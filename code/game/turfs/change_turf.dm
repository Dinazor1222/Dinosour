// This is a list of turf types we dont want to assign to baseturfs unless through initialization or explicitly
GLOBAL_LIST_INIT(blacklisted_automated_baseturfs, typecacheof(list(
	/turf/open/space,
	/turf/baseturf_bottom,
	)))

/turf/proc/empty(turf_type=/turf/open/space, baseturf_type, list/ignore_typecache, flags)
	// Remove all atoms except observers, landmarks, docking ports
	var/static/list/ignored_atoms = typecacheof(list(/mob/dead, /obj/effect/landmark, /obj/docking_port))
	var/list/allowed_contents = typecache_filter_list_reverse(get_all_contents_ignoring(ignore_typecache), ignored_atoms)
	allowed_contents -= src
	for(var/i in 1 to allowed_contents.len)
		var/thing = allowed_contents[i]
		qdel(thing, force=TRUE)

	if(turf_type)
		var/turf/new_turf = ChangeTurf(turf_type, baseturf_type, flags)
		SSair.remove_from_active(new_turf)
		CALCULATE_ADJACENT_TURFS(new_turf, KILL_EXCITED)

/turf/proc/copyTurf(turf/copy_to_turf)
	if(copy_to_turf.type != type)
		copy_to_turf.ChangeTurf(type)
	if(copy_to_turf.icon_state != icon_state)
		copy_to_turf.icon_state = icon_state
	if(copy_to_turf.icon != icon)
		copy_to_turf.icon = icon
	if(color)
		copy_to_turf.atom_colours = atom_colours.Copy()
		copy_to_turf.update_atom_colour()
	if(copy_to_turf.dir != dir)
		copy_to_turf.setDir(dir)
	return copy_to_turf

/turf/open/copyTurf(turf/open/copy_to_turf, copy_air = FALSE)
	. = ..()
	ASSERT(istype(copy_to_turf, /turf/open))
	var/datum/component/wet_floor/slip = GetComponent(/datum/component/wet_floor)
	if(slip)
		var/datum/component/wet_floor/new_wet_floor_component = copy_to_turf.AddComponent(/datum/component/wet_floor)
		new_wet_floor_component.InheritComponent(slip)
	if (copy_air)
		copy_to_turf.air.copy_from(air)

//wrapper for ChangeTurf()s that you want to prevent/affect without overriding ChangeTurf() itself
/turf/proc/TerraformTurf(path, new_baseturf, flags)
	return ChangeTurf(path, new_baseturf, flags)

