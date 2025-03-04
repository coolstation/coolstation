/**
 * MYLIE NOTE:
 * For some reason I'm still figuring out, if any component returns COMPONENT_INCOMPATIBLE during preloading, it will runtime forever.
 * What this means is if you start seeing runtimes about bad indexes and null parents, you may have a pitfall returning COMPONENT_INCOMPATIBLE.
 * The current reasons for this are: anything but a turf having a pitfall, or the children types not having their needed target specification.
 **/

// Use this to check if anything is mapped onto a pit when it shouldn't be
//#define CHECK_PITFALL_INITIALIZATION

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
		src.BruteDamageMax	= BruteDamageMax
		src.AnchoredAllowed = AnchoredAllowed
		src.HangTime		= HangTime
		src.FallTime		= FallTime
		src.DepthScale		= DepthScale

	PostTransfer()
		if (!istype(src.parent, /turf))
			return COMPONENT_INCOMPATIBLE

	RegisterWithParent()
		. = ..()
		RegisterSignal(src.parent, COMSIG_ATOM_ENTERED, PROC_REF(start_fall))
		RegisterSignal(src.parent, COMSIG_TURF_LANDIN_THROWN, PROC_REF(start_fall_no_coyote))
		RegisterSignal(src.parent, COMSIG_TURF_REPLACED, PROC_REF(RemoveComponent))
		for(var/atom/movable/AM in src.typecasted_parent())
			src.start_fall(AM,AM)

	UnregisterFromParent()
		. = ..()
		UnregisterSignal(src.parent, COMSIG_ATOM_ENTERED)
		UnregisterSignal(src.parent, COMSIG_TURF_LANDIN_THROWN)
		UnregisterSignal(src.parent, COMSIG_TURF_REPLACED)

	/// returns the .parent but typecasted as a turf
	proc/typecasted_parent()
		RETURN_TYPE(/turf)
		. = src.parent

	/// returns the turf to drop a movable AM to. Must be overridden by all children, or they will output to themself. Overriding could filter or deny ghosts passage.
	proc/get_turf_to_fall(var/atom/movable/AM)
		RETURN_TYPE(/turf)
		return src.parent

	/// checks if an atom can fall in.
	proc/test_fall(var/atom/movable/AM,var/no_thrown=FALSE)
		if (!istype(AM, /atom/movable) || istype(AM, /obj/projectile))
			return
		if(AM.event_handler_flags & IS_PITFALLING)
			return
		if(no_thrown && AM.throwing)
			return
		if (AM.flags & TECHNICAL_ATOM || istype(AM, /obj/blob)) //we can do this better (except the blob one, RIP)
			return
		if (AM.anchored > src.AnchoredAllowed || (locate(/obj/lattice) in src.parent) || (locate(/obj/grille/catwalk) in src.parent))
			return
		if (ismob(AM))
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

		return TRUE

	/// called when movable atom AM enters a pitfall turf.
	proc/start_fall(var/signalsender, var/atom/movable/AM)
		if(!src.test_fall(AM,TRUE))
			return

		AM.event_handler_flags |= IS_PITFALLING

		// if the fall has coyote time, then delay it
		if (src.HangTime)
			if(!(AM.event_handler_flags & IN_COYOTE_TIME)) // maybe refactor this into a property after converting mob_prop to atom_prop
				AM.event_handler_flags |= IN_COYOTE_TIME
				SPAWN_DBG(src.HangTime)
					if (!QDELETED(AM))
						AM.event_handler_flags &= ~IN_COYOTE_TIME
						var/datum/component/pitfall/pit = AM.loc.GetComponent(/datum/component/pitfall)
						if(!pit || AM.anchored > pit.AnchoredAllowed || (locate(/obj/lattice) in AM.loc) || (locate(/obj/grille/catwalk) in AM.loc))
							return
						if (ismob(AM))
							var/mob/M = AM
							if (HAS_MOB_PROPERTY(M,PROP_ATOM_FLOATING))
								return
						pit.fall_to(src.get_turf_to_fall(AM), AM, src.BruteDamageMax)
		else
			src.fall_to(src.get_turf_to_fall(AM), AM, src.BruteDamageMax)

	/// called when movable atom AM lands from a throw into a pitfall turf.
	proc/start_fall_no_coyote(var/signalsender, var/atom/movable/AM)
		if(!src.test_fall(AM,FALSE))
			return 0

		AM.event_handler_flags |= IS_PITFALLING
		AM.event_handler_flags &= ~IN_COYOTE_TIME

		src.fall_to(src.get_turf_to_fall(AM), AM, src.BruteDamageMax)
		return 1

	/// a proc that makes a movable atom 'AM' fall from 'src.typecasted_parent()' to 'T' with a maximum of 'brutedamage' brute damage
	proc/fall_to(var/turf/T, var/atom/movable/AM, var/brutedamage = 50)
		if(istype(AM, /obj/overlay) || AM.anchored == 2)
			return
		#ifdef CHECK_PITFALL_INITIALIZATION
		if(current_state <= GAME_STATE_WORLD_NEW)
			CRASH("[identify_object(AM)] fell into [src.typecasted_parent()] at [src.typecasted_parent().x],[src.typecasted_parent().y],[src.typecasted_parent().z] ([src.typecasted_parent().loc] [src.typecasted_parent().loc.type]) during world initialization")
		#endif
		src.typecasted_parent().visible_message(SPAN_ALERT("[AM] falls into [src.typecasted_parent()]!"))
		if(src.FallTime)
			animate_fall(AM,src.FallTime,src.DepthScale)
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
			var/old_density = AM.density // dont block other fools from falling in
			AM.density = 0
			SPAWN_DBG(src.FallTime)
				if (!QDELETED(AM))
					if(M)
						REMOVE_MOB_PROPERTY(M, PROP_CANTMOVE, src)
					AM.density = old_density
					src.actually_fall(T, AM, brutedamage)
		else
			src.actually_fall(T, AM, brutedamage)

	proc/actually_fall(var/turf/T, var/atom/movable/AM, var/brutedamage = 50)
		if (isturf(T))
			var/datum/component/pitfall/next_pit = T.GetComponent(/datum/component/pitfall)
			var/keep_falling = TRUE
			if(!next_pit || AM.anchored > next_pit.AnchoredAllowed || (locate(/obj/lattice) in next_pit.typecasted_parent()) || (locate(/obj/grille/catwalk) in next_pit.typecasted_parent()))
				keep_falling = FALSE
			else if(next_pit == src && (src.FallTime < 0.3 SECONDS || brutedamage > 1500)) // a couple limits on infinite falls, for server's sake
				keep_falling = FALSE
			AM.set_loc(T)
			if (ismob(AM))
				var/mob/M = AM
				var/safe = FALSE
				if (HAS_MOB_PROPERTY(M,PROP_ATOM_FLOATING))
					keep_falling = FALSE
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					if(H.shoes && (H.shoes.c_flags & SAFE_FALL))
						safe = TRUE
					if(H.wear_suit && (H.wear_suit.c_flags & SAFE_FALL))
						safe = TRUE
					if (H.back && (H.back.c_flags & IS_JETPACK) && HAS_MOB_PROPERTY(M,PROP_ATOM_FLOATING))
						safe = TRUE
				if(safe)
					M.visible_message("<span class='notice'>[AM] [keep_falling ? "glides down through" : "lands gently on"] [T].</span>","<span class='notice'>You [keep_falling ? "glide down through" : "land gently on"] [T].</span>")
				else
					var/did_hit_mob
					for(var/atom/landed_on in T)
						if(landed_on == AM)
							continue
						if(landed_on.density)
							AM.throw_impact(landed_on, null)
						if(isliving(landed_on))
							var/mob/living/L = landed_on
							M.show_message("<span class='combat'>You smash into [L] as you land!</span>")
							L.visible_message("<span class='combat'>[M] crashes down onto [L]!</span>", "<span class='combat'>[M] crashes down onto you!</span>")
							did_hit_mob = TRUE
							random_brute_damage(L, brutedamage / 4)
							if (brutedamage >= 20)
								L.changeStatus("weakened", 2 SECONDS)
					if(brutedamage && !keep_falling)
						random_brute_damage(M, brutedamage)
						if (brutedamage >= 1500)
							for(var/mob/living/L in T)
								random_brute_damage(L,40)
							M.visible_message("<span class='alert bold'>[M] splatters onto [T] at mach fuck!</span>", "<span class='alert bold'>You splatter onto [T] at mach fuck!</span>")
							M.gib()
							return
						else if (brutedamage >= 50)
							M.changeStatus("paralysis", 7 SECONDS)
						else if (brutedamage >= 30)
							M.changeStatus("stunned", 10 SECONDS)
						else if (brutedamage >= 20)
							M.changeStatus("weakened", 5 SECONDS)
						else if (brutedamage >= 5)
							M.changeStatus("weakened", 2 SECONDS)
						M.force_laydown_standup()
						playsound(M.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 75, 1)
						#ifdef DATALOGGER
						game_stats.Increment("workplacesafety")
						#endif
					if(!did_hit_mob)
						M.visible_message("<span class='alert'>[M] [keep_falling ? "tumbles through" : "slams down into"] [T]!</span>", "<span class='alert'>You [keep_falling ? "tumble through" : "slam down into"] [T]!</span>")
			else
				for(var/mob/living/L in T)
					L.visible_message("<span class='alert'>[AM] crashes down onto [L]!</span>", "<span class='alert'>[AM] crashes down onto you!</span>")
					AM.throw_impact(L, null)
			T.hitby(AM, null)
			AM.throwing = 0
			animate(AM)
			if(keep_falling)
				next_pit.fall_to(next_pit.get_turf_to_fall(AM),AM,next_pit.BruteDamageMax + brutedamage) // lets just be evil
			else
				AM.event_handler_flags &= ~IS_PITFALLING
			return
		else
			AM.event_handler_flags &= ~IS_PITFALLING
			if(ismob(AM))
				var/mob/M = AM
				M.show_message("<span class='alert bold'>That pit is MAJORLY fucked up! Tell a coder!</span>")

