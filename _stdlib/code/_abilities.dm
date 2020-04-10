// macros for /datum/targetable's targeting_flags

#define TARGETS_MOBS (1<<1)
#define TARGETS_OBJS (1<<2)
#define TARGETS_TURFS (1<<3)
#define TARGETS_IN_INVENTORY (1<<4) // you probably also want TARGETS_OBJS on!
#define TARGETS_ABILITIES (1<<5) // note that this passes the BUTTON and not the ABILITY into cast! Extract the ability from the button yourself (button.owner)
#define TARGETS_GHOSTS (1<<6) // you probably also want TARGETS_MOBS on!

#define TARGETS_ATOMS (TARGETS_MOBS | TARGETS_OBJS | TARGETS_TURFS)
