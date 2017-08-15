/obj/item/device/spacepod_equipment/weaponry/proc/fire_weapons()
	if(my_atom.next_firetime > world.time)
		to_chat(usr, "<span class='warning'>Your weapons are recharging.</span>")
		return
	var/turf/firstloc
	var/turf/secondloc
	if(!my_atom.cell.use(shot_cost))
		to_chat(usr, "<span class='warning'>Insufficient charge to fire the weapons</span>")
		return
	var/olddir
	for(var/i in 0 to shots_per-1)
		if(olddir != my_atom.dir)
			switch(my_atom.dir)
				if(NORTH)
					firstloc = get_step(my_atom, NORTH)
					secondloc = get_step(firstloc,EAST)
				if(SOUTH)
					firstloc = get_turf(my_atom)
					secondloc = get_step(firstloc,EAST)
				if(EAST)
					firstloc = get_step(my_atom, EAST)
					secondloc = get_step(firstloc,NORTH)
				if(WEST)
					firstloc = get_turf(my_atom)
					secondloc = get_step(firstloc,NORTH)
		olddir = dir
		var/obj/item/projectile/projone = new projectile_type(firstloc)
		var/obj/item/projectile/projtwo = new projectile_type(secondloc)
		projone.starting = get_turf(my_atom)
		projone.firer = usr
		projone.def_zone = "chest"
		projtwo.starting = get_turf(my_atom)
		projtwo.firer = usr
		projtwo.def_zone = "chest"
		INVOKE_ASYNC(src, .proc/do_fire, projone, projtwo)
		sleep(2)
	my_atom.next_firetime = world.time + fire_delay


/obj/item/device/spacepod_equipment/weaponry/proc/do_fire(obj/item/projectile/projone, obj/item/projectile/projtwo)
    playsound(src, fire_sound, 50, 1)
    projone.dumbfire(my_atom.dir)
    projtwo.dumbfire(my_atom.dir)

/datum/spacepod/equipment
	var/obj/spacepod/my_atom
	var/list/obj/item/device/spacepod_equipment/installed_modules = list() // holds an easy to access list of installed modules

	var/obj/item/device/spacepod_equipment/weaponry/weapon_system // weapons system
	var/obj/item/device/spacepod_equipment/misc/misc_system // misc system
	var/obj/item/device/spacepod_equipment/cargo/cargo_system // cargo system
	var/obj/item/device/spacepod_equipment/cargo/sec_cargo_system // secondary cargo system
	var/obj/item/device/spacepod_equipment/lock/lock_system // lock system

/datum/spacepod/equipment/New(var/obj/spacepod/SP)
	..()
	if(istype(SP))
		my_atom = SP

/obj/item/device/spacepod_equipment
	name = "equipment"
	var/obj/spacepod/my_atom
	var/occupant_mod = 0	// so any module can modify occupancy
	var/list/storage_mod = list("slots" = 0, "w_class" = 0)		// so any module can modify storage slots

/obj/item/device/spacepod_equipment/proc/removed(var/mob/user) // So that you can unload cargo when you remove the module
	return

/*
///////////////////////////////////////
/////////Weapon System///////////////////
///////////////////////////////////////
*/

/obj/item/device/spacepod_equipment/weaponry
	name = "pod weapon"
	desc = "You shouldn't be seeing this"
	icon = 'icons/vehicles/spacepod.dmi'
	icon_state = "blank"
	var/obj/item/projectile/projectile_type
	var/shot_cost = 0
	var/shots_per = 1
	var/fire_sound
	var/fire_delay = 15

/obj/item/device/spacepod_equipment/weaponry/taser
	name = "disabler system"
	desc = "A weak taser system for space pods, fires disabler beams."
	icon_state = "weapon_taser"
	projectile_type = /obj/item/projectile/beam/disabler
	shot_cost = 400
	fire_sound = 'sound/weapons/Taser.ogg'

