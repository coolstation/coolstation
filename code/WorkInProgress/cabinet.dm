/obj/cabinet
	name = "Cabinet"
	desc = "Cabinet for storing various things."
	anchored = 1
	density = 1
	icon = 'icons/obj/furniture/cabinet.dmi'
	icon_state = "cabinet"
	flags = NOSPLASH
	bound_height = 32
	bound_width = 32
	layer = EFFECTS_LAYER_1
	appearance_flags = TILE_BOUND

	var/list/slots = list("1","2","3","4","5","6") //I hate byond
	var/list/deniedTypes = list(/obj/item/tool/omnitool) //Add your allowed paths here and the icons for them in rebuildOverlays() below.

	New()
		rebuildOverlays()
		..()

	RawClick(location,control,params)
		var/mob/user = usr
		if (ismobcritter(user) || issilicon(user) || isobserver(user))
			return
		if(can_act(user) && can_reach(user, src))
			var/list/paramList = params2list(params)
			var/slotNum = 0

			//Slots numbered bottom to top, left to right, like byond coords.
			switch(text2num(paramList["icon-x"]))
				if(4 to 15) //Range for left slot x
					switch(text2num(paramList["icon-y"]))
						if(6 to 15) slotNum = 1
						if(17 to 26) slotNum = 3
						if(28 to 37) slotNum = 5
				if(18 to 29) //Range for right slot x
					switch(text2num(paramList["icon-y"]))
						if(6 to 15) slotNum = 2
						if(17 to 26) slotNum = 4
						if(28 to 37) slotNum = 6

			var/obj/item/I = user.equipped()

			if(!slotNum && canHold(I)) //Didn't click on a slot but has valid item. Find next empty slot and put in.
				takeItem(user, I, null)
				return

			if(slots["[slotNum]"] != null)
				if(I && canHold(I)) //Clicked on a full slot with a valid item. Find next empty slot and put in.
					takeItem(user, I, null)
					return
				else if (!I) //Empty hand on full slot, take out.
					var/obj/item/slotItem = slots["[slotNum]"]
					slotItem.set_loc(user.loc)
					slots["[slotNum]"] = null
					user.put_in_hand(slotItem, user.hand)
					boutput(user, "<span class='notice'><B>You take the [slotItem] out of the cabinet.</B></span>")
					rebuildOverlays()
					return
			else
				if(I)
					if(canHold(I))
						takeItem(user, I, "[slotNum]") //aaaah.
					else
						boutput(user, "<span class='alert'><B>You can't put that item in the cabinet.</B></span>")

	proc/takeItem(var/mob/user, var/obj/item/I, var/slotNum = null)
		if (!ishuman(user))
			return
		if(!slotNum) //Didnt pass in a slot number, find next free slot.
			for(var/X in slots)
				if(!slots[X])
					slotNum = X
					break

		if(!slotNum) //Still no free slot number, we're full.
			boutput(user, "<span class='alert'><B>The cabinet is full.</B></span>")
			return

		if(I && I == user.equipped())
			user.drop_item()
			I.set_loc(src)
			slots[slotNum] = I
			rebuildOverlays()
			boutput(user, "<span class='notice'><B>You put the [I] into the cabinet.</B></span>")
		return

	proc/canHold(var/obj/item/I)
		if(isnull(I))
			return null
		if(I.cant_drop)
			return 0
		for(var/X in deniedTypes)
			if(istype(I, X))
				return 0
		return 1

	proc/rebuildOverlays()
		src.underlays.Cut()
		for(var/X in slots)
			var/obj/item/I = slots[X]
			var/offsetX = 0
			var/offsetY = 0

			//Uglyyyy
			switch(X)
				if("1") //Slot 1
					offsetX = 3
					offsetY = 5
				if("2") //Slot 2
					offsetX = 17
					offsetY = 5
				if("3") //Slot 3
					offsetX = 3
					offsetY = 16
				if("4") //Slot 4
					offsetX = 17
					offsetY = 16
				if("5") //Slot 5
					offsetX = 3
					offsetY = 27
				if("6") //Slot 6
					offsetX = 17
					offsetY = 27

			if(istype(I))
				var/image/A = null

				if(istype(I,/obj/item/reagent_containers/glass/bottle)) //Add your other icon states here.
					A = image('icons/obj/furniture/cabinet.dmi',"slot_bottle")
				else
					A = image(cabinetGlassIcon(I))

				A.pixel_x = offsetX
				A.pixel_y = offsetY
				A.mouse_opacity = 0
				underlays.Add(A)
			else
				var/image/A = image('icons/obj/furniture/cabinet.dmi',src,"slot_empty")
				A.pixel_x = offsetX
				A.pixel_y = offsetY
				A.mouse_opacity = 0
				underlays.Add(A)
		return

	ex_act(severity)
		switch(severity)
			if(OLD_EX_SEVERITY_1)
				qdel(src)
				return
			if(OLD_EX_SEVERITY_2)
				if (prob(50))
					qdel(src)
					return

	blob_act(var/power)
		if (prob(25 * power/20))
			qdel(src)

	meteorhit()
		qdel(src)
		return

