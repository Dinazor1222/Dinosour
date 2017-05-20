/obj/item/clothing/mask/breath
	desc = "A close-fitting mask that can be connected to an air supply."
	name = "breath mask"
	icon_state = "breath"
	item_state = "m_mask"
	body_parts_covered = 0
	flags = MASKINTERNALS
	visor_flags = MASKINTERNALS
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.10
	permeability_coefficient = 0.50
	actions_types = list(/datum/action/item_action/adjust)
	flags_cover = MASKCOVERSMOUTH
	visor_flags_cover = MASKCOVERSMOUTH
	resistance_flags = 0

/obj/item/clothing/mask/breath/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/breath/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, be_close=TRUE))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	else
		adjustmask(user)

/obj/item/clothing/mask/breath/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Alt-click [src] to adjust it.</span>")

/obj/item/clothing/mask/breath/medical
	desc = "A close-fitting sterile mask that can be connected to an air supply."
	name = "medical mask"
	icon_state = "medical"
	item_state = "m_mask"
	permeability_coefficient = 0.01
	put_on_delay = 10

//Vaporizing breath mask


/obj/item/clothing/mask/vape/vapormask
	name = "Vaporizing Breath Mask"
	desc = "A breath mask with an integrated chemical vaporizer. A label reads \"In case of hallucinations, put mask on and inhale deeply. Warning: Do not fill with flammable materials.\""
	icon_state = "vapor" 
	item_state = "vapor"
	chem_volume = 50 //Lower capacity than a regular vape
	flags = MASKINTERNALS
	flags_cover = MASKCOVERSMOUTH
	gas_transfer_coefficient = 0.10
	permeability_coefficient = 0.50

/obj/item/clothing/mask/vape/vapormask/Initialize()
	. = ..() //I have no idea what this line does but apparently Initialize() is supposed to have it.
	create_reagents(chem_volume)
	reagents.set_reacting(FALSE)
	reagents.add_reagents("synaptizine", 25)

/obj/item/clothing/mask/vape/vapormask/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/weapon/reagent_containers) && (O.container_type & OPENCONTAINER))
		return ..()

/obj/item/clothing/mask/vape/vapormask/emag_act()
	return
