/datum/status_effect/revenant_revealed
	id = "revenant_revealed"

/datum/status_effect/revenant_revealed/on_apply()
	. = ..()
	if(!.)
		return FALSE
	owner.orbiting?.end_orbit(src)

	ADD_TRAIT(owner, TRAIT_REVENANT_REVEALED, TRAIT_STATUS_EFFECT(id))
	owner.invisibility = 0
	owner.incorporeal_move = FALSE
	owner.update_appearance(UPDATE_ICON)

	owner.balloon_alert(owner, "revealed!")


/datum/status_effect/revenant_revealed/on_remove()
	REMOVE_TRAIT(owner, TRAIT_REVENANT_REVEALED, TRAIT_STATUS_EFFECT(id))

	owner.incorporeal_move = INCORPOREAL_MOVE_JAUNT
	owner.invisibility = INVISIBILITY_REVENANT
	owner.update_appearance(UPDATE_ICON)

	owner.balloon_alert(owner, "concealed")
	return ..()

/datum/status_effect/incapacitating/paralyzed/revenant
	id = "revenant_paralyzed"

/datum/status_effect/incapacitating/paralyzed/revenant/on_apply()
	. = ..()
	if(!.)
		return FALSE
	owner.orbiting?.end_orbit(src)

	ADD_TRAIT(owner, TRAIT_NO_TRANSFORM, TRAIT_STATUS_EFFECT(id))
	owner.balloon_alert(owner, "can't move!")
	owner.update_appearance(UPDATE_ICON)

/datum/status_effect/incapacitating/paralyzed/revenant/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NO_TRANSFORM, TRAIT_STATUS_EFFECT(id))
	owner.balloon_alert(owner, "can move again")

	return ..()
