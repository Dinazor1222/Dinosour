/*
Research and Development (R&D) Console

This is the main work horse of the R&D system. It contains the menus/controls for the Destructive Analyzer, Protolathe, and Circuit
imprinter.

Basic use: When it first is created, it will attempt to link up to related devices within 3 squares. It'll only link up if they
aren't already linked to another console. Any consoles it cannot link up with (either because all of a certain type are already
linked or there aren't any in range), you'll just not have access to that menu. In the settings menu, there are menu options that
allow a player to attempt to re-sync with nearby consoles. You can also force it to disconnect from a specific console.

The imprinting and construction menus do NOT require toxins access to access but all the other menus do. However, if you leave it
on a menu, nothing is to stop the person from using the options on that menu (although they won't be able to change to a different
one). You can also lock the console on the settings menu if you're feeling paranoid and you don't want anyone messing with it who
doesn't have toxins access.

*/

/obj/machinery/computer/rdconsole
	name = "R&D Console"
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	circuit = /obj/item/weapon/circuitboard/computer/rdconsole
	var/datum/techweb/stored_research					//Reference to global science techweb.
	var/obj/item/weapon/disk/tech_disk/t_disk = null	//Stores the technology disk.
	var/obj/item/weapon/disk/design_disk/d_disk = null	//Stores the design disk.

	var/obj/machinery/rnd/destructive_analyzer/linked_destroy = null	//Linked Destructive Analyzer
	var/obj/machinery/rnd/protolathe/linked_lathe = null				//Linked Protolathe
	var/obj/machinery/rnd/circuit_imprinter/linked_imprinter = null	//Linked Circuit Imprinter

	req_access = list(GLOB.access_tox)	//Data and setting manipulation requires scientist access.

	var/category_lathe
	var/category_imprinter
	var/current_tab = "settings"
	var/list/datum/design/matching_designs_protolathe //for the search function
	var/list/datum/design/matching_designs_imprinter
	var/list/datum/design/cat_designs_protolathe
	var/list/datum/design/cat_designs_imprinter
	var/disk_slot_selected = 0
	var/datum/techweb_node/selected_node
	var/datum/design/selected_design
	var/locked = FALSE

/proc/CallMaterialName(ID)
	if (copytext(ID, 1, 2) == "$" && GLOB.materials_list[ID])
		var/datum/material/material = GLOB.materials_list[ID]
		return material.name

	else if(GLOB.chemical_reagents_list[ID])
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[ID]
		return reagent.name
	return "ERROR: Report This"

/obj/machinery/computer/rdconsole/proc/SyncRDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any).
	for(var/obj/machinery/rnd/D in oview(3,src))
		if(D.linked_console != null || D.disabled || D.panel_open)
			continue
		if(istype(D, /obj/machinery/rnd/destructive_analyzer))
			if(linked_destroy == null)
				linked_destroy = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/rnd/protolathe))
			if(linked_lathe == null)
				linked_lathe = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/rnd/circuit_imprinter))
			if(linked_imprinter == null)
				linked_imprinter = D
				D.linked_console = src

/obj/machinery/computer/rdconsole/Initialize()
	. = ..()
	stored_research = SSresearch.science_tech
	stored_research.consoles_accessing[src] = TRUE
	matching_designs_imprinter = list()
	matching_designs_protolathe = list()
	cat_designs_protolathe = list()
	cat_designs_imprinter = list()
	SyncRDevices()

/obj/machinery/computer/rdconsole/Destroy()
	if(stored_research)
		stored_research.consoles_accessing -= src
	matching_designs_protolathe = null
	matching_designs_imprinter = null
	cat_designs_protolathe = null
	cat_designs_imprinter = null
	if(linked_destroy)
		linked_destroy.linked_console = null
		linked_destroy = null
	if(linked_lathe)
		linked_lathe.linked_console = null
		linked_lathe = null
	if(linked_imprinter)
		linked_imprinter.linked_console = null
		linked_imprinter = null
	if(t_disk)
		t_disk.forceMove(get_turf(src))
		t_disk = null
	if(d_disk)
		d_disk.forceMove(get_turf(src))
		d_disk = null
	selected_node = null
	selected_design = null
	return ..()

