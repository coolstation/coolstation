/*
 * Hey! You!
 * Remember to mirror your changes (unless you use the [DEFINE_FLOORS] macro)
 * floors_unsimulated.dm & floors.dm
 */

/turf/floor/airless
	oxygen = 0.001
	nitrogen = 0.001
	temperature = TCMB

//////////////////////////////////////////////////////////// SPECIAL AIRLESS-ONLY TURFS

/turf/floor/airless/solar
	icon_state = "solarbase"
	step_material = "step_lattice"
	step_priority = STEP_PRIORITY_MED

// cogwerks - catwalk plating

/turf/floor/airless/plating/catwalk
	name = "catwalk support"
	icon_state = "catwalk" //+ catwalk_cross for blue-grey, old catwalks available under catwalk_grey and catwalk_cross_grey
	allows_vehicles = 1
	step_material = "step_lattice"
	step_priority = STEP_PRIORITY_MED

/turf/floor/airless/plating/catwalk/grey
	icon_state = "catwalk_grey"

////////////////////////////////////////////////////////////

/turf/floor/airless/scorched
	icon_state = "floorscorched1"

/turf/floor/airless/scorched2
	icon_state = "floorscorched2"

/turf/floor/airless/damaged1
	icon_state = "damaged1"

/turf/floor/airless/damaged2
	icon_state = "damaged2"

/turf/floor/airless/damaged3
	icon_state = "damaged3"

/turf/floor/airless/damaged4
	icon_state = "damaged4"

/turf/floor/airless/damaged5
	icon_state = "damaged5"

/////////////////////////////////////////

/turf/floor/airless/plating
	name = "plating"
	icon_state = "plating"
	intact = 0
	layer = PLATING_LAYER
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

	jen
		icon_state = "plating_jen"

/turf/floor/airless/plating/scorched
	icon_state = "panelscorched"

/turf/floor/airless/plating/damaged1
	icon_state = "platingdmg1"

/turf/floor/airless/plating/damaged2
	icon_state = "platingdmg2"

/turf/floor/airless/plating/damaged3
	icon_state = "platingdmg3"

/////////////////////////////////////////

/turf/floor/airless/grime
	icon_state = "floorgrime"

/////////////////////////////////////////

/turf/floor/airless/neutral
	icon_state = "fullneutral"

/turf/floor/airless/neutral/side
	icon_state = "neutral"

/turf/floor/airless/neutral/corner
	icon_state = "neutralcorner"

/////////////////////////////////////////

/turf/floor/airless/white
	icon_state = "white"

/turf/floor/airless/white/side
	icon_state = "whitehall"

/turf/floor/airless/white/corner
	icon_state = "whitecorner"

/turf/floor/airless/white/checker
	icon_state = "whitecheck"

/turf/floor/airless/white/checker2
	icon_state = "whitecheck2"

/turf/floor/airless/white/grime
	icon_state = "floorgrime-w"

/////////////////////////////////////////

/turf/floor/airless/black //Okay so 'dark' is darker than 'black', So 'dark' will be named black and 'black' named grey.
	icon_state = "dark"

/turf/floor/airless/black/side
	icon_state = "greyblack"

/turf/floor/airless/black/corner
	icon_state = "greyblackcorner"

/turf/floor/airless/black/grime
	icon_state = "floorgrime-b"


/turf/floor/airless/blackwhite
	icon_state = "darkwhite"

/turf/floor/airless/blackwhite/corner
	icon_state = "darkwhitecorner"

/turf/floor/airless/blackwhite/side
	icon_state = "whiteblack"

/turf/floor/airless/blackwhite/whitegrime
	icon_state = "floorgrime_bw1"

/turf/floor/airless/blackwhite/whitegrime/other
	icon_state = "floorgrime_bw2"

/////////////////////////////////////////

/turf/floor/airless/grey
	icon_state = "fullblack"

/turf/floor/airless/grey/side
	icon_state = "black"

/turf/floor/airless/grey/corner
	icon_state = "blackcorner"

/turf/floor/airless/grey/checker
	icon_state = "blackchecker"

/turf/floor/airless/grey/blackgrime
	icon_state = "floorgrime_gb1"

/turf/floor/airless/grey/blackgrime/other
	icon_state = "floorgrime_gb2"

/turf/floor/airless/grey/whitegrime
	icon_state = "floorgrime_gw1"

/turf/floor/airless/grey/whitegrime/other
	icon_state = "floorgrime_gw2"

/////////////////////////////////////////

/turf/floor/airless/red
	icon_state = "fullred"

/turf/floor/airless/red/side
	icon_state = "red"

