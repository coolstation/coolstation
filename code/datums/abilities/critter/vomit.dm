// -----------------
// vomit, copy paste from bigpuke sorta
// -----------------
/datum/targetable/critter/vomit
	name = "Vomit"
	desc = "BLARF"
	icon_state = "puke"
	cooldown = 30 SECONDS
	targeted = 1
	target_anything = 1
	ai_range = 3
	attack_mobs = TRUE
	var/vom_range = 1

	cast(atom/target)
		if (..())
			return 1

		var/turf/T = get_turf(target)
		var/list/affected_turfs = getline(holder.owner, T)

		holder.owner.visible_message("<span class='alert'><b>[holder.owner] pukes!</b></span>")
		logTheThing("combat", holder.owner, target, "power-pukes [log_reagents(holder.owner)] at [log_loc(holder.owner)].")
		playsound(holder.owner.loc, "sound/misc/meat_plop.ogg", 50, 0)
		var/datum/reagents/vomit_reagents = new /datum/reagents(160)
		if(isliving(holder.owner))
			var/mob/living/L = holder.owner
			if(L.organHolder && L.organHolder.stomach)
				L.organHolder.stomach.reagents.trans_to_direct(vomit_reagents, 80)
		vomit_reagents.add_reagent("vomit",max(15,vomit_reagents.total_volume)) // add up to 80, at least 15 vomit, trying for half and half
		var/turf/currentturf
		var/turf/previousturf
		var/amt_per_turf = vomit_reagents.total_volume / clamp((length(affected_turfs) - 1),1,src.vom_range) // account for skipping the first turf
		var/amt_removed = 0
		for(var/turf/F in affected_turfs)
			previousturf = currentturf
			currentturf = F
			if(currentturf.density)
				if(previousturf)
					vomit_reagents.reaction(previousturf, TOUCH, vomit_reagents.total_volume - amt_removed)
				break
			if(previousturf && LinkBlocked(previousturf, currentturf))
				vomit_reagents.reaction(previousturf, TOUCH, vomit_reagents.total_volume - amt_removed)
				break
			if(GET_DIST(holder.owner,F) > src.vom_range)
				break
			if ((F == get_turf(holder.owner)) || istype(currentturf, /turf/space))
				continue
			for(var/mob/living/L in F.contents)
				vomit_reagents.reaction(L,TOUCH, amt_per_turf, FALSE)
			for(var/obj/O in F.contents)
				vomit_reagents.reaction(O,TOUCH, amt_per_turf, FALSE)
			vomit_reagents.reaction(F, TOUCH, amt_per_turf, TRUE)
			amt_removed += amt_per_turf
		qdel(vomit_reagents)

		return 0





