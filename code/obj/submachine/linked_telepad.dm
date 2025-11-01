//two options to run the teleporter now: one way, for sending crap, or two way, for sending a single mob with a remote
//secure two way teleportation to things like, say, i dunno, an AI satellite

/obj/submachine/linked_telepad
	name = "Linked Teleporter"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pad0"
	density = 0
	opacity = 0
	anchored = ANCHORED
	var/recharging =0
	var/id = "linkedtele" //The main location of the teleporter, change this for pads and buttons in maps
	var/recharge = 50 //About 5 seconds seems right
	var/image/disconnectedImage

	New()
		. = ..()
		disconnectedImage = image('icons/obj/stationobjs.dmi', "pad-noconnect")
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	//send anything on the tile
	//one way trip with this method, but a mob can come back with a syndicate remote
	//stolen from telesci.dm's main telepad send
	//oh shit this should probably check and throw an error if there's not exactly 2 huh
	//anyway that's a mapper's problem
	proc/send()
		for_by_tcl(S, /obj/submachine/linked_telepad)
			if(S.id == src.id && S != src)
				src.overlays.len = 0
				if(recharging == 1)
					return 1
				else
					S.recharging = 1
					src.recharging = 1

					var/list/stuff = list()
					for(var/atom/movable/O as obj|mob in src.loc)
						if(O.anchored) continue
						if(O == src) continue
						stuff.Add(O)
					if (stuff.len)
						var/atom/movable/which = pick(stuff)
						which.set_loc(S.loc)

					showswirl(src.loc)
					leaveresidual(src.loc)
					showswirl(S.loc)
					leaveresidual(S.loc)
					//eventually maybe either make this full machinery or add power handling
					SPAWN_DBG(recharge)
						S.recharging = 0
						src.recharging = 0
					return 0

		//couldn't find another pad that isn't itself?
		src.overlays += src.disconnectedImage
		return 1

/obj/machinery/button/linked_telepad
	name = "Linked Teleporter Switch"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A remote control switch for the syndicate teleporter."
	var/id = "linkedtele"
	anchored = ANCHORED
	layer = EFFECTS_LAYER_UNDER_1
	plane = PLANE_NOSHADOW_ABOVE

/obj/machinery/button/linked_telepad/New()
	..()
	UnsubscribeProcess()

/obj/machinery/button/linked_telepad/attack_ai(mob/user as mob)
	return src.Attackhand(user)
/obj/machinery/button/linked_telepad/attackby(obj/item/W, mob/user as mob)
	return src.Attackhand(user)

/obj/machinery/button/linked_telepad/attack_hand(mob/user as mob)
	if((status & (NOPOWER|BROKEN)))
		return

	if (user.getStatusDuration("stunned") || user.getStatusDuration("weakened") || user.stat)
		return

	use_power(5)
	icon_state = "doorctrl1"

	if (!src.id)
		return

	for (var/obj/submachine/linked_telepad/M in by_type[/obj/submachine/linked_telepad])
		if (M.id == src.id)
			if (M.loc.loc == src.loc.loc)
				M.send()

	//no cooldown because the telepad handles its own cooldown

	SPAWN_DBG(1.5 SECONDS)
		if(!(status & NOPOWER))
			icon_state = "doorctrl0"

//no remote, impenetrable remote bunkers are for syndies
