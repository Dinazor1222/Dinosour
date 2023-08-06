///a superlist containing typecaches shared between the several fish scanning experiments for each techweb.
GLOBAL_LIST_EMPTY(scanned_fish_by_techweb)

/**
 * A special scanning experiment that unlocks further settings for the fishing portal generator.
 * Mainly as an inventive solution to many a fish source being limited to maps that have it,
 * and to make the fishing portal generator a bit than just gubby and goldfish.
 */
/datum/experiment/scanning/fish
	name = "Fish Scanning Experiment 1"
	description = "An experiment requiring different fish species scanned to unlock the 'Beach' setting for the fishing portal generator."
	performance_hint = "Scan fish. Examine scanner to review progress. Unlock new fishing portals."
	traits = EXPERIMENT_TRAIT_TYPECACHE
	points_reward = list(TECHWEB_POINT_TYPE_GENERIC = 750)
	required_atoms = list(/obj/item/fish = 4)
	scan_of_message = "Scan species of"
	///Further experiments added to the techweb when this one is completed.
	var/list/next_experiments = list(/datum/experiment/scanning/fish/second)
	///Completing a experiment may also enable a fish source to be used for use for the portal generator.
	var/fish_source_reward = /datum/fish_source/portal/beach

/**
 * We make sure the scanned list is shared between all fish scanning experiments for this techweb,
 * since this is about scanning each species, and having to redo it for each species is a hassle.
 */
/datum/experiment/scanning/fish/New(datum/techweb/techweb)
	. = ..()
	if(!techweb)
		return
	var/techweb_ref = REF(techweb)
	var/list/scanned_fish = GLOB.scanned_fish_by_techweb[techweb_ref]
	if(!scanned_fish)
		scanned_fish = list()
		GLOB.scanned_fish_by_techweb[techweb_ref] = scanned_fish
	for(var/atom_type in required_atoms)
		LAZYINITLIST(scanned_fish[atom_type])
	scanned = scanned_fish

/**
 * Registers a couple signals to review the fish scanned so far.
 * It'd be an hassle not having any way (beside memory) to know which fish species have been scanned already otherwise.
 */
/datum/experiment/scanning/fish/on_selected(datum/component/experiment_handler/experiment_handler)
	RegisterSignal(experiment_handler.parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_handler_examine))
	RegisterSignal(experiment_handler.parent, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_handler_examine_more))

/datum/experiment/scanning/fish/proc/on_handler_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("Examine the handler closer to review the fish scanned thus far.")

/datum/experiment/scanning/fish/proc/on_handler_examine_more(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("Fish scanned hitherto, if any:")
	examine_list += "<span class='info ml-1'>"
	for(var/atom_type in required_atoms)
		for(var/obj/item/fish/fish_path as anything in scanned[atom_type])
			examine_list += "[initial(fish_path.name)]"
	examine_list += "</span>"

/datum/experiment/scanning/fish/on_selected(datum/component/experiment_handler/experiment_handler)
	UnregisterSignal(experiment_handler.parent, list(COMSIG_ATOM_EXAMINE, COMSIG_ATOM_EXAMINE_MORE))

///Only scannable fish will contribute towards the experiment.
/datum/experiment/scanning/fish/final_contributing_index_checks(obj/item/fish/target, typepath)
	return target.experisci_scannable

/**
 * After a fish scanning experiment is done, more may be unlocked. If so, add them to the techweb
 * and automatically link the handler to the next experiment in the list as a bit of qol.
 */
/datum/experiment/scanning/fish/finish_experiment(datum/component/experiment_handler/experiment_handler, ...)
	. = ..()
	if(next_experiments)
		experiment_handler.linked_web.add_experiments(next_experiments)
		var/datum/experiment/next_in_line = locate(next_experiments[1]) in experiment_handler.linked_web.available_experiments
		experiment_handler.link_experiment(next_in_line)

/datum/experiment/scanning/fish/second
	name = "Fish Scanning Experiment 2"
	description = "An experiment requiring a few more species of fish to be scanned to unlock the 'Chasm' fishing portal setting."
	points_reward = list(TECHWEB_POINT_TYPE_GENERIC = 1500)
	required_atoms = list(/obj/item/fish = 8)
	next_experiments = list(/datum/experiment/scanning/fish/third, /datum/experiment/scanning/fish/holographic)
	fish_source_reward = /datum/fish_source/portal/chasm

/datum/experiment/scanning/fish/third
	name = "Fish Scanning Experiment 3"
	description = "An experiment requiring even more species of fish to be scanned to unlock the 'Ocean' setting."
	points_reward = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	required_atoms = list(/obj/item/fish = 14)
	next_experiments = list(/datum/experiment/scanning/fish/fourth)
	fish_source_reward = /datum/fish_source/portal/ocean

/datum/experiment/scanning/fish/holographic
	name = "Holographic Fish Scanning Experiment"
	description = "This one actually requires holographic fish to to unlock the 'Randomizer' setting."
	performance_hint = "You need load in the 'Beach' template at the Holodeck."
	points_reward = list(TECHWEB_POINT_TYPE_GENERIC = 500)
	required_atoms = list(/obj/item/fish/holo = 4)
	next_experiments = null
	fish_source_reward = /datum/fish_source/portal/random

///All holo fishes are normally unscannable, but this is an experiment focused on them, so...
/datum/experiment/scanning/fish/holographic/final_contributing_index_checks(obj/item/fish/target, typepath)
	return TRUE

/datum/experiment/scanning/fish/fourth
	name = "Fish Scanning Experiment 4"
	description = "An experiment requiring lotsa fish species scanned for the 'Hyperspace' setting."
	points_reward = list(TECHWEB_POINT_TYPE_GENERIC = 3000)
	required_atoms = list(/obj/item/fish = 21)
	next_experiments = null
	fish_source_reward = /datum/fish_source/portal/hyperspace
