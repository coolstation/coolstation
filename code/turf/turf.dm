/turf
	icon = 'icons/turf/floors.dmi'
	plane = PLANE_FLOOR //See _plane.dm, required for shadow effect
	appearance_flags = TILE_BOUND | PIXEL_SCALE
	flags = OPENCONTAINER | FPRINT
	var/intact = 1
	var/allows_vehicles = 1

	var/tagged = 0 // Gang wars thing

	///If ReplaceWith() actually does a thing or not. Used to be a thing on turf, gets set for unsimmed turfs in New() in base_lighting.dm
	var/can_replace_with_stuff = 0

	//To the best of my knowledge nothing cares about a turf's level
	level = 1

	//Properties for open tiles (/floor)
	#define _UNSIM_TURF_GAS_DEF(GAS, ...) var/GAS = 0;
	APPLY_TO_GASES(_UNSIM_TURF_GAS_DEF)

	//By default, folks can breathe on a turf (this might look weird but that's just how it is to have folks not suffocate on walls)
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

	//Properties for airtight tiles (/wall)
	var/thermal_conductivity = 0.05
	var/heat_capacity = 1

	#undef _UNSIM_TURF_GAS_DEF

	//Properties for both
	var/temperature = T20C

	var/icon_old = null
	var/name_old = null
	var/tmp/pathweight = 1
	var/tmp/pathable = 1
	var/can_write_on = 0
	var/tmp/messy = 0 //value corresponds to how many cleanables exist on this turf. Exists for the purpose of making fluid spreads do less checks.
	//var/tmp/checkingexit = 0 //value corresponds to how many objs on this turf implement checkexit(). lets us skip a costly loop later!
	//var/tmp/checkingcanpass = 0 // "" how many implement canpass()
	//var/tmp/checkinghasentered = 0 // "" hasproximity as well as items with a mat that hasproximity
	var/tmp/checkinghasproximity = 0
	/// directions of this turf being blocked by directional blocking objects. So we don't need to loop through the entire contents
	//var/tmp/blocked_dirs = 0
	var/wet = 0 //slippery when
	var/clean = 0 //is this floor recently cleaned? like, clean enough to eat off of? almost no floor starts clean
	var/permadirty = 0 //grimy tiles can never truly be clean
	throw_unlimited = 0 //throws cannot stop on this tile if true (also makes space drift)

	var/step_material = 0
	var/step_priority = 0 //compare vs. shoe for step sounds

	var/special_volume_override = -1 //if greater than or equal to 0, override

	var/turf_flags = 0

	var/mutable_appearance/wet_overlay = null
	var/default_melt_cap = 30
	can_write_on = 1

	text = "<font color=#aaa>."

	//wrapper for crap that needs to be maintained when turfs are replaced
	var/datum/turf_persistent/turf_persistent

	disposing() // DOES NOT GET CALLED ON TURFS!!!
		SHOULD_NOT_OVERRIDE(TRUE)
		..()

	Del()
		if (length(cameras))
			for (var/obj/machinery/camera/C as anything in by_type[/obj/machinery/camera])
				if(C.coveredTiles)
					C.coveredTiles -= src
		cameras = null
		..()

	onMaterialChanged()
		..()
		if(istype(src.material))
			if(initial(src.opacity))
				src.RL_SetOpacity(src.material.alpha <= MATERIAL_ALPHA_OPACITY ? 0 : 1)

		gas_impermeable = material.hasProperty("permeable") ? material.getProperty("permeable") >= 33 : gas_impermeable
		return

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		F["[path].type"] << type
		serialize_icon(F, path, sandbox)
		F["[path].name"] << name
		F["[path].dir"] << dir
		F["[path].desc"] << desc
		F["[path].color"] << color
		F["[path].density"] << density
		F["[path].opacity"] << opacity
		F["[path].pixel_x"] << pixel_x
		F["[path].pixel_y"] << pixel_y

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		deserialize_icon(F, path, sandbox)
		F["[path].name"] >> name
		F["[path].dir"] >> dir
		F["[path].desc"] >> desc
		F["[path].color"] >> color
		F["[path].density"] >> density
		F["[path].opacity"] >> opacity
		RL_SetOpacity(opacity)
		F["[path].pixel_x"] >> pixel_x
		F["[path].pixel_y"] >> pixel_y
		return DESERIALIZE_OK

	proc/canpass()
		if( density )
			return 0
		for( var/thing in contents )
			var/atom/A = thing
			if( A.density && !ismob(A) )
				return 0
		return 1

	proc/tilenotify(turf/notifier)

	proc/selftilenotify()

	proc/is_frozen()
		if(istype(src,/turf/space))
			return TRUE
		if(temperature < T0C+2 ) // 2 degrees of grace.
			return TRUE
		else
			return FALSE

	proc/is_too_hot()
		if(istype(src,/turf/space))
			return FALSE
		if(temperature > T45C)
			return TRUE
		else
			return FALSE


	proc/inherit_area() //jerko built a thing
		if(!loc:expandable) return
		for(var/dir in (cardinal + 0))
			var/turf/thing = get_step(src, dir)
			var/area/fuck_everything = thing?.loc
			if(fuck_everything?.expandable && (fuck_everything.type != /area/space))
				fuck_everything.add_turf(src)
				return

		var/area/built_zone/zone = new//TODO: cache a list of these bad boys because they don't get GC'd because WHY WOULD THEY?!
		zone.add_turf(src)//get in the ZONE

	proc/setIntact(var/new_intact_value)
		if (new_intact_value)
			src.intact = TRUE
			src.layer = TURF_LAYER
		else
			src.intact = FALSE
			src.layer = PLATING_LAYER

	proc/UpdateDirBlocks()
		src.turf_persistent.blocked_dirs = 0
		for (var/obj/O in src.contents)
			if (HAS_FLAG(O.object_flags, HAS_DIRECTIONAL_BLOCKING))
				ADD_FLAG(src.turf_persistent.blocked_dirs, O.dir)

