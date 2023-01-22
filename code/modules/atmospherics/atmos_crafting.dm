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
ABSTRACT_TYPE(/obj/item/atmospherics/pipeframe)
/obj/item/atmospherics/pipeframe
	name = "the platonic ideal of atmospheric piping frame"
	desc = "Small pipes made to exchange heat inside with their environment."
	icon = 'icons/obj/atmospherics/atmos_parts.dmi'
	icon_state = "conduit_to-weld"
	///What does this look like after welding?
	var/icon_welded
	///What's this going to turn into when deployed (sans gizmo)?
	var/frame_makes = /obj/machinery/atmospherics
	var/welded = FALSE
	//The amount of connections this frame/assembly needs, gets overridden when a module is added
	var/expected_connections = 2
	w_class = W_CLASS_SMALL //pipebombs are normal size but I don't wanna have these be bulky.
	max_stack = 30


	//we might be trying to mix welded and unwelded
	check_valid_stack(obj/item/atmospherics/pipeframe/O)
		. = ..()
		if (.)
			if (O.welded != welded)
				. = 0

	//Set appropriate welded status
	split_stack(toRemove)
		var/obj/item/atmospherics/pipeframe/newstack = ..()
		if (istype(newstack)) //Parent call failed
			newstack.welded = src.welded
			newstack.icon_state = newstack.icon_welded
		return newstack

	get_desc(dist, mob/user)
		..()
		if (!welded)
			. += " You'll have to weld the seams first though."

	afterattack(atom/target, mob/user, reach, params)
		if (!istype(user)) //Gonna need those sweet, sweet component vars
			return

		if(istype(target, /obj/window))
			target = get_turf(target)

		if(isturf(target))
			var/datum/component/atmos_crafty/pipe_settings = user.GetComponent(/datum/component/atmos_crafty)
			if (isnull(pipe_settings)) //This basically amounts to using the default settings on the new component
				pipe_settings = user.AddComponent(/datum/component/atmos_crafty)
			if (!(expected_connections == 1)) //Direction is all we need it's fine
				if (!validate_settings(pipe_settings.orientation, pipe_settings.direction, pipe_settings.no_of_connections, user))
					return
			var/obj/machinery/atmospherics/newthing = build_a_pipe(target, pipe_settings.orientation, pipe_settings.direction, user)
			if (istype(newthing))
				change_stack_amount(-1)
				newthing.initialize() //Apparently this is where they stuck the fucking node finding code
				newthing.sync_node_connections()
			return
		..()

	attackby(obj/item/W as obj, mob/user as mob, params, is_special = 0)
		if (istool(W, TOOL_WELDING) && !welded)
			if (W:try_weld(user,1))
				if (src.amount > 1) // No welding a stack of things in one go
					var/obj/item/atmospherics/pipeframe/weldedpipe = split_stack(1)
					weldedpipe.welded = TRUE
					weldedpipe.icon_state = weldedpipe.icon_welded
					user.put_in_hand_or_drop(weldedpipe)
				else
					welded = TRUE
					icon_state = icon_welded
				return
		if (istype(W, /obj/item/atmospherics/pipeframe/))
			stack_item(W)
		..()

	attack_hand(mob/user) //Copied from material sheets
		if((user.r_hand == src || user.l_hand == src) && src.amount > 1)
			var/splitnum = round(input("How many frames do you want to take from the pile?","Pile of [src.amount]",1) as num)
			if(src.loc != user) //Dropped between opening and closing the box
				return
			splitnum = round(clamp(splitnum, 0, src.amount))
			if(amount == 0)
				return
			var/obj/item/atmospherics/pipeframe/new_stack = split_stack(splitnum)
			if (!istype(new_stack))
				return
			user.put_in_hand_or_drop(new_stack)
			//new_stack.add_fingerprint(user) //IDK I haven't bothered with fingerprints anywhere else in this file
		else ..()

	///Bring up the orientation panel
	attack_self(mob/user)
		if (!welded)
			return ..()
		var/datum/component/atmos_crafty/blepperdy_bloop = user.GetComponent(/datum/component/atmos_crafty)
		if (!isnull(blepperdy_bloop))
			blepperdy_bloop.showPanel()
		else //Set em up with one of these if they're so gosh dang interested
			blepperdy_bloop = user.AddComponent(/datum/component/atmos_crafty)
			blepperdy_bloop.showPanel()
		. = ..()

