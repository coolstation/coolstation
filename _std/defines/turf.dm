//todo : port some more shit over to turf flags
/// simulated floor slippage
#define MOB_SLIP (1<<0)
/// simulated floor steppage
#define MOB_STEP (1<<1)
/// lol idk this kind of sucks, but i guess i can avoid some type checks in atmos processing
#define IS_TYPE_SIMULATED (1<<2)
/// can atmos use this tile as a space sample?
#define CAN_BE_SPACE_SAMPLE (1<<3)
/// fluid move gear suffers no penalty on these turfs
#define FLUID_MOVE (1<<4)
/// space move gear suffers no penalty on these turfs
#define SPACE_MOVE (1<<5)

//N.B. these flags currently have precedence over area checks on the mining maps. By default, turfs are coloured "other" on the maps (unless in a station area)
/// turf is coloured solid on the mining map
#define MINE_MAP_PRESENTS_SOLID (1<<7)
/// turf is coloured tough on the mining map
#define MINE_MAP_PRESENTS_TOUGH (1<<8)
/// turf is coloured empty on the mining map
#define MINE_MAP_PRESENTS_EMPTY (1<<9)
