var/datum/score_tracker/score_tracker

/datum/score_tracker
	// Nice to have somewhere to centralize this shit so w/e
	//Overall
	var/score_calculated = 0
	var/final_score_all = 0
	var/grade = "The Aristocrats!"
	//Antagonists
	var/score_enemy_failure_rate = 0 //replace with success rate
	//var/score_enemy_success_rate = 0

	//nuke
	//var/operatives_killed = 0
	//var/auth_disk_location = 0

	//wizard
	/*
	var/spells_cast = 0
	var/total_corrupted_terrain = 0
	var/total_corruptible_terrain = 0
	*/

	//Station condition
	var/score_cleanliness = 0 //janitor
	//var/outpost_destroyed = 0 //if we have a zeta-like,
	//Safety
	var/score_crew_evacuation_rate = 0 //save this for later to keep categories balanced
	var/score_crew_survival_rate = 0
	//Security
	//var/tickets_written = 0
	var/final_score_sec = 0
	var/tickets_text = null
	//Financial
	var/score_expenses = 0
	//Power
	var/score_power_outages = 0
	var/score_structural_damage = 0
	var/final_score_eng = 0
	//Health
	var/cloner_broken_timestamp = 0 //ticks since roundstart until one of the 4 roundstart cloner parts is destroyed

	//Food
	//var/food_prepared = 0 //how productive is the chef
	//var/food_eaten = 0 //how hungry is the crew
	//var/food_eaten_ratio = 0 //how sad is the chef
	//var/food_lost = 0 //barf

	//Science
	//var/chemical_reactions = 0 //ONLY counted in chemistry's area
	//var/teleports = 0
	//var/bombs_tested = 0 //counts for VR but also counts for bombs set off on station. test successful!
	var/artifacts_analyzed = 0 //maybe....
	var/artifacts_correctly_analyzed = 0
	var/score_artifact_analysis = 0
	var/final_score_res = 0

	//Mining
	//var/ores_mined = 0
	//var/gems_mined = 0
	//var/mining_explosions = 0 //'what exploded' 'oh it's just mining'

	//Administrative
	//var/payroll_met = 0
	//var/paychecks_given = 0
	//var/ids_changed = 0 //hop
	var/final_score_civ = 0 //might not have department scores

	// Engineering
	var/engine_power_hiscore = 0
	var/engine_power_type = ""

	//Misc
	//var/clown_beatings = null
	//var/farts_busted = 0
	//var/shots_fired = 0
	//var/total_karma = 0 //pascal's over/under
	//var/total_orgone = 0 //orgone accumulated
	//var/average_drunkenness = 0

	//individual achievements
	var/mob/richest_escapee = null
	var/richest_total = 0
	var/mob/most_damaged_escapee = null
	var/damage_total = 0
	var/most_xp = "OH NO THIS IS BROKEN"
	var/score_text = null

	//chumps survived
	var/beepsky_alive = null
	//var/ai_alive = null

	//who cares
	//var/acula_blood = null
	//var/list/pets_escaped = null
	//var/list/command_pets_escaped = null

/* -------------------------------------------------------------------------- */
/*                                Station Score                               */
/* -------------------------------------------------------------------------- */

	proc/calculate_score()
		if (score_calculated != 0)
			return
		// Even if its the end of the round it'd probably be nice to just calculate this once and let players grab that
		// instead of calculating it again every time a player wants to look at the score

		// SECURITY DEPARTMENT SECTION
		var/crew_count = 0
		var/fatalities = 0
		var/traitor_objectives = 0
		var/traitor_objectives_failed = 0

		for (var/datum/mind/M in ticker.minds)
			if (M.current && istype(M.current,/mob/dead/observer/))
				var/mob/dead/observer/O = M.current
				if (O.observe_round)
					continue
			if (M in ticker.mode.traitors) // if you're an antag, you're not considered crew
				continue

			crew_count++ // good job you're one of the crew, get counted upon

			if (!M.current || (M.current && isdead(M.current))) // DEAD
				fatalities++

		for (var/datum/mind/traitor in ticker.mode.traitors)
			for (var/datum/objective/objective in traitor.objectives)
				traitor_objectives++
#ifdef CREW_OBJECTIVES
				if (istype(objective, /datum/objective/crew)) continue
