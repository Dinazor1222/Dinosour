/datum/spatial_grid_cell
	///our x index in the list of cells. this is our index inside of our row list
	var/cell_x
	///our y index in the list of cells. this is the index of our row list inside of our z level grid
	var/cell_y
	///which z level we belong to, corresponding to the index of our gridmap in SSspatial_grid.grids_by_z_level
	var/cell_z
	//every data point in a grid cell is separated by usecase

	///every hearing sensitive movable inside this cell
	var/list/hearing_contents = list()
	///every client possessed mob inside this cell
	var/list/client_contents = list()

/datum/spatial_grid_cell/New(cell_x, cell_y, cell_z)
	. = ..()
	src.cell_x = cell_x
	src.cell_y = cell_y
	src.cell_z = cell_z

/datum/spatial_grid_cell/Destroy(force, ...)
	if(force)//the response to someone trying to qdel this is a right proper fuck you
		return

	. = ..()

/**
 * # Spatial Grid
 * a gamewide grid of spatial_grid_cell datums, each "covering" SPATIAL_GRID_CELLSIZE ^ 2 turfs
 * each spatial_grid_cell datum stores information about what is inside its covered area, so that searches through that area dont have to literally search
 * through all turfs themselves to know what is within it since view() calls are expensive, and so is iterating through stuff you dont want.
 * this allows you to only go through lists of what you want very cheaply
 *
 * you can also register to objects entering and leaving a spatial cell, this allows you to do things like stay idle until a player enters, so you wont
 * have to use expensive view() calls or iteratite over the global list of players and call get_dist() on every one. which is fineish for a few things, but is
 * k * n operations for k objects iterating through n players
 *
 * currently this system is only designed for searching for relatively uncommon things, small subsets of /atom/movable
 * dont add stupid shit to the cells please, keep the information that the cells store to things that need to be searched for often
 *
 * as of right now this system operates on a subset of the important_recursive_contents list for atom/movable, specifically
 * RECURSIVE_CONTENTS_HEARING_SENSITIVE and RECURSIVE_CONTENTS_CLIENT_MOBS because both are those are both 1. important and 2. commonly searched for
 */

SUBSYSTEM_DEF(spatial_grid)
	can_fire = FALSE
	init_order = INIT_ORDER_SPATIAL_GRID
	name = "Spatial Grid"

	///list of the spatial_grid_cell datums per z level, arranged in the order of y index then x index
	var/list/grids_by_z_level = list()
	///everything that spawns before us is added to this list until we initialize
	var/list/waiting_to_add_by_type = list(RECURSIVE_CONTENTS_HEARING_SENSITIVE = list(), RECURSIVE_CONTENTS_CLIENT_MOBS = list())

	var/cells_on_x_axis = 0
	var/cells_on_y_axis = 0
/datum/controller/subsystem/spatial_grid/Initialize(start_timeofday)
	. = ..()

	cells_on_x_axis = SPATIAL_GRID_CELLS_PER_SIDE(world.maxx)
	cells_on_y_axis = SPATIAL_GRID_CELLS_PER_SIDE(world.maxy)

	for(var/datum/space_level/z_level as anything in SSmapping.z_list)
		propogate_spatial_grid_to_new_z(null, z_level)
		CHECK_TICK_HIGH_PRIORITY

	//for anything waiting to be let in
	for(var/channel_type in waiting_to_add_by_type)
		for(var/atom/movable/movable as anything in waiting_to_add_by_type[channel_type])
			var/turf/movable_turf = get_turf(movable)
			if(movable_turf)
				enter_cell(movable, movable_turf)

			UnregisterSignal(movable, COMSIG_PARENT_PREQDELETED)
			waiting_to_add_by_type[channel_type] -= movable

	RegisterSignal(SSdcs, COMSIG_GLOB_NEW_Z, .proc/propogate_spatial_grid_to_new_z)
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPANDED_WORLD_BOUNDS, .proc/after_world_bounds_expanded)

/datum/controller/subsystem/spatial_grid/proc/enter_pre_init_queue(atom/movable/waiting_movable, type)
	RegisterSignal(waiting_movable, COMSIG_PARENT_PREQDELETED, .proc/queued_item_deleted, override = TRUE)
	//override because something can enter the queue for two different types but that is done through unrelated procs that shouldnt know about eachother
	waiting_to_add_by_type[type] += waiting_movable

