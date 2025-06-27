/datum/component/activate_trap_on_door_touch
	var/datum/grigori_trap/linked_trap
	Initialize(var/obj/linked_obj,var/datum/grigori_trap/trap)
		..()
		linked_trap = trap
		RegisterSignal(linked_obj, COMSIG_MOB_DOORBUMP, /datum/component/activate_trap_on_door_touch/proc/on_bump_signal)
		RegisterSignal(linked_obj, COMSIG_ATTACKBY, /datum/component/activate_trap_on_door_touch/proc/on_attack_signal)

	proc/on_bump_signal(var/mob/usr)
		linked_trap.trap_triggered(usr)
	proc/on_attack_signal(_,var/mob/usr)
		linked_trap.trap_triggered(usr)

