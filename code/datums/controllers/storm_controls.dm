/datum/storm_controller
	var/list/storm_list = list()
	var/storms_to_create = 10

	New()
		..()

		#ifdef MAP_OVERRIDE_PERDUTA
		var/datum/storm_cell/new_storm = 0
		for (var/i = 1, i <= storms_to_create, i++)
			new_storm = new
			storm_list += new_storm
			var/turf/T = locate(rand(1,world.maxx),rand(1,world.maxy), 1)
			new_storm.move_center_to(T)
		#endif

	proc/process()
		for(var/datum/storm_cell/S in storm_list)
			S.drift_count++
			if (S.drift_count >= S.drift_speed)
				S.drift_count = 0
				S.move_center_to(get_step(S.center.turf(), S.drift_dir))

	proc/probe_turf(var/turf/T)
		.= 0
		for (var/datum/storm_cell/S in storm_list)
			var/turf/T2 = S.center.turf()
			var/dist = GET_DIST(T, T2)

			. += (-9 * sin(45.84 * dist)) / (1.5 * (dist + 1))

	proc/clear()
		storm_list.len = 0

/datum/storm_cell
	var/drift_dir = 0
	var/can_drift = 1
	var/drift_speed = 1 //amount of ticks it takes to move
	var/drift_count = 0

	var/datum/hotspot_point/center = new //going to reuse hotspot points since its there and does what i need it to
	var/radius = 8

	New()
		..()

	proc/move_center_to(var/turf/new_center)
		if (!istype(new_center)) return
		if (!can_drift) return

		//if the storm would go off the edge of the map, qdel it and place a new one somewhere on the opposite side, within some random variance.
		if (new_center.x >= world.maxx || new_center.x <= 1 || new_center.y >= world.maxy || new_center.y <= 1)
			var/datum/storm_cell/new_storm = new
			storm_controller.storm_list += new_storm
			var/turf/T = locate((rand(-30,30) + new_center.x) % 300, ((rand(-30,30) + new_center.y) % 300), new_center.z)
			new_storm.move_center_to(T)
			qdel(src)
			return

		center.change(new_center.x,new_center.y,new_center.z)


