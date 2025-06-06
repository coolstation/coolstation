/obj/effects/harmless_smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0
	//Remove this bit to use the old smoke
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32
	event_handler_flags = CAN_UPDRAFT
/*
	pooled()
		..()
*/
/*
/obj/effects/harmless_smoke/New()
	..()
	SPAWN_DBG(10 SECONDS)
		qdel(src)
	return
*/
/obj/effects/harmless_smoke/proc/kill(var/time)
	SPAWN_DBG(time)
		qdel(src)


proc/harmless_smoke_puff(var/turf/location, var/duration = 100)
	if(!istype(location)) return
	var/obj/effects/harmless_smoke/smoke = new()
	smoke.set_loc(location)
	smoke.kill(100)
