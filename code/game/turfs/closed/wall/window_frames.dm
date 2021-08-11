/turf/closed/wall/window_frame
	name = "window frame"
	desc = "A frame section to place a window on top."
	icon = 'icons/turf/walls/low_walls/low_wall_normal.dmi'
	icon_state = "low_wall_normal-0"
	base_icon_state = "low_wall_normal"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOWS)
	canSmoothWith = list(SMOOTH_GROUP_WINDOWS)
	opacity = FALSE
	density = TRUE
	blocks_air = FALSE
	flags_1 = RAD_NO_CONTAMINATE_1 | ALLOW_DARK_PAINTS_1
	rad_insulation = null
	frill_icon = 'icons/effects/frills/window_normal_frill.dmi'
	///Bitflag to hold state on what other objects we have
	var/window_state = NONE
	///what step in the construction procedure we are in
	var/construction_state = WINDOW_FRAME_EMPTY
	///Icon used by grilles for this window frame
	var/grille_icon = 'icons/turf/walls/window_grille.dmi'
	///Icon state used by grilles for this window frame
	var/grille_icon_state = "window_grille"
	///Icon used by windows for this window frame
	var/window_icon = 'icons/turf/walls/window_normal.dmi'
	///Icon state used by windows for this window frame
	var/window_icon_state = "window_normal"
	///Frill used for window frame

	///what datum material our glass is made out of
	var/glass_material = /datum/material/glass
	///what datum material our grille is composed of
	var/grille_material = /datum/material/iron
	///what datum material our frame is made out of
	var/frame_material = /datum/material/iron

	var/break_sound = "shatter"
	var/knock_sound = 'sound/effects/Glassknock.ogg'
	var/bash_sound = 'sound/effects/Glassbash.ogg'
	var/hit_sound = 'sound/effects/Glasshit.ogg'

/turf/closed/wall/window_frame/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/climbable)
	update_icon()

	var/list/initialization_materials = list(frame_material = 2000)
	if(window_state & WINDOW_FRAME_WITH_GRILLES)
		initialization_materials[grille_material] = 2000
	if(window_state & WINDOW_FRAME_WITH_WINDOW)
		initialization_materials[window_material] = 2000
	set_custom_materials(initialization_materials)

	RegisterSignal(src, COMSIG_OBJ_PAINTED, .proc/on_painted)

	if(window_state & WINDOW_FRAME_WITH_WINDOW)
		air_update_turf(TRUE, TRUE)

/turf/closed/wall/window_frame/attackby(obj/item/attacking_item, mob/living/user, params)
	if(!can_be_reached(user))
		return TRUE //skip the afterattack

	add_fingerprint(user)

	/*
	if(attacking_item.tool_behaviour == TOOL_WELDER)
		if(obj_integrity < max_integrity)
			if(!attacking_item.tool_start_check(user, amount = 0))
				return

			to_chat(user, "<span class='notice'>You begin repairing [src]...</span>")
			if(attacking_item.use_tool(src, user, 40, volume = 50))
				obj_integrity = max_integrity
				update_nearby_icons()
				to_chat(user, "<span class='notice'>You repair [src].</span>")
		else
			to_chat(user, "<span class='warning'>[src] is already in good condition!</span>")
		return

	if(!(flags_1&NODECONSTRUCT_1) && !(reinf && state >= RWINDOW_FRAME_BOLTED))
		if(attacking_item.tool_behaviour == TOOL_SCREWDRIVER)
			to_chat(user, "<span class='notice'>You begin to [anchored ? "unscrew the window from":"screw the window to"] the floor...</span>")
			if(attacking_item.use_tool(src, user, decon_speed, volume = 75, extra_checks = CALLBACK(src, .proc/check_anchored, anchored)))
				set_anchored(!anchored)
				to_chat(user, "<span class='notice'>You [anchored ? "fasten the window to":"unfasten the window from"] the floor.</span>")
			return
		else if(attacking_item.tool_behaviour == TOOL_WRENCH && !anchored)
			to_chat(user, "<span class='notice'>You begin to disassemble [src]...</span>")
			if(attacking_item.use_tool(src, user, decon_speed, volume = 75, extra_checks = CALLBACK(src, .proc/check_state_and_anchored, state, anchored)))
				var/obj/item/stack/sheet/G = new glass_type(user.loc, glass_amount)
				G.add_fingerprint(user)
				playsound(src, 'sound/items/Deconstruct.ogg', 50, TRUE)
				to_chat(user, "<span class='notice'>You successfully disassemble [src].</span>")
				qdel(src)
			return
		else if(attacking_item.tool_behaviour == TOOL_CROWBAR && reinf && (state == WINDOW_OUT_OF_FRAME) && anchored)
			to_chat(user, "<span class='notice'>You begin to lever the window into the frame...</span>")
			if(attacking_item.use_tool(src, user, 100, volume = 75, extra_checks = CALLBACK(src, .proc/check_state_and_anchored, state, anchored)))
				state = RWINDOW_SECURE
				to_chat(user, "<span class='notice'>You pry the window into the frame.</span>")
			return

	return ..()
	*/

