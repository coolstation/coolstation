/obj/blob
	name = "blob"
	desc = "A mysterious alien blob-like organism."
	icon = 'icons/mob/blob.dmi'
	icon_state = "15"
	var/state_overlay = null
	var/anim_overlay = null // hack, there HAS to be a better way of doing this

	color = "#FF0000"
	var/original_color = "#FF0000"
	alpha = 180
	density = 1
	opacity = 0
	anchored = 1
	event_handler_flags = USE_FLUID_ENTER | USE_CANPASS
	var/evolution_flags = 0
	var/health = 30         // current health of the blob
	var/health_max = 30     // health cap
	var/armor = 1           // how much incoming damage gets divided by unless it bypasses armor
	var/ideal_temp = 310    // what temperature the blob is safe at
	var/datum/abilityHolder/blob/blob_holder = null // what's the holder tied to this this blob
	var/gen_rate_value = 0  // how much gen rate upkeep the blob is paying on this tile
	var/can_spread_from_this = 1
	var/can_attack_from_this = 1
	var/poison = 0
	var/can_absorb = 1
	var/special_icon = 0
	var/spread_type = null
	var/spread_value = 0
	var/movable = 0
	var/in_disposing = 0
	var/datum/action/bar/blob_health/healthbar //Hack.
	var/static/image/poisoned_image
	var/fire_coefficient = 1
	var/poison_coefficient = 1
	var/poison_spread_coefficient = 0.5
	var/poison_depletion = 1
	var/heat_divisor = 15
	var/temp_tolerance = 40
	mat_changename = 0
	mat_changedesc = 0
	var/runOnLife = 0 //Should this obj run Life?

	New()
		..()
		START_TRACKING
		if (!poisoned_image)
			poisoned_image = image('icons/mob/blob.dmi', "poison")
		src.update_icon()
		update_surrounding_blob_icons(get_turf(src))
		var/datum/controller/process/blob/B = get_master_blob_controller()
		B?.blobs += src
		for (var/obj/machinery/camera/C in get_turf(src))
			qdel(C)

		healthbar = new
		healthbar.owner = src
		healthbar.onStart()
		healthbar.onUpdate()

		if (istype(src.loc,/turf))
			if (istype(src.loc.loc,/area))
				src.loc.loc.Entered(src)

		SPAWN_DBG(0.1 SECONDS)
			for (var/mob/living/carbon/human/H in src.loc)
				if (H.decomp_stage == 4 || check_target_immunity(H))//too decomposed or too cool to be eaten
					continue
				src.visible_message("<span class='alert'><b>The blob starts trying to absorb [H.name]!</b></span>")
				actions.start(new /datum/action/bar/blob_absorb(H, blob_holder), src)
				playsound(src.loc, "sound/voice/blob/blobsucc[rand(1, 3)].ogg", 10, 1)

	proc/right_click_action()
		usr.examine_verb(src)

	Click(location, control, params)
		if (usr != blob_holder.owner)
			return
		var/list/pa = params2list(params)
		if ("right" in pa)
			right_click_action()
		else
			..()

	CanPass(atom/movable/mover, turf/target)
		. = ..()
		var/obj/projectile/P = mover
		if (istype(P) && P.proj_data) //Wire note: Fix for Cannot read null.type
			if (P.proj_data.type == /datum/projectile/slime)
				return 1
		if (istype(mover, /obj/decal))
			return 1

	proc/setHolder(var/datum/abilityHolder/blob/AH)
		if (blob_holder == AH)
			return
		if (blob_holder)
			blob_holder.blobs -= src
		if (AH)
			blob_holder = AH
			setMaterial(copyMaterial(AH.my_material))
			color = blob_holder.color
			original_color = blob_holder.color
			blob_holder.blobs |= src
			onAttach(blob_holder)
			if( state_overlay )
				var/image/blob_image
				if (special_icon)
					blob_image = image('icons/mob/blob_organs.dmi')
				else
					blob_image = image('icons/mob/blob.dmi')
				blob_image.appearance_flags |= RESET_COLOR
				blob_image.plane = PLANE_SELFILLUM + 1

				blob_image.color = blob_holder.organ_color
				blob_image.icon_state = state_overlay
				UpdateOverlays(blob_image,"organs")
			if ( anim_overlay )
				var/image/blob_anim_image = image('icons/mob/blob_organs.dmi')
				blob_anim_image.appearance_flags |= RESET_COLOR
				blob_anim_image.plane = PLANE_SELFILLUM + 2

				blob_anim_image.color = blob_holder.organ_color
				blob_anim_image.icon_state = anim_overlay
				UpdateOverlays(blob_anim_image,"anim_overlay")
			if ( blob_holder.hat && istype(src,/obj/blob/nucleus))
				src.vis_contents += blob_holder.hat

	proc/onAttach(var/datum/abilityHolder/blob/AH)
		if (istype(AH))
			if (spread_value)
				AH.spread_mitigation += spread_value

	proc/attack(var/turf/T)
		particleMaster.SpawnSystem(new /datum/particleSystem/blobattack(T,blob_holder.color))
		if (T?.density)
			T.blob_act(blob_holder.attack_power * 20)
			T.material?.triggerOnBlobHit(T, blob_holder.attack_power * 20)

		else
			for (var/mob/M in T.contents)
				M.blob_act(blob_holder.attack_power * 20)
			for (var/obj/O in T.contents)
				O.blob_act(blob_holder.attack_power * 20)
				O.material?.triggerOnBlobHit(O, blob_holder.attack_power * 20)


	proc/attack_random()
		var/list/allowed = list()
		for (var/D in cardinal)
			var/turf/Q = get_step(get_turf(src), D)
			if (Q && !(locate(/obj/blob) in Q))
				allowed += Q
		if (allowed.len)
			attack(pick(allowed))

	disposing()
		if (qdeled || in_disposing)
			return
		STOP_TRACKING
		in_disposing = 1
		var/datum/controller/process/blob/B = get_master_blob_controller()
		B.blobs -= src
		if (istype(blob_holder))
			blob_holder.blobs -= src
			if (gen_rate_value > 0)
				blob_holder.gen_rate_used = max(0,blob_holder.gen_rate_used - gen_rate_value)
				gen_rate_value = 0
			blob_holder.spread_mitigation -= spread_value
		var/turf/T = get_turf(src)
		if (istype(src.loc,/turf))
			if (istype(src.loc.loc,/area))
				src.loc.loc.Exited(src)
		healthbar?.onDelete()
		qdel(healthbar)
		healthbar = null
		..()
		update_surrounding_blob_icons(T)
		in_disposing = 0

	ex_act(severity)
		var/damage = 0
		var/damage_mult = 1
		switch(severity)
			if(OLD_EX_SEVERITY_1)
				damage = rand(30,50)
				damage_mult = 8
			if(OLD_EX_SEVERITY_2)
				damage = rand(25,40)
				damage_mult = 4
			if(OLD_EX_SEVERITY_3)
				damage = rand(10,20)
				damage_mult = 2
				if (prob(5))
					create_chunk(get_turf(src))

		src.take_damage(damage,damage_mult,"mixed")
		return

	bullet_act(var/obj/projectile/P)
		if(src.material) src.material.triggerOnBullet(src, src, P)
		var/damage = round((P.power*P.proj_data.ks_ratio), 1.0)
		var/damage_mult = 1
		var/damtype = "brute"
		if (damage < 1)
			return

		switch(P.proj_data.damage_type)
			if(D_KINETIC)
				damage_mult = 0.5
				damtype = "brute"
			if(D_PIERCING)
				damage_mult = 0.25
				damtype = "brute"
			if(D_ENERGY)
				damage_mult = 1
				damtype = "laser" // a type of burn damage that fire resistant membranes don't protect against
			if(D_BURNING)
				damage_mult = 2
				damtype = "burn"
			if(D_SLASHING)
				damage_mult = 1.5
				damtype = "brute"

		src.take_damage(damage,damage_mult,damtype)
		return

	temperature_expose(datum/gas_mixture/air, temperature, volume)
		var/temp_difference = abs(temperature - src.ideal_temp)
		var/tolerance = temp_tolerance
		if (material)
			material.triggerTemp(src, temperature)

		if (src.evolution_flags & BLOB_EVOLUTION_FIRERES)
			tolerance *= 3
		if(temp_difference > tolerance)
			temp_difference = abs(temp_difference - tolerance)

			src.take_damage(temp_difference / heat_divisor * min(1, volume / (CELL_VOLUME/3)), 1, "burn")

	attack_hand(var/mob/user)
		user.lastattacked = src
		var/adj1
		var/adj2 = pick_string("blob.txt", "adj2")
		var/act1
		var/act2 = pick_string("blob.txt", "act2")
		switch(user.a_intent)
			if(INTENT_HELP)
				adj1 = "help"
			if(INTENT_DISARM)
				adj1 = "disarm"
			if(INTENT_GRAB)
				adj1 = "grab"
			if(INTENT_HARM)
				adj1 = "harm"
		act1 = pick_string("blob.txt", "act1_[adj1]")
		adj1 = pick_string("blob.txt", "adj1_[adj1]")
		playsound(src.loc, "sound/voice/blob/blobdamaged[rand(1, 3)].ogg", 75, 1)
		src.visible_message("<span class='combat'><b>[user.name]</b> [adj1] [act1] [src]! That's [adj2] [act2]!</span>")
		return

	attackby(var/obj/item/W, var/mob/user)
		user.lastattacked = src
		if(ismobcritter(user) && user:ghost_spawned || isghostdrone(user))
			src.visible_message("<span class='combat'><b>[user.name]</b> feebly attacks [src] with [W], but is too weak to harm it!</span>")
			return
		if( istype(W,/obj/item/clothing/head) && blob_holder )
			user.drop_item()
			blob_holder.setHat(W)
			user.visible_message( "<span class='notice'>[user] places the [W] on the blob!</span>" )
			user.visible_message( "<span class='notice'>The blob disperses the hat!</span>" )
			blob_holder.owner.show_message( "<span class='notice'>[user] places the [W] on you!</span>" )
			return
		src.visible_message("<span class='combat'><b>[user.name]</b> attacks [src] with [W]!</span>")
		playsound(src.loc, "sound/voice/blob/blobdamaged[rand(1, 3)].ogg", 75, 1)
		if (W.hitsound)
			playsound(src.loc, W.hitsound, 50, 1)

		var/damage = W.force
		var/damage_mult = 1
		var/damtype = "brute"
		if (W.hit_type == DAMAGE_BURN)
			damtype = "burn"

		if (damage)
			if (isliving(blob_holder.owner))
				var/mob/living/L = blob_holder.owner
				L.was_harmed(user, W)

			if (src.type == /obj/blob && W.hit_type != DAMAGE_BURN)
				var/chunk_chance = 2
				if (W.hit_type == DAMAGE_CUT)
					chunk_chance = 8
				if (prob(chunk_chance))
					create_chunk(get_turf(user))

		if (material)
			material.triggerOnAttacked(src, user, src, W)

		src.take_damage(damage,damage_mult,damtype,user)

		if (ispryingtool(W))
			user.unlock_medal("Is it really that time again?", 1)

		return

	proc/create_chunk(var/turf/T)
		var/obj/item/material_piece/wad/BC = new()
		BC.set_loc(T)
		BC.setMaterial(copyMaterial(material))
		BC.name = "chunk of blob"

	proc/take_damage(var/amount,var/damage_mult = 1,var/damtype = "brute",var/mob/user)
		if (!isnum(amount) || amount <= 0)
			return

		if (damage_mult <= 0)
			damage_mult = 1

		if (damtype == "mixed")
			var/brute = round(amount / 2)
			var/burn = amount - brute
			take_damage(brute, damage_mult, "brute", user)
			take_damage(burn,  damage_mult, "burn",  user)
			return

		var/armor_value = armor
		var/ignore_armor = 0
		switch (damtype)
			if ("burn")
				if (!(src.evolution_flags & BLOB_EVOLUTION_FIRERES))
					ignore_armor = 1
				else
					amount = min(amount, health_max * 0.8)
				amount *= fire_coefficient
				//search for ectothermids.
				if (amount)
					for_by_tcl(T, /obj/blob/ectothermid)
						if (IN_RANGE(src, T, T.protect_range) && amount > 0)
							amount *= T.absorb(min(amount * damage_mult, src.health))
							break
			if ("laser")
				ignore_armor = 1
			if ("poison","self_poison")
				if (!(src.evolution_flags & BLOB_EVOLUTION_POISONRES))
					ignore_armor = 1
				else
					armor_value = max(2, armor)
				amount *= poison_coefficient
				//handle poison overlay
				if (amount && damtype == "poison")
					src.poison += amount * damage_mult
					updatePoisonOverlay()
					if (!blob_holder)
						SPAWN_DBG(1 SECOND)
							while (poison)
								Life()
								sleep(1 SECOND)
					return
			if ("chaos")
				ignore_armor = 1
		if (!ignore_armor && armor_value > 0)
			amount /= armor_value

		amount *= damage_mult

		if (!amount)
			return


		src.health -= amount
		src.health = max(0,min(src.health_max,src.health))

		if (src.health <= 0)
			src.onKilled()
			if (istype(blob_holder.owner, /mob/living/intangible/blob_overmind))
				var/mob/living/intangible/blob_overmind/o_blob = blob_holder.owner
				o_blob.onBlobDeath(src, user)
			playsound(src.loc, "sound/voice/blob/blobspread[rand(1, 2)].ogg", 100, 1)
			qdel(src)
		else
			src.update_icon()
			if (healthbar) //ZeWaka: Fix for null.onUpdate
				healthbar.onUpdate()
		return

	proc/updatePoisonOverlay()
		if (!poison)
			animate(src)
			color = original_color
		else
			animate(src, color="#00FF00", time=10, loop=-1)

	proc/onKilled()
		if (poison)
			poison = poison * poison_spread_coefficient
			var/list/spread = list()
			for (var/d in cardinal)
				var/turf/T = get_step(loc, d)
				if (T)
					var/obj/blob/B = locate() in T
					if (B)
						spread += B
			if (spread.len)
				var/amt = poison / length(spread)
				for (var/obj/blob/B in spread)
					B.poison += amt
		for (var/obj/material_deposit/M in src.loc)
			visible_message("<span class='alert'>[M] crumbles into dust!</span>")
			qdel(M)

	proc/heal_damage(var/amount)
		if (!isnum(amount) || amount < 1)
			return
		if (src.poison)
			amount /= 4
		src.health += amount
		src.health = max(0,min(src.health_max,src.health))
		particleMaster.SpawnSystem(new /datum/particleSystem/blobheal(get_turf(src),src.color))
		src.update_icon()
		healthbar.onUpdate()

	proc/update_icon()
		if (!src)
			return

		if (!special_icon || istype(src,/obj/blob/nucleus))
			var/dirs = 0
			for (var/dir in cardinal)
				var/turf/T = get_step(src, dir)
				if (!T)
					continue

				var/obj/blob/B = T.get_blob_on_this_turf()
				if (B)
					dirs |= dir
			icon_state = num2text(dirs)

		//else if(istext( special_icon ))
		//	if(!BLOB_OVERLAYS[ special_icon ])
		//		CRASH( "Invalid blob special icon [special_icon]." )
		//	else


		src.setMaterial(src.material)
		var/healthperc = get_fraction_of_percentage_and_whole(src.health,src.health_max)
		switch(healthperc)
			if (-INFINITY to 33)
				src.alpha *= 0.25
			if (34 to 66)
				src.alpha *= 0.5
			if (66 to 99)
				src.alpha *= 0.8
		src.alpha = max(src.alpha, 32)

	proc/spread(var/turf/T)
		if (!istype(T) || !T.can_blob_spread_here(null, null, isadmin(blob_holder.owner)))
			return

		var/blob_type = /obj/blob/
		if (ispath(src.spread_type))
			blob_type = src.spread_type

		var/obj/blob/B = new blob_type(T)
		B.setHolder(blob_holder)

		return B

	proc/Life()
		if (disposed)
			return 1
		if (src.poison)
			var/damage_taken = min(10, src.poison)
			take_damage(damage_taken, 1, "self_poison")
			src.poison -= damage_taken * poison_depletion
			src.poison = max(src.poison, 0)
			updatePoisonOverlay()
		if (!blob_holder)
			return 1
		if (blob_holder.tutorial)
			if (!blob_holder.tutorial.PerformSilentAction("blob-life", src))
				return 0

		return 0

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (O == src)
			return
		if (O.disposed)
			return
		if (blob_holder.owner != user)
			return
		if (isitem(O))
			if (GET_DIST(O, src) > 1)
				return
			var/datum/targetable/blob/devour_item/D = blob_holder.getAbility(/datum/targetable/blob/devour_item)
			if (D)
				D.cast(O)
			return
		if (istype(O, /obj/material_deposit))
			O.set_loc(src.loc)
		if (!istype(O, /obj/blob))
			return
		if (blob_holder.tutorial)
			if (!blob_holder.tutorial.PerformAction("mousedrop", list(O, src)))
				return
		if (istype(O, /obj/blob) && src.type == /obj/blob) // I'M LAZY. i'll fix this up if needed
			var/obj/blob/Q = O
			if (Q.movable)
				Q.onMove(src)

	proc/onMove(var/obj/blob/B)
		return

	onMaterialChanged()
		..()
		if (material && material.mat_id != "blob")
			src.name = "[material.name] [initial(src.name)]"

			// ARBITRARY MATH TIME! WOO!
			var/om_tough = max(blob_holder.initial_material.getProperty("density"), 1) * max(blob_holder.initial_material.getProperty("hard"), 1)
			var/c_tough = max(material.getProperty("density"), 1) * max(material.getProperty("hard"), 1)
			var/hm_orig = initial(health_max)
			var/new_tough = (c_tough/om_tough)
			if(new_tough > 2)
				new_tough = 1 + sqrt(new_tough-1)

			if (om_tough)
				var/hm_new = hm_orig * new_tough
				var/perc_change = hm_new / health_max
				health_max = hm_new
				health *= perc_change

			var/om_mp = blob_holder.initial_material.getProperty("thermal")
			var/c_mp = material.getProperty("thermal")
			var/hd_orig = initial(heat_divisor)

			var/mp_diff = max(0, c_mp - om_mp)
			heat_divisor = hd_orig + mp_diff / 300

			var/om_flame = blob_holder.initial_material.getProperty("flammable")
			var/c_flame = material.getProperty("flammable")
			var/fc_orig = initial(fire_coefficient)

			if (om_flame)
				var/t = (100 / om_flame * c_flame) / 100
				fire_coefficient = (0.25 + (t * 0.75)) * fc_orig

			var/om_perme = blob_holder.initial_material.getProperty("permeable")
			var/c_perme = material.getProperty("permeable")
			var/psc_orig = initial(poison_spread_coefficient)

			if (om_perme)
				var/t = (100 / om_perme * c_perme) / 100
				poison_spread_coefficient = (0.5 + (t * 0.5)) * psc_orig

			var/om_corr = blob_holder.initial_material.getProperty("corrosion")
			var/c_corr = material.getProperty("corrosion")
			var/pc_orig = initial(poison_coefficient)

			if (om_corr)
				var/pc_new = pc_orig * (om_corr / c_corr)
				poison_coefficient = pc_new

			if (material.alpha > 210)
				opacity = 1
			else
				opacity = initial(opacity)

		else
			src.name = initial(src.name)
			var/hm_curr = health_max
			health_max = initial(health_max)
			health *= health_max / hm_curr
			heat_divisor = initial(heat_divisor)
			fire_coefficient = initial(fire_coefficient)
			opacity = initial(opacity)
		original_color = color

