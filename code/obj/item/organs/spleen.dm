/obj/item/organ/spleen
	name = "spleen"
	organ_name = "spleen"
	organ_holder_name = "spleen"
	organ_holder_location = "chest"
	organ_holder_required_op_stage = 6.0
	icon_state = "spleen"
	body_side = L_ORGAN
	var/blood_id = "blood"

	on_life(var/mult = 1)
		if (!..())
			return 0
		var/blood_in_ya = donor.reagents.get_reagent_amount(donor.blood_id)
		if (blood_in_ya < donor.ideal_blood_volume * 0.99 && blood_in_ya > donor.ideal_blood_volume * BLOOD_SCALAR * 5) // if we're full or mostly empty, don't bother v
			if (prob(66))
				donor.reagents.add_reagent(src.blood_id, donor.ideal_blood_volume * BLOOD_SCALAR * mult, temp_new = donor.base_body_temp) // maybe get a little blood back ^
			else if (src.robotic)  // garuanteed extra blood with robotic spleen
				donor.reagents.add_reagent(src.blood_id, donor.ideal_blood_volume * BLOOD_SCALAR * 2 * mult, temp_new = donor.base_body_temp)
		else if (donor.reagents.total_volume > donor.ideal_blood_volume * 1.05)
			if (prob(66))
				donor.reagents.remove_reagent(donor.blood_id, donor.ideal_blood_volume * BLOOD_SCALAR * mult)
		if(emagged)
			donor.reagents.add_reagent(src.blood_id, donor.ideal_blood_volume * BLOOD_SCALAR * 2 * mult, temp_new = donor.base_body_temp) //Don't worry friend, you'll have /plenty/ of blood!
		return 1

	on_broken(var/mult = 1)
		donor.reagents.remove_reagent(donor.blood_id, donor.ideal_blood_volume * BLOOD_SCALAR * 2 * mult)

	disposing()
		if (holder)
			if (holder.spleen == src)
				holder.spleen = null
		..()

/obj/item/organ/spleen/synth
	name = "synthspleen"
	organ_name = "synthspleen"
	icon_state = "plant"
	desc = "I guess you could say, the person missing this has spleen better days!"
	synthetic = 1
	New()
		..()
		src.icon_state = pick("plant_spleen", "plant_spleen_bloom")

/obj/item/organ/spleen/cyber
	name = "cyberspleen"
	desc = "A fancy robotic spleen to replace one that someone's lost!"
	icon_state = "cyber-spleen"
	made_from = "pharosium"
	// item_state = "heart_robo1"
	robotic = 1
	edible = 0
	mats = 6
	created_decal = /obj/decal/cleanable/oil
