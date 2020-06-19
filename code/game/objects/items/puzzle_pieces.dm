//**************
//*****Keys*******************
//**************		**  **
/obj/item/keycard
	name = "security keycard"
	desc = "This feels like it belongs to a door."
	icon = 'icons/obj/puzzle_small.dmi'
	icon_state = "keycard"
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 7
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	var/puzzle_id = null

//Two test keys for use alongside the two test doors.
/obj/item/keycard/cheese
	name = "cheese keycard"
	desc = "Look, I still don't understand the reference. What the heck is a keyzza?"
	color = "#f0da12"
	puzzle_id = "cheese"

/obj/item/keycard/swordfish
	name = "titanic keycard"
	desc = "Smells like it was at the bottom of a harbor."
	color = "#3bbbdb"
	puzzle_id = "swordfish"

/obj/item/keycard/jungle
	name = "Lizard's Eye"
	desc = "A small hexagonal chunk of stone. It's inscribed with a strange rune, and it's glowing gently."
	icon_state = "lizard_eye"
	puzzle_id = "jungletemple"

/obj/item/keycard/jungle/warrior
	name = "Lizard's Courage"
	desc = "A small hexagonal chunk of stone. It's inscribed with a strange rune, and it's glowing gently."
	puzzle_id = "junglewarrior"

/obj/item/keycard/jungle/ranger
	name = "Lizard's Precision"
	desc = "A small hexagonal chunk of stone. It's inscribed with a strange rune, and it's glowing gently."
	puzzle_id = "jungleranger"

/obj/item/keycard/jungle/mage
	name = "Lizard's Wisdom"
	desc = "A small hexagonal chunk of stone. It's inscribed with a strange rune, and it's glowing gently."
	puzzle_id = "junglemage"

/obj/item/keycard/jungle/summoner
	name = "Lizard's Leadership"
	desc = "A small hexagonal chunk of stone. It's inscribed with a strange rune, and it's glowing gently."
	puzzle_id = "junglesummoner"

//***************
//*****Doors*****
//***************

/obj/machinery/door/keycard
	name = "locked door"
	desc = "This door only opens when a keycard is swiped. It looks virtually indestructable."
	icon = 'icons/obj/doors/puzzledoor/default.dmi'
	icon_state = "door_closed"
	explosion_block = 3
	heat_proof = TRUE
	max_integrity = 600
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	damage_deflection = 70
	/// Make sure that the key has the same puzzle_id as the keycard door!
	var/puzzle_id = null
	/// Message that occurs when the door is opened
	var/open_message = "The door beeps, and slides opens."

//Standard Expressions to make keycard doors basically un-cheeseable
/obj/machinery/door/keycard/Bumped(atom/movable/AM)
	return !density && ..()

/obj/machinery/door/keycard/emp_act(severity)
	return

/obj/machinery/door/keycard/ex_act(severity, target)
	return

/obj/machinery/door/keycard/try_to_activate_door(mob/user)
	add_fingerprint(user)
	if(operating)
		return

/obj/machinery/door/keycard/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I,/obj/item/keycard))
		var/obj/item/keycard/key = I
		if((!puzzle_id || puzzle_id == key.puzzle_id)  && density)
			if(open_message)
				to_chat(user, "<span class='notice'>[open_message]</span>")
			open()
			return
		else if(puzzle_id != key.puzzle_id)
			to_chat(user, "<span class='notice'>[src] buzzes. This must not be the right key.</span>")
			return
		else
			to_chat(user, "<span class='notice'>This door doesn't appear to close.</span>")
			return

//Test doors. Gives admins a few doors to use quickly should they so choose.
/obj/machinery/door/keycard/cheese
	name = "blue airlock"
	desc = "Smells like... pizza?"
	puzzle_id = "cheese"

/obj/machinery/door/keycard/swordfish
	name = "blue airlock"
	desc = "If nautical nonsense be something you wish."
	puzzle_id = "swordfish"

/obj/machinery/door/keycard/jungle
	name = "Sun Gate"
	desc = "It's engraved with strange runes and glyphs. A large carving of a gecko takes up most of the centre, and there's a hexagonal indent where its eye should be."
	puzzle_id = "jungletemple"
	icon = 'icons/effects/96x96.dmi'
	open_message = "The stone flashes briefly, and the door slides open with a rumble."

/obj/machinery/door/keycard/jungle/warrior
	name = "Courage Gate"
	desc = "It's engraved with strange runes and glyphs. A large carving of a gecko takes up most of the centre, and there's a hexagonal indent where its heart should be."
	puzzle_id = "junglewarrior"

/obj/machinery/door/keycard/jungle/ranger
	name = "Precision Gate"
	desc = "It's engraved with strange runes and glyphs. A large carving of a gecko takes up most of the centre, and there's a hexagonal indent where its eye should be."
	puzzle_id = "jungleranger"

