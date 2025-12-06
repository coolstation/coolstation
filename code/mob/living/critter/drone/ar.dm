/mob/living/critter/robotic/drone/ar
	drone_designation = "AR"
	desc = "A highly dangerous Syndicate artillery drone."
	icon_state = "drone5"
	alert_sounds = list('sound/machines/engine_alert1.ogg')

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/artillery(src)
		HH.name = "S-42 Long Range Explosive Shells"
		HH.icon = 'icons/ui/critter_ui.dmi'
		HH.icon_state = "handart"
		HH.limb.name = "S-42 Long Range Explosive Shells"
		HH.can_hold_items = 0
		HH.can_attack = 0
		HH.can_range_attack = 1

	setup_loot_table()
		..()
		loot_table[/obj/item/shipcomponent/secondary_system/crash] = 100
