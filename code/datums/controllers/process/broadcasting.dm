#define MINIMUM_BUFFER_SIZE 3

var/datum/broadcast_controller/broadcast_controls

/datum/controller/process/broadcasting
	var/list/autoschedule_channels

	setup()
		autoschedule_channels = list()
		name = "Broadcasting"
		schedule_interval = 0.5 SECONDS
		RegisterSignal(broadcast_controls, COMSIG_BROADCAST_STOPPED, PROC_REF(autoschedule))
		//a little hardcoding
		var/datum/directed_broadcast_scheduler/generic_stations/scheduler = new
		autoschedule_channels = list(TR_CAT_TEEVEE_BROADCAST_RECEIVERS = scheduler, TR_CAT_RADIO_BROADCAST_RECEIVERS = scheduler)
		for (var/a_channel as anything in autoschedule_channels)
			autoschedule(channel = a_channel) //A little bit silly at this stage, but once we have more than one scheduler running ever...

	doWork()
		broadcast_controls.process()

	proc/debug_autoschedule()
		for (var/a_channel as anything in autoschedule_channels)
			autoschedule(channel = a_channel)
//fill continuously broadcasting channels with crap as they go through
/datum/controller/process/broadcasting/proc/autoschedule(ended_broadcast = null, channel, programming_buffer = 0)
	if (!(channel in autoschedule_channels))
		return
	if (programming_buffer >= MINIMUM_BUFFER_SIZE)
		return

	var/datum/directed_broadcast_scheduler/scheduler = autoschedule_channels[channel]
	scheduler.fill_schedule(channel)

#undef MINIMUM_BUFFER_SIZE
