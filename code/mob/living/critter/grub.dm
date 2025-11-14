/mob/living/critter/grub
	name = "grub"
	real_name = "grub"
	desc = "The perfectly generic grub."
	icon = 'icons/mob/grub.dmi'
	icon_state = "grub" //longgrub and deathgrub exist as sprites but those are separate from the entire overlay system
	icon_state_dead = "grub-dead"
	speechverb_say = "slobbers"
	speechverb_exclaim = "squelches"
	speechverb_ask = "squirms"
	density = 0
	custom_gib_handler = /proc/gibs
	can_throw = 1
	lie_on_death = 0
	butcherable = 1
	name_the_meat = 0
	max_skins = 1
	meat_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/grubmeat
	// blood_color = "#33C370" This doesn't work and I don't know enough to make it work.
	health_brute = 8 // these values are unchanged from critter base
	health_burn = 8
	flags = TABLEPASS
	fits_under_table = 1
	hand_count = 1
	var/body_color = 0
	var/head_color = 0
	var/eye_color = 0
	var/coat_wings = 0
	var/hat_antenna = 0
	var/body_hair = 0
	var/eyes_2 = 0

	base_move_delay = 2.3
	base_walk_delay = 4

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
		HH.limb = new /datum/limb/small_critter(src)
		HH.icon = 'icons/ui/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "pincers"
		HH.limb.name = "pincers"


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
			coat_wings = 1 //ideally these should make you float but idk how
			hat_antenna = 1
			body_hair = 1
			eyes_2 = 1
		..()

		src.setup_overlays()

	setup_overlays()

		var/image/overlay_head = image('icons/mob/grub.dmi', "head")
		overlay_head.color = head_color
		src.UpdateOverlays(overlay_head, "head")

		var/image/overlay_body = image('icons/mob/grub.dmi', "body")
		if(body_hair)
			overlay_body = image('icons/mob/grub.dmi', "body_hair")
		..()
		overlay_body.color = body_color
		src.UpdateOverlays(overlay_body, "body")

		var/image/overlay_eyes = image('icons/mob/grub.dmi', "eyes")
		if(eyes_2)
			overlay_eyes = image('icons/mob/grub.dmi', "eyes_2")
		..()
		overlay_eyes.color = eye_color
		src.UpdateOverlays(overlay_eyes, "eyes")

		if(hat_antenna)
			var/image/overlay_coat= image('icons/mob/grub.dmi', "hat_antenna")
			src.UpdateOverlays(overlay_coat, "hat")
		..()

		if(coat_wings)
			var/image/overlay_coat= image('icons/mob/grub.dmi', "coat_wings")
			src.UpdateOverlays(overlay_coat, "coat")
		..()

	death()
		src.ClearAllOverlays()

		var/image/overlay_head = image('icons/mob/grub.dmi', "head-dead")
		overlay_head.color = head_color
		src.UpdateOverlays(overlay_head, "head")

		var/image/overlay_body = image('icons/mob/grub.dmi', "body-dead")
		if(body_hair)
			overlay_body = image('icons/mob/grub.dmi', "body_hair-dead")
		..()
		overlay_body.color = body_color
		src.UpdateOverlays(overlay_body, "body")

		if(hat_antenna)
			var/image/overlay_hat = image('icons/mob/grub.dmi', "hat_antenna-dead")
			src.UpdateOverlays(overlay_hat, "hat")
		..()

		if(coat_wings)
			var/image/overlay_coat = image('icons/mob/grub.dmi', "coat_wings-dead")
			src.UpdateOverlays(overlay_coat, "coat")
		..()

	full_heal()
		..()
		src.ClearAllOverlays()
		src.setup_overlays()
