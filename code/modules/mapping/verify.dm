GLOBAL_LIST_EMPTY(map_reports)

/// An error report generated by [/datum/parsed_map/proc/check_for_errors].
/datum/map_report
	var/original_path
	var/list/bad_paths = list()
	var/list/bad_keys = list()
	/// Whether this map can be loaded safely despite the errors.
	var/loadable = TRUE
	var/crashed = TRUE

	var/static/tag_number = 0

/datum/map_report/New(datum/parsed_map/map)
	original_path = map.original_path || "Untitled"
	GLOB.map_reports += src

/datum/map_report/Destroy(force, ...)
	GLOB.map_reports -= src
	return ..()


/// Show a rendered version of this report to a client.
/datum/map_report/proc/show_to(client/C)
	var/list/html = list()
	html += "<p>Report for map file <tt>[original_path]</tt></p>"
	if(crashed)
		html += "<p><b>Validation crashed</b>: check the runtime logs.</p>"
	if(!loadable)
		html += "<p><b>Not loadable</b>: some tiles are missing their turfs or areas.</p>"

	if(bad_paths.len)
		html += "<p>Bad paths: <ol>"
		for(var/path in bad_paths)
			var/list/keys = bad_paths[path]
			html += "<li><tt>[path]</tt>: used in ([keys.len]): <tt>[keys.Join("</tt>, <tt>")]</tt>"
		html += "</ol></p>"

	if(bad_keys.len)
		html += "<p>Bad keys: <ul>"
		for(var/key in bad_keys)
			var/list/messages = bad_keys[key]
			html += "<li><tt>[key]</tt>"
			if(messages.len == 1)
				html += ": [bad_keys[key][1]]"
			else
				html += "<ul><li>[messages.Join("</li><li>")]</li></ul>"
			html += "</li>"
		html += "</ul></p>"
	C << browse(html.Join(), "window=[tag];size=600x400")

/datum/map_report/Topic(href, href_list)
	. = ..()
	if(. || !check_rights(R_ADMIN, FALSE) || !usr.client.holder.CheckAdminHref(href, href_list))
		return

	if (href_list["show"])
		show_to(usr)


/// Check a parsed but not yet loaded map for errors.
///
/// Returns a [/datum/map_report] if there are errors or `FALSE` otherwise.
/datum/parsed_map/proc/check_for_errors()
	var/datum/map_report/report = new(src)
	. = report

	// build_cache will check bad paths for us
	var/list/modelCache = build_cache(TRUE, report.bad_paths)

	var/static/regex/area_or_turf = regex(@"/(turf|area)/")
	for(var/path in report.bad_paths)
		if(area_or_turf.Find("[path]", 1, 1))
			report.loadable = FALSE

	// check for tiles with the wrong number of turfs or areas
	for(var/key in modelCache)
		if(key == SPACE_KEY)
			continue
		var/model = modelCache[key]
		var/list/members = model[1]

		var/turfs = 0
		var/areas = 0
		for(var/i in 1 to members.len)
			var/atom/path = members[i]

			turfs += ispath(path, /turf)
			areas += ispath(path, /area)

		if(turfs == 0)
			report.loadable = FALSE
			LAZYADD(report.bad_keys[key], "no turf")
		else if(turfs > 1)
			LAZYADD(report.bad_keys[key], "[turfs] stacked turfs")

		if(areas != 1)
			report.loadable = FALSE
			LAZYADD(report.bad_keys[key], "[areas] areas instead of 1")

	// return the report
	if(report.bad_paths.len || report.bad_keys.len || !report.loadable)
		// keep the report around so it can be referenced later
		report.tag = "mapreport_[++report.tag_number]"
		report.crashed = FALSE
	else
		return FALSE
