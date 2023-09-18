#define LOOP_INFINITELY -1
#define DEFAULT_BROADCAST_MESSAGE_TIME 4 SECONDS


/*
ABOUT (TECHNICAL):
directed broadcasts loop messages over a list of atoms, think like a radio broadcast
I've tried to code this in a way that neither the broadcast nor the receivers keep track of each other, which should keep garbage collection issues low,
while also avoiding more vars on all atoms.
(chat_text isn't mine so I consider it fair game if that has GC weirdness)

I called them directed broadcasts mostly to avoid confusion with other broadcasty things in the game, since they target subscribed objects

They'll automatically instantiate chat_text (a maptext controller thing) on atoms that don't have one yet,
which should get cleaned up once that atom is disposed of

If you're instead looking for something with branching in the messaging, I think you'll want the dialoguenode/dialoguemaster system.


TO USE (PRACTICAL):
To start a broadcast, call broadcast_controls.broadcast_start() with either a broadcast datum or the id of a broadcast.



A broadcast is an id, a broadcast_channels an optional list of speakers, and a list of messages

The broadcast_channels is the category in which it will try to find receivers.

The speakers list should be formatted
	list("id1" = list("Name One", maptext colour code), "id2" = list("Name Two", maptext colour code))
	et cetera et cetera

	The ids itself should be unique for this broadcast.

	The first part of the inner list is the name that actually gets printed (so you can just write "bot" in the message list instead of "V.I.V.I-SECT-10N" 20 times)

	The second part is the colour of the maptext for this speaker.

The message list can just be a list of strings, or a list of lists each containing the message string and optional data in order:
	list(message, time displayed, speaker id, video broadcast icon state)

	time displayed dictates how long maptext stays up. Timing is all manual, so you'll have to eyeball it based on message length. Default is 4s

	speaker id is either null or should correspond to an id in the speaker list.

	video icon state is just the string of the icon state. It's up to the receiving objects to specify the dmi used via SUBSCRIBE_BROADCAST
	and it's up to the spriter/coder to make sure that dmi has appropriate sprites for the occasion. Remember to think about the no-name fallback!



To get an object to *listen* to a broadcast, use the SUBSCRIBE_BROADCAST(x, value) macro
	x is the broadcast_channels we're listening in on

	value should be either a dmi to use for video overlays if using, or the number 1 if not (the latter for internal consistency)

To stop listening, use UNSUBSCRIBE_BROADCAST(x). Treat this like category tracking and make sure to unsubscribe when disposing. :3


There's more options in the code, but that should get you something working I think.
Look for /datum/directed_broadcast/testing_teevee at the bottom of this file as an example of what this system is capable of.
/obj/shitty_radio/shitty_tv is the recipient of that broadcast.
*/

/datum/directed_broadcast
	var/list/cooldowns //needed for the ON_COOLDOWN macro

	///ID of this broadcast
	var/id
	///I guess you can queue up broadcasts now per channel, and higher priority (but within the same priority it's first come first serve)
	var/priority = 1

	///nested list of messages and their settings, see above
	var/list/list/messages = list()
	///a list of speaker names (optional) and their associated colours.
	var/list/speakers = list()

	///index of the message list
	var/index = 0 //OOB technically but gets incremented before reading


	///The amount of times this broadcast will loop (the broadcast will stop ticking once it reaches 0, but there's no 0th loop)
	var/loops_remaining = LOOP_INFINITELY
	///Delete broadcast datum on end :3
	var/dispose_on_end = FALSE
	///If a priority broadcast is playing instead of this one,
	///TRUE will advance the message index (so messages will be skipped but timing remains intact) while FALSE will effectively pause the broadcast.
	var/progress_when_silent = TRUE

	var/default_maptext_colour = "#C2BEEE"

	///tracking category of which all members receive the broadcast, can be a list of multiple
	var/list/broadcast_channels = null
	///Toggle to broadcast with "received_broadcast" message group, causing them to collapse in chat. Less spammy, but can't be read back in chat well.
	var/group_messages = FALSE

	New()
		..()
		//Bit of QOL and code brevity
		if (!islist(broadcast_channels) && !isnull(broadcast_channels))
			broadcast_channels = list(broadcast_channels)
		START_TRACKING


	disposing()
		STOP_TRACKING
		broadcast_controls.broadcast_stop(src)
		messages = null
		..()


