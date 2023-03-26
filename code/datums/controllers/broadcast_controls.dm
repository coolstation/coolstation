/datum/broadcast_controller

	var/list/datum/directed_broadcast/active_broadcasts = list()

/datum/broadcast_controller/proc/process()
	//The idea here is this thing will ping each active broadcast, and the broadcast itself will have a cooldown to check if it actually should
	for (var/datum/directed_broadcast/broadcast as anything in active_broadcasts)
		broadcast.process()

/datum/broadcast_controller/proc/broadcast_start(datum/directed_broadcast/broadcast, process_immediately = FALSE)
	if (!istype(broadcast)) return
	active_broadcasts |= broadcast
	if (process_immediately) //send out a message as soon as possible
		broadcast.process()

/datum/broadcast_controller/proc/broadcast_stop(datum/directed_broadcast/broadcast)
	if (!istype(broadcast)) return
	active_broadcasts -= broadcast
