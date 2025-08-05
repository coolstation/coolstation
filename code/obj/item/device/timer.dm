/obj/item/device/timer
	name = "timer"
	icon_state = "timer0"
	item_state = "electronic"
	var/timing = FALSE
	var/time = null
	var/last_tick = 0
	var/const/max_time = 600
	var/min_time = 0
	var/const/min_detonator_time = 90
	var/ui_name = "Timing Unit"
	//Prevents you from doing anything with the timer while it's armed, including disarming.
	var/lock_once_timer_set = FALSE
	//Prevents you from doing anything with the timer directly, generally when it's a canbomb detonator.
	var/lock_manual_adjustment = FALSE
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = W_CLASS_SMALL
	m_amt = 100
	mats = 2
	desc = "A device that emits a signal when the time reaches 0."

/obj/item/device/timer/proc/time()
	src.c_state(0)

	if (src.master)
		SPAWN_DBG( 0 )
			var/datum/signal/signal = get_free_signal()
			signal.source = src
			signal.data["message"] = "ACTIVATE"
			src.master.receive_signal(signal)
			//qdel(signal)
			return
	else
		for(var/mob/O in hearers(null, null))
			O.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)
	return

//*****RM


/obj/item/device/timer/proc/c_state(n)
	//src.icon_state = text("timer[]", n)

	if(src.master)
		src.master:c_state(n)

	return

//*****

/obj/item/device/timer/process()
	if (src.timing)
		if (!last_tick) last_tick = TIME
		var/passed_time = round(max(round(TIME - last_tick),10) / 10)

		if (src.time > 0)
			src.time -= passed_time
			if(time<5)
				src.c_state(2)
			else
				// they might increase the time while it is timing
				src.c_state(1)
		else
			time()
			src.time = 0
			src.timing = 0
			last_tick = 0

		last_tick = TIME

		if (!src.master)
			src.updateSelfDialog()
		else
			src.master.updateSelfDialog()

	else
		// If it's not timing, reset the icon so it doesn't look like it's still about to go off.
		src.c_state(0)
		processing_items.Remove(src)
		last_tick = 0

	return

/obj/item/device/timer/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/device/radio/signaler) )
		var/obj/item/device/radio/signaler/S = W
		if(!S.b_stat)
			return

		var/obj/item/assembly/rad_time/R = new /obj/item/assembly/rad_time( user )
		S.set_loc(R)
		R.part1 = S
		S.layer = initial(S.layer)
		user.u_equip(S)
		user.put_in_hand_or_drop(R)
		S.master = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		src.set_loc(R)
		R.part2 = src
		R.set_dir(src.dir)
		src.add_fingerprint(user)
		return

/obj/item/device/timer/attack_self(mob/user as mob)
	..()
	if (user.stat || user.restrained() || user.lying)
		return

	if ((src in user) || (src.master && (src.master in user)) || (get_dist(src, user) <= 1))
		if (!src.master)
			src.add_dialog(user)
		else
			src.master.add_dialog(user)
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		var/timing_links = (src.timing ? text("<A href='byond://?src=\ref[];time=0'>Timing</A>", src) : text("<A href='byond://?src=\ref[];time=1'>Not Timing</A>", src))
		var/timing_text = (src.timing ? "Timing - controls locked" : "Not timing - controls unlocked")
		var/dat = text("<TT><B>[]</B><br>[] []:[]<br><A href='byond://?src=\ref[];tp=-30'>-30s</A> <A href='byond://?src=\ref[];tp=-1'>-1s</A> <A href='byond://?src=\ref[];tp=set'>set time</A> <A href='byond://?src=\ref[];tp=1'>+1s</A> <A href='byond://?src=\ref[];tp=30'>+30s</A><br></TT>", src.ui_name, (src.lock_manual_adjustment || (src.lock_once_timer_set && src.timing)) ? timing_text : timing_links, minute, add_zero(second, 2), src, src, src, src, src)
		dat += "<BR>[(src.lock_once_timer_set && !src.timing) ? "<b>Warning: controls lock once timer is activated.</b>" : ""]<BR><A href='byond://?src=\ref[src];close=1'>Close</A>"
		user.Browse(dat, "window=timer")
		onclose(user, "timer")
	else
		user.Browse(null, "window=timer")
		if (!src.master)
			src.remove_dialog(user)
		else
			src.master.remove_dialog(user)

	return

/obj/item/device/timer/proc/set_time(var/new_time as num)
	src.time = clamp(new_time, min_time, src.max_time)

/obj/item/device/timer/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained() || usr.lying)
		return
	var/can_use_detonator = (src.lock_manual_adjustment || src.lock_once_timer_set) && !src.timing
	if (can_use_detonator || (src in usr) || (src.master && (src.master in usr)) || in_interact_range(src, usr) && istype(src.loc, /turf))
		if (!src.master)
			src.add_dialog(usr)
		else
			src.master.add_dialog(usr)
		if (href_list["time"])
			src.timing = text2num(href_list["time"])
			if(timing)
				src.c_state(1)
				processing_items |= src

			if (src.master && istype(master, /obj/item/device/transfer_valve))
				logTheThing("bombing", usr, null, "[timing ? "initiated" : "defused"] a timer on a transfer valve at [log_loc(src.master)].")
				message_admins("[key_name(usr)] [timing ? "initiated" : "defused"] a timer on a transfer valve at [log_loc(src.master)].")
			else if (src.master && istype(src.master, /obj/item/assembly/time_ignite)) //Timer-detonated beaker assemblies
				var/obj/item/assembly/rad_ignite/RI = src.master
				logTheThing("bombing", usr, null, "[timing ? "initiated" : "defused"] a timer on a timer-igniter assembly at [log_loc(src.master)]. Contents: [log_reagents(RI.part3)]")

			else if(src.master && istype(src.master, /obj/item/assembly/time_bomb))	//Timer-detonated single-tank bombs
				logTheThing("bombing", usr, null, "[timing ? "initiated" : "defused"] a timer on a single-tank bomb at [log_loc(src.master)].")
				message_admins("[key_name(usr)] [timing ? "initiated" : "defused"] a timer on a single-tank bomb at [log_loc(src.master)].")

			else if (src.master && istype(src.master, /obj/item/mine)) // Land mine.
				logTheThing("bombing", usr, null, "[timing ? "initiated" : "defused"] a timer on a [src.master.name] at [log_loc(src.master)].")

		if (href_list["tp"])
			var/tp
			//set absolute time
			if (href_list["tp"] == "set")
				tp = input(usr, "Enter a time (seconds)", "Set [ui_name]", src.time) as num|null
				if (isnull(tp))
					return
				if (src.lock_once_timer_set && src.timing) //async from input holding us up
					return
				set_time(tp)
			//add or remove time
			else
				tp = text2num(href_list["tp"])
				set_time(src.time += tp)

		if (href_list["close"])
			usr.Browse(null, "window=timer")
			if (!src.master)
				src.remove_dialog(usr)
			else
				src.master.remove_dialog(usr)
			return

		if (!src.master)
			src.updateSelfDialog()
		else
			src.master.updateSelfDialog()

		src.add_fingerprint(usr)
	else
		usr.Browse(null, "window=timer")
		return
	return
