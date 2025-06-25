/obj/item/device/grigori_trap_hand
	name = "grigori trap"
	icon_state = "placeholder"
	var/trigger_type = null
	var/trap_type = null
	var/armed = FALSE
	flags = USEDELAY
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


