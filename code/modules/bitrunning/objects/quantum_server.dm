#define ONLY_TURF 1 // There should only ever be one turf at the bottom left of the map.
#define REDACTED "???"
#define MAX_DISTANCE 4 // How far crates can spawn from the server
#define COMSIG_LAZY_TEMPLATE_LOADED "temporary ci fix"

/obj/machinery/quantum_server
	name = "quantum server"

	circuit = /obj/item/circuitboard/machine/quantum_server
	density = TRUE
	desc = "A hulking computational machine designed to fabricate virtual domains."
	icon = 'icons/obj/machines/bitrunning.dmi'
	base_icon_state = "qserver"
	icon_state = "qserver"
	/// Affects server cooldown efficiency
	var/capacitor_coefficient = 1
	/// The loaded map template, map_template/virtual_domain
	var/datum/lazy_template/virtual_domain/generated_domain
	/// The loaded safehouse, map_template/safehouse
	var/datum/map_template/safehouse/generated_safehouse
	/// The connected console
	var/datum/weakref/console_ref
	/// If the current domain was a random selection
	var/domain_randomized = FALSE
	/// If any threats were spawned, adds to rewards
	var/domain_threats = 0
	/// Prevents multiple user actions. Handled by loading domains and cooldowns
	var/is_ready = TRUE
	/// List of available domains
	var/list/available_domains = list()
	/// Current plugged in users
	var/list/datum/weakref/avatar_connection_refs = list()
	/// Cached list of mutable mobs in zone for cybercops
	var/list/mob/living/mutation_candidates = list()
	/// Any ghosts that have spawned in
	var/list/mob/living/spawned_threats = list()
	/// Scales loot with extra players
	var/multiplayer_bonus = 1.1
	/// The amount of points in the system, used to purchase maps
	var/points = 0
	/// Keeps track of the number of times someone has built a hololadder
	var/retries_spent = 0
	/// Changes how much info is available on the domain
	var/scanner_tier = 1
	/// Length of time it takes for the server to cool down after resetting. Here to give runners downtime so their faces don't get stuck like that
	var/server_cooldown_time = 3 MINUTES
	/// Applies bonuses to rewards etc
	var/servo_bonus = 0
	/// The turfs we can place a hololadder on.
	var/turf/exit_turfs = list()
	/// The turfs on station where we generate loot.
	var/turf/receive_turfs = list()

