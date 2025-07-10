/turf/drawbridge
	name = "bridge"
	icon = 'icons/turf/drawbridge.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0

	meteorhit()
		return

/turf/drawbridge/wall
	name = "drawbridge wall"
	icon_state = "wall"
	var/icon_style = "wall"
	opacity = 0
	density = 1
	gas_impermeable = 1
	pathable = 0

/turf/drawbridge/floor
	name = "drawbridge floor"
	icon_state = "floor"

// airbridge

/turf/floor/airbridge
	// regular white steel floor for now but a good candidate for new sprites!
	icon_state = "airbridge"
	name = "airbridge floor"

	classic
		icon = 'icons/turf/construction_floors.dmi' // this dmi has a few of the older ones still
		icon_state = "shuttle"

		white
			icon_state = "shuttle-white"

		yellow
			icon_state = "shuttle-yellow"

		red
			icon_state = "shuttle-red"

		purple
			icon_state = "shuttle-purple"

		green
			icon_state = "shuttle-green"

/turf/wall/airbridge
	icon_state = "airbridge"
	name = "airbridge wall"

	classic
		icon = 'icons/turf/construction_walls.dmi'
		icon_state = "shuttle"

		gray
			icon_state = "shuttle-gray"

		orange
			icon_state = "shuttle-orange"

		green
			icon_state = "shuttle-green"