///This may seem useless but for the regular frames I need to do some weird stuff to work junctions in
/obj/item/atmospherics/pipeframe/proc/validate_settings(orientation, direction, no_of_connections, mob/user)
	if (no_of_connections != expected_connections)
		return 0
	if (!(orientation & direction)) //Direction isn't included in orientation (AKA settings are nonsense)
		boutput(user, "<span class='alert'>Your chosen direction isn't one of the sides the component connect to!</span>")
		return 0 //Would every single machine type necessarily care? No, but the buildy procs assume direction is good
	return 1

///Try to put up a pipe
/obj/item/atmospherics/pipeframe/proc/build_a_pipe(turf/destination, orientation, direction, mob/user)
	switch (orientation)
		if ((EAST + WEST), (NORTH + SOUTH))
			return new frame_makes(destination, direction)
		if (NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST) //pipes are one of those fucked up things where corner sprites are assigned to the diagonals
			return new frame_makes(destination, orientation)


//Temperature exchanging piping
/obj/item/atmospherics/pipeframe/exchanger
	name = "heat conduit pipe frame"
	desc = "Small pipes made to exchange heat inside with their environment."
	icon_state = "conduit_to-weld"
	icon_welded = "frame_conduit"
	frame_makes = /obj/machinery/atmospherics/pipe/simple/heat_exchanging


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

	build_a_pipe(turf/destination, orientation, direction, mob/user) //these don't do corners
		switch (orientation)
			if ((EAST + WEST), (NORTH + SOUTH))
				return new frame_makes(destination, direction)//return direction


