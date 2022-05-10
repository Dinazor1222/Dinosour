/obj/projectile/beam/mindflayer
	name = "flayer ray"

/obj/projectile/beam/mindflayer/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/human_hit = target
		human_hit.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20)
		human_hit.adjust_timed_status_effect(60 SECONDS, /datum/status_effect/hallucination)
