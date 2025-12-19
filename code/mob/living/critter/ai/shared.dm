// in here I dump ai tasks that seem like they could be useful to other people
// but are far too specific to warrant going into ai.dm - cirr

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// GOALBASED PRIORITIZER TASK
// a child prioritizer geared to a very specific set of needs
// responsible for: selecting a target (and reporting back the evaluation score based on its value)
// and moving through the following two tasks:
// moving to a selected target, performing a /datum/action on the selected target
/datum/aiTask/sequence/goalbased
	name = "goal parent"
	var/weight = 1 // for weighting the importance of the goal this sequence is in charge of
	max_dist = 5 // the maximum tile distance that we look for targets
	var/can_be_adjacent_to_target = 1 // do we need to be AT the target specifically, or is being in 1 tile of it fine?

/datum/aiTask/sequence/goalbased/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/move, list(holder)))
	// SECOND TASK IS SUBGOAL SPECIFIC

/datum/aiTask/sequence/goalbased/evaluate()
	. = score_goal() * weight

/datum/aiTask/sequence/goalbased/proc/precondition()
	// useful for goals that have a requirement, return 0 to instantly make this state score 0 and not be picked
	. = 1

/datum/aiTask/sequence/goalbased/proc/score_goal()
	// do any specific stuff here, eg. if the goal requires some conditions and they don't exist, reduce the score here
	// by default, return the score of the best target
	. = 0
	var/precond = precondition()
	if(precond)
		. = precond * score_target(get_best_target(get_targets()))

/datum/aiTask/sequence/goalbased/on_tick()
	..()
	if(!holder.target && !(holder.seek_cooldown && ON_COOLDOWN(src.holder.owner, "ai_seek_target_cooldown", holder.seek_cooldown)))
		holder.target = get_best_target(get_targets())
	if(subtask_index == 1) // MOVE TASK
		// make sure we both set our target and move to our target correctly
		var/datum/aiTask/succeedable/move/M = subtasks[subtask_index]
		if(M && !M.move_target)
			var/target_turf = get_turf(holder.target)
			var/list/tempPath = get_path_to(holder.owner, target_turf, 40, can_be_adjacent_to_target, do_doorcheck = TRUE)
			var/length_of_path = length(tempPath)
			if(length_of_path) // fix runtime Cannot read length(null)
				M.move_target = tempPath[length_of_path]
				if(M.move_target)
					return
			M.move_target = target_turf

/datum/aiTask/sequence/goalbased/on_reset()
	..()
	holder.target = null

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// WANDER TASK
// spend a few ticks wandering aimlessly
/datum/aiTask/timed/wander
	name = "wandering"
	minimum_task_ticks = 5
	maximum_task_ticks = 10

/datum/aiTask/timed/wander/evaluate()
	. = 1 // it'd require every other task returning very small values for this to get selected

/datum/aiTask/timed/wander/on_tick()
	. = ..()
	// thanks zewaka for reminding me the previous implementation of this is BYOND NATIVE
	// thanks byond forums for letting me know that the byond native implentation FUCKING SUCKS
	holder.owner.move_dir = pick(alldirs)
	holder.owner.process_move()
	holder.stop_move()

/datum/aiTask/timed/wander/f
	name = "explicit_wandering"
/datum/aiTask/timed/wander/f/on_tick()
	holder.owner.move_dir = pick(alldirs)
	holder.owner.process_move()
	if(prob(1))
		if(prob(25))
			if(prob(10))
				holder.owner.say("fuck")
			else
				holder.owner.say(pick("that sure is swell","oh boy","gee whiz","hot dog","hee hee"))

/datum/aiTask/timed/wander/s
	name = "wandering slow"
	minimum_task_ticks = 2
	maximum_task_ticks = 5

