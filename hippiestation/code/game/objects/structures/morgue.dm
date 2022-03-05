/obj/structure/bodycontainer/morgue/update_icon()	//hippie start, re-add cloning
	..()
	var/list/compiled = get_all_contents_type(/mob/living) // Search for mobs in all contents.
	if(!length(compiled)) // No mobs?
		icon_state = "morgue3"
		return
	for(var/mob/living/M in compiled)
		var/mob/living/mob_occupant = get_mob_or_brainmob(M)
		if(mob_occupant.client && !mob_occupant.suiciding && !(HAS_TRAIT(mob_occupant, TRAIT_BADDNA)))
			icon_state = "morgue4" // clonable