/obj/blob/nucleus
	name = "blob nucleus"
	state_overlay = "nucleus"
	anim_overlay = "nucleus_blink"
	special_icon = 1
	desc = "The core of the blob. Destroying all nuclei effectively stops the organism dead in its tracks."
	armor = 1.5
	health_max = 500
	health = 500
	temp_tolerance = 1200
	fire_coefficient = 0.5
	poison_coefficient = 0.5
	poison_depletion = 3
	var/nextAttackMsg = 0

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	bullet_act(var/obj/projectile/P)
		if (P.proj_data.damage_type == D_ENERGY && src.blob_holder && prob(src.blob_holder.nucleus_reflectivity))
			shoot_reflected_to_sender(P, src)
			playsound(src.loc, "sound/voice/blob/blobreflect[rand(1, 5)].ogg", 100, 1)
		else
			..()

	onAttach(var/datum/abilityHolder/blob/AH)
		..()
		AH.nuclei += src
		if(AH.nucleus_overlay && AH.nucleus_overlay.alpha)
			src.UpdateOverlays(AH.nucleus_overlay, "reflectivity")

	take_damage(amount, mult, damtype, mob/user)
		var/now = world.timeofday
		if (!src.nextAttackMsg || now >= src.nextAttackMsg) //every 5 seconds supposedly
			boutput(blob_holder.owner, "<span class='blobalert'>Your nucleus in [get_area(src)] is taking damage!</span>")
			src.nextAttackMsg = now + 50 //every 5 seconds

		..()

	onKilled()
		if (!(src in blob_holder.nuclei))
			return

		blob_holder.nuclei -= src

		//still got some nuclei left!
		if (length(blob_holder.nuclei))
			//give a downside to having a nucleus destroyed. wipe biopoints and temp nerf generation (handled in blob overmind Life())
			blob_holder.points = 0
			blob_holder.debuff_timestamp = world.timeofday + blob_holder.debuff_duration

			out(blob_holder.owner, "<span class='blobalert'>Your nucleus in [get_area(src)] has been destroyed! You feel a lot weaker for a short time...</span>")

			if (prob(1))
				src.visible_message("<span class='blobalert'>With a great almighty wobble, the nucleus and nearby blob pieces wither and die! The time of jiggles is truly over.</span>")
			else
				src.visible_message("<span class='blobalert'>The nucleus and nearby blob pieces wither and die!</span>")

		//all dead :(
		else
			out(blob_holder.owner, "<span class='blobalert'>Your nucleus in [get_area(src)] has been destroyed!</span>")
			if (prob(50))
				playsound(src.loc, "sound/voice/blob/blobdeploy.ogg", 100, 1)
			else
				playsound(src.loc, "sound/voice/blob/blobdeath.ogg", 100, 1)

		//destroy blob tiles near the destroyed nucleus
		for (var/obj/blob/B in orange(1, src))
			//dont insta-kill nearby nuclei tho...
			if (!istype(B, /obj/blob/nucleus))
				B.onKilled()
				qdel(B)

		..()


