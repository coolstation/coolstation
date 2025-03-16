#define BLOB_EVOLUTION_FIRERES		(1<<0)
#define BLOB_EVOLUTION_POISONRES	(1<<1)
#define BLOB_EVOLUTION_DEVOURITEM	(1<<2)
#define BLOB_EVOLUTION_REINFORCE	(1<<3)
#define BLOB_EVOLUTION_REINFORCEALL	(1<<4)

// THE BLOB HOLDER

/datum/abilityHolder/blob
	topBarRendered = 1
	pointName = "Biomass Points"
	regenRate = 3
	var/total_placed = 0
	var/started = 0
	var/spread_mitigation = 0
	var/spread_upgrade = 0
	var/viewing_upgrades = TRUE
	var/datum/tutorial_base/blob/tutorial
	var/evo_points = 0
	var/attack_power = 1
	var/multi_spread = 0
	var/extra_nuclei = 0
	var/evolution_flags = 0
	var/datum/material/my_material = null
	var/datum/material/initial_material = null
	var/list/obj/blob/blobs = list()
	var/list/obj/blob/lipid/lipids = list()
	var/list/obj/blob/nucleus/nuclei = list()
	var/color = "#F5A9B8"
	var/organ_color = "#5BCEFA"
	var/points_max = 1
	var/points_max_bonus = 7 //starting bio point cap should be 10-12 now, i think. a bit more wiggle room for starter blobs.
	var/gen_rate_bonus = 0
	var/gen_rate_used = 0
	var/next_evo_point = 25
	var/next_extra_nucleus = 100
	var/upgrading = 0
	var/upgrade_id = 1
	var/nucleus_reflectivity = 0
	var/image/nucleus_overlay
	var/next_pity_point = 100
	var/debuff_timestamp = 0
	var/debuff_duration = 1200 //deciseconds. 1200 = 2 minutes
	var/starter_buff = 1
	var/obj/item/clothing/head/hat = null

	New()
		..()
#ifdef Z3_IS_A_STATION_LEVEL
		if(isintangible(src.owner))
			src.addAbility(/datum/targetable/ghost_observer/upper_transfer)
			src.addAbility(/datum/targetable/ghost_observer/lower_transfer)
#endif
		src.addAbility(/datum/targetable/blob/plant_nucleus)
		src.addAbility(/datum/targetable/blob/set_color)
		src.addAbility(/datum/targetable/blob/tutorial)
		src.addAbility(/datum/targetable/blob/help)

		if(prob(50))
			color = "#5BCEFA"
			organ_color = "#F5A9B8"

		my_material = copyMaterial(getMaterial("blob"))
		my_material.color = src.color
		initial_material = copyMaterial(getMaterial("blob"))

		src.nucleus_overlay = image('icons/mob/blob.dmi', null, "reflective_overlay")
		src.nucleus_overlay.alpha = 0
		src.nucleus_overlay.appearance_flags = RESET_COLOR

	onLife(mult = 1)
		if (..())
			return 1

		//time to un-apply the nucleus-destroyed debuff
		if (src.debuff_timestamp && world.timeofday >= src.debuff_timestamp)
			src.debuff_timestamp = 0
			boutput(src, "<span class='alert'><b>You can feel your former power returning!</b></span>")

		if (blobs.len > 0)
			/**
			 * at 2175 blobs, blob points max will reach about 350. It will begin decreasing sharply after that
			 * This is a size penalty. Basically if the blob gets too damn big, the crew has some chance of
			 * fighting it back because it will run out of points.
			 */
			src.points_max = src.BlobPointsBezierApproximation(floor(length(src.blobs) / 5)) + src.points_max_bonus

		src.generatePoints(mult)

		if (length(blobs) >= next_evo_point)
			next_evo_point += initial(next_evo_point)
			evo_points++
			boutput(src, "<span class='notice'><b>You have expanded enough to earn one evo point! You will be granted another at size [next_evo_point]. Good luck!</b></span>")

		if (total_placed >= next_pity_point)
			next_pity_point += initial(next_pity_point)
			evo_points++
			boutput(src, "<span class='notice'><b>You have perfomed enough spreads to earn one evo point! You will be granted another after placing [next_pity_point] tiles. Good luck!</b></span>")

		if (length(blobs) >= next_extra_nucleus)
			next_extra_nucleus += initial(next_extra_nucleus)
			extra_nuclei++
			boutput(src, "<span class='notice'><b>You have expanded enough to earn one extra nucleus! You will be granted another at size [next_extra_nucleus]. Good luck!</b></span>")

		src.nucleus_reflectivity = src.blobs.len < 151 ? 100 : 100 - ((src.blobs.len - 150)/2)
		var/old_alpha = src.nucleus_overlay.alpha
		var/new_alpha = clamp(src.nucleus_reflectivity * 2, 0, 255)
		if(abs(old_alpha - new_alpha) >= 25 || (old_alpha != new_alpha && (new_alpha == 0 || old_alpha == 0)))
			src.nucleus_overlay.alpha = new_alpha
			for(var/obj/blob/nucleus/N in src.nuclei)
				if(new_alpha)
					N.UpdateOverlays(src.nucleus_overlay, "reflectivity")
				else
					N.UpdateOverlays(null, "reflectivity")

	Stat()
		stat(null, " ")
		stat("--Blob--", " ")
		stat("Bio Points:", "[floor(points)]/[points_max]")
		//debuff active
		if (src.debuff_timestamp && gen_rate_bonus > 0)
			var/genBonus = floor(gen_rate_bonus / 2)
			stat("Generation Rate:", "[regenRate + genBonus - gen_rate_used]/[regenRate + gen_rate_bonus] BP <span class='alert'>(WEAKENED)</span>")

		else
			stat("Generation Rate:", "[regenRate + gen_rate_bonus - gen_rate_used]/[regenRate + gen_rate_bonus] BP")

		stat("Blob Size:", blobs.len)
		stat("Total spreads:", total_placed)
		stat("Evo Points:", evo_points)
		stat("Next Evo Point at size:", next_evo_point)
		stat("Total spreads needed for additional point:", next_pity_point)
		stat("Living nuclei:", nuclei.len)
		stat("Unplaced extra nuclei:", extra_nuclei)
		stat("Next Extra Nucleus at size:", next_extra_nucleus)

	deductPoints(var/cost)
		if (points < cost)
			var/needed = cost - points
			if (lipids.len * 4 >= needed)
				while (points < cost)
					if (!lipids.len)
						break
					var/obj/blob/lipid/L = pick(lipids)
					if (!istype(L))
						lipids -= L
						continue
					L.use()
		if (points >= cost)
			points -= cost
			return 1

	pointCheck(cost)
		if (!src.usesPoints)
			return 1
		if (src.points < 0) // Just-in-case fallback.
			logTheThing("debug", usr, null, "'s ability holder ([src.type]) was set to an invalid value (points less than 0), resetting.")
			src.points = 0
		for (var/Q in lipids)
			if (!istype(Q, /obj/blob/lipid))
				lipids -= Q
		if (cost > points + length(lipids) * 4)
			boutput(owner, notEnoughPointsMessage)
			return 0
		return 1

	generatePoints(mult)
		//debuff active
		lastBonus = bonus
		src.points += bonus

		var/genBonus = gen_rate_bonus
		if (src.debuff_timestamp && genBonus > 0)
			genBonus = floor(genBonus / 2)

			//maybe other debuffs here in the future

		src.points = clamp((src.points + (regenRate + genBonus - gen_rate_used) * mult), 0, src.points_max) //these are rounded in point displays


	updateButtons(called_by_owner, start_x, start_y)
		if(..())
			return
		if (src.shiftPower)
			src.shiftPower.object.overlays += src.shiftPower.object.shift_highlight
		if (src.ctrlPower)
			src.ctrlPower.object.overlays += src.ctrlPower.object.ctrl_highlight
		if (src.altPower)
			src.altPower.object.overlays += src.altPower.object.alt_highlight
		if (viewing_upgrades)
			var/pos_x = 0
			var/pos_y = 14

			for(var/datum/targetable/blob/evolution/B in src.abilities)
				if (!istype(B.object))
					continue
				B.object.overlays = list()
				B.object.invisibility = 0
				B.object.screen_loc = "WEST+[pos_x]:9,NORTH-[pos_y]"
				pos_x++
				if(pos_x > 3)
					pos_x = 0
					pos_y--
				if(!B.check_requirements())
					B.object.overlays += B.object.darkener
		else
			for(var/datum/targetable/blob/evolution/B in src.abilities)
				B.object.invisibility = 101

	proc/reset()
		src.attack_power = initial(src.attack_power)
		src.points = 0
		src.points_max = initial(src.points_max)
		src.points_max_bonus = initial(src.points_max_bonus)
		src.regenRate = initial(src.regenRate)
		src.gen_rate_bonus = 0
		src.gen_rate_used = 0
		src.evo_points = 0
		src.next_evo_point = initial(src.next_evo_point)
		src.next_pity_point = initial(src.next_pity_point)
		src.total_placed = 0
		src.spread_upgrade = 0
		src.spread_mitigation = 0
		src.viewing_upgrades = 1
		src.help_mode = 0
		src.blobs = new()
		src.started = 0
		src.extra_nuclei = 0
		src.next_extra_nucleus = initial(src.next_extra_nucleus)
		src.multi_spread = 0
		src.upgrading = 0
		src.upgrade_id = 1
		src.lipids = new()
		src.nuclei = new()
		src.my_material = copyMaterial(getMaterial("blob"))
		src.my_material.color = src.color
		src.initial_material = copyMaterial(getMaterial("blob"))
		src.debuff_timestamp = 0
		src.starter_buff = 1

		for(var/datum/targetable/B in src.abilities)
			src.removeAbilityInstance(B)

