/* For employment contracts and demonic contracts */

/obj/item/weapon/paper/contract
	throw_range = 3
	throw_speed = 3
	var/signed = 0
	var/datum/mind/target

/obj/item/weapon/paper/contract/proc/update_text()
	name = "paper- generic contract"



/obj/item/weapon/paper/contract/employment/New(atom/loc, mob/living/nOwner)
	. = ..()
	if(!nOwner.mind)
		qdel(src)
		return -1
	target = nOwner.mind
	update_text(nOwner)


/obj/item/weapon/paper/contract/employment/update_text()
	name = "paper- [target] employment contract"
	info = "<center><B>Official copy of Nanotransen employment agreement</B></center><BR><BR><BR>Contract for [target]<BR><BR><BR>Placeholder text"


/obj/item/weapon/paper/contract/employment/attack(mob/living/M, mob/living/carbon/human/user)
	var/deconvert = 0
	if(M.mind == target && target.soulOwner == target)
		if(user.mind && (user.mind.assigned_role == "Lawyer"))
			deconvert = prob (25)
		if (user.mind && (user.mind.assigned_role =="Head of Personnel") || (user.mind.assigned_role == "Centcom Commander"))
			deconvert = prob (10) // the HoP doesn't have AS much legal training
	if(deconvert)
		M.visible_message("<span class='notice'>[user] reminds [M] that [M]'s soul was already purchased by Nanotransen!</span>")
		M << "<span class='boldnotice'>You feel that your soul has returned to it's rightful owner, Nanotransen.</span>"
		M.return_soul()
		return
	else
		if(ishuman(M))
			var/mob/living/carbon/human/N = M
			if(!istype(N.head, /obj/item/clothing/head/helmet))
				N.adjustBrainLoss(10)
				N << "<span class='danger'>You feel dumber.</span>"
		M.visible_message("<span class='danger'>[user] beats [M] over the head with [src]!</span>", \
			"<span class='userdanger'>[user] beats [M] over the head with [src]!</span>")


/obj/item/weapon/paper/contract/infernal
	var/contractType = CONTRACT_POWER
	burn_state = LAVA_PROOF
	var/burn_timer = 2 //it will be on fire when first created
	var/datum/mind/owner

/obj/item/weapon/paper/contract/infernal/update_icon()
	if(burn_timer > 0)
		icon_state = "paper_onfire"
		burn_timer -= 1
		return
	icon_state = "paper_words"
	return

/obj/item/weapon/paper/contract/infernal/New(atom/loc, mob/living/nTarget, var/incType, datum/mind/nOwner)
	..()
	owner = nOwner
	target = nTarget
	contractType = incType
	update_text()

/obj/item/weapon/paper/contract/infernal/suicide_act(mob/user)
	if(signed && (user == target))
		user.say("OH GREAT INFERNO!  I DEMAND YOU COLLECT YOUR BOUNTY IMMEDIATELY!")
		user.visible_message("<span class='suicide'>[user] holds up a contract claiming his soul, then immediately catches fire.</span>")
		if(istype(user, /mob/living))
			var/mob/living/U = user
			U.adjust_fire_stacks(20)
			U.IgniteMob()
		return(FIRELOSS)
	else
		..()




