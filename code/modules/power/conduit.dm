//a disastrous mashup of cables and disposal pipes for heavy duty connectivity

/obj/cable/conduit
// note don't get used to it just yet as i will probably be changing some of the iconstate naming conventions
	name = "power conduit"
	desc = "A rigid assembly of superconducting power lines."
	icon = 'icons/obj/machines/power_conduit.dmi'
	icon_state = "conduit-large"

	layer = CABLE_LAYER
	plane = PLANE_NOSHADOW_BELOW
	color = "#DD0000"
	text = ""

	conductor_default = "claretine"
	insulator_default = "synthrubber"

	var/static/welds_required = 2
	var/welds = 0
	var/connects = 2

	get_desc(dist, mob/user)
		if(dist < 4 && welds)
			.= "<br>" + "The conduit looks partially detached."

	cut(mob/user,turf/T) //not cuttable, intercept any attempts to cut
		boutput(user, "<span class='alert'>In retrospect, this looks more like a welding job.</span>")
		src.visible_message("<span class='alert'>[user] tries to cut through section of [src], but the conduit is too thick.</span>")

	updateicon()
		return //these are rigid items, we will not be updating icons with directions, but we will be using iconstate names for powernet direction

	weld(mob/user,turf/T) //weld to dismantle, disposal pipe style
		welds++
		shock(user, 50)
		var/num = "first"
		if (welds == 2)
			num = "second"
		src.visible_message("<span class='alert'>[user] slices through the [num] conductor pair of [src].</span>")

		if (welds >= welds_required)
			src.visible_message("<span class='alert'>If the next part of this was working, it would spawn right now!</span>")
			welds = 0 //reset the count and do nothing
		else
			playsound(src.loc, "sound/items/Welder.ogg", 50, 1)

/obj/cable/conduit/junction
	name = "three-way conduit junction"
	desc = "A rigid assembly of superconducting power lines. A three-way junction has been made."
	icon_state = "conduit-large-tee"
	connects = 3

/obj/cable/conduit/allway
	name = "all-way conduit junction"
	desc = "A rigid assembly of superconducting power lines. A four-way junction has been made."
	icon_state = "conduit-large-all"
	connects = 4

/obj/cable/conduit/tap
	icon_state = "1-2-conduit-tap"
	name = "conduit tap"
	desc = "A rigid assembly of superconducting power lines. A terminal tap has been added mid-length."
	connects = 1

/obj/cable/conduit/trunk
	name = "conduit terminal"
	desc = "A rigid assembly of superconducting power lines. It ends in a terminal tap."
	icon_state = "conduit-large-trunk"
	connects = 1

/obj/cable/conduit/switcher
	name = "switched conduit"
	desc = "A rigid assembly of superconducting power lines. It has a heavy duty in-line switch built in."
	icon_state = "conduit-large-sw0"

/obj/cable/conduit/small
	name = "small power conduit"
	desc = "A two-line superconductor conduit, meant for direct monitoring of power output by terminals."
	icon_state = "conduit-small"
	color = "#BA9B67"

/obj/cable/conduit/small/tap
	name = "small power conduit tap"
	desc = "A two-line superconductor conduit tap, meant for direct monitoring of power output by terminals."
	icon_state = "conduit-small-tap"
	connects = 1

/obj/cable/conduit/small/trunk
	name = "small power conduit trunk"
	desc = "A two-line superconductor conduit trunk, meant for direct monitoring of power output by terminals."
	icon_state = "conduit-small-trunk"
	connects = 1

//proc stuff

/obj/cable/conduit/New(var/newloc, var/obj/item/cable_coil/source)
	..()

	if (source) src.iconmod = source.iconmod

	var/turf/T = src.loc			// hide if turf is not intact
									// but show if in space
	if(istype(T, /turf/space) && !istype(T,/turf/space/fluid)) hide(0)
	else if(level==1) hide(T.intact)

	if (istype(source))
		applyCableMaterials(src, source.insulator, source.conductor)
	else
		applyCableMaterials(src, getMaterial(insulator_default), getMaterial(conductor_default))

	START_TRACKING

/obj/cable/conduit/hide(var/i)

	if(level == 1)
		invisibility = i ? 101 : 0
	updateicon()
/*
/obj/cable/conduit/disposing()		// called when a cable is deleted

	if(!defer_powernet_rebuild)	// set if network will be rebuilt manually

		if(netnum && powernets && powernets.len >= netnum)		// make sure cable & powernet data is valid
			var/datum/powernet/PN = powernets[netnum]
			PN.cut_cable(src)									// updated the powernets
	else
		defer_powernet_rebuild = 2

		if(netnum && powernets && powernets.len >= netnum) //NEED FOR CLEAN GC IN EXPLOSIONS
			powernets[netnum].cables -= src

	//insulator.owner = null
	//conductor.owner = null

	STOP_TRACKING

	..()													// then go ahead and delete the cable
*/
// returns the powernet this cable belongs to
/obj/cable/conduit/get_powernet()
	return
	/*
	var/datum/powernet/PN			// find the powernet
	if(netnum && powernets && powernets.len >= netnum)
		PN = powernets[netnum]
	return PN
	*/
