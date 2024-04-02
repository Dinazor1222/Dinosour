///Lists related to quirk selection

///Types of glasses that can be selected at character selection with the Nearsighted quirk
GLOBAL_LIST_INIT(nearsighted_glasses, list(
	"Regular" = /obj/item/clothing/glasses/regular,
	"Circle" = /obj/item/clothing/glasses/regular/circle,
	"Hipster" = /obj/item/clothing/glasses/regular/hipster,
	"Thin" = /obj/item/clothing/glasses/regular/thin,
	"Jamjar" = /obj/item/clothing/glasses/regular/jamjar,
	"Binoclard" = /obj/item/clothing/glasses/regular/kim,
))

///Options for the prosthetic limb quirk to choose from
GLOBAL_LIST_INIT(limb_choice, list(
	"Left arm" = /obj/item/bodypart/arm/left/robot/surplus,
	"Right arm" = /obj/item/bodypart/arm/right/robot/surplus,
	"Left leg" = /obj/item/bodypart/leg/left/robot/surplus,
	"Right leg" = /obj/item/bodypart/leg/right/robot/surplus,
))

///Transhumanist quirk
GLOBAL_LIST_INIT(limb_choice_transhuman, list(
	"Left Arm" = /obj/item/bodypart/arm/left/robot,
	"Right Arm" = /obj/item/bodypart/arm/right/robot,
	"Left Leg" = /obj/item/bodypart/leg/left/robot,
	"Right Leg" = /obj/item/bodypart/leg/right/robot,
))
///Hemiplegic Quirk
GLOBAL_LIST_INIT(side_choice_hemiplegic, list(
	"Left Side" = /datum/brain_trauma/severe/paralysis/hemiplegic/left,
	"Right Side" = /datum/brain_trauma/severe/paralysis/hemiplegic/right,
))

///Options for the Junkie quirk to choose from
GLOBAL_LIST_INIT(possible_junkie_addictions, setup_junkie_addictions(list(
	/datum/reagent/drug/blastoff,
	/datum/reagent/drug/krokodil,
	/datum/reagent/medicine/morphine,
	/datum/reagent/drug/happiness,
	/datum/reagent/drug/methamphetamine,
)))

///Options for the Smoker quirk to choose from
GLOBAL_LIST_INIT(possible_smoker_addictions, setup_junkie_addictions(list(
	/obj/item/storage/fancy/cigarettes,
	/obj/item/storage/fancy/cigarettes/cigpack_midori,
	/obj/item/storage/fancy/cigarettes/cigpack_uplift,
	/obj/item/storage/fancy/cigarettes/cigpack_robust,
	/obj/item/storage/fancy/cigarettes/cigpack_robustgold,
	/obj/item/storage/fancy/cigarettes/cigpack_carp,
	/obj/item/storage/fancy/cigarettes/cigars,
	/obj/item/storage/fancy/cigarettes/cigars/cohiba,
	/obj/item/storage/fancy/cigarettes/cigars/havana,
)))

///Options for the Alcoholic quirk to choose from
GLOBAL_LIST_INIT(possible_alcoholic_addictions, list(
	"Beekhof Blauw Curaçao" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/curacao, "reagent" = /datum/reagent/consumable/ethanol/curacao),
	"Buckin' Bronco's Applejack" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/applejack, "reagent" = /datum/reagent/consumable/ethanol/applejack),
	"Voltaic Yellow Wine" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/wine_voltaic, "reagent" = /datum/reagent/consumable/ethanol/wine_voltaic),
	"Caccavo guaranteed quality tequila" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/tequila, "reagent" = /datum/reagent/consumable/ethanol/tequila),
	"Captain Pete's Cuban spiced rum" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/rum, "reagent" = /datum/reagent/consumable/ethanol/rum),
	"Chateau de Baton premium cognac" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/cognac, "reagent" = /datum/reagent/consumable/ethanol/cognac),
	"Doublebeard's bearded special wine" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/wine, "reagent" = /datum/reagent/consumable/ethanol/wine),
	"Extra-strong absinthe" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/absinthe, "reagent" = /datum/reagent/consumable/ethanol/absinthe),
	"Goldeneye vermouth" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/vermouth, "reagent" = /datum/reagent/consumable/ethanol/vermouth),
	"Griffeater gin" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/gin, "reagent" = /datum/reagent/consumable/ethanol/gin),
	"Jian Hard Cider" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/hcider, "reagent" = /datum/reagent/consumable/ethanol/hcider),
	"Luini Amaretto" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/amaretto, "reagent" = /datum/reagent/consumable/ethanol/amaretto),
	"Magm-Ale" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/ale, "reagent" = /datum/reagent/consumable/ethanol/ale),
	"Phillipes well-aged Grappa" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/grappa, "reagent" = /datum/reagent/consumable/ethanol/grappa),
	"Pride of the Union Navy-Strength Rum" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/navy_rum, "reagent" = /datum/reagent/consumable/ethanol/navy_rum),
	"Rabid Bear malt liquor" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/maltliquor, "reagent" = /datum/reagent/consumable/ethanol/beer/maltliquor),
	"Robert Robust's coffee liqueur" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/kahlua, "reagent" = /datum/reagent/consumable/ethanol/kahlua),
	"Ryo's traditional sake" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/sake, "reagent" = /datum/reagent/consumable/ethanol/sake),
	"Space beer" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/beer, "reagent" = /datum/reagent/consumable/ethanol/beer),
	"Tunguska triple distilled" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/vodka, "reagent" = /datum/reagent/consumable/ethanol/vodka),
	"Uncle Git's special reserve" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/whiskey, "reagent" = /datum/reagent/consumable/ethanol/whiskey),
	"Breezy Shoals Coconut Rum" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/coconut_rum, "reagent" = /datum/reagent/consumable/ethanol/coconut_rum),
	"Moonlabor Yūyake" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/yuyake, "reagent" = /datum/reagent/consumable/ethanol/yuyake),
	"Shu-Kouba Straight Shochu" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/shochu, "reagent" = /datum/reagent/consumable/ethanol/shochu)
))

///Options for Prosthetic Organ
GLOBAL_LIST_INIT(organ_choice, list(
	"Heart" = ORGAN_SLOT_HEART,
	"Lungs" = ORGAN_SLOT_LUNGS,
	"Liver" = ORGAN_SLOT_LIVER,
	"Stomach" = ORGAN_SLOT_STOMACH,
))
