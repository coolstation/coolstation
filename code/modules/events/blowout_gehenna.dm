/datum/random_event/major/blowout_gehenna
	name = "Radioactive Blowout (Gehenna)"
	required_elapsed_round_time = 20 MINUTES
	var/space_color = "#ff4646"
#ifndef DESERT_MAP
	disabled = TRUE
#endif

	event_effect() //Gehenna's blowouts are simpler because we just want to nuke all of z1
		..()
		var/timetoreachsec = rand(1,9)
		var/timetoreach = rand(30,60)
		var/actualtime = timetoreach * 10 + timetoreachsec

		for (var/mob/M in mobs)
			M.flash(3 SECONDS)
		var/sound/siren = sound('sound/misc/airraid_loop.ogg')
		siren.repeat = TRUE
		siren.channel = 5
		siren.volume = 75 // wire note: lets not deafen players with an air raid siren
		world << siren
		command_alert("Extreme levels of radiation detected approaching the planet surface. All personnel have [timetoreach].[timetoreachsec] seconds to reach the tunnel level. This is not a test.", "Anomaly Alert")

		var/datum/directed_broadcast/emergency/broadcast = new(station_name, "Radiation Storm", "[timetoreach] Seconds", "Seek shelter underground immediately. Do not use elevators.")
		broadcast_controls.broadcast_start(broadcast, TRUE, set_loops = -1, process_immediately = TRUE)

		SPAWN_DBG(0)
			//The normal blowout zeroes out maint airlock access here
			sleep(actualtime)

			for (var/area/A in world)
				LAGCHECK(LAG_LOW)
				if (A.z != Z_LEVEL_STATION)
					continue
				//Ignoring do_not_irradiate here
				if (!A.irradiated)
					A.irradiated = TRUE
				A.icon_state = "bluenew" //gonna tryturf/ed cherenkov flavour
				for (var/turf/T in A.turfs)
					//Might be interesting for folks to scour the desert for artifacts after, the odds of spawning are lower cause it spawned kinda a lot in testing
					if (rand(0,1000) < 3 && (istype(T,/turf/floor) || istype(T, /turf/space/gehenna/desert)))
						Artifact_Spawn(T)

			siren.repeat = FALSE
			siren.channel = 5
			siren.volume = 75

			for (var/mob/N in mobs)
				N.flash(3 SECONDS)
/*
	#ifndef UNDERWATER_MAP
			for (var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
				LAGCHECK(LAG_LOW)
				S.color = src.space_color
	#endif
*/
			world << siren

			sleep(0.4 SECONDS)

			blowout = TRUE

			var/sound/blowoutsound = sound('sound/misc/blowout.ogg')
			blowoutsound.repeat = 0
			blowoutsound.channel = 5
			blowoutsound.volume  = 20
			world << blowoutsound
			boutput(world, "<span class='alert'><B>WARNING</B>: Mass radiation has struck [station_name(1)]. Do not leave safety until all radiation alerts have been cleared.</span>")

			for (var/mob/M in mobs)
				SPAWN_DBG(0)
					shake_camera(M, 400, 16)

			sleep(rand(1.5 MINUTES,2 MINUTES)) // drsingh lowered these by popular request.
			command_alert("Radiation levels lowering across the surface. ETA 60 seconds until all areas are safe.", "Anomaly Alert")

			sleep(rand(25 SECONDS,50 SECONDS)) // drsingh lowered these by popular request

			for (var/area/A in world)
				LAGCHECK(LAG_LOW)
				if (A.z != Z_LEVEL_STATION)
					continue
				if (!A.permarads)
					A.irradiated = FALSE

				else
					A.irradiated = initial(A.irradiated)
				A.icon_state = null

			blowout = FALSE
			broadcast_controls.broadcast_stop(broadcast)
			qdel(broadcast)
			command_alert("All radiation alerts onboard [station_name(1)] have been cleared. You may now leave the tunnels freely.", "All Clear")
/*
	#ifndef UNDERWATER_MAP
			for (var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
				LAGCHECK(LAG_LOW)
				S.color = null
	#endif
*/
			for (var/mob/N in mobs)
				N.flash(3 SECONDS)

			//Cut out another sleep and the restoring of airlock access
