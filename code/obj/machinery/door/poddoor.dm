/obj/machinery/door/poddoor
	name = "podlock"
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = "pdoor1"
	icon_base = "pdoor"
	cant_emag = 1
	layer = 2.8
	object_flags = 0

	health = 1800
	health_max = 1800

	var/close_sound = "sound/machines/blast_door_1.ogg"
	var/open_sound = "sound/machines/hydraulic.ogg"

	var/id = 1.0

	New()
		. = ..()
		START_TRACKING
		close_sound = "sound/machines/blast_door_[rand(1,9)].ogg" // variety

	disposing()
		. = ..()
		STOP_TRACKING

/obj/machinery/door/poddoor/blast/single
	icon_state = "bdoorsingle1"

/obj/machinery/door/poddoor/shutters
	icon_state = "shutter1"
	icon_base = "shutter"
	layer = 5

/obj/machinery/door/poddoor/shutters/left
	icon_state = "shutterleft1"
	icon_base = "shutterleft"

/obj/machinery/door/poddoor/shutters/right
	icon_state = "shutterright1"
	icon_base = "shutterright"

/obj/machinery/door/poddoor/shutters/center
	icon_state = "shuttercenter1"
	icon_base = "shuttercenter"

/obj/machinery/door/poddoor/buff/staging
	name = "Staging Area"
	desc = "This door neatly separates the setup area from the spectator booths."
	icon = 'icons/effects/VR.dmi'

	New()
		..()
		SPAWN_DBG(5 SECONDS)
			open()

	Bump()
		return

	attack_hand()
		return

	attackby()
		return

/obj/machinery/door/poddoor/buff/gauntlet
	name = "The Gauntlet"
	desc = "This door guards the passage out of the gauntlet. It will not open while there are live players inside."
	icon = 'icons/effects/VR.dmi'

	Bump()
		return

	attack_hand()
		return

	attackby()
		return

