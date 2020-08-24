/obj/item/modular_computer/tablet  //Its called tablet for theme of 90ies but actually its a "big smartphone" sized
	name = "tablet computer"
	icon = 'icons/obj/modular_tablet.dmi'
	icon_state = "tablet-red"
	icon_state_unpowered = "tablet"
	icon_state_powered = "tablet"
	icon_state_menu = "menu"
	worn_icon_state = "tablet"
	hardware_flag = PROGRAM_TABLET
	max_hardware_size = 1
	w_class = WEIGHT_CLASS_SMALL
	max_bays = 3
	steel_sheet_cost = 1
	slot_flags = ITEM_SLOT_ID | ITEM_SLOT_BELT
	has_light = TRUE //LED flashlight!
	comp_light_luminosity = 2.3 //Same as the PDA
	var/has_variants = TRUE
	var/finish_color = null

/obj/item/modular_computer/tablet/update_icon_state()
	if(has_variants)
		if(!finish_color)
			finish_color = pick("red","blue","brown","green","black")
		icon_state = icon_state_powered = icon_state_unpowered = "tablet-[finish_color]"

/obj/item/modular_computer/tablet/syndicate_contract_uplink
	name = "contractor tablet"
	icon = 'icons/obj/contractor_tablet.dmi'
	icon_state = "tablet"
	icon_state_unpowered = "tablet"
	icon_state_powered = "tablet"
	icon_state_menu = "assign"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_ID | ITEM_SLOT_BELT
	comp_light_luminosity = 6.3
	has_variants = FALSE

/// Given to Nuke Ops members.
/obj/item/modular_computer/tablet/nukeops
	icon_state = "tablet-syndicate"
	comp_light_luminosity = 6.3
	has_variants = FALSE
	device_theme = "syndicate"

/obj/item/modular_computer/tablet/nukeops/emag_act(mob/user)
	if(!enabled)
		to_chat(user, "<span class='warning'>You'd need to turn the [src] on first.</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You swipe \the [src]. It's screen briefly shows a message reading \"MEMORY CODE INJECTION DETECTED AND SUCCESSFULLY QUARANTINED\".</span>")
	return FALSE

/// Borg Built-in tablet interface
/obj/item/modular_computer/tablet/integrated
	icon_state = "tablet-red"
	comp_light_luminosity = 0 //tablet light button actually enables/disables the borg lamp
	has_variants = FALSE
	///Ref to the borg we're installed in. Set by the borg during our creation.
	var/mob/living/silicon/robot/borgo
	///IC log that borgs can view in their personal management app
	var/list/borglog = list()

//Makes the light settings reflect the borg's headlamp settings
/obj/item/modular_computer/tablet/integrated/ui_data(mob/user)
	. = ..()
	.["light_on"] = borgo?.lamp_enabled
	.["comp_light_color"] = borgo?.lamp_color


//Overrides the ui_act to make the flashlight controls link to the borg instead
/obj/item/modular_computer/tablet/integrated/ui_act(action, params)
	switch(action)
		if("PC_toggle_light")
			if(!borgo)
				return FALSE
			borgo.toggle_headlamp()
			return TRUE

		if("PC_light_color")
			if(!borgo)
				return FALSE
			var/mob/user = usr
			var/new_color
			while(!new_color)
				new_color = input(user, "Choose a new color for [src]'s flashlight.", "Light Color",light_color) as color|null
				if(!new_color)
					return
				if(color_hex2num(new_color) < 200) //Colors too dark are rejected
					to_chat(user, "<span class='warning'>That color is too dark! Choose a lighter one.</span>")
					new_color = null
			borgo.lamp_color = new_color
			borgo.toggle_headlamp(FALSE, TRUE)
			return TRUE
	return ..()
