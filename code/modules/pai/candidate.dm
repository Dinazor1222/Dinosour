/// Created when a user clicks the "pAI candidate" window
/datum/pai_candidate
	/// User inputted OOC comments
	var/comments
	/// User inputted behavior description
	var/description
	/// User's ckey
	var/ckey
	/// User's pAI name. If blank, ninja name.
	var/name
	/// If the user has hit "submit"
	var/ready = FALSE

/datum/pai_candidate/New(mob/user)
	src.ckey = user.ckey

/**
 * Checks if a candidate is ready so that they may be displayed in the pAI
 * card's candidate window
 */
/datum/pai_candidate/proc/check_ready()
	if(!ready)
		return FALSE
	for(var/mob/dead/observer/ghost as anything in GLOB.player_list)
		if(ghost.ckey != ckey)
			continue
		if(ghost.client && !is_banned_from(ghost.ckey, ROLE_PAI))
			return TRUE
	if(SSpai.candidates[ckey])
		SSpai.candidates.Remove(ckey)
		return FALSE

