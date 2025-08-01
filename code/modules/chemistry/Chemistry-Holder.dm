//defines moved to _setup.dm

///////////////////////////////////////////////////////////////////////////////////


//If i somehow could add something that sets the temp of all reagents to the average and calls their temp reactions
//in the update_total_temp , without causing an endless loop - i could have the reagents cool each other down etc.
//Right now only cryostylane does that kinda stuff because its coded that way. So yup. Right now you have to code it.

// Exadv1: reagent_list is now an ASSOCIATIVE LIST for performance reasons

//SpyGuy: Testing out a possibility-based reaction list

var/list/datum/reagents/active_reagent_holders = list()

var/list/datum/reagents/combusting_reagent_holders = list()

proc/chem_helmet_check(mob/living/carbon/human/H, var/what_liquid="hot")
	if(H.wear_mask)
		boutput(H, "<span class='alert'>Your mask protects you from the [what_liquid] liquid!</span>")
		return 0
	else if(H.head)
		boutput(H, "<span class='alert'>Your helmet protects you from the [what_liquid] liquid!</span>")
		return 0
	return 1

proc/chemhood_check(mob/living/carbon/human/H)
	if(H.wear_mask == /obj/item/clothing/head/chemhood && H.wear_suit == /obj/item/clothing/suit/chemsuit )
		boutput(H, "<span class='alert'>FUCK YOU ACID</span>")
		return 0
	else
		return 1