/obj/machinery/quantum_server/Initialize(mapload)
	. = ..()

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/quantum_server/LateInitialize()
	. = ..()

	if(isnull(console_ref))
		find_console()

	RegisterSignals(src, list(COMSIG_MACHINERY_BROKEN, COMSIG_MACHINERY_POWER_LOST), PROC_REF(on_broken))
	RegisterSignal(src, COMSIG_QDELETING, PROC_REF(on_delete))
	RegisterSignal(src, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(src, COMSIG_BITRUNNER_CLIENT_CONNECTED, PROC_REF(on_client_connected))
	RegisterSignal(src, COMSIG_BITRUNNER_CLIENT_DISCONNECTED, PROC_REF(on_client_disconnected))
	RegisterSignal(src, COMSIG_BITRUNNER_SPAWN_GLITCH, PROC_REF(on_threat_created))

	// This further gets sorted in the client by cost so it's random and grouped
	available_domains = shuffle(subtypesof(/datum/lazy_template/virtual_domain))

/obj/machinery/quantum_server/Destroy(force)
	. = ..()

	available_domains.Cut()
	QDEL_LIST(mutation_candidates)
	QDEL_LIST(avatar_connection_refs)
	QDEL_LIST(spawned_threats)
	QDEL_NULL(exit_turfs)
	QDEL_NULL(receive_turfs)
	QDEL_NULL(generated_domain)
	QDEL_NULL(generated_safehouse)

/obj/machinery/quantum_server/update_appearance(updates)
	if(isnull(generated_domain) || !is_operational)
		set_light(0)
		return ..()

	set_light_color(is_ready ? LIGHT_COLOR_BABY_BLUE : LIGHT_COLOR_FIRE)
	set_light(2, 1.5)

	return ..()

/obj/machinery/quantum_server/update_icon_state()
	if(isnull(generated_domain) || !is_operational)
		icon_state = base_icon_state
		return ..()

	icon_state = "[base_icon_state]_[is_ready ? "on" : "off"]"
	return ..()

/obj/machinery/quantum_server/crowbar_act(mob/living/user, obj/item/crowbar)
	. = ..()

	if(!is_ready)
		balloon_alert(user, "it's scalding hot!")
		return TRUE
	if(length(avatar_connection_refs))
		balloon_alert(user, "all clients must disconnect!")
		return TRUE
	if(default_deconstruction_crowbar(crowbar))
		return TRUE
	return FALSE

/obj/machinery/quantum_server/screwdriver_act(mob/living/user, obj/item/screwdriver)
	. = ..()

	if(!is_ready)
		balloon_alert(user, "it's scalding hot!")
		return TRUE
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_panel", icon_state, screwdriver))
		return TRUE
	return FALSE

/obj/machinery/quantum_server/RefreshParts()
	. = ..()

	var/capacitor_rating = 1.15
	var/datum/stock_part/capacitor/cap = locate() in component_parts
	capacitor_rating -= cap.tier * 0.15

	capacitor_coefficient = capacitor_rating

	var/datum/stock_part/scanning_module/scanner = locate() in component_parts
	if(scanner)
		scanner_tier = scanner.tier

	var/servo_rating = 0
	for(var/datum/stock_part/servo/servo in component_parts)
		servo_rating += servo.tier * 0.1

	servo_bonus = servo_rating

	SEND_SIGNAL(src, COMSIG_BITRUNNER_SERVER_UPGRADED, scanner_tier)

/// Gives all current occupants a notification that the server is going down
/obj/machinery/quantum_server/proc/begin_shutdown(mob/user)
	if(isnull(generated_domain))
		return

	if(!length(avatar_connection_refs))
		balloon_alert(user, "powering down domain...")
		playsound(src, 'sound/machines/terminal_off.ogg', 40, 2)
		reset()
		return

	balloon_alert(user, "notifying clients...")
	playsound(src, 'sound/machines/terminal_alert.ogg', 100, TRUE)
	user.visible_message(
		span_danger("[user] begins depowering the server!"),
		span_notice("You start disconnecting clients..."),
		span_danger("You hear frantic keying on a keyboard."),
	)

	SEND_SIGNAL(src, COMSIG_BITRUNNER_SHUTDOWN_ALERT, user)

	if(!do_after(user, 20 SECONDS, src))
		return

	reset()

/// Handles calculating rewards based on number of players, parts, threats, etc
/obj/machinery/quantum_server/proc/calculate_rewards()
	var/rewards_base = 0.8

	if(domain_randomized)
		rewards_base += 0.2

	rewards_base += servo_bonus

	rewards_base += (domain_threats * 2)

	for(var/index in 2 to length(avatar_connection_refs))
		rewards_base += multiplayer_bonus

	return rewards_base

/**
 * ### Quantum Server Cold Boot
 * Procedurally links the 3 booting processes together.
 *
 * This is the starting point if you have an id. Does validation and feedback on steps
 */
/obj/machinery/quantum_server/proc/cold_boot_map(mob/user, map_key)
	if(!is_ready)
		return FALSE

	if(isnull(map_key))
		balloon_alert(user, "no domain specified.")
		return FALSE

	if(generated_domain)
		balloon_alert(user, "stop the current domain first.")
		return FALSE

	if(length(avatar_connection_refs))
		balloon_alert(user, "all clients must disconnect!")
		return FALSE

	is_ready = FALSE
	playsound(src, 'sound/machines/terminal_processing.ogg', 30, 2)

	if(!initialize_domain(map_key) || !initialize_safehouse() || !initialize_map_items())
		balloon_alert(user, "initialization failed.")
		scrub_vdom()
		is_ready = TRUE
		return FALSE

	is_ready = TRUE
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 30, 2)
	balloon_alert(user, "domain loaded.")
	generated_domain.start_time = world.time
	points -= generated_domain.cost
	update_use_power(ACTIVE_POWER_USE)
	update_appearance()

	return TRUE