///Normal pipe frames
/obj/item/atmospherics/pipeframe/regular
	name = "pipe frame"
	desc = "Two pipes suitable for most atmospheric construction."
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "Pipe_Frame"
	icon_welded = "Pipe_Hollow"
	var/obj/item/atmospherics/module/gizmo =  null
	//IDK what all these variants are but this is what I found used on atlas
	frame_makes = /obj/machinery/atmospherics/pipe/simple/insulated

	disposing()
		if (gizmo?.loc == src) //This is the bullshit that will let us split off of stack of gizmoed frames without spawning a gizmo every time
			qdel(gizmo) //Basically until we're
		gizmo = null
		..()


	get_desc(dist, mob/user)
		..()
		if (welded && isnull(gizmo))
			. += " Add a metal sheet to make a pipebomb frame."

	///We might have differing modules attached
	check_valid_stack(obj/item/atmospherics/pipeframe/regular/O)
		. = ..()
		if (.) //Includes welded check
			if ((gizmo && (!O.gizmo || !(O.gizmo.type == gizmo.type))) || (!gizmo && O.gizmo)) //mismatch of gizmo types
				. = 0

	///Spawn a gizmo
	split_stack(toRemove, spawn_gizmo = TRUE) //
		var/obj/item/atmospherics/pipeframe/regular/newstack = ..()
		if (!istype(newstack)) //parent call may have failed
			return 0
		if (gizmo)
			var/obj/item/thingy = new src.gizmo.type
			newstack.Attackby(thingy)
		return newstack

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
			if (W.amount > 1)
				W = W.split_stack(1)
			else
				user.u_equip(W)
			//Hey it'd be a good idea to check if we're not a stack of things too
			var/obj/item/atmospherics/pipeframe/regular/to_b_combined = src
			if (src.amount > 1)
				to_b_combined = split_stack(1)
				to_b_combined.welded = TRUE
			W.set_loc(to_b_combined)
			to_b_combined.gizmo = W
			to_b_combined.expected_connections = to_b_combined.gizmo.expected_connections
			to_b_combined.name = "[to_b_combined.gizmo.assembly_prefix] pipe assembly"
			var/image/scrumpy = image(to_b_combined.gizmo.icon, to_b_combined.gizmo.icon_state)
			to_b_combined.UpdateOverlays(scrumpy, "added_gizmo")
			if (to_b_combined != src)
				user.put_in_hand_or_drop(to_b_combined)
			return
		#endif
		..()

	build_a_pipe(turf/destination, orientation, direction, mob/user)

		if (!gizmo)
			switch(orientation) //Like manifold valves, manifolds point in the direction they don't have a connection to
				if(NORTH + EAST + WEST)
					return new /obj/machinery/atmospherics/pipe/manifold(destination, SOUTH)
				if(SOUTH + EAST + WEST)
					return new /obj/machinery/atmospherics/pipe/manifold(destination, NORTH)
				if(NORTH + SOUTH + WEST)
					return new /obj/machinery/atmospherics/pipe/manifold(destination, EAST)
				if(NORTH + SOUTH + EAST)
					return new /obj/machinery/atmospherics/pipe/manifold(destination, WEST)
				else
					return ..() //2-connection pipes
		else
			return gizmo.determine_and_place_machine(destination, orientation, direction)
			/*if (gizmo.determine_and_place_machine(destination, orientation, direction))
				change_stack_amount(-1)
			else
				boutput(user, "<span class='alert'>Hmm, something about your pipe settings isn't right. Probably the direction?</span>")*/

	validate_settings(orientation, direction, no_of_connections, mob/user)
		if (!gizmo)
			if (no_of_connections == 3) //manifold time
				return 1
		return ..()

///Here be the bits and bobs you slap onto a pipe frame
/obj/item/atmospherics/module/
	name = "atmos thingy"
	desc = "combine with a pipe frame to make something neat!"

	icon = 'icons/obj/atmospherics/atmos_parts.dmi'
	icon_state = ""
	w_class = W_CLASS_TINY
	max_stack = 10
	force = 0
	///Gets combined into the pipeframe's name
	var/assembly_prefix = ""
	///The typepath of thing that this module should produce
	var/machine_path = /obj/machinery/atmospherics/valve
	///How many pipe connections come out of this thing, used for making sure that the player has a sensible configuration.
	var/expected_connections = 2
	///I think all in-line atmos machinery only goes straight but if yours can make the corner, set this (room to expand?)
	var/can_do_corners = FALSE

	attack_hand(mob/user)
		if (amount > 1 && user.find_in_hand(src))
			user.put_in_hand_or_drop(split_stack(1)) //Could upgrade this to allow players to specify a number I doubt it's necessary ATM
			return
		..()
	//Fuck it lets make these stackable too
	attackby(obj/item/W as obj, mob/user as mob, params, is_special = 0)
		if (istype(W, /obj/item/atmospherics/module/))
			stack_item(W)
		else if (istype(W, /obj/item/atmospherics/pipeframe))
			W.attackby(src, user, params, is_special) //fuck crafting recipes that demand you slap A on B but not B on A
		..()

