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
	var/obj/physical_node

	///Our direct neighbours
	var/list/datum/powernet_graph_node/adjacent_nodes

	///Our associated powernet
	var/datum/powernet/pnet

	var/netnum = 0

///Run through our connections and update which ones are still relevant, then
/datum/powernet_graph_node/proc/validate()
	var/dissolve_self = isnull(physical_node)
	var/list/datum/powernet_graph_node/previous_adjacent_nodes = adjacent_nodes.Copy()
	for (var/datum/powernet_graph_node/other_node as anything in adjacent_nodes)
		var/datum/powernet_graph_link/relevant_link = adjacent_nodes[other_node]
		var/delete_link = (dissolve_self || !other_node.physical_node) //if directly adjacent nodes, see if one of our cables is ded
		//no need to qdel the other node if it's gone in case of explosion cleanup, it'll be on the revalidate list too

		if (istype(relevant_link))
			if (delete_link || (relevant_link.expected_length > length(relevant_link.cables))) //link borked or one of the end points borked
				delete_link = TRUE
				relevant_link.dissolve()

		if (delete_link) //break list linking
			other_node.adjacent_nodes -= src
			adjacent_nodes -= other_node

	if (dissolve_self)
		qdel(src)
	else
		//TODO compare what's left of adjacent_nodes versus previous_adjacent_nodes after doing a network propagation ping
		//Tell the other nodes to split off into other powernets




//Stretches of cables with two connections. That is, the parts that aren't dead ends or
//For navigating the graph we don't need to bother with these, that's the point of abstracting into a graph.
//These are going to be a useful in figuring out what happened to a powernet post-explosion
/datum/powernet_graph_link
	//How many cables we had last time we checked
	var/expected_length = 0
	//How many cables currently claim to be part of this link
	var/list/obj/cable/cables = list()
	//Which two nodes are we connecting
	var/list/datum/powernet_graph_node/adjacent_nodes

	//links don't have a net number, we'll just grab the number of one of the nodes if needed (should be rare, like mostly people poking wires with multitools).
	//Less stuff to keep in line.

///
/datum/powernet_graph_link/proc/dissolve()
