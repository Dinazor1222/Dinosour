/datum/component/riding
	var/last_vehicle_move = 0 //used for move delays
	var/last_move_diagonal = FALSE
	var/vehicle_move_delay = 2 //tick delay between movements, lower = faster, higher = slower
	var/keytype

	var/slowed = FALSE
	var/slowvalue = 1

	///Bool to check if you gain the ridden mob's abilities.
	var/can_use_abilities = FALSE

	var/list/riding_offsets = list()	//position_of_user = list(dir = list(px, py)), or RIDING_OFFSET_ALL for a generic one.
	var/list/directional_vehicle_layers = list()	//["[DIRECTION]"] = layer. Don't set it for a direction for default, set a direction to null for no change.
	var/list/directional_vehicle_offsets = list()	//same as above but instead of layer you have a list(px, py)
	var/list/allowed_turf_typecache
	var/list/forbid_turf_typecache					//allow typecache for only certain turfs, forbid to allow all but those. allow only certain turfs will take precedence.
	var/allow_one_away_from_valid_turf = TRUE		//allow moving one tile away from a valid turf but not more.
	var/override_allow_spacemove = FALSE
	var/drive_verb = "drive"
	/// If we should delete this component when we have nothing left buckled, used for buckling to mobs
	var/del_on_unbuckle_all = FALSE

	/// If the rider needs hands free in order to not fall off (fails if they're incap'd or restrained)
	var/rider_holding_on = FALSE
	/// If the ridden needs a hand free to carry the rider (fails if they're incap'd or restrained)
	var/ridden_holding_rider = FALSE



	/// If the "vehicle" is a mob, respect MOBILITY_MOVE on said mob.
	var/respect_mob_mobility = TRUE


/datum/component/riding/Initialize(riding_flags, mob/living/riding_mob)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, .proc/vehicle_turned)
	RegisterSignal(parent, COMSIG_MOVABLE_BUCKLE, .proc/vehicle_mob_buckle)
	RegisterSignal(parent, COMSIG_MOVABLE_UNBUCKLE, .proc/vehicle_mob_unbuckle)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/vehicle_moved)

	var/atom/movable/parent_movable = parent
	rider_holding_on = (riding_flags & RIDING_RIDER_HOLDING_ON)
	ridden_holding_rider = (riding_flags & RIDING_RIDDEN_HOLD_RIDER)

	if(!riding_mob)
		return

	if(parent_movable.has_buckled_mobs() && ((riding_mob in parent_movable.buckled_mobs) || parent_movable.buckled_mobs.len >= parent_movable.max_buckled_mobs))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/parent_living = parent
	if(isliving(parent_living) && parent_living.buckled)
		testing("already has a thing buckled? thing: [parent_living.buckled]")
		return COMPONENT_INCOMPATIBLE

	var/mob/living/carbon/human/human_parent = parent // likely should be somewhere else
	if(ishuman(human_parent) && !is_type_in_typecache(riding_mob, human_parent.can_ride_typecache))
		riding_mob.visible_message("<span class='warning'>[riding_mob] really can't seem to mount [parent_movable]...</span>")
		return COMPONENT_INCOMPATIBLE

	// need to see if !equip_buckle_inhands() checks are enough to skip any needed incapac/restrain checks

	// ridden_holding_rider shouldn't apply if the ridden isn't even a living mob
	if(ridden_holding_rider && (!isliving(parent_living) || !equip_buckle_inhands(parent_living, 1, riding_mob))) // hardcode 1 hand for now
		parent_living.visible_message("<span class='warning'>[parent_living] can't get a grip on [riding_mob] because [parent_living.p_their()] hands are full!</span>",
			"<span class='warning'>You can't get a grip on [riding_mob] because your hands are full!</span>")
		return COMPONENT_INCOMPATIBLE // is this okay to use as a conditional fail rather than a categorical "you can't use that on this"?

	if(rider_holding_on && !equip_buckle_inhands(riding_mob, 2)) // hardcode 2 hands for now
		riding_mob.visible_message("<span class='warning'>[riding_mob] can't get a grip on [parent_movable] because [riding_mob.p_their()] hands are full!</span>",
			"<span class='warning'>You can't get a grip on [parent_movable] because your hands are full!</span>")
		return COMPONENT_INCOMPATIBLE


