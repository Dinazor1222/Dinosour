/mob/living/simple_animal/slime
	name = "grey baby slime (123)"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey baby slime"
	pass_flags = PASSTABLE | PASSGRILLE
	ventcrawler = VENTCRAWLER_ALWAYS
	gender = NEUTER
	var/is_adult = 0
	var/docile = 0
	faction = list("slime","neutral")

	harm_intent_damage = 5
	icon_living = "grey baby slime"
	icon_dead = "grey baby slime dead"
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "stomps on"
	response_harm_simple = "stomp on"
	emote_see = list("jiggles", "bounces in place")
	speak_emote = list("blorbles")
	bubble_icon = "slime"
	initial_language_holder = /datum/language_holder/slime

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	maxHealth = 150
	health = 150
	healable = 0

	see_in_dark = 8

	verb_say = "blorbles"
	verb_ask = "inquisitively blorbles"
	verb_exclaim = "loudly blorbles"
	verb_yell = "loudly blorbles"

	// canstun and canknockdown don't affect slimes because they ignore stun and knockdown variables
	// for the sake of cleanliness, though, here they are.
	status_flags = CANUNCONSCIOUS|CANPUSH

	var/cores = 1 // the number of /obj/item/slime_extract's the slime has left inside
	var/mutation_chance = 30 // Chance of mutating, should be between 25 and 35

	var/powerlevel = 0 // 1-10 controls how much electricity they are generating
	var/amount_grown = 0 // controls how long the slime has been overfed, if 10, grows or reproduces

	var/number = 0 // Used to understand when someone is talking to it

	var/mob/living/Target = null // AI variable - tells the slime to hunt this down
	var/mob/living/Leader = null // AI variable - tells the slime to follow this person

	var/attacked = 0 // Determines if it's been attacked recently. Can be any number, is a cooloff-ish variable
	var/rabid = 0 // If set to 1, the slime will attack and eat anything it comes in contact with
	var/holding_still = 0 // AI variable, cooloff-ish for how long it's going to stay in one place
	var/target_patience = 0 // AI variable, cooloff-ish for how long it's going to follow its target

	var/list/Friends = list() // A list of friends; they are not considered targets for feeding; passed down after splitting

	var/list/speech_buffer = list() // Last phrase said near it and person who said it

	var/mood = "" // To show its face
	var/mutator_used = FALSE //So you can't shove a dozen mutators into a single slime
	var/force_stasis = FALSE

	var/static/regex/slime_name_regex = new("\\w+ (baby|adult) slime \\(\\d+\\)")
	///////////TIME FOR SUBSPECIES

	var/colour = "grey"
	var/coretype = /obj/item/slime_extract/grey
	var/list/slime_mutation[4]

	var/static/list/slime_colours = list("rainbow", "grey", "purple", "metal", "orange",
	"blue", "dark blue", "dark purple", "yellow", "silver", "pink", "red",
	"gold", "green", "adamantine", "oil", "light pink", "bluespace",
	"cerulean", "sepia", "black", "pyrite")

	///////////CORE-CROSSING CODE

	var/effectmod //What core modification is being used.
	var/applied = 0 //How many extracts of the modtype have been applied.

	// Transformative extract effects - get passed down
	var/transformeffects = SLIME_EFFECT_DEFAULT
	var/effectsapplied = 0 //for use in the slime scanner


/mob/living/simple_animal/slime/Initialize(mapload, new_colour="grey", new_is_adult=FALSE)
	var/datum/action/innate/slime/feed/F = new
	F.Grant(src)

	is_adult = new_is_adult

	if(is_adult)
		var/datum/action/innate/slime/reproduce/R = new
		R.Grant(src)
		health = 200
		maxHealth = 200
	else
		var/datum/action/innate/slime/evolve/E = new
		E.Grant(src)
	create_reagents(100)
	set_colour(new_colour)
	. = ..()
	set_nutrition(700)
	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_SLIME, 0)
	add_cell_sample()

/mob/living/simple_animal/slime/Destroy()
	for (var/A in actions)
		var/datum/action/AC = A
		AC.Remove(src)
	Target = null
	Leader = null
	Friends = null
	return ..()

/mob/living/simple_animal/slime/proc/set_colour(new_colour)
	colour = new_colour
	update_name()
	slime_mutation = mutation_table(colour)
	var/sanitizedcolour = replacetext(colour, " ", "")
	coretype = text2path("/obj/item/slime_extract/[sanitizedcolour]")
	regenerate_icons()

