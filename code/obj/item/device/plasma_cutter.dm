/obj/item/plasma_cutter
	name = "plasma cutter"
	desc = "An extremely bulky and dangerous device, this tool uses electricity from an attatched power store to superheat plasma and cut through nearly any material."
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
		var/turf/location = src.loc
		if(ismob(location))
			var/mob/M = location
			if (M.l_hand == src || M.r_hand = =src)
				location = M.loc
		if(istype(location,/turf))
			location.hotspot_expose(2000,5) //could go horribly wrong- a bit higher than the melting point of steel. Don't leave it on!
		if(prob(10))
			use_power(10)
			if(!get_power())
				active = 0

	attack_self(mob/user)
		. = ..()
		toggle_active()

	proc/toggle_active()
		if(!active && get_power())
			icon_state = "active"
			active = 1
			//boowap
			return 1
		else
			icon_state = "base"
			active = 0
			//boowump
			return 0

	proc/get_power()
		if(powerbank)
			return powerbank.charge

	proc/use_power(var/amount)
		amount = min(get_power(), amount)
		if(get_power() > 0)
			powerbank.lose_charge(amount)


	/proc/connect(var/obj/reagent_dispensers/powerbank/I)
		if(powerbank)
			powerbank = null
			//disconnect cable
		powerbank = I
		//play connection sound whatever
		//draw cable
		I.connected()
		return

