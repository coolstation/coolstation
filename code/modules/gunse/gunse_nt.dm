
// BASIC GUN'S
//NANOTRASEN COP GUNS
//stupid plastic patented hi tech bullshit, for copse. rifle is bullpup
//probably the most "normal" modern gun in the game
//standard stupid breech load
//Ammo: standard/small and also primarily stun
//magazine: none by default, ammo is stored behind/in the stock (the grip holds the very large battery for the light and the loader)
//eventually: convert long receiver to short receiver and vice versa via swappable kit (with NT and soviet receivers)
/*
ABSTRACT_TYPE(/obj/item/gun/modular/NT)
/obj/item/gun/modular/NT
	name = "abstract NT gun"
	real_name = "abstract NT gun"
	desc = "You're not supposed to see this, call a coder or whatever."
	max_ammo_capacity = 0 // single-shot pistols ha- unless you strap an expensive loading mag on it.
	action = "single"
	gun_DRM = GUN_NANO
	icon = 'icons/obj/items/modular_guns/receivers.dmi'
	icon_state = "nt_short" //or nt_long
	var/electrics_intact = FALSE //the grody autoloading ID locked snitchy smart gun parts that are just begging to be microwaved, emagged, or simply pried and cut out
	spread_angle = 6
*/
ABSTRACT_TYPE(/obj/item/gun/modular/NT)
/obj/item/gun/modular/NT
	name = "\improper NT pistol receiver"
	real_name = "\improper NT pistol"
	desc = "A basic, Nanotrasen-licensed single-shot weapon."
	icon = 'icons/obj/items/modular_guns/receivers.dmi'
	icon_state = "nt"
	barrel_overlay_x = 5
	grip_overlay_x = -4
	grip_overlay_y = -2
	stock_overlay_x = -4
	stock_overlay_y = -1
	max_ammo_capacity = 0
	action = "single"
	gun_DRM = GUN_NANO
	spread_angle = 6

	//receiver, by itself and unbuilt
	receiver
		no_build = TRUE

//a built and usable pistol
/obj/item/gun/modular/NT/pistol
	name = "\improper NT pistol"
	make_parts()
		barrel = new /obj/item/gun_parts/barrel/NT(src)
		if(prob(10))
			grip = new /obj/item/gun_parts/grip/NT/fancy(src)
		else if(prob(10))
			grip = new /obj/item/gun_parts/grip/NT/ceremonial(src)
		else if(prob(10)) // yes i know these are diminishing probabilities, thats the idea.
			grip = new /obj/item/gun_parts/grip/NT/stub(src)
		else
			grip = new /obj/item/gun_parts/grip/NT(src)

/obj/item/gun/modular/NT/pistol_sec
	name = "\improper NT pistol"
	make_parts()
		barrel = new /obj/item/gun_parts/barrel/NT/long/padded(src)
		if(prob(10))
			grip = new /obj/item/gun_parts/grip/NT/fancy(src)
		else if(prob(10))
			grip = new /obj/item/gun_parts/grip/NT/ceremonial(src)
		else
			grip = new /obj/item/gun_parts/grip/NT/stub(src)


//single shot, no stock, intended for shotgun shell
/obj/item/gun/modular/NT/bartender
	name = "grey-market NT shotgun"
	desc = "Cobbled together from unlicensed parts and passed between bartenders for at least a quarter of a generation."
	contraband = 3
	make_parts()
		barrel = new /obj/item/gun_parts/barrel/juicer/chub(src)
		if(prob(50))
			grip = new /obj/item/gun_parts/grip/juicer/black(src)
			//if(prob(10))
			//	foregrip = new /obj/item/gun_parts/grip/NT/stub(src)
		else
			grip = new /obj/item/gun_parts/grip/juicer(src)
			//if(prob(10))
			//	foregrip = new /obj/item/gun_parts/grip/juicer/black(src)
		if(prob(30))
			accessory = new /obj/item/gun_parts/accessory/flashlight(src)

//long rifle
/obj/item/gun/modular/NT/rifle
	name = "\improper NT rifle"
	real_name = "\improper NT rifle"

	make_parts()
		if(prob(90))
			barrel = new /obj/item/gun_parts/barrel/NT/long(src)
		else
			barrel = new /obj/item/gun_parts/barrel/NT/long/padded(src)
		stock = new /obj/item/gun_parts/stock/NT(src)
		if(prob(60))
			grip = new /obj/item/gun_parts/grip/NT
		if(prob(10))
			accessory = new /obj/item/gun_parts/accessory/flashlight(src)

//stocked shotgun for sec
/obj/item/gun/modular/NT/shotty
	name = "\improper NT riot suppressor"
	real_name = "\improper NT shotgun"
	desc = "'Innovated' almost entirely from Juicer parts, it seems."

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/NT/shotty(src)
		if(prob(50))
			stock = new /obj/item/gun_parts/stock/NT(src)
		else
			stock = new /obj/item/gun_parts/stock/NT/drum(src)
		if(prob(25))
			grip = new /obj/item/gun_parts/grip/NT/stub(src)
		else if(prob(25))
			grip = new /obj/item/gun_parts/grip/NT/wood(src)
		//if(prob(30))
		//	foregrip = new /obj/item/gun_parts/grip/NT/stub(src)
