
/*
BASIC BROAD PART PARADIGMS:
" gun " : the reciever - determines whether it's single or double action, basic capacity (bolt or revolver), and DRM types
Barrels : largely handle how a shot behaves after leaving your gun. Spread, muzzle flash, silencing, damage modifiers.
Stocks  : everything to do with holding and interfacing the gun. Crankhandles, extra capacity, 2-handedness, and (on rare occasions) power cells go here
Grips	: sorry i had to break this out for logistical purposes. absolutely only used (atm) for hondling the gun, stocks are the fancy bits
Mags    : entirely optional component that adds ammo capacity, but also increases jamming frequency. May affect action type by autoloading?
accssry : mall ninja bullshit. optics. gadgets. flashlights. horns. sexy nude men figurines. your pick.
*/

ABSTRACT_TYPE(/obj/item/gun_parts)
/obj/item/gun_parts/
	icon = 'icons/obj/items/modular_guns/accessory.dmi'
	var/name_addition = ""
	var/part_type = null
	var/overlay_x = 0 //how much does the sprite need to move to fit with standard attachment position
	var/overlay_y = 0 //same but vertical
	var/foldable = 0 //wire stocks and the like. 0 cannot, 1 is deployed, 2 is folded.
	var/part_DRM = 0 //which gun models is this part compatible with?
	var/obj/item/gun/modular/my_gun = null

	proc/add_part_to_gun(var/obj/item/gun/modular/gun)
		my_gun = gun
		add_overlay_to_gun(gun, 1)
		my_gun.bulk += src.bulkiness
		my_gun.name = my_gun.real_name //clear "receiver"
		return 1

	proc/add_overlay_to_gun(var/obj/item/gun/modular/gun, var/correctly = 0)
		var/image/I = image(icon, "[icon_state]-built")
		if(correctly) //proper assembly?
			I.pixel_x = overlay_x
			I.pixel_y = overlay_y
		else // to be tightened
			if (part_type == "barrel")
				I.pixel_x = overlay_x + 3
			if (part_type == "stock")
				I.pixel_x = overlay_x - 3
				//if (gun.bullpup_stock) //gotta figure this fucker out: we'd want this to be an underlay or a layer slightly below the reciever
				//for now i'm just adding another overlay of the receiver maybe
			if (part_type == "grip")
				I.pixel_y = overlay_y - 3
		gun.UpdateOverlays(I, part_type)

	proc/remove_part_from_gun()
		RETURN_TYPE(/obj/item/gun_parts/)
		my_gun = null
		overlay_x = initial(overlay_x)
		overlay_y = initial(overlay_y)
		part_type = initial(part_type)
		return src

	//barrel vars
	var/spread_angle = 0 // modifier, added to stock
	var/silenced = 0
	var/muzzle_flash = "muzzle_flash"
	var/lensing = 0 // Variable used for optical gun barrels. Scalar around 1.0
	var/jam_frequency_fire = 1 //additional % chance to jam on fire. Reload to clear.
	var/scatter = 0
	var/length = 0 // centimetres

	//stock vars
	var/can_dual_wield = 0
	//var/spread_angle = 0 	// modifier, added to stock // repeat of barrel
	var/max_ammo_capacity = 0 //modifier
	var/flashbulb_only = 0 	// FOSS guns only (only takes flashbulb ammo)
	var/flash_auto = 0 		// FOSS guns only (autoloader, multiple small shots on a big charge)
	var/max_crank_level = 0 // FOSS guns only (top end cranking)
	var/safe_crank_level = 0 // FOSS guns only (limited cranking)
	var/bulkiness = 1 //higher bulkiness leads to 2-handedness?? 1-5 i guess
	var/stock_dual_wield = 1 // if gun AND stock can be dual wielded, whole gun can be dual wielded.
	var/jam_frequency_reload = 0 //attitional % chance to jam on reload. Just reload again to clear.

	// mag vars
	// max_ammo_capacity = 0 //modifier
	// jam_frequency_reload = 5 //additional % chance to jam on reload. Just reload again to clear.

	buildTooltipContent()
		. = ..()
		if(part_DRM)
			. += "<div><span>DRM REQUIREMENTS: </span>"
			if(part_DRM & GUN_NANO)
				. += "<img src='[resource("images/tooltips/temp_nano.png")]' alt='' class='icon' />"
			if(part_DRM & GUN_FOSS)
				. += "<img src='[resource("images/tooltips/temp_foss.png")]' alt='' class='icon' />"
			if(part_DRM & GUN_JUICE)
				. += "<img src='[resource("images/tooltips/temp_juice.png")]' alt='' class='icon' />"
			if(part_DRM & GUN_SOVIET)
				. += "<img src='[resource("images/tooltips/temp_soviet.png")]' alt='' class='icon' />"
			if(part_DRM & GUN_ITALIAN)
				. += "<img src='[resource("images/tooltips/temp_italian.png")]' alt='' class='icon' />"
			. += "</div>"
		if(scatter)
			. += "<div><img src='[resource("images/tooltips/temp_scatter.png")]' alt='' class='icon' /></div>"
		if(spread_angle)
			. += "<div><img src='[resource("images/tooltips/temp_spread.png")]' alt='' class='icon' /><span>Spread Modifier: [src.spread_angle] </span></div>"
		if(lensing)
			. += "<div><img src='[resource("images/tooltips/lensing.png")]' alt='' class='icon' /><span>Optical Lens: [src.lensing] </span></div>"
		if(length)
			. += "<div><span>Barrel length: [src.length] </span></div>"
		if(jam_frequency_fire || jam_frequency_reload)
			. += "<div><img src='[resource("images/tooltips/jamjarrd.png")]' alt='' class='icon' /><span>Jam Probability: [src.jam_frequency_reload + src.jam_frequency_fire] </span></div>"
		if(max_ammo_capacity)
			. += "<div> <span>Capacity Modifier: [src.max_ammo_capacity] </span></div>"
		lastTooltipContent = .



