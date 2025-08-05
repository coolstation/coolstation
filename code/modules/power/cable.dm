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

		if(T.intact || !istype(T, /turf/floor))
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
		NC.integrate()//update_network()
		coil.use(1)
		return
	else
		..()
	return


// the power cable object
/obj/cable
	level = 1
	anchored =1
	//var/tmp/netnum = 0
	name = "power cable"
	desc = "A flexible power cable."
	icon = 'icons/obj/machines/power_cond.dmi'
	icon_state = "0-1"
	var/d1 = 0
	var/d2 = 1
	var/iconmod = null
	//var/image/cableimg = null
	//^ is unnecessary, i think
	layer = CABLE_LAYER
	plane = PLANE_NOSHADOW_BELOW
	color = "#DD0000"
	text = ""

	var/insulator_default = "synthrubber"
	var/conductor_default = "pharosium"
	var/cuttable = "1"
	var/open_circuit = FALSE //governed by breakers, prevents this cable from being added to a powernet, basically suspends a cable connection without deleting the cable

	var/datum/material/insulator = null
	var/datum/material/conductor = null

	//Are we a branch or dead end in the powernet...
	var/datum/powernet_graph_node/is_a_node = null
	//...or part of the connective tissue?
	var/datum/powernet_graph_link/is_a_link = null

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

/obj/cable/New(var/newloc, var/obj/item/cable_coil/source, dir1, dir2)
	..()
	// ensure d1 & d2 reflect the icon_state for entering and exiting cable
	if (dir1)
		d1 = dir1
	else
		d1 = text2num( icon_state )

	if (dir2)
		d2 = dir2
	else
		d2 = text2num( copytext( icon_state, findtext(icon_state, "-")+1 ) )

	if (source) src.iconmod = source.iconmod

	var/turf/T = src.loc			// hide if turf is not intact
									// but show if in space
	if(level==1) hide(T.intact)

	//cableimg = image(src.icon, src.loc, src.icon_state)
	//cableimg.layer = OBJ_LAYER

	if (istype(source))
		applyCableMaterials(src, source.insulator, source.conductor)
	else
		applyCableMaterials(src, getMaterial(insulator_default), getMaterial(conductor_default))

	if (current_state >= GAME_STATE_WORLD_INIT)
		if (worldgen_hold)
			worldgen_candidates[worldgen_generation] += src
		else
			src.integrate()
		//all_cables += src

	START_TRACKING

//Deal with prefabs plopping down cablenets of their own
//what this currently does not account for is something like a prefab type that adds to the station grid,
//in which case it would be sensible to find an existing powernet to propagate to the new parts
/obj/cable/generate_worldgen()
	if (src.is_a_link) return
	if (src.is_a_node) return
	DEBUG_MESSAGE("Adding new powernet section (likely a prefab getting placed)")
	makepowernet_from_cable(src, length(powernets) + 1)
	DEBUG_MESSAGE("Finishing new powernet section")

/obj/cable/disposing()		// called when a cable is deleted
	STOP_TRACKING
	..()					// move cable first

	if (is_a_link)
		is_a_link.cables -= src
		if (defer_powernet_rebuild)
			if (is_a_link.adjacent_nodes)
				dirty_pnet_nodes |= is_a_link.adjacent_nodes
		else
			var/datum/powernet_graph_node/node1 = is_a_link.adjacent_nodes[1]
			var/datum/powernet_graph_node/node2 = is_a_link.adjacent_nodes[2]
			node1.validate()
			node2.validate()
		is_a_link = null
	else if (is_a_node)
		is_a_node.physical_node = null
		if (defer_powernet_rebuild)
			dirty_pnet_nodes |= is_a_node
		else
			is_a_node.validate()
		is_a_node = null

/obj/cable/hide(var/i)

	if(level == 1)
		invisibility = i ? 101 : 0
	updateicon()

/obj/cable/proc/updateicon()
	icon_state = "[d1]-[d2][iconmod]"
	alpha = invisibility ? 128 : 255
	//if (cableimg)
	//	cableimg.icon_state = icon_state
	//	cableimg.alpha = invisibility ? 128 : 255


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
	//What if this isn't bugged anymore? IDK
	//defer_powernet_rebuild = 0		// to fix no-action bug
	qdel(src)
	return

/obj/cable/proc/weld(mob/user,turf/T) //set up the welder proc for conduit
	src.visible_message("<span class='alert'>[user] melts the cable's insulation for some reason.</span>")
	//todo: set cable is melted
	//new proc: do the glass shard thing and see if someone stepping on it doesn't have shoes and if not, zap them
	//probably don't want to do powernet shit

	shock(user, 50)

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
	var/number = 0
	if(open_circuit) //This goes before the netnum thing because it's probably 0 in this case

		if (!powernets) return 0

		if (is_a_node)
			number = is_a_node.pnet.number
		else if (is_a_link?.adjacent_nodes)
			var/datum/powernet_graph_node/N = is_a_link.adjacent_nodes[1]
			number = N.pnet.number

		//The below wouldn't work with the new structure of powernets anyway, but I'm sitting here wondering why they bothered looping all the connections
		//If these cables are your direct connections you're all on the same fucken powernet anyway.
		/*
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
		return result ? src.electrocute(user, prb, result) : 0*/

	if(!number)		// unconnected cable is unpowered
		return 0

	return src.electrocute(user, prb, number)

/obj/cable/ex_act(severity, last_touched, epicenter, turf_safe)
	if(turf_safe)
		severity = severity - 8
	switch (severity)
		if (OLD_EX_SEVERITY_1)
			qdel(src)
		if (OLD_EX_SEVERITY_2)
			if (prob(15))
				var/atom/A = new/obj/item/cable_coil(src.loc, src.d1 ? 2 : 1)
				applyCableMaterials(A, src.insulator, src.conductor)
			qdel(src)

/obj/cable/reinforced/ex_act(severity)
	return //nah

//(should probably deprecate for get_powernet, since most applications of this end up looking up the powernet themselves anyway)
// returns the netnumber powernet this cable belongs to
/obj/cable/proc/get_netnumber()
	var/datum/powernet_graph_node/polled_node = src.is_a_node
	if (src.is_a_link)
		polled_node = src.is_a_link.adjacent_nodes[1]
	return polled_node.pnet.number

// returns the powernet this cable belongs to
/obj/cable/proc/get_powernet()
	var/datum/powernet_graph_node/polled_node = src.is_a_node
	if (src.is_a_link)
		polled_node = src.is_a_link.adjacent_nodes[1]
	return polled_node.pnet

