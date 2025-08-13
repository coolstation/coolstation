/* Contains;
- Lightning rod
- Surge capacitor
*/

#define UNWRENCHED 0
#define WRENCHED 1
#define WELDED 2

/////////////////////////////////// Lightning Rod //////////////////////////////////////////////////////

//Lightning strikes, as well as arcflashes, target this bad boy preferentially

/obj/lightning_rod
	name = "lightning rod"
	desc = "A spire of steel supporting cables and coils designed to catch lightning."
	icon = 'icons/obj/large/32x96.dmi'
	icon_state = "lightning_rod"
	layer = EFFECTS_LAYER_UNDER_1
	plane = PLANE_NOSHADOW_ABOVE
	anchored = UNANCHORED
	density = 1
	_health = 100
	_max_health = 100
	p_class = 3
	var/efficiency = 0.9
	var/obj/cable/attached
	var/state = UNWRENCHED

/obj/lightning_rod/New()
	START_TRACKING
	..()
	SPAWN_DBG(0.6 SECONDS)
		if(!src.attached && (src.state != UNWRENCHED))
			src.attach()

/obj/lightning_rod/get_desc()
	switch(src.state)
		if (WRENCHED)
			. += "It has been bolted to the floor."
		if (WELDED)
			. += "It has been bolted and welded to the floor."

/obj/lightning_rod/disposing()
	STOP_TRACKING
	. = ..()

/obj/lightning_rod/proc/attach()
	var/turf/T = get_turf(src)
	for(var/obj/cable/C in T)
		if(!C.d1)
			src.attached = C

/obj/lightning_rod/proc/struck(var/wattage)
	var/obj/overlay/fullbright_overlay = new(src.loc)
	fullbright_overlay.icon = src.icon
	fullbright_overlay.icon_state = "empty"
	fullbright_overlay.plane = PLANE_SELFILLUM
	flick("lightning_rod_struck", fullbright_overlay)
	SPAWN_DBG(0.6 SECONDS)
		qdel(fullbright_overlay)
	if(attached)
		var/datum/powernet/PN = attached.get_powernet()
		if(PN)
			PN.newavail += wattage * src.efficiency
			return

/obj/lightning_rod/attackby(obj/item/W, mob/user)
	if (iswrenchingtool(W))
		if(src.state == UNWRENCHED)
			var/turf/T = get_turf(src)
			if(istype(T, /turf/space) && !(locate(/obj/lattice) in T) && !(locate(/obj/grille/catwalk) in T))
				boutput(user, "You want to bolt \the [src] to nothing? Yeah, right.")
				return
			src.state = WRENCHED
			playsound(src.loc, "sound/items/Ratchet.ogg", 75, 1)
			src.attach()
			boutput(user, "You secure the reinforcing bolts to the floor[src.attached ? " and attach the cable" : ""].")
			if(src.attached)
				src.attached.shock(user, 100)
			src.anchored = ANCHORED
			return

		else if(src.state == WRENCHED)
			src.state = UNWRENCHED
			playsound(src.loc, "sound/items/Ratchet.ogg", 75, 1)
			boutput(user, "You undo the reinforcing bolts[src.attached ? " and detach the cable" : ""].")
			if(src.attached)
				src.attached.shock(user, 100)
			src.attached = null
			src.anchored = UNANCHORED
			return

	if(isweldingtool(W))
		if(src.state == WRENCHED)
			var/turf/T = get_turf(src)
			if(istype(T, /turf/space) && !(locate(/obj/lattice) in T) && !(locate(/obj/grille/catwalk) in T))
				boutput(user, "You want to weld \the [src] to nothing? Yeah, right.")
				return
			if(!W:try_weld(user, 1, noisy = 2))
				return
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/lightning_rod/proc/weld_action,\
			list(user), W.icon, W.icon_state, "[user] finishes welding \the [src] down.", null)
			boutput(user, "You start to weld \the [src] to the floor.")
			return
		else if(src.state == WELDED)
			if(!W:try_weld(user, 1, noisy = 2))
				return
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/lightning_rod/proc/weld_action,\
			list(user), W.icon, W.icon_state, "[user] finishes cutting \the [src] free.", null)
			boutput(user, "You start to cut \the [src]free from the floor.")
			return
	else
		src.add_fingerprint(user)
		..()

/obj/lightning_rod/proc/weld_action(mob/user)
	if(src.state == WRENCHED)
		var/turf/T = get_turf(src)
		if(istype(T, /turf/space) && !(locate(/obj/lattice) in T) && !(locate(/obj/grille/catwalk) in T))
			boutput(user, "You want to weld \the [src] to nothing? Yeah, right.")
			return
		src.state = WELDED
		boutput(user, "You weld \the [src] to the floor.")
		logTheThing("station", user, null, "welds a lightning rod to the floor at [log_loc(src)].")
	else if(src.state == WELDED)
		src.state = WRENCHED
		boutput(user, "You cut \the [src] free from the floor.")
		logTheThing("station", user, null, "unwelds a lightning rod from the floor at [log_loc(src)].")

#undef UNWRENCHED
#undef WRENCHED
#undef WELDED
