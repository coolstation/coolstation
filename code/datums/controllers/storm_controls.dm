/datum/storm_controller
	var/list/storm_list = list()
	var/storms_to_create = 5

	New()
		..()

#ifdef MAP_OVERRIDE_PERDUTA
		src.create_storm_cells(storms_to_create)
#endif

	proc/create_storm_cells(var/amt)
		var/datum/storm_cell/new_storm
		for (var/i = 1, i <= amt, i++)
			new_storm = new
			storm_list += new_storm
			new_storm.move_center_to(rand(5,world.maxx - 5),rand(5,world.maxy - 5),1)

	proc/process()
		for(var/datum/storm_cell/S in storm_list)
			S.move_center_to(S.center.x + S.drift_x, S.center.y + S.drift_y, S.center.z)

	proc/probe_turf(var/turf/T)
		.= 0
		for (var/datum/storm_cell/S in storm_list)
			var/turf/T2 = S.center.turf()
			if (T2 && (T.z == T2.z))
				var/dist = GET_EUCLIDEAN_DIST(T, T2) + 1

				. += (-9 * sin(45.84 * dist)) / (1.5 * dist)

	proc/remove_storm_cells(var/amt)
		var/i = 0
		for(var/datum/storm_cell/cell in storm_list)
			if(i >= amt)
				break
			qdel(cell)
			i++

/datum/storm_cell
	var/drift_x = 0
	var/drift_y = 0
	var/can_drift = 1

	var/datum/hotspot_point/center = new //going to reuse hotspot points since its there and does what i need it to

	New()
		src.drift_x = rand(2,4)
		src.drift_y = 6 - drift_x
		if(prob(50))
			src.drift_x = -src.drift_x
		if(prob(50))
			src.drift_y = -src.drift_y
		..()

	proc/move_center_to(var/x, var/y, var/z)
		if (!can_drift) return FALSE

		//if the storm would go off the edge of the map, qdel it and place a new one somewhere on the opposite side, within some random variance.
		if (x >= world.maxx || x <= 1 || y >= world.maxy || y <= 1)
			var/datum/storm_cell/new_storm = new
			storm_controller.storm_list += new_storm
			new_storm.move_center_to(x % 296 + 2, y % 296 + 2, z)
			new_storm.drift_x = src.drift_x + rand(-1,1)
			new_storm.drift_y = src.drift_y + rand(-1,1)
			if(!new_storm.drift_x && !new_storm.drift_y) // if it stalls out, beeline for the center of the station instead
				new_storm.drift_x = floor((new_storm.center.x - 150) / -25)
				new_storm.drift_y = floor((new_storm.center.y - 150) / -25)
			qdel(src)
			return FALSE

		center.change(x,y,z)
		return TRUE

	disposing()
		storm_controller.storm_list -= src
		qdel(center)
		center = null
		..()
