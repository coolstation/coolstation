


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
	var/add_prefix = "" // DONT INCLUDE A TRAILING SPACE
	var/add_suffix = "" // DONT INCLUDE A LEADING SPACE
	var/part_type = GUN_PART_UNDEF
	var/overlay_x = 0 //how much does the sprite need to move to fit with standard attachment position
	var/overlay_y = 0 //same but vertical
	var/foldable = 0 //wire stocks and the like. 0 cannot, 1 is deployed, 2 is folded.
	var/part_DRM = 0 //which gun models is this part compatible with?
	var/call_alter_projectile = 0 // does the gun call this accessory's alter_projectile() proc?
	var/call_on_cycle = 0 // does the gun call this accessory's on_cycle() proc? (thats when you cycle ammo)
	var/caliber = CALIBER_TINY // bitflag OR'd with other parts, TINY is 00 (pistol), WIDE is 01 (shotgun), LONG is 10 (rifle), LONG_WIDE is 11 (huge stuff)
	var/bulkiness = 1 //higher bulkiness increases w_class and handedness, each part is 1-5
	var/spread_angle = 0 // modifier, added to receiver
	var/jam_frequency = 1 //additional % chance to jam on fire. Reload to clear.
	var/max_ammo_capacity = 0 //modifier

	var/obj/item/gun/modular/my_gun = null

	//barrel vars (usually)
	var/silenced = FALSE
	var/muzzle_flash = null
	var/lensing = 0 // Variable used for optical gun barrels. Adds onto static base of 0.2x
	var/length = 0 // centimetres

	//stock vars (usually)
	var/flashbulb_only = FALSE 	// FOSS guns only (only takes flashbulb ammo)
	var/flash_auto = FALSE 		// FOSS guns only (autoloader, multiple small shots on a big charge)
	var/max_crank_level = 0 // FOSS guns only (top end cranking)
	var/safe_crank_level = 0 // FOSS guns only (limited cranking)

	New()
		. = ..()
		if(src.real_name)
			src.name = src.real_name

	proc/add_part_to_gun(var/obj/item/gun/modular/gun)
		if(!istype(gun))
			return 0 // what
		// In order to generalize the construction process and allow some wacky parts to exist, we're doing all stat assignment on every part.
		// this means in practice, all stats are additive, and you may see nonsensical stat additions on exotic pieces, ex: +lensing on stocks.
		// while i don't see this being a common practice, i wanna keep an open mind about what people might design. Who says a grip cant make bang.
		// i make bang.   -warc
		my_gun = gun
		add_overlay_to_gun(gun, 1)

		//GENERAL PROPERTIES
		my_gun.bulk += src.bulkiness
		my_gun.max_ammo_capacity += src.max_ammo_capacity
		my_gun.jam_frequency += src.jam_frequency
		my_gun.spread_angle += src.spread_angle
		my_gun.lensing += src.lensing

		//NAME
		my_gun.name_prefix(src.add_prefix)
		my_gun.name_suffix(src.add_suffix)
		my_gun.UpdateName()

		//FOSS
		if(src.flashbulb_only)
			my_gun.flashbulb_only |= src.part_type
		if(src.flash_auto)
			my_gun.flash_auto |= src.part_type
		my_gun.max_crank_level  += src.max_crank_level  	//potential to increase these with a doodad other than the stock device
		my_gun.safe_crank_level += src.safe_crank_level 	//potential to increase these with a doodad other than the stock device

		//LISTS
		if(src.muzzle_flash)
			my_gun.muzzle_flashes.Add(src.muzzle_flash)

		//BITFIELDS
		if(src.silenced)
			my_gun.silenced |= src.part_type
		if(src.call_on_cycle)
			my_gun.call_on_cycle |= src.part_type
		if(src.call_alter_projectile)
			my_gun.call_alter_projectile |= src.part_type

		//AOUGH
		my_gun.caliber |= src.caliber

		return 1

	proc/on_cycle(var/obj/item/gun/modular/gun, var/datum/projectile/projectile, var/mob/user)
		return call_on_cycle

	proc/alter_projectile(var/obj/item/gun/modular/gun, var/obj/projectile/P, var/mob/user)
		return call_alter_projectile

	proc/add_overlay_to_gun(var/obj/item/gun/modular/gun, var/correctly = 0)
		var/image/I = image(icon, icon_state)//"[icon_state]-built")
		if(correctly) //proper assembly?
			I.pixel_x = overlay_x
			I.pixel_y = overlay_y
		else // to be tightened
			if (part_type & GUN_PART_BARREL)
				I.pixel_x = overlay_x + 3
				I.pixel_y = overlay_y
			if (part_type & GUN_PART_STOCK)
				I.pixel_x = overlay_x - 3
				I.pixel_y = overlay_y - 1
			if (part_type & GUN_PART_GRIP)
				I.pixel_y = overlay_y - 3
				I.pixel_x = overlay_x - 1
		I.layer = gun.layer - 0.01
		gun.UpdateOverlays(I, "[part_type]")

	proc/remove_part_from_gun()
		RETURN_TYPE(/obj/item/gun_parts/)

		//GENERAL PROPERTIES
		my_gun.bulk -= src.bulkiness
		my_gun.max_ammo_capacity -= src.max_ammo_capacity
		my_gun.jam_frequency -= src.jam_frequency
		my_gun.spread_angle -= src.spread_angle
		my_gun.lensing -= src.lensing

		//NAME
		my_gun.name_prefixes -= src.add_prefix
		my_gun.name_suffixes -= src.add_suffix
		my_gun.UpdateName()

		//FOSS
		if(src.flashbulb_only)
			my_gun.flashbulb_only &= ~src.part_type
		if(src.flash_auto)
			my_gun.flash_auto &= ~src.part_type
		my_gun.max_crank_level  -= src.max_crank_level  	//potential to increase these with a doodad other than the stock device
		my_gun.safe_crank_level -= src.safe_crank_level 	//potential to increase these with a doodad other than the stock device

		//LISTS
		if(src.muzzle_flash)
			my_gun.muzzle_flashes -= src.muzzle_flash

		//BITFIELDS
		if(src.silenced)
			my_gun.silenced &= ~src.part_type
		if(src.call_on_cycle)
			my_gun.call_on_cycle &= ~src.part_type
		if(src.call_alter_projectile)
			my_gun.call_alter_projectile &= ~src.part_type

		my_gun.parts -= src

		//AOUGH
		my_gun.caliber = initial(my_gun.caliber)
		for(var/obj/item/gun_parts/part in my_gun.parts)
			my_gun.caliber |= part.caliber

		my_gun.UpdateOverlays(null, "[part_type]")

		my_gun = null
		overlay_x = initial(overlay_x)
		overlay_y = initial(overlay_y)
		part_type = initial(part_type)
		return src


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
		if(length)
			. += "<div><span>Barrel length: [src.length] cm = [round(100 * BARREL_SCALING(src.length), 0.5)]% power </span></div>"

		if(src.caliber & CALIBER_LONG)
			. += "<div><span>Caliber Modifier: Long</span></div>"
		if(src.caliber & CALIBER_WIDE)
			. += "<div><span>Caliber Modifier: Wide</span></div>"
		if(src.caliber & CALIBER_SPUD)
			. += "<div><span>Caliber Modifier: Spudlike</span></div>"

		. += "<div><img src='[resource("images/tooltips/temp_spread.png")]' alt='' class='icon' /><span>Spread Modifier: [src.spread_angle] </span></div>"

		if(lensing)
			. += "<div><img src='[resource("images/tooltips/lensing.png")]' alt='' class='icon' /><span>Optical Lens: [src.lensing] </span></div>"

		. += "<div><img src='[resource("images/tooltips/jamjarrd.png")]' alt='' class='icon' /><span>Jam Modifier: [src.jam_frequency] </span></div>"

		. += "<div><span>Bulk: [src.bulkiness][pick("kg","lb","0%"," finger")] </span></div>"

		if(max_ammo_capacity)
			. += "<div> <span>Capacity Modifier: [src.max_ammo_capacity] </span></div>"

		lastTooltipContent = .

	disposing()
		src.remove_part_from_gun()
		..()