/mob/living/simple_animal/slime/proc/update_name()
	if(slime_name_regex.Find(name))
		number = rand(1, 1000)
		name = "[colour] [is_adult ? "adult" : "baby"] slime ([number])"
		real_name = name

/mob/living/simple_animal/slime/proc/random_colour()
	set_colour(pick(slime_colours))

/mob/living/simple_animal/slime/regenerate_icons()
	cut_overlays()
	var/icon_text = "[colour] [is_adult ? "adult" : "baby"] slime"
	icon_dead = "[icon_text] dead"
	if(stat != DEAD)
		icon_state = icon_text
		if(mood && !stat)
			add_overlay("aslime-[mood]")
	else
		icon_state = icon_dead
	..()

/mob/living/simple_animal/slime/on_reagent_change()
	. = ..()
	remove_movespeed_modifier(/datum/movespeed_modifier/slime_reagentmod)
	var/amount = 0
	if(reagents.has_reagent(/datum/reagent/medicine/morphine)) // morphine slows slimes down
		amount = 2
	if(reagents.has_reagent(/datum/reagent/consumable/frostoil)) // Frostoil also makes them move VEEERRYYYYY slow
		amount = 5
	if(amount)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/slime_reagentmod, multiplicative_slowdown = amount)

/mob/living/simple_animal/slime/updatehealth()
	. = ..()
	var/mod = 0
	if(!HAS_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN))
		var/health_deficiency = (maxHealth - health)
		if(health_deficiency >= 45)
			mod += (health_deficiency / 25)
		if(health <= 0)
			mod += 2
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/slime_healthmod, multiplicative_slowdown = mod)

/mob/living/simple_animal/slime/adjust_bodytemperature()
	. = ..()
	var/mod = 0
	if(bodytemperature >= 330.23) // 135 F or 57.08 C
		mod = -1	// slimes become supercharged at high temperatures
	else if(bodytemperature < 283.222)
		mod = ((283.222 - bodytemperature) / 10) * 1.75
	if(mod)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/slime_tempmod, multiplicative_slowdown = mod)

/mob/living/simple_animal/slime/ObjBump(obj/O)
	if(!client && powerlevel > 0)
		var/probab = 10
		switch(powerlevel)
			if(1 to 2)
				probab = 20
			if(3 to 4)
				probab = 30
			if(5 to 6)
				probab = 40
			if(7 to 8)
				probab = 60
			if(9)
				probab = 70
			if(10)
				probab = 95
		if(prob(probab))
			if(istype(O, /obj/structure/window) || istype(O, /obj/structure/grille))
				if(nutrition <= get_hunger_nutrition() && !Atkcool)
					if (is_adult || prob(5))
						O.attack_slime(src)
						Atkcool = TRUE
						addtimer(VARSET_CALLBACK(src, Atkcool, FALSE), 4.5 SECONDS)

/mob/living/simple_animal/slime/Process_Spacemove(movement_dir = 0)
	return 2

/mob/living/simple_animal/slime/get_status_tab_items()
	. = ..()
	if(!docile)
		. += "Nutrition: [nutrition]/[get_max_nutrition()]"
	if(amount_grown >= SLIME_EVOLUTION_THRESHOLD)
		if(is_adult)
			. += "You can reproduce!"
		else
			. += "You can evolve!"

	switch(stat)
		if(HARD_CRIT, UNCONSCIOUS)
			. += "You are knocked out by high levels of BZ!"
		else
			. += "Power Level: [powerlevel]"


/mob/living/simple_animal/slime/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced)
		amount = -abs(amount)
	return ..() //Heals them

/mob/living/simple_animal/slime/bullet_act(obj/projectile/Proj)
	attacked += 10
	if((Proj.damage_type == BURN))
		adjustBruteLoss(-abs(Proj.damage)) //fire projectiles heals slimes.
		Proj.on_hit(src)
	else
		. = ..(Proj)
	. = . || BULLET_ACT_BLOCK

/mob/living/simple_animal/slime/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	powerlevel = 0 // oh no, the power!

/mob/living/simple_animal/slime/MouseDrop(atom/movable/A as mob|obj)
	if(isliving(A) && A != src && usr == src)
		var/mob/living/Food = A
		if(CanFeedon(Food))
			Feedon(Food)
	return ..()

/mob/living/simple_animal/slime/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	return

/mob/living/simple_animal/slime/start_pulling(atom/movable/AM, state, force = move_force, supress_message = FALSE)
	return

/mob/living/simple_animal/slime/attack_ui(slot)
	return

