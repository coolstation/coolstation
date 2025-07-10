var/datum/event_controller/random_events

//The time for an event is scheduled to start, allowing admins to cancel/change inopportune event picks. These are also when events are picked. Set to 0 to disable
//N.B. also look at the schedule interval for the random events process when setting these, it's very coarse and will need adjusting
#define MAJOR_EVENT_FIRST_ADMIN_WARNING 2 MINUTES //(If you want only one warning, disable the second one and not the first)
#define MAJOR_EVENT_SECOND_ADMIN_WARNING 40 SECONDS //In case that the first warning is scrolled off the window
#define MINOR_EVENT_ADMIN_WARNING 0 SECONDS //these are mostly inconsequential so I'm gonna code one but have it disabled
#define SPAWN_EVENT_ADMIN_WARNING 1 MINUTE	//Slightly more impactful

//Default times for event types to begin
#define MAJOR_EVENTS_BEGIN 30 MINUTES
#define MINOR_EVENTS_BEGIN 10 MINUTES
#define SPAWN_EVENTS_BEGIN 23 MINUTES
#define MAINT_EVENTS_BEGIN 15 MINUTES

ABSTRACT_TYPE(/datum/random_event/major/player_spawn)
ABSTRACT_TYPE(/datum/random_event/major/antag)

/datum/event_controller
	var/list/events = list()
	var/time_between_events_lower = 11 MINUTES
	var/time_between_events_upper = 20 MINUTES
	var/events_enabled = 1
	var/announce_events = 1
	var/event_cycle_count = 0

	var/list/minor_events = list()
	var/time_between_minor_events_lower = 400 SECONDS //6m 40s
	var/time_between_minor_events_upper = 800 SECONDS //13m 20s
	var/minor_events_enabled = 1
	var/minor_event_cycle_count = 0

	var/list/antag_spawn_events = list()
#ifdef RP_MODE
	var/alive_antags_threshold = 0.06
#else
	var/alive_antags_threshold = 0.1
