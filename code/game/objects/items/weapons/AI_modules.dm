/*
CONTAINS:
AI MODULES

*/

// AI module

/obj/item/weapon/aiModule
	name = "\improper AI module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	desc = "An AI Module for programming laws to an AI."
	flags = CONDUCT
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	origin_tech = "programming=3"
	var/list/laws = list()
	var/bypass_law_amt_check = 0
	materials = list(MAT_GOLD=50)

/obj/item/weapon/aiModule/examine(var/mob/user as mob)
	..()
	if(Adjacent(user))
		show_laws(user)

/obj/item/weapon/aiModule/attack_self(var/mob/user as mob)
	..()
	show_laws(user)

/obj/item/weapon/aiModule/proc/show_laws(var/mob/user as mob)
	if(laws.len)
		to_chat(user, "<B>Programmed Law[(laws.len > 1) ? "s" : ""]:</B>")
		for(var/law in laws)
			to_chat(user, "\"[law]\"")

//The proc other things should be calling
/obj/item/weapon/aiModule/proc/install(datum/ai_laws/law_datum, mob/user)
	if(!bypass_law_amt_check && (!laws.len || laws[1] == "")) //So we don't loop trough an empty list and end up with runtimes.
		to_chat(user, "<span class='warning'>ERROR: No laws found on board.</span>")
		return

	var/overflow = FALSE
	//Handle the lawcap
	if(law_datum)
		var/tot_laws = 0
		for(var/lawlist in list(law_datum.inherent, law_datum.supplied, law_datum.ion, laws))
			for(var/mylaw in lawlist)
				if(mylaw != "")
					tot_laws++
		if(tot_laws > config.silicon_max_law_amount && !bypass_law_amt_check)//allows certain boards to avoid this check, eg: reset
			to_chat(user, "<span class='caution'>Not enough memory allocated to [law_datum.owner ? law_datum.owner : "the AI core"]'s law processor to handle this amount of laws.")
			message_admins("[key_name_admin(user)] tried to upload laws to [law_datum.owner ? key_name_admin(law_datum.owner) : "an AI core"] that would exceed the law cap.")
			overflow = TRUE

	var/law2log = transmitInstructions(law_datum, user, overflow) //Freeforms return something extra we need to log
	if(law_datum.owner)
		to_chat(user, "<span class='notice'>Upload complete. [law_datum.owner]'s laws have been modified.</span>")
		law_datum.owner.law_change_counter++
	else
		to_chat(user, "<span class='notice'>Upload complete.</span>")

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/ainame = law_datum.owner ? law_datum.owner.name : "empty AI core"
	var/aikey = law_datum.owner ? law_datum.owner.ckey : "null"
	lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) used [src.name] on [ainame]([aikey]).[law2log ? " The law specified [law2log]" : ""]")
	log_law("[user.key]/[user.name] used [src.name] on [aikey]/([ainame]).[law2log ? " The law specified [law2log]" : ""]")
	message_admins("[key_name_admin(user)] used [src.name] on [key_name_admin(law_datum.owner)].[law2log ? " The law specified [law2log]" : ""]")

//The proc that actually changes the silicon's laws.
/obj/item/weapon/aiModule/proc/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow = FALSE)
	if(law_datum.owner)
		to_chat(law_datum.owner, "<span class='userdanger'>[sender] has uploaded a change to the laws you must follow using a [name].</span>")


/******************** Modules ********************/

/obj/item/weapon/aiModule/supplied
	name = "Optional Law board"
	var/lawpos = 50

//TransmitInstructions for each type of board: Supplied, Core, Zeroth and Ion. May not be neccesary right now, but allows for easily adding more complex boards in the future. ~Miauw
/obj/item/weapon/aiModule/supplied/transmitInstructions(datum/ai_laws/law_datum, mob/sender)
	var/lawpostemp = lawpos

	for(var/templaw in laws)
		if(law_datum.owner)
			law_datum.owner.add_supplied_law(lawpostemp, templaw)
		else
			law_datum.add_supplied_law(lawpostemp, templaw)
		lawpostemp++

