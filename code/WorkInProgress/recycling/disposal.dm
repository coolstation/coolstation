
#define PIPEC_MAIL "#8dc2f4"
#define PIPEC_BRIG "#ff6666"
#define PIPEC_EJECTION "#f2a673"
#define PIPEC_MORGUE "#696969"
#define PIPEC_CREMATORIUM "#a51313"
#define PIPEC_QUARANTINE "#54ad00"
#define PIPEC_GENETICS "#403b81"
#define PIPEC_FOOD "#fbed92"
#define PIPEC_PRODUCE "#b2ff4f"
#define PIPEC_TRANSPORT "#ffbef6"
#define PIPEC_MINERAL "#a5fffc"
#define PIPEC_CARGO "#f4ff53"
#define PIPEC_SEWAGE "#778163"

// virtual disposal object
// travels through pipes in lieu of actual items
// contents will be items flushed by the disposal
// this allows the gas flushed to be tracked

/obj/disposalholder
	invisibility = 101
	var/datum/gas_mixture/gas = null	// gas used to flush, will appear at exit point
	var/active = 0	// true if the holder is moving, otherwise inactive
	dir = 0
	var/count = 1000	//*** can travel 1000 steps before going inactive (in case of loops)
	var/last_sound = 0

	var/slowed = 0 // when you move, slows you down

	var/mail_tag = null //Switching junctions with the same tag will pass it out the secondary instead of primary

	var/autoconfig = 0 //Is this a configuration packet? great! glad to hear it!
	var/list/routers = null // a list of the places we have been so far.

	New()
		..()
		gas = null
		active = 0
		set_dir(0)
		count = initial(count)
		last_sound = 0
		mail_tag = null
		autoconfig = 0
		routers = list()
		reagents = new(1000)

	disposing()
		routers = null
		autoconfig = 0
		gas = null
		active = 0
		set_dir(0)
		last_sound = 0
		mail_tag = null
		reagents = null
		..()

	// initialize a holder from the contents of a disposal unit
	proc/init(var/obj/machinery/disposal/D)
		gas = D.air_contents.remove_ratio(1)	// transfer gas resv. into holder object

		// set_loc(null makes some stuff grumpy, ok?)
		if(D.trunk)
			src.set_loc(D.trunk)
		else
			src.set_loc(D)

		// now everything inside the disposal gets put into the holder
		// note AM since can contain mobs or objs
		for(var/atom/movable/AM in D)
			AM.set_loc(src)
			if(ishuman(AM))
				var/mob/living/carbon/human/H = AM
				H.unlock_medal("It'sa me, Mario", 1)

	proc/init_sewer(var/obj/item/storage/toilet/toilet)
		if(toilet.trunk)		//copypasted
			src.set_loc(toilet.trunk)
		else
			src.set_loc(toilet)

		if(!src.reagents)
			src.reagents = new(1000)

		src.reagents.add_reagent("water", 50)
		src.reagents.add_reagent("sewage", rand(10,55))

		if(toilet.poops)
			src.reagents.add_reagent("poo",toilet.poops*25)
			toilet.poops = 0
		if(toilet.peeps)
			src.reagents.add_reagent("urine",toilet.peeps*25)
			toilet.peeps = 0

		if(toilet.reagents && toilet.reagents.total_volume)
			toilet.reagents.trans_to(src, toilet.reagents.total_volume)


		for(var/atom/movable/AM in toilet)
			AM.set_loc(src)


	// start the movement process
	// argument is the disposal unit the holder started in
	proc/start(var/obj/machinery/disposal/D)
		if(!D.trunk || D.trunk.loc != D.loc)
			D.expel(src)	// no trunk connected, so expel immediately
			return

		set_loc(D.trunk)
		active = 1
		set_dir(DOWN)
		SPAWN_DBG(1 DECI SECOND)
			process()		// spawn off the movement process

		return

	// movement process, persists while holder is moving through pipes
	proc/process()
		var/obj/disposalpipe/last
		while(active)
			sleep(0.1 SECONDS)		// was 1
			if(slowed > 0)
				slowed--
				slowed = max(slowed,0)
				sleep(1 SECONDS)
			else
				if (!loc)
					return
				var/obj/disposalpipe/curr = loc
				last = curr
				curr = curr.transfer(src)
				if(!curr)
					last.expel(src, get_turf(loc), dir)

				if(!(count--))
					active = 0
					if(autoconfig)//we dont want dead config packets to stay put, we want them to evaporate.
						qdel(src)
		return

	// find the turf which should contain the next pipe
	proc/nextloc()
		return get_step(loc,dir)

	// find a matching pipe on a turf
	proc/findpipe(var/turf/T)

		if(!T)
			return null

		var/fdir = turn(dir, 180)	// flip the movement direction
		for(var/obj/disposalpipe/P in T)
			if(fdir & P.dpdir)		// find pipe direction mask that matches flipped dir
				return P
		// if no matching pipe, return null
		return null

	// merge two holder objects
	// used when a a holder meets a stuck holder
	proc/merge(var/obj/disposalholder/other)
		if (istype(other, /obj/disposalholder/crawler)) //early return here to have mercy on pipe crawling players
			var/obj/disposalholder/crawler/C = other
			boutput(C.pilot, "<span class='alert'><b>Something else coming down the pipes sweeps you with it! [pick("Fuck", "Damn it", "Piss", "Noooooo", "Bitter hubris", "Oh the humanity")]!</b></span>")
			C.pilot?.emote("scream")
			if (istype(src, /obj/disposalholder/crawler) && !src.active) //partly funny, partly to avoid having to deal with two pilots (or someone holding another person indefinitely)
				C = src
				C.movement_controller.in_control = FALSE
				C.pilot?.emote("scream")
				C.active = TRUE
				boutput(C.pilot, "<span class='alert'><b>You slam into someone else in the pipes, and lose your grip! [pick("Fuck", "Damn it", "Piss", "Noooooo", "Bitter hubris", "Oh the humanity")]!</b></span>")
				SPAWN_DBG(1 DECI SECOND) //Get fucked
					process()		// spawn off the movement process
		for(var/atom/movable/AM in other)
			AM.set_loc(src)	// move everything in other holder to this one
		if(other.mail_tag && !src.mail_tag)
			src.mail_tag = other.mail_tag
		if(other.reagents)
			other.reagents.trans_to(src, 1000)
		qdel(other)


	// called when player tries to move while in a pipe
	relaymove(mob/user as mob)
		if (user.stat)
			return

		// drsingh: attempted fix for Cannot read null.loc
		if (src == null || src.loc == null || src.loc.loc == null)
			return

		for (var/mob/M in hearers(src.loc.loc))
			boutput(M, "<FONT size=[max(0, 5 - get_dist(src, M))]>CLONG, clong!</FONT>")

		if(last_sound + 6 < world.time)
			playsound(src.loc, "sound/impact_sounds/Metal_Clang_1.ogg", 50, 0, 0)
			last_sound = world.time
			damage_pipe()
			if(prob(30))
				slowed++

	mob_flip_inside(var/mob/user)
		var/obj/disposalpipe/P = src.loc
		if(!istype(P))
			return
		user.show_text("<span class='alert'>You leap and slam against the inside of [P]! Ouch!</span>")
		user.changeStatus("paralysis", 4 SECONDS)
		user.changeStatus("weakened", 4 SECONDS)
		src.visible_message("<span class='alert'><b>[P]</b> emits a loud thump and rattles a bit.</span>")
		user.take_brain_damage(prob(50))

		animate_storage_thump(P)

		user.show_text("<span class='alert'>[P] [pick("cracks","bends","shakes","groans")].</span>")
		damage_pipe(5)
		slowed++

	proc/damage_pipe(var/amount = 3)
		var/obj/disposalpipe/P = src.loc
		if(istype(P))
			P.health -= rand(1,amount)
			P.health = max(P.health,0)
			P.healthcheck()

	// called to vent all gas in holder to a location
	proc/vent_gas(var/atom/location)
		location.assume_air(gas)  // vent all gas to turf
		gas = null
		return

	proc/dupe() // returns another disposalholder like this one
		var/obj/disposalholder/autoconfig/dupe = new()
		dupe.count = src.count
		dupe.autoconfig = src.autoconfig
		dupe.routers = src.routers.Copy()
		dupe.mail_tag = src.mail_tag
		dupe.active = src.active
		dupe.dir = src.dir
		return dupe

