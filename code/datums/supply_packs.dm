/proc/build_supply_pack_cache()
	//hjalp pls

	//clear all lists before start the manual way
	qm_supply_cache.Cut()
	nanotrasen_supply_cache.Cut()
	engineering_supply_cache.Cut()
	construction_supply_cache.Cut()
	electronics_supply_cache.Cut()
	grocery_supply_cache.Cut()
	heavy_supply_cache.Cut()
	party_supply_cache.Cut()
	vending_supply_cache.Cut()
	misc_supply_cache.Cut()



	//start adding items to their respective lists
	for(var/S in concrete_typesof(/datum/supply_packs))
		//fill old list just in case (definitely wanna boot this guy out tho)
		qm_supply_cache += new S()
		//and do it again for specific vendor lists because
		var/datum/supply_packs/SP = S //because fuck me that's why
		switch(initial(SP.vendor))
			if ("nanotrasen")
				nanotrasen_supply_cache += new S()
			if ("engineering")
				engineering_supply_cache += new S()
			if ("construction")
				construction_supply_cache += new S()
			if ("electronics")
				electronics_supply_cache += new S()
			if ("grocery")
				grocery_supply_cache += new S()
			if ("heavy")
				heavy_supply_cache += new S()
			if ("vending")
				vending_supply_cache += new S()
			if ("party")
				party_supply_cache += new S()
			else
				misc_supply_cache += new S()
//hell mess for later
//INTENT: create little icons like in the fabs and the vending machines so you can see what you get/visual shorthand
/*
		//while we're here, why not pre-build all the icons
			//see if the datum has some stuff specified manually
			if (SP.icon && SP.iconstate)
				getItemIcon(initial(SP))
			//or if an item is specified or whatever
				else if (SP.representative_item)
					getItemIcon(initial(SP.representative_item))
			//otherwise pick the first thing in the list
					else if (SP && length(SP.contains) && SP.contains[1])
						var/obj/I = SP.contains[1]
						getItemIcon(I)
			//i will probably pick whatever the hell works

	//while we're here
	// pre-build all the icons for shit qm can order
	for (var/datum/supply_packs/SP as anything in concrete_typesof(/datum/supply_packs))
		getItemIcon(initial(SP))
		if (SP.item_outputs)
		var/icon_rsc = getItemIcon(A.item_outputs[1], C = usr.client)
		user << browse_rsc(browse_supply_pack_icons[icon_rsc], icon_rsc)
		icon_text = "<img class='icon' src='[icon_rsc]'>"

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
*/

//	QM_SupplierList["NanoTrasen"] = nanotrasen_supply_cache // redundo
	QM_SupplierList["Juicy Engineering"] = engineering_supply_cache
	QM_SupplierList["Construction Comrade"] = construction_supply_cache
	QM_SupplierList["Electronics Libre"] = electronics_supply_cache
	QM_SupplierList["Giuseppe's Italian Grocery & Massage"] = grocery_supply_cache
	QM_SupplierList["Hafgan Heavy Industries"] = heavy_supply_cache
	QM_SupplierList["Vendtech Vending"] = vending_supply_cache
	QM_SupplierList["ACAB Party Center"] = party_supply_cache
	QM_SupplierList["Odds & Ends"] = misc_supply_cache


//return info for different qm vendors
//use alone for friendly name
/proc/qm_vendor_info(var/vendor,var/info)
	if (!info)
		info = "name"
	else if (info != "name" && info != "desc" && info != "cache")
		return "error!!!!! fuick"
	switch(vendor)
		if ("nanotrasen")
			if (info == "name")
				return "Nanotrasen Corporate"
			if (info == "desc")
				return "Economic powerhouse of the Frontier and your (yes, you!) employer."
			if (info == "cache")
				return nanotrasen_supply_cache
		if ("engineering")
			if (info == "name")
				return "Juicy Engineering"
			if (info == "desc")
				return "Eclectic mechanical design shop. Safety not guaranteed."
			if (info == "cache")
				return engineering_supply_cache
		if ("construction")
			if (info == "name")
				return "Construction Comrade"
			if (info == "desc")
				return "Worker co-op construction supply and hardware depot."
			if (info == "cache")
				return construction_supply_cache
		if ("electronics")
			if (info == "name")
				return "Electronics Libre"
			if (info == "desc")
				return "High variety, low service electronics outlet."
			if (info == "cache")
				return electronics_supply_cache
		if ("grocery")
			if (info == "name")
				return "Giuseppe's Grocery"
			if (info == "desc")
				return "Friendly local neighborhood megasupermarket."
			if (info == "cache")
				return grocery_supply_cache
		if ("heavy")
			if (info == "name")
				return "Hafgan Heavy Industries"
			if (info == "desc")
				return "Long-running heavy manufacturing outfit, under contract with Nanotrasen."
			if (info == "cache")
				return heavy_supply_cache
		if ("vending")
			if (info == "name")
				return "Vend-tech"
			if (info == "desc")
				return "Vending machine servicing company, under contract with Nanotrasen."
			if (info == "cache")
				return vending_supply_cache
		if ("party")
			if (info == "name")
				return "All Celebrations Are Beautiful"
			if (info == "desc")
				return "Non-hierarchical party and bar supply store."
			if (info == "cache")
				return party_supply_cache
		if ("misc")
			if (info == "name")
				return "Odds & Ends"
			if (info == "desc")
				return "Pawn shop, takeout restaurant and pet store."
			if (info == "cache")
				return misc_supply_cache
		else
			return "Erorrrrrrr"

/datum/supply_order
	var/datum/supply_packs/object = null
	var/orderedby = null
	var/comment = null
	var/whos_id = null
	var/console_location = null

	proc/create(var/mob/orderer)
		var/obj/storage/S = object.create(orderer)

		if(!isnull(whos_id))
			S.name = "[S.name], Ordered by [whos_id:registered], [comment ? "([comment])":"" ]"
		else
			S.name = "[S.name] [comment ? "([comment])":"" ]"

		if(comment)
			S.delivery_destination = comment

		return S

//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: hidden packs only show up when the computer has been hacked.
//Todo: Shit is sold by a bunch of different people, and if you have a supply shuttle, you gotta do your ordering in related batches!
//If you don't want to or cannot wait, for a fee, non-NT traders will send a delivery (mass-drive from a passing ship that may or may not line up with your delivery port)
//In dockmap, these supply packs will be enumerated for counterside pickup
//Instant travel, but you gotta load it yourself.

ABSTRACT_TYPE(/datum/supply_packs)
/datum/supply_packs
	var/name = null
	var/desc = null
	var/contents = null //could I interpret the contains list? sure. will i? fuck no
	var/list/contains = list()
	//path here to an object that represents what this supply pack is
	var/representative_item = null //leave null to pull the first from contains list
	var/image = null //if you want to explicitly provide an image go ahead, this is mostly for placeholders
	var/icon = null //but for items, a specified icon and icon_state should take precedence over image
	var/icon_state = null //when refreshing item lists, look these up and store them in image and reference image from that point on
	var/amount = null
	var/cost = null
	var/containertype = null
	var/containername = null
	var/vendor = null //who's selling this (for order grouping, the shuttle can only go to one place at a time)
	var/vendor_name = null //the friendly name shown when referencing the vendor
	var/category = "Error Department - Call a Coder!" //for segmentation by page
	var/access = null
	var/hidden = 0	//So as it turns out this is used in construction mode hardyhar
	var/syndicate = 0 //If this is one the crate will only show up when the console is emagged
	var/id = 0 //What jobs can order it
	var/whos_id = null //linked ID

	proc/create(var/mob/creator)
		var/obj/storage/S
		if (!ispath(containertype) && contains.len > 1)
			containertype = text2path(containertype)
			if (!ispath(containertype))
				containertype = /obj/storage/crate // this did not need to be a string

		if (ispath(containertype))
#ifdef HALLOWEEN
			if (halloween_mode && prob(10))
				S = new /obj/storage/crate/haunted
			else
				S = new containertype
#else
			S = new containertype
#endif
			if (S)
				if (containername)
					S.name = containername

				if (access && istype(S))
					S.req_access = list()
					S.req_access += text2num(access)

				if (istype(S, /obj/storage) && prob(20)) //just to be safe
					new /obj/item/reagent_containers/food/snacks/silica_packet(S) //since these count as food you could sell em on to traders

		if (contains.len)
			for (var/B in contains)
				var/thepath = B
				if (!ispath(thepath))
					thepath = text2path(B)
					if (!ispath(thepath))
						continue

				var/amt = 1
				if (isnum(contains[B]))
					amt = abs(contains[B])

				for (amt, amt>0, amt--)
					var/atom/thething = new thepath(S)
					if (amount && isitem(thething))
						var/obj/item/I = thething
						I.amount = amount
		return S


//ABSTRACTed Categories Go Under Here

