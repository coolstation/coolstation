#define COMBAT_BLOCK_DELAY (2)
#define COMBAT_CLICK_DELAY 10

//attack message flags
#define SUPPRESS_BASE_MESSAGE (1<<0)
#define SUPPRESS_SOUND (1<<1)
#define SUPPRESS_VISIBLE_MESSAGES (1<<2)
#define SUPPRESS_SHOWN_MESSAGES (1<<3)
#define SUPPRESS_LOGS (1<<4)

// used by limbs which make a special kind of melee attack happen
#define SUPPRESS_MELEE_LIMB 15

#define GRAB_PASSIVE 0
#define GRAB_AGGRESSIVE 1
#define GRAB_NECK 2
#define GRAB_KILL 3
#define GRAB_PIN 4

// Ranged weapon melee damage values

#define MELEE_DMG_PISTOL 6
#define MELEE_DMG_REVOLVER 8
#define MELEE_DMG_SMG 8
#define MELEE_DMG_RIFLE 12
#define MELEE_DMG_LARGE 15
