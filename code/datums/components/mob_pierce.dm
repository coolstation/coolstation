/datum/component/gaseous_projectile

/datum/component/gaseous_projectile/Initialize()
	if(!istype(parent, /obj/projectile))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_PROJ_COLLIDE), .proc/update_pierces)

/datum/component/gaseous_projectile/proc/update_pierces(var/obj/projectile/P, var/atom/hit)
	if(!hit.opacity)
		return PROJ_ATOM_PASSTHROUGH

/datum/component/gaseous_projectile/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PROJ_COLLIDE)
	. = ..()
