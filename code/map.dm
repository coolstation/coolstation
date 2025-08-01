
#define MAP_SPAWN_SHUTTLE 1
#define MAP_SPAWN_CRYO 2
#define MAP_SPAWN_MISSILE 3
//Todo - merge with MAP_SPAWN_SHUTTLE, maps need retrofits
#define MAP_SPAWN_SHUTTLE_DYNAMIC 4 //(most) crew spawns on the arrivals shuttle, which docks with the station at some point

#define MAP_NAME_RANDOM 1

var/global/map_setting = null
var/global/datum/map_settings/map_settings = null

//id corresponds to the name of the /obj/landmark/map
//playerPickable defines whether the map can be chosen by players when voting on a new map. Setting to ASS_JAM should allow it on the 13th only, and not on RP.
var/global/list/mapNames = list(
	"Clarion" = 		list("id" = "CLARION", 		"settings" = "destiny/clarion", "playerPickable" = 1,		"MaxPlayersAllowed" = 80),
#ifdef RP_MODE
	"Cogmap 1" = 		list("id" = "COGMAP", 		"settings" = "cogmap", 			"playerPickable" = 1, 	"MinPlayersAllowed" = 14),
#else
	"Cogmap 1" = 		list("id" = "COGMAP", 		"settings" = "cogmap", 			"playerPickable" = 1,		"MaxPlayersAllowed" = 80),
#endif
	//"Construction" = 	list("id" = "CONSTRUCTION", "settings" = "construction"),
	"Cogmap 1 (Old)" = 	list("id" = "COGMAP_OLD", 	"settings" = "cogmap_old"),
	"Cogmap 2" = 		list("id" = "COGMAP2", 		"settings" = "cogmap2", 		"playerPickable" = 1, 		"MinPlayersAllowed" = 40),
	"Destiny" = 		list("id" = "DESTINY", 		"settings" = "destiny", 		"playerPickable" = 1,		"MaxPlayersAllowed" = 80),
	"Donut 2" = 		list("id" = "DONUT2", 		"settings" = "donut2",			"playerPickable" = 1),
	"Donut 3" = 		list("id" = "DONUT3", 		"settings" = "donut3",			"playerPickable" = 0, 		"MinPlayersAllowed" = 40),
	"Horizon" = 		list("id" = "HORIZON", 		"settings" = "horizon", 		"playerPickable" = 0),
	"The Crag"=			list("id" = "CRAG",			"settings" = "crag", 			"playerPickable" = 1),
	"Gehenna Colony" = 	list("id" = "GEHENNA",		"settings" = "gehenna",			"playerPickable" = 1),
	"The Chunk" =	 	list("id" = "CHUNK",		"settings" = "chunk",			"playerPickable" = 1),
	"Bayou Bend Dock-N-Go" = list("id" = "BAYOUBEND",	"settings" = "bayoubend", 	"playerPickable" = 1,		"MaxPlayersAllowed" = 60),
	"Bobmap" = 			list("id" = "BOBMAP",		"settings" = "bobmap",			"playerPickable" = 0,  	"MinPlayersAllowed" = 20),
	//"Dockmap" = 		list("id" = "DOCKMAP",		"settings" = "dockmap",			"playerPickable" = 0,	"MaxPlayersAllowed" = 30),
	"Spirit" =			list("id" = "SPIRIT",		"settings" = "spirit",				"playerPickable" = 0),
	//"Mushroom" =		list("id" = "MUSHROOM", 	"settings" = "mushroom",		"playerPickable" = ASS_JAM),
	//"Trunkmap" = 		list("id" = "TRUNKMAP", 	"settings" = "trunkmap",		"playerPickable" = ASS_JAM),
	"Oshan Laboratory"= list("id" = "OSHAN", 		"settings" = "oshan", 			"playerPickable" = 1),
	//"1 pamgoC" = 		list("id" = "PAMGOC", 		"settings" = "pamgoc", 			"playerPickable" = ASS_JAM),
	//"Kondaru" = 		list("id" = "KONDARU", 		"settings" = "kondaru", 		"playerPickable" = 1,		"MaxPlayersAllowed" = 80),
	//"Ozymandias" = 	list("id" = "OZYMANDIAS", 	"settings" = "ozymandias", 		"playerPickable" = 0, 		"MinPlayersAllowed" = 40),
	//"Bellerophon Fleet" = list("id" = "FLEET", 	"settings" = "fleet", 			"playerPickable" = ASS_JAM),
	//"Icarus" = 		list("id" = "ICARUS",		"settings" = "icarus",			"playerPickable" = ASS_JAM),
	//"Density" = 		list("id" = "DENSITY", 		"settings" = "density", 		"playerPickable" = ASS_JAM,	"MaxPlayersAllowed" = 30),
	"Atlas" = 			list("id" = "ATLAS", 		"settings" = "atlas", 			"playerPickable" = 1,		"MaxPlayersAllowed" = 30),
	"Wrestlemap" = 		list("id" = "WRESTLEMAP", 	"settings" = "wrestlemap", 		"playerPickable" = ASS_JAM),
	"pod_wars" = 		list("id" = "POD_WARS", 	"settings" = "pod_wars", 		"playerPickable" = 0),
	"blank" = 			list("id" = "BLANK", 		"settings" = "", 				"playerPickable" = 0),
	"blank_underwater" =  list("id" = "BLANK_UNDERWATER", "settings" = "", "playerPickable" = 0)
)

/obj/landmark/map
	name = "map_setting"
	icon_state = "x3"
	add_to_landmarks = FALSE

	New()
		if (src.name != "map_setting")
			map_setting = src.name

			//find config in mapNames above
			for (var/map in mapNames)
				var/mapID = mapNames[map]["id"]

				if (mapID == map_setting)
					var/path = (mapNames[map]["settings"] == "") ? /datum/map_settings : text2path("/datum/map_settings/" + mapNames[map]["settings"])
					map_settings = new path
					break

			//Fallback for an unfound map. Should never occur!!
			if (!map_settings)
				map_settings = new /datum/map_settings
				CRASH("A mapName entry for '[src.name]' wasn't found!")
		..()

//Setting maps to be underwater is handled in the map config file, aka [mapname].dm