/obj/machinery/computer/rdconsole/attackby(obj/item/weapon/D, mob/user, params)

	//Loading a disk into it.
	if(istype(D, /obj/item/weapon/disk))
		if(t_disk || d_disk)
			to_chat(user, "A disk is already loaded into the machine.")
			return

		if(istype(D, /obj/item/weapon/disk/tech_disk))
			t_disk = D
		else if (istype(D, /obj/item/weapon/disk/design_disk))
			d_disk = D
		else
			to_chat(user, "<span class='danger'>Machine cannot accept disks in that format.</span>")
			return
		if(!user.drop_item())
			return
		D.loc = src
		to_chat(user, "<span class='notice'>You add the disk to the machine!</span>")
	else if(!(linked_destroy && linked_destroy.busy) && !(linked_lathe && linked_lathe.busy) && !(linked_imprinter && linked_imprinter.busy))
		. = ..()
	updateUsrDialog()

/obj/machinery/computer/rdconsole/proc/research_node(id, mob/user)
	CRASH("RESEARCH NODE NOT CODED!")

/obj/machinery/computer/rdconsole/on_deconstruction()
	if(linked_destroy)
		linked_destroy.linked_console = null
		linked_destroy = null
	if(linked_lathe)
		linked_lathe.linked_console = null
		linked_lathe = null
	if(linked_imprinter)
		linked_imprinter.linked_console = null
		linked_imprinter = null
	..()


/obj/machinery/computer/rdconsole/emag_act(mob/user)
	if(!emagged)
		playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
		emagged = TRUE
		to_chat(user, "<span class='notice'>You disable the security protocols</span>")

