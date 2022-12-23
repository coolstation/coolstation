/* This file will contain the following junk:
- modular gun save format
- modular gun parser and sanitiser
- modular gun constructor (generalist)
- modular gun savefile management
- modular gun workbenches?
Enjoy */


//idk what im doing.


/datum/player
	proc/savegun()
		return




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

	attackby(obj/item/W as obj, mob/user as mob, params)
		if(!istype(W,/obj/item/gun/modular/) || prob(70))
			playsound(src.loc, "sound/impact_sounds/Wood_Hit_1.ogg", 70, 1)
			..()
			return
		var/obj/item/gun/modular/new_gun = W
		if(!new_gun.built)
			boutput(user, "<span class='notice'>You smash the pieces of the gun into place!</span>")
			playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1)
			new_gun.build_gun()
			return
		else
			boutput(user, "<span class='notice'>You smash the pieces of the gun apart!</span>")
			playsound(src.loc, "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
			user.u_equip(W)
			W.dropped(user)
			W.set_loc(src.loc)
			if(new_gun.barrel)
				src.part = new_gun.barrel.remove_part_from_gun()
				src.part.set_loc(src.loc)
			if(new_gun.stock)
				src.part = new_gun.stock.remove_part_from_gun()
				src.part.set_loc(src.loc)
			if(new_gun.stock2)
				src.part = new_gun.stock2.remove_part_from_gun()
				src.part.set_loc(src.loc)
			if(new_gun.magazine)
				src.part = new_gun.magazine.remove_part_from_gun()
				src.part.set_loc(src.loc)
			if(new_gun.accessory)
				src.part = new_gun.accessory.remove_part_from_gun()
				src.part.set_loc(src.loc)
			src.part = null
			new_gun.reset_gun() // back to inits
			new_gun.buildTooltipContent()
			new_gun.built = 0
			new_gun.ClearAllOverlays(1) // clear the part overlays but keep cache? idk if thats better or worse.




/obj/table/gun_workbench/
	name = "gunsmithing workbench"
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
		if(new_gun.magazine)
			src.magazine = new_gun.magazine.remove_part_from_gun()
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
		gun.magazine = src.magazine
		gun.accessory = src.accessory

		//dispense gun
		gun.build_gun()
		user.put_in_hand_or_drop(gun)

		//clear table
		gun = null
		barrel.contents = null
		stock.contents = null
		magazine.contents = null
		accessory = null
