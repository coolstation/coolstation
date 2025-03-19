#define STATE_DEAD 0
#define STATE_DEPLOYING 1
#define STATE_EXPANDING 2
#define STATE_DO_LIPIDS 3
#define STATE_FORTIFYING 4
#define STATE_UNDER_ATTACK 5

/mob/living/intangible/blob_overmind/ai
	var/static/next_id = 1
	var/ai_id
	var/state = 0
	var/calm_state = 0
	var/force_state = 0
	var/mob/living/attacker
	var/list/attackers = list()

	var/counter = 4
	var/refresh_lists = 0
	var/datum/targetable/blob/deploy = null
	var/datum/targetable/blob/attack = null
	var/datum/targetable/blob/spread = null
	var/datum/targetable/blob/build/ribosome = null
	var/datum/targetable/blob/build/mito = null
	var/datum/targetable/blob/build/wall = null
	var/datum/targetable/blob/absorb = null
	var/datum/targetable/blob/promote = null
	var/datum/targetable/blob/evolution/spread_up = null
	var/datum/targetable/blob/evolution/gen_up = null
	var/datum/targetable/blob/evolution/fireres_up = null

	var/turf/last_spread = null
	var/turf/last_lost = null
	var/list/extreme = list()
	var/list/open = list()
	var/list/open_medium = list()
	var/list/open_low = list()
	var/ribosome_count = 0
	var/turf/destroying = null
	var/turf/fortifying = null
	var/turf/protecting = null
	var/destroy_level = 0
	var/list/consider_destroy = list(/obj/reagent_dispensers = 1, /obj/table = 1, /obj/machinery/computer3 = 1, /obj/machinery/computer = 1, /obj/storage/secure/closet = 1, /obj/storage/closet = 1, /obj/machinery/door/airlock = 2, /obj/window = 2, /obj/grille = 2)

	var/list/closed = list()

	var/ai_ticks_queued_up = 0

	New()
		ai_id = src.next_id
		src.next_id++
		state = STATE_DEPLOYING
		..()
		name = "Blob AI #[ai_id]"
		real_name = name
		deploy = src.abilityHolder.getAbility(/datum/targetable/blob/plant_nucleus)

	proc/priority(var/obj/O)
		if (!O.density)
			return 0
		for (var/t in consider_destroy)
			if (istype(O, t))
				return consider_destroy[t]
		return 3

	proc/is_bottleneck(var/turf/T)
		var/turf/N = locate(T.x, T.y + 1, T.z)
		var/turf/S = locate(T.x, T.y - 1, T.z)
		var/turf/E = locate(T.x + 1, T.y, T.z)
		var/turf/W = locate(T.x - 1, T.y, T.z)
		var/NV = evaluate_no_add(N)
		var/SV = evaluate_no_add(S)
		var/EV = evaluate_no_add(E)
		var/WV = evaluate_no_add(W)
		if (N)
			if (locate(/obj/machinery/door) in N)
				return 100
		if (S)
			if (locate(/obj/machinery/door) in S)
				return 100
		if (E)
			if (locate(/obj/machinery/door) in E)
				return 100
		if (W)
			if (locate(/obj/machinery/door) in W)
				return 100
		if (NV > 1 && SV > 1)
			return 100
		if (EV > 1 && WV > 1)
			return 100
		if (NV > 0 && SV > 0)
			return 50
		if (EV > 0 && WV > 0)
			return 50
		if (NV > 0)
			var/turf/SS = locate(T.x, T.y - 2, T.z)
			if (evaluate_no_add(SS) > 0)
				return 25
		if (SV > 0)
			var/turf/NN = locate(T.x, T.y + 2, T.z)
			if (evaluate_no_add(NN) > 0)
				return 25
		if (EV > 0)
			var/turf/WW = locate(T.x - 2, T.y, T.z)
			if (evaluate_no_add(WW) > 0)
				return 25
		if (WV > 0)
			var/turf/EE = locate(T.x + 2, T.y, T.z)
			if (evaluate_no_add(EE) > 0)
				return 25
		return 0


	proc/update_lists(var/turf/ST)
		if (ST in open)
			open -= ST
		var/turf/N = locate(ST.x, ST.y + 1, ST.z)
		var/turf/S = locate(ST.x, ST.y - 1, ST.z)
		var/turf/E = locate(ST.x + 1, ST.y, ST.z)
		var/turf/W = locate(ST.x - 1, ST.y, ST.z)
		if (N)
			evaluate(N)
		if (S)
			evaluate(S)
		if (E)
			evaluate(E)
		if (W)
			evaluate(W)

	proc/get_nearby_convertable_blob(var/turf/T)
		for (var/obj/blob/B in orange(1, T))
			if (B.type == /obj/blob)
				return B
		return null

	proc/evaluate_no_add(var/turf/C)
		if (!C)
			return -2
		if (locate(/obj/blob/wall) in C)
			return 3
		if (locate(/obj/blob) in C)
			return -1
		if (!has_adjacent_blob(C))
			return -1
		var/cl
		if (C.density || istype(C, /turf/space))
			cl = 3
		else
			cl = 0
			for (var/obj/O in C)
				var/prior = priority(O)
				if (prior > cl)
					cl = prior
				if (cl == 3)
					break
		return cl

	proc/evaluate(var/turf/C)
		var/cl = evaluate_no_add(C)
		switch (cl)
			if (0)
				open[C] = 1
			if (1)
				open_medium[C] = 1
			if (2)
				open_low[C] = 1
			if (3)
				closed[C] = 1

	proc/has_adjacent_blob(var/turf/T)
		var/turf/N = locate(T.x, T.y + 1, T.z)
		var/turf/S = locate(T.x, T.y - 1, T.z)
		var/turf/E = locate(T.x + 1, T.y, T.z)
		var/turf/W = locate(T.x - 1, T.y, T.z)
		if (N)
			if (locate(/obj/blob) in N)
				return 1
		if (S)
			if (locate(/obj/blob) in S)
				return 1
		if (E)
			if (locate(/obj/blob) in E)
				return 1
		if (W)
			if (locate(/obj/blob) in W)
				return 1
		return 0

	proc/pick_deployment_location()
		var/turf/T = get_turf(src)
		if (T.density || istype(T, /turf/space) || prob(50))
			var/nx = T.x + floor(rand(-2, 2) + ((150 - T.x) / 37.5))
			var/ny = T.y + floor(rand(-2, 2) + ((150 - T.y) / 37.5))
			var/turf/Q = locate(nx, ny, T.z)
			if (Q)
				return Q
		return T

	proc/check_viability(var/turf/start)
		var/list/closed = list()
		var/list/open = list()
		open[start] = 1
		var/viability = 0
		while (open.len)
			var/turf/T = open[1]
			viability++
			if (viability >= 100)
				return 1
			open.Cut(1,2)
			closed[T] = 1
			var/turf/N = locate(T.x, T.y + 1, T.z)
			var/turf/S = locate(T.x, T.y - 1, T.z)
			var/turf/W = locate(T.x - 1, T.y, T.z)
			var/turf/E = locate(T.x + 1, T.y, T.z)
			if (N)
				if (!istype(N, /turf/space) && !N.density && !(N in closed) && !(N in open))
					open[N] = 1
			if (S)
				if (!istype(S, /turf/space) && !S.density && !(S in closed) && !(S in open))
					open[S] = 1
			if (W)
				if (!istype(W, /turf/space) && !W.density && !(W in closed) && !(W in open))
					open[W] = 1
			if (E)
				if (!istype(E, /turf/space) && !E.density && !(E in closed) && !(E in open))
					open[E] = 1
		return 0

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		if (client)
			return
		if (!length(blob_holder.blobs) && state != 1)
			return
		ai_ticks_queued_up++
		src.ai_process()
		SPAWN_DBG(0)
			var/max_extra_ticks = 4
			var/extra_ticks_left = max_extra_ticks
			while(blob_holder.points >= blob_holder.points_max * 2/3 && ai_ticks_queued_up <= 4 && extra_ticks_left-- && APPROX_TICK_USE < 80)
				sleep(4 SECONDS / (max_extra_ticks + 1))
				src.ai_process()
			ai_ticks_queued_up--

	proc/ai_process()
		if (refresh_lists > 50 && state > 1 || length(open) + length(open_low) + length(open_medium) + length(closed) <= 1)
			logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Refreshing lists.")
			refresh_lists = 0
			var/list/all = open + open_low + open_medium + closed
			open.len = 0
			closed.len = 0
			open_low.len = 0
			open_medium.len = 0
			for (var/turf/C as anything in all)
				evaluate(C)
			for (var/turf/T as anything in block(locate(src.x - 30, src.y - 30, src.z), locate(src.x + 30, src.y + 30, src.z)))
				if (!(T in all))
					evaluate(T)

		if (state > 1)
			if(src.blob_holder.extra_nuclei)
				src.place_extra_nucleus()

			if (fireres_up)
				if (fireres_up.check_requirements())
					fireres_up.cast()
					fireres_up = null
					logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Took fire resistance upgrade.")

			if (absorb)
				for (var/mob/living/carbon/human/H in (mobs + ai_mobs))
					if (!isturf(H.loc))
						continue
					if (isdead(H))
						continue
					if (H.decomp_stage >= 4)
						continue
					if (!(locate(/obj/blob) in H.loc))
						var/turf/T = get_turf(H)
						if (has_adjacent_blob(T) && prob(50))
							attack_now(T)
							if (T.can_blob_spread_here())
								spread_to(T, 0)
							logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Can't absorb [H] (no blob on tile), attacking instead at [log_loc(H)].")
						continue
					else
						var/turf/H_turf = H.loc
						SPAWN_DBG(-1)
							for(var/dir in cardinal)
								var/turf/T = get_step(H, dir)
								if(H.loc != H_turf)
									break
								if(T.can_blob_spread_here())
									spread_to(T, 0)
									sleep(spread.cooldown + 1)
					// no explicit `absorb.cast` call because absorption is now automatic

		switch (state)
			if (STATE_DEAD)
				return
			if (STATE_DEPLOYING)
				counter--
				if (counter <= 0)
					var/turf/T = pick_deployment_location()
					if (!T)
						T = get_turf(pick_landmark(LANDMARK_OBSERVER)) // contingency
					set_loc(T)
					if (!deploy)
						logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Invalid state for [src]: Cannot find deploy ability in state DEPLOYING.")
						state = 0
						return

					blob_holder.color = random_color()
					blob_holder.my_material.color = color
					blob_holder.initial_material.color = color
					blob_holder.organ_color = random_color()
					color = blob_holder.color

					if (istype(T, /turf/space))
						return // Do not deploy on space.
					if (!check_viability(T))
						return
					deploy.cast(T)
					if (src.abilityHolder.getAbility(/datum/targetable/blob/plant_nucleus))
						logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Deploy failed.")
						return
					state = STATE_EXPANDING
					last_spread = T
					update_lists(T)
					spread = blob_holder.getAbility(/datum/targetable/blob/spread)
					attack = blob_holder.getAbility(/datum/targetable/blob/attack)
					ribosome = blob_holder.getAbility(/datum/targetable/blob/build/ribosome)
					mito = blob_holder.getAbility(/datum/targetable/blob/build/mitochondria)
					wall = blob_holder.getAbility(/datum/targetable/blob/build/wall)
					absorb = blob_holder.getAbility(/datum/targetable/blob/absorb)
					promote = blob_holder.getAbility(/datum/targetable/blob/promote_nucleus)
					spread_up = blob_holder.getAbility(/datum/targetable/blob/evolution/quick_spread)
					gen_up = blob_holder.getAbility(/datum/targetable/blob/evolution/extra_genrate)
					fireres_up = blob_holder.getAbility(/datum/targetable/blob/evolution/fire_resist)
					logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Deployed blob to ([T.x], [T.y], [T.z]).")
					counter = 0
			if (STATE_EXPANDING)
				refresh_lists++
				if (blob_holder.blobs.len > 15 && prob(blob_holder.blobs.len / (ribosome_count + 1)) && blob_holder.points_max >= ribosome.pointCost)
					state = STATE_DO_LIPIDS
				if (!(blob_holder.getAbility(/datum/targetable/blob/evolution/extra_genrate)))
					gen_up = null
				if (!blob_holder.getAbility(/datum/targetable/blob/evolution/spread))
					spread_up = null
				if (gen_up)
					if (gen_up.check_requirements())
						gen_up.cast()
						logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Took generation rate upgrade while expanding.")
				if (spread_up)
					if (spread_up.check_requirements())
						spread_up.cast()
						logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Took spread upgrade while expanding.")
				if(length(open) + length(open_low) + length(open_medium) == 0 && length(closed) > 0)
					destroying = pick(closed)
				var/turf/ST = null
				if (destroying && !has_adjacent_blob(destroying))
					destroying = null
				if (open.len && !destroying)
					if (blob_holder.points < spread.pointCost)
						return
					for (var/turf/Q in range(5, last_spread))
						if (Q in open)
							if (Q.can_blob_spread_here())
								ST = Q
								break
							else
								open -= Q
								evaluate(Q)
						else if (!(Q in open_medium) && !(Q in open_low) && !(Q in closed))
							evaluate(Q)
							if (Q in open)
								ST = Q
					if (!ST)
						do
							if (!open.len)
								break
							var/turf/Q = pick(open)
							if (Q.can_blob_spread_here())
								ST = Q
								break
							else
								open -= Q
								evaluate(Q)
						while (!ST)
				if (ST && !destroying)
					if (!spread)
						logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Invalid state for [src]: Cannot find spread ability in state EXPANDING.")
					spread_to(ST, 1)
					return
				if ((open_medium.len && !destroying) || (destroying && destroy_level == 1))
					if (blob_holder.points < attack.pointCost)
						return
					ST = null
					if (destroying)
						ST = destroying
					else
						do
							if (ST)
								evaluate(ST)
								ST = null
							if (!open_medium.len)
								break
							ST = pick(open_medium)
							open_medium -= ST
						while (evaluate_no_add(ST) != 1)
					if (ST)
						destroying = ST
						destroy_level = 1
						set_loc(ST)
						attack.cast(ST)
						logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Attacking tile at [showCoords(ST.x, ST.y, ST.z)].")
						var/new_score = evaluate_no_add(ST)
						if (new_score != 1)
							switch (new_score)
								if (0)
									open[ST] = 1
								if (2)
									open_low[ST] = 1
								if (3)
									closed[ST] = 1
							destroying = null
						return
					else if (destroying)
						destroying = null
				if (open_low.len || destroying)
					if (blob_holder.points < attack.pointCost)
						return
					ST = null
					if (destroying)
						ST = destroying
					else
						do
							if (ST)
								evaluate(ST)
								ST = null
							if (!open_low.len)
								break
							ST = pick(open_low)
							open_low -= ST
						while (evaluate_no_add(ST) != 2)
					if (ST)
						destroying = ST
						destroy_level = 2
						set_loc(ST)
						attack.cast(ST)
						logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Attacking tile at [showCoords(ST.x, ST.y, ST.z)].")
						var/new_score = evaluate_no_add(ST)
						if (new_score != 2)
							switch (new_score)
								if (0)
									open[ST] = 1
								if (1)
									open_medium[ST] = 1
								if (3)
									closed[ST] = 1
							destroying = null
						return
					else if (destroying)
						destroying = null
				if (force_state)
					state = force_state
					force_state = 0
			if (STATE_DO_LIPIDS)
				if (blob_holder.points < ribosome.pointCost)
					if(blob_holder.points_max < ribosome.pointCost)
						state = STATE_EXPANDING
					return
				var/obj/blob/A
				if (!A)
					for (var/i in 1 to 20)
						var/obj/blob/C = pick(blob_holder.blobs)
						if (C.type == /obj/blob)
							A = C
							break
				if (!A)
					state = STATE_EXPANDING
					logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Failed to find suitable ribosome candidate in 20 attempts.")
					return
				var/turf/T = get_turf(A)
				set_loc(T)
				ribosome.cast(T)
				var/obj/blob/ribosome/L = locate() in T
				if (L)
					ribosome_count++
				logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Creating ribosome at [showCoords(T.x, T.y, T.z)].")
				state = STATE_EXPANDING
			if (STATE_FORTIFYING)
				if (!fortifying)
					state = STATE_EXPANDING
					return
				var/obj/blob/TF = locate() in fortifying
				if (!TF)
					state = STATE_EXPANDING
					return
				if (TF.type == /obj/blob)
					create_wall_if_possible(fortifying)
					return
				else if (TF.type == /obj/blob/wall)
					var/obj/blob/C = get_nearby_convertable_blob(fortifying)
					if (!C)
						state = STATE_EXPANDING
						return
					if (blob_holder.points < mito.pointCost)
						if (prob(20))
							state = STATE_EXPANDING
						return
					var/turf/T = get_turf(C)
					if (blob_holder.get_gen_rate() < 4)
						state = STATE_EXPANDING
					else if (create_mitochondria_if_possible(T) || prob(40))
						state = STATE_EXPANDING
				else
					state = STATE_EXPANDING
					return
			if (STATE_UNDER_ATTACK)
				var/attacks = rand(1,4)
				var/attack_used = 0
				var/mob/nearest = null
				var/n_dist = 5000
				if (attacker)
					if (!isturf(attacker.loc) || !has_adjacent_blob(attacker.loc) || attacker.stat || isintangible(attacker))
						attacker = null
				if (!attacker)
					if (attackers.len)
						for (var/mob/living/M in attackers)
							if (isintangible(M))
								attackers -= M
								continue
							if (isdead(M))
								attackers -= M
								continue
							if (isturf(M.loc))
								if (has_adjacent_blob(M.loc))
									attacker = M
									break
								else
									attackers -= M
									var/dist = GET_DIST(M, src)
									if (n_dist > dist)
										n_dist = dist
										nearest = M
					if (nearest)
						attackers += nearest
					if (!attacker)
						for (var/mob/living/M in (mobs + ai_mobs))
							if (isintangible(M))
								continue
							if (isdead(M))
								continue
							if (isturf(M.loc))
								if (has_adjacent_blob(M.loc))
									attacker = M
									break
				if (!attacker)
					counter++
					if (counter >= 5)
						attacker = null
						attackers.len = 0
						if (calm_state > 1)
							state = calm_state
						else
							state = STATE_EXPANDING
						counter = 0
						return
				if (attacker)
					var/turf/AT = get_turf(attacker)
					var/spreaded = 0
					if (!(locate(/obj/blob) in AT) && AT.can_blob_spread_here())
						spreaded = 1
						spread_to(AT, 0)
					for (var/obj/reagent_dispensers/fueltank/FU in view(attacker))
						if (has_adjacent_blob(FU.loc))
							attack_used++
							attack_now(FU.loc, attack_used)
							logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Attacking fuel tank at [showCoords(FU.x, FU.y, FU.z)] in response to attack force.")
					if (has_adjacent_blob(AT))
						attack_now(AT, attack_used)
						logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Hitting [attacker] at [showCoords(attacker.loc.x, attacker.loc.y, attacker.loc.z)] [attacks - attack_used] times.")
					var/obj/blob/B = get_nearby_convertable_blob(attacker.loc)
					if (B)
						create_wall_if_possible(get_turf(B))
					if (!spreaded)
						for (var/turf/T in range(2, attacker))
							if (T.can_blob_spread_here())
								spread_to(T, 0)
								logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Spreading near [attacker] to [showCoords(T.x, T.y, T.z)] in response to attack force.")
								break
				else if (!attacker)
					var/obj/blob/F = null
					//var/preferred = 0
					for_by_tcl(B, /obj/blob)
						if(!IN_RANGE(B, nearest, 10))
							continue
						if (B.type == /obj/blob)
							var/obj/blob/adj_blob = locate(/obj/blob) in get_step_towards(B, nearest)
							if (!adj_blob)
								continue
							if (adj_blob.type == /obj/blob)
								continue
							F = B
							/*if (adj_blob.type == /obj/blob/wall)
								preferred = 1
							else
								preferred = 0*/
							break
					if (F)
						var/turf/T = get_turf(F)
						create_mitochondria_if_possible(T)
					for (var/turf/T in range(5, nearest))
						if (T.can_blob_spread_here())
							spread_to(T, 0)
							logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Spreading near nearest [nearest] to [showCoords(T.x, T.y, T.z)] in response to attack force.")
							break

	proc/place_extra_nucleus()
		if(!src.blob_holder.extra_nuclei)
			return
		var/list/obj/blob/visited = list()
		var/list/obj/blob/current = list()
		var/obj/blob/final_target = null
		for_by_tcl(blob, /obj/blob)
			for(var/dir in cardinal)
				var/turf/T = get_step(blob.loc, dir)
				if(!istype(T))
					continue
				if(!T.density && !(locate(/obj/blob) in T) || blob.type == /obj/blob/nucleus && blob.blob_holder == src.blob_holder)
					current[blob] = 1
					break
		while(length(current))
			var/list/next = list()
			for(var/obj/blob/blob as anything in current)
				visited[blob] = 1
				if(blob.type == /obj/blob)
					final_target = blob
				for(var/dir in cardinal)
					var/obj/blob/next_blob = locate(/obj/blob) in get_step(blob.loc, dir)
					if(next_blob && !(next_blob in visited) && !(next_blob in next) && !(next_blob in current))
						next[next_blob] = 1
			current = next
		promote.cast(final_target?.loc)

	proc/attack_now(var/turf/T)
		set_loc(T)
		attack.cast(T)

	proc/spread_to(var/turf/ST, var/is_calm)
		set_loc(ST)
		spread.cast(ST)
		if (locate(/obj/blob) in ST)
			open -= ST
			if (is_calm)
				last_spread = ST
			logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Spreading to [showCoords(ST.x, ST.y, ST.z)].")
		else
			return
		update_lists(ST)
		if (!is_calm)
			return
		if (locate(/obj/machinery/power/apc) in ST)
			destroying = ST
			destroy_level = 1
		if (prob(is_bottleneck(ST)))
			if (destroying)
				force_state = STATE_FORTIFYING
			else
				state = STATE_FORTIFYING
			fortifying = ST

	proc/create_mitochondria_if_possible(var/turf/T)
		if (blob_holder.points >= mito.pointCost && mito.cooldowncheck())
			set_loc(T)
			mito.cast(T)
			logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Creating mitochondria at [showCoords(T.x, T.y, T.z)].")
			return 1
		return 0

	proc/create_wall_if_possible(var/turf/T)
		if (blob_holder.points >= wall.pointCost && wall.cooldowncheck())
			set_loc(T)
			wall.cast(T)
			logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Creating wall at [showCoords(T.x, T.y, T.z)].")
			return 1
		return 0

	was_harmed(var/obj/blob/B, var/mob/M, special, intent)
		..()
		if (!prob(max(1, min(100, (2000 - 100 * GET_DIST(M, src)) / 13))))
			return
		if (!(M in attackers))
			attackers += M
		if (!attacker || istype(B, /obj/blob/nucleus))
			attacker = M
		if (state != STATE_UNDER_ATTACK)
			calm_state = state
			state = STATE_UNDER_ATTACK
		counter = 0

	onBlobDeath(var/obj/blob/B, var/mob/M)
		if (!prob(max(1, min(100, (2000 - 100 * GET_DIST(B, src)) / 13))))
			return
		attacker = M
		if (istype(B, /obj/blob/ribosome))
			if (ribosome_count > 0)
				ribosome_count--
		if (state != STATE_UNDER_ATTACK)
			calm_state = state
			state = STATE_UNDER_ATTACK
		counter = 0



/mob/living/intangible/blob_overmind/ai/start_here
	var/deployment_attempt = 0
	pick_deployment_location()
		deployment_attempt++
		if(deployment_attempt == 1)
			return src.loc
		else
			return get_step(src.loc, pick(alldirs))

#undef STATE_UNDER_ATTACK
#undef STATE_FORTIFYING
#undef STATE_DO_LIPIDS
#undef STATE_EXPANDING
#undef STATE_DEPLOYING
#undef STATE_DEAD
