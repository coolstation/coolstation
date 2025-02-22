TYPEINFO(/datum/component/blacklight_visible)
	initialization_args = list(
		ARG_INFO("glow_icon", "string", "The icon of the glow.", null),
		ARG_INFO("glow_icon_state", "string", "The icon state of the glow.", null),
	)

/datum/component/blacklight_visible
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/image/glow
	var/atom/movable/parent_AM

/datum/component/blacklight_visible/Initialize(var/glow_icon, var/glow_icon_state)
	if(!istype(parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	src.parent_AM = parent
	src.glow = new /image(glow_icon ? glow_icon : parent_AM.icon, glow_icon_state ? glow_icon_state : parent_AM.icon_state)
	src.glow.layer = parent_AM.layer + 1
	src.glow.plane = PLANE_SELFILLUM
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(check_blacklight))
	src.process()

/datum/component/blacklight_visible/proc/process()
	src.check_blacklight()
	SPAWN_DBG(1 SECOND)
		src.process()

/datum/component/blacklight_visible/proc/check_blacklight()
	if(!parent)
		return
	var/turf/T = get_turf(parent)
	var/blacklight_level = T.turf_persistent.RL_LumR * 3 + T.turf_persistent.RL_LumB * 4 - T.turf_persistent.RL_LumG * 10
	src.glow.alpha = blacklight_level > 0.05 ? min(blacklight_level * 255, 255) : 0
	parent_AM.UpdateOverlays(src.glow,"blacklight_glow")

/datum/component/blacklight_visible/UnregisterFromParent()
	src.glow = null
	src.parent_AM.UpdateOverlays(null, "blacklight_glow")
	src.parent_AM = null
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	. = ..()
