
/datum/lifeprocess/canmove
	process()
		//check_if_seated()
		if (owner.stool_flags)
			//check if not on same loc
			if (owner.stool_used.loc != owner.loc)
				owner.stool_used.reset_stool(owner)
				return ..()
			owner.lying = istype(owner.stool_used, /obj/stool/bed) || istype(owner.buckled, /obj/machinery/conveyor)
			if (owner.lying)
				owner.drop_item()
			owner.set_density(initial(owner.density))
		else
			if (!owner.lying)
				owner.set_density(initial(owner.density))
			else
				owner.set_density(0)

		//update_canmove

		if (HAS_MOB_PROPERTY(owner, PROP_CANTMOVE))
			owner.canmove = 0
			return ..()

		//check so we can still rotate the chairs on their slower delay even if we are anchored
		if (owner.stool_used && owner.stool_used.anchored) //chair stationary?
			if (owner.stool_used.swivels)
				owner.canmove = 1
				return ..()
			if (owner.stool_used.rotatable)
				owner.canmove = 1
				return ..()
			else
				owner.canmove = 0
				return ..()

		if (owner.throwing & (THROW_CHAIRFLIP | THROW_GUNIMPACT | THROW_SLIP))
			owner.canmove = 0
			return ..()

		owner.canmove = 1

		..()
