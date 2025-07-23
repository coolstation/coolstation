/atom
	var/tmp/fingerprints = null
	var/tmp/list/fingerprintshidden = null//new/list()
	var/tmp/fingerprintslast = null
	var/tmp/blood_DNA = null
	var/tmp/blood_type = null
	//var/list/forensic_info = null
	var/list/forensic_trace = null // list(fprint, bDNA, btype) - can't get rid of this so easy!

/*
/atom/proc/add_forensic_info(var/key, var/value)
	if (!key || !value)
		return
	if (!islist(src.forensic_info))
		src.forensic_info = list("fprints" = null, "bDNA" = null, "btype" = null)
	src.forensic_info[key] = value

/atom/proc/get_forensic_info(var/key)
	if (!key || !islist(src.forensic_info))
		return 0
	return src.forensic_info[key]
*/
/atom/proc/add_forensic_trace(var/key, var/value)
	if (!key || !value)
		return
	if (!islist(src.forensic_trace))
		src.forensic_trace = list("fprints" = null, "bDNA" = null, "btype" = null)
	src.forensic_trace[key] = value

/atom/proc/get_forensic_trace(var/key)
	if (!key || !islist(src.forensic_trace))
		return 0
	return src.forensic_trace[key]

/atom/proc/add_fingerprint(mob/living/M as mob)
	if (!ismob(M) || isnull(M.key))
		return
	if (!(src.flags & FPRINT))
		return
	if (!src.fingerprintshidden)
		src.fingerprintshidden = list()

	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		var/list/L = src.fingerprints
		if(isnull(L))
			L = list()

		if (H.gloves) // Fixed: now adds distorted prints even if 'fingerprintslast == ckey'. Important for the clean_forensic proc (Convair880).
			var/gloveprints = H.gloves.distort_prints(H.bioHolder.uid_hash, 1)
			if (!isnull(gloveprints))
				L -= gloveprints
				if (L.len >= 6) //Limit fingerprints in the list to 6
					L.Cut(1,2)
				L += gloveprints
				src.fingerprints = L

			if(src.fingerprintslast != H.key)
				src.fingerprintshidden += "(Wearing gloves). Real name: [H.real_name], Key: [H.key], Time: [time2text(world.timeofday, "hh:mm:ss")]"
				src.fingerprintslast = H.key

			return 0

		if (!( src.fingerprints ))
			src.fingerprints = list("[H.bioHolder.uid_hash]")
			if(src.fingerprintslast != H.key)
				src.fingerprintshidden += "Real name: [H.real_name], Key: [H.key], Time: [time2text(world.timeofday, "hh:mm:ss")]"
				src.fingerprintslast = H.key

			return 1

		else
			L -= H.bioHolder.uid_hash
			while(L.len >= 6) // limit the number of fingerprints to 6, previously 3
				L -= L[1]
			L += H.bioHolder.uid_hash
			src.fingerprints = L
			if(src.fingerprintslast != H.key)
				src.fingerprintshidden += "Real name: [H.real_name], Key: [H.key], Time: [time2text(world.timeofday, "hh:mm:ss")]"
				src.fingerprintslast = H.key

	else
		if(src.fingerprintslast != M.key)
			src.fingerprintshidden += "Real name: [M.real_name], Key: [M.key], Time: [time2text(world.timeofday, "hh:mm:ss")]"
			src.fingerprintslast = M.key

	return

