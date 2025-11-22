var/global/list/teleareas

proc/get_teleareas()
	if (isnull(teleareas))
		generate_teleareas()
		teleareas = sortList(teleareas)
	return teleareas

proc/get_telearea(var/name)
	var/list/areas = get_teleareas()
	return areas[name]
/*
proc/generate_teleareas() // holy fucking SHIT this is INSANE
	var/area/a
	LAGCHECK(LAG_HIGH)
	teleareas = list()
	for (var/turf/T in bounds(1, 1, world.maxx * world.icon_size, world.maxy * world.icon_size, 1))
		a = T.loc
		// this is gross sorry
		if (!a || !isarea(a) || teleareas.Find(a.name) || istype(a, /area/cordon) || a.type == "/area" || a.name == "Space")
			continue
		if (istype(a, /area/wizard_station))
			var/entry = text("* []", a.name)
			teleareas[entry] = a
			continue
		teleareas[a.name] = a
	teleareas = sortList(teleareas)
*/


proc/generate_teleareas()
	LAGCHECK(LAG_HIGH)
	teleareas = list()
	for (var/area/area in world)
		if (!length(area.turfs)) continue
		if (istype(area, /area/station))
			var/turf/T = area.turfs[1]
			//why is Z_LEVEL_DEBRIS not a thing on underwater maps?
			#ifndef UNDERWATER_MAP
			if (T?.z == Z_LEVEL_STATION || (map_currently_very_dusty && T?.z == Z_LEVEL_DEBRIS))
				teleareas[area.name] = area
			#else
			if (T?.z == Z_LEVEL_STATION)
				teleareas[area.name] = area
			#endif
		if (istype(area, /area/diner))
			var/turf/T = area.turfs[1]
			if (T?.z == Z_LEVEL_MINING)
				teleareas[area.name] = area
		if(istype(area, /area/wizard_station))
			teleareas[area.name] = area

