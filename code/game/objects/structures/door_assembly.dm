obj/structure/door_assembly
	icon = 'icons/obj/doors/door_assembly.dmi'

	name = "Airlock Assembly"
	icon_state = "door_as_0"
	anchored = 0
	density = 1
	var/state = 0
	var/mineral = null
	var/typetext = null
	var/icontext = null
	var/base_icon_state = "door_as_0"
	var/glass_base_icon_state = "door_as_g0"
	var/obj/item/weapon/airlock_electronics/electronics = null
	var/airlock_type = /obj/machinery/door/airlock //the type path of the airlock once completed
	var/glass_type = /obj/machinery/door/airlock/glass
	var/glass = null
	var/created_name = null

	New()
		base_icon_state = copytext(icon_state,1,lentext(icon_state))

	door_assembly_0
		name = "Airlock Assembly"
		icon_state = "door_as_1"
		airlock_type = /obj/machinery/door/airlock
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_com
		name = "Command Airlock Assembly"
		icon_state = "door_as_com1"
		glass_base_icon_state = "door_as_gcom"
		typetext = "command"
		icontext = "com"
		glass_type = /obj/machinery/door/airlock/glass_command
		airlock_type = /obj/machinery/door/airlock/command
		anchored = 1
		density = 1
		state = 1
		glass = 0

		glass
			glass = 1
			icon_state = "door_as_gcom1"

	door_assembly_sec
		name = "Security Airlock Assembly"
		icon_state = "door_as_sec1"
		glass_base_icon_state = "door_as_gsec"
		typetext = "security"
		icontext = "sec"
		glass_type = /obj/machinery/door/airlock/glass_security
		airlock_type = /obj/machinery/door/airlock/security
		anchored = 1
		density = 1
		state = 1
		glass = 0

		glass
			glass = 1
			icon_state = "door_as_gsec1"

	door_assembly_eng
		name = "Engineering Airlock Assembly"
		icon_state = "door_as_eng1"
		glass_base_icon_state = "door_as_geng"
		typetext = "engineering"
		icontext = "eng"
		glass_type = /obj/machinery/door/airlock/glass_engineering
		airlock_type = /obj/machinery/door/airlock/engineering
		anchored = 1
		density = 1
		state = 1
		glass = 0

		glass
			glass = 1
			icon_state = "door_as_geng1"

	door_assembly_min
		name = "Mining Airlock Assembly"
		icon_state = "door_as_min1"
		glass_base_icon_state = "door_as_gmin"
		typetext = "mining"
		icontext = "min"
		glass_type = /obj/machinery/door/airlock/glass_mining
		airlock_type = /obj/machinery/door/airlock/mining
		anchored = 1
		density = 1
		state = 1
		glass = 0

		glass
			glass = 1
			icon_state = "door_as_gmin1"

	door_assembly_atmo
		name = "Atmospherics Airlock Assembly"
		icon_state = "door_as_atmo1"
		glass_base_icon_state = "door_as_gatmo"
		typetext = "atmos"
		icontext = "atmo"
		glass_type = /obj/machinery/door/airlock/glass_atmos
		airlock_type = /obj/machinery/door/airlock/atmos
		anchored = 1
		density = 1
		state = 1
		glass = 0

		glass
			glass = 1
			icon_state = "door_as_gatmo1"

	door_assembly_research
		name = "Research Airlock Assembly"
		icon_state = "door_as_res1"
		glass_base_icon_state = "door_as_gres"
		typetext = "research"
		icontext = "res"
		glass_type = /obj/machinery/door/airlock/glass_research
		airlock_type = /obj/machinery/door/airlock/research
		anchored = 1
		density = 1
		state = 1
		glass = 0

		glass
			glass = 1
			icon_state = "door_as_gres1"

	door_assembly_science
		name = "Science Airlock Assembly"
		icon_state = "door_as_sci1"
		glass_base_icon_state = "door_as_gsci"
		typetext = "science"
		icontext = "sci"
		glass_type = /obj/machinery/door/airlock/glass_science
		airlock_type = /obj/machinery/door/airlock/science
		anchored = 1
		density = 1
		state = 1
		glass = 0

		glass
			glass = 1
			icon_state = "door_as_gsci1"

	door_assembly_med
		name = "Medical Airlock Assembly"
		icon_state = "door_as_med1"
		typetext = "medical"
		icontext = "med"
		airlock_type = /obj/machinery/door/airlock/medical
		anchored = 1
		density = 1
		state = 1

		glass
			mineral = "glass"
			icon_state = "door_as_gmed1"

	door_assembly_mai
		name = "Maintenance Airlock Assembly"
		icon_state = "door_as_mai1"
		typetext = "maintenance"
		icontext = "mai"
		airlock_type = /obj/machinery/door/airlock/maintenance
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_ext
		name = "External Airlock Assembly"
		icon_state = "door_as_ext1"
		typetext = "external"
		icontext = "ext"
		airlock_type = /obj/machinery/door/airlock/external
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_fre
		name = "Freezer Airlock Assembly"
		icon_state = "door_as_fre1"
		typetext = "freezer"
		icontext = "fre"
		airlock_type = /obj/machinery/door/airlock/freezer
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_hatch
		name = "Airtight Hatch Assembly"
		icon_state = "door_as_hatch1"
		typetext = "hatch"
		icontext = "hatch"
		airlock_type = /obj/machinery/door/airlock/hatch
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_mhatch
		name = "Maintenance Hatch Assembly"
		icon_state = "door_as_mhatch1"
		typetext = "maintenance_hatch"
		icontext = "mhatch"
		airlock_type = /obj/machinery/door/airlock/maintenance_hatch
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_glass
		name = "Glass Airlock Assembly"
		icon_state = "door_as_g1"
		airlock_type = /obj/machinery/door/airlock/glass
		anchored = 1
		density = 1
		state = 1
		mineral = "glass"

	door_assembly_gold
		name = "Gold Airlock Assembly"
		icon_state = "door_as_gold1"
		airlock_type = /obj/machinery/door/airlock/gold
		anchored = 1
		density = 1
		state = 1
		mineral = "gold"

	door_assembly_silver
		name = "Silver Airlock Assembly"
		icon_state = "door_as_silver1"
		airlock_type = /obj/machinery/door/airlock/silver
		anchored = 1
		density = 1
		state = 1
		mineral = "silver"

	door_assembly_diamond
		name = "Diamond Airlock Assembly"
		icon_state = "door_as_diamond1"
		airlock_type = /obj/machinery/door/airlock/diamond
		anchored = 1
		density = 1
		state = 1
		mineral = "diamond"

	door_assembly_uranium
		name = "Uranium Airlock Assembly"
		icon_state = "door_as_uranium1"
		airlock_type = /obj/machinery/door/airlock/uranium
		anchored = 1
		density = 1
		state = 1
		mineral = "uranium"

	door_assembly_plasma
		name = "Plasma Airlock Assembly"
		icon_state = "door_as_plasma1"
		airlock_type = /obj/machinery/door/airlock/plasma
		anchored = 1
		density = 1
		state = 1
		mineral = "plasma"

	door_assembly_clown
		name = "Bananium Airlock Assembly"
		desc = "Honk"
		icon_state = "door_as_clown1"
		airlock_type = /obj/machinery/door/airlock/clown
		anchored = 1
		density = 1
		state = 1
		mineral = "clown"

	door_assembly_sandstone
		name = "Sandstone Airlock Assembly"
		icon_state = "door_as_sandstone1"
		airlock_type = /obj/machinery/door/airlock/sandstone
		anchored = 1
		density = 1
		state = 1
		mineral = "sandstone"

	door_assembly_highsecurity // Borrowing this until WJohnston makes sprites for the assembly
		name = "High Tech Security Assembly"
		icon_state = "door_as_highsec1"
		typetext = "highsecurity"
		icontext = "highsec"
		airlock_type = /obj/machinery/door/airlock/highsecurity
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_vault
		name = "Vault Door Assembly"
		icon_state = "door_as_vault1"
		typetext = "vault"
		icontext = "vault"
		airlock_type = /obj/machinery/door/airlock/vault
		anchored = 1
		density = 1
		state = 1
		glass = 0

