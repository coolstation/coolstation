/*
Quick overview:

Pipes combine to form pipelines
Pipelines and other atmospheric objects combine to form pipe_networks
	Note: A single pipe_network represents a completely open space

Pipes -> Pipelines
Pipelines + Other Objects -> Pipe network

*/
//
obj/machinery/atmospherics
	anchored = ANCHORED
	layer = 2.12

	var/generic_decon_time = 10 SECONDS //default is kinda long cause I figured the larger complex machines wouldn't be grouped together, but lower when appropriate
	var/generic_decon_module = null
	var/initialize_directions = 0

	//This lets built atmos equipment set the thing's direction before it initialises
	New(loc, specify_direction = null)
		..()
		if (!isnull(specify_direction))
			dir = specify_direction

	process()
		build_network()
		..()

	// override default subscribes to be in a different process loop. that's why they don't call parent ( ..() )
	SubscribeToProcess()
		START_TRACKING_CAT(TR_CAT_ATMOS_MACHINES)

	UnsubscribeProcess()
		STOP_TRACKING_CAT(TR_CAT_ATMOS_MACHINES)

	attackby(obj/item/I, mob/user)
		if (!(isconstructionturf(src.loc)))
			return ..()
		if (!src.deconstruct_flags) //generic atmos deconstruction
			var/obj/item/weldingtool/W
			if ((isweldingtool(I) && user.find_tool_in_hand(TOOL_SAWING))) //welder with saw off-hand
				W = I //we need to typecast for the other branch anyway might as well
				if (W.try_weld(user,0.5))
					SETUP_GENERIC_ACTIONBAR(user, src, src.generic_decon_time, PROC_REF(generic_deconstruct), null, 'icons/ui/actions.dmi', "decon", null, null)
					return
			else if (istool(I, TOOL_SAWING)) //saw with welder off-hand
				W = user.find_tool_in_hand(TOOL_WELDING)
				if (W?.try_weld(user,0.5))
					SETUP_GENERIC_ACTIONBAR(user, src, src.generic_decon_time, PROC_REF(generic_deconstruct), null, 'icons/ui/actions.dmi', "decon", null, null)
					return
		..()

	proc
		network_disposing(datum/pipe_network/reference)
			// Called by a network associated with this machine when it is being disposed
			// This must be implemented to unhook any references to the network

			return null

		network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
			// Check to see if should be added to network. Add self if so and adjust variables appropriately.
			// Note don't forget to have neighbors look as well!

			return null

		build_network()
			// Called to build a network from this node

			return null

		return_network(obj/machinery/atmospherics/reference)
			// Returns pipe_network associated with connection to reference
			// Notes: should create network if necessary
			// Should never return null

			return null

		reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
			// Used when two pipe_networks are combining

		return_network_air(datum/pipe_network/reference)
			// Return a list of gas_mixture(s) in the object
			//		associated with reference pipe_network for use in rebuilding the networks gases list
			// Is permitted to return null

		disconnect(obj/machinery/atmospherics/reference)

		///welder + saw deconstruction
		generic_deconstruct(obj/item/atmospherics/pipeframe/regular/PF)
			//this is where you'd have Consequences for piercing a high pressure gas line
			if (!PF)
				PF =  new /obj/item/atmospherics/pipeframe/regular/pre_welded(src.loc) //player's hands are full anyway, may as well drop it
				if (generic_decon_module) //add module if specified
					var/obj/item/atmospherics/module/M = new generic_decon_module(PF)
					PF.gizmo = M

					PF.expected_connections = PF.gizmo.expected_connections
					PF.name = "[PF.gizmo.assembly_prefix] pipe assembly"
					PF.orientation_instructions = PF.gizmo.module_instructions

					var/image/scrumpy = image(PF.gizmo.icon, PF.gizmo.icon_state)
					PF.UpdateOverlays(scrumpy, "added_gizmo")
			qdel(src)

		sync_node_connections()
			// For each node you have that isn't null, call sync_connect()
			// I needed this to sync up node vars for constructable atmos

		sync_connect(obj/machinery/atmospherics/reference)
			// Check if reference isn't already a node, connect if not etc.

		connect(dir)
			if (!(initialize_directions & dir)) //Not gonna connect to shit we shouldn't
				return null
			for(var/obj/machinery/atmospherics/target in get_step(src,dir))
				if(target.initialize_directions & get_dir(target,src))
					return target
			return null
			// Find a suitable atmos machine to connect to
			// Replaces the many identical for loops across atmos machine code + needed for constructable atmos

		update_icon()
			return null
