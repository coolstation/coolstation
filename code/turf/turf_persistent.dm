//Here's an idea I stole from pali (that AFAIK they haven't implemented at all yet over on goon)
//It's a datum of all the stuff that needs to persist between turf replacements
//so ReplaceWith can stop being a proc that largely shovels vars from one turf to the next
/datum/turf_persistent
	#ifdef ATMOS_PROCESS_CELL_STATS_TRACKING
	var/tmp/process_cell_operations = 0
	#endif
	///multiplicative RL overlay (full darkness to "normal" sprite colours/fullbright)
	var/obj/overlay/tile_effect/lighting/mul/RL_MulOverlay = null
	///additive RL overlay (brighter than normal/fullbright)
	var/obj/overlay/tile_effect/lighting/add/RL_AddOverlay = null

	var/RL_ApplyGeneration = 0
	var/RL_UpdateGeneration = 0

	//var/RL_LumR = 0
	//var/RL_LumG = 0
	//var/RL_LumB = 0

	//colouration of RL additive overlay
	var/RL_AddLumR = 0
	var/RL_AddLumG = 0
	var/RL_AddLumB = 0

	//turf has any additive
	var/RL_NeedsAdditive = 0

	//List of light datums that have some influence on this turf
	var/list/datum/light/RL_Lights = null

	var/opaque_atom_count = 0

	//.turf_persistent.