#ifdef Z3_IS_A_STATION_LEVEL
		if(isintangible(src.owner))
			src.addAbility(/datum/targetable/ghost_observer/upper_transfer)
			src.addAbility(/datum/targetable/ghost_observer/lower_transfer)
#endif
		src.addAbility(/datum/targetable/blob/plant_nucleus)
		src.addAbility(/datum/targetable/blob/set_color)
		src.addAbility(/datum/targetable/blob/tutorial)
		src.addAbility(/datum/targetable/blob/help)

	proc/setHat( var/obj/item/clothing/head/new_hat )
		new_hat.pixel_y = 15
		new_hat.pixel_x = 0
		new_hat.appearance_flags |= KEEP_APART & RESET_ALPHA
		new_hat.plane = PLANE_SELFILLUM + 1
		for( var/obj/blob/b in nuclei )
			if(src.hat)
				b.vis_contents -= src.hat
			b.vis_contents += new_hat
		if( src.hat )
			qdel(src.hat)
		src.hat = new_hat
		src.hat.set_loc(src.owner)

	proc/BlobPointsBezierApproximation(var/t)
		// t = number of tiles occupied by the blob
		t = max(0, min(1000, t))
		var/points

		if (t < 514)
			points = t - ((t ** 2) / 4000) - (eulers ** ((t-252)/50)) + 1
		else if (t >= 514)
			// Oh dear, you seem to be too fucking big. Whoopsie daisies...
			// Marq update: gonna flatline this at 40 so big blobs aren't completely useless
			// The idea is not that we should be punishing big blobs, rather we should be making progress progressively difficult.
			points = max(40, 30000 / (t - 417) - 51)

		return floor(max(0, points))

	proc/get_gen_rate()
		return regenRate + gen_rate_bonus - gen_rate_used

	proc/tutorial_check(var/id, var/turf/T)
		if(src.tutorial && !src.tutorial.PerformAction(id, T))
			return 0
		return 1

	proc/auto_spread(turf/starter, maxRange = 3, maxTurfs = 15, maxLoops = 2, currentRange = 1, currentTurfs = 0, currentLoop = 1)
		//if we went outside the allowed range
		if (currentRange > maxRange)
			//if we have loops left, do so
			if (currentLoop < maxLoops)
				src.auto_spread(starter, maxRange, maxTurfs, maxLoops, 1, currentTurfs, currentLoop + 1)
			return

		var/list/outerArea = orange(currentRange, starter)

		//subtract the inner tiles (we only want the outer edge of our range)
		if (currentRange > 1)
			var/list/innerArea = orange(currentRange - 1, starter)
			outerArea -= innerArea

		for (var/turf/T in outerArea)
			//reached max amount of blob tiles to place
			if (currentTurfs > maxTurfs)
				return

			if (T.can_blob_spread_here(null, null, isadmin(owner)))
				var/obj/blob/B
				if (prob(5))
					B = new /obj/blob/lipid(T)
				else if (prob(5))
					B = new /obj/blob/ribosome(T)
				else if (prob(5))
					B = new /obj/blob/mitochondria(T)
				else if (prob(5))
					B = new /obj/blob/wall(T)
				else if (prob(5))
					B = new /obj/blob/firewall(T)
				else
					B = new /obj/blob(T)
				src.total_placed++
				B.setHolder(src)
				currentTurfs++

		//recurse!
		src.auto_spread(starter, maxRange, maxTurfs, maxLoops, currentRange + 1, currentTurfs, currentLoop)


	proc/start_tutorial()
		if (tutorial)
			return
		tutorial = new(src)
		if (tutorial.tutorial_area)
			tutorial.Start()
		else
			boutput(src, "<span class='alert'>Could not start tutorial! Please try again later or call Mylie.</span>")
			tutorial = null
			return

// STARTER ABILITIES

/datum/targetable/blob
	icon = 'icons/ui/blob_ui.dmi'
	icon_state = "blob-template"
	cooldown = 0
	last_cast = 0
	targeted = 1
	target_anything = 1
	preferred_holder_type = /datum/abilityHolder/blob
	var/datum/abilityHolder/blob/blob_holder

	onAttach(datum/abilityHolder/H)
		. = ..()
		src.blob_holder = H

