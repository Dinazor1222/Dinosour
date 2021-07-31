/**
 * # Setter Component
 *
 * Stores the current input when triggered into a variable.
 */
/obj/item/circuit_component/setter
	display_name = "Variable Setter"
	display_desc = "A component that sets a variable globally on the circuit."

	circuit_flags = CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// Variable name
	var/datum/port/input/option/variable_name

	/// The input to store
	var/datum/port/input/input_port
	/// The trigger to store the current value of the input
	var/datum/port/input/trigger

	var/current_type

/obj/item/circuit_component/setter/populate_options()
	variable_name = add_input_port("Variable", PORT_TYPE_OPTION, SET_OPTION_LIST(null))

/obj/item/circuit_component/setter/add_to(obj/item/integrated_circuit/added_to)
	. = ..()
	variable_name.possible_options = added_to.circuit_variables

/obj/item/circuit_component/setter/removed_from(obj/item/integrated_circuit/removed_from)
	variable_name.possible_options = null
	return ..()

/obj/item/circuit_component/setter/Initialize()
	. = ..()
	input_port = add_input_port("Input", PORT_TYPE_ANY)
	trigger = add_input_port("Store", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/setter/input_received(datum/port/input/port)
	. = ..()
	var/variable_string = variable_name.input_value
	if(!variable_string)
		return

	var/datum/circuit_variable/variable = parent.circuit_variables[variable_string]
	if(!variable)
		return

	if(variable.datatype != current_type)
		current_type = variable.datatype
		input_port.set_datatype(current_type)

	if(.)
		return

	if(!COMPONENT_TRIGGERED_BY(trigger, port))
		return TRUE

	var/input_val = input_port.input_value
	variable.value = input_val
