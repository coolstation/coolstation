// Disposal pipe construction

/obj/disposalconstruct

	name = "disposal pipe segment"
	desc = "A huge pipe segment used for constructing disposal systems."
	icon = 'icons/obj/machines/disposal.dmi'
	icon_state = "conpipe-s"
	anchored = UNANCHORED
	density = 0
	pressure_resistance = 5*ONE_ATMOSPHERE
	m_amt = 1850
	level = 2
	var/ptype = 0
	// 0=straight, 1=bent, 2=junction-j1, 3=junction-j2, 4=junction-y, 5=trunk, 6 & 7=switching junction, 8 & 9=mob filter junction, 10 = loafer, 11 = mechanics controlled junction

	var/dpdir = 0	// directions as disposalpipe
	var/base_state = "pipe-s"
	var/mail_tag = null //For pipes that use mail filtering
	var/filter_type = null //For pipes that filter objects passing through.

	// update iconstate and dpdir due to dir and type
	proc/update()
		var/flip = turn(dir, 180)
		var/left = turn(dir, 90)
		var/right = turn(dir, -90)

		switch(ptype)
			if(0)
				base_state = "pipe-s"
				dpdir = dir | flip
			if(1)
				base_state = "pipe-c"
				dpdir = dir | right
			if(2)
				base_state = "pipe-j1"
				dpdir = dir | right | flip
			if(3)
				base_state = "pipe-j2"
				dpdir = dir | left | flip
			if(4)
				base_state = "pipe-y"
				dpdir = dir | left | right
			if(5)
				base_state = "pipe-t"
				dpdir = dir
			if(6,8)
				base_state = "pipe-sj1"
				dpdir = dir
			if(7,9)
				base_state = "pipe-sj2"
				dpdir = dir
			if(10)
				base_state = "pipe-loaf0"
				dpdir = dir
			if(11)
				base_state = "pipe-mech"
				dpdir = dir | left | flip
			if(12)
				base_state = "pipe-mechsense"
				dpdir = dir | flip


		icon_state = "con[base_state]"

		if(invisibility)				// if invisible, fade icon
			icon -= rgb(0,0,0,128)

	// hide called by levelupdate if turf intact status changes
	// change visibility status and force update of icon
	hide(var/intact)
		invisibility = (intact && level==1) ? 101: 0	// hide if floor is intact
		update()

	// returns the type path of disposalpipe corresponding to this item dtype
	proc/dpipetype()
		switch(ptype)
			if(0,1)
				return /obj/disposalpipe/segment
			if(2,3,4)
				return /obj/disposalpipe/junction
			if(5)
				return /obj/disposalpipe/trunk
			if(6,7)
				return /obj/disposalpipe/switch_junction
			if(8,9)
				return /obj/disposalpipe/switch_junction/biofilter
			if(10)
				return /obj/disposalpipe/loafer
			if(11)
				return /obj/disposalpipe/mechanics_switch
			if(12)
				return /obj/disposalpipe/mechanics_sensor
		return

	// click the junction with empty hand to change direction
	attack_hand(mob/user)
		if(!anchored)
			if(ptype == 2)
				ptype = 3
				set_dir(turn(dir, 180))
				boutput(user, "You change the pipe junction's direction.")
			else if (ptype == 3)
				ptype = 2
				set_dir(turn(dir, 180))
				boutput(user, "You change the pipe junction's direction.")
			update()

	// attackby item
	// crowbar: rotate
	// screwdriver: disassemble
	// wrench: (un)anchor
	// weldingtool: convert to real pipe

	attackby(var/obj/item/I, var/mob/user)
		if(ispryingtool(I) && !anchored)
			set_dir(turn(dir, -90))
			update()
			return

		if(isscrewingtool(I))
			boutput(user, "You take the pipe segment apart.")
			// var/obj/item/sheet/A = new /obj/item/sheet(get_turf(src))
			// if(src.material)
			// 	A.setMaterial(src.material)
			// else
			// 	var/datum/material/M = getMaterial("steel")
			// 	A.setMaterial(M)
			qdel(src)
			return

		var/turf/T = src.loc
		if(T.intact && (iswrenchingtool(I) || isweldingtool(I))) //to stop it from screaming about it when rotating the pipe with crowbar
			boutput(user, "You can only attach the pipe if the floor plating is removed.")
			return

		var/obj/disposalpipe/CP = locate() in T
		if(CP)
			update()
			var/pdir = CP.dpdir
			if(istype(CP, /obj/disposalpipe/broken))
				pdir = CP.dir
			if((pdir & dpdir) && (iswrenchingtool(I) || isweldingtool(I))) //see the comment above
				boutput(user, "There is already a pipe at that location.")
				return

		if (iswrenchingtool(I))
			if(anchored)
				anchored = UNANCHORED
				level = 2
				set_density(1)
				boutput(user, "You detach the pipe from the underfloor.")
			else
				anchored = ANCHORED
				level = 1
				set_density(0)
				boutput(user, "You attach the pipe to the underfloor.")
			playsound(src.loc, "sound/items/Ratchet.ogg", 100, 1)

		else if(isweldingtool(I))
			if(I:try_weld(user, 2, noisy = 2))
				// check if anything changed over 2 seconds
				var/turf/uloc = user.loc
				var/atom/wloc = I.loc
				var/turf/ploc = loc
				boutput(user, "You begin welding [src] in place.")
				sleep(0.1 SECONDS)
				if(user.loc == uloc && wloc == I.loc)
					// REALLY? YOU DON'T FUCKING CARE ABOUT THE LOCATION OF THE PIPE? GET FUCKED <CODER>
					if (ploc != loc)
						boutput(user, "<span class='alert'>As you try to weld the pipe to a completely different floor than it was originally placed on it breaks!</span>")
						ploc = loc
						SPAWN_DBG(0)
							robogibs(ploc)
							//if (isrestrictedz(ploc.z))
								//explosion_new(src, ploc, 3) // okay yes we don't need to explode people for this
						qdel(src)
						return
					update()
					var/pipetype = dpipetype()
					var/obj/disposalpipe/P = new pipetype(src.loc)
					P.base_icon_state = base_state
					P.set_dir(dir)
					P.dpdir = dpdir
					P.mail_tag = mail_tag
					P.updateicon()
					boutput(user, "You weld [P] in place.")

					qdel(src)
				else
					boutput(user, "You must stay still while welding.")
					return

