/// Pedestrian crossing signal for tram
/obj/machinery/crossing_signal
	name = "crossing signal"
	desc = "Indicates to pedestrians if it's safe to cross the tracks."
	icon = 'icons/obj/machines/crossing_signal.dmi'
	base_icon_state = "crossing-"
	plane = GAME_PLANE_UPPER
	layer = TRAM_SIGNAL_LAYER
	max_integrity = 250
	integrity_failure = 0.25
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 2.4
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.74
	anchored = TRUE
	density = FALSE
	// pointless if it only takes 2 seconds to cross but updates every 2 seconds
	subsystem_type = /datum/controller/subsystem/processing/fastprocess
	light_range = 1.5
	light_power = 3
	light_color = LIGHT_COLOR_BABY_BLUE
	luminosity = 1
	/// green, amber, or red for tram, blue if it's emag, tram missing, etc.
	var/signal_state = XING_STATE_MALF
	/// The ID of the tram we control
	var/tram_id = TRAMSTATION_LINE_1
	/// Weakref to the tram we're tracking
	var/datum/weakref/tram_ref
	/// the sensor we use
	var/obj/machinery/guideway_sensor/linked_sensor
	/// If the signal is facing east or west
	var/signal_direction
	/// Inbound station
	var/inbound
	/// Outbound station
	var/outbound
	var/operating_status = XING_NORMAL_OPERATION
	/** Proximity thresholds for crossing signal states
	*
	* The proc that checks the distance between the tram and crossing signal uses these vars to determine the distance between tram and signal to change
	* colors. The numbers are specifically set for Tramstation. If we get another map with crossing signals we'll have to probably subtype it or something.
	* If the value is set too high, it will cause the lights to turn red when the tram arrives at another station. You want to optimize the amount of
	* warning without turning it red unnessecarily.
	*
	* Red: decent chance of getting hit, but if you're quick it's a decent gamble.
	* Amber: slow people may be in danger.
	*/
	var/amber_distance_threshold = XING_DISTANCE_AMBER
	var/red_distance_threshold = XING_DISTANCE_RED


/** Crossing signal subtypes
 *
 *  Each map will have a different amount of tiles between stations, so adjust the signals here based on the map.
 *  The distance is calculated from the bottom left corner of the tram,
 *  so signals on the east side have their distance reduced by the tram length, in this case 10 for Tramstation.
*/
/obj/machinery/crossing_signal/northwest
	icon_state = "crossing-base-right"
	signal_direction = WEST
	pixel_x = -32
	pixel_y = -1

/obj/machinery/crossing_signal/northeast
	icon_state = "crossing-base-left"
	signal_direction = EAST
	pixel_x = -2
	pixel_y = -1

/obj/machinery/crossing_signal/southwest
	icon_state = "crossing-base-right"
	signal_direction = WEST
	pixel_x = -32
	pixel_y = 20

/obj/machinery/crossing_signal/southeast
	icon_state = "crossing-base-left"
	signal_direction = EAST
	pixel_x = -2
	pixel_y = 20

/obj/machinery/static_signal
	name = "crossing signal"
	desc = "Indicates to pedestrians if it's safe to cross the tracks."
	icon = 'icons/obj/machines/crossing_signal.dmi'
	icon_state = "static-left-on"
	base_icon_state = "static-left-"
	plane = GAME_PLANE_UPPER
	max_integrity = 250
	integrity_failure = 0.25
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 2.4
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.74
	anchored = TRUE
	density = FALSE
	light_range = 1.5
	light_power = 3
	light_color = COLOR_VIBRANT_LIME
	luminosity = 1

/obj/machinery/static_signal/northwest
	icon_state = "static-right-on"
	base_icon_state = "static-right-"
	pixel_x = -32
	pixel_y = -1

/obj/machinery/static_signal/northeast
	pixel_x = -2
	pixel_y = -1

/obj/machinery/static_signal/southwest
	icon_state = "static-right-on"
	base_icon_state = "static-right-"
	pixel_x = -32
	pixel_y = 20

/obj/machinery/static_signal/southeast
	pixel_x = -2
	pixel_y = 20

/obj/machinery/crossing_signal/Initialize(mapload)
	. = ..()
	RegisterSignal(SSicts_transport, COMSIG_ICTS_TRANSPORT_ACTIVE, PROC_REF(wake_up))
	SSicts_transport.crossing_signals += src
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/crossing_signal/LateInitialize(mapload)
	. = ..()
	find_tram()
	link_sensor()

/obj/machinery/crossing_signal/Destroy()
	SSicts_transport.crossing_signals -= src
	if(linked_sensor)
		linked_sensor.uplink = null
		linked_sensor = null
	. = ..()

/obj/machinery/crossing_signal/emag_act(mob/living/user)
	if(obj_flags & EMAGGED)
		return FALSE
	balloon_alert(user, "disabled motion sensors")
	operating_status = XING_SIGNAL_EMAG
	obj_flags |= EMAGGED
	return TRUE

