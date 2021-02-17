/datum/ai_controller/robot_customer
	blackboard = list(BB_CUSTOMER_CURRENT_ORDER = null,
	BB_CUSTOMER_MY_SEAT = null,
	BB_CUSTOMER_PATIENCE = 999,
	BB_CUSTOMER_CUSTOMERINFO = null,
	BB_CUSTOMER_EATING = FALSE,
	BB_BLACKBOARD_CUSTOMER_LEAVING = FALSE,
	BB_CUSTOMER_ATTENDING_VENUE = null)


/datum/ai_controller/robot_customer/TryPossessPawn(atom/new_pawn)
	if(!istype(new_pawn, /mob/living/simple_animal/robot_customer))
		return AI_CONTROLLER_INCOMPATIBLE
	RegisterSignal(new_pawn, COMSIG_PARENT_ATTACKBY, .proc/on_attackby)
	return ..() //Run parent at end

/datum/ai_controller/robot_customer/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(COMSIG_PARENT_ATTACKBY))
	return ..() //Run parent at end

/datum/ai_controller/robot_customer/SelectBehaviors(delta_time)
	current_behaviors = list()
	if(blackboard[BB_BLACKBOARD_CUSTOMER_LEAVING])
		var/datum/venue/attending_venue = blackboard[BB_CUSTOMER_ATTENDING_VENUE]
		current_movement_target = attending_venue
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/leave_venue)
		return

	var/obj/structure/chair/my_seat = blackboard[BB_CUSTOMER_MY_SEAT]

	if(!my_seat) //We havn't got a seat yet! find one!
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/find_seat)
		return

	current_movement_target = my_seat

	if(!blackboard[BB_CUSTOMER_CURRENT_ORDER]) //We havn't ordered yet even ordered yet. go on! go over there and go do it!
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/order_food)
		return
	else
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/wait_for_food)


/datum/ai_controller/robot_customer/proc/on_attackby(datum/source, obj/item/I, mob/user)
	SIGNAL_HANDLER
	if(blackboard[BB_CUSTOMER_CURRENT_ORDER] == I.type)
		blackboard[BB_CUSTOMER_EATING] = TRUE
		pawn.visible_message("<span class='danger'>[pawn] pushes [I] into their mouth-shaped hole!</span>", "<span class='danger'>You push [I] into your mouth-shaped hole</span>")
		qdel(I)