/obj/disposalholder/autoconfig
	// warc sez: \\
	// this is a special guy created specifically to help automatically configure the mail system.
	autoconfig = 1

/obj/disposalholder/crawler
	// bat sex: \\
	// this is a special gal that lets players traverse the disposals network
	var/mob/pilot
	var/datum/movement_controller/pipe_crawler/movement_controller
	var/obj/item/device/t_scanner/vision

	New()
		vision = new(src)
		vision.set_on(TRUE)
		movement_controller = new()
		movement_controller.owner = src
		..()

	disposing()
		qdel(vision)
		qdel(movement_controller)
		vision = null
		movement_controller = null
		pilot = null
		..()

	start(obj/machinery/disposal/D)
		if (!can_act(pilot, TRUE))
			movement_controller.in_control = TRUE
			return ..()

		if(!D.trunk || D.trunk.loc != D.loc)
			D.expel(src)	// no trunk connected, so expel immediately
			return

		set_loc(D.trunk)
		set_dir(D.trunk.dir)



// Disposal pipes

/obj/disposalpipe
	icon = 'icons/obj/machines/disposal.dmi'
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	anchored = 1
	density = 0
	text = ""

	level = 1			// underfloor only
	var/dpdir = 0		// bitmask of pipe directions
	dir = 0				// dir will contain dominant direction for junction pipes
	var/health = 10 	// health points 0-10
	layer = DISPOSAL_PIPE_LAYER
	plane = PLANE_FLOOR
	var/base_icon_state	// initial icon state on map
	var/list/mail_tag = null // Tag of mail group for switching pipes

	var/image/pipeimg = null

	// new pipe, set the icon_state as on map
	New()
		..()
		base_icon_state = icon_state
		pipeimg = image(src.icon, src.loc, src.icon_state, 3, dir)
		pipeimg.layer = OBJ_LAYER
		pipeimg.dir = dir
		return

	// pipe is deleted
	// ensure if holder is present, it is expelled
	disposing()
		var/obj/disposalholder/H = locate() in src
		if(H)
			// holder was present
			H.active = 0
			var/turf/T = get_turf(src)
			if(T?.density)
				// deleting pipe is inside a dense turf (wall)
				// this is unlikely, but just dump out everything into the turf in case

				for(var/atom/movable/AM in H)
					AM.set_loc(T)
					AM.pipe_eject(0)
				H.dispose()
				..()
				return

			// otherswise, do normal expel from turf
			expel(H, T, 0)
		..()

	// returns the direction of the next pipe object, given the entrance dir
	// by default, returns the bitmask of remaining directions
	proc/nextdir(var/fromdir)
		return dpdir & (~turn(fromdir, 180))

	// transfer the holder through this pipe segment
	// overriden for special behaviour
	//
	proc/transfer(var/obj/disposalholder/H)
		var/nextdir = nextdir(H.dir)
		H.set_dir(nextdir)
		var/turf/T = H.nextloc()
		var/obj/disposalpipe/P = H.findpipe(T)

		if(P)
			// find other holder in next loc, if inactive merge it with current
			var/obj/disposalholder/H2 = locate() in P
			if(H2 && !H2.active)
				H.merge(H2)

			H.set_loc(P)
		else			// if wasn't a pipe, then set loc to turf
			H.set_loc(T)
			return null

		return P


	// update the icon_state to reflect hidden status
	proc/update()
		var/turf/T = src.loc
		if (T) hide(T.intact && !istype(T,/turf/space))	// space never hides pipes

	// hide called by levelupdate if turf intact status changes
	// change visibility status and force update of icon
	hide(var/intact)
		invisibility = intact ? 101: 0	// hide if floor is intact
		updateicon()

	// update actual icon_state depending on visibility
	// if invisible, set alpha to half the norm
	// this will be revealed if a T-scanner is used
	// if visible, use regular icon_state
	proc/updateicon()
		icon_state = base_icon_state
		alpha = invisibility ? 128 : 255
		return

	proc/fix_sprite()
		return

	// expel the held objects into a turf
	// called when there is a break in the pipe
	//

	proc/expel(var/obj/disposalholder/H, var/turf/T, var/direction)
		// oh dear, please stop ruining the machine loop with your invalid loc
		if (!T)
			return

		var/turf/target

		if(T.density)		// dense ouput turf, so stop holder
			H.active = 0
			H.set_loc(src)
			return
		if(T.intact && istype(T,/turf/floor)) //intact floor, pop the tile
			var/turf/floor/F = T
			//F.health	= 100
			F.burnt	= 1
			F.setIntact(FALSE)
			F.levelupdate()
			new /obj/item/tile/steel(H)	// add to holder so it will be thrown with other stuff
			F.icon_state = "[F.burnt ? "panelscorched" : "plating"]"

		if(direction)		// direction is specified
			if(istype(T, /turf/space)) // if ended in space, then range is unlimited
				target = get_edge_target_turf(T, direction)
			else						// otherwise limit to 10 tiles
				target = get_ranged_target_turf(T, direction, 10)

			playsound(src, "sound/machines/hiss.ogg", 50, 0, 0)
			for(var/atom/movable/AM in H)
				AM.set_loc(T)
				AM.pipe_eject(direction)
				AM?.throw_at(target, 100, 1)

			if(H.reagents && H.reagents.total_volume)
				T.fluid_react(H.reagents, H.reagents.total_volume)
			H.vent_gas(T)
			qdel(H)

		else	// no specified direction, so throw in random direction

			playsound(src, "sound/machines/hiss.ogg", 50, 0, 0)
			for(var/atom/movable/AM in H)
				target = get_offset_target_turf(T, rand(5)-rand(5), rand(5)-rand(5))

				AM.set_loc(T)
				AM.pipe_eject(0)
				AM?.throw_at(target, 5, 1)

			if(H.reagents && H.reagents.total_volume)
				T.fluid_react(H.reagents, H.reagents.total_volume)
			H.vent_gas(T)	// all gas vent to turf
			qdel(H)

		return

	// call to break the pipe
	// will expel any holder inside at the time
	// then delete the pipe
	// remains : set to leave broken pipe pieces in place
	proc/broken(var/remains = 0)
		if(isrestrictedz(z))
			return
		if(remains)
			for(var/D in cardinal)
				if(D & dpdir)
					var/obj/disposalpipe/broken/P = new(src.loc)
					P.set_dir(D)

		src.invisibility = 101	// make invisible (since we won't delete the pipe immediately)
		var/obj/disposalholder/H = locate() in src
		if(H)
			// holder was present
			H.active = 0
			var/turf/T = src.loc
			if(T.density)
				// broken pipe is inside a dense turf (wall)
				// this is unlikely, but just dump out everything into the turf in case

				for(var/atom/movable/AM in H)
					AM.set_loc(T)
					AM.pipe_eject(0)
				qdel(H)
				return

			// otherswise, do normal expel from turf
			expel(H, T, 0)

		SPAWN_DBG(0.2 SECONDS)	// delete pipe after 2 ticks to ensure expel proc finished
			qdel(src)


	proc/disconnected_dirs()
		. = list()
		if(!src)
			return

		for(var/d in list(1, 2, 4, 8))
			if(!(d & src.dpdir))
				continue
			var/ok = 1
			for(var/obj/disposalpipe/D in get_step(get_turf(src), d))
				if(D) // already existing connection
					if(D.dpdir & get_dir(D, src)) //pipe points towards us
						ok = 0
						break
			if(ok)
				. += d


	// pipe affected by explosion
	ex_act(severity)

		switch(severity)
			if(OLD_EX_SEVERITY_1)
				broken(0)
				return
			if(OLD_EX_SEVERITY_2)
				health -= rand(5,12) //3 in 7 chance to break from full health
				healthcheck()
				return
			if(OLD_EX_SEVERITY_3)
				health -= rand(2,6)
				healthcheck()
				return


	// test health for brokenness
	proc/healthcheck()
		if(isrestrictedz(z))
			return
		if(health < -2)
			broken(0)
		else if(health<1)
			broken(1)
		return

	//attack by item
	//weldingtool: unfasten and convert to obj/disposalconstruct

	attackby(var/obj/item/I, var/mob/user)
		if (isrestrictedz(z))
			return
		var/turf/T = src.loc
		if (T.intact)
			return		// prevent interaction with T-scanner revealed pipes

		if (isweldingtool(I))
			if (I:try_weld(user, 3, noisy = 2))
				// check if anything changed over 2 seconds
				var/turf/uloc = user.loc
				var/atom/wloc = I.loc
				boutput(user, "You begin slicing [src].")
				sleep(0.1 SECONDS)
				if (user.loc == uloc && wloc == I.loc)
					welded(user)
				else
					boutput(user, "You must stay still while welding the pipe.")
					return

	// called when pipe is cut with welder
	proc/welded(var/user)

		var/obj/disposalconstruct/C = new (src.loc)
		switch(base_icon_state)
			if("pipe-s")
				C.ptype = 0
			if("pipe-c")
				C.ptype = 1
			if("pipe-j1")
				C.ptype = 2
			if("pipe-j2")
				C.ptype = 3
			if("pipe-y")
				C.ptype = 4
			if("pipe-t")
				C.ptype = 5
			if("pipe-sj1")
				C.ptype = 6
			if("pipe-sj2")
				C.ptype = 7

		if (user)
			boutput(user, "You finish slicing [C].")

		C.set_dir(dir)
		C.mail_tag = src.mail_tag
		C.update()

		qdel(src)