/datum/map_settings
	var/name = "MAP"
	var/display_name = MAP_NAME_RANDOM
	var/style = "station"
	var/default_gamemode = "secret"
	var/goonhub_map = "https://goonhub.com/maps/cogmap"
	var/arrivals_type = MAP_SPAWN_SHUTTLE
	var/dir_fore = null

	var/walls = /turf/wall/auto
	var/rwalls = /turf/wall/r_wall
	var/auto_walls = 0

	var/windows = /obj/window
	var/windows_thin = /obj/window
	var/rwindows = /obj/window/reinforced
	var/rwindows_thin = /obj/window/reinforced
	var/windows_crystal = /obj/window/crystal
	var/windows_rcrystal = /obj/window/crystal/reinforced
	var/window_layer_full = null
	var/window_layer_north = null // cog2 panel windows need to go under stuff because ~perspective~
	var/window_layer_south = null
	var/auto_windows = 0

	var/ext_airlocks = /obj/machinery/door/airlock/external
	var/airlock_style = "gannets"
	var/firelock_style = /obj/machinery/door/firedoor/pyro

	var/escape_centcom = /area/shuttle/escape/centcom
	var/escape_outpost = /area/shuttle/escape/outpost
	var/escape_transit = /area/shuttle/escape/transit
	var/escape_station = /area/shuttle/escape/station
	var/escape_def = SHUTTLE_NODEF
	var/escape_dir = SOUTH
	//Only used with MAP_SPAWN_SHUTTLE_DYNAMIC, determines which shuttle folder gets used
	var/arrivals_shape = "cogmap"

	var/shuttle_map_turf = /turf/space
	var/qm_supply_type = "space" //can also be "shuttle"!

	var/merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom
	var/merchant_left_station = /area/shuttle/merchant_shuttle/left_station
	var/merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom
	var/merchant_right_station = /area/shuttle/merchant_shuttle/right_station

	var/list/valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science/lobby),
		"the cargo bay (QM)" = list(/area/station/quartermaster/office),
		"the engineering control room" = list(/area/station/engine/engineering, /area/station/engine/power),
		"the central warehouse" = list(/area/station/storage/warehouse),
		"the courtroom" = list(/area/station/crew_quarters/courtroom, /area/station/crew_quarters/juryroom),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery, /area/station/medical/medbay/lobby),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the EVA storage" = list(/area/station/ai_monitored/storage/eva),
		"the robotics lab" = list(/area/station/medical/robotics))
//		"the public pool" = list(/area/station/crew_quarters/pool))

	var/job_limits_from_landmarks = FALSE /// if TRUE each job with a landmark will get as many slots as many landmarks there are (jobs without a landmark left on default)
	var/list/job_limits_override = list() /// assoc list of the form `job_type=limit` to override other job settings, works on gimmick jobs too

	proc/init() /// Map-specific initialization, feel free to override for your map!
		// map limits
		if(job_limits_from_landmarks)
			for(var/datum/job/J in job_controls.staple_jobs)
				if(J.map_can_autooverride && (J.name in job_start_locations))
					J.limit = length(job_start_locations[J.name])

		for(var/datum/job/J in job_controls.staple_jobs + job_controls.special_jobs)
			if(J.type in src.job_limits_override)
				J.limit = src.job_limits_override[J.type]



/datum/map_settings/donut2
	name = "DONUT2"
	goonhub_map = "https://goonhub.com/maps/donut2"
	airlock_style = "pyro"
	walls = /turf/wall/auto/supernorn
	rwalls = /turf/wall/auto/reinforced/supernorn

	escape_centcom = /area/shuttle/escape/centcom/donut2
	escape_outpost = /area/shuttle/escape/outpost/donut2
	escape_transit = /area/shuttle/escape/transit/donut2
	escape_station = /area/shuttle/escape/station/donut2
	escape_def = SHUTTLE_WEST
	escape_dir = WEST

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/donut2
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/donut2
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/donut2
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/donut2

/datum/map_settings/donut3
	name = "DONUT3"
	goonhub_map = "http://goonhub.com/maps/donut3"
	airlock_style = "pyro"
	walls = /turf/wall/auto/jen
	rwalls = /turf/wall/auto/reinforced/jen

	escape_centcom = /area/shuttle/escape/centcom/donut3
	escape_outpost = /area/shuttle/escape/outpost/donut3
	escape_transit = /area/shuttle/escape/transit/donut3
	escape_station = /area/shuttle/escape/station/donut3
	escape_def = SHUTTLE_DONUT3
	escape_dir = NORTH
	auto_windows = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/destiny
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/destiny
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/destiny
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/destiny

	valid_nuke_targets = list("the cargo bay (QM)" = list(/area/station/quartermaster/office),
		"inner engineering (surrounding the singularity, not in it)" = list(/area/station/engine/inner),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the inner hall of the medbay" = list(/area/station/medical/medbay),
		"the main hallway in research" = list(/area/station/science/lobby),
		"the chapel" = list(/area/station/chapel/sanctuary),
		"the escape hallway" = list(/area/station/hallway/secondary/exit),
		"the Research Director's office" = list(/area/station/crew_quarters/hor),
		"the Chief Engineer's office" = list(/area/station/engine/engineering/ce),
		"the kitchen" = list(/area/station/crew_quarters/kitchen),
		"the bridge" = list(/area/station/bridge),
		"the courtroom" = list(/area/station/crew_quarters/courtroom),
		"the central room in security" = list(/area/station/security/main),
		"the hydroponics bay" = list(/area/station/hydroponics/bay))

/datum/map_settings/cogmap_old
	name = "COGMAP_OLD"
	escape_centcom = /area/shuttle/escape/centcom/cogmap
	escape_outpost = /area/shuttle/escape/outpost/cogmap
	escape_transit = /area/shuttle/escape/transit/cogmap
	escape_station = /area/shuttle/escape/station/cogmap
	escape_def = SHUTTLE_SOUTH
	escape_dir = SOUTH

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

/datum/map_settings/chunk
	name = "CHUNK"
	walls = /turf/wall/
	rwalls = /turf/wall/r_wall/
	auto_walls = 0
	job_limits_from_landmarks = TRUE
	goonhub_map = "https://wiki.coolstation.space/wiki/Chunk"

	windows = /obj/window/auto
	windows_thin = /obj/window
	rwindows = /obj/window/reinforced
	rwindows_thin = /obj/window/reinforced
	windows_crystal = /obj/window/crystal
	windows_rcrystal = /obj/window/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1
	qm_supply_type = "shuttle"

	ext_airlocks = /obj/machinery/door/airlock/external
	airlock_style = "fart butt old stuff"
	firelock_style = /obj/machinery/door/firedoor/border_only

	escape_centcom = /area/shuttle/escape/centcom/destiny
	escape_outpost = /area/shuttle/escape/outpost/destiny
	escape_transit = /area/shuttle/escape/transit/destiny
	escape_station = /area/shuttle/escape/station/destiny
	escape_def = SHUTTLE_NORTH
	escape_dir = NORTH

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science/lobby),
		"the cargo bay" = list(/area/station/quartermaster/cargobay),
		"the engineering control room" = list(/area/station/engine/engineering, /area/station/engine/power),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery, /area/station/medical/medbay/pharmacy, /area/station/medical/medbay/treatment ),
		"the bar" = list(/area/station/crew_quarters/bar),
		"the EVA storage" = list(/area/station/ai_monitored/storage/eva),
		"the robotics lab" = list(/area/station/medical/robotics),
		"the bridge" = list(/area/station/bridge),
		"the escape arm" = list(/area/station/hallway/secondary/exit),
		"the dank ass observatory" = list(/area/station/crew_quarters/observatory),
		"the chapel" = list(/area/station/chapel/sanctuary))