/obj/cabinet/pathology

	New()
		#ifdef CREATE_PATHOGENS //PATHOLOGY REMOVAL
		slots["1"] = new/obj/item/reagent_containers/glass/vial/prepared(src)
		slots["2"] = new/obj/item/reagent_containers/glass/vial/prepared(src)
		slots["3"] = new/obj/item/reagent_containers/glass/vial/prepared(src)
		slots["4"] = new/obj/item/reagent_containers/glass/vial/prepared(src)
		slots["5"] = new/obj/item/reagent_containers/glass/vial/prepared(src)
		slots["6"] = new/obj/item/reagent_containers/glass/vial/prepared(src)
		#endif
		rebuildOverlays()
		return ..()

/obj/cabinet/chemistry

	New()
		slots["1"] = new/obj/item/reagent_containers/glass/beaker(src)
		slots["2"] = new/obj/item/reagent_containers/glass/beaker(src)
		slots["3"] = new/obj/item/reagent_containers/glass/beaker(src)
		slots["4"] = new/obj/item/reagent_containers/glass/beaker/large(src)
		slots["5"] = new/obj/item/reagent_containers/glass/beaker/large(src)
		slots["6"] = new/obj/item/reagent_containers/glass/beaker/large(src)
		rebuildOverlays()
		return ..()

/obj/cabinet/chemistry2

	New()
		slots["1"] = new/obj/item/reagent_containers/glass/flask(src)
		slots["2"] = new/obj/item/reagent_containers/glass/flask(src)
		slots["3"] = new/obj/item/reagent_containers/dropper/mechanical(src)
		slots["4"] = new/obj/item/reagent_containers/dropper/mechanical(src)
		slots["5"] = new/obj/item/reagent_containers/dropper(src)
		slots["6"] = new/obj/item/reagent_containers/dropper(src)
		rebuildOverlays()
		return ..()

/obj/cabinet/chemicals

	New()
		slots["1"] = new/obj/item/reagent_containers/glass/bottle/oil(src)
		slots["2"] = new/obj/item/reagent_containers/glass/bottle/phenol(src)
		slots["3"] = new/obj/item/reagent_containers/glass/bottle/acetone(src)
		slots["4"] = new/obj/item/reagent_containers/glass/bottle/ammonia(src)
		slots["5"] = new/obj/item/reagent_containers/glass/bottle/diethylamine(src)
		slots["6"] = new/obj/item/reagent_containers/glass/bottle/acid(src)
		rebuildOverlays()
		return ..()

/obj/cabinet/restrictedmedical

	New()
		slots["1"] = new/obj/item/reagent_containers/glass/bottle/pfd(src)
		slots["2"] = new/obj/item/reagent_containers/glass/bottle/pentetic(src)
		slots["3"] = new/obj/item/reagent_containers/glass/bottle/omnizine(src)
		slots["4"] = new/obj/item/reagent_containers/glass/bottle/pfd(src)
		slots["5"] = new/obj/item/reagent_containers/glass/bottle/ether(src)
		slots["6"] = new/obj/item/reagent_containers/glass/bottle/haloperidol(src)
		rebuildOverlays()
		return ..()

