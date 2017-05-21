/*Crafting recipes for stuff made out of the blacksmtihing tools*/

/datum/crafting_recipe/broadsword
	name = "Smith Broadsword"
	result = /obj/item/weapon/smithed_sword
	reqs = list(/obj/item/weapon/grown/log = 1,
				/obj/item/weapon/mold_result/blade = 1)
	parts = list(/obj/item/weapon/mold_result/blade = 1)
	time = 40
	category = CAT_SMITH

/datum/crafting_recipe/pickaxe
	name = "Smithed Pickaxe"
	result = /obj/item/weapon/pickaxe/smithed_pickaxe
	reqs = list(/obj/item/weapon/grown/log = 1,
				/obj/item/weapon/mold_result/pickaxe_head = 1)
	parts = list(/obj/item/weapon/mold_result/pickaxe_head = 1)
	time = 40
	category = CAT_SMITH

/datum/crafting_recipe/shovel
	name = "Smithed Shovel"
	result = /obj/item/weapon/shovel/smithed_shovel
	reqs = list(/obj/item/weapon/grown/log = 1,
				/obj/item/weapon/mold_result/shovel_head = 1)
	parts = list(/obj/item/weapon/mold_result/shovel_head = 1)
	time = 40
	category = CAT_SMITH

/datum/crafting_recipe/smith_armor
	name = "Smith Armor"
	result = /obj/item/clothing/suit/armor/riot/dwarf
	reqs = list(/obj/item/weapon/grown/log = 1,
				/obj/item/weapon/mold_result/armor_plating = 1)
	parts = list(/obj/item/weapon/mold_result/armor_plating = 1)
	time = 40
	category = CAT_SMITH

/datum/crafting_recipe/smith_helmet
	name = "Smith Helmet
	result = /obj/item/clothing/head/helmet/dwarf
	reqs = list(/obj/item/weapon/grown/log = 1,
				/obj/item/weapon/mold_result/helmet_plating = 1)
	parts = list(/obj/item/weapon/mold_result/helmet_plating = 1)
	time = 40
	category = CAT_SMITH