/datum/targetable/blob/plant_nucleus
	name = "Deploy"
	icon_state = "blob-nucleus"
	desc = "This will place your first nucleus at the target. You can only do this once. Once placed, a small amount of blob tiles will spawn around it."
	targeted = 1

	cast(var/atom/target)
		if (..())
			return 1

		if (!target)
			target = get_turf(src.holder.owner)

		var/turf/T = get_turf(target)

		if (istype(T,/turf/space/))
			boutput(src.holder.owner, "<span class='alert'>You can't start in space!</span>")
			return

		if (!isadmin(src.holder.owner)) //admins can spawn wherever
			if (!istype(T.loc, /area/station/) && !istype(T.loc, /area/blob/))
				boutput(src.holder.owner, __red("You need to start on the [station_or_ship()]!"))
				return

			if (!issimulatedturf(T))
				boutput(src.holder.owner, "<span class='alert'>This kind of tile cannot support a blob.</span>")
				return

			if (T.density)
				boutput(src.holder.owner, "<span class='alert'>You can't start inside a wall!</span>")
				return

			for (var/atom/O in T.contents)
				if (O.density)
					boutput(src.holder.owner, "<span class='alert'>That tile is blocked by [O].</span>")
					return

			for (var/mob/M in viewers(T, 7))
				if (isrobot(M) || ishuman(M))
					if (!isdead(M))
						boutput(src.holder.owner, "<span class='alert'>You are being watched.</span>")
						return

		if (!src.blob_holder.tutorial_check("deploy", T))
			return

		var/obj/blob/nucleus/C = new /obj/blob/nucleus(T)
		C.layer++
		src.blob_holder.total_placed++
		C.setHolder(src.holder)
		C.Life()
		src.blob_holder.started = 1
		src.holder.addAbility(/datum/targetable/blob/spread)
		src.holder.addAbility(/datum/targetable/blob/attack)
		src.holder.addAbility(/datum/targetable/blob/consume)
		src.holder.addAbility(/datum/targetable/blob/repair)
		src.holder.addAbility(/datum/targetable/blob/absorb)
		src.holder.addAbility(/datum/targetable/blob/promote_nucleus)
	#ifdef Z3_IS_A_STATION_LEVEL
		src.holder.addAbility(/datum/targetable/blob/blob_level_transfer)
	#endif
		src.holder.addAbility(/datum/targetable/blob/build/ribosome)
		src.holder.addAbility(/datum/targetable/blob/build/lipid)
		src.holder.addAbility(/datum/targetable/blob/build/mitochondria)
		src.holder.addAbility(/datum/targetable/blob/build/wall)
		src.holder.addAbility(/datum/targetable/blob/build/firewall)
		src.holder.addAbility(/datum/targetable/blob/toggle_evolution_bar)
		src.holder.addAbility(/datum/targetable/blob/evolution/extra_genrate)
		src.holder.addAbility(/datum/targetable/blob/evolution/quick_spread)
		src.holder.addAbility(/datum/targetable/blob/evolution/spread)
		src.holder.addAbility(/datum/targetable/blob/evolution/attack)
		src.holder.addAbility(/datum/targetable/blob/evolution/fire_resist)
		src.holder.addAbility(/datum/targetable/blob/evolution/poison_resist)
		src.holder.addAbility(/datum/targetable/blob/evolution/devour_item)
		src.holder.addAbility(/datum/targetable/blob/evolution/bridge)
		src.holder.addAbility(/datum/targetable/blob/evolution/launcher)
		src.holder.addAbility(/datum/targetable/blob/evolution/plasmaphyll)
		src.holder.addAbility(/datum/targetable/blob/evolution/ectothermid)
		src.holder.addAbility(/datum/targetable/blob/evolution/reflective)

		if (!src.blob_holder.tutorial)
			//do a little "blobsplosion"
			var/amount = rand(20, 30)
			src.blob_holder.auto_spread(T, maxRange = 3, maxTurfs = amount)
		src.holder.owner.playsound_local(src.holder.owner.loc, "sound/voice/blob/blobdeploy.ogg", 50, 1)
		src.holder.removeAbility(/datum/targetable/blob/plant_nucleus)
		src.holder.removeAbility(/datum/targetable/blob/set_color)
		src.holder.removeAbility(/datum/targetable/blob/tutorial)

/datum/targetable/blob/help
	name = "Toggle Help Mode"
	desc = "Enter or exit help mode."
	icon_state = "blob-help0"
	targeted = 0
	special_screen_loc = "SOUTH,EAST"
	helpable = 0

	cast()
		if (..())
			return
		if (src.holder.help_mode)
			src.holder.help_mode = 0
		else
			src.holder.help_mode = 1
			boutput(src.holder.owner, "<span class='notice'>Help Mode has been activated. To disable it, click on this button again.</span>")
			boutput(src.holder.owner, "<span class='notice'>Hold down Shift, Ctrl or Alt while clicking the button to set it to that key.</span>")
			boutput(src.holder.owner, "<span class='notice'>You will then be able to use it freely by holding that button and left-clicking a tile.</span>")
			boutput(src.holder.owner, "<span class='notice'>Alternatively, you can click with your middle mouse button to use the ability on your current tile.</span>")
			boutput(src.holder.owner, "<span class='notice'>If you want to swap the places of two buttons on this bar, click and drag one to the position you want it to occupy.</span>")
		src.object.icon_state = "blob-help[src.holder.help_mode]"
		src.holder.updateButtons()

/datum/targetable/blob/set_color
	name = "Set Color"
	desc = "Choose what color you want your blob to be. This will be removed when you start the blob."
	icon_state = "blob-color"
	targeted = 0

	cast()
		if (..())
			return 1
		src.blob_holder.color = input("Select your Color","Blob") as color
		src.blob_holder.organ_color = input("Select your Organelle Color","Blob") as color
		src.blob_holder.my_material.color = src.blob_holder.color

/datum/targetable/blob/spread
	name = "Spread"
	icon_state = "blob-spread"
	desc = "This spends two biomass to spread to the desired tile. Blobs must be placed cardinally adjacent to other blobs."
	pointCost = 0
	cooldown = 2 SECONDS
	var/pointCostPostStarterBuff = 2

	cast(var/atom/target)
		if (..())
			return 1

		if (!target)
			target = get_turf(src.holder.owner)

		var/turf/T = get_turf(target)

		if (istype(T, /turf/space))
			var/datum/targetable/blob/bridge/B = src.holder.getAbility(/datum/targetable/blob/bridge)

			if (B)
				var/success = !B.cast(T)		//Abilities return 1 on failure and 0 on success. fml
				if (success)
					boutput(src.holder.owner, "<span class='notice'>You create a bridge on [T].</span>")
				else
					boutput(src.holder.owner, "<span class='alert'>You were unable to place a bridge on [T].</span>")

				return 1

		var/obj/blob/B1 = T.can_blob_spread_here(src.holder.owner, null, isadmin(src.holder.owner))
		if (!istype(B1))
			return 1

		if (!src.blob_holder.tutorial_check("spread", T))
			return 1

		var/obj/blob/B2 = new /obj/blob(T)
		B2.setHolder(src.holder)

		cooldown = 16
		var/mindist = 127
		for_by_tcl(nucleus, /obj/blob/nucleus)
			if(nucleus.blob_holder == src.holder)
				mindist = min(mindist, GET_DIST(T, get_turf(nucleus)))

		mindist *= max((length(src.blob_holder.blobs) * 0.005) - 2, 1)

		cooldown = max(cooldown + max(mindist * 0.5 - 10, 0) - src.blob_holder.spread_upgrade * 5 - src.blob_holder.spread_mitigation * 0.5, 6)
		src.blob_holder.total_placed++

		var/extra_spreads = round(src.blob_holder.multi_spread / 100) + (prob(src.blob_holder.multi_spread % 100) ? 1 : 0)
		if (extra_spreads)
			var/list/spreadability = list()
			for (var/turf/floor/Q in view(7, src.holder.owner))
				if (locate(/obj/blob) in Q)
					continue
				var/obj/blob/B3 = Q.can_blob_spread_here(null, null, isadmin(src.holder.owner))
				if (B3)
					spreadability += Q


			for (var/i = 1, i <= extra_spreads && spreadability.len, i++)
				var/turf/R = pick(spreadability)
				var/obj/blob/B3 = new /obj/blob(R)
				src.blob_holder.total_placed++
				B3.setHolder(src.holder)
				spreadability -= R

		src.holder.owner.playsound_local(src.holder.owner.loc, "sound/voice/blob/blobspread[rand(1, 6)].ogg", 80, 1)
		if (src.blob_holder.starter_buff)
			if (length(src.blob_holder.blobs) >= 40)
				boutput(src.blob_holder.owner, SPAN_ALERT("You've grown large enough to lose your starter bonus! Good luck!"))
				src.blob_holder.starter_buff = 0
				pointCost = src.pointCostPostStarterBuff
			else
				pointCost = 0
				cooldown = 6

/datum/targetable/blob/promote_nucleus
	name = "Promote to Nucleus"
	icon_state = "blob-nucleus"
	desc = "This ability allows you to plant extra nuclei. You are allowed to use this ability once for every 100 tiles of blob reached."
	pointCost = 0
	cooldown = 120 SECONDS

	cast(var/atom/target)
		if (..())
			return 1
		if (!src.blob_holder.extra_nuclei)
			boutput(usr, "<span class='alert'>You cannot place additional nuclei at this time.</span>")
			return 1

		if (!target)
			target = get_turf(src.holder.owner)

		var/turf/T = get_turf(target)

		var/obj/blob/B = locate() in T
		if (!B)
			boutput(usr, "<span class='alert'>No blob here to convert!</span>")
			return 1
		if (!istype_exact(B, /obj/blob))
			boutput(usr, "<span class='alert'>Cannot promote special blob tiles!</span>")
			return 1
		src.blob_holder.extra_nuclei--
		var/obj/blob/nucleus/N = new(T)
		N.setHolder(src.holder)
		N.setMaterial(B.material)
		B.material = null
		qdel(B)
		src.holder.owner.playsound_local(src.holder.owner.loc, "sound/voice/blob/blobdeploy.ogg", 50, 1)

