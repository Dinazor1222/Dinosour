var/list/department_radio_keys = list(
	  ":r" = "right hand",	".r" = "right hand",
	  ":l" = "left hand",	".l" = "left hand",
	  ":i" = "intercom",	".i" = "intercom",
	  ":h" = "department",	".h" = "department",
	  ":c" = "Command",		".c" = "Command",
	  ":n" = "Science",		".n" = "Science",
	  ":m" = "Medical",		".m" = "Medical",
	  ":e" = "Engineering", ".e" = "Engineering",
	  ":s" = "Security",	".s" = "Security",
	  ":w" = "whisper",		".w" = "whisper",
	  ":b" = "binary",		".b" = "binary",
	  ":a" = "alientalk",	".a" = "alientalk",
	  ":t" = "Syndicate",	".t" = "Syndicate",
	  ":u" = "Supply",		".u" = "Supply",
	  ":v" = "Service",		".v" = "Service",
	  ":o" = "AI Private",	".o" = "AI Private",
	  ":g" = "changeling",	".g" = "changeling",
	  ":y" = "Centcom",		".y" = "Centcom",
	  ":x" = "cords",		".x" = "cords",
	  ":p" = "admin",		".p" = "admin",
	  ":d" = "deadmin",		".d" = "deadmin",

	  ":R" = "right hand",	".R" = "right hand",
	  ":L" = "left hand",	".L" = "left hand",
	  ":I" = "intercom",	".I" = "intercom",
	  ":H" = "department",	".H" = "department",
	  ":C" = "Command",		".C" = "Command",
	  ":N" = "Science",		".N" = "Science",
	  ":M" = "Medical",		".M" = "Medical",
	  ":E" = "Engineering",	".E" = "Engineering",
	  ":S" = "Security",	".S" = "Security",
	  ":W" = "whisper",		".W" = "whisper",
	  ":B" = "binary",		".B" = "binary",
	  ":A" = "alientalk",	".A" = "alientalk",
	  ":T" = "Syndicate",	".T" = "Syndicate",
	  ":U" = "Supply",		".U" = "Supply",
	  ":V" = "Service",		".V" = "Service",
	  ":O" = "AI Private",	".O" = "AI Private",
	  ":G" = "changeling",	".G" = "changeling",
	  ":Y" = "Centcom",		".Y" = "Centcom",
	  ":X" = "cords",		".X" = "cords",
	  ":P" = "admin",		".P" = "admin",
	  ":D" = "deadmin",		".D" = "deadmin",

	  //kinda localization -- rastaf0
	  //same keys as above, but on russian keyboard layout. This file uses cp1251 as encoding.
	  ":ê" = "right hand",	".ê" = "right hand",
	  ":ä" = "left hand",	".ä" = "left hand",
	  ":ø" = "intercom",	".ø" = "intercom",
	  ":ð" = "department",	".ð" = "department",
	  ":ñ" = "Command",		".ñ" = "Command",
	  ":ò" = "Science",		".ò" = "Science",
	  ":ü" = "Medical",		".ü" = "Medical",
	  ":ó" = "Engineering",	".ó" = "Engineering",
	  ":û" = "Security",	".û" = "Security",
	  ":ö" = "whisper",		".ö" = "whisper",
	  ":è" = "binary",		".è" = "binary",
	  ":ô" = "alientalk",	".ô" = "alientalk",
	  ":å" = "Syndicate",	".å" = "Syndicate",
	  ":é" = "Supply",		".é" = "Supply",
	  ":ï" = "changeling",	".ï" = "changeling"
)

var/list/crit_allowed_modes = list(MODE_WHISPER,MODE_CHANGELING,MODE_ALIEN)
var/list/unconscious_allowed_modes = list(MODE_CHANGELING,MODE_ALIEN)

var/list/one_character_prefix = list(MODE_HEADSET,MODE_ROBOT,MODE_WHISPER)

