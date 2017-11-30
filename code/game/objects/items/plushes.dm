/obj/item/toy/plush
	name = "plush"
	desc = "This is the special coder plush, do not steal."
	icon = 'icons/obj/plushes.dmi'
	icon_state = "debug"
	attack_verb = list("thumped", "whomped", "bumped")
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	var/list/squeak_override //Weighted list; If you want your plush to have different squeak sounds use this
	var/stuffed = TRUE //If the plushie has stuffing in it
	var/obj/item/grenade/grenade //You can remove the stuffing from a plushie and add a grenade to it for *nefarious uses*
	//--love ~<3--
	var/male_chance = 1
	var/female_chance = 1
	var/obj/item/toy/plush/lover
	var/obj/item/toy/plush/partner
	var/obj/item/toy/plush/plush_child
	var/obj/item/toy/plush/paternal_parent	//who initiated creation
	var/obj/item/toy/plush/maternal_parent	//who owns, see love()
	var/list/scorned	//who the plush hates
	var/heartbroken = FALSE
	var/vowbroken = FALSE
	var/young = FALSE
	var/mood_message = null
	var/list/love_message
	var/list/heartbroken_message
	var/list/vowbroken_message
	var/list/child_message
	var/normal_desc
	//--end of love :'(--

/obj/item/toy/plush/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, squeak_override)

/obj/item/toy/plush/New()
	//time to assume Pinocchio's gender
	if(male_chance + female_chance <= 0)	//if neither genders are present
		gender = NEUTER
	else if(male_chance <=0)	//if cannot be male
		gender = FEMALE
	else if(female_chance <= 0)	//if cannot be female
		gender = MALE
	else if(rand(0, (male_chance+female_chance)) > male_chance)	//if a random number from 0 to total of both chances > one chance (here it's male)...
		gender = FEMALE	//... gender will be female (since the check is "not male")
	else	//... else the number landed on the other chance
		gender = MALE

	normal_desc = desc

	love_message += ("\n\The [src] is so happy, \he could rip a seam!")
	heartbroken_message += ("\n\The [src] looks so sad.")
	vowbroken_message += ("\n\The [src] lost \his ring...")
	child_message += ("\n\The [src] can't remember what sleep is.")

	return ..()

/obj/item/toy/plush/Destroy()
	QDEL_NULL(grenade)
	return ..()

/obj/item/toy/plush/handle_atom_del(atom/A)
	if(A == grenade)
		grenade = null
	..()

/obj/item/toy/plush/attack_self(mob/user)
	. = ..()
	if(stuffed || grenade)
		to_chat(user, "<span class='notice'>You pet [src]. D'awww.</span>")
		if(grenade && !grenade.active)
			if(istype(grenade, /obj/item/grenade/chem_grenade))
				var/obj/item/grenade/chem_grenade/G = grenade
				if(G.nadeassembly) //We're activated through different methods
					return
			log_game("[key_name(user)] activated a hidden grenade in [src].")
			grenade.preprime(user, msg = FALSE, volume = 10)
	else
		to_chat(user, "<span class='notice'>You try to pet [src], but it has no stuffing. Aww...</span>")