// a straight or bent segment
/obj/disposalpipe/segment
	icon_state = "pipe-s"

	horizontal
		dir = EAST
	vertical
		dir = NORTH
	bent
		icon_state = "pipe-c"

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	mail
		name = "mail pipe"
		desc = "An underfloor mail pipe."
		color = PIPEC_MAIL

		horizontal
			dir = EAST
		vertical
			dir = NORTH
		bent
			icon_state = "pipe-c"

			north
				dir = NORTH
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST
	brig
		name = "brig pipe"
		desc = "An underfloor brig pipe. Bripe."
		color = PIPEC_BRIG

	ejection
		name = "ejection pipe"
		desc = "An underfloor ejection pipe."
		color = PIPEC_EJECTION

	morgue
		name = "morgue pipe"
		desc = "An underfloor morgue pipe, for dead people."
		color = PIPEC_MORGUE

	quarantine
		name = "quarantine pipe"
		desc = "An underfloor quarantine pipe."
		color = PIPEC_QUARANTINE

	genetics
		name = "genetics pipe"
		desc = "An underfloor genetics pipe, for dead people."
		color = PIPEC_GENETICS

	crematorium
		name = "crematorium pipe"
		desc = "An underfloor crematorium pipe, for dead people."
		color = PIPEC_CREMATORIUM

	food
		name = "food pipe"
		desc = "An underfloor food pipe lined with non-stick, probably-food-safe materials."
		color = PIPEC_FOOD

	produce
		name = "produce pipe"
		desc = "An underfloor produce pipe."
		color = PIPEC_PRODUCE

	transport
		name = "transport pipe"
		desc = "An underfloor transport pipe."
		color = PIPEC_TRANSPORT

	mineral
		name = "mineral pipe"
		desc = "An underfloor mineral pipe."
		color = PIPEC_MINERAL

	cargo
		name = "cargo pipe"
		desc = "An underfloor cargo pipe."
		color = PIPEC_CARGO

	sewage // sewer
		name = "sewer pipe"
		desc = "... we have those?"
		color = PIPEC_SEWAGE

	New()
		..()
		if(icon_state == "pipe-s")
			dpdir = dir | turn(dir, 180)
		else
			dpdir = dir | turn(dir, -90)

		update()
		return

/obj/disposalpipe/segment/fix_sprite()
	if(turn(dir, 180) & dpdir)
		icon_state = "pipe-s"
	else
		icon_state = "pipe-c"
		for(var/d in list(1, 2, 4, 8))
			if((d | turn(d, -90)) == dpdir)
				set_dir(d)
				break
	base_icon_state = icon_state
	src.update()

//just a funey little guy who applies a mail label to your guy!
/obj/disposalpipe/labeller
	name = "mail labeller"
	desc = "an electronic disposal pipe that applies a small mail tag to passing detritus"
	icon_state = "pipe-mechsense"
	transfer(var/obj/disposalholder/H)
		H.mail_tag = src.mail_tag
		flick("pipe-mechsense-detect", src)
		return ..()

/obj/disposalpipe/segment/configurator // place this inside the main router, after all the collector junctions, and before all of the main group routers.
	name = "mail chute configurator"
	desc = "an electronic disposal pipe that dispenses little electronic tracking devices, permitting automatic mail router configuration"
	icon_state = "pipe-s-dir"

	New()
		..()
		dpdir = dir | turn(dir, 180)
		processing_items |= src
		update()

	proc/process()
		send_out_dat_fucken_packet()
		processing_items -= src

	transfer(var/obj/disposalholder/H)
		if(H.autoconfig == 1)// its one of our own little packets that made it all the way around. So we kill him.
			logTheThing("debug", src, null, "got a little guy back")
			qdel(H)
			return null
		if(H.autoconfig == 2)
			logTheThing("debug", src, null, "the journey begin's")
			H.autoconfig = 1 // the journey begin's
			SPAWN_DBG(60 SECONDS)
				call_mail_chute_configs()
		return ..()


	proc/send_out_dat_fucken_packet() // gonna make a fresh tracker holder and send it out to make trouble.
		logTheThing("debug", src, null, "sent out a little guy")
		for (var/obj/disposalpipe/switch_junction/SJ in world)
			logTheThing("debug", SJ, null, "deleting mail tags")
			SJ.mail_tag = list()

		var/obj/disposalholder/packet = new()
		packet.contents += new /obj/item/gnomechompski(packet)
		packet.autoconfig = 2
		packet.active = 1
		packet.set_dir(dir)
		packet.set_loc(src)
		SPAWN_DBG(0.1 SECONDS)
			packet.process()

	proc/call_mail_chute_configs()
		logTheThing("debug", src, null, "asking if anyone has seen my little guy")
		for (var/obj/machinery/disposal/mail/MB in world)
			MB.self_register()


//a three-way junction with dir being the dominant direction
/obj/disposalpipe/junction
	icon_state = "pipe-j1"

	left
		name = "pipe junction"
		icon_state = "pipe-j1"

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	right
		name = "pipe junction"
		icon_state = "pipe-j2"

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	middle
		name = "pipe junction"
		icon_state = "pipe-y"

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	New()
		..()
		if(icon_state == "pipe-j1")
			dpdir = dir | turn(dir, -90) | turn(dir,180)
		else if(icon_state == "pipe-j2")
			dpdir = dir | turn(dir, 90) | turn(dir,180)
		else // pipe-y
			dpdir = dir | turn(dir,90) | turn(dir, -90)
		update()
		return

	fix_sprite()
		if(dpdir == (dir | turn(dir, 90) | turn(dir, 180)))
			icon_state = "pipe-j2"
		else if(dpdir == (dir | turn(dir, -90) | turn(dir, 180)))
			icon_state = "pipe-j1"
		else if(dpdir == (dir | turn(dir, -90) | turn(dir, 90)))
			icon_state = "pipe-y"
		base_icon_state = icon_state
		src.update()

	// next direction to move
	// if coming in from secondary dirs, then next is primary dir
	// if coming in from primary dir, then next is equal chance of other dirs

	nextdir(var/fromdir)
		var/flipdir = turn(fromdir, 180)
		if(flipdir != dir)	// came from secondary dir
			return dir		// so exit through primary
		else				// came from primary
							// so need to choose either secondary exit
			var/mask = ..(fromdir)

			// find a bit which is set
			var/setbit = 0
			if(mask & NORTH)
				setbit = NORTH
			else if(mask & SOUTH)
				setbit = SOUTH
			else if(mask & EAST)
				setbit = EAST
			else
				setbit = WEST

			if(prob(50))	// 50% chance to choose the found bit or the other one
				return setbit
			else
				return mask & (~setbit)