///removes an initialized and probably deleted movable from our pre init queue before we're initialized
/datum/controller/subsystem/spatial_grid/proc/remove_from_pre_init_queue(atom/movable/movable_to_remove, exclusive_type)
	if(exclusive_type)
		waiting_to_add_by_type[exclusive_type] -= movable_to_remove

		var/waiting_movable_is_in_other_queues = FALSE//we need to check if this movable is inside the other queues
		for(var/type in waiting_to_add_by_type)
			if(movable_to_remove in waiting_to_add_by_type[type])
				waiting_movable_is_in_other_queues = TRUE

		if(!waiting_movable_is_in_other_queues)
			UnregisterSignal(movable_to_remove, COMSIG_PARENT_PREQDELETED)

		return

	UnregisterSignal(movable_to_remove, COMSIG_PARENT_PREQDELETED)
	for(var/type in waiting_to_add_by_type)
		waiting_to_add_by_type[type] -= movable_to_remove

///if a movable is inside our pre init queue before we're initialized and it gets deleted we need to remove that reference with this proc
/datum/controller/subsystem/spatial_grid/proc/queued_item_deleted(atom/movable/movable_being_deleted)
	SIGNAL_HANDLER
	remove_from_pre_init_queue(movable_being_deleted, null)

///creates the spatial grid for a new z level
/datum/controller/subsystem/spatial_grid/proc/propogate_spatial_grid_to_new_z(datum/controller/subsystem/processing/dcs/fucking_dcs, datum/space_level/z_level)
	SIGNAL_HANDLER

	var/list/new_cell_grid = list()

	grids_by_z_level += list(new_cell_grid)

	for(var/y in 1 to cells_on_y_axis)
		new_cell_grid += list(list())
		for(var/x in 1 to cells_on_x_axis)
			var/datum/spatial_grid_cell/cell = new(x, y, z_level.z_value)
			new_cell_grid[y] += cell

///adds cells to the grid for every z level when world.maxx or world.maxy is expanded after this subsystem is initialized. hopefully this is never needed
/datum/controller/subsystem/spatial_grid/proc/after_world_bounds_expanded(datum/controller/subsystem/processing/dcs/fucking_dcs, has_expanded_world_maxx, has_expanded_world_maxy)
	SIGNAL_HANDLER
	var/old_x_axis = cells_on_x_axis
	var/old_y_axis = cells_on_y_axis

	cells_on_x_axis = SPATIAL_GRID_CELLS_PER_SIDE(world.maxx)
	cells_on_y_axis = SPATIAL_GRID_CELLS_PER_SIDE(world.maxy)

	for(var/z_level in 1 to length(grids_by_z_level))
		var/list/z_level_gridmap = grids_by_z_level[z_level]

		for(var/cell_row_for_expanded_y_axis in 1 to cells_on_y_axis)

			if(cell_row_for_expanded_y_axis > old_y_axis)//we are past the old length of the number of rows, so add to the list
				z_level_gridmap += list(list())

			//now we know theres a row at this position, so add cells to it that need to be added and update the ones that already exist
			var/list/cell_row = z_level_gridmap[cell_row_for_expanded_y_axis]

			for(var/grid_cell_for_expanded_x_axis in 1 to cells_on_x_axis)

				if(grid_cell_for_expanded_x_axis > old_x_axis)
					var/datum/spatial_grid_cell/new_cell_inserted = new(grid_cell_for_expanded_x_axis, cell_row_for_expanded_y_axis, z_level)
					cell_row += new_cell_inserted
					continue

				//now we know the cell index we're at contains an already existing cell that needs its x and y values updated
				var/datum/spatial_grid_cell/old_cell_that_needs_updating = cell_row[grid_cell_for_expanded_x_axis]
				old_cell_that_needs_updating.cell_x = grid_cell_for_expanded_x_axis
				old_cell_that_needs_updating.cell_y = cell_row_for_expanded_y_axis


#define BOUNDING_BOX_MIN(center_coord) max(ROUND_UP((center_coord - range) / SPATIAL_GRID_CELLSIZE), 1)
#define BOUNDING_BOX_MAX(center_coord, axis_size) min(ROUND_UP((center_coord + range) / SPATIAL_GRID_CELLSIZE), axis_size)

