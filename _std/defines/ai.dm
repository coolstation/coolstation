//I think this is for mob AI
#define AI_PASSIVE 0
#define AI_ANGERING 1
#define AI_ATTACKING 2
#define AI_HELPING 3
#define AI_IDLE 4
#define AI_FLEEING 5

//This is for silicon player AI, but I figure they can share a file

//AI governor registry strings. The strings do double duty in the PDA governor manifest, which is why they're human readable
#define AI_GOVERNOR_AIRLOCKS "Airlock control"
#define AI_GOVERNOR_APCS "APC control"
#define AI_GOVERNOR_TRACKING "Camera tracking"
#define AI_GOVERNOR_KILLSWITCH "Killswitch control"
#define AI_GOVERNOR_VIEWPORTS "Viewport control"
#define AI_GOVERNOR_GENRADIO "General radio"
#define AI_GOVERNOR_CORERADIO "Core radio"
#define AI_GOVERNOR_DEPRADIO "Departmental radio"

//I know we're in the defines section but one macro can't hurt right?
#define ACTION_GOVERNOR_BLOCKED(action) ((action in governor_registry) && islist(governor_registry[action]) && !length(governor_registry[action]))
