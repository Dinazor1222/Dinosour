/obj/machinery/fat_sucker
	name = "lipid extractor"
	desc = "Safely and efficiently extracts excess fat from a subject."
	icon = 'icons/obj/machines/fat_sucker.dmi'
	icon_state = "sucker"

	state_open = FALSE
	density = TRUE
	req_access = list(ACCESS_KITCHEN)
	var/processing
	var/start_at = NUTRITION_LEVEL_WELL_FED
	var/stop_at = NUTRITION_LEVEL_STARVING
	var/free_exit = TRUE //set to false to prevent people from exiting before being completely stripped of fat
	var/bite_size = 15 //amount of nutrients we take per process
	var/nutrients //amount of nutrients we got build up
	var/nutrient_to_meat = 90 //one slab of meat gives about 52 nutrition
	var/datum/looping_sound/microwave/soundloop //100% stolen from microwaves

	var/next_fact = 10 //in ticks, so about 20 seconds
	var/static/list/fat_facts = list(\
	"Fats are triglycerides made up of a combination of different building blocks; glycerol and fatty acids.", \
	"Adults should get a recommended 20-35% of their energy intake from fat.", \
	"Being overweight or obese puts you at an increased risk of chronic diseases, such as cardiovascular diseases, metabolic syndrome, type 2 diabetes and some types of cancers.", \
	"Not all fats are bad. A certain amount of fat is an essential part of a healthy balanced diet. " , \
	"Saturated fat should form no more than 11% of your daily calories.", \
	"Unsaturated fat, that is monounsaturated fats, polyunsaturated fats and omega-3 fatty acids, is found in plant foods and fish." \
	)

/obj/machinery/fat_sucker/Initialize()
	. = ..()
	soundloop = new(list(src),  FALSE)

/obj/machinery/fat_sucker/RefreshParts()
	..()
	var/rating
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		rating += L.rating
	bite_size = initial(bite_size) + rating * 5
	nutrient_to_meat = initial(nutrient_to_meat) - rating * 5

/obj/machinery/fat_sucker/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>Alt-Click to toggle the safety hatch.</span>")
	to_chat(user, "<span class='notice'>Removing [bite_size] nutritional units per operation.</span>")
	to_chat(user, "<span class='notice'>Requires [nutrient_to_meat] nutritional units per meat slab.</span>")

/obj/machinery/fat_sucker/close_machine(mob/user)
	if(panel_open)
		to_chat(user, "<span class='warning'>You need to close the maintenance hatch first!</span>")
		return
	..()
	if(occupant)
		if(!iscarbon(occupant))
			occupant.forceMove(drop_location())
			occupant = null
			return
		to_chat(occupant, "<span class='notice'>You enter [src]</span>")
		addtimer(CALLBACK(src, .proc/start_extracting), 20)

/obj/machinery/fat_sucker/open_machine(mob/user)
	make_meat()
	if(processing)
		stop()
	..()

/obj/machinery/fat_sucker/container_resist(mob/living/user)
	if(!free_exit || state_open)
		to_chat(user, "<span class='notice'>The emergency release is not responding!</span>")
		return
	open_machine()

/obj/machinery/fat_sucker/interact(mob/user)
	if(state_open)
		close_machine()
	else if(!processing || free_exit)
		open_machine()
	else
		to_chat(user, "<span class='warning'>The safety hatch has been disabled!</span>")

/obj/machinery/fat_sucker/AltClick(mob/living/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(user == occupant)
		to_chat(user, "<span class='warning'>You can't reach the controls from inside!</span>")
		return
	if(!(obj_flags & EMAGGED) && !allowed(user))
		to_chat(user, "<span class='warning'>You lack the required access.</span>")
		return
	free_exit = !free_exit
	to_chat(user, "<span class='notice'>Safety hatch [free_exit ? "unlocked" : "locked"].</span>")

/obj/machinery/fat_sucker/update_icon()
	overlays.Cut()
	if(state_open)
		icon_state = initial(icon_state) + "_open"
	else if(processing)
		icon_state  = initial(icon_state) + "_on"
	else
		icon_state = initial(icon_state)

/obj/machinery/fat_sucker/process()
	if(!processing)
		return
	if(!powered(EQUIP) || !occupant || !iscarbon(occupant))
		open_machine()
		return

	var/mob/living/carbon/C = occupant
	if(C.nutrition <= stop_at)
		open_machine()
		playsound(src, 'sound/machines/microwave/microwave-end.ogg', 100, FALSE)
		return
	C.adjust_nutrition(-bite_size)
	nutrients += bite_size

	if(next_fact <= 0)
		next_fact = initial(next_fact)
		say(pick(fat_facts))
		playsound(loc, 'sound/machines/chime.ogg', 30, FALSE)
	else
		next_fact--
	use_power(500)

/obj/machinery/fat_sucker/proc/start_extracting()
	if(state_open || !occupant || processing || !powered(EQUIP))
		return
	if(iscarbon(occupant))
		var/mob/living/carbon/C = occupant
		if(C.nutrition > start_at)
			processing = TRUE
			soundloop.start()
			update_icon()
			set_light(3, 2)
		else
			say("Subject not fat enough.")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 40, FALSE)

/obj/machinery/fat_sucker/proc/stop()
	processing = FALSE
	soundloop.stop()
	set_light(0, 0)

/obj/machinery/fat_sucker/proc/make_meat()
	if(occupant && iscarbon(occupant))
		var/mob/living/carbon/C = occupant
		if(C.type_of_meat)
			if(nutrients >= nutrient_to_meat * 2)
				C.put_in_hands(new /obj/item/reagent_containers/food/snacks/cookie (), TRUE)
			while(nutrients >= nutrient_to_meat)
				nutrients -= nutrient_to_meat
				new C.type_of_meat (drop_location())
			while(nutrients >= nutrient_to_meat / 3)
				nutrients -= nutrient_to_meat / 3
				new /obj/item/reagent_containers/food/snacks/meat/rawcutlet/plain (drop_location())
			nutrients = 0

/obj/machinery/fat_sucker/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(..())
		return
	if(occupant)
		to_chat(user, "<span class='warning'>[src] is currently occupied!</span>")
		return
	if(state_open)
		to_chat(user, "<span class='warning'>[src] must be closed to [panel_open ? "close" : "open"] its maintenance hatch!</span>")
		return
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]_panel", initial(icon_state), I))
		return
	return FALSE

/obj/machinery/fat_sucker/crowbar_act(mob/living/user, obj/item/I)
	if(default_deconstruction_crowbar(I))
		return TRUE

/obj/machinery/fat_sucker/emag_act(mob/living/user)
	if(obj_flags & EMAGGED)
		return
	start_at = 100
	stop_at = 0
	to_chat(user, "<span class='notice'>You remove the acces restrictions and lower the automatic ejection threshold!</span>")
	obj_flags |= EMAGGED