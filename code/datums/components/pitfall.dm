/**
 * These are ALL TURFS. They should STAY TURFS.
 * similar but not quite the same as /datum/component/teleport_on_enter
 **/

ABSTRACT_TYPE(/datum/component/pitfall)
/// A component for turfs which make movable atoms "fall down a pit"
/datum/component/pitfall
	/// the maximum amount of brute damage applied. This is used in random_brute_damage()
	var/BruteDamageMax = 0
	/// Can anchored movables fall down this pit?
	var/AnchoredAllowed = TRUE
	/// How long it takes for a thing to fall into the pit. 0 is instant, but usually you'd have a couple deciseconds where something can be flung across. Should use time defines.
	var/HangTime = 0.3 SECONDS
	/// How long it takes to plummet down as an animation
	var/FallTime = 1.2 SECONDS
	/// The smallest to make someone who falls as a scalar, ideally correlated with FallTime but if it's really funny you don't have to
	var/DepthScale = 0.3

	Initialize(BruteDamageMax = 50, AnchoredAllowed = TRUE, HangTime = 0.3 SECONDS, FallTime = 1.2 SECONDS, DepthScale = 0.3)
		. = ..()
		if (!istype(src.parent, /turf))
			return COMPONENT_INCOMPATIBLE
		RegisterSignal(src.parent, COMSIG_ATOM_ENTERED, PROC_REF(start_fall))
		RegisterSignal(src.parent, COMSIG_TURF_LANDIN_THROWN, PROC_REF(start_fall))
		RegisterSignal(src.parent, COMSIG_ATTACKBY, PROC_REF(update_targets))
		RegisterSignal(src.parent, COMSIG_TURF_REPLACED, PROC_REF(RemoveComponent))
		src.BruteDamageMax	= BruteDamageMax
		src.AnchoredAllowed = AnchoredAllowed
		src.HangTime		= HangTime
		src.FallTime		= FallTime
		src.DepthScale		= DepthScale

	UnregisterFromParent()
		. = ..()
		UnregisterSignal(src.parent, COMSIG_ATOM_ENTERED)
		UnregisterSignal(src.parent, COMSIG_TURF_LANDIN_THROWN)
		UnregisterSignal(src.parent, COMSIG_ATTACKBY)
		UnregisterSignal(src.parent, COMSIG_TURF_REPLACED)

	/// returns the .parent but typecasted as a turf
	proc/typecasted_parent()
		RETURN_TYPE(/turf)
		. = src.parent

	/// updates targets for area/coordinate targeting. is overridden added to in child types.
	proc/update_targets()
		return

	/// called when movable atom AM enters a pitfall turf. Mainly checks.
	proc/start_fall(var/signalsender, var/atom/movable/AM)
		if (!istype(AM, /atom/movable) || istype(AM, /obj/projectile))
			return
		if (AM.throwing) // throw em on over, why dont ya
			return
		if (AM.event_handler_flags & IMMUNE_PITFALL)
			return
		if (AM.flags & TECHNICAL_ATOM || istype(AM, /obj/blob)) //we can do this better (except the blob one, RIP)
			return
		if (AM.anchored > src.AnchoredAllowed || (locate(/obj/lattice) in src.parent) || (locate(/obj/grille/catwalk) in src.parent))
			return
		if (ismob(AM))
			if (ishuman(AM) && src.typecasted_parent().active_liquid?.last_depth_level >= 3) // TO DO: make jetpacks just apply PROB_ATOM_FLOATING
				var/mob/living/carbon/human/H = AM
				if (H.back && H.back.c_flags & IS_JETPACK)
					if (istype(H.back, /obj/item/tank/jetpack)) //currently unnecessary but what if we have IS_JETPACK on clothing items that are not back-wear later on?
						var/obj/item/tank/jetpack/J = H.back
						if(J.allow_thrust(0.01, H))
							return
			if (isliving(AM))
				var/mob/living/peep = AM
				if (!ON_COOLDOWN(AM, "re-swim", 0.5 SECONDS)) //Try swimming, but not if they've just stopped (for a stun or whatever)
					peep.attempt_swim() //should do nothing if they're already swimming I think?
			var/mob/M = AM
			if (HAS_MOB_PROPERTY(M,PROP_ATOM_FLOATING))
				return
			if (M.client?.flying || isobserver(AM) || isintangible(AM) || istype(AM, /mob/wraith))
				return

		return_if_overlay_or_effect(AM)

		// if the fall has coyote time, then delay it
		if (src.HangTime)
			SPAWN_DBG(src.HangTime)
				if (!QDELETED(AM))
					var/datum/component/pitfall/pitfall = AM.loc.GetComponent(/datum/component/pitfall)
					pitfall?.try_fall(signalsender, AM)
		else
			src.try_fall(signalsender, AM)

	/// called when it's time for movable atom AM to actually fall into the pit
	proc/try_fall(var/signalsender, var/atom/movable/AM)
		SHOULD_CALL_PARENT(TRUE)
		return TRUE
		// child procs will then use fall_to after calling this

	/// a proc that makes a movable atom 'A' fall from 'src.typecasted_parent()' to 'T' with a maximum of 'brutedamage' brute damage
	proc/fall_to(var/turf/T, var/atom/movable/AM, var/brutedamage = 50)
		SHOULD_NOT_OVERRIDE(TRUE)
		if(istype(AM, /obj/overlay) || AM.anchored == 2)
			return
		#ifdef CHECK_MORE_RUNTIMES
		if(current_state <= GAME_STATE_WORLD_NEW)
			CRASH("[identify_object(AM)] fell into [src.typecasted_parent()] at [src.typecasted_parent().x],[src.typecasted_parent().y],[src.typecasted_parent().z] ([src.typecasted_parent().loc] [src.typecasted_parent().loc.type]) during world initialization")
		#endif
		src.typecasted_parent().visible_message(SPAN_ALERT("[AM] falls into [src.typecasted_parent()]!"))
		if(src.FallTime)
			animate_fall(AM,src.FallTime,src.DepthScale)
			var/old_anchored = AM.anchored
			var/old_density = AM.density
			var/mob/M
			if(ismob(AM))
				M = AM
				if(M.mind && M.mind.assigned_role == "Clown")
					playsound(M, "sound/effects/slidewhistlefall.ogg", 50, 0)
