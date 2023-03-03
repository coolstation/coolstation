/atom/proc/electrocute(mob/user, prb, netnum, var/ignore_gloves)

	if(!prob(prb))
		return 0

	if(!netnum)		// unconnected cable is unpowered
		return 0

	var/datum/powernet/PN
	if(powernets && powernets.len >= netnum)
		PN = powernets[netnum]

	elecflash(src)

	return user.shock(src, PN ? PN.avail : 0, user.hand == 1 ? "l_arm": "r_arm", 1, ignore_gloves ? 1 : 0)

// attach a wire to a power machine - leads from the turf you are standing on

/obj/machinery/power/attackby(obj/item/W, mob/user)

	if(istype(W, /obj/item/cable_coil))

		var/obj/item/cable_coil/coil = W

		var/turf/T = user.loc

		if(T.intact || !istype(T, /turf/simulated/floor))
			return

		if(get_dist(src, user) > 1)
			return

		if(!directwired)		// only for attaching to directwired machines
			return

		var/dirn = get_dir(user, src)


		for(var/obj/cable/LC in T)
			if(LC.d1 == dirn || LC.d2 == dirn)
				boutput(user, "There's already a cable at that position.")
				return

		var/obj/cable/NC = new(T, coil)
		NC.d1 = 0
		NC.d2 = dirn
		NC.iconmod = coil.iconmod
		NC.add_fingerprint()
		NC.updateicon()
		NC.update_network()
		coil.use(1)
		return
	else
		..()
	return


// the power cable object
/obj/cable
	level = 1
	anchored = 1
	var/tmp/netnum = 0
	name = "power cable"
	desc = "A flexible power cable."
	icon = 'icons/obj/power_cond.dmi'
	icon_state = "0-1"
	var/d1 = 0
	var/d2 = 1
	var/iconmod = null
	layer = CABLE_LAYER
	plane = PLANE_NOSHADOW_BELOW
	color = "#DD0000"
	text = ""

	var/insulator_default = "synthrubber"
	var/conductor_default = "pharosium"
	var/tapped = 0 //0: completely insulated 1: safely tapped 2: unsafely tapped
	var/open_circuit = FALSE //governed by breakers, prevents this cable from being added to a powernet, basically suspends a cable connection without deleting the cable

	var/datum/material/insulator = null
	var/datum/material/conductor = null

/obj/cable/reinforced
	name = "reinforced power cable"
	desc = "A flexible yet extremely thick power cable. How paradoxical."
	icon_state = "0-1-thick"
	iconmod = "-thick"
	color = "#075C90"

	conductor_default = "pharosium"
	insulator_default = "synthblubber"

	//same as normal cables but you have to click them multiple cuts heheheh
	var/static/cuts_required = 3
	var/cuts = 0

	get_desc(dist, mob/user)
		if(dist < 4 && cuts)
			.= "<br>" + "The cable looks partially cut."


	cut(mob/user,turf/T)
		cuts++
		shock(user, 50)
		var/num = "first"
		if (cuts == 2)
			num = "second"
		if (cuts == 3)
			num = "third"
		if (cuts == 4)
			num = "fourth"
		if (cuts == 5)
			num = "fifth"
		src.visible_message("<span class='alert'>[user] cuts through the [num] section of [src].</span>")

		if (cuts >= cuts_required)
			..()
		else
			playsound(src.loc, "sound/items/Wirecutter.ogg", 50, 1)

/obj/cable/New(var/newloc, var/obj/item/cable_coil/source)
	..()
	// ensure d1 & d2 reflect the icon_state for entering and exiting cable
	d1 = text2num( icon_state )

	d2 = text2num( copytext( icon_state, findtext(icon_state, "-")+1 ) )

	if (source) src.iconmod = source.iconmod

	var/turf/T = src.loc			// hide if turf is not intact
									// but show if in space
	if(istype(T, /turf/space) && !istype(T,/turf/space/fluid)) hide(0)
	else if(level==1) hide(T.intact)

	//cableimg = image(src.icon, src.loc, src.icon_state)
	//cableimg.layer = OBJ_LAYER

	if (istype(source))
		applyCableMaterials(src, source.insulator, source.conductor)
	else
		applyCableMaterials(src, getMaterial(insulator_default), getMaterial(conductor_default))

	START_TRACKING

