/*
Contains:
-Vehicle defines
-Vehicle parent
-Segway
-Floor buffer
-Clown car
-Rideable cats
-Admin bus
-Forklift
*/

//------------------ Vehicle Defines --------------------///
#define MINIMUM_EFFECTIVE_DELAY 0.001 //absolute maximum speed for vehicles (lower is faster), do not set to 0 or division by 0 will happen

//////////////////////////////// Vehicle parent ///////////////////////////////////////
ABSTRACT_TYPE(/obj/vehicle)
/obj/vehicle
	name = "vehicle"
	icon = 'icons/obj/vehicles/vehicles.dmi'
	density = 1
	var/mob/living/rider = null //rider is basically the "driver" of the vehicle
	var/in_bump = 0 //sanity variable to prevent the vehicle from crashing multiple times due to a single collision
	var/sealed_cabin = 0 //does the vehicle have air conditioning? (check /datum/lifeprocess/bodytemp in bodytemp.dm for details)
	var/rider_visible =	1 //can we see the driver from outside of the vehicle? (used for overlays)
	var/list/ability_buttons = null //storage for the ability buttons after initialization
	var/list/ability_buttons_to_initialize = null //list of types of ability buttons to be initialized
	var/throw_dropped_items_overboard = 0 // See /mob/proc/drop_item() in mob.dm.
	var/attacks_fast_eject = 1 //whether any attack with an item that has a force vallue will immediately eject the rider (only works if rider_visible is true)
	layer = MOB_LAYER
	var/delay = 2 //speed, lower is faster, minimum of MINIMUM_EFFECTIVE_DELAY
	var/booster_upgrade = 0 //do we go through space?
	var/booster_image = null //what overlay icon do we use for the booster upgrade? (we have to initialize this in new)


	New()
		. = ..()
		START_TRACKING
		booster_image = image('icons/mob/robots.dmi', "up-speed") //default booster_image is the same as used for speed boost upgrade on cyborgs
		if(length(ability_buttons_to_initialize))
			src.setup_ability_buttons()


	disposing()
		if(rider)
			boutput(rider, "<span class='alert'><B>Your [src] is destroyed!</B></span>")
			eject_rider()
		. = ..()
		STOP_TRACKING

	remove_air(amount)
		return src.loc.remove_air(amount)

	return_air()
		return src.loc.return_air()

	attackby(obj/item/W as obj, mob/user as mob)
		if(src.rider && src.rider_visible && W.force)
			W.attack(src.rider, user)
			user.lastattacked = src
			if (attacks_fast_eject || rider.hasStatus(list("weakened", "paralysis", "stunned")))
				eject_rider()
			W.visible_message("<span class='alert'>[user] swings at [src.rider] with [W]!</span>")
		return

	bullet_act(flag, A as obj)
		if(src.rider)
			rider.bullet_act(flag, A)
			eject_rider()
		else
			..()

	meteorhit()
		if (src.rider && ismob(src.rider))
			src.rider.meteorhit()
			src.eject_rider()
		return

	ex_act(severity)
		switch(severity)
			if(OLD_EX_SEVERITY_1)
				for(var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					A.ex_act(severity)
				qdel(src)

			if(OLD_EX_SEVERITY_2)
				if (prob(50))
					for(var/atom/movable/A as mob|obj in src)
						A.set_loc(src.loc)
						A.ex_act(severity)
					qdel(src)

			if(OLD_EX_SEVERITY_3)
				if (prob(25))
					for(var/atom/movable/A as mob|obj in src)
						A.set_loc(src.loc)
						A.ex_act(severity)
					qdel(src)

	Exited(atom/movable/thing, atom/newloc)
		. = ..()
		if(thing == src.rider)
			src.eject_rider(0, 1, 0)

	proc/eject_other_stuff() // override if there's some stuff integral to the vehicle that should not be ejected
		for(var/atom/movable/AM in src)
			AM.set_loc(src.loc)

	/// kick out the rider
	proc/eject_rider(var/crashed, var/selfdismount, var/ejectall = 1)
		if(src.rider)
			if(src.rider.loc == src)
				src.rider.set_loc(src.loc)
			ClearSpecificOverlays("rider")
			ClearSpecificOverlays("booster_image")
			if(src.rider)
				handle_button_removal()
			src.rider = null
		if (ejectall)
			src.eject_other_stuff()

	/// remove the ability buttons from the rider
	proc/handle_button_removal()
		if (length(src.ability_buttons))
			for(var/obj/ability_button/B in src.ability_buttons)
				src.rider.client?.screen -= B

	/// add the ability buttons to the rider
	proc/handle_button_addition()
		if(!src.rider?.loc == src || !(length(src.ability_buttons)))
			return
		if(ishuman(src.rider))
			var/mob/living/carbon/human/H = rider
			H.hud?.update_ability_hotbar() //automatically adds the vehicle ability buttons
		else if (src.rider) //fix for cannot read null.client
			for(var/obj/ability_button/B in ability_buttons)
				B.the_mob = src.rider
				rider.client?.screen += B //don't have to worry about location since that should already have been handled by initialization

	/// initializes the ability buttons (if we have any)
	proc/setup_ability_buttons()
		if (!islist(src.ability_buttons))
			src.ability_buttons = list()
		var/x_btt =1
		for (var/button in src.ability_buttons_to_initialize)
			var/obj/ability_button/NB = new button()
			src.ability_buttons += NB
			NB.screen_loc = "NORTH-2,[x_btt]"
			x_btt++


	// This handles the code that USED to be defined individually in each vehicle's relaymove() proc
	// all non-machinery vehicles except forklifts and skateboards use this now
	relaymove(mob/user as mob, dir)
		// we reset the overlays to null in case the relaymove() call was initiated by a
		// passenger rather than the driver (we shouldn't have a rider overlay if there is no rider!)

		if(!src.rider || user != src.rider)
			UpdateOverlays(null, "rider")
			return

		var/td = max(src.delay, MINIMUM_EFFECTIVE_DELAY)

		if(src.rider_visible)
			UpdateOverlays(src.rider, "rider")

		// You can't move in space without the booster upgrade
		if (src.booster_upgrade)
			UpdateOverlays(booster_image, "booster_image")
		else
			UpdateOverlays(null, "booster_image")
			var/turf/T = get_turf(src)

			if(T.throw_unlimited && istype(T, /turf/space))
				return

		// Next, we do some simple math to adjust the vehicle's glide_size based on its speed and to compensate for lag
		src.glide_size = (32 / td) * world.tick_lag

		// we set the glide_size for all occupants of the vehicle to the same value that we used for the vehicle itself
		// and set the occupant's animate_movement to SYNC_STEPS
		// This helps to SIGNIFICANTLY smooth the apparent motion of the camera at higher speeds (almost buttery at default speed of 2)
		// Unfortunately, there is still some stuttering at higher speeds, but it has been lessened quite a bit.
		for(var/mob/M in src)
			M.glide_size = src.glide_size ;
			M.animate_movement = SYNC_STEPS;

		// We finally actually walk the src vehicle in the dir direction with td delay between steps
		// The vehicle will keep moving in this direction until stopped or the direction is changed
		walk(src, dir, td)

		// We.... uhhhhhh... well, we do the glide_size and animation adjustments AGAIN.
		// I really have no idea why we do this, but it was present in pod movement code,
		// and I asked mbc about it and we were both too scared to change it
		// So, if you want to optimize this some more, I'd start by looking into removing that bit of code
		src.glide_size = (32 / td) * world.tick_lag

		for(var/mob/M in src)
			M.glide_size = src.glide_size;
			M.animate_movement = SYNC_STEPS;

		// LASTLY, we call do_special_on_relay() to handle any special behaviors we want the vehicle to perform each time relaymove() is called
		// NOTE: this means that do_special_on_relay() will only get called when the rider is performing a direction input
		//       and NOT whenever the vehicle actually MOVES.
		//       For that, you'll want to override the vehicles Move() proc with the custom behavior you want.
		src.do_special_on_relay(user, dir);

	proc/do_special_on_relay(mob/user as mob, dir) //empty placeholder for when we successfully have the rider relay a move
		return


	proc/Stopped()
		ClearSpecificOverlays("booster_image") //so we don't see thrusters firing on a parked vehicle
		return

	proc/stop()
		walk(src,0)
		Stopped()

	blob_act(var/power)
		qdel(src)

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		..()
		// Simulate hotspot Crossed/Process so turfs engulfed in flames aren't simply ignored in vehicles
		if (src.rider_visible && !src.sealed_cabin && ismob(src.rider) && exposed_volume > (CELL_VOLUME * 0.8) && exposed_temperature > FIRE_MINIMUM_TEMPERATURE_TO_SPREAD)
			src.rider.update_burning(clamp(exposed_temperature / 60, 0, 10))

//////////////////////////////////////////////////////////// Segway ///////////////////////////////////////////

/obj/vehicle/segway
	name = "\improper Space Segway"
	desc = "Now you too can look like a complete tool in space!"
	icon_state = "segway"
	var/icon_base = "segway"
	var/icon_rider_state = 1
	var/image/image_under = null
	layer = MOB_LAYER + 1
	mats = 8
	var/weeoo_in_progress = 0
	var/icon_weeoo_state = 2
	soundproofing = 0
	throw_dropped_items_overboard = 1
	var/datum/light/light
	ability_buttons_to_initialize = list(/obj/ability_button/weeoo)
	var/obj/item/joustingTool = null // When jousting will be reference to lance being used

/obj/vehicle/segway/New()
	..()
	light = new /datum/light/point
	light.set_brightness(0.7)
	light.attach(src)

/obj/vehicle/segway/proc/weeoo()
	if (weeoo_in_progress)
		return

	weeoo_in_progress = 10
	SPAWN_DBG(0)
		playsound(src.loc, "sound/machines/siren_police.ogg", 50, 1)
		light.enable()
		src.icon_state = "[src.icon_base][src.icon_weeoo_state]"
		while (weeoo_in_progress--)
			light.set_color(0.9, 0.1, 0.1)
			sleep(0.3 SECONDS)
			light.set_color(0.1, 0.1, 0.9)
			sleep(0.3 SECONDS)
		light.disable()
		src.update()
		weeoo_in_progress = 0

/obj/ability_button/weeoo
	name = "Police Siren"
	icon = 'icons/ui/abilities.dmi'
	icon_state = "noise"

	Click()
		if(!the_mob) return

		if (istype(the_mob.loc, /obj/vehicle/segway))
			var/obj/vehicle/segway/seg = the_mob.loc
			seg.weeoo()
		else if (ishuman(the_mob))
			var/mob/living/carbon/human/H = the_mob
			var/obj/item/clothing/head/helmet/siren/S = H.head
			if (istype(S))
				S.weeoo()
		return

/obj/ability_button/sexgarf
	name = "sex garfield"
	icon = 'icons/ui/abilities.dmi'
	icon_state = "noise"

	Click()
		if(!the_mob) return

		if (istype(the_mob.loc, /obj/vehicle/cat/garfield/sex))
			var/obj/vehicle/cat/garfield/sex/sexgarf = the_mob.loc
			sexgarf.catchphrase()
		return

/obj/vehicle/segway/proc/update()
	if (rider)
		src.icon_state = "[src.icon_base][src.icon_rider_state]"
		if (!src.image_under)
			src.image_under = image(icon = src.icon, icon_state = src.icon_base, layer = MOB_LAYER - 0.1)
		else
			src.image_under.icon = src.icon
			src.image_under.icon_state = src.icon_base
		src.underlays += src.image_under
	else
		src.icon_state = src.icon_base
		src.UpdateOverlays(null, "rider")
		src.underlays = null

/obj/vehicle/segway/Bump(atom/AM as mob|obj|turf)
	if(in_bump)
		return
	if(AM == rider || !rider)
		return
	if(world.timeofday - AM.last_bumped <= 100)
		return
	walk(src, 0)
	update()
	..()
	in_bump = 1
	if((isturf(AM) || istype(AM, /mob/living/carbon/wall)) && (rider.bioHolder.HasEffect("clumsy") || (rider.reagents && rider.reagents.has_reagent("ethanol"))))
		boutput(rider, "<span class='alert'><B>You crash into the wall!</B></span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><B>[rider] crashes into the wall with \the [src]!</B></span>", 1)
		eject_rider(2)
		JOB_XP(rider, "Clown", 1)
		in_bump = 0
		return
	if(ismob(AM))
		var/mob/M = AM
		boutput(rider, "<span class='alert'><B>You crash into [M]!</B></span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><B>[rider] crashes into [M] with \the [src]!</B></span>", 1)
		// drsingh for undef variable silicon/robot/var/shoes
		// i guess a borg got on a segway? maybe someone was riding one with nanites
		if (ishuman(M))
			if(!istype(M:shoes, /obj/item/clothing/shoes/sandal))
				M.changeStatus("stunned", 8 SECONDS)
				M.changeStatus("weakened", 5 SECONDS)
				M.force_laydown_standup()
				src.log_me(src.rider, M, "impact")
			else
				boutput(M, "<span class='alert'><B>Your magical sandals keep you upright!</B></span>")
				boutput(rider, "<span class='alert'><B>[M] is kept upright by magical sandals!</B></span>")
				src.log_me(src.rider, M, "impact", 1)
				for (var/mob/C in AIviewers(src))
					if(C == M)
						continue
					C.show_message("<span class='alert'><B>[M] is kept upright by magical sandals!</B></span>", 1)
		else
			M.changeStatus("stunned", 8 SECONDS)
			M.changeStatus("weakened", 5 SECONDS)
			src.log_me(src.rider, M, "impact")
		if(prob(10))
			M.visible_message("<span class='success'><b>[src]</b> beeps out an automated injury report of [M]'s vitals.</span>")
			M.visible_message(scan_health(M, visible = 1))
		eject_rider(2)
		in_bump = 0

	if(isitem(AM))
		if(AM:w_class >= W_CLASS_BULKY)
			boutput(rider, "<span class='alert'><B>You crash into [AM]!</B></span>")
			for (var/mob/C in AIviewers(src))
				if(C == rider)
					continue
				C.show_message("<span class='alert'><B>[rider] crashes into [AM] with \the [src]!</B></span>", 1)
			eject_rider(1)
			in_bump = 0
			return
	if(istype(AM, /obj/vehicle/segway))
		var/obj/vehicle/segway/SG = AM
		if(SG.rider)
			SG.in_bump = 1
			var/mob/M = SG.rider
			var/mob/N = rider
			boutput(N, "<span class='alert'><B>You crash into [M]'s [SG.name]!</B></span>")
			boutput(M, "<span class='alert'><B>[N] crashes into your [SG.name]!</B></span>")
			for (var/mob/C in AIviewers(src))
				if(C == N || C == M)
					continue
				C.show_message("<span class='alert'><B>[N] and [M] crash into each other!</B></span>", 1)
			eject_rider(2)
			SG.eject_rider(1)
			src.log_me(N, M, "impact")
			in_bump = 0
			SG.in_bump = 0
			return
	in_bump = 0
	return

/obj/vehicle/segway/eject_rider(var/crashed, var/selfdismount, var/ejectall = 1)
	if (!src.rider)
		return

	var/mob/living/rider = src.rider
	..()
	rider.pixel_y = 0
	walk(src, 0)
	if(crashed)
		if(crashed == 2)
			playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
		boutput(rider, "<span class='alert'><B>You are flung over \the [src]'s handlebars!</B></span>")
		rider.changeStatus("stunned", 8 SECONDS)
		rider.changeStatus("weakened", 5 SECONDS)
		rider.force_laydown_standup()
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><B>[rider] is flung over \the [src]'s handlebars!</B></span>", 1)
		var/turf/target = get_edge_target_turf(src, src.dir)
		rider.throw_at(target, 5, 1)
		rider = null
		update()
		return
	if(selfdismount)
		boutput(rider, "<span class='notice'>You dismount from \the [src].</span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<B>[rider]</B> dismounts from \the [src].", 1)
	rider = null
	update()
	return

/obj/vehicle/segway/Move()
	. = ..()
	if (joustingTool && ishuman(rider)) // poke at people in three forward squares
		var/mob/living/carbon/human/R = rider
		if (R.equipped() != joustingTool) // you unreadied your lance
			return

		var/list/targets = new /list

		var/turf/nextStep = get_step(src, src.dir)
		targets += getTurfTargets(nextStep) // segway helper proc below

		var/turf/temp = null
		if (src.dir & (WEST | EAST)) // moving w/e, add diagonal potential targets
			temp = get_step(nextStep, NORTH)
			targets += getTurfTargets(temp)
			temp = get_step(nextStep, SOUTH)
			targets += getTurfTargets(temp)
		else if (src.dir & (NORTH | SOUTH)) // facing n/s, add contents of turfs w/e of nextStep
			temp = get_step(nextStep, WEST)
			targets += getTurfTargets(temp)
			temp = get_step(nextStep, EAST)
			targets += getTurfTargets(temp)
		else
			//boutput(world, "What direction are you even facing")
			return
		if (targets.len) // We have contact!
			var/unluckyFucker = pick(targets)
			var/mob/living/carbon/human/T
			var/obj/vehicle/segway/S = null
			if (ishuman(unluckyFucker))
				T = unluckyFucker
			else
				S = unluckyFucker
				T = S.rider


			var/datum/attackResults/msgs = new(R)
			msgs.clear(T)
			msgs.played_sound = joustingTool.hitsound
			msgs.affecting = pick("chest", "head")
			msgs.logs = list()
			msgs.logc("jousts [constructTarget(T,"combat")] with a [joustingTool]")
			msgs.damage_type = DAMAGE_BLUNT

			//logTheThing("combat", R, T, " jousts [constructTarget(src,"diary")] with a [joustingTool]")

			if (S) // they were on a segway, diiiiis-MOUNT!
				S.eject_rider(2)

			if (istype(joustingTool, /obj/item/mop))
				msgs.show_message_self("You slap [T] across the face with your [joustingTool]!")
				msgs.show_message_target("You get slapped across the face by [R]'s jousting mop!")
				msgs.visible_message_target("[T] is slapped in the face with [R]'s jousting mop!")
				msgs.stamina_self = rand(-15, -25)
				msgs.stamina_target = rand(-10,-30)
				msgs.flush()

				if (T.head && prob(20))
					T.show_message("Your hat goes flying!")
					var/obj/item/hat = T.head
					T.u_equip(hat)
					hat.set_loc(T.loc)
					hat.dropped(T)
					hat.throw_at(get_edge_target_turf(T, S.dir), 50, 1)

			else if (istype(joustingTool, /obj/item/experimental/melee/spear)) // don't need custom attackResults here, just use the spear attack, that's deadly enough
				T.Attackby(joustingTool, R)
				R.visible_message("[R] lances [T] with a spear!", "You stab at [T] in passing!")
				if (prob(33))
					R.drop_item(joustingTool)
					joustingTool.set_loc(get_turf(T))
					if (prob(50))
						R.show_message("The spear sticks in [T] and you lose control of [src]!")
						src.eject_rider(2)
					else
						R.show_message("You lose control of your spear!")

			else if (istype(joustingTool, /obj/item/rods))
				msgs.show_message_self("You wallop [T] in passing!")
				msgs.show_message_target("[R] wallops you with a [joustingTool] in passing!")
				msgs.visible_message_target("[R] jousts [T] with a [joustingTool]!")
				msgs.stamina_self = rand(-25, -45)
				msgs.stamina_target = rand(-25,-40)
				msgs.damage = rand(3,10)
				msgs.flush()

				if (prob(20))
					R.show_message("You lose your balance!")
					src.eject_rider(2)
			//else
				//boutput(world, "What the fuck how are you jousting with [joustingTool]")
			joustingTool = null // unready your lance, you've done well valliant knight

/obj/vehicle/segway/proc/getTurfTargets(turf/turf as turf)
	. = new /list
	for (var/mob/living/carbon/human/H in turf.contents)
		. += H
	for (var/obj/vehicle/segway/S in turf.contents)
		if (ishuman(S.rider))
			. += S

/obj/vehicle/segway/MouseDrop_T(mob/living/target, mob/user)
	if (rider || !istype(target) || target.buckled || LinkBlocked(target.loc,src.loc) || get_dist(user, src) > 1 || get_dist(user, target) > 1 || is_incapacitated(user) || isAI(user))
		return

	var/msg

	if(target == user && !user.stat)	// if drop self, then climbed in
		msg = "[user.name] climbs onto the [src]."
		boutput(user, "<span class='notice'>You climb onto \the [src].</span>")
	else if(target != user && !user.restrained())
		msg = "[user.name] helps [target.name] onto \the [src]!"
		boutput(user, "<span class='notice'>You help [target.name] onto \the [src]!</span>")
	else
		return
	target.set_loc(src)
	rider = target
	if (rider.client)
		handle_button_addition()
	rider.pixel_x = 0
	rider.pixel_y = 5
	src.UpdateOverlays(rider, "rider")

	for (var/mob/C in AIviewers(src))
		if(C == user)
			continue
		C.show_message(msg, 3)

	update()
	return

/obj/vehicle/segway/Click()
	if(usr != rider)
		..()
		return
	if(!(usr.getStatusDuration("paralysis") || usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened") || usr.stat))
		eject_rider(0, 1)
	return

/obj/vehicle/segway/attack_hand(mob/living/carbon/human/M as mob)
	if(!M || !rider)
		..()
		return
	switch(M.a_intent)
		if("harm", "disarm")
			if(prob(60))
				playsound(src.loc, "sound/impact_sounds/Generic_Shove_1.ogg", 50, 1, -1)
				src.visible_message("<span class='alert'><B>[M] has shoved [rider] off of the [src]!</B></span>")
				src.log_me(src.rider, M, "shoved_off")
				if (!rider.hasStatus("weakened"))
					rider.changeStatus("weakened", 2 SECONDS)
					rider.force_laydown_standup()
				eject_rider()
			else
				playsound(src.loc, "sound/impact_sounds/Generic_Swing_1.ogg", 25, 1, -1)
				src.visible_message("<span class='alert'><B>[M] has attempted to shove [rider] off of the [src]!</B></span>")
	return

/obj/vehicle/segway/disposing()
	if(rider)
		boutput(rider, "<span class='alert'><B>Your segway is destroyed!</B></span>")
		eject_rider()
	..()
	return

// Some people get really angry over this, so whatever. Logs would've been helpful on occasion (Convair880).
/obj/vehicle/segway/proc/log_me(var/mob/rider, var/mob/other_dude, var/action = "", var/immune_to_impact = 0)
	if (!src || action == "")
		return

	switch (action)
		if ("impact")
			if (ismob(rider) && ismob(other_dude))
				logTheThing("vehicle", rider, other_dude, "driving [src] crashes into [constructTarget(other_dude,"vehicle")][immune_to_impact != 0 ? " (immune to impact)" : ""] at [log_loc(src)].")

		if ("shoved_off")
			if (ismob(rider) && ismob(other_dude))
				logTheThing("vehicle", other_dude, rider, "shoves [constructTarget(rider,"vehicle")] off of a [src] at [log_loc(src)].")

	return

////////////////////////////////////////////////////// Floor buffer /////////////////////////////////////

/obj/vehicle/floorbuffer
	name = "\improper Buff-R-Matic 3000"
	desc = "A snazzy ridable floor buffer with a holding tank for cleaning agents."
	icon_state = "floorbuffer"
	layer = MOB_LAYER + 1
	is_syndicate = 1
	mats = 8
	var/low_reagents_warning = 0
	var/zamboni = 0
	var/bigshoe = 0
	var/sprayer_active = 0
	var/image/image_under = null
	var/icon_base = "floorbuffer"
	var/rider_state = 1
	delay = 4
	ability_buttons_to_initialize = list(/obj/ability_button/fbuffer_toggle, /obj/ability_button/fbuffer_status)
	soundproofing = 0
	throw_dropped_items_overboard = 1

	New()
		START_TRACKING
		..()
		src.create_reagents(1250)
		if(zamboni)
			reagents.add_reagent("cryostylane", 1000)
			return
		else if(bigshoe)
			reagents.add_reagent("tomato_sauce", 1000) //now we got da sause
			return
		else
			reagents.add_reagent("cleaner", 1000)
			//reagents.add_reagent("cleaner", 250) //don't even need this now that we have fluid, probably. If you want it, add it yer self

	disposing()
		STOP_TRACKING
		..()

/*
/obj/ability_button/toggle_buffer
	name = "Toggle Buff-R-Matic Sprayer"
	icon = 'icons/ui/abilities.dmi'
	icon_state = "on"
	var/active = 0

	Click()
		if(!the_mob) return

		var/mob/my_mob = the_mob

		var/obj/vehicle/floorbuffer/FB = null

		if(istype(my_mob.loc, /obj/vehicle/floorbuffer))
			FB = my_mob.loc
			active = !active
			boutput(my_mob, "<span class='notice'><B>You turn [active ? "on" : "off"] the floor buffer's sprayer.</span></B>")
			FB.sprayer_active = active
			src.icon_state = active ? "on" : "off"
			playsound(my_mob.loc, "sound/machines/click.ogg", 50, 1)

		return
*/
/obj/vehicle/floorbuffer/proc/update()
	if (rider)
		src.icon_state = "floorbuffer[src.sprayer_active]"
		//src.underlays += image(icon = src.icon, icon_state = "floorbuffer1a", layer = MOB_LAYER - 0.1 )
		if (!src.image_under)
			src.image_under = image(icon = src.icon, icon_state = src.icon_base, layer = MOB_LAYER - 0.1)
		else
			src.image_under.icon_state = src.icon_base
		src.underlays += src.image_under
	else
		src.icon_state = src.icon_base
		src.UpdateOverlays(null, "rider")
		src.underlays = null

/obj/vehicle/floorbuffer/Move()
	. = ..()
	if(. && rider)
		if(src.bigshoe) //big steppy
			pixel_x = rand(-4, 4)
			pixel_y = rand(3, 8)
			//playsound(src.loc, "sound/misc/step/step_heavyboots_[rand(1,3)].ogg", 30, 1) doesn't play for some people for some reason
			playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 30, 1)
			SPAWN_DBG(1 DECI SECOND)
				pixel_x = rand(-1, 1)
				pixel_y = rand(-1, 1)
		else
			pixel_x = rand(-1, 1)
			pixel_y = rand(-1, 1)
			SPAWN_DBG(1 DECI SECOND)
				pixel_x = rand(-1, 1)
				pixel_y = rand(-1, 1)
		if (!src.sprayer_active)
			var/turf/T = get_turf(src)
			if (istype(T) && T.active_liquid)
				if (T.active_liquid.group && T.active_liquid.group.members.len > 20) //Drain() is faster. use this if the group is large.
					if (prob(20))
						playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 25, 1)

					if (T.active_liquid.group)
						T.active_liquid.group.queued_drains += rand(2,4)
						T.active_liquid.group.last_drain = T
						if (!T.active_liquid.group.draining)
							T.active_liquid.group.add_drain_process()
					//T.active_liquid.group.drain(T.active_liquid, rand(2,4))

				else
					T.active_liquid.removed(1)
			return
		SPAWN_DBG(0)
			if (src.reagents.total_volume < 1)
				return

			if(src.reagents.has_reagent("water") || src.reagents.has_reagent("cleaner"))
				JOB_XP(rider, "Janitor", 1)

			else if(src.reagents.total_volume < 250 && !low_reagents_warning)
				low_reagents_warning = 1
				boutput(rider, "<span class='notice'><B>The \"Storage Tank Low\" indicator light starts blinking on [src]'s dashboard.</B></span>")
				for (var/obj/ability_button/fbuffer_status/SB in src)
					SB.icon_state = "bufferf-low"
				playsound(src, "sound/machines/twobeep.ogg", 50)
			else if(src.reagents.total_volume >= 250)
				low_reagents_warning = 0
				for (var/obj/ability_button/fbuffer_status/SB in src)
					SB.icon_state = "bufferf"

			var/obj/decal/D = new/obj/decal(get_turf(src))
			D.name = null
			D.icon = null
			D.invisibility = 101
			D.create_reagents(5)
			src.reagents.trans_to(D, 5)

			var/turf/D_turf = get_turf(D)
			D.reagents.reaction(D_turf)
			for(var/atom/T in D_turf)
				D.reagents.reaction(T)
			sleep(0.3 SECONDS)
			if (D_turf.active_liquid)
				D_turf.active_liquid.try_connect_to_adjacent()

			qdel(D)

/obj/vehicle/floorbuffer/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/reagent_containers) && W.is_open_container() && W.reagents)
		if(!W.reagents.total_volume)
			boutput(user, "<span class='alert'>[W] is empty.</span>")
			return

		if(src.reagents.total_volume >= src.reagents.maximum_volume)
			boutput(user, "<span class='alert'>The [src.name]'s holding tank is full!</span>")
			return

		logTheThing("combat", user, null, "pours chemicals [log_reagents(W)] into the [src] at [log_loc(src)].") // Logging for floor buffers (Convair880).
		var/trans = W.reagents.trans_to(src, W.reagents.total_volume)
		boutput(user, "<span class='notice'>You empty [trans] units of the solution into the [src.name]'s holding tank.</span>")
		return
	..()

