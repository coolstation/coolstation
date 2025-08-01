
var/global/list/list/turf/landmarks = list()

proc/pick_landmark(name, default=null)
	if(!(name in landmarks))
		return default
	return pick(landmarks[name])

/// please do not use except for live testing and admin shenanigans
proc/add_landmark(var/turf/T, var/name, var/data = null)
	if(!istype(T) || !name)
		return FALSE
	if(!(name in landmarks))
		landmarks[name] = list()
	landmarks[name][T] = data
	return TRUE

/obj/landmark
	name = "landmark"
	icon = 'icons/ui/screen1.dmi'
	icon_state = "x2"
	anchored = 1
	invisibility = 101
	var/deleted_on_start = TRUE
	var/add_to_landmarks = TRUE
	var/data = null // data to associatively save with the landmark
	var/name_override = null

	ex_act()
		return

/obj/landmark/proc/init()
	if(src.add_to_landmarks)
		if(!landmarks)
			landmarks = list()
		var/name = src.name_override ? src.name_override : src.name
		if(!landmarks[name])
			landmarks[name] = list()
		landmarks[name][src.loc] = src.data
	if(src.deleted_on_start)
		qdel(src)

/obj/landmark/New()
	if(current_state > GAME_STATE_MAP_LOAD)
		SPAWN_DBG(0)
			src.init()
		..()
	else
		src.init()
		if(!src.disposed)
			..()

var/global/list/job_start_locations = list()

/obj/landmark/start
	name = "start"
	icon_state = "x"
	add_to_landmarks = FALSE

	New()
		if (job_start_locations)
			if (!islist(job_start_locations[src.name]))
				job_start_locations[src.name] = list(src.loc)
			else
				job_start_locations[src.name] += src.loc
		..()

// actual landmarks follow
// most of these are here just for backwards compatibility

/obj/landmark/start/latejoin
	name = LANDMARK_LATEJOIN
	add_to_landmarks = TRUE

	//Woop woop dynamic arrivals shuttle requires we actually move the latejoin landmarks
/obj/landmark/start/latejoin/dynamic_shuttle
	deleted_on_start = FALSE

	set_loc(newloc)
		if (current_state >= GAME_STATE_PLAYING && !disposed)
			landmarks[name] -= src.loc
			job_start_locations[src.name] -= src.loc
			..()
			landmarks[name] += src.loc
			job_start_locations[src.name] += src.loc
			qdel(src) //you can die now :)
		else ..()

/obj/landmark/cruiser_entrance
	name = LANDMARK_CRUISER_ENTRANCE

/obj/landmark/cruiser_center
	name = LANDMARK_CRUISER_CENTER

/obj/landmark/escape_pod_succ
	name = LANDMARK_ESCAPE_POD_SUCCESS
	icon_state = "xp"
	var/shuttle = SHUTTLE_NODEF

	New()
		src.data = src.shuttle// save dir
		..()

	north
		dir = NORTH
		shuttle = SHUTTLE_NORTH

		donut3
			shuttle = SHUTTLE_DONUT3

	south
		dir = SOUTH
		shuttle = SHUTTLE_SOUTH

	east
		dir = EAST
		shuttle = SHUTTLE_EAST

		oshan
			shuttle = SHUTTLE_OSHAN

	west
		dir = WEST
		shuttle = SHUTTLE_WEST

/obj/landmark/tutorial_start
	name = LANDMARK_TUTORIAL_START

/obj/landmark/halloween
	name = LANDMARK_HALLOWEEN_SPAWN

/obj/landmark/asteroid_spawn_blocker //Blocks the creation of an asteroid on this tile, as you would expect
	name = "asteroid blocker"
	icon_state = "x4"
	deleted_on_start = FALSE
	add_to_landmarks = FALSE

/obj/landmark/magnet_center
	name = LANDMARK_MAGNET_CENTER
	icon_state = "x"

/obj/landmark/magnet_shield
	name = LANDMARK_MAGNET_SHIELD
	icon_state = "x"

/obj/landmark/latejoin_missile
	name = "missile latejoin spawn marker"
	name_override = LANDMARK_LATEJOIN_MISSILE
	icon_state = "x"
	dir = NORTH

	New()
		src.data = src.dir // save dir
		..()
	north
		name = "missile latejoin spawn marker (north)"
		dir = NORTH

	south
		name = "missile latejoin spawn marker (not north)"
		dir = SOUTH

/obj/landmark/ass_arena_spawn
	name = LANDMARK_ASS_ARENA_SPAWN
	icon_state = "x"

/obj/landmark/club_juice_dance
	name = LANDMARK_CLUB_JUICE_DANCE
	icon_state = "x"

