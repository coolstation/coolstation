//Maintenance arrears system
//Where machines will develop problems over the round if nobody goes and check on them
//But then again they might also be Fine, so don't worry about it :3

/*
How 2 expand to other machines:
-Give that machinery type MAY_REQUIRE_MAINT in its machinery_flags
-Put some interesting behaviour in the malfuction(mult) proc, which is called during process(). Will need power to malfunction.
-If your machine doesn't call the /obj/machinery process parent, do a check for src.status & MALFUNC somewhere appropriate
-Implement a way of fixing the thing once it's malfunctioning, probably in attackby or something. Call maintenance_resolve() in that spot.
-maintenance_resolve() is also the place to override if your machine needs some kind of cleanup. Call yer parent though!
*/


ABSTRACT_TYPE(/datum/random_event/minor/maintenance)
/datum/random_event/minor/maintenance
	disabled = FALSE //toggle for both

//The event that causes machinery on the routine maintenance list to start malfunctioning
//It's a minor event so that it might get additional random rolls on the minor event cycle, in addition to its bespoke rolls.
/datum/random_event/minor/maintenance/maintenance_breakdown
	name = "Maintenance Breakdown"
	weight = 50
	var/list/unmaintained_machines
	customization_available = TRUE

	New()
		..()
		unmaintained_machines = list()

	admin_call(var/source)
		if (..())
			return

		var/target_amount = input(usr, "How many machines should bork?", "Maintenance Breakdown", 1) as num|null
		if (target_amount)
			event_effect(source, target_amount)

	//amount = how many machines we break
	event_effect(source, amount = 2)
		..()
		amount = min(amount, length(unmaintained_machines))
		if (amount < 1)
			return
		var/fails = 0
		for (var/i in 1 to amount)
			var/obj/machinery/RIP = pick(unmaintained_machines)
			if (!istype(RIP))
				continue
			if (RIP.status & MALFUNC)
				elecflash(RIP)
				RIP.malfunction()
				fails++
				if (prob(90 - fails)) //small chance of not giving a mulligan just to make sure this will eventually fall through
					i--
				continue
			RIP.status |= MALFUNC
			if (prob(50))
				elecflash(RIP)
				RIP.malfunction()
			//Did we pull things that were already broken? Penalty time
			if (fails) //This partially exists to make sure there will be always be new things to break down if we manage to run out.
				random_events.force_event("Maintenance Arrears", "Existing Maintenance Failure Penalty", fails + rand(0,2), TRUE)

//Picks some new things that may break down soon in the other event. This one only shows up as a minor event
/datum/random_event/minor/maintenance/maintenance_new
	name = "Maintenance Arrears"
	//for centcom_headline see below
	centcom_message = "The NanoTrasen Station Maintenance Department has determined that some on-station equipment has not been properly maintained. The equipment in question may experience faults in the near future if the situation is not addressed. The engineering department has been given details on the affected equipment on their PDAs."
	customization_available = TRUE

	admin_call(var/source)
		if (..())
			return
		var/target_amount = input(usr, "How many machines should get on the shitlist?", "Maintenance Arrears", 20) as num|null
		if (target_amount)
			event_effect(source, target_amount)

	//amount = how many machines we try to add
	event_effect(source, amount = 0, suppress_report = FALSE)
		centcom_headline = suppress_report ? null : "Maintenance Required" //slight hack to avoid the non-random calls to this event from generating a centcomm report.
		..()
		if (amount < 1)
			amount = rand(2,4)
		for (var/i in 1 to amount)
			var/obj/machinery/RIP = pick(maintenance_eligible_machines)
			if (GET_COOLDOWN(RIP, "maintained"))
				continue
			if (!(RIP in random_events.maintenance_event.unmaintained_machines))
				random_events.maintenance_event.unmaintained_machines |= RIP


