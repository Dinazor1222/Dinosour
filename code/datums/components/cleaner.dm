GLOBAL_LIST_INIT_TYPED(cleaning_bubbles_lower, /mutable_appearance, list(generate_bubbles(GAME_PLANE, 0)))
GLOBAL_LIST_INIT_TYPED(cleaning_bubbles_higher, /mutable_appearance, list(generate_bubbles(ABOVE_GAME_PLANE, 0)))

/proc/generate_bubbles(plane, offset)
	return mutable_appearance('icons/effects/effects.dmi', "bubbles", layer = FLOOR_CLEAN_LAYER, plane = plane, offset_const = offset)

/**
 * Component that can be used to clean things.
 * Takes care of duration, cleaning skill and special cleaning interactions.
 * A callback can be set by the datum holding the cleaner to add custom functionality.
 * Soap uses a callback to decrease the amount of uses it has left after cleaning for example.
 */
/datum/component/cleaner
	/// The time it takes to clean something, without reductions from the cleaning skill modifier.
	var/base_cleaning_duration
	/// Offsets the cleaning duration modifier that you get from your cleaning skill, the duration won't be modified to be more than the base duration.
	var/skill_duration_modifier_offset
	/// Determines what this cleaner can wash off, [the available options are found here](code/__DEFINES/cleaning.html).
	var/cleaning_strength
	/// Gets called when something is successfully cleaned.
	var/datum/callback/on_cleaned_callback

/datum/component/cleaner/Initialize(
	base_cleaning_duration = 3 SECONDS,
	skill_duration_modifier_offset = 0,
	cleaning_strength = CLEAN_SCRUB,
	datum/callback/on_cleaned_callback = null,
)
	src.base_cleaning_duration = base_cleaning_duration
	src.skill_duration_modifier_offset = skill_duration_modifier_offset
	src.cleaning_strength = cleaning_strength
	src.on_cleaned_callback = on_cleaned_callback

/datum/component/cleaner/Destroy(force, silent)
	if(on_cleaned_callback)
		QDEL_NULL(on_cleaned_callback)
	return ..()

/datum/component/cleaner/RegisterWithParent()
	RegisterSignal(parent, COMSIG_START_CLEANING, .proc/on_start_cleaning)

/datum/component/cleaner/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_START_CLEANING)

/**
 * Handles the COMSIG_START_CLEANING signal by calling the clean proc.
 *
 * Arguments
 * * source the datum that sent the signal to start cleaning
 * * target the thing being cleaned
 * * user the person doing the cleaning
 * * clean_target set this to false if the target should not be washed and if experience should not be awarded to the user
 */
/datum/component/cleaner/proc/on_start_cleaning(datum/source, atom/target, mob/living/user, clean_target)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/clean, source, target, user, clean_target) //signal handlers can't have do_afters inside of them

/**
 * Cleans something using this cleaner.
 * The cleaning duration is modified by the cleaning skill of the user.
 * Successfully cleaning gives cleaning experience to the user and invokes the on_cleaned_callback.
 *
 * Arguments
 * * source the datum that sent the signal to start cleaning
 * * target the thing being cleaned
 * * user the person doing the cleaning
 * * clean_target set this to false if the target should not be washed and if experience should not be awarded to the user
 */
