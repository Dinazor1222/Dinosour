#define MAX_ARTIFACT_ROLL_CHANCE 10
#define MINERAL_TYPE_OPTIONS_RANDOM 4
#define OVERLAY_OFFSET_START 0
#define OVERLAY_OFFSET_EACH 5
#define LARGE_VENT_TYPE "large"
#define MEDIUM_VENT_TYPE "medium"
#define SMALL_VENT_TYPE "small"

/obj/structure/ore_vent
	name = "ore vent"
	desc = "An ore vent, brimming with underground ore. Scan with an advanced mining scanner to start extracting ore from it."
	icon = 'icons/obj/mining_zones/terrain.dmi'
	icon_state = "ore_vent"
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF //This thing will take a beating.
	anchored = TRUE
	density = TRUE
	can_buckle = TRUE

	/// Has this vent been tapped to produce boulders? Cannot be untapped.
	var/tapped = FALSE
	/// Has this vent been scanned by a mining scanner? Cannot be scanned again. Adds ores to the vent's description.
	var/discovered = FALSE
	/// Is this type of vent exempt from the 15 vent limit? Think the free iron/glass vent or boss vents. This also causes it to not roll for random mineral breakdown.
	var/unique_vent = FALSE
	/// What icon_state do we use when the ore vent has been tapped?
	var/icon_state_tapped = "ore_vent_active"

	/// A weighted list of what minerals are contained in this vent, with weight determining how likely each mineral is to be picked in produced boulders.
	var/list/mineral_breakdown = list()
	/// How many rolls on the mineral_breakdown list are made per boulder produced? EG: 3 rolls means 3 minerals per boulder, with order determining percentage.
	var/minerals_per_boulder = 3
	/// How many minerals are picked to be in the ore vent? These are added to the mineral_breakdown list.
	var/minerals_per_breakdown = MINERAL_TYPE_OPTIONS_RANDOM
	/// What size boulders does this vent produce?
	var/boulder_size = BOULDER_SIZE_SMALL
	/// Reference to this ore vent's NODE drone, to track wave success.
	var/mob/living/basic/node_drone/node = null //this path is a placeholder.
	/// String of ores that this vent can produce.
	var/ore_string = ""
	/// Associated list of vent size weights to pick from.
	var/list/ore_vent_options = list(
		LARGE_VENT_TYPE,
		MEDIUM_VENT_TYPE,
		SMALL_VENT_TYPE,
	)

	/// What string do we use to warn the player about the excavation event?
	var/excavation_warning = "Are you ready to excavate this ore vent?"
	///Are we currently spawning mobs?
	var/spawning_mobs = FALSE
		/// A list of mobs that can be spawned by this vent during a wave defense event.
	var/list/defending_mobs = list(
		/mob/living/basic/mining/goliath,
		/mob/living/basic/mining/legion/spawner_made,
		/mob/living/basic/mining/watcher,
		/mob/living/basic/mining/lobstrosity/lava,
		/mob/living/basic/mining/brimdemon,
		/mob/living/basic/mining/bileworm,
	)
	///What items can be used to scan a vent?
	var/static/list/scanning_equipment = list(
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/mining_scanner,
	)

	/// What base icon_state do we use for this vent's boulders?
	var/boulder_icon_state = "boulder"
	/// Percent chance that this vent will produce an artifact boulder.
	var/artifact_chance = 0
	/// We use a cooldown to prevent the wave defense from being started multiple times.
	COOLDOWN_DECLARE(wave_cooldown)


/obj/structure/ore_vent/Initialize(mapload)
	generate_description()
	register_context()
	SSore_generation.possible_vents += src
	boulder_icon_state = pick(list(
		"boulder",
		"rock",
		"stone",
	))
	if(tapped)
		SSore_generation.processed_vents += src
		icon_state = icon_state_tapped
		update_appearance(UPDATE_ICON_STATE)
		add_overlay(mutable_appearance('icons/obj/mining_zones/terrain.dmi', "well", ABOVE_MOB_LAYER, src, ABOVE_MOB_LAYER))
	return ..()

/obj/structure/ore_vent/Destroy()
	SSore_generation.possible_vents -= src
	node = null
	if(tapped)
		SSore_generation.processed_vents -= src
	return ..()

/obj/structure/ore_vent/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(.)
		return
	if(!is_type_in_list(attacking_item, scanning_equipment))
		return
	if(tapped)
		balloon_alert_to_viewers("vent tapped!")
		return TRUE
	scan_and_confirm(user)
	return TRUE

