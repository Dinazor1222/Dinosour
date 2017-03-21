/datum/surgery/eye_surgery
	name = "eye surgery"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/fix_eyes, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list("eyes")
	requires_organic_bodypart = 0

//fix eyes
/datum/surgery_step/fix_eyes
	name = "fix eyes"
	implements = list(/obj/item/weapon/hemostat = 100, /obj/item/weapon/screwdriver = 45, /obj/item/weapon/pen = 25)
	time = 64

/datum/surgery/eye_surgery/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/eyes/E = target.getorganslot("eye_sight")
	if(!E)
		to_chat(user, "It's hard to do surgery on someones eyes when they don't have any.")
		return FALSE

/datum/surgery_step/fix_eyes/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[IDENTITY_SUBJECT(1)] begins to fix [IDENTITY_SUBJECT(2)]'s eyes.", "<span class='notice'>You begin to fix [IDENTITY_SUBJECT(2)]'s eyes...</span>", subjects=list(user, target))

/datum/surgery_step/fix_eyes/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[IDENTITY_SUBJECT(1)] successfully fixes [IDENTITY_SUBJECT(2)]'s eyes!", "<span class='notice'>You succeed in fixing [IDENTITY_SUBJECT(2)]'s eyes.</span>", subjects=list(user, target))
	target.cure_blind()
	target.set_blindness(0)
	target.cure_nearsighted()
	target.blur_eyes(35)	//this will fix itself slowly.
	target.set_eye_damage(0)
	return TRUE

/datum/surgery_step/fix_eyes/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.getorgan(/obj/item/organ/brain))
		user.visible_message("<span class='warning'>[IDENTITY_SUBJECT(1)] accidentally stabs [IDENTITY_SUBJECT(2)] right in the brain!</span>", "<span class='warning'>You accidentally stab [IDENTITY_SUBJECT(2)] right in the brain!</span>", subjects=list(user, target))
		target.adjustBrainLoss(100)
	else
		user.visible_message("<span class='warning'>[IDENTITY_SUBJECT(1)] accidentally stabs [IDENTITY_SUBJECT(2)] right in the brain! Or would have, if [IDENTITY_SUBJECT(2)] had a brain.</span>", "<span class='warning'>You accidentally stab [IDENTITY_SUBJECT(2)] right in the brain! Or would have, if [IDENTITY_SUBJECT(2)] had a brain.</span>", subjects=list(user, target))
	return FALSE