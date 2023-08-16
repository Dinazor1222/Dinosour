#define REGALRAT_INTERACTION "regalrat"

/// The cheesiest, most crowned rat of them all. Regent superior of all rats in maintenance... at least until someone else tries to encroach on their claim.
/mob/living/basic/regal_rat
	name = "feral regal rat"
	desc = "An evolved rat, created through some strange science. They lead nearby rats with deadly efficiency to protect their kingdom."
	icon_state = "regalrat"
	icon_living = "regalrat"
	icon_dead = "regalrat_dead"

	maxHealth = 70
	health = 70

	butcher_results = list(/obj/item/food/meat/slab/mouse = 2, /obj/item/clothing/head/costume/crown = 1)

	response_help_continuous = "glares at"
	response_help_simple = "glare at"
	response_disarm_continuous = "skoffs at"
	response_disarm_simple = "skoff at"
	response_harm_continuous = "slashes"
	response_harm_simple = "slash"

	obj_damage = 10
	melee_damage_lower = 13
	melee_damage_upper = 15
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/bladeslice.ogg'

	// Slightly brown red, for the eyes
	// Might be a bit too dim
	lighting_cutoff_red = 22
	lighting_cutoff_green = 8
	lighting_cutoff_blue = 5

	attack_vis_effect = ATTACK_EFFECT_CLAW
	unique_name = TRUE
	faction = list(FACTION_RAT, FACTION_MAINT_CREATURES)

	ai_controller = /datum/ai_controller/basic_controller/regal_rat

	///Should we request a mind immediately upon spawning?
	var/poll_ghosts = FALSE

/mob/living/basic/regal_rat/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(pre_attack))

	AddElement(/datum/element/waddling)
	AddElement(/datum/element/ai_retaliate)
	AddComponent(\
		/datum/component/ghost_direct_control,\
		poll_candidates = poll_ghosts,\
		role_name = "the Regal Rat, cheesy be their crown",\
		poll_ignore_key = POLL_IGNORE_REGAL_RAT,\
		assumed_control_message = "You are an independent, invasive force on the station! Hoard coins, trash, cheese, and the like from the safety of darkness!",\
		after_assumed_control = CALLBACK(src, PROC_REF(became_player_controlled)),\
	)

	var/datum/action/cooldown/mob_cooldown/domain/domain = new(src)
	domain.Grant(src)
	ai_controller.set_blackboard_key(BB_DOMAIN_ABILITY, domain)

	var/datum/action/cooldown/mob_cooldown/riot/riot = new(src)
	riot.Grant(src)
	ai_controller.set_blackboard_key(BB_RAISE_HORDE_ABILITY, riot)

/mob/living/basic/regal_rat/examine(mob/user)
	. = ..()
	if(user == src)
		return

	if(isregalrat(user))
		. += span_warning("Who is this foolish false king? This will not stand!")
		return

	if(ismouse(user))
		if(user.faction_check_mob(src, TRUE))
			. += span_notice("This is your king. Long live [p_their()] majesty!")
		else
			. += span_warning("This is a false king! Strike [p_them()] down!")

/mob/living/basic/regal_rat/handle_environment(datum/gas_mixture/environment)
	. = ..()
	if(stat == DEAD || isnull(environment) || isnull(environment.gases[/datum/gas/miasma]))
		return
	var/miasma_percentage = environment.gases[/datum/gas/miasma][MOLES] / environment.total_moles()
	if(miasma_percentage >= 0.25)
		heal_bodypart_damage(1)

/// Triggers an alert to all ghosts that the rat has become player controlled.
/mob/living/basic/regal_rat/proc/became_player_controlled()
	notify_ghosts(
		"All rise for the rat king, ascendant to the throne in \the [get_area(src)].",
		source = src,
		action = NOTIFY_ORBIT,
		flashwindow = FALSE,
		header = "Sentient Rat Created",
	)

/// Checks if we are able to attack this object, as well as send out the signal to see if we get any special regal rat interactions.
/mob/living/basic/regal_rat/proc/pre_attack(mob/living/source, atom/target)
	SIGNAL_HANDLER

	if(DOING_INTERACTION(src, REGALRAT_INTERACTION) || !allowed_to_attack(target))
		return COMPONENT_HOSTILE_NO_ATTACK

	if(SEND_SIGNAL(target, COMSIG_RAT_INTERACT, src) & COMPONENT_RAT_INTERACTED)
		return COMPONENT_HOSTILE_NO_ATTACK

	if(isnull(mind))
		return

	if(istype(target, /obj/machinery/door/airlock))
		INVOKE_ASYNC(src, PROC_REF(pry_door), target)
		return COMPONENT_HOSTILE_NO_ATTACK

	if(!combat_mode)
		INVOKE_ASYNC(src, PROC_REF(poison_target), target)
		return COMPONENT_HOSTILE_NO_ATTACK

