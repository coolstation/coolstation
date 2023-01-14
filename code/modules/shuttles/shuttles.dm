// this contains individual shuttle definitions.


/datum/transit_stop/mining_dock
	stop_id 	= "mining_dock"
	name		= "Station Mining Shuttle Dock"
	target_area = /area/shuttle/mining/station

/datum/transit_stop/mining_diner
	current_occupant = "mining_shuttle"
	stop_id 	= "mining_diner"
	name		= "Diner Shuttle Dock"
	target_area = /area/shuttle/mining/space

/datum/transit_stop/mining_outpost
	stop_id 	= "mining_outpost"
	name		= "Mining Outpost Shuttle Dock"
	target_area = /area/shuttle/mining/outpost

/area/shuttle/mining/station
	icon_state = "shuttle"


/area/shuttle/mining/space
	icon_state = "shuttle2"
	filler_turf = "/turf/space"

/area/shuttle/mining/outpost
	icon_state = "shuttle"
	filler_turf = "/turf/space"

/datum/transit_vehicle/mining_shuttle
	vehicle_id = "mining_shuttle"
#ifdef DESERT_MAP
	stop_ids = list("mining_dock","mining_diner")
#else
	stop_ids = list("mining_dock","mining_diner","mining_outpost")
#endif

	var/departure_delay = 8 SECONDS

	var/disembark_time = 2 SECONDS


	departing(datum/transit_stop/destination)
		var/turf/target
		for(var/turf/T in locate(src.current_location.target_area))
			target = T
			break
		if(target)
			playsound(target, "sound/effects/ship_charge.ogg", 70, 1)
		else
			stack_trace("Vehicle [src.vehicle_id] had no turfs at stop [src.current_location.stop_id] ([src.current_location.target_area])")
			return
		sleep(departure_delay)
		playsound(target, "sound/misc/ground_rumble_big.ogg", 70, 1)
		for(var/mob/M in locate(destination.target_area)) // oh dear, stay behind the yellow line kids
			SPAWN_DBG(1 DECI SECOND)
				random_brute_damage(M, 60)
				M.changeStatus("weakened", 5 SECONDS)
				M.emote("scream")
				playsound(M.loc, "sound/impact_sounds/Flesh_Break_1.ogg", 90, 1)

	arriving(datum/transit_stop/destination)
		var/turf/target
		for(var/turf/T in locate(destination.target_area))
			target = T
			break
		if(target)
			playsound(target, "sound/machines/hiss.ogg", 50, 1)
			SPAWN_DBG(1 DECI SECOND)
				playsound(target, "sound/items/Deconstruct.ogg", 65, 1)
		sleep(disembark_time)

/obj/machinery/computer/transit_terminal/mining
	vehicle_id = "mining_shuttle"