//A junction capable of switching output direction
/obj/disposalpipe/switch_junction
	name = "switching pipe"
	icon_state = "pipe-sj1"

	var/redirect_chance = 50
	var/switch_dir = 0 //Direction of secondary port
					//Same-tag holders are sent out this one.

	left
		name = "mail junction"
		icon_state = "pipe-sj1"

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	right
		name = "mail junction"
		icon_state = "pipe-sj2"

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	New()
		..()
		if(icon_state == "pipe-sj1")
			switch_dir = turn(dir, -90)
			dpdir = dir | switch_dir | turn(dir,180)
		else if(icon_state == "pipe-sj2")
			switch_dir = turn(dir, 90)
			dpdir = dir | turn(dir, 90) | turn(dir,180)
		else
			switch_dir = turn(dir, 90)
			dpdir = dir | turn(dir,90) | turn(dir, -90)
		update()

		if (src.mail_tag)
			if (islist(src.mail_tag))
				src.name = "mail junction (multiple destinations)"
			else
				src.name = "mail junction ([src.mail_tag])"
				src.mail_tag = params2list(src.mail_tag)
		return


	// next direction to move

	transfer(var/obj/disposalholder/H)
		var/same_group = 0

		if(H.autoconfig == 1) // this is a configuration packet, let's make it get wierd.
			logTheThing("debug", src, null, "relayed a little guy")
			var/obj/disposalholder/dupe = H.dupe()
			if(!dupe.routers)
				dupe.routers = list()
			dupe.routers[src] = dupe.count  // we add ourselves to it's travel log so it can find its way home
			dupe.autoconfig = 2
			dupe.set_loc(src)
			SPAWN_DBG(2 SECONDS) // send a copy of this packet to this same router, but this time take the branch.
				dupe.process()

		if(H.autoconfig == 2) // that's it.
			H.autoconfig = 1
			same_group = 1 // one in, one out.


		if(src.mail_tag && (H.mail_tag in src.mail_tag))
			same_group = 1

		var/nextdir = nextdir(H.dir, same_group)
		H.set_dir(nextdir)
		var/turf/T = H.nextloc()
		var/obj/disposalpipe/P = H.findpipe(T)

		if(P)
			// find other holder in next loc, if inactive merge it with current
			var/obj/disposalholder/H2 = locate() in P
			if(H2 && !H2.active)
				H.merge(H2)

			H.set_loc(P)
		else			// if wasn't a pipe, then set loc to turf
			H.set_loc(T)
			return null

		return P

	nextdir(var/fromdir, var/use_secondary)
		var/flipdir = turn(fromdir, 180)
		if(flipdir != dir)	// came from secondary or tertiary
			var/senddir = dir	//Do we send this out the primary or secondary?
			if(use_secondary && flipdir != switch_dir) //Oh, we're set to sort this out our side secondary
				flick("[base_icon_state]-on", src)
				senddir = switch_dir
			return senddir
		else				// came from primary
							// so need to choose either secondary exit
			var/mask = ..(fromdir)

			// find a bit which is set
			var/setbit = 0
			if(mask & NORTH)
				setbit = NORTH
			else if(mask & SOUTH)
				setbit = SOUTH
			else if(mask & EAST)
				setbit = EAST
			else
				setbit = WEST

			if(prob(redirect_chance))	// Adjustable chance to choose the found bit or the other one
				return setbit
			else
				return mask & (~setbit)

/obj/disposalpipe/switch_junction/biofilter
	name = "biofilter pipe"
	desc = "A pipe junction designed to redirect living organic tissue."
	redirect_chance = 0

	left
		icon_state = "pipe-sj1"

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	right
		icon_state = "pipe-sj2"

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	transfer(var/obj/disposalholder/H)
		var/redirect = 0
		for (var/mob/living/carbon/C in H)
			if (!isdead(C))
				redirect = 1
				break

		var/nextdir = nextdir(H.dir, redirect)
		H.set_dir(nextdir)
		var/turf/T = H.nextloc()
		var/obj/disposalpipe/P = H.findpipe(T)

		if(P)
			// find other holder in next loc, if inactive merge it with current
			var/obj/disposalholder/H2 = locate() in P
			if(H2 && !H2.active)
				H.merge(H2)

			H.set_loc(P)
		else			// if wasn't a pipe, then set loc to turf
			H.set_loc(T)
			return null

		return P

	welded()

		var/obj/disposalconstruct/C = new (src.loc)
		C.ptype = (src.icon_state == "pipe-sj1" ? 8 : 9)
		C.set_dir(dir)
		C.mail_tag = src.mail_tag
		C.update()

		qdel(src)

/obj/disposalpipe/loafer
	name = "disciplinary loaf processor"
	desc = "A pipe segment designed to convert detritus into a nutritionally-complete meal for inmates."
	icon_state = "pipe-loaf0"
	mats = 100
	is_syndicate = 1
	var/is_doing_stuff = FALSE

	horizontal
		dir = EAST
	vertical
		dir = NORTH

	New()
		..()

		dpdir = dir | turn(dir, 180)
		update()

	was_built_from_frame(mob/user, newly_built)
		. = ..()
		dpdir = dir | turn(dir, 180)
		update()

	transfer(var/obj/disposalholder/H)
		while(src.is_doing_stuff)
			sleep(1 SECOND)
		src.is_doing_stuff = TRUE

		if (H.contents.len)
			playsound(src.loc, "sound/machines/mixer.ogg", 50, 1)
			//src.visible_message("<b>[src] activates!</b>") // Processor + loop = SPAM
			src.icon_state = "pipe-loaf1"

			var/doSuperLoaf = 0
			for (var/atom/movable/O in H)
				if(O.name == "strangelet loaf")
					doSuperLoaf = 1
					break

			if(doSuperLoaf)
				for (var/atom/movable/O2 in H)
					if(ismob(O2))
						var/mob/M = O2
						M.ghostize()
					qdel(O2)

				var/obj/item/reagent_containers/food/snacks/einstein_loaf/estein = new /obj/item/reagent_containers/food/snacks/einstein_loaf(src)
				estein.set_loc(H)
				goto StopLoafing


			var/obj/item/reagent_containers/food/snacks/prison_loaf/newLoaf = new /obj/item/reagent_containers/food/snacks/prison_loaf(src)
			for (var/atom/movable/newIngredient in H)

				LAGCHECK(LAG_MED)



				if (newIngredient.reagents)
					newIngredient.reagents.trans_to(newLoaf, 1000)

				if (istype(newIngredient, /obj/item/reagent_containers/food/snacks/prison_loaf))
					var/obj/item/reagent_containers/food/snacks/prison_loaf/otherLoaf = newIngredient
					newLoaf.loaf_factor += otherLoaf.loaf_factor * 1.2
					newLoaf.loaf_recursion = otherLoaf.loaf_recursion + 1
					otherLoaf = null

				else if (isliving(newIngredient))
					playsound(src.loc, pick("sound/impact_sounds/Slimy_Splat_1.ogg","sound/impact_sounds/Liquid_Slosh_1.ogg","sound/impact_sounds/Wood_Hit_1.ogg","sound/impact_sounds/Slimy_Hit_3.ogg","sound/impact_sounds/Slimy_Hit_4.ogg","sound/impact_sounds/Flesh_Stab_1.ogg"), 50, 1)
					var/mob/living/poorSoul = newIngredient
					if (issilicon(poorSoul))
						newLoaf.reagents.add_reagent("oil",10)
						newLoaf.reagents.add_reagent("silicon",10)
						newLoaf.reagents.add_reagent("iron",10)
					else
						newLoaf.reagents.add_reagent("bloodc",10) // heh
						newLoaf.reagents.add_reagent("ectoplasm",10)

					if(ishuman(newIngredient))
						newLoaf.loaf_factor += (newLoaf.loaf_factor / 5) + 50 // good god this is a weird value
					else
						newLoaf.loaf_factor += (newLoaf.loaf_factor / 10) + 50
					if(!isdead(poorSoul))
						poorSoul:emote("scream")
					sleep(0.5 SECONDS)
					poorSoul.death()
					if (poorSoul.mind || poorSoul.client)
						poorSoul.ghostize()
				else if (isitem(newIngredient))
					var/obj/item/I = newIngredient
					newLoaf.loaf_factor += I.w_class * 5
					I = null
				else
					newLoaf.loaf_factor++

				H.contents -= newIngredient
				newIngredient.set_loc(null)
				newIngredient = null

				//LAGCHECK(LAG_MED)
				qdel(newIngredient)

			newLoaf.update()
			newLoaf.set_loc(H)

			StopLoafing:

			sleep(0.3 SECONDS)	//make a bunch of ongoing noise i guess?
			playsound(src.loc, pick("sound/machines/mixer.ogg","sound/machines/mixer.ogg","sound/machines/mixer.ogg","sound/machines/hiss.ogg","sound/machines/ding.ogg","sound/machines/buzz-sigh.ogg","sound/impact_sounds/Machinery_Break_1.ogg","sound/effects/pop.ogg","sound/machines/warning-buzzer.ogg","sound/impact_sounds/Glass_Shatter_1.ogg","sound/impact_sounds/Flesh_Break_2.ogg","sound/effects/spring.ogg","sound/machines/engine_grump1.ogg","sound/machines/engine_grump2.ogg","sound/machines/engine_grump3.ogg","sound/impact_sounds/Glass_Hit_1.ogg","sound/effects/bubbles.ogg","sound/effects/brrp.ogg"), 50, 1)
			sleep(0.3 SECONDS)

			playsound(src.loc, "sound/machines/engine_grump1.ogg", 50, 1)
			sleep(3 SECONDS)
			src.icon_state = "pipe-loaf0"
			//src.visible_message("<b>[src] deactivates!</b>") // Processor + loop = SPAM

		var/nextdir = nextdir(H.dir)
		H.set_dir(nextdir)
		var/turf/T = H.nextloc()
		var/obj/disposalpipe/P = H.findpipe(T)

		src.is_doing_stuff = FALSE

		if(P)
			// find other holder in next loc, if inactive merge it with current
			var/obj/disposalholder/H2 = locate() in P
			if(H2 && !H2.active)
				H.merge(H2)

			H.set_loc(P)
		else			// if wasn't a pipe, then set loc to turf
			H.set_loc(T)
			return null

		return P

	welded()
		return //can't let them unweld the loafer
	update()
		..()
		src.name = initial(src.name)

