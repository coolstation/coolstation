
/mob/living/carbon/human/bullet_act(var/obj/projectile/P, mob/meatshield)
	. = ..()
	if(!.)
		return 0 //early return from parent

	if(istype(/atom, .))
		return . //meatshielded

	var/damage = 0
	if (P.proj_data)  //ZeWaka: Fix for null.ks_ratio
		damage = round((P.power*P.proj_data.ks_ratio), 1.0)

	var/armor_value_bullet = 1

	if (!(client && client.hellbanned))
		armor_value_bullet = max(get_ranged_protection(), 0.01)
	var/target_organ = pick("left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix", "tail")
	if (P.proj_data) //Wire: Fix for: Cannot read null.damage_type
		switch(P.proj_data.damage_type)
			if (D_KINETIC)
				if (armor_value_bullet <= 1)
					if (src.organHolder && prob(50))
						src.organHolder.damage_organ(damage, 0, 0, target_organ)
					src.set_clothing_icon_dirty()

				if (src.wear_suit && armor_value_bullet >= 2)
					return
				else
					if (P.implanted)
						if (istext(P.implanted))
							P.implanted = text2path(P.implanted)
							if (!P.implanted)
								return
						var/obj/item/implant/projectile/implanted
						if (ispath(P.implanted))
							implanted = new P.implanted
						else
							implanted = P.implanted
						implanted.set_loc(src)
						if (istype(implanted))
							implanted.owner = src
							if (P.forensic_ID)
								implanted.forensic_ID = P.forensic_ID
							src.implant += implanted
							if (P.proj_data.material)
								implanted.setMaterial(P.proj_data.material)
							implanted.implanted(src, null, 60)
							//extra damage from silver for werewolves
							if (istype(implanted, /datum/material/metal/silver) && iswerewolf(src))
								src.TakeDamage("chest", 0, (damage/armor_value_bullet), 0, DAMAGE_BURN)
								if (src.organHolder)//Damage the organ again for more.
									src.organHolder.damage_organ(0, (damage/armor_value_bullet)*2, 0, target_organ)
							//implanted.implanted(src, null, min(20, max(0, floor(damage / 10) ) ))
			if (D_PIERCING)
				if (src.organHolder && prob(50))
					src.organHolder.damage_organ(damage/max( armor_value_bullet / 3, min(1, armor_value_bullet)), 0, 0, target_organ)

				if (P.implanted)
					if (istext(P.implanted))
						P.implanted = text2path(P.implanted)
						if (!P.implanted)
							return
					var/obj/item/implant/projectile/implanted
					if (ispath(P.implanted))
						implanted = new P.implanted
					else
						implanted = P.implanted
					implanted.set_loc(src)
					if (istype(implanted))
						implanted.owner = src
						src.implant += implanted
						if (P.forensic_ID)
							implanted.forensic_ID = P.forensic_ID
						if (P.proj_data.material)
							implanted.setMaterial(P.proj_data.material)
						implanted.implanted(src, null, 100)
					//extra damage from silver for werewolves
						if (istype(implanted, /datum/material/metal/silver) && iswerewolf(src))
							src.TakeDamage("chest", 0, (damage/armor_value_bullet), 0, DAMAGE_BURN)
							if (src.organHolder)//Damage the organ again for more burn.
								src.organHolder.damage_organ(0, (damage/armor_value_bullet)*2, 0, target_organ)
						//implanted.implanted(src, null, min(20, max(0, floor(damage / 10) ) ))

			if (D_SLASHING)
				if (armor_value_bullet > 1)
					if (src.organHolder && prob(50))
						src.organHolder.damage_organ(damage/armor_value_bullet, 0, 0, target_organ)
				else
					if (src.organHolder && prob(50))
						src.organHolder.damage_organ(damage*2, 0, 0, target_organ)

			if (D_ENERGY)
				if (armor_value_bullet > 1)
					if (src.organHolder && prob(50))
						src.organHolder.damage_organ(0, damage/armor_value_bullet, 0, target_organ)
				else
					if (src.organHolder && prob(50))
						src.organHolder.damage_organ(0, damage, 0, target_organ)

			if (D_BURNING)
				if (armor_value_bullet > 1)
					if (src.organHolder && prob(50))
						src.organHolder.damage_organ(0, damage/armor_value_bullet, 0, target_organ)
				else
					if (src.organHolder && prob(50))
						src.organHolder.damage_organ(0, damage, 0, target_organ)

			if (D_TOXIC)
				if (P.proj_data.reagent_payload)
					if (P.implanted)
						if (istext(P.implanted))
							P.implanted = text2path(P.implanted)
							if (!P.implanted)
								return
						var/obj/item/implant/projectile/implanted = new P.implanted
						implanted.set_loc(src)
						if (istype(implanted))
							implanted.owner = src
							src.implant += implanted
							implanted.setMaterial(P.proj_data.material)
							implanted.implanted(src, null, 0)
	return 1


