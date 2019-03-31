/obj/item/suspiciousphone
	name = "suspicious phone"
	desc = "This device raises pink levels to unknown highs."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "suspiciousphone"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("dumped")
	var/dumped = FALSE
	var/mob/living/carbon/human/bogdanoff

/obj/item/suspiciousphone/attack_self(mob/user)
	if(!ishuman(user))
		to_chat(user, "<span class='warning'>This device is too advanced for you!</span>")
		return
	if(dumped)
		to_chat(user, "<span class='warning'>You already activated Protocol CRAB-17.</span>")
		return FALSE
	if(alert(user, "Are you sure you want to crash this market with no survivors?", "Protocol CRAB-17", "Yes", "No") == "Yes")
		if(dumped) //Prevents fuckers from cheesing alert
			return FALSE
		sound_to_playing_players('sound/items/dump_it.ogg', 75)
		bogdanoff = user
		var/turf/targetturf = get_random_station_turf()
		var/obj/effect/dumpeetTarget/target = new(targetturf)
		target.bogdanoff = src.bogdanoff
		dumped = TRUE

/obj/structure/checkoutmachine
	name = "Nanotrasen Space-Coin Market"
	desc = "This is good for spacecoin because"
	icon = 'icons/obj/money_machine.dmi'
	icon_state = "bogdanoff"
	layer = TABLE_LAYER //So that the crate inside doesn't appear underneath
	armor = list("melee" = 30, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 100, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 80)
	density = TRUE
	var/list/accounts_to_rob
	var/mob/living/carbon/human/bogdanoff
	var/canwalk = FALSE
	pixel_z = -8
	layer = LARGE_MOB_LAYER

/obj/structure/checkoutmachine/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/card/id))
		var/obj/item/card/id/card = W
		if(!card.registered_account)
			to_chat(user, "<span class='warning'>This card does not have a registered account!</span>")
			return
		if(!card.registered_account.being_dumped)
			to_chat(user, "<span class='warning'>It appears that your funds are safe from draining!</span>")
			return
		if(do_after(user, 40, target = src))
			if(!card.registered_account.being_dumped)
				return
			to_chat(user, "<span class='warning'>You quickly cash out your funds to a more secure banking location. Funds are safu.</span>")
			card.registered_account.being_dumped = FALSE	
			card.registered_account.canWithdraw = 0
	else
		return ..()

/obj/structure/checkoutmachine/Initialize()
	. = ..()
	add_overlay("flaps")
	add_overlay("hatch")
	add_overlay("legs_retracted")
	addtimer(CALLBACK(src, .proc/startUp), 50)
	START_PROCESSING(SSfastprocess, src)
	
/obj/structure/checkoutmachine/proc/startUp() //very VERY snowflake code that adds a neat animation when the pod lands.
	start_dumping() //The machine doesnt move during this time, giving people close by a small window to grab their funds before it starts running around
	priority_announce("The spacecoin bubble has popped! Get to the credit deposit machine at [get_area(src).name] and cash out before you lose all of your funds!", sender_override = "CRAB-17 Protocol")
	sleep(10)
	playsound(src, 'sound/machines/click.ogg', 15, 1, -3)
	cut_overlay("flaps")
	sleep(10)
	playsound(src, 'sound/machines/click.ogg', 15, 1, -3)
	cut_overlay("hatch")
	sleep(30)
	playsound(src,'sound/machines/twobeep.ogg',50,0)
	var/mutable_appearance/hologram = mutable_appearance(icon, "hologram")
	hologram.pixel_y = 16
	add_overlay(hologram)
	var/mutable_appearance/holosign = mutable_appearance(icon, "holosign")
	holosign.pixel_y = 16
	add_overlay(holosign)
	add_overlay("legs_extending")
	cut_overlay("legs_retracted")
	pixel_z += 4
	sleep(5)
	add_overlay("legs_extended")
	cut_overlay("legs_extending")
	pixel_z += 4
	sleep(20)
	add_overlay("screen_lines")
	sleep(5)
	cut_overlay("screen_lines")
	sleep(5)
	add_overlay("screen_lines")
	add_overlay("screen")
	sleep(5)
	playsound(src,'sound/machines/triple_beep.ogg',50,0)
	add_overlay("text")
	sleep(10)
	add_overlay("legs")
	cut_overlay("legs_extended")
	cut_overlay("screen")
	add_overlay("screen")
	cut_overlay("screen_lines")
	add_overlay("screen_lines")
	cut_overlay("text")
	add_overlay("text")
	canwalk = TRUE

