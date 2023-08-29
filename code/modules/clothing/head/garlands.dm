/obj/item/clothing/head/costume/garland
	name = "floral garland"
	desc = "Someone, somewhere, is starving while wearing this. And it's definitely not you."
	icon_state = "garland"
	worn_icon_state = "garland"

/obj/item/clothing/head/costume/garland/equipped(mob/living/user, slot)
	. = ..()
	if(slot_flags & slot)
		user.add_mood_event("garland", /datum/mood_event/garland)

/obj/item/clothing/head/costume/garland/dropped(mob/living/user)
	. = ..()
	user.clear_mood_event("garland")

/obj/item/clothing/head/costume/rainbowbunchcrown
	name = "rainbow flower crown"
	desc = "A flower crown made out of the flowers of the rainbow bunch plant."
	icon_state = "rainbow_bunch_crown"
	worn_icon_state = "rainbow_bunch_crown"

/obj/item/clothing/head/costume/rainbowbunchcrown/Initialize()
	. = ..()
	var/crown_type = rand(1,4)
	switch(crown_type)
		if(1)
			desc += " This one has red, yellow and white flowers."
			icon_state = "rainbow_bunch_crown_1"
		if(2)
			desc += " This one has blue, yellow, green and white flowers."
			icon_state = "rainbow_bunch_crown_2"
		if(3)
			desc += " This one has red, blue, purple and pink flowers."
			icon_state = "rainbow_bunch_crown_3"
		if(4)
			desc += " This one has yellow, green and white flowers."
			icon_state = "rainbow_bunch_crown_4"

/obj/item/clothing/head/costume/rainbowbunchcrown/equipped(mob/living/user, slot)
	. = ..()
	if(slot_flags & slot)
		user.add_mood_event("garland", /datum/mood_event/garland)

/obj/item/clothing/head/costume/rainbowbunchcrown/dropped(mob/living/user)
	. = ..()
	user.clear_mood_event("garland")

/obj/item/clothing/head/costume/sunflowercrown
	name = "sunflower crown"
	desc = "A bright flower crown made out sunflowers that is sure to brighten up anyone's day!"
	icon_state = "sunflower_crown"
	worn_icon_state = "sunflower_crown"

/obj/item/clothing/head/costume/sunflowercrown/equipped(mob/living/user, slot)
	. = ..()
	if(slot_flags & slot)
		user.add_mood_event("garland", /datum/mood_event/garland)

/obj/item/clothing/head/costume/sunflowercrown/dropped(mob/living/user)
	. = ..()
	user.clear_mood_event("garland")

/obj/item/clothing/head/costume/poppycrown
	name = "poppy crown"
	desc = "A flower crown made out of a string of bright red poppies."
	icon_state = "poppy_crown"
	worn_icon_state = "poppy_crown"

/obj/item/clothing/head/costume/poppycrown/equipped(mob/living/user, slot)
	. = ..()
	if(slot_flags & slot)
		user.add_mood_event("garland", /datum/mood_event/garland)

/obj/item/clothing/head/costume/poppycrown/dropped(mob/living/user)
	. = ..()
	user.clear_mood_event("garland")

/obj/item/clothing/head/costume/lilycrown
	name = "lily crown"
	desc = "A leafy flower crown with a cluster of large white lilies at at the front."
	icon_state = "lily_crown"
	worn_icon_state = "lily_crown"

/obj/item/clothing/head/costume/lilycrown/equipped(mob/living/user, slot)
	. = ..()
	if(slot_flags & slot)
		user.add_mood_event("garland", /datum/mood_event/garland)

/obj/item/clothing/head/costume/lilycrown/dropped(mob/living/user)
	. = ..()
	user.clear_mood_event("garland")