/mob/living/carbon/human/ex_act(severity, lasttouched, epicenter)
	..() // Logs.
	if (src.nodamage) return
	// there used to be mining radiation check here which increases severity by one
	// this needs to be derived from material properties instead and is disabled for now
	src.flash(3 SECONDS)

	if (isdead(src) && src.client)
		SPAWN_DBG(1 DECI SECOND)
			src.gib(1)
		return

	else if (isdead(src) && !src.client)
		var/list/virus = src.ailments
		var/atom/A = src.loc

		var/bdna = null // For forensics (Convair880).
		var/btype = null
		if (src.bioHolder && src.bioHolder.Uid && src.bioHolder.bloodType) //ZeWaka: Fix for null.bioHolder
			bdna = src.bioHolder.Uid
			btype = src.bioHolder.bloodType
		SPAWN_DBG(0)
			gibs(A, virus, null, bdna, btype)

		qdel(src)
		return

	var/exploprot = src.get_explosion_resistance()
	var/reduction = 0
	var/shielded = 0

	for (var/obj/item/device/shield/S in src)
		if (S.active)
			exploprot += 0.3
			shielded = 1
			reduction += 1
			break

	if (src.energy_shield) reduction += src.energy_shield.protect()/15
	if (src.spellshield)
		reduction += 2
		shielded = 1
		boutput(src, "<span class='alert'><b>Your Spell Shield absorbs some blast!</b></span>")

	severity *= clamp(1-exploprot, 0, 1)
	severity -= reduction
	var/b_loss = clamp(severity*15, 0, 120)
	var/f_loss = clamp((severity-2.5)*10, 0, 120)

	var/delib_chance = b_loss - 20
	if(src.bioHolder && src.bioHolder.HasEffect("shoot_limb"))
		delib_chance += 20

	if (src.traitHolder && src.traitHolder.hasTrait("explolimbs") || src.getStatusDuration("food_explosion_resist"))
		delib_chance = floor(delib_chance / 2)

	if (prob(delib_chance) && !shielded)
		src.sever_limb(pick(list("l_arm","r_arm","l_leg","r_leg"))) //max one delimb at once

	switch (severity)
		if (-INFINITY to 0) //blocked
			boutput(src, "<span class='alert'><b>You are shielded from the blast!</b></span>")
			return
		if (6 to INFINITY) //gib
			SPAWN_DBG(1 DECI SECOND)
				src.gib(1)
			return
	src.apply_sonic_stun(0, 0, 0, 0, 0, floor(severity*7), floor(severity*7), severity*40)

	if (prob(b_loss) && !shielded && !reduction)
		src.changeStatus("paralysis", b_loss DECI SECONDS)
		src.force_laydown_standup()

	TakeDamage(zone="All", brute=b_loss, burn=f_loss, tox=0, damage_type=0, disallow_limb_loss=1)
	src.UpdateDamageIcon()

	if (epicenter && severity > 4)
		src.throw_at(get_edge_cheap(get_turf(src), get_dir(epicenter, get_turf(src))),  floor(3 * severity), floor(severity/2))

