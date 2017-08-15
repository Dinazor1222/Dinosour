/obj/structure/spacepoddoor
	name = "Podlock"
	desc = "An air-tight holodoor that only lets spacepods through."
	icon = 'icons/effects/beam.dmi'
	icon_state = "n_beam"
	var/id = 1.0
	density = 0
	anchored = 1

/obj/structure/spacepoddoor/Initialize()
	. = ..()
	air_update_turf(1)

/obj/structure/spacepoddoor/CanAtmosPass(turf/T)
	return 0

/obj/structure/spacepoddoor/Destroy()
	air_update_turf(1)
	return ..()

/obj/structure/spacepoddoor/CanPass(atom/movable/A, turf/T)
	if(istype(A, /obj/spacepod))
		return ..()
	else
		return 0