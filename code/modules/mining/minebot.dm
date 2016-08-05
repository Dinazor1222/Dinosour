/**********************Mining drone**********************/
#define MINEDRONE_COLLECT 1
#define MINEDRONE_ATTACK 2

/mob/living/simple_animal/hostile/mining_drone
	name = "nanotrasen minebot"
	desc = "The instructions printed on the side read: This is a small robot used to support miners, can be set to search and collect loose ore, or to help fend off wildlife. A mining scanner can instruct it to drop loose ore. Field repairs can be done with a welder."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "mining_drone"
	icon_living = "mining_drone"
	status_flags = CANSTUN|CANWEAKEN|CANPUSH
	stop_automated_movement_when_pulled = 1
	mouse_opacity = 1
	faction = list("neutral")
	a_intent = "harm"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	wander = 0
	idle_vision_range = 5
	move_to_delay = 10
	retreat_distance = 1
	minimum_distance = 2
	health = 125
	maxHealth = 125
	melee_damage_lower = 15
	melee_damage_upper = 15
	environment_smash = 0
	check_friendly_fire = 1
	attacktext = "drills"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	ranged = 1
	sentience_type = SENTIENCE_MINEBOT
	ranged_message = "shoots"
	ranged_cooldown_time = 30
	projectiletype = /obj/item/projectile/kinetic
	projectilesound = 'sound/weapons/Gunshot4.ogg'
	speak_emote = list("states")
	wanted_objects = list(/obj/item/weapon/ore/diamond, /obj/item/weapon/ore/gold, /obj/item/weapon/ore/silver,
						  /obj/item/weapon/ore/plasma,  /obj/item/weapon/ore/uranium,    /obj/item/weapon/ore/iron,
						  /obj/item/weapon/ore/bananium, /obj/item/weapon/ore/titanium)
	healable = 0
	var/mode = MINEDRONE_COLLECT
	var/light_on = 0

/mob/living/simple_animal/hostile/mining_drone/sentience_act()
	AIStatus = AI_OFF
	check_friendly_fire = 0

/mob/living/simple_animal/hostile/mining_drone/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I
		if(W.welding && !stat)
			if(AIStatus != AI_OFF && AIStatus != AI_IDLE)
				user << "<span class='info'>[src] is moving around too much to repair!</span>"
				return
			if(maxHealth == health)
				user << "<span class='info'>[src] is at full integrity.</span>"
			else
				adjustBruteLoss(-10)
				user << "<span class='info'>You repair some of the armor on [src].</span>"
			return
	if(istype(I, /obj/item/device/mining_scanner) || istype(I, /obj/item/device/t_scanner/adv_mining_scanner))
		user << "<span class='info'>You instruct [src] to drop any collected ore.</span>"
		DropOre()
		return
	..()

/mob/living/simple_animal/hostile/mining_drone/death()
	..()
	visible_message("<span class='danger'>[src] is destroyed!</span>")
	new /obj/effect/decal/cleanable/robot_debris(src.loc)
	DropOre(0)
	qdel(src)
	return

/mob/living/simple_animal/hostile/mining_drone/New()
	..()
	SetCollectBehavior()

/mob/living/simple_animal/hostile/mining_drone/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == "help")
		toggle_minedrone_mode()
		switch(mode)
			if(MINEDRONE_COLLECT)
				M << "<span class='info'>[src] has been set to search and store loose ore.</span>"
			if(MINEDRONE_ATTACK)
				M << "<span class='info'>[src] has been set to attack hostile wildlife.</span>"
		return
	..()

/mob/living/simple_animal/hostile/mining_drone/proc/SetCollectBehavior()
	mode = MINEDRONE_COLLECT
	idle_vision_range = 9
	search_objects = 2
	wander = 1
	ranged = 0
	minimum_distance = 1
	retreat_distance = null
	icon_state = "mining_drone"
	src << "<span class='info'>You are set to collect mode. You can now collect loose ore.</span>"

/mob/living/simple_animal/hostile/mining_drone/proc/SetOffenseBehavior()
	mode = MINEDRONE_ATTACK
	idle_vision_range = 7
	search_objects = 0
	wander = 0
	ranged = 1
	retreat_distance = 1
	minimum_distance = 2
	icon_state = "mining_drone_offense"
	src << "<span class='info'>You are set to attack mode. You can now attack from range.</span>"

/mob/living/simple_animal/hostile/mining_drone/AttackingTarget()
	if(istype(target, /obj/item/weapon/ore) && mode ==  MINEDRONE_COLLECT)
		CollectOre()
		return
	..()