/obj/cable/disposing()		// called when a cable is deleted

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

/obj/cable/hide(var/i)

	if(level == 1)// && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	updateicon()

/obj/cable/proc/updateicon()
	icon_state = "[d1]-[d2][iconmod]"
	alpha = invisibility ? 128 : 255
	//if (cableimg)
	//	cableimg.icon_state = icon_state
	//	cableimg.alpha = invisibility ? 128 : 255

// returns the powernet this cable belongs to
/obj/cable/proc/get_powernet()
	var/datum/powernet/PN			// find the powernet
	if(netnum && powernets && powernets.len >= netnum)
		PN = powernets[netnum]
	return PN

/obj/cable/proc/cut(mob/user,turf/T)
	if(src.d1)	// 0-X cables are 1 unit, X-X cables are 2 units long
		var/atom/A = new/obj/item/cable_coil(T, 2)
		applyCableMaterials(A, src.insulator, src.conductor)
		if (src.iconmod)
			var/obj/item/cable_coil/C = A
			C.iconmod = src.iconmod
			C.updateicon()
	else
		var/atom/A = new/obj/item/cable_coil(T, 1)
		applyCableMaterials(A, src.insulator, src.conductor)
		if (src.iconmod)
			var/obj/item/cable_coil/C = A
			C.iconmod = src.iconmod
			C.updateicon()

	src.visible_message("<span class='alert'>[user] cuts the cable.</span>")
	src.log_wirelaying(user, 1)

	shock(user, 50)

	defer_powernet_rebuild = 0		// to fix no-action bug
	qdel(src)
	return

/obj/cable/proc/weld(mob/user,turf/T) //set up the welder proc for conduit
	if (!src.tapped) //really just exposed in this case, but this is still useful for other reasons
		shock(user, 25)
		src.visible_message("<span class='alert'>[user] melts the cable's insulation, for some reason.</span>")
		src.tapped = 2 //might work as a quick and dirty tap, who knows
		//regular tapped cable can't safely be reused and will need to be recycled
	//todo: set cable is melted, with an overlay
	//new proc: do the glass shard thing and see if someone stepping on it doesn't have shoes and if not, zap them
	return

/obj/cable/attackby(obj/item/W, mob/user)

	var/turf/T = src.loc
	if (T.intact)
		return

	if (issnippingtool(W))
		src.cut(user,T) //for normal cables

	else if (istype(W, /obj/item/cable_coil))
		var/obj/item/cable_coil/coil = W
		coil.cable_join(src, get_turf(user), user, TRUE)
		//note do shock in cable_join

	else if (istype(W, /obj/item/weldingtool))
		src.weld(user,T) //for conduit

	else if (istype(W, /obj/item/device/t_scanner) || ispulsingtool(W) || (istype(W, /obj/item/device/pda2) && istype(W:module, /obj/item/device/pda_module/tray)))

		var/datum/powernet/PN = get_powernet()		// find the powernet
		var/powernet_id = ""

		if(PN && (PN.avail > 0))		// is it powered?
			if(ispulsingtool(W))
				// 3 Octets: Netnum, 4 Octets: Nodes+Data Nodes*2, 4 Octets: Cable Count
				powernet_id = " ID#[num2text(PN.number,3,8)]:[num2text(length(PN.nodes)+(length(PN.data_nodes)<<2),4,8)]:[num2text(length(PN.cables),4,8)]"

			boutput(user, "<span class='alert'>[PN.avail]W in power network.[powernet_id]</span>")

		else
			boutput(user, "<span class='alert'>The cable is not powered.</span>")

		if(prob(40))
			shock(user, 10)

	else
		shock(user, 10)

	src.add_fingerprint(user)

// shock the user with probability prb