//silent is when when the broadcast is active, but another
/datum/directed_broadcast/proc/process(silent = FALSE)
	if (GET_COOLDOWN(src, "next_broadcast"))
		return
	if (!length(messages)) //what
		return

	//pause
	if (silent && !progress_when_silent)
		return

	//advance index
	if (++index > length(messages))
		index = 1
		if (loops_remaining != LOOP_INFINITELY)
			loops_remaining--


		if (loops_remaining == 0)
			broadcast_controls.broadcast_stop(src)
			if (dispose_on_end)
				qdel(src)
		//	SEND_SIGNAL(broadcast, COMSIG_BROADCAST_ENDED)
			return
		//else
		//	SEND_SIGNAL(broadcast, COMSIG_BROADCAST_LOOPED, loops_remaining)




	var/current_entry = messages[index] //may be a string or a list

	var/delay2use = DEFAULT_BROADCAST_MESSAGE_TIME
	var/current_speaker = null
	var/video_frame = null
	//sorry IDK how you'd do this better there's 3 optional arguments
	if (islist(current_entry))
		if (length(current_entry) > 1) //shoooould safegaurd folks making bad lists
			if (current_entry[2]) //nonzero
				delay2use = current_entry[2] //timing

			if (length(current_entry) > 2)
				if (current_entry[3] in speakers)
					current_speaker = speakers[current_entry[3]]//speaker/maptext col

				if (length(current_entry) > 3)
					video_frame = current_entry[4]//video icon_state
		current_entry = current_entry[1] //string

	//pause but with the index advanced
	if (silent)
		ON_COOLDOWN(src, "next_broadcast", delay2use)
		return

	var/image/chat_maptext/receiver_output

	//go through every channel in turn
	for(var/this_channel in src.broadcast_channels)
		var/list/total_shit_broadcasting_to = by_cat[this_channel]

		for (var/atom/movable/receiver in total_shit_broadcasting_to) //not skipping the type check just in case
			if (receiver.disposed)
				CRASH("Qdeled object ([receiver]) still subscribed to broadcast.")//That thing isn't gonna GC now is it? Nothing we can do in here though
			if (!isturf(receiver.loc)) continue //can't maptext inside things I think?
			if (!receiver.chat_text)
				receiver.chat_text = new
				receiver.vis_contents += receiver.chat_text
			//build and send maptext
			receiver_output = make_chat_maptext(receiver, current_entry, "color: [islist(current_speaker) ? current_speaker[2] : default_maptext_colour]", 200, FALSE, delay2use - 0.5 SECONDS)
			if(receiver_output && length(receiver.chat_text.lines))
				receiver_output.measure() //This proc asks a client and then doesn't use it?
				for(var/image/chat_maptext/I in receiver.chat_text.lines) //why is this a manual operation
					if(I != receiver_output)
						I.bump_up(receiver_output.measured_height)

			//chucking these all in the same message group for now cause the radios are quite capable of spamming chat to shit
			receiver.audible_message("<span class='subtle'><span class='game say'><span class='name'>[receiver]</span> receives:</span> \"[islist(current_speaker) ? current_speaker[1]+": " : null][current_entry]\"</span>", 2, assoc_maptext = receiver_output, group = (group_messages ? "received_broadcast" : ""))

			if (!isnull(video_frame))
				var/which_dmi = by_cat[this_channel][receiver]
				if (which_dmi != 1) //receiver has specified a dmi
					receiver.UpdateOverlays(image(which_dmi,video_frame),BROADCAST_VIDEO_KEY)
	ON_COOLDOWN(src, "next_broadcast", delay2use)



/obj/shitty_radio
	name = "shitty test radio"
	desc = "fuck me that's one shitty radio"
	var/on = TRUE
	var/station = TR_CAT_RADIO_BROADCAST_RECEIVERS
	var/video_dmi = null //Optional:

	icon_state = "transmitter-on"
	icon = 'icons/obj/loudspeakers.dmi'
	color = "#AAAAAA"

	New()
		..()
		//The 1 is there for consistency with what by_cat was doing before I did my hack.
		SUBSCRIBE_BROADCAST(station, (video_dmi ? video_dmi : 1))

	disposing()
		UNSUBSCRIBE_BROADCAST(station)
		..()


	attack_hand(mob/user)
		if (on)
			on = FALSE
			UNSUBSCRIBE_BROADCAST(station)
			icon_state = "transmitter"
		else
			SUBSCRIBE_BROADCAST(station, (video_dmi ? video_dmi : 1))
			on = TRUE
			icon_state = "transmitter-on"
		. = ..()
