/datum/action/cooldown/spell/aoe/repulse
	/// The max throw range of the repulsioon.
	var/max_throw = 5
	/// A visual effect to be spawned on people who are thrown away.
	var/obj/effect/sparkle_path = /obj/effect/temp_visual/gravpush
	/// The moveforce of the throw done by the repulsion.
	var/repulse_force = MOVE_FORCE_EXTREMELY_STRONG

/datum/action/cooldown/spell/aoe/repulse/is_affected_by_aoe(atom/thing)
	if(thing == owner)
		return FALSE

	if(!ismovable(thing))
		return FALSE

	var/atom/movable/movable_thing = thing
	return !movable_thing.anchored

/datum/action/cooldown/spell/aoe/repulse/get_things_to_cast_on(atom/center)
	return view(outer_radius, center)

/datum/action/cooldown/spell/aoe/repulse/cast_on_thing_in_aoe(atom/movable/victim, atom/caster)
	if(ismob(victim))
		var/mob/victim_mob = victim
		if(victim_mob.anti_magic_check())
			return

	var/turf/throwtarget = get_edge_target_turf(caster, get_dir(caster, get_step_away(victim, caster)))
	var/dist_from_caster = get_dist(victim, caster)

	if(dist_from_caster == 0)
		if(isliving(victim))
			var/mob/living/victim_living = victim
			victim_living.Paralyze(10 SECONDS)
			victim_living.adjustBruteLoss(5)
			to_chat(victim, span_userdanger("You're slammed into the floor by [caster]!"))
	else
		if(sparkle_path)
			// Created sparkles will disappear on their own
			new sparkle_path(get_turf(victim), get_dir(caster, victim))

		if(isliving(victim))
			var/mob/living/victim_living = victim
			victim_living.Paralyze(4 SECONDS)
			to_chat(victim, span_userdanger("You're thrown back by [caster]!"))

		// So stuff gets tossed around at the same time.
		victim.safe_throw_at(throwtarget, ((clamp((max_throw - (clamp(dist_from_caster - 2, 0, dist_from_caster))), 3, max_throw))), 1, caster, force = repulse_force)

/datum/action/cooldown/spell/aoe/repulse/wizard
	name = "Repulse"
	desc = "This spell throws everything around the user away."
	button_icon_state = "repulse"
	sound = 'sound/magic/repulse.ogg'

	school = SCHOOL_EVOCATION
	invocation = "GITTAH WEIGH"
	invocation_type = INVOCATION_SHOUT
	outer_radius = 5

	cooldown_time = 40 SECONDS
	cooldown_reduction_per_rank = 6.25 SECONDS

/datum/action/cooldown/spell/aoe/repulse/wizard/is_affected_by_aoe(atom/thing)
	. = ..()
	if(!.)
		return FALSE

	if(isliving(thing))
		var/mob/living/living_thing = thing
		if(living_thing.anti_magic_check())
			return FALSE

	return TRUE

/datum/action/cooldown/spell/aoe/repulse/xeno
	name = "Tail Sweep"
	desc = "Throw back attackers with a sweep of your tail."
	background_icon_state = "bg_alien"
	icon_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "tailsweep"
	panel = "Alien"
	sound = 'sound/magic/tail_swing.ogg'

	cooldown_time = 15 SECONDS

	invocation_type = INVOCATION_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	outer_radius = 2

	sparkle_path = /obj/effect/temp_visual/dir_setting/tailsweep

/datum/action/cooldown/spell/aoe/repulse/xeno/cast(atom/cast_on)
	if(iscarbon(cast_on))
		var/mob/living/carbon/carbon_caster = cast_on
		playsound(get_turf(carbon_caster), 'sound/voice/hiss5.ogg', 80, TRUE, TRUE)
		carbon_caster.spin(6, 1)

	return ..()