//NT Administrative - Because that's Priority #1
ABSTRACT_TYPE(/datum/supply_packs/nanotrasen)
/datum/supply_packs/nanotrasen
	category = "Administrative"
	vendor = "nanotrasen"
	vendor_name = "Nanotrasen Corporate"
	emptycrate
		name = "Empty Crate"
		desc = "Absolutely nothing, packed inside a crate. For reuse."
		icon = 'icons/obj/large_storage.dmi'
		icon_state = "closed"
		contents = "Nothing (crate only)"
		contains = list()
		cost = 10
		containertype = /obj/storage/crate
		containername = "crate"

	office
		name = "Office Supply Crate"
		desc = "Replenish your paperwork supplies. You are doing the paperwork, right?"
		contents = "x4 Paper Bins, x2 Clipboards, x1 Sticky Note Box, x5 Writing Implement Sets, x1 Stapler, x1 Scissors, x2 Canvas"
		contains = list(/obj/item/paper_bin = 4,
			/obj/item/clipboard = 2,
			/obj/item/item_box/postit,
			/obj/item/storage/box/pen,
			/obj/item/storage/box/marker/basic,
			/obj/item/storage/box/marker,
			/obj/item/storage/box/crayon/basic,
			/obj/item/storage/box/crayon,
			/obj/item/staple_gun/red,
			/obj/item/scissors,
			/obj/item/canvas = 2,
			/obj/item/stamp = 2)
		icon = 'icons/obj/items/writing.dmi'
		icon_state = "paper_bin1"
		image = null
		cost = 250
		containername = "Office Supply Crate"

	ID_gear
		name = "Identity Kit"
		desc = "For HOP use only. Certainly not for identity fraud."
		contents = "1x PDA box (x4 PDA, some software carts), 1x ID Kit"
		contains = list(/obj/item/storage/box/PDAbox,
						/obj/item/storage/box/id_kit)
		cost = 1500
		containertype = /obj/storage/secure/crate
		containername = "ID/PDA Kit"
		access = access_heads

	cloth_box
		name = "DIY Uniform Kit"
		desc = "Fiber supplies for HoP uniform manufacture."
		contents = "x5 sheets of cotton"
		contains = list(/obj/item/material_piece/cloth/cottonfabric = 5)
		cost = 1500
		containertype = /obj/storage/secure/crate
		containername = "Uniform Material Kit"
		access = access_heads

	janitor_starter
		name = "Janitorial Supplies"
		desc = "Initial supplies to outfit reinforcements against the scourge of station filth."
		contents = "x3 Buckets, x3 Mop, x3 Wet Floor Signs, x3 Cleaning Grenades, x1 Mop Bucket, x1 Rubber Gloves"
		contains = list(/obj/item/reagent_containers/glass/bucket = 3,
						/obj/item/mop = 3,
						/obj/item/caution = 3,
						/obj/item/chem_grenade/cleaner = 3,
						/obj/mopbucket,
						/obj/item/clothing/gloves/long)
		cost = 500
		containertype = /obj/storage/crate
		containername = "Janitorial Supplies"

	janitor_refill
		name = "Janitorial Supplies Refill"
		desc = "Janitor consumables and one-time use items that see a lot of use."
		contents = "4x Cleaner Grenades, 2x Cleaner-Filled Spray Bottle, 2x Jugs of Cleaner, 1x Trash Bags, 1x Biohazard Bags"
		contains = list(/obj/item/chem_grenade/cleaner = 4,
						/obj/item/spraybottle/cleaner = 2,
						/obj/item/reagent_containers/glass/bottle/cleaner = 2,
						/obj/item/storage/box/trash_bags,
						/obj/item/storage/box/biohazard_bags)
		cost = 500
		containertype = /obj/storage/crate/packing
		containername = "Janitorial Consumables"

//NT Emergency
ABSTRACT_TYPE(/datum/supply_packs/nanotrasen/emergency)
/datum/supply_packs/nanotrasen/emergency
	category = "Emergency"

	meteor
		name = "Meteor Shield System"
		desc = "It'll do in a pinch but your ship should really have it's own shields."
		contents = "x4 Meteor Shields"
		contains = list(/obj/machinery/shieldgenerator/meteorshield = 4)
		cost = 2500
		containertype = /obj/storage/crate/wooden
		containername = "Meteor Shield System"

	evacuation
		name = "Station Breach Equipment"
		desc = "Robotic repair and protection against the vacuum of space."
		contents = "x4 Floor Bot, x4 Gas Tanks, x4 Gas Mask, x4 Emergency Space Suit Set"
		contains = list(/obj/machinery/bot/floorbot = 4,
		/obj/item/clothing/mask/gas = 4,
		/obj/item/tank/emergency_oxygen = 2,
		/obj/item/tank/air = 2,
		/obj/item/clothing/head/emerg = 4,
		/obj/item/clothing/suit/space/emerg = 4)
		cost = 1500
		containertype = /obj/storage/crate/internals
		containername = "Station Breach Equipment"

	atmos
		name = "Atmospherics Supplies"
		desc = "For when you need to be breathing."
		contents = "x1 Air Tank, x1 Oxygen Tank, x2 Portable Scrubbers, 1x Atmos Tech Uniform"
		contains = list(/obj/item/tank/air,
						/obj/item/tank/oxygen,
						/obj/machinery/portable_atmospherics/scrubber = 2,
						/obj/item/clothing/under/misc/atmospheric_technician)
		cost = 8000
		containertype = /obj/storage/crate/wooden
		containername = "Atmospherics Supplies"

	firefighting
		name = "Firefighting Supplies Crate"
		desc = "Fire extinguishers and grenades and fire-resistant outerwear."
		contents = "x3 Extinguisher, x3 Firefighting Grenade, x2 Firesuit, x2 Firefighter Helmets"
		contains = list(/obj/item/extinguisher = 3,
		/obj/item/chem_grenade/firefighting = 3,
		/obj/item/clothing/suit/fire = 2,
		/obj/item/clothing/head/helmet/firefighter = 2)
		cost = 1000
		containertype = /obj/storage/crate
		containername = "Firefighting Supplies Crate"

	engineering_grenades
		name = "Breach Grenade Crate"
		desc = "Grenades for sealing breaches and replenishing minimum breathable atmosphere."
		contents = "4x Red Oxygen Grenades, x4 Metal Foam Grenades"
		contains = list(/obj/item/old_grenade/oxygen = 4, /obj/item/chem_grenade/metalfoam = 4)
		cost = 1200
		containertype = /obj/storage/crate
		containername = "Breach Grenade Crate"

	radiation_emergency
		name = "Radioactive Emergency Supplies"
		desc = "Equipment for dealing with a radioactive emergency. No, the crate itself is not radioactive."
		contents = "4x Complete Rad Suits, 2x Bottles Potassium Iodide, 4x Potassium Iodide Autoinjectors, 2x Geiger Counter"
		contains = list(/obj/item/clothing/suit/rad = 4,
						/obj/item/clothing/head/rad_hood = 4,
						/obj/item/storage/pill_bottle/antirad = 2,
						/obj/item/reagent_containers/emergency_injector/anti_rad = 4,
						/obj/item/device/geiger = 2)
		cost = 2000
		containertype = /obj/storage/crate/wooden
		containername = "Radiation Emergency Supplies"

	antisingularity
		name = "Anti-Singularity Pack"
		desc = "Everything that the crew needs to take down a rogue singularity."
		contents = "1x Singularity Busting Thingy, 5x Singularity Busting Thingy Bullets, 1x Instruction Pamphlet"
		contains = list(/obj/item/paper/antisingularity,/obj/item/ammo/bullets/antisingularity = 5,/obj/item/gun/kinetic/antisingularity)
		cost = 10000
		containertype = /obj/storage/crate/classcrate/qm
		containername = "Anti-Singularity Supply Pack"

	emergency_lighting
		name = "Emergency Lighting Crate"
		desc = "Flashlights and glowsticks, for visibility in low power environments and marking paths."
		contents = "x4 Flashlights, x2 Glowsticks Box (14 glowsticks total)"
		contains = list(/obj/item/device/light/flashlight = 4, /obj/item/storage/box/glowstickbox = 2)
		cost = 500
		containertype = /obj/storage/crate
		containername = "Emergency Glowsticks Crate - 4 pack"

//NT Security
ABSTRACT_TYPE(/datum/supply_packs/nanotrasen/security)
/datum/supply_packs/nanotrasen/security
	category = "Security"
	basic_gear
		name = "Armour Crate - Security Equipment (Cardlocked \[Security Equipment])"
		desc = "Everything a newly arrived or conscripted security officer needs to suffer less damage from being shot."
		contents = "1x Armoured Vest, 1x Helmet, x1 Handcuff Kit"
		contains = list(/obj/item/clothing/suit/armor/vest,
						/obj/item/clothing/head/helmet/hardhat/security,
						/obj/item/storage/box/handcuff_kit)
		cost = 6000
		containertype = /obj/storage/secure/crate/weapon
		containername = "Armour Crate - Security Equipment (Cardlocked \[Security Equipment])"
		access = access_securitylockers

	upgrade
		name = "Weapons Crate - Experimental Grenades (Cardlocked \[Security Equipment])"
		desc = "Some grenades that fell out of some kind of portal into our warehouse. Get them while supplies last."
		contents = "x1 Elite Security Helmet, x1 Lethal Grenade Kit, 1x Experimental Grenade Kit"
		contains = list(/obj/item/storage/box/QM_grenadekit_security,
						/obj/item/storage/box/QM_grenadekit_experimentalweapons,
						/obj/item/clothing/head/helmet/hardhat/security/improved)
		cost = 9000
		containertype = /obj/storage/secure/crate/weapon
		containername = "Weapons Crate - Experimental Grenades (Cardlocked \[Security Equipment])"
		access = access_securitylockers
		hidden = 1

	brig_resupply
		name = "Security Containment Crate - Security Equipment (Cardlocked \[Security Equipment])"
		desc = "Has your Port-a-Brig been stolen and/or run into the crusher, or do you have so much crime you need a second one? What are you even doing over there?"
		contents = "x1 Port-a-Brig and Remote"
		contains = list(/obj/machinery/port_a_brig,
						/obj/item/remote/porter/port_a_brig)
		cost = 1000
		containertype = /obj/storage/secure/crate/weapon
		containername = "Security Containment Crate - Security Equipment (Cardlocked \[Security Equipment])"
		access = access_securitylockers
		hidden = 1

	weapons2
		name = "Weapons Crate - Phasers (Cardlocked \[Security Equipment])"
		desc = "Some future space guns that fell out of some kind of portal into our warehouse. Get them while supplies last."
		contents = "x2 Phaser Gun"
		contains = list(/obj/item/gun/energy/phaser_gun = 2)
		cost = 5000
		containertype = /obj/storage/secure/crate/weapon
		containername = "Weapons Crate - Phasers (Cardlocked \[Security Equipment])"
		access = access_securitylockers
		hidden = 1

	antibio
		name = "Anti-Biological Hazard Supplies"
		desc = " A couple of tools for combatting rogue biological lifeforms."
		contents = "1x Complete and Loaded Flamethrower, 1x Flare Gun and Flares"
		category = "Security Department"
		contains = list(/obj/item/gun/flamethrower/assembled/loaded,
						/obj/item/storage/box/flaregun)
		cost = 7000
		containertype = /obj/storage/secure/crate
		containername = "Anti-Biological Hazard Supplies (Cardlocked \[Security Equipment])"
		access = access_securitylockers
		hidden = 1

	loyaltyimplant
		name = "Loyalty Kit"
		desc = "To ensure unflinching loyalty towards Nanotrasen."
		contents = "4x Loyalty Implants, 2x Implanters"
		category = "Security Department"
		contains = list(/obj/item/implantcase/antirev = 4,
						/obj/item/implanter = 2)
		cost = 6000
		containertype = /obj/storage/crate
		containername = "Loyalty Kit"
		access = access_security
		hidden = 1