/obj/item/device/spacepod_equipment/weaponry/burst_taser
	name = "burst taser system"
	desc = "A weak taser system for space pods, this one fires 3 at a time."
	icon_state = "weapon_burst_taser"
	projectile_type = /obj/item/projectile/beam/disabler
	shot_cost = 1200
	shots_per = 3
	fire_sound = 'sound/weapons/Taser.ogg'
	fire_delay = 30

/obj/item/device/spacepod_equipment/weaponry/laser
	name = "laser system"
	desc = "A weak laser system for space pods, fires concentrated bursts of energy."
	icon_state = "weapon_laser"
	projectile_type = /obj/item/projectile/beam
	shot_cost = 600
	fire_sound = 'sound/weapons/Laser.ogg'

// MINING LASERS
/obj/item/device/spacepod_equipment/weaponry/mining_laser_basic
	name = "weak mining laser system"
	desc = "A weak mining laser system for space pods, fires bursts of energy that cut through rock."
	icon = 'goon/icons/pods/ship.dmi'
	icon_state = "pod_taser"
	projectile_type = /obj/item/projectile/kinetic/pod
	shot_cost = 300
	fire_delay = 14
	fire_sound = 'sound/weapons/Kenetic_accel.ogg'

/obj/item/device/spacepod_equipment/weaponry/mining_laser
	name = "mining laser system"
	desc = "A mining laser system for space pods, fires bursts of energy that cut through rock."
	icon = 'goon/icons/pods/ship.dmi'
	icon_state = "pod_m_laser"
	projectile_type = /obj/item/projectile/kinetic/pod/regular
	shot_cost = 250
	fire_delay = 10
	fire_sound = 'sound/weapons/Kenetic_accel.ogg'

/obj/item/device/spacepod_equipment/weaponry/plasma_cutter
	name = "plasma cutter system"
	desc = "A plasma cutter system for space pods. It is capable of expelling concentrated plasma bursts to mine or cut off xeno limbs!"
	icon = 'goon/icons/pods/ship.dmi'
	icon_state = "pod_p_cutter"
	projectile_type = /obj/item/projectile/plasma
	shot_cost = 250
	fire_delay = 10
	fire_sound = 'sound/weapons/plasma_cutter.ogg'

/obj/item/device/spacepod_equipment/weaponry/plasma_cutter/adv
	name = "enhanced plasma cutter system"
	desc = "An enhanced plasma cutter system for space pods. It is capable of expelling concentrated plasma bursts to mine or cut off xeno faces!"
	icon_state = "pod_ap_cutter"
	projectile_type = /obj/item/projectile/plasma/adv
	shot_cost = 200
	fire_delay = 8

/*
///////////////////////////////////////
/////////Misc. System///////////////////
///////////////////////////////////////
*/

/obj/item/device/spacepod_equipment/misc
	name = "pod misc"
	desc = "You shouldn't be seeing this"
	icon = 'goon/icons/pods/ship.dmi'
	icon_state = "blank"
	var/enabled

/obj/item/device/spacepod_equipment/misc/tracker
	name = "\improper spacepod tracking system"
	desc = "A tracking device for spacepods."
	icon_state = "pod_locator"
	enabled = TRUE

