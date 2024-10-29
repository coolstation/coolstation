/datum/targetable/critter/fire_sprint
	name = "Fire Form"
	desc = "For a limited time : Hold Sprint key to maintain Fire Form. You will leave a trail of flames while in use."
	icon_state = "fire_e_sprint"
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 200
	pointCost = 0
	restricted_area_check = 1
	var/duration = 30

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/carbon/human/M = holder.owner
		//var/datum/abilityHolder/vampire/H = holder

		if (!M)
			return 1


		M.special_sprint |= SPRINT_FIRE
		SPAWN_DBG(duration)
			M.special_sprint &= ~SPRINT_FIRE
			boutput(M, __blue("Fire Form depleted."))


		boutput(M, __blue("Fire Form activated. (Hold Sprint to fly around)"))

		return 0
