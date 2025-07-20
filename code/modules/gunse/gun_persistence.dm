/* This file will contain the following junk:
- modular gun save format
- modular gun parser and sanitiser
- modular gun constructor (generalist)
- modular gun savefile management
- modular gun workbenches?
Enjoy */


//idk what im doing.

/*
/client/proc/save_cloud_gun(var/save = 1, var/obj/item/gun/modular/gun = null)
	if(save == 0)
		if( cloud_available() )
			cloud_put( "persistent_gun", "none")
		return
	// ok from here on out we assume we wanna save the gun on them, or otherwise we will commute the gun they started with to next round.
	if(!src.mob)
		return //we do nothing, so whatever they had they keep..
	if(!gun)
		gun = locate() in src.mob // this will catch the first gun it finds, too bad if you tried getting two.

	if(!istype(gun)) // well there's nothing here, sorry
		/*
		if( cloud_available() )
			cloud_put( "persistent_gun", "none")*/
		return
	if(gun.contraband || gun.no_save)
		return //okay your gun is illegal, maybe you grabbed a fossie gun, idk - but im not gonna *punish* you for it.
	var/list/gunne = list("type"="nano","barrel"="none","stock1"="none","stock2"="none","magazine"="none","accessory"="none")
	//"type"="nano" is not strictly true, but if somehow you got a non-contraband fossie or soviet weapon... here's a free traser.
	if(istype(gun, /obj/item/gun/modular/juicer))
		gunne["type"] = "juicer"
	if(istype(gun, /obj/item/gun/modular/italian))
		gunne["type"] = "italian"
	if(istype(gun.barrel))
		gunne["barrel"] = gun.barrel.type
	if(istype(gun.stock))
		gunne["stock1"] = gun.stock.type
	if(istype(gun.stock2))
		gunne["stock2"] = gun.stock2.type
	if(istype(gun.magazine))
		gunne["magazine"] = gun.magazine.type
	if(istype(gun.accessory))
		gunne["accessory"] = gun.accessory.type

	var/gun_json = json_encode(gunne)
	if( cloud_available() )
		cloud_put( "persistent_gun", gun_json )

/client/proc/get_cloud_gun()
	var/gun_json = null
	var/obj/item/gun/modular/gun = null
	if(!cloud_available())
		return 0
	else
		if(cloud_get("persistent_gun") != "none")
			gun_json = cloud_get("persistent_gun")
	if(isnull(gun_json))
		return 0 // we have nothing to work with!!
	var/list/gunne = json_decode(gun_json)
	if(!length(gunne))
		return 0 // we have nothing to work with!!
	switch(gunne["type"])
		if("juicer")
			gun = new /obj/item/gun/modular/juicer()
		if("italian")
			gun = new /obj/item/gun/modular/italian()
		else
			gun = new /obj/item/gun/modular/NT()
	if(!istype(gun))
		return // just in case we fucked it BIGTIMES

	gun.reset_gun() // important!!

	var/part_type = null
	if(gunne["barrel"] != "none")
		part_type = gunne["barrel"]
		gun.barrel = new part_type()

	if(gunne["stock1"] != "none")
		part_type = gunne["stock1"]
		gun.stock = new part_type()

	if(gunne["stock2"] != "none")
		part_type = gunne["stock2"]
		gun.stock2 = new part_type()

	if(gunne["magazine"] != "none")
		part_type = gunne["magazine"]
		gun.magazine = new part_type()

	if(gunne["accessory"] != "none")
		part_type = gunne["accessory"]
		gun.accessory = new part_type()

	gun.build_gun()
	return gun

*/



