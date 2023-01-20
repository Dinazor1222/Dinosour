#define COMP_SECURITY_ARREST_AMOUNT_TO_FLAG 10
#define PRINTOUT_MISSING "Missing"
#define PRINTOUT_RAPSHEET "Rapsheet"
#define PRINTOUT_WANTED "Wanted"

/obj/machinery/computer/secure_data//TODO:SANITY
	name = "security records console"
	desc = "Used to view and edit personnel's security records."
	icon_screen = "security"
	icon_keyboard = "security_key"
	req_one_access = list(ACCESS_SECURITY, ACCESS_HOP)
	circuit = /obj/item/circuitboard/computer/secure_data
	light_color = COLOR_SOFT_RED
	/// The current state of the printer
	var/printing = FALSE
	/// Logged in to the console
	var/logged_in = FALSE

/obj/machinery/computer/secure_data/syndie
	icon_keyboard = "syndie_key"
	req_one_access = list(ACCESS_SYNDICATE)
	logged_in = TRUE

/obj/machinery/computer/secure_data/laptop
	name = "security laptop"
	desc = "A cheap Nanotrasen security laptop, it functions as a security records console. It's bolted to the table."
	icon_state = "laptop"
	icon_screen = "seclaptop"
	icon_keyboard = "laptop_key"
	pass_flags = PASSTABLE

/obj/machinery/computer/secure_data/laptop/syndie
	desc = "A cheap, jailbroken security laptop. It functions as a security records console. It's bolted to the table."
	req_one_access = list(ACCESS_SYNDICATE)
	logged_in = TRUE

/obj/machinery/computer/secure_data/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/arrest_console_data,
		/obj/item/circuit_component/arrest_console_arrest,
	))

/obj/machinery/computer/secure_data/emp_act(severity)
	. = ..()

	if(machine_stat & (BROKEN|NOPOWER) || . & EMP_PROTECT_SELF)
		return

	for(var/datum/record/crew/record in GLOB.data_core.general)
		if(prob(10/severity))
			switch(rand(1,5))
				if(1)
					if(prob(10))
						record.name = "[pick(lizard_name(MALE),lizard_name(FEMALE))]"
					else
						record.name = "[pick(pick(GLOB.first_names_male), pick(GLOB.first_names_female))] [pick(GLOB.last_names)]"
				if(2)
					record.gender = pick("Male", "Female", "Other")
				if(3)
					record.age = rand(5, 85)
				if(4)
					record.wanted_status = pick(WANTED_STATUSES())
				if(5)
					record.species = pick(get_selectable_species())
			continue

		else if(prob(1))
			qdel(record)
			continue

/obj/machinery/computer/secure_data/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(.)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		character_preview_view = create_character_preview_view(user)
		ui = new(user, src, "SecurityRecords")
		ui.set_autoupdate(FALSE)
		ui.open()
		addtimer(CALLBACK(src, PROC_REF(update_preview)), 1 SECONDS)

/obj/machinery/computer/secure_data/ui_data(mob/user)
	var/list/data = list()

	data["available_statuses"] = WANTED_STATUSES()
	data["logged_in"] = isliving(user) && (logged_in || issilicon(user))

	if(!logged_in)
		return data

	var/list/records = list()

	for(var/datum/record/crew/target in GLOB.data_core.general)
		var/list/citations = list()
		for(var/datum/crime/citation/warrant in target.citations)
			var/list/entry = list(list(
				author = warrant.author,
				details = warrant.details,
				fine = warrant.fine,
				name = warrant.name,
				paid = warrant.paid,
				ref = REF(warrant),
				time = warrant.time,
			))

			citations += entry

		var/list/crimes = list()
		for(var/datum/crime/crime in target.crimes)
			var/list/entry = list(list(
				author = crime.author,
				details = crime.details,
				name = crime.name,
				ref = REF(crime),
				time = crime.time,
			))

			crimes += entry

		var/list/record = list(list(
			age = target.age,
			appearance = character_preview_view.assigned_map,
			citations = citations,
			crimes = crimes,
			fingerprint = target.fingerprint,
			gender = target.gender,
			lock_ref = target.lock_ref,
			name = target.name,
			note = target.security_note,
			rank = target.rank,
			ref = REF(target),
			species = target.species,
			wanted_status = target.wanted_status,
		))

		records += record
	data["records"] = records

	return data

