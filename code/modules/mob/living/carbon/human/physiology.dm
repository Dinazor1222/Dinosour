//Stores several modifiers in a way that isn't cleared by changing species

/datum/physiology
	var/brute_mod = 1   	// % of brute damage taken from all sources
	var/burn_mod = 1    	// % of burn damage taken from all sources
	var/tox_mod = 1     	// % of toxin damage taken from all sources
	var/oxy_mod = 1     	// % of oxygen damage taken from all sources
	var/clone_mod = 1   	// % of clone damage taken from all sources
	var/stamina_mod = 1 	// % of stamina damage taken from all sources
	var/brain_mod = 1   	// % of brain damage taken from all sources

	var/pressure_mod = 1	// % of brute damage taken from low or high pressure (stacks with brute_mod)
	var/heat_mod = 1    	// % of burn damage taken from heat (stacks with burn_mod)
	var/cold_mod = 1    	// % of burn damage taken from cold (stacks with burn_mod)

	var/damage_resistance = 0 // %damage reduction from all sources

	var/siemens_coeff = 1 	// resistance to shocks

	var/stun_mod = 1      	// % stun modifier
	var/bleed_mod = 1     	// % bleeding modifier
	var/datum/armor/armor 	// internal armor datum

	var/speed_mod = 0     	//tick modifier for each step. Positive is slower, negative is faster.

	var/hunger_mod = 1		//% of hunger rate taken per tick.

	var/do_after_speed = 1 //Speed mod for do_after. Lower is better. If temporarily adjusting, please only modify using *= and /=, so you don't interrupt other calculations.

	var/punchlow = 0     	//Adds to the minimal damage that an unarmed attack can do for that species
	var/punchhigh = 0    	//Adds to the maximum damage that an unarmed attack can do for that species
	var/punchstun = 0    	//Adds to the minimum value that an unarmed attack will stun at (Preferably should have the same number as punchhigh, as it means the maximum damage a punch can do WILL stun)

/datum/physiology/New()
	armor = new
