#define HEAL_EFFECT_COOLDOWN (1 SECONDS)

/// Applies healing to those in the area.
/// Will provide them with an alert while they're in range, as well as
/// give them a healing particle.
/// Can be applied to those only with a trait conditionally.
/datum/component/aura_healing
	/// The range of which to heal
	var/range = 5

	/// Whether or not you must be a visible object of the parent
	var/requires_visibility = TRUE

	/// Brute damage to heal over a second
	var/brute_heal = 0

	/// Burn damage to heal over a second
	var/burn_heal = 0

	/// Toxin damage to heal over a second
	var/toxin_heal = 0

	/// Suffocation damage to heal over a second
	var/suffocation_heal = 0

	/// Stamina damage to heal over a second
	var/stamina_heal = 0

	/// Amount of blood to heal over a second
	var/blood_heal = 0

	/// Map of organ (such as ORGAN_SLOT_BRAIN) to damage heal over a second
	var/list/organ_healing = null

	/// Amount of damage to heal on simple mobs over a second
	var/simple_heal = 0

	/// Trait to limit healing to, if set
	var/limit_to_trait = null

	/// The color to give the healing visual
	var/healing_color = COLOR_GREEN

	/// A list of being healed to active alerts
	var/list/datum/weakref/current_alerts = list()

	/// Cooldown between showing the heal effect
	COOLDOWN_DECLARE(last_heal_effect_time)

/datum/component/aura_healing/Initialize(
	range = 5,
	requires_visibility = TRUE,
	brute_heal = 0,
	burn_heal = 0,
	toxin_heal = 0,
	suffocation_heal = 0,
	stamina_heal = 0,
	blood_heal = 0,
	organ_healing = null,
	simple_heal = 0,
	limit_to_trait = null,
	healing_color = COLOR_GREEN,
)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	START_PROCESSING(SSaura, src)

	src.range = range
	src.requires_visibility = requires_visibility
	src.brute_heal = brute_heal
	src.burn_heal = burn_heal
	src.toxin_heal = toxin_heal
	src.suffocation_heal = suffocation_heal
	src.stamina_heal = stamina_heal
	src.blood_heal = blood_heal
	src.organ_healing = organ_healing
	src.simple_heal = simple_heal
	src.limit_to_trait = limit_to_trait
	src.healing_color = healing_color

/datum/component/aura_healing/Destroy(force)
	STOP_PROCESSING(SSaura, src)
	var/alert_category = "aura_healing_[REF(src)]"

	for(var/datum/weakref/alert_holder in current_alerts)
		var/mob/alert_holder_real = alert_holder.resolve()
		alert_holder_real?.clear_alert(alert_category)
	current_alerts.Cut()

	return ..()

/datum/component/aura_healing/process(seconds_per_tick)
	var/should_show_effect = COOLDOWN_FINISHED(src, last_heal_effect_time)
	if (should_show_effect)
		COOLDOWN_START(src, last_heal_effect_time, HEAL_EFFECT_COOLDOWN)

	var/list/remove_alerts_from = current_alerts.Copy()
	var/list/to_heal = list()
	var/alert_category = "aura_healing_[REF(src)]"

	if(requires_visibility)
		for(var/mob/living/candidate in view(range, parent))
			to_heal += candidate
	else
		for(var/mob/living/candidate in range(range, parent))
			to_heal += candidate

	for (var/mob/living/candidate as anything in to_heal)
		if (!isnull(limit_to_trait) && !HAS_TRAIT(candidate, limit_to_trait))
			continue

		var/candi_ref = WEAKREF(candidate)
		remove_alerts_from -= candi_ref
		if (!current_alerts[candi_ref])
			var/atom/movable/screen/alert/aura_healing/alert = candidate.throw_alert(alert_category, /atom/movable/screen/alert/aura_healing, new_master = parent)
			alert.desc = "You are being healed by [parent]."
			current_alerts[candi_ref] = TRUE

		if (should_show_effect && candidate.health < candidate.maxHealth)
			new /obj/effect/temp_visual/heal(get_turf(candidate), healing_color)

		if (iscarbon(candidate) || issilicon(candidate) || isbasicmob(candidate))
			candidate.adjustBruteLoss(-brute_heal * seconds_per_tick, updating_health = FALSE)
			candidate.adjustFireLoss(-burn_heal * seconds_per_tick, updating_health = FALSE)

		if (iscarbon(candidate))
			// Toxin healing is forced for slime people
			candidate.adjustToxLoss(-toxin_heal * seconds_per_tick, updating_health = FALSE, forced = TRUE)

			candidate.adjustOxyLoss(-suffocation_heal * seconds_per_tick, updating_health = FALSE)
			candidate.adjustStaminaLoss(-stamina_heal * seconds_per_tick, updating_stamina = FALSE)

			for (var/organ in organ_healing)
				candidate.adjustOrganLoss(organ, -organ_healing[organ] * seconds_per_tick)
		else if (isanimal(candidate))
			var/mob/living/simple_animal/animal_candidate = candidate
			animal_candidate.adjustHealth(-simple_heal * seconds_per_tick, updating_health = FALSE)
		else if (isbasicmob(candidate))
			var/mob/living/basic/basic_candidate = candidate
			basic_candidate.adjust_health(-simple_heal * seconds_per_tick, updating_health = FALSE)

		if (candidate.blood_volume < BLOOD_VOLUME_NORMAL)
			candidate.blood_volume += blood_heal * seconds_per_tick

		candidate.updatehealth()

	for (var/datum/weakref/remove_alert_from in remove_alerts_from)
		var/mob/living/remove_alert_from_real = remove_alert_from.resolve()
		remove_alert_from_real?.clear_alert(alert_category)
	current_alerts -= remove_alerts_from

/atom/movable/screen/alert/aura_healing
	name = "Aura Healing"
	icon_state = "template"

#undef HEAL_EFFECT_COOLDOWN
