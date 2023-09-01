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



A broadcast is an id, a broadcast_cat an optional list of speakers, and a list of messages

The broadcast_cat is the category in which it will try to find receivers.

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
	x is the broadcast_cat we're listening in on

	value should be either a dmi to use for video overlays if using, or the number 1 if not (the latter for internal consistency)

To stop listening, use UNSUBSCRIBE_BROADCAST(x). Treat this like category tracking and make sure to unsubscribe when disposing. :3


There's more options in the code, but that should get you something working I think.
Look for /datum/directed_broadcast/testing_teevee at the bottom of this file as an example of what this system is capable of.
/obj/shitty_radio/shitty_tv is the recipient of that broadcast.
*/

/datum/directed_broadcast
	var/list/cooldowns //needed for the ON_COOLDOWN macro


	//Format: list(list("yer_message_here", 5 SECONDS), "a second message", "message 3" , list("This message is number 4", 10 SECONDS))
	//You can omit the list and just have messages (as in the second and third messages), in which case a default time will be used
	//Messages need to be in the order they're to be broadcast in

	///nested list of messages and the time that they should stay up for.
	var/list/list/messages = list()
	///a list of speaker names (optional) and their associated colours.
	var/list/speakers = list()

	var/index = 1
	var/id
	///The amount of times this broadcast will loop (the broadcast will stop ticking once it reaches 0, but there's no 0th loop)
	var/loops_remaining = LOOP_INFINITELY
	///Toggle to clear the receiving objects list after the broadcast stops. Probably want this to be TRUE to clean up references, but in case you've got a broadca
	var/clear_receivers_after_loop = TRUE
	var/dispose_on_end
	var/default_maptext_colour = "#C2BEEE"

	///tracking category of which all members receive the broadcast, which would probably be the preferred
	var/broadcast_cat = null
	///Toggle to broadcast with "received_broadcast" message group, causing them to collapse in chat. Less spammy, but can't be read back in chat well.
	var/group_messages = FALSE

	New()
		..()
		START_TRACKING


	disposing()
		STOP_TRACKING
		broadcast_controls.broadcast_stop(src)
		messages = null
		..()


/datum/directed_broadcast/proc/process()
	if (GET_COOLDOWN(src, "next_broadcast"))
		return
	if (!length(messages)) //what
		return

	//advance index
	if (++index > length(messages))
		index = 1
		if (loops_remaining != LOOP_INFINITELY)
			loops_remaining--


		if (loops_remaining == 0)
			broadcast_controls.broadcast_stop(src)
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

	var/image/chat_maptext/receiver_output

	//chuck everything we'll transmit to on a pile
	var/list/total_shit_broadcasting_to = by_cat[broadcast_cat]

	for (var/atom/movable/receiver in total_shit_broadcasting_to) //not skipping the type check just in case
		if (receiver.disposed)
			CRASH("Qdeled object ([receiver]) still subscribed to broadcast.")//That thing isn't gonna GC now is it? Nothing we can do in here though
		if (!isturf(receiver.loc)) continue //can't maptext inside things I think?
		if (!receiver.chat_text)
			receiver.chat_text = new
			receiver.vis_contents += receiver.chat_text

		receiver_output = make_chat_maptext(receiver, current_entry, "color: [islist(current_speaker) ? current_speaker[2] : default_maptext_colour]", 200, FALSE, delay2use - 0.5 SECONDS)
		if(receiver_output && length(receiver.chat_text.lines))
			receiver_output.measure() //This proc asks a client and then doesn't use it?
			for(var/image/chat_maptext/I in receiver.chat_text.lines)
				if(I != receiver_output)
					I.bump_up(receiver_output.measured_height)
		//chucking these all in the same message group for now cause the radios are quite capable of spamming chat to shit
		receiver.audible_message("<span class='subtle'><span class='game say'><span class='name'>[receiver]</span> receives:</span> \"[islist(current_speaker) ? current_speaker[1]+": " : null][current_entry]\"</span>", 2, assoc_maptext = receiver_output, group = (group_messages ? "received_broadcast" : ""))

		if (!isnull(video_frame))
			var/which_dmi = by_cat[broadcast_cat][receiver]
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

/obj/shitty_radio/finite_demo
	name = "shittier test radio"
	desc = "god damn this fucking blight on the station (use a multitool to start this)"
	color = "#541771"
	station = TR_CAT_FINITE_BROADCAST_RECEIVERS

	attackby(obj/item/I, mob/user)
		if (istool(I, TOOL_PULSING))
			broadcast_controls.broadcast_start("demo_finite")
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

	broadcast_cat = TR_CAT_RADIO_BROADCAST_RECEIVERS

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

	broadcast_cat = TR_CAT_FINITE_BROADCAST_RECEIVERS

/datum/directed_broadcast/testing_teevee
	id = "demo_teevee"
	speakers = list("hank" = list("Hank", "#A2DD77"), "rachelle" = list("Rachelle", "#DDA277"))
	messages = list(\
		list("Coolstatio...", 6 SECONDS, "hank", "test-A"),\
		list("The universe where you can say 'penis' on TV.", 6 SECONDS, "hank", "test-A"),\
		list("Oh Hank, isn't it wonderful?", 4 SECONDS, "rachelle", "test-B"),\
		list("I love saying words like that.", 5 SECONDS, "rachelle", "test-B"),\
		list("We interrupt this programming for an important announcement:", 7 SECONDS, null, "test-C"),\
		list("For the owner of the golden pod: I smashed in your windshield. Fuck you.", 7 SECONDS, null, "test-C"),\
		list("*laugh track*", 4 SECONDS, null, "test-D"),\
	)//test-D doesn't exist, which is intentional for testing here

	broadcast_cat = TR_CAT_TEEVEE_BROADCAST_RECEIVERS
#undef LOOP_INFINITELY
#undef DEFAULT_BROADCAST_MESSAGE_TIME
