#define FIREFLASH_HOTSPOT_TIME 2 SECONDS

/proc/fireflash(atom/center, radius, ignoreUnreachable, energy)
	tfireflash(center, radius, rand(2800,3200), ignoreUnreachable, energy)

/proc/tfireflash(atom/center, radius, temp, ignoreUnreachable, energy)
	if (locate(/obj/blob/firewall) in center)
		return
	for(var/turf/T in range(radius,get_turf(center)))
		if(istype(T, /turf/space) || T.loc:sanctuary) continue
		if(!ignoreUnreachable && !can_line(get_turf(center), T, radius+1)) continue
		for(var/obj/spacevine/V in T) qdel(V)
//		for(var/obj/kudzu_marker/M in T) qdel(M)
//		for(var/obj/alien/weeds/V in T) qdel(V)

		var/obj/hotspot/fireflash/hotspot = locate(/obj/hotspot/fireflash) in T
		if (locate(/obj/fire_foam) in T)
			if(hotspot)
				hotspot.dispose()
				qdel(hotspot)
			continue
		if (hotspot)
			hotspot.time_to_die = world.time + FIREFLASH_HOTSPOT_TIME
			hotspot.temperature = max(hotspot.temperature,temp)
		else
			hotspot = new(FIREFLASH_HOTSPOT_TIME)
			hotspot.temperature = temp
			hotspot.set_loc(T)

		hotspot.volume = 400
		hotspot.set_real_color()
		T.hotspot_expose(hotspot.temperature, hotspot.volume)

/*// experimental thing to let temporary hotspots affect atmos
		h.perform_exposure()
*/
		//SPAWN_DBG(1.5 SECONDS) T.hotspot_expose(2000, 400)

		if(istype(T, /turf/floor)) T:burn_tile()
		SPAWN_DBG(0)
			for(var/mob/living/L in T)
				L.set_burning(33-radius)
				L.bodytemperature = max(temp/3, L.bodytemperature)
				LAGCHECK(LAG_REALTIME)
			for(var/obj/critter/C in T)
				if(istype(C, /obj/critter/zombie)) C.health -= 15
				C.health -= (30 * C.firevuln)
				C.check_health()
				SPAWN_DBG(0.5 SECONDS)
					if(C)
						C.health -= (2 * C.firevuln)
						C.check_health()
					sleep(0.5 SECONDS)
					if(C)
						C.health -= (2 * C.firevuln)
						C.check_health()
					sleep(0.5 SECONDS)
					if(C)
						C.health -= (2 * C.firevuln)
						C.check_health()
					sleep(0.5 SECONDS)
					if(C)
						C.health -= (2 * C.firevuln)
						C.check_health()
					sleep(0.5 SECONDS)
					if(C)
						C.health -= (2 * C.firevuln)
						C.check_health()
					sleep(0.5 SECONDS)
					if(C)
						C.health -= (2 * C.firevuln)
						C.check_health()
				LAGCHECK(LAG_REALTIME)

/proc/fireflash_s(atom/center, radius, temp, falloff, energy)
	if (locate(/obj/blob/firewall) in center)
		return list()
	if (temp < T0C + 60)
		return list()
	var/list/open = list()
	var/list/affected = list()
	var/list/obj/hotspot/fireflash/affected_hotspots = list()
	var/list/closed = list()
	var/turf/Ce = get_turf(center)
	var/max_dist = radius
	if (falloff)
		max_dist = min((temp - (T0C + 60)) / falloff, radius)
	open[Ce] = 0
	while (open.len)
		var/turf/T = open[1]
		var/dist = open[T]
		open -= T
		closed += T

		if (!T || istype(T, /turf/space) || T.loc:sanctuary)
			continue
		if (dist > max_dist)
			continue
		if (!ff_cansee(Ce, T))
			continue

		var/falloff_affected_temp = temp - dist * falloff
		var/obj/hotspot/fireflash/hotspot = locate(/obj/hotspot/fireflash) in T
		if (locate(/obj/fire_foam) in T)
			if(hotspot)
				hotspot.dispose()
				qdel(hotspot)
			continue
		if (hotspot)
			hotspot.time_to_die = world.time + FIREFLASH_HOTSPOT_TIME
			hotspot.temperature = max(hotspot.temperature,falloff_affected_temp)
		else
			hotspot = new(FIREFLASH_HOTSPOT_TIME)
			hotspot.temperature = falloff_affected_temp
			hotspot.set_loc(T)
		affected_hotspots += hotspot

		hotspot.volume = 400
		hotspot.set_real_color()
		T.hotspot_expose(hotspot.temperature, hotspot.volume)

		if(istype(T, /turf/floor)) T:burn_tile()
		for (var/mob/living/L in T)
			L.update_burning(min(55, max(0, falloff_affected_temp - 100 / 550)))
			L.bodytemperature = (2 * L.bodytemperature + falloff_affected_temp) / 3
		SPAWN_DBG(0)
			for (var/obj/critter/C in T)
				C.health -= (30 * C.firevuln)
				C.check_health()
				LAGCHECK(LAG_REALTIME)

		if (T.density)
			continue
		for (var/obj/O in T)
			if (O.density)
				continue
		if (dist == max_dist)
			continue

		for (var/dir in cardinal)
			var/turf/link = get_step(T, dir)
			if (!link)
				continue
			var/dx = link.x - Ce.x
			var/dy = link.y - Ce.y
			var/target_dist = max((dist + 1 + sqrt(dx * dx + dy * dy)) / 2, dist)
			if (!(link in closed))
				if (link in open)
					if (open[link] > target_dist)
						open[link] = target_dist
				else
					open[link] = target_dist
		var/datum/component/updraft/up = T.GetComponent(/datum/component/updraft)
		if(up)
			var/turf/link = up.TargetTurf
			if (!link)
				continue
			var/target_dist = dist + 1
			if (!(link in closed))
				if (link in open)
					if (open[link] > target_dist)
						open[link] = target_dist
				else
					open[link] = target_dist

		LAGCHECK(LAG_REALTIME)

	var/hotspot_energy = energy / length(affected_hotspots)
	for(var/obj/hotspot/fireflash/hotspot in affected_hotspots)
		hotspot.thermal_energy += hotspot_energy
	return affected


