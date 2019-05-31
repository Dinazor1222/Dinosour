// To add a rev to the list of revolutionaries, make sure it's rev (with if(SSticker.mode.name == "revolution)),
// then call SSticker.mode:add_revolutionary(_THE_PLAYERS_MIND_)
// nothing else needs to be done, as that proc will check if they are a valid target.
// Just make sure the converter is a head before you call it!
// To remove a rev (from brainwashing or w/e), call SSticker.mode:remove_revolutionary(_THE_PLAYERS_MIND_),
// this will also check they're not a head, so it can just be called freely
// If the game somtimes isn't registering a win properly, then SSticker.mode.check_win() isn't being called somewhere.


/datum/game_mode/revolution
	name = "revolution"
	config_tag = "revolution"
	report_type = "revolution"
	antag_flag = ROLE_REV
	false_report_weight = 10
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer")
	required_players = 30
	required_enemies = 2
	recommended_enemies = 3
	enemy_minimum_age = 14

	announce_span = "danger"
	announce_text = "Some crewmembers are attempting a coup!\n\
	<span class='danger'>Revolutionaries</span>: Expand your cause and overthrow the heads of staff by execution or otherwise.\n\
	<span class='notice'>Crew</span>: Prevent the revolutionaries from taking over the station."

	var/finished = 0
	var/check_counter = 0
	var/max_headrevs = 3
	var/datum/team/revolution/revolution
	var/list/datum/mind/headrev_candidates = list()
	var/end_when_heads_dead = TRUE
	var/victory_type = 0

///////////////////////////
//Announces the game type//
///////////////////////////
/datum/game_mode/revolution/announce()
	to_chat(world, "<B>The current game mode is - Revolution!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a revolution!<BR>\nRevolutionaries - Accomplish your objectives to seize control of the station. Convert other crewmembers (excluding the heads of staff, and security officers) to your cause by flashing them. Protect your leaders.<BR>\nPersonnel - Protect the heads of staff. Kill the leaders of the revolution, and brainwash the other revolutionaries (by beating them in the head).</B>")


///////////////////////////////////////////////////////////////////////////////
//Gets the round setup, cancelling if there's not enough players at the start//
///////////////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	for (var/i=1 to max_headrevs)
		if (antag_candidates.len==0)
			break
		var/datum/mind/lenin = antag_pick(antag_candidates)
		antag_candidates -= lenin
		headrev_candidates += lenin
		lenin.restricted_roles = restricted_jobs

	if(headrev_candidates.len < required_enemies)
		setup_error = "Not enough headrev candidates"
		return FALSE

	return TRUE

/datum/game_mode/revolution/post_setup()
	var/list/heads = SSjob.get_living_heads()
	var/list/sec = SSjob.get_living_sec()
	var/weighted_score = min(max(round(heads.len - ((8 - sec.len) / 3)),1),max_headrevs)

	for(var/datum/mind/rev_mind in headrev_candidates)	//People with return to lobby may still be in the lobby. Let's pick someone else in that case.
		if(isnewplayer(rev_mind.current))
			headrev_candidates -= rev_mind
			var/list/newcandidates = shuffle(antag_candidates)
			if(newcandidates.len == 0)
				continue
			for(var/M in newcandidates)
				var/datum/mind/lenin = M
				antag_candidates -= lenin
				newcandidates -= lenin
				if(isnewplayer(lenin.current)) //We don't want to make the same mistake again
					continue
				else
					var/mob/Nm = lenin.current
					if(Nm.job in restricted_jobs)	//Don't make the HOS a replacement revhead
						antag_candidates += lenin	//Let's let them keep antag chance for other antags
						continue

					headrev_candidates += lenin
					break

	while(weighted_score < headrev_candidates.len) //das vi danya
		var/datum/mind/trotsky = pick(headrev_candidates)
		antag_candidates += trotsky
		headrev_candidates -= trotsky

	revolution = new()

	for(var/datum/mind/rev_mind in headrev_candidates)
		log_game("[key_name(rev_mind)] has been selected as a head rev")
		var/datum/antagonist/rev/head/new_head = new()
		new_head.give_flash = TRUE
		new_head.give_hud = TRUE
		new_head.remove_clumsy = TRUE
		if(SSticker.mode.name == "domination")
			new_head.give_dom = TRUE
		rev_mind.add_antag_datum(new_head,revolution)

	revolution.update_objectives()
	revolution.update_heads()

	SSshuttle.registerHostileEnvironment(src)

	..()

/datum/game_mode/revolution/process()
	check_counter++
	if(check_counter >= 5)
		if(!finished)
			SSticker.mode.check_win()
		check_counter = 0
	return FALSE

