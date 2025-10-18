/datum/data
	var/name = "data"
	var/size = 1.0

//powernet nodes that are involved in a cable break (either the node cable itself or a cable connecting it to an adjacent node.)
var/global/list/dirty_pnet_nodes = list()
var/global/list/dirty_power_machines = list()

/datum/powernet
	/// all cables & junctions
	var/list/obj/cable/cables = list()
	/// all APCs & sources
	var/list/obj/machinery/power/nodes = list()
	/// all networked machinery
	var/list/obj/machinery/power/data_nodes = list()

	var/list/datum/powernet_graph_node/all_graph_nodes = list()

	var/newload = 0
	var/load = 0
	var/newavail = 0
	var/avail = 0

	var/viewload = 0

	var/number = 0
	/// per-apc avilability
	var/perapc = 0

	var/netexcess = 0

	disposing()
		for (var/i in src.number to length(powernets))
			var/datum/powernet/PN = powernets[i]
			PN.number = i
		src.number = 0
		..()

//Represents either a branch (one cable connecting to 3+ other cables) in the net or a dead end (a cable connected to 0-1 other cables)
/datum/powernet_graph_node // not my fault that "nodes" in the context of pnets already means something else

	//which obj/cable or obj/machinery/power we're associated with
	var/obj/cable/physical_node

	///Our direct neighbours
	var/list/datum/powernet_graph_node/adjacent_nodes

	///Our associated powernet
	var/datum/powernet/pnet

	//var/netnum = 0


/datum/powernet_graph_node/New()
	adjacent_nodes = list()
	..()

//No attempt at fixing lingering references, just nuke. Let's not make this any more complicated.
/datum/powernet_graph_node/disposing()
	pnet = null
	adjacent_nodes = null
	physical_node = null
	..()


