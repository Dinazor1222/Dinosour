/datum/lazy_template/virtual_domain/beach_bar
	name = "Beach Bar"
	desc = "A cheerful seaside haven where friendly skeletons serve up drinks. Say, how'd you guys get so dead?"
	extra_loot = list(/obj/item/toy/beach_ball = 1)
	map_name = "beach_bar"
	help_text = "This place is running on a skeleton crew, and they don't seem to be too keen to share details.\
	Maybe a few drinks of liquid charm will get the spirits up. As the saying goes, if you can't beat 'em, join 'em."
	id = "beach_bar"
	safehouse_path = /datum/map_template/safehouse/mine

/obj/item/reagent_containers/cup/glass/drinkingglass/virtual_domain
	name = "pina colada"
	desc = "Whose drink is this? Not yours, that's for sure. Well, it's not like they're going to miss it."
	list_reagents = list(/datum/reagent/consumable/ethanol/pina_colada = 30)
	/// The crate to add points to when drank.
	var/datum/weakref/our_signaler

/obj/item/reagent_containers/cup/glass/drinkingglass/virtual_domain/Initialize(mapload, vol)
	. = ..()
	RegisterSignal(src, COMSIG_GLASS_DRANK, PROC_REF(on_drank))

	var/obj/effect/bitrunning/loot_signal/signaler = locate() in orange(4, src)
	if(signaler)
		our_signaler = WEAKREF(signaler)

/obj/item/reagent_containers/cup/glass/drinkingglass/virtual_domain/proc/on_drank(datum/source, mob/target, mob/user)
	SIGNAL_HANDLER

	if(target != user) // Hey now!
		return

	var/obj/effect/bitrunning/loot_signal/signaler = our_signaler?.resolve()
	if(isnull(signaler))
		return

	SEND_SIGNAL(signaler, COMSIG_BITRUNNER_GOAL_POINT, 0.5)
