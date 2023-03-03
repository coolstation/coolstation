// Conduit construction

/obj/conduitparts

	name = "conduit segment"
	desc = "A huge superconducting conduit segment used for directing power from generation sources to SMES power substations."
	icon = 'icons/obj/power_cond.dmi'
	icon_state = "conduit-large-d"
	anchored = 0
	density = 0
	level = 2
	w_class = W_CLASS_BULKY
	var/conduit_type = "/obj/cable/conduit/"
	var/bendable = 1
	var/bent = 0

	//shit's heavy. two handed.

	/trunk
		icon_state = "conduit-large-d-trunk"
		conduit_type = "/obj/cable/conduit/trunk"
		bendable = 0
	/tap
		icon_state = "conduit-large-d-tap"
		conduit_type = "/obj/cable/conduit/tap"
		bendable = 0
	/tee
		icon_state = "conduit-large-d-tee"
		conduit_type = "/obj/cable/conduit/tee"
		bendable = 0
	/allway
		icon_state = "conduit-large-d-all"
		conduit_type = "/obj/cable/conduit/allway"
		bendable = 0
	/switcher
		icon_state = "conduit-large-d-sw"
		conduit_type = "/obj/cable/conduit/switcher"
		bendable = 0

	proc/toggle_bend(mob/living/user as mob)
		//should fix any possible weirdness too
		if (src.bent)
			if (src.dir in ordinal)
				src.dir = (turn(src.dir,-45))
				src.bent = 0
			else
				src.bent = 0
		else
			if (src.dir in cardinal)
				src.dir = (turn(src.dir,45))
				src.bent = 1
			else
				src.bent = 1
		if (user)
			boutput(user, "<b>[user]</b> [src.bent ? "straightens" : "bends"] [src].")
		src.bent = !(src.bent)
		playsound(src, "sound/effects/valve_creak.ogg", 50, 1)
		return

	// attackself: menu to bend or rotate
	attackself()
		if(src.bendable)
			src.toggle_bend()
		else
			turn(src.dir,90)

	attackby(var/obj/item/I, var/mob/user)

		if(ispryingtool(I)) //rotation
			set_dir(turn(dir, -90))
			return

		if(isscrewingtool(I)) //deconstruction
			boutput(user, "You take the conduit apart. Or you would. Probably.")
			// new /obj/item/reinforcedcablesnippet(src.loc) //8 worth (4*2 on a tile) (must be claretine)
			// new /obj/item/reinforcedcablesnippet(src.loc)
			// new /obj/item/reinforcedcablesnippet(src.loc)
			// new /obj/item/reinforcedcablesnippet(src.loc)
			// new /obj/item/rods (2)
			//qdel(src)
			return

		if (iswrenchingtool(I)) //installation
			var/turf/T = src.loc
			if(T.intact)
				boutput(user, "You can only attach the conduit if the floor plating is removed.")
				return
			var/obj/cable/conduit/C = locate() in T
				if(C)
					update()
					var/pdir = C.cddir
					if((pdir & cddir) && (iswrenchingtool(I) || isweldingtool(I))) //see the comment above
						boutput(user, "There is already a conduit at that location.")
						return
				if(anchored)
					anchored = 0
					level = 2
					boutput(user, "You detach the conduit from the underfloor.")
				else
					anchored = 1
					level = 1
					boutput(user, "You attach the conduit to the underfloor.")
					var/obj/cable/conduit/P = new conduit_type(src.loc)
					P.dir = src.dir
				playsound(src.loc, "sound/items/Ratchet.ogg", 75, 1)

		else ..()
