/// Returns true if the given x is an item.

/* ---------------- Stools/Seats/Beds Macros For obj/stool.dm --------------- */
//okay yeah i cheated here with the name but whatever
#define isseat(x) istype(x, /obj/stool)

#define canstool(x,y) (isseat(x), && (x:cando_flags & (y)))
#define isstool(x,y) (isseat(x), && (x:stool_flags & (y)))

//capability
#define canstoolsit(x) (canstool(x, STOOL_SIT))
#define canstoolbuckle(x) (canstool(x, STOOL_BUCKLE))
#define canstoolstand(x) (canstool(x, STOOL_STAND))
#define canstoolsecure(x) (canstool(x, STOOL_SECURE))

//status
#define isstoolsat(x) (isstool(x, STOOL_SIT))
#define isstoolbuckled(x) (isstool(x, STOOL_BUCKLE))
#define isstoolstood(x) (isstool(x, STOOL_STAND))
#define isstoolsecured(x) (isstool(x, STOOL_SECURE))

//action
#define sitstool(x) x.stool_flags |= (STOOL_SIT)
#define bucklestool(x) x.stool_flags |= (STOOL_BUCKLE)
#define standstool(x) x.stool_flags |= (STOOL_STAND)
#define securestool(x) x.stool_flags |= (STOOL_SECURE)

//unaction
#define unsitstool(x) x.stool_flags &= ~(STOOL_SIT)
#define unbucklestool(x) x.stool_flags &= ~(STOOL_BUCKLE)
#define unstandstool(x) x.stool_flags &= ~(STOOL_STAND)
#define unsecurestool(x) x.stool_flags &= ~(STOOL_SECURE)
