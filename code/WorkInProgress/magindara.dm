/turf/space/magindara
	name = "\proper the ocean below"
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
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C

	var/static/obj/overlay/magindara_fog/magindara_fog
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
		if(!magindara_fog)
			magindara_fog = new
			magindara_fog.alpha = 128
		vis_contents += magindara_fog

	/// Adds the pitfall, handled in map setup on Perduta. If you wanna spawn this turf, call this soon after!
	proc/initialise_component()
		src.AddComponent(/datum/component/pitfall/target_coordinates,\
			BruteDamageMax = 6,\
			AnchoredAllowed = FALSE,\
			HangTime = 0.3 SECONDS,\
			FallTime = 1.2 SECONDS,\
			DepthScale = 0.5,\
		)

	make_light()
		if (!light)
			light = new
			light.attach(src)
		light.set_brightness(light_brightness)
		light.set_color(light_r, light_g, light_b)
		light.set_height(light_height)
		SPAWN_DBG(0.1)
			light?.enable()

	update_icon(starlight_alpha=128) // dumb and bad
		return

	proc/update_fog(fog_alpha=128)
		if(!magindara_fog)
			magindara_fog = new

		magindara_fog.alpha = fog_alpha

/obj/overlay/magindara_fog
	name = "thick smog"
	desc = "The atmosphere of Magindara, just barely shy of chokingly thick smog."
	icon = 'icons/effects/tile_effects.dmi'
	icon_state = "densefog"
	appearance_flags = RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | KEEP_APART
	layer = EFFECTS_LAYER_4
	plane = PLANE_NOSHADOW_ABOVE
	mouse_opacity = FALSE

/area/magindara
	icon_state = "pink"
	name = "the magindaran sea"
	is_construction_allowed = TRUE

proc/update_magindaran_weather(fog_alpha=128,rain_alpha=0)
	if(!map_currently_abovewater)
		return FALSE
	var/turf/space/magindara/sample = locate(/turf/space/magindara)
	if(!sample)
		return FALSE
	sample.update_fog(fog_alpha)
	if(rain_alpha)
		var/image/weather = image('icons/turf/water.dmi',"fast_rain", layer = EFFECTS_LAYER_BASE)
		weather.alpha = rain_alpha
		weather.appearance_flags = RESET_COLOR | RESET_ALPHA
		weather.plane = PLANE_NOSHADOW_ABOVE
		sample.magindara_fog.UpdateOverlays(weather, "weather_rain")
	else
		sample.magindara_fog.UpdateOverlays(null, "weather_rain")
	return TRUE

/client/proc/change_magindaran_weather()
	set name = "Change Magindaran Weather"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	admin_only

	var/fog_alpha = input(usr, "Please enter the fog alpha:","Fog Alpha", "128") as num
	var/rain_alpha = input(usr, "Please enter the rain alpha:","Rain Alpha", "0") as num

	update_magindaran_weather(fog_alpha, rain_alpha)
