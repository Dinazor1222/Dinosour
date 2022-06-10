/obj/item/implant/storage
	name = "storage implant"
	desc = "Stores up to two big items in a bluespace pocket."
	icon_state = "storage"
	implant_color = "r"
	var/max_slot_stacking = 4

/obj/item/implant/storage/activate()
	. = ..()
	atom_storage?.open_storage(src, imp_in)

/obj/item/implant/storage/removed(source, silent = FALSE, special = 0)
	if(!special)
		var/datum/storage/implant/lostimplant = atom_storage
		var/mob/living/implantee = source

		var/atom/resolve_parent = lostimplant.parent?.resolve()
		if(!resolve_parent)
			return

		for (var/obj/item/I in resolve_parent.contents)
			I.add_mob_blood(implantee)
		lostimplant.mass_empty(src, implantee)
		implantee.visible_message(span_warning("A bluespace pocket opens around [src] as it exits [implantee], spewing out its contents and rupturing the surrounding tissue!"))
		implantee.apply_damage(20, BRUTE, BODY_ZONE_CHEST)
		qdel(lostimplant)
	return ..()

/obj/item/implant/storage/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	for(var/X in target.implants)
		if(istype(X, type))
			var/obj/item/implant/storage/imp_e = X
			var/datum/storage/STR = imp_e.atom_storage
			if(!STR || (STR && STR.max_slots < max_slot_stacking))
				imp_e.create_storage(type = /datum/storage/implant)
				qdel(src)
				return TRUE
			return FALSE
	create_storage(type = /datum/storage/implant)

	return ..()

/obj/item/implanter/storage
	name = "implanter (storage)"
	imp_type = /obj/item/implant/storage