/// Resets the cooldown state and updates icons
/obj/machinery/quantum_server/proc/cool_off()
	is_ready = TRUE
	update_appearance()

/// Attempts to connect to a quantum console
/obj/machinery/quantum_server/proc/find_console()
	var/obj/machinery/computer/quantum_console/console = console_ref?.resolve()
	if(console)
		return console

	for(var/direction in GLOB.cardinals)
		var/obj/machinery/computer/quantum_console/nearby_console = locate(/obj/machinery/computer/quantum_console, get_step(src, direction))
		if(nearby_console)
			console_ref = WEAKREF(nearby_console)
			nearby_console.server_ref = WEAKREF(src)
			return nearby_console

/// Generates a new avatar for the bitrunner.
/obj/machinery/quantum_server/proc/generate_avatar(obj/structure/hololadder/wayout, datum/outfit/netsuit)
	var/mob/living/carbon/human/avatar = new(wayout.loc)

	var/outfit_path = generated_domain.forced_outfit || netsuit
	var/datum/outfit/to_wear = new outfit_path()

	to_wear.suit_store = null
	to_wear.belt = /obj/item/bitrunning_host_monitor
	to_wear.glasses = null
	to_wear.suit = null
	to_wear.gloves = null

	avatar.equipOutfit(to_wear, visualsOnly = TRUE)

	var/obj/item/storage/backpack/bag = avatar.back
	if(istype(bag))
		bag.contents += list(
			new /obj/item/storage/box/survival,
			new /obj/item/storage/medkit/regular,
			new /obj/item/flashlight,
		)

	var/obj/item/card/id/outfit_id = avatar.wear_id
	if(outfit_id)
		outfit_id.assignment = "Bit Avatar"
		outfit_id.registered_name = avatar.real_name

		outfit_id.registered_account = new()
		outfit_id.registered_account.replaceable = FALSE

		SSid_access.apply_trim_to_card(outfit_id, /datum/id_trim/bit_avatar)

	return avatar

/// Generates a new hololadder for the bitrunner. Effectively a respawn attempt.
/obj/machinery/quantum_server/proc/generate_hololadder()
	if(!length(exit_turfs))
		return

	if(retries_spent >= length(exit_turfs))
		return

	var/turf/destination
	for(var/turf/dest_turf in exit_turfs)
		if(!locate(/obj/structure/hololadder) in dest_turf)
			destination = dest_turf
			break

	if(isnull(destination))
		return

	var/obj/structure/hololadder/wayout = new(destination)
	if(isnull(wayout))
		return

	retries_spent += 1

	return wayout

/// Generates a reward based on the given domain
/obj/machinery/quantum_server/proc/generate_loot()
	if(!length(receive_turfs) && !locate_receive_turfs())
		return FALSE

	points += generated_domain.reward_points
	playsound(src, 'sound/machines/terminal_success.ogg', 30, 2)

	var/turf/dest_turf = pick(receive_turfs)
	if(isnull(dest_turf))
		stack_trace("Failed to find a turf to spawn loot crate on.")
		return FALSE

	var/bonus = calculate_rewards()

	var/obj/item/paper/certificate = new()
	certificate.add_raw_text(get_completion_certificate())
	certificate.name = "certificate of domain completion"
	certificate.update_appearance()

	var/obj/structure/closet/crate/secure/bitrunning/decrypted/reward_crate = new(dest_turf, generated_domain, bonus)
	reward_crate.manifest = certificate
	reward_crate.update_appearance()

	spark_at_location(reward_crate)
	return TRUE