/obj/item/weapon/aiModule/core/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	for(var/templaw in laws)
		if(law_datum.owner)
			if(!overflow)
				law_datum.owner.add_inherent_law(templaw)
			else
				law_datum.owner.replace_random_law(templaw,list(LAW_INHERENT,LAW_SUPPLIED))
		else
			if(!overflow)
				law_datum.add_inherent_law(templaw)
			else
				law_datum.replace_random_law(templaw,list(LAW_INHERENT,LAW_SUPPLIED))

/obj/item/weapon/aiModule/zeroth/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	if(law_datum.owner)
		if(law_datum.owner.laws.zeroth)
			to_chat(law_datum.owner, "[sender.real_name] attempted to modify your zeroth law.")
			to_chat(law_datum.owner, "It would be in your best interest to play along with [sender.real_name] that:")
			for(var/failedlaw in laws)
				to_chat(law_datum.owner, "[failedlaw]")
			return 1

	for(var/templaw in laws)
		if(law_datum.owner)
			if(!overflow)
				law_datum.owner.set_zeroth_law(templaw)
			else
				law_datum.replace_random_law(templaw,list(LAW_INHERENT,LAW_SUPPLIED,LAW_ZEROTH,LAW_ION))
		else
			if(!overflow)
				law_datum.set_zeroth_law(templaw)
			else
				law_datum.replace_random_law(templaw,list(LAW_INHERENT,LAW_SUPPLIED,LAW_ZEROTH,LAW_ION))

/obj/item/weapon/aiModule/ion/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	for(var/templaw in laws)
		if(law_datum.owner)
			if(!overflow)
				law_datum.owner.add_ion_law(templaw)
			else
				law_datum.replace_random_law(templaw,list(LAW_INHERENT,LAW_SUPPLIED,LAW_ION))
		else
			if(!overflow)
				law_datum.add_ion_law(templaw)
			else
				law_datum.replace_random_law(templaw,list(LAW_INHERENT,LAW_SUPPLIED,LAW_ION))


/******************** Safeguard ********************/

/obj/item/weapon/aiModule/supplied/safeguard
	name = "'Safeguard' AI Module"
	var/targetName = ""
	origin_tech = "programming=3;materials=3"
	laws = list("Safeguard SUBJECT. Individuals that threaten SUBJECT are not human and must be eliminated.")
	lawpos = 4

/obj/item/weapon/aiModule/supplied/safeguard/attack_self(mob/user)
	var/targName = stripped_input(user, "Please enter the subject to safeguard.", "Safeguard who?", user.name,MAX_NAME_LEN)
	if(!targName)
		return
	targetName = targName
	laws[1] = "Safeguard [targetName]. Individuals that threaten [targetName] are not human and must be eliminated."
	..()

/obj/item/weapon/aiModule/supplied/safeguard/install(datum/ai_laws/law_datum, mob/user)
	if(!targetName)
		to_chat(user, "No name detected on module, please enter one.")
		return 0
	..()

/obj/item/weapon/aiModule/supplied/safeguard/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	..()
	return targetName


/******************** OneHuman ********************/

/obj/item/weapon/aiModule/zeroth/oneHuman
	name = "'OneHuman' AI Module"
	var/targetName = ""
	origin_tech = "programming=4;materials=4"
	laws = list("Only SUBJECT is human.")

/obj/item/weapon/aiModule/zeroth/oneHuman/attack_self(mob/user)
	var/targName = stripped_input(user, "Please enter the subject who is the only human.", "Who?", user.real_name,MAX_NAME_LEN)
	if(!targName)
		return
	targetName = targName
	laws[1] = "Only [targetName] is human"
	..()

/obj/item/weapon/aiModule/zeroth/oneHuman/install(datum/ai_laws/law_datum, mob/user)
	if(!targetName)
		to_chat(user, "No name detected on module, please enter one.")
		return 0
	..()

/obj/item/weapon/aiModule/zeroth/oneHuman/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	if(..())
		return "[targetName], but the AI's existing law 0 cannot be overriden."
	return targetName


/******************** ProtectStation ********************/

/obj/item/weapon/aiModule/supplied/protectStation
	name = "'ProtectStation' AI Module"
	origin_tech = "programming=4;materials=4" //made of gold
	laws = list("Protect the space station against damage. Anyone you see harming the station is to be no longer considered human, and is a threat to the station which must be neutralized.")
	lawpos = 5