ABSTRACT_TYPE(/obj/item/gun_parts/barrel)
/obj/item/gun_parts/barrel/
// useful vars
	part_type = "barrel"
	spread_angle = 0// remove barrel penalty
	silenced = 0
	muzzle_flash = "muzzle_flash"
	lensing = 0 // Variable used for optical gun barrels. Scalar around 1.0
	jam_frequency_fire = 1 //additional % chance to jam on fire. Reload to clear.
	scatter = 0
	icon = 'icons/obj/items/modular_guns/barrels.dmi'
	icon_state = "it_revolver"
	length = STANDARD_BARREL_LEN
	overlay_x = 13
	// for uniformity, barrels should start on the 3rd column of the frame and try to cover a height of 4 pixels
	// just for ease of reference, the projectile will "exit" the receiver one pixel down from the top
	// this means you've got a pixel at the top (19,3) and bottom (16,3) for receiver attachment
	// the row one pixel down (18) for light barrels, and the middle 2 rows of the 4 pixels (17,18) for implied heavy barrels
	// check the template and other sprites for details
	// use these offsets if your sprite doesnt match that (extreme length, greebling, etc)

	add_part_to_gun(var/obj/item/gun/modular/gun)
		overlay_x += gun.barrel_overlay_x
		overlay_y += gun.barrel_overlay_y
		..()
		if(!my_gun)
			return
		my_gun.barrel = src
		my_gun.spread_angle = max(0, (my_gun.spread_angle + src.spread_angle)) // so we cant dip below 0
		my_gun.silenced = src.silenced
		my_gun.muzzle_flash = src.muzzle_flash
		my_gun.lensing = src.lensing
		my_gun.scatter = src.scatter
		my_gun.jam_frequency_fire += src.jam_frequency_fire
		my_gun.name = my_gun.name + " " + src.name_addition
		//Icon! :)

	remove_part_from_gun()
		if(!my_gun)
			return

		. = ..()

//the thing on the back of a grun
	// MOVE TO WIKI ON A HOW TO GUNS SECTION LATER
	// for uniformity, shoulder stocks should start two pixels from the right edge (30x) and 13px from the top (19y)
	// this gives you an attachment point/hard stock edge 4 pixels tall (30,16 to 30,19)
	// the template in stocks.dmi shows cyan for receiver, blue for the virtual grip attachment point, dark green for stock attachment, and light green for roughly safe area to make your stock
	// if you have an extreme or weird example of a thing that goes beyond that point (wired stocks, greebling, etc)...
	// ...adjust your offset so your intended stock attachment point is along the line of (16,16 to 16,19)
	// this gives us a roughly centered stock attachment point, which can then be adjusted by the long or short receivers
	// i.e. long regular receiver requires -6x, long bullpup receiver requires -2x, short receiver requires -5x with a normal stock that fits this offset
	// also makes it easy to tell where the barrel is relative to the grip for foregrip purposes

ABSTRACT_TYPE(/obj/item/gun_parts/stock)
/obj/item/gun_parts/stock/
	//add a var for a power cell later
	part_type = "stock"
	can_dual_wield = 0
	spread_angle = 0 // modifier, added to stock
	max_ammo_capacity = 0 //modifier
	flashbulb_only = 0 // FOSS guns only
	max_crank_level = 0 // FOSS guns only
	bulkiness = 1 // if gun or stock is 2 handed, whole gun is 2 handed
	stock_dual_wield = 1 // if gun AND stock can be dual wielded, whole gun can be dual wielded.
	jam_frequency_reload = 0 //attitional % chance to jam on reload. Just reload again to clear.
	part_DRM = GUN_JUICE | GUN_NANO | GUN_SOVIET | GUN_ITALIAN //pretty much everyone by default
	var/list/ammo_list = list() // ammo that stays in the stock when removed
	icon_state = "nt_solid"
	icon = 'icons/obj/items/modular_guns/stocks.dmi'
	overlay_x = -14

	add_part_to_gun(var/obj/item/gun/modular/gun)
		if(!istype(gun))
			return
		overlay_x += gun.stock_overlay_x
		overlay_y += gun.stock_overlay_y
		..()
		if(!my_gun)
			return
		//if stock blocks grip, return
		if(part_type == "stock")
			my_gun.stock = src
			my_gun.can_dual_wield = src.can_dual_wield
		my_gun.max_ammo_capacity += src.max_ammo_capacity
		my_gun.spread_angle = max(0, (my_gun.spread_angle + src.spread_angle)) // so we cant dip below 0

		my_gun.can_dual_wield &= src.stock_dual_wield
		my_gun.jam_frequency_reload += src.jam_frequency_reload
		my_gun.ammo_list += src.ammo_list
		my_gun.name = src.name_addition + " " + my_gun.name
		if(flashbulb_only)
			my_gun.flashbulb_only = 1 //src.flashbulb_only
			my_gun.max_crank_level = src.max_crank_level
			my_gun.safe_crank_level = src.safe_crank_level
			my_gun.flash_auto = src.flash_auto
		else
			my_gun.flashbulb_only = 0
			my_gun.max_crank_level = 0
			my_gun.safe_crank_level = 0
			my_gun.flash_auto = 0

	remove_part_from_gun()
		if(!my_gun)
			return
		//handle some ammo
		if(my_gun.ammo_list.len)
			var/total = ((my_gun.ammo_list.len > src.max_ammo_capacity) ? max_ammo_capacity : 0)
			src.ammo_list = my_gun.ammo_list.Copy(1,(total))
			my_gun.ammo_list.Cut(1,(total))
		. = ..()