/datum/component/riding/proc/vehicle_mob_unbuckle(datum/source, mob/living/rider, force = FALSE)
	SIGNAL_HANDLER

	var/atom/movable/movable_parent = parent
	remove_abilities(rider)
	restore_position(rider)
	unequip_buckle_inhands(rider)
	rider.updating_glide_size = TRUE
	if(del_on_unbuckle_all && !movable_parent.has_buckled_mobs())
		qdel(src)

/datum/component/riding/proc/vehicle_mob_buckle(datum/source, mob/living/M, force = FALSE)
	SIGNAL_HANDLER

	var/atom/movable/movable_parent = parent
	M.set_glide_size(movable_parent.glide_size)
	M.updating_glide_size = FALSE
	handle_vehicle_offsets(movable_parent.dir)
	if(can_use_abilities)
		setup_abilities(M)

///Gives the rider the riding parent's abilities
/datum/component/riding/proc/setup_abilities(mob/living/M)

	if(!istype(parent, /mob/living))
		return

	var/mob/living/ridden_creature = parent

	for(var/i in ridden_creature.abilities)
		var/obj/effect/proc_holder/proc_holder = i
		M.AddAbility(proc_holder)

///Takes away the riding parent's abilities from the rider
/datum/component/riding/proc/remove_abilities(mob/living/M)

	if(!istype(parent, /mob/living))
		return

	var/mob/living/ridden_creature = parent

	for(var/i in ridden_creature.abilities)
		var/obj/effect/proc_holder/proc_holder = i
		M.RemoveAbility(proc_holder)

/datum/component/riding/proc/handle_vehicle_layer(dir)
	var/atom/movable/AM = parent
	var/static/list/defaults = list(TEXT_NORTH = OBJ_LAYER, TEXT_SOUTH = ABOVE_MOB_LAYER, TEXT_EAST = ABOVE_MOB_LAYER, TEXT_WEST = ABOVE_MOB_LAYER)
	. = defaults["[dir]"]
	if(directional_vehicle_layers["[dir]"])
		. = directional_vehicle_layers["[dir]"]
	if(isnull(.))	//you can set it to null to not change it.
		. = AM.layer
	AM.layer = .

/datum/component/riding/proc/set_vehicle_dir_layer(dir, layer)
	directional_vehicle_layers["[dir]"] = layer

/datum/component/riding/proc/vehicle_moved(datum/source, dir)
	SIGNAL_HANDLER

	var/atom/movable/movable_parent = parent
	if (isnull(dir))
		dir = movable_parent.dir
	movable_parent.set_glide_size(DELAY_TO_GLIDE_SIZE(vehicle_move_delay))
	for (var/m in movable_parent.buckled_mobs)
		var/mob/buckled_mob = m
		ride_check(buckled_mob)
		buckled_mob.set_glide_size(movable_parent.glide_size)
	handle_vehicle_offsets(dir)
	handle_vehicle_layer(dir)

/datum/component/riding/proc/vehicle_turned(datum/source, _old_dir, new_dir)
	SIGNAL_HANDLER

	vehicle_moved(source, new_dir)

/datum/component/riding/proc/ride_check(mob/living/rider)
	var/atom/movable/parent_movable = parent
	var/kick_us_off

	if(rider_holding_on && (HAS_TRAIT(rider, TRAIT_RESTRAINED) || rider.incapacitated(TRUE, TRUE)))
		kick_us_off = TRUE
	else if(ridden_holding_rider && isliving(parent_movable))
		var/mob/living/parent_living = parent_movable
		if(HAS_TRAIT(parent_living, TRAIT_RESTRAINED) || parent_living.incapacitated(TRUE, TRUE))
			kick_us_off = TRUE
	else if(isliving(parent_movable)) // adding a check for standing to the ridden for all carries pending someone explaining why laying down should let you keep riding
		var/mob/living/parent_living = parent_movable
		if(parent_living.body_position != STANDING_UP)
			kick_us_off = TRUE

	if(!kick_us_off)
		return TRUE

	rider.visible_message("<span class='warning'>[rider] falls off of [parent_movable]!</span>", \
					"<span class='warning'>You fall off of [parent_movable]!</span>")
	parent_movable.unbuckle_mob(rider)


