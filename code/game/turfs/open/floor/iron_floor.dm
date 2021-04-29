/turf/open/floor/iron
	icon_state = "floor"
	floor_tile = /obj/item/stack/tile/iron

/turf/open/floor/iron/setup_broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/iron/setup_burnt_states()
	return list("floorscorched1", "floorscorched2")


/turf/open/floor/iron/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There's a <b>small crack</b> on the edge of it.</span>"


/turf/open/floor/iron/rust_heretic_act()
	if(prob(70))
		new /obj/effect/temp_visual/glowing_rune(src)
	ChangeTurf(/turf/open/floor/plating/rust)


/turf/open/floor/iron/update_icon_state()
	if(broken || burnt)
		return ..()
	icon_state = base_icon_state
	return ..()


/turf/open/floor/iron/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/iron/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/floor/iron/dark
	icon_state = "darkfull"
	base_icon_state = "darkfull"
	floor_tile = /obj/item/stack/tile/iron/dark

/turf/open/floor/iron/dark/side
	icon_state = "dark"
	base_icon_state = "dark"
	floor_tile = /obj/item/stack/tile/iron/dark_side

/turf/open/floor/iron/dark/corner
	icon_state = "darkcorner"
	base_icon_state = "darkcorner"
	floor_tile = /obj/item/stack/tile/iron/dark_corner

/turf/open/floor/iron/checker
	icon_state = "checker"
	base_icon_state = "checker"
	floor_tile = /obj/item/stack/tile/iron/checker

/turf/open/floor/iron/dark/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/dark/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/iron/dark/side/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/dark/corner/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/checker/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/white
	icon_state = "white"
	base_icon_state = "white"
	floor_tile = /obj/item/stack/tile/iron/white

/turf/open/floor/iron/white/side
	icon_state = "whitehall"
	base_icon_state = "whitehall"
	floor_tile = /obj/item/stack/tile/iron/white_side

/turf/open/floor/iron/white/corner
	icon_state = "whitecorner"
	base_icon_state = "whitecorner"
	floor_tile = /obj/item/stack/tile/iron/white_corner

/turf/open/floor/iron/cafeteria
	icon_state = "cafeteria"
	base_icon_state = "cafeteria"
	floor_tile = /obj/item/stack/tile/iron/cafeteria

/turf/open/floor/iron/white/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/white/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/iron/white/side/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/white/corner/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/cafeteria/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/recharge_floor
	icon_state = "recharge_floor"
	base_icon_state = "recharge_floor"
	floor_tile = /obj/item/stack/tile/iron/recharge_floor

/turf/open/floor/iron/recharge_floor/asteroid
	icon_state = "recharge_floor_asteroid"
	base_icon_state = "recharge_floor_asteroid"


/turf/open/floor/iron/chapel
	icon_state = "chapel"
	base_icon_state = "chapel"
	floor_tile = /obj/item/stack/tile/iron/chapel

/turf/open/floor/iron/showroomfloor
	icon_state = "showroomfloor"
	base_icon_state = "showroomfloor"
	floor_tile = /obj/item/stack/tile/iron/showroomfloor

/turf/open/floor/iron/showroomfloor/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/solarpanel
	icon_state = "solarpanel"
	base_icon_state = "solarpanel"
	floor_tile = /obj/item/stack/tile/iron/solarpanel

/turf/open/floor/iron/solarpanel/airless
	initial_gas_mix = AIRLESS_ATMOS


/turf/open/floor/iron/freezer
	icon_state = "freezerfloor"
	base_icon_state = "freezerfloor"
	floor_tile = /obj/item/stack/tile/iron/freezer

/turf/open/floor/iron/freezer/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/kitchen_coldroom
	name = "cold room floor"

/turf/open/floor/iron/kitchen_coldroom/Initialize(mapload)
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS
	return ..()

/turf/open/floor/iron/kitchen_coldroom/freezerfloor
	icon_state = "freezerfloor"
	base_icon_state = "freezerfloor"
	floor_tile = /obj/item/stack/tile/iron/freezer

/turf/open/floor/iron/grimy
	icon_state = "grimy"
	base_icon_state = "grimy"
	tiled_dirt = FALSE
	floor_tile = /obj/item/stack/tile/iron/grimy

/turf/open/floor/iron/vaporwave
	icon_state = "pinkblack"
	base_icon_state = "pinkblack"
	floor_tile = /obj/item/stack/tile/iron/vaporwave

/turf/open/floor/iron/goonplaque
	name = "commemorative plaque"
	desc = "\"This is a plaque in honour of our comrades on the G4407 Stations. Hopefully TG4407 model can live up to your fame and fortune.\" Scratched in beneath that is a crude image of a meteor and a spaceman. The spaceman is laughing. The meteor is exploding."
	icon_state = "plaque"
	base_icon_state = "plaque"
	tiled_dirt = FALSE
	floor_tile = /obj/item/stack/tile/iron/goonplaque

/turf/open/floor/iron/stairs
	icon_state = "stairs"
	base_icon_state = "stairs"
	tiled_dirt = FALSE

/turf/open/floor/iron/stairs/left
	icon_state = "stairs-l"
	base_icon_state = "stairs-l"

/turf/open/floor/iron/stairs/medium
	icon_state = "stairs-m"
	base_icon_state = "stairs-m"

/turf/open/floor/iron/stairs/right
	icon_state = "stairs-r"
	base_icon_state = "stairs-r"

/turf/open/floor/iron/stairs/old
	icon_state = "stairs-old"
	base_icon_state = "stairs-old"

/turf/open/floor/iron/bluespace
	icon_state = "bluespace"
	base_icon_state = "bluespace"
	desc = "Sadly, these don't seem to make you faster..."
	floor_tile = /obj/item/stack/tile/iron/bluespace

/turf/open/floor/iron/monotile
	icon_state = "monotile"
	base_icon_state = "monotile"
	floor_tile = /obj/item/stack/tile/iron/monotile

/turf/open/floor/iron/sepia
	icon_state = "sepia"
	base_icon_state = "sepia"
	desc = "Well, the flow of time is normal on these tiles, weird."
	floor_tile = /obj/item/stack/tile/iron/sepia

/turf/open/floor/iron/yellowsiding
	icon_state = "yellowsiding"
	base_icon_state = "yellowsiding"

/turf/open/floor/iron/yellowsiding/corner
	icon_state = "yellowcornersiding"
	base_icon_state = "yellowcornersiding"
