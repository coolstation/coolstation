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
		src.weld(user,T) //for conduit (but also this)

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

//--------------------------------------------------------------------------------------------
// --- conduits!
// a disastrous mashup of cables and disposal pipes for heavy duty and secure connectivity
//--------------------------------------------------------------------------------------------
// moved down here to make it easier to work and look at
// harder to handle than cables but at least it only really goes between engines and SMES
// tamper resistent and secure (mostly)
// let's say this *safely* does up to 5 megawatts worth of whatever amp draw (draw, not supply)
// but it and gets more and more dangerous above that?
//--------------------------------------------------------------------------------------------

/obj/cable/conduit
	name = "power conduit"
	desc = "A rigid assembly of superconducting power lines."
	icon_state = "conduit-large"
	var/loose = 1 //Unweld, then cut
	var/cuts_required = 4
	var/cuts = 0
	var/list/conduits = list() //debug var, to remove later
	var/connects = 2
	var/connections = 0 //bitflag for all possible connected directions
	var/connected = 0 //bitflag for all actually connected directions
	//var/deconstructs_into = /obj/conduitparts"

	tapped = 0 //1 for standard small conduit tap, 2 for hotwire syndie tap (equivalent to d1 = 0 in regular cable)

	insulator_default = "synthrubber"
	conductor_default = "claretine" //lmao don't scrap it for claretine please (this should affect capacity tbh)

//different types
/obj/cable/conduit/tee
	name = "all-way conduit junction"
	desc = "A rigid assembly of superconducting power lines. A three-way junction has been made."
	iconmod = "-tee"
	cuts_required = 6
	connects = 4
/obj/cable/conduit/allway
	name = "all-way conduit junction"
	desc = "A rigid assembly of superconducting power lines. A four-way junction has been made."
	iconmod = "-all"
	cuts_required = 8
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

//--------------------------------------------------------------------------------------------
//--- conduit standard procs
//--------------------------------------------------------------------------------------------
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

/obj/cable/conduit/ex_act(severity) //doesn't get deleted but it can get partly disconnected

	switch (severity)
		if (1)
			if (prob(20))
				src.loose = 1
			if (prob(10))
				src.cuts += 1
				if (prob(10))
					src.cuts += 1
					if (prob(10))
						src.cuts += 1
						if (prob(10))
							src.cuts += 1
		if (2)
			if (prob(10))
				src.loose = 1
			if (prob(5))
				src.cuts += 1
				if (prob(5))
					src.cuts += 1
		if (3)
			if (prob(5))
				src.loose = 1
			if (prob(2))
				src.cuts += 1
				if (prob(1))
					src.cuts += 1

/obj/cable/conduit/attackby(obj/item/W, mob/user)
	if (iswrenchingtool(W))
		src.wrench(user)
			//new conduit assembly with vars etc.
	if (isscrewingtool(W))
		src.screw(user)
	if (istype(W, /obj/item/device/t_scanner) || ispulsingtool(W) || (istype(W, /obj/item/device/pda2) && istype(W:module, /obj/item/device/pda_module/tray)))
		src.debug_messages_for_conduits()
		..() //and also do whatever else
	else
		..()


/obj/cable/conduit/get_desc(dist, mob/user)
	if(dist < 3 && src.loose)
		.= "<br>The conduit splice covers look partially detached."
		if (dist < 2 && src.cuts)
			.= "<br>[src.cuts] conductor pair[src.cuts ? "s are" : " is"] disconnected."

//--------------------------------------------------------------------------------------------
//--- construction and deconstruction procs
//--------------------------------------------------------------------------------------------
// deconstruct:	screwdriver, cut cut cut cut (4 per connected side, but generally pretty fast)
// 				wrench -> pickup -> screwdriver -> 4 sections of claretine wire  and 2 rods
// construct:	hit a coil of at least 8 lengths of thick wire with a stack of at least 2 rods
//				and a wirecutter in your hand - > pickupable thing -> wrench, weld weld weld weld
//				screwdriver to "finish" even though it's connected when the first weld is made
// todo: efficiency/safety decreases with cuts? make the cut/welding directional priority?
//--------------------------------------------------------------------------------------------