///add new cable into surrounding pnet data structure at runtime
/obj/cable/proc/integrate()
	var/connections = get_connections(FALSE)
	var/datum/powernet/future_powernet

	//loose cable with no neighbours
	if (!length(connections))
		src.is_a_node = new()
		src.is_a_node.physical_node = src
		src.is_a_node.pnet = new /datum/powernet()
		powernets += src.is_a_node.pnet
		src.is_a_node.pnet.number = length(powernets)
		return

	//In theory it'd be possible to steal the node datum from a connection that doesn't need it anymore,
	//but it complicates things a lot and I'm not convinced it'd be any faster.
	if (length(connections) != 2)
		src.is_a_node = new() //no pnet yet, we'll be able to get one later

	//Assumption: the topology of adjacent connections is correct (no nodes that should be links or vice versa, or unincorporated stuff)
	//Assumption: every connection we found will also find us, one more connection than they had previously.
	//				HOWEVER, their node's adjacent_nodes doesn't know about us yet
	//Thus, anything that has 3 connections now was previously a link and needs to turn into a node
	//and anything with 2 connections was a node that needs to become a link
	//everything else was and is a node

	var/list/cables_with_links2kill = list()
	var/list/datum/powernet_graph_node/nodes2kill = list()
	var/list/datum/powernet_graph_node/nodes2link = list()


	for (var/obj/cable/C in connections)
		if (C.is_a_node)
			if (!future_powernet)
				future_powernet = C.is_a_node.pnet
			else
				if (future_powernet.number > C.is_a_node.pnet.number)
					future_powernet = C.is_a_node.pnet //select for smallest numbered pnet

		var/list/awawa = C.get_connections()
		switch(length(awawa))
			if (3) //other cable was a link, needs to become a node
				cables_with_links2kill += C
			if (2) //other cable was a dead end, is now a simple connection

				nodes2kill += C.is_a_node
			else   //other cable stays a node
				nodes2link += C.is_a_node

	if (!src.is_a_node && length(nodes2kill) == 2) //edge case time
		//So, one thing that can happen is we close a loop of wire
		//where we'd technically not have any junctions that should be nodes, but nodes are also required for powernets to function.
		//so in that case we'll just leave the two previous dead ends as nodes.
		var/datum/powernet_graph_node/possible_loop_node_1 = nodes2kill[1]
		var/datum/powernet_graph_node/possible_loop_node_2 = nodes2kill[2]
		if (length(possible_loop_node_1.adjacent_nodes) == 1 && length(possible_loop_node_2.adjacent_nodes) == 1)
			if (possible_loop_node_2 in possible_loop_node_1.adjacent_nodes)
				src.is_a_link = new(list(src), list(possible_loop_node_1, possible_loop_node_2))
				//list em up, since, well, technically we've given it the topology of two links connecting the same nodes
				possible_loop_node_1.adjacent_nodes[possible_loop_node_2] = list(possible_loop_node_1.adjacent_nodes[possible_loop_node_2], src.is_a_link)
				possible_loop_node_2.adjacent_nodes[possible_loop_node_1] = list(possible_loop_node_2.adjacent_nodes[possible_loop_node_1], src.is_a_link)
				return //we've handled the entire net by now

	//normal handling now

	//first, we let ex-links sort themselves out
	//we might end up assigned a link through all this, and if not then this will sort out part of our node connections.
	for(var/obj/cable/new_physical_node as anything in cables_with_links2kill)
		var/datum/powernet_graph_link/dead_link = new_physical_node.is_a_link
		dead_link.cables -= new_physical_node
		dead_link.dissolve()
		new_physical_node.is_a_node = new()
		new_physical_node.is_a_node.physical_node = new_physical_node
		if (src.is_a_node)
			src.is_a_node.adjacent_nodes += new_physical_node.is_a_node
			new_physical_node.is_a_node.adjacent_nodes += src.is_a_node
		else
			nodes2link |= new_physical_node.is_a_node

	if (src.is_a_node)
		//these are going from 1->2 connections, so by definition they only had one adjacent node
		for (var/datum/powernet_graph_node/dead_node as anything in nodes2kill)
			var/datum/powernet_graph_node/neighbour_node = dead_node.adjacent_nodes[1]
			var/datum/powernet_graph_link/maybe_link = dead_node.adjacent_nodes[neighbour_node]
			if (istype(maybe_link))	//use existing link
				dead_node.physical_node.is_a_link = maybe_link
				maybe_link.cables += dead_node.physical_node
				maybe_link.expected_length = length(maybe_link.cables)
			else //make a new link
				dead_node.physical_node.is_a_link = new(list(dead_node.physical_node), list(src.is_a_node, neighbour_node))

			neighbour_node.adjacent_nodes -= dead_node
			dead_node.physical_node.is_a_node = null
			qdel(dead_node)
			neighbour_node.adjacent_nodes[src.is_a_node] = maybe_link
			src.is_a_node.adjacent_nodes[neighbour_node] = maybe_link

		for (var/datum/powernet_graph_node/directly_adjacent_node as anything in nodes2link) //just add each other's refs
			directly_adjacent_node.adjacent_nodes += src.is_a_node
			src.is_a_node.adjacent_nodes += directly_adjacent_node

		src.is_a_node.propagate_netnum(src.is_a_node, future_powernet.number, early_end_at_matching_netnum = TRUE)



	else //we are a link
		//dead end 2 link
		for (var/datum/powernet_graph_node/dead_node as anything in nodes2kill)
			if (length(dead_node.adjacent_nodes))
				var/datum/powernet_graph_node/neighbour_node = dead_node.adjacent_nodes[1]
				var/datum/powernet_graph_link/maybe_link = dead_node.adjacent_nodes[neighbour_node]

				neighbour_node.adjacent_nodes -= dead_node

				if (istype(maybe_link))	//use existing link
					if (src.is_a_link) //ah dang it, we gotta merge
						src.is_a_link.cables += maybe_link.cables
						src.is_a_link.cables += dead_node.physical_node
						dead_node.physical_node.is_a_link = src.is_a_link
						src.is_a_link.adjacent_nodes += neighbour_node
					else //let's add both of us to it
						src.is_a_link = maybe_link
						dead_node.physical_node.is_a_link = maybe_link
						maybe_link.cables += list(dead_node.physical_node, src)
				else //make a new link
					if (src.is_a_link)
						src.is_a_link.cables += dead_node.physical_node
						dead_node.physical_node.is_a_link = src.is_a_link
					else
						src.is_a_link = new(list(src, dead_node.physical_node), list(neighbour_node))
						dead_node.physical_node.is_a_link = src.is_a_link

				//neighbour_node.adjacent_nodes[src.is_a_node] = maybe_link
				//src.is_a_node.adjacent_nodes[neighbour_node] = maybe_link

			dead_node.physical_node.is_a_node = null
			qdel(dead_node)

		//All that's left is direct neighbouring nodes. If we're not part of a link yet, there's no way we'd get assigned one anymore.
		if (!src.is_a_link)
			src.is_a_link = new(list(src))

		for (var/datum/powernet_graph_node/directly_adjacent_node as anything in nodes2link)
			src.is_a_link.adjacent_nodes += directly_adjacent_node

		correct_link_references()

		if (length(src.is_a_link.adjacent_nodes))
			var/datum/powernet_graph_node/propergate = src.is_a_link.adjacent_nodes[1]
			propergate.propagate_netnum(propergate, future_powernet.number, early_end_at_matching_netnum = TRUE)


