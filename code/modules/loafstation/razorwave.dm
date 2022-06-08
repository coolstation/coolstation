/// Razorwave from Loafstation.
// sprites & sound by Kubius
// given w/ permission to coolstation


// Threat Assessment

/// Modifier against total threat for mobs wearing agent cards.
#define RAZORWAVE_AGENT_THREAT_MOD (-2)

/// Weight applied to contraband var of items.
#define RAZORWAVE_CONTRABAND_WEIGHT (0.5)  // This number is arbitrary, but is what other sec machines use.
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

// Razorwave device

/// Minimum threat level to be listed in the razorwave results
#define RAZORWAVE_MIN_THREAT_LEVEL 4

/// Device whichs scans every mob in the camera network for contraband and reports their identity, location, and threat level.
/obj/machinery/razorwave
	name = "interspatial visual aggregator"
	desc = "Metal box painstakingly designed to give you kidney damage."
	icon = 'icons/loafstation/razorwave.dmi'
	icon_state = "razorwave"
	density = TRUE
	anchored = TRUE
	req_access = list(access_heads)
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_MULTITOOL
	/// Whether the device is scanning.
	var/activated = FALSE

/obj/machinery/razorwave/proc/get_trackable_mobs()
	. = list()
	for (var/mob/M as anything in mobs) // mobs is safe to tcl
		if(!ishuman(M))
			continue
		if(M.z != 1 && M.z != src.z)
			continue
		if(!istype(M.loc, /turf)) //in a closet or something, AI can't see him anyways
			continue
		if(M.invisibility) //cloaked
			continue
		var/turf/T = get_turf(M)
		if(!T.cameras || !length(T.cameras))
			continue
		. += M

/obj/machinery/razorwave/attackby(obj/item/I, mob/user)
	var/obj/item/disk/data/floppy/read_only/authentication/disk = I
	if(!istype(I))
		return ..()
	if(!src.allowed(user))
		boutput(src, "<span class='alert'>Access Denied.</span>")
		return
	playsound(src, 'sound/machines/razorwave_scour.ogg', 40, 0)
	var/report_text = "INTERSPATIAL AGGREGATION REPORT<hr>"
	for(var/mob/M as anything in src.get_trackable_mobs())
		var/threat_level = razorwave_assess_threat(M)
		if(threat_level >= RAZORWAVE_MIN_THREAT_LEVEL)
			report_text += "<emph>[M]</emph> in [get_area(M)], threat level [threat_level]<br>" // Let's ignore disguises for now.
	return

/obj/machinery/razorwave/power_change()
	. = ..()
	update_icon()

/obj/machinery/razorwave/update_icon()
	if(status & (NOPOWER))
		UpdateOverlays(null, "power")
		UpdateOverlays(null, "razorwaving")
		UpdateOverlays(null, "crimewave")
		return
