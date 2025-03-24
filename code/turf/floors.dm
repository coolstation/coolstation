/*
 * Hey! You!
 * Remember to mirror your changes (unless you use the [DEFINE_FLOORS] macro)
 * floors_unsimulated.dm & floors_airless.dm
 */

/turf/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	thermal_conductivity = 0.040
	heat_capacity = 225000

	turf_flags = IS_TYPE_SIMULATED | MOB_SLIP | MOB_STEP

	var/broken = 0
	var/burnt = 0
	var/has_material = TRUE
	var/plate_mat = null
	var/reinforced = FALSE
	//Stuff for the floor & wall planner undo mode that initial() doesn't resolve.
	var/roundstart_icon_state
	var/roundstart_dir
	allows_vehicles = 0

	New()
		..()
		if (has_material)
			if (isnull(plate_mat))
				plate_mat = getMaterial("steel")
			setMaterial(plate_mat)
		roundstart_icon_state = icon_state
		roundstart_dir = dir
		var/obj/plan_marker/floor/P = locate() in src
		if (P)
			src.icon = P.icon
			src.icon_state = P.icon_state
			src.icon_old = P.icon_state
			allows_vehicles = P.allows_vehicles
			var/pdir = P.dir
			SPAWN_DBG(0.5 SECONDS)
				src.set_dir(pdir)
			qdel(P)


