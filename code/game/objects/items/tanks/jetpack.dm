/obj/item/tank/jetpack
	name = "jetpack (empty)"
	desc = "A tank of compressed gas for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	inhand_icon_state = "jetpack"
	lefthand_file = 'icons/mob/inhands/equipment/jetpacks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/jetpacks_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	distribute_pressure = ONE_ATMOSPHERE * O2STANDARD
	actions_types = list(/datum/action/item_action/set_internals, /datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	var/gas_type = /datum/gas/oxygen
	var/on = FALSE
	var/stabilizers = FALSE
	var/full_speed = TRUE // If the jetpack will have a speedboost in space/nograv or not
	var/datum/effect_system/trail_follow/ion/ion_trail

/obj/item/tank/jetpack/Initialize(mapload)
	. = ..()
	ion_trail = new
	ion_trail.auto_process = FALSE
	ion_trail.set_up(src)

/obj/item/tank/jetpack/Destroy()
	QDEL_NULL(ion_trail)
	return ..()

/obj/item/tank/jetpack/populate_gas()
	if(gas_type)
		var/datum/gas_mixture/our_mix = return_air()
		our_mix.assert_gas(gas_type)
		our_mix.gases[gas_type][MOLES] = ((6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/tank/jetpack/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/toggle_jetpack))
		cycle(user)
	else if(istype(action, /datum/action/item_action/jetpack_stabilization))
		if(on)
			stabilizers = !stabilizers
			to_chat(user, span_notice("You turn the jetpack stabilization [stabilizers ? "on" : "off"]."))
	else
		toggle_internals(user)


/obj/item/tank/jetpack/proc/cycle(mob/user)
	if(user.incapacitated())
		return

	if(!on)
		if(turn_on(user))
			to_chat(user, span_notice("You turn the jetpack on."))
		else
			to_chat(user, span_notice("You fail to turn the jetpack on."))
			return
	else
		turn_off(user)
		to_chat(user, span_notice("You turn the jetpack off."))
	update_action_buttons()


/obj/item/tank/jetpack/proc/turn_on(mob/user)
	if(!allow_thrust(0.01, user))
		return FALSE
	on = TRUE
	icon_state = "[initial(icon_state)]-on"
	ion_trail.start()
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/move_react)
	RegisterSignal(user, COMSIG_MOVABLE_PRE_MOVE, .proc/pre_move_react)
	RegisterSignal(user, COMSIG_MOVABLE_SPACEMOVE, .proc/spacemove_react)
	if(full_speed)
		user.add_movespeed_modifier(/datum/movespeed_modifier/jetpack/fullspeed)
	return TRUE


/obj/item/tank/jetpack/proc/turn_off(mob/user)
	on = FALSE
	stabilizers = FALSE
	icon_state = initial(icon_state)
	ion_trail.stop()
	if(user)
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(user, COMSIG_MOVABLE_PRE_MOVE)
		UnregisterSignal(user, COMSIG_MOVABLE_SPACEMOVE)
		user.remove_movespeed_modifier(/datum/movespeed_modifier/jetpack/fullspeed)

/obj/item/tank/jetpack/proc/move_react(mob/user)
	SIGNAL_HANDLER
	if(!on)//If jet dont work, it dont work
		return
	if(!user || !user.client)//Don't allow jet self using
		return
	if(!isturf(user.loc))//You can't use jet in nowhere or from mecha/closet
		return
	if(!(user.movement_type & FLOATING) || user.buckled)//You don't want use jet in gravity or while buckled.
		return
	if(user.pulledby)//You don't must use jet if someone pull you
		return
	if(user.throwing)//You don't must use jet if you thrown
		return
	if(length(user.client.keys_held & user.client.movement_keys))//You use jet when press keys. yes.
		allow_thrust(0.01, user)

/obj/item/tank/jetpack/proc/pre_move_react(mob/user)
	SIGNAL_HANDLER
	ion_trail.oldposition = get_turf(src)

