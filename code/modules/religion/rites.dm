/datum/religion_rites
/// name of the religious rite
	var/name = "religious rite"
/// Description of the religious rite
	var/desc = "immm gonna rooon"
/// length it takes to complete the ritual
	var/ritual_length = (10 SECONDS) //total length it'll take
/// list of invocations said (strings) throughout the rite
	var/list/ritual_invocations //strings that are by default said evenly throughout the rite
/// message when you invoke
	var/invoke_msg
	var/favor_cost = 0

/datum/religion_rites/New()
	. = ..()
	if(!GLOB?.religious_sect)
		return
	LAZYADD(GLOB.religious_sect.active_rites, src)

/datum/religion_rites/Destroy()
	if(!GLOB?.religious_sect)
		return
	LAZYREMOVE(GLOB.religious_sect.active_rites, src)
	return ..()


///Called to perform the invocation of the rite, with args being the performer and the altar where it's being performed. Maybe you want it to check for something else?
/datum/religion_rites/proc/perform_rite(mob/living/user, atom/religious_tool)
	if(GLOB.religious_sect?.favor < favor_cost)
		to_chat(user, "<span class='warning'>This rite requires more favor!</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You begin to perform the rite of [name]...</span>")
	if(!ritual_invocations)
		if(do_after(user, target = user, delay = ritual_length))
			return TRUE
		return FALSE
	var/first_invoke = TRUE
	for(var/i in ritual_invocations)
		if(first_invoke) //instant invoke
			user.say(i)
			first_invoke = FALSE
			continue
		if(!ritual_invocations.len) //we divide so we gotta protect
			return FALSE
		if(!do_after(user, target = user, delay = ritual_length/ritual_invocations.len))
			return FALSE
		user.say(i)
	if(!do_after(user, target = user, delay = ritual_length/ritual_invocations.len)) //because we start at 0 and not the first fraction in invocations, we still have another fraction of ritual_length to complete
		return FALSE
	if(invoke_msg)
		user.say(invoke_msg)
	return TRUE


///Does the thing if the rite was successfully performed. return value denotes that the effect successfully (IE a harm rite does harm)
/datum/religion_rites/proc/invoke_effect(mob/living/user, atom/religious_tool)
	GLOB.religious_sect.on_riteuse(user,religious_tool)
	return TRUE


/*********Technophiles**********/

/datum/religion_rites/synthconversion
	name = "Synthetic Conversion"
	desc = "Convert a human-esque individual into a (superior) Android."
	ritual_length = 1 MINUTES
	ritual_invocations = list("By the inner workings of our god...",
						"... We call upon you, in the face of adversity...",
						"... to complete us, removing that which is undesirable...")
	invoke_msg = "... Arise, our champion! Become that which your soul craves, live in the world as your true form!!"
	favor_cost = 500

/datum/religion_rites/synthconversion/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		. = FALSE
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
			return
		to_chat(user, "<span class='warning'>This rite requires an individual to be buckled to [movable_reltool].</span>")
		return
	return ..()

/datum/religion_rites/synthconversion/invoke_effect(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool?.buckled_mobs?.len)
		return FALSE
	var/mob/living/carbon/human/human2borg
	for(var/i in movable_reltool.buckled_mobs)
		if(istype(i,/mob/living/carbon/human))
			human2borg = i
			break
	if(!human2borg)
		return FALSE
	human2borg.set_species(/datum/species/android)
	human2borg.visible_message("<span class='notice'>[human2borg] has been converted by the rite of [name]!</span>")
	return TRUE


/*********Ever-Burning Candle**********/

/datum/religion_rites/fireproof
	name = "Unmelting Wax"
	desc = "Grants fire immunity to any piece of clothing."
	ritual_length = 15 SECONDS
	ritual_invocations = list("And so to support the holder of the Ever-Burning candle...",
	"... allow this unworthy apparel to serve you ...",
	"... make it strong enough to burn a thousand time and more ...")
	invoke_msg = "... Come forth in your new form, and join the unmelting wax of the one true flame!"
	favor_cost = 1000