#define MAXIMUM_LOAF_STATE_VALUE 10

/obj/item/reagent_containers/food/snacks/einstein_loaf
	name = "einstein-rosen loaf"
	desc = "A hypothetical feature of loaf-spacetime. Maybe this could be used as a material?"
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "eloaf"
	force = 0
	throwforce = 0
	initial_volume = 1000

	New()
		..()
		src.reagents.add_reagent("liquid spacetime",11)
		src.setMaterial(getMaterial("negativematter"), appearance = 0, setname = 0)

/obj/item/reagent_containers/food/snacks/prison_loaf
	name = "prison loaf"
	desc = "A rather slapdash loaf designed to feed prisoners.  Technically nutritionally complete and edible in the same sense that potted meat product is edible."
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "ploaf0"
	force = 0
	throwforce = 0
	initial_volume = 1000
	var/loaf_factor = 1
	var/loaf_recursion = 1
	var/processing = 0
	var/orderOfLoafitude = 1

	New()
		..()
		src.reagents.add_reagent("gravy",10)
		src.reagents.add_reagent("refried_beans",10)
		src.reagents.add_reagent("fakecheese",10)
		src.reagents.add_reagent("silicate",10)
		src.reagents.add_reagent("space_fungus",3)
		src.reagents.add_reagent("synthflesh",10)
		START_TRACKING
		event_handler_flags |= IS_LOAF

	disposing()
		. = ..()
		STOP_TRACKING

	proc/update()
		orderOfLoafitude = max( 0, min( floor( log(8, loaf_factor)), MAXIMUM_LOAF_STATE_VALUE ) )
		//src.icon_state = "ploaf[orderOfLoafitude]"

		src.w_class = min(orderOfLoafitude+1, 4)

		switch ( orderOfLoafitude )

			if (1)
				src.name = "prison loaf"
				src.desc = "A rather slapdash loaf designed to feed prisoners.  Technically nutritionally complete and edible in the same sense that potted meat product is edible."
				src.icon_state = "ploaf0"
				src.force = 0
				src.throwforce = 0

			if (2)
				src.name = "dense prison loaf"
				src.desc = "The chef must be really packing a lot of junk into these things today."
				src.icon_state = "ploaf0"
				src.force = 3
				src.throwforce = 3
				src.reagents.add_reagent("beff",25)

			if (3)
				src.name = "extra dense prison loaf"
				src.desc = "Good lord, this thing feels almost like a brick. A brick made of kitchen scraps and god knows what else."
				src.icon_state = "ploaf0"
				src.force = 6
				src.throwforce = 6
				src.reagents.add_reagent("porktonium",25)

			if (4)
				src.name = "super-compressed prison loaf"
				src.desc = "Hard enough to scratch a diamond, yet still somehow edible, this loaf seems to be emitting decay heat. Dear god."
				src.icon_state = "ploaf1"
				src.force = 11
				src.throwforce = 11
				src.throw_range = 6
				src.reagents.add_reagent("thalmerite",25)

			if (5)
				src.name = "fissile loaf"
				src.desc = "There's so much junk packed into this loaf, the flavor atoms are starting to go fissile. This might make a decent engine fuel, but it definitely wouldn't be good for you to eat."
				src.icon_state = "ploaf2"
				src.force = 22
				src.throwforce = 22
				src.throw_range = 5
				src.reagents.add_reagent("uranium",25)

			if (6)
				src.name = "fusion loaf"
				src.desc = "Forget fission, the flavor atoms in this loaf are so densely packed now that they are undergoing atomic fusion. What terrifying new flavor atoms might lurk within?"
				src.icon_state = "ploaf3"
				src.force = 44
				src.throwforce = 44
				src.throw_range = 4
				src.reagents.add_reagent("radium",25)

			if (7)
				src.name = "neutron loaf"
				src.desc = "Oh good, the flavor atoms in this prison loaf have collapsed down to a a solid lump of neutrons."
				src.icon_state = "ploaf4"
				src.force = 66
				src.throwforce = 66
				src.throw_range = 3
				src.reagents.add_reagent("polonium",25)

			if (8)
				src.name = "quark loaf"
				src.desc = "This nutritional loaf is collapsing into subatomic flavor particles. It is unfathmomably heavy."
				src.icon_state = "ploaf5"
				src.force = 88
				src.throwforce = 88
				src.throw_range = 2
				src.reagents.add_reagent("rainbow_melonium",25)

			if (9)
				src.name = "degenerate loaf"
				src.desc = "You should probably call a physicist."
				src.icon_state = "ploaf6"
				src.force = 110
				src.throwforce = 110
				src.throw_range = 1
				src.reagents.add_reagent("rainbow_melonium",50)

			if (10)
				src.name = "strangelet loaf"
				src.desc = "You should probably call a priest."
				src.icon_state = "ploaf7"
				src.force = 220
				src.throwforce = 220
				src.throw_range = 0
				src.reagents.add_reagent("rainbow_melonium",100)

				if (!src.processing)
					src.processing = 1

				/*SPAWN_DBG(rand(100,1000))
					if(src)
						src.visible_message("<span class='alert'><b>[src] collapses into a black hole! Holy fuck!</b></span>")
						world << sound("sound/effects/kaboom.ogg")
						new /obj/bhole(get_turf(src.loc))*/


		return

	process()
		if(!src.processing)
			return
		if(src.loc == get_turf(src))
			var/edge = get_edge_target_turf(src, pick(alldirs))
			src.throw_at(edge, 100, 1)
		if (istype(src.loc,/obj/))
			if (prob(33))
				var/obj/container = src.loc
				container.visible_message("<span class='alert'><b>[container]</b> emits a loud thump and rattles a bit.</span>")
				if (istype(container, /obj/storage) && prob(33))
					var/obj/storage/C = container
					if (C.can_flip_bust == 1)
						boutput(src, "<span class='alert'>[C] [pick("cracks","bends","shakes","groans")].</span>")
						C.bust_out()

	attackby(obj/item/W, mob/user)
		if(istool(W,TOOL_SPOONING))
			boutput(user, "You scoop the dense crumb out of [src], making an attractive pair of loafers.")
			var/turf/T = get_turf(src)
			T.fluid_react(src.reagents, src.reagents.total_volume) // why not
			new /obj/item/clothing/shoes/loaf(T, order = src.orderOfLoafitude)
			user.u_equip(src)
			qdel(src)
		else
			..()