/mob/living/say(message, bubble_type,var/list/spans = list(), sanitize = TRUE)
	if(sanitize)
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message || message == "")
		return

	var/message_mode = get_message_mode(message)
	var/original_message = message
	var/in_critical = InCritical()
	var/voice_print = get_voiceprint()

	if(message_mode in one_character_prefix)
		message = copytext(message, 2)
	else if(message_mode)
		message = copytext(message, 3)
	if(findtext(message, " ", 1, 2))
		message = copytext(message, 2)

	if(message_mode == "admin")
		if(client)
			client.cmd_admin_say(message)
		return

	if(message_mode == "deadmin")
		if(client)
			client.dsay(message)
		return

	if(stat == DEAD)
		say_dead(original_message)
		return

	if(check_emote(original_message) || !can_speak_basic(original_message))
		return

	if(in_critical)
		if(!(message_mode in crit_allowed_modes))
			return
	else if(stat == UNCONSCIOUS)
		if(!(message_mode in unconscious_allowed_modes))
			return

	if(handle_inherent_channels(message, message_mode)) //Hiveminds, binary chat & holopad.
		return

	if(!can_speak_vocal(message))
		to_chat(src, "<span class='warning'>You find yourself unable to speak!</span>")
		return

	var/message_range = 6

	if(message_mode == MODE_WHISPER)
		message_range = 1
		spans |= SPAN_ITALICS
		log_whisper("[src.name]/[src.key] : [message]")
		if(in_critical)
			var/health_diff = round(-HEALTH_THRESHOLD_DEAD + health)
			// If we cut our message short, abruptly end it with a-..
			var/message_len = length(message)
			message = copytext(message, 1, health_diff) + "[message_len > health_diff ? "-.." : "..."]"
			message = Ellipsis(message, 10, 1)
			message_mode = MODE_WHISPER_CRIT
			succumb(1)
	else
		log_say("[name]/[key] : [message]")

	message = treat_message(message)
	if(!message)
		return

	spans += get_spans()

	//Log what we've said with an associated timestamp, using the list's len for safety/to prevent overwriting messages
	log_message(message, INDIVIDUAL_SAY_LOG)

	var/radio_return = radio(message, message_mode, spans)
	if(radio_return & ITALICS)
		spans |= SPAN_ITALICS
	if(radio_return & REDUCE_RANGE)
		message_range = 1

	//No screams in space, unless you're next to someone.
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/environment = T.return_air()
	var/pressure = (environment)? environment.return_pressure() : 0
	if(pressure < SOUND_MINIMUM_PRESSURE)
		message_range = 1

	if(pressure < ONE_ATMOSPHERE*0.4) //Thin air, let's italicise the message
		spans |= SPAN_ITALICS

	send_speech(message, message_range, src, bubble_type, spans, voice_print, message_mode)

	return 1

/mob/living/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans, voice_print, accent, message_mode)
	if(!client)
		return
	var/deaf_message
	var/deaf_type
	var/voice
	var/edit_print_ref
	if(voice_print)
		voice = get_voiceprint_name(speaker, voice_print)
		if(mind && voice_print != voiceprint)
			edit_print_ref = mind.voiceprint_edit_tag(voice_print)
	if(speaker != src)
		if(!radio_freq) //These checks have to be seperate, else people talking on the radio will make "You can't hear yourself!" appear when hearing people over the radio while deaf.
			deaf_message = "<span class='name'>[voice ? voice : speaker]</span> [speaker.verb_say] something but you cannot hear them."
			deaf_type = 1
	else
		deaf_message = "<span class='notice'>You can't hear yourself!</span>"
		deaf_type = 2 // Since you should be able to hear yourself without looking
	if(voice || !(message_langs & languages_understood) || force_compose) //force_compose is so AIs don't end up without their hrefs.
		message = compose_message(speaker, message_langs, raw_message, radio_freq, spans, voice, accent, message_mode, edit_print_ref)
		last_voiceprint_message(voice_print, remove_html_tags(message))
	show_message(message, 2, deaf_message, deaf_type)
	return message

/mob/living/send_speech(message, message_range = 6, obj/source = src, bubble_type = bubble_icon, list/spans, voice_print, message_mode)
	var/list/listening = get_hearers_in_view(message_range+1, source)
	var/list/the_dead = list()
	for(var/mob/M in player_list)
		if(M.stat == DEAD && M.client && ((M.client.prefs.chat_toggles & CHAT_GHOSTEARS) || (get_dist(M, src) <= 7 && M.z == z)) && client) // client is so that ghosts don't have to listen to mice
			listening |= M
			the_dead |= M

	var/eavesdropping = stars(message)
	var/accent
	if(voice_print)
		accent = accent_from_voiceprint(voice_print)
	var/eavesrendered = compose_message(src, languages_spoken, eavesdropping, , spans, null, accent, message_mode)
	var/rendered = compose_message(src, languages_spoken, message, , spans, null, accent, message_mode)
	for(var/atom/movable/AM in listening)
		if(get_dist(src, AM) > message_range && !(AM in the_dead))
			AM.Hear(eavesrendered, src, languages_spoken, eavesdropping, , spans, voice_print, accent, message_mode)
		else
			AM.Hear(rendered, src, languages_spoken, message, , spans, voice_print, accent, message_mode)

	//speech bubble
	var/list/speech_bubble_recipients = list()
	for(var/mob/M in listening)
		if(M.client)
			speech_bubble_recipients.Add(M.client)
	var/image/I = image('icons/mob/talk.dmi', src, "[bubble_type][say_test(message)]", FLY_LAYER)
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	spawn(0)
		flick_overlay(I, speech_bubble_recipients, 30)

/mob/living/compose_namepart(atom/movable/speaker, namepart, edit_tag, radio_freq)
	if(edit_tag)
		namepart = "<a title='Rename' href='?src=\ref[src];voiceprint_edit=[edit_tag];t=[world.time]'>[namepart]</a>"
	. = namepart

/mob/proc/binarycheck()
	return 0

/mob/living/can_speak(message) //For use outside of Say()
	if(can_speak_basic(message) && can_speak_vocal(message))
		return 1

