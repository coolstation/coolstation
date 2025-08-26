/datum/unit_test/passability_cache
	/// List of types which are permitted to violate certain stability rules.
	var/permitted_instability = list(
		/atom = list("CanPass"), // Density check, handled in jpsTurfPassable.
		/turf = list("Enter", "Exit", "CanPass"), // newloc smuggling, optimizations & vismirrors
		/turf/cordon = list("Enter"), // cordons are never crossable
		/turf/floor = list("CanPass"), // 2x2 pod collision handling (handled in /datum/pathfind by disabling cache for pods)
		/turf/null_hole = list("Enter"), // null holes arent pathable
		/obj/grille/catwalk = list("CanPass"), //catwalks are the nondense variant that never blocks
		/obj/item/scrap = list("CanPass"), // it eats other scrap that enters it
		/mob/living/critter/robotic/bot = list("CanPass"), // likewise
		/mob/living/intangible = list("CanPass"), // dont even break cache for these
		/obj/machinery/bot = list("CanPass"), // only blocks projectiles, probably
		/turf/floor/setpieces/gauntlet = list("CanPass"), //pods
		/turf/floor/setpieces/gauntlet/pod = list("CanPass"), //pods
	)
	/// List of procs that are forbidden to be implemented on stable atoms.
	var/forbidden_procs = list("Enter", "Exit", "CanPass")

/**
 * JPS Passability cache flag [/atom/var/pass_unstable] correctness checking.
 * Issue a failure for every descendent of /atom claiming to be stable, that is itself, or a descendant of, any type that contains an implementation
 * of a proc listed in forbidden_procs that is not explicitly allowed in permitted_instability.
 */
/datum/unit_test/passability_cache/Run()
	generate_procs_by_type()

	// var/list/empty_list = list()
	var/list/unstable_types = list()

	for(var/type in concrete_typesof(/atom))
		var/atom/atom_type = type

		var/direct_parent_path = type2parent(type)
		var/atom/direct_parent
		if(ispath(direct_parent_path, /atom))
			direct_parent = direct_parent_path
		var/instability = initial(atom_type.pass_unstable)

		// Fail if this type is the first descendant of a unstable lineage to claim to be stable.
		if(!instability && direct_parent && initial(direct_parent.pass_unstable))
			var/unstable_parent = predecessor_path_in_list(type, unstable_types)
			if(unstable_parent)
				var/list/blocking_procs_list = unstable_types[unstable_parent]
				var/parents_permitted_procs = src.permitted_instability[unstable_parent]
				for(var/blocking_proc in blocking_procs_list)
					if(blocking_proc in parents_permitted_procs)
						continue
					Fail("[type] claims stability but cannot be because [unstable_parent] implements [blocking_procs]")

		var/procs = procs_by_type[type]
		if(!procs)
			continue
		var/permitted_procs = src.permitted_instability[type]

		// Fail if this type claims to be stable but implements forbidden procs.
		for(var/forbidden_proc in forbidden_procs)
			if(procs[forbidden_proc])
				if(forbidden_proc in permitted_procs)
					continue // Don't track permitted instability
				LAZYLISTADD(unstable_types[type], forbidden_proc)
				if(instability != TRUE)
					Fail("[type] is stable and must not implement [forbidden_proc]")

		// Fail if this type preserves the cache but can alter passability - maybe expand this check to instantiation and CanPass later?
		if(instability & PRESERVE_CACHE)
			if(initial(atom_type.density))
				Fail("[type] is JPS cache preserving and must not be dense")