/obj/vehicle/floorbuffer/is_open_container()
	return 2

/obj/vehicle/floorbuffer/Bump(atom/AM as mob|obj|turf)
	if(in_bump)
		return
	if(AM == rider || !rider)
		return
	if(world.timeofday - AM.last_bumped <= 100)
		return
	walk(src, 0)
	update()
	..()
	in_bump = 1
	if(ismob(AM) && src.bigshoe) //this repeats twice for some reason, i probably fucked up but it's funny
		var/mob/M = AM
		boutput(rider, "<span class='alert'><B>You kick [M]!</B></span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><B>[rider] kicks [M] with \the [src]!</B></span>", 1)
		var/turf/target = get_edge_target_turf(src, src.dir)
		M.throw_at(target, 5, 1) //kicks them out of the way so we don't get slowed down, stomps are when you enter same turf
		M.changeStatus("stunned", 4 SECONDS)
		M.changeStatus("weakened", 2 SECONDS)
		M.TakeDamage("chest", 8, 0, 0, DAMAGE_BLUNT) //reduced because it hits twice
		playsound(src.loc, "sound/impact_sounds/Flesh_Break_1.ogg", 25, 1)
		playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 25, 1) //placeholder sounds
		var/mob/living/carbon/human/R = src.rider
		if (R.traitHolder.hasTrait("italian"))
			R.say (pick("Wahoo!", "Mama Mia!", "Let's-a Go!", "Ha ha!")) //there it is
		in_bump = 0
		return
	if(ismob(AM) && src.booster_upgrade)
		var/mob/M = AM
		boutput(rider, "<span class='alert'><B>You crash into [M]!</B></span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><B>[rider] crashes into [M] with \the [src]!</B></span>", 1)
		M.changeStatus("stunned", 5 SECONDS)
		M.changeStatus("weakened", 3 SECONDS)
		in_bump = 0
		return
	if(isitem(AM))
		..()
		in_bump = 0
		return
	if(istype(AM, /obj/vehicle/segway))
		var/obj/vehicle/segway/SG = AM
		if(SG.rider)
			SG.in_bump = 1
			var/mob/M = SG.rider
			var/mob/N = rider
			boutput(N, "<span class='alert'><B>You crash into [M]'s [SG.name]!</B></span>")
			boutput(M, "<span class='alert'><B>[N] crashes into your [SG.name]!</B></span>")
			for (var/mob/C in AIviewers(src))
				if(C == N || C == M)
					continue
				C.show_message("<span class='alert'><B>[N] and [M] crash into each other!</B></span>", 1)
			SG.eject_rider(1)
			in_bump = 0
			SG.in_bump = 0
			return
	in_bump = 0
	return

