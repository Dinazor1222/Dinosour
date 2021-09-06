/**
 * # Compact Remote
 *
 * A handheld device with one big button.
 */
/obj/item/compact_remote
	name = "compact remote"
	icon = 'icons/obj/wiremod.dmi'
	icon_state = "setup_small_simple"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_on = FALSE

/obj/item/compact_remote/Initialize()
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/compact_remote()
	), SHELL_CAPACITY_SMALL)

/obj/item/circuit_component/compact_remote
	display_name = "Compact Remote"
	desc = "Used to receive inputs from the compact remote shell. Use the shell in hand to trigger the output signal."

	/// Called when attack_self is called on the shell.
	var/datum/port/output/signal
	/// The user who used the bot
	var/datum/port/output/entity

/obj/item/circuit_component/compact_remote/Initialize()
	. = ..()
	entity = add_output_port("User", PORT_TYPE_ATOM)
	signal = add_output_port("Signal", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/compact_remote/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_ITEM_ATTACK_SELF, .proc/send_trigger)

/obj/item/circuit_component/compact_remote/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_ITEM_ATTACK_SELF)

/**
 * Called when the shell item is used in hand.
 */
/obj/item/circuit_component/compact_remote/proc/send_trigger(atom/source, mob/user)
	SIGNAL_HANDLER
	source.balloon_alert(user, "clicked primary button")
	playsound(source, get_sfx("terminal_type"), 25, FALSE)
	entity.set_output(user)
	signal.set_output(COMPONENT_SIGNAL)
