/datum/broadcast_controller

	var/list/list/datum/directed_broadcast/active_broadcasts = list()

/datum/broadcast_controller/proc/process()
	//The idea here is this thing will ping each active broadcast, and the broadcast itself will have a cooldown to check if it actually should
	for (var/channel as anything in active_broadcasts)
		//every queued broadcast in that channel
		var/first = TRUE
		for (var/datum/directed_broadcast/broadcast as anything in active_broadcasts[channel])
			broadcast.process(silent = !first)
			first = FALSE


///Start or resume a broadcast
/*
	broadcast - a datum or an id
	reset_to_start - FALSE resumes the broadcast where it left off
	set_loops - how often you want this to loop, leave on 0 to not change, -1 loops infinitely and any other negative number IDK
	process_immediately - runs the broadcast process immediately, which might give slightly funky timing (it's probably fine though) but sends out a message at once.
*/
/datum/broadcast_controller/proc/broadcast_start(datum/directed_broadcast/broadcast, reset_to_start = TRUE, set_loops = 0, process_immediately = FALSE)
	if (!istype(broadcast))
		for_by_tcl(candidate, /datum/directed_broadcast) //see if we can find it by ID instead
			if (candidate.id == broadcast)
				broadcast = candidate
				break
		if (!istype(broadcast)) return //can't find a valid broadcast

	if (broadcast.loops_remaining == 0) return //don't start a spent broadcast
	if (!islist(broadcast.broadcast_channels)) return

	//optional settings
	if (set_loops)
		broadcast.loops_remaining = set_loops
	if (reset_to_start)
		broadcast.index = 0 //OOB technically but gets incremented before reading

	//priority sorting
	var/in_front_somewhere = FALSE
	for (var/a_channel as anything in broadcast.broadcast_channels)
		var/queue_index = 1
		if (!active_broadcasts[a_channel])//first, make list
			active_broadcasts[a_channel] = list(broadcast)
		else//also handles empty active_broadcast list
			//don't duplicate the same broadcast pls
			if (broadcast in active_broadcasts[a_channel])
				continue
			//Find the first broadcast with a lower priority than ours (so we're last in our priority bracket)
			for (var/datum/directed_broadcast/other_broadcast as anything in active_broadcasts[a_channel])
				if (broadcast.priority > other_broadcast.priority)
					break
				queue_index++
			active_broadcasts[a_channel].Insert(queue_index, broadcast)
		if (queue_index == 1)
			in_front_somewhere = TRUE

	if (process_immediately && in_front_somewhere) //send out a message as soon as possible but only if it'd do something worthwhile
		broadcast.process()
	//SEND_SIGNAL(broadcast, COMSIG_BROADCAST_STARTED)

/datum/broadcast_controller/proc/broadcast_stop(datum/directed_broadcast/broadcast)
	if (!istype(broadcast)) return
	if (!islist(broadcast.broadcast_channels)) return
	for (var/a_channel as anything in broadcast.broadcast_channels)
		if ((broadcast in active_broadcasts[a_channel]))
			active_broadcasts[a_channel] -= broadcast
	//SEND_SIGNAL(broadcast, COMSIG_BROADCAST_STOPPED)