/datum/aiTask/timed/wander/s/on_tick()
	if(prob(20))
		holder.owner.move_dir = pick(alldirs)
		holder.owner.process_move()

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// TARGETED TASK
// a timed task that also relates to a target and the acquisition of said target
/datum/aiTask/timed/targeted
	name = "targeted"
	var/target_range = 8

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// MOVE TASK
// target: holder target assigned by a sequence task
/datum/aiTask/succeedable/move
	name = "moving"
	max_fails = 5
	distance_from_target = 1
	var/max_path_dist = 30
	var/move_adjacent = TRUE
	var/list/found_path = null
	var/atom/move_target = null
	var/turf/next_turf = null

// use the target from our holder
/datum/aiTask/succeedable/move/proc/get_path()
	if(!src.move_target)
		fails++
		return
	src.found_path = get_path_to(holder.owner, src.move_target, max_distance=src.max_path_dist, mintargetdist=distance_from_target, move_through_space=move_through_space, do_doorcheck = TRUE)
	if(!src.found_path || !jpsTurfPassable(src.found_path[1], get_turf(src.holder.owner), src.holder.owner, options = list("do_doorcheck" = TRUE, "move_through_space" = move_through_space))) // no path :C
		fails++

/datum/aiTask/succeedable/move/on_reset()
	..()
	src.found_path = null
	src.move_target = null
	src.next_turf = null
	src.holder.stop_move()

/datum/aiTask/succeedable/move/on_tick()
	if(!src.found_path)
		get_path()
	if(length(src.found_path))
		// follow the path
		if(!src.next_turf || GET_DIST(src.holder.owner, src.next_turf) < 1)
			if(length(src.found_path) >= 2)
				src.next_turf = src.found_path[1]
				var/i = 2
				var/dir_line = get_dir(src.found_path[1],src.found_path[2])
				while(get_dir(src.next_turf, src.found_path[i]) == dir_line)
					src.next_turf = src.found_path[i]
					i++
					if(i > length(src.found_path))
						break
				src.found_path.Cut(1, i)
			else
				src.next_turf = get_turf(src.found_path[1])
				src.found_path.Cut()
		holder.move_to(src.next_turf, 0)
		return

/datum/aiTask/succeedable/move/on_move()
	. = ..()
	if(length(src.found_path))
		// follow the path
		if(!src.next_turf || GET_DIST(src.holder.owner, src.next_turf) < 1)
			if(length(src.found_path) >= 2)
				src.next_turf = src.found_path[1]
				var/i = 2
				var/dir_line = get_dir(src.found_path[1],src.found_path[2])
				while(get_dir(src.next_turf, src.found_path[i]) == dir_line)
					src.next_turf = src.found_path[i]
					i++
					if(i > length(src.found_path))
						break
				src.found_path.Cut(1, i)
			else
				src.next_turf = get_turf(src.found_path[1])
				src.found_path.Cut()
		holder.move_to(src.next_turf, 0)
		return

/datum/aiTask/succeedable/move/succeeded()
	if(src.move_target)
		return ((GET_DIST(get_turf(holder.owner), get_turf(src.move_target)) <= distance_from_target))

/datum/aiTask/succeedable/move/inherit_target

/datum/aiTask/succeedable/move/inherit_target/tick()
	src.move_target = holder.target
	return ..()


///////////////////////////////////////////////////////////////////////////////////////////////////////////
// WAIT TASK
// uh, yeah. spend a couple ticks waiting, whatever
// logic for going back to previous task is handled by holder
/datum/aiTask/timed/wait
	name = "waiting"
	minimum_task_ticks = 10
	maximum_task_ticks = 10

/datum/aiTask/timed/hibernate
	name = "hibernate"
	minimum_task_ticks = 1
	maximum_task_ticks = 1
	var/min_time_between_hibernations = 20 SECONDS
	var/hibernation_priority = 100

	evaluate()
		. = ..()
		var/mob/living/critter/M = holder.owner
		if (!M)
			return -1
		var/area/A = get_area(M)
		if (A?.active)
			return -1
		if ((M.last_hibernation_wake_tick + min_time_between_hibernations) >= TIME)
			return -1
		return hibernation_priority

	on_tick()
		. = ..()
		var/mob/living/critter/M = holder.owner
		if (!M) return
		holder.enabled = FALSE
		M.is_hibernating = TRUE
		M.registered_area = get_area(M)
		if(M.registered_area)
			M.registered_area.registered_mob_critters |= M

/datum/aiTask/endless
	name = "endless"

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// ENDLESS MOVE TASK
/datum/aiTask/endless/move
	name = "endlessly moving"
	distance_from_target = 1
	var/max_path_dist = 30
	var/move_adjacent = TRUE
	var/list/found_path = null
	var/atom/move_target = null
	var/turf/next_turf = null

// use the target from our holder
/datum/aiTask/endless/move/proc/get_path()
	if(!src.move_target)
		src.found_path = null
		src.next_turf = null
		src.holder.move_target = null
		ai_move_scheduled -= src.holder
		src.holder.owner.move_dir = 0
		return
	src.found_path = get_path_to(holder.owner, src.move_target, max_distance=src.max_path_dist, mintargetdist=distance_from_target, move_through_space=move_through_space, do_doorcheck = TRUE)
	if(!src.found_path || !jpsTurfPassable(src.found_path[1], get_turf(src.holder.owner), src.holder.owner, options = list("do_doorcheck" = TRUE, "move_through_space" = move_through_space))) // no path :C
		return

/datum/aiTask/endless/move/on_reset()
	. = ..()
	src.found_path = null
	src.move_target = null
	src.next_turf = null
	src.holder.stop_move()

/datum/aiTask/endless/move/on_tick()
	if(src.found_path && src.move_target)
		if(src.found_path.len > 0)
			if(!src.next_turf || GET_DIST(src.holder.owner, src.next_turf) < 1)
				// follow the path
				if(src.found_path.len >= 2)
					src.next_turf = src.found_path[1]
					var/i = 2
					var/dir_line = get_dir(src.found_path[1],src.found_path[2])
					while(get_dir(src.next_turf, src.found_path[i]) == dir_line)
						src.next_turf = src.found_path[i]
						i++
						if(i > length(src.found_path))
							break
					src.found_path.Cut(1, i)
				else
					src.next_turf = get_turf(src.found_path[1])
					src.found_path.Cut()
			holder.move_to(src.next_turf, 0)
			return
	get_path()

/datum/aiTask/endless/move/inherit_target

/datum/aiTask/endless/move/inherit_target/on_tick()
	src.move_target = holder.target
	return ..()

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// ENDLESS PICKUP ITEMS TASK

/datum/aiTask/endless/pickup
	name = "endlessly picking up items"
	max_dist = 3
	score_by_distance_only = TRUE
	var/obj/item/target_item = null
	var/acquire_target_chance = 10
	var/max_wclass = W_CLASS_TINY

/datum/aiTask/endless/pickup/New(parentHolder)
	. = ..()
	SPAWN_DBG(3 SECONDS)
		if(src.holder.owner)
			var/datum/limb/active_limb = src.holder.owner.equipped_limb()
			if(active_limb)
				src.max_wclass = active_limb.max_wclass

/datum/aiTask/endless/pickup/on_tick()
	if(src.holder.owner.restrained() || src.holder.owner.sleeping || src.holder.owner.stat || src.holder.owner.lying)
		return ..()
	if(src.target_item && can_reach(src.holder.owner, src.target_item))
		var/obj/item/equipped = src.holder.owner.equipped()
		if (!equipped || src.holder.owner.drop_item(equipped))
			if (isturf(src.target_item.loc))
				pickup_particle(src.holder.owner,src.target_item)
			src.holder.owner.put_in_hand_or_drop(src.target_item)
			src.target_item = null
			src.holder.target = null
			return ..()
	if(!src.target_item && prob(src.acquire_target_chance) && !src.equipped_validity())
		src.target_item = src.get_best_target(src.get_targets())
		if(src.target_item)
			RegisterSignal(src.target_item, COMSIG_ITEM_PICKUP, PROC_REF(target_picked_up))
			src.holder.target = src.target_item
	return ..()