///Run through our connections and update which ones are still relevant, then
/datum/powernet_graph_node/proc/validate()
	var/dissolve_self = isnull(physical_node)
	if (!length(adjacent_nodes))
		if (dissolve_self)
			qdel()
		return

	var/actual_links_left = length(adjacent_nodes) //We have to keep track of adjacent nodes that we are only temporarily broken off from
	var/list/datum/powernet_graph_node/previous_adjacent_nodes = adjacent_nodes.Copy()
	for (var/datum/powernet_graph_node/other_node as anything in adjacent_nodes)
		var/datum/powernet_graph_link/relevant_link = adjacent_nodes[other_node]

		var/delete_link = (dissolve_self || !other_node.physical_node)//if directly adjacent nodes, see if one of our cables is ded
		//no need to qdel the other node if it's gone in case of explosion cleanup, it'll be on the revalidate list too

		//So like, 99,9% of the time two nodes will have one link between them because that's just the sensible way to map powernets
		//but I realised there are technically valid cable layouts that would put two separate links between the same nodes, neither of which are special.
		//And so we have to account for the possibility of multiple links, even if it's probably always one. I hate this, but hate isn't a coding standard.
		//vars for sadness
		var/how_many_links = 1
		var/unbroken_links = 1
		var/inactive_links = 0
		var/list/links
		if (islist(relevant_link))
			unbroken_links = how_many_links = length(relevant_link)
			links = relevant_link
			relevant_link = links[length(links)]

		var/datum/powernet_graph_node/new_node
		do
		{
			if (istype(relevant_link))
				if (delete_link || (relevant_link.expected_length != length(relevant_link.cables))) //link borked or one of the end points borked
					unbroken_links--
					new_node = relevant_link.dissolve(src)

				else if (relevant_link.active <= 0)
					unbroken_links--
					inactive_links++

			if (--how_many_links > 0)
				relevant_link = links[how_many_links]
		}
		while (how_many_links > 0)

		if (delete_link || unbroken_links == 0) //break list linking
			if (!inactive_links && !new_node)
				actual_links_left--
				other_node.adjacent_nodes -= src //probably faster to do it now, but breaks things if there's inactive links
			adjacent_nodes -= other_node

	//we're now basically a straight run and don't need to be a node anymore (I figured doing it here is easier than in dissolving the link)
	if (actual_links_left == 2) // && !dissolve_self (shouldn't be necessary)
		dissolve_self = TRUE
		var/datum/powernet_graph_node/node_one = adjacent_nodes[1]
		var/datum/powernet_graph_node/node_two = adjacent_nodes[2]
		var/datum/powernet_graph_link/link_one = adjacent_nodes[node_one]
		var/datum/powernet_graph_link/link_two = adjacent_nodes[node_two]
		//this branching sucks
		if (link_one)
			if (link_two) //merge links into one
				link_one.cables |= link_two.cables
				link_one.cables += physical_node
				physical_node.is_a_node = null
				physical_node = null
				for(var/obj/cable/C as anything in link_one.cables)
					C.is_a_link = link_one
				link_one.expected_length = length(link_one.cables)
				link_one.adjacent_nodes = list(node_one, node_two)
				//kill superfluous link datum
				link_two.cables = null
				link_two.adjacent_nodes = null
				qdel(link_two)
				//update node graph
				node_one.adjacent_nodes -= src
				node_two.adjacent_nodes -= src
				if (node_two in node_one.adjacent_nodes) //They're already linked, fuck
					node_one.adjacent_nodes[node_two] = (islist(node_one.adjacent_nodes[node_two]) ? node_one.adjacent_nodes[node_two] + link_one : list(node_one.adjacent_nodes[node_two], link_one))
					node_two.adjacent_nodes[node_one] = (islist(node_two.adjacent_nodes[node_one]) ? node_two.adjacent_nodes[node_one] + link_one : list(node_two.adjacent_nodes[node_one], link_one))
				else
					node_one.adjacent_nodes[node_two] = link_one
					node_two.adjacent_nodes[node_one] = link_one //ough writing this bit really hit home just how Huge these graphs still are as data structures.
			else //only link_one is a link datum
				link_one.cables += physical_node
				physical_node.is_a_node = null
				physical_node.is_a_link = link_one
				physical_node = null
				link_one.expected_length = length(link_one.cables)
				link_one.adjacent_nodes = list(node_one, node_two)
				//update node graph
				node_one.adjacent_nodes -= src
				node_two.adjacent_nodes -= src
				if (node_two in node_one.adjacent_nodes)
					node_one.adjacent_nodes[node_two] = (islist(node_one.adjacent_nodes[node_two]) ? node_one.adjacent_nodes[node_two] + link_one : list(node_one.adjacent_nodes[node_two]) + link_one)
					node_two.adjacent_nodes[node_one] = (islist(node_two.adjacent_nodes[node_one]) ? node_two.adjacent_nodes[node_one] + link_one : list(node_two.adjacent_nodes[node_one]) + link_one)
				else
					node_one.adjacent_nodes[node_two] = link_one
					node_two.adjacent_nodes[node_one] = link_one
		else
			if (link_two) //only link_two is a link datum
				link_two.cables += physical_node
				physical_node.is_a_node = null
				physical_node.is_a_link = link_two
				physical_node = null
				link_two.expected_length = length(link_two.cables)
				link_two.adjacent_nodes = list(node_one, node_two)
				//update node graph
				node_one.adjacent_nodes -= src
				node_two.adjacent_nodes -= src
				if (node_two in node_one.adjacent_nodes)
					node_one.adjacent_nodes[node_two] = (islist(node_one.adjacent_nodes[node_two]) ? node_one.adjacent_nodes[node_two] + link_two : list(node_one.adjacent_nodes[node_two]) + link_two)
					node_two.adjacent_nodes[node_one] = (islist(node_two.adjacent_nodes[node_one]) ? node_two.adjacent_nodes[node_one] + link_two : list(node_two.adjacent_nodes[node_one]) + link_two)
				else
					node_one.adjacent_nodes[node_two] = link_two
					node_two.adjacent_nodes[node_one] = link_two
			else //neither side is a link datum
				physical_node.is_a_link = new(list(physical_node), list(node_one, node_two))
				physical_node.is_a_node = null

	previous_adjacent_nodes -= adjacent_nodes

	dirty_power_machines |= src.pnet.nodes

	var/an_netnum = src.pnet.number
	if (length(adjacent_nodes))
		var/datum/powernet_graph_node/non_break_node = adjacent_nodes[1]
		previous_adjacent_nodes -= non_break_node.propagate_netnum(non_break_node, an_netnum)

	while(length(previous_adjacent_nodes))
		var/datum/powernet/PN = new
		powernets += PN
		PN.number = length(powernets)
		an_netnum = PN.number
		var/datum/powernet_graph_node/orphaned_node = previous_adjacent_nodes[1]
		previous_adjacent_nodes -= orphaned_node.propagate_netnum(orphaned_node, an_netnum)

	if (dissolve_self)
		qdel(src)

	dirty_pnet_nodes -= src

	//I'm not happy with putting this here but it'll do for now. Just tossing all the power machines into a bucket like this isn't great
	if (!length(dirty_pnet_nodes))
		for(var/obj/machinery/power/thing as anything in dirty_power_machines)
			thing.generate_worldgen()


