/**
Centcom / Earth Stuff
Contents:
	Areas:
		Main Area
		Outside
		Offices
		Lobby
		Lounge
		Garden
		Power Supply

	Turfs: Outside Concrete & Grass
**/

var/global/Z4_ACTIVE = 0 //Used for mob processing purposes

//earth centcom (for score purposes)
/area/centcom/earth
	is_centcom = 0 //it's centcom, but not our centcom

/area/centcom/earth/outside
	name = "Earth"
	icon_state = "nothing_earth"
	//force_fullbright = 1

// HIGHLY SCIENTIFIC NUMBERS PULLED OUT OF MY ASS
// Loosely based on color temperatures during daylight hours
// and random bullshit for night hours
// would love to have this at runtime but
// i do not think that is possible in a way that isnt shit. maybe. idk
#if BUILD_TIME_HOUR == 0
	ambient_light = rgb(255 * 0.01, 255 * 0.01, 255 * 0.01)	// night time
#elif BUILD_TIME_HOUR == 1
	ambient_light = rgb(255 * 0.005, 255 * 0.005, 255 * 0.01)	// night time
#elif BUILD_TIME_HOUR == 2
	ambient_light = rgb(255 * 0.00, 255 * 0.00, 255 * 0.005)	// night time
#elif BUILD_TIME_HOUR == 3
	ambient_light = rgb(255 * 0.00, 255 * 0.00, 255 * 0.00)	// night time
#elif BUILD_TIME_HOUR == 4
	ambient_light = rgb(255 * 0.02, 255 * 0.02, 255 * 0.02)	// night time
#elif BUILD_TIME_HOUR == 5
	ambient_light = rgb(255 * 0.05, 255 * 0.05, 255 * 0.05)	// night time
#elif BUILD_TIME_HOUR == 6
	ambient_light = rgb(181 * 0.25, 205 * 0.25, 255 * 0.25)	// 17000
#elif BUILD_TIME_HOUR == 7
	ambient_light = rgb(202 * 0.60, 218 * 0.60, 255 * 0.60)	// 10000
#elif BUILD_TIME_HOUR == 8
	ambient_light = rgb(221 * 0.95, 230 * 0.95, 255 * 0.95)	// 8000 (sunrise)
#elif BUILD_TIME_HOUR == 9
	ambient_light = rgb(210 * 1.00, 223 * 1.00, 255 * 1.00)	// 11000
#elif BUILD_TIME_HOUR == 10
	ambient_light = rgb(196 * 1.00, 214 * 1.00, 255 * 1.00)	// 10000
#elif BUILD_TIME_HOUR == 11
	ambient_light = rgb(221 * 1.00, 230 * 1.00, 255 * 1.00)	// 8000
#elif BUILD_TIME_HOUR == 12
	ambient_light = rgb(230 * 1.00, 235 * 1.00, 255 * 1.00)	// 7500-ish
#elif BUILD_TIME_HOUR == 13
	ambient_light = rgb(243 * 1.00, 242 * 1.00, 255 * 1.00)	// 7000
#elif BUILD_TIME_HOUR == 14
	ambient_light = rgb(255 * 1.00, 250 * 1.00, 244 * 1.00)	// 6250-ish
#elif BUILD_TIME_HOUR == 15
	ambient_light = rgb(255 * 1.00, 243 * 1.00, 231 * 1.00)	// 5800-ish
#elif BUILD_TIME_HOUR == 16
	ambient_light = rgb(255 * 1.00, 232 * 1.00, 213 * 1.00)	// 5200-ish
#elif BUILD_TIME_HOUR == 17
	ambient_light = rgb(255 * 0.95, 206 * 0.95, 166 * 0.95)	// 4000
#elif BUILD_TIME_HOUR == 18
	ambient_light = rgb(255 * 0.90, 146 * 0.90,  39 * 0.90)	// 2200 (sunset), "golden hour"