// ====================== SUBTYPES OF PITFALL ======================

TYPEINFO(/datum/component/pitfall/target_landmark)
	initialization_args = list(
		ARG_INFO("BruteDamageMax", "num", "The maximum amount of random brute damage applied by the fall.", 0),
		ARG_INFO("AnchoredAllowed", "boolean", "Can anchored movables fall down this pit?", TRUE),
		ARG_INFO("HangTime", "num", "How much coyote time things get for the pit.", 0.3 SECONDS),
		ARG_INFO("FallTime", "num", "How long it takes for a thing to animate falling down the pit.", 1.2 SECONDS),
		ARG_INFO("DepthScale", "num", "A scalar for how small FallTime, if any, makes them.", 0.3),
		ARG_INFO("TargetLandmark", "text", "The landmark that the fall sends you to.", "")
	)

/// a pitfall that targets a pitfall landmark
/datum/component/pitfall/target_landmark
	/// The landmark that the fall sends you to. Should be a landmark define.
	var/TargetLandmark = ""

	Initialize(BruteDamageMax = 50, AnchoredAllowed = TRUE, HangTime = 0.3 SECONDS, FallTime = 1.2 SECONDS, DepthScale = 0.3, TargetLandmark = "")
		if (!TargetLandmark)
			return COMPONENT_INCOMPATIBLE
		..()
		src.TargetLandmark = TargetLandmark

	get_turf_to_fall(atom/movable/AM)
		return pick_landmark(src.TargetLandmark)

