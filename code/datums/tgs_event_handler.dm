/datum/tgs_event_handler/impl/HandleEvent(event_code, ...)
	switch(event_code)
		if(TGS_EVENT_REBOOT_MODE_CHANGE)
			var/list/reboot_mode_lookup = list ("[TGS_REBOOT_MODE_NORMAL]" = "be normal", "[TGS_REBOOT_MODE_SHUTDOWN]" = "shutdown the server", "[TGS_REBOOT_MODE_RESTART]" = "hard restart the server")
			var old_reboot_mode = args[2]
			var new_reboot_mode = args[3]
			message_admins("TGS: Reboot will no longer [reboot_mode_lookup["[old_reboot_mode]"]], it will instead [reboot_mode_lookup["[new_reboot_mode]"]]")
			break
		if(TGS_EVENT_PORT_SWAP)
			message_admins("TGS: Changing port from [world.port] to [args[2]]")
			break
		if(TGS_EVENT_INSTANCE_RENAMED)
			message_admins("TGS: Instance renamed to from [world.TgsInstanceName()] to [args[2]]")
			break
		if(TGS_EVENT_COMPILE_START)
			message_admins("TGS: Deployment started, new game version incoming...")
		if(TGS_EVENT_COMPILE_CANCELLED)
			message_admins("TGS: Deployment cancelled!")
		if(TGS_EVENT_COMPILE_FAILURE)
			message_admins("TGS: Deployment failed!")
		if(TGS_EVENT_DEPLOYMENT_COMPLETE)
			message_admins("TGS: Deployment complete!")
			to_chat(world, "<span class='boldannounce'>Server updated, changes will be applied on the next round...</span>")
