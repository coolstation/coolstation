/obj/train
	name = "train!!!"
	desc = "That thing what runs you over."
	icon = 'icons/obj/large/trains_256x128.dmi'
	icon_state = "engine_precolor_test"
	bound_width = 256
	bound_height = 96
	density = TRUE
	anchored = ANCHORED
	throw_spin = FALSE

	New()
		..()
		var/image/fullbright = image('icons/obj/large/trains_256x128.dmi',"fullbright")
		fullbright.plane = PLANE_SELFILLUM
		src.UpdateOverlays(fullbright, "fullbright")