//the thing you hold to hold a gun
// mechanically they're just a stick to hold onto

	// MOVE TO WIKI AS HOW TO CREATE A GUN'S PARTS ARTICLE:
	// full size part icons can be whatever. half-sized built icons have to fit this template, where each px is approximately 1 inch
	// for uniformity, grips should aim for a virtual attachment point at (12,16), 1,1 up from the bottom left of a standard small receiver outline (greebling can exceed this)
	// make sure the right side of the trigger has a 2 px vertical flat area, with 1px clearance to the left of the trigger
	// templates will be available for three styles/starting points: pistol, revolver, rifle. each has different cutouts but they all share same attachment point and interface with trigger
	// grip goes over 1 hand gun, under 2 hand gun
	// there's also a standard trigger location for reference (useful for NT bullpup)
	// and for now let's assume a foregrip is like, 6px to the right of the regular grip

	// also really just use the template,

ABSTRACT_TYPE(/obj/item/gun_parts/grip)
/obj/item/gun_parts/grip/
	//add a var for a power cell later
	bulkiness = 1
	part_type = "grip"
	spread_angle = 0 // modifier, added to stock
	icon_state = "wiz"
	icon = 'icons/obj/items/modular_guns/grips.dmi'

	add_part_to_gun(var/obj/item/gun/modular/gun)
		if(!istype(gun))
			return

		overlay_x += gun.grip_overlay_x //offsets to get to the standard position on the receiver
		overlay_y += gun.grip_overlay_y
		//no grip? put grip on first
		if(!gun.grip)
			//add checks to see if you can put one on (some receivers/stocks might block)
			//TODO: soviet long receiver accepts no grip
			src.part_type = "grip"
			my_gun = gun
			my_gun.grip = src
			add_overlay_to_gun(gun, 1)
			my_gun.bulk += src.bulkiness
			//TODO ATTN barrels need to have length specified for this (hover over last pixel on the barrel and -2x and there's ur length)
		//grip is present, attempt to put foregrip on if there is no foregrip
		/*
		else if(!gun.foregrip)
			//if (gun.barrel && (gun.barrel.length + gun.barrel.overlay_x >= gun.grip_overlay_x + gun.foregrip_offset_x + 2)) // with at least 2px from the end of the barrel.
			//add checks to see if you can put one on (some receivers/stocks might block, some receivers can always accept regardless of barrel?)
			//I have this off until I adjust barrel lengths and can look at the math with a fresh and clear head
			//TODO: soviet gun accepts no foregrip
			//additional shunting from the receiver itself
			overlay_x += gun.foregrip_offset_x
			overlay_y += gun.foregrip_offset_y

			src.part_type = "foregrip"

			my_gun = gun
			my_gun.foregrip = src
			add_overlay_to_gun(gun, 1)
			my_gun.bulk += src.bulkiness
			*/
			/*
			else //no room on the barrel
				boutput(usr,"<span class='alert'><b>Error! The foregrip just falls off 'cause there's jack shit to hold it!</b></span>")
				my_gun.foregrip = null
				gun.parts &= ~src
				src.set_loc(get_turf(src))
				gun.UpdateOverlays(null, part_type)
				src.part_type = "grip" //back to a normal grip
				return
			*/
		/* //don't think i need this. tearing it out for now
		else //already a grip and foregrip
			boutput(usr,"<span class='alert'><b>Error! Looks like you can't put any grips on this thing at all!</b></span>")
			gun.parts &= ~src
			src.set_loc(get_turf(src))
			gun.UpdateOverlays(null, part_type)
			src.part_type = "grip"
			return
		*/

		..()
		if(!my_gun)
			return

		my_gun.spread_angle = max(0, (my_gun.spread_angle + src.spread_angle)) // so we cant dip below 0

		my_gun.name = src.name_addition + " " + my_gun.name

	remove_part_from_gun()
		if(!my_gun) //already removed, or so you think
			return
		. = ..()

		my_gun.grip = null
		/*
		if (part_type == "foregrip")
			my_gun.foregrip = null
			*/

//any gun that isn't single shot will need one of these somehow
ABSTRACT_TYPE(/obj/item/gun_parts/magazine)
/obj/item/gun_parts/magazine/

	part_type = "magazine"
	max_ammo_capacity = 0 //modifier
	jam_frequency_reload = 5 //additional % chance to jam on reload. Just reload again to clear.
	var/list/ammo_list = list() // ammo that stays in the mag when removed

	icon_state = "generic_magazine"
	contraband = 1

	add_part_to_gun(var/obj/item/gun/modular/gun)
		overlay_x += gun.magazine_overlay_x
		overlay_y += gun.magazine_overlay_y
		..()
		if(!my_gun)
			return
		my_gun.magazine = src
		my_gun.ammo_list += src.ammo_list
		my_gun.max_ammo_capacity += src.max_ammo_capacity
		my_gun.jam_frequency_reload += src.jam_frequency_reload
		my_gun.name = my_gun.name + " " + src.name_addition

	remove_part_from_gun()
		if(!my_gun)
			return
		my_gun.magazine = null
		if(my_gun.ammo_list.len)
			var/total = ((my_gun.ammo_list.len > src.max_ammo_capacity) ? max_ammo_capacity : 0)
			src.ammo_list = my_gun.ammo_list.Copy(1,(total))
			my_gun.ammo_list.Cut(1,(total))

		. = ..()

