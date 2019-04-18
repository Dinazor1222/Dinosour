//This is supposed to help make miasma at certain turfs by reducing the number of atmos changes to do
var/datum/controller/miasma_processor/miasma_manager

/datum/controller/miasma_processor
	var/list/tilestodiffuse = list()

/datum/controller/miasma_processor/Initialize()
	START_PROCESSING(SSprocessing, src)

/datum/controller/miasma_processor/process()
	for(var/turf/T in tilestodiffuse)
		if(!istype(T))
			continue
	
		var/datum/gas_mixture/stank = new
		ADD_GAS(/datum/gas/miasma, stank.gases)
		stank.gases[/datum/gas/miasma][MOLES] = tilestodiffuse[T]
		T.assume_air(stank)
		T.air_update_turf()
	
	tilestodiffuse.Cut()	


/datum/component/rot
	var/amount = 1

/datum/component/rot/Initialize(new_amount)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	if(new_amount)
		amount = new_amount

	START_PROCESSING(SSprocessing, src)

/datum/component/rot/process()
	var/atom/A = parent

	var/turf/open/T = get_turf(A)

	if(istype(T) && !istype(T,/turf/open/space))
		miasma_manager.tilestodiffuse[T] += amount

/datum/component/rot/corpse
	amount = MIASMA_CORPSE_MOLES

/datum/component/rot/corpse/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()

/datum/component/rot/corpse/process()
	var/mob/living/carbon/C = parent
	//There is no way to de-husk and inorganic mobs/ skeletons don't rot: remove the component
	if(C.stat != DEAD || C.has_trait(TRAIT_HUSK) || (!(MOB_ORGANIC in C.mob_biotypes) && !(MOB_UNDEAD in C.mob_biotypes)))
		qdel(src)
		return

	// Wait a bit before decaying
	if(world.time - C.timeofdeath < 2 MINUTES)
		return

	// Properly stored corpses shouldn't create miasma
	if(istype(C.loc, /obj/structure/closet/crate/coffin)|| istype(C.loc, /obj/structure/closet/body_bag) || istype(C.loc, /obj/structure/bodycontainer))
		return

	// No decay if formaldehyde in corpse or when the corpse is charred
	if(C.reagents.has_reagent("formaldehyde", 15))
		return

	// Also no decay if corpse chilled or not organic/undead
	if(C.bodytemperature <= T0C-10)
		return

	..()

/datum/component/rot/gibs
	amount = MIASMA_GIBS_MOLES

/datum/component/rot/bodypart
	amount = MIASMA_GIBS_MOLES

/datum/component/rot/bodypart/process()
	var/obj/item/bodypart/BP = parent
	if(BP.owner || BP.burn_dam > 100)
		qdel(src)
		return
	..()

/datum/component/rot/organ
	amount = MIASMA_GIBS_MOLES

/datum/component/rot/organ/process()
	var/obj/item/organ/O = parent
	if(O.owner)
		qdel(src)
		return
	..()
