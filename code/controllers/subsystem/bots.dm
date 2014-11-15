var/datum/subsystem/bots/SSbot

/datum/subsystem/bots
	name = "Bots"
	priority = 8

	var/list/processing = list()

/datum/subsystem/bots/New()
	NEW_SS_GLOBAL(SSbot)

/datum/subsystem/bots/fire()
	set background = BACKGROUND_ENABLED

	var/seconds = wait * 0.1
	var/i=1
	for(var/thing in processing)
		if(thing && !thing:gc_destroyed)
			spawn(-1)
				thing:bot_process(seconds)
			++i
			continue
		processing.Cut(i, i+1)