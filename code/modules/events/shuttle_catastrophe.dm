/datum/round_event_control/shuttle_catastrophe
	name = "Shuttle Catastrophe"
	typepath = /datum/round_event/shuttle_catastrophe
	weight = 10
	max_occurrences = 1
	category = EVENT_CATEGORY_BUREAUCRATIC
	description = "Replaces the emergency shuttle with a random one."

/datum/round_event_control/shuttle_catastrophe/can_spawn_event(players, allow_magic = FALSE)
	. = ..()
	if(!.)
		return .

	if(SSshuttle.shuttle_purchased == SHUTTLEPURCHASE_FORCED)
		return FALSE //don't do it if its already been done
	if(istype(SSshuttle.emergency, /obj/docking_port/mobile/emergency/shuttle_build))
		return FALSE //don't undo manual player engineering, it also would unload people and ghost them, there's just a lot of problems
	if(EMERGENCY_AT_LEAST_DOCKED)
		return FALSE //don't remove all players when its already on station or going to centcom
	return TRUE

/datum/round_event_control/shuttle_catastrophe/admin_setup(mob/admin)
	if(EMERGENCY_AT_LEAST_DOCKED || istype(SSshuttle.emergency, /obj/docking_port/mobile/emergency/shuttle_build))
		if(tgui_alert(usr, "WARNING: This will unload the currently docked emergency shuttle, and ERASE ANYTHING within it. Proceed anyways?", "How about a REAL catastrophe?", list("Yes", "No")) == "Yes")
			message_admins("[admin.ckey] has forced a shuttle catastrophe while a shuttle was already docked.") //Just in case
		else
			return ADMIN_CANCEL_EVENT

/datum/round_event/shuttle_catastrophe
	var/datum/map_template/shuttle/new_shuttle

/datum/round_event/shuttle_catastrophe/announce(fake)
	var/cause = pick("was attacked by [syndicate_name()] Operatives", "mysteriously teleported away", "had its refuelling crew mutiny",
		"was found with its engines stolen", "\[REDACTED\]", "flew into the sunset, and melted", "learned something from a very wise cow, and left on its own",
		"had cloning devices on it", "had its shuttle inspector put the shuttle in reverse instead of park, causing the shuttle to crash into the hangar")
	var/message = "Your emergency shuttle [cause]. "

	if(SSshuttle.shuttle_insurance)
		message += "Luckily, your shuttle insurance has covered the costs of repair!"
		if(SSeconomy.get_dep_account(ACCOUNT_CAR))
			message += " You have been awarded a bonus from [command_name()] for smart spending."
	else
		message += "Your replacement shuttle will be the [new_shuttle.name] until further notice."
	priority_announce(message, "[command_name()] Spacecraft Engineering")

/datum/round_event/shuttle_catastrophe/setup()
	if(SSshuttle.shuttle_insurance)
		return
	var/list/valid_shuttle_templates = list()
	for(var/shuttle_id in SSmapping.shuttle_templates)
		var/datum/map_template/shuttle/template = SSmapping.shuttle_templates[shuttle_id]
		if(!isnull(template.who_can_purchase) && template.credit_cost < INFINITY) //if we could get it from the communications console, it's cool for us to get it here
			valid_shuttle_templates += template
	new_shuttle = pick(valid_shuttle_templates)

/datum/round_event/shuttle_catastrophe/start()
	if(SSshuttle.shuttle_insurance)
		var/datum/bank_account/station_balance = SSeconomy.get_dep_account(ACCOUNT_CAR)
		station_balance?.adjust_money(8000)
		return
	SSshuttle.shuttle_purchased = SHUTTLEPURCHASE_FORCED
	SSshuttle.unload_preview()
	SSshuttle.existing_shuttle = SSshuttle.emergency
	SSshuttle.action_load(new_shuttle, replace = TRUE)
	log_shuttle("Shuttle Catastrophe set a new shuttle, [new_shuttle.name].")
