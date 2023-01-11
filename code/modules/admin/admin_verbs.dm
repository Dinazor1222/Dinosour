
/**
 * AVD TODO

admin_verbs_sounds
/client/proc/play_local_sound
/client/proc/play_direct_mob_sound
/client/proc/play_sound
/client/proc/set_round_end_sound

admin_verbs_fun
/datum/admins/proc/station_traits_panel
/client/proc/admin_away
/client/proc/add_mob_ability
/client/proc/admin_change_sec_level
/client/proc/cinematic
/client/proc/cmd_admin_add_freeform_ai_law
/client/proc/cmd_admin_gib_self
/client/proc/cmd_select_equipment
/client/proc/command_report_footnote
/client/proc/delay_command_report
/client/proc/forceEvent
/client/proc/mass_zombie_cure
/client/proc/mass_zombie_infection
/client/proc/object_say
/client/proc/polymorph_all
/client/proc/remove_mob_ability
/client/proc/reset_ooc
/client/proc/run_weather
/client/proc/set_dynex_scale
/client/proc/set_ooc
/client/proc/show_tip
/client/proc/smite
/client/proc/summon_ert
/client/proc/toggle_nuke
/client/proc/toggle_random_events

admin_verbs_spawn
/datum/admins/proc/beaker_panel
/datum/admins/proc/podspawn_atom
/datum/admins/proc/spawn_atom
/datum/admins/proc/spawn_cargo
/datum/admins/proc/spawn_objasmob
/client/proc/respawn_character

admin_verbs_server
/datum/admins/proc/delay
/datum/admins/proc/delay_round_end
/datum/admins/proc/end_round
/datum/admins/proc/restart
/datum/admins/proc/startnow
/datum/admins/proc/toggleaban
/datum/admins/proc/toggleAI
/client/proc/adminchangemap
/client/proc/cmd_admin_delete
/client/proc/cmd_debug_del_all
/client/proc/cmd_debug_force_del_all
/client/proc/cmd_debug_hard_del_all
/client/proc/everyone_random
/client/proc/forcerandomrotate
/client/proc/generate_job_config
/client/proc/panicbunker
/client/proc/toggle_cdn
/client/proc/toggle_hub
/client/proc/toggle_interviews
/client/proc/toggle_random_events

admin_verbs_debug
#ifdef TESTING
/client/proc/check_missing_sprites
/client/proc/run_dynamic_simulations
#endif

/proc/machine_upgrade
/datum/admins/proc/create_or_modify_area
/client/proc/adventure_manager
/client/proc/atmos_control
/client/proc/callproc
/client/proc/callproc_datum
/client/proc/check_bomb_impacts
/client/proc/check_timer_sources
/client/proc/clear_dynamic_transit
/client/proc/cmd_admin_debug_traitor_objectives
/client/proc/cmd_admin_delete
/client/proc/cmd_admin_list_open_jobs
/client/proc/cmd_admin_toggle_fov
/client/proc/cmd_debug_del_all
/client/proc/cmd_debug_force_del_all
/client/proc/cmd_debug_hard_del_all
/client/proc/cmd_debug_make_powernets
/client/proc/cmd_debug_mob_lists
/client/proc/cmd_display_del_log
/client/proc/cmd_display_init_log
/client/proc/cmd_display_overlay_log
/client/proc/Debug2
/client/proc/debug_controller
/client/proc/debug_hallucination_weighted_list_per_type
/client/proc/debug_huds
/client/proc/debugNatureMapGenerator
/client/proc/debug_plane_masters
/client/proc/debug_spell_requirements
/client/proc/display_sendmaps
/client/proc/enable_mapping_verbs
/client/proc/generate_wikichem_list
/client/proc/get_dynex_power
/client/proc/get_dynex_range
/client/proc/jump_to_ruin
/client/proc/load_circuit
/client/proc/map_template_load
/client/proc/map_template_upload
/client/proc/modify_goals
/client/proc/open_colorblind_test
/client/proc/open_lua_editor
/client/proc/outfit_manager
/client/proc/populate_world
/client/proc/pump_random_event
/client/proc/print_cards
/client/proc/reload_cards
/client/proc/reload_configuration
/client/proc/restart_controller
/client/proc/run_empty_query
/client/proc/SDQL2_query
/client/proc/set_dynex_scale
/client/proc/spawn_debug_full_crew
/client/proc/test_cardpack_distribution
/client/proc/test_movable_UI
/client/proc/test_snap_UI
/client/proc/toggle_cdn
/client/proc/toggle_medal_disable
/client/proc/unload_ctf
/client/proc/validate_cards
/client/proc/validate_puzzgrids
/client/proc/view_runtimes

admin_verbs_possess
/proc/possess
/proc/release

admin_verbs_permissions
/client/proc/edit_admin_permissions

R_BUILD
/client/proc/togglebuildmodeself

R_SOUND & CONFIG_GET(string/invoke_youtubedl)
	add_verb(src, /client/proc/play_web_sound)

 * END AVD TODO
 */

