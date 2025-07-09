//i should make a parent for these probably, but i've already dug my grave(i'll do it once it all works, or maybe never because i'll forget)
//(if it's not done when you see this and think to yourself "i should fix this!!!" uhmmm)
//(don't!!!! i'll do it, just tell me! -klushy)
/datum/component/activate_trap_on_door_touch
	var/datum/grigori_trap/linked_trap
	Initialize(var/obj/linked_obj,var/datum/grigori_trap/trap)
		..()
		linked_trap = trap
		RegisterSignal(linked_obj, COMSIG_MOB_DOORBUMP, /datum/component/activate_trap_on_door_touch/proc/on_bump_signal)
		RegisterSignal(linked_obj, COMSIG_ATTACKBY, /datum/component/activate_trap_on_door_touch/proc/on_attack_signal)

	proc/on_bump_signal(_,var/mob/usr)
		linked_trap.trap_triggered(usr)
	proc/on_attack_signal(_,_,var/mob/usr)
		if(!istype(usr.equipped(), /obj/item))
			linked_trap.trap_triggered(usr)
		else
			linked_trap.attempt_disarm(usr,usr.equipped())

/datum/component/activate_trap_on_computer_touch
	var/datum/grigori_trap/linked_trap
	Initialize(var/obj/linked_obj,var/datum/grigori_trap/trap)
		..()
		linked_trap = trap
		RegisterSignal(linked_obj, COMSIG_ATTACKBY, /datum/component/activate_trap_on_computer_touch/proc/on_attack_signal)
	proc/on_attack_signal(_,_,var/mob/usr)
		if(!istype(usr.equipped(),/obj/item))
			linked_trap.trap_triggered(usr)
		else
			linked_trap.attempt_disarm(usr,usr.equipped())

/datum/component/activate_trap_on_chair_buckle

	var/datum/grigori_trap/linked_trap
	Initialize(var/obj/linked_obj,var/datum/grigori_trap/trap)
		..()
		linked_trap = trap
		RegisterSignal(linked_obj, COMSIG_MOVABLE_CHAIR_BUCKLE, /datum/component/activate_trap_on_chair_buckle/proc/on_buckle_signal)
		RegisterSignal(linked_obj, COMSIG_ATTACKBY, /datum/component/activate_trap_on_computer_touch/proc/on_attack_signal)

	proc/on_buckle_signal(_,var/mob/usr,var/obj/stool/chair) //taking the chair as an argument here in case we want some traps to break the chair or something
		linked_trap.trap_triggered(usr)

	proc/on_attack_signal(_,_,var/mob/usr)
		if(istype(usr.equipped(),/obj/item))
			linked_trap.attempt_disarm(usr,usr.equipped())



