#if defined(MAP_OVERRIDE_CONSTRUCTION)


#elif defined(MAP_OVERRIDE_DESTINY)


#elif defined(MAP_OVERRIDE_CLARION)


#elif defined(MAP_OVERRIDE_COGMAP)


#elif defined(MAP_OVERRIDE_COGMAP2)


#elif defined(MAP_OVERRIDE_DONUT2)


#elif defined(MAP_OVERRIDE_DONUT3)


#elif defined(MAP_OVERRIDE_MUSHROOM)


#elif defined(MAP_OVERRIDE_TRUNKMAP)


#elif defined(MAP_OVERRIDE_CHIRON)


#elif defined(MAP_OVERRIDE_PAMGOC)

#define REVERSED_MAP

#elif defined(MAP_OVERRIDE_OSHAN)

#define UNDERWATER_MAP 1
#define SCIENCE_PATHO_MAP 1

#elif defined(MAP_OVERRIDE_HORIZON)


#elif defined(MAP_OVERRIDE_ATLAS)

#elif defined(MAP_OVERRIDE_BOBMAP)

#elif defined(MAP_OVERRIDE_BOBMAPMINI)
#define NO_START_JOBGEAR_MAP

#elif defined(MAP_OVERRIDE_DOCKMAP)
#define NO_START_JOBGEAR_MAP
#define NO_DEPARTMENT_START_MAP

#elif defined(MAP_OVERRIDE_GEHENNA)
#define DESERT_MAP
#define Z3_IS_A_STATION_LEVEL //Allows AIs to work (mostly) across upper and lower level

#elif defined(MAP_OVERRIDE_CRAG)
#define DESERT_MAP
#define Z3_IS_A_STATION_LEVEL //Allows AIs to work (mostly) across upper and lower level

#elif defined(MAP_OVERRIDE_SUMMIT)
#define SNOW_MAP

#elif defined(MAP_OVERRIDE_CHUNK)

#elif defined(MAP_OVERRIDE_BAYOUBEND)

#elif defined(MAP_OVERRIDE_SPIRIT)


#elif defined(MAP_OVERRIDE_MANTA)

#define UNDERWATER_MAP 1
#define MOVING_SUB_MAP 1
#define SUBMARINE_MAP 1
#define SCIENCE_PATHO_MAP 1
#elif defined(SPACE_PREFAB_RUNTIME_CHECKING)
#define RUNTIME_CHECKING 1
#define PREFAB_CHECKING 1
#elif defined(UNDERWATER_PREFAB_RUNTIME_CHECKING)
#define UNDERWATER_MAP 1
#define RUNTIME_CHECKING 1
#define PREFAB_CHECKING 1
//Entry below is the "default" map
#else

//#define UNDERWATER_MAP 1

#endif