#undef MAXIMUM_LOAF_STATE_VALUE

/obj/disposalpipe/mechanics_switch
	icon_state = "pipe-mech0"
	var/active = 0
	var/switch_dir = 0

	north
		dir = NORTH
	east
		dir = EAST
	south
		dir = SOUTH
	west
		dir = WEST

	New()
		..()

		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"toggle", "toggleactivation")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"on", "activate")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"off", "deactivate")

		SPAWN_DBG(1 SECOND)
			switch_dir = turn(dir, 90)
			dpdir = dir | switch_dir | turn(dir,180)

		update()

	nextdir(var/fromdir)
		//var/flipdir = turn(fromdir, 180)
		if(fromdir & turn(switch_dir, 180))	// came in the wrong way
			return dpdir & (prob(50) ? dir : turn(dir, 180))//turn(switch_dir, prob(50) ? -90 : 90)

		else
			if (active)
				return switch_dir

			else
				return fromdir

	updateicon()
		icon_state = "pipe-mech[active]"//[invisibility ? "f" : null]"
		alpha = invisibility ? 128 : 255
		return

	proc/toggleactivation()
		src.active = !src.active
		updateicon()

	proc/activate()
		src.active = 1
		updateicon()

	proc/deactivate()
		src.active = 0
		updateicon()

	welded()
		var/obj/disposalconstruct/C = new (src.loc)
		C.ptype = 11
		C.set_dir(dir)
		C.update()
		qdel(src)

//<Jewel>:
//Tried to rework biofilter to create a new disposalholder and send bio one way and normal objects the other. It doesn't work.
//Check back on the pipe code later. It needs some kinda revamp in the future.

/*/obj/disposalpipe/switch_junction/biofilter
	name = "biofilter pipe"
	desc = "A pipe junction designed to redirect living organic tissue."
	redirect_chance = 0

	var/obj/disposalholder/bioHolder = new()

	transfer(var/obj/disposalholder/origHolder)
		for (var/mob/living/carbon/C in origHolder)
			if (!isdead(C))
				C.set_loc(bioHolder)

		var/otherdir = nextdir(origHolder.dir, 0)
		var/biodir = nextdir(origHolder.dir, 1)

		origHolder.set_dir(otherdir)
		bioHolder.set_dir(biodir)

		var/turf/nonBioTurf = origHolder.nextloc()
		var/turf/bioTurf = bioHolder.nextloc()

		var/obj/disposalpipe/nonBioPipe = origHolder.findpipe(nonBioTurf)
		var/obj/disposalpipe/bioPipe = bioHolder.findpipe(bioTurf)

		if (nonBioPipe)
			var/obj/disposalholder/newHolder = locate() in nonBioPipe
			if(newHolder && !newHolder.active)
				origHolder.merge(newHolder)

			origHolder.set_loc(nonBioPipe)

			boutput(world, "I found a non bio pipe at [nonBioPipe.loc] with [origHolder.loc]")

		if (bioPipe)
			var/obj/disposalholder/newHolderBio = locate() in bioPipe
			if (newHolderBio && !newHolderBio.active)
				bioHolder.merge(newHolderBio)

			bioHolder.set_loc(bioPipe)

			boutput(world, "I found a bio pipe at [bioPipe.loc] with [bioHolder.loc]")

		bioHolder.active = 1
		bioHolder.set_dir(biodir)
		SPAWN_DBG(1 DECI SECOND)
			bioHolder.process()

		return nonBioPipe

	welded()
		var/obj/disposalconstruct/C = new (src.loc)
		C.ptype = (src.icon_state == "pipe-sj1" ? 8 : 9)
		C.set_dir(dir)
		C.mail_tag = src.mail_tag
		C.update()

		qdel(src)*/

/obj/disposalpipe/block_sensing_outlet
	name = "smart disposal outlet"
	desc = "A disposal outlet with a little sonar sensor on the front, so it only dumps contents if it is unblocked."
	icon_state = "unblockoutlet"
	anchored = 1
	density = 1
	var/turf/stuff_chucking_target

	north
		dir = NORTH
	east
		dir = EAST
	south
		dir = SOUTH
	west
		dir = WEST

	New()
		..()

		dpdir = dir | turn(dir, 270) | turn(dir, 90)
		SPAWN_DBG(0.1 SECONDS)
			stuff_chucking_target = get_ranged_target_turf(src, dir, 1)

	welded()
		return

	transfer(var/obj/disposalholder/H)
		var/allowDump = 1

		for (var/atom/movable/blockingJerk in get_step(src, src.dir))
			if (blockingJerk.density)
				allowDump = 0
				break

		if (allowDump)
			flick("unblockoutlet-open", src)
			playsound(src, "sound/machines/warning-buzzer.ogg", 50, 0, 0)

			sleep(2 SECONDS)	//wait until correct animation frame
			playsound(src, "sound/machines/hiss.ogg", 50, 0, 0)


			for(var/atom/movable/AM in H)
				AM.set_loc(src.loc)
				AM.pipe_eject(dir)
				AM.throw_at(stuff_chucking_target, 3, 1)
			H.vent_gas(src.loc)
			qdel(H)

			return null

		var/turf/T = H.nextloc()
		var/obj/disposalpipe/P = H.findpipe(T)

		if(P)
			// find other holder in next loc, if inactive merge it with current
			var/obj/disposalholder/H2 = locate() in P
			if(H2 && !H2.active)
				H.merge(H2)

			H.set_loc(P)
		else			// if wasn't a pipe, then set loc to turf
			H.set_loc(T)
			return null

		return P

/obj/disposalpipe/type_sensing_outlet
	name = "filter disposal outlet"
	desc = "A disposal outlet with a little sensor in it, to allow it to filter out unwanted things from the system."
	icon_state = "unblockoutlet"
	var/turf/stuff_chucking_target
	var/list/allowed_types = list()

	north
		dir = NORTH
	east
		dir = EAST
	south
		dir = SOUTH
	west
		dir = WEST

	New()
		..()

		dpdir = dir | turn(dir, 270) | turn(dir, 90)
		SPAWN_DBG(0.1 SECONDS)
			stuff_chucking_target = get_ranged_target_turf(src, dir, 1)

	welded()
		return

	transfer(var/obj/disposalholder/H)
		var/list/things_to_dump = list()

		for (var/atom/movable/A in H)
			var/dump_this = 1
			for (var/thing in src.allowed_types)
				if (ispath(thing) && istype(A, thing))
					dump_this = 0
					break
			if (dump_this)
				things_to_dump += A

		if (things_to_dump.len)
			flick("unblockoutlet-open", src)
			playsound(src, "sound/machines/warning-buzzer.ogg", 50, 0, 0)

			sleep(2 SECONDS)	//wait until correct animation frame
			playsound(src, "sound/machines/hiss.ogg", 50, 0, 0)

			for (var/atom/movable/AM in things_to_dump)
				AM.set_loc(src.loc)
				AM.pipe_eject(dir)
				AM.throw_at(stuff_chucking_target, 3, 1)
			if (H.contents.len < 1)
				H.vent_gas(src.loc)
				qdel(H)
				return null

		var/turf/T = H.nextloc()
		var/obj/disposalpipe/P = H.findpipe(T)

		if(P)
			// find other holder in next loc, if inactive merge it with current
			var/obj/disposalholder/H2 = locate() in P
			if(H2 && !H2.active)
				H.merge(H2)

			H.set_loc(P)
		else			// if wasn't a pipe, then set loc to turf
			H.set_loc(T)
			return null

		return P

