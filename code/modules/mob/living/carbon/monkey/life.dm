

/mob/living/carbon/monkey

/mob/living/carbon/monkey/handle_mutations_and_radiation(delta_time, times_fired)
	if(!radiation)
		return ..()

	if(radiation > RAD_MOB_KNOCKDOWN && DT_PROB(RAD_MOB_KNOCKDOWN_PROB, delta_time))
		if(!IsParalyzed())
			emote("collapse")
		Paralyze(RAD_MOB_KNOCKDOWN_AMOUNT)
		to_chat(src, "<span class='danger'>You feel weak.</span>")

	if(radiation > RAD_MOB_MUTATE && DT_PROB(RAD_MOB_MUTATE_PROB, delta_time))
		to_chat(src, "<span class='danger'>You mutate!</span>")
		easy_randmut(NEGATIVE + MINOR_NEGATIVE)
		emote("gasp")
		domutcheck()

		if(radiation > RAD_MOB_MUTATE * 2 && prob(50))
			gorillize()
			return

	if(radiation > RAD_MOB_VOMIT && DT_PROB(RAD_MOB_VOMIT_PROB, delta_time))
		vomit(10, TRUE)

	return ..()

/mob/living/carbon/monkey/handle_breath_temperature(datum/gas_mixture/breath)
	if(abs(get_body_temp_normal() - breath.temperature) > 50)
		switch(breath.temperature)
			if(-INFINITY to 120)
				adjustFireLoss(3)
			if(120 to 200)
				adjustFireLoss(1.5)
			if(200 to 260)
				adjustFireLoss(0.5)
			if(360 to 400)
				adjustFireLoss(2)
			if(400 to 1000)
				adjustFireLoss(3)
			if(1000 to INFINITY)
				adjustFireLoss(8)

	. = ..() // interact with body heat after dealing with the hot air

/mob/living/carbon/monkey/handle_environment(datum/gas_mixture/environment, delta_time, times_fired)
	// Run base mob body temperature proc before taking damage
	// this balances body temp to the environment and natural stabilization
	. = ..()

	if(bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT && !HAS_TRAIT(src, TRAIT_RESISTHEAT))
		switch(bodytemperature)
			if(360 to 400)
				throw_alert("temp", /atom/movable/screen/alert/hot, 1)
				apply_damage(HEAT_DAMAGE_LEVEL_1 * delta_time, BURN)
			if(400 to 460)
				throw_alert("temp", /atom/movable/screen/alert/hot, 2)
				apply_damage(HEAT_DAMAGE_LEVEL_2 * delta_time, BURN)
			if(460 to INFINITY)
				throw_alert("temp", /atom/movable/screen/alert/hot, 3)
				if(on_fire)
					apply_damage(HEAT_DAMAGE_LEVEL_3 * delta_time, BURN)
				else
					apply_damage(HEAT_DAMAGE_LEVEL_2 * delta_time, BURN)

	else if(bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT && !HAS_TRAIT(src, TRAIT_RESISTCOLD))
		if(!istype(loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
			switch(bodytemperature)
				if(200 to 260)
					throw_alert("temp", /atom/movable/screen/alert/cold, 1)
					apply_damage(COLD_DAMAGE_LEVEL_1 * delta_time, BURN)
				if(120 to 200)
					throw_alert("temp", /atom/movable/screen/alert/cold, 2)
					apply_damage(COLD_DAMAGE_LEVEL_2 * delta_time, BURN)
				if(-INFINITY to 120)
					throw_alert("temp", /atom/movable/screen/alert/cold, 3)
					apply_damage(COLD_DAMAGE_LEVEL_3 * delta_time, BURN)
		else
			clear_alert("temp")

	else
		clear_alert("temp")

	//Account for massive pressure differences

	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.
	switch(adjusted_pressure)
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			adjustBruteLoss( min( ( (adjusted_pressure / HAZARD_HIGH_PRESSURE) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE) )
			throw_alert("pressure", /atom/movable/screen/alert/highpressure, 2)
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			throw_alert("pressure", /atom/movable/screen/alert/highpressure, 1)
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			clear_alert("pressure")
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			throw_alert("pressure", /atom/movable/screen/alert/lowpressure, 1)
		else
			adjustBruteLoss( LOW_PRESSURE_DAMAGE )
			throw_alert("pressure", /atom/movable/screen/alert/lowpressure, 2)

	return

/mob/living/carbon/monkey/handle_random_events(delta_time, times_fired)
	if(DT_PROB(0.01, delta_time))
		emote("scratch")

/mob/living/carbon/monkey/has_smoke_protection()
	if(wear_mask)
		if(wear_mask.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
			return 1

/mob/living/carbon/monkey/handle_fire(delta_time, times_fired)
	. = ..()
	if(.) //if the mob isn't on fire anymore
		return

	//the fire tries to damage the exposed clothes and items
	var/list/burning_items = list()
	//HEAD//
	var/obscured = check_obscured_slots(TRUE)
	if(wear_mask && !(obscured & ITEM_SLOT_MASK))
		burning_items += wear_mask
	if(wear_neck && !(obscured & ITEM_SLOT_NECK))
		burning_items += wear_neck
	if(head)
		burning_items += head

	if(back)
		burning_items += back

	for(var/X in burning_items)
		var/obj/item/I = X
		I.fire_act((fire_stacks * 50)) //damage taken is reduced to 2% of this value by fire_act()

	adjust_bodytemperature(BODYTEMP_HEATING_MAX * 0.5 * delta_time)
	SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "on_fire", /datum/mood_event/on_fire)
