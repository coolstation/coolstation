/mob/living/carbon/human/normal
	var/do_random_appearance = TRUE

	New()
		..()
		SPAWN_DBG(0)
			if(do_random_appearance)
				randomize_look(src, 1, 1, 1, 1, 1, 1, src)
			src.update_colorful_parts()

		SPAWN_DBG(1 SECOND)
			set_clothing_icon_dirty()

/mob/living/carbon/human/normal/assistant
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Staff Assistant")

/mob/living/carbon/human/normal/syndicate
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Syndicate")

/mob/living/carbon/human/normal/captain
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Captain")

/mob/living/carbon/human/normal/headofpersonnel
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Head of Personnel")

/mob/living/carbon/human/normal/chiefengineer
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Chief Engineer")

/mob/living/carbon/human/normal/researchdirector
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Research Director")

/mob/living/carbon/human/normal/headofsecurity
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Head of Security")

/mob/living/carbon/human/normal/securityofficer
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Security Officer")

/mob/living/carbon/human/normal/securityassistant
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Security Assistant")

/mob/living/carbon/human/normal/detective
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Detective")

/mob/living/carbon/human/normal/clown
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Clown")

/mob/living/carbon/human/normal/chef
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Chef")

/mob/living/carbon/human/normal/chaplain
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Chaplain")

/mob/living/carbon/human/normal/bartender
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Bartender")

/mob/living/carbon/human/normal/botanist
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Botanist")

/mob/living/carbon/human/normal/rancher
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Rancher")

/mob/living/carbon/human/normal/janitor
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Janitor")

/mob/living/carbon/human/normal/mechanic
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Mechanic")

/mob/living/carbon/human/normal/electrician
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Electrician")

/mob/living/carbon/human/normal/engineer
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Engineer")

/mob/living/carbon/human/normal/miner
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Miner")

/mob/living/carbon/human/normal/quartermaster
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Quartermaster")

/mob/living/carbon/human/normal/cargotechnician
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Cargo Technician")

/mob/living/carbon/human/normal/medicaldoctor
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Medical Doctor")

/mob/living/carbon/human/normal/surgeon
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Surgeon")

/mob/living/carbon/human/normal/geneticist
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Geneticist")

/mob/living/carbon/human/normal/pathologist
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Pathologist")

/mob/living/carbon/human/normal/roboticist
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Roboticist")

/mob/living/carbon/human/normal/pharmacist
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Pharmacist")

/mob/living/carbon/human/normal/nurse
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Nurse")

/mob/living/carbon/human/normal/receptionist
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Receptionist")

/mob/living/carbon/human/normal/chemist
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Chemist")

/mob/living/carbon/human/normal/scientist
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Scientist")

/mob/living/carbon/human/normal/wizard
	New()
		..()
		SPAWN_DBG(0)
			if (src.gender && src.gender == "female")
				src.real_name = pick_string_autokey("names/wizard_female.txt")
			else
				src.real_name = pick_string_autokey("names/wizard_male.txt")

			equip_wizard(src, 1)
		return

/mob/living/carbon/human/normal/rescue
	New()
		..()
		SPAWN_DBG(0)
			src.equip_new_if_possible(/obj/item/clothing/shoes/red, slot_shoes)
			src.equip_new_if_possible(/obj/item/clothing/under/color/red, slot_w_uniform)
			src.equip_new_if_possible(/obj/item/card/id, slot_wear_id)
			src.equip_new_if_possible(/obj/item/device/radio/headset, slot_ears)
			src.equip_new_if_possible(/obj/item/storage/belt/utility/prepared, slot_belt)
			src.equip_new_if_possible(/obj/item/storage/backpack/withO2, slot_back)
			src.equip_new_if_possible(/obj/item/device/light/flashlight, slot_l_store)
			src.equip_new_if_possible(/obj/item/clothing/suit/armor/vest, slot_wear_suit)
			src.equip_new_if_possible(/obj/item/clothing/mask/gas, slot_wear_mask)
			src.equip_new_if_possible(/obj/item/clothing/gloves/black, slot_gloves)
			src.equip_new_if_possible(/obj/item/clothing/glasses/nightvision, slot_glasses)

			var/obj/item/card/id/C = src.wear_id
			if(C)
				C.registered = src.real_name
				C.assignment = "NT-SO Rescue Worker"
				C.name = "[C.registered]'s ID Card ([C.assignment])"
				C.access = get_all_accesses()

			update_clothing()

/mob/living/carbon/human/normal/ntso
	New()
		..()
		SPAWN_DBG(0)
			src.equip_new_if_possible(/obj/item/clothing/shoes/swat, slot_shoes)
			src.equip_new_if_possible(/obj/item/clothing/under/misc/NT, slot_w_uniform)
			src.equip_new_if_possible(/obj/item/card/id, slot_wear_id)
			src.equip_new_if_possible(/obj/item/device/radio/headset/command/captain, slot_ears)
			src.equip_new_if_possible(/obj/item/storage/belt/security, slot_belt)
			src.equip_new_if_possible(/obj/item/storage/backpack/NT, slot_back)
			src.equip_new_if_possible(/obj/item/clothing/glasses/nightvision, slot_l_store)
			src.equip_new_if_possible(/obj/item/crowbar, slot_r_store)
			src.equip_new_if_possible(/obj/item/clothing/suit/armor/NT_alt, slot_wear_suit)
			src.equip_new_if_possible(/obj/item/clothing/mask/gas/swat, slot_wear_mask)
			src.equip_new_if_possible(/obj/item/clothing/head/NTberet, slot_head)
			src.equip_new_if_possible(/obj/item/clothing/gloves/black, slot_gloves)
			src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses/sechud, slot_glasses)

			var/obj/item/card/id/C = src.wear_id
			if(C)
				C.registered = src.real_name
				C.assignment = "NT-SO Special Operative"
				C.name = "[C.registered]'s ID Card ([C.assignment])"
				var/list/ntso_access = get_all_accesses()
				ntso_access += access_maxsec // This makes sense, right? They're highly trained and trusted.
				C.access = ntso_access

			update_clothing()

