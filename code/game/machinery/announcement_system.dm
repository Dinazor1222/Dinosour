var/list/announcement_systems = list()

/obj/machinery/announcement_system
	density = 1
	anchored = 1
	name = "\improper Automated Announcement System"
	desc = "An automated announcement system that handles minor announcements over the radio."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "AAS_On"
	var/obj/item/device/radio/headset/radio

	verb_say = "coldly states"
	verb_ask = "queries"
	verb_exclaim = "alarms"

	idle_power_usage = 20
	active_power_usage = 50

	var/arrival = "%PERSON has signed up as %RANK"
	var/arrivalToggle = 1
	var/newhead = "%PERSON, %RANK, is the department head."
	var/newheadToggle = 1

	var/greenlight = "Light_Green"
	var/pinklight = "Light_Pink"
	var/errorlight = "Error_Red"

/obj/machinery/announcement_system/New()
	..()
	announcement_systems += src
	radio = new /obj/item/device/radio/headset/ai(src)

	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/announcement_system(null)
	B.apply_default_parts(src)

	update_icon()

/obj/item/weapon/circuitboard/machine/announcement_system
	name = "circuit board (Announcement System)"
	build_path = /obj/machinery/announcement_system
	origin_tech = "programming=3;bluespace=3;magnets=2"
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/machinery/announcement_system/update_icon()
	if(is_operational())
		icon_state = (panel_open ? "AAS_On_Open" : "AAS_On")
	else
		icon_state = (panel_open ? "AAS_Off_Open" : "AAS_Off")


	cut_overlays()
	if(arrivalToggle)
		add_overlay(greenlight)
	else
		overlays -= greenlight

	if(newheadToggle)
		add_overlay(pinklight)
	else
		overlays -= pinklight

	if(stat & BROKEN)
		add_overlay(errorlight)
	else
		overlays -= errorlight

/obj/machinery/announcement_system/Destroy()
	announcement_systems -= src //"OH GOD WHY ARE THERE 100,000 LISTED ANNOUNCEMENT SYSTEMS?!!"
	return ..()

/obj/machinery/announcement_system/power_change()
	..()
	update_icon()

/obj/machinery/announcement_system/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/weapon/screwdriver))
		playsound(src.loc, P.usesound, 50, 1)
		panel_open = !panel_open
		user << "<span class='notice'>You [panel_open ? "open" : "close"] the maintenance hatch of [src].</span>"
		update_icon()
	else if(default_deconstruction_crowbar(P))
		return
	else if(istype(P, /obj/item/device/multitool) && panel_open && (stat & BROKEN))
		user << "<span class='notice'>You reset [src]'s firmware.</span>"
		stat &= ~BROKEN
		update_icon()
	else
		return ..()

/obj/machinery/announcement_system/proc/CompileText(str, user, rank) //replaces user-given variables with actual thingies.
	str = replacetext(str, "%PERSON", "[user]")
	str = replacetext(str, "%RANK", "[rank]")
	return str

/obj/machinery/announcement_system/proc/announce(message_type, user, rank, list/channels)
	if(!is_operational())
		return

	var/message

	if(message_type == "ARRIVAL" && arrivalToggle)
		message = CompileText(arrival, user, rank)

	else if(message_type == "NEWHEAD" && newheadToggle)
		message = CompileText(newhead, user, rank)

	if(channels.len == 0)
		radio.talk_into(src, message, null, list(SPAN_ROBOT))
	else
		for(var/channel in channels)
			radio.talk_into(src, message, channel, list(SPAN_ROBOT))

//config stuff

/obj/machinery/announcement_system/interact(mob/user)
	if(stat & BROKEN)
		visible_message("<span class='warning'>[src] buzzes.</span>", "<span class='italics'>You hear a faint buzz.</span>")
		playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 1)
		return


	var/contents = "Arrival Announcement:  <A href='?src=\ref[src];ArrivalT-Topic=1'>([(arrivalToggle ? "On" : "Off")])</a><br>\n<A href='?src=\ref[src];ArrivalTopic=1'>[arrival]</a><br><br>\n"
	contents += "Departmental Head Announcement:  <A href='?src=\ref[src];NewheadT-Topic=1'>([(newheadToggle ? "On" : "Off")])</a><br>\n<A href='?src=\ref[src];NewheadTopic=1'>[newhead]</a><br><br>\n"

	var/datum/browser/popup = new(user, "announcement_config", "Automated Announcement Configuration", 370, 220)
	popup.set_content(contents)
	popup.open()

/obj/machinery/announcement_system/Topic(href, href_list)
	if(stat & BROKEN)
		visible_message("<span class='warning'>[src] buzzes.</span>", "<span class='italics'>You hear a faint buzz.</span>")
		playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 1)
		return

	if(href_list["ArrivalTopic"])
		var/NewMessage = stripped_input(usr, "Enter in the arrivals announcement configuration.", "Arrivals Announcement Config", arrival)
		if(!in_range(src, usr) && src.loc != usr && !isAI(usr))
			return
		if(NewMessage)
			arrival = NewMessage
	else if(href_list["NewheadTopic"])
		var/NewMessage = stripped_input(usr, "Enter in the departmental head announcement configuration.", "Head Departmental Announcement Config", newhead)
		if(!in_range(src, usr) && src.loc != usr && !isAI(usr))
			return
		if(NewMessage)
			newhead = NewMessage

	else if(href_list["NewheadT-Topic"])
		newheadToggle = !newheadToggle
		update_icon()
	else if(href_list["ArrivalT-Topic"])
		arrivalToggle = !arrivalToggle
		update_icon()

	add_fingerprint(usr)
	interact(usr)

/obj/machinery/announcement_system/attack_ai(mob/living/silicon/ai/user)
	if(!isAI(user))
		return
	if(stat & BROKEN)
		user << "<span class='warning'>[src]'s firmware appears to be malfunctioning!</span>"
		return
	interact(user)

/obj/machinery/announcement_system/proc/act_up() //does funny breakage stuff
	stat |= BROKEN
	update_icon()

	arrival = pick("#!@%ERR-34%2 CANNOT LOCAT@# JO# F*LE!", "CRITICAL ERROR 99.", "ERR)#: DA#AB@#E NOT F(*ND!")
	newhead = pick("OV#RL()D: \[UNKNOWN??\] DET*#CT)D!", "ER)#R - B*@ TEXT F*O(ND!", "AAS.exe is not responding. NanoOS is searching for a solution to the problem.")

/obj/machinery/announcement_system/emp_act(severity)
	if(!(stat & (NOPOWER|BROKEN)))
		act_up()
	..(severity)

/obj/machinery/announcement_system/emag_act()
	if(!emagged)
		emagged = 1
		act_up()
