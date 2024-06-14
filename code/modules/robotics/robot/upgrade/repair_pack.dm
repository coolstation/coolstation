//Heals 100 brute and 100 burn on every part of a borg. That's 200 at most if you manage to split the damage evenly (rare in practice)
//For light parts this is functionally a full heal. Regular chests and heads are around 200 total health and reinforcing heads gives significantly more.
//Only heavy arms have over 100 health, while legs cap out at 100

/obj/item/roboupgrade/repairpack
	name = "cyborg repair pack"
	desc = "A single-use construction unit that can repair up to 50% of a cyborg's structure."
	icon_state = "up-reppack"
	active = 1
	charges = 1

/obj/item/roboupgrade/repairpack/upgrade_activate(var/mob/living/silicon/robot/user as mob)
	if (!user)
		return
	for (var/obj/item/parts/robot_parts/RP in user.contents)
		RP.ropart_mend_damage(100, 100)
	boutput(user, "<span class='notice'>All components repaired!</span>")