/*
/obj/shitty_radio/finite_demo
	name = "shittier test radio"
	desc = "god damn this fucking blight on the station (use a multitool to start this)"
	color = "#541771"
	station = TR_CAT_FINITE_BROADCAST_RECEIVERS

	attackby(obj/item/I, mob/user)
		if (istool(I, TOOL_PULSING))
			broadcast_controls.broadcast_start("demo_finite")
		..()
*/
/obj/shitty_radio/queueing_and_interruption_demo //Testing for proper queue behaviour and priority sorting
	name = "queue test radio"
	desc = "Wat een verkakt stuk schroot (use a multitool to start this)"
	color = "#54B771"
	station = TR_CAT_FINITE_BROADCAST_RECEIVERS
	var/ignore = FALSE

	attackby(obj/item/I, mob/user)
		if (istool(I, TOOL_PULSING) && !ignore)
			ignore = TRUE
			broadcast_controls.broadcast_start(new /datum/directed_broadcast/queue_test_series/one)
			broadcast_controls.broadcast_start(new /datum/directed_broadcast/queue_test_series/two)
			broadcast_controls.broadcast_start(new /datum/directed_broadcast/queue_test_series/three)
			broadcast_controls.broadcast_start(new /datum/directed_broadcast/queue_test_series/four)
			SPAWN_DBG(5 SECONDS) //
				broadcast_controls.broadcast_start(new /datum/directed_broadcast/queue_test_series/priority)
				broadcast_controls.broadcast_start(new /datum/directed_broadcast/queue_test_series/highpriority)
				ignore = FALSE

		..()

/obj/shitty_radio/shitty_tv
	name = "shitty test TV"
	desc = "And you thought those radios were fucking garbage"
	icon_state = "POCteevee-on"
	icon = 'icons/misc/broadcastsPOC.dmi'
	station = TR_CAT_TEEVEE_BROADCAST_RECEIVERS
	video_dmi = 'icons/misc/broadcastsPOC.dmi'
	color = null

	//shitcode override but it's a demo object so who cares
	attack_hand(mob/user)
		..()
		if (on)
			icon_state = "POCteevee-on"
		else
			icon_state = "POCteevee"

/datum/directed_broadcast/testing
	id = "demo"
	group_messages = TRUE
	//Mixing entries like this would be bad form I feel, but to demonstrate that it functions
	messages = list(\
		list("This is the first message for this test broadcast. It has a longer delay than default.", 9 SECONDS),\
		list("If the code works right, you should see this."),\
		"BatElite wuz here",\
		"After this message, the broadcast should loop.",\
	)

	broadcast_channels = TR_CAT_RADIO_BROADCAST_RECEIVERS
/*
/datum/directed_broadcast/testing_finite
	id = "demo_finite"
	loops_remaining = 2
	messages = list(\
		"This broadcast will loop twice, and then stop.",\
		"But after that you can restart it by hitting one of the shittier radios with a multitool.",\
		"In the meantime, let me just say I'm gay.",\
		"I think it'd be pretty cool if you made some of these broadcasts too.",\
		"This is the last message in the loop.",\
	)

	broadcast_channels = TR_CAT_FINITE_BROADCAST_RECEIVERS
*/
/datum/directed_broadcast/queue_test_series
	id = "Q"
	loops_remaining = 1
	priority = 1
	broadcast_channels = TR_CAT_FINITE_BROADCAST_RECEIVERS
	progress_when_silent = FALSE
	dispose_on_end = TRUE
/datum/directed_broadcast/queue_test_series/one
	id = "Q1"
	default_maptext_colour = "#FF3333"
	messages = list("First in series.")
/datum/directed_broadcast/queue_test_series/two
	id = "Q2"
	default_maptext_colour = "#AAAA33"
	messages = list("Second in series.")
/datum/directed_broadcast/queue_test_series/three
	id = "Q3"
	default_maptext_colour = "#33FF33"
	messages = list("Third in series.")
/datum/directed_broadcast/queue_test_series/four
	id = "Q4"
	default_maptext_colour = "#33AAAA"
	messages = list("Fourth in series.")
/datum/directed_broadcast/queue_test_series/priority
	id = "Q5"
	default_maptext_colour = "#aaaaaa" //;3
	priority = 2
	messages = list("Lower priority interrupt.")
/datum/directed_broadcast/queue_test_series/highpriority
	id = "Q6"
	default_maptext_colour = "#AAAAAA"
	priority = 3
	messages = list("High priority interrupt.")

