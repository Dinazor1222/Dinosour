/**
 * ##temporary_body
 *
 * Used on carbons when they are meant to be a 'temporary body'
 * Holds a reference to an old mind & body, to put them back in
 * once this temporary one is being deleted.
 */
/datum/component/temporary_body
	///The old mind we will be put back into when parent is being deleted.
	var/datum/mind/old_mind
	///The old body we will be put back into when parent is being deleted.
	var/mob/living/old_body

	///A callback sent once parent's mind is returned to their old body.
	var/datum/callback/body_return_callback

/datum/component/temporary_body/Initialize(old_mind, old_body, body_return_callback)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.old_mind = old_mind
	src.old_body = old_body
	src.body_return_callback = body_return_callback

/datum/component/temporary_body/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(on_parent_destroy))

/datum/component/bakeable/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_QDELETING)

/**
 * Sends the mind of the temporary body back into their previous host
 * If the previous host is alive, we'll force them into the body.
 * Otherwise we'll let them hang out as a ghost still.
 */
/datum/component/temporary_body/proc/on_parent_destroy()
	SIGNAL_HANDLER
	if(QDELETED(old_mind) || QDELETED(old_body))
		return

	var/mob/living/living_parent = parent
	var/mob/dead/observer/ghost = living_parent.ghostize()
	if(!ghost)
		ghost = living_parent.get_ghost()
	if(!ghost)
		CRASH("[src] belonging to [parent] was completely unable to find a ghost to put back into a body!")
	ghost.mind = old_mind
	old_mind.set_current(old_body)
	if(old_body.stat != DEAD)
		old_body.key = old_mind.key

	if(body_return_callback)
		body_return_callback.Invoke(old_mind, old_body)
	old_mind = null
	old_body = null
