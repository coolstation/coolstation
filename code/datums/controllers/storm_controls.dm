/datum/storm_controller
	var/list/storm_list = list()
#ifdef MAP_OVERRIDE_PERDUTA
	var/storms_to_create = 3
#else
	var/storm_to_create = 0
#endif
	var/lightning_tally = 0
	var/pending_strike_attempts = 1
	var/max_pending_attempts = 3

	New()
		..()

		src.create_storm_cells(storms_to_create)
		for(var/datum/storm_cell/S in storm_list) // slow down the storm early on
			S.potential_bonus -= 15 / length(storm_list)

	proc/create_storm_cells(var/amt)
		var/datum/storm_cell/new_storm
		for (var/i = 1, i <= amt, i++)
			new_storm = new
			storm_list += new_storm
			new_storm.move_center_to(rand(5,world.maxx - 5),rand(5,world.maxy - 5),1)

	proc/process()
		for(var/datum/storm_cell/S in storm_list)
			S.partial_x += S.drift_x
			S.partial_y += S.drift_y
			S.move_center_to(S.center.x + floor(S.partial_x), S.center.y + floor(S.partial_y), S.center.z)
			S.partial_x = S.partial_x % 1
			S.partial_y = S.partial_y % 1
			src.lightning_tally += S.potential_bonus
		var/lightning_struck = FALSE
		var/lightning_attempts = 0
		if(prob(ceil(lightning_tally)))
			src.lightning_tally = 0
			src.pending_strike_attempts = min(src.pending_strike_attempts + 1, src.max_pending_attempts)
			var/list/client/lightning_targets = clients
			var/total_strikes = ceil(lightning_targets / 15)
			while(lightning_attempts < total_strikes)
				var/client/target = pick(lightning_targets)
				if(!target.mob || !isliving(target.mob))
					lightning_targets -= target
					if(!lightning_targets.len)
						break
					continue
				lightning_attempts++
				var/turf/T = get_turf(target.mob)
				for(var/i = 1, i <= src.pending_strike_attempts, i++)
					var/turf/target_turf = locate(T.x + rand(-10,10), T.y + rand(-7,7), T.z)
					if(istype(target_turf,/turf/space/magindara) || locate(/obj/overlay/magindara_skylight) in target_turf)
						var/turf_potential = src.probe_turf(target_turf)
						if(turf_potential > 0)
							lightning_strike(target_turf, power = turf_potential * 8 + 4)
							lightning_struck = TRUE
						break
		if(!lightning_struck)
			var/datum/storm_cell/S = pick(storm_list)
			if(S)
				S.potential_bonus += 0.2
		else
			src.pending_strike_attempts = 0
			var/datum/storm_cell/S = pick(storm_list)
			if(S)
				S.potential_bonus -= 2

	proc/probe_turf(var/turf/T)
		.= 0
		for (var/datum/storm_cell/S in storm_list)
			var/turf/T2 = S.center.turf()
			if (T2 && (T.z == T2.z))
				var/dist = GET_EUCLIDEAN_DIST(T, T2)

				if(dist <= S.falloff)
					. += S.potential + S.potential_bonus - 5
				else
					dist += S.falloff
					. += S.falloff * (S.potential * sin(45.84 * dist / S.falloff) + S.potential_bonus) / dist

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
	var/partial_x = 0
	var/partial_y = 0
	var/can_drift = 1
	var/potential = -6
	var/potential_bonus = 0
	var/falloff = 5
	var/initial_speed = 0.4

	var/datum/hotspot_point/center = new //going to reuse hotspot points since its there and does what i need it to

	New()
		src.drift_x = rand() * src.initial_speed
		src.drift_y = sqrt(src.initial_speed ** 2 - src.drift_x ** 2)
		if(prob(50))
			src.drift_x = -src.drift_x
		if(prob(50))
			src.drift_y = -src.drift_y
		..()

	proc/move_center_to(var/x, var/y, var/z)
		if (!src.can_drift) return FALSE

		//if the storm would go off the edge of the map, put it on the opposite side, and shake up the variables a bit.
		if (x >= world.maxx || x <= 1 || y >= world.maxy || y <= 1)
			x = x % 298 + 2
			y = y % 298 + 2
			src.drift_x = src.drift_x * rand(8,11) / 10
			src.drift_y = src.drift_y * rand(8,11) / 10
			if((src.drift_x ** 2 + src.drift_y ** 2) < (src.initial_speed / 2)) // if it stalls out, beeline for the center of the station instead
				src.drift_x = (src.center.x - (world.maxx / 2)) / (-world.maxx / 3)
				src.drift_y = (src.center.y - (world.maxy / 2)) / (-world.maxy / 3)

		center.change(x,y,z)
		return TRUE

	disposing()
		storm_controller.storm_list -= src
		qdel(center)
		center = null
		..()
