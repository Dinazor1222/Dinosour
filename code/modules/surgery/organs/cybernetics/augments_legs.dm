/obj/item/organ/cyberimp/leg
	name = "leg-mounted implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	zone = BODY_ZONE_R_LEG
	icon_state = "implant-toolkit"
	w_class = WEIGHT_CLASS_SMALL
	encode_info = AUGMENT_NT_LOWLEVEL

	var/double_legged = FALSE

/obj/item/organ/cyberimp/leg/Initialize()
	. = ..()
	update_icon()
	SetSlotFromZone()

/obj/item/organ/cyberimp/leg/proc/SetSlotFromZone()
	switch(zone)
		if(BODY_ZONE_R_LEG)
			slot = ORGAN_SLOT_LEFT_LEG_AUG
		if(BODY_ZONE_L_LEG)
			slot = ORGAN_SLOT_RIGHT_LEG_AUG
		else
			CRASH("Invalid zone for [type]")

/obj/item/organ/cyberimp/leg/update_icon()
	if(zone == BODY_ZONE_R_LEG)
		transform = null
	else // Mirroring the icon
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/cyberimp/leg/examine(mob/user)
	. = ..()
	. += "<span class='info'>[src] is assembled in the [zone == BODY_ZONE_R_LEG ? "right" : "left"] LEG configuration. You can use a screwdriver to reassemble it.</span>"

/obj/item/organ/cyberimp/leg/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return TRUE
	I.play_tool_sound(src)
	if(zone == BODY_ZONE_R_LEG)
		zone = BODY_ZONE_L_LEG
	else
		zone = BODY_ZONE_R_LEG
	SetSlotFromZone()
	to_chat(user, "<span class='notice'>You modify [src] to be installed on the [zone == BODY_ZONE_R_LEG ? "right" : "left"] leg.</span>")
	update_icon()

