/obj/decal
	text = ""
	var/list/random_icon_states = list()
	var/random_dir = 0

	New()
		..()
		if (random_icon_states && length(src.random_icon_states) > 0)
			src.icon_state = pick(src.random_icon_states)
		if (src.random_dir)
			if (random_dir >= 8)
				src.set_dir(pick(alldirs))
			else
				src.set_dir(pick(cardinal))

		if (!real_name)
			real_name = name
/*
	pooled()
		..()


	unpooled()
		..()
*/
	proc/setup(var/L,var/list/viral_list)
		set_loc(L)

		if (random_icon_states && length(src.random_icon_states) > 0)
			src.icon_state = pick(src.random_icon_states)
		if (src.random_dir)
			if (random_dir >= 8)
				src.set_dir(pick(alldirs))
			else
				src.set_dir(pick(cardinal))

		if (!real_name)
			real_name = name

	meteorhit(obj/M as obj)
		if (isrestrictedz(src.z))
			return
		else
			return ..()

	ex_act(severity)
		if (isrestrictedz(src.z))
			return
		else
			qdel(src)
			//return ..()

	track_blood()
		src.tracked_blood = null
		return

////////////
// OTHERS //
////////////

/obj/decal/ceshield
	name = ""
	icon = 'icons/effects/effects.dmi'
	icon_state = "ceshield"
	layer = EFFECTS_LAYER_BASE
	opacity = 0
	anchored = 1
	pixel_y = 0
	pixel_x = 0
	mouse_opacity = 0
	blend_mode = 2

	New()
		src.filters += filter(type="motion_blur", x=0, y=3)
		..()

/obj/decal/skeleton
	name = "skeleton"
	desc = "The remains of a human."
	opacity = 0
	density = 0
	anchored = 1
	icon = 'icons/obj/adventurezones/void.dmi'
	icon_state = "skeleton_l"

	decomposed_corpse
		name = "decomposed corpse"
		desc = "Eugh, the stench is horrible!"
		icon = 'icons/misc/hstation.dmi'
		icon_state = "body1"

	unanchored
		anchored = 0

		summon
			New()
				flick("skeleton_summon", src)
				..()


	cap
		name = "remains of the captain"
		desc = "The remains of the captain of this station ..."
		opacity = 0
		density = 0
		anchored = 1
		icon = 'icons/obj/adventurezones/void.dmi'
		icon_state = "skeleton_l"

/obj/decal/floatingtiles
	name = "floating tiles"
	desc = "These tiles are just floating around in the void."
	opacity = 0
	density = 0
	anchored = 1
	icon = 'icons/obj/adventurezones/void.dmi'
	icon_state = "floattiles1"
	var/recover = FALSE
	plane = PLANE_NOSHADOW_BELOW

	attackby(obj/item/C as obj, mob/user as mob)
		if (ispryingtool(C))
			if(!recover)
				return ..()
			if(prob(33))
				boutput(user, "<span class='notice'>You are able to salvage the tiles.</span>")
				var/obj/item/I = new /obj/item/tile()
				I.set_loc(src.loc)
				if (src.material)
					I.setMaterial(src.material)
				else
					var/datum/material/M = getMaterial("steel")
					I.setMaterial(M)
			else
				boutput(user, "<span class='notice'>These tiles are too fucked to be of use.</span>")
			qdel(src)

	loose
		name = "loose tiles"
		desc = "These tiles were dislodged by something."
		recover = TRUE

/obj/decal/floatingtiles/loose/random
	New()
		..()
		icon_state = "floattiles[rand(1,6)]"
		set_dir(pick(NORTH,EAST,SOUTH,WEST))

/obj/decal/implo
	name = "implosion"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "dimplo"
	layer = EFFECTS_LAYER_BASE
	opacity = 0
	anchored = 1
	pixel_y = -16
	pixel_x = -16
	mouse_opacity = 0
	New(var/atom/location)
		src.set_loc(location)
		SPAWN_DBG(2 SECONDS) qdel(src)
		return ..(location)

/obj/decal/shockwave
	name = "shockwave"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "explocom"
	layer = EFFECTS_LAYER_BASE
	opacity = 0
	anchored = 1
	pixel_y = -16
	pixel_x = -16
	mouse_opacity = 0
	New(var/atom/location)
		src.set_loc(location)
		SPAWN_DBG(2 SECONDS) qdel(src)
		return ..(location)

/obj/decal/point
	name = "point"
	icon = 'icons/ui/screen1.dmi'
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | PIXEL_SCALE
	icon_state = "arrow"
	layer = EFFECTS_LAYER_1
	plane = PLANE_HUD
	anchored = 1

