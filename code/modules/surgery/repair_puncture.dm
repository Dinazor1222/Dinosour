
/////BURN FIXING SURGERIES//////

#define REALIGN_INNARDS 1
#define WELD_VEINS		2

///// Debride burnt flesh
/datum/surgery/repair_puncture
	name = "Repair puncture"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/repair_innards, /datum/surgery_step/seal_veins, /datum/surgery_step/close)
	target_mobtypes = list(/mob/living/carbon)
	possible_locs = list(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_CHEST,BODY_ZONE_HEAD)
	requires_real_bodypart = TRUE
	targetable_wound = /datum/wound/pierce
	var/next_step = REALIGN_INNARDS

/datum/surgery/repair_puncture/can_start(mob/living/user, mob/living/carbon/target)
	if(..())
		var/obj/item/bodypart/targeted_bodypart = target.get_bodypart(user.zone_selected)
		var/datum/wound/burn/pierce_wound = targeted_bodypart.get_wound_type(targetable_wound)
		return(pierce_wound && pierce_wound.blood_flow > 0)

//SURGERY STEPS

///// Debride
/datum/surgery_step/repair_innards
	name = "realign blood vessels"
	implements = list(TOOL_HEMOSTAT = 100, TOOL_SCALPEL = 85, TOOL_WIRECUTTER = 40)
	time = 30
	experience_given = MEDICAL_SKILL_MEDIUM

/datum/surgery_step/repair_innards/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(surgery.operated_wound)
		var/datum/wound/pierce/pierce_wound = surgery.operated_wound
		if(pierce_wound.blood_flow <= 0)
			to_chat(user, "<span class='notice'>[target]'s [parse_zone(user.zone_selected)] has no puncture to repair!</span>")
			surgery.status++
			return
		display_results(user, target, "<span class='notice'>You begin to realign the torn blood vessels in [target]'s [parse_zone(user.zone_selected)]...</span>",
			"<span class='notice'>[user] begins to realign the torn blood vessels in [target]'s [parse_zone(user.zone_selected)] with [tool].</span>",
			"<span class='notice'>[user] begins to realign the torn blood vessels in [target]'s [parse_zone(user.zone_selected)].</span>")
	else
		user.visible_message("<span class='notice'>[user] looks for [target]'s [parse_zone(user.zone_selected)].</span>", "<span class='notice'>You look for [target]'s [parse_zone(user.zone_selected)]...</span>")

/datum/surgery_step/repair_innards/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/datum/wound/pierce/pierce_wound = surgery.operated_wound
	if(pierce_wound)
		display_results(user, target, "<span class='notice'>You successfully realign some of the blood vessels in [target]'s [parse_zone(target_zone)].</span>",
			"<span class='notice'>[user] successfully realigns some of the blood vessels in [target]'s [parse_zone(target_zone)] with [tool]!</span>",
			"<span class='notice'>[user] successfully realigns some of the blood vessels in  [target]'s [parse_zone(target_zone)]!</span>")
		log_combat(user, target, "excised infected flesh in", addition="INTENT: [uppertext(user.a_intent)]")
		surgery.operated_bodypart.receive_damage(brute=3, wound_bonus=CANT_WOUND)
		pierce_wound.blood_flow -= 0.25
		//if(pierce_wound.blood_flow <= )

	else
		to_chat(user, "<span class='warning'>[target] has no puncture wound there!</span>")
	return ..()

/datum/surgery_step/repair_innards/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, var/fail_prob = 0)
	..()
	display_results(user, target, "<span class='notice'>You carve away some of the healthy flesh from [target]'s [parse_zone(target_zone)].</span>",
		"<span class='notice'>[user] carves away some of the healthy flesh from [target]'s [parse_zone(target_zone)] with [tool]!</span>",
		"<span class='notice'>[user] carves away some of the healthy flesh from  [target]'s [parse_zone(target_zone)]!</span>")
	surgery.operated_bodypart.receive_damage(brute=rand(4,8), sharpness=SHARP_EDGED)

///// Dressing burns
/datum/surgery_step/seal_veins
	name = "weld veins" // if your doctor says they're going to weld your blood vessels back together, you're either A) on SS13, or B) in grave mortal peril
	implements = list(TOOL_CAUTERY = 100, /obj/item/gun/energy/laser = 90, TOOL_WELDER = 70, /obj/item = 30)
	time = 40
	experience_given = MEDICAL_SKILL_MEDIUM

/datum/surgery_step/seal_veins/tool_check(mob/user, obj/item/tool)
	if(implement_type == TOOL_WELDER || implement_type == /obj/item)
		return tool.get_temperature()

	return TRUE

/datum/surgery_step/seal_veins/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/datum/wound/pierce/pierce_wound = surgery.operated_wound
	if(pierce_wound)
		display_results(user, target, "<span class='notice'>You begin to meld some of the split blood vessels in [target]'s [parse_zone(user.zone_selected)]...</span>",
			"<span class='notice'>[user] begins to meld some of the split blood vessels in [target]'s [parse_zone(user.zone_selected)] with [tool].</span>",
			"<span class='notice'>[user] begins to meld some of the split blood vessels in [target]'s [parse_zone(user.zone_selected)].</span>")
	else
		user.visible_message("<span class='notice'>[user] looks for [target]'s [parse_zone(user.zone_selected)].</span>", "<span class='notice'>You look for [target]'s [parse_zone(user.zone_selected)]...</span>")

/datum/surgery_step/seal_veins/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/datum/wound/pierce/pierce_wound = surgery.operated_wound
	if(pierce_wound)
		display_results(user, target, "<span class='notice'>You successfully meld some of the split blood vessels in [target]'s [parse_zone(target_zone)] with [tool].</span>",
			"<span class='notice'>[user] successfully melds some of the split blood vessels in [target]'s [parse_zone(target_zone)] with [tool]!</span>",
			"<span class='notice'>[user] successfully melds some of the split blood vessels in [target]'s [parse_zone(target_zone)]!</span>")
		log_combat(user, target, "dressed burns in", addition="INTENT: [uppertext(user.a_intent)]")
		pierce_wound.blood_flow -= 0.5
		if(pierce_wound.blood_flow > 0)
			surgery.status = REALIGN_INNARDS
			to_chat(user, "<span class='notice'><i>There still seems to be misaligned blood vessels to finish...<i></span>")
		else
			to_chat(user, "<span class='green'>You've repaired all the internal damage in [target]'s [parse_zone(target_zone)]!</span>")
	else
		to_chat(user, "<span class='warning'>[target] has no burns there!</span>")
	return ..()

/datum/surgery_step/seal_veins/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, var/fail_prob = 0)
	..()
	if(istype(tool, /obj/item/stack))
		var/obj/item/stack/used_stack = tool
		used_stack.use(1)

#undef REALIGN_INNARDS
#undef WELD_VEINS