///the piece of clothing that will be fireproofed, only one per rite
	var/obj/item/clothing/chosen_clothing

/datum/religion_rites/fireproof/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/clothing/apparel in get_turf(religious_tool))
		if(apparel.max_heat_protection_temperature >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
			continue //we ignore anything that is already fireproof
		chosen_clothing = apparel //the apparel has been chosen by our lord and savior
		return ..()
	return FALSE

/datum/religion_rites/fireproof/invoke_effect(mob/living/user, atom/religious_tool)
	for(chosen_clothing in get_turf(religious_tool))
		chosen_clothing.name = "unmelting [chosen_clothing.name]"
		chosen_clothing.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		chosen_clothing.add_atom_colour("#FF0000", FIXED_COLOUR_PRIORITY)
		chosen_clothing.max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
		chosen_clothing.heat_protection = chosen_clothing.body_parts_covered
		chosen_clothing.resistance_flags |= FIRE_PROOF
		chosen_clothing = null //our lord and savior no longer cares about this apparel
		return TRUE
	chosen_clothing = null
	to_chat(user, "<span class='warning'>The clothing that was chosen for the rite is no longer on the altar!</span>")
	return FALSE


/datum/religion_rites/burning_sacrifice
	name = "Candle Fuel"
	desc = "Sacrifice a buckled burning corpse for favor, the more burn damage the corpse has the more favor you will receive."
	ritual_length = 20 SECONDS
	ritual_invocations = list("To feed the fire of the one true flame ...",
	"... to make it burn brighter ...",
	"... so that it may consume all in its path ...",
	"... I offer you this pitiful being ...")
	invoke_msg = "... may it join you in the amalgamation of wax and fire, and become one in the black and white scene. "
///the burning corpse chosen for the sacrifice of the rite
	var/mob/living/carbon/chosen_sacrifice

/datum/religion_rites/burning_sacrifice/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user, "<span class='warning'>Nothing is buckled to the altar!</span>")
		return FALSE
	for(var/mob/living/carbon/corpse in movable_reltool.buckled_mobs) //works with any carbon corpse,not just humans
		if(corpse.stat != DEAD)
			to_chat(user, "<span class='warning'>You can only sacrifice dead bodies, this one is still alive!</span>")
			return FALSE
		if(!corpse.on_fire)
			to_chat(user, "<span class='warning'>This corpse needs to be on fire to be sacrificed!</span>")
			return FALSE
		chosen_sacrifice = corpse
		return ..()
	return FALSE

/datum/religion_rites/burning_sacrifice/invoke_effect(mob/living/user, atom/movable/religious_tool)
	for(chosen_sacrifice in religious_tool.buckled_mobs) //checks one last time if the right corpse is still buckled
		var/favor_gained = 100 + round(chosen_sacrifice.getFireLoss())
		GLOB.religious_sect?.adjust_favor(favor_gained, user)
		to_chat(user, "<span class='notice'>[GLOB.deity] absorb the burning corpse and any trace of fire with it. [GLOB.deity] rewards you with [favor_gained] favor.</span>")
		chosen_sacrifice.dust(force = TRUE)
		chosen_sacrifice = null
		return TRUE
	to_chat(user, "<span class='warning'>The sacrifice has been moved before you could finish the rite!</span>")
	chosen_sacrifice = null
	return FALSE


/datum/religion_rites/infinite_candle
	name = "Immortal Candles"
	desc = "Creates 5 candles that never run out of wax."
	ritual_length = 10 SECONDS
	invoke_msg = "please lend us five of your candles so we may bask in your Ever-Burning glory."
	favor_cost = 200

/datum/religion_rites/infinite_candle/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/altar_turf = get_turf(religious_tool)
	for(var/candle_count = 0, candle_count < 5, candle_count++)
		new /obj/item/candle/infinite(altar_turf)
	playsound(get_turf(altar_turf), 'sound/magic/charge.ogg', 50, TRUE)
	return TRUE
