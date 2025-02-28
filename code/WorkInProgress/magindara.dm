/turf/space/magindara
	name = "\improper ocean below"
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

	var/datum/light/point/light = null
	var/light_r = 0.6
	var/light_g = 0.4
	var/light_b = 1.0
	var/light_brightness = 1.25
	var/light_height = 3
	var/generateLight = 1

	New()
		..()
		if (generateLight)
			src.make_light()
		src.initialise_component()

	proc/initialise_component()
		src.AddComponent(/datum/component/pitfall/target_area,\
			BruteDamageMax = 6,\
			HangTime = 0.6 SECONDS,\
			FallTime = 1.5 SECONDS,\
			TargetArea = /area/station/medical/medbay/lobby)

	make_light()
		if (!light)
			light = new
			light.attach(src)
		light.set_brightness(light_brightness)
		light.set_color(light_r, light_g, light_b)
		light.set_height(light_height)
		SPAWN_DBG(0.1)
			light?.enable()

/area/magindara
	icon_state = "pink"
	name = "the magindaran sea"
	is_construction_allowed = TRUE
