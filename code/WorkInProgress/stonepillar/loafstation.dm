/// loaf station secret module
/// chapter 2 edition
/// sike we're on chapter 3 now
/// whoops we're using the same codebase for chapter 4 as well


/// Lean Cup
/obj/item/reagent_containers/food/drinks/duo/lean
	name = "suspicious duo cup"
	desc = "You can hear digital snares when you put your ear to the cup."

/obj/item/reagent_containers/food/drinks/duo/lean/New()
	..()
	reagents.add_reagent("lean", 25)


/// Meth Ampule Box
/obj/item/reagent_containers/ampoule/meth
	name = "ampoule (methamphetamine)"

/obj/item/reagent_containers/ampoule/meth/New()
	..()
	reagents.add_reagent("methamphetamine", 5)

/obj/item/item_box/meth
	name = "box of meth ampoules"
	desc = "For when jesse doesn't want to cook."
	contained_item = /obj/item/reagent_containers/ampoule/meth


/// Opium Cigars
/obj/item/clothing/mask/cigarette/ricin
	desc = "This one broke bad."
	flavor = "ricin"

/obj/item/clothing/mask/cigarette/cigar/opium
	name = "poppy bulb cigar"
	desc = "Who's got time for an opium pipe anyway?"
	flavor = "morphine"

/obj/item/cigpacket/opium
	name = "wangji cigars"
	desc = "Cheaply packaged opium cigars imported from space china. Aren't these illegal?"
	cigtype = /obj/item/clothing/mask/cigarette/cigar/opium
	icon_state = "cigarillopacket"
	package_style = "cigarillopacket"
	max_cigs = 2


// what could possibly go wrong

/obj/trait/random_allergy/antihol
	name = "Antihol Allergy (+0)"
	cleanName = "Antihol Allergy"
	desc = "You are allergic to antihol."

	id = "antiantihol"
	New()
		..()
		src.allergen = "antihol"


/// Spefo is a hoarder

/obj/machinery/vending/spefo_lol
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
		product_list += new/datum/data/vending_product(/obj/storage/crate/classcrate/demo, 1)
		product_list += new/datum/data/vending_product(/obj/storage/crate/classcrate/medic, 1)
		product_list += new/datum/data/vending_product(/obj/storage/crate/classcrate/infiltrator, 1)
		product_list += new/datum/data/vending_product(/obj/storage/crate/classcrate/scout, 1)
		product_list += new/datum/data/vending_product(/obj/storage/crate/classcrate/engineer, 1)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/rpg, 3)
		product_list += new/datum/data/vending_product(/obj/item/gun/kinetic/rpg7, 1)

/// Casper's Notes for Ch. 2 Investigations

/obj/item/paper/casper_ch2
	name = "crumpled up note"
	desc = "A suspiciously smelly note."
	icon_state = "paper_caution"

/obj/item/paper/casper_ch2/emilija
	name = "pretty drawing"
	desc = "d'aww"
	info = "<em>It's a pleasant crayon drawing of a golden throne with red and black tones.</em>"