/turf/attack_hand(var/mob/user as mob)
	if (src.density == 1)
		return
	if ((!( user.canmove ) || user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (isobj(user.pulling.loc))
		var/obj/container = user.pulling.loc
		if (user.pulling in container.contents)
			return

	var/turf/fuck_u = user.pulling.loc
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/mob/t = M.pulling
		M.pulling = null
		step(M, get_dir(fuck_u, src))
		M.pulling = t
	else
		step(user.pulling, get_dir(fuck_u, src))
	return

/turf/attackby(var/obj/item/W, var/mob/user, params)
	if (istype(W, /obj/item/pen))
		var/obj/item/pen/P = W
		P.write_on_turf(src, user, params)
		return
	else
		//if turf has kudzu, transfer attack from turf to kudzu
		if (src.temp_flags & HAS_KUDZU)
			var/obj/spacevine/K = locate(/obj/spacevine) in src.contents
			if (K)
				K.Attackby(W, user, params)
		return ..()


/turf/meteorhit(obj/meteor as obj) //ATMOSSIMSTODO
	return

/turf/ex_act(severity) //ATMOSSIMSTODO
	return

/turf/New(loc, datum/turf_persistent/inheritance = null)
	..() //atom shit down here
	if (inheritance)
		turf_persistent = inheritance
	else
		turf_persistent = new

	turf_persistent.RL_LumR += base_RL_LumR
	turf_persistent.RL_LumG += base_RL_LumG
	turf_persistent.RL_LumB += base_RL_LumB

	if (density)
		pathable = 0
	for(var/atom/movable/AM as mob|obj in src)
		if (AM) // ???? x2
			src.Entered(AM)
	if(!RL_Started)
		RL_Init()

	//Atmospherics setup
	var/area/A = src.loc
	if (A.is_atmos_simulated)
		instantiate_air()
		if (!istype(src, /turf/space))
			turf_flags |= IS_TYPE_SIMULATED

	//unsimmed turfs are unreplaceable by default
	can_replace_with_stuff = (A.is_construction_allowed || can_replace_with_stuff) //(no it's not lighting related but this override already had the area going on)
#ifdef RUNTIME_CHECKING
	can_replace_with_stuff = 1  //Shitty dumb hack bullshit (moved from turf/unsimulated definition, IDK what it's for)
#endif

	//Base lighting setup
	#ifdef UNDERWATER_MAP //FUCK THIS SHIT. NO FULLBRIGHT ON THE MINING LEVEL, I DONT CARE.
	if (z == AST_ZLEVEL) return
	#endif
	if (!A.force_fullbright && fullbright) // if the area's fullbright we'll use a single overlay on the area instead
		overlays += /image/fullbright


/turf/Enter(atom/movable/mover as mob|obj, atom/forget as mob|obj|turf|area)
	if (!mover)
		return 1

	var/turf/cturf = get_turf(mover)
	if (cturf == src)
		return 1

	//First, check objects to block exit
	if (cturf?.turf_persistent.checkingexit > 0) //dont bother checking unless the turf actually contains a checkable :)
		for(var/thing in cturf)
			var/obj/obstacle = thing
			if(obstacle == mover)
				continue
			if((mover != obstacle) && (forget != obstacle))
				if(obstacle.event_handler_flags & USE_CHECKEXIT)
					if(!obstacle.CheckExit(mover, src))
						mover.Bump(obstacle, 1)
						return 0

	//Then, check the turf itself
	if (!src.CanPass(mover, src))
		mover.Bump(src, 1)
		return 0

	//Finally, check objects/mobs to block entry
	if (src.turf_persistent.checkingcanpass > 0)  //dont bother checking unless the turf actually contains a checkable :)
		for(var/thing in src)
			var/atom/movable/obstacle = thing
			if(obstacle == mover) continue
			if(!mover)	return 0
			if ((forget != obstacle))
				if(obstacle.event_handler_flags & USE_CANPASS)
					if(!obstacle.CanPass(mover, cturf, 1, 0))

						mover.Bump(obstacle, 1)
						return 0
				else //cheaper, skip proc call lol lol
					if (obstacle.density)

						mover.Bump(obstacle,1)
						return 0

	if (mirrored_physical_zone_created) //checking visual mirrors for blockers if set
		if (length(src.vis_contents))
			var/turf/T = locate(/turf) in src.vis_contents
			if (T)
				for(var/thing in T)

					var/atom/movable/obstacle = thing
					if(obstacle == mover) continue
					if(!mover)	return 0
					if ((forget != obstacle))
						if(obstacle.event_handler_flags & USE_CANPASS)
							if(!obstacle.CanPass(mover, cturf, 1, 0))

								mover.Bump(obstacle, 1)
								return 0
						else //cheaper, skip proc call lol lol
							if (obstacle.density)

								mover.Bump(obstacle,1)
								return 0

	return 1 //Nothing found to block so return success!

/turf/Exited(atom/movable/Obj, atom/newloc)
	var/i = 0

	//MBC : nothing in the game even uses PrxoimityLeave meaningfully. I'm disabling the proc call here.
	//for(var/atom/A as mob|obj|turf|area in range(1, src))
	if (src.turf_persistent.checkinghasentered > 0)  //dont bother checking unless the turf actually contains a checkable :)
		for(var/thing in src)
			var/atom/A = thing
			if(A == Obj)
				continue
			// I Said No sanity check
			if(i >= 50)
				break
			i++
			if(A.loc == src && A.event_handler_flags & USE_HASENTERED)
				A.HasExited(Obj, newloc)
			//A.ProximityLeave(Obj)

	if (global_sims_mode)
		var/area/Ar = loc
		if (!Ar.skip_sims)
			if (isitem(Obj))
				if (!(locate(/obj/table) in src) && !(locate(/obj/rack) in src))
					Ar.sims_score = min(Ar.sims_score + 4, 100)


	return ..(Obj, newloc)

/turf/Entered(atom/movable/M as mob|obj, atom/OldLoc)
	if(ismob(M) && !src.throw_unlimited && !M.no_gravity)
		var/mob/tmob = M
		tmob.inertia_dir = 0
	///////////////////////////////////////////////////////////////////////////////////
	..()
	return_if_overlay_or_effect(M)
	src.material?.triggerOnEntered(src, M)

	//optionally cancel swims
	if (isliving(M) && M.hasStatus("swimming") && !istype(src, /turf/space/fluid))
		if (src.active_liquid?.last_depth_level < 3) //Trying to swim into the air
			actions.start(new/datum/action/swim_coyote_time(), M)
			//M.delStatus("swimming")

	if (global_sims_mode)
		var/area/Ar = loc
		if (!Ar.skip_sims)
			if (isitem(M))
				if (!(locate(/obj/table) in src) && !(locate(/obj/rack) in src))
					Ar.sims_score = max(Ar.sims_score - 4, 0)

	var/i = 0
	if (src.turf_persistent.checkinghasentered > 0)  //dont bother checking unless the turf actually contains a checkable :)
		for(var/thing in src)
			var/atom/A = thing
			if(A == M)
				continue
			// I Said No sanity check
			if(i++ >= 50)
				break

			if (A.event_handler_flags & USE_HASENTERED)
				A.HasEntered(M, OldLoc)
			if(A.material)
				A.material.triggerOnEntered(A, M)
	i = 0
	for (var/turf/T in range(1,src))
		if (T.checkinghasproximity > 0)
			for(var/thing in T)
				var/atom/A = thing
				// I Said No sanity check
				if(i++ >= 50)
					break
				if (A.event_handler_flags & USE_PROXIMITY)
					A.HasProximity(M, 1) //IMPORTANT MBCNOTE : ADD USE_PROXIMITY FLAG TO ANY ATOM USING HASPROX THX BB

	if(!src.throw_unlimited && M?.no_gravity)
		BeginSpacePush(M)

#ifdef NON_EUCLIDEAN
	if(warptarget)
		if(OldLoc)
			switch (warptarget_modifier)
				if(LANDMARK_VM_WARP_NON_ADMINS) //warp away nonadmin
					if (ismob(M))
						var/mob/mob = M
						if (!mob.client?.holder && mob.last_client)
							M.set_loc(warptarget)
						if (rank_to_level(mob.client.holder.rank) < LEVEL_SA)
							M.set_loc(warptarget)
				else
					M.set_loc(warptarget)
#endif

#if defined(MAP_OVERRIDE_POD_WARS)
/turf/proc/edge_step(var/atom/movable/A, var/newx, var/newy)

	//testing pali's solution for getting the direction opposite of the map edge you are nearest to.
	// A.set_loc(A.loc)
	var/atom/target = get_edge_target_turf(A, (A.x + A.y > world.maxx ? SOUTH | WEST : NORTH | EAST) & (A.x - A.y > 0 ? NORTH | WEST : SOUTH | EAST))
	if (!istype(A, /obj/machinery/vehicle) && target)	//Throw everything but vehicles(pods)
		A.throw_at(target, 1, 1)

	return
#else
//transfer between Z-levels happens here
/turf/proc/edge_step(var/atom/movable/A, var/newx, var/newy)
	var/zlevel = 3 //((A.z=3)?5:3)//(3,4)

	if(A.z == 3) zlevel = 5
	else if(map_currently_very_dusty)
		if(A.z == 6) zlevel = 5
		else zlevel = 6

	if (world.maxz < zlevel) // if there's less levels than the one we want to go to
		zlevel = 1 // just boot people back to z1 so the server doesn't lag to fucking death trying to place people on maps that don't exist
	if (istype(A, /obj/machinery/vehicle))
		var/obj/machinery/vehicle/V = A
		if (V.going_home)
			if(map_currently_very_dusty)
				zlevel = 5
			else
				zlevel = 1
			V.going_home = 0
	if (istype(A, /obj/newmeteor))
		qdel(A)
		return

	if (A.z == 1 && zlevel != A.z)
		if (!(isitem(A) && A:w_class <= W_CLASS_SMALL))
			for_by_tcl(C, /obj/machinery/communications_dish)
				C.add_cargo_logs(A)

	A.z = zlevel
	if (newx)
		A.x = newx
	if (newy)
		A.y = newy
	SPAWN_DBG(0)
		if ((A?.loc))
			A.loc.Entered(A)
#endif

/turf/hitby(atom/movable/AM, datum/thrown_thing/thr)
	. = ..()
	if(src.density)
		if(AM.throwforce >= 80)
			src.meteorhit(AM)
		. = 'sound/impact_sounds/Generic_Stab_1.ogg'

/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(src.intact)

/turf/proc/burn_down()
		return

/turf/proc/ReplaceWith(var/what, var/keep_old_material = 1, var/handle_air = 1, handle_dir = 1, force = 0)
	SEND_SIGNAL(src, COMSIG_TURF_REPLACED, what)
	if (!can_replace_with_stuff && !force) //(for unsimmed turfs)
		return //..(what, keep_old_material = keep_old_material, handle_air = handle_air)

	var/turf/new_turf
	var/old_dir = dir

	if(explosions.exploding) // this is fucked up and messed up and fucked up.
		handle_air = FALSE
		keep_old_material = FALSE

	var/oldmat = src.material

	var/datum/gas_mixture/oldair = null //Set if old turf is simulated and has air on it.
	var/datum/air_group/oldparent = null //Ditto.
	var/zero_new_turf_air = (turf_flags & CAN_BE_SPACE_SAMPLE)

	//For unsimulated static air tiles such as ice moon surface.
	var/temp_old = null
	#define _OLD_GAS_VAR_DEF(GAS, ...) var/GAS ## _old = null;
	APPLY_TO_GASES(_OLD_GAS_VAR_DEF)

	if (handle_air)
		if (issimulatedturf(src)) //Setting oldair & oldparent if simulated.
			oldair = src.air
			oldparent = src.parent

		else //Apparently unsimulated turfs can have static air as well!
			#define _OLD_GAS_VAR_ASSIGN(GAS, ...) GAS ## _old = src.GAS;
			APPLY_TO_GASES(_OLD_GAS_VAR_ASSIGN)
			temp_old = src.temperature
			#undef _OLD_GAS_VAR_ASSIGN

	#undef _OLD_GAS_VAR_DEF

	/*
	if (!src.fullbright)
		var/area/old_loc = src.loc
		if(old_loc)
			old_loc.contents -= src.loc
	*/
	if ((map_currently_underwater && what == "Space")  && (src.z == 1 || src.z == 5))
		var/area/area = src.loc
		if(istype(area, /area/shuttle/))
			what = "Plating"
			keep_old_material = 1
		else
			what = "Ocean"
			keep_old_material = 0

	if ((map_currently_very_dusty && what == "Space") && (src.z == 1 || src.z == 3))
		var/area/area = src.loc
		if(istype(area, /area/shuttle/))
			what = "Plating"
			keep_old_material = 1
		else
			what = "Desert"
			keep_old_material = 0

	//This doesn't work properly yet, but the solution seems to be calling RL_UPDATE_LIGHT on 3 of our neighbours and fuck that

	//turf_persistent.RL_LumR -= base_RL_LumR
	//turf_persistent.RL_LumG -= base_RL_LumG
	//turf_persistent.RL_LumB -= base_RL_LumB

	var/old_opacity = src.opacity

	var/old_checkinghasproximity = src.checkinghasproximity

	var/new_type = ispath(what) ? what : text2path(what) //what what, what WHAT WHAT WHAAAAAAAAT
	if (new_type)
		new_turf = new new_type(src, src.turf_persistent)
		if (!isturf(new_turf))
			new_turf = new /turf/space(src, src.turf_persistent)

	else switch(what)
		if ("Desert")
			if(src.z==3)
				new_turf = new /turf/floor/plating/gehenna(src, src.turf_persistent)
			else
				new_turf = new /turf/space/gehenna/desert(src, src.turf_persistent)
		if ("Ocean")
			new_turf = new /turf/space/fluid(src, src.turf_persistent)
		if ("Floor")
			new_turf = new /turf/floor(src, src.turf_persistent)
		if ("MetalFoam")
			new_turf = new /turf/floor/metalfoam(src, src.turf_persistent)
		if ("EngineFloor")
			new_turf = new /turf/floor/engine(src, src.turf_persistent)
		if ("Circuit")
			new_turf = new /turf/floor/circuit(src, src.turf_persistent)
		if ("RWall")
			if (map_settings)
				new_turf = new map_settings.rwalls (src, src.turf_persistent)
			else
				new_turf = new /turf/wall/r_wall(src, src.turf_persistent)
		if("Concrete")
			new_turf = new /turf/floor/concrete(src, src.turf_persistent)
		if ("Wall")
			if (map_settings)
				new_turf = new map_settings.walls (src, src.turf_persistent)
			else
				new_turf = new /turf/wall(src, src.turf_persistent)
		if ("Unsimulated Floor") //AREASIMSTODO
			new_turf = new /turf/floor(src, src.turf_persistent)
		if ("Plating")
			new_turf = new /turf/floor/plating/random(src, src.turf_persistent)
		else
			new_turf = new /turf/space(src, src.turf_persistent)

	if(keep_old_material && oldmat && !istype(new_turf, /turf/space)) new_turf.setMaterial(oldmat)

	new_turf.icon_old = icon_old //TODO: Change it so original turf path is remembered, for turfening floors
	new_turf.name_old = name_old

	if (handle_dir)
		new_turf.set_dir(old_dir)

	new_turf.levelupdate()

	new_turf.checkinghasproximity = old_checkinghasproximity

	//cleanup old overlay to prevent some Stuff
	//This might not be necessary, i think its just the wall overlays that could be manually cleared here.
	//new_turf.RL_Cleanup() // ACTUALLY this proc does nothing anymore		 //Cleans up/mostly removes the lighting.
	new_turf.RL_Init()

	//The following is required for when turfs change opacity during replace. Otherwise nearby lights will not be applying to the correct set of tiles.
	//example of failure : fire destorying a wall, the fire goes away, the area BEHIND the wall that used to be blocked gets strip()ped and now it leaves a blue glow (negative fire color)
	if (new_turf.opacity != old_opacity)
		new_turf.opacity = old_opacity
		new_turf.RL_SetOpacity(!new_turf.opacity)


	if (handle_air)
		if (issimulatedturf(src)) //Anything -> Simulated tile
			var/turf/N = new_turf
			if (oldair) //Simulated tile -> Simulated tile
				N.air = oldair
			else if(zero_new_turf_air && istype(N.air)) //Unsimulated tile (likely space) - > Simulated tile  // fix runtime: Cannot execute null.zero() << ever heard of walls you butt???
				N.air.zero()

			#define _OLD_GAS_VAR_NOT_NULL(GAS, ...) GAS ## _old ||
			if (N.air && (APPLY_TO_GASES(_OLD_GAS_VAR_NOT_NULL) 0)) //Unsimulated tile w/ static atmos -> simulated floor handling
				#define _OLD_GAS_VAR_RESTORE(GAS, ...) N.air.GAS += GAS ## _old;

				APPLY_TO_GASES(_OLD_GAS_VAR_RESTORE)
				if (!N.air.temperature)
					N.air.temperature = temp_old

				#undef _OLD_GAS_VAR_RESTORE
			#undef _OLD_GAS_VAR_NOT_NULL

			// tell atmos to update this tile's air settings
			if (air_master)
				air_master.tiles_to_update |= N

		if (air_master && oldparent) //Handling air parent changes for oldparent for Simulated -> Anything
			air_master.groups_to_rebuild |= oldparent //Puts the oldparent into a queue to update the members.

	if (issimulatedturf(new_turf)) //ATMOSSIMSTODO - hope this works
		// tells the atmos system "hey this tile changed, maybe rebuild the group / borders"
		new_turf.update_nearby_tiles(1)

	return new_turf


/turf/proc/ReplaceWithFloor()
	var/turf/floor = ReplaceWith("Floor")
	if (icon_old)
		floor.icon_state = icon_old
	if (name_old)
		floor.name = name_old
	for (var/obj/lattice/L in src.contents)
		qdel(L)

	if (map_settings)
		if (map_settings.auto_walls)
			for (var/turf/wall/auto/W in orange(1))
				W.update_icon()
		if (map_settings.auto_windows)
			for (var/obj/window/auto/W in orange(1))
				W.update_icon()
	return floor

/turf/proc/ReplaceWithMetalFoam(var/mtype)
	var/turf/floor/metalfoam/floor = ReplaceWith("MetalFoam")
	if(icon_old)
		floor.icon_state = icon_old
	if(name_old)
		floor.name_old = name_old

	for (var/obj/lattice/L in src.contents)
		qdel(L)

	floor.metal = mtype
	floor.update_icon()

	return floor

/turf/proc/ReplaceWithEngineFloor()
	var/turf/floor = ReplaceWith("EngineFloor")
	if(icon_old)
		floor.icon_state = icon_old
	for (var/obj/lattice/L in src.contents)
		qdel(L)
	return floor

/turf/proc/ReplaceWithCircuit()
	var/turf/floor = ReplaceWith("Circuit")
	if(icon_old)
		floor.icon_state = icon_old
	for (var/obj/lattice/L in src.contents)
		qdel(L)
	return floor

/turf/proc/ReplaceWithSpace()
	if( air_master.is_busy )
		air_master.tiles_to_space |= src
		return

	var/area/my_area = loc
	var/turf/floor
	if (my_area)
		if (my_area.filler_turf)
			floor = ReplaceWith(my_area.filler_turf)
		else
			floor = ReplaceWith("Space")
	else
		floor = ReplaceWith("Space")

	return floor

/turf/proc/ReplaceWithConcreteFloor()
	var/turf/floor = ReplaceWith("Concrete")
	if(icon_old)
		floor.icon_state = icon_old
	return floor

//This is for admin replacements (deletions) ONLY. I swear to god if any actual in-game code uses this I will be pissed - Wire
/turf/proc/ReplaceWithSpaceForce()
	var/area/my_area = loc
	var/turf/floor
	if (my_area)
		if (my_area.filler_turf)
			floor = ReplaceWith(my_area.filler_turf, force=1)
		else
			floor = ReplaceWith("Space", force=1)
	else
		floor = ReplaceWith("Space", force=1)

	return floor

/turf/proc/ReplaceWithLattice()
	new /obj/lattice(src)
	return ReplaceWithSpace()

/turf/proc/ReplaceWithWall()
	var/wall = ReplaceWith("Wall")
	if (map_settings)
		if (map_settings.auto_walls)
			for (var/turf/wall/auto/W in orange(1))
				W.update_icon()
		if (map_settings.auto_windows)
			for (var/obj/window/auto/W in orange(1))
				W.update_icon()
	return wall

/turf/proc/ReplaceWithRWall()
	var/wall = ReplaceWith("RWall")
	if (map_settings)
		if (map_settings.auto_walls)
			for (var/turf/wall/auto/W in orange(1))
				W.update_icon()
		if (map_settings.auto_windows)
			for (var/obj/window/auto/W in orange(1))
				W.update_icon()
	return wall

/turf/proc/is_sanctuary()
  var/area/AR = src.loc
  return AR.sanctuary

//////////////////////////////////////////////////////////////////////////////////////////////////

//Overlays

//////////////////////////////////////////////////////////////////////////////////////////////////
/obj/overlay/tile_effect
	name = ""
	anchored = 1
	density = 0
	mouse_opacity = 0
	alpha = 255
	layer = TILE_EFFECT_OVERLAY_LAYER
	animate_movement = NO_STEPS // fix for things gliding around all weird

	pooled(var/poolname)
		overlays.len = 0
		..()

	Move()
		return 0

/obj/overlay/tile_gas_effect
	name = ""
	anchored = 1
	density = 0
	mouse_opacity = 0

	pooled(var/poolname)
		overlays.len = 0
		..()

	Move()
		return 0

///////////////////////////////////////////////////////////////////////////////////////////////////

//SPAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACE

///////////////////////////////////////////////////////////////////////////////////////////////////

/turf/space
	icon = 'icons/turf/space.dmi'
	name = "\proper space"
	icon_state = "placeholder"
	fullbright = 1
#ifndef HALLOWEEN
	color = "#898989"
#endif
	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000
	pathable = 0
	mat_changename = 0
	mat_changedesc = 0
	throw_unlimited = 1
	oxygen = 0
	nitrogen = 0
	plane = PLANE_SPACE
	special_volume_override = 0
	text = ""
	clean = 1 //in space, no one needs you to clean
	intact = FALSE //in space, you can't hide anything under the floor either
	var/static/list/space_color = generate_space_color()
	var/static/image/starlight

	flags = ALWAYS_SOLID_FLUID
	turf_flags = CAN_BE_SPACE_SAMPLE | MINE_MAP_PRESENTS_EMPTY
	event_handler_flags = IMMUNE_SINGULARITY
	dense
		icon_state = "dplaceholder"
		density = 1
		opacity = 1

	cavern // cavernous interior spaces
		icon_state = "cavern"
		name = "cavern"
		fullbright = 0

/turf/space/solariumjoke
	icon = 'icons/misc/worlds.dmi'
	icon_state = "howlingsun"
	desc = "Looks normal."

/turf/space/proc/update_icon(starlight_alpha=255)
	if(!isnull(space_color) && !istype(src, /turf/space/fluid) && !istype(src, /turf/space/gehenna))
		src.color = space_color

	if(fullbright)
		if(!starlight)
			starlight = image('icons/effects/overlays/simplelight.dmi', "3x3", pixel_x=-32, pixel_y=-32)
			starlight.appearance_flags = RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | NO_CLIENT_COLOR | KEEP_APART
			starlight.layer = LIGHTING_LAYER_BASE
			starlight.plane = PLANE_LIGHTING
			starlight.blend_mode = BLEND_ADD

		starlight.color = src.color
		if(!isnull(starlight_alpha))
			starlight.alpha = starlight_alpha
		UpdateOverlays(starlight, "starlight")
	else
		UpdateOverlays(null, "starlight")


/turf/space/no_replace

/turf/space/New()
	..()
	//icon = 'icons/turf/space.dmi'
	if (icon_state == "placeholder") icon_state = "[rand(1,25)]"
	if (icon_state == "aplaceholder") icon_state = "a[rand(1,10)]"
	if (icon_state == "dplaceholder") icon_state = "[rand(1,25)]"
	if (icon_state == "d2placeholder") icon_state = "near_blank"
	if (blowout == 1) icon_state = "blowout[rand(1,5)]"
	if (derelict_mode == 1)
		icon = 'icons/turf/floors.dmi'
		icon_state = "darkvoid"
		name = "void"
		desc = "Yep, this is fine."

	update_icon()

proc/repaint_space(regenerate=TRUE, starlight_alpha)
	for(var/turf/space/T)
		if(regenerate)
			T.space_color = generate_space_color()
			regenerate = FALSE
		if(istype(T, /turf/space/fluid))
			continue
		T.update_icon(starlight_alpha)

proc/generate_space_color()
#ifndef HALLOWEEN
	return "#898989"
#else
	var/bg = list(0, 0, 0)
	bg[1] += rand(0, 35)
	bg[3] += rand(0, 35)
	var/main_star = list(255, 255, 255)
	main_star = list(150 + rand(-40, 40), 100 + rand(-40, 40), 50 + rand(-40, 40))
	var/hsv_main = rgb2hsv(main_star[1], main_star[2], main_star[3])
	hsv_main[2] = 100
	main_star = hsv2rgblist(hsv_main[1], hsv_main[2], hsv_main[3])
	if(prob(5))
		main_star = list(230, 0, 0)
	var/misc_star_1 = main_star
	var/misc_star_2 = main_star
	if(prob(33))
		misc_star_2 = list(main_star[2], main_star[3], main_star[1])
		misc_star_1 = list(main_star[3], main_star[1], main_star[2])
	else if(prob(50))
		misc_star_1 = list(main_star[2], main_star[3], main_star[1])
		misc_star_2 = list(main_star[3], main_star[1], main_star[2])
	else
		misc_star_1 = list(150 + rand(-40, 40), 100 + rand(-40, 40), 50 + rand(-40, 40))
		misc_star_2 = list(150 + rand(-40, 40), 100 + rand(-40, 40), 50 + rand(-40, 40))
	if(prob(5))
		misc_star_1 = list(230, 0, 0)
	misc_star_1 = list(misc_star_1[1] + rand(-25, 25), misc_star_1[2] + rand(-25, 25), misc_star_1[3] + rand(-25, 25))
	misc_star_2 = list(misc_star_2[1] + rand(-25, 25), misc_star_2[2] + rand(-25, 25), misc_star_2[3] + rand(-25, 25))
	if(prob(5))
		misc_star_2 = list(230, 0, 0)
	if(prob(1.5))
		bg = list(200 - bg[1], 200 - bg[2], 200 - bg[3])
		if(prob(50))
			main_star = list(180 - main_star[1], 180 - main_star[2], 180 - main_star[3])
			misc_star_1 = list(255 - misc_star_1[1], 255 - misc_star_1[2], 255 - misc_star_1[3])
			misc_star_2 = list(255 - misc_star_2[1], 255 - misc_star_2[2], 255 - misc_star_2[3])
	if(prob(2))
		bg = list(120 + rand(-30, 30), rand(20, 50), rand(20, 50))
	return affine_color_mapping_matrix(
		list("#000000", "#ffffff", "#ff0000", "#0080FF"), // original misc_star_2 = "#64C5D2", but that causes issues for some frames
		list(bg, main_star, misc_star_1, misc_star_2)
	)
#endif

// Ported from unstable r355
/turf/space/Entered(atom/movable/A as mob|obj)
	..()
	if ((!(A) || istype(null, /obj/projectile)))
		return

	if (!(A.last_move))
		return

	//if(!(src in A.locs))
	//	return

//	if (locate(/obj/movable, src))
//		return 1

	//if (!istype(src,/turf/space/fluid))//ignore inertia if we're in the ocean
	if (src.throw_unlimited)//ignore inertia if we're in the ocean (faster but kind of dumb check)
		if ((ismob(A) && src.x > 2 && src.x < (world.maxx - 1))) //fuck?
			var/mob/M = A
			if( M.client && M.client.flying )
				return//aaaaa
			BeginSpacePush(M)

	if (src.x <= 1)
		edge_step(A, world.maxx- 2, 0)
	else if (A.x >= (world.maxx - 1))
		edge_step(A, 3, 0)
	else if (src.y <= 1)
		edge_step(A, 0, world.maxy - 2)
	else if (A.y >= (world.maxy - 1))
		edge_step(A, 0, 3)

// override for space turfs, since they should never hide anything
/turf/space/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(0)

// override for space turfs, since they should never hide anything
/turf/space/ReplaceWithSpace()
	return

/turf/space/process_cell()
	return

// imported from space.dm

/turf/space/attack_hand(mob/user as mob)
	if ((user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (isobj(user.pulling.loc))
		var/obj/container = user.pulling.loc
		if (user.pulling in container.contents)
			return

	var/turf/fuck_u = user.pulling.loc
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/t = M.pulling
		M.pulling = null
		step(M, get_dir(fuck_u, src))
		M.pulling = t
	else
		step(user.pulling, get_dir(fuck_u, src))
	return

/turf/space/attackby(obj/item/C as obj, mob/user as mob)
	var/area/A = get_area (user)
	if (istype(A, /area/supply/spawn_point || /area/supply/delivery_point || /area/supply/sell_point))
		boutput(user, "<span class='alert'>You can't build here.</span>")
		return
	var/obj/item/rods/R = C
	if (istype(R))
		//no more stacking lattices thx
		var/obj/lattice/lat = locate() in src
		if (lat)
			return //lat.Attackby(R, user)
		else if (R.change_stack_amount(-1))
			boutput(user, "<span class='notice'>Constructing support lattice ...</span>")
			playsound(src, "sound/impact_sounds/Generic_Stab_1.ogg", 50, 1)
			ReplaceWithLattice()
			if (R.material)
				src.setMaterial(C.material)
			return

	if (istype(C, /obj/item/tile))
		//var/obj/lattice/L = locate(/obj/lattice, src)
		var/obj/item/tile/T = C
		if (T.amount >= 1)
			for(var/obj/lattice/L in src)
				qdel(L)
			playsound(src, "sound/impact_sounds/Generic_Stab_1.ogg", 50, 1)
			T.build(src)

///////////////////////////////////////////////////////////////////////////////////////////////////

//Cordon

///////////////////////////////////////////////////////////////////////////////////////////////////

/turf/cordon
	name = "CORDON"
	icon = 'icons/map-editing/mapeditor.dmi'
	icon_state = "cordonturf"
	fullbright = 1
	invisibility = 101
	explosion_resistance = 999999
	density = 1
	opacity = 1

	Enter()
		return 0 // nope

	process_cell()
		return

//-------------An assortment of random miscellaneous turf definitions below

/turf/aprilfools/grass
	name = "grass"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "grass"
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED

/turf/aprilfools/dirt
	name = "dirt"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "sand"

/turf/aprilfools/brick_wall
	name = "brick wall"
	icon = 'icons/misc/aprilfools.dmi'
	icon_state = "brick_wall"
	opacity = 1
	density = 1
	pathable = 0
	var/d_state = 0

/turf/aprilfools/floor/concrete_floor
	name = "concrete floor"
	icon = 'icons/misc/aprilfools.dmi'
	icon_state = "concrete"

/turf/aprilfools/grass
	name = "grass"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "grass"
	opacity = 0
	density = 0

/turf/aprilfools/dirt
	name = "dirt"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "sand"
	opacity = 0
	density = 0

/turf/wall/wooden
	icon_state = "wooden"

/turf/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	text = "<font color=#aaa>."
	plane = PLANE_FLOOR
	stops_space_move = 1
	mat_appearances_to_ignore = list("steel")


/turf/wall
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	//IDK where the icon_state is set anymore but this sprite is _old_
	//icon_state = "riveted"
	opacity = 1
	text = "<font color=#aaa>#"
	density = 1
	pathable = 0
	turf_flags = ALWAYS_SOLID_FLUID
#ifndef IN_MAP_EDITOR // display disposal pipes etc. above walls in map editors
	plane = PLANE_WALL
#else
	plane = PLANE_FLOOR
#endif
	stops_space_move = 1

/turf/wall/solidcolor
	name = "invisible solid turf"
	desc = "A solid... nothing? Is that even a thing?"
	icon = 'icons/turf/walls.dmi'
	icon_state = "white"
	plane = PLANE_LIGHTING + 1
	mouse_opacity = 0
	fullbright = 1

/turf/wall/solidcolor/white
	icon_state = "white"

/turf/wall/solidcolor/black
	icon_state = "black"

/turf/wall/other
	icon_state = "r_wall"

/turf/wall/wooden
	icon_state = "wooden"

/turf/bombvr
	name = "Virtual Floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "vrfloor"

/turf/floor/carpet
	name = "carpet"
	icon = 'icons/turf/carpet.dmi'
	icon_state = "red1"

/turf/wall/bombvr
	name = "Virtual Wall"
	icon = 'icons/turf/floors.dmi'
	icon_state = "vrwall"

//vr shit
/turf/wall/virtual
	name = "virtual wall"
	desc = "A state of the art computer-generated image of a wall."
	icon_state = "wallVR"

	light
		icon_state = "wallVR-light"

/turf/wall/virtual/reinforced
	name = "reinforced virtual wall"
	desc = "...Or is that virtual reinforced wall?"
	icon_state = "r_wallVR"

	light
		icon_state = "r_wallVR-light"

/turf/wall/virtual/barrier
	name = "virtual barrier"
	desc = "Some kind of force field?"
	icon_state = "barrierVR"

//Vr turf is a jerk and pretends to be broken.
/turf/bombvr/ex_act(severity)
	switch(severity)
		if(OLD_EX_SEVERITY_1)
			src.icon_state = "vrspace"
		if(OLD_EX_SEVERITY_2)
			switch(pick(1;75,2))
				if(1)
					src.icon_state = "vrspace"
				if(2)
					if(prob(80))
						src.icon_state = "vrplating"

		if(OLD_EX_SEVERITY_3)
			if (prob(50))
				src.icon_state = "vrplating"
	return

/turf/wall/bombvr/ex_act(severity)
	switch(severity)
		if(OLD_EX_SEVERITY_1)
			opacity = 0
			set_density(0)
			src.icon_state = "vrspace"
		if(OLD_EX_SEVERITY_2)
			switch(pick(1;75,2))
				if(1)
					opacity = 0
					set_density(0)
					src.icon_state = "vrspace"
				if(2)
					if(prob(80))
						opacity = 0
						set_density(0)
						src.icon_state = "vrplating"

		if(OLD_EX_SEVERITY_3)
			if (prob(50))
				src.icon_state = "vrwallbroken"
				opacity = 0
	return



////////////////////////////////////////////////

//stuff ripped out of keelinsstuff.dm
/turf/floor/pool
	name = "water"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "poolwaterfloor"

	New()
		..()
		src.set_dir(pick(NORTH,SOUTH))

/turf/pool/no_animate
	name = "pool floor"
	icon = 'icons/obj/fluid.dmi'
	icon_state = "poolwaterfloor"

	New()
		..()
		src.set_dir(pick(NORTH,SOUTH))
/turf/pool
	name = "water"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "poolwaterfloor"

	New()
		..()
		src.set_dir(pick(NORTH,SOUTH))

/turf/pool/no_animate
	name = "pool floor"
	icon = 'icons/obj/fluid.dmi'
	icon_state = "poolwaterfloor"

	New()
		..()
		src.set_dir(pick(NORTH,SOUTH))

/turf/nicegrass
	name = "grass"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "grass"

/turf/nicegrass/random
	New()
		..()
		src.set_dir(pick(cardinal))

/turf/nicegrass
	name = "grass"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "grass"

/turf/nicegrass/random
	New()
		..()
		src.set_dir(pick(cardinal))


/turf/floor/ballpit
	name = "ball pit"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "ballpitfloor"

/turf/floor/concrete
	name = "concrete floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "concrete"

/turf/wall/griffening
	icon = 'icons/misc/griffening/area_wall.dmi'
	icon_state = null
	density = 1
	opacity = 0
	name = "wall"
	desc = "A holographic projector wall."

/turf/floor/griffening
	icon = 'icons/misc/griffening/area_floor.dmi'
	icon_state = null
	opacity = 0
	name = "floor"
	desc = "A holographic projector floor."

/turf/null_hole
	name = "expedition chute"
	icon = 'icons/obj/machines/delivery.dmi'
	icon_state = "floorflush_o"

	Enter(atom/movable/mover, atom/forget)
		. = ..()
		mover.set_loc(null)
