///Craftable atmospheric machinery
//This code of ????? quality brought to you by BatElite and probably improved on by others later

/*

CONTENTS IN ORDER OR APPEARANCE:
-Pipe frame assembly parent & code (atmos only, pipebombs are in code/obj/item/grenades.dm)
-Atmos module parent
-Atmos deployable parent & code
-Atmos crafting orientation component
-Module subtypes


The basic idea here:

Pipe frames are co-opted for purpose instead of being only for pipebombs (and roller assemblies I guess, but those are kind of a novelty you remember sometimes)
I'm also kinda making the first two stages (unwelded and welded pipe frame) not a type of pipebomb assembly

Frames now cost 2 sheets (2 halves after all), and adding another sheet after welding the pipes closed branches from atmos piping into pipebombs
(so pipebombs are the same cost, but also I didn't want atmos construction to have to deal with being mostly made of half-finished pipebombs)

-----------------------------------------------------------------
Pipe frame -> (weld) -> Welded pipe frame -> (sheet) -> Pipe bomb
	V							V
(mousetrap bomb)		(atmos crafting part (OPTIONAL))
	V							V
Roller assembly			Atmos construction
-----------------------------------------------------------------

A welded frame itself can be deployed into regular piping, straight or around a corner. You just weld the pipes at an angle you see :P
Stuff like pump and valve modules (from a vending machine?) can be combined to make an assembly that deploys into the appropriate thing
Also I have to say I don't really give a shit that the system lets you produce 3-way junctions from what's visibly 2 segments that's just pedantry.

Tank transfer valves aren't incorporated into this, sorry.

*/
///A global toggle just in case, pipebomb crafting remains possible if this is disabled
#define ENABLE_ATMOS_BUILDY


///This isn't a proper thing but I figured it'd be nice on the object tree to group it all under one parent
ABSTRACT_TYPE(/obj/item/atmospherics)
/obj/item/atmospherics

///Parent crafting item, the pipe frame end of things. BTW these are stackable watch out
/obj/item/atmospherics/pipeframe/
	name = "heat conduit pipe frame" //exchanger pipes are the parent item 'cuz they don't need to accept modules
	desc = "Small pipes made to exchange heat inside with their environment."
	icon = 'icons/obj/atmospherics/atmos_parts.dmi'
	icon_state = "conduit_to-weld"
	var/icon_welded = "frame_conduit"
	///What's this going to turn into when deployed (sans gizmo)?
	var/frame_makes = /obj/machinery/atmospherics/pipe/simple/heat_exchanging
	var/welded = FALSE
	w_class = W_CLASS_SMALL //pipebombs are normal size but I don't wanna have these be bulky.


	//we might be trying to mix welded and unwelded
	check_valid_stack(obj/item/atmospherics/pipeframe/O)
		if (O.welded != welded)
			return 0
		..()

	get_desc(dist, mob/user)
		..()
		if (!welded)
			. += " You'll have to weld the seams first though."

	attackby(obj/item/W as obj, mob/user as mob, params, is_special = 0)
		if (istool(W, TOOL_WELDING) && !welded)
			if (W:try_weld(user,1))
				welded = TRUE
				icon_state = icon_welded

///For regular pipe frames, this is what's called when there's no module
/obj/item/atmospherics/pipeframe/proc/build_a_pipe(orientation, direction)
	switch (orientation)
		if ((EAST + WEST), (NORTH + SOUTH))
			return direction
		if (NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST) //pipes are one of those fucked up things where corner sprites are assigned to the diagonals
			return orientation

//The bit that going between normal piping and heat exchangers. Build direction points to the exchanger side
/obj/item/atmospherics/pipeframe/exchanger_regular_junction
	name = "heat conduit pipe junction"
	desc = "A thing to convert from regular to heat exchanging pipes. "
	icon_state = "junction_to-weld"
	frame_makes = /obj/machinery/atmospherics/pipe/simple/junction
	icon_welded = "frame_junction"

	pre_welded
		welded = TRUE
		icon_state = "frame_junction"

	build_a_pipe(orientation, direction) //these don't do corners
		switch (orientation)
			if ((EAST + WEST), (NORTH + SOUTH))
				return direction

