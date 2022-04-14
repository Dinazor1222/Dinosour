
/**
 * # laser pointer Component
 *
 * Points a laser at a tile or mob
 */
/obj/item/circuit_component/laserpointer
	display_name = "Laser Pointer"
	desc = "A component that shines a high powered light at a target."
	category = "Action"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/// The Laser Pointer Variables
	var/turf/pointer_loc

	var/effectchance = 100 /// same as a tier 4 laser pointer (technically thats 120), which is offset by the large time investment and difficulty in using circuits.
	/// The input port
	var/datum/port/input/target_input
	var/datum/port/input/image_pixel_x = 0
	var/datum/port/input/image_pixel_y = 0

	var/max_range = 7

	var/datum/port/input/option/lasercolour_option


/obj/item/circuit_component/laserpointer/get_ui_notices()
	. = ..()
	. += create_ui_notice("Maximum Range: [max_range] tiles", "orange", "info")

/obj/item/circuit_component/laserpointer/populate_options()
	var/static/component_options = list(
		"red",
		"green",
		"blue",
		"purple",
	)
	lasercolour_option = add_option_port("Laser Colour", component_options)


/obj/item/circuit_component/laserpointer/populate_ports()
	target_input = add_input_port("Target", PORT_TYPE_ATOM)
	image_pixel_x = add_input_port("X-Axis Shift", PORT_TYPE_NUMBER)
	image_pixel_y = add_input_port("Y-Axis Shift", PORT_TYPE_NUMBER)


/obj/item/circuit_component/laserpointer/input_received(datum/port/input/port)

	var/atom/target = target_input.value
	var/atom/movable/shell = parent.shell
	var/turf/targloc = get_turf(target)


	var/pointer_icon_state = lasercolour_option.value

	var/turf/current_turf = get_location()
	if(get_dist(current_turf, target) > max_range || current_turf.z != target.z)
		return

	/// the only reason this is even still here is because you have to set the cyborg as the target first which usually requires being next to them
	if(iscyborg(target))
		var/mob/living/silicon/silicon = target
		log_combat(shell, silicon, "shone in the sensors", src)
		silicon.flash_act(affect_silicon = 1)
		silicon.Paralyze(rand(1,5))
		to_chat(silicon, span_danger("Your sensors were overloaded by a laser shone by [shell]!"))

	for(var/mob/living/carbon/human/Victim in view(1,targloc))
		if(!isfelinid(Victim) || Victim.incapacitated() || Victim.is_blind())
			continue
		else
			Victim.setDir(get_dir(Victim,targloc))
			Victim.visible_message(span_warning("[Victim] makes a grab for the light!"),span_userdanger("LIGHT!"))
			Victim.Move(targloc)
			log_combat(shell, Victim, "moved with a laser pointer",src)

	///laserpointer image
	var/image/laser_location = image('icons/obj/guns/projectiles.dmi',targloc,"[pointer_icon_state]_laser",10)

	laser_location.pixel_x = clamp(target.pixel_x + image_pixel_x.value,-15,15)
	laser_location.pixel_y = clamp(target.pixel_y + image_pixel_y.value,-15,15)

	flick_overlay_view(laser_location, targloc, 10)