TYPEINFO(/datum/component/pitfall/target_area)
	initialization_args = list(
		ARG_INFO("BruteDamageMax", "num", "The maximum amount of random brute damage applied by the fall.", 0),
		ARG_INFO("AnchoredAllowed", "boolean", "Can anchored movables fall down this pit?", TRUE),
		ARG_INFO("HangTime", "num", "How much coyote time things get for the pit.", 0.3 SECONDS),
		ARG_INFO("FallTime", "num", "How long it takes for a thing to animate falling down the pit.", 1.2 SECONDS),
		ARG_INFO("DepthScale", "num", "A scalar for how small FallTime, if any, makes them.", 0.3),
		ARG_INFO("TargetArea", "num", "The area typepath that the target falls into. If null, then it drops onto the same coordinates.", null)
	)

/// a pitfall that targets an area
/datum/component/pitfall/target_area
	/// The area path that the target falls into. For area targeting
	var/TargetArea = null

	Initialize(BruteDamageMax = 50, AnchoredAllowed = TRUE, HangTime = 0.3 SECONDS, FallTime = 1.2 SECONDS, DepthScale = 0.3, TargetArea = null)
		if (!TargetArea || !ispath(TargetArea, /area))
			return COMPONENT_INCOMPATIBLE
		..()
		src.TargetArea = TargetArea

	get_turf_to_fall(atom/movable/AM)
		return pick(get_area_turfs(src.TargetArea))