GLOBAL_LIST_EMPTY(change_cost)
GLOBAL_LIST_EMPTY(change_count)
// Creates a new turf
// new_baseturfs can be either a single type or list of types, formated the same as baseturfs. see turf.dm
/turf/proc/ChangeTurf(path, list/new_baseturfs, flags)
	INIT_COST(GLOB.change_cost, GLOB.change_count)
	EXPORT_STATS_TO_CSV_LATER("change.csv", GLOB.change_cost, GLOB.change_count)
	switch(path)
		if(null)
			return
		if(/turf/baseturf_bottom)
			path = SSmapping.level_trait(z, ZTRAIT_BASETURF) || /turf/open/space
			if (!ispath(path))
				path = text2path(path)
				if (!ispath(path))
					warning("Z-level [z] has invalid baseturf '[SSmapping.level_trait(z, ZTRAIT_BASETURF)]'")
					path = /turf/open/space
		if(/turf/open/space/basic)
			// basic doesn't initialize and this will cause issues
			// no warning though because this can happen naturaly as a result of it being built on top of
			path = /turf/open/space
	SET_COST("resolve path")

	if(!GLOB.use_preloader && path == type && !(flags & CHANGETURF_FORCEOP) && (baseturfs == new_baseturfs)) // Don't no-op if the map loader requires it to be reconstructed, or if this is a new set of baseturfs
		SET_COST("check for no-op (success)")
		return src
	SET_COST("check for no-op")
	if(flags & CHANGETURF_SKIP)
		SET_COST("check for skip (success)")
		return new path(src)
	SET_COST("check for skip")

	var/old_lighting_object = lighting_object
	var/old_lighting_corner_NE = lighting_corner_NE
	var/old_lighting_corner_SE = lighting_corner_SE
	var/old_lighting_corner_SW = lighting_corner_SW
	var/old_lighting_corner_NW = lighting_corner_NW
	var/old_directional_opacity = directional_opacity
	var/old_dynamic_lumcount = dynamic_lumcount
	var/old_rcd_memory = rcd_memory
	var/old_explosion_throw_details = explosion_throw_details
	var/old_opacity = opacity
	// I'm so sorry brother
	// This is used for a starlight optimization
	var/old_light_range = light_range
	SET_COST("save old turf details (vars)")
	// We get just the bits of explosive_resistance that aren't the turf
	var/old_explosive_resistance = explosive_resistance - get_explosive_block()
	SET_COST("save old turf details (explosive resistance)")
	var/old_lattice_underneath = lattice_underneath

	var/old_bp = blueprint_data
	blueprint_data = null

	var/list/old_baseturfs = baseturfs
	var/old_type = type
	SET_COST("save old turf details (vars)")

	var/list/post_change_callbacks = list()
	SET_COST("build post_change_callbacks")
	SEND_SIGNAL(src, COMSIG_TURF_CHANGE, path, new_baseturfs, flags, post_change_callbacks)
	SET_COST("send turf_change")

	changing_turf = TRUE
	SET_COST("set changing_turf")
	qdel(src) //Just get the side effects and call Destroy
	SET_COST("delete parent")
	//We do this here so anything that doesn't want to persist can clear itself
	var/list/old_comp_lookup = comp_lookup?.Copy()
	var/list/old_signal_procs = signal_procs?.Copy()
	SET_COST("copy old signal stuff")
	var/turf/new_turf = new path(src)
	SET_COST("make new turf")

	// WARNING WARNING
	// Turfs DO NOT lose their signals when they get replaced, REMEMBER THIS
	// It's possible because turfs are fucked, and if you have one in a list and it's replaced with another one, the list ref points to the new turf
	if(old_comp_lookup)
		LAZYOR(new_turf.comp_lookup, old_comp_lookup)
	if(old_signal_procs)
		LAZYOR(new_turf.signal_procs, old_signal_procs)
	SET_COST("setup old turf signals")

	for(var/datum/callback/callback as anything in post_change_callbacks)
		SET_COST("walk postchange callbacks")
		callback.InvokeAsync(new_turf)
		SET_COST("run postchange callback")
	SET_COST("finish postchange callbacks")

	if(new_baseturfs)
		new_turf.baseturfs = baseturfs_string_list(new_baseturfs, new_turf)
	else
		new_turf.baseturfs = baseturfs_string_list(old_baseturfs, new_turf) //Just to be safe
	SET_COST("stringify baseturfs")

	if(!(flags & CHANGETURF_DEFER_CHANGE))
		new_turf.AfterChange(flags, old_type)
	SET_COST("consume afterchange")

	new_turf.blueprint_data = old_bp
	new_turf.rcd_memory = old_rcd_memory
	new_turf.explosion_throw_details = old_explosion_throw_details
	new_turf.explosive_resistance += old_explosive_resistance

	lighting_corner_NE = old_lighting_corner_NE
	lighting_corner_SE = old_lighting_corner_SE
	lighting_corner_SW = old_lighting_corner_SW
	lighting_corner_NW = old_lighting_corner_NW

	dynamic_lumcount = old_dynamic_lumcount

	lattice_underneath = old_lattice_underneath
	SET_COST("reset old vars")

	if(SSlighting.initialized)
		SET_COST("check lighting init")
		new_turf.lighting_object = old_lighting_object

		directional_opacity = old_directional_opacity
		SET_COST("set old light stuff")
		recalculate_directional_opacity()
		SET_COST("recalc opacity")

		if(lighting_object && !lighting_object.needs_update)
			lighting_object.update()
			SET_COST("update lighting object")
	else
		SET_COST("check lighting init")

	if(isspaceturf(src) && CONFIG_GET(flag/starlight))
		SET_COST("check starlight home")
		var/turf/open/space/lit_turf = src
		SET_COST("cast src to space")
		// This also counts as a removal, so we need to do a full rebuild
		if(!ispath(old_type, /turf/open/space))
			SET_COST("check old space")
			lit_turf.update_starlight()
			SET_COST("update our starlight")
			for(var/turf/open/space/space_tile in RANGE_TURFS(1, src) - src)
				SET_COST("walk update starlight")
				space_tile.update_starlight()
				SET_COST("update starlight")
		else
			SET_COST("check old space")
			if(old_light_range)
				SET_COST("check old range")
				lit_turf.enable_starlight()
				SET_COST("enable our starlight")
			else
				SET_COST("check old range")
	else if (istype(src, /turf/cordon) && CONFIG_GET(flag/starlight))
		SET_COST("check starlight home")
		// This counts as removing a source of starlight, so we need to update the space tile to inform it
		if(!ispath(old_type, /turf/open/space))
			SET_COST("check cordon type")
			for(var/turf/open/space/space_tile in RANGE_TURFS(1, src))
				SET_COST("walk cordon starlight")
				space_tile.update_starlight()
				SET_COST("cordon update starlight")
		else
			SET_COST("check cordon type")

	else if(ispath(old_type, /turf/open/space) && CONFIG_GET(flag/starlight))
		SET_COST("check starlight home")
		for(var/turf/open/space/space_tile in RANGE_TURFS(1, src))
			SET_COST("walk enable starlight")
			space_tile.enable_starlight()
			SET_COST("enable starlight")
	else
		SET_COST("check starlight home")

	if(old_opacity != opacity)
		GLOB.cameranet.updateVisibility(src)
	SET_COST("check visiblity")

