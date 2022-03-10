#define RISEN_MAX_HEALTH 125

/datum/heretic_knowledge/limited_amount/risen_corpse
	name = "Shattered Risen"
	desc = "Allows you to transmute a corpse with a soul, a pair of latex or nitrile gloves, and \
		and any exosuit clothing (such as armor) to create a Shattered Risen. \
		Shattered Risen are strong ghouls that have 125 health, but cannot hold items, \
		instead having two brutal weapons for hands. You can only create one at a time."
	gain_text = "I witnessed a cold, rending force drag this corpse back to near-life. \
		When it moves, it crunches like broken glass. Its hands are no longer recognizable as human - \
		each clenched fist contains a brutal nest of sharp bone-shards instead."
	next_knowledge = list(
		/datum/heretic_knowledge/cold_snap,
		/datum/heretic_knowledge/blade_dance,
	)
	required_atoms = list(
		/obj/item/clothing/suit = 1,
		/obj/item/clothing/gloves/color/latex = 1,
		/mob/living/carbon/human = 1,
	)
	limit = 1
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/limited_amount/risen_corpse/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD || !IS_VALID_GHOUL_MOB(body) || HAS_TRAIT(body, TRAIT_HUSK))
			atoms -= body
			continue

		// We will only grab bodies with minds that have ghosts (with clients)
		if(!body.mind?.get_ghost(ghosts_with_clients = TRUE))
			atoms -= body
			continue

	if(!(locate(/mob/living/carbon/human) in atoms))
		loc.balloon_alert(user, "ritual failed, no valid body!")
		return FALSE

	return TRUE

/datum/heretic_knowledge/limited_amount/risen_corpse/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/mob/living/carbon/human/soon_to_be_ghoul = locate() in selected_atoms
	if(QDELETED(soon_to_be_ghoul)) // No body? No ritual
		stack_trace("[type] reached on_finished_recipe without a human in selected_atoms to make a ghoul out of.")
		loc.balloon_alert(user, "ritual failed, no valid body!")
		return FALSE

	soon_to_be_ghoul.grab_ghost()
	if(!soon_to_be_ghoul.mind || !soon_to_be_ghoul.client)
		stack_trace("[type] reached on_finished_recipe without a minded / cliented human in selected_atoms to make a ghoul out of.")
		loc.balloon_alert(user, "ritual failed, no valid body!")
		return FALSE

	selected_atoms -= soon_to_be_ghoul

	log_game("[key_name(user)] created a shattered risen out of [key_name(soon_to_be_ghoul)].")
	message_admins("[ADMIN_LOOKUPFLW(user)] shattered risen out of [ADMIN_LOOKUPFLW(soon_to_be_ghoul)].")

	soon_to_be_ghoul.apply_status_effect(
		/datum/status_effect/ghoul,
		RISEN_MAX_HEALTH,
		user.mind,
		CALLBACK(src, .proc/apply_to_risen),
		CALLBACK(src, .proc/remove_from_risen),
	)

/datum/heretic_knowledge/limited_amount/risen_corpse/proc/apply_to_risen(mob/living/risen)
	LAZYADD(created_items, WEAKREF(risen))

	for(var/obj/item/held as anything in risen.held_items)
		if(istype(held))
			risen.dropItemToGround(held)

		risen.put_in_hands(new /obj/item/risen_hand(), del_on_fail = TRUE)

/datum/heretic_knowledge/limited_amount/risen_corpse/proc/remove_from_risen(mob/living/risen)
	LAZYREMOVE(created_items, WEAKREF(risen))

	for(var/obj/item/risen_hand/hand in risen.held_items)
		qdel(hand)

#undef RISEN_MAX_HEALTH

/// The "hand" "weapon" used by shattered risen
/obj/item/risen_hand
	name = "bone-shards"
	desc = "What once appeared to be a normal human fist, now holds a maulled nest of sharp bone-shards."
	icon = 'icons/effects/blood.dmi'
	base_icon_state = "bloodhand"
	color = "#001aff"
	item_flags = ABSTRACT | DROPDEL | HAND_ITEM
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	hitsound = "shatter"
	force = 16
	sharpness = SHARP_EDGED
	wound_bonus = -30
	bare_wound_bonus = 15

/obj/item/risen_hand/visual_equipped(mob/user, slot)
	. = ..()

	// Even hand indexes are right hands,
	// Odd hand indexes are left hand
	// ...But also, we swap it intentionally here,
	// so right icon is shown on the left (Because hands)
	if(user.get_held_index_of_item(src) % 2 == 1)
		icon_state = "[base_icon_state]_right"
	else
		icon_state = "[base_icon_state]_left"

/obj/item/risen_hand/pre_attack(atom/hit, mob/living/user, params)
	. = ..()
	if(.)
		return

	// If it's a structure or machine, we get a damage bonus (allowing us to break down doors)
	if(isstructure(hit) || ismachinery(hit))
		force *= 1.5

	// If it's another other item make sure we're at normal force
	else
		force = initial(force)

/datum/heretic_knowledge/rune_carver
	name = "Carving Knife"
	desc = "Allows you to transmute a knife, a shard of glass, and a piece of paper to create a Carving Knife. \
		The Carving Knife allows you to etch difficult to see traps that trigger on heathens who walk overhead. \
		Also makes for a handy throwing weapon."
	gain_text = "Etched, carved... eternal. There is power hidden in everything. I can unveil it! \
		I can carve the monolith to reveal the chains!"
	next_knowledge = list(
		/datum/heretic_knowledge/spell/void_phase,
		/datum/heretic_knowledge/duel_stance,
	)
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/shard = 1,
		/obj/item/paper = 1,
	)
	result_atoms = list(/obj/item/melee/rune_carver)
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/summon/maid_in_mirror
	name = "Maid in the Mirror"
	desc = ""
	gain_text = ""
	next_knowledge = list(
		/datum/heretic_knowledge/spell/void_pull,
		/datum/heretic_knowledge/spell/furious_steel,
	)
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/shard = 1,
		/obj/item/paper = 1,
	)
	cost = 1
	route = PATH_SIDE