// WHAT THE ACTUAL FUCK IS THIS SHIT
// WHO THE FUCK WROTE THIS
/atom/proc/add_blood(atom/source, var/amount = 5)
//	if (!( isliving(M) ) || !M.blood_id)
//		return 0
	if (!(src.flags& FPRINT))
		return
	var/mob/living/L = source
	var/b_uid = "--unidentified substance--"
	var/b_type = "--unidentified substance--"
	var/blood_color = DEFAULT_BLOOD_COLOR
	var/blood_stain = "blood-stained"
	if(istype(source, /obj/fluid))
		var/obj/fluid/F = source
		blood_color = F.group.reagents.get_master_color()
		var/datum/reagent/blood/blood_reagent = F.group.reagents.reagent_list["blood"]
		if(!blood_reagent)
			blood_reagent = F.group.reagents.reagent_list["bloodc"]
		var/datum/bioHolder/bioholder = blood_reagent?.data
		if(istype(bioholder))
			b_uid = bioholder.Uid
			b_type = bioholder.bloodType
	else if (istype(L) && L.bioHolder)
		b_uid = L.bioHolder.Uid
		b_type = L.bioHolder.bloodType
		var/datum/reagent/R = reagents_cache[L.blood_id]
		blood_color = rgb(R.fluid_r, R.fluid_g, R.fluid_b)
		if(L?.blood_id == "blood" && L.bioHolder.bloodColor)
			blood_color = L.bioHolder.bloodColor
	else
		if (source.blood_DNA)
			b_uid = source.blood_DNA
		if (source.blood_type)
			b_type = source.blood_type
	if(istype(source, /obj/decal/cleanable))
		var/obj/decal/cleanable/source_cleanable = source
		if(!isnull(source.color))
			blood_color = source.color
		blood_stain = source_cleanable.stain
	if (!( src.blood_DNA ))
		if (isitem(src))
			var/obj/item/I = src
			I.appearance_flags |= KEEP_TOGETHER
			var/image/blood_overlay = image('icons/obj/decals/blood.dmi', "itemblood")
			blood_overlay.appearance_flags = PIXEL_SCALE | RESET_COLOR
			blood_overlay.color = blood_color
			blood_overlay.alpha = min(blood_overlay.alpha, 200)
			blood_overlay.blend_mode = BLEND_INSET_OVERLAY
			src.UpdateOverlays(blood_overlay, "blood_splatter")
			I.blood_DNA = b_uid
			I.blood_type = b_type
			if (istype(I, /obj/item/clothing))
				var/obj/item/clothing/C = src
				C.add_stain(blood_stain)
		else if (ishuman(src)) // this will add the blood to their hands or something?
			src.blood_DNA = b_uid
			src.blood_type = b_type
		else
			return
	else
		var/list/blood_list = params2list(src.blood_DNA)
		blood_list -= b_uid
		if(blood_list.len >= 6)
			blood_list = blood_list.Copy(blood_list.len - 5, 0)
		blood_list += b_uid
		src.blood_DNA = list2params(blood_list)