ABSTRACT_TYPE(/obj/item/gun_parts/barrel)
/obj/item/gun_parts/barrel/
// useful vars
	part_type = GUN_PART_BARREL
	spread_angle = 0// remove barrel penalty
	silenced = FALSE
	muzzle_flash = "muzzle_flash"
	lensing = 0 // Variable used for optical gun barrels. Scalar around 1.0
	jam_frequency = 1 //additional % chance to jam on fire. Reload to clear.
	spread_angle = 5 // modifier, added to receiver
	icon = 'icons/obj/items/modular_guns/barrels.dmi'
	icon_state = "italian_revolver"
	length = STANDARD_BARREL_LEN
	overlay_x = 13

	add_part_to_gun(var/obj/item/gun/modular/gun)
		overlay_x += gun.barrel_overlay_x
		overlay_y += gun.barrel_overlay_y
		..()
		if(!my_gun)
			return
		my_gun.barrel = src

		//Icon! :)

	remove_part_from_gun()
		if(!my_gun)
			return
		my_gun.barrel = null
		my_gun.spread_angle += BARREL_PENALTY
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
	part_type = GUN_PART_STOCK

	spread_angle = 0 // modifier, added to receiver
	max_ammo_capacity = 0 //modifier
	flashbulb_only = FALSE // FOSS guns only
	max_crank_level = 0 // FOSS guns only
	jam_frequency = 0 //attitional % chance to jam on reload. Just reload again to clear.
	part_DRM = GUN_JUICE | GUN_NANO | GUN_SOVIET | GUN_ITALIAN //pretty much everyone by default
	caliber = CALIBER_LONG
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
		my_gun.stock = src
		//if stock blocks grip, return
		my_gun.ammo_list += src.ammo_list


	remove_part_from_gun()
		if(!my_gun)
			return
		my_gun.stock = null
		//handle some ammo
		if(my_gun.ammo_list.len)
			var/total = ((my_gun.ammo_list.len > src.max_ammo_capacity) ? max_ammo_capacity : 0)
			src.ammo_list = my_gun.ammo_list.Copy(1,(total))
			my_gun.ammo_list.Cut(1,(total))
		if(!my_gun.grip)
			my_gun.spread_angle += GRIP_PENALTY
		. = ..()

