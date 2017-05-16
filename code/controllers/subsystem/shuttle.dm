#define HIGHLIGHT_DYNAMIC_TRANSIT 1

SUBSYSTEM_DEF(shuttle)
	name = "Shuttle"
	wait = 10
	init_order = INIT_ORDER_SHUTTLE
	flags = SS_KEEP_TIMING|SS_NO_TICK_CHECK
	runlevels = RUNLEVEL_SETUP | RUNLEVEL_GAME

	var/list/mobile = list()
	var/list/stationary = list()
	var/list/transit = list()

	var/list/turf/transit_turfs = list()
	var/list/transit_requesters = list()
	var/clear_transit = FALSE

		//emergency shuttle stuff
	var/obj/docking_port/mobile/emergency/emergency
	var/obj/docking_port/mobile/arrivals/arrivals
	var/obj/docking_port/mobile/emergency/backup/backup_shuttle
	var/emergencyCallTime = 6000	//time taken for emergency shuttle to reach the station when called (in deciseconds)
	var/emergencyDockTime = 1800	//time taken for emergency shuttle to leave again once it has docked (in deciseconds)
	var/emergencyEscapeTime = 1200	//time taken for emergency shuttle to reach a safe distance after leaving station (in deciseconds)
	var/area/emergencyLastCallLoc
	var/emergencyCallAmount = 0		//how many times the escape shuttle was called
	var/emergencyNoEscape
	var/list/horrible_things = list()
	var/recall_timer_id
	var/list/hostileEnvironments = list()
	var/annoyed_admiral_message

		//supply shuttle stuff
	var/obj/docking_port/mobile/supply/supply
	var/ordernum = 1					//order number given to next order
	var/points = 5000					//number of trade-points we have
	var/centcom_message = ""			//Remarks from Centcom on how well you checked the last order.
	var/list/discoveredPlants = list()	//Typepaths for unusual plants we've already sent CentComm, associated with their potencies

	var/list/supply_packs = list()
	var/list/shoppinglist = list()
	var/list/requestlist = list()
	var/list/orderhistory = list()

	var/datum/round_event/shuttle_loan/shuttle_loan

	var/shuttle_purchased = FALSE //If the station has purchased a replacement escape shuttle this round
	var/list/shuttle_purchase_requirements_met = list() //For keeping track of ingame events that would unlock new shuttles, such as defeating a boss or discovering a secret item

	var/lockdown = FALSE	//disallow transit after nuke goes off

/datum/controller/subsystem/shuttle/Initialize(timeofday)
	if(!arrivals)
		WARNING("No /obj/docking_port/mobile/arrivals placed on the map!")
	if(!emergency)
		WARNING("No /obj/docking_port/mobile/emergency placed on the map!")
	if(!backup_shuttle)
		WARNING("No /obj/docking_port/mobile/emergency/backup placed on the map!")
	if(!supply)
		WARNING("No /obj/docking_port/mobile/supply placed on the map!")

	ordernum = rand(1, 9000)

	for(var/pack in subtypesof(/datum/supply_pack))
		var/datum/supply_pack/P = new pack()
		if(!P.contains)
			continue
		supply_packs[P.type] = P

	setup_transit_zone()
	initial_move()
#ifdef HIGHLIGHT_DYNAMIC_TRANSIT
	color_space()
#endif
	..()

/datum/controller/subsystem/shuttle/proc/setup_transit_zone()
	if(GLOB.transit_markers.len == 0)
		WARNING("No /obj/effect/landmark/transit placed on the map!")
		return
	// transit zone
	var/turf/A = get_turf(GLOB.transit_markers[1])
	var/turf/B = get_turf(GLOB.transit_markers[2])
	for(var/i in block(A, B))
		var/turf/T = i
		T.ChangeTurf(/turf/open/space)
		transit_turfs += T
		T.flags |= UNUSED_TRANSIT_TURF