//NT Medsci //split this up if there's ever enough science stuff to warrant
ABSTRACT_TYPE(/datum/supply_packs/nanotrasen/medsci)
/datum/supply_packs/nanotrasen/medsci
	category = "Medical/Research"

	chemical
		name = "Chemistry Resupply Crate"
		desc = "Various chemistry supplies, including reagent precursors that cannot easily be produced."
		contents = "x6 Reagent Bottles, x1 Beaker Box, x1 Mechanical Dropper, x1 Spectroscopic Goggles, x1 Reagent Scanner"
		contains = list(/obj/item/storage/box/beakerbox,
						/obj/item/reagent_containers/glass/bottle/oil,
						/obj/item/reagent_containers/glass/bottle/phenol,
						/obj/item/reagent_containers/glass/bottle/acid,
						/obj/item/reagent_containers/glass/bottle/acetone,
						/obj/item/reagent_containers/glass/bottle/diethylamine,
						/obj/item/reagent_containers/glass/bottle/ammonia,
						/obj/item/reagent_containers/dropper/mechanical,
						/obj/item/clothing/glasses/spectro,
						/obj/item/device/reagentscanner)
		cost = 500
		containertype = /obj/storage/secure/crate/plasma
		containername = "Chemistry Resupply Crate"

	firstaid
		name = "First Aid Crate"
		desc = "Medbay ransacked? Buy these to replenish your supplies, but know this: it will happen again."
		contents = "x10 Assorted First Aid Kits"
		contains = list(/obj/item/storage/firstaid/regular = 2,
						/obj/item/storage/firstaid/brute = 2,
						/obj/item/storage/firstaid/fire = 2,
						/obj/item/storage/firstaid/toxin = 2,
						/obj/item/storage/firstaid/oxygen,
						/obj/item/storage/firstaid/brain)
		cost = 1000
		containertype = /obj/storage/crate/medical
		containername = "First Aid Crate"

	chems
		name = "Medical Reservoir Crate"
		desc = "Bulk loose medicine and the means to apply it."
		contents = "x4 Assorted reservoir tanks, x2 Sedative bottles, x2 Hyposprays, x1 Auto-mender, x2 Brute Auto-mender Refill Cartridges, x2 Burn Auto-mender Refill Cartridges, x1 Syringe Kit"
		contains = list(/obj/item/reagent_containers/glass/beaker/large/antitox,
						/obj/item/reagent_containers/glass/beaker/large/epinephrine,
						/obj/item/reagent_containers/food/drinks/reserve/brute,
						/obj/item/reagent_containers/food/drinks/reserve/burn,
						/obj/item/reagent_containers/glass/bottle/morphine = 2,
						/obj/item/reagent_containers/mender,
						/obj/item/reagent_containers/mender_refill_cartridge/brute = 2,
						/obj/item/reagent_containers/mender_refill_cartridge/burn = 2,
						/obj/item/reagent_containers/hypospray = 2,
						/obj/item/storage/box/syringes)
		cost = 2300
		containertype = /obj/storage/crate/medical
		containername = "Medical Crate"

	bloodbags
		name = "Blood Bank"
		desc = "An emergency supply of blood."
		contents = "4x O- Blood IV Bag"
		contains = list (/obj/item/reagent_containers/iv_drip/blood = 4)
		cost = 3000
		containertype = /obj/storage/crate/medical
		containername = "Blood Bank"

	restricted_medicine
		name = "Restricted Medicine Shipment"
		desc = "A shipment of specialised medicines. Card-locked to medical access."
		contents = "2x Bottle of Perfluorodecalin, 1x each Bottle of Omnizine, Pentetic Acid, Haloperidol, Ether"
		contains = list(/obj/item/reagent_containers/glass/bottle/omnizine,
						/obj/item/reagent_containers/glass/bottle/pfd = 2,
						/obj/item/reagent_containers/glass/bottle/pentetic,
						/obj/item/reagent_containers/glass/bottle/haloperidol,
						/obj/item/reagent_containers/glass/bottle/ether)
		cost = 6000
		containertype = /obj/storage/secure/crate
		containername = "Restricted Medicine Shipment (Cardlocked \[Medical])"
		access = access_medical_director

	morgue
		name = "Morgue Supplies"
		desc = "The morgue can only fit so many clowns."
		contents = "10x Body Bags, 1x each Formaldehyde Bottle, Syringe, Bible"
		contains = list(/obj/item/body_bag = 10,
						/obj/item/reagent_containers/glass/bottle/formaldehyde,
						/obj/item/reagent_containers/syringe,
						/obj/item/storage/bible)
		cost = 10000
		containertype = /obj/storage/closet/coffin
		containername = "Morgue Supplies"

	monkey4
		name = "Lab Monkey Crate - 4 pack"
		desc = "You can never get enough of these delicious, self-table-flinging bastards. It's vegan,"
		contents = "x4 Monkey, x1 Monkey Translator"
		contains = list(/mob/living/carbon/human/npc/monkey = 4,
							/obj/item/clothing/mask/monkey_translator)
		cost = 2500
		containertype = /obj/storage/secure/crate/medical/monkey
		containername = "Lab Monkey Crate"
		hidden = 1
/*
//NT Research
ABSTRACT_TYPE(/datum/supply_packs/nanotrasen/research)
/datum/supply_packs/nanotrasen/research
	category = "NT Research"
*/

//Engineering - Also a juicer front
ABSTRACT_TYPE(/datum/supply_packs/engineering)
/datum/supply_packs/engineering
	category = "Engineering"
	vendor = "engineering"
	vendor_name = "Juicy Engineering"
	supplies
		name = "Mechanical Tools Crate"
		desc = "Some toolboxes, some welding masks, and some nerdy coats we hate and are throwing in to give you the best possible deal!"
		contents = "x2 Mechanical Toolbox, x2 Welding Mask, x2 Insulated Coat"
		contains = list(/obj/item/storage/toolbox/mechanical = 2,
						/obj/item/clothing/head/helmet/welding = 2,
						/obj/item/clothing/suit/wintercoat/engineering = 2)
		cost = 1000
		containertype = /obj/storage/crate
		containername = "Mechanical Tools Crate"

	electool
		name = "Electrical Tools Crate"
		desc = "Hey, remember when these will get rarer??? Me too thanks"
		contents = "x2 Electrical Toolbox, x2 Multi-Tool, x2 Insulated Gloves"
		contains = list(/obj/item/storage/toolbox/electrical = 2,
						/obj/item/device/multitool = 2,
						/obj/item/clothing/gloves/yellow = 2)
		cost = 2500
		containertype = /obj/storage/crate
		containername = "Electrical Tools Crate"

	electrical
		name = "Electrical Supplies Crate (red) - 2 pack"
		contents = "A whole load of cables, packed in a too-big crate."
		desc = "x2 Cabling Box (14 cable coils total)"
		contains = list(/obj/item/storage/box/cablesbox = 2)
		containername = "Electrical Supplies Crate - 2 pack"
		cost = 2000
		containertype = /obj/storage/crate

	toolbelts
		name = "Utility Belt Crate"
		desc = "Belts and tools to fill them to appease the staff assistant masses."
		contents = "2x Utility Belts, 2x Full Mechanical Toolboxes"
		contains = list(/obj/item/storage/belt/utility = 2,
						/obj/item/storage/toolbox/mechanical = 2)
		cost = 750
		containertype = /obj/storage/crate/packing
		containername = "Utility Belt Crate"

	reclaimer
		name = "Reclaimed Reclaimer"
		desc = "You wouldn't believe what you find in dumpsters these days, man."
		contents = "1x Portable Reclaimer"
		contains = list(/obj/machinery/portable_reclaimer)
		cost = 1000
		containertype = /obj/storage/crate/packing
		containername = "Reclaimed Reclaimer"

	eva
		name = "EVA Equipment Crate"
		desc = "Gear for enabling mobility in major hull damage scenarios."
		contents = "1x each of Complete Spacesuit, Emergency Gas Mask, Jetpack, Magboots"
		contains = list(/obj/item/clothing/head/helmet/space,
						/obj/item/clothing/suit/space,
						/obj/item/clothing/mask/gas/emergency,
						/obj/item/tank/jetpack,
						/obj/item/clothing/shoes/magnetic)
		cost = 5000
		containertype = /obj/storage/crate/wooden
		containername = "EVA Equipment Crate"

	fueltank
		name = "Welding Fuel Tank"
		desc = "Welding tools need lots of fuel, and we have it! Best stored in areas of high heat, chance of sparks, and assistant access."
		contents = "1x Welding Fuel Tank"
		contains = list(/obj/reagent_dispensers/fueltank)
		cost = 4000
		containertype = /obj/storage/crate
		containername = "Welding Tank crate"

	foamtank
		name = "Firefighting Foam tank"
		desc = "Fill up those empty extinguishers before the next fire breaks out!"
		contents = "1x Firefighting Foam Tank"
		contains = list(/obj/reagent_dispensers/foamtank)
		cost = 1000
		containertype = /obj/storage/crate
		containername = "Firefighting Foam crate"

	//will probably move canisters
	XL_air_canister
		name = "Extra Large Air Mix Canister"
		desc = "Spare canister filled with a mix of nitrogen, oxygen and minimal amounts of carbon dioxide. Used for emergency re-pressurisation efforts."
		contents = "1x High Capacity Air Canister"
		contains = list(/obj/machinery/portable_atmospherics/canister/air/large)
		cost = 5000
		containertype = /obj/storage/crate/wooden
		containername = "Spare XL Air Mix Canister Crate"

	oxygen_canister
		name = "Spare Oxygen Canister"
		desc = "Spare oxygen canister, for resupplying Engineering's fuel or refilling oxygen tanks."
		contents = "1x Standard Oxygen Canister"
		contains = list(/obj/machinery/portable_atmospherics/canister/oxygen)
		cost = 10000
		containertype = /obj/storage/crate/wooden
		containername = "Spare Oxygen Canister Crate"