/datum/targetable/blob/consume
	name = "Consume"
	icon_state = "blob-consume"
	desc = "This ability can be used to remove an existing blob tile for biopoints. Any blob tile you own can be consumed."
	pointCost = 10
	cooldown = 2 SECONDS

	cast(var/atom/target)
		if (..())
			return 1

		if (!target)
			target = get_turf(src.holder.owner)

		var/turf/T = get_turf(target)

		var/obj/blob/B = locate() in T
		if (!B)
			return 1
		if (B.disposed)
			return 1
		if (B.blob_holder != src.holder)
			return 1
		if (istype(B, /obj/blob/nucleus))
			boutput(usr, "<span class='alert'>You cannot consume a nucleus!</span>")
			return 1
		if (!src.blob_holder.tutorial_check("consume", T))
			return 1
		src.holder.owner.playsound_local(src.holder.owner.loc, "sound/voice/blob/blobconsume[rand(1, 2)].ogg", 80, 1)
		B.visible_message("<span class='alert'><b>The blob consumes a piece of itself!</b></span>")
		qdel(B)

/datum/targetable/blob/attack
	name = "Attack"
	icon_state = "blob-attack"
	desc = "This ability commands the blob to attack the selected tile instantly. It must be next to a blob."
	pointCost = 1
	cooldown = 2 SECONDS

	cast(var/atom/target)
		if (..())
			return

		if (!target)
			target = get_turf(src.holder.owner)

		var/turf/T = get_turf(target)

		var/obj/blob/B
		var/turf/checked
		var/terminator = 0
		for (var/dir in alldirs)
			if (terminator)
				break
			checked = get_step(T, dir)
			for (var/obj/blob/X in checked.contents)
				if (X.can_attack_from_this)
					B = X
					terminator = 1
					break

		if (!istype(B))
			boutput(src.holder.owner, "<span class='alert'>That tile is not adjacent to a blob capable of attacking.</span>")
			return

		if (!src.blob_holder.tutorial_check("attack", T))
			return

		src.holder.owner.playsound_local(src.holder.owner.loc, "sound/voice/blob/blob[pick("deploy", "attack")].ogg", 85, 1)
		B.attack(T)
		for (var/obj/blob/C in orange(B, 7))
			if (prob(25))
				if (C.blob_holder == B.blob_holder)
					C.attack_random()


/datum/targetable/blob/repair
	name = "Repair"
	icon_state = "blob-repair"
	desc = "This ability repairs a selected blob tile by 20 health."
	pointCost = 1
	cooldown = 2 SECONDS

	cast(var/atom/target)
		if (..())
			return 1

		if (!target)
			target = get_turf(src.holder.owner)

		var/turf/T = get_turf(target)

		if (!src.blob_holder.tutorial_check("repair", T))
			return 1

		var/obj/blob/B = T.get_blob_on_this_turf()

		if (B)
			if(ON_COOLDOWN(B, "manual_blob_heal", 6 SECONDS))
				boutput(src.holder.owner, "<span class='alert'>That blob tile needs time before it can be repaired again.</span>")
				return 1

			B.heal_damage(20)
			B.update_icon()
			src.holder.owner.playsound_local(src.holder.owner.loc, "sound/voice/blob/blobheal[rand(1, 3)].ogg", 50, 1)
		else
			boutput(src.holder.owner, "<span class='alert'>There is no blob there to repair.</span>")
			return 1

/datum/targetable/blob/absorb
	name = "Absorb"
	icon_state = "blob-absorb"
	desc = "This will attempt to absorb a living person standing on one of your blob tiles. It takes a moment to work. If successful, it will grant four evo points."
	pointCost = 0
	cooldown = 2 SECONDS

	cast(var/atom/target)
		if (..())
			return 1

		if (!target)
			target = get_turf(src.holder.owner)

		var/turf/T = get_turf(target)

		var/obj/blob/B = T.get_blob_on_this_turf()
		if (!istype(B))
			boutput(src.holder.owner, "<span class='alert'>There is no blob there to absorb someone with.</span>")
			return 1
		if (!B.can_absorb)
			boutput(src.holder.owner, "<span class='alert'>[B] cannot absorb beings.</span>")

		if (!src.blob_holder.tutorial_check("absorb", T))
			return 1

		//Things that can be absorbed: humans, mobcritters, monkeys

		var/mob/living/M = null
		for (var/A in T.contents)
			if (check_target_immunity(A))
				continue
			if (ishuman(A))
				if (A:decomp_stage != 4)
					M = A
					break
			if (ismobcritter(A))
				M = A
				break

		if (!M)
			M = locate() in T
			if (ishuman(M))
				boutput(src.holder.owner, "<span class='alert'>There's no flesh left on [M.name] to absorb.</span>")
				return
			boutput(src.holder.owner, "<span class='alert'>There is no-one there that you can absorb.</span>")
			return

		B.visible_message("<span class='alert'><b>The blob starts trying to absorb [M.name]!</b></span>")
		actions.start(new /datum/action/bar/blob_absorb(M, src.holder.owner), B)

//The owner is the blob tile object...
/datum/action/bar/blob_absorb
	bar_icon_state = "bar-blob"
	border_icon_state = "border-blob"
	color_active = "#d73715"
	color_success = "#167935"
	color_failure = "#8d1422"
	duration = 10 SECONDS

	interrupt_flags = 0
	id = "blobabsorb"
	var/mob/living/target
	var/datum/abilityHolder/blob/blob_holder

	New(Target, var/datum/abilityHolder/blob/blob_holder)
		..()
		target = Target
		if (!istype(target))
			interrupt(INTERRUPT_ALWAYS)
			return
		src.blob_holder = blob_holder

	onUpdate()
		..()
		if(!target || !owner || GET_DIST(owner, target) > 0 || !blob_holder)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (ishuman(target) && target:decomp_stage == 4)
			interrupt(INTERRUPT_ALWAYS)
			return
		//damage thing a bit
		target.TakeDamage(burn=rand(2,4), tox=rand(2,4))

	onEnd()
		..()
		//owner type actually matters here. But it should never not be this anyway...
		if(!target || !owner || GET_DIST(owner, target) > 0 || !istype(blob_holder))
			return

		//This whole first bit is all still pretty ugly cause this ability works on both critters and humans. I didn't have it in me to rewrite the whole thing - kyle
		if (ismobcritter(target))
			target.gib()
			target.visible_message("<span class='alert'><b>The blob tries to absorb [target.name], but something goes horribly right!</b></span>")
			if (blob_holder.owner?.mind) //ahem ahem AI blobs exist
				blob_holder.owner.mind.blob_absorb_victims += target
			return

		if (!ishuman(target))
			target.ghostize()
			qdel(target)
			return

		var/mob/living/carbon/human/H = target
		if (H?.decomp_stage == 4)
			H.decomp_stage = 4

		if (blob_holder.owner?.mind) //ahem ahem AI blobs exist
			blob_holder.owner.mind.blob_absorb_victims += H

		if (!isnpc(H))
			blob_holder.evo_points += 4
			playsound(H.loc, "sound/voice/blob/blobsucced.ogg", 100, 1)
		//This is all the animation and stuff making the effect look good crap. Not much to see here.

		H.visible_message("<span class='alert'><b>[H.name] is absorbed by the blob!</b></span>")
		playsound(H.loc, 'sound/impact_sounds/Slimy_Hit_4.ogg', 50, 1)

		H.transforming = 1
		var/current_target_z = H.pixel_z
		var/destination_z = current_target_z - 6
		animate(H, time = 10, alpha = 1, pixel_z = destination_z, easing = LINEAR_EASING)
		SPAWN_DBG(0)
			sleep(1 SECOND)
			H.lying = 1
			H.skeletonize()
			H.transforming = 0
			H.death()
			H.update_face()
			H.update_body()
			H.update_clothing()
			sleep(2 SECONDS)
			animate(H, time = 10, alpha = 255, pixel_z = current_target_z, easing = LINEAR_EASING)