/obj/machinery/computer/secure_data/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("add_crime")
			add_crime(usr, params)
			return TRUE

		if("delete_crime")
			var/datum/record/crew/record = locate(params["crew_ref"]) in GLOB.data_core.general
			if(!record)
				return FALSE

			var/datum/crime/crime = locate(params["crime_ref"]) in record.crimes
			if(crime)
				record.crimes -= crime
				qdel(crime)
				return TRUE

			var/datum/crime/citation = locate(params["crime_ref"]) in record.citations
			if(citation)
				record.citations -= citation
				qdel(citation)
				return TRUE

			return FALSE

		if("login")
			login(usr)
			return TRUE

		if("logout")
			if(istype(src, /obj/machinery/computer/secure_data/syndie) || issilicon(usr))
				balloon_alert(usr, "access denied")
				playsound(src, 'sound/machines/terminal_error.ogg', 100, TRUE)
				return TRUE

			balloon_alert(usr, "logged out")
			playsound(src, 'sound/machines/terminal_off.ogg', 70, TRUE)
			logged_in = FALSE

			return TRUE

		if("print_record")
			print_record(usr, params)
			return TRUE

		if("set_note")
			var/datum/record/crew/record = locate(params["ref"]) in GLOB.data_core.general
			if(!record)
				return FALSE

			var/note = params["note"]
			record.security_note = trim(note, MAX_MESSAGE_LEN)

			return TRUE

		if("set_wanted")
			var/datum/record/crew/record = locate(params["ref"]) in GLOB.data_core.general
			if(!record)
				return FALSE

			var/wanted_status = params["status"]
			if(!wanted_status || !(wanted_status in WANTED_STATUSES()))
				return FALSE
			record.wanted_status = wanted_status

			return TRUE

		if("view_record")
			var/datum/record/locked/record = locate(params["lock_ref"]) in GLOB.data_core.locked
			if(!record)
				return FALSE
			update_preview(record)

			return TRUE

	return FALSE

/// Handles adding a crime to a particular record.
/obj/machinery/computer/secure_data/proc/add_crime(mob/user, list/params)
	var/datum/record/crew/target = locate(params["ref"]) in GLOB.data_core.general
	if(!target)
		return FALSE

	if(!params["name"])
		to_chat(usr, span_warning("You must enter a name for the crime."))
		playsound(src, 'sound/machines/terminal_error.ogg', 100, TRUE)
		return FALSE

	if(params["fine"] > MAX_CITATION_FINE)
		to_chat(usr, span_warning("The maximum fine is [MAX_CITATION_FINE] credits."))
		playsound(src, 'sound/machines/terminal_error.ogg', 100, TRUE)
		return FALSE

	var/input_details
	if(params["details"])
		input_details = params["details"]

	if(params["fine"] == 0)
		var/datum/crime/new_crime = new(name = params["name"], details = input_details, author = usr)
		target.crimes += new_crime
		target.wanted_status = WANTED_ARREST
		return TRUE

	var/datum/crime/citation/new_citation = new(name = params["name"], details = input_details, author = usr, fine = params["fine"])
	target.citations += new_citation
	citation_alert(user, target.name, "You have been issued a [params["fine"]]cr citation for [params["name"]].")

	return TRUE