/datum/map_settings/bayoubend
	name = "BAYOUBEND"
	walls = /turf/wall/
	rwalls = /turf/wall/r_wall/
	auto_walls = 0
	job_limits_from_landmarks = TRUE
	arrivals_type = MAP_SPAWN_CRYO
	goonhub_map = "https://wiki.coolstation.space/wiki/File:Bayoubendmapimage.png"

	windows = /obj/window/auto
	windows_thin = /obj/window
	rwindows = /obj/window/reinforced
	rwindows_thin = /obj/window/reinforced
	windows_crystal = /obj/window/crystal
	windows_rcrystal = /obj/window/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1
	qm_supply_type = "shuttle"
	//shuttle_map_turf = /turf/floor/airless/engine/caution

	ext_airlocks = /obj/machinery/door/airlock/external
	airlock_style = "fart butt old stuff"
	firelock_style = /obj/machinery/door/firedoor/border_only

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/destiny
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/destiny

	//Bayou's only got the one merchant dock so maybe have go to the same either way?
	merchant_right_centcom = /area/shuttle/merchant_shuttle/left_centcom/destiny
	merchant_right_station = /area/shuttle/merchant_shuttle/left_station/destiny

	escape_centcom = /area/shuttle/escape/centcom/donut2
	escape_outpost = /area/shuttle/escape/outpost/donut2
	escape_transit = /area/shuttle/escape/transit/donut2
	escape_station = /area/shuttle/escape/station/donut2
	escape_def = SHUTTLE_WEST
	escape_dir = WEST

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"research sector" = list(/area/station/science/lobby),
		"the logistics bay" = list(/area/station/quartermaster/cargobay),
		"the engineering control room" = list(/area/station/engine/engineering, /area/station/engine/power),
		"the robotics workshop" = list(/area/station/medical/robotics),
		"the bridge" = list(/area/station/bridge),
		"the departures wing" = list(/area/station/hallway/secondary/exit),
		"the chapel" = list(/area/station/chapel/sanctuary),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery, /area/station/medical/medbay/pharmacy, /area/station/medical/medbay/treatment ),
		"the cafeteria" = list(/area/station/crew_quarters/bar))

	job_limits_override = list(
		/datum/job/logistics/miner = 0,
		/datum/job/logistics/scrapper = 3,
		/datum/job/civilian/rancher = 0,
		/datum/job/medical/pathologist = 0,
		/datum/job/logistics/janitor = 1
	)

	init()
		..()
		SPAWN_DBG(10) // this sucks so much ass but it just- idk.
			var/area/m_shuttle = locate(/area/shuttle/mining/station)
			if(m_shuttle)
				m_shuttle.filler_turf = "/turf/floor/airless/engine/caution"
			var/area/c_shuttle = locate(/area/shuttle/cargo/station)
			if(c_shuttle)
				c_shuttle.filler_turf = "/turf/floor/airless/engine/caution"

			var/area/t_shuttle_r = locate(/area/shuttle/merchant_shuttle/right_station)
			if(t_shuttle_r)
				t_shuttle_r.filler_turf = "/turf/floor/airless/engine/caution"
			var/area/t_shuttle_l = locate(/area/shuttle/merchant_shuttle/left_station)
			if(t_shuttle_l)
				t_shuttle_l.filler_turf = "/turf/floor/airless/engine/caution"


/datum/map_settings/cogmap
	name = "COGMAP"
	goonhub_map = "https://goonhub.com/maps/cogmap"
	walls = /turf/wall/
	rwalls = /turf/wall/r_wall/
	auto_walls = 0

	windows = /obj/window/auto
	windows_thin = /obj/window
	rwindows = /obj/window/reinforced
	rwindows_thin = /obj/window/reinforced
	windows_crystal = /obj/window/crystal
	windows_rcrystal = /obj/window/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/external
	airlock_style = "fart butt old stuff"
	firelock_style = /obj/machinery/door/firedoor/border_only

	escape_centcom = /area/shuttle/escape/centcom/cogmap
	escape_outpost = /area/shuttle/escape/outpost/cogmap
	escape_transit = /area/shuttle/escape/transit/cogmap
	escape_station = /area/shuttle/escape/station/cogmap
	escape_def = SHUTTLE_SOUTH
	escape_dir = SOUTH
	arrivals_type = MAP_SPAWN_SHUTTLE_DYNAMIC
	arrivals_shape = "cogmap"

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science/lobby),
		"the cargo office (QM)" = list(/area/station/quartermaster/office),
		"the engineering control room" = list(/area/station/engine/engineering, /area/station/engine/power),
		"the central warehouse" = list(/area/station/storage/warehouse),
		"the courtroom" = list(/area/station/crew_quarters/courtroom, /area/station/crew_quarters/juryroom),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery, /area/station/medical/medbay/lobby),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the EVA storage" = list(/area/station/ai_monitored/storage/eva),
		"the robotics lab" = list(/area/station/medical/robotics),
		"the bridge" = list(/area/station/bridge),
		"the stock exchange at the public market" = list(/area/station/crew_quarters/stockex),
		"the escape arm" = list(/area/station/hallway/secondary/exit),
		"the central room of the crew lounge" = list(/area/station/crew_quarters/quarters),
		"the chapel" = list(/area/station/chapel/sanctuary))

/datum/map_settings/cogmap2
	name = "COGMAP2"
	goonhub_map = "https://goonhub.com/maps/cogmap2"
	walls = /turf/wall/auto/supernorn
	rwalls = /turf/wall/auto/reinforced/supernorn
	auto_walls = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_outpost = /area/shuttle/escape/outpost/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_def = SHUTTLE_EAST
	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap2
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap2
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap2
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap2

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science/lobby),
		"the cargo bay (QM)" = list(/area/station/quartermaster/office),
		//"the thermo-electric generator room" = list(/area/station/engine/core),
		"the engine control room" = list(/area/station/engine/power),
		"the refinery (arc smelter)" = list(/area/station/quartermaster/refinery),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the net cafe" = list(/area/station/crew_quarters/info),
		"the artifact lab" = list(/area/station/science/artifact),
		"the genetics lab" = list(/area/station/medical/research),
		"the chapel" = list(/area/station/chapel/sanctuary),
		"the mining staff room" = list(/area/station/mining/staff_room),
		"the bridge" = list(/area/station/bridge),
		"the central warehouse, next to the refinery" = list(/area/station/storage/warehouse))