/obj/cabinet/medical
	name = "Medical Cabinet"
	desc = "Contains the full spread of standard medical supplies."

	New()
		slots["1"] = new/obj/item/storage/firstaid/brain(src)
		slots["2"] = new/obj/item/storage/firstaid/regular(src)
		slots["3"] = new/obj/item/storage/firstaid/fire(src)
		slots["4"] = new/obj/item/storage/firstaid/toxin(src)
		slots["5"] = new/obj/item/storage/firstaid/brute(src)
		slots["6"] = new/obj/item/storage/firstaid/oxygen(src)
		rebuildOverlays()
		return ..()

/obj/cabinet/medicalbrute
	name = "Trauma Cabinet"
	desc = "Cabinet full of brute-damage-oriented medication."

	New()
		slots["1"] = new/obj/item/storage/box/salinebox(src) //if you bleed out you need this anyway
		slots["2"] = new/obj/item/storage/box/bloodbox(src) //bleeding management (promote clotting/stop bleeding with proconvertin and stimulate blood production with filgrastim)
		slots["3"] = new/obj/item/storage/box/brutebox(src) //liquid brute medication box gosh this is all just a lot of styptic huh (and salicylic)
		slots["4"] = new/obj/item/storage/box/brutepatchbox(src) //brute patch box
		slots["5"] = new/obj/item/storage/firstaid/brute(src)
		slots["6"] = new/obj/item/storage/firstaid/brute(src) //standard brute first aid ready to rock
		rebuildOverlays()
		return ..()

/obj/cabinet/medicalburn
	name = "Burn Cabinet"
	desc = "Cabinet full of burn-damage-oriented medications."

	New()
		slots["1"] = new/obj/item/storage/box/salinebox(src) //burns are traumatic
		slots["2"] = new/obj/item/storage/box/burnbox(src) //liquid burn medication box (with menthol) probably too much but we'll figure out some more medicine or some other drug to stuff in here
		slots["3"] = new/obj/item/storage/box/burnpatchbox(src) //burn patch box and yet again it's almost all the same chem
		slots["4"] = new/obj/item/storage/firstaid/fire(src)
		slots["5"] = new/obj/item/storage/firstaid/fire(src)
		slots["6"] = new/obj/item/storage/firstaid/fire(src) //standard fire first aid ready to rock
		rebuildOverlays()
		return ..()

/obj/cabinet/medicaltoxin
	name = "Anti-Toxins Cabinet"
	desc = "Cabinet for anti-toxin and anti-poisoning medication."
	//should have some better injectable anti-tox thing, instead of just charcoal, calomel, or stuff you have to make

	New()
		slots["1"] = new/obj/item/storage/box/antiradbox(src) //radsupplies box (potassium iodide)
		slots["2"] = new/obj/item/storage/box/purgativebox(src) //purgatives box (calomel and ipecac)
		slots["3"] = new/obj/item/storage/box/antitoxbox(src) //charcoal pills
		slots["4"] = new/obj/item/storage/firstaid/toxin(src) //standard tox first aid
		slots["5"] = new/obj/item/storage/firstaid/toxin(src)
		slots["6"] = new/obj/item/storage/firstaid/toxin(src)
		rebuildOverlays()
		return ..()

/obj/cabinet/medicalcritical
	name = "Critical Care Cabinet"
	desc = "Cabinet full of medicine intended to stabilize the most critical patients."

	New()
		slots["1"] = new/obj/item/storage/box/critcardiacbox(src) //critical cardiac box (amostly tropine plus heparin for blood clot/heart attack)
		slots["2"] = new/obj/item/storage/box/shockbox(src) //critical state recovery (diabetic shock, anaphylactic shock, opiod overdose?,)
		slots["3"] = new/obj/item/storage/box/salinebox(src)
		slots["4"] = new/obj/item/storage/box/salinebox(src)
		slots["5"] = new/obj/item/storage/box/salbutamolbox(src)
		slots["6"] = new/obj/item/storage/box/epibox(src) //adrenaline box
		rebuildOverlays()
		return ..()