///Here's where you sort out the direction your specific thing should get placed at.
/obj/item/atmospherics/module/proc/determine_and_place_machine(turf/destination, orientation, direction)
	//This handles 1-connection and 2-connection straight-only parts, which is about everything save for 3 or so machines
	if (expected_connections == 1 || orientation == (NORTH + SOUTH) || orientation == (EAST + WEST))
		return new machine_path(destination, direction) //Should set up directional pumps and stuff correctly too
	return 0

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

	determine_and_place_machine(turf/destination, orientation, direction) //Manifold valve sprites point in the one direction they DON'T have a connection to
		//Possible TODO: the valves only ever switch between two pairs when there's 3 possible pairs of pipes, but also they can't be flipped like mixers
		switch (orientation)
			if (NORTH + SOUTH + EAST)
				return new machine_path(destination, WEST)
			if (SOUTH + EAST + WEST)
				return new machine_path(destination, NORTH)
			if (EAST + WEST + NORTH)
				return new machine_path(destination, SOUTH)
			if (WEST + NORTH + SOUTH)
				return new machine_path(destination, EAST)
		return 0

/obj/item/atmospherics/module/filter //retrofilter is probably unnecessary
	name = "gas filter module"
	icon_state = "filter_module"
	assembly_prefix = "gas filter"
	machine_path = /obj/machinery/atmospherics/filter
	expected_connections = 3

	determine_and_place_machine(turf/destination, orientation, direction)
		switch (orientation)
			if (NORTH + SOUTH + EAST)
				return new machine_path(destination, NORTH)
			if (SOUTH + EAST + WEST)
				return new machine_path(destination, EAST)
			if (EAST + WEST + NORTH)
				return new machine_path(destination, WEST)
			if (WEST + NORTH + SOUTH)
				return new machine_path(destination, SOUTH)
		return 0

/obj/item/atmospherics/module/mixer
	name = "gas mixer module"
	icon_state = "mixer_module"
	assembly_prefix = "gas mixer"
	machine_path = /obj/machinery/atmospherics/mixer
	expected_connections = 3

	determine_and_place_machine(turf/destination, orientation, direction)
		switch (orientation)
			if (NORTH + SOUTH + EAST)
				return new machine_path(destination, (direction == SOUTH ? SOUTH : NORTH), (direction == SOUTH ? TRUE : FALSE)) //Third argument is for flipping the mixer
			if (SOUTH + EAST + WEST)
				return new machine_path(destination, (direction == SOUTH ? SOUTH : NORTH), (direction == SOUTH ? FALSE : TRUE))
			if (EAST + WEST + NORTH)
				return new machine_path(destination, (direction == WEST ? WEST : EAST), (direction == WEST ? TRUE : FALSE))
			if (WEST + NORTH + SOUTH)
				return new machine_path(destination, (direction == WEST ? WEST : EAST), (direction == WEST ? FALSE : TRUE))
		return 0


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

/* These two types aren't fit to be built directly
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
*/

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
	machine_path = /obj/machinery/atmospherics/unary/vent_pump
	expected_connections = 1

/obj/item/atmospherics/module/vent_scrubber
	name = "vent scrubber module"
	icon_state = "vent-scrubber_module"
	assembly_prefix = "vent scrubber"
	machine_path = /obj/machinery/atmospherics/unary/vent_scrubber

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
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/furnace_connector, 5)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/outlet_injector, 15)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/vent, 10)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/vent_pump, 10)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/vent_scrubber, 10)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/pipeframe/exchanger_regular_junction/pre_welded, 10)

//------------------------------Atmos crafting menu component?------------------------

//Look I need to put some shit somewhere on the mob so when you install different atmos items it remembers the orientation you picked
//Pretty sure that if we ask people to specify the orientation on every one individually they'll just go mad

