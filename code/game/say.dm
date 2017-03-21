/*
 	Miauw's big Say() rewrite.
	This file has the basic atom/movable level speech procs.
	And the base of the send_speech() proc, which is the core of saycode.
*/
var/list/freqtospan = list(
	"1351" = "sciradio",
	"1355" = "medradio",
	"1357" = "engradio",
	"1347" = "suppradio",
	"1349" = "servradio",
	"1359" = "secradio",
	"1353" = "comradio",
	"1447" = "aiprivradio",
	"1213" = "syndradio",
	"1337" = "centcomradio"
	)

/atom/movable/proc/say(message)
	if(!can_speak())
		return
	if(message == "" || !message)
		return
	var/list/spans = get_spans()
	var/voice_print = get_voiceprint()
	send_speech(message, 6, src, , spans, voice_print)

/atom/movable/proc/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans, voice_print, accent, message_mode)
	return

/atom/movable/proc/can_speak()
	return 1

/atom/movable/proc/send_speech(message, range = 6, obj/source = src, bubble_type, list/spans, voice_print)
	var/rendered = compose_message(src, languages_spoken, message, , spans)
	for(var/atom/movable/AM in get_hearers_in_view(range, src))
		AM.Hear(rendered, src, languages_spoken, message, , spans, voice_print)

//To get robot span classes, stuff like that.
/atom/movable/proc/get_spans()
	return list()

/atom/movable/proc/accent_from_voiceprint(voice_print)
	if(istext(voice_print) && length(voice_print))
		. = ""
		var/hash = 0
		for(var/i = 1, i <= length(voice_print), i++)
			hash += text2ascii(voice_print, i)
		var/static/list/accent_colors = list("black", "brown", "darkgreen", "darkred", "navy", "purple")
		var/static/list/accent_sizes = list("1.1em", "0.9em")
		var/static/list/accent_fonts = list("Arial", "Georgia, Vernanda", "Cambria")
		var/color_index = ((hash / 8) % accent_colors.len) + 1
		var/accent_color = color2hex(accent_colors[color_index])
		. += "color: [accent_color];"
		var/size_index = (hash / 16) % (accent_sizes.len + 1)
		if(size_index)
			var/accent_size = accent_sizes[size_index]
			. += " font-size: [accent_size];"
		var/fonts_index = (hash / 24) % (accent_fonts.len + 1)
		if(fonts_index)
			var/accent_font = accent_fonts[fonts_index]
			. += " font-family: [accent_font];"

/atom/movable/proc/compose_accent(name, accent)
	if(accent)
		. = "<span style='[accent]'>[name]</span>"
	else
		. = name

/atom/movable/proc/compose_message(atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans, name, accent, message_mode, edit_tag)
	//This proc uses text() because it is faster than appending strings. Thanks BYOND.
	//Basic span
	var/spanpart1 = "<span class='[radio_freq ? get_radio_span(radio_freq) : "game say"]'>"
	//Start name span.
	var/spanpart2 = "<span class='name'>"
	//Radio freq/name display
	var/freqpart = radio_freq ? "\[[get_radio_name(radio_freq)]\] " : ""
	//Speaker name
	var/namepart = name ? name : "[speaker.GetVoice()][speaker.get_alt_name()]"
	//End name span.
	var/endspanpart = "</span>"
	//Message
	var/messagepart = " <span class='message'>[lang_treat(speaker, message_langs, raw_message, spans, message_mode)]</span></span>"

	return "[spanpart1][spanpart2][freqpart][compose_namepart(speaker, compose_accent(namepart, accent), edit_tag, radio_freq)][endspanpart][messagepart]"

/atom/movable/proc/compose_namepart(atom/movable/speaker, namepart, edit_tag, radio_freq)
	return namepart

