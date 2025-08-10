//warc make clean
//this file just enumerates a bunch of hardcoded light types for mappers to use.
#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3

//these are the standard colors basically
#define ENUMERATE_FIXTURES(_supertypes, _fitting)\
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
/obj/machinery/light/_supertypes/cyan;\
/obj/machinery/light/_supertypes/cyan/name = "cyan "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/cyan/light_type = /obj/item/light/_fitting/cyan;\
/obj/machinery/light/_supertypes/blue;\
/obj/machinery/light/_supertypes/blue/name = "blue "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/blue/light_type = /obj/item/light/_fitting/blue;\
/obj/machinery/light/_supertypes/blueish;\
/obj/machinery/light/_supertypes/blueish/name = "blueish "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/blueish/light_type = /obj/item/light/_fitting/blueish;\
/obj/machinery/light/_supertypes/purple;\
/obj/machinery/light/_supertypes/purple/name = "purple "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/purple/light_type = /obj/item/light/_fitting/purple;\
/obj/machinery/light/_supertypes/purpleish;\
/obj/machinery/light/_supertypes/purpleish/name = "purpleish "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/purpleish/light_type = /obj/item/light/_fitting/purpleish;\
/obj/machinery/light/_supertypes/green;\
/obj/machinery/light/_supertypes/green/name = "green "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/green/light_type = /obj/item/light/_fitting/green;\
/obj/machinery/light/_supertypes/greenish;\
/obj/machinery/light/_supertypes/greenish/name = "greenish "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/greenish/light_type = /obj/item/light/_fitting/greenish;\
/obj/machinery/light/_supertypes/red;\
/obj/machinery/light/_supertypes/red/name = "red "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/red/light_type = /obj/item/light/_fitting/red;\
/obj/machinery/light/_supertypes/reddish;\
/obj/machinery/light/_supertypes/reddish/name = "reddish "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/reddish/light_type = /obj/item/light/_fitting/reddish;\
/obj/machinery/light/_supertypes/yellow;\
/obj/machinery/light/_supertypes/yellow/name = "yellow "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/yellow/light_type = /obj/item/light/_fitting/yellow;\
/obj/machinery/light/_supertypes/yellowish;\
/obj/machinery/light/_supertypes/yellowish/name = "yellowish "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/yellowish/light_type = /obj/item/light/_fitting/yellowish;\
/obj/machinery/light/_supertypes/blacklight;\
/obj/machinery/light/_supertypes/blacklight/name = "blacklight "+#_fitting+" light fixture";\
/obj/machinery/light/_supertypes/blacklight/light_type = /obj/item/light/_fitting/blacklight;\

/obj/machinery/light/fluorescent
	has_glow = TRUE
ENUMERATE_FIXTURES(fluorescent, tube)

/obj/machinery/light/fluorescent/auto
ENUMERATE_FIXTURES(fluorescent/auto, tube)

/obj/machinery/light/fluorescent/ceiling
ENUMERATE_FIXTURES(fluorescent/ceiling, tube)

/obj/machinery/light/small
	has_glow = TRUE
ENUMERATE_FIXTURES(small, bulb)

/obj/machinery/light/small/auto
ENUMERATE_FIXTURES(small/auto, bulb)

/obj/machinery/light/small/floor
ENUMERATE_FIXTURES(small/floor, bulb)

/obj/machinery/light/small/ceiling
ENUMERATE_FIXTURES(small/ceiling, bulb)

/obj/machinery/light/small/ceiling/bare
ENUMERATE_FIXTURES(small/ceiling, bulb)

// orphan types
/obj/machinery/light/small/frostedred
	name = "frosted red fluorescent light fixture"
	light_type = /obj/item/light/bulb/emergency

#undef ENUMERATE_FIXTURES

