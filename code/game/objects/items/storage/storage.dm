/obj/item/storage
	name = "storage"
	icon = 'icons/obj/storage.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	var/rummage_if_nodrop = TRUE
	var/component_type = /datum/component/storage/concrete

/obj/item/storage/get_dumping_location(obj/item/storage/source,mob/user)
	return src

/obj/item/storage/Initialize()
	. = ..()
	if (!(item_flags & ITEM_LAZY_STORAGE))
		PopulateContents()

/obj/item/storage/ComponentInitialize()
	. = ..()
	if (!(item_flags & ITEM_LAZY_STORAGE))
		var/STR = AddComponent(component_type)
		StorageInitialize(STR)
	else
		AddElement(/datum/element/lazystorage)

/// Set up vars for the storage component
/obj/item/storage/proc/StorageInitialize(datum/component/storage/STR)

/obj/item/storage/AllowDrop()
	return FALSE

/obj/item/storage/contents_explosion(severity, target)
	for(var/thing in contents)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += thing
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += thing
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += thing

/obj/item/storage/canStrip(mob/who)
	. = ..()
	if(!. && rummage_if_nodrop)
		return TRUE

/obj/item/storage/doStrip(mob/who)
	if(HAS_TRAIT(src, TRAIT_NODROP) && rummage_if_nodrop)
		var/datum/component/storage/CP = GetComponent(/datum/component/storage)
		CP.do_quick_empty()
		return TRUE
	return ..()

/obj/item/storage/contents_explosion(severity, target)
//Cyberboss says: "USE THIS TO FILL IT, NOT INITIALIZE OR NEW"

/obj/item/storage/proc/PopulateContents()

/obj/item/storage/proc/emptyStorage()
	var/datum/component/storage/ST = GetComponent(/datum/component/storage)
	ST.do_quick_empty()

/obj/item/storage/Destroy()
	for(var/obj/important_thing in contents)
		if(!(important_thing.resistance_flags & INDESTRUCTIBLE))
			continue
		important_thing.forceMove(drop_location())
	return ..()
