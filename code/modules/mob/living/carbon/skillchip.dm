/**
  * Attempts to implant this skillchip into the target carbon's brain.
  *
  * Returns whether the skillchip was inserted or not. Can optionally give chat message notification to the mob.
  * Arguments:
  * * skillchip - The skillchip you want to insert.
  * * silent - Whether or not to display the implanting message.
  * * force - Whether to force the implant to happen. Skips checking if the chip can actually be implanted. Used by changelings.
  */
/mob/living/carbon/proc/implant_skillchip(obj/item/skillchip/skillchip, silent = FALSE, force = FALSE)
	// Grab the brain.
	var/obj/item/organ/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)

	// Check for the brain. No brain = no implant.
	if(QDELETED(brain))
		return FALSE

	// Check the chip can actually be implanted.
	if(!force && skillchip.has_mob_incompatibility(src))
		return FALSE

	// Implant and call on_apply proc if successful.
	if(brain.implant_skillchip(skillchip))
		skillchip.on_apply(src, silent)
		skillchip.forceMove(brain)
		return TRUE

	return FALSE

/**
  * Attempts to remove this skillchip from the target carbon's brain.
  *
  * Returns FALSE when the skillchip couldn't be removed for some reason,
  * including the target or brain not existing or the skillchip not being in the brain.
  * Arguments:
  * * target - The living carbon whose brain you want to remove the chip from.
  * * silent - Whether or not to display the removal message.
  */
/mob/living/carbon/proc/remove_skillchip(obj/item/skillchip/skillchip, silent = FALSE)
	// Check the target's brain, making sure the target exists and has a brain.
	var/obj/item/organ/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)
	if(QDELETED(brain))
		return FALSE

	// Remove and call on_removal proc
	if(!brain.remove_skillchip(skillchip))
		stack_trace("Failed to remove skillchip [skillchip] from [src].")
		return FALSE

	skillchip.on_removal(src, silent)
	return TRUE

/**
  * Creates a list of type paths of skillchips in the mob's brain.
  *
  * Returns a simple list of typepaths.
  */
/mob/living/carbon/proc/get_skillchip_type_list()
	// Check the target's brain, making sure the target exists and has a brain.
	var/obj/item/organ/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)
	if(QDELETED(brain))
		return list()

	return brain.get_skillchip_type_list()

/**
  * Destroys all skillchips in the brain, calling on_removal if the brain has an owner mob.
  */
/mob/living/carbon/proc/destroy_all_skillchips(silent = FALSE)
	// Check the target's brain, making sure the target exists and has a brain.
	var/obj/item/organ/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)

	if(QDELETED(brain))
		return FALSE

	brain.destroy_all_skillchips(silent)

	return TRUE
