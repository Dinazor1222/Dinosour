// Add to clothing to give the wearer a mood buff and a unique examine str

/datum/component/onwear_mood
	/// the event the wearer experiences
	var/datum/mood_event/saved_event
	/// examine string added to examine
	var/examine_string

/datum/component/onwear_mood/Initialize(clear_after, datum/mood_event/saved_event, examine_string)

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	if(istype(saved_event))
		src.saved_event = saved_event

	src.examine_string = examine_string

	if(isnum(clear_after))
		QDEL_IN(src, clear_after)

/datum/component/onwear_mood/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/affect_wearer)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/clear_effects)

/datum/component/onwear_mood/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	clear_effects()

/datum/component/onwear_mood/proc/affect_wearer(datum/source, mob/target)
	SIGNAL_HANDLER
	target.add_mood_event(REF(src), saved_event)
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/component/onwear_mood/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += span_notice(examine_string)

/// clears the effects on the wearer
/datum/component/onwear_mood/proc/clear_effects(datum/source, mob/target)
	SIGNAL_HANDLER
	target = target || loc
	if(!istype(target))
		return
	UnregisterSignal(target, COMSIG_PARENT_EXAMINE)
	target.clear_mood_event(REF(src))

/datum/component/onwear_mood/Destroy(force, silent)
	clear_effects()
	. = ..()
