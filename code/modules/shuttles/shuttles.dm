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
	//sneaky
	sound_loop_1 = 'sound/ambience/music/tane_loop_louder.ogg'
	sound_loop_1_vol = -10
	sound_loop_2 = 'sound/ambience/music/tane_loop_distorted.ogg'
	sound_loop_2_vol = 50
	sound_group = "diner" //the music's kind of everywhere isn't it
	sound_group_varied = 1

/area/shuttle/mining/outpost
	icon_state = "shuttle"
	filler_turf = "/turf/space"

/datum/transit_vehicle/mining_shuttle
	vehicle_id = "mining_shuttle"/*
#ifdef Z3_IS_A_STATION_LEVEL
	stop_ids = list("mining_dock","mining_diner")
#else*/
	stop_ids = list("mining_dock","mining_diner","mining_outpost")
//#endif

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

// YEAH YEAH YEAH YEAH YEAH YEAH OLD QM SHUTTLE YEAH YEAH
//
//
/area/shuttle/cargo
	name = "Cargo Shuttle"

/area/shuttle/cargo/station
	icon_state = "shuttle"

/area/shuttle/cargo/hub
	icon_state = "shuttle2"
	filler_turf = "/turf/space"

/datum/transit_stop/cargo_dock
	stop_id 	= "cargo_dock"
	name		= "Station Cargo Shuttle Dock"
	target_area = /area/shuttle/cargo/station

/datum/transit_stop/cargo_hub
	current_occupant = "cargo_shuttle"
	stop_id 	= "cargo_hub"
	name		= "NTFC Cargo Hub Dock"
	target_area = /area/shuttle/cargo/hub
	on_arrival()
		shippingmarket.CSS_at_NTFC = TRUE
		for(var/atom/movable/AM in locate(target_area))
			var/datum/artifact/art = null
			if(isobj(AM))
				var/obj/O = AM
				art = O.artifact
			if(art)
				shippingmarket.sell_artifact(AM, art)
			else if (istype(AM, /obj/storage/crate/biohazard/cdc))
				QM_CDC.receive_pathogen_samples(AM)
			else if (istype(AM, /obj/storage/crate))
				if (AM.delivery_destination)
					for (var/datum/trader/T in shippingmarket.active_traders)
						if (T.crate_tag == AM.delivery_destination)
							shippingmarket.sell_crate(AM, T.goods_buy)
							continue
				shippingmarket.sell_crate(AM)



/obj/machinery/computer/transit_terminal/cargo
	name = "Cargo Shuttle Service Computer"
	vehicle_id = "cargo_shuttle"

/datum/transit_vehicle/cargo_shuttle
	vehicle_id = "cargo_shuttle"

	stop_ids = list("cargo_hub","cargo_dock")

	var/departure_delay = 5 SECONDS

	var/disembark_time = 15 SECONDS


	departing(datum/transit_stop/destination)
		shippingmarket.CSS_at_NTFC = FALSE
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
				destination.on_arrival()
		sleep(disembark_time)
