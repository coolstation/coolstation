/obj/item/organ/stomach
	name = "stomach"
	organ_name = "stomach"
	desc = "A little meat sack containing acid for the digestion of food. Like most things that come out of living creatures, you can probably eat it."
	organ_holder_name = "stomach"
	organ_holder_location = "chest"
	organ_holder_required_op_stage = 4.0
	icon_state = "stomach"
	FAIL_DAMAGE = 100
	var/reagent_capacity = 200 // should be 150 i think, but eh

	New()
		. = ..()
		src.create_reagents(src.reagent_capacity)

	on_life(var/mult = 1)
		if (!..())
			return 0
		if (length(src.contents))
			var/count_to_process = min(length(src.contents), 5)
			var/count_left = count_to_process
			for(var/obj/item/reagent_containers/food in src.contents)
				if (src.reagents.total_volume <= src.reagents.maximum_volume)
					if (!food.has_digested)
						food.reagents.reaction(donor, INGEST, src.reagents.total_volume)
						food.has_digested = TRUE

					food.reagents.trans_to(src, (5 / count_to_process) * mult, HAS_ATOM_PROPERTY(donor, PROP_DIGESTION_EFFICIENCY) ? GET_ATOM_PROPERTY(donor, PROP_DIGESTION_EFFICIENCY) : 1)

					if (food.reagents.total_volume <= 0)
						donor.poops += food.w_class / 4
						qdel(food)
				else
					break
				if(count_left-- <= 0)
					break

		src.reagents.trans_to(donor, 4 * mult, 1, 0)

		// if (src.get_damage() >= FAIL_DAMAGE && prob(src.get_damage() * 0.2))
		// 	donor.contract_disease(failure_disease,null,null,1)
		return 1


	disposing()
		if (holder)
			if (holder.stomach == src)
				holder.stomach = null
		..()

	attackby(obj/item/W as obj, mob/user as mob)
		..()
		if (src.contents && src.contents.len > 0 && istype(W, /obj/item/device/analyzer/healthanalyzer))
			var/output = ""
			var/list/L = list()
			for (var/obj/O in src.contents)
				L[O.name] ++

			for (var/S in L)
				output += "[S] = [L[S]]\n"
			boutput(user, "<br><span style='color:purple'><b>[src]</b> contains:\n [output]</span>")

/obj/item/organ/stomach/synth
	name = "synthstomach"
	organ_name = "synthstomach"
	icon_state = "plant"
	desc = "Nearly functionally identical to a pitcher plant... weird."
	synthetic = 1
	New()
		..()
		src.icon_state = pick("plant_stomach", "plant_stomach_bloom")

/obj/item/organ/stomach/cyber
	name = "cyberstomach"
	desc = "A fancy robotic stomach to replace one that someone's lost!"
	icon_state = "cyber-stomach"
	// item_state = "heart_robo1"
	made_from = "pharosium"
	robotic = 1
	created_decal = /obj/decal/cleanable/oil
	edible = 0
	mats = 6

	on_transplant(mob/M)
		. = ..()
		if(!broken)
			ADD_STATUS_LIMIT(M, "Food", 6)

	on_removal()
		. = ..()
		REMOVE_STATUS_LIMIT(src.donor, "Food")

	unbreakme()
		..()
		if(donor)
			ADD_STATUS_LIMIT(src.donor, "Food", 6)

	breakme()
		..()
		if(donor)
			REMOVE_STATUS_LIMIT(src.donor, "Food")

	emag_act(mob/user, obj/item/card/emag/E)
		. = ..()
		organ_abilities = list(/datum/targetable/organAbility/projectilevomit)

	demag(mob/user)
		..()
		organ_abilities = initial(organ_abilities)