/client/proc/add_admin_verbs()
	if(!holder)
		CRASH("called add_admin_verbs on a client without a holder?")
	control_freak = CONTROL_FREAK_SKIN | CONTROL_FREAK_MACROS
	SSadmin_verbs.assosciate_admin(src)

/client/proc/remove_admin_verbs()
	SSadmin_verbs.deassosciate_admin(src)

ADMIN_VERB(admin, hide_all_verbs, "Hide all of your Admin Verbs", NONE)
	usr.client.remove_admin_verbs()
	add_verb(usr.client, /client/proc/show_verbs)
	to_chat(usr, span_admin("Almost all of your adminverbs have been hidden."))

/client/proc/show_verbs() // This is not an ADMIN_VERB for a reason
	set name = "Adminverbs - Show"
	set category = "Admin"

	remove_verb(src, /client/proc/show_verbs)
	add_admin_verbs()

	to_chat(src, span_interface("All of your adminverbs are now visible."), confidential = TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Adminverbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

ADMIN_VERB(game, aghost, "Observe without leaving the game", R_ADMIN)
	if(isnewplayer(usr))
		to_chat(usr, span_red("Error: AGhost: Cannot admin-ghost wile in the lobby. Join or Observe first."))
		return

	if(isobserver(usr))
		var/mob/dead/observer/admin_ghost = usr
		if(!admin_ghost.mind?.current)
			to_chat(usr, span_red("Error: AGhost: You do not have a body to return to!"))
			return
		if(!admin_ghost.can_reenter_corpse)
			log_admin("[key_name(usr)] re-entered corpse")
			message_admins("[key_name_admin(usr)] re-entered corpse")
			admin_ghost.can_reenter_corpse = TRUE
		admin_ghost.reenter_corpse()
		return

	log_admin("[key_name(usr)] admin ghosted.")
	message_admins("[key_name_admin(usr)] admin ghosted.")
	usr.ghostize(TRUE)
	if(usr && !usr.key)
		usr.key = "@[key]" // If the key starts with '@' it designates an admin ghost

ADMIN_VERB(game, invisimin, "Toggles ghost-like invisibility", R_ADMIN)
	if(initial(usr.invisibility) == INVISIBILITY_OBSERVER)
		to_chat(usr, span_boldannounce("Invisimin toggle failed. You are already an invisible mob like a ghost."), confidential = TRUE)
		return
	if(usr.invisibility == INVISIBILITY_OBSERVER)
		usr.invisibility = initial(usr.invisibility)
		to_chat(usr, span_boldannounce("Invisimin off. Invisibility reset."), confidential = TRUE)
	else
		usr.invisibility = INVISIBILITY_OBSERVER
		to_chat(usr, span_adminnotice("<b>Invisimin on. You are now as invisible as a ghost.</b>"), confidential = TRUE)

ADMIN_VERB(game, check_antagonists, "", R_ADMIN)
	usr.client.holder.check_antagonists()
	log_admin("[key_name(usr)] checked antagonists.") //for tsar~ get a room you two
	if(!isobserver(usr) && SSticker.HasRoundStarted())
		message_admins("[key_name_admin(usr)] checked antagonists.")

ADMIN_VERB(game, list_bombers, "", R_ADMIN)
	usr.client.holder.list_bombers()

ADMIN_VERB(game, list_signalers, "", R_ADMIN)
	usr.client.holder.list_signalers()

ADMIN_VERB(game, list_law_changes, "", R_ADMIN)
	usr.client.holder.list_law_changes()

ADMIN_VERB(game, show_manifest, "", R_ADMIN)
	usr.client.holder.show_manifest()

ADMIN_VERB(game, list_dna, "", R_ADMIN)
	usr.client.holder.list_dna()

ADMIN_VERB(game, list_fingerprints, "", R_ADMIN)
	usr.client.holder.list_fingerprints()

ADMIN_VERB(admin, banning_panel, "", R_BAN)
	usr.client.holder.ban_panel()

ADMIN_VERB(admin, unbanning_panel, "", R_BAN)
	usr.client.holder.unban_panel()

ADMIN_VERB(game, game_panel, "", NONE)
	usr.client.holder.Game()

ADMIN_VERB(admin, server_poll_management, "", R_POLL)
	usr.client.holder.poll_list_panel()

/// Returns this client's stealthed ckey
/client/proc/getStealthKey()
	return GLOB.stealthminID[ckey]

/// Takes a stealthed ckey as input, returns the true key it represents
/proc/findTrueKey(stealth_key)
	if(!stealth_key)
		return
	for(var/potentialKey in GLOB.stealthminID)
		if(GLOB.stealthminID[potentialKey] == stealth_key)
			return potentialKey

/// Hands back a stealth ckey to use, guarenteed to be unique
/proc/generateStealthCkey()
	var/guess = rand(0, 1000)
	var/text_guess
	var/valid_found = FALSE
	while(valid_found == FALSE)
		valid_found = TRUE
		text_guess = "@[num2text(guess)]"
		// We take a guess at some number, and if it's not in the existing stealthmin list we exit
		for(var/key in GLOB.stealthminID)
			// If it is in the list tho, we up one number, and redo the loop
			if(GLOB.stealthminID[key] == text_guess)
				guess += 1
				valid_found = FALSE
				break

	return text_guess

/client/proc/createStealthKey()
	GLOB.stealthminID["[ckey]"] = generateStealthCkey()

ADMIN_VERB(admin, stealth_mode, "Makes you unable to be seen through most means", R_STEALTH)
	if(usr.client.holder.fakekey)
		usr.client.disable_stealth_mode()
	else
		usr.client.enable_stealth_mode()

#define STEALTH_MODE_TRAIT "stealth_mode"

/client/proc/enable_stealth_mode()
	var/new_key = ckeyEx(stripped_input(usr, "Enter your desired display name.", "Fake Key", key, 26))
	if(!new_key)
		return
	holder.fakekey = new_key
	createStealthKey()
	if(isobserver(mob))
		mob.invisibility = INVISIBILITY_MAXIMUM //JUST IN CASE
		mob.alpha = 0 //JUUUUST IN CASE
		mob.name = " "
		mob.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	ADD_TRAIT(mob, TRAIT_ORBITING_FORBIDDEN, STEALTH_MODE_TRAIT)
	QDEL_NULL(mob.orbiters)

	log_admin("[key_name(usr)] has turned stealth mode ON")
	message_admins("[key_name_admin(usr)] has turned stealth mode ON")

/client/proc/disable_stealth_mode()
	holder.fakekey = null
	if(isobserver(mob))
		mob.invisibility = initial(mob.invisibility)
		mob.alpha = initial(mob.alpha)
		if(mob.mind)
			if(mob.mind.ghostname)
				mob.name = mob.mind.ghostname
			else
				mob.name = mob.mind.name
		else
			mob.name = mob.real_name
		mob.mouse_opacity = initial(mob.mouse_opacity)

	REMOVE_TRAIT(mob, TRAIT_ORBITING_FORBIDDEN, STEALTH_MODE_TRAIT)

	log_admin("[key_name(usr)] has turned stealth mode OFF")
	message_admins("[key_name_admin(usr)] has turned stealth mode OFF")

#undef STEALTH_MODE_TRAIT

ADMIN_VERB(fun, drop_bomb, "Cause an explosion of varying strength at your location", R_FUN)
	var/list/choices = list("Small Bomb (1, 2, 3, 3)", "Medium Bomb (2, 3, 4, 4)", "Big Bomb (3, 5, 7, 5)", "Maxcap", "Custom Bomb")
	var/choice = tgui_input_list(usr, "What size explosion would you like to produce? NOTE: You can do all this rapidly and in an IC manner (using cruise missiles!) with the Config/Launch Supplypod verb. WARNING: These ignore the maxcap", "Drop Bomb", choices)
	if(isnull(choice))
		return
	var/turf/epicenter = get_turf(usr)

	switch(choice)
		if("Small Bomb (1, 2, 3, 3)")
			explosion(epicenter, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 3, flash_range = 3, adminlog = TRUE, ignorecap = TRUE, explosion_cause = usr)
		if("Medium Bomb (2, 3, 4, 4)")
			explosion(epicenter, devastation_range = 2, heavy_impact_range = 3, light_impact_range = 4, flash_range = 4, adminlog = TRUE, ignorecap = TRUE, explosion_cause = usr)
		if("Big Bomb (3, 5, 7, 5)")
			explosion(epicenter, devastation_range = 3, heavy_impact_range = 5, light_impact_range = 7, flash_range = 5, adminlog = TRUE, ignorecap = TRUE, explosion_cause = usr)
		if("Maxcap")
			explosion(epicenter, devastation_range = GLOB.MAX_EX_DEVESTATION_RANGE, heavy_impact_range = GLOB.MAX_EX_HEAVY_RANGE, light_impact_range = GLOB.MAX_EX_LIGHT_RANGE, flash_range = GLOB.MAX_EX_FLASH_RANGE, adminlog = TRUE, ignorecap = TRUE, explosion_cause = usr)
		if("Custom Bomb")
			var/range_devastation = input("Devastation range (in tiles):") as null|num
			if(range_devastation == null)
				return
			var/range_heavy = input("Heavy impact range (in tiles):") as null|num
			if(range_heavy == null)
				return
			var/range_light = input("Light impact range (in tiles):") as null|num
			if(range_light == null)
				return
			var/range_flash = input("Flash range (in tiles):") as null|num
			if(range_flash == null)
				return
			if(range_devastation > GLOB.MAX_EX_DEVESTATION_RANGE || range_heavy > GLOB.MAX_EX_HEAVY_RANGE || range_light > GLOB.MAX_EX_LIGHT_RANGE || range_flash > GLOB.MAX_EX_FLASH_RANGE)
				if(tgui_alert(usr, "Bomb is bigger than the maxcap. Continue?",,list("Yes","No")) != "Yes")
					return
			epicenter = get_turf(usr) //We need to reupdate as they may have moved again
			explosion(epicenter, devastation_range = range_devastation, heavy_impact_range = range_heavy, light_impact_range = range_light, flash_range = range_flash, adminlog = TRUE, ignorecap = TRUE, explosion_cause = usr)
	message_admins("[ADMIN_LOOKUPFLW(usr)] creating an admin explosion at [epicenter.loc].")
	log_admin("[key_name(usr)] created an admin explosion at [epicenter.loc].")

ADMIN_VERB(fun, drop_dynex_bomb, "Cause an explosion of varting strength at your location", R_FUN)
	var/ex_power = input(usr, "Explosive Power:") as null|num
	var/turf/epicenter = get_turf(usr)
	if(ex_power && epicenter)
		dyn_explosion(epicenter, ex_power)
		message_admins("[ADMIN_LOOKUPFLW(usr)] creating an admin explosion at [epicenter.loc].")
		log_admin("[key_name(usr)] created an admin explosion at [epicenter.loc].")

/client/proc/get_dynex_range()
	set category = "Debug"
	set name = "Get DynEx Range"
	set desc = "Get the estimated range of a bomb, using explosive power."

	var/ex_power = input("Explosive Power:") as null|num
	if (isnull(ex_power))
		return
	var/range = round((2 * ex_power)**GLOB.DYN_EX_SCALE)
	to_chat(usr, "Estimated Explosive Range: (Devastation: [round(range*0.25)], Heavy: [round(range*0.5)], Light: [round(range)])", confidential = TRUE)

/client/proc/get_dynex_power()
	set category = "Debug"
	set name = "Get DynEx Power"
	set desc = "Get the estimated required power of a bomb, to reach a specific range."

	var/ex_range = input("Light Explosion Range:") as null|num
	if (isnull(ex_range))
		return
	var/power = (0.5 * ex_range)**(1/GLOB.DYN_EX_SCALE)
	to_chat(usr, "Estimated Explosive Power: [power]", confidential = TRUE)

/client/proc/set_dynex_scale()
	set category = "Debug"
	set name = "Set DynEx Scale"
	set desc = "Set the scale multiplier of dynex explosions. The default is 0.5."

	var/ex_scale = input("New DynEx Scale:") as null|num
	if(!ex_scale)
		return
	GLOB.DYN_EX_SCALE = ex_scale
	log_admin("[key_name(usr)] has modified Dynamic Explosion Scale: [ex_scale]")
	message_admins("[key_name_admin(usr)] has  modified Dynamic Explosion Scale: [ex_scale]")

/client/proc/atmos_control()
	set name = "Atmos Control Panel"
	set category = "Debug"
	if(!check_rights(R_DEBUG))
		return
	SSair.ui_interact(mob)

/client/proc/reload_cards()
	set name = "Reload Cards"
	set category = "Debug"
	if(!check_rights(R_DEBUG))
		return
	if(!SStrading_card_game.loaded)
		message_admins("The card subsystem is not currently loaded")
		return
	SStrading_card_game.reloadAllCardFiles()

/client/proc/validate_cards()
	set name = "Validate Cards"
	set category = "Debug"
	if(!check_rights(R_DEBUG))
		return
	if(!SStrading_card_game.loaded)
		message_admins("The card subsystem is not currently loaded")
		return
	var/message = SStrading_card_game.check_cardpacks(SStrading_card_game.card_packs)
	message += SStrading_card_game.check_card_datums()
	if(message)
		message_admins(message)
	else
		message_admins("No errors found in card rarities or overrides.")

/client/proc/test_cardpack_distribution()
	set name = "Test Cardpack Distribution"
	set category = "Debug"
	if(!check_rights(R_DEBUG))
		return
	if(!SStrading_card_game.loaded)
		message_admins("The card subsystem is not currently loaded")
		return
	var/pack = tgui_input_list(usr, "Which pack should we test?", "You fucked it didn't you", sort_list(SStrading_card_game.card_packs))
	if(!pack)
		return
	var/batch_count = tgui_input_number(usr, "How many times should we open it?", "Don't worry, I understand")
	var/batch_size = tgui_input_number(usr, "How many cards per batch?", "I hope you remember to check the validation")
	var/guar = tgui_input_number(usr, "Should we use the pack's guaranteed rarity? If so, how many?", "We've all been there. Man you should have seen the old system")

	SStrading_card_game.check_card_distribution(pack, batch_size, batch_count, guar)

/client/proc/print_cards()
	set name = "Print Cards"
	set category = "Debug"
	SStrading_card_game.printAllCards()

/client/proc/give_spell(mob/spell_recipient in GLOB.mob_list)
	set category = "Admin.Fun"
	set name = "Give Spell"
	set desc = "Gives a spell to a mob."

	var/which = tgui_alert(usr, "Chose by name or by type path?", "Chose option", list("Name", "Typepath"))
	if(!which)
		return
	if(QDELETED(spell_recipient))
		to_chat(usr, span_warning("The intended spell recipient no longer exists."))
		return

	var/list/spell_list = list()
	for(var/datum/action/cooldown/spell/to_add as anything in subtypesof(/datum/action/cooldown/spell))
		var/spell_name = initial(to_add.name)
		if(spell_name == "Spell") // abstract or un-named spells should be skipped.
			continue

		if(which == "Name")
			spell_list[spell_name] = to_add
		else
			spell_list += to_add

	var/chosen_spell = tgui_input_list(usr, "Choose the spell to give to [spell_recipient]", "ABRAKADABRA", sort_list(spell_list))
	if(isnull(chosen_spell))
		return
	var/datum/action/cooldown/spell/spell_path = which == "Typepath" ? chosen_spell : spell_list[chosen_spell]
	if(!ispath(spell_path))
		return

	var/robeless = (tgui_alert(usr, "Would you like to force this spell to be robeless?", "Robeless Casting?", list("Force Robeless", "Use Spell Setting")) == "Force Robeless")

	if(QDELETED(spell_recipient))
		to_chat(usr, span_warning("The intended spell recipient no longer exists."))
		return

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Spell") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(spell_recipient)] the spell [chosen_spell][robeless ? " (Forced robeless)" : ""].")
	message_admins("[key_name_admin(usr)] gave [key_name_admin(spell_recipient)] the spell [chosen_spell][robeless ? " (Forced robeless)" : ""].")

	var/datum/action/cooldown/spell/new_spell = new spell_path(spell_recipient.mind || spell_recipient)

	if(robeless)
		new_spell.spell_requirements &= ~SPELL_REQUIRES_WIZARD_GARB

	new_spell.Grant(spell_recipient)

	if(!spell_recipient.mind)
		to_chat(usr, span_userdanger("Spells given to mindless mobs will belong to the mob and not their mind, \
			and as such will not be transferred if their mind changes body (Such as from Mindswap)."))