/obj/item/tank/jetpack/proc/spacemove_react(mob/user, movement_dir)
	SIGNAL_HANDLER

	if(on && (movement_dir || stabilizers))
		return COMSIG_MOVABLE_STOP_SPACEMOVE

/obj/item/tank/jetpack/proc/allow_thrust(num, mob/living/user)
	if((num < 0.005 || air_contents.total_moles() < num))
		turn_off(user)
		return

	var/datum/gas_mixture/removed = remove_air(num)
	if(removed.total_moles() < 0.005)
		turn_off(user)
		return

	var/turf/T = get_turf(user)
	T.assume_air(removed)
	ion_trail.generate_effect()

	return TRUE

/obj/item/tank/jetpack/suicide_act(mob/user)
	if (istype(user, /mob/living/carbon/human/))
		var/mob/living/carbon/human/H = user
		H.say("WHAT THE FUCK IS CARBON DIOXIDE?")
		H.visible_message(span_suicide("[user] is suffocating [user.p_them()]self with [src]! It looks like [user.p_they()] didn't read what that jetpack says!"))
		return (OXYLOSS)
	else
		..()

/obj/item/tank/jetpack/improvised
	name = "improvised jetpack"
	desc = "A jetpack made from two air tanks, a fire extinguisher and some atmospherics equipment. It doesn't look like it can hold much."
	icon_state = "jetpack-improvised"
	inhand_icon_state = "jetpack-improvised"
	worn_icon = null
	worn_icon_state = "jetpack-improvised"
	volume = 20 //normal jetpacks have 70 volume
	gas_type = null //it starts empty
	full_speed = FALSE //moves at hardsuit jetpack speeds

/obj/item/tank/jetpack/improvised/allow_thrust(num, mob/living/user)
	if(rand(0,250) == 0)
		to_chat(user, span_notice("You feel your jetpack's engines cut out."))
		turn_off(user)
		return
	return ..()

/obj/item/tank/jetpack/void
	name = "void jetpack (oxygen)"
	desc = "It works well in a void."
	icon_state = "jetpack-void"
	inhand_icon_state =  "jetpack-void"

/obj/item/tank/jetpack/oxygen
	name = "jetpack (oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	inhand_icon_state = "jetpack"

/obj/item/tank/jetpack/oxygen/harness
	name = "jet harness (oxygen)"
	desc = "A lightweight tactical harness, used by those who don't want to be weighed down by traditional jetpacks."
	icon_state = "jetpack-mini"
	inhand_icon_state = "jetpack-mini"
	volume = 40
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/tank/jetpack/oxygen/captain
	name = "captain's jetpack"
	desc = "A compact, lightweight jetpack containing a high amount of compressed oxygen."
	icon_state = "jetpack-captain"
	inhand_icon_state = "jetpack-captain"
	w_class = WEIGHT_CLASS_NORMAL
	volume = 90
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //steal objective items are hard to destroy.

/obj/item/tank/jetpack/oxygen/security
	name = "security jetpack (oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas by security forces."
	icon_state = "jetpack-sec"
	inhand_icon_state = "jetpack-sec"



/obj/item/tank/jetpack/carbondioxide
	name = "jetpack (carbon dioxide)"
	desc = "A tank of compressed carbon dioxide for use as propulsion in zero-gravity areas. Painted black to indicate that it should not be used as a source for internals."
	icon_state = "jetpack-black"
	inhand_icon_state =  "jetpack-black"
	distribute_pressure = 0
	gas_type = /datum/gas/carbon_dioxide


/obj/item/tank/jetpack/suit
	name = "hardsuit jetpack upgrade"
	desc = "A modular, compact set of thrusters designed to integrate with a hardsuit. It is fueled by a tank inserted into the suit's storage compartment."
	icon_state = "jetpack-mining"
	inhand_icon_state = "jetpack-black"
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	volume = 1
	slot_flags = null
	gas_type = null
	full_speed = FALSE
	var/datum/gas_mixture/tempair_contents
	var/obj/item/tank/internals/tank = null
	var/mob/living/carbon/human/active_user = null
	var/obj/item/clothing/suit/space/hardsuit/active_hardsuit = null