/obj/disposalconstruct/mechanics
	name = "controlled pipe junction"
	ptype = 11
	base_state = "pipe-mech"
	icon_state = "conpipe-mech"

/obj/disposalconstruct/mechanics_sensor
	name = "sensor pipe"
	ptype = 12
	base_state = "pipe-mechsense"
	icon_state = "pipe-mechsense"


//Why was this in a random file for an ancient atmos pipe project?
/obj/machinery/disposal_pipedispenser
	name = "Disposal Pipe Dispenser"
	icon = 'icons/obj/machines/manufacturer.dmi'
	icon_state = "fab"
	density = 1
	anchored = ANCHORED
	mats = 16
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS

/obj/machinery/disposal_pipedispenser/attack_hand(mob/user as mob)
	if(..())
		return

	var/dat = {"<b>Disposal Pipes</b><br><br>
<A href='byond://?src=\ref[src];dmake=0'>Pipe</A><BR>
<A href='byond://?src=\ref[src];dmake=1'>Bent Pipe</A><BR>
<A href='byond://?src=\ref[src];dmake=2'>Junction</A><BR>
<A href='byond://?src=\ref[src];dmake=3'>Y-Junction</A><BR>
<A href='byond://?src=\ref[src];dmake=4'>Trunk</A><BR>
"}

	user.Browse("<HEAD><TITLE>Disposal Pipe Dispenser</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	return

// 0=straight, 1=bent, 2=junction-j1, 3=junction-j2, 4=junction-y, 5=trunk


/obj/machinery/disposal_pipedispenser/Topic(href, href_list)
	if(..())
		return
	src.add_dialog(usr)
	src.add_fingerprint(usr)
	if(href_list["dmake"])
		var/p_type = text2num(href_list["dmake"])
		var/obj/disposalconstruct/C = new (src.loc)
		switch(p_type)
			if(0)
				C.ptype = 0
			if(1)
				C.ptype = 1
			if(2)
				C.ptype = 2
			if(3)
				C.ptype = 4
			if(4)
				C.ptype = 5

		C.update()

		usr.Browse(null, "window=pipedispenser")
		src.remove_dialog(usr)
	return

/obj/machinery/disposal_pipedispenser/mobile
	name = "disposal pipe dispenser cart"
	desc = "A tool for removing some of the tedium from pipe-laying."
	anchored = UNANCHORED
	icon_state = "fab-mobile"
	mats = 16
	var/laying_pipe = 0
	var/removing_pipe = 0
	var/prev_dir = 0
	var/first_step = 0

	Move(var/turf/new_loc,direction)
		var/old_loc = loc
		. = ..()
		if(!(direction in cardinal)) // cardinal sin
			return
		if(old_loc != loc)
			if(src.laying_pipe)
				src.lay_pipe(old_loc, prev_dir, direction)
				src.connect_pipe(new_loc, turn(direction, 180))
			else if(src.removing_pipe)
				if(!new_loc.intact)
					for(var/obj/disposalpipe/pipe in old_loc)
						if (istype(pipe, /obj/disposalpipe/loafer)) continue //I guess
						qdel(pipe)
			prev_dir = direction // might want to actually do this even when old_loc == loc but idk, it sucks with attempted diagonal movement

	proc/connect_pipe(var/turf/new_loc, var/new_dir)
		var/free_dirs = 1 | 2 | 4 | 8
		var/obj/disposalpipe/pipe = null
		var/obj/disposalpipe/backup_pipe = null
		var/obj/disposalpipe/backup_backup_pipe = null
		for(var/obj/disposalpipe/D in new_loc)
			var/list/avail_dirs = D.disconnected_dirs()
			free_dirs &= ~D.dpdir
			if(istype(D, /obj/disposalpipe/trunk)) // don't wanna mess with those, they are important
				continue
			else if(avail_dirs.len >= 2)
				backup_pipe = D
			else if(avail_dirs.len == 0)
				backup_backup_pipe = D
		if(!pipe)
			pipe = backup_pipe
		if(!pipe)
			pipe = backup_backup_pipe
		if(!pipe)
			return
		if(new_dir & free_dirs)
			pipe_reconnect_disconnected(pipe, new_dir, 1)

	// look I didn't want to duplicate all this code either, I'm sorry :(
	proc/lay_pipe(var/turf/new_loc, var/old_dir, var/new_dir)
		var/is_first = src.first_step
		src.first_step = 0

		if(new_loc.intact)
			return

		var/obj/disposalpipe/junction/junction = locate(/obj/disposalpipe/junction) in new_loc
		if(junction)
			if(new_dir & junction.dpdir)
				junction.set_dir(new_dir)
				junction.fix_sprite()
				return

		var/free_dirs = 1 | 2 | 4 | 8
		var/obj/disposalpipe/new_pipe = null
		var/obj/disposalpipe/backup_pipe = null
		var/obj/disposalpipe/backup_backup_pipe = null
		for(var/obj/disposalpipe/D in new_loc)
			var/list/avail_dirs = D.disconnected_dirs()
			free_dirs &= ~D.dpdir
			if(istype(D, /obj/disposalpipe/trunk)) // don't wanna mess with those, they are important
				continue
			else if(avail_dirs.len == 1)
				new_pipe = D
				break
			else if(avail_dirs.len >= 2)
				backup_pipe = D
			else if(avail_dirs.len == 0)
				backup_backup_pipe = D
		if(!new_pipe)
			new_pipe = backup_pipe
		if(!new_pipe)
			new_pipe = backup_backup_pipe
		if(!new_pipe && is_first)
			new_pipe = new/obj/disposalpipe/trunk(new_loc)
			new_pipe.set_dir(new_dir)
			new_pipe.dpdir = new_pipe.dir
			var/obj/disposalpipe/trunk/trunk = new_pipe
			trunk.getlinked()
			return
		else if(!new_pipe)
			var/new_pipe_dirs = new_dir | turn(old_dir, 180)
			if(new_pipe_dirs == new_dir) // if we back up
				new_pipe_dirs |= turn(new_dir, 180)
			if((new_pipe_dirs & free_dirs) != new_pipe_dirs) // subset of free dirs
				return
			new_pipe = new/obj/disposalpipe/segment(new_loc)
			new_pipe.set_dir(new_dir)
			new_pipe.dpdir = new_pipe_dirs

		if(new_dir & free_dirs)
			pipe_reconnect_disconnected(new_pipe, new_dir, 1)

	Topic(href, href_list)
		src.add_dialog(usr)
		src.add_fingerprint(usr)
		if(href_list["toggle_laying"])
			src.removing_pipe = 0
			src.laying_pipe = !(src.laying_pipe)
			if(src.laying_pipe)
				src.first_step = 1
				src.color = "#bbffbb"
			else
				src.color = "#ffffff"
				var/final_dir = turn(src.dir, 180)
				var/obj/disposalpipe/pipe = locate(/obj/disposalpipe/segment) in src.loc
				if(istype(pipe))
					var/list/disc_dirs = pipe.disconnected_dirs()
					final_dir = pipe.dpdir
					for(var/d in disc_dirs)
						final_dir &= ~d
				if(final_dir in cardinal)
					if(istype(pipe))
						qdel(pipe)
					var/obj/disposalpipe/trunk/trunk = new(src.loc)
					trunk.set_dir(final_dir)
					trunk.dpdir = trunk.dir
					trunk.getlinked()
			src.Attackhand(usr)
			return
		else if(href_list["toggle_removing"])
			src.laying_pipe = 0
			src.removing_pipe = !(src.removing_pipe)
			if(src.removing_pipe)
				src.color = "#ffbbbb"
			else
				src.color = "#ffffff"
			src.Attackhand(usr)
			return
		else if(href_list["dmake"])
			var/p_type = text2num(href_list["dmake"])
			var/obj/disposalconstruct/C = new (src.loc)
			switch(p_type)
				if(0)
					C.ptype = 0
				if(1)
					C.ptype = 1
				if(2)
					C.ptype = 2
				if(3)
					C.ptype = 4
				if(4)
					C.ptype = 5

			C.update()

			usr << browse(null, "window=pipedispenser")
			src.remove_dialog(usr)
		return

/obj/machinery/disposal_pipedispenser/mobile/attack_hand(user as mob)
	var/startstop_lay = (src.laying_pipe ? "Stop" : "Start")
	var/startstop_remove = (src.removing_pipe ? "Stop" : "Start")
	var/dat = {"<b>Disposal Pipes</b><br><br>
<A href='byond://?src=\ref[src];dmake=0'>Pipe</A><BR>
<A href='byond://?src=\ref[src];dmake=1'>Bent Pipe</A><BR>
<A href='byond://?src=\ref[src];dmake=2'>Junction</A><BR>
<A href='byond://?src=\ref[src];dmake=3'>Y-Junction</A><BR>
<A href='byond://?src=\ref[src];dmake=4'>Trunk</A><BR>
<BR>
<A href='byond://?src=\ref[src];toggle_laying=1'>[startstop_lay] Laying Pipe Automatically</A><BR>
<A href='byond://?src=\ref[src];toggle_removing=1'>[startstop_remove] Removing Pipe Automatically</A><BR>
"}

	user << browse("<HEAD><TITLE>Disposal Pipe Dispenser</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	return

// 0=straight, 1=bent, 2=junction-j1, 3=junction-j2, 4=junction-y, 5=trunk