proc/make_point(atom/movable/target, pixel_x=0, pixel_y=0, color="#ffffff", time=2 SECONDS, invisibility=0)
	// note that `target` can also be a turf, but byond sux and I can't declare the var as atom because areas don't have vis_contents
	var/obj/decal/point/point = new
	point.pixel_x = pixel_x
	point.pixel_y = pixel_y
	point.color = color
	point.invisibility = invisibility
	target.vis_contents += point
	SPAWN_DBG(time)
		if(target)
			target.vis_contents -= point
		qdel(point)
	return point

/* - Replaced by functional version: /obj/item/instrument/large/jukebox
/obj/decal/jukebox
	name = "Old Jukebox"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "jukebox"
	desc = "This doesn't seem to be working anymore."
	layer = OBJ_LAYER
	anchored = 1
	density = 1
*/

/obj/decal/pole
	name = "Barber Pole"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "pole"
	anchored = 1
	density = 0
	desc = "Barber poles historically were signage used to convey that the barber would perform services such as blood letting and other medical procedures, with the red representing blood, and the white representing the bandaging. In America, long after the time when blood-letting was offered, a third colour was added to bring it in line with the colours of their national flag. This one is in space."
	layer = OBJ_LAYER

/obj/decal/gehennagrass
	name = "desert scrub"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "gehennagrass1"
	random_icon_states = list("gehennagrass1", "gehennagrass2", "gehennagrass3")
	anchored = 1
	density = 0
	var/seed_prob = 50
	desc = "This scrub has turned purple from the strain of growing in the desert."
	layer = FLOOR_EQUIP_LAYER1

	attackby(obj/item/I, mob/user)
		if(istool(I,TOOL_CUTTING | TOOL_SAWING | TOOL_SNIPPING))
			src.visible_message("[user] cuts [src].")
			if(prob(seed_prob))
				var/seedtype = null
				if(prob(1))
					seedtype = /obj/item/seed/alien
				else
					seedtype = /obj/item/seed/grass/scrub

				new seedtype(src.loc)
			qdel(src)
		else
			..()

/obj/decal/oven
	name = "Oven"
	desc = "An old oven."
	icon = 'icons/obj/foodNdrink/kitchen.dmi'
	icon_state = "oven_off"
	anchored = 1
	density = 1
	layer = OBJ_LAYER

/obj/decal/sink
	name = "Sink"
	icon = 'icons/obj/foodNdrink/kitchen.dmi'
	icon_state = "sink"
	desc = "The sink doesn't appear to be connected to a waterline."
	anchored = 1
	density = 1
	layer = OBJ_LAYER

obj/decal/fakeobjects
	layer = OBJ_LAYER
	var/true_name = "fuck you erik"	//How else will players banish it or place curses on it?? honestly people

	New()
		..()
		true_name = name

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.true_name][name_suffix(null, 1)]"

/obj/decal/fakeobjects/robot
	name = "Inactive Robot"
	desc = "The robot looks to be in good condition."
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	anchored = 0
	density = 1

/obj/decal/fakeobjects/sealedsleeper
	name = "sleeper"
	desc = "This one appears to still be sealed. Who's in there?"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sealedsleeper"
	anchored = 1
	density = 1

/obj/decal/fakeobjects/hose //gross
	name = "garden hose"
	desc = "A garden hose stand, with spigot."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "hose"
	anchored = 1
	density = 1

//sealab prefab fakeobjs

/obj/decal/fakeobjects/palmtree
	name = "palm tree"
	desc = "This is a palm tree. Smells like plastic."
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm"
	anchored = 1
	density = 0

/obj/decal/fakeobjects/brokenportal
	name = "broken portal ring"
	desc = "This portal ring looks completely fried."
	icon = 'icons/obj/machines/teleporter.dmi'
	icon_state = "tele_fuzz"
	anchored = 1
	density = 1

//this was the florps statue in keelin's stuff
//now it's pupkin (simplified)
/obj/decal/fakeobjects/pupkinstatue
	name = "Statue of Pupkin"
	desc = "Thank you for loving Pupkin."
	var/broken = 0
	icon ='icons/obj/objects.dmi'
	icon_state = "statuepupkin"
	density = 1

	New()
		..()
		setMaterial(getMaterial("slag"))
		name = "Statue of Pupkin"

	attack_hand(mob/user as mob)
		boutput(user, "You pet \the [src]. You feel really uneasy about it, but thank you anyway.")
		return


/obj/decal/bloodtrace
	name = "blood trace"
	desc = "Oh my!!"
	icon = 'icons/obj/decals/blood.dmi'
	icon_state = "lum"
	invisibility = 101
	blood_DNA = null
	blood_type = null

