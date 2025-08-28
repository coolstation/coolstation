//it's like a light switch but for anywhere
/datum/buildmode/lights
	name = "Toggle Lights"
	desc = {"***********************************************************<br>
Left Mouse Button on mob/obj/turf  = toggle area lights<br>
***********************************************************"}
	icon_state = "lights"

	click_left(atom/object, var/ctrl, var/alt, var/shift) //mostly a trimmed down version of lights switch code
		var/area/A = get_area(object)
		if (istype(A))
			A.lightswitch = !A.lightswitch
			var/on = A.lightswitch
			A.power_change()
			for(var/obj/machinery/light_switch/L in A.machines)
				L.on = on
				L.updateicon()
			playsound(object, "sound/misc/lightswitch.ogg", 50, 1) //keeping this in :3
			if(on)
				for_by_tcl(S, /obj/critter/turtle)
					if(get_area(S) == A && S.rigged)
						S.explode()

