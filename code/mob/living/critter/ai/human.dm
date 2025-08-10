/mob/living/carbon/human/var/uses_mobai = 0

/datum/aiHolder/human

/datum/aiTask/timed/targeted/human/get_targets()
	. = list()
	if(holder.owner)
		for(var/mob/living/M in view(target_range, holder.owner))
			if(M == holder.owner) continue
			if(isalive(M))
				. += M



/datum/aiTask/timed/targeted/human
	frustration_check()
		.= 0
		if (!IN_RANGE(holder.owner, holder.target, target_range))
			if(frustration >= frustration_threshold) // give up already you goddamn salad.
				holder.target = null
			return 1

		if (ismob(holder.target))
			var/mob/M = holder.target
			. = !(holder.target && isalive(M))
		else
			. = !(holder.target)

/datum/aiTask/timed/targeted/human/get_weapon
	name = "getting strapped"
	minimum_task_ticks = 3
	maximum_task_ticks = 5
	target_range = 5
	frustration_threshold = 2
	var/last_seek = 0

	get_targets()
		var/list/targets = list()
		if(holder.owner)
			for(var/obj/item/gun/G in view(target_range, holder.owner))
				if(G.canshoot())
					targets += G
			if(!targets.len)
				for(var/obj/item/I in view(target_range, holder.owner))
					if(I.force >= 3)
						targets += I
		return targets

	next_task()
		if(holder.ownhuman.equipped())
			return transition_task
		return null

	on_tick()
		if (HAS_MOB_PROPERTY(holder.ownhuman, PROP_CANTMOVE) || !isalive(holder.ownhuman))
			return

		if(!holder.target)
			if (world.time > last_seek + 4 SECONDS)
				last_seek = world.time
				var/list/possible = get_targets()
				if (possible.len)
					holder.target = pick(possible)

		if(holder.target && holder.target.z == holder.ownhuman.z)
			var/dist = get_dist(holder.ownhuman, holder.target)
			if (dist >= 1)
				if (prob(80))
					holder.move_to(holder.target,0)
				else
					holder.move_circ(holder.target)
			else
				holder.stop_move()

			if (dist <= 1)
				holder.ownhuman.put_in_hand_or_drop(holder.target)


