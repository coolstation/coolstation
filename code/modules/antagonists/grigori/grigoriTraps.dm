/obj/item/device/grigori_trap_hand
	name = "inhand grigori trap"
	icon_state = "placeholder"
	var/trigger_type = null
	var/armed = FALSE
	var/trap_type = null
	var/item/trap_content
	flags = USEDELAY | TRAP_SPAWNER
	w_class = W_CLASS_BULKY
	item_state = "placeholder"
	desc = "abstract trap. Hand? !!!"

	attack_self(var/mob/user as mob)
		if(src.armed)
			boutput(user, "<span class='alert'>You disarm [src]</span>")
			src.disarm()
		else
			boutput(user, "<span class='alert'>You arm [src]. Click on a [trigger_type] to set the trap.</span>")
			src.arm()

	proc/arm()
		//play some sounds, animate the icon, mark armed to true
		src.armed = TRUE
	proc/disarm()
		//play some sounds, animate the icon, mark armed to false
		src.armed = FALSE

	proc/deploy(var/obj/target, var/mob/user)
		switch(src.trigger_type)
			if("door_touch")
				if(istype(target,/obj/machinery/door))
					new trap_type(target,trigger_type)
					qdel(src) //handle animations, sounds, bars, effects, and whatever else here

/obj/item/device/grigori_trap_hand/door_handle //for now just an abstract, but once custom traps are worked in, this will be used for custom traps
	name = "door control trap mechanism"
	icon_state = "placeholder"
	item_state = "placeholder"
	trigger_type = "door_touch"
	desc = "A door control trap trigger. This trigger attatches to a door, and is activated upon the user trying to open the door."

/obj/item/device/grigori_trap_hand/door_handle/chopper //a blade cuts a random limb off
	name = "hidden door blade trap"
	icon_state = "placeholder"
	item_state = "placeholder"
	trap_type = /datum/grigori_trap/chopper
	desc = "A hidden blade that can be fastened to a door. When a victim tries to open the door, a blade will come from the door and chop a random limb off."

/datum/grigori_trap
	var/obj/linked_obj

	New(var/obj/target,var/trigger_type)
		..()
		linked_obj = target

		switch(trigger_type)
			if("door_touch")
				AddComponent(/datum/component/activate_trap_on_door_touch,linked_obj,src)

	proc/trap_triggered(var/mob/victim)
		boutput(world, "<B>help</B>")


/datum/grigori_trap/chopper
	trap_triggered()
		boutput(world, "<B>the trap springs</B>")
		//do random chopping code here - have the trap be layerd ontop of whatever machine, and the linked object passes interactions from attackby to a proc here if the trap is present





