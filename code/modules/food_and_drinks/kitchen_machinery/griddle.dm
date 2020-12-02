/obj/machinery/griddle
	name = "griddle"
	desc = "Because using pans is for pansies."
	icon = 'icons/obj/machines/griddle.dmi'
	icon_state = "griddle1_off"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	layer = BELOW_OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/griddle
	processing_flags = START_PROCESSING_MANUALLY
	resistance_flags = FIRE_PROOF

	///Things that are being griddled right now, associated as atom | grilled underlay for said atom
	var/list/griddled_objects = list()
	///Looping sound for the grill
	var/datum/looping_sound/deep_fryer/fry_loop
	///Whether or not the machine is turned on right now
	var/on = FALSE
	///What variant of griddle is this?
	var/variant = 1
	///How many shit fits on the griddle?
	var/max_items = 6

/obj/machinery/griddle/Initialize()
	. = ..()
	fry_loop = new(list(src), FALSE)
	variant = rand(1,3)

/obj/machinery/griddle/attackby(obj/item/I, mob/user, params)
	if(user.transferItemToLoc(I, src, silent = FALSE))
		var/list/click_params = params2list(params)
		//Center the icon where the user clicked.
		if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
			return
		//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
		I.pixel_x = clamp(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
		I.pixel_y = clamp(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)
		to_chat(user, "<span class='notice'>You place [I] on [src].</span>")
		AddToGrill(I, user)
		update_icon()

/obj/machinery/griddle/attack_hand(mob/user)
	. = ..()
	on = !on
	if(on)
		fry_loop.start()
		begin_processing()
		for(var/i in griddled_objects)
			var/obj/item/griddle_item = i
			griddle_item.underlays += griddled_objects[griddle_item] //Add the underlay
	else
		fry_loop.stop()
		end_processing()
		for(var/i in griddled_objects)
			var/obj/item/griddle_item = i
			griddle_item.underlays += griddled_objects[griddle_item] //Add the underlay
	update_icon()


/obj/machinery/griddle/proc/AddToGrill(obj/item/item_to_grill, mob/user)
	var/mutable_appearance/grill_underlay = mutable_appearance(icon, "grease")
	griddled_objects[item_to_grill] = grill_underlay
	vis_contents += item_to_grill
	item_to_grill.flags_1 |= IS_ONTOP_1
	if(on)
		item_to_grill.underlays += grill_underlay
	RegisterSignal(item_to_grill, COMSIG_MOVABLE_MOVED, .proc/ItemMoved)
	RegisterSignal(item_to_grill, COMSIG_GRILL_COMPLETED, .proc/GrillCompleted)

/obj/machinery/griddle/proc/ItemMoved(obj/item/I, atom/OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	I.flags_1 &= ~IS_ONTOP_1
	I.underlays -= griddled_objects[I]
	griddled_objects -= I
	vis_contents -= I
	UnregisterSignal(I, COMSIG_GRILL_COMPLETED)

/obj/machinery/griddle/proc/GrillCompleted(obj/item/source, atom/grilled_result)
	SIGNAL_HANDLER
	griddled_objects -= source //Old object
	AddToGrill(grilled_result)

/obj/machinery/griddle/process(delta_time)
	..()
	for(var/i in griddled_objects)
		var/obj/item/griddled_item = i
		if(SEND_SIGNAL(griddled_item, COMSIG_ITEM_GRILLED, src, delta_time) & COMPONENT_HANDLED_GRILLING)
			continue
		griddled_item.fire_act(1000) //Hot hot hot!
		if(prob(10))
			visible_message("<span class='danger'>[griddled_item] doesn't seem to be doing too great on the [src]!</span>")

/obj/machinery/griddle/update_icon_state()
	. = ..()
	icon_state = "griddle[variant]_[on ? "on" : "off"]"