/obj/cable/conduit/cut(mob/user,turf/T)
	if(loose) //don't even try unless it's loose
		boutput(user, "<span class='alert'>\The [src]'s supports are still in place.</span>")
		return
	cuts++
	//capacity-- //reduced by cuts, increased by welds. always cut in pairs, whether per conductor or side.
	//this is something to come back to later
	shock(user, 90) //very dangerous, always cut power
	var/num = "first"
	if (cuts == 2)
		num = "second" //one side
	if (cuts == 3)
		num = "third"
	if (cuts == 4)
		num = "fourth" //another side, straight and bends gone
	if (cuts == 5)
		num = "fifth"
	if (cuts == 6)
		num = "sixth" //tee
	if (cuts == 7)
		num = "seventh"
	if (cuts == 8)
		num = "eighth" //all-way
	if (cuts == 9)
		num = "ninth? what"
	else if (cuts >= cuts_required) //cut it out
		src.visible_message("<span class='alert'>[user] cuts through \the [src]'s [num] and final set of exposed conductor pairs.</span>","<span class='alert'>You cut through \the [src]'s [num] and final set of exposed conductor pairs.</span>")
		playsound(src.loc, "sound/items/Wirecutter.ogg", 75, 1)
		sleep(0.5)
		playsound(src.loc, "sound/items/Wirecutter.ogg", 75, 1)
	else
		playsound(src.loc, "sound/items/Wirecutter.ogg", 75, 1)
		sleep(0.5)
		playsound(src.loc, "sound/items/Wirecutter.ogg", 75, 1)
		src.visible_message("<span class='alert'>[user] cuts through \the [src]'s [num] set of exposed conductor pairs.</span>","<span class='alert'>You cut through \the [src]'s [num] set of exposed conductor pairs.</span>")

//cut in reverse
/obj/cable/conduit/weld(mob/user,turf/T)
	if(loose) //don't even try unless it's loose
		boutput(user, "<span class='alert'>\The [src]'s supports are still in place.</span>")
		return
	cuts--
	//capacity-- //reduced by cuts, increased by welds. always cut in pairs, whether per conductor or side.
	//this is something to come back to later
	shock(user, 90) //very dangerous, always cut power
	var/num = "first"
	if (cuts == 2)
		num = "second" //one side
	if (cuts == 3)
		num = "third"
	if (cuts == 4)
		num = "fourth" //another side, straight and bends gone
	if (cuts == 5)
		num = "fifth"
	if (cuts == 6)
		num = "sixth" //tee
	if (cuts == 7)
		num = "seventh"
	if (cuts == 8)
		num = "eighth" //all-way
	if (cuts == 9)
		num = "ninth? what"
	else if (cuts <= cuts_required) //cut it out
		boutput(user, "<span class='alert'>\The [src] is fully connected.</span>")
	else
		playsound(src.loc, "sound/items/Welder.ogg", 75, 1)
		sleep(0.5)
		playsound(src.loc, "sound/items/Welder.ogg", 75, 1)
		src.visible_message("<span class='alert'>[user] welds \the [src]'s [num] set of exposed conductor pairs together.</span>","<span class='alert'>You weld \the [src]'s [num] set of exposed conductor pairs together.</span>")

/obj/cable/conduit/proc/screw(mob/user) //weld to dismantle, disposal pipe style
	if(src.cuts ? shock(user, 90) : shock(user, 50))
		src.visible_message("<span class='alert'>[user] tries to work on [src] but it arcs wildly! Holy fuck!</span>","<span class='alert'>[src] arcs WILDLY and you back the fuck off! Holy shit!</span>")
	else
		if (loose)
			src.visible_message("<span class='alert'>[user] secures [src]'s conductor supports over the splices.</span>","<span class='alert'>You slice through [src]'s conductor supports over the splices.[src.cuts ? " Not all the conductors are connected." : null]</span>")
			src.loose = 0
		else
			src.visible_message("<span class='alert'>[user] removes [src]'s conductor supports, exposing the cable splices.</span>","<span class='alert'>You remove [src]'s conductor supports, exposing the cable splices.</span>")
			src.loose = 1
		playsound(src, "sound/items/Screwdriver.ogg", 50, 1)

/obj/cable/conduit/proc/wrench(mob/user) //weld to dismantle, disposal pipe style
	if(src.cuts >= src.cuts_required || !src.loose)
		boutput(user,"<span class='alert'>[src] is still at least partially connected and can't be removed.</span>")
	else
		src.visible_message("<span class='alert'>[user] unsecures [src] from the subfloor.</span>","<span class='alert'>You unsecure [src] from the subfloor. Or you would if that was currently in.</span>")
		//var/obj/conduitparts/P = new/obj/conduitparts
		//P.dir = src.dir
		playsound(src, "sound/items/Ratchet.ogg", 75, 1)
		//qdel(src)
