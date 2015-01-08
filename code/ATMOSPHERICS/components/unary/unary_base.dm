/obj/machinery/atmospherics/unary
	icon = 'icons/obj/atmospherics/unary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH
	var/datum/gas_mixture/air_contents
	var/obj/machinery/atmospherics/node
	var/datum/pipeline/parent

/obj/machinery/atmospherics/unary/New()
	..()
	air_contents = new
	air_contents.volume = 200


/obj/machinery/atmospherics/unary/SetInitDirections()
	initialize_directions = dir
/*
Iconnery
*/

//Separate this because we don't need to update pipe icons if we just are going to change the state
/obj/machinery/atmospherics/unary/proc/update_icon_nopipes()
	return

/obj/machinery/atmospherics/unary/update_icon()
	underlays.Cut()
	update_icon_nopipes()

	//This code might be a bit specific to scrubber, vents and injectors, but honestly they are basically the only ones used in the unary branch.

	var/state
	var/col
	var/lay
	if(node)
		state = "pipe_intact"
		col = node.pipe_color
		lay = node.layer
	else
		state = "pipe_exposed"
		lay = PIPE_LAYER

	underlays += getpipeimage('icons/obj/atmospherics/binary_devices.dmi', state, initialize_directions, col, lay)

/*
Housekeeping and pipe network stuff below
*/

/obj/machinery/atmospherics/unary/Destroy()
	if(node)
		node.disconnect(src)
		node = null
		nullifyPipenet(parent)
	..()


/obj/machinery/atmospherics/unary/initialize()
	for(var/obj/machinery/atmospherics/target in get_step(src, dir))
		if(target.initialize_directions & get_dir(target,src))
			node = target
			break
	..()

/obj/machinery/atmospherics/unary/default_change_direction_wrench(mob/user, obj/item/weapon/wrench/W)
	if(..())
		initialize_directions = dir
		if(node)
			node.disconnect(src)
		node = null
		nullifyPipenet(parent)
		initialize()
		if(node)
			node.initialize()
			node.addMember(src)
		build_network()
		. = 1

/obj/machinery/atmospherics/unary/build_network()
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)

/obj/machinery/atmospherics/unary/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node)
		if(istype(node, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node = null
	update_icon()

/obj/machinery/atmospherics/unary/nullifyPipenet()
	..()
	parent.other_airs -= air_contents
	parent = null

/obj/machinery/atmospherics/unary/returnPipenetAir()
	return air_contents

/obj/machinery/atmospherics/unary/pipeline_expansion()
	return list(node)

/obj/machinery/atmospherics/unary/setPipenet(datum/pipeline/P)
	parent = P

/obj/machinery/atmospherics/unary/returnPipenet()
	return parent

/obj/machinery/atmospherics/unary/replacePipenet(datum/pipeline/Old, datum/pipeline/New)
	if(Old == parent)
		parent = New