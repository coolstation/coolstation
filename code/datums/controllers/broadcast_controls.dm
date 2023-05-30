/datum/broadcast_controller

	var/list/datum/directed_broadcast/active_broadcasts = list()

/datum/broadcast_controller/proc/process()
	//The idea here is this thing will ping each active broadcast, and the broadcast itself will have a cooldown to check if it actually should
	for (var/datum/directed_broadcast/broadcast as anything in active_broadcasts)
		broadcast.process()


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
	if (broadcast in active_broadcasts) return
	if (set_loops)
		broadcast.loops_remaining = set_loops
	if (broadcast.loops_remaining == 0) return //don't start a spent broadcast
	if (reset_to_start)
		broadcast.index = 1
	active_broadcasts |= broadcast
	if (process_immediately) //send out a message as soon as possible
		broadcast.process()
	//SEND_SIGNAL(broadcast, COMSIG_BROADCAST_STARTED)

/datum/broadcast_controller/proc/broadcast_stop(datum/directed_broadcast/broadcast)
	if (!istype(broadcast)) return
	if (!(broadcast in active_broadcasts)) return
	active_broadcasts -= broadcast
	//SEND_SIGNAL(broadcast, COMSIG_BROADCAST_STOPPED)
