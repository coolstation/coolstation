/datum/storm_controller
	var/list/storm_list = list()
	var/storms_to_create = 5

	New()
		..()

#ifdef MAP_OVERRIDE_PERDUTA
		create_storm_cells(storms_to_create)
#endif

	proc/create_storm_cells(var/amt)
		var/datum/storm_cell/new_storm
		for (var/i = 1, i <= amt, i++)
			new_storm = new
			storm_list += new_storm
			var/turf/T = locate(rand(1,world.maxx),rand(1,world.maxy), 1)
			new_storm.move_center_to(T)

	proc/process()
		for(var/datum/storm_cell/S in storm_list)
			S.drift_count += S.drift_speed
			while (S.drift_count >= 1)
				S.drift_count--
				if (!S.move_center_to(get_step(S.center.turf(), S.drift_dir)))
					break

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
			if(i > amt)
				break
			qdel(cell)
			i++

/datum/storm_cell
	var/drift_dir = 0
	var/can_drift = 1
	var/drift_speed = 3.35 //amount of movements per tick
	var/drift_count = 0

	var/datum/hotspot_point/center = new //going to reuse hotspot points since its there and does what i need it to
	var/radius = 8

	New()
		drift_dir = pick(alldirs)
		..()

	proc/move_center_to(var/turf/new_center)
		if (!istype(new_center)) return FALSE
		if (!can_drift) return FALSE

		//if the storm would go off the edge of the map, qdel it and place a new one somewhere on the opposite side, within some random variance.
		if (new_center.x >= world.maxx || new_center.x <= 1 || new_center.y >= world.maxy || new_center.y <= 1)
			var/datum/storm_cell/new_storm = new
			storm_controller.storm_list += new_storm
			var/turf/T = locate((rand(-30,30) + new_center.x) % 300, ((rand(-30,30) + new_center.y) % 300), new_center.z)
			new_storm.move_center_to(T)
			qdel(src)
			return FALSE

		center.change(new_center.x,new_center.y,new_center.z)
		return TRUE

	disposing()
		storm_controller.storm_list -= src
		qdel(center)
		center = null
		..()
