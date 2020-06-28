/**
  * # Swarmer
  *
  * Tiny machines made by an ancient civilization, they seek only to consume materials and replicate.
  *
  * Tiny robots which, while not lethal, seek to destroy station components in order to recycle them into more swarmers.
  * Sentient player swarmers spawn from a beacon spawned in maintenance and they can spawn melee swarmers to protect them.
  * Swarmers have the following abilities:
  * - Can melee targets to deal stamina damage.  Stuns cyborgs.
  * - Can teleport friend and foe alike away using ctrl + click.  Applies binds to carbons, preventing them from immediate retaliation
  * - Can shoot lasers which deal stamina damage to carbons and direct damage to simple mobs
  * - Can self repair for free, completely healing themselves
  * - Can construct traps which stun targets, and walls which block non-swarmer entites and projectiles
  * - Can create swarmer drones, which lack the above abilities sans melee stunning targets.  A swarmer can order its drones around by middle-clicking a tile.
  */

/mob/living/simple_animal/hostile/swarmer
	name = "swarmer"
	icon = 'icons/mob/swarmer.dmi'
	desc = "Robotic constructs of unknown design, swarmers seek only to consume materials and replicate themselves indefinitely."
	speak_emote = list("tones")
	initial_language_holder = /datum/language_holder/swarmer
	bubble_icon = "swarmer"
	mob_biotypes = MOB_ROBOTIC
	health = 40
	maxHealth = 40
	status_flags = CANPUSH
	icon_state = "swarmer"
	icon_living = "swarmer"
	icon_dead = "swarmer_unactivated"
	icon_gib = null
	wander = 0
	harm_intent_damage = 5
	minbodytemp = 0
	maxbodytemp = 500
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	melee_damage_lower = 15
	melee_damage_upper = 15
	melee_damage_type = STAMINA
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	hud_possible = list(ANTAG_HUD, DIAG_STAT_HUD, DIAG_HUD)
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	attack_verb_continuous = "shocks"
	attack_verb_simple = "shock"
	attack_sound = 'sound/effects/empulse.ogg'
	friendly_verb_continuous = "pinches"
	friendly_verb_simple = "pinch"
	speed = 0
	faction = list("swarmer")
	AIStatus = AI_OFF
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_TINY
	ventcrawler = VENTCRAWLER_ALWAYS
	ranged = 1
	projectiletype = /obj/projectile/beam/disabler/swarmer
	ranged_cooldown_time = 20
	projectilesound = 'sound/weapons/taser2.ogg'
	loot = list(/obj/effect/decal/cleanable/robot_debris, /obj/item/stack/ore/bluespace_crystal)
	del_on_death = 1
	deathmessage = "explodes with a sharp pop!"
	light_color = LIGHT_COLOR_CYAN
	hud_type = /datum/hud/swarmer
	speech_span = SPAN_ROBOT
	///Resource points, generated by consuming metal/glass
	var/resources = 0
	///Maximum amount of resources a swarmer can store
	var/max_resources = 100
	///List used for player swarmers to keep track of their drones
	var/list/mob/living/simple_animal/hostile/swarmer/melee/dronelist

/mob/living/simple_animal/hostile/swarmer/Initialize()
	. = ..()
	verbs -= /mob/living/verb/pulled
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)

