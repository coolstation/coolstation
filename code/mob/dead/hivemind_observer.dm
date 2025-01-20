/mob/dead/target_observer/hivemind_observer
	var/datum/abilityHolder/changeling/hivemind_owner
	var/can_exit_hivemind_time = 0
	var/last_attack = 0

	New()
		. = ..()
		REMOVE_MOB_PROPERTY(src, PROP_EXAMINE_ALL_NAMES, src)

	say_understands(var/other)
		return 1

	say(var/message)
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

		if (!message)
			return

		if (dd_hasprefix(message, "*"))
			return

		logTheThing("diary", src, null, "(HIVEMIND): [message]", "hivesay")

		if (src.client && src.client.ismuted())
			boutput(src, "You are currently muted and may not speak.")
			return

		. = src.say_hive(message, hivemind_owner)


	disposing()
		hivemind_owner?.hivemind -= src
		..()

	click(atom/target, params)
		if (try_launch_attack(target))
			return
		..()

	proc/try_launch_attack(atom/shoot_target)
		.= 0
		if (isabomination(hivemind_owner.owner) && world.time > (last_attack + src.combat_click_delay))
			var/obj/projectile/proj = initialize_projectile_ST(target, new /datum/projectile/special/acidspit, shoot_target)
			if (proj) //ZeWaka: Fix for null.launch()
				proj.launch()
				last_attack = world.time
				playsound(src, 'sound/weapons/flaregun.ogg', 30, 0.1, 0, 2.6)
				.= 1

	proc/set_owner(var/datum/abilityHolder/changeling/new_owner)
		if(!istype(new_owner)) return 0
		//DEBUG_MESSAGE("Calling set_owner on [src] with abilityholder belonging to [new_owner.owner]")

		//If we had an owner then remove ourselves from the their hivemind
		if(hivemind_owner)
			//DEBUG_MESSAGE("Removing [src] from [hivemind_owner.owner]'s hivemind.")
			hivemind_owner.hivemind -= src

		//DEBUG_MESSAGE("Adding [src] to new owner [new_owner.owner]'s hivemind.")
		//Add ourselves to the new owner's hivemind
		hivemind_owner = new_owner
		new_owner.hivemind |= src
		//...and transfer the observe stuff accordingly.
		//DEBUG_MESSAGE("Setting new observe target: [new_owner.owner]")
		set_observe_target(new_owner.owner)

		return 1

/mob/dead/target_observer/hivemind_observer/proc/regain_control()
	set name = "Retake Control"
	set category = "Changeling"
	usr = src

	if(hivemind_owner && hivemind_owner.master == src)
		if(hivemind_owner.return_control_to_master())
			qdel(src)


/mob/dead/target_observer/hivemind_observer/voluntary_leave()
	set hidden = 1

//Same thing, different name, since I can't rename verbs on subtypes?
/mob/dead/target_observer/hivemind_observer/verb/alt_voluntary_leave()
	set name = "Exit Hivemind"
	set category = "Commands"
	usr = src

	voluntary_stop_observing()

/mob/dead/target_observer/hivemind_observer/voluntary_stop_observing()
	if(world.time >= can_exit_hivemind_time && hivemind_owner && hivemind_owner.master != src)
		hivemind_owner.hivemind -= src
		boutput(src, __red("You have parted with the hivemind."))
		src.stop_observing()
	else
		boutput(src, __red("You are not able to part from the hivemind at this time. You will be able to leave in [(can_exit_hivemind_time/10 - world.time/10)] seconds."))