/datum/component/riding/proc/force_dismount(mob/living/rider, gentle = FALSE)
	var/atom/movable/parent_movable = parent
	parent_movable.unbuckle_mob(rider)

	if(!isanimal(parent_movable) && !iscyborg(parent_movable))
		return

	var/turf/target = get_edge_target_turf(parent_movable, parent_movable.dir)
	var/turf/targetm = get_step(get_turf(parent_movable), parent_movable.dir)
	rider.Move(targetm)
	if(gentle)
		rider.visible_message("<span class='warning'>[rider] is thrown clear of [parent_movable]!</span>", \
		"<span class='warning'>You're thrown clear of [parent_movable]!</span>")
		rider.throw_at(target, 8, 3, parent_movable, gentle = TRUE)
	else
		rider.visible_message("<span class='warning'>[rider] is thrown violently from [parent_movable]!</span>", \
		"<span class='warning'>You're thrown violently from [parent_movable]!</span>")
		rider.throw_at(target, 14, 5, parent_movable, gentle = FALSE)
	rider.Knockdown(3 SECONDS)

/datum/component/riding/proc/handle_vehicle_offsets(dir)
	var/atom/movable/AM = parent
	var/AM_dir = "[dir]"
	var/passindex = 0
	if(AM.has_buckled_mobs())
		for(var/m in AM.buckled_mobs)
			passindex++
			var/mob/living/buckled_mob = m
			var/list/offsets = get_offsets(passindex)
			buckled_mob.setDir(dir)
			dir_loop:
				for(var/offsetdir in offsets)
					if(offsetdir == AM_dir)
						var/list/diroffsets = offsets[offsetdir]
						buckled_mob.pixel_x = diroffsets[1]
						if(diroffsets.len >= 2)
							buckled_mob.pixel_y = diroffsets[2]
						if(diroffsets.len == 3)
							buckled_mob.layer = diroffsets[3]
						break dir_loop
	var/list/static/default_vehicle_pixel_offsets = list(TEXT_NORTH = list(0, 0), TEXT_SOUTH = list(0, 0), TEXT_EAST = list(0, 0), TEXT_WEST = list(0, 0))
	var/px = default_vehicle_pixel_offsets[AM_dir]
	var/py = default_vehicle_pixel_offsets[AM_dir]
	if(directional_vehicle_offsets[AM_dir])
		if(isnull(directional_vehicle_offsets[AM_dir]))
			px = AM.pixel_x
			py = AM.pixel_y
		else
			px = directional_vehicle_offsets[AM_dir][1]
			py = directional_vehicle_offsets[AM_dir][2]
	AM.pixel_x = px
	AM.pixel_y = py

/datum/component/riding/proc/set_vehicle_dir_offsets(dir, x, y)
	directional_vehicle_offsets["[dir]"] = list(x, y)

//Override this to set your vehicle's various pixel offsets
/datum/component/riding/proc/get_offsets(pass_index) // list(dir = x, y, layer)
	. = list(TEXT_NORTH = list(0, 0), TEXT_SOUTH = list(0, 0), TEXT_EAST = list(0, 0), TEXT_WEST = list(0, 0))
	if(riding_offsets["[pass_index]"])
		. = riding_offsets["[pass_index]"]
	else if(riding_offsets["[RIDING_OFFSET_ALL]"])
		. = riding_offsets["[RIDING_OFFSET_ALL]"]

/datum/component/riding/proc/set_riding_offsets(index, list/offsets)
	if(!islist(offsets))
		return FALSE
	riding_offsets["[index]"] = offsets

//KEYS
/datum/component/riding/proc/keycheck(mob/user)
	return !keytype || user.is_holding_item_of_type(keytype)

//BUCKLE HOOKS
/datum/component/riding/proc/restore_position(mob/living/buckled_mob)
	if(buckled_mob)
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
		if(buckled_mob.client)
			buckled_mob.client.view_size.resetToDefault()

//MOVEMENT
/datum/component/riding/proc/turf_check(turf/next, turf/current)
	if(allowed_turf_typecache && !allowed_turf_typecache[next.type])
		return (allow_one_away_from_valid_turf && allowed_turf_typecache[current.type])
	else if(forbid_turf_typecache && forbid_turf_typecache[next.type])
		return (allow_one_away_from_valid_turf && !forbid_turf_typecache[current.type])
	return TRUE

