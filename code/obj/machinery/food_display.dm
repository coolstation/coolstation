/obj/machinery/food_display
	name = "menu display"
	icon = 'icons/obj/machines/menudisplay.dmi'
	icon_state = "menudisplay"
	var/datum/light/glow
	power_usage = 200

	var/screen = null
	var/prevscreen = null

/obj/machinery/food_display/New()
	..()
	if(!src.screen)
		src.screen = "blank"

	src.glow = new /datum/light/point
	src.glow.set_brightness(0.8)
	src.glow.set_color(0.75, 0.75, 0.75)
	src.glow.set_height(0.75)
	src.glow.attach_x = 1
	src.glow.attach(src)
	src.glow.enable()

	src.update_icon()

/obj/machinery/food_display/process()
	if(status & BROKEN)
		return
	..()
	if(status & NOPOWER)
		return
	use_power(power_usage)

/obj/machinery/food_display/proc/update_icon()
	if (status & BROKEN)
		ClearAllOverlays()
		return

	var/image/I = SafeGetOverlayImage("disp", 'icons/obj/machines/menudisplay.dmi', src.screen)
	UpdateOverlays(I, "disp")

/obj/machinery/food_display/attack_hand(var/mob/user)
	if(user.stat || status & (NOPOWER|BROKEN))
		return
	. = ..()

	if(src.prevscreen)
		src.icon_state = "menudisplay"
		src.screen = src.prevscreen
		src.prevscreen = null
		src.glow.enable()
	else
		src.prevscreen = src.screen
		if(prob(25))
			src.screen = "blank"
		else
			src.icon_state = "menudisplay-off"
			src.screen = "off"
			src.glow.disable()

	src.update_icon()


/obj/machinery/food_display/nanoburg
	screen = "nanoburg_menu"

/obj/machinery/food_display/warcys
	screen = "warcys_menu"

/obj/machinery/food_display/notaburger
	screen = "notaburg_menu"
