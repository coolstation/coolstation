//Abilities that are shared by most if not all ethereal things
//(observers, wraiths, AEyes would but they don't use a damn abilityholder, preferably blobs at some point but they got their own ability implementation)
//I'm as disappointed as you are

//being under ghost_observer is probably fine right?

#ifdef Z3_IS_A_STATION_LEVEL
/datum/targetable/ghost_observer/upper_transfer
	name = "Go To Upper Level"
	desc = "See what's happening upstairs"
	icon_state = "upper_transfer"
	targeted = 0
	cooldown = 0

	cast(atom/target)
		if (ismob(holder?.owner)) //The things that use these buttons are all over the mob object tree we can't get more specific
			if (holder.owner.z == Z_LEVEL_STATION)
				return
			var/turf/destination = locate(holder.owner.x, holder.owner.y, Z_LEVEL_STATION)
			holder.owner.set_loc(destination)

/datum/targetable/ghost_observer/lower_transfer
	name = "Go To Lower Level"
	desc = "See what's happening downstairs"
	icon_state = "lower_transfer"
	targeted = 0
	cooldown = 0

	cast(atom/target)
		if (ismob(holder?.owner))
			if (holder.owner.z == Z_LEVEL_DEBRIS)
				return
			var/turf/destination = locate(holder.owner.x, holder.owner.y, Z_LEVEL_DEBRIS)
			holder.owner.set_loc(destination)
#endif
