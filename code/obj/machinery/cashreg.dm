/obj/machinery/cashreg
	name = "credit transfer device"
	desc = "Sends funds directly to a host ID."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "scanner"
	anchored = 1
	mats = 6
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_MULTITOOL
	var/datum/data/record/mainaccount = null
	var/datum/data/record/servicechgaccount = null

	var/receipt_count = 20 // Todo: ...new printer rolls for receipts?
	var/min_serv_chg  = 5
	var/serv_chg_pct  = 0.02 // Percentage for service charge. 0.02 == 2%

	New()
		..()
		UnsubscribeProcess()
		if(!servicechgaccount)
			servicechgaccount = wagesystem.finserv_budget

	proc/PrintReceipt(var/datum/data/record/accountTo, var/datum/data/record/accountFrom, amount, serv_chg_amount)
		//
		var/receiptText = "<b>Payment Receipt</b><br>"

		receiptText += "<b>[accountTo.fields["name"]]</b>: [amount]<br>"
		receiptText += "<b>Service Charge</b>: [serv_chg_amount]<br>"
		receiptText += "<hr>"
		receiptText += "<b>Total</b> (deducted from [accountFrom.fields["name"]]): [amount + serv_chg_amount]"

		playsound(src.loc, "sound/machines/printer_dotmatrix.ogg", 50, 1)
		SPAWN_DBG(3.2 SECONDS)
			var/obj/item/paper/P = new()
			P.set_loc(src.loc)
			P.name = "paper- 'Receipt'"
			P.info = receiptText

		receipt_count--

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/device/pda2) && W:ID_card)
			W = W:ID_card
		if(istool(W, TOOL_SCREWING | TOOL_WRENCHING))
			user.visible_message("<b>[user]</b> [anchored ? "unbolts the [src] from" : "secures the [src] to"] the floor.")
			playsound(src.loc, "sound/items/Screwdriver.ogg", 80, 1)
			src.anchored = !src.anchored
		if (istype(W, /obj/item/card/id))
			var/obj/item/card/id/card = W
			if (!mainaccount)
				for (var/datum/data/record/account in data_core.bank)
					if (ckey(account.fields["id"]) == ckey(card.registered_id))
						mainaccount = account
						boutput(user, "<span class='notice'>Payments will be paid to [card.registered].</span>")
						break

				if (!istype(mainaccount))
					mainaccount = null
					boutput(user, "<span class='alert'>Unable to find bank account!</span>")
					return

				user.visible_message("<span class='notice'>[user] configures [src] with [W].</span>")
				return

			if (!servicechgaccount) // For sneaky embezzlement reasons
				for(var/datum/data/record/account in data_core.bank)
					if(ckey(account.fields["id"]) == ckey(card.registered_id))
						servicechgaccount = account
						break
				if(!istype(servicechgaccount))
					servicechgaccount = null
					boutput(user, "<span class='alert'>Configuration failure</span>")
					return

				user.visible_message("<span class='notice'>[user] configures [src] with [W].</span>")
				return

			if (card.registered_id in FrozenAccounts)
				boutput(user, "<span class='alert'>Your account cannot currently be liquidated due to active borrows.</span>")
				return
			var/datum/data/record/target_account = null
			for (var/datum/data/record/account in data_core.bank)
				if (ckey(account.fields["id"]) == ckey(card.registered_id))
					target_account = account
					break
			if (!istype(target_account))
				boutput(user, "<span class='alert'>Unable to find user bank account!</span>")
				return

			if (target_account == mainaccount)
				boutput(user, "<span class='alert'>You can't send funds with the host ID to the host ID!</span>")
				// TAKE SERVICE FEE :3
				target_account.fields["current_money"] -= min_serv_chg
				servicechgaccount.fields["current_money"] += min_serv_chg
				return

			boutput(user, "<span class='notice'>The current host ID is [mainaccount.fields["name"]]. Insert a value less than zero to cancel transaction.</span>")
			var/amount = input(user, "How much money would you like to send?", "Deposit", 0) as null|num
			if (amount <= 0)
				// Assume the service fee
				target_account.fields["current_money"] -= min_serv_chg
				servicechgaccount.fields["current_money"] += min_serv_chg
				return
			if (amount > target_account.fields["current_money"])
				boutput(user, "<span class='alert'>Insufficent funds. [W] only has [target_account.fields["current_money"]] credits.</span>")
				// But take the service fee anyway~
				target_account.fields["current_money"] -= min_serv_chg
				servicechgaccount.fields["current_money"] += min_serv_chg
				return
			boutput(user, "<span class='notice'>Sending transaction.</span>")
			user.visible_message("<span class='notice'>[user] swipes [src] with [W].</span>")
			target_account.fields["current_money"] -= amount
			mainaccount.fields["current_money"] += amount
			var/service_charge = ((amount * serv_chg_pct) < min_serv_chg) ? min_serv_chg : round(amount * serv_chg_pct)
			target_account.fields["current_money"] -= service_charge
			servicechgaccount.fields["current_money"] += service_charge

			user.visible_message("<b>[src]</b> beeps, \"[mainaccount.fields["name"]] now holds [mainaccount.fields["current_money"]] credits. Thank you for your service!\"")
			PrintReceipt(mainaccount, target_account, amount, service_charge)

	attack_hand(mob/user as mob)
		if (!mainaccount)
			boutput(user, "<span class='alert'>You press the reset button, but nothing happens.</span>")
			return
		switch(alert("Reset the reader?",,"Yes","No"))
			if ("Yes")
				boutput(user, "<span class='alert'>Reader reset.</span>")
				user.visible_message("<span class='alert'><B>[user]</B> resets [src].</span>")
				mainaccount = null
			if ("No")
				return

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if(user)
			boutput("You scramble the configuration on [src]!")
			src.servicechgaccount = null
			return 1
		return 0

	demag(var/mob/user)
		if(user)
			boutput("You reset the configuration on [src] to factory defaults.")
			src.mainaccount = null
			src.servicechgaccount = wagesystem.finserv_budget
			return 1