/*

	if(href_list["disk_slot"])
		disk_slot_selected = text2num(href_list["disk_slot"])

	else if(href_list["updt_tech"]) //Update the research holder with information from the technology disk.
		screen = SCICONSOLE_UPDATE_DATABASE
		var/wait = 50
		spawn(wait)
			screen = SCICONSOLE_TDISK
			if(t_disk)
				t_disk.stored_research.copy_research_to(stored_research)
				updateUsrDialog()
	else if(href_list["clear_tech"]) //Erase data on the technology disk.
		if(t_disk)
			qdel(t_disk.stored_research)
			t_disk.stored_research = new
	else if(href_list["eject_tech"]) //Eject the technology disk.
		if(t_disk)
			t_disk.loc = src.loc
			t_disk = null
		screen = SCICONSOLE_MENU

	else if(href_list["copy_tech"]) //Copy some technology data from the research holder to the disk.
		stored_research.copy_research_to(t_disk.stored_research)
		screen = SCICONSOLE_TDISK
	else if(href_list["updt_design"]) //Updates the research holder with design data from the design disk.
		var/n = text2num(href_list["updt_design"])
		screen = SCICONSOLE_UPDATE_DATABASE
		var/wait = 50
		if(!n)
			wait = 0
			for(var/D in d_disk.blueprints)
				if(D)
					wait += 50
		spawn(wait)
			screen = SCICONSOLE_DDISK
			if(d_disk)
				if(!n)
					for(var/D in d_disk.blueprints)
						if(D)
							stored_research.add_design(D)
				else
					stored_research.add_design(d_disk.blueprints[n])
				updateUsrDialog()

	else if(href_list["clear_design"]) //Erases data on the design disk.
		if(d_disk)
			var/n = text2num(href_list["clear_design"])
			if(!n)
				for(var/i in 1 to d_disk.max_blueprints)
					d_disk.blueprints[i] = null
			else
				d_disk.blueprints[n] = null

	else if(href_list["eject_design"]) //Eject the design disk.
		if(d_disk)
			d_disk.loc = src.loc
			d_disk = null
		screen = SCICONSOLE_MENU

	else if(href_list["copy_design"]) //Copy design data from the research holder to the design disk.
		var/slot = text2num(href_list["copy_design"])
		var/datum/design/D = stored_research.researched_designs[href_list["copy_design_ID"]]
		if(D)
			var/autolathe_friendly = 1
			if(D.reagents_list.len)
				autolathe_friendly = 0
				D.category -= "Imported"
			else
				for(var/x in D.materials)
					if( !(x in list(MAT_METAL, MAT_GLASS)))
						autolathe_friendly = 0
						D.category -= "Imported"

			if(D.build_type & (AUTOLATHE|PROTOLATHE|CRAFTLATHE)) // Specifically excludes circuit imprinter and mechfab
				D.build_type = autolathe_friendly ? (D.build_type | AUTOLATHE) : D.build_type
				D.category |= "Imported"
			d_disk.blueprints[slot] = D
		screen = SCICONSOLE_DDISK

	else if(href_list["eject_item"]) //Eject the item inside the destructive analyzer.
		if(linked_destroy)
			if(linked_destroy.busy)
				to_chat(usr, "<span class='danger'>The destructive analyzer is busy at the moment.</span>")

			else if(linked_destroy.loaded_item)
				linked_destroy.loaded_item.forceMove(linked_destroy.loc)
				linked_destroy.loaded_item = null
				linked_destroy.icon_state = "d_analyzer"
				screen = SCICONSOLE_MENU

	else if(href_list["build"]) //Causes the Protolathe to build something.
		var/datum/design/being_built = stored_research.researched_designs[href_list["build"]]
		var/amount = text2num(href_list["amount"])

		if(being_built.make_reagents.len)
			return FALSE

		if(!linked_lathe || !being_built || !amount)
			updateUsrDialog()
			return

		if(linked_lathe.busy)
			to_chat(usr, "<span class='danger'>Protolathe is busy at the moment.</span>")
			return

		var/coeff = linked_lathe.efficiency_coeff
		var/power = 1000
		var/old_screen = screen

		amount = max(1, min(10, amount))
		for(var/M in being_built.materials)
			power += round(being_built.materials[M] * amount / 5)
		power = max(3000, power)
		screen = SCICONSOLE_UPDATE_PROTOLATHE
		var/key = usr.key	//so we don't lose the info during the spawn delay
		if (!(being_built.build_type & PROTOLATHE))
			message_admins("Protolathe exploit attempted by [key_name(usr, usr.client)]!")
			updateUsrDialog()
			return

		var/g2g = 1
		var/enough_materials = 1
		linked_lathe.busy = TRUE
		flick("protolathe_n",linked_lathe)
		use_power(power)

		var/list/efficient_mats = list()
		for(var/MAT in being_built.materials)
			efficient_mats[MAT] = being_built.materials[MAT]*coeff

		if(!linked_lathe.materials.has_materials(efficient_mats, amount))
			linked_lathe.say("Not enough materials to complete prototype.")
			enough_materials = 0
			g2g = 0
		else
			for(var/R in being_built.reagents_list)
				if(!linked_lathe.reagents.has_reagent(R, being_built.reagents_list[R]*coeff))
					linked_lathe.say("Not enough reagents to complete prototype.")
					enough_materials = 0
					g2g = 0

		if(enough_materials)
			linked_lathe.materials.use_amount(efficient_mats, amount)
			for(var/R in being_built.reagents_list)
				linked_lathe.reagents.remove_reagent(R, being_built.reagents_list[R]*coeff)

		var/P = being_built.build_path //lets save these values before the spawn() just in case. Nobody likes runtimes.

		coeff *= being_built.lathe_time_factor

		spawn(32*coeff*amount**0.8)
			if(linked_lathe)
				if(g2g) //And if we only fail the material requirements, we still spend time and power
					var/already_logged = 0
					for(var/i = 0, i<amount, i++)
						var/obj/item/new_item = new P(src)
						if( new_item.type == /obj/item/weapon/storage/backpack/holding )
							new_item.investigate_log("built by [key]", INVESTIGATE_SINGULO)
						if(!istype(new_item, /obj/item/stack/sheet) && !istype(new_item, /obj/item/weapon/ore/bluespace_crystal)) // To avoid materials dupe glitches
							new_item.materials = efficient_mats.Copy()
						new_item.loc = linked_lathe.loc
						if(!already_logged)
							SSblackbox.add_details("item_printed","[new_item.type]|[amount]")
							already_logged = 1
				screen = old_screen
				linked_lathe.busy = FALSE
			else
				say("Protolathe connection failed. Production halted.")
				screen = SCICONSOLE_MENU
			updateUsrDialog()

	else if(href_list["imprint"]) //Causes the Circuit Imprinter to build something.
		var/datum/design/being_built = stored_research.researched_designs[href_list["imprint"]]

		if(!linked_imprinter || !being_built)
			updateUsrDialog()
			return

		if(linked_imprinter.busy)
			to_chat(usr, "<span class='danger'>Circuit Imprinter is busy at the moment.</span>")
			updateUsrDialog()
			return

		var/coeff = linked_imprinter.efficiency_coeff

		var/power = 1000
		var/old_screen = screen
		for(var/M in being_built.materials)
			power += round(being_built.materials[M] / 5)
		power = max(4000, power)
		screen = SCICONSOLE_UPDATE_CIRCUIT
		if (!(being_built.build_type & IMPRINTER))
			message_admins("Circuit imprinter exploit attempted by [key_name(usr, usr.client)]!")
			updateUsrDialog()
			return

		var/g2g = 1
		var/enough_materials = 1
		linked_imprinter.busy = TRUE
		flick("circuit_imprinter_ani", linked_imprinter)
		use_power(power)

		var/list/efficient_mats = list()
		for(var/MAT in being_built.materials)
			efficient_mats[MAT] = being_built.materials[MAT]/coeff

		if(!linked_imprinter.materials.has_materials(efficient_mats))
			linked_imprinter.say("Not enough materials to complete prototype.")
			enough_materials = 0
			g2g = 0
		else
			for(var/R in being_built.reagents_list)
				if(!linked_imprinter.reagents.has_reagent(R, being_built.reagents_list[R]/coeff))
					linked_imprinter.say("Not enough reagents to complete prototype.")
					enough_materials = 0
					g2g = 0

		if(enough_materials)
			linked_imprinter.materials.use_amount(efficient_mats)
			for(var/R in being_built.reagents_list)
				linked_imprinter.reagents.remove_reagent(R, being_built.reagents_list[R]/coeff)

		var/P = being_built.build_path //lets save these values before the spawn() just in case. Nobody likes runtimes.
		spawn(16)
			if(linked_imprinter)
				if(g2g)
					var/obj/item/new_item = new P(src)
					new_item.loc = linked_imprinter.loc
					new_item.materials = efficient_mats.Copy()
					SSblackbox.add_details("circuit_printed","[new_item.type]")
				screen = old_screen
				linked_imprinter.busy = FALSE
			else
				say("Circuit Imprinter connection failed. Production halted.")
				screen = SCICONSOLE_MENU
			updateUsrDialog()

////////////////////////////////////////////////////////////	switch(screen)
		//////////////////////R&D CONSOLE SCREENS//////////////////
		if(SCICONSOLE_UPDATE_DATABASE)
			dat += "<div class='statusDisplay'>Processing and Updating Database...</div>"
		if(SCICONSOLE_UPDATE_PROTOLATHE)
			dat += "<div class='statusDisplay'>Constructing Prototype. Please Wait...</div>"
		if(SCICONSOLE_UPDATE_CIRCUIT)
			dat += "<div class='statusDisplay'>Imprinting Circuit. Please Wait...</div>"
			dat += "</div>"
		if(SCICONSOLE_TDISK) //Technology Disk Menu
			dat += SCICONSOLE_HEADER
			dat += "Disk Operations: <A href='?src=\ref[src];clear_tech=0'>Clear Disk</A>"
			dat += "<A href='?src=\ref[src];eject_tech=1'>Eject Disk</A>"
			dat += "<A href='?src=\ref[src];updt_tech=0'>Upload All</A>"
			dat += "<A href='?src=\ref[src];copy_tech=1'>Load Technology to Disk</A>"
			dat += "<div class='statusDisplay'><h3>Stored Technology Nodes:</h3>"
			for(var/i in t_disk.stored_research.researched_nodes)
				var/datum/techweb_node/N = t_disk.stored_research.researched_nodes[i]
				dat += "<A href='?src=\ref[src];view_node=[i];back_screen=[screen]'>[N.display_name]</A>"
			dat += "</div>"

		if(SCICONSOLE_DDISK) //Design Disk menu.
			dat += SCICONSOLE_HEADER
			dat += "Disk Operations: <A href='?src=\ref[src];clear_design=0'>Clear Disk</A><A href='?src=\ref[src];updt_design=0'>Upload All</A><A href='?src=\ref[src];eject_design=1'>Eject Disk</A>"
			for(var/i in 1 to d_disk.max_blueprints)
				dat += "<div class='statusDisplay'>"
				if(d_disk.blueprints[i])
					var/datum/design/D = d_disk.blueprints[i]
					dat += "<A href='?src=\ref[src];view_design=[D.id]'>[D.name]</A>"
					dat += "Operations: <A href='?src=\ref[src];updt_design=[i]'>Upload to Database</A> <A href='?src=\ref[src];clear_design=[i]'>Clear Slot</A>"
				else
					dat += "Empty SlotOperations: <A href='?src=\ref[src];menu=[SCICONSOLE_DDISKL];disk_slot=[i]'>Load Design to Slot</A>"
				dat += "</div>"
		if(SCICONSOLE_DDISKL) //Design disk submenu
			dat += SCICONSOLE_HEADER
			dat += "<A href='?src=\ref[src];menu=[SCICONSOLE_DDISK];back_screen=[screen]'>Return to Disk Operations</A><div class='statusDisplay'>"
			dat += "<h3>Load Design to Disk:</h3>"
			for(var/v in stored_research.researched_designs)
				var/datum/design/D = stored_research.researched_designs[v]
				dat += "[D.name] "
				dat += "<A href='?src=\ref[src];copy_design=[disk_slot_selected];copy_design_ID=[D.id]'>Copy to Disk</A>"
			dat += "</div>"

		////////////////////DESTRUCTIVE ANALYZER SCREENS////////////////////////////

		if(SCICONSOLE_DA_UNLOADED)
			dat += SCICONSOLE_HEADER
			dat += "<div class='statusDisplay'>No Item Loaded. Standing-by...</div>"

		if(SCICONSOLE_DA_LOADED)
			dat += SCICONSOLE_HEADER
			dat += "<div class='statusDisplay'><h3>Deconstruction Menu</h3>"
			dat += "<A href='?src=\ref[src];eject_item=1'>Eject Item</A>"
			dat += "Name: [linked_destroy.loaded_item.name]"
			dat += "Select a node to boost by deconstructing this item."
			dat += "This item is able to boost:"
			var/list/input = techweb_item_boost_check(linked_destroy.loaded_item)
			for(var/datum/techweb_node/N in input)
				if(!stored_research.researched_nodes[N] && !stored_research.boosted_nodes[N])
					dat += "<A href='?src=\ref[src];deconstruct=[N.id]'>[N.display_name]: [input[N]] points</A>"
				else
					dat += "<span class='linkOff>[N.display_name]: [input[N]] points</span>"

*/
/obj/machinery/computer/rdconsole/ui_data(mob/user)
	var/list/data = list()
	//Tabs
	data["tabs"] = list("Technology", "View Node", "View Design", "Disk Operations", "Deconstructive Analyzer", "Protolathe", "Circuit Imprinter", "Settings")
	//Locking
	data["locked"] = locked
	//General Access
	data["research_points_stored"] = stored_research.research_points
	data["protolathe_linked"] = linked_lathe? TRUE : FALSE
	data["circuit_linked"] = linked_imprinter? TRUE : FALSE
	data["destroy_linked"] = linked_destroy? TRUE : FALSE
	data["node_selected"] = selected_node? TRUE : FALSE
	data["design_selected"] = selected_design? TRUE : FALSE
	//Techweb
	var/list/techweb_avail = list()
	var/list/techweb_locked = list()
	var/list/techweb_researched = list()
	for(var/id in stored_research.available_nodes)
		var/datum/techweb_node/N = stored_research.available_nodes[id]
		techweb_avail += list(list("id" = N.id, "display_name" = N.display_name))
	for(var/id in stored_research.visible_nodes)
		var/datum/techweb_node/N = stored_research.visible_nodes[id]
		techweb_locked += list(list("id" = N.id, "display_name" = N.display_name))
	for(var/id in stored_research.researched_nodes)
		var/datum/techweb_node/N = stored_research.researched_nodes[id]
		techweb_researched += list(list("id" = N.id, "display_name" = N.display_name))
	data["techweb_avail"] = techweb_avail
	data["techweb_locked"] = techweb_locked
	data["techweb_researched"] = techweb_researched
	//Node View
	if(selected_node)
		data["snode_name"] = selected_node.display_name
		data["snode_id"] = selected_node.id
		data["snode_researched"] = stored_research.researched_nodes[selected_node.id]? TRUE : FALSE
		data["snode_cost"] = selected_node.get_price(stored_research)
		data["snode_export"] = selected_node.export_price
		data["snode_desc"] = selected_node.description
		var/list/prereqs = list()
		var/list/unlocks = list()
		var/list/designs = list()
		for(var/id in selected_node.prerequisites)
			var/datum/techweb_node/N = selected_node.prerequisites[id]
			prereqs += list(list("id" = N.id, "display_name" = N.display_name))
		for(var/id in selected_node.unlocks)
			var/datum/techweb_node/N = selected_node.unlocks[id]
			unlocks += list(list("id" = N.id, "display_name" = N.display_name))
		for(var/id in selected_node.designs)
			var/datum/design/D = selected_node.designs[id]
			designs += list(list("id" = D.id, "name" = D.name))
		data["node_prereqs"] = prereqs
		data["node_unlocks"] = unlocks
		data["node_designs"] = designs
	//Design View
	if(selected_design)
		data["sdesign_id"] = selected_design.id
		data["sdesign_name"] = selected_design.name
		data["sdesign_desc"] = selected_design.desc
		data["sdesign_buildtype"] = selected_design.build_type
		data["sdesign_mats"] = list()
		for(var/M in selected_design.materials)
			data["sdesign_mats"]["[CallMaterialName(M)]"] = selected_design.materials[M]
	//Both Lathes
	data["lathe_tabs"] = list("Category List", "Selected Category", "Search Results", "Materials", "Chemicals")
	//Protolathe
	if(linked_lathe)
		data["protobusy"] = linked_lathe.busy? TRUE : FALSE
		data["protocats"] = list()
		for(var/v in linked_lathe.categories)
			data["protocats"] += list(list("name" = v))
		data["protomats"] = "[linked_lathe.materials.total_amount]"
		data["protomaxmats"] = "[linked_lathe.materials.max_amount]"
		data["protochems"] = "[linked_lathe.reagents.total_volume]"
		data["protomaxchems"] = "[linked_lathe.reagents.maximum_volume]"
		data["protodes"] = list()
		for(var/v in cat_designs_protolathe)
			var/datum/design/D = cat_designs_protolathe[v]
			data["protodes"] += list(list("name" = D.name, "id" = D.id, "canprint" = check_canprint(D, PROTOLATHE), "matstring" = get_actual_mat_string(D, PROTOLATHE)))
		data["protomatch"] = list()
		for(var/v in matching_designs_protolathe)
			var/datum/design/D = matching_designs_protolathe[v]
			data["protomatch"] += list(list("name" = D.name, "id" = D.id, "canprint" = check_canprint(D, PROTOLATHE), "matstring" = get_actual_mat_string(D, PROTOLATHE)))
		data["protomat_list"] = list()
		for(var/m in linked_lathe.materials.materials)
			var/datum/material/M = linked_lathe.materials.materials[m]
			var/sheets = Floor(M.amount/MINERAL_MATERIAL_AMOUNT)
			data["protomat_list"] += list(list("name" = M.name, "amount" = M.amount, "sheets" = sheets, "mat_id" = m))
		data["protochem_list"] = list()
		for(var/datum/reagent/R in linked_lathe.reagents.reagent_list)
			data["protochem_list"] += list(list("name" = R.name, "amount" = R.volume, "reagentid" = R.id))
	//Circuit Imprinter
	if(linked_imprinter)
		data["circuitbusy"] = linked_imprinter.busy? TRUE : FALSE
		data["circuitcats"] = list()
		for(var/v in linked_lathe.categories)
			data["circuitcats"] += list(list("name" = v))
		data["circuitmats"] = "[linked_imprinter.materials.total_amount]"
		data["circuitmaxmats"] = "[linked_imprinter.materials.max_amount]"
		data["circuitchems"] = "[linked_imprinter.reagents.total_volume]"
		data["circuitmaxchems"] = "[linked_imprinter.reagents.maximum_volume]"
		data["imprintdes"] = list()
		for(var/v in cat_designs_imprinter)
			var/datum/design/D = cat_designs_imprinter[v]
			data["imprintdes"] += list(list("name" = D.name, "id" = D.id, "canprint" = check_canprint(D, PROTOLATHE), "matstring" = get_actual_mat_string(D, PROTOLATHE)))
		data["imprintmatch"] = list()
		for(var/v in matching_designs_imprinter)
			var/datum/design/D = matching_designs_protolathe[v]
			data["imprintmatch"] += list(list("name" = D.name, "id" = D.id, "canprint" = check_canprint(D, IMPRINTER), "matstring" = get_actual_mat_string(D, IMPRINTER)))
		data["circuitmat_list"] = list()
		for(var/m in linked_imprinter.materials.materials)
			var/datum/material/M = linked_imprinter.materials.materials[m]
			var/sheets = Floor(M.amount/MINERAL_MATERIAL_AMOUNT)
			data["circuitmat_list"] += list(list("name" = M.name, "amount" = M.amount, "sheets" = sheets, "mat_id" = m))
		data["circuitchem_list"] = list()
		for(var/datum/reagent/R in linked_imprinter.reagents.reagent_list)
			data["circuitchem_list"] += list(list("name" = R.name, "amount" = R.volume, "reagentid" = R.id))
	if(linked_destroy)
		data["destroybusy"] = linked_destroy.busy? TRUE : FALSE
		data["destroy_loaded"] = linked_destroy.loaded_item? TRUE : FALSE
		if(linked_destroy.loaded_item)
			data["destroy_name"] = linked_destroy.loaded_item.name
			data["boost_paths"] = list()
			var/list/input = techweb_item_boost_check(linked_destroy.loaded_item)	//Node datum = value
			for(var/v in input)
				var/datum/techweb_node/TN = v
				var/boost = input[v]
				var/can_boost = stored_research.boosted_nodes[TN]? FALSE : TRUE
				data["boost_paths"] += list(list("name" = TN.display_name, "value" = boost, "allow" = can_boost, "id" = TN.id))
	/*
	//Disk Operations
	*/


	return data

