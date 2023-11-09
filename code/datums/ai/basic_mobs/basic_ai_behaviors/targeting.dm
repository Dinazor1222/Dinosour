/// List of objects that AIs will treat as targets
GLOBAL_LIST_EMPTY_TYPED(hostile_machines, /atom)

/datum/ai_behavior/find_potential_targets
	action_cooldown = 2 SECONDS
	/// How far can we see stuff?
	var/vision_range = 9
	/// Blackboard key for aggro range, uses vision range if not specified
	var/aggro_range_key = BB_AGGRO_RANGE

/datum/ai_behavior/find_potential_targets/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	var/mob/living/living_mob = controller.pawn
	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])

	if(!targeting_strategy)
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")

	var/atom/current_target = controller.blackboard[target_key]
	if (targeting_strategy.can_attack(living_mob, current_target, vision_range))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/aggro_range = controller.blackboard[aggro_range_key] || vision_range

	controller.clear_blackboard_key(target_key)

	var/list/potential_targets = hearers(aggro_range, get_turf(controller.pawn)) - living_mob //Remove self, so we don't suicide

	for (var/atom/hostile_machine as anything in GLOB.hostile_machines)
		if (can_see(living_mob, hostile_machine, aggro_range))
			potential_targets += hostile_machine

	if(!potential_targets.len)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/list/filtered_targets = list()

	for(var/atom/pot_target in potential_targets)
		if(targeting_strategy.can_attack(living_mob, pot_target))//Can we attack it?
			filtered_targets += pot_target
			continue

	if(!filtered_targets.len)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/atom/target = pick_final_target(controller, filtered_targets)
	controller.set_blackboard_key(target_key, target)

	var/atom/potential_hiding_location = targeting_strategy.find_hidden_mobs(living_mob, target)

	if(potential_hiding_location) //If they're hiding inside of something, we need to know so we can go for that instead initially.
		controller.set_blackboard_key(hiding_location_key, potential_hiding_location)

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/find_potential_targets/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	if (succeeded)
		controller.CancelActions() // On retarget cancel any further queued actions so that they will setup again with new target

/// Returns the desired final target from the filtered list of targets
/datum/ai_behavior/find_potential_targets/proc/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	return pick(filtered_targets)