/datum/targetable/blob/reinforce
	name = "Reinforce Blob"
	icon_state = "blob-reinforce"
	desc = "Reinforce the selected blob bit with a material deposit on the same tile. Blob bits with reinforcements may be more durable or more heat resistant, or otherwise may bear special properties depending on the properties of the material. A single blob bit can be repeatedly reinforced to push its properties closer to that of the reinforcing material."
	pointCost = 2
	cooldown = 2 SECONDS

	cast(var/atom/target)
		if (..())
			return 1

		if (!target)
			target = get_turf(src.holder.owner)

		var/turf/T = get_turf(target)

		var/obj/blob/B = locate() in T
		if (!B)
			boutput(src.holder.owner, "<span class='alert'>No blob there to reinforce.</span>")
			return 1

		var/list/deposits = list()

		for (var/obj/material_deposit/M in T)
			deposits += M

		if (!deposits.len)
			boutput(src.holder.owner, "<span class='alert'>No material deposits for reinforcement there.</span>")
			return 1

		var/obj/material_deposit/reinforcing = deposits[1]

		if (deposits.len > 1)
			reinforcing = input("Which material deposit?", "Reinforce blob", null) in deposits

		if (reinforcing.disposed)
			return 1

		B.visible_message("<span class='alert'><b>[B] reinforces using [reinforcing]!</b></span>")


		B.setMaterial(getInterpolatedMaterial(B.material, reinforcing.material, 0.17))
		qdel(reinforcing)

		src.holder.owner.playsound_local(src.holder.owner.loc, "sound/voice/blob/blobreinforce[rand(1, 2)].ogg", 50, 1)

/datum/targetable/blob/reclaimer
	name = "Build Reclaimer"
	icon_state = "blob-reclaimer"
	desc = "This will convert an untapped reagent deposit in the blob into a reclaimer. Reclaimers consume the reagents in the deposit and provide biopoints in exchange. When the deposit depletes, the reclaimer becomes a lipid."
	pointCost = 4
	cooldown = 5 SECONDS

	cast(var/atom/target)
		if (..())
			return 1

		if (!target)
			target = get_turf(src.holder.owner)

		var/turf/T = get_turf(target)

		var/obj/blob/deposit/B = locate() in T
		if (!B)
			boutput(src.holder.owner, "<span class='alert'>Reclaimers must be placed on untapped reagent deposits.</span>")
			return 1
		if (B.type != /obj/blob/deposit)
			boutput(src.holder.owner, "<span class='alert'>Reclaimers must be placed on untapped reagent deposits.</span>")
			return 1

		if (!src.blob_holder.tutorial_check("reclaimer", T))
			return 1

		B.build_reclaimer()

/datum/targetable/blob/replicator
	name = "Build Replicator"
	icon_state = "blob-replicator"
	desc = "This will convert an untapped reagent deposit in the blob into a replicator. Replicators use other reagent deposits to create more of the highest volume reagent in the deposit."
	pointCost = 4
	cooldown = 5 SECONDS

	cast(var/atom/target)
		if (..())
			return 1

		if (!target)
			target = get_turf(src.holder.owner)

		var/turf/T = get_turf(target)

		var/obj/blob/deposit/B = locate() in T
		if (!B)
			boutput(src.holder.owner, "<span class='alert'>Replicators must be placed on untapped reagent deposits.</span>")
			return 1
		if (B.type != /obj/blob/deposit)
			boutput(src.holder.owner, "<span class='alert'>Replicators must be placed on untapped reagent deposits.</span>")
			return 1

		if (!src.blob_holder.tutorial_check("replicator", T))
			return 1

		B.build_replicator()

/datum/targetable/blob/bridge
	name = "Build Bridge"
	icon_state = "blob-bridge"
	desc = "Creates a floor that you can cross through in space. The floor can be destroyed by fire or weldingtools, and does not act as a blob tile."
	pointCost = 5
	cooldown = 5 SECONDS

	cast(var/atom/target)
		if (..())
			return 1

		if (!target)
			target = get_turf(src.holder.owner)

		var/turf/T = get_turf(target)
		if (!istype(T, /turf/space))
			boutput(src.holder.owner, "<span class='alert'>Bridges must be placed on space tiles.</span>")
			return 1

		var/passed = 0
		for (var/dir in cardinal)
			var/turf/checked = get_step(T, dir)
			for (var/obj/blob/B in checked.contents)
				if (B.type != /obj/blob/mutant)
					passed = 1
					break

		if (!passed)
			boutput(src.holder.owner, "<span class='alert'>You require an adjacent blob tile to create a bridge.</span>")
			return 1

		if (!src.blob_holder.tutorial_check("bridge", T))
			return 1

		var/turf/floor/blob/B = T.ReplaceWith(/turf/floor/blob, FALSE, TRUE, FALSE)
		B.setHolder(src.holder)

/datum/targetable/blob/devour_item
	name = "Devour Item"
	icon_state = "blob-digest"
	desc = "This ability will attempt to devour and digest an object on or cardinally adjacent to a blob tile. This process takes 2 seconds, and it can be interrupted by the removal of the blobs in the item's vicinity or the item itself. If the item or any of its contents contained any reagents, a reagent deposit tile will be created on a nearby standard blob tile."
	pointCost = 3
	cooldown = 0

	proc/recursive_reagents(var/obj/O)
		var/list/ret = list()
		if (O.reagents)
			for (var/id in O.reagents.reagent_list)
				ret += O.reagents.reagent_list[id]
		for (var/obj/P in O)
			ret += recursive_reagents(P)
		return ret

	cast(var/atom/target)
		if (..())
			return 1

		if (!target)
			target = get_turf(src.holder.owner)

		var/turf/T = get_turf(target)
		var/list/obj/item/items = list()
		for (var/obj/item/I in T)
			items += I
		if (!items.len)
			boutput(src.holder.owner, "<span class='alert'>Nothing to devour there.</span>")
			return 1

		var/obj/blob/Bleb = locate() in T
		if (!Bleb)
			for (var/D in cardinal)
				var/turf/B = get_step(T, D)
				Bleb = locate() in B
				if (Bleb)
					break

		if (!Bleb)
			boutput(src.holder.owner, "<span class='alert'>There is no blob nearby which can devour items.</span>")
			return 1

		if (!src.blob_holder.tutorial_check("devour", T))
			return 1

		var/obj/item/I = items[1]
		if (items.len > 1)
			I = input("Which item?", "Item", null) as null|anything in items
		if (!I)
			return 1

		if (I.loc != T)
			return 1

		if (!Bleb) //Wire: Duplicated from above because there's an input() in-between (Fixes runtime: Cannot execute null.visible message())
			boutput(src.holder.owner, "<span class='alert'>There is no blob nearby which can devour items.</span>")
			return 1

		Bleb.visible_message("<span class='alert'><b>The blobs starts devouring [I]!</b></span>")
		SPAWN_DBG(2 SECONDS)
			if (I && isturf(I.loc))
				Bleb = locate() in I.loc
				if (!Bleb)
					for (var/D in cardinal)
						var/turf/B = get_step(I.loc, D)
						Bleb = locate() in B
						if (Bleb)
							break

				if (Bleb)
					Bleb.visible_message("<span class='alert'><b>The blob devours [I]!</b></span>")

					if (I.material)
						var/count = 2
						if (istype(I, /obj/item/raw_material) || istype(I, /obj/item/material_piece))
							count = 3
						if (I.amount >= 10)
							count *= round(I.amount / 10) + 1
						for (var/i = 1, i <= count, i++)
							new /obj/material_deposit(Bleb.loc, I.material, src.holder)

					var/list/aggregated = recursive_reagents(I)
					qdel(I)
					if (aggregated.len)
						if (Bleb.type != /obj/blob)
							Bleb = null
							for (var/obj/blob/C in range(5, Bleb))
								if (C.blob_holder == src.holder && istype_exact(C, /obj/blob))
									Bleb = C
									break
						if (Bleb)
							var/obj/blob/deposit/B2 = new /obj/blob/deposit(Bleb.loc)
							B2.setHolder(src.holder)
							qdel(Bleb)
							B2.reagents = new /datum/reagents(0)
							B2.reagents.my_atom = B2
							for (var/datum/reagent/R in aggregated)
								if (B2)
									B2.reagents.maximum_volume += R.volume
									B2.reagents.add_reagent(R.id, R.volume)
							if (B2)
								B2.update_reagent_overlay()
								if (!B2.reagents.total_volume)
									var/obj/blob/B3 = new /obj/blob(B2.loc)
									B3.setHolder(src.holder)
									qdel(B2)

