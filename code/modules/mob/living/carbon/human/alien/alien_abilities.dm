/**
 * DRONE EVOLUTION ABILITY
 */
/obj/effect/proc_holder/alien/evolve
	name = "Evolve to Praetorian"
	desc = "Praetorian"
	plasma_cost = 500

	action_icon_state = "alien_evolve_drone"

/obj/effect/proc_holder/alien/evolve/fire(mob/living/carbon/human/species/alien/user)
	var/obj/item/organ/alien/hivenode/node = user.getorgan(/obj/item/organ/alien/hivenode)
	if(!node) //Players are Murphy's Law. We may not expect there to ever be a living xeno with no hivenode, but they _WILL_ make it happen.
		to_chat(user, span_danger("Without the hivemind, you can't possibly hold the responsibility of leadership!"))
		return FALSE
	if(node.recent_queen_death)
		to_chat(user, span_danger("Your thoughts are still too scattered to take up the position of leadership."))
		return FALSE

	if(!isturf(user.loc))
		to_chat(user, span_warning("You can't evolve here!"))
		return FALSE
	if(!get_alien_type(/mob/living/carbon/human/species/alien/royal))
		var/mob/living/carbon/human/species/alien/royal/praetorian/new_xeno = new (user.loc)
		user.alien_evolve(new_xeno)
		return TRUE
	else
		to_chat(user, span_warning("We already have a living royal!"))
		return FALSE
