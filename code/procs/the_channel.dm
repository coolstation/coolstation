//The Channel, that whacky space thing that someone broke! It's got code associated with it!

///Things that need to happen when the Channel opens
/proc/open_the_channel()
	if (channel_open)
		return
	channel_open = TRUE
	//Activate GPS visibility for earth-side telesci azones
	for_by_tcl(G, /obj/item/device/gps)
		if (G.z != Z_LEVEL_ADVENTURE)
			continue
		LAGCHECK(LAG_LOW)
		var/turf/T = get_turf(G)
		if (T in landmarks[LANDMARK_TELESCI_CHANNEL_GATED]) //not foolproof but it'll do
			G.allowtrack = TRUE

/proc/close_the_channel()
	if (!channel_open)
		return
	channel_open = FALSE
	//Hide GPS visibility for earth-side telesci azones
	for_by_tcl(G, /obj/item/device/gps)
		if (G.z != Z_LEVEL_ADVENTURE)
			continue
		LAGCHECK(LAG_LOW)
		var/turf/T = get_turf(G)
		if (T in landmarks[LANDMARK_TELESCI_CHANNEL_GATED])
			G.allowtrack = FALSE
