/datum/data/vending_product
	var/product_name = "generic"
	var/atom/product_path = null

	var/product_cost
	var/product_amount
	var/product_hidden
	var/logged_on_vend

	var/static/list/product_name_cache = list(/obj/item/reagent_containers/mender/brute = "brute auto-mender", /obj/item/reagent_containers/mender/burn = "burn auto-mender")


	New(productpath, amount=0, cost=0, hidden=0, logged_on_vend=FALSE)
		..()
		if (istext(productpath))
			productpath = text2path(productpath)
		if (!ispath(productpath))
			qdel(src)
			return
		src.product_path = productpath

		var/name_check = product_name_cache[productpath]
		if (name_check)
			src.product_name = name_check
		else
			//var/obj/temp = new src.product_path(src)
			var/p_name = initial(product_path.name)
			src.product_name = capitalize(p_name)
			product_name_cache[productpath] = src.product_name
			//qdel(temp)

		src.product_amount = amount
		src.product_cost = round(cost)

		src.product_hidden = hidden
		src.logged_on_vend = logged_on_vend

/proc/RandomVendWires()
	//to make this not randomize the wires, just set index to 1 and increment it in the flag for loop (after doing everything else).
	var/list/Vendwires = list(0, 0, 0, 0, 0)
	VendIndexToFlag = list(0, 0, 0, 0, 0)
	VendIndexToWireColor = list(0, 0, 0, 0, 0)
	VendWireColorToIndex = list(0, 0, 0, 0, 0)
	var/flagIndex = 1
	for (var/flag=1, flag<=16, flag+=flag)
		var/valid = 0
		while (!valid)
			var/colorIndex = rand(1, 5)
			if (Vendwires[colorIndex]==0)
				valid = 1
				Vendwires[colorIndex] = flag
				VendIndexToFlag[flagIndex] = flag
				VendIndexToWireColor[flagIndex] = colorIndex
				VendWireColorToIndex[colorIndex] = flagIndex
		flagIndex+=1
	return Vendwires

/obj/machinery/vending
	name = "Vendomat"
	desc = "A generic vending machine."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "generic"
	machinery_flags = MAY_REQUIRE_MAINT
	anchored = 1
	density = 1
	mats = 20
	layer = OBJ_LAYER - 0.1 // so items get spawned at 3, don't @ me
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_MULTITOOL
	object_flags = CAN_REPROGRAM_ACCESS
	var/freestuff = 0
	var/obj/item/card/id/scan = null

	var/image/panel_image = null

	var/active = 1 //No sales pitches if off!
	var/vend_ready = 1 //Are we ready to vend?? Is it time??
	var/vend_delay = 5 //How long does it take to vend?

	//Keep track of lists
	var/list/slogan_list = list()//new() //List of strings
	var/list/product_list = new() //List of datum/data/vending_product
	var/glitchy_slogans = 0 // do they come out aLL FunKY lIKe THIs?
	/// For player vending machines
	var/player_list
	//Replies when buying
	var/vend_reply //Thank you for shopping!
	var/last_reply = 0

	//Slogans
	var/last_slogan = 0 //When did we last pitch?
	var/slogan_delay = 600 //How long until we can pitch again?
	var/slogan_chance = 5

	//Icons
	var/icon_panel = "generic-panel"
	var/icon_vend //Icon for vending
	var/icon_deny //Icon when denying vend (wrong access)

	var/icon_off // trying to cut down on some duplicated icons in vending.dmi so I'm adding more icon states wee
	var/icon_broken // you only need to set these to something if you want these icons to be something other than "[initial(icon_state)]-off/-broken/-fallen"
	var/icon_fallen // otherwise it'll just default to that behavior

	var/emagged = 0 //Ignores if somebody doesn't have card access to that machine.

	//Malfunctioning machine
	var/seconds_electrified = 0 //Shock customers like an airlock.
	var/shoot_inventory = 0 //Fire items at customers! We're broken!
	var/shoot_inventory_chance = 5
	var/ai_control_enabled = 1

	var/extended_inventory = FALSE //can we access the hidden inventory?
	var/can_fall = TRUE //Can this machine be knocked over?
	var/can_hack = TRUE //Can this machine have it's panel open?
	var/freezer = FALSE // is it one of those machines what has frozen goods lol

	var/panel_open = FALSE //Hacking that vending machine. Gonna get a free candy bar.
	var/wires = 15 // flag 1 + 2 + 4 + 8 + !(16)

	// Paid vendor variables
	var/pay = 0 // Does this vending machine require money?
	var/acceptcard = 1 // does the machine accept ID swiping?
	var/credit = 0 //How much money is currently in the machine?
	var/profit = 0.90 // Percentage of item cost that goes to player. Rest goes to QM/shipping budget.

	// Receipts and Service charge! Because this machine provides a useful service to you, the customer,
	// and we should be compensated for that! uwu
	// Also, you may need a receipt to take to your department head for expenses reimbursements~
	var/print_receipts = TRUE
	var/print_receipts_long = FALSE
	var/receipt_count = 20 // TODO: Printer rolls for receipts?
	var/min_serv_chg = 2 // 2 bux just to use your damn machine? Rasm frasm grumble!
	var/serv_chg_pct = 0.02
	var/datum/data/record/servicechgaccount = null // TODO: add a way to set/reset this for miscreants to do an embeezle

	var/HTML = null // guh
	var/vending_HTML = null // buh
	var/wire_HTML = null // duh
	var/list/vendwires = list() // fuh
	var/datum/data/vending_product/paying_for = null // zuh

	var/datum/light/light
	var/light_r =1
	var/light_g = 1
	var/light_b = 1

	var/has_glow = TRUE // is this machine emissive?
	var/image/glow

	var/output_target = null

	power_usage = 50

	var/window_size = "400x475"

	New()
		if(has_glow)
			src.glow = image(src.icon, src, "[icon_state]_g")
			src.glow.plane = PLANE_LIGHTING
			src.glow.layer = LIGHTING_LAYER_BASE
			src.glow.blend_mode = BLEND_ADD
			src.UpdateOverlays(glow, "glow")

		src.create_products()
		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Vend Random", "vendinput")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Vend by Name", "vendname")
		light = new /datum/light/point
		light.attach(src)
		light.set_brightness(0.6)
		light.set_height(1.5)
		light.set_color(light_r, light_g, light_b)
		..()
		src.panel_image = image(src.icon, src.icon_panel)
		if(!servicechgaccount)
			servicechgaccount = wagesystem.finserv_budget

	var/lastvend = 0

	proc/printReceipt(var/datum/data/record/accountFrom, item, amount, serv_chg_amount)
		if(!print_receipts)
			return

		var/receiptText = "<b>Payment Receipt</b><br><i>Please keep this for departmental records.</i><br>"
		receiptText += "[item]: $[amount]<br>"
		if(serv_chg_amount > 0 || amount != 0)
			receiptText += "<b>Service Charge</b>: $[serv_chg_amount]<br>"
		else
			receiptText += "<b>-Service Charge Waived-</b><br>"
			serv_chg_amount = 0

		receiptText += "<hr>"

		if(!istype(accountFrom))
			receiptText += "<b>Total</b>: $[amount + serv_chg_amount]"
		else
			receiptText += "<b>Total</b> (deducted from [accountFrom.fields["name"]]): $[amount + serv_chg_amount]"

		playsound(src.loc, "sound/machines/printer_dotmatrix.ogg", 40, 1)

		SPAWN_DBG(3.2 SECONDS)
			var/obj/item/paper/P = new()
			P.set_loc(src.loc)
			if(print_receipts_long)
				P.icon_state = "thermal_paper_med"
				P.desc = "Holy crap, how long does a receipt need to be?!"
			else
				P.icon_state = "thermal_paper"

			P.name = "'[item]' receipt"
			P.info = receiptText

		// receipt_count--


	proc/vendinput(var/datum/mechanicsMessage/inp)
		if( world.time < lastvend ) return//aaaaaaa
		lastvend = world.time + 2
		var/datum/data/vending_product/R = throw_item()
		if (!R) //pizza machine = special
			return
		var/service_charge = ((R.product_cost * serv_chg_pct) < min_serv_chg) ? min_serv_chg : round(R.product_cost * serv_chg_pct)
		printReceipt(0, R.product_name, R.product_cost, service_charge)
		if(R?.logged_on_vend)
			logTheThing("station", usr, null, "randomly vended a logged product ([R.product_name]) using mechcomp from [src] at [log_loc(src)].")

	proc/vendname(var/datum/mechanicsMessage/inp)
		if( world.time < lastvend || !inp) return//aaaaaaa
		if(!length(inp.signal)) return//aaaaaaa
		lastvend = world.time + 5 //Make it slower to vend by name?
		var/datum/data/vending_product/R = throw_item(inp.signal)
		if(R?.logged_on_vend)
			logTheThing("station", usr, null, "vended a logged product by name ([R.product_name]) using mechcomp from [src] at [log_loc(src)].")

	// just making this proc so we don't have to override New() for every vending machine, which seems to lead to bad things
	// because someone, somewhere, always forgets to use a ..()
	proc/create_products()
		return

	proc/deep_freeze(atom/movable/thing) // this is for frozen foods, or anything else you wanna freeze. I dont care. -warc

		if(istype(thing, /obj/item/popsicle))
			return thing // dont refreeze these. hopefully thats all the exceptions.

		var/obj/item/reagent_containers/food/snacks/shell/frozen/freezie = new(src)

		if(istype(thing, /obj/item/reagent_containers/food/snacks/))
			var/obj/item/reagent_containers/food/snacks/S = thing
			if("food_cold" in S.food_effects)
				return S // if the dispensed item is meant to be cold, don't treat it as "frozen"
			else
				freezie.food_effects |= S.food_effects
				freezie.food_effects -= "food_warm"



		freezie.name = "frozen [thing.name]"

		var/icon/composite = new(thing.icon, thing.icon_state)
		for(var/O in thing.underlays + thing.overlays)
			var/image/I = O
			composite.Blend(icon(I.icon, I.icon_state, I.dir, 1), ICON_OVERLAY)

		composite.ColorTone("#bbefff")
		freezie.icon = composite
		freezie.overlays = thing.overlays

		if(isitem(thing))
			var/obj/item/item = thing
			freezie.amount = (item.amount > 1 ? item.amount : item.w_class+1)
		else
			freezie.amount = 5

		thing.set_loc(freezie)
		return freezie



	MouseDrop(over_object, src_location, over_location)
		if(!istype(usr,/mob/living/))
			boutput(usr, "<span class='alert'>Only living mobs are able to set the output target for [src].</span>")
			return

		if(get_dist(over_object,src) > 1)
			boutput(usr, "<span class='alert'>[src] is too far away from the target!</span>")
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
				boutput(usr, "<span class='notice'>You set [src] to output to [over_object]!</span>")

		else if (istype(over_object,/obj/table/) || istype(over_object,/obj/rack/))
			var/obj/O = over_object
			src.output_target = O.loc
			boutput(usr, "<span class='notice'>You set [src] to output on top of [O]!</span>")

		else if (istype(over_object,/turf) && !over_object:density)
			src.output_target = over_object
			boutput(usr, "<span class='notice'>You set [src] to output to [over_object]!</span>")

		else
			boutput(usr, "<span class='alert'>You can't use that as an output target.</span>")
		return

	MouseDrop_T(mob/target, mob/user)
		if(!istype(target) || target.buckled || get_dist(user, src) > 1 || get_dist(user, target) > 1 || is_incapacitated(user) || isAI(user) || isAI(target) || isghostcritter(user))
			return

		actions.start(new/datum/action/bar/icon/shoveMobIntoVendomat(src, target, user), user)

	proc/spitOut(mob/target)
		src.prevend_effect()
		src.visible_message("", "The [src] forces [target] back out!")
		playsound(src.loc, 'sound/machines/buzz-two.ogg', 25, 1)
		target.set_loc(src.loc)
		if(prob(30))
			random_brute_damage(target, rand(5,20),1)
		// Doesn't quite work for vending machines on the south side of a hallway, just
		// punts you into the wall quite firmly. Not sure how to do anything different
		// about that.
		if(src.emagged)
			target.throw_at(get_edge_target_turf(src, src.dir), 15, 3)
		else
			target.throw_at(get_edge_target_turf(src, src.dir), 5, 1)
		src.postvend_effect()
		sleep(1.5 SECONDS)
		if(prob(50)) // Additionally, fuck you. *smack*
			var/datum/data/vending_product/R = throw_item()
			var/service_charge = ((R.product_cost * serv_chg_pct) < min_serv_chg) ? min_serv_chg : round(R.product_cost* serv_chg_pct)
			printReceipt(0, R.product_name, R.product_cost, service_charge)


	proc/get_output_location()
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

		else if (istype(src.output_target,/turf/floor/))
			return src.output_target

		else
			return src.loc

#define WIRE_EXTEND 1
#define WIRE_SCANID 2
#define WIRE_SHOCK 3
#define WIRE_SHOOTINV 4
#define WIRE_FREEZER 5

/obj/machinery/vending/ex_act(severity)
	switch(severity)
		if(OLD_EX_SEVERITY_1)
			qdel(src)
			return
		if(OLD_EX_SEVERITY_2)
			if (prob(50))
				qdel(src)
				return
		if(OLD_EX_SEVERITY_3)
			if (prob(25))
				SPAWN_DBG(0)
					src.break_down()
					return
				return
			else if (prob(25))
				SPAWN_DBG(0)
					src.fall()
					return
		else
	return

/obj/machinery/vending/blob_act(var/power)
	if (prob(power * 1.25))
		SPAWN_DBG(0)
			if (prob(power / 3) && can_fall == 2)
				for (var/i = 0, i < rand(4,7), i++)
					src.break_down()
				qdel(src)
			if (prob(50) || can_fall == 2)
				src.break_down()
			else
				src.fall()
		return

	return

/obj/machinery/vending/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (!src.emagged)
		src.emagged = 1
		if(user)
			boutput(user, "You short out the product lock on [src]")
		return 1
	return 0

/obj/machinery/vending/demag(var/mob/user)
	if (!src.emagged)
		return 0
	if (user)
		user.show_text("You repair the product lock on [src].")
	src.emagged = 0
	return 1

/obj/machinery/vending/proc/scan_card(var/obj/item/card/id/card as obj, var/mob/user as mob)
	if (!card || !user || !src.acceptcard)
		return
	boutput(user, "<span class='notice'>You swipe [card].</span>")
	var/datum/data/record/account = null
	account = FindBankAccountById(card.registered_id)
	if (account)
		var/enterpin = input(user, "Please enter your PIN number.", "Enter PIN", 0) as null|num
		if (enterpin == card.pin)
			boutput(user, "<span class='notice'>Card authorized.</span>")
			src.scan = card
		else
			boutput(user, "<span class='alert'>Pin number incorrect.</span>")
			src.scan = null
	else
		boutput(user, "<span class='alert'>No bank account associated with this ID found.</span>")
		src.scan = null

/* For potential festivities! */
/obj/machinery/vending/proc/seasonal_check(mob/user as mob, datum/data/vending_product/product)
	return

/obj/machinery/vending/proc/generate_HTML(var/update_vending = 0, var/update_wire = 0)
	src.HTML = ""

	if (!src.wire_HTML || update_wire)
		src.generate_wire_HTML()
	if (src.panel_open || isAI(usr))
		src.HTML += src.wire_HTML

	if (!src.vending_HTML || update_vending)
		src.generate_vending_HTML()
	src.HTML += src.vending_HTML

	src.updateUsrDialog()

/obj/machinery/vending/proc/generate_vending_HTML()
	var/list/html_parts = list()
	html_parts += "<b>Welcome!</b><br>"

	if (src.paying_for && (!istype(src.paying_for, /datum/data/vending_product) || !src.pay))
		src.paying_for = null

	if (src.pay && src.acceptcard)
		if (src.paying_for && !src.scan)
			html_parts += "<B>You have selected the following item:</b><br>"
			html_parts += "&emsp;<b>[src.paying_for.product_name]</b><br>"
			html_parts += "Please swipe your card to authorize payment.<br>"
			html_parts += "<B>Current ID:</B> None<BR>"
		else if (src.scan)
			if (src.paying_for)
				html_parts += "<B>You have selected the following item for purchase:</b><br>"
				html_parts += "&emsp;[src.paying_for.product_name]<br>"
				html_parts += "<B>Please swipe your card to authorize payment.</b><br>"
			var/datum/data/record/account = null
			account = FindBankAccountById(src.scan.registered_id)
			html_parts += "<B>Current ID:</B> <a href='byond://?src=\ref[src];logout=1'><u>([src.scan])</u></A><BR>"
			html_parts += "<B>Credits on Account: [account.fields["current_money"]] Credits</B> <BR>"
		else
			html_parts += "<B>Current ID:</B> None<BR>"

	if (!length(src.product_list) && !length(src.player_list))
		html_parts += "<font color = 'red'>No product loaded!</font>"

	else if (src.paying_for)
		html_parts += "<a href='byond://?src=\ref[src];vend=\ref[src.paying_for]'><u><b>Continue</b></u></a>"
		html_parts += " | <a href='byond://?src=\ref[src];cancel_payfor=1;logout=1'><u><b>Cancel</b></u></a>"

	else
		html_parts += "<table style='width: 100%; border: none; border-collapse: collapse;'><thead><tr><th>Product</th><th>Amt.</th><th>Price</th></tr></thead>"
		for (var/datum/data/vending_product/R in src.product_list)
			if (R.product_hidden && !src.extended_inventory)
				continue
			if (R.product_amount > 0)
				html_parts += "<tr><td><a href='byond://?src=\ref[src];vend=\ref[R]'>[R.product_name]</a></td><td style='text-align: right;'>[R.product_amount]</td><td style='text-align: right;'> $[R.product_cost]</td></tr>"
			else
				html_parts += "<tr><td>[R.product_name]</a></td><td colspan='2' style='text-align: center;'><strong>SOLD OUT</strong></td></tr>"
		if (player_list)
			var/obj/machinery/vending/player/T = src
			for (var/datum/data/vending_product/player_product/R in src.player_list)
				var/obj/item/productholder = R.contents[1]
				var/nextproduct = html_encode(sanitize(productholder.name))
				if (!T.unlocked)
					html_parts += "<tr><td><a href='byond://?src=\ref[src];vend=\ref[R]'>[nextproduct]</a></td><td style='text-align: right;'>[R.product_amount]</td><td style='text-align: right;'> $[R.product_cost]</td></tr>"
					//Player vending machines don't have "out of stock" items
				else if (T.unlocked)
					//Links for setting prices when player vending machines are unlocked
					html_parts += "<tr><td><a href='byond://?src=\ref[src];vend=\ref[R]'>[nextproduct]</a></td><td style='text-align: right;'>[R.product_amount]</td><td style='text-align: right;'><a href='byond://?src=\ref[src];setprice=\ref[R]'>$[R.product_cost]</a> (<a href='byond://?src=\ref[src];icon=\ref[R]'>*</a>)</td></tr>"
		html_parts += "</table>";

		if (src.pay)
			html_parts += "<BR><B>Available Credits:</B> $[src.credit] <a href='byond://?src=\ref[src];return_credits=1'>Return Credits</A>"
			if (!src.acceptcard)
				html_parts += "<BR>This machine only takes credit bills."

	src.vending_HTML = jointext(html_parts, "")


