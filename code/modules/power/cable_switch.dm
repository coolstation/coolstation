//A box you slap on wiring and then it toggles to separate or join powernets (similar to atmos valves)
//There's sprites for LOTO but there's no code for that atm.

///Thing you slap onto the wiring
/obj/item/breaker_box
	name = "breaker box"
	desc = "Used to separate sections of station wiring."
	icon = 'icons/obj/machines/power.dmi'
	icon_state = "cable_switch-off"

/obj/item/breaker_box/afterattack(atom/target, mob/user, reach, params)
	if (isturf(target))
		var/turf/place = target
		if (place.intact)
			return
		var/obj/cable/thing = locate(/obj/cable) in target //Find out if there's any cable here at all
		if (isnull(thing))
			boutput(user, "<span class='alert'>You need to place this somewhere there's a cable.</span>")
			return
		new /obj/machinery/power/breaker(target)
		user.u_equip(src)
		qdel(src)
		return
	else if (istype(target, /obj/cable))
		new /obj/machinery/power/breaker(get_turf(target))
		user.u_equip(src)
		qdel(src)
		return
	..()

//--------------------------------------

///This is the placed switch
/obj/machinery/power/breaker
	name = "breaker" //IDK what you'd call these in real life
	desc = "A red light means closed circuit, a yellow one means open circuit."
	icon_state = "cable_switch-live"
	level = 1 //for hide()
	var/live = TRUE //Defaulting to live wiring

	off //Guessing this might be of use for mappers
		live = FALSE
		icon_state = "cable_switch-off"

///Break the nets if we spawn off
/obj/machinery/power/breaker/New()
	..()
	SPAWN_DBG(1 SECOND) //How long does it take for all the powernets to spawn and shit? IDK
		if (!live)
			break_nets()
	var/turf/place = get_turf(src)
	if (!istype(place, /turf/space))
		hide(place.intact)


/obj/machinery/power/breaker/disposing()
	if (!live)
		merge_nets()
	..()


/obj/machinery/power/breaker/attack_hand(mob/user)
	if (!ON_COOLDOWN(src, "toggle", 1 SECOND)) //Please don't spam powernet rebuilds
		toggle()
	..()

///Disassembling a breaker
/obj/machinery/power/breaker/attackby(obj/item/W, mob/user)
	if (istool(W, TOOL_WRENCHING))
		playsound(src, "sound/items/Ratchet.ogg", 50, 1)
		new /obj/item/breaker_box(get_turf(src))
		qdel(src)
	..()

/obj/machinery/power/breaker/hide(var/intact) //I copied this from somewhere it probably works
		invisibility = intact ? INVIS_ALWAYS : INVIS_NONE	// hide if floor is intact

///Toggle or set the switch' state
/obj/machinery/power/breaker/proc/toggle(newstate = null) //Set newstate if you want to ensure it's on or off instead of flipping I guess
	if (live || newstate == "off")
		live = FALSE
		break_nets()
		icon_state = "cable_switch-off"
	else if (!live || newstate == "live" || newstate == "on") //"Live" is the electrical term but lord knows everything else is off/on
		live = TRUE
		merge_nets()
		icon_state = "cable_switch-live"

/obj/machinery/power/breaker/proc/merge_nets()
	for (var/obj/cable/C in get_turf(src))
		if (C.is_a_node)
			dirty_pnet_nodes |= C.is_a_node
			for (var/neighbour_node in C.is_a_node.adjacent_nodes)
				if (istype(C.is_a_node.adjacent_nodes[neighbour_node], /datum/powernet_graph_link))
					var/datum/powernet_graph_link/a_linke = C.is_a_node.adjacent_nodes[neighbour_node]
					a_linke.active++
				else
					var/bwebbo = C.is_a_node.adjacent_nodes[neighbour_node]
					for(var/datum/powernet_graph_link/an_linke in bwebbo)
						an_linke.active++

			//We broke direct node connections so restoring time
			var/list/connections = C.get_connections()
			for(var/obj/cable/C2 in connections)
				if (C2.is_a_node)
					if (C2.is_a_node in C.is_a_node.adjacent_nodes)
						var/bweb = C.is_a_node.adjacent_nodes[C2.is_a_node]
						if (islist(bweb))
							C.is_a_node.adjacent_nodes[C2.is_a_node] += null
							C2.is_a_node.adjacent_nodes[C.is_a_node] += null
						else
							C.is_a_node.adjacent_nodes[C2.is_a_node] = list(C.is_a_node.adjacent_nodes[C2.is_a_node],null)
							C2.is_a_node.adjacent_nodes[C.is_a_node] = list(C2.is_a_node.adjacent_nodes[C.is_a_node],null)
		else if (C.is_a_link)
			dirty_pnet_nodes |= C.is_a_link.adjacent_nodes
			C.is_a_link.active--


	if (!(explosions.exploding || defer_powernet_rebuild) && length(dirty_pnet_nodes))
		for(var/datum/powernet_graph_node/node as anything in dirty_pnet_nodes)
			node.validate()

/obj/machinery/power/breaker/proc/break_nets()
	//defer_powernet_rebuild = TRUE
	//netnum = -1 // haha I sure as shit didn't think it was still connecting the pnet halves through the switch itelf
	for (var/obj/cable/C in get_turf(src))
		if (C.is_a_node)
			for (var/neighbour_node in C.is_a_node.adjacent_nodes)
				if (istype(C.is_a_node.adjacent_nodes[neighbour_node], /datum/powernet_graph_link))
					var/datum/powernet_graph_link/a_linke = C.is_a_node.adjacent_nodes[neighbour_node]
					a_linke.active--
				else
					var/bweb = C.is_a_node.adjacent_nodes[neighbour_node]
					if (islist(bweb))
						for(var/datum/powernet_graph_link/an_linke in bweb)
							an_linke.active--
				C.is_a_node.adjacent_nodes[neighbour_node] -= null

		else if (C.is_a_link)
			dirty_pnet_nodes |= C.is_a_link.adjacent_nodes
			C.is_a_link.active--
		/*var/cable_netnum = C.get_netnumber()
		if(cable_netnum && powernets && powernets.len >= cable_netnum)		// Make sure cable & powernet data is valid
			C.open_circuit = TRUE
			var/datum/powernet/PN = powernets[cable_netnum]
			PN.cut_cable(C)	// Update the powernets
			*/

		//netnum = -1 // I don't really understand powernet propagation code but this seems necessary if there's multiple cables on a turf.
	//defer_powernet_rebuild = FALSE

	if (!(explosions.exploding || defer_powernet_rebuild) && length(dirty_pnet_nodes))
		for(var/datum/powernet_graph_node/node as anything in dirty_pnet_nodes)
			node.validate()
