/**
 * # Virtual Domains
 * Create your own: Read the readme file in the '_maps/virtual_domains' folder.
 */
/datum/lazy_template/virtual_domain
	map_dir = "_maps/virtual_domains"
	map_name = "None"
	key = "Virtual Domain"

	/// Cost of this map to load
	var/cost = BITRUNNER_COST_NONE
	/// The safehouse to load into the map
	var/datum/map_template/safehouse/safehouse_path = /datum/map_template/safehouse/den
	/// Any outfit that you wish to force on avatars. Overrides preferences
	var/datum/outfit/forced_outfit
	/// The description of the map for the console UI
	var/desc = "A map."
	/// The 'difficulty' of the map, which affects the ui and ability to scan info.
	var/difficulty = BITRUNNER_DIFFICULTY_NONE
	/// The map file to load
	var/filename = "virtual_domain.dmm"
	/// Information given to connected clients via ability
	var/help_text
	/// Byond will look for modular mob segment landmarks then choose from here at random. You can make them unique also.
	var/list/datum/modular_mob_segment/mob_modules = list()
	/// On initialize, will look for map module landmarks then choose one from this list.
	var/list/datum/map_template/modular/room_modules = list()
	/// An assoc list of typepath/amount to spawn on completion. Not weighted - the value is the amount
	var/list/extra_loot
	/// Forces all mob modules to only load once
	var/modular_unique_mobs = FALSE
	/// Forces all room modules to only load once
	var/modular_unique_rooms = FALSE
	// Name to show in the UI
	var/name = "Virtual Domain"
	/// Points to reward for completion. Used to purchase new domains and calculate ore rewards.
	var/reward_points = BITRUNNER_REWARD_MIN
	/// The start time of the map. Used to calculate time taken
	var/start_time
	/// This map is specifically for unit tests. Shouldn't display in game
	var/test_only = FALSE