ABSTRACT_TYPE(/obj/item/gun_parts/accessory)
/obj/item/gun_parts/accessory/
	var/alt_fire = 0 //does this accessory offer an alt-mode? light perhaps? (this is triggered by cycling with the chamber full)
	var/call_on_fire = 0 // does the gun call this accessory's on_fire() proc?
	var/call_on_cycle = 0 // does the gun call this accessory's on_cycle() proc? (thats when you cycle ammo)
	part_type = "accessory"
	icon_state = "generic_magazine"

	proc/alt_fire()
		return alt_fire

	proc/on_fire()
		return call_on_fire

	proc/on_cycle()
		return call_on_cycle

	add_part_to_gun()
		..()
		if(!my_gun)
			return
		my_gun.accessory = src
		my_gun.accessory_alt = alt_fire
		my_gun.accessory_on_fire = call_on_fire
		my_gun.accessory_on_cycle = call_on_cycle
		my_gun.name = src.name_addition + " " + my_gun.name



	remove_part_from_gun()
		if(!my_gun)
			return
		. = ..()
		my_gun.accessory = null




// NOW WE HAVE THE INSTANCIBLE TYPES

// BASIC BARRELS

/obj/item/gun_parts/barrel/NT
	name = "standard barrel"
	desc = "A cylindrical barrel, unrifled."
	spread_angle = 1 // basic stabilisation
	part_DRM = GUN_NANO | GUN_JUICE | GUN_ITALIAN
	icon_state = "nt_blue_short"
	length = 10

/obj/item/gun_parts/barrel/NT/long
	name = "standard long barrel"
	desc = "A cylindrical barrel, rifled."
	spread_angle = 0
	name_addition = "longarm"
	icon_state = "nt_blue"
	length = 16
	bulkiness = 3

/obj/item/gun_parts/barrel/NT/short
	name = "standard snub barrel"
	spread_angle = 4
	length = 5
	icon_state = "nt_blue_snub"
	name_addition = "shortie"

/obj/item/gun_parts/barrel/NT/shotty
	name = "shotgun barrel"
	spread_angle = 18
	scatter = 1
	length = 10
	icon_state = "nt_blue_shotshort"
	name_addition = "shotty"
	bulkiness = 2

/obj/item/gun_parts/barrel/NT/shotty/short
	name = "sawn-off barrel"
	spread_angle = 12
	scatter = 1
	length = 10
	icon_state = "nt_blue_shotshort"
	name_addition = "shotty"
	bulkiness = 2

/obj/item/gun_parts/barrel/NT/long/very
	name = "special long barrel"
	desc = "A cylindrical barrel, rifled."
	spread_angle = -1
	name_addition = "polearm"
	icon_state = "nt_blue_very"
	length = 50
	icon = 'icons/obj/items/modular_guns/64.dmi'
	bulkiness = 3

/obj/item/gun_parts/barrel/NT/long/padded
	name = "padded long barrel"
	desc = "A cylindrical barrel, padded."
	spread_angle = -1
	name_addition = "club"
	icon_state = "nt_guarded"
	bulkiness = 4

/obj/item/gun_parts/barrel/foss
	name = "\improper FOSS lensed barrel"
	desc = "A cylindrical array of lenses to focus laser blasts."
	spread_angle = 2
	lensing = 0.9
	part_DRM = GUN_FOSS | GUN_SOVIET | GUN_JUICE
	name_addition = "lenser"
	icon = 'icons/obj/items/modular_guns/fossgun.dmi'
	icon_state = "barrel_short"
	contraband = 1
	length = 17

/obj/item/gun_parts/barrel/foss/long
	name = "\improper FOSS lensed long barrel"
	desc = "A cylindrical array of lenses to focus laser blasts."
	spread_angle = 1
	lensing = 1
	name_addition = "focuser"
	icon_state = "barrel_long"
	length = 29
	bulkiness = 2

/obj/item/gun_parts/barrel/foss/long/very
	name = "\improper FOSS ultra lensed barrel"
	desc = "A hyperbolic array of lenses to focus laser blasts."
	spread_angle = -1
	lensing = 0.85
	name_addition = "catalyst"
	icon = 'icons/obj/items/modular_guns/64.dmi' //can move this back to standard barrel, leave 64 for comedy
	icon_state = "foss_very_long"
	length = 28
	bulkiness = 3

/obj/item/gun_parts/barrel/juicer
	name = "\improper BLUNDA Barrel"
	desc = "A cheaply-built shotgun barrel. And by cheaply-built I mean someone adapted a broken vuvuzela for a gun."
	spread_angle =  13 // jesus christ it's a spread machine
	scatter = 1
	jam_frequency_fire = 5 //but very poorly built
	part_DRM = GUN_JUICE
	name_addition = "BLUNDA"
	icon_state = "juicer_blunderbuss"
	length = 16
	bulkiness = 1
	//absolutely needs a quiet fucked up vuvuzela honk

