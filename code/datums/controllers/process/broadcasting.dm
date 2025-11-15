#define MINIMUM_BUFFER_SIZE 3

var/datum/broadcast_controller/broadcast_controls

/datum/controller/process/broadcasting
	var/list/autoschedule_channels

	setup()
		autoschedule_channels = list()
		name = "Broadcasting"
		schedule_interval = 0.5 SECONDS
		RegisterSignal(broadcast_controls, COMSIG_BROADCAST_STOPPED, PROC_REF(autoschedule))

	doWork()
		broadcast_controls.process()

//fill continuously broadcasting channels with crap as they go through
/datum/controller/process/broadcasting/proc/autoschedule(ended_broadcast, channel, programming_buffer)
	if (!(channel in autoschedule_channels))
		return
	if (programming_buffer >= MINIMUM_BUFFER_SIZE)
		return

	//General idea: 2-5 ads - programme - interstitial - programme - ads

	for(var/i in 1 to MINIMUM_BUFFER_SIZE)

	/*
	proc/filter_trait_hats(var/type)
	var/obj/item/clothing/head/coolhat = type
	return !initial(coolhat.blocked_from_petasusaphilic)
	*/
	/*
	if (channel in initial(broadcast.broadcast_channels))
		broadcast_controls.broadcast_start(new broadcast, TRUE, channel, 1, FALSE)
	*/

#undef MINIMUM_BUFFER_SIZE