//Construction and Tools - Also a Space Soviet front
//logo crossed hammer and RCD? not doing the fake cyrillic thing
ABSTRACT_TYPE(/datum/supply_packs/construction)
/datum/supply_packs/construction
	category = "Construction"
	vendor = "construction"
	vendor_name = "Construction Comrade"
	metal50
		name = "50 Metal Sheets"
		desc = "Metal sheets, for construction or repair."
		contents = "x50 Metal Sheets"
		contains = list(/obj/item/sheet/steel)
		amount = 50
		cost = 500
		containertype = /obj/storage/crate
		containername = "Metal Sheets Crate - 50 pack"

	metal200
		name = "200 Metal Sheets"
		desc = "Has the tin can you're living in been totally ruptured? We have you covered."
		contents = "x200 Metal Sheets"
		contains = list(/obj/item/sheet/steel)
		amount = 200
		cost = 2000
		containertype = /obj/storage/crate
		containername = "Metal Sheets Crate - 200 pack"

	glass50
		name = "50 Glass Sheets"
		desc = "Glass sheets, for construction or repair."
		contents = "x50 Glass Sheets"
		contains = list(/obj/item/sheet/glass)
		amount = 50
		cost = 500
		containertype = /obj/storage/crate
		containername = "Glass Sheets Crate - 50 pack"

	glass200
		name = "200 Glass Sheets"
		desc = "Got a lot of windows to fix in your glass house? We have you covered."
		contents = "x200 Glass Sheets"
		contains = list(/obj/item/sheet/glass)
		amount = 200
		cost = 2000
		containertype = /obj/storage/crate
		containername = "Glass Sheets Crate - 200 pack"

	paint
		name = "Paint Cans"
		desc = "A selection of random paints."
		contents = "4x Random Color Paint Cans"
		contains = list(/obj/item/paint_can/random = 4)
		cost = 1000
		containertype = /obj/storage/crate
		containername = "Paint Crate"

	mining
		name = "Mining Equipment"
		desc = "We may not be able to strike the earth any more, but asteroids and desert planets mine just fine."
		contents = "x1 Powered Pickaxe, x1 Power Hammer, x1 Optical Meson Scanner, x1 Geological Scanner, x2 Mining Satchel, x3 Mining Explosives"
		contains = list(/obj/item/mining_tool/power_pick,
						/obj/item/mining_tool/powerhammer,
						/obj/item/clothing/glasses/meson,
						/obj/item/oreprospector,
						/obj/item/satchel/mining = 2,
						/obj/item/breaching_charge/mining = 3)
		cost = 500
		containertype = /obj/storage/secure/crate/plasma
		containername = "Mining Equipment Crate"
		access = null
	rcd
		name = "Rapid-construction-device Replacement"
		desc = "Contains one empty rapid-construction-device."
		contents = "1x Rapid Construction Device (No Cartridge)"
		contains = list(/obj/item/rcd)
		cost = 60000
		containertype = /obj/storage/crate/wooden
		containername = "RCD Replacement"

	abcu
		name = "ABCU Unit Crate"
		desc = "An additional ABCU Unit, for large construction projects."
		contents = "1x ABCU and Blueprint Marker"
		contains = list(/obj/machinery/abcu, /obj/item/blueprint_marker)
		cost = 5000
		containertype = /obj/storage/secure/crate
		containername = "ABCU Unit Crate (Cardlocked \[Engineering])"
		access = access_engineering

	conworksupplies
		name = "Construction Equipment"
		desc = "The mothballed tools of our former Construction Workers, in a crate, for you!"
		contents = "construction stuff whatever"
		contains = list(/obj/item/lamp_manufacturer/organic,/obj/item/material_shaper,/obj/item/room_planner,/obj/item/clothing/under/rank/orangeoveralls)
		cost = 8000
		containertype = /obj/storage/secure/crate
		containername = "Construction Equipment (Cardlocked \[Engineering])"
		access = access_engineering

//Electronics - Also a FOSSyndie front
ABSTRACT_TYPE(/datum/supply_packs/electronics)
/datum/supply_packs/electronics
	category = "Electronics"
	vendor = "electronics"
	vendor_name = "Electronics Libre"

	powercell
		name = "Power Cell Crate"
		desc = "You'll have the power with these charged up and ready-to-use power cells!"
		contents = "x3 Power Cell"
		contains = list(/obj/item/cell/charged = 3)
		cost = 2500
		containertype = /obj/storage/crate
		containername = "Power Cell Crate"

	computer
		name = "Home Networking Kit"
		desc = "Build your own state of the art computer system! (Contents may vary.)"
		contents = "1x each stack of metal and glass, 3x cable coil, 1x motherboard, and assorted peripherals and boards."
		contains = list(/obj/item/sheet/glass/fullstack,
						/obj/item/sheet/steel/fullstack,
						/obj/item/cable_coil = 3,
						/obj/item/motherboard,
						/obj/random_item_spawner/peripherals,
						/obj/random_item_spawner/circuitboards)
		cost = 5000
		containertype = /obj/storage/crate/wooden
		containername = "Home Networking Kit"

	robot
		name = "Drone Crate"
		desc = "An assortment of single-minded drones? What a perfect addition to your station!"
		contents = "x1 Securitron, x1 Floorbot, x1 Cleanbot, x1 Medibot, x1 Firebot"
		contains = list(/obj/machinery/bot/secbot,
						/obj/machinery/bot/floorbot,
						/obj/machinery/bot/cleanbot,
						/obj/machinery/bot/medbot,
						/obj/machinery/bot/firebot)
		cost = 7500
		containertype = /obj/storage/crate
		containername = "Drone Crate"

	cyborg
		name = "Cyborg Component Crate"
		desc = "Build your very own walking science nightmare! (Brain not included.)"
		contents = "1x each of Robot Frame, Head (Sturdy), Chest, and 2x each Arm (Sturdy) and Leg"
		contains = list(/obj/item/parts/robot_parts/robot_frame,
						/obj/item/parts/robot_parts/head/sturdy,
						/obj/item/parts/robot_parts/chest,
						/obj/item/parts/robot_parts/arm/left/sturdy,
						/obj/item/parts/robot_parts/arm/right/sturdy,
						/obj/item/parts/robot_parts/leg/left,
						/obj/item/parts/robot_parts/leg/right,
						/obj/item/cable_coil)
		cost = 4500
		containertype = /obj/storage/crate/wooden
		containername = "Junior Medical Science Set: For Ages 7+"

	prosthetics
		name = "Prosthetic Augmentation Kit"
		desc = "Replace your feeble flesh with these mechanical substitutes."
		contents = "Assorted and random prosthetics."
		contains = list(/obj/random_item_spawner/prosthetics)
		cost = 2000
		containertype = /obj/storage/crate
		containername = "Prosthetic Augmentation Kit"

	buddy
		name = "Thinktronic Build Your Own Buddy Kit"
		desc = "Assemble your very own working Robuddy, one part per week."
		contents = "1x Robuddy Frame, 1x Robuddy Core, 1x Robuddy Tool Module 1x Power Cell, 1x Robot Arm"
		contains = list(/obj/item/guardbot_frame,
						/obj/item/guardbot_core,
						/obj/item/cell,
						/obj/item/parts/robot_parts/arm/right/sturdy,
						/obj/random_item_spawner/buddytool)
		cost = 7500
		containertype = /obj/storage/crate/wooden
		containername = "Robuddy Kit"

	specialops
		name = "GNU/Special Ops Supplies"
		desc = "If you are reading this, then we are authorized to ship you some additional assistance!"
		contents = "x1 Sleepy Pen, x1 Holographic Disguiser, x1 Signal Jammer, x1 Agent Card, x1 EMP Grenade Kit, x1 Tactical Grenades Kit"
		contains = list(/obj/item/card/id/syndicate,
						/obj/item/storage/box/emp_kit,
						/obj/item/storage/box/tactical_kit,
						/obj/item/pen/sleepypen,
						/obj/item/device/disguiser,
						/obj/item/radiojammer)
		cost = 80000
		containertype = /obj/storage/crate
		containername = "GNU/Special Ops Crate"
		syndicate = 1

//Grocery - Also an Italian front
ABSTRACT_TYPE(/datum/supply_packs/grocery)
/datum/supply_packs/grocery
	category = "Grocery"
	vendor = "grocery"
	vendor_name = "Giuseppe's Grocery"

	produce
		name = "Fresh Produce Crate"
		desc = "Assorted fruits and vegetables for the kitchen."
		contents = "x20 Assorted Cooking Ingredients"
		contains = list(/obj/item/reagent_containers/food/snacks/plant/apple = 2,
						/obj/item/reagent_containers/food/snacks/plant/banana = 2,
						/obj/item/reagent_containers/food/snacks/plant/carrot = 2,
						/obj/item/reagent_containers/food/snacks/plant/corn = 2,
						/obj/item/reagent_containers/food/snacks/plant/garlic = 1,
						/obj/item/reagent_containers/food/snacks/plant/lettuce = 2,
						/obj/item/reagent_containers/food/snacks/plant/tomato = 3,
						/obj/item/reagent_containers/food/snacks/plant/potato = 2,
						/obj/item/reagent_containers/food/snacks/plant/onion,
						/obj/item/reagent_containers/food/snacks/plant/lime,
						/obj/item/reagent_containers/food/snacks/plant/lemon,
						/obj/item/reagent_containers/food/snacks/plant/orange)
		cost = 1500
		containertype = /obj/storage/crate/freezer
		containername = "Fresh Produce Crate"

	meateggdairy
		name = "Meat, Eggs & Dairy Crate"
		desc = "Assorted proteins for the kitchen."
		contents = "x25 Assorted Cooking Ingredients"
		contains = list(/obj/item/reagent_containers/food/snacks/hotdog = 4,
						/obj/item/reagent_containers/food/snacks/ingredient/cheese = 4,
						/obj/item/reagent_containers/food/drinks/milk = 4,
						/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat = 3,
						/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat = 3,
						/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/salmon,
						/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/white,
						/obj/item/kitchen/food_box/egg_box = 3,
						/obj/item/storage/box/bacon_kit = 2)
		cost = 1500
		containertype = /obj/storage/crate/freezer
		containername = "Meat, Eggs & Dairy Crate"

	freshfish
		name = "'Fresh' Frozen Fish"
		desc = "Assorted not so fresh fish for the kitchen."
		contents = "x15 Assorted Frozen Fish"
		contains = list(/obj/item/fish/salmon = 4,
						/obj/item/fish/bass = 4,
						/obj/item/fish/carp = 5,
						/obj/item/fish/pufferfish = 2,
						/obj/item/raw_material/ice = 5)
		cost = 1000
		containertype = /obj/storage/crate/freezer
		containername = "Frozen Fish Crate"


	dryfoods
		name = "Dry Goods Crate"
		desc = "Dry goods like flour, sugar, pasta and oatmeal as bases for the kitchen."
		contents = "x25 Assorted Cooking Ingredients"
		contains = list(/obj/item/reagent_containers/food/snacks/ingredient/flour = 6,
						/obj/item/reagent_containers/food/snacks/ingredient/rice_sprig = 4,
						/obj/item/reagent_containers/food/snacks/ingredient/spaghetti = 3,
						/obj/item/reagent_containers/food/snacks/ingredient/sugar = 4,
						/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 3,
						/obj/item/reagent_containers/food/snacks/ingredient/tortilla = 3,
						/obj/item/reagent_containers/food/snacks/ingredient/pancake_batter = 2)
		cost = 750
		containertype = /obj/storage/crate/freezer
		containername = "Dry Goods Crate"

	condiment
		name = "Condiment Crate"
		desc = "Bulk pack of condiments and other ingredients."
		contents = "x25 Assorted Cooking Ingredients"
		contains = list(/obj/item/reagent_containers/food/snacks/condiment/chocchips = 3,
						/obj/item/reagent_containers/food/snacks/condiment/cream = 2,
						/obj/item/reagent_containers/food/snacks/condiment/custard,
						/obj/item/reagent_containers/food/snacks/condiment/hotsauce = 3,
						/obj/item/reagent_containers/food/snacks/condiment/ketchup = 4,
						/obj/item/reagent_containers/food/snacks/condiment/mayo = 4,
						/obj/item/reagent_containers/food/snacks/condiment/syrup = 3,
						/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 3,
						/obj/item/reagent_containers/food/snacks/ingredient/honey = 2)
		cost = 750
		containertype = /obj/storage/crate/freezer
		containername = "Condiment Crate"

	hydrostarter
		name = "Hydroponics: Starter Crate"
		desc = "Basic supplies for growing your own produce."
		contents = "x2 Watering Cans, x4 Compost Bags, x2 Weedkiller bottles, x2 Plant Analyzers, x4 Plant Trays"
		category = "Agriculture"
		contains = list(/obj/item/reagent_containers/glass/wateringcan = 2,
						/obj/item/reagent_containers/glass/compostbag = 4,
						/obj/item/reagent_containers/glass/bottle/weedkiller = 2,
						/obj/item/plantanalyzer = 2,
						/obj/machinery/plantpot = 4)
		cost = 500
		containertype = /obj/storage/crate
		containername = "Hydroponics: Starter Crate"

	hydronutrient
		name = "Hydroponics: Nutrient Pack"
		desc = "Assorted hydroponics formulae."
		contents = "x15 Nutrient Formulas"
		category = "Agriculture"
		contains = list(/obj/item/reagent_containers/glass/bottle/fruitful = 3,
						/obj/item/reagent_containers/glass/bottle/mutriant = 3,
						/obj/item/reagent_containers/glass/bottle/groboost = 3,
						/obj/item/reagent_containers/glass/bottle/topcrop = 3,
						/obj/item/reagent_containers/glass/bottle/powerplant = 3)
		cost = 1000
		containertype = /obj/storage/crate
		containername = "Hydroponics: Nutrient Crate"

	bee
		name = "Honey Production Kit"
		desc = "For use with existing hydroponics bay."
		contents = "5x Bee Egg Cartons"
		category = "Agriculture"
		contains = list(/obj/item/bee_egg_carton = 5)
		cost = 450
		containertype = /obj/storage/crate/bee
		containername = "Honey Production Kit"
		create(var/sp, var/mob/creator)
			var/obj/storage/secure/crate/bee/beez=..()
			for(var/obj/item/bee_egg_carton/carton in beez)
				carton.ourEgg.blog = "ordered by [key_name(creator)]|"
			return beez

	watertank
		name = "High Capacity Watertank"
		desc = "Pre-filled water tank for agricultural activity."
		contents = "1x High Capacity Watertank"
		category = "Agriculture"
		contains = list(/obj/reagent_dispensers/watertank/big)
		cost = 2500
		containertype = /obj/storage/crate
		containername = "High Capacity Watertank crate"

	compostbin
		name = "Compost Bin"
		desc = "Fertilizing compost bin. Not for use as an outhouse."
		contents = "1x Compost Bin"
		category = "Agriculture"
		contains = list(/obj/reagent_dispensers/compostbin)
		cost = 1000
		containertype = /obj/storage/crate
		containername = "Compost Bin crate"

