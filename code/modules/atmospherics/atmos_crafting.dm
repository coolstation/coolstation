///Craftable atmospheric machinery
//This code of ????? quality brought to you by BatElite and probably improved on by others later

/*

CONTENTS IN ORDER OR APPEARANCE:
-Pipe frame assembly parent & code (atmos only, pipebombs are in code/obj/item/grenades.dm)
-Atmos module parent
-Atmos deployable parent & code
-Atmos crafting orientation component
-Module subtypes
-Deployable subtypes


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

Deployables are things that stand on their own, and they're basically on the level of mechcomp frames

Tank transfer valves aren't incorporated into this, sorry.

*/
///A global toggle just in case, pipebomb crafting remains possible if this is disabled
#define ENABLE_ATMOS_BUILDY


///This isn't a proper thing but I figured it'd be nice on the object tree to group it all under one parent
ABSTRACT_TYPE(/obj/item/atmospherics)
/obj/item/atmospherics

///Parent crafting item, the pipe frame end of things. BTW these are stackable watch out
/obj/item/atmospherics/pipeframe
	name = "pipe frame"
	desc = "Two pipes suitable for ."
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "Pipe_Frame"
	///
	var/obj/item/atmospherics/module/gizmo =  null
	///What's this assembly going to turn into when deployed?
	var/assembly_makes = /obj/machinery/atmospherics/pipe/simple/insulated
	var/welded = FALSE

	get_desc(dist, mob/user)
		..()
		if (welded && isnull(gizmo))
			. += " Add a metal sheet to make a pipebomb frame."

	///We might have differing modules attached, or we might be trying to mix welded and unwelded
	check_valid_stack(obj/item/atmospherics/pipeframe/O)
		if (O.welded != welded)
			return 0
		if ((gizmo && (!O.gizmo || !(O.gizmo.type == gizmo.type))) || (!gizmo && O.gizmo)) //mismatch of gizmo types
			return 0
		. = ..()

	attackby(obj/item/W as obj, mob/user as mob, params, is_special = 0)
		if (istool(W, TOOL_WELDING) && !welded)
			if (W:try_weld(user,1))
				welded = TRUE
				icon_state = "Pipe_Hollow"

		if (istype(W, /obj/item/sheet))
			var/obj/item/sheet/sheet = W
			if (!(sheet.material?.material_flags & MATERIAL_METAL))
				return
			if (!welded || gizmo)
				return
			if (!sheet.change_stack_amount(-1))
				return
			//Make a pipebomb frame and advance it to stage 2
			var/obj/item/pipebomb/frame/newbomb = new
			newbomb.icon_state = "Pipe_Sheet"
			newbomb.state = 2
			newbomb.flags |= NOSPLASH
			newbomb.desc = "Two small pipes joined together. The pipes are empty."

			if (sheet.material)
				newbomb.setMaterial(sheet.material)
				newbomb.name = "hollow [newbomb.material.name] pipe frame"
			else
				newbomb.name = "hollow pipe frame"
			return
		#ifdef ENABLE_ATMOS_BUILDY
		if (istype(W, /obj/item/atmospherics/module/))
			if (gizmo) //already got something
				return
			gizmo = W
			assembly_makes = gizmo.machine_path
		#endif



///Here be the bits and bobs you slap onto a pipe frame
/obj/item/atmospherics/module/
	name = "atmos thingy"
	desc = "combine with a pipe frame to make something neat!"

	icon = 'icons/obj/atmospherics/digital_valve.dmi' //temp
	icon_state = "hvalve0" //temp
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
/obj/item/atmospherics/module/proc/determine_machine_dir(orientation, direction)
	//The default behaviour is gonna be for 2-connection things that can't turn corners, which is simple as can be anyway
	return direction //Should set up directional pumps and stuff correctly too

///Items that are directly deployable on their own? (big looking filters and connectors and so on?)
/obj/item/atmospherics/deployable
	name = "atmos deployable"
	desc = "IDK wrench this shit or something?"




//Look I need to put some shit somewhere on the mob so when you install different atmos items it remembers the orientation you picked
//Pretty sure that if we ask people to specify the orientation on every one individually they'll just go mad