/obj/blob/mutant
	name = "mutated blob"
	icon_state = "mutant"
	special_icon = 1
	desc = "It's a mutated blob bit. For all intents and purposes, it is useless."
	armor = 0
	can_absorb = 0
	movable = 0

/obj/blob/deposit
	name = "reagent deposit"
	state_overlay = "deposit-reagent"
	special_icon = 1
	desc = "It's a thick walled cell with reagents entrenched within."
	armor = 1
	gen_rate_value = 0
	can_absorb = 0
	var/static/image/overlay_image = null
	var/last_color = null
	var/building = 0
	movable = 1

	New()
		..()
		if (!overlay_image)
			overlay_image = image('icons/mob/blob.dmi', "deposit-material")

	examine(mob/user)
		if (disposed)
			return list()
		. = ..()
		if (user == blob_holder.owner)
			if (movable)
				. += "<span class='notice'>Clickdrag this onto any standard (not special) blob tile to move the reagent deposit there.</span>"
			. += "<span class='notice'>It contains:</span>"
			for (var/id in src.reagents.reagent_list)
				var/datum/reagent/R = src.reagents.reagent_list[id]
				. += "<span class='notice'>- [R.volume] unit[R.volume != 1 ? "s" : null] of [R.name]</span>"

	proc/update_reagent_overlay()
		if (disposed)
			return
		if (src.reagents.total_volume <= 0)
			UpdateOverlays(overlay_image,name)
			return
		var/curr_color = src.reagents.get_average_rgb()
		if (curr_color != last_color)
			UpdateOverlays(null,name)
			overlay_image.color = curr_color
			last_color = curr_color
			UpdateOverlays(overlay_image,name)

	proc/build_reclaimer()
		if (disposed || building)
			return
		building = 1
		var/obj/blob/deposit/reclaimer/B = new(src.loc)
		B.setHolder(blob_holder)
		B.reagents = src.reagents
		B.reagents.my_atom = B
		B.update_reagent_overlay()
		src.reagents = null
		B.setMaterial(src.material)
		src.material = null
		qdel(src)

	proc/build_replicator()
		if (disposed || building)
			return
		building = 1
		var/obj/blob/deposit/replicator/B = new(src.loc)
		B.setHolder(blob_holder)
		B.reagents = src.reagents
		B.reagents.my_atom = B
		B.set_master_reagent()
		B.update_reagent_overlay()
		src.reagents = null
		B.setMaterial(src.material)
		src.material = null
		qdel(src)

	onKilled()
		if (disposed)
			return
		..()
		if (src.reagents && src.reagents.total_volume)
			visible_message("<span class='alert'>[src] bursts open, releasing the deposited reagents in a cloud!</span>")
			smoke_reaction(reagents, 3, loc)

	onMove(var/obj/blob/B)
		var/turf/T = B.loc
		B.set_loc(loc)
		set_loc(T)
		update_icon()
		B.update_icon()

	replicator
		name = "replicator"
		state_overlay = "replicator"
		runOnLife = 1
		var/points_per_unit = 1
		var/max_per_tick = 3

		var/master_reagent_id = null
		var/datum/reagents/converting = null
		var/datum/action/bar/blob_replicator/progress = new

		New()
			..()
			progress.owner = src
			progress.onStart()

		disposing()
			..()
			progress.onDelete()
			qdel(progress)

		proc/set_master_reagent()
			if (master_reagent_id)
				return
			if (src.reagents && src.reagents.total_volume)
				master_reagent_id = src.reagents.get_master_reagent()
				name = "[initial(name)] ([src.reagents.get_master_reagent_name()])"
				src.reagents.clear_reagents()

		Life()
			if (converting)
				var/removed = min(max_per_tick, converting.total_volume)
				reagents.maximum_volume = reagents.total_volume + removed
				reagents.add_reagent(master_reagent_id, removed)
				converting.remove_any(removed)
				if (converting.total_volume < 1)
					converting = null
				update_reagent_overlay()
				progress.onUpdate()

		MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
			if (O.disposed)
				return
			if (blob_holder.tutorial)
				if (!blob_holder.tutorial.PerformAction("mousedrop", list(O, src)))
					return
			if (O.type == /obj/blob/deposit)
				if (src.converting)
					boutput(user, "<span class='alert'>Something is already loaded into the replicator.</span>")
					return
				var/obj/blob/deposit/D = O
				if (D.blob_holder.owner != user)
					return
				var/obj/blob/B = new(O.loc)
				B.setHolder(blob_holder)
				converting = O.reagents
				converting.my_atom = src
				converting.maximum_volume = converting.total_volume
				O.reagents = null
				boutput(user, "<span class='notice'>Reagents transferred to the replicator.</span>")
				qdel(O)
				update_reagent_overlay()
				progress.onUpdate()

		onMove(var/obj/blob/B)
			if (B.disposed)
				return
			if (!isturf(B.loc))
				return
			if (!reagents)
				return
			if (!reagents.total_volume)
				return
			var/obj/blob/deposit/D = new(B.loc)
			D.setHolder(blob_holder)
			qdel(B)
			var/trans_amt = src.reagents.total_volume
			D.reagents = new /datum/reagents(trans_amt)
			D.reagents.my_atom = D
			src.reagents.trans_to(D, trans_amt)
			D.update_reagent_overlay()
			boutput(usr, "<span class='notice'>Transferred [trans_amt] reagents into a deposit.</span>")
			update_reagent_overlay()

	reclaimer
		name = "reclaimer"
		state_overlay = "reclaimer"
		runOnLife = 1
		var/reagents_per_point = 5
		var/max_per_tick = 3
		var/may_gain_last = null
		movable = 0

		Life()
			if (..())
				return 1
			var/can_gain = round(reagents.total_volume / reagents_per_point)
			if (can_gain <= 0)
				var/obj/blob/lipid/B = new(loc)
				B.setHolder(blob_holder)
				qdel(src)
			var/may_gain = min(max_per_tick, blob_holder.points_max - blob_holder.points)
			may_gain_last = may_gain
			if (may_gain)
				particleMaster.SpawnSystem(new /datum/particleSystem/blobheal(get_turf(src),src.color))
				src.reagents.remove_any(reagents_per_point * may_gain)
				blob_holder.points += may_gain
				reagents.maximum_volume = reagents.total_volume
				update_reagent_overlay()

/obj/blob/launcher
	name = "slime launcher"
	state_overlay = "cannon"

	special_icon = 1
	desc = "It's a slime ball launcher. The organic equivalent of a defense turret."
	armor = 0
	gen_rate_value = 0
	can_absorb = 0
	runOnLife = 1
	var/slime_cost = 2
	var/firing_range = 7
	var/last_color = null
	var/datum/projectile/slime/current_projectile = new
	var/static/image/underlay_image = null

	New()
		..()
		if (!underlay_image)
			underlay_image = image('icons/mob/blob.dmi', "deposit-reagent")

	proc/update_reagent_underlay()
		if (disposed)
			return
		if (src.reagents.total_volume <= 0)
			underlays.len = 0
			return
		var/curr_color = src.reagents.get_average_rgb()
		if (curr_color != last_color)
			underlays.len = 0
			underlay_image.color = curr_color
			last_color = curr_color
			underlays += underlay_image

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (O.disposed)
			return
		if (blob_holder.tutorial)
			if (!blob_holder.tutorial.PerformAction("mousedrop", list(O, src)))
				return
		if (O.type == /obj/blob/deposit)
			if (src.reagents && src.reagents.total_volume)
				boutput(user, "<span class='alert'>Something is already loaded into the slime launcher.</span>")
				return
			var/obj/blob/deposit/D = O
			if (D.blob_holder.owner != user)
				return
			var/obj/blob/B = new(O.loc)
			B.setHolder(blob_holder)
			reagents = O.reagents
			reagents.my_atom = src
			O.reagents = null
			boutput(user, "<span class='notice'>Reagents transferred to the slime launcher.</span>")
			qdel(O)
			update_reagent_underlay()

	Life()
		if (..())
			return 1

		var/cost = 2
		if (reagents)
			if (reagents.total_volume)
				cost = 0

		if (cost && !blob_holder.pointCheck(slime_cost))
			return 1

		var/list/targets_primary = list()
		var/list/targets_secondary = list()

		//turrets can fire on humans, mobcritters and pods
		for (var/mob/living/M in view(firing_range, src))
			if ((ishuman(M) || (ismobcritter(M) && !M:ghost_spawned)) && !isdead(M) && !check_target_immunity(M))
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.mutantrace)
						targets_secondary += M
					else
						targets_primary += M
				else
					targets_primary += M

		for(var/obj/machinery/vehicle/pod_smooth/P in view(firing_range, src))
			targets_secondary += P

		if (!targets_primary.len && !length(targets_secondary))
			return 1

		var/atom/Target = null

		if (targets_primary.len)
			Target = pick(targets_primary)
		else
			Target = pick(targets_secondary)

		if (!Target)
			return 1

		var/obj/projectile/L = initialize_projectile_ST(src, current_projectile, Target)

		if (!L)
			return
		L.setup()

		if (!cost)
			L.reagents = new /datum/reagents(15)
			L.reagents.my_atom = L
			reagents.trans_to(L, 5, 3)
			L.color = L.reagents.get_average_rgb()
			L.name = "[L.reagents.get_master_reagent_name()]-infused slime"
			update_reagent_underlay()
		else
			blob_holder.deductPoints(slime_cost)
			L.color = blob_holder.color

		visible_message("<span class='alert'><b>[src] fires slime at [Target]!</b></span>")
		L.launch()

/datum/projectile/slime
	name = "slime"
	icon = 'icons/obj/projectiles.dmi'
	//state_overlay = "slime"
	color_red = 0
	color_green = 0
	color_blue = 0
	color_icon = "#ffffff"
	power = 20
	cost = 0
	dissipation_rate = 25
	dissipation_delay = 8
	ks_ratio = 0.5
	sname = "slime"
	shot_sound = 'sound/voice/blob/blobshoot.ogg'
	shot_number = 0
	damage_type = D_SPECIAL
	hit_ground_chance = 50
	window_pass = 0
	override_color = 1

	on_hit(atom/hit, angle, var/obj/projectile/O)
		..()

		if (O.reagents)
			O.reagents.reaction(hit, TOUCH)
			if (ismob(hit))
				O.reagents.trans_to(hit, 15)

		if (ismob(hit))
			var/mob/asshole = hit
			asshole.TakeDamage("All", 8, 0) //haha fuck armor amiright? blobs don't need a nerf in this department
			if (ishuman(asshole))
				var/mob/living/carbon/human/literal_asshole = asshole
				literal_asshole.remove_stamina(45)
				playsound(hit.loc, "sound/voice/blob/blobhit.ogg", 100, 1)

			if (prob(8))
				asshole.drop_item()

/obj/blob/mitochondria
	name = "mitochondria"
	state_overlay = "mitochondria"
	special_icon = 1
	desc = "It's a giant energy converting cell. It seems to be knitting together nearby holes in the blob."
	armor = 0
	gen_rate_value = 0
	can_absorb = 0
	runOnLife = 1
	poison_coefficient = 2
	poison_spread_coefficient = 1
	var/heal_range = 2
	var/heal_amount = 4

	Life()
		if (..())
			return 1
		for (var/obj/blob/B in view(heal_range,src))
			if (B.health < B.health_max)
				B.heal_damage(heal_amount)

