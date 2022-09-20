/// Test to verify message mods are parsed correctly
/datum/unit_test/get_message_mods
	var/mob/host_mob

/datum/unit_test/get_message_mods/Run()
	host_mob = allocate(/mob/living/carbon/human)

	test("Hello", "Hello", list())
	test(";HELP", "HELP", list(MODE_HEADSET = TRUE))
	test(";%Never gonna give you up", "Never gonna give you up", list(MODE_HEADSET = TRUE, MODE_SING = TRUE))
	test(".s Gun plz", "Gun plz", list(RADIO_KEY = RADIO_KEY_SECURITY, RADIO_EXTENSION = RADIO_CHANNEL_SECURITY))
	test("...What", "...What", list())

/datum/unit_test/get_message_mods/proc/test(message, expected_message, list/expected_mods)
	var/list/mods = list()
	TEST_ASSERT_EQUAL(host_mob.get_message_mods(message, mods), expected_message, "Chopped message was not what we expected. Message: [message]")

	for (var/mod_key in mods)
		TEST_ASSERT_EQUAL(mods[mod_key], expected_mods[mod_key], "The value for [mod_key] was not what we expected. Message: [message]")
		expected_mods -= mod_key

	TEST_ASSERT(!expected_mods.len,
		"Some message mods were expected, but were not returned by get_message_mods: [json_encode(expected_mods)]. Message: [message]")

/// Test to verify COMSIG_MOB_SAY is sent the exact same list as the message args, as they're operated on
/datum/unit_test/say_signal

/datum/unit_test/say_signal/Run()
	var/mob/living/dummy = allocate(/mob/living)

	RegisterSignal(dummy, COMSIG_MOB_SAY, .proc/check_say)
	dummy.say("Make sure the say signal gets the arglist say is past, no copies!")

/datum/unit_test/say_signal/proc/check_say(mob/living/source, list/say_args)
	SIGNAL_HANDLER

	TEST_ASSERT_EQUAL(REF(say_args), source.last_say_args_ref, "Say signal didn't get the argslist of say as a reference. \
		This is required for the signal to function in most places - do not create a new instance of a list when passing it in to the signal.")

// For the above test to track the last use of say's message args.
/mob/living
	var/last_say_args_ref

/datum/unit_test/translate_language
	var/mob/host_mob

/datum/unit_test/translate_language/Run()
	host_mob = allocate(/mob/living/carbon/human)
	var/surfer_quote = "surfing in the USA"

	host_mob.grant_language(/datum/language/beachbum, spoken=TRUE, understood=FALSE) // can speak but can't understand
	host_mob.add_blocked_language(subtypesof(/datum/language) - /datum/language/beachbum, LANGUAGE_STONER)
	TEST_ASSERT_NOTEQUAL(surfer_quote, host_mob.translate_language(host_mob, /datum/language/beachbum, surfer_quote), "Language test failed. Mob was supposed to understand: [surfer_quote]")

	host_mob.grant_language(/datum/language/beachbum, spoken=TRUE, understood=TRUE) // can now understand
	TEST_ASSERT_EQUAL(surfer_quote, host_mob.translate_language(host_mob, /datum/language/beachbum, surfer_quote), "Language test failed. Mob was supposed NOT to understand: [surfer_quote]")

/datum/unit_test/speech
	var/handle_raw_speech_result
	var/handle_speech_result
	var/handle_hearing_result

/datum/unit_test/speech/proc/handle_raw_speech(datum/source, mob/speaker, message)
	SIGNAL_HANDLER

	// check if source == speaker?
	TEST_ASSERT(speaker, "Handle raw speech signal does not have a speaker arg")
	TEST_ASSERT(message, "Handle raw speech signal does not have a message arg")

	handle_raw_speech_result = TRUE

/datum/unit_test/speech/proc/handle_speech(datum/source, mob/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	TEST_ASSERT(message, "Handle speech signal does not have a message arg")
	var/spans = speech_args[SPEECH_SPANS]
	TEST_ASSERT(spans, "Handle speech signal does not have spans arg")
	var/language = speech_args[SPEECH_LANGUAGE]
	TEST_ASSERT(language, "Handle speech signal does not have a language arg")
	// Uncomment this when the other SPEECH_RANGE PR gets merged
	//var/range = speech_args[SPEECH_RANGE]
	//TEST_ASSERT(range, "Handle speech signal does not have a range arg")

	handle_speech_result = TRUE

/datum/unit_test/speech/proc/handle_hearing(datum/source, list/hearing_args)
	SIGNAL_HANDLER

	//if(!owner.can_hear() || owner == hearing_args[HEARING_SPEAKER] || !owner.has_language(hearing_args[HEARING_LANGUAGE]))
	//	return

	var/message = hearing_args[HEARING_MESSAGE]
	TEST_ASSERT(message, "Handle hearing signal does not have a message arg")
	var/speaker = hearing_args[HEARING_SPEAKER]
	TEST_ASSERT(speaker, "Handle hearing signal does not have a speaker arg")
	var/language = hearing_args[HEARING_LANGUAGE]
	TEST_ASSERT(language, "Handle hearing signal does not have a language arg")
	var/raw_message = hearing_args[HEARING_RAW_MESSAGE]
	TEST_ASSERT(raw_message, "Handle hearing signal does not have a raw message arg")
	// TODO radio unit tests
	//var/radio_freq = hearing_args[HEARING_RADIO_FREQ]
	//TEST_ASSERT(radio_freq, "Handle hearing signal does not have a radio freq arg")
	var/spans = hearing_args[HEARING_SPANS]
	TEST_ASSERT(spans, "Handle hearing signal does not have a spans arg")
	var/message_mode = hearing_args[HEARING_MESSAGE_MODE]
	TEST_ASSERT(message_mode, "Handle hearing signal does not have a message mode arg")

	handle_hearing_result = TRUE

/datum/unit_test/speech/Run()
	var/mob/living/carbon/human/speaker = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/listener = allocate(/mob/living/carbon/human)

	RegisterSignal(speaker, COMSIG_GLOB_LIVING_SAY_SPECIAL, .proc/handle_raw_speech)
	RegisterSignal(speaker, COMSIG_MOB_SAY, .proc/handle_speech)
	RegisterSignal(listener, COMSIG_MOVABLE_HEAR, .proc/handle_hearing)

	speaker.forceMove(run_loc_floor_bottom_left)
	// move listener 1 tiles away
	listener.forceMove(locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	speaker.say("The quick brown fox jumps over the lazy dog", spans = list(SPAN_YELL))

	TEST_ASSERT(handle_raw_speech_result, "Handle raw speech signal was not fired")
	TEST_ASSERT(handle_speech_result, "Handle speech signal was not fired")
	TEST_ASSERT(handle_hearing_result, "Handle hearing signal was not fired")

	// move listener 5 tiles away (for whisper testing)
	listener.forceMove(locate(run_loc_floor_bottom_left.x + 5, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	// move listener 10 tiles away (should be out of range of speaker)
	listener.forceMove(locate(run_loc_floor_bottom_left.x + 10, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
