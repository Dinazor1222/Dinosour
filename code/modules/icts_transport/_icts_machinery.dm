/obj/machinery/icts
	/// ID of the transport we're associated with for filtering commands
	var/configured_transport_id = TRAMSTATION_LINE_1
	/// weakref of the transport we're associated with
	var/datum/weakref/transport_ref
	var/list/methods_to_fix = list()
	var/list/repair_signals = list()
	var/static/list/how_do_we_fix_it = list(
		"try turning it off and on again" = TOOL_MULTITOOL,
		"try forcing an unexpected reboot" = TOOL_MULTITOOL,
		"patch the system's call table" = TOOL_MULTITOOL,
		"gently reset the invalid memory" = TOOL_CROWBAR,
		"secure its ground connection" = TOOL_WRENCH,
		"tighten some screws" = TOOL_SCREWDRIVER,
		"check its wire voltages" = TOOL_MULTITOOL,
		"cut some excess wires" = TOOL_WIRECUTTER,
	)
	var/malfunctioning = FALSE

/obj/machinery/icts/proc/local_fault()
	if(malfunctioning || repair_signals)
		return

	generate_repair_signals()
	malfunctioning = TRUE
	set_is_operational(FALSE)
	update_appearance()

/**
 * All ICTS subtypes have the same method of repair for consistency and predictability
 * The key of this assoc list is the "method" of how they're fixing the thing (just flavor for examine),
 * and the value is what tool they actually need to use on the thing to fix it
 */
/obj/machinery/icts/proc/generate_repair_signals()

	// Select a few methods of how to fix it
	var/list/fix_it_keys = assoc_to_keys(how_do_we_fix_it)
	methods_to_fix += pick_n_take(fix_it_keys)

	// Construct the signals
	LAZYINITLIST(repair_signals)
	for(var/tool_method as anything in methods_to_fix)
		repair_signals += COMSIG_ATOM_TOOL_ACT(how_do_we_fix_it[tool_method])

	// Register signals to make it fixable
	if(length(repair_signals))
		RegisterSignals(src, repair_signals, PROC_REF(on_machine_tooled))

/obj/machinery/icts/proc/clear_repair_signals()
	UnregisterSignal(src, repair_signals)
	QDEL_LAZYLIST(repair_signals)

/obj/machinery/icts/examine(mob/user)
	. = ..()
	if(methods_to_fix)
		for(var/tool_method as anything in methods_to_fix)
			. += span_info("It needs someone to [tool_method].")

/**
 * Signal proc for [COMSIG_ATOM_TOOL_ACT], from a variety of signals, registered on the ICTS machinery.
 *
 * We allow for someone to stop the event early by using the proper tools, hinted at in examine, on the machine
 */
/obj/machinery/icts/proc/on_machine_tooled(obj/machinery/source, mob/living/user, obj/item/tool)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(try_fix_machine), source, user, tool)
	return COMPONENT_BLOCK_TOOL_ATTACK

/// Attempts a do_after, and if successful, stops the event
/obj/machinery/icts/proc/try_fix_machine(obj/machinery/icts/machine, mob/living/user, obj/item/tool)
	SHOULD_CALL_PARENT(TRUE)

	machine.balloon_alert(user, "percussive maintenance...")
	if(!tool.use_tool(machine, user, 7 SECONDS, volume = 50))
		machine.balloon_alert(user, "interrupted!")
		return FALSE

	playsound(src, 'sound/machines/synth_yes.ogg', 75, use_reverb = TRUE)
	machine.balloon_alert(user, "success!")
	UnregisterSignal(src, repair_signals)
	QDEL_LAZYLIST(repair_signals)
	QDEL_LAZYLIST(methods_to_fix)
	malfunctioning = FALSE
	set_machine_stat(machine_stat & ~EMAGGED)
	update_appearance()
	return TRUE

/obj/machinery/icts/welder_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return
	if(atom_integrity >= max_integrity)
		balloon_alert(user, "it doesn't need repairs!")
		return TRUE
	balloon_alert(user, "repairing...")
	if(!tool.use_tool(src, user, 4 SECONDS, amount = 0, volume=50))
		return TRUE
	balloon_alert(user, "repaired")
	atom_integrity = max_integrity
	set_machine_stat(machine_stat & ~BROKEN)
	update_appearance()
	return TRUE

/obj/item/wallframe/icts/try_build(obj/structure/tram/on_tram, mob/user)
	if(get_dist(on_tram,user) > 1)
		balloon_alert(user, "you are too far!")
		return

	var/floor_to_tram = get_dir(user, on_tram)
	if(!(floor_to_tram in GLOB.cardinals))
		balloon_alert(user, "stand in line with tram wall!")
		return

	var/turf/tram_turf = get_turf(user)
	var/obj/structure/thermoplastic/tram_floor = locate() in tram_turf
	if(!istype(tram_floor))
		balloon_alert(user, "needs tram!")
		return

	if(check_wall_item(tram_turf, floor_to_tram, wall_external))
		balloon_alert(user, "already something here!")
		return

	return TRUE

/obj/item/wallframe/icts/attach(obj/structure/tram/on_tram, mob/user)
	if(result_path)
		playsound(src.loc, 'sound/machines/click.ogg', 75, TRUE)
		user.visible_message(span_notice("[user.name] installs [src] on the tram."),
			span_notice("You install [src] on the tram."),
			span_hear("You hear clicking."))
		var/floor_to_tram = get_dir(user, on_tram)

		var/obj/cabinet = new result_path(get_turf(user), floor_to_tram, TRUE)
		cabinet.setDir(floor_to_tram)

		if(pixel_shift)
			switch(floor_to_tram)
				if(NORTH)
					cabinet.pixel_y = pixel_shift
				if(SOUTH)
					cabinet.pixel_y = -pixel_shift
				if(EAST)
					cabinet.pixel_x = pixel_shift
				if(WEST)
					cabinet.pixel_x = -pixel_shift
		after_attach(cabinet)

	qdel(src)
