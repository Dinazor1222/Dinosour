//for subsystems that do some sort of processing on datums

/datum/subsystem/processing
	name = "Processing"

	flags = SS_ABSTRACT

	var/stat_tag = "P" //Used for logging
	var/list/processing_list = list()	//what's processing
	var/list/run_cache = list()	//what's left to process in the next run
	var/delegate	//what the processing call is
	var/fire_if_empty = FALSE	//set can_fire to FALSE if idle?

/datum/subsystem/processing/stat_entry(append, forward = FALSE)
	if(forward)
		..(append)
	else if(processing_list)
		..("[stat_tag]:[processing_list.len][append]")
	else
		..("[stat_tag]:FIX THIS SHIT")

/datum/subsystem/processing/proc/start_processing(datum/D)
	var/processors = D.processors
	if(D)
		if(!processors)
			D.processors = list(src)
		else if(src in processors)
			return FALSE
		else
			processors += src
		processing_list += D
		can_fire = TRUE
		return TRUE
	return FALSE

/datum/subsystem/processing/proc/stop_processing(datum/D, killed = FALSE)
	var/list/proc_list = processing_list
	proc_list -= D
	if(!proc_list.len && !fire_if_empty)
		can_fire = FALSE
	var/list/rc = run_cache
	if(!killed && rc.len)
		rc -= D
	if(D)
		LAZYREMOVE(D.processors, src)

/datum/subsystem/processing/fire(resumed = 0, arg = wait)
	var/list/local_cache
	if (!resumed)
		local_cache = processing_list.Copy()
		run_cache = local_cache
	else
		local_cache = run_cache
	//cache for sanic speed (lists are references anyways) = run_cache
	var/local_delegate = delegate

	if(local_cache.len)
		if(local_delegate)
			do	//we know local_cache.len will always at least be 1 if we're here
				var/thing = local_cache[local_cache.len]
				local_cache.len--
				if(!thing || call(thing, local_delegate)(arg) == PROCESS_KILL)
					stop_processing(thing, TRUE)
			while (local_cache.len && MC_TICK_CHECK)
		else	//copy pasta to avoid the call()() overhead for 90% of things
			do
				var/datum/thing = local_cache[local_cache.len]
				local_cache.len--
				if(!thing || thing.process(arg) == PROCESS_KILL)
					stop_processing(thing, TRUE)
			while(local_cache.len && MC_TICK_CHECK)
	else if(!fire_if_empty)
		can_fire = FALSE

/datum/subsystem/processing/Recover(datum/subsystem/processing/predecessor)
	for(var/I in predecessor.processing_list)
		var/datum/D = I
		D.processors -= predecessor
		D.processors += src
	processing_list = predecessor.processing_list		
	run_cache = predecessor.run_cache

/datum/var/list/processors

/datum/Destroy()
	. = ..()
	for(var/I in processors)
		var/datum/subsystem/processing/SS = I
		SS.stop_processing(src)
	LAZYCLEARLIST(processors)

/datum/proc/process(wait)
	set waitfor = FALSE
	return PROCESS_KILL