#endif
				if (istype(objective, /datum/objective/miscreant)) continue
				if (objective.check_completion() == FAILED)
					traitor_objectives_failed++

		// special case - if there were no antags for w/e reason you get a free pass i guess?
		if (traitor_objectives == 0)
			score_enemy_failure_rate = 100
		else
			score_enemy_failure_rate = get_percentage_of_fraction_and_whole(traitor_objectives_failed,traitor_objectives)

		score_crew_survival_rate = get_percentage_of_fraction_and_whole(fatalities,crew_count)

		score_crew_survival_rate = clamp(score_crew_survival_rate,0,100)
		score_enemy_failure_rate = clamp(score_enemy_failure_rate,0,100)

		final_score_sec = (score_crew_survival_rate + score_enemy_failure_rate) * 0.5

		// ENGINEERING DEPARTMENT SECTION
		// also civ cleanliness counted here cos fuck calling a world loop more than once
		var/apc_count = 0
		var/apcs_powered = 0
		var/num_station_areas = 0
		var/undamaged_areas = 0
		var/clean_areas = 0

		//checking power levels
		for (var/obj/machinery/power/apc/A in machine_registry[MACHINES_POWER])
			if (!istype(A.area,/area/station/))
				continue
			apc_count++
			for (var/obj/item/cell/C in A.contents)
				if (get_percentage_of_fraction_and_whole(C.charge,C.maxcharge) >= 85)
					apcs_powered++
			//LAGCHECK(LAG_LOW)

		//checking mess
		for(var/area/station/AR in world)
			var/cleanliness = AR.calculate_area_cleanliness()
			if(cleanliness == -1) // no sim. turfs
				continue
			num_station_areas++
			if (get_percentage_of_fraction_and_whole(AR.calculate_structure_value(),AR.initial_structure_value) >= 50)
				undamaged_areas++
			if (cleanliness >= 80)
				clean_areas++
			//LAGCHECK(LAG_LOW)

		score_power_outages = get_percentage_of_fraction_and_whole(apcs_powered,apc_count)

		if (istype(ticker?.mode, /datum/game_mode/nuclear)) //Since the nuke doesn't actually blow up in time
			var/datum/game_mode/nuclear/N = ticker.mode
			if (N.nuke_detonated)
				score_structural_damage = 0
			else
				score_structural_damage = get_percentage_of_fraction_and_whole(undamaged_areas,num_station_areas)
		else
			score_structural_damage = get_percentage_of_fraction_and_whole(undamaged_areas,num_station_areas)

		score_power_outages = clamp(score_power_outages,0,100)
		score_structural_damage = clamp(score_structural_damage,0,100)

		final_score_eng = (score_power_outages + score_structural_damage) * 0.5

		// RESEARCH DEPARTMENT SECTION
		for(var/obj/O in artifact_controls.artifacts)
			if(O.disposed)
				continue
			var/obj/item/sticker/postit/artifact_paper/pap = locate(/obj/item/sticker/postit/artifact_paper/) in O.vis_contents
			if(pap)
				artifacts_analyzed++
			if(pap?.lastAnalysis >= 3)
				artifacts_correctly_analyzed++
		if(artifacts_analyzed)
			score_artifact_analysis = (artifacts_correctly_analyzed/artifacts_analyzed)*100

		final_score_res = score_artifact_analysis

		// CIVILIAN DEPARTMENT SECTION
		if (!istype(wagesystem))
			// something glitched out and broke so give them a free pass on it
			score_expenses = 100
		else
			var/profit_target = 300000
			var/totalfunds = wagesystem.station_budget + wagesystem.research_budget + wagesystem.shipping_budget
			if (totalfunds == 0)
				score_expenses = 0
			if (totalfunds != totalfunds) //let's see if someone sets the budget to -NaN!
				score_expenses = 100
			else
				score_expenses = get_percentage_of_fraction_and_whole(totalfunds,profit_target)

		score_cleanliness = get_percentage_of_fraction_and_whole(clean_areas,num_station_areas)

		score_expenses = clamp(score_expenses,0,100)
		score_cleanliness = clamp(score_cleanliness,0,100)
		final_score_civ = (score_expenses + score_cleanliness) * 0.5

		var/xp_winner = null
		var/curr_xp = 0
		for(var/x in xp_earned)
			if(xp_earned[x] > curr_xp)
				curr_xp = xp_earned[x]
				xp_winner = x

		if(xp_winner)
			most_xp = "[xp_winner]!"
		else
			most_xp = "No one. Dang."

		calculate_escape_stats()

		// AND THE WINNER IS.....

		var/department_score_sum = 0
		department_score_sum = final_score_sec + final_score_eng + final_score_civ + final_score_res

		if (department_score_sum == 0 || department_score_sum != department_score_sum) //check for 0 and for NaN values
			final_score_all = 0
		else
			final_score_all = round(department_score_sum / 4)

		switch(final_score_all)
			if (100 to INFINITY) grade = "NanoTrasen's Finest"
			if (90 to 99) grade = "The Pride of Science Itself"
			if (91 to 95) grade = "Ambassadors of Discovery"
			if (86 to 90) grade = "Missionaries of Science"
			if (81 to 85) grade = "Promotions for Everyone"
			if (76 to 80) grade = "An Excellent Pursuit of Progress"
			if (71 to 75) grade = "Lean Mean Machine Thirteen"
			if (66 to 70) grade = "Best of a Good Bunch"
			if (61 to 65) grade = "Worthy Citizens"
			if (56 to 60) grade = "Ambiguously Ambivalent"
			if (51 to 55) grade = "Not Bad, but Not Good"
			if (46 to 50) grade = "Ambivalently Average"
			if (41 to 45) grade = "Not Worthy of Praise"
			if (36 to 40) grade = "Extremely Unsatisfactory"
			if (31 to 35) grade = "A Bad Bunch"
			if (26 to 30) grade = "The Undesireables"
			if (21 to 25) grade = "Outclassed by Lab Monkeys"
			if (16 to 20) grade = "A Wretched Heap of Scum and Incompetence"
			if (11 to 15) grade = "A Waste of Perfectly Good Oxygen"
			if (06 to 10) grade = "You're All Fired"
			if (01 to 05) grade = "Engine Fodder"
			if (-INFINITY to 0) grade = "Even the Engine Deserves Better"
			else grade = "Somebody fucked something up."

		score_calculated = 1
		boutput(world, "<b>Final Rating: <font size='4'>[final_score_all]%</font></b>")
		boutput(world, "<b>Grade: <font size='4'>[grade]</font></b>")

