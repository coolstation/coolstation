/*
Overview:
	The air_master global variable is the workhorse for the system.

Why are you archiving data before modifying it?
	The general concept with archiving data and having each tile keep track of when they were last updated is to keep everything symmetric
		and totally independent of the order they are read in an update cycle.
	This prevents abnormalities like air/fire spreading rapidly in one direction and super slowly in the other.

Why not just archive everything and then calculate?
	Efficiency. While a for-loop that goes through all tils and groups to archive their information before doing any calculations seems simple, it is
		slightly less efficient than the archive-before-modify/read method.

Why is there a cycle check for calculating data as well?
	This ensures that every connection between group-tile, tile-tile, and group-group is only evaluated once per loop.

//

Important variables:
	air_master.groups_to_rebuild (list)
		A list of air groups that have had their geometry occluded and thus may need to be split in half.
		A set of adjacent groups put in here will join together if validly connected.
		This is done before air system calculations for a cycle.
	air_master.tiles_to_update (list)
		Turfs that are in this list have their border data updated before the next air calculations for a cycle.
		Place turfs in this list rather than call the proc directly to prevent race conditions

	turf.archive() and datum/air_group.archive()
		This stores all data for.
		If you modify, make sure to update the archived_cycle to prevent race conditions and maintain symmetry

	atom/gas_cross(turf/target)
		returns 1 for allow gas crossing and 0 for deny gas crossing
		Turfs automatically call this for all objects/mobs in its turf.
		This is called both as source.gas_cross(target)
			and  target.gas_cross(source)

Important Procedures
	air_master.process()
		This first processes the air_master update/rebuild lists then processes all groups and tiles for air calculations


*/

/atom/proc/CanPass(atom/movable/mover)
	return (!density)

/atom/proc/gas_cross(turf/target)
	return !src.gas_impermeable

/turf/CanPass(atom/movable/mover, turf/target)
	. = ..()
	if(!target) return 0

/turf/gas_cross(turf/target)
	if(target?.gas_impermeable || src.gas_impermeable)
		return 0
	else // Now, doing more detailed checks for air movement and air group formation
		if (src.turf_persistent.checkingcanpass > 0)
			for(var/atom/A as anything in src)
				if(!A.gas_cross(target))
					return 0

		if (target?.turf_persistent.checkingcanpass > 0)
			for(var/atom/A as anything in target)
				if(!A.gas_cross(src))
					return 0

		return 1

var/global/datum/controller/air_system/air_master
var/global/total_gas_mixtures = 0

