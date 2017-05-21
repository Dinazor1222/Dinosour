/obj/item/clothing/suit/armor/riot/dwarf
	name = "dwarven armor"
	desc = "Great for stopping sponges."
	icon_state = "dwarf"
	item_state = "dwarf"
	dwarf_only = TRUE
	greyscale = TRUE

/obj/item/clothing/suit/armor/riot/dwarf/CheckParts(list/parts_list)
	..()
	var/obj/item/weapon/mold_result/armor_plating/S = locate() in contents
	if(S)
		var/image/Q = image(icon, icon_state)
		Q.color = S.color
		add_overlay(Q)
		smelted_material = new S.smelted_material.type()
		name = "[S.material_type] armor"
		desc = "Armor forged from [S.material_type]."
		for(var/A in armor)
			A = S.attack_amt/100



/obj/item/clothing/under/dwarf
	name = "dwarf tunic"
	icon_state = "dwarf"
	item_state = "dwarf"
	item_color = "dwarf"
	dwarf_only = TRUE

/obj/item/clothing/shoes/dwarf
	name = "dwarf shoes"
	icon_state = "dwarf"
	item_color = "dwarf"
	item_state = "dwarf"
	desc = "A pair of dwarven boots."
	dwarf_only = TRUE

/obj/item/clothing/gloves/dwarf
	desc = "Great for holding pickaxes."
	name = "dwarven gloves"
	icon_state = "dwarf"
	item_color = "dwarf"
	item_state = "dwarf"
	dwarf_only = TRUE

/obj/item/clothing/head/helmet/dwarf
	name = "dwarven helm"
	desc = "Protects the head from tantrums."
	icon_state = "dwarf"
	item_state = "dwarf"
	dwarf_only = TRUE
	greyscale = TRUE

/obj/item/clothing/head/helmet/dwarf/CheckParts(list/parts_list)
	..()
	var/obj/item/weapon/mold_result/helmet_plating/S = locate() in contents
	if(S)
		var/image/Q = image(icon, icon_state)
		Q.color = S.color
		add_overlay(Q)
		smelted_material = new S.smelted_material.type()
		name = "[S.material_type] helmet"
		desc = "Helmet forged from [S.material_type]."
		for(var/A in armor)
			A = S.attack_amt/100