/obj/item/medical/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'


/obj/item/medical/organ/heart
	name = "heart"
	icon_state = "heart-on"
	var/beating = 1

/obj/item/medical/organ/heart/update_icon()
	if(beating)
		icon_state = "heart-on"
	else
		icon_state = "heart-off"


/obj/item/medical/organ/appendix
	name = "appendix"
	icon_state = "appendix"
	var/inflamed = 1

/obj/item/medical/organ/appendix/update_icon()
	if(inflamed)
		icon_state = "appendixinflamed"
	else
		icon_state = "appendix"


//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm