var/datum/explosion_controller/explosions
//When uncommented, turfs don't get destroyed by explosions but show their calculated explosion severity on them.
//#define EXPLOSION_MAPTEXT_DEBUGGING
/datum/explosion_controller
	var/list/queued_explosions = list()
	var/list/turf/queued_turfs = list()
	var/list/turf/queued_turf_safe = list()
	var/list/queued_turfs_blame = list()
	var/list/queued_turfs_center = list()
	var/distant_sound = 'sound/effects/explosionfar.ogg'
	var/exploding = 0

	proc/explode_at(atom/source, turf/epicenter, power, brisance = 1, angle = 0, width = 360, turf_safe = FALSE, no_effects = FALSE)
		var/atom/A = epicenter
		if(istype(A))
			var/fprint = null
			if(istype(source))
				fprint = source.fingerprintslast
			while(!istype(A, /turf))
				if(!istype(A, /mob) && A != source)
					A.ex_act(power, fprint)
				A = A.loc
		if (!istype(epicenter, /turf))
			epicenter = get_turf(epicenter)
		if (!epicenter)
			return
		if (epicenter.loc:sanctuary)
			return//no boom boom in sanctuary
		queued_explosions += new/datum/explosion(source, epicenter, power, brisance, angle, width, usr, turf_safe, no_effects)
		#ifdef Z3_IS_A_STATION_LEVEL
		if (epicenter.z == Z_LEVEL_DEBRIS && power > 30 && !istype(epicenter.loc, /area/station)) //large explosions cause cave-ins
			random_events.force_event("Cave-In", "Underground Explosion In Caverns", epicenter)
		#endif

	proc/queue_damage(var/list/new_turfs)
		var/c = 0
		for (var/turf/T as anything in new_turfs)
			queued_turfs[T] += new_turfs[T]
			queued_turf_safe[T] += new_turfs[T]
			if(c++ % 100 == 0)
				LAGCHECK(LAG_HIGH)

	proc/queue_damage_turf_safe(var/list/new_turfs)
		var/c = 0
		for (var/turf/T as anything in new_turfs)
			queued_turf_safe[T] += new_turfs[T]
			if(c++ % 100 == 0)
				LAGCHECK(LAG_HIGH)

	proc/kaboom()
		defer_powernet_rebuild = 1
		defer_camnet_rebuild = 1
		exploding = 1
		RL_Suspend()

		var/needrebuild = 0
		var/p
		var/last_touched
		var/center

		for (var/turf/T as anything in queued_turf_safe)
			queued_turf_safe[T]=sqrt(queued_turf_safe[T])*2
			p = queued_turf_safe[T]
			last_touched = queued_turfs_blame[T]
			center = queued_turfs_center[T]
			for (var/mob/M in T)
				M.ex_act(p, last_touched, center)

		LAGCHECK(LAG_HIGH)

		for (var/turf/T as anything in queued_turf_safe)
			p = queued_turf_safe[T]
			last_touched = queued_turfs_blame[T]
			center = queued_turfs_center[T]
			for (var/obj/O in T)
				if(istype(O, /obj/overlay))
					continue
				O.ex_act(p, last_touched, center, !queued_turfs[T])
				if (istype(O, /obj/cable)) // this is hacky, newcables should relieve the need for this
					needrebuild = 1

		LAGCHECK(LAG_HIGH)

		// BEFORE that ordeal (which may sleep quite a few times), fuck the turfs up all at once to prevent lag
		for (var/turf/T as anything in queued_turfs)
			queued_turfs[T]=sqrt(queued_turfs[T])*2
#ifndef UNDERWATER_MAP
			if(istype(T, /turf/space))
				continue
#endif
			p = queued_turfs[T]
			last_touched = queued_turfs_blame[T]
			center = queued_turfs_center[T]
			//boutput(world, "P2 [p]")
#ifdef EXPLOSION_MAPTEXT_DEBUGGING
			if (p >= OLD_EX_TOTAL)
				T.maptext = "<span style='color: #ff0000;' class='pixel c sh'>[round(p, 0.01)]</span>"
			else if (p >= OLD_EX_HEAVY)
				T.maptext = "<span style='color: #ffff00;' class='pixel c sh'>[round(p, 0.01)]</span>"
			else
				T.maptext = "<span style='color: #00ff00;' class='pixel c sh'>[round(p, 0.01)]</span>"

#else
			T.ex_act(p, last_touched, center)
#endif
		LAGCHECK(LAG_HIGH)

		queued_turfs.len = 0
		queued_turf_safe.len = 0
		queued_turfs_blame.len = 0
		queued_turfs_center.len = 0
		defer_powernet_rebuild = 0
		defer_camnet_rebuild = 0
		exploding = 0
		RL_Resume()
		if (needrebuild)
			makepowernets()

		rebuild_camera_network()
		world.updateCameraVisibility()

	proc/process()
		if (exploding)
			return
		else if (queued_turfs.len || queued_turf_safe.len)
			SPAWN_DBG(0)
				kaboom()
		else if (queued_explosions.len)
			SPAWN_DBG(0)
				var/datum/explosion/E
				while (queued_explosions.len)
					E = queued_explosions[1]
					queued_explosions -= E
					E.explode()

/datum/explosion
	var/atom/source
	var/turf/epicenter
	var/power
	var/brisance
	var/angle
	var/width
	var/user
	var/turf_safe
	var/no_effects

	New(atom/source, turf/epicenter, power, brisance, angle, width, user, turf_safe, no_effects)
		..()
		src.source = source
		src.epicenter = epicenter
		src.power = power
		src.brisance = brisance
		src.angle = angle
		src.width = width
		src.user = user
		src.turf_safe = turf_safe
		src.no_effects = no_effects

	proc/logMe(var/power)
		//I do not give a flying FUCK about what goes on in the colosseum. =I
		if(!istype(get_area(epicenter), /area/colosseum))
			//stop runtiming ffs
			if(istype(source, /datum/sea_hotspot))
				var/logmsg = "Explosion[src.turf_safe ? " (turf safe)" : ""] with power [power] (Source: Ocean Hotspot)  at [log_loc(epicenter)]."
				if(power > 10)
					message_admins(logmsg)
				logTheThing("bombing", user, null, logmsg)
				logTheThing("diary", user, null, logmsg, "combat")
				return

			var/logmsg = "Explosion[src.turf_safe ? " (turf safe)" : ""] with power [power] (Source: [source ? "[source.name]" : "*unknown*"])  at [log_loc(epicenter)]. Source last touched by: [key_name(source?.fingerprintslast)] (usr: [ismob(user) ? key_name(user) : user])"
			if(power > 10)
				message_admins(logmsg)
			if (source?.fingerprintslast)
				logTheThing("bombing", source.fingerprintslast, null, logmsg)
				logTheThing("diary", source.fingerprintslast, null, logmsg, "combat")
			else
				logTheThing("bombing", user, null, logmsg)
				logTheThing("diary", user, null, logmsg, "combat")

	///Calculate explosion power and queues damage
	proc/explode()
		logMe(power)

		if(!src.no_effects)
			if(power > 15)
				for(var/client/C in clients)
					if(C.mob && (C.mob.z == epicenter.z))
						shake_camera(C.mob, 8, 24) // remove if this is too laggy

						playsound(C.mob, explosions.distant_sound, 100, 0)

			playsound(epicenter.loc, "explosion", 100, 1, round(power, 1) )
			if(power > 10)
				var/datum/effects/system/explosion/E = new/datum/effects/system/explosion()
				E.set_up(epicenter)
				E.start()

		var/radius = round(sqrt(power), 1) * brisance

		var/last_touched
		if (istype(source, /atom)) // Cannot read null.fingerprintslast
			last_touched = source.fingerprintslast
		else
			last_touched = "*null*"

		var/list/nodes = list()
		var/list/blame = list()
		var/list/center = list()
		var/list/open = list(epicenter)
		nodes[epicenter] = radius
		while (open.len)
			if(length(nodes) % 100 == 0)
				LAGCHECK(LAG_HIGH)
			var/turf/T = open[1]
			open.Cut(1, 2)
			var/value = nodes[T] - 1 - T.explosion_resistance
			var/value2 = nodes[T] - 1.4 - T.explosion_resistance
			for (var/atom/A in T.contents)
				if (A.density/* && !A.CanPass(null, target)*/) // nothing actually used the CanPass check
					value -= A.explosion_resistance
					value2 -= A.explosion_resistance
			if (value < 0)
				continue
			for (var/dir in alldirs)
				var/turf/target = get_step(T, dir)
				if (!target) continue // woo edge of map
				if( target.loc:sanctuary ) continue
				var/new_value = dir & (dir-1) ? value2 : value
				if(width < 360)
					var/diff = abs(angledifference(get_angle(epicenter, target), angle))
					if(diff > width)
						continue
					else if(diff > width/2)
						new_value = new_value / 3 - 1
				if ((nodes[target] && nodes[target] >= new_value))
					continue
				nodes[target] = new_value
				open |= target

		radius += 1 // avoid a division by zero
		for (var/turf/T as anything in nodes) // inverse square law (IMPORTANT) and pre-stun
			var/p = power / ((radius-nodes[T])**2)
			nodes[T] = p
			blame[T] = last_touched
			center[T] = epicenter
			p = min(p, 10)
			if(prob(1))
				LAGCHECK(LAG_HIGH)
			for(var/mob/living/carbon/C in T)
				if (!isdead(C) && C.client)
					shake_camera(C, 3 * p, p * 4)
				C.changeStatus("stunned", p SECONDS)
				C.stuttering += p
				C.lying = 1
				C.set_clothing_icon_dirty()

		if(!src.turf_safe)
			explosions.queue_damage(nodes)
		else
			explosions.queue_damage_turf_safe(nodes)
		explosions.queued_turfs_blame += blame
		explosions.queued_turfs_center += center

		//GC cleanup thanx zewaka
		src.epicenter = null
		src.source = null