/obj/cable/proc/shock(mob/user, prb)

	if(open_circuit) //This goes before the netnum thing because it's probably 0 in this case
		if (!powernets) return 0
		var/result = 0 //this is a powernet number
		var/max_avail = 0 //gotta keep track since we're gonna examine one pnet at a time
		for(var/obj/cable/C in src.get_connections()) //Find the spiciest connection and use that
			if (!C.netnum) continue
			var/datum/powernet/PN
			if(powernets.len >= C.netnum)
				PN = powernets[C.netnum]
				if (PN.avail > max_avail)
					max_avail = PN.avail
					result = C.netnum
		return result ? src.electrocute(user, prb, result) : 0

	if(!netnum)		// unconnected cable is unpowered
		return 0

	return src.electrocute(user, prb, netnum)

/obj/cable/ex_act(severity)
	switch (severity)
		if (1)
			qdel(src)
		if (2)
			if (prob(15))
				var/atom/A = new/obj/item/cable_coil(src.loc, src.d1 ? 2 : 1)
				applyCableMaterials(A, src.insulator, src.conductor)
			qdel(src)

/obj/cable/reinforced/ex_act(severity)
	return //nah

// called when a new cable is created
// can be 1 of 3 outcomes:
// 1. Isolated cable (or only connects to isolated machine) -> create new powernet
// 2. Joins to end or bridges loop of a single network (may also connect isolated machine) -> add to old network
// 3. Bridges gap between 2 networks -> merge the networks (must rebuild lists also) (currently just calls makepowernets. welp)

/obj/cable/proc/update_network()
	if(makingpowernets) // this might cause local issues but prevents a big global race condition that breaks everything
		return
	var/turf/T = get_turf(src)
	var/obj/cable/cable_d1 = null //locate() in (d1 ? get_step(src,d1) : orange(0, src) )
	var/obj/cable/cable_d2 = null //locate() in (d2 ? get_step(src,d2) : orange(0, src) )
	var/request_rebuild = 0

	for (var/obj/cable/new_cable_d1 in src.get_connections_one_dir(is_it_d2 = 0))
		if (istype(new_cable_d1, /obj/cable/conduit))
			continue //for now (implement and check for unsafe taps later)
		cable_d1 = new_cable_d1
		break

	for (var/obj/cable/new_cable_d2 in src.get_connections_one_dir(is_it_d2 = 1))
		if (istype(new_cable_d2, /obj/cable/conduit))
			continue
		cable_d2 = new_cable_d2
		break

	// due to the first two lines of this proc it can happen that some cables are left at netnum 0, oh no
	// this is bad and should be fixed, probably by having a queue of stuff to process once current makepowernets finishes
	// but I'm too lazy to do that, so here's a bandaid
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

	//powernets are really in need of a renovation.  makepowernets() is called way too much and is really intensive on the server ok.

// Some non-traitors love to hotwire the engine (Convair880).
/obj/cable/proc/log_wirelaying(var/mob/user, var/cut = 0)
	if (!src || !istype(src) || !user || !ismob(user))
		return

	var/powered = 0
	var/datum/powernet/PN = src.get_powernet()
	if (PN && istype(PN) && (PN.avail > 0))
		powered = 1


	if (cut) //avoid some slower string builds lol
		logTheThing("station", user, null, "cuts a cable[powered == 1 ? " (powered when cut)" : ""] at [log_loc(src)].")
	else
		logTheThing("station", user, null, "lays a cable[powered == 1 ? " (powered when connected)" : ""] at [log_loc(src)].")

	return

//conduits! a disastrous mashup of cables and disposal pipes for heavy duty and secure connectivity
//moved down here to make it easier to work and look at
//let's say this *safely* does up to 5 megawatts worth of whatever amp draw (draw, not supply) and gets more dangerous above that?

/obj/cable/conduit
	name = "power conduit"
	desc = "A rigid assembly of superconducting power lines."
	icon_state = "conduit-large"
	var/welded = 1 //Unweld, then cut
	var/static/cuts_required = 4
	var/cuts = 0
	var/list/conduits = list() //debug var, to remove later
	var/connects = 2
	var/connections = 0 //bitflag for all possible connected directions
	var/connected = 0 //bitflag for all actually connected directions
	//var/deconstructs_into = /obj/conduitparts"

	tapped = 0 //1 for standard small conduit tap, 2 for hotwire syndie tap (equivalent to d1 = 0 in regular cable)
	//for later disassembly and capacity, may or may not use. i want to make it a slow pain in the ass but balance it out with being incredibly fuckin' tough and blast resistant
	//connect_n = 4
	//connect_s = 4
	//connect_e = 4
	//connect_w = 4

	insulator_default = "synthrubber"
	conductor_default = "claretine" //lmao don't scrap it for claretine please (this should affect capacity tbh)