/obj/decal/boxingrope
	name = "Boxing Ropes"
	desc = "Do not exit the ring."
	density = 1
	anchored = 1
	icon = 'icons/obj/decoration.dmi'
	icon_state = "ringrope"
	layer = OBJ_LAYER
	event_handler_flags = USE_FLUID_ENTER | USE_CHECKEXIT | USE_CANPASS

	CanPass(atom/movable/mover, turf/target) // stolen from window.dm
		if (mover && mover.throwing & THROW_CHAIRFLIP)
			return 1
		if (src.dir == SOUTHWEST || src.dir == SOUTHEAST || src.dir == NORTHWEST || src.dir == NORTHEAST || src.dir == SOUTH || src.dir == NORTH)
			return 0
		if(get_dir(loc, target) == dir)

			return !density
		else
			return 1

	CheckExit(atom/movable/O as mob|obj, target as turf)
		if (!src.density)
			return 1
		if (get_dir(O.loc, target) == src.dir)
			return 0
		return 1

/obj/stool/chair/boxingrope_corner
	name = "Boxing Ropes"
	desc = "Do not exit the ring."
	density = 1
	anchored = 1
	icon = 'icons/obj/decoration.dmi'
	icon_state = "ringrope"
	layer = OBJ_LAYER
	event_handler_flags = USE_FLUID_ENTER | USE_CHECKEXIT | USE_CANPASS

	rotatable = 0
	foldable = 0
	climbable = 2
	buckle_move_delay = 6 // this should have been a var somepotato WHY WASN'T IT A VAR
	securable = 0

	can_buckle(var/mob/M as mob, var/mob/user as mob)
		if (M != user)
			return 0
		if ((!( iscarbon(M) ) || get_dist(src, user) > 1 || user.restrained() || user.stat || !user.canmove))
			return 0
		return 1

	MouseDrop_T(mob/M as mob, mob/user as mob)
		if (can_buckle(M,user))
			M.set_loc(src.loc)
			user.visible_message("<span class='notice'><b>[M]</b> climbs up on [src], ready to lay down the pain!</span>", "<span class='notice'>You climb up on [src] and prepare to rain destruction!</span>")
			buckle_in(M, user, 1)

	CanPass(atom/movable/mover, turf/target) // stolen from window.dm
		if (mover && mover.throwing & THROW_CHAIRFLIP)
			return 1
		if (src.dir == SOUTHWEST || src.dir == SOUTHEAST || src.dir == NORTHWEST || src.dir == NORTHEAST || src.dir == SOUTH || src.dir == NORTH)
			return 0
		if(get_dir(loc, target) == dir)

			return !density
		else
			return 1

	CheckExit(atom/movable/O as mob|obj, target as turf)
		if (!src.density)
			return 1
		if (get_dir(O.loc, target) == src.dir)
			return 0
		return 1

/obj/decal/boxingropeenter
	name = "Ring entrance"
	desc = "Do not exit the ring."
	density = 0
	anchored = 1
	icon = 'icons/obj/decoration.dmi'
	icon_state = "ringrope"
	layer = OBJ_LAYER

/obj/decal/doormat
	name = "Doormat"
	desc = "A cute, muddy doormat"
	density = 0
	anchored = 1
	icon = 'icons/obj/decoration.dmi'
	icon_state = "doormat"
	layer = OBJ_LAYER

/obj/decal/slipmat
	name = "Anti Slip mat"
	desc = "A ratty rubber mat that protects you from slipping. Probably."
	density = 0
	anchored = 1
	icon = 'icons/obj/decoration.dmi'
	icon_state = "slipmat"
	layer = OBJ_LAYER

/obj/decal/slipmat/torn
	name = "Torn anti slip mat"
	icon_state = "slipmat_torn"

/obj/decal/alienflower
	name = "strange alien flower"
	desc = "Is it going to eat you if you get too close?"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "alienflower"
	random_dir = 8

	New()
		..()
		src.set_dir(pick(alldirs))
		src.pixel_y += rand(-8,8)
		src.pixel_x += rand(-8,8)

/obj/decal/cleanable/alienvine
	name = "strange alien vine"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "avine_l1"
	random_icon_states = list("avine_l1", "avine_l2", "avine_l3")
	New()
		..()
		src.set_dir(pick(cardinal))
		if (prob(20))
			new /obj/decal/alienflower(src.loc)
/*
	unpooled()
		..()
		src.set_dir(pick(cardinal))
		if (prob(20))
			new /obj/decal/alienflower(src.loc)
*/
/obj/decal/icefloor
	name = "ice"
	desc = "Slippery!"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "icefloor"
	density = 0
	opacity = 0
	anchored = 1
	plane = PLANE_FLOOR
	event_handler_flags = USE_HASENTERED

