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
	// thanks zewaka for reminding me the previous implementation of this is BYOND NATIVE
	// thanks byond forums for letting me know that the byond native implentation FUCKING SUCKS
	holder.owner.move_dir = pick(alldirs)
	holder.owner.process_move()

/datum/aiTask/timed/wander/on_tick()
	. = ..()
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
	if(src.found_path)
		if(src.found_path.len > 0)
			// follow the path
			if(!src.next_turf || GET_DIST(src.holder.owner, src.next_turf) < 1)
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
			holder.move_to(src.next_turf, 0)
			return
	get_path()
	holder.move_to(src.move_target, distance_from_target) // fuck it!

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
		return
	src.found_path = get_path_to(holder.owner, src.move_target, max_distance=src.max_path_dist, mintargetdist=distance_from_target, move_through_space=move_through_space, do_doorcheck = TRUE)
	if(!src.found_path || !jpsTurfPassable(src.found_path[1], get_turf(src.holder.owner), src.holder.owner, options = list("do_doorcheck" = TRUE, "move_through_space" = move_through_space))) // no path :C
		return

/datum/aiTask/endless/move/on_reset()
	..()
	src.found_path = null
	src.move_target = null
	src.next_turf = null
	src.holder.stop_move()

/datum/aiTask/endless/move/on_tick()
	if(src.found_path)
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
			holder.move_to(src.next_turf, 0)
			return
	get_path()
	holder.move_to(src.move_target, distance_from_target) // fuck it!

/datum/aiTask/endless/move/inherit_target

/datum/aiTask/endless/move/inherit_target/tick()
	src.move_target = holder.target
	return ..()

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// LA VIOLENCIA

/datum/aiHolder/violent
	move_shuffle_at_target = 3
	seek_cooldown = 1.5 SECONDS

/datum/aiHolder/violent/New()
	..()
	default_task = get_instance(/datum/aiTask/concurrent/violence, list(src))
	src.tick()

/datum/aiHolder/violent/was_harmed(obj/item/W, mob/M)
	if(src.owner.ai_is_valid_target(M))
		src.target = M

/datum/aiTask/concurrent/violence
	name = "violence"
	max_dist = 9

/datum/aiTask/concurrent/violence/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/endless/violence_subtask, list(holder)))
	add_task(holder.get_instance(/datum/aiTask/endless/move/inherit_target, list(holder)))

/datum/aiTask/concurrent/violence/get_targets()
	. = ..()
	for(var/mob/living/L in oview(src.holder.owner, src.max_dist))
		if(src.holder.owner.ai_is_valid_target(L))
			. |= L

/datum/aiTask/concurrent/violence/tick()
	if(!src.holder.target && !ON_COOLDOWN(src.holder.owner, "ai_seek_target_cooldown", src.holder.seek_cooldown))
		src.holder.target = src.get_best_target(get_targets())
	. = ..()

// this task causes violence forever
/datum/aiTask/endless/violence_subtask
	name = "violence subtask"
	var/boredom_ticks = 60
	var/ability_cooldown = 4 SECONDS
	var/mob/living/queued_target = null
	var/ticks_since_combat = 0

/datum/aiTask/endless/violence_subtask/on_tick()
	var/mob/living/critter/owncritter = src.holder.owner
	if (!src.holder.owner || HAS_ATOM_PROPERTY(src.holder.owner, PROP_CANTMOVE))
		return

	if(src.holder.target)
		var/mob/living/M = src.holder.target
		if(!istype(M) || isdead(M) || M.z != src.holder.owner.z || src.ticks_since_combat >= src.boredom_ticks || !src.holder.owner.ai_is_valid_target(M))
			src.queued_target = null
			src.holder.target = null
			if(!src.holder.target && !GET_COOLDOWN(src.holder.owner, "ai_seek_target_cooldown"))
				src.holder.target = src.get_best_target(get_targets())
			if(!src.holder.target)
				return ..()

		src.holder.owner.a_intent = prob(80) ? INTENT_HARM : pick(INTENT_DISARM, INTENT_GRAB)

		owncritter.hud.update_intent() // god i hate this

		if(src.holder.owner.next_click > world.time)
			return ..()

		if((!src.ability_cooldown || !ON_COOLDOWN(src.holder.owner, "ai_ability_cooldown", src.ability_cooldown)) && src.holder.owner.ability_attack(M))
			src.holder.owner.next_click = world.time + COMBAT_CLICK_DELAY
			return ..()

		if(GET_DIST(src.holder.owner, M) <= 1)
			src.holder.owner.hand_attack(M)
			src.ticks_since_combat = 0
			src.holder.owner.next_click = world.time + COMBAT_CLICK_DELAY
			src.queued_target = null
		else if(istype(owncritter))
			var/datum/handHolder/HH = owncritter.get_active_hand()
			if(HH.can_range_attack)
				src.holder.owner.hand_attack(M)
				src.ticks_since_combat = 0
				src.holder.owner.next_click = world.time + COMBAT_CLICK_DELAY
				src.queued_target = null
			else
				src.queued_target = M
				src.ticks_since_combat++
		else
			src.queued_target = M
			src.ticks_since_combat++
		src.holder.owner.set_dir(get_dir(src.holder.owner, M))

		if(prob(40)) // may do a more intelligent check later, but this is decent
			src.holder.owner.swap_hand()
	else
		src.holder.target = locate(src.holder.owner.x + rand(-4, 4), src.holder.owner.y + rand(-4, 4), src.holder.owner.z)

	..()

/datum/aiTask/endless/violence_subtask/on_move()
	if(src.queued_target && src.holder.owner.next_click <= world.time && GET_DIST(src.holder.owner, src.queued_target) <= 1 && prob(80))
		src.ticks_since_combat = 0
		SPAWN_DBG(rand(1,2))
			if(src.queued_target && GET_DIST(src.holder.owner, src.queued_target) <= 1)
				src.holder.owner.hand_attack(src.queued_target)
				src.holder.owner.next_click = world.time + COMBAT_CLICK_DELAY
