///List of gases with high filter priority
GLOBAL_LIST_INIT(high_filtering_gases, list(
		/datum/gas/plasma,
		/datum/gas/carbon_dioxide,
		/datum/gas/nitrous_oxide
	))
///List of gases with medium filter priority
GLOBAL_LIST_INIT(mid_filtering_gases, list(
		/datum/gas/nitryl,
		/datum/gas/stimulum,
		/datum/gas/freon,
		/datum/gas/hypernoblium,
		/datum/gas/bz
	))
///List of gases with low filter priority
GLOBAL_LIST_INIT(low_filtering_gases, list(
		/datum/gas/healium,
		/datum/gas/proto_nitrate,
		/datum/gas/halon,
		/datum/gas/tritium,
		/datum/gas/zauker
	))

/obj/item/gas_filter
	name = "atmospheric gas filter"
	desc = "piece of filtering cloth to be used with atmospheric gas masks and emergency gas masks"
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "gas_atmos_filter"
	///Amount of filtering points available
	var/filter_status = 100
	///Strenght of the filter against high filtering gases
	var/filter_strenght_high = 10
	///Strenght of the filter against mid filtering gases
	var/filter_strenght_mid = 8
	///Strenght of the filter against low filtering gases
	var/filter_strenght_low = 5
	///General efficiency of the filter (between 0 and 1)
	var/filter_efficiency = 0.5
	///All the gases that are breathed and to be checked against
	var/list/gases_moles

/obj/item/gas_filter/Initialize()
	. = ..()
	for(var/gas_id in GLOB.meta_gas_info)
		LAZYADD(gases_moles, gas_id)

/obj/item/gas_filter/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] is at [filter_status] % durability.</span>"

/**
 * called by the gas mask where the filter is installed, lower the filter_status depending on the breath gas composition and by the strenght of the filter
 * returns the modified breath gas mixture
 *
 * Arguments:
 * * breath - the current gas mixture of the breathed air
 *
 */
/obj/item/gas_filter/proc/reduce_filter_status(datum/gas_mixture/breath)

	for(var/gas_id in GLOB.meta_gas_info)
		gases_moles[gas_id] = breath.gases[gas_id][MOLES]

	var/danger_points = 0

	for(var/gas_id in GLOB.high_filtering_gases)
		if(gases_moles[gas_id] > 0.005)
			breath.gases[gas_id][MOLES] = max(breath.gases[gas_id][MOLES] - filter_strenght_high * filter_efficiency * 0.001, 0)
			danger_points += 0.5
		else if(gases_moles[gas_id] > 0)
			breath.gases[gas_id][MOLES] = max(breath.gases[gas_id][MOLES] - filter_strenght_high * filter_efficiency * 0.0005, 0)
			danger_points += 0.05

	for(var/gas_id in GLOB.mid_filtering_gases)
		if(gases_moles[gas_id] > 0.0025)
			breath.gases[gas_id][MOLES] = max(breath.gases[gas_id][MOLES] - filter_strenght_mid * filter_efficiency * 0.001, 0)
			danger_points += 0.75
		else if(gases_moles[gas_id] > 0)
			breath.gases[gas_id][MOLES] = max(breath.gases[gas_id][MOLES] - filter_strenght_mid * filter_efficiency * 0.0005, 0)
			danger_points += 0.15

	for(var/gas_id in GLOB.low_filtering_gases)
		if(gases_moles[gas_id] > 0.001)
			breath.gases[gas_id][MOLES] = max(breath.gases[gas_id][MOLES] - filter_strenght_low * filter_efficiency * 0.001, 0)
			danger_points += 1
		else if(gases_moles[gas_id] > 0)
			breath.gases[gas_id][MOLES] = max(breath.gases[gas_id][MOLES] - filter_strenght_low * filter_efficiency * 0.0005, 0)
			danger_points += 0.5

	filter_status = max(filter_status - danger_points - 1, 0)
	return breath

/obj/item/gas_filter/damaged
	name = "damaged gas filter"
	desc = "piece of filtering cloth to be used with atmospheric gas masks and emergency gas masks, it seems damaged"
	filter_status = 50 //override on initialize

/obj/item/gas_filter/damaged/Initialize()
	. = ..()
	filter_status = rand(35, 65)
