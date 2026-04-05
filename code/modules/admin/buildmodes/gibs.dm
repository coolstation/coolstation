//I can't remember if there's an easy way to proc gibs at will, so here is this

/datum/buildmode/gibs
	name = "Gibs"
	desc = {"***********************************************************<br>
Left Mouse Button on mob/obj/turf  = Spawn gibs<br>
***********************************************************"}
	icon_state = "buildappearance"
	var/bodyparts = TRUE

	New()
		..()
		update_button_text("include random bodypart: [bodyparts ? "YES" : "NO"]")

	click_mode_right(var/ctrl, var/alt, var/shift)
		bodyparts = !bodyparts
		update_button_text("include random bodypart: [bodyparts ? "YES" : "NO"]")

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		gibs(get_turf(object),null,null,null,null,bodyparts,null)