/obj/cable/conduit/tee
	name = "all-way conduit junction"
	desc = "A rigid assembly of superconducting power lines. A three-way junction has been made."
	iconmod = "-tee"
	connects = 4
/obj/cable/conduit/allway
	name = "all-way conduit junction"
	desc = "A rigid assembly of superconducting power lines. A four-way junction has been made."
	iconmod = "-all"
	connects = 4

/obj/cable/conduit/tap
	name = "conduit tap"
	desc = "A rigid assembly of superconducting power lines. A terminal tap has been added mid-length."
	iconmod = "-tap"
	tapped = 1

/obj/cable/conduit/trunk
	name = "conduit terminal"
	desc = "A rigid assembly of superconducting power lines. It ends in a terminal tap."
	iconmod = "-trunk"
	tapped = 1 //can connect to terminals

/obj/cable/conduit/switcher
	name = "switched conduit"
	desc = "A rigid assembly of superconducting power lines. It has a heavy duty in-line switch built in."
	iconmod = "-sw1"
	//var/open_circuit = FALSE //governed by a breaker, prevents this cable from being added to a powernet, basically suspends a cable connection without deleting the cable (thanks BatElite)
	//let's save this fuckre for later

/obj/cable/conduit/small
	name = "small power conduit"
	desc = "A two-line superconductor conduit, meant for direct monitoring of power output by terminals."
	icon_state = "conduit-small"
	color = "#BA9B67"

/obj/cable/conduit/small/tap
	name = "small power conduit tap"
	desc = "A two-line superconductor conduit tap, meant for direct monitoring of power output by terminals."
	iconmod = "-tap"
	tapped = 1

/obj/cable/conduit/small/trunk
	name = "small power conduit trunk"
	desc = "A two-line superconductor conduit tap, meant for direct monitoring of power output by terminals."
	iconmod = "-trunk"
	tapped = 1

//conduprocs time
//this is the fixed thing, will need to crib more from disposals
/obj/cable/conduit/New() //var/obj/item/conduit/source draggable and droppable and clickable to rotate 90
	..()
	//if (source)
		//src.dir = source.dir
		//src.iconmod = source.iconmod
	var/turf/T = src.loc			// hide if turf is not intact
									// but show if in space
	if(istype(T, /turf/space) && !istype(T,/turf/space/fluid)) hide(0)
	else if(level==1) hide(T.intact)
	applyCableMaterials(src, getMaterial(insulator_default), getMaterial(conductor_default))
	START_TRACKING

/obj/cable/conduit/updateicon()
	return //no iconstate changes until we add damage/manual tapping (plus iconstate for unwelded connectors maybe)

/obj/cable/conduit/ex_act(severity)

	/* switch (severity)
		if (1)
			//
		if (2)
			if (prob(30))
				src.welded = 0
			if (prob(15))
				var/atom/A = new/obj/item/cable_coil(src.loc, src.d1 ? 2 : 1)
				applyCableMaterials(A, src.insulator, src.conductor)
				qdel(src)*/
	return //for now

/obj/cable/conduit/get_desc(dist, mob/user)
	if(dist < 4 && !welded)
		.= "<br>The conduit splice covers look partially detached."

//still fuckin' deciding which way to go. how's this sound:
//deconstruct: screwdriver, cut cut cut cut (4 per connected side, but generally pretty fast), wrench -> pickupable thing -> screwdriver -> 4 2-length sections of thick claretine wire (or maybe an 8long coil?) and 2 rods
//construct: hit a coil of at least 8 lengths of thick wire with a stack of at least 2 rods and a wirecutter in your hand -> pickupable thing -> wrench, weld weld weld weld, screwdriver?

