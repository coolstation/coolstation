TYPEINFO(/datum/component/blacklight_visible)
	initialization_args = list(
		ARG_INFO("glow_image", "image", "An image that glows on this atom in blacklight.", null),
	)

/datum/component/blacklight_visible
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/image/glow_image
	var/atom/parent_atom

/datum/component/blacklight_visible/Initialize(var/glow_image)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	src.parent_atom = parent
	src.glow_image = glow_image ? glow_image : new /image(parent_atom.icon, parent_atom.icon_state)
	src.glow_image.layer = parent_atom.layer + 0.01
	src.glow_image.plane = PLANE_SELFILLUM
	if(ismovable(parent_atom))
		RegisterSignal(parent_atom, COMSIG_MOVABLE_MOVED, PROC_REF(check_blacklight))
	src.process()

/datum/component/blacklight_visible/proc/process()
	if(parent_atom)
		src.check_blacklight()
		SPAWN_DBG(3 SECONDS)
			src.process()
	else
		qdel(src)

/datum/component/blacklight_visible/proc/check_blacklight()
	var/turf/T = get_turf(parent_atom)
	var/blacklight_level = T.turf_persistent.RL_LumR * 3 + T.turf_persistent.RL_LumB * 4 - T.turf_persistent.RL_LumG * 10
	src.glow_image.alpha = blacklight_level > 0.05 ? min(blacklight_level * 255, 255) : 0
	parent_atom.UpdateOverlays(src.glow_image,"blacklight_glow")

/datum/component/blacklight_visible/UnregisterFromParent()
	parent_atom.UpdateOverlays(null, "blacklight_glow")
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	. = ..()

/datum/component/blacklight_visible/disposing()
	src.glow_image = null
	. = ..()