/obj/item/device/spacepod_equipment/misc/tracker/proc/get_pod_info()
	var/obj/spacepod/M = src.loc
	if(!M)
		return 0
	var/cell_charge = max(0, M.cell.charge)
	var/answer = {"<b>Name:</b> [M.name]
	<b>Integrity:</b> [M.obj_integrity/M.max_integrity*100]%
	<b>Cell charge:</b> [isnull(cell_charge)?"Not found":"[M.cell.percent()]%"]
	<b>Airtank:</b> [M.return_pressure()]kPa
	<b>Pilot:</b> [M.pilot||"None"]
	<b>Location:</b> [get_area(M)||"Unknown"] "}

	return answer

/obj/item/device/spacepod_equipment/misc/tracker/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		if(enabled)
			enabled = FALSE
			user.show_message("<span class='notice'>You disable \the [src]'s power.")
			return
		enabled = TRUE
		user.show_message("<span class='notice'>You enable \the [src]'s power.</span>")
	else
		..()

/*
///////////////////////////////////////
/////////Cargo System//////////////////
///////////////////////////////////////
*/

/obj/item/device/spacepod_equipment/cargo
	name = "pod cargo"
	desc = "You shouldn't be seeing this"
	icon = 'icons/vehicles/spacepod.dmi'
	icon_state = "cargo_blank"
	var/obj/storage = null

/obj/item/device/spacepod_equipment/cargo/proc/passover(var/obj/item/I)
	return

/obj/item/device/spacepod_equipment/cargo/proc/unload() // called by unload verb
	if(storage)
		storage.forceMove(get_turf(my_atom))
		storage = null

/obj/item/device/spacepod_equipment/cargo/removed(var/mob/user) // called when system removed
	. = ..()
	unload()

// Ore System
/obj/item/device/spacepod_equipment/cargo/ore
	name = "spacepod ore storage system"
	desc = "An ore storage system for spacepods. Scoops up any ore you drive over."
	icon_state = "cargo_ore"

/obj/item/device/spacepod_equipment/cargo/ore/passover(var/obj/item/I)
	if(storage && istype(I,/obj/item/weapon/ore))
		I.forceMove(storage)

// Crate System
/obj/item/device/spacepod_equipment/cargo/crate
	name = "spacepod crate storage system"
	desc = "A heavy duty storage system for spacepods. Holds one crate."
	icon_state = "cargo_crate"

/*
///////////////////////////////////////
/////////Secondary Cargo System////////
///////////////////////////////////////
*/

/obj/item/device/spacepod_equipment/sec_cargo
	name = "secondary cargo"
	desc = "you shouldn't be seeing this"
	icon = 'icons/vehicles/spacepod.dmi'
	icon_state = "blank"

// Passenger Seat
/obj/item/device/spacepod_equipment/sec_cargo/chair
	name = "passenger seat"
	desc = "A passenger seat for a spacepod."
	icon_state = "sec_cargo_chair"
	occupant_mod = 1

// Loot Box
/obj/item/device/spacepod_equipment/sec_cargo/loot_box
	name = "loot box"
	desc = "A small compartment to store valuables."
	icon_state = "sec_cargo_loot"
	storage_mod = list("slots" = 7, "w_class" = 14)

/*
///////////////////////////////////////
/////////Lock System///////////////////
///////////////////////////////////////
*/

/obj/item/device/spacepod_equipment/lock
	name = "pod lock"
	desc = "You shouldn't be seeing this"
	icon = 'icons/vehicles/spacepod.dmi'
	icon_state = "blank"
	var/mode = 0
	var/id = null

// Key and Tumbler System
/obj/item/device/spacepod_equipment/lock/keyed
	name = "spacepod tumbler lock"
	desc = "A locking system to stop podjacking. This version uses a standalone key."
	icon_state = "lock_tumbler"
	var/static/id_source = 0

/obj/item/device/spacepod_equipment/lock/keyed/Initialize()
	. = ..()
	id = ++id_source

// The key
/obj/item/device/spacepod_key
	name = "spacepod key"
	desc = "A key for a spacepod lock."
	icon = 'icons/vehicles/spacepod.dmi'
	icon_state = "podkey"
	w_class = WEIGHT_CLASS_TINY
	var/id = 0

// Key - Lock Interactions
/obj/item/device/spacepod_equipment/lock/keyed/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/device/spacepod_key))
		var/obj/item/device/spacepod_key/key = I
		if(!key.id)
			key.id = id
			to_chat(user, "<span class='notice'>You grind the blank key to fit the lock.</span>")
		else
			to_chat(user, "<span class='warning'>This key is already ground!</span>")
	else
		..()