/obj/machinery/vending/proc/generate_wire_HTML()
	src.vendwires = list("Violet" = 1,\
		"Orange" = 2,\
		"Goldenrod" = 3,\
		"Green" = 4,\
		"Broun" = 5)
	var/list/html_parts = list()
	html_parts = "<TT><B>The Access Panel is [src.panel_open ? "open" : "closed"]:</B><br>"
	html_parts += "<table border=\"1\" style=\"width:100%\"><tbody><tr><td><small>"
	for (var/wiredesc in vendwires)
		var/is_uncut = src.wires & VendWireColorToFlag[vendwires[wiredesc]]
		html_parts += "[wiredesc] wire: "
		if (!is_uncut)
			html_parts += "<a href='byond://?src=\ref[src];cutwire=[vendwires[wiredesc]]'>Mend</a>"
		else
			html_parts += "<a href='byond://?src=\ref[src];cutwire=[vendwires[wiredesc]]'>Cut</a> "
			html_parts += "<a href='byond://?src=\ref[src];pulsewire=[vendwires[wiredesc]]'>Pulse</a> "
		html_parts += "<br>"

	html_parts += "<br>"
	html_parts += "The orange light is [(src.seconds_electrified == 0) ? "off" : "on"].<BR>"
	html_parts += "The red light is [src.shoot_inventory ? "off" : "blinking"].<BR>"
	html_parts += "The green light is [src.extended_inventory ? "on" : "off"].<BR>"
	html_parts += "The [(src.wires & WIRE_SCANID) ? "purple" : "yellow"] light is on.<BR>"
	html_parts += "The AI control indicator is [src.ai_control_enabled ? "lit" : "unlit"].<BR>"
	html_parts += "The compressor is [(!(status & (BROKEN|NOPOWER)) && src.freezer) ? "rumbling softly" : "quiet"].<BR>"
	html_parts += "</small></td></tr></tbody></table></TT><br>"
	src.wire_HTML = jointext(html_parts, "")

/obj/machinery/vending/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W,/obj/item/electronics/scanner) || istype(W,/obj/item/deconstructor)) // So people don't end up making the vending machines fall on them when they try to scan/deconstruct it
		return
	if (istype(W, /obj/item/spacecash))
		if (src.pay)
			src.credit += W.amount
			W.amount = 0
			boutput(user, "<span class='notice'>You insert [W].</span>")
			user.u_equip(W)
			W.dropped()
			qdel( W )
			src.generate_HTML(1)
			return
		else
			boutput(user, "<span class='alert'>This machine does not accept cash.</span>")
			return
	if (istype(W, /obj/item/device/pda2) && W:ID_card)
		W = W:ID_card
	if (istype(W, /obj/item/card/id))
		if (src.acceptcard)
			src.scan_card(W, user)
			src.generate_HTML(1)
			return
			/*var/amount = input(user, "How much money would you like to deposit?", "Deposit", 0) as null|num
			if(amount <= 0)
				return
			if(amount > W:money)
				boutput(user, "<span class='alert'>Insufficent funds. [W] only has [W:money] credits.</span>")
				return
			src.credit += amount
			W:money -= amount
			boutput(user, "<span class='notice'>You deposit [amount] credits. [W] now has [W:money] credits.</span>")
			src.updateUsrDialog()
			return()*/
		else
			boutput(user, "<span class='alert'>This machine does not accept ID cards.</span>")
			return
	else if (isscrewingtool(W) && (src.can_hack))
		src.panel_open = !src.panel_open
		boutput(user, "You [src.panel_open ? "open" : "close"] the maintenance panel.")
		src.UpdateOverlays(src.panel_open ? src.panel_image : null, "panel")
		src.generate_HTML(0, 1)
		return
	else if (istype(W, /obj/item/cable_coil))
		if (src.panel_open && W.amount >= 5)
			W.change_stack_amount(-5)
			playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
			boutput(user, "<span class='notice'>You replace the wiring inside the machine.</span>")
			malfunction_resolve()
	else if (istype(W, /obj/item/device/t_scanner) || (istype(W, /obj/item/device/pda2) && istype(W:module, /obj/item/device/pda_module/tray)))
		if (src.seconds_electrified != 0)
			boutput(user, "<span class='alert'>[bicon(W)] <b>WARNING</b>: Abnormal electrical response received from access panel.</span>")
		else
			if (status & NOPOWER)
				boutput(user, "<span class='alert'>[bicon(W)] No electrical response received from access panel.</span>")
			else
				boutput(user, "<span class='notice'>[bicon(W)] Regular electrical response received from access panel.</span>")
		return
	else if (src.panel_open && (issnippingtool(W) || ispulsingtool(W)))
		src.Attackhand(user)
		return
	else if (ispryingtool(W))
		if (src.can_fall == 2) //if the vendor is toppled
			//action bar is defined at the end of these procs
			actions.start(new /datum/action/bar/icon/right_vendor(src), user)
			return

	if (istype(W, /obj/item/vending/restock_cartridge))
		//check if cartridge type matches the vending machine
		var/obj/item/vending/restock_cartridge/Q = W
		if (istype(src, text2path("/obj/machinery/vending/[Q.vendingType]")))

		// if (istype(src, text2path("/obj/machinery/vending/[W:vendingType]")))
			//remove all producs, reinitialize array and then create the products like new
			src.product_list = new()
			src.create_products()
			src.generate_HTML(1)

			boutput(user, "<span class='notice'>You restocked the items in [src].</span>")
			playsound(src.loc ,"sound/items/Deconstruct.ogg", 80, 0)
			user.u_equip(W)
			qdel(W)
			return
		else
			boutput(user, "<span class='alert'>[W] is not compatible with [src].</span>")
	else
		user.lastattacked = src
		hit_twitch(src)
		attack_particle(user,src)
		playsound(src,"sound/impact_sounds/Metal_Clang_2.ogg",50,1)
		..()
		if (W?.force >= 5 && prob(4 + (W.force - 5)))
			src.fall(user)

/obj/machinery/vending/hitby(atom/movable/M, datum/thrown_thing/thr)
	if (iscarbon(M) && M.throwing && prob(25))
		src.fall(M)
		return

	..()

/obj/machinery/vending/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/vending/attack_hand(mob/user as mob)
	if (status & (BROKEN|NOPOWER))
		return
	src.add_dialog(user)

	if (src.seconds_electrified != 0)
		if (src.shock(user, 100))
			return

	if (!src.HTML)
		src.generate_HTML()
	else
		if (src.HTML && !src.vending_HTML)
			src.generate_HTML(1)
		if (src.HTML && (src.panel_open || isAI(user)) && !src.wire_HTML)
			src.generate_HTML(0, 1)

	if (window_size)
		user.Browse(src.HTML, "window=vending;size=[window_size]")
	else
		user.Browse(src.HTML, "window=vending")
	onclose(user, "vending")

	interact_particle(user,src)
	return

/obj/machinery/vending/Topic(href, href_list)
	if (status & (BROKEN|NOPOWER))
		return
	if (usr.stat || usr.restrained())
		return

	//ehh just let the AI operate vending machines. why not!!
	if (isAI(usr) && !src.ai_control_enabled)
		boutput(usr, "<span class='alert'>AI control for this vending machine has been disconnected!</span>")
		return

	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))))
		var/isplayer = 0
		src.add_dialog(usr)
		src.add_fingerprint(usr)
		if ((href_list["vend"]) && (src.vend_ready))

			if ((!src.allowed(usr)) && (!src.emagged) && (src.wires & WIRE_SCANID)) //For SECURE VENDING MACHINES YEAH
				boutput(usr, "<span class='alert'>Access denied.</span>") //Unless emagged of course
				flick(src.icon_deny,src)
				return

			src.vend_ready = 0 //One thing at a time!!

			var/datum/data/vending_product/R = locate(href_list["vend"]) in src.product_list
			if (!R)
				R = locate(href_list["vend"]) in src.player_list
				isplayer = TRUE
			if (!R || !istype(R))
				src.vend_ready = 1
				return
			else if(R.product_hidden && !src.extended_inventory)
				src.vend_ready = 1
				return
			var/product_path = R.product_path

			if (istext(product_path))
				product_path = text2path(product_path)

			if (!product_path && !isplayer)
				src.vend_ready = 1
				return

			if (R.product_amount <= 0)
				src.vend_ready = 1
				return

			//Wire: Fix for href exploit allowing for vending of arbitrary items
			if (!(R in src.product_list) && !(R in src.player_list))
				src.vend_ready = 1

				trigger_anti_cheat(usr, "tried to href exploit [src] to spawn an invalid item.")
				return

			var/datum/data/record/account = null
			if (src.pay)
				if (src.acceptcard && src.scan)
					account = FindBankAccountById(src.scan.registered_id)
					if (!account)
						boutput(usr, "<span class='alert'>No bank account associated with ID found.</span>")
						flick(src.icon_deny,src)
						src.vend_ready = 1
						src.paying_for = R
						src.generate_HTML(1)
						return
					if (account.fields["current_money"] < R.product_cost)
						boutput(usr, "<span class='alert'>Insufficient funds in account. To use machine credit, log out.</span>")
						account.fields["current_money"] -= min_serv_chg
						servicechgaccount.fields["current_money"] += min_serv_chg
						flick(src.icon_deny,src)
						src.vend_ready = 1
						src.paying_for = R
						src.generate_HTML(1)
						return
				else
					if (src.credit < R.product_cost)
						boutput(usr, "<span class='alert'>Insufficient Credit.</span>")
						flick(src.icon_deny,src)
						src.vend_ready = 1
						src.paying_for = R
						src.generate_HTML(1)
						return

			if (((src.last_reply + (src.vend_delay + 200)) <= world.time) && src.vend_reply)
				SPAWN_DBG(0)
					src.speak(src.vend_reply)
					src.last_reply = world.time

			use_power(10)
			if (src.icon_vend) //Show the vending animation if needed
				flick(src.icon_vend,src)

			src.prevend_effect()
			if(!src.freestuff) R.product_amount--

			var/service_charge = ((R.product_cost * serv_chg_pct) < min_serv_chg) ? min_serv_chg : round(R.product_cost* serv_chg_pct)
			if (src.pay)
				if (src.acceptcard && account)
					account.fields["current_money"] -= R.product_cost
					account.fields["current_money"] -= service_charge
					servicechgaccount.fields["current_money"] += service_charge
				else
					src.credit -= R.product_cost
					service_charge = 0
				if (!isplayer)
					wagesystem.shipping_budget += round(R.product_cost * profit) // cogwerks - maybe money shouldn't just vanish into the aether idk
				else
					//Players get 90% of profit from player vending machines QMs get 10%
					var/obj/machinery/vending/player/T = src
					T.owneraccount.fields["current_money"] += round(R.product_cost * profit)
					wagesystem.shipping_budget += round(R.product_cost * (1 - profit))
				if(R.product_amount <= 0 && !isplayer == 0)
					src.player_list -= R
			//Gotta do this before the SPAWN_DBG
			var/obj/item/playervended
			if (player_list)
				var/datum/data/vending_product/player_product/T = R
				playervended = T.contents[1]
				T.contents -= playervended
			SPAWN_DBG(src.vend_delay)
				src.vend_ready = 1 // doin this at the top here just in case something goes fucky and the proc crashes
				src.seasonal_check(usr, R)
				if (ispath(product_path))
					var/atom/movable/vended = new product_path(src.get_output_location()) // changed from obj, because it could be a mob, THANKS VALUCHIMP
					vended.layer = src.layer + 0.1 //So things stop spawning under the fukin thing
					if(isitem(vended))
						if(src.freezer)
							vended = deep_freeze(vended)
						usr.put_in_hand_or_eject(vended) // try to eject it into the users hand, if we can
					// else, just let it spawn where it is
				else if (player_list)
					playervended.layer = src.layer + 0.3 //To get over the CRT layer
					if(src.freezer)
						playervended = deep_freeze(playervended)
					usr.put_in_hand_or_eject(playervended)
				else if (isicon(R.product_path))
					var/icon/welp = icon(R.product_path)
					if (welp.Width() > 32 || welp.Height() > 32)
						welp.Scale(32, 32)
						R.product_path = welp // if scaling is required reset the product_path so it only happens the first time
					var/obj/dummy = new /obj/item(src.get_output_location())
					dummy.name = R.product_name
					dummy.desc = "?!"
					dummy.icon = welp
				else if (isfile(R.product_path))
					var/S = sound(R.product_path)
					if (S)
						playsound(src.loc, S, 50, 0)
				src.postvend_effect()
				if(account || print_receipts_long)//trying out no receipts for cash transactions - warc
					printReceipt(account, R.product_name, R.product_cost, service_charge)

				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "productDispensed=[R.product_name]")

			if (src.paying_for)
				src.paying_for = null
				src.scan = null
			src.generate_HTML(1)

			if(R.logged_on_vend)
				logTheThing("station", usr, null, "vended a logged product ([R.product_name]) from [src] at [log_loc(src)].")
			if(player_list)
				logTheThing("station", usr, null, "vended a player product ([R.product_name]) from [src] at [log_loc(src)].")
		if (href_list["logout"])
			src.scan = null
			src.generate_HTML(1)

		if (href_list["cancel_payfor"])
			src.paying_for = null
			src.generate_HTML(1)

		if (href_list["return_credits"])
			SPAWN_DBG(src.vend_delay)
				if (src.credit > 0)
					var/obj/item/spacecash/returned = new()
					returned.setup(src.get_output_location(), src.credit)

					usr.put_in_hand_or_eject(returned) // try to eject it into the users hand, if we can
					src.credit = 0
					boutput(usr, "<span class='notice'>You receive [returned].</span>")
					src.generate_HTML(1)

		if ((href_list["cutwire"]) && (src.panel_open))
			var/twire = text2num(href_list["cutwire"])
			if (!usr.find_tool_in_hand(TOOL_SNIPPING))
				boutput(usr, "You need a snipping tool!")
				return
			else if (src.isWireColorCut(twire))
				src.mend(twire)
			else
				src.cut(twire)

		if ((href_list["pulsewire"]) && (src.panel_open || isAI(usr)))
			var/twire = text2num(href_list["pulsewire"])
			if (! (usr.find_tool_in_hand(TOOL_PULSING) || isAI(usr)) )
				boutput(usr, "You need a multitool or similar!")
				return
			else if (src.isWireColorCut(twire))
				boutput(usr, "You can't pulse a cut wire.")
				return
			else
				src.pulse(twire)
	else
		usr.Browse(null, "window=vending")
		return
	return

/obj/machinery/vending/process()
	if (status & BROKEN)
		return
	..()
	if (status & NOPOWER)
		return

	if (!src.active)
		return

	if (src.seconds_electrified > 0)
		src.seconds_electrified--

	//Pitch to the people!  Really sell it!
	if (prob(src.slogan_chance) && ((src.last_slogan + src.slogan_delay) <= world.time) && (src.slogan_list.len > 0))
		var/slogan = pick(src.slogan_list)
		src.speak(slogan)
		src.last_slogan = world.time

	if ((prob(shoot_inventory_chance)) && (src.shoot_inventory))
		src.throw_item()

	return

