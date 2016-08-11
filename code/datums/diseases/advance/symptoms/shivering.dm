/*
//////////////////////////////////////

Shivering

	No change to hidden.
	Increases resistance.
	Increases stage speed.
	Little transmittable.
	Low level.

Bonus
	Cools down your body.

//////////////////////////////////////
*/

/datum/symptom/shivering

	name = "Shivering"
	stealth = 0
	resistance = 2
	stage_speed = 2
	transmittable = 2
	level = 2
	severity = 2

/datum/symptom/shivering/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		M << "<span class='warning'>[pick("You feel cold.", "You start shivering.")]</span>"
		if(M.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT)
			Chill(M, A)
	return

/datum/symptom/shivering/proc/Chill(mob/living/M, datum/disease/advance/A)
	var/get_cold = (sqrt(16+A.totalStealth()*2))+(sqrt(21+A.totalResistance()*2))
	M.bodytemperature = min(M.bodytemperature - (get_cold * A.stage), BODYTEMP_COLD_DAMAGE_LIMIT + 1)
	return 1


/*
//////////////////////////////////////

Mitochondrial Depolarization (aka Freezing)

	Noticeable.
	Decreases resistance.
	Heavily decreases stage speed.
	Little transmittable.
	Fatal level.

Bonus
	Freezes your body.

//////////////////////////////////////
*/

/datum/symptom/freezing

	name = "Mitochondrial Depolarization"
	stealth = -1
	resistance = -2
	stage_speed = -4
	transmittable = 1
	level = 7
	severity = 5

/datum/symptom/freezing/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		switch(A.stage)
			if(3)
				M << "<span class='warning'>[pick("You feel cold.", "You feel as if you can't warm up.", "You start shivering.")]</span>"
				M.emote("shiver")

			if(4,5)
				M << "<span class='userdanger'>[pick("Your skin starts freezing!", "You feel cold!", "You can't feel your limbs!")]</span>"
				M.emote("shiver")
				Freeze(M, A)
	return

/datum/symptom/freezing/proc/Freeze(mob/living/M, datum/disease/advance/A)
	var/get_cold = (sqrt(16+A.totalStealth()*2))+(sqrt(21+A.totalResistance()*2))
	M.bodytemperature = min(M.bodytemperature - (get_cold * A.stage), 40)
	return 1