#define DEBUG
/*
  ANY CHANGES HERE WILL BE OVERWRITTEN BY THE SERVER BUILD PROCESS.
  THAT BEING SAID, THIS IS THE IDEAL PLACE TO FORCE A CERTAIN MAP/FLAGS FOR LOCAL DEVELOPMENT.
  ALSO HERE'S A BEE

                .-..-.``        ```````
  .........`   s-`../-...`  `...........`
o+`        `-` ``..-:yooos-..----------..`
             .-`osyyyhssyh:.............-
            `+hh+/::::s::::::/oyysssys-`
          .sh+:o/:::::s:::::::::+yNNNNNs.
         od+:::++:::::s:::::::::::/yNNNmdy`
       .ds::::::+:::::/:::::::::::::/dNNNhd-
      `d+////::::::::::://///::::::::/hNNNym.
      ddmNNNNmy/::::::/ymNNNNds/::::::/dNNNsd`
     :MNNNNNNNNm+::::+mNNNNNNNNd/::::::oNNNydyooyy
     yNNNs::sNNNy::::dNNh/:/mNNN+:::::::mNNdsMNNd-
     dNNd....dNN+::::+NN:...oNNd/:::::::mNNNoNs:
     yyymdoodNd+::::::+hmyoyNNh/::::::::mNNdsh
     /m://ooo/::::::::::/+oo+/:::::::::/NNNhd/
      ds::::::::++:::/++:::::::::::::::sNNNhm`
      .m+::::::::+++++/:::::::::::::::/NNNNm-
       .do:::::::::::::::::::::::::::/mNNNN:
        `yh+::::::::::::::::::::::::/mNMMyd-
          .ydo/::::::::::::::::::::oNNmds :d
           .N:+yhyso//::::::://+osyyN- /h  N`
           .N   y:-:++osssssso++:`  M` :s
           `d.                     .d`
*/

//////////// OPTIONS TO GO FAST

//#define IM_REALLY_IN_A_FUCKING_HURRY_HERE 1  		// Skip setup for atmos, Z5, don't show changelogs, skip pregame lobby
//#define GOTTA_GO_FAST_BUT_ZLEVELS_TOO_SLOW 1		// Only include the map Atlas, no other zlevels. Boots way faster
#define Z_LOG_ENABLE 1  							// Enable additional world.log logging


//////////// PROFILING OPTIONS

//#define TRACY_PROFILER_HOOK 					// Enables the hook for the DM Tracy profiler in world/init()

//#define SERVER_SIDE_PROFILING_FULL_ROUND 1  	// Generate and save profiler data for the entire round
//#define SERVER_SIDE_PROFILING_PREGAME 1 		// Generate and save profiler data for pregame work (before "Welcome to pregame lobby")
//#define SERVER_SIDE_PROFILING_INGAME_ONLY 1 	// Generate and save profiler data for post-pregame work


//////////// DEBUGGING TOGGLES

//#define IM_TESTING_FUCKING_BASIC_MOB_FUNCTIONALITY 1	//force prevent mob spawner landmarks, so you can test movement or damage or whatever without the GODCOCKING MONKEYS TRIPPING YOUR BREAKPOINTS EVERY 2 MILLISECONDS GOD DAMN

// Delete queue debug toggle
// This is expensive. don't turn it on on the server unless you want things to be bad and slow
//#define DELETE_QUEUE_DEBUG

// Update queue debug toggle
// Probably don't turn it on on a real server but also I have no idea what an update queue is vOv
//#define UPDATE_QUEUE_DEBUG

// Image deletion debug
// DO NOT ENABLE THIS ON THE SERVER FOR FUCKS SAKE
//#define IMAGE_DEL_DEBUG

// Machine processing debug
// Apparently not that hefty but still
//#define MACHINE_PROCESSING_DEBUG

// Queue worker statistics
// Probably hefty
//#define QUEUE_STAT_DEBUG

// Makes the code crash / log when an abstract type is instantiated.
// see _stadlib/_types.dm for details
// #define ABSTRACT_VIOLATION_CRASH
// #define ABSTRACT_VIOLATION_WARN

// Makes the delete queue go through every single datum in the game when a hard del happens
// It gets reported to the debug log. This process takes about 4 minutes per hard deletion
// (during that time the server will be frozen).
//#define LOG_HARD_DELETE_REFERENCES
//#define LOG_HARD_DELETE_REFERENCES_2_ELECTRIC_BOOGALOO
// The same thing but powered by extools. Better, harder, faster, stronger.
// You'll need an extools version that has the right stuff in it to make this work.
//#define REFERENCE_TRACKING
//#define AUTO_REFERENCE_TRACKING_ON_HARD_DEL

// Toggle this to turn .dispose() into qdel( ). Useful for trying to find lingering references locally.
//#define DISPOSE_IS_QDEL

//////////// MAP OVERRIDES

