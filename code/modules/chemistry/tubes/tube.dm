// TUBES are a reagent transport system.

#define STANDARD_TUBE_DIAMETER 0.1 // meters
#define STANDARD_TUBE_LENGTH 1
#define FLUID_UNITS_PER_CUBIC_METER 100000
#define STANDARD_TUBE_CAPACITY 3.1416 * ((STANDARD_TUBE_DIAMETER / 2) ** 2) * STANDARD_TUBE_LENGTH * FLUID_UNITS_PER_CUBIC_METER

ABSTRACT_TYPE(/obj/reagent_tubing)
/obj/reagent_tubing
	name = "abstract reagent tubing thingy"
	desc = "do not use me! i shouldnt exist!!!! grrr!!!!!!!"
	layer = PIPE_LAYER

ABSTRACT_TYPE(/obj/reagent_tubing/node)
/obj/reagent_tubing/node
	name = "abstract reagent tubing node"
	var/datum/reagents/reagent_bucket
	var/max_storage = 1000
	var/reagent_tubing/next_node
	var/next_tube_length = 0

	New()
		..()
		reagent_bucket = new(max_storage)
		reagent_bucket.my_atom = src

	proc/process(var/mult = 1)


	proc/locate_next_node()



ABSTRACT_TYPE(/obj/reagent_tubing/tube)
/obj/reagent_tubing/tube
	name = "tube"
	desc = "A reinforced section of tubing designed for the transport of potentially reactive chemicals."
	var/dir1
	var/dir2
	var/obj/reagent_tubing/node/input_node
	var/hydraulic_diameter = STANDARD_TUBE_DIAMETER
	var/capacity = STANDARD_TUBE_CAPACITY

/obj/reagent_tubing/tube/northsouth
	dir1 = NORTH
	dir2 = SOUTH

/obj/reagent_tubing/tube/northeast
	dir1 = NORTH
	dir2 = EAST

/obj/reagent_tubing/tube/northwest
	dir1 = NORTH
	dir2 = WEST

/obj/reagent_tubing/tube/southeast
	dir1 = SOUTH
	dir2 = EAST

/obj/reagent_tubing/tube/southwest
	dir1 = SOUTH
	dir2 = WEST

/obj/reagent_tubing/tube/eastwest
	dir1 = EAST
	dir2 = WEST
