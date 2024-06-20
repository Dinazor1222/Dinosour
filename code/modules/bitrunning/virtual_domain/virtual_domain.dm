/**
 * # Virtual Domains
 * Create your own: Read the readme file in the '_maps/virtual_domains' folder.
 */
/datum/lazy_template/virtual_domain
	map_dir = "_maps/virtual_domains"
	map_name = "None"
	key = "Virtual Domain"
	place_on_top = TRUE
	/// The map file to load
	var/filename = "virtual_domain.dmm"
	/// The start time of the map. Used to calculate time taken
	var/start_time
	/// This map is specifically for unit tests. Shouldn't display in game
	var/test_only = FALSE

	/**
	 * Generic UI
	 */

	/// Cost of this map to load
	var/cost = BITRUNNER_COST_NONE
	/// The description of the map for the console UI
	var/desc = "A map."
	/// Affects the ui and ability to scan info.
	var/difficulty = BITRUNNER_DIFFICULTY_NONE
	/// Write these to help complete puzzles and other objectives. Viewed in the domain info ability.
	var/help_text
	// Name to show in the UI
	var/name = "Virtual Domain"
	/// Points to reward for completion. Used to purchase new domains and calculate ore rewards.
	var/reward_points = BITRUNNER_REWARD_MIN

	/**
	 * Player customization
	 */

	/// If this domain blocks the use of items from disks, for whatever reason
	var/forbids_disk_items = FALSE
	/// If this domain blocks the use of spells from disks, for whatever reason
	var/forbids_disk_spells = FALSE
	/// Any outfit that you wish to force on avatars. Overrides preferences
	var/datum/outfit/forced_outfit

	/**
	 * Loot
	 */

	/// An assoc list of typepath/amount to spawn on completion. Not weighted - the value is the amount
	var/list/completion_loot
	/// An accoc list of typepath/amount to spawn from secondary objectives. Not weighted - the value is the total number of items that can be obtained.
	var/list/secondary_loot = list()
	/// Number of secondary loot boxes generated. Resets when the domain is reloaded.
	var/secondary_loot_generated
	/// Has this domain been beaten with high enough score to spawn a tech disk?
	var/disk_reward_spawned = FALSE

	/**
	 * Modularity
	 */

	/// Whether to display this as a modular map
	var/is_modular = FALSE
	/// Byond will look for modular mob segment landmarks then choose from here at random. You can make them unique also.
	var/list/datum/modular_mob_segment/mob_modules = list()
	/// Forces all mob modules to only load once
	var/modular_unique_mobs = FALSE

	/**
	 * Spawning
	 */

	/// Looks for random landmarks to spawn on.
	var/randomized_spawns = FALSE
	/// If this domain has a permanent way out.
	var/single_hololadder = FALSE
	/// Useful for maps that have random spawns, etc.
	var/unlimited_respawns = FALSE


/// Sends a point to any loot signals on the map
/datum/lazy_template/virtual_domain/proc/add_points(points_to_add)
	SEND_SIGNAL(src, COMSIG_BITRUNNER_GOAL_POINT, points_to_add)


/// Overridable proc to be called after the map is loaded.
/datum/lazy_template/virtual_domain/proc/setup_domain(list/created_atoms)
	return