/datum/component/riding/proc/handle_ride(mob/user, direction)
	var/atom/movable/AM = parent
	if(user.incapacitated())
		Unbuckle(user)
		return

	if(world.time < last_vehicle_move + ((last_move_diagonal? 2 : 1) * vehicle_move_delay))
		return
	last_vehicle_move = world.time

	if(keycheck(user))
		var/turf/next = get_step(AM, direction)
		var/turf/current = get_turf(AM)
		if(!istype(next) || !istype(current))
			return	//not happening.
		if(!turf_check(next, current))
			to_chat(user, "<span class='warning'>Your \the [AM] can not go onto [next]!</span>")
			return
		if(!Process_Spacemove(direction) || !isturf(AM.loc))
			return
		if(isliving(AM) && respect_mob_mobility)
			var/mob/living/M = AM
			if(!(M.mobility_flags & MOBILITY_MOVE))
				return
		step(AM, direction)

		if((direction & (direction - 1)) && (AM.loc == next))		//moved diagonally
			last_move_diagonal = TRUE
		else
			last_move_diagonal = FALSE

		handle_vehicle_layer(AM.dir)
		handle_vehicle_offsets(AM.dir)
	else
		to_chat(user, "<span class='warning'>You'll need a special item in one of your hands to [drive_verb] [AM].</span>")

/datum/component/riding/proc/Unbuckle(atom/movable/M)
	addtimer(CALLBACK(parent, /atom/movable/.proc/unbuckle_mob, M), 0, TIMER_UNIQUE)

/datum/component/riding/proc/Process_Spacemove(direction)
	var/atom/movable/AM = parent
	return override_allow_spacemove || AM.has_gravity()

/datum/component/riding/proc/account_limbs(mob/living/M)
	if(M.usable_legs < 2 && !slowed)
		vehicle_move_delay = vehicle_move_delay + slowvalue
		slowed = TRUE
	else if(slowed)
		vehicle_move_delay = vehicle_move_delay - slowvalue
		slowed = FALSE

///////Yes, I said humans. No, this won't end well...//////////



/datum/component/riding/human
	/// Is the parent fireman carrying the cargo, or is the cargo riding along on the parent?
	var/carry_mode
	del_on_unbuckle_all = TRUE



/datum/component/riding/human/Initialize(riding_flags, mob/living/riding_mob)
	. = ..()
	RegisterSignal(parent, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, .proc/on_host_unarmed_melee)

/datum/component/riding/human/vehicle_mob_unbuckle(datum/source, mob/living/M, force = FALSE)
	unequip_buckle_inhands(parent)
	var/mob/living/carbon/human/H = parent
	H.remove_movespeed_modifier(/datum/movespeed_modifier/human_carry)
	. = ..()

/datum/component/riding/human/vehicle_mob_buckle(datum/source, mob/living/M, force = FALSE)
	. = ..()
	var/mob/living/carbon/human/H = parent
	H.add_movespeed_modifier(/datum/movespeed_modifier/human_carry)

/datum/component/riding/human/proc/on_host_unarmed_melee(atom/target)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/H = parent
	if(H.a_intent == INTENT_DISARM && (target in H.buckled_mobs))
		force_dismount(target)

/datum/component/riding/human/handle_vehicle_layer(dir)
	var/atom/movable/AM = parent
	if(!AM.buckled_mobs || !AM.buckled_mobs.len)
		AM.layer = MOB_LAYER
		return

	for(var/mob/M in AM.buckled_mobs) //ensure proper layering of piggyback and carry, sometimes weird offsets get applied
		M.layer = MOB_LAYER
	if(!AM.buckle_lying)
		if(dir == SOUTH)
			AM.layer = ABOVE_MOB_LAYER
		else
			AM.layer = OBJ_LAYER
	else
		if(dir == NORTH)
			AM.layer = OBJ_LAYER
		else
			AM.layer = ABOVE_MOB_LAYER


/datum/component/riding/human/get_offsets(pass_index)
	var/mob/living/carbon/human/H = parent
	if(H.buckle_lying)
		return list(TEXT_NORTH = list(0, 6), TEXT_SOUTH = list(0, 6), TEXT_EAST = list(0, 6), TEXT_WEST = list(0, 6))
	else
		return list(TEXT_NORTH = list(0, 6), TEXT_SOUTH = list(0, 6), TEXT_EAST = list(-6, 4), TEXT_WEST = list( 6, 4))


/datum/component/riding/human/force_dismount(mob/living/user)
	var/atom/movable/AM = parent
	AM.unbuckle_mob(user)
	user.Paralyze(60)
	user.visible_message("<span class='warning'>[AM] pushes [user] off of [AM.p_them()]!</span>", \
						"<span class='warning'>[AM] pushes you off of [AM.p_them()]!</span>")