/// Handles logging into the computer.
/obj/machinery/computer/secure_data/proc/login(mob/user)
	if(!isliving(user))
		to_chat(user, span_warning("ACCESS DENIED"))
		playsound(src, 'sound/machines/terminal_error.ogg', 100, TRUE)
		return FALSE

	var/mob/living/player = user
	var/obj/item/card/id/auth = player.get_idcard(TRUE)
	if(!auth)
		to_chat(user, span_warning("ACCESS DENIED: No ID card detected."))
		playsound(src, 'sound/machines/terminal_error.ogg', 100, TRUE)
		return FALSE
	var/list/access = auth.GetAccess()

	if(!check_access_list(access))
		to_chat(user, span_warning("ACCESS DENIED: Insufficient access."))
		playsound(src, 'sound/machines/terminal_error.ogg', 100, TRUE)
		return FALSE

	balloon_alert(player, "access granted")
	playsound(src, 'sound/machines/terminal_on.ogg', 100, TRUE)
	logged_in = TRUE
	return TRUE

/// Finishes printing, resets the printer.
/obj/machinery/computer/secure_data/proc/print_finish(obj/item/printable)
	printing = FALSE
	playsound(src, 'sound/machines/terminal_eject.ogg', 100, TRUE)
	printable.forceMove(loc)

	return TRUE

/// Handles printing records via UI. Takes the params from UI_act.
/obj/machinery/computer/secure_data/proc/print_record(mob/user, list/params)
	if(printing)
		balloon_alert(usr, "printer busy")
		playsound(src, 'sound/machines/terminal_error.ogg', 100, TRUE)
		return FALSE

	var/datum/record/crew/record = locate(params["ref"]) in GLOB.data_core.general
	if(!record)
		return FALSE

	printing = TRUE
	balloon_alert(user, "printing")
	playsound(src, 'sound/machines/printer.ogg', 100, TRUE)

	var/obj/item/printable
	var/input_alias = trim(params["alias"], MAX_NAME_LEN) || record.name
	var/input_description = trim(params["desc"], MAX_BROADCAST_LEN) || "No further details."
	var/input_header = trim(params["head"], 8) || capitalize(params["type"])

	switch(params["type"])
		if("missing")
			var/obj/item/photo/mugshot = record.get_front_photo()
			var/obj/item/poster/wanted/missing/missing_poster = new(null, mugshot.picture.picture_image, input_alias, input_description, input_header)

			printable = missing_poster

		if("wanted")
			var/list/crimes = record.crimes
			if(!length(crimes))
				balloon_alert(user, "no crimes")
				return FALSE

			for(var/datum/crime/incident in crimes)
				input_description += "\n[incident.name]\n"
				input_description += "[incident.details]\n"

			var/obj/item/photo/mugshot = record.get_front_photo()
			var/obj/item/poster/wanted/wanted_poster = new(null, mugshot.picture.picture_image, input_alias, input_description, input_header)

			printable = wanted_poster

		if("rapsheet")
			var/list/crimes = record.crimes
			if(!length(crimes))
				balloon_alert(user, "no crimes")
				return FALSE

			var/obj/item/paper/rapsheet = record.get_rapsheet(input_alias, input_header, input_description)
			printable = rapsheet

	addtimer(CALLBACK(src, PROC_REF(print_finish), printable), 2 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE)
	return TRUE

/**
 * Security circuit component
 */
/obj/item/circuit_component/arrest_console_data
	display_name = "Security Records Data"
	desc = "Outputs the security records data, where it can then be filtered with a Select Query component"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The records retrieved
	var/datum/port/output/records

	/// Sends a signal on failure
	var/datum/port/output/on_fail

	var/obj/machinery/computer/secure_data/attached_console