/obj/blob/reflective
	name = "reflective membrane"
	state_overlay = "reflective"
	special_icon = 1
	desc = "This cell seems to reflect light."
	armor = 0
	gen_rate_value = 0
	can_absorb = 0
	opacity = 1
	health = 85
	health_max = 85

	bullet_act(var/obj/projectile/P)
		if (P.proj_data.damage_type == D_ENERGY)
			shoot_reflected_to_sender(P, src)
			playsound(src.loc, "sound/voice/blob/blobreflect[rand(1, 5)].ogg", 100, 1)
		else
			..()

/obj/blob/ectothermid
	name = "ectothermid"
	state_overlay = "ectothermid"
	special_icon = 1
	desc = "It's a giant energy converting cell. It seems to store heat energy."
	armor = 0
	gen_rate_value = 1
	can_absorb = 0
	runOnLife = 1
	var/protect_range = 3
	var/temptemp = 0
	var/absorbed_temp = 0
	var/removed = 0
	var/dead = 0

	New()
		. = ..()
		START_TRACKING

	temperature_expose(datum/gas_mixture/air, temperature, volume)
		if (temperature > T20C)
			temperature = T20C
		..(air, temperature, volume)

	onAttach(var/datum/abilityHolder/blob/AH)
		..()
		blob_holder.regenRate -= 0.5
		removed = 0.5

	disposing()
		..()
		STOP_TRACKING
		if (blob_holder)
			blob_holder.gen_rate_bonus += removed
			removed = 0

	Life()
		if (..())
			return 1
		absorbed_temp += temptemp * 0.25 + 50
		temptemp *= 0.75
		temptemp -= 50
		for (var/turf/floor/T in range(protect_range,src))
			var/datum/gas_mixture/air = T.air
			if (air.temperature > T20C)
				air.temperature /= 2
				air.temperature -= 100
				if(air.temperature > T20C)
					absorbed_temp += log(2, air.temperature)

	proc/absorb(amount)
		if(!dead)
			temptemp += amount
			return clamp(0.0005 * (temptemp - 100), 0, 1)
		else
			return 1

	onKilled()
		. = ..()
		dead = 1
		if(absorbed_temp > 1000)
			fireflash_s(get_turf(src), protect_range + 1, absorbed_temp, absorbed_temp/protect_range)


