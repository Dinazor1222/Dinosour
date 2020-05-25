//the random offset applied to square coordinates, causes intermingling at biome borders
#define BIOME_RANDOM_SQUARE_DRIFT 2

/datum/map_generator/jungle_generator
	///2D list of all biomes based on heat and humidity combos.
	var/list/possible_biomes = list(BIOME_LOW_HEAT = list(BIOME_LOW_HUMIDITY = /datum/biome/plains, BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/mudlands, BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/mudlands, BIOME_HIGH_HUMIDITY = /datum/biome/water), BIOME_LOWMEDIUM_HEAT = list(BIOME_LOW_HUMIDITY = /datum/biome/plains, BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/jungle, BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/jungle, BIOME_HIGH_HUMIDITY = /datum/biome/mudlands), BIOME_HIGHMEDIUM_HEAT = list(BIOME_LOW_HUMIDITY = /datum/biome/plains, BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/plains, BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/jungle/deep, BIOME_HIGH_HUMIDITY = /datum/biome/jungle), BIOME_HIGH_HEAT = list(BIOME_LOW_HUMIDITY = /datum/biome/wasteland, BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/plains, BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/jungle, BIOME_HIGH_HUMIDITY = /datum/biome/jungle/deep))

///Seeds the rust-g perlin noise with a random number.
/datum/map_generator/jungle_generator/generate_terrain(var/list/turfs)
	. = ..()
	var/height_seed = rand(0, 50000)
	var/humidity_seed = rand(0, 50000)
	var/heat_seed = rand(0, 50000)

	for(var/turf/T in turfs) //Go through all the turfs and generate them
		var/x = T.x + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)
		var/y = T.y + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)

		var/height = CLAMP01(text2num(rustg_noise_get_at_coordinates("[height_seed]", "[x / 65]", "[y / 65]")))


		var/datum/biome/selected_biome
		if(height <= 0.85) //If height is less than 0.85, we generate biomes based on the heat and humidity of the area.
			var/humidity = text2num(rustg_noise_get_at_coordinates("[humidity_seed]", "[x / 65]", "[y / 65]"))
			var/heat = text2num(rustg_noise_get_at_coordinates("[heat_seed]", "[x / 65]", "[y / 65]"))
			var/heat_level //Type of heat zone we're in LOW-MEDIUM-HIGH
			var/humidity_level  //Type of humidity zone we're in LOW-MEDIUM-HIGH

			switch(heat)
				if(0 to 0.25)
					heat_level = BIOME_LOW_HEAT
				if(0.25 to 0.5)
					heat_level = BIOME_LOWMEDIUM_HEAT
				if(0.5 to 0.75)
					heat_level = BIOME_HIGHMEDIUM_HEAT
				if(0.75 to 1)
					heat_level = BIOME_HIGH_HEAT
			switch(humidity)
				if(0 to 0.25)
					humidity_level = BIOME_LOW_HUMIDITY
				if(0.25 to 0.5)
					humidity_level = BIOME_LOWMEDIUM_HUMIDITY
				if(0.5 to 0.75)
					humidity_level = BIOME_HIGHMEDIUM_HUMIDITY
				if(0.75 to 1)
					humidity_level = BIOME_HIGH_HUMIDITY
			selected_biome = possible_biomes[heat_level][humidity_level]
		else //Over 0.85; It's a mountain
			selected_biome = /datum/biome/mountain
		selected_biome = SSmapping.biomes[selected_biome] //Get the instance of this biome from SSmapping
		selected_biome.generate_turf(T)
		CHECK_TICK

/turf/open/genturf
	name = "ungenerated turf"
	desc = "If you see this, and you're not a ghost, yell at coders"
	icon = 'icons/turf/debug.dmi'
	icon_state = "genturf"

/area/mine/planetgeneration
	name = "planet generation area"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	map_generator = /datum/map_generator/jungle_generator
