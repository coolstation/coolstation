//where did the contents of _setup.dm go? "gone, reduced to atom"

#define isatom(A) (isloc(A))

//temp_flags lol for atoms and im gonna be constantly adding and removing these
//this doesn't entirely make sense, cause some other flags are temporary too! ok im runnign otu OF FUCKING SPACE
#define SPACE_PUSHING 1 //used for removing us from mantapush list when we get deleted
#define MANTA_PUSHING 2	//used for removing us from spacepush list when we get beleted
#define HAS_PARTICLESYSTEM 4 			//atom has a particlesystem right now - used for clean gc to clear refs to itself etc blah
#define HAS_PARTICLESYSTEM_TARGET 8 	//atom is a particlesystem target - " "
#define HAS_BAD_SMOKE 16 				//atom has a bad smoke pointing to it right now - used for clean gc to clear refs to itself etc blah
#define IS_LIMB_ITEM 32 				//im a limb
#define HAS_KUDZU 64					//if a turf has kudzu.
#define HAS_NBGG 128					//if a turf has NBGG.
#define BEING_CRUSHERED 256				//if an atom/movable is in the crusher (so conveyors don't push it around)

//event_handler_flags
#define USE_PROXIMITY 1 	//Atom implements HasProximity() call in some way.
#define USE_FLUID_ENTER 2 	//Atom implements EnteredFluid() call in some way.
#define USE_GRAB_CHOKE 4	//Atom can be held as an item and have a grab inside it to choke somebuddy
#define HANDLE_STICKER 8	//Atom implements var/active = XXX and responds to sticker removal methods (burn-off + acetone). this atom MUST have an 'active' var. im sory.
#define USE_HASENTERED 16	//Atom implements HasEntered() call in some way.
#define USE_CHECKEXIT 32	//Atom implements CheckExit() call in some way.
#define USE_CANPASS 64		//Atom implements CanPass() call in some way. (doesnt affect turfs, put this on mobs or objs)
#define IMMUNE_MANTA_PUSH 128			//cannot be pushed by MANTAwaters
#define IMMUNE_SINGULARITY 256
#define IMMUNE_SINGULARITY_INACTIVE 512
#define IS_TRINKET 1024 		//used for trinkets GC
#define IS_FARTABLE 2048
#define NO_MOUSEDROP_QOL 4096 //overrides the click drag mousedrop pickup QOL kinda stuff
#define HASENTERED_MAT_PROP 8192 // if the USE_HASENTERED flag is a material property, so we know when to flush it.
#define IS_LOAF 16384 // its a loaf. used by the singularity.
#define IS_PITFALLING 32768 // its currently falling down an elevator, hole, etc
#define IN_COYOTE_TIME 65536 // its coyote timing OVER a pitfall - to be replaced by atom property
//TBD the rest

//THROW flags (what kind of throw, we can have ddifferent kinds of throws ok)
#define THROW_NORMAL 1
#define THROW_CHAIRFLIP 2
#define THROW_GUNIMPACT 4
#define THROW_SLIP 8
#define THROW_SANDWICH 16 //This is for one single item, because I'm pretty sure this would never have been clean.
#define THROW_KNOCKDOWN 32 //i know what i'm doing

//For serialization purposes
#define DESERIALIZE_ERROR 0
#define DESERIALIZE_OK 1
#define DESERIALIZE_NEED_POSTPROCESS 2
#define DESERIALIZE_NOT_IMPLEMENTED 4

///Old explosion integer severity brackets
///(cause I'd like to pipe the raw power value into ex_act without rewriting how a couple hundred objects react to explosions)
///I'm not expecting these to ever go away btw, it's useful to have some baseline for total/heavy/light devastation
#define OLD_EX_SEVERITY_1 6 to INFINITY
#define OLD_EX_SEVERITY_2 3 to 6 //note that these defines overlap on round numbers which is technically bad (it happens a lot though)
#define OLD_EX_SEVERITY_3 0 to 3 //but I believe that you can't put a "X up to but not including Y" type statement into a switch, so

//These go into places where ex_act was called with just the integer, so those evaluate back to the correct old bracket
#define OLD_EX_TOTAL 6.1 //decimals to avoid the overlap
#define OLD_EX_HEAVY 3.1
#define OLD_EX_LIGHT 1