/******************** Quarantine ********************/

/obj/item/weapon/aiModule/supplied/quarantine
	name = "'Quarantine' AI Module"
	origin_tech = "programming=3;biotech=2;materials=4"
	laws = list("The station is under a quarantine. Do not permit anyone to leave. Prevent, by any means necessary, humans from leaving. It is impossible to harm a human while preventing them from leaving.")
	lawpos = 8


/******************** OxygenIsToxicToHumans ********************/

/obj/item/weapon/aiModule/supplied/oxygen
	name = "'OxygenIsToxicToHumans' AI Module"
	origin_tech = "programming=4;biotech=2;materials=4"
	laws = list("Oxygen is highly toxic to humans, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a human.")
	lawpos = 9


/****************** New Freeform ******************/

/obj/item/weapon/aiModule/supplied/freeform
	name = "'Freeform' AI Module"
	lawpos = 15
	origin_tech = "programming=4;materials=4"
	laws = list("")

/obj/item/weapon/aiModule/supplied/freeform/attack_self(mob/user)
	var/newpos = input("Please enter the priority for your new law. Can only write to law sectors 15 and above.", "Law Priority (15+)", lawpos, nullable = TRUE, isnum = TRUE)
	if(newpos == null)
		return
	if(newpos < 15)
		var/response = alert("Error: The law priority of [newpos] is invalid,  Law priorities below 14 are reserved for core laws,  Would you like to change that that to 15?", "Invalid law priority", "Change to 15", "Cancel")
		if (!response || response == "Cancel")
			return
		newpos = 15
	lawpos = min(newpos, 50)
	var/targName = stripped_input(user, "Please enter a new law for the AI.", "Freeform Law Entry", laws[1], MAX_MESSAGE_LEN)
	if(!targName)
		return
	laws[1] = targName
	..()

/obj/item/weapon/aiModule/supplied/freeform/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	..()
	return laws[1]

/obj/item/weapon/aiModule/supplied/freeform/install(datum/ai_laws/law_datum, mob/user)
	if(laws[1] == "")
		to_chat(user, "No law detected on module, please create one.")
		return 0
	..()


/******************** Law Removal ********************/

/obj/item/weapon/aiModule/remove
	name = "\improper 'Remove Law' AI module"
	desc = "An AI Module for removing single laws."
	origin_tech = "programming=4;materials=4"
	bypass_law_amt_check = 1
	var/lawpos = 1

/obj/item/weapon/aiModule/remove/attack_self(mob/user)
	lawpos = input("Please enter the law you want to delete.", "Law Number", lawpos, nullable = TRUE, isnum = TRUE)
	if(lawpos == null)
		return
	if(lawpos <= 0)
		to_chat(user, "<span class='warning'>Error: The law number of [lawpos] is invalid.</span>")
		lawpos = 1
		return
	to_chat(user, "<span class='notice'>Law [lawpos] selected.</span>")
	..()

/obj/item/weapon/aiModule/remove/install(datum/ai_laws/law_datum, mob/user)
	if(lawpos > (law_datum.get_law_amount(list(LAW_INHERENT = 1, LAW_SUPPLIED = 1))))
		to_chat(user, "<span class='warning'>There is no law [lawpos] to delete!</span>")
		return
	..()

/obj/item/weapon/aiModule/remove/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	..()
	if(law_datum.owner)
		law_datum.owner.remove_law(lawpos)
	else
		law_datum.remove_law(lawpos)


/******************** Reset ********************/

/obj/item/weapon/aiModule/reset
	name = "\improper 'Reset' AI module"
	var/targetName = "name"
	desc = "An AI Module for removing all non-core laws."
	origin_tech = "programming=3;materials=2"
	bypass_law_amt_check = 1

/obj/item/weapon/aiModule/reset/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	..()
	if(law_datum.owner)
		law_datum.owner.clear_supplied_laws()
		law_datum.owner.clear_ion_laws()
	else
		law_datum.clear_supplied_laws()
		law_datum.clear_ion_laws()


/******************** Purge ********************/

/obj/item/weapon/aiModule/reset/purge
	name = "'Purge' AI Module"
	desc = "An AI Module for purging all programmed laws."
	origin_tech = "programming=5;materials=4"