/obj/item/tank/jetpack/suit/Initialize(mapload)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	tempair_contents = air_contents


/obj/item/tank/jetpack/suit/Destroy()
	if(on)
		turn_off()
	return ..()


/obj/item/tank/jetpack/suit/attack_self()
	return

/obj/item/tank/jetpack/suit/cycle(mob/user)
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit))
		to_chat(user, span_warning("\The [src] must be connected to a hardsuit!"))
		return

	var/mob/living/carbon/human/H = user
	if(!istype(H.s_store, /obj/item/tank/internals))
		to_chat(user, span_warning("You need a tank in your suit storage!"))
		return
	return ..()


/obj/item/tank/jetpack/suit/turn_on(mob/user)
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit) || !ishuman(loc.loc) || loc.loc != user)
		return FALSE
	active_user = user
	tank = active_user.s_store
	air_contents = tank.return_air()
	. = ..()
	if(!.)
		active_user = null
		tank = null
		air_contents = null
		return
	active_hardsuit = loc
	RegisterSignal(active_hardsuit, COMSIG_MOVABLE_MOVED, .proc/on_hardsuit_moved)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/on_moved)
	RegisterSignal(active_user, COMSIG_PARENT_QDELETING, .proc/on_user_del)
	START_PROCESSING(SSobj, src)


/obj/item/tank/jetpack/suit/turn_off(mob/user)
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	if(active_hardsuit)
		UnregisterSignal(active_hardsuit, COMSIG_MOVABLE_MOVED)
		active_hardsuit = null
	if(active_user)
		UnregisterSignal(user, COMSIG_PARENT_QDELETING)
		active_user = null
	tank = null
	air_contents = tempair_contents
	return ..()


/obj/item/tank/jetpack/suit/process()
	var/mob/living/carbon/human/H = loc.loc
	if(!tank || tank != H.s_store)
		turn_off(active_user)
		return
	excited = TRUE
	..()


/// Called when the jetpack moves, presumably away from the hardsuit.
/obj/item/tank/jetpack/suit/proc/on_moved(atom/movable/source, atom/old_loc, movement_dir, forced, list/atom/old_locs)
	SIGNAL_HANDLER
	if(istype(loc, /obj/item/clothing/suit/space/hardsuit) && ishuman(loc.loc) && loc.loc == active_user)
		UnregisterSignal(active_hardsuit, COMSIG_MOVABLE_MOVED)
		active_hardsuit = loc
		RegisterSignal(loc, COMSIG_MOVABLE_MOVED, .proc/on_hardsuit_moved)
		return
	turn_off(active_user)


/// Called when the hardsuit loc moves, presumably away from the human user.
/obj/item/tank/jetpack/suit/proc/on_hardsuit_moved(atom/movable/source, atom/old_loc, movement_dir, forced, list/atom/old_locs)
	SIGNAL_HANDLER
	turn_off(active_user)


/// Called when the human wearing the suit that contains this jetpack is deleted.
/obj/item/tank/jetpack/suit/proc/on_user_del(mob/living/carbon/human/source, force)
	SIGNAL_HANDLER
	turn_off(active_user)


//Return a jetpack that the mob can use
//Back worn jetpacks, hardsuit internal packs, and so on.
//Used in Process_Spacemove() and wherever you want to check for/get a jetpack

/mob/proc/get_jetpack()
	return

/mob/living/carbon/get_jetpack()
	var/obj/item/tank/jetpack/J = back
	if(istype(J))
		return J

/mob/living/carbon/human/get_jetpack()
	var/obj/item/tank/jetpack/J = ..()
	if(!istype(J) && istype(wear_suit, /obj/item/clothing/suit/space/hardsuit))
		var/obj/item/clothing/suit/space/hardsuit/C = wear_suit
		J = C.jetpack
	return J
