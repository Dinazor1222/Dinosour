/mob/living/carbon/human/movement_delay()
	. = 0
	var/static/config_human_delay
	if(isnull(config_human_delay))
		config_human_delay = CONFIG_GET(number/human_delay)
	. += ..() + config_human_delay + dna.species.movement_delay(src)

/mob/living/carbon/human/slip(knockdown_amount, obj/O, lube)
	if(has_trait(TRAIT_NOSLIPALL))
		return 0
	if (!(lube&GALOSHES_DONT_HELP))
		if(has_trait(TRAIT_NOSLIPWATER))
			return 0
		if(shoes && is_type_in_typecache(shoes, GLOB.typecache_clothing))
			var/obj/item/clothing/CS = shoes
			if (CS.clothing_flags & NOSLIP)
				return 0
	return ..()

/mob/living/carbon/human/experience_pressure_difference()
	playsound(src, 'sound/effects/space_wind.ogg', 50, 1)
	if(shoes && is_type_in_typecache(shoes, GLOB.typecache_clothing))
		var/obj/item/clothing/S = shoes
		if (S.clothing_flags & NOSLIP)
			return 0
	return ..()

/mob/living/carbon/human/mob_has_gravity()
	. = ..()
	if(!.)
		if(mob_negates_gravity())
			. = 1

/mob/living/carbon/human/mob_negates_gravity()
	return ((shoes && shoes.negates_gravity()) || (dna.species.negates_gravity(src)))

/mob/living/carbon/human/Move(NewLoc, direct)
	. = ..()
	for(var/datum/mutation/human/HM in dna.mutations)
		HM.on_move(src, NewLoc)
	if(dna && dna.species)
		dna.species.on_move(src)
	if(shoes)
		if(!lying && !buckled)
			if(loc == NewLoc)
				if(!has_gravity(loc))
					return
				var/obj/item/clothing/shoes/S = shoes

				//Bloody footprints
				var/turf/T = get_turf(src)
				if(S.bloody_shoes && S.bloody_shoes[S.blood_state])
					var/obj/effect/decal/cleanable/blood/footprints/oldFP = locate(/obj/effect/decal/cleanable/blood/footprints) in T
					if(oldFP && oldFP.blood_state == S.blood_state)
						return
					else
						//No oldFP or it's a different kind of blood
						S.bloody_shoes[S.blood_state] = max(0, S.bloody_shoes[S.blood_state] - BLOOD_LOSS_PER_STEP)
						if (S.bloody_shoes[S.blood_state] > BLOOD_LOSS_IN_SPREAD)
							var/obj/effect/decal/cleanable/blood/footprints/FP = new /obj/effect/decal/cleanable/blood/footprints(T)
							FP.blood_state = S.blood_state
							FP.entered_dirs |= dir
							FP.bloodiness = S.bloody_shoes[S.blood_state] - BLOOD_LOSS_IN_SPREAD
							FP.add_blood_DNA(S.return_blood_DNA())
							FP.update_icon()
						update_inv_shoes()
				//End bloody footprints
				S.step_action()

/mob/living/carbon/human/Process_Spacemove(movement_dir = 0) //Temporary laziness thing. Will change to handles by species reee.
	if(..())
		return 1
	return dna.species.space_move(src)