/obj/item/gun_parts/barrel/juicer/chub
	name = "\improper BUSTIN Barrel"
	desc = "Sawn-off shotgun barrel, hot-rodded with paint and donkey grease."
	part_DRM = GUN_JUICE | GUN_NANO
	spread_angle = 6
	length = 11
	icon_state = "juicer_chub"
	name_addition = "BUSTA"
	bulkiness = 1

/obj/item/gun_parts/barrel/juicer/ribbed
	name = "\improper KNOBBIN Barrel"
	desc = "Shotgun barrel: for yuor gun's pleansure."
	part_DRM = GUN_JUICE | GUN_NANO
	spread_angle = 4
	jam_frequency_fire = 8
	length = 17
	icon_state = "juicer_ribbed"
	name_addition = "Genthlemaenne's"
	bulkiness = 2

/obj/item/gun_parts/barrel/juicer/longer
	name = "\improper SNIPA Barrel"
	desc = "A cheaply-built extended rifled shotgun barrel. Not good."
	part_DRM = GUN_JUICE | GUN_NANO
	spread_angle =  4 // accurate?? ish?
	jam_frequency_fire = 15 //but very!!!!!!! poorly built
	name_addition = "BLITZINNNNNNN'"
	icon_state = "juicer_long"
	bulkiness = 3
	length = 28

//TODO: names and lengths
//average laser
/obj/item/gun_parts/barrel/soviet
	name = "soviet lenses"
	desc = "стопка линз для фокусировки вашего пистолета"
	spread_angle =  3
	lensing = 1.2
	part_DRM = GUN_SOVIET | GUN_ITALIAN
	name_addition = "comrade"
	icon_state = "soviet_lens"
	length = 18

//quieter somehow but also less damage and very short range
/obj/item/gun_parts/barrel/soviet/covert
	name = "compact soviet beam former"
	spread_angle =  3
	lensing = 1.2
	part_DRM = GUN_SOVIET | GUN_ITALIAN
	name_addition = "shpion"
	icon_state = "soviet_lens_snub"
	length = 14

//fire two projectiles at half damage and short range
/obj/item/gun_parts/barrel/soviet/scatter
	name = "soviet diffractor"
	spread_angle =  5
	lensing = 1.2
	part_DRM = GUN_SOVIET | GUN_ITALIAN
	name_addition = "raskolnik"
	icon_state = "soviet_lens_scatter"
	length = 14

//longer range
/obj/item/gun_parts/barrel/soviet/long
	name = "focused soviet lenses"
	desc = "стопка линз для фокусировки вашего пистолета"
	part_DRM = GUN_SOVIET | GUN_ITALIAN
	spread_angle = 2
	lensing = 1.4
	name_addition = "tovarisch"
	icon_state = "soviet_lens_long"
	length = 23
	bulkiness = 2

//heavier hitting, also adaptable to foss lasers: too big for small italian revolver
/obj/item/gun_parts/barrel/soviet/dense
	name = "soviet optical concentrator"
	desc = "стопка линз для фокусировки вашего пистолета"
	part_DRM = GUN_FOSS | GUN_SOVIET
	spread_angle = 2
	lensing = 1.4
	name_addition = "medved"
	icon_state = "soviet_lens_dense"
	length = 25
	bulkiness = 2

/obj/item/gun_parts/barrel/italian
	name = "canna di fucile"
	desc = "una canna di fucile di base e di alta qualità"
	icon_state = "it_revolver"
	spread_angle = 7 // "alta qualità"
	part_DRM = GUN_ITALIAN | GUN_SOVIET
	name_addition = "paisan"
	icon_state = "it_revolver_short"
	length = 13

/obj/item/gun_parts/barrel/italian/small
	name = "canna di fucile piccolo"
	desc = "una canna di fucile di base e di bellissima qualità"
	icon_state = "it_revolver_snub"
	name_addition = "paisanetto"
	spread_angle = 9
	length = 5

/obj/item/gun_parts/barrel/italian/spicy
	name = "canna di fucile arrabiata"
	desc = "una canna di fucile di base e di bellissima qualità"
	icon_state = "it_revolver_short"
	name_addition = "paisana"
	spread_angle = 9
	length = 16

/obj/item/gun_parts/barrel/italian/accurate
	name = "buon canna di fucile"
	desc = "una canna di fucile di base e di bellissima qualità"
	icon_state = "it_revolver_long"
	name_addition = "paisano"
	spread_angle = 3

/obj/item/gun_parts/barrel/italian/buntline
	name = "canna di fucile extra lunga"
	desc = "una canna di fucile di base e di bellissima qualità"
	icon_state = "it_revolver_buntline"
	name_addition = "tiratore"
	spread_angle = 0

/obj/item/gun_parts/barrel/italian/joker
	name = "canna di fucile pagliaccioo"
	desc = "una canna di fucile di base e di bellissima qualità"
	icon_state = "it_revolver_justsilly"
	name_addition = "burlone"
	spread_angle = 4 //a little shaky
	length = 25

// BASIC STOCKS
// Stocks should always have a negative spread angle unless they're particularly cumbersome.
// those ones probably add functionality that offsets the +ve spread?