/mob/living/carbon/human/blob_act(var/power)
	logTheThing("combat", src, null, "is hit by a blob")
	if (isdead(src) || src.nodamage)
		return
	var/shielded = 0
	for (var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
	if (src.spellshield)
		shielded = 1

	var/modifier = power / 20
	var/damage = null
	if (!isdead(src))
		damage = rand(modifier, 12 + 8 * modifier)

	if (shielded)
		damage /= 4

		//src.paralysis += 1

	src.show_message("<span class='alert'>The blob attacks you!</span>")

	if (src.spellshield)
		boutput(src, "<span class='alert'><b>Your Spell Shield absorbs some damage!</b></span>")

	var/list/zones = list("head", "chest", "l_arm", "r_arm", "l_leg", "r_leg")

	var/zone = pick(zones)

	var/obj/item/temp = src.organs[zone]

	switch(zone)
		if ("head")
			if ((((src.head && src.head.body_parts_covered & HEAD) || (src.wear_mask && src.wear_mask.body_parts_covered & HEAD)) && prob(99)))
				if (temp && prob(45))
					temp.take_damage(damage, 0)
				else
					src.show_message("<span class='alert'>You have been protected from a hit to the head.</span>")
				return
			if (damage > 4.9)
				changeStatus("weakened", 2 SECONDS)
				for (var/mob/O in viewers(src, null))
					O.show_message("<span class='alert'><B>The blob has weakened [src]!</B></span>", 1, "<span class='alert'>You hear someone fall.</span>", 2)
			if (temp)
				temp.take_damage(damage, 0)
		if ("chest")
			if ((((src.wear_suit && src.wear_suit.body_parts_covered & TORSO) || (src.w_uniform && src.w_uniform.body_parts_covered & TORSO)) && prob(70)))
				src.show_message("<span class='alert'>You have been protected from a hit to the chest.</span>")
				return
			if (damage > 4.9)
				if (prob(50))
					src.changeStatus("weakened", 5 SECONDS)
					for (var/mob/O in viewers(src, null))
						O.show_message("<span class='alert'><B>The blob has knocked down [src]!</B></span>", 1, "<span class='alert'>You hear someone fall.</span>", 2)
				else
					changeStatus("stunned", 5 SECONDS)
					for (var/mob/O in viewers(src, null))
						if (O.client)	O.show_message("<span class='alert'><B>The blob has stunned [src]!</B></span>", 1)
				if (isalive(src))
					src.lastgasp() // calling lastgasp() here because we just got knocked out
			if (temp)
				temp.take_damage(damage, 0)

		if ("l_arm")
			if (temp)
				temp.take_damage(damage, 0)
			if (prob(20) && equipped())
				visible_message("<span class='alert'><b>The blob has knocked [equipped()] out of [src]'s hand!</b></span>")
				drop_item()
		if ("r_arm")
			if (temp)
				temp.take_damage(damage, 0)
			if (prob(20) && equipped())
				visible_message("<span class='alert'><b>The blob has knocked [equipped()] out of [src]'s hand!</b></span>")
				drop_item()
		if ("l_leg")
			if (temp)
				temp.take_damage(damage, 0)
			if (prob(5))
				visible_message("<span class='alert'><b>The blob has knocked [src] off-balance!</b></span>")
				drop_item()
				if (prob(50))
					src.changeStatus("weakened", 1 SECOND)
		if ("r_leg")
			if (temp)
				temp.take_damage(damage, 0)
			if (prob(5))
				visible_message("<span class='alert'><b>The blob has knocked [src] off-balance!</b></span>")
				drop_item()
				if (prob(50))
					src.changeStatus("weakened", 1 SECOND)

	src.force_laydown_standup()

	src.UpdateDamageIcon()
	return

/mob/living/carbon/human/TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss, var/bypass_reversal = FALSE)
	if (src.nodamage) return

	if (src.traitHolder && src.traitHolder.hasTrait("scienceteam"))
		if (prob(20))
			var/mob/living/carbon/human/H = src
			playsound(src.loc, pick(H.sound_list_pain), 80, 0, 0, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)

	hit_twitch(src)

	if (src.traitHolder && src.traitHolder.hasTrait("reversal") && !bypass_reversal)
		src.HealDamage(zone, brute, burn, tox, TRUE)
		return

	if (src.traitHolder && src.traitHolder.hasTrait("deathwish"))
		brute *= 2
		burn *= 2
		//tox *= 2

	if(src.traitHolder?.hasTrait("athletic"))
		brute *=1.33

	if (src.mutantrace)
		var/typemult
		if(islist(src.mutantrace.typevulns))
			typemult = src.mutantrace.typevulns[DAMAGE_TYPE_TO_STRING(damage_type)]
		if(!typemult)
			typemult = 1
		if(damage_type == DAMAGE_BURN)
			burn *= typemult
		else
			brute *= typemult

		brute *= src.mutantrace.brutevuln
		burn *= src.mutantrace.firevuln
		tox *= src.mutantrace.toxvuln

	if (is_heat_resistant())
		burn = 0

	//if (src.bioHolder && src.bioHolder.HasEffect("resist_toxic"))
		//tox = 0

	brute = max(0, brute)
	burn = max(0, burn)
	//tox = max(0, burn)

	if (brute + burn + tox <= 0) return

	if (src.is_heat_resistant())
		burn = 0 //mostly covered by individual procs that cause burn damage, but just in case

	//Bandaid fix for tox damage being mysteriously unhooked in here.
	if (tox)
		tox = max(0, tox)
		take_toxin_damage(tox)

	if (zone == "All")
		var/organCount = 0
		for (var/organName in src.organs)
			var/obj/item/extOrgan = src.organs["[organName]"]
			if (istype(extOrgan))
				organCount++
		if (!organCount)
			return
		brute = brute / organCount
		burn = burn / organCount
		var/update = 0
		for (var/organName in src.organs)
			var/obj/item/extOrgan = src.organs["[organName]"]
			if (istype(extOrgan))
				if (extOrgan.take_damage(brute, burn, 0/*tox*/, damage_type))
					update = 1

		if (update)
			src.UpdateDamageIcon()
			health_update_queue |= src
	else
		var/obj/item/E = null
		try
			E = src.organs[zone]
		catch
			logTheThing("debug", null, null, "<b>ORGAN/INDEX_DMG</b> Invalid index: [zone]")
			return 0
		if (isitem(E))
			if (E.take_damage(brute, burn, 0/*tox*/, damage_type))
				src.UpdateDamageIcon()
				health_update_queue |= src
		else
			return 0
		return