#ifdef HIGHLIGHT_DYNAMIC_TRANSIT
/datum/controller/subsystem/shuttle/proc/color_space()
	if(GLOB.transit_markers.len == 0)
		WARNING("No /obj/effect/landmark/transit placed on the map!")
		return
	var/turf/A = get_turf(GLOB.transit_markers[1])
	var/turf/B = get_turf(GLOB.transit_markers[2])
	for(var/i in block(A, B))
		var/turf/T = i
		// Only dying the "pure" space, not the transit tiles
		if(istype(T, /turf/open/space/transit) || !isspaceturf(T))
			continue
		if((T.x == A.x) || (T.x == B.x) || (T.y == A.y) || (T.y == B.y))
			T.color = "#ffff00"
		else
			T.color = "#00ffff"
#endif

	//world.log << "[transit_turfs.len] transit turfs registered"

/datum/controller/subsystem/shuttle/fire()
	for(var/thing in mobile)
		if(!thing)
			mobile.Remove(thing)
			continue
		var/obj/docking_port/mobile/P = thing
		P.check()
	var/changed_transit = FALSE
	for(var/thing in transit)
		var/obj/docking_port/stationary/transit/T = thing
		if(!T.owner)
			qdel(T, force=TRUE)
			changed_transit = TRUE
		// This next one removes transit docks/zones that aren't
		// immediately being used. This will mean that the zone creation
		// code will be running a lot.
		var/obj/docking_port/mobile/owner = T.owner
		if(owner)
			var/idle = owner.mode == SHUTTLE_IDLE
			var/not_centcom_evac = owner.launch_status == NOLAUNCH
			var/not_in_use = (!T.get_docked())
			if(idle && not_centcom_evac && not_in_use)
				qdel(T, force=TRUE)
				changed_transit = TRUE
	if(clear_transit)
		transit_requesters.Cut()
		for(var/i in transit)
			qdel(i, force=TRUE)
		setup_transit_zone()
		clear_transit = FALSE
		changed_transit = TRUE
#ifdef HIGHLIGHT_DYNAMIC_TRANSIT
	if(changed_transit)
		color_space()
#endif

	while(transit_requesters.len)
		var/requester = popleft(transit_requesters)
		var/success = generate_transit_dock(requester)
		if(!success) // BACK OF THE QUEUE
			transit_requesters += requester
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/shuttle/proc/getShuttle(id)
	for(var/obj/docking_port/mobile/M in mobile)
		if(M.id == id)
			return M
	WARNING("couldn't find shuttle with id: [id]")

/datum/controller/subsystem/shuttle/proc/getDock(id)
	for(var/obj/docking_port/stationary/S in stationary)
		if(S.id == id)
			return S
	WARNING("couldn't find dock with id: [id]")

/datum/controller/subsystem/shuttle/proc/requestEvac(mob/user, call_reason, legitimacy_check=TRUE)
	if(!emergency)
		WARNING("requestEvac(): There is no emergency shuttle, but the \
			shuttle was called. Using the backup shuttle instead.")
		if(!backup_shuttle)
			throw EXCEPTION("requestEvac(): There is no emergency shuttle, \
			or backup shuttle! The game will be unresolvable. This is \
			possibly a mapping error, more likely a bug with the shuttle \
			manipulation system, or badminry. It is possible to manually \
			resolve this problem by loading an emergency shuttle template \
			manually, and then calling register() on the mobile docking port. \
			Good luck.")
			return
		emergency = backup_shuttle

	if(world.time - SSticker.round_start_time < config.shuttle_refuel_delay)
		to_chat(user, "The emergency shuttle is refueling. Please wait another [abs(round(((world.time - SSticker.round_start_time) - config.shuttle_refuel_delay)/600))] minutes before trying again.")
		return

	switch(emergency.mode)
		if(SHUTTLE_RECALL)
			to_chat(user, "The emergency shuttle may not be called while returning to Centcom.")
			return
		if(SHUTTLE_CALL)
			to_chat(user, "The emergency shuttle is already on its way.")
			return
		if(SHUTTLE_DOCKED)
			to_chat(user, "The emergency shuttle is already here.")
			return
		if(SHUTTLE_IGNITING)
			to_chat(user, "The emergency shuttle is firing its engines to leave.")
			return
		if(SHUTTLE_ESCAPE)
			to_chat(user, "The emergency shuttle is moving away to a safe distance.")
			return
		if(SHUTTLE_STRANDED)
			to_chat(user, "The emergency shuttle has been disabled by Centcom.")
			return

	call_reason = trim(html_encode(call_reason))

	if(length(call_reason) < CALL_SHUTTLE_REASON_LENGTH && seclevel2num(get_security_level()) > SEC_LEVEL_GREEN)
		to_chat(user, "You must provide a reason.")
		return

	var/area/signal_origin = get_area(user)
	var/emergency_reason = "\nNature of emergency:\n\n[call_reason]"
	var/security_num = seclevel2num(get_security_level())
	switch(security_num)
		if(SEC_LEVEL_RED,SEC_LEVEL_DELTA)
			emergency.request(null, signal_origin, html_decode(emergency_reason), 1) //There is a serious threat we gotta move no time to give them five minutes.
		else
			emergency.request(null, signal_origin, html_decode(emergency_reason), 0)

	log_game("[key_name(user)] has called the shuttle.")
	message_admins("[key_name_admin(user)] has called the shuttle.")

	if(legitimacy_check)
		check_call_legitimacy()


