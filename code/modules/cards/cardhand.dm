/obj/item/toy/cards/cardhand
	name = "hand of cards"
	desc = "A number of cards not in a deck, customarily held in ones hand."
	icon = 'icons/obj/playing_cards.dmi'
	icon_state = "none"
	w_class = WEIGHT_CLASS_TINY
	worn_icon_state = "card"

/obj/item/toy/cards/cardhand/Initialize(mapload, list/cards_to_combine)
	. = ..()
 
	if(!LAZYLEN(cards_to_combine))
		CRASH("[src] is being made into a cardhand without a list of cards to combine")

/** I haven't decided if I want to make it possible to mapload cardhands (meh)

	if(mapload && LAZYLEN(cards)) // these cards have not been initialized 
		for(var/card_name in cards)
			var/obj/item/toy/singlecard/new_card = new (loc, card_name)
			new_card.update_appearance()
			cards_to_combine += new_card		
		cards = list() // reset our cards to an empty list
**/
	if(LAZYLEN(cards_to_combine)) // these cards are already initialized
		for(var/obj/item/toy/singlecard/new_card in cards_to_combine)
			new_card.forceMove(src)
			cards += new_card
	update_appearance()

/obj/item/toy/cards/cardhand/Destroy()
	if(LAZYLEN(cards))
		QDEL_LIST(cards)
	return ..()

/obj/item/toy/cards/cardhand/attack_self(mob/living/user)
	if(!isliving(user) || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, NO_TK))
		return

	var/list/handradial = list()
	for(var/obj/item/toy/singlecard/card in cards)
		handradial[card] = image(icon = src.icon, icon_state = card.icon_state)

	var/obj/item/toy/singlecard/choice = show_radial_menu(usr, src, handradial, custom_check = CALLBACK(src, .proc/check_menu, user), radius = 36, require_near = TRUE)
	if(!choice)
		return FALSE

	var/obj/item/toy/singlecard/selected_card = draw(user, choice)
	selected_card.pickup(user)
	user.put_in_hands(selected_card)
	update_appearance()

	if(length(cards) == 1)
		user.temporarilyRemoveItemFromInventory(src, TRUE)
		var/obj/item/toy/singlecard/last_card = draw(user)
		last_card.pickup(user)
		user.put_in_hands(last_card)
		qdel(src) // cardhand is empty now so delete it

/obj/item/toy/cards/cardhand/attackby(obj/item/weapon, mob/living/user, params)
	var/cards_to_add = list()

	if(istype(weapon, /obj/item/toy/singlecard))
		var/obj/item/toy/singlecard/card = weapon
		cards_to_add += card

	if(istype(weapon, /obj/item/toy/cards/deck))
		var/obj/item/toy/cards/deck/dealer_deck = weapon
		if(dealer_deck.wielded) 
			var/obj/item/toy/singlecard/card = dealer_deck.draw(user)
			cards_to_add += card
		else // recycle cards back into deck
			dealer_deck.insert(cards)
			qdel(src)
			user.balloon_alert_to_viewers("puts cards in deck", vision_distance = COMBAT_MESSAGE_RANGE)
			return

	if(LAZYLEN(cards_to_add))
		insert(cards_to_add)
		return

	return ..()

/obj/item/toy/cards/cardhand/proc/check_menu(mob/living/user)
	return isliving(user) && !user.incapacitated()

/obj/item/toy/cards/cardhand/update_overlays()
	. = ..()
	cut_overlays()
	for(var/i in 1 to cards.len)
		var/obj/item/toy/singlecard/card = cards[i]
		var/card_overlay = image(icon, icon_state = card.icon_state, pixel_x = (i - 1) * 3, pixel_y = (i - 1) * 3)
		add_overlay(card_overlay)