/client/proc/remove_spell(mob/removal_target in GLOB.mob_list)
	set category = "Admin.Fun"
	set name = "Remove Spell"
	set desc = "Remove a spell from the selected mob."

	var/list/target_spell_list = list()
	for(var/datum/action/cooldown/spell/spell in removal_target.actions)
		target_spell_list[spell.name] = spell

	if(!length(target_spell_list))
		return

	var/chosen_spell = tgui_input_list(usr, "Choose the spell to remove from [removal_target]", "ABRAKADABRA", sort_list(target_spell_list))
	if(isnull(chosen_spell))
		return
	var/datum/action/cooldown/spell/to_remove = target_spell_list[chosen_spell]
	if(!istype(to_remove))
		return

	qdel(to_remove)
	log_admin("[key_name(usr)] removed the spell [chosen_spell] from [key_name(removal_target)].")
	message_admins("[key_name_admin(usr)] removed the spell [chosen_spell] from [key_name_admin(removal_target)].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Remove Spell") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/give_disease(mob/living/T in GLOB.mob_living_list)
	set category = "Admin.Fun"
	set name = "Give Disease"
	set desc = "Gives a Disease to a mob."
	if(!istype(T))
		to_chat(src, span_notice("You can only give a disease to a mob of type /mob/living."), confidential = TRUE)
		return
	var/datum/disease/D = input("Choose the disease to give to that guy", "ACHOO") as null|anything in sort_list(SSdisease.diseases, GLOBAL_PROC_REF(cmp_typepaths_asc))
	if(!D)
		return
	T.ForceContractDisease(new D, FALSE, TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Disease") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] the disease [D].")
	message_admins(span_adminnotice("[key_name_admin(usr)] gave [key_name_admin(T)] the disease [D]."))

