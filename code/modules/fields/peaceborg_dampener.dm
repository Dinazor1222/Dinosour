
//Projectile dampening field that slows projectiles and lowers their damage for an energy cost deducted every 1/5 second.
//Only use square radius for this!
/datum/field/peaceborg_dampener
	name = "\improper Hyperkinetic Dampener Field"
	requires_processing = TRUE
	setup_edge_turfs = TRUE
	setup_field_turfs = TRUE
	field_shape = FIELD_SHAPE_RADIUS_SQUARE
	var/static/image/edgeturf_south = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_south")
	var/static/image/edgeturf_north = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_north")
	var/static/image/edgeturf_west = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_west")
	var/static/image/edgeturf_east = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_east")
	var/static/image/northwest_corner = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_northwest")
	var/static/image/southwest_corner = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_southwest")
	var/static/image/northeast_corner = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_northeast")
	var/static/image/southeast_corner = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_southeast")
	var/list/turf/turf_overlay_tracker
	var/obj/item/borg/projectile_dampen/projector = null
	var/list/obj/item/projectile/tracked

/datum/field/peaceborg_dampener/New()
	turf_overlay_tracker = list()
	tracked = list()

/datum/field/peaceborg_dampener/process()
	if(!istype(projector))
		qdel(src)
	var/list/ranged = list()
	for(var/obj/item/projectile/P in range(square_radius, center))
		ranged += P
	for(var/obj/item/projectile/P in tracked)
		if(!P in ranged)
			release_projectile(P)
	for(var/mob/living/silicon/robot/R in range(square_radius, center))
		if(R.buckled_mobs)
			for(var/mob/living/L in R.buckled_mobs)
				L.visible_message("<span class='warning'>[L] is knocked off of [R] by the charge in [R]'s chassis induced by [name]!</span>")	//I know it's bad.
				L.Weaken(3)
				R.unbuckle_mob(L)
				do_sparks(5, 0, L)
	..()

/datum/field/peaceborg_dampener/setup_edge_turf(turf/T)
	..()
	var/dir_found = get_edgeturf_direction(T)
	T.add_overlay(get_edgeturf_overlay(dir_found))
	turf_overlay_tracker[T] = dir_found

/datum/field/peaceborg_dampener/cleanup_edge_turf(turf/T)
	T.cut_overlay(get_edgeturf_overlay(turf_overlay_tracker[T]))
	turf_overlay_tracker -= T
	..()

/datum/field/peaceborg_dampener/proc/get_edgeturf_overlay(direction)
	switch(direction)
		if(NORTH)
			return edgeturf_north
		if(SOUTH)
			return edgeturf_south
		if(EAST)
			return edgeturf_east
		if(WEST)
			return edgeturf_west
		if(NORTHEAST)
			return northeast_corner
		if(NORTHWEST)
			return northwest_corner
		if(SOUTHEAST)
			return southeast_corner
		if(SOUTHWEST)
			return southwest_corner

/datum/field/peaceborg_dampener/proc/capture_projectile(obj/item/projectile/P, track_projectile = TRUE)
	if(P in tracked)
		return
	projector.dampen_projectile(P, track_projectile)
	if(track_projectile)
		tracked += P
	world << "Captured [P] tracking [track_projectile]"

/datum/field/peaceborg_dampener/proc/release_projectile(obj/item/projectile/P)
	projector.restore_projectile(P)
	tracked -= P
	world << "Releasing [P]"

/datum/field/peaceborg_dampener/field_edge_uncrossed(atom/movable/AM, atom/movable/field_object/field_edge/F)
	if(!is_turf_in_field(get_turf(AM), src))
		if(istype(AM, /obj/item/projectile))
			if(AM in tracked)
				release_projectile(AM)
			else
				capture_projectile(AM, FALSE)
	return ..()

/datum/field/peaceborg_dampener/field_edge_crossed(atom/movable/AM, atom/movable/field_object/field_edge/F)
	if(istype(AM, /obj/item/projectile) && !(AM in tracked))
		capture_projectile(AM)
	return ..()
