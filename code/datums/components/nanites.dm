/datum/component/nanites
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/mob/living/host_mob
	var/nanite_volume = 100		//amount of nanites in the system, used as fuel for nanite programs
	var/max_nanites = 500		//maximum amount of nanites in the system
	var/regen_rate = 0.5		//nanites generated per second
	var/safety_threshold = 50	//how low nanites will get before they stop processing/triggering
	var/cloud_id = 0 			//0 if not connected to the cloud, 1-100 to set a determined cloud backup to draw from
	var/next_sync = 0
	var/list/datum/nanite_program/programs = list()
	var/max_programs = NANITE_PROGRAM_LIMIT

	var/stealth = FALSE //if TRUE, does not appear on HUDs and health scans, and does not display the program list on nanite scans

/datum/component/nanites/Initialize(amount = 100, cloud = 0)
	nanite_volume = amount
	cloud_id = cloud

	RegisterSignal(parent, COMSIG_HAS_NANITES, .proc/confirm_nanites)
	RegisterSignal(parent, COMSIG_NANITE_UI_DATA, .proc/nanite_ui_data)
	RegisterSignal(parent, COMSIG_NANITE_GET_PROGRAMS, .proc/get_programs)
	RegisterSignal(parent, COMSIG_NANITE_SET_VOLUME, .proc/set_volume)
	RegisterSignal(parent, COMSIG_NANITE_ADJUST_VOLUME, .proc/adjust_nanites)
	RegisterSignal(parent, COMSIG_NANITE_SET_MAX_VOLUME, .proc/set_max_volume)
	RegisterSignal(parent, COMSIG_NANITE_SET_CLOUD, .proc/set_cloud)
	RegisterSignal(parent, COMSIG_NANITE_SET_SAFETY, .proc/set_safety)
	RegisterSignal(parent, COMSIG_NANITE_SET_REGEN, .proc/set_regen)
	RegisterSignal(parent, COMSIG_NANITE_ADD_PROGRAM, .proc/add_program)
	RegisterSignal(parent, COMSIG_NANITE_SCAN, .proc/nanite_scan)
	RegisterSignal(parent, COMSIG_NANITE_SYNC, .proc/sync)

	//Nanites without hosts are non-interactive through normal means
	if(isliving(parent))
		host_mob = parent

		if(!(MOB_ORGANIC in host_mob.mob_biotypes) && !(MOB_UNDEAD in host_mob.mob_biotypes)) //Shouldn't happen, but this avoids HUD runtimes in case a silicon gets them somehow.
			return COMPONENT_INCOMPATIBLE

		host_mob.hud_set_nanite_indicator()
		START_PROCESSING(SSnanites, src)
		RegisterSignal(host_mob, COMSIG_ATOM_EMP_ACT, .proc/on_emp)
		RegisterSignal(host_mob, COMSIG_MOB_DEATH, .proc/on_death)
		RegisterSignal(host_mob, COMSIG_MOB_ALLOWED, .proc/check_access)
		RegisterSignal(host_mob, COMSIG_LIVING_ELECTROCUTE_ACT, .proc/on_shock)
		RegisterSignal(host_mob, COMSIG_LIVING_MINOR_SHOCK, .proc/on_minor_shock)
		RegisterSignal(host_mob, COMSIG_MOVABLE_HEAR, .proc/on_hear)
		RegisterSignal(host_mob, COMSIG_SPECIES_GAIN, .proc/check_viable_biotype)

		RegisterSignal(host_mob, COMSIG_NANITE_SIGNAL, .proc/receive_signal)
		if(cloud_id)
			cloud_sync()
	else if(!istype(parent, /datum/nanite_cloud_backup))
		return COMPONENT_INCOMPATIBLE

/datum/component/nanites/Destroy()
	STOP_PROCESSING(SSnanites, src)
	set_nanite_bar(TRUE)
	QDEL_LIST(programs)
	if(host_mob)
		host_mob.hud_set_nanite_indicator()
	host_mob = null
	return ..()

/datum/component/nanites/InheritComponent(datum/component/nanites/new_nanites, i_am_original, list/arguments)
	if(new_nanites)
		adjust_nanites(new_nanites.nanite_volume)
	else
		adjust_nanites(arguments[1]) //just add to the nanite volume

/datum/component/nanites/process()
	adjust_nanites(regen_rate)
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.on_process()
	set_nanite_bar()
	if(cloud_id && world.time > next_sync)
		cloud_sync()
		next_sync = world.time + NANITE_SYNC_DELAY