/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=FUCK I AM TIRED OF MAPING WITH NON-PATHED FLOORS-=-=-=-*/
/*-=-=-I GUESS I'LL DO THIS FOR EVERY FUCKING FLOOR EVER-=-=-=-*/
/*-=-=-=-=-=-=-=-=-=-=WITH LOVE BY ZEWAKA=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

/////////////////////////////////////////

/turf/floor/plating
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

/turf/floor/plating/random
	New()
		..()
		if (prob(20))
			src.icon_state = pick("panelscorched", "platingdmg1", "platingdmg2", "platingdmg3")
		if (prob(2))
			make_cleanable(/obj/decal/cleanable/dirt,src)
		else if (prob(2))
			make_cleanable(/obj/decal/cleanable/dirt/dirt2,src)
		else if (prob(2))
			make_cleanable(/obj/decal/cleanable/dirt/dirt3,src)
		else if (prob(2))
			make_cleanable(/obj/decal/cleanable/dirt/dirt4,src)
		else if (prob(2))
			make_cleanable(/obj/decal/cleanable/dirt/dirt5,src)
		else if (prob(2))
			var/obj/C = pick(/obj/decal/cleanable/paper, /obj/decal/cleanable/fungus, /obj/decal/cleanable/ash,\
			/obj/decal/cleanable/molten_item, /obj/decal/cleanable/machine_debris, /obj/decal/cleanable/oil, /obj/decal/cleanable/rust)
			make_cleanable( C ,src)
		else if ((locate(/obj) in src) && prob(3))
			var/obj/C = pick(/obj/item/cable_coil/cut/small, /obj/item/brick, /obj/item/cigbutt, /obj/item/scrap, /obj/item/raw_material/scrap_metal,\
			/obj/item/spacecash, /obj/item/tile/steel, /obj/item/weldingtool, /obj/item/screwdriver, /obj/item/wrench, /obj/item/wirecutters, /obj/item/crowbar)
			new C (src)
		else if (prob(1) && prob(2)) // really rare. not "three space things spawn on destiny during first test with just prob(1)" rare.
			var/obj/C = pick(/obj/item/space_thing, /obj/item/sticker/gold_star, /obj/item/sticker/banana, /obj/item/sticker/heart,\
			/obj/item/reagent_containers/vending/bag/random, /obj/item/reagent_containers/vending/vial/random, /obj/item/clothing/mask/cigarette/random)
			new C (src)
		return

/turf/floor/plating/airless/random
	New()
		..()
		if (prob(20))
			src.icon_state = pick("panelscorched", "platingdmg1", "platingdmg2", "platingdmg3")


/////////////////////////////////////////

/turf/floor/scorched
	icon_state = "floorscorched1"

/turf/floor/scorched2
	icon_state = "floorscorched2"

/turf/floor/damaged1
	icon_state = "damaged1"
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

/turf/floor/damaged2
	icon_state = "damaged2"
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

/turf/floor/damaged3
	icon_state = "damaged3"
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

/turf/floor/damaged4
	icon_state = "damaged4"
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

/turf/floor/damaged5
	icon_state = "damaged5"
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

/////////////////////////////////////////

/turf/floor/plating
	name = "plating"
	icon_state = "plating"
	intact = 0
	layer = PLATING_LAYER

/turf/floor/plating/jen
	icon_state = "plating_jen"

/turf/floor/plating/scorched
	icon_state = "panelscorched"

/turf/floor/plating/damaged1
	icon_state = "platingdmg1"

/turf/floor/plating/damaged2
	icon_state = "platingdmg2"

/turf/floor/plating/damaged3
	icon_state = "platingdmg3"

/////////////////////////////////////////

/turf/floor/grime
	icon_state = "floorgrime"
	permadirty = 1

/////////////////////////////////////////

/turf/floor/neutral
	icon_state = "fullneutral"

/turf/floor/neutral/side
	icon_state = "neutral"

/turf/floor/neutral/corner
	icon_state = "neutralcorner"

/////////////////////////////////////////

/turf/floor/white
	icon_state = "white"

/turf/floor/white/side
	icon_state = "whitehall"

/turf/floor/white/corner
	icon_state = "whitecorner"

/turf/floor/white/checker
	icon_state = "whitecheck"

/turf/floor/white/checker2
	icon_state = "whitecheck2"

/turf/floor/white/grime
	icon_state = "floorgrime-w"
	permadirty = 1

/////////////////////////////////////////

/turf/floor/black //Okay so 'dark' is darker than 'black', So 'dark' will be named black and 'black' named grey.
	icon_state = "dark"

/turf/floor/black/side
	icon_state = "greyblack"

/turf/floor/black/corner
	icon_state = "greyblackcorner"

/turf/floor/black/grime
	icon_state = "floorgrime-b"
	permadirty = 1

/turf/floor/blackwhite
	icon_state = "darkwhite"

/turf/floor/blackwhite/corner
	icon_state = "darkwhitecorner"

/turf/floor/blackwhite/side
	icon_state = "whiteblack"

/turf/floor/blackwhite/whitegrime
	icon_state = "floorgrime_bw1"
	permadirty = 1

/turf/floor/blackwhite/whitegrime/other
	icon_state = "floorgrime_bw2"
	permadirty = 1

/////////////////////////////////////////

/turf/floor/grey
	icon_state = "fullblack"

/turf/floor/grey/side
	icon_state = "black"

/turf/floor/grey/corner
	icon_state = "blackcorner"

/turf/floor/grey/checker
	icon_state = "blackchecker"

/turf/floor/grey/blackgrime
	icon_state = "floorgrime_gb1"
	permadirty = 1

/turf/floor/grey/blackgrime/other
	icon_state = "floorgrime_gb2"
	permadirty = 1

/turf/floor/grey/whitegrime
	icon_state = "floorgrime_gw1"
	permadirty = 1

/turf/floor/grey/whitegrime/other
	icon_state = "floorgrime_gw2"
	permadirty = 1

/////////////////////////////////////////

/turf/floor/red
	icon_state = "fullred"

/turf/floor/red/side
	icon_state = "red"

/turf/floor/red/corner
	icon_state = "redcorner"

/turf/floor/red/checker
	icon_state = "redchecker"

/turf/floor/red/redblackchecker
	icon_state = "redblackchecker"

/turf/floor/redblack
	icon_state = "redblack"

/turf/floor/redblack/corner
	icon_state = "redblackcorner"

/turf/floor/redwhite
	icon_state = "redwhite"

/turf/floor/redwhite/corner
	icon_state = "redwhitecorner"

/////////////////////////////////////////

/turf/floor/blue
	icon_state = "fullblue"

/turf/floor/blue/side
	icon_state = "blue"

/turf/floor/blue/corner
	icon_state = "bluecorner"

/turf/floor/blue/checker
	icon_state = "bluechecker"


/turf/floor/blueblack
	icon_state = "blueblack"

/turf/floor/blueblack/corner
	icon_state = "blueblackcorner"

/turf/floor/bluewhite
	icon_state = "bluewhite"

/turf/floor/bluewhite/corner
	icon_state = "bluewhitecorner"

/////////////////////////////////////////

/turf/floor/darkblue
	icon_state = "fulldblue"

/turf/floor/darkblue/checker
	icon_state = "blue-dblue"

/turf/floor/darkblue/checker/other
	icon_state = "blue-dblue2"

/turf/floor/darkblue/side
	icon_state = "dblue"

/turf/floor/darkblue/corner
	icon_state = "dbluecorner"

/turf/floor/darkblue/checker
	icon_state = "dbluechecker"

/turf/floor/darkblueblack
	icon_state = "dblueblack"

/turf/floor/darkblueblack/corner
	icon_state = "dblueblackcorner"

/turf/floor/darkbluewhite
	icon_state = "dbluewhite"

/turf/floor/darkbluewhite/corner
	icon_state = "dbluewhitecorner"

/////////////////////////////////////////

/turf/floor/bluegreen
	icon_state = "blugreenfull"

/turf/floor/bluegreen/side
	icon_state = "blugreen"

/turf/floor/bluegreen/corner
	icon_state = "blugreencorner"

/////////////////////////////////////////

/turf/floor/cautionblack
	icon_state = "fullcaution"

/turf/floor/cautionblack/side
	icon_state = "caution"

/turf/floor/cautionwhite/side
	icon_state = "cautionwhite"

/turf/floor/cautionblack/corner
	icon_state = "cautioncorner"

/turf/floor/cautionwhite/corner
	icon_state = "cautionwhitecorner"

/////////////////////////////////////////

/turf/floor/green
	icon_state = "fullgreen"

/turf/floor/green/side
	icon_state = "green"

/turf/floor/green/corner
	icon_state = "greencorner"

/turf/floor/green/checker
	icon_state = "greenchecker"

/turf/floor/greenblack
	icon_state = "greenblack"

/turf/floor/greenblack/corner
	icon_state = "greenblackcorner"

/turf/floor/greenwhite
	icon_state = "greenwhite"

/turf/floor/greenwhite/corner
	icon_state = "greenwhitecorner"

/////////////////////////////////////////

/turf/floor/greenwhite/other
	icon_state = "toxshuttle"

/turf/floor/greenwhite/other/corner
	icon_state = "toxshuttlecorner"

/////////////////////////////////////////

/turf/floor/purple
	icon_state = "fullpurple"

/turf/floor/purple/side
	icon_state = "purple"

/turf/floor/purple/corner
	icon_state = "purplecorner"

/turf/floor/purple/checker
	icon_state = "purplechecker"

/turf/floor/purpleblack
	icon_state = "purpleblack"

/turf/floor/purpleblack/corner
	icon_state = "purpleblackcorner"

/turf/floor/purplewhite
	icon_state = "purplewhite"

/turf/floor/purplewhite/corner
	icon_state = "purplewhitecorner"

/////////////////////////////////////////

/turf/floor/darkpurple
	icon_state = "fulldpurple"

/turf/floor/darkpurple/side
	icon_state = "dpurple"

/turf/floor/darkpurple/checker
	icon_state = "dpurplechecker"

/turf/floor/darkpurpleblack
	icon_state = "dpurpleblack"

/turf/floor/darkpurpleblack/corner
	icon_state = "dpurpleblackcorner"

/turf/floor/darkpurplewhite
	icon_state = "dpurplewhite"

/turf/floor/darkpurplewhite/corner
	icon_state = "dpurplewhitecorner"

/////////////////////////////////////////

/turf/floor/yellow
	icon_state = "fullyellow"

/turf/floor/yellow/side
	icon_state = "yellow"

/turf/floor/yellow/corner
	icon_state = "yellowcorner"

/turf/floor/yellow/alt
	icon_state = "fullyellow_alt"

/turf/floor/yellow/checker
	icon_state = "yellowchecker"

/turf/floor/yellowblack
	icon_state = "yellowblack"

/turf/floor/yellowblack/corner
	icon_state = "yellowblackcorner"

/turf/floor/yellowwhite
	icon_state = "yellowwhite"

/turf/floor/yellowwhite/corner
	icon_state = "yellowwhitecorner"

/////////////////////////////////////////

/turf/floor/orange
	icon_state = "fullorange"

/turf/floor/orange/side
	icon_state = "orange"

/turf/floor/orange/corner
	icon_state = "orangecorner"

/turf/floor/orange/checker
	icon_state = "orangechecker"

/turf/floor/orangeblack
	icon_state = "orangeblack"

/turf/floor/orangewhite
	icon_state = "orangewhite"

/turf/floor/orangeblack/corner
	icon_state = "orangeblackcorner"

/turf/floor/orangewhite/corner
	icon_state = "orangewhitecorner"

/////////////////////////////////////////

//IT'S NOT ORANGE OKAY??

/turf/floor/tangerine
	icon_state = "fulltangerine"

/turf/floor/tangerine/side
	icon_state = "tangerine"

/turf/floor/tangerine/corner
	icon_state = "tangerinecorner"

/turf/floor/tangerineblack
	icon_state = "tangerineblack"

/turf/floor/tangerinewhite
	icon_state = "tangerinewhite"

/turf/floor/tangerineblack/corner
	icon_state = "tangerineblackcorner"

/turf/floor/tangerinewhite/corner
	icon_state = "tangerinewhitecorner"

/turf/floor/tangerinewhite/checker
	icon_state = "tangerinechecker"

	other
		dir = 4

/turf/floor/tangerineblack/checker
	icon_state = "tangerineblackchecker"

	other
		dir = 4

/////////////////////////////////////////

/turf/floor/circuit
	name = "transduction matrix"
	desc = "An elaborate, faintly glowing matrix of isolinear circuitry."
	icon_state = "circuit"
	base_RL_LumR = 0
	base_RL_LumG = 0   //Corresponds to color of the icon_state.
	base_RL_LumB = 0.3
	mat_appearances_to_ignore = list("pharosium")
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

	New()
		plate_mat = getMaterial("pharosium")
		. = ..()

/turf/floor/circuit/green
	icon_state = "circuit-green"
	base_RL_LumR = 0
	base_RL_LumG = 0.3
	base_RL_LumB = 0

/turf/floor/circuit/white
	icon_state = "circuit-white"
	base_RL_LumR = 0.2
	base_RL_LumG = 0.2
	base_RL_LumB = 0.2

/turf/floor/circuit/purple
	icon_state = "circuit-purple"
	base_RL_LumR = 0.1
	base_RL_LumG = 0
	base_RL_LumB = 0.2

/turf/floor/circuit/red
	icon_state = "circuit-red"
	base_RL_LumR = 0.3
	base_RL_LumG = 0
	base_RL_LumB = 0

/turf/floor/circuit/vintage
	icon_state = "circuit-vint1"
	base_RL_LumR = 0.1
	base_RL_LumG = 0.1
	base_RL_LumB = 0.1

/turf/floor/circuit/off
	icon_state = "circuitoff"
	base_RL_LumR = 0
	base_RL_LumG = 0
	base_RL_LumB = 0

/////////////////////////////////////////

/turf/floor/carpet
	name = "carpet"
	icon = 'icons/turf/carpet.dmi'
	icon_state = "red1"
	mat_appearances_to_ignore = list("cotton")
	mat_changename = 0
	step_material = "step_carpet"
	step_priority = STEP_PRIORITY_MED

	New()
		plate_mat = getMaterial("cotton")
		. = ..()

	break_tile()
		..()
		icon = 'icons/turf/floors.dmi'

	burn_tile()
		..()
		icon = 'icons/turf/floors.dmi'

/turf/floor/carpet/grime
	name = "cheap carpet"
	icon = 'icons/turf/floors.dmi'
	icon_state = "grimy"
	permadirty = 1

/turf/floor/carpet/office/yellow
	name = "yellow office carpet"
	icon = 'icons/turf/floors.dmi'
	icon_state = "yellowoffice"
	permadirty = 1

/turf/floor/carpet/office/hotdog
	name = "hotdog office carpet"
	icon = 'icons/turf/floors.dmi'
	icon_state = "hotdogoffice"
	permadirty = 1

/turf/floor/carpet/office
	name = "office carpet"
	icon = 'icons/turf/floors.dmi'
	icon_state = "office"
	permadirty = 1

/turf/floor/carpet/nicebrown
	name = "nice brown carpet"
	icon = 'icons/turf/floors.dmi'
	icon_state = "nicebrown"
	permadirty = 1

/turf/floor/carpet/grime2
	name = "cheap carpet"
	icon = 'icons/turf/floors.dmi'
	icon_state = "grimy2"
	permadirty = 1

	New()
		..()
		src.dir = pick(NORTH, EAST, SOUTH, WEST)

/turf/floor/carpet/grime3
	name = "cheap carpet"
	icon = 'icons/turf/floors.dmi'
	icon_state = "grimy3"
	permadirty = 1

/turf/floor/carpet/grime4
	name = "cheap carpet"
	icon = 'icons/turf/floors.dmi'
	icon_state = "grimy4"
	permadirty = 1

	New()
		..()
		src.dir = pick(NORTH, EAST, SOUTH, WEST)

/turf/floor/carpet/arcade
	icon = 'icons/turf/floors.dmi'
	icon_state = "arcade_carpet"

/turf/floor/carpet/arcade/half
	icon_state = "arcade_carpet_half"

/turf/floor/carpet/arcade/blank
	icon_state = "arcade_carpet_blank"

/turf/floor/carpet/office
	icon = 'icons/turf/floors.dmi'
	icon_state = "office_carpet"

/turf/floor/carpet/office/other
	icon = 'icons/turf/floors.dmi'
	icon_state = "office_carpet2"

/turf/floor/carpet/arcade/filthy
	icon = 'icons/turf/floors.dmi'
	icon_state = "arcade_carpet_filthy"
	permadirty = 1
	var/static/image/blacklight_image = image('icons/turf/floors.dmi',"arcade_carpet_glow")

	New()
		..()
		src.AddComponent(/datum/component/blacklight_visible, src.blacklight_image)

DEFINE_FLOORS(carpet/regalcarpet,
	name = "regal carpet";\
	icon = 'icons/turf/floors.dmi';\
	icon_state = "regal_carpet";\
	step_material = "step_carpet";\
	step_priority = STEP_PRIORITY_MED)

DEFINE_FLOORS(carpet/regalcarpet/border,
	icon_state = "regal_carpet_border")

DEFINE_FLOORS(carpet/regalcarpet/innercorner,
	icon_state = "regal_carpet_corner")

DEFINE_FLOORS(carpet/darkcarpet,
	name = "dark carpet";\
	icon = 'icons/turf/floors.dmi';\
	icon_state = "dark_carpet";\
	step_material = "step_carpet";\
	step_priority = STEP_PRIORITY_MED)

DEFINE_FLOORS(carpet/darkcarpet/border,
	icon_state = "dark_carpet_border")

DEFINE_FLOORS(carpet/darkcarpet/innercorner,
	icon_state = "dark_carpet_corner")

DEFINE_FLOORS(carpet/clowncarpet,
	name = "clown carpet";\
	icon = 'icons/turf/floors.dmi';\
	icon_state = "clown_carpet";\
	step_material = "step_carpet";\
	step_priority = STEP_PRIORITY_MED)

DEFINE_FLOORS(carpet/clowncarpet/border,
	icon_state = "clown_carpet_border")

DEFINE_FLOORS(carpet/clowncarpet/innercorner,
	icon_state = "clown_carpet_corner")

/////////////////////////////////////////

/turf/floor/shiny
	icon_state = "shiny"

/turf/floor/shiny/white
	icon_state = "whiteshiny"

/////////////////////////////////////////

/turf/floor/sanitary
	icon_state = "freezerfloor"
	clean = 1

/turf/floor/sanitary/white
	icon_state = "freezerfloor2"
	clean = 1

/turf/floor/sanitary/blue
	icon_state = "freezerfloor3"
	clean = 1

////////////////////////////////////////

DEFINE_FLOORS(terrazzo,
	name = "terrazzo tiling";\
	icon = 'icons/turf/floors.dmi';\
	icon_state = "terrazzo_beige";\
	step_material = "step_wood";\
	clean = 1;\
	step_priority = STEP_PRIORITY_MED)

DEFINE_FLOORS(terrazzo/black,
	icon_state = "terrazzo_black";\
	clean = 1)

DEFINE_FLOORS(terrazzo/white,
	icon_state = "terrazzo_white";\
	clean = 1)

/////////////////////////////////////////

DEFINE_FLOORS(marble,
	name = "marble tiling";\
	icon = 'icons/turf/floors.dmi';\
	icon_state = "marble_white";\
	step_material = "step_wood";\
	clean = 1;\
	step_priority = STEP_PRIORITY_MED)

DEFINE_FLOORS(marble/black,
	icon_state = "marble_black";\
	clean = 1)

DEFINE_FLOORS(marble/border_bw,
	icon_state = "marble_border_bw";\
	clean = 1)

DEFINE_FLOORS(marble/border_wb,
	icon_state = "marble_border_wb";\
	clean = 1)

/////////////////////////////////////////

/turf/floor/specialroom

/turf/floor/specialroom/arcade
	icon_state = "arcade"

/turf/floor/specialroom/bar
	icon_state = "bar"

/turf/floor/specialroom/bar/edge
	icon_state = "bar-edge"

/turf/floor/specialroom/gym
	name = "boxing mat"
	icon_state = "boxing"

/turf/floor/specialroom/gym/alt
	name = "gym mat"
	icon_state = "gym_mat"

/turf/floor/specialroom/cafeteria
	icon_state = "cafeteria"

/turf/floor/specialroom/chapel
	icon_state = "chapel"

/turf/floor/specialroom/freezer
	name = "freezer floor"
	icon_state = "freezerfloor"
	temperature = T0C
	clean = 1

/turf/floor/specialroom/freezer/white
	icon_state = "freezerfloor2"
	clean = 1

/turf/floor/specialroom/freezer/blue
	icon_state = "freezerfloor3"
	clean = 1

/turf/floor/specialroom/medbay
	icon_state = "medbay"
	clean = 1 //but not for long

/////////////////////////////////////////

/turf/floor/arrival
	icon_state = "arrival"

/turf/floor/arrival/corner
	icon_state = "arrivalcorner"

/////////////////////////////////////////

/turf/floor/escape
	icon_state = "escape"

/turf/floor/escape/corner
	icon_state = "escapecorner"

/////////////////////////////////////////

/turf/floor/planter
	icon_state = "PlanterCenter"

/turf/floor/planter/edges
	icon_state = "PlanterEdges"

/turf/floor/planter/strips
	icon_state = "PlanterStrips"

/////////////////////////////////////////

/turf/floor/delivery
	icon_state = "delivery"

/turf/floor/delivery/white
	icon_state = "delivery_white"

/turf/floor/delivery/caution
	icon_state = "deliverycaution"

/turf/floor/bot
	icon_state = "bot"

/turf/floor/bot/white
	icon_state = "bot_white"

/turf/floor/bot/blue
	icon_state = "bot_blue"

/turf/floor/bot/darkpurple
	icon_state = "bot_dpurple"

/turf/floor/bot/caution
	icon_state = "botcaution"

/////////////////////////////////////////

/turf/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000

	reinforced = TRUE
	allows_vehicles = 1
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

	event_handler_flags = IMMUNE_SINGULARITY_INACTIVE

/turf/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"
	oxygen = 0
	nitrogen = 0.001
	temperature = TCMB

/turf/floor/engine/glow
	icon_state = "engine-glow"

/turf/floor/engine/glow/blue
	icon_state = "engine-blue"


/turf/floor/engine/caution/south
	icon_state = "engine_caution_south"

/turf/floor/engine/caution/north
	icon_state = "engine_caution_north"

/turf/floor/engine/caution/northsouth
	icon_state = "engine_caution_ns"

/turf/floor/engine/caution/west
	icon_state = "engine_caution_west"

/turf/floor/engine/caution/east
	icon_state = "engine_caution_east"

/turf/floor/engine/caution/westeast
	icon_state = "engine_caution_we"

/turf/floor/engine/caution/corner
	icon_state = "engine_caution_corners"

/turf/floor/engine/caution/corner2
	icon_state = "engine_caution_corners2"

/turf/floor/engine/caution/misc
	icon_state = "engine_caution_misc"

/////////////////////////////////////////

/turf/floor/caution/south
	icon_state = "caution_south"

/turf/floor/caution/north
	icon_state = "caution_north"

/turf/floor/caution/northsouth
	icon_state = "caution_ns"

/turf/floor/caution/west
	icon_state = "caution_west"

/turf/floor/caution/east
	icon_state = "caution_east"

/turf/floor/caution/westeast
	icon_state = "caution_we"

/turf/floor/caution/corner/se
	icon_state = "corner_east"

/turf/floor/caution/corner/sw
	icon_state = "corner_west"

/turf/floor/caution/corner/ne
	icon_state = "corner_neast"

/turf/floor/caution/corner/nw
	icon_state = "corner_nwest"

/turf/floor/caution/corner/misc
	icon_state = "floor_hazard_corners"

/turf/floor/caution/misc
	icon_state = "floor_hazard_misc"

/////////////////////////////////////////

/turf/floor/wood
	icon_state = "wooden-2"
	mat_appearances_to_ignore = list("wood")
	step_material = "step_wood"
	step_priority = STEP_PRIORITY_MED

	New()
		plate_mat = getMaterial("wood")
		. = ..()

/turf/floor/wood/two
	icon_state = "wooden"

/turf/floor/wood/three
	icon_state = "wooden-3"

/turf/floor/wood/four
	icon_state = "wooden-4"

/turf/floor/wood/five
	icon_state = "wooden-5"

/turf/floor/wood/six
	icon_state = "wooden-6"

/turf/floor/wood/seven
	icon_state = "wooden-7"

/turf/floor/wood/eight
	icon_state = "wooden-8"

/////////////////////////////////////////

/turf/floor/sandytile
	name = "sand-covered floor"
	icon_state = "sandytile"

/////////////////////////////////////////
// manta related
/turf/floor/longtile
	icon_state = "longtile"

/turf/floor/longtile/black
	icon_state = "longtile-dark"

/turf/floor/longtile/blue
	icon_state = "longtile-blue"

/turf/floor/longtile/red
	icon_state = "longtile-red"

/turf/floor/specialroom/clown
	icon_state = "clownfloor"

/turf/floor/special
	icon_state = "waithere"

/turf/floor/special/bridgeup
	icon_state = "bridge_up"

/turf/floor/special/escapedown
	icon_state = "escape_down"

/turf/floor/special/submarinesdown
	icon_state = "submarines_down"

/turf/floor/special/submarinesup
	icon_state = "submarines_up"

/turf/floor/special/researchdown
	icon_state = "research_down"

/turf/floor/special/risingtide
	icon_state = "risingtide"
/////////////////////////////////////////
/turf/floor/stairs
	name = "stairs"
	icon_state = "Stairs_alone"

	Entered(atom/A as mob|obj)
		if (istype(A, /obj/stool/chair/comfy/wheelchair))
			var/obj/stool/chair/comfy/wheelchair/W = A
			if (!W.lying && prob(40))
				if (W.stool_user && W.stool_user.m_intent == "walk")
					return ..()
				else
					W.fall_over(src)
		..()

/turf/floor/stairs/wide
	icon_state = "Stairs_wide"

/turf/floor/stairs/wide/other
	icon_state = "Stairs2_wide"

/turf/floor/stairs/wide/green
	icon_state = "Stairs_wide_green"

/turf/floor/stairs/wide/green/other
	icon_state = "Stairs_wide_green_other"

/turf/floor/stairs/wide/middle
	icon_state = "stairs_middle"


/turf/floor/stairs/medical
	icon_state = "medstairs_alone"

/turf/floor/stairs/medical/wide
	icon_state = "medstairs_wide"

/turf/floor/stairs/medical/wide/other
	icon_state = "medstairs2_wide"

/turf/floor/stairs/medical/wide/middle
	icon_state = "medstairs_middle"


/turf/floor/stairs/quilty
	icon_state = "quiltystair"

/turf/floor/stairs/quilty/wide
	icon_state = "quiltystair2"


/turf/floor/stairs/wood
	icon_state = "wood_stairs"

/turf/floor/stairs/wood/wide
	icon_state = "wood_stairs2"


/turf/floor/stairs/wood2
	icon_state = "wood2_stairs"

/turf/floor/stairs/wood2/wide
	icon_state = "wood2_stairs2"

/turf/floor/stairs/wood2/middle
	icon_state = "wood2_stairs2_middle"

/turf/floor/stairs/wood3
	icon_state = "wood3_stairs"

/turf/floor/stairs/wood3/wide
	icon_state = "wood3_stairs2"


/turf/floor/stairs/dark
	icon_state = "dark_stairs"

/turf/floor/stairs/dark/wide
	icon_state = "dark_stairs2"

/////////////////////////////////////////

/turf/floor/Vspace
	name = "Vspace"
	icon_state = "flashyblue"
	var/network = "none"
	var/network_ID = "none"
	fullbright = 1

/turf/floor/Vspace/brig
	name = "Brig"
	icon_state = "floor"
	network = "prison"

/turf/floor/vr
	icon_state = "vrfloor"

	fourbit
		icon_state = "vrfloor16"

/turf/floor/vr/plating
	icon_state = "vrplating"

	fourbit
		icon_state = "vrplating16"

/turf/floor/vr/space
	icon_state = "vrspace"

	fourbit
		icon_state = "vrspace16"

/turf/floor/vr/white
	icon_state = "vrwhitehall"

	fourbit
		icon_state = "vrwhitehall16"

/turf/floor/airless/vr/flashy
	name = "Vspace"
	icon_state = "flashyblue"

// simulated setpieces

/turf/floor/setpieces
	icon = 'icons/misc/worlds.dmi'
	fullbright = 0
	has_material = FALSE
	turf_flags = 0 //following previous behavior at root here
	thermal_conductivity = 0.05 //taking values from /turf rather than /turf/floor
	heat_capacity = 1 //since setpieces were made with that default behavior (might be relevant maybe (just in case (but probably not)))

	bloodfloor
		name = "bloody floor"
		desc = "Yuck."
		icon_state = "bloodfloor_1"
		permadirty = 1
		reinforced = 1

	hivefloor
		name = "hive floor"
		icon = 'icons/turf/floors.dmi'
		icon_state = "hive"
		permadirty = 1

/////////////////////////////////////////

/turf/floor/snow
	name = "snow"
	icon_state = "snow1"
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED
	mat_appearances_to_ignore = list("steel")

	New()
		..()
		if (prob(50))
			icon_state = "snow2"
		else if (prob(25))
			icon_state = "snow3"
		else if (prob(5))
			icon_state = "snow4"
		src.set_dir(pick(cardinal))

/turf/floor/snow/snowball

	New()
		..()
		AddComponent(/datum/component/snowballs)

/turf/floor/snow/green
	name = "snow-covered floor"
	icon_state = "snowgreen"

/turf/floor/snow/green/corner
	name = "snow-covered floor"
	icon_state = "snowgreencorner"

DEFINE_FLOORS(snowcalm,
	name = "snow";\
	icon = 'icons/turf/floors.dmi';\
	icon_state = "snow_calm";\
	step_material = "step_outdoors";\
	step_priority = STEP_PRIORITY_MED)

DEFINE_FLOORS(snowcalm/border,
	icon_state = "snow_calm_border")

DEFINE_FLOORS(snowrough,
	name = "snow";\
	icon = 'icons/turf/floors.dmi';\
	icon_state = "snow_rough";\
	step_material = "step_outdoors";\
	step_priority = STEP_PRIORITY_MED)

DEFINE_FLOORS(snowrough/border,
	icon_state = "snow_rough_border")

/////////////////////////////////////////

/turf/floor/sand
	name = "sand"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "sand"
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED
	plate_mat = 0 //Prevents this "steel sand" bullshit but it's not a great solution
	permadirty = 1 //sand gets everywhere

	New()
		..()
		src.set_dir(pick(cardinal))

/////////////////////////////////////////

/turf/floor/industrial
	icon_state = "diamondtile"
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
	allows_vehicles = 1
	permadirty = 1

/turf/floor/industrial
	icon_state = "diamondtile"
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
	allows_vehicles = 1
	permadirty = 1

/////////////////////////////////////////

/* Animated turf - Walp */

