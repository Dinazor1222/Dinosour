/obj/item/raptor_dex
	name = "raptor Dex"
	desc = "A device used to analyze lavaland raptors!"
	icon = 'icons/obj/devices/scanner.dmi'
	icon_state = "raptor_dex"
	item_flags = NOBLUDGEON
	///current raptor we are analyzing
	var/datum/weakref/raptor

/obj/item/raptor_dex/ui_interact(mob/user, datum/tgui/ui)
	if(isnull(raptor?.resolve()))
		balloon_alert(user, "no specimen data!")
		return TRUE

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RaptorDex")
		ui.open()

/obj/item/raptor_dex/ui_static_data(mob/user)
	var/list/data = list()
	var/mob/living/basic/mining/raptor/my_raptor = raptor.resolve()
	data["raptor_image"] = icon2base64(getFlatIcon(image(icon = my_raptor.icon, icon_state = my_raptor.icon_state)))
	data["raptor_attack"] = my_raptor.melee_damage_lower
	data["raptor_health"] = my_raptor.maxHealth
	data["raptor_speed"] = my_raptor.speed
	data["raptor_color"] = my_raptor.name
	var/datum/raptor_inheritance/inherit = my_raptor.inherited_stats
	if(isnull(inherit))
		return data
	data["inherited_attack"] = inherit.attack_modifier
	data["inherited_attack_max"] = RAPTOR_INHERIT_MAX_ATTACK
	data["inherited_health"] = inherit.health_modifier
	data["inherited_health_max"] = RAPTOR_INHERIT_MAX_HEALTH
	data["inherited_traits"] = inherit.inherit_traits
	return data


/obj/item/raptor_dex/afterattack(atom/attacked_atom, mob/living/user, proximity)
	. = ..()

	if(!proximity)
		return

	. |= AFTERATTACK_PROCESSED_ITEM

	if(!istype(attacked_atom, /mob/living/basic/mining/raptor))
		balloon_alert(user, "cant be analyzed!")
		return

	raptor = WEAKREF(attacked_atom)
	playsound(src, 'sound/items/orbie_send_out.ogg', 20)
	balloon_alert(user, "scanned")
