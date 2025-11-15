#define LOOP_INFINITELY -1
#define DEFAULT_BROADCAST_MESSAGE_TIME 4 SECONDS

#define DEFAULT_PROGRAMMING_PRIORITY 2


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

ABSTRACT_TYPE(/datum/directed_broadcast)
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
			receiver_output = make_chat_maptext(receiver, current_entry, "color: [islist(current_speaker) ? current_speaker[2] : default_maptext_colour]", 150, FALSE, delay2use - 0.5 SECONDS)
			if(receiver_output && length(receiver.chat_text.lines))
				receiver_output.measure() //This proc asks a client and then doesn't use it?
				for(var/image/chat_maptext/I in receiver.chat_text.lines) //why is this a manual operation
					if(I != receiver_output)
						I.bump_up(receiver_output.measured_height, TRUE)

			//chucking these all in the same message group for now cause the radios are quite capable of spamming chat to shit
			receiver.audible_message("<span class='subtle'><span class='game say'><span class='name'>[receiver]</span> receives:</span> \"[islist(current_speaker) ? current_speaker[1]+": " : null][current_entry]\"</span>", 2, assoc_maptext = receiver_output, group = (group_messages ? "received_broadcast" : ""))

			if (!isnull(video_frame))
				var/which_dmi = by_cat[this_channel][receiver]
				if (which_dmi != 1) //receiver has specified a dmi
					receiver.UpdateOverlays(image(which_dmi,video_frame),BROADCAST_VIDEO_KEY)
	ON_COOLDOWN(src, "next_broadcast", delay2use)



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
	speakers = list("hank" = list("Hank", "#A2DD77"), "rachelle" = list("Rachelle", "#DDA277"), "administrator" = list("NT Administrator", "#6969BF"))
	messages = list(\
		list("Colstatio...", 10 SECONDS, "hank", "test-A"),\
		list("The universe where you can say 'penis' on TV.", 10 SECONDS, "hank", "test-A"),\
		list("Oh Hank, isn't it wonderful?", 8 SECONDS, "rachelle", "test-B"),\
		list("I love saying words like that.", 8 SECONDS, "rachelle", "test-B"),\
		list("We interrupt this programming for an important announcement:", 13 SECONDS, null, "test-C"),\
		list("To the owner of the golden pod: I smashed in your windshield. Fuck you.", 10 SECONDS, null, "test-C"),\
		list("*laugh track*", 10 SECONDS, null, "test-D"),\
		list("The following program is brought to you by Cigarettes.", 6 SECONDS, null, "cigarettes-B"),\
		list("Do you know where the fire exists are located?", 10 SECONDS, "administrator", "emergency-B"),\
		list("Often, ten seconds is all it takes to make the difference...", 10 SECONDS, "administrator", "emergency-B"),\
		list("Between life and death.", 5 SECONDS, "administrator", "emergency-B"),\
		list("Speak to your safety officer today.", 10 SECONDS, "administrator", "emergency-B"),\
		list("*static*", 4 SECONDS, null, "test-D"),\
		list("The tape will now rewind.", 7 SECONDS, "administrator", "emergency-A"),\
		list("*static*", 10 SECONDS, null, "test-D"),\
	)//test-D doesn't exist, which is intentional for testing here
	group_messages = TRUE
	broadcast_channels = TR_CAT_TEEVEE_BROADCAST_RECEIVERS

/datum/directed_broadcast/ad
	id = "generic_ad"
	loops_remaining = 1
	priority = DEFAULT_PROGRAMMING_PRIORITY
	group_messages = TRUE
	//direct children of this can go both on radios and TVs
	broadcast_channels = list(TR_CAT_RADIO_BROADCAST_RECEIVERS, TR_CAT_TEEVEE_BROADCAST_RECEIVERS)

	speakers = list("announcer" = list("Announcer", "#d600d6"), "consumer" = list("Consumer", "#003eb3"))
	messages = list(\
		list("*static*", 2 SECONDS, null, "test-D"),\
		list("Have you considered...", 6 SECONDS, "announcer", "cigarettes-A"),\
		list("Buying product?", 6 SECONDS, "announcer", "cigarettes-A"),\
		list("Oh, I'd love to do that! I'll go do that right now!", 8 SECONDS, "consumer", "cigarettes-B"),\
		list("Products. Available wherever goods are sold.", 10 SECONDS, "announcer", "cigarettes-B"),\
		list("*static*", 2 SECONDS, null, "test-D"),\
	)


/datum/directed_broadcast/ad/tv_only
	id = "generic_ad_tv"
	broadcast_channels = TR_CAT_TEEVEE_BROADCAST_RECEIVERS

	speakers = list("announcer" = list("Announcer", "#d600d6"), "consumer" = list("Consumer", "#003eb3"))
	messages = list(\
		list("*static*", 2 SECONDS, null, "test-D"),\
		list("Remember to spend your money wisely.", 7 SECONDS, "announcer", "cigarettes-A"),\
		list("Buy more guns. Guns. Gunse. Gunse.", 6 SECONDS, "announcer", "cigarettes-A"),\
		list("But I have a family to feed!", 6 SECONDS, "consumer", "cigarettes-B"),\
		list("Gunse. Yours is waiting out there for you.", 10 SECONDS, "announcer", "cigarettes-B"),\
		list("*static*", 2 SECONDS, null, "test-D"),\
	)


