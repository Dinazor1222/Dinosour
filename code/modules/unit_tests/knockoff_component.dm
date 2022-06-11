/// Helper to reset the glasses dummy (wears_the_glasses) back to it's original position, clear knockdown, and return glasses (if gone)
#define SET_GLASSES_WEARER \
	wears_the_glasses.forceMove(right_of_shover); \
	wears_the_glasses.SetKnockdown(0); \
	if(!wears_the_glasses.glasses){ wears_the_glasses.equip_to_slot(glasses, ITEM_SLOT_EYES); }

/// Test that the knockoff component will properly cause something
/// with it applied to be knocked off when it should be.
/datum/unit_test/knockoff_component

/datum/unit_test/knockoff_component/Run()
	var/mob/living/carbon/human/wears_the_glasses = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/shoves_the_guy = allocate(/mob/living/carbon/human)

	// No pre-existing items have a 100% chance of being knocked off,
	// so we'll just apply it to a relatively generic item (glasses)
	var/obj/item/clothing/glasses/sunglasses/glasses = allocate(/obj/item/clothing/glasses/sunglasses)
	glasses.AddComponent(/datum/component/knockoff, \
		knockoff_chance = 100, \
		target_zones = list(BODY_ZONE_PRECISE_EYES), \
		slots_knockoffable = glasses.slot_flags)

	// Save this for later, since we wanna reset our dummy positions even after they're shoved about.
	var/turf/right_of_shover = locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)

	// Position shover (bottom left) and the shovee (1 tile right of bottom left, no wall behind them)
	shoves_the_guy.forceMove(run_loc_floor_bottom_left)
	SET_GLASSES_WEARER

	TEST_ASSERT(wears_the_glasses.glasses == glasses, "Dummy failed to equip the glasses.")

	// Test disarm, targeting chest
	// A disarm targeting chest should not knockdown or lose glasses
	shoves_the_guy.zone_selected = BODY_ZONE_CHEST
	shoves_the_guy.disarm(wears_the_glasses)
	TEST_ASSERT(!wears_the_glasses.IsKnockdown(), "Dummy was knocked down when being disarmed shouldn't have been.")
	TEST_ASSERT(wears_the_glasses.glasses == glasses, "Dummy lost their glasses even thought they were disarmed targeting the wrong slot.")

	SET_GLASSES_WEARER

	// Test disarm, targeting eyes
	// A disarm targeting eyes should not knockdown but should lose glasses
	shoves_the_guy.zone_selected = BODY_ZONE_PRECISE_EYES
	shoves_the_guy.disarm(wears_the_glasses)
	TEST_ASSERT(!wears_the_glasses.IsKnockdown(), "Dummy was knocked down when being disarmed shouldn't have been.")
	TEST_ASSERT(wears_the_glasses.glasses != glasses, "Dummy kept their glasses, even though they were shoved targeting the correct zone.")

	SET_GLASSES_WEARER

	// Test Knockdown()
	// Any amount of positive Kockdown should lose glasses
	wears_the_glasses.Knockdown(1 SECONDS)
	TEST_ASSERT(wears_the_glasses.IsKnockdown(), "Dummy wasn't knocked down after Knockdown() was called.")
	TEST_ASSERT(wears_the_glasses.glasses != glasses, "Dummy kept their glasses, even though they knocked down by Knockdown().")

	SET_GLASSES_WEARER

	// Test AdjustKnockdown()
	// Any amount of positive Kockdown should lose glasses
	wears_the_glasses.AdjustKnockdown(1 SECONDS)
	TEST_ASSERT(wears_the_glasses.IsKnockdown(), "Dummy wasn't knocked down after AdjustKnockdown() was called.")
	TEST_ASSERT(wears_the_glasses.glasses != glasses, "Dummy kept their glasses, even though they knocked down by AdjustKnockdown().")

	SET_GLASSES_WEARER

	// Test SetKnockdown()
	// Any amount of positive Kockdown should lose glasses
	wears_the_glasses.SetKnockdown(1 SECONDS)
	TEST_ASSERT(wears_the_glasses.IsKnockdown(), "Dummy wasn't knocked down after SetKnockdown() was called.")
	TEST_ASSERT(wears_the_glasses.glasses != glasses, "Dummy kept their glasses, even though they knocked down by SetKnockdown().")

	SET_GLASSES_WEARER

	// Test a negative value applied of Knockdown (AdjustKnockdown, SetKnockdown, and Knockdown should all act the same here)
	// Any amount of negative Kockdown should not cause the glasses to be lost
	wears_the_glasses.AdjustKnockdown(-1 SECONDS)
	TEST_ASSERT(!wears_the_glasses.IsKnockdown(), "Dummy was knocked down after AdjustKnockdown() was called with a negative value.")
	TEST_ASSERT(wears_the_glasses.glasses == glasses, "Dummy lost their glasses, even though AdjustKnockdown() was called with a negative value.")

	// Bonus check: A wallshove should definitely cause them to be lost
	wears_the_glasses.forceMove(shoves_the_guy.loc)
	shoves_the_guy.forceMove(right_of_shover)

	shoves_the_guy.zone_selected = BODY_ZONE_CHEST
	shoves_the_guy.disarm(wears_the_glasses)
	TEST_ASSERT(wears_the_glasses.glasses != glasses, "Dummy kept their glasses, even though were disarm shoved into a wall.")