/obj/structure/checkoutmachine/Destroy(var/force)
	if (!force)
		return QDEL_HINT_LETMELIVE
	stop_dumping()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/structure/checkoutmachine/proc/start_dumping()
	accounts_to_rob = SSeconomy.bank_accounts.Copy()
	accounts_to_rob -= bogdanoff.get_bank_account()
	for(var/i in accounts_to_rob)
		var/datum/bank_account/B = i
		B.dumpeet()
	dump()	

/obj/structure/checkoutmachine/proc/dump()
	var/percentage_lost = (rand(1, 10) / 100)
	for(var/i in accounts_to_rob)
		var/datum/bank_account/B = i
		if(!B.being_dumped)
			continue
		var/amount = B.account_balance * percentage_lost 
		bogdanoff.get_bank_account().transfer_money(B, amount)
		B.bank_card_talk("You have lost [percentage_lost * 100]% of your funds!")
	addtimer(CALLBACK(src, .proc/dump), 150) //Drain every 15 seconds

/obj/structure/checkoutmachine/process()
	if(!canwalk)
		return
	var/anydir = pick(GLOB.cardinals)
	if(Process_Spacemove(anydir))
		Move(get_step(src, anydir), anydir)

/obj/structure/checkoutmachine/proc/stop_dumping()
	for(var/i in accounts_to_rob)
		var/datum/bank_account/B = i
		B.being_dumped = FALSE

/obj/effect/dumpeetFall //Falling pod
	name = ""
	icon = 'icons/obj/money_machine_64.dmi'
	pixel_z = 300
	desc = "Get out of the way!"
	layer = FLY_LAYER//that wasnt flying, that was falling with style!
	icon_state = "missile_blur"

/obj/effect/dumpeetTarget
	name = "Landing Zone Indicator"
	desc = "A holographic projection designating the landing zone of something. It's probably best to stand back."
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	light_range = 2
	var/obj/effect/dumpeetFall/DF
	var/obj/structure/checkoutmachine/dump
	var/mob/living/carbon/human/bogdanoff

/obj/effect/ex_act()
	return

/obj/effect/dumpeetTarget/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/startLaunch), 100)
	deadchat_broadcast("<span class='deadsay'>Protocol CRAB-17 has been activated. A space-coin market has been launched at the station!</span>", turf_target = get_turf(src))

/obj/effect/dumpeetTarget/proc/startLaunch()
	DF = new /obj/effect/dumpeetFall(drop_location())
	dump = new /obj/structure/checkoutmachine()
	dump.bogdanoff = src.bogdanoff
	animate(DF, pixel_z = -8, time = 5, , easing = LINEAR_EASING)
	addtimer(CALLBACK(src, .proc/endLaunch), 5, TIMER_CLIENT_TIME) //Go onto the last step after a very short falling animation
	addtimer(CALLBACK(src, .proc/playFallingSound), 1, TIMER_CLIENT_TIME) //Go onto the last step after a very short falling animation

/obj/effect/dumpeetTarget/proc/playFallingSound()
	playsound(src,  'sound/weapons/mortar_whistle.ogg', 80, 1, 6)

/obj/effect/dumpeetTarget/proc/endLaunch()
	QDEL_NULL(DF) //Delete the falling machine effect, because at this point its animation is over. We dont use temp_visual because we want to manually delete it as soon as the pod appears
	playsound(src, "explosion", 80, 1)
	dump.forceMove(get_turf(src))
	qdel(src) //The target's purpose is complete. It can rest easy now