//////////////////////////////////////
//Checks if the revs have won or not//
//////////////////////////////////////
/datum/game_mode/revolution/check_win()
	if(check_rev_victory())
		finished = 1
	else if(check_heads_victory())
		finished = 2
	return

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/revolution/check_finished()
	if(CONFIG_GET(keyed_list/continuous)["revolution"])
		if(finished)
			SSshuttle.clearHostileEnvironment(src)
		return ..()
	if(finished != 0 && end_when_heads_dead)
		return TRUE
	else
		return ..()

///////////////////////////////////////////////////
//Deals with converting players to the revolution//
///////////////////////////////////////////////////
/proc/is_revolutionary(mob/M)
	return M && istype(M) && M.mind && M.mind.has_antag_datum(/datum/antagonist/rev)

/proc/is_head_revolutionary(mob/M)
	return M && istype(M) && M.mind && M.mind.has_antag_datum(/datum/antagonist/rev/head)

//////////////////////////
//Checks for rev victory//
//////////////////////////
/datum/game_mode/revolution/proc/check_rev_victory()
	for(var/datum/objective/mutiny/objective in revolution.objectives)
		if(!(objective.check_completion()))
			return FALSE
	return TRUE

/////////////////////////////
//Checks for a head victory//
/////////////////////////////
/datum/game_mode/revolution/proc/check_heads_victory()
	for(var/datum/mind/rev_mind in revolution.head_revolutionaries())
		var/turf/T = get_turf(rev_mind.current)
		if(!considered_afk(rev_mind) && considered_alive(rev_mind) && is_station_level(T.z))
			if(ishuman(rev_mind.current) || ismonkey(rev_mind.current))
				return FALSE
	return TRUE
	victory_type = 3


/datum/game_mode/revolution/set_round_result()
	..()
	if(finished == 1)
		SSticker.mode_result = "win - heads killed"
		SSticker.news_report = REVS_WIN
	else if(finished == 2)
		SSticker.mode_result = "loss - rev heads killed"
		SSticker.news_report = REVS_LOSE

//TODO What should be displayed for revs in non-rev rounds
/datum/game_mode/revolution/special_report()
	if(finished == 1)
		return "<div class='panel redborder'><span class='redtext big'>The heads of staff were killed or exiled! The revolutionaries win!</span></div>"
	else if(finished == 2)
		return "<div class='panel redborder'><span class='redtext big'>The heads of staff managed to stop the revolution!</span></div>"

/datum/game_mode/revolution/generate_report()
	return "Employee unrest has spiked in recent weeks, with several attempted mutinies on heads of staff. Some crew have been observed using flashbulb devices to blind their colleagues, \
		who then follow their orders without question and work towards dethroning departmental leaders. Watch for behavior such as this with caution. If the crew attempts a mutiny, you and \
		your heads of staff are fully authorized to execute them using lethal weaponry - they will be later cloned and interrogated at Central Command."

/datum/game_mode/revolution/extended
	name = "extended_revolution"
	config_tag = "extended_revolution"
	end_when_heads_dead = FALSE

/datum/game_mode/revolution/speedy
	name = "speedy_revolution"
	config_tag = "speedy_revolution"
	end_when_heads_dead = FALSE
	var/endtime = null
	var/fuckingdone = FALSE

/datum/game_mode/revolution/speedy/pre_setup()
	endtime = world.time + 20 MINUTES
	return ..()

/datum/game_mode/revolution/speedy/process()
	. = ..()
	if(check_counter == 0)
		if (world.time > endtime && !fuckingdone)
			fuckingdone = TRUE
			for (var/obj/machinery/nuclearbomb/N in GLOB.nuke_list)
				if (!N.timing)
					N.timer_set = 200
					N.set_safety()
					N.set_active()

GLOBAL_VAR_INIT(dominator_count, 0)

/datum/game_mode/revolution/proc/check_victory_type()
	if(SSshuttle.emergency.mode == SHUTTLE_ESCAPE || SSshuttle.emergency.mode == SHUTTLE_ENDGAME)
		var/headcount = 0
		var/untracked_heads = SSjob.get_all_heads()
		for(var/mob/living/carbon/survivor in untracked_heads)
			if(survivor.ckey && considered_escaped(survivor.mind))
				headcount++
		if(!headcount)
			victory_type = 2
		else
			victory_type = 4

/datum/game_mode/revolution/proc/considered_escaped(datum/mind/M)
	if(M.force_escaped)
		return TRUE
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return FALSE
	var/turf/location = get_turf(M.current)
	if(!location || istype(location, /turf/open/floor/plasteel/shuttle/red) || istype(location, /turf/open/floor/mineral/plastitanium/red/brig))
		return FALSE
	return location.onCentCom() || location.onSyndieBase()

/datum/game_mode/revolution/domination
	name = "domination"
	config_tag = "domination"
	report_type = "domination"
	end_when_heads_dead = FALSE

