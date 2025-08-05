//god the forklift needs to stop handling so shit

/*
	This is a slight edit of /datum/movement_controller/obj_control
	I still don't understand how components are used cause it's fairly abstracted and incredibly fussy
	but you shouldn't be able to sprint in a forklift anyway (obj_control allows it) so this can be its own thing

	TODO - make generic for all obj/vehicles (except maybe segway/clown car)
*/

/datum/movement_controller/forklift
	var/obj/master
	var/move_dir = 0
	var/move_delay = 2.5
	var/next_move = 0
	var/automove = FALSE

	New(master)
		..()
		src.master = master

	disposing()
		master = null
		..()

	keys_changed(mob/user, keys, changed)
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
			if(src.move_dir)
				attempt_move(user)

	process_move(mob/user, keys)
		if(!src.move_dir)
			return 0
		if(TIME < src.next_move)
			return 0
		var/delay = src.move_delay
		src.master.set_dir(src.move_dir)
		var/turf/T = src.master.loc
		if(istype(T))
			// this is what pod.dm does, don't look at me!!!
			src.master.glide_size = (32 / delay) * world.tick_lag
			user.glide_size = src.master.glide_size
			user.animate_movement = SYNC_STEPS
			if (automove)
				walk(src.master, src.move_dir, move_delay)
			else
				step(src.master, src.move_dir)
			src.master.glide_size = (32 / delay) * world.tick_lag
			user.glide_size = src.master.glide_size
			user.animate_movement = SYNC_STEPS
		src.next_move = TIME + delay
		return delay
