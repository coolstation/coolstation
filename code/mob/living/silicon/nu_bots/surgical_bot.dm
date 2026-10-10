/mob/living/silicon/nubot/surgical_bot
	var/playing = FALSE


	proc/move_sound() //this just makes the sound have a cooldown so diagonals dont play 2x the sounds
		if(playing == FALSE)
			if(src.pulling)
				playsound(src, "sound/machines/motor_whir.ogg", 10, 0, pitch = 1 * src.pulling.p_class)
			else
				playsound(src, "sound/machines/motor_whir.ogg", 10, 0)
			playing = TRUE
			SPAWN_DBG(0.1 SECOND)
				playing = FALSE
				return
		else
			return

	Move()
		. = ..()
		move_sound()
