#define DRAKE_SWOOP_HEIGHT 270 //how high up drakes go, in pixels
#define DRAKE_SWOOP_DIRECTION_CHANGE_RANGE 5 //the range our x has to be within to not change the direction we slam from

#define SWOOP_DAMAGEABLE 1
#define SWOOP_INVULNERABLE 2

/*

ASH DRAKE

Ash drakes spawn randomly wherever a lavaland creature is able to spawn. They are the draconic guardians of the Necropolis.

It acts as a melee creature, chasing down and attacking its target while also using different attacks to augment its power that increase as it takes damage.

Whenever possible, the drake will breathe fire directly at it's target, igniting and heavily damaging anything caught in the blast.
It also often causes lava to pool from the ground around you - many nearby turfs will temporarily turn into lava, dealing damage to anything on the turfs.
The drake also utilizes its wings to fly into the sky, flying after its target and attempting to slam down on them. Anything near when it slams down takes huge damage.
 - Sometimes it will chain these swooping attacks over and over, making swiftness a necessity.
 - Sometimes, it will encase its target in an arena of lava

When an ash drake dies, it leaves behind a chest that can contain four things:
 1. A spectral blade that allows its wielder to call ghosts to it, enhancing its power
 2. A lava staff that allows its wielder to create lava
 3. A spellbook and wand of fireballs
 4. A bottle of dragon's blood with several effects, including turning its imbiber into a drake themselves.

When butchered, they leave behind diamonds, sinew, bone, and ash drake hide. Ash drake hide can be used to create a hooded cloak that protects its wearer from ash storms.

Difficulty: Medium

*/

/mob/living/simple_animal/hostile/megafauna/dragon
	name = "ash drake"
	desc = "Guardians of the necropolis."
	health = 2500
	maxHealth = 2500
	spacewalk = TRUE
	attacktext = "chomps"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	icon_state = "dragon"
	icon_living = "dragon"
	icon_dead = "dragon_dead"
	friendly = "stares down"
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 1
	move_to_delay = 5
	ranged = 1
	pixel_x = -16
	crusher_loot = list(/obj/structure/closet/crate/necropolis/dragon/crusher)
	loot = list(/obj/structure/closet/crate/necropolis/dragon)
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30)
	guaranteed_butcher_results = list(/obj/item/stack/sheet/animalhide/ashdrake = 10)
	var/swooping = NONE
	var/player_cooldown = 0
	medal_type = BOSS_MEDAL_DRAKE
	score_type = DRAKE_SCORE
	deathmessage = "collapses into a pile of bones, its flesh sloughing away."
	deathsound = 'sound/magic/demon_dies.ogg'
	var/datum/action/small_sprite/smallsprite = new/datum/action/small_sprite/drake()

	do_footstep = TRUE

/mob/living/simple_animal/hostile/megafauna/dragon/Initialize()
	smallsprite.Grant(src)
	. = ..()
	internal = new/obj/item/gps/internal/dragon(src)

/mob/living/simple_animal/hostile/megafauna/dragon/ex_act(severity, target)
	if(severity == 3)
		return
	..()

/mob/living/simple_animal/hostile/megafauna/dragon/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && (swooping & SWOOP_INVULNERABLE))
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/megafauna/dragon/visible_message()
	if(swooping & SWOOP_INVULNERABLE) //to suppress attack messages without overriding every single proc that could send a message saying we got hit
		return
	return ..()

/mob/living/simple_animal/hostile/megafauna/dragon/AttackingTarget()
	if(!swooping)
		return ..()

/mob/living/simple_animal/hostile/megafauna/dragon/DestroySurroundings()
	if(!swooping)
		..()

/mob/living/simple_animal/hostile/megafauna/dragon/Move()
	if(!swooping)
		..()

/mob/living/simple_animal/hostile/megafauna/dragon/Goto(target, delay, minimum_distance)
	if(!swooping)
		..()