/**
 * https://en.wikipedia.org/wiki/Range_searching#Orthogonal_range_searching
 *
 * searches through the grid cells intersecting a rectangular search space (with sides of length 2 * range) then returns all contents of type inside them.
 * much faster than iterating through view() to find all of what you want for things that arent that common.
 *
 * this does NOT return things only in range distance from center! the search space is a square not a circle, if you want only thing in a certain distance
 * then you need to filter that yourself
 *
 * * center - the atom that is the center of the searched circle
 * * type - the type of grid contents you are looking for, see __DEFINES/spatial_grid.dm
 * * range - the bigger this is, the more spatial grid cells the search space intersects
 */
/datum/controller/subsystem/spatial_grid/proc/orthogonal_range_search(atom/center, type, range)
	var/turf/center_turf = get_turf(center)

	var/center_x = center_turf.x//used inside the macros
	var/center_y = center_turf.y

	. = list()

	//cache for sanic speeds
	var/cells_on_y_axis = src.cells_on_y_axis
	var/cells_on_x_axis = src.cells_on_x_axis

	//technically THIS list only contains lists, but inside those lists are grid cell datums and we can go without a SINGLE var init if we do this
	var/list/datum/spatial_grid_cell/grid_level = grids_by_z_level[center_turf.z]
	switch(type)
		if(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)
			for(var/row in BOUNDING_BOX_MIN(center_y) to BOUNDING_BOX_MAX(center_y, cells_on_y_axis))
				for(var/x_index in BOUNDING_BOX_MIN(center_x) to BOUNDING_BOX_MAX(center_x, cells_on_x_axis))

					. += grid_level[row][x_index].client_contents

		if(SPATIAL_GRID_CONTENTS_TYPE_HEARING)
			for(var/row in BOUNDING_BOX_MIN(center_y) to BOUNDING_BOX_MAX(center_y, cells_on_y_axis))
				for(var/x_index in BOUNDING_BOX_MIN(center_x) to BOUNDING_BOX_MAX(center_x, cells_on_x_axis))

					. += grid_level[row][x_index].hearing_contents

	return .

///get the grid cell encomapassing targets coordinates
/datum/controller/subsystem/spatial_grid/proc/get_cell_of(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return

	return grids_by_z_level[target_turf.z][ROUND_UP(target_turf.y / SPATIAL_GRID_CELLSIZE)][ROUND_UP(target_turf.x / SPATIAL_GRID_CELLSIZE)]

///get all grid cells intersecting the bounding box around center with sides of length 2 * range
/datum/controller/subsystem/spatial_grid/proc/get_cells_in_range(atom/center, range)
	var/turf/center_turf = get_turf(center)

	var/center_x = center_turf.x
	var/center_y = center_turf.y

	var/list/intersecting_grid_cells = list()

	//the minimum x and y cell indexes to test
	var/min_x = max(ROUND_UP((center_x - range) / SPATIAL_GRID_CELLSIZE), 1)
	var/min_y = max(ROUND_UP((center_y - range) / SPATIAL_GRID_CELLSIZE), 1)//calculating these indices only takes around 2 microseconds

	//the maximum x and y cell indexes to test
	var/max_x = min(ROUND_UP((center_x + range) / SPATIAL_GRID_CELLSIZE), cells_on_x_axis)
	var/max_y = min(ROUND_UP((center_y + range) / SPATIAL_GRID_CELLSIZE), cells_on_y_axis)

	var/list/grid_level = grids_by_z_level[center_turf.z]

	for(var/row in min_y to max_y)
		var/list/grid_row = grid_level[row]

		for(var/x_index in min_x to max_x)
			intersecting_grid_cells += grid_row[x_index]

	return intersecting_grid_cells

///find the spatial map cell that target belongs to, then add target's important_recusive_contents to it.
///make sure to provide the turf new_target is "in"
/datum/controller/subsystem/spatial_grid/proc/enter_cell(atom/movable/new_target, turf/target_turf)
	if(!target_turf || !new_target?.important_recursive_contents)
		CRASH("/datum/controller/subsystem/spatial_grid/proc/enter_cell() was given null arguments or a new_target without important_recursive_contents!")

	var/x_index = ROUND_UP(target_turf.x / SPATIAL_GRID_CELLSIZE)
	var/y_index = ROUND_UP(target_turf.y / SPATIAL_GRID_CELLSIZE)
	var/z_index = target_turf.z

	var/datum/spatial_grid_cell/intersecting_cell = grids_by_z_level[z_index][y_index][x_index]

	if(new_target.important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS])
		intersecting_cell.client_contents |= new_target.important_recursive_contents[SPATIAL_GRID_CONTENTS_TYPE_CLIENTS]

		SEND_SIGNAL(intersecting_cell, SPATIAL_GRID_CELL_ENTERED(RECURSIVE_CONTENTS_CLIENT_MOBS), new_target)

	if(new_target.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE])
		intersecting_cell.hearing_contents |= new_target.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE]

		SEND_SIGNAL(intersecting_cell, SPATIAL_GRID_CELL_ENTERED(RECURSIVE_CONTENTS_HEARING_SENSITIVE), new_target)

