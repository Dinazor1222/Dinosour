/**
 * Avoids players while throwing skulls at them.
 * Legion skulls heal allies, bite enemies, and infest dying humans to make more legions.
 */
/mob/living/basic/mining/legion
	name = "legion"
	desc = "You can still see what was once a human under the shifting mass of corruption."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "legion"
	icon_living = "legion"
	icon_dead = "legion"
	icon_gib = "syndicate_gib"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	basic_mob_flags = DEL_ON_DEATH
	speed = 4
	obj_damage = 60
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_verb_continuous = "lashes out at"
	attack_verb_simple = "lash out at"
	speak_emote = list("echoes")
	attack_sound = 'sound/weapons/pierce.ogg'
	throw_blocked_message = "bounces harmlessly off of"
	crusher_loot = /obj/item/crusher_trophy/legion_skull
	death_message = "wails in chorus and dissolves into quivering flesh."
	/// What kind of mob do we spawn?
	var/brood_type = /mob/living/basic/legion_brood
	/// What kind of corpse spawner do we leave behind on death?
	var/corpse_type
	/// Who is inside of us?
	var/mob/living/stored_mob
	/// What we drop when we die

/mob/living/basic/mining/legion/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/death_drops, get_loot_list())
	AddElement(/datum/element/content_barfer)

/// Create what we want to drop on death, in proc form so we can always return a static list
/mob/living/basic/mining/legion/proc/get_loot_list()
	var/static/list/death_loot = list(/obj/item/organ/internal/monster_core/regenerative_core/legion)
	return death_loot

/mob/living/basic/mining/legion/Exited(atom/movable/gone, direction)
	. = ..()
	if (gone != stored_mob)
		return
	ai_controller.clear_blackboard_key(BB_LEGION_CORPSE)
	stored_mob.remove_status_effect(/datum/status_effect/grouped/stasis, STASIS_LEGION_EATEN)
	stored_mob.add_mood_event("regenerative core", /datum/mood_event/healsbadman/long_term) // This will still probably mostly be gone before you are alive
	stored_mob = null

/mob/living/basic/mining/legion/death(gibbed)
	if (isnull(stored_mob))
		new corpse_type(loc)
	return ..()

/// Put a corpse in this guy
/mob/living/basic/mining/legion/proc/consume(mob/living/consumed)
	gender = consumed.gender
	real_name = consumed.real_name
	visible_message(span_warning("[name] staggers to [p_their()] feet!"))
	consumed.investigate_log("has been killed by hivelord infestation.", INVESTIGATE_DEATHS)
	consumed.death()
	consumed.extinguish_mob()
	consumed.fully_heal(HEAL_DAMAGE)
	consumed.apply_status_effect(/datum/status_effect/grouped/stasis, STASIS_LEGION_EATEN)
	consumed.forceMove(src)
	ai_controller.set_blackboard_key(BB_LEGION_CORPSE, consumed)
	stored_mob = consumed

/// A Legion which only drops skeletons instead of corpses which might have fun loot, so it cannot be farmed
/mob/living/basic/mining/legion/spawner_made
	corpse_type = /obj/effect/mob_spawn/corpse/human/charredskeleton


/// Like a Legion but it's an adorable snowman
/mob/living/basic/mining/legion/snow
	name = "snow legion"
	desc = "You can vaguely see what was once a human under the densely packed snow. Cute, but macabre."
	icon = 'icons/mob/simple/icemoon/icemoon_monsters.dmi'
	icon_state = "snowlegion"
	icon_living = "snowlegion"
	// icon_aggro = "snowlegion_alive"
	icon_dead = "snowlegion"
	brood_type = /mob/living/basic/legion_brood/snow
	corpse_type = /obj/effect/mob_spawn/corpse/human/snowlegioninfested

/mob/living/basic/mining/legion/snow/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/appearance_on_aggro, aggro_state = "snowlegion_alive") // Surprise! I was real!

/// As Snow Legion but spawns corpses which don't have any exciting loot
/mob/living/basic/mining/legion/snow/spawner_made
	corpse_type = /obj/effect/mob_spawn/corpse/human/skeleton


/// Like a Legion but shorter and faster
/mob/living/basic/mining/legion/dwarf
	name = "dwarf legion"
	desc = "You can still see what was once a rather small human under the shifting mass of corruption."
	icon_state = "dwarf_legion"
	icon_living = "dwarf_legion"
	icon_dead = "dwarf_legion"
	maxHealth = 60
	health = 60
	speed = 2
	crusher_drop_chance = 20
	corpse_type = /obj/effect/mob_spawn/corpse/human/legioninfested/dwarf


/// Like a Legion but larger and spawns regular Legions, not currently used anywhere and very soulful
/mob/living/basic/mining/legion/large
	name = "myriad"
	desc = "A legion of legions, a dead end to whatever form the Necropolis was attempting to create."
	icon_state = "legion"
	icon_living = "legion"
	icon_dead = "legion"
	health_doll_icon = "legion"
	speed = 5
	health = 450
	maxHealth = 450
	melee_damage_lower = 20
	melee_damage_upper = 20
	obj_damage = 30
	sentience_type = SENTIENCE_BOSS
	corpse_type = /obj/effect/mob_spawn/corpse/human/legioninfested

/mob/living/basic/mining/legion/large/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/spawner,\
		spawn_types = list(/mob/living/basic/mining/legion),\
		spawn_time = 20 SECONDS,\
		max_spawned = 3,\
		spawn_text = "peels itself off from",\
		faction = faction,\
	)

/// Create what we want to drop on death, in proc form so we can always return a static list
/mob/living/basic/mining/legion/large/get_loot_list()
	var/static/list/death_loot = list(/obj/item/organ/internal/monster_core/regenerative_core/legion = 3, /obj/effect/mob_spawn/corpse/human/legioninfested = 4)
	return death_loot
