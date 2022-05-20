/*******************************************************************************

	   Code & defines specific to the SPIRIT mall map.

*******************************************************************************/

/*******************************************************************************
			 Random Room Subtypes
*******************************************************************************/

TYPEINFO(/datum/mapPrefab/random_room/spirit)
	folder = "tamwip/spirit/templates"

/obj/landmark/random_room/spirit/foodhole
	apply()
		var/datum/mapPrefab/random_room/spirit/room_prefab = pick_map_prefab(/datum/mapPrefab/random_room/spirit, \
			list("foodhole"))
		if(isnull(room_prefab))
			CRASH("No random room prefab found for foodhole")
		room_prefab.applyTo(src.loc)
		logTheThing("debug", null, null, "Applied foodhole prefab to [log_loc(src)]")
		qdel(src)