//Syncs the nanite component to another, making it so programs are the same with the same programming (except activation status)
/datum/component/nanites/proc/sync(datum/component/nanites/source, full_overwrite = TRUE, copy_activation = FALSE)
	var/list/programs_to_remove = programs.Copy()
	var/list/programs_to_add = source.programs.Copy()
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		for(var/Y in programs_to_add)
			var/datum/nanite_program/SNP = Y
			if(NP.type == SNP.type)
				programs_to_remove -= NP
				programs_to_add -= SNP
				SNP.copy_programming(NP, copy_activation)
				break
	if(full_overwrite)
		for(var/X in programs_to_remove)
			qdel(X)
	for(var/X in programs_to_add)
		var/datum/nanite_program/SNP = X
		add_program(SNP.copy())

/datum/component/nanites/proc/cloud_sync()
	if(!cloud_id)
		return
	var/datum/nanite_cloud_backup/backup = SSnanites.get_cloud_backup(cloud_id)
	if(backup)
		var/datum/component/nanites/cloud_copy = backup.nanites
		if(cloud_copy)
			sync(cloud_copy)

/datum/component/nanites/proc/add_program(datum/nanite_program/new_program, datum/nanite_program/source_program)
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		if(NP.unique && NP.type == new_program.type)
			qdel(NP)
	if(programs.len >= max_programs)
		return COMPONENT_PROGRAM_NOT_INSTALLED
	if(source_program)
		source_program.copy_programming(new_program)
	programs += new_program
	new_program.on_add(src)
	return COMPONENT_PROGRAM_INSTALLED

/datum/component/nanites/proc/consume_nanites(amount, force = FALSE)
	if(!force && safety_threshold && (nanite_volume - amount < safety_threshold))
		return FALSE
	adjust_nanites(-amount)
	return (nanite_volume > 0)

/datum/component/nanites/proc/adjust_nanites(amount)
	nanite_volume = CLAMP(nanite_volume + amount, 0, max_nanites)
	if(nanite_volume <= 0) //oops we ran out
		qdel(src)