//Hafgan Heavy Equipment - hi cogs (Space Quebecois Front)
ABSTRACT_TYPE(/datum/supply_packs/heavy_equipment)
/datum/supply_packs/heavy_equipment
	category = "Heavy Equipment"
	vendor = "heavy"
	vendor_name = "Hafgan Heavy Industries"

	mulebot
		name = "Replacement Mulebot"
		desc = "For bolstering logistics delivery capacity, or if you joyrode the last one into space and lost it."
		contents = "x1 Mulebot"
		contains = list("/obj/machinery/bot/mulebot")
		cost = 750
		containertype = /obj/storage/crate
		containername = "Replacement Mulebot Crate"

	generator
		name = "Experimental Local Generator"
		desc = "I think this thing wires into your grid and runs on plasma. For emergency backup use."
		contents = "x1 Experimental Local Generator"
		contains = list(/obj/machinery/power/lgenerator)
		cost = 2500
		containertype = /obj/storage/crate
		containername = "Experimental Local Generator Crate"

	singularity_generator
		name = "Singularity Generator Crate"
		desc = "An extremely unstable gravitational singularity, stored in a hi-tech jam jar, fired directly at your current location."
		contains = list(/obj/machinery/the_singularitygen)
		cost = 100000
		containertype = /obj/storage/secure/crate
		containername = "Singularity Generator Crate (Cardlocked \[Chief Engineer])"
		access = access_engineering_chief
		//hidden = 1

	field_generator
		name = "Field Generator Crate"
		desc = "The four goal-posts needed to contain a singularity."
		contents = "4x Field Generators"
		contains = list(/obj/machinery/field_generator = 4)
		cost = 40000
		containertype = /obj/storage/secure/crate
		containername = "Field Generator Crate (Cardlocked \[Engineering])"
		access = access_engineering
		//hidden = 1

	emitter
		name = "Emitter Crate"
		desc = "Contains one emitter, for energizing field generators. You'll need a few of these."
		contents = "1x Emitter"
		contains = list(/obj/machinery/emitter)
		cost = 15000
		containertype = /obj/storage/secure/crate
		containername = "Emitter Crate (Cardlocked \[Engineering])"
		access = access_engineering
		//hidden = 1

	rad_collector
		name = "Radiation Collector Crate"
		desc = "Four collector arrays and two controllers, to harvest radiation from the singularity."
		contents = "4x Collector Arrays, 2x Collector Control, 1x Soldering Iron (Courtesy Item)"
		contains = list(/obj/item/electronics/frame/collector_array = 4,
						/obj/item/electronics/frame/collector_control = 2,
						/obj/item/electronics/soldering)
		cost = 15000
		containertype = /obj/storage/secure/crate
		containername = "Radiation Array Crate (Cardlocked \[Engineering])"
		access = access_engineering
		//hidden = 1

	teg
		name = "Thermoelectric Generator Kit"
		desc = "A three-part kit for constructing your very own megawatt-output peltier device. Furnaces sold seperately."
		contents = "Thermoelectric Generator, Hot Gas Circulator, Cold Gas Circulator, Instructions (no charge)"
		contains = list(/obj/item/electronics/frame/teg,
					/obj/item/electronics/frame/hot_circ,
					/obj/item/electronics/frame/cold_circ,
					/obj/item/paper/teg_kit,
					/obj/item/electronics/soldering)
		cost = 15000
		containertype = /obj/storage/secure/crate
		containername = "Thermoelectric Generator Kit (Cardlocked \[Engineering])"
		access = access_engineering
		//hidden = 1 // doesnt actually work yet - warc
	teg_furnaces
		name = "Thermoelectric Furnace Pack"
		desc = "A set of three atmospheric furnaces for heating megawatt-class peltier devices."
		contents = "3x Thermoelectric Furnace Frame"
		contains = list(/obj/item/electronics/frame/teg_furnace,
					/obj/item/electronics/frame/teg_furnace,
					/obj/item/electronics/frame/teg_furnace)
		cost = 5000
		containertype = /obj/storage/crate
		containername = "Thermoelectric Furnace Pack"

//Vending machine servicing
//Kyle2143 originally
//Maybe split these the hell up + order one at a time??? Have you SEEN how big a vending machine is????
//For desc flavor consideration (do not move them out of here or put mechanical significance on who sells what beyond how it arrives)
//Vendtech services -Tech vending machines
//Giuseppi's services food and drink and kitchen
//Juicers do meat??? (through partnership with Giuseppi's)
//NT services Nano- (Med, Guns) and Pathology (also software)
//1312 services Bubs' Booze and Pizza (Italians would never)

//NOTE: Not actually in the Bonk-Tek Consortium (maybe)
ABSTRACT_TYPE(/datum/supply_packs/vending)
/datum/supply_packs/vending
	category = "Vending Services"
	vendor = "vending"
	vendor_name = "Vend-tech"

	restock
		name = "Necessities Vending Machine Restocking Pack"
		desc = "Various Vending Machine Restock Cartridges for necessities"
		contains = list(/obj/item/vending/restock_cartridge/coffee,
						/obj/item/vending/restock_cartridge/snack,
						/obj/item/vending/restock_cartridge/cigarette,
						/obj/item/vending/restock_cartridge/alcohol,
						/obj/item/vending/restock_cartridge/cola,
						/obj/item/vending/restock_cartridge/kitchen,
						/obj/item/vending/restock_cartridge/monkey,
						/obj/item/vending/restock_cartridge/standard,
						/obj/item/vending/restock_cartridge/capsule)
		cost = 3000
		containertype = /obj/storage/crate
		containername = "Necessities Vending Machine Restocking Pack"

	med_hydro //weird combo but whatev
		name = "Medical/Hydroponics Vending Machine Restocking Pack"
		desc = "Various Vending Machine Restock Cartridges for Med/Hydro"
		contains = list(/obj/item/vending/restock_cartridge/hydroponics,
						/obj/item/vending/restock_cartridge/medical,
						/obj/item/vending/restock_cartridge/medical_public,
						/obj/item/vending/restock_cartridge/kitchen)
		cost = 3000
		containertype = /obj/storage/crate
		containername = "Med/Hydro Vending Machine Restocking Pack"

	electronics
		name = "Electronics Vending Machine Restocking Pack"
		desc = "Various Vending Machine Restock Cartridges for electronics"
		contains = list(/obj/item/vending/restock_cartridge/electronics,
						/obj/item/vending/restock_cartridge/mechanics,
						/obj/item/vending/restock_cartridge/computer3,
						/obj/item/vending/restock_cartridge/floppy,
						/obj/item/vending/restock_cartridge/pda)
		cost = 4000
		containertype = /obj/storage/crate
		containername = "Electronics Vending Machine Restocking Pack"

	vending_restock
		name = "Security Vending Machine Restocking Pack"
		desc = "Various Vending Machine Restock Cartridges for security"
		contains = list(/obj/item/vending/restock_cartridge/security,
						/obj/item/vending/restock_cartridge/security_ammo)
		cost = 5000
		containertype = /obj/storage/crate
		containername = "Security Vending Machine Restocking Pack"

//Party & Bar equipment - Also an Anarchist front
ABSTRACT_TYPE(/datum/supply_packs/party)
/datum/supply_packs/party
	category = "Party & Bar Supplies"
	vendor = "party"
	vendor_name = "All Celebrations Are Beautiful"
	//all celebrations are beautiful :)))))

