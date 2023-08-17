/datum/game_mode/gvd
	name = "Grigoris vs Draculas"
	config_tag = "gvd"

	shuttle_auto_call_time = 60 MINUTES
	do_antag_random_spawns = 1 // funnier

	var/list/datum/mind/grigoris = list()
	var/list/datum/mind/draculas = list()

	latejoin_antag_compatible = 1
	latejoin_antag_roles = list(ROLE_VAMPIRE)
	traitor_types = list(ROLE_VAMPIRE)
	num_enemies_divisor = 5 // 20% Vamps

	/datum/game_mode/proc/announce()
		boutput(world, "<B>In this world, it's Grig or be Grigged.. ... nothin personnel, Drac.</B>")

	/datum/game_mode/proc/pre_setup()
		return ..()
		// Not sure if it goes here or there but we should force everyone to grab the Chaplain job, and also switch all Staff Assistant landmarks to chaplain landmarks

	/datum/game_mode/proc/post_setup()
		return ..()
		// Basically yeah it's just Normal Vampire Mode but with a shitton of Vampires and everyone else is a Chaplain.
		// Oh also make sure the Vampires are also dressed as Chaplains.

	/datum/game_mode/proc/post_post_setup()
		return ..()

/datum/game_mode/gvd/proc/get_possible_draculas()
	var/list/candidates = list()

	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if (ishellbanned(player)) continue //No treason for you
		if ((player.ready) && !(player.mind in draculas) && !(player.mind in token_players) && !candidates.Find(player.mind))
			if(player.client.preferences.be_vampire)
				candidates += player.mind

	if(candidates.len < 1)
		logTheThing("debug", null, null, "<b>Enemy Assignment</b>: Not enough players with be_vampire set to yes, so we're adding players who don't want to be draculas to the pool.")
		for(var/client/C)
			var/mob/new_player/player = C.mob
			if (!istype(player)) continue

			if (ishellbanned(player)) continue //No treason for you
			if ((player.ready) && !(player.mind in draculas) && !(player.mind in token_players) && !candidates.Find(player.mind))
				candidates += player.mind

	if(candidates.len < 1)
		return list()
	else
		return candidates

/datum/game_mode/gvd/proc/get_possible_traitor_grigoris()
	var/list/candidates = list()

	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if (ishellbanned(player)) continue //No treason for you
		if ((player.ready) && !(player.mind in draculas) && !(player.mind in token_players) && !candidates.Find(player.mind))
			if(player.client.preferences.be_traitor)
				candidates += player.mind

	if(candidates.len < 1)
		logTheThing("debug", null, null, "<b>Enemy Assignment</b>: Not enough players with be_traitor set to yes, so we're adding players who don't want to be crooked grigoris to the pool.")
		for(var/client/C)
			var/mob/new_player/player = C.mob
			if (!istype(player)) continue

			if (ishellbanned(player)) continue //No treason for you
			if ((player.ready) && !(player.mind in draculas) && !(player.mind in token_players) && !candidates.Find(player.mind))
				candidates += player.mind

	if(candidates.len < 1)
		return list()
	else
		return candidates