/datum/component/nanites/proc/set_nanite_bar(remove = FALSE)
	var/image/holder = host_mob.hud_list[DIAG_NANITE_FULL_HUD]
	var/icon/I = icon(host_mob.icon, host_mob.icon_state, host_mob.dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = null
	if(remove || stealth)
		return //bye icon
	var/nanite_percent = (nanite_volume / max_nanites) * 100
	switch(nanite_percent)
		if(0 to 10)
			holder.icon_state = "nanites10"
		if(10 to 20)
			holder.icon_state = "nanites20"
		if(20 to 30)
			holder.icon_state = "nanites30"
		if(30 to 40)
			holder.icon_state = "nanites40"
		if(40 to 50)
			holder.icon_state = "nanites50"
		if(50 to 60)
			holder.icon_state = "nanites60"
		if(60 to 70)
			holder.icon_state = "nanites70"
		if(70 to 80)
			holder.icon_state = "nanites80"
		if(80 to 90)
			holder.icon_state = "nanites90"
		if(90 to 100)
			holder.icon_state = "nanites100"

/datum/component/nanites/proc/on_emp(severity)
	nanite_volume *= (rand(0.60, 0.90))		//Lose 10-40% of nanites
	adjust_nanites(-(rand(5, 50)))		//Lose 5-50 flat nanite volume
	if(prob(40/severity))
		cloud_id = 0
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.on_emp(severity)

/datum/component/nanites/proc/on_shock(shock_damage)
	nanite_volume *= (rand(0.45, 0.80))		//Lose 20-55% of nanites
	adjust_nanites(-(rand(5, 50)))			//Lose 5-50 flat nanite volume
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.on_shock(shock_damage)

/datum/component/nanites/proc/on_minor_shock()
	adjust_nanites(-(rand(5, 15)))			//Lose 5-15 flat nanite volume
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.on_minor_shock()

/datum/component/nanites/proc/on_death(gibbed)
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.on_death(gibbed)

/datum/component/nanites/proc/on_hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.on_hear(message, speaker, message_language, raw_message, radio_freq, spans, message_mode)

/datum/component/nanites/proc/receive_signal(code, source = "an unidentified source")
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.receive_signal(code, source)

/datum/component/nanites/proc/check_viable_biotype()
	if(!(MOB_ORGANIC in host_mob.mob_biotypes) && !(MOB_UNDEAD in host_mob.mob_biotypes))
		qdel(src) //bodytype no longer sustains nanites

/datum/component/nanites/proc/check_access(obj/O)
	for(var/datum/nanite_program/triggered/access/access_program in programs)
		if(access_program.activated)
			return O.check_access_list(access_program.access)
		else
			return FALSE
	return FALSE

/datum/component/nanites/proc/set_volume(amount)
	nanite_volume = CLAMP(amount, 0, max_nanites)

/datum/component/nanites/proc/set_max_volume(amount)
	max_nanites = max(1, max_nanites)

/datum/component/nanites/proc/set_cloud(amount)
	cloud_id = CLAMP(amount, 0, 100)

/datum/component/nanites/proc/set_safety(amount)
	safety_threshold = CLAMP(amount, 0, max_nanites)

/datum/component/nanites/proc/set_regen(amount)
	regen_rate = amount

/datum/component/nanites/proc/confirm_nanites()
	return TRUE //yup i exist

/datum/component/nanites/proc/get_data(list/nanite_data)
	nanite_data["nanite_volume"] = nanite_volume
	nanite_data["max_nanites"] = max_nanites
	nanite_data["cloud_id"] = cloud_id
	nanite_data["regen_rate"] = regen_rate
	nanite_data["safety_threshold"] = safety_threshold
	nanite_data["stealth"] = stealth

/datum/component/nanites/proc/get_programs(list/nanite_programs)
	nanite_programs |= programs

/datum/component/nanites/proc/nanite_scan(mob/user, full_scan)
	if(!full_scan)
		if(!stealth)
			to_chat(user, "<span class='notice'><b>Nanites Detected</b></span>")
			to_chat(user, "<span class='notice'>Saturation: [nanite_volume]/[max_nanites]</span>")
			return TRUE
	else
		to_chat(user, "<span class='info'>NANITES DETECTED</span>")
		to_chat(user, "<span class='info'>================</span>")
		to_chat(user, "<span class='info'>Saturation: [nanite_volume]/[max_nanites]</span>")
		to_chat(user, "<span class='info'>Safety Threshold: [safety_threshold]</span>")
		to_chat(user, "<span class='info'>Cloud ID: [cloud_id ? cloud_id : "Disabled"]</span>")
		to_chat(user, "<span class='info'>================</span>")
		to_chat(user, "<span class='info'>Program List:</span>")
		if(stealth)
			to_chat(user, "<span class='alert'>%#$ENCRYPTED&^@</span>")
		else
			for(var/X in programs)
				var/datum/nanite_program/NP = X
				to_chat(user, "<span class='info'><b>[NP.name]</b> | [NP.activated ? "Active" : "Inactive"]</span>")
		return TRUE

/datum/component/nanites/proc/nanite_ui_data(list/data, scan_level)
	data["has_nanites"] = TRUE
	data["nanite_volume"] = nanite_volume
	data["regen_rate"] = regen_rate
	data["safety_threshold"] = safety_threshold
	data["cloud_id"] = cloud_id
	var/list/mob_programs = list()
	var/id = 1
	for(var/X in programs)
		var/datum/nanite_program/P = X
		var/list/mob_program = list()
		mob_program["name"] = P.name
		mob_program["desc"] = P.desc
		mob_program["id"] = id

		if(scan_level >= 2)
			mob_program["activated"] = P.activated
			mob_program["use_rate"] = P.use_rate
			mob_program["can_trigger"] = P.can_trigger
			mob_program["trigger_cost"] = P.trigger_cost
			mob_program["trigger_cooldown"] = P.trigger_cooldown / 10

		if(scan_level >= 3)
			mob_program["activation_delay"] = P.activation_delay
			mob_program["timer"] = P.timer
			mob_program["timer_type"] = P.get_timer_type_text()
			var/list/extra_settings = list()
			for(var/Y in P.extra_settings)
				var/list/setting = list()
				setting["name"] = Y
				setting["value"] = P.get_extra_setting(Y)
				extra_settings += list(setting)
			mob_program["extra_settings"] = extra_settings
			if(LAZYLEN(extra_settings))
				mob_program["has_extra_settings"] = TRUE

		if(scan_level >= 4)
			mob_program["activation_code"] = P.activation_code
			mob_program["deactivation_code"] = P.deactivation_code
			mob_program["kill_code"] = P.kill_code
			mob_program["trigger_code"] = P.trigger_code
		id++
		mob_programs += list(mob_program)
	data["mob_programs"] = mob_programs