//CONTENTS
//Base bot control program
//Secbot control
//Mulebot control


/datum/computer/file/pda_program/bot_control
	name = "bot control base"

	var/list/botlist = list()		// list of bots
	var/list/botstatus			// the status signal sent by the bot

	var/control_freq = FREQ_BOT_CONTROL //Just for sending, adjust what the actual pda hooks to for receive

	proc/post_status(var/conn_id, var/key, var/value, var/key2, var/value2, var/key3, var/value3)
		if(!src.master)
			return

		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.transmission_method = 1
		signal.data[key] = value
		if(key2)
			signal.data[key2] = value2
		if(key3)
			signal.data[key3] = value3

		src.post_signal(signal, conn_id)

	on_activated(obj/item/device/pda2/pda)
		pda.AddComponent(
			/datum/component/packet_connected/radio, \
			"bot_beacon",\
			pda.beacon_freq, \
			pda.net_id, \
			null, \
			FALSE, \
			null, \
			FALSE \
		)
		pda.AddComponent(
			/datum/component/packet_connected/radio, \
			"bot_control",\
			control_freq, \
			pda.net_id, \
			null, \
			FALSE, \
			null, \
			FALSE \
		)
		RegisterSignal(pda, COMSIG_MOVABLE_RECEIVE_PACKET, PROC_REF(receive_signal))

	on_deactivated(obj/item/device/pda2/pda)
		qdel(get_radio_connection_by_id(pda, "bot_beacon"))
		qdel(get_radio_connection_by_id(pda, "bot_control"))
		UnregisterSignal(pda, COMSIG_MOVABLE_RECEIVE_PACKET)

	proc/receive_signal(obj/item/device/pda2/pda, datum/signal/signal, transmission_method, range, connection_id)
		return

#define SECACC_MENU_MAIN 1
#define SECACC_MENU_AREAS 2