/turf/floor/airless/red/corner
	icon_state = "redcorner"

/turf/floor/airless/red/checker
	icon_state = "redchecker"


/turf/floor/airless/redblack
	icon_state = "redblack"

/turf/floor/airless/redblack/corner
	icon_state = "redblackcorner"


/turf/floor/airless/redwhite
	icon_state = "redwhite"

/turf/floor/airless/redwhite/corner
	icon_state = "redwhitecorner"

/////////////////////////////////////////

/turf/floor/airless/blue
	icon_state = "fullblue"

/turf/floor/airless/blue/side
	icon_state = "blue"

/turf/floor/airless/blue/corner
	icon_state = "bluecorner"

/turf/floor/airless/blue/checker
	icon_state = "bluechecker"


/turf/floor/airless/blueblack
	icon_state = "blueblack"

/turf/floor/airless/blueblack/corner
	icon_state = "blueblackcorner"


/turf/floor/airless/bluewhite
	icon_state = "bluewhite"

/turf/floor/airless/bluewhite/corner
	icon_state = "bluewhitecorner"

/////////////////////////////////////////

/turf/floor/airless/darkblue
	icon_state = "fulldblue"

/turf/floor/airless/darkblue/checker
	icon_state = "blue-dblue"

/turf/floor/airless/darkblue/checker/other
	icon_state = "blue-dblue2"

/turf/floor/airless/darkblue/side
	icon_state = "dblue"

/turf/floor/airless/darkblue/corner
	icon_state = "dbluecorner"

/turf/floor/airless/darkblue/checker
	icon_state = "dbluechecker"

/turf/floor/airless/darkblueblack
	icon_state = "dblueblack"

/turf/floor/airless/darkblueblack/corner
	icon_state = "dblueblackcorner"

/turf/floor/airless/darkbluewhite
	icon_state = "dbluewhite"

/turf/floor/airless/darkbluewhite/corner
	icon_state = "dbluewhitecorner"

/////////////////////////////////////////

/turf/floor/airless/darkpurple
	icon_state = "fulldpurple"

/turf/floor/airless/darkpurple/side
	icon_state = "dpurple"

/turf/floor/airless/darkpurple/corner
	icon_state = "dpurplecorner"

/turf/floor/airless/darkpurple/checker
	icon_state = "dpurplechecker"

/turf/floor/airless/darkpurpleblack
	icon_state = "dpurpleblack"

/turf/floor/airless/darkpurpleblack/corner
	icon_state = "dpurpleblackcorner"

/turf/floor/airless/darkpurplewhite
	icon_state = "dpurplewhite"

/turf/floor/airless/darkpurplewhite/corner
	icon_state = "dpurplewhitecorner"

/////////////////////////////////////////

/turf/floor/airless/orangeblack
	icon_state = "fullcaution"

/turf/floor/airless/orangeblack/side
	icon_state = "caution"

/turf/floor/airless/orangeblack/side/white
	icon_state = "cautionwhite"

/turf/floor/airless/orangeblack/corner
	icon_state = "cautioncorner"

/turf/floor/airless/orangeblack/corner/white
	icon_state = "cautionwhitecorner"

/////////////////////////////////////////

/turf/floor/airless/cautionblack
	icon_state = "fullcaution"

/turf/floor/airless/cautionblack/side
	icon_state = "caution"

/turf/floor/airless/cautionwhite/side
	icon_state = "cautionwhite"

/turf/floor/airless/cautionblack/corner
	icon_state = "cautioncorner"

/turf/floor/airless/cautionwhite/corner
	icon_state = "cautionwhitecorner"

/////////////////////////////////////////

/turf/floor/airless/bluegreen
	icon_state = "blugreenfull"

/turf/floor/airless/bluegreen/side
	icon_state = "blugreen"

/turf/floor/airless/bluegreen/corner
	icon_state = "blugreencorner"

/////////////////////////////////////////

/turf/floor/airless/green
	icon_state = "fullgreen"

/turf/floor/airless/green/side
	icon_state = "green"

/turf/floor/airless/green/corner
	icon_state = "greencorner"

/turf/floor/airless/green/checker
	icon_state = "greenchecker"


/turf/floor/airless/greenblack
	icon_state = "greenblack"

/turf/floor/airless/greenblack/corner
	icon_state = "greenblackcorner"


/turf/floor/airless/greenwhite
	icon_state = "greenwhite"

/turf/floor/airless/greenwhite/corner
	icon_state = "greenwhitecorner"

/////////////////////////////////////////

/turf/floor/airless/greenwhite/other
	icon_state = "toxshuttle"