/obj/landmark/club_juice_drink
	name = LANDMARK_CLUB_JUICE_DRINK
	icon_state = "x2"

/obj/landmark/club_juice_dj
	name = LANDMARK_CLUB_JUICE_DJ
	icon_state = "x3"

/obj/landmark/interesting
	// Use this to place cryptic clues to be picked up by the T-ray, because trying to remember which floortile you varedited is shit. For objects and mobs, just varedit.
	name = "Interesting turf spawner"
	desc = "Sets the var/interesting of the target turf, then deletes itself"
	interesting = ""
	add_to_landmarks = FALSE

	New() //use initialize() later and test ok
		var/turf/T = src.loc
		T.interesting = src.interesting
		..()

/obj/landmark/artifact
	name = LANDMARK_ARTIFACT_SPAWN
	icon_state = "x3"
	var/spawnchance = 100 // prob chance out of 100 to spawn artifact at game start
	New()
		src.data = src.spawnchance
		..()

/obj/landmark/spawner
	name = "spawner"
	add_to_landmarks = FALSE
	deleted_on_start = FALSE
	var/type_to_spawn = null
	var/spawnchance = 100
	var/static/list/name_to_type = list(
		"spare" = /obj/item/card/id/captains_spare,
		#ifndef IM_TESTING_FUCKING_BASIC_MOB_FUNCTIONALITY
		"juicer_gene" = /mob/living/carbon/human/geneticist,
		"shitty_bill" = /mob/living/carbon/human/biker,
		"john_bill" = /mob/living/carbon/human/john,
		"big_yank" = /mob/living/carbon/human/big_yank,
		"father_jack" = /mob/living/carbon/human/fathergraham,
		"don_glab" = /mob/living/carbon/human/don_glab,
		"gunsemanne" = /mob/living/carbon/human/gunsemanne,

		"monkeyspawn_normal" = /mob/living/carbon/human/npc/monkey,
		"monkeyspawn_albert" = /mob/living/carbon/human/npc/monkey/albert,
		"monkeyspawn_rathen" = /mob/living/carbon/human/npc/monkey/mr_rathen,
		"monkeyspawn_mrmuggles" = /mob/living/carbon/human/npc/monkey/mr_muggles,
		"monkeyspawn_mrsmuggles" = /mob/living/carbon/human/npc/monkey/mrs_muggles,
		"monkeyspawn_syndicate" = /mob/living/carbon/human/npc/monkey/minty,
		"monkeyspawn_foss" = /mob/living/carbon/human/npc/monkey/trovalds,
		"monkeyspawn_horse" = /mob/living/carbon/human/npc/monkey/horse,
		"monkeyspawn_krimpus" = /mob/living/carbon/human/npc/monkey/krimpus,
		"monkeyspawn_tanhony" = /mob/living/carbon/human/npc/monkey/tanhony,
		"monkeyspawn_stirstir" = /mob/living/carbon/human/npc/monkey/stirstir,
		"seamonkeyspawn" = /mob/living/carbon/human/npc/monkey/sea,
		"seamonkeyspawn_gang" = /mob/living/carbon/human/npc/monkey/sea/gang,
		"seamonkeyspawn_gang_gun" = /mob/living/carbon/human/npc/monkey/sea/gang_gun,
		"seamonkeyspawn_rich" = /mob/living/carbon/human/npc/monkey/sea/rich,
		"seamonkeyspawn_lab" = /mob/living/carbon/human/npc/monkey/sea/lab,
		"waiter" = /mob/living/carbon/human/waiter,
		"monkeyspawn_inside" = /mob/living/carbon/human/npc/monkey
		#endif
	)

	New()
		if(current_state >= GAME_STATE_WORLD_INIT && prob(spawnchance) && !src.disposed)
			SPAWN_DBG(6 SECONDS) // bluh, replace with some `initialize` variant later when someone makes it (needs to work with dmm loader)
				if(!src.disposed)
					initialize()
		..()

	initialize()
		if(prob(spawnchance))
			spawn_the_thing()
		..()

	proc/spawn_the_thing()
		if(isnull(src.type_to_spawn))
			src.type_to_spawn = name_to_type[src.name]
		if(!isnull(src.type_to_spawn))
			new type_to_spawn(src.loc)
		#ifndef IM_TESTING_FUCKING_BASIC_MOB_FUNCTIONALITY
		else
			CRASH("Spawner [src] at [src.x] [src.y] [src.z] had no type.")
		#endif
		qdel(src)

/obj/landmark/spawner/inside
	New()
		var/obj/storage/S = locate() in src.loc
		src.set_loc(S)
		..()

/obj/landmark/spawner/inside/monkey
	name = "monkeyspawn_inside"