/mob/living/simple_animal/hostile/mining_drone/proc/CollectOre()
	var/obj/item/weapon/ore/O
	for(O in src.loc)
		O.loc = src
	for(var/dir in alldirs)
		var/turf/T = get_step(src,dir)
		for(O in T)
			O.loc = src
	return

/mob/living/simple_animal/hostile/mining_drone/proc/DropOre(message = 1)
	if(!contents.len)
		if(message)
			src << "<span class='notice'>You attempt to dump your stored ore, but you have none.</span>"
		return
	if(message)
		src << "<span class='notice'>You dump your stored ore.</span>"
	for(var/obj/item/weapon/ore/O in contents)
		contents -= O
		O.loc = src.loc
	return

/mob/living/simple_animal/hostile/mining_drone/adjustHealth(amount)
	if(mode != MINEDRONE_ATTACK && amount > 0)
		SetOffenseBehavior()
	. = ..()

//Verbs for sentient minebots

/mob/living/simple_animal/hostile/mining_drone/verb/toggle_minedrone_light()
	set category = "Minebot"
	set name = "Toggle Minebot Light"

	if(light_on == 2)
		return

	if(light_on)
		AddLuminosity(-6)
	else
		AddLuminosity(6)
	light_on = !light_on
	src << "<span class='notice'>You toggle your light [light_on ? "on" : "off"].</span>"


/mob/living/simple_animal/hostile/mining_drone/verb/toggle_meson_vision()
	set category = "Minebot"
	set name = "Toggle Meson Vision"
	if(sight & SEE_TURFS)
		sight &= ~SEE_TURFS
		see_invisible = SEE_INVISIBLE_LIVING
	else
		sight |= SEE_TURFS
		see_invisible = SEE_INVISIBLE_MINIMUM

	src << "<span class='notice'>You toggle your meson vision [(sight & SEE_TURFS) ? "on" : "off"].</span>"

/mob/living/simple_animal/hostile/mining_drone/verb/toggle_minedrone_mode()
	set category = "Minebot"
	set name = "Toggle Mode"

	switch(mode)
		if(MINEDRONE_COLLECT)
			SetOffenseBehavior()
		if(MINEDRONE_ATTACK)
			SetCollectBehavior()
		else //This should never happen.
			mode = MINEDRONE_COLLECT
			SetCollectBehavior()

/mob/living/simple_animal/hostile/mining_drone/verb/dump_ore()
	set category = "Minebot"
	set name = "Dump Ore"

	DropOre()


/**********************Minebot Upgrades**********************/

//Melee

/obj/item/device/mine_bot_ugprade
	name = "minebot melee upgrade"
	desc = "A minebot upgrade."
	icon_state = "door_electronics"
	icon = 'icons/obj/module.dmi'

/obj/item/device/mine_bot_ugprade/afterattack(mob/living/simple_animal/hostile/mining_drone/M, mob/user, proximity)
	if(!istype(M) || !proximity)
		return
	upgrade_bot(M, user)

/obj/item/device/mine_bot_ugprade/proc/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/M, mob/user)
	if(M.melee_damage_upper != initial(M.melee_damage_upper))
		user << "[src] already has a combat upgrade installed!"
		return
	M.melee_damage_lower = 22
	M.melee_damage_upper = 22
	qdel(src)

//Health

/obj/item/device/mine_bot_ugprade/health
	name = "minebot chassis upgrade"

/obj/item/device/mine_bot_ugprade/health/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/M, mob/user)
	if(M.maxHealth != initial(M.maxHealth))
		user << "[src] already has a reinforced chassis!"
		return
	M.maxHealth = 170
	qdel(src)


//Cooldown

/obj/item/device/mine_bot_ugprade/cooldown
	name = "minebot cooldown upgrade"

/obj/item/device/mine_bot_ugprade/cooldown/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/M, mob/user)
	name = "minebot cooldown upgrade"
	if(M.ranged_cooldown_time != initial(M.ranged_cooldown_time))
		user << "[src] already has a decreased weapon cooldown!"
		return
	M.ranged_cooldown_time = 10
	qdel(src)


//AI
/obj/item/slimepotion/sentience/mining
	name = "minebot AI upgrade"
	desc = "Can be used to grant sentience to minebots."
	icon_state = "door_electronics"
	icon = 'icons/obj/module.dmi'
	sentience_type = SENTIENCE_MINEBOT
	origin_tech = "programming=6"

#undef MINEDRONE_COLLECT
#undef MINEDRONE_ATTACK