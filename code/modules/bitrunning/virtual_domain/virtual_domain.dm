/**
 * # Virtual Domains
 * This loads a base level, then users can select the preset upon it.
 * Create your own: Read the readme file in the '_maps/virtual_domains' folder.
 */
/datum/lazy_template/virtual_domain
	map_dir = "_maps/virtual_domains"
	map_height = 75 // these should NOT extend beyond 75x75
	map_width = 75
	map_name = "None"

	/// Cost of this map to load
	var/cost = BITRUNNER_COST_NONE
	/// The description of the map
	var/desc = "A map."
	/// The 'difficulty' of the map, which affects the ui and ability to scan info.
	var/difficulty = BITRUNNER_DIFFICULTY_NONE
	/// An assoc list of typepath/amount to spawn on completion. Not weighted - the value is the amount
	var/list/extra_loot
	/// The map file to load
	var/filename = "virtual_domain.dmm"
	/// Any outfit that you wish to force on avatars. Overrides preferences
	var/datum/outfit/forced_outfit
	/// Information given to connected clients via ability
	var/help_text
	/// For blacklisting purposes
	var/id
	// Name to show in the UI
	var/name = "Virtual Domain"
	/// Points to reward for completion. Used to purchase new domains and calculate ore rewards.
	var/reward_points = BITRUNNER_REWARD_MIN
	/// The start time of the map. Used to calculate time taken
	var/start_time
	/// This map is specifically for unit tests. Shouldn't display in game
	var/test_only = FALSE
	/// The safehouse to load into the map
	var/datum/map_template/safehouse/safehouse_path = /datum/map_template/safehouse/den

/turf/closed/indestructible/binary
	name = "tear in the fabric of reality"
	icon = 'icons/turf/floors.dmi'
	icon_state = "binary"