///Normal pipe frames
/obj/item/atmospherics/pipeframe/regular
	name = "pipe frame"
	desc = "Two pipes suitable for most atmospheric construction."
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "Pipe_Frame"
	icon_welded = "Pipe_Hollow"
	var/obj/item/atmospherics/module/gizmo =  null
	var/list/gizmoes = list() //keep a list of modules if we have a stack of assemblies (rather than just pipes)
	//IDK what all these fucking pipe variants are but this is what I found used on atlas
	frame_makes = /obj/machinery/atmospherics/pipe/simple/insulated


	get_desc(dist, mob/user)
		..()
		if (welded && isnull(gizmo))
			. += " Add a metal sheet to make a pipebomb frame."

	///We might have differing modules attached
	check_valid_stack(obj/item/atmospherics/pipeframe/regular/O)
		if ((gizmo && (!O.gizmo || !(O.gizmo.type == gizmo.type))) || (!gizmo && O.gizmo)) //mismatch of gizmo types
			return 0
		. = ..() //Includes welded check

	///We're gonna have to give the new stack the appropriate amount of gizmoes
	split_stack(toRemove)
		var/obj/item/atmospherics/pipeframe/regular/newstack = ..()
		if (!istype(newstack))	//parent call may have failed & returned 0
			return 0
		if (length(gizmoes))
			newstack.gizmoes.Add(src.gizmoes.Cut(1, toRemove))
			newstack.gizmo = newstack.gizmoes[1]

	///Steal gizmoes
	stack_item(obj/item/atmospherics/pipeframe/regular/other)
		var/added = ..()
		//for (var/i = 1, i <= added, i += 1)
		if (length(other.gizmoes))
			src.gizmoes.Add(other.gizmoes.Cut(1, added)) //NB this doesn't account for borgs yet! (where the transfer between src and other is reversed)
		return added //Pass parent return value

	attackby(obj/item/W as obj, mob/user as mob, params, is_special = 0)
		if (istype(W, /obj/item/sheet))
			var/obj/item/sheet/sheet = W
			if (!(sheet.material?.material_flags & MATERIAL_METAL))
				return
			if (!welded || gizmo)
				return
			var/sheetmat = sheet.material //Grabbing this because IDK what happens to the sheet's material if the following proc qdels the sheet
			if (!sheet.change_stack_amount(-1))
				return
			//Make a pipebomb frame and advance it to stage 2
			change_stack_amount(-1)
			var/obj/item/pipebomb/frame/newbomb = new
			newbomb.icon_state = "Pipe_Sheet"
			newbomb.state = 2
			newbomb.flags |= NOSPLASH
			newbomb.desc = "Two small pipes joined together. The pipes are empty."

			user.put_in_hand_or_drop(newbomb)
			if (sheetmat)
				newbomb.setMaterial(sheetmat)
				newbomb.name = "hollow [newbomb.material.name] pipe frame"
			else
				newbomb.name = "hollow pipe frame"
			return
		#ifdef ENABLE_ATMOS_BUILDY
		if (istype(W, /obj/item/atmospherics/module/))
			if (!welded)
				return
			if (gizmo) //already got something
				return
			user.u_equip(W)
			W.set_loc(src)
			gizmo = W
			gizmoes += W
			name = "[gizmo.assembly_prefix] pipe assembly"
			var/image/scrumpy = image(gizmo.icon, gizmo.icon_state)
			UpdateOverlays(scrumpy, "added_gizmo")
			return
		#endif
		..()

///Here be the bits and bobs you slap onto a pipe frame
/obj/item/atmospherics/module/
	name = "atmos thingy"
	desc = "combine with a pipe frame to make something neat!"

	icon = 'icons/obj/atmospherics/atmos_parts.dmi'
	icon_state = ""
	w_class = W_CLASS_TINY
	force = 0
	///Gets combined into the pipeframe's name
	var/assembly_prefix = ""
	///The typepath of thing that this module should produce
	var/machine_path = /obj/machinery/atmospherics/valve
	///How many pipe connections come out of this thing, used for making sure that the player has a sensible configuration.
	var/expected_connections = 2
	///I think all in-line atmos machinery only goes straight but if yours can make the corner, set this (room to expand?)
	var/can_do_corners = FALSE

