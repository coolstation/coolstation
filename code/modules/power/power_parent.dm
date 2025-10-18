/obj/machinery/power
	name = null
	icon = 'icons/obj/machines/power.dmi'
	anchored = ANCHORED
	machine_registry_idx = MACHINES_POWER
	var/datum/powernet/powernet = null
	var/tmp/netnum = 0
	var/use_datanet = 0		// If set to 1, communicate with other devices over cable network.
	var/directwired = 1		// by default, power machines are connected by a cable in a neighbouring turf
							// if set to 0, requires a 0-X cable on this turf

/obj/machinery/power/New(var/new_loc)
	..()
	if (netnum != -1)
		if (worldgen_hold || makingpowernets)
			worldgen_candidates[worldgen_generation+1] += src // generated along with cables in a prefab, the cables need to trigger first
		else
			generate_worldgen()

/obj/machinery/power/generate_worldgen()
	src.netnum = 0
	if(makingpowernets)
		return // TODO queue instead
	for(var/obj/cable/C in src.get_connections())
		src.netnum = C.get_netnumber()
		break
	/*
	if(src.netnum == 0)
		src.netnum = C.get_netnumber()
	else if(C.netnum != 0 && C.netnum != src.netnum) // could be a join instead but this won't happen often so screw it
		makepowernets()
		return*/
	if(src.netnum)
		src.powernet = powernets[src.netnum]
		src.powernet.nodes += src
		if(src.use_datanet)
			src.powernet.data_nodes += src


/obj/machinery/power/disposing()
	if(src.powernet)
		src.powernet.nodes -= src
		src.powernet.data_nodes -= src
	if(src.directwired) // it can bridge gaps in the powernet :/
		if(!defer_powernet_rebuild)
			CLEAR_PNET_BACKLOG_NOW
			//for(var/datum/powernet_graph_node/node as anything in dirty_pnet_nodes)
			//	node.validate()
		else
			defer_powernet_rebuild = 2
	. = ..()

// common helper procs for all power machines
/obj/machinery/power/proc/add_avail(var/amount)
	if(powernet)
		powernet.newavail += amount

#ifdef MACHINE_PROCESSING_DEBUG
	var/area/A = get_area(src)
	var/list/machines = detailed_machine_power[A]
	if(!machines)
		detailed_machine_power[A] = list()
		machines = detailed_machine_power[A]
	var/list/machine = machines[src]
	if(!machine)
		machines[src] = list()
		machine = machines[src]
	machine += amount
#endif

/obj/machinery/power/proc/add_load(var/amount)
	if(powernet)
		powernet.newload += amount

/obj/machinery/power/proc/surplus()
	if(powernet)
		return powernet.avail-powernet.load
	else
		return 0

/obj/machinery/power/proc/avail()
	if(powernet)
		return powernet.avail
	else
		return 0


// the powernet datum
// each contiguous network of cables & nodes


// rebuild all power networks from scratch
var/makingpowernets = 0
var/makingpowernetssince = 0
//var/list/obj/cable/all_cables = list()
/proc/makepowernets()
	if (makingpowernets)
		logTheThing("debug", null, null, "makepowernets was called while it was already running! oh no!")
		DEBUG_MESSAGE("attempt to rebuild powernets while already rebuilding")
		return
	DEBUG_MESSAGE("rebuilding powernets start")

	makingpowernets = 1
	if (ticker)
		makingpowernetssince = ticker.round_elapsed_ticks
	else
		makingpowernetssince = 0

	var/netcount = 1 //was 0, we now increment after building a net
	powernets = list()

	for_by_tcl(PC, /obj/cable)
		if (PC.is_a_link) continue
		if (PC.is_a_node) continue
		makepowernet_from_cable(PC, netcount)
		netcount++

		LAGCHECK(LAG_MED)

	makingpowernets = 0
	DEBUG_MESSAGE("rebuilding powernets end")

