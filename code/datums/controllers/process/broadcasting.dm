var/datum/broadcast_controller/broadcast_controls

/datum/controller/process/broadcasting
	setup()
		name = "Broadcasting"
		schedule_interval = 0.5 SECONDS

	doWork()
		broadcast_controls.process()
