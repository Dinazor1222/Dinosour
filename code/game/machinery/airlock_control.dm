#define AIRLOCK_CONTROL_RANGE 5

// This code allows for airlocks to be controlled externally by setting an id_tag and comm frequency (disables ID access)
/obj/machinery/door/airlock
	/// The current state of the airlock, used to construct the airlock overlays
	var/airlock_state
	var/frequency
	var/datum/radio_frequency/radio_connection

/obj/machinery/door/airlock/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_GREY_TIDE, PROC_REF(grey_tide))

/obj/machinery/door/airlock/receive_signal(datum/signal/signal)
	if(!signal)
		return

	if(id_tag != signal.data["tag"] || !signal.data["command"])
		return

	switch(signal.data["command"])
		if("open")
			open(TRUE)

		if("close")
			close(TRUE)

		if("unlock")
			locked = FALSE
			update_appearance()

		if("lock")
			locked = TRUE
			update_appearance()

		if("secure_open")
			locked = FALSE
			update_appearance()

			sleep(0.2 SECONDS)
			open(TRUE)

			locked = TRUE
			update_appearance()

		if("secure_close")
			locked = FALSE
			close(TRUE)

			locked = TRUE
			sleep(0.2 SECONDS)
			update_appearance()

	send_status()

/obj/machinery/door/airlock/proc/send_status()
	if(radio_connection)
		var/datum/signal/signal = new(list(
			"tag" = id_tag,
			"timestamp" = world.time,
			"door_status" = density ? "closed" : "open",
			"lock_status" = locked ? "locked" : "unlocked"
		))
		radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)

/obj/machinery/door/airlock/open(surpress_send)
	. = ..()
	if(!surpress_send)
		send_status()

/obj/machinery/door/airlock/close(surpress_send)
	. = ..()
	if(!surpress_send)
		send_status()

/obj/machinery/door/airlock/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	if(new_frequency)
		frequency = new_frequency
		radio_connection = SSradio.add_object(src, frequency, RADIO_AIRLOCK)

/obj/machinery/door/airlock/on_magic_unlock(datum/source, datum/action/cooldown/spell/aoe/knock/spell, mob/living/caster)
	// Airlocks should unlock themselves when knock is casted, THEN open up.
	locked = FALSE
	return ..()

/obj/machinery/door/airlock/Destroy()
	if(frequency)
		SSradio.remove_object(src,frequency)
	UnregisterSignal(SSdcs, COMSIG_GLOB_GREY_TIDE)
	return ..()

/obj/machinery/door/airlock/proc/grey_tide()
	SIGNAL_HANDLER

	if(critical_machine) //Skip doors in critical positions, such as the SM chamber.
		return

	if(is_station_level(z))
		for(var/area_type in GLOB.grey_tide_areas)
			if(istype(get_area(src), area_type))
				INVOKE_ASYNC(src, PROC_REF(prison_open), 2) //Sleep gets called further down in open(), so we have to invoke async

/obj/machinery/airlock_sensor
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_sensor_off"
	base_icon_state = "airlock_sensor"
	name = "airlock sensor"
	resistance_flags = FIRE_PROOF

	power_channel = AREA_USAGE_ENVIRON

	var/master_tag
	var/frequency = FREQ_AIRLOCK_CONTROL

	var/datum/radio_frequency/radio_connection

	var/on = TRUE
	var/alert = FALSE

/obj/machinery/airlock_sensor/incinerator_ordmix
	id_tag = INCINERATOR_ORDMIX_AIRLOCK_SENSOR
	master_tag = INCINERATOR_ORDMIX_AIRLOCK_CONTROLLER

/obj/machinery/airlock_sensor/incinerator_atmos
	id_tag = INCINERATOR_ATMOS_AIRLOCK_SENSOR
	master_tag = INCINERATOR_ATMOS_AIRLOCK_CONTROLLER

/obj/machinery/airlock_sensor/incinerator_syndicatelava
	id_tag = INCINERATOR_SYNDICATELAVA_AIRLOCK_SENSOR
	master_tag = INCINERATOR_SYNDICATELAVA_AIRLOCK_CONTROLLER

/obj/machinery/airlock_sensor/update_icon_state()
	if(!on)
		icon_state = "[base_icon_state]_off"
	else
		if(alert)
			icon_state = "[base_icon_state]_alert"
		else
			icon_state = "[base_icon_state]_standby"
	return ..()

/obj/machinery/airlock_sensor/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	var/datum/signal/signal = new(list(
		"tag" = master_tag,
		"command" = "cycle"
	))

	radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)
	flick("airlock_sensor_cycle", src)

/obj/machinery/airlock_sensor/process()
	if(on)
		var/datum/gas_mixture/air_sample = return_air()
		var/pressure = round(air_sample.return_pressure(),0.1)
		alert = (pressure < ONE_ATMOSPHERE*0.8)

		var/datum/signal/signal = new(list(
			"tag" = id_tag,
			"timestamp" = world.time,
			"pressure" = num2text(pressure)
		))

		radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)

	update_appearance()

/obj/machinery/airlock_sensor/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_AIRLOCK)

/obj/machinery/airlock_sensor/Initialize(mapload)
	. = ..()
	set_frequency(frequency)

/obj/machinery/airlock_sensor/Destroy()
	SSradio.remove_object(src,frequency)
	return ..()
