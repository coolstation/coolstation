
//Soviet Laser
//Functional, chunky
//Ammo is a series of chemical zaubertubes
//Not really for physical ammo
//might be funny to be lever action/underbarrel tube-fed (which means load directly to chamber, then: last in, first out)

//sound: lever manipulation reload: Realoding a 30-30 Rifle. OWI.wav by JesterWhoo -- https://freesound.org/s/706980/ -- License: Creative Commons 0

ABSTRACT_TYPE(/obj/item/gun/modular/soviet)
/obj/item/gun/modular/soviet

	name = "\improper abstract Soviet laser gun"
	real_name = "\improper abstract Soviet laser gun"
	desc = "abstract type do not instantiate"
	action = "lever"
	icon = 'icons/obj/items/modular_guns/receivers.dmi'
	icon_state = "shittygun"
	sound_type = "soviet"
	gun_DRM = GUN_SOVIET
	lensing = 0.2

//short receiver only
/obj/item/gun/modular/soviet/short
	name = "\improper Soviet laser pistol receiver"
	real_name = "\improper Soviet lazernyy pistolet"
	desc = "Энергетическая пушка советской разработки с пиротехническими лампами-вспышками."
	icon_state = "soviet_short"
	max_ammo_capacity = 2
	contraband = 2
	barrel_overlay_x = BARREL_OFFSET_SHORT
	grip_overlay_x = GRIP_OFFSET_SHORT
	stock_overlay_x = STOCK_OFFSET_SHORT
	jam_frequency = 2
	fiddlyness = 45

/obj/item/gun/modular/soviet/short/basic
	name = "\improper Soviet laser pistol"
	spread_angle = 9
	contraband = 4
	stock_overlay_x = -10

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/soviet(src)
		grip = new /obj/item/gun_parts/grip/italian/cowboy(src)

/obj/item/gun/modular/soviet/short/covert
	name = "covert Soviet laser pistol"
	desc = "Энергетическая пушка советской разработки с пиротехническими лампами-вспышками."
	icon = 'icons/obj/items/modular_guns/receivers.dmi'
	icon_state = "soviet_short"
	max_ammo_capacity = 0 //single shot
	gun_DRM = GUN_SOVIET
	spread_angle = 9
	silenced = 1 //need to set this from barrel but whatever, it's here for now
	//color = "#FF9999"
	//icon_state = "laser"
	contraband = 2

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/soviet/covert(src)
		grip = new /obj/item/gun_parts/grip/italian(src)

//long receiver only
/obj/item/gun/modular/soviet/long
	name = "\improper Soviet laser rifle receiver"
	real_name = "\improper Soviet lazernaya vintovka"
	desc = "Энергетическая пушка советской разработки с пиротехническими лампами-вспышками."
	icon_state = "soviet_long"
	//cartridge_length = 40
	max_ammo_capacity = 4
	spread_angle = 9
	contraband = 4
	barrel_overlay_x = BARREL_OFFSET_LONG
	grip_overlay_x = GRIP_OFFSET_LONG
	stock_overlay_x = STOCK_OFFSET_LONG
	//two_handed = TRUE
	//can_dual_wield = FALSE
	jam_frequency = 2
	fiddlyness = 35

/obj/item/gun/modular/soviet/long/advanced
	name = "\improper advanced Soviet laser rifle"
	real_name = "\improper Soviet lazernaya vintovka"
	desc = "Энергетическая пушка советской разработки с пиротехническими лампами-вспышками."
	icon_state = "soviet_long"
	max_ammo_capacity = 4
	gun_DRM = GUN_SOVIET
	spread_angle = 9
	contraband = 5
	barrel_overlay_x = BARREL_OFFSET_LONG
	grip_overlay_x = GRIP_OFFSET_LONG
	stock_overlay_x = STOCK_OFFSET_LONG

	make_parts()
		if(prob(25))
			barrel = new /obj/item/gun_parts/barrel/soviet/dense(src)
		else
			barrel = new /obj/item/gun_parts/barrel/soviet/long(src)
		if(prob(75))
			stock = new /obj/item/gun_parts/stock/soviet(src)
		else
			stock = new /obj/item/gun_parts/stock/soviet/wire(src)

/obj/item/gun/modular/soviet/long/scatter
	name = "\improper Soviet laser scattergun"
	real_name = "\improper Soviet lazernaya drobovik"
	desc = "Энергетическая пушка советской разработки с пиротехническими лампами-вспышками."
	icon_state = "soviet_long"
	max_ammo_capacity = 3
	gun_DRM = GUN_SOVIET
	spread_angle = 9
	contraband = 5
	barrel_overlay_x = BARREL_OFFSET_LONG
	grip_overlay_x = GRIP_OFFSET_LONG
	stock_overlay_x = STOCK_OFFSET_LONG
	two_handed = TRUE //okay so this happens even when it's in receiver-only form
	//might want to make a gun flag so that they're one handed when apart but two handed when fully assembled

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/soviet/scatter(src)
		if(prob(75))
			stock = new /obj/item/gun_parts/stock/soviet(src)
		else
			stock = new /obj/item/gun_parts/stock/italian(src)
