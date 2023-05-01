//When the controller's pawn finds something, triggers a proc to cause some things to happen, this can be used for implementing feature parity with hostile mobs such as aggro sounds and icon state changes
/datum/ai_planning_subtree/simple_find_target/sleeping
	///Determines if we already swapped some blackboard variables to a different value, ex. vision range
	var/is_awake = FALSE
	///This is to determine if it's been at least 1 process() tick since our target became invalid, we don't want to go to sleep and immediately awaken just because we killed one target out of the two already present
	var/going_to_sleep = FALSE

/datum/ai_planning_subtree/simple_find_target/sleeping/setup(datum/ai_controller/controller)
	..()
	RegisterSignal(controller.pawn, COMSIG_BASIC_AI_WAKE_UP, PROC_REF(wake_up), controller)

/datum/ai_planning_subtree/simple_find_target/sleeping/select_behaviors(datum/ai_controller/controller, delta_time)
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!QDELETED(target))
		if(!is_awake)
			//Could modify this to implement hostile mob's ability to rally surrounding mobs around itself
			for(var/mob/mob in view(controller.pawn, controller.blackboard[BB_VISION_RANGE_AGGRO]))
				SEND_SIGNAL(mob, COMSIG_BASIC_AI_WAKE_UP)
			wake_up(source = controller.pawn, controller = controller)
			going_to_sleep = FALSE
	else
		if(going_to_sleep)
			go_sleep(controller)
		going_to_sleep = TRUE
	controller.queue_behavior(/datum/ai_behavior/find_potential_targets, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION, BB_VISION_RANGE)

///Modifies blackboard variables upon waking up, queuing target behavior is handled with select_behaviors
/datum/ai_planning_subtree/simple_find_target/sleeping/proc/wake_up(datum/source, datum/ai_controller/controller)
	SIGNAL_HANDLER
	//Checks are here due to COMSIG registration triggering this, we may be waking up multiple times to due over mobs waking up and notifying us
	if(!is_awake && controller.blackboard[BB_AGGRO_SOUND_FILE])
		playsound(controller.pawn, controller.blackboard[BB_AGGRO_SOUND_FILE], 50, vary = FALSE)
		is_awake = TRUE
	controller.set_blackboard_key(BB_VISION_RANGE, controller.blackboard[BB_VISION_RANGE_AGGRO])

///Modifies blackboard to indicate sleeping, mainly reduced vision range
/datum/ai_planning_subtree/simple_find_target/sleeping/proc/go_sleep(datum/ai_controller/controller)
	is_awake = FALSE
	controller.set_blackboard_key(BB_VISION_RANGE, controller.blackboard[BB_VISION_RANGE_SLEEP])
