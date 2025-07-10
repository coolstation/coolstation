//human emotes that are just Big
/*
Contents:
fart (bio)
dance
flip
urinate
dab

BTW when datumising I did fairly little to these beyond a src->user find/replace, figuring they're pretty bespoke
So if shit breaks, that's why. I excised about 2k lines into all these emote datums and I wasn't gonna clean it all up
*/


/datum/emote/fart/bio
	cooldown = 1 SECOND

/datum/emote/fart/bio/return_cooldown(mob/user, voluntary = 0)
	var/tempcooldown = cooldown
	if(user && user.reagents)
		if(user.reagents.combustible_pressure)
			tempcooldown = 4*tempcooldown // farting out fire is hard
		if(user.reagents.has_reagent("egg"))
			tempcooldown = 0.9*tempcooldown
		if(user.reagents.has_reagent("fartonium"))
			tempcooldown = 0.8*tempcooldown
		if(user.reagents.has_reagent("refried_beans"))
			tempcooldown = 0.9*tempcooldown
		return tempcooldown
	else
		return cooldown

/datum/emote/fart/bio/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user)) return //get_organ, organ_istype, fart sounds
	var/oxyplasmafart = 0
	var/message = null
	var/m_type
	var/firepower = 0
	if (farting_allowed && (!user.reagents || !user.reagents.has_reagent("anti_fart")))
		if (!user.get_organ("butt"))
			m_type = MESSAGE_VISIBLE
			if (prob(10))
				switch(rand(1, 5))
					if (1) message = "<B>[user]</B> purses [his_or_her(user)] lips and makes a wet sound. It's not very convincing."
					if (2) message = "<B>[user]</B> quietly peels some eggs. <B>Ugh!</B> what a <i>smell!</i>"
					if (3) message = "<B>[user]</B> does some armpit singing. Rude."
					if (4) message = "<B>[user]</B> manages to blow one out- but it goes <i>right back in!</i>"
					if (5)
						message = "<span class='alert'><B>[user]</B> grunts so hard [he_or_she(user)] tears a ligament!</span>"
						user.emote("scream")
						random_brute_damage(user, 20)
			else
				message = "<B>[user]</B> grunts for a moment. Nothing happens."
		else
			if(user.reagents && user.reagents.combustible_pressure)
				firepower = ceil(user.reagents.combustible_pressure) // 1 to 10
			m_type = MESSAGE_AUDIBLE
			var/fart_loudness = 50 + firepower * 2

			if(user.reagents.has_reagent("egg"))
				fart_loudness += 5
			if(user.reagents.has_reagent("fartonium"))
				fart_loudness += 15
			if(user.reagents.has_reagent("refried_beans"))
				fart_loudness += 5

			if (iscluwne(user))
				playsound(user, "sound/voice/farts/poo.ogg", fart_loudness, 1, channel=VOLUME_CHANNEL_EMOTE)
			else if (user.organ_istype("butt", /obj/item/clothing/head/butt/cyberbutt))
				playsound(user, "sound/voice/farts/poo2_robot.ogg", fart_loudness, 1, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
			else if (user.reagents && user.reagents.has_reagent("honk_fart"))
				playsound(user.loc, 'sound/musical_instruments/Bikehorn_1.ogg', fart_loudness, 1, -1, channel=VOLUME_CHANNEL_EMOTE)
			else
				if (narrator_mode)
					playsound(user, 'sound/vox/fart.ogg', fart_loudness, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
				else
					if (user.getStatusDuration("food_deep_fart"))
						playsound(user, user.sound_fart, fart_loudness, 0, 0, user.get_age_pitch() - 0.3, channel=VOLUME_CHANNEL_EMOTE)
					else
						playsound(user, user.sound_fart, fart_loudness, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)

			var/fart_on_other = 0
			for (var/atom/A as anything in user.loc)
				if (A.event_handler_flags & IS_FARTABLE)
					var/mob/living/M
					if (istype(A,/mob/living))
						M = A
						if (M == user || !M.lying)
							continue
						if(firepower >= 3)
							M.changeStatus("burning",firepower * 3 SECONDS)
						message = "<span class='alert'><B>[user]</B> farts in [M]'s face!</span>"
						if (ishuman(user))
							var/mob/living/carbon/human/H = user
							if (H.sims)
								H.sims.affectMotive("fun", 4)
						if (user.mind)
							if (M.mind && M.mind.assigned_role == "Geneticist")
								user.add_karma(10)
							if (M.mind && M.mind.assigned_role == "Clown")
								user.add_karma(1)
#ifdef DATALOGGER
								game_stats.Increment("clownabuse")
#endif
						fart_on_other = 1
						break
					else if (istype(A,/obj/item/storage/bible))
						var/obj/item/storage/bible/B = A
						B.farty_heresy(user)
						fart_on_other = 1
						break
					else if (istype(A,/obj/item/book_kinginyellow))
						var/obj/item/book_kinginyellow/K = A
						K.farty_doom(user)
						fart_on_other = 1
						break
					else if (istype(A,/obj/item/photo/voodoo))
						var/obj/item/photo/voodoo/V = A
						M = V.cursed_dude
						if (!M || !M.lying)
							continue
						playsound(M, user.sound_fart, 20, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
						switch(rand(1, 7))
							if (1) M.visible_message("<span class='emote'><b>[M]</b> suddenly radiates an unwelcoming odor.</span>")
							if (2) M.visible_message("<span class='emote'><b>[M]</b> is visited by ethereal incontinence.</span>")
							if (3) M.visible_message("<span class='emote'><b>[M]</b> experiences paranormal gastrointestinal phenomena.</span>")
							if (4) M.visible_message("<span class='emote'><b>[M]</b> involuntarily telecommutes to the farty party.</span>")
							if (5) M.visible_message("<span class='emote'><b>[M]</b> is swept over by a mysterious draft.</span>")
							if (6) M.visible_message("<span class='emote'><b>[M]</b> abruptly emits an odor of cheese.</span>")
							if (7) M.visible_message("<span class='emote'><b>[M]</b> is set upon by extradimensional flatulence.</span>")
						if (ishuman(user))
							var/mob/living/carbon/human/H = user
							if (H.sims)
								H.sims.affectMotive("fun", 4)
						//break deliberately omitted
			var/accident = FALSE
			if (!fart_on_other)
				switch(rand(1, 42))
					if (1) message = "<B>[user]</B> lets out a little 'toot' from [his_or_her(user)] butt."
					if (2) message = "<B>[user]</B> farts loudly!"
					if (3) message = "<B>[user]</B> lets one rip!"
					if (4) message = "<B>[user]</B> farts! It sounds wet and smells like rotten eggs."
					if (5) message = "<B>[user]</B> farts robustly!"
					if (6) message = "<B>[user]</B> farted! It smells like something died."
					if (7) message = "<B>[user]</B> farts like a muppet!"
					if (8) message = "<B>[user]</B> defiles the station's air supply."
					if (9) message = "<B>[user]</B> farts a ten second long fart."
					if (10) message = "<B>[user]</B> groans and moans, farting like the world depended on it."
					if (11) message = "<B>[user]</B> breaks wind!"
					if (12) message = "<B>[user]</B> expels intestinal gas through the anus."
					if (13) message = "<B>[user]</B> release an audible discharge of intestinal gas."
					if (14) message = "<B>[user]</B> is a farting motherfucker!!!"
					if (15) message = "<B>[user]</B> suffers from flatulence!"
					if (16) message = "<B>[user]</B> releases flatus."
					if (17) message = "<B>[user]</B> releases methane."
					if (18) message = "<B>[user]</B> farts up a storm."
					if (19) message = "<B>[user]</B> farts. It smells like Soylent Surprise!"
					if (20) message = "<B>[user]</B> farts. It smells like pizza!"
					if (21) message = "<B>[user]</B> farts. It smells like Shitty Bill's perfume!"
					if (22) message = "<B>[user]</B> farts. It smells like the kitchen!"
					if (23) message = "<B>[user]</B> farts. It smells like medbay in here now!"
					if (24) message = "<B>[user]</B> farts. It smells like the bridge in here now!"
					if (25) message = "<B>[user]</B> farts like a pubby!"
					if (26) message = "<B>[user]</B> farts like a goone!"
					if (27)
						message = "<B>[user]</B> sharts! That's just nasty."
						if(user?.bioHolder.HasEffect("teflon_colon") || user?.traitHolder.hasTrait("teflon_colon"))
							user.poop()
							accident = TRUE
					if (28) message = "<B>[user]</B> farts delicately."
					if (29) message = "<B>[user]</B> farts timidly."
					if (30) message = "<B>[user]</B> farts very, very quietly. The stench is OVERPOWERING."
					if (31) message = "<B>[user]</B> farts egregiously."
					if (32) message = "<B>[user]</B> farts voraciously."
					if (33) message = "<B>[user]</B> farts cantankerously."
					if (34) message = "<B>[user]</B> fart in [he_or_she(user)] own mouth. A shameful [user]."
					if (35)
						message = "<B>[user]</B> farts out pure plasma! <span class='alert'><B>FUCK!</B></span>"
						oxyplasmafart = 1
					if (36)
						message = "<B>[user]</B> farts out pure oxygen. What the fuck did [he_or_she(user)] eat?"
						oxyplasmafart = 2
					if (37) message = "<B>[user]</B> breaks wind noisily!"
					if (38) message = "<B>[user]</B> releases gas with the power of the gods! The very station trembles!!"
					if (39) message = "<B>[user] <span style='color:red'>f</span><span style='color:blue'>a</span>r<span style='color:red'>t</span><span style='color:blue'>s</span>!</B>"
					if (40) message = "<B>[user]</B> laughs! [his_or_her(user)] breath smells like a fart."
					if (41) message = "<B>[user]</B> farts, and as such, blob cannot evoulate."
					if (42) message = "<b>[user]</B> farts. It might have been the Citizen Kane of farts."

			//pine fartens get in on the act as well
			for_by_tcl(F, /mob/living/critter/small_animal/meatslinky/pine_marten)
				if(!IN_RANGE(F, user, 4)) //if we can't find a marten within 4 tiles then move on
					continue
				F.fart_along() // chance for mart to fart

			if (user.bioHolder)
				var/toxic = user.bioHolder.HasEffect("toxic_farts")
				if (toxic)
					message = "<span class='alert'><B>[user] [pick("unleashes","rips","blasts")] \a [pick("truly","utterly","devastatingly","shockingly")] [pick("hideous","horrendous","horrific","heinous","horrible")] fart!</B></span>"
					var/turf/fart_turf = get_turf(user)
					fart_turf.fluid_react_single("[toxic > 1 ?"very_":""]toxic_fart", toxic*2, airborne = 1)

				if (user.bioHolder.HasEffect("linkedfart"))
					for(var/mob/living/H in mobs)
						if (H.bioHolder && H.bioHolder.HasEffect("linkedfart")) continue
						var/found_bible = 0
						for (var/atom/A as anything in H.loc)
							if (A.event_handler_flags & IS_FARTABLE)
								if (istype(A,/obj/item/storage/bible))
									found_bible = 1
						if (found_bible)
							user.visible_message("<span class='alert'><b>A mysterious force smites [user.name] for inciting blasphemy!</b></span>")
							user.gib()
						else
							H.emote("fart")

			var/turf/T = get_turf(user)
			if (T && T == user.loc)
				switch(firepower)
					if(10 to INFINITY) // perfectly timed
						logTheThing("bombing", user, user, "farts perfectly and causes a power 16 explosion at [showCoords(user.x, user.y, user.z)]")
						message = "<span class='alert'><b>[user] vents that ass like a fucking shuttle thruster!</b></span>"
						user.throw_at(get_edge_cheap(user, user.dir),rand(15,20),4)
						fireflash_s(T,3,user.reagents.composite_combust_temp)
						user.reagents.combustible_pressure *= 0.1
						SPAWN_DBG(0.2 SECONDS)
							explosion_new(user, T, 16) // if this isnt funny i dont know what is
					if(3 to 10)
						message = "<span class='alert'><b>[user]</b> lets out a powerful flaming fart!</span>"
						fireflash_s(T,floor(firepower / 2) - 1,user.reagents.composite_combust_temp)
						user.reagents.combustible_pressure *= 0.7
					if(1 to 3)
						message = "<B>[user]</B> lets out a tiny flaming fart!"
						fireflash_s(T,0,user.reagents.composite_combust_temp)

				if (T.turf_flags & CAN_BE_SPACE_SAMPLE)
					if (accident)
						if (HAS_MOB_PROPERTY(user, PROP_SPACEFARTS))
							user.throw_at(get_edge_cheap(T, user.dir), 30, 1)
					else
						if ((firepower > 2 && firepower < 10) || HAS_MOB_PROPERTY(user, PROP_SPACEFARTS))
							user.inertia_dir = user.dir
							//step(user, user.inertia_dir) <- seemed kinda unnecessary, you moved forward 2 tiles from one fart? - Bat
							SPAWN_DBG(1 DECI SECOND)
								user.inertia_dir = user.dir
								step(user, user.inertia_dir)
				else if(!firepower)
					if(prob(10) && istype(user.loc, /turf/floor/specialroom/freezer)) //ZeWaka: Fix for null.loc
						message = "<b>[user]</B> farts. The fart freezes in MID-AIR!!!"
						new/obj/item/material_piece/fart(user.loc)
						var/obj/item/material_piece/fart/F = new /obj/item/material_piece/fart
						F.set_loc(user.loc)

			if (ishuman(user))
				var/mob/living/carbon/human/M = user
				M.expel_fart_gas(oxyplasmafart)
				// If there is a chest item, see if it can be activated on fart (attack_self)
				if (M.chest_item != null) //Gotta do that pre-emptive runtime protection!
					M.chest_item_attack_self_on_fart()

			user.stamina_stun()
			fartcount++
			if(fartcount == 69 || fartcount == 420)
				var/obj/item/paper/grillnasium/fartnasium_recruitment/flyer/F = new(get_turf(user))
				user.put_in_hand_or_drop(F)
				message = ("<b>[user]</B> farts out a... wait is this viral marketing?")
			#if defined(MAP_OVERRIDE_POD_WARS)
			if (istype(ticker.mode, /datum/game_mode/pod_wars))
				var/datum/game_mode/pod_wars/mode = ticker.mode
				mode.stats_manager?.inc_farts(user)
			#endif
			#ifdef DATALOGGER
			game_stats.Increment("farts")
			#endif
	if(user.bioHolder && user.bioHolder.HasEffect("training_miner") && prob(1))
		var/glowsticktype = pick(typesof(/obj/item/device/light/glowstick))
		var/obj/item/device/light/glowstick/G = new glowsticktype
		G.set_loc(user.loc)
		G.turnon()
		var/turf/target = get_offset_target_turf(user.loc, (rand(5)-rand(5)), (rand(5)-rand(5)))
		G.throw_at(target,5,1)
		user.visible_message("<b>[user]</B> farts out a...glowstick?")

	if (message)
		return list(message, null, m_type)





/datum/emote/dance //The one, the only, the champion of all emotes (also boogie)
	possible_while_dead = TRUE //if you're porting this back to goon remove this line, but I want the corpses to dance
/datum/emote/dance/return_cooldown(mob/user)
	if (!ishuman(user))
		return 5 SECONDS
	var/mob/living/carbon/human/M = user
	if (istype(M.shoes, /obj/item/clothing/shoes/heels/dancin))
		return 1.5 SECONDS
	return 5 SECONDS

/datum/emote/dance/enact(mob/user, voluntary = 0, param)
	if (user.restrained())
		return list("<B>[user]</B> twitches feebly in time to music only [he_or_she(user)] can hear.", null, MESSAGE_VISIBLE)
	var/message = null
	if (iswizard(user) && prob(10))
		message = pick("<span class='alert'><B>[user]</B> breaks out the most unreal dance move you've ever seen!</span>", "<span class='alert'><B>[user]'s</B> dance move borders on the goddamn diabolical!</span>")
		user.say("GHEIT DAUN!")
		animate_flash_color_fill(user,"#5C0E80", 1, 10)
		animate_levitate(user, 1, 10)
		SPAWN_DBG(0) // some movement to make it look cooler
			for (var/i in 0 to 9)
				user.set_dir(turn(user.dir, 90))
				sleep(0.2 SECONDS)

		elecflash(user,power = 2)
	else
		//glowsticks
		var/left_glowstick = istype (user.l_hand, /obj/item/device/light/glowstick)
		var/right_glowstick = istype (user.r_hand, /obj/item/device/light/glowstick)
		var/obj/item/device/light/glowstick/l_glowstick = null
		var/obj/item/device/light/glowstick/r_glowstick = null
		if (left_glowstick)
			l_glowstick = user.l_hand
		if (right_glowstick)
			r_glowstick = user.r_hand
		if ((left_glowstick && l_glowstick.on) || (right_glowstick && r_glowstick.on))
			if (left_glowstick)
				particleMaster.SpawnSystem(new /datum/particleSystem/glow_stick_dance(user.loc))
			if (right_glowstick)
				particleMaster.SpawnSystem(new /datum/particleSystem/glow_stick_dance(user.loc))
			var/dancemove = rand(1,6)
			switch(dancemove)
				if (1)
					message = "<B>[user]</B> puts on a sick-ass lightshow!"
				if (2)
					message = "<B>[user]</B> waves a glowstick around in the air!"
				if (3)
					message = "<B>[user]</B> twirls a glowstick! Cool!"
				if (4)
					message = "<B>[user]</B> spins a glowstick! Trippy!"
				if (5)
					message = "<B>[user]</B> is the life of the party!"
				else
					message = "<B>[user]</B> is raving super hard!"
			SPAWN_DBG(0)
				for (var/i = 0, i < 4, i++)
					user.set_dir(turn(user.dir, 90))
					sleep(0.2 SECONDS)
		//standard dancing
		else
			var/dancemove = rand(1,7)

			switch(dancemove)
				if (1)
					message = "<B>[user]</B> busts out some mad moves."
					SPAWN_DBG(0)
						for (var/i = 0, i < 4, i++)
							user.set_dir(turn(user.dir, 90))
							sleep(0.2 SECONDS)

				if (2)
					message = "<B>[user]</B> does the twist, like they did last summer."
					SPAWN_DBG(0)
						for (var/i = 0, i < 4, i++)
							user.set_dir(turn(user.dir, -90))
							sleep(0.2 SECONDS)

				if (3)
					message = "<B>[user]</B> moonwalks."
					SPAWN_DBG(0)
						for (var/i = 0, i < 4, i++)
							user.pixel_x+= 2
							sleep(0.2 SECONDS)
						for (var/i = 0, i < 4, i++)
							user.pixel_x-= 2
							sleep(0.2 SECONDS)

				if (4)
					message = "<B>[user]</B> boogies!"
					SPAWN_DBG(0)
						for (var/i = 0, i < 4, i++)
							user.pixel_x+= 2
							user.set_dir(turn(user.dir, 90))
							sleep(0.2 SECONDS)
						for (var/i = 0, i < 4, i++)
							user.pixel_x-= 2
							user.set_dir(turn(user.dir, 90))
							sleep(0.2 SECONDS)

				if (5)
					message = "<B>[user]</B> gets on down."
					SPAWN_DBG(0)
						for (var/i = 0, i < 4, i++)
							user.pixel_y-= 2
							sleep(0.2 SECONDS)
						for (var/i = 0, i < 4, i++)
							user.pixel_y+= 2
							sleep(0.2 SECONDS)

				if (6)
					message = "<B>[user]</B> dances!"
					SPAWN_DBG(0)
						for (var/i = 0, i < 4, i++)
							user.pixel_x+= 1
							user.pixel_y+= 1
							sleep(0.2 SECONDS)
						for (var/i = 0, i < 4, i++)
							user.pixel_x-= 1
							user.pixel_y-= 1
							sleep(0.2 SECONDS)

				else
					message = "<B>[user]</B> cranks out some dizzying windmills."
					SPAWN_DBG(0)
						for (var/i = 0, i < 4, i++)
							user.pixel_x+= 1
							user.pixel_y+= 1
							user.set_dir(turn(user.dir, -90))
							sleep(0.2 SECONDS)
						for (var/i = 0, i < 4, i++)
							user.pixel_x-= 1
							user.pixel_y-= 1
							user.set_dir(turn(user.dir, -90))
							sleep(0.2 SECONDS)
					// expand this too, however much

				// todo: add context-sensitive break dancing and some other goofy shit

	SPAWN_DBG(0.5 SECONDS)
		//i hate these checks - too lazy to fix for real now but lets throw on some lagchecks since we're already spawning
		LAGCHECK(LAG_MED)
		var/beeMax = 15
		for (var/obj/critter/domestic_bee/responseBee in range(7, user))
			if (!responseBee.alive)
				continue

			if (beeMax-- < 0)
				break

			responseBee.dance_response()
			user.add_karma(1)

		LAGCHECK(LAG_MED)
		var/parrotMax = 15
		for (var/obj/critter/parrot/responseParrot in range(7, user))
			if (!responseParrot.alive)
				continue
			if (parrotMax-- < 0)
				break
			responseParrot.dance_response()

		LAGCHECK(LAG_MED)
		var/crabMax = 5
		for (var/obj/critter/crab/party/responseCrab in range(7, user))
			if (!responseCrab.alive)
				continue
			if (crabMax-- < 0)
				break
			responseCrab.dance_response()

	if (user.traitHolder && user.traitHolder.hasTrait("happyfeet"))
		if (prob(33))
			SPAWN_DBG(0.5 SECONDS)
				for (var/mob/living/carbon/human/responseMonkey in orange(1, user)) // they don't have to be monkeys, but it's signifying monkey code
					LAGCHECK(LAG_MED)
					if (!can_act(responseMonkey, 0))
						continue
					responseMonkey.emote("dance")

	if (user.reagents)
		if (user.reagents.has_reagent("ants") && user.reagents.has_reagent("mutagen"))
			var/ant_amt = user.reagents.get_reagent_amount("ants")
			var/mut_amt = user.reagents.get_reagent_amount("mutagen")
			user.reagents.del_reagent("ants")
			user.reagents.del_reagent("mutagen")
			user.reagents.add_reagent("spiders", ant_amt + mut_amt)
			boutput(user, "<span class='notice'>The ants arachnify.</span>")
			playsound(user, "sound/effects/bubbles.ogg", 80, 1)
	return list(message, null, MESSAGE_VISIBLE)



/datum/emote/flip
	cooldown = 5 SECONDS
/datum/emote/flip/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user)) //sounds restrict this to living, on_chair to human
		return
	var/message = null
	var/list/combatflipped = list()
	//TODO: space flipping
	//if ((!user.restrained()) && (!user.lying) && (istype(user.loc, /turf/space)))
	//	message = "<B>[user]</B> does a flip!"
	//	if (prob(50))
	//		animate(user, transform = turn(GetPooledMatrix(), 90), time = 1, loop = -1)
	//		animate(transform = turn(GetPooledMatrix(), 180), time = 1, loop = -1)
	//		animate(transform = turn(GetPooledMatrix(), 270), time = 1, loop = -1)
	//		animate(transform = turn(GetPooledMatrix(), 360), time = 1, loop = -1)
	//	else
	//		animate(user, transform = turn(GetPooledMatrix(), -90), time = 1, loop = -1)
	//		animate(transform = turn(GetPooledMatrix(), -180), time = 1, loop = -1)
	//		animate(transform = turn(GetPooledMatrix(), -270), time = 1, loop = -1)
	//		animate(transform = turn(GetPooledMatrix(), -360), time = 1, loop = -1)
	if (isobj(user.loc))
		var/obj/container = user.loc
		container.mob_flip_inside(user)

	if (!iswrestler(user))
		if (user.stamina <= STAMINA_FLIP_COST || (user.stamina - STAMINA_FLIP_COST) <= 0)
			boutput(user, "<span class='alert'>You fall over, panting and wheezing.</span>")
			message = "<span class='alert'><B>[user]</b> falls over, panting and wheezing.</span>"
			user.changeStatus("weakened", 2 SECONDS)
			user.set_stamina(min(1, user.stamina))
			user.emote_allowed = 0
			SPAWN_DBG(1 SECOND)
				user.emote_allowed = 1
			//goto showmessage


	if (user.targeting_ability && istype(user.targeting_ability, /datum/targetable))
		var/datum/targetable/D = user.targeting_ability
		D.flip_callback()

	if ((!istype_exact(user.loc, /turf/space)) && (!user.on_chair)) //that typecheck might still be bogus but at least we can flip on sand now
		if (!user.lying)
			if ((user.restrained()) || (user.reagents && user.reagents.get_reagent_amount("ethanol") > 30) || (user.bioHolder.HasEffect("clumsy")))
				message = pick("<B>[user]</B> tries to flip, but stumbles!", "<B>[user]</B> slips!")
				user.changeStatus("weakened", 4 SECONDS)
				user.TakeDamage("head", 8, 0, 0, DAMAGE_BLUNT)
				JOB_XP(user, "Clown", 1)
			else
				message = "<B>[user]</B> does a flip!"
			if (!user.reagents.has_reagent("fliptonium"))
				animate_spin(user, prob(50) ? "L" : "R", 1, 0)
			//TACTICOOL FLOPOUT
			if (user.traitHolder.hasTrait("matrixflopout") && user.stance != "dodge")
				user.remove_stamina(STAMINA_FLIP_COST * 2.0)
				message = "<B>[user]</B> does a tactical flip!"
				user.stance = "dodge"
				SPAWN_DBG(0.2 SECONDS) //I'm sorry for my transgressions there's probably a way better way to do this
					if(user?.stance == "dodge")
						user.stance = "normal"

			//FLIP OVER TABLES
			if (iswrestler(user) && !istype(user.equipped(), /obj/item/grab))
				for (var/obj/table/T in oview(1, null))
					if ((user.dir == get_dir(user, T)))
						T.set_density(0)
						if (LinkBlockedWithAccess(user.loc, T.loc))
							T.set_density(1)
							continue
						T.set_density(1)
						var/turf/newloc = T.loc
						user.set_loc(newloc)
						message = "<B>[user]</B> flips onto [T]!"

			var/flipped_a_guy = FALSE
			for (var/obj/item/grab/G in user.equipped_list(check_for_magtractor = 0))
				var/mob/living/M = G.affecting
				if (M == user)
					continue
				if (!G.affecting) //Wire note: Fix for Cannot read null.loc
					continue
				if (G.affecting in combatflipped)
					continue
				if (user.a_intent == INTENT_HELP && voluntary)
					M.emote("flip", 0) // make it voluntary so there's a cooldown and stuff
					continue
				flipped_a_guy = TRUE
				var/suplex_result = user.do_suplex(G)
				if(suplex_result)
					combatflipped |= TRUE
					message = suplex_result
				if(!combatflipped)
					var/turf/oldloc = user.loc
					var/turf/newloc = G.affecting.loc
					if(istype(oldloc) && istype(newloc))
						user.set_loc(newloc)
						G.affecting.set_loc(oldloc)
						message = "<B>[src]</B> flips over [G.affecting]!"
			if (!flipped_a_guy)
				for (var/mob/living/M in view(1, null))
					if (M == user)
						continue
					if (M in combatflipped)
						continue
					if (user.reagents?.get_reagent_amount("ethanol") > 10)
						if (!iswrestler(user) && user.traitHolder && !user.traitHolder.hasTrait("glasscannon"))
							user.remove_stamina(STAMINA_FLIP_COST)
							user.stamina_stun()
						combatflipped |= M
						message = "<span class='alert'><B>[user]</B> flips into [M]!</span>"
						logTheThing("combat", user, M, "flips into [constructTarget(M,"combat")]")
						user.changeStatus("weakened", 6 SECONDS)
						user.TakeDamage("head", 4, 0, 0, DAMAGE_BLUNT)
						M.changeStatus("weakened", 2 SECONDS)
						M.TakeDamage("head", 2, 0, 0, DAMAGE_BLUNT)
						playsound(user.loc, pick(sounds_punch), 100, 1)
						var/turf/newloc = M.loc
						user.set_loc(newloc)
					else if (!(user.reagents?.get_reagent_amount("ethanol") > 30))
						message = "<B>[user]</B> flips in [M]'s general direction."
					break
	if(length(combatflipped))
		actions.interrupt(user, INTERRUPT_ACT)
	if (user.lying)
		message = "<B>[user]</B> flops on the floor like a fish."
		//maptext_out = "<I>flops on the floor like a fish</I>"
	// If there is a chest item, see if its reagents can be dumped into the body
	var/mob/living/carbon/human/M = user
	if(M.chest_item != null)
		M.chest_item_dump_reagents_on_flip()
	return list(message, null, MESSAGE_VISIBLE)

/datum/emote/urinate //also piss, pee
/datum/emote/urinate/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user))
		return //I don't want to make pissing compatible with other things
	var/bladder = user.sims?.getValue("Bladder")
	var/message
	if (!isnull(bladder))
		var/obj/item/storage/toilet/toilet = locate() in user.loc
		var/obj/item/reagent_containers/glass/beaker = locate() in user.loc
		if (bladder > 75)
			boutput(user, "<span class='notice'>You don't need to go right now.</span>")
			return
		else if (bladder > 50)
			if(toilet)
				if (user.wear_suit || user.w_uniform)
					message = "<B>[user]</B> unzips [his_or_her(user)] pants and pees in the toilet."
				else
					message = "<B>[user]</B> pees in the toilet."
				toilet.clogged += 0.10
				toilet.peeps++
				user.sims.affectMotive("Bladder", 100)
				user.sims.affectMotive("Hygiene", -5)
				user.cleanhands = 0
			else if(beaker)
				boutput(user, "<span class='alert'>You don't feel desperate enough to piss in the beaker.</span>")
			else if(user.wear_suit || user.w_uniform)
				boutput(user, "<span class='alert'>You don't feel desperate enough to piss into your [user.w_uniform ? "uniform" : "suit"].</span>")
			else
				boutput(user, "<span class='alert'>You don't feel desperate enough to piss on the floor.</span>")
			return
		else if (bladder > 25)
			if(toilet)
				if (user.wear_suit || user.w_uniform)
					message = "<B>[user]</B> unzips [his_or_her(user)] pants and pees in the toilet."
				else
					message = "<B>[user]</B> pees in the toilet."
				toilet.clogged += 0.10
				toilet.peeps+=2
				user.sims.affectMotive("Bladder", 100)
				user.sims.affectMotive("Hygiene", -5)
				user.cleanhands = 0
			else if(beaker)
				if(user.wear_suit || user.w_uniform)
					message = "<B>[user]</B> unzips [his_or_her(user)] pants, takes aim, and pees in the beaker."
				else
					message = "<B>[user]</B> takes aim and pees in the beaker."
				beaker.reagents.add_reagent("urine", 4)
				user.sims.affectMotive("Bladder", 100)
				user.sims.affectMotive("Hygiene", -25)
				user.cleanhands = 0
			else
				if(user.wear_suit || user.w_uniform)
					boutput(user, "<span class='alert'>You don't feel desperate enough to piss into your [user.w_uniform ? "uniform" : "suit"].</span>")
					return
				else
					user.urinate()
					user.sims.affectMotive("Bladder", 100)
					user.sims.affectMotive("Hygiene", -50)
		else
			if (toilet)
				if (user.wear_suit || user.w_uniform)
					message = "<B>[user]</B> unzips [his_or_her(user)] pants and pees in the toilet."
				else
					message = "<B>[user]</B> pees in the toilet."
				toilet.clogged += 0.10
				toilet.peeps+=3
				user.sims.affectMotive("Bladder", 100)
				user.sims.affectMotive("Hygiene", -5)
				user.cleanhands = 0
			else if(beaker)
				if(user.wear_suit || user.w_uniform)
					message = "<B>[user]</B> unzips [his_or_her(user)] pants, takes aim, and fills the beaker with pee."
				else
					message = "<B>[user]</B> takes aim and fills the beaker with pee."
				user.sims.affectMotive("Bladder", 100)
				user.sims.affectMotive("Hygiene", -25)
				beaker.reagents.add_reagent("urine", 4)
				user.cleanhands = 0
			else
				if (user.wear_suit || user.w_uniform)
					message = "<B>[user]</B> pisses all over [himself_or_herself(user)]!"
					user.sims.affectMotive("Bladder", 100)
					user.sims.affectMotive("Hygiene", -100)
					if (user.w_uniform)
						user.w_uniform.name = "piss-soaked [initial(user.w_uniform.name)]"
					else
						user.wear_suit.name = "piss-soaked [initial(user.wear_suit.name)]"
				else
					user.urinate()
					user.sims.affectMotive("Bladder", 100)
					user.sims.affectMotive("Hygiene", -50)

	else
		var/obj/item/storage/toilet/toilet = locate() in user.loc

		if (toilet && (user.buckled != null))
			if (user.urine >= 1)
				for (var/obj/item/storage/toilet/T in user.loc)
					message = pick("<B>[user]</B> unzips [his_or_her(user)] pants and pees in the toilet.", "<B>[user]</B> empties [his_or_her(user)] bladder.", "<span class='notice'>Ahhh, sweet relief.</span>")
					user.urine = 0
					user.cleanhands = 0
					T.clogged += 0.10
					T.peeps++
					break
			else
				message = "<B>[user]</B> unzips [his_or_her(user)] pants but, try as [he_or_she(user)] might, [he_or_she(user)] can't pee in the toilet!"
		else if (user.urine < 1)
			message = "<B>[user]</B> pees [himself_or_herself(user)] a little bit."
		else
			user.urine--
			user.urinate()
	return list(message, null, MESSAGE_VISIBLE)


