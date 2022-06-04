/**
 * The tgui speech modal. This initializes an input window which hides until
 * the user presses one of the speech hotkeys. Once an entry is set, it will
 * delegate the speech to the proper channel.
 */
/datum/tgui_modal
	/// The user who opened the window
	var/client/client
	/// Boolean for whether the tgui_modal was closed by the user.
	var/closed
	/// Max message length
	var/max_length = MAX_MESSAGE_LEN
	/// The modal window
	var/datum/tgui_window/window
	/// Injury phrases to blurt out
	var/list/hurt_phrases = list("GACK!", "GLORF!", "OOF!", "AUGH!", "OW!", "URGH!", "HRNK!")

/** Creates the new input window to exist in the background. */
/datum/tgui_modal/New(client/client, id)
	src.client = client
	window = new(client, id)
	window.subscribe(src, .proc/on_message)
	window.is_browser = TRUE

/**
 * Injects the scripts and styling into the window,
 * then feeds it props for the chat channel and max message length.
 */
/datum/tgui_modal/proc/initialize()
	set waitfor = FALSE
	// Sleep to defer initialization to after client constructor
	sleep(5 SECONDS)
	window.initialize(
			strict_mode = TRUE,
			fancy = TRUE,
			inline_css = file("tgui/public/tgui-modal.bundle.css"),
			inline_js = file("tgui/public/tgui-modal.bundle.js"),
	);
	close()

/**
 * Sets the window as "opened" server side, though it is already
 * visible to the user. We do this to set local vars.
 */
/datum/tgui_modal/proc/open(channel = SAY_CHAN)
	closed = FALSE
	if(!client.mob)
		return
	if(client?.mob.typing_thinking_indicator)
		if(client?.typing_indicators)
			log_speech_indicators("[key_name(client)] started typing at [loc_name(client?.mob)], indicators enabled.")
		else
			log_speech_indicators("[key_name(client)] started typing at [loc_name(client?.mob)], indicators DISABLED.")
		client?.mob.typing_thinking_indicator = FALSE


/**
 * Closes the window and hides it from view.
 */
/datum/tgui_modal/proc/close()
	closed = TRUE
	if(!client.mob)
		return
	if(client?.mob.typing_thinking_indicator)
		if(client?.typing_indicators)
			log_speech_indicators("[key_name(client)] stopped typing at [loc_name(client?.mob)], indicators enabled.")
		else
			log_speech_indicators("[key_name(client)] stopped typing at [loc_name(client?.mob)], indicators DISABLED.")
		client?.mob.typing_thinking_indicator = FALSE
	client.mob.cancel_thinking()

/**
 * Force say handler.
 * Sends a message to the modal window to send its current value.
 */
/datum/tgui_modal/proc/force_say()
	window.send_message("force")

/**
 * The equivalent of ui_act, this waits on messages from the window
 * and delegates actions.
 */
/datum/tgui_modal/proc/on_message(type, payload)
	if(type == "ready")
		/// Sanity check in case the server ever changes MAX_LEN_MESSAGE
		window.send_message("maxLength", list(
			maxLength = max_length,
		))
		return TRUE
	if (type == "close")
		close()
		return TRUE
	if (type == "entry" || type == "force")
		if(!payload || !payload["channel"] || !payload["entry"])
			return FALSE
		if(length(payload["entry"]) > max_length)
			CRASH("[usr] has entered more characters than allowed")
		if(type == "force")
			delegate_speech(alter_entry(payload), SAY_CHAN)
		if(type == "entry")
			delegate_speech(payload["entry"], payload["channel"])
			close()
		return TRUE
	if (type == "typing")
		init_typing()
	return TRUE

/**
 * Handles the user typing. After a brief period of inactivity,
 * signals the client mob to revert to the "thinking" icon.
 */
/datum/tgui_modal/proc/init_typing()
	addtimer(CALLBACK(src, .proc/stop_typing), 3 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)
	if(client.mob)
		client.mob.start_typing()

/** Signals the parent to return to "thinking" state */
/datum/tgui_modal/proc/stop_typing()
	if(client.mob)
		client.mob.cancel_typing()

/**
 * Alters text when players are injured.
 * Adds text, trims left and right side
 *
 * Arguments:
 *  payload - a string list containing entry & channel
 * Returns:
 *  string - the altered entry
 */
/datum/tgui_modal/proc/alter_entry(payload)
	var/entry = payload["entry"]
	/// No OOC leaks
	if(payload["channel"] == OOC_CHAN || payload["channel"] == ME_CHAN)
		return pick(hurt_phrases)
	/// Sanitizes radio prefixes so users can't game the system (mostly)
	entry = remove_prefixes(entry)
	if(!entry)
		return pick(hurt_phrases)
	/// Random trimming for larger sentences
	if(length(entry) > 50)
		entry = trim(entry, rand(40, 50))
	else
		/// Otherwise limit trim to just last letter
		if(length(entry) > 1)
			entry = trim(entry, length(entry))
	return entry + "-" + pick(hurt_phrases)

/**
 * Sanitizes text from radio and emote prefixes
 *
 * Arguments:
 * 	entry - the text to sanitize
 * Returns:
 * 	string || boolean FALSE if the entry is empty
 */
/datum/tgui_modal/proc/remove_prefixes(entry)
	if(length(entry) < 2)
		return FALSE
	/// Start removing any type of radio prefix
	while(copytext_char(entry, 1, 2) == ";" \
		|| copytext_char(entry, 1, 2) == ":" \
		|| copytext_char(entry, 1, 2) == "*")
		/// Ensure we're not clipping the only letter
		if(length(entry) < 2)
			return FALSE
		/// Sanitize standard departmental chat
		if(copytext_char(entry, 1, 2) == ":" \
			&& length(entry) > 3 \
			&& copytext_char(entry, 3, 4) == " ")
			entry = copytext(entry, 4)
		else
			entry = copytext(entry, 2)
	return entry

/**
 * Delegates the speech to the proper channel.
 *
 * Arguments:
 * 	entry - the text to broadcast
 * 	channel - the channel to broadcast in
 * Returns:
 *  boolean - on success or failure
 */
/datum/tgui_modal/proc/delegate_speech(entry, channel)
	if(!client)
		return FALSE
	if(channel == OOC_CHAN)
		client.ooc(entry)
		return TRUE
	if(!client.mob)
		return FALSE
	switch(channel)
		if(RADIO_CHAN)
			entry = remove_prefixes(entry)
			if(entry)
				entry = ";" + entry
				client.mob.say_verb(entry)
			return TRUE
		if(ME_CHAN)
			client.mob.me_verb(entry)
			return TRUE
		if(SAY_CHAN)
			client.mob.say_verb(entry)
			return TRUE
	return FALSE


