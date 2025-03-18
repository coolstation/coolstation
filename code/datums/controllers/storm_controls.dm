/datum/storm_controller
	var/list/storm_list = list()
#ifdef MAP_OVERRIDE_PERDUTA
	var/storms_to_create = 3
#else
	var/storm_to_create = 0
#endif
	/// what the tally starts at, likely negative to provide brief roundstart safety
	var/lightning_tally = -60
	/// the bonus potential that will be spread across the storms from repeated non-strikes (this is the total, not per storm)
	var/maximum_bonus = 30

	/// internally set variable used for pending up attempts to find a strikeable tile, basically a way to strike soon after someone goes outside
	var/pending_strike_attempts = 1
	/// the maximum attempts that will pend
	var/max_pending_attempts = 3

	/// internally set variable used for spawning in edges (x)
	var/x_spawn_cuberoot = 0
	/// internally set variable used for spawning in edges (y)
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
		for(var/datum/storm_cell/S in src.storm_list)
			S.move_center_to(S.x + S.drift_x, S.y + S.drift_y, S.z)
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
						var/turf_potential = src.calculate_potential_in_turf(target_turf)
						if(turf_potential > 2 && prob(turf_potential * 10))
							lightning_strike(target_turf, power = turf_potential)
							lightning_struck = TRUE
						break
		if(!lightning_struck)
			var/datum/storm_cell/S = pick(storm_list)
			if(S && S.potential_bonus < src.maximum_bonus)
				S.potential_bonus += 2
		else
			src.pending_strike_attempts = 0
			var/datum/storm_cell/S = pick(storm_list)
			if(S)
				S.potential_bonus -= 20

	proc/calculate_potential_in_turf(var/turf/T)
		return src.calculate_potential(T.x,T.y,T.z)

	proc/calculate_potential(var/x, var/y, var/z)
		. = 0
		for (var/datum/storm_cell/S in storm_list)
			if (z == S.z)
				var/dist = sqrt((x - S.x) ** 2 + (y - S.y) ** 2)

				if(dist <= S.breadth)
					. += S.potential + S.potential_bonus
				else
					. += (S.potential * sin(45.84 * (dist ** S.wavecrush) / S.breadth) + S.potential_bonus) / dist

/datum/storm_cell
	/// can it move
	var/can_drift = 1
	/// controls intensity of the initial wave
	var/potential = -240
	/// additional charge not affected by wave, but affected by distance
	var/potential_bonus = 0
	/// breadth of initial wave before wavecrush
	var/breadth = 6
	/// initial speed
	var/initial_speed = 0.5
	/// how much speed is added towards the center of the map each time it loops
	var/central_pull = 0.2
	/// controls spreading the waves wider as they get further away. higher = more broadening of waves
	var/wavecrush = 1.1

	/// tiles per tick in x dimension, set from initial_speed in New
	var/drift_x = 0
	/// tiles per tick in y dimension, set from initial_speed in New
	var/drift_y = 0

	var/x = 150
	var/y = 150
	var/z = 1

	New()
		src.drift_x = rand() * src.initial_speed
		src.drift_y = sqrt(src.initial_speed ** 2 - src.drift_x ** 2)
		if(prob(50))
			src.drift_x = -src.drift_x
		if(prob(50))
			src.drift_y = -src.drift_y
		..()

	proc/move_center_to(var/new_x, var/new_y, var/new_z)
		if (!src.can_drift) return FALSE

		//if the storm would go too far off the edge of the map, put it sorta on the opposite side, and shake up the variables a bit.
		if (new_x >= world.maxx * 1.5 || new_x <= (-world.maxx * 0.5) || new_y >= world.maxy * 1.5 || new_y <= (-world.maxy * 0.5))
			new_x = (new_x + world.maxx / 2) % (world.maxx * 2) - (world.maxx / 2)
			new_y = (new_y + world.maxy / 2) % (world.maxy * 2) - (world.maxy / 2)
			src.drift_x += src.drift_x * (rand() * 0.4 - 0.3) // the storm slows down, usually (-30% to +10% speed change, averaging -10%)
			src.drift_y += src.drift_y * (rand() * 0.4 - 0.3) // so it will lose some of its initial random inclination
			src.drift_x += (0.5 - (src.x / world.maxx)) * src.central_pull // but this bit pushes towards world center
			src.drift_y += (0.5 - (src.y / world.maxy)) * src.central_pull // as such storms grow more "aggressive" over round

		src.x = new_x
		src.y = new_y
		src.z = new_z
		return TRUE

	disposing()
		storm_controller.storm_list -= src
		..()