/obj/cable/conduit/cut(mob/user,turf/T)
	if(welded) //don't even try unless it's loose
		boutput(user, "<span class='alert'>This looks more like a welding job for now.</span>")
		return
	cuts++
	//capacity-- //reduced by cuts, increased by welds. always cut in pairs, whether per conductor or side.
	//this is something to come back to later
	shock(user, 90) //very dangerous, always cut power
	var/num = "first"
	if (cuts == 2)
		num = "second"
	if (cuts == 3)
		num = "third"
	if (cuts == 4)
		num = "fourth"
	if (cuts == 5)
		num = "fifth?? what"
	else if (cuts >= cuts_required) //cut it out
		src.visible_message("<span class='alert'>[user] would have dismantled [src] by now, if there was anything to dismantle it into.</span>","<span class='alert'>You would have dismantled [src] by now, if there was anything to dismantle it into.</span>")
		playsound(src.loc, "sound/items/Wirecutter.ogg", 75, 1)
		sleep(0.5)
		playsound(src.loc, "sound/items/Wirecutter.ogg", 75, 1)
		//..()
		//var/obj/conduitparts/P = new/obj/conduitparts
	else
		playsound(src.loc, "sound/items/Wirecutter.ogg", 75, 1)
		sleep(0.5)
		playsound(src.loc, "sound/items/Wirecutter.ogg", 75, 1)
		src.visible_message("<span class='alert'>[user] cuts through \the [src]'s [num] set of exposed conductor pairs.</span>","<span class='alert'>You cut through \the [src]'s [num] set of exposed conductor pairs.</span>")

/obj/cable/conduit/weld(mob/user,turf/T) //weld to dismantle, disposal pipe style
	shock(user, 50)
	if (welded)
		src.visible_message("<span class='alert'>[user] slice through [src]'s conductor supports.</span>","<span class='alert'>You slice through [src]'s conductor supports.</span>")
		src.welded = 0
	else
		src.visible_message("<span class='alert'>[user] welds [src]'s conductor supports into place.</span>","<span class='alert'>You weld [src]'s conductor supports into place.</span>")
		src.welded = 1
	//add progress bar maybe, two seconds

// called when a new conduit is created
// can be 1 of 3 outcomes:
// 1. Isolated conduit -> create new powernet
// 2. Joins to end or connects loop -> add to old network
// 3. Bridges gap between 2-4(!!) networks -> merge the networks (oh god help me)

/obj/cable/conduit/update_network()
	if(makingpowernets) // this might cause local issues but prevents a big global race condition that breaks everything
		return

	var/turf/T = get_turf(src)
	var/request_rebuild = 0
	//one's for cardinal, others are for ordinal. doing them here because fuck it

	//find them
	src.find_all_connections(T)

	//itsy bitsy funny debug
	src.debug_messages_for_conduits()

	if (!connections) //nobody? really? after all that? new powernet all by yourself
		src.makenewpowernet()

	//now let's check for devices on us
	//BY THE WAY HELLO YES IN MOST NORMAL USE CASES THIS WILL BE HANDLED BY CONDUIT TRUNKS THANKS
	//but for now, we're doing this. and also taps will exist soon anyway so whatever.
	//by the way secure taps only connect to small conduits, syndicate taps will allow regular station wires to get connected
	src.connect_devices(T)

	//now let's check for devices 1 tile next to us... oh wait
	//NOBODY SHOULD BE SUCKING OFF POWER DIRECTLY FROM CONDUITS
	//THAT IS THE POINT
	//OF CONDUITS
	//leaving it here for the time being though, in case anything out there is relying on this behavior
	src.power_devices()

	if(request_rebuild)
		makepowernets()

//if conduit has a direction facing the opposite direction as this check, it's a possible connection
/obj/cable/conduit/find_all_connections(var/turf/T)
	var/checkdir = turn(src.dir,180)
	var/checkdir1 = turn(src.dir,-135)
	var/checkdir2 = turn(src.dir,135)
	for (var/d in cardinal)
		var/turf/TC = get_step(src, d)
		var/obj/cable/conduit/C = locate() in TC
		if (C)	//got one
			if (src.dir in ordinal) //c-bend?
				if (!(checkdir1 &= C.dir) || !(checkdir2 &= C.dir)) //check for the opposite of 45deg to either direction on the neighboring turf and if neither match... keep going
					continue
			else //straight/junction?
				if (!(checkdir &= C.dir)) //same but 180 flip turnwise. bitflags are neat when you learn how to use them
					continue
			//made it through and we still have a valid connection to make
			conduit_connect(C, d)