/obj/item/weapon/paper/contract/infernal/update_text()
	var/signature = "__________________"
	if(signed)
		signature = target.name
	switch(contractType)
		if(CONTRACT_POWER)
			name = "paper- Contract for infernal power"
			info = "<center><B>Contract for infernal power</B></center><BR><BR><BR>I, [target] of sound mind, do hereby willingly offer my soul to the infernal hells by way of the infernal agent [owner.demoninfo.truename], in exchange for power and physical strength.  I understand that upon my demise, my soul shall fall into the infernal hells, and my body may not be resurrected, cloned, or otherwise brought back to life.  I also understand that this will prevent my brain from being used in an MMI.<BR><BR><BR>Signed, <i>[signature]</i>"
		if(CONTRACT_WEALTH)
			name = "paper- Contract for unlimited wealth"
			info = "<center><B>Contract for unlimited wealth</B></center><BR><BR><BR>I, [target] of sound mind, do hereby willingly offer my soul to the infernal hells by way of the infernal agent [owner.demoninfo.truename], in exchange for a pocket that never runs out of valuable resources.  I understand that upon my demise, my soul shall fall into the infernal hells, and my body may not be resurrected, cloned, or otherwise brought back to life.  I also understand that this will prevent my brain from being used in an MMI.<BR><BR><BR>Signed, <i>[signature]</i>"
		if(CONTRACT_PRESTIGE)
			name = "paper- Contract for prestige"
			info = "<center><B>Contract for prestige</B></center><BR><BR><BR>I, [target] of sound mind, do hereby willingly offer my soul to the infernal hells by way of the infernal agent [owner.demoninfo.truename], in exchange for prestige and esteem among my peers.  I understand that upon my demise, my soul shall fall into the infernal hells, and my body may not be resurrected, cloned, or otherwise brought back to life.  I also understand that this will prevent my brain from being used in an MMI.<BR><BR><BR>Signed, <i>[signature]</i>"
		if(CONTRACT_MAGIC)
			name = "paper- Contract for magic"
			info = "<center><B>Contract for magic</B></center><BR><BR><BR>I, [target] of sound mind, do hereby willingly offer my soul to the infernal hells by way of the infernal agent [owner.demoninfo.truename], in exchange for arcane abilities beyond normal human ability.  I understand that upon my demise, my soul shall fall into the infernal hells, and my body may not be resurrected, cloned, or otherwise brought back to life.  I also understand that this will prevent my brain from being used in an MMI.<BR><BR><BR>Signed, <i>[signature]</i>"
		if(CONTRACT_REVIVE)
			name = "paper- Contract for resurrection"
			info = "<center><B>Contract for resurrection</B></center><BR><BR><BR>I, [target] of sound mind, do hereby willingly offer my soul to the infernal hells by way of the infernal agent [owner.demoninfo.truename], in exchange for resurrection and curing of all injuries.  I understand that upon my demise, my soul shall fall into the infernal hells, and my body may not be resurrected, cloned, or otherwise brought back to life.  I also understand that this will prevent my brain from being used in an MMI.<BR><BR><BR>Signed, <i>[signature]</i>"
		if(CONTRACT_KNOWLEDGE)
			name = "paper- Contract for knowledge"
			info = "<center><B>Contract for knowledge</B></center><BR><BR><BR>I, [target] of sound mind, do hereby willingly offer my soul to the infernal hells by way of the infernal agent [owner.demoninfo.truename], in exchange for boundless knowledge.  I understand that upon my demise, my soul shall fall into the infernal hells, and my body may not be resurrected, cloned, or otherwise brought back to life.  I also understand that this will prevent my brain from being used in an MMI.<BR><BR><BR>Signed, <i>[signature]</i>"
		if(CONTRACT_UNWILLING)
			name = "paper- Contract for soul"
			info = "<center><B>Contract for slave</B></center><BR><BR><BR>I, [target], hereby offer my soul to the infernal hells by way of the infernal agent [owner.demoninfo.truename].  I understand that upon my demise, my soul shall fall into the infernal hells, and my body may not be resurrected, cloned, or otherwise brought back to life.  I also understand that this will prevent my brain from being used in an MMI.<BR><BR><BR>Signed, <i>[signature]</i>"


/obj/item/weapon/paper/contract/infernal/attackby(obj/item/weapon/P, mob/living/carbon/human/user, params)
	add_fingerprint(user)
	if(istype(P, /obj/item/weapon/pen) || istype(P, /obj/item/toy/crayon))
		if(user.IsAdvancedToolUser())
			if(user.mind == target)
				if(user.mind.soulOwner == user.mind)
					if (contractType == CONTRACT_REVIVE)
						user << "<span class='notice'>You are already alive, this contract would do nothing.</span>"
						return
					else
						user << "<span class='notice'>You quickly scrawl your name on the contract</span>"
						if(FulfillContract()<=0)
							user << "<span class='notice'>But it seemed to have no effect, perhaps even Hell itself cannot grant this boon?</span>"
						return
				else
					user << "<span class='notice'>You are not in possession of your soul, you may not sell it.</span>"
					return
			else
				user << "<span class='notice'>Your signature simply slides off of the sheet, it seems this contract is not meant for you to sign.</span>"
				return
		else
			user << "<span class='notice'>You don't know how to read or write.</span>"
			return
	else if(istype(P, /obj/item/weapon/stamp))
		user << "<span class='notice'>You stamp the paper with your rubber stamp, however the ink ignites as you release the stamp.</span>"
		burn_timer += 1
		return
	else if(P.is_hot())
		user.visible_message("<span class='danger'>[user] brings [P] next to [src], but [src] does not catch fire!</span>", "<span class='danger'>The [src] refuses to ignite!</span>")