/mob/living/carbon/human/TakeDamageAccountArmor(zone, brute, burn, tox, damage_type)
	var/armor_mod = 0
	//var/z_name = zone
	var/a_zone = zone
	if (a_zone in list("l_leg", "r_arm", "l_leg", "r_leg"))
		a_zone = "chest"

	armor_mod = get_melee_protection(zone, damage_type)
	/*switch (zone)
		if ("l_arm")
			z_name = "left arm"
		if ("r_arm")
			z_name = "right arm"
		if ("l_leg")
			z_name = "left leg"
		if ("r_leg")
			z_name = "right leg"*/

	brute = max(0, brute - armor_mod)
	burn = max(0, burn - armor_mod)
	/*
	if (brute + burn == 0)
		show_message("<span class='notice'>You have been completely protected from damage on your [z_name]!</span>")
	else if (armor_mod != 0)
		show_message("<span class='notice'>You have been partly protected from damage on your [z_name]!</span>")
	*///Begone, message spam. Nobody asked for this
	TakeDamage(zone, max(brute, 0), max(burn, 0), 0, damage_type)

/mob/living/carbon/human/HealDamage(zone, brute, burn, tox, var/bypass_reversal = FALSE)

	if (src.traitHolder && src.traitHolder.hasTrait("reversal"))
		src.TakeDamage(zone, brute, burn, tox, null, FALSE, TRUE)

	src.take_toxin_damage(-tox)

	if (zone == "All")
		var/bruteOrganCount = 0.0 		//How many organs have brute damage?
		var/burnOrganCount = 0.0		//How many organs have burn damage?
		var/toxOrganCount = 0.0			// gurbage

		//Let's find out
		for (var/organName in src.organs)
			var/obj/item/extOrgan = src.organs["[organName]"]
			if (istype(extOrgan, /obj/item/organ))
				var/obj/item/organ/O = extOrgan
				if (O.brute_dam > 0)
					bruteOrganCount ++
				if (O.burn_dam > 0)
					burnOrganCount ++
				if (O.tox_dam > 0)
					toxOrganCount ++
			else if (istype(extOrgan, /obj/item/parts))
				var/obj/item/parts/O = extOrgan
				if (O.brute_dam > 0)
					bruteOrganCount ++
				if (O.burn_dam > 0)
					burnOrganCount ++
				if (O.tox_dam > 0)
					toxOrganCount ++

		if (!bruteOrganCount && !burnOrganCount && !toxOrganCount) //No damage
			return

		//This is ugly, but necessary
		if (bruteOrganCount > 0)
			brute = brute / bruteOrganCount
		else
			brute = 0

		if (burnOrganCount > 0)
			burn = burn / burnOrganCount
		else
			burn = 0

		if (toxOrganCount > 0)
			tox = tox / toxOrganCount
		else
			tox = 0


		var/update = 0
		for (var/organName in src.organs)
			var/obj/item/extOrgan = src.organs["[organName]"]
			if (istype(extOrgan, /obj/item/organ))
				var/obj/item/organ/O = extOrgan
				if ((O.brute_dam > 0 && brute > 0) || (O.burn_dam > 0 && burn > 0) || (O.tox_dam > 0 && tox > 0))
					if (O.heal_damage(brute, burn, tox))
						update = 1
			else if (istype(extOrgan, /obj/item/parts))
				var/obj/item/parts/O = extOrgan
				if ((O.brute_dam > 0 && brute > 0) || (O.burn_dam > 0 && burn > 0) || (O.tox_dam > 0 && tox > 0))
					if (O.heal_damage(brute, burn, tox))
						update = 1

		if (update)
			src.UpdateDamageIcon()
			health_update_queue |= src
		return 1
	else
		var/obj/item/E = src.organs["[zone]"]
		if (isitem(E))
			if (E.heal_damage(brute, burn, tox))
				src.UpdateDamageIcon()
				health_update_queue |= src
				return 1
		else
			return 0
	return