/obj/machinery/vending/proc/speak(var/message)
	if (status & NOPOWER)
		return

	if (!message)
		return

	for (var/mob/O in hearers(src, null))
		if (src.glitchy_slogans)
			O.show_message("<span class='game say'><span class='name'>[src]</span> beeps,</span> \"[voidSpeak(message)]\"", 2)
		else
			O.show_message("<span class='subtle'><span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"</span></span>", 2)

	return

/obj/machinery/vending/proc/prevend_effect()
	playsound(src.loc, 'sound/machines/driveclick.ogg', 30, 1, 0.1)
	return

/obj/machinery/vending/proc/postvend_effect()
	playsound(src.loc, 'sound/machines/ping.ogg', 20, 1, 0.1)
	return

/obj/machinery/vending/power_change()
	if (can_fall == 2)
		icon_state = icon_fallen ? icon_fallen : "[initial(icon_state)]-fallen"
		light.disable()
		return

	if (status & BROKEN)
		icon_state = icon_broken ? icon_broken : "[initial(icon_state)]-broken"
		light.disable()
		if(src.has_glow)
			src.UpdateOverlays(null, "glow")
	else
		if ( powered() )
			icon_state = initial(icon_state)
			status &= ~NOPOWER
			light.enable()
			if(src.has_glow)
				src.UpdateOverlays(glow, "glow")
		else
			SPAWN_DBG(rand(0, 15))
				src.icon_state = icon_off ? icon_off : "[initial(icon_state)]-off"
				status |= NOPOWER
				light.disable()
				if(src.has_glow)
					src.UpdateOverlays(null, "glow")

/obj/machinery/vending/proc/fall(mob/living/carbon/victim)
	if (can_fall != 1)
		return
	can_fall = 2
	status |= BROKEN
	var/turf/vicTurf = get_turf(victim)
	src.icon_state = "[initial(icon_state)]-fallen"
//	SPAWN_DBG(0)
//		src.icon_state = "[initial(icon_state)]-fall"
//		SPAWN_DBG(2 SECONDS)
//			src.icon_state = "[initial(icon_state)]-fallen"
	if (istype(victim) && vicTurf && (get_dist(vicTurf, src) <= 1))
		victim.changeStatus("weakened", 30 SECONDS)
		src.visible_message("<b><font color=red>[src.name] tips over onto [victim]!</font></b>")
		victim.force_laydown_standup()
		victim.set_loc(vicTurf)
		if (src.layer < victim.layer)
			src.layer = victim.layer+1
		src.set_loc(vicTurf)
		random_brute_damage(victim, rand(30,50),1)
	else
		src.visible_message("<b><font color=red>[src.name] tips over!</font></b>")

	src.power_change()
	src.anchored = 0
	return

//Oh no we're getting roughed up!  Dump out some product and break.
/obj/machinery/vending/proc/break_down() //was proc/malfunction, renamed to free up the name for a machinery-wide proc (this gets calls by pretty severe things anyway)
	for(var/datum/data/vending_product/R in src.product_list)
		if (R.product_amount <= 0) //Try to use a record that actually has something to dump.
			continue

		var/dump_path = null
		if (ispath(R.product_path))
			dump_path = R.product_path
		else if (istext(R.product_path))
			dump_path = text2path(R.product_path)
			if (isnull(dump_path))
				continue
		else
			continue

		while(R.product_amount>0) //and by some we mean literally all of it
			new dump_path(src.loc)
			R.product_amount--
		break

	status |= BROKEN
	power_change()
	return

//Somebody cut an important wire and now we're following a new definition of "pitch."
/obj/machinery/vending/proc/throw_item(var/item_name_to_throw = "")
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return null

	if(length(item_name_to_throw))
		for(var/datum/data/vending_product/R in src.product_list)
			if(item_name_to_throw == R.product_name_cache[R.product_path])
				if(R.product_amount > 0)
					throw_item_act(R, target)
					return R
				return
	else
		var/list/datum/data/vending_product/valid_products = list()
		for(var/datum/data/vending_product/R in src.product_list)
			if(R.product_amount <= 0) //Try to use a record that actually has something to dump.
				continue
			valid_products.Add(R)
		if(length(valid_products))
			var/datum/data/vending_product/vending_product = pick(valid_products)
			throw_item_act(vending_product, target)
			return vending_product

/obj/machinery/vending/proc/throw_item_act(var/datum/data/vending_product/R, var/mob/living/target)
	var/obj/throw_item = null
	//Big if/else trying to create the object properly
	if (ispath(R.product_path))
		var/dump_path = R.product_path
		throw_item = new dump_path(src.loc)
	else if (istext(R.product_path))
		var/dump_path = text2path(R.product_path)
		if (dump_path)
			throw_item = new dump_path(src.loc)
	else if (isicon(R.product_path))
		var/icon/welp = icon(R.product_path)
		if (welp.Width() > 32 || welp.Height() > 32)
			welp.Scale(32, 32)
			R.product_path = welp // if scaling is required reset the product_path so it only happens the first time
		var/obj/dummy = new /obj/item(src.get_output_location())
		dummy.name = R.product_name
		dummy.desc = "?!"
		dummy.icon = welp
		throw_item = dummy
	else if (isfile(R.product_path))
		var/sound/S = sound(R.product_path)
		if (S)
			R.product_amount--
			SPAWN_DBG(0)
				playsound(src.loc, S, 50, 0)
				src.visible_message("<span class='alert'><b>[src] launches [R.product_name] at [target.name]!</b></span>")
				src.generate_HTML(1)
			return 1

	if (throw_item)
		if(src.freezer)
			throw_item = deep_freeze(throw_item)
		R.product_amount--
		use_power(10)
		if (src.icon_vend) //Show the vending animation if needed
			flick(src.icon_vend,src)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "productDispensed=[R.product_name]")
		src.generate_HTML(1)
		throw_item.throw_at(target, 16, 3)
		src.visible_message("<span class='alert'><b>[src] launches [throw_item.name] at [target.name]!</b></span>")
		postvend_effect()
		return 1
	return 0

/obj/machinery/vending/malfunction(mult)
	..()
	if (probmult(15))
		elecflash(src)
	else
		if (prob(50))//fairly common
			throw_item()
	if (probmult(5)) //cause lasting problems :3
		//so having this list duplicated here is kinda shit but src.vendwires isn't set until something generates the vending machine's HTML
		cut(pick(list("Violet", "Orange", "Goldenrod", "Green",	"Broun")))
	if (probmult(1))
		var/mob/living/carbon/human/H = locate() in orange(1, src)
		fall(H) //:D

/obj/machinery/vending/malfunction_hint()
	if (can_fall == 2)
		return "Pry the machine back on its feet with a crowbar." //duh
	else if (src.status & BROKEN) //toppled machines count as BROKEN but can be fixed. This is broken glass dead monkeys levels of fucked.
		return "Machine is beyond repair. Replace with a new unit."

	if (src in random_events.maintenance_event.unmaintained_machines)
		return "Open the maintenance hatch and replace the machine's wiring."
	return FALSE

//Since repairing a vending machine involves replacing the wiring...
/obj/machinery/vending/malfunction_resolve()
	src.wires = initial(src.wires)
	src.extended_inventory = FALSE
	src.seconds_electrified = 0
	src.shoot_inventory = FALSE
	src.ai_control_enabled = TRUE
	src.freezer = initial(src.freezer)
	..()

/obj/machinery/vending/proc/isWireColorCut(var/wireColor)
	var/wireFlag = VendWireColorToFlag[wireColor]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/vending/proc/isWireCut(var/wireIndex)
	var/wireFlag = VendIndexToFlag[wireIndex]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/vending/proc/cut(var/wireColor)
	var/wireFlag = VendWireColorToFlag[wireColor]
	var/wireIndex = VendWireColorToIndex[wireColor]
	src.wires &= ~wireFlag
	switch(wireIndex)
		if(WIRE_EXTEND)
			src.extended_inventory = 0
			src.generate_HTML(1)
		if(WIRE_SHOCK)
			src.seconds_electrified = -1
		if (WIRE_SHOOTINV)
			if(!src.shoot_inventory)
				src.shoot_inventory = 1
		if (WIRE_SCANID) //yeah the scanID wire also controls the AI control FUCK YOU
			if(src.ai_control_enabled)
				src.ai_control_enabled = 0
		if (WIRE_FREEZER)
			if(src.freezer)
				src.freezer = 0
	src.generate_HTML(0, 1)

/obj/machinery/vending/proc/mend(var/wireColor)
	var/wireFlag = VendWireColorToFlag[wireColor]
	var/wireIndex = VendWireColorToIndex[wireColor] //not used in this function
	src.wires |= wireFlag
	switch(wireIndex)
		if(WIRE_SCANID)
			src.ai_control_enabled = 1
		if(WIRE_SHOCK)
			src.seconds_electrified = 0
		if (WIRE_SHOOTINV)
			src.shoot_inventory = 0
		if (WIRE_FREEZER)
			src.freezer = 1
	src.generate_HTML(0, 1)

/obj/machinery/vending/proc/pulse(var/wireColor)
	var/wireIndex = VendWireColorToIndex[wireColor]
	switch (wireIndex)
		if (WIRE_EXTEND)
			src.extended_inventory = !src.extended_inventory
			src.generate_HTML(1)
		if (WIRE_SCANID)
			src.ai_control_enabled = !src.ai_control_enabled
		if (WIRE_SHOCK)
			src.seconds_electrified = 30
		if (WIRE_SHOOTINV)
			src.shoot_inventory = !src.shoot_inventory
		if (WIRE_FREEZER)
			src.freezer = !src.freezer


	src.generate_HTML(0, 1)

//"Borrowed" airlock shocking code.
/obj/machinery/vending/proc/shock(mob/user, prb)
	if (!prob(prb))
		return 0

	if (status & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0

	if (src.electrocute(user, 1))
		return 1
	else
		return 0

/obj/machinery/vending/electrocute(mob/user, netnum)
	if (!netnum)		// unconnected cable is unpowered
		return 0

	var/datum/powernet/PN			// find the powernet
	if (powernets && powernets.len >= netnum)
		PN = powernets[netnum]

	elecflash(src)

	if (!PN) //Wire note: Fix for Cannot read null.avail
		return 0

	if (user.shock(src, PN.avail, user.hand == 1 ? "l_arm" : "r_arm", 1, 0))
		for (var/mob/M in AIviewers(src))
			if (M == user)	continue
			M.show_message("<span class='alert'>[user.name] was shocked by the [src.name]!</span>", 3, "<span class='alert'>You hear a heavy electrical crack</span>", 2)
		return 1
	return 0

/datum/action/bar/icon/right_vendor //This is used when you try to remove someone elses handcuffs.
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "right_vendor"
	icon = 'icons/obj/items/tools/tools.dmi'
	icon_state = "crowbar"
	var/obj/machinery/vending/vendor = null

	New(vending_machine, var/Owner)
		src.vendor = vending_machine
		src.owner = Owner
		..()

	onUpdate()
		..()
		if(!IN_RANGE(src.owner, src.vendor, 1) || src.vendor == null || src.owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(!(src.vendor.status & BROKEN)) //it somehow got fixed while making it go upright??
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(!IN_RANGE(src.owner, src.vendor, 1) || src.vendor == null || src.owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		for(var/mob/M in AIviewers(src.owner))
			M.show_message("<span class='notice'><B>[src.owner] starts trying to pry \the [src.vendor] back up...</B></span>", 1)

	onEnd()
		..()
		if(src.owner && vendor && (src.vendor.status & BROKEN))
			src.vendor.can_fall = 1
			src.vendor.layer = initial(src.vendor.layer)
			src.vendor.anchored = 1
			src.vendor.status &= ~BROKEN
			src.vendor.power_change()

			for(var/mob/M in AIviewers(src.owner))
				M.show_message("<span class='notice'><B>[src.owner] manages to stand \the [src.vendor] back upright!</B></span>", 1)

#undef WIRE_EXTEND
#undef WIRE_SCANID
#undef WIRE_SHOCK
#undef WIRE_SHOOTINV
#undef WIRE_FREEZER

/obj/machinery/vending/coffee
	name = "coffee machine"
	desc = "A Robust Coffee vending machine."
	pay = 1
	vend_delay = 25
	icon_state = "coffee"
	icon_vend = "coffee-vend" //TODO: resprite vend state (along with broken/tipped and tipped glow, other vending machines also require this)
	icon_panel = "coffee-panel"
	light_r = 1
	light_g = 0.88
	light_b = 0.3

	//i'd love at some point for this fuckin' thing to rarely drop a cup wrong or out entirely and then it just spills on the floor (and do it more often if hacked)
	prevend_effect()
		playsound(src.loc, 'sound/misc/pourdrink.ogg', 50, 1, 0.1)
		return

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/coffee, 25, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/tea, 10, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/xmas, 10, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/chickensoup, 10, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/weightloss_shake, 10, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/pseudocoffee, 10, cost=PAY_TRADESMAN, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/cola, rand(1, 6), cost=PAY_UNTRAINED/5, hidden=1)

/obj/machinery/vending/snack
	name = "snack machine"
	desc = "Tasty treats for crewman eats."
	pay = 1
	icon_state = "snack"
	icon_panel = "snack-panel"
	slogan_list = list("Try our new nougat bar!",
	"Twice the calories for half the price!",
	"Fill the gap in your stomach right now!",
	"A fresh delight is only a bite away!",
	"We feature Discount Dan's Noodle Soups!")
	light_r =0.6
	light_g = 0.92
	light_b = 0.85

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/candy/regular, 10, cost=PAY_UNTRAINED/20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/chips, 10, cost=PAY_UNTRAINED/15)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/donut, 10, cost=PAY_TRADESMAN/20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/fries, 10, cost=PAY_TRADESMAN/15)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/peanuts, 10, cost=PAY_UNTRAINED/20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/noodlecup, 10, cost=PAY_UNTRAINED/8)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/plasticpackage, 10, cost=PAY_UNTRAINED/10)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/fork/plastic, 10, cost=PAY_UNTRAINED/20)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/spoon/plastic, 10, cost=PAY_UNTRAINED/20)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/knife/plastic, 10, cost=PAY_UNTRAINED/20)

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/peanuts/salty, rand(1, 2), cost=PAY_UNTRAINED/15, hidden=1)

/obj/machinery/vending/snack_freezer
	name = "snack machine"
	desc = "Frozen treats for crewman eats."
	pay = 1
	icon_state = "frozen"
	icon_panel = "frozen-panel"
	slogan_list = list("Flash Frozen Ferfection!",
	"Twice the calories for half the price!",
	"Buy now! Warm later!",
	"A fresh delight is only a microwave away!",
	"We feature Discount Dan's Tee Vee Dinners!")
	freezer = TRUE
	wires = 31 // 1 + 2 + 4 + 8 + 16
	light_r =1
	light_g = 0.4
	light_b = 0.4

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/tvdinner, 8, cost=PAY_UNTRAINED/6)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/burrito, 12, cost=PAY_UNTRAINED/8)
		product_list += new/datum/data/vending_product(/obj/item/popsicle, 8, cost=PAY_UNTRAINED/8)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ice_cream/goodrandom, 4, cost=PAY_UNTRAINED/7)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/yoghurt/frozen, 4, cost=PAY_UNTRAINED/5)

/obj/machinery/vending/cigarette //eventually wanna make one of these specifically for medbay
	name = "cigarette machine"
	desc = "If you don't have any money for smokes, you can at least pretend you're playing extremely complicated pinball."
	pay = 1
	vend_delay = 10
	icon_state = "cigs_old" //credits: based heavily and directly on a 64x64 sprite by a grody clown which was made in direct response to my sudden request for a knobby cigarete vendin machin thank you kindly a grody clown -reginaldhj
	icon_panel = "cigs-panel"
	slogan_list = list("Space cigs taste good like a cigarette should!",
	"I'd rather toolbox than switch.",
	"Smoke!",
	"Don't believe the reports - smoke today!")
	light_r =0.7
	light_g = 0.67
	light_b = 0.51

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/cigpacket, 20, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/nicofree, 10, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/menthol, 10, cost=PAY_UNTRAINED/5)

		product_list += new/datum/data/vending_product(/obj/item/cigpacket/propuffs, 10, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/cigarillo, 10, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/brute, 5, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/burn, 5, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/cigarbox, 1, cost=PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/nicotine, 10, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/matchbook, 10, cost=PAY_UNTRAINED/20)
		product_list += new/datum/data/vending_product(/obj/item/device/light/zippo, 5, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vape, 10, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/ecig_refill_cartridge, 20, cost=PAY_TRADESMAN/5)

		product_list += new/datum/data/vending_product(/obj/item/device/igniter, rand(1, 6), hidden=1, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/random, rand(0, 1), hidden=1, cost=420)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/cigarillo/juicer, rand(6, 9), hidden=1, cost=69)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/greasy, rand(1,3),hidden=1, cost=PAY_UNTRAINED/5)

	noknobs
		desc = "If you want to get cancer, might as well do it in style!"
		icon_state = "cigs"
		has_glow = FALSE

/obj/machinery/vending/cigarette/schweewa
	icon_state = "s_cigs_old"
	icon_panel = "cigs-panel"
	acceptcard = 0
	desc = "Who still smokes these?"
	has_glow = FALSE
	slogan_list = list("Juicer Schweet's Original Rowdy Rillos, Quality you can crave.",
	"Fresh Fine Flamable Farmaceuticals.",
	"Smoke!",
	"Watch out! You're cravin one now!")

	create_products()
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/cigarillo/juicer, rand(6, 9), cost=PAY_UNTRAINED/6)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/cigarillo/juicer, rand(6, 9), cost=PAY_UNTRAINED/6)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/cigarillo/juicer, rand(6, 9), cost=PAY_UNTRAINED/6)

		product_list += new/datum/data/vending_product(/obj/item/cigpacket/cigarillo, rand(6, 9), cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/cigarillo, rand(6, 9), cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/cigarillo, rand(6, 9), cost=PAY_UNTRAINED/5)

		product_list += new/datum/data/vending_product(/obj/item/cigpacket/greasy, rand(6, 9), cost=PAY_UNTRAINED/6)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/greasy, rand(6, 9), cost=PAY_UNTRAINED/6)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/greasy, rand(6, 9), cost=PAY_UNTRAINED/6)

		product_list += new/datum/data/vending_product(/obj/item/device/light/zippo, 5, cost=PAY_UNTRAINED/4)

		product_list += new/datum/data/vending_product(/obj/item/cigpacket/random, rand(1,3), hidden=1, cost=420)

	noknobs
		desc = "Higher tech, but really doesn't have the same vibe."
		icon_state = "s_cigs"