/datum/aiTask/endless/pickup/proc/target_picked_up(obj/item/stolen, mob/thief)
	UnregisterSignal(src.target_item, COMSIG_ITEM_PICKUP)
	src.target_item = null
	src.holder.target = null

/datum/aiTask/endless/pickup/get_targets()
	. = ..()
	for(var/obj/item/I in view(get_turf(src.holder.owner), src.max_dist))
		. |= I

/datum/aiTask/endless/pickup/proc/equipped_validity()
	var/obj/item/equipped = src.holder.owner.equipped()
	if(equipped)
		return TRUE
	return FALSE

/datum/aiTask/endless/pickup/score_target(obj/item/target)
	if(target.w_class > src.max_wclass || target.anchored)
		return 0
	return ..()

/datum/aiTask/endless/pickup/weapon
	name = "endlessly picking up weapons"
	max_dist = 4
	score_by_distance_only = FALSE

/datum/aiTask/endless/pickup/weapon/equipped_validity()
	var/obj/item/equipped = src.holder.owner.equipped()
	if(equipped && prob(min(equipped.force / equipped.combat_click_delay * 80, 96)))
		return TRUE
	return FALSE

/datum/aiTask/endless/pickup/weapon/score_target(obj/item/target)
	if(target.w_class > src.max_wclass || target.anchored)
		return 0
	return (target.force / target.combat_click_delay) - 0.49 // we dont want anything that does less than 5 dps

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// LA VIOLENCIA

/datum/aiHolder/violent
	move_shuffle_at_target = 3
	seek_cooldown = 1.5 SECONDS

/datum/aiHolder/violent/New()
	..()
	default_task = get_instance(/datum/aiTask/concurrent/violence, list(src))
	if(current_state == GAME_STATE_PLAYING)
		src.tick()

/datum/aiTask/concurrent/violence
	name = "violence"
	max_dist = 9
	score_by_distance_only = FALSE

/datum/aiTask/concurrent/violence/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/endless/violence_subtask, list(holder)))
	if(src.holder.owner && src.holder.owner.ai_flags & MOB_AI_PICKUP_WEAPONS)
		add_task(holder.get_instance(/datum/aiTask/endless/pickup/weapon, list(holder)))
	add_task(holder.get_instance(/datum/aiTask/endless/move/inherit_target, list(holder)))

/datum/aiTask/concurrent/violence/get_targets()
	. = ..()
	for(var/mob/living/L in view(src.holder.owner, src.max_dist))
		if(src.holder.owner.ai_is_valid_target(L))
			. |= L

/datum/aiTask/concurrent/violence/tick()
	var/mob/living/L = src.holder.target
	if(src.holder.target && !istype(L))
		// going for weapons and such, and doesnt change heavyweight status so we go for it faster in a fight
		return ..()
	if(!src.holder.target || L.z != src.holder.owner.z || !src.holder.owner.ai_is_valid_target(L))
		src.holder.target = null
		var/obj/item/grab/G = src.holder.owner.equipped()
		if(G && istype(G))
			src.holder.owner.drop_item(G)
		if(!GET_COOLDOWN(src.holder.owner, "ai_seek_target_cooldown"))
			src.holder.target = src.get_best_target(src.get_targets())
	// when fighting, move to the heavyweight ai ticks
	if(src.holder.owner.mob_flags & HEAVYWEIGHT_AI_MOB)
		if(!src.holder.target)
			src.holder.owner.mob_flags &= ~HEAVYWEIGHT_AI_MOB
	else if(src.holder.target)
		src.holder.owner.mob_flags |= HEAVYWEIGHT_AI_MOB
	. = ..()

/datum/aiTask/concurrent/violence/score_target(atom/target)
	. = ..()
	if(.)
		. *= src.holder.owner.ai_rate_target(target)

// this task causes violence forever
/datum/aiTask/endless/violence_subtask
	name = "violence subtask"
	var/boredom_ticks = 120
	var/ability_cooldown = 4 SECONDS
	var/mob/living/queued_target = null
	var/ticks_since_combat = 0
	var/static/list/special_params = list("left" = TRUE, "ai" = TRUE)

