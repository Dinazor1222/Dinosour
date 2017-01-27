/obj/item/soapstone
	name = "chisel"
	desc = "Leave informative messages for the crew, including the crew of future shifts!\n(Not suitable for engraving on shuttles, off station or on cats. Side effects may include beatings, bannings and orbital bombardment.)"
	icon = 'icons/obj/items.dmi'
	icon_state = "soapstone"
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/tool_speed = 50

/obj/item/soapstone/New()
	. = ..()
	name = pick("soapstone", "chisel", "chalk", "magic marker")

/obj/item/soapstone/afterattack(atom/target, mob/user, proximity)
	var/turf/T = get_turf(target)
	if(!proximity)
		return

	var/obj/structure/chisel_message/already_message = locate(/obj/structure/chisel_message) in T

	if(!good_chisel_message_location(T))
		user << "<span class='warning'>It's not appropriate to engrave on [T].</span>"
		return

	if(already_message)
		user.visible_message("<span class='notice'>[user] starts erasing [already_message].</span>", "<span class='notice'>You start erasing [already_message].</span>", "<span class='italics'>You hear a chipping sound.</span>")
		playsound(loc, 'sound/items/gavel.ogg', 50, 1, -1)

		if(do_after(user, tool_speed, target=target))
			user.visible_message("<span class='notice'>[user] has erased [already_message].</span>", "<span class='notice'>You erased [already_message].</span>")
			already_message.persists = FALSE
			qdel(already_message)
			playsound(loc, 'sound/items/gavel.ogg', 50, 1, -1)
		return

	var/message = stripped_input(user, "What would you like to engrave?", "Chisel Message")
	if(!message)
		user << "You decide not to chisel anything."
		return

	if(!target.Adjacent(user) && locate(/obj/structure/chisel_message) in T)
		user << "You decide not to chisel anything."
		return

	playsound(loc, 'sound/items/gavel.ogg', 50, 1, -1)
	user.visible_message("<span class='notice'>[user] starts engraving a message into [T].</span>", "You start engraving a message into [T].", "<span class='italics'>You hear a chipping sound.</span>")
	if(do_after(user, tool_speed, target=T))
		if(!locate(/obj/structure/chisel_message in T))
			user << "You chisel a message into [T]."
			playsound(loc, 'sound/items/gavel.ogg', 50, 1, -1)
			var/obj/structure/chisel_message/M = new(T)
			M.register(user, message)

/* Persistent engraved messages, etched onto the station turfs to serve
   as instructions and/or memes for the next generation of spessmen.

   Limited in location to station_z only. Can be smashed out or exploded,
   but only permamently removed with the librarian's soapstone.
*/

/proc/good_chisel_message_location(turf/T)
	if(!T)
		. = FALSE
	else if(T.z != ZLEVEL_STATION)
		. = FALSE
	else if(istype(get_area(T), /area/shuttle))
		. = FALSE
	else if(!(isfloorturf(T) || iswallturf(T)))
		. = FALSE
	else
		. = TRUE

/obj/structure/chisel_message
	name = "engraved message"
	desc = "A message from a past traveler."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "soapstone_message"
	density = 0
	anchored = 1
	luminosity = 1
	obj_integrity = 30
	max_integrity = 30

	var/hidden_message
	var/creator_key
	var/creator_name
	var/realdate
	var/map
	var/persists = TRUE

/obj/structure/chisel_message/New(newloc)
	..()
	SSpersistence.chisel_messages += src
	var/turf/T = get_turf(src)
	if(!good_chisel_message_location(T))
		persists = FALSE
		qdel(src)

/obj/structure/chisel_message/proc/register(mob/user, newmessage)
	hidden_message = newmessage
	creator_name = user.name
	creator_key = user.key
	realdate = world.timeofday
	map = MAP_NAME
	update_icon()

/obj/structure/chisel_message/update_icon()
	..()
	var/hash = md5(hidden_message)
	var/newcolor = copytext(hash, 1, 7)
	add_atom_colour("#[newcolor]", FIXED_COLOUR_PRIORITY)

/obj/structure/chisel_message/proc/pack()
	var/list/data = list()
	data["hidden_message"] = hidden_message
	data["creator_name"] = creator_name
	data["creator_key"] = creator_key
	data["realdate"] = realdate
	data["map"] = MAP_NAME
	var/turf/T = get_turf(src)
	data["x"] = T.x
	data["y"] = T.y
	return data

/obj/structure/chisel_message/proc/unpack(list/data)
	hidden_message = data["hidden_message"]
	creator_name = data["creator_name"]
	creator_key = data["creator_key"]
	realdate = data["realdate"]

	var/x = data["x"]
	var/y = data["y"]
	var/turf/newloc = locate(x, y, ZLEVEL_STATION)
	forceMove(newloc)
	update_icon()

/obj/structure/chisel_message/examine(mob/user)
	..()
	user << "<span class='warning'>[hidden_message]</span>"

/obj/structure/chisel_message/Destroy()
	if(persists)
		SSpersistence.SaveChiselMessage(src)
	SSpersistence.chisel_messages -= src
	. = ..()
