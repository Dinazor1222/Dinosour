/datum/map_template/shuttle/voidcrew/honk
	name = "Honk-class Boe Nah Nah"
	suffix = "honk"
	short_name = "Honk-Class"
	part_cost = 1

	job_slots = list(
		list(
			name = "Mime",
			officer = TRUE,
			outfit = /datum/outfit/job/mime,
			slots = 1,
		),
		list(
			name = "Clown",
			outfit = /datum/outfit/job/clown,
			slots = 7,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/honk
	name = "Honk-class Boe Nah Nah"
	area_type = /area/shuttle/voidcrew/honk


/// AREAS ///

// this one isn't even worth organizing

/area/shuttle/voidcrew/honk
	name = "POTASSIUM"
	icon_state = "station"

/area/shuttle/voidcrew/honk/bridge
	name = "HONKER CONTROL!!!!"
	icon_state = "bridge"

/area/shuttle/voidcrew/honk/supermatter
	name = "FUNNY ZONE PRIME"
	icon_state = "engine_sm"
