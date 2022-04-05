
/**
 * Handles simple payment operations where the cost of the object in question doesn't change.
 *
 * What this is useful for:
 * Basic forms of vending.
 * Objects that can drain the owner's money linearly.
 * What this is not useful for:
 * Things where the seller may want to fluxuate the price of the object.
 * Improving standardizing every form of payment handing, as some custom handling is specific to that object.
 **/
/datum/component/payment
	dupe_mode = COMPONENT_DUPE_UNIQUE ///NO OVERRIDING TO CHEESE BOUNTIES
	///Standardized of operation.
	var/cost = 10
	///Flavor style for handling cash (Friendly? Hostile? etc.)
	var/transaction_style = "Clinical"
	///Who's getting paid?
	var/datum/bank_account/target_acc
	///Does this payment component respect same-department-discount?
	var/department_discount = FALSE

/datum/component/payment/Initialize(_cost, _target, _style)
	target_acc = _target
	if(!target_acc)
		target_acc = SSeconomy.get_dep_account(ACCOUNT_CIV)
	cost = _cost
	transaction_style = _style
	RegisterSignal(parent, COMSIG_OBJ_ATTEMPT_CHARGE, .proc/attempt_charge)
	RegisterSignal(parent, COMSIG_OBJ_ATTEMPT_CHARGE_CHANGE, .proc/change_cost)

/datum/component/payment/proc/attempt_charge(datum/source, atom/movable/target, extra_fees = 0)
	SIGNAL_HANDLER
	if(!cost && !extra_fees) //In case a free variant of anything is made it'll skip charging anyone.
		return
	var/total_cost = cost + extra_fees
	if(!ismob(target))
		return COMPONENT_OBJ_CANCEL_CHARGE
	var/mob/living/user = target
	if(issilicon(user)) //They have evolved beyond the need for mere credits
		return
	var/obj/item/card/id/card
	if(istype(user))
		card = user.get_idcard(TRUE)
	if(!card && istype(user.pulling, /obj/item/card/id))
		card = user.pulling
	if(!card)
		if(handle_cardless(user, total_cost)) //Here we attempt to handle the purchase physically, with held money first. Otherwise we default to below.
			return
		switch(transaction_style)
			if(PAYMENT_FRIENDLY)
				to_chat(user, span_warning("ID not detected, sorry [user]!"))
			if(PAYMENT_ANGRY)
				to_chat(user, span_warning("WHERE IS YOUR GOD DAMN CARD! GOD DAMNIT!"))
			if(PAYMENT_CLINICAL)
				to_chat(user, span_warning("ID card not present. Aborting."))
		return COMPONENT_OBJ_CANCEL_CHARGE
	if(!card.registered_account)
		switch(transaction_style)
			if(PAYMENT_FRIENDLY)
				to_chat(user, span_warning("There's no account detected on your ID, how mysterious!"))
			if(PAYMENT_ANGRY)
				to_chat(user, span_warning("ARE YOU JOKING. YOU DON'T HAVE A BANK ACCOUNT ON YOUR ID YOU IDIOT."))
			if(PAYMENT_CLINICAL)
				to_chat(user, span_warning("ID Card lacks a bank account. Aborting."))
		return COMPONENT_OBJ_CANCEL_CHARGE

	if(!(card.registered_account.has_money(total_cost)))
		switch(transaction_style)
			if(PAYMENT_FRIENDLY)
				to_chat(user, span_warning("I'm so sorry... You don't seem to have enough money."))
			if(PAYMENT_ANGRY)
				to_chat(user, span_warning("YOU MORON. YOU ABSOLUTE BAFOON. YOU INSUFFERABLE TOOL. YOU ARE POOR."))
			if(PAYMENT_CLINICAL)
				to_chat(user, span_warning("ID Card lacks funds. Aborting."))
		user.balloon_alert(user, "Cost: [total_cost] credits.")
		return COMPONENT_OBJ_CANCEL_CHARGE
	target_acc.transfer_money(card.registered_account, total_cost)
	card.registered_account.bank_card_talk("[total_cost] credits deducted from your account.")
	playsound(src, 'sound/effects/cashregister.ogg', 20, TRUE)

/datum/component/payment/proc/change_cost(datum/source, new_cost)
	SIGNAL_HANDLER

	if(!isnum(new_cost))
		CRASH("change_cost called with variable new_cost as not a number.")
	cost = new_cost

/datum/component/payment/proc/handle_cardless(mob/living/user, total_cost)
	//Here is all the possible non-ID payment methods.
	var/list/counted_money = list()
	var/physical_cash_total = 0
	for(var/obj/item/coin/counted_coin in user.get_all_contents()) //Coins.
		if(physical_cash_total > total_cost)
			break
		physical_cash_total += counted_coin.value
		counted_money += counted_coin

	for(var/obj/item/stack/spacecash/counted_cash in user.get_all_contents()) //Paper Cash
		if(physical_cash_total > total_cost)
			break
		physical_cash_total += counted_cash.value * counted_cash.amount
		counted_money += counted_cash

	for(var/obj/item/holochip/counted_credits in user.get_all_contents()) //Holocredits
		if(physical_cash_total > total_cost)
			break
		physical_cash_total += counted_credits.credits
		counted_money += counted_credits

	if(istype(user.pulling, /obj/item/coin) && (physical_cash_total < total_cost)) //Coins(Pulled).
		var/obj/item/coin/counted_coin = user.pulling
		physical_cash_total += counted_coin.value
		counted_money += counted_coin

	else if(istype(user.pulling, /obj/item/stack/spacecash) && (physical_cash_total < total_cost)) //Cash(Pulled).
		var/obj/item/stack/spacecash/counted_cash = user.pulling
		physical_cash_total += counted_cash.value * counted_cash.amount
		counted_money += counted_cash

	else if(istype(user.pulling, /obj/item/holochip) && (physical_cash_total < total_cost)) //Holocredits(pulled).
		var/obj/item/holochip/counted_credits = user.pulling
		physical_cash_total += counted_credits.credits
		counted_money += counted_credits

	if(physical_cash_total < total_cost) //Suggestions for those with no arms/simple animals.
		var/armless
		if(!ishuman(user) && !istype(user, /mob/living/simple_animal/slime))
			armless = TRUE
		else
			var/mob/living/carbon/human/harmless_armless = user
			if(!harmless_armless.get_bodypart(BODY_ZONE_L_ARM) && !harmless_armless.get_bodypart(BODY_ZONE_R_ARM))
				armless = TRUE

		if(armless)
			if(!user.pulling || !iscash(user.pulling) && !istype(user.pulling, /obj/item/card/id))
				to_chat(user, span_notice("Try pulling a valid ID, space cash, holochip or coin while using \the [parent]!"))

	if(physical_cash_total >= total_cost)
		for(var/obj/cash_object in counted_money)
			qdel(cash_object)
		physical_cash_total -= total_cost

		if(physical_cash_total > 0)
			var/obj/item/holochip/holochange = new /obj/item/holochip(user.loc) //Change is made in holocredits exclusively.
			holochange.credits = physical_cash_total
			holochange.name = "[holochange.credits] credit holochip"
			if(istype(user, /mob/living/carbon/human))
				var/mob/living/carbon/human/paying_customer = user
				if(!paying_customer.put_in_hands(holochange))
					user.pulling = holochange
			else
				user.pulling = holochange
		to_chat(user, span_notice("Purchase completed with held credits."))
		playsound(user, 'sound/effects/cashregister.ogg', 20, TRUE)
		return TRUE
	return FALSE
