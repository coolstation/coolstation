/mob/living/critter/repairbot
	name = "odd thingmabob"
	real_name = "odd thingmabob"
	desc = "A Security Robot, something seems a bit off."
	density = 1
	icon = 'icons/mob/critter.dmi'
	icon_state = "ancient_guardbot"
	custom_gib_handler = /proc/robogibs
	say_language = "binary"
	voice_name = "synthesized voice"
	hand_count = 1
	can_throw = 0
	can_grab = 0
	can_disarm = 0
	blood_id = "oil"
	speechverb_say = "beeps"
	speechverb_gasp = "chirps"
	speechverb_stammer = "beeps"
	speechverb_exclaim = "beeps"
	speechverb_ask = "beeps"
	metabolizes = 0
	robotic = TRUE
	takes_tox = FALSE
	takes_brain = FALSE
	health_brute = 30
	health_brute_vuln = 1
	health_burn = 30
	health_burn_vuln = 1

	understands_language(var/langname)
		if (langname == say_language || langname == "silicon" || langname == "binary" || langname == "english")
			return 1
		return 0

	New()
		..()
		src.name = "[pick("strange","weird","odd","bizarre","quirky","antique")] [pick("robot","automaton","machine","gizmo","thingmabob","doodad","widget")]"
		src.real_name = src.name

	process_language(var/message)
		var/datum/language/L = languages.language_cache[say_language]
		if (!L)
			L = languages.language_cache["english"]
		return L.get_messages(message, (1 - health / max_health) * 16)

	death(var/gibbed)
		elecflash(src,power = 3)
		..()
		ghostize()
		qdel(src)

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
		HH.limb = new /datum/limb/arcflash
		HH.name = "Electric Intruder Countermeasure"
		HH.icon = 'icons/ui/critter_ui.dmi'
		HH.icon_state = "handzap"
		HH.limb_name = "Electric Intruder Countermeasure"
		HH.can_hold_items = 0
		HH.can_attack = 0
		HH.can_range_attack = 1