#endif
	var/list/player_spawn_events = list()
	var/dead_players_threshold = 0.3
	var/time_between_spawn_events = 8 MINUTES
	var/spawn_event_cycle_count = 0

	var/major_event_timer = 0
	var/minor_event_timer = 0

	//timestamps for when the next events happen
	var/next_major_event = MAJOR_EVENTS_BEGIN
	var/next_minor_event = MINOR_EVENTS_BEGIN
	var/next_spawn_event = SPAWN_EVENTS_BEGIN
	//the picked types for the next scheduled event
	var/datum/random_event/next_picked_major_event = null
	var/datum/random_event/next_picked_minor_event = null
	var/datum/random_event/next_picked_spawn_event = null

	//parking the maintenance arrears event here so we don't need to keep searching for it
	var/datum/random_event/minor/maintenance/maintenance_breakdown/maintenance_event = null

	//Effectively disabling extra maint events for the moment, see how that works out. They can still be pulled at random as a minor event.
	var/next_maint_event = 120 MINUTES//MAINT_EVENTS_BEGIN
	var/time_between_maint_events_lower = 400 SECONDS //6m 40s
	var/time_between_maint_events_upper = 800 SECONDS //13m 20s
	//To disable the machinery maintenance system, just disable the event itself.

	var/time_lock = 1
	var/list/special_events = list()
	var/minimum_population = 5 // Minimum amount of players connected for event to occur
	var/list/cooldowns

	New()
		..()
		for (var/X in childrentypesof(/datum/random_event/major))
			if(IS_ABSTRACT(X)) // warc - fix for "random event cycle can pick nonexistent events "
				continue
			var/datum/random_event/RE = new X
			events += RE

		for (var/X in childrentypesof(/datum/random_event/major/antag))
			var/datum/random_event/RE = new X
			antag_spawn_events += RE

		for (var/X in childrentypesof(/datum/random_event/major/player_spawn))
			var/datum/random_event/RE = new X
			player_spawn_events += RE

		for (var/X in childrentypesof(/datum/random_event/minor))
			if(IS_ABSTRACT(X)) //environmental minor base woop woop
				continue
			var/datum/random_event/RE = new X
			minor_events += RE
			if (istype(RE, /datum/random_event/minor/maintenance/maintenance_breakdown))
				maintenance_event = RE

		for (var/X in childrentypesof(/datum/random_event/special))
			var/datum/random_event/RE = new X
			special_events += RE

	proc/mult_time_between_events(var/mult=1)
		time_between_events_lower = floor(mult*time_between_events_lower)
		time_between_events_upper = floor(mult*time_between_events_upper)
		time_between_minor_events_lower = floor(mult*time_between_minor_events_lower)
		time_between_minor_events_upper = floor(mult*time_between_minor_events_upper)

	proc/process()
		// prevent random events near round end
		if (emergency_shuttle.location > SHUTTLE_LOC_STATION || current_state == GAME_STATE_FINISHED)
			return

		//MAJOR EVENTS
		if (ticker.round_elapsed_ticks >= next_major_event)
			event_cycle()
		else if(MAJOR_EVENT_FIRST_ADMIN_WARNING) //check for admin warning timings
			var/time_to_go = next_major_event - ticker.round_elapsed_ticks
			if(time_to_go < MAJOR_EVENT_FIRST_ADMIN_WARNING)
				if (!next_picked_major_event) next_picked_major_event = pick_random_event(events)
				if (!ON_COOLDOWN(src, "major_event_first_warning", MAJOR_EVENT_FIRST_ADMIN_WARNING + 10)) //cooldown slightly longer than eligible period
					message_admins("<span class='internal'>Random event soon: \An [next_picked_major_event.name] event will occur at around [floor(next_major_event / 600)] minutes.<br><a href=\"byond://?src=\ref[src];major_interrupt=1;major_cycle=[event_cycle_count]\">Cancel</a> - <a href=\"byond://?src=\ref[src];major_change=1;major_cycle=[event_cycle_count]\">Change</a></span>")
				else if (MAJOR_EVENT_SECOND_ADMIN_WARNING && time_to_go < MAJOR_EVENT_SECOND_ADMIN_WARNING)
					if (ON_COOLDOWN(src, "major_event_second_warning", MAJOR_EVENT_SECOND_ADMIN_WARNING + 10))
						message_admins("<span class='internal'>Random event imminent: [next_picked_major_event.name] will start shortly.<br><a href=\"byond://?src=\ref[src];major_interrupt=1;major_cycle=[event_cycle_count]\">Cancel</a> - <a href=\"byond://?src=\ref[src];major_change=1;major_cycle=[event_cycle_count]\">Change</a></span>")

		//SPAWN EVENTS
		if (ticker.round_elapsed_ticks >= next_spawn_event)
			spawn_event()
		else if(SPAWN_EVENT_ADMIN_WARNING)//check for admin warning timing
			var/time_to_go = next_spawn_event - ticker.round_elapsed_ticks
			if(time_to_go < SPAWN_EVENT_ADMIN_WARNING)
				if (!next_picked_spawn_event) pick_random_spawn_event()
				if (next_picked_spawn_event && !ON_COOLDOWN(src, "minor_event_first_warning", SPAWN_EVENT_ADMIN_WARNING + 10))
					message_admins("<span class='internal'>Random spawn event soon: \An [next_picked_spawn_event.name] event will occur at around [floor(next_spawn_event / 600)] minutes.<br><a href=\"byond://?src=\ref[src];spawn_interrupt=1;spawn_cycle=[spawn_event_cycle_count]\">Cancel</a> - <a href=\"byond://?src=\ref[src];spawn_change=1;spawn_cycle=[spawn_event_cycle_count]\">Change</a></span>")

		//MINOR EVENTS
		if (ticker.round_elapsed_ticks >= next_minor_event)
			minor_event_cycle()
		else if(MINOR_EVENT_ADMIN_WARNING) //check for admin warning timing
			var/time_to_go = next_minor_event - ticker.round_elapsed_ticks
			if(time_to_go < MINOR_EVENT_ADMIN_WARNING)
				if (!next_picked_minor_event) next_picked_minor_event = pick_random_event(minor_events)
				if (!ON_COOLDOWN(src, "minor_event_first_warning", MINOR_EVENT_ADMIN_WARNING + 10))
					message_admins("<span class='internal'>Minor random event soon: \An [next_picked_minor_event.name] event will occur at around [floor(next_minor_event / 600)] minutes.<br><a href=\"byond://?src=\ref[src];minor_interrupt=1;minor_cycle=[minor_event_cycle_count]\">Cancel</a> - <a href=\"byond://?src=\ref[src];minor_change=1;minor_cycle=[minor_event_cycle_count]\">Change</a></span>")

		if (ticker.round_elapsed_ticks >= next_maint_event)
			maintenance_event.event_effect("Routine Lack of Maintenance", rand(1,3))
			next_maint_event = TIME + rand(time_between_maint_events_lower,time_between_maint_events_upper)

	proc/event_cycle()
		event_cycle_count++
		if (events_enabled && (total_clients() >= minimum_population))
			if (!next_picked_major_event)
				next_picked_major_event = pick_random_event(events)
			next_picked_major_event.event_effect()
			next_picked_major_event = null
		else
			message_admins("<span class='internal'>A random event would have happened now, but they are disabled!</span>")

		major_event_timer = rand(time_between_events_lower,time_between_events_upper)
		next_major_event = TIME + major_event_timer
		message_admins("<span class='internal'>Next event will occur at [floor(next_major_event / 600)] minutes into the round.</span>")

	proc/minor_event_cycle()
		minor_event_cycle_count++
		if (minor_events_enabled)
			if (!next_picked_minor_event)
				next_picked_minor_event = pick_random_event(minor_events)
			next_picked_minor_event.event_effect()
			next_picked_minor_event = null

		minor_event_timer = rand(time_between_minor_events_lower,time_between_minor_events_upper)
		next_minor_event = TIME + minor_event_timer

	proc/spawn_event(var/type = "player")
		spawn_event_cycle_count++
		if (!events_enabled)
			message_admins("<span class='internal'>A spawn event would have happened now, but they are disabled!</span>")
		else if (total_clients() < minimum_population)
			message_admins("<span class='internal'>A spawn event would have happened now, but there is not enough players!</span>")
		else if (ticker?.mode?.do_random_events)
			if (!next_picked_spawn_event)
				pick_random_spawn_event(events)
			next_picked_spawn_event?.event_effect() //pick_random_spawn_event can fail if conditions aren't dire enough
			next_picked_spawn_event = null

		next_spawn_event = TIME + time_between_spawn_events

	proc/pick_random_event(var/list/event_bank, var/source = null)
		if (!event_bank || event_bank.len < 1)
			logTheThing("debug", null, null, "<b>Random Events:</b> pick_random_event proc was passed a bad event bank")
			return
		if (!ticker?.mode?.do_random_events)
			logTheThing("debug", null, null, "<b>Random Events:</b> Random events are turned off on this game mode.")
			return
		var/list/eligible = list()
		var/list/weights = list()
		for (var/datum/random_event/RE in event_bank)
			if (RE.is_event_available( ignore_time_lock = (source=="spawn_antag") ))
				eligible += RE
				weights += RE.weight
		if (eligible.len > 0)
			return weightedprob(eligible, weights)
		else
			logTheThing("debug", null, null, "<b>Random Events:</b> pick_random_event couldn't find any eligible events")

	//spawn events are kinda weird so they have their bespoke picking proc
	proc/pick_random_spawn_event()
		var/aap = get_alive_antags_percentage()
		var/dcp = get_dead_crew_percentage()
		if (aap < alive_antags_threshold && (ticker?.mode?.do_antag_random_spawns))
			next_picked_spawn_event = pick_random_event(list(pick(antag_spawn_events)), source = "spawn_antag")
			//message_admins("<span class='internal'>Antag spawn event success!<br>[round(100 * aap, 0.1)]% of the alive crew were antags.</span>")
		else if (dcp > dead_players_threshold)
			next_picked_spawn_event = pick_random_event(player_spawn_events, source = "spawn_player")
			//message_admins("<span class='internal'>Player spawn event success!<br>[round(100 * dcp, 0.1)]% of the entire crew were dead.</span>")
		else
			message_admins("<span class='internal'>A spawn event would have happened now, but it was not needed based on alive players + antagonists headcount! Advancing next spawn event time.<br> \
							[round(100 * aap, 0.1)]% of the alive crew were antags and [round(100 * dcp, 0.1)]% of the entire crew were dead.</span>")
			next_spawn_event += time_between_spawn_events

	proc/force_event(var/string,var/reason)
		if (!string)
			return
		if (!reason)
			reason = "coded instance (undefined)"
		var/list/arguments = list(reason) + args.Copy(3,0) //get any number of arguments past the reason one
		var/list/allevents = events | minor_events | special_events
		for (var/datum/random_event/RE in allevents)
			if (RE.name == string)
				RE.event_effect(arglist(arguments))
				break

	///////////////////
	// CONFIGURATION //
	///////////////////

	proc/event_config()
		var/dat = "<html><body><title>Random Events Controller</title>"
		dat += "<b><u>Random Event Controls</u></b><HR>"

		dat += "Next major event at <a href='byond://?src=\ref[src];ScheduleMajor=1'>[floor(next_major_event / 600)] minutes</a> into the round.<br>"
		dat += "Next minor event at <a href='byond://?src=\ref[src];ScheduleMinor=1'>[floor(next_minor_event / 600)] minutes</a> into the round.<br>"
		dat += "Next spawn event at <a href='byond://?src=\ref[src];ScheduleSpawn=1'>[floor(next_spawn_event / 600)] minutes</a> into the round.<br>"
		dat += "Next maintenance event at <a href='byond://?src=\ref[src];ScheduleMaint=1'>[floor(next_maint_event / 600)] minutes</a> into the round.<br>"

		dat += "<b><a href='byond://?src=\ref[src];EnableEvents=1'>Random Events Enabled:</a></b> [events_enabled ? "Yes" : "No"]<br>"
		dat += "<b><a href='byond://?src=\ref[src];EnableMEvents=1'>Minor Events Enabled:</a></b> [minor_events_enabled ? "Yes" : "No"]<br>"
		dat += "<b><a href='byond://?src=\ref[src];AnnounceEvents=1'>Announce Events to Station:</a></b> [announce_events ? "Yes" : "No"]<br>"
		dat += "<b><a href='byond://?src=\ref[src];TimeLocks=1'>Time Locking:</a></b> [time_lock ? "Yes" : "No"]<br>"
		dat += "<b>Minimum Population for Events: <a href='byond://?src=\ref[src];MinPop=1'>[minimum_population] players</a><br>"
		dat += "<b>Time Between Events:</b> <a href='byond://?src=\ref[src];TimeLower=1'>[floor(time_between_events_lower / 600)]m</a> /"
		dat += " <a href='byond://?src=\ref[src];TimeUpper=1'>[floor(time_between_events_upper / 600)]m</a><br>"
		dat += "<b>Time Between Minor Events:</b> <a href='byond://?src=\ref[src];MTimeLower=1'>[floor(time_between_minor_events_lower / 600)]m</a> /"
		dat += " <a href='byond://?src=\ref[src];MTimeUpper=1'>[floor(time_between_minor_events_upper / 600)]m</a>"
		dat += "<HR>"

		dat += "<b><u>Normal Random Events</u></b><BR>"
		for(var/datum/random_event/RE in events)
			dat += "<a href='byond://?src=\ref[src];TriggerEvent=\ref[RE]'><b>[RE.name]</b></a>"
			dat += " <small><a href='byond://?src=\ref[src];DisableEvent=\ref[RE]'>([RE.disabled ? "Disabled" : "Enabled"])</a>"
			if (RE.is_event_available())
				dat += " (Active)"
			dat += "<br></small>"
		dat += "<BR>"


		dat += "<b><u>Minor Random Events</u></b><BR>"
		for(var/datum/random_event/RE in minor_events)
			dat += "<a href='byond://?src=\ref[src];TriggerMEvent=\ref[RE]'><b>[RE.name]</b></a>"
			dat += " <small><a href='byond://?src=\ref[src];DisableMEvent=\ref[RE]'>([RE.disabled ? "Disabled" : "Enabled"])</a>"
			if (RE.is_event_available())
				dat += " (Active)"
			dat += "<br></small>"
		dat += "<BR>"

		dat += "<b><u>Gimmick Events</u></b><BR>"
		for(var/datum/random_event/RE in special_events)
			dat += "<a href='byond://?src=\ref[src];TriggerSEvent=\ref[RE]'><b>[RE.name]</b></a><br>"

		dat += "<HR>"
		dat += "</body></html>"
		usr.Browse(dat,"window=reconfig;size=450x450")

	Topic(href, href_list[])
		//So we have not had any validation on the admin random events panel since its inception. Argh. /Spy
		if(usr?.client && !usr.client.holder) {boutput(usr, "Only administrators may use this command."); return}
		var/pop_up_UI = TRUE //this topic is now a mix of in-chat and panel commands, so the former shouldn't open the event controls

		if(href_list["TriggerEvent"])
			var/datum/random_event/RE = locate(href_list["TriggerEvent"]) in events
			if (!istype(RE,/datum/random_event/))
				return
			var/choice = alert("Trigger a [RE.name] event?","Random Events","Yes","No")
			if (choice == "Yes")
				if (RE.customization_available)
					var/choice2 = alert("Random or custom variables?","[RE.name]","Random","Custom")
					if (choice2 == "Custom")
						RE.admin_call(key_name(usr, 1))
					else
						RE.event_effect("Triggered by [key_name(usr)]")
				else
					RE.event_effect("Triggered by [key_name(usr)]")

		else if(href_list["TriggerMEvent"])
			var/datum/random_event/RE = locate(href_list["TriggerMEvent"]) in minor_events
			if (!istype(RE,/datum/random_event/))
				return
			var/choice = alert("Trigger a [RE.name] event?","Random Events","Yes","No")
			if (choice == "Yes")
				if (RE.customization_available)
					var/choice2 = alert("Random or custom variables?","[RE.name]","Random","Custom")
					if (choice2 == "Custom")
						RE.admin_call(key_name(usr, 1))
					else
						RE.event_effect("Triggered by [key_name(usr)]")
				else
					RE.event_effect("Triggered by [key_name(usr)]")

		else if(href_list["TriggerSEvent"])
			var/datum/random_event/RE = locate(href_list["TriggerSEvent"]) in special_events
			if (!istype(RE,/datum/random_event/))
				return
			var/choice = alert("Trigger a [RE.name] event?","Random Events","Yes","No")
			if (choice == "Yes")
				if (RE.customization_available)
					var/choice2 = alert("Random or custom variables?","[RE.name]","Random","Custom")
					if (choice2 == "Custom")
						RE.admin_call(key_name(usr, 1))
					else
						RE.event_effect("Triggered by [key_name(usr)]")
				else
					RE.event_effect("Triggered by [key_name(usr)]")

		//in-chat command for cancelling an event about to happen
		else if(href_list["major_interrupt"])
			pop_up_UI = FALSE
			if (event_cycle_count== text2num(href_list["major_cycle"]))// We've not clicked some old link
				message_admins("Admin [key_name(usr)] cancelled the next major event")
				logTheThing("admin", usr, null, "cancelled the next major event")
				logTheThing("diary", usr, null, "cancelled the next major event", "admin")
				major_event_timer = rand(time_between_events_lower,time_between_events_upper)
				next_major_event = ticker.round_elapsed_ticks + major_event_timer
				next_picked_major_event = null
			else
				boutput(usr, "<span=alert>That event has come and gone, silly.</span>")

		//in-chat command for changing the type of event about to happen
		else if(href_list["major_change"])
			pop_up_UI = FALSE
			var/new_event = input(usr, "Pick another event type", "Event shit", src.next_picked_major_event) as null|anything in events
			if (event_cycle_count == text2num(href_list["major_cycle"]))
				next_picked_major_event = new_event
				message_admins("Admin [key_name(usr)] changed the next major event to [next_picked_major_event?.name].")
				logTheThing("admin", usr, null, "changed the next major event to [next_picked_major_event?.name].")
				logTheThing("diary", usr, null, "changed the next major event to [next_picked_major_event?.name].", "admin")
			else
				boutput(usr, "<span=alert>That event has come and gone, silly.</span>")

		else if(href_list["minor_interrupt"])
			pop_up_UI = FALSE
			if (minor_event_cycle_count== text2num(href_list["minor_cycle"]))
				minor_event_timer = rand(time_between_minor_events_lower,time_between_minor_events_upper)
				next_minor_event = ticker.round_elapsed_ticks + minor_event_timer
				next_picked_minor_event = null
			else
				boutput(usr, "<span=alert>That event has come and gone, silly.</span>")

		else if(href_list["minor_change"])
			pop_up_UI = FALSE
			var/new_event = input(usr, "Pick another event type", "Event shit", src.next_picked_minor_event) as null|anything in minor_events
			if (minor_event_cycle_count == text2num(href_list["minor_cycle"]))
				next_picked_minor_event = new_event
			else
				boutput(usr, "<span=alert>That event has come and gone, silly.</span>")

		else if(href_list["spawn_interrupt"])
			pop_up_UI = FALSE
			if (spawn_event_cycle_count== text2num(href_list["spawn_cycle"]))// We've not clicked some old link
				message_admins("Admin [key_name(usr)] cancelled the next spawn event")
				logTheThing("admin", usr, null, "cancelled the next spawn event")
				logTheThing("diary", usr, null, "cancelled the next spawn event", "admin")
				next_spawn_event = ticker.round_elapsed_ticks + time_between_spawn_events
				next_picked_spawn_event = null
			else
				boutput(usr, "<span=alert>That event has come and gone, silly.</span>")

		else if(href_list["spawn_change"])
			pop_up_UI = FALSE
			var/new_event = input(usr, "Pick another event type", "Event shit", src.next_picked_spawn_event) as null|anything in (antag_spawn_events + player_spawn_events)
			if (spawn_event_cycle_count == text2num(href_list["spawn_cycle"]))
				next_picked_spawn_event = new_event
				message_admins("Admin [key_name(usr)] changed the next spawn event to [next_picked_spawn_event?.name].")
				logTheThing("admin", usr, null, "changed the next spawn event to [next_picked_spawn_event?.name].")
				logTheThing("diary", usr, null, "changed the next spawn event to [next_picked_spawn_event?.name].", "admin")
			else
				boutput(usr, "<span=alert>That event has come and gone, silly.</span>")

		else if(href_list["DisableEvent"])
			var/datum/random_event/RE = locate(href_list["DisableEvent"]) in events
			if (!istype(RE,/datum/random_event/))
				return
			RE.disabled = !RE.disabled
			message_admins("Admin [key_name(usr)] switched [RE.name] event [RE.disabled ? "Off" : "On"]")
			logTheThing("admin", usr, null, "switched [RE.name] event [RE.disabled ? "Off" : "On"]")
			logTheThing("diary", usr, null, "switched [RE.name] event [RE.disabled ? "Off" : "On"]", "admin")

		else if(href_list["DisableMEvent"])
			var/datum/random_event/RE = locate(href_list["DisableMEvent"]) in minor_events
			if (!istype(RE,/datum/random_event/))
				return
			RE.disabled = !RE.disabled
			message_admins("Admin [key_name(usr)] switched [RE.name] event [RE.disabled ? "Off" : "On"]")
			logTheThing("admin", usr, null, "switched [RE.name] event [RE.disabled ? "Off" : "On"]")
			logTheThing("diary", usr, null, "switched [RE.name] event [RE.disabled ? "Off" : "On"]", "admin")

		else if(href_list["MinPop"])
			var/new_min = input("How many players need to be connected before events will occur?","Random Events",minimum_population) as num
			if (new_min == minimum_population) return

			if (new_min < 1)
				boutput(usr, "<span class='alert'>Well that doesn't even make sense.</span>")
				return
			else
				minimum_population = new_min

			message_admins("Admin [key_name(usr)] set the minimum population for events to [minimum_population]")
			logTheThing("admin", usr, null, "set the minimum population for events to [minimum_population]")
			logTheThing("diary", usr, null, "set the minimum population for events to [minimum_population]", "admin")

		else if(href_list["ScheduleMajor"])
			var/time = input("At how many minutes should the next major event occur?","Random Events") as num
			next_major_event = time MINUTES

			message_admins("Admin [key_name(usr)] set next major event to occur at [time] minutes")
			logTheThing("admin", usr, null, "set next major event to occur at [time] minutes")
			logTheThing("diary", usr, null, "set next major event to occur at [time] minutes", "admin")

		else if(href_list["ScheduleMinor"])
			var/time = input("At how many minutes should the next minor event occur?","Random Events") as num
			next_minor_event = time MINUTES

			message_admins("Admin [key_name(usr)] set next minor event to occur at [time] minutes")
			logTheThing("admin", usr, null, "set next minor event to occur at [time] minutes")
			logTheThing("diary", usr, null, "set next minor event to occur at [time] minutes", "admin")

		else if(href_list["ScheduleSpawn"])
			var/time = input("At how many minutes should the next spawn event occur?","Random Events") as num
			next_spawn_event = time MINUTES

			message_admins("Admin [key_name(usr)] set next spawn event to occur at [time] minutes")
			logTheThing("admin", usr, null, "set next spawn event to occur at [time] minutes")
			logTheThing("diary", usr, null, "set next spawn event to occur at [time] minutes", "admin")

		else if(href_list["ScheduleMaint"])
			var/time = input("At how many minutes should the next maintenance event occur?","Random Events") as num
			next_maint_event = time MINUTES

			message_admins("Admin [key_name(usr)] set next maintenance event to occur at [time] minutes")
			logTheThing("admin", usr, null, "set next maintenance event to occur at [time] minutes")
			logTheThing("diary", usr, null, "set next maintenance event to occur at [time] minutes", "admin")

		else if(href_list["EnableEvents"])
			events_enabled = !events_enabled
			message_admins("Admin [key_name(usr)] [events_enabled ? "enabled" : "disabled"] random events")
			logTheThing("admin", usr, null, "[events_enabled ? "enabled" : "disabled"] random events")
			logTheThing("diary", usr, null, "[events_enabled ? "enabled" : "disabled"] random events", "admin")

		else if(href_list["EnableMEvents"])
			minor_events_enabled = !minor_events_enabled
			message_admins("Admin [key_name(usr)] [minor_events_enabled ? "enabled" : "disabled"] minor events")
			logTheThing("admin", usr, null, "[minor_events_enabled ? "enabled" : "disabled"] minor events")
			logTheThing("diary", usr, null, "[minor_events_enabled ? "enabled" : "disabled"] minor events", "admin")

		else if(href_list["AnnounceEvents"])
			announce_events = !announce_events
			message_admins("Admin [key_name(usr)] [announce_events ? "enabled" : "disabled"] random event announcements")
			logTheThing("admin", usr, null, "[announce_events ? "enabled" : "disabled"] random event announcements")
			logTheThing("diary", usr, null, "[announce_events ? "enabled" : "disabled"] random event announcements", "admin")

		else if(href_list["TimeLocks"])
			time_lock = !time_lock
			message_admins("Admin [key_name(usr)] [time_lock ? "enabled" : "disabled"] random event time locks")
			logTheThing("admin", usr, null, "[time_lock ? "enabled" : "disabled"] random event time locks")
			logTheThing("diary", usr, null, "[time_lock ? "enabled" : "disabled"] random event time locks", "admin")

		else if(href_list["TimeLower"])
			var/time = input("Set the lower bound to how many minutes?","Random Events") as num
			if (time < 1)
				boutput(usr, "<span class='alert'>The fuck is that supposed to mean???? Knock it off!</span>")
				return

			time *= 600
			if (time > time_between_events_upper)
				boutput(usr, "<span class='alert'>You cannot set the lower bound higher than the upper bound.</span>")
			else
				time_between_events_lower = time
				message_admins("Admin [key_name(usr)] set event lower interval bound to [time_between_events_lower / 600] minutes")
				logTheThing("admin", usr, null, "set event lower interval bound to [time_between_events_lower / 600] minutes")
				logTheThing("diary", usr, null, "set event lower interval bound to [time_between_events_lower / 600] minutes", "admin")

		else if(href_list["TimeUpper"])
			var/time = input("Set the upper bound to how many minutes?","Random Events") as num
			if (time > 100)
				boutput(usr, "<span class='alert'>That's a bit much.</span>")
				return

			time *= 600
			if (time < time_between_events_lower)
				boutput(usr, "<span class='alert'>You cannot set the upper bound lower than the lower bound.</span>")
			else
				time_between_events_upper = time
			message_admins("Admin [key_name(usr)] set event upper interval bound to [time_between_events_upper / 600] minutes")
			logTheThing("admin", usr, null, "set event upper interval bound to [time_between_events_upper / 600] minutes")
			logTheThing("diary", usr, null, "set event upper interval bound to [time_between_events_upper / 600] minutes", "admin")

		else if(href_list["MTimeLower"])
			var/time = input("Set the lower bound to how many minutes?","Random Events") as num
			if (time < 1)
				boutput(usr, "<span class='alert'>The fuck is that supposed to mean???? Knock it off!</span>")
				return

			time *= 600
			if (time > time_between_minor_events_upper)
				boutput(usr, "<span class='alert'>You cannot set the lower bound higher than the upper bound.</span>")
			else
				time_between_minor_events_lower = time
			message_admins("Admin [key_name(usr)] set minor event lower interval bound to [time_between_minor_events_lower / 600] minutes")
			logTheThing("admin", usr, null, "set minor event lower interval bound to [time_between_minor_events_lower / 600] minutes")
			logTheThing("diary", usr, null, "set minor event lower interval bound to [time_between_minor_events_lower / 600] minutes", "admin")

		else if(href_list["MTimeUpper"])
			var/time = input("Set the upper bound to how many minutes?","Random Events") as num
			if (time > 100)
				boutput(usr, "<span class='alert'>That's a bit much.</span>")
				return

			time *= 600
			if (time < time_between_events_lower)
				boutput(usr, "<span class='alert'>You cannot set the upper bound lower than the lower bound.</span>")
			else
				time_between_minor_events_upper = time
			message_admins("Admin [key_name(usr)] set minor event upper interval bound to [time_between_minor_events_upper / 600] minutes")
			logTheThing("admin", usr, null, "set minor event upper interval bound to [time_between_minor_events_upper / 600] minutes")
			logTheThing("diary", usr, null, "set minor event upper interval bound to [time_between_minor_events_upper / 600] minutes", "admin")

		if (pop_up_UI)
			src.event_config()

#undef MAJOR_EVENT_FIRST_ADMIN_WARNING
#undef MAJOR_EVENT_SECOND_ADMIN_WARNING
#undef MINOR_EVENT_ADMIN_WARNING
#undef SPAWN_EVENT_ADMIN_WARNING
#undef MAJOR_EVENTS_BEGIN
#undef MINOR_EVENTS_BEGIN
#undef SPAWN_EVENTS_BEGIN
#undef MAINT_EVENTS_BEGIN