/datum/component/cleaner/proc/clean(datum/source, atom/target, mob/living/user, clean_target = TRUE)
	//add the cleaning overlay
	var/already_cleaning = HAS_TRAIT(target, CURRENTLY_CLEANING) //tracks if atom had the cleaning trait when you started cleaning
	if(!already_cleaning) //add the trait and overlay
		ADD_TRAIT(target, CURRENTLY_CLEANING, src)

		// We need to update our planes on overlay changes
		RegisterSignal(target, COMSIG_MOVABLE_Z_CHANGED, .proc/cleaning_target_moved)
		var/turf/target_turf = get_turf(target)
		var/offset = GET_TURF_PLANE_OFFSET(target_turf)
		var/mutable_appearance/low_bubble = GLOB.cleaning_bubbles_lower[offset + 1]
		var/mutable_appearance/high_bubble = GLOB.cleaning_bubbles_higher[offset + 1]
		if(target.plane > low_bubble.plane) //check if the higher overlay is necessary
			target.add_overlay(high_bubble)
		else if(target.plane == low_bubble.plane)
			if(target.layer > low_bubble.layer)
				target.add_overlay(high_bubble)
			else
				target.add_overlay(low_bubble)
		else //(target.plane < GLOB.cleaning_bubbles_lower.plane)
			target.add_overlay(low_bubble)

	//set the cleaning duration
	var/cleaning_duration = base_cleaning_duration
	if(user.mind) //higher cleaning skill can make the duration shorter
		//offsets the multiplier you get from cleaning skill, but doesn't allow the duration to be longer than the base duration
		cleaning_duration = cleaning_duration * min(user.mind.get_skill_modifier(/datum/skill/cleaning, SKILL_SPEED_MODIFIER)+skill_duration_modifier_offset,1)

	//do the cleaning
	user.visible_message(span_notice("[user] starts to clean [target]!"), span_notice("You start to clean [target]..."))
	if(do_after(user, cleaning_duration, target = target))
		user.visible_message(span_notice("[user] finishes cleaning [target]!"), span_notice("You finish cleaning [target]."))
		if(clean_target)
			if(isturf(target)) //cleaning the floor and every bit of filth on top of it
				for(var/obj/effect/decal/cleanable/cleanable_decal in target) //it's important to do this before you wash all of the cleanables off
					user.mind?.adjust_experience(/datum/skill/cleaning, round(cleanable_decal.beauty / CLEAN_SKILL_BEAUTY_ADJUSTMENT))
			else if(istype(target, /obj/structure/window)) //window cleaning
				target.set_opacity(initial(target.opacity))
				target.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
				var/obj/structure/window/window = target
				if(window.bloodied)
					for(var/obj/effect/decal/cleanable/blood/iter_blood in window)
						window.vis_contents -= iter_blood
						qdel(iter_blood)
						window.bloodied = FALSE
			user.mind?.adjust_experience(/datum/skill/cleaning, round(CLEAN_SKILL_GENERIC_WASH_XP))
			target.wash(cleaning_strength)
		on_cleaned_callback?.Invoke(source, target, user, clean_target)

	//remove the cleaning overlay
	if(!already_cleaning)
		var/turf/target_turf = get_turf(target)
		var/offset = GET_TURF_PLANE_OFFSET(target_turf)
		var/mutable_appearance/low_bubble = GLOB.cleaning_bubbles_lower[offset + 1]
		var/mutable_appearance/high_bubble = GLOB.cleaning_bubbles_higher[offset + 1]
		target.cut_overlay(low_bubble)
		target.cut_overlay(high_bubble)
		REMOVE_TRAIT(target, CURRENTLY_CLEANING, src)

/datum/component/cleaner/proc/cleaning_target_moved(atom/movable/source, turf/old_turf, turf/new_turf, same_z_layer)
	if(same_z_layer)
		return
	// First, get rid of the old overlay
	var/old_offset = GET_TURF_PLANE_OFFSET(old_turf)
	var/mutable_appearance/old_low_bubble = GLOB.cleaning_bubbles_lower[old_offset + 1]
	var/mutable_appearance/old_high_bubble = GLOB.cleaning_bubbles_higher[old_offset + 1]
	source.cut_overlay(old_low_bubble)
	source.cut_overlay(old_high_bubble)

	// Now, add the new one
	var/new_offset = GET_TURF_PLANE_OFFSET(new_turf)
	var/mutable_appearance/new_low_bubble = GLOB.cleaning_bubbles_lower[new_offset + 1]
	var/mutable_appearance/new_high_bubble = GLOB.cleaning_bubbles_higher[new_offset + 1]
	source.add_overlay(new_low_bubble)
	source.add_overlay(new_high_bubble)
