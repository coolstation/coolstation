/datum/controller/process/area_clearer
	var/list/area/bad_areas = list()

/datum/controller/process/area_clearer/setup()
		name = "area turf clearer"
		schedule_interval = 0.5 SECONDS

/datum/controller/process/area_clearer/doWork()
	var/list/area/iterated_over = list()
	for(var/area/area in world) // FUCK
		iterated_over += area
	while(length(iterated_over))
		LAGCHECK(LAG_REALTIME)
		var/area/iteration = iterated_over[length(iterated_over)]
		for (var/z in 1 to length(iteration.bad_turfs_by_z))
			if(length(iteration.bad_turfs_by_z[z]) < 128)
				continue
			bad_areas |= iteration
			break
		iterated_over.len -= 1
	while(length(bad_areas))
		var/area/bad_area = bad_areas[length(bad_areas)]
		var/bad_len = length(bad_area.bad_turfs_by_z)
		for (var/z in 1 to bad_len)
			if (!length(bad_area.bad_turfs_by_z[z]))
				continue
			bad_area.turfs_by_z[z] -= bad_area.bad_turfs_by_z[z] // this isnt great for big lists but its probably fine because the only time we do this is during mapgen
			LAGCHECK(LAG_REALTIME)
		bad_area.bad_turfs_by_z.Cut()
		bad_areas.len -= 1 //remove the stuff we did like right now
