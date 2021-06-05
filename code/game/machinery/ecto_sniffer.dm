/obj/machinery/ecto_sniffer
	name = "ectoscopic sniffer"
	desc = "A highly sensitive parascientific instrument calibrated to detect the slightest whiff of ectoplasm."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "ecto_sniffer"
	density = FALSE
	anchored = FALSE
	pass_flags = PASSTABLE
	///determines if the device if the power switch is turned on or off. Useful if the ghosts are too annoying.
	var/on = TRUE
	///If this var set to false the ghosts will not be able interact with the machine, say if the machine is silently disabled by cutting the internal wire.
	var/sensor_enabled = TRUE
	///List of weakref datums containing mobs who have recently activated the device, mobs on this list are prohibited from activating the device untill their residue decays.
	var/list/ectoplasmic_residues = list()

/obj/machinery/ecto_sniffer/Initialize()
	. = ..()
	wires = new/datum/wires/ecto_sniffer(src)

/obj/machinery/ecto_sniffer/attack_ghost(mob/user)
	. = ..()
	if(!is_operational || !on || !sensor_enabled)
		return

	for(var/datum/weakref/spirit_residue in ectoplasmic_residues)
		if(IS_WEAKREF_OF(user, spirit_residue))
			return ..()
	activate(user)

/obj/machinery/ecto_sniffer/proc/activate(mob/activator)
	flick("ecto_sniffer_flick", src)
	playsound(loc, 'sound/machines/ping.ogg', 20)
	use_power(10)
	if(activator)
		ectoplasmic_residues += WEAKREF(activator)
		addtimer(CALLBACK(src, .proc/clear_residue, activator), 15 SECONDS)

/obj/machinery/ecto_sniffer/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	add_fingerprint(user)
	on = !on
	balloon_alert(user, "sniffer turned [on ? "on" : "off"]")
	update_appearance()

/obj/machinery/ecto_sniffer/update_icon_state()
	. = ..()
	if(panel_open)
		icon_state = "[initial(icon_state)]_open"
	else
		icon_state = "[initial(icon_state)][(is_operational && on) ? null : "-p"]"

/obj/machinery/ecto_sniffer/update_overlays()
	. = ..()
	if(is_operational && on)
		. += emissive_appearance(icon, "[initial(icon_state)]-light-mask")

/obj/machinery/ecto_sniffer/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	tool.play_tool_sound(src, 15)
	set_anchored(!anchored)
	balloon_alert(user, "sniffer [anchored ? "anchor" : "unanchor"]")

/obj/machinery/ecto_sniffer/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(!.)
		return default_deconstruction_screwdriver(user, "ecto_sniffer_open", "ecto_sniffer", I)

/obj/machinery/ecto_sniffer/Destroy()
	. = ..()
	ectoplasmic_residues = null

///Removes the ghost from the ectoplasmic_residues list and lets them know they are free to activate the sniffer again.
/obj/machinery/ecto_sniffer/proc/clear_residue(mob/haunt)
	for(var/datum/weakref/spirit_residue in ectoplasmic_residues)
		if(IS_WEAKREF_OF(haunt, spirit_residue))
			ectoplasmic_residues -= spirit_residue
			break

	to_chat(haunt, "<span class='nicegreen'>The coating of ectoplasmic residue you left on [src]'s sensors has decayed.</span>")
