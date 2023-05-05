/obj/structure/locker/crate/wooden
	name = "wooden crate"
	desc = "Works just as well as a metal one."
	material_drop = /obj/item/stack/sheet/mineral/wood
	material_drop_amount = 6
	icon_state = "wooden"
	open_sound = 'sound/machines/wooden_locker_open.ogg'
	close_sound = 'sound/machines/wooden_locker_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50

/obj/structure/locker/crate/wooden/toy
	name = "toy box"
	desc = "It has the words \"Clown + Mime\" written underneath of it with marker."

/obj/structure/locker/crate/wooden/toy/PopulateContents()
	. = ..()
	new /obj/item/megaphone/clown(src)
	new /obj/item/reagent_containers/cup/soda_cans/canned_laughter(src)
	new /obj/item/pneumatic_cannon/pie(src)
	new /obj/item/food/pie/cream(src)
	new /obj/item/storage/crayons(src)