/obj/machinery/door/poddoor/pyro
	icon = 'icons/obj/doors/SL_doors.dmi'
	icon_state = "pdoor1"
	icon_base = "pdoor"
	flags = FPRINT | IS_PERSPECTIVE_FLUID | ALWAYS_SOLID_FLUID

	// Please keep synchronizied with these lists for easy map changes:
	// /obj/machinery/door_control (door_control.dm)
	// /obj/machinery/r_door_control (door_control.dm)
	// /obj/machinery/door/poddoor/blast/pyro (poddoor.dm)
	// /obj/warp_beacon (warp_travel.dm)
	podbay_autoclose
		autoclose = 1

		wizard_horizontal
			name = "external blast door"
			id = "hangar_wizard"
			dir = NORTH

			vertical
				dir = EAST

		syndicate_horizontal
			name = "external blast door"
			id = "hangar_syndicate"
			dir = NORTH

			vertical
				dir = EAST

		catering_horizontal
			name = "pod bay (catering)"
			id = "hangar_catering"
			dir = NORTH

			vertical
				dir = EAST

		arrivals_horizontal
			name = "pod bay (arrivals)"
			id = "hangar_arrivals"
			dir = NORTH

			vertical
				dir = EAST

		escape_horizontal
			name = "pod bay (escape hallway)"
			id = "hangar_escape"
			dir = NORTH

			vertical
				dir = EAST

		mainpod1_horizontal
			name = "pod bay (main hangar #1)"
			id = "hangar_podbay1"
			dir = NORTH

			vertical
				dir = EAST

		mainpod2_horizontal
			name = "pod bay (main hangar #2)"
			id = "hangar_podbay2"
			dir = NORTH

			vertical
				dir = EAST

		engineering_horizontal
			name = "pod bay (engineering)"
			id = "hangar_engineering"
			dir = NORTH

			vertical
				dir = EAST

		security_horizontal
			name = "pod bay (security)"
			id = "hangar_security"
			dir = NORTH

			vertical
				dir = EAST

		medsci_horizontal
			name = "pod bay (medsci)"
			id = "hangar_medsci"
			dir = NORTH

			vertical
				dir = EAST

		research_horizontal
			name = "pod bay (research)"
			id = "hangar_research"
			dir = NORTH

			vertical
				dir = EAST

		medbay_horizontal
			name = "pod bay (medbay)"
			id = "hangar_medbay"
			dir = NORTH

			vertical
				dir = EAST

		qm_horizontal
			name = "pod bay (cargo bay)"
			id = "hangar_qm"
			dir = NORTH

			vertical
				dir = EAST

		mining_horizontal
			name = "pod bay (mining)"
			id = "hangar_mining"
			dir = NORTH

			vertical
				dir = EAST

		miningoutpost_horizontal
			name = "pod bay (mining outpost)"
			id = "hangar_miningoutpost"
			dir = NORTH

			vertical
				dir = EAST

		diner1_horizontal
			name = "pod bay (space diner #1)"
			id = "hangar_spacediner1"
			dir = NORTH

			vertical
				dir = EAST

		diner2_horizontal
			name = "pod bay (space diner #2)"
			id = "hangar_spacediner2"
			dir = NORTH

			vertical
				dir = EAST

		soviet_horizontal
			name = "pod bay (salyut)"
			id = "hangar_soviet"
			dir = NORTH

			vertical
				dir = EAST
		t1d1_horizontal
			name = "pod bay (team1door1)"
			id = "hangar_t1d1"
			dir = NORTH

			vertical
				dir = EAST

		t1d2_horizontal
			name = "pod bay (team1door2)"
			id = "hangar_t1d2"
			dir = NORTH

			vertical
				dir = EAST

		t1d3_horizontal
			name = "pod bay (team1door3)"
			id = "hangar_t1d3"
			dir = NORTH

			vertical
				dir = EAST

		t1d4_horizontal
			name = "pod bay (team1door4)"
			id = "hangar_t1d4"
			dir = NORTH

			vertical
				dir = EAST

		t2d1_horizontal
			name = "pod bay (team2door1)"
			id = "hangar_t2d1"
			dir = NORTH

			vertical
				dir = EAST

		t2d2_horizontal
			name = "pod bay (team2door2)"
			id = "hangar_t2d2"
			dir = NORTH

			vertical
				dir = EAST

		t2d3_horizontal
			name = "pod bay (team2door3)"
			id = "hangar_t2d3"
			dir = NORTH

			vertical
				dir = EAST

		t2d4_horizontal
			name = "pod bay (team2door4)"
			id = "hangar_t2d4"
			dir = NORTH

			vertical
				dir = EAST
		t1d1_horizontal
			name = "pod bay (team1door1)"
			id = "hangar_t1d1"
			dir = NORTH

			vertical
				dir = EAST

		t1d2_horizontal
			name = "pod bay (team1door2)"
			id = "hangar_t1d2"
			dir = NORTH

			vertical
				dir = EAST

		t1d3_horizontal
			name = "pod bay (team1door3)"
			id = "hangar_t1d3"
			dir = NORTH

			vertical
				dir = EAST

		t1d4_horizontal
			name = "pod bay (team1door4)"
			id = "hangar_t1d4"
			dir = NORTH

			vertical
				dir = EAST

		t1condoor_horizontal
			name = "pod bay (team1 construction door)"
			id = "hangar_t1condoor"
			dir = NORTH

			vertical
				dir = EAST

		t2d1_horizontal
			name = "pod bay (team2door1)"
			id = "hangar_t2d1"
			dir = NORTH

			vertical
				dir = EAST

		t2d2_horizontal
			name = "pod bay (team2door2)"
			id = "hangar_t2d2"
			dir = NORTH

			vertical
				dir = EAST

		t2d3_horizontal
			name = "pod bay (team2door3)"
			id = "hangar_t2d3"
			dir = NORTH

			vertical
				dir = EAST

		t2d4_horizontal
			name = "pod bay (team2door4)"
			id = "hangar_t2d4"
			dir = NORTH

			vertical
				dir = EAST

		t2condoor_horizontal
			name = "pod bay (team2 construction door)"
			id = "hangar_t2condoor"
			dir = NORTH

			vertical
				dir = EAST

