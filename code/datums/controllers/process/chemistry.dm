
/// Handles chemistry reactions
/datum/controller/process/chemistry

	setup()
		name = "Chemistry"
		schedule_interval = 1 SECOND

	doWork()
		for(var/datum/d in active_reagent_holders)
			d:process_reactions()
			scheck()
		RL_Suspend()
		for(var/datum/d in combusting_reagent_holders)
			d:process_combustion()
			scheck()
		RL_Resume()