//seasonal party - listing these first
#ifdef HALLOWEEN
	halloween
		name = "Spooky Crate"
		desc = "WHAT COULD IT BE? SPOOKY GHOSTS?? TERRIFYING SKELETONS??? DARE YOU FIND OUT?!"
		contains = list(/obj/item/storage/goodybag = 6)
		cost = 250
		containertype = /obj/storage/crate
		containername = "Spooky Crate"
#endif

#ifdef XMAS
	xmas
		name = "Holiday Supplies"
		desc = "Winter joys from the workshop of Santa Claus himself! (Amusing Trivia: Santa Claus does not infact exist.)"
		contains = list(/obj/item/clothing/head/helmet/space/santahat = 3,
						/obj/item/wrapping_paper/xmas = 2,
						/obj/item/scissors,
						/obj/item/reagent_containers/food/drinks/eggnog = 2,
						/obj/item/a_gift/festive = 2)
		cost = 500
		containertype = /obj/storage/crate/xmas
		containername = "Holiday Supplies"
#endif

	supplies
		name = "Party Supplies"
		desc = "Perfect for celebrating any special occasion!"
		contains = list(/obj/item/clothing/head/party/birthday = 1,
						/obj/item/clothing/head/party/birthday/blue = 1,
						/obj/item/clothing/head/party/random = 5,
						/obj/item/wrapping_paper = 2,
						/obj/item/scissors,
						/obj/item/item_box/assorted/stickers,
						/obj/item/storage/box/balloonbox = 2,
						/obj/item/reagent_containers/food/drinks/duo = 6,
						/obj/item/reagent_containers/food/drinks/bottle/beer = 6,
						/obj/item/reagent_containers/food/snacks/cake/chocolate/gateau = 1)
		cost = 750
		containertype = /obj/storage/crate
		containername = "Party Supplies"

	alcohol
		name = "Alcohol Resupply Crate"
		desc = "A collection of nine assorted liquors in case of stationwide alcohol deficiency"
		contains = list(/obj/item/storage/box/beer,
						/obj/item/reagent_containers/food/drinks/bottle/beer,
						/obj/item/reagent_containers/food/drinks/bottle/wine,
						/obj/item/reagent_containers/food/drinks/bottle/mead,
						/obj/item/reagent_containers/food/drinks/bottle/cider,
						/obj/item/reagent_containers/food/drinks/bottle/rum,
						/obj/item/reagent_containers/food/drinks/bottle/vodka,
						/obj/item/reagent_containers/food/drinks/bottle/tequila,
						/obj/item/reagent_containers/food/drinks/bottle/bojackson,
						/obj/item/reagent_containers/food/drinks/curacao)
		cost = 400
		containertype = /obj/storage/crate
		containername = "Alcohol Crate"

	cocktail
		name = "Cocktail Party Supplies"
		desc = "All the equipment you need to be the next up and coming amateur mixologist."
		contains = list(/obj/item/reagent_containers/food/drinks/cocktailshaker,
						/obj/item/storage/box/cocktail_umbrellas = 2,
						/obj/item/storage/box/cocktail_doodads = 2,
						/obj/item/storage/box/fruit_wedges = 1,
						/obj/item/shaker/salt = 1)
		cost = 100
		containertype = /obj/storage/crate
		containername = "Cocktail Party Supplies"

	microbrew
		name = "Home Distillery Kit"
		desc = "Turn Cargo into a microbrewery."
		contains = list(/obj/reagent_dispensers/still,
						/obj/item/reagent_containers/food/drinks/drinkingglass/pitcher = 2,
						/obj/item/reagent_containers/food/drinks/bottle/soda = 6)
		cost = 5000
		containertype = /obj/storage/crate/wooden
		containername = "Home Distillery Kit"
		hidden = 1

	dressup
		name = "Novelty Clothing Crate"
		desc = "Assorted Novelty Clothing"
		contains = list(/obj/random_item_spawner/dressup)
		cost = 15000
		containertype = /obj/storage/crate/packing
		containername = "Novelty Clothing Crate"
		hidden = 1

	clown
		name = "Comedy Equipment"
		desc = "Entertainers burn bright but die young, outfit a new one with this crate!"
		contains = list(
			/obj/item/storage/box/costume/clown/recycled,
			/obj/item/instrument/bikehorn,
			/obj/item/bananapeel,
			/obj/item/reagent_containers/food/snacks/pie/cream,
			/obj/item/storage/box/balloonbox,
		)
		cost = 500
		containertype = /obj/storage/crate/packing
		containername = "Comedy Equipment"

	glowsticksassorted
		name = "Assorted Glowsticks Crate - 4 pack"
		desc = "Everything you need for your very own DIY rave!"
		contains = list(/obj/item/storage/box/glowstickbox/assorted = 4)
		cost = 600
		containertype = /obj/storage/crate
		containername = "Assorted Glowsticks Crate - 4 pack"
		hidden = 1

	neon_lining
		name = "Neon Lining Crate"
		desc = "For intellectuals that value the aesthetic of the past."
		contains = list(/obj/item/neon_lining/shipped, /obj/item/paper/neonlining)
		cost = 2000
		containertype = /obj/storage/crate
		containername = "Neon Lining Crate"
		hidden = 1

	sponge
		name = "Sponge Capsule Crate"
		desc = "For all your watery animal needs!"
		contains = list(/obj/item/spongecaps = 4)
		cost = 5000
		containertype = /obj/storage/crate/packing
		containername = "Sponge Capsule Crate"
		hidden = 1

	candy
		name = "Candy Crate"
		desc = "Proudly bringing sugar comas to your space stations since 2k53."
		contains = list(/obj/item/item_box/heartcandy,
						/obj/item/storage/goodybag,
						/obj/item/item_box/swedish_bag,
						/obj/item/kitchen/peach_rings)
		cost = 500
		containertype = /obj/storage/crate
		containername = "Candy Crate"
		hidden = 1

	candle
		name = "Candle Crate"
		desc = "Perfect for setting the mood."
		contains = list(/obj/item/device/light/candle = 3,
						/obj/item/device/light/candle/small = 6,
						/obj/item/matchbook)
		cost = 500
		containertype = /obj/storage/crate/packing
		containername = "Candle Crate"
		hidden = 1

//Furniture? (Space Swedish Front???????? just kidding)
//hidden for now
ABSTRACT_TYPE(/datum/supply_packs/furniture)
/datum/supply_packs/furniture
	category = "Furniture"
	hidden = 1

	assorted
		name = "Furnishings Crate"
		desc = "An assortment of flat-packed furniture, designed in Space Sweden."
		contains = list(/obj/random_item_spawner/furniture_parts)
		cost = 1500
		containertype = /obj/storage/crate/wooden
		containername = "Furnishings Crate"

	eventtablered
		name = "Red Event Table Crate"
		desc = "A flat-packed set of tables, each with a fancy red tablecloth."
		contains = list(/obj/item/furniture_parts/table/clothred = 5)
		cost = 25000
		containername = "Red Event Table Crate"

	regal
		name = "Regal Furnishings Crate"
		desc = "A set of very fancy flat-packed, regal furniture."
		contains = list(/obj/item/furniture_parts/wood_chair/regal = 4,
						/obj/item/furniture_parts/table/regal = 4,
						/obj/item/furniture_parts/decor/regallamp = 2)
		cost = 80000
		containername = "Regal Furnishings Crate"

	furniture_throne
		name = "Golden Throne"
		desc = "A flat-packed throne. It can't be real gold for that price..."
		contains = list(/obj/item/furniture_parts/throne_gold)
		cost = 150000 //jfc
		containertype = /obj/storage/crate/wooden
		containername = "Throne Crate"

//Clothing
//hidden for now
ABSTRACT_TYPE(/datum/supply_packs/clothing)
/datum/supply_packs/clothing
	category = "Clothing"
	hidden = 1

	hat
		name = "Haberdasher's Crate"
		desc = "A veritable smörgåsbord of head ornaments."
		contains = list(/obj/random_item_spawner/hat)
		cost = 5000
		containertype = /obj/storage/crate/packing
		containername = "Haberdasher's Crate"


	winter
		name = "Cold Weather Gear"
		desc = "Warm winter gear to ward off the winter chills."
		contains = list(/obj/item/clothing/suit/wintercoat = 5,
						/obj/machinery/space_heater = 2,
						/obj/item/reagent_containers/food/drinks/chickensoup = 2,
						/obj/item/reagent_containers/food/drinks/coffee = 2)
		cost = 3000
		containertype = /obj/storage/crate/packing
		containername = "Cold Weather Gear"

	headbands
		name = "Bargain Bows & Bands Box"
		desc = "Headbands for all occasions."
		cost = 2000
		contains = list(//obj/item/clothing/head/headband/giraffe = 1,
						/obj/item/clothing/head/headband/antlers = 1,
						/obj/item/clothing/head/headband/nyan/tiger = 1,
						/obj/item/clothing/head/headband/nyan/leopard = 1,
						/obj/item/clothing/head/headband/nyan/snowleopard = 1,
						//obj/item/clothing/head/headband/bee = 2,
						/obj/item/clothing/head/headband/nyan/random = 1)

	mask
		name = "Masquerade Crate"
		desc = "For hosting a masked ball in the bar."
		contains = list(/obj/random_item_spawner/mask)
		cost = 5000
		containertype = /obj/storage/crate/packing
		containername = "Masquerade Crate"

	shoe
		name = "Shoe Crate"
		desc = "Has an unruly staff assistant stolen all your shoes?"
		contains = list(/obj/random_item_spawner/shoe)
		cost = 2000
		containertype = /obj/storage/crate/packing
		containername = "Shoe Crate"

