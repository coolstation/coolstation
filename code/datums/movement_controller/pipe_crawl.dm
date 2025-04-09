//For use with /obj/disposalholder/crawler - allows players to navigate disposal pipes
/datum/movement_controller/pipe_crawler
	var/obj/disposalholder/crawler/owner
	var/in_control = TRUE
	var/delay = 0.45 SECONDS
	var/next_move = 0
	var/move_dir = 0


	keys_changed(mob/user, keys, changed)
		if (!in_control)
			return
		if (changed & (KEY_FORWARD|KEY_BACKWARD|KEY_RIGHT|KEY_LEFT))
			src.move_dir = 0
			if (keys & KEY_FORWARD)
				move_dir |= NORTH
			if (keys & KEY_BACKWARD)
				move_dir |= SOUTH
			if (keys & KEY_RIGHT)
				move_dir |= EAST
			if (keys & KEY_LEFT)
				move_dir |= WEST
			if (!(move_dir in cardinal))
				move_dir = 0
			if(src.move_dir)
				attempt_move(user)

	process_move(mob/user, keys)
		if (!in_control)
			return 0
		if(!src.move_dir)
			return 0
		if(TIME < src.next_move)
			return src.next_move - TIME
		var/obj/disposalpipe/oldpipe = src.owner.loc
		if (!(oldpipe.dpdir & src.move_dir)) //see if we can even exit our current pipe this direction
			if (istype(oldpipe, /obj/disposalpipe/trunk)) //might be trying to get out of a trunk
				goto exit_trunk
			return 0
		src.owner.set_dir(src.move_dir)
		var/turf/nextturf = src.owner.nextloc()
		var/obj/disposalpipe/nextpipe = src.owner.findpipe(nextturf)
		if(istype(nextpipe))
			// cargo culted from obj_control, who took it from the pod controller
			//src.owner.glide_size = (32 / delay) * world.tick_lag //Doesn't work though, but having smooth glides would be nice
			//user.glide_size = src.owner.glide_size
			//user.animate_movement = SYNC_STEPS

			var/obj/disposalholder/H2 = locate() in nextpipe
			if(H2 && !H2.active)
				src.owner.merge(H2)
			src.owner.set_loc(nextpipe)

			//As it turns out disposal pipes do their funky shit when a disposalholder exits, and we're picking our own exit all the time
			//So we have to have a workaround to make sure you get mulched if you crawl into a loafer
			if (istype(nextpipe, /obj/disposalpipe/loafer))
				boutput(src.owner.pilot, "Something tells you this wasn't your finest idea...")
				src.in_control = FALSE
				nextpipe.transfer(src.owner) //double move technically
			else
				src.owner.vision?.process()
		else
			oldpipe.expel(src.owner, nextturf,src.move_dir)

		exit_trunk:
		if (istype(nextpipe, /obj/disposalpipe/trunk))
			var/obj/machinery/disposal/exit = locate() in nextturf
			if (exit)
				exit.expel(src.owner)
			else
				nextpipe.expel(src.owner, nextturf,src.move_dir)
				//src.owner.set_loc(get_turf(nextpipe))

		src.next_move = TIME + delay
		return delay
