//Used by: BFG 9000
/datum/projectile/bfg
	name = "BFG shot"
	icon_state = "bfg"
	power = 400
	cost = 40
	sname = "plasma blast"
	shot_sound = null
	shot_number = 1
	brightness = 0.8
	color_red = 0
	color_green = 0.9
	color_blue = 0.2
	max_range = 100
	dissipation_rate = 0

	on_hit(atom/hit)
		if (!master) return
		var/obj/overlay/explosion = new(master.loc)
		explosion.pixel_x = -16
		explosion.pixel_y = -16
		explosion.icon = 'icons/effects/64x64.dmi'
		flick("bfg_explode", explosion)
		SPAWN_DBG(1.6 SECONDS)
			qdel(explosion)
		playsound(master, "sound/weapons/DSRXPLOD.ogg", 75)
		return