#elif BUILD_TIME_HOUR == 19
	ambient_light = rgb(196 * 0.50, 214 * 0.50, 255 * 0.50)	// 10000
#elif BUILD_TIME_HOUR == 20
	ambient_light = rgb(191 * 0.21, 211 * 0.20, 255 * 0.30)	// 12000 (moon / stars), "blue hour"
#elif BUILD_TIME_HOUR == 21
	ambient_light = rgb(218 * 0.10, 228 * 0.10, 255 * 0.13)	// 8250
#elif BUILD_TIME_HOUR == 22
	ambient_light = rgb(221 * 0.04, 230 * 0.04, 255 * 0.05)	// 8000
#elif BUILD_TIME_HOUR == 23
	ambient_light = rgb(243 * 0.01, 242 * 0.01, 255 * 0.02)	// 7000
#else
	ambient_light = rgb(255 * 1.00, 255 * 1.00, 255 * 1.00)	// uhhhhhh
#endif

//goonstation offices as is for now- but they're not in as areas.
/area/centcom/earth/offices
	name = "NT Offices"
	icon_state = "green"
	var/ckey = ""

//sord office

/obj/machinery/door/unpowered/wood/sordBloodDoor
	open()
		. = ..()
		if(.)
			var/const/fluid_amount = 50
			var/datum/reagents/R = new /datum/reagents(fluid_amount)
			R.add_reagent("blood", fluid_amount)

			var/turf/T = get_turf(src)
			if (istype(T))
				T.fluid_react(R,fluid_amount)
				R.clear_reagents()

/area/centcom/earth/lobby
	name = "NT Offices Lobby"
	icon_state = "blue"

/area/centcom/earth/lounge
	name = "NT Recreational Lounge"
	icon_state = "yellow"

/area/centcom/earth/garden
	name = "NT Business Park"
	icon_state = "orange"

/area/centcom/earth/power
	name = "NT Power Supply"
	icon_state = "green"
	blocked = 1

/area/centcom/earth/datacenter
	name = "NT Data Center"
	icon_state = "pink"

/area/centcom/earth/reconstitutioncenter
	name = "NT Reconstitution Center"
	icon_state = "purple"

//some whatever thing on earth, doesn't bother us

/area/retentioncenter
	name = "NT Retention Center"
	icon_state = "dk_yellow"

/area/retentioncenter/depot
	name = "NT Retention Center (depot)"
	icon_state = "green"

/area/retentioncenter/blue
	name = "NT Retention Center (BLU)"
	icon_state = "blue"

/area/retentioncenter/green
	name = "NT Retention Center (GRN)"
	icon_state = "green"

/area/retentioncenter/yellow
	name = "NT Retention Center (YLW)"
	icon_state = "yellow"

/area/retentioncenter/orange
	name = "NT Retention Center (ORG)"
	icon_state = "orange"

/area/retentioncenter/red
	name = "NT Retention Center (RED)"
	icon_state = "red"

/area/retentioncenter/black
	name = "NT Retention Center (BLK)"
	icon_state = "purple"

/area/retentioncenter/restricted
	name = "NT Retention Center (Restricted)"
	icon_state = "death"

/area/retentioncenter/disposals
	name = "NT Retention Center (disposals)"
	icon_state = "red"

/area/retentioncenter/substation
	name = "NT Retention Center (substation)"
	icon_state = "pink"

/area/retentioncenter/office
	name = "NT Retention Center (office)"
	icon_state = "orange"

////////////////////////////

/turf/outdoors
	icon = 'icons/turf/outdoors.dmi'


	snow
		name = "snow"
		New()
			..()
			set_dir(pick(cardinal))
		icon_state = "grass_snow"
	grass
		name = "grass"
		New()
			..()
			set_dir(pick(cardinal))
		icon_state = "grass"
		dense
			name = "dense grass"
			desc = "whoa, this is some dense grass. wow."
			density = 1
			opacity = 1
			color = "#AAAAAA"
	concrete
		name = "concrete"
		icon_state = "concrete"
