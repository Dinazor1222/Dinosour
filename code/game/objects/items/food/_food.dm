///Abstract class to allow us to easily create all the generic "normal" food without too much copy pasta of adding more components
/obj/item/food
	name = "food"
	desc = "you eat this"
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/obj/food/food.dmi'
	icon_state = null
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	obj_flags = UNIQUE_RENAME
	grind_results = list()
	///List of reagents this food gets on creation
	var/list/food_reagents
	///Extra flags for things such as if the food is in a container or not
	var/food_flags
	///Bitflag of the types of food this food is
	var/foodtypes
	///Amount of volume the food can contain
	var/max_volume
	///How long it will take to eat this food without any other modifiers
	var/eat_time
	///Tastes to describe this food
	var/list/tastes
	///Verbs used when eating this food in the to_chat messages
	var/list/eatverbs
	///How much reagents per bite
	var/bite_consumption
	///What you get if you microwave the food, this should be replaced once I fully re-work cooking.
	var/microwaved_type
	///Type of atom thats spawned after eating this item
	var/trash_type
	///How much junkiness this food has? God I should remove junkiness soon
	var/junkiness
	///Will this food turn into badrecipe on a grill? Don't use this for everything; preferably mostly for food that is made on a grill to begin with so it burns after some time
	var/burns_on_grill = FALSE

/obj/item/food/Initialize()
	. = ..()
	if(food_reagents)
		food_reagents = string_assoc_list(food_reagents)
	if(tastes)
		tastes = string_assoc_list(tastes)
	if(eatverbs)
		eatverbs = string_list(eatverbs)
	MakeEdible()
	MakeProcessable()
	MakeLeaveTrash()
	MakeGrillable()

///This proc adds the edible component, overwrite this if you for some reason want to change some specific args like callbacks.
/obj/item/food/proc/MakeEdible()
	AddComponent(/datum/component/edible,\
				initial_reagents = food_reagents,\
				food_flags = food_flags,\
				foodtypes = foodtypes,\
				volume = max_volume,\
				eat_time = eat_time,\
				tastes = tastes,\
				eatverbs = eatverbs,\
				bite_consumption = bite_consumption,\
				microwaved_type = microwaved_type,\
				junkiness = junkiness)


///This proc handles processable elements, overwrite this if you want to add behavior such as slicing, forking, spooning, whatever, to turn the item into something else
/obj/item/food/proc/MakeProcessable()
	return

///This proc handles grillable components, overwrite if you want different grill results etc.
/obj/item/food/proc/MakeGrillable()
	if(burns_on_grill)
		AddComponent(/datum/component/grillable, /obj/item/food/badrecipe, rand(20 SECONDS, 30 SECONDS), TRUE)
	return

///This proc handles trash components, overwrite this if you want the object to spawn trash
/obj/item/food/proc/MakeLeaveTrash()
	if(trash_type)
		AddElement(/datum/element/food_trash, trash_type)
	return