//---------------------- Maps that are being maintained ------------------------------//
//#define MAP_OVERRIDE_BAYOUBEND 		//DO NOT RUN THIS RIGHT NOW!!! low to midpop scrapping map by Klushy225
//#define MAP_OVERRIDE_BOBMAP 			//"to be renamed" map by ReginaldHJ
#define MAP_OVERRIDE_CHUNK				// Warcrimes tiny map (not Atlas levels of tiny, but usable tiny)
//#define MAP_OVERRIDE_DONUT2 			// Un-Updated Donut2
//#define MAP_OVERRIDE_COGMAP 			// Cogmap
//#define MAP_OVERRIDE_GEHENNA			// Warcrimes WIP do use
//#define MAP_OVERRIDE_CRAG						// secret >:)
//#define MAP_OVERRIDE_CLARION			// Destiny/Alt RP
//---------------------- Maps that exist but maybe not up to date --------------------//
//#define MAP_OVERRIDE_CONSTRUCTION	// Construction mode
//#define MAP_OVERRIDE_DESTINY			// Destiny/RP
//#define MAP_OVERRIDE_COGMAP2			// Cogmap 2
//#define MAP_OVERRIDE_DONUT3 			// Donut3 by Ryumi
//#define MAP_OVERRIDE_MUSHROOM			// Updated Mushroom
//#define MAP_OVERRIDE_TRUNKMAP			// Updated Ovary
//#define MAP_OVERRIDE_CHIRON 			// Chiron by Kusibu
//#define MAP_OVERRIDE_OSHAN  			// Oshan
//#define MAP_OVERRIDE_HORIZON			// Horizon by Warcrimes do not use
//#define MAP_OVERRIDE_SPIRIT 			// Hastily Repurposed Shopping Mall - Tamber
//#define MAP_OVERRIDE_ATLAS  			// gannetmap
//#define MAP_OVERRIDE_DENSITY			// Urs' tiny map to troll players (we still have it I guess)
//#define MAP_OVERRIDE_KONDARU
//#define MAP_OVERRIDE_OZYMANDIAS
//#define MAP_OVERRIDE_FLEET
//#define MAP_OVERRIDE_ICARUS
//#define MAP_OVERRIDE_PAMGOC 			// Pamgoc
//#define MAP_OVERRIDE_WRESTLEMAP  	// Wrestlemap by Overtone
//#define MAP_OVERRIDE_POD_WARS   	// 500x500 Pod Wars map

//////////// GAMEMODE OVERRIDES (intended for ease of debug only. disables saving/loading the mode config therefore probably fucky on live server)

//#define MODE_OVERRIDE_EXTENDED			//No antagonists.
//#define MODE_OVERRIDE_ENVIRONMENTAL //No antagonists, but with more random shit happening
//#define MODE_OVERRIDE_TRAITOR			//Folks with uplinks, chance for a wraith.
//#define MODE_OVERRIDE_MIXED_ACTION		//A combination of most antags can appear.
//#define MODE_OVERRIDE_MIXED_MILD 		//Mixed, minus werewolf/wizard/blob.
//#define MODE_OVERRIDE_VAMPIRE			//Draculas suck blood and cause mischief.
//#define MODE_OVERRIDE_CHANGELING 		//Changelings suck everything and cause mischief.
//#define MODE_OVERRIDE_SPY_THEFT  		//Absconsion of company property, hijinks ensue.
//#define MODE_OVERRIDE_WIZARD 			//Pointy hatted pricks ruin everyone's day.
//#define MODE_OVERRIDE_NUCLEAR			//FOSS strike team planting a nuke on station.
//#define MODE_OVERRIDE_REVOLUTION 		//(Up to) 3 rev leaders teach crew the meaning of ACAB.
//#define MODE_OVERRIDE_REVOLUTION_EX  	//Revs but the round doesn't end early, I didn't know we had this.
//#define MODE_OVERRIDE_BLOB				//2-3 blobs versus the station.
//#define MODE_OVERRIDE_GANG				//Several gangs vie for the highest score by doing crimes. In theory, anyway.
//#define MODE_OVERRIDE_CONSPIRACY		//A group of crewmembers enact a sinister plot. More heavily role-play oriented than most modes.
//#define MODE_OVERRIDE_DISASTER			//The crew fights off an onslaught of scary until help arrives.
//#define MODE_OVERRIDE_DISASTER_DERELICT			//Solarium flavour disaster
//#define MODE_OVERRIDE_FOOTBALL			//20-30 minutes of admins dicking around while the crew is made to play american football.
//#define MODE_OVERRIDE_BATTLE_ROYALE	//Players scour the station for weaponry and murder each other - last man standing. A joke mode.

//everything below this point is unmaintained at best and has probably been severely broken for years

//#define MODE_OVERRIDE_SPY				//Spies murder each other with the help of crewmembers.
//#define MODE_OVERRIDE_FLOCK			//Teal technobirds convert the station into more teal technobirds
//#define MODE_OVERRIDE_CONSTRUCTION		//A 12,5 *hour* round in which players build a station from scratch
//#define MODE_OVERRIDE_ASS_DAY			//Every single crewmember gets antagonist status

//////////// Unit Test Framework

//#define UNIT_TESTS

//////////// HOLIDAYS AND OTHER SUCH TOGGLES

//#define RP_MODE
//#define HALLOWEEN 1
//#define XMAS 1
//#define CANADADAY 1
//#define FOOTBALL_MODE 1

//#define ASS_JAM_ENABLED 1 // Don't re-enable this. -warc


var/global/vcs_revision = "1"
var/global/vcs_author = "bob"

var/global/ci_dm_version_major = "1"
var/global/ci_dm_version_minor = "100"

// The following describe when the server was compiled
#define BUILD_TIME_TIMEZONE_ALPHA "EST" // Server is EST
#define BUILD_TIME_TIMEZONE_OFFSET -0500
#define BUILD_TIME_FULL "2009-02-13 18:31:30"
#define BUILD_TIME_YEAR 2053
#define BUILD_TIME_MONTH 12
#define BUILD_TIME_DAY 24 //SET ME TO 13 TO TEST YOUR ASS_JAM CONTENT!!
#define BUILD_TIME_HOUR 18
#define BUILD_TIME_MINUTE 31
#define BUILD_TIME_SECOND 30
#define BUILD_TIME_UNIX 1234567890 // Unix epoch, second precision

// Uncomment and set to a URL with a zip of the RSC to offload RSC sending to an external webserver/CDN.
#define PRELOAD_RSC_URL "https://cdn.coolstation.space/coolstation.rsc.zip"