/obj/machinery/computer/rdconsole/ui_act(action, params)
	if(..())
		return
	var/list/l = params
	to_chat(usr, "<span class='boldnotice'>DEBUG: Interact with action [action] and params: \"[list2params(params)]\"</span>")
	switch(action)
		if("select_node")
			selected_node = SSresearch.techweb_nodes[params["id"]]
		if("select_design")
			selected_design = SSresearch.techweb_designs[params["id"]]
		if("research_node")
			research_node(params["id"], usr)
		if("Lock")
			if(allowed(usr))
				lock_console(usr)
			else
				to_chat(usr, "<span class='boldwarning'>Unauthorized Access.</span>")
		if("Unlock")
			if(allowed(usr))
				unlock_console(usr)
			else
				to_chat(usr, "<span class='boldwarning'>Unauthorized Access.</span>")
		if("Resync")
			to_chat(usr, "<span class='boldnotice'>[bicon(src)]: Resynced with nearby machinery.</span>")
		if("textSearch")
			var/text = params["latheType"]
			var/compare
			if(text == "proto")
				compare = PROTOLATHE
			else if(text == "imprinter")
				compare = IMPRINTER
			else
				return
			var/list/operating = compare == PROTOLATHE? matching_designs_protolathe : matching_designs_imprinter
			operating.Cut()
			for(var/v in stored_research.researched_designs)
				var/datum/design/D = stored_research.researched_designs[v]
				if(!(D.build_type & compare))
					continue
				if(findtext(D.name, text))
					operating[D.id] = D
		if("switchcat")
			if(type == "proto")
				category_lathe = params["cat"]
			else if(type == "imprinter")
				category_imprinter = params["cat"]
			else
				return
			rescan_category_views()
		if("releasemats")
			if(type == "proto")
				linked_lathe.materials.retrieve_sheets(text2num(params["sheets"]), params["mat_id"])
			else if(type == "imprinter")
				linked_imprinter.materials.retrieve_sheets(text2num(params["sheets"]), params["mat_id"])
			else
				return
		if("purgechem")
			if(type == "proto")
				linked_lathe.reagents.del_reagent(params["id"])
			else if(type == "imprinter")
				linked_lathe.reagents.del_reagent(params["id"])
			else
				return
		if("disconnect")
			switch(params["type"])
				if("destroy")
					linked_destroy.linked_console = null
					linked_destroy = null
				if("lathe")
					linked_lathe.linked_console = null
					linked_lathe = null
				if("imprinter")
					linked_imprinter.linked_console = null
					linked_imprinter = null
				else
					return
		if("eject_da")
			linked_destroy.unload_item()
		if("deconstruct")
			linked_destroy.user_try_decon_id(params["id"])
		if("print")
			if(params["latheType"] == "proto")
				linked_lathe.user_try_print_id(params["id"], params["amount"])
			if(params["latheType"] == "circuit")
				linked_imprinter.user_try_print_id(params["id"])
			else
				return

