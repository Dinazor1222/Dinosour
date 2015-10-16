// Cold

/datum/disease/advance/cold/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Cold"
		symptoms = list(new/datum/symptom/sneeze)
	..(process, D, copy)


// Flu

/datum/disease/advance/flu/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Flu"
		symptoms = list(new/datum/symptom/cough)
	..(process, D, copy)


// Voice Changing

/datum/disease/advance/voice_change/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Epiglottis Mutation"
		symptoms = list(new/datum/symptom/voice_change)
	..(process, D, copy)


// Toxin Filter

/datum/disease/advance/heal/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Liver Enhancer"
		symptoms = list(new/datum/symptom/heal)
	..(process, D, copy)


// Toxin Comp
// shit nigga do you expect me to rng it up just to test some shit
/datum/disease/advance/converter/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Toxin Coverter"
		symptoms = list(new/datum/symptom/damage_converter)
	..(process, D, copy)


// Hullucigen

/datum/disease/advance/hullucigen/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Reality Impairment"
		symptoms = list(new/datum/symptom/hallucigen)
	..(process, D, copy)

//Inert Virus

/datum/disease/advance/inert/New(var/process = 1, var/datum/disease/advance/D, var/copy = 0)
	if(!D)
		name = "Inert Virus"
		symptoms = list(new/datum/symptom/inert)
	..(process, D, copy)