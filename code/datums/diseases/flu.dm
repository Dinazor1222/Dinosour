/datum/disease/flu
	name = "The Flu"
	max_stages = 3
	spread_text = "Airborne"
	cure_text = "Spaceacillin"
	cures = list("spaceacillin")
	cure_chance = 10
	agent = "H13N1 flu virion"
	viable_mobtypes = list(/mob/living/carbon/human,/mob/living/carbon/monkey)
	permeability_mod = 0.75
	desc = "If left untreated the subject will feel quite unwell."
	severity = MEDIUM

/datum/disease/flu/stage_act()
	..()
	switch(stage)
		if(2)
			if(affected_mob.lying && new_prob(20))
				affected_mob << "<span class='notice'>You feel better.</span>"
				stage--
				return
			if(new_prob(1))
				affected_mob.emote("sneeze")
			if(new_prob(1))
				affected_mob.emote("cough")
			if(new_prob(1))
				affected_mob << "<span class='danger'>Your muscles ache.</span>"
				if(new_prob(20))
					affected_mob.take_organ_damage(1)
			if(new_prob(1))
				affected_mob << "<span class='danger'>Your stomach hurts.</span>"
				if(new_prob(20))
					affected_mob.adjustToxLoss(1)
					affected_mob.updatehealth()

		if(3)
			if(affected_mob.lying && new_prob(15))
				affected_mob << "<span class='notice'>You feel better.</span>"
				stage--
				return
			if(new_prob(1))
				affected_mob.emote("sneeze")
			if(new_prob(1))
				affected_mob.emote("cough")
			if(new_prob(1))
				affected_mob << "<span class='danger'>Your muscles ache.</span>"
				if(new_prob(20))
					affected_mob.take_organ_damage(1)
			if(new_prob(1))
				affected_mob << "<span class='danger'>Your stomach hurts.</span>"
				if(new_prob(20))
					affected_mob.adjustToxLoss(1)
					affected_mob.updatehealth()
	return
