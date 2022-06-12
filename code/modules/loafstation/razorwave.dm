/// Razorwave from Loafstation.
// sprites & sound by Kubius
// given w/ permission to coolstation


// Threat Assessment

/// Modifier against total threat for mobs wearing agent cards.
#define RAZORWAVE_AGENT_THREAT_MOD (-2)

/// Weight applied to contraband var of items.
#define RAZORWAVE_CONTRABAND_WEIGHT 0 // Set to 0.5 to scale razorwave to be more like security scanners.
/// Return the total threat of a given item.
#define ASSESS_ITEM_THREAT(_rz_i) (_rz_i?.contraband * RAZORWAVE_CONTRABAND_WEIGHT)


/// Return the threat level of a given human.
proc/razorwave_assess_threat(mob/living/carbon/human/target)
	var/total_threat = 0

	total_threat += ASSESS_ITEM_THREAT(target.l_hand)
	total_threat += ASSESS_ITEM_THREAT(target.r_hand)
	total_threat += ASSESS_ITEM_THREAT(target.l_store)
	total_threat += ASSESS_ITEM_THREAT(target.r_store)
	total_threat += ASSESS_ITEM_THREAT(target.wear_suit)

	total_threat += ASSESS_ITEM_THREAT(target.belt)
	for(var/obj/item/I in target.belt)
		total_threat += ASSESS_ITEM_THREAT(I)

	total_threat += ASSESS_ITEM_THREAT(target.back)
	for(var/obj/item/I in target.back)
		total_threat += ASSESS_ITEM_THREAT(I)

	if(istype(target.wear_id, /obj/item/card/id/syndicate))
		total_threat += RAZORWAVE_AGENT_THREAT_MOD

	return total_threat

// Razorwave components

/// Radio antenna used for the Razorwave. Single-use.
/obj/item/razorwave_antenna
	name = "hypertron beam array"
	desc = "A large, narrow cylinder with a nanofiber structure set up like antennae."
	icon_state = "antenna-long"
	icon = 'icons/loafstation/razorwave.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "rods"
	force = 3
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_NORMAL
	flags = FPRINT | TABLEPASS | CONDUCT
	var/overloaded = FALSE

	special_desc(dist, mob/user)
		. = ..()


// Razorwave device

/// Minimum threat level to be listed in the razorwave results
#define RAZORWAVE_MIN_THREAT_LEVEL 4

/// Device whichs scans every mob in the camera network for contraband and reports their identity, location, and threat level.
/obj/machinery/razorwave
	name = "interspatial visual aggregator"
	desc = "Metal box painstakingly designed to give you kidney damage. There's a slot where a disk should go."
	icon = 'icons/loafstation/razorwave.dmi'
	icon_state = "frame"
	density = TRUE
	anchored = TRUE
	req_access = list(access_heads)
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_MULTITOOL
	/// Antenna loaded into the device.
	var/obj/item/razorwave_antenna/antenna
	/// Action bar for scanning.
	var/datum/action/bar/razorwave/scanning

/obj/machinery/razorwave/disposing()
	..()
	qdel(src.antenna)
	qdel(src.scanning)
	src.scanning = null
	src.antenna = null

/obj/machinery/razorwave/proc/get_trackable_mobs()
	. = list()
	for (var/mob/M as anything in mobs) // mobs is safe to tcl
		if(!ishuman(M))
			continue
		if(M.z != 1 && M.z != src.z)
			continue
		if(!istype(M.loc, /turf))
			continue
		if(M.invisibility)
			continue
		var/turf/T = get_turf(M)
		if(!T.cameras || !length(T.cameras))
			continue
		. += M

/obj/machinery/razorwave/attack_hand(mob/user)
	add_fingerprint(user)
	if(!src.antenna || isintangible(user))
		return ..()
	if(src.scanning)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.gloves?.getProperty("heatProt") < 7)
				boutput(user, "<span class='alert'>You try to remove [src.antenna], but you burn your hand on it!</span>")
				H.TakeDamage(user.hand == 1 ? "l_arm" : "r_arm", 0, 5)
				return
		boutput(src, "<span class='alert'>\The [src.antenna] doesn't budge!</span>")
		return
	visible_message("<span class='notice'>[user] extracts [src.antenna] from [src].</span>")
	playsound(src, 'sound/items/Deconstruct.ogg', 40, 1)
	user.put_in_hand_or_eject(src.antenna)
	src.antenna = null
	update_icon()

