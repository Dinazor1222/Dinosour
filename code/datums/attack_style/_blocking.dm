/**
 * # Blocking
 *
 * Blocking incoming attacks, converting it to stamina damage.
 */
/datum/status_effect/blocking
	id = "blocking"
	alert_type = /atom/movable/screen/alert/status_effect/blocking
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = 1 SECONDS
	duration = -1

	var/obj/item/blocking_with
	var/obj/effect/blocking_effect/shield_overlay

/datum/status_effect/blocking/nextmove_modifier()
	// Next move CD is 2x as long while blocking.
	// You are unable to attack while blocking but this handles stuff like
	// interfacing with your backpack or other actions.
	return 2

/datum/status_effect/blocking/on_creation(mob/living/new_owner, obj/item/new_blocker)
	. = ..()
	if(!.)
		return
	if(!isnull(new_blocker))
		set_blocking_item(new_blocker)

	var/static/shield_offset_const = (0.8 * world.icon_size)
	shield_overlay = new(new_owner)
	shield_overlay.pixel_y += shield_offset_const // melbert todo: hides under mobs
	owner.vis_contents += shield_overlay
	update_shield()

/datum/status_effect/blocking/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(on_attacked))
	RegisterSignals(owner, list(COMSIG_MOB_APPLY_DAMAGE, COMSIG_LIVING_HEALTH_UPDATE), PROC_REF(on_health_update))
	owner.add_movespeed_modifier(/datum/movespeed_modifier/blocking)
	owner.add_actionspeed_modifier(/datum/actionspeed_modifier/blocking)
	ADD_TRAIT(owner, TRAIT_CANNOT_HEAL_STAMINA, id)
	return TRUE

/datum/status_effect/blocking/refresh(effect, obj/item/new_blocker)
	if(isnull(new_blocker))
		if(!isnull(blocking_with))
			clear_blocking_item()
	else
		set_blocking_item(new_blocker)

/datum/status_effect/blocking/on_remove()
	owner.vis_contents -= shield_overlay
	QDEL_NULL(shield_overlay)
	UnregisterSignal(owner, list(
		COMSIG_LIVING_CHECK_BLOCK,
		COMSIG_LIVING_HEALTH_UPDATE,
		COMSIG_MOB_APPLY_DAMAGE,
	))
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/blocking)
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/blocking)
	REMOVE_TRAIT(owner, TRAIT_CANNOT_HEAL_STAMINA, id)

/datum/status_effect/blocking/Destroy()
	if(blocking_with)
		clear_blocking_item()
	return ..()

/datum/status_effect/blocking/tick(seconds_per_tick, times_fired)
	if(iscarbon(owner))
		// every tick we will set the mob's stamina regen start time the next time this status effect will tick
		// this is so blocking prevents all stamina regen while active
		// (though we use a max to prevent memes like 1-tick blocking to reset stamina regen period)
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.stam_regen_start_time = max(carbon_owner.stam_regen_start_time, tick_interval)

	update_shield()

/datum/status_effect/blocking/proc/update_shield()
	if(QDELING(src))
		return

	var/percent = round(100 - ((owner.getStaminaLoss() / owner.maxHealth) * 100), 10)
	var/new_icon_state = "shield[percent]"
	if(percent <= 0)
		owner.visible_message(span_danger("[owner]'s guard is broken!"), span_userdanger("Your guard is broken!"))
		qdel(src)

	else if(shield_overlay.icon_state != new_icon_state)
		shield_overlay.icon_state = "shield[percent]"

/datum/status_effect/blocking/proc/set_blocking_item(obj/item/new_blocker)
	blocking_with = new_blocker
	RegisterSignals(blocking_with, list(COMSIG_PARENT_QDELETING, COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED), PROC_REF(stop_blocking))
	linked_alert.update_appearance(UPDATE_DESC)

/datum/status_effect/blocking/proc/clear_blocking_item()
	UnregisterSignal(blocking_with, list(
		COMSIG_PARENT_QDELETING,
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_EQUIPPED,
	))

	blocking_with = null
	if(!QDELETED(linked_alert))
		linked_alert.update_appearance(UPDATE_DESC)