/datum/map_settings/destiny
	name = "DESTINY"
	display_name = "NSS Destiny"
	style = "ship"
	default_gamemode = "extended"
	goonhub_map = "https://goonhub.com/maps/destiny"
	arrivals_type = MAP_SPAWN_CRYO
	dir_fore = NORTH

	walls = /turf/wall/auto/gannets
	rwalls = /turf/wall/auto/reinforced/gannets
	auto_walls = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/destiny
	escape_outpost = /area/shuttle/escape/outpost/destiny
	escape_transit = /area/shuttle/escape/transit/destiny
	escape_station = /area/shuttle/escape/station/destiny
	escape_def = SHUTTLE_NORTH
	escape_dir = NORTH

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/destiny
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/destiny
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/destiny
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/destiny

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science/lobby),
		"the cargo bay (QM)" = list(/area/station/quartermaster/office),
		"the thermo-electric generator room" = list(/area/station/engine/core),
		//"the refinery (arc smelter)" = list(/area/station/mining/refinery),
		"the courtroom" = list(/area/station/crew_quarters/courtroom),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/lobby),
		"the bar" = list(/area/station/crew_quarters/bar),
		//"the EVA storage" = list(/area/station/ai_monitored/storage/eva),
		"the artifact lab" = list(/area/station/science/artifact),
		"the robotics lab" = list(/area/station/medical/robotics),
		"the escape shuttle dock" = list(/area/station/hallway/secondary/exit),
		"the kitchen" = list(/area/station/crew_quarters/kitchen))

/datum/map_settings/destiny/clarion
	name = "CLARION"
	display_name = "NSS Clarion"
	goonhub_map = "https://goonhub.com/maps/clarion"

	walls = /turf/wall/auto/supernorn
	rwalls = /turf/wall/auto/reinforced/supernorn
	auto_walls = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science/lobby),
		"the quartermaster's office" = list(/area/station/quartermaster/office),
		"the thermo-electric generator room" = list(/area/station/engine/core),
		"the courtroom" = list(/area/station/crew_quarters/courtroom),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/lobby),
		"the bar" = list(/area/station/crew_quarters/bar),
		//"the EVA storage" = list(/area/station/ai_monitored/storage/eva),
		"the artifact lab" = list(/area/station/science/artifact),
		"the bridge" = list(/area/station/bridge),
		"the community center (chapel)" = list(/area/station/chapel/sanctuary),
		"the aviary" = list(/area/station/garden/aviary),
		"the quartermaster's storage room" = list(/area/station/quartermaster/storage))
		//"the robotics lab" = list(/area/station/medical/robotics))

/datum/map_settings/horizon
	name = "HORIZON"
	display_name = "NSS Horizon"
	style = "ship"
	goonhub_map = "https://goonhub.com/maps/horizon"
	walls = /turf/wall/auto/supernorn
	rwalls = /turf/wall/auto/reinforced/supernorn
	auto_walls = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_outpost = /area/shuttle/escape/outpost/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_def = SHUTTLE_EAST
	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the courtroom" = list(/area/station/crew_quarters/courtroom),
		"the chapel" = list(/area/station/chapel/sanctuary),
		"the main security room" = list(/area/station/security/main),
		"the Quartermaster's Store (QM)" = list(/area/station/quartermaster/office),
		"the Engineering control room" = list(/area/station/engine/power),
		"that snazzy-lookin' sports bar up front" = list(/area/station/crew_quarters/fitness),
		"the main medical bay room" = list(/area/station/medical/medbay),
		"the research artifact lounge" = list(/area/station/science/artifact),
		"the cloning lab" = list(/area/station/medical/medbay/cloner),
		"the hot loop" = list(/area/station/engine/hotloop),
		"the mechanics' lab" = list(/area/station/engine/elect),
		"the mining staff room" = list(/area/station/mining/staff_room),
		"the robotics lab" = list(/area/station/medical/robotics),
		"the crew quarters on the south of the station" = list(/area/station/crew_quarters/quarters_south))

	job_limits_override = list(
		/datum/job/civilian/clown = 2,
		/datum/job/security/security_officer = 6,
		/datum/job/security/detective = 3,
		/datum/job/research/scientist = 6,
		/datum/job/medical/geneticist = 3,
		/datum/job/medical/roboticist = 3,
		/datum/job/medical/medical_doctor = 7,
		/datum/job/engineering/mechanic = 4,
		/datum/job/engineering/engineer = 6,
		/datum/job/logistics/miner = 4,
		/datum/job/logistics/janitor = 3,
		/datum/job/civilian/chef = 2,
		/datum/job/civilian/bartender = 2,
		/datum/job/civilian/chaplain = 2,
		/datum/job/special/lawyer = 1,
		/datum/job/engineering/atmospheric_technician = 1
	)

/datum/map_settings/mushroom
	name = "MUSHROOM"
	goonhub_map = "https://goonhub.com/maps/mushroom"

	walls = /turf/wall/auto/supernorn
	rwalls = /turf/wall/auto/reinforced/supernorn
	auto_walls = 1
	airlock_style = "pyro"

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_outpost = /area/shuttle/escape/outpost/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_def = SHUTTLE_EAST
	escape_dir = EAST

/datum/map_settings/trunkmap
	name = "TRUNKMAP"
	goonhub_map = "https://goonhub.com/maps/trunkmap"
	escape_centcom = /area/shuttle/escape/centcom/destiny
	escape_outpost = /area/shuttle/escape/outpost/destiny
	escape_transit = /area/shuttle/escape/transit/destiny
	escape_station = /area/shuttle/escape/station/destiny
	escape_def = SHUTTLE_NORTH
	escape_dir = NORTH

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/destiny
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/destiny
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/destiny
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/destiny

