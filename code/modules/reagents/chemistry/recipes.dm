/datum/chemical_reaction
	var/name = null
	var/id = null
	var/list/results = new/list()
	var/list/required_reagents = new/list()
	var/list/required_catalysts = new/list()
		//FermiChem vars:
	var/OptimalTempMin 		= 0 // Lower area of bell curve for determining heat based rate reactions
	var/OptimalTempMax		= 1000 // Upper end for above
	var/ExplodeTemp			//Temperature at which reaction explodes
	var/OptimalpHMin		= 1 // Lowest value of pH determining pH a 1 value for pH based rate reactions (Plateu phase)
	var/OptimalpHMax		= 14 // Higest value for above
	var/ReactpHLim			= 0 // How far out pH wil react, giving impurity place (Exponential phase)
	//var/CatalystFact		= 0 // How much the catalyst affects the reaction (0 = no catalyst) //unimplemented, coming soon
	var/CurveSharpT 		= 1.5 // How sharp the temperature exponential curve is (to the power of value)
	var/CurveSharppH 		= 3 // How sharp the pH exponential curve is (to the power of value)
	var/ThermicConstant		= 0 //Temperature change per 1u produced
	var/HIonRelease 		= 0 //pH change per 1u reaction
	var/RateUpLim 			= 10 //Optimal/max rate possible if all conditions are perfect
	var/FermiExplode 		= FALSE //If the chemical explodes in a special way
	var/PurityMin			= 0.1 //The minimum purity something has to be above, otherwise it explodes.
	var/FermiChem = FALSE // If the chemical uses the Fermichem reaction mechanics
	var/clear_conversion	= REACTION_CLEAR_INVERSE

	// Both of these variables are mostly going to be used with slime cores - but if you want to, you can use them for other things
	var/required_container = null // the exact container path required for the reaction to happen
	var/required_other = 0 // an integer required for the reaction to happen

	var/mob_react = TRUE //Determines if a chemical reaction can occur inside a mob

	var/required_temp = 0
	var/is_cold_recipe = 0 // Set to 1 if you want the recipe to only react when it's BELOW the required temp.
	var/mix_message = "The solution begins to bubble." //The message shown to nearby people upon mixing, if applicable
	var/mix_sound = 'sound/effects/bubbles.ogg' //The sound played upon mixing, if applicable

/datum/chemical_reaction/proc/on_reaction(datum/reagents/holder, created_volume)
	return
	//I recommend you set the result amount to the total volume of all components.

/datum/chemical_reaction/proc/check_special_react(datum/reagents/holder)
	return

/datum/chemical_reaction/proc/chemical_mob_spawn(datum/reagents/holder, amount_to_spawn, reaction_name, mob_class = HOSTILE_SPAWN, mob_faction = "chemicalsummon", random = TRUE)
	if(holder && holder.my_atom)
		var/atom/A = holder.my_atom
		var/turf/T = get_turf(A)
		var/message = "A [reaction_name] reaction has occurred in [ADMIN_VERBOSEJMP(T)]"
		message += " (<A HREF='?_src_=vars;Vars=[REF(A)]'>VV</A>)"

		var/mob/M = get(A, /mob)
		if(M)
			message += " - Carried By: [ADMIN_LOOKUPFLW(M)]"
		else
			message += " - Last Fingerprint: [(A.fingerprintslast ? A.fingerprintslast : "N/A")]"

		message_admins(message, 0, 1)
		log_game("[reaction_name] chemical mob spawn reaction occuring at [AREACOORD(T)] carried by [key_name(M)] with last fingerprint [A.fingerprintslast? A.fingerprintslast : "N/A"]")

		playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, TRUE)

		for(var/mob/living/carbon/C in viewers(get_turf(holder.my_atom), null))
			C.flash_act()

		for(var/i in 1 to amount_to_spawn)
			var/mob/living/simple_animal/S
			if(random)
				S = create_random_mob(get_turf(holder.my_atom), mob_class)
			else
				S = new mob_class(get_turf(holder.my_atom))//Spawn our specific mob_class
			S.faction |= mob_faction
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(S, pick(NORTH,SOUTH,EAST,WEST))

///Simulates a vortex that moves nearby movable atoms towards or away from the turf T. Range also determines the strength of the effect. High values cause nearby objects to be thrown.
/proc/goonchem_vortex(turf/T, setting_type, range)
	for(var/atom/movable/X in orange(range, T))
		if(X.anchored)
			continue
		if(iseffect(X) || iscameramob(X) || isdead(X))
			continue
		var/distance = get_dist(X, T)
		var/moving_power = max(range - distance, 1)
		if(moving_power > 2) //if the vortex is powerful and we're close, we get thrown
			if(setting_type)
				var/atom/throw_target = get_edge_target_turf(X, get_dir(X, get_step_away(X, T)))
				X.throw_at(throw_target, moving_power, 1)
			else
				X.throw_at(T, moving_power, 1)
		else
			if(setting_type)
				if(step_away(X, T) && moving_power > 1) //Can happen twice at most. So this is fine.
					addtimer(CALLBACK(GLOBAL_PROC, .proc/_step_away, X, T), 2)
			else
				if(step_towards(X, T) && moving_power > 1)
					addtimer(CALLBACK(GLOBAL_PROC, .proc/_step_towards, X, T), 2)
