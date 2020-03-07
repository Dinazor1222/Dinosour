/turf/proc/coldspot_expose(exposed_temperature, exposed_volume, soh = 0)
	return


/turf/open/coldspot_expose(exposed_temperature, exposed_volume, soh)
	var/list/air_gases = air?.gases
	if(!air_gases)
		return

	. = air_gases[/datum/gas/oxygen]
	var/oxy = . ? .[MOLES] : 0
	if (oxy < 0.5)
		return
	. = air_gases[/datum/gas/freon]
	var/freon = . ? .[MOLES] : 0
	if(active_coldspot)
		if(soh)
			if(freon > 0.5)
				if(active_coldspot.temperature > exposed_temperature)
					active_coldspot.temperature = exposed_temperature
				if(active_coldspot.volume > exposed_volume)
					active_coldspot.volume = exposed_volume
		return

	if((exposed_temperature < FREON_MAXIMUM_BURN_TEMPERATURE) && (freon > 0.5))

		active_coldspot = new /obj/effect/coldspot(src, exposed_volume*25, exposed_temperature)

		active_coldspot.just_spawned = (current_cycle < SSair.times_fired)
			//remove just_spawned protection if no longer processing this cell
		SSair.add_to_active(src, 0)

//This is the icon for fire on turfs, also helps for nurturing small fires until they are full tile
/obj/effect/coldspot
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	layer = GASFIRE_LAYER
	light_range = LIGHT_RANGE_FIRE
	light_color = LIGHT_COLOR_FIRE
	blend_mode = BLEND_ADD

	var/volume = 125
	var/temperature = COLD_FIRE_MAXIMUM_TEMPERATURE_TO_EXIST
	var/just_spawned = TRUE
	var/bypassing = FALSE
	var/visual_update_tick = 0

/obj/effect/coldspot/Initialize(mapload, starting_volume, starting_temperature)
	. = ..()
	SSair.coldspots += src
	if(!isnull(starting_volume))
		volume = starting_volume
	if(!isnull(starting_temperature))
		temperature = starting_temperature
	perform_exposure()
	setDir(pick(GLOB.cardinals))
	air_update_turf()

/obj/effect/coldspot/proc/perform_exposure()
	var/turf/open/location = loc
	if(!istype(location) || !(location.air))
		return

	location.active_coldspot = src

	bypassing = !just_spawned && (volume > CELL_VOLUME*0.95)

	if(bypassing)
		volume = location.air.reaction_results["cold fire"]*COLD_FIRE_GROWTH_RATE
		temperature = location.air.temperature
	else
		var/datum/gas_mixture/affected = location.air.remove_ratio(volume/location.air.volume)
		if(affected) //in case volume is 0
			affected.temperature = temperature
			affected.react(src)
			temperature = affected.temperature
			volume = affected.reaction_results["cold fire"]*COLD_FIRE_GROWTH_RATE
			location.assume_air(affected)

	for(var/A in location)
		var/atom/AT = A
		if(!QDELETED(AT) && AT != src) // It's possible that the item is deleted in temperature_expose
			AT.fire_act(temperature, volume)
	return

/obj/effect/coldspot/proc/gauss_lerp(x, x1, x2)
	var/b = (x1 + x2) * 0.5
	var/c = (x2 - x1) / 6
	return NUM_E ** -((x - b) ** 2 / (2 * c) ** 2)

