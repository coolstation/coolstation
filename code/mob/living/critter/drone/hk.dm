/mob/living/critter/robotic/drone/hk
	drone_designation = "HK"
	desc = "A heavily-armed Syndicate hunter-killer drone."
	icon_state = "drone2"
	health_brute = 200
	health_burn = 200

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/disruptor(src)
		HH.name = "S-7 Heavy Waveform Disruptor"
		HH.icon = 'icons/ui/critter_ui.dmi'
		HH.icon_state = "handdis"
		HH.limb.name = "S-7 Heavy Waveform Disruptor"
		HH.can_hold_items = 0
		HH.can_attack = 0
		HH.can_range_attack = 1
