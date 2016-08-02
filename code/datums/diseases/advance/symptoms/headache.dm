/*
//////////////////////////////////////

Headache

	Noticable.
	Highly resistant.
	Increases stage speed.
	Not transmittable.
	Low Level.
Old stats
	name = "Headache"
	stealth = -1
	resistance = 4
	stage_speed = 2
	transmittable = 0
	level = 1
	severity = 1
BONUS
	Displays an annoying message!
	Should be used for buffing your disease.

//////////////////////////////////////
*/

/datum/symptom/headache

	name = "Headache"
	stealth = 0
	resistance = 5
	stage_speed = 3
	transmittable = 1
	level = 1
	severity = 1

/datum/symptom/headache/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		M << "<span class='warning'>[pick("Your head hurts.", "Your head starts pounding.")]</span>"
	return
