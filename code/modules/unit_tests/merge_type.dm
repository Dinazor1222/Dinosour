/datum/unit_test/merge_type/Run()
	var/list/paths = subtypesof(/obj/item/stack) - /obj/item/stack/sheet - /obj/item/stack/sheet/mineral - /obj/item/stack/ore
	- /obj/item/stack/spacecash - /obj/item/stack/license_plates - /obj/item/stack/tile/mineral - /obj/item/stack/tile

	for(var/stackpath in paths)
		var/obj/item/stack/stack = stackpath
		if(!initial(stack.merge_type))
			Fail("([stack]) lacks set merge_type variable!")