//the thing you hold to hold a gun
// mechanically they're just a stick to hold onto
ABSTRACT_TYPE(/obj/item/gun_parts/grip)
/obj/item/gun_parts/grip/
	//add a var for a power cell later
	part_type = GUN_PART_GRIP
	spread_angle = 0 // modifier, added to receiver
	icon_state = "wiz"
	icon = 'icons/obj/items/modular_guns/grips.dmi'

	add_part_to_gun(var/obj/item/gun/modular/gun)
		if(!istype(gun))
			return
		overlay_x += gun.grip_overlay_x //offsets to get to the standard position on the receiver
		overlay_y += gun.grip_overlay_y
		..()
		if(!my_gun)
			return
		my_gun.grip = src

	remove_part_from_gun()
		if(!my_gun) //already removed, or so you think
			return
		my_gun.grip = null
		if(!my_gun.stock)
			my_gun.spread_angle += GRIP_PENALTY
		. = ..()

		/*
		if (part_type == "foregrip")
			my_gun.foregrip = null
			*/

ABSTRACT_TYPE(/obj/item/gun_parts/accessory)
/obj/item/gun_parts/accessory/
	var/alt_fire = 0 //does this accessory offer an alt-mode? light perhaps? (this is triggered by cycling with the chamber full)

	spread_angle = 0 // modifier, added to receiver

	part_type = GUN_PART_ACCSY
	icon_state = "generic_magazine"

	proc/alt_fire()
		return alt_fire

	add_part_to_gun()
		..()
		if(!my_gun)
			return
		my_gun.accessory = src
		my_gun.accessory_alt = alt_fire

	remove_part_from_gun()
		if(!my_gun)
			return
		my_gun.accessory = null
		. = ..()

// NOW WE HAVE THE INSTANCIBLE TYPES

// BASIC BARRELS

/obj/item/gun_parts/barrel/NT
	name = "standard barrel"
	desc = "A cylindrical barrel, unrifled."
	spread_angle = 4 // decent stabilisation
	part_DRM = GUN_NANO | GUN_JUICE | GUN_ITALIAN
	icon_state = "nt_blue_short"
	length = 10
	overlay_x = 5
	bulkiness = 2

/obj/item/gun_parts/barrel/NT/long
	name = "standard long barrel"
	desc = "A cylindrical barrel, rifled."
	spread_angle = 2
	add_suffix = "longarm"
	icon_state = "nt_blue"
	length = 16
	overlay_x = 7
	bulkiness = 3

/obj/item/gun_parts/barrel/NT/short
	name = "standard snub barrel"
	spread_angle = 6
	length = 5
	icon_state = "nt_blue_snub"
	add_suffix = "shortie"
	overlay_x = 2

/obj/item/gun_parts/barrel/NT/shotty
	name = "shotgun barrel"
	spread_angle = 8
	length = 10
	icon_state = "nt_blue_shot"
	add_suffix = "shotty"
	overlay_x = 6
	bulkiness = 2
	caliber = CALIBER_WIDE

/obj/item/gun_parts/barrel/NT/shotty/short
	name = "sawn-off barrel"
	spread_angle = 11
	length = 6
	icon_state = "nt_blue_shotshort"
	add_suffix = "shottie"
	overlay_x = 4
	bulkiness = 1
	caliber = CALIBER_WIDE

/obj/item/gun_parts/barrel/NT/shotty/flare
	name = "flare gun barrel"
	spread_angle = -2
	length = 5
	icon_state = "nt_blue_shotflare"
	add_suffix = null
	add_prefix = "plastic"
	overlay_x = 4
	bulkiness = 2
	caliber = CALIBER_WIDE
	call_alter_projectile = TRUE

	alter_projectile(var/obj/item/gun/modular/gun, var/obj/projectile/P, var/mob/user)
		if (P && P.power > 15)
			var/spread = rand((P.power ** 0.66) * 20) / 10
			P.rotateDirection(prob(50) ? spread : -spread)
			P.max_spread += spread
			if(prob(P.power * 1.5))
				explosion_new(src, get_turf(src), 1)
				src.remove_part_from_gun()
				src.set_loc(get_turf(src))
				src.visible_message("\The [src] bursts and pops off the gun!")
				src.combust(src)
		return ..()


/obj/item/gun_parts/barrel/NT/long/very
	name = "special long barrel"
	desc = "A cylindrical barrel, rifled."
	spread_angle = 0
	add_suffix = "polearm"
	icon_state = "nt_blue_very"
	length = 30
	icon = 'icons/obj/items/modular_guns/64.dmi'
	bulkiness = 5

/obj/item/gun_parts/barrel/NT/long/padded
	name = "padded long barrel"
	desc = "A cylindrical barrel, padded."
	spread_angle = 0
	add_suffix = "club"
	icon_state = "nt_guarded"
	overlay_x = 8
	bulkiness = 4

