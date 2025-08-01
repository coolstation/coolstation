// Cleaned up the ancient code that used to be here (Convair880).
ABSTRACT_TYPE(/obj/item/mine) //To be safe I guess
/obj/item/mine
	name = "land mine (parent)"
	desc = "You shouldn't be able to see this!"
	w_class = W_CLASS_NORMAL
	density = 0
	layer = OBJ_LAYER
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "mine"
	is_syndicate = 1
	mats = 6
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER
	var/suppress_flavourtext = 0
	var/armed = 0
	var/used_up = 0
	var/obj/item/device/timer/our_timer = null

	New()
		..()
		if (src.armed)
			src.update_icon()

		if (!src.our_timer || !istype(src.our_timer))
			src.our_timer = new /obj/item/device/timer(src)
			src.our_timer.master = src
			src.our_timer.ui_name = "Mine Timer"
			src.our_timer.lock_once_timer_set = TRUE
		return

	examine()
		. = ..()
		if (!src.suppress_flavourtext)
			. += "It appears to be [src.armed == 1 ? "armed" : "disarmed"]."

	disposing()
		//These haven't been cleaning up their timers for probably a decade :)
		qdel(our_timer)
		our_timer = null
		..()

	attack_hand(mob/user as mob)
		src.add_fingerprint(user)

		if (prob(50) && src.armed && !src.used_up)
			if (!src.suppress_flavourtext)
				src.visible_message("<font color='red'><b>[user] fumbles with the [src.name], accidentally setting it off!</b></span>")
			src.triggered(user)
			return

		..()
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (prob(50) && src.armed && !src.used_up)
			if (!src.suppress_flavourtext)
				src.visible_message("<font color='red'><b>[user] fumbles with the [src.name], accidentally setting it off!</b></span>")
			src.triggered(user)
			return

		..()
		return

	pull(mob/user as mob)
		if (src.armed && !src.used_up)
			if (!src.suppress_flavourtext)
				src.visible_message("<font color='red'><b>[user] tries to pull the [src.name], triggering the anti-tamper mechanism!</b></span>")
			src.triggered(user)
			return

		..()
		return

	attack_self(mob/user as mob)
		src.add_fingerprint(user)

		if (src.used_up != 0)
			user.show_text("The [src.name] has already been triggered and is no longer functional.", "red")
			return

		if (src.armed)
			src.armed = 0
			src.update_icon()
			user.show_text("You disarm the [src.name].", "blue")
			logTheThing("bombing", user, null, "has disarmed the [src.name] at [log_loc(user)].")

		if (src.our_timer && istype(src.our_timer))
			src.our_timer.attack_self(user)

		return

	receive_signal()
		if (src.used_up != 0)
			return

		playsound(src.loc, "sound/weapons/armbomb.ogg", 100, 1)
		src.armed = 1
		src.update_icon()
		return

	// Timer process() expects this to be here. Could be used for dynamic icon_states updates.
	proc/c_state()
		return

	ex_act(severity)
		if (src.used_up != 0 || !src.armed)
			return
		if (!src.suppress_flavourtext)
			src.visible_message("<font color='red'><b>The explosion sets off the [src.name]!</b></span>")
		src.triggered()
		return

	emp_act()
		if (src.used_up != 0 || !src.armed)
			return
		if (!src.suppress_flavourtext)
			src.visible_message("<font color='red'><b>The electromagnetic pulse sets off the [src.name]!</b></span>")
		src.triggered()
		return

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (src.used_up != 0 || !src.armed)
			return 0
		if (!src.suppress_flavourtext)
			src.visible_message("<font color='red'><b>The electric charge sets off the [src.name]!</b></span>")
		src.triggered(user)
		return 1

	HasEntered(AM as mob|obj)
		if (AM == src || !(istype(AM, /obj/vehicle) || istype(AM, /obj/machinery/bot) || ismob(AM)))
			return
		if (ismob(AM) && (!isliving(AM) || isintangible(AM) || iswraith(AM)))
			return
		if (src.used_up != 0)
			return
		if (!src.armed)
			return

		if (!src.suppress_flavourtext)
			src.visible_message("<font color='red'><b>[AM] triggers the [src.name]!</b></span>")
		src.triggered(AM)
		return

	proc/update_icon()
		if (!src || !istype(src))
			return

		if (src.armed && !findtext(src.icon_state, "_armed"))
			src.icon_state = "[src.icon_state]_armed"
		else
			src.icon_state = replacetext(src.icon_state, "_armed", "")

		return

	// Special effects handled by every type of mine.
	proc/custom_stuff(var/atom/M)
		return

	proc/triggered(var/atom/M)
		if (!src || !istype(src))
			return

		if (src.used_up != 0)
			qdel(src)
			return
		src.used_up = 1

		elecflash(src)

		src.custom_stuff(M)
		src.log_me(M)

		qdel(src)
		return

	// For bioeffects or stuns, basically everything that should affect all mobs located on src.loc when triggered.
	proc/get_mobs_on_turf(var/radius = 0)
		var/list/mobs = list()

		if (!src || !istype(src))
			return mobs

		var/turf/T = get_turf(src)

		for (var/mob/living/L in range(radius,T))
			if (isintangible(L) || iswraith(L))
				continue
			mobs += L

		return mobs

	proc/log_me(var/atom/M, var/mob/T)
		if (!src || !istype(src))
			return
		var/logtarget = (T && ismob(T) ? T : null)
		logTheThing("bombing", M && ismob(M) ? M : null, logtarget, "The [src.name] was triggered at [log_loc(src)][T && ismob(T) ? ", affecting [constructTarget(logtarget,"bombing")]." : "."] Last touched by: [src.fingerprintslast ? "[src.fingerprintslast]" : "*null*"]")
		return