/obj/structure/door_assembly/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/pen))
		var/t = copytext(stripped_input(user, "Enter the name for the door.", src.name, src.created_name),1,MAX_NAME_LEN)
		if(!t)	return
		if(!in_range(src, usr) && src.loc != usr)	return
		created_name = t
		return

	else if(istype(W, /obj/item/weapon/airlock_painter)) // |- Ricotez
	//INFORMATION ABOUT ADDING A NEW AIRLOCK TO THE PAINT LIST:
	//If your airlock has a regular version, add it to the list with regular versions.
	//If your airlock has a glass version, add it to the list with glass versions.
	//Do NOT add your airlock to a list if it does not have a version for that list,
	//	or you will get broken icons.
	//If you do this properly, you can just add the typetext and icontext of your airlock
	//  to the big switch without having to make exceptions for glass airlocks, it will
	//  simply be unavailable if the painter is used on an airlock of the wrong type.
	//If your airlock has both a regular and a glass version, remember to also add the
	//  icontext as exception in the part of the code that deals with turning a regular
	//  airlock into a glass airlock, else your airlock can't transition from regular to
	//  glass and will instead revert back to the white sprite.
	// |- Ricotez
		var/obj/item/weapon/airlock_painter/WT = W
		if(WT.ink.charges)
			var/icontype
			var/optionlist
			var/glasstext = ""
			var/gicontext = ""
			if(src.mineral)
				if(src.mineral == "glass")
					gicontext = "g"
					glasstext = "glass_"
					//These airlocks have a glass version.
					optionlist = list("Default", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Mining")
				else
					user << "The painter does not work on airlocks coated in minerals!"
					return
			else
				//These airlocks have a regular version.
				optionlist = list("Default", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Mining", "Maintenance", "External", "High Security")


			icontype = input(user, "Please select a paintjob for this glass airlock.") in optionlist
			if(!in_range(src, usr) && src.loc != usr)	return
			switch(icontype)
				if("Default")
					if(src.mineral == "glass")
						glasstext = "glass"
					typetext = ""
					icontext = ""
				if("Engineering")
					typetext = "engineering"
					icontext = "eng"
				if("Atmospherics")
					typetext = "atmos"
					icontext = "atmo"
				if("Security")
					typetext = "security"
					icontext = "sec"
				if("Command")
					typetext = "command"
					icontext = "com"
				if("Medical")
					typetext = "medical"
					icontext = "med"
				if("Research")
					typetext = "research"
					icontext = "res"
				if("Mining")
					typetext = "mining"
					icontext = "min"
				if("Maintenance")
					typetext = "maintenance"
					icontext = "mai"
				if("External")
					typetext = "special"
					icontext = "ext"
				if("High Security")
					typetext = "highsecurity"
					icontext = "highsec"
			src.airlock_type = text2path("/obj/machinery/door/airlock/[glasstext][typetext]")
			src.base_icon_state = "door_as_[gicontext][icontext]"
			user << "\blue You change the paintjob on the airlock assembly."
			WT.use()
		else
			user << "\blue There aren't any charges left!"
			return

	else if(istype(W, /obj/item/weapon/weldingtool) && !anchored )
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			user.visible_message("[user] dissassembles the airlock assembly.", "You start to dissassemble the airlock assembly.")
			playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)

			if(do_after(user, 40))
				if(!src || !WT.isOn()) return
				user << "\blue You've dissasembled the airlock assembly."
				new /obj/item/stack/sheet/metal(get_turf(src), 4)
				if (mineral)
					if (mineral == "glass")
						new /obj/item/stack/sheet/rglass(get_turf(src))
					else
						var/M = text2path("/obj/item/stack/sheet/mineral/[mineral]")
						new M(get_turf(src))
						new M(get_turf(src))
				del(src)
		else
			user << "\blue You need more welding fuel to dissassemble the airlock assembly."
			return

	else if(istype(W, /obj/item/weapon/wrench) && !anchored )
		playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
		user.visible_message("[user] secures the airlock assembly to the floor.", "You start to secure the airlock assembly to the floor.")

		if(do_after(user, 40))
			if(!src) return
			user << "\blue You've secured the airlock assembly."
			src.name = "Secured Airlock Assembly"
			src.anchored = 1

	else if(istype(W, /obj/item/weapon/wrench) && anchored )
		playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
		user.visible_message("[user] unsecures the airlock assembly from the floor.", "You start to unsecure the airlock assembly from the floor.")
		if(do_after(user, 40))
			if(!src) return
			user << "\blue You've unsecured the airlock assembly."
			src.name = "Airlock Assembly"
			src.anchored = 0

	else if(istype(W, /obj/item/weapon/cable_coil) && state == 0 && anchored )
		var/obj/item/weapon/cable_coil/coil = W
		user.visible_message("[user] wires the airlock assembly.", "You start to wire the airlock assembly.")
		if(do_after(user, 40))
			if(!src) return
			coil.use(1)
			src.state = 1
			user << "\blue You've wired the airlock assembly."
			src.name = "Wired Airlock Assembly"

	else if(istype(W, /obj/item/weapon/wirecutters) && state == 1 )
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		user.visible_message("[user] cuts the wires from the airlock assembly.", "You start to cut the wires from airlock assembly.")

		if(do_after(user, 40))
			if(!src) return
			user << "\blue You've cut the wires from the airlock assembly."
			new/obj/item/weapon/cable_coil(get_turf(user), 1)
			src.state = 0
			src.name = "Secured Airlock Assembly"

	else if(istype(W, /obj/item/weapon/airlock_electronics) && state == 1 )
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		user.visible_message("[user] installs the electronics into the airlock assembly.", "You start to install electronics into the airlock assembly.")
		user.drop_item()
		W.loc = src

		if(do_after(user, 40))
			if(!src) return
			user << "\blue You've installed the airlock electronics."
			src.state = 2
			src.name = "Near finished Airlock Assembly"
			src.electronics = W
		else
			W.loc = src.loc

			//del(W)

	else if(istype(W, /obj/item/weapon/crowbar) && state == 2 )
		playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
		user.visible_message("[user] removes the electronics from the airlock assembly.", "You start to remove the electronics from the airlock assembly.")

		if(do_after(user, 40))
			if(!src) return
			user << "\blue You've removed the airlock electronics."
			src.state = 1
			src.name = "Wired Airlock Assembly"
			var/obj/item/weapon/airlock_electronics/ae
			if (!electronics)
				ae = new/obj/item/weapon/airlock_electronics( src.loc )
			else
				ae = electronics
				electronics = null
				ae.loc = src.loc
	else if(istype(W, /obj/item/stack/sheet) && !mineral)
		var/obj/item/stack/sheet/G = W
		if(G)
			if(G.amount>=1)
				if(G.type == /obj/item/stack/sheet/rglass)
					playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
					user.visible_message("[user] adds [G.name] to the airlock assembly.", "You start to install [G.name] into the airlock assembly.")
					if(do_after(user, 40))
						user << "\blue You've installed reinforced glass windows into the airlock assembly."
						G.use(1)
						src.mineral = "glass"
						src.name = "Near finished Window Airlock Assembly"
						if(icontext in list("eng", "atmo", "sec", "com", "med", "res", "min")) //Make sure this airlock actually has a glass version.
							src.airlock_type = text2path("/obj/machinery/door/airlock/glass_[typetext]")
						else
							//This airlock is default or does not have a glass version, so we revert to the default glass airlock. |- Ricotez
							src.airlock_type = /obj/machinery/door/airlock/glass
							typetext = ""
							icontext = ""
						src.base_icon_state = "door_as_g[icontext]" //this will be applied to the icon_state with the correct state number at the proc's end.
				else if(istype(G, /obj/item/stack/sheet/mineral))
					var/M = G.sheettype
					if(G.amount>=2)
						playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
						user.visible_message("[user] adds [G.name] to the airlock assembly.", "You start to install [G.name] into the airlock assembly.")
						if(do_after(user, 40))
							user << "\blue You've installed [M] plating into the airlock assembly."
							G.use(2)
							src.mineral = "[M]"
							src.name = "Near finished [M] Airlock Assembly"
							src.airlock_type = text2path ("/obj/machinery/door/airlock/[M]")
							src.base_icon_state = "door_as_[M]"

	else if(istype(W, /obj/item/weapon/screwdriver) && state == 2 )
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		user << "\blue You start finishing the airlock."

		if(do_after(user, 40))
			if(!src) return
			user << "\blue You've finished the airlock."
			var/obj/machinery/door/airlock/door
			//The below cluster of if-else-statements is a result of the differences between normal
			//  and mineral doors. |- Ricotez
			if (mineral)
				if(mineral == "glass")
					if(!typetext)
						airlock_type = /obj/machinery/door/airlock/glass
					else
						airlock_type = text2path("/obj/machinery/door/airlock/glass_[typetext]")
				else
					airlock_type = text2path("/obj/machinery/door/airlock/[mineral]")
			else
				if(!typetext)
					airlock_type = /obj/machinery/door/airlock
				else
					airlock_type = text2path("/obj/machinery/door/airlock/[typetext]")
			door = new src.airlock_type( src.loc )
			//door.req_access = src.req_access
			door.electronics = src.electronics
			door.req_access = src.electronics.conf_access
			if(created_name)
				door.name = created_name
			src.electronics.loc = door
			del(src)
	else
		..()
	icon_state = "[base_icon_state][state]"
	//This updates the icon_state. They are named as "door_as1_eng" where the 1 in that example
	//represents what state it's in. So the most generic algorithm for the correct updating of
	//this is simply to change the number.