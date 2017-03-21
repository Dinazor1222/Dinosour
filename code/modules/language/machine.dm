/datum/language/machine
	name = "Encoded Audio Language"
	desc = "An efficient language of encoded tones developed by synthetics and cyborgs."
	speech_verb = "whistles"
	ask_verb = "chirps"
	exclaim_verb = "whistles loudly"
	colour = "changeling"
	key = "6"
	flags = NO_STUTTER
	syllables = list("beep","beep","beep","beep","beep","boop","boop","boop","bop","bop","dee","dee","doo","doo","hiss","hss","buzz","buzz","bzz","ksssh","keey","wurr","wahh","tzzz")
	space_chance = 10

/datum/language/machine/get_random_name()
	if(prob(70))
		return "[pick(posibrain_names)]-[rand(100, 999)]"
	return pick(ai_names)