///Here's where you sort out the direction your specific thing should get placed at. Return that direction.
/obj/item/atmospherics/module/proc/determine_and_place_machine(orientation, direction)
	//The default behaviour is gonna be for 2-connection things that can't turn corners, which is simple as can be anyway
	return direction //Should set up directional pumps and stuff correctly too

///Given the orientation and direction, should the machine be in its flipped state or no? Return 0 if no or if it's not applicable
/obj/item/atmospherics/module/proc/determine_machine_flip(orientation, direction)
	return 0 //Should set up directional pumps and stuff correctly to


//Look I need to put some shit somewhere on the mob so when you install different atmos items it remembers the orientation you picked
//Pretty sure that if we ask people to specify the orientation on every one individually they'll just go mad

//Done as a component because I think adding an AnotherGarbageHolder var on /mob is kinda silly when 2 people in a round are gonna use it
/datum/component/atmos_crafty
	//The sum of every direction we're connecting in
	var/orientation = null
	//For things that output in a specific direction (like pumps), specifies the output direction.
	var/direction = SOUTH
	//Amount of connections of the current selection (so we don't have to fuck around with orientation to get the number)
	var/no_of_connections = 0



//---------------------------Modules!-----------------------------

/obj/item/atmospherics/module/valve
	name = "valve module"
	icon_state = "valve_module"
	assembly_prefix = "valve"
	machine_path = /obj/machinery/atmospherics/valve

/obj/item/atmospherics/module/digital_valve
	name = "digital valve module"
	icon_state = "digital-valve_module"
	assembly_prefix = "digital valve"
	machine_path = /obj/machinery/atmospherics/valve/digital

/obj/item/atmospherics/module/manifold_valve
	name = "manifold valve module"
	icon_state = "manifold-valve_module"
	assembly_prefix = "manifold valve"
	machine_path = /obj/machinery/atmospherics/manifold_valve
	expected_connections = 3

	determine_and_place_machine(orientation, direction) //Manifold valve sprites point in the one direction they DON'T have a connection to
		//Possible TODO: the valves only ever switch between two pairs when there's 3 possible pairs of pipes, but also they can't be flipped like mixers
		switch (orientation)
			if (NORTH + SOUTH + EAST)
				return WEST
			if (SOUTH + EAST + WEST)
				return NORTH
			if (EAST + WEST + NORTH)
				return SOUTH
			if (WEST + NORTH + SOUTH)
				return EAST

/obj/item/atmospherics/module/filter //retrofilter is probably unnecessary
	name = "gas filter module"
	icon_state = "filter_module"
	assembly_prefix = "gas filter"
	machine_path = /obj/machinery/atmospherics/filter
	expected_connections = 3

//	determine_and_place_machine(orientation, direction)

/obj/item/atmospherics/module/mixer
	name = "gas mixer module"
	icon_state = "mixer_module"
	assembly_prefix = "gas mixer"
	machine_path = /obj/machinery/atmospherics/mixer
	expected_connections = 3

	determine_and_place_machine(orientation, direction)
		switch (orientation)
			if (NORTH + SOUTH + EAST)
				return "fuck" //asda


/obj/item/atmospherics/module/connector
	name = "connector port module"
	icon_state = "connector_module"
	assembly_prefix = "connector port"
	machine_path = /obj/machinery/atmospherics/portables_connector
	expected_connections = 1

/obj/item/atmospherics/module/vent
	name = "vent module"
	icon_state = "vent_module"
	assembly_prefix = "vent"
	machine_path = /obj/machinery/atmospherics/pipe/vent
	expected_connections = 1

//--Things are kinda sorted by type, binary machines are up next and unary comes after that

