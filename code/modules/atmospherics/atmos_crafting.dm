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
	//The amount of connections this frame/assembly needs, gets overridden when a module is added
	var/expected_connections = 2
	w_class = W_CLASS_SMALL //pipebombs are normal size but I don't wanna have these be bulky.


	//we might be trying to mix welded and unwelded
	check_valid_stack(obj/item/atmospherics/pipeframe/O)
		if (..())
			if (O.welded != welded)
				return 0
		return 1

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
				if (pipe_settings.no_of_connections != expected_connections)
					return
				if ((pipe_settings.orientation ^ pipe_settings.direction) > pipe_settings.orientation) //Direction isn't included in orientation (AKA settings are nonsense)
					boutput(user, "<span class='alert'>Your chosen direction isn't one of the sides the component connect to!</span>")
					return //Would every single machine type necessarily care? No, but I'm relying on a sensible direction for shorthand in build_a_pipe
			build_a_pipe(target, pipe_settings.orientation, pipe_settings.direction)
			return
		..()

	attackby(obj/item/W as obj, mob/user as mob, params, is_special = 0)
		if (istool(W, TOOL_WELDING) && !welded)
			if (W:try_weld(user,1))
				welded = TRUE
				icon_state = icon_welded
				return
		if (istype(W, /obj/item/atmospherics/pipeframe/))
			stack_item(W)
		..()

	attack_hand(mob/user)
		..()
		//Gonna have to set up/assign

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

///Try to put up a
/obj/item/atmospherics/pipeframe/proc/build_a_pipe(turf/destination, orientation, direction)
	switch (orientation)
		if ((EAST + WEST), (NORTH + SOUTH))
			new frame_makes(destination, specify_direction = direction)
			qdel(src)
		if (NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST) //pipes are one of those fucked up things where corner sprites are assigned to the diagonals
			new frame_makes(destination, specify_direction = orientation)
			qdel(src)



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

	build_a_pipe(turf/destination, orientation, direction) //these don't do corners
		switch (orientation)
			if ((EAST + WEST), (NORTH + SOUTH))
				new frame_makes(destination, direction)//return direction
				qdel(src)


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

	disposing()
		gizmo = null
		for (var/a_gizmo as anything in gizmoes)
			qdel(a_gizmo)
		gizmoes = null
		..()


	get_desc(dist, mob/user)
		..()
		if (welded && isnull(gizmo))
			. += " Add a metal sheet to make a pipebomb frame."

	///We might have differing modules attached
	check_valid_stack(obj/item/atmospherics/pipeframe/regular/O)
		if (..()) //Includes welded check
			if ((gizmo && (!O.gizmo || !(O.gizmo.type == gizmo.type))) || (!gizmo && O.gizmo)) //mismatch of gizmo types
				return 0
		return 1

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
			if (W.amount > 1)
				W = W.split_stack(1)
			else
				user.u_equip(W)
			W.set_loc(src)
			gizmo = W
			gizmoes += W
			expected_connections = gizmo.expected_connections
			name = "[gizmo.assembly_prefix] pipe assembly"
			var/image/scrumpy = image(gizmo.icon, gizmo.icon_state)
			UpdateOverlays(scrumpy, "added_gizmo")
			return
		#endif
		..()

	build_a_pipe(turf/destination, orientation, direction)
		if (!gizmo)
			..()
		else
			gizmo.determine_and_place_machine(destination, orientation, direction)
			qdel(src)



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
	//The default behaviour is gonna be for 2-connection things that can't turn corners, which is simple as can be anyway
	if (orientation == (NORTH + SOUTH) || orientation == (EAST + WEST))
		new machine_path(destination, specify_direction = direction) //Should set up directional pumps and stuff correctly too

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
	<a href='?src=\ref[src];action=straight_NS'>|</a> ‧
	<a href='?src=\ref[src];action=straight_EW'>─</a> ‧
	<a href='?src=\ref[src];action=corner_SE'>┌</a> ‧
	<a href='?src=\ref[src];action=corner_SW'>┐</a> ‧
	<a href='?src=\ref[src];action=corner_NE'>└</a> ‧
	<a href='?src=\ref[src];action=corner_NW'>┘</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>3 Connections</b>
	<a href='?src=\ref[src];action=junc_N'>┴</a> ‧
	<a href='?src=\ref[src];action=junc_S'┬</a> ‧
	<a href='?src=\ref[src];action=junc_W'>┤</a> ‧
	<a href='?src=\ref[src];action=junc_E'>├</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Orientation & Single Connection</b>
	<a href='?src=\ref[src];action=north'>↑</a> ‧
	<a href='?src=\ref[src];action=south'>↓</a> ‧
	<a href='?src=\ref[src];action=west'>←</a> ‧
	<a href='?src=\ref[src];action=east'>→</a>
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