/obj/item/gun_parts/barrel/foss
	name = "\improper FOSS lensed barrel"
	desc = "A cylindrical array of lenses to focus laser blasts."
	spread_angle = 2
	lensing = 0.9
	part_DRM = GUN_FOSS | GUN_SOVIET | GUN_JUICE
	add_suffix = "lenser"
	icon = 'icons/obj/items/modular_guns/fossgun.dmi'
	icon_state = "barrel_short"
	contraband = 1
	length = 17

/obj/item/gun_parts/barrel/foss/long
	name = "\improper FOSS lensed long barrel"
	desc = "A cylindrical array of lenses to focus laser blasts."
	spread_angle = 1
	lensing = 1
	add_suffix = "focuser"
	icon_state = "barrel_long"
	length = 29
	bulkiness = 2

/obj/item/gun_parts/barrel/foss/long/very
	name = "\improper FOSS ultra lensed barrel"
	desc = "A hyperbolic array of lenses to focus laser blasts."
	spread_angle = -1
	lensing = 0.85
	add_suffix = "catalyst"
	icon = 'icons/obj/items/modular_guns/64.dmi' //can move this back to standard barrel, leave 64 for comedy
	icon_state = "foss_very_long"
	length = 28
	bulkiness = 3

/obj/item/gun_parts/barrel/juicer
	name = "\improper BLUNDA barrel"
	desc = "A cheaply-built shotgun barrel. And by cheaply-built I mean someone adapted a broken vuvuzela for a gun."
	spread_angle =  13 // jesus christ it's a spread machine
	jam_frequency = 5 //but very poorly built
	part_DRM = GUN_JUICE
	add_prefix = "BLUNDA"
	icon_state = "juicer_blunderbuss"
	length = 16
	bulkiness = 1
	caliber = CALIBER_WIDE
	//absolutely needs a quiet fucked up vuvuzela honk

/obj/item/gun_parts/barrel/juicer/chub
	name = "\improper BUSTIN barrel"
	desc = "Sawn-off shotgun barrel, hot-rodded with paint and donkey grease."
	part_DRM = GUN_JUICE | GUN_NANO
	spread_angle = 6
	length = 11
	icon_state = "juicer_chub"
	add_prefix = "BUSTA"
	bulkiness = 1

/obj/item/gun_parts/barrel/juicer/ribbed
	name = "\improper KNOBBIN barrel"
	desc = "Shotgun barrel: for yuor gun's pleansure."
	part_DRM = GUN_JUICE | GUN_NANO
	spread_angle = 4
	jam_frequency = 8
	length = 17
	icon_state = "juicer_ribbed"
	add_prefix = "Genthlemaenne's"
	bulkiness = 2

/obj/item/gun_parts/barrel/juicer/longer
	name = "\improper SNIPA barrel"
	desc = "A cheaply-built extended rifled shotgun barrel. Not good."
	part_DRM = GUN_JUICE | GUN_NANO
	spread_angle =  4 // accurate?? ish?
	jam_frequency = 15 //but very!!!!!!! poorly built
	add_prefix = "BLITZINNNNNNN'"
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
	add_suffix = "comrade"
	icon_state = "soviet_lens"
	length = 18

//quieter somehow but also less damage and very short range
/obj/item/gun_parts/barrel/soviet/covert
	name = "compact soviet beam former"
	spread_angle =  3
	lensing = 1.2
	part_DRM = GUN_SOVIET | GUN_ITALIAN
	add_suffix = "shpion"
	icon_state = "soviet_lens_snub"
	length = 14

//fire two projectiles at half damage and short range
/obj/item/gun_parts/barrel/soviet/scatter
	name = "soviet diffractor"
	spread_angle =  5
	lensing = 1.2
	part_DRM = GUN_SOVIET | GUN_ITALIAN
	add_suffix = "raskolnik"
	icon_state = "soviet_lens_scatter"
	length = 14

//longer range
/obj/item/gun_parts/barrel/soviet/long
	name = "focused soviet lenses"
	desc = "стопка линз для фокусировки вашего пистолета"
	part_DRM = GUN_SOVIET | GUN_ITALIAN
	spread_angle = 2
	lensing = 1.4
	add_suffix = "tovarisch"
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
	add_suffix = "medved"
	icon_state = "soviet_lens_dense"
	length = 25
	bulkiness = 2

/obj/item/gun_parts/barrel/italian
	name = "italian pistol barrel"
	real_name = "canna di fucile"
	desc = "una canna di fucile di base e di alta qualità"
	icon_state = "italian_revolver"
	part_DRM = GUN_ITALIAN | GUN_SOVIET
	add_suffix = "paisan"
	spread_angle = 5 // "alta qualità"
	length = 12
	overlay_x = 6
	bulkiness = 2

/obj/item/gun_parts/barrel/italian/derringer
	name = "italian derringer barrel"
	real_name = "canna di fucile corta"
	desc = "una canna di fucile dalle dimensioni minime in assoluto."
	icon_state = "italian_revolver_derringer"
	add_suffix = "carino"
	spread_angle = 5
	length = 2
	overlay_x = 2
	bulkiness = 1

/obj/item/gun_parts/barrel/italian/snub
	name = "italian snub barrel"
	real_name = "canna di fucile corta"
	desc = "una canna di fucile di base e di bellissima qualità"
	icon_state = "italian_revolver_snub"
	add_suffix = "paisanuccia"
	spread_angle = 7
	length = 5
	overlay_x = 3
	bulkiness = 1

