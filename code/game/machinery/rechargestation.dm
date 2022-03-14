/obj/machinery/recharge_station
	name = "recharging station"
	desc = "This device recharges energy dependent lifeforms, like cyborgs, ethereals and MODsuit users."
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 1000
	req_access = list(ACCESS_ROBOTICS)
	state_open = TRUE
	circuit = /obj/item/circuitboard/machine/cyborgrecharger
	occupant_typecache = list(/mob/living/silicon/robot, /mob/living/carbon/human)
	processing_flags = NONE
	var/recharge_speed
	var/repairs


/obj/machinery/recharge_station/Initialize(mapload)
	. = ..()
	update_appearance()
	if(is_operational)
		begin_processing()

	var/area/my_area = get_area(src)
	if(my_area.type in GLOB.the_station_areas)
		GLOB.station_recharging_stations += src
		update_area_names()

/obj/machinery/recharge_station/proc/update_area_names()
	GLOB.station_recharging_station_area_names.Cut()
	for(var/atom/charge_station in GLOB.station_recharging_stations)
		var/area_name = get_area_name(charge_station, format_text = TRUE)
		if(!(area_name in GLOB.station_recharging_station_area_names))
			GLOB.station_recharging_station_area_names += area_name
	GLOB.station_recharging_station_area_names = sort_list(GLOB.station_recharging_station_area_names)

/obj/machinery/recharge_station/Destroy()
	GLOB.station_recharging_stations -= src
	update_area_names()
	return ..()

/obj/machinery/recharge_station/RefreshParts()
	recharge_speed = 0
	repairs = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_speed += C.rating * 100
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		repairs += M.rating - 1
	for(var/obj/item/stock_parts/cell/C in component_parts)
		recharge_speed *= C.maxcharge / 10000

/obj/machinery/recharge_station/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Recharging <b>[recharge_speed]J</b> per cycle.")
		if(repairs)
			. += span_notice("[src] has been upgraded to support automatic repairs.")


/obj/machinery/recharge_station/on_set_is_operational(old_value)
	if(old_value) //Turned off
		end_processing()
	else //Turned on
		begin_processing()


/obj/machinery/recharge_station/process(delta_time)
	if(occupant)
		process_occupant(delta_time)
	return 1

/obj/machinery/recharge_station/relaymove(mob/living/user, direction)
	if(user.stat)
		return
	open_machine()

/obj/machinery/recharge_station/emp_act(severity)
	. = ..()
	if(!(machine_stat & (BROKEN|NOPOWER)))
		if(occupant && !(. & EMP_PROTECT_CONTENTS))
			occupant.emp_act(severity)
		if (!(. & EMP_PROTECT_SELF))
			open_machine()

/obj/machinery/recharge_station/attackby(obj/item/P, mob/user, params)
	if(state_open)
		if(default_deconstruction_screwdriver(user, "borgdecon2", "borgcharger0", P))
			return

	if(default_pry_open(P))
		return

	if(default_deconstruction_crowbar(P))
		return
	return ..()

/obj/machinery/recharge_station/interact(mob/user)
	toggle_open()
	return TRUE

/obj/machinery/recharge_station/proc/toggle_open()
	if(state_open)
		close_machine()
	else
		open_machine()

/obj/machinery/recharge_station/open_machine()
	. = ..()
	update_use_power(IDLE_POWER_USE)

/obj/machinery/recharge_station/close_machine()
	. = ..()
	if(occupant)
		update_use_power(ACTIVE_POWER_USE) //It always tries to charge, even if it can't.
		add_fingerprint(occupant)

/obj/machinery/recharge_station/update_icon_state()
	if(!is_operational)
		icon_state = "borgcharger-u[state_open ? 0 : 1]"
		return ..()
	icon_state = "borgcharger[state_open ? 0 : (occupant ? 1 : 2)]"
	return ..()

/obj/machinery/recharge_station/proc/process_occupant(delta_time)
	if(!occupant)
		return
	SEND_SIGNAL(occupant, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, recharge_speed * delta_time / 2, repairs)
