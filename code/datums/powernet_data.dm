/datum/data
	var/name = "data"
	var/size = 1.0

/datum/data/record
	name = "record"
	size = 5.0
	/// associated list of various data fields
	var/list/fields = list(  )

proc/FindRecordByFieldValue(var/list/datum/data/record/L, var/field, var/value)
	if (!value) return
	for(var/datum/data/record/R in L)
		if(R.fields[field] == value)
			return R
	return

//powernet nodes that are involved in a cable break (either the node cable itself or a cable connecting it to an adjacent node.)
var/global/list/dirty_pnet_nodes = list()

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

//Represents either a branch (one cable connecting to 3+ other cables) in the net or a dead end (a cable connected to 0-1 other cables)
/datum/powernet_graph_node // not my fault that "nodes" in the context of pnets already means something else

	//which obj/cable or obj/machinery/power we're associated with
	var/obj/cable/physical_node

	///Our direct neighbours
	var/list/datum/powernet_graph_node/adjacent_nodes

	///Our associated powernet
	var/datum/powernet/pnet

	var/netnum = 0

///Run through our connections and update which ones are still relevant, then
/datum/powernet_graph_node/proc/validate()
	var/dissolve_self = isnull(physical_node)
	if (!length(adjacent_nodes))
		if (dissolve_self)
			qdel()
		return

	var/list/datum/powernet_graph_node/previous_adjacent_nodes = adjacent_nodes.Copy()
	for (var/datum/powernet_graph_node/other_node as anything in adjacent_nodes)
		//set this up for checking if there's powernet breaks later.
		other_node.netnum = 0
		var/datum/powernet_graph_link/relevant_link = adjacent_nodes[other_node]

		var/delete_link = (dissolve_self || !other_node.physical_node)//if directly adjacent nodes, see if one of our cables is ded
		//no need to qdel the other node if it's gone in case of explosion cleanup, it'll be on the revalidate list too

		//So like, 99,9% of the time two nodes will have one link between them because that's just the sensible way to map powernets
		//but I realised there are technically valid cable layouts that would put two separate links between the same nodes, neither of which are special.
		//And so we have to account for the possibility of multiple links, even if it's probably always one. I hate this, but hate isn't a coding standard.
		//vars for sadness
		var/how_many_links = 1
		var/unbroken_links = 1
		var/list/links
		if (islist(relevant_link))
			unbroken_links = how_many_links = length(relevant_link)
			links = relevant_link
			relevant_link = links[length(links)]

		do
		{
			if (istype(relevant_link))
				if (delete_link || (relevant_link.expected_length > length(relevant_link.cables))) //link borked or one of the end points borked
					unbroken_links--
					relevant_link.dissolve()

			if (--how_many_links > 0)
				relevant_link = links[how_many_links]
		}
		while (how_many_links > 0)

		if (delete_link || unbroken_links == 0) //break list linking
			other_node.adjacent_nodes -= src
			adjacent_nodes -= other_node

	//we're now basically a straight run and don't need to be a node anymore (I figured doing it here is easier than in dissolving the link)
	if (length(adjacent_nodes) == 2) // && !dissolve_self (shouldn't be necessary)
		dissolve_self = TRUE
		var/datum/powernet_graph_node/node_one = adjacent_nodes[1]
		var/datum/powernet_graph_node/node_two = adjacent_nodes[2]
		var/datum/powernet_graph_link/link_one = adjacent_nodes[node_one]
		var/datum/powernet_graph_link/link_two = adjacent_nodes[node_two]
		//merge links into one
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
			node_one.adjacent_nodes[node_two] |= link_one
			node_two.adjacent_nodes[node_one] |= link_one
		else
			node_one.adjacent_nodes[node_two] = link_one
			node_two.adjacent_nodes[node_one] = link_one //ough writing this bit really hit home just how Huge these graphs still are as data structures.

	if (dissolve_self)
		qdel(src)
		//TODO compare what's left of adjacent_nodes versus previous_adjacent_nodes after doing a network propagation ping
		//Tell the other nodes to split off into other powernets

	dirty_pnet_nodes -= src

///From starting_node, crawl the node network and assign new_netnum
/datum/powernet_graph_node/proc/propagate_netnum(datum/powernet_graph_node/starting_node, new_netnum = 1)
	var/datum/powernet/PN
	if(powernets && length(powernets) >= new_netnum)
		PN = powernets[new_netnum]
	var/list/visited_nodes = list()
	var/list/nodes_to_visit = list(starting_node)

	//Could have done this recursively, but that'd require shoveling the visited nodes list around between calls and I don't think that's cheap?
	while (length(nodes_to_visit))
		var/datum/powernet_graph_node/a_node = nodes_to_visit[1]
		//not bothing updating the powernet's cables list cause I want to deprecate that
		a_node.pnet.all_graph_nodes -= a_node
		a_node.netnum = new_netnum
		a_node.pnet = PN
		PN.all_graph_nodes |= a_node

		visited_nodes |= a_node
		var/list/new_nodes = Copy(a_node.adjacent_nodes) - visited_nodes
		nodes_to_visit |= new_nodes

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

///
/datum/powernet_graph_link/proc/dissolve()