/datum/map_settings/atlas
	name = "ATLAS"
	display_name = "NCS Atlas"
	style = "ship"
	goonhub_map = "https://goonhub.com/maps/atlas"
	arrivals_type = MAP_SPAWN_CRYO
	dir_fore = NORTH

	walls = /turf/wall/auto/supernorn
	rwalls = /turf/wall/auto/reinforced/supernorn
	auto_walls = 1
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_outpost = /area/shuttle/escape/outpost/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_def = SHUTTLE_EAST
	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the cargo bay (QM)" = list(/area/station/quartermaster/office/),
		"the bridge" = list(/area/station/bridge/),
		"the thermo-electric generator room" = list(/area/station/engine/core),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the telescience lab" = list(/area/station/science/teleporter),
		"the genetics lab" = list(/area/station/medical/research, /area/station/medical/medbay/cloner))

/datum/map_settings/kondaru
	name = "KONDARU"
	goonhub_map = "https://goonhub.com/maps/kondaru"
	walls = /turf/wall/auto/supernorn
	rwalls = /turf/wall/auto/reinforced/supernorn
	auto_walls = 1

	arrivals_type = MAP_SPAWN_CRYO

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_outpost = /area/shuttle/escape/outpost/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_def = SHUTTLE_EAST
	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the quartermaster's front office" = list(/area/station/quartermaster/office),
		"the courtroom" = list(/area/station/crew_quarters/courtroom),
		"the thermo-electric generator room" = list(/area/station/engine/core),
		"the refinery (arc smelter)" = list(/area/station/mining/refinery),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the artifact lab" = list(/area/station/science/artifact),
		"the janitor's office" = list(/area/station/janitor/office),
		"the telescience lab" = list(/area/station/science/teleporter),
		"the merchant docks" = list(/area/station/crew_quarters/market),
		"the nerd dungeon" = list(/area/station/crew_quarters/arcade/dungeon),
		"the chapel" = list(/area/station/chapel/sanctuary),
		"the fitness room" = list(/area/station/crew_quarters/fitness),
		"the news office" = list(/area/station/crew_quarters/radio/news_office),
		"the central warehouse" = list(/area/station/storage/warehouse),
		"the aviary" = list( /area/station/garden/aviary))

/datum/map_settings/ozymandias
	name = "OZYMANDIAS"
	goonhub_map = "https://i.imgur.com/COYgNvN.jpg"
	walls = /turf/wall/auto/supernorn
	rwalls = /turf/wall/auto/reinforced/supernorn
	auto_walls = 1

	job_limits_from_landmarks = 1
	job_limits_override = list(
		/datum/job/engineering/atmospheric_technician = 1,
		/datum/job/special/barber = 1,
		/datum/job/special/research_assistant = 2,
		/datum/job/special/medical_assistant = 2
	)

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_outpost = /area/shuttle/escape/outpost/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_def = SHUTTLE_EAST
	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the security equipment wing" = list(/area/station/security/equipment),
		"the central research sector hub" = list(/area/station/science/lobby),
		"the quartermasters' office" = list(/area/station/quartermaster/office),
		"the thermo-electric generator room" = list(/area/station/engine/core),
		"the basketball court" = list(/area/station/crew_quarters/fitness),
		"the medbay's central loop" = list(/area/station/medical/medbay),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the data center" = list(/area/station/crew_quarters/info),
		"the artifact lab" = list(/area/station/science/artifact),
		"the chapel reception hall" = list(/area/station/crew_quarters/quarters))

/datum/map_settings/fleet
	name = "FLEET"
	display_name = "Bellerophon Fleet"
	style = "ship"
	goonhub_map = "https://goonhub.com/maps/bellerophon fleet"
	walls = /turf/wall/auto/supernorn
	rwalls = /turf/wall/auto/reinforced/supernorn
	auto_walls = 1
	arrivals_type = MAP_SPAWN_CRYO
	dir_fore = NORTH

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_outpost = /area/shuttle/escape/outpost/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_def = SHUTTLE_EAST
	escape_dir = EAST

	merchant_left_centcom = null
	merchant_left_station = null
	merchant_right_centcom = null
	merchant_right_station = null

	valid_nuke_targets = list("the Demeter primary zone" = list(/area/station/garden/aviary),
		"the Tenebrae primary zone" = list(/area/station/science/lobby),
		"the Asclepius primary zone" = list(/area/station/medical/medbay),
		"the Meridian primary zone" = list(/area/station/crew_quarters/captain),
		"the Dionysus primary zone" = list(/area/station/crew_quarters/cafeteria),
		"the Maru primary zone" = list(/area/station/engine/engineering),
		"the Hammer primary zone" = list(/area/station/security/main))

/datum/map_settings/icarus
	name = "ICARUS"
	display_name = "Icarus"
	style = "ship"
	goonhub_map = "https://i.imgur.com/SiI3RC9.png"
	walls = /turf/wall/auto/supernorn
	rwalls = /turf/wall/auto/reinforced/supernorn
	auto_walls = 1
	arrivals_type = MAP_SPAWN_CRYO
	dir_fore = NORTH

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external

	escape_centcom = /area/shuttle/escape/centcom/destiny
	escape_outpost = /area/shuttle/escape/outpost/destiny
	escape_transit = /area/shuttle/escape/transit/destiny
	escape_station = /area/shuttle/escape/station/destiny
	escape_def = SHUTTLE_NORTH
	escape_dir = NORTH

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/destiny
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/destiny
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/destiny
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/destiny

	valid_nuke_targets = list("the gymnasium" = list(/area/station/crew_quarters/fitness),
		"the vessel's power core" = list(/area/station/engine/engineering),
		"the monkey dome" = list(/area/station/medical/dome),
		"the jazz lounge" = list(/area/station/crew_quarters/jazz),
		"the quartermasters front office" = list(/area/station/quartermaster/office))

/datum/map_settings/density // I just copied cog2 for now, ok????
	name = "density"
	goonhub_map = "https://goonhub.com/maps/density"
	walls = /turf/wall/auto/supernorn
	rwalls = /turf/wall/auto/reinforced/supernorn
	auto_walls = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_outpost = /area/shuttle/escape/outpost/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_def = SHUTTLE_EAST
	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap2
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap2
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap2
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap2

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science/lobby),
		"the cargo bay (QM)" = list(/area/station/quartermaster/office),
		"the thermo-electric generator room" = list(/area/station/engine/core),
		"the refinery (arc smelter)" = list(/area/station/quartermaster/refinery),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the net cafe" = list(/area/station/crew_quarters/info),
		"the artifact lab" = list(/area/station/science/artifact),
		"the genetics lab" = list(/area/station/medical/research))

/datum/map_settings/pamgoc
	name = "PAMGOC"
	goonhub_map = "https://goonhub.com/maps/cogmap"
	walls = /turf/wall/auto/supernorn
	rwalls = /turf/wall/auto/reinforced/supernorn
	auto_walls = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap
	escape_outpost = /area/shuttle/escape/outpost/cogmap
	escape_transit = /area/shuttle/escape/transit/cogmap
	escape_station = /area/shuttle/escape/station/cogmap
	escape_def = SHUTTLE_SOUTH
	escape_dir = SOUTH

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	job_limits_override = list(
		/datum/job/civilian/clown = 2 // pamgoc can have a little clown, as a treat
	)

