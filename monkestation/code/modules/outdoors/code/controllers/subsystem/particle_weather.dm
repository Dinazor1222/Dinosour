SUBSYSTEM_DEF(particle_weather)
	name = "Particle Weather"
	flags = SS_BACKGROUND
	wait = 10
	runlevels = RUNLEVEL_GAME
	var/list/elligble_weather = list()
	var/datum/particle_weather/runningWeather
	// var/list/next_hit = list() //Used by barometers to know when the next storm is coming

	var/particles/weather/particleEffect
	var/obj/weather_effect

/datum/controller/subsystem/particle_weather/fire()
	// process active weather
	if(runningWeather)
		if(runningWeather.running)
			runningWeather.tick()
			for(var/mob/act_on as anything in GLOB.mob_living_list)
				runningWeather.try_weather_act(act_on)
	else
		// start random weather
		var/datum/particle_weather/our_event = pick_weight(elligble_weather) //possible_weather
		if(our_event)
			run_weather(our_event)


//This has been mangled - currently only supports 1 weather effect serverwide so I can finish this
/datum/controller/subsystem/particle_weather/Initialize(start_timeofday)
	for(var/V in subtypesof(/datum/particle_weather))
		var/datum/particle_weather/W = V
		var/probability = initial(W.probability)
		var/target_trait = initial(W.target_trait)

		// any weather with a probability set may occur at random
		if (probability && SSmapping.config.particle_weather[target_trait])
			LAZYINITLIST(elligble_weather)
			elligble_weather[W] = probability
	return ..()

/datum/controller/subsystem/particle_weather/proc/run_weather(datum/particle_weather/weather_datum_type, force = 0)
	if(runningWeather)
		if(force)
			runningWeather.end()
		else
			return
	if (istext(weather_datum_type))
		for (var/V in subtypesof(/datum/particle_weather))
			var/datum/particle_weather/W = V
			if (initial(W.name) == weather_datum_type)
				weather_datum_type = V
				break
	if (!ispath(weather_datum_type, /datum/particle_weather))
		CRASH("run_weather called with invalid weather_datum_type: [weather_datum_type || "null"]")

	runningWeather = new weather_datum_type()

	if(force)
		runningWeather.start()
	else
		var/randTime = rand(0, 6000) + initial(runningWeather.weather_duration_upper)
		addtimer(CALLBACK(runningWeather, /datum/particle_weather/proc/start), randTime, TIMER_UNIQUE|TIMER_STOPPABLE) //Around 0-10 minutes between weathers


/datum/controller/subsystem/particle_weather/proc/make_eligible(possible_weather)
	elligble_weather = possible_weather
// 	next_hit = null

/datum/controller/subsystem/particle_weather/proc/get_weather_effect(atom/movable/screen/plane_master/weather_effect/W)
	if(!weather_effect)
		weather_effect = new /obj()
		weather_effect.particles = particleEffect
		weather_effect.filters += filter(type="alpha", render_source="[WEATHER_RENDER_TARGET] #[W.offset]")
		weather_effect.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	return weather_effect

/datum/controller/subsystem/particle_weather/proc/SetparticleEffect(particles/P)
	particleEffect = P
	weather_effect.particles = particleEffect

/datum/controller/subsystem/particle_weather/proc/stopWeather()
	QDEL_NULL(runningWeather)
	QDEL_NULL(particleEffect)
