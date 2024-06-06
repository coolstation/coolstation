/obj/machinery/conduit_dispenser
	name = "Conduit Dispenser"
	icon = 'icons/obj/machines/manufacturer.dmi'
	icon_state = "fab"
	density = 1
	anchored = 1.0
	mats = 16
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS

/obj/machinery/conduit_dispenser/attack_hand(mob/user as mob)
	if(..())
		return

	var/dat = {"<b>Conduits</b><br><br>
<A href='byond://?src=\ref[src];dmake=0'>Straight</A><BR>
<A href='byond://?src=\ref[src];dmake=1'>Bent</A><BR>
<A href='byond://?src=\ref[src];dmake=2'>Three-way Junction</A><BR>
<A href='byond://?src=\ref[src];dmake=3'>All-way Junction</A><BR>
<A href='byond://?src=\ref[src];dmake=4'>Tap</A><BR>
<A href='byond://?src=\ref[src];dmake=5'>Trunk</A><BR>
<A href='byond://?src=\ref[src];dmake=6'>Switch</A><BR>
"}

	user.Browse("<HEAD><TITLE>Conduit Dispenser</TITLE></HEAD><TT>[dat]</TT>", "window=conduitdispenser")
	return

// 0=straight, 1=bent, 2=junction-3, 3=junction-all, 4=tap, 5=trunk, 6=switch


/obj/machinery/conduitdispenser/Topic(href, href_list)
	if(..())
		return
	src.add_dialog(usr)
	src.add_fingerprint(usr)
	if(href_list["dmake"])
		var/c_type = text2num(href_list["dmake"])
		var/obj/conduitconstruct/C = new (src.loc)
//		C.ctype = c_type //probably not
		switch(c_type)
			if(0)
				C.ctype = 0
			if(1)
				C.ctype = 1
			if(2)
				C.ctype = 2
			if(3)
				C.ctype = 3
			if(4)
				C.ctype = 4
			if(5)
				C.ctype = 5
			if(6)
				C.ctype = 6 //yes this is silly but i'll come back and see if this switch case can be removed

		C.update()

		usr.Browse(null, "window=conduitdispenser")
		src.remove_dialog(usr)
	return

/obj/machinery/conduitdispenser/mobile
	name = "Conduit Dispenser Cart"
	desc = "A tool for removing some of the tedium from conduit-laying."
	anchored = 0
	icon_state = "fab-mobile"
	mats = 16
	var/laying_conduit = 0
	var/removing_conduit = 0
	var/prev_dir = 0
	var/first_step = 0

	Move(var/turf/new_loc,direction)
		var/old_loc = loc
		. = ..()
		if(!(direction in cardinal)) // cardinal sin
			return
		if(old_loc != loc)
			if(src.laying_conduit)
				src.lay_conduit(old_loc, prev_dir, direction)
				src.connect_conduit(new_loc, turn(direction, 180))
			else if(src.removing_conduit)
				if(!new_loc.intact || istype(new_loc,/turf/space))
					for(var/obj/cable/conduit/conduit in old_loc)
						qdel(conduit)
			prev_dir = direction // might want to actually do this even when old_loc == loc but idk, it sucks with attempted diagonal movement

	proc/connect_conduit(var/turf/new_loc, var/new_dir)
		var/free_dirs = 1 | 2 | 4 | 8
		var/obj/cable/conduit/conduit = null
		var/obj/cable/conduit/backup_conduit = null
		var/obj/cable/conduit/backup_backup_conduit = null
		for(var/obj//cable/conduit/D in new_loc)
			var/list/avail_dirs = D.disconnected_dirs()
			free_dirs &= ~D.dpdir
			if(istype(D, /obj/cable/conduit/trunk)) // don't wanna mess with those, they are important
				continue
			if(istype(D, /obj/cable/conduit/tap)) // don't wanna mess with those, they are also important (can i do an or statement? i am a skunk i am not good with cod)
				continue
			else if(avail_dirs.len >= 2)
				backup_conduit = D
			else if(avail_dirs.len == 0)
				backup_backup_conduit = D
		if(!conduit)
			conduit = backup_conduit
		if(!conduit)
			conduit = backup_backup_conduit
		if(!conduit)
			return
		if(new_dir & free_dirs)
			conduit_reconnect_disconnected(conduit, new_dir, 1)

	// look I didn't want to duplicate all this code either, I'm sorry :(
	proc/lay_conduit(var/turf/new_loc, var/old_dir, var/new_dir)
		var/is_first = src.first_step
		src.first_step = 0

		if(new_loc.intact && !istype(new_loc,/turf/space))
			return

		var/obj/cable/conduit/junction/junction = locate(/obj/cable/conduit/junction) in new_loc
		if(junction)
			if(new_dir & junction.dpdir)
				junction.set_dir(new_dir)
				junction.fix_sprite()
				return

		var/free_dirs = 1 | 2 | 4 | 8
		var/obj/cable/conduit/new_conduit = null
		var/obj/cable/conduit/backup_conduit = null
		var/obj/cable/conduit/backup_backup_conduit = null
		for(var/obj/cable/conduit/D in new_loc)
			var/list/avail_dirs = D.disconnected_dirs()
			free_dirs &= ~D.dpdir
			if(istype(D, /obj/cable/conduit/trunk)) // don't wanna mess with those, they are important
				continue
			else if(avail_dirs.len == 1)
				new_conduit = D
				break
			else if(avail_dirs.len >= 2)
				backup_conduit = D
			else if(avail_dirs.len == 0)
				backup_backup_conduit = D
		if(!new_conduit)
			new_conduit = backup_conduit
		if(!new_conduit)
			new_conduit = backup_backup_conduit
		if(!new_conduit && is_first)
			new_conduit = new/obj/cable/conduit/trunk(new_loc)
			new_conduit.set_dir(new_dir)
			new_conduit.dpdir = new_conduit.dir
			var/obj/cable/conduit/trunk/trunk = new_conduit
			trunk.getlinked()
			return
		else if(!new_conduit)
			var/new_conduit_dirs = new_dir | turn(old_dir, 180)
			if(new_conduit_dirs == new_dir) // if we back up
				new_conduit_dirs |= turn(new_dir, 180)
			if((new_conduit_dirs & free_dirs) != new_conduit_dirs) // subset of free dirs
				return
			new_conduit = new/obj/cable/conduit/segment(new_loc)
			new_conduit.set_dir(new_dir)
			new_conduit.dpdir = new_conduit_dirs

		if(new_dir & free_dirs)
			conduit_reconnect_disconnected(new_conduit, new_dir, 1)

	Topic(href, href_list)
		src.add_dialog(usr)
		src.add_fingerprint(usr)
		if(href_list["toggle_laying"])
			src.removing_conduit = 0
			src.laying_conduit = !(src.laying_conduit)
			if(src.laying_conduit)
				src.first_step = 1
				src.color = "#bbffbb"
			else
				src.color = "#ffffff"
				var/final_dir = turn(src.dir, 180)
				var/obj/cable/conduit/conduit = locate(/obj/cable/conduit/segment) in src.loc
				if(istype(conduit))
					var/list/disc_dirs = conduit.disconnected_dirs()
					final_dir = conduit.dpdir
					for(var/d in disc_dirs)
						final_dir &= ~d
				if(final_dir in cardinal)
					if(istype(conduit))
						qdel(conduit)
					var/obj/cable/conduit/trunk/trunk = new(src.loc)
					trunk.set_dir(final_dir)
					trunk.dpdir = trunk.dir
					trunk.getlinked()
			src.Attackhand(usr)
			return
		else if(href_list["toggle_removing"])
			src.laying_conduit = 0
			src.removing_conduit = !(src.removing_conduit)
			if(src.removing_conduit)
				src.color = "#ffbbbb"
			else
				src.color = "#ffffff"
			src.Attackhand(usr)
			return
		else if(href_list["dmake"])
			var/c_type = text2num(href_list["dmake"])
			var/obj/disposalconstruct/C = new (src.loc)
			// C.ctype = c_type
			switch(c_type)
				if(0)
					C.ctype = 0
				if(1)
					C.ctype = 1
				if(2)
					C.ctype = 2
				if(3)
					C.ctype = 4
				if(4)
					C.ctype = 5 //silly switch case again

			C.update()

			usr << browse(null, "window=conduitdispenser")
			src.remove_dialog(usr)
		return

/obj/machinery/conduit_dispenser/mobile/attack_hand(user as mob)
	var/startstop_lay = (src.laying_conduit ? "Stop" : "Start")
	var/startstop_remove = (src.removing_conduit ? "Stop" : "Start")
	var/dat = {"<b>Conduits</b><br><br>
<A href='byond://?src=\ref[src];dmake=0'>Conduit</A><BR>
<A href='byond://?src=\ref[src];dmake=1'>Bent Conduit</A><BR>
<A href='byond://?src=\ref[src];dmake=2'>Three-way Junction</A><BR>
<A href='byond://?src=\ref[src];dmake=3'>All-way Junction</A><BR>
<A href='byond://?src=\ref[src];dmake=4'>Tap</A><BR>
<A href='byond://?src=\ref[src];dmake=5'>Trunk</A><BR>
<A href='byond://?src=\ref[src];dmake=6'>Switched</A><BR>
<BR>
<A href='byond://?src=\ref[src];toggle_laying=1'>[startstop_lay] Laying Conduit Automatically</A><BR>
<A href='byond://?src=\ref[src];toggle_removing=1'>[startstop_remove] Removing Conduit Automatically</A><BR>
"}

	user << browse("<HEAD><TITLE>Conduit Dispenser</TITLE></HEAD><TT>[dat]</TT>", "window=conduitdispenser")
	return

// 0=straight, 1=bent, 2=junction-3, 3=junction-all, 4=tap, 5=trunk, 6=switch

