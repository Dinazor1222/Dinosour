/mob/living/simple_animal/hostile/feral_cat
	name = "feral cat"
	desc = "Kitty!! Wait, no no DON'T BITE-"
	icon = 'icons/mob/pets.dmi'
	icon_state = "cat2"
	icon_living = "cat2"
	icon_dead = "cat2_dead"
	gender = MALE
	maxHealth = 30
	health = 30
	melee_damage_lower = 15
	melee_damage_upper = 7
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	speak = list("Meow!", "Esp!", "Purr!", "HSSSSS")
	speak_emote = list("purrs", "meows")
	emote_hear = list("meows", "mews")
	speak_chance = 1
	turns_per_move = 5
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_SMALL
	minbodytemp = 200
	maxbodytemp = 400
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/slab = 2)

	gold_core_spawnable = 1
	faction = list("cat", ROLE_SYNDICATE)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 5
