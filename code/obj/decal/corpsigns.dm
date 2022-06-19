/obj/decal/poster/wallsign/foodhole
	name = "fast-food company sign"
	icon = 'icons/obj/decals/corpsigns.dmi'
	icon_state = "nanoburg"

	var/datum/light/glow

	New()
		..()
		src.glow = new /datum/light/point
		src.glow.set_brightness(0.8)
		src.glow.set_color(1, 0.52, 0.15)
		src.glow.set_height(0.75)
		src.glow.attach(src, 1.0)
		src.glow.enable()


/obj/decal/poster/wallsign/foodhole/nanoburg
	name = "NanoBurg franchise sign"
	icon_state = "nanoburg"

/obj/decal/poster/wallsign/foodhole/notaburger
	name = "NotABurger franchise sign"
	icon_state = "notaburger"

	New()
		..()
		src.glow.set_brightness(1.2)
		src.glow.set_color(0.88, 0.12, 0.12)

/obj/decal/poster/wallsign/foodhole/warcys
	name = "Strange fast-food franchise sign"
	icon_state = "warcys"
	desc = "Something about this sign seems very out of place"

	New()
		..()
		src.glow.set_color(0.88, 0.12, 0.12)

/*******************************************************************************
			 Spirit Space-o-ween
*******************************************************************************/

/obj/decal/poster/wallsign/spirit
	name = "welcome sign"
	icon = 'maps/tamwip/spirit/mall.dmi'
	icon_state = "spirit"
	desc = "A large sign, welcoming you to NTS Spirit station, with the faded promise of a fantastic retail experience among the stars."
	var/datum/light/glow

	New()
		..()
		src.glow = new /datum/light/point
		src.glow.set_brightness(0.6)
		src.glow.set_height(0.75)
		src.glow.attach(src, 1.0)
		src.glow.enable()
		#ifdef HALLOWEEN
		src.icon_state = "spirit-halloween"
		src.desc = "A large spooky sign, welcoming you to Spirit Halloween station, promising a spooktacular shift at bargain prices!"
		src.glow.set_color(0.88, 0.52, 0.12)
		#else
		src.glow.set_color(0.12, 0.12, 0.24)
		#endif
