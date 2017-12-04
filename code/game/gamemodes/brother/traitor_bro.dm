/datum/objective_team/brother_team
	name = "brotherhood"
	member_name = "blood brother"
	var/meeting_area

/datum/objective_team/brother_team/is_solo()
	return FALSE

/datum/objective_team/brother_team/proc/update_name()
	var/list/last_names = list()
	for(var/datum/mind/M in members)
		var/list/split_name = splittext(M.name," ")
		last_names += split_name[split_name.len]

	name = last_names.Join(" & ")

/datum/objective_team/brother_team/roundend_report()
	var/list/parts = list()

	parts += "<font size=4><b>The blood brothers of [name] were:</b></font>"
	for(var/datum/mind/M in members)
		parts += printplayer(M)
	var/win = TRUE
	var/objective_count = 1
	for(var/datum/objective/objective in objectives)
		if(objective.check_completion())
			parts += "<B>Objective #[objective_count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
		else
			parts += "<B>Objective #[objective_count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
			win = FALSE
		objective_count++
	if(win)
		parts += "<font color='green'><B>The blood brothers were successful!</B></font>"
	else
		parts += "<font color='red'><B>The blood brothers have failed!</B></font>"

	return parts.Join("<br>")

/datum/objective_team/brother_team/proc/add_objective(datum/objective/O, needs_target = FALSE)
	O.team = src
	if(needs_target)
		O.find_target()
	O.update_explanation_text()
	objectives += O

/datum/objective_team/brother_team/proc/forge_brother_objectives()
	objectives = list()
	var/is_hijacker = prob(10)
	for(var/i = 1 to max(1, CONFIG_GET(number/brother_objectives_amount) + (members.len > 2) - is_hijacker))
		forge_single_objective()
	if(is_hijacker)
		if(!locate(/datum/objective/hijack) in objectives)
			add_objective(new/datum/objective/hijack)
	else if(!locate(/datum/objective/escape) in objectives)
		add_objective(new/datum/objective/escape)

/datum/objective_team/brother_team/proc/forge_single_objective()
	if(prob(50))
		if(LAZYLEN(active_ais()) && prob(100/GLOB.joined_player_list.len))
			add_objective(new/datum/objective/destroy, TRUE)
		else if(prob(30))
			add_objective(new/datum/objective/maroon, TRUE)
		else
			add_objective(new/datum/objective/assassinate, TRUE)
	else
		add_objective(new/datum/objective/steal, TRUE)

/datum/game_mode
	var/list/datum/mind/brothers = list()
	var/list/datum/objective_team/brother_team/brother_teams = list()

/datum/game_mode/traitor/bros
	name = "traitor+brothers"
	config_tag = "traitorbro"
	restricted_jobs = list("AI", "Cyborg")

	announce_span = "danger"
	announce_text = "There are Syndicate agents and Blood Brothers on the station!\n\
	<span class='danger'>Traitors</span>: Accomplish your objectives.\n\
	<span class='danger'>Blood Brothers</span>: Accomplish your objectives.\n\
	<span class='notice'>Crew</span>: Do not let the traitors or brothers succeed!"

	var/list/datum/objective_team/brother_team/pre_brother_teams = list()
	var/const/team_amount = 2 //hard limit on brother teams if scaling is turned off
	var/const/min_team_size = 2
	traitors_required = FALSE //Only teams are possible

	var/meeting_areas = list("The Bar", "Dorms", "Escape Dock", "Arrivals", "Holodeck", "Primary Tool Storage", "Recreation Area", "Chapel", "Library")

/datum/game_mode/traitor/bros/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	var/list/datum/mind/possible_brothers = get_players_for_role(ROLE_BROTHER)

	var/num_teams = team_amount
	var/bsc = CONFIG_GET(number/brother_scaling_coeff)
	if(bsc)
		num_teams = max(1, round(num_players() / bsc))

	for(var/j = 1 to num_teams)
		if(possible_brothers.len < min_team_size || antag_candidates.len <= required_enemies)
			break
		var/datum/objective_team/brother_team/team = new
		var/team_size = prob(10) ? min(3, possible_brothers.len) : 2
		for(var/k = 1 to team_size)
			var/datum/mind/bro = pick(possible_brothers)
			possible_brothers -= bro
			antag_candidates -= bro
			team.add_member(bro)
			bro.restricted_roles = restricted_jobs
			log_game("[bro.key] (ckey) has been selected as a Brother")
		pre_brother_teams += team
	return ..()

/datum/game_mode/traitor/bros/post_setup()
	for(var/datum/objective_team/brother_team/team in pre_brother_teams)
		team.meeting_area = pick(meeting_areas)
		meeting_areas -= team.meeting_area
		team.forge_brother_objectives()
		for(var/datum/mind/M in team.members)
			M.add_antag_datum(ANTAG_DATUM_BROTHER, team)
		team.update_name()
	brother_teams += pre_brother_teams
	return ..()

/datum/game_mode/traitor/bros/generate_report()
	return "It's Syndicate recruiting season. Be alert for potential Syndicate infiltrators, but also watch out for disgruntled employees trying to defect. Unlike Nanotrasen, the Syndicate prides itself in teamwork and will only recruit pairs that share a brotherly trust."

/datum/game_mode/proc/update_brother_icons_added(datum/mind/brother_mind)
	var/datum/atom_hud/antag/brotherhud = GLOB.huds[ANTAG_HUD_BROTHER]
	brotherhud.join_hud(brother_mind.current)
	set_antag_hud(brother_mind.current, "brother")

/datum/game_mode/proc/update_brother_icons_removed(datum/mind/brother_mind)
	var/datum/atom_hud/antag/brotherhud = GLOB.huds[ANTAG_HUD_BROTHER]
	brotherhud.leave_hud(brother_mind.current)
	set_antag_hud(brother_mind.current, null)