/obj/machinery/razorwave/attackby(obj/item/I, mob/user)
	var/obj/item/disk/data/floppy/read_only/authentication/disk = I
	if(istype(disk))
		if(src.scanning)
			boutput(user, "<span class='alert'>\The [src] is already activated!</span>")
			return
		if(!src.allowed(user))
			boutput(user, "<span class='alert'>Access Denied.</span>")
			return
		if(!src.antenna)
			boutput(user, "<span class='alert'>\The [src] is missing it's antenna!</span>")
			return
		if(src.antenna.overloaded)
			boutput(user, "<span class'alert'>\The [src] is burned out, and can't be used again.</span>")
			return
		if(src.status & (NOPOWER|BROKEN))
			return
		visible_message("<span class='notice'>[user] activates [src].</span>")
		start_scan()
		return
	var/obj/item/razorwave_antenna/antenna = I
	if(istype(antenna))
		if(src.antenna)
			boutput(user, "<span class='alert'>\The [src] already has an antenna!</span>")
			return
		user.u_equip(antenna)
		antenna.set_loc(src)
		src.antenna = antenna
		visible_message("<span class='notice'>[user] inserts [antenna] into [src]</span>")
		playsound(src, 'sound/items/Deconstruct.ogg', 40, 1)
		update_icon()
		return
	..()

/obj/machinery/razorwave/proc/start_scan()
	if(src.status & (NOPOWER|BROKEN))
		return
	if(!src.antenna)
		stack_trace("razorwave scan started with no antenna")
		return
	playsound(src, 'sound/machines/razorwave_scour.ogg', 40, 0)
	actions.start(new/datum/action/bar/razorwave(src), src) // icon updates handled by the action bar.

/obj/machinery/razorwave/proc/finish_scan()
	var/report_text = "INTERSPATIAL AGGREGATION REPORT<hr>"
	for(var/mob/M as anything in src.get_trackable_mobs())
		var/threat_level = razorwave_assess_threat(M)
		if(threat_level >= RAZORWAVE_MIN_THREAT_LEVEL)
			report_text += "<b>[M]</b> in [get_area(M)], threat level [threat_level]<br>" // Let's ignore disguises for now.

	src.antenna.overloaded = TRUE

	var/obj/item/paper/result = unpool(/obj/item/paper)
	result.info = report_text
	result.set_loc(get_turf(src))
	playsound(src, "sparks", 75, 1, -1)


/obj/machinery/razorwave/power_change()
	. = ..()
	update_icon()


#define RAZORWAVE_OVERLAY_POWER "razorwave-power"
#define RAZORWAVE_OVERLAY_OVERLOAD "razorwave-overloaded"
#define RAZORWAVE_OVERLAY_ANTENNA "razorwave-antenna"

/obj/machinery/razorwave/proc/update_icon()
	if(status & (NOPOWER))
		UpdateOverlays(null, RAZORWAVE_OVERLAY_POWER)
		UpdateOverlays(null, RAZORWAVE_OVERLAY_OVERLOAD)
		return
	else
		UpdateOverlays(image('icons/loafstation/razorwave.dmi', "powered"), RAZORWAVE_OVERLAY_POWER)

	if(src.scanning)
		UpdateOverlays(image('icons/loafstation/razorwave.dmi', "online"), RAZORWAVE_OVERLAY_ANTENNA)
	else if(src.antenna)
		UpdateOverlays(image('icons/loafstation/razorwave.dmi', "antenna"), RAZORWAVE_OVERLAY_ANTENNA)
	else
		UpdateOverlays(null, RAZORWAVE_OVERLAY_ANTENNA)

	if(src.antenna?.overloaded)
		UpdateOverlays(image('icons/loafstation/razorwave.dmi', "overload"), RAZORWAVE_OVERLAY_OVERLOAD)
	else
		UpdateOverlays(null, RAZORWAVE_OVERLAY_OVERLOAD)


/datum/action/bar/razorwave
	duration = 15 SECONDS
	id = "razorwave"
	var/obj/machinery/razorwave/machine

	New(machine)
		..()
		src.machine = machine

	onStart()
		. = ..()
		src.machine.scanning = src
		machine.update_icon()

	onUpdate()
		..()
		if (machine.status & (NOPOWER | BROKEN) || !machine.antenna)
			interrupt(INTERRUPT_ALWAYS)
			return
		playsound(src, 'sound/machines/razorwave_scan.ogg', 40, 0)

	onEnd()
		..()
		machine.finish_scan()

	onDelete()
		. = ..()
		machine.scanning = null
		machine.update_icon()

#undef RAZORWAVE_OVERLAY_POWER
#undef RAZORWAVE_OVERLAY_OVERLOAD
#undef RAZORWAVE_OVERLAY_ANTENNA
#undef RAZORWAVE_AGENT_THREAT_MOD
#undef RAZORWAVE_CONTRABAND_WEIGHT
#undef ASSESS_ITEM_THREAT