/obj/structure/ore_vent/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!isgolem(user))
		return
	if(!discovered)
		to_chat(user, span_notice("You can't quite find the weakpoint of [src]... Perhaps it needs to be scanned first?"))
		return TRUE
	to_chat(user, span_notice("You start striking [src] with your golem's fist, attempting to dredge up a boulder..."))
	for(var/i in 1 to 3)
		if(do_after(user, boulder_size * 1 SECONDS, src))
			user.apply_damage(20, STAMINA)
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
	produce_boulder()
	visible_message(span_notice("You've successfully produced a boulder! Boy are your arms tired."))
	return TRUE

/obj/structure/ore_vent/is_buckle_possible(mob/living/target, force, check_loc)
	. = ..()
	if(tapped)
		return FALSE
	if(istype(target, /mob/living/basic/node_drone))
		return TRUE

/obj/structure/ore_vent/examine(mob/user)
	. = ..()
	if(discovered)
		switch(boulder_size)
			if(BOULDER_SIZE_SMALL)
				. += span_notice("This vent produces [span_bold("small")] boulders containing [ore_string]")
			if(BOULDER_SIZE_MEDIUM)
				. += span_notice("This vent produces [span_bold("medium")] boulders containing [ore_string]")
			if(BOULDER_SIZE_LARGE)
				. += span_notice("This vent produces [span_bold("large")] boulders containing [ore_string]")
	else
		. += span_notice("This vent can be scanned with a [span_bold("Mining Scanner")].")

/obj/structure/ore_vent/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(is_type_in_list(held_item, scanning_equipment))
		context[SCREENTIP_CONTEXT_LMB] = "Scan vent"
		return CONTEXTUAL_SCREENTIP_SET

/**
 * Picks n types materials to pack into a boulder created by this ore vent, where n is this vent's minerals_per_boulder.
 * Then assigns custom_materials based on boulder_size, assigned via the ore_quantity_function
 */
/obj/structure/ore_vent/proc/create_mineral_contents()
	var/list/refined_list = list()
	for(var/iteration in 1 to minerals_per_boulder)
		var/datum/material/material = pick_weight(mineral_breakdown)
		refined_list[material] += ore_quantity_function(iteration)
	return refined_list

/obj/structure/ore_vent/proc/generate_mineral_breakdown(max_minerals = MINERAL_TYPE_OPTIONS_RANDOM, map_loading = FALSE)
	var/iterator = 1
	if(max_minerals < 1)
		CRASH("generate_mineral_breakdown called with max_minerals < 1.")
	while(iterator <= max_minerals)
		if(!SSore_generation.ore_vent_minerals.len && map_loading)
			CRASH("No minerals left to pick from! We may have spawned too many ore vents in init, or added too many ores to the existing vents.")
		var/datum/material/material
		if(map_loading)
			material = pick_weight(SSore_generation.ore_vent_minerals)
		if(is_type_in_list(mineral_breakdown, material))
			continue

		if(map_loading)
			SSore_generation.ore_vent_minerals[material] -= 1 //We remove 1 from the ore vent's mineral breakdown weight, so that it can't be picked again.
			if(SSore_generation.ore_vent_minerals[material] <= 0)
				SSore_generation.ore_vent_minerals -= material
		mineral_breakdown[material] = rand(1, 4)
		iterator++


/**
 * Returns the quantity of mineral sheets in each ore's boulder contents roll. First roll can produce the most ore, with subsequent rolls scaling lower logarithmically.
 */
/obj/structure/ore_vent/proc/ore_quantity_function(ore_floor)
	return SHEET_MATERIAL_AMOUNT * round(boulder_size * (log(rand(1 + ore_floor, 4 + ore_floor)) ** -1))

/**
 * Starts the wave defense event, which will spawn a number of lavaland mobs based on the size of the ore vent.
 * Called after the vent has been tapped by a scanning device.
 * Will summon a number of waves of mobs, ending in the vent being tapped after the final wave.
 */