/obj/item/gun_parts/barrel/italian/short
	name = "italian short barrel"
	real_name = "canna di fucile piccolo"
	desc = "una canna di fucile di base e di bellissima qualità"
	icon_state = "italian_revolver_short"
	add_suffix = "paisanetto"
	spread_angle = 6
	length = 7
	overlay_x = 4
	bulkiness = 1

/obj/item/gun_parts/barrel/italian/spicy
	name = "italian weighted barrel"
	real_name = "canna di fucile arrabiata"
	desc = "una canna di fucile di base e di bellissima qualità"
	icon_state = "italian_revolver_weighted"
	add_suffix = "paisana"
	spread_angle = 5
	overlay_x = 6

/obj/item/gun_parts/barrel/italian/accurate
	name = "italian sighted barrel"
	real_name = "buon canna di fucile"
	desc = "una canna di fucile di base e di bellissima qualità"
	icon_state = "italian_revolver_long"
	add_suffix = "paisano"
	spread_angle = 3
	overlay_x = 7

/obj/item/gun_parts/barrel/italian/buntline
	name = "italian buntline barrel"
	real_name = "canna di fucile extra lunga"
	desc = "una canna di fucile di base e di bellissima qualità"
	icon_state = "italian_revolver_buntline"
	add_suffix = "tiratore"
	spread_angle = 4
	length = 17
	overlay_x = 8

/obj/item/gun_parts/barrel/italian/joker
	name = "italian jokester barrel"
	real_name = "canna di fucile pagliaccioo"
	desc = "una canna di fucile di base e di bellissima qualità"
	icon_state = "italian_revolver_justsilly"
	add_suffix = "burlone"
	spread_angle = 5 //a little shaky
	length = 25
	overlay_x = 14
	bulkiness = 4

/obj/item/gun_parts/barrel/italian/tommy
	name = "italian thick ventilated barrel"
	real_name = "canna di fucile ventilata"
	desc = "una canna di fucile grande e ventilata a gas"
	icon_state = "italian_tommy"
	add_suffix = "sospettosa"
	spread_angle = 6
	length = 18
	overlay_x = 9
	bulkiness = 4
	caliber = CALIBER_WIDE
	// maybe MORE recoil?

/obj/item/gun_parts/barrel/italian/silenced
	name = "italian silenced barrel"
	real_name = "canna di fucile tacito"
	desc = "Una sottile canna di pistola racchiusa in un robusto silenziatore e freno a gas."
	icon_state = "italian_silenced"
	add_suffix = "valentino"
	spread_angle = 4
	length = 16
	overlay_x = 8
	bulkiness = 4
	silenced = TRUE
	call_alter_projectile = TRUE

	alter_projectile(var/obj/item/gun/modular/gun, var/obj/projectile/P, var/mob/user)
		P.proj_data.shot_volume = P.proj_data.shot_volume * 0.25
		P.proj_data.shot_sound_extrarange = P.proj_data.shot_sound_extrarange - 11 // this magic number is one third of MAX_SOUND_RANGE
		playsound(get_turf(gun), 'sound/weapons/silencedshot.ogg', 40 + P.proj_data.shot_volume, extrarange = P.proj_data.shot_sound_extrarange)
		return ..()

/obj/item/gun_parts/barrel/italian/grenade
	name = "italian grenade barrel"
	real_name = "canna del lanciagranate"
	desc = "Una canna larga per lanciare granate. Non dovrebbe essere usata per proiettili più piccoli."
	icon_state = "italian_grenade"
	add_suffix = "pistoni"
	spread_angle = 4
	length = 18
	overlay_x = 9
	bulkiness = 4
	caliber = CALIBER_WIDE
	call_alter_projectile = TRUE

	alter_projectile(var/obj/item/gun/modular/gun, var/obj/projectile/P, var/mob/user)
		if (!(P.proj_data.caliber & CALIBER_SPUD))
			var/spread = rand(200) / 10 + 3
			P.rotateDirection(prob(50) ? spread : -spread)
			P.max_spread += spread
		return ..()

/obj/item/gun_parts/barrel/pipeframe
	name = "pipe barrel"
	real_name = "pipe barrel"
	desc = "A barrel made of metal pipe."
	icon_state = "pipe"
	add_prefix = "classic"
	part_DRM = GUN_NANO | GUN_JUICE | GUN_ITALIAN | GUN_SOVIET
	spread_angle = 9
	length = 13
	overlay_x = 7
	bulkiness = 4

// BASIC STOCKS
// Stocks should always have a negative spread angle unless they're particularly cumbersome.
// those ones probably add functionality that offsets the +ve spread?

/obj/item/gun_parts/grip/NT
	name = "standard grip"
	desc = "A comfortable NT pistol grip"
	spread_angle = -3 // basic stabilisation
	part_DRM = GUN_NANO
	add_prefix = "trusty"
	icon = 'icons/obj/items/modular_guns/grips.dmi'
	icon_state = "nt_blue"
	overlay_x = -3
	overlay_y = -3

