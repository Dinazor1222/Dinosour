/obj/item/organ/body_egg
	name = "body egg"
	desc = "All slimy and yuck."
	icon_state = "innards"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_PARASITE_EGG

/obj/item/organ/body_egg/on_find(mob/living/finder)
	..()
	to_chat(finder, span_warning("You found an unknown alien organism in [owner]'s [zone]!"))

/obj/item/organ/body_egg/Initialize(mapload)
	. = ..()
	if(iscarbon(loc))
		Insert(loc)

/obj/item/organ/body_egg/Insert(mob/living/carbon/M, special = FALSE)
	..()
	ADD_TRAIT(owner, TRAIT_XENO_HOST, ORGAN_TRAIT)
	ADD_TRAIT(owner, TRAIT_XENO_IMMUNE, ORGAN_TRAIT)
	owner.med_hud_set_status()
	INVOKE_ASYNC(src, .proc/AddInfectionImages, owner)

/obj/item/organ/body_egg/Remove(mob/living/carbon/M, special = FALSE)
	if(owner)
		REMOVE_TRAIT(owner, TRAIT_XENO_HOST, ORGAN_TRAIT)
		REMOVE_TRAIT(owner, TRAIT_XENO_IMMUNE, ORGAN_TRAIT)
		owner.med_hud_set_status()
		INVOKE_ASYNC(src, .proc/RemoveInfectionImages, owner)
	..()

/obj/item/organ/body_egg/on_death(delta_time, times_fired)
	. = ..()
	if(!owner)
		return
	egg_process(delta_time, times_fired)

/obj/item/organ/body_egg/on_life(delta_time, times_fired)
	. = ..()
	egg_process(delta_time, times_fired)

/obj/item/organ/body_egg/proc/egg_process(delta_time, times_fired)
	return

/obj/item/organ/body_egg/proc/RefreshInfectionImage()
	RemoveInfectionImages()
	AddInfectionImages()

/obj/item/organ/body_egg/proc/AddInfectionImages()
	return

/obj/item/organ/body_egg/proc/RemoveInfectionImages()
	return