/datum/aiTask/endless/violence_subtask/on_tick()
	if (!src.holder.owner || HAS_ATOM_PROPERTY(src.holder.owner, PROP_CANTMOVE))
		return

	if(!isliving(src.holder.target))
		return ..()

	if(!src.holder.target || src.ticks_since_combat >= src.boredom_ticks)
		src.holder.target = null
		src.queued_target = null
		src.ticks_since_combat = 0
		return ..()

	if(src.holder.owner.next_click > world.time)
		return ..()

	if(src.holder.owner.ai_a_intent)
		src.holder.owner.a_intent = src.holder.owner.ai_a_intent
	else
		src.holder.owner.a_intent = pick(70; INTENT_HARM, 20; INTENT_GRAB, 10; INTENT_DISARM)

	var/mob/living/critter/owncritter = src.holder.owner
	owncritter.hud.update_intent() // this works even on humans, due to both huds having this proc. hate it though.

	if((!src.ability_cooldown || !ON_COOLDOWN(src.holder.owner, "ai_ability_cooldown", src.ability_cooldown)) && src.holder.owner.ability_attack(src.holder.target))
		src.holder.owner.next_click = world.time + src.holder.owner.combat_click_delay * GET_COMBAT_CLICK_DELAY_SCALE(src.holder.owner)
		return ..()

	var/dont_swap = prob(60)

	// fake misclicks
	var/atom/possible_miss = src.holder.target
	var/mob/M = src.holder.target
	if(prob(10) && istype(M))
		possible_miss = M.prev_loc
	else if(prob(15))
		var/turf/current_turf = get_turf(src.holder.target)
		possible_miss = locate(current_turf.x + rand(-1,1), current_turf.y + rand(-1,1), current_turf.z)

	if(can_reach(src.holder.owner, possible_miss))
		src.holder.owner.set_dir(get_dir(src.holder.owner, src.holder.target))
		// bit of a shitshow here, but this ensures the ai mobs dont alternate between choking and letting go of people and doubles as getting the equipped item
		var/obj/item/grab/equipped = src.holder.owner.equipped()
		if(istype(equipped))
			if(equipped.state > GRAB_NECK || prob(5))
				dont_swap = FALSE
			else
				src.holder.owner.a_intent = INTENT_GRAB // finish the choke!
				dont_swap = TRUE
				if(equipped.state == GRAB_NECK && !equipped.affecting.beingBaned && prob(90))
					if(src.holder.owner.can_throw && prob(60))
						src.holder.owner.overhead_throw(TRUE)
						SPAWN_DBG(rand(0.8 SECONDS, 1.3 SECONDS))
							var/turf/current_turf = get_turf(src.holder.owner)
							var/turf/throw_target = locate(current_turf.x + pick(rand(-10,-3), rand(3, 10)), current_turf.y + pick(rand(-10,-3), rand(3, 10)), current_turf.z)
							if(throw_target)
								src.holder.owner.throw_item(throw_target)
					else if(prob(80))
						src.holder.owner.emote("flip", TRUE)
				else
					equipped.attack_self(src.holder.owner)
		else if(equipped)
			if(equipped.special && (prob(15) || possible_miss != src.holder.target))
				equipped.special.pixelaction(possible_miss,src.special_params,src.holder.owner)
				if(!dont_swap)
					dont_swap = prob(90)
			else
				src.holder.owner.weapon_attack(possible_miss, equipped, TRUE)
				if(!dont_swap)
					dont_swap = prob(min(equipped.force / equipped.combat_click_delay * 80, 96)) // 80% chance to stay on weapon if it does 10 dps, 96% at 12+
		else if(prob(15) || possible_miss != src.holder.target)
			var/datum/limb/active_limb = src.holder.owner.equipped_limb()
			if(active_limb)
				if(src.holder.owner.a_intent == INTENT_HARM && active_limb.harm_special)
					active_limb.harm_special.pixelaction(possible_miss,src.special_params,src.holder.owner)
				else if(src.holder.owner.a_intent == INTENT_DISARM && active_limb.disarm_special)
					active_limb.disarm_special.pixelaction(possible_miss,src.special_params,src.holder.owner)
				else
					src.holder.owner.hand_attack(possible_miss)
			else
				src.holder.owner.hand_attack(possible_miss)
		else
			src.holder.owner.hand_attack(possible_miss)
		src.ticks_since_combat = 0
		src.holder.owner.next_click = world.time + (equipped ? equipped.combat_click_delay : src.holder.owner.combat_click_delay) * GET_COMBAT_CLICK_DELAY_SCALE(src.holder.owner)
		src.holder.owner.lastattacked = null
		src.queued_target = null
	else if(istype(owncritter))
		var/datum/handHolder/HH = owncritter.get_active_hand()
		if(HH.can_range_attack)
			src.holder.owner.hand_attack(possible_miss)
			src.ticks_since_combat = 0
			src.holder.owner.next_click = world.time + src.holder.owner.combat_click_delay * GET_COMBAT_CLICK_DELAY_SCALE(src.holder.owner)
			src.queued_target = null
		else
			src.queued_target = possible_miss
			src.ticks_since_combat++
	else
		src.queued_target = possible_miss
		src.ticks_since_combat++

	if(!dont_swap)
		src.holder.owner.swap_hand()

	..()