/obj/item/gun_parts/grip/NT
	name = "standard grip"
	desc = "A comfortable NT pistol grip"
	spread_angle = -3 // basic stabilisation
	part_DRM = GUN_NANO
	name_addition = "trusty"
	icon = 'icons/obj/items/modular_guns/grips.dmi'
	icon_state = "nt_blue"

	guardless
		name = "guardless standard grip"
		icon_state = "nt_blue_guardless"
		name_addition = "rusty"

	ceremonial
		name = "ceremonial standard grip"
		icon_state = "nt_ceremonial"
		name_addition = "shmancy"

	fancy
		name = "fancy standard grip"
		icon_state = "nt_fancy"
		name_addition = "fancy"

	stub
		name = "stub grip"
		icon_state = "nt_stub"
		spread_angle = -1
		name_addition = "stubby"

	wood
		name = "wood grip"
		icon_state = "nt_rev"
		spread_angle = -1
		name_addition = "woody"


/obj/item/gun_parts/grip/italian
	name = "impugnatura a pistola"
	desc = "un'impugnatura rivestita in cuoio toscano per un revolver di alta qualità"
	spread_angle = 0
	max_ammo_capacity = 1 // to make that revolver revolve!
	jam_frequency_reload = 3 // a lot  more jammy!!
	part_DRM = GUN_NANO | GUN_ITALIAN | GUN_SOVIET
	icon = 'icons/obj/items/modular_guns/grips.dmi'
	icon_state = "it_plain"
	name_addition = "quality"

	bigger
		name = "impugnatura a pistola piu larga"
		desc = "un'impugnatura rivestita in cuoio toscano per un revolver di alta qualità"
		spread_angle = -1
		max_ammo_capacity = 3 // to make that revolver revolve!
		jam_frequency_reload = 6 // a lot  more jammy!!
		part_DRM = GUN_ITALIAN | GUN_SOVIET
		icon_state = "it_fancy"
		name_addition = "jovial"
		bulkiness = 2

	meatball
		name = "da meatballs"
		desc = "An extremely weirdly-shaped and red sauce-smelling combat grip, but it's definitely comfortable."
		spread_angle = -2
		max_ammo_capacity = 2
		jam_frequency_reload = 4
		part_DRM = GUN_ITALIAN | GUN_SOVIET
		icon_state = "it_meatballs"
		name_addition = ""
		bulkiness = 2


	cowboy
		name = "cowboy grip"
		desc = "Smells like spaghetti."
		spread_angle = 0
		max_ammo_capacity = 2
		jam_frequency_reload = 4
		part_DRM = GUN_ITALIAN | GUN_SOVIET
		icon_state = "it_cowboy"
		bulkiness = 2

		bandit
			name = "bandit grip"
			desc = "Looks like trouble."
			spread_angle = 3
			max_ammo_capacity = 1
			jam_frequency_reload = 6
			icon_state = "it_bandit"

		pearl
			name = "pearl grip"
			desc = "Tastes like plastic."
			spread_angle = -3
			max_ammo_capacity = 1
			jam_frequency_reload = 2
			icon_state = "it_pearl"


/obj/item/gun_parts/grip/juicer
	name = "da grip"
	desc = "some kind of knockoff tacticool pistol grip"
	spread_angle = -3
	icon = 'icons/obj/items/modular_guns/grips.dmi'
	icon_state = "white"
	name_addition = "strapped"

	red
		name = "redgrip"
		icon_state = "red"
		name_addition = "stylish"

	black
		icon_state = "black"
		name_addition = "slick"

	trans
		name = "da brick"
		icon_state = "trans"
		throwforce = 10 // hehe
		name_addition = "queer"

/obj/item/gun_parts/grip/foss
	name = "\improper FOSS grip"
	desc = "An open-sourced 3d-printed grip with dynamic angles. Comfort secondary."
	spread_angle = -3 // basic stabilisation
	part_DRM = GUN_FOSS
	name_addition = "hands-on"
	icon_state = "foss"

/obj/item/gun_parts/grip/wizard
	name = "space wizard grip"
	desc = "Do you think space wizards know just how fucking insufferable they are? They have to, they really have to. They gotta be doing it on purpose. Holy shit."
	spread_angle = -3 // basic stabilisation
	name_addition = "whizz-bang"
	icon_state = "wiz"

//stonks

/obj/item/gun_parts/stock/NT
	name = "standard stock"
	desc = "A comfortable NT shoulder stock"
	spread_angle = -4 // quite better stabilisation
	bulkiness = 3
	can_dual_wield = 0
	max_ammo_capacity = 2 // a few more rounds
	jam_frequency_reload = 2 // a little more jammy
	icon = 'icons/obj/items/modular_guns/stocks.dmi'
	name_addition = "sturdy"
	icon_state = "nt_solid"

/obj/item/gun_parts/stock/NT/precision
	name = "Precision stock"
	desc = "A comfortable NT shoulder stock with cheek rest"
	spread_angle = -6 // quite better stabilisation
	max_ammo_capacity = 1 // additional shot in the butt
	jam_frequency_reload = 1 // not too bad
	name_addition = "sharpshooter"
	icon_state = "nt_solid_cheek"

/obj/item/gun_parts/stock/NT/wire
	name = "wire stock"
	desc = "An uncomfortable NT wire stock, but maybe some day it can fold up" //convert from 1-2 hand and conceal
	spread_angle = -2 // not as better stabilisation
	bulkiness = 1
	can_dual_wield = 0
	foldable = 1
	//max_ammo_capacity = 0 // does not add ammo
	//jam_frequency_reload = 3 // a little more jammy
	icon = 'icons/obj/items/modular_guns/stocks.dmi'
	name_addition = "capable"
	icon_state = "nt_wire"
	overlay_x = 0 //generally wire stocks should be centered, using "template-offset" as a guide

