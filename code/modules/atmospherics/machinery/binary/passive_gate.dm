obj/machinery/atmospherics/binary/passive_gate
	//Tries to achieve target pressure at output (like a normal pump) except
	//	Uses no power but can not transfer gases from a low pressure area to a high pressure area
	icon = 'icons/obj/atmospherics/passive_gate.dmi'
	icon_state = "intact_off"
//
	name = "Passive gate"
	desc = "A one-way air valve that does not require power. Flow rate may be adjusted with tools."
	generic_decon_module = /obj/item/atmospherics/module/passive_gate

	var/on = 0
	var/target_pressure = ONE_ATMOSPHERE
	var/datum/pump_ui/ui

	initialize()
		..()
		ui = new/datum/pump_ui/passive_gate_ui(src)

	update_icon(state)
		if(state)
			flick("intact_[state]",src) //state is ton, toff, adjust (the t stands for turn hope this helps)
			return //this is meant to be called like the valve, after all: animate, sleep a sec, then open/close and update icon to finished state
		if(node1&&node2)
			icon_state = "intact_[on?("on"):("off")]"
		else
			if(node1)
				icon_state = "exposed_1_off"
			else if(node2)
				icon_state = "exposed_2_off"
			else
				icon_state = "exposed_3_off"
			on = 0

		return

	process()
		..()
		if(!on)
			return 0

		var/output_starting_pressure = MIXTURE_PRESSURE(air2)
		var/input_starting_pressure = MIXTURE_PRESSURE(air1)

		if(output_starting_pressure >= min(target_pressure,input_starting_pressure-10))
			//No need to pump gas if target is already reached or input pressure is too low
			//Need at least 10 KPa difference to overcome friction in the mechanism
			return 1

		//Calculate necessary moles to transfer using PV = nRT
		if((TOTAL_MOLES(air1) > 0) && (air1.temperature>0))
			var/pressure_delta = min(target_pressure - output_starting_pressure, (input_starting_pressure - output_starting_pressure)/2)
			//Can not have a pressure delta that would cause output_pressure > input_pressure

			var/transfer_moles = pressure_delta*air2.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = air1.remove(transfer_moles)
			air2.merge(removed)

			network1?.update = 1

			if(network2)
				network2.update = 1

	attack_ai(mob/user as mob)
		boutput(user, "This valve is manually controlled.")
		return

	attack_hand(mob/user as mob)
		if(src.node1 && src.node2) //only do this on a currently working valve
			src.update_icon(src.on ? "toff" : "ton") //spin it
			playsound(src.loc, "sound/effects/valve_creak.ogg", 50, 1)
			sleep(0.9 SECONDS)
			src.on = !src.on
			src.update_icon()
			playsound(src.loc, (src.on ? "sound/machines/hiss.ogg" : "sound/items/Screwdriver.ogg"), 50, 1)
		else
			boutput(user, "This valve isn't connected.")

obj/machinery/atmospherics/binary/passive_gate/attackby(obj/item/W, mob/user)
	if(ispulsingtool(W) || iswrenchingtool(W)) //pet peeve: why would a passive, non-power-using gate respond to a MULTITOOL
		ui.show_ui(user)
	else ..()

datum/pump_ui/passive_gate_ui
	value_name = "Release Pressure"
	value_units = "kPa"
	min_value = 0
	max_value = 1e31
	incr_sm = 100
	incr_lg = 1000
	var/obj/machinery/atmospherics/binary/passive_gate/our_gate

datum/pump_ui/passive_gate_ui/New(obj/machinery/atmospherics/binary/passive_gate/our_gate)
	..()
	src.our_gate = our_gate
	pump_name = our_gate.name

datum/pump_ui/passive_gate_ui/set_value(val)
	if(our_gate.node1 && our_gate.node2) //only do this on a currently working valve
		our_gate.update_icon("adjust") //right now this adjusts the same big red valve handle BUT I'm gonna add like, a nut-shaped thing that rotates, separate from the open/close valve.
	our_gate.target_pressure = val
	playsound(our_gate.loc, "sound/effects/valve_creak.ogg", 50, 1)

datum/pump_ui/passive_gate_ui/toggle_power()
	playsound(our_gate.loc, "sound/effects/valve_creak.ogg", 50, 1)
	if(our_gate.node1 && our_gate.node2) //only do this on a currently working valve
		our_gate.update_icon(our_gate.on ? "toff" : "ton" ) //spin it
		sleep(0.9 SECONDS)
		playsound(our_gate.loc, (our_gate.on ? "sound/machines/hiss.ogg" : "sound/items/Screwdriver.ogg"), 50, 1)
	our_gate.on = !our_gate.on
	our_gate.update_icon()

datum/pump_ui/passive_gate_ui/is_on()
	return our_gate.on

datum/pump_ui/passive_gate_ui/get_value()
	return our_gate.target_pressure

datum/pump_ui/passive_gate_ui/get_atom()
	return our_gate