/proc/makepowernet_from_cable(obj/cable/C, num)
	var/datum/powernet/PN = new
	PN.number = num
	powernets += PN
	var/list/nodes = list()
	var/list/nodes_2_visit = list()

	if (length(C.get_connections()) == 2)
		C.link_crawl()
		if (C.is_a_link)
			nodes |= C.is_a_link.adjacent_nodes
			nodes_2_visit |= C.is_a_link.adjacent_nodes
		else
			nodes |= C.is_a_node
			nodes_2_visit |= C.is_a_node
	else
		C.is_a_node = new
		C.is_a_node.physical_node = C
		nodes |= C.is_a_node
		nodes_2_visit |= C.is_a_node

	while (length(nodes_2_visit))
		var/datum/powernet_graph_node/next_node = nodes_2_visit[1]
		nodes_2_visit -= next_node
		var/obj/cable/next_cable = next_node.physical_node
		for(var/obj/cable/next_next_cable in next_cable.get_connections()) //IDK what to call these things either anymore
			if (next_next_cable.is_a_link) continue
			if (next_next_cable.is_a_node)
				if (next_node in next_next_cable.is_a_node.adjacent_nodes)
					if (islist(next_next_cable.is_a_node.adjacent_nodes[next_next_cable.is_a_node]))
						var/list/lissed = next_node.adjacent_nodes[next_next_cable.is_a_node]
						lissed += null
						next_node.adjacent_nodes[next_next_cable.is_a_node] = lissed
						lissed = next_next_cable.is_a_node.adjacent_nodes[next_node]
						lissed += null
						next_next_cable.is_a_node.adjacent_nodes[next_node] += lissed
					else
						next_node.adjacent_nodes[next_next_cable.is_a_node] = list(next_node.adjacent_nodes[next_next_cable.is_a_node], null)
						next_next_cable.is_a_node.adjacent_nodes[next_node] = list(next_next_cable.is_a_node.adjacent_nodes[next_node], null)
				else
					next_node.adjacent_nodes += next_next_cable.is_a_node
					next_node.adjacent_nodes[next_next_cable.is_a_node] = null
					next_next_cable.is_a_node.adjacent_nodes += next_node
					next_next_cable.is_a_node.adjacent_nodes[next_node] = null
				continue

			if (length(next_next_cable.get_connections()) == 2)
				var/datum/powernet_graph_link/next_next_link = next_next_cable.link_crawl()
				if (!(next_next_link.adjacent_nodes[1] in nodes))
					nodes_2_visit |= next_next_link.adjacent_nodes[1]
				if (!(next_next_link.adjacent_nodes[2] in nodes))
					nodes_2_visit |= next_next_link.adjacent_nodes[2]
				nodes |= next_next_link.adjacent_nodes

			else
				next_next_cable.is_a_node = new
				next_next_cable.is_a_node.physical_node = next_next_cable
				nodes |= next_next_cable.is_a_node
				nodes_2_visit |= next_next_cable.is_a_node


	for(var/datum/powernet_graph_node/net_node as anything in nodes)
		//net_node.netnum = netcount
		net_node.pnet = PN
	PN.all_graph_nodes = nodes

/proc/unfuck_makepowernets()
	makingpowernets = 0

/client/proc/fix_powernets()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set desc = "Attempts for fix the powernets."
	set name = "Fix powernets"
	unfuck_makepowernets()
	makepowernets()

// returns a list of all power-related objects (nodes, cable, junctions) in turf,
// excluding source, that match the direction d
// if unmarked==1, only return those with netnum==0

/proc/power_list(var/turf/T, var/source, var/d, var/unmarked=0, var/cables_only=0)
	. = list()
	var/fdir = (!d)? 0 : turn(d, 180)	// the opposite direction to d (or 0 if d==0)

	if(!cables_only)
		for(var/obj/machinery/power/P in T)
			if(P.netnum < 0)	// exclude APCs
				continue

			if(P.directwired)	// true if this machine covers the whole turf (so can be joined to a cable on neighbour turf)
				if(!unmarked || !P.netnum)
					. += P
			else if(d == 0)		// otherwise, need a 0-X cable on same turf to connect
				if(!unmarked || !P.netnum)
					. += P


	for(var/obj/cable/C in T)
		if(C.open_circuit) continue
		if(C.d1 == fdir || C.d2 == fdir)
			. += C

	. -= source

/obj/machinery/power/proc/get_connections(unmarked = 0)

	if(!directwired)
		return get_indirect_connections(unmarked)

	. = list()
	var/cdir

	for(var/turf/T in orange(1, src))

		cdir = get_dir(T, src)

		for(var/obj/cable/C in T)

			if(C.open_circuit)
				continue

			if(C.d1 == cdir || C.d2 == cdir)
				. += C

/obj/machinery/power/proc/get_indirect_connections(unmarked = 0)

	. = list()

	for(var/obj/cable/C in src.loc)

		if(C.d1 == 0)
			. += C