#ifdef DATALOGGER
					game_stats.Increment("clownabuse")
#endif
				M.emote("scream")
				APPLY_MOB_PROPERTY(M, PROP_CANTMOVE, src)
			AM.anchored = 1
			AM.density = 0
			SPAWN_DBG(src.FallTime)
				if (!QDELETED(AM))
					if(M)
						REMOVE_MOB_PROPERTY(M, PROP_CANTMOVE, src)
					AM.anchored = old_anchored
					AM.density = old_density
					src.actually_fall(T, AM, brutedamage)
		else
			src.actually_fall(T, AM, brutedamage)

	proc/actually_fall(var/turf/T, var/atom/movable/AM, var/brutedamage = 50)
		if (isturf(T))
			if (ismob(AM))
				var/mob/M = AM
				var/safe = FALSE
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					if(H.shoes && (H.shoes.c_flags & SAFE_FALL))
						safe = TRUE
					if(H.wear_suit && (H.wear_suit.c_flags & SAFE_FALL))
						safe = TRUE
					if (H.back && (H.back.c_flags & IS_JETPACK))
						safe = TRUE
				if(safe)
					M.visible_message("<span class='notice'>[AM] lands gently on the ground.</span>")
				else
					random_brute_damage(M, brutedamage)
					if (brutedamage >= 50)
						M.changeStatus("paralysis", 7 SECONDS)
					else if (brutedamage >= 30)
						M.changeStatus("stunned", 10 SECONDS)
					else if (brutedamage >= 20)
						M.changeStatus("weakened", 5 SECONDS)
					else
						M.changeStatus("weakened", 2 SECONDS)
					playsound(M.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 75, 1)
					#ifdef DATALOGGER
					game_stats.Increment("workplacesafety")
					#endif
			AM.set_loc(T)
			AM.event_handler_flags &= ~IMMUNE_PITFALL
			return

// ====================== SUBTYPES OF PITFALL ======================

TYPEINFO(/datum/component/pitfall/target_landmark)
	initialization_args = list(
		ARG_INFO("BruteDamageMax", "num", "The maximum amount of random brute damage applied by the fall.", 0),
		ARG_INFO("AnchoredAllowed", "boolean", "Can anchored movables fall down this pit?", TRUE),
		ARG_INFO("HangTime", "num", "How long it takes for a thing to fall into the pit.", 0.3 SECONDS),
		ARG_INFO("FallTime", "num", "How long it takes for a thing to animate falling down the pit.", 1.2 SECONDS),
		ARG_INFO("DepthScale", "num", "A scalar for how small FallTime, if any, makes them.", 0.3),
		ARG_INFO("TargetLandmark", "text", "The landmark that the fall sends you to.", "")
	)

