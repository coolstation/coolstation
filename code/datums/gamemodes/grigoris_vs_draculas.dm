/datum/game_mode/gvd
	name = "Grigoris vs Draculas"
	config_tag = "gvd"

	shuttle_auto_call_time = 60 MINUTES
	do_antag_random_spawns = 1 // funnier

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