/datum/controller/subsystem/shuttle/proc/check_call_legitimacy()
	if(station_in_trouble())
		message_admins("Shuttle call is legitimate by the listed metrics.")
		return

	var/time_to_recall = rand(600, 1500)
	recall_timer_id = addtimer(CALLBACK(src, .proc/recall_illegitimate, emergency.timer), time_to_recall, TIMER_STOPPABLE)
	if(!annoyed_admiral_message)
		annoyed_admiral_message = pick("Do you know how expensive these stations are?","Stop wasting my time.","I was sleeping, thanks a lot.","Stand and fight you cowards!","You knew the risks coming in.","Stop being paranoid.","Whatever's broken just build a new one.","No.", "<i>null</i>","<i>Error: No comment given.</i>", "It's a good day to die!")

	message_admins("Shuttle will recall automatically. (<A HREF='?_src_=holder;stop_autorecall=\ref[usr]'>STOP AUTORECALL</A>) (<A HREF='?_src_=holder;set_annoyed_admiral_message=1'>SET ANNOYED ADMIRAL MESSAGE</A>)")

/datum/controller/subsystem/shuttle/proc/recall_illegitimate(old_timer)
	if(emergency.mode != SHUTTLE_CALL || emergency.timer != old_timer)
		return

	emergency.cancel(/area/centcom)
	message_admins("Shuttle has been automatically recalled.")
	log_game("Shuttle has been automatically recalled.")

	sleep(50)
	var/intercepttext = "<FONT size = 3><b>NanoTrasen Update</b>: Request For Shuttle.</FONT><HR>\
						To whom it may concern:<BR><BR>\
						We have taken note of the situation upon [station_name()] and have come to the \
						conclusion that it does not warrant the abandonment of the station.<BR>\
						If you do not agree with our opinion we suggest that you open a direct \
						line with us and explain the nature of your crisis.<BR><BR>\
						<i>This message has been automatically generated based upon readings from long \
						range diagnostic tools. To assure the quality of your request every finalized report \
						is reviewed by an on-call rear admiral.<BR>\
						<b>Rear Admiral's Notes:</b> \
						[annoyed_admiral_message]"
	annoyed_admiral_message = null
	print_command_report(intercepttext, announce=TRUE)