/client/proc/object_say(obj/O in world)
	set category = "Admin.Events"
	set name = "OSay"
	set desc = "Makes an object say something."
	var/message = tgui_input_text(usr, "What do you want the message to be?", "Make Sound", encode = FALSE)
	if(!message)
		return
	O.say(message, sanitize = FALSE)
	log_admin("[key_name(usr)] made [O] at [AREACOORD(O)] say \"[message]\"")
	message_admins(span_adminnotice("[key_name_admin(usr)] made [O] at [AREACOORD(O)]. say \"[message]\""))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Object Say") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/client/proc/togglebuildmodeself()
	set name = "Toggle Build Mode Self"
	set category = "Admin.Events"
	if (!(holder.rank_flags() & R_BUILD))
		return
	if(src.mob)
		togglebuildmode(src.mob)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Build Mode") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/check_ai_laws()
	set name = "Check AI Laws"
	set category = "Admin.Game"
	if(holder)
		src.holder.output_ai_laws()

/client/proc/deadmin()
	set name = "Deadmin"
	set category = "Admin"
	set desc = "Shed your admin powers."

	if(!holder)
		return

	holder.deactivate()

	to_chat(src, span_interface("You are now a normal player."))
	log_admin("[src] deadminned themselves.")
	message_admins("[src] deadminned themselves.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Deadmin")

