/datum/component/activate_trap_on_door_touch
	var/atom/parent

	Initialize()
		..()
		if(!istype(parent,/obj/machinery/door))
			CRASH("activate_trap_on_door_touch assigned to a non-door object")
		RegisterSignal(parent, COMSIG_MOB_DOORBUMP, /datum/component/activate_trap_on_door_touch/proc/on_bump_signal)
		RegisterSignal(parent, COMSIG_ATTACKBY, /datum/component/activate_trap_on_door_touch/proc/on_attack_signal)

	proc/on_bump_signal(var/mob/usr)
		parent.trap_triggered(usr)
	proc/on_attack_signal(_,var/mob/usr)
		parent.trap_triggered(usr)