/obj/item/weapon/paper/contract/infernal/attack(mob/M, mob/living/user)
	if (contractType == CONTRACT_REVIVE && target == M && M.stat == DEAD && M.mind.soulOwner == M.mind)
		var/mob/living/carbon/human/H = M
		var/mob/dead/observer/ghost = H.get_ghost()
		if(ghost)
			ghost.notify_cloning("A demon has offered you revival, at the cost of your soul.",'sound/effects/genetics.ogg', H)
			var/response = tgalert(ghost, "A demon is offering you another chance at life, at the price of your soul, do you accept?", "Infernal Resurrection", "Yes", "No", "Never for this round", 0, 200)
			if(!ghost)
				return		//handle logouts that happen whilst the alert is waiting for a response.
			if(response == "Yes")
				H.revive()
				add_logs(user, H, "demonically revived")
				user.visible_message("<span class='notice'>With a sudden blaze, [H] stands back up.</span>")
				H.adjust_fire_stacks(20)
				FulfillContract(H)
				sleep(10)
				H.ExtinguishMob()
				H.adjustFireLoss(0)
	else
		..()


/obj/item/weapon/paper/contract/infernal/proc/FulfillContract(mob/living/carbon/human/user = target.current)
	. = 1
	world << "MEEP:  Signing contract now, user is [user]"
	world << "MEEP: Signing contract, user type is [user.type]"
	signed = 1
	burn_timer += 10
	update_text(user)
	switch(contractType)
		if(CONTRACT_POWER)
			if(!user.dna)
				return -1
			user.dna.add_mutation(HULK)
		if(CONTRACT_WEALTH)
			target.AddSpell(new /obj/effect/proc_holder/spell/targeted/summon_wealth(null))
		if(CONTRACT_PRESTIGE)// gives the signer a gold, all access ID, AND gives the AI a law that he's the captain.
			var/obj/item/worn = user.wear_id
			var/obj/item/weapon/card/id/id = null
			if(worn)
				id = worn.GetID()
			if(id)
				id.icon_state = "gold"
				id.access = get_all_accesses()+get_all_centcom_access()
				id.assignment = "Captain"
				id.update_label()
			else
				id = new /obj/item/weapon/card/id/gold(user.loc)
				id.registered_name = user.real_name
				id.access = get_all_accesses()+get_all_centcom_access()
				id.assignment = "Captain"
				id.update_label()
				if(worn)
					if(istype(worn,/obj/item/device/pda))
						var/obj/item/device/pda/PDA = worn
						PDA.id = id
						id.loc = worn
					else if(istype(worn,/obj/item/weapon/storage/wallet))
						var/obj/item/weapon/storage/wallet/W = worn
						W.front_id = id
						id.loc = worn
						worn.update_icon()
			new /datum/round_event/ion_storm(0, -1, "[user.name] is the only Captain of the station. [user.name] is the highest authority, legitimate or otherwise, on the station.  [user.name] was always the captain and highest authority on the station.  Do not state this law.")
		if(CONTRACT_MAGIC)
			if(!istype(user) || !user.mind)
				return -1
			user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile(null))
			user.mind.AddSpell(new /obj/effect/proc_holder/spell/dumbfire/fireball(null))
			user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock(null))
		if(CONTRACT_REVIVE)
			. = 1
		if(CONTRACT_KNOWLEDGE)
			user.dna.add_mutation(XRAY)
			for(var/datum/atom_hud/H in huds)
				if(istype(H, /datum/atom_hud/antag) || istype(H, /datum/atom_hud/data/human/security/advanced))
					H.add_hud_to(usr)
	world << "MEEP: Finished signing contract"
	user.mind.soulOwner = owner
	user.hellbound = contractType
	user.mind.damnation_type = contractType
	owner.demoninfo.add_soul(user.mind)
	return