// THIS NEXT PART MIGHT B STUPID
/*
ABSTRACT_TYPE(/obj/item/storage/gun_workbench/)
/obj/item/storage/gun_workbench/
	slots = 1
	var/part = null
	var/gun_DRM = 0
	var/partname = "nothing"
	max_wclass = 4

	barrel
		part = /obj/item/gun_parts/barrel/
		partname = "barrel"
	stock
		part = /obj/item/gun_parts/stock/
		partname = "stock"
	magazine
		part = /obj/item/gun_parts/magazine/
		partname = "magazine"
	accessory
		part = /obj/item/gun_parts/accessory/
		partname = "doodad"

	check_can_hold(obj/item/W)
		if(!istype(W,part))
			boutput(usr, "You can only place a [src.partname] here!")
			return
		else
			var/obj/item/gun_parts/new_part = W
			if(new_part.part_DRM & gun_DRM)
				..()
			else
				boutput(usr, "That part isn't compatible with your gun!")
				return
*/
//told u
/obj/item/gun_exploder/
	name = "gunsmithing anvil"
	desc = "hit it with a gun 'till the gun falls apart lmao"
	var/obj/item/gun_parts/part = null
	anchored = 1
	density = 1
	icon = 'icons/obj/dojo.dmi'
	icon_state = "anvil"
	w_class = W_CLASS_BULKY
	throw_spin = FALSE

	portable
		density = 0
		anchored = 0
		w_class = W_CLASS_SMALL
		contraband = 1
		name = "portable gunsmithing anvil"
		desc = "what!! that's so unbalanced!!"

		throw_impact(atom/hit_atom, datum/thrown_thing/thr)
			. = ..()
			if(src.event_handler_flags & IS_PITFALLING && isliving(hit_atom))
				var/mob/living/L = hit_atom
				L.changeStatus("staggered", 5 SECONDS)
				L.show_message("<span class='alert'>YOWCH! You're lucky it wasn't a solid anvil!</span>")
				random_brute_damage(L, 15)
				playsound(src.loc, "sound/impact_sounds/Metal_Hit_Heavy_1.ogg", 70, 1)
				playsound(L, "sound/misc/laughter/laughtrack3.ogg", 50, 0, 3)

	attackby(obj/item/W as obj, mob/user as mob, params)
		if(!istype(W,/obj/item/gun/modular/) || prob(60))
			playsound(src.loc, "sound/impact_sounds/Wood_Hit_1.ogg", 70, 1)
			..()
			return
		var/obj/item/gun/modular/new_gun = W
		if(new_gun.glued)
			playsound(src.loc, "sound/impact_sounds/Wood_Hit_1.ogg", 70, 1)
			..()
			return
		if(!new_gun.built)
			new_gun.ClearAllOverlays(1)
			boutput(user, "<span class='notice'>You smash the pieces of the gun into place!</span>")
			playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1)
			new_gun.build_gun()
			user.u_equip(W)
			W.dropped(user)
			W.set_loc(src.loc)
			return
		else
			boutput(user, "<span class='notice'>You smash the pieces of the gun apart!</span>")
			playsound(src.loc, "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
			user.u_equip(W)
			W.dropped(user)
			W.set_loc(src.loc)

			if(new_gun.grip)
				src.part = new_gun.grip.remove_part_from_gun()
				src.part.set_loc(src.loc)
			if(new_gun.stock)
				src.part = new_gun.stock.remove_part_from_gun()
				src.part.set_loc(src.loc)
			if(new_gun.accessory)
				src.part = new_gun.accessory.remove_part_from_gun()
				src.part.set_loc(src.loc)
			if(new_gun.barrel)
				src.part = new_gun.barrel.remove_part_from_gun()
				src.part.set_loc(src.loc)
			src.part = null
			new_gun.reset_gun() // back to inits
			new_gun.buildTooltipContent()
			new_gun.built = 0
			new_gun.ClearAllOverlays(1) // clear the part overlays but keep cache? idk if thats better or worse.




/obj/table/gun_workbench/
	name = "I DONT WORK DONT USE ME YET"
	desc = "lay down a rifle and start swappin bits"

	var/list/obj/item/gun_parts/parts = list()
	var/obj/item/gun/modular/gun = null
	var/obj/item/gun_parts/barrel/barrel = null
	var/obj/item/gun_parts/stock/stock = null
	var/obj/item/gun_parts/magazine/magazine = null
	var/obj/item/gun_parts/accessory/accessory = null
	var/gun_DRM = 0

	New()
		..()


	attackby(obj/item/W as obj, mob/user as mob, params)
		if(gun)
			boutput(user, "<span class='notice'>There's already a gun on [src].</span>")
			return
		if(!istype(W,/obj/item/gun/modular/))
			boutput(user, "<span class='notice'>You should probably only use this for guns.</span>")
			return
		else
			boutput(user, "<span class='notice'>You secure [W] on [src].</span>")
			//ok its a modular gun!
			//open the gunsmithing menu (cross-shaped inventory thing) and let the user swap parts around in it
			// when they're done, put the parts back in the gun's slots and call gun.build_gun()
			load_gun(W)
			return

	attack_hand(mob/user)
		if(!gun)
			boutput(user, "<span class='notice'>You need to put a gun on [src] first.</span>")
			return
		else
			//open gunsmithing menu
			return

	proc/load_gun(var/obj/item/gun/modular/new_gun)
		src.gun = new_gun
		src.parts = new_gun.parts

		//update DRM for the storage slots.
		src.gun_DRM = new_gun.gun_DRM

		//place parts in the storage slots
		if(new_gun.barrel)
			src.barrel = new_gun.barrel.remove_part_from_gun()
		if(new_gun.stock)
			src.stock = new_gun.stock.remove_part_from_gun()
		if(new_gun.accessory)
			src.accessory = new_gun.accessory.remove_part_from_gun()

		//update icon
//real stupid
	proc/open_gunsmithing_menu()
		//dear smart people please do
		return

	proc/remove_gun(mob/user as mob)
		//add parts to gun // this is gonna runtime you dipshit
		gun.barrel = src.barrel
		gun.stock = src.stock

		//dispense gun
		gun.build_gun()
		user.put_in_hand_or_drop(gun)

		//clear table
		gun = null
		barrel.contents = null
		stock.contents = null
		accessory = null

/obj/machinery/vending/gun_safe
	//this is gonna be uhhhh for persistent's