/turf/closed/wall/window_frame/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!can_be_reached(user))
		return
	user.changeNext_move(CLICK_CD_MELEE)

	if(!user.combat_mode)
		switch(construction_state)
			if(WINDOW_FRAME_GRILLE_UNSECURED)
				construction_state = WINDOW_FRAME_EMPTY
				window_state &= ~WINDOW_FRAME_WITH_GRILLES
				var/list/new_materials = has_material_type(glass_material)
				if(!length(new_materials))
					stack_trace("[src] does not have any iron but had a grille!")
				set_custom_materials(new_materials)
				var/obj/item/stack/rods/rod = new(src, 1)

		user.visible_message("<span class='notice'>[user] knocks on [src].</span>", \
			"<span class='notice'>You knock on [src].</span>")
		playsound(src, knocksound, 50, TRUE)
	else
		user.visible_message("<span class='warning'>[user] bashes [src]!</span>", \
			"<span class='warning'>You bash [src]!</span>")
		playsound(src, bashsound, 100, TRUE)

///returns the new rods
/turf/close/wall/window_frame/proc/remove_grille(drop_on_loc = TRUE)
	window_state &= ~WINDOW_FRAME_WITH_GRILLES

//turf/closed/wall/try_decon(obj/item/used_item, mob/user, turf/user_turf)

/turf/closed/wall/window_frame/attack_tk(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='notice'>Something knocks on [src].</span>")
	add_fingerprint(user)
	playsound(src, knocksound, 50, TRUE)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/turf/closed/wall/window_frame/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(!can_be_reached(user))
		return
	return ..()

/turf/closed/wall/window_frame/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!can_be_reached(user))
		return
	user.changeNext_move(CLICK_CD_MELEE)

	if(!user.combat_mode)
		user.visible_message("<span class='notice'>[user] knocks on [src].</span>", \
			"<span class='notice'>You knock on [src].</span>")
		playsound(src, knocksound, 50, TRUE)
	else
		user.visible_message("<span class='warning'>[user] bashes [src]!</span>", \
			"<span class='warning'>You bash [src]!</span>")
		playsound(src, bashsound, 100, TRUE)

/turf/closed/wall/window_frame/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/turf/closed/wall/window_frame/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1) //used by attack_alien, attack_animal, and attack_slime
	if(!can_be_reached(user))
		return
	return ..()

///delightfully devilous seymour
/turf/closed/wall/window_frame/set_smoothed_icon_state(new_junction)
	. = ..()
	update_icon()

/turf/closed/wall/window_frame/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("mode" = RCD_DECONSTRUCT, "delay" = 20, "cost" = 5)
	return FALSE