//Done as a component because I think adding an AnotherGarbageHolder var on /mob is kinda silly when 2 people in a round are gonna use it
/datum/component/atmos_crafty
	//The sum of every
	var/orientation = null
	//For things that output in a specific direction (like pumps), specifies the output direction.
	var/direction = SOUTH
	//
	var/no_of_connections = 0



//---------------------------Modules!-----------------------------

/obj/item/atmospherics/module/valve
	name = "valve module"
	assembly_prefix = "valve"
	machine_path = /obj/machinery/atmospherics/valve

/obj/item/atmospherics/module/digital_valve
	name = "digital valve module"
	assembly_prefix = "digital valve"
	machine_path = /obj/machinery/atmospherics/valve/digital

/obj/item/atmospherics/module/manifold_valve
	name = "manifold valve module"
	assembly_prefix = "manifold valve"
	machine_path = /obj/machinery/atmospherics/manifold_valve
	expected_connections = 3

//	determine_machine_dir(orientation, direction) //Manifold valve sprites point in the one direction they DON'T have a connection to
		//Possible TODO: the valves only ever switch between two pairs when there's 3 possible pairs of pipes, but also they can't be flipped like mixers

/obj/item/atmospherics/module/filter //retrofilter is probably unnecessary
	name = "gas filter module"
	assembly_prefix = "gas filter"
	machine_path = /obj/machinery/atmospherics/filter
	expected_connections = 3

//	determine_machine_dir(orientation, direction)

/obj/item/atmospherics/module/mixer
	name = "gas mixer module"
	assembly_prefix = "gas mixer"
	machine_path = /obj/machinery/atmospherics/mixer
	expected_connections = 3

//	determine_machine_dir(orientation, direction)
		//switch(orientation)
			//if(NORTH + SOUTH + EAST)

/obj/item/atmospherics/module/connector
	name = "connector port module"
	assembly_prefix = "connector port"
	machine_path = /obj/machinery/atmospherics/portables_connector
	expected_connections = 1

//--Things are kinda sorted by type, binary machines are up next and unary comes after that

/obj/item/atmospherics/module/pump
	name = "pump module"
	assembly_prefix = "pump"
	machine_path = /obj/machinery/atmospherics/binary/pump

/obj/item/atmospherics/module/volume_pump
	name = "volume pump module"
	assembly_prefix = "volume pump"
	machine_path = /obj/machinery/atmospherics/binary/volume_pump

/obj/item/atmospherics/module/dp_vent
	name = "dual port vent module"
	assembly_prefix = "dual port vent"
	machine_path = /obj/machinery/atmospherics/binary/dp_vent_pump

/obj/item/atmospherics/module/passive_gate
	name = "passive gate module"
	assembly_prefix = "passive gate"
	machine_path = /obj/machinery/atmospherics/binary/passive_gate

//Binary machinery not included above: circulator (old and deprecated?) and circulatorTemp (TEG gas circulators)

/obj/item/atmospherics/module/cold_sink
	name = "cold sink module"
	assembly_prefix = "cold sink"
	machine_path = /obj/machinery/atmospherics/unary/cold_sink
	expected_connections = 1

/obj/item/atmospherics/module/heat_reservoir
	name = "heat reservoir module"
	assembly_prefix = "heat reservoir"
	machine_path = /obj/machinery/atmospherics/unary/heat_reservoir
	expected_connections = 1

/obj/item/atmospherics/module/furnace_connector //you know I thought furnaces plugged into atmos on their own accord.
	name = "furnace connector module"
	assembly_prefix = "furnace connector"
	machine_path = /obj/machinery/atmospherics/unary/furnace_connector
	expected_connections = 1

/obj/item/atmospherics/module/outlet_injector
	name = "outlet injector module"
	assembly_prefix = "outlet injector"
	machine_path = /obj/machinery/atmospherics/unary/outlet_injector
	expected_connections = 1

/obj/item/atmospherics/module/vent_pump
	name = "vent pump module"
	assembly_prefix = "vent pump"
	machine_path = /obj/machinery/atmospherics/unary/heat_reservoir
	expected_connections = 1

/obj/item/atmospherics/module/vent_scrubber
	name = "vent scrubber module"
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
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/vent_pump, 10)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/vent_scrubber, 10)