/datum/directed_broadcast/testing_teevee
	id = "demo_teevee"
	speakers = list("hank" = list("Hank", "#A2DD77"), "rachelle" = list("Rachelle", "#DDA277"))
	messages = list(\
		list("Coolstatio...", 10 SECONDS, "hank", "test-A"),\
		list("The universe where you can say 'penis' on TV.", 10 SECONDS, "hank", "test-A"),\
		list("Oh Hank, isn't it wonderful?", 8 SECONDS, "rachelle", "test-B"),\
		list("I love saying words like that.", 8 SECONDS, "rachelle", "test-B"),\
		list("We interrupt this programming for an important announcement:", 13 SECONDS, null, "test-C"),\
		list("For the owner of the golden pod: I smashed in your windshield. Fuck you.", 10 SECONDS, null, "test-C"),\
		list("*laugh track*", 10 SECONDS, null, "test-D"),\
		list("The following program is brought to you by Cigarettes.", 10 SECONDS, null, "cigarettes-B"),\
	)//test-D doesn't exist, which is intentional for testing here
	group_messages = TRUE
	broadcast_channels = TR_CAT_TEEVEE_BROADCAST_RECEIVERS

/datum/directed_broadcast/cigarettes
	id = "cigarette_ad"
	priority = 2
	speakers = list("hank" = list("Thank", "#A2DD77"), "rachelle" = list("Grachelle", "#DDA277"))
	messages = list(\
		list("Smoke...", 6 SECONDS, "hank", "cigarettes-A"),\
		list("Smoke cigarettes today!", 6 SECONDS, "hank", "cigarettes-A"),\
		list("Oh, they're so smooth! I love smoking cigarettes!", 6 SECONDS, "rachelle", "cigarettes-B"),\
	)

	broadcast_channels = TR_CAT_TEEVEE_BROADCAST_RECEIVERS

/datum/directed_broadcast/hotdogs
	id = "hotdog_ad"
	priority = 2
	speakers = list("Frank" = list("Frank", "#d3374c"))
	messages = list(\
		list("Hey...", 6 SECONDS, "Frank", "hotdogs-A"),\
		list("Uh, d'you like hotdogs?", 6 SECONDS, "Frank", "hotdogs-A"),\
		list("If you like hot dogs come to the mall, we're a restaurant that specializes in hot dogs.", 10 SECONDS, "Frank", "hotdogs-A"),\
		list("It's pretty much all we got. You'd need to bring your own soda or something to drink.", 10 SECONDS, "Frank", "hotdogs-A"),\
		list("You're not really supposed to do that either but it's whatever.", 7 SECONDS, "Frank", "hotdogs-A"),\
		list("Come down and get some dogs in you.", 8 SECONDS, "Frank", "hotdogs-B"),\
		list("Probably safe!", 4 SECONDS, "Frank", "hotdogs-B"),\
	)

	broadcast_channels = TR_CAT_TEEVEE_BROADCAST_RECEIVERS

/datum/directed_broadcast/emergency
	var/station_name
	var/emergency_situation
	var/eta
	var/additional_info

	New(var/Station_Name, var/Emergency_Situation, var/Eta, var/Additional_Info)
		..()
		src.station_name = Station_Name ? Station_Name : "NT13"
		src.emergency_situation = Emergency_Situation ? Emergency_Situation : "GENERAL EMERGENCY"
		src.eta = Eta ? Eta : "IMMEDIATE"
		src.additional_info = Additional_Info ? Additional_Info : "Seek additional information from local chain of command."

		messages = list(\
			list("Please stand by for an emergency broadcast.", 6 SECONDS, null, "emergency-A"),\
			list("This is not a test. Standby for emergency information.", 6 SECONDS, null, "emergency-A"),\
			list("An emergency alert has been issued for [src.station_name].", 5 SECONDS, null, "emergency-B"),\
			list("Nanotrasen Command has issued an alert for a [src.emergency_situation].", 5 SECONDS, null, "emergency-B"),\
			list("Reports indicate potential hazards in: [src.eta]", 5 SECONDS, null, "emergency-B"),\
			list("[src.additional_info]", 7 SECONDS, null, "emergency-B"),\
			list("All personnel report to stations or shelter as ordered. This message will repeat.", 5 SECONDS, null, "emergency-A"),\
			)

	id = "emergency"
	priority = 10 //pulled out of ass, so long as nothing else goes over this it'll be alright :)
	progress_when_silent = FALSE //just in case :(
	messages = list("Please stand by for an emergency broadcast.", 6 SECONDS, null, "emergency-A")

	broadcast_channels = list(TR_CAT_TEEVEE_BROADCAST_RECEIVERS, TR_CAT_FINITE_BROADCAST_RECEIVERS , TR_CAT_RADIO_BROADCAST_RECEIVERS)


#undef LOOP_INFINITELY
#undef DEFAULT_BROADCAST_MESSAGE_TIME