/obj/structure/ore_vent/proc/start_wave_defense()
	AddComponent(\
		/datum/component/spawner, \
		spawn_types = defending_mobs, \
		spawn_time = (10 SECONDS + (5 SECONDS * (boulder_size/5))), \
		max_spawned = 10, \
		max_spawn_per_attempt = (1 + (boulder_size/5)), \
		spawn_text = "emerges to assault", \
		spawn_distance = 4, \
		spawn_distance_exclude = 3, \
	)
	var/wave_timer = 60 SECONDS
	if(boulder_size == BOULDER_SIZE_MEDIUM)
		wave_timer = 90 SECONDS
	else if(boulder_size == BOULDER_SIZE_LARGE)
		wave_timer = 150 SECONDS
	COOLDOWN_START(src, wave_cooldown, wave_timer)
	addtimer(CALLBACK(src, PROC_REF(handle_wave_conclusion)), wave_timer)
	spawning_mobs = TRUE
	icon_state = icon_state_tapped
	update_appearance(UPDATE_ICON_STATE)

/**
 * Called when the wave defense event ends, after a variable amount of time in start_wave_defense.
 *
 * If the node drone is still alive, the ore vent is tapped and the ore vent will begin generating boulders.
 * If the node drone is dead, the ore vent is not tapped and the wave defense can be reattempted.
 *
 * Also gives xp and mining points to all nearby miners in equal measure.
 */
/obj/structure/ore_vent/proc/handle_wave_conclusion()
	SEND_SIGNAL(src, COMSIG_VENT_WAVE_CONCLUDED)
	COOLDOWN_RESET(src, wave_cooldown)
	particles = null
	if(!QDELETED(node)) ///The Node Drone has survived the wave defense, and the ore vent is tapped.
		tapped = TRUE
		SSore_generation.processed_vents += src
		balloon_alert_to_viewers("vent tapped!")
	else
		visible_message(span_danger("\the [src] creaks and groans as the mining attempt fails, and the vent closes back up."))
		icon_state = initial(icon_state)
		update_appearance(UPDATE_ICON_STATE)
		return FALSE //Bad end, try again.

	for(var/mob/living/carbon/human/potential_miner in range(7, src)) //Give the miners who are near the vent points and xp.
		var/mob/living/carbon/human/true_miner = potential_miner
		var/obj/item/card/id/user_id_card = true_miner.get_idcard(TRUE)
		if(true_miner?.mind)
			true_miner.mind.adjust_experience(/datum/skill/mining, MINING_SKILL_BOULDER_SIZE_XP * boulder_size)
		if(!user_id_card)
			continue
		var/point_reward_val = (MINER_POINT_MULTIPLIER * boulder_size) - MINER_POINT_MULTIPLIER // We remove the base value of discovering the vent
		user_id_card.registered_account.mining_points += point_reward_val
		user_id_card.registered_account.bank_card_talk("You have been awarded [point_reward_val] mining points for your efforts.")
	node.pre_escape() //Visually show the drone is done and flies away.
	add_overlay(mutable_appearance('icons/obj/mining_zones/terrain.dmi', "well", ABOVE_MOB_LAYER, src, GAME_PLANE))

/**
 * Called when the ore vent is tapped by a scanning device.
 * Gives a readout of the ores available in the vent that gets added to the description, then asks the user if they want to start wave defense.
 */
/obj/structure/ore_vent/proc/scan_and_confirm(mob/user, scan_only = FALSE)
	if(tapped)
		balloon_alert_to_viewers("vent tapped!")
		return
	if(!COOLDOWN_FINISHED(src, wave_cooldown))
		balloon_alert_to_viewers("protect the node drone!")
		return
	if(!discovered)
		balloon_alert(user, "scanning...")
		playsound(src, 'sound/items/timer.ogg', 30, TRUE)
		if(scan_only)
			discovered = TRUE
		if(!discovered)
			if(do_after(user, 4 SECONDS))
				discovered = TRUE
				balloon_alert(user, "vent scanned!")
			generate_description(user)
			if(!ishuman(user))
				return
			var/mob/living/carbon/human/scanning_miner = user
			var/obj/item/card/id/user_id_card = scanning_miner.get_idcard(TRUE)
			if(isnull(user_id_card))
				return
			user_id_card.registered_account.mining_points += (MINER_POINT_MULTIPLIER)
			user_id_card.registered_account.bank_card_talk("You've been awarded [MINER_POINT_MULTIPLIER] mining points for discovery of an ore vent.")
			return
	if(scan_only)
		return

	if(tgui_alert(user, excavation_warning, "Begin defending ore vent?", list("Yes", "No")) != "Yes")
		return
	if(!COOLDOWN_FINISHED(src, wave_cooldown))
		return
	//This is where we start spitting out mobs.
	Shake(duration = 3 SECONDS)
	node = new /mob/living/basic/node_drone(loc)
	node.arrive(src)
	RegisterSignal(node, COMSIG_QDELETING, PROC_REF(handle_wave_conclusion))
	particles = new /particles/smoke/ash()

	for(var/i in 1 to 5) // Clears the surroundings of the ore vent before starting wave defense.
		for(var/turf/closed/mineral/rock in oview(i))
			if(istype(rock, /turf/open/misc/asteroid) && prob(35)) // so it's too common
				new /obj/effect/decal/cleanable/rubble(rock)
			if(prob(100 - (i * 15)))
				rock.gets_drilled(user, FALSE)
				if(prob(50))
					new /obj/effect/decal/cleanable/rubble(rock)
		sleep(0.6 SECONDS)

	start_wave_defense()