/obj/blob/plasmaphyll
	name = "plasmaphyll"
	state_overlay = "plasmaphyll"
	special_icon = 1
	desc = "It's a giant energy converting cell. It seems to feed on certain gases."
	armor = 0
	gen_rate_value = 1
	can_absorb = 0
	runOnLife = 1
	poison_coefficient = 0.5
	var/protect_range = 3
	var/consume_per_tick = 5.5
	var/plasma_per_point = 2

	Life()
		if (..())
			return 1
		var/toxins_consumed = 0
		for (var/turf/floor/T in range(protect_range,src))
			var/datum/gas_mixture/air = T.air
			if (air.toxins > 0)
				if (air.temperature > T20C)
					air.temperature = T20C + (air.temperature - T20C) / 1.25
				toxins_consumed += min(consume_per_tick, air.toxins)
				air.toxins = max(air.toxins - consume_per_tick, 0)
		if (!toxins_consumed)
			return
		blob_holder.points = min(blob_holder.points + round(toxins_consumed / plasma_per_point), blob_holder.points_max)

/obj/blob/lipid
	name = "lipid"
	state_overlay = "lipid"
	special_icon = 1
	desc = "It's an energy storage cell. It stores biopoints."
	armor = 0
	can_absorb = 0
	poison_coefficient = 0
	poison_spread_coefficient = 3

	onAttach(var/datum/abilityHolder/blob/AH)
		..()
		AH.lipids += src

	proc/use()
		blob_holder.lipids -= src
		blob_holder.points += 4
		var/turf/T = get_turf(src)
		set_loc(null)
		var/obj/blob/B = new /obj/blob(T)
		B.blob_holder = blob_holder
		blob_holder.blobs += B
		B.color = blob_holder.color
		qdel(src)

// TODO: REPLACE WITH SOMETHING COOLER - URS
/obj/blob/ribosome
	name = "ribosome"
	state_overlay = "ribosome"
	special_icon = 1
	desc = "It's a protein sequencing cell. It enhances the blob's ability to spread."
	poison_spread_coefficient = 1
	armor = 0
	can_absorb = 0
	var/added = 0
	var/list/affected_blobs = list()

	onAttach(var/datum/abilityHolder/blob/AH)
		..()
		AH.gen_rate_bonus += 0.1
		added = 0.1

	update_icon()
		return

	disposing()
		..()
		if (blob_holder)
			blob_holder.gen_rate_bonus -= added
			added = 0


/obj/blob/wall
	name = "thick membrane"
	desc = "This blob is encased in a tough membrane. It'll be harder to get rid of."
	state_overlay = "wall"
	opacity = 1
	special_icon = 1
	armor = 2
	health = 75
	health_max = 75
	can_absorb = 0
	flags = ALWAYS_SOLID_FLUID

	take_damage(var/amount,var/damage_mult = 1,var/damtype,var/mob/user)
		if (damage_mult == 0)
			return
		if (damtype != "mixed")
			if (amount * damage_mult > health_max * 0.6)
				amount = health_max * 0.6 / damage_mult
		..(amount, damage_mult, damtype, user)

	update_icon()
		return

