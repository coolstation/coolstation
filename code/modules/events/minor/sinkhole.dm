// gehenna sinkhole

/datum/random_event/minor/targetable/two_layer_sinkhole
	name = "Deep Sinkhole"
	disabled = 1
	announce_to_admins = 0
	customization_available = 0

	event_effect(var/source,var/turf/center)
		..()

		if (!istype(center))
			return

		playsound(center, "sound/misc/ground_rumble_big.ogg", 50, 1, 3)
		SPAWN_DBG(rand(8 SECONDS, 12 SECONDS))
			create_two_layer_sinkhole(center, 2, 2 SECONDS)

proc/create_two_layer_sinkhole(var/turf/center, var/size = 3, var/delay = 2 SECONDS, target_z = 3)
	if (!istype(center))
		return FALSE
	if (!isnum(size) || size < 1)
		return FALSE

	var/current_range = 0
	var/corner_range = round(size * 1.5)

	if (!center.density)
		var/turf/below = locate(center.x,center.y,target_z)
		if(!below.density)
			center = center.ReplaceWith(/turf/floor/specialroom/two_layer_sinkhole)
			center.AddComponent(/datum/component/pitfall/target_coordinates,\
				BruteDamageMax = 20,\
				HangTime = 0.3 SECONDS,\
				TargetZ = target_z,\
				LandingRange = 0)

	SPAWN_DBG(delay)
		playsound(center, "sound/misc/ground_rumble_big.ogg", 50, 1)
		while (current_range < size - 1)
			current_range++
			var/total_distance = 0
			var/list/turf/floor/specialroom/two_layer_sinkhole/affected_circle = list()
			for (var/turf/S in orange(current_range,center))
				if (S.density)
					continue
				if (get_dist(S,center) != current_range)
					continue
				total_distance = abs(center.x - S.x) + abs(center.y - S.y) + (current_range / 2)
				if (total_distance > corner_range)
					continue
				var/turf/below = locate(S.x,S.y,target_z)
				if(below.density)
					continue // to do, make this better
				var/turf/sinkhole = S.ReplaceWith(/turf/floor/specialroom/two_layer_sinkhole)
				sinkhole.AddComponent(/datum/component/pitfall/target_coordinates,\
					BruteDamageMax = 25,\
					HangTime = 0.2 SECONDS,\
					TargetZ = target_z)
				affected_circle += sinkhole
			for (var/turf/floor/specialroom/two_layer_sinkhole/sinkhole in affected_circle)
				sinkhole.calculate_direction(FALSE)
			sleep(delay)
	return TRUE

/turf/floor/specialroom/two_layer_sinkhole
	name = "sinkhole"
	desc = "That looks dangerous! Better not jump in."
	icon_state = "moon_shaft"
	has_material = FALSE //this is a big hole, the big hole is made of steel? yeah right buddy!!!

	proc/calculate_direction(var/propagate = FALSE)
		var/turf/floor/specialroom/two_layer_sinkhole/n = get_step(src,NORTH)
		var/turf/floor/specialroom/two_layer_sinkhole/e = get_step(src,EAST)
		var/turf/floor/specialroom/two_layer_sinkhole/w = get_step(src,WEST)
		var/turf/floor/specialroom/two_layer_sinkhole/s = get_step(src,SOUTH)

		if (!istype(n))
			n = null
		if (!istype(e))
			e = null
		if (!istype(w))
			w = null
		if (!istype(s))
			s = null

		if (n && e && w && s)
			src.icon_state = "shaft_center"
		else if (e && w && s)
			set_dir(NORTH)
		else if (n && e && w)
			set_dir(SOUTH)
		else if (n && w && s)
			set_dir(EAST)
		else if (n && e && s)
			set_dir(WEST)
		else if (n && e)
			set_dir(SOUTHWEST)
		else if (e && s)
			set_dir(NORTHWEST)
		else if (n && w)
			set_dir(SOUTHEAST)
		else if (s && w)
			set_dir(NORTHEAST)
		else
			src.icon_state = "shaft_single"

		if (propagate)
			n?.calculate_direction(FALSE)
			e?.calculate_direction(FALSE)
			w?.calculate_direction(FALSE)
			s?.calculate_direction(FALSE)

	ex_act(severity)
		return
