/*TODO:
	PTSD
*/
/datum/brain_trauma/psychological
	var/cure_points = 1000
	var/current_points = 0
	var/fearless_mod = 1
	var/lithiated_mod = 1
	var/relaxed_mod = 1
	var/control_mod = 1

/datum/brain_trauma/psychological/on_life()
	if(HAS_TRAIT(owner, TRAIT_FEARLESS))
		current_points += fearless_mod
	if(HAS_TRAIT(owner, TRAIT_LITHIATED))
		current_points += lithiated_mod
	if(HAS_TRAIT(owner, TRAIT_RELAXED))
		current_points += relaxed_mod
	if(HAS_TRAIT(owner, TRAIT_UNDER_CONTROL))
		current_points += control_mod
	if(current_points >= cure_points)
		SEND_SIGNAL(src, COMSIG_CURE_MENTAL, src)


/datum/brain_trauma/psychological/depression
	name = "Depression"
	desc = "Extensive damage to receptors in brain result in subject's near constant bad mood."
	scan_desc = "Electric imaging suggests a mental disorder is present"
	gain_text = "<span class='warning'>You feel empty inside!</span>"
	lose_text = "<span class='notice'>You feel whole once again.</span>"
	cure_points = 1500
	lithiated_mod = -2
	control_mod = -1
	fearless_mod = 4
	relaxed_mod = 3

/datum/brain_trauma/psychological/depression/on_gain()
	ADD_TRAIT(owner, TRAIT_DEPRESSION, PSYCH_TRAIT)
	..()

/datum/brain_trauma/psychological/depression/on_lose()
	REMOVE_TRAIT(owner, TRAIT_DEPRESSION, PSYCH_TRAIT)
	..()

/datum/brain_trauma/psychological/depression/on_life()
	..()
	if(HAS_TRAIT(owner, TRAIT_FEARLESS))
		return
	if(prob(5)) //this is much much worse then before!
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "depression", /datum/mood_event/depression)


/datum/brain_trauma/psychological/social_anxiety
	name = "Social Anxiety"
	desc = "Talking to people is very difficult for the subject ,often stuttering or even locking up."
	gain_text = "<span class='danger'>You start worrying about what you're saying.</span>"
	lose_text = "<span class='notice'>You feel easier about talking again.</span>" //if only it were that easy!
	scan_desc = "Electric imaging suggests a mental disorder is present"
	var/dumb_thing = TRUE
	cure_points = 500
	lithiated_mod = -2
	control_mod = 2
	fearless_mod = 1
	relaxed_mod = 4

/datum/brain_trauma/psychological/social_anxiety/on_life()
	..()
	if(HAS_TRAIT(owner, TRAIT_FEARLESS))
		return
	var/nearby_people = 0
	for(var/mob/living/carbon/human/H in oview(3, owner))
		if(H.client)
			nearby_people++
	var/mob/living/carbon/human/H = owner
	if(prob(2 + nearby_people))
		H.stuttering = max(3, H.stuttering)
	else if(prob(min(3, nearby_people)) && !H.silent)
		to_chat(H, "<span class='danger'>You retreat into yourself. You <i>really</i> don't feel up to talking.</span>")
		H.silent = max(10, H.silent)
	else if(prob(0.5) && dumb_thing)
		to_chat(H, "<span class='userdanger'>You think of a dumb thing you said a long time ago and scream internally.</span>")
		dumb_thing = FALSE //only once per life
		if(prob(1))
			new/obj/item/reagent_containers/food/snacks/spaghetti/pastatomato(get_turf(H)) //now that's what I call spaghetti code


/datum/brain_trauma/psychological/social_anxiety/on_gain()
	ADD_TRAIT(owner, TRAIT_SOCIAL_ANXIETY, PSYCH_TRAIT)
	..()

/datum/brain_trauma/psychological/social_anxiety/on_lose()
	REMOVE_TRAIT(owner, TRAIT_SOCIAL_ANXIETY, PSYCH_TRAIT)
	..()

/datum/brain_trauma/psychological/bipolar
	name = "Bipolar Disorder"
	desc = "Subject experiences alternating mood swings"
	gain_text = "<span class='danger'>You feel as on a moodswing.</span>"
	lose_text = "<span class='notice'>You feel peace</span>" //if only it were that easy!
	scan_desc = "Electric imaging suggests a mental disorder is present"
	cure_points = 750
	lithiated_mod = 2
	control_mod = 4
	fearless_mod = -2
	relaxed_mod = -5
	var/mood_swing_state = FALSE

