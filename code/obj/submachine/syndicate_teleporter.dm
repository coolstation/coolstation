//two options to run the teleporter now: one way, for sending crap, or two way, for sending a single mob with a remote
//eventually network this like the regular telepad- still bound to a single pad, but adds nerd opportunities
//i made a linked telepad out of this and it is in linked_telepad.dm thanku

/obj/submachine/syndicate_teleporter
	name = "Syndicate Teleporter"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pad0"
	density = 0
	opacity = 0
	anchored = ANCHORED
	var/recharging =0
	var/id = "shuttle" //The main location of the teleporter
	var/recharge = 20 //A short recharge time between teleports
	var/image/disconnectedImage

	New()
		. = ..()
		disconnectedImage = image('icons/obj/stationobjs.dmi', "pad-noconnect")
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	//send a single mob only, using the teleporter remote
	proc/sendme(mob/user)
		for_by_tcl(S, /obj/submachine/syndicate_teleporter)
			if(S.id == src.id && S != src)
				src.overlays.len = 0
				if(recharging == 1)
					return 1
				else
					S.recharging = 1
					src.recharging = 1
					user.set_loc(S.loc)
					showswirl(user.loc)
					showswirl(S.loc)
					SPAWN_DBG(recharge)
						S.recharging = 0
						src.recharging = 0
					return 0
		//couldn't find another pad that isn't itself? it probably blew up sorry
		src.overlays += src.disconnectedImage
		return 1

	//send anything on the tile
	//one way trip with this method, but a mob can come back with a syndicate remote
	//stolen from telesci.dm's main telepad send
	proc/sendany()
		for_by_tcl(S, /obj/submachine/syndicate_teleporter)
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

					showswirl(S.loc)
					showswirl(src.loc)
					SPAWN_DBG(recharge)
						S.recharging = 0
						src.recharging = 0

					return 0
		//couldn't find another pad that isn't itself?
		src.overlays += src.disconnectedImage
		return 1

/obj/item/remote/syndicate_teleporter
	name = "Syndicate Teleporter Remote"
	icon = 'icons/obj/items/device.dmi'
	desc = "Allows one to use a syndicate teleporter when standing on it."
	icon_state = "locator"
	item_state = "electronic"
	density = 0
	anchored = UNANCHORED
	w_class = W_CLASS_SMALL

	attack_self(mob/user as mob)
		for(var/obj/submachine/syndicate_teleporter/S in get_turf(src))
			S.sendme(user)

//just the hangar door button
/obj/machinery/button/syndicate_teleporter
	name = "Syndicate Teleporter Switch"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A remote control switch for the syndicate teleporter."
	var/id = "shuttle"
	anchored = ANCHORED
	layer = EFFECTS_LAYER_UNDER_1
	plane = PLANE_NOSHADOW_ABOVE

/obj/machinery/button/syndicate_teleporter/New()
	..()
	UnsubscribeProcess()

//any interaction is just a regular hand interaction, boop it with your laser or hypersoylent bottle, who cares your hands are full and you got a station to blow up
/obj/machinery/button/syndicate_teleporter/attack_ai(mob/user as mob)
	return src.Attackhand(user)
/obj/machinery/button/syndicate_teleporter/attackby(obj/item/W, mob/user as mob)
	return src.Attackhand(user)

/obj/machinery/button/syndicate_teleporter/attack_hand(mob/user as mob)
	if((status & (NOPOWER|BROKEN)))
		return

	if (user.getStatusDuration("stunned") || user.getStatusDuration("weakened") || user.stat)
		return

	icon_state = "doorctrl1"

	if (!src.id)
		return

	for (var/obj/submachine/syndicate_teleporter/M in by_type[/obj/submachine/syndicate_teleporter])
		if (M.id == src.id)
			if (M.loc.z == src.loc.z) //close enough, might be better to do area tho
				M.sendany()

	//no cooldown because the telepad handles its own cooldowns, button or remote

	SPAWN_DBG(1.5 SECONDS)
		if(!(status & NOPOWER))
			icon_state = "doorctrl0"
