/datum/disease/Tuberculosis
	name = "Fungal tuberculosis"
	max_stages = 4
	spread_text = "Airborne"
	cure_text = "Spaceacillin & salbutamol"
	cures = list("spaceacillin", "salbutamol")
	agent = "Fungal Tubercle bacillus Cosmosis"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 5//like hell are you getting out of hell
	desc = "A rare highly transmittable virulent virus. Few samples exist, rumoured to be carefully grown and cultured by clandestine bio-weapon specialists. Causes fever, blood vomiting, lung damage, weight loss, and fatigue."
	required_organs = list(/obj/item/organ/limb/head)
	severity = DANGEROUS

/datum/disease/Tuberculosis/stage_act() //it begins
	..()

	switch(stage)
		if(2)
			if(prob(2))
				affected_mob.emote("cough")
				affected_mob << "<span class='danger'>Your chest hurts.</span>"
			if(prob(2))
				affected_mob << "<span class='danger'>Your stomach violently rumbles!</span>"
			if(prob(2))
				affected_mob << "<span class='danger'>You feel a cavity in your lung forming.</span>"
				affected_mob.adjustOxyLoss(5)
				affected_mob.emote("gasp")
			if(prob(5))
				/datum/symptom/vomit/proc/Vomit(mob/living/carbon/M)
				affected_mob.vomit(20)
		if(3)
			if(prob(2))
				affected_mob << "<span class='userdanger'>You see four of everything</span>"
				affected_mob.Dizzy(5)
			if(prob(2))
				affected_mob << "<span class='danger'>You feel a cold sweat form.</span>"
			if(prob(10)
				affected_mob << "<span class='danger'>You feel air escape from your lungs painfully.</span>"
				affected_mob.adjustOxyLoss(25)
				affected_mob.emote("gasp")

		if(4)
			if(prob(2))
				affected_mob << "<span class='userdanger'>[pick("You feel your heart slowing...", "You slow your heartbeat.")]</span>"
				affected_mob.adjustStaminaLoss(40)
				if(affected_mob.getStaminaLoss() > 60 && !M.stat)
					affected_mob.visible_message("<span class='warning'>[M] faints!</span>", "<span class='userdanger'>You surrender yourself and feel at peace...</span>")
					affected_mob.sleeping += 5
			if(prob(2))
				affected_mob << "<span class='userdanger'>You feel your mind relax and your thoughts drift!</span>"
				affected_mob.confused = min(100, M.confused + 8)
			if(prob(15)
				/datum/symptom/vomit/blood/Vomit(mob/living/carbon/M)
				affected_mob.vomit(0, 1)
			if(prob(3))
				affected_mob << "<span class='warning'><i>[pick("Your stomach silently rumbles...", "Your stomach seizes up and falls limp, muscles dead and lifeless.", "You could eat a crayon")]</i></span>"
				affected_mob.overeatduration = max(affected_mob.overeatduration - 100, 0)
				affected_mob.nutrition = max(M.nutrition - 100, 0
			if(prob(15))
				affected_mob << "<span class='danger'>[pick("You feel uncomfortably hot...", "You feel like unzipping your jumpsuit", "You feel like taking off some clothes...")]</span>"
				affected_mob.bodytemperature += 40

	return
	
