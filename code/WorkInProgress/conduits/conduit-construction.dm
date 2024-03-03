// Conduit construction

/obj/conduitconstruct

	name = "conduit segment"
	desc = "A huge superconducting conduit segment used for directing power from generation sources to SMES power substations."
	icon = 'icons/obj/machines/power_cond.dmi'
	icon_state = "conduit-straight"
	anchored = 0
	density = 0
	level = 2
	var/ctype = 0
	// 0=straight, 1=bent, 2=junction, 3=all-way, 4=tap, 5=trunk, 6=switch

	var/cddir = 0	// directions as conduit
	var/base_state = "conduit-segment"

	// update iconstate and cddir due to dir and type
	proc/update()
		var/flip = turn(dir, 180)
		var/left = turn(dir, 90)
		var/right = turn(dir, -90)

		switch(ctype)
			if(0)
				base_state = "conduit-s"
				cddir = dir | flip
			if(1)
				base_state = "conduit-c"
				cddir = dir | right
			if(2)
				base_state = "conduit-j"
				cddir = dir | right | flip
			if(3)
				base_state = "conduit-a"
				cddir = dir | left | flip
			if(4)
				base_state = "conduit-tap"
				cddir = dir | left | right
			if(5)
				base_state = "conduit-t"
				cddir = dir
			if(6)
				base_state = "conduit-sw"
				cddir = dir


		icon_state = "con[base_state]"

		if(invisibility)				// if invisible, fade icon
			icon -= rgb(0,0,0,128)

	// hide called by levelupdate if turf intact status changes
	// change visibility status and force update of icon
	hide(var/intact)
		invisibility = (intact && level==1) ? 101: 0	// hide if floor is intact
		update()

	// returns the type path of conduit corresponding to this item dtype
	proc/conduittype()
		switch(ctype)
			if(0,1)
				return /obj/cable/conduit/segment
			if(2)
				return /obj/cable/conduit/junction
			if(3)
				return /obj/cable/conduit/allway
			if(4)
				return /obj/cable/conduit/tap
			if(5)
				return /obj/cable/conduit/trunk
			if(6)
				return /obj/cable/conduit/switcher
		return

	// attackby item
	// crowbar: rotate
	// screwdriver: disassemble
	// wrench: (un)anchor
	// weldingtool: deploy conduit in place

	attackby(var/obj/item/I, var/mob/user)
		if(ispryingtool(I) && !anchored)
			set_dir(turn(dir, -90))
			update()
			return

		if(isscrewingtool(I))
			boutput(user, "You take the conduit apart.")
			// var/obj/item/sheet/A = new /obj/item/sheet(get_turf(src))
			// if(src.material)
			// 	A.setMaterial(src.material)
			// else
			// 	var/datum/material/M = getMaterial("steel")
			// 	A.setMaterial(M)
			//  Take a look at the above and see if there are any cables or a new assembly we can make from a dismantled conduit for handheld use
			qdel(src)
			return

		var/turf/T = src.loc
		if(T.intact && (iswrenchingtool(I) || isweldingtool(I))) //to stop it from screaming about it when rotating the conduit with crowbar
			boutput(user, "You can only attach the conduit if the floor plating is removed.")
			return

		var/obj/cable/conduit/CP = locate() in T
		if(CP)
			update()
			var/pdir = CP.cddir
			if((pdir & cddir) && (iswrenchingtool(I) || isweldingtool(I))) //see the comment above
				boutput(user, "There is already a conduit at that location.")
				return

		if (iswrenchingtool(I))
			if(anchored)
				anchored = 0
				level = 2
				set_density(1)
				boutput(user, "You detach the conduit from the underfloor.")
			else
				anchored = 1
				level = 1
				set_density(0)
				boutput(user, "You attach the conduit to the underfloor.")
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
					// REALLY? YOU DON'T FUCKING CARE ABOUT THE LOCATION OF THE CONDUIT? GET FUCKED <CODER>
					if (ploc != loc)
						boutput(user, "<span class='alert'>As you try to weld the conduit to a completely different floor than it was originally placed on it breaks!</span>")
						ploc = loc
						SPAWN_DBG(0)
							robogibs(ploc)
							//if (isrestrictedz(ploc.z))
								//explosion_new(src, ploc, 3) // okay yes we don't need to explode people for this
						qdel(src)
						return
					update()
					var/conduittype = conduittype()
					var/obj/cable/conduit/P = new conduittype(src.loc)
					P.base_icon_state = base_state
					P.set_dir(dir)
					P.cddir = cddir
					P.updateicon()
					boutput(user, "You weld [P] in place.")

					qdel(src)
				else
					boutput(user, "You must stay still while welding.")
					return