/datum/directed_broadcast/ad/tv_only/cigarettes
	id = "cigarette_ad"
	speakers = list("hank" = list("Thank", "#A2DD77"), "rachelle" = list("Grachelle", "#DDA277"))
	messages = list(\
		list("*static*", 2 SECONDS, null, "test-D"),\
		list("Smoke...", 6 SECONDS, "hank", "cigarettes-A"),\
		list("Smoke cigarettes today!", 6 SECONDS, "hank", "cigarettes-A"),\
		list("Oh, they're so smooth! I love smoking cigarettes!", 8 SECONDS, "rachelle", "cigarettes-B"),\
		list("Cigarettes- available at your nearest cigarette vending machine.", 10 SECONDS, "hank", "cigarettes-B"),\
		list("*static*", 2 SECONDS, null, "test-D"),\
	)

/datum/directed_broadcast/ad/tv_only/hotdogs
	id = "hotdog_ad"
	speakers = list("Frank" = list("Frank", "#d3374c"))
	messages = list(\
		list("*static*", 2 SECONDS, null, "test-D"),\
		list("Hey...", 6 SECONDS, "Frank", "hotdogs-A"),\
		list("Uh, d'you like hotdogs?", 6 SECONDS, "Frank", "hotdogs-A"),\
		list("If you like hot dogs come to the mall, we're a restaurant that specializes in hot dogs.", 10 SECONDS, "Frank", "hotdogs-A"),\
		list("It's pretty much all we got. You'd need to bring your own soda or something to drink.", 10 SECONDS, "Frank", "hotdogs-A"),\
		list("You're not really supposed to do that either but it's whatever.", 7 SECONDS, "Frank", "hotdogs-A"),\
		list("Come down and get some dogs in you.", 8 SECONDS, "Frank", "hotdogs-B"),\
		list("Probably safe!", 4 SECONDS, "Frank", "hotdogs-B"),\
		list("*static*", 2 SECONDS, null, "test-D"),\
	)

/datum/directed_broadcast/ad/radio_only
	id = "generic_ad_radio"
	broadcast_channels = TR_CAT_RADIO_BROADCAST_RECEIVERS
	speakers = list("announcer" = list("Announcer", "#d600d6"), "consumer" = list("Consumer", "#003eb3"))
	messages = list(\
		list("*static*", 2 SECONDS, null, "test-D"),\
		list("You know you want it.", 3 SECONDS, "announcer"),\
		list("You know you need it.", 3 SECONDS, "announcer"),\
		list("Huh? What?", 2 SECONDS, "consumer"),\
		list("Products. Available wherever goods are sold.", 10 SECONDS, "announcer", "cigarettes-B"),\
		list("*static*", 2 SECONDS, null, "test-D"),\
		)

/datum/directed_broadcast/ad/radio_only/schweewa1
	id = "schweewa_ad_1"
	speakers = list("dad" = list("Your actual dad(???)", "#d1320b"))
	messages = list(\
		list("*Greasy jingle*", 2 SECONDS),\
		list("Schweewa.", 2 SECONDS),\
		list("We've got fucking food in here.", 5 SECONDS),\
		list("Come stuff your mouth!", 4 SECONDS),\
		list("Like a burger or whatever. Buy our shit.", 5 SECONDS),\
		list("You love to eat at Schweewa.", 5 SECONDS),\
		list("Don't disappoint me this time.", 5 SECONDS, "dad"),\
		list("Eat at Schweewa.", 4 SECONDS, "dad"),\
		list("Schweewa: Found wherever asteroid mining takes place.", 8 SECONDS),\
	)

/datum/directed_broadcast/ad/radio_only/schweewa2
	id = "schweewa_ad_2"
	messages = list(\
		list("*Greasy jingle*", 2 SECONDS),\
		list("Schweewa cares for the community.", 2 SECONDS),\
		list("Just in 2053 alone we donated over 70 burnt-out deep fryers to children in need!", 10 SECONDS),\
		list("Every day, our customers find physical and mental support in the bins they eat our food off of.", 10 SECONDS),\
		list("So come on down and join in.", 5 SECONDS),\
		list("You might just find the family you were missing inside here!", 7 SECONDS),\
		list("And if not, there's at least fried chicken.", 6 SECONDS),\
		list("So, so much fried chicken.", 4 SECONDS),\
		list("Schweewa: A beacon of hope in the darkness of space.", 8 SECONDS),\
	)

/datum/directed_broadcast/programme
	priority = DEFAULT_PROGRAMMING_PRIORITY
	loops_remaining = 1

