
/mob/living/carbon/
	gender = MALE // WOW RUDE
	var/last_eating = 0

	var/oxyloss = 0
	var/toxloss = 0
	var/brainloss = 0
	//var/brain_op_stage = 0.0
	//var/heart_op_stage = 0.0

	infra_luminosity = 4
	var/poop_amount = 9

/mob/living/carbon/New()
	START_TRACKING
	. = ..()

/mob/living/carbon/disposing()
	STOP_TRACKING
	stomach_contents = null
	..()

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		//SLIP handling
		if (!src.throwing && !src.lying && isturf(NewLoc))
			var/turf/T = NewLoc
			if (T.turf_flags & MOB_SLIP)
				var/wet_adjusted = T.wet
				if (T.wet && traitHolder?.hasTrait("super_slips"))
					wet_adjusted = max(wet_adjusted, 2) //whee
				switch (wet_adjusted)
					if (1)
						if (locate(/obj/item/clothing/under/towel) in T)
							src.inertia_dir = 0
							T.wet = 0
							return
						if (src.slip())
							src.lastgasp()
							boutput(src, "<span class='notice'>You slipped on the wet floor!</span>")
							src.unlock_medal("I just cleaned that!", 1)
						else
							src.inertia_dir = 0
							return
					if (2) //lube
						src.pulling = null
						src.changeStatus("weakened", 3.5 SECONDS)
						src.lastgasp()
						boutput(src, "<span class='notice'>You slipped on the floor!</span>")
						playsound(T, "sound/misc/slip.ogg", 50, 1, -3)
						var/atom/target = get_edge_target_turf(src, src.dir)
						src.throw_at(target, 12, 1, throw_type = THROW_SLIP)
					if (3) // superlube
						src.pulling = null
						src.changeStatus("weakened", 6 SECONDS)
						playsound(T, "sound/misc/slip.ogg", 50, 1, -3)
						src.lastgasp()
						boutput(src, "<span class='notice'>You slipped on the floor!</span>")
						var/atom/target = get_edge_target_turf(src, src.dir)
						src.throw_at(target, 30, 1, throw_type = THROW_SLIP)
						random_brute_damage(src, 10)



/mob/living/carbon/relaymove(var/mob/user, direction)
	if(user in src.stomach_contents)
		if(prob(40))
			for(var/mob/M in hearers(4, src))
				if(M.client)
					M.show_message(text("<span class='alert'>You hear something rumbling inside [src]'s stomach...</span>"), 2)
			var/obj/item/I = user.equipped()
			if(I?.force)
				var/d = rand(floor(I.force / 4), I.force)
				src.TakeDamage("chest", d, 0)
				for(var/mob/M in viewers(user, null))
					if(M.client)
						M.show_message(text("<span class='alert'><B>[user] attacks [src]'s stomach wall with the [I.name]!</span>"), 2)
				playsound(user.loc, "sound/impact_sounds/Slimy_Hit_3.ogg", 50, 1)

				if(prob(get_brute_damage() - 50))
					src.gib()

/mob/living/carbon/gib(give_medal, include_ejectables)
	for(var/mob/M in src)
		if(M in src.stomach_contents)
			src.stomach_contents.Remove(M)
		if (!isobserver(M))
			src.visible_message("<span class='alert'><B>[M] bursts out of [src]!</B></span>")
		else if (istype(M, /mob/dead/target_observer))
			M.cancel_camera()

		M.set_loc(src.loc)
	. = ..(give_medal, include_ejectables)