/**
 * Generates a description of the ore vent to ore_string, based on the minerals contained within it.
 * Ore_string is passed to examine().
 */
/obj/structure/ore_vent/proc/generate_description(mob/user)
	for(var/mineral_count in 1 to mineral_breakdown.len)
		var/datum/material/resource = mineral_breakdown[mineral_count]
		if(mineral_count == mineral_breakdown.len)
			ore_string += "and " + span_bold(initial(resource.name)) + "."
		else
			ore_string += span_bold(initial(resource.name)) + ", "
	if(user)
		ore_string += "\nThis vent was first discovered by [user]."
/**
 * Adds floating temp_visual overlays to the vent, showcasing what minerals are contained within it.
 * If undiscovered, adds a single overlay with the icon_state "unknown".
 */
/obj/structure/ore_vent/proc/add_mineral_overlays()
	if(mineral_breakdown.len && !discovered)
		var/obj/effect/temp_visual/mining_overlay/vent/new_mat = new /obj/effect/temp_visual/mining_overlay/vent(drop_location())
		new_mat.icon_state = "unknown"
		return
	for(var/datum/material/selected_mat as anything in mineral_breakdown)
		var/obj/effect/temp_visual/mining_overlay/vent/new_mat = new /obj/effect/temp_visual/mining_overlay/vent(drop_location())
		new_mat.icon_state = selected_mat.name

/**
 * Here is where we handle producing a new boulder, based on the qualities of this ore vent.
 * Returns the boulder produced.
 */
/obj/structure/ore_vent/proc/produce_boulder()
	var/obj/item/boulder/new_rock
	if(prob(artifact_chance))
		new_rock = new /obj/item/boulder/artifact(loc)
	else
		new_rock = new (loc)
	var/list/mats_list = create_mineral_contents()
	Shake(duration = 1.5 SECONDS)
	new_rock.set_custom_materials(mats_list)
	new_rock.flavor_boulder(src)
	return new_rock


//comes with the station, and is already tapped.
/obj/structure/ore_vent/starter_resources
	name = "active ore vent"
	desc = "An ore vent, brimming with underground ore. It's already supplying the station with iron and glass."
	tapped = TRUE
	discovered = TRUE
	unique_vent = TRUE
	boulder_size = BOULDER_SIZE_SMALL
	mineral_breakdown = list(
		/datum/material/iron = 50,
		/datum/material/glass = 50,
	)

/obj/structure/ore_vent/random
	/// Static list of ore vent types, for random generation.
	var/static/list/ore_vent_types = list(
		BOULDER_SIZE_SMALL,
		BOULDER_SIZE_MEDIUM,
		BOULDER_SIZE_LARGE,
	)

/obj/structure/ore_vent/random/Initialize(mapload)
	. = ..()
	if(!unique_vent && !mapload)
		generate_mineral_breakdown(map_loading = mapload) //Default to random mineral breakdowns, unless this is a unique vent or we're still setting up default vent distribution.
	artifact_chance = rand(0, MAX_ARTIFACT_ROLL_CHANCE)
	var/string_boulder_size = pick_weight(ore_vent_options)
	name = "[string_boulder_size] ore vent"
	switch(string_boulder_size)
		if("large")
			boulder_size = BOULDER_SIZE_LARGE
			SSore_generation.ore_vent_sizes["large"] -= 1
		if("medium")
			boulder_size = BOULDER_SIZE_MEDIUM
			SSore_generation.ore_vent_sizes["medium"] -= 1
		if("small")
			boulder_size = BOULDER_SIZE_SMALL
			SSore_generation.ore_vent_sizes["small"] -= 1
		else
			boulder_size = BOULDER_SIZE_SMALL //Might as well set a default value
			name = initial(name)