/obj/cable/proc/link_crawl()
	var/list/connections = get_connections()
	switch(length(connections))
		if (3)
			return //should get cleaned up elsewhere in pnet code (trying to avoid recursion in integrate or validate)
		if (1)
			src.is_a_node = new
			src.is_a_node.physical_node = src
			var/obj/cable/C = connections[1]
			if (C.is_a_node)
				C.is_a_node.adjacent_nodes += src.is_a_node
				src.is_a_node.adjacent_nodes += C.is_a_node
				src.is_a_node.pnet = C.is_a_node.pnet
		else //2
			var/datum/powernet_graph_link/new_link = new
			src.is_a_link = new_link
			src.is_a_link.cables += src


			for (var/obj/cable/next_cable as anything in connections)
				var/obj/cable/last_cable = src


				var/list/temp_connections = next_cable.get_connections()
				//go along straights indefinitely
				while (length(temp_connections) == 2)
					if (next_cable in new_link.cables) //we've looped on ourselves
						//assign the two cables we have references for nodes arbitrarily, so the net is still technically functional.
						next_cable.is_a_link = null
						next_cable.is_a_node = new
						next_cable.is_a_node.physical_node = next_cable
						last_cable.is_a_link = null
						last_cable.is_a_node = new
						last_cable.is_a_node.physical_node = last_cable

						new_link.cables -= last_cable
						new_link.cables -= next_cable
						new_link.adjacent_nodes = list(next_cable.is_a_node, last_cable.is_a_node)
						next_cable.is_a_node.adjacent_nodes[last_cable.is_a_node] = list(null, new_link)
						last_cable.is_a_node.adjacent_nodes[next_cable.is_a_node] = list(null, new_link)
						goto loop_break

					new_link.cables += next_cable
					next_cable.is_a_link = new_link
					if (temp_connections[1] == last_cable)
						last_cable = next_cable
						next_cable = temp_connections[2]
					else
						last_cable = next_cable
						next_cable = temp_connections[1]
					temp_connections = next_cable.get_connections()


				//found a node
				if (!next_cable.is_a_node)
					next_cable.is_a_node = new
					next_cable.is_a_link = null
					next_cable.is_a_node.physical_node = next_cable
					//SEND_SIGNAL(next_cable, COMSIG_POWERNET_TOPOLOGY_CHANGE)
				src.is_a_link.adjacent_nodes += next_cable.is_a_node

			loop_break:
			if (src.is_a_link)
				correct_link_references()
			else //in case we've run into the loop-of-wire thing up top, src probably became one of the emergency nodes
				var/obj/cable/unlikely = new_link.cables[1]
				unlikely.correct_link_references()

			return src.is_a_link

