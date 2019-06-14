/datum/component/cleaning
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/radius = 0

/datum/component/cleaning/Initialize(_radius)
	if(!ismovableatom(parent))
		return COMPONENT_INCOMPATIBLE
	radius = max(_radius, 0)
	RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), .proc/Clean)

/datum/component/cleaning/proc/Clean()
	var/atom/movable/AM = parent
	var/tiles = range(radius, AM)

	for(var/turf/tile in tiles)
		if(!isturf(tile))
			continue

		SEND_SIGNAL(tile, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
		
		for(var/A in tile)
			if(is_cleanable(A))
				qdel(A)
			else if(istype(A, /obj/item))
				var/obj/item/I = A
				SEND_SIGNAL(I, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
				if(ismob(I.loc))
					var/mob/M = I.loc
					M.regenerate_icons()
			else if(ishuman(A))
				var/mob/living/carbon/human/cleaned_human = A
				if(!(cleaned_human.mobility_flags & MOBILITY_STAND))
					if(cleaned_human.head)
						SEND_SIGNAL(cleaned_human.head, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
					if(cleaned_human.wear_suit)
						SEND_SIGNAL(cleaned_human.wear_suit, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
					else if(cleaned_human.w_uniform)
						SEND_SIGNAL(cleaned_human.w_uniform, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
					if(cleaned_human.shoes)
						SEND_SIGNAL(cleaned_human.shoes, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
					SEND_SIGNAL(cleaned_human, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
					cleaned_human.wash_cream()
					cleaned_human.regenerate_icons()
					to_chat(cleaned_human, "<span class='danger'>[AM] cleans your face!</span>")
