//A box you slap on wiring and then it toggles to separate or join powernets (similar to atmos valves)
//There's sprites for LOTO but there's no code for that atm.

///Thing you slap onto the wiring
/obj/item/cable_switch_box
	name = "cable switch box"
	desc = "Used to separate sections of station wiring."
	icon = 'icons/obj/power.dmi'
	icon_state = "cable_switch-off"

/obj/item/cable_switch_box/afterattack(atom/target, mob/user, reach, params)
	if (isturf(target))
		var/turf/place = target
		if (place.intact)
			return
		var/obj/cable/thing = locate(/obj/cable) in target //Find out if there's any cable here at all
		if (isnull(thing))
			boutput(user, "<span class='alert'>You need to place this somewhere there's a cable.</span>")
			return
		new /obj/machinery/power/cable_switch(target)
		user.u_equip(src)
		qdel(src)
		return
	else if (istype(target, /obj/cable))
		new /obj/machinery/power/cable_switch(get_turf(target))
		user.u_equip(src)
		qdel(src)
		return
	..()

//--------------------------------------

///This is the placed switch
/obj/machinery/power/cable_switch
	name = "cable switch" //IDK what you'd call these in real life
	desc = "uhhhhh"
	icon_state = "cable_switch-live"
	level = 1 //for hide()
	var/live = TRUE //Defaulting to live wiring

	off //Guessing this might be of use for mappers
		live = FALSE
		icon_state = "cable_switch-off"

///Break the nets if we spawn off
/obj/machinery/power/cable_switch/New()
	..()
	SPAWN_DBG(1 SECOND) //How long does it take for all the powernets to spawn and shit? IDK
		if (!live)
			break_nets()
	var/turf/place = get_turf(src)
	if (!istype(place, /turf/space))
		hide(place.intact)


/obj/machinery/power/cable_switch/disposing()
	if (!live)
		merge_nets()
	..()


/obj/machinery/power/cable_switch/attack_hand(mob/user)
	if (!ON_COOLDOWN(src, "toggle", 1 SECOND)) //Please don't spam powernet rebuilds
		toggle()
	..()

///Disassembling a cable switch
/obj/machinery/power/cable_switch/attackby(obj/item/W, mob/user)
	if (istool(W, TOOL_WRENCHING))
		playsound(src, "sound/items/Ratchet.ogg", 50, 1)
		new /obj/item/cable_switch_box(get_turf(src))
		qdel(src)
	..()

/obj/machinery/power/cable_switch/hide(var/intact) //I copied this from somewhere it probably works
		invisibility = intact ? INVIS_ALWAYS : INVIS_NONE	// hide if floor is intact

///Toggle or set the switch' state
/obj/machinery/power/cable_switch/proc/toggle(newstate = null) //Set newstate if you want to ensure it's on or off instead of flipping I guess
	if (live || newstate == "off")
		live = FALSE
		break_nets()
		icon_state = "cable_switch-off"
	else if (!live || newstate == "live" || newstate == "on") //"Live" is the electrical term but lord knows everything else is off/on
		live = TRUE
		merge_nets()
		icon_state = "cable_switch-live"

/obj/machinery/power/cable_switch/proc/merge_nets()
	underlays = null
	for (var/obj/cable/C in src)
		C.set_loc(get_turf(src))
		C.update_network()

/obj/machinery/power/cable_switch/proc/break_nets()
	defer_powernet_rebuild = TRUE
	netnum = -1 // haha I sure as shit didn't think it was still connecting the pnet halves through the switch itelf
	for (var/obj/cable/C in get_turf(src))
		if(C.netnum && powernets && powernets.len >= C.netnum)		// Make sure cable & powernet data is valid
			var/datum/powernet/PN = powernets[C.netnum]
			PN.cut_cable(C)	// Update the powernets
			C.set_loc(src)
			var/image/sprot = image(C.icon, C.icon_state) //so we're just gonna slap the cable's sprite under us :)
			sprot.color = C.color
			underlays += sprot
		netnum = -1 // I don't really understand powernet propagation code but this seems necessary if there's multiple cables on a turf.
	defer_powernet_rebuild = FALSE
	makepowernets()
