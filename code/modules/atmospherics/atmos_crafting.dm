///Craftable atmospheric machinery
//This code of ????? quality brought to you by BatElite and probably improved on by others later

/*

CONTENTS IN ORDER OR APPEARANCE:
-Pipe frame assembly parent & code (atmos only, pipebombs are in code/obj/item/grenades.dm)
-Atmos modules
-Atmos vending machine
-Atmos crafting orientation component
-Debug atmos bapper


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
///A global toggle just in case, disables adding modules to frames and deletes the vending machine when off. Pipebomb crafting remains possible if this is disabled
#define ENABLE_ATMOS_BUILDY


///This isn't a proper thing but I figured it'd be nice on the object tree to group it all under one parent
ABSTRACT_TYPE(/obj/item/atmospherics)
/obj/item/atmospherics
	icon = 'icons/obj/atmospherics/atmos_parts.dmi'

///Parent crafting item, the pipe frame end of things. BTW these are stackable watch out
ABSTRACT_TYPE(/obj/item/atmospherics/pipeframe)
/obj/item/atmospherics/pipeframe
	name = "the platonic ideal of atmospheric piping frame"
	desc = "Small pipes made to exchange heat inside with their environment."
	icon_state = "conduit_to-weld"
	///What does this look like after welding?
	var/icon_welded
	///What's this going to turn into when deployed (sans gizmo)?
	var/frame_makes = /obj/machinery/atmospherics
	var/welded = FALSE
	///The amount of connections this frame/assembly needs, gets overridden when a module is added
	var/expected_connections = 2
	///Gets slapped into the orientation HTML, basically "how the fuck do I place this", overridden by module
	var/orientation_instructions = "Just slap it down IDK"
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
		if (istype(newstack) && src.welded) //Parent call failed
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
			if (!validate_settings(pipe_settings.orientation, pipe_settings.no_of_connections, user))
				return
			var/obj/machinery/atmospherics/newthing = build_a_pipe(target, pipe_settings.orientation, user)
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

		else if (..()) //We've probably been picked up (at least that seems to be what attack_hand on items is doing)
			if (src.welded && winget(user, "atmospipecrafting", "is-visible") == "true") //They've got the laying window open
				var/datum/component/atmos_crafty/their_menu = user.GetComponent(/datum/component/atmos_crafty)
				their_menu.showPanel(src.name, orientation_instructions) //Update the instructions to this frame's :3

	///Bring up the orientation panel
	attack_self(mob/user)
		if (!welded)
			return ..()
		var/datum/component/atmos_crafty/blepperdy_bloop = user.GetComponent(/datum/component/atmos_crafty)
		if (!isnull(blepperdy_bloop))
			blepperdy_bloop.showPanel(src.name, orientation_instructions)
		else //Set em up with one of these if they're so gosh dang interested
			blepperdy_bloop = user.AddComponent(/datum/component/atmos_crafty)
			blepperdy_bloop.showPanel(src.name, orientation_instructions)
		. = ..()

///This proc mostly exists so that it can be overridden for the purpose of pipe manifolds
/obj/item/atmospherics/pipeframe/proc/validate_settings(orientation, no_of_connections, mob/user)
	return (no_of_connections == expected_connections)

///Try to put up a pipe
/obj/item/atmospherics/pipeframe/proc/build_a_pipe(turf/destination, orientation, mob/user)
	switch (orientation)
		if ((EAST + WEST))
			return new frame_makes(destination, EAST) //EAST and NORTH are lower numbers, but mostly simple pipes don't give a shit which way round they go
		if ((NORTH + SOUTH))
			return new frame_makes(destination, NORTH)
		if (NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST) //pipes are one of those fucked up things where corner sprites are assigned to the diagonals
			return new frame_makes(destination, orientation)


//Temperature exchanging piping
/obj/item/atmospherics/pipeframe/exchanger
	name = "heat conduit pipe frame"
	desc = "Small pipes made to exchange heat inside with their environment."
	icon_state = "conduit_to-weld"
	icon_welded = "frame_conduit"
	frame_makes = /obj/machinery/atmospherics/pipe/simple/heat_exchanging
	orientation_instructions = "Straight and corner pieces only, direction does not matter."

	pre_welded
		welded = TRUE
		icon_state = "frame_conduit"


//The bit that going between normal piping and heat exchangers. Build direction points to the exchanger side
/obj/item/atmospherics/pipeframe/exchanger_regular_junction
	name = "heat conduit pipe junction"
	desc = "A thing to convert from regular to heat exchanging pipes. "
	icon_state = "junction_to-weld"
	frame_makes = /obj/machinery/atmospherics/pipe/simple/junction
	icon_welded = "frame_junction"
	orientation_instructions = "Straight pieces only, set direction to the side the exchanger end should be on."

	pre_welded
		welded = TRUE
		icon_state = "frame_junction"

	build_a_pipe(turf/destination, orientation, mob/user) //these don't do corners
		if (orientation == (NORTH + SOUTH))
			var/direction = alert("What side should the exchanging side go?",,"North","South")
			if (IN_RANGE(user, destination, 1))
				return new frame_makes(destination, direction == "North" ? NORTH : SOUTH)

		if (orientation == (EAST + WEST))
			var/direction = alert("What side should the exchanging side go?",,"West","East")
			if (IN_RANGE(user, destination, 1))
				return new frame_makes(destination, direction == "West" ? WEST : EAST)

		if (orientation in cardinal)
			return new frame_makes(destination, orientation)//Shove exchanger end towards orientation fuck it

	validate_settings(orientation, no_of_connections, mob/user)
		return (no_of_connections <= expected_connections)




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
	orientation_instructions = "Regular pipes can be placed in any 2 or 3 connection orientation, the latter making manifolds."

	pre_welded
		welded = TRUE
		icon_state = "Pipe_Hollow"

	disposing() //TODO hey what the fuck was I doing here this seems like a terrible plan??
		if (gizmo?.loc == src) //This is the bullshit that will let us split off of stack of gizmoed frames without spawning a gizmo every time
			qdel(gizmo) //Basically until we're
		gizmo = null
		..()


	get_desc(dist, mob/user)
		..()
		if (welded && isnull(gizmo))
			. += " Add a metal sheet to make a pipebomb frame."
		if (!welded)
			. += " You'll have to weld the seam shut first."

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
			to_b_combined.orientation_instructions = to_b_combined.gizmo.module_instructions

			var/image/scrumpy = image(to_b_combined.gizmo.icon, to_b_combined.gizmo.icon_state)
			to_b_combined.UpdateOverlays(scrumpy, "added_gizmo")
			if (to_b_combined != src)
				user.put_in_hand_or_drop(to_b_combined)
			return
		#endif
		..()

	build_a_pipe(turf/destination, orientation, mob/user)

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
			return gizmo.determine_and_place_machine(destination, orientation, user)

	validate_settings(orientation, no_of_connections, mob/user)
		if (!gizmo)
			if (no_of_connections == 3) //manifold time
				return 1
		return (no_of_connections == expected_connections || (expected_connections == 2 && no_of_connections == 1)) //Allows the direction-as-output shortcut







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
	///These override orientation_instructions on the pipe frame
	var/module_instructions = "Someone didn't write instructions for me :)"

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
/obj/item/atmospherics/module/proc/determine_and_place_machine(turf/destination, orientation, user)
	//This handles 1-connection and 2-connection valves, leaving various pumps, manifold valve, filter & mixer
	if (expected_connections <= 2 && (orientation in cardinal)) // the <= 2 is a shortcut to place pumps & stuff outputting towards orientation
		return new machine_path(destination, orientation)
	else if (expected_connections == 2)
		if (orientation == (NORTH + SOUTH))
			return new machine_path(destination, NORTH)
		if (orientation == (EAST + WEST))
			return new machine_path(destination, EAST)
	return 0


//---------------------------Modules!-----------------------------

/obj/item/atmospherics/module/valve
	name = "valve module"
	icon_state = "valve_module"
	assembly_prefix = "valve"
	machine_path = /obj/machinery/atmospherics/valve
	module_instructions = "Straight only."

/obj/item/atmospherics/module/digital_valve
	name = "digital valve module"
	icon_state = "digital-valve_module"
	assembly_prefix = "digital valve"
	machine_path = /obj/machinery/atmospherics/valve/digital
	module_instructions = "Straight only."

/obj/item/atmospherics/module/manifold_valve
	name = "manifold valve module"
	icon_state = "manifold-valve_module"
	assembly_prefix = "manifold valve"
	machine_path = /obj/machinery/atmospherics/manifold_valve
	expected_connections = 3
	module_instructions = "Any junction."

	determine_and_place_machine(turf/destination, orientation, user) //Manifold valve sprites point in the one direction they DON'T have a connection to
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
	module_instructions = "Any junction."

	determine_and_place_machine(turf/destination, orientation, user)
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
	module_instructions = "Any junction, output direction is asked upon placement."

	//For understanding this I'd suggest keeping the mixer icon states on hand, but the gist is mixers output towards dir and are right-handed by default.
	determine_and_place_machine(turf/destination, orientation, user)
		var/direction
		switch (orientation)
			if (NORTH + SOUTH + EAST)
				direction = alert("What side should the mixer output to?",,"North","South")
				if (IN_RANGE(user, destination, 1))
					return new machine_path(destination, (direction == "South" ? SOUTH : NORTH), (direction == "South" ? TRUE : FALSE)) //Third argument is for flipping the mixer

			if (SOUTH + EAST + WEST)
				direction = alert("What side should the mixer output to?",,"West","East")
				if (IN_RANGE(user, destination, 1))
					return new machine_path(destination, (direction == "West" ? WEST : EAST), (direction == "West" ? TRUE : FALSE))

			if (EAST + WEST + NORTH)
				direction = alert("What side should the mixer output to?",,"West","East")
				if (IN_RANGE(user, destination, 1))
					return new machine_path(destination, (direction == "West" ? WEST : EAST), (direction == "West" ? FALSE : TRUE))

			if (WEST + NORTH + SOUTH)
				direction = alert("What side should the mixer output to?",,"North","South")
				if (IN_RANGE(user, destination, 1))
					return new machine_path(destination, (direction == "South" ? SOUTH : NORTH), (direction == "South" ? FALSE : TRUE))
		return 0


/obj/item/atmospherics/module/connector
	name = "connector port module"
	icon_state = "connector_module"
	assembly_prefix = "connector port"
	machine_path = /obj/machinery/atmospherics/portables_connector
	expected_connections = 1
	module_instructions = "Connects towards orientation."

/obj/item/atmospherics/module/vent
	name = "vent module"
	icon_state = "vent_module"
	assembly_prefix = "vent"
	machine_path = /obj/machinery/atmospherics/pipe/vent
	expected_connections = 1
	module_instructions = "Connects towards orientation."

//--Things are kinda sorted by type, binary machines are up next and unary comes after that

/obj/item/atmospherics/module/pump
	name = "pump module"
	icon_state = "pump_module"
	assembly_prefix = "pump"
	machine_path = /obj/machinery/atmospherics/binary/pump
	module_instructions = "Straight only."

	determine_and_place_machine(turf/destination, orientation, user)
		if (orientation == (NORTH + SOUTH))
			var/direction = alert("What side should the pump output?",,"North","South")
			if (IN_RANGE(user, destination, 1))
				return new machine_path(destination, direction == "North" ? NORTH : SOUTH)

		if (orientation == (EAST + WEST))
			var/direction = alert("What side should the pump output?",,"West","East")
			if (IN_RANGE(user, destination, 1))
				return new machine_path(destination, direction == "West" ? WEST : EAST)
		return ..()

/obj/item/atmospherics/module/volume_pump
	name = "volume pump module"
	icon_state = "volume-pump_module"
	assembly_prefix = "volume pump"
	machine_path = /obj/machinery/atmospherics/binary/volume_pump
	module_instructions = "Straight only."

	determine_and_place_machine(turf/destination, orientation, user)
		if (orientation == (NORTH + SOUTH))
			var/direction = alert("What side should the volume pump output?",,"North","South")
			if (IN_RANGE(user, destination, 1))
				return new machine_path(destination, direction == "North" ? NORTH : SOUTH)

		if (orientation == (EAST + WEST))
			var/direction = alert("What side should the volume pump output?",,"West","East")
			if (IN_RANGE(user, destination, 1))
				return new machine_path(destination, direction == "West" ? WEST : EAST)
		return ..()

/obj/item/atmospherics/module/dp_vent
	name = "dual port vent module"
	icon_state = "dp-vent_module"
	assembly_prefix = "dual port vent"
	machine_path = /obj/machinery/atmospherics/binary/dp_vent_pump
	module_instructions = "Straight only."

	determine_and_place_machine(turf/destination, orientation, user)
		if (orientation == (NORTH + SOUTH))
			var/direction = alert("What side should the vent pump output?",,"North","South")
			if (IN_RANGE(user, destination, 1))
				return new machine_path(destination, direction == "North" ? NORTH : SOUTH)

		if (orientation == (EAST + WEST))
			var/direction = alert("What side should the vent pump output?",,"West","East")
			if (IN_RANGE(user, destination, 1))
				return new machine_path(destination, direction == "West" ? WEST : EAST)
		return ..()

/obj/item/atmospherics/module/passive_gate
	name = "passive gate module"
	icon_state = "passive-gate_module"
	assembly_prefix = "passive gate"
	machine_path = /obj/machinery/atmospherics/binary/passive_gate
	module_instructions = "Straight only."

	determine_and_place_machine(turf/destination, orientation, user)
		if (orientation == (NORTH + SOUTH))
			var/direction = alert("What side should the passive gate output?",,"North","South")
			if (IN_RANGE(user, destination, 1))
				return new machine_path(destination, direction == "North" ? NORTH : SOUTH)

		if (orientation == (EAST + WEST))
			var/direction = alert("What side should the passive gate output?",,"West","East")
			if (IN_RANGE(user, destination, 1))
				return new machine_path(destination, direction == "West" ? WEST : EAST)
		return ..()

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
	module_instructions = "Connects towards orientation."

/obj/item/atmospherics/module/outlet_injector
	name = "outlet injector module"
	icon_state = "injector_module"
	assembly_prefix = "outlet injector"
	machine_path = /obj/machinery/atmospherics/unary/outlet_injector
	expected_connections = 1
	module_instructions = "Connects towards orientation."

/obj/item/atmospherics/module/vent_pump
	name = "vent pump module"
	icon_state = "vent-pump_module"
	assembly_prefix = "vent pump"
	machine_path = /obj/machinery/atmospherics/unary/vent_pump
	expected_connections = 1
	module_instructions = "Connects towards orientation."

/obj/item/atmospherics/module/vent_scrubber
	name = "vent scrubber module"
	icon_state = "vent-scrubber_module"
	assembly_prefix = "vent scrubber"
	machine_path = /obj/machinery/atmospherics/unary/vent_scrubber
	expected_connections = 1
	module_instructions = "Connects towards orientation."

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
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/pocketguide/atmos, 1)
		product_list += new/datum/data/vending_product(/obj/item/deconstructor, 2)
		product_list += new/datum/data/vending_product(/obj/item/weldingtool, 3)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/valve, 15)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/digital_valve, 15)
		product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/manifold_valve, 10)
		//product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/filter, 5)
		//product_list += new/datum/data/vending_product(/obj/item/atmospherics/module/mixer, 5)
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
	//Amount of connections of the current selection (so we don't have to fuck around with orientation to get the number)
	var/no_of_connections = 2

	///cache of the last assembly name we got, for post-Topic updates
	var/last_name = null
	///cache of the last assembly instructions we got, for post-Topic updates
	var/last_instructions = null
	///Text version for the HTML
	var/orientation_text = "north to south"
	//From here on out I copy-pasted the admin antag popups debug and started editing GLHF (that's also why the style is called antagType)
	var/html

	proc/generateHTML(assembly_name = null, orientation_instructions = null)

		if (assembly_name)
			last_name = assembly_name
		if (orientation_instructions)
			last_instructions = orientation_instructions

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
	<b>Orientation:</b> [orientation_text]<br>
</head>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>2 Connections</b>
	<font size="5">
	<a href='byond://?src=\ref[src];action=straight_NS'>|</a> ‧
	<a href='byond://?src=\ref[src];action=straight_EW'>─</a> ‧
	<a href='byond://?src=\ref[src];action=corner_SE'>┌</a> ‧
	<a href='byond://?src=\ref[src];action=corner_SW'>┐</a> ‧
	<a href='byond://?src=\ref[src];action=corner_NE'>└</a> ‧
	<a href='byond://?src=\ref[src];action=corner_NW'>┘</a>
	</font>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>3 Connections</b>
	<font size="5">
	<a href='byond://?src=\ref[src];action=junc_N'>┴</a> ‧
	<a href='byond://?src=\ref[src];action=junc_S'>┬</a> ‧
	<a href='byond://?src=\ref[src];action=junc_W'>┤</a> ‧
	<a href='byond://?src=\ref[src];action=junc_E'>├</a>
	</font>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>1 Connection</b>
	<font size="5">
	<a href='byond://?src=\ref[src];action=north'>↑</a> ‧
	<a href='byond://?src=\ref[src];action=south'>↓</a> ‧
	<a href='byond://?src=\ref[src];action=west'>←</a> ‧
	<a href='byond://?src=\ref[src];action=east'>→</a>
	</font>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>[last_name]</b>
	[last_instructions]
</div>
"}

		return html

	proc/showPanel(assembly_name = null, orientation_instructions = null)
		if (!generateHTML(assembly_name, orientation_instructions))
			alert("Unable to generate pipe orientation panel panel! Something's gone wacky!")
			return

		usr.Browse(html, "window=atmospipecrafting;size=350x400")

	Topic(href, href_list)
		if (!ismob(usr))
			alert("How the hell are you not a mob?! I can't show the panel to you, you don't exist!")
			return

		switch(href_list["action"])
			// 2 connections
			if ("straight_NS")
				orientation = NORTH + SOUTH
				no_of_connections = 2
				orientation_text = "north to south"
			if ("straight_EW")
				orientation = EAST + WEST
				no_of_connections = 2
				orientation_text = "east to west"
			if ("corner_SW")
				orientation = SOUTH + WEST
				no_of_connections = 2
				orientation_text = "south-to-west corner"
			if ("corner_SE")
				orientation = SOUTH + EAST
				no_of_connections = 2
				orientation_text = "south-to-east corner"
			if ("corner_NW")
				orientation = NORTH + WEST
				no_of_connections = 2
				orientation_text = "north-to-west corner"
			if ("corner_NE")
				orientation = NORTH + EAST
				no_of_connections = 2
				orientation_text = "north-to-east corner"

			// 3 connections
			if ("junc_N")
				orientation = NORTH + EAST + WEST
				no_of_connections = 3
				orientation_text = "north, east to west junction"
			if ("junc_S")
				orientation = SOUTH + EAST + WEST
				no_of_connections = 3
				orientation_text = "south, east to west junction"
			if ("junc_W")
				orientation = NORTH + SOUTH + WEST
				no_of_connections = 3
				orientation_text = "west, north to south junction"
			if ("junc_E")
				orientation = NORTH + SOUTH + EAST
				no_of_connections = 3
				orientation_text = "east, north to south junction"

			// single connection
			if ("north")
				orientation = NORTH
				no_of_connections = 1
				orientation_text = "north"
			if ("south")
				orientation = SOUTH
				no_of_connections = 1
				orientation_text = "south"
			if ("east")
				orientation = EAST
				no_of_connections = 1
				orientation_text = "east"
			if ("west")
				orientation = WEST
				no_of_connections = 1
				orientation_text = "west"

		usr.Browse(generateHTML(), "window=atmospipecrafting;size=350x400") //update window to new settings

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

//Gonna steal a lot from the geothermal dowsing rods, but I feel there's not enough overlap to justify making this a subtype
/obj/item/atmospherics/purger
	name = "pipeline gas purger"
	desc = "A machine that attaches to pipes and slowly disintegrates gases inside them"
	icon_state = "purger_undeployed"
	w_class = W_CLASS_NORMAL
	//All of this is just copied from the dowsing rod
	throwforce = 6
	force = 6
	throw_speed = 4
	throw_range = 5
	stamina_damage = 30
	stamina_cost = 15
	stamina_crit_chance = 1
	///This many moles will be deleted per item process tick
	var/moles_per_tick = 2 //For reference, an O2/plasma/CO2/N2O can has ~1,8k moles. N2 has like 6,5k and air cans much more
	var/deployed = FALSE
	var/obj/machinery/atmospherics/pipe/currently_attached
/obj/item/atmospherics/purger/afterattack(obj/machinery/atmospherics/pipe/P, var/mob/user)
	if (istype(P))
		user.drop_item()
		src.set_loc(get_turf(P))
		src.deploy(P)
		return
	..()
/obj/item/atmospherics/purger/process()
	..() //Something about timekeeping in here? IDK
	if ((istype(currently_attached) && !currently_attached.disposed && (src.loc != get_turf(currently_attached)))) //not a valid pipe or we've somehow come off of the pipe
		undeploy()
		return
	var/datum/pipeline/pipeline = currently_attached.parent
	if (!pipeline)
		return
	var/datum/gas_mixture/gas2purge = pipeline.air
	if (!gas2purge)
		UpdateOverlays(null, "plasma")
		return
	if (gas2purge.remove(moles_per_tick))
		UpdateOverlays(image(src.icon, "purger_effect"), "plasma")
	else
		UpdateOverlays(null, "plasma")
///Undeploy when moved (including on pickup, I'm pretty sure)
/obj/item/atmospherics/purger/set_loc(newloc)
	if (deployed)
		undeploy()
	..()
/obj/item/atmospherics/purger/proc/deploy(obj/machinery/atmospherics/pipe/attach_to)
	if (istype(attach_to))
		deployed = TRUE
		processing_items |= src
		icon_state = "purger_deployed"
		currently_attached = attach_to
/obj/item/atmospherics/purger/proc/undeploy()
	currently_attached = null
	processing_items -= src
	deployed = FALSE
	icon_state = "purger_undeployed"
	UpdateOverlays(null, "plasma")
