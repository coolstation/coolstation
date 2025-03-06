/datum/thrown_thing
	var/atom/movable/thing
	var/atom/target
	var/error
	var/speed
	var/dx
	var/dy
	var/dist_x
	var/dist_y
	var/range
	var/target_x
	var/target_y
	var/matrix/transform_original
	var/list/params
	var/turf/thrown_from
	var/atom/return_target
	var/bonus_throwforce = 0
	///Must be a list now of (datum to call on, procref to call) otherwise shit won't work
	var/list/end_throw_callback
	var/mob/user
	var/hitAThing = FALSE
	var/dist_travelled = 0
	var/speed_error = 0
	var/pitfall_flying = FALSE

	New(atom/movable/thing, atom/target, error, speed, dx, dy, dist_x, dist_y, range,
			target_x, target_y, matrix/transform_original, list/params, turf/thrown_from, atom/return_target,
			bonus_throwforce=0, end_throw_callback=null)
		src.thing = thing
		src.target = target
		src.error = error
		src.speed = speed
		src.dx = dx
		src.dy = dy
		src.dist_x = dist_x
		src.dist_y = dist_y
		src.range = range
		src.target_x = target_x
		src.target_y = target_y
		src.transform_original = transform_original
		src.params = params
		src.thrown_from = thrown_from
		src.return_target = return_target
		src.bonus_throwforce = bonus_throwforce
		src.end_throw_callback = end_throw_callback
		src.user = usr // ew
		..()

	proc/get_throw_travelled()
		. = src.dist_travelled //dist traveled is super innacurrate, especially when stacking throws
		if (src.thrown_from) //if we have this param we should use it to get the REAL distance.
			. = get_dist(get_turf(thing), get_turf(src.thrown_from))

var/global/datum/controller/throwing/throwing_controller = new

/datum/controller/throwing
	var/list/datum/thrown_thing/thrown
	var/running = FALSE

/datum/controller/throwing/proc/start()
	if(src.running)
		return
	src.running = TRUE
	SPAWN_DBG(0)
		while(src.tick())
			sleep(0.1 SECONDS)
		src.running = FALSE

/datum/controller/throwing/proc/move_thrown(var/atom/movable/thing, var/datum/thrown_thing/thr)
	if(!thing || thing.disposed)
		return TRUE
	var/turf/T = thing.loc
	if( !(
			thr.target && thing.throwing && isturf(T) && \
				(
					(
						(thr.target_x != thing.x || thr.target_y != thing.y ) && \
						thr.dist_travelled < thr.range
					) || \
					T?.throw_unlimited || \
					thing.throw_unlimited || \
					thr.pitfall_flying
				)
			))
		return TRUE
	var/choose_x = thr.error > 0
	if(thr.dist_y > thr.dist_x) choose_x = !choose_x
	var/turf/next = get_step(thing, choose_x ? thr.dx : thr.dy)
	if(!next || next == T) // going off the edge of the map makes get_step return null, don't let things go off the edge
		return TRUE
	thing.glide_size = (32 / (1/thr.speed)) * world.tick_lag
	if (!thing.Move(next))  // Grayshift: Race condition fix. Bump proc calls are delayed past the end of the loop and won't trigger end condition
		thr.hitAThing = TRUE // of !throwing on their own, so manually checking if Move failed as end condition
		return TRUE
	thing.glide_size = (32 / (1/thr.speed)) * world.tick_lag
	var/hit_thing = thing.hit_check(thr)
	thr.error += thr.error > 0 ? -min(thr.dist_x, thr.dist_y) : max(thr.dist_x, thr.dist_y)
	thr.dist_travelled++
	if(!thing.throwing || hit_thing)
		return TRUE

/datum/controller/throwing/proc/tick()
	if(!length(thrown))
		return FALSE
	for(var/_thr in thrown)
		var/datum/thrown_thing/thr = _thr
		var/atom/movable/thing = thr.thing

		var/end_throwing = FALSE
		var/int_speed = floor(thr.speed + thr.speed_error)
		if(thr.pitfall_flying)
			thr.speed = max(thr.speed - 1, 0.5)
		thr.speed_error += thr.speed - int_speed
		var/rem_speed
		for(var/i in 1 to int_speed)
			if(src.move_thrown(thing, thr))
				end_throwing = TRUE
				rem_speed = int_speed - i
				break

		if(end_throwing)
			thrown -= thr
			var/turf/T = get_turf(thing)
			if(thing && SEND_SIGNAL(T, COMSIG_TURF_LANDIN_THROWN, thing))
				if(!thr.pitfall_flying)
					thr.pitfall_flying = TRUE
					if(rem_speed)
						for(var/i in 1 to rem_speed)
							src.move_thrown(thing, thr)
				thrown += thr
				continue
			if(thr.end_throw_callback)
				if(call(thr.end_throw_callback[1], thr.end_throw_callback[2])(thr)) // return 1 to continue the throw, might be useful!
					thrown += thr
					continue
				else
					//garbage collect cause I'm not seeing where the fuck the thrown thing datums are deleted (I'm pretty sure this whole thing is quite gross)
					thr.end_throw_callback = null
			if(!thing || thing.disposed)
				continue
			if(!(thr.pitfall_flying))
				animate(thing)

			thing.throw_end(thr.params, thrown_from=thr.thrown_from)
			SEND_SIGNAL(thing, COMSIG_MOVABLE_THROW_END, thr)

			if(thr.hitAThing)
				thr.params = null// if we hit something don't use the pixel x/y from the click params

			thing.throwing = 0
			thing.throw_unlimited = 0

			thing.throw_impact(T, thr)
			thing.throwforce -= thr.bonus_throwforce

			if(thr.target != thr.return_target && thing.throw_return)
				thing.throw_at(thr.return_target, thing.throw_range, thing.throw_speed)
	return TRUE
