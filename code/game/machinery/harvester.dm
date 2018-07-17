/obj/machinery/harvester
	name = "organ harvester"
	desc = "An advanced machine used for harvesting organs and limbs from the deceased."
	density = TRUE
	icon = 'icons/obj/machines/harvester.dmi'
	icon_state = "harvester"
	verb_say = "states"
	state_open = FALSE
	idle_power_usage = 50
	circuit = /obj/item/circuitboard/machine/harvester
	light_color = LIGHT_COLOR_BLUE
	var/interval = 20
	var/harvesting = FALSE
	var/list/operation_order = list() //Order of wich we harvest limbs.
	var/allow_clothing = FALSE
	var/allow_living = FALSE

/obj/machinery/harvester/Initialize()
	. = ..()
	if(prob(5))
		name = "auto-autopsy"

/obj/machinery/harvester/RefreshParts()
	interval = 0
	var/max_time = 40
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		max_time -= L.rating
	interval = max(max_time,1)

/obj/machinery/harvester/update_icon(warming_up)
	if(warming_up)
		icon_state = initial(icon_state)+"-charging"
		return
	if(state_open)
		icon_state = initial(icon_state)+"-open"
	else if(harvesting)
		icon_state = initial(icon_state)+"-active"
	else
		icon_state = initial(icon_state)

/obj/machinery/harvester/open_machine(drop = TRUE)
	if(panel_open)
		return
	. = ..()
	harvesting = FALSE

/obj/machinery/harvester/attack_hand(mob/user)
	if(state_open)
		close_machine()
	else if(!harvesting)
		open_machine()

/obj/machinery/harvester/AltClick(mob/user)
	if(harvesting || !user || !isliving(user) || state_open)
		return
	if(can_harvest())
		start_harvest()

/obj/machinery/harvester/proc/can_harvest()
	if(!powered(EQUIP) || state_open || !occupant || !iscarbon(occupant))
		return
	var/mob/living/carbon/C = occupant
	if(!allow_clothing)
		for(var/A in C.held_items + C.get_equipped_items())
			if(!isitem(A))
				continue
			var/obj/item/I = A
			if(!(I.item_flags & NODROP))
				say("Subject may not have abiotic items on.")
				playsound(src, 'sound/machines/buzz-sigh.ogg', 30, 1)
				return
	if(!(MOB_ORGANIC in C.mob_biotypes))
		say("Subject is not organic.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, 1)
		return
	if(!allow_living && !(C.stat == DEAD || C.has_trait(TRAIT_FAKEDEATH)))     //I mean, the machines scanners arent advanced enough to tell you're alive
		say("Subject is still alive.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, 1)
		return
	return TRUE

/obj/machinery/harvester/proc/start_harvest()
	if(!occupant || !iscarbon(occupant))
		return
	var/mob/living/carbon/C = occupant
	operation_order = reverseList(C.bodyparts)   //Chest and head are first in bodyparts, so we invert it to make them suffer more
	harvesting = TRUE
	visible_message("<span class='notice'>The [name] begins warming up!</span>")
	update_icon(TRUE)
	addtimer(CALLBACK(src, .proc/harvest), interval)

/obj/machinery/harvester/proc/harvest()
	update_icon()
	if(!harvesting || state_open || !powered(EQUIP) || !occupant || !iscarbon(occupant))
		return
	playsound(src, 'sound/machines/juicer.ogg', 20, 1)
	var/mob/living/carbon/C = occupant
	if(!LAZYLEN(operation_order)) //The list is empty, so we're done here
		end_harvesting()
		return
	var/turf/target
	for(var/adir in list(EAST,NORTH,SOUTH,WEST))
		var/turf/T = get_step(src,adir)
		if(!T)
			continue
		if(istype(T, /turf/closed))
			continue
		target = T
		break
	if(!target)
		target = get_turf(src)
	for(var/obj/item/bodypart/BP in operation_order) //first we do non-essential limbs
		BP.drop_limb()
		C.emote("scream")
		if(BP.body_zone != "chest")
			BP.forceMove(target)    //Move the limbs right next to it, except chest, that's a weird one
			BP.drop_organs()
		else
			for(var/obj/item/organ/O in BP.dismember())
				O.forceMove(target) //Some organs, like chest ones, are different so we need to manually move them
		operation_order.Remove(BP)
		break
	use_power(5000)
	addtimer(CALLBACK(src, .proc/harvest), interval)

/obj/machinery/harvester/proc/end_harvesting()
	harvesting = FALSE
	open_machine()
	say("Subject has been succesfuly harvested.")
	playsound(src, 'sound/machines/microwave/microwave-end.ogg', 100, 0)

/obj/machinery/harvester/screwdriver_act(mob/living/user, obj/item/I)
	if(!state_open && !occupant)
		if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
			return

/obj/machinery/harvester/crowbar_act(mob/living/user, obj/item/I)
	if(default_pry_open(I))
		return
	if(default_deconstruction_crowbar(I))
		return

/obj/machinery/harvester/default_pry_open(obj/item/I) //wew
	. = !(state_open || panel_open || (flags_1 & NODECONSTRUCT_1)) && I.tool_behaviour == TOOL_CROWBAR //We removed is_operational() here
	if(.)
		I.play_tool_sound(src, 50)
		visible_message("<span class='notice'>[usr] pries open \the [src].</span>", "<span class='notice'>You pry open [src].</span>")
		open_machine()

/obj/machinery/harvester/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	allow_living = TRUE
	to_chat(user, "<span class='warning'>You overload [src]'s lifesign scanners.</span>")

/obj/machinery/harvester/container_resist(mob/living/user)
	if(!harvesting)
		visible_message("<span class='notice'>[occupant] emerges from [src]!</span>",
			"<span class='notice'>You climb out of [src]!</span>")
		open_machine()
	else
		to_chat(user,"<span class='warning'>[src] is active and can't be opened!</span>") //rip

/obj/machinery/harvester/Exited(atom/movable/user)
	if (!state_open && user == occupant)
		container_resist(user)

/obj/machinery/harvester/relaymove(mob/user)
	if (!state_open)
		container_resist(user)