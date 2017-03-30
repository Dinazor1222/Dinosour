
GLOBAL_REAL(SSflightpacks, /datum/controller/subsystem/processing/flightpacks)
/datum/controller/subsystem/processing/flightpacks
	name = "Flightpack Movement"
	priority = 30
	wait = 2
	stat_tag = "FM"
	flags = SS_NO_INIT|SS_TICKER|SS_KEEP_TIMING
	var/flightsuit_processing = FLIGHTSUIT_PROCESSING_FULL

/datum/controller/subsystem/processing/flightpacks/New()
	NEW_SS_GLOBAL(SSflightpacks)

/datum/controller/subsystem/processing/flightpacks/Initialize()
	sync_flightsuit_processing()

/datum/controller/subsystem/processing/flightpacks/vv_edit_var(var_name, var_value)
	..()
	switch(var_name)
		if("flightsuit_processing")
			sync_flightsuit_processing()

/datum/controller/subsystem/processing/flightpacks/proc/sync_flightsuit_processing()
	for(var/obj/item/device/flightpack/FP in processing)
		FP.sync_processing(src)
	if(flightsuit_processing == FLIGHTSUIT_PROCESSING_NONE)	//Don't even bother firing.
		can_fire = FALSE
	else
		can_fire = TRUE