/datum/controller/subsystem/shuttle/proc/station_in_trouble() //Checks are sorted in rough order of processing cost
	. = FALSE
	message_admins("Emergency shuttle legitimacy checks follow:")

	listclearnulls(SSshuttle.horrible_things)
	var/num_things = SSshuttle.horrible_things.len
	message_admins("[num_things] horrible things on station[num_things ? ":[english_list(SSshuttle.horrible_things)]" : ""]")

	if(num_things)
		. = TRUE

	message_admins("Round length is [round(world.time / 600)] minutes, boredom threshold is set to [config.shuttle_boredom_check] minutes.")
	if(world.time >= (config.shuttle_boredom_check * 600)) //Extended mercy and/or boring/ineffective antags
		. = TRUE

	var/list/living_crew_bodies = list()
	var/list/living_crew_minds	= list()
	for(var/mob/Player in GLOB.mob_list)
		if(Player.mind && Player.stat != DEAD && !isnewplayer(Player) &&!isbrain(Player))
			living_crew_bodies += Player
			living_crew_minds += Player.mind

	var/living_ratio
	if(!GLOB.joined_player_list.len)
		living_ratio = INFINITY
	else
		living_ratio = living_crew_bodies.len / GLOB.joined_player_list.len
	message_admins("[living_ratio*100]% of all joined crew are alive, minimum is [config.shuttle_life_check*100]%.")
	if(living_ratio <= config.shuttle_life_check) //Dead people everywhere
		. = TRUE

	var/list/antagonist_crew_minds = list()
	for(var/datum/mind/M in living_crew_minds)
		if(M.special_role)
			antagonist_crew_minds += M

	var/antag_ratio = antagonist_crew_minds.len / living_crew_minds.len
	if(antag_ratio >= config.shuttle_antag_overrun) //Station ruled by antags
		. = TRUE
	message_admins("[antag_ratio*100]% living minds are special roles, minimum to call is [config.shuttle_antag_overrun*100]%")

	var/datum/station_state/current_state = new /datum/station_state()
	current_state.count()
	var/score = GLOB.start_state.score(current_state)
	if(score < config.shuttle_infrastructure_check) //Station bombed to hell/singulo'd
		. = TRUE

	message_admins("Station integrity is [score*100]%, shuttle can be called if [config.shuttle_infrastructure_check*100]% or lower.")

// Called when an emergency shuttle mobile docking port is
// destroyed, which will only happen with admin intervention
/datum/controller/subsystem/shuttle/proc/emergencyDeregister()
	// When a new emergency shuttle is created, it will override the
	// backup shuttle.
	src.emergency = src.backup_shuttle

/datum/controller/subsystem/shuttle/proc/cancelEvac(mob/user)
	if(canRecall())
		emergency.cancel(get_area(user))
		log_game("[key_name(user)] has recalled the shuttle.")
		message_admins("[key_name_admin(user)] has recalled the shuttle.")
		return 1

/datum/controller/subsystem/shuttle/proc/canRecall()
	if(!emergency || emergency.mode != SHUTTLE_CALL)
		return
	if(SSticker.mode.name == "meteor")
		return
	var/security_num = seclevel2num(get_security_level())
	switch(security_num)
		if(SEC_LEVEL_GREEN)
			if(emergency.timeLeft(1) < emergencyCallTime)
				return
		if(SEC_LEVEL_BLUE)
			if(emergency.timeLeft(1) < emergencyCallTime * 0.5)
				return
		else
			if(emergency.timeLeft(1) < emergencyCallTime * 0.25)
				return
	return 1

/datum/controller/subsystem/shuttle/proc/autoEvac()
	var/callShuttle = 1

	for(var/thing in GLOB.shuttle_caller_list)
		if(isAI(thing))
			var/mob/living/silicon/ai/AI = thing
			if(AI.deployed_shell && !AI.deployed_shell.client)
				continue
			if(AI.stat || !AI.client)
				continue
		else if(istype(thing, /obj/machinery/computer/communications))
			var/obj/machinery/computer/communications/C = thing
			if(C.stat & BROKEN)
				continue

		var/turf/T = get_turf(thing)
		if(T && T.z == ZLEVEL_STATION)
			callShuttle = 0
			break

	if(callShuttle)
		if(EMERGENCY_IDLE_OR_RECALLED)
			emergency.request(null, set_coefficient = 2.5)
			log_game("There is no means of calling the shuttle anymore. Shuttle automatically called.")
			message_admins("All the communications consoles were destroyed and all AIs are inactive. Shuttle called.")

/datum/controller/subsystem/shuttle/proc/registerHostileEnvironment(datum/bad)
	hostileEnvironments[bad] = TRUE
	checkHostileEnvironment()

/datum/controller/subsystem/shuttle/proc/clearHostileEnvironment(datum/bad)
	hostileEnvironments -= bad
	checkHostileEnvironment()

