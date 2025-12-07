#define STAT_ALIVE 0
#define STAT_UNCONSCIOUS 1
#define STAT_DEAD 2

// because fuck remembering what stat means every single time
#define isalive(x) (ismob(x) && x.stat == STAT_ALIVE)
#define isunconscious(x) (ismob(x) && x.stat == STAT_UNCONSCIOUS)
#define isdead(x) (ismob(x) && x.stat == STAT_DEAD)
#define setalive(x) if (ismob(x)) x.stat = STAT_ALIVE
#define setunconscious(x) if (ismob(x)) x.stat = STAT_UNCONSCIOUS
#define setdead(x) if (ismob(x)) x.stat = STAT_DEAD

#define ismuzzled(x) (x.wear_mask && x.wear_mask.is_muzzle)

// status effect system stuff
#define ADD_STATUS_LIMIT(target, group, value)\
	do { \
		if (length(target.statusLimits)) { \
			target.statusLimits[group] = value; \
		} else { \
			target.statusLimits = list(group = value);\
		} \
	} while (0)

#define REMOVE_STATUS_LIMIT(target, group)\
	do { \
		target.statusLimits -= group;\
	} while (0)