/datum/status_effect/blocking/proc/stop_blocking(obj/item/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/status_effect/blocking/proc/on_attacked(mob/living/source, atom/movable/hitby, damage, attack_text, attack_type, armour_penetration, damage_type)
	SIGNAL_HANDLER

	if(blocking_with)
		if(!(blocking_with.can_block_flags & attack_type))
			return NONE

	else if(!(BLOCK_ALL_MELEE & attack_type))
		return NONE

	// Depending on the item (or lack thereof) you are blocking with, the damage taken is converted to more (or maybe less!) stamina damage
	var/mob/living/attacker = GET_ASSAILANT(hitby)
	var/defense_multiplier = blocking_with ? blocking_with.get_blocking_ability(source, hitby, damage, attack_type, damage_type) : BARE_HAND_DEFENSE_MULTIPLIER
	if(defense_multiplier < 0)
		return NONE
	var/final_damage = defense_multiplier * damage
	if(attacker && HAS_TRAIT(attacker, TRAIT_HULK))
		final_damage *= 1.2 // Hulk attacks are harder to stop
	if(final_damage > 0)
		source.apply_damage(final_damage, STAMINA, spread_damage = TRUE)

	// Stamcrit = failed
	if(source.incapacitated())
		return NONE

	// Stops all following effects of the attack.
	if(blocking_with && !blocking_with.on_successful_block(source, hitby, damage, attack_text, attack_type, damage_type))
		source.visible_message(
			span_danger("[source] blocks [attack_text][blocking_with ? " with [blocking_with]" : ""]!"),
			span_danger("You block [attack_text][blocking_with ? " with [blocking_with]" : ""]!"),
		)
	source.add_movespeed_modifier(/datum/movespeed_modifier/successful_block)
	addtimer(CALLBACK(source, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/successful_block), 0.5 SECONDS)
	if(!QDELETED(src))
		animate(shield_overlay, time = 0.15 SECONDS, pixel_x = 2, easing = BACK_EASING|EASE_OUT)
		animate(time = 0.20 SECONDS, pixel_x = -2, easing = BACK_EASING|EASE_OUT)
		animate(time = 0.15 SECONDS, pixel_x = 0, easing = BACK_EASING|EASE_OUT)

	return SUCCESSFUL_BLOCK

/datum/status_effect/blocking/proc/on_health_update(mob/living/source)
	SIGNAL_HANDLER

	update_shield()

/atom/movable/screen/alert/status_effect/blocking
	name = "Blocking"
	desc = "You're blocking incoming attacks.\
		This will prevent you from taking physical damage, but drain your stamina.\
		You also won't regenerate stamina while blocking."
	icon = 'icons/effects/blocking.dmi'
	icon_state = "block_alert"

/atom/movable/screen/alert/status_effect/blocking/update_desc(updates)
	. = ..()
	desc = initial(desc)
	var/datum/status_effect/blocking/blocking_effect = attached_effect
	ASSERT(istype(blocking_effect))
	if(blocking_effect.blocking_with)
		desc += " You are blocking with [blocking_effect.blocking_with], \
			which has an effectiveness of [blocking_effect.blocking_with.blocking_ability]."
	else
		desc += " You are blocking with your bare hands, \
			which has an effectiveness of [BARE_HAND_DEFENSE_MULTIPLIER]."

/obj/effect/blocking_effect
	icon = 'icons/effects/blocking.dmi'
	icon_state = "shield100"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/blocking_effect/Initialize(mapload)
	. = ..()
	color = loc.chat_color || LIGHT_COLOR_BLUE
	alpha = min(loc.alpha, 200)
	layer = loc.layer + 0.1

/datum/movespeed_modifier/blocking
	multiplicative_slowdown = 0.5

/datum/movespeed_modifier/successful_block
	multiplicative_slowdown = 0.25

/datum/actionspeed_modifier/blocking
	multiplicative_slowdown = 1