/client/proc/readmin()
	set name = "Readmin"
	set category = "Admin"
	set desc = "Regain your admin powers."

	var/datum/admins/A = GLOB.deadmins[ckey]

	if(!A)
		A = GLOB.admin_datums[ckey]
		if (!A)
			var/msg = " is trying to readmin but they have no deadmin entry"
			message_admins("[key_name_admin(src)][msg]")
			log_admin_private("[key_name(src)][msg]")
			return

	A.associate(src)

	if (!holder)
		return //This can happen if an admin attempts to vv themself into somebody elses's deadmin datum by getting ref via brute force

	to_chat(src, span_interface("You are now an admin."), confidential = TRUE)
	message_admins("[src] re-adminned themselves.")
	log_admin("[src] re-adminned themselves.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Readmin")

/client/proc/populate_world(amount = 50)
	set name = "Populate World"
	set category = "Debug"
	set desc = "(\"Amount of mobs to create\") Populate the world with test mobs."

	for (var/i in 1 to amount)
		var/turf/tile = get_safe_random_station_turf()
		var/mob/living/carbon/human/hooman = new(tile)
		hooman.equipOutfit(pick(subtypesof(/datum/outfit)))
		testing("Spawned test mob at [get_area_name(tile, TRUE)] ([tile.x],[tile.y],[tile.z])")