/turf/floor/airless/greenwhite/other/corner
	icon_state = "toxshuttlecorner"

/////////////////////////////////////////

/turf/floor/airless/purple
	icon_state = "fullpurple"

/turf/floor/airless/purple/side
	icon_state = "purple"

/turf/floor/airless/purple/corner
	icon_state = "purplecorner"

/turf/floor/airless/purple/checker
	icon_state = "purplechecker"


/turf/floor/airless/purpleblack
	icon_state = "purpleblack"

/turf/floor/airless/purpleblack/corner
	icon_state = "purpleblackcorner"


/turf/floor/airless/purplewhite
	icon_state = "purplewhite"

/turf/floor/airless/purplewhite/corner
	icon_state = "purplewhitecorner"

/////////////////////////////////////////

/turf/floor/airless/yellow
	icon_state = "fullyellow"

/turf/floor/airless/yellow/side
	icon_state = "yellow"

/turf/floor/airless/yellow/corner
	icon_state = "yellowcorner"

/turf/floor/airless/yellow/checker
	icon_state = "yellowchecker"


/turf/floor/airless/yellowblack
	icon_state = "yellowblack"

/turf/floor/airless/yellowblack/corner
	icon_state = "yellowblackcorner"

/turf/floor/airless/yellowwhite
	icon_state = "yellowwhite"

/turf/floor/airless/yellowwhite/corner
	icon_state = "yellowwhitecorner"

/////////////////////////////////////////

/turf/floor/airless/orange
	icon_state = "fullorange"

/turf/floor/airless/orange/side
	icon_state = "orange"

/turf/floor/airless/orange/corner
	icon_state = "orangecorner"

/turf/floor/airless/orangeblack
	icon_state = "fullcaution"

/turf/floor/airless/orange/checker
	icon_state = "orangechecker"

/turf/floor/airless/orangeblack/side
	icon_state = "caution"

/turf/floor/airless/orangeblack/side/white
	icon_state = "cautionwhite"

/turf/floor/airless/orangeblack
	icon_state = "fullcaution"

/turf/floor/airless/orangewhite
	icon_state = "orangewhite"

/turf/floor/airless/orangeblack/corner
	icon_state = "cautioncorner"

/turf/floor/airless/orangeblack/corner/white
	icon_state = "cautionwhitecorner"

/////////////////////////////////////////

/turf/floor/airless/circuit
	name = "transduction matrix"
	desc = "An elaborate, faintly glowing matrix of isolinear circuitry."
	icon_state = "circuit"
	base_RL_LumR = 0
	base_RL_LumG = 0   //Corresponds to color of the icon_state.
	base_RL_LumB = 0.3
	mat_appearances_to_ignore = list("pharosium")

	New()
		plate_mat = getMaterial("pharosium")
		. = ..()

/turf/floor/airless/circuit/green
	icon_state = "circuit-green"
	base_RL_LumR = 0
	base_RL_LumG = 0.3
	base_RL_LumB = 0

/turf/floor/airless/circuit/white
	icon_state = "circuit-white"
	base_RL_LumR = 0.2
	base_RL_LumG = 0.2
	base_RL_LumB = 0.2

/turf/floor/airless/circuit/purple
	icon_state = "circuit-purple"
	base_RL_LumR = 0.1
	base_RL_LumG = 0
	base_RL_LumB = 0.2

/turf/floor/airless/circuit/red
	icon_state = "circuit-red"
	base_RL_LumR = 0.3
	base_RL_LumG = 0
	base_RL_LumB = 0

/turf/floor/airless/circuit/vintage
	icon_state = "circuit-vint1"
	base_RL_LumR = 0.1
	base_RL_LumG = 0.1
	base_RL_LumB = 0.1

/turf/floor/airless/circuit/off
	icon_state = "circuitoff"
	base_RL_LumR = 0
	base_RL_LumG = 0
	base_RL_LumB = 0

/////////////////////////////////////////

/turf/floor/airless/carpet
	name = "carpet"
	icon = 'icons/turf/carpet.dmi'
	icon_state = "red1"
	mat_appearances_to_ignore = list("cotton")
	mat_changename = 0

	New()
		plate_mat = getMaterial("cotton")
		. = ..()

	break_tile()
		..()
		icon = 'icons/turf/floors.dmi'

	burn_tile()
		..()
		icon = 'icons/turf/floors.dmi'

/turf/floor/airless/carpet/grime
	icon = 'icons/turf/floors.dmi'
	icon_state = "grimy"

/turf/floor/airless/carpet/arcade
	icon = 'icons/turf/floors.dmi'
	icon_state = "arcade_carpet"

