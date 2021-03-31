/// You can't use items on anyone other than yourself if you stand in a blacklisted room
/datum/component/shy_room
	can_transfer = TRUE
	/// Typecache of areas you can't stand
	var/list/blacklist
	/// Message shown when you are in a blacklisted room
	var/message = "%ROOM is too creepy to do that!"

/// _blacklist, and _message map to vars
/datum/component/shy_room/Initialize(_blacklist, _message)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	blacklist = _blacklist
	if(_message)
		message = _message

/datum/component/shy_room/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_CLICKON, .proc/frightened_click)
	RegisterSignal(parent, COMSIG_LIVING_TRY_PULL, .proc/frightened_pull)
	RegisterSignal(parent, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HUMAN_EARLY_UNARMED_ATTACK), .proc/frightened_unarmed)

/datum/component/shy_room/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_CLICKON, COMSIG_LIVING_TRY_PULL, COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HUMAN_EARLY_UNARMED_ATTACK))

/datum/component/shy_room/PostTransfer()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/shy_room/InheritComponent(datum/component/shy_room/friend, i_am_original, list/arguments)
	if(i_am_original)
		blacklist = friend.blacklist
		message = friend.message

/// Returns TRUE or FALSE if you are in a blacklisted area
/datum/component/shy_room/proc/frightened(atom/A)
	var/mob/owner = parent
	if(!length(blacklist) || (A in owner.DirectAccess()))
		return

	var/area/room = get_area(owner)
	if(is_type_in_typecache(room, blacklist))
		to_chat(owner, "<span class='warning'>[replacetext(message, "%ROOM", room)]</span>")
		return TRUE

/datum/component/shy_room/proc/frightened_click(datum/source, atom/A, params)
	return frightened(A) && COMSIG_MOB_CANCEL_CLICKON

/datum/component/shy_room/proc/frightened_pull(datum/source, atom/movable/AM, force)
	return frightened(AM) && COMSIG_LIVING_CANCEL_PULL

/datum/component/shy_room/proc/frightened_unarmed(datum/source, atom/target, proximity, modifiers)
	return frightened(target) && COMPONENT_CANCEL_ATTACK_CHAIN

