/obj/structure/microscope
	name = "Microscope"
	desc = "A simple microscope, allowing you to examine micro-organisms."
	icon = 'icons/obj/science/vatgrowing.dmi'
	icon_state = "microscope"
	var/obj/item/petri_dish/current_dish

/obj/structure/microscope/attacked_by(obj/item/I, mob/living/user)
	if(!istype(I, /obj/item/petri_dish))
		return ..()
	if(current_dish)
		to_chat(user, span_warning("There is already a petridish in \the [src]."))
		return
	to_chat(user, span_notice("You put [I] into \the [src]."))
	current_dish = I
	current_dish.forceMove(src)

/obj/structure/microscope/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Microscope", name)
		ui.open()

/obj/structure/microscope/ui_data(mob/user)
	var/list/data = list()

	data["has_dish"] = current_dish ? TRUE : FALSE
	data["cell_lines"] = list()

	if(!current_dish)
		return data
	if(!current_dish.sample)
		return data

	for(var/organism in current_dish.sample.micro_organisms) //All the microorganisms in the dish
		if(istype(organism, /datum/micro_organism/cell_line))
			var/datum/micro_organism/cell_line/cell_line = organism
			var/atom/resulting_atom = cell_line.resulting_atom
			var/atom_icon = resulting_atom ? sanitize_css_class_name("[initial(resulting_atom.icon)][initial(resulting_atom.icon_state)]") : ""
			var/list/organism_data = list(
				type = "cell line",
				name = cell_line.name,
				desc = cell_line.desc,
				icon = atom_icon,
				growth_rate = cell_line.growth_rate,
				suspectibility = cell_line.virus_suspectibility,
				requireds = get_reagent_list(cell_line.required_reagents),
				supplementaries = get_reagent_list(cell_line.supplementary_reagents),
				suppressives = get_reagent_list(cell_line.suppressive_reagents)
			)
			data["cell_lines"] += list(organism_data)

		if(istype(organism, /datum/micro_organism/virus))
			var/datum/micro_organism/virus/virus = organism
			var/list/virus_data = list(
				type = "virus",
				name = virus.name,
				desc = virus.desc
			)
			data["cell_lines"] += list(virus_data)

	return data

/obj/structure/microscope/proc/get_reagent_list(list/reagents)
	var/list/reagent_list = list()
	for(var/i in reagents) //Convert from assoc to normal. Yeah very shit.
		var/datum/reagent/reagent = i
		reagent_list += initial(reagent.name)
	return reagent_list.Join(", ")


/obj/structure/microscope/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("eject_petridish")
			if(!current_dish)
				return FALSE
			current_dish.forceMove(get_turf(src))
			current_dish = null
			. = TRUE
	update_appearance()

/obj/structure/microscope/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/cell_line)
	)

/datum/crafting_recipe/microscope
	name = "Microscope"
	result = /obj/structure/microscope
	time = 30
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/flashlight = 1,
	)
	category = CAT_CHEMISTRY