/obj/machinery/vending/medical
	name = "NanoMed Plus"
	desc = "Medical drug dispenser."
	icon_state = "med"
	icon_panel = "standard-panel"
	icon_deny = "med-deny"
	req_access_txt = "5"
	mats = 10
	acceptcard = 0
	window_size = "400x675"
	light_r =1
	light_g = 0.88
	light_b = 0.88
	//print_receipts_long = TRUE



	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/bruise, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/burn, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/mender_refill_cartridge/brute, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/mender_refill_cartridge/burn, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/syringe, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/antihistamine, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/atropine, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/calomel, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/antitoxin, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/epinephrine, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/filgrastim, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/heparin, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/insulin, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/morphine, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/eyedrops, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/antirad, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/proconvertin, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/aspirin, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/saline, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/synaptizine, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/mannitol, 8)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/mutadone, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/salbutamol, 8)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/ipecac, 8)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/ampoule/smelling_salts, 5)
		product_list += new/datum/data/vending_product(/obj/item/bandage, 5)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/healthanalyzer, 5)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/healthanalyzer_upgrade, 5)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/healthanalyzer_organ_upgrade, 5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/medical_surgery_guide, 2)

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/sulfonal, rand(1, 2), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/pancuronium, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/LSD, rand(1, 6), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vape/medical, 1, hidden=1, cost=400)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/bath_bomb, rand(7, 13), hidden=1, cost=100)

/obj/machinery/vending/medical_public
	name = "Public MiniMed"
	desc = "Medical supplies for everyone! Almost nearly as good as what the professionals use, kinda!"
	pay = 1
	vend_delay = 10
	icon_state = "pubmed"
	icon_panel = "pubmed-panel"
	slogan_list = list("It pays to be safe!",
	"It's safest to pay!",
	"We've gone green! Now using 100% recycled materials!",
	"Address all complaints about Public MiniMed services to FILE NOT FOUND for a swift response.",
	"Now 80% sterilized!",
	"There is a 1000 credit fine for bleeding on this machine.",
	"Are you or a loved one currently dying? Consider Discount Dan's burial solutions!",
	"ERROR: Item \"Stimpack\" not found!",
	"Please, be considerate! Do not block access to the machine with your bloodied carcass.",
	"Please contact your insurance provider for details on reduced payment options for this machine!")
	window_size = "400x500"

	light_r =1
	light_g = 0.88
	light_b = 0.88
	print_receipts_long = TRUE

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/mini/bruise, 5, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/mini/burn, 5, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/epinephrine, 5, cost=PAY_TRADESMAN/3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/salicylic_acid, 5, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/menthol, 5, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/charcoal, 5, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/antihistamine, 2, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/spaceacillin, 2, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/naloxone, 2, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/ampoule/smelling_salts, 2, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/healthanalyzer, 2, cost=PAY_TRADESMAN/4)
		product_list += new/datum/data/vending_product(/obj/item/bandage, 5, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/surgical, 5, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/latex, 5, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/healthanalyzer_upgrade, rand(0, 2), hidden=1, cost=PAY_TRADESMAN/4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/mini/synthflesh, rand(0, 5), hidden=1, cost=PAY_TRADESMAN/4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vape/medical, 1, hidden=1, cost=PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/bath_bomb, rand(2, 5), hidden=1, cost=PAY_TRADESMAN)
		if (prob(5))
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/bathsalts, 1, hidden=1, cost=PAY_TRADESMAN)

		if (prob(15))
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/coffee, rand(1,5), hidden=1, cost=PAY_TRADESMAN/10)
		else
			slogan_list += "ERROR: OUT OF COFFEE!"

/obj/machinery/vending/security
	name = "SecTech"
	desc = "A security equipment vendor."
	icon_state = "sec"
	icon_panel = "standard-panel"
	icon_deny = "sec-deny"
	req_access_txt = "1"
	acceptcard = 0

	light_r =1
	light_g = 0.8
	light_b = 0.9

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/handcuffs/guardbot, 16)
		product_list += new/datum/data/vending_product(/obj/item/handcuffs, 8)
		product_list += new/datum/data/vending_product(/obj/item/chem_grenade/flashbang, 5)
		product_list += new/datum/data/vending_product(/obj/item/chem_grenade/fog, 5)
		product_list += new/datum/data/vending_product(/obj/item/device/flash, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/helmet/hardhat/security, 4)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/security, 2)
		product_list += new/datum/data/vending_product(/obj/item/stackable_ammo/pistol/capacitive/three, 3)
		product_list += new/datum/data/vending_product(/obj/item/stackable_ammo/rifle/capacitive/burst/three, 2)
		product_list += new/datum/data/vending_product(/obj/item/implantcase/antirev, 3)
		product_list += new/datum/data/vending_product(/obj/item/implanter, 1)
		product_list += new/datum/data/vending_product(/obj/item/gun/modular/NT/pistol, 3)
		product_list += new/datum/data/vending_product(/obj/item/gun/modular/NT/shotty, 2)
#ifdef RP_MODE
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/space_law, 1)
#endif
		product_list += new/datum/data/vending_product(/obj/item/device/flash/turbo, rand(1, 6), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/stackable_ammo/pistol/NT/ten, rand(1, 2), hidden=1)

/obj/machinery/vending/security_ammo //ass jam time yes
	name = "AmmoTech"
	desc = "A restricted ammunition vendor."
	icon_state = "sec"
	icon_panel = "standard-panel"
	icon_deny = "sec-deny"
	req_access_txt = "37"
	acceptcard = 0
	light_r =1
	light_g = 0.8
	light_b = 0.9
	is_syndicate = 1

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/stackable_ammo/pistol/capacitive/ten, 3)
		product_list += new/datum/data/vending_product(/obj/item/stackable_ammo/pistol/NT/ten, 3)
		product_list += new/datum/data/vending_product(/obj/item/stackable_ammo/shotgun/slug_rubber/ten, 3)
		product_list += new/datum/data/vending_product(/obj/item/stackable_ammo/shotgun/juicer/three, 3)
		product_list += new/datum/data/vending_product(/obj/item/stackable_ammo/rifle/tranq/three, 3)
		product_list += new/datum/data/vending_product(/obj/item/stackable_ammo/rifle/anti_mutant/three, 3)
		product_list += new/datum/data/vending_product(/obj/item/stackable_ammo/pistol/zaubertube/three, 1, hidden=1) // not sure why this is in here - mylie

/obj/machinery/vending/cola
	name = "soda machine"
	pay = 1

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/cola, rand(1, 6), cost=PAY_UNTRAINED/10, hidden = 1)
		product_list += new/datum/data/vending_product(/obj/item/canned_laughter, rand(1,5), cost=PAY_UNTRAINED/5,hidden=1)
		if(prob(25))
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/softsoft_pizza, rand(1, 3), cost=PAY_UNTRAINED/5, hidden = 1)

	red
		icon_state = "robust"
		icon_panel = "robust-panel"
		slogan_list = list("Drink Robust-Eez, the classic robustness tonic!",
		"A Dr. Pubber a day keeps the boredom away!",
		"Cool, refreshing Lime-Aid - it's good for you!",
		"Grones Soda! Where has your bottle been today?",
		"Decirprevo. The sophisticate's bottled water.",
		"Tell your friends! Mountain Poo is back!")

		light_r =1
		light_g = 0.4
		light_b = 0.4

		create_products()
			..()
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/red, 10, cost=PAY_UNTRAINED/10)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/pink, 10, cost=PAY_UNTRAINED/6)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/lime, 10, cost=PAY_UNTRAINED/6)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/poo, 10, cost=PAY_UNTRAINED/6)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/grones, 10, cost=PAY_UNTRAINED/6)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/bottledwater, 10, cost=PAY_UNTRAINED/4)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/cola/random, 10, cost=PAY_UNTRAINED/10) //does this even work??

	blue
		icon_state = "grife"
		icon_panel = "grife-panel"
		slogan_list = list("Grife-O - the soda of a space generation!",
		"The taste of nature!",
		"Spooky Dan's - it's altogether ooky!",
		"Everyone can see Orange-Aid is best!",
		"Decirprevo. The sophisticate's bottled water.",
		"Mr. Piss - Tastes normal!",
		"Aperitivo analcolico a base di carne - Cappy Cola!")

		light_r =0.5
		light_g = 0.5
		light_b = 1



		create_products()
			..()
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/blue, 10, cost=PAY_UNTRAINED/10)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/orange, 10, cost=PAY_UNTRAINED/6)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/spooky, 10, cost=PAY_UNTRAINED/6)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/spooky2,10, cost=PAY_UNTRAINED/6)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/pee, 10, cost=PAY_UNTRAINED/6)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/italian, 10, cost=PAY_UNTRAINED/6)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/bottledwater, 10, cost=PAY_UNTRAINED/4)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/cola/random, 10, cost=PAY_UNTRAINED/10)

/obj/machinery/vending/electronics
	name = "ElecTek Vendomaticotron"
	desc = "Dispenses electronics equipment."
	icon_state = "generic"
	icon_panel = "generic-panel"
	acceptcard = 0
	slogan_list = list("Stop fussing about in boxes, use ElecTek!",
	"Now with boards 100% of the time!",
	"No carbs!",
	"Now with 50% extra inventory!")

	light_r =1
	light_g = 0.88
	light_b = 0.3

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/electronics/battery, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/board, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/fuse, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/switc, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/keypad, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/screen, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/capacitor, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/buzzer, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/resistor, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/bulb, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/relay, 30)

/obj/machinery/vending/mechanics
	name = "MechComp Dispenser"
	desc = "Dispenses electronics equipment."
	icon_state = "generic"
	icon_panel = "generic-panel"
	acceptcard = 0
	pay = 0
	has_glow = FALSE

	light_r =1
	light_g = 0.88
	light_b = 0.3

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/breaker_box, 30)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/mechanicbook, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/andcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/association, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/math, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/counter, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/trigger/button, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/trigger/buttonPanel, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/mc14500, 30)
		product_list += new/datum/data/vending_product(/obj/disposalconstruct/mechanics, 10)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/pausecomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/dispatchcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/gunholder/recharging, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/filecomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/flushcomp, 3) // reduced from 30
		product_list += new/datum/data/vending_product(/obj/item/mechanics/accelerator, 3) // reduced from 30
		product_list += new/datum/data/vending_product(/obj/item/mechanics/gunholder, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/hscan, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/instrumentPlayer, 10)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/ledcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/screen, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/miccomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/orcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/pscan, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/cashmoney, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/networkcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/trigger/pressureSensor, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/radioscanner, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/regfind, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/regreplace, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/relaycomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/selectcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/buffercomp, 30)
		product_list += new/datum/data/vending_product(/obj/disposalconstruct/mechanics_sensor, 10)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/sigbuilder, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/sigcheckcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/synthcomp, 30)
		//product_list += new/datum/data/vending_product(/obj/item/mechanics/telecomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/zapper, 10)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/thprint, 10)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/togglecomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/triplaser, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/wificomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/wifisplit, 30)

/obj/machinery/vending/computer3
	name = "CompTech"
	desc = "A computer equipment vendor."
	icon_state = "comp"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	acceptcard = 0

	light_r =1
	light_g = 0.9
	light_b = 0.1

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/motherboard, 8)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/fixed_disk, 8)
		//product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/computer3boot, 4)
		product_list += new/datum/data/vending_product(/obj/item/peripheral/card_scanner, 8)
		product_list += new/datum/data/vending_product(/obj/item/peripheral/network/powernet_card, 4)

		product_list += new/datum/data/vending_product(/obj/item/peripheral/drive, rand(1, 6), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/peripheral/drive/cart_reader, rand(1, 6), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/peripheral/prize_vendor, rand(1, 6), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/peripheral/network/radio, rand(1, 6), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/peripheral/drive/tape_reader, rand(1, 6), hidden=1)

//cogwerks- adding a floppy disk vendor
/obj/machinery/vending/floppy
	name = "Software On-The-Go!" //NT Branding
	desc = "A computer software vendor."
	icon_state = "software"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	pay = 1
	acceptcard = 1
	slogan_list = list("Remember to read the EULA!",
	"Don't copy that floppy!",
	"Welcome to the information age!")

	light_r =0.03
	light_g = 1
	light_b = 0.2

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/computer3boot, 6, cost=PAY_TRADESMAN/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/read_only/terminal_os, 6, cost=PAY_TRADESMAN/4)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/read_only/network_progs, 4, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/read_only/medical_progs, 2, cost=PAY_TRADESMAN/2)

		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/read_only/security_progs, 2, cost=PAY_TRADESMAN/2, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/read_only/communications, 2, cost=PAY_TRADESMAN, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/storage/box/diskbox, rand(2,3), cost=PAY_UNTRAINED/2)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy, rand(5,8), cost=PAY_UNTRAINED/5)

//for the GNU/Battleship
//general crimer software + a couple PDA bomb carts/emags maybe??? imo
/*
/obj/machinery/vending/floppy/syndicate
	name = "Free AND Legal Software"
	desc = "A dubious computer software vendor."
	icon_state = "software"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	pay = 1
	acceptcard = 1

	slogan_list = list("Remember to read the licensing agreement! Carefully! All of it!",
	"Copy that floppy!",
	"Welcome to the age of free and open-source software!",
	"Death to DWAINE! Long Live OpenDWAINE!")

	light_r =0.03
	light_g = 1
	light_b = 0.2

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/storage/box/diskbox, rand(2,3), cost=PAY_UNTRAINED/2)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy, rand(5,8), cost=PAY_UNTRAINED/5)
*/

/obj/machinery/vending/pda //cogwerks: vendor to clean up the pile of PDA carts a bit
	name = "CartyParty" //We'll also just say that's NT Branding
	desc = "A PDA cartridge vendor."
	icon_state = "pda"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	pay = 1
	acceptcard = 1
	slogan_list = list("Convenient and feature-packed!",
	"For the busy jet-setting businessperson on the go!",
	"-CHECKSUM FAILURE | STACK OVERFLOW - CONSULT YOUR TECHN-WONK")

	light_r =0.4
	light_g = 0.4
	light_b = 1

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/device/pda2, 20, cost=PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/atmos, 5, cost=PAY_TRADESMAN/4)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/mechanic, 2, cost=PAY_DOCTORATE/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/game_codebreaker, 10, cost=PAY_UNTRAINED/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/janitor, 5, cost=PAY_TRADESMAN/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/genetics, 5, cost=PAY_DOCTORATE/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/engineer, 5, cost=PAY_TRADESMAN/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/botanist, 5, cost=PAY_TRADESMAN/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/medical, 5, cost=PAY_DOCTORATE/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/toxins, 5, cost=PAY_DOCTORATE/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/quartermaster, 5, cost=PAY_TRADESMAN/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/ringtone, 5, cost=PAY_TRADESMAN/6)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/ringtone_basic, 5, cost=PAY_TRADESMAN/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/ringtone_chimes, 5, cost=PAY_TRADESMAN/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/ringtone_beepy, 5, cost=PAY_TRADESMAN/3)
		product_list += new/datum/data/vending_product(/obj/item/device/pda_module/flashlight/high_power, 10, cost=PAY_UNTRAINED/2)

		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/security, 1, cost=PAY_TRADESMAN/3, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/head, 1, cost=PAY_IMPORTANT/3, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/clown, 1, cost=PAY_DUMBCLOWN, hidden=1)

/obj/machinery/vending/book //cogwerks: eventually this oughta have some of the wiki job guides available in it
	name = "Books4u" //NT branding for guidebooks and such
	desc = "A printed text vendor."
	icon_state = "books"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	pay = 1
	acceptcard = 1
	slogan_list = list("Read a book today!",
	"Educate thyself!",
	"Book Club meeting in the Chapel, every Thursday!")

	light_r =0.2
	light_g = 1
	light_b = 0.03

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/paper/engine, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/cookbook, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/dwainedummies, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/guardbot_guide, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/hydroponicsguide, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/monster_manual, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/Cloning, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/pharmacopia, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/minerals, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/player_piano, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/DNDrulebook, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/monster_manual_revised, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/ai_programming_101, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/captaining_101, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/dealing_with_clonelieness, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/elective_prosthetics_for_dummies, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/teg_guide, 2, cost=PAY_UNTRAINED/5)

		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/the_trial, 1, cost=PAY_UNTRAINED/5, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/critter_compendium, 1, cost=PAY_UNTRAINED/5, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/syndies_guide, 1, cost=PAY_UNTRAINED/5, hidden=1)