/datum/game_mode/revolution/domination/post_setup()
	.=..()
	SSshuttle.clearHostileEnvironment(src)

/datum/game_mode/revolution/domination/special_report()
	if(victory_type == 1)
		return "<div class='panel redborder'><span class='redtext big'>Revolution Major Victory: The revolutionaries assumed total control of the station!</span></div>"
	else if(victory_type == 2)
		return "<div class='panel redborder'><span class='redtext big'>Revolution Minor Victory: An escape signal made it to Central Command, but the revolution did manage to kill most of the heads of staff!</span></div>"
	else if(victory_type == 3)
		return "<div class='panel redborder'><span class='redtext big'>Crew Major Victory: The crew managed to stop the revolutionaries from taking control of the station!</span></div>"
	else if(victory_type == 4)
		return "<div class='panel redborder'><span class='redtext big'>Crew Minor Victory: A head of staff managed to escape to warn Central Command of the revolution!</span></div>"

/datum/game_mode/revolution/check_rev_victory()
	for(var/obj/machinery/revdominator/N in GLOB.poi_list)
		if(N.takeover_complete == 1)
			victory_type = 1
			return TRUE
	return FALSE

/datum/game_mode/revolution/domination/check_heads_victory()
	var/dom_recount = 0
	for(var/obj/machinery/revdominator/N in GLOB.poi_list)
		dom_recount++
		if(N.active && !N.takeover_complete == 2)
			return FALSE
		if(N.takeover_complete == 2)
			victory_type = 3
			return TRUE
		if(dom_recount < GLOB.dominator_count)
			victory_type = 3
			return TRUE
		else
			return ..()

/datum/game_mode/revolution/domination/check_win()
	if(check_rev_victory())
		finished = 1
	else if(check_heads_victory())
		finished = 2
	return

/datum/game_mode/revolution/domination/check_finished()
	if(finished != 0)
		return TRUE
		check_victory_type()
	else
		return ..()

////////////
////////////

/obj/machinery/revdominator
	name = "dominator"
	desc = "This sinister-looking pile of machinery can be used to wrest control of all station systems. Requires a powered area that is not in space or blocked by a dense object to activate. May explode if destroyed."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator"
	density = TRUE
	anchored = FALSE
	can_be_unanchored = TRUE
	max_integrity = 400
	var/active = FALSE
	var/broken = FALSE
	var/last_chance = FALSE
	var/beepsound = 'sound/items/timer.ogg'
	var/next_beep
	var/obj/effect/countdown/revdominator/clock
	var/clock_set = 6000
	var/countdown
	var/takeover_complete = 0 // 0: Incomplete -- 1: Successful -- 2: All Dominators Destroyed

/obj/machinery/revdominator/Initialize()
	. = ..()
	clock = new(src)
	GLOB.dominator_count++
	GLOB.poi_list += src
	var/num_revheads = 0
	for(var/mob/living/carbon/survivor in GLOB.alive_mob_list)
		if(survivor.ckey)
			if(survivor.mind.has_antag_datum(/datum/antagonist/rev/head) == TRUE)
				num_revheads++
	if(GLOB.dominator_count >= num_revheads)
		last_chance = TRUE
	if(isopenturf(get_turf(src)) && !isspaceturf(get_turf(src)))
		anchored = 1
	else
		anchored = 0
	interaction_flags_machine -= INTERACT_MACHINE_ALLOW_SILICON

/obj/machinery/revdominator/update_icon()
	if(active)
		icon_state = "dominator-red"
	else
		icon_state = "dominator"

/obj/machinery/revdominator/proc/toggle_on(mob/user)
	notify_ghosts("\A [src] has been activated at [get_area(src)]!", source = src, action = NOTIFY_ORBIT)
	clock.start()
	START_PROCESSING(SSfastprocess, src)
	active = TRUE
	update_icon()
	SSshuttle.registerHostileEnvironment(src)
	SSmapping.add_nuke_threat(src)
	var/num_revs = 0
	var/num_nonrevs = 0
	for(var/mob/living/carbon/survivor in GLOB.alive_mob_list)
		if(survivor.ckey)
			if(survivor.mind.has_antag_datum(/datum/antagonist/rev) == TRUE)
				num_revs++
			else
				num_nonrevs++
	clock_set = max((clock_set*(num_revs/num_nonrevs)),2400)
	countdown = world.time + clock_set
	set_security_level("delta")
	for(var/obj/item/pinpointer/nuke/P in GLOB.pinpointer_list)
		P.switch_mode_to(TRACK_DOMINATOR)
	var/turf/T = get_turf(src)
	T.visible_message("<span class='warning'>The [src]'s anchoring bolts lock into place with an intense click as it activates.</span>")
	minor_announce("Hostile takeover signal detected. Signal origin pinpointed to [get_area(src)].")
	anchored = 1
	can_be_unanchored = 0

