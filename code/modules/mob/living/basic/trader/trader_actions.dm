/datum/action/setup_shop
	name = "Setup shop"
	desc = "Summons a wacky sales sign, and a comfy sitting spot to conduct your business from."
	button_icon = 'icons/mob/actions/actions_trader.dmi'
	button_icon_state = "setup_shop"
	/// The shop spot
	var/datum/weakref/shop_spot_ref
	/// The server this console is connected to.
	var/datum/weakref/sign_ref
	var/shop_spot_type
	var/sign_type
	var/shop_sound
	var/opening_lines

/datum/action/setup_shop/IsAvailable(feedback = FALSE)
	. = ..()
	if (!.)
		return FALSE
	if(shop_spot_ref?.resolve())
		if(feedback)
			owner.balloon_alert(owner, "already set up!")
		return FALSE
	return TRUE

/datum/action/setup_shop/New(Target, datum/trader_data/data)
	. = ..()
	src.shop_spot_type = data.shop_spot_type
	src.sign_type = data.sign_type
	src.shop_sound = data.sell_sound
	src.opening_lines = data.say_phrases[TRADER_SHOP_OPENING_PHRASE]

/datum/action/setup_shop/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	owner.say(pick(opening_lines))
	var/obj/shop_spot = new shop_spot_type(owner.loc)
	shop_spot.dir = owner.dir
	shop_spot_ref = WEAKREF(shop_spot)
	if(owner.ai_controller)
		owner.ai_controller.set_blackboard_key(BB_SHOP_SPOT, shop_spot)

	playsound(owner, shop_sound, 50, TRUE)

	var/turf/sign_turf

	sign_turf = try_find_valid_spot(owner.loc, turn(shop_spot.dir, -90))
	if(isnull(sign_turf)) //No space to my left, lets try right
		sign_turf = try_find_valid_spot(owner.loc, turn(shop_spot.dir, 90))

	if(!isnull(sign_turf))
		var/obj/sign = sign_ref?.resolve()
		if(QDELETED(sign))
			var/obj/new_sign = new sign_type(sign_turf)
			sign_ref = WEAKREF(sign)
			do_sparks(3, FALSE, new_sign)
		else
			do_teleport(sign,sign_turf)

///Look for a spot we can place our sign on
/datum/action/setup_shop/proc/try_find_valid_spot(origin_turf, direction_to_check)
	var/turf/sign_turf = get_step(origin_turf, direction_to_check)
	if(sign_turf && !isgroundlessturf(sign_turf) && !isclosedturf(sign_turf) && !sign_turf.is_blocked_turf())
		return sign_turf
	return null