#ifndef  MAP_OVERRIDE_POD_WARS
		for (var/client/C)
			var/mob/M = C.mob
			if (M && C.preferences.view_score)
				M.scorestats()
#endif
		return

/* -------------------------------------------------------------------------- */
/*                                Escapee Stuff                               */
/* -------------------------------------------------------------------------- */

	proc/calculate_escape_stats()
		//set the global total to zero on proc start, just in cases.
		richest_total = 0
		damage_total = null
		var/current_damage //from -whatever to 100%
		//search mobs in centcom
		for (var/mob/M in mobs)
			if(in_centcom_shuttle(M)) //only shuttle escapees
				//see who's most hurt
				if (!most_damaged_escapee) //if we don't have someone, look for anyone with damage

					current_damage = ( M.health / M.max_health) * 100
					if (current_damage) //any damage at all?
						most_damaged_escapee = M
						damage_total = current_damage
				else //compare damages
					current_damage = ( M.health / M.max_health) * 100
					if (current_damage < damage_total)
						damage_total = current_damage
						most_damaged_escapee = M
				//see who's most stacked
				var/cash_total = get_cash_in_thing(M)
				if (richest_total < cash_total)
					richest_total = cash_total
					richest_escapee = M
		/*
		command_pets_escaped = list()
		pets_escaped = list()

		for (var/pet in by_cat[TR_CAT_PETS])
			if(iscritter(pet))
				var/obj/critter/P = pet
				if (in_centcom(P) && P.alive)
					if(P.is_pet == 2)
						command_pets_escaped += P
					else if(P.is_pet)
						pets_escaped += P
					if (istype(P, /obj/critter/bat/doctor))
						acula_blood = P:blood_volume //this only gets populated if Dr. Acula escapes
			else if(ismobcritter(pet))
				var/mob/living/critter/P = pet
				if (in_centcom(pet) && isalive(P))
					if(pet:is_pet == 2)
						command_pets_escaped += pet
					else if(pet:is_pet)
						pets_escaped += pet
			else if(istype(pet, /obj/item/rocko))
				if(in_centcom(pet))
					command_pets_escaped += pet
		*/

		if (length(by_type[/obj/machinery/bot/secbot/beepsky]))
			beepsky_alive = 1

		return

	proc/get_cash_in_thing(var/atom/A)
		. = 0
		for (var/I in A)
			if (istype(I, /obj/item/storage))
				. += get_cash_in_thing(I)
			if (istype(I, /obj/item/spacecash))
				var/obj/item/spacecash/SC = I
				. += SC.amount
			if (istype(I, /obj/item/card/id))
				var/obj/item/card/id/ID = I
				. += ID.amount

	//stop with the bee hats
	/*
	proc/heisenhat_stats()
		. = list()
		. += "<B>Heisenbee's hat:</B> "
		var/found_hb = 0
		var/tier = world.load_intra_round_value("heisenbee_tier")
		for(var/obj/critter/domestic_bee/heisenbee/HB in by_cat[TR_CAT_PETS])
			var/obj/item/hat = HB.original_hat
			if(hat && !hat.disposed)
				if(hat.loc != HB)
					var/atom/movable/L = hat.loc
					while(istype(L) && !istype(L, /mob))
						L = L.loc
					. += "[hat][inline_bicon(getFlatIcon(hat, no_anim=TRUE))](tier [HB.original_tier])"
					if(istype(L, /mob))
						. += " \[STOLEN BY [L]\]"
					else
						. += " \[STOLEN!\]"
					if(HB.hat)
						var/dead = HB.alive ? "" : "(dead) "
						. += "<BR>Also someone put [HB.hat] on [dead][HB][inline_bicon(getFlatIcon(HB, no_anim=TRUE))]but that doesn't count."
				else if(!HB.alive)
					. += "[hat][inline_bicon(getFlatIcon(HB, no_anim=TRUE))](tier [HB.original_tier])"
					. += " \[🐝 MURDERED!\]"
				else
					. += "[hat][inline_bicon(getFlatIcon(HB, no_anim=TRUE))](tier [HB.original_tier])"
			else if(HB.alive)
				if(hat)
					. += "[inline_bicon(getFlatIcon(hat, no_anim=TRUE))] \[DESTROYED!\]"
				else
					. += "No hat yet."
			else if(hat)
				. += "[inline_bicon(getFlatIcon(hat, no_anim=TRUE))] \[DESTROYED!\] \[🐝 MURDERED!\]"
			else
				. += "No hat yet. \[🐝 MURDERED!\]"
			found_hb = 1
			break
		if(!found_hb)
			if(tier)
				. += "Heisenbee is missing but the hat is safe at tier [tier]."
			else
				. += "Heisenbee is missing and has no hat."
		. += "<BR>"
		return jointext(., "")

	*/

	proc/escapee_facts()
		. = list()
		//Richest Escapee | Most Damaged Escapee | Dr. Acula Blood Total | Clown Beatings
		if (richest_escapee)
			if (richest_escapee.real_name == "cockroach")
				. += "<B>Richest Escapee:</B> A cockroach???? : what the fuck<BR>"
			else
				. += "<B>Richest Escapee:</B> [richest_escapee.real_name] : $[richest_total]<BR>"
		else
			. += "<B>Richest Escapee:</B> Nobody!<BR>"
		if (most_damaged_escapee)
			. += "<B>Most Damaged Escapee:</B> [most_damaged_escapee.real_name] : [damage_total]%<BR>"
		else
			. += "<B>Most Damaged Escapee:</B> Nobody!<BR>"

		//whocare about pets
		/*
		if (length(command_pets_escaped))
			var/list/who_escaped = list()
			for (var/atom/A in command_pets_escaped)
				who_escaped += "[A.name] [inline_bicon(getFlatIcon(A, no_anim=TRUE))]"
			. += "<B>Command Pets Escaped:</B> [who_escaped.Join(" ")]<BR><BR>"
		if (length(pets_escaped))
			var/list/who_escaped = list()
			for (var/atom/A in pets_escaped)
				who_escaped += "[A.name] [bicon(A)]"
			. += "<B>Other Pets Escaped:</B> [who_escaped.Join(" ")]<BR><BR>"
		*/

		//if (acula_blood) 			. += "<B>Dr. Acula Blood Total:</B> [acula_blood]p<BR>"
		. += "<B>Officer Beepsky:</B> [beepsky_alive ? "Survived" : "Ate Shit"] This Round<BR>"
		//. += "<B>Ores Mined:</B> dunno yet but soon ok<BR>"
		//. += "<B>Things Sold:</B> dunno yet but soon ok<BR>"
		//. += "<B>Food Produced:</B> dunno yet but soon ok<BR>"
		//. += "<B>Food Eaten:</B> dunno yet but soon ok<BR>"
		. += "<B>Farts Blasted:</B> [fartcount]<BR>"
		. += "<B>Weades Growne:</B> [weadegrowne]<BR>"
		. += "<B>Doinks Sparked:</B> [doinkssparked]<BR>"
		. += "<B>Time To Cloner Destruction:</B> [score_tracker.cloner_broken_timestamp ? "[score_tracker.cloner_broken_timestamp] ticks" : "Never even happened."]<BR>"
