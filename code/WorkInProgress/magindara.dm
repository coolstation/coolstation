var/list/obj/overlay/magindara_fog/magindara_global_fog

/turf/space/magindara
	name = "\improper the ocean below"
	desc = "The deep ocean of Magindara far below, whipped with waves and frigid cold."
	icon = 'icons/turf/water.dmi'
	icon_state = "magindara_ocean"
	opacity = 0
	pathable = 0
	mat_changename = 0
	mat_changedesc = 0
	fullbright = 0
	luminosity = 1
	throw_unlimited = 0
	color = "#ffffff"
	special_volume_override = -1
	turf_flags = MINE_MAP_PRESENTS_EMPTY
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C

	var/datum/light/point/light = null
	var/light_r = 0.55
	var/light_g = 0.4
	var/light_b = 0.6
	var/light_brightness = 1.1
	var/light_height = 3
	var/generateLight = 1

	New()
		..()
		if (generateLight)
			src.make_light()
		if(!magindara_global_fog)
			magindara_global_fog = list()
		if(!length(magindara_global_fog))
			for (var/i in 1 to 4)
				magindara_global_fog += new /obj/overlay/magindara_fog
		vis_contents += magindara_global_fog[1 + (src.x % 2) + (src.y % 2) * 2]
		var/obj/decal/magindara_skylight/skylight = locate() in src
		if(skylight)
			qdel(skylight)

	/// Adds the pitfall, handled in map setup on Perduta. If you wanna spawn this turf, call this soon after!
	proc/initialise_component()
		src.AddComponent(/datum/component/pitfall/target_coordinates/nonstation,\
			BruteDamageMax = 6,\
			AnchoredAllowed = FALSE,\
			HangTime = 0.3 SECONDS,\
			FallTime = 1.2 SECONDS,\
			DepthScale = 0.5,\
			TargetZ = 5)

	make_light()
		if (!light)
			light = new
			light.attach(src)
		light.set_brightness(light_brightness)
		light.set_color(light_r, light_g, light_b)
		light.set_height(light_height)
		SPAWN_DBG(0.1)
			light?.enable()

/obj/overlay/magindara_fog
	name = "thick smog"
	desc = "The atmosphere of Magindara, just barely shy of chokingly thick smog."
	icon = 'icons/effects/tile_effects.dmi'
	icon_state = "densefog"
	appearance_flags = RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | KEEP_APART
	layer = EFFECTS_LAYER_4
	plane = PLANE_NOSHADOW_ABOVE
	mouse_opacity = FALSE
	alpha = 128

	ex_act(severity)
		return

/obj/overlay/magindara_skylight
	name = null
	desc = "hidden decal to show the light and weather of Magindara on any turf"
	anchored = 2
	var/datum/light/point/light = null
	var/light_r = 0.55
	var/light_g = 0.4
	var/light_b = 0.6
	var/light_brightness = 1.1
	var/light_height = 3
	var/generateLight = 1

	New()
		..()
		if (!light)
			light = new
			light.attach(src)
		light.set_brightness(light_brightness)
		light.set_color(light_r, light_g, light_b)
		light.set_height(light_height)
		SPAWN_DBG(0.1)
			light?.enable()
		if(!magindara_global_fog)
			magindara_global_fog = list()
		if(!length(magindara_global_fog))
			for (var/i in 1 to 4)
				magindara_global_fog += new /obj/overlay/magindara_fog
		vis_contents += magindara_global_fog[1 + (src.x % 2) + (src.y % 2) * 2]

	ex_act(severity)
		return

/area/magindara
	icon_state = "pink"
	name = "\proper Magindaran sea"
	is_construction_allowed = TRUE

/area/station/catwalk/simulated //todo: make this an abstract type later
	icon_state = "yellow"
	name = "Maintenance Catwalk"
	force_fullbright = FALSE
	requires_power = TRUE