/mob/living/simple_animal/hostile/megafauna/dragon/OpenFire()
	if(swooping)
		return
	anger_modifier = CLAMP(((maxHealth - health)/50),0,20)
	ranged_cooldown = world.time + ranged_cooldown_time

	if(prob(15 + anger_modifier) && !client)
		if(health < maxHealth*0.5)
			swoop_attack(lava_arena = TRUE)
		else
			lava_swoop()

	else if(prob(10+anger_modifier) && !client)
		if(health < maxHealth*0.5)
			mass_fire()
		else
			fire_cone()
	else
		if(prob(50) && !client)
			INVOKE_ASYNC(src, .proc/lava_pools, 10, 2)
		fire_cone()

/mob/living/simple_animal/hostile/megafauna/dragon/proc/lava_pools(var/amount, var/delay = 0.8)
	if(!target)
		return
	target.visible_message("<span class='boldwarning'>Lava starts to pool up around you!</span>")
	while(amount > 0)
		if(!target)
			break
		var/turf/T = pick(RANGE_TURFS(1, target))
		new /obj/effect/temp_visual/lava_warning(T, 60) // longer reset time for the lava
		amount--
		sleep(delay)

/mob/living/simple_animal/hostile/megafauna/dragon/proc/lava_swoop(var/amount = 30)
	INVOKE_ASYNC(src, .proc/lava_pools, amount)
	swoop_attack(FALSE, target, 1000) // longer cooldown until it gets reset below
	fire_cone()
	if(health < maxHealth*0.5)
		sleep(10)
		fire_cone()
		sleep(10)
		fire_cone()
	SetRecoveryTime(40)

/mob/living/simple_animal/hostile/megafauna/dragon/proc/mass_fire(var/spiral_count = 12, var/range = 15, var/times = 3)
	for(var/i = 1 to times)
		SetRecoveryTime(50)
		playsound(get_turf(src),'sound/magic/fireball.ogg', 200, 1)
		var/increment = 360 / spiral_count
		for(var/j = 1 to spiral_count)
			var/list/turfs = line_target(j * increment + i * increment / 2, range, src)
			INVOKE_ASYNC(src, .proc/fire_line, turfs)
		sleep(25)
	SetRecoveryTime(30)

/mob/living/simple_animal/hostile/megafauna/dragon/proc/lava_arena()
	if(!target)
		return
	target.visible_message("<span class='boldwarning'>[src] encases you in an arena of fire!</span>")
	var/amount = 3
	var/turf/center = get_turf(target)
	var/list/walled = RANGE_TURFS(3, center) - RANGE_TURFS(2, center)
	var/list/drakewalls = list()
	for(var/turf/T in walled)
		drakewalls += new /obj/effect/temp_visual/drakewall(T) // no people with lava immunity can just run away from the attack for free
	var/list/indestructible_turfs = list()
	for(var/turf/T in RANGE_TURFS(2, center))
		if(istype(T, /turf/open/indestructible))
			continue
		if(!istype(T, /turf/closed/indestructible))
			T.ChangeTurf(/turf/open/floor/plating/asteroid/basalt/lava_land_surface)
		else
			indestructible_turfs += T
	sleep(10) // give them a bit of time to realize what attack is actually happening

	var/list/turfs = RANGE_TURFS(2, center)
	while(amount > 0)
		var/list/empty = indestructible_turfs.Copy() // can't place safe turfs on turfs that weren't changed to be open
		var/any_attack = 0
		for(var/turf/T in turfs)
			for(var/mob/living/L in T.contents)
				if(L.client)
					empty += pick(((RANGE_TURFS(2, L) - RANGE_TURFS(1, L)) & turfs) - empty) // picks a turf within 2 of the creature not outside or in the shield
					any_attack = 1
			for(var/obj/mecha/M in T.contents)
				empty += pick(((RANGE_TURFS(2, M) - RANGE_TURFS(1, M)) & turfs) - empty)
				any_attack = 1
		if(!any_attack)
			for(var/obj/effect/temp_visual/drakewall/D in drakewalls)
				qdel(D)
			return 0 // nothing to attack in the arena time for enraged attack if we still have a target
		for(var/turf/T in turfs)
			if(!(T in empty))
				new /obj/effect/temp_visual/lava_warning(T)
			else if(!istype(T, /turf/closed/indestructible))
				new /obj/effect/temp_visual/lava_safe(T)
		amount--
		sleep(24)
	return 1 // attack finished completely

