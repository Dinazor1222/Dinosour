/datum/unit_test/atmospherics_sanity
	var/list/station_areas_remaining

TEST_FOCUS(/datum/unit_test/atmospherics_sanity)

/datum/unit_test/atmospherics_sanity/Run()
	station_areas_remaining = GLOB.the_station_areas.Copy()

	var/list/ignored_areas = list(
		// external
		/area/station/solars,
		// SPAAACE
		/area/station/maintenance/space_hut,
		// where the bombs get sent for ordance
		/area/station/science/ordnance/bomb,
		// holodeck
		/area/station/holodeck/rec_center,
		// pretty obvious
		/area/station/engineering/supermatter,
		// self contained
		/area/station/tcommsat/server,
	)
	for(var/ignored_type in ignored_areas)
		station_areas_remaining -= typesof(ignored_type)

	var/list/start_areas = list(
		// arrivals
		/area/station/hallway/secondary/entry,
		// xenobio
		/area/station/science/xenobiology,
		// viro
		/area/station/medical/virology,
	)
	for(var/area/start_area as anything in start_areas)
		crawl_area(GLOB.areas_by_type[start_area])

	for(var/area/missed as anything in station_areas_remaining)
		TEST_FAIL("Area Type [missed] was not connected to the atmospherics network")

/datum/unit_test/atmospherics_sanity/proc/crawl_area(area/the_area)
	if(!(the_area.type in station_areas_remaining))
		return
	station_areas_remaining -= the_area.type

	var/list/area_scrubbers = the_area.air_scrubbers
	var/list/area_vents = the_area.air_vents
	var/list/datum/pipeline/pipelines = list()

	for(var/obj/machinery/atmospherics/components/component as anything in (area_vents + area_scrubbers))
		for(var/datum/pipeline/vent_node as anything in component.return_pipenets())
			if(!length(vent_node.other_airs))
				TEST_FAIL("Area Type [the_area.type] has an unconnected atmospherics device [component.type]")
				continue
			pipelines |= vent_node

	for(var/datum/pipeline/to_explore as anything in pipelines)
		for(var/obj/machinery/atmospherics/components/other_component as anything in to_explore.other_atmos_machines)
			crawl_area(get_area(other_component))