/obj/decal/icefloor/HasEntered(var/atom/movable/AM)
	if (iscarbon(AM))
		var/mob/M =	AM
		// drsingh fix for undefined variable mob/living/carbon/monkey/var/shoes

		if (M.getStatusDuration("weakened") || M.getStatusDuration("stunned") || M.getStatusDuration("frozen"))
			return

		if (M.slip(0))
			M.lastgasp()
			boutput(M, "<span class='alert'>You slipped on [src]!</span>")
			if (prob(5))
				M.TakeDamage("head", 5, 0, 0, DAMAGE_BLUNT)
				M.visible_message("<span class='alert'><b>[M]</b> hits their head on [src]!</span>")
				playsound(src.loc, "sound/impact_sounds/Generic_Hit_1.ogg", 50, 1)

// These used to be static turfs derived from the standard grey floor tile and thus didn't always blend in very well (Convair880).
/obj/decal/mule
	name = "Don't spawn me"
	mouse_opacity = 0
	density = 0
	anchored = 1
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "blank"
	layer = TURF_LAYER + 0.1 // Should basically be part of a turf.

	beacon
		name = "MULE delivery destination"
		icon_state = "mule_beacon"
		var/auto_dropoff_spawn = 1

		New()
			..()
			var/turf/T = get_turf(src)
			if (T && isturf(T) && src.auto_dropoff_spawn == 1)
				for (var/obj/machinery/navbeacon/mule/NB in T.contents)
					if (!isnull(NB.codes_txt))
						var/turf/TD = null
						switch (NB.codes_txt)
							if ("delivery;dir=1")
								TD = locate(T.x, T.y + 1, T.z)
							if ("delivery;dir=4")
								TD = locate(T.x + 1, T.y, T.z)
							if ("delivery;dir=2")
								TD = locate(T.x, T.y - 1, T.z)
							if ("delivery;dir=8")
								TD = locate(T.x - 1, T.y, T.z)
							else
								return

						if (TD && isturf(TD) && !TD.density)
							new /obj/decal/mule/dropoff(TD)
							if (!isnull(NB.location))
								src.name = "[src.name] ([NB.location])"
							break
			return

		no_auto_dropoff_spawn
			auto_dropoff_spawn = 0

	dropoff
		name = "MULE cargo dropoff point"
		icon_state = "mule_dropoff"

/obj/decal/ballpit
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "ballpitwater"
	name = "ball pit"
	real_name = "ball pit"
	layer = 25
	mouse_opacity = 0

//Decals that glow.
/obj/decal/glow
	var/brightness = 0
	var/color_r = 0.36
	var/color_g = 0.35
	var/color_b = 0.21
	var/datum/light/light

	New()
		..()
		light = new /datum/light/point
		light.attach(src)
		light.set_color(src.color_r, src.color_g, src.color_b)
		light.set_brightness(src.brightness / 5)
		light.enable()

////////////
// RUDDER //
////////////
/obj/decal/rudder
	name = "ship steering wheel"
	desc = "They used these to steer ships a long, long time ago."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "rudder"
	density = 0
	opacity = 0
	anchored = 1

/obj/decal/landing_gear_prints_gehenna
	name = null
	desc = null
	icon = 'icons/effects/64x64.dmi'
	icon_state = "landing_gear_gehenna"
	anchored = 1
	density = 0
	mouse_opacity = 0
	plane = PLANE_NOSHADOW_BELOW
	layer = TURF_LAYER - 0.1
	//Grabs turf color set in gehenna.dm for sand
	New()
		..()
		var/turf/T = get_turf(src)
		src.color = T.color

/obj/decal/beaten_edge_thin
	name = null
	desc = null
	icon = 'icons/turf/gehenna_overlays.dmi'
	icon_state = "beaten_edge_thin"
	anchored = 1
	density = 0
	mouse_opacity = 0
	plane = PLANE_NOSHADOW_BELOW
	layer = TURF_LAYER - 0.1
	//Grabs turf color set in gehenna.dm for sand
	New()
		..()
		var/turf/T = get_turf(src)
		src.color = T.color


/obj/decal/cragrock
	name = "\improper Gehennan rock spikes"
	desc = "Painfully sharp shards of sulfurous rock."
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "cragrock1"
	pixel_x = -16
	density = 1
	opacity = 0
	anchored = 1
	plane = PLANE_NOSHADOW_ABOVE

	New()
		..()
		icon_state = "cragrock[rand(1,4)]"

	Bumped(AM as mob|obj)
		if(!ismob(AM))
			return
		var/mob/living/L = AM
		if(prob(5))
			take_bleeding_damage(L,null,5,DAMAGE_STAB)
			random_brute_damage(L,10)
			L.visible_message("<span class='alert'>[L] stubs their toe on [src]!</span>","<span class='alert'>You stub your toe on [src]!</span>")
