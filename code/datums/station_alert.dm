/datum/station_alert
    /// Holder of the datum
    var/holder
    /// List of all alarm types we are listening to
    var/list/alarm_types
    /// Listens for alarms, provides the alarms list for our UI
    var/datum/alarm_listener/listener
    /// Title of our UI
    var/title
	/// If UI will also show and allow jumping to cameras connected to each alert area
    var/camera_view

/datum/station_alert/ui_host(mob/user)
	return holder

/datum/station_alert/New(holder, list/alarm_types, list/listener_z_level, title = "Station Alerts", camera_view = FALSE)
    src.holder = holder
    src.alarm_types = alarm_types
    src.title = title
    src.camera_view = camera_view
    listener = new(alarm_types, listener_z_level)

/datum/station_alert/Destroy()
    QDEL_NULL(listener)
    return ..()

/datum/station_alert/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StationAlertConsole", title)
		ui.open()

/datum/station_alert/ui_data(mob/user)
	var/list/data = list()
	data["cameraView"] = camera_view
	data["alarms"] = list()
	var/list/alarms = listener.alarms
	for(var/alarm_type in alarms)
		var/list/category = list(
			"name" = alarm_type,
			"alerts" = list(),
		)
		var/list/alerts = alarms[alarm_type]
		for(var/alert in alerts)
			var/list/alarm = alerts[alert]
			category["alerts"] += list(list(
				"name" = get_area_name(alarm[1], TRUE),
				"cameras" = camera_view ? length(alarm[2]) : null,
                "sources" = camera_view ? length(alarm[3]) : null,
				"ref" = camera_view ? REF(alert) : null,
			))
		data["alarms"] += list(category)
	return data

/datum/station_alert/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("select_camera")
			var/mob/living/silicon/ai/ai = usr
			if(!istype(ai))
				return

			var/list/alarms = listener.alarms
			var/list/alerts = list()
			for(var/alarm_type in alarms)
				alerts += alarms[alarm_type]

			var/list/our_alert = locate(params["alert"]) in alerts
			var/chosen_alert = alerts[our_alert]
			var/list/cameras = chosen_alert[2]
			var/list/named_cameras = list()
			for(var/obj/machinery/camera/camera in cameras)
				named_cameras[camera.c_tag] = camera

			var/chosen_camera = tgui_input_list(ai, "Choose a camera to jump to", "Camera Selection", named_cameras)
			if(!chosen_camera)
				return
			var/obj/machinery/camera/selected_camera = named_cameras[chosen_camera]
			if(!selected_camera.can_use())
				to_chat(ai, span_warning("Camera is unavailable!"))
				return
			ai.switchCamera(selected_camera)
			return TRUE
