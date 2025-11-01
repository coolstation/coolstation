//Abilities that are shared by most if not all ethereal things
//(observers, wraiths, blob overminds, AEyes would but they don't use a damn abilityholder)
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

/datum/targetable/ghost_observer/respawn
	name = "Respawn"
	desc = "Give this living thing another shot?"
	icon_state = "respawn"
	targeted = 0
	cooldown = 0

	cast(atom/target)
		if(ismob(holder?.owner))
			holder.owner.abandon_mob()


/datum/targetable/ghost_observer/goto_escape
	name = "Go To Escape"
	desc = "See what's happening at the exit?"
	icon_state = "escape"
	targeted = 0
	cooldown = 0

	cast(atom/target)
		var/turf/destination
		if (ismob(holder?.owner) && map_settings)
			if(!emergency_shuttle)
				destination = locate(map_settings.escape_station)
			else
				switch(emergency_shuttle.location)
					if(SHUTTLE_LOC_CENTCOM)
						destination = locate(map_settings.escape_station)
					if(SHUTTLE_LOC_STATION)
						destination = locate(map_settings.escape_station)
					if(SHUTTLE_LOC_TRANSIT)
						destination = locate(map_settings.escape_transit)
					if(SHUTTLE_LOC_RETURNED)
						if(channel_open)
							destination = locate(map_settings.escape_centcom)
						else
							destination = locate(map_settings.escape_outpost)

		if(destination)
			holder.owner.set_loc(destination)
		else(boutput(holder.owner, "someone fucked up lmao call a coder"))

