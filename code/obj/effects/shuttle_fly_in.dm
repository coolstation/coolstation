/obj/effects/fly_in
	//most of these vars are from when this was just the shuttle effect.
	name = "inbound shuttle"
	desc = "OH FUCK IT'S COMING RIGHT FOR US!!"
	icon = 'icons/obj/large/mining_shuttle_front.dmi'
	icon_state = "shuttle"
	anchored = ANCHORED_TECHNICAL
	invisibility = 101 //start invisible
	plane = PLANE_SPACE
	flags = TECHNICAL_ATOM
	var/jitter_upper = 96
	var/jitter_lower = 40
	var/jitter_startangle = 90
	var/jitter_endangle_upper = 270
	var/jitter_endangle_lower = 45
	var/icon_offset_x = 3
	var/icon_offset_y = 1

	New(loc, total_delay = 5 SECONDS)
		..()
		var/turf/our_loc = src.loc
		var/turf/offset_for_sprite_size = locate(our_loc.x - icon_offset_x, our_loc.y - icon_offset_y, our_loc.z)
		if(offset_for_sprite_size)
			set_loc(offset_for_sprite_size)
		var/start_anim = total_delay - 5 SECONDS
		var/startangle = rand(-jitter_startangle, jitter_startangle)
		var/endangle = -1 * sign(startangle) * rand(jitter_endangle_lower,jitter_endangle_upper)
		pixel_x = rand(jitter_lower, jitter_upper) * (prob(50) ? 1 : -1)
		pixel_y = rand(jitter_lower, jitter_upper) * (prob(50) ? 1 : -1)
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

/obj/effects/fly_in/shuttle

	New(loc, total_delay)
		if (!istype_exact(src.loc, /turf/space))
			icon_state = "shadow"
		..()


/obj/effects/fly_in/meteor
	name = "inbound meteor"
	icon = 'icons/obj/large/meteor96x96.dmi'
	icon_state = "meteor_shadow"
	jitter_startangle = 180
	icon_offset_x = 1

	New(loc, total_delay)
		jitter_upper = rand(80, 160)
		jitter_lower = rand(30, 60)
		//much more rotation
		jitter_endangle_upper = 720
		jitter_endangle_lower = 360
		..()

/obj/effects/fly_in/meteor/meaty
	icon_state = "meaty_shadow"