/obj/machinery/vending/kitchen
	name = "FoodTech"
	desc = "Food storage unit."
	icon_state = "food"
	icon_panel = "standard-panel"
	icon_off = "food-off"
	icon_broken = "food-broken"
	icon_fallen = "food-fallen"
	req_access_txt = "28"
	acceptcard = 0

	light_r =1
	light_g = 0.88
	light_b = 0.3

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/chefhat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/chef, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/apron,2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/souschefhat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/souschef, 2)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/fork, 10)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/knife, 10)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/spoon, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/drinkingglass/icing, 3)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/chopsticks_package, 5)
		product_list += new/datum/data/vending_product(/obj/item/plate/tray, 3)
		product_list += new/datum/data/vending_product(/obj/table/kitchen_island, 2)
		product_list += new/datum/data/vending_product(/obj/item/storage/lunchbox, 12)
		product_list += new/datum/data/vending_product(/obj/item/ladle, 1)
		product_list += new/datum/data/vending_product(/obj/item/soup_pot, 1)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/rollingpin, 2)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/knife/cleaver, 1)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/knife/pizza_cutter, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bowl, 10)
		product_list += new/datum/data/vending_product(/obj/item/plate, 10)
		product_list += new/datum/data/vending_product(/obj/item/matchbook, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ice_cream_cone, 20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/oatmeal, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/flour, 20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/rice, 20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/sugar, 20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/butter, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/spaghetti, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/meatball, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/syrup, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/mayo, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/ketchup, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/tomato_sauce, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/tomato, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/apple, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/lettuce, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/potato, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/corn, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/seaweed, 10)

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/breakfast, rand(2, 4), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/snack_cake, rand(1, 3), hidden=1)

/obj/machinery/vending/kitchen/lite
	name = "FoodTech Mini"
	desc = "Food storage unit."
	icon_state = "food"
	icon_panel = "standard-panel"
	icon_off = "food-off"
	icon_broken = "food-broken"
	icon_fallen = "food-fallen"
	req_access_txt = "28"
	acceptcard = 0

	light_r =1
	light_g = 0.88
	light_b = 0.3

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/storage/lunchbox, 12)
		product_list += new/datum/data/vending_product(/obj/item/ladle, 1)
		product_list += new/datum/data/vending_product(/obj/item/soup_pot, 1)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/rollingpin, 2)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/knife/cleaver, 1)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/knife/pizza_cutter, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/oatmeal, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/flour, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/rice, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/sugar, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/butter, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/spaghetti, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/meatball, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/syrup, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/mayo, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/ketchup, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/tomato_sauce, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/tomato, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/apple, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/lettuce, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/potato, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/corn, 10)

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/breakfast, rand(2, 4), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/snack_cake, rand(1, 3), hidden=1)


/obj/machinery/vending/gunse
	name = "NanoGunse"
	desc = "Gunse storage unit."
	icon_state = "gunse"
	icon_panel = "standard-panel"
	icon_off = "gunse-off"
	icon_broken = "gunse-broken"
	icon_fallen = "gunse-fallen"
	req_access_txt = ""
	acceptcard = 1
	pay = 1

	light_r =1
	light_g = 0.88
	light_b = 0.3

	/*attackby(obj/item/W, mob/user)
		if(!user?.client)
			return ..()
		if(istype(W, /obj/item/gun/modular/))
			if (alert(user, "Would you like to store your weapon?", "Confirmation", "Yes", "No") == "Yes")
				user.client.save_cloud_gun(1, gun=W)
				user.u_equip(W)
				W.dropped(user)
				qdel(W)
			return

		else
			..()*/


	create_products()
		//..()
		/*
		product_list += new/datum/data/vending_product(/obj/item/gun/modular/italian/revolver/improved, 2)
		product_list += new/datum/data/vending_product(/obj/item/gun/modular/soviet/basic, 2)
		product_list += new/datum/data/vending_product(/obj/item/gun/modular/juicer/receiver, 2)
		product_list += new/datum/data/vending_product(/obj/item/gun/modular/juicer/long, 2)
		product_list += new/datum/data/vending_product(/obj/item/gun/modular/foss, 2)
		product_list += new/datum/data/vending_product(/obj/item/gun/modular/foss/long, 2)
		product_list += new/datum/data/vending_product(/obj/item/gun/modular/foss/punt, 2)
*/
		//above this line is for debug and testing only, they'll go in the bin later.
		//all should require permit, some should require permit and sec
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/pocketguide/gunsmith, 5, cost = 10)
		//full gunse
		product_list += new/datum/data/vending_product(/obj/item/gun/modular/NT/pistol, 2, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/gun/modular/NT/rifle, 1, cost = PAY_TRADESMAN*1.5)
		product_list += new/datum/data/vending_product(/obj/item/gun/modular/NT/shotty, 1, cost = PAY_TRADESMAN*1.5)
		//DIY section
		//receivers
		//partse
		product_list += new/datum/data/vending_product(/obj/item/gun_parts/barrel/NT, 5, cost = PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/gun_parts/barrel/NT/long, 5, cost = PAY_UNTRAINED*1.1)
		product_list += new/datum/data/vending_product(/obj/item/gun_parts/barrel/NT/long/very, 1, hidden=1, cost = PAY_TRADESMAN*1.2)
		product_list += new/datum/data/vending_product(/obj/item/gun_parts/barrel/NT/short, 2, 2, cost = PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/gun_parts/barrel/NT/shotty, 2, cost = PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/gun_parts/grip/NT, 6, cost = PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/gun_parts/grip/NT/fancy, 2, cost = PAY_UNTRAINED/2)
		product_list += new/datum/data/vending_product(/obj/item/gun_parts/grip/NT/ceremonial, 2, cost = PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/gun_parts/grip/NT/stub, 2, cost = PAY_UNTRAINED/2)
		product_list += new/datum/data/vending_product(/obj/item/gun_parts/stock/NT, 2, cost = PAY_UNTRAINED/1.5)
		product_list += new/datum/data/vending_product(/obj/item/gun_parts/stock/NT/precision, 2, cost = PAY_UNTRAINED/2)
		//product_list += new/datum/data/vending_product(/obj/item/gun_parts/stock/NT/drum, 2, cost = PAY_UNTRAINED/2.5)
		product_list += new/datum/data/vending_product(/obj/item/gun_parts/stock/NT/wire, 2, cost = PAY_UNTRAINED/1.5)
		product_list += new/datum/data/vending_product(/obj/item/gun_parts/accessory/horn, 1, cost = PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/gun_parts/accessory/flashlight, 3, cost = PAY_UNTRAINED/4)
		//ammo
		product_list += new/datum/data/vending_product(/obj/item/stackable_ammo/pistol/NT/ten, 10, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/stackable_ammo/pistol/capacitive/ten, 10, cost = PAY_UNTRAINED)
		//hidden
		product_list += new/datum/data/vending_product(/obj/item/gun/modular/juicer/receiver, 1, hidden=1, cost = PAY_UNTRAINED*2)
		product_list += new/datum/data/vending_product(/obj/item/gun/modular/juicer/blunder, 1, hidden=1, cost = PAY_UNTRAINED*2)
		product_list += new/datum/data/vending_product(/obj/item/gun/modular/juicer/long, 1, hidden=1, cost = PAY_UNTRAINED*2)
		product_list += new/datum/data/vending_product(/obj/item/gun_parts/accessory/magazine/juicer, 1, hidden=1, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/gun_parts/grip/italian, 1, hidden=1, cost = PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/gun_parts/grip/italian/bigger,  1, hidden=1, cost = PAY_UNTRAINED*1.1)
		product_list += new/datum/data/vending_product(/obj/item/stackable_ammo/shotgun/coil/ten, 3, cost = PAY_TRADESMAN*1.3)

	diner
		name = "Fucile Fusilli"
		desc = "Un distributore automatico pieno di armi."
		create_products()
			product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/pocketguide/gunsmith, 5, cost = 10)
			product_list += new/datum/data/vending_product(/obj/item/gun/modular/italian/revolver/silly, 1, cost = PAY_DOCTORATE)
			product_list += new/datum/data/vending_product(/obj/item/gun/modular/italian/revolver/masterwork, 2, cost = PAY_DOCTORATE)
			product_list += new/datum/data/vending_product(/obj/item/gun/modular/italian/revolver/improved, 4, cost = PAY_TRADESMAN)
			product_list += new/datum/data/vending_product(/obj/item/gun/modular/NT/pistol, 2, cost = PAY_TRADESMAN*0.9)
			product_list += new/datum/data/vending_product(/obj/item/gun/modular/NT/rifle, 1, cost = PAY_TRADESMAN*1.4)

			product_list += new/datum/data/vending_product(/obj/item/gun_parts/grip/italian, 3, cost = PAY_UNTRAINED)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/grip/italian/bigger,  2, cost = PAY_UNTRAINED*1.1)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/grip/italian/meatball, 3, cost = PAY_UNTRAINED)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/grip/juicer/trans, 2, cost = PAY_UNTRAINED)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/barrel/italian/spicy, 5, cost = PAY_UNTRAINED)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/barrel/italian/accurate, 5, cost = PAY_UNTRAINED*1.1)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/grip/wizard, 1, cost = PAY_TRADESMAN)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/accessory/magazine/juicer, 5, cost = PAY_UNTRAINED*1.3)


			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/breakfast, rand(2, 4), cost = 15)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/snack_cake, rand(1, 3), cost = 10)


	debug
		name = "Debug Gunse Vendor"
		desc = "new! improviato! no more ammo*!!!! maximum relievo"
		pay = 0
		create_products()
			for(var/types in concrete_typesof(/obj/item/gun/modular))
				product_list += new/datum/data/vending_product(types, 2)
			for(var/types in concrete_typesof(/obj/item/gun_parts/))
				product_list += new/datum/data/vending_product(types, 2)
			for(var/types in concrete_typesof(/obj/item/stackable_ammo/)) // no more ammo? but its right here???
				product_list += new/datum/data/vending_product(types, 5)
			product_list += new/datum/data/vending_product(/obj/item/storage/box/foss_flashbulbs, 5)

		ammo
			name = "Debug Ammo Vendor"
			desc = "there were just too many fucking types of this shit and scrolling was bad"
			pay = 0
			create_products()
				for(var/types in concrete_typesof(/obj/item/stackable_ammo/))
					product_list += new/datum/data/vending_product(types, 5)
				product_list += new/datum/data/vending_product(/obj/item/storage/box/foss_flashbulbs, 5)

	juicer
		color = "#bbFFbb"
		name = "JUICER SYSTEN"
		create_products()
			product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/pocketguide/gunsmith, 5, cost = 10)
			product_list += new/datum/data/vending_product(/obj/item/gun/modular/juicer/blunder, 2, cost = PAY_TRADESMAN)
			product_list += new/datum/data/vending_product(/obj/item/gun/modular/juicer/long, 2, cost = PAY_TRADESMAN*1.1)
			product_list += new/datum/data/vending_product(/obj/item/gun/modular/juicer/ribbed, 2, cost = PAY_TRADESMAN)
			product_list += new/datum/data/vending_product(/obj/item/gun/modular/italian/revolver/improved, 2, cost = PAY_UNTRAINED*1.1)
			product_list += new/datum/data/vending_product(/obj/item/gun/modular/soviet/short/basic, 2, cost = PAY_TRADESMAN*1.2)
			product_list += new/datum/data/vending_product(/obj/item/gun/modular/NT/shotty, 3, hidden=1, cost = PAY_TRADESMAN)
			//product_list += new/datum/data/vending_product(/obj/item/gun/modular/foss, 2)
			//product_list += new/datum/data/vending_product(/obj/item/gun/modular/foss/long, 2)
			//product_list += new/datum/data/vending_product(/obj/item/gun/modular/foss/punt, 2)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/barrel/NT, 9, hidden=1, cost = PAY_UNTRAINED*0.8)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/barrel/NT/long/very, 3, hidden=1, cost = PAY_UNTRAINED*1.1)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/barrel/NT/long/padded, 3, hidden=1, cost = PAY_UNTRAINED)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/barrel/NT/shotty, 5, hidden=1, cost = PAY_UNTRAINED*0.9)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/barrel/soviet/long, 1, cost = PAY_UNTRAINED*1.3)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/barrel/soviet, 1, cost = PAY_UNTRAINED*1.1)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/barrel/juicer, 4, cost = PAY_UNTRAINED*0.6)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/barrel/juicer/chub, 4, cost = PAY_UNTRAINED*0.6)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/barrel/juicer/longer, 4, cost = PAY_UNTRAINED*0.9)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/barrel/juicer/ribbed, 4, cost = PAY_UNTRAINED*0.7)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/accessory/horn, 1, cost = PAY_UNTRAINED/5)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/accessory/flashlight, 3, cost = PAY_UNTRAINED/4)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/accessory/magazine/juicer, 3, cost = PAY_UNTRAINED)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/accessory/magazine/juicer/four, 1, cost = PAY_UNTRAINED*1.5)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/grip/italian, 1, cost = PAY_UNTRAINED*0.9)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/grip/italian/bigger,  1, cost = PAY_UNTRAINED)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/grip/juicer/black, 4, cost = PAY_UNTRAINED*0.7)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/grip/juicer/red, 4, cost = PAY_UNTRAINED*0.7)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/grip/juicer/trans, 2, cost = PAY_UNTRAINED*0.8)
			product_list += new/datum/data/vending_product(/obj/item/gun_parts/grip/juicer, 3, cost = PAY_UNTRAINED*0.7)
			product_list += new/datum/data/vending_product(/obj/item/stackable_ammo/pistol/zaubertube/ten, 10, cost = PAY_TRADESMAN)
			product_list += new/datum/data/vending_product(/obj/item/stackable_ammo/pistol/NT/ten, 10, cost = PAY_TRADESMAN)
			product_list += new/datum/data/vending_product(/obj/item/stackable_ammo/pistol/capacitive/ten, 10, cost = PAY_UNTRAINED)
			product_list += new/datum/data/vending_product(/obj/item/stackable_ammo/shotgun/juicer, 10, cost = PAY_UNTRAINED*3)
			product_list += new/datum/data/vending_product(/obj/item/stackable_ammo/shotgun/slug_rubber, 10, cost = PAY_UNTRAINED)
			product_list += new/datum/data/vending_product(/obj/item/stackable_ammo/rifle/capacitive/burst, 10, cost = PAY_UNTRAINED*3)
			product_list += new/datum/data/vending_product(/obj/item/storage/box/foss_flashbulbs, 1, cost = PAY_UNTRAINED*1.1)


//The burden of these machinations weighs on my shoulders
//And thus you will be burdened
/datum/data/vending_product/player_product
	var/contents
	var/product_type
	var/real_name
	var/image/icon
	var/label
	product_amount = 1
	New(obj/item/product,price)
		. = ..()
		contents = list()
		if (!product)
			return
		product_type = product.type
		product_name = product.name
		real_name = product.real_name
		contents += product
		product_cost = price

/obj/item/machineboard
	name = "machine module"
	desc = "A circuit board assembly used in the construction of machinery."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "board1"
	mats = 2
	var/machinepath = null

/obj/item/machineboard/vending
	name = "vending machine module"
	desc = "An assembly used in the construction of a vending machine."
	machinepath = "/obj/machinery/vending/player"
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "base-module"

/obj/item/machineboard/vending/player
	icon_state = "player-module"

/obj/item/machineboard/vending/monkeys
	name = "Valuchimp module"
	machinepath = "/obj/machinery/vending/monkey"
	icon_state = "monkey-module"
	mats = 0 //No!!

