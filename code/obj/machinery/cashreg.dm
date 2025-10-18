/obj/machinery/cashreg
	name = "credit transfer device"
	desc = "Sends funds directly to a host ID."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "scanner"
	anchored = ANCHORED
	mats = 6
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_MULTITOOL
	var/datum/db_record/mainaccount = null
	var/datum/db_record/servicechgaccount = null

	var/receipt_count = 20 // Todo: ...new printer rolls for receipts?
	var/min_serv_chg  = 5
	var/serv_chg_pct  = 0.02 // Percentage for service charge. 0.02 == 2%

	New()
		..()
		UnsubscribeProcess()
		if(!servicechgaccount)
			servicechgaccount = wagesystem.finserv_budget

	proc/PrintReceipt(var/datum/db_record/accountTo, var/datum/db_record/accountFrom, amount, serv_chg_amount)
		//
		var/receiptText = "<b>Payment Receipt</b><br>"

		receiptText += "<b>[accountTo["name"]]</b>: [amount]<br>"
		receiptText += "<b>Service Charge</b>: [serv_chg_amount]<br>"
		receiptText += "<hr>"
		receiptText += "<b>Total</b> (deducted from [accountFrom["name"]]): [amount + serv_chg_amount]"

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
				for (var/datum/db_record/account as anything in data_core.bank.records)
					if (ckey(account["name"]) == ckey(card.registered))
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
				servicechgaccount = data_core.bank.find_record("id", ckey(card.registered_id))
				if(!istype(servicechgaccount))
					servicechgaccount = null
					boutput(user, "<span class='alert'>Configuration failure</span>")
					return

				user.visible_message("<span class='notice'>[user] configures [src] with [W].</span>")
				return

			if (card.registered_id in FrozenAccounts)
				boutput(user, "<span class='alert'>Your account cannot currently be liquidated due to active borrows.</span>")
				return
			var/datum/db_record/target_account = FindBankAccountByName(card.registered)
			if (!istype(target_account))
				boutput(user, "<span class='alert'>Unable to find user bank account!</span>")
				return

			if (target_account == mainaccount)
				boutput(user, "<span class='alert'>You can't send funds with the host ID to the host ID!</span>")
				// TAKE SERVICE FEE :3
				target_account["current_money"] -= min_serv_chg
				servicechgaccount["current_money"] += min_serv_chg
				return

			boutput(user, "<span class='notice'>The current host ID is [mainaccount["name"]]. Insert a value less than zero to cancel transaction.</span>")
			var/amount = input(user, "How much money would you like to send?", "Deposit", 0) as null|num
			if (amount <= 0)
				// Assume the service fee
				target_account["current_money"] -= min_serv_chg
				servicechgaccount["current_money"] += min_serv_chg
				return
			if (amount > target_account["current_money"])
				boutput(user, "<span class='alert'>Insufficent funds. [W] only has [target_account["current_money"]] credits.</span>")
				return
			boutput(user, "<span class='notice'>Sending transaction.</span>")
			user.visible_message("<span class='notice'>[user] swipes [src] with [W].</span>")
			target_account["current_money"] -= amount
			mainaccount["current_money"] += amount
			user.visible_message("<b>[src]</b> beeps, \"[mainaccount["name"]] now holds [mainaccount["current_money"]] credits. Thank you for your service!\"")

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

/* this shit needs to be burned
/obj/machinery/cashreg/register //basically a machine that generates a receipt for whatever items are selected without charging the user.
	name = "register"
	desc = "prints out a bill for items bought."
	icon_state = "register"
	var/list/laden = list()
	var/owner
	var/temp

	attackby(obj/item/W as obj, mob/user as mob)

		if(istool(W, TOOL_SCREWING | TOOL_WRENCHING))
			user.visible_message("<b>[user]</b> [anchored ? "unbolts the [src] from" : "secures the [src] to"] the floor.")
			playsound(src.loc, "sound/items/Screwdriver.ogg", 80, 1)
			src.anchored = !src.anchored

	attack_hand(var/mob/user as mob)
		src.add_dialog(user)
		var/dat
		if(src.temp)
			dat = src.temp
		if(!owner)
			owner = input(user, "Please enter the shop or owner name.","Bill Register",0)

		dat += {"<B>Bill Issuer: [owner]</B><br><br>"}
		dat += view_list()
		user.Browse(dat, "title=[owner] Stock Register;window=computer_\ref[src];size=575x450")
		onclose(user, "computer_\ref[src]")
		return

	view_list()
		. = "<B>Item list:</B><br>"
		for(var/S in laden)
			var/datum/laden_item/LI = S
			. += "<A href='byond://?src=\ref[src];changename=1>[LI.itemname]</A> - <A href='byond://?src=\ref[src];changeprice=1>[LI.itemprice]</A> - <A href='byond://?src=\ref[src];add=1>ADD TO BILL</A> - <A href='byond://?src=\ref[src];remove=1>(X)</A>"
*/

