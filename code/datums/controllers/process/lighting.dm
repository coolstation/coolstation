
/// Lights with pending recalculations
var/datum/circular_queue/light_update_queue = new /datum/circular_queue(500)

/*
	To explain these queues, picture the following:
	You're moving a vehicle from one side of a gehenna map to the other arriving over desert and leaving desert.

	Removing desert deletes a lot of lights, and spawning desert makes a lot of lights.
	Meanwhile, floor <-> wall changes requires RL_SetOpacity() calls which involves iterating over every light in a radius.
	So to avoid as many recalculations as possible, we want to do the opacity changes when there's the fewest lights around.

	Trick is, for the departing side of the equation that's *before* the newly spawned lights are enabled,
	while on the arriving side that's after all the freshly deleted lights are disabled.

	Now that's a hypothetical as of time of writing, but the same problem affects the Gehenna <-> Space mining shuttle.
*/

/// Atoms with pending recalculations, processed before light_update_queue
//var/datum/circular_queue/RL_atom_update_queue_early = new /datum/circular_queue(250) //RL_OPACITY_TODO
/// Atoms with pending recalculations, processed after light_update_queue
//var/datum/circular_queue/RL_atom_update_queue_late = new /datum/circular_queue(250) //RL_OPACITY_TODO


/// Controls the LIGHTS
datum/controller/process/lighting

	var/max_chunk_size = 6 //20 prev
	var/min_chunk_size = 2
	var/count = 0
	var/chunk_count = 0

	var/chunk_count_increase_rate = 0.12//0.06

	setup()
		name = "Lighting"
		schedule_interval = 0.1 SECONDS
		tick_allowance = 90

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/lighting/old_lighting = target
		src.tick_allowance = old_lighting.schedule_interval
		src.max_chunk_size = old_lighting.max_chunk_size
		src.min_chunk_size = old_lighting.min_chunk_size
		src.count = old_lighting.count
		src.chunk_count = old_lighting.chunk_count
		src.chunk_count_increase_rate = old_lighting.chunk_count_increase_rate

	enable()
		..()
		RL_Resume()

	disable()
		..()
		RL_Suspend()

	doWork()
		count = 0
		//var/atom/A = 0

		if (!(/*RL_atom_update_queue_early.cur_size + */light_update_queue.cur_size/* + RL_atom_update_queue_late.cur_size*/))
			chunk_count = min_chunk_size

		/*while(RL_atom_update_queue_early.cur_size) //RL_OPACITY_TODO

			A = RL_atom_update_queue_early.dequeue()
			if (A)
				A.RL_SetOpacity(0, queued_run = TRUE) //The first argument is wrong but should not get used with queued_run set
				count++

			if (APPROX_TICK_USE > LIGHTING_MAX_TICKUSAGE && count >= chunk_count)
				chunk_count = min(max_chunk_size, chunk_count + chunk_count_increase_rate*2)
				return*/

		var/datum/light/L = 0

		while(light_update_queue.cur_size)

			L = light_update_queue.dequeue()

			if (L && L.dirty_flags != 0)

				if (L.dirty_flags & D_ENABLE)
					if (L.enabled)
						L.disable(queued_run = 1)
						L.dirty_flags &= ~D_ENABLE

				if (L.dirty_flags & D_BRIGHT)
					L.set_brightness(L.brightness_des, queued_run = 1)
				if (L.dirty_flags & D_COLOR)
					L.set_color(L.r_des,L.g_des,L.b_des, queued_run = 1)
				if (L.dirty_flags & D_HEIGHT)
					L.set_height(L.height_des, queued_run = 1)
				if (L.dirty_flags & D_ATTEN_CON)
					L.set_atten_con(L.atten_con_des, queued_run = 1)

				if (L.dirty_flags & D_MOVE)
					L.move(L.x_des,L.y_des,L.z_des,L.dir_des, queued_run = 1)


				if (L.dirty_flags & D_ENABLE)
					if (!L.enabled)
						L.enable(queued_run = 1)
						L.dirty_flags &= ~D_ENABLE

				L.dirty_flags = 0

				count++

			if (APPROX_TICK_USE > LIGHTING_MAX_TICKUSAGE && count >= chunk_count)
				chunk_count = min(max_chunk_size, chunk_count + chunk_count_increase_rate*2)
				break//return//previously break before adding the second queue

		//reusing A

		/*while(RL_atom_update_queue_late.cur_size) //RL_OPACITY_TODO

			A = RL_atom_update_queue_late.dequeue()
			if (A)
				A.RL_SetOpacity(0, queued_run = TRUE) //The first argument is wrong but should not get used with queued_run set
				count++

			if (APPROX_TICK_USE > LIGHTING_MAX_TICKUSAGE && count >= chunk_count)
				chunk_count = min(max_chunk_size, chunk_count + chunk_count_increase_rate*2)
				break

		chunk_count = max(min_chunk_size, chunk_count - chunk_count_increase_rate)*/

	/*
	proc/lag_machine() //for testing the game in a laggy state
		var/x = ""
		while(1)
			x = "[rand(0,1111)]"
			LAGCHECK(99)

	proc/linfo()
		boutput(world,"[light_update_queue.cur_size]")
	*/

/datum/circular_queue

	var/list/list = 0

	var/read_index = 1
	var/write_index = 1
	var/cur_size = 0
	var/const/increase_size_amt = 100


	New(ListSize = 500)
		..()
		list = list()
		list.len = ListSize


	proc/dequeue()
		.= 0
		if (cur_size > 0)
			.= list[read_index]

			list[read_index] = 0
			read_index ++

			if (read_index > list.len)
				read_index = 1

			update_size()

	proc/update_size()
		if (write_index >= read_index)
			cur_size = write_index - read_index
		else
			cur_size = (write_index + list.len) - read_index

	proc/queue(var/Q)
		if (!list)
			src.New()

		if (cur_size + 1 >= list.len)
			grow()

		//boutput(world,"[write_index]")
		list[write_index] = Q
		write_index ++

		if (write_index > list.len)
			write_index = 1

		update_size()

	proc/grow()
		list.len += increase_size_amt
		update_size()

	proc/shrink()//maybe todo, maybe not necessary idk