//if (src.tapped) //engineering will be able to make taps to connect small conduit trunks to big conduits
	//get small conduit trunks on T and connect them, since we never connect directly to wires.
	//but... if a certain sort were to install illegal electrical equipment...
	//if (src.tapped == 2) //the squeakquel
		//get other cables on turf and see if any of them have D1 = 0
		//then: :getin:
		//burns out regular cables
		//fucked up sparks
		//even better if you can lock the switchgear closed
		//both of these can be applied to any straight cable (no trunks or junctions, the overlay will be too weird

//takes a conduit and a direction because i dunno
/obj/cable/conduit/connect_conduit(var/obj/cable/conduit/C, var/d)
	src.conduits += C //for debug vars
		src.connections |= d
		if (C.netnum && powernets[C.netnum]) //does this have a valid powernet already?
			if (!src.netnum) //and we don't have one?
				var/datum/powernet/PN = powernets[C.netnum]
				PN.cables += src
				src.netnum = C.netnum //now we do
				src.connected |= d
			else //oh we DO have a powernet, and they do, too...
				var/datum/powernet/PN = src.get_powernet()
				var/datum/powernet/PC = C.get_powernet()
				src.netnum = C.netnum
				PC.cables += src
				if(PN.cables.len <= PC.cables.len) //theirs is bigger
					PN.join_to(PC)
				else
					PC.join_to(PN)
				src.connected |= d
		else //no valid powernet on connected conduit
			if (!src.netnum) //and WE don't have one? fucked up if true
				//let's see if we can go without this, for now
				/*logTheThing("debug", src, conduit_A, "Conduit \ref[src] ([src.x], [src.y], [src.z]) connected to \ref[conduit_A] which had netnum 0, rebuilding powernets.")
				DEBUG_MESSAGE("Conduit \ref[src] ([src.x], [src.y], [src.z]) connected to \ref[conduit_A] which had netnum 0, rebuilding powernets.")
				return makepowernets()*/
				//new powernet (the only case where we gotta make one, luckily)
				var/datum/powernet/PN = new()
				powernets += PN
				PN.cables += src
				PN.number = length(powernets)
				src.netnum = length(powernets)
				//add the conduit
				PN = powernets[C.netnum]
				PN.cables += src
				C.netnum = src.netnum
				PN.cables += C
				src.connected |= dir
			else //but if WE have one...
				var/datum/powernet/PN = src.get_powernet()
				//just add them on
				C.netnum = src.netnum
				PN.cables += C
				src.connected |= dir

/obj/cable/conduit/connect_devices(var/turf/T)
	if (isturf(T) && src.tapped && !request_rebuild) 	//are we tapped in any way? well then fuck and also piss, that means something can be attached!!! d1 = 0 equivalent
		//if (src.tapped = 2) //or worse yet, attached to the rest of the station distribution cables (but like, we'll add that later that is not a use case for this right now)
			//try to connect a cable (later, the syndie tap item doesn't even EXIST yet)
		for (var/obj/machinery/power/M in T.contents)
			if(M.netnum == 0 || powernets[M.netnum].cables.len == 0) //if it's not connected, or the net it's connected to has no cables? fucked up, let's fix that (also connect APCs and terminals to us)
				if(M.netnum) //it's still "connected" to a technically nonexistent powernet but it's orphaned or stranded something so: let's do a little cleanup
					M.powernet.nodes -= M
					M.powernet.data_nodes -= M
				M.netnum = src.netnum //now let's connect it to our powernet
				M.powernet = powernets[M.netnum]
				M.powernet.nodes += M
				if(M.use_datanet)
					M.powernet.data_nodes += M //link up
			else if(M.netnum != src.netnum) // this shouldn't actually ever happen probably
				request_rebuild = 1 //but let's handle it anyway with Another Fucking MakePowernets, just in case
				break