/datum/computer/file/pda_program/bot_control/secbot
	name = "Securitron Access"
	var/header_thing = "Securitron Interlink"
	size = 8.0
	var/menumode = 1
	var/all_guard = 0
	var/lockdown = 0
	var/can_summon_all = 0
	var/active 	// the active secbot; if null, show bot list

	return_text()
		if(..())
			return

		. = src.return_text_header()

		. += "<h4>[header_thing]</h4>"

		switch(src.menumode)
			if(SECACC_MENU_MAIN)
				// list of bots
				if(!src.botlist || (length(src.botlist) < 1))
					. += "No bots found.<BR>"

				else
					for(var/mob/living/critter/robotic/bot/securitron/B in src.botlist)
						. += "[B] at [get_area(B)]<BR>"
						. += "Health: " + "[round(B.health)]/[B.max_health]<BR>"
						if(B.guard_area_name)
							. += "[B.lockdown ? "Locking down:" : "Guarding:"] [B.guard_area_name]<BR>"
						switch(B.patrolling)
							if(FALSE) // Not doing something?
								. += "<A href='byond://?src=\ref[src];op=go;active=\ref[B]'>Patrol</A> " // Go patrol!
							else
								. += "<A href='byond://?src=\ref[src];op=stop;active=\ref[B]'>Halt</A> " // Stop patrol!
						. += "<A href='byond://?src=\ref[src];op=summon;active=\ref[B]'>Summon</A> "
						. += "<A href='byond://?src=\ref[src];op=guardhere;active=\ref[B]'>Guard</A> "
						. += "<A href='byond://?src=\ref[src];op=lockdown;active=\ref[B]'>Lockdown</A> "
						. += "<hr>"

					if(src.can_summon_all)
						. += "<A href='byond://?src=\ref[src];op=summonall'>Summon all active bots</A><br><br>"
						. += "<A href='byond://?src=\ref[src];op=allguardhere'>Set all bots to guard</A><br><br>"
						. += "<A href='byond://?src=\ref[src];op=alllockdown'>Set all bots to lockdown</A><br><br>"
				. += "<A href='byond://?src=\ref[src];op=getareas'>Get list of valid areas</A><br><br>"
				. += "<A href='byond://?src=\ref[src];op=scanbots'>Scan for active bots</A>"

	Topic(href, href_list)
		if(..())
			return

		var/obj/item/device/pda2/PDA = src.master
		var/turf/summon_turf = get_turf(PDA)
		if (isAIeye(usr))
			summon_turf = get_turf(usr)
			if (!(summon_turf.cameras && length(summon_turf.cameras)))
				summon_turf = get_turf(PDA)

		if(href_list["active"])
			src.active = locate(href_list["active"])

		switch(href_list["op"])

			if("getareas") // get all the areas
				var/list/stationAreas = get_accessible_station_areas()
				self_text("Valid guard areas: [english_list(stationAreas)].")

			if("scanbots") // find all bots
				botlist = null
				self_text("Scanning for security robots...")
				post_status("bot_control", "command", "bot_status")

			if("guardhere", "allguardhere", "lockdown", "alllockdown") // not spoofable because god no
				var/list/stationAreas = get_accessible_station_areas()
				if(href_list["op"] == "allguardhere" || href_list["op"] == "alllockdown")
					src.all_guard = 1
				else
					src.all_guard = 0
				if(href_list["op"] == "lockdown" || href_list["op"] == "alllockdown")
					src.lockdown = 1
				else
					src.lockdown = 0
				var/area/guardthis = input(usr, "Please type 'Here' or the name of an area. Capitalization matters!", "GuardTron 0.0.1a", "Here") as text
				if(IN_RANGE(get_turf(usr), get_turf(src.master), 1))
					if(guardthis == "Here")
						guardthis = get_area(get_turf(src.master))
					else if(guardthis in stationAreas)
						guardthis = stationAreas[guardthis]
					else
						self_text("Unknown area: [guardthis].")
						guardthis = null
				if(guardthis)
					if(!src.all_guard)
						if(src.lockdown)
							post_status("bot_control", "command", "lockdown", "address_1", active:net_id, "target", guardthis)
							self_text("[active] ordered to lockdown [guardthis].")
						else
							post_status("bot_control", "command", "guard", "address_1", active:net_id, "target", guardthis)
							self_text("[active] ordered to guard [guardthis].")
						post_status("bot_control", "command", "bot_status", "address_1", active:net_id)
					else
						src.all_guard = 0
						if (!botlist.len)
							PDA.updateSelfDialog()
							return
						var/stored_lockdown = src.lockdown
						SPAWN_DBG(0)
							// we are gonna try to do this for real, but with a sleep - mylie
							for(var/bot in src.botlist)
								if(stored_lockdown)
									post_status("bot_control", "command", "lockdown", "address_1", bot:net_id, "target", guardthis)
									self_text("[bot] ordered to lockdown [guardthis].")
								else
									post_status("bot_control", "command", "guard", "address_1", bot:net_id, "target", guardthis)
									self_text("[bot] ordered to guard [guardthis].")
								sleep(2 DECI SECONDS)

			if("stop", "go")
				post_status("bot_control", "command", href_list["op"], "address_1", active:net_id)
				post_status("bot_control", "command", "bot_status", "address_1", active:net_id)
				if(href_list["op"] == "go")
					self_text("[active] set to patrol.")
				else
					self_text("[active] set to not patrol.")

			if("summon") // not spoofable
				post_status("bot_control", "command", "summon", "address_1", active:net_id, "target", summon_turf)
				post_status("bot_control", "command", "bot_status", "address_1", active:net_id)
				self_text("[active] summoned to [summon_turf.loc].")

			if("summonall") // also not spoofable
				if (!botlist.len)
					PDA.updateSelfDialog()
					return
				SPAWN_DBG(0)
					// trying this for real - mylie
					for(var/bot in src.botlist)
						post_status("bot_control", "command", "summon", "address_1", bot:net_id, "target", summon_turf)
						post_status("bot_control", "command", "bot_status", "address_1", bot:net_id)
						self_text("[bot] summoned to [summon_turf.loc].")
						sleep(2 DECI SECONDS)

		src.lockdown = 0
		src.all_guard = 0
		PDA.updateSelfDialog()

	receive_signal(obj/item/device/pda2/pda, datum/signal/signal, transmission_method, range, connection_id)
		if(connection_id == "bot_control" && signal.data["type"] == "secbot")
			if(!botlist)
				botlist = new()

			if(istype(signal.source,/mob/living/critter/robotic/bot/securitron) || istype(signal.source,/obj/machinery/bot/secbot)) // avoid putting random shit in the list
				botlist |= signal.source

			src.master.updateSelfDialog()

	post_signal(datum/signal/signal, newfreq)
		signal.encryption = "ERR_12845_NT_SECURE_PACKET:"
		signal.encryption_obfuscation = 97
		signal.data["auth_code"] = netpass_security
		. = ..()

