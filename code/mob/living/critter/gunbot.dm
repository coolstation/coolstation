/mob/living/critter/robotic/gunbot
	name = "robot"
	real_name = "robot"
	desc = "A Security Robot, something seems a bit off."
	density = 1
	icon = 'icons/mob/critter.dmi'
	icon_state = "mars_sec_bot"
	custom_gib_handler = /proc/robogibs
	hand_count = 3
	can_throw = 0
	blood_id = "oil"
	speechverb_say = "states"
	speechverb_gasp = "states"
	speechverb_stammer = "states"
	speechverb_exclaim = "declares"
	speechverb_ask = "queries"
	robotic = TRUE
	health_brute = 60
	health_brute_vuln = 1
	health_burn = 60
	health_burn_vuln = 1
	metabolizes = 0

	death(var/gibbed)
		..(gibbed, 0)
		if (!gibbed)
			playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 100, 1)
			make_cleanable(/obj/decal/cleanable/oil,src.loc)
			ghostize()
			qdel(src)
		else
			playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 100, 1)
			make_cleanable(/obj/decal/cleanable/oil,src.loc)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, "sound/voice/screams/robot_scream.ogg" , 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> screams!"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears/intercom(src)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/arm38(src)
		HH.name = ".38 Anti-Personnel Arm"
		HH.icon = 'icons/ui/critter_ui.dmi'
		HH.icon_state = "hand38"
		HH.limb.name = ".38 Anti-Personnel Arm"
		HH.can_hold_items = 0
		HH.can_attack = 0
		HH.can_range_attack = 1

		HH = hands[2]
		HH.limb = new /datum/limb/gun/abg(src)
		HH.name = "ABG Riot Suppression Appendage"
		HH.icon = 'icons/ui/critter_ui.dmi'
		HH.icon_state = "handabg"
		HH.limb.name = "ABG Riot Suppression Appendage"
		HH.can_hold_items = 0
		HH.can_attack = 0
		HH.can_range_attack = 1

		HH = hands[3]
		HH.limb = new /datum/limb/small_critter/strong(src)
		HH.icon = 'icons/ui/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "gunbothand"
		HH.limb.name = "gunbot hands"

	get_melee_protection(zone, damage_type)
		return 6

	get_ranged_protection()
		return 2

	get_disorient_protection()
		return max(..(), 80)