/obj/cable/conduit/makenewpowernet()
	var/datum/powernet/PN = new()
	powernets += PN
	PN.cables += src
	PN.number = length(powernets)
	src.netnum = length(powernets)
	src.visible_message("<span class='alert'>[src] is a lonely conduit, but is working.</span>")

/obj/cable/conduit/power_devices()
	if(!request_rebuild)
		for (var/d in alldirs) //okay let's iterate in every direction (including ones we didn't connect and diagonals)
			var/turf/TP = get_step(src, d)
			for (var/obj/machinery/power/M in TP.contents)
				if(!M.directwired || M.netnum == -1) //which basically means... terminals, and also APCs (which connect through terminals)
					continue
				if(M.netnum == 0 || powernets[M.netnum].cables.len == 0) //same as above, let's clean it up and bring it into us
					if(M.netnum)
						M.powernet.nodes -= M
						M.powernet.data_nodes -= M
					M.netnum = src.netnum //you are mine now, you belong to me
					M.powernet = powernets[M.netnum]
					M.powernet.nodes += M
					if(M.use_datanet)
						M.powernet.data_nodes += M
				else if(M.netnum != src.netnum)
					request_rebuild = 1 //fuck
					break

/obj/cable/conduit/debug_messages_for_conduits()
	if (src.connections) //woaw we got something
		if (!src.connected)
			src.visible_message("<span class='alert'>Now [src] is a loser conduit. ([connections] connections possible but none made at all.)</span>")
		else if (src.connections >= src.connected)
			src.visible_message("<span class='alert'>Now [src] is a loser conduit. ([connections] connections possible yet [connected] connections made.)</span>")
		else if (src.connections <= src.connected)
			src.visible_message("<span class='alert'>Now [src] is a confusing conduit. ([connections] connections possible yet [connected] connections made.)</span>")
		else if (src.connections == src.connected)
			src.visible_message("<span class='alert'>Now [src] is a happy conduit. [connections] connections found, and [connected] connections made equals them.</span>")
	else
		if (src.connected) //huh?
			src.visible_message("<span class='alert'>Now [src] is a confusing conduit. (No connections possible yet [connected]connections made.)</span>")

/obj/cable/conduit/debug_messages_for_trunks()
	if (src.connections)
		if (!src.connected)
			src.visible_message("<span class='alert'>Now [src] is a loser trunk. ([connections] connections possible but none made at all.)</span>")
		else if (src.connections >= src.connected)
			src.visible_message("<span class='alert'>Now [src] is a loser trunk. ([connections] connections possible yet [connected] connections made.)</span>")
		else if (src.connections <= src.connected)
			src.visible_message("<span class='alert'>Now [src] is a confusing trunk. ([connections] connections possible yet [connected] connections made.)</span>")
		else if (src.connections == src.connected)
			src.visible_message("<span class='alert'>Now [src] is a happy trunk. [connections] connections found, and [connected] connections made equals them.</span>")
	else
		if (src.connected)
			src.visible_message("<span class='alert'>Now [src] is a confusing trunk. (No connections possible yet [connected]connections made.)</span>")

//i was planning to just push the conduit update but then i realized oh fuck, oh my god, shit, piss, i might as well do it while it's fresh so here i am happy 3 am to me
//this cannot tap into conduits, if you want to connect them use a T junction
/obj/cable/conduit/trunk/update_network()
	if(makingpowernets) // this might cause local issues but prevents a big global race condition that breaks everything
						// still want to figure you out, unless batclaire does
		return

	var/turf/T = get_turf(src)
	var/request_rebuild = 0

	if (!connections) //nobody? really? after all that? new powernet
		var/datum/powernet/PN = new()
		powernets += PN
		PN.cables += src
		PN.number = length(powernets)
		src.netnum = length(powernets)
		src.visible_message("<span class='alert'>[src] is a lonely trunk, but is working.</span>")

	//now let's check for devices on us
	//I REALLY need to finish small conduits now so we can better isolate our direct power monitoring EDIT: never mind i did them anyway
	//BUT THIS IS HERE SO NOTHING ELSE BREAKS WHILE I'M FINISHING THE REST
	//by the way secure taps only connect to small conduits, syndicate taps will allow regular station wires to get connected
	src.connect_devices(T)

	if(request_rebuild)
		makepowernets()

