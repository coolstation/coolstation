
/* -------------------------------------------------------------------------- */
/*                         Shuttle Escape Route Lights                        */
/* -------------------------------------------------------------------------- */
// first draft
// is set off by shuttle arriving on station and shuts off again when shuttle leaves
// intended for use in the middle of all main hallways to guide crew to departure
// alternates for going down the middle of 2 or 4 tile hallways or perhaps along walls
// build corners by using two of them, or intersections by using 3 or 4
// cardinal directions only

//Todo: junctions where more than one firsthalves come together get one very bright light because of overlaps

/obj/pathlights/shuttle
	name = "shuttle evacuation light"
	desc = "A small light that directs the way to the departing shuttle bay."
	icon = 'icons/obj/pathlights.dmi'
	#ifdef IN_MAP_EDITOR
	icon_state = "shuttle-egress-map"
	#else
	icon_state = "blank"
	#endif IN_MAP_EDITOR
	plane = PLANE_FLOOR
	mouse_opacity = 1 //you can't click this because that'd kinda suck
	var/halves = 3 //1 for first, 2 for second, 3 for both
	var/even = FALSE // false for centered, true for offset to north or east line (for even-tile hallways)
	var/even_alt = FALSE //normally center to north or east, this will center to south or west
	var/on_state = "shuttle-egress" //when this turns on, what iconstate to load
	var/image/glow_cutout = null

	//this can all be done so much better but i'm doing it this way for now so i have something to show
	//everything is cardinal and basic, if you want compound lights and intersections just plop down more

	New()
		..()
		START_TRACKING
		//initial slight offset due to the 32x32 cutoff
		//if unspecified, go with the default intended offsets
		if (!pixel_y || !pixel_x)
			switch(dir) //I trial and errored my way into these numbers
				if(NORTH)
					pixel_y = 5
				if(SOUTH)
					pixel_y = -3
				if(EAST)
					pixel_x = 3
				if(WEST)
					pixel_x = -5

			if(even)
				//bonus nudge for horizontal or vertical instances
				if(dir & (NORTH | SOUTH))
					//if normal even handling
					if (!even_alt)
						//shift half a tile east
						pixel_x += 16
					else
						//shift half a tile west
						pixel_x -= 16
				else
					//if normal even handling
					if (!even_alt)
						//shift half a tile north
						pixel_y += 16
					else
						//shift half a tile south
						pixel_y -= 16

	disposing()
		STOP_TRACKING
		..()

	//this thing does two things: turn on, and turn off
	proc/shuttle_pathlights()
		if(emergency_shuttle?.online)
			if(emergency_shuttle.location == SHUTTLE_LOC_STATION)
				src.icon_state = "[on_state]"
				glow_cutout = image('icons/obj/pathlights.dmi', src.icon_state, -1)
				glow_cutout.plane = PLANE_LIGHTING
				glow_cutout.blend_mode = BLEND_ADD
				glow_cutout.layer = LIGHTING_LAYER_BASE
				glow_cutout.color = glow_cutout.color = list(0.55,0.55,0.55, 0.55,0.55,0.55, 0.55,0.55,0.55)//up from a bunch of 0.33s
				src.UpdateOverlays(glow_cutout, "on_state")
				return
			else
				src.icon_state = "blank"
				src.ClearAllOverlays()
				src.glow_cutout = null

		return
//the first half of the full light sequence, for building corners and intersections. direction is direction of light path
//for example, first half dir north + second half dir north = just a normal full light sequence dir north
	firsthalf
		name = "shuttle evacuation light"
		#ifdef IN_MAP_EDITOR
		icon_state = "shuttle-egress-1-map"
		#else
		icon_state = "blank"
		#endif IN_MAP_EDITOR
		on_state = "shuttle-egress-1"

	//the second half of the full light sequence, for building corners and intersections. direction is direction of light path
	secondhalf
		name = "shuttle evacuation light"
		#ifdef IN_MAP_EDITOR
		icon_state = "shuttle-egress-2-map"
		#else
		icon_state = "blank"
		#endif IN_MAP_EDITOR
		on_state = "shuttle-egress-2"

	//if you have a hallway where this will be off center scootch this by 16 to the right if NS or 16 down if EW
	//the timing is also off by half because so is the positioning
	even
		name = "shuttle evacuation light"
		#ifdef IN_MAP_EDITOR
		icon_state = "shuttle-egress-map"
		#else
		icon_state = "blank"
		#endif IN_MAP_EDITOR
		even = TRUE
		on_state = "shuttle-egress-centered"

		//these are purely here as mapping aids but may help with buildmode/spawn stuff
		horizontal
			pixel_x = 4
			pixel_y = 16

			alt
				pixel_y = -16
		vertical
			pixel_x = 16
			pixel_y = -4

			alt
				pixel_x = -16

//the first half offset for even-tile hallways, with altered timing
	firsthalf/even
		even = TRUE
		on_state = "shuttle-egress-1-centered"

		horizontal
			pixel_x = 3
			pixel_y = 16

			alt
				pixel_y = -16

		vertical
			pixel_x = 16
			pixel_y = -3

			alt
				pixel_x = -16

//the second half offset for even-tile hallways, with altered timing
	secondhalf/even
		pixel_y = 12
		even = TRUE
		on_state = "shuttle-egress-2-centered"

		horizontal
			pixel_x = 3
			pixel_y = 16

			alt
				pixel_y = -16

		vertical
			pixel_x = 16
			pixel_y = -3

			alt
				pixel_x = -16