//Done as a component because I think adding an /datum/AnotherFuckingGarbageHolder var on /mob is kinda silly when 2 people in a round are gonna use it
/datum/component/atmos_crafty
	//The sum of every direction we're connecting in
	var/orientation = NORTH + SOUTH
	//For things that output in a specific direction (like pumps), specifies the output direction.
	var/direction = SOUTH
	//Amount of connections of the current selection (so we don't have to fuck around with orientation to get the number)
	var/no_of_connections = 2

	//From here on out I copy-pasted the admin antag popups debug and started editing GLHF (that's also why the style is called antagType)
	var/html

	proc/generateHTML()
		if (html)
			html = ""

		html += {"
<title>Pipe orientation</title>
<style>
	a {text-decoration:none}
	.antagType {padding:5px; margin-bottom:8px; border:1px solid black}
	.antagType .title {display:block; color:white; background:black; padding: 2px 5px; margin: -5px -5px 2px -5px}
</style>
<head>
	Please select the orientation you want to build in.<br>
	The direction corresponds to the outputting side of the component, if applicable.<br>
	For components with a single connection, the selected direction is used for the orientation instead.
</head>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>2 Connections</b>
	<font size="5">
	<a href='?src=\ref[src];action=straight_NS'>|</a> ‧
	<a href='?src=\ref[src];action=straight_EW'>─</a> ‧
	<a href='?src=\ref[src];action=corner_SE'>┌</a> ‧
	<a href='?src=\ref[src];action=corner_SW'>┐</a> ‧
	<a href='?src=\ref[src];action=corner_NE'>└</a> ‧
	<a href='?src=\ref[src];action=corner_NW'>┘</a>
	</font>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>3 Connections</b>
	<font size="5">
	<a href='?src=\ref[src];action=junc_N'>┴</a> ‧
	<a href='?src=\ref[src];action=junc_S'>┬</a> ‧
	<a href='?src=\ref[src];action=junc_W'>┤</a> ‧
	<a href='?src=\ref[src];action=junc_E'>├</a>
	</font>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Orientation & Single Connection</b>
	<font size="5">
	<a href='?src=\ref[src];action=north'>↑</a> ‧
	<a href='?src=\ref[src];action=south'>↓</a> ‧
	<a href='?src=\ref[src];action=west'>←</a> ‧
	<a href='?src=\ref[src];action=east'>→</a>
	</font>
</div>
"}

		return 1

	proc/showPanel()
		if (!html)
			if (!generateHTML())
				alert("Unable to generate pipe orientation panel panel! Something's gone wacky!")
				return

		usr.Browse(html, "window=atmospipecrafting;size=300x375")

	Topic(href, href_list)
		if (!ismob(usr))
			alert("How the hell are you not a mob?! I can't show the panel to you, you don't exist!")
			return

		switch(href_list["action"])
			// 2 connections
			if ("straight_NS")
				orientation = NORTH + SOUTH
				no_of_connections = 2
			if ("straight_EW")
				orientation = EAST + WEST
				no_of_connections = 2
			if ("corner_SW")
				orientation = SOUTH + WEST
				no_of_connections = 2
			if ("corner_SE")
				orientation = SOUTH + EAST
				no_of_connections = 2
			if ("corner_NW")
				orientation = NORTH + WEST
				no_of_connections = 2
			if ("corner_NE")
				orientation = NORTH + EAST
				no_of_connections = 2

			// 3 connections
			if ("junc_N")
				orientation = NORTH + EAST + WEST
				no_of_connections = 3
			if ("junc_S")
				orientation = SOUTH + EAST + WEST
				no_of_connections = 3
			if ("junc_W")
				orientation = NORTH + SOUTH + WEST
				no_of_connections = 3
			if ("junc_E")
				orientation = NORTH + SOUTH + EAST
				no_of_connections = 3

			// direction/single connection (these don't set no_of_connections because the placing code for 1-connection machines will just use direction)
			if ("north")
				direction = NORTH
			if ("south")
				direction = SOUTH
			if ("east")
				direction = EAST
			if ("west")
				direction = WEST

/obj/item/debug_atmos_bapper // I haven't made *deconstructable* atmos a thing yet so here you go for testing
	name = "debug atmos bapper"
	desc = "The bane of atmospheric machinery"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "rubber_hammer"
	color = "#EF00EF"
	w_class = W_CLASS_TINY

	afterattack(atom/target, mob/user, reach, params)
		if (istype(target, /obj/machinery/atmospherics))
			qdel(target)
		..()