/obj/machinery/vendingframe
	name = "vending machine frame"
	desc = "A generic vending machine frame."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "standard-frame"
	density = 1
	var/wrenched = FALSE
	var/glassed = FALSE
	var/boardinstalled = FALSE
	var/wiresinstalled = FALSE
	var/vendingtype = null
	var/basedesc
	var/boarddesc
	var/wiresdesc
	var/glassdesc
	var/readydesc
	New()
		. = ..()
		basedesc = desc
		boarddesc = "[desc] Seems to be missing the module, and everything else."
		wiresdesc = "[desc] Nothing has been wired up."
		glassdesc = "[desc] Isn't there usually glass?"
		readydesc = "[desc] Just needs a few screws tightened."

	proc/setFrameState(state, mob/user, obj/item/target)
		if (state == "WRENCHED")
			wrenched = TRUE
			anchored = TRUE
			desc = boarddesc
			boutput(user, "<span class='notice'>You wrench the frame into place.</span>")
		else if (state == "UNWRENCHED")
			wrenched = FALSE
			anchored = FALSE
			desc = basedesc
			boutput(user, "<span class='notice'>You unfasten the frame.</span>")
		else if (state == "BOARDINSTALLED")
			var/obj/item/machineboard/vending/V = target
			vendingtype = V.machinepath
			playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
			icon_state = "standard-frame-electronics"
			desc = wiresdesc
			boutput(user, "<span class='notice'>You install the module inside the frame.</span>")
			user.u_equip(target)
			target.set_loc(target)
			boardinstalled = TRUE
		else if (state == "WIRESINSTALLED")
			var/obj/item/cable_coil/targetcoil = target
			playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
			targetcoil.use(5)
			wiresinstalled = TRUE
			icon_state = "standard-frame-wired"
			desc = glassdesc
			boutput(user, "<span class='notice'>You add cables to the frame.</span>")
		else if (state == "GLASSINSTALLED")
			var/obj/item/sheet/glass/S = target
			playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
			S.change_stack_amount(-2)
			glassed = TRUE
			icon_state = "standard-frame-glassed"
			desc = readydesc
			boutput(user, "<span class='notice'>You put in the glass panel.</span>")
		else if (state == "GLASSREMOVED")
			var/obj/item/sheet/glass/A = new /obj/item/sheet/glass(src.loc)
			A.amount = 2
			glassed = FALSE
			playsound(src.loc, "sound/items/Crowbar.ogg", 50, 1)
			icon_state = "standard-frame-wired"
			desc = glassdesc
			boutput(user, "<span class='notice'>You remove the glass panel.</span>")
		else if (state == "BOARDREMOVED")
			icon_state = "standard-frame"
			desc = boarddesc
			boutput(user, "<span class='notice'>You remove the vending module.</span>")
			var/obj/item/machineboard/vending/E = locate()
			E.set_loc(src.loc)
			boardinstalled = FALSE
		else if (state == "WIRESREMOVED")
			playsound(src.loc, "sound/items/Wirecutter.ogg", 50, 1)
			icon_state = "standard-frame-electronics"
			desc = wiresdesc
			boutput(user, "<span class='notice'>You remove the cables.</span>")
			var/obj/item/cable_coil/C = new /obj/item/cable_coil(src.loc)
			C.amount = 5
			C.updateicon()
			wiresinstalled = FALSE
		else if (state == "DECONSTRUCTED")
			boutput(user, "<span class='notice'>You deconstruct the frame.</span>")
			var/obj/item/sheet/A = new /obj/item/sheet(src.loc)
			A.amount = 3
			if (src.material)
				A.setMaterial(src.material)
			else
				var/datum/material/M = getMaterial("steel")
				A.setMaterial(M)
			qdel(src)
		else
			setFrameState("UNWRENCHED")
			CRASH("Invalid state \"[state]\" set in [src] construction process at [log_loc(src)]")

	attackby(obj/item/target, mob/user)
		if (iswrenchingtool(target))
			if (!wrenched)
				playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
				SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/vendingframe/proc/setFrameState,\
				list("WRENCHED", user), target.icon, target.icon_state, null, null)
			else if (!boardinstalled && wrenched)
				playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
				SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/vendingframe/proc/setFrameState,\
				list("UNWRENCHED", user), target.icon, target.icon_state, null, null)
		else if (istype(target, /obj/item/machineboard/vending))
			if (wrenched && !boardinstalled)
				SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/vendingframe/proc/setFrameState,\
				list("BOARDINSTALLED", user, target), target.icon, target.icon_state, null, null)
		else if (istype(target, /obj/item/cable_coil) && boardinstalled && !wiresinstalled)
			var/obj/item/cable_coil/targetcoil = target
			if (targetcoil.amount >= 5)
				SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/vendingframe/proc/setFrameState,\
				list("WIRESINSTALLED", user, target), target.icon, target.icon_state, null, null)
			else if (!wiresinstalled && boardinstalled)
				boutput(user, "<span class='alert'>You need at least five pieces of cable to wire the vending machine.</span>")
		else if (istype(target, /obj/item/sheet) && wiresinstalled && !glassed)
			var/obj/item/sheet/glass/S = target
			if (!(S.material && S.amount >= 2))
				return
			setFrameState("GLASSINSTALLED", user, target)
		else if (isscrewingtool(target) && glassed)
			boutput(user, "<span class='notice'>You connect the screen.</span>")
			var/obj/machinery/vending/B = new vendingtype(src.loc)
			logTheThing("station", user, null, "assembles [B] [log_loc(B)]")
			qdel(src)
		else if (ispryingtool(target))
			if (glassed)
				setFrameState("GLASSREMOVED", user)
			else if (!wiresinstalled && boardinstalled)
				setFrameState("BOARDREMOVED", user)
		else if (issnippingtool(target) && wiresinstalled && !glassed)
			setFrameState("WIRESREMOVED", user)
		else if (isweldingtool(target) && !wrenched)
			var/obj/item/weldingtool/T = target
			if (T.try_weld(user,0,-1,0,1))
				SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/vendingframe/proc/setFrameState,\
				list("DECONSTRUCTED", user, target), target.icon, target.icon_state, null, null)
		else . = ..()

/obj/machinery/vending/player
	name = "Build-A-Vend" // Thanks Eagletanker
	icon_state = "player"
	desc = "A vending machine offering presumably legal goods sold by other crewmembers."
	pay = 1
	layer = OBJ_LAYER - 0.3
	//Product loading chute
	var/loading = FALSE
	var/unlocked = FALSE
	//Registered owner
	var/owner = null
	//card display name
	var/cardname
	//Bank account
	var/datum/data/record/owneraccount = null
	var/image/crtoverlay = null
	var/image/promoimage = null
	player_list = list()
	has_glow = FALSE

	New()
		. = ..()
		crtoverlay = SafeGetOverlayImage("screen", src.icon, "player-crt")
		crtoverlay.layer = src.layer + 0.2
		crtoverlay.plane = PLANE_DEFAULT
		//These stop the overlay from being selected instead of the item by your mouse?
		crtoverlay.appearance_flags = NO_CLIENT_COLOR
		crtoverlay.mouse_opacity = 0
		updateAppearance()

	proc/pick_product_name()
		var/datum/data/vending_product/player_product/R = pick(src.player_list)
		var/itemPromo = sanitize(html_encode(R.product_name))
		return itemPromo

	proc/generate_slogans()
		if (!length(player_list) <= 0)
			slogan_list = list("By popular demand: [pick_product_name()]!",
		"[src.name]. The better vending machine.",
		"Potentially well stocked!",
		"Buy my stuff!",
		"Don't miss out on [pick_product_name()]!",
		"[src.name]. What else were you going to buy?",
		"New and improved [pick_product_name()]!")

	proc/getScaledIcon(obj/item/target)
		var/image/itemoverlay = null
		itemoverlay = SafeGetOverlayImage(null, target, target.icon_state)
		itemoverlay.transform = matrix(null, 0.45, 0.45, MATRIX_SCALE)
		itemoverlay.pixel_x = -3
		itemoverlay.pixel_y = -4
		itemoverlay.layer = src.layer + 0.1
		itemoverlay.plane = PLANE_DEFAULT
		return itemoverlay

	proc/updateAppearance()
		if (status & BROKEN)
			setCrtOverlayStatus(FALSE)
			setItemOverlay(null)
			return FALSE
		else if (powered())
			setCrtOverlayStatus(TRUE)
			if (promoimage)
				icon_state = "[initial(icon_state)]-display"
				setItemOverlay(promoimage)
			else
				icon_state = initial(icon_state)
		else
			setCrtOverlayStatus(FALSE)
			setItemOverlay(null)
			return FALSE

	proc/setItemOverlay(image/target)
		UpdateOverlays(null, "item", 1, 1)
		UpdateOverlays(target, "item", 0, 1)

	proc/setCrtOverlayStatus(status)
		if (status)
			UpdateOverlays(crtoverlay, "screen", 0, 1)
		else
			UpdateOverlays(null, "screen", 0, 1)

	proc/addProduct(obj/item/target, mob/user)
		var/obj/item/storage/targetContainer = target
		if (!istype(targetContainer))
			productListUpdater(target, user)
			user.visible_message("<b>[user.name]</b> loads [target] into [src].")
			return
		var/action = input(user, "What do you want to do with [targetContainer]?") as null|anything in list("Empty it into the vending machine","Place it in the vending machine")
		var/cantuse
		if (action)
			cantuse = ((isdead(user) || !can_act(user) || !in_interact_range(src, user)))
		if (action == "Place it in the vending machine" && !cantuse)
			productListUpdater(target, user)
			user.visible_message("<b>[user.name]</b> loads [target] into [src].")
			return
		else if (cantuse || !action)
			return
		user.visible_message("<b>[user.name]</b> dumps out [targetContainer] into [src].")
		for (var/obj/item/R in targetContainer)
			targetContainer.hud.remove_object(R)
			productListUpdater(R, user)
		generate_HTML(1, 0)

	proc/productListUpdater(obj/item/target, mob/user)
		if (!target)
			return
		user.u_equip(target)
		target.set_loc(src)
		target.layer = (initial(target.layer))
		var/existed = FALSE
		//Finds items that have been labeled
		var/regex/labelFinder = new("\\*? \\(.*?\\)")
		//Extracts label contents via regex replace
		var/regex/labelExtractor = new("(?:.*?\\()(.*?)\\)")
		var/label = null
		if ((target.real_name != target.name) && labelFinder.Find(target.name))
			label = labelExtractor.Replace(target.name, "$1")
		//Add the item to an existing entry if there is one
		for (var/datum/data/vending_product/player_product/R in src.player_list)
			if (label && label == R.label)
				R.contents += target
				R.product_amount += 1
				existed = TRUE
				break
			else if (istype(target,R.product_type) && R.real_name == target.real_name)
				R.contents += target
				R.product_amount += 1
				existed = TRUE
				break
		if (!existed)
			var/datum/data/vending_product/player_product/itemEntry = new/datum/data/vending_product/player_product(target, 15)
			itemEntry.icon = getScaledIcon(target)
			player_list += itemEntry
			if (label) itemEntry.label = label
			logTheThing("station", user, null, "added player product ([target.name]) to [src] at [log_loc(src)].")
			generate_slogans()

	power_change()
		. = ..()
		updateAppearance()

	process()
		. = ..()
		//Don't update if we're working, always handle that in power_change()
		if ((status & BROKEN) || status & NOPOWER)
			updateAppearance()

	generate_wire_HTML()
		. = ..()
		var/list/html_parts = list()
		html_parts += "<table border=\"1\" style=\"width:100%\"><tbody><tr><td><small>"
		html_parts += "Registered Owner: "
		if (!owner)
			html_parts += "<a href='byond://?src=\ref[src];unlock=true'>Unregistered (locked)</a></br>"
		else
			html_parts += "<a href='byond://?src=\ref[src];unlock=true'>[src.cardname] "
			if (!unlocked) html_parts += "(locked) </a></br>"
			else html_parts += "(unlocked) </a></br>"
		html_parts += "Loading Chute:  "
		if (loading)
			html_parts += "<a href='byond://?src=\ref[src];loading=false'>Open</a></br> "
		else
			html_parts += "<a href='byond://?src=\ref[src];loading=true'>Closed</a></br> "
		html_parts += "Vendor Name:  "
		html_parts += "<a href='byond://?src=\ref[src];rename=true'>[src.name]</a> "
		html_parts += "</small></td></tr></tbody></table></TT><br>"
		src.wire_HTML += jointext(html_parts, "")

	attackby(obj/item/target, mob/user)
		if (loading && panel_open)
			addProduct(target, user)
		else
			. = ..()
		if (!panel_open) //lock up if the service panel is closed
			loading = FALSE
			unlocked = FALSE
		src.generate_HTML(1)

	Topic(href, href_list)
		. = ..()
		if (updateAppearance()) //updateAppearance returns FALSE if we're broken/off
			return
		if ((isdead(usr) || !can_act(usr) || !in_interact_range(src, usr)))
			return

		if (href_list["loading"])
			if (src.panel_open && src.unlocked)
				loading = !loading
				src.generate_HTML(0, 1)
		else if (href_list["unlock"] && src.panel_open)
			if (!owner && src.scan?.registered)
				owneraccount = FindBankAccountById(src.scan.registered_id)
				owner = src.scan.registered
				cardname = src.scan.name
				unlocked = TRUE
				loading = TRUE
			else if (src.scan?.registered && owner == src.scan.registered)
				unlocked = !unlocked
				if (!unlocked && loading) loading = FALSE
			else
				unlocked = FALSE
				loading = FALSE
			src.generate_HTML(0, 1)
		else if (href_list["rename"] && src.panel_open && src.unlocked)
			var/inp
			inp = html_encode(sanitize(input(usr,"Enter new name:","Vendor Name", "") as text))
			if (inp && inp != "" && !(isdead(usr) || !can_act(usr) || !in_interact_range(src, usr)))
				src.name = inp
				src.generate_HTML(0, 1)
				generate_slogans()
		else if (href_list["setprice"] && src.panel_open && src.unlocked)
			var/inp
			inp = input(usr,"Enter the new price:","Item Price", "") as num
			if (inp && inp >= 0 && !(isdead(usr) || !can_act(usr) || !in_interact_range(src, usr)))
				var/datum/data/vending_product/player_product/R = locate(href_list["setprice"]) in src.player_list
				R.product_cost = inp
				src.generate_HTML(1, 0)
		else if (href_list["vend"] && !length(player_list))
			promoimage = null
			updateAppearance()
		else if (href_list["icon"] && src.panel_open && src.unlocked)
			var/datum/data/vending_product/player_product/R = locate(href_list["icon"]) in src.player_list
			promoimage = R.icon
			updateAppearance()
		if (href_list["vend"])
			//Vends can change the name of list entries so generate HTML
			src.generate_HTML(1, 0)

/obj/machinery/vending/player/fallen
	New()
		. = ..()
		src.fall()
//Somewhere out in the vast nothingness of space, a chef (and an admin) is crying.

/obj/machinery/vending/pizza
	name = "pizza vending machine"
	icon_state = "pizza"
	desc = "A vending machine that serves... pizza?"
	var/pizcooking = 0
	var/piztopping = "plain"
	anchored = 0
	acceptcard = 0
	pay = 1
	credit = 100
	slogan_list = list("A revolution in the pizza industry!",
	"Prepared in moments!",
	"I'm a chef who works 24 hours a day!")
	var/sharpen = FALSE

	light_r =1
	light_g = 0.6
	light_b = 0.2

	attackby(obj/item/W, mob/user)
		if (!sharpen && istype(W, /obj/item/kitchen/utensil/knife/pizza_cutter/traitor))
			sharpen = TRUE
			add_fingerprint(user)
			boutput(user, "You jam the pizza sharpener inside the vending machine.")
			user.u_equip(W)
			qdel(W)
			return
		return ..()

	generate_vending_HTML()
		src.vending_HTML = "<TT><B>PizzaVend 0.5b</B></TT><BR>"

		if (src.pizcooking)
			src.vending_HTML += "<TT><B>Cooking your pizza, please wait!</B></TT><BR>"
		else
			src.vending_HTML += "Topping - <A href='byond://?src=\ref[src];picktopping=1'>[piztopping]</A><BR>"
			src.vending_HTML += "<A href='byond://?src=\ref[src];cook=1'>Cook!</A><BR>"

			if (src.pay)
				src.vending_HTML += "<BR><B>Available Credits:</B> [src.emagged ? "CREDIT CALCULATION ERROR" : "$[src.credit]"] <a href='byond://?src=\ref[src];return_credits=1'>Return Credits</A>"
				if (!src.acceptcard)
					src.vending_HTML += "<BR>This machine only takes credit bills."

			src.vending_HTML += "</TT>"

	Topic(href, href_list)
		if(..())
			return

		if (status & (NOPOWER|BROKEN))
			return

		if (usr.contents.Find(src) || in_interact_range(src, usr) && istype(src.loc, /turf))
			src.add_dialog(usr)
			if (href_list["cook"])
				if(!pizcooking)
					if((credit < 50)&&(!emagged))
						boutput(usr, "<span class='alert'>Insufficient funds!</span>") // no money? get out
						return
					if(!emagged)
						credit -= 50
					pizcooking = 1
					icon_state = "pizza-vend"
					src.generate_HTML(1)
					updateUsrDialog()
					sleep(20 SECONDS)
					playsound(src.loc, 'sound/machines/ding.ogg', 50, 1, -1)
					var/obj/item/reagent_containers/food/snacks/pizza/P
					if(emagged)
						P = new /obj/item/reagent_containers/food/snacks/pizza/vendor/pineapple(src.loc)
					else
						switch(piztopping)
							if("plain")
								P = new /obj/item/reagent_containers/food/snacks/pizza/vendor/cheese(src.loc)
							if("meatball")
								P = new /obj/item/reagent_containers/food/snacks/pizza/vendor/meatball(src.loc)
							if("mushroom")
								P = new /obj/item/reagent_containers/food/snacks/pizza/vendor/mushroom(src.loc)
							if("pepperoni")
								P = new /obj/item/reagent_containers/food/snacks/pizza/vendor/pepperoni(src.loc)
					if (src.sharpen)
						var/list/slices = P.make_slices()
						for(var/obj/item/reagent_containers/food/snacks/pizzaslice/slice in slices)
							slice.throw_at(usr, 16, 3)

					if (!(status & (NOPOWER|BROKEN)))
						icon_state = "pizza"

					pizcooking = 0
					src.generate_HTML(1)
			if(href_list["picktopping"])
				switch(piztopping)
					if("plain") piztopping = "meatball"
					if("meatball") piztopping = "mushroom"
					if("mushroom") piztopping = "pepperoni"
					if("pepperoni") piztopping = "plain"
				src.generate_HTML(1)
			add_fingerprint(usr)
			updateUsrDialog()
		return

	spitOut(mob/target)
		// Ah! Spicy!
		if(prob(50))
			random_burn_damage(target, rand(5,15))
		..(target)

	//Mess with people trying to get free pizza
	throw_item(item_name_to_throw)
		var/mob/living/target = locate() in view(7,src)
		if(!target)
			return null

		var/obj/item/reagent_containers/food/snacks/ingredient/pizza_base/P  = new /obj/item/reagent_containers/food/snacks/ingredient/pizza_base(src.loc) //It's raw :)
		P.quality = 0.6
		P.heal_amt = 2

		P.throw_at(target, 16, 3)
		src.visible_message("<span class='alert'><b>[src] launches [P.name] at [target.name]!</b></span>")
		postvend_effect()
		return


/obj/machinery/vending/pizza/fallen
	New()
		. = ..()
		src.fall()

