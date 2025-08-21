/mob/living/critter/gnome
	name = "gnome"
	desc = "A horrifying sewer-dwelling shapeshifter. The hat and clothes are made of chitin."
	icon_state = "gnome"
	can_help = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	can_throw = TRUE
	flags = TABLEPASS
	fits_under_table = TRUE
	reagent_capacity = 100
	hand_count = 2
	speechverb_say = "hisses"
	speechverb_exclaim = "screams"
	speechverb_ask = "hisses"
	say_language = "english"
	base_move_delay = 1.66
	base_walk_delay = 3
	stepsound = "sound/misc/step/step_gnome_1.ogg"
	pass_through_mobs = TRUE
	health_brute = 30
	health_brute_vuln = 1
	health_burn = 30
	health_burn_vuln = 1.5

	New()
		..()
		src.abilityHolder = new /datum/abilityHolder/composite(src)
		var/datum/abilityHolder/composite/composite_holder = src.abilityHolder
		composite_holder.addHolder(/datum/abilityHolder/gnome)
		ON_COOLDOWN(src, "gnome_laugh", 30 SECONDS)

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears(src)
		. = ..()

	Life(datum/controller/process/mobs/parent)
		if(..(parent))
			return 1

		if(prob(10) && !ON_COOLDOWN(src, "gnome_laugh", 20 SECONDS))
			SPAWN_DBG(rand(0,20))
				if(src)
					src.emote("laugh", 0)

	specific_emotes(var/act, var/param = null, var/voluntary = 1)
		switch (act)
			if ("laugh")
				if (src.emote_check(voluntary, 50))
					playsound(src, "sound/misc/gnomechuckle.ogg", 50, 1, 0.5, channel=VOLUME_CHANNEL_EMOTE)
					return "<span class='emote'><b>[src]</b> chuckles!</span>"
		return ..()

	Move(var/turf/NewLoc, direct)
		src.footstep = 10
		. = ..()
		// handles 8dir diagonals
		src.set_dir(direct)

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		. = ..()
		if(isturf(hit_atom) && !hit_atom.density)
			return
		if(prob(75) || thr.get_throw_travelled() < 3)
			playsound(src.loc, "sound/impact_sounds/Wet_Gnome_Thud.ogg", 60, 1)
			src.visible_message(SPAN_COMBAT("[src] slams against [hit_atom] and makes a loud thud!"))
		else
			playsound(src.loc, "sound/impact_sounds/Wet_Gnome_Scream.ogg", 60, 0)
			src.visible_message(SPAN_COMBAT("[src] slams against [hit_atom] and screams in agony!"))

/mob/living/critter/gnome/ai_controlled
	is_npc = 1

	New()
		..()
		src.ai = new /datum/aiHolder/gnome(src)
		remove_lifeprocess(/datum/lifeprocess/blindness)
		remove_lifeprocess(/datum/lifeprocess/viruses)

	death(var/gibbed)
		qdel(src.ai)
		src.ai = null
		reduce_lifeprocess_on_death()
		..()

/obj/gnome_hole
	name = "gnome manhole"
	desc = "A pit most foul, a horrid glimpse into the gnome hive."
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "gnomeholegaping"
	anchored = ANCHORED_ALWAYS
	event_handler_flags = USE_FLUID_ENTER | Z_ANCHORED
	plane = PLANE_FLOOR //They're supposed to be embedded in the floor.
	layer = TURF_LAYER
	bound_width = 64
	bound_height = 64

	ex_act()
		return

	bullet_act()
		return

	blob_act()
		return

	meteorhit()
		return

	attackby()
		return

	attack_hand()
		return