// Was clean_blood. Reworked the proc to take care of other forensic evidence as well (Convair880).
/atom/proc/clean_forensic()
	if (!src)
		return
	//if (!(src.flags & FPRINT)) // why is this here? we call clean_forensic on lots of stuff thats not fingerprinted.
	//	return
	// The first version accidently looped through everything for every atom. Consequently, cleaner grenades caused horrendous lag on my local server. Woops.
	if (!ismob(src)) // Mobs are a special case.
		if (isitem(src) && (src.fingerprints || src.blood_DNA || src.blood_type))
			src.UpdateOverlays(null, "mud_splatter")
			src.add_forensic_trace("fprints", src.fingerprints)
			src.fingerprints = null
			src.add_forensic_trace("btype", src.blood_type)
			src.blood_type = null
			if (src.blood_DNA)
				src.add_forensic_trace("bDNA", src.blood_DNA)
				var/obj/item/CI = src
				CI.blood_DNA = null
				CI.UpdateOverlays(null, "blood_splatter")
		if (istype(src, /obj/item/clothing))
			var/obj/item/clothing/C = src
			C.clean_stains()

		else if (istype(src, /obj/decal/cleanable) || istype(src, /obj/reagent_dispensers/cleanable))
			qdel(src)

		else if (isturf(src))
			var/turf/T = get_turf(src)
			for (var/obj/decal/cleanable/mess in T)
				qdel(mess)
			T.clean = 1
			T.messy = 0

		else // Don't think it should clean doors and the like. Give the detective at least something to work with.
			return

	else
		if (isobserver(src) || isintangible(src) || iswraith(src)) // Just in case.
			return

		if (src.color) //wash off paint! might be dangerous, so possibly move this check into humans only if it causes problems with critters
			src.color = initial(src.color)

		if (ishuman(src))
			var/mob/living/carbon/human/M = src
			var/list/gear_to_clean = list(M.r_hand, M.l_hand, M.head, M.wear_mask, M.w_uniform, M.wear_suit, M.belt, M.gloves, M.glasses, M.shoes, M.wear_id, M.back)
			for (var/obj/item/check in gear_to_clean)
				check.UpdateOverlays(null, "mud_splatter")
				if (check.fingerprints || check.blood_DNA || check.blood_type)
					check.add_forensic_trace("fprints", check.fingerprints)
					check.fingerprints = null
					check.add_forensic_trace("btype", check.blood_type)
					check.blood_type = null
					if (check.blood_DNA)
						check.add_forensic_trace("bDNA", check.blood_DNA)
						check.blood_DNA = null
						check.UpdateOverlays(null, "blood_splatter")
				if (istype(check, /obj/item/clothing))
					var/obj/item/clothing/C = check
					C.clean_stains()

			if (isnull(M.gloves)) // Can't clean your hands when wearing gloves.
				M.add_forensic_trace("bDNA", M.blood_DNA)
				M.blood_DNA = null
				M.add_forensic_trace("btype", M.blood_type)
				M.blood_type = null
				M.cleanhands = 0

			M.add_forensic_trace("fprints", M.fingerprints)
			M.fingerprints = null // Foreign fingerprints on the mob.
			M.gunshot_residue = 0 // Only humans can have residue at the moment.
			if (M.makeup || M.spiders)
				M.makeup = null
				M.makeup_color = null
				M.spiders = null
				M.set_body_icon_dirty()
			M.tracked_reagents.clear_reagents()
			M.set_clothing_icon_dirty()

		else

			var/mob/living/L = src // Punching cyborgs does leave fingerprints for instance.
			L.add_forensic_trace("fprints", L.fingerprints)
			L.fingerprints = null
			L.add_forensic_trace("bDNA", L.blood_DNA)
			L.blood_DNA = null
			L.add_forensic_trace("btype", L.blood_type)
			L.blood_type = null
			L.tracked_reagents.clear_reagents()
			L.set_clothing_icon_dirty()
	SEND_SIGNAL(src, COMSIG_ATOM_CLEANED)

/mob/living
	var/datum/reagents/tracked_reagents

/mob/living/proc/track_reagents()
	var/turf/T = get_turf(src)
	var/obj/decal/cleanable/tracked_reagents/dynamic/tracks/B = null
	if (T.messy > 0)
		B = locate(/obj/decal/cleanable/tracked_reagents/dynamic) in T

	if (!B)
		if (T.active_liquid)
			src.tracked_reagents.trans_to_direct(T.active_liquid.group.reagents, 1)
			return
		B = make_cleanable(/obj/decal/cleanable/tracked_reagents/dynamic/tracks,get_turf(src))

	var/list/states = src.get_step_image_states()

	if (states[1] || states[2])
		if (states[1])
			B.transfer_volume(src.tracked_reagents, 0.5, null, null, states[1], src.last_move, 0)
		if (states[2])
			B.transfer_volume(src.tracked_reagents, 0.5, null, null, states[2], src.last_move, 0)
	else
		B.transfer_volume(src.tracked_reagents, 1, null, null, "smear2", src.last_move, 0)

	if (!src.tracked_reagents.total_volume) // mirror from below
		src.set_clothing_icon_dirty()
		return

/mob/living/proc/get_step_image_states()
	return list("footprints[rand(1,2)]", null)

/mob/living/carbon/human/get_step_image_states()
	return src.limbs ? list(istype(src.limbs.l_leg) ? src.limbs.l_leg.step_image_state : null, istype(src.limbs.r_leg) ? src.limbs.r_leg.step_image_state : null) : list(null, null)

/mob/living/silicon/robot/get_step_image_states()
	return list(istype(src.part_leg_l) ? src.part_leg_l.step_image_state : null, istype(src.part_leg_r) ? src.part_leg_r.step_image_state : null)