// CONSTRUCTION ABILITIES

/datum/targetable/blob/build
	var/gen_rate_invest = 0
	var/build_path = /obj/blob
	cooldown = 10 SECONDS
	var/buildname = "build"

	extra_help(user)
		boutput(user, "<span class='notice'>This is a building ability - you need to use it on a regular blob tile.</span>")
		if (src.gen_rate_invest > 0)
			boutput(user, "<span class='notice'>This ability requires you to invest [src.gen_rate_invest] of your BP generation rate in it. It will be returned when the cell is destroyed.</span>")

	cast(var/atom/target)
		if (..())
			return 1

		if (!target)
			target = get_turf(src.holder.owner)

		var/turf/T = get_turf(target)

		var/obj/blob/B = T.get_blob_on_this_turf()

		if (!B)
			boutput(src.holder.owner, "<span class='alert'>There is no blob there to convert.</span>")
			return 1

		if (gen_rate_invest > 0)
			if (src.blob_holder.regenRate < gen_rate_invest + 1)
				boutput(src.holder.owner, "<span class='alert'>You do not have a high enough generation rate to use that ability.</span>")
				boutput(src.holder.owner, "<span class='alert'>Keep in mind that you cannot reduce your generation rate to zero or below.</span>")
				return 1

		if (B.type != /obj/blob)
			boutput(src.holder.owner, "<span class='alert'>You cannot convert special blob cells.</span>")
			return 1

		if (!src.blob_holder.tutorial_check(buildname, T))
			return 1

		var/obj/blob/L = new build_path(T)
		L.setHolder(src.holder)
		L.setMaterial(B.material)
		B.material = null
		qdel(B)
		if (gen_rate_invest)
			src.blob_holder.gen_rate_used++
		src.holder.owner.playsound_local(src.holder.owner.loc, "sound/voice/blob/blobplace[rand(1, 6)].ogg", 75, 1)

/datum/targetable/blob/build/lipid
	name = "Build Lipid Cell"
	icon_state = "blob-lipid"
	desc = "This will convert a blob tile into a Lipid. Lipids act as a storage for 4 biopoints. When you try to spend more than your available biopoints, you will use up lipids to substitute for the missing points. If a lipid is destroyed, the stored points are lost."
	pointCost = 5
	build_path = /obj/blob/lipid
	buildname = "lipid"

/datum/targetable/blob/build/ribosome
	name = "Build Ribosome Cell"
	icon_state = "blob-ribosome"
	desc = "This will convert a blob tile into a Ribosome. Ribosomes increase your generation of biopoints, allowing you to do more things."
	pointCost = 15
	build_path = /obj/blob/ribosome
	buildname = "ribosome"

/datum/targetable/blob/build/mitochondria
	name = "Build Mitochondria Cell"
	icon_state = "blob-mitochondria"
	desc = "This will convert a blob tile into a Mitochondrion. Mitochondria heal nearby blob cells."
	pointCost = 5
	build_path = /obj/blob/mitochondria
	buildname = "mitochondria"

/datum/targetable/blob/build/plasmaphyll
	name = "Build Plasmaphyll Cell"
	icon_state = "blob-plasmaphyll"
	desc = "This will convert a blob tile into a Plasmaphyll. Plasmaphylls protect nearby blob pieces from sustained fires by absorbing plasma out of the air and converting it into biopoints."
	pointCost = 15
	gen_rate_invest = 1
	build_path = /obj/blob/plasmaphyll
	buildname = "plasmaphyll"

/datum/targetable/blob/build/ectothermid
	name = "Build Ectothermid Cell"
	icon_state = "blob-ectothermid"
	desc = "This will convert a blob tile into a Ectothermid. Ectothermids provice heat protection in an area at the cost of for biopoints."
	pointCost = 15
	gen_rate_invest = 1
	build_path = /obj/blob/ectothermid
	buildname = "ectothermid"

/datum/targetable/blob/build/reflective
	name = "Build Reflective Membrane Cell"
	icon_state = "blob-reflective"
	desc = "This will convert a blob tile into a reflective membrane. Reflective membranes are reflect energy projectiles back in the direction they were shot from."
	pointCost = 8
	build_path = /obj/blob/reflective
	buildname = "reflective"

/datum/targetable/blob/build/launcher
	name = "Build Slime Launcher"
	icon_state = "blob-cannon"
	desc = "This will convert a blob tile into a slime launcher. Slime launchers will fire weak projectiles at nearby humans and cyborgs at the cost of 2 biopoints. Click-drag any reagent deposit onto a slime launcher to load the reagents into the launcher. When loaded with reagents, the slime bullets are also infused with the reagents and while the reservoir lasts, firing the launcher does not cost biopoints."
	pointCost = 10
	build_path = /obj/blob/launcher
	buildname = "launcher"

/datum/targetable/blob/build/wall
	name = "Build Thick Membrane Cell"
	icon_state = "blob-wall"
	desc = "This will convert a blob tile into a wall. Wall cells are harder to destroy."
	pointCost = 5
	build_path = /obj/blob/wall
	buildname = "wall"

/datum/targetable/blob/build/firewall
	name = "Build Fire-resistant Membrane Cell"
	icon_state = "blob-firewall"
	desc = "This will convert a blob tile into a fire-resistant wall. Fire resistant walls are very resistant to fire damage."
	pointCost = 5
	build_path = /obj/blob/firewall
	buildname = "firewall"

