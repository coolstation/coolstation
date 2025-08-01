#define MAX_QUEUE_LENGTH 20

#define UNIFORM_LIST /datum/manufacture/shoes,\
/datum/manufacture/shoes_brown,\
/datum/manufacture/shoes_white,\
/datum/manufacture/jumpsuit,\
/datum/manufacture/jumpsuit_white,\
/datum/manufacture/jumpsuit_red,\
/datum/manufacture/jumpsuit_yellow,\
/datum/manufacture/jumpsuit_green,\
/datum/manufacture/jumpsuit_pink,\
/datum/manufacture/jumpsuit_blue,\
/datum/manufacture/jumpsuit_brown,\
/datum/manufacture/jumpsuit_black,\
/datum/manufacture/jumpsuit_orange,\
/datum/manufacture/pride_lgbt,\
/datum/manufacture/pride_ace,\
/datum/manufacture/pride_aro,\
/datum/manufacture/pride_bi,\
/datum/manufacture/pride_inter,\
/datum/manufacture/pride_lesb,\
/datum/manufacture/pride_nb,\
/datum/manufacture/pride_pan,\
/datum/manufacture/pride_poly,\
/datum/manufacture/pride_trans,\
/datum/manufacture/suit_black,\
/datum/manufacture/dress_black,\
/datum/manufacture/hat_black,\
/datum/manufacture/hat_white,\
/datum/manufacture/hat_blue,\
/datum/manufacture/hat_yellow,\
/datum/manufacture/hat_red,\
/datum/manufacture/hat_green,\
/datum/manufacture/hat_pink,\
/datum/manufacture/hat_orange,\
/datum/manufacture/hat_tophat,\
/datum/manufacture/backpack,\
/datum/manufacture/backpack_red,\
/datum/manufacture/backpack_green,\
/datum/manufacture/backpack_blue,\
/datum/manufacture/satchel,\
/datum/manufacture/satchel_red,\
/datum/manufacture/satchel_green,\
/datum/manufacture/satchel_blue,\
/datum/manufacture/bedsheet_lgbt,\
/datum/manufacture/bedsheet_ace,\
/datum/manufacture/bedsheet_aro,\
/datum/manufacture/bedsheet_bi,\
/datum/manufacture/bedsheet_inter,\
/datum/manufacture/bedsheet_lesb,\
/datum/manufacture/bedsheet_nb,\
/datum/manufacture/bedsheet_pan,\
/datum/manufacture/bedsheet_poly,\
/datum/manufacture/bedsheet_trans

/obj/machinery/manufacturer
	name = "Manufacturing Unit"
	desc = "A standard fabricator unit capable of producing certain items from various materials."
	icon = 'icons/obj/machines/manufacturer.dmi'
	icon_state = "fab"
	var/icon_base = null
	density = 1
	anchored = 1
	mats = 20
	req_access = list(access_heads)
	event_handler_flags = NO_MOUSEDROP_QOL
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	flags = NOSPLASH
	machinery_flags = MAY_REQUIRE_MAINT
	var/health = 100
	var/mode = "ready"
	var/error = null
	var/speed = 3
	var/repeat = 0
	var/timeleft = 0
	var/manual_stop = 0
	var/panelopen = 0
	var/powconsumption = 0
	var/hacked = 0
	var/malfunction = 0
	var/electrified = 0
	var/accept_blueprints = 1
	var/page = 0 // temporary measure, i want a better UI for this =(
	var/dismantle_stage = 0
	var/output_cap = 20
	// 0 is =>, 1 is ==
	var/base_material_class = /obj/item/material_piece/ // please only material pieces
	var/obj/item/reagent_containers/glass/beaker = null
	var/list/resource_amounts = list()
	var/area_name = null
	var/output_target = null
	var/list/materials_in_use = list()
	var/list/available = list()
	var/list/download = list()
	var/list/hidden = list()
	var/list/queue = list()
	var/last_queue_op = 0

	var/category = null
	var/list/categories = list("Tool","Clothing","Resource","Component","Machinery","Atmospherics","Miscellaneous", "Downloaded")
	var/search = null
	var/wires = 15
	var/image/work_display = null
	var/image/activity_display = null
	var/image/panel_sprite = null
	var/list/obj/item/material_piece/free_resources = list() // please only material pieces
	var/free_resource_amt = 0
	var/list/nearby_turfs = list()
	var/sound_happy = 'sound/machines/chime.ogg'
	var/sound_grump = 'sound/machines/buzz-two.ogg'
	var/sound_beginwork = 'sound/machines/computerboot_pc.ogg'
	var/sound_damaged = 'sound/impact_sounds/Metal_Hit_Light_1.ogg'
	var/sound_destroyed = 'sound/impact_sounds/Machinery_Break_1.ogg'
	power_usage = 200
	var/static/list/sounds_malfunction = list('sound/machines/engine_grump1.ogg','sound/machines/engine_grump2.ogg','sound/machines/engine_grump3.ogg',
	'sound/machines/glitch1.ogg','sound/machines/glitch2.ogg','sound/machines/glitch3.ogg','sound/impact_sounds/Metal_Clang_1.ogg','sound/impact_sounds/Metal_Hit_Heavy_1.ogg','sound/machines/romhack1.ogg','sound/machines/romhack3.ogg')
	var/static/list/text_flipout_adjective = list("an awful","a terrible","a loud","a horrible","a nasty","a horrendous")
	var/static/list/text_flipout_noun = list("noise","racket","ruckus","clatter","commotion","din")
	var/list/text_bad_output_adjective = list("janky","crooked","warped","shoddy","shabby","lousy","crappy","shitty")
	var/obj/item/card/id/scan = null
	var/temp = null
	var/frequency = FREQ_PDA
	var/datum/radio_frequency/transmit_connection = null
	var/net_id = null

	var/datum/action/action_bar = null
	//We'll probably have to handle having multiple appendices the moment there's more than one type, but not now. uwu
	var/obj/machinery/manufacturer_attachment/appendix = null



