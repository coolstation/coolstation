/datum/random_event/major/sandstorm
	name = "Sandstorm"
	required_elapsed_round_time = 30 MINUTES
#ifndef DESERT_MAP
	disabled = TRUE
#endif

	event_effect()
		..()
		var/timetoreachsec = rand(1,9)
		var/timetoreach = rand(60,120)
		var/actualtime = timetoreach * 10 + timetoreachsec
		var/intensity = rand(6,20) //todo: hook up gehenna weather to this. Shouldn't be hard
		var/originDirection = rand(1,4) //1 North, 2 East, 3 South, 4 West Never Eat Shitty Wankers
		switch(originDirection)
			if(1)
				originDirection = NORTH
			if(2)
				originDirection = EAST
			if(3)
				originDirection = SOUTH
			if(4)
				originDirection = WEST

		var/sound/blow = sound('sound/ambience/loop/Wind_Low.ogg')
		blow.channel = 5
		blow.volume = 50
		blow.repeat = TRUE
		world << blow
		command_alert("A severe weather disturbance has been detected approaching the station. All personnel have [timetoreach].[timetoreachsec] seconds to make their way indoors. Crew are advised to cover airways and eyes when going outdoors. The storm is predicted to last anywhere from a couple minutes to hours.", "Weather Alert")

		var/datum/directed_broadcast/emergency/broadcast = new(station_name, "Sandstorm", "[timetoreach] Seconds", "Wind speeds of [intensity] Wargs expected. Seek shelter indoors immediately. Do not go outside with exposed eyes or airways.")
		broadcast_controls.broadcast_start(broadcast, TRUE, -1, 1)

		SPAWN_DBG(0)
			sleep(actualtime)
			for(var/area/A in world)
				LAGCHECK(LAG_LOW) //what does that do
				if(A.z != Z_LEVEL_STATION)
					continue
				if((istype(A, /area/gehenna) || istype(A, /area/shuttle)) && A.z == Z_LEVEL_STATION) //probably a bad fix
					A.sandstorm = TRUE
					A.blowOrigin = originDirection
					A.sandstormIntensity = intensity
					A.overlays += image(icon = 'icons/turf/areas.dmi', icon_state = "dustverlay", layer = EFFECTS_LAYER_BASE)


			sandstorm = TRUE
			blow.repeat = FALSE
			blow.volume = 25
			world << blow

			var/sound/stormsound = sound('sound/ambience/nature/Wind_Cold1.ogg')
			stormsound.repeat = TRUE
			stormsound.volume = 50
			stormsound.channel = 5
			world << stormsound
			boutput(world, "<span class='alert'><B>WARNING</B>: Severe storm system has hit [station_name(1)]. Do not go outside without covering airways and eyes.</span>")

			sleep(rand(10 MINUTES, 30 MINUTES))
			command_alert("The low pressure system is rapidly increasing in pressure. ETA 120 seconds until the storm has passed.", "Weather Alert")

			sleep(rand(50 SECONDS, 110 SECONDS))

			for (var/area/A in world)
				LAGCHECK(LAG_LOW)
				if (A.z != Z_LEVEL_STATION)
					continue
				A.sandstormIntensity = 0
				A.sandstorm = FALSE
				A.blowOrigin = 0
				A.overlays -= image(icon = 'icons/turf/areas.dmi', icon_state = "dustverlay", layer = EFFECTS_LAYER_BASE)