/// a pitfall that targets a pitfall landmark
/datum/component/pitfall/target_landmark
	/// The landmark that the fall sends you to. Should be a landmark define.
	var/TargetLandmark = ""

	Initialize(BruteDamageMax = 50, AnchoredAllowed = TRUE, HangTime = 0.3 SECONDS, FallTime = 1.2 SECONDS, DepthScale = 0.3, TargetLandmark = "")
		..()
		src.TargetLandmark = TargetLandmark
		if (!src.TargetLandmark)
			return COMPONENT_INCOMPATIBLE

	try_fall(signalsender, var/atom/movable/AM)
		if (..())
			src.fall_to(pick_landmark(src.TargetLandmark), AM, src.BruteDamageMax)

TYPEINFO(/datum/component/pitfall/target_area)
	initialization_args = list(
		ARG_INFO("BruteDamageMax", "num", "The maximum amount of random brute damage applied by the fall.", 0),
		ARG_INFO("AnchoredAllowed", "boolean", "Can anchored movables fall down this pit?", TRUE),
		ARG_INFO("HangTime", "num", "How long it takes for a thing to fall into the pit.", 0.3 SECONDS),
		ARG_INFO("FallTime", "num", "How long it takes for a thing to animate falling down the pit.", 1.2 SECONDS),
		ARG_INFO("DepthScale", "num", "A scalar for how small FallTime, if any, makes them.", 0.3),
		ARG_INFO("TargetArea", "num", "The area typepath that the target falls into. If null, then it drops onto the same coordinates.", null)
	)

/// a pitfall that targets an area
/datum/component/pitfall/target_area
	/// The area path that the target falls into. For area targeting
	var/TargetArea = null

	Initialize(BruteDamageMax = 50, AnchoredAllowed = TRUE, HangTime = 0.3 SECONDS, FallTime = 1.2 SECONDS, DepthScale = 0.3, TargetArea = null)
		..()
		src.TargetArea = TargetArea
		if (!src.TargetArea || !ispath(src.TargetArea, /area))
			return COMPONENT_INCOMPATIBLE

	try_fall(signalsender, var/atom/movable/AM)
		if (..())
			src.fall_to(pick(get_area_turfs(src.TargetArea)), AM, src.BruteDamageMax)

TYPEINFO(/datum/component/pitfall/target_coordinates)
	initialization_args = list(
		ARG_INFO("BruteDamageMax", "num", "The maximum amount of random brute damage applied by the fall.", 0),
		ARG_INFO("AnchoredAllowed", "boolean", "Can anchored movables fall down this pit?", TRUE),
		ARG_INFO("HangTime", "num", "How long it takes for a thing to fall into the pit.", 0.3 SECONDS),
		ARG_INFO("FallTime", "num", "How long it takes for a thing to animate falling down the pit.", 1.2 SECONDS),
		ARG_INFO("DepthScale", "num", "A scalar for how small FallTime, if any, makes them.", 0.3),
		ARG_INFO("TargetZ", "num", "The z level that the target falls into.", 5),
		ARG_INFO("LandingRange", "num", "If true, try to find a spot around the target to land on in range (x). Only for 'direct drops'.", 4),
	)

/// a pitfall which targets a coordinate. At the moment only supports targeting a z level and picking a range around current coordinates.
/datum/component/pitfall/target_coordinates
	/// a list of targets for the fall to pick from
	var/list/TargetList = list()
	/// The z level that the target falls into if not via area or landmark.
	var/TargetZ = 5
	/// If truthy, try to find a spot around the target to land on in range(x).
	var/LandingRange = 4

	Initialize(BruteDamageMax = 50, AnchoredAllowed = TRUE, HangTime = 0.3 SECONDS, FallTime = 1.2 SECONDS, DepthScale = 0.3, TargetZ = 5, LandingRange = 4)
		..()
		src.TargetZ			= TargetZ
		src.LandingRange	= LandingRange
		if (!src.TargetZ || !src.LandingRange)
			return COMPONENT_INCOMPATIBLE
		src.update_targets()

	try_fall(signalsender, var/atom/movable/AM)
		if (..())
			if (!src.TargetList || !length(src.TargetList))
				if(!src.update_targets())
					RemoveComponent()
					return
			src.fall_to(pick(src.TargetList), AM, src.BruteDamageMax)

	update_targets()
		src.TargetList = list()
		for(var/turf/space/T in range(src.LandingRange, locate(src.typecasted_parent().x, src.typecasted_parent().y , src.TargetZ)))
			src.TargetList += T
			return TRUE
		for(var/turf/floor/T in range(src.LandingRange, locate(src.typecasted_parent().x, src.typecasted_parent().y , src.TargetZ)))
			if(!T.density)
				src.TargetList += T
				return TRUE
		return FALSE