/obj/machinery/crossing_signal/proc/start_event_malfunction()
	if(operating_status == XING_NORMAL_OPERATION)
		operating_status = XING_TRANSPORT_FAULT
		amber_distance_threshold = XING_DISTANCE_AMBER * 0.5
		red_distance_threshold = XING_DISTANCE_RED * 0.5

/obj/machinery/crossing_signal/proc/end_event_malfunction()
	if(operating_status == XING_TRANSPORT_FAULT)
		operating_status = FALSE
		amber_distance_threshold = XING_DISTANCE_AMBER
		red_distance_threshold = XING_DISTANCE_RED

/**
 * Finds the tram, just like the tram computer
 *
 * Locates tram parts in the lift global list after everything is done.
 */
/obj/machinery/crossing_signal/proc/find_tram()
	for(var/datum/transport_controller/linear/tram/tram as anything in SSicts_transport.transports_by_type[ICTS_TYPE_TRAM])
		if(tram.specific_transport_id != tram_id)
			continue
		tram_ref = WEAKREF(tram)
		break

/obj/machinery/crossing_signal/proc/link_sensor()
	if(linked_sensor)
		linked_sensor.uplink = null
		linked_sensor = null
	if(!signal_direction)
		return
	var/limit = XING_DEFAULT_TRAM_LENGTH
	var/turf/my_turf = get_turf(src)
	var/obj/machinery/guideway_sensor/found_sensor
	do
		my_turf = get_step(my_turf, signal_direction)
		found_sensor = locate() in my_turf
		if(found_sensor && found_sensor.link_direction != get_dir(found_sensor, src))
			found_sensor = null
		limit--
	while(!found_sensor && limit)
	if(!found_sensor)
		return FALSE
	found_sensor.uplink = src
	linked_sensor = found_sensor

/obj/machinery/crossing_signal/proc/wake_sensor()
	if(operating_status > XING_SENSOR_FAULT)
		return

	if(isnull(linked_sensor))
		message_admins("Crossing signal: Sensor fault")
		operating_status = XING_SENSOR_FAULT

	if(linked_sensor.check_connection())
		message_admins("Crossing signal: Sensor connected")
		operating_status = XING_NORMAL_OPERATION

	else
		message_admins("Crossing signal: Sensor fault")
		operating_status = XING_SENSOR_FAULT

/**
 * Only process if the tram is actually moving
 */
/obj/machinery/crossing_signal/proc/wake_up(datum/source, transport_controller, controller_active)
	SIGNAL_HANDLER

	update_operating()

/obj/machinery/crossing_signal/on_set_is_operational()
	. = ..()

	update_operating()

/**
 * Update processing state.
 *
 * Returns whether we are still processing.
 */
/obj/machinery/crossing_signal/proc/update_operating()

	use_power(idle_power_usage)
	wake_sensor()
	// Immediately process for snappy feedback
	var/should_process = process() != PROCESS_KILL
	if(should_process)
		begin_processing()
		return
	end_processing()

/obj/machinery/crossing_signal/process()

	var/datum/transport_controller/linear/tram/tram = tram_ref?.resolve()

	// Check for stopped states.
	if(!tram || !tram.controller_operational || !is_operational || !inbound || !outbound)
		// Tram missing, we lost power, or something isn't right
		// Throw the error message (blue)
		set_signal_state(XING_STATE_MALF, force = !is_operational)
		return PROCESS_KILL

	use_power(active_power_usage)

	var/obj/structure/transport/linear/tram_part = tram.return_closest_platform_to(src)

	if(QDELETED(tram_part))
		set_signal_state(XING_STATE_MALF, force = !is_operational)
		return PROCESS_KILL

	// Everything will be based on position and travel direction
	var/signal_pos
	var/tram_pos
	var/tram_velocity_sign // 1 for positive axis movement, -1 for negative
	// Try to be agnostic about N-S vs E-W movement
	if(tram.travel_direction & (NORTH|SOUTH))
		signal_pos = y
		tram_pos = tram_part.y
		tram_velocity_sign = tram.travel_direction & NORTH ? 1 : -1
	else
		signal_pos = x
		tram_pos = tram_part.x
		tram_velocity_sign = tram.travel_direction & EAST ? 1 : -1

	// How far away are we? negative if already passed.
	var/approach_distance = tram_velocity_sign * (signal_pos - (tram_pos + (XING_DEFAULT_TRAM_LENGTH * 0.5)))

	// Check for stopped state.
	// Will kill the process since tram starting up will restart process.
	if(!tram.controller_active)
		set_signal_state(XING_STATE_GREEN)
		return PROCESS_KILL

	// Check if tram is driving away from us.
	if(approach_distance < 0)
		// driving away. Green. In fact, in order to reverse, it'll have to stop, so let's go ahead and kill.
		set_signal_state(XING_STATE_GREEN)
		return PROCESS_KILL

	// Check the tram's terminus station.
	// INBOUND 1 < 2 < 3
	// OUTBOUND 1 > 2 > 3
	if(tram.travel_direction & WEST && inbound < tram.destination_platform.platform_code)
		set_signal_state(XING_STATE_GREEN)
		return PROCESS_KILL
	if(tram.travel_direction & EAST && outbound > tram.destination_platform.platform_code)
		set_signal_state(XING_STATE_GREEN)
		return PROCESS_KILL

	// Finally the interesting part where it's ACTUALLY approaching
	if(approach_distance <= red_distance_threshold)
		if(operating_status != XING_NORMAL_OPERATION)
			set_signal_state(XING_STATE_MALF)
		else
			set_signal_state(XING_STATE_RED)
		return
	if(approach_distance <= amber_distance_threshold)
		set_signal_state(XING_STATE_AMBER)
		return
	set_signal_state(XING_STATE_GREEN)