///From starting_node, crawl the node network and assign new_netnum
/datum/powernet_graph_node/proc/propagate_netnum(datum/powernet_graph_node/starting_node, new_netnum = 1, early_end_at_matching_netnum = FALSE)
	var/datum/powernet/PN
	if(powernets && length(powernets) >= new_netnum)
		PN = powernets[new_netnum]
	var/list/visited_nodes = list()
	var/list/nodes_to_visit = list(starting_node)

	//Could have done this recursively, but that'd require shoveling the visited nodes list around between calls and I don't think that's cheap?
	while (length(nodes_to_visit))
		var/datum/powernet_graph_node/a_node = nodes_to_visit[1]
		visited_nodes |= a_node
		nodes_to_visit -= a_node

		//If we're just doing a local update (merging 2 nets or whatever) and there's no reason to assume the net as a whole is compromised
		if (a_node.pnet?.number == new_netnum && early_end_at_matching_netnum)
			continue

		//not bothing updating the powernet's cables list cause I want to deprecate that
		if (a_node.pnet)
			a_node.pnet.all_graph_nodes -= a_node
			if (!length(a_node.pnet.all_graph_nodes))
				dirty_power_machines |= a_node.pnet.nodes
				qdel(a_node.pnet)
		//a_node.netnum = new_netnum
		a_node.pnet = PN
		PN.all_graph_nodes |= a_node

		var/list/new_nodes = a_node.adjacent_nodes.Copy() - visited_nodes
		nodes_to_visit |= new_nodes

	return visited_nodes

//Stretches of cables with two connections. That is, the parts that aren't dead ends or
//For navigating the graph we don't need to bother with these, that's the point of abstracting into a graph.
//These are going to be a useful in figuring out what happened to a powernet post-explosion
/datum/powernet_graph_link
	//How many cables we had last time we checked
	var/expected_length = 0
	///How many cables currently claim to be part of this link. Note that this list isn't ordered WRT physical layout in any way.
	var/list/obj/cable/cables
	//Which two nodes are we connecting
	var/list/datum/powernet_graph_node/adjacent_nodes

	//Cable breakers deactivate
	var/active = 1 //Nearly a boolean, but if multiple breakers affect the same link this will go into the negatives

	//links don't have a net number, we'll just grab the number of one of the nodes if needed (should be rare, like mostly people poking wires with multitools).
	//Less stuff to keep in line.

	New(list/new_cables = null, list/new_nodes = null)

		if (new_cables)
			cables = new_cables
			expected_length = length(cables)
		else cables = list()

		if (length(new_nodes) == 2)
			adjacent_nodes = new_nodes
		else adjacent_nodes = list()

		..()

	//No attempt at fixing lingering references, just nuke. Let's not make this any more complicated.
	disposing()
		cables = null
		adjacent_nodes = null
		..()


///split up
/datum/powernet_graph_link/proc/dissolve(var/datum/powernet_graph_node/caller)
	//Should note that when a cable inside a link becomes a node because a new connection appeared
	//That cable is already removed in cable/proc/integrate. The assumption is that all cables we call link_crawl are still links.
	//That is to avoid recursion.

	//break links between nodes
	var/datum/powernet_graph_node/node_1 = adjacent_nodes[1]
	var/datum/powernet_graph_node/node_2 = adjacent_nodes[2]
	var/new_node = null
	if (islist(node_1.adjacent_nodes[node_2]))
		node_1.adjacent_nodes[node_2] -= src
		node_2.adjacent_nodes[node_1] -= src
	else
		node_1.adjacent_nodes -= node_2
		node_2.adjacent_nodes -= node_1
	//let all the cables sort themselves out
	while(length(cables))
		var/obj/cable/C = cables[1]
		var/datum/powernet_graph_link/L = C.link_crawl()
		if (L)
			cables -= L.cables
			if (caller)
				if (caller in L.adjacent_nodes)
					if (L.adjacent_nodes[1] == caller)
						new_node = L.adjacent_nodes[2]
					else
						new_node = L.adjacent_nodes[1]
		else
			cables -= C
			if (C.is_a_node)
				if (caller in C.is_a_node.adjacent_nodes)
					new_node = C.is_a_node

	qdel(src)
	return new_node

///Used with cable switches/breaker boxes. Let our nodes know about each other again so they validate sorta properly.
/datum/powernet_graph_link/proc/reactivate()
	if (src.active > 0) return //we're not inactive? let's not mess with the topography then
	src.active++
	if (src.active <= 0) return //multiple boxes on one link? It's possible
	var/datum/powernet_graph_node/node_1 = adjacent_nodes[1]
	var/datum/powernet_graph_node/node_2 = adjacent_nodes[2]
	if (node_2 in node_1.adjacent_nodes)
		node_1.adjacent_nodes[node_2] += src
		node_2.adjacent_nodes[node_1] += src
	else
		node_1.adjacent_nodes[node_2] = src
		node_2.adjacent_nodes[node_1] = src
