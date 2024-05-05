//Gamemode with a focus on random events and gradually breaking down the station.
//Because antag-based gamemodes don't really work when you've got like 3 pop.

//This thing is barely started so don't expect anything amazing yet.
/datum/game_mode/environmental
	name = "environmental"
	config_tag = "environmental"
	do_antag_random_spawns = 0
	latejoin_antag_compatible = 0
	crew_shortage_enabled = 0 // for testing :)

/datum/game_mode/environmental/pre_setup()
	. = ..()
	//maybe splice in an antag here or there later?
	for(var/datum/mind/mind in antag_token_list())
		mind.current?.client?.using_antag_token = FALSE

	if (!random_events)
		return FALSE

	//Spice up the random events controller
	random_events.time_lock = FALSE //some of the worse events don't start until like 40 minutes in
	random_events.minimum_population = 1 //It's lowpop time
	random_events.time_between_events_lower = 8 MINUTES //down from 11 minutes
	random_events.time_between_events_upper = 15 MINUTES //down from 20 minutes

	random_events.time_between_minor_events_lower = 240 SECONDS //down from 400 seconds
	random_events.time_between_minor_events_upper = 540 SECONDS //down from 800 seconds

	random_events.time_between_spawn_events = 8 MINUTES

	//timestamps for when the next events happen
	random_events.next_major_event = 12 MINUTES
	random_events.next_minor_event = 5 MINUTES
	random_events.next_spawn_event = 8 MINUTES

	//enable additional eventes
	for (var/datum/random_event/minor/environmental/R1 in random_events.minor_events)
		R1.disabled = FALSE
	for (var/datum/random_event/major/environmental/R2 in random_events.events)
		R2.disabled = FALSE
	//I like this one so
	var/datum/random_event/minor/gimmick_flood/R3 = locate() in random_events.minor_events
	if (R3)
		R3.disabled = FALSE

	//Spicy big event
	SPAWN_DBG(rand(2 MINUTES, 3 MINUTES))
		random_events.force_event("Meteor Shower", "Scripted Environmental Mode Event",rand(25,40), 0, 0, 3 MINUTES, rand(8,15)) //large amounts of meteors, fast and with 3 mins warning. direction and delay will be randomised as normal



/datum/game_mode/environmental/announce()
	boutput(world, "<B>The current game mode is - Environmental!</B>")
	boutput(world, "<B>Reality has it out for the station! Hang in there together!</B>")