///cleanup to make sure our linked nodes know of each other
/obj/cable/proc/correct_link_references()
	var/datum/powernet_graph_node/linked_node_1 = src.is_a_link.adjacent_nodes[1]
	var/datum/powernet_graph_node/linked_node_2 = src.is_a_link.adjacent_nodes[2]
	//I'm sorry this looks like this, it's, yeah
	if (!(linked_node_2 in linked_node_1.adjacent_nodes))
		linked_node_1.adjacent_nodes += linked_node_2
		linked_node_1.adjacent_nodes[linked_node_2] = src.is_a_link
	else //node 1 knows of 2, but not via our link aaaa
		var/datum/powernet_graph_link/maybe_us_node_1 = linked_node_1.adjacent_nodes[linked_node_2]
		if (islist(maybe_us_node_1)) //and it's a fucking list AAAAA
			linked_node_1.adjacent_nodes[linked_node_2] += src.is_a_link
		else if (maybe_us_node_1 != src.is_a_link)
			linked_node_1.adjacent_nodes[linked_node_2] = list(maybe_us_node_1, src.is_a_link)

	if (!(linked_node_1 in linked_node_2.adjacent_nodes))
		linked_node_2.adjacent_nodes += linked_node_1
		linked_node_2.adjacent_nodes[linked_node_1] = src.is_a_link
	else //node 2 knows of 1, but not via our link aaaa
		var/datum/powernet_graph_link/maybe_us_node_2 = linked_node_2.adjacent_nodes[linked_node_1]
		if (islist(maybe_us_node_2)) //and it's a fucking list AAAAA
			linked_node_2.adjacent_nodes[linked_node_1] += src.is_a_link
		else if (maybe_us_node_2 != src.is_a_link)
			linked_node_2.adjacent_nodes[linked_node_1] = list(maybe_us_node_2, src.is_a_link)

	src.is_a_link.expected_length = length(src.is_a_link.cables)



// called when a new cable is created
// can be 1 of 3 outcomes:
// 1. Isolated cable (or only connects to isolated machine) -> create new powernet
// 2. Joins to end or bridges loop of a single network (may also connect isolated machine) -> add to old network
// 3. Bridges gap between 2 networks -> merge the networks (must rebuild lists also) (currently just calls makepowernets. welp)

/*

/obj/cable/proc/update_network()
	if(makingpowernets) // this might cause local issues but prevents a big global race condition that breaks everything
		return
	var/turf/T = get_turf(src)
	var/obj/cable/cable_d1 = null //locate() in (d1 ? get_step(src,d1) : orange(0, src) )
	var/obj/cable/cable_d2 = null //locate() in (d2 ? get_step(src,d2) : orange(0, src) )
	var/request_rebuild = 0

	for (var/obj/cable/new_cable_d1 in src.get_connections_one_dir(is_it_d2 = 0))
		cable_d1 = new_cable_d1
		break

	for (var/obj/cable/new_cable_d2 in src.get_connections_one_dir(is_it_d2 = 1))
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
*/
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
