/obj/item/device/radio/intercom
	name = "station intercom"
	desc = "Talk through this."
	icon_state = "intercom"
	anchored = 1
	w_class = WEIGHT_CLASS_BULKY
	canhear_range = 2
	var/number = 0
	var/anyai = 1
	var/mob/living/silicon/ai/ai = list()
	var/last_tick //used to delay the powercheck
	dog_fashion = null

/obj/item/device/radio/intercom/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/device/radio/intercom/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/device/radio/intercom/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/wrench))
		var/obj/item/weapon/wrench/W = I
		user.visible_message("<span class='notice'>[user] starts unsecuring [src]...</span>", "<span class='notice'>You start unsecuring [src]...</span>")
		playsound(src, W.usesound, 50, 1)
		if(!do_after(user, 80 * W.toolspeed, target = user))
			return
		user.visible_message("<span class='notice'>[user] unsecures [src]!</span>", "<span class='notice'>You detach [src] from the wall.</span>")
		playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
		new/obj/item/wallframe/intercom(get_turf(src))
		qdel(src)
		return
	..()

/obj/item/device/radio/intercom/attack_ai(mob/user)
	interact(user)

/obj/item/device/radio/intercom/attack_hand(mob/user)
	interact(user)

/obj/item/device/radio/intercom/interact(mob/user)
	..()
	ui_interact(user, state = GLOB.default_state)

/obj/item/device/radio/intercom/receive_range(freq, level)
	if(!on)
		return -1
	if(wires.is_cut(WIRE_RX))
		return -1
	if(!(0 in level))
		var/turf/position = get_turf(src)
		if(isnull(position) || !(position.z in level))
			return -1
	if(!src.listening)
		return -1
	if(freq == GLOB.SYND_FREQ)
		if(!(src.syndie))
			return -1//Prevents broadcast of messages over devices lacking the encryption

	return canhear_range


/obj/item/device/radio/intercom/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans, message_mode)
	if(!anyai && !(speaker in ai))
		return
	..()

/obj/item/device/radio/intercom/process()
	if(((world.timeofday - last_tick) > 30) || ((world.timeofday - last_tick) < 0))
		last_tick = world.timeofday

		var/area/A = get_area(src)
		if(!A || emped)
			on = 0
		else
			on = A.powered(EQUIP) // set "on" to the power status

		if(!on)
			icon_state = "intercom-p"
		else
			icon_state = "intercom"

/obj/item/device/radio/intercom/add_blood(list/blood_dna)
	return 0



/obj/item/wallframe/intercom
	name = "intercom frame"
	desc = "A detached intercom."
	icon_state = "intercom"
	result_path = /obj/item/device/radio/intercom
	onto_wall = TRUE