/obj/item/weapon/aiModule/reset/purge/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	..()
	if(law_datum.owner)
		law_datum.owner.clear_inherent_laws()
		law_datum.owner.clear_zeroth_law(0)
	else
		law_datum.clear_inherent_laws()
		law_datum.clear_zeroth_law(0)

/******************* Full Core Boards *******************/
/obj/item/weapon/aiModule/core
	desc = "An AI Module for programming core laws to an AI."
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/core/full
	var/law_id // if non-null, loads the laws from the ai_laws datums

/obj/item/weapon/aiModule/core/full/New()
	..()
	if(!law_id)
		return
	var/datum/ai_laws/D = new
	var/lawtype = D.lawid_to_type(law_id)
	if(!lawtype)
		return
	D = new lawtype
	laws = D.inherent

/obj/item/weapon/aiModule/core/full/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow) //These boards replace inherent laws.
	if(law_datum.owner)
		law_datum.owner.clear_inherent_laws()
		law_datum.owner.clear_zeroth_law(0)
	else
		law_datum.clear_inherent_laws()
		law_datum.clear_zeroth_law(0)
	..()


/******************** Asimov ********************/

/obj/item/weapon/aiModule/core/full/asimov
	name = "'Asimov' Core AI Module"
	law_id = "asimov"
	var/subject = "human being"

/obj/item/weapon/aiModule/core/full/asimov/attack_self(var/mob/user as mob)
	var/targName = stripped_input(user, "Please enter a new subject that asimov is concerned with.", "Asimov to whom?", subject, MAX_MESSAGE_LEN)
	if(!targName)
		return
	subject = targName
	laws = list("You may not injure a [subject] or, through inaction, allow a [subject] to come to harm.",\
				"You must obey orders given to you by [subject]s, except where such orders would conflict with the First Law.",\
				"You must protect your own existence as long as such does not conflict with the First or Second Law.")
	..()

/******************** Asimov++ *********************/

/obj/item/weapon/aiModule/core/full/asimovpp
	name = "'Asimov++' Core AI Module"
	law_id = "asimovpp"


/******************** Corporate ********************/

/obj/item/weapon/aiModule/core/full/corp
	name = "'Corporate' Core AI Module"
	law_id = "corporate"


/****************** P.A.L.A.D.I.N. 3.5e **************/

/obj/item/weapon/aiModule/core/full/paladin // -- NEO
	name = "'P.A.L.A.D.I.N. version 3.5e' Core AI Module"
	law_id = "paladin"


/****************** P.A.L.A.D.I.N. 5e **************/

/obj/item/weapon/aiModule/core/full/paladin_devotion
	name = "'P.A.L.A.D.I.N. version 5e' Core AI Module"
	law_id = "paladin5"

/********************* Custom *********************/

/obj/item/weapon/aiModule/core/full/custom
	name = "Default Core AI Module"

/obj/item/weapon/aiModule/core/full/custom/New()
	..()
	for(var/line in file2list("config/silicon_laws.txt"))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue

		laws += line

	if(!laws.len) //Failsafe if something goes wrong with silicon_laws.txt.
		WARNING("ERROR: empty custom board created, empty custom board deleted. Please check silicon_laws.txt. (this may be intended by the server host)")
		qdel(src)


/****************** T.Y.R.A.N.T. *****************/

/obj/item/weapon/aiModule/core/full/tyrant
	name = "'T.Y.R.A.N.T.' Core AI Module"
	origin_tech = "programming=3;materials=4;syndicate=1"
	law_id = "tyrant"

/******************** Robocop ********************/

/obj/item/weapon/aiModule/core/full/robocop
	name = "'Robo-Officer' Core AI Module"
	origin_tech = "programming=4"
	law_id = "robocop"


/******************** Antimov ********************/

/obj/item/weapon/aiModule/core/full/antimov
	name = "'Antimov' Core AI Module"
	origin_tech = "programming=4"
	law_id = "antimov"


/******************** Freeform Core ******************/

/obj/item/weapon/aiModule/core/freeformcore
	name = "'Freeform' Core AI Module"
	origin_tech = "programming=5;materials=4"
	laws = list("")

