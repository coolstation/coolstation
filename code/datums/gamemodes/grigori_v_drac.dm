/datum/game_mode/grigori_v_drac
	name = "Grigori Vs Dracula"
	config_tag = "grigori_v_drac"
	latejoin_antag_compatible = 1
	latejoin_antag_roles = list(ROLE_GRIGORI, ROLE_LESSERVAMP)

	var/list/traitor_types = list(ROLE_GRIGORI, ROLE_LESSERVAMP)

	var/num_sec_divisor = 10 //used to scale amount of sec
	var/num_sec_possible = 4 //includes HoS

/datum/game_mode/grigori_v_drac/announce()
	boutput(world, "<B>The current game mode is - Grigori Vs Dracula!</B>")
	boutput(world, "<B>Grigoris and Vamps try to wipe each other out, but who's who?</B>")

/datum/game_mode/grigori_v_drac/pre_setup()
	var/num_players = 0
	for(var/client/C)
		var/mob/new_player/player = C.mob
		if(!istype(player)) continue
		if(player.ready)
			num_players++

	var/num_enemies = 0
	var/num_sec = 0
	var/num_grigoris = 0
	var/num_dracs = 0

	var/i = rand(1,25)

	num_sec = max(1,min(floor((num_players + i) / num_sec_divisor), num_sec_possible))
	num_enemies = num_players - num_sec
	num_grigoris = max(1,floor(num_enemies / 2))
	num_dracs = max(1,num_enemies - num_grigoris)

	var/list/candidates = get_candidates(num_sec)

	for(var/datum/mind/tokenUser in antag_token_list())
		tokenUser.current?.client?.using_antag_token = FALSE

	if(num_grigoris)
		var/list/chosen_grigoris = list()
		var/g = 0
		for (var/datum/mind/candidate in candidates)
			if(g % 2 == 0)
				chosen_grigoris += candidate
			g++
		for (var/datum/mind/grigori in chosen_grigoris)
			traitors += grigori
			grigori.special_role = ROLE_GRIGORI
			candidates.Remove(grigori)
		num_grigoris = chosen_grigoris.len //just to keep the record straight
	if(num_dracs)
		var/list/chosen_dracs = candidates //we've already pulled the chosen grigoris out, all that's left is dracs
		for (var/datum/mind/drac in chosen_dracs)
			traitors += drac
			drac.special_role = ROLE_LESSERVAMP
			candidates.Remove(drac)
		num_dracs = chosen_dracs
	if(candidates.len > 0) //mopping up what's left behind(hopefully none)
		for (var/datum/mind/leftover in candidates)
			if(prob(50))
				traitors += leftover
				leftover.special_role = ROLE_GRIGORI
				candidates.Remove(leftover)
				num_grigoris++
			else
				traitors += leftover
				leftover.special_role = ROLE_LESSERVAMP
				candidates.Remove(leftover)
				num_dracs++

/datum/game_mode/grigori_v_drac/post_setup()
	var/objective_set_path = null

	for (var/datum/mind/traitor in traitors)
		if (traitor.assigned_role == "Chaplain" && prob(80))
			traitor.assigned_role = ROLE_GRIGORI //most chaplains are grigoris but some can be dracs

		switch(traitor.special_role)
			if(ROLE_GRIGORI)
				objective_set_path = pick(typesof(/datum/objective_set/grigori))
				equip_grigori(traitor.current)
			if(ROLE_LESSERVAMP)
				objective_set_path = pick(Typesof(/datum/objective_set/drac))
				traitor.current.make_vampire(lesser = TRUE)

/datum/game_mode/grigori_v_drac/proc/get_candidates(num_sec)
	var/list/candidates = list()

	for(var/client/C)
		var/mob/new_player/player = C.mob
		var/assigned_sec = 0
		var/assigned_HOS = 0
		if (!istype(player)) continue
		//how do we fuck with the hellbanned people here lol
		if ((player.ready) && !(player.mind in traitors) && !candidates.Find(player.mind))
			if(num_sec && num_sec < assigned_sec) //the sec check is here because usually the entire station isn't an antagonist, and sec can just pick from the leftovers. Not here.
				if(assigned_HOS != 0)
					if(player.client.preferences.job_favorite == "Head of Security" && prob(50) && !player.mind.overrideSecOff)
						player.mind.overrideHOS = TRUE
						assigned_sec++
						assigned_HOS++
						continue
					else if(player.client.preferences.jobs_med_priority.Find("Head of Security") && prob(30) && !player.mind.overrideSecOff)
						player.mind.overrideHOS = TRUE
						assigned_sec++
						assigned_HOS++
						continue
					else if(player.client.preferences.jobs_low_priority.Find("Head of Security") && prob(30) && !player.mind.overrideSecOff)
						player.mind.overrideHOS = TRUE
						assigned_sec++
						assigned_HOS++
						continue
				if(player.client.preferences.job_favorite == "Security Officer" && prob(50) && !player.mind.overrideHOS)
					player.mind.overrideSecOff = TRUE
					assigned_sec++
					continue
				else if(player.client.preferences.jobs_med_priority.Find("Security Officer") && prob(30) && !player.mind.overrideHOS)
					player.mind.overrideSecOff = TRUE
					assigned_sec++
					continue
				else if(player.client.preferences.jobs_low_priority.Find("Security Officer") && prob(30) && !player.mind.overrideHOS)
					player.mind.overrideSecOff = TRUE
					assigned_sec++
					continue
			candidates += player.mind
	return candidates