//Stationary/Printing
//hidden for now
ABSTRACT_TYPE(/datum/supply_packs/stationary)
/datum/supply_packs/stationary
	category = "Stationary"
	hidden = 1

	bureaucrat
		name = "Bureaucracy Supply Crate"
		desc = "x2 Paper bins, x2 Folders, x2 Pencils, x2 Pens, x2 Stamps, x1 Fancy Pen"
		contains = list(/obj/item/paper_bin,
						/obj/item/paper_bin,
						/obj/item/folder,
						/obj/item/folder,
						/obj/item/pen/pencil,
						/obj/item/pen/pencil,
						/obj/item/pen,
						/obj/item/pen,
						/obj/item/stamp,
						/obj/item/stamp,
						/obj/item/pen/fancy)
		cost = 1500
		containertype = /obj/storage/crate
		containername = "Bureaucracy Supply Crate"


	ink_refill
		name = "Printing Press Refill Supplies"
		desc = "x1 Ink Cartridge, x2 Paper Bin"
		category = "Civilian Department"
		contains = list(/obj/item/press_upgrade/ink,
						/obj/item/paper_bin,
						/obj/item/paper_bin)
		cost = 2500 //theres a monopoly on space ink!
		containertype = /obj/storage/crate/packing
		containername = "Printing Press Refill Crate"

	ink_upgrade
		name = "Printing Press Colour Module"
		desc = "x1 Ink Color Upgrade"
		category = "Civilian Department"
		contains = list(/obj/item/press_upgrade/colors)
		cost = 2000 //colour ink is expensive yo
		containertype = /obj/storage/crate/packing
		containername = "Printing Press Colour Crate"

	custom_books
		name = "Printing Press Custom Cover Module"
		desc = "x1 Custom Cover Upgrade"
		category = "Stationary"
		contains = list(/obj/item/press_upgrade/books)
		cost = 2000
		containertype = /obj/storage/crate/packing
		containername = "Printing Press Cover Crate"

	printing_press
		name = "Printing Press"
		desc = "x1 Printing Press Frame"
		category = "Stationary"
		contains = list(/obj/item/electronics/frame/press_frame,
						/obj/item/paper/press_warning)
		cost = 5000
		containertype = /obj/storage/crate/wooden
		containername = "Printing Press Crate"

//Misc Stuff
//hidden for now
ABSTRACT_TYPE(/datum/supply_packs/misc)
/datum/supply_packs/misc
	category = "Pawn Shop, Pet Store & Takeout"
	vendor = "misc"
	vendor_name = "Odds & Ends"

	percussion_band_kit
		name = "Percussion Band Kit"
		desc = "1x Tambourine, 1x Cowbell, 1x Triangle"
		cost = 2000
		containername = "Percussion Band Kit"
		contains = list(/obj/item/instrument/tambourine,/obj/item/instrument/triangle,/obj/item/instrument/cowbell)
		containertype = /obj/storage/crate/wooden

	kendo
		name = "Kendo Crate"
		desc = "A crate containing two full sets of kendo equipment."
		contains = list(/obj/item/clothing/head/helmet/men = 2,
						/obj/item/clothing/suit/armor/douandtare = 2,
						/obj/item/clothing/gloves/kote = 2,
						/obj/item/shinai_bag,
						/obj/item/storage/box/kendo_box/hakama)
		cost = 5000
		containertype = /obj/storage/crate/wooden
		containername = "Kendo Crate"

	birds
		name = "Avian Import Kit"
		desc = "x5 hand-reared birds to help brighten your workplace."
		category = "Civilian Department"
		contains = list(/obj/critter/parrot/random = 5)
		cost = 2000
		containertype = /obj/storage/crate/packing
		containername = "Avian Import Kit"

	animal
		name = "Animal Import Kit"
		desc = "A random pile of animals."
		category = "Civilian Department"
		contains = list (/obj/random_item_spawner/critter)
		cost = 2000
		containertype = /obj/storage/crate/packing
		containername = "Animal Import Kit"

	takeout_chinese
		name = "Golden Gannet Delivery"
		desc = "A Space Chinese meal for two, delivered galaxy-wide."
		category = "Civilian Department"
		contains = list(/obj/item/reagent_containers/food/snacks/takeout = 2,
						/obj/item/reagent_containers/food/snacks/fortune_cookie = 2,
						/obj/item/kitchen/chopsticks_package = 2)
		cost = 200
		containertype = /obj/storage/crate/packing
		containername = "Golden Gannet Delivery"

	takeout_pizza
		name = "Soft Soft Pizzeria Delivery"
		desc = "Two fresh-baked pizza meals, straight from the oven to your airlock."
		category = "Civilian Department"
		contains = list(/obj/item/reagent_containers/food/snacks/pizza = 2,
						/obj/item/reagent_containers/food/snacks/fries = 2,
						/obj/item/reagent_containers/food/drinks/cola = 2)
		cost = 200
		containertype = /obj/storage/crate/pizza
		containername = "Soft Soft Pizza Delivery"

/* ================================================= */
/* ---------- Construction Mode Apparently --------- */
/* ================================================= */

//Probably not going to be used

ABSTRACT_TYPE(/datum/supply_packs/constructionmode)
/datum/supply_packs/constructionmode
	hidden = 1

	banking_kit
		name = "Banking Kit"
		desc = "Circuit Boards: 1x Bank Records, 1x ATM"
		contains = list(/obj/item/circuitboard/atm,
						/obj/item/circuitboard/bank_data)
		cost = 10000
		containertype = /obj/storage/crate
		containername = "Banking Kit"

	homing_kit
		name = "Homing Kit"
		desc = "3x Tracking Beacon"
		cost = 1000
		contains = list(/obj/item/device/radio/beacon = 3)
		containertype = /obj/storage/crate
		containername = "Homing Kit"

	id_computer
		name = "ID Computer Circuitboard"
		desc = "1x ID Computer Circuitboard"
		contains = list(/obj/item/circuitboard/card)
		cost = 10000

	administrative_id
		name = "Administrative ID card"
		desc = "1x Captain level ID"
		contains = list(/obj/item/card/id/captains_spare)
		cost = 2500
		hidden = 1
		containertype = null
		containername = null

	plasmastone
		name = "Plasmastone"
		desc = "1x Plasmastone"
		contains = list(/obj/item/raw_material/plasmastone)
		cost = 7000
		containertype = null
		containername = null

	baton
		name = "Stun Baton"
		desc = "1x Stun Baton"
		contains = list(/obj/item/baton)
		cost = 3000
		containertype = null
		containername = null

	telecrystal
		name = "Telecrystal"
		desc = "1x Telecrystal"
		contains = list(/obj/item/raw_material/telecrystal)
		cost = 7000
		containertype = null
		containername = null

	telecrystal_bulk
		name = "Telecrystal Resupply Pack"
		desc = "10x Telecrystal"
		contains = list(/obj/item/raw_material/telecrystal = 10)
		cost = 63000
		containertype = /obj/storage/crate
		containername = "Telecrystal Resupply Pack"

/* ================================================= */
/* ------------- Complex Supply Drops -------------- */
/* ------------ At The Bottom Of Every ------------- */
/* ------------------- Category -------------------- */
/* ================================================= */

//none of these are really useful right now so they're hidden

ABSTRACT_TYPE(/datum/supply_packs/complex)
/datum/supply_packs/complex
	hidden = 0
	category = "Heavy Equipment"
	var/list/blueprints = list()
	var/list/frames = list()

	create(var/spawnpoint,var/mob/creator)
		var/atom/movable/A = ..()
		if (!A)
			// TODO: spawn a new crate instead of just returning?
			return

		for (var/path in blueprints)
			if (!ispath(path))
				path = text2path(path)
				if (!ispath(path))
					continue

			var/amt = 1
			if (isnum(blueprints[path]))
				amt = abs(blueprints[path])

			for (amt, amt>0, amt--)
				new /obj/item/paper/manufacturer_blueprint(A, path)

		for (var/path in frames)
			if (!ispath(path))
				path = text2path(path)
				if (!ispath(path))
					continue

			var/amt = 1
			if (isnum(frames[path]))
				amt = abs(frames[path])

			var/atom/template = path
			var/template_name = initial(template.name)
			if (!template_name)
				continue

			for (amt, amt>0, amt--)
				var/obj/item/electronics/frame/F = new /obj/item/electronics/frame(A)
				F.name = "[template_name] frame"
				F.store_type = path
				F.viewstat = 2
				F.secured = 2
				F.icon_state = "dbox"

		return A

	//General Heavy Equipment
	basic_power
		name = "Basic Power Kit"
		desc = "Frames: 1x SMES cell, 2x Furnace"
		category = "Hafgan Heavy Industries"
		frames = list(/obj/smes_spawner,
						/obj/machinery/power/furnace = 2)
		cost = 20000
		containertype = /obj/storage/crate
		containername = "Power Kit"
		hidden = 1

#ifndef UNDERWATER_MAP
	mini_magnet
		name = "Small Magnet Kit"
		desc = "1x Magnetizer, 1x Low Performance Magnet Kit, 1x Magnet Chassis Frame"
		category = "Hafgan Heavy Industries"
		contains = list(/obj/item/magnetizer,
						/obj/item/magnet_parts/construction/small)
		frames = list(/obj/machinery/magnet_chassis,
						/obj/machinery/computer/magnet)
		cost = 10000
		containertype = /obj/storage/crate
		containername = "Small Magnet Kit"
		hidden = 1

	magnet
		name = "Magnet Kit"
		desc = "1x Magnetizer, 1x High Performance Magnet Kit, 1x Magnet Chassis Frame"
		category = "Hafgan Heavy Industries"
		contains = list(/obj/item/magnetizer,
						/obj/item/magnet_parts/construction)
		frames = list(/obj/machinery/magnet_chassis,
						/obj/machinery/computer/magnet)
		cost = 75000
		containertype = /obj/storage/crate
		containername = "Magnet Kit"
		hidden = 1
