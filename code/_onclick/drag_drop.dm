/*
	MouseDrop:

	Called on the atom you're dragging.  In a lot of circumstances we want to use the
	receiving object instead, so that's the default action.  This allows you to drag
	almost anything into a trash can.
*/
/atom/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if(!usr || !over)
		return
	if(SEND_SIGNAL(src, COMSIG_MOUSEDROP_ONTO, over, usr) & COMPONENT_NO_MOUSEDROP) //Whatever is receiving will verify themselves for adjacency.
		return
	var/proximity_check = usr.client.check_drag_proximity(src, over, src_location, over_location, src_control, over_control, params)
	if(proximity_check)
		return proximity_check

	if(!Adjacent(usr) || !over.Adjacent(usr))
		return // should stop you from dragging through windows

	over.MouseDrop_T(src,usr, params)
	return

/// Handles treating drags as clicks if they're within some conditions
/// Does some other stuff adjacent to trying to figure out what the user actually "wanted" to click
/// Returns TRUE if it caused a click, FALSE otherwise
/client/proc/check_drag_proximity(atom/dragging, atom/over, src_location, over_location, src_control, over_control, params)
	// We will swap which thing we're trying to check for clickability based off the type
	// Assertion is if you drag a turf to anything else, you really just wanted to click the anything else
	// And slightly misseed. I'm not interested in making this game pixel percise, so if it fits our other requirements
	// Lets just let that through yeah?
	var/atom/attempt_click = dragging
	var/atom/click_from = over
	var/location_to_use = src_location
	var/control_to_use = src_control
	if(isturf(attempt_click) && !isturf(over))
		// swapppp
		attempt_click = over
		click_from = dragging
		location_to_use = over_location
		control_to_use = over_control
		log_runtime("Lieniency Log TURF SWAP!: [src] clicked on [dragging] but we swapped them to [over] instead.")

	if(is_drag_clickable(attempt_click, click_from, params))
		Click(attempt_click, location_to_use, control_to_use, params)
		return TRUE
	return FALSE

// These two are globs for the purpose of testing, convert to defines when you're done
// Distance in pixels that we consider "acceptable" from the initial click to the release
// Note: this does not account for the position of the object, just where it was when we first started the timer
GLOBAL_VAR_INIT(lieniency_distance, 10)
// Accepted time in seconds between the initial click and drag release
// Go higher then this and we just don't care anymore
GLOBAL_VAR_INIT(lieniency_time, 0.1 SECONDS)
/// Does the logic for checking if a drag counts as a click or not
/// Returns true if it does, false otherwise
/client/proc/is_drag_clickable(atom/dragging, atom/over, params)
	if(dragging == over)
		return TRUE
	if(world.time - drag_start > GLOB.lieniency_time) // Time's up bestie
		return FALSE
	if(!get_turf(dragging)) // If it isn't in the world, drop it. This is for things that can move, and we assume hud elements will not have this problem
		log_runtime("Lieniency Log FAILURE (NO TURF)!: [src] got the time right for a drag click, but was NOT on a turf. \n\
			We found it sitting on [dragging.loc] \n\
			They were trying to click [dragging], and instead clicked [over]. \n\
			([params]) \n ([list2params(drag_details)])")
		return FALSE
	var/list/modifiers = params2list(params)
	var/list/old_offsets = screen_loc_to_offset(LAZYACCESS(drag_details, SCREEN_LOC), view)
	var/list/new_offsets = screen_loc_to_offset(LAZYACCESS(modifiers, SCREEN_LOC), view)

	var/extra = ""
	if(isliving(mob))
		extra += "Our Mob:\n"
		extra += drag_mob_extra_details(mob)

	if(isliving(dragging))
		extra += "Dragging Living:\n"
		extra += drag_mob_extra_details(dragging)

	var/distance = sqrt(((old_offsets[1] - new_offsets[1]) ** 2) + ((old_offsets[2] - new_offsets[2]) ** 2))
	if(distance > GLOB.lieniency_distance)
		log_runtime("Lieniency Log FAILURE (TOO FAR)!: [src] got the time right for a drag click, but was too far from the initial point of movement. \n\
			They started at ([old_offsets[1]],[old_offsets[2]]) and moved to ([new_offsets[1]], [new_offsets[2]]) with a total distance of [distance], off the mark from [GLOB.lieniency_distance]. \n\
			They were trying to click [dragging], and instead clicked [over]. \n\
			[extra] \
			([params]) \n ([list2params(drag_details)])")
		return FALSE

	log_runtime("Lieniency Log SUCCESS!: [src] got the time right for a drag click, And hit the correct window too. \n\
		They started at ([old_offsets[1]],[old_offsets[2]]) and moved to ([new_offsets[1]], [new_offsets[2]]) with a total distance of [distance], on target for [GLOB.lieniency_distance]. \n\
		They were trying to click [dragging], and instead clicked [over]. \n\
		[extra] \
		([params]) \n ([list2params(drag_details)])")
	return TRUE