DEFINE_FLOORS(techfloor,
	name = "data tech flooring";\
	icon = 'icons/turf/floors.dmi';\
	icon_state = "techfloor_blue";\
	step_material = "step_plating";\
	step_priority = STEP_PRIORITY_MED;\
	base_RL_LumR = 0;\
	base_RL_LumG = 0;\
	base_RL_LumB = 0.3)

DEFINE_FLOORS(techfloor/red,
	icon_state = "techfloor_red";\
	base_RL_LumR = 0.3;\
	base_RL_LumG = 0;\
	base_RL_LumB = 0)

DEFINE_FLOORS(techfloor/purple,
	icon_state = "techfloor_purple";\
	base_RL_LumR = 0.1;\
	base_RL_LumG = 0;\
	base_RL_LumB = 0.2)

DEFINE_FLOORS(techfloor/yellow,
	icon_state = "techfloor_yellow";\
	base_RL_LumR = 0.2;\
	base_RL_LumG = 0.1;\
	base_RL_LumB = 0)

DEFINE_FLOORS(techfloor/green,
	icon_state = "techfloor_green";\
	base_RL_LumR = 0;\
	base_RL_LumG = 0.3;\
	base_RL_LumB = 0)

/////////////////////////////////////////

/turf/floor/grass
	name = "grass"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "grass"
	mat_appearances_to_ignore = list("steel","synthrubber")
	mat_changename = 0
	mat_changedesc = 0
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED
	permadirty = 1

	New()
		plate_mat = getMaterial("synthrubber")
		. = ..()

