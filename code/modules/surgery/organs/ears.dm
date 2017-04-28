/obj/item/organ/ears
	name = "ears"
	icon_state = "ears"
	desc = "There are three parts to the ear. Inner, middle and outer. Only one of these parts should be normally visible."
	zone = "head"
	slot = "ears"

	// `deaf` measures "ticks" of deafness. While > 0, the person is unable
	// to hear anything.
	var/deaf = 0

	// `ear_damage` measures long term damage to the ears, if too high,
	// the person will not have either `deaf` or `ear_damage` decrease
	// without external aid (earmuffs, drugs)
	var/ear_damage = 0

/obj/item/organ/ears/on_life()
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/C = owner
	// genetic deafness prevents the body from using the ears, even if healthy
	if(C.disabilities & DEAF)
		deaf = max(deaf, 1)
	else
		if(C.ears && HAS_SECONDARY_FLAG(C.ears, HEALS_EARS))
			deaf = max(deaf - 1, 1)
			ear_damage = max(ear_damage - 0.10, 0)
		// if higher than UNHEALING_EAR_DAMAGE, no natural healing occurs.
		if(ear_damage < UNHEALING_EAR_DAMAGE)
			ear_damage = max(ear_damage - 0.05, 0)
			deaf = max(deaf - 1, 0)

/obj/item/organ/ears/proc/restoreEars()
	deaf = 0
	ear_damage = 0

	var/mob/living/carbon/C = owner

	if(iscarbon(owner) && C.disabilities & DEAF)
		deaf = 1

/obj/item/organ/ears/proc/adjustEarDamage(ddmg, ddeaf)
	ear_damage = max(ear_damage + ddmg, 0)
	deaf = max(deaf + ddeaf, 0)

/obj/item/organ/ears/proc/minimumDeafTicks(value)
	deaf = max(deaf, value)


/mob/proc/restoreEars()

/mob/living/carbon/restoreEars()
	var/obj/item/organ/ears/ears = getorgan(/obj/item/organ/ears)
	if(ears)
		ears.restoreEars()

/mob/proc/adjustEarDamage()

/mob/living/carbon/adjustEarDamage(ddmg, ddeaf)
	var/obj/item/organ/ears/ears = getorgan(/obj/item/organ/ears)
	if(ears)
		ears.adjustEarDamage(ddmg, ddeaf)

/mob/proc/minimumDeafTicks()

/mob/living/carbon/minimumDeafTicks(value)
	var/obj/item/organ/ears/ears = getorgan(/obj/item/organ/ears)
	if(ears)
		ears.minimumDeafTicks(value)