/datum/computer/file/pda_program/bot_control/secbot/pro
	name = "Securitron Access PRO"
	size = 8.0
	header_thing = "Securitron Interlink PRO"
	can_summon_all = 1

/datum/computer/file/pda_program/bot_control/mulebot
	name = "MULE Bot Control"
	size = 16.0
	var/list/beacons
	var/obj/machinery/bot/mulebot/active
	var/list/pdas = list()

	return_text()
		if(..())
			return

		. = list(src.return_text_header())
		. += "<h4>M.U.L.E. bot Interlink V0.8</h4>"

		if(!src.active)
			// list of bots
			if(!src.botlist || (src.botlist && src.botlist.len==0))
				. += "No bots found.<BR>"

			else
				for(var/obj/machinery/bot/mulebot/B in src.botlist)
					. += "<A href='byond://?src=\ref[src];op=control;bot=\ref[B]'>[B] at [get_area(B)]</A><BR>"



			. += "<BR><A href='byond://?src=\ref[src];op=scanbots'>Scan for active bots</A><BR>"

		else	// bot selected, control it


			. += "<B>[src.active]</B><BR> Status: (<A href='byond://?src=\ref[src];op=control;bot=\ref[src.active]'><i>refresh</i></A>)<BR>"

			if(!src.botstatus)
				. += "Waiting for response...<BR>"
			else

				. += "Location: [src.botstatus["loca"] ]<BR>"
				. += "Mode: "

				switch(src.botstatus["mode"])
					if(0)
						. += "Ready"
					if(1)
						. += "Loading/Unloading"
					if(2)
						. += "Navigating to Delivery Location"
					if(3)
						. += "Navigating to Home"
					if(4)
						. += "Waiting for clear path"
					if(5,6)
						. += "Calculating navigation path"
					if(7)
						. += "Unable to locate destination"
				var/obj/storage/crate/C = src.botstatus["load"]
				. += "<BR>Current Load: [ !C ? "<i>none</i>" : "[C.name] (<A href='byond://?src=\ref[src];op=unload'><i>unload</i></A>)" ]<BR>"
				. += "<A href='byond://?src=\ref[src];op=scanbeacons'>Scan destinations</a><br>"
				. += "<A href='byond://?src=\ref[src];op=import'>Import PDAs</a><br>"
				. += "Destination: [!src.botstatus["dest"] ? "<i>none</i>" : src.botstatus["dest"] ] (<A href='byond://?src=\ref[src];op=setdest'><i>set</i></A>)<BR>"
				. += "Power: [src.botstatus["powr"]]%<BR>"
				. += "Home: [!src.botstatus["home"] ? "<i>none</i>" : src.botstatus["home"] ]<BR>"
				. += "Auto Return Home: [src.botstatus["retn"] ? "<B>On</B> <A href='byond://?src=\ref[src];op=retoff'>Off</A>" : "(<A href='byond://?src=\ref[src];op=reton'><i>On</i></A>) <B>Off</B>"]<BR>"
				. += "Auto Pickup Crate: [src.botstatus["pick"] ? "<B>On</B> <A href='byond://?src=\ref[src];op=pickoff'>Off</A>" : "(<A href='byond://?src=\ref[src];op=pickon'><i>On</i></A>) <B>Off</B>"]<BR><BR>"

				. += "\[<A href='byond://?src=\ref[src];op=stop'>Stop</A>\] "
				. += "\[<A href='byond://?src=\ref[src];op=go'>Proceed</A>\] "
				. += "\[<A href='byond://?src=\ref[src];op=home'>Return Home</A>\]<BR>"

				. += "<HR><A href='byond://?src=\ref[src];op=botlist'>Return to bot list</A><BR><HR>"
				for (var/P_id in src.pdas)
					var/P_name = src.pdas[P_id]
					if (!P_name)
						src.pdas -= P_id
						continue
					. += "<li>PDA-[P_name]"
					. += " \[<a href='byond://?src=\ref[src];op=setpdadest&deliver=[P_id]'>Set Target</a>\]<BR>"
		. = jointext(., "")

	Topic(href, href_list)
		if(..())
			return

		var/obj/item/device/pda2/PDA = src.master
		var/cmd = "command"
		if(active) cmd = "command_[ckey(active.suffix)]"

		switch(href_list["op"])

			if("import")
				src.pdas = null
				if(src.master.host_program && istype(src.master.host_program, /datum/computer/file/pda_program/os/main_os))
					src.pdas = src.master.host_program:detected_pdas

			if("control")
				active = locate(href_list["bot"])
				post_status("bot_control", cmd, "bot_status")

			if("scanbots")		// find all bots
				botlist = null
				post_status("bot_control", "command", "bot_status")

			if("scanbeacons")
				beacons = null
				src.post_status("bot_beacon", "findbeacon", "delivery", "address_tag", "any")

			if("botlist")
				active = null
				PDA.updateSelfDialog()

			if("unload")
				post_status("bot_control", cmd, "unload")
				post_status("bot_control", cmd, "bot_status")
			if("setdest")
				if(beacons)
					var/dest = input("Select Bot Destination", "Mulebot [active.suffix] Interlink", active:destination) as null|anything in beacons
					if(dest)
						post_status("bot_control", cmd, "target", "destination", dest)
						post_status("bot_control", cmd, "bot_status")
			if("setpdadest")
				if(href_list["deliver"])
					post_status("bot_control", cmd, "pda_target", "destination", href_list["deliver"])
			if("retoff")
				post_status("bot_control", cmd, "autoret", "value", 0)
				post_status("bot_control", cmd, "bot_status")
			if("reton")
				post_status("bot_control", cmd, "autoret", "value", 1)
				post_status("bot_control", cmd, "bot_status")

			if("pickoff")
				post_status("bot_control", cmd, "autopick", "value", 0)
				post_status("bot_control", cmd, "bot_status")
			if("pickon")
				post_status("bot_control", cmd, "autopick", "value", 1)
				post_status("bot_control", cmd, "bot_status")

			if("stop", "go", "home")
				post_status("bot_control", cmd, href_list["op"])
				post_status("bot_control", cmd, "bot_status")
		return

	receive_signal(obj/item/device/pda2/pda, datum/signal/signal, transmission_method, range, connection_id)
		if(signal.data["type"] == "mulebot" && connection_id == "bot_control" && !signal.encryption)
			if(!botlist)
				botlist = new()

			botlist |= signal.source

			if(active == signal.source)
				var/list/b = signal.data
				botstatus = b.Copy()

			src.master.updateSelfDialog()

		else if(signal.data["beacon"] && connection_id == "bot_beacon")
			if(!beacons)
				beacons = new()

			beacons[signal.data["beacon"] ] = signal.source

#undef SECACC_MENU_MAIN
#undef SECACC_MENU_AREAS