//what do we fill this with? not the stuff that the MD has locked up or stuff better cooked up in a chem machine
//but something that's more involved or unusual? anyway...
/* /obj/cabinet/medicalspecialist
	name = "Specialist Drugs Cabinet"
	desc = "Cabinet full of more obscure or advanced medication."

	New()
		slots["1"] = box with 5 ampoule smelling salts, 1 30u synaptizine, 1 30u haloperidol //resuscitation/sedative box
		slots["2"] = new/obj/item/storage/box/bloodbox(src)
		slots["3"] = morphine, salicylic, naloxone (painkiller box)
		slots["4"] = oculine (put it in 7 pre-filled single use droppers. fuck it.)
		slots["5"] = 6 mannitol and 1 salbutamol go together well, considering the circumstance and brain damage mechanic
		slots["6"] = 4 mutadone pill bottles 3 antirad pill bottle box
		rebuildOverlays()
		return ..()

*/
/obj/cabinet/medicalbulk
	name = "Bulk Drugs Cabinet"
	desc = "Cabinet full of bulk medicine reserve beakers."

	New()
		slots["1"] = new/obj/item/reagent_containers/glass/beaker/large/saline(src)
		slots["2"] = new/obj/item/reagent_containers/glass/beaker/large/saline(src)
		slots["3"] = new/obj/item/reagent_containers/glass/beaker/large/antitox(src)
		slots["4"] = new/obj/item/reagent_containers/glass/beaker/large/epinephrine(src)
		slots["5"] = new/obj/item/reagent_containers/glass/beaker/large/brute(src)
		slots["6"] = new/obj/item/reagent_containers/glass/beaker/large/burn(src)
		rebuildOverlays()
		return ..()

/obj/cabinet/medicalmenders

	New()
		slots["1"] = new/obj/item/reagent_containers/mender/brute(src)
		slots["2"] = new/obj/item/reagent_containers/mender_refill_cartridge/brute(src)
		slots["3"] = new/obj/item/reagent_containers/mender_refill_cartridge/brute(src)
		slots["4"] = new/obj/item/reagent_containers/mender/burn(src)
		slots["5"] = new/obj/item/reagent_containers/mender_refill_cartridge/burn(src)
		slots["6"] = new/obj/item/reagent_containers/mender_refill_cartridge/burn(src)
		rebuildOverlays()
		return ..()

/obj/cabinet/psychiatry

	New()
		slots["1"] = new /obj/item/device/audio_log(src)
		slots["2"] = new /obj/item/paper_bin(src)
		slots["3"] = new /obj/item/storage/box/crayon(src)
		slots["4"] = new /obj/item/storage/box/cookie_tin/sugar(src)
		slots["5"] = new /obj/item/item_box/gold_star(src)
		slots["6"] = new /obj/item/toy/plush/small/stress_ball(src)
		rebuildOverlays()
		return ..()

/obj/cabinet/taffy // because you did such a good job in there

	New()
		slots["1"] = new /obj/item/reagent_containers/food/snacks/candy/taffy/cherry(src)
		slots["2"] = new /obj/item/reagent_containers/food/snacks/candy/taffy/watermelon(src)
		slots["3"] = new /obj/item/reagent_containers/food/snacks/candy/taffy/blueraspberry(src)
		slots["4"] = new /obj/item/reagent_containers/food/snacks/candy/taffy/cherry(src)
		slots["5"] = new /obj/item/reagent_containers/food/snacks/candy/taffy/watermelon(src)
		slots["6"] = new /obj/item/reagent_containers/food/snacks/candy/taffy/blueraspberry(src)
		rebuildOverlays()
		return ..()

/obj/cabinet/ammo // for the shooting range prefab
	New()
		slots["1"] = new /obj/item/stackable_ammo/pistol/capacitive/ten(src)
		slots["2"] = new /obj/item/stackable_ammo/pistol/capacitive/ten(src)
		slots["3"] = new /obj/item/stackable_ammo/pistol/capacitive/ten(src)
		slots["4"] = new /obj/item/stackable_ammo/pistol/NT/five(src)
		rebuildOverlays()
		return ..()
