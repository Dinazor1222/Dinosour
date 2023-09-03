/datum/action/cooldown/spell/pointed/moon_smile
	name = "Smile of the moon"
	desc = "Lets you turn the gaze of the moon on someone \
			temporarily blinding, muting, deafening and confusing a single target."
	button_icon_state = "blind"
	ranged_mousepointer = 'icons/effects/mouse_pointers/blind_target.dmi'

	sound = 'sound/magic/blind.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "S`M`L`E M`O"
	invocation_type = INVOCATION_SHOUT
	garbled_invocation_prob = 0
	spell_requirements = NONE

	active_msg = "You prepare to let them see the true face..."

/datum/action/cooldown/spell/pointed/moon_smile/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/moon_smile/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("The moon turns, its smile no longer set on you."))
		to_chat(owner, span_warning("The moon does not smile upon them."))
		return FALSE

	to_chat(cast_on, span_warning("Your eyes cry out in pain, your ears bleed and your lips seal! THE MOON SMILES UPON YOU"))
	cast_on.adjust_temp_blindness(5 SECONDS)
	cast_on.set_eye_blur_if_lower(10 SECONDS)
	var/obj/item/organ/internal/ears/ears = cast_on.get_organ_slot(ORGAN_SLOT_EARS)
	ears?.adjustEarDamage(0,5)
	cast_on.adjust_silence(5 SECONDS)
	cast_on.adjust_confusion(10 SECONDS)
	return TRUE