/obj/machinery/door/keycard/jungle/mage
	name = "Wisdom Gate"
	desc = "It's engraved with strange runes and glyphs. A large carving of a gecko takes up most of the centre, and there's a hexagonal indent where its brain should be."
	puzzle_id = "junglemage"

/obj/machinery/door/keycard/jungle/summoner
	name = "Leadership Gate"
	desc = "It's engraved with strange runes and glyphs. A large carving of a gecko takes up most of the centre, and there's a hexagonal indent where its hand should be."
	puzzle_id = "junglesummoner"

//*************************
//***Box Pushing Puzzles***
//*************************
//We're working off a subtype of pressureplates, which should work just a BIT better now.
/obj/structure/holobox
	name = "holobox"
	desc = "A hard-light box, containing a secure decryption key."
	icon = 'icons/obj/puzzle_small.dmi'
	icon_state = "laserbox"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF

/obj/structure/holobox/statue
	name = "broken statue"
	desc = "Oh god oh fuck you shouldn't see this oh fuck"

/obj/structure/holobox/statue/warrior
	name = "statue of a brave warrior"
	desc = "A statue of a lizard warrior, clad in imposing armour and armed with a sword and shield. Its chest glows dully."
	icon_state = "warrior_statue"

/obj/structure/holobox/statue/ranger
	name = "statue of a precise ranger"
	desc = "A statue of a lizard ranger, clad in imposing armour and armed with a bow and arrow. Its eye glows dully."
	icon_state = "ranger_statue"

/obj/structure/holobox/statue/mage
	name = "statue of a wise mage"
	desc = "A statue of a lizard mage, clad in imposing armour and armed with a staff. Its head glows dully."
	icon_state = "mage_statue"

/obj/structure/holobox/statue/summoner
	name = "statue of an inspiring summoner"
	desc = "A statue of a lizard summoner, clad in imposing armour and armed with a whip and staff. Its hand glows dully."
	icon_state = "summoner_statue"

//Uses the pressure_plate settings for a pretty basic custom pattern that waits for a specific item to trigger. Easy enough to retool for mapping purposes or subtypes.
/obj/item/pressure_plate/hologrid
	name = "hologrid"
	desc = "A high power, electronic input port for a holobox, which can unlock the hologrid's storage compartment. Safe to stand on."
	icon = 'icons/obj/puzzle_small.dmi'
	icon_state = "lasergrid"
	anchored = TRUE
	trigger_mob = FALSE
	trigger_item = TRUE
	specific_item = /obj/structure/holobox
	removable_signaller = FALSE //Being a pressure plate subtype, this can also use signals.
	roundstart_signaller_freq = FREQ_HOLOGRID_SOLUTION //Frequency is kept on it's own default channel however.
	active = TRUE
	trigger_delay = 10
	protected = TRUE
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	var/reward = /obj/item/reagent_containers/food/snacks/cookie
	var/claimed = FALSE

/obj/item/pressure_plate/hologrid/Initialize()
	. = ..()

	AddElement(/datum/element/undertile, tile_overlay = tile_overlay) //we remove use_anchor here, so it ALWAYS stays anchored

/obj/item/pressure_plate/hologrid/examine(mob/user)
	. = ..()
	if(claimed)
		. += "<span class='notice'>This one appears to be spent already.</span>"

/obj/item/pressure_plate/hologrid/trigger()
	if(!claimed)
		new reward(loc)
	flick("lasergrid_a",src)
	icon_state = "lasergrid_full"
	claimed = TRUE

/obj/item/pressure_plate/hologrid/Crossed(atom/movable/AM)
	. = ..()
	if(trigger_item && istype(AM, specific_item) && !claimed)
		AM.anchored = TRUE
		flick("laserbox_burn", AM)
		trigger()
		sleep(15)
		qdel(AM)

/obj/item/pressure_plate/hologrid/jungle
	name = "statue plinth"
	desc = "A glowing stone slab, waiting to accept a statue. But which one is correct...?"
	icon_state = "lasergrid_jungle"
	specific_item = /obj/structure/holobox/statue/warrior
	reward = /obj/item/keycard/jungle/warrior

/obj/item/pressure_plate/hologrid/jungle/ranger
	specific_item = /obj/structure/holobox/statue/ranger
	reward = /obj/item/keycard/jungle/ranger

/obj/item/pressure_plate/hologrid/jungle/mage
	specific_item = /obj/structure/holobox/statue/mage
	reward = /obj/item/keycard/jungle/mage

/obj/item/pressure_plate/hologrid/jungle/summoner
	specific_item = /obj/structure/holobox/statue/summoner
	reward = /obj/item/keycard/jungle/summoner

/obj/item/pressure_plate/hologrid/jungle/Crossed(atom/movable/AM)
	. = ..()
	if(trigger_item && istype(AM, specific_item) && !claimed)
		AM.anchored = TRUE
		trigger()
		sleep(15)