#ifdef DATALOGGER
		. += "<B>Shots Fired:</B> [game_stats.GetStat("gunfire")]<BR>"
		. += "<B>Health and Safety violations:</B> [game_stats.GetStat("workplacesafety")]<BR>"
		. += "<B>Number of times a clown was abused:</B> [game_stats.GetStat("clownabuse")]<BR>"
		. += "<B><I><span style='color:green;'>im gay :)</B></I> [game_stats.GetStat("gayirl")]</span><BR>"
#endif
		. += "<BR><B>COOL FACT:</B> all the [pick("space bees","ferrets","clowns","juicers","robots","fish","cats","rocks","paisanos")] are gay<BR>"
		return jointext(., "")


/mob/proc/scorestats()
	if (score_tracker.score_calculated == 0)
		return

	if (!score_tracker.score_text)
		score_tracker.score_text = {"<B>Round Statistics and Score</B><BR><HR>"}
		score_tracker.score_text += "<B><U>TOTAL SCORE: [round(score_tracker.final_score_all)]%</U></B>"
		if(round(score_tracker.final_score_all) == 69)
			score_tracker.score_text += " <b>nice</b>"
		score_tracker.score_text += "<BR>"
		score_tracker.score_text += "<B><U>GRADE: [score_tracker.grade]</U></B><BR>"
		score_tracker.score_text += "<BR>"

		score_tracker.score_text += "<B><U>SECURITY DEPARTMENT</U></B><BR>"
		score_tracker.score_text += "<B>Crew Member Survival Rate:</B> [round(score_tracker.score_crew_survival_rate)]%<BR>"
		score_tracker.score_text += "<B>Enemy Objective Failure Rate:</B> [round(score_tracker.score_enemy_failure_rate)]%<BR>"
		score_tracker.score_text += "<B>Total Department Score:</B> [round(score_tracker.final_score_sec)]%<BR>"
		score_tracker.score_text += "<BR>"

		var/power_hi = score_tracker.engine_power_hiscore
		var/prettified_power_hiscore
		var/prettified_power_postfix = ""
		switch(round(power_hi))
			if(0 to 999)
				prettified_power_hiscore = round(power_hi, 1.5)
			if(1 KILO to 999 KILO)
				prettified_power_hiscore = round((power_hi / 1 KILO), 1.5)
				prettified_power_postfix = "Kilo"
			if(1 MEGA to 999 MEGA)
				prettified_power_hiscore = round((power_hi / 1 MEGA), 1.5)
				prettified_power_postfix = "Mega"
			if(1 GIGA to 999 GIGA)
				prettified_power_hiscore = round((power_hi / 1 GIGA), 1.5)
				prettified_power_postfix = "Giga"
			if(1 TERA to 999 TERA) /* Not sure how much these levels will be needed, but hey */
				prettified_power_hiscore = round((power_hi / 1 TERA), 1.5)
				prettified_power_postfix = "Tera"
			if(1 PETA to 999 PETA)
				prettified_power_hiscore = round((power_hi / 1 PETA), 1.5)
				prettified_power_postfix = "Peta"
			if(1 EXA to 999 EXA)
				prettified_power_hiscore = round((power_hi / 1 EXA), 1.5)
				prettified_power_postfix = "Exa"
			if(1 ZETTA to 999 ZETTA)
				prettified_power_hiscore = round((power_hi / 1 ZETTA), 1.5)
				prettified_power_postfix = "Zetta"
			if(1 YOTTA to INFINITY)
				prettified_power_hiscore = round((power_hi / 1 YOTTA), 1.5)
				prettified_power_postfix = "Yotta"

		score_tracker.score_text += "<B><U>ENGINEERING DEPARTMENT</U></B><BR>"
		score_tracker.score_text += "<B>Station Structural Integrity:</B> [round(score_tracker.score_structural_damage)]%<BR>"
		score_tracker.score_text += "<B>Station Areas Powered:</B> [round(score_tracker.score_power_outages)]%<BR>"
		score_tracker.score_text += "<B>Highest [score_tracker.engine_power_type]Peak Power:</B> [prettified_power_hiscore] [prettified_power_postfix]Watts<BR>"
		score_tracker.score_text += "<B>Total Department Score:</B> [round(score_tracker.final_score_eng)]%<BR>"
		score_tracker.score_text += "<BR>"

		score_tracker.score_text += "<B><U>RESEARCH DEPARTMENT</U></B><BR>"
		score_tracker.score_text += "<B>Artifacts correctly analyzed:</B> [round(score_tracker.score_artifact_analysis)]% ([score_tracker.artifacts_correctly_analyzed]/[score_tracker.artifacts_analyzed])<BR>"
		score_tracker.score_text += "<B>Total Department Score:</B> [round(score_tracker.final_score_res)]%<BR>"
		score_tracker.score_text += "<BR>"

		score_tracker.score_text += "<B><U>CIVILIAN DEPARTMENT</U></B><BR>"
		score_tracker.score_text += "<B>Overall Station Cleanliness:</B> [round(score_tracker.score_cleanliness)]%<BR>"
		score_tracker.score_text += "<B>Profit Made from Initial Budget:</B> [round(score_tracker.score_expenses)]%<BR>"
		score_tracker.score_text += "<B>Total Department Score:</B> [round(score_tracker.final_score_civ)]%<BR>"
		score_tracker.score_text += "<BR>"
	 /* until this is actually done or being worked on im just going to comment it out
		score_tracker.score_text += "<B>Most Experienced:</B> [score_tracker.most_xp]<BR>"
		*/
		score_tracker.score_text += "<B><U>STATISTICS</U></B><BR>"
		score_tracker.score_text += score_tracker.escapee_facts()
		//score_tracker.score_text += score_tracker.heisenhat_stats()

		score_tracker.score_text += "<HR>"

	src.Browse(score_tracker.score_text, "window=roundscore;size=500x700;title=Round Statistics")

