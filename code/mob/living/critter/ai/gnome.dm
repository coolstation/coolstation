
/datum/aiHolder/gnome

/datum/aiHolder/gnome/New()
	..()

	default_task = get_instance(/datum/aiTask/sequence/gnome_flee_sequence, list(src, task_cache[/datum/aiTask/timed/wander/long]))

/datum/aiHolder/gnome/was_harmed(obj/item/W, mob/M)
	current_task = get_instance(/datum/aiTask/sequence/gnome_flee_sequence, list(src, task_cache[/datum/aiTask/timed/wander/long]))
	current_task.reset()

/datum/aiTask/sequence/gnome_flee_sequence
	name = "flee"

/datum/aiTask/sequence/gnome_flee_sequence/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/escape_sight, list(holder)))
	add_task(holder.get_instance(/datum/aiTask/succeedable/gnome_disguise, list(holder)))
	current_subtask = subtasks[subtask_index]

/datum/aiTask/succeedable/escape_sight
	name = "escaping sight"
	var/next_success = 0
	var/mob/living/fleeing_from

/datum/aiTask/succeedable/escape_sight/on_tick()
	for(var/mob/living/M in viewers(world.view, src.holder.owner.loc))
		if(M.client && M != src.holder.owner)
			if(!src.fleeing_from)
				src.fleeing_from = M
			else if(M != src.fleeing_from && GET_DIST(src.holder.owner, M) < GET_DIST(src.holder.owner, src.fleeing_from))
				src.fleeing_from = M
			src.next_success = world.time + 1 SECONDS
			break
	if(src.fleeing_from)
		src.holder.move_away(src.fleeing_from, 15)
	..()

/datum/aiTask/succeedable/escape_sight/succeeded()
	if(src.next_success < world.time)
		src.holder.stop_move()
		return 1
	return 0

/datum/aiTask/succeedable/escape_sight/failed()
	return 0

/datum/aiTask/succeedable/gnome_disguise
	name = "gnoming it up"
	max_fails = 8
	var/datum/targetable/gnome/disguise/disguise_ability
	var/successful = FALSE

/datum/aiTask/succeedable/gnome_disguise/New(parentHolder)
	..(parentHolder)
	if(src.holder.owner.abilityHolder)
		src.disguise_ability = src.holder.owner.abilityHolder.getAbility(/datum/targetable/gnome/disguise)

/datum/aiTask/succeedable/gnome_disguise/on_reset()
	if(istype(src.holder.owner?.loc, /obj/item/gnome_disguise))
		src.successful = TRUE
	. = ..()

/datum/aiTask/succeedable/gnome_disguise/on_tick()
	..()
	if(src.successful || !src.disguise_ability.cooldowncheck())
		return
	for(var/obj/item/I in view(2, src.holder.owner.loc))
		if(!I.anchored && I.w_class <= W_CLASS_BULKY && !src.disguise_ability.handleCast(I))
			src.successful = TRUE
			return
	for(var/obj/item/I in view(5, src.holder.owner.loc))
		if(!I.anchored && I.w_class <= W_CLASS_BULKY)
			src.holder.move_to(I, 1)
			return

/datum/aiTask/succeedable/gnome_disguise/succeeded()
	return src.successful

