/obj/vehicle/ridden/scooter
	name = "scooter"
	desc = "A fun way to get around."
	icon_state = "scooter"

/obj/vehicle/ridden/scooter/Initialize()
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0), TEXT_SOUTH = list(-2), TEXT_EAST = list(0), TEXT_WEST = list( 2)))


/obj/vehicle/ridden/scooter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/wrench))
		to_chat(user, "<span class='notice'>You begin to remove the handlebars...</span>")
		if(I.use_tool(src, user, 40, volume=50))
			var/obj/vehicle/ridden/scooter/skateboard/S = new(drop_location())
			new /obj/item/stack/rods(drop_location(), 2)
			to_chat(user, "<span class='notice'>You remove the handlebars from [src].</span>")
			if(has_buckled_mobs())
				var/mob/living/carbon/H = buckled_mobs[1]
				unbuckle_mob(H)
				S.buckle_mob(H)
			qdel(src)

/obj/vehicle/ridden/scooter/Moved()
	. = ..()
	for(var/m in buckled_mobs)
		var/mob/living/buckled_mob = m
		if(buckled_mob.get_num_legs() > 0)
			buckled_mob.pixel_y = 5
		else
			buckled_mob.pixel_y = -4

/obj/vehicle/ridden/scooter/buckle_mob(mob/living/M, force = 0, check_loc = 1)
	if(!istype(M))
		return 0
	if(M.get_num_legs() < 2 && M.get_num_arms() <= 0)
		to_chat(M, "<span class='warning'>Your limbless body can't ride \the [src].</span>")
		return 0
	. = ..()

/obj/vehicle/ridden/scooter/skateboard
	name = "skateboard"
	desc = "An unfinished scooter which can only barely be called a skateboard. It's still rideable, but probably unsafe. Looks like you'll need to add a few rods to make handlebars."
	icon_state = "skateboard"
	density = FALSE

/obj/vehicle/ridden/scooter/skateboard/Initialize()
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.vehicle_move_delay = 0
	D.set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	D.set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	D.set_vehicle_dir_layer(EAST, OBJ_LAYER)
	D.set_vehicle_dir_layer(WEST, OBJ_LAYER)

/obj/vehicle/ridden/scooter/skateboard/post_buckle_mob(mob/living/M)//allows skateboards to be non-dense but still allows 2 skateboarders to collide with each other
	density = TRUE
	return ..()

/obj/vehicle/ridden/scooter/skateboard/post_unbuckle_mob(mob/living/M)
	if(!has_buckled_mobs())
		density = FALSE
	return ..()

/obj/vehicle/ridden/scooter/skateboard/Collide(atom/A)
	. = ..()
	if(A.density && has_buckled_mobs())
		var/mob/living/carbon/H = buckled_mobs[1]
		var/atom/throw_target = get_edge_target_turf(H, pick(GLOB.cardinals))
		unbuckle_mob(H)
		H.throw_at(throw_target, 4, 3)
		H.Knockdown(100)
		H.adjustStaminaLoss(40)
		if(!istype(H.head,/obj/item/clothing/head/helmet/) && !istype(H.head,/obj/item/clothing/head/hardhat))
			H.adjustBrainLoss(3)
			H.updatehealth()
		visible_message("<span class='danger'>[src] crashes into [A], sending [H] flying!</span>")
		playsound(src, 'sound/effects/bang.ogg', 50, 1)

/obj/vehicle/ridden/scooter/skateboard/MouseDrop(atom/over_object)
	var/mob/living/carbon/M = usr
	if(!istype(M) || M.incapacitated() || !Adjacent(M))
		return
	if(has_buckled_mobs() && over_object == M)
		to_chat(M, "<span class='warning'>You can't lift this up when somebody's on it.</span>")
		return
	if(over_object == M)
		var/obj/item/melee/skateboard/board = new /obj/item/melee/skateboard()
		M.put_in_hands(board)
		qdel(src)

//CONSTRUCTION
/obj/item/scooter_frame
	name = "scooter frame"
	desc = "A metal frame for building a scooter. Looks like you'll need to add some metal to make wheels."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "scooter_frame"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/scooter_frame/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/wrench))
		to_chat(user, "<span class='notice'>You deconstruct [src].</span>")
		new /obj/item/stack/rods(get_turf(src),10)
		playsound(get_turf(user), 'sound/items/ratchet.ogg', 50, 1)
		qdel(src)
		return

	else if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = I
		if(M.get_amount() < 5)
			to_chat(user, "<span class='warning'>You need at least five metal sheets to make proper wheels!</span>")
			return
		to_chat(user, "<span class='notice'>You begin to add wheels to [src].</span>")
		if(do_after(user, 80, target = src))
			if(!M || M.get_amount() < 5)
				return
			M.use(5)
			to_chat(user, "<span class='notice'>You finish making wheels for [src].</span>")
			new /obj/vehicle/ridden/scooter/skateboard(user.loc)
			qdel(src)

/obj/vehicle/ridden/scooter/skateboard/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver))
		to_chat(user, "<span class='notice'>You begin to deconstruct and remove the wheels on [src]...</span>")
		playsound(get_turf(user), I.usesound, 50, 1)
		if(do_after(user, 20, target = src))
			to_chat(user, "<span class='notice'>You deconstruct the wheels on [src].</span>")
			new /obj/item/stack/sheet/metal(get_turf(src),5)
			new /obj/item/scooter_frame(get_turf(src))
			if(has_buckled_mobs())
				var/mob/living/carbon/H = buckled_mobs[1]
				unbuckle_mob(H)
			qdel(src)

	else if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/C = I
		if(C.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need at least two rods to make proper handlebars!</span>")
			return
		to_chat(user, "<span class='notice'>You begin making handlebars for [src].</span>")
		if(do_after(user, 25, target = src))
			if(!C || C.get_amount() < 2)
				return
			to_chat(user, "<span class='notice'>You add the rods to [src], creating handlebars.</span>")
			C.use(2)
			var/obj/vehicle/ridden/scooter/S = new(loc)
			if(has_buckled_mobs())
				var/mob/living/carbon/H = buckled_mobs[1]
				unbuckle_mob(H)
				S.buckle_mob(H)
			qdel(src)