/turf/floor/airless/carpet/arcade/half
	icon_state = "arcade_carpet_half"

/turf/floor/airless/carpet/arcade/blank
	icon_state = "arcade_carpet_blank"

/turf/floor/airless/carpet/office
	icon = 'icons/turf/floors.dmi'
	icon_state = "office_carpet"

/turf/floor/airless/carpet/office/other
	icon = 'icons/turf/floors.dmi'
	icon_state = "office_carpet2"

/////////////////////////////////////////

/turf/floor/airless/shiny
	icon_state = "shiny"

/turf/floor/airless/shiny/white
	icon_state = "whiteshiny"

/////////////////////////////////////////

/turf/floor/airless/sanitary
	icon_state = "freezerfloor"

/turf/floor/airless/sanitary/white
	icon_state = "freezerfloor2"

/turf/floor/airless/sanitary/blue
	icon_state = "freezerfloor3"

////////////////////////////////////////

/turf/floor/airless/specialroom

/turf/floor/airless/specialroom/arcade
	icon_state = "arcade"

/turf/floor/airless/specialroom/bar
	icon_state = "bar"

/turf/floor/airless/specialroom/bar/edge
	icon_state = "bar-edge"

/turf/floor/airless/specialroom/gym
	name = "boxing mat"
	icon_state = "boxing"

/turf/floor/airless/specialroom/gym/alt
	name = "gym mat"
	icon_state = "gym_mat"

/turf/floor/airless/specialroom/cafeteria
	icon_state = "cafeteria"

/turf/floor/airless/specialroom/chapel
	icon_state = "chapel"

/turf/floor/airless/specialroom/freezer
	name = "freezer floor"
	icon_state = "freezerfloor"

/turf/floor/airless/specialroom/freezer/white
	icon_state = "freezerfloor2"

/turf/floor/airless/specialroom/freezer/blue
	icon_state = "freezerfloor3"

/turf/floor/airless/specialroom/medbay
	icon_state = "medbay"

/////////////////////////////////////////

/turf/floor/airless/arrival
	icon_state = "arrival"

/turf/floor/airless/arrival/corner
	icon_state = "arrivalcorner"

/////////////////////////////////////////

/turf/floor/airless/escape
	icon_state = "escape"

/turf/floor/airless/escape/corner
	icon_state = "escapecorner"

/////////////////////////////////////////

/turf/floor/airless/delivery
	icon_state = "delivery"

/turf/floor/airless/delivery/white
	icon_state = "delivery_white"

/turf/floor/airless/delivery/caution
	icon_state = "deliverycaution"


/turf/floor/airless/bot
	icon_state = "bot"

/turf/floor/airless/bot/white
	icon_state = "bot_white"

/turf/floor/airless/bot/blue
	icon_state = "bot_blue"

/turf/floor/airless/bot/caution
	icon_state = "botcaution"

/////////////////////////////////////////

/turf/floor/airless/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000
	reinforced = TRUE
	allows_vehicles = 1

/turf/floor/airless/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"
	oxygen = 0
	nitrogen = 0.001
	temperature = TCMB

/turf/floor/airless/engine/glow
	icon_state = "engine-glow"

/turf/floor/airless/engine/glow/blue
	icon_state = "engine-blue"


/turf/floor/airless/engine/caution/south
	icon_state = "engine_caution_south"

/turf/floor/airless/engine/caution/north
	icon_state = "engine_caution_north"

/turf/floor/airless/engine/caution/west
	icon_state = "engine_caution_west"

/turf/floor/airless/engine/caution/east
	icon_state = "engine_caution_east"

/turf/floor/airless/engine/caution/westeast
	icon_state = "engine_caution_we"

/turf/floor/airless/engine/caution/corner
	icon_state = "engine_caution_corners"

/turf/floor/airless/engine/caution/corner2
	icon_state = "engine_caution_corners2"

/turf/floor/airless/engine/caution/misc
	icon_state = "engine_caution_misc"

/////////////////////////////////////////

/turf/floor/airless/caution/south
	icon_state = "caution_south"

/turf/floor/airless/caution/north
	icon_state = "caution_north"

/turf/floor/airless/caution/northsouth
	icon_state = "caution_ns"

/turf/floor/airless/caution/west
	icon_state = "caution_west"

/turf/floor/airless/caution/east
	icon_state = "caution_east"

/turf/floor/airless/caution/westeast
	icon_state = "caution_we"

/turf/floor/airless/caution/corner/se
	icon_state = "corner_east"

/turf/floor/airless/caution/corner/sw
	icon_state = "corner_west"

