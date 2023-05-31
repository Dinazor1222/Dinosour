/datum/element/waddling

/datum/element/waddling/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	if(isliving(target))
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(LivingWaddle))
	else
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(Waddle))

/datum/element/waddling/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)


/datum/element/waddling/proc/LivingWaddle(mob/living/targetmob, atom/oldloc, direction, forced)
	SIGNAL_HANDLER

	if(forced || target.incapacitated() || target.body_position == LYING_DOWN || CHECK_MOVE_LOOP_FLAGS(target, MOVEMENT_LOOP_OUTSIDE_CONTROL))
		return
	waddling_animation(target)


/datum/element/waddling/proc/Waddle(atom/movable/target, atom/oldloc, direction, forced)
	SIGNAL_HANDLER

	if(forced || CHECK_MOVE_LOOP_FLAGS(target, MOVEMENT_LOOP_OUTSIDE_CONTROL))
		return
	waddling_animation(target)

/datum/element/waddling/proc/waddling_animation(atom/movable/target)
	animate(target, pixel_z = 4, time = 0)
	var/prev_trans = matrix(target.transform)
	animate(pixel_z = 0, transform = turn(target.transform, pick(-12, 0, 12)), time=2)
	animate(pixel_z = 0, transform = prev_trans, time = 0)