/obj/vehicle/floorbuffer/eject_rider(var/crashed, var/selfdismount, var/ejectall = 1)
	var/mob/living/rider = src.rider
	..()
	rider.pixel_y = 0
	walk(src, 0)
	src.log_rider(rider, 1)
	if(crashed)
		if(crashed == 2)
			playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
		boutput(rider, "<span class='alert'><B>You are flung over \the [src]'s handlebars!</B></span>")
		rider.changeStatus("stunned", 8 SECONDS)
		rider.changeStatus("weakened", 5 SECONDS)
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><B>[rider] is flung over \the [src]'s handlebars!</B></span>", 1)
		var/turf/target = get_edge_target_turf(src, src.dir)
		rider.throw_at(target, 5, 1)
		rider = null
		update()
		return
	if(selfdismount)
		boutput(rider, "<span class='notice'>You dismount from \the [src].</span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<B>[rider]</B> dismounts from \the [src].", 1)
	rider = null
	update()
	return

/obj/vehicle/floorbuffer/MouseDrop_T(mob/living/target, mob/user)
	if (rider || !istype(target) || target.buckled || LinkBlocked(target.loc,src.loc) || get_dist(user, src) > 1 || get_dist(user, target) > 1 || is_incapacitated(user) || isAI(user))
		return

	var/msg
	//TODO: pro-italian discrimination for the big shoe?
	if(target == user && !user.stat)	// if drop self, then climbed in
		if(src.bigshoe)
			msg = "[user.name] gets into [his_or_her(user)] [src.name] about it!"
			boutput(user, "<span class='notice'>You hop into \the [src]!</span>")
			src.log_rider(user, 0)
		else
			msg = "[user.name] climbs onto the [src]."
			boutput(user, "<span class='notice'>You climb onto \the [src].</span>")
			src.log_rider(user, 0)
	else if(target != user && !user.restrained())
		msg = "[user.name] helps [target.name] onto \the [src]!"
		boutput(user, "<span class='notice'>You help [target.name] onto \the [src]!</span>")
		src.log_rider(target, 0)
	else
		return

	target.set_loc(src)
	rider = target
	if (target.client)
		handle_button_addition()
	if (src.bigshoe)
		rider.pixel_x = 0
		rider.pixel_y = 8
	else
		rider.pixel_x = 0
		rider.pixel_y = 10
	src.UpdateOverlays(rider, "rider")

	for (var/mob/C in AIviewers(src))
		if(C == user)
			continue
		C.show_message(msg, 3)

	update()
	return

/obj/vehicle/floorbuffer/Click()
	if(usr != rider)
		..()
		return
	if(!is_incapacitated(usr))
		eject_rider(0, 1)
	return

/obj/vehicle/floorbuffer/attack_hand(mob/living/carbon/human/M as mob)
	if(!M || !rider)
		..()
		return
	switch(M.a_intent)
		if("harm", "disarm")
			if(prob(70) || M.is_hulk())
				playsound(src.loc, "sound/impact_sounds/Generic_Shove_1.ogg", 50, 1, -1)
				src.visible_message("<span class='alert'><B>[M] has yanked [rider] off of \the [src]!</B></span>")
				if (!rider.hasStatus("weakened"))
					rider.changeStatus("weakened", 2 SECONDS)
					rider.force_laydown_standup()
				eject_rider()
			else
				playsound(src.loc, "sound/impact_sounds/Generic_Swing_1.ogg", 25, 1, -1)
				src.visible_message("<span class='alert'><B>[M] has attempted to yank [rider] off of \the [src]!</B></span>")
	return

/obj/vehicle/floorbuffer/disposing()
	if(rider)
		boutput(rider, "<span class='alert'><B>Your [src.name] is destroyed!</B></span>")
		eject_rider()
	..()
	return

// Ditto, more logs (Convair880).
/obj/vehicle/floorbuffer/proc/log_rider(var/mob/rider, var/mount_or_dismount = 0)
	if (!src || !rider || !ismob(rider))
		return

	logTheThing("vehicle", rider, null, "[mount_or_dismount == 0 ? "mounts" : "dismounts"] \a [src.name] [log_reagents(src)] at [log_loc(src)].")
	return

/obj/ability_button/fbuffer_toggle
	name = "Floor Buffer Toggle"
	icon = 'icons/ui/abilities.dmi'
	icon_state = "buffer0"
	screen_loc = "NORTH-2,1"

	Click()
		if (!the_mob)
			return
		if (istype(the_mob.loc, /obj/vehicle/floorbuffer/reallybigshoe))
			var/obj/vehicle/floorbuffer/reallybigshoe/RBS = the_mob.loc
			RBS.sprayer_active = !RBS.sprayer_active
			if (RBS.sprayer_active)
				boutput(the_mob, "<span class='notice'><B>You turn on [RBS]'s pasta-saucer.</span></B>")
			else
				boutput(the_mob, "<span class='notice'><B>You turn off [RBS]'s pasta-saucer.</span></B>")
			playsound(the_mob, "sound/misc/meat_plop.ogg", 50, 1)
		else if (istype(the_mob.loc, /obj/vehicle/floorbuffer))
			var/obj/vehicle/floorbuffer/FB = the_mob.loc
			FB.sprayer_active = !FB.sprayer_active
			if (FB.sprayer_active)
				boutput(the_mob, "<span class='notice'><B>You turn on [FB]'s sprayer.</span></B>")
			else
				boutput(the_mob, "<span class='notice'><B>You turn off [FB]'s sprayer - the buffer will now dry puddles.</span></B>")
			src.icon_state = "buffer[FB.sprayer_active]"
			if (FB.rider)
				FB.icon_state = "[FB.icon_base][FB.sprayer_active]"
			playsound(the_mob, "sound/machines/click.ogg", 50, 1)
		return

