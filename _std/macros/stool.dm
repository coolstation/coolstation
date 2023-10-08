/// Returns true if the given x is an item.

/* ---------------- Stools/Seats/Beds Macros For obj/stool.dm --------------- */
//okay yeah i cheated here with the name but whatever
#define isseat(x) istype(x, /obj/stool)

//capability (stools only)
#define canstool(x,y) (isseat(x) && (x:cando_flags & (y)))

#define cansit(x) (canstool(x, STOOL_SIT))
#define canbuckle(x) (canstool(x, STOOL_BUCKLE))
#define canstand(x) (canstool(x, STOOL_STAND))
#define cansecure(x) (canstool(x, STOOL_SECURE))

//status (stools AND mobs)
#define isstool(x,y) ((isseat(x) || ismob(x)) && (x:stool_flags & (y)))

#define issit(x) (isstool(x, STOOL_SIT))
#define isbuckle(x) (isstool(x, STOOL_BUCKLE))
#define isstand(x) (isstool(x, STOOL_STAND))
#define issecure(x) (isstool(x, STOOL_SECURE))

//action
#define setsit(x) x.stool_flags |= (STOOL_SIT)
#define setbuckle(x) x.stool_flags |= (STOOL_BUCKLE)
#define setstand(x) x.stool_flags |= (STOOL_STAND)
#define setsecure(x) x.stool_flags |= (STOOL_SECURE)
#define settuck(x) x.stool_flags |= (STOOL_SECURE)

//unaction
#define setunsit(x) x.stool_flags &= ~(STOOL_SIT)
#define setunbuckle(x) x.stool_flags &= ~(STOOL_BUCKLE)
#define setunstand(x) x.stool_flags &= ~(STOOL_STAND)
#define setunsecure(x) x.stool_flags &= ~(STOOL_SECURE)
#define setuntuck(x) x.stool_flags |= (STOOL_SECURE)
