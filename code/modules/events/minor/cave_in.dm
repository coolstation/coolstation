//Things that would make this nicer:
//admin input, preferably one of those reticules for selecting where to put a cave in
//Send out an alert for particularly heavy cave ins
//refine the sounds
//some light screenshake
//smoke, but I have to look into the particle thing because it looks like the spawner objects might never get GCd?

/datum/random_event/minor/cave_in
	name = "Cave-In"
	disabled = 1	// Currently only accessed by mining
	announce_to_admins = 0
	customization_available = 0 //Do later :)

	event_effect(var/source,var/turf/wall/asteroid/gehenna/center)
		..()

		if (!istype(center))
			return
		var/severity = 1 //we'll assume the center is open since it will be very soon
		//effect is worse the more open the area of the cave in
		for (var/turf/T in orange(center, 4))
			if (!T.density) severity++

		var/next_timer = rand(7 SECONDS, 14 SECONDS)
		while (severity > 0)
			SPAWN_DBG(next_timer)
				//rocks will tend to start falling further out and gradually overlap closer to the center. This is just cause it's easy to code but it might be a nice effect too?
				var/turf/T = locate(center.x + rand(-round(severity/3, 1),round(severity/3, 1)), center.y + rand(-round(severity/3, 1),round(severity/3, 1)), center.z)
				playsound(T, "sound/misc/ground_rumble_big.ogg", 50, 1)
				Turfspawn_Cave_In_Round(T, 3, severity)
			next_timer += (rand(0.5 SECONDS, 1.5 SECONDS))
			severity -= 3

		//message_admins(" [T.loc]")
