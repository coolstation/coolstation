//Here's an idea I stole from pali (that AFAIK they haven't implemented at all yet over on goon)
//It's a datum of all the stuff that needs to persist between turf replacements
//so ReplaceWith can stop being a proc that largely shovels vars from one turf to the next
/datum/turf_persistent
	#ifdef ATMOS_PROCESS_CELL_STATS_TRACKING
	var/tmp/process_cell_operations = 0
	#endif

	//----------------ATOM PROC TRACKING

	var/tmp/checkingexit = 0 //value corresponds to how many objs on this turf implement checkexit(). lets us skip a costly loop later!
	var/tmp/checkingcanpass = 0 // "" how many implement canpass()
	var/tmp/checkinghasentered = 0 // "" hasproximity as well as items with a mat that hasproximity

	//checkinghasproximity is still on turfs because some turfs with immediately spawn crap on top of them,
	// which then causes it to try and check checkinghasproximity on turfs that haven't had a chance to init turf_persistent yet

	/// directions of this turf being blocked by directional blocking objects. So we don't need to loop through the entire contents
	var/tmp/blocked_dirs = 0

	//----------------LIGHTING

	///multiplicative RL overlay (full darkness to "normal" sprite colours/fullbright)
	var/obj/overlay/tile_effect/lighting/mul/RL_MulOverlay = null
	///additive RL overlay (brighter than normal/fullbright)
	var/obj/overlay/tile_effect/lighting/add/RL_AddOverlay = null

	var/RL_ApplyGeneration = 0
	var/RL_UpdateGeneration = 0

	//colouration of the RL multiplicative overlay (I think)
	var/RL_LumR = 0
	var/RL_LumG = 0
	var/RL_LumB = 0

	//colouration of RL additive overlay
	var/RL_AddLumR = 0
	var/RL_AddLumG = 0
	var/RL_AddLumB = 0

	//turf has any additive
	var/RL_NeedsAdditive = 0

	//List of light datums that have some influence on this turf
	var/list/datum/light/RL_Lights = null

	var/opaque_atom_count = 0

	///Things that are hidden "in" this turf that are revealed when it is pried up.
	///Kept in a hidden object on the turf so that `get_turf` works as normal. Yes this is crime, fight me I have a possum.
	var/obj/effects/hidden_contents_holder/hidden_contents = null

	//.turf_persistent.