/obj/machinery/revdominator/proc/toggle_off(mob/user)
	QDEL_NULL(clock)
	broken = TRUE
	if(active)
		active = FALSE
		GLOB.poi_list -= src
		STOP_PROCESSING(SSfastprocess, src)
		SSshuttle.clearHostileEnvironment(src)
		SSmapping.remove_nuke_threat(src)
		set_security_level("red")
		minor_announce("Hostile activity within station systems has ceased.")
		for(var/obj/item/pinpointer/nuke/P in GLOB.pinpointer_list)
			P.switch_mode_to(TRACK_NUKE_DISK)


/obj/machinery/revdominator/proc/takeover()
	sound_to_playing_players('sound/machines/alarm.ogg')
	sleep(100)
	to_chat(world, "<B>A device has taken control of all of the station's systems!</B>")
	resistance_flags += INDESTRUCTIBLE
	takeover_complete = 1
	SSticker.mode.check_win()
//	SSticker.force_ending = 1

/obj/machinery/revdominator/proc/seconds_remaining()
	. = max(0, (round((countdown - world.time) / 10)))

/obj/machinery/revdominator/interact(mob/user)
	if(active || takeover_complete == 1)
		to_chat(user, "<span class='notice'>The embedded timer reads: <b>[seconds_remaining()]</b>.</span>")
		return
	if(!active)
		if((user.mind.has_antag_datum(/datum/antagonist/rev) == FALSE) || alert(user, "Attempt to take control of all station systems?", "[src]", "Yes", "Cancel") == "Cancel")
			if(user.canUseTopic(src, BE_CLOSE))
				to_chat(user, "<b>You warily regard the inactive \[src].</b>")
				return
			else
				return
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(!is_station_level(src.z))
		to_chat(user, "<span class='notice'>Dominator is unable to establish connection to station systems. Relocate Dominator to station territory before continuing.</span>")
		return
	for(var/obj/machinery/revdominator/N in GLOB.poi_list)
		if(N.active)
			to_chat(user, "<span class='notice'>Station takeover is underway from another location. Unable to initiate takeover. Aborting.</span>")
			return
	if(SSshuttle.emergency.mode == SHUTTLE_ESCAPE || SSshuttle.emergency.mode == SHUTTLE_ENDGAME)
		to_chat(user, "<span class='notice'>Successful emergency evacuation signal detected. Unable to initiate takeover.</span>")
		return
	if(src.powered() && isopenturf(get_turf(src)) && !isspaceturf(get_turf(src)))
		if(do_after(user,50,target = src) && !active)
			toggle_on(user)
			add_fingerprint(user)
			next_beep = world.time + 10
			playsound(loc, 'sound/items/nuke_toy_lowpower.ogg', 50, 1)
			to_chat(user, "<b>You activate the [src].</b>")
			message_admins("[ADMIN_LOOKUPFLW(user)] activated a dominator at [ADMIN_VERBOSEJMP(src.loc)] with a [seconds_remaining()] timer.")
	else
		to_chat(user, "<span class='notice'>Device does not have power, is blocked by a dense object, or is in space. Aborting.</span>")

/obj/machinery/revdominator/attackby(obj/item/I, mob/user, params)
	if((I.tool_behaviour == TOOL_WRENCH) && (src.can_be_unanchored == 1))
		to_chat(user, "<span class='notice'>You begin to [anchored ? "unwrench" : "wrench"] [src].</span>")
		if(I.use_tool(src, user, 20, volume=50))
			to_chat(user, "<span class='notice'>You successfully [anchored ? "unwrench" : "wrench"] [src].</span>")
			setAnchored(!anchored)
	else
		return ..()

/obj/machinery/revdominator/Destroy()
	explosion(src,0,0,2,2, flame_range = 2)
	if(last_chance)
		takeover_complete = 2
		SSticker.mode.check_win()
	if(takeover_complete == 1)
		return
	toggle_off()
	return ..()

/obj/machinery/revdominator/process()
	if(!active)
		STOP_PROCESSING(SSfastprocess, src)
		return
	var/sec_left = seconds_remaining()
	if(!sec_left)
		active = FALSE
		takeover()
	if(!isnull(next_beep) && (next_beep <= world.time))
		var/volume
		switch(seconds_remaining())
			if(0 to 5)
				volume = 50
			if(5 to 10)
				volume = 40
			if(10 to 15)
				volume = 30
			if(15 to 20)
				volume = 20
			if(20 to 25)
				volume = 10
			else
				volume = 5
		playsound(loc, beepsound, volume, 0)
		next_beep = world.time + 10