/obj/effect/coldspot/proc/update_color()
	cut_overlays()

	var/heat_r = heat2colour_r(temperature)
	var/heat_g = heat2colour_g(temperature)
	var/heat_b = heat2colour_b(temperature)
	var/heat_a = 255
	var/greyscale_fire = 1 //This determines how greyscaled the fire is.

	if(temperature > 270) //This is where fire is very orange, we turn it into the normal fire texture here.
		var/normal_amt = gauss_lerp(temperature, 1000, 3000)
		heat_r = LERP(heat_r,255,normal_amt)
		heat_g = LERP(heat_g,255,normal_amt)
		heat_b = LERP(heat_b,255,normal_amt)
		heat_a -= gauss_lerp(temperature, -5000, 5000) * 128
		greyscale_fire -= normal_amt
	if(temperature < 270) //Past this temperature the fire will gradually turn a bright purple
		var/purple_amt = temperature < LERP(40000,200000,0.5) ? gauss_lerp(temperature, 40000, 200000) : 1
		heat_r = LERP(heat_r,255,purple_amt)
	if(temperature < 200 && temperature > 150) //Somewhere at this temperature nitryl happens.
		var/sparkle_amt = gauss_lerp(temperature, 200000, 500000)
		var/mutable_appearance/sparkle_overlay = mutable_appearance('icons/effects/effects.dmi', "shieldsparkles")
		sparkle_overlay.blend_mode = BLEND_ADD
		sparkle_overlay.alpha = sparkle_amt * 255
		add_overlay(sparkle_overlay)
	if(temperature < 150 && temperature > 100) //Lightning because very anime.
		var/mutable_appearance/lightning_overlay = mutable_appearance(icon, "overcharged")
		lightning_overlay.blend_mode = BLEND_ADD
		add_overlay(lightning_overlay)
	if(temperature < 100) //This is where noblium happens. Some fusion-y effects.
		var/fusion_amt = temperature < LERP(4500000,12000000,0.5) ? gauss_lerp(temperature, 4500000, 12000000) : 1
		var/mutable_appearance/fusion_overlay = mutable_appearance('icons/effects/atmospherics.dmi', "fusion_gas")
		fusion_overlay.blend_mode = BLEND_ADD
		fusion_overlay.alpha = fusion_amt * 255
		var/mutable_appearance/rainbow_overlay = mutable_appearance('icons/mob/screen_gen.dmi', "druggy")
		rainbow_overlay.blend_mode = BLEND_ADD
		rainbow_overlay.alpha = fusion_amt * 255
		rainbow_overlay.appearance_flags = RESET_COLOR
		heat_r = LERP(heat_r,150,fusion_amt)
		heat_g = LERP(heat_g,150,fusion_amt)
		heat_b = LERP(heat_b,150,fusion_amt)
		add_overlay(fusion_overlay)
		add_overlay(rainbow_overlay)

	set_light(l_color = rgb(LERP(250,heat_r,greyscale_fire),LERP(160,heat_g,greyscale_fire),LERP(25,heat_b,greyscale_fire)))

	heat_r /= 255
	heat_g /= 255
	heat_b /= 255

	color = list(LERP(0.3, 1, 1-greyscale_fire) * heat_r,0.3 * heat_g * greyscale_fire,0.3 * heat_b * greyscale_fire, 0.59 * heat_r * greyscale_fire,LERP(0.59, 1, 1-greyscale_fire) * heat_g,0.59 * heat_b * greyscale_fire, 0.11 * heat_r * greyscale_fire,0.11 * heat_g * greyscale_fire,LERP(0.11, 1, 1-greyscale_fire) * heat_b, 0,0,0)
	alpha = heat_a

#define INSUFFICIENT(path) (!location.air.gases[path] || location.air.gases[path][MOLES] < 0.5)
/obj/effect/coldspot/process()
	if(just_spawned)
		just_spawned = FALSE
		return

	var/turf/open/location = loc
	if(!istype(location))
		qdel(src)
		return

	if(location.excited_group)
		location.excited_group.reset_cooldowns()

	if((temperature > COLD_FIRE_MAXIMUM_TEMPERATURE_TO_EXIST) || (volume <= 1))
		qdel(src)
		return
	if(!location.air || INSUFFICIENT(/datum/gas/freon) || INSUFFICIENT(/datum/gas/oxygen))
		qdel(src)
		return

	//Not enough to burn
	if((!location.air.gases[/datum/gas/plasma] || location.air.gases[/datum/gas/plasma][MOLES] < 0.5) || location.air.gases[/datum/gas/oxygen][MOLES] < 0.5)
		qdel(src)
		return

	perform_exposure()

	if(bypassing)
		icon_state = "3"
		location.burn_tile()

		//Possible spread due to radiated heat
		if(location.air.temperature < COLD_FIRE_MAXIMUM_TEMPERATURE_TO_SPREAD)
			var/radiated_temperature = location.air.temperature*COLD_FIRE_SPREAD_RADIOSITY_SCALE
			for(var/t in location.atmos_adjacent_turfs)
				var/turf/open/T = t
				if(!T.active_coldspot)
					T.coldspot_expose(radiated_temperature, CELL_VOLUME/4)

	else
		if(volume > CELL_VOLUME*0.4)
			icon_state = "2"
		else
			icon_state = "1"

	if((visual_update_tick++ % 7) == 0)
		update_color()

#undef INSUFFICIENT