//LummoxJR patch:
///I think this proc is for collecting power cables/machinery under netnumber [num] starting from [O]. I've added it returning TRUE when it finishes, or FALSE when it cuts of early (so makepowernets can reuse the netnum) - Bat
/*
/proc/powernet_nextlink(var/obj/O, var/num)
    var/list/P
    var/list/more

    //world.log << "start: [O] at [O.x].[O.y]"

	///Cut setup early if we're an open circuit cable (stops em from connecting themselves to adjacent pnets)
    if (istype(O, /obj/cable))
        var/obj/cable/OC = O
        if (OC.open_circuit)
            //OC.netnum = num //makepowernets hands out netnums to unlinked cables, might as well use it so it's accounted for
            return FALSE

    while(1)
        if( istype(O, /obj/cable) )
            var/obj/cable/C = O
            if(C.netnum > 0)
                if(!more || !length(more)) return TRUE
                O = more[more.len]
                more -= O
                continue

            C.netnum = num
            P = C.get_connections(1)

        else if( istype(O, /obj/machinery/power) )

            var/obj/machinery/power/M = O
            if(M.netnum > 0)
                if(!more || !length(more)) return TRUE
                O = more[more.len]
                more -= O
                continue

            M.netnum = num
            P = M.get_connections(1)

        if(P.len == 0)
            if(length(more))
                O = more[more.len]
                more -= O
                continue
            return TRUE

        O = P[1]

        if(P.len > 1)
            if(!more) more = P.Copy(2)
            else
                for(var/X in P)
                    X:netnum = -1
                more += P.Copy(2)
// cut a powernet at this cable object
*/
/datum/powernet/proc/cut_cable(var/obj/cable/C)
	qdel(C)
/*
	var/turf/T1 = C.loc
	if(C.d1)
		T1 = get_step(C, C.d1)

	var/turf/T2 = get_step(C, C.d2)

	var/list/P1 = power_list(T1, C, C.d1)	// what joins on to cut cable in dir1

	var/list/P2 = power_list(T2, C, C.d2)	// what joins on to cut cable in dir2

	if(P1.len == 0 || P2.len ==0)			// if nothing in either list, then the cable was an endpoint
											// no need to rebuild the powernet, just remove cut cable from the list
		cables -= C
		return

	if(makingpowernets)
		return // TODO queue instead

	// zero the netnum of all cables & nodes in this powernet

	for(var/obj/cable/OC as anything in cables)
		OC.netnum = 0
	for(var/obj/machinery/power/OM as anything in nodes)
		OM.netnum = 0


	// remove the cut cable from the network
	C.netnum = -1
	C.open_circuit = TRUE //replaces C.set_loc(null)
	cables -= C

	powernet_nextlink(P1[1], number)		// propagate network from 1st side of cable, using current netnum

	// now test to see if propagation reached to the other side
	// if so, then there's a loop in the network

	var/notlooped = 0
	for(var/obj/O in P2)
		if( istype(O, /obj/machinery/power) )
			var/obj/machinery/power/OM = O
			if(OM.netnum != number)
				notlooped = 1
				break
		else if( istype(O, /obj/cable) )
			var/obj/cable/OC = O
			if(OC.netnum != number)
				notlooped = 1
				break

	if(notlooped)

		// not looped, so make a new powernet

		var/datum/powernet/PN = new()
		//PN.tag = "powernet #[L]"
		powernets += PN
		PN.number = length(powernets)

		for(var/obj/cable/OC as anything in cables)
			if(!OC.netnum)		// non-connected cables will have netnum==0, since they weren't reached by propagation
				OC.netnum = PN.number
				cables -= OC
				PN.cables += OC		// remove from old network & add to new one
			LAGCHECK(LAG_MED)

		for(var/obj/machinery/power/OM as anything in nodes)
			if(!OM.netnum)
				OM.netnum = PN.number
				OM.powernet = PN
				nodes -= OM
				PN.nodes += OM		// same for power machines
				if (OM.use_datanet)	//Don't forget data_nodes! (If relevant)
					data_nodes -= OM
					PN.data_nodes += OM
			LAGCHECK(LAG_MED)

	else
		//there is a loop, so nothing to be done
		return

	return*/
/*
/datum/powernet/proc/join_to(var/datum/powernet/PN) // maybe pool powernets someday
	for(var/obj/cable/C as anything in src.cables)
		C.netnum = PN.number
		PN.cables += C

	for(var/obj/machinery/power/M as anything in src.nodes)
		M.netnum = PN.number
		M.powernet = PN
		PN.nodes += M
		if (M.use_datanet)
			PN.data_nodes += M*/

/datum/powernet/proc/reset()
	load = newload
	newload = 0
	avail = newavail
	newavail = 0

	viewload = 0.8*viewload + 0.2*load

	viewload = round(viewload)

	var/numapc = 0

	if (!nodes)
		nodes = list()

	for(var/obj/machinery/power/terminal/term in nodes)
		if( istype( term.master, /obj/machinery/power/apc ) )
			numapc++

	if(numapc)
		perapc = avail/numapc

	netexcess = avail - load

	if( netexcess > 100)		// if there was excess power last cycle
		for(var/obj/machinery/power/smes/S in nodes)	// find the SMESes in the network
			S.restore()				// and restore some of the power that was used
		for(var/obj/machinery/power/sword_engine/SW in nodes)	//Finds the SWORD Engines in the network.
			SW.restore()				//Restore some of the power that was used.