/* -------------------------------------------------------------------------- */
/*                              Security Tickets                              */
/* -------------------------------------------------------------------------- */

//We need to lighten this up

/mob/proc/showtickets()
	if(!data_core.tickets.len && !length(data_core.fines)) return

	if (!score_tracker.tickets_text)
		logTheThing("debug", null, null, "Zamujasa/SHOWTICKETS: [world.timeofday] generating showtickets text")

		score_tracker.tickets_text = {"<B>Tickets</B><BR><HR>"}

		if(data_core.tickets.len)
			var/list/people_with_tickets = list()
			for (var/datum/ticket/T in data_core.tickets)
				people_with_tickets |= T.target

			for(var/N in people_with_tickets)
				score_tracker.tickets_text += "<b>[N]</b><br><br>"
				for(var/datum/ticket/T in data_core.tickets)
					if(T.target == N)
						score_tracker.tickets_text += "[T.text]<br>"
			score_tracker.tickets_text += "<br>"
		else
			score_tracker.tickets_text += "No tickets were issued!<br><br>"

		score_tracker.tickets_text += {"<B>Fines</B><BR><HR>"}

		if(data_core.fines.len)
			var/list/people_with_fines = list()
			for (var/datum/fine/F in data_core.fines)
				people_with_fines |= F.target

			for(var/N in people_with_fines)
				score_tracker.tickets_text += "<b>[N]</b><br><br>"
				for(var/datum/fine/F in data_core.fines)
					if(F.target == N)
						score_tracker.tickets_text += "[F.target]: [F.amount] credits<br>Reason: [F.reason]<br>[F.approver ? "[F.issuer != F.approver ? "Requested by: [F.issuer] - [F.issuer_job]<br>Approved by: [F.approver] - [F.approver_job]" : "Issued by: [F.approver] - [F.approver_job]"]" : "Not Approved"]<br>Paid: [F.paid_amount] credits<br><br>"
		else
			score_tracker.tickets_text += "No fines were issued!"
		logTheThing("debug", null, null, "Zamujasa/SHOWTICKETS: [world.timeofday] done")

	src.Browse(score_tracker.tickets_text, "window=tickets;size=500x650")
	return