/datum/map_settings/oshan
	name = "OSHAN"
	goonhub_map = "https://goonhub.com/maps/oshan"

	arrivals_type = MAP_SPAWN_MISSILE

	walls = /turf/wall/auto/supernorn
	rwalls = /turf/wall/auto/reinforced/supernorn
	auto_walls = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/sealab
	escape_outpost = /area/shuttle/escape/outpost/sealab
	escape_transit = /area/shuttle/escape/transit/sealab
	escape_station = /area/shuttle/escape/station/sealab
	escape_def = SHUTTLE_OSHAN
	escape_dir = EAST
	shuttle_map_turf = /turf/space/fluid

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the fitness room" = list(/area/station/crew_quarters/fitness),
		"the quartermaster's office" = list(/area/station/quartermaster/office),
		"the refinery (arc smelter)" = list(/area/station/quartermaster/refinery),
		"the courtroom" = list(/area/station/crew_quarters/courtroom),
		"the medbay" = list(/area/station/medical/medbay),
		"the bar" = list(/area/station/crew_quarters/bar),
		"the nerd dungeon" = list(/area/station/crew_quarters/arcade/dungeon),
		"the chapel" = list(/area/station/chapel/sanctuary),
		"the main security room" = list(/area/station/security/main),
		"the main engineering room" = list(/area/station/engine/engineering, /area/station/hangar/engine),
		"the research lobby" = list(/area/station/science/lobby),
		"the crew quarters" = list(/area/station/crew_quarters/quartersA),
		"the mining staff room" = list(/area/station/mining/staff_room))
		//"the radio lab" = list(/area/station/crew_quarters/radio))


/datum/map_settings/noyade
	name = "NOYADE"
	goonhub_map = "https://goonhub.com/maps/oshan"

	arrivals_type = MAP_SPAWN_MISSILE

	walls = /turf/wall
	rwalls = /turf/wall/r_wall
	auto_walls = 0
	shuttle_map_turf = /turf/space/gehenna/desert/beaten

	qm_supply_type = "shuttle"
	shuttle_map_turf = /turf/space/fluid

	windows = /obj/window
	windows_thin = /obj/window
	rwindows = /obj/window/reinforced
	rwindows_thin = /obj/window/reinforced
	windows_crystal = /obj/window/crystal
	windows_rcrystal = /obj/window/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "fart butt old stuff"
	firelock_style = /obj/machinery/door/firedoor/border_only

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_outpost = /area/shuttle/escape/outpost/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_def = SHUTTLE_EAST
	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list()
	//job_limits_override = list()

	init()
		..()
		SPAWN_DBG(10) // this sucks so much ass but it just- idk.
			var/area/m_shuttle = locate(/area/shuttle/mining/station)
			if(m_shuttle)
				m_shuttle.filler_turf = /turf/space/fluid/noexplosion/nospawn
			var/area/c_shuttle = locate(/area/shuttle/cargo/station)
			if(c_shuttle)
				c_shuttle.filler_turf = /turf/space/fluid/noexplosion/nospawn

			var/area/t_shuttle_r = locate(/area/shuttle/merchant_shuttle/right_station)
			if(t_shuttle_r)
				t_shuttle_r.filler_turf = /turf/space/fluid/noexplosion/nospawn
			var/area/t_shuttle_l = locate(/area/shuttle/merchant_shuttle/left_station)
			if(t_shuttle_l)
				t_shuttle_l.filler_turf = /turf/space/fluid/noexplosion/nospawn


/datum/map_settings/wrestlemap
	name = "WRESTLEMAP"
	walls = /turf/wall/auto/supernorn
	rwalls = /turf/wall/auto/reinforced/supernorn
	auto_walls = 1

	arrivals_type = MAP_SPAWN_CRYO

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/destiny
	escape_outpost = /area/shuttle/escape/outpost/destiny
	escape_transit = /area/shuttle/escape/transit/destiny
	escape_station = /area/shuttle/escape/station/destiny
	escape_def = SHUTTLE_NORTH
	escape_dir = NORTH

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap


	valid_nuke_targets = list("The Ring (near the bar)" = list(/area/station/crew_quarters/quarters),
		"the monkeydome arena" = list(/area/station/medical/dome),
		"the courtroom" = list(/area/station/crew_quarters/courtroom),
		"outside the Ringularity" = list(/area/station/engine/inner),
		"the courtroom" = list(/area/station/storage/warehouse),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay),
		"the security lobby" = list(/area/station/chapel/sanctuary),
		"the chapel" = list(/area/station/security/secwing),
		"the south crew quarters" = list(/area/station/crew_quarters/quarters_south))

/datum/map_settings/pod_wars
	name = "POD_WARS"
	default_gamemode = "pod_wars"
	goonhub_map = "https://goonhub.com/maps/pod_wars"
	walls = /turf/wall/auto/supernorn
	rwalls = /turf/wall/auto/reinforced/supernorn
	auto_walls = 1
	style = "spess"


	arrivals_type = MAP_SPAWN_CRYO

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = null
	escape_transit = null
	escape_station = null
	escape_dir = NORTH

	merchant_left_centcom = null
	merchant_left_station = null
	merchant_right_centcom = null
	merchant_right_station = null

	valid_nuke_targets = list()


