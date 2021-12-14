/**
 * Creates a TGUI window with a number input. Returns the user's response as num | null.
 *
 * This proc should be used to create windows for number entry that the caller will wait for a response from.
 * If tgui fancy chat is turned off: Will return a normal input. If a max or min value is specified, will
 * validate the input inside the UI and ui_act.
 *
 * Arguments:
 * * user - The user to show the number input to.
 * * message - The content of the number input, shown in the body of the TGUI window.
 * * title - The title of the number input modal, shown on the top of the TGUI window.
 * * default - The default (or current) value, shown as a placeholder. Users can press refresh with this.
 * * max_value - Specifies a maximum value. If none is set, any number can be entered. Pressing "max" defaults to 1000.
 * * min_value - Specifies a minimum value. Often 0.
 */
/proc/tgui_input_number(mob/user, message = null, title = "Number Input", default = null, max_value = null, min_value = 0)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	/// Client does NOT have tgui_input on: Returns regular input
	if(!user.client.prefs.read_preference(/datum/preference/toggle/tgui_input))
		return input(user, message, title, default) as null|num
	var/datum/tgui_input_number/number_input = new(user, message, title, default, max_value, min_value)
	number_input.ui_interact(user)
	number_input.wait()
	if (number_input)
		. = number_input.entry
		qdel(number_input)

/**
 * Creates an asynchronous TGUI number input window with an associated callback.
 *
 * This proc should be used to create number inputes that invoke a callback with the user's entry.
 *
 * Arguments:
 * * user - The user to show the number input to.
 * * message - The content of the number input, shown in the body of the TGUI window.
 * * title - The title of the number input modal, shown on the top of the TGUI window.
 * * default - The default (or current) value, shown as a placeholder. Users can press refresh with this.
 * * max_value - Specifies a maximum value. If none is set, any number can be entered. Pressing "max" defaults to 1000.
 * * min_value - Specifies a minimum value. Often 0.
 * * callback - The callback to be invoked when a choice is made.
 */
/proc/tgui_input_number_async(mob/user, message = null, title = "Number Input", default = null, max_value = null, min_value = 0, datum/callback/callback)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	var/datum/tgui_input_number/async/number_input = new(user, message, title, default, max_value, min_value, callback)
	number_input.ui_interact(user)

/**
 * # tgui_input_number
 *
 * Datum used for instantiating and using a TGUI-controlled number input that prompts the user with
 * a message and has an input for text entry.
 */
/datum/tgui_input_number
	/// Boolean field describing if the tgui_input_number was closed by the user.
	var/closed
	/// The default (or current) value, shown as a default. Users can press reset with this.
	var/default
	/// The entry that the user has return_typed in.
	var/entry
	/// The maximum value that can be entered.
	var/max_value
	/// The prompt's body, if any, of the TGUI window.
	var/message
	/// The minimum value that can be entered.
	var/min_value
	/// The title of the TGUI window
	var/title


/datum/tgui_input_number/New(mob/user, message, title, default, max_value, min_value)
	src.default = default
	src.max_value = max_value
	src.message = message
	src.min_value = min_value
	src.title = title

/datum/tgui_input_number/Destroy(force, ...)
	SStgui.close_uis(src)
	. = ..()

/**
 * Waits for a user's response to the tgui_input_number's prompt before returning. Returns early if
 * the window was closed by the user.
 */
/datum/tgui_input_number/proc/wait()
	while (!entry && !closed && !QDELETED(src))
		stoplag(1)

/datum/tgui_input_number/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NumberInputModal")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/tgui_input_number/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_input_number/ui_state(mob/user)
	return GLOB.always_state

/datum/tgui_input_number/ui_static_data(mob/user)
	. = list(
		"max_value" = max_value,
		"message" = message,
		"min_value"	= min_value,
		"placeholder" = default, /// You cannot use default as a const
		"preferences" = list(),
		"title" = title
	)
	.["preferences"]["large_buttons"] = user.client.prefs.read_preference(/datum/preference/toggle/tgui_input_large)
	.["preferences"]["swapped_buttons"] = user.client.prefs.read_preference(/datum/preference/toggle/tgui_input_swapped)

/datum/tgui_input_number/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("submit")
			if(max_value && (params["entry"] > max_value))
				return FALSE
			if(min_value && (params["entry"] < min_value))
				return FALSE
			set_entry(params["entry"])
			SStgui.close_uis(src)
			return TRUE
		if("cancel")
			set_entry(null)
			SStgui.close_uis(src)
			return TRUE

/datum/tgui_input_number/proc/set_entry(entry)
		src.entry = entry

/**
 * # async tgui_input_number
 *
 * An asynchronous version of tgui_input_number to be used with callbacks instead of waiting on user responses.
 */
/datum/tgui_input_number/async
	/// The callback to be invoked by the tgui_input_number upon having a choice made.
	var/datum/callback/callback

/datum/tgui_input_number/async/New(mob/user, message, title, default, max_value, min_value, callback)
	..(user, message, title, default, max_value, min_value)
	src.callback = callback

/datum/tgui_input_number/async/Destroy(force, ...)
	QDEL_NULL(callback)
	. = ..()

/datum/tgui_input_number/async/set_entry(entry)
	. = ..()
	if(!isnull(src.entry))
		callback?.InvokeAsync(src.entry)

/datum/tgui_input_number/async/wait()
	return
