/datum/element/cleaning/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/Clean)

/datum/element/cleaning/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)

/datum/element/cleaning/proc/Clean(datum/source)
	var/atom/movable/AM = source
	var/turf/tile = AM.loc
	if(!isturf(tile))
		return

	tile.wash(CLEAN_WASH)
	for(var/A in tile)
		// Clean small items that are lying on the ground
		if(isitem(A))
			var/obj/item/I = A
			if(I.w_class <= WEIGHT_CLASS_SMALL && !ismob(I.loc))
				I.wash(CLEAN_WASH)
		// Clean humans that are lying down
		else if(ishuman(A))
			var/mob/living/carbon/human/cleaned_human = A
			if(!(cleaned_human.mobility_flags & MOBILITY_STAND))
				cleaned_human.wash(CLEAN_WASH)
				cleaned_human.regenerate_icons()
				to_chat(cleaned_human, "<span class='danger'>[AM] cleans your face!</span>")
