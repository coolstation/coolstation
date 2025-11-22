// Largely used for handling auto turfs that update their appearance, but also something like the cloner and other multipart machines.
// to "connect" graphically to nearby walls and set up references

/*
	HOW TO USE:
	If you need to set something up and it requires knowing about other atoms (say neighbouring turfs on an autowall), which may not yet exist depending on map load order
	During a round this is no problem most of the time, folks are going to make walls and windows and whatever one at a time when any neighbours already exist
	But when making new sections of map (mineral magnet, prefabs), we can add to a waiting list worldgen_candidates so that that logic happens after loading or generation has finished
	Let's have fewer SPAWN_DBGs if we can help it thnx

	Basically:

/atom/coolthing/New()
	..()
	if (worldgen_hold)
		worldgen_candidates[worldgen_generation] += src
	else
		[call a proc]

/atom/coolthing/generate_worldgen()
	[call a proc]

*/




// Turfs add themselves to this in their New()
/var/global/list/list/worldgen_candidates = list(list(),list(),list(),list(),list()) //5 levels is probably plenty


// If your whatever needs to wait on adjacent atoms to have finished spawning so it can configure itself properly, use this instead of SPAWN_DBG when possible pls
/// TRUE when maps, including prefabs, are loaded or significant amounts of terrain are being generated.
/var/global/worldgen_hold = TRUE
var/global/worldgen_generation = 1

/proc/initialize_worldgen()
	/*for(var/atom/U in worldgen_candidates)
		if (U) //may be deleted lol
			U.generate_worldgen()
			LAGCHECK(LAG_REALTIME)
	worldgen_candidates = list()
	worldgen_hold = FALSE*/

	while (length(worldgen_candidates) >= worldgen_generation)
		//objects with complicated setups can subscribe multiple generations in advance
		//but we advance the generation early so that when U spawns something that itself goes on the backlog, say a wingrille spawner spawning windows and a grille
		//the windows/grille will end up subscribing to the *next* generation automatically without them having to be told they're spawned in the middle of the whole process
		worldgen_generation++
		for(var/atom/U in worldgen_candidates[worldgen_generation - 1]) //it does look a bit silly though
			if (U) //may be deleted lol
				U.generate_worldgen()
				LAGCHECK(LAG_REALTIME)

	worldgen_hold = FALSE
	worldgen_candidates = list(list(),list(),list(),list(),list())
	worldgen_generation = 1