/obj/machinery/computer/rdconsole/proc/rescan_category_views()
	cat_designs_protolathe = list()
	cat_designs_imprinter = list()
	for(var/v in stored_research.researched_designs)
		var/datum/design/D = stored_research.researched_designs[v]
		if((D.build_type & PROTOLATHE) && (category_lathe in D.category))
			cat_designs_protolathe[D.id] = D
		if((D.build_type & IMPRINTER) && (category_imprinter in D.category))
			cat_designs_imprinter[D.id] = D

/obj/machinery/computer/rdconsole/proc/get_actual_mat_string(datum/design/D, buildtype)
	. = ""
	var/all_materials = D.materials + D.reagents_list
	if(buildtype == IMPRINTER)
		if(!linked_imprinter)
			return FALSE
		for(var/M in all_materials)
			. += " | "
			. += " <span class='[linked_imprinter.check_mat(D, M)? "" : "bad"]'>[all_materials[M]/linked_lathe.efficiency_coeff] [CallMaterialName(M)]</span>"
	else if(buildtype == PROTOLATHE)
		if(!linked_lathe)
			return FALSE
		for(var/M in all_materials)
			. += " | "
			. += " <span class='[linked_lathe.check_mat(D, M)? "" : "bad"]'>[all_materials[M]/linked_lathe.efficiency_coeff] [CallMaterialName(M)]</span>"