/mob/living/carbon/proc/poop()
	if(ON_COOLDOWN(src, "poo", 20 MINUTES))
		boutput(src, "You don't feel ready to go.")
		return
	SPAWN_DBG(0.1 SECOND)
		var/mob/living/carbon/human/H = src
		var/obj/item/reagent_containers/poo_target = src.equipped()
		var/obj/item/reagent_containers/food/snacks/ingredient/mud/shit = new(src.loc, src.poop_amount)
		shit.owner = src // this is your shit.
		if(src.poops)
			src.poops--
		if(!istype(H)) // just in case something unhuman poops, lets still make a turd.
			var/turf/T = get_turf(src)
			if (istype(T))
				make_cleanable( /obj/decal/cleanable/tracked_reagents/mud,T)
			return
		playsound(H, "sound/voice/hoooagh2.ogg", 50, 0, 0, H.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
		if(H.wear_suit || H.w_uniform) // wearing pants while shitting? fine!!
			if(H.bioHolder.HasEffect("teflon_colon") || H.traitHolder.hasTrait("teflon_colon"))
				if(prob(10))
					H.visible_message("<span class='alert'><B>[H] fires the poop cannon, right through [his_or_her(H)] pants!</B></span>")
					playsound(H, "sound/effects/ExplosionFirey.ogg", 45, 1)
				else
					H.visible_message("<span class='alert'><B>[H] turds right through [his_or_her(H)] clothing!</B></span>")
					playsound(H, "sound/effects/splort.ogg", 75, 1)
				yeetapoop(H, shit)

				// ... also set suit/uniform to bottomless? I dunno
			else
				H.visible_message("<span class='alert'><B>[H] shits [his_or_her(H)] pants!</B></span>")
			H.wiped = 0 //+1 trait idea: nothin' but net
			if(H.w_uniform)
				H.w_uniform.add_mud(H, H.poop_amount ? H.poop_amount : 15)
			else
				H.wear_suit?.add_mud(H, H.poop_amount ? H.poop_amount : 15)
			H.set_clothing_icon_dirty() //ur a shitter
			playsound(H, H.sound_fart, 50, 0, 0, H.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
			return

		else
			if(istype(poo_target) && poo_target.reagents && poo_target.reagents.total_volume < poo_target.reagents.maximum_volume && poo_target.is_open_container())
				H.visible_message("<span class='alert'><B>[H] tries to shit in [poo_target]!</B></span>")
				playsound(H, H.sound_fart, 50, 0, 0, H.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
				if(prob(H.bioHolder.HasEffect("clumsy")?75:25))//clowns are bad at shitting in containers
					H.visible_message("<span class='alert'><B>[H] misses the container!</B></span>")
					shit.throw_impact(H)
				else
					playsound(src.loc, "sound/impact_sounds/Slimy_Hit_4.ogg", 100, 1)
					poo_target.reagents.add_reagent("poo",\
						(H.poop_amount ? H.poop_amount : 15))
					qdel(shit)
				H.cleanhands = 0
				H.wiped = 0
			else
				if(H.bioHolder.HasEffect("teflon_colon") || H.traitHolder.hasTrait("teflon_colon"))
					yeetapoop(H, shit)
				else
					shit.set_loc(src.loc)
					H.visible_message("<span class='alert'><B>[H] [pick("takes a dump","drops a turd","shits a load","does a poo","craps all over","plops a deuce","splats a shit","shits a stinker", \
					"funges an ape","leaves a log","releases [his_or_her(H)] bowel contents","excretes some feces","poops a pepperoni","is shittsing","fertilizes the floor")]!</B></span>")
					H.wiped = 0

		return

/mob/living/carbon/proc/yeetapoop(mob/living/carbon/C, var/obj/item/reagent_containers/food/snacks/ingredient/mud/shit)
	// Yeet a loaf in the opposite direction from where we're facing
	var/target_dir = NORTH

	switch(C.dir)
		if(NORTH)
			target_dir = SOUTH
		if(EAST)
			target_dir = WEST
		if(WEST)
			target_dir = EAST

	shit.loc = C.loc
	shit.throw_at(get_turf(get_steps(C, target_dir, rand(2,5))), rand(2,5), rand(1,4))
	C.visible_message("<span class='alert'><b>[C] [pick("hurls a loaf",\
		"unloads at speed", "lobs a loaf", "shits with gusto", \
		"shits with gutso", "fires the poo-cannon", "nukes a dookie", \
		"blasts [his_or_her(C)] bowels", "fires a full broadside", "shits really, REALLY hard")]!</b></span>")



/mob/living/carbon/proc/urinate()
	SPAWN_DBG(0)
		var/obj/item/reagent_containers/pee_target = src.equipped()
		if(istype(pee_target) && pee_target.reagents && pee_target.reagents.total_volume < pee_target.reagents.maximum_volume && pee_target.is_open_container())
			src.visible_message("<span class='alert'><B>[src] pees in [pee_target]!</B></span>")
			playsound(src, "sound/misc/pourdrink.ogg", 50, 1)
			pee_target.reagents.add_reagent("urine", 4)
			src.cleanhands = 0 //probably made a mess, gross, wash em
			return

		// possibly change the text colour to the gray emote text
		src.visible_message(pick("<B>[src]</B> unzips their pants and pees on the floor.", "<B>[src]</B> pisses all over the floor!", "<B>[src]</B> makes a big piss puddle on the floor."))
		src.cleanhands = 0
		var/obj/decal/cleanable/urine/U = make_cleanable(/obj/decal/cleanable/urine, src.loc)

		// Flag the urine stain if the pisser is trying to make fake initropidril
		if(src.reagents.has_reagent("tongueofdog"))
			U.thrice_drunk = 4
		else if(src.reagents.has_reagent("woolofbat"))
			U.thrice_drunk = 3
		else if(src.reagents.has_reagent("toeoffrog"))
			U.thrice_drunk = 2
		else if(src.reagents.has_reagent("eyeofnewt"))
			U.thrice_drunk = 1


		// check for being in sight of a working security camera

		if(seen_by_camera(src) && ishuman(src))

			// determine the name of the perp (goes by ID if wearing one)
			var/perpname = src.name
			if(src:wear_id && src:wear_id:registered)
				perpname = src:wear_id:registered
			// find the matching security record
			for(var/datum/data/record/R in data_core.general)
				if(R.fields["name"] == perpname)
					for (var/datum/data/record/S in data_core.security)
						if (S.fields["id"] == R.fields["id"])
							// now add to rap sheet

							S.fields["criminal"] = "*Arrest*"
							S.fields["mi_crim"] = "Public urination."

							break



/mob/living/carbon/swap_hand()
	var/obj/item/grab/block/B = src.check_block(ignoreStuns = 1)
	if(B)
		qdel(B)
	src.hand = !src.hand

/mob/living/carbon/lastgasp(allow_dead=FALSE,overrideGrunt=FALSE,customGrunt=null)
	if(!overrideGrunt)
		..(allow_dead, grunt=pick("NGGH","OOF","UGH","ARGH","BLARGH","BLUH","URK") )
	else
		..(allow_dead, grunt=customGrunt)

/mob/living/carbon/full_heal()
	src.remove_ailments()
	src.take_toxin_damage(-INFINITY)
	src.take_oxygen_deprivation(-INFINITY)
	src.change_misstep_chance(-INFINITY)
	if (src.reagents)
		src.reagents.clear_reagents()
		src.reagents.stop_combusting()
	..()

/mob/living/carbon/take_brain_damage(var/amount)
	if (..())
		return

	if (src.traitHolder && src.traitHolder.hasTrait("reversal"))
		amount *= -1

	src.brainloss = max(0,min(src.brainloss + amount,120))

	if (src.brainloss >= 120 && isalive(src))
		// instant death, we can assume a brain this damaged is no longer able to support life
		src.visible_message("<span class='alert'><b>[src.name]</b> goes limp, their facial expression utterly blank.</span>")
		src.death()
		return

	return

/mob/living/carbon/take_toxin_damage(var/amount)
	if (!toxloss && amount < 0)
		amount = 0
	if (..())
		return

	if (src.traitHolder && src.traitHolder.hasTrait("reversal"))
		amount *= -1

	if (src.bioHolder && src.bioHolder.HasEffect("resist_toxic"))
		src.toxloss = 0
		return 1 //prevent organ damage

	src.toxloss = max(0,src.toxloss + amount)
	return

/mob/living/carbon/take_oxygen_deprivation(var/amount)
	if (!oxyloss && amount < 0)
		return
	if (..())
		return

	if (HAS_MOB_PROPERTY(src, PROP_BREATHLESS))
		src.oxyloss = 0
		return

	src.oxyloss = max(0,src.oxyloss + amount)
	return

/mob/living/carbon/lose_breath(var/amount)
	if (..())
		return

	if (!losebreath && amount < 0)
		return

	if (ischangeling(src) || HAS_MOB_PROPERTY(src, PROP_BREATHLESS))
		src.losebreath = 0
		return

	src.losebreath = max(0,src.losebreath + amount)
	return

/mob/living/carbon/get_brain_damage()
	return src.brainloss

/mob/living/carbon/get_toxin_damage()
	return src.toxloss

/mob/living/carbon/get_oxygen_deprivation()
	return src.oxyloss

