
/mob/living/critter/desert/eleuaua
	name = "eleuaua"
	desc = "A beastie!"
	icon = 'icons/misc/critter.dmi'
	icon_state = "eleuaua"
	icon_state_alive = "eleuaua"
	icon_state_dead = "eleuaua-dead"
	abilityHolder = null
	add_abilities = null

	hand_count = 1	//One mouth

	base_move_delay = 1.6 //guess
	base_walk_delay = 2.2
	stepsound = null
	///time when mob last awoke from hibernation
	last_hibernation_wake_tick = 0
	is_hibernating = TRUE

	can_burn = 1
	can_throw = 0
	can_choke = 0
	in_throw_mode = 0

	can_help = TRUE
	can_grab = 0
	can_disarm = 0

	reagent_capacity = 137

	//death_text = null // can use %src%
	//pet_text = "pets" // can be a list

	custom_brain_type = null

	last_life_process = 0
	use_stunned_icon = 1

	pull_w_class = W_CLASS_SMALL

	blood_id = "blood"
	is_npc = TRUE

	New()
		..()
		APPLY_MOB_PROPERTY(src, PROP_CANTSPRINT, src) //Rather, they're always sprinting but same idea
		src.ai = new /datum/aiHolder/eleuaua(src)

	setup_healths()
		add_hh_flesh(33, 1.3)
		add_hh_flesh_burn(0, 0.75)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/mouth/eleuaua
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "mouth"


/datum/limb/mouth/eleuaua
	sound_attack = "sound/impact_sounds/Flesh_Tear_1.ogg"
	dam_low = 6 //high damage floor cause desert creatures gotta make it count
	dam_high = 9

	help(mob/target, mob/user)
		user.visible_message("<span class='notice'>[user] nuzzes [target].</span>") //critical feature
		user.lastattacked = target

//Find a nice open space, then rally self and any mobs of our own type in view to random turfs in the area. Probably prone to losing herd members but that's simplicity for you.
/datum/aiTask/mass_rally
	name = "start mass rally" //alternatively: mass migration
	///n*n square around a target turf that we scan & rally to
	var/area_size = 5
	///percentage of turfs in potential target area that can be blocked or the attempt fails (low atm in the hopes it discourages moving into gehenna's interiors)
	var/blocked_turf_limit_pct = 25
	//how far out we pick a center tile
	var/distance_upper_bound = 50
	var/distance_lower_bound = 25

	on_tick()
		var/chosen_direction = list(rand(-1,1),rand(-1,1))//pick(alldirs)
		var/dist = rand(distance_lower_bound, distance_upper_bound)
		var/turf/chosen_center = locate(holder.owner.x + chosen_direction[1]*dist, holder.owner.y + chosen_direction[2]*dist, holder.owner.z) //Get turf some distance away
		if (!chosen_center) //would be off map, probably
			return

		var/dense_count = 0
		var/total_count = 0
		//The weird floor/ceil stuff should be accounting for the center turf's own width (area_size of 5 should give -2 to +2. area_size of 6 should give -2 to +3)
		var/list/turf/target_area = block(locate(chosen_center.x - ceil(area_size/2 - 1), chosen_center.y - ceil(area_size/2 - 1), chosen_center.z),		locate(chosen_center.x + round(src.area_size/2), chosen_center.y + round(src.area_size/2), chosen_center.z))
		for (var/turf/place as anything in target_area)
			total_count += 1
			if(place.density) //Possibly use CanPass in the future, but we can't really give that proc a valid target in this context
				dense_count += 1
				target_area -= place //no selecting for pathing

		//Too close to map edge (that block statement up top breaks)
		if (!total_count)
			return
		//Target region not open enough
		if ((dense_count/total_count) * 100 > blocked_turf_limit_pct)
			return

		for (var/mob/living/M in view(9,holder.owner))
			if (!istype(M, holder.owner) || !M.is_npc)
				continue

			var/datum/aiHolder/their_ai = M.ai
			if (!their_ai)
				continue

			their_ai.current_task = their_ai.get_instance(/datum/aiTask/sequence/goalbased/rally, list(their_ai, their_ai.default_task))
			their_ai.current_task.reset()
			their_ai.target = pick(target_area)


//Trek across the desert in groups
/datum/aiHolder/eleuaua

	New()
		. = ..()
		var/datum/aiTask/timed/wander/W =  get_instance(/datum/aiTask/timed/wander, list(src)) //In between rallies
		var/datum/aiTask/mass_rally/MR = get_instance(/datum/aiTask/mass_rally, list(src))
		var/datum/aiTask/sequence/goalbased/rally/R = get_instance(/datum/aiTask/sequence/goalbased/rally, list(src, src.default_task))
		var/datum/aiTask/succeedable/move/M = get_instance(/datum/aiTask/succeedable/move, list(src))
		W.transition_task = MR
		R.transition_task = W
		//MR transitioning into R is done in mass_rally/on_tick
		default_task = W
		W.maximum_task_ticks = 5 // The first eleuaua to tick over sends the whole group, so might as well make them all wander the same amount

		R.can_be_adjacent_to_target = TRUE
		R.max_traverse = 300

		M.max_traverse = 300

/datum/random_event/minor/eleuaua_herd
	disabled = TRUE
	name = "Spawn eleuaua group"

	event_effect()
		..()
		var/turf/drop_point = pick_landmark("eleuaua_test")
		if (!drop_point)
			return
		for (var/i in 1 to (rand(9,12)))
			new /mob/living/critter/desert/eleuaua(drop_point)
