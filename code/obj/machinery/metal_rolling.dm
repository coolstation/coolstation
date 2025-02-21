/obj/machinery/hot_roller
	name = "hot roller"
	desc = "Heats and squishes blocks of material."
	icon_state = "hot_roller_off"
	density = 1
	anchored = 1
	mats = 40
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	processing_tier = PROCESSING_HALF
	p_class = 5 // the funny
	var/emagged = FALSE
	var/sound_loop_channel = 150 // works i hope

	New()
		..()
		UnsubscribeProcess()

	emag_act(mob/user)
		if (!src.emagged)
			src.emagged = TRUE
			if (user && ismob(user))
				src.add_fingerprint(user)
				boutput(user, "<span class='alert bold'>You short out [src]'s safety interlock!</span>")
				src.audible_message("<span class='alert'><B>[src] clunks strangely!</B></span>")
			logTheThing("station", user, null, "emagged a [src.name] at [log_loc(src)].")
			return 1
		return 0

	demag(var/mob/user)
		if(src.emagged)
			src.emagged = FALSE
			boutput(user, "<span class='notice'>You repair [src]'s safety interlock!</span>")
			return 1
		return 0

	custom_suicide = TRUE
	suicide(mob/user)
		if (!src.user_can_suicide(user))
			return 0
		if (!src.current_processing_tier)
			boutput(user, "<span class='alert'>You can't squish yourself on a stopped roller!</span>")
			return 0
		user.visible_message("<span class='combat bold'>[user] jumps right into [src]!</span>", "<span class='combat bold'>You jump into [src]!</span>")
		get_sucked_in(user)
		return 1

	attack_hand(mob/living/user)
		if(user && (user.lying || user.stat))
			return 1
		if(!in_interact_range(src, user) || !istype(src.loc, /turf))
			return 1
		if (isghostdrone(user))
			boutput(user, "<span class='alert'>Cardboard is all a refined ghostdrone like you needs, no need for [src]!</span>")
			return 1
		if(src.emagged && src.current_processing_tier)
			if(ishuman(user))
				arm_stuck(user)
			else
				get_sucked_in(user)
			return 0
		. = ..() // hate this being so far down but we need to be able to suck people in even if theyre dazed when smacking it
		if (src.current_processing_tier)
			user.visible_message("<span class='notice'>[user] shuts down the [src].</span>", "<span class='notice'>You slam the brake and shut down [src].</span>")
			UnsubscribeProcess()
			icon_state = "hot_roller_off"
		else
			user.visible_message("<span class='notice'>[user] starts up the [src].</span>", "<span class='notice'>You slap a button and start up [src].</span>")
			SubscribeToProcess()
			icon_state = "hot_roller_on"

	Bumped(atom/movable/AM)
		. = ..()
		try_pull_in(AM)

	Move(NewLoc,Dir)
		. = ..()
		if (.)
			for(var/atom/movable/AM in src.loc)
				try_pull_in(AM,Dir)

	proc/try_pull_in(var/atom/movable/AM,var/approach_dir)
		if(AM.anchored)
			return

		if(!approach_dir)
			approach_dir = get_dir(src,AM)

		if(!src.current_processing_tier)
			return

		if(world.timeofday - AM.last_bumped <= 60)
			return

		if(approach_dir in ordinal)
			if((turn(approach_dir,45)!=src.dir) && turn(approach_dir,-45)!=src.dir)
				return
		else if(approach_dir!=src.dir)
			return

		if(isliving(AM))
			var/mob/living/L = AM
			if(L.lying || (L.flags & TABLEPASS))
				get_sucked_in(L)

		if(!(AM.flags & TABLEPASS))
			return

		if(!isitem(AM))
			return

		src.visible_message("<span class='alert bold'>[AM] gets pulled into [src]!</span>","<span class='alert'>You hear something crunch!</span>","hot_roller")

		if (istype(AM, /obj/item/material_piece) && AM.material)
			for(var/obj/item/material_piece/I in src.contents)
				if (I.material && isSameMaterial(AM.material, I.material))
					I.change_stack_amount(I.amount)
					qdel(AM)
					return

		if (istype(AM, /obj/item/tile) && AM.material)
			for(var/obj/item/tile/I in src.contents)
				if (I.material && isSameMaterial(AM.material, I.material))
					I.change_stack_amount(I.amount)
					qdel(AM)
					return

		AM.set_loc(src)

	proc/arm_stuck(var/mob/living/user)
		var/mob/living/carbon/human/H = user
		user.visible_message("<span class='alert'>[src] snags [user] by the arm! Holy fuck!</span>", "<span class='alert'>[src] snags your arm and sucks it in! Holy fuck!</span>")
		user.emote("scream")
		var/obj/item/parts/limb_to_grab = user.hand ? H.limbs.l_arm : H.limbs.r_arm
		logTheThing("combat", H, null, "gets snagged in a hot roller at [log_loc(src)].")
		var/cnm = user.canmove
		//No voluntary movement while the arm is stuck!
		user.canmove = 0
		user.setStatus("weakened", max(user.getStatusDuration("weakened"),5 SECONDS))
		user.force_laydown_standup()
		SPAWN_DBG(0.5 SECONDS)
			if(!user) // hate runtimes hate them
				return
			user.canmove = cnm
			if(user.loc == src) // theres a very solid chance they got sucked in
				return
			if(!limb_to_grab)
				return
			new limb_to_grab.streak_decal(get_turf(src))
			take_bleeding_damage(user,user,rand(20,40))
			user.TakeDamage("All", rand(20,40), rand(15,25))
			limb_to_grab.remove()
			limb_to_grab.set_loc(src)
			logTheThing("combat", H, null, "loses an arm to a hot roller at [log_loc(src)].")
			#ifdef DATALOGGER
			game_stats.Increment("workplacesafety")
			#endif


	proc/get_sucked_in(var/mob/living/user)
		user.visible_message("<span class='combat bold'>[src] pulls [user] in and starts crushing [him_or_her(user)] into sheets!</span>", "<span class='combat bold'>[src] pulls you in! This is the end!</span>")
		user.set_loc(get_turf(src)) //So it looks like they're actually pulled in
		SPAWN_DBG(0.4 SECONDS)
			user.set_loc(src)
		logTheThing("combat", user, null, "gets sucked into a hot roller at [log_loc(src)].")
		#ifdef DATALOGGER
		game_stats.Increment("workplacesafety")
		#endif

	process()
		..()

		if(status & (NOPOWER|BROKEN))
			icon_state = "hot_roller_off"
			UnsubscribeProcess()
			return 0

		use_power(500)

		// when looping sounds works in 516, get back to this
		//playsound(src.loc, 'sound/machines/hot_roller_loop.ogg', 50, 0, forcechannel = src.sound_loop_channel, repeat = TRUE)
		playsound(src.loc, 'sound/machines/hot_roller_loop_temp.ogg', 50, 0, forcechannel = src.sound_loop_channel)

		var/processed_something = FALSE

		for(var/mob/living/poor_soul in src.contents) // i know oldcrusher is better... but THIS is hilarious
			if(poor_soul.nodamage)
				continue
			processed_something = TRUE
			if(isdead(poor_soul))
				for(var/obj/item/organ/organ in poor_soul.contents)
					qdel(organ)

				for(var/obj/item/I in poor_soul.contents)
					I.plane = PLANE_DEFAULT
					I.set_loc(src)

				if(poor_soul.material)
					var/obj/item/material_piece/processed_soul = new /obj/item/material_piece(src)
					processed_soul.change_stack_amount(4)
				else if(iscarbon(poor_soul))
					var/obj/item/material_piece/processed_soul = new /obj/item/material_piece/flesh(src)
					processed_soul.change_stack_amount(4)
				else if(issilicon(poor_soul))
					var/obj/item/material_piece/processed_soul = new /obj/item/material_piece/steel(src)
					processed_soul.change_stack_amount(4)
				poor_soul.gib()
			else
				poor_soul.TakeDamage("All", rand(30,40), rand(20,30))
				take_bleeding_damage(poor_soul,null,50,DAMAGE_CRUSH)
				if(prob(75))
					SPAWN_DBG(rand(0, 1 SECONDS))
						animate_storage_thump(src)
				SPAWN_DBG(rand(0, 1 SECONDS))
					poor_soul.emote("scream")

		for(var/obj/item/I in src.contents) // this code is TEMPORARY until atoms store their materials as a keyed list
			if(istype(I,/obj/item/tile) || istype(I, /obj/item/sheet) || istype(I, /obj/item/rods) || istype(I, /obj/item/raw_material/shard) || I.w_class < W_CLASS_NORMAL)
				I.set_loc(src.loc)
				I.throw_at(get_edge_cheap(src,turn(src.dir,180)), rand(3,6), 3) // vroom
				processed_something = TRUE
				break
			else if(src.create_sheets(I,1))
				processed_something = TRUE
				break
			I.set_loc(src.loc)
			I.throw_at(get_edge_cheap(src,turn(src.dir,180)), rand(3,6), 3) // get these weird things out
			processed_something = TRUE
			break

		if(processed_something)
			playsound(src.loc, 'sound/machines/hot_loop_process_1.ogg', 50, 1)

	/// mylie note - this proc will be revamped with keyed list materials to remove the required field
	proc/create_sheets(var/obj/item/I,var/required)
		if(required > I.amount || !I.material)
			return FALSE
		var/obj/item/sheet/sheet
		for(var/obj/item/sheet/potential_stack in src.loc) // maybe remove later because sheets may not stack in the end
			if((potential_stack.amount <= potential_stack.max_stack - 10) && isSameMaterial(getMaterial(potential_stack), getMaterial(I)))
				sheet = potential_stack
				sheet.change_stack_amount(10) // can be 1 when sheets squished
				break
		if(!sheet)
			sheet = new /obj/item/sheet(src.loc)
			sheet.setMaterial(I.material)
			sheet.change_stack_amount(9) // can be removed when sheets squished
			sheet.throw_at(get_edge_cheap(src,turn(src.dir,180)), rand(1,2), 2) // caution advised
		I.change_stack_amount(-1 * required)
		if(!I.amount)
			qdel(I)
		return TRUE