/turf/floor/airless/caution/corner/ne
	icon_state = "corner_neast"

/turf/floor/airless/caution/corner/nw
	icon_state = "corner_nwest"

/turf/floor/airless/caution/corner/misc
	icon_state = "floor_hazard_corners"

/turf/floor/airless/caution/misc
	icon_state = "floor_hazard_misc"

/////////////////////////////////////////

/turf/floor/airless/wood
	icon_state = "wooden-2"
	mat_appearances_to_ignore = list("wood")
	step_material = "step_wood"
	step_priority = STEP_PRIORITY_MED

	New()
		plate_mat = getMaterial("wood")
		. = ..()

/turf/floor/airless/wood/two
	icon_state = "wooden"

/turf/floor/airless/wood/three
	icon_state = "wooden-3"

/turf/floor/airless/wood/four
	icon_state = "wooden-4"
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_LOW

/////////////////////////////////////////

/turf/floor/airless/sandytile
	name = "sand-covered floor"
	icon_state = "sandytile"

/////////////////////////////////////////
/turf/floor/airless/stairs
	name = "stairs"
	icon_state = "Stairs_alone"
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

	Entered(atom/A as mob|obj)
		if (istype(A, /obj/stool/chair/comfy/wheelchair))
			var/obj/stool/chair/comfy/wheelchair/W = A
			if (!W.lying && prob(40))
				if (W.stool_user && W.stool_user.m_intent == "walk")
					return ..()
				else
					W.fall_over(src)
		..()

/turf/floor/airless/stairs/wide
	icon_state = "Stairs_wide"

/turf/floor/airless/stairs/wide/other
	icon_state = "Stairs2_wide"

/turf/floor/airless/stairs/wide/green
	icon_state = "Stairs_wide_green"

/turf/floor/airless/stairs/wide/middle
	icon_state = "stairs_middle"


/turf/floor/airless/stairs/medical
	icon_state = "medstairs_alone"

/turf/floor/airless/stairs/medical/wide
	icon_state = "medstairs_wide"

/turf/floor/airless/stairs/medical/wide/other
	icon_state = "medstairs2_wide"

/turf/floor/airless/stairs/medical/wide/middle
	icon_state = "medstairs_middle"


/turf/floor/airless/stairs/quilty
	icon_state = "quiltystair"

/turf/floor/airless/stairs/quilty/wide
	icon_state = "quiltystair2"


/turf/floor/airless/stairs/wood
	icon_state = "wood_stairs"

/turf/floor/airless/stairs/wood/wide
	icon_state = "wood_stairs2"


/turf/floor/airless/stairs/wood2
	icon_state = "wood2_stairs"

/turf/floor/airless/stairs/wood2/wide
	icon_state = "wood2_stairs2"


/turf/floor/airless/stairs/wood3
	icon_state = "wood3_stairs"

/turf/floor/airless/stairs/wood3/wide
	icon_state = "wood3_stairs2"


/turf/floor/airless/stairs/dark
	icon_state = "dark_stairs"

/turf/floor/airless/stairs/dark/wide
	icon_state = "dark_stairs_wide"

/turf/floor/airless/stairs/dark/wide2
	icon_state = "dark_stairs_wide2"

/turf/floor/airless/stairs/dark/middle
	icon_state = "dark_stairs_middle"

/////////////////////////////////////////

/turf/floor/airless/snow
	name = "snow"
	icon_state = "snow1"
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED

	New()
		..()
		if (prob(50))
			icon_state = "snow2"
		else if (prob(25))
			icon_state = "snow3"
		else if (prob(5))
			icon_state = "snow4"
		src.set_dir(pick(cardinal))

/turf/floor/airless/snow/green
	name = "snow-covered floor"
	icon_state = "snowgreen"

/turf/floor/airless/snow/green/corner
	name = "snow-covered floor"
	icon_state = "snowgreencorner"

/////////////////////////////////////////

/turf/floor/airless/sand
	name = "sand"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "sand"

	New()
		..()
		src.set_dir(pick(cardinal))

/////////////////////////////////////////

/turf/floor/airless/grass
	name = "grass"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "grass"
	mat_appearances_to_ignore = list("steel","synthrubber")
	mat_changename = 0
	mat_changedesc = 0

	New()
		plate_mat = getMaterial("synthrubber")
		. = ..()

/turf/floor/airless/grass/leafy
	icon_state = "grass_leafy"

/turf/floor/airless/grass/random
	New()
		..()
		src.set_dir(pick(cardinal))

/turf/floor/airless/grass/random/alt
	icon_state = "grass_eh"

/////////////////////////////////////////