//--------------------------------------------------------------------------------------------
//--- powernet handling (oh god)
//--------------------------------------------------------------------------------------------
// called when a new conduit is created
// can be 1 of 3 outcomes:
// 1. Isolated conduit -> create new powernet
// 2. Joins to end or connects loop -> add to old network
// 3. Bridges gap between 2-4(!!) networks -> merge the networks (oh god help me)

//standard connection: conduits to conduits
/obj/cable/conduit/update_network()
	if(makingpowernets) // this might cause local issues but prevents a big global race condition that breaks everything
		return

	var/turf/T = get_turf(src)
	var/request_rebuild = 0
	//reset
	src.conduits = list()
	src.connections = 0
	src.connected = 0

	//find conduits and connect them
	src.make_all_connections(T)

	if (!connections) //nobody? really? after all that? new powernet all by yourself
		src.makenewpowernet()

	//now let's check for devices on us
	//BY THE WAY HELLO YES IN MOST NORMAL USE CASES THIS WILL BE HANDLED BY CONDUIT TRUNKS THANKS
	//but for now, we're doing this. and also taps will exist soon anyway so whatever.
	//by the way secure taps only connect to small conduits, syndicate taps will allow regular station wires to get connected
	if (!request_rebuild)
		request_rebuild = src.connect_devices(T)

	//now let's check for devices 1 tile next to us... oh wait
	//NOBODY SHOULD BE SUCKING OFF POWER DIRECTLY FROM CONDUITS
	//THAT IS THE POINT
	//OF CONDUITS
	//if (!request_rebuild)
	//	request_rebuild = src.power_devices()

	if(request_rebuild)
		makepowernets()


//special handling for conduit trunks, which connect to SMES and large power generating devices
//this cannot tap into conduits, if you want to connect to an existing conduit: use a T junction
/obj/cable/conduit/trunk/update_network()
	if(makingpowernets) // this might cause local issues but prevents a big global race condition that breaks everything
						// still want to figure you out, unless batclaire does first
		return

	var/turf/T = get_turf(src)
	var/checkdir = turn(src.dir,180)
	var/request_rebuild = 0

	var/turf/TC = get_step(src, src.dir) //easy one step check
	var/obj/cable/conduit/C = locate() in TC
	if (C)
		if (checkdir &= C.dir)
			if (src.connect_conduit(C))
				src.conduits += C
				src.connections |= src.dir

	if (!connections)
		src.makenewpowernet()

	//now let's check for devices on us
	if(!request_rebuild)
		request_rebuild = src.connect_devices(T)

	if(request_rebuild)
		makepowernets()
	//and we're basically done here

//if conduit has a direction facing the opposite direction as our conduit, it's a possible connection
/obj/cable/conduit/proc/make_all_connections(var/turf/T)
	//one's for cardinal, others are for ordinal.
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
			if (src.connect_conduit(C))
				src.conduits += C
				src.connections |= src.dir

//if despite all best efforts there are no powernet connections to be had, make a new powernet
/obj/cable/conduit/proc/makenewpowernet()
	var/datum/powernet/PN = new()
	powernets += PN
	PN.cables += src
	PN.number = length(powernets)
	src.netnum = length(powernets)
	src.visible_message("<span class='alert'>[src] is a lonely conduit, but is working.</span>")