datum/controller/air_system
	//Geoemetry lists
	var/list/datum/air_group/air_groups = list()
	var/list/turf/active_singletons = list()

	//Special functions lists
	var/list/turf/active_super_conductivity = list() //gets space in here somehow ZEWAKA/ATMOS
	var/list/turf/high_pressure_delta = list()

	//Geometry updates lists
	var/list/turf/tiles_to_update = list()
	var/list/datum/air_group/groups_to_rebuild = list()
	var/list/turf/tiles_to_space = list()

	var/current_cycle = 0
	var/is_busy = FALSE
	var/datum/controller/process/air_system/parent_controller = null

	var/turf/space/space_sample = 0 //instead of repeatedly using locate() to find space, we should just cache a space tile ok

	proc/setup(datum/controller/process/air_system/controller)
		update_space_sample()
		//Call this at the start to setup air groups geometry
		//Warning: Very processor intensive but only must be done once per round

	proc/assemble_group_turf(turf/base)
		//Call this to try to construct a group starting from base and merging with neighboring unparented tiles
		//Expands the group until all valid borders explored

	proc/process()
		//Call this to process air movements for a cycle

	proc/process_groups()
		//Used by process()
		//Warning: Do not call this

	proc/process_singletons()
		//Used by process()
		//Warning: Do not call this

	proc/process_high_pressure_delta()
		//Used by process()
		//Warning: Do not call this

	proc/process_super_conductivity()
		//Used by process()
		//Warning: Do not call this

	proc/process_tiles_to_space()
		//Used by process()
		//Warning: Do not call this

	proc/process_update_tiles()
		//Used by process()
		//Warning: Do not call this

	proc/process_rebuild_select_groups()
		//Used by process()
		//Warning: Do not call this

	proc/rebuild_group(datum/air_group)
		//Used by process_rebuild_select_groups()
		//Warning: Do not call this, add the group to air_master.groups_to_rebuild instead

	proc/update_space_sample()
		if (!space_sample || !(space_sample.turf_flags & CAN_BE_SPACE_SAMPLE))
			space_sample = locate(/turf/space)
		return space_sample

	setup(datum/controller/process/air_system/controller)
		parent_controller = controller

		#if SKIP_FEA_SETUP == 1
		return
		#else

		boutput(world, "<span class='alert'>Processing Geometry...</span>")

		var/start_time = world.timeofday

		//floors should be safe? we'd like to skip space and walls shouldn't form airgroups anyway (though they probably do IDK)
		for(var/turf/floor/S in world)
			if(issimulatedturf(S))
				if(!S.gas_impermeable && !S.parent)
					assemble_group_turf(S)
				//this is inside the issimulatedturf thing cause otherwise a third of Z2 adds itself to the active singletons list (laggy as shit)
				S.update_air_properties()

		boutput(world, "<span class='alert'>Geometry processed in [(world.timeofday-start_time)/10] seconds!</span>")
		#endif

	assemble_group_turf(turf/base)
		set waitfor = 0
		var/list/turf/members = list(base) // Confirmed group members
		var/list/turf/possible_members = list(base) // Possible places for group expansion
		var/list/turf/possible_borders
		var/list/turf/possible_space_borders
		var/possible_space_length = 0

		while(possible_members.len > 0) //Keep expanding, looking for new members
			for(var/turf/test as anything in possible_members)
				test.length_space_border = 0
				for(var/direction in cardinal)
					var/turf/T = get_step(test,direction)
					if(T && !(T in members) && test.gas_cross(T) && T.gas_cross(test))
						if(issimulatedturf(T))
							if(!T:parent)
								possible_members += T
								members += T
							else
								LAZYLISTINIT(possible_borders)
								possible_borders |= test
						else if(istype_exact(T, /turf/space))
							LAZYLISTINIT(possible_space_borders)
							possible_space_borders |= test
							test.length_space_border++

				if(test.length_space_border > 0)
					possible_space_length += test.length_space_border
				possible_members -= test

		if(members.len > 1)
			var/datum/air_group/group = new
			if(possible_borders && (possible_borders.len > 0))
				group.borders = possible_borders
			if(possible_space_borders && (possible_space_borders.len > 0))
				group.space_borders = possible_space_borders
				group.length_space_border = possible_space_length

			for(var/turf/test as anything in members)
				test.parent = group
				test.processing = 0
				active_singletons -= test

				test.dist_to_space = null
				var/dist
				for(var/P in possible_space_borders)
					var/turf/b = P
					if (b == test)
						test.dist_to_space = 1
						break
					dist = get_dist(b, test)
					if ((test.dist_to_space == null) || (dist < test.dist_to_space))
						test.dist_to_space = dist

			// Allow groups to determine if group processing is applicable after FEA setup
			if(current_cycle) group.group_processing = FALSE
			group.members = members
			air_groups += group

			group.update_group_from_tiles() //Initialize air group variables
			return group
		else
			base.processing = 0 //singletons at startup are technically unconnected anyway
			base.parent = null

			if(base.air && base.air.check_tile_graphic())
				base.update_visuals(base.air)

		return null

	process()
		current_cycle++

		process_tiles_to_space()
		is_busy = TRUE

		if(!explosions.exploding)
			if(groups_to_rebuild.len > 0)
				process_rebuild_select_groups()
			LAGCHECK(LAG_REALTIME)

			if(tiles_to_update.len > 0)
				process_update_tiles()
			LAGCHECK(LAG_REALTIME)

		process_groups()
		LAGCHECK(LAG_REALTIME)

		process_singletons()
		LAGCHECK(LAG_REALTIME)

		process_super_conductivity()
		LAGCHECK(LAG_REALTIME)

		process_high_pressure_delta()
		LAGCHECK(LAG_REALTIME)

		if(current_cycle % 7 == 0) //Check for groups of tiles to resume group processing every 7 cycles
			for(var/datum/air_group/AG as anything in air_groups)
				AG.check_regroup()
				LAGCHECK(LAG_REALTIME)

		is_busy = FALSE
		return 1

	process_tiles_to_space()
		if(length(tiles_to_space))
			for(var/turf/T as anything in tiles_to_space)
				T.ReplaceWithSpace()
			tiles_to_space.len = 0

	process_update_tiles()
		for(var/turf/T in tiles_to_update) // ZEWAKA-ATMOS SPACE + SPACE FLUID LEAKAGE
			T.update_air_properties()
		tiles_to_update.len = 0

	process_rebuild_select_groups()
		var/list/turf/turf_list = list()

		for(var/datum/air_group/turf_AG in groups_to_rebuild) // Deconstruct groups, gathering their old members
			if(turf_AG.group_processing)	// Ensure correct air is used for reconstruction, otherwise parent is destroyed
				turf_AG.suspend_group_processing()
			for(var/turf/T as anything in turf_AG.members)
				T.parent = null
				turf_list += T
			air_master.air_groups -= turf_AG
			turf_AG.members.len = 0
		LAGCHECK(LAG_REALTIME)

		for(var/turf/S as anything in turf_list) // Have old members try to form new groups
			if(!S.parent)
				assemble_group_turf(S)
		LAGCHECK(LAG_REALTIME)

		for(var/turf/S as anything in turf_list)
			S.update_air_properties()
		LAGCHECK(LAG_REALTIME)

		groups_to_rebuild.len = 0

	process_groups()
		for(var/datum/air_group/AG as anything in air_groups)
			AG?.process_group(parent_controller)
			LAGCHECK(LAG_REALTIME)

	process_singletons()
		for(var/turf/loner as anything in active_singletons)
			loner.process_cell()
			LAGCHECK(LAG_REALTIME)

	process_super_conductivity()
		for(var/turf/hot_potato as anything in active_super_conductivity)
			hot_potato.super_conduct()
			LAGCHECK(LAG_REALTIME)

	process_high_pressure_delta()
		for(var/turf/pressurized as anything in high_pressure_delta)
			pressurized.high_pressure_movements()
			LAGCHECK(LAG_REALTIME)

		high_pressure_delta.len = 0
