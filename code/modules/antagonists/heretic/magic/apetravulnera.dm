/datum/action/cooldown/spell/pointed/apetra_vulnera
	name = "Apetra Vulnera"
	desc = "Causes severe bleeding on a limb of a target that has above 15 brute. If there are no such parts, applies a random wound."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "cleave"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 45 SECONDS

	invocation = "AP'TRA VULN'RA!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 4
	/// What type of wound we apply
	var/wound_type = /datum/wound/slash/flesh/critical/cleave

/datum/action/cooldown/spell/pointed/apetra_vulnera/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/apetra_vulnera/cast(mob/living/carbon/human/cast_on)
	. = ..()
	
	if(IS_HERETIC_OR_MONSTER(cast_on))
		return FALSE

	if(!cast_on.blood_volume)
		return FALSE

	if(cast_on.can_block_magic(antimagic_flags))
		cast_on.visible_message(
			span_danger("[cast_on]'s bruises , but repels the effect!"),
			span_danger("Your bruises sting a little, but you are protected!!")
		)
		return FALSE

	var/a_limb_got_damaged = FALSE
	for(var/obj/item/bodypart/bodypart in cast_on.bodyparts)
		if(bodypart.brute_dam < 15)
			continue
		a_limb_got_damaged = TRUE
		cast_on.visible_message(
			span_danger("[cast_on]'s [bodypart]'s scratches and bruises are torn open by an unholy force!"),
			span_danger("Your [bodypart]'s scratches and bruises are torn open by some horrible unholy force!")
		)
		var/datum/wound/slash/crit_wound = new wound_type()
		crit_wound.apply_wound(bodypart)
	
	if(!a_limb_got_damaged)
		var/datum/wound/slash/crit_wound = new wound_type()
		crit_wound.apply_wound(pick(cast_on.bodyparts))
	
	new /obj/effect/temp_visual/cleave(get_turf(cast_on))

	return TRUE