//takes another conduit and connects it to this one, returns 1 if successfully connected
/obj/cable/conduit/proc/connect_conduit(var/obj/cable/conduit/C)
	if (C.netnum && powernets[C.netnum]) //does this have a valid powernet already?
		if (!src.netnum) //and we don't have one?
			var/datum/powernet/PN = powernets[C.netnum]
			src.netnum = C.netnum //now we do
			PN.cables += src //add us in
		else //oh we DO have a powernet, and they do, too...
			var/datum/powernet/PN = src.get_powernet()
			var/datum/powernet/PC = C.get_powernet()
			src.netnum = C.netnum
			PC.cables += src
			if(PN.cables.len <= PC.cables.len) //theirs is bigger
				PN.join_to(PC)
			else
				PC.join_to(PN)
	else //no valid powernet on connected conduit
		if (!src.netnum) //and WE don't have one? fucked up if true
			//new powernet (the only case where we gotta make one, luckily)
			src.makenewpowernet()
			//add the conduit
			var/datum/powernet/PN = src.get_powernet()
			PN = powernets[C.netnum]
			PN.cables += src
			C.netnum = src.netnum
			PN.cables += C
			logTheThing("debug", src, C, "Conduit \ref[src] ([src.x], [src.y], [src.z]) connected to \ref[C] which had netnum 0. Conduit now has [src.netnum] and other conduit has [C.netnum].")
			DEBUG_MESSAGE("Conduit \ref[src] ([src.x], [src.y], [src.z]) connected to \ref[C] which had netnum 0. Conduit now has [src.netnum] and other conduit has [C.netnum].")
			//let's see if we can go without this, for now
			//return makepowernets()
		else //but if WE have one...
			var/datum/powernet/PN = src.get_powernet()
			//just add them to ours
			C.netnum = src.netnum
			PN.cables += C

//for anything that directly connects to this tapped thing
/obj/cable/conduit/proc/connect_devices(var/turf/T)
	var/rebuild = 0
	if (isturf(T) && src.tapped) //are we tapped in any way? well then fuck and also piss, that means something can be attached!!! at least for now. d1 = 0 equivalent
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
				rebuild = 1 //but let's handle it anyway with Another Fucking MakePowernets, just in case
				break
		//if (src.tapped = 2) //or worse yet, attached to the rest of the station distribution cables (but like, we'll add that later that is not a use case for this right now)
			//for (var/obj/cable/C in T.contents) try to connect a cable (later, the syndie tap item doesn't even EXIST yet)
			//if successful congratulations you are now a spark throwing hell mess
			//also cause bugs, wrong data, cable burnouts, etc.
	return rebuild

//breaking this out for now and not using it, but i will definitely put this into /cable
/obj/cable/conduit/proc/power_devices()
	var/rebuild = 0
	for (var/d in alldirs) //okay let's iterate in every direction (including ones we didn't connect and diagonals)
		var/turf/TP = get_step(src, d)
		for (var/obj/machinery/power/M in TP.contents)
			if(!M.directwired || M.netnum == -1) //which basically means... no terminals or APCs (which connect through terminals)
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
				rebuild = 1 //fuck
				break
	return rebuild

	//notes on taps:
	//
	//a tapped conduit should try to connect to any valid connection on top of it when created...
	//...in case of existing valid connection that wouldn't otherwise be connected
	//however, the connection to the tap should otherwise be made by the smaller, tapping connection on top
	//
	//engineering will be able to make safe taps on large conduits to connect small conduit trunks for powernet monitoring
	//i.e. when installed, check for small conduit trunks on src turf and connect them, and them alone, since we never connect directly to anything else
	//
	//but... if a certain sort were to install illegal electrical equipment, we get tapped 2: the squeakquel
	//get other cables on turf and see if any of them have D1 = 0, while cables and small trunk taps also check for tapped == 2
	//then: :getin:
	//burns out regular cables if current too high, fucked up sparks, the works.
	//even better if you can lock the switchgear closed so nobody can fix it without shutting down the engine or doing dangerous repairs
	//
	//both of these can be applied to any straight cable (no trunks or junctions, the overlay will be too weird
	//these checks will be done by regular cables, or bootstrapped by the tap itself when placed

//debug messages, hit it with some electronic pulsing tool or whatever
/obj/cable/conduit/proc/debug_messages_for_conduits()
	if (src.connections)
		if (!src.connected)
			src.visible_message("<span class='alert'>[src] is a loser conduit. ([connections] connections possible but none made at all.)</span>")
		else if (src.connections >= src.connected)
			src.visible_message("<span class='alert'>[src] is a loser conduit. ([connections] connections possible yet [connected] connections made.)</span>")
		else if (src.connections <= src.connected)
			src.visible_message("<span class='alert'>[src] is a confusing conduit. ([connections] connections possible yet [connected] connections made.)</span>")
		else if (src.connections == src.connected)
			src.visible_message("<span class='alert'>[src] is a happy conduit. [connections] connections found, and [connected] connections made equals them.</span>")
	else
		if (src.connected) //huh?
			src.visible_message("<span class='alert'>[src] is a confusing conduit. (No connections possible yet [connected]connections made.)</span>")

