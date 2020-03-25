/mob/living/simple_animal/hostile/asteroid/ice_whelp
	name = "ice whelp"
	desc = "The offspring of an ice drake, weak in comparison but still terrifying."
	icon = 'icons/mob/icemoon/icemoon_monsters.dmi'
	icon_state = "ice_whelp"
	icon_living = "ice_whelp"
	icon_dead = "ice_whelp_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mouse_opacity = MOUSE_OPACITY_ICON
	friendly_verb_continuous = "stares down"
	friendly_verb_simple = "stare down"
	speak_emote = list("roars")
	speed = 10
	move_to_delay = 10
	ranged = TRUE
	ranged_cooldown_time = 40
	maxHealth = 350
	health = 350
	obj_damage = 40
	armour_penetration = 20
	melee_damage_lower = 20
	melee_damage_upper = 20
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	vision_range = 9
	aggro_vision_range = 9
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	butcher_results = list(/obj/item/stack/ore/diamond = 3, /obj/item/stack/sheet/sinew = 2, /obj/item/stack/sheet/bone = 10, /obj/item/stack/sheet/animalhide/ashdrake = 1)
	loot = list()
	deathmessage = "collapses on it's side."
	deathsound = 'sound/magic/demon_dies.ogg'
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/hostile/asteroid/ice_whelp/OpenFire()
	var/list/burn_turfs = getline(src, target) - get_turf(src)
	dragon_fire_line(src, burn_turfs)

/mob/living/simple_animal/hostile/asteroid/ice_whelp/Life()
	. = ..()
	if(target == null)
		adjustHealth(-maxHealth*0.025)

/mob/living/simple_animal/hostile/asteroid/ice_whelp/death(gibbed)
	move_force = MOVE_FORCE_DEFAULT
	move_resist = MOVE_RESIST_DEFAULT
	pull_force = PULL_FORCE_DEFAULT
	return ..()
