/obj/machinery/computer/nanite_chamber_control
	name = "nanite chamber control console"
	desc = "Controls a connected nanite chamber. Can inoculate nanites, load programs, and analyze existing nanite swarms."
	icon = 'voidcrew/modules/nanites/icons/computer.dmi'
	icon_screen = "nanite_chamber_control"
	icon_keyboard = null
	circuit = /obj/item/circuitboard/computer/nanite_chamber_control

	///The nanite chamber this computer is connected to.
	var/obj/machinery/nanite_chamber/chamber

/obj/machinery/computer/nanite_chamber_control/Initialize(mapload)
	. = ..()
	find_chamber()

/obj/machinery/computer/nanite_chamber_control/proc/find_chamber()
	for(var/direction in GLOB.cardinals)
		var/C = locate(/obj/machinery/nanite_chamber, get_step(src, direction))
		if(C)
			var/obj/machinery/nanite_chamber/NC = C
			chamber = NC
			NC.console = src

/obj/machinery/computer/nanite_chamber_control/interact()
	if(!chamber)
		find_chamber()
	..()

/obj/machinery/computer/nanite_chamber_control/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NaniteChamberControl", name)
		ui.open()

/obj/machinery/computer/nanite_chamber_control/ui_data()
	var/list/data = list()

	if(!chamber)
		data["status_msg"] = "No chamber detected."
		return data

	if(!chamber.occupant)
		data["status_msg"] = "No occupant detected."
		return data

	var/mob/living/L = chamber.occupant

	if(!(L.mob_biotypes & (MOB_ORGANIC|MOB_UNDEAD)))
		data["status_msg"] = "Occupant not compatible with nanites."
		return data

	if(chamber.busy)
		data["status_msg"] = chamber.busy_message
		return data

	data["status_msg"] = null
	data["scan_level"] = chamber.scan_level
	data["locked"] = chamber.locked
	data["occupant_name"] = chamber.occupant.name

	SEND_SIGNAL(L, COMSIG_NANITE_UI_DATA, data, chamber.scan_level)

	return data

/obj/machinery/computer/nanite_chamber_control/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle_lock")
			chamber.locked = !chamber.locked
			chamber.update_icon()
		if("set_safety")
			var/threshold = text2num(params["value"])
			if(!isnull(threshold))
				chamber.set_safety(clamp(round(threshold, 1),0,500))
				playsound(src, "terminal_type", 25, FALSE)
				log_game("[chamber.occupant]'s nanites' safety threshold was set to [threshold] by [key_name(usr)] via [src] at [AREACOORD(src)].")
		if("set_cloud")
			var/cloud_id = text2num(params["value"])
			if(!isnull(cloud_id))
				chamber.set_cloud(clamp(round(cloud_id, 1),0,100))
				playsound(src, "terminal_type", 25, FALSE)
				log_game("[chamber.occupant]'s nanites' cloud id was set to [cloud_id] by [key_name(usr)] via [src] at [AREACOORD(src)].")
		if("connect_chamber")
			find_chamber()
		if("remove_nanites")
			playsound(src, 'sound/machines/terminal_prompt.ogg', 25, FALSE)
			chamber.remove_nanites()
			log_combat(usr, chamber.occupant, "cleared nanites from", null, "via [src]")
			log_game("[chamber.occupant]'s nanites were cleared by [key_name(usr)] via [src] at [AREACOORD(src)].")
		if("nanite_injection")
			playsound(src, 'sound/machines/terminal_prompt.ogg', 25, FALSE)
			chamber.inject_nanites()
			log_combat(usr, chamber.occupant, "injected", null, "with nanites via [src]")
			log_game("[chamber.occupant] was injected with nanites by [key_name(usr)] via [src] at [AREACOORD(src)].")
	return TRUE