/obj/item/organ/cyberimp/leg/Insert(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()
	if(!double_legged)
		on_full_insert(M, special, drop_if_replaced)
		return
	var/obj/item/organ/organ = M.getorganslot(slot == ORGAN_SLOT_LEFT_LEG_AUG ? ORGAN_SLOT_RIGHT_LEG_AUG : ORGAN_SLOT_LEFT_LEG_AUG)
	if(organ && organ.type == type)
		on_full_insert(M, special, drop_if_replaced)

/obj/item/organ/cyberimp/leg/proc/on_full_insert(mob/living/carbon/M, special, drop_if_replaced)
	return

/obj/item/organ/cyberimp/leg/emp_act(severity)
	. = ..()
	owner.apply_damage(10,BURN,zone)

/obj/item/organ/cyberimp/leg/table_glider
	name = "table-glider implant"
	desc = "Implant that allows you quickly glide tables, if you have this installed in both of your legs."
	encode_info = AUGMENT_NT_LOWLEVEL
	double_legged = TRUE

/obj/item/organ/cyberimp/leg/table_glider/update_implants()
	if(!check_compatibility())
		REMOVE_TRAIT(owner,TRAIT_FAST_CLIMBER,type)
		return
	ADD_TRAIT(owner,TRAIT_FAST_CLIMBER,type)

/obj/item/organ/cyberimp/leg/table_glider/on_full_insert(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()
	if(!check_compatibility())
		return
	ADD_TRAIT(owner,TRAIT_FAST_CLIMBER,type)

/obj/item/organ/cyberimp/leg/table_glider/Remove(mob/living/carbon/M, special)
	REMOVE_TRAIT(owner,TRAIT_FAST_CLIMBER,type)
	return ..()

/obj/item/organ/cyberimp/leg/shove_resist
	name = "BU-TAM resistor implant"
	desc = "Implant that allows you to resist shoves, instead shoves deal pure stamina damage."
	encode_info = AUGMENT_NT_HIGHLEVEL
	double_legged = TRUE

/obj/item/organ/cyberimp/leg/table_glider/update_implants()
	if(!check_compatibility())
		REMOVE_TRAIT(owner,TRAIT_SHOVE_RESIST,type)
		return
	ADD_TRAIT(owner,TRAIT_SHOVE_RESIST,type)

/obj/item/organ/cyberimp/leg/shove_resist/on_full_insert(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()
	if(!check_compatibility())
		return
	ADD_TRAIT(owner,TRAIT_SHOVE_RESIST,type)

/obj/item/organ/cyberimp/leg/shove_resist/Remove(mob/living/carbon/M, special)
	REMOVE_TRAIT(owner,TRAIT_SHOVE_RESIST,type)
	return ..()

/obj/item/organ/cyberimp/leg/accelerator
	name = "P.R.Y.Z.H.O.K accelerator system"
	desc = "Russian implant that allows you to tackle people."
	encode_info = AUGMENT_TG_LEVEL
	double_legged = TRUE
	var/datum/component/tackler

/obj/item/organ/cyberimp/leg/accelerator/on_full_insert(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()
	tackler = M.AddComponent(/datum/component/tackler, stamina_cost=30, base_knockdown = 1.5, range = 5, speed = 2, skill_mod = 1.5, min_distance = 3)

/obj/item/organ/cyberimp/leg/accelerator/Remove(mob/living/carbon/M, special)
	if(tackler)
		qdel(tackler)
	return ..()

/obj/item/organ/cyberimp/leg/chemplant
	name = "Debug Chemplant"
	desc = "You shouldn't see this!"
	icon_state = "chemplant"
	implant_overlay = "chemplant_overlay"
	var/list/reagent_list = list()
	var/health_threshold = 20
	var/max_ticks_cooldown = 100
	var/current_ticks_cooldown = 0

/obj/item/organ/cyberimp/leg/chemplant/on_life()
	if(!check_compatibility())
		return

	if(current_ticks_cooldown > 0)
		current_ticks_cooldown--
		return

	if(owner.health < health_threshold)
		current_ticks_cooldown = max_ticks_cooldown
		on_effect()

/obj/item/organ/cyberimp/leg/chemplant/emp_act(severity)
	. = ..()
	health_threshold += rand(-10,10)

	on_effect()

/obj/item/organ/cyberimp/leg/chemplant/proc/on_effect()
	owner.reagents.add_reagent_list(reagent_list)
	to_chat(owner,"<span class = 'notice'> You feel a sharp pain as the cocktail of chemicals is injected into your bloodstream!</span>")
	return

/obj/item/organ/cyberimp/leg/chemplant/drugs
	name = "deep-vein emergency morale rejuvenator"
	desc = "Dangerous implant used by the syndicate to reinforce their assault forces that go on suicide missions."
	implant_color = "#74942a"
	encode_info = AUGMENT_SYNDICATE_LEVEL
	reagent_list = list(/datum/reagent/determination = 5, /datum/reagent/drug/methamphetamine = 5 , /datum/reagent/medicine/atropine = 5)

/obj/item/organ/cyberimp/leg/chemplant/emergency
	name = "deep emergency chemical infuser"
	desc = "Dangerous implant used by the syndicate to reinforce their assault forces that go on suicide missions."
	implant_color = "#2a6194"
	encode_info = AUGMENT_NT_HIGHLEVEL
	reagent_list = list(/datum/reagent/medicine/atropine = 5, /datum/reagent/medicine/omnizine = 3 , /datum/reagent/medicine/leporazine = 3, /datum/reagent/medicine/c2/aiuri = 2, /datum/reagent/medicine/c2/libital = 2)

/obj/item/organ/cyberimp/leg/chemplant/rage
	name = "R.A.G.E chemical system"
	desc = "Extremely dangerous system that fills the user with a mix of potent drugs in dire situation."
	implant_color = "#ce3914"
	encode_info = AUGMENT_TG_LEVEL
	reagent_list = list(/datum/reagent/determination = 5, /datum/reagent/drug/methamphetamine = 5 , /datum/reagent/drug/bath_salts = 5)

