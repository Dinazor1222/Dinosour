/datum/species/android
	name = "Android"
	id = SPECIES_ANDROID
	species_traits = list(
		NO_DNA_COPY,
		NOTRANSSTING,
	)
	inherent_traits = list(
		TRAIT_CAN_USE_FLIGHT_POTION,
		TRAIT_GENELESS,
		TRAIT_LIMBATTACHMENT,
		TRAIT_NOBREATH,
		TRAIT_NOCLONELOSS,
		TRAIT_NOFIRE,
		TRAIT_NOHUNGER,
		TRAIT_NOMETABOLISM,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_TOXIMMUNE,
		TRAIT_NOBLOOD,
	)

	inherent_biotypes = MOB_ROBOTIC|MOB_HUMANOID
	meat = null
	species_language_holder = /datum/language_holder/synthetic
	wing_types = list(/obj/item/organ/external/wings/functional/robotic)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	internal_organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/internal/brain,
		ORGAN_SLOT_EARS = /obj/item/organ/internal/ears/cybernetic,
		ORGAN_SLOT_EYES = /obj/item/organ/internal/eyes/robotic,
		ORGAN_SLOT_TONGUE = /obj/item/organ/internal/tongue/robot,
		ORGAN_SLOT_HEART = NO_ORGAN,
		ORGAN_SLOT_LUNGS = NO_ORGAN,
		ORGAN_SLOT_STOMACH = NO_ORGAN,
		ORGAN_SLOT_LIVER = NO_ORGAN,
		ORGAN_SLOT_APPENDIX = NO_ORGAN,

		ORGAN_SLOT_BRAIN_ANTIDROP = NO_ORGAN,
		ORGAN_SLOT_BRAIN_ANTISTUN = NO_ORGAN,
		ORGAN_SLOT_HUD = NO_ORGAN,
		ORGAN_SLOT_BREATHING_TUBE = NO_ORGAN,
		ORGAN_SLOT_HEART_AID = NO_ORGAN,
		ORGAN_SLOT_STOMACH_AID = NO_ORGAN,
		ORGAN_SLOT_THRUSTERS = NO_ORGAN,
		ORGAN_SLOT_RIGHT_ARM_AUG = NO_ORGAN,
		ORGAN_SLOT_LEFT_ARM_AUG = NO_ORGAN,

		ORGAN_SLOT_ADAMANTINE_RESONATOR = NO_ORGAN,
		ORGAN_SLOT_VOICE = NO_ORGAN,
		ORGAN_SLOT_MONSTER_CORE = NO_ORGAN,
		ORGAN_SLOT_CHEST_BONUS = NO_ORGAN,
		ORGAN_SLOT_GROIN_BONUS = NO_ORGAN,

		ORGAN_SLOT_ZOMBIE = NO_ORGAN,
		ORGAN_SLOT_PARASITE_EGG = NO_ORGAN,

		ORGAN_SLOT_XENO_HIVENODE = NO_ORGAN,
		ORGAN_SLOT_XENO_ACIDGLAND = NO_ORGAN,
		ORGAN_SLOT_XENO_NEUROTOXINGLAND = NO_ORGAN,
		ORGAN_SLOT_XENO_RESINSPINNER = NO_ORGAN,
		ORGAN_SLOT_XENO_PLASMAVESSEL = NO_ORGAN,
		ORGAN_SLOT_XENO_EGGSAC = NO_ORGAN,
	)
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/robot,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/robot,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/robot,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/robot,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/robot,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/robot,
	)
	examine_limb_id = SPECIES_HUMAN

/datum/species/android/on_species_gain(mob/living/carbon/C)
	. = ..()
	// Androids don't eat, hunger or metabolise foods. Let's do some cleanup.
	C.set_safe_hunger_level()
