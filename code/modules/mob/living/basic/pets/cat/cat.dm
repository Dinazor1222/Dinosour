
#define RUNTIME_SAVE_DATA "data/npc_saves/Runtime.sav"
#define RUNTIME_JSON_DATA "data/npc_saves/Runtime.json"
#define MAX_CAT_DEPLOY 50
/mob/living/basic/pet/cat
	name = "cat"
	desc = "Kitty!!"
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "cat2"
	icon_living = "cat2"
	icon_dead = "cat2_dead"
	speak_emote = list("purrs", "meows")
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
//	minbodytemp = 200
//	maxbodytemp = 400
	unsuitable_atmos_damage = 0.5
	butcher_results = list(/obj/item/food/meat/slab = 1,
		/obj/item/organ/internal/ears/cat = 1,
		/obj/item/organ/external/tail/cat = 1,
		/obj/item/stack/sheet/animalhide/cat = 1
	)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	gold_core_spawnable = FRIENDLY_SPAWN
	collar_icon_state = "cat"
	has_collar_resting_icon_state = TRUE
	can_be_held = TRUE
	ai_controller = /datum/ai_controller/basic_controller/cat
	held_state = "cat2"
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/weapons/slash.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
//	footstep_type = FOOTSTEP_MOB_CLAW
	///can this cat breed?
	var/can_breed = TRUE
	///can hold items?
	var/can_hold_item = TRUE
	///list of items we can carry
	var/static/list/carriable_items = typecacheof(list(
		/obj/item/fish,
		/obj/item/food/deadmouse,
	))
	///item we are currently holding
	var/obj/item/held_food
	///mutable appearance for held item
	var/mutable_appearance/held_item_overlay

/mob/living/basic/pet/cat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "purrs!")
	add_verb(src, /mob/living/proc/toggle_resting)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	ai_controller.set_blackboard_key(BB_CARRIABLE_PREY, carriable_items)
	if(can_breed)
		add_breeding_component()
	if(can_hold_item)
		RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(pre_attack))

/mob/living/basic/pet/cat/proc/pre_attack(mob/living/source, atom/movable/target)
	SIGNAL_HANDLER
	if(!is_type_in_typecache(target, carriable_items) || held_food)
		return
	target.forceMove(src)

/mob/living/basic/pet/cat/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone != held_food)
		return
	held_food = null
	update_appearance(UPDATE_OVERLAYS)
/mob/living/basic/pet/cat/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(is_type_in_typecache(arrived, carriable_items))
		held_food = arrived
		update_appearance(UPDATE_OVERLAYS)
	return ..()

/mob/living/basic/pet/cat/update_overlays()
	. = ..()
	if(stat == DEAD ||resting || !held_food)
		return
	if(istype(held_food, /obj/item/fish))
		held_item_overlay = mutable_appearance(icon, "cat_fish_overlay")
	if(istype(held_food, /obj/item/food/deadmouse))
		held_item_overlay = mutable_appearance(icon, "cat_mouse_overlay")
	. += held_item_overlay

/mob/living/basic/pet/cat/update_resting()
	. = ..()
	if(stat == DEAD)
		return
	update_appearance(UPDATE_ICON_STATE)

/mob/living/basic/pet/cat/update_icon_state()
	. = ..()
	if (resting)
		icon_state = "[icon_living]_rest"
		return
	icon_state = "[icon_living]"

/mob/living/basic/pet/cat/proc/add_breeding_component()
	AddComponent(\
		/datum/component/breed,\
		can_breed_with = typecacheof(list(/mob/living/basic/pet/cat)),\
		baby_path = /mob/living/basic/pet/cat/kitten,\
	)

/mob/living/basic/pet/cat/space
	name = "space cat"
	desc = "They're a cat... in space!"
	icon_state = "spacecat"
	icon_living = "spacecat"
	icon_dead = "spacecat_dead"
	unsuitable_atmos_damage = 0
//	minbodytemp = TCMB
//	maxbodytemp = T0C + 40
	held_state = "spacecat"
/mob/living/basic/pet/cat/breadcat
	name = "bread cat"
	desc = "They're a cat... with a bread!"
	icon_state = "breadcat"
	icon_living = "breadcat"
	icon_dead = "breadcat_dead"
	collar_icon_state = null
	held_state = "breadcat"
	butcher_results = list(
		/obj/item/food/meat/slab = 2,
		/obj/item/organ/internal/ears/cat = 1,
		/obj/item/organ/external/tail/cat = 1,
		/obj/item/food/breadslice/plain = 1
	)
/mob/living/basic/pet/cat/original
	name = "Batsy"
	desc = "The product of alien DNA and bored geneticists."
	gender = FEMALE
	icon_state = "original"
	icon_living = "original"
	icon_dead = "original_dead"
	collar_icon_state = null
	unique_pet = TRUE
	held_state = "original"
/mob/living/basic/pet/cat/kitten
	name = "kitten"
	desc = "D'aaawwww."
	icon_state = "kitten"
	icon_living = "kitten"
	icon_dead = "kitten_dead"
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	collar_icon_state = "kitten"
	can_breed = FALSE
/mob/living/basic/pet/cat/_proc
	name = "Proc"
	gender = MALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
