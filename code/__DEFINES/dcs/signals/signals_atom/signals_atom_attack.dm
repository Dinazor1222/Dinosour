// All signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of atom/attackby(): (/obj/item, /mob/living, params)
#define COMSIG_PARENT_ATTACKBY "atom_attackby"
/// From base of [atom/proc/attacby_secondary()]: (/obj/item/weapon, /mob/user, params)
#define COMSIG_PARENT_ATTACKBY_SECONDARY "atom_attackby_secondary"
/// From base of [/atom/proc/attack_hand_secondary]: (mob/user, list/modifiers) - Called when the atom receives a secondary unarmed attack.
#define COMSIG_ATOM_ATTACK_HAND_SECONDARY "atom_attack_hand_secondary"
///Return this in response if you don't want afterattack to be called
	#define COMPONENT_NO_AFTERATTACK (1<<0)
///from base of atom/attack_hulk(): (/mob/living/carbon/human)
#define COMSIG_ATOM_HULK_ATTACK "hulk_attack"
///from base of atom/animal_attack(): (/mob/user)
#define COMSIG_ATOM_ATTACK_ANIMAL "attack_animal"
//from base of atom/attack_basic_mob(): (/mob/user)
#define COMSIG_ATOM_ATTACK_BASIC_MOB "attack_basic_mob"
/// from /atom/proc/atom_break: ()
#define COMSIG_ATOM_BREAK "atom_break"
/// from base of [/atom/proc/atom_fix]: ()
#define COMSIG_ATOM_FIX "atom_fix"
///from base of [/atom/proc/update_integrity]: (old_value, new_value)
#define COMSIG_ATOM_INTEGRITY_CHANGED "atom_integrity_changed"
///from base of [/atom/proc/take_damage]: (damage_amount, damage_type, damage_flag, sound_effect, attack_dir, aurmor_penetration)
#define COMSIG_ATOM_TAKE_DAMAGE "atom_take_damage"
	/// Return bitflags for the above signal which prevents the atom taking any damage.
	#define COMPONENT_NO_TAKE_DAMAGE (1<<0)
///from [/datum/controller/subsystem/explosions/proc/explode]: (/list(/atom, devastation_range, heavy_impact_range, light_impact_range, flame_range, flash_range, adminlog, ignorecap, silent, smoke, explosion_cause))
#define COMSIG_ATOM_EXPLODE "atom_explode"
///from [/datum/controller/subsystem/explosions/proc/explode]: (/list(/atom, devastation_range, heavy_impact_range, light_impact_range, flame_range, flash_range, adminlog, ignorecap, silent, smoke, explosion_cause))
#define COMSIG_ATOM_INTERNAL_EXPLOSION "atom_internal_explosion"
///from [/datum/controller/subsystem/explosions/proc/explode]: (/list(/atom, devastation_range, heavy_impact_range, light_impact_range, flame_range, flash_range, adminlog, ignorecap, silent, smoke, explosion_cause))
#define COMSIG_AREA_INTERNAL_EXPLOSION "area_internal_explosion"
	/// When returned on a signal hooked to [COMSIG_ATOM_EXPLODE], [COMSIG_ATOM_INTERNAL_EXPLOSION], or [COMSIG_AREA_INTERNAL_EXPLOSION] it prevents the explosion from being propagated further.
	#define COMSIG_CANCEL_EXPLOSION (1<<0)
///from /obj/machinery/doppler_array/proc/sense_explosion(...): Runs when an explosion is succesfully detected by a doppler array(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
#define COMSIG_DOPPLER_ARRAY_EXPLOSION_DETECTED "atom_dopplerarray_explosion_detected"
/* Attack signals. They should share the returned flags, to standardize the attack chain. */
/// tool_act -> pre_attack -> target.attackby (item.attack) -> afterattack
	///Ends the attack chain. If sent early might cause posterior attacks not to happen.
	#define COMPONENT_CANCEL_ATTACK_CHAIN (1<<0)
	///Skips the specific attack step, continuing for the next one to happen.
	#define COMPONENT_SKIP_ATTACK (1<<1)
///from base of atom/attack_ghost(): (mob/dead/observer/ghost)
#define COMSIG_ATOM_ATTACK_GHOST "atom_attack_ghost"
///from base of atom/attack_hand(): (mob/user, list/modifiers)
#define COMSIG_ATOM_ATTACK_HAND "atom_attack_hand"
///from base of atom/attack_paw(): (mob/user)
#define COMSIG_ATOM_ATTACK_PAW "atom_attack_paw"