/obj/item/paper/casper_ch2/shoes
	info = {"<br>She wasn't safe.
		<br>I had to take her.
		<br>If you find her, don't send her home.
		<br>She will be lost if you do.
		<br>
		<br>Augustus,
		<br>Her future depends on you.
		<br>If you still trust me after this,
		<br>Go to Emilija' Temple.
		<br>Find the place where there is only darkness.
		<br>There, in her sanctuary,
		<br>You will find me.
		<br>
		<br>C
	"}

/obj/item/paper/casper_ch2/temple
	info = {"There is something common between the three of us.
		<br>We all love staring into the stars.
		<br>The next time you go back to that groody couch,
		<br>To gaze into the void.
		<br>We'll be there.
		<br>See you soon.
		<br>
		<br>C
	"}

/obj/item/paper/casper_ch2/wrong
	info = {"
		Not here.
	"}


/// William's Notes for Ch 2. Investigations

/obj/item/paper/william_ch2
	name = "official looking document"
	desc = "These corporate higher-ups get some really nice stationary..."
	icon_state = "stamped-thin"


/obj/item/paper/william_ch2/brief
	info = {"
		<center>OFFICE OF THE REGIONAL DIRECTOR OF THE CENTRAL FRONTIER</center>
		<hr>
		<br>As you all know, my daughter has gone missing. Again.
		<br>Due to some oversights on the part of a certain now-demoted employee, she is in the hands of some disturbed weirdo.
		<br>I've sent one of my inspectors to replace the person whom-shall-not-be-named.
		<br>
		<br>They will be coming to the station with a machine that will feed your camera system into the computers at Central.
		<br>Have the crew install it. If that creep shows up on the station we'll see it and act accordingly.
		<br>
		<br>The attached incident report should provide all of the details for those unaware.
		<br>Get her back, and bring that creep to justice as well.
		<br>Your jobs depend on it.
		<br>
		<br>William Dean
		<br>Regional Director, Central Frontier
	"}

/obj/item/paper/william_ch2/incident
	info = {"
	<center>NANOTRASEN CORPORATE SECURITY</center>
	<hr>
	<br>INCIDENT REPORT - KIDNAPPING; Dean, Emilija
	<br>
	<br>Primary Suspect: Casper Cliff A.K.A Clep Tomani-Aquis
	<br>Last Seen: NT13 Medical Bay; Treatment Room
	<br>Current Status: Presumed to be alive, in custody of suspect.
	<br>Partial belongings of both suspect and victim discovered in The Medical Podbay.
	<br>
	<br>INCIDENT REPORT - GRAND THEFT SPACEPOD
	<br>Primary Suspect: Casper Cliff A.K.A Clep Tomani-Aquis
	<br>Following disappearance of Crewmember Emilija Dean, Pod C-286
	<br>Pod last seen in the Medical Podbay.
	"}

/obj/item/paper/william_ch2/inspector
	info = {"
		<center>OFFICE OF THE REGIONAL DIRECTOR OF THE CENTRAL FRONTIER</center>
		<hr>
		<br>Inspector.
		<br>
		<br>All of the relevant documents have been provided in your suitcase.
		<br>When you are ready, go to the Security Department and brief them on the situation.
		<br>
		<br>Write the results of your investigation on your clip-board.
		<br>Even if you die for whatever reason, that clip-board will transmit it's contents.
		<br>
		<br>If you, during the course of the investigation, have an opprotunity to capture Casper, you must.
		<br>They must be brought to justice.
		<br>
		<br>Good Luck.
		<br>
		<br>William Dean
		<br>Regional Director, Central Frontier
	"}

/obj/item/storage/briefcase/inspector
	spawn_contents = list(/obj/item/paper/william_ch2/incident, /obj/item/paper/william_ch2/brief)


/area/centcom/offices/willaim
	name = "Office of Casper Cliff"

/area/centcom/offices/daniel
	name = "Office of Daniel Dean"

/area/centcom/offices/emilija
	name = "Office of Emilija Dean"


/area/station/casper_shop
	name = "Abandoned Workshop"

/area/centcomm/hell_fucking_hell
	name = "The Basement"

// THE ELEVATOR
/area/shuttle/lovecraft_elevator_room
	name = "Elevator Bay"
	icon_state = "purple"
/area/shuttle/lovecraft_elevator/upper
	name = "Elevator Shaft"
	icon_state = "shuttle"
	filler_turf = "/turf/simulated/floor/specialroom/sea_elevator_shaft"

/area/shuttle/lovecraft_elevator/lower
	name = "Elevator Shaft"
	icon_state = "shuttle2"
	filler_turf = "/turf/simulated/floor/plating"

/area/shuttle/lovecraft_elevator
	name = "Elevator Shaft"
	icon_state = "blue"



#define ELEVATOR_TOP 1
#define ELEVATOR_BOTTOM 0

/obj/machinery/computer/lovecraft_elevator
	name = "Elevator Control"
	icon_state = "shuttle"
	var/active = FALSE
	var/location = ELEVATOR_TOP // 0 for bottom, 1 for top
	var/obj/item/disk/data/floppy/read_only/authentication/disk

	attack_hand(mob/user as mob)
		if(!disk)
			tgui_alert(user, "There is an empty slot where a disk should go. It seems you can't do anything until you put something there.")
			return
		if(active)
			boutput(user, "The disk slot is sealed shut!")
			return
		if(tgui_alert(user, "[disk] protrudes from [src]. Take it?", "Elevator Control", list("Yes", "No")) == "Yes")
			user.put_in_hand_or_eject(src.disk)
			src.disk = null

	attackby(obj/item/W as obj, mob/user as mob)
		var/obj/item/disk/data/floppy/read_only/authentication/disk = W
		if(!istype(disk))
			if(istype(W, /obj/item/disk/data))
				visible_message("<span class='alert'>The machine beeps angrily!</span>")
				playsound(src.loc, 'sound/machines/buzz-two.ogg', 50,1)
				tgui_alert(user, "The machine doesn't seem to want this disk.", timeout=10 SECONDS)
				return
			..()
		if(src.disk)
			boutput(user, "<span class='alert'>There is already something in the disk slot!</span>")
			return
		if(active)
			boutput(user, "<span class='alert'>The disk slot is sealed shut! Maybe wait for the ride to be over?</span>")
			return
		if(tgui_alert(user, "If you insert [disk] into [src], it will begin it's descent.", "Elevator Control", list("Put it in", "Leave it alone")) == "Put it in")
			user.drop_item()
			disk.set_loc(src)
			src.disk = disk
			// weee
			src.active = TRUE
			src.visible_message("<span class='alert'>The elevator begins to move!</span>")
			message_admins("<h2>The lovecraft elevator has been activated at [log_loc(src)] by [key_name(user)]</h2>")
			playsound(src.loc, "sound/machines/elevator_move.ogg", 100, 0)
			SPAWN(10 SECONDS)
				call_shuttle()

	proc/call_shuttle()
		if(location == ELEVATOR_BOTTOM)
			var/area/start_location = locate(/area/shuttle/lovecraft_elevator/lower)
			var/area/end_location = locate(/area/shuttle/lovecraft_elevator/upper)
			start_location.move_contents_to(end_location, /turf/unsimulated/floor/longtile, ignore_fluid = 1)
			location = ELEVATOR_TOP
		else // at top
			var/area/start_location = locate(/area/shuttle/lovecraft_elevator/upper)
			var/area/end_location = locate(/area/shuttle/lovecraft_elevator/lower)
			for(var/mob/M in end_location) // oh dear, stay behind the yellow line kids
				SPAWN(1 DECI SECOND)
					random_brute_damage(M, 30)
					M.changeStatus("weakened", 5 SECONDS)
					M.emote("scream")
					playsound(M.loc, "sound/impact_sounds/Flesh_Break_1.ogg", 90, 1)
			start_location.move_contents_to(end_location, /turf/unsimulated/floor/longtile, ignore_fluid = 1)
			location = ELEVATOR_BOTTOM
		active = FALSE

#undef ELEVATOR_TOP
#undef ELEVATOR_BOTTOM

/obj/item/paper/harry_ch3
	name = "crisp printed paper"
	desc = "A suspiciously well-made page, printed on high-quality cardstock and still smells like it was fresh off the printer."
	icon_state = "paper_caution"
	info = {"
		<br><i>We are the dead.</i>
		<br><i>You are the dead.</i>
		<br><i>Off with your head!</i>
		<br><i>Chopper, chopper, chopper</i>
		<br>24 23 26 50 54 04
	"}

/obj/item/paper/daniel/
	name = "printed memo"
	desc = "Somehow, it kept perfectly."


/obj/item/paper/daniel/
	info = {"
		<br>Chief,
		<br>
		<br>The authentication disk allows you to access the borehole elevator.
		<br>Do not allow any other crew members, including security, to use the elevator.
		<br>
		<br>William Dean
	"}

/obj/item/paper/daniel/casper
	info = {"
		<br>Emilija and Harry and now with Casper.
		<br>Everything is in place.
		<br>It's a major deviation from the plan, but it serves itself.
		<br>
		<br>The Charrington note has been left where he will arrive.
		<br>Remember, crew expendible.
		<br>
		<br>D
	"}

/obj/item/paper/daniel/emilija
	info = {"
		<br>William.
		<br>
		<br>She's ready. Well, as ready as she will ever be.
		<br>I've cleaned up the initial outburst but all is green.
		<br>Now get Casper.
		<br>
		<br>D
	"}

/obj/item/paper/daniel/basement
	info = {"
		<br>KFW,
		<br>We are sending back your engineers soon.
		<br>We will soon have the original creator with us.
		<br>
		<br>You will be rewarded, as promised.
		<br>
		<br>D
	"}


/obj/item/paper/nutty
	name = "crumpled post-it note"
	icon_state = "postit-writing"

	biomatter
		info = {"the biomatter keeps evaporating - get stabalizer!"}

	ai
		info = {"TODO: figure out soul-electron bonding"}

	computer
		info = {"cant interface with the brain until its in. FUCK"}

	shield
		info = {"shield generator hasn't arrived yet"}

/obj/item/device/radio/headset/casper
	name = "crappy headset"
	desc = "A radio headset that can communicate over one crappy channel."
	icon_state = "multi headset"
	frequency = R_FREQ_MULTI
	chat_class = RADIOCL_SYNDICATE
	locked_frequency = TRUE


/datum/job/special/syndicate_weak/casper
	name = "Violently Unemployed"
	slot_poc2 = list()
	slot_poc1 = list()
	slot_rhan = list()
	slot_head = list()
	slot_ears = list(/obj/item/device/radio/headset/casper)

/datum/job/special/lmao
	name = "Missing Person"
	slot_jump = list(/obj/item/clothing/under/misc/western)


// CHAPTER 4 MAGIC

/obj/item/paper/william_ch4
	name = "official looking document"
	desc = "These corporate higher-ups get some really nice stationary..."
	icon_state = "stamped-thin"

	hey_brother
		info = {"
			<br>Inspector,
			<br>
			<br>I'm sure you've read the reports of recent happenings on the station you were just assigned to.
			<br>You are to search for any survivors of the explosion on Core Installation 26, and question them.
			<br>
			<br>It's suspected some of them may have been Syndicate agents. Take care when approaching them.
			<br>
			<br>Good luck.
			<br>Central Command Authorty
			<br>NT-Alpha
		"}

	theres_and_endless_road_2_rediscover
		info = {"
			<br>ALL POINTS BULLETIN - PERSONS OF INTEREST
			<hr>Casper Cliff - WANTED
			<br>Wanted for questioning involving Syndicate activity and kidnapping.
			<br>Wanted Alive by Regional Command.
			<hr>Francis Watt - WANTED
			<br>Wanted for terrorism.
			<br>Whereabouts unknown.
			<hr>Augustus Hanaki - WANTED
			<br>Wanted for questioning involving affiliation with Casper Cliff.
			<br>Wanted Alive by Regional Command.
			<hr>Harry Dubois - WANTED
			<br>Wanted for failure to appear for court-martial.
			<br>Whereabouts unknown.
			<hr>ALL POINTS BULLETIN - PERSONS OF INTEREST
			<br>2053.APR.02
		"}

	hey_sister
		info = {"
		<h1>HEY BOZO</h1>
		<h2>YEAH YOU IM TALKING TO YOU</h2>
		<h3>You forgot to tell the crew to install that machine in your office</h3>
		It stops <b>crazy black holes and shit</b>
		Shit it might not even work but even then its better than nothing
		DONT JUST LEAVE IT THERE ALRIGHT???
		"}

	waters_sweet_blood_thickie // Casper's record
		info = {"
		"}


// CHAPTER 5: RAZORWAVE

/obj/item/razortap
	name = "syndicate circuit interdictor"
	desc = "An illegal and well-crafted device which enables the remote-control of machines. It has 'Nostra nova spes' engraved into the bottom."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "syndie_upgr"
	w_class = W_CLASS_TINY
	is_syndicate = 1
	mats = 12

// Teh razorwave
/obj/machinery/razorwave
	name = "interspatial visual aggregator"
	desc = "It has 'Property of Nanotrasen Research & Development - Project Razorwave' stamped several times on it's surface."
	icon = 'icons/loafstation/razorwave.dmi'
	icon_state = "razorwave"
	density = TRUE
	anchored = TRUE
	/// do it do the doing yes
	var/razorwaving = FALSE

	var/sound/sound_interdict_on = "sound/machines/pc_process.ogg"
	var/sound/sound_interdict_off = "sound/machines/shieldgen_shutoff.ogg"
	var/sound/sound_interdict_run = "sound/loafstation/scan.ogg"
	var/sound/sound_interdict_grump = "sound/loafstation/scour.ogg"

	/// Is our thing open?
	var/thing_open = FALSE
	/// Percent of last scan that was crime divided by 25 percent
	var/crime = 0
	/// Ref to the wiretap
	var/obj/item/razortap/wiretap
	var/datum/light/light

	New()
		..()
		MAKE_SENDER_RADIO_PACKET_COMPONENT("pda", FREQ_PDA)
		light = new/datum/light/point
		light.set_brightness(0.4)
		light.set_color(0.38, 0.88, 0.85)
		light.attach(src)
		src.wiretap = new

	//lol, sort of copied from secbot.dm
	proc/assess_perp(mob/target as mob)
		var/threatcount = 0

		if (!ishuman(target))
			if (istype(target, /mob/living/critter/changeling))
				return 6
			for( var/obj/item/item in target.contents )
				threatcount += item.contraband
			return threatcount

		var/mob/living/carbon/human/perp = target

		if (perp.mutantrace)
			if (istype(perp.mutantrace, /datum/mutantrace/abomination))
				threatcount += 8
			else if (istype(perp.mutantrace, /datum/mutantrace/zombie))
				threatcount += 6
			else if (istype(perp.mutantrace, /datum/mutantrace/werewolf) || istype(perp.mutantrace, /datum/mutantrace/hunter))
				threatcount += 4
			else if (istype(perp.mutantrace, /datum/mutantrace/cat))
				threatcount += 3

		if(perp.traitHolder.hasTrait("immigrant") && perp.traitHolder.hasTrait("jailbird"))
			if(isnull(data_core.security.find_record("name", perp.name)))
				threatcount += 5

		//if((isnull(perp:wear_id)) || (istype(perp:wear_id, /obj/item/card/id/syndicate)))
		var/obj/item/card/id/perp_id = perp.equipped()
		if (!istype(perp_id))
			perp_id = perp.wear_id

		var/has_carry_permit = 0
		var/has_contraband_permit = 0

		if(perp_id) //Checking for permits
			if(access_carrypermit in perp_id.access)
				has_carry_permit = 1
			if(access_contrabandpermit in perp_id.access)
				has_contraband_permit = 1

		if (istype(perp.l_hand))
			if (istype(perp.l_hand, /obj/item/gun/))  // perp is carrying a gun
				if(!has_carry_permit)
					threatcount += perp.l_hand.contraband
			else // not carrying a gun
				if(!has_contraband_permit)
					threatcount += perp.l_hand.contraband

		if (istype(perp.r_hand))
			if (istype(perp.r_hand, /obj/item/gun/)) // perp is carrying a gun
				if(!has_carry_permit)
					threatcount += perp.r_hand.contraband
			else // not carrying a gun, but potential contraband?
				if(!has_contraband_permit)
					threatcount += perp.r_hand.contraband

		if (istype(perp.wear_suit))
			if (!has_contraband_permit)
				threatcount += perp.wear_suit.contraband

		if (istype(perp.belt))
			if (istype(perp.belt, /obj/item/gun/))
				if (!has_carry_permit)
					threatcount += perp.belt.contraband * 0.5
			else
				if (!has_contraband_permit)
					threatcount += perp.belt.contraband * 0.5
				for( var/obj/item/item in perp.belt.contents )
					if (istype(item, /obj/item/gun/))
						if (!has_carry_permit)
							threatcount += item.contraband * 0.5
					else
						if (!has_contraband_permit)
							threatcount += item.contraband * 0.5

		if (istype(perp.l_store))
			if (istype(perp.l_store, /obj/item/gun/))
				if (!has_carry_permit)
					threatcount += perp.l_store.contraband * 0.5
			else
				if (!has_contraband_permit)
					threatcount += perp.l_store.contraband * 0.5

		if (istype(perp.r_store))
			if (istype(perp.r_store, /obj/item/gun/))
				if (!has_carry_permit)
					threatcount += perp.r_store.contraband * 0.5
			else
				if (!has_contraband_permit)
					threatcount += perp.r_store.contraband * 0.5

		if (istype(perp.back))
			if (istype(perp.back, /obj/item/gun/)) // some weapons can be put on backs
				if (!has_carry_permit)
					threatcount += perp.back.contraband * 0.5
			else // at moment of doing this we don't have other contraband back items, but maybe that'll change
				if (!has_contraband_permit)
					threatcount += perp.back.contraband * 0.5
			if (istype(perp.back, /obj/item/storage/))
				for( var/obj/item/item in perp.back.contents )
					if (istype(item, /obj/item/gun/))
						if (!has_carry_permit)
							threatcount += item.contraband * 0.5
					else
						if (!has_contraband_permit)
							threatcount += item.contraband * 0.5

		//Agent cards lower threatlevel
		if((istype(perp.wear_id, /obj/item/card/id/syndicate)))
			threatcount -= 2

		// we have grounds to make an arrest, don't bother with further analysis
		if(threatcount >= 4)
			return threatcount

		var/see_face = 1
		if (istype(perp.wear_mask) && !perp.wear_mask.see_face)
			see_face = 0
		else if (istype(perp.head) && !perp.head.see_face)
			see_face = 0
		else if (istype(perp.wear_suit) && !perp.wear_suit.see_face)
			see_face = 0

		var/perpname = see_face ? perp.real_name : perp.name

		for (var/datum/db_record/R as anything in data_core.security.find_records("name", perpname))
			if(R["criminal"] == "*Arrest*")
				threatcount = max(4,threatcount)
				break

		return threatcount


	proc/get_trackable_mobs()
		. = list()
		for (var/mob/M in mobs)
			if(!ishuman(M))
				continue
			if (HAS_ATOM_PROPERTY(M, PROP_MOB_AI_UNTRACKABLE))
				continue
			if (istype(M:wear_id, /obj/item/card/id/syndicate) || (istype(M:wear_id, /obj/item/device/pda2) && M:wear_id:ID_card && istype(M:wear_id:ID_card, /obj/item/card/id/syndicate)))
				continue
			if(M.z != 1 && M.z != src.z)
				continue
			if(!istype(M.loc, /turf)) //in a closet or something, AI can't see him anyways
				continue
			if(M.invisibility) //cloaked
				continue
			var/turf/T = get_turf(M)
			if(!T.cameras || !length(T.cameras))
				continue
			. += M

	attack_hand(mob/user as mob)
		tgui_alert(user, "It seems to need a floppy disk to activate.")
		return

	emag_act(mob/user, obj/item/card/emag/E)
		src.add_fingerprint(user)
		if(src.thing_open)
			boutput(user, "<span class='alert'>There isn't anything to emag.</span>")
			return
		src.thing_open = TRUE
		UpdateIcon()
		playsound(src, "sound/items/Deconstruct.ogg", 40, 1)
		visible_message("<span class='alert'>[user] overloads the magentic lock on [src]!</span>")
		return TRUE

	attackby(obj/item/I, mob/user)
		src.add_fingerprint(user)
		if(isscrewingtool(I))
			if(src.razorwaving && !src.thing_open)
				boutput(user, "<span class='alert'>The magnetic lock prevents the screws from coming out!</span>")
			else
				src.thing_open = !src.thing_open
				visible_message("<span class='alert'>[user] [src.thing_open ? "removes" : "secures"] the access panel on [src].</span>")
				playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
				UpdateIcon()
			return
		if(istype(I, /obj/item/razortap))
			if(src.wiretap) // technically possible.
				boutput(user, "<span class='alert'>Someone beat you to it, there is already a bug in there!</span>")
				message_coders("[user] managed to stick [I] into [src] at [log_loc(src)] just to find its bugged already")
				return
			if(!src.thing_open)
				boutput(user, "<span class='alert'>You need to remove the access panel first!</span>")
				return
			visible_message("<span class='alert'>[user] sticks [I] into [src] for some reason.</span>")
			user.u_equip(I)
			I.set_loc(src)
			src.wiretap = I
			playsound(src, "sound/items/Deconstruct.ogg", 40, 1)
			UpdateIcon()
			return
		var/obj/item/disk/data/floppy/read_only/authentication/disk = I
		if(istype(disk))
			if(tgui_alert(user, "Are you sure you want to [src.razorwaving ? "deactivate" : "activate"] [src]?", "Razorwave Controls", list("Yes", "No")) == "Yes")
				src.razorwaving = !src.razorwaving
				if(src.razorwaving)
					visible_message("<span class='alert'>[src] starts buzzing violently!</span>")
					playsound(src.loc, src.sound_interdict_on, 30, 0)
					message_admins("[src] at [log_loc(src)] was turned on by [user]!")
					SubscribeToProcess()
				else
					visible_message("<span class='alert'>[src] stops buzzing!</span>")
					playsound(src.loc, src.sound_interdict_off, 30, 0)
					message_admins("[src] at [log_loc(src)] was turned off by [user]!")
					UpdateIcon()
				return
		if(istype(I, /obj/item/disk/data))
			visible_message("<span class='alert'>\The [src] beeps angrily!</span>")
			playsound(src.loc, 'sound/machines/buzz-two.ogg', 50,1)
			tgui_alert(user, "The machine doesn't seem to want this disk.", timeout=10 SECONDS)
			return
		. = ..()

	power_change()
		. = ..()
		UpdateIcon()
		if(status & (NOPOWER))
			return
		SubscribeToProcess()

	update_icon(...)
		if(status & (NOPOWER))
			UpdateOverlays(null, "power")
			UpdateOverlays(null, "razorwaving")
			UpdateOverlays(null, "crimewave")
			light.disable()
			return
		UpdateOverlays(image('icons/loafstation/razorwave.dmi', "razorwave-power"), "power")
		if(src.razorwaving)
			UpdateOverlays(image('icons/loafstation/razorwave.dmi', "razorwave-on"), "razorwaving")
			light.enable()
		else
			UpdateOverlays(null, "razorwaving")
			light.disable()
		if(src.crime > 0 && src.crime < 5)
			UpdateOverlays(image('icons/loafstation/razorwave.dmi', "razorwave-crime[crime]"), "crimewave")
		else
			UpdateOverlays(null, "crimewave")
		if(src.thing_open)
			src.icon_state = "razorwave-bug[src.wiretap ? "":"less"]"
		else
			src.icon_state = "razorwave"

	process()
		if(!src.razorwaving || (status & (NOPOWER)))
			UnsubscribeProcess()
			return
		var/new_people_or_crime = FALSE
		var/possible_crime = 0
		var/total_crime = 0
		for(var/mob/target in src.get_trackable_mobs())
			var/contraband = assess_perp(target)
			contraband = min(contraband,10)

			if(prob(6.66))
				target.show_text( "You feel [pick("funny", "wrong", "confused", "dangerous", "sickly", "puzzled", "happy")].", "blue" )
			if(prob(1))
				target.take_toxin_damage(1) // yeah this thing probably isn't that healthy

			// Machine gets grumpier when new people enter it's range
			if(!ON_COOLDOWN(target, "razorwave_tracking", 5 MINUTES))
				new_people_or_crime = TRUE

			if (ishuman(target))
				possible_crime++

			if (contraband >= 4)
				contraband = round(contraband)
				var/scan_location = get_area(target)
				if (ishuman(target))
					var/mob/living/carbon/human/H = target
					// Or when someone commits some crime...
					if(!ON_COOLDOWN(H, "razorwave_snitch", 5 MINUTES))
						var/datum/signal/pdaSignal = get_free_signal()
						pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="RAZORWAVE-MAILBOT", "group"=list(MGD_SECURITY, MGA_CHECKPOINT), "sender"="00000000", "message"="Notification: [H.name] failed Razorwave scan in [scan_location]! Threat Level : [contraband]")
						SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pdaSignal)
						new_people_or_crime = TRUE
						total_crime++
		src.crime = round((total_crime/possible_crime)/0.25)

		if(new_people_or_crime)
			src.use_power(10 KILO WATTS)
			playsound(src.loc, src.sound_interdict_grump, 30, 0)
		else
			playsound(src.loc, src.sound_interdict_run, 30, 0)
		src.use_power(10 KILO WATTS)

		UpdateIcon()


/obj/item/razor_board
	name = "interspatial visual aggregator mainboard"
	desc = "A custom-fabricated circuit board with a cutting-edge miniaturized retro-encabulator."
	icon = 'icons/obj/machines/interdictor.dmi'
	icon_state = "interdict-board"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "electronic"
	mats = 6
	health = 6
	w_class = W_CLASS_TINY
	flags = FPRINT | TABLEPASS | CONDUCT

/obj/item/razorwave_pillar
	name = "hypertron beam array"
	desc = "A large, narrow cylinder with a nanofiber structure set up like antennae."
	icon_state = "razorwave-pillar"
	icon = 'icons/loafstation/razorwave.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "rods"
	force = 3
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_NORMAL
	flags = FPRINT | TABLEPASS | CONDUCT


/// Brand-new with nothing new
#define RAZORWAVE_FRAME "razorwave-frame"
/// Do you have the Sensing Pillar?
#define RAZORWAVE_PILLAR "razorwave-tower"
/// Mainboard added
#define RAZORWAVE_MAINBOARD "razorwave-board"
/// Wires added
#define RAZORWAVE_WIRES "razorwave-wire"
/// Screwed shut
#define RAZORWAVE_ASSEMBLED "razorwave"

/obj/razorwave_frame
	name = "interspatial visual aggregator frame"
	icon = 'icons/loafstation/razorwave.dmi'
	icon_state = "razorwave-frame"
	anchored = FALSE
	density = TRUE
	var/construction_state = RAZORWAVE_FRAME

	update_icon(...)
		. = ..()
		if(construction_state)
			icon_state = construction_state

	proc/finish_construction(obj/item/I, mob/user)
		switch(construction_state)
			if(RAZORWAVE_FRAME)
				construction_state = RAZORWAVE_PILLAR
				user.u_equip(I)
				playsound(src, "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)
				qdel(I)
			if(RAZORWAVE_PILLAR)
				construction_state = RAZORWAVE_MAINBOARD
				user.u_equip(I)
				playsound(src, "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)
				qdel(I)
			if(RAZORWAVE_MAINBOARD)
				construction_state = RAZORWAVE_WIRES
				I.amount -= 4
				if (I.amount < 1)
					user.u_equip(I)
					qdel(I)
				else if(I.inventory_counter)
					I.inventory_counter.update_number(I.amount)
				playsound(src, "sound/items/Deconstruct.ogg", 40, 1)
			if(RAZORWAVE_WIRES)
				construction_state = RAZORWAVE_ASSEMBLED
				playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
				message_admins("[user] assembled [src] at [log_loc(src)]")
				visible_message("<span class='alert'><b>[src] bolts itself to the floor!</b></span>")
				var/obj/machinery/razorwave/razorwave = new
				razorwave.set_loc(src.loc)
				qdel(src)
		UpdateIcon()

	attackby(obj/item/I, mob/user)
		var/end_message = ""
		if(src.construction_state == RAZORWAVE_FRAME)
			if(!istype(I, /obj/item/razorwave_pillar))
				return ..()
			visible_message("<span class='notice'>[user] begins to twist [I] into [src].</span>")
			playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
		if(src.construction_state == RAZORWAVE_PILLAR)
			if(!istype(I, /obj/item/razor_board))
				return ..()
			visible_message("<span class='notice'>[user] starts to install [I] into [src].</span>")
			end_message = "<span class='notice'>You install [I] into [src].</span>"
		if(src.construction_state == RAZORWAVE_MAINBOARD)
			if(!istype(I, /obj/item/cable_coil))
				return ..()
			visible_message("<span class='notice'>[user] starts to connect the circuits and modules in [src].</span>")
			end_message = "<span class='notice'>You connect the circuits and modules in [src].</span>"
		if(src.construction_state == RAZORWAVE_WIRES)
			if(!isscrewingtool(I))
				return ..()
			playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
			visible_message("<span class='notice'>[user] starts to close up [src]</span>")
			end_message = "<span class='notice'>You close up [src]</span>"
		src.add_fingerprint(user)
		var/datum/action/bar/icon/hitthingwithitem/actionbar = new(user, user, I, src, src, 4 SECONDS, .proc/finish_construction, list(I, user), I.icon, I.icon_state, end_message, null)
		actionbar.interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
		actions.start(actionbar, user)

#undef RAZORWAVE_FRAME
#undef RAZORWAVE_WIRES
#undef RAZORWAVE_MAINBOARD
#undef RAZORWAVE_ASSEMBLED

/datum/manufacture/mechanics/razorwave
	name = "interspatial visual aggregator frame"
	frame_path = /obj/razorwave_frame
	time = 30 SECONDS
	create = 1
	item_amounts = list(5,6,4)

/obj/item/paper/manufacturer_blueprint/razorwave
	blueprint = /datum/manufacture/mechanics/razorwave


/obj/item/paper/william_ch5
	name = "official looking document"
	desc = "These corporate higher-ups get some really nice stationary..."
	icon_state = "stamped-thin"

	some_advice
		info = {"
			Place the provided device into the access compartment of the razorwave.
			<br>The razorwave must be assembled but not turned on.
			<br>If the razorwave is already online, you will have to overload the locks with an emag.
			<br>You will need a screwdriver to remove the cover on the compartment.
			<br>Good luck.
		"}

	razorwave
		info = {"
		<center>
		<h2>NANOTRASEN RESEARCH & DEVELOPMENT<h2>
		<span>PROJECT RAZORWAVE -- TOP SECRET -- FOR YOUR EYES ONLY</span>
		</center>
		<hr>
		<h3>ABOUT THE VISUAL AGGREGATOR</h3>
		<br>The experimental interspatial visual aggregator, sometimes called the Razorwave,
		<br>is an tactical counter-terrorism measure designed to identify and isolate
		<br>threats to station security with extreme accuracy.
		<br>
		<br>It goes without saying that this technology is one of our trump cards.
		<br>Make sure the Syndicate or any enterprising puttwasher dont get their hands on it!
		<br>
		<br>There is a minor risk of toxic organ damage while the machine is operating.
		<br>In studies however, less than 1% of subjects showed signs of significant organ damage.
		<h3>POWER REQUIREMENTS</h3>
		<br>The experimental interspatial visual aggregator is a very power-hungry device.
		<br>It requires 36 megawatt-hours of electricity to remain powered.
		<br>It is recommended one ore multiple portable generators be used to provide this power.
		<br>Alternative operations include: APC Hotwiring, Artifact Science.
		<h3>INSTALLATION LOCATION</h3>
		<br>Pick a location easily defensible from external threats in the interior of your station.
		<h3>ASSEMBLY INSTRUCTIONS</h3>
		<ol>
			<li>Manufacture the frame of the device from the provided blueprint</li>
			<li>Deploy the frame of the device where it will be installed</li>
			<li>Install the hypertron beam array into the frame</li>
			<li>Insert the mainboard into the frame</li>
			<li>Connect the hypertron beam to the mainboard using standard electrical cable.</li>
			<li>Tighten automatic security screws with screwdriver</li>
			<li>Activate using your commander's Authentication Disk.</li>
		</ol>
		<br>The interspatial visual aggregator will then permentantly affix itself to the decking of your station automatically.
		<br>It cannot be removed without explosives.
		"}

	intel
		info = {"
		<br>NANOTRASEN CORPORATION THREAT ADVISORY
		<hr>APRIL 04, 2053 - CENTRAL COMMAND
		<em>( It's totally empty. Must've gotten lost during transmission. Oh well! )</em>
		"}

/obj/item/paper/casper_ch5
	name = "crumpled up note"
	desc = "A suspiciously smelly note."
	icon_state = "paper_caution"

	razorwave
		info = {"
		<br>omnipresent visual threat assessment system
		<br>my assistant keeps calling it razorwave.
		<br>it can see everyone, see everything.
		<br>can detect selected individuals, can detect
		<br>specific weapons and items.
		<br>it's the ultimate anti-terror device.
		<br>might cause kindey damage. not sure.
		<br>will test on a random population.
		"}

	wedc
		info = {"
			<br>william wanted some sort of method to control an individual
			<br>I assumed it was some like interrogation stuff but
			<br>He was also looking for that girl a while ago.
			<br>weird. oh well.
		"}

	seeing_it_all
		info = {"
			<br>i saw it all
			<br>i was making the matter drive and it just
			<br>reached out to me. like my brain was touched.
			<br>i understood the universe and for a moment
			<br>i could fix it all
			<br>but now its gone
			<br>its all gone
			<br>i remember so little
			<br>but i know that i am about to do something terrible.
			<br>i have to get out of here
			<br>i have to get out of here
			<br>i have to get out of here
			<br>daniel scares the hell out of me
			<br>william scares the hell out of me
			<br>i scare the hell out of me
			<br>she scares the hell out of me
			<br>she is scared by everyone except him
			<br>i have to get her out of here
			<br>i have to get out of here
			<br>i have to get out of here
		"}

	note_to_self
		info = {"
			<br>note to self
			<br>remove those dumb scuff marks in front of the dresser
			<br>makes it really obvious where the secret wall is
			<br>
			<br>might not matter. maybe i'll make her do it
		"}

	the_future
		info = {"
			<br>long range gps frequency detection
			<br>if you point the telescope long enough in it's general area
			<br>you can pick up the gps signal if you over do a long exposure
			<br>should work to locate where emilija is
			<br>
			<br>or me
			<br>i probably need to cut that damn implant out
			<br>but i have to get ready
			<br>augustus is already here
			<br>
			<br>note to self: just make it so if you put a gps near it
			<br>it will eventually program the cordinates

		"}


// title screen scene here

/area/titlescreen/daniel
	name = "D"
/area/titlescreen/william
	name = "W"
/area/titlescreen/kilo
	name = "KFW"
/area/titlescreen/rodgers
	name = "R"

/obj/toggle_power_thingy
	name = "thing you shouldn't see you nosy fucker"
	desc = "fucking nerd"
	anchored = 1

	attack_hand(mob/user)
		if(!isadmin(user))
			boutput(user, "<h1>HEY GET YOUR HANDS OFF MY ADMIN TRIGGER</h1>")
			return
		var/area/the_area = get_area(src)
		the_area.power_light = FALSE
		the_area.power_equip = FALSE
		the_area.power_change()
		playsound(src.loc, 'sound/machines/shieldgen_shutoff.ogg', 30, 0)
		visible_message("<span class='alert'>The communication console shuts down!</span>")


/obj/item/paper/william_ch6
	name = "official looking document"
	desc = "These corporate higher-ups get some really nice stationary..."
	icon_state = "stamped-thin"

	startup
		info = {"
		<h1>RAZORWAVE ACTIVATION FOR DUMMIES! (ages 3+)</h1>
		<hr>Good morning, Captain!
		<br>The Razorwave must be activated early on in the shift for maximum effectiveness.
		<br>Your crew will need to:
		<ul>
		<li>Prepare primary power supply through SMES unit north of it.</li>
		<li>Prepare backup power generators in case of emergency </li>
		<li>Activate the Razorwave device using Authentication Disk</li>
		<li>Use your friendly station AI to secure the compartment</li>
		<li>?????</li>
		<li>Profit!</li>
		</ul>
		<br>Have a safe and productive shift!
		<br>Nanotrasen Department of Informational Publications
		"}

	layoff
		info = {"
		<br>NANOTRASEN CORPORATION DEPARTMENT OF HUMAN RESOUCES
		<br>STAFFING DIRECTIVE EFFECTIVE UPON RECEIPT
		<hr>Due to increased operational costs in Frontier stations and
		<br>the sharp increase in human resource waste
		<br>It is ordered that stations must employ <b>no more than</b>
		<ul>
		<li>1 Head of Security or NT-SO per 40 crewmates</li>
		<li>1 Security Officer per 40 crewmates</li>
		<li>1 Part-Time Vice Officer per 10 crewmates</li>
		<li>2 Engineers</li>
		<li>1 Medical Doctor per 10 crewmates</li>
		</ul>
		<b>Stipend will be adjusted to reflect these employment requirements.</b>
		<hr>NT HUMAN RESOURCES
		"}

// chapter 7: nostra nova spes

var/global/list/ckey_start_locations = list()

/obj/landmark/ckey_start
	name = "start"
	icon_state = "x"
	add_to_landmarks = FALSE

	New()
		src.name = ckey(src.name)
		if (ckey_start_locations)
			if (!islist(ckey_start_locations[src.name]))
				ckey_start_locations[src.name] = list(src.loc)
			else
				ckey_start_locations[src.name] += src.loc
		..()


/obj/machinery/field_generator/popup
	var/obj/machinery/turretcover/cover
	state = 2 // WELDED from singularity.dm

	var/popping = 0

	disposing()
		. = ..()
		qdel(cover)

	process()
		if (src.cover==null)
			src.cover = new /obj/machinery/turretcover(src.loc)
		if(..())
			popDown()
		if(!isDown())
			playsound(src, 'sound/loafstation/scan.ogg', 20, 0)

	proc/isDown()
		return (invisibility != INVIS_NONE)

	proc/isPopping()
		return (popping!=0)

	proc/popUp()
		if (!isDown()) return
		if ((!isPopping()) || src.popping==-1)
			invisibility = INVIS_NONE
			popping = 1
			if (src.cover!=null)
				flick("popup", src.cover)
				src.cover.icon_state = "openTurretCover"
			SPAWN(1 SECOND)
				if (popping==1) popping = 0
				set_density(1)
				src.Varedit_start = TRUE

	proc/popDown()
		if (isDown()) return
		if ((!isPopping()) || src.popping==1)
			popping = -1
			src.power = 0
			SPAWN(3 SECONDS)
				if (src.cover!=null)
					flick("popdown", src.cover)
					src.cover.icon_state = "turretCover"
			SPAWN(3 SECONDS + 1.3 SECONDS)
				if (popping==-1)
					invisibility = INVIS_CLOAK
					popping = 0
					set_density(0)


/obj/machinery/computer/at_field
	name = "shield control computer"
	icon_state = "engine"
	var/active = FALSE

	attack_hand()
		if(active)
			playsound(src, 'sound/machines/shieldgen_shutoff.ogg', 50, 0)
		else
			playsound(src, 'sound/machines/shieldgen_startup.ogg', 50, 0)
		for(var/obj/machinery/field_generator/popup/gen in get_area(src))
			if(active)
				gen.popDown()
			else
				gen.popUp()
		active = !active
		..()

/obj/item/card/id/casper
	name = "pristine identification card"
	icon_state = "polaris"
	registered = "Casper Cliff"
	assignment = "Research Director"
	access = list(access_polariscargo,access_heads)
	keep_icon = TRUE

/obj/landmark/lrt/casper
	name = "Casper's Workshop"

/area/centcomm/hell_fucking_hell/core
	name = "Steel Crown Core"
	icon_state = "AIt"


/obj/item/paper/emilija
	name = "well-kept stationary"
	desc = "Smells like fresh waffles!"
	icon_state = "stamped-thin"

	gtg
		info = {"
			<br>It's time for me to go.
			<br>Cliff doesn't want me to write...
			<br>He's..
			<br>
			<br>
			<br>I can hear them both...
			<br>One in the hall, and one above..
			<br>Calm down.
		"}

	herself
		info = {"
			<br>it's soon
			<br>it's what i was meant to do
			<br>i tried to live a little while i can
			<br>but it's time to live in death
			<br>for the rest
		"}

	them
		info = {"
			<br>who are they?
			<br>i don't remember them
			<br>i remember people and places
			<br>but not faces
			<br>i remember sun and soil
			<br>but not oil
			<br>not steel and cold stone
			<br>i sit here almost alone
			<br>who are they?
		"}

	alive
		info = {"
			<br>it's there
			<br>everything he's wanted is there
			<br>i've seen it all before
			<br>in that room south of here
			<br>sometimes i still go there
			<br>pretend caspers's still there
			<br>that's why i wonder...
			<br>where?
		"}


/obj/item/paper/casper_ch5
	name = "crumpled up note"
	desc = "A suspiciously smelly note."
	icon_state = "paper_caution"

	goodbye
		info = {"
			<br>if you're reading this, it's done
			<br>he's in the crown and so am i
			<br>don't speak, think.
			<br>he can see you. all of you
			<br>see into your eyes and into yourself
			<br>take these.
			<br>the disk is in her room. she's never used it.
			<br>look where stuff you don't need goes.
		"}



/// finale


/turf/simulated/floor/plating/airless/asteroid/dark/air
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C
