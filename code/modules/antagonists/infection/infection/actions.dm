/datum/action/cooldown/infection
	name = "Infection Power"
	desc = "New Infection Power"
	icon_icon = 'icons/mob/infection/action_icons.dmi'
	button_icon_state = ""
	cooldown_time = 0
	var/cost = 0 // cost to actually use

/datum/action/cooldown/infection/New()
	name = name + " ([cost])"
	. = ..()

/datum/action/cooldown/infection/Trigger()
	if(!..())
		return FALSE
	var/mob/I = owner
	var/turf/T = get_turf(I)
	if(T)
		fire(I, T)
		return TRUE
	return FALSE

/datum/action/cooldown/infection/proc/fire(mob/camera/commander/I, turf/T)
	return TRUE

/datum/action/cooldown/infection/coregrab
	name = "Core Grab"
	desc = "Causes a rift over an infection that a few seconds after creation, ruptures, sending everything on the turf to the core of the infection."
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "bluestream_fade"
	cost = 50
	cooldown_time = 600

/datum/action/cooldown/infection/coregrab/fire(mob/camera/commander/I, turf/T)
	var/obj/structure/infection/S = locate(/obj/structure/infection) in T.contents
	if(S)
		StartCooldown()
		playsound(T, 'sound/effects/seedling_chargeup.ogg', 100, FALSE, pressure_affected = FALSE)
		new /obj/effect/temp_visual/bluespace_fissure(T)
		sleep(9)
		new /obj/effect/temp_visual/bluespace_fissure(T)
		sleep(9)
		if(I.infection_core)
			var/list/possible_turfs = orange(2, I.infection_core)
			for(var/atom/movable/M in T.contents - S)
				if(M.anchored)
					continue
				M.forceMove(pick(possible_turfs))
		return
	to_chat(I, "<span class='warning'>You must be above an infection to use this ability!</span>")

/datum/action/cooldown/infection/creator
	name = "Create"
	desc = "New Creation Power"
	var/type_to_create
	var/distance_from_similar = 0
	var/needs_node = FALSE

/datum/action/cooldown/infection/creator/fire(mob/camera/commander/I, turf/T)
	I.createSpecial(cost, type_to_create, distance_from_similar, needs_node, T)
	return TRUE

/datum/action/cooldown/infection/creator/shield
	name = "Create Shield Infection"
	desc = "Create a shield infection, which is harder to kill and has resistances to different types of attacks."
	cost = 5
	button_icon_state = "wall"
	type_to_create = /obj/structure/infection/shield

/datum/action/cooldown/infection/creator/reflective
	name = "Create Reflective Shield Infection"
	desc = "Create a shield that will reflect projectiles back at your enemies."
	cost = 10
	button_icon_state = "reflective"
	type_to_create = /obj/structure/infection/shield/reflective

/datum/action/cooldown/infection/creator/node
	name = "Create Node Infection"
	desc = "Create a node, which will power nearby factory and resource structures."
	cost = 50
	button_icon_state = "node"
	type_to_create = /obj/structure/infection/node
	distance_from_similar = 6

/datum/action/cooldown/infection/creator/resource
	name = "Create Resource Infection"
	desc = "Create a resource tower which will gradually generate resources for you."
	cost = 25
	button_icon_state = "resource"
	type_to_create = /obj/structure/infection/resource
	distance_from_similar = 4
	needs_node = TRUE

/datum/action/cooldown/infection/creator/factory
	name = "Create Factory Infection"
	desc = "Create a spore tower that will spawn spores to harass your enemies."
	cost = 50
	button_icon_state = "factory"
	type_to_create = /obj/structure/infection/factory
	distance_from_similar = 7
	needs_node = TRUE

/datum/action/cooldown/infection/creator/turret
	name = "Create Turret Infection"
	desc = "Create a turret that will automatically fire at your enemies."
	cost = 50
	button_icon_state = "turret"
	type_to_create = /obj/structure/infection/turret
	distance_from_similar = 8
	needs_node = TRUE

/datum/action/cooldown/infection/creator/beamturret
	name = "Create Beam Turret Infection"
	desc = "Create a turret that will automatically fire and instantly stick to your enemies."
	cost = 50
	button_icon_state = "beamturret"
	type_to_create = /obj/structure/infection/turret/beam
	distance_from_similar = 8
	needs_node = TRUE

/datum/action/cooldown/infection/creator/vacuum
	name = "Create Vacuum Infection"
	desc = "Create a vacuum that will suck in anything non-infectious, as well as hurt things caught in it."
	cost = 50
	button_icon_state = "vacuum"
	type_to_create = /obj/structure/infection/vacuum
	distance_from_similar = 8
	needs_node = TRUE

/datum/action/cooldown/infection/mininode
	name = "Miniature Node"
	desc = "Creates a miniature node on the infection you're standing on."
	button_icon_state = "node"
	cooldown_time = 900

/datum/action/cooldown/infection/mininode/fire(mob/infector, turf/T)
	var/obj/structure/infection/I = locate(/obj/structure/infection) in T.contents
	if(I)
		StartCooldown()
		playsound(T, 'sound/effects/splat.ogg', 100, FALSE, pressure_affected = FALSE)
		I.change_to(/obj/structure/infection/node/mini, I.overmind)
		return
	to_chat(infector, "<span class='warning'>You must be above an infection to use this ability!</span>")

/datum/action/cooldown/infection/flash
	name = "Bright Flash"
	desc = "Creates a bright flash of light centered around you."
	icon_icon = 'icons/obj/assemblies/new_assemblies.dmi'
	button_icon_state = "flash"
	cooldown_time = 900

/datum/action/cooldown/infection/flash/fire(mob/infector, turf/T)
	StartCooldown()
	playsound(T, 'sound/weapons/flash.ogg', 100, FALSE, pressure_affected = FALSE)
	for(var/mob/living/L in viewers(infector,4) - infector)
		L.flash_act()

/datum/action/cooldown/infection/voice
	name = "Booming Voice"
	desc = "A large sound erupts from your body, possibly stunning opponents around you."
	icon_icon = 'icons/obj/projectiles.dmi'
	button_icon_state = "kinetic_blast"
	cooldown_time = 900

/datum/action/cooldown/infection/voice/fire(mob/infector, turf/T)
	StartCooldown()
	playsound(T, 'sound/voice/ed209_20sec.ogg', 100, FALSE, pressure_affected = FALSE)
	for(var/mob/living/L in get_hearers_in_view(4, T) - infector)
		L.Paralyze(200)
		L.soundbang_act(1, 200, 10, 15)
