/obj/machinery/computer/telescience
	name = "telepad control console"
	desc = "Used to teleport objects to and from the telescience telepad."
	icon_state = "teleport"
	var/sending = 1
	var/obj/machinery/telepad/telepad = null

	// VARIABLES //
	var/teles_left	// How many teleports left until it becomes uncalibrated
	var/x_off	// X offset
	var/y_off	// Y offset
	var/x_co	// X coordinate
	var/y_co	// Y coordinate
	var/z_co	// Z coordinate

/obj/machinery/computer/telescience/New()
	teles_left = rand(8,12)
	x_off = rand(-10,10)
	y_off = rand(-10,10)
	initialize()

/obj/machinery/computer/telescience/initialize()
	..()
	telepad = locate() in range(src, 7)

/obj/machinery/computer/telescience/update_icon()
	if(stat & BROKEN)
		icon_state = "telescib"
	else
		if(stat & NOPOWER)
			src.icon_state = "teleport0"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER

/obj/machinery/computer/telescience/attack_paw(mob/user)
	user << "You are too primitive to use this computer."
	return

/obj/machinery/computer/telescience/attack_ai(mob/user)
	src.attack_hand(user)

/obj/machinery/computer/telescience/attack_hand(mob/user)
	if(..())
		return
	var/t = ""
	t += "<A href='?src=\ref[src];setx=1'>Set X</A>"
	t += "<A href='?src=\ref[src];sety=1'>Set Y</A>"
	t += "<A href='?src=\ref[src];setz=1'>Set Z</A>"
	t += "<BR><BR>Current set coordinates:"
	t += "([x_co], [y_co], [z_co])"
	t += "<BR><BR><A href='?src=\ref[src];send=1'>Send</A>"
	t += " <A href='?src=\ref[src];receive=1'>Receive</A>"
	t += "<BR><BR><A href='?src=\ref[src];recal=1'>Recalibrate</A>"
	var/datum/browser/popup = new(user, "telesci", name, 640, 480)
	popup.set_content(t)
	popup.open()
	return
/obj/machinery/computer/telescience/proc/sparks()
	if(telepad)
		var/L = get_turf(E)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, L)
		s.start()
	else
		return
/obj/machinery/computer/telescience/proc/telefail()
	sparks()
	for(var/mob/O in hearers(src, null))
		O.show_message("<span class = 'caution'>The telepad weakly fizzles.</span>", 2)
	return
/obj/machinery/computer/telescience/proc/doteleport(mob/user)
	var/trueX = (x_co + x_off)
	var/trueY = (y_co + y_off)
	trueX = Clamp(trueX, 1, world.maxx)
	trueY = Clamp(trueY, 1, world.maxy)
	if(telepad)
		error("debug machine: [telepad]")
		var/turf/target = locate(trueX, trueY, z_co)
		var/area/A = get_area(target)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, telepad)
		s.start()
		flick("pad-beam", telepad)
		user << "<span class = 'caution'> Teleport successful.</span>"
		investigate_log("[key_name(usr)]/[user] has teleported with Telescience at [trueX],[trueY],[z_co], in [A.name].","telesci")
		var/sparks = get_turf(target)
		var/datum/effect/effect/system/spark_spread/y = new /datum/effect/effect/system/spark_spread
		y.set_up(5, 1, sparks)
		y.start()
		var/turf/source = target
		var/turf/dest = get_turf(telepad)
		if(sending)
			source = dest
			dest = target
		for(var/atom/movable/ROI in source)
			if(ROI.anchored) continue
			do_teleport(ROI, dest, 0)
		return
	return

/obj/machinery/computer/telescience/proc/teleport(mob/user)
	error("debug start")
	if(x_co == null || y_co == null || z_co == null)
		error("debug A")
		user << "<span class = 'caution'>  Error: set coordinates.</span>"
		return
	if(x_co < 1 || x_co > 255)
		error("debug B")
		telefail()
		user << "<span class = 'caution'>  Error: X is less than 1 or greater than 255.</span>"
		return
	if(y_co < 1 || y_co > 255)
		error("debug C")
		telefail()
		user << "<span class = 'caution'>  Error: Y is less than 1 or greater than 255.</span>"
		return
	if(z_co == 2 || z_co < 1 || z_co > 7)
		error("debug D")
		telefail()
		user << "<span class = 'caution'>  Error: Z is less than 1, greater than 7, or equal to 2.</span>"
		return
	if(teles_left > 0)
		error("debug E")
		teles_left -= 1
		doteleport(user)
	else
		error("debug F")
		telefail()
		return
	return

/obj/machinery/computer/telescience/Topic(href, href_list)
	if(..())
		return
	error("debug 1")
	if(href_list["setx"])
		var/new_x = input("Please input desired X coordinate.", name, x_co) as num
		x_co = Clamp(new_x, 1, 9999)
		return
	if(href_list["sety"])
		var/new_y = input("Please input desired Y coordinate.", name, y_co) as num
		y_co = Clamp(new_y, 1, 9999)
		return
	if(href_list["setz"])
		var/new_z = input("Please input desired Z coordinate.", name, z_co) as num
		z_co = Clamp(new_z, 1, 9999)
		return
	if(href_list["send"])
		error("debug 2")
		sending = 1
		teleport(usr)
		return
	if(href_list["receive"])
		error("debug 3")
		sending = 0
		teleport(usr)
		return
	if(href_list["recal"])
		error("debug 4")
		teles_left = rand(9,12)
		x_off = rand(-10,10)
		y_off = rand(-10,10)
		sparks()
		usr << "<span class = 'caution'> Calibration successful.</span>"
		return