/obj/structure/ore_vent/random/icebox //The one that shows up on the top level of icebox
	icon_state = "ore_vent_ice"
	icon_state_tapped = "ore_vent_ice_active"
	defending_mobs = list(
		/mob/living/basic/mining/lobstrosity,
		/mob/living/basic/mining/legion/snow/spawner_made,
		/mob/living/simple_animal/hostile/asteroid/polarbear,
		/mob/living/simple_animal/hostile/asteroid/wolf,
	)
	ore_vent_options = list(
		"small",
	)

/obj/structure/ore_vent/random/icebox/lower
	defending_mobs = list(
		/mob/living/basic/mining/ice_whelp,
		/mob/living/basic/mining/lobstrosity,
		/mob/living/basic/mining/legion/snow/spawner_made,
		/mob/living/basic/mining/ice_demon,
		/mob/living/simple_animal/hostile/asteroid/polarbear,
		/mob/living/simple_animal/hostile/asteroid/wolf,
	)
	ore_vent_options = list(
		"small",
		"medium",
		"large",
	)


/obj/structure/ore_vent/boss
	name = "menacing ore vent"
	desc = "An ore vent, brimming with underground ore. This one has an evil aura about it. Better be careful."
	unique_vent = TRUE
	boulder_size = BOULDER_SIZE_LARGE
	mineral_breakdown = list( // All the riches of the world, eeny meeny boulder room.
		/datum/material/iron = 1,
		/datum/material/glass = 1,
		/datum/material/plasma = 1,
		/datum/material/titanium = 1,
		/datum/material/silver = 1,
		/datum/material/gold = 1,
		/datum/material/diamond = 1,
		/datum/material/uranium = 1,
		/datum/material/bluespace = 1,
		/datum/material/plastic = 1,
	)
	defending_mobs = list(
		/mob/living/simple_animal/hostile/megafauna/bubblegum,
		/mob/living/simple_animal/hostile/megafauna/dragon,
		/mob/living/simple_animal/hostile/megafauna/colossus,
	)
	excavation_warning = "Something big is nearby. Are you ABSOLUTELY ready to excavate this ore vent?"
	///What boss do we want to spawn?
	var/summoned_boss = null

/obj/structure/ore_vent/boss/Initialize(mapload)
	. = ..()
	summoned_boss = pick(defending_mobs)

/obj/structure/ore_vent/boss/examine(mob/user)
	. = ..()
	var/boss_string = ""
	switch(summoned_boss)
		if(/mob/living/simple_animal/hostile/megafauna/bubblegum)
			boss_string = "A giant fleshbound beast"
		if(/mob/living/simple_animal/hostile/megafauna/dragon)
			boss_string = "Sharp teeth and scales"
		if(/mob/living/simple_animal/hostile/megafauna/colossus)
			boss_string = "A giant, armored behemoth"
		if(/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner)
			boss_string = "A bloody drillmark"
		if(/mob/living/simple_animal/hostile/megafauna/wendigo)
			boss_string = "A chilling skull"
	. += span_notice("[boss_string] is etched onto the side of the vent.")

/obj/structure/ore_vent/boss/start_wave_defense()
	// Completely override the normal wave defense, and just spawn the boss.
	var/mob/living/simple_animal/hostile/megafauna/boss = new summoned_boss(loc)
	RegisterSignal(boss, COMSIG_LIVING_DEATH, PROC_REF(handle_wave_conclusion))
	COOLDOWN_START(src, wave_cooldown, INFINITY) //Basically forever
	boss.say(boss.summon_line) //Pull their specific summon line to say. Default is meme text so make sure that they have theirs set already.

/obj/structure/ore_vent/boss/handle_wave_conclusion()
	node = new /mob/living/basic/node_drone(loc) //We're spawning the vent after the boss dies, so the player can just focus on the boss.
	COOLDOWN_RESET(src, wave_cooldown)
	return ..()

/obj/structure/ore_vent/boss/icebox
	icon_state = "ore_vent_ice"
	icon_state_tapped = "ore_vent_ice_active"
	defending_mobs = list(
		/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner,
		/mob/living/simple_animal/hostile/megafauna/wendigo,
		/mob/living/simple_animal/hostile/megafauna/colossus,
	)

#undef MAX_ARTIFACT_ROLL_CHANCE
#undef MINERAL_TYPE_OPTIONS_RANDOM
#undef OVERLAY_OFFSET_START
#undef OVERLAY_OFFSET_EACH
#undef LARGE_VENT_TYPE
#undef MEDIUM_VENT_TYPE
#undef SMALL_VENT_TYPE