/**
 * Set the signal state and update appearance.
 *
 * Arguments:
 * new_state - the new state (XING_STATE_RED, etc)
 * force_update - force appearance to update even if state didn't change.
 */
/obj/machinery/crossing_signal/proc/set_signal_state(new_state, force = FALSE)
	if(new_state == signal_state && !force)
		return

	signal_state = new_state
	update_appearance()

/obj/machinery/crossing_signal/update_appearance(updates)
	. = ..()

	if(!is_operational)
		set_light(l_on = FALSE)
		return

	var/new_color
	switch(signal_state)
		if(XING_STATE_MALF)
			new_color = LIGHT_COLOR_BABY_BLUE
		if(XING_STATE_GREEN)
			new_color = LIGHT_COLOR_VIVID_GREEN
		if(XING_STATE_AMBER)
			new_color = LIGHT_COLOR_BRIGHT_YELLOW
		else
			new_color = LIGHT_COLOR_FLARE

	set_light(l_on = TRUE, l_color = new_color)

/obj/machinery/crossing_signal/update_overlays()
	. = ..()

	if(!is_operational)
		return

	if(!signal_direction) //Base type doesnt have directions set
		return

	var/lights_overlay = "[base_icon_state][signal_direction][signal_state]"

	. += mutable_appearance(icon, lights_overlay)
	. += emissive_appearance(icon, "[lights_overlay]e", offset_spokesman = src, alpha = src.alpha)

/obj/machinery/static_signal/power_change()
	..()
	if(!is_operational)
		icon_state = "[base_icon_state]off"
		set_light(l_on = FALSE)
		return

	icon_state = "[base_icon_state]on"
	set_light(l_on = TRUE)

/obj/machinery/guideway_sensor
	name = "guideway sensor"
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "airlock_sensor_standby"
	layer = TRAM_RAIL_LAYER
	/// Keeps track of the signal's scanning equipment
	var/obj/item/stock_parts/scanning_module/attached_scanner = new /obj/item/stock_parts/scanning_module/adv()
	/// Sensors work in a married pair
	var/obj/machinery/guideway_sensor/paired_sensor
	var/link_direction
	var/pairing_direction
	/// The crossing signal we report to
	var/obj/machinery/crossing_signal/uplink

/obj/machinery/guideway_sensor/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/guideway_sensor/LateInitialize(mapload)
	. = ..()
	pair_sensor()

/obj/machinery/guideway_sensor/proc/pair_sensor()
	if(paired_sensor)
		paired_sensor.paired_sensor = null
		paired_sensor = null
	if (!pairing_direction)
		return
	var/limit = XING_DEFAULT_TRAM_LENGTH
	var/turf/my_turf = get_turf(src)
	var/obj/machinery/guideway_sensor/found_sensor
	do
		my_turf = get_step(my_turf, pairing_direction)
		found_sensor = locate() in my_turf
		if (found_sensor && found_sensor.pairing_direction != get_dir(found_sensor, src))
			found_sensor = null
		limit--
	while(!found_sensor && limit)
	if(!found_sensor)
		return FALSE
	found_sensor.paired_sensor = src
	paired_sensor = found_sensor
	icon_state = "airlock_sensor_cycle"
	update_appearance()
	paired_sensor.icon_state = "airlock_sensor_cycle"
	paired_sensor.update_appearance()

/obj/machinery/guideway_sensor/proc/check_connection()
	if(attached_scanner.rating > 2)
		icon_state = "airlock_sensor_standby"
		set_is_operational(FALSE)
		update_appearance()
		return FALSE

	if(is_operational && paired_sensor.is_operational)
		icon_state = "airlock_sensor_cycle"
		update_appearance()
		return TRUE

	icon_state = "airlock_sensor_standby"
	update_appearance()
	return FALSE

/obj/machinery/guideway_sensor/Destroy()
	if(paired_sensor)
		paired_sensor.paired_sensor = null
		paired_sensor.update_appearance()
		paired_sensor = null
		update_appearance()
	if(uplink)
		uplink.linked_sensor = null
		uplink = null
	. = ..()

/obj/machinery/guideway_sensor/update_appearance()
	. = ..()

	if(!paired_sensor)
		icon_state = "airlock_sensor_standby"
	else if(!paired_sensor.check_connection())
		icon_state = "airlock_sensor_alert"