/proc/fireflash_sm(atom/center, radius, temp, falloff, capped = 1, bypass_RNG = 0, energy)
	var/list/affected = fireflash_s(center, radius, temp, falloff, energy)
	for (var/turf/T in affected)
		if (issimulatedturf(T) && !T.loc:sanctuary)
			var/mytemp = affected[T]
			var/melt = 1643.15 // default steel melting point
			if (T.material && T.material.hasProperty("flammable") && ((T.material.material_flags & MATERIAL_METAL) || (T.material.material_flags & MATERIAL_CRYSTAL) || (T.material.material_flags & MATERIAL_RUBBER)))
				melt = melt + (((T.material.getProperty("flammable") - 50) * 15)*(-1)) //+- 750° ?
			var/divisor = melt
			if (mytemp >= melt * 2)
				var/chance = mytemp / divisor
				if (capped)
					chance = min(chance, T:default_melt_cap)
				if (prob(chance) || bypass_RNG) // The bypass is for thermite (Convair880).
					//T.visible_message("<span class='alert'>[T] melts!</span>")
					T.burn_down()
		LAGCHECK(LAG_REALTIME)

	return affected

var/list/obj/hotspot/fireflash/fireflashes = list()

/obj/hotspot/fireflash
	layer = FIREFLASH_LAYER
	plane = PLANE_DEFAULT
	var/time_to_die
	var/thermal_energy = 0
	cleanup_active = FALSE
	event_handler_flags = CAN_UPDRAFT

	New(var/time_to_live = 1.5 SECONDS, var/energy = 0)
		..()
		src.time_to_die = world.time + time_to_live
		src.thermal_energy = energy
		fireflashes += src

	process(list/turf/possible_spread)
		if (just_spawned)
			just_spawned = 0
			return 0

		var/turf/floor/location = loc
		if (!istype(location) || (locate(/obj/fire_foam) in location))
			src.dispose()
			qdel(src)
			return 0

		if(src.thermal_energy)
			impart_energy(location)

		if(world.time > src.time_to_die)
			src.dispose()
			qdel(src)
			return 0

		if ((temperature < FIRE_MINIMUM_TEMPERATURE_TO_EXIST) || (volume <= 1))
			src.dispose()
			qdel(src)
			return 0

		for (var/mob/living/L in loc)
			L.update_burning(min(max(temperature / 60, 5),33))

		if (volume > (CELL_VOLUME * 0.4))
			icon_state = "2"
		else
			icon_state = "1"

		return 1

	set_loc(newloc)
		var/obj/hotspot/fireflash/hotspot = locate(/obj/hotspot/fireflash) in newloc
		if (hotspot)
			hotspot.time_to_die = max(hotspot.time_to_die,src.time_to_die) + FIREFLASH_HOTSPOT_TIME
			hotspot.temperature = max(hotspot.temperature,src.temperature)
			qdel(src)
			return
		. = ..()

	disposing()
		fireflashes -= src
		..()

	proc/impart_energy(var/turf/location)
		if (!location?.air)
			qdel(src)
			return

		location.air.temperature += src.thermal_energy / HEAT_CAPACITY(location.air) * 0.6

		src.thermal_energy = src.thermal_energy * 0.4