/**
 * find the spatial map cell that target used to belong to, then subtract target's important_recusive_contents from it.
 * make sure to provide the turf old_target used to be "in"
 * * old_target - the thing we want to remove from the spatial grid cell
 * * target_turf - the turf we use to determine the cell we're removing from
 * * exclusive_type - either null or a valid contents channel. if you just want to remove a single type from the grid cell then use this
 */
/datum/controller/subsystem/spatial_grid/proc/exit_cell(atom/movable/old_target, turf/target_turf, exclusive_type)
	if(!target_turf || !old_target?.important_recursive_contents)
		CRASH("/datum/controller/subsystem/spatial_grid/proc/exit_cell() was given null arguments or a new_target without important_recursive_contents!")

	var/x_index = ROUND_UP(target_turf.x / SPATIAL_GRID_CELLSIZE)
	var/y_index = ROUND_UP(target_turf.y / SPATIAL_GRID_CELLSIZE)
	var/z_index = target_turf.z

	var/list/grid = grids_by_z_level[z_index]
	var/datum/spatial_grid_cell/intersecting_cell = grid[y_index][x_index]

	if(exclusive_type && old_target.important_recursive_contents[exclusive_type])
		switch(exclusive_type)
			if(RECURSIVE_CONTENTS_CLIENT_MOBS)
				intersecting_cell.client_contents -= old_target.important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS]

			if(RECURSIVE_CONTENTS_HEARING_SENSITIVE)
				intersecting_cell.client_contents -= old_target.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE]

		SEND_SIGNAL(intersecting_cell, SPATIAL_GRID_CELL_EXITED(exclusive_type), old_target)
		return

	if(old_target.important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS])
		intersecting_cell.client_contents -= old_target.important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS]

		SEND_SIGNAL(intersecting_cell, SPATIAL_GRID_CELL_EXITED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), old_target)

	if(old_target.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE])

		intersecting_cell.hearing_contents -= old_target.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE]

		SEND_SIGNAL(intersecting_cell, SPATIAL_GRID_CELL_EXITED(RECURSIVE_CONTENTS_HEARING_SENSITIVE), old_target)

///find the cell this movable is associated with and removes it from all lists
/datum/controller/subsystem/spatial_grid/proc/force_remove_from_cell(atom/movable/to_remove, datum/spatial_grid_cell/input_cell)
	if(!initialized)
		remove_from_pre_init_queue(to_remove)//the spatial grid doesnt exist yet, so just take it out of the queue
		return

	if(!input_cell)
		input_cell = get_cell_of(to_remove)
		if(!input_cell)
			find_hanging_cell_refs_for_movable(to_remove, TRUE)
			return

	input_cell.client_contents -= to_remove
	input_cell.hearing_contents -= to_remove

