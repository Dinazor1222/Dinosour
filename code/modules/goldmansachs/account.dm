GLOBAL_LIST_EMPTY(bank_accounts)
GLOBAL_LIST_EMPTY(department_accounts)

/datum/bank_account
	var/account_holder = "Rusty Venture"
	var/account_balance = 0
	var/datum/job/account_job
	var/list/bank_cards = list()
	var/add_to_accounts = TRUE
	var/account_id

/datum/bank_account/New()
	..()
	if(add_to_accounts)
		GLOB.bank_accounts += src

/datum/bank_account/Destroy()
	if(add_to_accounts)
		GLOB.bank_accounts -= src
	..()

/datum/bank_account/proc/_adjust_money(amt)
	account_balance += amt
	if(account_balance < 0)
		account_balance = 0

/datum/bank_account/proc/has_money(amt)
	return account_balance >= amt

/datum/bank_account/proc/adjust_money(amt)
	if((amt < 0 && has_money((amt * -1))) || amt > 0)
		_adjust_money(amt)
		return TRUE
	return FALSE

/datum/bank_account/proc/transfer_money(datum/bank_account/from, amount)
	if(from.has_money(amount))
		adjust_money(amount)
		from.adjust_money(-1 * amount)
		return TRUE
	return FALSE

/datum/bank_account/proc/i_need_my_payday_too(amt_of_paychecks, free = FALSE)
	if(free)
		adjust_money(account_job.paycheck * amt_of_paychecks)
	else
		var/datum/bank_account/D = SSgoldmansachs.get_dep_account(account_job.paycheck_department)
		if(D)
			if(!transfer_money(D, account_job.paycheck * amt_of_paychecks))
				bank_card_talk("ERROR: Payday aborted, departmental funds insufficient.")
				return FALSE
			else
				bank_card_talk("Payday processed, account now holds $[account_balance].")
				return TRUE
	bank_card_talk("ERROR: Payday aborted, unable to contact departmental account.")
	return FALSE

/datum/bank_account/proc/bank_card_talk(fuck)
	if(!fuck || !bank_cards.len)
		return
	for(var/obj/A in bank_cards)
		for(var/mob/M in hearers(1,get_turf(A)))
			to_chat(M, fuck)

/datum/bank_account/department
	account_holder = "Guild Credit Agency"
	var/department_id = "REPLACE_ME"
	add_to_accounts = FALSE