/mob/living/simple_animal/hostile/megafauna/dragon/proc/arena_escape_enrage() // you ran somehow / teleported away from my arena attack now i'm mad fucker
	SetRecoveryTime(80)
	visible_message("<span class='boldwarning'>[src] starts to glow vibrantly as its wounds close up!</span>")
	adjustBruteLoss(-250) // yeah you're gonna pay for that, don't run nerd
	add_atom_colour(rgb(255, 255, 0), TEMPORARY_COLOUR_PRIORITY)
	move_to_delay = move_to_delay / 2
	light_range = 10
	sleep(10) // run.
	mass_fire(20, 15, 3)
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	move_to_delay = initial(move_to_delay)
	light_range = initial(light_range)

/mob/living/simple_animal/hostile/megafauna/dragon/proc/fire_cone(var/atom/at = target)
	playsound(get_turf(src),'sound/magic/fireball.ogg', 200, 1)
	if(QDELETED(src) || stat == DEAD) // we dead no fire
		return
	var/range = 15
	var/list/turfs = list()
	turfs = line_target(-40, range, at)
	INVOKE_ASYNC(src, .proc/fire_line, turfs)
	turfs = line_target(0, range, at)
	INVOKE_ASYNC(src, .proc/fire_line, turfs)
	turfs = line_target(40, range, at)
	INVOKE_ASYNC(src, .proc/fire_line, turfs)

/mob/living/simple_animal/hostile/megafauna/dragon/proc/line_target(var/offset, var/range, var/atom/at = target)
	if(!at)
		return
	var/angle = ATAN2(at.x - src.x, at.y - src.y) + offset
	var/turf/T = get_turf(src)
	for(var/i in 1 to range)
		var/turf/check = locate(src.x + cos(angle) * i, src.y + sin(angle) * i, src.z)
		if(!check)
			break
		T = check
	return (getline(src, T) - get_turf(src))

/mob/living/simple_animal/hostile/megafauna/dragon/proc/fire_line(var/list/turfs)
	var/list/hit_list = list()
	for(var/turf/T in turfs)
		if(istype(T, /turf/closed))
			break
		new /obj/effect/hotspot(T)
		T.hotspot_expose(700,50,1)
		for(var/mob/living/L in T.contents)
			if(L in hit_list || L == src)
				continue
			hit_list += L
			L.adjustFireLoss(20)
			to_chat(L, "<span class='userdanger'>You're hit by [src]'s fire breath!</span>")

		// deals damage to mechs
		for(var/obj/mecha/M in T.contents)
			if(M in hit_list)
				continue
			hit_list += M
			M.take_damage(45, BRUTE, "melee", 1)
		sleep(1.5)

