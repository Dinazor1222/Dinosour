/**
 * # Hello World preset
 *
 * Says "Hello World" when triggered. Needs to be wired up and connected first.
 */
/obj/item/integrated_circuit/loaded/hello_world

/obj/item/integrated_circuit/loaded/hello_world/Initialize()
	. = ..()
	var/obj/item/circuit_component/speech/speech = new()
	add_component(speech)

	speech.message.put("Hello World")

