//Status effects are used to apply temporary or permanent effects to mobs. Mobs are aware of their status effects at all times.
//This file contains their code, plus code for applying and removing them.
//When making a new status effect, add a define to status_effects.dm in __DEFINES for ease of use!
var/list/status_effects = list() //All status effects affecting literally anyone
/datum/status_effect
	var/name = "Curse of Mundanity"
	var/desc = "You don't feel any different..."
	var/id = "effect" //Used for screen alerts.
	var/icon_state //Used for displaying the status effect.
	var/duration = -1 //How long the status effect lasts in SECONDS. Enter -1 for an effect that never ends unless removed through some means.
	var/tick_interval = 1 //How many seconds between ticks. Leave at 1 for every second.
	var/mob/living/owner //The mob affected by the status effect.
	var/cosmetic = FALSE //If the status effect only exists for flavor.
	var/unique = TRUE //If there can be multiple status effects of this type on one mob.

/datum/status_effect/New(mob/living/new_owner)
	..()
	if(!new_owner)
		qdel(src)
	owner = new_owner
	status_effects["\ref[owner][id]"] = src
 	start_ticking()

/datum/status_effect/Destroy()
    status_effects -= "\ref[owner][id]"
    return ..()

/datum/status_effect/proc/start_ticking()
	if(!src)
		return
	on_apply()
	owner.throw_alert(id, /obj/screen/alert, effect = src)
	START_PROCESSING(SSprocessing, src)

/datum/status_effect/process()
	if(duration != -1)
		duration--
	tick_interval--
	if(!tick_interval)
		tick()
		tick_interval = initial(tick_interval)
	if(!duration && duration != -1)
		cancel_effect()

/datum/status_effect/proc/cancel_effect()
	STOP_PROCESSING(SSprocessing, src)
	owner.clear_alert(id)
	on_remove()
	qdel(src)

/datum/status_effect/proc/on_apply() //Called whenever the buff is applied.
/datum/status_effect/proc/tick() //Called every tick.
/datum/status_effect/proc/on_remove() //Called whenever the buff expires or is removed.

//////////////////
// HELPER PROCS //
//////////////////

/mob/living/proc/apply_status_effect(datum/status_effect/effect)
	if(status_effects["\ref[src][initial(effect.id)]"] && initial(effect.unique))
		return 0
	new effect(src)
	return 1

/mob/living/proc/remove_status_effect(datum/status_effect/effect)
    var/datum/status_effect/S = status_effects["\ref[src][initial(effect.id)]"]
    if(!S)
        return 0
    qdel(S)
    return 1
