/mob/living/critter/grub
	name = "grub"
	real_name = "grub"
	desc = "The perfectly generic grub."
	icon = 'icons/mob/grub.dmi'
	icon_state = "grub" //longgrub and deathgrub exist as sprites but those are separate from the entire overlay system
	icon_state_dead = "grub-dead"
	speechverb_say = "slobbers"
	speechverb_exclaim = "squelches"
	speechverb_ask = "squrims"
	density = 0
	custom_gib_handler = /proc/gibs
	can_help = 1
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	butcherable = 1 //leftover from critter copy-paste. There's independent grubmeat sprites in the dmi
	name_the_meat = 1
	max_skins = 1
	var/health_brute = 20 // these values are unchanged from critter base. Do I still need these???? I don't know
	var/health_brute_vuln = 1
	var/health_burn = 20
	var/health_burn_vuln = 1
	health_brute = 8 // these values are unchanged from critter base
	health_burn = 8
	hand_count = 1
	var/body_color = 0
	var/head_color = 0
	var/eye_color = 0
	var/wings = 0
	var/antenna = 0
	var/hair = 0
	var/eyes2 = 0

	var/is_pet = null // null = autodetect

	New(loc) //Beyond here I'm not sure how much is actually needed. Most of the overlay stuff is in the wild grub defines but I don't wanna break anything
		if(isnull(src.is_pet))
			src.is_pet = (copytext(src.name, 1, 2) in uppercase_letters)
		if(in_centcom(loc) || current_state >= GAME_STATE_PLAYING)
			src.is_pet = 0
		if(src.is_pet)
			START_TRACKING_CAT(TR_CAT_PETS)
		..()

		src.add_stam_mod_max("grub", -(STAMINA_MAX*0.5))

	disposing()
		if(src.is_pet)
			STOP_TRACKING_CAT(TR_CAT_PETS)
		..()

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)
		add_health_holder(/datum/healthHolder/toxin)
		add_health_holder(/datum/healthHolder/brain)

	CanPass(atom/mover, turf/target, height=0, air_group=0)
		if (!src.density && istype(mover, /obj/projectile))
			return prob(50)
		else
			return ..()

	death(var/gibbed)
		if (!gibbed)
			src.unequip_all()
		..()

	canRideMailchutes()
		return src.fits_under_table

	proc/reduce_lifeprocess_on_death() //used for AI mobs we dont give a dang about them after theyre dead
		remove_lifeprocess(/datum/lifeprocess/blood)
		remove_lifeprocess(/datum/lifeprocess/canmove)
		remove_lifeprocess(/datum/lifeprocess/disability)
		remove_lifeprocess(/datum/lifeprocess/fire)
		remove_lifeprocess(/datum/lifeprocess/hud)
		remove_lifeprocess(/datum/lifeprocess/mutations)
		remove_lifeprocess(/datum/lifeprocess/organs)
		remove_lifeprocess(/datum/lifeprocess/sight)
		remove_lifeprocess(/datum/lifeprocess/skin)
		remove_lifeprocess(/datum/lifeprocess/statusupdate)

	specific_emotes(var/act, var/param = null, var/voluntary = 0) //Oh wait I remember these things are needed
		switch (act)
			if ("scream","chitter")
				if (src.emote_check(voluntary, 50))
					playsound(src, "sound/voice/animal/bugchitter.ogg", 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<span class='emote'><b>[src]</b> chitters!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","chitter")
				return 2
		return ..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "pincers"
		HH.limb_name = "pincers"


/mob/living/critter/grub/wildgrub //Wild grubs don't have any relevance to any domestic grub breeding stuff. It's just an excuse to show off all the funny overlays
	name = "wild grub"
	real_name = "wild grub"
	desc = "A lesser desert grub. These ones are non-domesticated and genetically normal. For now?"

	New()
		..()
		body_color =	pick("#101010", "#924D28", "#61301B", "#E0721D", "#D7A83D","#D8C078", "#E3CC88", "#F2DA91", "#F21AE", "#664F3C", "#8C684A", "#EE2A22", "#B89778", "#3B3024", "#A56b46")
		head_color =	pick("#101010", "#924D28", "#61301B", "#E0721D", "#D7A83D","#D8C078", "#E3CC88", "#F2DA91", "#F21AE", "#664F3C", "#8C684A", "#EE2A22", "#B89778", "#3B3024", "#A56b46")
		eye_color = "#FFFFF"
		if (prob(50)) //in wild grubs these would each independently have a small chance of being on. Domestic grubs would have these expressed via the whole breeding thing
			wings = 1 //ideally these should make you float but idk how
			antenna = 1
			hair = 1
			eyes2 = 1
		..()
		src.setup_overlays()

	setup_overlays()
		var/image/overlay_body = image('icons/mob/grub.dmi', "body")
		overlay_body.color = body_color
		src.UpdateOverlays(overlay_body, "body")

		var/image/overlay_head = image('icons/mob/grub.dmi', "head")
		overlay_head.color = head_color
		src.UpdateOverlays(overlay_head, "head")

		var/image/overlay_eyes = image('icons/mob/grub.dmi', "eyes")
		overlay_eyes.color = eye_color
		src.UpdateOverlays(overlay_eyes, "eyes")

		if(hair)
			var/image/overlay_hair = image('icons/mob/grub.dmi', "hair")
			overlay_hair.color = body_color
			src.UpdateOverlays(overlay_hair, "hair")
		..()

		if(wings)
			var/image/overlay_wings = image('icons/mob/grub.dmi', "wings")
			src.UpdateOverlays(overlay_wings, "wings")
		..()

		if(antenna)
			var/image/overlay_antenna = image('icons/mob/grub.dmi', "antenna")
			src.UpdateOverlays(overlay_antenna, "antenna")
		..()

		if(eyes2)
			var/image/overlay_eyes2 = image('icons/mob/grub.dmi', "eyes2")
			overlay_eyes2.color = eye_color
			src.UpdateOverlays(overlay_eyes2, "eyes2")
		..()

	death()
		src.ClearAllOverlays()
		var/image/overlay_body = image('icons/mob/grub.dmi', "body-dead")
		overlay_body.color = body_color
		src.UpdateOverlays(overlay_body, "body")
		var/image/overlay_head = image('icons/mob/grub.dmi', "head-dead")
		overlay_head.color = head_color
		src.UpdateOverlays(overlay_head, "head")
		if(wings)
			var/image/overlay_wings = image('icons/mob/grub.dmi', "wings-dead")
			src.UpdateOverlays(overlay_wings, "wings")
		..()

		if(hair)
			var/image/overlay_hair = image('icons/mob/grub.dmi', "hair-dead")
			overlay_hair.color = body_color
			src.UpdateOverlays(overlay_hair, "hair")
		..()

		if(antenna)
			var/image/overlay_antenna = image('icons/mob/grub.dmi', "antenna-dead")
			src.UpdateOverlays(overlay_antenna, "antenna")
		..()

	full_heal()
		..()
		src.ClearAllOverlays()
		src.setup_overlays()
