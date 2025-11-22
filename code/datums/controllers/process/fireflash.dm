/// Handles fireflashes (non-atmos hotspots)
/datum/controller/process/fireflash

	setup()
		name = "Fireflashes"
		schedule_interval = 1 SECOND

	doWork()
		for(var/obj/hotspot/fireflash/FF in global.fireflashes)
			FF.process()

			scheck()
