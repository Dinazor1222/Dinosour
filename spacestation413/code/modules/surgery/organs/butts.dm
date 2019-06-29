/obj/item/organ/butt
	name = "butt"
	desc = "extremely treasured body part"
	alternate_worn_icon = 'spacestation413/icons/mob/head.dmi'
	icon = 'spacestation413/icons/obj/butts.dmi'
	icon_state = "butt"
	item_state = "butt"
	zone = "groin"
	slot = ORGAN_SLOT_BUTT
	throwforce = 5
	throw_speed = 4
	force = 5
	hitsound = 'spacestation413/sound/effects/fart.ogg'
	body_parts_covered = HEAD
	slot_flags = SLOT_HEAD
	embedding = list("embedded_pain_multiplier" = 1, "embed_chance" = 4, "embedded_fall_chance" = 10, "embedded_ignore_throwspeed_threshold" = FALSE) //This is a joke
	juice_results = list(/datum/reagent/drug/fartium = 20)
	var/loose = 0
	var/max_combined_w_class = 3
	var/max_w_class = 2
	var/max_items = 2
	var/obj/item/storage/internal/pocket/butt/inv = /obj/item/storage/internal/pocket/butt

/obj/item/organ/butt/xeno //XENOMORPH BUTTS ARE BEST BUTTS yes i agree
	name = "alien butt"
	desc = "best trophy ever"
	icon_state = "xenobutt"
	item_state = "xenobutt"
	max_items = 3
	max_combined_w_class = 5

/obj/item/organ/butt/bluebutt // bluespace butts, science
	name = "butt of holding"
	desc = "This butt has bluespace properties, letting you store more items in it. Four tiny items, or two small ones, or one normal one can fit."
	icon_state = "bluebutt"
	item_state = "bluebutt"
	status = ORGAN_ROBOTIC
	max_combined_w_class = 12
	max_w_class = 3
	max_items = 4

/obj/item/organ/butt/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	inv = new(H)
	var/datum/component/storage/STR = inv.GetComponent(/datum/component/storage)
	STR.max_w_class = max_w_class
	STR.max_items = max_items
	STR.max_combined_w_class = max_combined_w_class

/obj/item/organ/butt/Remove(mob/living/carbon/M, special = 0)
	var/turf/T = get_turf(M)
	if(inv)
		var/datum/component/storage/STR = inv.GetComponent(/datum/component/storage)
		for(var/i in inv.contents)
			var/obj/item/I = i
			STR.remove_from_storage(I, T)
	QDEL_NULL(inv)
	..()

/obj/item/organ/butt/on_life()
	if(owner && inv)
		for(var/obj/item/I in inv.contents)
			if(I.is_sharp() || is_pointed(I))
				owner.bleed(4)

/obj/item/organ/butt/Destroy()
	if(inv && owner)
		var/turf/T = get_turf(owner)
		var/datum/component/storage/STR = inv.GetComponent(/datum/component/storage)
		for(var/i in inv.contents)
			var/obj/item/I = i
			STR.remove_from_storage(I, T)
	QDEL_NULL(inv)
	..()

/obj/item/organ/butt/attackby(var/obj/item/W, mob/user as mob, params) // copypasting bot manufucturing process, im a lazy fuck

	if(istype(W, /obj/item/bodypart/l_arm/robot) || istype(W, /obj/item/bodypart/r_arm/robot))
		if(istype(src, /obj/item/organ/butt/bluebutt)) //nobody sprited a blue butt buttbot
			to_chat(user, "<span class='warning'>Why the heck would you want to make a robot out of this?</span>")
			return
		user.dropItemToGround(W)
		qdel(W)
		var/turf/T = get_turf(src.loc)
		var/mob/living/simple_animal/bot/buttbot/B = new /mob/living/simple_animal/bot/buttbot(T)
		if(istype(src, /obj/item/organ/butt/xeno))
			B.xeno = 1
			B.icon_state = "buttbot_xeno"
			B.speech_list = list("hissing butts", "hiss hiss motherfucker", "nice trophy nerd", "butt", "woop get an alien inspection")
		to_chat(user, "<span class='notice'>You add the robot arm to the butt and... What?</span>")
		user.dropItemToGround(src)
		qdel(src)

/obj/item/organ/butt/throw_impact(atom/hit_atom)
	..()
	playsound(src, 'spacestation413/sound/effects/fart.ogg', 50, 1, 5)

/mob/living/carbon/proc/regeneratebutt()
	if(!getorganslot("butt"))
		if(ishuman(src) || ismonkey(src))
			var/obj/item/organ/butt/B = new()
			B.Insert(src)
		if(isalien(src))
			var/obj/item/organ/butt/xeno/X = new()
			X.Insert(src) 
