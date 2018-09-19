///LAVA

/turf/open/lava
	name = "lava"
	icon_state = "lava"
	gender = PLURAL //"That's some lava."
	baseturfs = /turf/open/lava //lava all the way down
	slowdown = 2

	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_LAVA
	bullet_bounce_sound = 'sound/items/welder2.ogg'

	footstep = FOOTSTEP_LAVA

/turf/open/lava/ex_act(severity, target)
	contents_explosion(severity, target)

/turf/open/lava/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/lava/acid_act(acidpwr, acid_volume)
	return

/turf/open/lava/MakeDry(wet_setting = TURF_WET_WATER)
	return

/turf/open/lava/airless
	initial_gas_mix = "TEMP=2.7"

/turf/open/lava/Entered(atom/movable/AM)
	if(burn_stuff(AM))
		START_PROCESSING(SSobj, src)

/turf/open/lava/Exited(atom/movable/Obj, atom/newloc)
	. = ..()
	if(isliving(Obj))
		var/mob/living/L = Obj
		if(!islava(newloc) && !L.on_fire)
			L.update_fire()

/turf/open/lava/hitby(atom/movable/AM)
	if(burn_stuff(AM))
		START_PROCESSING(SSobj, src)

/turf/open/lava/process()
	if(!burn_stuff())
		STOP_PROCESSING(SSobj, src)

/turf/open/lava/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_FLOORWALL)
			return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 3)
	return FALSE

/turf/open/lava/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			to_chat(user, "<span class='notice'>You build a floor.</span>")
			PlaceOnTop(/turf/open/floor/plating)
			return TRUE
	return FALSE

/turf/open/lava/singularity_act()
	return

/turf/open/lava/singularity_pull(S, current_size)
	return

/turf/open/lava/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/open/lava/GetHeatCapacity()
	. = 700000

/turf/open/lava/GetTemperature()
	. = 5000

/turf/open/lava/TakeTemperature(temp)


/turf/open/lava/proc/is_safe()
	//if anything matching this typecache is found in the lava, we don't burn things
	var/static/list/lava_safeties_typecache = typecacheof(list(/obj/structure/lattice/catwalk, /obj/structure/stone_tile))
	var/list/found_safeties = typecache_filter_list(contents, lava_safeties_typecache)
	for(var/obj/structure/stone_tile/S in found_safeties)
		if(S.fallen)
			LAZYREMOVE(found_safeties, S)
	return LAZYLEN(found_safeties)


/turf/open/lava/proc/burn_stuff(AM)
	. = 0

	if(is_safe())
		return FALSE

	var/thing_to_check = src
	if (AM)
		thing_to_check = list(AM)
	for(var/thing in thing_to_check)
		if(isobj(thing))
			var/obj/O = thing
			if(burn_items(O, TRUE))
				. = TRUE

		else if (isliving(thing))
			. = TRUE
			var/mob/living/L = thing
			if(L.movement_type & FLYING)
				continue	//YOU'RE FLYING OVER IT

			var/buckle_check = L.buckling
			if(!buckle_check)
				buckle_check = L.buckled
			if(isobj(buckle_check))
				var/obj/O = buckle_check
				if(O.resistance_flags & LAVA_PROOF)
					continue
			else if(isliving(buckle_check))
				var/mob/living/live = buckle_check
				if("lava" in live.weather_immunities)
					continue

			if(!L.on_fire)
				L.update_fire()

			var/skip_redundant = FALSE // no sense doing the processing to burn items twice, it would just return anyway.

			if(L.resting || L.lying) //burn all visible non-lavaproofed items if they're lying down on the lava.
				var/list/visible_items = L.get_visible_items(TRUE)
				for(var/visible_item in visible_items)
					var/obj/O = visible_item
					burn_items(O)
				skip_redundant = TRUE

			if(iscarbon(L))
				var/mob/living/carbon/C = L
				var/obj/item/clothing/S = C.get_item_by_slot(SLOT_WEAR_SUIT)
				var/obj/item/clothing/H = C.get_item_by_slot(SLOT_HEAD)

				if(S && H && S.clothing_flags & LAVAPROTECT && H.clothing_flags & LAVAPROTECT)
					if(!skip_redundant)
						for(var/obj/item/I in L.held_items) //lavasuits don't protect items in hands!
							burn_items(I)
					return

				if(!skip_redundant)
					var/obj/item/clothing/U = C.get_item_by_slot(SLOT_W_UNIFORM)
					var/obj/item/clothing/Z = C.get_item_by_slot(SLOT_SHOES)
					var/obj/item/B = C.get_item_by_slot(SLOT_BELT)

					var/list/burned_items = list() //if they aren't wearing a set of lavaproof equipment, widdle away exposed leg/waist items.

						//CHEST & WAIST//
					var/obj/item/clothing/chest_clothes = null
					if(U && (U.body_parts_covered & (LEGS|GROIN))) //only burn uniform if it's covering legs/groin
						chest_clothes = U
					if(S && (S.body_parts_covered & (LEGS|GROIN))) //only burn suit if it's covering legs/groin
						chest_clothes = S
					else if(B)
						burned_items += B

					if(chest_clothes)
						burned_items += chest_clothes

						//SHOES//
					var/obj/item/clothing/leg_clothes = null
					if(Z)
						leg_clothes = Z
					if(U && (U.body_parts_covered & FEET)) //if uniform is protecting shoes, burn uniform first.
						leg_clothes = U
					if(S && (S.body_parts_covered & FEET)) //if suit is protecting shoes, burn suit first.
						leg_clothes = S
					if(leg_clothes)
						burned_items |= leg_clothes

					for(var/obj/item/I in burned_items)
						burn_items(I)

			if(!skip_redundant)
				for(var/obj/item/I in L.held_items) //wading through lava is still risky to held items.
					burn_items(I)


			if("lava" in L.weather_immunities)
				continue

			L.adjustFireLoss(20)
			if(L) //mobs turning into object corpses could get deleted here.
				L.adjust_fire_stacks(20)
				L.IgniteMob()

/turf/open/lava/proc/burn_items(obj/O, throwing_check)
	if(QDELETED(O) || O.resistance_flags & (LAVA_PROOF|INDESTRUCTIBLE) || (throwing_check && O.throwing))
		return
	. = TRUE
	if((O.resistance_flags & (ON_FIRE)))
		return
	if(!(O.resistance_flags & FLAMMABLE))
		O.resistance_flags |= FLAMMABLE //Even fireproof things burn up in lava
	if(O.resistance_flags & FIRE_PROOF)
		O.resistance_flags &= ~FIRE_PROOF
	if(O.armor.fire > 50) //obj with 100% fire armor still get slowly burned away.
		O.armor = O.armor.setRating(fire = 50)
	O.fire_act(10000, 1000)


/turf/open/lava/smooth
	name = "lava"
	baseturfs = /turf/open/lava/smooth
	icon = 'icons/turf/floors/lava.dmi'
	icon_state = "unsmooth"
	smooth = SMOOTH_MORE | SMOOTH_BORDER
	canSmoothWith = list(/turf/open/lava/smooth)

/turf/open/lava/smooth/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/lava/smooth/lava_land_surface

/turf/open/lava/smooth/airless
	initial_gas_mix = "TEMP=2.7"