/datum/aiTask/endless/violence_subtask/on_move()
	. = ..()
	if(src.queued_target && src.holder.owner.next_click <= world.time && prob(80))
		SPAWN_DBG(rand(1,2))
			if(src.holder.owner.next_click > world.time)
				return
			var/atom/possible_miss = src.queued_target
			var/mob/M = src.queued_target
			if(prob(10) && istype(M))
				possible_miss = M.prev_loc
			else if(prob(10))
				possible_miss = src.queued_target.loc
			if(possible_miss && can_reach(src.holder.owner, possible_miss))
				var/obj/item/grab/equipped = src.holder.owner.equipped()
				if(equipped && istype(equipped))
					if(equipped.state > GRAB_NECK || prob(5))
						src.holder.owner.swap_hand()
						src.holder.owner.a_intent = INTENT_HARM // and dont try to choke them in the other hand, either!
					else
						src.holder.owner.a_intent = INTENT_GRAB // finish the choke!
						equipped.attack_self(src.holder.owner)
				else if (equipped)
					if(equipped.special && prob(15) || possible_miss != src.holder.target)
						equipped.special.pixelaction(possible_miss,src.special_params,src.holder.owner)
					else
						src.holder.owner.weapon_attack(possible_miss, equipped, TRUE)
				else if(prob(20))
					var/mob/living/critter/owncritter = src.holder.owner
					var/datum/limb/active_limb
					if(istype(owncritter))
						var/datum/handHolder/HH = owncritter.get_active_hand()
						active_limb = HH.limb
					else if(ishuman(src.holder.owner))
						var/mob/living/carbon/human/H = src.holder.owner
						active_limb = H.hand ? H.limbs.l_arm : H.limbs.r_arm
					if(active_limb)
						if(src.holder.owner.a_intent == INTENT_HARM && active_limb.harm_special)
							active_limb.harm_special.pixelaction(possible_miss,src.special_params,src.holder.owner)
						else if(src.holder.owner.a_intent == INTENT_DISARM && active_limb.disarm_special)
							active_limb.disarm_special.pixelaction(possible_miss,src.special_params,src.holder.owner)
						else
							src.holder.owner.hand_attack(possible_miss)
					else
						src.holder.owner.hand_attack(possible_miss)
				else
					src.holder.owner.hand_attack(possible_miss)
				src.ticks_since_combat = 0
				src.holder.owner.next_click = world.time + (equipped ? equipped.combat_click_delay : src.holder.owner.combat_click_delay) * GET_COMBAT_CLICK_DELAY_SCALE(src.holder.owner)
				src.holder.owner.lastattacked = null
				src.queued_target = null
