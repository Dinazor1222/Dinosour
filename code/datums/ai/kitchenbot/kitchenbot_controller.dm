/datum/ai_controller/kitchenbot
	ai_movement = /datum/ai_movement/basic_avoidance
	movement_delay = 0.3 SECONDS
	blackboard = list(
	BB_KITCHENBOT_MODE = KITCHENBOT_MODE_REFUSE,
	//BB_KITCHENBOT_MODE = KITCHENBOT_MODE_OFF,
	BB_KITCHENBOT_CHOSEN_DISPOSALS = null,
	BB_KITCHENBOT_TARGET_TO_DISPOSE = null,
	BB_KITCHENBOT_CHOSEN_GRIDDLE = null,
	BB_KITCHENBOT_CHOSEN_STOCKPILE = null,
	BB_KITCHENBOT_ITEMS_WATCHED = list(),
	BB_KITCHENBOT_ITEMS_BANNED = list(),
	BB_KITCHENBOT_TAKE_OFF_GRILL = list(),
	BB_KITCHENBOT_TARGET_TO_GRILL = null
	)


/datum/ai_controller/kitchenbot/TryPossessPawn(atom/new_pawn)
	if(!istype(new_pawn, /mob/living/simple_animal/bot/kitchenbot))
		return AI_CONTROLLER_INCOMPATIBLE
	return ..() //Run parent at end

/datum/ai_controller/kitchenbot/SelectBehaviors(delta_time)
	current_behaviors = list()
	switch(blackboard[BB_KITCHENBOT_MODE])
		if(KITCHENBOT_MODE_IDLE)//off, or on but no mode
			return
		if(KITCHENBOT_MODE_REFUSE)//handle refuse
			var/obj/chosen_disposals = blackboard[BB_KITCHENBOT_CHOSEN_DISPOSALS]
			var/obj/target_refuse = blackboard[BB_KITCHENBOT_TARGET_TO_DISPOSE]
			if(!chosen_disposals)
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/find_disposals)
				return
			if(!target_refuse)
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/find_refuse)
				return
			if(!(target_refuse in pawn.contents))
				//not holding plate, should be where we're going now
				current_movement_target = target_refuse
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/grab_refuse)
				return
			//holding plate, knows a disposals to dump it. get to work
			current_movement_target = chosen_disposals
			current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/dump_refuse)
		if(KITCHENBOT_MODE_THE_GRIDDLER)
			var/obj/machinery/griddle/griddle = blackboard[BB_KITCHENBOT_CHOSEN_GRIDDLE]
			var/obj/stockpile = blackboard[BB_KITCHENBOT_CHOSEN_STOCKPILE]
			var/list/take_off_grill = blackboard[BB_KITCHENBOT_TAKE_OFF_GRILL]
			if(!griddle)
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/find_griddle)
				return
			if(!stockpile)
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/find_stockpile)
				return
			if(take_off_grill.len)
				current_movement_target = griddle
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/take_off_grill)
				return
			if(griddle.griddled_objects.len >= griddle.max_items)
				return
			if(blackboard[BB_KITCHENBOT_TARGET_TO_GRILL])
				current_movement_target = griddle
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/put_on_grill)
				return
			var/list/should_griddle = list()
			var/turf/stockpile_turf = get_turf(stockpile)
			for(var/obj/item/grillable in stockpile_turf.contents)
				var/list/banned_items = blackboard[BB_KITCHENBOT_ITEMS_BANNED]
				if(grillable in banned_items)
					continue
				var/datum/component/grillable/grill_comp = grillable.GetComponent(/datum/component/grillable)
				if(!grill_comp || !grill_comp.positive_result)//bad, don't grill this
					banned_items += grillable
					continue
				should_griddle += grillable
			if(!should_griddle.len)
				return
			current_movement_target = pick_n_take(should_griddle)
			current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/grab_griddlable)
		if(KITCHENBOT_MODE_WAITER)
			return
		else
			stack_trace("Kitchenbot is in a mode it doesn't have!")

/datum/ai_controller/kitchenbot/proc/GrillCompleted(obj/item/source, atom/grilled_result)
	SIGNAL_HANDLER
	blackboard[BB_KITCHENBOT_TAKE_OFF_GRILL] += grilled_result

/datum/ai_controller/kitchenbot/proc/clear_signals()
	var/list/items_watched = blackboard[BB_KITCHENBOT_ITEMS_WATCHED]
	for(var/unregister_from in items_watched)
		UnregisterSignal(unregister_from, COMSIG_GRILL_COMPLETED)
	UnregisterSignal(pawn, list(COMSIG_PARENT_ATTACKBY))

/datum/ai_controller/kitchenbot/proc/change_mode(new_mode)
	var/mob/living/simple_animal/bot/kitchenbot/kitchenbot = pawn
	if(!kitchenbot.on)
		return //no mode switching while off
	clear_signals()
	blackboard[BB_KITCHENBOT_MODE] = new_mode
	switch(blackboard[BB_KITCHENBOT_MODE])
		if(KITCHENBOT_MODE_THE_GRIDDLER)
			RegisterSignal(kitchenbot, COMSIG_PARENT_ATTACKBY, .proc/point_in_the_right_direction)

/datum/ai_controller/kitchenbot/proc/point_in_the_right_direction(datum/source, obj/item/grillable, mob/user)
	SIGNAL_HANDLER

	var/mob/living/simple_animal/bot/kitchenbot/kitchenbot = pawn
	var/obj/machinery/griddle/chosen_griddle = blackboard[BB_KITCHENBOT_CHOSEN_GRIDDLE]
	var/obj/stockpile = blackboard[BB_KITCHENBOT_CHOSEN_STOCKPILE]
	if(!chosen_griddle)//no griddle
		to_chat(user, "<span class='warning'>[pawn] shrugs. It hasn't found a grill to man!</span>")
		playsound(src, 'sound/machines/buzz-two.ogg', 50, FALSE)
		return COMPONENT_NO_AFTERATTACK
	if(chosen_griddle.griddled_objects.len >= chosen_griddle.max_items)//too many things
		to_chat(user, "<span class='warning'>[pawn] shrugs. It needs a holo-projected stockpile to take griddlable food from!</span>")
		playsound(src, 'sound/machines/buzz-two.ogg', 50, FALSE)
		return COMPONENT_NO_AFTERATTACK
	to_chat(user, "<span class='warning'>[pawn] points to the food stockpile. If you add food to the stockpile, it will griddle it!</span>")
	playsound(kitchenbot, 'sound/machines/chime.ogg', 50, FALSE)
	kitchenbot.point_at(stockpile)

	return COMPONENT_NO_AFTERATTACK