/obj/item/gun_parts/grip/NT/ceremonial
	max_ammo_capacity = 1
	name = "ceremonial standard grip"
	icon_state = "nt_ceremonial"
	add_prefix = "shmancy"
	overlay_x = -2

/obj/item/gun_parts/grip/NT/fancy
	max_ammo_capacity = 1
	name = "fancy standard grip"
	icon_state = "nt_fancy"
	add_prefix = "fancy"
	overlay_x = -2

/obj/item/gun_parts/grip/NT/stub
	max_ammo_capacity = 1
	name = "stub grip"
	icon_state = "nt_stub"
	spread_angle = 0
	add_prefix = "stubby"
	overlay_x = -1

/obj/item/gun_parts/grip/NT/wood
	name = "wood grip"
	icon_state = "nt_rev"
	spread_angle = -1
	add_prefix = "woody"
	overlay_x = -2
	overlay_y = -2


/obj/item/gun_parts/grip/italian
	name = "italian pistol grip"
	real_name = "impugnatura a pistola"
	desc = "un'impugnatura rivestita in cuoio toscano per un revolver di alta qualità"
	spread_angle = 0
	max_ammo_capacity = 1 // to make that revolver revolve!
	jam_frequency = 3 // a lot  more jammy!!
	part_DRM = GUN_NANO | GUN_ITALIAN | GUN_SOVIET
	icon = 'icons/obj/items/modular_guns/grips.dmi'
	icon_state = "italian_plain"
	add_prefix = "quality"
	overlay_x = -2

/obj/item/gun_parts/grip/italian/bigger
	name = "italian fat grip"
	real_name = "impugnatura a pistola piu larga"
	desc = "un'impugnatura rivestita in cuoio toscano per un revolver di alta qualità"
	spread_angle = -1
	max_ammo_capacity = 3 // to make that revolver revolve!
	jam_frequency = 6 // a lot  more jammy!!
	part_DRM = GUN_ITALIAN | GUN_SOVIET
	icon_state = "italian_fancy"
	add_prefix = "jovial"
	bulkiness = 2
	overlay_x = -2

/obj/item/gun_parts/grip/italian/meatball
	name = "da meatballs"
	desc = "An extremely weirdly-shaped and red sauce-smelling combat grip, but it's definitely comfortable."
	spread_angle = -2
	max_ammo_capacity = 2
	jam_frequency = 4
	part_DRM = GUN_ITALIAN | GUN_SOVIET
	icon_state = "italian_meatballs"
	add_prefix = "polpetti"
	bulkiness = 2
	overlay_x = -2

/obj/item/gun_parts/grip/italian/cowboy
	name = "italian cowboy grip"
	desc = "Smells like spaghetti."
	spread_angle = 0
	max_ammo_capacity = 2
	jam_frequency = 4
	part_DRM = GUN_ITALIAN | GUN_SOVIET
	icon_state = "italian_cowboy"
	bulkiness = 2
	overlay_x = -3
	overlay_y = -3

/obj/item/gun_parts/grip/italian/cowboy/bandit
	name = "italian bandit grip"
	desc = "Looks like trouble."
	spread_angle = 3
	max_ammo_capacity = 1
	jam_frequency = 6
	icon_state = "italian_bandit"

/obj/item/gun_parts/grip/italian/cowboy/pearl
	name = "italian pearl grip"
	desc = "Tastes like plastic."
	spread_angle = -3
	max_ammo_capacity = 1
	jam_frequency = 2
	icon_state = "italian_pearl"


/obj/item/gun_parts/grip/juicer
	name = "da grip"
	desc = "some kind of knockoff tacticool pistol grip"
	spread_angle = -3
	icon = 'icons/obj/items/modular_guns/grips.dmi'
	icon_state = "white"
	add_prefix = "strapped"
	overlay_x = -2
	overlay_y = -1
	bulkiness = 2

/obj/item/gun_parts/grip/juicer/red
	name = "redgrip"
	icon_state = "red"
	add_prefix = "stylish"

/obj/item/gun_parts/grip/juicer/black
	name = "slick grip"
	icon_state = "black"
	add_prefix = "slick"

/obj/item/gun_parts/grip/juicer/trans
	name = "da brick"
	icon_state = "trans"
	throwforce = 10 // hehe
	add_prefix = "queer"

/obj/item/gun_parts/grip/foss
	name = "\improper FOSS grip"
	desc = "An open-sourced 3d-printed grip with dynamic angles. Comfort secondary."
	spread_angle = -3 // basic stabilisation
	part_DRM = GUN_FOSS
	add_prefix = "hands-on"
	icon_state = "foss"

/obj/item/gun_parts/grip/wizard
	name = "space wizard grip"
	desc = "Do you think space wizards know just how fucking insufferable they are? They have to, they really have to. They gotta be doing it on purpose. Holy shit."
	spread_angle = -3 // basic stabilisation
	add_prefix = "whizz-bang"
	icon_state = "wiz"

//stonks

/obj/item/gun_parts/stock/NT
	name = "standard stock"
	desc = "A comfortable NT shoulder stock"
	spread_angle = -4 // quite better stabilisation
	bulkiness = 3

	max_ammo_capacity = 2 // a few more rounds
	jam_frequency = 2 // a little more jammy
	icon = 'icons/obj/items/modular_guns/stocks.dmi'
	add_prefix = "sturdy"
	icon_state = "nt_solid"
	overlay_x = -8