/obj/item/gun_parts/stock/NT/drum //TODO: make this fucker slow to load somehow
	name = "helical-magazine stock"
	desc = "A staggering 5 rounds can be loaded into this integral drum shoulder stock."
	spread_angle = -3 // quite better stabilisation
	bulkiness = 4
	can_dual_wield = 0
	max_ammo_capacity = 5
	jam_frequency_reload = 5 // a little more jammy
	icon = 'icons/obj/items/modular_guns/stocks.dmi'
	name_addition = "appointed"
	icon_state = "nt_solid_mag"

/obj/item/gun_parts/stock/italian
	name = "hunting stock"
	desc = "A fancy walnut Italian stock for hunting (write this in italian later)" //convert from 1-2 hand and conceal
	spread_angle = -5 // brety gud
	bulkiness = 1
	//max_ammo_capacity = 0 // does not add ammo
	//jam_frequency_reload = 3 // a little more jammy
	icon = 'icons/obj/items/modular_guns/stocks.dmi'
	name_addition = "cacciatore"
	icon_state = "it_solid"
	bulkiness = 3

/obj/item/gun_parts/stock/italian/wire
	name = "wire stock"
	desc = "A long Italian wire stock that currently doesn't fold"
	spread_angle = -2 // not as better stabilisation
	bulkiness = 1
	can_dual_wield = 0
	foldable = 1
	icon = 'icons/obj/items/modular_guns/stocks.dmi'
	name_addition = "stabile"
	icon_state = "it_wire"
	overlay_x = 0

/obj/item/gun_parts/stock/soviet
	name = "hunting stock"
	desc = "A utilitarian Soviet stock (write this in russian later)" //convert from 1-2 hand and conceal
	spread_angle = -5 // brety gud
	bulkiness = 2
	//max_ammo_capacity = 0 // does not add ammo
	//jam_frequency_reload = 3 // a little more jammy
	icon = 'icons/obj/items/modular_guns/stocks.dmi'
	name_addition = "ustoychivyy"
	icon_state = "sov_solid"

/obj/item/gun_parts/stock/soviet/wire
	name = "wire stock"
	desc = "A long Soviet wire stock that currently doesn't fold"
	spread_angle = -2 // not as better stabilisation
	bulkiness = 1
	can_dual_wield = 0
	foldable = 1
	icon = 'icons/obj/items/modular_guns/stocks.dmi'
	name_addition = "udobnyy"
	icon_state = "sov_wire"
	overlay_x = 0

//Free and Open Source Cranked-Up Springs/Capacitors/Etc.
//One second per crank just imo, the spam was getting bad
//Allow a disableable crank safety- with it on, you have a smaller level of cranking available.
//With it off, you can do significantly more damage but there's higher risk to you- bulb burn out, explosions, misfires (like the spring slips and it just fires somewhere in front of you, or into your leg if holstered, etc), etc.
//These are ALWAYS two handed because of the necessary stock
/obj/item/gun_parts/stock/foss
	name = "\improper FOSS laser stock"
	desc = "An open-sourced laser dynamo, with a multiple-position winding spring."
	spread_angle = -3 // basic stabilisation
	part_DRM = GUN_FOSS //standards compliant with their own standard
	flashbulb_only = 1
	max_crank_level = 2
	safe_crank_level = 1
	bulkiness = 2
	overlay_x = -6 //absolutely know this is right

	name_addition = "agile"
	icon = 'icons/obj/items/modular_guns/fossgun.dmi'
	icon_state = "stock_single"


/obj/item/gun_parts/stock/foss/long
	name = "\improper FOSS laser rifle stock"
	spread_angle = -4 // better stabilisation
	bulkiness = 3
	can_dual_wield = 0
	max_crank_level = 3 // for syndicate ops
	safe_crank_level = 2
	name_addition = "lean"

//the closest thing to a machine gun we'll get
//lets out charge one crank at a time
//less powerful than the others but good at suppressing
//the bulb can still burn out though! so what if: auto-failover between loaded bulbs
//another fun option: flywheel dynamo in this guy that you can hear a constant sound
//the more charged it is, the more high pitched it is, so you can tell when it's at a high charge vs a low charge
//takes a small while to crank up from empty, and will run down over time when not used (say, 1 charge/s)
//faster to charge while charged? add 4 per 4 second crank?
//charge it up too much and you have increasingly higher risks to overcharge like the gauss gun
/obj/item/gun_parts/stock/foss/loader
	name = "\improper FOSS laser loader stock"
	desc = "An open-sourced laser dynamo, with a multiple-position winding spring. This one's kind of hard to hold."
	spread_angle = 2 // poor stabilisation
	max_ammo_capacity = 1 // more bulbs in the pocket
	jam_frequency_reload = 10
	flash_auto = 1
	max_crank_level = 25
	safe_crank_level = 15
	name_addition = "automated"
	icon_state = "stock_double"
	bulkiness = 4

//mega charge for heavy hitting
//what if this requires two bulbs inserted to get crank 4 and if one breaks you're down to crank 2? hmm
/obj/item/gun_parts/stock/foss/longer
	name = "\improper FOSS laser punt gun stock"
	spread_angle = 3 // poor stabilisation
	bulkiness = 5
	can_dual_wield = 0
	max_crank_level = 5 // for syndicate ops
	safe_crank_level = 3
	jam_frequency_reload = 5 // a little more jammy
	name_addition = "six-sigma"
	icon_state = "stock_double_alt"

// BASIC ACCESSORIES
	// flashlight!!
	// grenade launcher!!
	// a horn!!