/obj/disposalpipe/type_sensing_outlet/drone_factory
	allowed_types = list(/obj/item/ghostdrone_assembly)

#define SENSE_LIVING 1
#define SENSE_OBJECT 2
#define SENSE_TAG 3

/obj/disposalpipe/mechanics_sensor
	name = "Sensor pipe"
	icon_state = "pipe-mechsense"
	var/sense_mode = SENSE_OBJECT
	var/sense_tag_filter = ""

	horizontal
		dir = EAST
	vertical
		dir = NORTH

	New()
		..()

		AddComponent(/datum/component/mechanics_holder)

		dpdir = dir | turn(dir, 180)

		update()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			. = alert(user, "What should trigger the sensor?","Disposal Sensor", "Creatures", "Anything", "A mail tag")
			if (.)
				if (get_dist(user, src) > 1 || user.stat)
					return

				switch (.)
					if ("Creatures")
						sense_mode = SENSE_LIVING

					if ("Anything")
						sense_mode = SENSE_OBJECT

					if ("A mail tag")
						. = copytext(ckeyEx(input(user, "What should the tag be?", "What?")), 1, 33)
						if (. && get_dist(user, src) < 2 && !user.stat)
							sense_mode = SENSE_TAG
							sense_tag_filter = .

	MouseDrop(obj/O, null, var/src_location, var/control_orig, var/control_new, var/params)

		if(!isliving(usr))
			return

		if(istype(O, /obj/item/mechanics) && O.level == 2)
			boutput(usr, "<span class='alert'>[O] needs to be secured into place before it can be connected.</span>")
			return

		if(usr.stat)
			return

		if (!usr.find_tool_in_hand(TOOL_PULSING))
			boutput(usr, "<span class='alert'>[MECHFAILSTRING]</span>")
			return

		SEND_SIGNAL(src,_COMSIG_MECHCOMP_DROPCONNECT,O,usr)
		return ..()

	transfer(var/obj/disposalholder/H)
		if (sense_mode == SENSE_TAG)
			if (cmptext(H.mail_tag, sense_tag_filter))
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,ckey(H.mail_tag))
				flick("pipe-mechsense-detect", src)

		else if (sense_mode == SENSE_OBJECT)
			if (H.contents.len)
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"1")
				flick("pipe-mechsense-detect", src)

		else
			for (var/atom/aThing in H)
				if (sense_mode == SENSE_LIVING)
					if (istype(aThing, /obj/critter) || isliving(aThing))
						if (isliving(aThing))
							var/mob/living/M = aThing
							if (isdead(M))
								continue

						SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"1")
						flick("pipe-mechsense-detect", src)
						break

		return ..()

	welded()
		var/obj/disposalconstruct/C = new (src.loc)
		C.ptype = 12
		C.set_dir(dir)
		C.update()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_RM_ALL_CONNECTIONS)
		qdel(src)

#undef SENSE_LIVING
#undef SENSE_OBJECT
#undef SENSE_TAG

//a trunk joining to a disposal bin or outlet on the same turf
/obj/disposalpipe/trunk
	var/target_z
	var/id
	icon_state = "pipe-t"
	var/obj/linked 	// the linked obj/machinery/disposal or obj/disposaloutlet

	north
		dir = NORTH
	east
		dir = EAST
	south
		dir = SOUTH
	west
		dir = WEST

	mail
		name = "mail pipe"
		desc = "An underfloor mail pipe."
		color = PIPEC_MAIL

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	brig
		name = "brig pipe"
		desc = "An underfloor brig pipe."
		color = PIPEC_BRIG

	ejection
		name = "ejection pipe"
		desc = "An underfloor ejection pipe."
		color = PIPEC_EJECTION

	morgue
		name = "morgue pipe"
		desc = "An underfloor morgue pipe."
		color = PIPEC_MORGUE

	quarantine
		name = "quarantine pipe"
		desc = "An underfloor quarantine pipe."
		color = PIPEC_QUARANTINE

	genetics
		name = "genetics pipe"
		desc = "An underfloor genetics pipe, for dead people."
		color = PIPEC_GENETICS

	crematorium
		name = "crematorium pipe"
		desc = "An underfloor crematorium pipe, for dead people."
		color = PIPEC_CREMATORIUM

	food
		name = "food pipe"
		desc = "An underfloor food pipe."
		color = PIPEC_FOOD

	produce
		name = "produce pipe"
		desc = "An underfloor produce pipe."
		color = PIPEC_PRODUCE

	transport
		name = "transport pipe"
		desc = "An underfloor transport pipe."
		color = PIPEC_TRANSPORT

	mineral
		name = "mineral pipe"
		desc = "An underfloor mineral pipe."
		color = PIPEC_MINERAL

	sewage // sewer
		name = "sewer pipe"
		desc = "... we have those?"
		color = PIPEC_SEWAGE

	New()
		..()
		dpdir = dir
		src.event_handler_flags |= USE_HASENTERED
		SPAWN_DBG(1 DECI SECOND)
			getlinked()


		update()
		return

	HasEntered(atom/movable/AM, atom/OldLoc)
		..()
		if(target_z || linked)
			return
		var/turf/T = get_turf(src)
		if(T.intact)
			return // this trunk is not exposed
		if(ismob(AM))
			var/mob/schmuck = AM
			if ((schmuck.stat || schmuck.getStatusDuration("weakened")) && prob(50) || prob(10))
				src.visible_message("[AM] falls down the pipe trunk.")
				random_brute_damage(schmuck, 10)
				schmuck.show_text("You fall down the pipe trunk!", "red")
				schmuck.changeStatus("weakened", 3 SECONDS)
				#ifdef DATALOGGER
				game_stats.Increment("workplacesafety")
				#endif

				var/obj/disposalholder/D = new (src)
				D.set_loc(src)

				AM.set_loc(D)

				//flush time
				if(ishuman(AM))
					var/mob/living/carbon/human/H = AM
					H.unlock_medal("Gay Luigi?", 1)

				//D.start() wants a disposal unit
				D.active = 1
				D.set_dir(DOWN)
				D.process()



	disposing()
		if (linked && istype(linked, /obj/machinery/disposal))
			var/obj/machinery/disposal/D = linked
			D.trunk = null
			D = null
		linked = null
		..()

	proc/getlinked()
		linked = null
		var/obj/machinery/disposal/D = locate() in src.loc
		if(D)
			linked = D

		var/obj/disposaloutlet/O = locate() in src.loc
		if(O)
			linked = O

		update()
		return

	// would transfer to next pipe segment, but we are in a trunk
	// if not entering from disposal bin,
	// transfer to linked object (outlet or bin)

	transfer(var/obj/disposalholder/H)

		if(H.dir == DOWN)		// we just entered from a disposer
			return ..()		// so do base transfer proc
		// otherwise, go to the linked object
		if(linked)
			var/obj/disposaloutlet/O = linked
			if(istype(O))
				O.expel(H)	// expel at outlet
			else
				var/obj/machinery/disposal/D = linked
				D.expel(H)	// expel at disposal
		else
			src.expel(H, src.loc, 0)	// expel at turf
		return null

	// nextdir

	nextdir(var/fromdir)
		if(fromdir == DOWN)
			return dir
		else
			return 0

