// -----------------
// Simple bite skill
// -----------------
/datum/targetable/critter/blood_bite
	name = "Blood Bite"
	desc = "Bite someone and take a tiny amount of blood."
	cooldown = 10 SECONDS
	targeted = 1
	target_anything = 1
	icon_state = "bloodbite"
	ai_range = 1
	attack_mobs = TRUE

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, __red("Nothing to bite there."))
				return 1
		if (target == holder.owner)
			return 1
		if (get_dist(holder.owner, target) > 1)
			boutput(holder.owner, __red("That is too far away to bite."))
			return 1
		playsound(target,"sound/items/drink.ogg", rand(10,50), 1, pitch = 1.4)
		var/mob/M = target

		holder.owner.visible_message(__red("<b>[holder.owner] sucks some blood from [M]!</b>"), __red("You suck some blood from [M]!"))
		if (isliving(M))
			if (M.reagents)
				holder.owner.reagents.trans_to(M,1) //swap a bit ;)
				M.reagents.trans_to(holder.owner,5)

		holder.owner.TakeDamage("All", -5, -5)
		return 0
