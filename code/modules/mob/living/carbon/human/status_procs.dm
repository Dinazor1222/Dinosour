
/mob/living/carbon/human/Paralyse(amount, updating = 1, ignore_canparalyse = 0)
	amount = dna.species.spec_paralyse(src,amount)
	return ..()

/mob/living/carbon/human/Knockdown(amount, updating = 1, ignore_canparalyse = 0)
	amount = dna.species.spec_paralyse(src,amount)
	return ..()

/mob/living/carbon/human/Unconscious(amount, updating = 1, ignore_canparalyse = 0)
	amount = dna.species.spec_paralyse(src,amount)
	return ..()

/mob/living/carbon/human/cure_husk()
	. = ..()
	if(.)
		update_hair()

/mob/living/carbon/human/become_husk()
	if(istype(dna.species, /datum/species/skeleton)) //skeletons shouldn't be husks.
		cure_husk()
		return
	. = ..()
	if(.)
		update_hair()

/mob/living/carbon/human/set_drugginess(amount)
	..()
	if(!amount)
		remove_language(/datum/language/beachbum)

/mob/living/carbon/human/adjust_drugginess(amount)
	..()
	if(!dna.check_mutation(STONER))
		if(druggy)
			grant_language(/datum/language/beachbum)
		else
			remove_language(/datum/language/beachbum)
