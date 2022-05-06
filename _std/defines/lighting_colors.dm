//warc make clean
//this file just enumerates a bunch of hardcoded light types for mappers to use.
#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3

//these are the standard colors basically
#define ENUMERATE_BULBS(_supertypes, _fitting)\
/obj/machinery/light/_supertypes/cool;\
/obj/machinery/light/_supertypes/cool/name = "cool "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/cool/light_type = /obj/item/light/_fitting/cool;\
/obj/machinery/light/_supertypes/cool/very;\
/obj/machinery/light/_supertypes/cool/very/name = "very cool "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/cool/very/light_type = /obj/item/light/_fitting/cool/very;\
/obj/machinery/light/_supertypes/neutral;\
/obj/machinery/light/_supertypes/neutral/name = "neutral "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/neutral/light_type = /obj/item/light/_fitting/neutral;\
/obj/machinery/light/_supertypes/warm;\
/obj/machinery/light/_supertypes/warm/name = "warm "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/warm/light_type = /obj/item/light/_fitting/warm;\
/obj/machinery/light/_supertypes/warm/very;\
/obj/machinery/light/_supertypes/warm/very/name = "very warm "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/warm/very/light_type = /obj/item/light/_fitting/warm/very;\
/obj/machinery/light/_supertypes/harsh;\
/obj/machinery/light/_supertypes/harsh/name = "harsh "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/harsh/light_type = /obj/item/light/_fitting/harsh;\
/obj/machinery/light/_supertypes/harsh/very;\
/obj/machinery/light/_supertypes/harsh/very/name = "very harsh "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/harsh/very/light_type = /obj/item/light/_fitting/harsh/very;\
/obj/machinery/light/_supertypes/blueish;\
/obj/machinery/light/_supertypes/blueish/name = "blueish "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/blueish/light_type = /obj/item/light/_fitting/blueish;\
/obj/machinery/light/_supertypes/purpleish;\
/obj/machinery/light/_supertypes/purpleish/name = "purpleish "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/purpleish/light_type = /obj/item/light/_fitting/purpleish;\
/obj/machinery/light/_supertypes/greenish;\
/obj/machinery/light/_supertypes/greenish/name = "greenish "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/greenish/light_type = /obj/item/light/_fitting/greenish;\
/obj/machinery/light/_supertypes/red;\
/obj/machinery/light/_supertypes/red/name = "red "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/red/light_type = /obj/item/light/_fitting/red;\
/obj/machinery/light/_supertypes/yellow;\
/obj/machinery/light/_supertypes/yellow/name = "yellow "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/yellow/light_type = /obj/item/light/_fitting/yellow;\

/obj/machinery/light/fluorescent
ENUMERATE_BULBS(fluorescent, tube)

/obj/machinery/light/fluorescent/auto
ENUMERATE_BULBS(fluorescent/auto, tube)

/obj/machinery/light/fluorescent/ceiling
ENUMERATE_BULBS(fluorescent/ceiling, tube)

/obj/machinery/light/small
ENUMERATE_BULBS(small, bulb)

/obj/machinery/light/small/auto
ENUMERATE_BULBS(small/auto, bulb)

/obj/machinery/light/small/floor
ENUMERATE_BULBS(small/floor, bulb)

/obj/machinery/light/small/ceiling
ENUMERATE_BULBS(small/ceiling, bulb)

// orphan types
/obj/machinery/light/small/frostedred
	name = "frosted red fluorescent light fixture"
	light_type = /obj/item/light/bulb/emergency

/obj/machinery/light/small/broken //Made at first to replace a decal in cog1's wreckage area
	name = "shattered light bulb"
	New()
		..()
		current_lamp.light_status = LIGHT_BROKEN