/obj/item/gun_parts/stock/NT/precision
	name = "precision stock"
	desc = "A longer NT shoulder stock for precision"
	spread_angle = -6 // quite better stabilisation
	max_ammo_capacity = 1 // additional shot in the butt
	jam_frequency = 1 // not too bad
	add_suffix = "sharpshooter"
	icon_state = "nt_solid_precision"
	overlay_x = -10

/obj/item/gun_parts/stock/NT/wire
	name = "wire stock"
	desc = "An uncomfortable NT wire stock, but maybe some day it can fold up" //convert from 1-2 hand and conceal
	spread_angle = -2 // not as better stabilisation
	bulkiness = 1
	foldable = 1
	icon = 'icons/obj/items/modular_guns/stocks.dmi'
	add_prefix = "capable"
	icon_state = "nt_wire"
	overlay_x = 0 //generally wire stocks should be centered, using "template-offset" as a guide
	caliber = CALIBER_TINY // barely a stock at all

/obj/item/gun_parts/stock/NT/drum //TODO: make this fucker slow to load somehow
	name = "helical-magazine stock"
	desc = "A staggering 5 rounds can be loaded into this integral drum shoulder stock."
	spread_angle = -3 // quite better stabilisation
	bulkiness = 4

	max_ammo_capacity = 5
	jam_frequency = 5 // a little more jammy
	icon = 'icons/obj/items/modular_guns/stocks.dmi'
	add_prefix = "appointed"
	icon_state = "nt_solid_mag"
	overlay_x = -9

/obj/item/gun_parts/stock/italian
	name = "italian hunting stock"
	real_name = "calcio del fucile"
	desc = "Un calcio in noce robusto ma leggero per la caccia."
	spread_angle = -5 // brety gud
	icon = 'icons/obj/items/modular_guns/stocks.dmi'
	add_suffix = "cacciatore"
	icon_state = "italian_solid"
	bulkiness = 3
	overlay_x = -9

/obj/item/gun_parts/stock/italian/wire
	name = "italian wire stock"
	real_name = "calcio dell'asta"
	desc = "Un solido ceppo in filo metallico italiano, decorato con foglia d'oro."
	spread_angle = -4 // not as great, but good
	bulkiness = 2
	//foldable = 1
	icon = 'icons/obj/items/modular_guns/stocks.dmi'
	add_suffix = "pirite"
	icon_state = "italian_wire"
	overlay_x = -7
	caliber = CALIBER_TINY // barely a stock at all

/obj/item/gun_parts/stock/soviet
	name = "hunting stock"
	desc = "A utilitarian Soviet stock (write this in russian later)" //convert from 1-2 hand and conceal
	spread_angle = -5 // brety gud
	bulkiness = 2
	//max_ammo_capacity = 0 // does not add ammo
	//jam_frequency = 3 // a little more jammy
	icon = 'icons/obj/items/modular_guns/stocks.dmi'
	add_suffix = "ustoychivyy"
	icon_state = "sov_solid"

/obj/item/gun_parts/stock/soviet/wire
	name = "wire stock"
	desc = "A long Soviet wire stock that currently doesn't fold"
	spread_angle = -2 // not as better stabilisation
	bulkiness = 1

	foldable = 1
	icon = 'icons/obj/items/modular_guns/stocks.dmi'
	add_prefix = "udobnyy"
	icon_state = "sov_wire"
	overlay_x = 0
	caliber = CALIBER_TINY // barely a stock at all

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

	add_prefix = "agile"
	icon = 'icons/obj/items/modular_guns/fossgun.dmi'
	icon_state = "stock_single"


/obj/item/gun_parts/stock/foss/long
	name = "\improper FOSS laser rifle stock"
	spread_angle = -4 // better stabilisation
	bulkiness = 3

	max_crank_level = 3 // for syndicate ops
	safe_crank_level = 2
	add_prefix = "lean"

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
	jam_frequency = 10
	flash_auto = TRUE
	max_crank_level = 25
	safe_crank_level = 15
	add_prefix = "automated"
	icon_state = "stock_double"
	bulkiness = 4

//mega charge for heavy hitting
//what if this requires two bulbs inserted to get crank 4 and if one breaks you're down to crank 2? hmm
/obj/item/gun_parts/stock/foss/longer
	name = "\improper FOSS laser punt gun stock"
	spread_angle = 3 // poor stabilisation
	bulkiness = 5

	max_crank_level = 5 // for syndicate ops
	safe_crank_level = 3
	jam_frequency = 5 // a little more jammy
	add_prefix = "six-sigma"
	icon_state = "stock_double_alt"

// BASIC ACCESSORIES
	// flashlight!!
	// grenade launcher!!
	// a horn!!