/// Compiles a list of available domains.
/obj/machinery/quantum_server/proc/get_available_domains()
	var/list/levels = list()

	for(var/datum/lazy_template/virtual_domain/domain as anything in available_domains)
		if(initial(domain.test_only))
			continue
		var/can_view = initial(domain.difficulty) < scanner_tier && initial(domain.cost) <= points + 5
		var/can_view_reward = initial(domain.difficulty) < (scanner_tier + 1) && initial(domain.cost) <= points + 3

		levels += list(list(
			"cost" = initial(domain.cost),
			"desc" = can_view ? initial(domain.desc) : "Limited scanning capabilities. Cannot infer domain details.",
			"difficulty" = initial(domain.difficulty),
			"id" = initial(domain.key),
			"name" = can_view ? initial(domain.name) : REDACTED,
			"reward" = can_view_reward ? initial(domain.reward_points) : REDACTED,
		))

	return levels

/// If there are hosted minds, attempts to get a list of their current virtual bodies w/ vitals
/obj/machinery/quantum_server/proc/get_avatar_data()
	var/list/hosted_avatars = list()

	for(var/datum/weakref/avatar_ref in avatar_connection_refs)
		var/datum/component/avatar_connection/connection = avatar_ref.resolve()
		if(isnull(connection))
			avatar_connection_refs.Remove(connection)
			continue

		var/mob/living/creature = connection.parent
		var/mob/living/pilot = connection.old_body_ref?.resolve()

		hosted_avatars += list(list(
			"health" = creature.health,
			"name" = creature.name,
			"pilot" = pilot,
			"brute" = creature.get_damage_amount(BRUTE),
			"burn" = creature.get_damage_amount(BURN),
			"tox" = creature.get_damage_amount(TOX),
			"oxy" = creature.get_damage_amount(OXY),
		))

	return hosted_avatars

/// Returns the markdown text containing domain completion information
/obj/machinery/quantum_server/proc/get_completion_certificate()
	var/base_points = generated_domain.reward_points
	if(domain_randomized)
		base_points -= 1

	var/bonuses = calculate_rewards()

	var/time_difference = world.time - generated_domain.start_time

	var/completion_time = "### Completion Time: [DisplayTimeText(time_difference)]\n"

	var/grade = "\n---\n\n# Rating: [grade_completion(generated_domain.difficulty, domain_threats, base_points, domain_randomized, time_difference)]"

	var/text = "# Certificate of Domain Completion\n\n---\n\n"

	text += "### [generated_domain.name][domain_randomized ? " (Randomized)" : ""]\n"
	text += "- **Difficulty:** [generated_domain.difficulty]\n"
	text += "- **Threats:** [domain_threats]\n"
	text += "- **Base Points:** [base_points][domain_randomized ? " +1" : ""]\n\n"
	text += "- **Total Bonus:** [bonuses]x\n\n"

	if(bonuses <= 1)
		text += completion_time
		text += grade
		return text

	text += "### Bonuses\n"
	if(domain_randomized)
		text += "- **Randomized:** + 0.2\n"

	if(length(avatar_connection_refs) > 1)
		text += "- **Multiplayer:** + [(length(avatar_connection_refs) - 1) * multiplayer_bonus]\n"

	if(domain_threats > 0)
		text += "- **Threats:** + [domain_threats * 2]\n"

	var/servo_rating = servo_bonus

	if(servo_rating > 0.2)
		text += "- **Components:** + [servo_rating]\n"

	text += completion_time
	text += grade

	return text

/// Gets a random available domain given the current points. Weighted towards higher cost domains.
/obj/machinery/quantum_server/proc/get_random_domain_id()
	if(points < 1)
		return

	var/list/random_domains = list()
	var/total_cost = 0

	for(var/datum/lazy_template/virtual_domain/available as anything in subtypesof(/datum/lazy_template/virtual_domain))
		var/init_cost = initial(available.cost)
		if(!initial(available.test_only) && init_cost > 0 && init_cost < 4 && init_cost <= points)
			random_domains += list(list(
				cost = init_cost,
				id = initial(available.key),
			))

	var/random_value = rand(0, total_cost)
	var/accumulated_cost = 0

	for(var/available as anything in random_domains)
		accumulated_cost += available["cost"]
		if(accumulated_cost >= random_value)
			domain_randomized = TRUE
			return available["id"]