/*
/obj/cable/conduit/update_network()
	return

	//don't do this yet


/obj/cable/conduit/update_network()
	if(makingpowernets) // this might cause local issues but prevents a big global race condition that breaks everything
		return
	var/turf/T = get_turf(src)
	var/list/conduits_to_connect = list()
	var/list/directions_to_connect = null
	var/powernet_to_join = null
	if (src.connects == 1)
		directions_to_connect = list(src.dir)
	if (src.connects == 2)
		directions_to_connect = list(src.dir, turn(src.dir,180))
	if (src.connects == 3)
		directions_to_connect = list(src.dir, turn(src.dir,-90), turn(src.dir,90))
	if (src.connects == 4)
		directions_to_connect = cardinal

	for (C in directions_to_connect)
		conduits_to_connect += locate(/obj/cable/conduit) in (get_step(C))

	for (C in conduits_to_connect)
		if (C.powernet_id)
			powernet_to_join = C.powernet_id
		var/request_rebuild = 0

	for (var/obj/cable/new_cable_d1 in src.get_connections_one_dir(is_it_d2 = 0))
		cable_d1 = new_cable_d1
		break

	for (var/obj/cable/new_cable_d2 in src.get_connections_one_dir(is_it_d2 = 1))
		cable_d2 = new_cable_d2
		break

	if(cable_d1 && !cable_d1.netnum)
		logTheThing("debug", src, cable_d1, "Cable \ref[src] ([src.x], [src.y], [src.z]) connected to \ref[cable_d1] which had netnum 0, rebuilding powernets.")
		DEBUG_MESSAGE("Cable \ref[src] ([src.x], [src.y], [src.z]) connected to \ref[cable_d1] which had netnum 0, rebuilding powernets.")
		return makepowernets()
	if(cable_d2 && !cable_d2.netnum)
		logTheThing("debug", src, cable_d1, "Cable \ref[src] ([src.x], [src.y], [src.z]) connected to \ref[cable_d2] which had netnum 0, rebuilding powernets.")
		DEBUG_MESSAGE("Cable \ref[src] ([src.x], [src.y], [src.z]) connected to \ref[cable_d2] which had netnum 0, rebuilding powernets.")
		return makepowernets()

	if (cable_d1 && cable_d2)
		if (cable_d1.netnum == cable_d2.netnum && powernets[cable_d1.netnum])
			var/datum/powernet/PN = powernets[cable_d1.netnum]
			PN.cables += src
			src.netnum = cable_d1.netnum
		else
			var/datum/powernet/P1 = cable_d1.get_powernet()
			var/datum/powernet/P2 = cable_d2.get_powernet()
			src.netnum = cable_d1.netnum
			P1.cables += src
			if(P1.cables.len <= P2.cables.len)
				P1.join_to(P2)
			else
				P2.join_to(P1)

	else if (!cable_d1 && !cable_d2)
		var/datum/powernet/PN = new()
		powernets += PN
		PN.cables += src
		PN.number = length(powernets)
		src.netnum = length(powernets)

	else if (cable_d1)
		var/datum/powernet/PN = powernets[cable_d1.netnum]
		PN.cables += src
		src.netnum = cable_d1.netnum

	else
		var/datum/powernet/PN = powernets[cable_d2.netnum]
		PN.cables += src
		src.netnum = cable_d2.netnum

	if (isturf(T) && d1 == 0 && !request_rebuild)
		for (var/obj/machinery/power/M in T.contents)
			if(M.directwired)
				continue
			if(M.netnum == 0 || powernets[M.netnum].cables.len == 0)
				if(M.netnum)
					M.powernet.nodes -= M
					M.powernet.data_nodes -= M
				M.netnum = src.netnum
				M.powernet = powernets[M.netnum]
				M.powernet.nodes += M
				if(M.use_datanet)
					M.powernet.data_nodes += M
			else if(M.netnum != src.netnum) // this shouldn't actually ever happen probably
				request_rebuild = 1
				break
	if(d1 != 0 && !request_rebuild)
		var/turf/T1 = get_step(src, d1)
		for (var/obj/machinery/power/M in T1.contents)
			if(!M.directwired)
				continue
			if(M.netnum == 0 || powernets[M.netnum].cables.len == 0)
				if(M.netnum)
					M.powernet.nodes -= M
					M.powernet.data_nodes -= M
				M.netnum = src.netnum
				M.powernet = powernets[M.netnum]
				M.powernet.nodes += M
				if(M.use_datanet)
					M.powernet.data_nodes += M
			else if(M.netnum != src.netnum)
				request_rebuild = 1
				break
	if(!request_rebuild)
		var/turf/T2 = get_step(src, d2)
		for (var/obj/machinery/power/M in T2.contents)
			if(!M.directwired || M.netnum == -1) // APCs have -1 and don't connect directly
				continue
			if(M.netnum == 0 || powernets[M.netnum].cables.len == 0)
				if(M.netnum)
					M.powernet.nodes -= M
					M.powernet.data_nodes -= M
				M.netnum = src.netnum
				M.powernet = powernets[M.netnum]
				M.powernet.nodes += M
				if(M.use_datanet)
					M.powernet.data_nodes += M
			else if(M.netnum != src.netnum)
				request_rebuild = 1
				break

	if(request_rebuild)
		makepowernets()
*/
