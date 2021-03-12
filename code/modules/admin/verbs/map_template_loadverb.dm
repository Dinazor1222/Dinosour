/client/proc/map_template_load()
	set category = "Debug"
	set name = "Map template - Place"

	var/datum/map_template/template

	var/map = input(src, "Choose a Map Template to place at your CURRENT LOCATION","Place Map Template") as null|anything in sortList(SSmapping.map_templates)
	if(!map)
		return
	template = SSmapping.map_templates[map]

	var/turf/T = get_turf(mob)
	if(!T)
		return

	var/list/preview = list()
	var/center
	var/centeralert = alert(src,"Center Template.","Template Centering","Yes","No")
	switch(centeralert)
		if("Yes")
			center = TRUE
		if("No")
			center = FALSE
		else
			return
	for(var/S in template.get_affected_turfs(T,centered = center))
		var/image/item = image('icons/turf/overlays.dmi',S,"greenOverlay")
		item.plane = ABOVE_LIGHTING_PLANE
		preview += item
	images += preview
	if(alert(src,"Confirm location.","Template Confirm","Yes","No") == "Yes")
		if(template.load(T, centered = TRUE))
			var/affected = template.get_affected_turfs(T, centered = center)
			for(var/AT in affected)
				for(var/obj/docking_port/mobile/P in AT)
					if(istype(P, /obj/docking_port/mobile))
						template.post_load(P)
						break

			message_admins("<span class='adminnotice'>[key_name_admin(src)] has placed a map template ([template.name]) at [ADMIN_COORDJMP(T)]</span>")
		else
			to_chat(src, "Failed to place map", confidential = TRUE)
	images -= preview

/client/proc/map_template_upload()
	set category = "Debug"
	set name = "Map Template - Upload"

	var/map = input(src, "Choose a Map Template to upload to template storage","Upload Map Template") as null|file
	if(!map)
		return
	if(copytext("[map]", -4) != ".dmm")//4 == length(".dmm")
		to_chat(src, "<span class='warning'>Filename must end in '.dmm': [map]</span>", confidential = TRUE)
		return
	var/datum/map_template/M
	switch(alert(src, "What kind of map is this?", "Map type", "Normal", "Shuttle", "Cancel"))
		if("Normal")
			M = new /datum/map_template(map, "[map]", TRUE)
		if("Shuttle")
			M = new /datum/map_template/shuttle(map, "[map]", TRUE)
		else
			return
	if(!M.cached_map)
		to_chat(src, "<span class='warning'>Map template '[map]' failed to parse properly.</span>", confidential = TRUE)
		return

	var/datum/map_report/report = M.cached_map.check_for_errors()
	var/report_link
	if(report)
		report.show_to(src)
		report_link = " - <a href='?src=[REF(report)];[HrefToken(TRUE)];show=1'>validation report</a>"
		to_chat(src, "<span class='warning'>Map template '[map]' <a href='?src=[REF(report)];[HrefToken()];show=1'>failed validation</a>.</span>", confidential = TRUE)
		if(report.loadable)
			var/response = alert(src, "The map failed validation, would you like to load it anyways?", "Map Errors", "Cancel", "Upload Anyways")
			if(response != "Upload Anyways")
				return
		else
			alert(src, "The map failed validation and cannot be loaded.", "Map Errors", "Oh Darn")
			return

	SSmapping.map_templates[M.name] = M
	message_admins("<span class='adminnotice'>[key_name_admin(src)] has uploaded a map template '[map]' ([M.width]x[M.height])[report_link].</span>")
	to_chat(src, "<span class='notice'>Map template '[map]' ready to place ([M.width]x[M.height])</span>", confidential = TRUE)
