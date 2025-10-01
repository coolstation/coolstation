// the SMES
// stores power

#define SMESMAXCHARGELEVEL 200000
#define SMESMAXOUTPUT 200000

/obj/machinery/power/smes/magical
	name = "magical power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. Magically produces power, using magic."
	process()
		capacity = INFINITY
		charge = INFINITY
		..()

/obj/machinery/power/smes
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit."
	icon = 'icons/obj/large/32x48.dmi'
	icon_state = "smes"
	density = 1
	anchored = 1
	requires_power = FALSE
	var/output = 30000
	var/lastout = 0
	var/loaddemand = 0
	var/capacity = 1e8
	var/charge = 2e7
	var/charging = 0
	var/chargemode = 1
	var/chargecount = 0
	var/chargelevel = 30000
	var/lastexcess = 0
	var/online = 1
	var/n_tag = null
	var/obj/machinery/power/terminal/terminal = null
	var/opened = FALSE
	var/tampered = FALSE
	var/maxinput = SMESMAXCHARGELEVEL
	var/maxoutput = SMESMAXOUTPUT

	get_desc()
		. = {"It's [online ? "on" : "off"]line. [charging ? "It's charging, and it" : "It"] looks about [round(charge / capacity * 100, 20)]% full. [((maxinput > SMESMAXCHARGELEVEL) || (maxoutput > SMESMAXOUTPUT)) ? "It smells quite warm..." : ""]"}

/obj/machinery/power/smes/attackby(obj/item/W, mob/user)
	src.add_fingerprint(user)

	if(isscrewingtool(W))
		boutput(user, "<span class='alert'>You [opened ? "close" : "open"] the panel on the [src]!</span>")
		if(src.opened)
			src.opened = FALSE
		else
			src.opened = TRUE
		updateicon()
		return

	if(ispulsingtool(W))
		if(src.opened)
			if(src.tampered)
				src.tampered = FALSE
				boutput(user, "<span class='alert'>You reset the safeties!</span>")
				src.maxinput = SMESMAXCHARGELEVEL
				src.maxoutput = SMESMAXOUTPUT
			else
				src.tampered = TRUE
				boutput(user, "<span class='alert'>You short out the safeties!</span>")
				src.maxinput = INFINITY
				src.maxoutput = INFINITY
		updateicon()
		return
	..()


/obj/machinery/power/smes/construction
	New(var/turf/iloc, var/idir = 2)
		if (!isturf(iloc))
			qdel(src)
		set_dir(idir)
		var/turf/Q = get_step(iloc, idir)
		if (!Q)
			qdel(src)
			var/obj/machinery/power/terminal/term = new /obj/machinery/power/terminal(Q)
			term.set_dir(get_dir(Q, iloc))
		..()

/obj/machinery/power/smes/emp_act()
	..()
	src.online = 0
	src.charging = 0
	src.output = 0
	src.charge -= 1e6
	if (src.charge < 0)
		src.charge = 0
	SPAWN_DBG(10 SECONDS)
		src.output = initial(src.output)
		src.charging = initial(src.charging)
		src.online = initial(src.online)
	return

/obj/machinery/power/smes/New()
	..()

	//Overlay of the top bit of the SMES on a layer where it occludes things behind it
	UpdateOverlays(image(src.icon, "smes-overlay", layer = FLY_LAYER), "top")

	SPAWN_DBG(0.5 SECONDS)
		dir_loop:
			for(var/d in cardinal)
				var/turf/T = get_step(src, d)
				for(var/obj/machinery/power/terminal/term in T)
					if (term?.dir == turn(d, 180))
						terminal = term
						break dir_loop

		if (!terminal)
			status |= BROKEN
			return

		terminal.master = src

		updateicon()


/obj/machinery/power/smes/proc/updateicon()

	if (status & BROKEN)
		ClearAllOverlays()
		return

	if(opened)
		ClearAllOverlays()
		if(tampered)
			icon_state = "smes-open-tamp"
		else
			icon_state = "smes-open"
		return
	else
		icon_state = "smes"

	var/image/I = SafeGetOverlayImage("operating", 'icons/obj/machines/power.dmi', "smes-op[online]")
	I.plane = PLANE_SELFILLUM
	I.blend_mode = BLEND_OVERLAY
	UpdateOverlays(I, "operating")

	I = SafeGetOverlayImage("chargemode",'icons/obj/machines/power.dmi', "smes-oc1")
	if (charging)
		I.icon_state = "smes-oc1"
		I.plane = PLANE_SELFILLUM
		I.blend_mode = BLEND_OVERLAY
	else if (chargemode)
		I.icon_state = "smes-oc0"
		I.plane = PLANE_SELFILLUM
		I.blend_mode = BLEND_OVERLAY
	else
		I = null


	UpdateOverlays(I, "chargemode", 0, 1)

	var/clevel = chargedisplay()
	if (clevel>0)
		I = SafeGetOverlayImage("chargedisp",'icons/obj/machines/power.dmi',"smes-og[clevel]")
		I.plane = PLANE_SELFILLUM
		I.blend_mode = BLEND_OVERLAY
		UpdateOverlays(I, "chargedisp")

/obj/machinery/power/smes/proc/chargedisplay()
	return round(5.5*charge/capacity)

/obj/machinery/power/smes/process(mult)

	if (status & BROKEN)
		return


	//store machine state to see if we need to update the icon overlays
	var/last_disp = chargedisplay()
	var/last_chrg = charging
	var/last_onln = online

	// Had to revert a hack here that caused SMES to continue charging despite insufficient power coming in on the input (terminal) side.
	if (terminal)
		var/excess = terminal.surplus()
		var/load = 0
		if (charging)
			if (excess >= 0)		// if there's power available, try to charge

				load = min(capacity-charge, chargelevel)		// charge at set rate, limited to spare capacity

				// Adjusting mult to other power sources would likely cause more harm than good as it would cause unusual surges
				// of power that would only be noticed though hotwire or be unrationalizable to player.  This will extrapolate power
				// benefits to charged value so that minimal loss occurs.
				charge += load * mult	// increase the charge
				add_load(load)		// add the load to the terminal side network
				if(tampered && load > SMESMAXCHARGELEVEL && prob(25))
					var/overcharge = round(load / SMESMAXCHARGELEVEL)
					charge = max((charge - load), 0)
					switch(overcharge)
						if(1)
							// Very Mild
							elecflash(src, (overcharge/2), overcharge)
						if(2)
							// Mild
							elecflash(src, (overcharge/2), overcharge)
							chargemode = 0
							online = 0
						if(3 to 7)
							// Oops, charge circuitry trips out
							SPAWN_DBG(0) zapStuff(overcharge/2)
							chargemode = 0
						if(8 to 100)
							// Owie!
							SPAWN_DBG(0) zapStuff(overcharge)
							src.status |= BROKEN
						if(101 to INFINITY)
							SPAWN_DBG(0) zapStuff(overcharge)
							explosion(src, src, 1, 1, 2, 4)


			else					// if not enough capcity
				charging = 0		// stop charging
				chargecount  = 0

		else if (chargemode)
			if (chargecount > 2)
				charging = 1
				chargecount = 0
			else if (excess >= chargelevel)
				chargecount++
			else
				chargecount = 0

		lastexcess = load + excess

	if (online)		// if outputting
		if (prob(5))
			SPAWN_DBG(1 DECI SECOND)
				playsound(src.loc, pick(ambience_power), 60, 1)

		lastout = min(charge, output)		//limit output to that stored
		if(tampered && lastout > SMESMAXOUTPUT && prob(25))
			var/overcharge = round(lastout/SMESMAXOUTPUT)
			switch(overcharge)
				if(1)
					elecflash(src, (overcharge/2), overcharge)
				if(2)
					elecflash(src, (overcharge/2), overcharge)
				if(3 to 7)
					// Oops, output circuitry trips out
					SPAWN_DBG(0) zapStuff(overcharge/2)
					online = 0
				if(8 to 100)
					SPAWN_DBG(0) zapStuff(overcharge)
					status |= BROKEN
				if(101 to INFINITY)
					SPAWN_DBG(0) zapStuff(overcharge)
					explosion(src, src, 1, 1, 2, 4)

		charge -= lastout		// reduce the storage (may be recovered in /restore() if excessive)

		add_avail(lastout)				// add output to powernet (smes side)

		if (charge < 0.0001)
			online = 0					// stop output if charge falls to zero

	// only update icon if state changed
	if (last_disp != chargedisplay() || last_chrg != charging || last_onln != online)
		updateicon()

	src.updateDialog()

// called after all power processes are finished
// restores charge level to smes if there was excess this ptick

/obj/machinery/power/smes/proc/restore()
	if (status & BROKEN)
		return

	if (!online)
		loaddemand = 0
		return

	var/excess = powernet.netexcess		// this was how much wasn't used on the network last ptick, minus any removed by other SMESes

	excess = min(lastout, excess)				// clamp it to how much was actually output by this SMES last ptick

	excess = min(capacity-charge, excess)	// for safety, also limit recharge by space capacity of SMES (shouldn't happen)

	// now recharge this amount

	var/clev = chargedisplay()

	charge += excess
	powernet.netexcess -= excess		// remove the excess from the powernet, so later SMESes don't try to use it

	loaddemand = lastout - excess

	if (clev != chargedisplay())
		updateicon()


///obj/machinery/power/smes/add_avail(var/amount)
//	if (terminal?.powernet)
//		terminal.powernet.newavail += amount

/obj/machinery/power/smes/add_load(var/amount)
	if (terminal?.powernet)
		terminal.powernet.newload += amount

/obj/machinery/power/smes/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Smes", src.name)
		ui.open()

/obj/machinery/power/smes/ui_static_data(mob/user)
	. = list(
		"inputLevelMax" = src.maxinput,
		"outputLevelMax" = src.maxoutput,
	)

/obj/machinery/power/smes/ui_data(mob/user)
	. = list(
		"capacity" = src.capacity,
		"charge" = src.charge,

		"inputAttempt" = src.chargemode,
		"inputting" = src.charging,
		"inputLevel" = src.chargelevel,
		"inputAvailable" = src.lastexcess,

		"outputAttempt" = src.online,
		"outputting" = src.loaddemand,
		"outputLevel" = src.output,
	)

/obj/machinery/power/smes/ui_act(action, params)
	. = ..()
	if (.)
		return
	switch(action)
		if("toggle-input")
			src.chargemode = !src.chargemode
			if (!chargemode)
				charging = 0
			src.updateicon()
			. = TRUE
		if("toggle-output")
			src.online = !src.online
			src.updateicon()
			. = TRUE
		if("set-input")
			var/target = params["target"]
			var/adjust = params["adjust"]
			if(target == "min")
				src.chargelevel = 0
				. = TRUE
			else if(target == "max")
				src.chargelevel = src.maxinput
				. = TRUE
			else if(adjust)
				src.chargelevel = clamp((src.chargelevel + adjust), 0 , src.maxinput)
				. = TRUE
			else if(text2num(target) != null) //set by drag
				src.chargelevel = clamp(text2num(target), 0 , src.maxinput)
				. = TRUE
		if("set-output")
			var/target = params["target"]
			var/adjust = params["adjust"]
			if(target == "min")
				src.output = 0
				. = TRUE
			else if(target == "max")
				src.output = src.maxoutput
				. = TRUE
			else if(adjust)
				src.output = clamp((src.output + adjust), 0 , src.maxoutput)
				. = TRUE
			else if(text2num(target) != null) //set by drag
				src.output = clamp(text2num(target), 0 , src.maxoutput)
				. = TRUE

/obj/machinery/power/smes/proc/zapStuff(power)
	var/atom/target = null
	var/atom/last   = src
	var/list/starts = new/list()
	for(var/atom/movable/M in orange(3, src))
		if(istype(M, /obj/overlay/tile_effect) || M.invisibility) continue
		starts.Add(M)

	if(!starts.len) return
	if(prob(10))
		var/person = null
		person = (locate(/mob/living) in starts)
		if(person)
			target = person
		else
			target = pick(starts)
	else
		target = pick(starts)

	if(isturf(target))
		return

	playsound(target, 'sound/effects/elec_bigzap.ogg', 40, 1)
	for(var/count=0, count<3, count++)
		if(target == null)
			break
		var/list/affected = DrawLine(last, target, /obj/line_obj/elec ,'icons/obj/projectiles.dmi',\
			"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",OBJ_LAYER,1,\
			PreloadedIcon='icons/effects/LghtLine.dmi')

		for(var/obj/O in affected)
			SPAWN_DBG(0.6 SECONDS) qdel(O)

		if(isliving(target)) //Probably unsafe.
			target:TakeDamage("chest", 0, 20)

		var/list/next = new/list()
		for(var/atom/movable/M in orange(2, target))
			if(istype(M, /obj/overlay/tile_effect) || istype(M, /obj/line_obj/elec) || M.invisibility)
				continue
			next.Add(M)

		last = target
		target = pick(next)


/proc/rate_control(var/S, var/V, var/C, var/Min=1, var/Max=5, var/Limit=null)
	var/href = "<A href='byond://?src=\ref[S];rate control=1;[V]"
	var/rate = "[href]=-[Max]'>-</A>[href]=-[Min]'>-</A> [(C?C : 0)] [href]=[Min]'>+</A>[href]=[Max]'>+</A>"
	if (Limit) return "[href]=-[Limit]'>-</A>"+rate+"[href]=[Limit]'>+</A>"
	return rate

#undef SMESMAXCHARGELEVEL
#undef SMESMAXOUTPUT
