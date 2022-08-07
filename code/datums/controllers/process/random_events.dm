
/// handles random events
datum/controller/process/randomevents
	hang_warning_time = 5 MINUTES
	hang_alert_time = 5.5 MINUTES
	hang_restart_time = 6 MINUTES

	setup()
		name = "Random Events"
		schedule_interval = 20 SECONDS //Was 2.5 MINUTES before admin warnings necessitated something finer

	doWork()
		random_events.process()
