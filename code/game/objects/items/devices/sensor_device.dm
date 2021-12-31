/obj/item/sensor_device
	name = "handheld crew monitor" //Thanks to Gun Hog for the name!
	desc = "A miniature machine that tracks suit sensors across the station."
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	atom_size = ITEM_SIZE_SMALL
	slot_flags = ITEM_SLOT_BELT
	custom_price = PAYCHECK_MEDIUM * 5
	custom_premium_price = PAYCHECK_MEDIUM * 6

/obj/item/sensor_device/attack_self(mob/user)
	GLOB.crewmonitor.show(user,src) //Proc already exists, just had to call it