/mob/living/simple_animal/hostile/megafauna/dragon/proc/swoop_attack(lava_arena = FALSE, atom/movable/manual_target, var/swoop_cooldown = 30)
	if(stat || swooping)
		return
	if(manual_target)
		target = manual_target
	if(!target)
		return
	stop_automated_movement = TRUE
	swooping |= SWOOP_DAMAGEABLE
	density = FALSE
	icon_state = "shadow"
	visible_message("<span class='boldwarning'>[src] swoops up high!</span>")

	var/negative
	var/initial_x = x
	if(target.x < initial_x) //if the target's x is lower than ours, swoop to the left
		negative = TRUE
	else if(target.x > initial_x)
		negative = FALSE
	else if(target.x == initial_x) //if their x is the same, pick a direction
		negative = prob(50)
	var/obj/effect/temp_visual/dragon_flight/F = new /obj/effect/temp_visual/dragon_flight(loc, negative)

	negative = !negative //invert it for the swoop down later

	var/oldtransform = transform
	alpha = 255
	animate(src, alpha = 204, transform = matrix()*0.9, time = 3, easing = BOUNCE_EASING)
	for(var/i in 1 to 3)
		sleep(1)
		if(QDELETED(src) || stat == DEAD) //we got hit and died, rip us
			qdel(F)
			if(stat == DEAD)
				swooping &= ~SWOOP_DAMAGEABLE
				animate(src, alpha = 255, transform = oldtransform, time = 0, flags = ANIMATION_END_NOW) //reset immediately
			return
	animate(src, alpha = 100, transform = matrix()*0.7, time = 7)
	swooping |= SWOOP_INVULNERABLE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	sleep(7)

	while(target && loc != get_turf(target))
		forceMove(get_step(src, get_dir(src, target)))
		sleep(0.5)

	// Ash drake flies onto its target and rains fire down upon them
	var/descentTime = 10;
	var/lava_success = 1
	if(lava_arena)
		lava_success = lava_arena()


	//ensure swoop direction continuity.
	if(negative)
		if(ISINRANGE(x, initial_x + 1, initial_x + DRAKE_SWOOP_DIRECTION_CHANGE_RANGE))
			negative = FALSE
	else
		if(ISINRANGE(x, initial_x - DRAKE_SWOOP_DIRECTION_CHANGE_RANGE, initial_x - 1))
			negative = TRUE
	new /obj/effect/temp_visual/dragon_flight/end(loc, negative)
	new /obj/effect/temp_visual/dragon_swoop(loc)
	animate(src, alpha = 255, transform = oldtransform, descentTime)
	sleep(descentTime)
	swooping &= ~SWOOP_INVULNERABLE
	mouse_opacity = initial(mouse_opacity)
	icon_state = "dragon"
	playsound(loc, 'sound/effects/meteorimpact.ogg', 200, 1)
	for(var/mob/living/L in orange(1, src))
		if(L.stat)
			visible_message("<span class='warning'>[src] slams down on [L], crushing [L.p_them()]!</span>")
			L.gib()
		else
			L.adjustBruteLoss(75)
			if(L && !QDELETED(L)) // Some mobs are deleted on death
				var/throw_dir = get_dir(src, L)
				if(L.loc == loc)
					throw_dir = pick(GLOB.alldirs)
				var/throwtarget = get_edge_target_turf(src, throw_dir)
				L.throw_at(throwtarget, 3)
				visible_message("<span class='warning'>[L] is thrown clear of [src]!</span>")
	for(var/obj/mecha/M in orange(1, src))
		M.take_damage(75, BRUTE, "melee", 1)

	for(var/mob/M in range(7, src))
		shake_camera(M, 15, 1)

	density = TRUE
	sleep(1)
	swooping &= ~SWOOP_DAMAGEABLE
	SetRecoveryTime(swoop_cooldown)
	if(!lava_success)
		arena_escape_enrage()

/mob/living/simple_animal/hostile/megafauna/dragon/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(player_cooldown >= world.time)
		to_chat(src, "<span class='warning'>You need to wait [(player_cooldown - world.time) / 10] seconds before swooping again!</span>")
		return
	swoop_attack(FALSE, A)
	lava_pools(10, 2) // less pools but longer delay before spawns
	player_cooldown = world.time + 200 // needs seperate cooldown or cant use fire attacks

/obj/item/gps/internal/dragon
	icon_state = null
	gpstag = "Fiery Signal"
	desc = "Here there be dragons."
	invisibility = 100

/obj/effect/temp_visual/lava_warning
	icon_state = "lavastaff_warn"
	layer = BELOW_MOB_LAYER
	light_range = 2
	duration = 13

/obj/effect/temp_visual/lava_warning/ex_act()
	return

/obj/effect/temp_visual/lava_warning/Initialize(mapload, var/reset_time = 10)
	. = ..()
	INVOKE_ASYNC(src, .proc/fall, reset_time)
	src.alpha = 63.75
	animate(src, alpha = 255, time = duration)

/obj/effect/temp_visual/lava_warning/proc/fall(var/reset_time)
	var/turf/T = get_turf(src)
	playsound(T,'sound/magic/fleshtostone.ogg', 80, 1)
	sleep(duration)
	playsound(T,'sound/magic/fireball.ogg', 200, 1)

	for(var/mob/living/L in T.contents)
		if(istype(L, /mob/living/simple_animal/hostile/megafauna/dragon))
			continue
		L.adjustFireLoss(10)
		to_chat(L, "<span class='userdanger'>You fall directly into the pool of lava!</span>")

	// deals damage to mechs
	for(var/obj/mecha/M in T.contents)
		M.take_damage(45, BRUTE, "melee", 1)

	// changes turf to lava temporarily
	if(!istype(T, /turf/closed) && !istype(T, /turf/open/lava))
		var/lava_turf = /turf/open/lava/smooth
		var/reset_turf = T.type
		T.ChangeTurf(lava_turf)
		sleep(reset_time)
		T.ChangeTurf(reset_turf)

/obj/effect/temp_visual/drakewall
	desc = "An ash drakes true flame."
	name = "Fire Barrier"
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	anchored = TRUE
	opacity = 0
	density = TRUE
	CanAtmosPass = ATMOS_PASS_DENSITY
	duration = 82
	color = COLOR_DARK_ORANGE

/obj/effect/temp_visual/lava_safe
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "trap-earth"
	layer = BELOW_MOB_LAYER
	light_range = 2
	duration = 13

/obj/effect/temp_visual/dragon_swoop
	name = "certain death"
	desc = "Don't just stand there, move!"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "landing"
	layer = BELOW_MOB_LAYER
	pixel_x = -32
	pixel_y = -32
	color = "#FF0000"
	duration = 10

/obj/effect/temp_visual/dragon_flight
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	icon_state = "dragon"
	layer = ABOVE_ALL_MOB_LAYER
	pixel_x = -16
	duration = 10
	randomdir = FALSE

/obj/effect/temp_visual/dragon_flight/Initialize(mapload, negative)
	. = ..()
	INVOKE_ASYNC(src, .proc/flight, negative)

/obj/effect/temp_visual/dragon_flight/proc/flight(negative)
	if(negative)
		animate(src, pixel_x = -DRAKE_SWOOP_HEIGHT*0.1, pixel_z = DRAKE_SWOOP_HEIGHT*0.15, time = 3, easing = BOUNCE_EASING)
	else
		animate(src, pixel_x = DRAKE_SWOOP_HEIGHT*0.1, pixel_z = DRAKE_SWOOP_HEIGHT*0.15, time = 3, easing = BOUNCE_EASING)
	sleep(3)
	icon_state = "swoop"
	if(negative)
		animate(src, pixel_x = -DRAKE_SWOOP_HEIGHT, pixel_z = DRAKE_SWOOP_HEIGHT, time = 7)
	else
		animate(src, pixel_x = DRAKE_SWOOP_HEIGHT, pixel_z = DRAKE_SWOOP_HEIGHT, time = 7)

/obj/effect/temp_visual/dragon_flight/end
	pixel_x = DRAKE_SWOOP_HEIGHT
	pixel_z = DRAKE_SWOOP_HEIGHT
	duration = 10

