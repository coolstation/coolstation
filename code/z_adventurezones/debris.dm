////Martian Turf stuff//////////////
/turf/floor/setpieces/martian
	name = "organic floor"
	icon = 'icons/turf/martian.dmi'
	icon_state = "floor1"
	thermal_conductivity = 0.05
	heat_capacity = 0

//2023-9-17 - IDK what's up with this it's never been pathed correctly
/*
/turf/floor/martian/attackby(obj/item/C as obj, mob/user as mob, params)
	if (istype(C, /obj/item/martianSeed))
		var/obj/item/martianSeed/S = C
		if(S)
			S.plant(src)
			logTheThing("station", user, null, "plants a martian biotech seed (<b>Structure:</b> [S.spawn_path]) at [log_loc(src)].")
			return
	else
		..()*/

/turf/wall/setpieces/martian
	name = "organic wall"
	icon = 'icons/turf/martian.dmi'
	icon_state = "wall1"
	opacity = 1
	density = 1
	gas_impermeable = 1
	thermal_conductivity = 0.05
	heat_capacity = 0

	health = 40

	proc/checkhealth()
		if(src.health <= 0)
			SPAWN_DBG(0)
				gib(src.loc)
				ReplaceWithSpace()

/turf/wall/setpieces/martian/ex_act(severity)
	switch(severity)
		if(OLD_EX_SEVERITY_1)
			src.health -= 40
			checkhealth()
		if(OLD_EX_SEVERITY_2)
			src.health -= 20
			checkhealth()
		if(OLD_EX_SEVERITY_3)
			src.health -= 5
			checkhealth()

/turf/wall/setpieces/martian/proc/gib(atom/location)
	if (!location) return

	var/obj/decal/cleanable/machine_debris/gib = null
	var/obj/decal/cleanable/tracked_reagents/blood/gibs/gib2 = null

	// NORTH
	gib = make_cleanable( /obj/decal/cleanable/machine_debris,location)
	if (prob(25))
		gib.icon_state = "gibup1"
	gib.streak_cleanable(NORTH)
	LAGCHECK(LAG_LOW)

	// SOUTH
	gib2 = make_cleanable( /obj/decal/cleanable/tracked_reagents/blood/gibs,location)
	if (prob(25))
		gib2.icon_state = "gibdown1"
	gib2.streak_cleanable(SOUTH)
	LAGCHECK(LAG_LOW)

	// RANDOM
	gib2 = make_cleanable( /obj/decal/cleanable/tracked_reagents/blood/gibs,location)
	gib2.streak_cleanable(cardinal)