proc/update_magindaran_weather(fog_alpha=128,rain_alpha=40,rain_color="#ac85eb")
	if(!magindara_global_fog)
		magindara_global_fog = list()
	if(!length(magindara_global_fog))
		for (var/i in 1 to 4)
			magindara_global_fog += new /obj/overlay/magindara_fog
	for (var/i in 1 to 4)
		magindara_global_fog[i].alpha = fog_alpha
		if(rain_alpha)
			var/image/weather = image('icons/turf/water.dmi',"bigrain[i]", layer = EFFECTS_LAYER_BASE)
			weather.alpha = rain_alpha
			weather.color = rain_color
			weather.appearance_flags = RESET_COLOR | RESET_ALPHA
			weather.plane = PLANE_NOSHADOW_ABOVE
			magindara_global_fog[i].UpdateOverlays(weather, "weather_rain")
		else
			magindara_global_fog[i].UpdateOverlays(null, "weather_rain")

/client/proc/change_magindaran_weather()
	set name = "Change Magindaran Weather"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	admin_only

	var/fog_alpha = input(usr, "Please enter the fog alpha:","Fog Alpha", "128") as num
	var/rain_alpha = input(usr, "Please enter the rain alpha:","Rain Alpha", "0") as num
	var/rain_color = input(usr, "Please enter the rain color:","Rain Color", "#4e2492") as color

	logTheThing("admin", usr, null, "changed Magindara's weather to fog [fog_alpha] and rain [rain_alpha] [rain_color].")
	logTheThing("diary", usr, null, "changed Magindara's weather to fog [fog_alpha] and rain [rain_alpha] [rain_color].", "admin")

	update_magindaran_weather(fog_alpha, rain_alpha, rain_color)

/client/proc/strike_lightning_here()
	set name = "Strike Lightning Here"
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	admin_only

	var/power = input(usr, "Please enter the power:","Power", "10") as num
	var/warning_time = input(usr, "Please enter the warning time (deciseconds):","Warning Time", "60") as num
	var/warning_sparks = input(usr, "Please enter the number of warning sparks:","Warning Sparks", "9") as num
	var/is_turf_safe = input(usr, "Is this lightning safe for turfs? BE CAREFUL:","Turf Safe", "1") as num
	var/turf/T = get_turf(src.mob)

	if(power)
		logTheThing("admin", src, null, "created[is_turf_safe ? "" : " turf destroying"] lightning (power [power], warning [warning_time]) at [log_loc(T)].")
		logTheThing("diary", src, null, "created[is_turf_safe ? "" : " turf destroying"] lightning (power [power], warning [warning_time]) at [log_loc(T)].", "admin")

		lightning_strike(T, power, warning_time, warning_sparks, is_turf_safe)

/proc/lightning_strike(var/turf/target, var/power = 10, var/warning_time = 6 SECONDS, var/warning_sparks = 9, var/is_turf_safe = TRUE)
	if(!target || !power)
		return
	if(!istype(target))
		target = get_turf(target)
	logTheThing("bombing", null, null, "Lightning[is_turf_safe ? "" : " (turf destroying)"] with power [power] started striking [log_loc(target)], warning time [warning_time / 10] seconds.")
	logTheThing("diary", null, null, "Lightning[is_turf_safe ? "" : " (turf destroying)"] with power [power] started striking [log_loc(target)], warning time [warning_time / 10] seconds.", "combat")
	SPAWN_DBG(0)
		var/sleep_time = ceil(warning_time / (warning_sparks + 1))
		if(warning_sparks && warning_time)
			var/spark_volume = max(50 - 5 * warning_sparks, 20)
			for(var/i in 1 to warning_sparks)
				if(QDELETED(target))
					return
				var/datum/effects/system/spark_spread/E = new()
				E.set_up(6,0,target)
				E.start()
				sleep(sleep_time)
				playsound(target, pick(sounds_sparks), spark_volume, 1)
				spark_volume = min(spark_volume + 5 * warning_sparks, 65)
		sleep(sleep_time)
		if(QDELETED(target))
			return
		playsound(target, 'sound/effects/thunder.ogg', 80, 1, floor(power))
		new /obj/decal/lightning(target)
		explosion_new(target, target, power, turf_safe = is_turf_safe, no_effects = TRUE)
		for(var/mob/living/L in orange(2, target)) // some more mean effects
			L.changeStatus("disorient",min(5 * power,30 SECONDS))
			L.change_misstep_chance(min(power, 30))