/obj/item/circuit_component/arrest_console_data/populate_ports()
	records = add_output_port("Security Records", PORT_TYPE_TABLE)
	on_fail = add_output_port("Failed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/arrest_console_data/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/computer/secure_data))
		attached_console = shell

/obj/item/circuit_component/arrest_console_data/unregister_usb_parent(atom/movable/shell)
	attached_console = null
	return ..()

/obj/item/circuit_component/arrest_console_data/get_ui_notices()
	. = ..()
	. += create_table_notices(list(
		"name",
		"id",
		"rank",
		"arrest_status",
		"gender",
		"age",
		"species",
		"fingerprint",
	))

/obj/item/circuit_component/arrest_console_data/input_received(datum/port/input/port)
	if(!attached_console || !attached_console.authenticated)
		on_fail.set_output(COMPONENT_SIGNAL)
		return

	if(isnull(GLOB.data_core.general))
		on_fail.set_output(COMPONENT_SIGNAL)
		return

	var/list/new_table = list()
	for(var/datum/record/crew/player_record as anything in GLOB.data_core.general)
		var/list/entry = list()
		entry["age"] = player_record.age
		entry["arrest_status"] = player_record.wanted_status
		entry["fingerprint"] = player_record.fingerprint
		entry["gender"] = player_record.gender
		entry["name"] = player_record.name
		entry["rank"] = player_record.rank
		entry["record"] = REF(player_record)
		entry["species"] = player_record.species

		new_table += list(entry)

	records.set_output(new_table)
/obj/item/circuit_component/arrest_console_arrest
	display_name = "Security Records Set Status"
	desc = "Receives a table to use to set people's arrest status. Table should be from the security records data component. If New Status port isn't set, the status will be decided by the options."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The targets to set the status of.
	var/datum/port/input/targets

	/// Sets the new status of the targets.
	var/datum/port/input/option/new_status

	/// Returns the new status set once the setting is complete. Good for locating errors.
	var/datum/port/output/new_status_set

	/// Sends a signal on failure
	var/datum/port/output/on_fail

	var/obj/machinery/computer/secure_data/attached_console

/obj/item/circuit_component/arrest_console_arrest/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/computer/secure_data))
		attached_console = shell

/obj/item/circuit_component/arrest_console_arrest/unregister_usb_parent(atom/movable/shell)
	attached_console = null
	return ..()

/obj/item/circuit_component/arrest_console_arrest/populate_options()
	if(!attached_console)
		return
	var/list/available_statuses = WANTED_STATUSES()
	new_status = add_option_port("Arrest Options", available_statuses)

/obj/item/circuit_component/arrest_console_arrest/populate_ports()
	targets = add_input_port("Targets", PORT_TYPE_TABLE)
	new_status_set = add_output_port("Set Status", PORT_TYPE_STRING)
	on_fail = add_output_port("Failed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/arrest_console_arrest/input_received(datum/port/input/port)
	if(!attached_console || !attached_console.authenticated)
		on_fail.set_output(COMPONENT_SIGNAL)
		return

	var/status_to_set = new_status.value

	new_status_set.set_output(status_to_set)
	var/list/target_table = targets.value
	if(!target_table)
		on_fail.set_output(COMPONENT_SIGNAL)
		return

	var/successful_set = 0
	var/list/names_of_entries = list()
	for(var/list/target in target_table)
		var/datum/record/crew/sec_record = target["security_record"]
		if(!sec_record)
			continue

		if(sec_record.wanted_status != status_to_set)
			successful_set++
			names_of_entries += target["name"]
		sec_record.wanted_status = status_to_set


	if(successful_set > 0)
		investigate_log("[names_of_entries.Join(", ")] have been set to [status_to_set] by [parent.get_creator()].", INVESTIGATE_RECORDS)
		if(successful_set > COMP_SECURITY_ARREST_AMOUNT_TO_FLAG)
			message_admins("[successful_set] security entries have been set to [status_to_set] by [parent.get_creator_admin()]. [ADMIN_COORDJMP(src)]")
		for(var/mob/living/carbon/human/human as anything in GLOB.human_list)
			human.sec_hud_set_security_status()

#undef COMP_SECURITY_ARREST_AMOUNT_TO_FLAG
#undef PRINTOUT_MISSING
#undef PRINTOUT_RAPSHEET
#undef PRINTOUT_WANTED