/obj/machinery/vending/monkey
	name = "ValuChimp"
	desc = "More fun than a barrel of monkeys! Monkeys may or may not be synthflesh replicas, may or may not contain partially-hydrogenated banana oil."
	icon_state = "monkey"
	icon_panel = "standard-panel"
	// monkey vendor has slightly special broken/etc sprites so it doesn't just inherit the standard set  :)
	acceptcard = 0
	mats = 0 // >:I
	slogan_list = list("My monkeys are too strong for you, traveler!")
	slogan_chance = 1

	light_r =1
	light_g = 0.88
	light_b = 0.3

	create_products()
		..()
		product_list += new/datum/data/vending_product(/mob/living/carbon/human/npc/monkey, rand(10, 15), logged_on_vend=TRUE)

		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/monkey_translator, rand(1,2), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/banana, rand(1,20), hidden=1)

/obj/machinery/vending/grub //remove this once there's literally any other method of generating grubs
	name = "Grub Hub"
	desc = "There's bugs in this here box!"
	icon_state = "grub"
	icon_panel = "standard-panel"
	// monkey vendor has slightly special broken/etc sprites so it doesn't just inherit the standard set  :)
	acceptcard = 0
	mats = 0 // >:I
	slogan_list = list("Free bug for your de bug!")
	slogan_chance = 1

	light_r =1
	light_g = 0.88
	light_b = 0.3

	create_products()
		..()
		product_list += new/datum/data/vending_product(/mob/living/critter/grub/wildgrub, rand(10, 15), logged_on_vend=TRUE)


/obj/machinery/vending/magivend
	name = "MagiVend"
	desc = "A magic vending machine."
	icon_state = "wiz"
	icon_panel = "standard-panel"
	acceptcard = 0
	slogan_list = list("Sling spells the proper way with MagiVend!",
	"Be your own Houdini! Use MagiVend!")

	vend_delay = 15
	vend_reply = "Have an enchanted evening!"

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/wizard, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wizrobe, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/sandal, 1)
		product_list += new/datum/data/vending_product(/obj/item/staff, 2)

		product_list += new/datum/data/vending_product(/obj/item/clothing/head/wizard/red, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wizrobe/red, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/wizard/purple, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wizrobe/purple, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/wizard/green, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wizrobe/green, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/wizard/witch, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/wizard/necro, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wizrobe/necro, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/staff/crystal, 1)

/obj/machinery/vending/standard
	desc = "A standard vending machine."
	icon_state = "standard"
	icon_panel = "standard-panel"
	acceptcard = 0
	slogan_list = list("Please make your selection.")

	light_r =1
	light_g = 0.81
	light_b = 0.81

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/device/prox_sensor, 8)
		product_list += new/datum/data/vending_product(/obj/item/device/igniter, 8)
		product_list += new/datum/data/vending_product(/obj/item/device/radio/signaler, 8)
		product_list += new/datum/data/vending_product(/obj/item/wirecutters, 1)
		product_list += new/datum/data/vending_product(/obj/item/device/timer, 8)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/atmosanalyzer_upgrade, 3)
		product_list += new/datum/data/vending_product(/obj/item/pressure_crystal, 5)
		product_list += new/datum/data/vending_product(/obj/item/device/pressure_sensor, 2)

		product_list += new/datum/data/vending_product(/obj/item/device/light/flashlight, rand(1, 6), hidden=1)
		//product_list += new/datum/data/vending_product(/obj/item/device/timer, rand(1, 6), hidden=1)



/obj/machinery/vending/hydroponics
	name = "GardenGear"
	desc = "A vendor for Hydroponics related equipment."
	icon_state = "gardengear"
	icon_panel = "standard-panel"
	icon_off = "gardengear-off"
	icon_broken = "gardengear-broken"
	icon_fallen = "gardengear-fallen"
	acceptcard = 0

	light_r =0.5
	light_g = 1
	light_b = 0.2

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/wateringcan, 5)
		product_list += new/datum/data/vending_product(/obj/item/plantanalyzer, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/compostbag, 5)
		product_list += new/datum/data/vending_product(/obj/item/saw, 3)
		product_list += new/datum/data/vending_product(/obj/item/gardentrowel, 5)
		product_list += new/datum/data/vending_product(/obj/item/satchel/hydro, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/beaker, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/weedkiller, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/mutriant, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/groboost, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/topcrop, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/powerplant, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/fruitful, 5)
		product_list += new/datum/data/vending_product(/obj/decorative_pot, 5)
		product_list += new/datum/data/vending_product(/obj/item/fishing_rod, 3)

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/water_pipe, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/seedplanter/hidden, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/seed/grass, rand(3, 6), hidden=1)
		if (prob(25))
			product_list += new/datum/data/vending_product(/obj/item/seed/alien, 1, hidden=1)

/obj/machinery/vending/hydroponics/mean_solarium_bullshit
	mechanics_type_override = /obj/machinery/vending/hydroponics
	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/device/key/cheget,1, 954, 1)

/obj/machinery/vending/fortune
#ifdef HALLOWEEN
	name = "Necromancer Zoldorf"
	icon_state = "hfortuneteller"
	icon_vend = "hfortuneteller-vend"
	pay = 1
	acceptcard = 1
	slogan_list = list("Ha ha ha ha ha!",
	"I am the great wizard Zoldorf!",
	"Learn your fate!")
	var/sound_riff = 'sound/machines/fortune_riff.ogg'
	var/sound_riff_broken = 'sound/machines/fortune_riff_broken.ogg'
	var/sound_greeting = 'sound/machines/fortune_greeting.ogg'
	var/sound_greeting_broken = 'sound/machines/fortune_greeting_broken.ogg'
	var/sound_laugh = 'sound/machines/fortune_laugh.ogg'
	var/sound_laugh_broken = 'sound/machines/fortune_laugh_broken.ogg'
	var/sound_ding = 'sound/machines/ding.ogg'
	var/list/sounds_working = list('sound/misc/automaton_scratch.ogg','sound/machines/mixer.ogg')
	var/list/sounds_broken = list('sound/machines/glitch1.ogg','sound/machines/glitch2.ogg','sound/machines/glitch3.ogg','sound/machines/glitch4.ogg','sound/machines/glitch5.ogg')

	light_r =0.3
	light_g = 0.3
	light_b = 1
	has_glow = FALSE
#else
	name = "Zoldorf"
	desc = "A horrid old fortune-telling machine."
	icon_state = "fortuneteller"
	icon_vend = "fortuneteller-vend"
	pay = 1
	acceptcard = 1
	slogan_list = list("Ha ha ha ha ha!",
	"I am the great wizard Zoldorf!",
	"Learn your fate!")
	var/sound_riff = 'sound/machines/fortune_riff.ogg'
	var/sound_riff_broken = 'sound/machines/fortune_riff_broken.ogg'
	var/sound_greeting = 'sound/machines/fortune_greeting.ogg'
	var/sound_greeting_broken = 'sound/machines/fortune_greeting_broken.ogg'
	var/sound_laugh = 'sound/machines/fortune_laugh.ogg'
	var/sound_laugh_broken = 'sound/machines/fortune_laugh_broken.ogg'
	var/sound_ding = 'sound/machines/ding.ogg'
	var/list/sounds_working = list('sound/misc/automaton_scratch.ogg','sound/machines/mixer.ogg')
	var/list/sounds_broken = list('sound/machines/glitch1.ogg','sound/machines/glitch2.ogg','sound/machines/glitch3.ogg','sound/machines/glitch4.ogg','sound/machines/glitch5.ogg')

	light_r =0.3
	light_g = 0.3
	light_b = 1
	has_glow = FALSE
#endif
	New()
		..()
		light.set_color(0.8, 0.4, 1)

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/paper/thermal/fortune, 25, cost=PAY_UNTRAINED/10)
		product_list += new/datum/data/vending_product(/obj/item/card_box/tarot, 5, cost=PAY_UNTRAINED/2)
		product_list += new/datum/data/vending_product(/obj/item/zolscroll, 100, cost=PAY_UNTRAINED, hidden=1) //weird burrito

	prevend_effect()
		if(src.seconds_electrified || src.extended_inventory)
			src.visible_message("<span class='notice'>[src] wakes up!</span>")
			playsound(src.loc, sound_riff_broken, 60, 1)
			sleep(2 SECONDS)
			playsound(src.loc, sound_greeting_broken, 65, 1)
			if (src.icon_vend)
				flick(src.icon_vend,src)
			speak("F*!@$*(9HZZZZ9**###!")
			sleep(2.5 SECONDS)
			src.visible_message("<span class='notice'>[src] spasms violently!</span>")
			playsound(src.loc, pick(sounds_broken), 40, 1)
			if (src.icon_vend)
				flick(src.icon_vend,src)
			sleep(1 SECOND)
			src.visible_message("<span class='notice'>[src] makes an obscene gesture!</b></span>")
			playsound(src.loc, pick(sounds_broken), 40, 1)
			if (src.icon_vend)
				flick(src.icon_vend,src)
			sleep(1.5 SECONDS)
			playsound(src.loc, sound_laugh_broken, 65, 1)
			speak("AHHH#######!")

		else
			src.visible_message("<span class='notice'>[src] wakes up!</span>")
			playsound(src.loc, sound_riff, 60, 1)
			sleep(2 SECONDS)
			playsound(src.loc, sound_greeting, 65, 1)
			if (src.icon_vend)
				flick(src.icon_vend,src)
			speak("The great wizard Zoldorf is here!")
			sleep(2.5 SECONDS)
			src.visible_message("<span class='notice'>[src] rocks back and forth!</span>")
			playsound(src.loc, pick(sounds_working), 40, 1)
			if (src.icon_vend)
				flick(src.icon_vend,src)
			sleep(1 SECOND)
			src.visible_message("<span class='notice'>[src] makes a mystical gesture!</b></span>")
			playsound(src.loc, pick(sounds_working), 40, 1)
			if (src.icon_vend)
				flick(src.icon_vend,src)
			sleep(1.5 SECONDS)
			playsound(src.loc, sound_laugh, 65, 1)
			speak("Ha ha ha ha ha!")

		return

	postvend_effect()
		playsound(src.loc, sound_ding, 50, 1)
		return

	fall(mob/living/carbon/victim)
		playsound(src.loc, sound_laugh, 65, 1)
		speak("Ha ha ha ha ha!")
		..()
		return

	shock(mob/user, prb)
		// Zap the fuck out of the user but don't prevent them from vending, because
		// fucked up Zoldorf is good and I miss seeing it.
		..()
		return 0

	electrocute(mob/user, netnum)
		..()
		playsound(src.loc, sound_laugh, 65, 1)
		speak("Ha ha ha ha ha!")
		return

	attackby(obj/item/weapon as obj, mob/user as mob) //pretty much just player zoldorf stuffs :)
		if((istype(weapon, /obj/item/zolscroll)) && istype(user,/mob/living/carbon/human) && (src.z == 1))
			var/obj/item/zolscroll/scroll = weapon
			var/mob/living/carbon/human/h = user
			if(h.unkillable)
				boutput(user,"<span class='alert'><b>Your soul is shielded and cannot be sold!</b></span>")
				return
			if(scroll.icon_state != "signed")
				boutput(h, "<span class='alert'>It doesn't seem to be signed yet.</span>")
				return
			if(scroll.signer == h.real_name)
				var/obj/machinery/playerzoldorf/pz = new /obj/machinery/playerzoldorf
				pz.credits = src.credit
				if(the_zoldorf.len)
					if(the_zoldorf[1].homebooth)
						//var/obj/booth = the_zoldorf[1].homebooth
						boutput(h, "<span class='alert'><b>There can only be one!</b></span>") // Maybe add a way to point where the booth is if people are being jerks
					else
						pz.booth(h,src.loc,scroll)
						qdel(src)
				else
					pz.booth(h,src.loc,scroll)
					qdel(src)
			else
				user.visible_message("<span class='alert'><b>[h.name] tries to sell [scroll.signer]'s soul to [src]! How dare they...</b></span>","<span class='alert'><b>You can only sell your own soul!</b></span>")
		else
			..()

/obj/machinery/vending/alcohol
	name = "Cap'n Bubs' Booze-O-Mat"
	desc = "A vending machine filled with various kinds of alcoholic beverages and things for fancying up drinks."
	pay = 1
	icon_state = "capnbubs"
	icon_panel = "capnbubs-panel"
	slogan_list = list("hm hm",
	"Liquor - get it in ya!",
	"I am the liquor",
	"I don't always drink, but when I do, I sell the rights to my likeness")

	light_r =1
	light_g = 0.3
	light_b = 0.95

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/beer, 6)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/fancy_beer, 6)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/vodka, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/tequila, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/wine, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/cider, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/mead, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/gin, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/rum, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/champagne, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/bojackson, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/box/cocktail_umbrellas, 4)
		product_list += new/datum/data/vending_product(/obj/item/storage/box/cocktail_doodads, 4)
		product_list += new/datum/data/vending_product(/obj/item/storage/box/fruit_wedges, 1)
		product_list += new/datum/data/vending_product(/obj/item/shaker/salt, 1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/cocktailshaker, 1)
		product_list += new/datum/data/vending_product(/obj/item/item_box/starwipes, 1)

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/hobo_wine, 2, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/thegoodstuff, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/stackable_ammo/shotgun/slug_rubber/five, 3, cost=PAY_TRADESMAN, hidden=1)

/obj/machinery/vending/chem
	name = "ChemDepot"
	desc = "Some odd machine that dispenses little vials and packets of chemicals for exorbitant amounts of money. Is this thing even working right?"
	icon_state = "chem"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	glitchy_slogans = 1
	pay = 1
	acceptcard = 1
	slogan_list = list("Hello!",
	"Please state the item you wish to purchase.",
	"Many goods at reasonable prices.",
	"Please step right up!",
	"Greetings!",
	"Thank you for your interest in VENDOR NAME's goods!")

	light_r =1
	light_g = 0.3
	light_b = 0.95

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vending/vial/random, 1, cost = rand(1000, 10000))
		var/lock1 = rand(1, 9)
		for (var/i = 0, i < lock1, i++) // this entire thing is just random luck
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vending/vial/random, 1, cost = rand(1000, 10000))

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vending/bag/random, 1, cost = rand(1000, 10000))
		var/lock2 = rand(1, 9)
		for (var/i = 0, i < lock2, i++) // so we'll add a random amount to each machine
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vending/bag/random, 1, cost = rand(1000, 10000))

		product_list += new/datum/data/vending_product(/obj/item/cigpacket/random, 1, cost = rand(1000, 10000), hidden=1)
		var/lock3 = rand(1, 9)
		for (var/i = 0, i < lock3, i++)
			product_list += new/datum/data/vending_product(/obj/item/cigpacket/random, 1, cost = rand(1000, 10000), hidden=1)

/obj/machinery/vending/cards
	name = "gaming machine"
	desc = "A machine that sells various kinds of recreational items, notably Spacemen the Grifening trading cards and dice!"
	pay = 1
	vend_delay = 10
	icon_state = "card"
	icon_panel = "card-panel"

	light_r =1
	light_g = 0.4
	light_b = 0.7

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/paper/yachtdice, 20, cost=PAY_UNTRAINED/8)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/grifening, 10, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/stg_box, 5, cost=PAY_UNTRAINED/2)
		product_list += new/datum/data/vending_product(/obj/item/stg_booster, 20, cost=PAY_UNTRAINED/10)
		product_list += new/datum/data/vending_product(/obj/item/card_box/plain, 10, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/card_box/tarot, 5, cost=PAY_UNTRAINED/3)
		product_list += new/datum/data/vending_product(/obj/item/card_box/hanafuda, 5, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/card_box, 5, cost=PAY_UNTRAINED/4)
		product_list += new/datum/data/vending_product(/obj/item/card_box/red, 5, cost=PAY_UNTRAINED/4)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/DNDrulebook, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/monster_manual_revised, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/diceholder/dicebox, 5, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/storage/dicepouch, 5, cost=PAY_TRADESMAN/3)
		product_list += new/datum/data/vending_product(/obj/item/diceholder/dicecup, 5, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/goboard, 1, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/gobowl/b, 1, cost=PAY_TRADESMAN/4)
		product_list += new/datum/data/vending_product(/obj/item/gobowl/w, 1, cost=PAY_TRADESMAN/4)
		product_list += new/datum/data/vending_product(/obj/item/card_box/clow, 5, cost=PAY_TRADESMAN/2) // (this is an anime joke)
		product_list += new/datum/data/vending_product(/obj/item/clow_key, 5, cost=PAY_TRADESMAN/2)      //      (please laugh)
		product_list += new/datum/data/vending_product(/obj/item/dice/weighted, rand(1,3), cost=PAY_TRADESMAN/2, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/dice/d1, rand(0,1), cost=PAY_TRADESMAN/3, hidden=1)