/obj/blob/firewall
	name = "fire-resistant membrane"
	desc = "This blob is encased in a fireproof and gas impermeable membrane."
	state_overlay = "firewall"
	opacity = 1
	special_icon = 1
	armor = 1
	can_absorb = 0
	gas_impermeable = TRUE

	take_damage(amount, mult, damtype, mob/user)
		if (damtype == "burn")
			return
		else if (damtype == "laser")
			return ..(amount/3,mult,damtype,user)
		else return ..()

	update_icon()
		return

///A pair of blob tiles that take damage & die in tandem
/obj/blob/linked
	name = "linked blob"
	var/obj/blob/linked/linked_blob
	var/dying = FALSE //Need to prevent these from infinite looping
	health = 60 //twice that of a regular blob tile
	health_max = 60
	special_icon = 1

	//uwu
	heal_damage(amount)
		..()
		if (linked_blob)
			linked_blob.health = src.health
			particleMaster.SpawnSystem(new /datum/particleSystem/blobheal(get_turf(linked_blob),linked_blob.color))
			linked_blob.update_icon()
			linked_blob.healthbar.onUpdate()
		else //shouldn't be possible for a linked blob to occur alone, rectify
			onKilled()
			qdel(src)


	///Transfer damage
	take_damage(amount, damage_mult, damtype, mob/user)
		..()
		if (linked_blob)
			if (src.health > 0) //don't really care if we're dying anyway
				linked_blob.health = src.health
				linked_blob.update_icon()
				if (linked_blob.healthbar)
					linked_blob.healthbar.onUpdate()
		else //shouldn't be possible for a linked blob to occur alone, rectify
			onKilled()
			qdel(src)

	///Kill soulmate blob (biggest tragedy of 2053)
	onKilled()
		..()
		dying = TRUE
		var/obj/ladder/turf_ladder = locate() in get_turf(src)

		if (turf_ladder)
			turf_ladder.blocked = FALSE
		if (!linked_blob?.dying)
			linked_blob.onKilled()
			qdel(linked_blob)//bypassing onBlobDeath at the moment but I haven't coded the AI to build level transfers anyway

/obj/blob/linked/upper
	name = "blob level transfer"
	desc = "Blob is oozing down a hole..."
	state_overlay = "transfer_upper"

/obj/blob/linked/lower
	name = "blob level transfer"
	desc = "More blob is oozing in from above..."
	state_overlay = "transfer_lower"

/obj/material_deposit
	name = "material deposit"
	desc = "A blob-engulfed chunk of materials."
	var/datum/abilityHolder/blob/blob_holder = null
	icon = 'icons/mob/blob.dmi'
	icon_state = "15"
	//state_overlay =
	layer = 4

	New(nloc, mat, blob)
		..(nloc)
		src.blob_holder = blob
		setMaterial(copyMaterial(mat))
		pixel_x = rand(-12, 12)
		pixel_y = rand(-12, 12)

		var/image/ov = image('icons/mob/blob_organs.dmi')
		ov.appearance_flags |= RESET_COLOR
		ov.plane = PLANE_SELFILLUM + 1
		ov.color = blob_holder.organ_color
		ov.icon_state = "deposit-material"
		UpdateOverlays(ov, name)

	onMaterialChanged()
		pixel_x = rand(-12, 12)
		pixel_y = rand(-12, 12)

	attackby(var/obj/item/W, var/mob/user)
		var/obj/blob/B = locate() in src.loc
		if (!B)
			qdel(src)
			return
		B.Attackby(W, user)

/////////////////////////
/// BLOB RELATED PROCS //
/////////////////////////

/atom/proc/blob_act(var/power)
	return

/turf/proc/get_object_for_blob_to_attack()
	if (!src)
		return null

	if (src.contents.len < 1)
		return null

	for (var/obj/O in src.contents)
		if (O.density)
			return O

	for (var/mob/M in src.contents)
		if (!isdead(M))
			return M

	return null

/turf/proc/can_blob_spread_here(var/mob/feedback, var/skip_adjacent, var/admin_overmind = 0)
	if (!src)
		return 0

	if (istype(src,/turf/space/))
		if (feedback)
			boutput(feedback, "<span class='alert'>You can't spread the blob into space.</span>")
		return 0

	if (!admin_overmind) //admins can spread wherever (within reason)
		if (!issimulatedturf(src))
			if (feedback)
				boutput(feedback, "<span class='alert'>You can't spread the blob onto that kind of tile.</span>")
			return 0

	if (src.density)
		if (feedback)
			boutput(feedback, "<span class='alert'>You can't spread the blob into a wall.</span>")
		return 0

	for (var/obj/O in src.contents)
		if (O.density)
			if (feedback)
				boutput(feedback, "<span class='alert'>That tile is blocked by [O].</span>")
			return 0

	if (skip_adjacent)
		return 1

	var/turf/checked
	for (var/dir in cardinal)
		checked = get_step(src, dir)
		for (var/obj/blob/B in checked.contents)
			if (B.type != /obj/blob/mutant)
				return B

	if (feedback)
		boutput(feedback, "<span class='alert'>There is no blob adjacent to this tile to spread from.</span>")

	return 0

/turf/proc/is_blob_adjacent()
	if (!src)
		return 0

	var/turf/checked
	for (var/dir in cardinal)
		checked = get_step(src, dir)
		for (var/obj/blob/B in checked.contents)
			return 1

	return 0

/turf/proc/get_blob_on_this_turf()
	if (!src)
		return null

	for (var/obj/blob/B in src.contents)
		return B

	return null

/proc/get_master_blob_controller()
	if(!processScheduler)
		return null
	for (var/datum/controller/process/blob/B in processScheduler.processes)
		return B
	return null

/proc/update_surrounding_blob_icons(var/turf/T)
	if (!istype(T))
		return
	for (var/obj/blob/B in orange(1,T))
		B.update_icon()