/obj/ability_button/fbuffer_status
	name = "Floor Buffer Tank Status"
	icon = 'icons/ui/abilities.dmi'
	icon_state = "bufferf"
	screen_loc = "NORTH-3,1"

	Click()
		if (!the_mob)
			return
		if (istype(the_mob.loc, /obj/vehicle/floorbuffer))
			var/obj/vehicle/floorbuffer/FB = the_mob.loc
			if (FB.reagents)
				boutput(the_mob, "<span class='notice'><B>[FB]'s tank is [get_fullness(FB.reagents.total_volume / FB.reagents.maximum_volume * 100)].</B></span>")
		return

/////////////////////////////////////////////////////// Big Italian Shoe /////////////////////////////////

/obj/vehicle/floorbuffer/reallybigshoe //get ready for some bad code and a really obnoxious gimmick item
	name = "\improper Big Italian Shoe"
	desc = "Mama Mia! Somebody ain't happy!"
	icon_state = "bigshoe"
	icon_base = "bigshoe"
	bigshoe = 1
	layer = MOB_LAYER + 1
	delay = 2

	//maybe this does small hops like moonboots when idle?

/obj/vehicle/floorbuffer/reallybigshoe/update() //gonna move this back to the original update with bigshoe carveouts when i understand it more but for now...
	if (rider)
		src.icon_state = "bigshoe"
		if (!src.image_under)
			src.image_under = image(icon = src.icon, icon_state = src.icon_base, layer = MOB_LAYER - 0.1)
		else
			src.image_under.icon_state = src.icon_base
		src.underlays += src.image_under
	else
		src.icon_state = src.icon_base
		src.UpdateOverlays(null, "rider")
		src.underlays = null

/obj/vehicle/floorbuffer/reallybigshoe/proc/StompOn(var/mob/living/carbon/human/H)
	if (!rider)
		return //don't stomp if someone isn't actually riding the shoe (i.e. pushing)
	playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
	//handle some specific checks
	var/mob/living/carbon/human/R = src.rider
	//if (R.reagents && R. wearing plumber outfit etc))
		// M.unlock_medal("Copyright Not Intendo", 1) not really (but maybe)
	if (R.traitHolder.hasTrait("italian"))
		R.say(pick("Wahoo!", "Mama Mia!", "Let's-a Go!", "Ha ha!")) //there it is

	var/damage = rand(1,3) //a little less rough because it can easily happen multiple times
	H.TakeDamage("head", 2*damage, 0) //same damage allocation as mulebot, for now
	H.TakeDamage("chest",2*damage, 0)
	H.TakeDamage("l_leg",0.5*damage, 0)
	H.TakeDamage("r_leg",0.5*damage, 0)
	H.TakeDamage("l_arm",0.5*damage, 0)
	H.TakeDamage("r_arm",0.5*damage, 0)
	if(prob(30))
		H.changeStatus("stunned", 3 SECONDS)

	boutput(rider, "<span class='alert'><B>You stomp on [H]!</B></span>")
	for (var/mob/C in AIviewers(src))
		if(C == rider)
			continue
		C.show_message("<span class='alert'><B>[rider] stomps all over [H] with \the [src]!</B></span>", 1)

	/*var/squished = 0 //not working, will deal with later
	if (!squished) //we only want to squish and unsquish once to keep it clean
		H.Scale(4, .25)
		squished = 1
		SPAWN_DBG(10 SECONDS)
			if(squished)
			H.Scale(.25, 4) //don't care if this doesn't work i'm slamming it in fore the playtest
			squished = 0 */

	//take_bleeding_damage(H, null, 2 * damage, DAMAGE_BLUNT)

	//bloodiness += 4 //giant red footprints, eventually

/////////////////////////////////////////////////////// Clown car ////////////////////////////////////////

/obj/vehicle/clowncar
	name = "Clown Car"
	desc = "A funny-looking car designed for circus events. Seats 30, very roomy!"
	icon_state = "clowncar"
	var/antispam = 0
	var/moving = 0
	rider_visible = 0
	is_syndicate = 1
	mats = 15
	ability_buttons_to_initialize = list(/obj/ability_button/loudhorn/clowncar, /obj/ability_button/stopthebus/clowncar)
	soundproofing = 5
	var/second_icon = "clowncar2" //animated jiggling for the clowncar

/obj/vehicle/clowncar/do_special_on_relay(mob/user as mob, dir)
	for (var/mob/living/carbon/human/H in src)
		if (H.sims)
			H.sims.affectMotive("fun", 1)
			H.sims.affectMotive("Hunger", 1)
			H.sims.affectMotive("Thirst", 1)
	icon_state = second_icon
	moving = 1
	if(!(world.timeofday - src.antispam <= 60))
		src.antispam = world.timeofday
		playsound(src, "sound/machines/rev_engine.ogg", 50, 1)
		playsound(src.loc, "sound/machines/rev_engine.ogg", 50, 1)
		//play engine sound
	return

/obj/vehicle/clowncar/Click()
	if(usr != rider)
		..()
		return
	if(!(usr.getStatusDuration("paralysis") || usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened") || usr.stat))
		eject_rider(0, 1, 0)
	return

/obj/vehicle/clowncar/attack_hand(mob/living/carbon/human/M as mob)
	if(!M)
		..()
		return
	if (ismobcritter(M))
		var/mob/living/critter/C = M
		if (isghostcritter(C))
			..()
			return

	if(M.is_hulk())
		if(prob(40))
			boutput(M, "<span class='alert'><B>You smash the puny [src] apart!</B></span>")
			playsound(src, "shatter", 70, 1)
			playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)

			for(var/mob/N in AIviewers(M, null))
				if(N == M)
					continue
				N.show_message(text("<span class='alert'><B>[] smashes the [] apart!</B></span>", M, src), 1)
			for(var/atom/A in src.contents)
				if(ismob(A))
					if (A != src.rider) // Rider log is called by disposing().
						src.log_me(src.rider, A, "pax_exit")
					var/mob/N = A
					N.show_message(text("<span class='alert'><B>[] smashes the [] apart!</B></span>", M, src), 1)
					N.set_loc(src.loc)
				else if (isobj(A))
					var/obj/O = A
					O.set_loc(src.loc)
			var/obj/item/scrap/S = new
			S.size = 4
			S.update()
			qdel(src)
		else
			boutput(M, "<span class='alert'><B>You punch the puny [src]!</B></span>")
			playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
			for(var/mob/N in AIviewers(M, null))
				if(N == M)
					continue
				N.show_message(text("<span class='alert'><B>[] punches the []!</B></span>", M, src), 1)
			for(var/atom/A in src.contents)
				if(ismob(A))
					var/mob/N = A
					N.show_message(text("<span class='alert'><B>[] punches the []!</B></span>", M, src), 1)
	else
		playsound(src.loc, "sound/machines/click.ogg", 15, 1, -3)
		if(rider && prob(40))
			playsound(src.loc, "sound/impact_sounds/Generic_Shove_1.ogg", 50, 1, -1)
			src.visible_message("<span class='alert'><B>[M] has pulled [rider] out of the [src]!</B></span>")
			if (!rider.hasStatus("weakened"))
				rider.changeStatus("weakened", 2 SECONDS)
				rider.force_laydown_standup()
			eject_rider(0, 0, 0)
		else
			if(src.contents.len)
				playsound(src.loc, "sound/impact_sounds/Generic_Shove_1.ogg", 50, 1, -1)
				src.visible_message("<span class='alert'><B>[M] opens up the [src], spilling the contents out!</B></span>")
				for(var/atom/A in src.contents)
					if(ismob(A))
						var/mob/N = A
						if (N != src.rider)
							src.log_me(src.rider, N, "pax_exit")
							N.show_message(text("<span class='alert'><B>You are let out of the [] by []!</B></span>", src, M), 1)
							N.set_loc(src.loc)
						else
							N.changeStatus("weakened", 2 SECONDS)
							src.eject_rider()
					else if (isobj(A))
						var/obj/O = A
						O.set_loc(src.loc)
			else
				boutput(M, "<span class='notice'>There's nothing inside of the [src].</span>")
				return
	return

/obj/vehicle/clowncar/MouseDrop_T(mob/living/carbon/human/target, mob/user)
	if (!istype(target) || target.buckled || LinkBlocked(target.loc,src.loc) || get_dist(user, src) > 1 || get_dist(user, target) > 1 || is_incapacitated(user) || isAI(user) || isghostcritter(user))
		return

	var/msg

	var/clown_tally = 0
	if(ishuman(user))
		if(istype(user:w_uniform, /obj/item/clothing/under/misc/clown))
			clown_tally += 1
		if(istype(user:shoes, /obj/item/clothing/shoes/clown_shoes))
			clown_tally += 1
		if(istype(user:wear_mask, /obj/item/clothing/mask/clown_hat))
			clown_tally += 1
	if(clown_tally < 2)
		boutput(user, "<span class='notice'>You don't feel funny enough to use the [src].</span>")
		return

	if(target == user && !user.stat)	// if drop self, then climbed in
		if(rider)
			return
		target.set_loc(src)
		rider = target
		handle_button_addition()
		src.log_me(src.rider, null, "rider_enter")
		msg = "[user.name] climbs into the driver's seat of the [src]."
		boutput(user, "<span class='notice'>You climb into the driver's seat of the [src].</span>")
	else if(target != user && !user.restrained() && target.lying)
		target.set_loc(src)
		src.log_me(user, target, "pax_enter", 1)
		msg = "[user.name] stuffs [target.name] into the back of the [src]!"
		boutput(user, "<span class='notice'>You stuff [target.name] into the back of the [src]!</span>")
	else
		return
	for (var/mob/C in AIviewers(src))
		if(C == user)
			continue
		C.show_message(msg, 3)
	return

/obj/vehicle/clowncar/Bump(atom/AM as mob|obj|turf)
	if(in_bump)
		return
	if(AM == rider || !rider)
		return
	if(world.timeofday - AM.last_bumped <= 100)
		return
	walk(src, 0)
	moving = 0
	icon_state = "clowncar"
	..()
	in_bump = 1
	if((isturf(AM) || istype(AM, /mob/living/carbon/wall)))
		boutput(rider, "<span class='alert'><B>You crash into the wall!</B></span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><B>[rider] crashes into the wall with the [src]!</B></span>", 1)
		eject_rider(2)
		in_bump = 0
		return
	if(ismob(AM))
		DEBUG_MESSAGE("Bumped [AM] and gonna bowl 'em over.")
		bumpstun(AM)

//		eject_rider(2)
		in_bump = 0
		return
	if(istype(AM, /obj/vehicle/segway))
		var/obj/vehicle/segway/SG = AM
		if(SG.rider)
			SG.in_bump = 1
			var/mob/M = SG.rider
			var/mob/N = rider
			boutput(N, "<span class='alert'><B>You crash into [M]'s [SG]!</B></span>")
			boutput(M, "<span class='alert'><B>[N] crashes into your [SG]!</B></span>")
			for (var/mob/C in AIviewers(src))
				if(C == N || C == M)
					continue
				C.show_message("<span class='alert'><B>[N] crashes into [M]'s [SG]!</B></span>", 1)
			SG.eject_rider(1)
			in_bump = 0
			SG.in_bump = 0
			return
	in_bump = 0
	return

/obj/vehicle/clowncar/Bumped(var/atom/movable/AM as mob|obj)
	if (moving && ismob(AM) && !isghostcritter(AM)) //If we're moving and they're in front of us then bump they
		walk(src, 0)
		moving = 0
		bumpstun(AM)

	..()

/obj/vehicle/clowncar/proc/bumpstun(var/mob/M)
	if(istype(M))
		boutput(rider, "<span class='alert'><B>You crash into [M]!</B></span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><B>[rider] crashes into [M] with the [src]!</B></span>", 1)
		M.changeStatus("stunned", 8 SECONDS)
		M.changeStatus("weakened", 5 SECONDS)
		playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)