/turf/proc/grassify()
	.=0

/turf/floor/grassify()
	src.icon = 'icons/turf/outdoors.dmi'
	src.icon_state = "grass"
	if(prob(30))
		src.icon_state += pick("_p", "_w", "_b", "_y", "_r", "_a")
	src.name = "grass"
	src.set_dir(pick(cardinal))
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED

/turf/floor/grassify()
	src.icon = 'icons/turf/outdoors.dmi'
	src.icon_state = "grass"
	if(prob(30))
		src.icon_state += pick("_p", "_w", "_b", "_y", "_r", "_a")
	src.name = "grass"
	src.set_dir(pick(cardinal))
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED

/turf/floor/grass/leafy
	icon_state = "grass_leafy"

/turf/floor/grass/random
	New()
		..()
		src.set_dir(pick(cardinal))

/turf/floor/grass/random/alt
	icon_state = "grass_eh" //ya grass

/turf/floor/grasstodirt
	name = "grass"
	icon = 'icons/misc/worlds.dmi'
	icon_state = "grasstodirt"
	mat_appearances_to_ignore = list("steel","synthrubber")
	mat_changename = 0
	mat_changedesc = 0
	permadirty = 1

/turf/floor/dirt
	name = "dirt"
	icon = 'icons/misc/worlds.dmi'
	icon_state = "dirt"
	mat_appearances_to_ignore = list("steel","synthrubber")
	mat_changename = 0
	mat_changedesc = 0
	permadirty = 1 //its dirt.............
	var/stone_color // runtime?????????? -warc

	//This is inherited from turf/dirt which is dead now, IDK if it's gonna be bad on here but
	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/shovel))
			if (src.icon_state == "dirt-dug")
				boutput(user, "<span class='alert'>That is already dug up! Are you trying to dig through to China or something?  That would be even harder than usual, seeing as you are in space.</span>")
				return

			user.visible_message("<b>[user]</b> begins to dig!", "You begin to dig!")
			//todo: A digging sound effect.
			if (do_after(user, 4 SECONDS) && src.icon_state != "dirt-dug")
				src.icon_state = "dirt-dug"
				user.visible_message("<b>[user]</b> finishes digging.", "You finish digging.")
				for (var/obj/tombstone/grave in orange(src, 1))
					if (istype(grave) && !grave.robbed)
						grave.robbed = 1
						//idea: grave robber medal.
						if (grave.special)
							new grave.special (src)
						else
							switch (rand(1,3))
								if (1)
									new /obj/item/skull {desc = "A skull.  That was robbed.  From a grave.";} ( src )
								if (2)
									new /obj/item/plank {name = "rotted coffin wood"; desc = "Just your normal, everyday rotten wood.  That was robbed.  From a grave.";} ( src )
								if (3)
									new /obj/item/clothing/under/suit/pinstripe {name = "old pinstripe suit"; desc  = "A pinstripe suit.  That was stolen.  Off of a buried corpse.";} ( src )
						break

		else
			return ..()