/mob/living/simple_animal/hostile/swarmer/med_hud_set_health()
	var/image/holder = hud_list[DIAG_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = "huddiag[RoundDiagBar(health/maxHealth)]"

/mob/living/simple_animal/hostile/swarmer/med_hud_set_status()
	var/image/holder = hud_list[DIAG_STAT_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = "hudstat"

/mob/living/simple_animal/hostile/swarmer/Stat()
	..()
	if(statpanel("Status"))
		stat("Resources:",resources)

/mob/living/simple_animal/hostile/swarmer/emp_act()
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(health > 1)
		adjustHealth(health-1)
	else
		death()

/mob/living/simple_animal/hostile/swarmer/CanAllowThrough(atom/movable/O)
	. = ..()
	if(istype(O, /obj/projectile/beam/disabler))//Allows for swarmers to fight as a group without wasting their shots hitting each other
		return TRUE
	if(isswarmer(O))
		return TRUE

////CTRL CLICK FOR SWARMERS AND SWARMER_ACT()'S////
/mob/living/simple_animal/hostile/swarmer/AttackingTarget()
	if(!isliving(target))
		return target.swarmer_act(src)
	if(iscyborg(target))
		var/mob/living/silicon/borg = target
		borg.adjustBruteLoss(melee_damage_lower)
	return ..()
		
/mob/living/simple_animal/hostile/swarmer/MiddleClickOn(atom/A)
	. = ..()
	if(!LAZYLEN(dronelist))
		return
	var/turf/clicked_turf = get_turf(A)
	if(!clicked_turf)
		return
	for(var/d in dronelist)
		var/mob/living/simple_animal/hostile/drone = d
		drone.LoseTarget()
		drone.Goto(clicked_turf, drone.move_to_delay)

/mob/living/simple_animal/hostile/swarmer/CtrlClickOn(atom/A)
	face_atom(A)
	if(!isturf(loc))
		return
	if(next_move > world.time)
		return
	if(!A.Adjacent(src))
		return
	PrepareTarget(src)

////END CTRL CLICK FOR SWARMERS////

/**
  * Called when a swarmer creates a structure or drone
  *
  * Proc called whenever a swarmer creates a structure or drone
  * Arguments:
  * * fabrication_object - The atom to create
  * * fabrication_cost - How many resources it costs for a swarmer to create the object
  */
/mob/living/simple_animal/hostile/swarmer/proc/Fabricate(atom/fabrication_object,fabrication_cost = 0)
	if(!isturf(loc))
		to_chat(src, "<span class='warning'>This is not a suitable location for fabrication. We need more space.</span>")
		return
	if(resources < fabrication_cost)
		to_chat(src, "<span class='warning'>You do not have the necessary resources to fabricate this object.</span>")
		return
	resources -= fabrication_cost
	return new fabrication_object(drop_location())

/**
  * Called when a swarmer attempts to consume an object
  *
  * Proc which determines interaction between a swarmer and whatever it is attempting to consume
  * Arguments:
  * * target - The material or object the swarmer is attempting to consume
  */
/mob/living/simple_animal/hostile/swarmer/proc/Integrate(obj/target)
	var/resource_gain = target.IntegrateAmount()
	if(resources + resource_gain > max_resources)
		to_chat(src, "<span class='warning'>We cannot hold more materials!</span>")
		return TRUE
	if(!resource_gain)
		to_chat(src, "<span class='warning'>[target] is incompatible with our internal matter recycler.</span>")
		return FALSE
	resources += resource_gain
	do_attack_animation(target)
	changeNext_move(CLICK_CD_RAPID)
	var/obj/effect/temp_visual/swarmer/integrate/I = new /obj/effect/temp_visual/swarmer/integrate(get_turf(target))
	I.pixel_x = target.pixel_x
	I.pixel_y = target.pixel_y
	I.pixel_z = target.pixel_z
	if(istype(target, /obj/item/stack))
		var/obj/item/stack/S = target
		S.use(1)
		if(S.amount)
			return TRUE
	qdel(target)
	return TRUE

/**
  * Called when a swarmer attempts to destroy a structure
  *
  * Proc which determines interaction between a swarmer and a structure it is destroying
  * Arguments:
  * * target - The material or object the swarmer is attempting to destroy
  */
/mob/living/simple_animal/hostile/swarmer/proc/DisIntegrate(atom/movable/target)
	new /obj/effect/temp_visual/swarmer/disintegration(get_turf(target))
	do_attack_animation(target)
	changeNext_move(CLICK_CD_MELEE)
	SSexplosions.lowobj += target

/**
  * Called when a swarmer attempts to teleport a living entity away
  *
  * Proc which finds a safe location to teleport a living entity to when a swarmer teleports it away.  Also energy handcuffs carbons.
  * Arguments:
  * * target - The entity the swarmer is trying to teleport away
  */
/mob/living/simple_animal/hostile/swarmer/proc/PrepareTarget(mob/living/target)
	if(target == src)
		return

	if(!is_station_level(z) && !is_mining_level(z))
		to_chat(src, "<span class='warning'>Our bluespace transceiver cannot locate a viable bluespace link, our teleportation abilities are useless in this area.</span>")
		return

	to_chat(src, "<span class='info'>Attempting to remove this being from our presence.</span>")

	if(!do_mob(src, target, 30))
		return
		
	TeleportTarget(target)
		
/mob/living/simple_animal/hostile/swarmer/proc/TeleportTarget(mob/living/target)
	var/turf/open/floor/safe_turf = find_safe_turf(zlevels = z, extended_safety_checks = TRUE)

	if(!safe_turf )
		return
	// If we're getting rid of a human, slap some energy cuffs on
	// them to keep them away from us a little longer

	if(ishuman(target))
		var/mob/living/carbon/human/victim = target
		if(!victim.handcuffed)
			victim.handcuffed = new /obj/item/restraints/handcuffs/energy/used(victim)
			victim.update_handcuffed()
			log_combat(src, victim, "handcuffed")

	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(4,0,get_turf(target))
	sparks.start()
	playsound(src, 'sound/effects/sparks4.ogg', 50, TRUE)
	do_teleport(target, safe_turf , 0, channel = TELEPORT_CHANNEL_BLUESPACE)

/mob/living/simple_animal/hostile/swarmer/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	if(!(flags & SHOCK_TESLA))
		return FALSE
	return ..()

/**
  * Called when a swarmer attempts to disassemble a machine
  *
  * Proc called when a swarmer attempts to disassemble a machine.  Destroys the machine, and gives the swarmer metal.
  * Arguments:
  * * target - The machine the swarmer is attempting to disassemble
  */
/mob/living/simple_animal/hostile/swarmer/proc/DismantleMachine(obj/machinery/target)
	do_attack_animation(target)
	to_chat(src, "<span class='info'>We begin to dismantle this machine. We will need to be uninterrupted.</span>")
	var/obj/effect/temp_visual/swarmer/dismantle/D = new /obj/effect/temp_visual/swarmer/dismantle(get_turf(target))
	D.pixel_x = target.pixel_x
	D.pixel_y = target.pixel_y
	D.pixel_z = target.pixel_z
	if(do_mob(src, target, 100))
		to_chat(src, "<span class='info'>Dismantling complete.</span>")
		var/atom/Tsec = target.drop_location()
		new /obj/item/stack/sheet/metal(Tsec, 5)
		for(var/obj/item/I in target.component_parts)
			I.forceMove(Tsec)
		var/obj/effect/temp_visual/swarmer/disintegration/N = new /obj/effect/temp_visual/swarmer/disintegration(get_turf(target))
		N.pixel_x = target.pixel_x
		N.pixel_y = target.pixel_y
		N.pixel_z = target.pixel_z
		target.dropContents()
		if(istype(target, /obj/machinery/computer))
			var/obj/machinery/computer/C = target
			if(C.circuit)
				C.circuit.forceMove(Tsec)
		qdel(target)

/**
  * Called when a swarmer attempts to create a trap
  *
  * Proc used to allow a swarmer to create a trap.  Checks if a trap is on the tile, then if the swarmer can afford, and then places the trap.
  */
/mob/living/simple_animal/hostile/swarmer/proc/CreateTrap()
	set name = "Create trap"
	set category = "Swarmer"
	set desc = "Creates a simple trap that will non-lethally electrocute anything that steps on it. Costs 4 resources."
	if(locate(/obj/structure/swarmer/trap) in loc)
		to_chat(src, "<span class='warning'>There is already a trap here. Aborting.</span>")
		return
	if(resources < 4)
		to_chat(src, "<span class='warning'>We do not have the resources for this!</span>")
		return
	Fabricate(/obj/structure/swarmer/trap, 4)

/**
  * Called when a swarmer attempts to create a barricade
  *
  * Proc used to allow a swarmer to create a barricade.  Checks if a barricade is on the tile, then if the swarmer can afford it, and then will attempt to create a barricade after a second delay.
  */
/mob/living/simple_animal/hostile/swarmer/proc/CreateBarricade()
	set name = "Create barricade"
	set category = "Swarmer"
	set desc = "Creates a barricade that will stop anything but swarmers and disabler beams from passing through.  Costs 4 resources."
	if(locate(/obj/structure/swarmer/blockade) in loc)
		to_chat(src, "<span class='warning'>There is already a blockade here. Aborting.</span>")
		return
	if(resources < 4)
		to_chat(src, "<span class='warning'>We do not have the resources for this!</span>")
		return
	if(do_mob(src, src, 10))
		Fabricate(/obj/structure/swarmer/blockade, 4)

/**
  * Called when a swarmer attempts to create a drone
  *
  * Proc used to allow a swarmer to create a drone.  Checks if the swarmer can afford the drone, then creates it after 5 seconds, and also registers it to the creating swarmer so it can command it
  */
/mob/living/simple_animal/hostile/swarmer/proc/CreateSwarmer()
	set name = "Replicate"
	set category = "Swarmer"
	set desc = "Creates a duplicate of ourselves, capable of protecting us while we complete our objectives."
	to_chat(src, "<span class='info'>We are attempting to replicate ourselves. We will need to stand still until the process is complete.</span>")
	if(resources < 20)
		to_chat(src, "<span class='warning'>We do not have the resources for this!</span>")
		return
	if(!isturf(loc))
		to_chat(src, "<span class='warning'>This is not a suitable location for replicating ourselves. We need more room.</span>")
		return
	if(do_mob(src, src, 50))
		var/createtype = SwarmerTypeToCreate()
		if(createtype)
			var/mob/newswarmer = Fabricate(createtype, 20)
			LAZYADD(dronelist, newswarmer)
			RegisterSignal(newswarmer, COMSIG_PARENT_QDELETING, .proc/remove_drone, newswarmer)
			playsound(loc,'sound/items/poster_being_created.ogg',20, TRUE, -1)

/**
  * Used to determine what type of swarmer a swarmer should create
  *
  * Returns the type of the swarmer to be created
  */
/mob/living/simple_animal/hostile/swarmer/proc/SwarmerTypeToCreate()
	return /mob/living/simple_animal/hostile/swarmer/melee

/**
  * Called when a swarmer attempts to repair itself
  *
  * Proc used to allow a swarmer self-repair.  If the swarmer does not move after a period of time, then it will heal fully
  */
/mob/living/simple_animal/hostile/swarmer/proc/RepairSelf()
	set name = "Self Repair"
	set category = "Swarmer"
	set desc = "Attempts to repair damage to our body. You will have to remain motionless until repairs are complete."
	if(!isturf(loc))
		return
	to_chat(src, "<span class='info'>Attempting to repair damage to our body, stand by...</span>")
	if(do_mob(src, src, 100))
		adjustHealth(-maxHealth)
		to_chat(src, "<span class='info'>We successfully repaired ourselves.</span>")

/**
  * Called when a swarmer toggles its light
  *
  * Proc used to allow a swarmer to toggle its  light on and off.  If a swarmer has any drones, change their light settings to match their master's.
  */
/mob/living/simple_animal/hostile/swarmer/proc/ToggleLight()
	if(!light_range)
		set_light(3)
		if(!mind)
			return
		for(var/d in dronelist)
			var/mob/living/simple_animal/hostile/swarmer/melee/drone = d
			drone.set_light(3)
	else
		set_light(0)
		if(!mind)
			return
		for(var/d in dronelist)
			var/mob/living/simple_animal/hostile/swarmer/melee/drone = d
			drone.set_light(0)

/**
  * Proc which is used for swarmer comms
  *
  * Proc called which sends a message to all other swarmers.
  * Arugments:
  * * msg - The message the swarmer is sending, gotten from ContactSwarmers()
  */
/mob/living/simple_animal/hostile/swarmer/proc/swarmer_chat(msg)
	var/rendered = "<B>Swarm communication - [src]</b> [say_quote(msg)]"
	for(var/i in GLOB.mob_list)
		var/mob/M = i
		if(isswarmer(M))
			to_chat(M, rendered)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")

/**
  * Proc which is used for inputting a swarmer message
  *
  * Proc which is used for a swarmer to input a message on a pop-up box, then attempt to send that message to the other swarmers
  */
/mob/living/simple_animal/hostile/swarmer/proc/ContactSwarmers()
	var/message = stripped_input(src, "Announce to other swarmers", "Swarmer contact")
	// TODO get swarmers their own colour rather than just boldtext
	if(message)
		swarmer_chat(message)
		
/**
  * Removes a drone from the swarmer's list.
  *
  * Removes the drone from our list.
  * Called specifically when a drone is about to be destroyed, so we don't have any null references.
  * Arguments:
  * * mob/drone - The drone to be removed from the list.
  */
mob/living/simple_animal/hostile/swarmer/proc/remove_drone(mob/drone, force)
	dronelist -= drone

/**
  * # Swarmer Drone
  *
  * Melee subtype of swarmers, always AI-controlled under normal circumstances.  Cannot fire projectiles, but does double stamina damage on melee
  */
/mob/living/simple_animal/hostile/swarmer/melee
	icon_state = "swarmer_melee"
	icon_living = "swarmer_melee"
	ranged = FALSE
	AIStatus = AI_ON
	melee_damage_lower = 30
	melee_damage_upper = 30

/obj/projectile/beam/disabler/swarmer/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(.)	
		if(!istype(target, /mob/living/simple_animal) || !istype(firer, /mob/living/simple_animal/hostile/swarmer))
			return
		var/mob/living/simple_animal/hostile/swarmer/swarmer = firer
		swarmer.TeleportTarget(target)
