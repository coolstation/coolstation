
/obj/machinery/floor_charger //too simple maybe? idk it does what it needs to
	name = "floor power socket"
	desc = "A recharger mounted to the floor. Only fits large power banks."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "floor_charger"
	anchored = ANCHORED
	mats = 30
	deconstruct_flags = DECON_SCREWDRIVER | DECON_MULTITOOL

	power_usage = 50
	var/active_drain = 500
	var/drain = 50

	var/obj/reagent_dispensers/powerbank/powerbank

	proc/pb_connect(var/obj/reagent_dispensers/powerbank/pb)
		powerbank = pb
		powerbank.anchored = ANCHORED
		//connect sound
	proc/pb_disconnect()
		powerbank.anchored = UNANCHORED
		powerbank = null
		//disconnect sound
	proc/pb_toggle_connect(var/obj/reagent_dispensers/powerbank/pb,var/mob/usr)
		if (powerbank)
			boutput(usr, "<span class='notice'>You disconnect [src] from the floor socket.</span>")
			pb_disconnect()
		else
			pb_connect(pb)
			boutput(usr, "<span class='notice'>You connect [src] to the floor socket.</span>")
		playsound(src,"sound/effects/pop.ogg",60,1)

	process(var/mult)
		if(src.powerbank)
			power_usage = active_drain * mult
			if(powerbank.charge >= powerbank.max_charge)
				//full, play sound or something
				powerbank.update_indicator()
			else
				powerbank.gain_charge(power_usage / 100)
				use_power(power_usage)
		else
			power_usage = drain * mult



