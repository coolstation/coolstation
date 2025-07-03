
// syndicate laser gun's!
// cranked capacitor which discharges through a flashtube thing and shoots a big honking lazers
// everyone else basically standardized on ammo but theirs is an open standard (that nobody uses)
// same goes for basically everything else, core foss parts only work with other core foss parts but lights and other similar attachments are fine
// nothing about this gun should be taken as applying to other gun's and vice versa
// it's basically super soaker principle
// TODO: strategy on crankin', on limits, on what different stocks allow
ABSTRACT_TYPE(/obj/item/gun/modular/foss)
/obj/item/gun/modular/foss
	name = "\improper FOSS laser"
	real_name = "\improper FOSS laser"
	desc = "An open-sourced and freely modifiable FOSS Inductive Flash Arc, Model 2k/19"
	max_ammo_capacity = 1 // just takes a flash bulb.
	action = "nerd"
	gun_DRM = GUN_FOSS
	spread_angle = 7
	//color = "#aaaaFF"
	icon = 'icons/obj/items/modular_guns/fossgun.dmi'
	icon_state = "foss_receiver"
	contraband = 7
	fiddlyness = 50
	//set these manually because nothing really uh
	//nothing else is like the foss guns
	barrel_overlay_x = 6
	stock_overlay_x = -10 //combined with the inherent -6 on the stock itself, this is 16 to the left (fiddly fucking thing)
	grip_overlay_x = -4
	grip_overlay_y = -2
	jam_frequency = 0 //really only if overcharged
	jam_frequency = 0 //only if the user is clumsy
	//foregrip_offset_x = 12
	//foregrip_offset_y = 0

//basic foss laser
/obj/item/gun/modular/foss/standard
	name = "\improper standards-compliant FOSS laser"

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/foss(src)
		stock = new /obj/item/gun_parts/stock/foss(src)


/obj/item/gun/modular/foss/long
	name = "\improper more-piped FOSS laser"
	desc = "An open-sourced and freely modifiable FOSS Inductive Flash Arc, Model 2k/20"

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/foss/long(src)
		stock = new /obj/item/gun_parts/stock/foss/long(src)
		grip = new /obj/item/gun_parts/grip/foss(src)

/obj/item/gun/modular/foss/punt
	name = "\improper 'arrem arreff' FOSS laser"
	desc = "An open-sourced and freely modifiable FOSS Inductive Flash Arc, Model 2k/420"

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/foss/long/very(src)
		stock = new /obj/item/gun_parts/stock/foss/longer(src)

/obj/item/gun/modular/foss/loader
	name = "\improper DDoS FOSS laser"
	desc = "An open-sourced and freely modifiable FOSS Inductive Flash Arc, Model 2k/19L"
	make_parts()
		barrel = new /obj/item/gun_parts/barrel/foss/long(src)
		stock = new /obj/item/gun_parts/stock/foss/loader(src)
		grip = new /obj/item/gun_parts/grip/foss(src)
		//foregrip = new /obj/item/gun_parts/grip/foss(src)