/datum/brain_trauma/psychological/bipolar/proc/change_mood_swing()
	mood_swing_state = !mood_swing_state
	if(mood_swing_state)
		to_chat(owner, "<span class='danger'>Your heart begins to race. You are overfilled with joy!.</span>")
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "bipolar", /datum/mood_event/mood_swing_up)
	else
		to_chat(owner, "<span class='danger'>You feel the stress catching up to you. Sadness fills your heart!</span>")
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "bipolar", /datum/mood_event/mood_swing_down)
	addtimer(CALLBACK(src, .proc/change_mood_swing), 2 MINUTES)

/datum/brain_trauma/psychological/bipolar/on_gain()
	change_mood_swing()
	ADD_TRAIT(owner, TRAIT_BIPOLAR, PSYCH_TRAIT)
	..()

/datum/brain_trauma/psychological/bipolar/on_lose()
	REMOVE_TRAIT(owner, TRAIT_BIPOLAR, PSYCH_TRAIT)
	..()

/datum/brain_trauma/psychological/paranoid
	name = "Paranoid schizophrenia"
	desc = "Mental disorder that is characterized by auditory and visual hallucinations"
	gain_text = "<span class='danger'>You hear whispers behind you.</span>"
	lose_text = "<span class='notice'>Voices stop responding.</span>"
	scan_desc = "Electric imaging suggests a mental disorder is present"
	cure_points = 1300
	lithiated_mod = 5
	control_mod = 3
	fearless_mod = -3
	relaxed_mod = -2

/datum/brain_trauma/psychological/paranoid/on_life()
	..()
	owner.hallucination += 75 //Schizophernia is supposed to be fucking hard. This ensures it
	owner.confused += 2
	if(prob(0.5))
		to_chat(owner, "<span class='danger'>You feel faint.</span>")
		owner.Unconscious(80)



/datum/brain_trauma/psychological/paranoid/on_gain()
	ADD_TRAIT(owner, TRAIT_PARANOID, PSYCH_TRAIT)
	..()

/datum/brain_trauma/psychological/paranoid/on_lose()
	REMOVE_TRAIT(owner, TRAIT_PARANOID, PSYCH_TRAIT)
	..()

#define BLIND_SPREE 1
#define MOAN_SPREE 2
#define SHOUTING_SPREE 3
#define SPASM_SPREE 4
#define MUTE_SPREE 5

/datum/brain_trauma/psychological/delusional
	name = "Delusional schizophrenia"
	desc = "Mental disorder that is characterized by uncontrolable actions , and delusional thoughts"
	gain_text = "<span class='danger'>You feel your body not responding</span>"
	lose_text = "<span class='notice'>You feel free once again</span>"
	scan_desc = "Electric imaging suggests a mental disorder is present"
	cure_points = 1200
	lithiated_mod = 3
	control_mod = -3
	fearless_mod = -2
	relaxed_mod = 2
	var/state = 0


/datum/brain_trauma/psychological/delusional/on_life()
	..()
	switch(state)
		if(BLIND_SPREE)
			owner.become_blind(PSYCH_TRAIT)
		if(MOAN_SPREE)
			owner.emote(pick("moan","giggle","laugh"))
		if(SHOUTING_SPREE)
			owner.emote(pick("scream","giggle","laugh"))
		if(SPASM_SPREE)
			owner.apply_status_effect(STATUS_EFFECT_SPASMS)
		if(MUTE_SPREE)
			ADD_TRAIT(owner, TRAIT_MUTE, PSYCH_TRAIT)


/datum/brain_trauma/psychological/delusional/proc/roll_bad_effect()
	clear_bad_effect()
	state = rand(0,5) //Upon getting 0 you will have a few minutes of silence. After that you are back on the ride!
	addtimer(CALLBACK(src, .proc/roll_bad_effect), rand(1 MINUTES, 5 MINUTES))

/datum/brain_trauma/psychological/delusional/proc/clear_bad_effect()
	switch(state)
		if(BLIND_SPREE)
			owner.cure_blind(PSYCH_TRAIT)
		if(SPASM_SPREE)
			owner.remove_status_effect(STATUS_EFFECT_SPASMS)
		if(MUTE_SPREE)
			REMOVE_TRAIT(owner, TRAIT_MUTE, PSYCH_TRAIT)