#ifdef Z3_IS_A_STATION_LEVEL
/datum/targetable/blob/blob_level_transfer //Spread up/down ladders & elevators, not the thing that moves the overmind between levels
	name = "Build Level Transfer"
	icon_state = "blob-leveltransfer"
	desc = "This will convert a blob tile into a vertical lever transfer, allowing you to spread across station levels. Only placeable in elevator shafts and on ladders."

	pointCost = 4 //2x that of spread
	cooldown = 4 SECONDS //Idem, though this one doesn't have scaling maths

	cast(var/atom/target)
		if (..())
			return 1

		if (!target)
			target = get_turf(src.holder.owner)

		var/turf/turf_z1 = get_turf(target)

		var/turf/turf_z3
		if (!turf_z1)
			turf_z1 = get_turf(src.holder.owner)
		turf_z1 = locate(turf_z1.x, turf_z1.y, 1) //I don't care if this ends up being unnecessary
		turf_z3 = locate(turf_z1.x, turf_z1.y, 3)

		//Do we have a blob in at least one of the two turfs
		var/obj/blob/B_z1 = locate() in turf_z1
		var/obj/blob/B_z3 = locate() in turf_z3

		if (!(B_z1) && !(B_z3))
			boutput(src.holder.owner, "<span class='alert'>You must spread here first on either level.</span>")
			return 1
		if ((B_z1 && B_z1.type != /obj/blob) || (B_z3 && B_z3.type != /obj/blob))
			boutput(src.holder.owner, "<span class='alert'>You can't convert special tiles.</span>")
			return 1

		//This bit is kinda ugly, sorry
		if (!istype(get_area(turf_z1), /area/transit_vehicle/elevator)) //Just gonna assume that if one isn't on an elevator the other isn't either
			var/obj/ladder/turf_ladder = locate() in turf_z1
			if (turf_ladder)
				turf_ladder.blocked = TRUE //I'd shove this on New() in the blobs but we have to check for these ladders anyway, might as well

				turf_ladder = locate() in turf_z3 //Do the same on Z3
				if (turf_ladder)
					turf_ladder.blocked = TRUE
			else //I'm fine with there just being hald a ladder pair, no doubt some asshat is going to find ways to delete ladders to fight blobs
				turf_ladder = locate() in turf_z3
				if (turf_ladder)
					turf_ladder.blocked = TRUE
				else //no ladder or elevator, aborte
					boutput(src.holder.owner, "<span class='alert'>This must be used at an elevator shaft or ladder.</span>")
					return 1

		var/obj/blob/linked/up
		var/obj/blob/linked/down
		//Remove & replace
		up = new /obj/blob/linked/upper(turf_z1)
		if (B_z1)
			up.setMaterial(B_z1.material)
			qdel(B_z1)

		down = new /obj/blob/linked/lower(turf_z3)
		if (B_z3)
			down.setMaterial(B_z3.material)
			qdel(B_z3)

		up.linked_blob = down
		down.linked_blob = up
		up.setHolder(src.holder)
		down.setHolder(src.holder)
		src.holder.owner.playsound_local(src.holder.owner.loc, "sound/voice/blob/blobspread[rand(1, 6)].ogg", 80, 1)
#endif

/datum/targetable/blob/tutorial
	name = "Interactive Tutorial"
	desc = "Check out the interactive blob tutorial to get started with blobs."
	icon_state = "blob-help0"
	targeted = 0

	cast()
		if (..())
			return
		if (src.blob_holder.tutorial)
			boutput(src.holder, "<span class='alert'>You're already in the tutorial!</span>")
			return
		src.blob_holder.start_tutorial()

/datum/targetable/blob/tutorial_exit
	name = "Exit Tutorial"
	desc = "Exit the blob tutorial and re-enter the game."
	icon_state = "blob-exit"
	targeted = 0
	special_screen_loc = "SOUTH,EAST-1"

	cast()
		if (..())
			return
		if (!src.blob_holder.tutorial)
			boutput(src.holder, "<span class='alert'>You're not in the tutorial!</span>")
			return
		src.blob_holder.tutorial.Finish()
		src.blob_holder.tutorial = null


// UPGRADES AKA EVOLUTIONS

/datum/targetable/blob/toggle_evolution_bar
	name = "Toggle Upgrade Bar"
	desc = "Expand or contract the upgrades bar."
	icon_state = "blob-viewupgrades"
	targeted = 0
	special_screen_loc = "SOUTH,WEST"
	helpable = 0

	cast()
		if (..())
			return
		if (src.blob_holder.viewing_upgrades)
			src.blob_holder.viewing_upgrades = 0
		else
			src.blob_holder.viewing_upgrades = 1
		src.holder.updateButtons()

/datum/targetable/blob/evolution
	targeted = FALSE
	special_screen_loc = "SOUTH,WEST"
	var/evo_point_cost = 0
	var/repeatable = 0
	var/scaling_cost_mult = 1
	var/scaling_cost_add = 0
	var/evolution_flags = 0
	var/id = "upgrade"

	cast()
		if(src.check_requirements())
			src.take_upgrade()
			src.deduct_evo_points()

	proc/check_requirements()
		if (src.blob_holder.evo_points < evo_point_cost)
			return 0
		return 1

	proc/deduct_evo_points()
		if (evo_point_cost == 0)
			return
		src.blob_holder.evo_points = max(0,round(src.blob_holder.evo_points - evo_point_cost))
		src.evo_point_cost = round(src.evo_point_cost * src.scaling_cost_mult)
		src.evo_point_cost += scaling_cost_add

	proc/take_upgrade()
		if (!src.blob_holder.tutorial_check(id, null))
			return 1
		src.blob_holder.evolution_flags |= src.evolution_flags
		if (repeatable > 0)
			repeatable--
		if (repeatable == 0)
			src.holder.removeAbilityInstance(src)
		if (prob(80))
			src.holder.owner.playsound_local(src.holder.owner.loc, "sound/voice/blob/blobup1.ogg", 50, 1)
		else if (prob(50))
			src.holder.owner.playsound_local(src.holder.owner.loc, "sound/voice/blob/blobup2.ogg", 50, 1)
		else
			src.holder.owner.playsound_local(src.holder.owner.loc, "sound/voice/blob/blobup3.ogg", 50, 1)

		src.holder.updateButtons()

/datum/targetable/blob/evolution/extra_genrate
	name = "Passive: Increase Generation Rate"
	icon_state = "blob-genrate"
	desc = "Increases your BP generation rate by 2. Can be repeated."
	evo_point_cost = 1
	scaling_cost_add = 1
	repeatable = -1
	id = "upgrade-genrate"

	take_upgrade()
		if (..())
			return 1
		src.blob_holder.gen_rate_bonus += 2

/datum/targetable/blob/evolution/quick_spread
	name = "Passive: Quicker Spread"
	icon_state = "blob-quickspread"
	desc = "Reduces the cooldown of your Spread ability by 0.5 seconds. Can be repeated. The cooldown of Spread cannot go below 0.6 seconds."
	evo_point_cost = 3
	scaling_cost_add = 3
	repeatable = -1
	id = "upgrade-spread"

	take_upgrade()
		if (..())
			return 1
		src.blob_holder.spread_upgrade++

/datum/targetable/blob/evolution/spread
	name = "Passive: Spread Upgrade"
	icon_state = "blob-spread"
	desc = "When spreading, adds a cumulative 20% chance to spread off another, random tile on your screen. Every time your chance hits a multiple of 100%, the spread for that amount of tiles is guaranteed and a new chance is added for an extra tile. For example, at 120%, you have a 100% chance to spread twice; with a 20% chance to spread three times instead."
	evo_point_cost = 1
	scaling_cost_add = 1
	repeatable = -1
	id = "upgrade-multispread"

	take_upgrade()
		if (..())
			return 1
		src.blob_holder.multi_spread += 20

/datum/targetable/blob/evolution/attack
	name = "Passive: Attack Upgrade"
	icon_state = "blob-attack"
	desc = "Increases your attack damage and the chance of mob knockdown. Level 3+ of this upgrade will allow you to punch down girders. Can be repeated."
	evo_point_cost = 1
	scaling_cost_add = 1
	repeatable = -1
	id = "upgrade-attack"

	take_upgrade()
		if (..())
			return 1
		src.blob_holder.attack_power += 0.34

/datum/targetable/blob/evolution/fire_resist
	name = "Passive: Fire Resistance"
	icon_state = "blob-fireresist"
	desc = "Makes your blob become more resistant to fire and heat based attacks."
	evo_point_cost = 2
	id = "upgrade-fireres"
	evolution_flags = BLOB_EVOLUTION_FIRERES

/datum/targetable/blob/evolution/poison_resist
	name = "Passive: Poison Resistance"
	icon_state = "blob-poisonresist"
	desc = "Makes your blob become more resistant to chemical attacks."
	evo_point_cost = 2
	id = "upgrade-poisonres"
	evolution_flags = BLOB_EVOLUTION_POISONRES