/atom/movable/proc/say_quote(input, list/spans=list())
	if(!input)
		return "says, \"...\""	//not the best solution, but it will stop a large number of runtimes. The cause is somewhere in the Tcomms code
	var/ending = copytext(input, length(input))
	if(copytext(input, length(input) - 1) == "!!")
		spans |= SPAN_YELL
		return "[verb_yell], \"[attach_spans(input, spans)]\""
	input = attach_spans(input, spans)
	if(ending == "?")
		return "[verb_ask], \"[input]\""
	if(ending == "!")
		return "[verb_exclaim], \"[input]\""

	return "[verb_say], \"[input]\""

/atom/movable/proc/lang_treat(atom/movable/speaker, message_langs, raw_message, list/spans, message_mode)
	if(languages_understood & message_langs)
		var/atom/movable/AM = speaker.GetSource()
		if(AM) //Basically means "if the speaker is virtual"
			if(AM.verb_say != speaker.verb_say || AM.verb_ask != speaker.verb_ask || AM.verb_exclaim != speaker.verb_exclaim || AM.verb_yell != speaker.verb_yell) //If the saymod was changed
				return speaker.say_quote(raw_message, spans, message_mode)
			return AM.say_quote(raw_message, spans, message_mode)
		else
			return speaker.say_quote(raw_message, spans, message_mode)
	else if((message_langs & HUMAN) || (message_langs & RATVAR)) //it's human or ratvar language
		var/atom/movable/AM = speaker.GetSource()
		if(message_langs & HUMAN)
			raw_message = stars(raw_message)
		if(message_langs & RATVAR)
			raw_message = text2ratvar(raw_message)
		if(AM)
			return AM.say_quote(raw_message, spans, message_mode)
		else
			return speaker.say_quote(raw_message, spans, message_mode)
	else if(message_langs & MONKEY)
		return "chimpers."
	else if(message_langs & ALIEN)
		return "hisses."
	else if(message_langs & ROBOT)
		return "beeps rapidly."
	else if(message_langs & DRONE)
		return "chitters."
	else if(message_langs & SWARMER)
		return "hums."
	else
		return "makes a strange sound."

/proc/get_radio_span(freq)
	var/returntext = freqtospan["[freq]"]
	if(returntext)
		return returntext
	return "radio"

/proc/get_radio_name(freq)
	var/returntext = radiochannelsreverse["[freq]"]
	if(returntext)
		return returntext
	return "[copytext("[freq]", 1, 4)].[copytext("[freq]", 4, 5)]"

/proc/attach_spans(input, list/spans)
	return "[message_spans_start(spans)][input]</span>"

/proc/message_spans_start(list/spans)
	var/output = "<span class='"
	for(var/S in spans)
		output = "[output][S] "
	output = "[output]'>"
	return output

/proc/say_test(text)
	var/ending = copytext(text, length(text))
	if (ending == "?")
		return "1"
	else if (ending == "!")
		return "2"
	return "0"

/atom/movable/proc/GetVoice()
	return name

/atom/movable/proc/IsVocal()
	return 1

/atom/movable/proc/get_alt_name()

//HACKY VIRTUALSPEAKER STUFF BEYOND THIS POINT
//these exist mostly to deal with the AIs hrefs and job stuff.

/atom/movable/proc/GetJob() //Get a job, you lazy butte

/atom/movable/proc/GetSource()

/atom/movable/proc/GetRadio()

//VIRTUALSPEAKERS
/atom/movable/virtualspeaker
	var/job
	var/atom/movable/source
	var/obj/item/device/radio/radio

/atom/movable/virtualspeaker/GetJob()
	return job

/atom/movable/virtualspeaker/GetSource()
	return source

/atom/movable/virtualspeaker/GetRadio()
	return radio

/atom/movable/virtualspeaker/default_identity_heard()
	. = (source ? source.default_identity_heard() : ..())

/atom/movable/virtualspeaker/default_identity_seen()
	. = (source ? source.default_identity_seen() : ..())

/atom/movable/virtualspeaker/default_identity_interact()
	. = (source ? source.default_identity_interact() : ..())