/////////////////////////////////////////

/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-FUCK THAT SHIT MY WRIST HURTS=-=-=-=-=-=-=-=-=*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */


/turf/floor/plating/airless
	name = "airless plating"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB
	//fullbright = 1
	allows_vehicles = 1

	New()
		..()
		name = "plating"

/turf/floor/plating/airless/shuttlebay
	name = "shuttle bay plating"
	icon_state = "engine"
	allows_vehicles = 1
	reinforced = TRUE

/turf/floor/shuttlebay
	name = "shuttle bay plating"
	icon_state = "engine"
	allows_vehicles = 1
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
	reinforced = TRUE

/turf/floor/metalfoam
	icon = 'icons/turf/floors.dmi'
	icon_state = "metalfoam"
	var/metal = 1
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB
	intact = 0
	layer = PLATING_LAYER
	allows_vehicles = 1 // let the constructor pods move around on these
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

	desc = "A flimsy foamed metal floor."

/turf/floor/blob
	name = "blob floor"
	desc = "Blob floors to lob blobs over."
	icon = 'icons/mob/blob.dmi'
	icon_state = "bridge"
	default_melt_cap = 80
	allows_vehicles = 1

	New()
		plate_mat = getMaterial("blob")
		. = ..()

	proc/setHolder(var/datum/abilityHolder/blob/AH)
		if (!material)
			setMaterial(getMaterial("blob"))
		material.color = AH.color
		color = AH.color

	attackby(var/obj/item/W, var/mob/user)
		if (isweldingtool(W))
			visible_message("<b>[user] hits [src] with [W]!</b>")
			if (prob(25))
				ReplaceWithSpace()

	ex_act(severity)
		if (prob(33))
			..(max(severity - 1, 1))
		else
			..(severity)

	burn_tile()
		return

// metal foam floors

/turf/floor/metalfoam/update_icon()
	if(metal == 1)
		icon_state = "metalfoam"
	else
		icon_state = "ironform"

/turf/floor/metalfoam/ex_act()
	ReplaceWithSpace()

/turf/floor/metalfoam/attackby(obj/item/C as obj, mob/user as mob)

	if(!C || !user)
		return 0
	if (istype(C, /obj/item/tile))
		var/obj/item/tile/T = C
		if (T.amount >= 1)
			playsound(src, "sound/impact_sounds/Generic_Stab_1.ogg", 50, 1)
			T.build(src)
		return

	if(prob(75 - metal * 25))
		ReplaceWithSpace()
		boutput(user, "You easily smash through the foamed metal floor.")
	else
		boutput(user, "Your attack bounces off the foamed metal floor.")

/turf/floor/CanPass(atom/movable/mover, turf/target)
	if (!src.allows_vehicles && (istype(mover, /obj/machinery/vehicle) && !istype(mover,/obj/machinery/vehicle/tank)))
		if (!( locate(/obj/machinery/mass_driver, src) ))
			return 0
	return ..()

/turf/shuttle/CanPass(atom/movable/mover, turf/target)
	if (!src.allows_vehicles && (istype(mover, /obj/machinery/vehicle) && !istype(mover,/obj/machinery/vehicle/tank)))
		return 0
	return ..()

/turf/floor/burn_down()
	src.ex_act(OLD_EX_HEAVY)

/turf/floor/ex_act(severity)
	if (!isconstructionturf(src)) return
	switch(severity)
		if(OLD_EX_SEVERITY_1)
			src.ReplaceWithSpace()

		if(OLD_EX_SEVERITY_2)
			switch(pick(1,2;75,3))
				if (1)
					if(prob(33))
						var/obj/item/I = new /obj/item/raw_material/scrap_metal()
						I.set_loc(src)
						if (src.material)
							I.setMaterial(src.material)
						else
							I.setMaterial(getMaterial("steel"))
					src.ReplaceWithLattice()
				if(2)
					src.ReplaceWithSpace()
				if(3)
					if(prob(33))
						var/obj/item/I = new /obj/item/raw_material/scrap_metal()
						I.set_loc(src)
						if (src.material)
							I.setMaterial(src.material)
						else
							I.setMaterial(getMaterial("steel"))
					if(prob(80))
						src.break_tile_to_plating()
					else
						src.break_tile()
					src.hotspot_expose(1000,CELL_VOLUME)
		if(OLD_EX_SEVERITY_3)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME)
	return

/turf/floor/blob_act(var/power)
	return

//turf/proc/ReplaceWith used to go "istype(src, /turf/floor)" and IDK if you're gonna check that on every turf maybe just split it off
/turf/floor/ReplaceWith(var/what, var/keep_old_material = 1, var/handle_air = 1, handle_dir = 1, force = 0)
	icon_old = icon_state
	name_old = name
	. = ..()

/turf/floor/proc/update_icon()