/datum/component/riding/cyborg
	del_on_unbuckle_all = TRUE

/datum/component/riding/cyborg/ride_check(mob/user)
	var/atom/movable/AM = parent
	if(user.incapacitated())
		var/kick = TRUE
		if(iscyborg(AM))
			var/mob/living/silicon/robot/R = AM
			if(R.module && R.module.ride_allow_incapacitated)
				kick = FALSE
		if(kick)
			to_chat(user, "<span class='userdanger'>You fall off of [AM]!</span>")
			Unbuckle(user)
			return
	if(iscarbon(user))
		var/mob/living/carbon/carbonuser = user
		if(!carbonuser.usable_hands)
			Unbuckle(user)
			to_chat(user, "<span class='warning'>You can't grab onto [AM] with no hands!</span>")
			return

/datum/component/riding/cyborg/handle_vehicle_layer(dir)
	var/atom/movable/AM = parent
	if(AM.buckled_mobs && AM.buckled_mobs.len)
		if(dir == SOUTH)
			AM.layer = ABOVE_MOB_LAYER
		else
			AM.layer = OBJ_LAYER
	else
		AM.layer = MOB_LAYER

/datum/component/riding/cyborg/get_offsets(pass_index) // list(dir = x, y, layer)
	return list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(-6, 3), TEXT_WEST = list( 6, 3))

/datum/component/riding/cyborg/handle_vehicle_offsets(dir)
	var/atom/movable/AM = parent
	if(AM.has_buckled_mobs())
		for(var/mob/living/M in AM.buckled_mobs)
			M.setDir(dir)
			if(iscyborg(AM))
				var/mob/living/silicon/robot/R = AM
				if(istype(R.module))
					M.pixel_x = R.module.ride_offset_x[dir2text(dir)]
					M.pixel_y = R.module.ride_offset_y[dir2text(dir)]
			else
				..()

/datum/component/riding/proc/equip_buckle_inhands(mob/living/carbon/human/user, amount_required = 1, riding_target_override = null)
	var/atom/movable/AM = parent
	var/amount_equipped = 0
	testing(" start equip - needed [amount_required]")
	for(var/amount_needed = amount_required, amount_needed > 0, amount_needed--)
		var/obj/item/riding_offhand/inhand = new /obj/item/riding_offhand(user)
		if(!riding_target_override)
			inhand.rider = user
		else
			inhand.rider = riding_target_override
		inhand.parent = AM
		for(var/obj/item/I in user.held_items) // delete any hand items like slappers that could still totally be used to grab on
			if((I.obj_flags & HAND_ITEM))
				qdel(I)
		if(user.put_in_hands(inhand, TRUE))
			amount_equipped++
			testing("equipped: [amount_equipped] | needed [amount_required]")
		else
			break

	if(amount_equipped >= amount_required)
		testing("had enough, true")
		return TRUE
	else
		testing("not enough, false")
		unequip_buckle_inhands(user)
		return FALSE

/datum/component/riding/proc/unequip_buckle_inhands(mob/living/carbon/user)
	var/atom/movable/AM = parent
	for(var/obj/item/riding_offhand/O in user.contents)
		if(O.parent != AM)
			CRASH("RIDING OFFHAND ON WRONG MOB")
		if(O.selfdeleting)
			continue
		else
			qdel(O)
	return TRUE

/obj/item/riding_offhand
	name = "offhand"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "offhand"
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ABSTRACT | DROPDEL | NOBLUDGEON
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/mob/living/carbon/rider
	var/mob/living/parent
	var/selfdeleting = FALSE

/obj/item/riding_offhand/dropped()
	selfdeleting = TRUE
	. = ..()

/obj/item/riding_offhand/equipped()
	if(loc != rider && loc != parent)
		selfdeleting = TRUE
		qdel(src)
	. = ..()

/obj/item/riding_offhand/Destroy()
	var/atom/movable/AM = parent
	if(selfdeleting)
		if(rider in AM.buckled_mobs)
			AM.unbuckle_mob(rider)
	. = ..()

/obj/item/riding_offhand/on_thrown(mob/living/carbon/user, atom/target)
	if(rider == user)
		return //Piggyback user.
	user.unbuckle_mob(rider)
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='notice'>You gently let go of [rider].</span>")
		return
	return rider