/obj/machinery/door/poddoor/blast/pyro
	icon = 'icons/obj/doors/SL_doors.dmi'
	icon_state = "bdoorsingle1"

	// Please keep synchronizied with these lists for easy map changes:
	// /obj/machinery/door_control (door_control.dm)
	// /obj/machinery/r_door_control (door_control.dm)
	// /obj/machinery/door/poddoor/pyro (poddoor.dm)
	// /obj/warp_beacon (warp_travel.dm)
	podbay_autoclose
		autoclose = 1
		icon_state = "bdoormid1"


		wizard_horizontal
			name = "external blast door"
			id = "hangar_wizard"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		syndicate_horizontal
			name = "external blast door"
			id = "hangar_syndicate"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		catering_horizontal
			name = "pod bay (catering)"
			id = "hangar_catering"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		arrivals_horizontal
			name = "pod bay (arrivals)"
			id = "hangar_arrivals"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		escape_horizontal
			name = "pod bay (escape hallway)"
			id = "hangar_escape"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		mainpod1_horizontal
			name = "pod bay (main hangar #1)"
			id = "hangar_podbay1"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		mainpod2_horizontal
			name = "pod bay (main hangar #2)"
			id = "hangar_podbay2"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		engineering_horizontal
			name = "pod bay (engineering)"
			id = "hangar_engineering"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		security_horizontal
			name = "pod bay (security)"
			id = "hangar_security"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		medsci_horizontal
			name = "pod bay (medsci)"
			id = "hangar_medsci"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		research_horizontal
			name = "pod bay (research)"
			id = "hangar_research"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		medbay_horizontal
			name = "pod bay (medbay)"
			id = "hangar_medbay"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		qm_horizontal
			name = "pod bay (cargo bay)"
			id = "hangar_qm"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		mining_horizontal
			name = "pod bay (mining)"
			id = "hangar_mining"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		miningoutpost_horizontal
			name = "pod bay (mining outpost)"
			id = "hangar_miningoutpost"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		diner1_horizontal
			name = "pod bay (space diner #1)"
			id = "hangar_spacediner1"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		diner2_horizontal
			name = "pod bay (space diner #2)"
			id = "hangar_spacediner2"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		soviet_horizontal
			name = "pod bay (salyut)"
			id = "hangar_soviet"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"

		t1d1_horizontal
			name = "pod bay (team1door1)"
			id = "hangar_t1d1"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		t1d2_horizontal
			name = "pod bay (team1door2)"
			id = "hangar_t1d2"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		t1d3_horizontal
			name = "pod bay (team1door3)"
			id = "hangar_t1d3"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		t1d4_horizontal
			name = "pod bay (team1door4)"
			id = "hangar_t1d4"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		t2d1_horizontal
			name = "pod bay (team2door1)"
			id = "hangar_t2d1"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		t2d2_horizontal
			name = "pod bay (team2door2)"
			id = "hangar_t2d2"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		t2d3_horizontal
			name = "pod bay (team2door3)"
			id = "hangar_t2d3"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		t2d4_horizontal
			name = "pod bay (team2door4)"
			id = "hangar_t2d4"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		t1d1_horizontal
			name = "pod bay (team1door1)"
			id = "hangar_t1d1"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		t1d2_horizontal
			name = "pod bay (team1door2)"
			id = "hangar_t1d2"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		t1d3_horizontal
			name = "pod bay (team1door3)"
			id = "hangar_t1d3"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		t1d4_horizontal
			name = "pod bay (team1door4)"
			id = "hangar_t1d4"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		t1condoor_horizontal
			name = "pod bay (team1 construction door)"
			id = "hangar_t1condoor"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		t2d1_horizontal
			name = "pod bay (team2door1)"
			id = "hangar_t2d1"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		t2d2_horizontal
			name = "pod bay (team2door2)"
			id = "hangar_t2d2"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		t2d3_horizontal
			name = "pod bay (team2door3)"
			id = "hangar_t2d3"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		t2d4_horizontal
			name = "pod bay (team2door4)"
			id = "hangar_t2d4"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


		t2condoor_horizontal
			name = "pod bay (team2 construction door)"
			id = "hangar_t2condoor"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"

			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"


