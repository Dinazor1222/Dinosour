var/datum/subsystem/augury/SSaugury

/datum/subsystem/augury
	name = "Augury"
	flags = SS_NO_INIT

	var/list/watchers = list()
	var/list/doombringers = list()

	var/list/observers_given_action = list()

/datum/subsystem/augury/New()
	NEW_SS_GLOBAL(SSaugury)

/datum/subsystem/augury/stat_entry(msg)
	..("W:[watchers.len]|D:[doombringers.len]")

/datum/subsystem/augury/proc/register_doom(atom/A, severity)
	doombringers[A] = severity

/datum/subsystem/augury/fire()
	var/biggest_doom = null
	var/biggest_threat = null

	for(var/db in doombringers)
		var/datum/d = db
		if(!d || qdeleted(d))
			doombringers -= d
			continue
		var/threat = doombringers[d]
		if((biggest_threat == null) || (biggest_threat < threat))
			biggest_doom = d
			biggest_threat = threat

	if(doombringers.len)
		for(var/i in player_list)
			if(isobserver(i) && (!(observers_given_action[i])))
				var/datum/action/innate/augury/A = new
				A.Grant(i)
				observers_given_action[i] = TRUE
	else
		for(var/i in observers_given_action)
			if(observers_given_action[i] && isobserver(i))
				var/mob/dead/observer/O = i
				for(var/datum/action/innate/augury/A in O.actions)
					qdel(A)
			observers_given_action -= i

	for(var/w in watchers)
		if(!w)
			watchers -= w
			continue
		var/mob/dead/observer/O = w
		if(biggest_doom && (!O.orbiting || O.orbiting.orbiting != biggest_doom))
			O.ManualFollow(biggest_doom)

/datum/action/innate/augury
	name = "Auto Follow Debris"
	icon_icon = 'icons/obj/meteor.dmi'
	button_icon_state = "flaming"
	background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND

/datum/action/innate/augury/Destroy()
	if(owner)
		SSaugury.watchers -= owner
	return ..()

/datum/action/innate/augury/Activate()
	SSaugury.watchers += owner
	owner << "<span class='notice'>You are now auto-following debris.</span>"
	active = TRUE
	UpdateButtonIcon()

/datum/action/innate/augury/Deactivate()
	SSaugury.watchers -= owner
	owner << "<span class='notice'>You are no longer auto-following debris.</span>"
	active = FALSE
	UpdateButtonIcon()

/datum/action/innate/augury/UpdateButtonIcon(status_only = FALSE)
	..()
	if(active)
		button.icon_state = "template_active"
	else
		button.icon_state = "template"
