// bitflags for different singing modifiers, used so that effects can be combined if desired
#define NORMAL_SINGING 1
#define LOUD_SINGING 2
#define SOFT_SINGING 4
#define BAD_SINGING 8


//THE BELOW IS UNUSED ATM

//What if we just put all the prefixes in
#define PREFIX_SILICON "s"
#define PREFIX_INNER "i"//shared between changeling hivemind and dracula-thrall comms
#define PREFIX_WHISPER "w" //commented out atm
#define PREFIX_RIGHT_HAND "rh"
#define PREFIX_LEFT_HAND "lh"
#define PREFIX_INTERCOM "in"
#define PREFIX_AI_GEN "1"
#define PREFIX_AI_CORE "2"
#define PREFIX_AI_SEC "3"

#define PREFIX_COMMAND "h" //heads
#define PREFIX_SECURITY "g" //gecurity??
#define PREFIX_ENGINEERING "e"
#define PREFIX_RESEARCH "r"
#define PREFIX_MEDICAL "m"
#define PREFIX_CIVILIAN "c"
#define PREFIX_SYNDICATE "z"
#define PREFIX_MULTI "q"

#define PREFIX_GANG "g" //overlaps with security

/*var/list/prefix_to_frequency = (\
	PREFIX_COMMAND = R_FREQ_COMMAND,\
	PREFIX_SECURITY = R_FREQ_SECURITY,\
	PREFIX_ENGINEERING = R_FREQ_ENGINEERING,\
	PREFIX_RESEARCH = R_FREQ_RESEARCH,\
	PREFIX_MEDICAL = R_FREQ_MEDICAL,\
	PREFIX_CIVILIAN = R_FREQ_CIVILIAN,\
	PREFIX_SYNDICATE = R_FREQ_SYNDICATE,\
	PREFIX_MULTI = R_FREQ_MULTI)*/
