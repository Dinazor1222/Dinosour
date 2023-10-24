#define STATUE_FILTER "statue_filter"
#define FILTER_COLOR "#34b347"
#define RECALL_DURATION 3 SECONDS

/obj/item/frog_statue
	name = "frog statue"
	icon = 'icons/obj/weapons/guns/magic.dmi'
	icon_state = "frog_statue"
	item_flags = NOBLUDGEON
	///our pet frog
	var/mob/living/contained_frog
	///the summon cooldown
	COOLDOWN_DECLARE(summon_cooldown)

/obj/item/frog_statue/attack_self(mob/user)
	. = ..()

	if(.)
		return TRUE

	if(!COOLDOWN_FINISHED(src, summon_cooldown))
		user.balloon_alert(user, "recharging!")
		return TRUE

	COOLDOWN_START(src, summon_cooldown, 30 SECONDS)
	if(isnull(contained_frog))
		user.balloon_alert(user, "no frog linked!")
		return TRUE
	if(contained_frog.loc == src)
		release_frog(user)
		return TRUE
	recall_frog(user)
	return TRUE

/obj/item/frog_statue/proc/recall_frog(mob/user)
	user.Beam(contained_frog, icon_state = "lichbeam", time = RECALL_DURATION)
	animate(contained_frog, transform = matrix().Scale(0.3, 0.3), time = RECALL_DURATION)
	addtimer(CALLBACK(contained_frog, TYPE_PROC_REF(/atom/movable, forceMove), src), RECALL_DURATION)

/obj/item/frog_statue/proc/release_frog(mob/user)
	var/list/possible_turfs = list()
	for(var/turf/possible_turf in oview(2, user))
		if(possible_turf.is_blocked_turf())
			continue
		possible_turfs += possible_turf
	playsound(src, 'sound/items/frog_statue_release.ogg', 50, TRUE)
	var/turf/final_turf = length(possible_turfs) ? pick(possible_turfs) : get_turf(src)
	user.Beam(final_turf, icon_state = "lichbeam", time = RECALL_DURATION)
	contained_frog.forceMove(final_turf)
	animate(contained_frog, transform = matrix(), time = RECALL_DURATION)


/obj/item/frog_statue/proc/set_new_frog(mob/living/frog)
	frog.transform = frog.transform.Scale(0.3, 0.3)
	contained_frog = frog
	animate_filter()
	RegisterSignals(frog, COMSIG_QDELETING, PROC_REF(render_obsolete))

/obj/item/frog_statue/proc/render_obsolete(datum/source)
	contained_frog = null
	playsound(src, 'sound/magic/demon_dies.ogg', 50, TRUE)

/obj/item/frog_statue/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(arrived != contained_frog)
		return
	animate_filter()
	if(contained_frog.health < contained_frog.maxHealth)
		START_PROCESSING(SSobj, src)

/obj/item/frog_statue/process(seconds_per_tick)
	if(isnull(contained_frog))
		return
	if(contained_frog.health == contained_frog.maxHealth)
		STOP_PROCESSING(SSobj, src)
		return
	if(contained_frog.stat == DEAD)
		contained_frog.revive()
	contained_frog.adjustBruteLoss(-5)

/obj/item/frog_statue/proc/animate_filter(mob/living/frog)
	add_filter(STATUE_FILTER, 2, list("type" = "outline", "color" = FILTER_COLOR, "size" = 1))
	var/filter = get_filter(STATUE_FILTER)
	animate(filter, alpha = 230, time = 2 SECONDS, loop = -1)
	animate(alpha = 30, time = 0.5 SECONDS)

/obj/item/frog_statue/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone != contained_frog)
		return
	clear_filters()

/obj/item/frog_contract
	name = "Frog Contract"
	icon = 'icons/obj/scrolls.dmi'
	icon_state = "scroll"

/obj/item/frog_contract/attack_self(mob/user)
	. = ..()
	if(.)
		return TRUE
	create_frog(user)
	return TRUE

/obj/item/frog_contract/proc/create_frog(mob/user)
	var/selected_name =  sanitize_name(tgui_input_text(user, "Choose your frog's name!", "Name pet toad", "leaper", MAX_NAME_LEN), allow_numbers = TRUE)
	var/toad_color  = input(user, "Select your frog's color!" , "Pet toad color") as color|null
	var/obj/item/frog_statue/statue = new(get_turf(user))
	var/mob/living/basic/leaper/new_frog = new(statue)
	statue.set_new_frog(new_frog)
	new_frog.befriend(user)
	if(toad_color)
		new_frog.set_color_overlay(toad_color)
	if(selected_name)
		new_frog.name = selected_name
	qdel(src)
