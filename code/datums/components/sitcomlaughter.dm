/datum/component/wearertargeting/sitcomlaughter
	valid_slots = list(ITEM_SLOT_HANDS, ITEM_SLOT_BELT, ITEM_SLOT_ID, ITEM_SLOT_LPOCKET, ITEM_SLOT_RPOCKET, ITEM_SLOT_SUITSTORE, ITEM_SLOT_DEX_STORAGE)
	signals = list(COMSIG_MOB_CREAMED, COMSIG_ON_CARBON_SLIP, COMSIG_ON_VENDOR_CRUSH, COMSIG_MOB_CLUMSY_SHOOT_FOOT)
	proctype = .proc/EngageInComedy
	mobtype = /mob/living
	///Sounds used for when user has a sitcom action occur
	var/list/comedysounds = list('sound/items/SitcomLaugh1.ogg', 'sound/items/SitcomLaugh2.ogg', 'sound/items/SitcomLaugh3.ogg')
	///Invoked in EngageInComedy is ran
	var/datum/callback/post_comedy_callback

/datum/component/wearertargeting/sitcomlaughter/Initialize(post_comedy_callback)
	. = ..()
	if(.) //If this is set something went wrong and we shouldn't init
		return
	src.post_comedy_callback = post_comedy_callback


///Play the laugh track if any of the signals related to comedy have been sent.
/datum/component/wearertargeting/sitcomlaughter/proc/EngageInComedy(datum/source)
	SIGNAL_HANDLER
	playsound(parent, pick(comedysounds), 100, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
	post_comedy_callback?.Invoke(source)