/obj/disposalpipe/trunk/zlevel

	name = "vertical disposal trunk"
	desc = "a section of vertical riser."
	icon_state = "pipe-vt"
	//color = "#FAF"

	New()
		..()
		START_TRACKING
		if(src.z > target_z)
			icon_state = "pipe-t"
			new /obj/structure/girder/riser(src.loc) //gotta go up!

	disposing()
		STOP_TRACKING
		. = ..()

	getlinked()
		return

	transfer(var/obj/disposalholder/H)
		if(H.dir == DOWN)		// we just entered from a disposer
			return ..()		// so do base transfer proc

		// otherwise, go to the linked object
		var/turf/T
		var/obj/disposalpipe/P
		if(target_z)
			T = get_turf(locate(src.x,src.y,target_z))
			P = locate(/obj/disposalpipe/trunk) in T
		else
			for_by_tcl(pipe, /obj/disposalpipe/trunk/zlevel)
				if(pipe.id == id && src != pipe)
					P = pipe
					break

		if(P)
			H.set_dir(DOWN)
			// find other holder in next loc, if inactive merge it with current
			var/obj/disposalholder/H2 = locate() in P
			if(H2 && !H2.active)
				H.merge(H2)

			H.set_loc(P)
		else			// if wasn't a pipe, then set loc to turf
			H.set_loc(T)
			return null

		return P

// a broken pipe
/obj/disposalpipe/broken
	icon_state = "pipe-b"
	dpdir = 0		// broken pipes have dpdir=0 so they're not found as 'real' pipes
					// i.e. will be treated as an empty turf
	desc = "A broken piece of disposal pipe."

	New()
		..()
		update()
		return

	// called when welded
	// for broken pipe, remove and turn into scrap

	welded()
		var/obj/item/scrap/S = new(src.loc)
		S.set_components(200,0,0)
		qdel(src)

// the disposal outlet machine

/obj/disposaloutlet
	name = "disposal outlet"
	desc = "An outlet for the pneumatic disposal system."
	icon = 'icons/obj/machines/disposal.dmi'
	icon_state = "outlet"
	density = 1
	anchored = 1
	var/active = 0
	var/turf/target	// this will be where the output objects are 'thrown' to.
	mats = 12
	var/range = 10

	var/message = null
	var/mailgroup = null
	var/mailgroup2 = null //Do not refactor into a list, maps override these properties
	var/net_id = null
	var/frequency = FREQ_PDA
	var/datum/radio_frequency/radio_connection
	throw_speed = 1

	ex_act(var/severity)
		switch(severity)
			if(OLD_EX_SEVERITY_1)
				qdel(src)
			if(OLD_EX_SEVERITY_2)
				if(prob(50))
					qdel(src)
			if(OLD_EX_SEVERITY_3)
				if(prob(25))
					qdel(src)

	small
		icon = 'icons/obj/machines/disposal_small.dmi'
		density = 0

	north
		dir = NORTH
	east
		dir = EAST
	south
		dir = SOUTH
	west
		dir = WEST

	New()
		..()

		SPAWN_DBG(1 DECI SECOND)
			target = get_ranged_target_turf(src, dir, range)
		SPAWN_DBG(0.8 SECONDS)
			if(radio_controller)
				radio_connection = radio_controller.add_object(src, "[frequency]")
			if(!src.net_id)
				src.net_id = generate_net_id(src)

	disposing()
		var/obj/disposalpipe/trunk/trunk = locate() in src.loc
		if (trunk && trunk.linked == src)
			trunk.linked = null
		trunk = null

		radio_controller.remove_object(src, "[frequency]")
		..()

	// expel the contents of the holder object, then delete it
	// called when the holder exits the outlet
	proc/expel(var/obj/disposalholder/H)
		if (message && (mailgroup || mailgroup2) && radio_connection)
			var/groups = list()
			if (mailgroup)
				groups += mailgroup
			if (mailgroup2)
				groups += mailgroup2
			groups += MGA_MAIL

			var/datum/signal/newsignal = get_free_signal()
			newsignal.source = src
			newsignal.transmission_method = TRANSMISSION_RADIO
			newsignal.data["command"] = "text_message"
			newsignal.data["sender_name"] = "CHUTE-MAILBOT"
			newsignal.data["message"] = "[message]"
			newsignal.data["address_1"] = "00000000"
			newsignal.data["group"] = groups
			newsignal.data["sender"] = src.net_id

			radio_connection.post_signal(src, newsignal)

		flick("outlet-open", src)
		playsound(src, "sound/machines/warning-buzzer.ogg", 50, 0, 0)

		sleep(2 SECONDS)	//wait until correct animation frame
		playsound(src, "sound/machines/hiss.ogg", 50, 0, 0)


		for(var/atom/movable/AM in H)
			AM.set_loc(src.loc)
			AM.pipe_eject(dir)
			AM.throw_at(target, src.throw_range, src.throw_speed)
		H.vent_gas(src.loc)
		qdel(H)

		return

// called when movable is expelled from a disposal pipe or outlet
// by default does nothing, override for special behaviour

/atom/movable/proc/pipe_eject(var/direction)
	return

// check if mob has client, if so restore client view on eject
/mob/pipe_eject(var/direction)
	src.changeStatus("weakened", 2 SECONDS)
	return

/obj/decal/cleanable/tracked_reagents/blood/gibs/pipe_eject(var/direction)
	var/list/dirs
	if(direction in cardinal)
		dirs = direction
	else
		dirs = cardinal.Copy()

	src.streak_cleanable(dirs)

/obj/decal/cleanable/robot_debris/gib/pipe_eject(var/direction)
	var/list/dirs
	if(direction in cardinal)
		dirs = direction
	else
		dirs = cardinal.Copy()

	src.streak_cleanable(dirs)


/obj/disposaloutlet/random_range
	var/min_range = 1
	var/max_range = 6
	expel(obj/disposalholder/H)
		src.throw_range = rand(min_range, max_range)
		. = ..()

/obj/disposaloutlet/artifact
	throw_range = 10
	throw_speed = 10

// -------------------- VR --------------------
/obj/disposaloutlet/virtual
	name = "gauntlet outlet"
	desc = "For disposing of pixel junk, one would suppose."
	icon = 'icons/effects/VR.dmi'
// --------------------------------------------

// takes a pipe and changes one of its disconnected directions to new_dir, or makes a junction if all are connected and make_junctions=1
proc/pipe_reconnect_disconnected(var/obj/disposalpipe/pipe, var/new_dir, var/make_junctions=0)
	var/list/avail_dirs = pipe.disconnected_dirs()
	for(var/x in avail_dirs)
	if(!avail_dirs.len && !(new_dir & pipe.dpdir))
		if(!make_junctions)
			return
		if(istype(pipe, /obj/disposalpipe/trunk))
			var/obj/disposalpipe/segment/segment = new(pipe.loc)
			segment.dpdir = pipe.dpdir | new_dir
			segment.set_dir(new_dir)
			qdel(pipe)
			segment.fix_sprite()
		else if(istype(pipe, /obj/disposalpipe/junction))
			var/obj/disposalpipe/segment/horiz = new(pipe.loc)
			horiz.dpdir = 1 | 2
			horiz.set_dir(1)
			horiz.fix_sprite()
			var/obj/disposalpipe/segment/vert = new(pipe.loc)
			vert.dpdir = 4 | 8
			vert.set_dir(4)
			vert.fix_sprite()
			qdel(pipe)
		if(istype(pipe, /obj/disposalpipe/segment))
			var/obj/disposalpipe/junction/junction = new(pipe.loc)
			junction.dpdir = pipe.dpdir | new_dir
			junction.set_dir(new_dir)
			qdel(pipe)
			junction.fix_sprite()
		return
	else if(!(new_dir & pipe.dpdir))
		for(var/d in list(new_dir, turn(new_dir, 90), turn(new_dir, 270), turn(new_dir, 180)))
			if(d in avail_dirs)
				pipe.dpdir &= ~d
				pipe.dpdir |= new_dir
				if(!(pipe.dir & pipe.dpdir)) // if we lost our dir
					pipe.set_dir(new_dir)
				break
	pipe.fix_sprite()