#warn space should not have lighting objects
	// We will only run this logic if the tile is not on the prime z layer, since we use area overlays to cover that
	if(SSmapping.z_level_to_plane_offset[z])
		SET_COST("check plane offset (success)")
		var/area/our_area = new_turf.loc
		if(our_area.lighting_effects)
			new_turf.add_overlay(our_area.lighting_effects[SSmapping.z_level_to_plane_offset[z] + 1])
	else
		SET_COST("check plane offset")

	 // only queue for smoothing if SSatom initialized us, and we'd be changing smoothing state
	if(flags_1 & INITIALIZED_1)
		QUEUE_SMOOTH_NEIGHBORS(src)
		QUEUE_SMOOTH(src)
	SET_COST("handle smoothing")

	return new_turf

/turf/open/ChangeTurf(path, list/new_baseturfs, flags) //Resist the temptation to make this default to keeping air.
	INIT_COST(GLOB.change_cost, GLOB.change_count)
	if ((flags & CHANGETURF_INHERIT_AIR) && ispath(path, /turf/open))
		SET_COST("check for air inherit")
		var/datum/gas_mixture/stashed_air = new()
		stashed_air.copy_from(air)
		SET_COST("stash air")
		var/stashed_state = excited
		var/datum/excited_group/stashed_group = excited_group
		SET_COST("stash vars")
		. = ..() //If path == type this will return us, don't bank on making a new type
		SET_COST("parent call consume")
		if (!.) // changeturf failed or didn't do anything
			SET_COST("check .")
			return
		SET_COST("check .")
		var/turf/open/new_turf = .
		new_turf.air.copy_from(stashed_air)
		SET_COST("copy old air")
		new_turf.excited = stashed_state
		new_turf.excited_group = stashed_group
		SET_COST("copy old vars")
		#ifdef VISUALIZE_ACTIVE_TURFS
		if(stashed_state)
			new_turf.add_atom_colour(COLOR_VIBRANT_LIME, TEMPORARY_COLOUR_PRIORITY)
		#endif
		if(stashed_group)
			if(stashed_group.should_display || SSair.display_all_groups)
				stashed_group.display_turf(new_turf)
	else
		SSair.remove_from_active(src) //Clean up wall excitement, and refresh excited groups
		SET_COST("remove from active")
		if(ispath(path,/turf/closed) || ispath(path,/turf/cordon))
			flags |= CHANGETURF_RECALC_ADJACENT
			SET_COST("set recalc adjacent")
		return ..()

//If you modify this function, ensure it works correctly with lateloaded map templates.
/turf/proc/AfterChange(flags, oldType) //called after a turf has been replaced in ChangeTurf()
	levelupdate()
	if(flags & CHANGETURF_RECALC_ADJACENT)
		immediate_calculate_adjacent_turfs()
		if(ispath(oldType, /turf/closed) && isopenturf(src))
			SSair.add_to_active(src)
	else //In effect, I want closed turfs to make their tile active when sheered, but we need to queue it since they have no adjacent turfs
		CALCULATE_ADJACENT_TURFS(src, (!(ispath(oldType, /turf/closed) && isopenturf(src)) ? NORMAL_TURF : MAKE_ACTIVE))

/turf/open/AfterChange(flags, oldType)
	..()
	RemoveLattice()
	if(!(flags & (CHANGETURF_IGNORE_AIR | CHANGETURF_INHERIT_AIR)))
		Assimilate_Air()

//////Assimilate Air//////
/turf/open/proc/Assimilate_Air()
	var/turf_count = LAZYLEN(atmos_adjacent_turfs)
	if(blocks_air || !turf_count) //if there weren't any open turfs, no need to update.
		return

	var/datum/gas_mixture/total = new//Holders to assimilate air from nearby turfs
	var/list/total_gases = total.gases
	//Stolen blatently from self_breakdown
	var/list/turf_list = atmos_adjacent_turfs + src
	var/turflen = turf_list.len
	var/energy = 0
	var/heat_cap = 0

	for(var/turf/open/turf in turf_list)
		//Cache?
		var/datum/gas_mixture/turf/mix = turf.air
		//"borrowing" this code from merge(), I need to play with the temp portion. Lets expand it out
		//temperature = (giver.temperature * giver_heat_capacity + temperature * self_heat_capacity) / combined_heat_capacity
		var/capacity = mix.heat_capacity()
		energy += mix.temperature * capacity
		heat_cap += capacity

		var/list/giver_gases = mix.gases
		for(var/giver_id in giver_gases)
			ASSERT_GAS(giver_id, total)
			total_gases[giver_id][MOLES] += giver_gases[giver_id][MOLES]

	total.temperature = energy / heat_cap
	for(var/id in total_gases)
		total_gases[id][MOLES] /= turflen

	for(var/turf/open/turf in turf_list)
		turf.air.copy_from(total)
		turf.update_visuals()
		SSair.add_to_active(turf)

/// Attempts to replace a tile with lattice. Amount is the amount of tiles to scrape away.
/turf/proc/attempt_lattice_replacement(amount = 2)
	if(lattice_underneath)
		var/turf/new_turf = ScrapeAway(amount, flags = CHANGETURF_INHERIT_AIR)
		if(!istype(new_turf, /turf/open/floor))
			new /obj/structure/lattice(src)
	else
		ScrapeAway(amount, flags = CHANGETURF_INHERIT_AIR)
