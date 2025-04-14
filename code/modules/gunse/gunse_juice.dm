
//JUICER GUN'ZES
//Loud and obnoxious and comical and deudly but also extremely unreliable
//Ammo: probably whatever but primarily shot
//Pump Action Slam
//Integrated Non-Removable TOP-FED Box Magazine (It's BIG but you still have to load one at a time and it's probably the most unreliable part)
//Ideally a two handed thing: maybe if you don't have a stock you can use wire to make a strap so it has a much smaller chance of flying out of your hands
//High damage potential but high fuckup potential as well
ABSTRACT_TYPE(/obj/item/gun/modular/juicer)
/obj/item/gun/modular/juicer
	name = "\improper abstract Juicer gun"
	real_name = "\improper abstract BLASTA"
	desc = "A juicer-built, juicer-'designed', and most importantly juicer-marketed gun."
	icon = 'icons/obj/items/modular_guns/receivers.dmi'
	icon_state = "juicer" //only large
	max_ammo_capacity = 0 //fukt up mags only
	action = "pump"
	gun_DRM = GUN_JUICE
	spread_angle = 10
	contraband = 1
	barrel_overlay_x = BARREL_OFFSET_LONG
	grip_overlay_x = GRIP_OFFSET_LONG
	stock_overlay_x = STOCK_OFFSET_LONG
	jam_frequency = 5
	jam_frequency = 15
	fiddlyness = 0 //surprisingly not very fiddly, loads fast, clears jams fast. built for sucking

//just the receiver
/obj/item/gun/modular/juicer/receiver

/obj/item/gun/modular/juicer/basic
	name = "\improper Juicer sawn-off shotgun"
	real_name = "babby BLASTA"

	make_parts()
		if(prob(50))
			barrel = new /obj/item/gun_parts/barrel/juicer(src)
		else
			if(prob(50))
				barrel = new /obj/item/gun_parts/barrel/juicer/chub(src)
			else
				barrel = new /obj/item/gun_parts/barrel/juicer/ribbed(src)
		if(prob(5))
			grip = new /obj/item/gun_parts/grip/juicer/trans(src)
		else if(prob(50))
			grip = new /obj/item/gun_parts/grip/juicer(src)
		else
			grip = new /obj/item/gun_parts/grip/juicer/red(src)
		if(prob(25))
			stock = new /obj/item/gun_parts/stock/italian/wire(src)
		if(prob(60))
			magazine = new /obj/item/gun_parts/magazine/juicer/four(src)
		else
			magazine = new /obj/item/gun_parts/magazine/juicer(src)
		if(prob(40))
			accessory = new /obj/item/gun_parts/accessory/flashlight(src)

/obj/item/gun/modular/juicer/blunder
	name = "\improper Juicer blunderbuss"
	real_name = "blunda BLASTA"

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/juicer(src)
		if(prob(5))
			grip = new /obj/item/gun_parts/grip/juicer/trans(src)
		else if(prob(50))
			grip = new /obj/item/gun_parts/grip/juicer/black(src)
		else
			grip = new /obj/item/gun_parts/grip/juicer(src)
		magazine = new /obj/item/gun_parts/magazine/juicer/four(src)

/obj/item/gun/modular/juicer/long
	name = "\improper Juicer 'sniper'"
	real_name = "sniper BLASTA"

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/juicer/longer(src)
		if(prob(70))
			grip = new /obj/item/gun_parts/grip/italian(src)
		else
			grip = new /obj/item/gun_parts/grip/italian/bigger(src)
		if(prob(50))
			//foregrip = new /obj/item/gun_parts/grip/juicer(src)
			magazine = new /obj/item/gun_parts/magazine/juicer/four(src)
		else
			magazine = new /obj/item/gun_parts/magazine/juicer/five(src)

/obj/item/gun/modular/juicer/ribbed
	name = "\improper Juicer dildogun"
	real_name = "greeble BLASTA"

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/juicer/ribbed(src)
		if(prob(70))
			grip = new /obj/item/gun_parts/grip/juicer(src)
		else
			grip = new /obj/item/gun_parts/grip/juicer/black(src)
		if(prob(50))
			//foregrip = new /obj/item/gun_parts/grip/juicer/black(src)
			magazine = new /obj/item/gun_parts/magazine/juicer/four(src)
		else
			magazine = new /obj/item/gun_parts/magazine/juicer(src)
