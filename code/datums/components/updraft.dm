TYPEINFO(/datum/component/updraft)
	initialization_args = list(
		ARG_INFO("DelayTime", "num", "How much time before something will float up the draft.", 0.5 SECONDS),
		ARG_INFO("RiseTimeBottom", "num", "How long it takes for a thing to animate rising to the bottom.", 2.8 SECONDS),
		ARG_INFO("RiseTimeTop", "num", "How long it takes for a thing to animate rising from the bottom.", 1.2 SECONDS),
		ARG_INFO("HeightScale", "num", "A scalar for how big RiseTimeBottom makes them.", 1.3),
		ARG_INFO("DepthScale", "num", "A scalar for how small RiseTimeTop makes them.", 0.3)
	)

/// A component for turfs which makes certain things, usually things like fire and smoke, rise up to another z-level
/// Usually, a pitfall creates this at its target. Nothing that can rise (event_handler_flag CAN_UPDRAFT) will ever pitfall.
/// This thing needs to have it's TargetTurf set, and pitfalls do that when they make it
/datum/component/updraft
	/// how long before something gets yoinked up
	var/DelayTime = 0.5 SECONDS
	/// How long it takes to float up as an animation at the bottom
	var/RiseTimeBottom = 2.8 SECONDS
	/// How long it takes to float up as an animation at the top
	var/RiseTimeTop = 1.2 SECONDS
	/// The size someone rising to the top ends at as a scalar
	var/HeightScale = 1.3
	/// The size someone rising from below starts at as a scalar
	var/DepthScale = 0.3
	/// Target turf to rise to
	var/turf/TargetTurf

	Initialize(var/DelayTime = 0.5 SECONDS, var/RiseTimeBottom = 2.8 SECONDS, var/RiseTimeTop = 1.2 SECONDS, var/HeightScale = 1.2 SECONDS,	var/HeightScale = 1.3, var/DepthScale = 0.3)
		. = ..()
		if (!istype(src.parent, /turf))
			return COMPONENT_INCOMPATIBLE
		src.DelayTime = DelayTime
		src.RiseTimeBottom = RiseTimeBottom
		src.RiseTimeTop = RiseTimeTop
		src.HeightScale = 1.3
		src.DepthScale = 0.3

	PostTransfer()
		if (!istype(src.parent, /turf))
			return COMPONENT_INCOMPATIBLE

	RegisterWithParent()
		. = ..()
		RegisterSignal(src.parent, COMSIG_ATOM_ENTERED, PROC_REF(attempt_rise))
		RegisterSignal(src.parent, COMSIG_TURF_REPLACED, PROC_REF(RemoveComponent))
		for(var/atom/movable/AM in src.parent)
			src.attempt_rise(AM,AM)

	UnregisterFromParent()
		. = ..()
		UnregisterSignal(src.parent, COMSIG_ATOM_ENTERED)
		UnregisterSignal(src.parent, COMSIG_TURF_REPLACED)

	/// checks if an atom can fall in.
	proc/test_rise(var/atom/movable/AM)
		if (AM.event_handler_flags & CAN_UPDRAFT)
			return TRUE
		return FALSE

	/// called when movable atom AM enters a pitfall turf.
	proc/attempt_rise(var/signalsender, var/atom/movable/AM)
		if(!src.test_rise(AM))
			return

		if(!(AM.event_handler_flags & IS_PITFALLING))
			AM.event_handler_flags |= IS_PITFALLING
			SPAWN_DBG(src.DelayTime)
				if (!QDELETED(AM))
					AM.event_handler_flags &= ~IS_PITFALLING
					animate_rise_bottom(AM,src.RiseTimeBottom,src.HeightScale)
					sleep(src.RiseTimeBottom)
					if (!QDELETED(AM))
						animate_rise_top(AM,src.RiseTimeTop,src.DepthScale)
						AM.set_loc(src.TargetTurf)