/obj/item/atmospherics/module/pump
	name = "pump module"
	icon_state = "pump_module"
	assembly_prefix = "pump"
	machine_path = /obj/machinery/atmospherics/binary/pump

/obj/item/atmospherics/module/volume_pump
	name = "volume pump module"
	icon_state = "volume-pump_module"
	assembly_prefix = "volume pump"
	machine_path = /obj/machinery/atmospherics/binary/volume_pump

/obj/item/atmospherics/module/dp_vent
	name = "dual port vent module"
	icon_state = "dp-vent_module"
	assembly_prefix = "dual port vent"
	machine_path = /obj/machinery/atmospherics/binary/dp_vent_pump

/obj/item/atmospherics/module/passive_gate
	name = "passive gate module"
	icon_state = "passive-gate_module"
	assembly_prefix = "passive gate"
	machine_path = /obj/machinery/atmospherics/binary/passive_gate

//Binary machinery not included above: circulator (old and deprecated?) and circulatorTemp (TEG gas circulators)

/obj/item/atmospherics/module/cold_sink
	name = "cold sink module"
	icon_state = "cold-sink_module"
	assembly_prefix = "cold sink"
	machine_path = /obj/machinery/atmospherics/unary/cold_sink
	expected_connections = 1

/obj/item/atmospherics/module/heat_reservoir
	name = "heat reservoir module"
	icon_state = "heat-reservoir_module"
	assembly_prefix = "heat reservoir"
	machine_path = /obj/machinery/atmospherics/unary/heat_reservoir
	expected_connections = 1

/obj/item/atmospherics/module/furnace_connector //you know I thought furnaces plugged into atmos on their own accord.
	name = "furnace connector module"
	icon_state = "heat-reservoir_module" //matches the actual connector reusing the reservoir sprite :V
	assembly_prefix = "furnace connector"
	machine_path = /obj/machinery/atmospherics/unary/furnace_connector
	expected_connections = 1

/obj/item/atmospherics/module/outlet_injector
	name = "outlet injector module"
	icon_state = "injector_module"
	assembly_prefix = "outlet injector"
	machine_path = /obj/machinery/atmospherics/unary/outlet_injector
	expected_connections = 1

/obj/item/atmospherics/module/vent_pump
	name = "vent pump module"
	icon_state = "vent-pump_module"
	assembly_prefix = "vent pump"
	machine_path = /obj/machinery/atmospherics/unary/heat_reservoir
	expected_connections = 1

/obj/item/atmospherics/module/vent_scrubber
	name = "vent scrubber module"
	icon_state = "vent-scrubber_module"
	assembly_prefix = "vent scrubber"
	machine_path = /obj/machinery/atmospherics/unary/heat_reservoir
	expected_connections = 1

//Unary machinery not included above: cryo_cell (a bit outside the remit of buildable atmos), generator_input (some sort of placeholder?)

//---------------------------Module vending machine!-----------------------------

/obj/machinery/vending/atmospherics //adapted from the mechcomp one
	name = "atmospherics module dispenser"
	desc = "Dispenses parts for building atmospherics equipment."
	icon_state = "generic"
	icon_panel = "generic-panel"
	acceptcard = 0
	pay = 0

	light_r =1
	light_g = 0.88
	light_b = 0.3

	#ifndef ENABLE_ATMOS_BUILDY
	New()
		..()
		qdel(src)
	#endif

	create_products() //IDK what half the machines these fuckers build into actually *do* so not all of this may be appropriate stock
		..()
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/valve, 15)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/digital_valve, 15)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/manifold_valve, 15)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/filter, 5)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/mixer, 5)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/connector, 8)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/pump, 15)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/volume_pump, 15)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/dp_vent, 10)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/passive_gate, 10)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/cold_sink, 5)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/heat_reservoir, 5)
		//obj/item/atmospherics/module/furnace_connector
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/outlet_injector, 15)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/vent, 10)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/vent_pump, 10)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/vent_scrubber, 10)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/pipeframe/exchanger_regular_junction/pre_welded, 10)