/// Gets all mobs originally generated by the loaded domain and returns a list that are capable of being antagged
/obj/machinery/quantum_server/proc/get_valid_domain_targets()
	// A: No one is playing
	// B: The domain is not loaded
	// C: The domain is shutting down
	// D: There are no mobs
	if(!length(avatar_connection_refs) || isnull(generated_domain) || !is_ready || !is_operational || !length(mutation_candidates))
		return list()

	for(var/mob/living/creature as anything in mutation_candidates)
		if(QDELETED(creature) || creature.mind)
			mutation_candidates.Remove(creature)

	return shuffle(mutation_candidates)

/// Grades the player's run based on several factors
/obj/machinery/quantum_server/proc/grade_completion(difficulty, threats, points, randomized, completion_time)
	var/score = threats * 5
	score += points
	score += randomized ? 1 : 0

	var/base = difficulty + 1
	var/time_score = 1

	if(completion_time <= 1 MINUTES)
		time_score = 10
	else if(completion_time <= 2 MINUTES)
		time_score = 5
	else if(completion_time <= 5 MINUTES)
		time_score = 3
	else if(completion_time <= 10 MINUTES)
		time_score = 2
	else
		time_score = 1

	score += time_score * base

	switch(score)
		if(1 to 4)
			return "D"
		if(5 to 7)
			return "C"
		if(8 to 10)
			return "B"
		if(11 to 13)
			return "A"
		else
			return "S"

/// Initializes a new domain if the given key is valid and the user has enough points
/obj/machinery/quantum_server/proc/initialize_domain(map_key)
	var/datum/lazy_template/virtual_domain/to_load

	for(var/datum/lazy_template/virtual_domain/available as anything in subtypesof(/datum/lazy_template/virtual_domain))
		if(map_key != initial(available.key) || points < initial(available.cost))
			continue
		to_load = available
		break

	if(isnull(to_load))
		return FALSE

	generated_domain = new to_load()
	RegisterSignal(generated_domain, COMSIG_LAZY_TEMPLATE_LOADED, PROC_REF(on_template_loaded))
	generated_domain.lazy_load()

	return TRUE

/// Loads in necessary map items, sets mutation targets, etc
/obj/machinery/quantum_server/proc/initialize_map_items()
	var/turf/goal_turfs = list()
	var/turf/crate_turfs = list()

	for(var/thing in GLOB.landmarks_list)
		if(istype(thing, /obj/effect/landmark/bitrunning/hololadder_spawn))
			exit_turfs += get_turf(thing)
			qdel(thing) // i'm worried about multiple servers getting confused so lets clean em up
			continue

		if(istype(thing, /obj/effect/landmark/bitrunning/cache_goal_turf))
			var/turf/tile = get_turf(thing)
			goal_turfs += tile
			RegisterSignal(tile, COMSIG_ATOM_ENTERED, PROC_REF(on_goal_turf_entered))
			RegisterSignal(tile, COMSIG_ATOM_EXAMINE, PROC_REF(on_goal_turf_examined))
			qdel(thing)
			continue

		if(istype(thing, /obj/effect/landmark/bitrunning/cache_spawn))
			crate_turfs += get_turf(thing)
			qdel(thing)
			continue

	if(!length(exit_turfs))
		CRASH("Failed to find exit turfs on generated domain.")
	if(!length(goal_turfs))
		CRASH("Failed to find send turfs on generated domain.")

	if(length(crate_turfs))
		shuffle_inplace(crate_turfs)
		new /obj/structure/closet/crate/secure/bitrunning/encrypted(pick(crate_turfs))

	return TRUE

