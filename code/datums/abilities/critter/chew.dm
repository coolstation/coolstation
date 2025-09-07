/datum/targetable/critter/chew
	name = "Crunch"
	desc = "Bite down on a grabbed mob, causing bleeding."
	cooldown = 50
	targeted = 0
	ai_range = 0
	var/brute_damage = 10
	attack_mobs = TRUE

	cast()
		if (..())
			return 1
		var/obj/item/grab/G = holder.owner.equipped()
		if(!G || !istype(G) || !G.affecting)
			return 1
		var/mob/living/target = G.affecting
		if (target == holder.owner)
			return 1
		if (GET_DIST(holder.owner, target) > 1)
			boutput(holder.owner, __red("Get a better bite on that before trying to chew on it!"))
			return 1
		playsound(target, "sound/impact_sounds/Flesh_Tear_[rand(1,3)].ogg", 50, 1, -13)
		target.TakeDamageAccountArmor("All", src.brute_damage, 0, 0, DAMAGE_CRUSH)
		holder.owner.visible_message("<span class='combat'><b>[holder.owner] bites [target]!</b></span>", "<span class='combat'>You bite [target]!</span>")
		return 0
