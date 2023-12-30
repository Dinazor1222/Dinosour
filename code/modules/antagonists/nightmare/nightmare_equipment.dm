/**
 * An armblade that instantly snuffs out lights
 */
/obj/item/light_eater
	name = "light eater" //as opposed to heavy eater
	icon = 'icons/obj/weapons/changeling_items.dmi'
	icon_state = "arm_blade"
	inhand_icon_state = "arm_blade"
	force = 25
	armour_penetration = 35
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = INDESTRUCTIBLE | ACID_PROOF | FIRE_PROOF | LAVA_PROOF | UNACIDABLE
	w_class = WEIGHT_CLASS_HUGE
	sharpness = SHARP_EDGED
	tool_behaviour = TOOL_MINING
	hitsound = 'sound/weapons/bladeslice.ogg'
	wound_bonus = -30
	bare_wound_bonus = 20
	///If this is true, our next hit will be critcal, temporarily stunning our target
	var/has_crit = FALSE
	///The timer which controls our next crit
	var/crit_timer

/obj/item/light_eater/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/butchering, \
	speed = 8 SECONDS, \
	effectiveness = 70, \
	)
	AddComponent(/datum/component/light_eater)

obj/item/light_eater/on_equipped(mob/user, slot, initial = FALSE)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_ENTER_JAUNT, PROC_REF(remove_crit))
	RegisterSignal(user, COMSIG_MOB_AFTER_EXIT_JAUNT, PROC_REF(prepare_crit_timer))
	prepare_crit_timer()

obj/item/light_eater/dropped(mob/user, silent = FALSE)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_ENTER_JAUNT)
	UnregisterSignal(user, COMSIG_MOB_AFTER_EXIT_JAUNT)
	remove_crit()

/obj/item/light_eater/attack(mob/living/target, mob/living/user, params)
	. = ..()
	if(!has_crit)
		return
	playsound(target, 'sound/effects/wounds/crackandbleed.ogg', 100, TRUE)
	if(target.stat == DEAD)
		user.visible_message(span_warning("[user] gores [target] with [src]!"), span_warning("You gore [target] with [src], which doesn't accomplish much, but it does make you feel a little better."))
	else if(iscarbon(target) || issilicon(target))
		user.visible_message(span_boldwarning("[user] gores [target] with [src], bringing them to a halt!"), span_userdanger("You gore [target] with [src], bringing them to a halt!"))
		target.Paralyze(issilicon(target) ? 2 SECONDS : 1 SECONDS)
	else
		user.visible_message(span_boldwarning("[user] gores [target] with [src], ripping into them!"), span_userdanger("You gore [target] with [src], ripping into them!"))
		target.apply_damage(damage = force, forced = TRUE)
	remove_crit()
	prepare_crit_timer()

/obj/item/light_eater/proc/prepare_crit_timer()
	crit_timer = addtimer(CALLBACK(src, PROC_REF(add_crit)), 15 SECONDS, TIMER_DELETE_ME | TIMER_STOPPABLE)

/obj/item/light_eater/proc/add_crit()
	has_crit = TRUE
	add_filter("crit_glow", 3, list("type" = "outline", "color" = "#ff330030", "size" = 5))
	if(ismob(loc))
		loc.balloon_alert(loc, "critical strike ready")

/obj/item/light_eater/proc/remove_crit()
	has_crit = FALSE
	remove_filter("crit_glow")
	deltimer(crit_timer)