/turf/attack_hand(mob/user as mob)
	if (src.density == 1)
		return
	if (!user.canmove || user.restrained())
		return
	if (!user.pulling || user.pulling.anchored || (user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		//get rid of click delay since we didn't do anything
		user.next_click = world.time
		return
	//duplicate user.pulling for RTE fix
	if (user.pulling && user.pulling.loc == user)
		user.pulling = null
		return
	//if the object being pulled's loc is another object (being in their contents) return
	if (isobj(user.pulling.loc))
		var/obj/container = user.pulling.loc
		if (user.pulling in container.contents)
			return

	var/turf/fuck_u = user.pulling.loc
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/mob/t = M.pulling
		M.pulling = null
		step(M, get_dir(fuck_u, src))
		M.pulling = t
	else
		step(user.pulling, get_dir(fuck_u, src))
	return

/turf/floor/proc/to_plating(var/force_break)
	if(!force_break)
		if(src.reinforced) return
	if(!intact) return
	if (!icon_old)
		icon_old = icon_state
	if (!name_old)
		name_old = name
	src.name = "plating"
	src.icon_state = "plating"
	setIntact(FALSE)
	broken = 0
	burnt = 0
	if(plate_mat)
		src.setMaterial((plate_mat))
	else
		src.setMaterial(getMaterial("steel"))
	levelupdate()

/turf/floor/proc/dismantle_wall()//can get called due to people spamming weldingtools on walls
	return

/turf/floor/proc/take_hit()// can get called due to people crumpling cardboard walls
	return

/turf/floor/proc/break_tile_to_plating()
	if(intact)
		to_plating()
		if(!src.reinforced && prob(25))
			new /obj/decal/floatingtiles/loose/random(src)
	break_tile()

/turf/floor/proc/break_tile(var/force_break)
	if(!force_break)
		if(src.reinforced) return

	if(broken) return
	if (!icon_old)
		icon_old = icon_state
	if(intact)
		src.icon_state = "damaged[pick(1,2,3,4,5)]"
		broken = 1
	else
		src.icon_state = "platingdmg[pick(1,2,3)]"
		broken = 1

/turf/floor/proc/burn_tile()
	if(broken || burnt || reinforced) return
	if (!icon_old)
		icon_old = icon_state
	if(intact)
		src.icon_state = "floorscorched[pick(1,2)]"
	else
		src.icon_state = "panelscorched"
	burnt = 1

/turf/floor/shuttle/burn_tile()
	return

/turf/floor/proc/restore_tile()
	if(intact) return
	setIntact(TRUE)
	broken = 0
	burnt = 0
	icon = initial(icon)
	if(icon_old)
		icon_state = icon_old
	else
		icon_state = "floor"
	if (name_old)
		name = name_old
	levelupdate()

/turf/floor/var/global/girder_egg = 0

//basically the same as walls.dm sans the
/turf/floor/proc/attach_light_fixture_parts(var/mob/user, var/obj/item/W, var/instantly)
	if (!user || !istype(W, /obj/item/light_parts/floor))
		return

	// the wall is the target turf, the source is the turf where the user is standing
	var/obj/item/light_parts/parts = W
	var/turf/target = src

	if(!instantly)
		playsound(src, "sound/items/Screwdriver.ogg", 50, 1)
		boutput(user, "You begin to attach the light fixture to [src]...")


		if (!do_after(user, 4 SECONDS))
			user.show_text("You were interrupted!", "red")
			return

		if (!parts) //ZeWaka: Fix for null.fixture_type
			return

		// if they didn't move, put it up
		boutput(user, "You attach the light fixture to [src].")

	var/obj/machinery/light/newlight = new parts.fixture_type(target)
	newlight.icon_state = parts.installed_icon_state
	newlight.base_state = parts.installed_base_state
	newlight.fitting = parts.fitting
	newlight.status = 1 // LIGHT_EMPTY

	newlight.add_fingerprint(user)
	src.add_fingerprint(user)

	user.u_equip(parts)
	qdel(parts)
	return

/turf/floor/proc/pry_tile(obj/item/C as obj, mob/user as mob, params)
	if(!isconstructionturf(src))
		return
	if (!intact)
		return
	if(src.reinforced)
		boutput(user, "<span class='alert'>You can't pry apart reinforced flooring! You'll have to loosen it with a welder or wrench instead.</span>")
		return

	if(broken || burnt)
		boutput(user, "<span class='alert'>You remove the broken plating.</span>")
	else
		var/atom/A = new /obj/item/tile(src)
		if(src.material)
			A.setMaterial(src.material)
		else
			A.setMaterial(getMaterial("steel"))
		.= A //return tile for crowbar special attack ok

	to_plating()
	playsound(src, "sound/items/Crowbar.ogg", 80, 1)

/turf/floor/levelupdate()
	..()
	if (!src.intact && src.turf_persistent.hidden_contents)
		for(var/atom/movable/AM as anything in src.turf_persistent.hidden_contents)
			AM.set_loc(src)
			SEND_SIGNAL(AM, COMSIG_MOVABLE_FLOOR_REVEALED, src)
		qdel(src.turf_persistent.hidden_contents) //it's an obj, see the definition for crime justification
		src.turf_persistent.hidden_contents = null


/turf/floor/attackby(obj/item/C as obj, mob/user as mob, params)

	if (!C || !user)
		return 0

	if (ispryingtool(C))
		src.pry_tile(C,user,params)
		return

	if (istype(C, /obj/item/pen))
		var/obj/item/pen/P = C
		P.write_on_turf(src, user, params)
		return

	if (istype(C, /obj/item/light_parts/floor))
		src.attach_light_fixture_parts(user, C) // Made this a proc to avoid duplicate code (Convair880).
		return

	if (src.reinforced && ((isweldingtool(C) && C:try_weld(user,0,-1,0,1)) || iswrenchingtool(C)))
		boutput(user, "<span class='notice'>Loosening rods...</span>")
		if(iswrenchingtool(C))
			playsound(src, "sound/items/Ratchet.ogg", 80, 1)
		if(do_after(user, 3 SECONDS))
			if(!src.reinforced)
				return
			var/obj/R1 = new /obj/item/rods(src)
			var/obj/R2 = new /obj/item/rods(src)
			if (material)
				R1.setMaterial(material)
				R2.setMaterial(material)
			else
				R1.setMaterial(getMaterial("steel"))
				R2.setMaterial(getMaterial("steel"))
			ReplaceWithFloor()
			src.to_plating()
			return

	if (isconstructionturf(src))
		//several things that build stuff
		if(istype(C, /obj/item/rods))
			if (!src.intact)
				if (C:amount >= 2)
					boutput(user, "<span class='notice'>Reinforcing the floor...</span>")
					if(do_after(user, 3 SECONDS))
						ReplaceWithEngineFloor()

						if (C)
							C.change_stack_amount(-2)
							if (C:amount <= 0)
								qdel(C) //wtf

							if (C.material)
								src.setMaterial(C.material)

						playsound(src, "sound/items/Deconstruct.ogg", 80, 1)
				else
					boutput(user, "<span class='alert'>You need more rods.</span>")
			else
				boutput(user, "<span class='alert'>You must remove the plating first.</span>")
			return

		if(istype(C, /obj/item/tile))
			var/obj/item/tile/T = C
			if(intact)
				var/obj/P = user.find_tool_in_hand(TOOL_PRYING)
				if (!P)
					return
				// Call ourselves w/ the tool, then continue
				src.Attackby(P, user)

			// Don't replace with an [else]! If a prying tool is found above [intact] might become 0 and this runs too, which is how floor swapping works now! - BatElite
			if (!intact)
				for(var/obj/decal/floatingtiles/loose/L in src.contents)
					if(istype(L))
						boutput(usr, "<span class='notice'>you need to clear the existing tile fragments.</span>")
						return

				restore_tile()
				src.plate_mat = src.material
				if(C.material)
					src.setMaterial(C.material)
				playsound(src, "sound/impact_sounds/Generic_Stab_1.ogg", 50, 1)

				if(!istype(src.material, /datum/material/metal/steel))
					logTheThing("station", user, null, "constructs a floor (<b>Material:</b>: [src.material && src.material.name ? "[src.material.name]" : "*UNKNOWN*"]) at [log_loc(src)].")

				T.change_stack_amount(-1)
				//if(T && (--T.amount < 1))
				//	qdel(T)
				//	return


		if(istype(C, /obj/item/sheet))
			if (!(C?.material?.material_flags & (MATERIAL_METAL | MATERIAL_CRYSTAL))) return
			if (!C:amount_check(2,user)) return

			var/msg = "a girder"

			if(!girder_egg)
				var/count = 0
				for(var/obj/structure/girder in src)
					count++
				var/static/list/insert_girder = list(
				"a girder",
				"another girder",
				"yet another girder",
				"oh god it's another girder",
				"god save the queen its another girder",
				"sweet christmas its another girder",
				"the 6th girder",
				"you're not sure but you think it's a girder",
				"um... ok. a girder, I guess",
				"what does girder even mean, anyway",
				"the strangest girder",
				"the girder that confuses you",
				"the metallic support frame",
				"a very untrustworthy girder",
				"the \"i'm concerned about the sheer number of girders\" girder",
				"a broken wall",
				"the 16th girder",
				"the 17th girder",
				"the 18th girder",
				"the 19th girder",
				"the 20th century girder",
				"the 21th girder",
				"the mfin girder coming right atcha",
				"the girder you cant believe is a girder",
				"rozenkrantz \[sic?\] and girderstein",
				"a.. IS THAT?! no, just a girder",
				"a gifter",
				"a shitty girder",
				"a girder potato",
				"girded loins",
				"the platonic ideal of stacked girders",
				"a complete goddamn mess of girders",
				"FUCK",
				"a girder for ants",
				"a girder of a time",
				"a girder girder girder girder girder girder girder girder girder girder girder girder.. mushroom MUSHROOM",
				"an attempted girder",
				"a failed girder",
				"a girder most foul",
				"a girder who just wants to be a wall",
				"a human child",//40
				"ett gürdür",
				"a girdle",
				"a g--NOT NOW MOM IM ALMOST AT THE 100th GIRDER--irder",
				"a McGirder",
				"a Double Cheesegirder",
				"an egg salad",
				"the ugliest damn girder you've ever seen in your whole fucking life",
				"the most magnificent goddamn girder that you've ever seen in your entire fucking life",
				"the constitution of the old republic, and also a girder",
				"a waste of space, which is crazy when you consider where you built this",//50
				"pure girder vibrations",
				"a poo containment girder",
				"an extremely solid girder, your parents would be proud",
				"the girder who informs you to the authorities",
				"a discount girder",
				"a counterfeit girder",
				"a construction",
				"readster's very own girder",
				"just a girder",
				"a gourder",//60
				"a fuckable girder",
				"a herd of girders",
				"an A.D.G.S",
				"the... thing",
				"the.. girder?",
				"a girder. one that girds if you girder it.",
				"the frog(?)",
				"the unstable relationship",
				"nice",
				"the girder egg")
				msg = insert_girder[min(count+1, insert_girder.len)]
				if(count >= 70)
					girder_egg = 1
					actions.start(new /datum/action/bar/icon/build(C, /obj/item/reagent_containers/food/snacks/ingredient/egg/critter/townguard/passive, 2, null, 1, 'icons/obj/structures.dmi', "girder egg", msg, null), user)
				else
					actions.start(new /datum/action/bar/icon/build(C, /obj/structure/girder, 2, C:material, 1, 'icons/obj/structures.dmi', "girder", msg, null, spot = src), user)
			else
				actions.start(new /datum/action/bar/icon/build(C, /obj/structure/girder, 2, C:material, 1, 'icons/obj/structures.dmi', "girder", msg, null, spot = src), user)


		if(istype(C, /obj/item/cable_coil))
			if(!intact)
				var/obj/item/cable_coil/coil = C
				coil.turf_place(src, get_turf(user), user)
			else
				boutput(user, "<span class='alert'>You must remove the plating first.</span>")

//grabsmash??
	if (istype(C, /obj/item/grab/))
		var/obj/item/grab/G = C
		if  (!grab_smash(G, user))
			return ..(C, user)
		else
			return

	// hi i don't know where else to put this :D - cirr
	else if (istype(C, /obj/item/martianSeed))
		var/obj/item/martianSeed/S = C
		if(S)
			S.plant(src)
			logTheThing("station", user, null, "plants a martian biotech seed (<b>Structure:</b> [S.spawn_path]) at [log_loc(src)].")
			return

	//also in turf.dm. Put this here for lowest priority.
	else if (src.temp_flags & HAS_KUDZU)
		var/obj/spacevine/K = locate(/obj/spacevine) in src.contents
		if (K)
			K.Attackby(C, user, params)

	else if (!user.pulling || user.pulling.anchored || (user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1)) // this seemed like the neatest way to make attack_hand still trigger when needed
		src.material?.triggerOnHit(src, C, user, 1)
	else
		return attack_hand(user)


/turf/floor/proc/hide_inside(atom/movable/AM)
	if (!src.turf_persistent.hidden_contents)
		src.turf_persistent.hidden_contents = new(src)
	AM.set_loc(src.turf_persistent.hidden_contents)

/turf/floor/MouseDrop_T(atom/A, mob/user as mob)
	..(A,user)
	if(istype(A,/turf/floor))
		var/turf/floor/F = A
		var/obj/item/I = user.equipped()
		if(I)
			if(istype(I,/obj/item/cable_coil))
				var/obj/item/cable_coil/C = I
				if((get_dist(user,F)<2) && (get_dist(user,src)<2))
					C.move_callback(user, F, src)

/turf/floor/restore_tile()
	..()
	for (var/obj/item/item in src.contents)
		if (item.w_class <= W_CLASS_TINY && !item.anchored) //I wonder if this will cause problems
			src.hide_inside(item)

///CRIME
/obj/effects/hidden_contents_holder
	name = ""
	desc = ""
	icon = null
	anchored = ANCHORED_ALWAYS
	invisibility = INVIS_ALWAYS
	alpha = 0

	set_loc(newloc)
		if (!isnull(newloc))
			return
		. = ..()


////////////////////////////////////////////ADVENTURE SIMULATED FLOORS////////////////////////
DEFINE_FLOORS_SIMMED_UNSIMMED(racing,
	icon = 'icons/misc/racing.dmi';\
	icon_state = "track_1")

DEFINE_FLOORS_SIMMED_UNSIMMED(racing/edge,
	icon = 'icons/misc/racing.dmi';\
	icon_state = "track_2")

DEFINE_FLOORS_SIMMED_UNSIMMED(racing/rainbow_road,
	icon = 'icons/misc/racing.dmi';\
	icon_state = "rainbow_road")

//////////////////////////////////////////////UNSIMULATED//////////////////////////////////////

/////////////////////// cogwerks - setpiece stuff

/turf/wall/setpieces
	icon = 'icons/misc/worlds.dmi'
	fullbright = 0
	material = null

	bloodwall
		name = "bloody wall"
		desc = "Gross."
		icon = 'icons/misc/meatland.dmi'
		icon_state = "bloodwall_1"

	leadwall
		name = "shielded wall"
		desc = "Seems pretty sturdy."
		icon_state = "leadwall"

		junction
			icon_state = "leadjunction"

		junction_four
			icon_state = "leadjunction_4way"

		cap
			icon_state = "leadcap"

		gray
			icon_state = "leadwall_gray"

		white
			name = "Microwave Power Transmitter"
			desc = "The outer shell of some large microwave array thing."
			icon_state = "leadwall_white"

		white_2
			icon_state = "leadwall_white"

			junction
				name = "shielded wall"
				desc
				icon_state = "leadjunction_white"

			junction_four
				icon_state = "leadjunction_white_4way"

	leadwindow
		name = "shielded window"
		desc = "Seems pretty sturdy."
		icon_state = "leadwindow_1"
		opacity = 0

		full
			icon_state = "leadwindow_2"

		gray
			icon_state = "leadwindow_gray_1"

		white
			icon_state = "leadwindow_white_1"

			full
				icon_state = "leadwindow_white_2"

	rootwall
		name = "overgrown wall"
		desc = "This wall is covered in vines."
		icon_state = "rootwall"

	bluewall
		name = "blue wall"
		desc = "This doesn't look normal at all."
		icon_state = "bluewall"

	bluewall_glowing
		name = "glowing wall"
		desc = "It seems to be humming slightly. Huh."
		luminosity = 2
		icon_state = "bluewall_glow"
		can_replace_with_stuff = 1

		attackby(obj/item/W as obj, mob/user as mob)
			if (istype(W, /obj/item/device/key))
				playsound(src, "sound/effects/mag_warp.ogg", 50, 1)
				src.visible_message("<span class='notice'><b>[src] slides away!</b></span>")
				src.ReplaceWithSpace() // make sure the area override says otherwise - maybe this sucks

	hive
		name = "hive wall"
		desc = "Honeycomb's big, yeah yeah yeah."
		icon = 'icons/turf/walls.dmi'
		icon_state = "hive"

	stranger
		name = "stranger wall"
		desc = "A weird jet black metal wall indented with strange grooves and lines."
		icon = 'icons/turf/walls.dmi'
		icon_state = "ancient"


// -------------------- VR --------------------
/turf/floor/setpieces/gauntlet
	name = "Gauntlet Floor"
	desc = "Artist needs effort badly."
	icon = 'icons/effects/VR.dmi'
	icon_state = "gauntfloorDefault"

	burn_down()
		return //no graphics


/turf/wall/setpieces/gauntlet
	name = "Gauntlet Wall"
	desc = "Is this retro? Thank god it's not team ninja."
	icon = 'icons/effects/VR.dmi'
	icon_state = "gauntwall"
// --------------------------------------------

/turf/floor/setpieces
	icon = 'icons/misc/worlds.dmi'
	fullbright = 0

	ancient_pit
		reinforced = 1
		name = "broken staircase"
		desc = "You can't see the bottom."
		icon_state = "black"
		var/falltarget = LANDMARK_FALL_ANCIENT

		New()
			. = ..()
			src.AddComponent(/datum/component/pitfall/target_landmark,\
				BruteDamageMax = 50,\
				HangTime = 0 SECONDS,\
				TargetLandmark = src.falltarget)

		shaft
			name = "Elevator Shaft"
			falltarget = LANDMARK_FALL_BIO_ELE

			Entered(atom/A as mob|obj)
				if (istype(A, /mob) && !istype(A, /mob/dead))
					bioele_accident()
				..()

		hole_xy
			name = "deep pit"
			falltarget = LANDMARK_FALL_DEBUG

	bloodfloor
		name = "bloody floor"
		desc = "Yuck."
		icon_state = "bloodfloor_1"

	rootfloor
		name = "overgrown floor"
		desc = "This floor is covered in vines."
		icon_state = "rootfloor_1"

	oldfloor
		name = "floor"
		desc = "Looks a bit different."
		icon_state = "old_floor1"

	bluefloor
		name = "blue floor"
		desc = "This floor looks awfully strange."
		icon_state = "bluefloor"

		pit
			name = "ominous pit"
			desc = "You can't see the bottom."
			icon_state = "deeps"

			New()
				. = ..()
				src.AddComponent(/datum/component/pitfall/target_landmark,\
					BruteDamageMax = 50,\
					HangTime = 0 SECONDS,\
					TargetLandmark = LANDMARK_FALL_DEEP)

	hivefloor
		name = "hive floor"
		desc = ""
		icon = 'icons/turf/floors.dmi'
		icon_state = "hive"

	swampgrass
		name = "reedy grass"
		desc = ""
		icon = 'icons/misc/worlds.dmi'
		icon_state = "swampgrass"

		New()
			..()
			set_dir(pick(1,2,4,8))
			return

	swampgrass_edging
		name = "reedy grass"
		desc = ""
		icon = 'icons/misc/worlds.dmi'
		icon_state = "swampgrass_edge"

//I think during the whole area based sims thing I lost a bunch of these auto turfs
//so I copied this whole section over from Harmony (where I didn't touch them anyway) - hopefully they're not broken :)
#define FLOOR_AUTO_EDGE_PRIORITY_DIRT 50
#define FLOOR_AUTO_EDGE_PRIORITY_GRASS 100
#define FLOOR_AUTO_EDGE_PRIORITY_WATER 200

/turf/floor/auto
	name = "auto edging turf"

	///turf won't draw edges on turfs with higher or equal priority
	var/edge_priority_level = 0
	var/icon_state_edge = null

	New()
		. = ..()
		src.layer += src.edge_priority_level / 1000
		SPAWN_DBG(0.5 SECONDS) //give neighbors a chance to spawn in
			edge_overlays()

/turf/floor/auto/proc/edge_overlays()
	for (var/turf/T in orange(src,1))
		if (istype(T, /turf/floor/auto))
			var/turf/floor/auto/TA = T
			if (TA.edge_priority_level >= src.edge_priority_level)
				continue
		var/direction = get_dir(T,src)
		var/image/edge_overlay = image(src.icon, "[icon_state_edge][direction]")
		edge_overlay.appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_COLOR | RESET_ALPHA
		edge_overlay.layer = src.layer + (src.edge_priority_level / 1000)
		edge_overlay.plane = PLANE_FLOOR
		T.UpdateOverlays(edge_overlay, "edge_[direction]")

/turf/floor/auto/grass/swamp_grass
	name = "swamp grass"
	desc = "Grass. In a swamp. Truly fascinating."
	icon = 'icons/turf/forest.dmi'
	icon_state = "grass1"
	edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_GRASS
	icon_state_edge = "grassedge"

	New()
		. = ..()
		src.icon_state = "grass[rand(1,9)]"

/turf/floor/auto/grass/leafy
	name = "grass"
	desc = "some leafy grass."
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "grass_leafy"
	edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_GRASS - 1
	icon_state_edge = "grass_leafyedge"

/turf/floor/auto/dirt
	name = "dirt"
	desc = "earth."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "dirt"
	edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_DIRT
	icon_state_edge = "dirtedge"

/turf/floor/auto/sand
	name = "sand"
	desc = "finest earth."
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "sand_other"
	edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_DIRT + 1
	icon_state_edge = "sand_edge"
	var/tuft_prob = 2

	New()
		..()
		src.set_dir(pick(cardinal))

		if(prob(tuft_prob))
			var/rand_x = rand(-5,5)
			var/rand_y = rand(-5,5)
			var/image/tuft
			var/hue_shift = rand(80,95)

			tuft = image('icons/turf/outdoors.dmi', "grass_tuft", src, pixel_x=rand_x, pixel_y=rand_y)
			tuft.color = hsv_transform_color_matrix(h=hue_shift)
			UpdateOverlays(tuft,"grass_turf")

	rough
		tuft_prob = 0.8
		New()
			..()
			icon_state_edge = "sand_r_edge"
			edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_DIRT + 2
			switch(rand(1,3))
				if(1)
					icon_state = "sand_other_texture"
					src.set_dir(pick(alldirs))
				if(2)
					icon_state = "sand_other_texture2"
					src.set_dir(pick(alldirs))
				if(3)
					icon_state = "sand_other_texture3"


/turf/floor/auto/water
	name = "water"
	desc = "Who knows what could be hiding in there."
	icon = 'icons/turf/water.dmi'
	icon_state = "swamp0"
	edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_WATER
	icon_state_edge = "swampedge"

	New()
		. = ..()
		if (prob(8))
			src.icon_state = "swamp[rand(1, 4)]"


/turf/floor/auto/water/ice
	name = "ice"
	desc = "Frozen water."
	icon = 'icons/turf/water.dmi'
	icon_state = "ice"
	icon_state_edge = "ice_edge"
	mat_appearances_to_ignore = list("ice")

	New()
		..()
		setMaterial(getMaterial("ice"))
		name = initial(name)

/turf/floor/auto/water/ice/rough
	name = "ice"
	desc = "Rough frozen water."
	icon = 'icons/turf/floors.dmi'
	icon_state = "ice1"

	New()
		..()
		src.icon_state = "ice[rand(1, 6)]"

	edge_overlays()
		return

/turf/floor/auto/swamp
	name = "swamp"
	desc = "Who knows what could be hiding in there."
	icon = 'icons/turf/water.dmi'
	icon_state = "swamp0"
	edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_WATER
	icon_state_edge = "swampedge"

	New()
		. = ..()
		if (prob(10))
			src.icon_state = "swamp_decor[rand(1, 10)]"
		else
			src.icon_state = "swamp0"

/turf/floor/auto/swamp/rain
	New()
		. = ..()
		var/image/R = image('icons/turf/water.dmi', "ripple", dir=pick(alldirs),pixel_x=rand(-10,10),pixel_y=rand(-10,10))
		R.alpha = 180
		src.UpdateOverlays(R, "ripple")
/* Okay these don't have their dmi I'm guessing they're too new
/turf/floor/auto/snow
	name = "snow"
	desc = "Snow. Soft and fluffy."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow1"
	edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_GRASS + 1
	icon_state_edge = "snow_edge"
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED

	New()
		. = ..()
		if(src.type == /turf/floor/auto/snow && prob(10))
			src.icon_state = "snow[rand(1,5)]"

/turf/floor/auto/snow/rough
	name = "snow"
	desc = "some piled snow."
	icon =  'icons/turf/snow.dmi'
	icon_state = "snow_rough1"
	edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_GRASS + 2
	icon_state_edge = "snow_r_edge"

	New()
		. = ..()
		if(prob(10))
			src.icon_state = "snow_rough[rand(1,3)]"
*/
#undef FLOOR_AUTO_EDGE_PRIORITY_DIRT
#undef FLOOR_AUTO_EDGE_PRIORITY_GRASS
#undef FLOOR_AUTO_EDGE_PRIORITY_WATER