/proc/drag_mob_extra_details(mob/living/details_from)
	var/extra = ""
	var/static/list/aspects_to_read = list(BRUTE, BURN, TOX, OXY, STAMINA, CLONE, BRAIN)
	for(var/type in aspects_to_read)
		extra += "[type]=[details_from.get_damage_amount(type)];"
	extra += "\n"
	var/obj/item/held = details_from.get_active_held_item()
	if(held)
		extra += "Holding : [held]\n"
	return extra

// receive a mousedrop
/atom/proc/MouseDrop_T(atom/dropping, mob/user, params)
	SEND_SIGNAL(src, COMSIG_MOUSEDROPPED_ONTO, dropping, user, params)


/client/MouseDown(datum/object, location, control, params)
	if(QDELETED(object)) //Yep, you can click on qdeleted things before they have time to nullspace. Fun.
		return
	SEND_SIGNAL(src, COMSIG_CLIENT_MOUSEDOWN, object, location, control, params)
	if(mouse_down_icon)
		mouse_pointer_icon = mouse_down_icon
	var/delay = mob.CanMobAutoclick(object, location, params)
	if(delay)
		selected_target[1] = object
		selected_target[2] = params
		while(selected_target[1])
			Click(selected_target[1], location, control, selected_target[2])
			sleep(delay)
	active_mousedown_item = mob.canMobMousedown(object, location, params)
	if(active_mousedown_item)
		active_mousedown_item.onMouseDown(object, location, params, mob)

/client/MouseUp(object, location, control, params)
	if(SEND_SIGNAL(src, COMSIG_CLIENT_MOUSEUP, object, location, control, params) & COMPONENT_CLIENT_MOUSEUP_INTERCEPT)
		click_intercept_time = world.time
	if(mouse_up_icon)
		mouse_pointer_icon = mouse_up_icon
	selected_target[1] = null
	if(active_mousedown_item)
		active_mousedown_item.onMouseUp(object, location, params, mob)
		active_mousedown_item = null

/mob/proc/CanMobAutoclick(object, location, params)

/mob/living/carbon/CanMobAutoclick(atom/object, location, params)
	if(!object.IsAutoclickable())
		return
	var/obj/item/h = get_active_held_item()
	if(h)
		. = h.CanItemAutoclick(object, location, params)

/mob/proc/canMobMousedown(atom/object, location, params)

/mob/living/carbon/canMobMousedown(atom/object, location, params)
	var/obj/item/H = get_active_held_item()
	if(H)
		. = H.canItemMouseDown(object, location, params)

/obj/item/proc/CanItemAutoclick(object, location, params)

/obj/item/proc/canItemMouseDown(object, location, params)
	if(canMouseDown)
		return src

/obj/item/proc/onMouseDown(object, location, params, mob)
	return

/obj/item/proc/onMouseUp(object, location, params, mob)
	return

/atom/proc/IsAutoclickable()
	return TRUE

/atom/movable/screen/IsAutoclickable()
	return FALSE

/atom/movable/screen/click_catcher/IsAutoclickable()
	return TRUE

/client/MouseDrag(src_object,atom/over_object,src_location,over_location,src_control,over_control,params)
	var/list/modifiers = params2list(params)
	if (LAZYACCESS(modifiers, MIDDLE_CLICK))
		if (src_object && src_location != over_location)
			middragtime = world.time
			middle_drag_atom_ref = WEAKREF(src_object)
		else
			middragtime = 0
			middle_drag_atom_ref = null
	if(!drag_start) // If we're just starting to drag
		drag_start = world.time
		drag_details = modifiers.Copy()
	mouseParams = params
	mouse_location_ref = WEAKREF(over_location)
	mouse_object_ref = WEAKREF(over_object)
	if(selected_target[1] && over_object?.IsAutoclickable())
		selected_target[1] = over_object
		selected_target[2] = params
	if(active_mousedown_item)
		active_mousedown_item.onMouseDrag(src_object, over_object, src_location, over_location, params, mob)
	SEND_SIGNAL(src, COMSIG_CLIENT_MOUSEDRAG, src_object, over_object, src_location, over_location, src_control, over_control, params)
	return ..()

/obj/item/proc/onMouseDrag(src_object, over_object, src_location, over_location, params, mob)
	return

/client/MouseDrop(atom/src_object, atom/over_object, atom/src_location, atom/over_location, src_control, over_control, params)
	if (IS_WEAKREF_OF(src_object, middle_drag_atom_ref))
		middragtime = 0
		middle_drag_atom_ref = null
	..()
	drag_start = 0
	drag_details = null
