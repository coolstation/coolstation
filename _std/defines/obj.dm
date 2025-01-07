
// ---- object_flags ----

/// bot considers this solid object that can be opened with a Bump() in pathfinding DirBlockedWithAccess
#define BOTS_DIRBLOCK 			 (1<<0)
/// illegal for arm attaching
#define NO_ARM_ATTACH 			 (1<<1)
/// access gun can reprog
#define CAN_REPROGRAM_ACCESS (1<<2)
/// this object only blocks things in certain directions, e.g. railings, thindows
#define HAS_DIRECTIONAL_BLOCKING (1<<3)
/// this is part of the roundstart station cloner (yes it's kind of a waste to have this on the global objects flags, but look how much space there is)
#define ROUNDSTART_CLONER_PART (1<<4)
/// object is spawned as part of the Special Delivery event, so if cargo tries to sell it NT will be angry
#define SPECIAL_PENALTY_ON_SALE (1<<5)

/// At which alpha do opague objects become see-through?
#define MATERIAL_ALPHA_OPACITY 190
