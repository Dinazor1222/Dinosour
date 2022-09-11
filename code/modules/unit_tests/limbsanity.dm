/datum/unit_test/limbsanity

/datum/unit_test/limbsanity/Run()
	for(var/obj/item/bodypart/path in subtypesof(/obj/item/bodypart))
		var/obj/item/bodypart/part = new path(null)
		if(part.is_dimorphic)
			if(!icon_exists(UNLINT(part.should_draw_greyscale ? part.icon_greyscale : part.icon_static), "[part.limb_id]_[part.body_zone]_m]"))
				Fail("[part] does not have a valid icon for male variants")
			if(!icon_exists(UNLINT(part.should_draw_greyscale ? part.icon_greyscale : part.icon_static), "[part.limb_id]_[part.body_zone]_f"))
				Fail("[part] does not have a valid icon for female variants")
		else if(!icon_exists(UNLINT(part.should_draw_greyscale ? part.icon_greyscale : part.icon_static), "[part.limb_id]_[part.body_zone]"))
			Fail("[part] does not have a valid icon")
