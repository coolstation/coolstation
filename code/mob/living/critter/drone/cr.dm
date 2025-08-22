/mob/living/critter/drone/cr
	drone_designation = "CR"
	desc = "A Syndicate scrap cutter drone, designed for automated salvage operations."
	icon_state = "drone4"
	health_brute = 100
	health_burn = 100

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/cutter(src)
		HH.name = "C-4 Salvager Sawdrill"
		HH.icon = 'icons/ui/critter_ui.dmi'
		HH.icon_state = "handcr"
		HH.limb.name = "C-4 Salvager Sawdrill"
		HH.can_hold_items = 0
		HH.can_attack = 0
		HH.can_range_attack = 1