/datum/emote/dab
	cooldown = 2 SECONDS
/datum/emote/dab/enact(mob/living/carbon/human/user, voluntary = 0, param) //I'm honestly not sure how I'm ever going to code anything lower than this - Readster 23/04/19
	if(!istype(user))
		return
	var/message
	var/mob/living/carbon/human/H = user //I don't know why H is a thing in this code I pulled this entire bit out of human emote code FFS
	var/obj/item/I = user.wear_id
	if (istype(I, /obj/item/device/pda2))
		var/obj/item/device/pda2/P = I
		if(P.ID_card)
			I = P.ID_card
	if(H && (!H.limbs.l_arm || !H.limbs.r_arm || H.restrained()))
		user.show_text("You can't do that without free arms!")
		return list(,,)
	else if((user.mind && (user.mind.assigned_role in list("Clown", "Staff Assistant", "Captain"))) || istraitor(H) || isnukeop(H) || ASS_JAM || istype(user.head, /obj/item/clothing/head/bighat/syndicate/) || istype(I, /obj/item/card/id/dabbing_license) || (user.reagents && user.reagents.has_reagent("puredabs")) || (user.reagents && user.reagents.has_reagent("extremedabs"))) //only clowns and the useless know the true art of dabbing
		var/obj/item/card/id/dabbing_license/dab_id = null
		if(istype(I, /obj/item/card/id/dabbing_license)) // if we are using a dabbing license, save it so we can increment stats
			dab_id = I
			dab_id.dab_count++
			dab_id.tooltip_rebuild = 1
		user.add_karma(-4)
		if(!dab_id && locate(/obj/machinery/bot/secbot/beepsky) in view(7, get_turf(user)))
			for(var/datum/data/record/R in data_core.general) //copy paste from public urination, hope it works
				if(R.fields["name"] == user.name)
					for (var/datum/data/record/S in data_core.security)
						if (S.fields["id"] == R.fields["id"])
							// now add to rap sheet

							S.fields["criminal"] = "*Arrest*"
							S.fields["mi_crim"] = "Public dabbing."
							break

		if(user.reagents) user.reagents.add_reagent("dabs",5)


		if(prob(92) && (!user.reagents.has_reagent("extremedabs")))
			user.dabbify()
			var/get_dabbed_on = 0
			if(locate(/mob/living) in range(1, user))
				if(isturf(user.loc))
					for(var/mob/living/carbon/human/M in range(1, user)) //Is there somebody to dab on?
						if(M == user || !M.lying) //Are they on the floor and therefore fair game to get dabbed on?
							continue
						message = "<span class='alert'><B>[user]</B> dabs on [M]!</span>" //Get fucking dabbed on!!!
						get_dabbed_on = 1
						if(prob(5))
							M.emote("cry") //You should be ashamed
						if(dab_id)
							dab_id.dabbed_on_count++

			if(get_dabbed_on == 0)
				if (user.mind && user.mind.assigned_role == "Clown")
					message = "<B>[user]</B> [pick("performs a sick dab", "dabs on the haters", "shows everybody [his_or_her(user)] dope dab skills", "performs a wicked dab", "dabs like nobody has dabbed before", "shows everyone how they dab in the circus")]!!!"
				else
					message = "<B>[user]</B> [pick("performs a sick dab", "dabs on the haters", "shows everybody [his_or_her(user)] dope dab skills", "performs a wicked dab", "dabs like nobody has dabbed before")]!!!"
		// Act 2: Starring Firebarrage
		else if(!user.reagents.has_reagent("puredabs"))
			message = "<span class='alert'><B>[user]</B> dabs [his_or_her(user)] arms <B>RIGHT OFF</B>!!!!</span>"
			playsound(user.loc,"sound/misc/deepfrieddabs.ogg",50,0, channel=VOLUME_CHANNEL_EMOTE)
			shake_camera(user, 40, 8)
			if(H)
				if(H.limbs.l_arm)
					user.limbs.l_arm.sever()
					if(dab_id)
						dab_id.arm_count++
				if(H.limbs.r_arm)
					user.limbs.r_arm.sever()
					if(dab_id)
						dab_id.arm_count++
				H.emote("scream")
		if(!(istype(user.head, /obj/item/clothing/head/bighat/syndicate) || user.reagents.has_reagent("puredabs")))
			user.take_brain_damage(10)
			dab_id?.brain_damage_count += 10
			if(user.get_brain_damage() > 60)
				user.show_text("<span class='alert'>Your head hurts!</span>")
		if(locate(/obj/item/storage/bible) in user.loc)
			if(H.limbs.l_arm)
				user.limbs.l_arm.sever()
				dab_id?.arm_count++
			if(H.limbs.r_arm)
				user.limbs.r_arm.sever()
				dab_id?.arm_count++
			user.limbs.r_leg?.sever()
			user.limbs.l_leg?.sever()
			message = "<span class='alert'>[user] does a sick dab on ol' bib!</span>"
			user.visible_message("<span class='alert'>[user]'s' limbs just kind of fly off for reasons.</B>!</span>")
			playsound(user.loc,"sound/misc/deepfrieddabs.ogg",50,0, channel=VOLUME_CHANNEL_EMOTE)
	else
		user.show_text("You don't know how to do that but you feel deeply ashamed for trying", "red")
		return list(,,)
	return list(message, null, MESSAGE_VISIBLE)