/// Loads the safehouse
/obj/machinery/quantum_server/proc/initialize_safehouse()
	var/turf/safehouse_load_turf = list()
	for(var/obj/effect/landmark/bitrunning/safehouse_spawn/spawner in GLOB.landmarks_list)
		safehouse_load_turf += get_turf(spawner)
		qdel(spawner)
		break

	if(!length(safehouse_load_turf))
		CRASH("Failed to find safehouse load landmark on map.")

	var/datum/map_template/safehouse/safehouse = new generated_domain.safehouse_path()
	safehouse.load(safehouse_load_turf[ONLY_TURF])
	generated_safehouse = safehouse

	return TRUE

/// Locates any turfs with crate out landmarks
/obj/machinery/quantum_server/proc/locate_receive_turfs()
	for(var/obj/effect/landmark/bitrunning/station_reward_spawn/spawner in GLOB.landmarks_list)
		if(IN_GIVEN_RANGE(src, spawner, MAX_DISTANCE))
			receive_turfs += get_turf(spawner)
			qdel(spawner)

	return length(receive_turfs) > 0

/// Finds any mobs with minds in the zones and gives them the bad news
/obj/machinery/quantum_server/proc/notify_spawned_threats()
	for(var/mob/living/baddie as anything in spawned_threats)
		if(QDELETED(baddie) || baddie.stat >= UNCONSCIOUS || isnull(baddie.mind))
			continue

		baddie.throw_alert(
			ALERT_BITRUNNER_RESET,
			/atom/movable/screen/alert/bitrunning/qserver_threat_deletion,
			new_master = src,
		)

		to_chat(baddie, span_userdanger("You have been flagged for deletion! Thank you for your service."))

/// If broken via signal, disconnects all users
/obj/machinery/quantum_server/proc/on_broken(datum/source)
	SIGNAL_HANDLER

	if(isnull(generated_domain))
		return

	SEND_SIGNAL(src, COMSIG_BITRUNNER_SEVER_AVATAR)

/// Someone connected via netpod
/obj/machinery/quantum_server/proc/on_client_connected(datum/source)
	SIGNAL_HANDLER

	avatar_connection_refs.Add(WEAKREF(source))

/// Someone disconnected
/obj/machinery/quantum_server/proc/on_client_disconnected(datum/source)
	SIGNAL_HANDLER

	avatar_connection_refs.Remove(WEAKREF(source))

/// Being qdeleted - make sure the circuit and connected mobs go with it
/obj/machinery/quantum_server/proc/on_delete(datum/source)
	SIGNAL_HANDLER

	if(generated_domain)
		SEND_SIGNAL(src, COMSIG_BITRUNNER_SEVER_AVATAR)
		scrub_vdom()

	if(is_ready)
		return
	// in case they're trying to cheese cooldown
	var/obj/item/circuitboard/machine/quantum_server/circuit = locate(/obj/item/circuitboard/machine/quantum_server) in contents
	if(circuit)
		qdel(circuit)

/// Handles examining the server. Shows cooldown time and efficiency.
/obj/machinery/quantum_server/proc/on_examine(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	if(capacitor_coefficient < 1)
		examine_text += span_infoplain("Its coolant capacity reduces cooldown time by [(1 - capacitor_coefficient) * 100]%.")

	if(servo_bonus > 0.2)
		examine_text += span_infoplain("Its manipulation potential is increasing rewards by [servo_bonus]x.")
		examine_text += span_infoplain("Injury from unsafe ejection reduced [servo_bonus * 100]%.")

	if(!is_ready)
		examine_text += span_notice("It is currently cooling down. Give it a few moments.")
		return

/// Whenever something enters the send tiles, check if it's a loot crate. If so, alert players.
/obj/machinery/quantum_server/proc/on_goal_turf_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!istype(arrived, /obj/structure/closet/crate/secure/bitrunning/encrypted))
		return

	var/obj/structure/closet/crate/secure/bitrunning/encrypted/loot_crate = arrived
	if(!istype(loot_crate))
		return

	for(var/mob/person in loot_crate.contents)
		if(isnull(person.mind))
			person.forceMove(get_turf(loot_crate))

		var/datum/component/avatar_connection/connection = person.GetComponent(/datum/component/avatar_connection)
		connection?.full_avatar_disconnect()

	spark_at_location(loot_crate)
	qdel(loot_crate)
	SEND_SIGNAL(src, COMSIG_BITRUNNER_DOMAIN_COMPLETE, arrived, generated_domain.reward_points)
	generate_loot()