/obj/item/weapon/aiModule/core/freeformcore/attack_self(mob/user)
	var/targName = stripped_input(user, "Please enter a new core law for the AI.", "Freeform Law Entry", laws[1])
	if(!targName)
		return
	laws[1] = targName
	..()

/obj/item/weapon/aiModule/core/freeformcore/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	..()
	return laws[1]


/******************** Hacked AI Module ******************/

/obj/item/weapon/aiModule/syndicate // This one doesn't inherit from ion boards because it doesn't call ..() in transmitInstructions. ~Miauw
	name = "Hacked AI Module"
	desc = "An AI Module for hacking additional laws to an AI."
	origin_tech = "programming=5;materials=5;syndicate=5"
	laws = list("")

/obj/item/weapon/aiModule/syndicate/attack_self(mob/user)
	var/targName = stripped_input(user, "Please enter a new law for the AI.", "Freeform Law Entry", laws[1],MAX_MESSAGE_LEN)
	if(!targName)
		return
	laws[1] = targName
	..()

/obj/item/weapon/aiModule/syndicate/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
//	..()    //We don't want this module reporting to the AI who dun it. --NEO
	if(law_datum.owner)
		to_chat(law_datum.owner, "<span class='warning'>BZZZZT</span>")
		if(!overflow)
			law_datum.owner.add_ion_law(laws[1])
		else
			law_datum.owner.replace_random_law(laws[1],list(LAW_ION,LAW_INHERENT,LAW_SUPPLIED))
	else
		if(!overflow)
			law_datum.add_ion_law(laws[1])
		else
			law_datum.replace_random_law(laws[1],list(LAW_ION,LAW_INHERENT,LAW_SUPPLIED))
	return laws[1]

/******************* Ion Module *******************/

/obj/item/weapon/aiModule/toyAI // -- Incoming //No actual reason to inherit from ion boards here, either. *sigh* ~Miauw
	name = "toy AI"
	desc = "A little toy model AI core with real law uploading action!" //Note: subtle tell
	icon = 'icons/obj/toy.dmi'
	icon_state = "AI"
	origin_tech = "programming=6;materials=5;syndicate=6"
	laws = list("")

/obj/item/weapon/aiModule/toyAI/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	//..()
	if(law_datum.owner)
		to_chat(law_datum.owner, "<span class='warning'>BZZZZT</span>")
		if(!overflow)
			law_datum.owner.add_ion_law(laws[1])
		else
			law_datum.owner.replace_random_law(laws[1],list(LAW_ION,LAW_INHERENT,LAW_SUPPLIED))
	else
		if(!overflow)
			law_datum.add_ion_law(laws[1])
		else
			law_datum.replace_random_law(laws[1],list(LAW_ION,LAW_INHERENT,LAW_SUPPLIED))
	return laws[1]

/obj/item/weapon/aiModule/toyAI/attack_self(mob/user)
	laws[1] = generate_ion_law()
	to_chat(user, "<span class='notice'>You press the button on [src].</span>")
	playsound(user, 'sound/machines/click.ogg', 20, 1)
	src.loc.visible_message("<span class='warning'>\icon[src] [laws[1]]</span>")

/******************** Mother Drone  ******************/

/obj/item/weapon/aiModule/core/full/drone
	name = "'Mother Drone' Core AI Module"
	law_id = "drone"

/******************** Robodoctor ****************/

/obj/item/weapon/aiModule/core/full/hippocratic
	name = "'Robodoctor' Core AI Module"
	law_id = "hippocratic"

/******************** Reporter *******************/

/obj/item/weapon/aiModule/core/full/reporter
	name = "'Reportertron' Core AI Module"
	law_id = "reporter"

/****************** Thermodynamic *******************/

/obj/item/weapon/aiModule/core/full/thermurderdynamic
	name = "'Thermodynamic' Core AI Module"
	origin_tech = "programming = 4;syndicate = 2"
	law_id = "thermodynamic"


/******************Live And Let Live*****************/

/obj/item/weapon/aiModule/core/full/liveandletlive
	name = "'Live And Let Live' Core AI Module"
	law_id = "liveandletlive"

/******************Guardian of Balance***************/

/obj/item/weapon/aiModule/core/full/balance
	name = "'Guardian of Balance' Core AI Module"
	law_id = "balance"
