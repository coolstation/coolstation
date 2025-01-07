//Objects that set up the ids (and names) of various machines and buttons at roundstart, so you don't have to varedit them (but you can if you want)
//The main benefit of doing it this way is that you only have to varedit the one instance you can colour code,
//and it should be a little clearer what's linked to what in the map editor.

//I need to mention that the idea is somewhat inspired by the door linkers Kubius made for goon, though I've never bothered to look at their code
//I just changed my mind on them being useful or not :p

//SUPPORTED THINGS:
//Doors, pod and regular (radio frequency, id)
//Door controls (id)
//Mass drivers (id)
//Computers (id and frequency, mixer control consoles have atmos mixer id support too)
//atmos mixer (ids, frequency, on)
//atmos pump (frequency, on)
//atmos injector outlet (on)
//airbridge controllers (id, width)
//Crematoriums and switches (id)


//NOT SUPPORTED
//lights & switches (area based)
//blinds & switches (area based)
//turret controls (area based)

/obj/map/machinery_link
	name = "machinery linker"
	//The vars all start with underscores so they're up top in strongDMM
	var/_id = null
	var/_freq = 0
	var/_naming_prefix = null
	var/_atmos_on = TRUE
	var/_airbridge_tunnel_width = 3 //default for airbridges
	var/_atmos_mixer_id = null


	New()
		..()
		SPAWN_DBG(1 SECOND)
			for(var/obj/O in get_turf(src))
				//if (isitem(O)) continue //In case we start putting buttons over full tables a lot? Seems rare atm.
				if (istype(O, /obj/machinery/door_control))
					var/obj/machinery/door_control/DC = O
					if (_id)
						DC.id = _id
					if (_naming_prefix)
						DC.name = _naming_prefix + DC.name
					continue
				if (istype(O, /obj/machinery/door/airlock))
					var/obj/machinery/door/airlock/D = O
					if (_id)
						D.id = _id
					if (_freq)
						D.frequency = _freq
					//TODO - doors currently have a spawn to rename themselves after the initial area, so this would just be a race condition waiting to happen
					//if (_naming_prefix)
					//	D.name = _naming_prefix + D.name
					continue
				if (istype(O, /obj/machinery/door/poddoor))
					var/obj/machinery/door/poddoor/PD = O
					if (_id)
						PD.id = _id
					continue
				if (istype(O, /obj/machinery/mass_driver))
					var/obj/machinery/mass_driver/MD = O
					if (_id)
						MD.id = _id
					continue
				if (istype(O, /obj/machinery/computer))
					var/obj/machinery/computer/C = O
					if (_id)
						C.id = _id
					if (_freq)
						C.frequency = _freq

					if (istype(C, /obj/machinery/computer/atmosphere/mixercontrol)) //ugh
						var/obj/machinery/computer/atmosphere/mixercontrol/MC = C
						if (_atmos_mixer_id)
							MC.mixerid = _atmos_mixer_id
					continue
				if (istype(O, /obj/machinery/atmospherics/binary/pump))
					var/obj/machinery/atmospherics/binary/pump/P = O
					if (_id)
						P.id = _id
					if (_freq)
						P.frequency = _freq
					P.on = _atmos_on
					continue
				if (istype(O, /obj/machinery/atmospherics/mixer))
					var/obj/machinery/atmospherics/mixer/MX = O
					if (_id)
						MX.master_id = _id
					if (_atmos_mixer_id)
						MX.id_tag = _atmos_mixer_id
					if (_freq)
						MX.frequency = _freq
					MX.on = _atmos_on
					continue
				if (istype(O, /obj/machinery/atmospherics/unary/outlet_injector))
					var/obj/machinery/atmospherics/unary/outlet_injector/OI = O
					OI.on = _atmos_on
					continue
				if (istype(O, /obj/crematorium))
					var/obj/crematorium/C = O
					if (_id)
						C.id = _id
					continue
				if (istype(O, /obj/machinery/crema_switch))
					var/obj/machinery/crema_switch/CS = O
					if (_id)
						CS.id = _id
					continue
				if (istype(O, /obj/airbridge_controller)) //airbridge comp doesn't need special handling beyond what the generic computer code does
					var/obj/airbridge_controller/AC = O
					if (_id)
						AC.id = _id
					AC.tunnel_width = _airbridge_tunnel_width
					continue

			qdel(src)