/obj/machinery/vending/clothing
	name = "FancyPantsCo Sew-O-Matic"
	desc = "A clothing vendor."
	icon_state = "clothes"
	icon_vend = "clothes-vend"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	pay = 1
	acceptcard = 1
	vend_delay = 20
	has_glow = FALSE
	slogan_list = list("Look snappy in seconds!",
	"Style over substance.")

	prevend_effect()
		playsound(src.loc, "sound/machines/mixer.ogg", 50, 1)
		return

	postvend_effect()
		playsound(src.loc, "sound/machines/ding.ogg", 50, 1)
		return

	create_products()
		..()
		//for (var/j in typesof(/obj/item/clothing/under/color)) // alla dem
			//product_list += new/datum/data/vending_product([j], 5, cost=50)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/yoga, 5, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/yoga/red, 5, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/dress, 5, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/dress/red, 5, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/dress/hawaiian, 5, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/heels/black, 5, cost=PAY_DOCTORATE/5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/heels/red, 5, cost=PAY_DOCTORATE/5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/poncho, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/lshirt, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/tan, 2, cost=PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/maroon, 2, cost=PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/magenta, 2, cost=PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/mint, 2, cost=PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/cerulean, 2, cost=PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/navy, 2, cost=PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/indigo, 2, cost=PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/grey, 2, cost=PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/dressb, 2, cost=PAY_DOCTORATE/2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/sunhat, 2, cost=PAY_DOCTORATE/5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headband/nyan/white, 3, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headband/nyan/gray, 3, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headband/nyan/black, 3, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headband/nyan/red, 3, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headband/nyan/orange, 3, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headband/nyan/yellow, 3, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headband/nyan/green, 3, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headband/nyan/blue, 3, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headband/nyan/purple, 3, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/pokervisor, 3, cost = PAY_TRADESMAN/5)


		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/yoga/communist, 1, cost=PAY_TRADESMAN/5, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/rando, 1, cost=PAY_TRADESMAN/3, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/gimmick/wedding_dress, 1, cost=PAY_IMPORTANT*4, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/veil, 1, PAY_IMPORTANT, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/heels, 1, PAY_DOCTORATE/5, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/tuxedo_jacket, 1, cost=PAY_IMPORTANT, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/bartender/tuxedo, 1, cost=PAY_IMPORTANT/5, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/dress_shoes, 1, cost=PAY_IMPORTANT/5, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/ring/gold, 2, cost=PAY_IMPORTANT, hidden=1)

/obj/machinery/vending/janitor
	name = "JaniTech Vendor"
	desc = "One stop shop for all your custodial needs."
	icon_state = "janitor"
	icon_panel = "standard-panel"
	icon_off = "janitor-off"
	icon_broken = "janitor-broken"
	icon_fallen = "janitor-fallen"
	pay = 1
	acceptcard = 1
	mats = 10
	window_size = "400x475"

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/mop, 5)
		product_list += new/datum/data/vending_product(/obj/item/sponge, 4)
		product_list += new/datum/data/vending_product(/obj/item/spraybottle/cleaner, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bucket, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/cleaner, 4)
		product_list += new/datum/data/vending_product(/obj/item/chem_grenade/cleaner, 6)
		product_list += new/datum/data/vending_product(/obj/item/storage/box/trash_bags, 8)
		product_list += new/datum/data/vending_product(/obj/item/storage/box/biohazard_bags, 8)
		product_list += new/datum/data/vending_product(/obj/item/storage/box/body_bag, 2)
		product_list += new/datum/data/vending_product(/obj/item/storage/box/mousetraps, 4)
		product_list += new/datum/data/vending_product(/obj/item/caution, 10)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/long, 2)

		product_list += new/datum/data/vending_product(/obj/item/sponge/cheese, 2, hidden=1)

/obj/machinery/vending/air_vendor
	name = "Oxygen Vending Machine"
	desc = "Here, you can buy the oxygen that you need to live."
	icon_state = "O2vend"
	icon_panel = "O2vend-panel"
	icon_off = "O2vend-off"
	icon_broken = "O2vend-broken"
	icon_fallen = "O2vend-fallen"
	deconstruct_flags = DECON_CROWBAR | DECON_WRENCH | DECON_MULTITOOL
	can_hack = FALSE
	pay = TRUE
	acceptcard = TRUE
	vend_delay = 0
	slogan_list = list("Come get a breath of fresh air",
	"You NEED this to live!.",
	"Breathing is GOOD!",
	"Contains only 2% farts!")
	var/global/image/holding_overlay_image = image('icons/obj/machines/vending.dmi', "O2vend-slot")

	// Currently installed tank
	var/obj/item/tank/holding = null

	// Gas mix to be copied into the target tank
	var/datum/gas_mixture/gas_prototype = null

	var/target_pressure = ONE_ATMOSPHERE
	var/air_cost = 0.1 // units: credits / ( kPa * L )

	light_r =0.4
	light_g = 0.4
	light_b = 1

	New()
		..()
		gas_prototype = new()

	proc/fill_cost()
		if(!holding) return 0
		return clamp(round((src.target_pressure - MIXTURE_PRESSURE(src.holding.air_contents)) * src.holding.air_contents.volume * src.air_cost), 0, INFINITY)

	proc/fill()
		if(!holding) return
		gas_prototype.volume = holding.air_contents.volume
		gas_prototype.temperature = T20C

		gas_prototype.oxygen = (target_pressure)*gas_prototype.volume/(R_IDEAL_GAS_EQUATION*gas_prototype.temperature)

		holding.air_contents.copy_from(gas_prototype)

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/tank))
			if (!src.holding)
				boutput(user, "You insert the [W] into the the [src].</span>")
				UpdateOverlays(holding_overlay_image, "o2_vend_tank_overlay")
				user.drop_item()
				W.set_loc(src)
				src.holding = W
				src.updateUsrDialog()
			else
				boutput(user, "You try to insert the [W] into the the [src], but there's already a tank there!</span>")
				return
		else
			..()

	attack_hand(mob/user as mob)
		if (status & (BROKEN|NOPOWER))
			return
		if (usr.stat || usr.restrained())
			return

		src.add_dialog(user)
		var/html = ""
		html += "<TT><b>Welcome!</b><br>"
		html += "<b>Current balance: <a href='byond://?src=\ref[src];return_credits=1'>[src.credit] credits</a></b><br>"
		if (src.scan)
			var/datum/data/record/account = null
			account = FindBankAccountById(src.scan.registered_id)
			html += "<b>Current ID:</b> <a href='byond://?src=\ref[src];logout=1'>[src.scan]</a><br />"
			html += "<b>Credits on Account: [account.fields["current_money"]] Credits</b> <br>"
		else
			html += "<b>Current ID:</b> None<br>"
		if(src.holding)
			html += "<font color = 'blue'>Current tank:</font> <a href='byond://?src=\ref[src];eject=1'>[holding]</a><br />"
			html += "<font color = 'red'>Pressure:</font> [MIXTURE_PRESSURE(holding.air_contents)] kPa<br />"
		else
			html += "<font color = 'blue'>Current tank:</font> none<br />"

		html += "<font color = 'green'>Desired pressure:</font> <a href='byond://?src=\ref[src];changepressure=1'>[src.target_pressure] kPa</a><br/>"
		html += (holding) ? "<a href='byond://?src=\ref[src];fill=1'>Fill ([src.fill_cost()] credits)</a>" : "<font color = 'red'>Fill (unavailable)</red>"

		user.Browse(html, "window=o2_vending")
		onclose(user, "vending")

	Topic(href, href_list)
		..()

		if(href_list["eject"])
			if(holding)
				usr.put_in_hand_or_eject(holding)
				holding = null
				UpdateOverlays(null, "o2_vend_tank_overlay")
				src.updateUsrDialog()

		if(href_list["changepressure"])
			var/change = input(usr,"Target Pressure (10.1325-1013.25):","Enter target pressure",target_pressure) as num
			if(isnum(change))
				target_pressure = min(max(10.1325, change),1013.25)
				src.updateUsrDialog()

		if(href_list["fill"])
			if (holding)
				var/cost = fill_cost()
				if(credit >= cost)
					src.credit -= cost
					src.fill()
					boutput(usr, "<span class='notice'>You fill up the [src.holding].</span>")
					src.updateUsrDialog()
					return
				else if(scan)
					var/datum/data/record/account = FindBankAccountById(src.scan.registered_id)
					if (account && account.fields["current_money"] >= cost)
						account.fields["current_money"] -= cost
						src.fill()
						boutput(usr, "<span class='notice'>You fill up the [src.holding].</span>")
						src.updateUsrDialog()
						return
				boutput(usr, "<span class='alert'>Insufficient funds.</span>")
			else
				boutput(usr, "<span class='alert'>There is no tank to fill up!</span>")


//Let me add some garbage
/obj/machinery/vending/juice
	name = "\improper JuiceSluice 10000"
	desc = "Surprisingly, unrelated to Juicerdom."
	icon_state = "juice"
	//I know these don't match I can't be arsed right this moment
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	deconstruct_flags = DECON_CROWBAR | DECON_WRENCH | DECON_MULTITOOL
	can_hack = FALSE
	pay = TRUE
	acceptcard = TRUE
	vend_delay = 0
	slogan_list = list("JUICE! JUICE! JUICE!",
	"Quench thine thirst!",
	"Get your daily deluge going!",
	"Not the worst you've ever tasted!")
	var/reagent_id

	//var/reservoir = 10000 //units

	var/target_deluge = 100 //units

	var/cost_per_unit = 1 //in credittes

	light_r =0.4
	light_g = 0.4
	light_b = 1

	New()
		..()
		if (!reagent_id)
			reagent_id = pick("juice_lime", "juice_lemon", "juice_orange","juice_cran", "juice_cherry", "juice_pineapple", "juice_tomato")
			reagents = new(10000)
			reagents.add_reagent(reagent_id, reagents.maximum_volume)
			cost_per_unit = rand(1,5)

	proc/fill() //for a sense of the word :)
		var/turf/T = get_turf(src)
		reagents.reaction(T, TOUCH, target_deluge)
		//reservoir -= target_deluge
		target_deluge = clamp(target_deluge, 0, reagents.total_volume)

	attack_hand(mob/user as mob)
		if (status & (BROKEN|NOPOWER))
			return
		if (usr.stat || usr.restrained())
			return

		src.add_dialog(user)
		var/html = ""
		html += "<TT><b>Welcome to the sluice!<i> BUY SOME JUICE!</i></b><br>"
		//credits
		html += "<b>Current balance: <a href='byond://?src=\ref[src];return_credits=1'>[src.credit] credits</a></b><br>"
		//bank balance
		if (src.scan)
			var/datum/data/record/account = null
			account = FindBankAccountById(src.scan.registered_id)
			html += "<b>Current ID:</b> <a href='byond://?src=\ref[src];logout=1'>[src.scan]</a><br />"
			html += "<b>Credits on Account: [account.fields["current_money"]] Credits</b> <br>"
		else
			html += "<b>Current ID:</b> None<br>"

		//reservoir
		html += "We have <font color = 'blue'><b>[reagents.total_volume]</b></font> units of <font color = 'blue'><b>[reagents.get_master_reagent_name()]</b></font> available for <br><font color = 'blue'><b>[cost_per_unit] [cost_per_unit == 1 ? "credit" : "credits"]</b></font> per unit!!<br /><br>"

		html += "<font color = 'red'>\"Gimme <a href='byond://?src=\ref[src];adjust_target=1'>[target_deluge] units</a> of that juice, my friend.\"</font><br>"
		html += "<a href='byond://?src=\ref[src];JUICE=1'>OPEN THE SLUICE ([cost_per_unit * target_deluge] credits)</a>"

		user.Browse(html, "window=juice_vending")
		onclose(user, "vending")

	Topic(href, href_list)
		..()


		if(href_list["adjust_target"])
			var/change = input(usr,"Target Amount:","Enter thirst",target_deluge) as num
			if(isnum(change))
				target_deluge = clamp(change, 0, reagents.total_volume)
				src.updateUsrDialog()

		if(href_list["JUICE"]) //open the floodgates
			var/cost = cost_per_unit * target_deluge
			if(credit >= cost)
				src.credit -= cost
				src.fill()
				boutput(usr, "<span class='notice'>Thank you for your purchase.</span>")
				src.updateUsrDialog()
				return
			else if(scan)
				var/datum/data/record/account = FindBankAccountById(src.scan.registered_id)
				if (account && account.fields["current_money"] >= cost)
					account.fields["current_money"] -= cost
					src.fill()
					boutput(usr, "<span class='notice'>Thank you for your purchase.</span>")
					src.updateUsrDialog()
					return
			boutput(usr, "<span class='alert'>Insufficient funds.</span>")


/obj/machinery/vending/standard/toxins
	desc = "A vending machine machine full of various useful tools and devices that plasma researchers can use to make bombs."
	icon_state = "toxins"

	create_products(restocked)
		product_list += new/datum/data/vending_product(/obj/item/device/prox_sensor, 10)
		product_list += new/datum/data/vending_product(/obj/item/device/igniter, 10)
		product_list += new/datum/data/vending_product(/obj/item/device/radio/signaler, 10)
		product_list += new/datum/data/vending_product(/obj/item/wirecutters, 1)
		product_list += new/datum/data/vending_product(/obj/item/device/timer, 10)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/atmospheric, 2)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/atmosanalyzer_upgrade, 3)
		product_list += new/datum/data/vending_product(/obj/item/pressure_crystal, 8)
		product_list += new/datum/data/vending_product(/obj/item/device/pressure_sensor, 2)


/datum/action/bar/icon/shoveMobIntoVendomat
	duration = 0.2 SECONDS
	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_ACT
	id = "shoveMobIntoVendomat"
	var/obj/machinery/vending/omat
	var/mob/user
	var/mob/target

	New(var/obj/machinery/vending/omat, var/mob/target, var/mob/user)
		..()
		src.omat   = omat
		src.user   = user
		src.target = target


	onStart()
		..()
		if(!checkStillValid()) return

	onUpdate()
		..()
		if(!checkStillValid()) return

	onEnd()
		if(checkStillValid())
			if(target.buckled || get_dist(user, omat) > 1 || get_dist(user, target) > 1 || ((is_incapacitated(user) && user != target)))
				..()
				return

		var/msg
		if(target == user)
			msg = "[user.name] wriggles their way into the [omat]."
			boutput(user, "You wriggle your way into the [omat].")
		else if(target != user && !user.restrained())
			msg = "[user.name] stuffs [target.name] into the [omat]!"
			boutput(user, "You stuff [target.name] into the [omat]!")
			logTheThing("combat", user, target, "places [constructTarget(target, "combat")] into [omat] at [log_loc(omat)].")
		else
			..()
			return

		actions.interrupt(target, INTERRUPT_MOVE)
		target.set_loc(omat)

		if(msg)
			omat.visible_message(msg)

		..()
		SPAWN_DBG(5 SECONDS) omat.spitOut(target)

	onDelete()
		..()

	proc/checkStillValid()
		if(isnull(user) || isnull(target) || isnull(omat))
			interrupt(INTERRUPT_ALWAYS)
			return false
		return true



/obj/machinery/vending/sause // todo: make it slather sauce on stuff instead of selling loose sauce but this is funny anyway.
	name = "sause"
	desc = "looks normal."
	icon_state = "sauce"
	icon_panel = "standard-panel"
	icon_off = "monkey-off"
	icon_broken = "monkey-broken"
	icon_fallen = "monkey-fallen"
	pay = 1
	acceptcard = 0
	slogan_list = list("<span style=\"font-family:'Comic Sans MS', sans-serif; \">for they <span style=\"color:#0F0;\">HIGH ROLLERS</span> out there...... </span>",
	"<span style=\"font-family:'Comic Sans MS', sans-serif; \">get it on their. </span>",
	"<span style=\"font-family:'Comic Sans MS', sans-serif; color: yellow; \">exclusive, premiume <span style=\"color:brown;\">GOURMéT BARBEBEQUE SAUCE.</span></span>",
	"<span style=\"font-family:'Comic Sans MS', sans-serif; color:gold; \">CHRIST</span>",
	"<span style=\"font-family:'Comic Sans MS', sans-serif; \">INGREGIENTS: it`s is, 100% <span style=\"color:gold;\">SAUSCE!!</span></span>",
	"<span style=\"font-family:'Comic Sans MS', sans-serif; \">Cash Only.</span>")

	light_r = 0.9
	light_g = 0.6
	light_b = 0.1

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/ketchup, 5, cost=PAY_UNTRAINED/9)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/mayo, 5, cost=PAY_UNTRAINED/9)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/hotsauce, 5, cost=PAY_UNTRAINED/6)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/coldsauce, 5, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/cream, 5, cost=PAY_UNTRAINED/7)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/custard, 5, cost=PAY_UNTRAINED/7)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/butters, 5, cost=PAY_UNTRAINED/4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/syrup, 5, cost=PAY_UNTRAINED/4)
		product_list += new/datum/data/vending_product(/obj/item/shaker/mustard, 5, cost=PAY_UNTRAINED/3)
		product_list += new/datum/data/vending_product(/obj/item/shaker/ketchup, 5, cost=PAY_UNTRAINED/3)

/obj/machinery/vending/meat //MEAT VENDING MACHINE
	name = "Meat4cash"
	desc = "An exotic meat vendor."
	icon_state = "steak"
	icon_panel = "standard-panel"
	icon_off = "monkey-off"
	icon_broken = "monkey-broken"
	icon_fallen = "monkey-fallen"
	pay = 1
	acceptcard = 0
	slogan_list = list("It's meat you can buy!",
	"Trade your money for meat!",
	"Buy the meat! It's meat!",
	"Why not buy the meat?",
	"Please, please buy meat.")

	light_r = 0.9
	light_g = 0.1
	light_b = 0.1

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat, 10, cost=PAY_UNTRAINED/4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat, 10, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat, 20, cost=PAY_UNTRAINED/6)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/meatball, 5, cost=PAY_UNTRAINED/6)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meatpaste, 5, cost=PAY_UNTRAINED/7)

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat, 2, cost=PAY_UNTRAINED, hidden=1)