/obj/vehicle/clowncar/bullet_act(flag, A as obj)
	if (src.rider && ismob(src.rider) && prob(30))
		src.rider.bullet_act(flag, A)
		src.eject_rider(1)
	return

/obj/vehicle/clowncar/meteorhit()
	if(prob(60))
		eject_rider(2)
	return

/obj/vehicle/clowncar/disposing()
	if(rider)
		boutput(rider, "<span class='alert'><B>Your [src] is destroyed!</B></span>")
		eject_rider(1)
	..()
	return

/obj/vehicle/clowncar/eject_rider(var/crashed, var/selfdismount, var/ejectall = 1)
	if (!src.rider || !ismob(src.rider))
		return
	var/mob/living/rider = src.rider
	..()
	walk(src, 0)
	moving = 0
	src.log_me(src.rider, null, "rider_exit")
	if(crashed)
		if(crashed == 2)
			playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
		playsound(src.loc, "shatter", 40, 1)
		boutput(rider, "<span class='alert'><B>You are flung through the [src]'s windshield!</B></span>")
		rider.changeStatus("stunned", 8 SECONDS)
		rider.changeStatus("weakened", 5 SECONDS)
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><B>[rider] is flung through the [src]'s windshield!</B></span>", 1)
		var/turf/target = get_edge_target_turf(src, src.dir)
		rider.throw_at(target, 5, 1)
		rider = null
		icon_state = "clowncar"
		if(prob(40) && length(src.contents))
			for(var/mob/O in AIviewers(src, null))
				O.show_message(text("<span class='alert'><B>Everything in the [] flies out!</B></span>", src), 1)
			for(var/atom/A in src.contents)
				if(ismob(A))
					src.log_me(null, A, "pax_exit")
					var/mob/N = A
					N.show_message(text("<span class='alert'><B>You are flung out of the []!</B></span>", src), 1)
					N.set_loc(src.loc)
				else if (isobj(A))
					var/obj/O = A
					O.set_loc(src.loc)
		return
	if(selfdismount)
		boutput(rider, "<span class='notice'>You climb out of the [src].</span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<B>[rider]</B> climbs out of the [src].", 1)
	rider = null
	icon_state = "clowncar"
	return

/obj/vehicle/clowncar/attackby(var/obj/item/I, var/mob/user)
	var/clown_tally = 0
	if(ishuman(user))
		if(istype(user:w_uniform, /obj/item/clothing/under/misc/clown))
			clown_tally += 1
		if(istype(user:shoes, /obj/item/clothing/shoes/clown_shoes))
			clown_tally += 1
		if(istype(user:wear_mask, /obj/item/clothing/mask/clown_hat))
			clown_tally += 1
	if(clown_tally < 2)
		boutput(user, "<span class='notice'>You don't feel funny enough to use the [src].</span>")
		return

	var/obj/item/grab/G = I
	if(istype(G))	// handle grabbed mob
		if(ismob(G.affecting))
			var/mob/GM = G.affecting
			GM.set_loc(src)
			boutput(user, "<span class='notice'>You stuff [GM.name] into the back of the [src].</span>")
			boutput(GM, "<span class='alert'><B>[user] stuffs you into the back of the [src]!</B></span>")
			src.log_me(user, GM, "pax_enter", 1)
			for (var/mob/C in AIviewers(src))
				if(C == user)
					continue
				C.show_message("<span class='alert'><B>[GM.name] has been stuffed into the back of the [src] by [user]!</B></span>", 3)
			qdel(G)
			return
	..()
	return

// Could be useful, I guess (Convair880).
obj/vehicle/clowncar/proc/log_me(var/mob/rider, var/mob/pax, var/action = "", var/forced_in = 0)
	if (!src || action == "")
		return

	switch (action)
		if ("rider_enter", "rider_exit")
			if (rider && ismob(rider))
				logTheThing("vehicle", rider, null, "[action == "rider_enter" ? "starts driving" : "stops driving"] [src.name] at [log_loc(src)].")

		if ("pax_enter", "pax_exit")
			if (pax && ismob(pax))
				var/logtarget = (rider && ismob(rider) ? rider : null)
				logTheThing("vehicle", pax, logtarget, "[action == "pax_enter" ? "is stuffed into" : "is ejected from"] [src.name] ([forced_in == 1 ? "Forced by" : "Driven by"]: [rider && ismob(rider) ? "[constructTarget(logtarget,"vehicle")]" : "N/A or unknown"]) at [log_loc(src)].")

	return

/obj/vehicle/clowncar/cluwne
	name = "cluwne car"
	desc = "A hideous-looking piece of shit on wheels. You probably shouldn't drive this."
	icon_state = "cluwnecar"
	second_icon = "cluwnecar2"

/obj/vehicle/clowncar/cluwne/Move()
	if(..())
		if(prob(2) && rider)
			eject_rider(1)
		pixel_x = rand(-6, 6)
		pixel_y = rand(-2, 2)
		SPAWN_DBG(1 DECI SECOND)
			pixel_x = rand(-6, 6)
			pixel_y = rand(-2, 2)
		return TRUE

/obj/vehicle/clowncar/cluwne/attackby(var/obj/item/W, var/mob/user)
	eject_rider()
	W.attack(rider, user)
	user.lastattacked = src

/obj/vehicle/clowncar/cluwne/eject_rider(var/crashed, var/selfdismount, var/ejectall = 1)
	..(crashed, selfdismount)
	icon_state = "cluwnecar"
	pixel_x = 0
	pixel_y = 0

/obj/vehicle/clowncar/cluwne/Bump(atom/AM as mob|obj|turf)
	..(AM)
	icon_state = "cluwnecar"
	pixel_x = 0
	pixel_y = 0

/obj/vehicle/clowncar/cluwne/MouseDrop_T(mob/living/carbon/human/target, mob/user)
	if (!istype(target) || target.buckled || LinkBlocked(target.loc,src.loc) || get_dist(user, src) > 1 || get_dist(user, target) > 1 || is_incapacitated(user) || isAI(user))
		return

	var/msg

	if(!user.mind || !iscluwne(user))
		boutput(user, "<span class='alert'>You think it's a REALLY bad idea to use the [src].</span>")
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if(alert(user, "Are you sure you want to get in?",,"Yes","No") == "Yes")
				H.cluwnify()
		return

	if(target == user && !user.stat)	// if drop self, then climbed in
		if(rider)
			return
		rider = target
		actions.interrupt(target, INTERRUPT_ACT)
		src.log_me(src.rider, null, "rider_enter")
		msg = "[user.name] climbs into the driver's seat of the [src]."
		boutput(user, "<span class='notice'>You climb into the driver's seat of the [src].</span>")
	else
		return

	target.set_loc(src)
	for (var/mob/C in AIviewers(src))
		if(C == user)
			continue
		C.show_message(msg, 3)
	return

/obj/vehicle/clowncar/surplus
	name = "Clown Car"
	desc = "A funny-looking car designed for circus events. Seats 30, very roomy! Comes with a free set of clown clothes!"
	icon_state = "clowncar"

	New()
		..()
		new /obj/item/storage/box/costume/clown(src.loc)

//////////////////////////////////////////////////// Rideable cats /////////////////////////////////////////////////////

/obj/vehicle/cat
	name = "Rideable Cat"
	desc = "He looks happy... how odd!"
	icon_state = "segwaycat-norider"
	layer = MOB_LAYER + 1
	soundproofing = 0
	throw_dropped_items_overboard = 1

// Might as well make use of the Garfield sprites (Convair880).

/obj/vehicle/cat/garfield
	name = "Garfield??"
	desc = "I'm not overweight, I'm undertall."
	icon_state = "garfield"

/obj/vehicle/cat/garfield/sex
	name = "sex garfield"
	desc = "sex garfield"
	icon_state = "sexgarfield"
	var/catchphrase_in_progress = 0
	ability_buttons_to_initialize = list(/obj/ability_button/sexgarf)

/obj/vehicle/cat/garfield/sex/proc/catchphrase()
	if (catchphrase_in_progress)
		return

	catchphrase_in_progress = 1
	playsound(src.loc, "sound/misc/sexgarf/garf[rand(1,5)].ogg", 50)
	SPAWN_DBG(3 SECONDS)
		catchphrase_in_progress = 0

/obj/vehicle/cat/odie
	name = "Odie??"
	desc = "Arf arf arf!"
	icon_state = "odie"

/obj/vehicle/cat/Bump(atom/AM as mob|obj|turf)
	if(in_bump)
		return
	if(AM == rider || !rider)
		return
	if(world.timeofday - AM.last_bumped <= 100)
		return
	walk(src, 0)
	..()
	in_bump = 1
	if((isturf(AM) || istype(AM, /mob/living/carbon/wall)) && (rider.bioHolder.HasEffect("clumsy") || rider.reagents.has_reagent("ethanol")))
		boutput(rider, "<span class='alert'><B>You run to the wall!</B></span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><B>[rider] runs into the wall with the [src]!</B></span>", 1)
		eject_rider(2)
		in_bump = 0
		return
	if(ismob(AM))
		var/mob/M = AM
		boutput(rider, "<span class='alert'><B>You run into [M]!</B></span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><B>[rider] runs into [M] with the [src]!</B></span>", 1)
		M.changeStatus("stunned", 8 SECONDS)
		M.changeStatus("weakened", 5 SECONDS)
		eject_rider(2)
		in_bump = 0
		return
	if(isitem(AM))
		if(AM:w_class >= W_CLASS_BULKY)
			boutput(rider, "<span class='alert'><B>You run into [AM]!</B></span>")
			for (var/mob/C in AIviewers(src))
				if(C == rider)
					continue
				C.show_message("<span class='alert'><B>[rider] runs into [AM] with the [src]!</B></span>", 1)
			eject_rider(1)
			in_bump = 0
			return
	if(istype(AM, /obj/vehicle/segway))
		var/obj/vehicle/segway/SG = AM
		if(SG.rider)
			SG.in_bump = 1
			var/mob/M = SG.rider
			var/mob/N = rider
			boutput(N, "<span class='alert'><B>You run into [M]'s [SG]!</B></span>")
			boutput(M, "<span class='alert'><B>[N] runs into your [SG]!</B></span>")
			for (var/mob/C in AIviewers(src))
				if(C == N || C == M)
					continue
				C.show_message("<span class='alert'><B>[N] and [M] crash into each other!</B></span>", 1)
			eject_rider(2)
			SG.eject_rider(1)
			in_bump = 0
			SG.in_bump = 0
			return
	in_bump = 0
	return

/obj/vehicle/cat/eject_rider(var/crashed, var/selfdismount, var/ejectall = 1)
	var/mob/living/rider = src.rider
	..()
	rider.pixel_y = 0
	walk(src, 0)
	if(crashed)
		if(crashed == 2)
			if(istype(src, /obj/vehicle/cat/garfield/sex))
				playsound(src.loc, "sound/misc/sexgarf/garf4.ogg", 70)
			else
				playsound(src.loc, "sound/voice/animal/cat.ogg", 70, 1)
		boutput(rider, "<span class='alert'><B>You are flung over the [src]'s head!</B></span>")
		rider.changeStatus("stunned", 8 SECONDS)
		rider.changeStatus("weakened", 5 SECONDS)
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><B>[rider] is flung over the [src]'s head!</B></span>", 1)
		var/turf/target = get_edge_target_turf(src, src.dir)
		rider.throw_at(target, 5, 1)
		rider = null
		ClearSpecificOverlays("rider")
		return
	if(selfdismount)
		boutput(rider, "<span class='notice'>You dismount from the [src].</span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<B>[rider]</B> dismounts from the [src].", 1)
	rider = null
	ClearSpecificOverlays("rider")
	return

/obj/vehicle/cat/do_special_on_relay(mob/user as mob, dir)
	switch(dir)
		if(NORTH,SOUTH)
			layer = MOB_LAYER+1// TODO Layer wtf
		if(EAST,WEST)
			layer = 3
	return

