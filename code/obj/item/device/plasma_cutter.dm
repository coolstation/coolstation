/obj/item/plasma_cutter
	name = "plasma cutter"
	desc = "An extremely bulky and dangerous device, this tool uses electricity from an attatched power store to superheat plasma able cut through nearly any material."
	icon = 'icons/obj/items/plasmacutter.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "base"
	item_state = "cutter"
	opacity = 0
	density = 0

	var/obj/tank/emergency_plasma/tank
	var/obj/reagent_dispensers/powerbank/powerbank

	flags = FPRINT | TABLEPASS | CONDUCT
	force = 20.0
	throwforce = 20.0
	throw_speed = 1
	throw_range = 3
	w_class = W_CLASS_GIGANTIC
	m_amt = 50000 //?

	var/power_cut_wall = 3
	var/time_cut_wall = 3 SECONDS
	var/active = 0

	New()
		..()
		var/turf/T = get_turf(src)
		for(var/item/I in T)
			if(istype(I,/obj/reagent_dispensers/powerbank))
				connect(I)
	examine()
		. = ..()
		. += "The dial says there are [powerbank.value] PU left in the battery."

	process()
		if(!active)
			processing_items.Remove(src)
			return
		//come back to this later, weldingtool.dm

	attack_self(mob/user)
		. = ..()
		if(powerbank && powerbank.charge > 0)//check for plasma tank too
			icon_state = "active"
			active = 1
			//play sound




	/proc/connect(var/obj/reagent_dispensers/powerbank/I)
		if(powerbank)
			powerbank = null
			//disconnect cable
		powerbank = I
		//play connection sound whatever
		I.connected()
		return