/obj/item/gun_parts/accessory/horn
	name = "tactical alerter"
	desc = "Efficiently alerts your squadron within miliseconds of target engagement, using cutting edge over-the-airwaves technology"
	call_alter_projectile = TRUE
	add_prefix = "tactical"
	icon_state = "alerter"

	alter_projectile(var/obj/item/gun/modular/gun, var/obj/projectile/P, var/mob/user)
		playsound(src.my_gun.loc, pick('sound/musical_instruments/Bikehorn_bonk1.ogg', 'sound/musical_instruments/Bikehorn_bonk2.ogg', 'sound/musical_instruments/Bikehorn_bonk3.ogg'), 50, 1, -1)
		return ..()

	attack_self(mob/user as mob)
		user.u_equip(src)
		user.show_text("You de-militarise the bike horn, turning it into a normal funny one.", "blue")
		var/obj/item/instrument/bikehorn/H = new()
		user.put_in_hand_or_drop(H)
		qdel(src)

/obj/item/gun_parts/accessory/flashlight
	name = "tactical enbrightener"
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
			my_gun.UpdateOverlays(I, "[part_type]")
			light_mode = 0
			light_good.update(0)
			return
		if(light_mode == 0) // dim mode
			set_icon_state(src.icon_on)
			var/image/I = image(icon, built_on)
			I.pixel_x = overlay_x
			I.pixel_y = overlay_y
			my_gun.UpdateOverlays(I, "[part_type]")
			light_mode = 1
			light_dim.update(1)
		else if(light_mode == 1) // actual flashlight mode
			light_dim.update(0)
			light_good.update(1)
			set_icon_state(src.icon_on)
			var/image/I = image(icon, built_focused)
			I.pixel_x = overlay_x
			I.pixel_y = overlay_y
			my_gun.UpdateOverlays(I, "[part_type]")
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
	name = "\improper NT weaponlight"
	desc = "A little more sensible than taping a handheld flashlight to your barrel. That is, if you're a COP."
	icon_state = "nt_flash"
	icon_off = "nt_flash"
	icon_on = "nt_flash_on"
	built_off = "nt_flash-built"
	built_on = "nt_flash-active"
	built_focused = "nt_flash-focused"

/obj/item/gun_parts/accessory/magazine/juicer
	name = "\improper HOTT SHOTTS MAG"
	desc = "Holds 3 rounds, and 30,000 followers."
	max_ammo_capacity = 3
	jam_frequency = 8
	add_suffix = "LARGE"
	icon = 'icons/obj/items/modular_guns/magazines.dmi'
	icon_state = "juicer_drum"

	four
		name = "\improper HOTTTER SHOTTTS MAG"
		desc = "Holds 4 rounds, and seems to be made out of some kind of cereal box."
		icon_state = "juicer_drum-bigger"
		max_ammo_capacity = 4
		jam_frequency = 16

	five
		name = "\improper HOTTTTEST SHOTTTTS MAG"
		desc = "Holds 5 rounds, attracts the ire of haters everywhere you go."
		icon_state = "juicer_drum-biggest"
		max_ammo_capacity = 5
		contraband = 5
		jam_frequency = 12
		bulkiness = 2

// the weird parts for glue'd gunse

/obj/item/gun_parts/barrel/MPRT
	name = "MPRT-7 barrel"
	desc = "A smoothbore tube to fire oversized warheads."
	icon_state = "mprt"
	part_DRM = GUN_FOSS
	caliber = CALIBER_WIDE
	overlay_x = 5
	length = 20
	muzzle_flash = "muzzle_flash_launch"
	bulkiness = 4
	spread_angle = 2
	call_alter_projectile = TRUE

	alter_projectile(var/obj/item/gun/modular/gun, var/obj/projectile/P, var/mob/user)
		if (!(P.proj_data.caliber & CALIBER_SPUD))
			var/spread = rand(200) / 10 + 3
			P.rotateDirection(prob(50) ? spread : -spread)
			P.max_spread += spread
		return ..()

/obj/item/gun_parts/stock/MPRT
	name = "MPRT-7 breach"
	desc = "A heat-shielded tube to vent propellant backblast behind the user."
	icon_state = "mprt"
	part_DRM = GUN_FOSS
	overlay_x = -12
	bulkiness = 4
	spread_angle = -3

/obj/item/gun_parts/barrel/NT/singularity_buster
	name = "Singularity Buster barrel"
	desc = "A lightweight barrel designed to fire at least three singularity busting warheads before safely disintegrating."
	icon_state = "antisingularity"
	caliber = CALIBER_WIDE
	overlay_x = 5
	length = 20
	muzzle_flash = "muzzle_flash_launch"
	bulkiness = 2
	spread_angle = 2
	call_alter_projectile = TRUE
	var/integrity = 15

	alter_projectile(var/obj/item/gun/modular/gun, var/obj/projectile/P, var/mob/user)
		if (P?.power && (P.power > 20 || prob(80 + P.power)))
			src.integrity -= P.power
		if(src.integrity <= 0)
			src.set_loc(get_turf(src))
			src.remove_part_from_gun()
			src.visible_message("\The [src] tears apart from wear!")
			src.combust(src)
		return ..()

/obj/item/gun_parts/stock/NT/singularity_buster
	name = "Singularity Buster breach"
	desc = "A composite breach designed to provide stability in high gravity environments."
	icon_state = "mprt"
	overlay_x = -12
	bulkiness = 3
	spread_angle = -3
