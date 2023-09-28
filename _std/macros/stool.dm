/// Returns true if the given x is an item.

/* ---------------- Stools/Seats/Beds Macros For obj/stool.dm --------------- */
//okay yeah i cheated here with the name but whatever
#define isseat(x) istype(x, /obj/stool)

#define canstool(x,y) (isseat(x), && (x:capability_flags & (y)))
#define isstool(x,y) (isseat(x), && (x:stool_flags & (y)))

//capability
#define canstoolsit(x) (canstool(x, SEAT_SIT))
#define canstoolbuckle(x) (canstool(x, SEAT_BUCKLE))
#define canstoolstand(x) (canstool(x, SEAT_STAND))
#define canstoolsecure(x) (canstool(x, SEAT_SECURE))

//status
#define isstoolsat(x) (isstool(x, SEAT_SIT))
#define isstoolbuckled(x) (isstool(x, SEAT_BUCKLE))
#define isstoolstood(x) (isstool(x, SEAT_STAND))
#define isstoolsecured(x) (isstool(x, SEAT_SECURE))

//action
#define sitstool(x) x.stool_flags |= (SEAT_SIT)
#define bucklestool(x) x.stool_flags |= (SEAT_BUCKLE)
#define standstool(x) x.stool_flags |= (SEAT_STAND)
#define securestool(x) x.stool_flags |= (SEAT_SECURE)

//unaction
#define unsitstool(x) x.stool_flags &= ~(SEAT_SIT)
#define unbucklestool(x) x.stool_flags &= ~(SEAT_BUCKLE)
#define unstandstool(x) x.stool_flags &= ~(SEAT_STAND)
#define unsecurestool(x) x.stool_flags &= ~(SEAT_SECURE)
