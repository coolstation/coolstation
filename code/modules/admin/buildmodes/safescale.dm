//Several of our admin team are addicted to doing bullshit with safescale, but it's a pain in the ass to do up to now
/datum/buildmode/safescale
	name = "Safescale"
	desc = {"***********************************************************<br>
Right Mouse Button on buildmode button = Set scalar<br>
Ctrl-RMB on buildmode button = Set X and Y scalars independently<br><br>

Left Mouse Button on mob/obj/turf  = Scale target<br>
Right Mouse Button on mob/obj/turf = Reset target scale<br>
***********************************************************"}
	icon_state = "safescale"
	var/scalar_x = 1
	var/scalar_y = 1

	selected()
		..()
		update_button_text("[scalar_x]*[scalar_y]")

	click_left(atom/object, var/ctrl, var/alt, var/shift) //set
		object.SafeScale(scalar_x, scalar_y)

	click_right(atom/object, var/ctrl, var/alt, var/shift) //reset
		object.SafeScale((1/object.transform.a), (1/object.transform.e))

	click_mode_right(var/ctrl, var/alt, var/shift)
		if(ctrl)
			scalar_x = input(usr, "set X scale", "X scale", 1) as num
			scalar_y = input(usr, "set Y scale", "Y scale", 1) as num
		else
			var/pick = input(usr, "set scale", "scale", 1) as num
			scalar_x = pick
			scalar_y = pick
		update_button_text("[scalar_x]*[scalar_y]")