/datum/targetable/blob/evolution/devour_item
	name = "Ability: Devour Item"
	icon_state = "blob-digest"
	desc = "Unlocks the Devour Item ability, which can be used to near-instantly break down any item adjacent to any blob tile. In addition, a reagent deposit is created in the blob if the item contained any reagents. Reagent deposits can be used with various blob elements. Material bearing objects will break down into material deposits, which can be used to reinforce your blob."
	evo_point_cost = 1
	id = "upgrade-digest"
	evolution_flags = BLOB_EVOLUTION_DEVOURITEM

	take_upgrade()
		if (..())
			return 1
		src.holder.addAbility(/datum/targetable/blob/devour_item)
		src.holder.addAbility(/datum/targetable/blob/evolution/reclaimer)
		src.holder.addAbility(/datum/targetable/blob/evolution/replicator)
		src.holder.addAbility(/datum/targetable/blob/evolution/reinforce)

// initially disabled
/datum/targetable/blob/evolution/reinforce
	name = "Ability: Reinforce"
	icon_state = "blob-reinforce"
	desc = "Unlocks the Reinforce ability, which can be used to strengthen a single blob bit. Blob bits with reinforcements may be more durable or more heat resistant, or otherwise may bear special properties depending on the properties of the material. A single blob bit can be repeatedly reinforced to push its properties closer to that of the reinforcing material."
	evo_point_cost = 1
	id = "upgrade-reinforce"
	evolution_flags = BLOB_EVOLUTION_REINFORCE

	take_upgrade()
		if (..())
			return 1
		src.holder.addAbility(/datum/targetable/blob/reinforce)
		src.holder.addAbility(/datum/targetable/blob/evolution/reinforce_spread)

// initially disabled
/datum/targetable/blob/evolution/reinforce_spread
	name = "Passive: Reinforced Spread"
	icon_state = "blob-global-reinforce"
	desc = "Reinforces the blob with material permanently. All existing blob tiles are reinforced with the average of the used materials, and all future blob bits will be created with the infusion. This upgrade requires 60 material deposits to be on your current tile."
	evo_point_cost = 1
	scaling_cost_add = 2
	repeatable = -1
	id = "upgrade-reinforce_spread"
	var/required_deposits = 30
	var/taking = 0
	evolution_flags = BLOB_EVOLUTION_REINFORCEALL

	take_upgrade()
		if (!src.blob_holder.tutorial_check())
			return 1
		var/count = 0
		for (var/obj/material_deposit/M in view(src.holder.owner))
			if (M.blob_holder == src.holder && M.material)
				count++
		if (count < required_deposits)
			boutput(src.holder.owner, "<span class='alert'><b>You need more deposits on your screen! (Required: [required_deposits], have: [count])</b></span>")
			return 1
		if (taking)
			boutput(src.holder.owner, "<span class='alert'>Cannot take this upgrade currently! Please wait.</span>")
			return 1
		taking = 1
		var/list/mats = list()
		var/list/weights = list()
		var/list/deposits = list()
		var/total = 0
		var/max_id = null
		for (var/obj/material_deposit/M in view(src.holder.owner))
			if (total >= required_deposits)
				break
			var/datum/material/Mat = M.material
			if (!Mat)
				continue
			deposits += M
			var/id = Mat.mat_id
			if (!(id in mats))
				mats[id] = Mat
				weights[id] = 1
			else
				weights[id] = weights[id] + 1
			total = 0
			for (var/mid in weights)
				if (weights[mid] > total)
					total = weights[mid]
					max_id = mid
		if (!total)
			taking = 0
			return 1
		if (total < required_deposits)
			taking = 0
			boutput(usr, "<span class='alert'><b>You need more deposits on your screen! (Required: [required_deposits], have (of highest material '[max_id]'): [total])</b></span>")
			return 1
		if (!mats.len)
			taking = 0
			return 1
		var/datum/material/to_merge = mats[max_id]
		src.blob_holder.my_material = getInterpolatedMaterial(src.blob_holder.my_material, to_merge, 0.17)
		for (var/obj/O in deposits)
			qdel(O)
		boutput(usr, "<span class='notice'>Applying upgrade to the blob...</span>")
		SPAWN_DBG(0)
			var/wg = 0
			for (var/obj/blob/O in src.blob_holder.blobs)
				O.setMaterial(src.blob_holder.my_material)
				wg++
				if (wg >= 20)
					sleep(0.1 SECONDS)
					wg = 0
			boutput(usr, "<span class='notice'>Finished applying material upgrade!</span>")
			taking = 0
		if (!(BLOB_EVOLUTION_REINFORCEALL & src.blob_holder.evolution_flags))
			src.blob_holder.evolution_flags |= BLOB_EVOLUTION_REINFORCEALL
		return 0

// initially disabled
/datum/targetable/blob/evolution/reclaimer
	name = "Structure: Reclaimer"
	icon_state = "blob-reclaimer"
	desc = "Unlocks the Reclaimer blob bit, which can be placed on reagent deposits. The reclaimer produces biopoints over time using reagents. Once the deposit depletes, the blob piece is transformed into a lipid."
	evo_point_cost = 1
	id = "upgrade-reclaimer"

	take_upgrade()
		if (..())
			return 1
		src.holder.addAbility(/datum/targetable/blob/reclaimer)

// initially disabled
/datum/targetable/blob/evolution/replicator
	name = "Structure: Replicator"
	icon_state = "blob-replicator"
	desc = "Unlocks the Replicator blob bit, which can be placed on reagent deposits. The replicator replicates the highest volume reagent in the deposit using reagents from other deposits, at the cost of biopoints."
	evo_point_cost = 2
	id = "upgrade-replicator"

	take_upgrade()
		if (..())
			return 1
		src.holder.addAbility(/datum/targetable/blob/replicator)

/datum/targetable/blob/evolution/bridge
	name = "Structure: Bridge"
	icon_state = "blob-bridge"
	desc = "Unlocks the Bridge blob bit, which can be placed on space tiles. Bridges are floor tiles, you still need to spread onto them, and cannot spread from them."
	evo_point_cost = 1
	id = "upgrade-bridge"

	take_upgrade()
		if (..())
			return 1
		src.holder.addAbility(/datum/targetable/blob/bridge)

/datum/targetable/blob/evolution/launcher
	name = "Structure: Slime Launcher"
	icon_state = "blob-cannon"
	desc = "Unlocks the Slime Launcher blob bit, which fires at nearby mobs at the cost of biopoints. Slime inflicts a short stun and minimal damage."
	id = "upgrade-launcher"
	evo_point_cost = 1

	take_upgrade()
		if (..())
			return 1
		src.holder.addAbility(/datum/targetable/blob/build/launcher)

/datum/targetable/blob/evolution/plasmaphyll
	name = "Structural: Plasmaphyll"
	icon_state = "blob-plasmaphyll"
	desc = "Unlocks the plasmaphyll blob bit, which passively protects an area from plasma by converting it to biopoints."
	evo_point_cost = 1
	id = "upgrade-plasmaphyll"

	take_upgrade()
		if (..())
			return 1
		src.holder.addAbility(/datum/targetable/blob/build/plasmaphyll)

/datum/targetable/blob/evolution/ectothermid
	name = "Structural: Ectothermid"
	icon_state = "blob-ectothermid"
	desc = "Unlocks the ectothermid blob bit, which passively protects an area from temperature. This protection consumes biopoints."
	evo_point_cost = 2
	id = "upgrade-ectothermid"

	take_upgrade()
		if (..())
			return 1
		src.holder.addAbility(/datum/targetable/blob/build/ectothermid)

/datum/targetable/blob/evolution/reflective
	name = "Structural: Reflective Membrane"
	icon_state = "blob-reflective"
	desc = "Unlocks the reflective membrane, which is immune to energy projectiles."
	evo_point_cost = 1
	id = "upgrade-reflective"

	take_upgrade()
		if (..())
			return 1
		src.holder.addAbility(/datum/targetable/blob/build/reflective)