TYPEINFO(/datum/component/pitfall/target_coordinates)
	initialization_args = list(
		ARG_INFO("BruteDamageMax", "num", "The maximum amount of random brute damage applied by the fall.", 0),
		ARG_INFO("AnchoredAllowed", "num", "Can anchored movables fall down this pit?", TRUE),
		ARG_INFO("HangTime", "num", "How much coyote time things get for the pit.", 0.3 SECONDS),
		ARG_INFO("FallTime", "num", "How long it takes for a thing to animate falling down the pit.", 1.2 SECONDS),
		ARG_INFO("DepthScale", "num", "A scalar for how small FallTime, if any, makes them.", 0.3),
		ARG_INFO("OffsetX", "num", "The X offset added to the pitfall turf's X.", 0),
		ARG_INFO("OffsetY", "num", "The Y offset added to the pitfall turf's Y.", 0),
		ARG_INFO("TargetZ", "num", "The Z level that the target falls into. Must be set.", 0),
		ARG_INFO("LandingRange", "num", "Try to find a spot around the target to land on in range (x).", 3),
	)

/// a pitfall which targets a coordinate. At the moment only supports targeting a z level and picking a range around current coordinates.
/datum/component/pitfall/target_coordinates
	/// a list of targets for the fall to pick from
	var/list/TargetList = list()
	/// The X offset added to the pitfall turfs X to find the target.
	var/OffsetX = 0
	/// The Y offset added to the pitfall turfs Y to find the target.
	var/OffsetY = 0
	/// The Z level that the target falls into. Must be set, to prevent accidental space-elevator-shafts.
	var/TargetZ = 0
	/// Try to find a non-dense spot around the target to land on in range(x).
	var/LandingRange = 3

	Initialize(BruteDamageMax = 50, AnchoredAllowed = TRUE, HangTime = 0.3 SECONDS, FallTime = 1.2 SECONDS, DepthScale = 0.3, OffsetX = 0, OffsetY = 0, TargetZ = 0, LandingRange = 3)
		if (!TargetZ)
			return COMPONENT_INCOMPATIBLE
		..()
		src.OffsetX			= OffsetX
		src.OffsetY			= OffsetY
		src.TargetZ			= TargetZ
		src.LandingRange	= LandingRange
		src.update_targets()

	get_turf_to_fall(atom/movable/AM)
		return pick(src.TargetList)

	proc/update_targets() // prefers non-dense turf, only chooses the closest turf. If you want multiple possibilities, make a child.
		src.TargetList = list()
		if(src.LandingRange)
			for(var/turf/T in range(src.LandingRange, locate(src.typecasted_parent().x + src.OffsetX, src.typecasted_parent().y + src.OffsetY, src.TargetZ)))
				if(!T.density)
					src.TargetList += T
					return TRUE
		src.TargetList += locate(src.typecasted_parent().x + src.OffsetX, src.typecasted_parent().y + src.OffsetY, src.TargetZ)
		if(!length(src.TargetList))
			return FALSE
		return TRUE
