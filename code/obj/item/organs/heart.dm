/*=========================*/
/*----------Heart----------*/
/*=========================*/

/obj/item/organ/heart
	name = "heart"
	organ_name = "heart"
	desc = "Offal, just offal."
	organ_holder_name = "heart"
	organ_holder_location = "chest"
	organ_holder_required_op_stage = 9.0
	icon_state = "heart"
	item_state = "heart"
	// var/broken = 0		//Might still want this. As like a "dead organ var", maybe not needed at all tho?
	var/list/diseases = null
	var/body_image = null // don't have time to completely refactor this, but, what name does the heart icon have in human.dmi?
	var/transplant_XP = 5
	var/blood_id = "blood"
	var/reag_cap = 100

	New(loc, datum/organHolder/nholder)
		. = ..()
		reagents = new/datum/reagents(reag_cap)

	disposing()
		if (holder)
			holder.heart = null
		..()

	on_transplant(var/mob/M as mob)
		..()
		if (src.donor.reagents && src.reagents)
			src.reagents.trans_to(src.donor, src.reagents.total_volume)

		if (src.robotic)
			if (src.emagged)
				APPLY_ATOM_PROPERTY(src.donor, PROP_STAMINA_REGEN_BONUS, "heart", 15)
				src.donor.add_stam_mod_max("heart", 90)
				APPLY_ATOM_PROPERTY(src.donor, PROP_STUN_RESIST, "heart", 30)
				APPLY_ATOM_PROPERTY(src.donor, PROP_STUN_RESIST_MAX, "heart", 30)
			else
				APPLY_ATOM_PROPERTY(src.donor, PROP_STAMINA_REGEN_BONUS, "heart", 5)
				src.donor.add_stam_mod_max("heart", 40)
				APPLY_ATOM_PROPERTY(src.donor, PROP_STUN_RESIST, "heart", 15)
				APPLY_ATOM_PROPERTY(src.donor, PROP_STUN_RESIST_MAX, "heart", 15)

		if (src.donor)
			for (var/datum/ailment_data/disease in src.donor.ailments)
				if (disease.cure == "Heart Transplant")
					src.donor.cure_disease(disease)
			src.donor.blood_id = (ischangeling(src.donor) && src.blood_id == "blood") ? "bloodc" : src.blood_id
		if (ishuman(M) && islist(src.diseases))
			var/mob/living/carbon/human/H = M
			for (var/datum/ailment_data/AD in src.diseases)
				H.contract_disease(null, null, AD, 1)
				src.diseases.Remove(AD)
			return

	on_removal()
		..()
		if (donor)
			if (src.donor.reagents && src.reagents)
				src.donor.reagents.trans_to(src, src.reagents.maximum_volume - src.reagents.total_volume)

			src.blood_id = src.donor.blood_id //keep our owner's blood (for mutantraces etc)

			if (src.robotic)
				REMOVE_ATOM_PROPERTY(src.donor, PROP_STAMINA_REGEN_BONUS, "heart")
				src.donor.remove_stam_mod_max("heart")
				REMOVE_ATOM_PROPERTY(src.donor, PROP_STUN_RESIST, "heart")
				REMOVE_ATOM_PROPERTY(src.donor, PROP_STUN_RESIST_MAX, "heart")

			var/datum/ailment_data/malady/HD = donor.find_ailment_by_type(/datum/ailment/malady/heartdisease)
			if (HD)
				if (!islist(src.diseases))
					src.diseases = list()
				HD.master.on_remove(donor,HD)
				donor.ailments.Remove(HD)
				HD.affected_mob = null
				src.diseases.Add(HD)
		return

	attach_organ(var/mob/living/carbon/M as mob, var/mob/user as mob)
		/* Overrides parent function to handle special case for attaching heads. */
		var/mob/living/carbon/human/H = M
		if (!src.can_attach_organ(H, user))
			return 0

		var/success = ..(H, user)

		if (success)
			if (!isdead(H))
				JOB_XP_DEPT(user, "Medical Doctor", "medical", src.health > 0 ? transplant_XP*2 : transplant_XP)
			return 1
		else
			return 0

/obj/item/organ/heart/synth
	name = "synthheart"
	desc = "I guess you could call this a... hearti-choke"
	synthetic = 1
	item_state = "plant"
	transplant_XP = 6
	New()
		..()
		src.icon_state = pick("plant_heart", "plant_heart_bloom")

/obj/item/organ/heart/cyber
	name = "cyberheart"
	desc = "A cybernetic heart. Is this thing really medical-grade?"
	icon_state = "heart_robo1"
	item_state = "heart_robo1"
	//created_decal = /obj/decal/cleanable/oil
	edible = 0
	robotic = 1
	created_decal = /obj/decal/cleanable/oil
	mats = 8
	made_from = "pharosium"
	transplant_XP = 7

	New()
		. = ..()
		src.reagents.add_reagent("oil", 25)

	emp_act()
		..()
		if (src.broken)
			boutput(donor, "<span class='alert'><B>Your cyberheart malfunctions and shuts down!</B></span>")
			donor.contract_disease(/datum/ailment/malady/flatline,null,null,1)
