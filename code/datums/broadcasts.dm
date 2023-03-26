#define LOOP_INFINITELY -1
#define DEFAULT_BROADCAST_MESSAGE_TIME 4 SECONDS


/*
directed broadcasts loop messages over a list of atoms, think like a radio broadcast
I've tried to code this in a way that has no references on the atom (chat_text isn't mine so I consider it fair game), which should keep garbage collection issues low
and also more vars shared by everything everywhere is not ideal. However I haven't designed for supporting more than one broadcast targeting any single object,
assuming that would just be a confusing mess anyways.

I called them directed mostly to avoid confusion with other broadcasty things in the game, and they kinda target certain objects.

They'll automatically instantiate chat_text (a maptext controller thing) on atoms that don't have one yet, which should get cleaned up once that atom is disposed of

If you're instead looking for something with branching in the messaging, I think you'll want the dialoguenode/dialoguemaster system.
*/

/datum/directed_broadcast
	var/list/cooldowns //needed for the ON_COOLDOWN macro


	//Format: list(list("yer_message_here", 5 SECONDS), "a second message", "message 3" , list("This message is number 4", 10 SECONDS))
	//You can omit the list and just have messages (as in the second and third messages), in which case a default time will be used
	//Messages need to be in the order they're to be broadcast in

	///nested list of messages and the time that they should stay up for.
	var/list/list/messages = list()

	var/index = 1
	///The amount of times this broadcast will loop (the broadcast will stop ticking once it reaches 0, but there's no 0th loop)
	var/loops_remaining = LOOP_INFINITELY
	///Toggle to clear the receiving objects list after the broadcast stops. Probably want this to be TRUE to clean up references, but in case you've got a broadca
	var/clear_receivers_after_loop = TRUE
	var/dispose_on_end

	///tracking category of which all members receive the broadcast, which would probably be the preferred
	var/broadcast_cat = null
	///A list of objects receiving this broadcast
	var/list/atom/movable/broadcasting_things = list()

	New()
		..()
		START_TRACKING


	disposing()
		STOP_TRACKING
		broadcast_controls.broadcast_stop(src)
		broadcasting_things = null
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



	var/current_entry = messages[index] //may be a string or a list

	var/delay2use = DEFAULT_BROADCAST_MESSAGE_TIME
	if (islist(current_entry))
		if (length(current_entry) > 1) //shoooould safegaurd folks making
			delay2use = current_entry[2] //timing
		current_entry = current_entry[1] //string

	var/image/chat_maptext/receiver_output

	//chuck everything we'll transmit to on a pile
	var/list/total_shit_broadcasting_to = broadcasting_things + by_cat[broadcast_cat]


	for (var/atom/movable/receiver in total_shit_broadcasting_to) //not skipping the type check just in case
		if (receiver.disposed)
			broadcasting_things -= receiver //If they're in this list, clean up. If they've got a category still active, god help you.
			continue
		if (!isturf(receiver.loc)) continue //
		if (!receiver.chat_text)
			receiver.chat_text = new
			receiver.vis_contents += receiver.chat_text

		receiver_output = make_chat_maptext(receiver, current_entry, "color: #C2BEEE", 200, FALSE, delay2use - 0.5 SECONDS)
		if(receiver_output && length(receiver.chat_text.lines))
			receiver_output.measure() //This proc asks a client and then doesn't use it?
			for(var/image/chat_maptext/I in receiver.chat_text.lines)
				if(I != receiver_output)
					I.bump_up(receiver_output.measured_height)
		//chucking these all in the same message group for now cause the radios are quite capable of spamming chat to shit
		receiver.audible_message("<span class='subtle'><span class='game say'><span class='name'>[receiver]</span> receives:</span> \"[current_entry]\"</span>", 2, assoc_maptext = receiver_output, group = "received_broadcast")

	ON_COOLDOWN(src, "next_broadcast", delay2use)


#undef LOOP_INFINITELY
#undef DEFAULT_BROADCAST_MESSAGE_TIME

/obj/shitty_radio
	name = "shitty test radio"
	desc = "fuck me that's one shitty radio"
	var/on = TRUE
	icon_state = "transmitter-on"
	icon = 'icons/obj/loudspeakers.dmi'
	color = "#AAAAAA"

	New()
		..()
		START_TRACKING_CAT(TR_CAT_RADIO_BROADCAST_RECEIVERS)

	attack_hand(mob/user)
		if (on)
			on = FALSE
			STOP_TRACKING_CAT(TR_CAT_RADIO_BROADCAST_RECEIVERS)
			icon_state = "transmitter"
		else
			START_TRACKING_CAT(TR_CAT_RADIO_BROADCAST_RECEIVERS)
			on = TRUE
			icon_state = "transmitter-on"
		. = ..()


/datum/directed_broadcast/testing
	//Mixing entries like this would be bad form I feel, but to demonstrate that it functions
	messages = list(\
		list("This is the first message for this test broadcast. It has a longer delay than default.", 9 SECONDS),\
		list("If the code works right, you should see this."),\
		"BatElite wuz here",\
		"After this message, the broadcast should loop.",\
	)

	broadcast_cat = TR_CAT_RADIO_BROADCAST_RECEIVERS
