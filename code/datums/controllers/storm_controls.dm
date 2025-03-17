/datum/storm_controller
	var/list/storm_list = list()
#ifdef MAP_OVERRIDE_PERDUTA
	var/storms_to_create = 3
#else
	var/storm_to_create = 0
#endif
	var/lightning_tally = -60 // brief period of safety
	var/pending_strike_attempts = 1
	var/max_pending_attempts = 3
	var/maximum_bonus = 3
	var/x_spawn_cuberoot = 0
	var/y_spawn_cuberoot = 0

	New()
		..()

		src.x_spawn_cuberoot = floor((world.maxx * 1.5) ** (1/3)) // we want to generate in the edges of the triple size map more often
		src.y_spawn_cuberoot = floor((world.maxy * 1.5) ** (1/3))
		if(storms_to_create)
			src.create_storm_cells(storms_to_create)

	proc/create_storm_cells(var/amt)
		if(amt)
			var/datum/storm_cell/new_storm
			if(length(src.storm_list))
				src.maximum_bonus = src.maximum_bonus * length(src.storm_list)
			for (var/i = 1, i <= amt, i++)
				new_storm = new
				storm_list += new_storm
				new_storm.move_center_to(rand(-src.x_spawn_cuberoot,src.x_spawn_cuberoot) ** 3, rand(-src.y_spawn_cuberoot,src.y_spawn_cuberoot) ** 3, 1)
			src.maximum_bonus = src.maximum_bonus / length(src.storm_list)

	proc/remove_storm_cells(var/amt)
		var/i = 0
		if(length(src.storm_list))
			src.maximum_bonus = src.maximum_bonus * length(src.storm_list)
			for(var/datum/storm_cell/cell in storm_list)
				if(i >= amt)
					break
				qdel(cell)
				i++
			if(length(src.storm_list))
				src.maximum_bonus = src.maximum_bonus / length(src.storm_list)
			else
				src.maximum_bonus = initial(src.maximum_bonus)

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
			var/list/mob/living/lightning_targets = list()
			for(var/client/target_client in global.clients)
				if(!target_client.mob || !isliving(target_client.mob))
					continue
				lightning_targets |= target_client.mob
			if(!length(lightning_targets))
				return
			var/total_strikes = ceil(length(lightning_targets) / 15)
			while(lightning_attempts < total_strikes)
				lightning_attempts++
				var/mob/target = pick(lightning_targets)
				var/turf/T = get_turf(target)
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
			if(S && S.potential_bonus < src.maximum_bonus)
				S.potential_bonus += 0.2
		else
			src.pending_strike_attempts = 0
			var/datum/storm_cell/S = pick(storm_list)
			if(S)
				S.potential_bonus -= 2

	proc/probe_turf(var/turf/T)
		.= 0
		for (var/datum/storm_cell/S in storm_list)
			if (T.z == S.center.z)
				var/dist = sqrt((T.x - S.center.x) ** 2 + (T.y - S.center.y) ** 2)

				if(dist <= S.falloff)
					. += S.potential + S.potential_bonus - 5
				else
					dist += S.falloff
					. += S.falloff * (S.potential * sin(45.84 * dist / S.falloff) + S.potential_bonus) / dist

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

		//if the storm would go too far off the edge of the map, put it sorta on the opposite side, and shake up the variables a bit.
		if (x >= world.maxx * 2 || x <= -world.maxx || y >= world.maxy * 2 || y <= -world.maxy)
			x = x % (world.maxx * 3) - world.maxx
			y = y % (world.maxy * 3) - world.maxy
			src.drift_x += src.drift_x * rand(-2,2) / 10
			src.drift_y += src.drift_y * rand(-2,2) / 10
			if((src.drift_x ** 2 + src.drift_y ** 2) < (src.initial_speed / 2)) // if it stalls out, beeline for the center of the station instead
				src.drift_x = (src.center.x - (world.maxx / 2)) / (-world.maxx / 4)
				src.drift_y = (src.center.y - (world.maxy / 2)) / (-world.maxy / 4)

		center.change(x,y,z)
		return TRUE

	disposing()
		storm_controller.storm_list -= src
		qdel(center)
		center = null
		..()
