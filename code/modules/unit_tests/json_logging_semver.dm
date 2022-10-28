/// Currently this only checks for a valid semver string
/datum/unit_test/json_logging_semver

/datum/unit_test/json_logging_semver/Run()
	for(var/datum/log_entry/entry as anything in subtypesof(/datum/log_entry))
		var/log_version = initial(entry.version)
		// check for invalid log version
		if(!log_version || log_version == "0.0.0")
			TEST_FAIL("[entry] has no log version; how did you mess this up?")
			continue
		var/regex/version_regex = regex("^[0-9]+\\.[0-9]+\\.[0-9]+$")
		if(!version_regex.Find(log_version))
			TEST_FAIL("[entry] has an invalid log version; it must be a semver version string")
			continue