/datum/controller/subsystem/shuttle/proc/checkHostileEnvironment()
	for(var/datum/d in hostileEnvironments)
		if(!istype(d) || QDELETED(d))
			hostileEnvironments -= d
	emergencyNoEscape = hostileEnvironments.len

	if(emergencyNoEscape && (emergency.mode == SHUTTLE_IGNITING))
		emergency.mode = SHUTTLE_STRANDED
		emergency.timer = null
		emergency.sound_played = FALSE
		priority_announce("Hostile environment detected. \
			Departure has been postponed indefinitely pending \
			conflict resolution.", null, 'sound/misc/notice1.ogg', "Priority")
	if(!emergencyNoEscape && (emergency.mode == SHUTTLE_STRANDED))
		emergency.mode = SHUTTLE_DOCKED
		emergency.setTimer(emergencyDockTime)
		priority_announce("Hostile environment resolved. \
			You have 3 minutes to board the Emergency Shuttle.",
			null, 'sound/AI/shuttledock.ogg', "Priority")

//try to move/request to dockHome if possible, otherwise dockAway. Mainly used for admin buttons
/datum/controller/subsystem/shuttle/proc/toggleShuttle(shuttleId, dockHome, dockAway, timed)
	var/obj/docking_port/mobile/M = getShuttle(shuttleId)
	if(!M)
		return 1
	var/obj/docking_port/stationary/dockedAt = M.get_docked()
	var/destination = dockHome
	if(dockedAt && dockedAt.id == dockHome)
		destination = dockAway
	if(timed)
		if(M.request(getDock(destination)))
			return 2
	else
		if(M.dock(getDock(destination)))
			return 2
	return 0	//dock successful


/datum/controller/subsystem/shuttle/proc/moveShuttle(shuttleId, dockId, timed)
	var/obj/docking_port/mobile/M = getShuttle(shuttleId)
	var/obj/docking_port/stationary/D = getDock(dockId)

	if(!M)
		return 1
	if(timed)
		if(M.request(D))
			return 2
	else
		if(M.dock(D))
			return 2
	return 0	//dock successful

/datum/controller/subsystem/shuttle/proc/request_transit_dock(obj/docking_port/mobile/M)
	if(!istype(M))
		throw EXCEPTION("[M] is not a mobile docking port")

	if(M.assigned_transit)
		return
	else
		if(!(M in transit_requesters))
			transit_requesters += M

/datum/controller/subsystem/shuttle/proc/generate_transit_dock(obj/docking_port/mobile/M)
	// First, determine the size of the needed zone
	// Because of shuttle rotation, the "width" of the shuttle is not
	// always x.
	var/travel_dir = M.preferred_direction
	// Remember, the direction is the direction we appear to be
	// coming from
	var/dock_angle = dir2angle(M.preferred_direction) + M.port_angle + 180
	var/dock_dir = angle2dir(dock_angle)

	var/transit_width = SHUTTLE_TRANSIT_BORDER * 2
	var/transit_height = SHUTTLE_TRANSIT_BORDER * 2

	// Shuttles travelling on their side have their dimensions swapped
	// from our perspective
	switch(dock_dir)
		if(NORTH, SOUTH)
			transit_width += M.width
			transit_height += M.height
		if(EAST, WEST)
			transit_width += M.height
			transit_height += M.width
/*
	to_chat(world, "The attempted transit dock will be [transit_width] width, and \)
		[transit_height] in height. The travel dir is [travel_dir]."
*/

	// Then find a place to put the zone

	var/list/proposed_zone

	base:
		for(var/i in transit_turfs)
			CHECK_TICK
			var/turf/topleft = i
			if(!(topleft.flags & UNUSED_TRANSIT_TURF))
				continue
			var/turf/bottomright = locate(topleft.x + transit_width,
				topleft.y + transit_height, topleft.z)
			if(!bottomright)
				continue
			if(!(bottomright.flags & UNUSED_TRANSIT_TURF))
				continue

			proposed_zone = block(topleft, bottomright)
			if(!proposed_zone)
				continue
			for(var/j in proposed_zone)
				var/turf/T = j
				if(!T)
					continue base
				if(!(T.flags & UNUSED_TRANSIT_TURF))
					continue base
			//to_chat(world, "[COORD(topleft)] and [COORD(bottomright)]")
			break base

	if((!proposed_zone) || (!proposed_zone.len))
		return FALSE

	var/turf/topleft = proposed_zone[1]
	//to_chat(world, "[COORD(topleft)] is TOPLEFT")
	// Then create a transit docking port in the middle
	var/coords = M.return_coords(0, 0, dock_dir)
	//to_chat(world, json_encode(coords))
	/*  0------2
        |      |
        |      |
        |  x   |
        3------1
	*/

	var/x0 = coords[1]
	var/y0 = coords[2]
	var/x1 = coords[3]
	var/y1 = coords[4]
	// Then we want the point closest to -infinity,-infinity
	var/x2 = min(x0, x1)
	var/y2 = min(y0, y1)