// Corpses! They will die when they are spawned. Keep in mind by default they will have blood and organs, and will decompose.

/mob/living/carbon/human/normal/corpse
	real_name = "corpse" // if we don't set this to something, you can't interact at all
	var/do_deathgasp = FALSE // will they do the deathgasp emote when spawned
	var/do_decompose = TRUE // will they decompose normally
	var/random_decomp = FALSE // applies a decomposition stage randomly, advanced stages being rarer
	do_random_appearance = TRUE // applies a random name and appearance

	New()
		..()
		SPAWN_DBG(0)
			src.death(deathgasp = do_deathgasp, decompose = do_decompose)

			if(random_decomp)
				switch(rand(1,100))
					if(1 to 40)
						return
					if(41 to 60)
						src.decomp_stage = 1
					if(61 to 78)
						src.decomp_stage = 2
					if(79 to 92)
						src.decomp_stage = 3
					if(93 to 100)
						src.decomp_stage = 4

	clothed_generic
		random_decomp = TRUE

		New()
			..()
			SPAWN_DBG(0)
				src.equip_new_if_possible(pick(/obj/item/clothing/shoes/white, /obj/item/clothing/shoes/black, /obj/item/clothing/shoes/brown, /obj/item/clothing/shoes/red, /obj/item/clothing/shoes/blue, /obj/item/clothing/shoes/orange, /obj/item/clothing/shoes/pink), slot_shoes)
				src.equip_new_if_possible(/obj/item/clothing/under/color/random, slot_w_uniform)

	morgue_patient
		random_decomp = FALSE

		New()
			..()
			SPAWN_DBG(0)
				src.equip_new_if_possible(/obj/item/clothing/under/patient_gown, slot_w_uniform)

				// they were embalmed so no free blood
				src.reagents.clear_reagents()
				src.reagents.add_reagent("formaldehyde", 15)

				// some organs may have been harvested as well?
				if(prob(50))
					var/list/organs = list("head", "skull", "brain", "left_eye", "right_eye", "heart", "left_lung", "right_lung", "butt", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix", "tail")
					var/organs_to_remove = rand(1,15)
					while(organs_to_remove > 0)
						organs_to_remove--
						var/O = pick(organs)
						if(src.get_organ(O))
							organs.Remove(O)
							qdel(src.get_organ(O))

	clown
		do_decompose = FALSE
		New()
			..()
			SPAWN_DBG(0)
				src.equip_new_if_possible(/obj/item/clothing/mask/clown_hat, slot_wear_mask)
				src.equip_new_if_possible(/obj/item/clothing/under/misc/clown, slot_w_uniform)
				src.equip_new_if_possible(/obj/item/clothing/shoes/clown_shoes, slot_shoes)

				src.reagents.clear_reagents()
				src.reagents.add_reagent("formaldehyde", 15)



	unique // for bodies with preset appearances and names
		do_decompose = FALSE // override this if wanted but this preserves the corpse looking a certain way
		random_decomp = FALSE
		do_random_appearance = FALSE

		martian // one day there should be some martian organs to harvest
			New()
				..()
				SPAWN_DBG(0)

				src.real_name = "martian"
				src.hair_override = FALSE
				src.set_mutantrace(/datum/mutantrace/martian)
				src.reagents.clear_reagents()

		miner_accident
			New()
				..()
				SPAWN_DBG(0)

				src.equip_new_if_possible(/obj/item/clothing/under/rank/overalls, slot_w_uniform)
				src.equip_new_if_possible(/obj/item/clothing/gloves/black, slot_gloves)

				src.real_name = "headless miner"
				src.reagents.clear_reagents()
				if(src.get_organ("head"))
					qdel(src.get_organ("head"))
				src.bioHolder.AddEffect("dwarf")

		fancy
			do_random_appearance = TRUE

			New()
				..()
				SPAWN_DBG(0)
				src.decomp_stage = 4
				switch(pick("dress_red", "dress_black", "tuxedo"))
					if("dress_red")
						src.equip_new_if_possible(/obj/item/clothing/under/misc/dress/red, slot_w_uniform)
						src.equip_new_if_possible(/obj/item/clothing/shoes/heels/red, slot_shoes)
					if("dress_black")
						src.equip_new_if_possible(/obj/item/clothing/under/misc/dress, slot_w_uniform)
						src.equip_new_if_possible(/obj/item/clothing/shoes/heels/black, slot_shoes)
					if("tuxedo")
						src.equip_new_if_possible(/obj/item/clothing/under/rank/bartender/tuxedo, slot_w_uniform)
						src.equip_new_if_possible(/obj/item/clothing/shoes/dress_shoes, slot_shoes)
				src.equip_new_if_possible(/obj/item/clothing/gloves/ring/gold, slot_gloves) // one day, should be able to melt this down for some gold
