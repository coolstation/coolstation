/obj/effects/shuttle_fly_in
	name = "inbound shuttle"
	desc = "OH FUCK IT'S COMING RIGHT FOR US!!"
	icon = 'icons/obj/large/mining_shuttle_front.dmi'
	icon_state = "shuttle"
	anchored = 2
	invisibility = 101 //start invisible
	plane = PLANE_SPACE
	flags = TECHNICAL_ATOM

	New(loc, total_delay)
		..()
		var/turf/our_loc = src.loc
		var/turf/offset_for_sprite_size = locate(our_loc.x - 3, our_loc.y - 1, our_loc.z)
		if(offset_for_sprite_size)
			set_loc(offset_for_sprite_size)
		var/start_anim = total_delay - 5 SECONDS
		var/startangle = rand(-90, 90)
		var/endangle = -1 * sign(startangle) * rand(45,270)
		pixel_x = rand(40, 96) * (prob(50) ? 1 : -1)
		pixel_y = rand(40, 96) * (prob(50) ? 1 : -1)
		var/matrix/matrix_start = matrix(matrix(startangle, MATRIX_ROTATE), 0, MATRIX_SCALE)
		var/matrix/matrix_end = matrix(matrix(endangle, MATRIX_ROTATE), 1, MATRIX_SCALE)
		//var/start_px = rand(-96,96)
		//var/start_py = rand(-96,96)
		src.transform = matrix_start
		SPAWN_DBG(start_anim)
			invisibility = 0
			animate(src, transform = matrix_end, time = 5 SECONDS, easing = CUBIC_EASING | EASE_IN, flags=ANIMATION_PARALLEL)
			animate(pixel_x =  0, time = 5 SECONDS, easing = CUBIC_EASING, flags=ANIMATION_PARALLEL)
			animate(pixel_y =  0, time = 5 SECONDS, easing = CUBIC_EASING)
			//animate(transform = matrix(A.transform, 180, MATRIX_ROTATE), time = 5 SECONDS)
		SPAWN_DBG(total_delay)
			qdel(src)
