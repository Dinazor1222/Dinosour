
/datum/mapGeneratorModule/bottomLayer/lavaland_default
	spawnableTurfs = list(/turf/open/floor/plating/asteroid/basalt/lava_land_surface = 100)

/datum/mapGeneratorModule/bottomLayer/lavaland_mineral
	spawnableTurfs = list(/turf/closed/mineral/random/volcanic = 100)

/datum/mapGeneratorModule/bottomLayer/lavaland_mineral/dense
	spawnableTurfs = list(/turf/closed/mineral/random/high_chance/volcanic = 100)

/datum/mapGeneratorModule/splatterLayer/lavalandMonsters
	spawnableTurfs = list()
	spawnableAtoms = list(/mob/living/simple_animal/hostile/asteroid/goliath/beast = 20,
	/mob/living/simple_animal/hostile/asteroid/hivelord/legion = 20,
	/mob/living/simple_animal/hostile/asteroid/basilisk/watcher = 20)

/datum/mapGeneratorModule/splatterLayer/lavalandTendrils
	spawnableTurfs = list()
	spawnableAtoms = list(/mob/living/simple_animal/hostile/spawner/lavaland = 15,
	/mob/living/simple_animal/hostile/spawner/lavaland/legion = 15,
	/mob/living/simple_animal/hostile/spawner/lavaland/goliath = 15)

/datum/mapGenerator/lavaland/ground_only
	modules = list(/datum/mapGeneratorModule/bottomLayer/lavaland_default)

/datum/mapGenerator/lavaland/dense_ores
	modules = list(/datum/mapGeneratorModule/bottomLayer/lavaland_mineral/dense)

/datum/mapGenerator/lavaland/normal_ores
	modules = list(/datum/mapGeneratorModule/bottomLayer/lavaland_mineral)
