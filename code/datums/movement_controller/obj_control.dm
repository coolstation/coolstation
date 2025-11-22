/*
	For when you want to have a mob control an object's movement.
	Used by the controlled_by_mob component.
*/

/datum/movement_controller/obj_control
	var/obj/master
	var/move_dir = 0
	var/move_delay = 0.4 SECONDS
	var/next_move = 0

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
		src.master.set_dir(src.move_dir)
		var/turf/T = src.master.loc
		if(istype(T))
			// this is what pod.dm does, don't look at me!!!
			src.master.glide_size = (32 / src.move_delay) * world.tick_lag
			user.glide_size = src.master.glide_size
			user.animate_movement = SYNC_STEPS
			step(src.master, src.move_dir)
			src.master.glide_size = (32 / src.move_delay) * world.tick_lag
			user.glide_size = src.master.glide_size
			user.animate_movement = SYNC_STEPS
		src.next_move = TIME + src.move_delay
		return src.move_delay

/datum/movement_controller/obj_control/admin
	move_delay = 0.1 SECONDS

	hotkey(mob/user, name)
		..()
		switch (name)
			if("exit")
				user.override_movement_controller = null
				user.set_loc(get_turf(src.master))
				user.reset_keymap()
				user.client.eye = user

	modify_keymap(client/C)
		..()
		C.apply_keybind("just exit")

/datum/movement_controller/obj_control/gnome
	process_move(mob/user, keys)
		if(!src.move_dir)
			return 0
		if(TIME < src.next_move)
			return 0
		src.master.set_dir(src.move_dir)
		var/glide = (32 / (src.move_delay + user.pulling?.p_class)) * world.tick_lag
		if(isturf(src.master.loc))
			// this is what pod.dm does, don't look at me!!!
			src.master.glide_size = glide
			user.glide_size = src.master.glide_size
			user.animate_movement = SYNC_STEPS
			var/turf/old_loc = src.master.loc

			step(src.master, src.move_dir)
			src.master.glide_size = glide
			user.glide_size = src.master.glide_size
			user.animate_movement = SYNC_STEPS

			if (src.master.loc != old_loc)
				var/list/pulling = list()
				if (user.pulling)
					if ((!IN_RANGE(old_loc, user.pulling, 1) && !IN_RANGE(user, user.pulling, 1)) || !isturf(user.pulling.loc) || user.pulling == user) // fucks sake
						user.pulling = null
					else
						pulling += user.pulling
				for (var/atom/movable/A in pulling)
					if (GET_DIST(src.master.loc, A) == 0) // if we're moving onto the same tile as what we're pulling, don't pull
						continue
					if (A == user || A == src.master)
						continue
					if (!isturf(A.loc) || A.anchored)
						continue // whoops
					A.animate_movement = SYNC_STEPS
					A.glide_size = glide
					step(A, get_dir(A, old_loc))
					A.glide_size = glide
					A.OnMove(user)

			src.next_move = TIME + src.move_delay + user.pulling?.p_class
			return src.move_delay + user.pulling?.p_class

		else if(ismob(src.master.loc))
			var/mob/M = src.master.loc
			var/multed_delay = rand(3,7) * M.movement_delay()
			step(M, src.move_dir)
			src.next_move = TIME + multed_delay
			return multed_delay