/*
                                  ''''''
IIIIIIIIIITTTTTTTTTTTTTTTTTTTTTTT '::::'   SSSSSSSSSSSSSSS      PPPPPPPPPPPPPPPPP        OOOOOOOOO          OOOOOOOOO     PPPPPPPPPPPPPPPPP
I::::::::IT:::::::::::::::::::::T '::::' SS:::::::::::::::S     P::::::::::::::::P     OO:::::::::OO      OO:::::::::OO   P::::::::::::::::P
I::::::::IT:::::::::::::::::::::T ':::''S:::::SSSSSS::::::S     P::::::PPPPPP:::::P  OO:::::::::::::OO  OO:::::::::::::OO P::::::PPPPPP:::::P
II::::::IIT:::::TT:::::::TT:::::T':::'  S:::::S     SSSSSSS     PP:::::P     P:::::PO:::::::OOO:::::::OO:::::::OOO:::::::OPP:::::P     P:::::P
  I::::I  TTTTTT  T:::::T  TTTTTT''''   S:::::S                   P::::P     P:::::PO::::::O   O::::::OO::::::O   O::::::O  P::::P     P:::::P
  I::::I          T:::::T               S:::::S                   P::::P     P:::::PO:::::O     O:::::OO:::::O     O:::::O  P::::P     P:::::P
  I::::I          T:::::T                S::::SSSS                P::::PPPPPP:::::P O:::::O     O:::::OO:::::O     O:::::O  P::::PPPPPP:::::P
  I::::I          T:::::T                 SS::::::SSSSS           P:::::::::::::PP  O:::::O     O:::::OO:::::O     O:::::O  P:::::::::::::PP
  I::::I          T:::::T                   SSS::::::::SS         P::::PPPPPPPPP    O:::::O     O:::::OO:::::O     O:::::O  P::::PPPPPPPPP
  I::::I          T:::::T                      SSSSSS::::S        P::::P            O:::::O     O:::::OO:::::O     O:::::O  P::::P
  I::::I          T:::::T                           S:::::S       P::::P            O:::::O     O:::::OO:::::O     O:::::O  P::::P
  I::::I          T:::::T                           S:::::S       P::::P            O::::::O   O::::::OO::::::O   O::::::O  P::::P
II::::::II      TT:::::::TT             SSSSSSS     S:::::S     PP::::::PP          O:::::::OOO:::::::OO:::::::OOO:::::::OPP::::::PP
I::::::::I      T:::::::::T             S::::::SSSSSS:::::S     P::::::::P           OO:::::::::::::OO  OO:::::::::::::OO P::::::::P
I::::::::I      T:::::::::T             S:::::::::::::::SS      P::::::::P             OO:::::::::OO      OO:::::::::OO   P::::::::P
IIIIIIIIII      TTTTTTTTTTT              SSSSSSSSSSSSSSS        PPPPPPPPPP               OOOOOOOOO          OOOOOOOOO     PPPPPPPPPP
*/

/atom/proc/add_mud(mob/living/M as mob, var/amount = 5)
	if (!(( src.flags) & FPRINT))
		return

	if (isitem(src))
		var/obj/item/I = src

		I.appearance_flags |= KEEP_TOGETHER
		var/image/mud_overlay = image('icons/obj/decals/not_poo.dmi', "itemmud")
		mud_overlay.appearance_flags = PIXEL_SCALE | RESET_COLOR
		mud_overlay.color = DEFAULT_MUD_COLOR
		mud_overlay.alpha = min(mud_overlay.alpha, 200)
		mud_overlay.blend_mode = BLEND_INSET_OVERLAY
		src.UpdateOverlays(mud_overlay, "mud_splatter")

		if (istype(I, /obj/item/clothing))
			var/obj/item/clothing/C = src
			C.add_stain("shit-stained")

		else
			I.name = "[pick("filthy ","muddy ","dirty ")] [I]"

	else
		return

/mob/living/carbon/human
	var/mud_gib_stage = 0.0
