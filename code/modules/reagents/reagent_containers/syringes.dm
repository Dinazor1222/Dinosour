////////////////////////////////////////////////////////////////////////////////
/// Syringes.
////////////////////////////////////////////////////////////////////////////////
#define SYRINGE_DRAW 0
#define SYRINGE_INJECT 1

/obj/item/chem/syringe
	name = "syringe"
	desc = "A syringe that can hold up to 15 units."
	icon = 'icons/obj/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null	//list(5, 10, 15)
	volume = 15
	var/mode = SYRINGE_DRAW

	on_reagent_change()
		update_icon()

	pickup(mob/user)
		..()
		update_icon()

	dropped(mob/user)
		..()
		update_icon()

	attack_self(mob/user)
		mode = !mode
		update_icon()

	attack_hand()
		..()
		update_icon()

	attack_paw()
		return attack_hand()

	attackby(obj/item/I, mob/user)
		return

	afterattack(obj/target, mob/user , flag)
		if(!target.reagents) return

		switch(mode)
			if(SYRINGE_DRAW)

				if(reagents.total_volume >= reagents.maximum_volume)
					user << "<span class='notice'>The syringe is full.</span>"
					return

				if(ismob(target))	//Blood!
					if(istype(target, /mob/living/carbon/slime))
						user << "<span class='notice'>You are unable to locate any blood.</span>"
						return
					if(reagents.has_reagent("blood"))
						user << "<span class='notice'>There is already a blood sample in this syringe.</span>"
						return
					if(istype(target, /mob/living/carbon))	//maybe just add a blood reagent to all mobs. Then you can suck them dry...With hundreds of syringes. Jolly good idea.
						var/amount = src.reagents.maximum_volume - src.reagents.total_volume
						var/mob/living/carbon/T = target
						var/datum/reagent/B = new /datum/reagent/blood
						if(!T.dna)
							user << "<span class='notice'>You are unable to locate any blood. (To be specific, your target seems to be missing their DNA datum- report this to an admin.)</span>"
							return
						if(NOCLONE in T.mutations)	//target done been et, no more blood in him
							user << "<span class='notice'>You are unable to locate any blood.</span>"
							return
						B.holder = src
						B.volume = amount
						//set reagent data
						B.data["donor"] = T

						/*
						if(T.virus && T.virus.spread_type != SPECIAL)
							B.data["virus"] = new T.virus.type(0)
						*/

						for(var/datum/disease/D in T.viruses)
							if(!B.data["viruses"])
								B.data["viruses"] = list()

							B.data["viruses"] += new D.type(0, D, 1)

						B.data["blood_DNA"] = copytext(T.dna.unique_enzymes,1,0)
						if(T.resistances&&T.resistances.len)
							B.data["resistances"] = T.resistances.Copy()
						if(istype(target, /mob/living/carbon/human))//I wish there was some hasproperty operation...
							var/mob/living/carbon/human/HT = target
							B.data["blood_type"] = copytext(HT.dna.b_type,1,0)
						var/list/temp_chem = list()
						for(var/datum/reagent/R in target.reagents.reagent_list)
							temp_chem += R.name
							temp_chem[R.name] = R.volume
						B.data["trace_chem"] = list2params(temp_chem)

						reagents.reagent_list += B
						reagents.update_total()
						on_reagent_change()
						reagents.handle_reactions()
						user.visible_message("<span class='notice'>[user] takes a blood sample from [target].</span>")

				else //if not mob
					if(!target.reagents.total_volume)
						user << "<span class='notice'>[target] is empty.</span>"
						return

					if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers) && !istype(target,/obj/item/slime/extract))
						user << "<span class='notice'>You cannot directly remove reagents from [target].</span>"
						return

					var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

					user << "<span class='notice'>You fill [src] with [trans] units of the solution.</span>"
				if (reagents.total_volume >= reagents.maximum_volume)
					mode=!mode
					update_icon()

			if(SYRINGE_INJECT)
				if(!reagents.total_volume)
					user << "<span class='notice'>[src] is empty.</span>"
					return
				if(istype(target, /obj/item/medical/implantcase/chem))
					return

				if(!target.is_open_container() && !ismob(target) && !istype(target, /obj/item/chem/food) && !istype(target, /obj/item/slime/extract) && !istype(target, /obj/item/clothing/mask/cigarette) && !istype(target, /obj/item/storage/fancy/cigarettes))
					user << "<span class='notice'>You cannot directly fill [target].</span>"
					return
				if(target.reagents.total_volume >= target.reagents.maximum_volume)
					user << "<span class='notice'>[target] is full.</span>"
					return

				if(ismob(target) && target != user)
					target.visible_message("<span class='danger'>[user] is trying to inject [target]!</span>", \
											"<span class='userdanger'>[user] is trying to inject [target]!</span>")
					if(!do_mob(user, target)) return
					target.visible_message("<span class='danger'>[user] injects [target] with the syringe!", \
									"<span class='userdanger'>[user] injects [target] with the syringe!")
					reagents.reaction(target, INGEST)
				if(ismob(target) && target == user)
					reagents.reaction(target, INGEST)
				spawn(5)
					target.add_fingerprint(user)
					var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
					user << "<span class='notice'>You inject [trans] unit\s of the solution. [src] now contains [reagents.total_volume] unit\s.</span>"
					if(reagents.total_volume <= 0 && mode == SYRINGE_INJECT)
						mode = SYRINGE_DRAW
						update_icon()


	update_icon()
		var/rounded_vol = round(reagents.total_volume,5)
		overlays.Cut()
		if(ismob(loc))
			var/injoverlay
			switch(mode)
				if (SYRINGE_DRAW)
					injoverlay = "draw"
				if (SYRINGE_INJECT)
					injoverlay = "inject"
			overlays += injoverlay
		icon_state = "[rounded_vol]"
		item_state = "syringe_[rounded_vol]"

		if(reagents.total_volume)
			var/image/filling = image('icons/obj/reagentfillings.dmi', src, "syringe10")

			switch(rounded_vol)
				if(5)	filling.icon_state = "syringe5"
				if(10)	filling.icon_state = "syringe10"
				if(15)	filling.icon_state = "syringe15"

			filling.icon += mix_color_from_reagents(reagents.reagent_list)
			overlays += filling