/obj/item/gun_parts/accessory/horn
	name = "Tactical Alerter"
	desc = "Efficiently alerts your squadron within miliseconds of target engagement, using cutting edge over-the-airwaves technology"
	call_on_fire = 1
	name_addition = "tactical"
	icon_state = "alerter"

	on_fire()
		playsound(src.my_gun.loc, pick('sound/musical_instruments/Bikehorn_bonk1.ogg', 'sound/musical_instruments/Bikehorn_bonk2.ogg', 'sound/musical_instruments/Bikehorn_bonk3.ogg'), 50, 1, -1)

	attack_self(mob/user as mob)
		user.u_equip(src)
		user.show_text("You de-militarise the bike horn, turning it into a normal funny one.", "blue")
		var/obj/item/instrument/bikehorn/H = new()
		user.put_in_hand_or_drop(H)
		qdel(src)

/obj/item/gun_parts/accessory/flashlight
	name = "Tactical Enbrightener"
	desc = "No deep operator can be without adequate Night-Vision equipment, or at the very least, a pocket torch taped to their barrel."
	alt_fire = 1
	icon_state = "flash"
	overlay_x = 4 //ideally: move this 1-3px ahead of the normal foregrip position, or use the foregrip position if there's no foregrip (foregrip add check should check for accessory here and kick it off)
	var/col_r = 0.9
	var/col_g = 0.8
	var/col_b = 0.7
	var/light_type = null
	var/brightness = 4.6
	var/light_mode = 0
	var/icon_off = "flash"
	var/icon_on = "flash_on"
	var/built_off = "flash-built"
	var/built_on = "flash-active"
	var/built_focused = "flash-focused"

	var/datum/component/holdertargeting/simple_light/light_dim
	var/datum/component/holdertargeting/simple_light/light_good

	attack_self(mob/user as mob)
		user.u_equip(src)
		user.show_text("You de-militarise the emergency flashlight, turning it into a normal, non-tactical one.", "baby shit brown")
		var/obj/item/device/light/flashlight/H = new()
		user.put_in_hand_or_drop(H)
		qdel(src)

	alt_fire()
		playsound(src, "sound/items/penclick.ogg", 30, 1)
		if(light_mode == 2) // if on the bright mode, turn off
			set_icon_state(src.icon_off)
			var/image/I = image(icon, built_off)
			I.pixel_x = overlay_x
			I.pixel_y = overlay_y
			my_gun.UpdateOverlays(I, part_type)
			light_mode = 0
			light_good.update(0)
			return
		if(light_mode == 0) // dim mode
			set_icon_state(src.icon_on)
			var/image/I = image(icon, built_on)
			I.pixel_x = overlay_x
			I.pixel_y = overlay_y
			my_gun.UpdateOverlays(I, part_type)
			light_mode = 1
			light_dim.update(1)
		else if(light_mode == 1) // actual flashlight mode
			light_dim.update(0)
			light_good.update(1)
			set_icon_state(src.icon_on)
			var/image/I = image(icon, built_focused)
			I.pixel_x = overlay_x
			I.pixel_y = overlay_y
			my_gun.UpdateOverlays(I, part_type)
			light_mode = 2

	add_part_to_gun()
		..()
		if(!my_gun)
			return
		light_dim = my_gun.AddComponent(/datum/component/holdertargeting/simple_light, col_r * 255, col_g * 255, col_b  * 255, 100)
		light_dim.update(0)
		light_good = my_gun.AddComponent(/datum/component/holdertargeting/medium_directional_light/, col_r * 255, col_g * 255, col_b  * 255, 210)
		light_good.update(0)


	remove_part_from_gun()
		light_good.update(0)
		light_good.light_target = src
		light_dim.update(0)
		light_dim.light_target = src
		light_mode = 0
		. = ..()

	attack_self(mob/user as mob)
		user.u_equip(src)
		user.show_text("You de-militarise the enbrightener, turning it into a normal useless one.", "blue")
		var/obj/item/device/light/flashlight/H = new()
		user.put_in_hand_or_drop(H)
		qdel(src)

/obj/item/gun_parts/accessory/flashlight/NT
	name = "NT Weaponlight"
	desc = "A little more sensible than taping a handheld flashlight to your barrel. That is, if you're a COP."
	icon_state = "nt_flash"
	icon_off = "nt_flash"
	icon_on = "nt_flash_on"
	built_off = "nt_flash-built"
	built_on = "nt_flash-active"
	built_focused = "nt_flash-focused"

// No such thing as a basic magazine! they're all bullshit!!
/obj/item/gun_parts/magazine/juicer
	name = "HOTT SHOTTS MAG"
	desc = "Holds 3 rounds, and 30,000 followers."
	max_ammo_capacity = 3
	jam_frequency_reload = 8
	name_addition = "LARGE"
	icon = 'icons/obj/items/modular_guns/magazines.dmi'
	icon_state = "juicer_drum"

	four
		name = "HOTTTER SHOTTTS MAG"
		desc = "Holds 4 rounds, and seems to be made out of some kind of cereal box."
		icon_state = "juicer_drum-bigger"
		max_ammo_capacity = 4
		jam_frequency_reload = 16

	five
		name = "HOTTTTEST SHOTTTTS MAG"
		desc = "Holds 5 rounds, attracts the ire of haters everywhere you go."
		icon_state = "juicer_drum-biggest"
		max_ammo_capacity = 5
		contraband = 5
		jam_frequency_reload = 12