#endif

	//NT Security
	security_camera
		name = "Security Camera kit"
		desc = "Frames: 5x Security Camera"
		category = "NT Security"
		frames = list(/obj/machinery/camera = 5)
		cost = 1000
		hidden = 1
		containertype = /obj/storage/crate
		containername = "Security Camera"

	turret
		name = "Defense Turret Kit"
		desc = "Frames: 3x Turret, 1x Turret Control Console, 2x Security Camera"
		category = "NT Security"
		frames = list(/obj/machinery/turret/construction = 3,
						/obj/machinery/turretid/computer,
						/obj/machinery/camera = 2)
		cost = 40000
		hidden = 1
		containertype = /obj/storage/crate
		containername = "Defense Turret Kit"

	//Construction
	toilet
		name = "Bathroom Kit"
		desc = "Frames: 4x Toilet, 1x Sink, 1x Shower Head, 1x Bathtub"
		category = "Construction"
		frames = list(/obj/item/storage/toilet = 4,
						/obj/machinery/shower,
						/obj/machinery/bathtub,
						/obj/submachine/chef_sink/chem_sink)
		cost = 15000
		containertype = /obj/storage/crate
		containername = "Bathroom Kit"
		hidden = 1

	//Grocery
	kitchen
		name = "Kitchen Kit"
		desc = "1x Fridge, Frames: 1x Oven, 1x Mixer, 1x Sink, 1x Deep Fryer, 1x Food Processor, 1x ValuChimp, 1x FoodTech, 1x Meat Spike, 1x Gibber"
		category = "Grocery"
		contains = list(/obj/storage/secure/closet/fridge)
		frames = list(/obj/submachine/chef_oven,
						/obj/submachine/mixer,
						/obj/submachine/chef_sink,
						/obj/machinery/deep_fryer,
						/obj/submachine/foodprocessor,
						/obj/machinery/vending/monkey,
						/obj/machinery/vending/kitchen,
						/obj/kitchenspike,
						/obj/machinery/gibber)
		cost = 50000
		containertype = /obj/storage/crate
		containername = "Kitchen Kit"
		hidden = 1

	//Party
	bartender
		name = "Bar Kit"
		desc = "2x Glassware box, Frames: 1x Alcohol Dispenser, 1x Soda Fountain, 1x Ice Cream Machine, 1x Kitchenware Recycler, 1x Microwave"
		category = "Party"
		contains = list(/obj/item/storage/box/glassbox = 2)
		frames = list(/obj/machinery/microwave,
						/obj/machinery/chem_dispenser/alcohol,
						/obj/machinery/chem_dispenser/soda,
						/obj/submachine/ice_cream_dispenser,
						/obj/machinery/glass_recycler)
		cost = 25000
		containertype = /obj/storage/crate
		containername = "Bar Kit"
		hidden = 1

	glass_recycler
		name = "Glass Recycler"
		desc = "x1 Kitchenware Recycler, a tabletop machine allowing you to recycle reclaimed glass into many different types of glassware"
		contains = list(/obj/item/electronics/soldering)
		frames = list(/obj/machinery/glass_recycler)
		cost = 3000
		containertype =/obj/storage/crate
		containername = "Recycling Initiative Crate"
		hidden = 1

	//Electronics
	arcade
		name = "Arcade Machine"
		desc = "Frames: 1x Arcade Machine"
		category = "Electronics"
		frames = list(/obj/machinery/computer/arcade)
		cost = 2500
		containertype = /obj/storage/crate
		containername = "Arcade Machine"
		hidden = 1

//Big Nanotrasen Proprietary Items
ABSTRACT_TYPE(/datum/supply_packs/complex/nanotrasen/)
/datum/supply_packs/complex/nanotrasen/
	category = "NT Proprietary"

	manufacturer
		name = "Manufacturer Kit"
		desc = "Frames: 1x General Manufacturer, 1x Mining Manufacturer, 1x Gas Extractor, 1x Clothing Manufacturer, 1x Reclaimer"

		frames = list(/obj/machinery/manufacturer/general,
						/obj/machinery/manufacturer/mining,
						/obj/machinery/manufacturer/gas,
						/obj/machinery/manufacturer/uniform,
						/obj/machinery/portable_reclaimer)
		cost = 8000
		containertype = /obj/storage/crate
		containername = "Manufacturer Kit"
		hidden = 1

	cargo
		name = "Cargo Bay Kit"
		desc = "Contains a higher tier of cargo computer, allowed access to the full NT catalog.<br>1x Cargo Teleporter, Frames: 1x Commerce Computer, 1x Incoming supply pad, 1x Outgoing supply pad, 1x Cargo Teleporter pad, 1x Recharger"
		hidden = 1
		category = "Nanotrasen - Proprietary"
		contains = list(/obj/item/paper/cargo_instructions,
						/obj/item/cargotele)
		frames = list(/obj/machinery/computer/special_supply/commerce,
						/obj/supply_pad/incoming,
						/obj/supply_pad/outgoing,
						/obj/submachine/cargopad,
						/obj/machinery/recharger)
		cost = 45000
		containertype = /obj/storage/crate
		containername = "Cargo Bay Kit"
		hidden = 1

	pod_kit
		name = "Pod Production Kit"
		desc = "Frames: 1x Ship Component Fabricator, 1x Reclaimer"
		category = "Nanotrasen - Proprietary"
		frames = list(/obj/machinery/manufacturer/hangar,
						/obj/machinery/portable_reclaimer)
		cost = 5000
		containertype = /obj/storage/crate
		containername = "Pod Production Kit"
		hidden = 1

	mainframe_kit
		name = "Computer Core Kit"
		desc = "1x Memory Board, 1x Mainframe Recovery Kit, 1x TermOS B disk, Frames: 1x Computer Mainframe, 1x Databank, 1x Network Radio, 3x Data Terminal, 1x CompTech"
		category = "Nanotrasen - Proprietary"
		contains = list(/obj/item/disk/data/memcard,
						/obj/item/storage/box/zeta_boot_kit,
						/obj/item/disk/data/floppy/read_only/terminal_os)
		frames = list(/obj/machinery/networked/mainframe,
						/obj/machinery/networked/storage,
						/obj/machinery/networked/radio,
						/obj/machinery/power/data_terminal = 3,
						/obj/machinery/vending/computer3)
		cost = 150000
		hidden = 1
		containertype = /obj/storage/crate
		containername = "Computer Core Kit"
		hidden = 1

	ai_kit
		name = "Artificial Intelligence Kit"
		desc = "Frames: 1x Asimov 5 AI, 2x Turret, 1x Turret Control Console, 2x Security Camera"
		category = "Nanotrasen - Proprietary"
		frames = list(/obj/ai_frame,
						/obj/machinery/turret/construction = 2,
						/obj/machinery/turretid/computer,
						/obj/machinery/camera = 2)
		cost = 100000
		hidden = 1
		containertype = /obj/storage/crate
		containername = "AI Kit"
		hidden = 1

	telescience
		name = "Telescience Kit"
		desc = "Frames: 1x Science Teleporter Console, 2x Data Terminal, 1x Telepad"
		category = "Nanotrasen - Proprietary"
		frames = list(/obj/machinery/networked/teleconsole,
						/obj/machinery/networked/telepad,
						/obj/machinery/power/data_terminal = 2)
		cost = 40000
		hidden = 1
		containertype = /obj/storage/crate
		containername = "Telescience"
		hidden = 1

	artlab
		name = "Artifact Research Kit"
		desc = "Frames: 5x Data Terminal, 1x Pitcher, 1x Impact pad, 1x Heater pad, 1x Electric box, 1x X-Ray machine"
		category = "Nanotrasen - Proprietary"
		frames = list(/obj/machinery/networked/test_apparatus/pitching_machine,
						/obj/machinery/networked/test_apparatus/impact_pad,
						/obj/machinery/networked/test_apparatus/electrobox,
						/obj/machinery/networked/test_apparatus/heater,
						/obj/machinery/networked/test_apparatus/xraymachine,
						/obj/machinery/power/data_terminal = 5)
		cost = 80000
		containertype = /obj/storage/crate
		containername = "Artifact Research Kit"
		hidden = 1

	electronics_kit
		name = "Mechanics Reconstruction Kit"
		desc = "1x Ruckingenur frame, 1x Manufacturer frame, 1x reclaimer frame, 1x device analyzer, 1x soldering iron"
		contains = list(/obj/item/electronics/scanner,
						/obj/item/electronics/soldering)
		frames = list(/obj/machinery/rkit,
						/obj/machinery/manufacturer/mechanic,
						/obj/machinery/portable_reclaimer)
		cost = 35000
		containertype = /obj/storage/crate
		containername = "Mechanics Reconstruction Kit"
		hidden = 1

	eppd
		name = "Emergency Pressurzation Kit"
		desc = "Frames: 1x Extreme-Pressure Pressurization Device"
		category = "Nanotrasen - Proprietary"
		frames = list(/obj/machinery/portable_atmospherics/pressurizer)
		cost = 5000
		containertype = /obj/storage/crate
		containername = "Prototype EPPD Kit"
		hidden = 1

//NT Medical
ABSTRACT_TYPE(/datum/supply_packs/complex/medical)
/datum/supply_packs/complex/medical
	category = "NT Medical"

	medbay
		name = "Medical Bay kit"
		desc = "1x Defibrillator, 2x Hypospray, 1x Medical Belt, Frames: 1x NanoMed, 1x Medical Records computer"
		category = "NT Medical"
		contains = list(/obj/item/robodefibrillator,
						/obj/item/storage/belt/medical,
						/obj/item/reagent_containers/hypospray = 2)
		frames = list(/obj/machinery/optable,
						/obj/machinery/vending/medical)
		cost = 10000
		containertype = /obj/storage/crate
		containername = "Medbay kit"
		hidden = 1

	operating
		name = "Operating Room kit"
		desc = "1x Staple Gun, 1x Defibrillator, 2x Scalpel, 2x Circular Saw, 1x Hemostat, 2x Suture, 1x Enucleation Spoon, Frames: 1x Medical Fabricator, 1x Operating Table"
		contains = list(/obj/item/staple_gun,
						/obj/item/robodefibrillator,
						/obj/item/scalpel = 2,
						/obj/item/circular_saw = 2,
						/obj/item/hemostat,
						/obj/item/scissors/surgical_scissors,
						/obj/item/suture,
						/obj/item/surgical_spoon)
		frames = list(/obj/machinery/manufacturer/medical,
						/obj/machinery/optable,
						/obj/machinery/vending/medical)
		cost = 15000
		containertype = /obj/storage/crate
		containername = "Operating Room kit"
		hidden = 1

	robotics
		name = "Robotics kit"
		desc = "1x Staple Gun, 1x Scalpel, 1x Circular Saw, Frames: 1x Robotics Fabricator, 1x Operating Table, 1x Module Rewriter, 1x Recharge station"
		contains = list(/obj/item/staple_gun,
						/obj/item/scalpel,
						/obj/item/circular_saw,
						/obj/item/circuitboard/robot_module_rewriter)
		frames = list(/obj/machinery/manufacturer/robotics,
						/obj/machinery/optable,
						/obj/machinery/recharge_station)
		cost = 20000
		containertype = /obj/storage/crate
		containername = "Robotics kit"
		hidden = 1

	genetics
		name = "Genetics kit"
		desc = "Circuitboards: 1x DNA Modifier, 1x DNA Scanner"
		contains = list(/obj/item/circuitboard/genetics)
		frames = list(/obj/machinery/genetics_scanner)
		cost = 75000
		containertype = /obj/storage/crate
		containername = "Genetics kit"
		hidden = 1

	cloner
		name = "Cloning kit"
		desc = "Circuitboards: 1x Cloning Console, Frames: 1x Cloning Scanner, 1x Cloning Pod, 1x Enzymatic Reclaimer"
		contains = list(/obj/item/circuitboard/cloning)
		frames = list(/obj/machinery/clone_scanner,
						/obj/machinery/clonepod,
						/obj/machinery/clonegrinder)
		cost = 150000
		containertype = /obj/storage/crate
		containername = "Cloner kit"
		hidden = 1