//connection handling for trunks, which only check one direction and connect to limited things
//should just be SMES/power generating equipment only, no terminals or conduit taps)
/obj/cable/conduit/trunk/connect_devices(var/turf/T)
	var/rebuild = 0
	if (isturf(T) && src.tapped)
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
				rebuild = 1
				break
	return rebuild

// -----------------------------
// ------ small conduits -------
// -----------------------------

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

//--------------------------------------------------------------------------------------------
//---- small conduit procs
//--------------------------------------------------------------------------------------------
//small conduits only connect to small conduits and that's handled by the make_all_connections override
//might make an end overlay so it appears capped, but that's later
//--------------------------------------------------------------------------------------------

//this is a small conduit trunk, this goes onto a large conduit and feeds the small conduits and small conduit taps
//at least, when it's finished. see comments in previous goes-arounds unless something is different or fucked up
/obj/cable/conduit/small/trunk/update_network()
	if(makingpowernets)
		return

	var/request_rebuild = 0
	//reset
	src.conduits = list()
	src.connections = 0
	src.connected = 0

	//hey remember what i said about something different or fucked up
	//find a tapped conduit buddy on same tile and do the same shit as above.
	var/turf/T = get_step(src, src.dir)
	var/obj/cable/conduit/C = locate() in T //still look for large conduits
	if (C)
		if (istype(C,/obj/cable/conduit)) //should only be one but let's iterate anyway while it's still fresh code
			if (C.tapped)
				var/checkdir = turn(src.dir,180)
				if (checkdir &= C.dir)
					if (src.connect_conduit(C))
						src.conduits += C
						src.connections |= src.dir
					//if (C.tapped = 2)
						//generate a lotta fucked up sparks on a continuing basis from this and connected small conduit taps
						//also garble output to all monitoring computers

	if (!connections)
		src.makenewpowernet()

	//nothing connects to this directly, this is not a d1=0 situation and isn't like the large conduit trunk at all

	if(request_rebuild)
		makepowernets()
	//and we're basically done here

//this is the process the taps use
//you can connect to power monitoring terminals only
/obj/cable/conduit/small/tap/update_network()
	if(makingpowernets)
		return

	var/turf/T = get_turf(src)
	var/request_rebuild = 0

	var/turf/TC = get_step(src, src.dir)
	var/obj/cable/conduit/small/C = locate() in TC
	if (C)
		var/checkdir = turn(src.dir,180)
		if (checkdir &= C.dir)
			if (src.connect_conduit(C))
				src.conduits += C
				src.connections |= src.dir


	for (var/obj/cable/conduit/C in T.contents)
		if (istype(C,/obj/cable/conduit/small)) //should only be one but let's iterate anyway while it's still fresh code
			if (src.connect_conduit(C))
				src.conduits += C
				src.connections |= src.dir
		else
			continue //small conduits only
		//if (C.tapped = 2)
			//generate a lotta fucked up sparks on a continuing basis from this and connected small conduit taps
			//also garble output to all monitoring computers
		//otherwise pretty standard powernet connection

	if (!connections)
		src.makenewpowernet()

	if(request_rebuild)
		makepowernets()

/obj/cable/conduit/small/make_all_connections(var/turf/T)
	var/checkdir = turn(src.dir,180)
	var/checkdir1 = turn(src.dir,-135)
	var/checkdir2 = turn(src.dir,135)
	for (var/d in cardinal)
		var/turf/TC = get_step(src, d)
		var/obj/cable/conduit/small/C = locate() in TC
		if (C)	//got one
			if (src.dir in ordinal) //c-bend?
				if (!(checkdir1 &= C.dir) || !(checkdir2 &= C.dir)) //check for the opposite of 45deg to either direction on the neighboring turf and if neither match... keep going
					continue
			else //straight/junction?
				if (!(checkdir &= C.dir)) //same but 180 flip turnwise. bitflags are neat when you learn how to use them
					continue
			//made it through and we still have a valid connection to make
			if (src.connect_conduit(C))
				src.conduits += C
				src.connections |= src.dir

//this is engineering only, high power monitoring of direct engine output. the small conduits can't be used for any good crimes.
//see prior conduit/device_check for full comments
/obj/cable/conduit/small/proc/device_check(var/turf/T)
	var/rebuild = 0
	if (isturf(T) && src.tapped)
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
				rebuild = 1
				break
	return rebuild