/// Handles examining the server. Shows cooldown time and efficiency.
/obj/machinery/quantum_server/proc/on_goal_turf_examined(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	examine_text += span_info("Beneath your gaze, the floor pulses subtly with streams of encoded data.")
	examine_text += span_info("It seems to be part of the location designated for retrieving encrypted payloads.")

/// Scans over the inbound created_atoms from lazy templates
/obj/machinery/quantum_server/proc/on_template_loaded(datum/lazy_template/source, list/created_atoms)
	SIGNAL_HANDLER

	for(var/thing in created_atoms)
		if(isliving(thing)) // so we can mutate them
			var/mob/living/creature = thing

			if(creature.can_be_cybercop)
				mutation_candidates += creature
			continue

		if(istype(thing, /obj/effect/mob_spawn/ghost_role)) // so we get threat alerts
			RegisterSignal(thing, COMSIG_GHOSTROLE_SPAWNED, PROC_REF(on_threat_created))
			continue

		if(istype(thing, /obj/effect/mob_spawn/corpse)) // corpses are valid targets too
			var/obj/effect/mob_spawn/corpse/spawner = thing
			var/mob/living/creature = spawner.mob_ref?.resolve()

			if(!creature?.can_be_cybercop)
				continue

			mutation_candidates += creature
			qdel(spawner)

	UnregisterSignal(source, COMSIG_LAZY_TEMPLATE_LOADED)

/// Handles when cybercops are summoned into the area or ghosts click a ghost role spawner
/obj/machinery/quantum_server/proc/on_threat_created(datum/source, mob/living/threat)
	SIGNAL_HANDLER

	domain_threats += 1
	spawned_threats += threat
	SEND_SIGNAL(src, COMSIG_BITRUNNER_THREAT_CREATED) // notify players

/// Stops the current virtual domain and disconnects all users
/obj/machinery/quantum_server/proc/reset(fast = FALSE)
	is_ready = FALSE

	SEND_SIGNAL(src, COMSIG_BITRUNNER_SEVER_AVATAR)

	if(!fast)
		notify_spawned_threats()
		addtimer(CALLBACK(src, PROC_REF(scrub_vdom)), 15 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)
	else
		scrub_vdom() // used in unit testing, no need to wait for callbacks

	addtimer(CALLBACK(src, PROC_REF(cool_off)), min(server_cooldown_time * capacitor_coefficient), TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_DELETE_ME)
	update_appearance()

	update_use_power(IDLE_POWER_USE)
	domain_randomized = FALSE
	domain_threats = 0
	retries_spent = 0

/// Deletes all the tile contents
/obj/machinery/quantum_server/proc/scrub_vdom()
	SEND_SIGNAL(src, COMSIG_BITRUNNER_SEVER_AVATAR) // just in case

	if(length(generated_domain.reservations))
		var/datum/turf_reservation/res = generated_domain.reservations[1]
		res.Release()

	var/list/mob/living/creatures = spawned_threats + mutation_candidates
	for(var/mob/living/creature as anything in creatures)
		if(QDELETED(creature))
			continue

		creature.dust() // sometimes mobs just don't die

	exit_turfs = list()
	generated_domain = null
	generated_safehouse = null
	mutation_candidates.Cut()
	spawned_threats.Cut()

/// Do some magic teleport sparks
/obj/machinery/quantum_server/proc/spark_at_location(obj/crate)
	playsound(crate, 'sound/magic/blink.ogg', 50, TRUE)
	var/datum/effect_system/spark_spread/quantum/sparks = new()
	sparks.set_up(5, 1, get_turf(crate))
	sparks.start()

#undef ONLY_TURF
#undef REDACTED
#undef MAX_DISTANCE
#undef COMSIG_LAZY_TEMPLATE_LOADED