/obj/item/toy/plush/attackby(obj/item/I, mob/living/user, params)
	if(I.is_sharp())
		if(!grenade)
			if(!stuffed)
				to_chat(user, "<span class='warning'>You already murdered it!</span>")
				return
			user.visible_message("<span class='notice'>[user] tears out the stuffing from [src]!</span>", "<span class='notice'>You rip a bunch of the stuffing from [src]. Murderer.</span>")
			playsound(I, I.usesound, 50, TRUE)
			stuffed = FALSE
		else
			to_chat(user, "<span class='notice'>You remove the grenade from [src].</span>")
			user.put_in_hands(grenade)
			grenade = null
		return
	if(istype(I, /obj/item/grenade))
		if(stuffed)
			to_chat(user, "<span class='warning'>You need to remove some stuffing first!</span>")
			return
		if(grenade)
			to_chat(user, "<span class='warning'>[src] already has a grenade!</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		user.visible_message("<span class='warning'>[user] slides [grenade] into [src].</span>", \
		"<span class='danger'>You slide [I] into [src].</span>")
		grenade = I
		var/turf/T = get_turf(user)
		log_game("[key_name(user)] added a grenade ([I.name]) to [src] at [COORD(T)].")
		return
	if(istype(I, /obj/item/toy/plush))
		love(I, user)
		return
	return ..()

/obj/item/toy/plush/proc/love(obj/item/toy/plush/Kisser, mob/living/user)	//~<3
	var/chance = 100	//to steal a kiss, surely there's a 100% chance no-one would reject a plush such as I?
	var/concern = 20	//perhaps something might cloud true love with doubt
	var/loyalty = 30	//why should another get between us?
	var/duty = 50		//conquering another's is what I live for

	//we are not catholic
	if (young == TRUE || Kisser.young == TRUE)
		user.show_message("<span class='notice'>[src] plays tag with [Kisser].</span>", 1,
			"<span class='notice'>They're happy.</span>", 0)
	//never again
	else if(Kisser in scorned)
		//message, visible, alternate message, neither visible nor audible
		user.show_message("<span class='notice'>[src] rejects the advances of [Kisser]!</span>", 1,
			"<span class='notice'>That didn't feel like it worked.</span>", 0)
	else if(src in Kisser.scorned)
		user.show_message("<span class='notice'>[Kisser] realises who [src] is and turns away.</span>", 1,
			"<span class='notice'>That didn't feel like it worked.</span>", 0)

	//first comes love
	else if(Kisser.lover != src && Kisser.partner != src)	//cannot be lovers or married
		if(Kisser.lover)	//if the initiator has a lover
			Kisser.lover.heartbreak(Kisser)	//the old lover can get over the kiss-and-run whilst the kisser has some fun
			chance -= concern	//one heart already broken, what does another mean?
		if(lover)	//if the recipient has a lover
			chance -= loyalty	//mustn't... but those lips
		if(partner)	//if the recipient has a partner
			chance -= duty	//do we mate for life?

		if(prob(chance))	//did we bag a date?
			user.visible_message("<span class='notice'>[user] makes \the [Kisser] kiss \the [src]!</span>",
									"<span class='notice'>You make \the [Kisser] kiss \the [src]!</span>")
			if(lover)	//who cares for the past, we live in the present
				lover.heartbreak(src)
			new_lover(Kisser)
			Kisser.new_lover(src)
		else
			user.show_message("<span class='notice'>[src] rejects the advances of [Kisser], maybe next time?</span>", 1,
								"<span class='notice'>That didn't feel like it worked, this time.</span>", 0)

	//then comes marriage
	else if(Kisser.lover == src && Kisser.partner != src)	//need to be lovers (assumes loving is a two way street) but not married (also assumes similar)
		user.visible_message("<span class='notice'>[user] pronounces \the [Kisser] and \the [src] married! D'aw.</span>",
									"<span class='notice'>You pronounce \the [Kisser] and \the [src] married!</span>")
		new_partner(Kisser)
		Kisser.new_partner(src)

	//then comes a baby in a baby's carriage, or an adoption in an adoption's orphanage
	else if(Kisser.partner == src && !src.plush_child)	//the one advancing does not take ownership of the child and we have a one child policy in the toyshop
		user.visible_message("<span class='notice'>[user] is going to break \the [Kisser] and \the [src] by bashing them like that.</span>",
									"<span class='notice'>\The [Kisser] passionately embraces \the [src] in your hands. Look away you perv!</span>")
		plop(Kisser)
		user.visible_message("<span class='notice'>Something drops at the feet of [user].</span>",
							"<span class='notice'>The miracle of oh god did that just come out of \the [src]?!</span>")

	//then comes protection, or abstinence if we are catholic
	else if(Kisser.partner == src && src.plush_child)
		user.visible_message("<span class='notice'>[user] makes \the [Kisser] nuzzle \the [src]!</span>",
									"<span class='notice'>You make \the [Kisser] nuzzle \the [src]!</span>")

	//then oh fuck something unexpected happened
	else
		user.show_message("<span class='warning'>\The [Kisser] and \the [src] don't know what to do with one another.</span>", 0)

/obj/item/toy/plush/proc/heartbreak(obj/item/toy/plush/Brutus)
	if(lover != Brutus)
		return	//why are we considering someone we don't love?

	scorned += Brutus
	lover = null
	Brutus.lover = null	//feeling's mutual
	heartbroken = TRUE
	mood_message = heartbroken_message

	if(partner == Brutus)	//oh dear...
		partner = null
		Brutus.partner = null	//it'd be weird otherwise
		vowbroken = TRUE
		mood_message = vowbroken_message

	update_desc()

/obj/item/toy/plush/proc/new_lover(obj/item/toy/plush/Juliet)
	if(lover == Juliet)
		return	//nice try
	lover = Juliet
	mood_message = love_message
	update_desc()

	if(partner)	//who?
		partner = null	//more like who cares

/obj/item/toy/plush/proc/new_partner(obj/item/toy/plush/Apple_of_my_eye)
	if(partner == Apple_of_my_eye)
		return	//double marriage is just insecurity
	if(lover != Apple_of_my_eye)
		return	//union not born out of love will falter

	partner = Apple_of_my_eye
	mood_message = "\n\The [src] has a ring on \his finger! It says bound to my dear [partner]."
	update_desc()

/obj/item/toy/plush/proc/plop(obj/item/toy/plush/Daddy)
	if(partner != Daddy)
		return	//we do not have bastards in our toyshop

	if(prob(50))	//it has my eyes
		plush_child = new type(get_turf(loc))
	else	//it has your eyes
		plush_child = new Daddy.type(get_turf(loc))

	plush_child.make_young(src, Daddy)
	Daddy.mood_message = Daddy.child_message
	Daddy.update_desc()
	mood_message = child_message
	update_desc()

/obj/item/toy/plush/proc/make_young(obj/item/toy/plush/Mama, obj/item/toy/plush/Dada)
	if(Mama == Dada)
		return	//cloning is reserved for plants and spacemen
	else
		maternal_parent = Mama
		paternal_parent = Dada
		young = TRUE
		mood_message = "\n\The [src] is a little baby of [maternal_parent] and [paternal_parent]!"
		update_desc()

/obj/item/toy/plush/proc/update_desc()
	if(mood_message)
		desc = normal_desc
		desc += mood_message

/obj/item/toy/plush/carpplushie
	name = "space carp plushie"
	desc = "An adorable stuffed toy that resembles a space carp."
	icon_state = "carpplush"
	item_state = "carp_plushie"
	attack_verb = list("bitten", "eaten", "fin slapped")
	squeak_override = list('sound/weapons/bite.ogg'=1)

/obj/item/toy/plush/bubbleplush
	name = "bubblegum plushie"
	desc = "The friendly red demon that gives good miners gifts."
	icon_state = "bubbleplush"
	attack_verb = list("rends")
	squeak_override = list('sound/magic/demon_attack1.ogg'=1)

/obj/item/toy/plush/plushvar
	name = "ratvar plushie"
	desc = "An adorable plushie of the clockwork justiciar himself with new and improved spring arm action."
	icon_state = "plushvar"
	var/obj/item/toy/plush/narplush/clash_target
	male_chance = 1	//he's a boy, right?
	female_chance = 0

/obj/item/toy/plush/plushvar/Moved()
	. = ..()
	if(clash_target)
		return
	var/obj/item/toy/plush/narplush/P = locate() in range(1, src)
	if(P && istype(P.loc, /turf/open) && !P.clashing)
		clash_of_the_plushies(P)

/obj/item/toy/plush/plushvar/proc/clash_of_the_plushies(obj/item/toy/plush/narplush/P)
	clash_target = P
	P.clashing = TRUE
	say("YOU.")
	P.say("Ratvar?!")
	var/obj/item/toy/plush/a_winnar_is
	var/victory_chance = 10
	for(var/i in 1 to 10) //We only fight ten times max
		if(QDELETED(src))
			P.clashing = FALSE
			return
		if(QDELETED(P))
			clash_target = null
			return
		if(!Adjacent(P))
			visible_message("<span class='warning'>The two plushies angrily flail at each other before giving up.</span>")
			clash_target = null
			P.clashing = FALSE
			return
		playsound(src, 'sound/magic/clockwork/ratvar_attack.ogg', 50, TRUE, frequency = 2)
		sleep(2.4)
		if(QDELETED(src))
			P.clashing = FALSE
			return
		if(QDELETED(P))
			clash_target = null
			return
		if(prob(victory_chance))
			a_winnar_is = src
			break
		P.SpinAnimation(5, 0)
		sleep(5)
		if(QDELETED(src))
			P.clashing = FALSE
			return
		if(QDELETED(P))
			clash_target = null
			return
		playsound(P, 'sound/magic/clockwork/narsie_attack.ogg', 50, TRUE, frequency = 2)
		sleep(3.3)
		if(QDELETED(src))
			P.clashing = FALSE
			return
		if(QDELETED(P))
			clash_target = null
			return
		if(prob(victory_chance))
			a_winnar_is = P
			break
		SpinAnimation(5, 0)
		victory_chance += 10
		sleep(5)
	if(!a_winnar_is)
		a_winnar_is = pick(src, P)
	if(a_winnar_is == src)
		say(pick("DIE.", "ROT."))
		P.say(pick("Nooooo...", "Not die. To y-", "Die. Ratv-", "Sas tyen re-"))
		playsound(src, 'sound/magic/clockwork/anima_fragment_attack.ogg', 50, TRUE, frequency = 2)
		playsound(P, 'sound/magic/demon_dies.ogg', 50, TRUE, frequency = 2)
		explosion(P, 0, 0, 1)
		qdel(P)
		clash_target = null
	else
		say("NO! I will not be banished again...")
		P.say(pick("Ha.", "Ra'sha fonn dest.", "You fool. To come here."))
		playsound(src, 'sound/magic/clockwork/anima_fragment_death.ogg', 50, TRUE, frequency = 2)
		playsound(P, 'sound/magic/demon_attack1.ogg', 50, TRUE, frequency = 2)
		explosion(src, 0, 0, 1)
		qdel(src)
		P.clashing = FALSE

/obj/item/toy/plush/narplush
	name = "nar'sie plushie"
	desc = "A small stuffed doll of the elder god nar'sie. Who thought this was a good children's toy?"
	icon_state = "narplush"
	var/clashing
	male_chance = 0
	female_chance = 1	//I guess it's canon

/obj/item/toy/plush/narplush/Moved()
	. = ..()
	var/obj/item/toy/plush/plushvar/P = locate() in range(1, src)
	if(P && istype(P.loc, /turf/open) && !P.clash_target && !clashing)
		P.clash_of_the_plushies(src)

/obj/item/toy/plush/lizardplushie
	name = "lizard plushie"
	desc = "An adorable stuffed toy that resembles a lizardperson."
	icon_state = "plushie_lizard"
	item_state = "plushie_lizard"
	attack_verb = list("clawed", "hissed", "tail slapped")
	squeak_override = list('sound/weapons/slash.ogg' = 1)

/obj/item/toy/plush/snakeplushie
	name = "snake plushie"
	desc = "An adorable stuffed toy that resembles a snake. Not to be mistaken for the real thing."
	icon_state = "plushie_snake"
	item_state = "plushie_snake"
	attack_verb = list("bitten", "hissed", "tail slapped")
	squeak_override = list('sound/weapons/bite.ogg' = 1)

/obj/item/toy/plush/nukeplushie
	name = "operative plushie"
	desc = "A stuffed toy that resembles a syndicate nuclear operative. The tag claims operatives to be purely fictitious."
	icon_state = "plushie_nuke"
	item_state = "plushie_nuke"
	attack_verb = list("shot", "nuked", "detonated")
	squeak_override = list('sound/effects/hit_punch.ogg' = 1)
	male_chance = 9	//I'm holding out hope that I'll ever see a girl nuke op, isn't a hot date nothing compared to thermonuclear date?
	female_chance = 1

/obj/item/toy/plush/slimeplushie
	name = "slime plushie"
	desc = "An adorable stuffed toy that resembles a slime. It is practically just a hacky sack."
	icon_state = "plushie_slime"
	item_state = "plushie_slime"
	attack_verb = list("blorbled", "slimed", "absorbed")
	squeak_override = list('sound/effects/blobattack.ogg' = 1)
	male_chance = 0
	female_chance = 1	//given all the jokes and drawings, I'm not sure the xenobiologists would make a slimeboy