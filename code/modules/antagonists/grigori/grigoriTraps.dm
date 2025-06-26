/obj/item/device/grigori_trap_hand
	name = "inhand grigori trap"
	icon_state = "placeholder"
	var/trigger_type = null
	var/armed = FALSE
	var/trap_type = "default"
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
	trap_type = "chopper"
	desc = "A hidden blade that can be fastened to a door. When a victim tries to open the door, a blade will come from the door and chop a random limb off."

/obj/item/device/grigori_trap_hand/deploy(var/obj/target, var/mob/user)
	var/grigori_xp = 0
	switch(src.trigger_type)
	if("door_touch") //it will eventually make sense why I'm using a switch here
		make_door_handle_trap(target,src.trap_type)
		grigori_xp = rand(1,5)
		qdel(src)
	user.add_grigori_xp(grigori_xp)


/obj/machinery/grigori_trap
	name = "grigori trap"
	icon_state = "placeholder"
	desc = "abstract grigori trap. far out, man!"
	var/obj/linked_obj
	density = 0
	anchored = 1




