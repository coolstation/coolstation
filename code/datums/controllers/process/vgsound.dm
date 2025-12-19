/**
 * copyright 2025 Inorien
 */

// This system's only job is to go over every active sound emitter every time it fires and push volume updates
datum/controller/process/sounds
	setup()
		name = "Sounds"
		schedule_interval = 0.5 SECONDS

	doWork()
		var/list/done = list()
		for (var/client/client in clients)
			if (!client.listener_context)
				continue
			for (var/datum/sound_emitter/E in client.listener_context.current_channels_by_emitter)
				if (done[E]) // only need to run update_active_sound_param once per emitter
					continue
				SPAWN_DBG(0)
					// recalc volume and such for when player/emitter isn't raising move signals
					E.update_active_sound_param()
					done[E] = TRUE