/*
	var/lowx = topleft.x + SHUTTLE_TRANSIT_BORDER
	var/lowy = topleft.y + SHUTTLE_TRANSIT_BORDER

	var/turf/low_point = locate(lowx, lowy, topleft.z)
	new /obj/effect/landmark/stationary(low_point)
	to_chat(world, "Starting at the low point, we go [x2],[y2]")
*/
	// Then invert the numbers
	var/transit_x = topleft.x + SHUTTLE_TRANSIT_BORDER + abs(x2)
	var/transit_y = topleft.y + SHUTTLE_TRANSIT_BORDER + abs(y2)

	var/transit_path = /turf/open/space/transit
	switch(travel_dir)
		if(NORTH)
			transit_path = /turf/open/space/transit/north
		if(SOUTH)
			transit_path = /turf/open/space/transit/south
		if(EAST)
			transit_path = /turf/open/space/transit/east
		if(WEST)
			transit_path = /turf/open/space/transit/west

	//to_chat(world, "Docking port at [transit_x], [transit_y], [topleft.z]")
	var/turf/midpoint = locate(transit_x, transit_y, topleft.z)
	if(!midpoint)
		return FALSE
	//to_chat(world, "Making transit dock at [COORD(midpoint)]")
	var/area/shuttle/transit/A = new()
	A.parallax_movedir = travel_dir
	A.contents = proposed_zone
	var/obj/docking_port/stationary/transit/new_transit_dock = new(midpoint)
	new_transit_dock.assigned_turfs = proposed_zone
	new_transit_dock.name = "Transit for [M.id]/[M.name]"
	new_transit_dock.turf_type = transit_path
	new_transit_dock.owner = M
	new_transit_dock.assigned_area = A


	// Add 180, because ports point inwards, rather than outwards
	new_transit_dock.setDir(angle2dir(dock_angle))

	for(var/i in new_transit_dock.assigned_turfs)
		var/turf/T = i
		T.ChangeTurf(transit_path)
		T.flags &= ~(UNUSED_TRANSIT_TURF)

	M.assigned_transit = new_transit_dock
	return TRUE

/datum/controller/subsystem/shuttle/proc/initial_move()
	for(var/obj/docking_port/mobile/M in mobile)
		if(!M.roundstart_move)
			continue
		M.dockRoundstart()
		CHECK_TICK

/datum/controller/subsystem/shuttle/Recover()
	if (istype(SSshuttle.mobile))
		mobile = SSshuttle.mobile
	if (istype(SSshuttle.stationary))
		stationary = SSshuttle.stationary
	if (istype(SSshuttle.transit))
		transit = SSshuttle.transit
	if (istype(SSshuttle.discoveredPlants))
		discoveredPlants = SSshuttle.discoveredPlants
	if (istype(SSshuttle.requestlist))
		requestlist = SSshuttle.requestlist
	if (istype(SSshuttle.orderhistory))
		orderhistory = SSshuttle.orderhistory
	if (istype(SSshuttle.emergency))
		emergency = SSshuttle.emergency
	if (istype(SSshuttle.backup_shuttle))
		backup_shuttle = SSshuttle.backup_shuttle
	if (istype(SSshuttle.supply))
		supply = SSshuttle.supply
	if (istype(SSshuttle.transit_turfs))
		transit_turfs = SSshuttle.transit_turfs

	centcom_message = SSshuttle.centcom_message
	ordernum = SSshuttle.ordernum
	points = SSshuttle.points


/datum/controller/subsystem/shuttle/proc/is_in_shuttle_bounds(atom/A)
	var/area/current = get_area(A)
	if(istype(current, /area/shuttle) && !istype(current,/area/shuttle/transit))
		return TRUE
	for(var/obj/docking_port/mobile/M in mobile)
		if(M.is_in_shuttle_bounds(A))
			return TRUE