/// Checks if we are allowed to attack this mob. Will return TRUE if we are potentially allowed to attack, but if we end up in a case where we should NOT attack, return FALSE.
/mob/living/basic/regal_rat/proc/allowed_to_attack(atom/the_target)
	if(QDELETED(the_target))
		return FALSE //wat

	if(!isliving(the_target))
		return TRUE // it might be possible to attack this? we'll find out soon enough

	var/mob/living/living_target = the_target
	if (living_target.stat == DEAD)
		balloon_alert(src, "already dead!")
		return FALSE

	if(living_target.faction_check_mob(src, exact_match = TRUE))
		balloon_alert(src, "one of your soldiers!")
		return FALSE

/// Attempts to add rat spit to a target, effectively poisoning it to whoever eats it. Yuckers.
/mob/living/basic/regal_rat/proc/poison_target(atom/target)
	if(isnull(target.reagents) || !target.is_injectable(src, allowmobs = TRUE))
		return

	visible_message(
		span_warning("[src] starts licking [target] passionately!"),
		span_notice("You start licking [target]..."),
		span_warning("You hear a disgusting slurping sound...")
	)

	if (!do_after(src, 2 SECONDS, target, interaction_key = REGALRAT_INTERACTION))
		return

	target.reagents.add_reagent(/datum/reagent/rat_spit, rand(1,3), no_react = TRUE)
	balloon_alert(src, "licked")

/**
 * Conditionally "eat" cheese object and heal, if injured.
 *
 * A private proc for sending a message to the mob's chat about them
 * eating some sort of cheese, then healing them, then deleting the cheese.
 * The "eating" is only conditional on the mob being injured in the first
 * place.
 */
/mob/living/basic/regal_rat/proc/cheese_heal(obj/item/target, amount, message)
	if(health >= maxHealth)
		balloon_alert(src, "you feel full!")
		return

	to_chat(src, message)
	heal_bodypart_damage(amount)
	qdel(target)

/**
 * Allows rat king to pry open an airlock if it isn't locked.
 *
 * A proc used for letting the rat king pry open airlocks instead of just attacking them.
 * This allows the rat king to traverse the station when there is a lack of vents or
 * accessible doors, something which is common in certain rat king spawn points.
 *
 * Returns TRUE if the door opens, FALSE otherwise.
 */
/mob/living/basic/regal_rat/proc/pry_door(target)
	if(DOING_INTERACTION(src, REGALRAT_INTERACTION))
		return FALSE

	var/obj/machinery/door/airlock/prying_door = target
	if(!prying_door.density || prying_door.locked || prying_door.welded || prying_door.seal)
		return FALSE

	visible_message(
		span_warning("[src] begins prying open the airlock..."),
		span_notice("You begin digging your claws into the airlock..."),
		span_warning("You hear groaning metal..."),
	)
	var/time_to_open = 0.5 SECONDS

	if(prying_door.hasPower())
		time_to_open = 5 SECONDS
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, vary = TRUE)

	if(!do_after(src, time_to_open, prying_door, interaction_key = REGALRAT_INTERACTION))
		return FALSE

	if(!prying_door.open(BYPASS_DOOR_CHECKS))
		balloon_alert(src, "failed to open!")
		return FALSE

	return TRUE

/mob/living/basic/regal_rat/controlled
	poll_ghosts = TRUE
	/// The prefix to our name, the domain of which we are inherited.
	var/static/list/kingdoms = list(
		"Cheese",
		"Garbage",
		"Maintenance",
		"Miasma",
		"Plague",
		"Rat",
		"Trash",
		"Vermin",
	)
	/// The suffix to our name, the title of which we are entitled to.
	var/static/list/titles = list(
		"Bojar",
		"Emperor",
		"King",
		"Lord",
		"Master",
		"Overlord",
		"Prince",
		"Shogun",
		"Supreme",
		"Tsar",
	)

/mob/living/basic/regal_rat/controlled/Initialize(mapload)
	. = ..()
	name = "[pick(kingdoms)] [pick(titles)]"

#undef REGALRAT_INTERACTION
