/obj/vehicle/ridden/pioneer_stone
	name = "pioneer stone"
	desc = "Pioneer's used to ride these babies for miles"
	icon_state = "pioneer_stone"
	max_integrity = 500
	armor = list("melee" = 75, "bullet" = 0, "laser" = 25, "energy" = 25, "bomb" = -75, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100) //it is a fucking stone, what do you expect
	are_legs_exposed = TRUE
	var/max_damage_force = 25
	
	fall_off_if_missing_arms = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/vehicle/ridden/pioneer_stone/Initialize()
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))
	D.vehicle_move_delay = 2

/obj/vehicle/ridden/pioneer_stone/proc/Change_move_delay()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	var/T = get_turf(src)
	if(is_mining_level(T.z))//pioneer stone works best on lavaland
		D.vehicle_move_delay = 1
	else
		D.vehicle_move_delay = 2

/obj/vehicle/ridden/pioneer_stone/Moved()
	playsound(src, 'sound/effects/clang.ogg', 25, TRUE)
	Change_move_delay()
	. = ..()
	


/obj/vehicle/ridden/pioneer_stone/Bump(atom/movable/A)
	. = ..()
	var/T = get_turf(src)
	if(!(A.density && has_buckled_mobs())||(!ishuman(A)))
		return FALSE
	var/atom/throw_target = get_edge_target_turf(A, dir)
	var/mob/living/carbon/human/H = A
	var/damage_force = rand(10,max_damage_force)
	H.apply_damage(damage_force, BRUTE)
	obj_integrity -= damage_force * is_mining_level(T.z)
	if(obj_integrity <= 0)
		Destroy()
	if(damage_force == max_damage_force)
		H.Paralyze(100)
		H.adjustStaminaLoss(60)
		H.throw_at(throw_target, 3, 2)
		visible_message("<span class='danger'>[src] slams with full force into [H]!</span>")
		playsound(src, 'sound/effects/bang.ogg', 100, TRUE)

	else
		H.Paralyze(50)
		H.adjustStaminaLoss(30)
		H.throw_at(throw_target, 2, 1)
		visible_message("<span class='danger'>[src] slams into [H]!</span>")
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)

/obj/vehicle/ridden/pioneer_stone/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()