#define WIRE_EXTEND 1
#define WIRE_POWER 2
#define WIRE_MALF 3
#define WIRE_SHOCK 4

	New()
		START_TRACKING
		..()
		var/area/area = get_area(src)
		src.area_name = area?.name
		src.transmit_connection = radio_controller.add_object(src,"[frequency]")
		src.net_id = generate_net_id(src)

		if (istype(manuf_controls,/datum/manufacturing_controller))
			src.set_up_schematics()
			manuf_controls.manufacturing_units += src

		for (var/turf/T in view(5,src))
			nearby_turfs += T

		src.create_reagents(1000)

		src.work_display = image('icons/obj/machines/manufacturer.dmi', "")
		src.activity_display = image('icons/obj/machines/manufacturer.dmi', "")
		src.panel_sprite = image('icons/obj/machines/manufacturer.dmi', "")
		SPAWN_DBG(0)
			src.build_icon()

	disposing()
		STOP_TRACKING
		manuf_controls.manufacturing_units -= src
		src.appendix?.belongs_to = null
		src.appendix = null
		src.work_display = null
		src.activity_display = null
		src.panel_sprite = null
		src.output_target = null
		src.beaker = null
		src.available.len = 0
		src.available = null
		src.download.len = 0
		src.download = null
		src.hidden.len = 0
		src.hidden = null
		src.queue.len = 0
		src.queue = null
		src.nearby_turfs.len = 0
		src.nearby_turfs = null
		src.sound_happy = null
		src.sound_grump = null
		src.sound_beginwork = null
		src.sound_damaged = null
		src.sound_destroyed = null
		radio_controller.remove_object(src,"[frequency]")
		src.transmit_connection = null

		for (var/obj/O in src.contents)
			O.set_loc(src.loc)
		for (var/mob/M in src.contents)
			// unlikely as this is to happen we might as well make sure everything is purged
			M.set_loc(src.loc)

		..()

	examine()
		. = ..()
		if (src.health < 100)
			if (src.health < 50)
				. += "<span class='alert'>It's rather badly damaged. It probably needs some wiring replaced inside.</span>"
			else
				. += "<span class='alert'>It's a bit damaged. It looks like it needs some welding done.</span>"

		if	(status & BROKEN)
			. += "<span class='alert'>It seems to be damaged beyond the point of operability.</span>"
		if	(status & NOPOWER)
			. += "<span class='alert'>It seems to be offline.</span>"

		switch(src.dismantle_stage)
			if(1)
				. += "<span class='alert'>It's partially dismantled. To deconstruct it, use a crowbar. To repair it, use a wrench.</span>"
			if(2)
				. += "<span class='alert'>It's partially dismantled. To deconstruct it, use wirecutters. To repair it, add reinforced metal.</span>"
			if(3)
				. += "<span class='alert'>It's partially dismantled. To deconstruct it, use a wrench. To repair it, add some cable.</span>"

	process(var/mult)
		if (status & NOPOWER)
			return

		power_usage = src.powconsumption + 200 * mult
		..()

		if (src.mode == "working")
			use_power(src.powconsumption)

		if (src.electrified > 0)
			src.electrified--
		/*
		if (src.mode == "working")
			if (src.malfunction && prob(8))
				src.flip_out()
			src.timeleft -= src.speed * 4.4 * mult
			use_power(src.powconsumption)
			if (src.timeleft < 1)
				src.output_loop(src.queue[1])
				SPAWN_DBG(0)
					if (src.queue.len < 1)
						src.manual_stop = 0
						playsound(src.loc, src.sound_happy, 50, 1)
						src.visible_message("<span class='notice'>[src] finishes its production queue.</span>")
						src.mode = "ready"
						src.build_icon()
		*/

	proc/finish_work()

		if(length(src.queue))
			output_loop(src.queue[1])
			if (!src.repeat)
				src.queue -= src.queue[1]

		if (src.queue.len < 1)
			src.manual_stop = 0
			playsound(src.loc, src.sound_happy, 50, 1)
			src.visible_message("<span class='notice'>[src] finishes its production queue.</span>")
			src.mode = "ready"
			src.build_icon()

	ex_act(severity)
		switch(severity)
			if(OLD_EX_SEVERITY_1)
				for(var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					A.ex_act(severity)
				src.take_damage(rand(100,120))
			if(OLD_EX_SEVERITY_2)
				src.take_damage(rand(40,80))
			if(OLD_EX_SEVERITY_3)
				src.take_damage(rand(20,40))
		return

	blob_act(var/power)
		src.take_damage(rand(power * 0.5, power * 1.5))

	meteorhit()
		src.take_damage(rand(15,45))

	emp_act()
		src.take_damage(rand(5,10))
		src.malfunction = 1
		src.flip_out()

	bullet_act(var/obj/projectile/P)
		// swiped from guardbot.dm
		var/damage = 0
		damage = round(((P.power/6)*P.proj_data.ks_ratio), 1.0)

		if(src.material) src.material.triggerOnBullet(src, src, P)

		if (!damage)
			return
		if(P.proj_data.damage_type == D_KINETIC || (P.proj_data.damage_type == D_ENERGY && damage))
			src.take_damage(damage / 2)
		else if (P.proj_data.damage_type == D_PIERCING)
			src.take_damage(damage)

	power_change()
		if(status & BROKEN)
			src.build_icon()
		else
			if(powered() && src.dismantle_stage < 3)
				status &= ~NOPOWER
				src.build_icon()
			else
				SPAWN_DBG(rand(0, 15))
					status |= NOPOWER
					src.build_icon()

	attack_hand(var/mob/user as mob)
		if (free_resource_amt > 0)
			claim_free_resources()

		if(src.electrified != 0)
			if (!(status & NOPOWER || status & BROKEN))
				if (src.manuf_zap(user, 33))
					return

		//Main screen
		src.add_dialog(user)

		PC_LOAD(manufacturer, mainscreen)

		mainscreen.tags["title"] += src.name

		var/list/dat = list()
		var/delete_allowed = src.allowed(usr)

		if (src.panelopen || isAI(user))
			var/list/manuwires = list(
			"Amber" = 1,
			"Teal" = 2,
			"Indigo" = 3,
			"Lime" = 4,
			)
			var/list/pdat = list("<B>[src] Maintenance Panel</B><hr>")
			for(var/wiredesc in manuwires)
				var/is_uncut = src.wires & APCWireColorToFlag[manuwires[wiredesc]]
				pdat += "[wiredesc] wire: "
				if(!is_uncut)
					pdat += "<a href='byond://?src=\ref[src];cutwire=[manuwires[wiredesc]]'>Mend</a>"
				else
					pdat += "<a href='byond://?src=\ref[src];cutwire=[manuwires[wiredesc]]'>Cut</a> "
					pdat += "<a href='byond://?src=\ref[src];pulsewire=[manuwires[wiredesc]]'>Pulse</a> "
				pdat += "<br>"

			pdat += "<br>"
			if (status & BROKEN || status & NOPOWER)
				pdat += "The yellow light is off.<BR>"
				pdat += "The blue light is off.<BR>"
				pdat += "The white light is off.<BR>"
				pdat += "The red light is off.<BR>"
			else
				pdat += "The yellow light is [(src.electrified == 0) ? "off" : "on"].<BR>"
				pdat += "The blue light is [src.malfunction ? "flashing" : "on"].<BR>"
				pdat += "The white light is [src.hacked ? "on" : "off"].<BR>"
				pdat += "The red light is on.<BR>"

			user.Browse(pdat.Join(), "window=manupanel")
			onclose(user, "manupanel")

		if (status & BROKEN || status & NOPOWER)
			dat = "The screen is blank."
			user.Browse(dat, "window=manufact;size=750x500")
			onclose(user, "manufact")
			return
		if (status & MALFUNC) //kinda boring but I can't think of anything better atm it's late
			dat = "The screen is a garbled, shifting mess. Something is broken here."
			user.Browse(dat, "window=manufact;size=750x500")
			onclose(user, "manufact")
			return


		// Get the list of stuff we can print ...
		var/list/products = src.available + src.download
		if (src.hacked)
			products += src.hidden

		// Then make it
		var/can_be_made = 0
		var/delete_link
		for(var/datum/manufacture/A in products)
			var/list/mats_used = get_materials_needed(A)

			if (istext(src.search) && !findtext(A.name, src.search, 1, null))
				continue
			else if (istext(src.category) && src.category != A.category)
				continue

			can_be_made = (mats_used.len >= A.item_paths.len)
			if(delete_allowed && src.download.Find(A))
				delete_link = {"<span class='delete' onclick='delete_product("\ref[A]");'>DELETE</span>"}

			else
				delete_link = ""

			var/icon_text = "<img class='icon'>"
			// @todo probably refactor this since it's copy pasted twice now.
			if (A.item_outputs)
				var/icon_rsc = getItemIcon(A.item_outputs[1], C = usr.client)
				// user << browse_rsc(browse_item_icons[icon_rsc], icon_rsc)
				icon_text = "<img class='icon' src='[icon_rsc]'>"

			if (istype(A, /datum/manufacture/mechanics))
				var/datum/manufacture/mechanics/F = A
				var/icon_rsc = getItemIcon(F.frame_path, C = usr.client)
				// user << browse_rsc(browse_item_icons[icon_rsc], icon_rsc)
				icon_text = "<img class='icon' src='[icon_rsc]'>"

			var/list/material_text = list()
			var/list/material_count = 0
			for (var/i in 1 to A.item_paths.len)
				material_count += A.item_amounts[i]
				var/mat_name
				if(isnull(A.item_names) || isnull(A.item_names[i]))
					mat_name = get_nice_mat_name_for_manufacturers(A.item_paths[i])
				else
					mat_name = A.item_names[i]
				material_text += {"
				<span class='mat[mats_used[A.item_paths[i]] ? "" : "-missing"]'>[A.item_amounts[i]] [mat_name]</span>
				"}

			mainscreen.tags["products"] += {"
		<div class='product[can_be_made ? "" : " disabled"]' onclick='product("\ref[A]");'>
			<strong>[A.name]</strong>
			<div class='required'><div>[material_text.Join("<br>")]</div></div>
			[icon_text]
			[delete_link]
			<span class='mats'>[material_count] mat.</span>
			<span class='time'>[A.time && src.speed ? round(A.time / src.speed / 10, 0.1) : "??"] sec.</span>
		</div>"}


		mainscreen.tags["mat-list"] += build_material_list(user)
		//Search
		mainscreen.tags["search"] += istext(src.search) ? html_encode(src.search) : "----"
		mainscreen.tags["search-category"] += istext(src.category) ? html_encode(src.category) : "----"
		// This is not re-formatted yet just b/c i don't wanna mess with it
		mainscreen.tags["scan"] = src.scan
		if(scan)
			var/datum/data/record/account = null
			account = FindBankAccountById(src.scan.registered_id)
			if (account)
				PC_ENABLE_IFDEF(mainscreen, "account")
				mainscreen.tags["account"] += account.fields["current_money"]

		for_by_tcl(S, /obj/machinery/ore_cloud_storage_container)
			if(S.broken)
				continue
			mainscreen.tags["ore-list"] += "<B>[S.name] at [get_area(S)]:</B><br>"
			var/list/ores = S.ores
			for(var/ore in ores)
				var/datum/ore_cloud_data/OCD = ores[ore]
				if(!OCD.for_sale || !OCD.amount)
					continue
				var/taxes = round(max(rockbox_globals.rockbox_client_fee_min,abs(OCD.price*rockbox_globals.rockbox_client_fee_pct/100)),0.01) //transaction taxes for the station budget
				mainscreen.tags["ore-list"] += "[ore]: [OCD.amount] ($[OCD.price+taxes+(!rockbox_globals.rockbox_premium_purchased ? rockbox_globals.rockbox_standard_fee : 0)]/ore) (<A href='byond://?src=\ref[src];purchase=1;storage=\ref[S];ore=[ore]'>Purchase</A>)<br>"

		mainscreen.tags["control-panel"] += build_control_panel(user)

		PC_RENDER(mainscreen)
		PC_BROWSE(mainscreen)
		onclose(user, "manufact")

		interact_particle(user,src)

	// Validate that an item is inside this machine for HREF check purposes
	proc/validate_disp(var/datum/manufacture/M)
		. = FALSE
		if(src.available && (M in src.available))
			return TRUE

		if(src.download && (M in src.download))
			return TRUE

		if(src.hacked && src.hidden && (M in src.hidden))
			return TRUE


	Topic(href, href_list)

		if(!(href_list["cutwire"] || href_list["pulsewire"]))
			if(status & BROKEN || status & NOPOWER)
				return

		if(usr.stat || usr.restrained())
			return

		if(src.electrified != 0)
			if (!(status & NOPOWER || status & BROKEN))
				if (src.manuf_zap(usr, 10))
					return

		if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1 || isAI(usr)) && istype(src.loc, /turf))))
			src.add_dialog(usr)

			if (src.malfunction && prob(10))
				src.flip_out()

			if (href_list["eject"])
				if (src.mode != "ready")
					boutput(usr, "<span class='alert'>You cannot eject materials while the unit is working.</span>")
				else
					var/mat_id = href_list["eject"]
					var/ejectamt = 0
					var/turf/ejectturf = get_turf(usr)
					for(var/obj/item/O in src.contents)
						if (O.material && O.material.mat_id == mat_id)
							if (!ejectamt)
								ejectamt = input(usr,"How many material pieces (10 units per) do you want to eject?","Eject Materials") as num
								if (ejectamt <= 0 || src.mode != "ready" || get_dist(src, usr) > 1)
									break
							if (!ejectturf)
								break
							if (ejectamt > O.amount)
								playsound(src.loc, src.sound_grump, 50, 1)
								boutput(usr, "<span class='alert'>There's not that much material in [name]. It has ejected what it could.</span>")
								ejectamt = O.amount
							src.update_resource_amount(mat_id, -ejectamt * 10) // ejectamt will always be <= actual amount
							if (ejectamt == O.amount)
								O.set_loc(get_output_location(O,1))
							else
								var/obj/item/material_piece/P = new O.type()
								P.setMaterial(O.material)
								P.change_stack_amount(ejectamt - P.amount)
								O.change_stack_amount(-ejectamt)
								P.set_loc(get_output_location(O,1))
							break

			if (href_list["speed"])
				if (src.mode == "working")
					boutput(usr, "<span class='alert'>You cannot alter the speed setting while the unit is working.</span>")
				else
					var/upperbound = 3
					if (src.hacked)
						upperbound = 5
					var/newset = input(usr,"Enter from 1 to [upperbound]. Higher settings consume more power","Manufacturing Speed") as num
					newset = max(1,min(newset,upperbound))
					src.speed = newset

			if (href_list["clearQ"])
				var/Qcounter = 1
				for (var/datum/manufacture/M in src.queue)
					if (Qcounter == 1 && src.mode == "working") continue
					src.queue -= src.queue[Qcounter]
				if (src.mode == "halt")
					src.manual_stop = 0
					src.error = null
					src.mode = "ready"
					src.build_icon()

			if (href_list["removefromQ"])
				var/operation = text2num(href_list["removefromQ"])
				if (!isnum(operation) || src.queue.len < 1 || operation > src.queue.len)
					boutput(usr, "<span class='alert'>Invalid operation.</span>")
					return

				if(world.time < last_queue_op + 5) //Anti-spam to prevent people lagging the server with autoclickers
					return
				else
					last_queue_op = world.time

				src.queue -= src.queue[operation]
				begin_work(1)//pesky exploits

			if (href_list["page"])
				var/operation = text2num(href_list["page"])
				src.page = operation

			if (href_list["repeat"])
				src.repeat = !src.repeat

			if (href_list["search"])
				src.search = input("Enter text to search for in schematics.","Manufacturing Unit") as null|text
				if (length(src.search) == 0)
					src.search = null

			if (href_list["category"])
				var/selection = input("Select which category to filter by.","Manufacturing Unit") as null|anything in list("REMOVE FILTER") + src.categories
				src.category = ((selection == "REMOVE FILTER") ? null : selection)

			if (href_list["continue"])
				if (src.queue.len < 1)
					boutput(usr, "<span class='alert'>Cannot find any items in queue to continue production.</span>")
					return
				if (!check_enough_materials(src.queue[1]))
					boutput(usr, "<span class='alert'>Insufficient usable materials to manufacture first item in queue.</span>")
				else
					src.begin_work(0)

			if (href_list["pause"])
				src.mode = "halt"
				src.build_icon()
				if (src.action_bar)
					src.action_bar.interrupt(INTERRUPT_ALWAYS)

			if (href_list["delete"])
				if(!src.allowed(usr))
					boutput(usr, "<span class='alert'>Access denied.</span>")
					return
				var/datum/manufacture/I = locate(href_list["disp"])
				if (!istype(I,/datum/manufacture/mechanics/))
					boutput(usr, "<span class='alert'>Cannot delete this schematic.</span>")
					return
				last_queue_op = world.time
				if(alert("Are you sure you want to remove [I.name] from the [src]?",,"Yes","No") == "Yes")
					src.download -= I
			else if (href_list["disp"])
				var/datum/manufacture/I = locate(href_list["disp"])
				if (!istype(I,/datum/manufacture/))
					return
				if(world.time < last_queue_op + 5) //Anti-spam to prevent people lagging the server with autoclickers
					return
				else
					last_queue_op = world.time

				// Verify that there is no href fuckery abound
				if(!validate_disp(I))
					// Since a manufacturer may get unhacked or a downloaded item could get deleted between someone
					// opening the window and clicking the button we can't assume intent here, so no cluwne
					return

				if (!check_enough_materials(I))
					boutput(usr, "<span class='alert'>Insufficient usable materials to manufacture that item.</span>")
				else if (src.queue.len >= MAX_QUEUE_LENGTH)
					boutput(usr, "<span class='alert'>Manufacturer queue length limit reached.</span>")
				else
					playsound(src.loc, src.sound_happy, 50, 1) //holy piss do these machines need to give feedback that your request went in
					boutput(usr, "<span class='alert'>Item added to to queue.</span>")
					src.queue += I
					if (src.mode == "ready")
						src.begin_work(1)
						src.updateUsrDialog()

				//Start the manufacturer even if we don't manage to add anything to the queue
				if (src.queue.len > 0 && src.mode == "ready")
					src.begin_work(1)
					src.updateUsrDialog()
					return

			if (href_list["ejectbeaker"])
				if (src.beaker)
					src.beaker.set_loc(get_output_location(beaker,1))
				src.beaker = null

			if (href_list["transto"])
				// reagents are going into beaker
				var/obj/item/reagent_containers/glass/B = locate(href_list["transto"])
				if (!istype(B,/obj/item/reagent_containers/glass/))
					return
				var/howmuch = input("Transfer how much to [B]?","[src.name]",B.reagents.maximum_volume - B.reagents.total_volume) as null|num
				if (!howmuch || !B || B != src.beaker )
					return
				src.reagents.trans_to(B,howmuch)

			if (href_list["transfrom"])
				// reagents are being drawn from beaker
				var/obj/item/reagent_containers/glass/B = locate(href_list["transfrom"])
				if (!istype(B,/obj/item/reagent_containers/glass/))
					return
				var/howmuch = input("Transfer how much from [B]?","[src.name]",B.reagents.total_volume) as null|num
				if (!howmuch)
					return
				B.reagents.trans_to(src,howmuch)

			if (href_list["flush"])
				var/the_reagent = href_list["flush"]
				if (!istext(the_reagent))
					return
				var/howmuch = input("Flush how much [the_reagent]?","[src.name]",0) as null|num
				if (!howmuch)
					return
				src.reagents.remove_reagent(the_reagent,howmuch)

			if ((href_list["cutwire"]) && (src.panelopen || isAI(usr)))
				if (src.electrified)
					if (src.manuf_zap(usr, 100))
						return
				var/twire = text2num(href_list["cutwire"])
				if (!usr.find_tool_in_hand(TOOL_SNIPPING))
					boutput(usr, "You need a snipping tool!")
					return
				else if (src.isWireColorCut(twire))
					src.mend(twire)
				else
					src.cut(twire)
				src.build_icon()

			if ((href_list["pulsewire"]) && (src.panelopen || isAI(usr)))
				var/twire = text2num(href_list["pulsewire"])
				if ( !(usr.find_tool_in_hand(TOOL_PULSING) || isAI(usr)) )
					boutput(usr, "You need a multitool or similar!")
					return
				else if (src.isWireColorCut(twire))
					boutput(usr, "You can't pulse a cut wire.")
					return
				else
					src.pulse(twire)
				src.build_icon()

			if (href_list["card"])
				if (src.scan) src.scan = null
				else
					var/obj/item/I = usr.equipped()
					src.scan_card(I)

			if (href_list["purchase"])
				var/obj/machinery/ore_cloud_storage_container/storage = locate(href_list["storage"])
				var/ore = href_list["ore"]
				var/datum/ore_cloud_data/OCD = storage.ores[ore]
				var/price = OCD.price
				var/taxes = round(max(rockbox_globals.rockbox_client_fee_min,abs(price*rockbox_globals.rockbox_client_fee_pct/100)),0.01) //transaction taxes for the station budget

				if(storage?.broken)
					return

				if(!scan)
					src.temp = {"You have to scan a card in first.<BR>"}
					src.updateUsrDialog()
					return
				else
					src.temp = null
				if (src.scan.registered_id in FrozenAccounts)
					boutput(usr, "<span class='alert'>Your account cannot currently be liquidated due to active borrows.</span>")
					return
				var/datum/data/record/account = null
				account = FindBankAccountById(src.scan.registered_id)
				if (account)
					var/quantity = 1
					quantity = max(0, input("How many units do you want to purchase?", "Ore Purchase", null, null) as num)

					////////////

					if(OCD.amount >= quantity && quantity > 0)
						var/subtotal = round(price * quantity)
						var/sum_taxes = round(taxes * quantity)
						var/rockbox_fees = (!rockbox_globals.rockbox_premium_purchased ? rockbox_globals.rockbox_standard_fee : 0) * quantity
						var/total = subtotal + sum_taxes + rockbox_fees
						if(account.fields["current_money"] >= total)
							account.fields["current_money"] -= total
							storage.eject_ores(ore, get_output_location(), quantity, transmit=1, user=usr)

							 // This next bit is stolen from PTL Code
							var/list/accounts = list()
							for(var/datum/data/record/t in data_core.bank)
								if(t.fields["job"] == "Chief Engineer")
									accounts += t
									accounts += t //fuck it x2
								else if(t.fields["job"] == "Miner")
									accounts += t


							var/datum/signal/minerSignal = get_free_signal()
							minerSignal.source = src
							minerSignal.transmission_method = TRANSMISSION_RADIO
							//any non-divisible amounts go to the shipping budget
							var/leftovers = 0
							if(accounts.len)
								leftovers = length(subtotal%accounts)
								var/divisible_amount = subtotal - leftovers
								if(divisible_amount)
									var/amount_per_account = divisible_amount/length(accounts)
									for(var/datum/data/record/t in accounts)
										t.fields["current_money"] += amount_per_account
									minerSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="ROCKBOX&trade;-MAILBOT",  "group"=list(MGO_MINING, MGA_SALES), "sender"=src.net_id, "message"="Notification: [amount_per_account] credits earned from Rockbox&trade; sale, deposited to your account.")
							else
								leftovers = subtotal
								minerSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="ROCKBOX&trade;-MAILBOT",  "group"=list(MGO_MINING, MGA_SALES), "sender"=src.net_id, "message"="Notification: [leftovers + sum_taxes] credits earned from Rockbox&trade; sale, deposited to the shipping budget.")
							wagesystem.shipping_budget += (leftovers + sum_taxes)
							transmit_connection.post_signal(src, minerSignal)

							src.temp = {"Enjoy your purchase!<BR>"}
						else
							src.temp = {"You don't have enough dosh, bucko.<BR>"}
					else
						if(quantity > 0)
							src.temp = {"I don't have that many for sale, champ.<BR>"}
						else
							src.temp = {"Enter some actual valid number, you doofus!<BR>"}
				else
					src.temp = {"That card doesn't have an account anymore, you might wanna get that checked out.<BR>"}

			src.updateUsrDialog()
		return

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.hacked)
			src.hacked = 1
			if(user)
				boutput(user, "<span class='notice'>You remove the [src]'s product locks!</span>")
			return 1
		return 0

	attackby(obj/item/W as obj, mob/user as mob)
		if (src.electrified)
			if (src.manuf_zap(usr, 33))
				return

		if (istype(W, /obj/item/paper/manufacturer_blueprint))
			if (!src.accept_blueprints)
				boutput(user, "<span class='alert'>This manufacturer unit does not accept blueprints.</span>")
				return
			var/obj/item/paper/manufacturer_blueprint/BP = W
			if (src.malfunction && prob(75))
				src.visible_message("<span class='alert'>[src] emits a [pick(src.text_flipout_adjective)] [pick(src.text_flipout_noun)]!</span>")
				playsound(src.loc, pick(src.sounds_malfunction), 50, 1)
				boutput(user, "<span class='alert'>The manufacturer mangles and ruins the blueprint in the scanner! What the fuck?</span>")
				qdel(BP)
				return
			if (!BP.blueprint)
				src.visible_message("<span class='alert'>[src] emits a grumpy buzz!</span>")
				playsound(src.loc, src.sound_grump, 50, 1)
				boutput(user, "<span class='alert'>The manufacturer rejects the blueprint. Is something wrong with it?</span>")
				return
			for (var/datum/manufacture/mechanics/M in (src.available + src.download))
				if(istype(M) && istype(BP.blueprint, /datum/manufacture/mechanics))
					var/datum/manufacture/mechanics/BPM = BP.blueprint
					if(M.frame_path == BPM.frame_path)
						src.visible_message("<span class='alert'>[src] emits an irritable buzz!</span>")
						playsound(src.loc, src.sound_grump, 50, 1)
						boutput(user, "<span class='alert'>The manufacturer rejects the blueprint, as it already knows it.</span>")
						return
				else if (BP.blueprint.name == M.name)
					src.visible_message("<span class='alert'>[src] emits an irritable buzz!</span>")
					playsound(src.loc, src.sound_grump, 50, 1)
					boutput(user, "<span class='alert'>The manufacturer rejects the blueprint, as it already knows it.</span>")
					return
			BP.dropped()
			src.download += BP.blueprint
			src.visible_message("<span class='alert'>[src] emits a pleased chime!</span>")
			playsound(src.loc, src.sound_happy, 50, 1)
			boutput(user, "<span class='notice'>The manufacturer accepts and scans the blueprint.</span>")
			qdel(BP)
			return

		else if (istype(W, /obj/item/satchel))
			user.visible_message("<span class='notice'>[user] uses [src]'s automatic loader on [W]!</span>", "<span class='notice'>You use [src]'s automatic loader on [W].</span>")
			var/amtload = 0
			for (var/obj/item/M in W.contents)
				if (!istype(M,src.base_material_class))
					continue
				W:curitems -= M.amount
				src.load_item(M)
				amtload++
			W:satchel_updateicon()
			if (amtload) boutput(user, "<span class='notice'>[amtload] materials loaded from [W]!</span>")
			else boutput(user, "<span class='alert'>No materials loaded!</span>")

		else if (isscrewingtool(W))
			if (!src.panelopen)
				src.panelopen = 1
			else
				src.panelopen = 0
			boutput(user, "You [src.panelopen ? "open" : "close"] the maintenance panel.")
			src.build_icon()

		else if (isweldingtool(W))
			var/do_action = 0
			if (istype(W,src.base_material_class) && src.accept_loading(user))
				if (alert(user,"What do you want to do with [W]?","[src.name]","Repair","Load it in") == "Load it in")
					do_action = 1
			if (do_action == 1)
				user.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>", "<span class='notice'>You load [W] into the [src].</span>")
				src.load_item(W,user)
			else
				if (src.health < 50)
					boutput(user, "<span class='alert'>It's too badly damaged. You'll need to replace the wiring first.</span>")
				else if(W:try_weld(user, 1))
					src.take_damage(-10)
					user.visible_message("<b>[user]</b> uses [W] to repair some of [src]'s damage.")
					if (src.health == 100)
						boutput(user, "<span class='notice'><b>[src] looks fully repaired!</b></span>")

		else if (istype(W,/obj/item/cable_coil) && src.panelopen)
			var/obj/item/cable_coil/C = W
			var/do_action = 0
			if (istype(C,src.base_material_class) && src.accept_loading(user))
				if (alert(user,"What do you want to do with [C]?","[src.name]","Repair","Load it in") == "Load it in")
					do_action = 1
			if (do_action == 1)
				user.visible_message("<span class='notice'>[user] loads [C] into the [src].</span>", "<span class='notice'>You load [C] into the [src].</span>")
				src.load_item(C,user)
			else
				if (src in random_events.maintenance_event.unmaintained_machines)
					if (W.amount >= 4)
						W.change_stack_amount(-4)
						playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
						boutput(user, "<span class='notice'>You replace some of the grodier-looking wires.</span>")
						malfunction_resolve()
				else
					if (src.health >= 50)
						boutput(user, "<span class='alert'>The wiring is fine. You need to weld the external plating to do further repairs.</span>")
					else
						C.use(1)
						src.take_damage(-10)
						user.visible_message("<b>[user]</b> uses [C] to repair some of [src]'s cabling.")
						playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
						if (src.health >= 50)
							boutput(user, "<span class='notice'>The wiring is fully repaired. Now you need to weld the external plating.</span>")

		else if (iswrenchingtool(W))
			var/do_action = 0
			if (istype(W,src.base_material_class) && src.accept_loading(user))
				if (alert(user,"What do you want to do with [W]?","[src.name]","Dismantle/Construct","Load it in") == "Load it in")
					do_action = 1
			if (do_action == 1)
				user.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>", "<span class='notice'>You load [W] into the [src].</span>")
				src.load_item(W,user)
			else
				playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
				if (src.dismantle_stage == 0)
					user.visible_message("<b>[user]</b> loosens [src]'s external plating bolts.")
					src.dismantle_stage = 1
				else if (src.dismantle_stage == 1)
					user.visible_message("<b>[user]</b> fastens [src]'s external plating bolts.")
					src.dismantle_stage = 0
				else if (src.dismantle_stage == 3)
					user.visible_message("<b>[user]</b> dismantles [src]'s mechanisms.")
					new /obj/item/sheet/steel/reinforced(src.loc)
					qdel(src)
					return
				src.build_icon()

		else if (ispryingtool(W) && src.dismantle_stage == 1)
			user.visible_message("<b>[user]</b> pries off [src]'s plating.")
			playsound(src.loc, "sound/items/Crowbar.ogg", 50, 1)
			src.dismantle_stage = 2
			new /obj/item/sheet/steel/reinforced(src.loc)
			src.build_icon()

		else if (issnippingtool(W) && src.dismantle_stage == 2)
			if (!(status & NOPOWER))
				if (src.manuf_zap(user,100))
					return
			user.visible_message("<b>[user]</b> disconnects [src]'s cabling.")
			playsound(src.loc, "sound/items/Wirecutter.ogg", 50, 1)
			src.dismantle_stage = 3
			src.status |= NOPOWER
			var/obj/item/cable_coil/cut/C = new /obj/item/cable_coil/cut(src.loc)
			C.amount = 1
			src.build_icon()

		else if (istype(W,/obj/item/sheet/steel/reinforced) && src.dismantle_stage == 2)
			user.visible_message("<b>[user]</b> adds plating to [src].")
			src.dismantle_stage = 1
			qdel(W)
			src.build_icon()

		else if (istype(W,/obj/item/cable_coil) && src.dismantle_stage == 3)
			user.visible_message("<b>[user]</b> adds cabling to [src].")
			src.dismantle_stage = 2
			qdel(W)
			src.status &= ~NOPOWER
			src.manuf_zap(user,100)
			src.build_icon()

		else if (istype(W,/obj/item/reagent_containers/glass))
			if (src.beaker)
				boutput(user, "<span class='alert'>There's already a receptacle in the machine. You need to remove it first.</span>")
			else
				boutput(user, "<span class='notice'>You insert [W].</span>")
				W.set_loc(src)
				src.beaker = W
				if (user && W)
					user.u_equip(W)
					W.dropped()

		else if (istype(W,/obj/item/sheet/) || (istype(W,/obj/item/cable_coil/ || (istype(W,/obj/item/raw_material/ )))))
			boutput(user, "<span class='alert'>The fabricator rejects the [W]. You'll need to refine them in a reclaimer first.</span>")
			playsound(src.loc, src.sound_grump, 50, 1)
			return

		else if (istype(W, src.base_material_class) && src.accept_loading(user))
			user.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>", "<span class='notice'>You load [W] into the [src].</span>")
			src.load_item(W,user)

		else if (src.panelopen && (issnippingtool(W) || ispulsingtool(W)))
			src.Attackhand(user)
			return

		else if(scan_card(W))
			return

		else
			..()
			user.lastattacked = src
			attack_particle(user,src)
			hit_twitch(src)
			if (W.hitsound)
				playsound(src.loc, W.hitsound, 50, 1)
			if (W.force)
				var/damage = W.force
				damage /= 3
				if (user.is_hulk())
					damage *= 4
				if (iscarbon(user))
					var/mob/living/carbon/C = user
					if (C.bioHolder && C.bioHolder.HasEffect("strong"))
						damage *= 2
				if (damage >= 5)
					src.take_damage(damage)

		src.updateUsrDialog()

	proc/scan_card(var/obj/item/I)
		if (istype(I, /obj/item/device/pda2))
			var/obj/item/device/pda2/P = I
			if(P.ID_card)
				I = P.ID_card
		if (istype(I, /obj/item/card/id))
			var/obj/item/card/id/ID = I
			boutput(usr, "<span class='notice'>You swipe the ID card in the card reader.</span>")
			var/datum/data/record/account = null
			account = FindBankAccountById(ID.registered_id)
			if(account)
				var/enterpin = input(usr, "Please enter your PIN number.", "Card Reader", 0) as null|num
				if (enterpin == ID.pin)
					boutput(usr, "<span class='notice'>Card authorized.</span>")
					src.scan = ID
					return 1
				else
					boutput(usr, "<span class='alert'>Pin number incorrect.</span>")
					src.scan = null
			else
				boutput(usr, "<span class='alert'>No bank account associated with this ID found.</span>")
				src.scan = null
		return 0

	MouseDrop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, "<span class='alert'>Only living mobs are able to set the manufacturer's output target.</span>")
			return

		if(get_dist(over_object,src) > 1)
			boutput(usr, "<span class='alert'>The manufacturing unit is too far away from the target!</span>")
			return

		if(get_dist(over_object,usr) > 1)
			boutput(usr, "<span class='alert'>You are too far away from the target!</span>")
			return

		if (istype(over_object,/obj/storage/crate/))
			var/obj/storage/crate/C = over_object
			if (C.locked || C.welded)
				boutput(usr, "<span class='alert'>You can't use a currently unopenable crate as an output target.</span>")
			else
				src.output_target = over_object
				boutput(usr, "<span class='notice'>You set the manufacturer to output to [over_object]!</span>")

		else if (istype(over_object,/obj/storage/cart/))
			var/obj/storage/cart/C = over_object
			if (C.locked || C.welded)
				boutput(usr, "<span class='alert'>You can't use a currently unopenable cart as an output target.</span>")
			else
				src.output_target = over_object
				boutput(usr, "<span class='notice'>You set the manufacturer to output to [over_object]!</span>")

		else if (istype(over_object,/obj/table/) || istype(over_object,/obj/rack/))
			var/obj/O = over_object
			src.output_target = O.loc
			boutput(usr, "<span class='notice'>You set the manufacturer to output on top of [O]!</span>")

		else if (istype(over_object,/turf/floor/))
			src.output_target = over_object
			boutput(usr, "<span class='notice'>You set the manufacturer to output to [over_object]!</span>")

		else
			boutput(usr, "<span class='alert'>You can't use that as an output target.</span>")
		return

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!O || !user)
			return

		if(!isliving(user))
			boutput(user, "<span class='alert'>Only living mobs are able to use the manufacturer's quick-load feature.</span>")
			return

		if (!istype(O,/obj/))
			boutput(user, "<span class='alert'>You can't quick-load that.</span>")
			return

		if(get_dist(O,user) > 1)
			boutput(user, "<span class='alert'>You are too far away!</span>")
			return


		if (istype(O, /obj/item/paper/manufacturer_blueprint))
			src.Attackby(O, user)

		if (istype(O, /obj/storage/crate/) || istype(O, /obj/storage/cart/) && src.accept_loading(user,1))
			if (O:welded || O:locked)
				boutput(user, "<span class='alert'>You cannot load from a container that cannot open!</span>")
				return

			user.visible_message("<span class='notice'>[user] uses [src]'s automatic loader on [O]!</span>", "<span class='notice'>You use [src]'s automatic loader on [O].</span>")
			var/amtload = 0
			for (var/obj/item/M in O.contents)
				if (!istype(M,src.base_material_class))
					continue
				src.load_item(M)
				amtload++
			if (amtload) boutput(user, "<span class='notice'>[amtload] materials loaded from [O]!</span>")
			else boutput(user, "<span class='alert'>No material loaded!</span>")

		else if (isitem(O) && src.accept_loading(user,1))
			user.visible_message("<span class='notice'>[user] begins quickly stuffing materials into [src]!</span>")
			var/staystill = user.loc
			for(var/obj/item/M in view(1,user))
				if (!O)
					continue
				if (!istype(M,O.type))
					continue
				if (!istype(M,src.base_material_class))
					continue
				if (O.loc == user)
					continue
				if (O in user.contents)
					continue
				src.load_item(M)
				sleep(0.5)
				if (user.loc != staystill) break
			boutput(user, "<span class='notice'>You finish stuffing materials into [src]!</span>")

		else ..()

		src.updateUsrDialog()

	proc/accept_loading(var/mob/user,var/allow_silicon = 0)
		if (!user)
			return 0
		if (src.status & BROKEN || src.status & NOPOWER)
			return 0
		if (src.dismantle_stage > 0)
			return 0
		if (!isliving(user))
			return 0
		if (issilicon(user) && !allow_silicon)
			return 0
		var/mob/living/L = user
		if (L.stat || L.transforming)
			return 0
		return 1

	proc/isWireColorCut(var/wireColor)
		var/wireFlag = APCWireColorToFlag[wireColor]
		return ((src.wires & wireFlag) == 0)

	proc/isWireCut(var/wireIndex)
		var/wireFlag = APCIndexToFlag[wireIndex]
		return ((src.wires & wireFlag) == 0)

	proc/cut(var/wireColor)
		var/wireFlag = APCWireColorToFlag[wireColor]
		var/wireIndex = APCWireColorToIndex[wireColor]
		src.wires &= ~wireFlag
		switch(wireIndex)
			if(WIRE_EXTEND)
				src.hacked = 0
			if(WIRE_SHOCK)
				src.electrified = -1
			if(WIRE_MALF)
				src.malfunction = 1
			if(WIRE_POWER)
				if(!(src.status & BROKEN || src.status & NOPOWER))
					src.manuf_zap(usr,100)
					src.status |= NOPOWER

	proc/mend(var/wireColor)
		var/wireFlag = APCWireColorToFlag[wireColor]
		var/wireIndex = APCWireColorToIndex[wireColor] //not used in this function
		src.wires |= wireFlag
		switch(wireIndex)
			if(WIRE_SHOCK)
				src.electrified = 0
			if(WIRE_MALF)
				src.malfunction = 0
			if(WIRE_POWER)
				if (!(src.status & BROKEN) && (src.status & NOPOWER))
					src.manuf_zap(usr,100)
					src.status &= ~NOPOWER

	proc/pulse(var/wireColor)
		var/wireIndex = APCWireColorToIndex[wireColor]
		switch(wireIndex)
			if(WIRE_EXTEND)
				src.hacked = !src.hacked
			if (WIRE_SHOCK)
				src.electrified = 30
			if (WIRE_MALF)
				src.malfunction = !src.malfunction
			if (WIRE_POWER)
				if(!(src.status & BROKEN || src.status & NOPOWER))
					src.manuf_zap(usr,100)

	proc/manuf_zap(mob/user, prb)
		if(issilicon(user) || isAI(user))
			return 0
		if(!prob(prb))
			return 0
		if(src.status & (BROKEN|NOPOWER))
			return 0
		if(ishuman(user))
			if (istype(user:gloves, /obj/item/clothing/gloves/yellow))
				return 0

		var/netnum = 0
		for(var/turf/T in range(1, user))
			for(var/obj/cable/C in T.contents)
				netnum = C.netnum
				break
			if (netnum) break

		if (!netnum) return 0

		if (src.electrocute(user,prb,netnum))
			return 1
		else
			return 0

	proc/add_schematic(var/schematic_path,var/add_to_list = "available")
		if (!ispath(schematic_path))
			return

		var/datum/manufacture/S = get_schematic_from_path(schematic_path)
		if (!istype(S,/datum/manufacture/))
			return

		switch(add_to_list)
			if ("hidden")
				src.hidden += S
			if ("download")
				src.download += S
			else
				src.available += S

	proc/set_up_schematics()
		for (var/X in src.available)
			if (ispath(X))
				src.add_schematic(X)
				src.available -= X

		for (var/X in src.hidden)
			if (ispath(X))
				src.add_schematic(X,"hidden")
				src.hidden -= X

	proc/match_material_pattern(pattern, datum/material/mat)
		if (!mat) // Marq fix for various cannot read null. runtimes
			return 0

		if (pattern == "ALL") // anything at all
			return 1
		else if (copytext(pattern, 4, 5) == "-") // wildcard
			var/firstpart = copytext(pattern, 1, 4)
			var/secondpart = text2num(copytext(pattern, 5))
			switch(firstpart)
				// this was kind of thrown together in a panic when i felt shitty so if its horrible
				// go ahead and clean it up a bit
				if ("MET")

					if (mat.material_flags & MATERIAL_METAL)
						// maux hardness = 15
						// bohr hardness = 33
						switch(secondpart)
							if(2) //"MET-2"
								return mat.getProperty("hard") >= 15
							if(3 to INFINITY) //"MET-3"
								return mat.getProperty("hard") >= 30
							else //"MET-1"
								return 1
				if ("CRY") //"CRY-1"
					return (mat.material_flags & MATERIAL_CRYSTAL)
				if ("REF") //"REF-1"
					return (mat.getProperty("reflective") >= 50)
				if ("CON")
					switch(secondpart)
						if(2) //"CON-2"
							return (mat.getProperty("electrical") >= 75) && (mat.material_flags & MATERIAL_METAL) || (mat.getProperty("electrical") >= 75) && (mat.material_flags & MATERIAL_CRYSTAL) //Wow! Claretine has a use again!
						else //"CON-1"
							return (mat.getProperty("electrical") >= 50) && (mat.material_flags & MATERIAL_METAL) || (mat.getProperty("electrical") >= 50) && (mat.material_flags & MATERIAL_CRYSTAL)
				if ("INS")
					switch(secondpart)
						if(2) //"INS-2"
							return mat.getProperty("electrical") <= 20 && (mat.material_flags & MATERIAL_CLOTH) || mat.getProperty("electrical") <= 20 && (mat.material_flags & MATERIAL_RUBBER)
						else //"INS-1"
							return mat.getProperty("electrical") <= 47 && (mat.material_flags & MATERIAL_CLOTH) || mat.getProperty("electrical") <= 47 && (mat.material_flags & MATERIAL_RUBBER)
				if ("DEN")
					switch(secondpart)
						if(3) //"DEN-3"
							return mat.getProperty("density") >= 75  && (mat.material_flags & MATERIAL_CRYSTAL)
						if(2) //"DEN-2"
							return mat.getProperty("density") >= 60  && (mat.material_flags & MATERIAL_CRYSTAL)
						else //"DEN-1"
							return mat.getProperty("density") >= 40  && (mat.material_flags & MATERIAL_CRYSTAL)
				if ("POW")
					if (mat.material_flags & MATERIAL_ENERGY)
						switch(secondpart)
							if(3) //"POW-3"
								return mat.getProperty("radioactive") >= 55 //soulsteel and erebite basically
							if(2) //"POW-2"
								return mat.getProperty("radioactive") >= 10
							else //"POW-1"
								return 1
				if ("FAB") //"FAB-1"
					return mat.material_flags & MATERIAL_CLOTH || mat.material_flags & MATERIAL_RUBBER || mat.material_flags & MATERIAL_ORGANIC
		else if (pattern == mat.mat_id) // specific material id
			return 1
		return 0

	proc/get_materials_needed(datum/manufacture/M) // returns associative list of item_paths with the mat_ids they're gonna use; does not guarantee all item_paths are satisfied
		var/list/mats_used = list()
		var/list/mats_available = src.resource_amounts.Copy()

		for (var/i in 1 to M.item_paths.len)
			var/pattern = M.item_paths[i]
			var/amount = M.item_amounts[i]
			for (var/mat_id in mats_available)
				if (mats_available[mat_id] < amount)
					continue
				var/datum/material/mat = getMaterial(mat_id)
				if (match_material_pattern(pattern, mat)) // TODO: refactor proc cuz this is bad
					mats_used[pattern] = mat_id
					mats_available[mat_id] -= amount
					break

		return mats_used

	proc/check_enough_materials(datum/manufacture/M)
		var/list/mats_used = get_materials_needed(M)
		if (mats_used.len == M.item_paths.len) // we have enough materials, so return the materials list, else return null
			return mats_used

	proc/remove_materials(datum/manufacture/M)
		for (var/i = 1 to M.item_paths.len)
			var/pattern = M.item_paths[i]
			var/mat_id = src.materials_in_use[pattern]
			if (mat_id)
				var/amount = M.item_amounts[i]
				src.update_resource_amount(mat_id, -amount)
				for (var/obj/item/I in src.contents)
					if (I.material && istype(I, src.base_material_class) && I.material.mat_id == mat_id)
						var/target_amount = round(src.resource_amounts[mat_id] / 10)
						if (!target_amount)
							src.contents -= I
							qdel(I)
						else if (I.amount != target_amount)
							I.change_stack_amount(-(I.amount - target_amount))
						break

	proc/begin_work(var/new_production = 1)
		if (status & NOPOWER || status & BROKEN)
			return
		if (!src.queue.len)
			src.manual_stop = 0
			src.mode = "ready"
			src.build_icon()
			src.updateUsrDialog()
			return
		if (!istype(src.queue[1],/datum/manufacture/))
			src.mode = "halt"
			src.error = "Corrupted entry purged from production queue."
			src.queue -= src.queue[1]
			src.visible_message("<span class='alert'>[src] emits an angry buzz!</span>")
			playsound(src.loc, src.sound_grump, 50, 1)
			src.build_icon()
			return

		var/datum/manufacture/M = src.queue[1]
		//Wire: Fix for href exploit creating arbitrary items
		if (!(M in src.available + src.hidden + src.download))
			src.mode = "halt"
			src.error = "Corrupted entry purged from production queue."
			src.queue -= src.queue[1]
			src.visible_message("<span class='alert'>[src] emits an angry buzz!</span>")
			playsound(src.loc, src.sound_grump, 50, 1)
			src.build_icon()
			return

		src.error = null

		if (src.malfunction && prob(40))
			src.flip_out()

		if (new_production)
			var/list/mats_used = check_enough_materials(M)

			if (!mats_used)
				src.mode = "halt"
				src.error = "Insufficient usable materials to continue queue production."
				src.visible_message("<span class='alert'>[src] emits an angry buzz!</span>")
				playsound(src.loc, src.sound_grump, 50, 1)
				src.build_icon()
				return
			else
				src.materials_in_use = mats_used

			// speed/power usage
			// spd   time    new     old (1500 * speed * 1.5)
			// 1:    10.0s     750   2250
			// 2:     5.0s    3000   4500
			// 3:     3.3s    6750   6750
			// 4:     2.5s   12000   9000
			// 5:     2.0s   18750  11250
			src.powconsumption = 750 * src.speed ** 2
			src.timeleft = M.time
			if (src.malfunction)
				src.powconsumption += 3000
				src.timeleft += rand(2,6)
				src.timeleft *= 1.5
			src.timeleft /= src.speed
			///
		playsound(src.loc, src.sound_beginwork, 50, 1, 0, 3)
		src.mode = "working"
		src.build_icon()

		src.action_bar = actions.start(new/datum/action/bar/manufacturer(src, src.timeleft), src)


	proc/output_loop(var/datum/manufacture/M)

		if (!istype(M,/datum/manufacture/))
			return

		if (M.item_outputs.len <= 0)
			return
		var/mcheck = check_enough_materials(M)
		if(mcheck)
			var/make = max(0,min(M.create,src.output_cap))
			switch(M.randomise_output)
				if(1) // pick a new item each loop
					while (make > 0)
						src.dispense_product(pick(M.item_outputs),M)
						make--
				if(2) // get a random item from the list and produce it
					var/to_make = pick(M.item_outputs)
					while (make > 0)
						src.dispense_product(to_make,M)
						make--
				else // produce every item in the list once per loop
					while (make > 0)
						for (var/X in M.item_outputs)
							src.dispense_product(X,M)
						make--

			src.remove_materials(M)

		return

	proc/dispense_product(var/product,var/datum/manufacture/M)
		if (ispath(product))
			if (istype(M,/datum/manufacture/))
				var/atom/movable/A = new product(src)
				if (isitem(A))
					var/obj/item/I = A
					M.modify_output(src, I, src.materials_in_use)
					I.set_loc(src.get_output_location(I))
				else
					A.set_loc(src.get_output_location(A))
			else
				new product(get_output_location())

		else if (istext(product) || isnum(product))
			if (istext(product) && copytext(product,1,8) == "reagent")
				var/the_reagent = copytext(product,9,length(product) + 1)
				if (M.create != 0)
					src.reagents.add_reagent(the_reagent,M.create / 10)
			else
				src.visible_message("<b>[src.name]</b> says, \"[product]\"")

		else if (isicon(product)) // adapted from vending machine code
			var/icon/welp = icon(product)
			if (welp.Width() > 32 || welp.Height() > 32)
				welp.Scale(32, 32)
				product = welp
			var/obj/dummy = new /obj/item(get_turf(src))
			dummy.name = "strange thing"
			dummy.desc = "The fuck is this?"
			dummy.icon = welp

		else if (isfile(product)) // adapted from vending machine code
			var/S = sound(product)
			if (S)
				playsound(src.loc, S, 50, 0)

		else if (isobj(product))
			var/obj/X = product
			X.set_loc(get_output_location())

		else if (ismob(product))
			var/mob/X = product
			X.set_loc(get_output_location())

	proc/flip_out()
		if (status & BROKEN || status & NOPOWER || !src.malfunction)
			return
		animate_shake(src,5,rand(3,8),rand(3,8))
		src.visible_message("<span class='alert'>[src] makes [pick(src.text_flipout_adjective)] [pick(src.text_flipout_noun)]!</span>")
		playsound(src.loc, pick(src.sounds_malfunction), 50, 2)
		if (prob(15) && src.contents.len > 4 && src.mode != "working")
			var/to_throw = rand(1,4)
			var/obj/item/X = null
			while(to_throw > 0)
				if(!src.nearby_turfs.len) //SpyGuy for RTE "pick() from empty list"
					break
				X = pick(src.contents)
				X.set_loc(src.loc)
				X.throw_at(pick(src.nearby_turfs), 16, 3)
				to_throw--
		if (src.queue.len > 1 && prob(20))
			var/list_counter = 0
			for (var/datum/manufacture/X in src.queue)
				list_counter++
				if (list_counter == 1)
					continue
				if (prob(33))
					src.queue -= X
		if (src.mode == "working")
			if (prob(5))
				src.mode = "halt"
				src.build_icon()
			else
				if (prob(10))
					src.powconsumption *= 2
		if (prob(10))
			src.speed = rand(1,8)
		if (prob(5))
			if (!src.electrified)
				src.electrified = 5

	proc/build_icon()
		icon_state = "fab[src.icon_base ? "-[src.icon_base]" : null]"

		if (status & BROKEN)
			src.UpdateOverlays(null, "work")
			src.UpdateOverlays(null, "activity")
			icon_state = "[src.icon_base ? src.icon_base : "fab"]-broken"
		else if (src.dismantle_stage >= 2)
			src.UpdateOverlays(null, "work")
			src.UpdateOverlays(null, "activity")
			icon_state = "fab-noplate"

		if (!(status & NOPOWER) && !(status & BROKEN))
			if (src.malfunction && prob(50))
				switch  (rand(1,4))
					if (1) src.activity_display.icon_state = "light-ready"
					if (2) src.activity_display.icon_state = "light-halt"
					if (3) src.activity_display.icon_state = "light-working"
					else src.activity_display.icon_state = "light-malf"
			else
				src.activity_display.icon_state = "light-[src.mode]"

			var/animspeed = src.speed
			if (animspeed < 1 || animspeed > 5 || (src.malfunction && prob(50)))
				animspeed = "malf"

			if (src.mode == "working")
				src.work_display.icon_state = "fab-work[animspeed]"
			else
				src.work_display.icon_state = ""

			src.UpdateOverlays(src.work_display, "work")
			src.UpdateOverlays(src.activity_display, "activity")

		if (src.panelopen)
			src.panel_sprite.icon_state = "fab-panel"
			src.UpdateOverlays(src.panel_sprite, "panel")
		else
			src.UpdateOverlays(null, "panel")

	proc/build_material_list()
		var/list/dat = list()
		dat += {"
<table class="outline" style="width: 100%;">
	<thead>
		<tr><th colspan='2'>Loaded Materials</th></tr>
	</thead>
	<tbody>
		"}
		for(var/mat_id in src.resource_amounts)
			var/datum/material/mat = getMaterial(mat_id)
			dat += {"
		<tr>
			<td><a href='byond://?src=\ref[src];eject=[mat_id]' class='buttonlink'>&#9167;</a> [mat]</td>
			<td class='r'>[src.resource_amounts[mat_id]]</td>
		</tr>
			"}
		if (dat.len == 1)
			dat += {"
		<tr>
			<td colspan='2' class='c'>No materials loaded.</td>
		</tr>
			"}


		if (src.reagents.total_volume > 0)
			dat += {"
		<tr><th colspan='2'>Loaded Reagents</th></tr>
			"}
			for(var/current_id in src.reagents.reagent_list)
				var/datum/reagent/current_reagent = src.reagents.reagent_list[current_id]
				dat += {"
		<tr>
			<td><a href='byond://?src=\ref[src];flush=[current_reagent.name]'>[current_reagent.name]</a></td>
			<td class='r'>[current_reagent.volume] units</td>
		</tr>
				"}

		if (src.beaker)
			dat += {"
		<tr><th colspan='2'>Container</th></tr>
			"}

			dat += {"
		<tr><td colspan='2'><a href='byond://?src=\ref[src];ejectbeaker=\ref[src.beaker]' class='buttonlink'>&#9167;</a> [src.beaker.name]<br>([round(src.beaker.reagents.total_volume)]/[src.beaker.reagents.maximum_volume])</td></tr>
		<tr><td class='c'>
			"}
			if (src.reagents.total_volume && src.beaker.reagents.total_volume < src.beaker.reagents.maximum_volume)
				dat += {"
				<a href='byond://?src=\ref[src];transto=\ref[src.beaker]'>Transfer<br>Machine &rarr; Container</a>
				"}
			else
				dat += {"
				&nbsp;
				"}

			dat += {"
		</td><td class='c'>
			"}

			if (src.beaker.reagents.total_volume > 0)
				dat += {"
				<a href='byond://?src=\ref[src];transfrom=\ref[src.beaker]'>Transfer<br>Container &rarr; Machine</a>"
				"}

			dat += {"
		</td></tr>
			"}
		dat += {"
	</tbody>
</table>
			"}

		return dat.Join()

	proc/build_control_panel(mob/user as mob)
		var/list/dat = list()

		var/list/speed_opts = list()
		for (var/i in 1 to (src.hacked ? 5 : 3))
			speed_opts += "<a href='byond://?src=\ref[src];speed=[i]' class='buttonlink' style='[i == src.speed ? "font-weight: bold; background: #6c6;" : ""]'>[i]</a>"

		if (src.speed > (src.hacked ? 5 : 3))
			// sometimes people get these set to wacky values
			speed_opts += "<a href='byond://?src=\ref[src];speed=[src.speed]' class='buttonlink' style='font-weight: bold; background: #c66;'>[src.speed]</a>"

		dat += {"
			<br>
			<table style='width: 100%:'>
				<thead><tr><th style='width: 50%:'>Speed</th><th style='width: 50%:'>Repeat</th></tr></thead>
				<tbody><tr>
					<td class='c'>[speed_opts.Join(" ")]</td>
					<td class='c'><a href='byond://?src=\ref[src];repeat=1'>[src.repeat ? "Yes" : "No"]</a></td>
				</tr></tbody>
			</table>

			"}
		if (src.error)
			dat += "<br><b>ERROR: [src.error]</b><br>"

		var/queue_num = 1
		for(var/datum/manufacture/A in src.queue)

			var/time_number = 0
			var/remove_link = ""
			var/pause_link = ""
			if (queue_num == 1)
				// if (istype(A,/datum/manufacture/) && src.speed != 0 && timeleft != 0)
				// 	time_number = round(src.timeleft / src.speed)
				pause_link = (src.mode == "working" ? "<a href='byond://?src=\ref[src];pause=1' class='queuelinks'>&#9208; Pause</a>" : "<a href='byond://?src=\ref[src];continue=1' class='queuelinks'>Resume</a>") + "<br>"
			else
				pause_link = ""

			time_number = A.time && src.speed ? round(A.time / src.speed / 10, 0.1) : "??"

			if (src.mode != "working" || queue_num != 1)
				remove_link = "<a href='byond://?src=\ref[src];removefromQ=[queue_num]' class='queuelinks'>&#128465; Remove</a>"
			else
				// shut up
				remove_link = "&#8987; Working..."

			var/icon_text = "<img class='icon'>"
			if (A.item_outputs)
				var/icon_rsc = getItemIcon(A.item_outputs[1], C = usr.client)
				// usr << browse_rsc(browse_item_icons[icon_rsc], icon_rsc)
				icon_text = "<img class='icon' src='[icon_rsc]'>"

			if (istype(A, /datum/manufacture/mechanics))
				var/datum/manufacture/mechanics/F = A
				var/icon_rsc = getItemIcon(F.frame_path, C = usr.client)
				// user << browse_rsc(browse_item_icons[icon_rsc], icon_rsc)
				icon_text = "<img class='icon' src='[icon_rsc]'>"


			dat += {"
		<div class='queue'>
			[icon_text]
			<strong>[A.name]</strong>
			<br>[time_number] sec.
		</div><div style='display: inline-block; vertical-align: middle;'>
		[pause_link]
		[remove_link]
		</div>
		<br>
		"}

			queue_num++

		return dat.Join()

	proc/load_item(var/obj/item/O,var/mob/living/user)
		if (!O)
			return

		if (user)
			user.u_equip(O)
			O.dropped()

		if (istype(O, src.base_material_class) && O.material)
			var/obj/item/material_piece/P = O
			for(var/obj/item/material_piece/M in src.contents)
				if (istype(M, P) && M.material && isSameMaterial(M.material, P.material))
					M.change_stack_amount(P.amount)
					src.update_resource_amount(M.material.mat_id, P.amount * 10)
					qdel(P)
					return
			src.update_resource_amount(P.material.mat_id, P.amount * 10)

		O.set_loc(src)

	proc/take_damage(var/damage_amount = 0)
		if (!damage_amount)
			return
		src.health -= damage_amount
		src.health = max(0,min(src.health,100))
		if (damage_amount > 0)
			playsound(src.loc, src.sound_damaged, 50, 2)
			if (src.health == 0)
				src.visible_message("<span class='alert'><b>[src.name] is destroyed!</b></span>")
				playsound(src.loc, src.sound_destroyed, 50, 2)
				robogibs(src.loc, null)
				qdel(src)
				return
			if (src.health <= 70 && !src.malfunction && prob(33))
				src.malfunction = 1
				src.flip_out()
			if (src.malfunction && prob(40))
				src.flip_out()
			if (src.health <= 25 && !(src.status & BROKEN))
				src.visible_message("<span class='alert'><b>[src.name] breaks down and stops working!</b></span>")
				src.status |= BROKEN
		else
			if (src.health >= 60 && src.status & BROKEN)
				src.visible_message("<span class='alert'><b>[src.name] looks like it can function again!</b></span>")
				status &= ~BROKEN

		src.build_icon()

	proc/update_resource_amount(mat_id, amt)
		src.resource_amounts[mat_id] = max(src.resource_amounts[mat_id] + amt, 0)

	proc/claim_free_resources()
		if (src.deconstruct_flags & DECON_BUILT)
			free_resource_amt = 0
		else if (free_resources.len && free_resource_amt > 0)
			for (var/X in src.free_resources)
				if (ispath(X))
					var/obj/item/material_piece/P = new X()
					P.set_loc(src)
					if (free_resource_amt > 1)
						P.change_stack_amount(free_resource_amt - P.amount)
					src.update_resource_amount(P.material.mat_id, free_resource_amt * 10)
			free_resource_amt = 0
		else
			logTheThing("debug", null, null, "<b>obj/manufacturer:</b> [src.name]-[src.type] empty free resources list!")

	proc/get_output_location(var/atom/A,var/ejection = 0)
		if (!src.output_target)
			return src.loc

		if (get_dist(src.output_target,src) > 1)
			src.output_target = null
			return src.loc

		if (istype(src.output_target,/obj/storage/crate/))
			var/obj/storage/crate/C = src.output_target
			if (C.locked || C.welded)
				src.output_target = null
				return src.loc
			else
				if (C.open)
					return C.loc
				else
					return C
		if (istype(src.output_target,/obj/storage/cart/))
			var/obj/storage/cart/C = src.output_target
			if (C.locked || C.welded)
				src.output_target = null
				return src.loc
			else
				if (C.open)
					return C.loc
				else
					return C
		else if (istype(src.output_target,/obj/machinery/manufacturer))
			var/obj/machinery/manufacturer/M = src.output_target
			if (M.status & BROKEN || M.status & NOPOWER || M.dismantle_stage > 0)
				src.output_target = null
				return src.loc
			if (A && istype(A,M.base_material_class))
				return M
			else
				return M.loc

		else if (istype(src.output_target,/turf/floor/))
			return src.output_target

		else
			return src.loc

/obj/machinery/manufacturer/malfunction_hint()
	if (src in random_events.maintenance_event.unmaintained_machines)
		return "Open the maintenance hatch and replace the manufacturer's wiring."
	return FALSE

// Blueprints

/obj/item/paper/manufacturer_blueprint
	name = "Manufacturer Blueprint"
	desc = "It's a blueprint to allow a manufacturing unit to build something."
	info = "There's all manner of confusing diagrams and instructions on here. It's meant for a machine to read."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "blueprint"
	item_state = "sheet"
	var/datum/manufacture/blueprint = null
	var/override_name_desc = 1
	rand_pos = 4



 	//TODO : pooling i guess cause other paper does
	New(var/loc,var/schematic = null)
		..()
		if(istype(schematic, /datum/manufacture))
			src.blueprint = schematic
		else if (!schematic)
			if (ispath(src.blueprint))
				src.blueprint = get_schematic_from_path(src.blueprint)
			else
				qdel(src)
				return 0
		else
			if (istext(schematic))
				src.blueprint = get_schematic_from_name(schematic)
			else if (ispath(schematic))
				src.blueprint = get_schematic_from_path(schematic)

		if (!src.blueprint)
			qdel(src)
			return 0
		if(src.override_name_desc)
			src.name = "Manufacturer Blueprint: [src.blueprint.name]"
			src.desc = "This blueprint will allow a manufacturer unit to build a [src.blueprint.name]"

		return 1

/******************** Cloner Blueprints *******************/

/obj/item/cloner_blueprints_folder
	name = "dirty manilla folder"
	desc = "An old manilla folder covered in stains. It looks like it'll fall apart at the slightest touch."
	icon = 'icons/obj/items/writing.dmi'
	icon_state = "folder"
	w_class = W_CLASS_SMALL
	throwforce = 0
	w_class = W_CLASS_NORMAL
	throw_speed = 3
	throw_range = 10

	attack_self(mob/user as mob)
		boutput(user, "<span class='alert'>The folder disintegrates in your hands, and papers scatter out. Shit!</span>")
		new /obj/item/paper/manufacturer_blueprint/clonepod(get_turf(src))
		new /obj/item/paper/manufacturer_blueprint/clonegrinder(get_turf(src))
		new /obj/item/paper/manufacturer_blueprint/clone_scanner(get_turf(src))
		new /obj/item/paper/hecate(get_turf(src))
		qdel(src)

/obj/item/paper/manufacturer_blueprint/clonepod
	blueprint = /datum/manufacture/mechanics/clonepod

/obj/item/paper/manufacturer_blueprint/clonegrinder
	blueprint = /datum/manufacture/mechanics/clonegrinder

/obj/item/paper/manufacturer_blueprint/clone_scanner
	blueprint = /datum/manufacture/mechanics/clone_scanner

/******************** Loafer Blueprints *******************/

/obj/item/paper/manufacturer_blueprint/loafer
	blueprint = /datum/manufacture/mechanics/loafer



/******************** AI Display Blueprints (should be temporary but we know how that goes in coding) *******************/

/obj/item/paper/manufacturer_blueprint/ai_status_display
	blueprint = /datum/manufacture/mechanics/ai_status_display


/******************** Alastor Pattern Thruster Blueprints *******************/
/obj/item/paper/manufacturer_blueprint/thrusters
	icon = 'icons/obj/items/writing.dmi'
	icon_state = "blueprint"
	desc = "Seems like theres traces of charcoal on the paper. Huh."
	blueprint = /datum/manufacture/thrusters

/******************** Spatial Interdictor *******************/

/obj/item/paper/manufacturer_blueprint/interdictor_frame
	name = "Interdictor Frame Kit"
	icon = 'icons/obj/items/writing.dmi'
	icon_state = "interdictor_blueprint"
	blueprint = /datum/manufacture/interdictor_frame

/obj/item/paper/manufacturer_blueprint/interdictor_rod_lambda
	name = "Lambda Phase-Control Rod"
	icon = 'icons/obj/items/writing.dmi'
	icon_state = "interdictor_blueprint"
	blueprint = /datum/manufacture/interdictor_rod_lambda

/obj/item/paper/manufacturer_blueprint/interdictor_rod_sigma
	name = "Sigma Phase-Control Rod"
	icon = 'icons/obj/items/writing.dmi'
	icon_state = "interdictor_blueprint"
	blueprint = /datum/manufacture/interdictor_rod_sigma

/******************** Phaser Drone *******************/
/obj/item/paper/manufacturer_blueprint/gunbot
	name = "Security Robot blueprint"
	icon = 'icons/obj/electronics.dmi'
	info = "<h3>AP-Class Security Robot</h3><i>A schematic blueprint for a security robot, modified to fit a station-grade manufacturer.</i>"
	icon_state = "blueprint"
	item_state = "sheet"
	blueprint = /datum/manufacture/mechanics/gunbot
	override_name_desc = 0

// Fabricator Defines

/obj/machinery/manufacturer/general
	name = "General Manufacturer"
	desc = "A manufacturing unit calibrated to produce tools and general purpose items."
	free_resource_amt = 5
	free_resources = list(/obj/item/material_piece/steel,
		/obj/item/material_piece/copper,
		/obj/item/material_piece/glass)
	available = list(/datum/manufacture/screwdriver,
		/datum/manufacture/wirecutters,
		/datum/manufacture/wrench,
		/datum/manufacture/crowbar,
		/datum/manufacture/extinguisher,
		/datum/manufacture/welder,
		/datum/manufacture/soldering,
		/datum/manufacture/flashlight,
		/datum/manufacture/weldingmask,
		/datum/manufacture/multitool,
		/datum/manufacture/metal,
		/datum/manufacture/metalR,
		/datum/manufacture/rods2,
		/datum/manufacture/glass,
		/datum/manufacture/glassR,
		/datum/manufacture/atmos_can,
		/datum/manufacture/player_module,
		/datum/manufacture/cable,
		/datum/manufacture/powercell,
		/datum/manufacture/powercellE,
		/datum/manufacture/powercellC,
		/datum/manufacture/light_bulb,
		/datum/manufacture/light_tube,
		/datum/manufacture/table_folding,
		/datum/manufacture/hardhat,
		/datum/manufacture/jumpsuit,
		/datum/manufacture/shoes,
		/datum/manufacture/breathmask,
		/datum/manufacture/fluidcanister,
#ifndef NO_EASY_BEAKERS
		/datum/manufacture/chemicalcan,
#endif
		/datum/manufacture/patch)
	hidden = list(/datum/manufacture/RCDammo,
		/datum/manufacture/RCDammomedium,
		/datum/manufacture/RCDammolarge,
		/datum/manufacture/bottle,
		/datum/manufacture/vuvuzela,
		/datum/manufacture/harmonica,
		/datum/manufacture/bikehorn,
		//datum/manufacture/bullet_22,
		//datum/manufacture/bullet_smoke,
		/datum/manufacture/stapler)

/obj/machinery/manufacturer/glasswares
	name = "Glass Manufacturer"
	desc = "A manufacturing unit calibrated to produce specialty glass objects"
	icon_state = "fab-glass"
	icon_base = "glass"
	free_resource_amt = 4
	free_resources = list(/obj/item/material_piece/glass,
		/obj/item/material_piece/copper)
	available = list(/datum/manufacture/light_bulb,
		/datum/manufacture/red_bulb,
		/datum/manufacture/yellow_bulb,
		/datum/manufacture/green_bulb,
		/datum/manufacture/cyan_bulb,
		/datum/manufacture/blue_bulb,
		/datum/manufacture/purple_bulb,
		/datum/manufacture/blacklight_bulb,
		/datum/manufacture/light_tube,
		/datum/manufacture/red_tube,
		/datum/manufacture/yellow_tube,
		/datum/manufacture/green_tube,
		/datum/manufacture/cyan_tube,
		/datum/manufacture/blue_tube,
		/datum/manufacture/purple_tube,
		/datum/manufacture/blacklight_tube,
		/datum/manufacture/glass,
		/datum/manufacture/glassR,
		/datum/manufacture/prodocs,
		/datum/manufacture/glasses)

/obj/machinery/manufacturer/robotics
	name = "Robotics Fabricator"
	desc = "A manufacturing unit calibrated to produce robot-related equipment."
	icon_state = "fab-robotics"
	icon_base = "robotics"
	free_resource_amt = 5
	free_resources = list(/obj/item/material_piece/steel,
		/obj/item/material_piece/copper,
		/obj/item/material_piece/glass)

	available = list(/datum/manufacture/robo_frame,
	/datum/manufacture/full_cyborg_standard,
	/datum/manufacture/full_cyborg_light,
	/datum/manufacture/robo_head,
	/datum/manufacture/robo_chest,
	/datum/manufacture/robo_arm_r,
	/datum/manufacture/robo_arm_l,
	/datum/manufacture/robo_leg_r,
	/datum/manufacture/robo_leg_l,
	/datum/manufacture/robo_head_light,
	/datum/manufacture/robo_chest_light,
	/datum/manufacture/robo_arm_r_light,
	/datum/manufacture/robo_arm_l_light,
	/datum/manufacture/robo_leg_r_light,
	/datum/manufacture/robo_leg_l_light,
	/datum/manufacture/robo_leg_treads,
	/datum/manufacture/robo_head_screen,
	/datum/manufacture/robo_module,
	/datum/manufacture/cyberheart,
	/datum/manufacture/cybereye,
	/datum/manufacture/cybereye_meson,
	/datum/manufacture/cybereye_spectro,
	/datum/manufacture/cybereye_prodoc,
	/datum/manufacture/cybereye_camera,
	/datum/manufacture/core_frame,
	/datum/manufacture/shell_frame,
	/datum/manufacture/ai_interface,
	/datum/manufacture/latejoin_brain,
	/datum/manufacture/shell_cell,
	/datum/manufacture/cable,
	/datum/manufacture/powercell,
	/datum/manufacture/powercellE,
	/datum/manufacture/powercellC,
	/datum/manufacture/crowbar,
	/datum/manufacture/wrench,
	/datum/manufacture/screwdriver,
	/datum/manufacture/scalpel,
	/datum/manufacture/circular_saw,
	/datum/manufacture/surgical_scissors,
	/datum/manufacture/hemostat,
	/datum/manufacture/suture,
	/datum/manufacture/stapler,
	/datum/manufacture/surgical_spoon,
	/datum/manufacture/implanter,
	/datum/manufacture/secbot,
	/datum/manufacture/medbot,
	/datum/manufacture/firebot,
	/datum/manufacture/floorbot,
	/datum/manufacture/cleanbot,
	/datum/manufacture/digbot,
	/datum/manufacture/visor,
	/datum/manufacture/deafhs,
	/datum/manufacture/robup_jetpack,
	/datum/manufacture/robup_healthgoggles,
	/datum/manufacture/robup_sechudgoggles,
	/datum/manufacture/robup_spectro,
	/datum/manufacture/robup_recharge,
	/datum/manufacture/robup_repairpack,
	/datum/manufacture/robup_speed,
	/datum/manufacture/robup_meson,
	/datum/manufacture/robup_aware,
	/datum/manufacture/robup_physshield,
	/datum/manufacture/robup_fireshield,
	/datum/manufacture/robup_teleport,
	/datum/manufacture/robup_visualizer,
	/*/datum/manufacture/robup_thermal,*/
	/datum/manufacture/robup_efficiency,
	/datum/manufacture/robup_repair,
	/datum/manufacture/implant_robotalk,
	/datum/manufacture/sbradio,
	/datum/manufacture/implant_health,
	/datum/manufacture/implant_antirot,
	/datum/manufacture/cyberappendix,
	/datum/manufacture/cyberpancreas,
	/datum/manufacture/cyberspleen,
	/datum/manufacture/cyberintestines,
	/datum/manufacture/cyberstomach,
	/datum/manufacture/cyberkidney,
	/datum/manufacture/cyberliver,
	/datum/manufacture/cyberlung_left,
	/datum/manufacture/cyberlung_right,
	/datum/manufacture/rods2,
	/datum/manufacture/metal,
	/datum/manufacture/glass)

	hidden = list(/datum/manufacture/flash,
	/datum/manufacture/cybereye_thermal,
	/datum/manufacture/cybereye_laser,
	/datum/manufacture/cyberbutt,
	/datum/manufacture/robup_expand)

/obj/machinery/manufacturer/medical
	name = "Medical Fabricator"
	desc = "A manufacturing unit calibrated to produce medical equipment."
	icon_state = "fab-med"
	icon_base = "med"
	free_resource_amt = 2
	free_resources = list(/obj/item/material_piece/steel,
		/obj/item/material_piece/copper,
		/obj/item/material_piece/glass,
		/obj/item/material_piece/cloth/cottonfabric)

	available = list(
		/datum/manufacture/scalpel,
		/datum/manufacture/circular_saw,
		/datum/manufacture/surgical_scissors,
		/datum/manufacture/hemostat,
		/datum/manufacture/tweezers,
		/datum/manufacture/suture,
		/datum/manufacture/stapler,
		/datum/manufacture/surgical_spoon,
		/datum/manufacture/prodocs,
		/datum/manufacture/glasses,
		/datum/manufacture/visor,
		/datum/manufacture/deafhs,
		/datum/manufacture/hypospray,
		/datum/manufacture/patch,
		/datum/manufacture/mender,
		/datum/manufacture/penlight,
		/datum/manufacture/stethoscope,
		/datum/manufacture/latex_gloves,
		/datum/manufacture/surgical_mask,
		/datum/manufacture/surgical_shield,
		/datum/manufacture/scrubs_white,
		/datum/manufacture/scrubs_teal,
		/datum/manufacture/scrubs_maroon,
		/datum/manufacture/scrubs_blue,
		/datum/manufacture/scrubs_purple,
		/datum/manufacture/scrubs_orange,
		/datum/manufacture/scrubs_pink,
		/datum/manufacture/patient_gown,
		/datum/manufacture/eyepatch,
		/datum/manufacture/blindfold,
		/datum/manufacture/muzzle,
		/datum/manufacture/body_bag,
		/datum/manufacture/implanter,
		/datum/manufacture/implant_health,
		/datum/manufacture/implant_antirot,
		/datum/manufacture/crowbar,
		/datum/manufacture/extinguisher,
		/datum/manufacture/cyberappendix,
		/datum/manufacture/cyberpancreas,
		/datum/manufacture/cyberspleen,
		/datum/manufacture/cyberintestines,
		/datum/manufacture/cyberstomach,
		/datum/manufacture/cyberkidney,
		/datum/manufacture/cyberliver,
		/datum/manufacture/cyberlung_left,
		/datum/manufacture/cyberlung_right,
		/datum/manufacture/empty_kit,
		/datum/manufacture/rods2,
		/datum/manufacture/metal,
		/datum/manufacture/glass
	)

	hidden = list(/datum/manufacture/cyberheart,
	/datum/manufacture/cybereye)

/obj/machinery/manufacturer/mining
	name = "Mining Fabricator"
	desc = "A manufacturing unit calibrated to produce mining related equipment."
	icon_state = "fab-mining"
	icon_base = "mining"
	free_resource_amt = 2
	free_resources = list(/obj/item/material_piece/steel,
		/obj/item/material_piece/copper,
		/obj/item/material_piece/glass)
	available = list(/datum/manufacture/pick,
	/datum/manufacture/powerpick,
	/datum/manufacture/blastchargeslite,
	/datum/manufacture/blastcharges,
	/datum/manufacture/powerhammer,
	/datum/manufacture/drill,
	/datum/manufacture/conc_gloves,
	/datum/manufacture/digbot,
	/datum/manufacture/jumpsuit,
	/datum/manufacture/shoes,
	/datum/manufacture/breathmask,
	/datum/manufacture/engspacesuit,
	/datum/manufacture/industrialarmor,
	/datum/manufacture/industrialcombatarmor,
	/datum/manufacture/industrialboots,
	/datum/manufacture/powercell,
	/datum/manufacture/powercellE,
	/datum/manufacture/powercellC,
	/datum/manufacture/ore_scoop,
	/datum/manufacture/oresatchel,
	/datum/manufacture/oresatchelL,
	/datum/manufacture/jetpack,
	/datum/manufacture/geoscanner,
	/datum/manufacture/geigercounter,
	/datum/manufacture/eyes_meson,
	/datum/manufacture/flashlight,
	/datum/manufacture/ore_accumulator,
	/datum/manufacture/rods2,
	/datum/manufacture/metal,
#ifdef UNDERWATER_MAP
	/datum/manufacture/jetpackmkII,
#endif
#ifndef UNDERWATER_MAP
	/datum/manufacture/mining_magnet
#endif
	)

	hidden = list(/datum/manufacture/RCD,
	/datum/manufacture/RCDammo,
	/datum/manufacture/RCDammomedium,
	/datum/manufacture/RCDammolarge)

/obj/machinery/manufacturer/hangar
	name = "Ship Component Fabricator"
	desc = "A manufacturing unit calibrated to produce parts for ships."
	icon_state = "fab-hangar"
	icon_base = "hangar"
	free_resource_amt = 2
	free_resources = list(/obj/item/material_piece/steel,
		/obj/item/material_piece/copper,
		/obj/item/material_piece/glass)
	available = list(
#ifdef UNDERWATER_MAP
		/datum/manufacture/sub/engine,
		/datum/manufacture/sub/boards,
		/datum/manufacture/sub/control,
		/datum/manufacture/sub/parts,
#else
		/datum/manufacture/putt/engine,
		/datum/manufacture/putt/boards,
		/datum/manufacture/putt/control,
		/datum/manufacture/putt/parts,
#endif
		/datum/manufacture/pod/engine,
		/datum/manufacture/pod/boards,
		/datum/manufacture/pod/armor_light,
		/datum/manufacture/pod/armor_heavy,
		/datum/manufacture/pod/armor_industrial,
		/datum/manufacture/pod/control,
		/datum/manufacture/pod/parts,
		/datum/manufacture/cargohold,
		/datum/manufacture/orescoop,
		/datum/manufacture/conclave,
		/datum/manufacture/communications/mining,
		/datum/manufacture/pod/weapon/mining,
		/datum/manufacture/pod/weapon/mining/drill,
		/datum/manufacture/pod/weapon/ltlaser,
		/datum/manufacture/engine2,
		/datum/manufacture/engine3,
		/datum/manufacture/pod/lock,
		/datum/manufacture/beaconkit,
		/datum/manufacture/tripod,
		/datum/manufacture/tripod_bulb
	)

/obj/machinery/manufacturer/uniform // add more stuff to this as needed, but it should be for regular uniforms the HoP might hand out, not tons of gimmicks. -cogwerks
	name = "Uniform Manufacturer"
	desc = "A manufacturing unit calibrated to produce workplace uniforms."
	icon_state = "fab-jumpsuit"
	icon_base = "jumpsuit"
	free_resource_amt = 5
	free_resources = list(/obj/item/material_piece/cloth/cottonfabric)
	accept_blueprints = 0
	available = list(UNIFORM_LIST)
	hidden = list(/datum/manufacture/breathmask,
	/datum/manufacture/patch,
	/datum/manufacture/hat_ltophat)
	///datum/manufacture/hermes) //all hail the shoe lord - needs adjusting for the new movement system which I cba to do right now

/// cogwerks - a gas extractor for the engine

/obj/machinery/manufacturer/gas
	name = "Gas Extractor"
	desc = "A manufacturing unit that can produce gas canisters from certain ores."
	icon_state = "fab-atmos"
	icon_base = "atmos"
	accept_blueprints = 0
	available = list(
	/datum/manufacture/atmos_can)

	var/refill = FALSE

	New()
		..()
		//Due to our refill shenanigans these have to be instantiated per extractor
		available += new /datum/manufacture/gas_extract/air_can/large()
		available += new /datum/manufacture/gas_extract/o2_can()
		available += new /datum/manufacture/gas_extract/co2_can()
		available += new /datum/manufacture/gas_extract/n2_can()
		available += new /datum/manufacture/gas_extract/plasma_can()
		available += new /datum/manufacture/gas_extract/agent_b_can()

	//override to allow the thing to refill canisters :)
	check_enough_materials(datum/manufacture/M)
		if (src.refill)
			var/obj/machinery/manufacturer_attachment/canister_port/port = src.appendix
			if (!istype(port))
				adjust_recipes(FALSE)
			else if (!istype(port.attached_can))
				adjust_recipes(FALSE)
		return ..()


	//crimes ahead
	dispense_product(var/product,var/datum/manufacture/M)
		if (refill) //LOAD 'ER UP
			var/obj/machinery/manufacturer_attachment/canister_port/port = src.appendix
			var/obj/machinery/portable_atmospherics/canister/target_can = port.attached_can
			if (!istype(target_can))
				CRASH("Gas extractor set to refill a non-existent can. What the fuck?")
			if (!istype(M, /datum/manufacture/atmos_can)) //would be empty anyway

				if (ispath(M.item_outputs[1], /obj/machinery/portable_atmospherics/canister))
					var/type_of_gas = M.item_outputs[1]
					var/obj/machinery/portable_atmospherics/canister/initial_trick = M.item_outputs[1]
					var/fill_factor = initial(initial_trick.filled)
					var/volume_factor = initial(initial_trick.volume)

					//this is reversed from canister.dm. It also sucks but uhh it'll do
					//I should probably have just chucked this in a proc on the manufacture datums or something.
					//but the goal is they dump in as much gas as the equivalent canister starts with
					var/prev_moles = TOTAL_MOLES(target_can.air_contents)
					var/prev_temp = target_can.air_contents.temperature
					var/added_temp = (type_of_gas == /obj/machinery/portable_atmospherics/canister/nitrogen ? 80 : T20C)
					var/added_moles = (target_can.maximum_pressure*fill_factor)*volume_factor/(R_IDEAL_GAS_EQUATION*added_temp)

					switch(type_of_gas)
						if(/obj/machinery/portable_atmospherics/canister/toxins)

							target_can.air_contents.toxins 	+= added_moles

						if(/obj/machinery/portable_atmospherics/canister/oxygen)
							target_can.air_contents.oxygen 	+= added_moles

						if(/obj/machinery/portable_atmospherics/canister/sleeping_agent)
							var/datum/gas/oxygen_agent_b/trace_gas = target_can.air_contents.get_or_add_trace_gas_by_type(/datum/gas/sleeping_agent)
							trace_gas.moles += added_moles

						if(/obj/machinery/portable_atmospherics/canister/oxygen_agent_b)
							var/datum/gas/oxygen_agent_b/trace_gas = target_can.air_contents.get_or_add_trace_gas_by_type(/datum/gas/oxygen_agent_b)
							trace_gas.moles += added_moles

						if(/obj/machinery/portable_atmospherics/canister/nitrogen)
							target_can.air_contents.nitrogen += added_moles

						if(/obj/machinery/portable_atmospherics/canister/carbon_dioxide)
							target_can.air_contents.carbon_dioxide 	+= added_moles

						if(/obj/machinery/portable_atmospherics/canister/air/large)
							added_moles = 0 //inefficient but it works for all the others so
							var/newO2 = (O2STANDARD*target_can.maximum_pressure*fill_factor)*volume_factor/(R_IDEAL_GAS_EQUATION*T20C)
							var/newN2 = (N2STANDARD*target_can.maximum_pressure*fill_factor)*volume_factor/(R_IDEAL_GAS_EQUATION*T20C)
							added_moles += newO2
							added_moles += newN2
							target_can.air_contents.oxygen 			+= newO2
							target_can.air_contents.nitrogen 		+= newN2

					//average out temperatures
					//this should probably account for specific heat but that's something for another day. I just don't want it to add hot gas to hot gas
					target_can.air_contents.temperature = (prev_moles/(prev_moles + added_moles))*prev_temp + (added_moles/(prev_moles + added_moles))*added_temp

					target_can.update_icon()
					playsound(src.loc, 'sound/machines/hiss.ogg', 50, 1)
					return
		..()

/obj/machinery/manufacturer/gas/proc/adjust_recipes(now_refill = TRUE)
	if (src.refill == now_refill)
		return
	src.refill = now_refill
	if (src.refill)
		for(var/datum/manufacture/gas_extract/GE in src.available)
			GE.toggle_refill()
	else
		for(var/datum/manufacture/gas_extract/GE in src.available)
			GE.toggle_canister()
	src.updateUsrDialog()

// a blank manufacturer for mechanics

/obj/machinery/manufacturer/mechanic
	name = "Reverse-Engineering Fabricator"
	desc = "A manufacturing unit designed to create new things from blueprints."
	icon_state = "fab-hangar"
	icon_base = "hangar"
	free_resource_amt = 2
	free_resources = list(/obj/item/material_piece/steel,
		/obj/item/material_piece/copper,
		/obj/item/material_piece/glass)

/obj/machinery/manufacturer/personnel
	name = "Personnel Equipment Manufacturer"
	desc = "A manufacturing unit that produces important identification and access equipment."
	icon_state = "fab-access"
	icon_base = "access"
	free_resource_amt = 2
	free_resources = list(/obj/item/material_piece/steel,
		/obj/item/material_piece/copper,
		/obj/item/material_piece/glass)
	available = list(/datum/manufacture/id_card, /datum/manufacture/implant_access,	/datum/manufacture/implanter) //hey if you update these please remember to add it to /hop_and_uniform's list too
	hidden = list(/datum/manufacture/id_card_gold, /datum/manufacture/implant_access_infinite)

//combine personnel + uniform manufactuer here. this is 'cause destiny doesn't have enough room! arrg!
//and i hate this, i do, but you're gonna have to update this list whenever you update /personnel or /uniform
/obj/machinery/manufacturer/hop_and_uniform
	name = "Personnel Manufacturer"
	desc = "A manufacturing unit calibrated to produce workplace uniforms and identification equipment."
	icon_state = "fab-access"
	icon_base = "access"
	free_resource_amt = 5
	free_resources = list(/obj/item/material_piece/steel,
		/obj/item/material_piece/copper,
		/obj/item/material_piece/glass,
		/obj/item/material_piece/cloth/cottonfabric)
	accept_blueprints = 0
	available = list(/datum/manufacture/id_card, /datum/manufacture/implant_access,	/datum/manufacture/implanter, UNIFORM_LIST)

	hidden = list(/datum/manufacture/id_card_gold,
	/datum/manufacture/implant_access_infinite,
	/datum/manufacture/breathmask,
	/datum/manufacture/patch,
	/datum/manufacture/hat_ltophat)

/obj/machinery/manufacturer/qm // This manufacturer just creates different crated and boxes for the QM. Lets give their boring lives at least something more interesting.
	name = "Crate Manufacturer"
	desc = "A manufacturing unit calibrated to produce different crates and boxes."
	icon_state = "fab-crates"
	icon_base = "crates"
	free_resource_amt = 5
	free_resources = list(/obj/item/material_piece/steel)
	accept_blueprints = 0
	available = list(/datum/manufacture/crate,	//hey if you update these please remember to add it to /hop_and_uniform's list too
	/datum/manufacture/packingcrate,
	/datum/manufacture/pizzabox,
	/datum/manufacture/wooden,
	/datum/manufacture/medical,
	/datum/manufacture/biohazard)

	hidden = list(/datum/manufacture/classcrate)

/obj/machinery/manufacturer/engineering
	name = "engineering manufacturer"
	desc = "A manufacturing unit calibrated to produce gear for engineers."
	icon_state = "fab-engi"
	icon_base = "engi"
	free_resource_amt = 5
	free_resources = list(/obj/item/material_piece/steel,
		/obj/item/material_piece/copper,
		/obj/item/material_piece/glass)

	available = list(/datum/manufacture/screwdriver,
	/datum/manufacture/wirecutters,
	/datum/manufacture/wrench,
	/datum/manufacture/crowbar,
	/datum/manufacture/extinguisher,
	/datum/manufacture/welder,
	/datum/manufacture/soldering,
	/datum/manufacture/flashlight,
	/datum/manufacture/weldingmask,
	/datum/manufacture/multitool,
	/datum/manufacture/extinguisher,
	/datum/manufacture/lamp_manufacturer,
	/datum/manufacture/room_planner,
	/datum/manufacture/hardhat,
	/datum/manufacture/cable,
	/datum/manufacture/powercell,
	/datum/manufacture/powercellC,
	/datum/manufacture/powercellE,
	/datum/manufacture/atmos_purger,
	/datum/manufacture/atmos_module/connector,
	/datum/manufacture/atmos_module/digital_valve,
	/datum/manufacture/atmos_module/dp_vent,
	//datum/manufacture/atmos_module/filter,
	/datum/manufacture/atmos_module/furnace_connector,
	/datum/manufacture/atmos_module/manifold_valve,
	//datum/manufacture/atmos_module/mixer,
	/datum/manufacture/atmos_module/outlet_injector,
	/datum/manufacture/atmos_module/passive_gate,
	/datum/manufacture/atmos_module/pump,
	/datum/manufacture/atmos_module/valve,
	/datum/manufacture/atmos_module/vent,
	/datum/manufacture/atmos_module/vent_pump,
	/datum/manufacture/atmos_module/vent_scrubber,
	/datum/manufacture/atmos_module/volume_pump,
	/datum/manufacture/RCDammo,
	/datum/manufacture/RCDammomedium)

	hidden = list(/datum/manufacture/RCDammolarge,
	/datum/manufacture/RCD)

/obj/machinery/manufacturer/zombie_survival
	name = "Uber-Extreme Survival Manufacturer"
	desc = "A manufacturing unit calibrated to produce items useful in surviving extreme scenarios."
	icon_state = "fab-crates"
	icon_base = "crates"
	free_resource_amt = 50
	free_resources = list(/obj/item/material_piece/steel,
		/obj/item/material_piece/copper,
		/obj/item/material_piece/glass,
		/obj/item/material_piece/cloth/cottonfabric)
	accept_blueprints = 0
	available = list(
	/datum/manufacture/engspacesuit,
	/datum/manufacture/breathmask,
	/datum/manufacture/suture,
	/datum/manufacture/scalpel,
	/datum/manufacture/flashlight,
	/datum/manufacture/armor_vest,
//	/datum/manufacture/bullet_22,
	/datum/manufacture/harmonica,
/*	datum/manufacture/riot_shotgun,
	/datum/manufacture/riot_shotgun_ammo,
	/datum/manufacture/clock,
	/datum/manufacture/clock_ammo,
	/datum/manufacture/saa,
	/datum/manufacture/saa_ammo,
	/datum/manufacture/riot_launcher,
	/datum/manufacture/riot_launcher_ammo_pbr,
	/datum/manufacture/riot_launcher_ammo_flashbang,
	/datum/manufacture/sniper,
	/datum/manufacture/sniper_ammo,
	/datum/manufacture/tac_shotgun,
	/datum/manufacture/tac_shotgun_ammo,
	/datum/manufacture/gyrojet,
	/datum/manufacture/gyrojet_ammo,*/
	/datum/manufacture/plank,
	/datum/manufacture/brute_kit,
	/datum/manufacture/burn_kit,
	/datum/manufacture/crit_kit,
	/datum/manufacture/spacecillin,
	/datum/manufacture/bat,
	/datum/manufacture/quarterstaff,
	/datum/manufacture/cleaver,
	/datum/manufacture/fireaxe,
	/datum/manufacture/shovel)

#undef WIRE_EXTEND
#undef WIRE_POWER
#undef WIRE_MALF
#undef WIRE_SHOCK
#undef MAX_QUEUE_LENGTH
#undef UNIFORM_LIST


// -------------------
/datum/action/bar/manufacturer
	duration = 1000
	id = "manufacturer"
	var/obj/machinery/manufacturer/MA
	var/completed = 0

	New(machine, dur)
		MA = machine
		duration = dur
		..()

	onUpdate()
		..()
		if (MA.malfunction && prob(8))
			MA.flip_out()

		if (MA.status & (NOPOWER | BROKEN))
			interrupt(INTERRUPT_ALWAYS)
			return

	onInterrupt()
		..()
		// Kind of a gross hack to store the time remaining on pause.
		MA.timeleft = (src.started + src.duration) - world.time
		MA.manual_stop = 0
		MA.error = null
		MA.mode = "ready"
		MA.build_icon()

	onEnd()
		..()
		src.completed = 1
		MA.finish_work()
		// call dispense

	onDelete()
		..()
		MA.action_bar = null
		if (src.completed && length(MA.queue))
			SPAWN_DBG(0.1 SECONDS)
				MA.begin_work(1)



/proc/build_manufacturer_icons()
	// pre-build all the icons for shit manufacturers make
	for (var/datum/manufacture/P as anything in typesof(/datum/manufacture))
		if (ispath(P, /datum/manufacture/mechanics))
			var/datum/manufacture/mechanics/M = P
			if (!initial(M.frame_path))
				continue
			getItemIcon(initial(M.frame_path))

		else
			// temporarily create this so we can get the list from it
			// i tried very hard to use initial() here and got nowhere,
			// but the fact it's a list seems to not really go well with it
			// maybe someone else can get it to work.
			var/datum/manufacture/I = new P
			if (I && length(I.item_outputs) && I.item_outputs[1])
				getItemIcon(I.item_outputs[1])

//shit that bolts on to a manufacturer :)
ABSTRACT_TYPE(/obj/machinery/manufacturer_attachment)
/obj/machinery/manufacturer_attachment
	name = "manufacturer appendix"
	desc = "Just like the human one, this thing might just bork and take the rest of the machine down with it!"
	icon = 'icons/obj/machines/manufacturer.dmi'
	var/obj/machinery/manufacturer/belongs_to

	New()
		..()
		UnsubscribeProcess()
		SPAWN_DBG(0)
			belongs_to = locate() in get_step(src, src.dir)
			if (belongs_to)
				belongs_to.appendix = src

	disposing()
		var/obj/machinery/manufacturer/gas/G = belongs_to
		if (istype(G))
			G.refill = FALSE
		src.belongs_to?.appendix = null
		src.belongs_to = null
		..()


/obj/machinery/manufacturer_attachment/canister_port
	name = "gas extractor canister port"
	desc = "Attach an empty canister to this port to have the gas extractor it's attached to (re)fill it."
	icon_state = "attach_canister"
	var/obj/machinery/portable_atmospherics/canister/attached_can
	plane = PLANE_NOSHADOW_BELOW

	New()
		..()

		switch(src.dir)
			if (NORTH)
				//For the most part we can just scoot over the port to make it look attached to the manufacturer,
				//but because the port is on the lower edge of the sprite and we'd need at least 5px of displacement up to overlap the machine convincingly,
				//which would pull the port halfway into the canister that's meant to be on top of it.
				var/image/I = image(src.icon, "attach_canister-B", layer = FLOAT_LAYER)
				I.plane = PLANE_DEFAULT
				I.pixel_y = 32
				UpdateOverlays(I, "extra bit")
			if (SOUTH)
				pixel_y = -6
			if (EAST)
				pixel_x = 4
			if (WEST)
				pixel_x = -4

	attackby(obj/item/I, mob/user)
		if (iswrenchingtool(I))
			if (attached_can)
				detach_can()
			else
				attached_can = locate(/obj/machinery/portable_atmospherics/canister) in src.loc
				attach_can()
		..()

	disposing()
		detach_can()
		..()

/obj/machinery/manufacturer_attachment/canister_port/proc/attach_can()
	if (attached_can)
		attached_can.UpdateOverlays(image(attached_can.icon, icon_state = "shitty_connector_placeholder"), "connecty_grip")
		attached_can.anchored = 1
		src.RegisterSignal(attached_can, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC, COMSIG_PARENT_PRE_DISPOSING), PROC_REF(detach_can))
		var/obj/machinery/manufacturer/gas/G = belongs_to
		if (istype(G))
			G.adjust_recipes(TRUE)

/obj/machinery/manufacturer_attachment/canister_port/proc/detach_can()
	if (attached_can)
		attached_can.anchored = 0
		src.UnregisterSignal(attached_can, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC, COMSIG_PARENT_PRE_DISPOSING))
		attached_can.UpdateOverlays(null, "connecty_grip")
		attached_can = null
		var/obj/machinery/manufacturer/gas/G = belongs_to
		if (istype(G))
			G.adjust_recipes(FALSE)