/turf/closed/wall/window_frame/rcd_act(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		to_chat(user, "<span class='notice'>You deconstruct the window.</span>")
		qdel(src)
		return TRUE
	return FALSE

/turf/closed/wall/window_frame/examine(mob/user)
	. = ..()
	if(window_state & (WINDOW_FRAME_WITH_WINDOW|WINDOW_FRAME_WITH_GRILLES))
		. += "<span class='notice'>The window is fully constructed.</span>"
	else if(window_state & WINDOW_FRAME_WITH_WINDOW)
		. += "<span class='notice'>The window set into the frame has no reinforcement.</span>"
	else if(window_state & WINDOW_FRAME_WITH_GRILLES)
		. += "<span class='notice'>The window frame only has a grille set into it.</span>"
	else
		. += "<span class='notice'>The window frame is empty</span>"
	/*
	if(reinf)
		if(anchored && state == WINDOW_SCREWED_TO_FRAME)
			. += "<span class='notice'>The window is <b>screwed</b> to the frame.</span>"
		else if(anchored && state == WINDOW_IN_FRAME)
			. += "<span class='notice'>The window is <i>unscrewed</i> but <b>pried</b> into the frame.</span>"
		else if(anchored && state == WINDOW_OUT_OF_FRAME)
			. += "<span class='notice'>The window is out of the frame, but could be <i>pried</i> in. It is <b>screwed</b> to the floor.</span>"
		else if(!anchored)
			. += "<span class='notice'>The window is <i>unscrewed</i> from the floor, and could be deconstructed by <b>wrenching</b>.</span>"
	else
		if(anchored)
			. += "<span class='notice'>The window is <b>screwed</b> to the floor.</span>"
		else
			. += "<span class='notice'>The window is <i>unscrewed</i> from the floor, and could be deconstructed by <b>wrenching</b>.</span>"
	*/

/turf/closed/wall/window_frame/update_appearance(updates)
	. = ..()
	if(window_state & WINDOW_FRAME_WITH_WINDOW)
		AddElement(/datum/element/frill, frill_icon)
	else
		RemoveElement(/datum/element/frill)

/turf/closed/wall/window_frame/update_overlays()
	. = ..()
	if(window_state & WINDOW_FRAME_WITH_GRILLES)
		. += mutable_appearance(grille_icon, "[grille_icon_state]-[smoothing_junction]")
	if(window_state & WINDOW_FRAME_WITH_WINDOW)
		. += mutable_appearance(window_icon, "[window_icon_state]-[smoothing_junction]")

/turf/closed/wall/window_frame/grille
	window_state = WINDOW_FRAME_WITH_GRILLES

/turf/closed/wall/window_frame/grille_and_window
	window_state = WINDOW_FRAME_COMPLETE

/turf/closed/wall/window_frame/titanium
	name = "shuttle window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_shuttle.dmi'
	icon_state = "low_wall_shuttle-0"
	base_icon_state = "low_wall_shuttle"
	custom_materials = list(/datum/material/titanium = 2000)

/turf/closed/wall/window_frame/plastitanium
	name = "plastitanium window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_plastitanium.dmi'
	icon_state = "low_wall_plastitanium-0"
	base_icon_state = "low_wall_plastitanium"
	custom_materials = list(/datum/material/alloy/plastitanium = 2000)

/turf/closed/wall/window_frame/wood
	name = "wooden platform"
	icon = 'icons/turf/walls/low_walls/low_wall_wood.dmi'
	icon_state = "low_wall_wood-0"
	base_icon_state = "low_wall_wood"
	custom_materials = list(/datum/material/wood = 2000)

/turf/closed/wall/window_frame/uranium
	name = "uranium window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_uranium.dmi'
	icon_state = "low_wall_uranium-0"
	base_icon_state = "low_wall_uranium"
	custom_materials = list(/datum/material/uranium = 2000)

/turf/closed/wall/window_frame/iron
	name = "rough iron window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_iron.dmi'
	icon_state = "low_wall_iron-0"
	base_icon_state = "low_wall_iron"
	custom_materials = list(/datum/material/iron = 2000)

/turf/closed/wall/window_frame/silver
	name = "silver window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_silver.dmi'
	icon_state = "low_wall_silver-0"
	base_icon_state = "low_wall_silver"
	custom_materials = list(/datum/material/silver = 2000)

/turf/closed/wall/window_frame/gold
	name = "gold window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_gold.dmi'
	icon_state = "low_wall_gold-0"
	base_icon_state = "low_wall_gold"
	custom_materials = list(/datum/material/gold = 2000)

/turf/closed/wall/window_frame/bronze
	name = "clockwork window mount"
	icon = 'icons/turf/walls/low_walls/low_wall_bronze.dmi'
	icon_state = "low_wall_bronze-0"
	base_icon_state = "low_wall_bronze"
	custom_materials = list(/datum/material/bronze = 2000)

/turf/closed/wall/window_frame/cult
	name = "rune-scarred window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_cult.dmi'
	icon_state = "low_wall_cult-0"
	base_icon_state = "low_wall_cult"
	custom_materials = list(/datum/material/runedmetal = 2000)

/turf/closed/wall/window_frame/hotel
	name = "hotel window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_hotel.dmi'
	icon_state = "low_wall_hotel-0"
	base_icon_state = "low_wall_hotel"
	custom_materials = list(/datum/material/wood = 2000)

/turf/closed/wall/window_frame/material
	name = "material window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_material.dmi'
	icon_state = "low_wall_material-0"
	base_icon_state = "low_wall_material"
	material_flags = MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

/turf/closed/wall/window_frame/rusty
	name = "rusty window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_rusty.dmi'
	icon_state = "low_wall_rusty-0"
	base_icon_state = "low_wall_rusty"
	custom_materials = list(/datum/material/iron = 2000)

/turf/closed/wall/window_frame/sandstone
	name = "sandstone plinth"
	icon = 'icons/turf/walls/low_walls/low_wall_sandstone.dmi'
	icon_state = "low_wall_sandstone-0"
	base_icon_state = "low_wall_sandstone"
	custom_materials = list(/datum/material/sandstone = 2000)

/turf/closed/wall/window_frame/bamboo
	name = "bamboo platform"
	icon = 'icons/turf/walls/low_walls/low_wall_bamboo.dmi'
	icon_state = "low_wall_bamboo-0"
	base_icon_state = "low_wall_bamboo"
	custom_materials = list(/datum/material/bamboo = 2000)

/turf/closed/wall/window_frame/paperframe
	name = "japanese window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_paperframe.dmi'
	icon_state = "low_wall_paperframe-0"
	base_icon_state = "low_wall_paperframe"
	custom_materials = list(/datum/material/paper = 2000)