/datum/brain_trauma/psychological/delusional/on_gain()
	roll_bad_effect()
	ADD_TRAIT(owner, TRAIT_DELUSIONAL, PSYCH_TRAIT)
	..()

/datum/brain_trauma/psychological/delusional/on_lose()
	clear_bad_effect()
	REMOVE_TRAIT(owner, TRAIT_DELUSIONAL, PSYCH_TRAIT)
	..()


/datum/brain_trauma/psychological/collector
	name = "Obsessive collector disorder"
	desc = "Mental disorder that is characterized by an intense need of collecting otherwise useless objects"
	gain_text = "<span class='danger'>You feel an odd compulsion to objects</span>"
	lose_text = "<span class='notice'>You feel free once again</span>"
	scan_desc = "Electric imaging suggests a mental disorder is present"
	cure_points = 1000
	lithiated_mod = -2
	control_mod = 4
	fearless_mod = -1
	relaxed_mod = 1

	var/list/obj/item/possible_items = list(/obj/item/toy = "<span class='boldwarning'>You feel a great need to collect toys of all kind!</span>",
	/obj/item/stamp = "<span class='boldwarning'>You feel a great need to collect stamps!</span>",
	/obj/item/shard = "<span class='boldwarning'>You feel a great need to collect stamps!</span>",
	/obj/item/reagent_containers/food/drinks/bottle = "<span class='boldwarning'>You feel a great need to collect bottles of all kind!</span>")
	var/list/obj/item/needed_item
	var/greed_level = 0

/datum/brain_trauma/psychological/collector/on_life()
	..()
	if(!check_items())
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "collectors_itch", /datum/mood_event/collectors_itch)
		SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "collectors_satisfaction", /datum/mood_event/collectors_satisfacton)
	else
		SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "collectors_itch", /datum/mood_event/collectors_itch)
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "collectors_satisfaction", /datum/mood_event/collectors_satisfacton)

/datum/brain_trauma/psychological/collector/proc/check_items()
	var/stolen_count
	var/list/all_items = owner.GetAllContents()
	for(var/obj/I in all_items) //Check for wanted items
		if(is_type_in_typecache(I, needed_item))
			stolen_count++
	return stolen_count >= greed_level

/datum/brain_trauma/psychological/collector/proc/increase_greed()
	to_chat(owner, "<span class='boldwarning'>You feel your greed expanding</span>")
	greed_level++
	addtimer(CALLBACK(src, .proc/increase_greed), 5 MINUTES)

/datum/brain_trauma/psychological/collector/proc/announce_item()
	to_chat(owner, "<span class='boldwarning'>You feel a great need to collect toys of all kind!</span>")

/datum/brain_trauma/psychological/collector/on_gain()
	needed_item = pick(possible_items)
	announce_item()
	needed_item = typecacheof(needed_item)
	increase_greed()
	ADD_TRAIT(owner, TRAIT_COLLECTOR, PSYCH_TRAIT)
	..()

/datum/brain_trauma/psychological/collector/on_lose()
	REMOVE_TRAIT(owner, TRAIT_COLLECTOR, PSYCH_TRAIT)
	..()

/datum/brain_trauma/psychological/bulimia
	name = "Bulimia Nervosa"
	desc = "Mental disorder that is characterized by vomiting after eating"
	gain_text = "<span class='danger'>You feel your stomach turning</span>"
	lose_text = "<span class='notice'>You feel able to eat once again</span>"
	scan_desc = "Electric imaging suggests a mental disorder is present"
	cure_points = 500
	lithiated_mod = -4
	control_mod = 3
	fearless_mod = 2
	relaxed_mod = -3

/datum/brain_trauma/psychological/bulimia/on_life()
	if(owner.nutrition > NUTRITION_LEVEL_WELL_FED && !HAS_TRAIT(owner,TRAIT_UNDER_CONTROL))
		to_chat(owner, "<span class='boldwarning'>You cannot handle that much food in your stomach</span>")
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "collectors_satisfaction", /datum/mood_event/ashamed_bulimia)
		owner.vomit()

/datum/brain_trauma/psychological/bulimia/on_gain()
	ADD_TRAIT(owner, TRAIT_BULIMIA, PSYCH_TRAIT)
	..()

/datum/brain_trauma/psychological/bulimia/on_lose()
	REMOVE_TRAIT(owner, TRAIT_BULIMIA, PSYCH_TRAIT)
	..()