/mob/living/carbon/human/take_eye_damage(var/amount, var/tempblind = 0, var/side)
	if (!src || !ishuman(src) || (!isnum(amount) || amount == 0))
		return 0

	var/eyeblind = 0
	if (tempblind == 0)
		if (src.organHolder)
			var/datum/organHolder/O = src.organHolder
			if (side == "right")
				if (O.right_eye)
					O.right_eye.brute_dam = max(0, O.right_eye.brute_dam + amount)
			else if (side == "left")
				if (O.left_eye)
					O.left_eye.brute_dam = max(0, O.left_eye.brute_dam + amount)
			else
				if (O.right_eye && O.left_eye)
					O.right_eye.brute_dam = max(0, O.right_eye.brute_dam + (amount/2))
					O.left_eye.brute_dam = max(0, O.left_eye.brute_dam + (amount/2))
				else if (O.right_eye)
					O.right_eye.brute_dam = max(0, O.right_eye.brute_dam + amount)
				else if (O.left_eye)
					O.left_eye.brute_dam = max(0, O.left_eye.brute_dam + amount)
		else
			src.eye_damage = max(0, src.eye_damage + amount)
	else
		eyeblind = amount

	// Modify eye_damage or eye_blind if prompted, but don't perform more than we absolutely have to.
	var/blind_bypass = 0
	if (src.bioHolder && src.bioHolder.HasEffect("blind"))
		blind_bypass = 1

	if (amount > 0 && tempblind == 0 && blind_bypass == 0) // so we don't enter the damage switch thing if we're healing damage
		var/eye_dam = src.get_eye_damage()
		switch (eye_dam)
			if (10 to 12)
				src.change_eye_blurry(rand(3,6))

			if (12 to 15)
				src.show_text("Your eyes hurt.", "red")
				src.change_eye_blurry(rand(6,9))

			if (15 to 25)
				src.show_text("Your eyes are really starting to hurt.", "red")
				src.change_eye_blurry(rand(12,16))

				if (prob(eye_dam - 15 + 1))
					src.show_text("Your eyes are badly damaged!", "red")
					eyeblind = 5
					src.change_eye_blurry(5)
					src.bioHolder.AddEffect("bad_eyesight")
					SPAWN_DBG(10 SECONDS)
						src.bioHolder.RemoveEffect("bad_eyesight")

			if (25 to INFINITY)
				src.show_text("<B>Your eyes hurt something fierce!</B>", "red")

				if (prob(eye_dam - 25 + 1))
					src.show_text("You go blind!", "red")
					src.bioHolder.AddEffect("blind")
				else
					src.change_eye_blurry(rand(12,16))

	if (eyeblind != 0)
		src.eye_blind = max(0, src.eye_blind + eyeblind)

	//DEBUG_MESSAGE("Eye damage applied: [amount]. Tempblind: [tempblind == 0 ? "N" : "Y"]")
	return 1

/mob/living/carbon/human/get_brute_damage()
	var/brute = 0
	for (var/organName in src.organs)
		var/obj/item/externalOrgan = src.organs["[organName]"]
		if (istype(externalOrgan, /obj/item/organ))
			var/obj/item/organ/O = externalOrgan
			brute += O.brute_dam
		else if (istype(externalOrgan, /obj/item/parts))
			var/obj/item/parts/O = externalOrgan
			brute += O.brute_dam
	return brute

/mob/living/carbon/human/get_burn_damage()
	var/burn = 0
	for (var/organName in src.organs)
		var/obj/item/externalOrgan = src.organs["[organName]"]
		if (istype(externalOrgan, /obj/item/organ))
			var/obj/item/organ/O = externalOrgan
			burn += O.burn_dam
		else if (istype(externalOrgan, /obj/item/parts))
			var/obj/item/parts/O = externalOrgan
			burn += O.burn_dam
	return burn