/datum/map_settings/gehenna
	name = "GEHENNA"
	goonhub_map = "https://wiki.coolstation.space/wiki/Gehenna"
	walls = /turf/wall
	rwalls = /turf/wall/r_wall
	auto_walls = 0
	shuttle_map_turf = /turf/space/gehenna/desert/beaten

	arrivals_type = MAP_SPAWN_CRYO
	qm_supply_type = "shuttle"

	windows = /obj/window
	windows_thin = /obj/window
	rwindows = /obj/window/reinforced
	rwindows_thin = /obj/window/reinforced
	windows_crystal = /obj/window/crystal
	windows_rcrystal = /obj/window/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "fart butt old stuff"
	firelock_style = /obj/machinery/door/firedoor/border_only

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_outpost = /area/shuttle/escape/outpost/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_def = SHUTTLE_EAST
	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the cargo office (QM)" = list(/area/station/quartermaster/office, /area/station/quartermaster/cargooffice/storefront),
		"the engineering control room" = list(/area/station/engine/engineering, /area/station/engine/power),
		"the hospital" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery, /area/station/medical/medbay/lobby),
		"the underground bar" = list(/area/station/crew_quarters/bar, /area/station/crew_quarters/fitness),
		"the bridge" = list(/area/station/bridge, /area/station/bridge/conference),
		"the chapel" = list(/area/station/chapel/sanctuary),
		"the fucking staff assistants' rat's nest between the tunnels" = list(/area/gehenna/underground/staffies_nest),
		"somewhere in the main tunnels, whatever" = list(/area/station/maintenance/west, /area/station/maintenance/inner/north, /area/station/maintenance/central, /area/station/maintenance/inner/ne, /area/station/maintenance/outer/east, /area/station/maintenance/south, /area/station/maintenance/inner/nw))

	job_limits_override = list(
		/datum/job/security/security_officer = 6,
		/datum/job/research/scientist = 6,
		/datum/job/medical/medical_doctor = 6,
		/datum/job/logistics/miner = 6,
		/datum/job/engineering/engineer = 6,
		/datum/job/civilian/chaplain = 2,
		/datum/job/engineering/atmospheric_technician = 2,
		/datum/job/civilian/botanist = 3
	)

	init()
		..()
		SPAWN_DBG(10) // this sucks so much ass but it just- idk.
			var/area/m_shuttle = locate(/area/shuttle/mining/station)
			if(m_shuttle)
				m_shuttle.filler_turf = "/turf/space/gehenna/desert/beaten"
			var/area/c_shuttle = locate(/area/shuttle/cargo/station)
			if(c_shuttle)
				c_shuttle.filler_turf = "/turf/floor/industrial"
			var/area/t_shuttle_r = locate(/area/shuttle/merchant_shuttle/right_station)
			if(t_shuttle_r)
				t_shuttle_r.filler_turf = "/turf/space/gehenna/desert/beaten"
			var/area/t_shuttle_l = locate(/area/shuttle/merchant_shuttle/left_station)
			if(t_shuttle_l)
				t_shuttle_l.filler_turf = "/turf/space/gehenna/desert/beaten"


/datum/map_settings/crag
	name = "CRAG"
	goonhub_map = "https://wiki.coolstation.space/wiki/Gehenna"
	walls = /turf/wall
	rwalls = /turf/wall/r_wall
	auto_walls = 0
	shuttle_map_turf = /turf/space/gehenna/desert/beaten

	arrivals_type = MAP_SPAWN_CRYO
	qm_supply_type = "shuttle"

	windows = /obj/window
	windows_thin = /obj/window
	rwindows = /obj/window/reinforced
	rwindows_thin = /obj/window/reinforced
	windows_crystal = /obj/window/crystal
	windows_rcrystal = /obj/window/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "fart butt old stuff"
	firelock_style = /obj/machinery/door/firedoor/border_only

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_outpost = /area/shuttle/escape/outpost/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_def = SHUTTLE_EAST
	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the cargo office (QM)" = list(/area/station/quartermaster/office, /area/station/quartermaster/cargooffice/storefront),
		"the engineering control room" = list(/area/station/engine/engineering, /area/station/engine/power),
		"the hospital" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery, /area/station/medical/medbay/lobby),
		"the bar" = list(/area/station/crew_quarters/bar),
		"the bridge" = list(/area/station/bridge, /area/station/bridge/conference),
		"the chapel" = list(/area/station/chapel/sanctuary),
		"somewhere in the main tunnels, whatever" = list(/area/station/maintenance/west, /area/station/maintenance/inner/north, /area/station/maintenance/central, /area/station/maintenance/inner/ne, /area/station/maintenance/outer/east, /area/station/maintenance/south, /area/station/maintenance/inner/nw))

	//job_limits_override = list()

	init()
		..()
		SPAWN_DBG(10) // this sucks so much ass but it just- idk.
			var/area/m_shuttle = locate(/area/shuttle/mining/station)
			if(m_shuttle)
				m_shuttle.filler_turf = "/turf/space/gehenna/desert/beaten"
			var/area/c_shuttle = locate(/area/shuttle/cargo/station)
			if(c_shuttle)
				c_shuttle.filler_turf = "/turf/space/gehenna/desert/beaten"

			var/area/t_shuttle_r = locate(/area/shuttle/merchant_shuttle/right_station)
			if(t_shuttle_r)
				t_shuttle_r.filler_turf = "/turf/space/gehenna/desert/beaten"
			var/area/t_shuttle_l = locate(/area/shuttle/merchant_shuttle/left_station)
			if(t_shuttle_l)
				t_shuttle_l.filler_turf = "/turf/space/gehenna/desert/beaten"

/datum/map_settings/bobmap
	name = "BOBMAP"
	goonhub_map = "https://coolstation.space/stingray.html"
	walls = /turf/wall
	rwalls = /turf/wall/r_wall
	auto_walls = 1
	qm_supply_type = "shuttle"

	windows = /obj/window
	windows_thin = /obj/window
	rwindows = /obj/window/reinforced
	rwindows_thin = /obj/window/reinforced
	windows_crystal = /obj/window/crystal
	windows_rcrystal = /obj/window/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/external
	airlock_style = "gannets"

	escape_centcom = /area/shuttle/escape/centcom/cogmap
	escape_outpost = /area/shuttle/escape/outpost/cogmap
	escape_transit = /area/shuttle/escape/transit/cogmap
	escape_station = /area/shuttle/escape/station/cogmap
	escape_def = SHUTTLE_SOUTH
	escape_dir = SOUTH

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science/lobby),
		"the cargo office (QM)" = list(/area/station/quartermaster/office),
		"the engineering control room" = list(/area/station/engine/engineering, /area/station/engine/power),
		"the courtroom" = list(/area/station/crew_quarters/courtroom, /area/station/crew_quarters/juryroom),
		"the medbay" = list(/area/station/medical/medbay/treatment, /area/station/medical/medbay/surgery, /area/station/medical/medbay/lobby),
		"the station's cafeteria" = list(/area/station/crew_quarters/bar),
		"the EVA storage" = list(/area/station/storage/eva),
		"the robotics lab" = list(/area/station/medical/robotics),
		"the bridge" = list(/area/station/bridge),
		"the coffee shop" = list(/area/station/crew_quarters/jazz),
		"the escape dock" = list(/area/station/hangar/escape),
		"the central room of the crew quarters" = list(/area/station/crew_quarters/quartersA),
		"the chapel" = list(/area/station/chapel/sanctuary))