datum
	reagents
		var/list/datum/reagent/reagent_list = new/list()
		var/maximum_volume = 100
		var/atom/my_atom = null
		var/last_basic_explosion = 0

		//Variables related to burn rate and temperature
		var/is_combusting = FALSE
		var/combustible_volume = 0
		var/composite_combust_speed = 0
		var/composite_combust_temp = 0
		var/composite_combust_energy = 0
		var/composite_volatility = 0
		var/combustible_pressure = 0

		var/last_temp = T20C
		var/total_temperature = T20C
		var/total_volume = 0
		var/composite_heat_capacity = 0

		var/defer_reactions = 0 //Set internally to prevent reactions inside reactions.
		var/deferred_reaction_checks = 0
		var/processing_reactions = 0
		var/inert = 0 //Do not react. At all. Do not pass go, do not collect $200. Halt. Stop right there, son.

		var/list/addiction_tally = null

		var/list/datum/chemical_reaction/possible_reactions = list()
		var/list/datum/chemical_reaction/active_reactions = list()

		var/list/covered_cache = 0
		var/covered_cache_volume = 0

		var/temperature_cap = 10000
		var/temperature_min = 0

		var/postfoam = 0 //attempt at killing infinite foam
		var/can_be_heated = TRUE //can be heated by external sources

		New(maximum=100)
			..()
			maximum_volume = maximum

		disposing()
			if (reagent_list)
				for(var/reagent_id in reagent_list)
					var/datum/reagent/current_reagent = reagent_list[reagent_id]
					if(current_reagent)
						qdel(current_reagent)
				reagent_list.len = 0
				reagent_list = null
			my_atom = null
			total_volume = 0
			addiction_tally = null
			if(src.is_combusting)
				combusting_reagent_holders -= src
			..()

		proc/covered_turf()
			.= list()
			if (my_atom)
				.+= get_turf(my_atom)

		proc/cache_covered_turf()
			covered_cache = covered_turf() //heh
			covered_cache_volume = total_volume

		proc/play_mix_sound(var/mix_sound)
			playsound(my_atom, mix_sound, 80, 1, 3)

		proc/copy_to(var/datum/reagents/target, var/multiplier = 1, var/do_not_react = 0, var/copy_temperature = 0)
			if(!target || target == src) return
			var/newtemp = copy_temperature ? src.total_temperature : T20C
			for(var/reagent_id in reagent_list)
				var/datum/reagent/current_reagent = reagent_list[reagent_id]
				if(current_reagent)
					target.add_reagent(reagent=reagent_id, amount=max(current_reagent.volume * multiplier, 0.001),donotreact=do_not_react, temp_new = newtemp) //mbc : fixed reagent duplication bug by changing max(x,1) to max(x,0.001). Still technically possible to dupe, but not realistically doable.
					current_reagent.on_copy(target.reagent_list[reagent_id])
				if(!target) return

			return target

		proc/set_reagent_temp(var/new_temp = T0C, var/react = 0)
			src.last_temp = total_temperature
			src.total_temperature = new_temp
			if (react)
				temperature_react()

		proc/temperature_react() //Calls the temperature reaction procs without changing the temp.
			for(var/reagent_id in reagent_list)
				var/datum/reagent/current_reagent = reagent_list[reagent_id]
				if(current_reagent && src.total_temperature >= current_reagent.minimum_reaction_temperature)
					current_reagent.reaction_temperature(src.total_temperature, 100)

		proc/temperature_reagents(exposed_temperature, exposed_volume = 100, exposed_heat_capacity = 100, change_cap = 15, change_min = 0.0000001,loud = 0)
			///This is what you use to change the temp of a reagent holder.
			///Do not manually change the reagent unless you know what youre doing.
			if (!src.can_be_heated)
				return
			last_temp = total_temperature
			var/exposed_temp = max(exposed_temperature,0)
			if(loud)
				boutput(world,"exposed_temp: [exposed_temp]")
			exposed_volume = exposed_volume/100 //abitrary but w/e, it makes the new values similar to old ones
			if(loud)
				boutput(world,"exposed_volume: [exposed_volume]")

			if(loud)
				boutput(world,"total_volume: [total_volume]")
			if(loud)
				boutput(world,"composite_heat_capacity: [composite_heat_capacity]")

			var/new_temperature = (total_temperature*total_volume*composite_heat_capacity + exposed_temp*exposed_volume*exposed_heat_capacity)/max(total_volume*composite_heat_capacity + exposed_volume*exposed_heat_capacity, 1)

			if(loud)
				boutput(world,"new_temperature = ([total_temperature]*[total_volume]*[composite_heat_capacity] + [exposed_temp]*[exposed_volume]*[exposed_heat_capacity])/([total_volume]*[composite_heat_capacity] + [exposed_volume]*[exposed_heat_capacity])")

			if(loud)
				boutput(world,"new_temperature: [new_temperature]")

			var/change = new_temperature - total_temperature

			if(change < 0)
				change = -clamp(abs(change),change_min,change_cap)
			else
				change = clamp(abs(change),change_min,change_cap)

			if(loud)
				boutput(world,"change: [change]")

			total_temperature += change

			total_temperature = clamp(total_temperature, temperature_min, temperature_cap) //Cap for the moment.

			update_total()

			temperature_react()

			handle_reactions()

		proc/remove_any(var/amount=1)
			if(amount > total_volume) amount = total_volume
			if(amount <= 0) return

			var/remove_ratio = amount/total_volume

			for(var/reagent_id in reagent_list)
				var/datum/reagent/current_reagent = reagent_list[reagent_id]
				if(current_reagent)
					var/transfer_amt = current_reagent.volume*remove_ratio
					src.remove_reagent(reagent_id, transfer_amt)

			src.update_total()

			return amount

		proc/remove_any_to(var/amount=1)
			if(amount > total_volume) amount = total_volume
			if(amount <= 0) return

			var/datum/reagents/R = new()

			var/remove_ratio = amount/total_volume

			for(var/reagent_id in reagent_list)
				var/datum/reagent/current_reagent = reagent_list[reagent_id]
				if(current_reagent)
					var/transfer_amt = current_reagent.volume*remove_ratio
					R.add_reagent(reagent_id, transfer_amt, current_reagent.data)
					src.remove_reagent(reagent_id, transfer_amt)

			src.update_total()

			return R

		proc/remove_any_except(var/amount=1, var/exception)
			if(amount > total_volume) amount = total_volume
			if(amount <= 0) return

			var/remove_ratio = amount/total_volume

			for(var/reagent_id in reagent_list)
				if (reagent_id == exception)
					continue

				var/datum/reagent/current_reagent = reagent_list[reagent_id]
				if(current_reagent)
					var/transfer_amt = current_reagent.volume*remove_ratio
					src.remove_reagent(reagent_id, transfer_amt)

			src.update_total()

			return amount

		proc/get_master_reagent_name()
			var/largest_name = null
			var/largest_volume = 0

			for(var/reagent_id in reagent_list)
				if(reagent_id == "smokepowder") continue
				var/datum/reagent/current = reagent_list[reagent_id]
				if(current.volume > largest_volume)
					largest_name = current.name
					largest_volume = current.volume

			return largest_name

		proc/get_master_reagent_name_except(var/exception)
			var/largest_name = null
			var/largest_volume = 0

			for(var/reagent_id in reagent_list)
				if(reagent_id == "smokepowder") continue
				if(reagent_id == exception) continue
				var/datum/reagent/current = reagent_list[reagent_id]
				if(current.volume > largest_volume)
					largest_name = current.name
					largest_volume = current.volume

			return largest_name

		proc/get_master_reagent_id()
			var/largest_id = null
			var/largest_volume = 0

			for(var/reagent_id in reagent_list)
				if(reagent_id == "smokepowder") continue
				var/datum/reagent/current = reagent_list[reagent_id]
				if(current.volume > largest_volume)
					largest_id = current.id
					largest_volume = current.volume

			return largest_id

		proc/get_master_color(var/ignore_smokepowder = 0)
			var/largest_volume = 0
			var/the_color = rgb(255,255,255,255)

			for(var/reagent_id in reagent_list)
				if(reagent_id == "smokepowder" && ignore_smokepowder) continue
				var/datum/reagent/current = reagent_list[reagent_id]
				if(current.volume > largest_volume)
					largest_volume = current.volume
					the_color = rgb(current.fluid_r, current.fluid_g, current.fluid_b, max(current.transparency,255))

			return the_color

		proc/get_master_reagent()
			var/largest_id = ""
			var/largest_volume = 0

			for(var/reagent_id in reagent_list)
				if(reagent_id == "smokepowder") continue
				var/datum/reagent/current = reagent_list[reagent_id]
				if(current.volume > largest_volume)
					largest_volume = current.volume
					largest_id = reagent_id

			return largest_id

		proc/get_master_reagent_slippy()
			var/largest_block_slippy = null
			var/largest_volume = 0

			for(var/reagent_id in reagent_list)
				if(reagent_id == "smokepowder") continue
				var/datum/reagent/current = reagent_list[reagent_id]
				if(current.volume > largest_volume)
					largest_block_slippy = current.block_slippy
					largest_volume = current.volume

			return largest_block_slippy

		proc/get_master_reagent_gas_opaque()
			var/opacity_to_return = null
			var/largest_volume = 0

			for(var/reagent_id in reagent_list)
				var/datum/reagent/current = reagent_list[reagent_id]
				if(current.volume > largest_volume)
					opacity_to_return = current.blocks_sight_gas
					largest_volume = current.volume

			return opacity_to_return

		// index = which reagent to transfer (0 = all)
		proc/trans_to(var/obj/target, var/amount=1, var/multiplier=1, var/do_fluid_react=1, var/index=0)
			if(amount > total_volume) amount = total_volume
			if(amount <= 0) return
			if(!target) return

			if (isnull(target.reagents))
				target.reagents = new
				target.reagents.my_atom = target

			var/datum/reagents/target_reagents = target.reagents
			amount = min(amount, target_reagents.maximum_volume - target_reagents.total_volume)

			if (do_fluid_react && issimulatedturf(target))
				var/turf/T = target
				return T.fluid_react(src, amount, index = index)

			return trans_to_direct(target_reagents, amount, multiplier, index = index)

		//MBC note : I added update_target_reagents and update_self_reagents vars for fluid handling. y'see, there are a ton of transfer operations involving fluids that don't need to update reagents immediately as they happen.
		// we would rather perform all the transfers, and then batch update the reagents when necessary. Saves us from some lag, and avoids some *buggy shit*!
		proc/trans_to_direct(var/datum/reagents/target_reagents, var/amount=1, var/multiplier=1, var/update_target_reagents = 1, var/update_self_reagents = 1, var/index = 0)
			if (!target_reagents || !total_volume) //Wire & ZeWaka: Fix for Division by zero
				return
			var/transfer_ratio = amount/total_volume

			if(!index)
				for(var/reagent_id in reagent_list)
					var/datum/reagent/current_reagent = reagent_list[reagent_id]

					if (isnull(current_reagent) || current_reagent.volume == 0)
						continue

					var/transfer_amt = current_reagent.volume*transfer_ratio
					var/receive_amt = transfer_amt * multiplier

					//if(istype(current_reagent, /datum/reagent/disease))
					//	target_reagents.add_reagent_disease(current_reagent, (transfer_amt * multiplier), current_reagent.data, current_reagent.temperature)
					//else
					target_reagents.add_reagent(reagent_id, receive_amt, current_reagent.data, src.total_temperature, !update_target_reagents)

					current_reagent.on_transfer(src, target_reagents, receive_amt)

					src.remove_reagent(reagent_id, transfer_amt, update_self_reagents, update_self_reagents)
			else //Only transfer one reagent
				var/CI = 1
				for(var/reagent_id in reagent_list)
					if ( CI++ == index )
						var/datum/reagent/current_reagent = reagent_list[reagent_id]
						if (isnull(current_reagent) || current_reagent.volume == 0)
							return 0
						var/transfer_amt = min(current_reagent.volume,amount)
						var/receive_amt = transfer_amt * multiplier
						target_reagents.add_reagent(reagent_id, receive_amt, current_reagent.data, src.total_temperature, !update_target_reagents)
						current_reagent.on_transfer(src, target_reagents, receive_amt)
						src.remove_reagent(reagent_id, transfer_amt, update_self_reagents, update_self_reagents)
						return 0

			if (update_self_reagents)
				src.update_total()
				src.handle_reactions()
				// this was missing. why was this missing? i might be breaking the shit out of something here
				reagents_changed()

			if (!target_reagents) // on_transfer may murder the target, see: nitroglycerin
				return amount

			if (update_target_reagents)
				target_reagents.update_total()
				target_reagents.handle_reactions()
				if(src.is_combusting)
					target_reagents.start_combusting()


			return amount

		proc/aggregate_pathogens()
			var/list/ret = list()
			for (var/reagent_id in pathogen_controller.pathogen_affected_reagents)
				if (src.has_reagent(reagent_id))
					var/datum/reagent/blood/B = src.get_reagent(reagent_id)
					if (!istype(B))
						continue
					for (var/uid in B.pathogens)
						if (!(uid in ret))
							ret += uid
							ret[uid] = B.pathogens[uid]
			return ret

		//multiplier is used to handle realtime metabolizations over byond time
		proc/metabolize(var/mob/target, var/multiplier = 1)
			if (islist(src.addiction_tally) && length(src.addiction_tally)) // if we got some addictions to process
				//DEBUG_MESSAGE("metabolize([target]) addiction_tally processing")
				for (var/rid in src.addiction_tally) // look at each addiction tally
					if (src.reagent_list.Find(rid)) // if we find that we've got that reagent in us right now
						//DEBUG_MESSAGE("[rid] currently in holder, continuing")
						continue // our tally's gunna go up for this reagent when it runs on_mob_life() below, so don't reduce it
					//DEBUG_MESSAGE("src.addiction_tally\[[rid]\] was [src.addiction_tally[rid]], now [src.addiction_tally[rid] - 0.2]")
					src.addiction_tally[rid] -= 0.01 * multiplier// otherwise, reduce it
					if (src.addiction_tally[rid] <= 0)
						src.addiction_tally -= rid

			var/mult_per_reagent = 1
			for (var/current_id in reagent_list)
				var/datum/reagent/current_reagent = reagent_list[current_id]
				if (current_reagent)
					mult_per_reagent = min(multiplier,current_reagent.how_many_depletions(target)) //limit the multiplier by how many depletions we have left

					//Actually, cap the multiplier minimum at 1	. This preserves some of the original expected funky stuff pre-realtime changes.
					// If someone who knows more about chemistry than MBC wants to remove this line, go right ahead :
					//mult_per_reagent = max(mult_per_reagent, 1)
					//hey this is mbc a couple months later, i commented out this line.


					current_reagent.on_mob_life(target, mult = mult_per_reagent)

			update_total()

		proc/handle_reactions()
			if(src.inert) return //We magically prevent all reactions inside ourselves.
			//if(ismob(my_atom)) return //No reactions inside mobs :I
			if (defer_reactions)
				deferred_reaction_checks++
				return
			var/list/old_reactions = active_reactions
			active_reactions = list()
			reaction_loop:
				for(var/datum/chemical_reaction/C in src.possible_reactions)
					if (!islist(C.required_reagents)) //This shouldn't happen but when practice meets theory...they beat the shit out of one another I guess
						continue

					if(C.required_temperature != -1)
						if(C.required_temperature <= 0) //total_temperature needs to be lower than absolute value of this temp
							if(abs(C.required_temperature) < total_temperature) continue //Not the right temp.
						else if(C.required_temperature > total_temperature) continue
						//Min / max temp intervals
						if(total_temperature < C.min_temperature)
							continue
						else if(total_temperature > C.max_temperature) continue

						// TODO: CONSIDER: reactions should probably occur if temp >= req temp not within bound of it
						// Monkeys: Did this, just put a required_temperature as negative to make the reaction happen below a temp rather than above.

					var/total_matching_reagents = 0
					var/created_volume = src.maximum_volume
					for(var/B in C.required_reagents)
						var/B_required_volume = max(CHEM_EPSILON, C.required_reagents[B])


						//var/amount = get_reagent_amount(B)
						//trying to reduce proc call overhead from fluid system
						//copied get_reagent_amount proc here because it's relatively simple procedure
						var/amount = 0
						try
							if (reagent_list[B])
								var/datum/reagent/current_reagent = reagent_list[B]
								amount = current_reagent.volume
						catch (var/e)
							logTheThing("debug", usr, null, "CRASH: reagent holder / handle_reactions: [C.name] reaction, reagent checked: '[B]', required = '[B_required_volume]', reagents in thing: [log_reagents(my_atom)].")
							CRASH("reagent holder / handle_reactions: tried to get reagent list '[B]' from '[reagent_list]' / [e]")
						//end my copy+paste


						if(round(amount, CHEM_EPSILON) >= B_required_volume) //This will mean you can have < 1 stuff not react. This is fine.
							total_matching_reagents++
							created_volume = min(created_volume, amount * (C.result_amount ? C.result_amount : 1) / B_required_volume)
						else
							break
					if(total_matching_reagents == C.required_reagents.len)
						for (var/inhibitor in C.inhibitors)
							if (src.has_reagent(inhibitor))
								continue reaction_loop

						if(!C.does_react(src))
							continue reaction_loop

						if (!old_reactions.Find(C))
							var/turf/T = 0
							if (my_atom)
								for(var/mob/living/M in AIviewers(7, get_turf(my_atom)) )	//Fuck you, ghosts
									if (C.mix_phrase) boutput(M, "<span class='notice'>[bicon(my_atom)] [C.mix_phrase]</span>")
								if (C.mix_sound) play_mix_sound(C.mix_sound)

								T = get_turf(my_atom.loc)

							// Ideally, we'd like to know the contents of chemical smoke and foam (Convair880).
							if (C.special_log_handling)
								logTheThing("combat", usr, null, "[C.name] chemical reaction [log_reagents(my_atom)] at [T ? "[log_loc(T)]" : "null"].")
							else
								logTheThing("combat", usr, null, "[C.name] chemical reaction at [T ? "[log_loc(T)]" : "null"].")

						if (C.instant)
							//MBC : Cache covered turfs right before the reagents are deleted.
							// This is necessary to allow reactions to take place as part of a fluid.
							cache_covered_turf()
							var/datum/reagents/fluid_group/FG
							if (istype(src,/datum/reagents/fluid_group))
								FG = src
							if (C.consume_all)
								for(var/B in C.required_reagents)
									if (FG) //MBC : I don't like doing this here, but it is necessary for fluids not to delete themselves mid-reaction
										FG.skip_next_update = 1
									src.del_reagent(B)
							else
								for(var/B in C.required_reagents)
									if (FG)
										FG.skip_next_update = 1
									src.remove_reagent(B, C.required_reagents[B] * created_volume / (C.result_amount ? C.result_amount : 1))
							src.add_reagent(C.result, created_volume)
							if(created_volume <= 0) //MBC : If a fluid reacted but didn't create anything, we require an update_total call to do drain/evaporate checks.
								src.update_total()
								if (FG && FG.my_group && src.total_volume <= 0) //also evaporate safety here
									FG.my_group.evaporate()
							C.on_reaction(src, created_volume)
							covered_cache = 0
							continue
						active_reactions += C

			if (!active_reactions.len)
				if (processing_reactions && !src.is_combusting)
					processing_reactions = 0
					active_reagent_holders -= src
			else if (!processing_reactions)
				processing_reactions = 1
				active_reagent_holders += src
			return 1

		proc/process_reactions()
			defer_reactions = 1
			deferred_reaction_checks = 0

			for(var/datum/chemical_reaction/C in src.active_reactions)
				if (C.result_amount <= 0)
					src.active_reactions -= C
					continue
				var/speed = C.reaction_speed
				for (var/reagent in C.required_reagents)
					var/required_amount = C.required_reagents[reagent] * speed / C.result_amount

					//Copy+paste to reduce proc calls
					//var/amount = get_reagent_amount(reagent)
					if (!(reagent in reagent_list))
						continue
					var/datum/reagent/current_reagent = reagent_list[reagent]
					var/amount = current_reagent ? current_reagent.volume : 0
					//end copy+paste

					if (amount < required_amount)
						speed *= amount / required_amount
				if (speed <= 0) // don't add anything that modifies the speed before this check
					src.active_reactions -= C
					continue

				cache_covered_turf()
				C.on_reaction(src, speed)
				for (var/reagent in C.required_reagents)
					src.remove_reagent(reagent, C.required_reagents[reagent] * speed / C.result_amount)
				if (C.result)
					src.add_reagent(C.result, speed,, src.total_temperature)
				covered_cache = 0

				if(my_atom?.loc) //We might be inside a thing, let's tell it we updated our reagents.
					my_atom.loc.handle_event("reagent_holder_update", src)

			defer_reactions = 0
			if (deferred_reaction_checks)
				src.handle_reactions()
			else if (!active_reactions.len && processing_reactions)
				processing_reactions = 0
				active_reagent_holders -= src

		proc/isolate_reagent(var/reagent)
			for(var/current_id in reagent_list)
				if (current_id != reagent)
					del_reagent(current_id)
					update_total()

		proc/del_reagent(var/reagent)
			var/datum/reagent/current_reagent = reagent_list[reagent]

			if (current_reagent)
				current_reagent.volume = 0 //mbc : I put these checks here to try to prevent an infloop
				if (current_reagent.pooled) //Caused some sort of infinite loop? gotta be safe.
					reagent_list.Remove(reagent)
					return 0
				else
					current_reagent.on_remove()
					remove_possible_reactions(current_reagent.id) //Experimental structure
					reagent_list.Remove(reagent)
					update_total()

					reagents_changed()

					qdel(current_reagent)

					return 0

			src.handle_reactions() // trigger inhibited reactions

			return 1

		proc/stop_combusting()
			if(src.is_combusting)
				src.is_combusting = FALSE
				src.combustible_pressure = 0
				combusting_reagent_holders -= src
				if(src.my_atom)
					src.my_atom.stopped_reagent_combustion()

		proc/start_combusting() // Starts combustion
			if (!src.is_combusting && src.composite_volatility > 0.5)
				if(ismob(src.my_atom))
					src.my_atom.visible_message("<span class='alert'>The chemicals in [src.my_atom] begin burning!</span>",blind_message = "<span class='alert'>You hear flames roar to life!</span>")

				var/turf/T = get_turf(src.my_atom)
				var/mob/our_user = null
				var/our_fingerprints = null

				// Sadly, we don't automatically get a mob reference under most circumstances.
				// If there's an existing lookup proc and/or better solution, I haven't found it yet.
				// If everything else fails, maybe there are fingerprints on the container for us to check though?
				if (my_atom)
					if (ismob(my_atom)) // Our mob, the container.
						our_user = my_atom
					else if (my_atom && (ismob(my_atom.loc))) // Backpacks etc.
						our_user = my_atom.loc
					else
						our_user = usr
						if (my_atom.fingerprintslast) // Our container. You don't necessarily have to pick it up to transfer stuff.
							our_fingerprints = my_atom.fingerprintslast
						else if (my_atom.loc?.fingerprintslast) // Backpacks etc.
							our_fingerprints = my_atom.loc.fingerprintslast
				if (our_user && ismob(our_user))
					logTheThing("combat", our_user, null, "Combustion started ([my_atom ? log_reagents(my_atom) : log_reagents(src)]) at [T ? "[log_loc(T)]" : "null"].")
				else
					logTheThing("combat", our_user, null, "Combustion started ([my_atom ? log_reagents(my_atom) : log_reagents(src)]) at [T ? "[log_loc(T)]" : "null"].[our_fingerprints ? " Container last touched by: [our_fingerprints]." : ""]")

				combusting_reagent_holders += src
				src.is_combusting = TRUE
				if(src.my_atom)
					src.my_atom.started_reagent_combustion()
				src.process_combustion() // one free to get the party started fast


		proc/pressurized_open()
			if (src.combustible_volume)
				src.my_atom.visible_message("<span class='alert'>[src.my_atom] sprays pressurized flames everywhere!</span>",blind_message = "<span class='alert'>You hear a fiery hiss!", group = "pressure_venting_\ref[src]")
				var/fireflash_size = clamp(src.combustible_pressure * src.composite_volatility / 50, 0, 4)
				fireflash_sm(get_turf(src.my_atom), fireflash_size, src.composite_combust_temp, src.composite_combust_speed / (2 * fireflash_size))
				src.trans_to(src.my_atom.loc,src.combustible_volume * src.combustible_pressure / 15)
			src.combustible_pressure = 0

		proc/process_combustion(mult = 1) //Handles any chem that burns
			if (src.composite_volatility <= 0.5 || !src.combustible_volume)
				src.stop_combusting()
				return

			// surfaces burning
			if (src.my_atom && istype(src,/datum/reagents/surface))
				var/continue_burn = FALSE
				var/burn_volatility = src.composite_volatility * clamp((src.combustible_volume ** 0.25) / 3, 0.35, 1.2)
				burn_volatility = clamp(burn_volatility, 0, 30)
				var/burn_speed = src.composite_combust_speed
				src.temperature_reagents(src.composite_combust_temp, burn_volatility * 4, change_cap = 300, change_min = 1)

				if (!ON_COOLDOWN(my_atom, "surface_fire_1", 3 SECONDS))
					particleMaster.SpawnSystem(new /datum/particleSystem/internal_combustion_fire(src.my_atom, src.composite_combust_temp, 8))

				if(ismob(src.my_atom))
					src.my_atom.changeStatus("burning", burn_volatility SECONDS)
				src.my_atom.temperature_expose(null, src.total_temperature, src.total_volume)

				for (var/reagent_id in src.reagent_list)
					var/datum/reagent/reagent = src.reagent_list[reagent_id]
					if (reagent.flammable_influence)
						var/amount_to_remove = (burn_speed * mult) * (reagent.volume / src.combustible_volume)
						reagent.do_burn(min(amount_to_remove,reagent.volume))
						src.remove_reagent(reagent_id, amount_to_remove)
						if(src.has_reagent(reagent_id))
							continue_burn = TRUE

				if(!continue_burn)
					src.stop_combusting()
				return

			// Smoke and pools burning
			if (istype(src,/datum/reagents/fluid_group))
				var/covered_area = length(src.covered_turf())

				var/continue_burn = FALSE
				var/burn_volatility = src.composite_volatility *  clamp(src.combustible_volume / (40 * max(1, covered_area)), 0.3, 1)
				burn_volatility = clamp(burn_volatility, 0, 30)
				var/burn_speed = src.composite_combust_speed

				switch (burn_volatility)
					if (0 to 6)
						for (var/turf/T in src.covered_turf())
							fireflash_s(T, 0, src.composite_combust_temp, 0, src.composite_combust_energy * burn_speed / src.combustible_volume)
					if (6 to 15)
						burn_speed *= 1.25
						for (var/turf/T in src.covered_turf())
							fireflash_s(T, 0, src.composite_combust_temp, 0, src.composite_combust_energy * burn_speed / src.combustible_volume)
						if (prob(burn_volatility * 5) && length(src.covered_turf())) // from 30 to 75% chance to cause an additional, brighter fireball
							var/turf/chosen_turf = pick(src.covered_turf()) // intentionally no thermal energy
							fireflash_sm(chosen_turf, 1, src.composite_combust_temp * 1.5, src.composite_combust_temp / 3)
					if (15 to INFINITY)
						burn_speed *= 2
						for (var/turf/T in src.covered_turf())
							fireflash_sm(T, 0, src.composite_combust_temp, 0, energy = src.composite_combust_energy * burn_speed / src.combustible_volume)
						if (prob((burn_volatility) * 2 + 40) && length(src.covered_turf())) // from 70 to 100% chance to cause an additional, brighter fireball
							var/turf/chosen_turf = pick(src.covered_turf()) // intentionally no thermal energy
							fireflash_sm(chosen_turf, 1, src.composite_combust_temp * 1.5, src.composite_combust_temp / 3)
							if (prob(50))
								chosen_turf = pick(src.covered_turf()) // and 50% after that to cause an additional small explosion
								explosion(chosen_turf, chosen_turf, -1,-1,(burn_volatility - 14)/6, (burn_volatility - 14)/3)

				for (var/reagent_id in src.reagent_list)
					var/datum/reagent/reagent = src.reagent_list[reagent_id]
					if (reagent.flammable_influence)
						var/amount_to_remove = (burn_speed * mult * covered_area) * (reagent.volume / src.combustible_volume)
						reagent.do_burn(min(amount_to_remove,reagent.volume))
						src.remove_reagent(reagent_id, amount_to_remove)
						if(src.has_reagent(reagent_id))
							continue_burn = TRUE

				if(!continue_burn)
					src.stop_combusting()
				return

			// Open containers burning
			if (src.my_atom && src.my_atom.is_open_container()) // this includes headless people, fun fact
				if(combustible_pressure)
					src.pressurized_open()
				var/continue_burn = FALSE
				var/burn_volatility = src.composite_volatility * clamp((src.combustible_volume ** 0.25) / 3, 0.35, 1.25)
				if(src.total_temperature > (T0C + 700))
					burn_volatility += src.total_temperature / (T0C + 700) - 1
				burn_volatility = clamp(burn_volatility, 0, 30)
				var/burn_speed = src.composite_combust_speed
				src.temperature_reagents(src.composite_combust_temp, burn_volatility * 4, change_cap = 300, change_min = 1)

				if (!ON_COOLDOWN(my_atom, "internal_fire_1", 6 SECONDS))
					particleMaster.SpawnSystem(new /datum/particleSystem/internal_combustion_fire(src.my_atom, src.composite_combust_temp, 4))

				if (src.combustible_volume >= 5 && !ON_COOLDOWN(my_atom, "splatter_chem_fire", rand(20,50) - burn_volatility))
					src.my_atom.visible_message("<span class='alert'>[src.my_atom] sprays burning chemicals!</span>", blind_message = "<span class='alert'>You hear a hissing splatter!</span>", group = "splatter_chem_fire_\ref[src]")
					src.trans_to(src.my_atom.loc,max(src.combustible_volume * burn_volatility / 200, 5))
					if(QDELETED(src.my_atom))
						return

				switch(burn_volatility)
					if (2 to 5) // Unsafe, leaking flames
						fireflash_s(get_turf(src.my_atom), 0, src.composite_combust_temp, 0, src.composite_combust_energy * burn_speed / src.combustible_volume)
					if (5 to 14) // Very spicy fire that maybe breaks stuff
						burn_speed *= 2
						var/fireflash_size = clamp(((burn_volatility - 5) / 3), 0, 2)
						fireflash_s(get_turf(src.my_atom), fireflash_size, src.composite_combust_temp, src.composite_combust_temp / (2 * fireflash_size + 1), src.composite_combust_energy * burn_speed / src.combustible_volume)
						if (istype(src.my_atom, /obj) && prob(burn_volatility * (src.total_temperature / 10000)))
							var/obj/O = src.my_atom
							O.shatter_chemically(projectiles = TRUE)
							burn_speed = INFINITY
							if(QDELETED(src.my_atom))
								return
					if (14 to INFINITY) // splatter chems and break
						var/turf/T = get_turf(src.my_atom)
						var/explosion_size = clamp(((burn_volatility - 5) / 3), 0, 4)
						fireflash_sm(T, explosion_size, src.composite_combust_temp, src.composite_combust_temp / (3 * explosion_size + 1), energy = src.composite_combust_energy)
						explosion_size = clamp(((burn_volatility - 14) * (combustible_volume ** 0.33) / 3), 0, 6)
						explosion(src.my_atom, T, -1,-1,explosion_size/2,explosion_size)
						if (istype(src.my_atom, /obj))
							var/obj/O = src.my_atom
							O.shatter_chemically(projectiles = TRUE)
							burn_speed = INFINITY
							if(QDELETED(src.my_atom))
								return
						else
							burn_speed = INFINITY

				for (var/reagent_id in src.reagent_list)
					var/datum/reagent/reagent = src.reagent_list[reagent_id]
					if (reagent.flammable_influence)
						var/amount_to_remove = (burn_speed * mult) * (reagent.volume / src.combustible_volume)
						reagent.do_burn(min(amount_to_remove,reagent.volume))
						src.remove_reagent(reagent_id, amount_to_remove)
						if(src.has_reagent(reagent_id))
							continue_burn = TRUE

				if(!continue_burn)
					src.stop_combusting()
				return

			// Closed containers burning
			if (src.my_atom)
				var/continue_burn = FALSE
				var/burn_volatility = src.composite_volatility * clamp((src.combustible_volume ** 0.25) / 3, 0.35, 1.2)
				burn_volatility = clamp(burn_volatility, 0, 30)
				var/burn_speed = src.composite_combust_speed

				src.temperature_reagents(src.composite_combust_temp, burn_volatility * 10, change_cap = 300, change_min = 1)

				src.combustible_pressure += burn_volatility / 30 // ten seconds MINIMUM to explode

				if(ismob(src.my_atom))
					var/mob/M = src.my_atom
					if(!ON_COOLDOWN(M, "pressure_damage", (50 - burn_volatility) DECI SECONDS))
						random_burn_damage(M,rand(1,ceil(burn_volatility / 7)))
						random_brute_damage(M,rand(1,ceil(src.combustible_pressure / 4)))
						boutput(M,"<span class='alert'>Your insides burn!</span>","pressure_damage")

					if (src.combustible_pressure >= 0.1) // inform people
						if (prob(src.combustible_pressure * 5) && !ON_COOLDOWN(my_atom, "pressure_smoke_1", (rand(30, 60) - burn_volatility) DECI SECONDS))
							particleMaster.SpawnSystem(new /datum/particleSystem/blow_cig_smoke(M, M.dir))
						if (!ON_COOLDOWN(my_atom, "internal_fire_1", (ceil((11 - src.combustible_pressure) / 2) SECONDS)))
							particleMaster.SpawnSystem(new /datum/particleSystem/internal_combustion_fire(M, src.composite_combust_temp, src.combustible_pressure))

					if (src.combustible_pressure >= 10) // kaboom
						var/turf/T = get_turf(my_atom)
						var/explosion_size = clamp((burn_volatility) / 3 * clamp((combustible_volume ** 0.33) / 6, 0.25, 1.25), 1, 7)
						M.visible_message("<span class='alert'><b>[M]</b> explodes!</span>",self_message = "<span class='combat bold'>You explode!<span class='alert'>", blind_message = "<span class='alert'>You hear a loud bang!<span class='alert'>")
						explosion(my_atom, T, explosion_size / 4, explosion_size / 2, explosion_size - 1,explosion_size + 1)
						fireflash_sm(T, 1 + explosion_size / 2, src.composite_combust_temp, src.composite_combust_temp / (2 * explosion_size + 1), src.composite_combust_energy)
						burn_speed = INFINITY

				else
					if (src.combustible_pressure >= 0.1) // inform people
						if (prob(src.combustible_pressure * 5) && !ON_COOLDOWN(my_atom, "pressure_rattle", (rand(35, 50) - burn_volatility) DECI SECONDS))
							animate_storage_thump(my_atom,ceil(src.combustible_pressure))
						if (!ON_COOLDOWN(my_atom, "internal_fire_1", (ceil((11 - src.combustible_pressure) / 2) SECONDS)))
							particleMaster.SpawnSystem(new /datum/particleSystem/internal_combustion_fire(src.my_atom, src.composite_combust_temp, src.combustible_pressure))

					if (src.combustible_pressure >= 3) // drain pressure
						if (prob(src.combustible_pressure * 5) && !ON_COOLDOWN(my_atom, "pressure_vent", (rand(80, 140) - burn_volatility * 2) DECI SECONDS))
							var/fireflash_size = max(round(src.combustible_pressure) / 3 - 2, 0)
							fireflash_s(get_turf(src.my_atom), fireflash_size, src.composite_combust_temp, src.composite_combust_temp / (2 * fireflash_size + 1), src.composite_combust_energy * burn_speed / src.combustible_volume)
							src.my_atom.visible_message("<span class='alert'>[src.my_atom] vents flames violently!</span>", blind_message = "<span class='alert'>You hear a fiery hiss!</span>", group = "pressure_venting_\ref[src]")
							src.combustible_pressure *= 0.9
							src.trans_to(src.my_atom.loc,src.combustible_volume * src.combustible_pressure / 100)

					if (src.combustible_pressure >= 10) // kaboom
						var/turf/T = get_turf(my_atom)
						var/explosion_size = clamp((burn_volatility) / 3 * clamp((combustible_volume ** 0.33) / 10, 0.25, 1.25), 1, 8)
						src.my_atom.visible_message("<span class='alert'>[src.my_atom] explodes!</span>",blind_message = "<span class='alert'>You hear a loud bang!<span class='alert'>")
						explosion(my_atom, T, explosion_size / 4, explosion_size / 2, explosion_size - 1,explosion_size + 1)
						fireflash_sm(T, 1 + explosion_size / 2, src.composite_combust_temp, src.composite_combust_temp / (2 * explosion_size + 1), energy = src.composite_combust_energy * burn_speed / src.combustible_volume)
						if (isobj(my_atom))
							var/obj/O = my_atom
							O.shatter_chemically(projectiles = TRUE)
							burn_speed = INFINITY

				for (var/reagent_id in src.reagent_list)
					var/datum/reagent/reagent = src.reagent_list[reagent_id]
					if (reagent.flammable_influence)
						var/amount_to_remove = (burn_speed * mult) / 2 * (reagent.volume / src.combustible_volume)
						reagent.do_burn(min(amount_to_remove,reagent.volume))
						src.remove_reagent(reagent_id, amount_to_remove)
						if(src.has_reagent(reagent_id))
							continue_burn = TRUE

				if(!continue_burn)
					src.stop_combusting()
				return

		proc/update_total()
			total_volume = 0
			combustible_volume = 0
			composite_combust_speed = 0
			composite_combust_energy = 0
			composite_combust_temp = 0
			composite_volatility = 0

			for(var/current_id in reagent_list)
				var/datum/reagent/current_reagent = reagent_list[current_id]
				if(current_reagent)
					if(current_reagent.volume <= 0.001)
						del_reagent(current_id)
					else
						current_reagent.volume = max(round(current_reagent.volume, 0.001), 0.001)
						composite_heat_capacity = total_volume/(total_volume+current_reagent.volume)*composite_heat_capacity + current_reagent.volume/(total_volume+current_reagent.volume)*current_reagent.heat_capacity
						total_volume += current_reagent.volume
						if (current_reagent.flammable_influence)
							combustible_volume += current_reagent.volume
							composite_combust_speed += current_reagent.burn_speed * current_reagent.volume
							composite_combust_energy += current_reagent.burn_energy * current_reagent.volume
							composite_combust_temp += current_reagent.burn_temperature * current_reagent.volume
							composite_volatility += current_reagent.burn_volatility * current_reagent.volume

			if(combustible_volume)
				composite_combust_speed = composite_combust_speed / combustible_volume
				composite_combust_temp = composite_combust_temp / combustible_volume
				composite_volatility = composite_volatility / total_volume

			if(isitem(my_atom))
				var/obj/item/I = my_atom
				I.tooltip_rebuild = 1
			return 0

		proc/clear_reagents()
			for(var/current_id in reagent_list)
				del_reagent(current_id)

			return 0

		proc/grenade_effects(var/obj/grenade, var/atom/A)
			for (var/id in src.reagent_list)
				var/datum/reagent/R = src.reagent_list[id]
				R.grenade_effects(grenade, A)
																				//	paramslist thingy can override the can_burn oh god im sorry		paramslist only used for mobs for now, feeel free to paste in for turfs objs
		proc/reaction(var/atom/A, var/method=TOUCH, var/react_volume, var/can_spawn_fluid = 1, var/minimum_react = 0.01, var/can_burn = 1, var/list/paramslist = 0)
			if (src.total_volume <= 0)
				return
			if (isobserver(A)) // errrr
				return

			.= list() //return a list of reagent_ids whose reactions were successful (e.g. had a custom effect. Used to decide if we should consume a fluid)

			if (!react_volume)
				react_volume = src.total_volume
			var/volume_fraction = react_volume / src.total_volume

			if (ismob(A))
				var/mob/M = A
				M.on_reagent_react(src, method, react_volume)

			var/turf/floor/fluid_turf
			var/datum/reagents/temp_fluid_reagents
			if (issimulatedturf(A))
				fluid_turf = A
				temp_fluid_reagents = new /datum/reagents(react_volume)
				//F.reagents.copy_to(temp_fluid_reagents)
				//if(current_reagent)
				//	target.add_reagent(reagent=reagent_id, amount=max(current_reagent.volume * multiplier, 1),donotreact=do_not_react)


			switch(method)
				if(TOUCH)
					var/mob/living/carbon/human/H = A
					if(istype(H) && can_burn)
						var/temp_to_burn_with = total_temperature
						var/dmg_multiplier = 1
						if (length(paramslist))
							if ("override_can_burn" in paramslist)
								temp_to_burn_with = paramslist["override_can_burn"]
							if ("dmg_multiplier" in paramslist)
								dmg_multiplier = paramslist["dmg_multiplier"]

						if(temp_to_burn_with > H.base_body_temp + (H.temp_tolerance * 4) && !H.is_heat_resistant())
							if (chem_helmet_check(H, "hot"))
								boutput(H, "<span class='alert'>You are scalded by the hot chemicals!</span>")
								H.TakeDamage("head", 0, 7 * dmg_multiplier, 0, DAMAGE_BURN) // lol this caused brute damage
								H.emote("scream")
								H.bodytemperature += clamp((temp_to_burn_with - (H.base_body_temp + (H.temp_tolerance * 4))) - 20, 5, 500)
						else if(temp_to_burn_with < H.base_body_temp - (H.temp_tolerance * 4) && !H.is_cold_resistant())
							if (chem_helmet_check(H, "cold"))
								boutput(H, "<span class='alert'>You are frostbitten by the freezing cold chemicals!</span>")
								H.TakeDamage("head", 0, 7 * dmg_multiplier, 0, DAMAGE_BURN)
								H.emote("scream")
								H.bodytemperature -= clamp((H.base_body_temp - (H.temp_tolerance * 4)) - temp_to_burn_with - 20, 5, 500)

					for(var/current_id in reagent_list)
						var/datum/reagent/current_reagent = reagent_list[current_id]
						var/turf_reaction_success = 0
						// drsingh attempted fix for Cannot read null.volume, but this one makes no sense. should have been protected already
						//mbc : I put in a check to stop extremely distilled things in fluids from reacting
						if(current_reagent != null && current_reagent.volume > minimum_react) // Don't put spawn(0) in the below three lines it breaks foam! - IM
							if(ismob(A) && !isobserver(A))
								if (!current_reagent.reaction_mob(A, TOUCH, current_reagent.volume*volume_fraction, paramslist))
									.+= current_id
							if(isturf(A))
								if (!current_reagent.reaction_turf(A, current_reagent.volume*volume_fraction))
									turf_reaction_success = 1
									.+= current_id
							if(isobj(A))
								// use current_reagent.reaction_obj for stuff that affects all objects
								// and reagent_act for stuff that affects specific objects
								if (!current_reagent.reaction_obj(A, current_reagent.volume*volume_fraction))
									.+= current_id
								if(A)
									// we want to make sure its still there after the initial reaction
									A.reagent_act(current_reagent.id,current_reagent.volume*volume_fraction)
								if (istype(A, /obj/blob))
									if (!current_reagent.reaction_blob(A, current_reagent.volume*volume_fraction))
										.+= current_id
							if (!turf_reaction_success && temp_fluid_reagents)
								temp_fluid_reagents.add_reagent(current_id, current_reagent.volume*volume_fraction, current_reagent.data, src.total_temperature, 1)
							//if (can_spawn_fluid && !turf_reaction_success && fluid_turf && current_reagent)
							//	fluid_turf.fluid_react_single(current_id, current_reagent.volume*volume_fraction) // todo optimize (too many fluid react singles, you can batch it)
				if(INGEST)

					if(ismob(A) && !isobserver(A) && can_burn)
						if(iscarbon(A))
							var/mob/living/carbon/C = A
							var/temp_to_burn_with = total_temperature
							var/dmg_multiplier = 1
							if (length(paramslist))
								if ("override_can_burn" in paramslist)
									temp_to_burn_with = paramslist["override_can_burn"]
								if ("dmg_multiplier" in paramslist)
									dmg_multiplier = paramslist["dmg_multiplier"]

							if(C.bioHolder)
								if(temp_to_burn_with > C.base_body_temp + (C.temp_tolerance * 4) && !C.is_heat_resistant())
									boutput(C, "<span class='alert'>You scald yourself trying to consume the boiling hot substance!</span>")
									C.TakeDamage("chest", 0, 7 * dmg_multiplier, 0, DAMAGE_BURN)
									C.bodytemperature += clamp((temp_to_burn_with - T0C) - 20, 5, 700)
								else if(temp_to_burn_with < C.base_body_temp - (C.temp_tolerance * 4) && !C.is_cold_resistant())
									boutput(C, "<span class='alert'>You frostburn yourself trying to consume the freezing cold substance!</span>")
									C.TakeDamage("chest", 0, 7 * dmg_multiplier, 0, DAMAGE_BURN)
									C.bodytemperature -= clamp((temp_to_burn_with - T0C) - 20, 5, 700)


					// These spawn calls were breaking stuff elsewhere. Since they didn't appear to be necessary and
					// I didn't come across problems in local testing, I've commented them out as an experiment. If you've come
					// here while investigating INGEST-related bugs, feel free to revert my change (Convair880).
					for(var/current_id in reagent_list)
						var/datum/reagent/current_reagent = reagent_list[current_id]
						var/turf_reaction_success = 0
						if(current_reagent && current_reagent.volume > minimum_react)
							if(ismob(A) && !isobserver(A))
								//SPAWN_DBG(0)
									//if (current_reagent) //This is in a spawn. Between our first check and the execution, this may be bad.
								if (!current_reagent.reaction_mob(A, INGEST, current_reagent.volume*volume_fraction))
									.+= current_id
							if(isturf(A))
								//SPAWN_DBG(0)
									//if (current_reagent)
								if (!current_reagent.reaction_turf(A, current_reagent.volume*volume_fraction))
									turf_reaction_success = 1
									.+= current_id
							if(isobj(A))
								//SPAWN_DBG(0)
									//if (current_reagent)
								if (!current_reagent.reaction_obj(A, current_reagent.volume*volume_fraction))
									.+= current_id
							if (!turf_reaction_success && temp_fluid_reagents)
								temp_fluid_reagents.add_reagent(current_id, current_reagent.volume*volume_fraction, current_reagent.data, src.total_temperature, 1)
							//if (can_spawn_fluid && !turf_reaction_success && fluid_turf)
							//	fluid_turf.fluid_react_single(current_id, current_reagent.volume*volume_fraction)

			if (can_spawn_fluid && fluid_turf && temp_fluid_reagents)
				temp_fluid_reagents.update_total()
				fluid_turf.fluid_react(temp_fluid_reagents, temp_fluid_reagents.total_volume)

		proc/add_reagent(var/reagent, var/amount, var/sdata, var/temp_new=T20C, var/donotreact = 0, var/donotupdate = 0)
			if(!isnum(amount) || amount <= 0 || src.disposed)
				return 1
			var/added_new = 0
			if (!donotupdate)
				update_total()
			amount = round(amount, CHEM_EPSILON)
			if(amount < CHEM_EPSILON)
				return 0
			if(total_volume + amount > maximum_volume)
				amount = (maximum_volume - total_volume) //Doesnt fit in. Make it disappear. Shouldnt happen. Will happen.

			var/datum/reagent/current_reagent = reagent_list[reagent]

			if(!current_reagent)
				if (reagents_cache.len <= 0)
					build_reagent_cache()

				current_reagent = reagents_cache[reagent]

				if(current_reagent)
					current_reagent = new current_reagent.type()
					reagent_list[reagent] = current_reagent
					current_reagent.holder = src
					current_reagent.volume = 0
					current_reagent.data = sdata
					added_new = 1
				else
					return 0
			// Else, if the reagent datum already exists, we'll just be adding to that and won't update with our new reagent datum data

			var/new_amount = (current_reagent.volume + amount)
			current_reagent.volume = new_amount
			if(!current_reagent.data) current_reagent.data = sdata


			src.last_temp = src.total_temperature
			var/temp_temperature = src.total_temperature*src.total_volume*src.composite_heat_capacity + temp_new*new_amount*current_reagent.heat_capacity

			var/divison_amount = src.total_volume * src.composite_heat_capacity + new_amount * current_reagent.heat_capacity
			if (divison_amount > 0)
				src.total_temperature = temp_temperature / divison_amount

			if (!donotupdate)
				update_total()

			if (!donotupdate)
				reagents_changed(1)

			if(added_new && !current_reagent.pooled)
				append_possible_reactions(current_reagent.id) //Experimental reaction possibilities
				current_reagent.on_add()
				if (!donotreact)
					src.handle_reactions()

			if(!donotreact)
				temperature_react()

			return 1

		proc/remove_reagent(var/reagent, var/amount, var/update_total = 1, var/reagents_change = 1)

			if(!isnum(amount)) return 1

			var/datum/reagent/current_reagent = reagent_list[reagent]

			if(current_reagent)
				current_reagent.volume -= amount
				if(current_reagent.volume <= 0 && (reagents_change || update_total))
					del_reagent(reagent)

				if (update_total)
					update_total()
				if (reagents_change)
					reagents_changed()

			return 1

		proc/has_reagent(var/reagent, var/amount=0)
			// I removed a check if reagent_list existed here in the interest of performance
			// if this happens again try to figure out why the fuck reagent_list would go null
			var/datum/reagent/current_reagent = reagent_list[reagent]
			return current_reagent && current_reagent.volume >= amount

		proc/has_active_reaction(var/reaction_id, var/amount=0)
			for(var/datum/chemical_reaction/C in src.active_reactions)
				if(C.id == reaction_id)
					return C && C.result_amount >= amount
			return FALSE

		proc/get_reagent(var/reagent_id)
			return reagent_list[reagent_id]

		proc/get_reagent_amount(var/reagent)
			var/datum/reagent/current_reagent = reagent_list[reagent]

			return current_reagent ? current_reagent.volume : 0

		proc/get_dispersal()
			if (!total_volume)
				return 0
			var/dispersal = 9999
			for (var/id in reagent_list)
				var/datum/reagent/R = reagent_list[id]
				if (R.dispersal < dispersal)
					dispersal = R.dispersal
			return dispersal

		proc/get_smoke_spread_mod()
			if (!total_volume)
				return 0
			var/smoke_spread_mod = 9999
			for (var/id in reagent_list)
				var/datum/reagent/R = reagent_list[id]
				if (R.smoke_spread_mod < smoke_spread_mod)
					smoke_spread_mod = R.smoke_spread_mod
			return smoke_spread_mod


		// redirect my_atom.on_reagent_change() through this function
		proc/reagents_changed(var/add = 0) // add will be 1 if reagents were just added
			if (my_atom)
				my_atom.on_reagent_change(add)
			return

		proc/is_full() // li'l tiny helper thing vOv
			if (src.total_volume >= src.maximum_volume)
				return 1
			else
				return 0

		/////////////////////////
		// procs for description and color of this collection of reagents


		// returns text description of reagent(s)
		// plus exact text of reagents if using correct equipment
		proc/get_description(mob/user, rc_flags=0)
			if(rc_flags == 0)	// Report nothing about the reagents in this case
				return null

			if(reagent_list.len)
				. += get_inexact_description(rc_flags)
				if(rc_flags & RC_SPECTRO)
					. += get_exact_description(user)

			else
				. += "<span class='notice'>Nothing in it.</span>"
			return


		proc/get_exact_description(mob/user)

			if(!length(reagent_list))
				return

			// check to see if user wearing the spectoscopic glasses (or similar)
			// if so give exact readout on what reagents are present
			if (HAS_MOB_PROPERTY(user, PROP_SPECTRO))
				if("cloak_juice" in reagent_list)
					var/datum/reagent/cloaker = reagent_list["cloak_juice"]
					if(cloaker.volume >= 5)
						. += "<br><span class='alert'>ERR: SPECTROSCOPIC ANALYSIS OF THIS SUBSTANCE IS NOT POSSIBLE.</span>"
						return


				. += "<br><span class='alert'>Spectroscopic analysis:</span>"

				for(var/current_id in reagent_list)
					var/datum/reagent/current_reagent = reagent_list[current_id]
					. += "<br><span class='alert'>[current_reagent.volume] units of [current_reagent.name]</span>"
			return

		proc/get_reagents_fullness(shorthand = FALSE)
			.= get_fullness((total_volume / maximum_volume * 100), shorthand)

		proc/get_inexact_description(var/rc_flags=0)
			if(rc_flags == 0)
				return null

			var/full_text = get_reagents_fullness()

			if(full_text == "empty")
				if(rc_flags & (RC_SCALE | RC_VISIBLE | RC_FULLNESS) )
					. += "<span class='notice'>It is empty.</span>"
				return

			var/datum/color/c = get_average_color()

			//. += "([c.r],[c.g],[c.b];[c.a])"

			var/nearest_color_text = get_nearest_color(c)

			var/opaque_text = get_opaqueness(c.a)

			var/state_text = get_state_description()

			if(state_text == "solid")	// if only have solids present, don't include opacity text
				opaque_text = null

			if(opaque_text) opaque_text += ", "

			var/t = "[opaque_text][nearest_color_text]"

			if(rc_flags & RC_VISIBLE)
				if(rc_flags & RC_SCALE)
					. += "<span class='notice'>It contains [total_volume] units of \a [t]-colored [state_text].</span>"
				else
					. += "<span class='notice'>It is [full_text] of \a [t]-colored [state_text].</span>"
			else
				if(rc_flags & RC_SCALE)
					. += "<span class='notice'>It contains [total_volume] units.</span>"
				else
					if(rc_flags & RC_FULLNESS)
						. += "<span class='notice'>It is [full_text].</span>"

			return .


		// returns the average color of the reagents
		// taking into account concentration and transparency

		proc/get_average_color()
			RETURN_TYPE(/datum/color)
			var/datum/color/average = new(0,0,0,0)
			var/total_weight = 0

			for(var/id in reagent_list)

				var/datum/reagent/current_reagent = reagent_list[id]

				// weigh contribution of each reagent to the average color by amount present and it's transparency

				var/weight = current_reagent.volume * current_reagent.transparency / 255.0
				total_weight += weight

				average.r += weight * current_reagent.fluid_r
				average.g += weight * current_reagent.fluid_g
				average.b += weight * current_reagent.fluid_b
				average.a += weight * current_reagent.transparency

			// now divide by total weight to get average color
			if(total_weight > 0)
				average.r /= total_weight
				average.g /= total_weight
				average.b /= total_weight
				average.a /= total_weight
			return average

		proc/get_average_rgb()
			var/datum/color/average = get_average_color()
			return rgb(average.r, average.g, average.b)


		//returns whether reagents are solid, liquid, gas, or mixture
		proc/get_state_description()
			var/has_solid = 0
			var/has_liquid = 0
			var/has_gas = 0

			for(var/id in reagent_list)

				var/datum/reagent/current_reagent = reagent_list[id]
				if(current_reagent.is_gas())
					has_gas = 1
				else if(current_reagent.is_liquid())
					has_liquid = 1
				else
					has_solid = 1

			if( (has_liquid+has_solid+has_gas)>1 )
				return "mixture"
			if(has_liquid)
				return "liquid"
			if(has_solid)
				return "solid"
			return "gas"

		proc/physical_shock(var/force)
			for (var/id in reagent_list)
				var/datum/reagent/current_reagent = reagent_list[id]
				current_reagent.physical_shock(force)

		proc/move_trigger(var/mob/M, kindof)
			var/shock = 0
			switch (kindof)
				if ("sprint")
					shock = rand(8, 16)
				if ("run")
					shock = rand(5, 12)
				if ("walk", "swap")
					if (prob(5))
						shock = 1
				if ("bump")
					shock = rand(3, 8)
				if ("pushdown")
					shock = rand(8, 16)
			if (shock)
				physical_shock(shock)

		//there were two different implementations, one of which didn't work, so i moved the working one here and both call it now - IM
		proc/smoke_start(var/volume, var/classic = 0)
			del_reagent("thalmerite")
			del_reagent("big_bang") //remove later if we can get a better fix
			del_reagent("big_bang_precursor")
			del_reagent("poor_concrete")
			del_reagent("okay_concrete")
			del_reagent("good_concrete")
			del_reagent("perfect_concrete")

			var/list/covered = covered_turf()

			var/turf/T = covered.len ? covered[1] : 0
			var/mob/our_user = null
			var/our_fingerprints = null

			// Sadly, we don't automatically get a mob reference under most circumstances.
			// If there's an existing lookup proc and/or better solution, I haven't found it yet.
			// If everything else fails, maybe there are fingerprints on the container for us to check though?
			if (my_atom)
				if (ismob(my_atom)) // Our mob, the container.
					our_user = my_atom
				else if (my_atom && (ismob(my_atom.loc))) // Backpacks etc.
					our_user = my_atom.loc
				else
					our_user = usr
					if (my_atom.fingerprintslast) // Our container. You don't necessarily have to pick it up to transfer stuff.
						our_fingerprints = my_atom.fingerprintslast
					else if (my_atom.loc.fingerprintslast) // Backpacks etc.
						our_fingerprints = my_atom.loc.fingerprintslast

			//DEBUG_MESSAGE("Heat-triggered smoke powder reaction: our user is [our_user ? "[our_user]" : "*null*"].[our_fingerprints ? " Fingerprints: [our_fingerprints]" : ""]")
			if (our_user && ismob(our_user))
				logTheThing("combat", our_user, null, "Smoke reaction ([my_atom ? log_reagents(my_atom) : log_reagents(src)]) at [T ? "[log_loc(T)]" : "null"].")
			else
				logTheThing("combat", our_user, null, "Smoke reaction ([my_atom ? log_reagents(my_atom) : log_reagents(src)]) at [T ? "[log_loc(T)]" : "null"].[our_fingerprints ? " Container last touched by: [our_fingerprints]." : ""]")

			if (classic)
				classic_smoke_reaction(src, min(round(volume / 5), 4), location = my_atom ? get_turf(my_atom) : 0)
			else
				smoke_reaction(src, round(min(5, round(volume/10))), location = my_atom ? get_turf(my_atom) : 0)

// currently a stub, any behavior for reagents on the surface of something goes here
/datum/reagents/surface

///////////////////////////////////////////////////////////////////////////////////


// Convenience proc to create a reagents holder for an atom
// Max vol is maximum volume of holder
atom/proc/create_reagents(var/max_vol)
	reagents = new/datum/reagents(max_vol)
	reagents.my_atom = src