/datum/aiTask/timed/targeted/human/cower
	name = "panicking"
	minimum_task_ticks = 3
	maximum_task_ticks = 10
	target_range = 7
	frustration_threshold = 4
	var/last_seek = 0

	frustration_check()
		. = 0
		if (IN_RANGE(holder.owner, holder.target, target_range))
			. = 1

	on_tick()
		if (HAS_MOB_PROPERTY(holder.ownhuman, PROP_CANTMOVE) || !isalive(holder.ownhuman))
			return

		if(!holder.target)
			if (world.time > last_seek + 4 SECONDS)
				last_seek = world.time
				var/list/possible = get_targets()
				if (possible.len)
					holder.target = pick(possible)

		if(holder.target && holder.target.z == holder.ownhuman.z)
			var/dist = get_dist(holder.ownhuman, holder.target)
			if(dist <= 1)
				holder.ownhuman.a_intent = INTENT_DISARM
				holder.ownhuman.set_dir(get_dir(holder.ownhuman, holder.target))
				var/list/params = list()
				params["left"] = 1
				holder.ownhuman.hand_attack(holder.target, params)
				if(prob(25))
					holder.ownhuman.emote("faint")

			if(dist <= target_range)
				if(prob(25))
					if(prob(25))
						holder.ownhuman.vomit()
					holder.ownhuman.say("[pick("please, please get away...","don't come any closer!","oh no oh no no no no oh no","HELP! HELP! OH GOD PLEASE HELP!")]")
				else
					if(prob(50))
						holder.ownhuman.emote("scream")
						if(prob(50))
							holder.ownhuman.setStatus("resting", 0.5 SECONDS)
							holder.ownhuman.force_laydown_standup()
							holder.ownhuman.hud.update_resting()
							holder.ownhuman.resist()
					else
						holder.move_away(holder.target,target_range)
					if(prob(25))
						holder.ownhuman.stuttering+=5
		..()

/datum/aiTask/timed/targeted/human/flee
	name = "running away"
	minimum_task_ticks = 3
	maximum_task_ticks = 10
	target_range = 2
	frustration_threshold = 4
	var/last_seek = 0

	frustration_check()
		. = 0
		if (IN_RANGE(holder.owner, holder.target, target_range))
			. = 1

	on_tick()
		if (HAS_MOB_PROPERTY(holder.ownhuman, PROP_CANTMOVE) || !isalive(holder.ownhuman))
			return

		if(!holder.target)
			if (world.time > last_seek + 4 SECONDS)
				last_seek = world.time
				var/list/possible = get_targets()
				if (possible.len)
					holder.target = pick(possible)

		if(holder.target && holder.target.z == holder.ownhuman.z)
			var/dist = get_dist(holder.ownhuman, holder.target)
			if(dist <= 1)
				holder.ownhuman.a_intent = INTENT_DISARM
				holder.ownhuman.set_dir(get_dir(holder.ownhuman, holder.target))
				var/list/params = list()
				params["left"] = 1
				holder.ownhuman.hand_attack(holder.target, params)

			if(dist <= target_range + 3)
				if(prob(25))
					holder.move_circ(holder.target,target_range)
				else
					holder.move_away(holder.target,target_range)
		..()


/datum/aiTask/timed/targeted/human/boxing/
	name = "boxing"
	minimum_task_ticks = 10
	maximum_task_ticks = 26
	target_range = 8
	frustration_threshold = 5
	var/last_seek = 0

	on_tick()
		if (HAS_MOB_PROPERTY(holder.ownhuman, PROP_CANTMOVE) || !isalive(holder.ownhuman))
			return

		if(!holder.target)
			if (world.time > last_seek + 4 SECONDS)
				last_seek = world.time
				var/list/possible = get_targets()
				if (possible.len)
					holder.target = pick(possible)
		if(holder.target && holder.target.z == holder.ownhuman.z)
			var/dist = get_dist(holder.ownhuman, holder.target)
			if (dist >= 1)
				if (prob(80))
					holder.move_to(holder.target,0)
				else
					holder.move_circ(holder.target)
			else
				holder.stop_move()

			if (ismob(holder.target))
				var/list/params = list()
				params["left"] = 1
				var/mob/living/M = holder.target
				if(!isalive(M))
					holder.target = null
					holder.target = get_best_target(get_targets())
					if(!holder.target)
						return ..() // try again next tick
				if ((dist <= 3) && holder.ownhuman.equipped())
					holder.ownhuman.set_dir(get_dir(holder.ownhuman, M))
					holder.ownhuman.throw_item(holder.target,params)
				if (dist <= 1)
					holder.ownhuman.a_intent = INTENT_HARM
					holder.ownhuman.set_dir(get_dir(holder.ownhuman, M))

					holder.ownhuman.hand_attack(M, params)
				if(prob(25))
					holder.move_circ(holder.target,1) // trying 2 -> 1

		..()

/datum/aiTask/timed/targeted/human/suplex
	name = "suplex"
	minimum_task_ticks = 7
	maximum_task_ticks = 16
	target_range = 8
	frustration_threshold = 5
	var/last_seek = 0

	on_tick()

		if (HAS_MOB_PROPERTY(holder.ownhuman, PROP_CANTMOVE) || !isalive(holder.ownhuman))
			return

		if(!holder.target)
			if (world.time > last_seek + 4 SECONDS)
				last_seek = world.time
				var/list/possible = get_targets()
				if (possible.len)
					holder.target = pick(possible)
		if(holder.target && holder.target.z == holder.ownhuman.z)
			var/dist = get_dist(holder.ownhuman, holder.target)
			if (dist >= 1)
				if (prob(80))
					holder.move_to(holder.target,0)
				else
					holder.move_circ(holder.target)
			else
				holder.stop_move()

			if (ismob(holder.target))
				var/mob/living/M = holder.target
				if(!isalive(M))
					holder.target = null
					holder.target = get_best_target(get_targets())
					if(!holder.target)
						return ..() // try again next tick
				if (dist <= 1)
					holder.ownhuman.a_intent = INTENT_GRAB

					holder.ownhuman.set_dir(get_dir(holder.ownhuman, M))

					var/list/params = list()
					params["left"] = 1

					if (!holder.ownhuman.equipped())
						holder.ownhuman.hand_attack(M, params)
					else
						var/obj/item/grab/G = holder.ownhuman.equipped()
						if (istype(G))
							if (G.affecting == null || G.assailant == null || G.disposed) //ugly safety
								holder.ownhuman.drop_item()

							if (G.state <= GRAB_PASSIVE)
								G.attack_self(holder.ownhuman)
							else
								holder.ownhuman.emote("flip")
								holder.move_away(holder.target,1)
						else
							holder.ownhuman.drop_item()
			else
				holder.move_circ(holder.target,2)

		..()

/datum/aiTask/timed/targeted/human/charge
	name = "charge"
	minimum_task_ticks = 7
	maximum_task_ticks = 16
	target_range = 8
	frustration_threshold = 2
	var/last_seek = 0

	on_tick()
		if (HAS_MOB_PROPERTY(holder.ownhuman, PROP_CANTMOVE) || !isalive(holder.ownhuman))
			return

		if(!holder.target)
			if (world.time > last_seek + 4 SECONDS)
				last_seek = world.time
				var/list/possible = get_targets()
				if (possible.len)
					holder.target = pick(possible)
		if(holder.target && holder.target.z == holder.ownhuman.z)
			var/dist = get_dist(holder.ownhuman, holder.target)
			holder.ownhuman.a_intent = INTENT_GRAB
			if (dist >= 1)
				if (prob(80))
					holder.move_to(holder.target,0)
				else
					holder.move_circ(holder.target)
			else
				holder.stop_move()
			if (dist <= 1)
				holder.ownhuman.Bump(holder.target)
				frustration++


/datum/aiHolder/human/geneticist
	New()
		..()
		var/datum/aiTask/timed/targeted/human/genetics/G = get_instance(/datum/aiTask/timed/targeted/human/genetics, list(src))
		default_task = G
		G.transition_task = G

/datum/aiTask/timed/targeted/human/genetics
	var/speakprob = 5
	name = "researching"

	on_tick()
		..()
		if(holder.owner)
			var/area/A = get_area(holder.owner)
			if(A && A.population && A.population.len && prob(speakprob))
				var/list/stuff_to_say = strings("gimmick_speech.txt", "geneticist")
				holder.owner.say(pick(stuff_to_say))

			else
				for(var/obj/machinery/computer/genetics/G in orange(5,holder.owner))
					walk_to(holder.owner,G,1,0,8)
					return
				walk_to(holder.owner,0)

/datum/aiHolder/human/clubfert
	New()
		..()
		var/datum/aiTask/timed/targeted/human/clubdance/D = get_instance(/datum/aiTask/timed/targeted/human/clubdance, list(src))
		default_task = D
		D.transition_task = D

/datum/aiTask/timed/targeted/human/clubdance
	var/speakprob = 1
	var/danceprob = 75
	var/moveprob = 50
	var/stopprob = 20
	var/target_landmark = null
	var/on_three = 1
	name = "dancing"

	on_tick()
		..()
		if(holder.owner)
			var/area/A = get_area(holder.owner)
			holder.owner.dir = pick(cardinal)
			if (on_three == 3)
				if(A && A.population && A.population.len) //don't do shit unless someone's around
					if(prob(speakprob))
						//if (bioholder whatever has fert)
						var/list/stuff_to_say = strings("gimmick_speech.txt", "fert") //just one thing in here for now though

						//var/list/stuff_to_say = strings("gimmick_speech.txt", "fert")
							//else human speech
						holder.owner.say(pick(stuff_to_say))
					if(prob(danceprob))
						if (prob(80)) holder.owner.emote(pick("dance", "laugh"))
						else if (prob(75)) holder.owner.emote(pick("flip", "laugh","twerk","twitch"))
						else if (prob(5)) holder.owner.emote("snap") //watch those ferret fongers, friends, you might snap 'em off
					if(prob(moveprob))
						//This is to keep them on task and from dancing out of the club
						step(holder.owner,pick(alldirs))
						target_landmark = pick_landmark(LANDMARK_CLUB_JUICE_DANCE) //like seriously
						walk_to(holder.owner,target_landmark,1,12,0) //take it slow on the dance floor
				on_three = 1
			on_three++