/obj/item/chem/syringe/lethal
	name = "lethal injection syringe"
	desc = "A syringe used for lethal injections. It can hold up to 50 units."
	amount_per_transfer_from_this = 50
	volume = 50

////////////////////////////////////////////////////////////////////////////////
/// Syringes. END
////////////////////////////////////////////////////////////////////////////////



/obj/item/chem/syringe/inaprovaline
	name = "syringe (inaprovaline)"
	desc = "Contains inaprovaline - used to stabilize patients."
	New()
		..()
		reagents.add_reagent("inaprovaline", 15)
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/chem/syringe/antitoxin
	name = "syringe (anti-toxin)"
	desc = "Contains anti-toxins."
	New()
		..()
		reagents.add_reagent("anti_toxin", 15)
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/chem/syringe/antiviral
	name = "syringe (spaceacillin)"
	desc = "Contains antiviral agents."
	New()
		..()
		reagents.add_reagent("spaceacillin", 15)
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/chem/syringe/lethal/choral
	New()
		..()
		reagents.add_reagent("chloralhydrate", 50)
		mode = SYRINGE_INJECT
		update_icon()


//Robot syringes
//Not special in any way, code wise. They don't have added variables or procs.
/obj/item/chem/syringe/robot/antitoxin
	name = "syringe (anti-toxin)"
	desc = "Contains anti-toxins."
	New()
		..()
		reagents.add_reagent("anti_toxin", 15)
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/chem/syringe/robot/inoprovaline
	name = "syringe (inoprovaline)"
	desc = "Contains inaprovaline - used to stabilize patients."
	New()
		..()
		reagents.add_reagent("inaprovaline", 15)
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/chem/syringe/robot/mixed
	name = "syringe (mixed)"
	desc = "Contains inaprovaline & anti-toxins."
	New()
		..()
		reagents.add_reagent("inaprovaline", 7)
		reagents.add_reagent("anti_toxin", 8)
		mode = SYRINGE_INJECT
		update_icon()