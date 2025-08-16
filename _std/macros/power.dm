///Validates all pnet graph nodes marked as dirty, then gets all (potentially) affected power machines to re-find their powernet
#define CLEAR_PNET_BACKLOG_NOW for(var/datum/powernet_graph_node/node as anything in dirty_pnet_nodes) {node.validate()};
//#define CLEAR_PNET_BACKLOG_NOW for(var/datum/powernet_graph_node/node as anything in dirty_pnet_nodes) {node.validate()}; for(var/obj/machinery/power/thing as anything in dirty_power_machines) {thing.generate_worldgen()};
