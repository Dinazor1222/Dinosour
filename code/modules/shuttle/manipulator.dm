/obj/machinery/shuttle_manipulator
	name = "shuttle manipulator"
	desc = "I shall be telling this with a sigh\n\
		Somewhere ages and ages hence:\n\
		Two roads diverged in a wood, and I,\n\
		I took the one less traveled by,\n\
		And that has made all the difference."

	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator-blue"

/obj/machinery/shuttle_manipulator/process()
	return

/obj/machinery/shuttle_manipulator/ui_interact(mob/user, ui_key = "main", \
	datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, \
	datum/ui_state/state = admin_state)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "shuttle_manipulator", name, 800, 600, \
			master_ui, state)
		ui.open()

/proc/shuttlemode2str(mode)
	switch(mode)
		if(SHUTTLE_IDLE)
			. = "idle"
		if(SHUTTLE_RECALL)
			. = "recalled"
		if(SHUTTLE_CALL)
			. = "called"
		if(SHUTTLE_DOCKED)
			. = "docked"
		if(SHUTTLE_STRANDED)
			. = "stranded"
		if(SHUTTLE_ENDGAME)
			. = "endgame"
	if(!.)
		throw EXCEPTION("shuttlemode2str(): invalid mode [mode]")

/obj/machinery/shuttle_manipulator/ui_data(mob/user)
	var/list/data = list()
	data["tabs"] = list("Status", "Templates", "Modification")

	// Status panel
	data["shuttles"] = list()
	for(var/i in SSshuttle.mobile)
		var/obj/docking_port/mobile/M = i
		var/list/L = list()
		L["name"] = M.name
		L["id"] = M.id
		L["timer"] = M.timer
		L["timeleft"] = M.getTimerStr()
		L["mode"] = capitalize(shuttlemode2str(M.mode))
		L["status"] = M.getStatusText()
		data["shuttles"] += list(L)

	// Templates panel
	data["templates"] = list()
	var/list/templates = data["templates"]
	data["templates_tabs"] = list()

	for(var/name in shuttle_templates)
		var/datum/map_template/shuttle/S = shuttle_templates[name]

		if(!templates[S.port_id])
			data["templates_tabs"] += S.port_id
			templates[S.port_id] = list(
				"port_id" = S.port_id,
				"templates" = list())
		
		var/list/L = list()
		L["name"] = S.name
		L["id"] = S.port_id
		L["description"] = S.description
		L["admin_notes"] = S.admin_notes

		templates[S.port_id]["templates"] += list(L)

	data["templates_tabs"] = sortList(data["templates_tabs"])

	// Modification panel
	// should be disabled unless we are doing something?
	data["modification"] = FALSE
	// Show current proposal
	// PREVIEW button to load
	// CANCEL button to (unload if loaded) and return back
	// LOAD button

	// Multiple stage notifications
	// - loaded
	// - removed old shuttle
	// - moved new shuttle to old location

	//world.log << json_encode(data)
	return data

/obj/machinery/my_machine/ui_act(action, params)
	if(..())
		return
/*
	switch(action)
		if("change_color")
			var/new_color = params["color"]
			if(!(color in allowed_coors))
				return
			color = new_color
			. = TRUE
*/
	update_icon()