//modify this to account for different connections
/obj/cable/conduit/trunk/connect_devices(var/turf/T)
	if (isturf(T) && src.tapped && !request_rebuild)
		for (var/obj/machinery/power/M in T.contents)
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

//this is a small conduit trunk, this goes onto a large conduit and feeds the small conduits and small conduit taps
//you can connect to even less things buddy- power monitoring systems only
//at least, when it's finished. see comments in previous goes-arounds unless something is different or fucked up here
/obj/cable/conduit/small/trunk/update_network()
	if(makingpowernets)
		return

	var/turf/T = get_turf(src)
	var/request_rebuild = 0

	var/turf/TC = get_step(src, src.dir)
	var/obj/cable/conduit/C = locate() in TC
	if (C)
		var/checkdir = turn(src.dir,180)
		if (checkdir &= C.dir)
			conduits += C
			src.connections |= src.dir
			src.connect_trunk(C)

	src.debug_messages_for_trunks

	//hey remember what i said about something different or fucked up
	//find a tapped conduit buddy on same tile and do the same shit as above.
	for (var/obj/cable/conduit/C in T.contents)
		if (istype(C,/obj/cable/conduit/small)) //should only be one but let's iterate anyway while it's still fresh code
			continue //this should only connect to large conduits that are tapped
		if (C.tapped == 0)
			continue //tap required
		//if (C.tapped = 2)
			//generate a lotta fucked up sparks but no connection and no danger (unless you touch it while it's on)
		//pretty standard powernet connection
		src.connect_trunk(C)

	if (!connections)
		var/datum/powernet/PN = new()
		powernets += PN
		PN.cables += src
		PN.number = length(powernets)
		src.netnum = length(powernets)
		src.visible_message("<span class='alert'>[src] is a lonely trunk, but is working.</span>")

	if(request_rebuild)
		makepowernets()

/obj/cable/conduit/connect_trunk(C)
	if (C.netnum && powernets[C.netnum])
		if (!src.netnum)
			var/datum/powernet/PN = powernets[C.netnum]
			PN.cables += src
			src.netnum = C.netnum
		else
			var/datum/powernet/PN = src.get_powernet()
			var/datum/powernet/PC = C.get_powernet()
			src.netnum = C.netnum
			PC.cables += src
			if(PN.cables.len <= PC.cables.len)
				PN.join_to(PC)
			else
				PC.join_to(PN)

/obj/cable/conduit/connect_tap(C)
	if (C.netnum && powernets[C.netnum])
		if (!src.netnum)
			var/datum/powernet/PN = powernets[C.netnum]
			PN.cables += src
			src.netnum = C.netnum
		else
			var/datum/powernet/PN = src.get_powernet()
			var/datum/powernet/PC = C.get_powernet()
			src.netnum = C.netnum
			PC.cables += src
			if(PN.cables.len <= PC.cables.len)
				PN.join_to(PC)
			else
				PC.join_to(PN)

	else
		if (!src.netnum)
			var/datum/powernet/PN = new()
			powernets += PN
			PN.cables += src
			PN.number = length(powernets)
			src.netnum = length(powernets)
			PN = powernets[C.netnum]
			PN.cables += src
			C.netnum = src.netnum
			PN.cables += C
		else
			var/datum/powernet/PN = src.get_powernet()
			C.netnum = src.netnum
			PN.cables += C

//now let's check for devices on us
//this is engineering only, high power monitoring of direct engine output. the small conduits can't be used for any good crimes.
//see prior conduit/device_check for full comments
/obj/cable/conduit/small/device_check(var/turf/T)
	if (isturf(T) && src.tapped && !request_rebuild)
		for (var/obj/machinery/power/M in T.contents)
			if(M.netnum == 0 || powernets[M.netnum].cables.len == 0)
			//only engine/smes/ptl monitoring computers should be connected here
			//powers monitoring terminal stuff directly off distributed mains. maybe set that with a var
			//call it /var/directconduitsmall or something i don't know
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

/obj/cable/conduit/small/tap/update_network()