/obj/machinery/door/poddoor/attackby(obj/item/C as obj, mob/user as mob)
	src.add_fingerprint(user)
	if (C && !ispryingtool(C))
		if (src.density && !src.operating)
			user.lastattacked = src
			attack_particle(user,src)
			playsound(src.loc, src.hitsound , 50, 1, pitch = 1.6)
			src.take_damage(C.force)
	if ((src.density && (status & NOPOWER) && !( src.operating )))
		SPAWN_DBG( 0 )
			src.operating = 1
			flick("[icon_base]c0", src)
			src.icon_state = "[icon_base]0"
			sleep(1.5 SECONDS)
			src.set_density(0)
			if (ignore_light_or_cam_opacity)
				src.opacity = 0
			else
				src.RL_SetOpacity(0)
			src.operating = 0
			update_nearby_tiles()
			return
	return

/obj/machinery/door/poddoor/bumpopen(mob/user as mob)
	return 0

/obj/machinery/door/poddoor/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!density)
		return 0
	if (linked_forcefield) //mbc : oh gosh why is this not calling door parent
		linked_forcefield.setactive(1)

	if(!src.operating) //in case of emag
		src.operating = 1

	SPAWN_DBG(-1)
		flick("[icon_base]c0", src)
		src.icon_state = "[icon_base]0"
		playsound(src, open_sound, rand(30,45),1)
		sleep(1 SECOND)
		src.set_density(0)
		if (ignore_light_or_cam_opacity)
			src.opacity = 0
		else
			src.RL_SetOpacity(0)
		update_nearby_tiles()


		if(operating == 1) //emag again
			src.operating = 0
		if(autoclose)
			SPAWN_DBG(15 SECONDS)
				autoclose()
	return 1

/obj/machinery/door/poddoor/close()
	if (src.operating)
		return
	if (src.density)
		return
	if (linked_forcefield) //mbc : oh gosh why is this not calling door parent
		linked_forcefield.setactive(0)

	SPAWN_DBG(0)
		src.operating = 1
		flick("[icon_base]c1", src)
		src.icon_state = "[icon_base]1"
		src.set_density(1)
		if (src.visible)
			if (ignore_light_or_cam_opacity)
				src.opacity = 1
			else
				src.RL_SetOpacity(1)
		update_nearby_tiles()

		playsound(src, close_sound, rand(50,65),1)

		sleep(1 SECOND)
		src.operating = 0

	return

/obj/machinery/door/poddoor/buff
	name = "buff blast door"
	desc = "This sure is a really strong looking door.  You would think there would be a point where the door is stronger than the walls around it."

	ex_act()
		return

	blob_act(var/power)
		return

	bullet_act()
		return

/obj/machinery/door/poddoor/blast
	name = "blast door"
	icon = 'icons/obj/doors/blastdoor.dmi'
	icon_state = "bdoormid1"
	desc = "Looks pretty tough. I wouldn't take this door on in a fight."
	icon_base = "bdoor"

/obj/machinery/door/poddoor/blast/New()
	..()
	//This may seem dumb, and it is. Why not set icon_base directly? I left it like this because it avoids checking all the maps
	//but this used to be a thing that set var///doordir based on initial iconstate.  which the parent poddoor doesn't have
	//Which meant that these fuckers copy pasted attackby/open/close procs just to do <src.icon_state = "[icon_base][//doordir]0"> instead of calling the parent.
	if(icon_state == "[icon_base]mid1")
		icon_base = "[icon_base]mid"
	if(icon_state == "[icon_base]left1")
		icon_base = "[icon_base]left"
	if(icon_state == "[icon_base]right1")
		icon_base = "[icon_base]right"
	if(icon_state == "[icon_base]single1")
		icon_base = "[icon_base]single"