///if shit goes south, this will find hanging references for qdeleting movables inside
/datum/controller/subsystem/spatial_grid/proc/find_hanging_cell_refs_for_movable(atom/movable/to_remove, remove_from_cells = TRUE)

	var/list/queues_containing_movable = list()
	for(var/queue_channel in waiting_to_add_by_type)
		var/list/queue_list = waiting_to_add_by_type[queue_channel]
		if(to_remove in queue_list)
			queues_containing_movable += queue_channel//just add the associative key
			if(remove_from_cells)
				queue_list -= to_remove

	if(!initialized)
		return queues_containing_movable

	var/list/containing_cells = list()
	for(var/list/z_level_grid as anything in grids_by_z_level)
		for(var/list/cell_row as anything in z_level_grid)
			for(var/datum/spatial_grid_cell/cell as anything in cell_row)
				if(to_remove in (cell.hearing_contents | cell.client_contents))
					containing_cells += cell
					if(remove_from_cells)
						force_remove_from_cell(to_remove, cell)

	return containing_cells

///debug proc for checking if a movable is in multiple cells when it shouldnt be (ie always unless multitile entering is implemented)
/atom/proc/find_all_cells_containing(remove_from_cells = FALSE)
	var/datum/spatial_grid_cell/real_cell = SSspatial_grid.get_cell_of(src)
	var/list/containing_cells = SSspatial_grid.find_hanging_cell_refs_for_movable(src, FALSE, remove_from_cells)

	message_admins("[src] is located in the contents of [length(containing_cells)] spatial grid cells")

	var/cell_coords = "the following cells contain [src]: "
	for(var/datum/spatial_grid_cell/cell as anything in containing_cells)
		cell_coords += "([cell.cell_x], [cell.cell_y]), "

	message_admins(cell_coords)
	message_admins("[src] is supposed to only be contained in the cell at indexes ([real_cell.cell_x], [real_cell.cell_y])")

/atom/proc/find_grid_statistics_for_z_level(insert_clients = 100)
	var/raw_clients = 0
	var/raw_hearables = 0

	var/cells_with_clients = 0
	var/cells_with_hearables = 0

	var/total_cells = (world.maxx / SPATIAL_GRID_CELLSIZE) ** 2

	var/average_clients_per_cell = 0
	var/average_hearables_per_cell = 0

	var/hearable_min_x = (world.maxx / SPATIAL_GRID_CELLSIZE)
	var/hearable_max_x = 1

	var/hearable_min_y = (world.maxy / SPATIAL_GRID_CELLSIZE)
	var/hearable_max_y = 1

	var/client_min_x = (world.maxx / SPATIAL_GRID_CELLSIZE)
	var/client_max_x = 1

	var/client_min_y = (world.maxy / SPATIAL_GRID_CELLSIZE)
	var/client_max_y = 1

	var/list/all_z_level_cells = SSspatial_grid.get_cells_in_range(src, 1000)

	for(var/datum/spatial_grid_cell/cell as anything in all_z_level_cells)
		var/client_length = length(cell.client_contents)
		var/hearable_length = length(cell.hearing_contents)
		raw_clients += client_length
		raw_hearables += hearable_length
		if(client_length)
			cells_with_clients++
			if(cell.cell_x < client_min_x)
				client_min_x = cell.cell_x
			if(cell.cell_x > client_max_x)
				client_max_x = cell.cell_x

			if(cell.cell_y < client_min_y)
				client_min_y = cell.cell_y
			if(cell.cell_y > client_max_y)
				client_max_y = cell.cell_y

		if(hearable_length)
			cells_with_hearables++
			if(cell.cell_x < hearable_min_x)
				hearable_min_x = cell.cell_x
			if(cell.cell_x > hearable_max_x)
				hearable_max_x = cell.cell_x

			if(cell.cell_y < hearable_min_y)
				hearable_min_y = cell.cell_y
			if(cell.cell_y > hearable_max_y)
				hearable_max_y = cell.cell_y

	average_clients_per_cell = raw_clients / total_cells
	average_hearables_per_cell = raw_hearables / total_cells

	message_admins("on z level [z] there are [raw_clients] clients ([insert_clients] of whom are fakes inserted to random station turfs) \
	and [raw_hearables] hearables. all of whom are inside the bounding box given by \
	clients: ([client_min_x], [client_min_y]) x ([client_max_x], [client_max_y]) \
	and hearables: ([hearable_min_x], [hearable_min_y]) x ([hearable_max_x], [hearable_max_y]) \
	on average there are [average_clients_per_cell] clients per cell and [average_hearables_per_cell] hearables per cell. \
	[cells_with_clients] cells have clients and [cells_with_hearables] have hearables")