/obj/item/mine/radiation
	name = "radiation land mine"
	desc = "An anti-personnel mine designed to heavily irradiate its target."
	icon_state = "mine_radiation"

	armed
		armed = 1

	custom_stuff(var/atom/M)
		if (!src || !istype(src))
			return

		var/list/mobs = src.get_mobs_on_turf()
		if (mobs.len)
			for (var/mob/living/L in mobs)
				if (istype(L))
					L.changeStatus("radiation", 60 SECONDS)
					if (L.bioHolder && ishuman(L))
						L.bioHolder.RandomEffect("bad")
					if (L != M)
						src.log_me(null, L)

		playsound(src.loc, 'sound/weapons/ACgun2.ogg', 50, 1)
		return

/obj/item/mine/incendiary
	name = "incendiary land mine"
	desc = "An anti-personnel mine equipped with an incendiary payload."
	icon_state = "mine_incendiary"

	armed
		armed = 1

	custom_stuff(var/atom/M)
		if (!src || !istype(src))
			return

		fireflash_sm(get_turf(src), 3, 3000, 500)
		playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1)
		return

/obj/item/mine/stun
	name = "stun land mine"
	desc = "An anti-personnel mine designed to stun its victim nonlethally."
	icon_state = "mine_stun"

	armed
		armed = 1

	custom_stuff(var/atom/M)
		if (!src || !istype(src))
			return

		var/list/mobs = src.get_mobs_on_turf(1)
		if (mobs.len)
			for (var/mob/living/L in mobs)
				if (istype(L))
					L.changeStatus("weakened", 15 SECONDS)
					L.stuttering += 15
					if (L != M)
						src.log_me(null, L)

		playsound(src.loc, 'sound/weapons/flashbang.ogg', 50, 1)
		return

/obj/item/mine/blast
	name = "high explosive land mine"
	desc = "An anti-personnel mine rigged with explosives."

	armed
		armed = 1

	custom_stuff(var/atom/M)
		if (!src || !istype(src))
			return

		explosion(src, src.loc, 0, 1, 2, 3)
		return

/obj/item/mine/plasmafire
	name = "incendiary plasma land mine"
	desc = "An anti-personnel mine equipped with an incendiary plasma payload."
	icon_state = "mine_incendiary" //needs its own sprite
	//both in moles
	var/payload_plasma = 25
	var/payload_farts = 10

	armed
		armed = 1

	custom_stuff(var/atom/M)
		if (!src || !istype(src))
			return

		if (!issimulatedturf(src.loc))
			return

		var/datum/gas_mixture/plasma = new()
		plasma.temperature = T20C + 15
		plasma.toxins = payload_plasma
		plasma.farts = payload_farts

		src.loc.assume_air(plasma)

		fireflash_sm(get_turf(src), 1, 3000, 500)
		playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1)
		return

/obj/item/mine/gibs
	name = "pustule"
	desc = "Some kind of weird little meat balloon."
	icon = 'icons/misc/meatland.dmi'
	icon_state = "meatmine"
	suppress_flavourtext = 1
	is_syndicate = 0
	mats = 0

	armed
		armed = 1

	update_icon()
		return

	custom_stuff(var/atom/M)
		if (!src || !istype(src))
			return

		src.visible_message("<span class='alert'>[src] bursts[pick(" like an overripe melon!", " like an impacted bowel!", " like a balloon filled with blood!", "!", "!")]</span>")
		gibs(src.loc)
		playsound(src.loc, "sound/impact_sounds/Flesh_Break_1.ogg", 50, 1)

		return
