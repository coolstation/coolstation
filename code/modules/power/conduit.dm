//a disastrous mashup of cables and disposal pipes for heavy duty connectivity

/obj/cable/conduit
// note don't get used to it just yet as i will probably be changing some of the iconstate naming conventions
	name = "power conduit"
	desc = "A rigid assembly of superconducting power lines."
	icon_state = "conduit"
	iconmod = "-conduit"

	conductor_default = "claretine"
	insulator_default = "synthrubber"

	//same as normal cables but you have to click them multiple cuts heheheh
	var/static/welds_required = 2
	var/welds = 0

	get_desc(dist, mob/user)
		if(dist < 4 && welds)
			.= "<br>" + "The conduit looks partially detached."

	cut(mob/user,turf/T) //not cuttable, intercept any attempts to cut
		boutput(user, "<span class='alert'>In retrospect, this looks more like a welding job.</span>")
		src.visible_message("<span class='alert'>[user] tries to cut through section of [src], but the conduit is too thick.</span>")

	updateicon()
		return //these are rigid items, we will not be updating icons with directions, but we will be using iconstate names for powernet direction

	weld(mob/user,turf/T) //weld to dismantle, disposal pipe style
		welds++
		shock(user, 50)
		var/num = "first"
		if (welds == 2)
			num = "second"
		src.visible_message("<span class='alert'>[user] slices through the [num] conductor pair of [src].</span>")

		if (welds >= welds_required)
			src.visible_message("<span class='alert'>If the next part of this was working, it would spawn right now!</span>")
			welds = 0 //reset the count and do nothing
		else
			playsound(src.loc, "sound/items/Welder.ogg", 50, 1)

/obj/cable/conduit/segment
	icon_state = "1-2-conduit"
	iconmod = "-conduit"

	horizontal
		dir = EAST
		icon_state = "4-8-conduit"
	vertical
		dir = NORTH
		icon_state = "1-2-conduit"
	bent
		icon_state = "1-4-conduit"
		desc = "A rigid assembly of superconducting power lines. This conduit has been curved at an angle."
		north
			dir = NORTH
			icon_state = "1-4-conduit"
		east
			dir = EAST
			icon_state = "4-2-conduit"
		south
			dir = SOUTH
			icon_state = "2-8-conduit"
		west
			dir = WEST
			icon_state = "8-1-conduit"

/obj/cable/conduit/junction
	icon_state = "a-1-conduit"
	name = "three-way conduit junction"
	desc = "A rigid assembly of superconducting power lines. A three-way junction has been made."
	north
		dir = NORTH
		icon_state = "a-1-conduit"
	east
		dir = EAST
		icon_state = "a-4-conduit"
	south
		dir = SOUTH
		icon_state = "a-2-conduit"
	west
		dir = WEST
		icon_state = "a-8-conduit"

/obj/cable/conduit/allway
	icon_state = "a-a-conduit"
	name = "all-way conduit junction"
	desc = "A rigid assembly of superconducting power lines. A four-way junction has been made."

/obj/cable/conduit/tap
	icon_state = "1-2-conduit-tap"
	name = "conduit tap"
	desc = "A rigid assembly of superconducting power lines. A terminal tap has been added mid-length."
	horizontal
		dir = EAST
		icon_state = "4-8-conduit-tap"
	vertical
		dir = NORTH
		icon_state = "1-2-conduit-tap"

/obj/cable/conduit/trunk
	icon_state = "conduit-t"
	name = "conduit terminal"
	desc = "A rigid assembly of superconducting power lines. It ends in a terminal tap."
	north
		dir = NORTH
		icon_state = "0-1-conduit"
	east
		dir = EAST
		icon_state = "0-4-conduit"
	south
		dir = SOUTH
		icon_state = "0-2-conduit"
	west
		dir = WEST
		icon_state = "0-8-conduit"

/obj/cable/conduit/switcher
	icon_state = "1-2-conduit-sw1"
	name = "switched conduit"
	desc = "A rigid assembly of superconducting power lines. It has a heavy duty in-line switch built in."
	east
		dir = EAST
		icon_state = "4-8-conduit-sw1"
	west
		dir = WEST
		icon_state = "8-4-conduit-sw1"
	vertical
		dir = NORTH
		icon_state = "1-2-conduit-sw1"

/obj/cable/conduit/small
	name = "small power conduit"
	desc = "A two-line superconductor conduit, meant for direct monitoring of power output by terminals."
	icon_state = "1-2-smallconduit"
	iconmod = "-smallconduit"
	color = "#BA9B67"

/obj/cable/conduit/small/tap
	name = "small power conduit tap"
	desc = "A two-line superconductor conduit tap, meant for direct monitoring of power output by terminals."
	icon_state = "0-1-smallconduit"
