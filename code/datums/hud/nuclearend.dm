datum/hud/nuclear
	click_check = 0
	var/atom/movable/screen/countdown

	New()

		src.countdown = create_screen("nuclear", "Nuclear Countdown", null, "", "NORTH,CENTER", HUD_LAYER_3)
		countdown.maptext = ""
		countdown.maptext_width = 480
		countdown.maptext_x = -(480 / 2) + 16
		countdown.maptext_y = -320
		countdown.maptext_height = 320
		countdown.plane = 100
		..()

	proc/update_time(var/seconds)
		countdown.maptext = "<span class='c ol vga vt' style='background: #00000080;'>Your employment contract will end in<br><span style='font-size: 24px;'>[seconds]</span></span>"