/obj/landmark/spawner/loot
	name = "Loot spawn"
	type_to_spawn = /obj/storage/crate/loot
	spawnchance = 75

// LONG RANGE TELEPORTER
// consider refactoring to be associative the other way around later

/obj/landmark/lrt //for use with long range teleporter locations, please add new subtypes of this for new locations and use those
	name = "lrt landmark"
	name_override = LANDMARK_LRT

	New()
		src.data = src.name // store name
		..()

/obj/landmark/lrt/gemv
	name = "Geminorum V"

/obj/landmark/lrt/workshop
	name = "Hidden Workshop"

/obj/landmark/character_preview_spawn
	name = LANDMARK_CHARACTER_PREVIEW_SPAWN

/obj/landmark/viscontents_spawn
	name = "visual mirror spawn"
	desc = "Links a pair of corresponding turfs in holy Viscontent Matrimony. You shouldnt be seeing this."
	icon = 'icons/map-editing/mapeditor.dmi'
	icon_state = "landmark"
	color = "#FF0000"
	/// target z-level to push it's contents to
	var/targetZ = 1
	/// x offset relative to the landmark, will cause visual jump effect due to set_loc not gliding
	var/xOffset = 0
	/// /y offset relative to the landmark, will cause visual jump effect due to set_loc not gliding
	var/yOffset = 0
	add_to_landmarks = FALSE
	/// modifier for restricting criteria of what gets warped by mirror
	var/warptarget_modifier = LANDMARK_VM_WARP_ALL
	var/novis = FALSE

	New(var/loc, var/man_xOffset, var/man_yOffset, var/man_targetZ, var/man_warptarget_modifier)
		if (man_xOffset) src.xOffset = man_xOffset
		if (man_yOffset) src.yOffset = man_yOffset
		if (man_targetZ) src.targetZ = man_targetZ
		if (!isnull(man_warptarget_modifier)) src.warptarget_modifier = man_warptarget_modifier
		var/turf/T = get_turf(src)
		if (!T) return
		if(novis)
			var/turf/W = locate(src.x + xOffset, src.y + yOffset, src.targetZ)
			W.warptarget = T
		else
			T.appearance_flags |= KEEP_TOGETHER
			T.vistarget = locate(src.x + xOffset, src.y + yOffset, src.targetZ)
			if (T.vistarget)
				if(warptarget_modifier)
					T.vistarget.warptarget = T
				T.updateVis()
				T.vistarget.fullbright = TRUE
				T.vistarget.RL_Init()
		..()

/obj/landmark/viscontents_spawn/no_vis
	name = "instant hole spawn"
	desc = "Point it at a turf. Stuff that goes there? goes here instead. Got it?"
	novis = TRUE

/obj/landmark/viscontents_spawn/gehenna // special cases :)
	New(var/loc, var/man_xOffset, var/man_yOffset, var/man_targetZ, var/man_warptarget_modifier)
		if(map_currently_very_dusty)
			..()
		else
			qdel(src)
			return

/obj/landmark/viscontents_spawn/no_warp
	warptarget_modifier = LANDMARK_VM_WARP_NONE
/// target turf for projecting its contents elsewhere
/turf/var/turf/vistarget = null
/// target turf for teleporting its contents elsewhere
/turf/var/turf/warptarget = null
/// control who gets warped to warptarget
/turf/var/turf/warptarget_modifier = null

/turf/proc/updateVis()
	if(vistarget)
		vistarget.overlays.Cut()
		vistarget.vis_contents += src
		var/obj/overlay/tile_effect/lighting/L = locate() in vistarget.vis_contents
		if(L)
			vistarget.vis_contents -= L

/obj/landmark/load_prefab_shuttledmm
	name = "custom shuttle dmm loading location"
	desc = "Tells the dmm loader where to put the bottom left corner of the shuttle prefab."
	icon = 'icons/map-editing/mapeditor.dmi'
	icon_state = "landmark"
	color = "#ff0000"

	arrivals_preload
		name = LANDMARK_SHUTTLE_ARRIVALS_PRELOAD
		color = "#ff00FF"

	arrivals
		name = LANDMARK_SHUTTLE_ARRIVALS

	cog1
		name = LANDMARK_SHUTTLE_ESCAPE_COG1
	cog2
		name = LANDMARK_SHUTTLE_ESCAPE_COG2
	sealab
		name = LANDMARK_SHUTTLE_ESCAPE_SEALAB
	donut2
		name = LANDMARK_SHUTTLE_ESCAPE_DONUT2
	donut3
		name = LANDMARK_SHUTTLE_ESCAPE_DONUT3
	destiny
		name = LANDMARK_SHUTTLE_ESCAPE_DESTINY

/obj/landmark/drain_exit
	name = LANDMARK_DRAIN_EXIT