/*/datum/map_settings/dockmap //by robert goodsmells age 34 (for shuttle/offstation econony testing)
	name = "DOCKMAP"
	goonhub_map = "https://coolstation.space/stingray.html"
	walls = /turf/wall
	rwalls = /turf/wall/r_wall
	auto_walls = 1

	windows = /obj/window
	windows_thin = /obj/window
	rwindows = /obj/window/reinforced
	rwindows_thin = /obj/window/reinforced
	windows_crystal = /obj/window/crystal
	windows_rcrystal = /obj/window/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/external
	airlock_style = "gannets"

	escape_centcom = /area/shuttle/escape/centcom/??map
	escape_outpost = /area/shuttle/escape/outpost/??map
	escape_transit = /area/shuttle/escape/transit/??map
	escape_station = /area/shuttle/escape/station/??map
	escape_def = SHUTTLE_EAST
	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/??map
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/??map
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/??map
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/??map

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main))*/

/datum/map_settings/spirit
	name = "SPIRIT"
	goonhub_map = "https://goonhub.com/maps/cogmap"
	walls = /turf/wall/auto/jen/dark2
	rwalls = /turf/wall/auto/reinforced/jen/dark2
	auto_walls = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap
	escape_outpost = /area/shuttle/escape/outpost/cogmap
	escape_transit = /area/shuttle/escape/transit/cogmap
	escape_station = /area/shuttle/escape/station/cogmap
	escape_def = SHUTTLE_SOUTH
	escape_dir = SOUTH



/area/shuttle/escape/centcom
	icon_state = "shuttle_escape"
	donut2
		icon_state = "shuttle_escape-dnt2"
	donut3
		icon_state = "shuttle_escape-dnt3"
	cogmap
		icon_state = "shuttle_escape-cog1"
	cogmap2
		icon_state = "shuttle_escape-cog2"
	destiny
		icon_state = "shuttle_escape-dest"
	sealab
		icon_state = "shuttle_escape-sealab"
	donut3
		icon_state = "shuttle_escape-dnt3"

/area/shuttle/escape/outpost
	icon_state = "shuttle_escape"
	donut2
		icon_state = "shuttle_escape-dnt2"
	donut3
		icon_state = "shuttle_escape-dnt3"
	cogmap
		icon_state = "shuttle_escape-cog1"
	cogmap2
		icon_state = "shuttle_escape-cog2"
	destiny
		icon_state = "shuttle_escape-dest"
	sealab
		icon_state = "shuttle_escape-sealab"
	donut3
		icon_state = "shuttle_escape-dnt3"

/area/shuttle/escape/station
	#ifdef UNDERWATER_MAP
	ambient_light = OCEAN_LIGHT
	#endif
	icon_state = "shuttle_escape"
	donut2
		icon_state = "shuttle_escape-dnt2"
	donut3
		icon_state = "shuttle_escape-dnt3"
	cogmap
		icon_state = "shuttle_escape-cog1"
	cogmap2
		icon_state = "shuttle_escape-cog2"
	destiny
		icon_state = "shuttle_escape-dest"
	sealab
		icon_state = "shuttle_escape-sealab"

/area/shuttle/escape/transit
	icon_state = "shuttle_escape"
	donut2
		icon_state = "shuttle_escape-dnt2"
		warp_dir = WEST
	donut3
		icon_state = "shuttle_escape-dnt3"
		warp_dir = NORTH
	cogmap
		icon_state = "shuttle_escape-cog1"
	cogmap2
		icon_state = "shuttle_escape-cog2"
		warp_dir = EAST
	destiny
		icon_state = "shuttle_escape-dest"
	sealab
		icon_state = "shuttle_escape-sealab"
		warp_dir = EAST
	battle_shuttle
		icon_state = "shuttle_escape-battle-shuttle"
		warp_dir = EAST
/area/shuttle/merchant_shuttle/left_centcom
	icon_state = "shuttle_merch_l"
	donut2
		icon_state = "shuttle_merch_l-dnt2"
	cogmap
		icon_state = "shuttle_merch_l-cog1"
	cogmap2
		icon_state = "shuttle_merch_l-cog2"
	destiny
		icon_state = "shuttle_merch_l-dest"
	sealab
		icon_state = "shuttle_merch_l-sealab"
/area/shuttle/merchant_shuttle/left_station
	#ifdef UNDERWATER_MAP
	ambient_light = OCEAN_LIGHT
	#endif
	icon_state = "shuttle_merch_l"
	donut2
		icon_state = "shuttle_merch_l-dnt2"
	cogmap
		icon_state = "shuttle_merch_l-cog1"
	cogmap2
		icon_state = "shuttle_merch_l-cog2"
	destiny
		icon_state = "shuttle_merch_l-dest"
	sealab
		icon_state = "shuttle_merch_l-sealab"
/area/shuttle/merchant_shuttle/right_centcom
	icon_state = "shuttle_merch_r"
	donut2
		icon_state = "shuttle_merch_r-dnt2"
	cogmap
		icon_state = "shuttle_merch_r-cog1"
	cogmap2
		icon_state = "shuttle_merch_r-cog2"
	destiny
		icon_state = "shuttle_merch_r-dest"
	sealab
		icon_state = "shuttle_merch_r-sealab"
/area/shuttle/merchant_shuttle/right_station
	#ifdef UNDERWATER_MAP
	ambient_light = OCEAN_LIGHT
	#endif
	icon_state = "shuttle_merch_r"
	donut2
		icon_state = "shuttle_merch_r-dnt2"
	cogmap
		icon_state = "shuttle_merch_r-cog1"
	cogmap2
		icon_state = "shuttle_merch_r-cog2"
	destiny
		icon_state = "shuttle_merch_r-dest"
	sealab
		icon_state = "shuttle_merch_r-sealab"

/proc/dir2nautical(var/req_dir, var/fore_dir = NORTH, var/side = 0)
	if (!isnum(req_dir) || !isnum(fore_dir))
		return "unknown[side ? " side" : null]"
	if (req_dir == fore_dir)
		return "north"
	else if (turn(fore_dir, 90) == req_dir)
		return "west[side ? " side" : null]"
	else if (turn(fore_dir, -90) == req_dir)
		return "east[side ? " side" : null]"
	else if (turn(fore_dir, 180) == req_dir)
		return "south"
	else // we're on some kind of diagonal idk
		if (turn(fore_dir, 45) == req_dir)
			return "north-west"
		else if (turn(fore_dir, -45) == req_dir)
			return "north-east"
		else if (turn(fore_dir, 135) == req_dir)
			return "south-west"
		else if (turn(fore_dir, -135) == req_dir)
			return "south-east"
	return "unknown[side ? " side" : null]"

/proc/getMapNameFromID(id)
	for (var/map in mapNames)
		if (id == mapNames[map]["id"])
			return map

	return 0