/mob/living/proc/can_speak_basic(message) //Check BEFORE handling of xeno and ling channels
	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='danger'>You cannot speak in IC (muted).</span>")
			return 0
		if(client.handle_spam_prevention(message,MUTE_IC))
			return 0

	return 1

/mob/living/proc/can_speak_vocal(message) //Check AFTER handling of xeno and ling channels
	if(disabilities & MUTE)
		return 0

	if(is_muzzled())
		return 0

	if(!IsVocal())
		return 0

	return 1

/mob/living/proc/check_emote(message)
	if(copytext(message, 1, 2) == "*")
		emote(copytext(message, 2))
		return 1

/mob/living/proc/get_message_mode(message)
	if(copytext(message, 1, 2) == ";")
		return MODE_HEADSET
	else if(copytext(message, 1, 2) == "#")
		return MODE_WHISPER
	else if(length(message) > 2)
		return department_radio_keys[copytext(message, 1, 3)]

/mob/living/proc/handle_inherent_channels(message, message_mode)
	if(message_mode == MODE_CHANGELING)
		switch(lingcheck())
			if(3)
				var/msg = "<i><font color=#800040><b>[src.mind]:</b> [message]</font></i>"
				for(var/mob/M in mob_list)
					if(M in dead_mob_list)
						var/link = FOLLOW_LINK(M, src)
						to_chat(M, "[link] [msg]")
					else
						switch(M.lingcheck())
							if(3)
								to_chat(M, msg)
							if(2)
								to_chat(M, msg)
							if(1)
								if(prob(40))
									to_chat(M, "<i><font color=#800080>We can faintly sense an outsider trying to communicate through the hivemind...</font></i>")
			if(2)
				var/msg = "<i><font color=#800080><b>[mind.changeling.changelingID]:</b> [message]</font></i>"
				log_say("[mind.changeling.changelingID]/[src.key] : [message]")
				for(var/mob/M in mob_list)
					if(M in dead_mob_list)
						var/link = FOLLOW_LINK(M, src)
						to_chat(M, "[link] [msg]")
					else
						switch(M.lingcheck())
							if(3)
								to_chat(M, msg)
							if(2)
								to_chat(M, msg)
							if(1)
								if(prob(40))
									to_chat(M, "<i><font color=#800080>We can faintly sense another of our kind trying to communicate through the hivemind...</font></i>")
			if(1)
				to_chat(src, "<i><font color=#800080>Our senses have not evolved enough to be able to communicate this way...</font></i>")
		return TRUE
	if(message_mode == MODE_ALIEN)
		if(hivecheck())
			alien_talk(message)
		return TRUE
	if(message_mode == MODE_VOCALCORDS)
		if(iscarbon(src))
			var/mob/living/carbon/C = src
			var/obj/item/organ/vocal_cords/V = C.getorganslot("vocal_cords")
			if(V && V.can_speak_with())
				V.handle_speech(message) //message
				V.speak_with(message) //action
		return TRUE
	return FALSE

/mob/living/proc/treat_message(message)
	if(getBrainLoss() >= 60)
		message = derpspeech(message, stuttering)

	if(stuttering)
		message = stutter(message)

	if(slurring)
		message = slur(message)

	if(cultslurring)
		message = cultslur(message)

	message = capitalize(message)

	return message

/mob/living/proc/radio(message, message_mode, list/spans)
	switch(message_mode)
		if(MODE_R_HAND)
			for(var/obj/item/r_hand in get_held_items_for_side("r", all = TRUE))
				if (r_hand)
					return r_hand.talk_into(src, message, , spans)
				return ITALICS | REDUCE_RANGE
		if(MODE_L_HAND)
			for(var/obj/item/l_hand in get_held_items_for_side("l", all = TRUE))
				if (l_hand)
					return l_hand.talk_into(src, message, , spans)
				return ITALICS | REDUCE_RANGE

		if(MODE_INTERCOM)
			for (var/obj/item/device/radio/intercom/I in view(1, null))
				I.talk_into(src, message, , spans)
			return ITALICS | REDUCE_RANGE

		if(MODE_BINARY)
			if(binarycheck())
				robot_talk(message)
			return ITALICS | REDUCE_RANGE //Does not return 0 since this is only reached by humans, not borgs or AIs.
	return 0

/mob/living/lingcheck() //1 is ling w/ no hivemind. 2 is ling w/hivemind. 3 is ling victim being linked into hivemind.
	if(mind && mind.changeling)
		if(mind.changeling.changeling_speak)
			return 2
		return 1
	if(mind && mind.linglink)
		return 3
	return 0

/mob/living/say_quote(input, list/spans, message_mode)
	var/tempinput = attach_spans(input, spans)
	if (stuttering)
		return "stammers, \"[tempinput]\""
	if (getBrainLoss() >= 60)
		return "gibbers, \"[tempinput]\""
	if(message_mode == MODE_WHISPER)
		return "[verb_whisper], \"[tempinput]\""
	if(message_mode == MODE_WHISPER_CRIT)
		return "[verb_whisper] in [p_their()] last breath, \"[tempinput]\""

	return ..()

/mob/living/whisper(message as text)
	say("#[message]")
