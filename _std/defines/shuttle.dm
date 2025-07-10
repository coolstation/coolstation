// where you at, dawg, where you where you at, shuttle_controller.dm
#define SHUTTLE_LOC_CENTCOM 0
#define SHUTTLE_LOC_STATION 1
#define SHUTTLE_LOC_TRANSIT 1.5
#define SHUTTLE_LOC_RETURNED 2

/// If true, the shuttle spends time in transit. If false, it instantly teleports.
#define SHUTTLE_TRANSIT 1

/// Time the shuttle takes to get to SS13
#define SHUTTLEARRIVETIME (6 MINUTES / (1 SECOND))
/// Time the shuttle takes to leave SS13
#define SHUTTLELEAVETIME (2 MINUTES / (1 SECOND))
/// Time the shuttle spends in transit away from SS13
#define SHUTTLETRANSITTIME (2.5 MINUTES / (1 SECOND))

// you might be asking "why in seconds?" the answer is that shuttle code uses seconds as a base unit and I'm too tired to refactor it

/// Time it takes the arrivals shuttle to dock with SS13
#define DYNAMIC_ARRIVAL_SHUTTLE_TIME 2 MINUTES

//IDK why the naming on these sucks so bad
#define SHUTTLE_SOUTH    "cogmap"
#define SHUTTLE_EAST  	 "cogmap2"
#define SHUTTLE_WEST   	 "donut2"
#define SHUTTLE_DONUT3   "donut3"
#define SHUTTLE_OSHAN    "oshan"
#define SHUTTLE_NORTH    "destiny"
#define SHUTTLE_NODEF    "nodef"
