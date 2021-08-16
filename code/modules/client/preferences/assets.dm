/// Assets generated from `/datum/preference` icons
/datum/asset/spritesheet/preferences
	name = "preferences"

/datum/asset/spritesheet/preferences/register()
	var/list/to_insert = list()

	for (var/preference_key in GLOB.preference_entries_by_key)
		var/datum/preference/choiced/preference = GLOB.preference_entries_by_key[preference_key]
		if (!istype(preference))
			continue

		if (!preference.should_generate_icons)
			continue

		var/list/choices = preference.get_choices_serialized()
		for (var/preference_value in choices)
			var/create_icon_of = choices[preference_value]

			var/icon/icon
			var/icon_state

			if (ispath(create_icon_of, /atom))
				var/atom/atom_icon_source = create_icon_of
				icon = initial(atom_icon_source.icon)
				icon_state = initial(atom_icon_source.icon_state)
			else if (isicon(create_icon_of))
				icon = create_icon_of
			else
				// MOTHBLOCKS TODO: Unit test this
				CRASH("[create_icon_of] is an invalid preference value (from [preference_key]:[preference_value]).")

			to_insert[preference.get_spritesheet_key(preference_value)] = list(icon, icon_state)

	for (var/spritesheet_key in to_insert)
		var/list/inserting = to_insert[spritesheet_key]
		Insert(spritesheet_key, inserting[1], inserting[2])

	return ..()

/// Returns the key that will be used in the spritesheet for a given value.
/datum/preference/proc/get_spritesheet_key(value)
	return "[savefile_key]___[sanitize_css_class_name(value)]"

/// Assets generated for the antagoninsts panel
/datum/asset/spritesheet/antagonists
	name = "antagonists"

/datum/asset/spritesheet/antagonists/register()
	var/list/generated_icons = list()
	var/list/to_insert = list()

	for (var/datum/dynamic_ruleset/ruleset as anything in subtypesof(/datum/dynamic_ruleset))
		var/datum/antagonist/antagonist_type = initial(ruleset.antag_datum)
		if (isnull(antagonist_type))
			continue

		// antag_flag is guaranteed to be unique by unit tests.
		var/spritesheet_key = serialize_antag_name(initial(ruleset.antag_flag))

		if (!isnull(generated_icons[antagonist_type]))
			to_insert[spritesheet_key] = generated_icons[antagonist_type]
			continue

		var/datum/antagonist/antagonist = new antagonist_type
		var/icon/preview_icon = antagonist.get_preview_icon()

		if (isnull(preview_icon))
			continue

		// preview_icons are not scaled at this stage INTENTIONALLY.
		// If an icon is not prepared to be scaled to that size, it looks really ugly, and this
		// makes it harder to figure out what size it *actually* is.
		generated_icons[antagonist_type] = preview_icon
		to_insert[spritesheet_key] = preview_icon

	for (var/spritesheet_key in to_insert)
		Insert(spritesheet_key, to_insert[spritesheet_key])

	return ..()