/mob/living/simple_animal/slime/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		if(M == src)
			return
		if(buckled)
			Feedstop(silent = TRUE)
			visible_message("<span class='danger'>[M] pulls [src] off!</span>", \
				"<span class='danger'>You pull [src] off!</span>")
			return
		attacked += 5
		if(nutrition >= 100) //steal some nutrition. negval handled in life()
			adjust_nutrition(-(50 + (40 * M.is_adult)))
			M.add_nutrition(50 + (40 * M.is_adult))
		if(health > 0)
			M.adjustBruteLoss(-10 + (-10 * M.is_adult))
			M.updatehealth()

/mob/living/simple_animal/slime/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		attacked += 10


/mob/living/simple_animal/slime/attack_paw(mob/living/carbon/monkey/M)
	if(..()) //successful monkey bite.
		attacked += 10

/mob/living/simple_animal/slime/attack_larva(mob/living/carbon/alien/larva/L)
	if(..()) //successful larva bite.
		attacked += 10

/mob/living/simple_animal/slime/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	discipline_slime(user)

/mob/living/simple_animal/slime/attack_hand(mob/living/carbon/human/M)
	if(buckled)
		M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
		if(buckled == M)
			if(prob(60))
				M.visible_message("<span class='warning'>[M] attempts to wrestle \the [name] off!</span>", \
					"<span class='danger'>You attempt to wrestle \the [name] off!</span>")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)

			else
				M.visible_message("<span class='warning'>[M] manages to wrestle \the [name] off!</span>", \
					"<span class='notice'>You manage to wrestle \the [name] off!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

				discipline_slime(M)

		else
			if(prob(30))
				buckled.visible_message("<span class='warning'>[M] attempts to wrestle \the [name] off of [buckled]!</span>", \
					"<span class='warning'>[M] attempts to wrestle \the [name] off of you!</span>")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)

			else
				buckled.visible_message("<span class='warning'>[M] manages to wrestle \the [name] off of [buckled]!</span>", \
					"<span class='notice'>[M] manage to wrestle \the [name] off of you!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

				discipline_slime(M)
	else
		if(stat == DEAD && surgeries.len)
			if(M.a_intent == INTENT_HELP || M.a_intent == INTENT_DISARM)
				for(var/datum/surgery/S in surgeries)
					if(S.next_step(M,M.a_intent))
						return 1
		if(..()) //successful attack
			attacked += 10

/mob/living/simple_animal/slime/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(..()) //if harm or disarm intent.
		attacked += 10
		discipline_slime(M)


/mob/living/simple_animal/slime/attackby(obj/item/W, mob/living/user, params)
	if(stat == DEAD && surgeries.len)
		if(user.a_intent == INTENT_HELP || user.a_intent == INTENT_DISARM)
			for(var/datum/surgery/S in surgeries)
				if(S.next_step(user,user.a_intent))
					return 1
	if(istype(W, /obj/item/stack/sheet/mineral/plasma) && !stat) //Let's you feed slimes plasma.
		if (user in Friends)
			++Friends[user]
		else
			Friends[user] = 1
		to_chat(user, "<span class='notice'>You feed the slime the plasma. It chirps happily.</span>")
		var/obj/item/stack/sheet/mineral/plasma/S = W
		S.use(1)
		return
	if(W.force > 0)
		attacked += 10
		if(prob(25))
			user.do_attack_animation(src)
			user.changeNext_move(CLICK_CD_MELEE)
			to_chat(user, "<span class='danger'>[W] passes right through [src]!</span>")
			return
		if(Discipline && prob(50)) // wow, buddy, why am I getting attacked??
			Discipline = 0
	if(W.force >= 3)
		var/force_effect = 2 * W.force
		if(is_adult)
			force_effect = round(W.force/2)
		if(prob(10 + force_effect))
			discipline_slime(user)
	if(istype(W, /obj/item/storage/bag/bio))
		var/obj/item/storage/P = W
		if(!effectmod)
			to_chat(user, "<span class='warning'>The slime is not currently being mutated.</span>")
			return
		var/hasOutput = FALSE //Have we outputted text?
		var/hasFound = FALSE //Have we found an extract to be added?
		for(var/obj/item/slime_extract/S in P.contents)
			if(S.effectmod == effectmod)
				SEND_SIGNAL(P, COMSIG_TRY_STORAGE_TAKE, S, get_turf(src), TRUE)
				qdel(S)
				applied++
				hasFound = TRUE
			if(applied >= SLIME_EXTRACT_CROSSING_REQUIRED)
				to_chat(user, "<span class='notice'>You feed the slime as many of the extracts from the bag as you can, and it mutates!</span>")
				playsound(src, 'sound/effects/attackblob.ogg', 50, TRUE)
				spawn_corecross()
				hasOutput = TRUE
				break
		if(!hasOutput)
			if(!hasFound)
				to_chat(user, "<span class='warning'>There are no extracts in the bag that this slime will accept!</span>")
			else
				to_chat(user, "<span class='notice'>You feed the slime some extracts from the bag.</span>")
				playsound(src, 'sound/effects/attackblob.ogg', 50, TRUE)
		return
	..()

/mob/living/simple_animal/slime/proc/spawn_corecross()
	var/static/list/crossbreeds = subtypesof(/obj/item/slimecross)
	visible_message("<span class='danger'>[src] shudders, its mutated core consuming the rest of its body!</span>")
	playsound(src, 'sound/magic/smoke.ogg', 50, TRUE)
	var/crosspath
	for(var/X in crossbreeds)
		var/obj/item/slimecross/S = X
		if(initial(S.colour) == colour && initial(S.effect) == effectmod)
			crosspath = S
			break
	if(crosspath)
		new crosspath(loc)
	else
		visible_message("<span class='warning'>The mutated core shudders, and collapses into a puddle, unable to maintain its form.</span>")
	qdel(src)

/mob/living/simple_animal/slime/proc/apply_water()
	if (!(transformeffects & SLIME_EFFECT_DARK_BLUE))
		adjustBruteLoss(rand(15,20))
		if(!client)
			if(Target) // Like cats
				Target = null
				++Discipline
	return

/mob/living/simple_animal/slime/examine(mob/user)
	. = list("<span class='info'>*---------*\nThis is [icon2html(src, user)] \a <EM>[src]</EM>!")
	if (stat == DEAD)
		. += "<span class='deadsay'>It is limp and unresponsive.</span>"
	else
		if (stat == UNCONSCIOUS || stat == HARD_CRIT) // Slime stasis
			. += "<span class='deadsay'>It appears to be alive but unresponsive.</span>"
		if (getBruteLoss())
			. += "<span class='warning'>"
			if (getBruteLoss() < 40)
				. += "It has some punctures in its flesh!"
			else
				. += "<B>It has severe punctures and tears in its flesh!</B>"
			. += "</span>\n"

		switch(powerlevel)
			if(2 to 3)
				. += "It is flickering gently with a little electrical activity."

			if(4 to 5)
				. += "It is glowing gently with moderate levels of electrical activity."

			if(6 to 9)
				. += "<span class='warning'>It is glowing brightly with high levels of electrical activity.</span>"

			if(10)
				. += "<span class='warning'><B>It is radiating with massive levels of electrical activity!</B></span>"

	. += "*---------*</span>"

/mob/living/simple_animal/slime/proc/discipline_slime(mob/user)
	if(stat)
		return

	if(prob(80) && !client)
		Discipline++

		if(!is_adult)
			if(Discipline == 1)
				attacked = 0

	if(Target)
		Target = null
	if(buckled)
		Feedstop(silent = TRUE) //we unbuckle the slime from the mob it latched onto.

	SStun = world.time + rand(20,60)

	Stun(3)
	if(user)
		step_away(src,user,15)

	addtimer(CALLBACK(src, .proc/slime_move, user), 0.3 SECONDS)


/mob/living/simple_animal/slime/proc/slime_move(mob/user)
	if(user)
		step_away(src,user,15)


/mob/living/simple_animal/slime/pet
	docile = 1

/mob/living/simple_animal/slime/get_mob_buckling_height(mob/seat)
	if(..())
		return 3

/mob/living/simple_animal/slime/can_be_implanted()
	return TRUE

/mob/living/simple_animal/slime/random/Initialize(mapload, new_colour, new_is_adult)
	. = ..(mapload, pick(slime_colours), prob(50))

/mob/living/simple_animal/slime/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SLIME, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/slime/attack_ghost(mob/user)
	. = ..()
	if(. || !(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER))
		return
	if (transformeffects & SLIME_EFFECT_RAINBOW)
		humanize_slime(user)

/mob/living/simple_animal/slime/proc/humanize_slime(mob/user)
	if(key || stat)
		return
	var/slime_ask = alert("Become a slime?", "Slime time?", "Yes", "No")
	if(slime_ask == "No" || QDELETED(src))
		return
	if(key)
		to_chat(user, "<span class='warning'>Someone else already took this slime!</span>")
		return
	key = user.key
	log_game("[key_name(src)] took control of [name].")
