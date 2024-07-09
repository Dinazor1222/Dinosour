/// A global assoc list for the drop of point
GLOBAL_LIST_EMPTY(voidwalker_void)

/// Lardmarks meant to designate where voidwalker kidnapees are sent
/obj/effect/landmark/voidwalker_void
	name = "default voidwalker void landmark"
	icon_state = "x"

/obj/effect/landmark/voidwalker_void/Initialize(mapload)
	. = ..()
	GLOB.voidwalker_void += src

/obj/effect/landmark/voidwalker_void/Destroy()
	GLOB.voidwalker_void -= src
	return ..()

/// Voidwalker void where the people go
/area/centcom/voidwalker_void
	name = "Voidwalker void"
	icon_state = "voidwalker"
	has_gravity = STANDARD_GRAVITY
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_ENVIRONMENT_CAVE
	area_flags = UNIQUE_AREA | NOTELEPORT | HIDDEN_AREA | BLOCK_SUICIDE

/// Mini car where people drive around in in their mangled corpse to heal a bit before they get dumped back on station
/obj/effect/wisp_mobile
	name = "wisp"

	icon = 'icons/obj/weapons/voidwalker_items.dmi'
	icon_state = "wisp"

	light_system = OVERLAY_LIGHT
	light_color = COLOR_WHITE
	light_range = 4
	light_power = 1
	light_on = TRUE

	/// Delay between movements
	var/move_delay = 0.5 SECONDS
	/// when can we move again?
	var/can_move
	/// what do we eatt?
	var/food_type = /obj/effect/wisp_food
	/// how much do we heal per food?
	var/heal_per_food = 15
	/// Traits given to the wisp driver
	var/wisp_driver_traits = list(TRAIT_STASIS, TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT)

/obj/effect/wisp_mobile/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()

	if(!isliving(arrived))
		return

	var/mob/living/driver = arrived
	driver.forceMove(src)
	driver.add_traits(wisp_driver_traits, REF(src))
	add_atom_colour(random_color(), FIXED_COLOUR_PRIORITY)

	if(ishuman(driver))
		var/mob/living/carbon/human/human_driver = driver
		human_driver.set_handcuffed(new /obj/item/restraints/handcuffs/energy/void(human_driver))
		human_driver.update_handcuffed()

	addtimer(CALLBACK(driver, TYPE_PROC_REF(/atom/movable, forceMove), get_random_station_turf()), 60 SECONDS)

/obj/effect/wisp_mobile/relaymove(mob/living/user, direction)
	if(can_move >= world.time)
		return
	can_move = world.time + move_delay

	if(isturf(loc))
		can_move = world.time + move_delay
		try_step_multiz(direction)

/obj/effect/wisp_mobile/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()

	var/obj/food = locate(food_type) in loc
	if(!food)
		return

	qdel(food)

	// make new food
	var/area/our_area = get_area(src)
	new food_type(pick(get_area_turfs(our_area)))

	var/mob/living/driver = locate(/mob/living) in contents
	if(driver)
		driver.heal_ordered_damage(heal_per_food, list(BRUTE, BURN, OXY))
		playsound(src, 'sound/misc/server-ready.ogg', 50, TRUE, -1)

/obj/effect/wisp_mobile/Exited(atom/movable/gone, direction)
	. = ..()

	gone.remove_traits(wisp_driver_traits, REF(src))

	if(ishuman(gone))
		var/mob/living/carbon/human/freedom = gone
		if(freedom.handcuffed)
			qdel(freedom.handcuffed)

	qdel(src)

/// we only exist to be eaten by wisps for food 😔👊
/obj/effect/wisp_food
	name = "wisp"
	icon = 'icons/obj/weapons/voidwalker_items.dmi'
	icon_state = "wisp"

	color = COLOR_YELLOW

	light_system = OVERLAY_LIGHT
	light_color = COLOR_WHITE
	light_range = 4
	light_power = 1
	light_on = TRUE

/obj/item/restraints/handcuffs/energy/void
	breakouttime = INFINITY
