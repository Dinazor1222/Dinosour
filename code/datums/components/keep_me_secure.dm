/**
 * ### Keep Me Secure component!
 *
 * Component that attaches to items, invoking a function to react when left unmoved and unsecured for too long.
 * Used for Nuclear Authentication Disks, and whiny plushy.
 */
/datum/component/keep_me_secure
	/// callback for the parent being secure
	var/datum/callback/secured_callback
	/// callback for the parent being unsecured
	var/datum/callback/unsecured_callback

	/// The last secure location the parent was at.
	var/turf/last_secured_location
	/// The last world time the parent moved.
	var/last_move

/datum/component/keep_me_secure/Initialize(secured_callback, unsecured_callback)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.secured_callback = secured_callback
	src.unsecured_callback = unsecured_callback

/datum/component/keep_me_secure/RegisterWithParent()
	last_move = world.time
	START_PROCESSING(SSobj, src)

/datum/component/keep_me_secure/UnregisterFromParent()
	STOP_PROCESSING(SSobj, src)

/datum/component/keep_me_secure/proc/is_secured()
	var/obj/item/item_parent = parent
	if (last_secured_location == get_turf(item_parent))
		return FALSE

	var/mob/holder = item_parent.pulledby || get(parent, /mob)
	if (isnull(holder?.client))
		return FALSE

	return TRUE

/datum/component/keep_me_secure/process(delta_time)
	var/turf/current_turf = get_turf(parent)

	if(is_secured())
		last_secured_location = current_turf
		last_move = world.time
		if(secured_callback)
			secured_callback.Invoke(last_move)
	else
		if(unsecured_callback)
			unsecured_callback.Invoke(last_move)