/client/proc/toggle_AI_interact()
	set name = "Toggle Admin AI Interact"
	set category = "Admin.Game"
	set desc = "Allows you to interact with most machines as an AI would as a ghost"

	AI_Interact = !AI_Interact
	if(mob && isAdminGhostAI(mob))
		mob.has_unlimited_silicon_privilege = AI_Interact

	log_admin("[key_name(usr)] has [AI_Interact ? "activated" : "deactivated"] Admin AI Interact")
	message_admins("[key_name_admin(usr)] has [AI_Interact ? "activated" : "deactivated"] their AI interaction")

/client/proc/admin_2fa_verify()
	set name = "Verify Admin"
	set category = "Admin"

	var/datum/admins/admin = GLOB.admin_datums[ckey]
	admin?.associate(src)

/client/proc/display_sendmaps()
	set name = "Send Maps Profile"
	set category = "Debug"

	src << link("?debug=profile&type=sendmaps&window=test")

/**
 * Debug verb that spawns human crewmembers
 * of each job type, gives them a mind and assigns the role,
 * and injects them into the manifest, as if they were a "player".
 *
 * This spawns humans with minds and jobs, but does NOT make them 'players'.
 * They're all clientles mobs with minds / jobs.
 */
/client/proc/spawn_debug_full_crew()
	set name = "Spawn Debug Full Crew"
	set desc = "Creates a full crew for the station, filling the datacore and assigning them all minds / jobs. Don't do this on live"
	set category = "Debug"

	if(!check_rights(R_DEBUG))
		return

	var/mob/admin = usr

	if(SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(admin, "You should only be using this after a round has setup and started.")
		return

	// Two input checks here to make sure people are certain when they're using this.
	if(tgui_alert(admin, "This command will create a bunch of dummy crewmembers with minds, job, and datacore entries, which will take a while and fill the manifest.", "Spawn Crew", list("Yes", "Cancel")) != "Yes")
		return

	if(tgui_alert(admin, "I sure hope you aren't doing this on live. Are you sure?", "Spawn Crew (Be certain)", list("Yes", "Cancel")) != "Yes")
		return

	// Find the observer spawn, so we have a place to dump the dummies.
	var/obj/effect/landmark/observer_start/observer_point = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
	var/turf/destination = get_turf(observer_point)
	if(!destination)
		to_chat(admin, "Failed to find the observer spawn to send the dummies.")
		return

	// Okay, now go through all nameable occupations.
	// Pick out all jobs that have JOB_CREW_MEMBER set.
	// Then, spawn a human and slap a person into it.
	var/number_made = 0
	for(var/rank in SSjob.name_occupations)
		var/datum/job/job = SSjob.GetJob(rank)

		// JOB_CREW_MEMBER is all jobs that pretty much aren't silicon
		if(!(job.job_flags & JOB_CREW_MEMBER))
			continue

		// Create our new_player for this job and set up its mind.
		var/mob/dead/new_player/new_guy = new()
		new_guy.mind_initialize()
		new_guy.mind.name = "[rank] Dummy"

		// Assign the rank to the new player dummy.
		if(!SSjob.AssignRole(new_guy, job))
			qdel(new_guy)
			to_chat(admin, "[rank] wasn't able to be spawned.")
			continue

		// It's got a job, spawn in a human and shove it in the human.
		var/mob/living/carbon/human/character = new(destination)
		character.name = new_guy.mind.name
		new_guy.mind.transfer_to(character)
		qdel(new_guy)

		// Then equip up the human with job gear.
		SSjob.EquipRank(character, job)
		job.after_latejoin_spawn(character)

		// Finally, ensure the minds are tracked and in the manifest.
		SSticker.minds += character.mind
		if(ishuman(character))
			GLOB.data_core.manifest_inject(character)

		number_made++
		CHECK_TICK

	to_chat(admin, "[number_made] crewmembers have been created.")

/// Debug verb for seeing at a glance what all spells have as set requirements
/client/proc/debug_spell_requirements()
	set name = "Show Spell Requirements"
	set category = "Debug"

	var/header = "<tr><th>Name</th> <th>Requirements</th>"
	var/all_requirements = list()
	for(var/datum/action/cooldown/spell/spell as anything in typesof(/datum/action/cooldown/spell))
		if(initial(spell.name) == "Spell")
			continue

		var/list/real_reqs = list()
		var/reqs = initial(spell.spell_requirements)
		if(reqs & SPELL_CASTABLE_AS_BRAIN)
			real_reqs += "Castable as brain"
		if(reqs & SPELL_CASTABLE_WHILE_PHASED)
			real_reqs += "Castable phased"
		if(reqs & SPELL_REQUIRES_HUMAN)
			real_reqs += "Must be human"
		if(reqs & SPELL_REQUIRES_MIME_VOW)
			real_reqs += "Must be miming"
		if(reqs & SPELL_REQUIRES_MIND)
			real_reqs += "Must have a mind"
		if(reqs & SPELL_REQUIRES_NO_ANTIMAGIC)
			real_reqs += "Must have no antimagic"
		if(reqs & SPELL_REQUIRES_OFF_CENTCOM)
			real_reqs += "Must be off central command z-level"
		if(reqs & SPELL_REQUIRES_WIZARD_GARB)
			real_reqs += "Must have wizard clothes"

		all_requirements += "<tr><td>[initial(spell.name)]</td> <td>[english_list(real_reqs, "No requirements")]</td></tr>"

	var/page_style = "<style>table, th, td {border: 1px solid black;border-collapse: collapse;}</style>"
	var/page_contents = "[page_style]<table style=\"width:100%\">[header][jointext(all_requirements, "")]</table>"
	var/datum/browser/popup = new(mob, "spellreqs", "Spell Requirements", 600, 400)
	popup.set_content(page_contents)
	popup.open()

/client/proc/force_load_lazy_template()
	set name = "Load/Jump Lazy Template"
	set category = "Admin.Events"
	if(!check_rights(R_ADMIN))
		return

	if(SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, span_warning("The game hasnt started yet!"))
		return

	var/list/choices = LAZY_TEMPLATE_KEY_LIST_ALL()
	var/choice = tgui_input_list(usr, "Key?", "Lazy Loader", choices)
	if(!choice)
		return

	choice = choices[choice]
	if(!choice)
		to_chat(usr, span_warning("No template with that key found, report this!"))
		return

	var/already_loaded = LAZYACCESS(SSmapping.loaded_lazy_templates, choice)
	var/force_load = FALSE
	if(already_loaded && (tgui_alert(usr, "Template already loaded.", "", list("Jump", "Load Again")) == "Load Again"))
		force_load = TRUE

	var/datum/turf_reservation/reservation = SSmapping.lazy_load_template(choice, force = force_load)
	if(!reservation)
		to_chat(usr, span_boldwarning("Failed to load template!"))
		return

	if(!isobserver(usr))
		SSadmin_verbs.dynamic_invoke_admin_verb(usr.client, /mob/admin_module_holder/game/aghost)
	usr.forceMove(coords2turf(reservation.bottom_left_coords))

	message_admins("[key_name_admin(usr)] has loaded lazy template '[choice]'")
	to_chat(usr, span_boldnicegreen("Template loaded, you have been moved to the bottom left of the reservation."))