/mob/living/carbon/human/get_toxin_damage()
	var/tox = src.toxloss
	for (var/organName in src.organs)
		var/obj/item/externalOrgan = src.organs["[organName]"]
		if (istype(externalOrgan, /obj/item/organ))
			var/obj/item/organ/O = externalOrgan
			tox += O.tox_dam
		else if (istype(externalOrgan, /obj/item/parts))
			var/obj/item/parts/O = externalOrgan
			tox += O.tox_dam
	return tox

/mob/living/carbon/human/get_eye_damage(var/tempblind = 0, var/side)
	if (tempblind == 0)
		var/eye_dam = 0
		if (src.organHolder)
			var/datum/organHolder/O = src.organHolder
			if (O.right_eye && side != "left")
				eye_dam += O.right_eye.brute_dam + O.right_eye.burn_dam + O.right_eye.tox_dam
			if (O.left_eye && side != "right")
				eye_dam += O.left_eye.brute_dam + O.left_eye.burn_dam + O.left_eye.tox_dam
		else
			eye_dam = src.eye_damage

		return eye_dam
	else
		return src.eye_blind

/mob/living/carbon/human/get_valid_target_zones()
	var/list/ret = list()
	for (var/organName in src.organs)
		if (istype(src.organs[organName], /obj/item))
			ret += organName
	return ret

/proc/random_brute_damage(var/mob/themob, var/damage, checkarmor=0) // do brute damage to a random organ
	if (!themob || !ismob(themob))
		return //???
	var/list/zones = themob.get_valid_target_zones()
	if(checkarmor)
		if (!zones || !length(zones))
			themob.TakeDamageAccountArmor("All", damage, 0, 0, DAMAGE_BLUNT)
		else
			if (prob(100 / zones.len + 1))
				themob.TakeDamageAccountArmor("All", damage, 0, 0, DAMAGE_BLUNT)
			else
				var/zone=pick(zones)
				themob.TakeDamageAccountArmor(zone, damage, 0, 0, DAMAGE_BLUNT)
	else
		if (!zones || !length(zones))
			themob.TakeDamage("All", damage, 0, 0, DAMAGE_BLUNT)
		else
			if (prob(100 / zones.len + 1))
				themob.TakeDamage("All", damage, 0, 0, DAMAGE_BLUNT)
			else
				var/zone=pick(zones)
				themob.TakeDamage(zone, damage, 0, 0, DAMAGE_BLUNT)

/proc/random_burn_damage(var/mob/themob, var/damage) // do burn damage to a random organ
	if (!themob || !ismob(themob))
		return //???
	var/list/zones = themob.get_valid_target_zones()
	if (!zones || !length(zones))
		themob.TakeDamage("All", 0, damage, 0, DAMAGE_BURN)
	else
		if (prob(100 / zones.len + 1))
			themob.TakeDamage("All", 0, damage, 0, DAMAGE_BURN)
		else
			themob.TakeDamage(pick(zones), 0, damage, 0, DAMAGE_BURN)

//ignore_organs if true. Needed for when non-functioning/missing kidney/liver genetates tox damage
/mob/living/carbon/human/take_toxin_damage(var/amount, var/ignore_organs = 0)
	if (..())
		return
	if (!ignore_organs)
		if (amount > 0 && src.organHolder)
			if (prob(30))
				src.organHolder.damage_organ(0, 0, amount/5, "left_kidney")
			if (prob(30))
				src.organHolder.damage_organ(0, 0, amount/5, "right_kidney")
			if (prob(30))
				src.organHolder.damage_organ(0, 0, amount/12, "liver")
	return

/mob/living/carbon/human/take_brain_damage(var/amount)
	if (!isnum(amount) || amount == 0)
		return 1

	if (src.organHolder && src.organHolder.brain)
		if (amount > 0)
			src.organHolder.damage_organ(amount, 0, 0, "brain")
		else
			src.organHolder.heal_organ(abs(amount), 0, 0, "brain")

	if (src.organHolder && src.organHolder.brain && src.organHolder.brain.get_damage() >= 120 && isalive(src))
		src.visible_message("<span class='alert'><b>[src.name]</b> goes limp, their facial expression utterly blank.</span>")
		INVOKE_ASYNC(src, TYPE_PROC_REF(/mob/living/carbon/human, death))

/mob/living/carbon/human/get_brain_damage()
	if (src.organHolder && src.organHolder.brain)
		return src.organHolder.brain.get_damage()
	//leaving this just in case, should never be called I assume
	..()

/mob/living/carbon/human/UpdateDamage()
	..()
	src.hud.update_health_indicator()