/datum/directed_broadcast/programme/eaglestoryone
	id = "mysteries_of_the_frontier_one"
	speakers = list("narrator" = list("Narrator", "#A2DD77"), "doctorwhitman" = list("Doctor Whitman", "#DDA277"), "specialistvirgil" = list("Specialist Virgil", "#6969BF"), "able" = list("Able", "#d3374c"))
	messages = list(\
		list("This cycle's MYSTERIES OF THE FRONTIER is brought to you by", 10 SECONDS, "narrator", "test-A"),\
		list("Hafgan Heavy Industries, for all your construction and demolition needs", 10 SECONDS, "narrator", "test-A"),\
		list("When we last left off, Doctor Whitman had successfuly isolated the virus haunting Jamsion Labs", 15 SECONDS, "narrator", "test-B"),\
		list("We now resume our story", 7 SECONDS, "narrator", "test-B"),\
		list("Doctor, what in the heavens is that thing!", 10 SECONDS, "specialistvirgil", "test-C"),\
		list("This, my dear ithilid friend, is our culprit.", 10 SECONDS, "doctorwhitman", "test-C"),\
		list("ABLE!", 5 SECONDS, "doctorwhitman", "test-C"),\
		list("Yes Doctor?", 5 SECONDS, "able", "emergency-B"),\
		list("Can you trace where this came from?", 10 SECONDS, "doctorwhitman", "test-C"),\
		list("Please transport the specimen to my upload, so I may interface with the object", 15 SECONDS, "able", "test-B"),\
		list("The Good Doctor and their trusty assistant rushed to the AI's upload room", 15 SECONDS, "narrator", "test-B"),\
		list("After placing the virus in a safe containment unit, and inserting it into the AI's mainframe", 15 SECONDS, "narrator", "test-B"),\
		list("Suddenly...", 5 SECONDS, "narrator", "emergency-B"),\
		list("*sparking noises*", 5 SECONDS, null, "test-C"),\
		list("Able, ABLE! Are you alright Able?!", 7 SECONDS, "specialistvirgil", "emergency-A"),\
		list("Join us next cycle for more of Hafgan Heavy Industries's MYSTERIES OF THE FRONTIER", 15 SECONDS, null, "test-D"),\
	)
	group_messages = TRUE
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
			list("*static*", 2 SECONDS, null, "test-D"),\
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

	broadcast_channels = list(TR_CAT_TEEVEE_BROADCAST_RECEIVERS, TR_CAT_CEILING_BROADCAST_DEFAULT , TR_CAT_RADIO_BROADCAST_RECEIVERS)

/datum/directed_broadcast/signoff
	id = "signoff"

	messages = list(\
		list("That is it for our programming schedule.", 6 SECONDS, null, "emergency-A"),\
		list("This is CoolTV, signing off.", 6 SECONDS, null, "emergency-A"),\
		list("*shitty corporate jingle*", 6 SECONDS, null, "emergency-A"),\
		)

	priority = 1 //last one to play
	progress_when_silent = FALSE

	broadcast_channels = list(TR_CAT_TEEVEE_BROADCAST_RECEIVERS)

ABSTRACT_TYPE(/datum/directed_broadcast/interstitial)
/datum/directed_broadcast/interstitial
	loops_remaining = 1
	priority = DEFAULT_PROGRAMMING_PRIORITY
	group_messages = TRUE

/datum/directed_broadcast/interstitial/tv
	id = "tv_int1"

	messages = list(\
		list("*Bweoooow*", 1 SECONDS, null, "emergency-B"),\
		list("This channel brought to you by Nanotrasen.", 3 SECONDS, null, "emergency-B"),\
		)

/datum/directed_broadcast/interstitial/tv/second
	id = "tv_int2"

	messages = list(\
		list("*Bweoooow*", 1 SECONDS, null, "emergency-B"),\
		list("Nanotrasen TV. For a productive shift.", 3 SECONDS, null, "emergency-B"),\
		)

/datum/directed_broadcast/interstitial/tv/third
	id = "tv_int3"

	messages = list(\
		list("*Bweoooow*", 1 SECONDS, null, "emergency-B"),\
		list("Nanotrasen TV is sponsored by Nanotrasen.", 3 SECONDS, null, "emergency-B"),\
		)

/datum/directed_broadcast/interstitial/radio
	id = "radio_int1"

	messages = list(\
		list("*pling*", 1 SECONDS),\
		list("You're listening to radio.", 3 SECONDS),\
		list("*plong*", 1 SECONDS),\
		)

/datum/directed_broadcast/interstitial/radio/second
	id = "radio_int2"

	messages = list(\
		list("*pling*", 1 SECONDS),\
		list("Radio. It's better than heaven.", 3 SECONDS),\
		list("*plong*", 1 SECONDS),\
		)

/datum/directed_broadcast/interstitial/radio/third
	id = "radio_int3"

	messages = list(\
		list("*pling*", 1 SECONDS),\
		list("Radio. I love it.", 3 SECONDS),\
		list("*plong*", 1 SECONDS),\
		)


#undef LOOP_INFINITELY
#undef DEFAULT_BROADCAST_MESSAGE_TIME
#undef DEFAULT_PROGRAMMING_PRIORITY