/obj/vehicle/cat/MouseDrop_T(mob/living/carbon/human/target, mob/user)
	if (rider || !istype(target) || target.buckled || get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.hasStatus(list("weakened", "paralysis", "stunned")) || user.stat || isAI(user))
		return

	var/msg

	if(target == user && !user.stat)	// if drop self, then climbed in
		msg = "[user.name] climbs onto the [src]."
		boutput(user, "<span class='notice'>You climb onto the [src].</span>")
	else if(target != user && !user.restrained())
		msg = "[user.name] helps [target.name] onto the [src]!"
		boutput(user, "<span class='notice'>You help [target.name] onto the [src]!</span>")
	else
		return

	target.set_loc(src)
	rider = target
	rider.pixel_x = 0
	rider.pixel_y = 5
	src.UpdateOverlays(rider, "rider")

	for (var/mob/C in AIviewers(src))
		if(C == user)
			continue
		C.show_message(msg, 3)

	return

/obj/vehicle/cat/Click()
	if(usr != rider)
		..()
		return
	if(!(usr.getStatusDuration("paralysis") || usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened") || usr.stat))
		eject_rider(0, 1)
	return

/obj/vehicle/cat/attack_hand(mob/living/carbon/human/M as mob)
	if(!M || !rider)
		..()
		return
	switch(M.a_intent)
		if("harm", "disarm")
			if(prob(60))
				playsound(src.loc, "sound/impact_sounds/Generic_Shove_1.ogg", 50, 1, -1)
				src.visible_message("<span class='alert'><B>[M] has shoved [rider] off of the [src]!</B></span>")
				if (!rider.hasStatus("weakened"))
					rider.changeStatus("weakened", 2 SECONDS)
					rider.force_laydown_standup()
				eject_rider()
			else
				playsound(src.loc, "sound/impact_sounds/Generic_Swing_1.ogg", 25, 1, -1)
				src.visible_message("<span class='alert'><B>[M] has attempted to shove [rider] off of the [src]!</B></span>")
	return


/obj/vehicle/cat/disposing()
	if(rider)
		boutput(rider, "<span class='alert'><B>Your cat is destroyed!</B></span>")
		eject_rider()
	..()
	return

////////////////////////////////////////////////// Admin bus /////////////////////////////////////

/obj/vehicle/adminbus
	name = "Admin Bus"
	desc = "A short yellow bus that looks reinforced."
	var/badmin_name = "Badmin Bus"
	var/badmin_desc = "A short bus painted in blood that looks horrifyingly evil."
	icon_state = "adminbus"
	var/nonmoving_state = "adminbus"
	var/moving_state = "adminbus2"
	var/badmin_moving_state = "badminbus2"
	var/badmin_nonmoving_state = "badminbus"
	var/antispam = 0
	is_syndicate = 1
	mats = 15
	sealed_cabin = 1
	rider_visible = 0
	ability_buttons_to_initialize = list(/obj/ability_button/loudhorn, /obj/ability_button/stopthebus, /obj/ability_button/togglespook)
	var/gib_onhit = 0
	var/is_badmin_bus = FALSE
	var/darkness = FALSE
	booster_upgrade =1
	delay = 1
	soundproofing = 5

/obj/vehicle/adminbus/Move()
	if(src.darkness)
		if(prob(3))
			src.do_darkness()

	return ..()

/obj/ability_button/loudhorn
	name = "Loudhorn"
	icon = 'icons/ui/abilities.dmi'
	icon_state = "noise"
	var/mysound = 'sound/musical_instruments/Vuvuzela_1.ogg'
	var/mydelay = 1 SECOND
	var/myvolume = 50
	var/active = 0

	Click(location, control, params)
		. = ..()
		if(!the_mob) return
		if(active) return

		var/the_turf = get_turf(the_mob)
		active = 1
		var/mob/my_mob = the_mob

		if(!isturf(my_mob.loc))
			playsound(my_mob.loc, src.mysound, src.myvolume, 1)
		playsound(the_turf, src.mysound, src.myvolume, 1)

		SPAWN_DBG(src.mydelay)
			active = 0

/obj/ability_button/loudhorn/clowncar
	name = "Clown Car Horn"
	icon = 'icons/ui/abilities.dmi'
	icon_state = "noise"
	mysound = 'sound/musical_instruments/Carhorn_1.ogg'
	mydelay = 10 SECONDS
	myvolume = 75

/obj/ability_button/stopthebus
	name = "Stop The Bus"
	icon = 'icons/ui/ManuUI.dmi'
	icon_state = "cancel"
	var/active = 0
	var/mydelay = 0 SECONDS

	Click(location, control, params)
		. = ..()
		if(!the_mob) return
		if(active)
			boutput( the_mob, "<span class='alert'>The brake is on cooldown!</span>" )
			return
		var/mob/my_mob = the_mob
		if(!istype(my_mob.loc, /obj/vehicle)) return
		active = 1
		var/obj/vehicle/v = my_mob.loc
		v.stop()

		SPAWN_DBG(src.mydelay)
			active = 0

	clowncar
		name = "Stop The Car"
		mydelay = 2 SECONDS

/obj/ability_button/togglespook
	name = "Toggle Spook"
	icon = 'icons/ui/context32x32.dmi'
	icon_state = "wraith-break-lights"

	Click(location, control, params)
		. = ..()
		if (!the_mob)
			return
		if(istype(the_mob.loc, /obj/vehicle/adminbus/))
			var/obj/vehicle/adminbus/bus = usr.loc
			bus.darkness = !bus.darkness
			if (bus.darkness)
				boutput( the_mob, "<span class='alert'>The air grows heavy and nearby lights begin to flicker and dim!</span>" )
			else
				boutput( the_mob, "<span class='alert'>Things seem to return to normal.</span>" )

/obj/vehicle/adminbus/Stopped()
	..()
	icon_state = nonmoving_state

/obj/vehicle/adminbus/do_special_on_relay(mob/user as mob, dir)
	icon_state = moving_state
	if(!(world.timeofday - src.antispam <= 60))
		src.antispam = world.timeofday
		playsound(src, "sound/machines/rev_engine.ogg", 50, 1)
		playsound(src.loc, "sound/machines/rev_engine.ogg", 50, 1)
		//play engine sound
		return

// the adminbus has a pressurized cabin!
/obj/vehicle/adminbus/handle_internal_lifeform(mob/lifeform_inside_me, breath_request)
	var/datum/gas_mixture/GM = new()

	var/oxygen = MOLES_O2STANDARD
	var/nitrogen = MOLES_N2STANDARD
	var/sum = oxygen + nitrogen

	GM.oxygen = (oxygen/sum)*breath_request
	GM.nitrogen = (nitrogen/sum)*breath_request
	GM.temperature = T20C

	return GM

/obj/vehicle/adminbus/Click()
	if(usr != rider)
		var/mob/M = usr
		if(M.client && M.client.holder && M.loc == src)
			M.show_message(text("<span class='alert'><B>You exit the []!</B></span>", src), 1)
			M.remove_adminbus_powers()
			M.set_loc(src.loc)
			return
		..()
		return
	if(!(usr.getStatusDuration("paralysis") || usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened") || usr.stat))
		eject_rider(0, 1, 0)
	return

/obj/vehicle/adminbus/attack_hand(mob/living/carbon/human/M as mob)
	if(!M || !(M.client && M.client.holder))
		..()
		return
	if(M.is_hulk())
		if(prob(40))
			boutput(M, "<span class='alert'><B>You smash the puny [src] apart!</B></span>")
			playsound(src, "shatter", 70, 1)
			playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)

			for(var/mob/N in AIviewers(M, null))
				if(N == M)
					continue
				N.show_message("<span class='alert'><B>[M] smashes the [src] apart!</B></span>", 1)
			for(var/atom/A in src.contents)
				if(ismob(A))
					var/mob/N = A
					N.show_message("<span class='alert'><B>[M] smashes the [src] apart!</B></span>", 1)
					N.set_loc(src.loc)
				else if (isobj(A))
					var/obj/O = A
					O.set_loc(src.loc)
			var/obj/item/scrap/S = new
			S.size = 4
			S.update()
			qdel(src)
		else
			boutput(M, "<span class='alert'><B>You punch the puny [src]!</B></span>")
			playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
			for(var/mob/N in AIviewers(M, null))
				if(N == M)
					continue
				N.show_message("<span class='alert'><B>[M] punches the [src]!</B></span>", 1)
			for(var/atom/A in src.contents)
				if(ismob(A))
					var/mob/N = A
					N.show_message("<span class='alert'><B>[M] punches the [src]!</B></span>", 1)
	else
		playsound(src.loc, "sound/machines/click.ogg", 15, 1, -3)
		if(rider && prob(40))
			playsound(src.loc, "sound/impact_sounds/Generic_Shove_1.ogg", 50, 1, -1)
			src.visible_message("<span class='alert'><B>[M] has pulled [rider] out of the [src]!</B></span>", 1)
			rider.changeStatus("weakened", 2 SECONDS)
			eject_rider(0,0,0)
		else
			if(src.contents.len)
				playsound(src.loc, "sound/impact_sounds/Generic_Shove_1.ogg", 50, 1, -1)
				src.visible_message("<span class='alert'><B>[M] opens up the [src], spilling the contents out!</B></span>", 1)
				for(var/atom/A in src.contents)
					if(ismob(A))
						var/mob/N = A
						N.show_message("<span class='alert'><B>You are let out of the [src] by [M]!</B></span>", 1)
						N.set_loc(src.loc)
					else if (isobj(A))
						var/obj/O = A
						O.set_loc(src.loc)
			else
				boutput(M, "<span class='notice'>There's nothing inside of the [src].</span>")
				return
	return

/obj/vehicle/adminbus/MouseDrop_T(mob/living/carbon/human/target, mob/user)
	if (!istype(target) || target.buckled || LinkBlocked(target.loc,src.loc) || get_dist(user, src) > 1 || get_dist(user, target) > 1 || is_incapacitated(user) || isAI(user))
		return

	var/msg

	if(!(user.client && user.client.holder))
		boutput(user, "<span class='notice'>You don't feel cool enough to use the [src].</span>")
		return

	if(target == user && !user.stat)	// if drop self, then climbed in
		target.set_loc(src)
		if(rider)
			msg = "[user.name] climbs into the front of the [src]."
			boutput(user, "<span class='notice'>You climb into the front of the [src].</span>")
		else
			rider = target
			msg = "[user.name] climbs into the driver's seat of the [src]."
			boutput(user, "<span class='notice'>You climb into the driver's seat of the [src].</span>")
			rider.add_adminbus_powers()
			sleep(1 SECOND)
			handle_button_addition()
	else if(target != user && !user.restrained())
		target.set_loc(src)
		msg = "[user.name] stuffs [target.name] into the back of the [src]!"
		boutput(user, "<span class='notice'>You stuff [target.name] into the back of the [src]!</span>")
	else
		return
	for (var/mob/C in AIviewers(src))
		if(C == user)
			continue
		C.show_message(msg, 3)
	return

/obj/vehicle/adminbus/Bump(atom/AM as mob|obj|turf)
	if(in_bump)
		return
	if(AM == rider || !rider)
		return
	if(!is_badmin_bus && world.timeofday - AM.last_bumped <= 100)
		return
	if(is_badmin_bus && world.timeofday - AM.last_bumped <= 50)
		return
	walk(src, 0)
	icon_state = nonmoving_state
	..()
	in_bump = 1
	if(isturf(AM))
		if (!isconstructionturf(AM))
			in_bump = 0
			return
		if(istype(AM, /turf/wall/r_wall || istype(AM, /turf/wall/auto/reinforced)) && prob(40))
			in_bump = 0
			return
		if(istype(AM, /turf/wall))
			var/turf/wall/T = AM
			T.dismantle_wall(1)
			playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
			playsound(src, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
			boutput(rider, "<span class='alert'><B>You crash through the wall!</B></span>")
			for(var/mob/C in viewers(src))
				shake_camera(C, 10, 16)
				if(C == rider)
					continue
				C.show_message("<span class='alert'><B>The [src] crashes through the wall!</B></span>", 1)
			in_bump = 0
			return
	if(ismob(AM))
		var/mob/M = AM
		boutput(rider, "<span class='alert'><B>You crash into [M]!</B></span>")
		for (var/mob/C in viewers(src))
			shake_camera(C, 8, 12)
			if(C == rider)
				continue
			C.show_message("<span class='alert'><B>The [src] crashes into [M]!</B></span>", 1)
		if(src.gib_onhit)
			M.gib()
		else
			M.changeStatus("stunned", 8 SECONDS)
			M.changeStatus("weakened", 5 SECONDS)
			var/turf/target = get_edge_target_turf(src, src.dir)
			M.throw_at(target, 10, 2)
		playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
		playsound(src, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
		in_bump = 0
		return
	if(isobj(AM))
		var/obj/O = AM
		if(O.density)
			boutput(rider, "<span class='alert'><B>You crash into [O]!</B></span>")
			for (var/mob/C in viewers(src))
				shake_camera(C, 8, 12)
				if(C == rider)
					continue
				C.show_message("<span class='alert'><B>The [src] crashes into [O]!</B></span>", 1)
			var/turf/target = get_edge_target_turf(src, src.dir)
			playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
			playsound(src, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
			O.throw_at(target, 10, 2)
			if(istype(O, /obj/window) || istype(O, /obj/grille) || istype(O, /obj/machinery/door) || istype(O, /obj/structure/girder) || istype(O, /obj/foamedmetal))
				qdel(O)
			if(istype(O, /obj/critter))
				O:CritterDeath()
			if(!isnull(O) && is_badmin_bus)
				O:ex_act(OLD_EX_HEAVY)
			in_bump = 0
			return
	in_bump = 0
	return

/obj/vehicle/adminbus/bullet_act(flag, A as obj)
	return

/obj/vehicle/adminbus/meteorhit()
	return

/obj/vehicle/adminbus/disposing()
	if(rider)
		boutput(rider, "<span class='alert'><B>Your [src] is destroyed!</B></span>")
		eject_rider(1)
	..()
	return

/obj/vehicle/adminbus/ex_act(severity)
	return

/obj/vehicle/adminbus/eject_rider(var/crashed, var/selfdismount, var/ejectall = 1)
	var/mob/living/rider = src.rider
	..()
	rider.remove_adminbus_powers()
	walk(src, 0)
	if(crashed)
		if(crashed == 2)
			playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
		playsound(src.loc, "shatter", 40, 1)
		boutput(rider, "<span class='alert'><B>You are flung through the [src]'s windshield!</B></span>")
		rider.changeStatus("stunned", 8 SECONDS)
		rider.changeStatus("weakened", 5 SECONDS)
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='alert'><B>[rider] is flung through the [src]'s windshield!</B></span>", 1)
		var/turf/target = get_edge_target_turf(src, src.dir)
		rider.throw_at(target, 5, 1)
		if(prob(40) && length(src.contents))
			src.visible_message("<span class='alert'><B>Everything in the [src] flies out!</B></span>")
			for(var/atom/A in src.contents)
				if(ismob(A))
					var/mob/N = A
					N.show_message(text("<span class='alert'><B>You are flung out of the []!</B></span>", src), 1)
					N.set_loc(src.loc)
				else if (isobj(A))
					var/obj/O = A
					O.set_loc(src.loc)

	if(selfdismount)
		boutput(rider, "<span class='notice'>You climb out of the [src].</span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<B>[rider]</B> climbs out of the [src].", 1)

	rider = null
	src.icon_state = src.nonmoving_state
	if (src.is_badmin_bus)
		src.toggle_badmin()


/obj/vehicle/adminbus/attackby(var/obj/item/I, var/mob/user)
	if(!(user.client && user.client.holder))
		boutput(user, "<span class='notice'>You don't feel cool enough to use the [src].</span>")
		return

	var/obj/item/grab/G = I
	if(istype(G))	// handle grabbed mob
		if(ismob(G.affecting))
			var/mob/GM = G.affecting
			GM.set_loc(src)
			boutput(user, "<span class='notice'>You stuff [GM.name] into the back of the [src].</span>")
			boutput(GM, "<span class='alert'><B>[user] stuffs you into the back of the [src]!</B></span>")
			for (var/mob/C in AIviewers(src))
				if(C == user)
					continue
				C.show_message("<span class='alert'><B>[GM.name] has been stuffed into the back of the [src] by [user]!</B></span>", 3)
			qdel(G)
			return
	..()
	return

/obj/vehicle/adminbus/proc/do_darkness()
	if(prob(50))
		playsound(src.loc, 'sound/effects/ghost.ogg', 50, 1)
	else
		playsound(src.loc, 'sound/effects/ghost2.ogg', 50, 1)

	var/list/apcs = bounds(src, 192)
	for(var/obj/machinery/power/apc/apc in apcs)
		if(prob(60))
			apc.overload_lighting()

	if(prob(50))
		gibs(get_turf(src))

/obj/vehicle/adminbus/proc/toggle_badmin()
	if (src.is_badmin_bus)
		src.name = initial(src.name)
		src.desc = initial(src.desc)
		src.moving_state = initial(src.moving_state)
		src.nonmoving_state = initial(src.nonmoving_state)
		src.is_badmin_bus = FALSE
		boutput(usr, "<span class='info'>Badmin mode disabled.</span>")
	else
		src.name = src.badmin_name
		src.desc = src.badmin_desc
		src.moving_state = src.badmin_moving_state
		src.nonmoving_state = src.badmin_nonmoving_state
		src.is_badmin_bus = TRUE
		boutput(usr, "<span class='info'>Badmin mode enabled.</span>")

/client/proc/toggle_gib_onhit()
	set category = "Adminbus"
	set name = "Toggle Gib On Collision"
	set desc = "Toggle gibbing when colliding with mobs."

	if(usr.stat)
		boutput(usr, "<span class='alert'>Not when you are incapacitated.</span>")
		return
	if(istype(usr.loc, /obj/vehicle/adminbus))
		var/obj/vehicle/adminbus/bus = usr.loc
		if(bus.gib_onhit)
			bus.gib_onhit = 0
			boutput(usr, "<span class='alert'>No longer gibbing on collision.</span>")
		else
			bus.gib_onhit = 1
			boutput(usr, "<span class='alert'>You will now gib mobs on collision. Let's paint the town red!</span>")
	else
		boutput(usr, "<span class='alert'>Uh-oh, you aren't in the adminbus! Report this.</span>")

/client/proc/toggle_badminbus()
	set category = "Adminbus"
	set name = "Toggle Badmin Mode"
	set desc = "Become the Badmin Bus"

	if(!isalive(usr))
		boutput(usr, "<span class='alert'>Not when you are incapacitated.</span>")
		return
	if(istype(usr.loc, /obj/vehicle/adminbus))
		var/obj/vehicle/adminbus/bus = usr.loc
		bus.toggle_badmin()
	else
		boutput(usr, "<span class='alert'>Uh-oh, you aren't in the adminbus! Report this.</span>")

/*
/atom/movable/effect/darkness
	icon = 'icons/effects/64x64.dmi'
	icon_state = "spooky"
	layer = EFFECTS_LAYER_BASE
	mouse_opacity = 0
	//blend_mode = BLEND_MULTIPLY

	New()
		..()
		src.Scale(9,9)
*/

/mob/proc/add_adminbus_powers()
	if(src.client.holder && src.client.holder.rank && src.client.holder.level >= LEVEL_PA)
		src.client.verbs += /client/proc/toggle_gib_onhit
		src.client.verbs += /client/proc/toggle_badminbus
	return

/mob/proc/remove_adminbus_powers()
	src.client.verbs -= /client/proc/toggle_gib_onhit
	src.client.verbs -= /client/proc/toggle_badminbus
	return

//////////////////////////////////////////////////////////////// Battle Bus //////////////////////////

/obj/vehicle/adminbus/battlebus
	name = "Battle Bus"
	desc = "A bus made for war."
	icon = 'icons/obj/vehicles/battlebus.dmi'
	icon_state = "adminbus"
	moving_state = "adminbus2"
	nonmoving_state = "adminbus"
	badmin_moving_state = "adminbus2"
	badmin_nonmoving_state = "adminbus"
	badmin_name = "Baddler Bus"
	badmin_desc = "An unstoppable bus made for war."
	ability_buttons_to_initialize = list(/obj/ability_button/loudhorn, /obj/ability_button/stopthebus, /obj/ability_button/togglespook, /obj/ability_button/battlecannon, /obj/ability_button/omnicannon, /obj/ability_button/bombchute, /obj/ability_button/hotwheels, /obj/ability_button/staticcharge)
	var/datum/projectile/P = new/datum/projectile/special/spawner/battlecrate
	var/datum/projectile/special/spreader/uniform_burst/circle/P2 = new
	var/power_hotwheels = FALSE
	var/power_staticcharge = FALSE
	var/power_bomberbus = FALSE
	var/power_bomberbus_chance = 25
	var/power_bomberbus_type = /obj/bomberman

	New()
		..()

		P2.spread_projectile_type = /datum/projectile/fireball
		P2.pellets_to_fire = 10
		P2.pellet_shot_volume = 75 / P2.pellets_to_fire //anti-ear destruction

	do_special_on_relay(mob/user, dir) //this should probably actually be inside an overriden Move() proc, but I've preserved the original behavior here instead.
		icon_state = moving_state
		if(src.power_hotwheels)
			tfireflash(get_turf(src), 0, 100)
		if(src.power_staticcharge)
			elecflash(get_turf(src),radius=0, power=2, exclude_center = 0)
		if(src.power_bomberbus && prob(power_bomberbus_chance))
			new src.power_bomberbus_type(get_turf(src))
		return


/obj/ability_button/battlecannon
	name = "Battle Cannon"
	icon = 'icons/ui/buildmode.dmi'
	icon_state = "buildmode4"

	Click(location, control, params)
		. = ..()
		if (!the_mob)
			return
		if(istype(the_mob.loc, /obj/vehicle/adminbus/battlebus))
			var/obj/vehicle/adminbus/battlebus/bus = usr.loc
			shoot_projectile_DIR(bus, bus.P, the_mob.dir)

/obj/ability_button/omnicannon
	name = "Omni Cannon"
	icon = 'icons/ui/spell_buttons.dmi'
	icon_state = "pandemonium"

	Click(location, control, params)
		. = ..()
		if (!the_mob)
			return
		if(istype(the_mob.loc, /obj/vehicle/adminbus/battlebus))
			var/obj/vehicle/adminbus/battlebus/bus = usr.loc

			shoot_projectile_DIR(bus, bus.P2, NORTH)

/obj/ability_button/hotwheels
	name = "Hot Wheels"
	icon = 'icons/ui/critter_ui.dmi'
	icon_state = "fire_e_sprint"

	Click(location, control, params)
		. = ..()
		if (!the_mob)
			return
		if(istype(the_mob.loc, /obj/vehicle/adminbus/battlebus))
			var/obj/vehicle/adminbus/battlebus/bus = usr.loc
			bus.power_hotwheels = !bus.power_hotwheels
			if (bus.power_hotwheels)
				boutput( the_mob, "<span class='alert'>Hot wheels engaged!</span>" )
			else
				boutput( the_mob, "<span class='alert'>Your tires begin to cooldown.</span>" )

/obj/ability_button/staticcharge
	name = "Static Charge"
	icon = 'icons/ui/critter_ui.dmi'
	icon_state = "zzzap"

	Click(location, control, params)
		. = ..()
		if (!the_mob)
			return
		if(istype(the_mob.loc, /obj/vehicle/adminbus/battlebus))
			var/obj/vehicle/adminbus/battlebus/bus = usr.loc
			bus.power_staticcharge = !bus.power_staticcharge
			if (bus.power_staticcharge)
				boutput( the_mob, "<span class='alert'>The bus begins to tingle with static!</span>" )
			else
				boutput( the_mob, "<span class='alert'>The static charge disipates.</span>" )

/obj/ability_button/bombchute
	name = "Bomb Chute"
	icon = 'icons/ui/critter_ui.dmi'
	icon_state = "fire_e_flamethrower"

	Click(location, control, params)
		. = ..()
		if (!the_mob)
			return
		if(istype(the_mob.loc, /obj/vehicle/adminbus/battlebus))
			var/obj/vehicle/adminbus/battlebus/bus = usr.loc
			bus.power_bomberbus = !bus.power_bomberbus
			if (bus.power_bomberbus)
				boutput( the_mob, "<span class='alert'>The bomb chute springs open!</span>" )
			else
				boutput( the_mob, "<span class='alert'>The bomb chute seals tightly shut.</span>" )

//////////////////////////////////////////////////////////////// Forklift //////////////////////////

/obj/vehicle/forklift
	name = "forklift"
	desc = "A vehicle used to transport crates."
	icon_state = "forklift"
	anchored = 1
	mats = 12
	var/list/helditems = list()	//Items being held by the forklift
	var/helditems_maximum = 3
	var/openpanel = 0			//1 when the back panel is opened
	var/broken = 0				//1 when the forklift is broken
	var/light = 0				//1 when the yellow light is on
	soundproofing = 5
	throw_dropped_items_overboard = 1
	var/image/image_crate = null
	var/image/image_under = null
	attacks_fast_eject = 0
	delay = 2.5
	var/datum/movement_controller/forklift/movement_controller
	ability_buttons_to_initialize = list(/obj/ability_button/toggle_automove)
	var/list/item_offsets = list(0,0,0)

/obj/vehicle/forklift/New()
	..()
	movement_controller = new(src)
	src.add_sm_light("forklift\ref[src]", list(0.5*255,0.5*255,0.5*255,255*0.67), directional = 1)


/obj/vehicle/forklift/examine()
	. = ..()
	var/list/examine_text = list()	//Shows who is driving it and also the items being carried
	var/obj/HI
	if(src.rider)
		examine_text += "[src.rider] is using it. "
	if(helditems.len >= 1)
		if (istype(helditems[1], /obj/))
			HI = helditems[1]
			examine_text += "It is carrying \a [HI.name]"
		if(helditems.len >= 2)
			for(var/i=2,i<=helditems.len-1,i++)
				if (istype(helditems[i], /obj/))
					HI = helditems[i]
					examine_text += ", [HI.name]"
			if (istype(helditems[helditems.len], /obj/))
				HI = helditems[helditems.len]
			examine_text += " and \a [HI.name]"
		examine_text += "."
	. += examine_text.Join("")

/obj/vehicle/forklift/verb/enter_forklift()
	set src in oview(1)
	set category = "Local"

	if (usr.stat)
		return

	if(!ishuman(usr))
		return

	if (src.rider)
		if(src.rider == usr)
			boutput(usr, "You are already in [src]!")
			return
		boutput(usr, "[src.rider] is using [src]!")
		return

	//if successful
	var/mob/M = usr
	M.set_loc(src)
	src.rider = M
	boutput(usr, "You get into [src].")
	src.update_overlays()
	if (rider.client)
		handle_button_addition()
	return

/obj/vehicle/forklift/verb/exit_forklift()
	set src in oview(1)
	set category = "Local"

	if (usr.stat)
		return

	if (usr.loc != src)
		boutput(usr, "You aren't in [src]!")
		return

	//if successful
	eject_rider()
	return

/obj/vehicle/forklift/Click()
	//Click the forklift when inside it to get out
	if(src.rider != usr)
		..()
		return

	if (usr.stat)
		return

	eject_rider()
	return

/obj/vehicle/forklift/eject_rider(var/crashed, var/selfdismount)
	if (!src.rider)
		return

	var/mob/living/rider = src.rider
	..(ejectall = 0)

	boutput(rider, "You get out of [src].")

	//Stops items from being lost forever
	for (var/obj/item/I in src)
		if (I in helditems)
			continue
		I.set_loc(src.loc)

	for (var/mob/M in src)
		M.set_loc(src.loc)

	src.update_overlays()

//We, unfortunately, can't use the base relaymove here because the forklift has some
// special behaviors with overlays and underlays that produce weird behaviors
// (ghost riders, phantom crates) when combined with the base relaymove
/obj/vehicle/forklift/relaymove(mob/user as mob, direction)
	return
	/*
	if (user.stat)
		return

	if (broken)
		return

	var/turf/T = get_turf(src)
	if(T.throw_unlimited && istype(T, /turf/space) && !src.booster_upgrade)
		return

	//forklift
	if(src.rider && user == src.rider)
		var/td = max(src.delay, MINIMUM_EFFECTIVE_DELAY)
		if (!src.booster_upgrade)
			if(T.throw_unlimited && istype(T, /turf/space))
				return
		src.glide_size = (32 / td) * world.tick_lag
		for(var/mob/M in src)
			M.glide_size = src.glide_size
			M.animate_movement = SYNC_STEPS
		if(src.booster_upgrade)
			src.UpdateOverlays(booster_image, "booster_image")
		walk(src, direction, td)
		src.glide_size = (32 / td) * world.tick_lag
		for(var/mob/M in src)
			M.glide_size = src.glide_size
			M.animate_movement = SYNC_STEPS
	else
		for(var/mob/M in src.contents)
			M.set_loc(src.loc)*/

/obj/vehicle/forklift/verb/toggle_lights()
	set category = "Forklift"
	set src = usr.loc

	if (usr.stat)
		return

	if (broken)
		boutput(usr, "You try to turn on the lights. Nothing happens.")

	light = !light
	update_overlays()
	src.toggle_sm_light(light)

//atom to forklift
/obj/vehicle/forklift/MouseDrop_T(atom/movable/A as obj|mob, mob/user as mob)

	if (user.stat)
		return

	//pick up crates with forklift
	if((istype(A, /obj/storage/crate) || istype(A, /obj/storage/cart) || istype(A, /obj/storage/secure/crate)) && get_dist(A, src) <= 1 && src.rider == user && helditems.len != helditems_maximum && !broken)
		A.set_loc(src)
		helditems.Add(A)
		update_overlays()
		boutput(user, "<span class='notice'><B>You pick up the [A.name].</B></span>")
		for (var/mob/C in AIviewers(src))
			if(C == rider)
				continue
			C.show_message("<span class='notice'><B>[src] picks up the [A.name].</B></span>", 1)
		return

	//Very funny
	if(istype(A, /obj/item/kitchen/utensil/fork))
		boutput(user, "You don't think [src] has enough utensil strength to pick this up.")
		return

	if(ishuman(A) && get_dist(user, src) <= 1  && get_dist(A, user) <= 1 && !rider)
		if (A == user)
			boutput(user, "You get into [src].")
		else
			boutput(user, "<span class='notice'>You help [A] onto [src]!</span>")
		A.set_loc(src)
		src.rider = A
		src.update_overlays()
		if (rider.client)
			handle_button_addition()
		return

//forklift to other atom
/obj/vehicle/forklift/MouseDrop(atom/over_object)
	if(get_dist(src.loc,over_object) >1)
		boutput(usr, "<span class='notice'><B>That's too far.</B></span>")
		return ..()
	if(isturf(over_object))
		if(length(helditems))
			var/obj/to_unload = helditems[length(helditems)]
			helditems.Remove(to_unload)
			to_unload.set_loc(over_object)
			src.update_overlays()
			boutput(usr, "<span class='notice'><B>You unload [to_unload].</B></span>")
	else
		..() //IDK if this is of any use

/obj/vehicle/forklift/attack_hand(mob/living/carbon/human/M as mob)
	if(!M || !rider)
		..()
		return
	switch(M.a_intent)
		if("harm", "disarm")
			if(prob(40) || isunconscious(rider))
				playsound(src.loc, "sound/impact_sounds/Generic_Shove_1.ogg", 50, 1, -1)
				src.visible_message("<span class='alert'><B>[M] has shoved [rider] off of [src]!</B></span>")
				if (!rider.hasStatus("weakened"))
					rider.changeStatus("weakened", 2 SECONDS)
					rider.force_laydown_standup()
				rider.set_loc(src.loc)
				src.rider = null
				src.update_overlays()
			else
				playsound(src.loc, "sound/impact_sounds/Generic_Swing_1.ogg", 25, 1, -1)
				src.visible_message("<span class='alert'><B>[M] has attempted to shove [rider] off of [src]!</B></span>")
	return

/obj/vehicle/forklift/verb/drop_crates()
	set category = "Forklift"
	set src = usr.loc

	if (usr.stat)
		return

	var/turf/T = get_turf(src)
	if(T.throw_unlimited && istype(T, /turf/space))
		return

	if(helditems.len >= 1)

		if(helditems.len == 1)
			var/obj/O = helditems[1]
			for (var/mob/C in AIviewers(src))
				C.show_message("<span class='notice'><B>[src] leaves the [O.name] on [src.loc].</B></span>", 1)
			boutput(usr, "<span class='notice'><B>You leave the [O.name] on [src.loc].</B></span>")
		if(helditems.len > 1)
			for (var/mob/C in AIviewers(src))
				C.show_message("<span class='notice'><B>[src] leaves [helditems.len] crates on [src.loc].</B></span>", 1)
			boutput(usr, "<span class='notice'><B>You leave [helditems.len] crates on [src.loc].</B></span>")

		for (var/obj/HI in helditems)
			HI.set_loc(src.loc)

		helditems.len = 0
		update_overlays()
	return

obj/vehicle/forklift/attackby(var/obj/item/I, var/mob/user)
	//Use screwdriver to open/close the forklift's back panel
	if (isscrewingtool(I))
		boutput(user, "You [openpanel ? "lock" : "unlock"] [src]'s panel with [I].")
		openpanel = !openpanel
		update_overlays()
		return

	//Breaking the forklift
	if (issnippingtool(I))
		if (openpanel && !broken)
			boutput(user, "<span class='notice'>You cut [src]'s wires!<span>")
			new /obj/item/cable_coil/cut/small( src.loc )
			break_forklift()
		return

	//Repairing the forklift
	if (istype(I,/obj/item/cable_coil))
		if (openpanel && broken)
			var/obj/item/cable_coil/coil = I
			coil.use(5)
			boutput(user, "<span class='notice'>You replace [src]'s wires!</span>")
			broken = 0
			if (helditems_maximum < 4)
				helditems_maximum = 4
			return

	return ..() // attacking rider on forklift

/obj/vehicle/forklift/proc/break_forklift()
	broken = 1
	//break the light if it is on
	if (light)
		light = 0
		src.toggle_sm_light(0)
		update_overlays()

/obj/vehicle/forklift/proc/update_overlays()
	if (light)
		src.UpdateOverlays(image(src.icon, "forklift_light"), "light")
	else
		src.UpdateOverlays(null, "light")

	if (openpanel)
		src.UpdateOverlays(image(src.icon, "forklift_panel"), "panel")
	else
		src.UpdateOverlays(null, "panel")

	if (!src.image_crate)
		src.image_crate = image(src.icon, "forklift_crate")
	//populate crates
	for (var/i = 1, i <= length(helditems), i++)
		image_crate.icon_state = "forklift_crate[min(i,4)]" //there's 4 different crate sprites that have different cutouts for the fork.
		image_crate.pixel_y = 7*(i-1)
		if (i > 3)
			if (length(item_offsets) < i)
				var/jitter = round(i/6)+1
				item_offsets.Add(item_offsets[i-1] + rand(-jitter,jitter))
		image_crate.pixel_x = item_offsets[i]//rand(-1,1)
		src.UpdateOverlays(src.image_crate, "crate[i]")
	//write null to empty slots
	for (var/i = length(helditems) + 1, i <= src.helditems_maximum, i++)
		src.UpdateOverlays(null, "crate[i]")

	if (length(item_offsets) > length(helditems))
		item_offsets.Cut(max(length(helditems),3) + 1) //prune unused offsets so they can be random again but not the bottom ones which are always 0

	if (src.rider)
		src.icon_state = "forklift1"
		src.underlays += rider
		if (!src.image_under)
			src.image_under = image(src.icon, "forklift")
		src.underlays += src.image_under
	else
		src.icon_state = "forklift"
		src.underlays = null

/obj/vehicle/forklift/bullet_act(flag, A as obj)
	if(rider && rider_visible)
		rider.bullet_act(flag, A)
		//do not eject!
	else
		..()

/obj/ability_button/toggle_automove
	name = "Toggle Continuous Movement"
	icon = 'icons/ui/abilities.dmi'
	icon_state = "pedal_off"

	Click()
		if(!the_mob) return

		if (istype(the_mob.loc, /obj/vehicle/forklift))
			var/obj/vehicle/forklift/fork = the_mob.loc
			var/datum/movement_controller/forklift/MC = fork.movement_controller
			if (MC.automove)
				walk(fork, 0)
				icon_state = "pedal_off"
			else
				icon_state = "pedal_on"
			MC.automove = !MC.automove
		return
