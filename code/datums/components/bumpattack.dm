/**
 * Add an auto attack on bump behaviour to item
 * valid_slot: the inventory slot the item could be held in while still bumpattacking with it
 * proxy_weapon: the weapon that will gain this behaviour
 */
#define COOLDOWN_BUMP_ATTACK "bump_attack"
/datum/component/bumpattack
	dupe_mode = COMPONENT_DUPE_UNIQUE
	///inventory slot that the item could be stored while still being able to attack with it
	var/valid_slots
	var/active = FALSE
	var/mob/living/wearer
	///the item that will gain this behaviour
	var/obj/item/proxy_weapon
	///cool down between each hit
	var/attack_cooldown = CLICK_CD_MELEE

/datum/component/bumpattack/Initialize(valid_slots, obj/item/proxy_weapon)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.valid_slots = valid_slots
	src.proxy_weapon = proxy_weapon

/datum/component/bumpattack/Destroy(force, silent)
	return ..()

/datum/component/bumpattack/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/check_equip)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/check_drop)

/datum/component/bumpattack/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

/datum/component/bumpattack/proc/check_equip(obj/item/source, mob/living/user, slot)
	SIGNAL_HANDLER
	if(!user) // iunno, thoroughness
		return
	if((slot & valid_slots))
		activate(user)
	else
		deactivate()
/datum/component/bumpattack/proc/check_drop(datum/source, mob/living/dropper)
	SIGNAL_HANDLER
	deactivate()

/datum/component/bumpattack/proc/activate(mob/living/user)
	if(!istype(user))
		return
	active = TRUE
	wearer = user
	RegisterSignal(user, COMSIG_LIVING_MOB_BUMP, .proc/check_bump)

/datum/component/bumpattack/proc/deactivate()
	active = FALSE
	if(wearer)
		UnregisterSignal(wearer, COMSIG_LIVING_MOB_BUMP)
	wearer = null

/datum/component/bumpattack/proc/check_bump(mob/living/bumper, mob/living/target)
	SIGNAL_HANDLER
	var/obj/item/our_weapon = proxy_weapon || parent
	if(!istype(our_weapon))
		qdel(src)
		return
	if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_BUMP_ATTACK))
		TIMER_COOLDOWN_START(src, COOLDOWN_BUMP_ATTACK, attack_cooldown)
		INVOKE_ASYNC(target, /atom.proc/attackby , our_weapon, bumper)
		bumper.visible_message(span_danger("[bumper] charges into [target], attacking with [our_weapon]!"), span_danger("You charge into [target], attacking with [our_weapon]!"), vision_distance = COMBAT_MESSAGE_RANGE)
#undef COOLDOWN_BUMP_ATTACK