/obj/machinery/computer/rdconsole/proc/check_canprint(datum/design/D, buildtype)
	var/amount = 50
	if(buildtype == IMPRINTER)
		if(!linked_imprinter)
			return FALSE
		for(var/M in D.materials + D.reagents_list)
			amount = min(amount, linked_imprinter.check_mat(D, M))
			if(amount < 1)
				return FALSE
	else if(buildtype == PROTOLATHE)
		if(!linked_lathe)
			return FALSE
		for(var/M in D.materials + D.reagents_list)
			amount = min(amount, linked_lathe.check_mat(D, M))
			if(amount < 1)
				return FALSE
	else
		return FALSE
	return amount

/obj/machinery/computer/rdconsole/proc/lock_console(mob/user)
	locked = TRUE

/obj/machinery/computer/rdconsole/proc/unlock_console(mob/user)
	locked = FALSE

/obj/machinery/computer/rdconsole/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "rdconsole_primary", "Research and Development", 880, 880, master_ui, state)
		ui.open()

//helper proc, which return a table containing categories
/obj/machinery/computer/rdconsole/proc/list_categories(list/categories, menu_num as num)
	if(!categories)
		return

	var/line_length = 1
	var/dat = "<table style='width:100%' align='center'><tr>"

	for(var/C in categories)
		if(line_length > 2)
			dat += "</tr><tr>"
			line_length = 1

		dat += "<td><A href='?src=\ref[src];category=[C];menu=[menu_num]'>[C]</A></td>"
		line_length++

	dat += "</tr></table></div>"
	return dat

/obj/machinery/computer/rdconsole/robotics
	name = "Robotics R&D Console"
	desc = "A console used to interface with R&D tools."
	req_access = null
	req_access_txt = "29"

/obj/machinery/computer/rdconsole/robotics/Initialize()
	. = ..()
	if(circuit)
		circuit.name = "R&D Console - Robotics (Computer Board)"
		circuit.build_path = /obj/machinery/computer/rdconsole/robotics

/obj/machinery/computer/rdconsole/core
	name = "Core R&D Console"
	desc = "A console used to interface with R&D tools."

/obj/machinery/computer/rdconsole/experiment
	name = "E.X.P.E.R.I-MENTOR R&D Console"
	desc = "A console used to interface with R&D tools."
