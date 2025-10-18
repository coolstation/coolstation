//it's like a light switch but for anywhere
/datum/buildmode/lights
	name = "Lights"
	desc = {"***********************************************************<br>
Left Mouse Button on mob/obj/turf  = toggle area lights<br>
Right Mouse Button on mob/obj/turf = set area lights to selected color<br>
Right Mouse Button + CTRL on light/turf = set specific light to selected color<br>
Right Mouse Button on buildmode    = Select color for right-click<br>
***********************************************************"}
	icon_state = "lights"
	var/colour = "FFFFFF"

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

	click_mode_right(var/ctrl, var/alt, var/shift)
		colour = input(usr, "Select your faceplate color", "Drone", colour) as null|color
		update_button_text("Color: <span style='color: [colour];'>[colour]</span>")

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		var/temp_r = hex2num(copytext(colour, 2, 4)) / 255.0
		var/temp_g = hex2num(copytext(colour, 4, 6)) / 255.0
		var/temp_b = hex2num(copytext(colour, 6, 8)) / 255.0
		if (ctrl)
			if (istype(object, /obj/machinery/light))
				var/obj/machinery/light/L = object
				L.light?.set_color(temp_r, temp_g, temp_b)
			else
				var/turf/T = get_turf(object)
				for (var/obj/machinery/light/L in T)
					L.light?.set_color(temp_r, temp_g, temp_b)
		else
			var/area/A = get_area(object)
			if (istype(A))

				for (var/obj/machinery/light/L as anything in A.light_manager.lights)
					L.light?.set_color(temp_r, temp_g, temp_b)
					LAGCHECK(LAG_LOW)
				logTheThing("admin", src, null, "set every light in [A] to a [colour].")
				logTheThing("diary", src, null, "set every light in [A] to a [colour].", "admin")
				//message_admins("[key_name(src)] set every light in [A] to a [colour].")
