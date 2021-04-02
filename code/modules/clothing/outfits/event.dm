/datum/outfit/santa //ho ho ho!
	name = "Santa Claus"

	uniform = /obj/item/clothing/under/color/red
	suit = /obj/item/clothing/suit/space/santa
	back = /obj/item/storage/backpack/santabag
	backpack_contents = list(
		/obj/item/a_gift/anything = 5,
)
	gloves = /obj/item/clothing/gloves/color/red
	head = /obj/item/clothing/head/santa
	shoes = /obj/item/clothing/shoes/sneakers/red
	r_pocket = /obj/item/flashlight

	box = /obj/item/storage/box/survival/engineer

/datum/outfit/santa/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	H.fully_replace_character_name(H.real_name, "Santa Claus")
	H.mind.assigned_role = "Santa"
	H.mind.special_role = "Santa"

	H.hairstyle = "Long Hair 3"
	H.facial_hairstyle = "Beard (Full)"
	H.hair_color = "FFF"
	H.facial_hair_color = "FFF"
	H.update_hair()