/obj/effect/temp_visual/dragon_flight/end/flight(negative)
	if(negative)
		pixel_x = -DRAKE_SWOOP_HEIGHT
		animate(src, pixel_x = -16, pixel_z = 0, time = 5)
	else
		animate(src, pixel_x = -16, pixel_z = 0, time = 5)

/mob/living/simple_animal/hostile/megafauna/dragon/lesser
	name = "lesser ash drake"
	maxHealth = 200
	health = 200
	faction = list("neutral")
	obj_damage = 80
	melee_damage_upper = 30
	melee_damage_lower = 30
	mouse_opacity = MOUSE_OPACITY_ICON
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	loot = list()
	crusher_loot = list()
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30)

/mob/living/simple_animal/hostile/megafauna/dragon/lesser/grant_achievement(medaltype,scoretype)
	return
	
/mob/living/simple_animal/hostile/megafauna/dragon/space_dragon
	name = "space dragon"
	maxHealth = 250
	health = 250
	desc = "A dangerously territorial creature that lives in space.  Does not take kindly to uninvited guests within its claim."
	obj_damage = 80
	melee_damage_upper = 35
	melee_damage_lower = 35
	speed = 0
	mouse_opacity = MOUSE_OPACITY_ICON
	color = rgb(75,0,130)
	loot = list()
	crusher_loot = list()
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30)
	move_force = MOVE_FORCE_NORMAL
	move_resist = MOVE_FORCE_NORMAL
	pull_force = MOVE_FORCE_NORMAL

/mob/living/simple_animal/hostile/megafauna/dragon/space_dragon/grant_achievement(medaltype,scoretype)
	return	
	
/mob/living/simple_animal/hostile/megafauna/dragon/space_dragon/proc/fire_stream(var/atom/at = target)
	playsound(get_turf(src),'sound/magic/fireball.ogg', 200, 1)
	if(QDELETED(src) || stat == DEAD) // we dead no fire
		return
	var/range = 20
	var/list/turfs = list()
	turfs = line_target(0, range, at)
	INVOKE_ASYNC(src, .proc/fire_line, turfs)
	
/mob/living/simple_animal/hostile/megafauna/dragon/space_dragon/OpenFire()
	if(swooping)
		return
	anger_modifier = CLAMP(((maxHealth - health)/50),0,20)
	ranged_cooldown = world.time + ranged_cooldown_time

	if(prob(15 + anger_modifier) && !client)
		tail_sweep()

	else if(prob(10+anger_modifier) && !client)
		if(health < maxHealth*0.5)
			tail_sweep()
		else
			fire_stream()
	else
		if(prob(50) && !client)
			tail_sweep()
		fire_stream()

/mob/living/simple_animal/hostile/megafauna/dragon/space_dragon/proc/tail_sweep()
	var/turf/dragon_turf = get_turf(src)
	var/dir_to_target = get_dir(dragon_turf, get_turf(target))
	var/static/list/tail_sweep_angles = list(0, -45, 45, 90, -90, 145, -145, 180)
	visible_message("<span class='warning'>[src] sweeps their tail around them!</span>")
	for(var/i in tail_sweep_angles)
		var/turf/T = get_step(dragon_turf, turn(dir_to_target, i))
		for(var/mob/living/carbon/L in T)
			if(src.Adjacent(L) && L.density)
				L.visible_message("<span class='warning'>[L] has been knocked down by [src]'s tail!</span>")
				L.Paralyze(60)
	src.spin(10, 1)
	
/mob/living/simple_animal/hostile/megafauna/dragon/space_dragon/AltClickOn()
	if(QDELETED(src) || stat == DEAD) // We're dead, don't do tail sweep.
		return
	if(player_cooldown >= world.time)
		to_chat(src, "<span class='warning'>You need to wait [(player_cooldown - world.time) / 10] seconds before using your tail again!</span>")
		return
	tail_sweep()
	player_cooldown = world.time + 150 // needs seperate cooldown or cant use fire attacks
