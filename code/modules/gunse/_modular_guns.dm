/*
 ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄                 ▄▄▄▄▄▄▄▄▄▄▄  ▄         ▄  ▄▄        ▄  ▄▄▄▄▄▄▄▄▄▄▄
▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌               ▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░▌      ▐░▌▐░░░░░░░░░░░▌
▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░▌               ▐░█▀▀▀▀▀▀▀▀▀ ▐░▌       ▐░▌▐░▌░▌     ▐░▌▐░█▀▀▀▀▀▀▀▀▀
▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌               ▐░▌          ▐░▌       ▐░▌▐░▌▐░▌    ▐░▌▐░▌
▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌               ▐░▌ ▄▄▄▄▄▄▄▄ ▐░▌       ▐░▌▐░▌ ▐░▌   ▐░▌▐░█▄▄▄▄▄▄▄▄▄
▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌               ▐░▌▐░░░░░░░░▌▐░▌       ▐░▌▐░▌  ▐░▌  ▐░▌▐░░░░░░░░░░░▌
▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌               ▐░▌ ▀▀▀▀▀▀█░▌▐░▌       ▐░▌▐░▌   ▐░▌ ▐░▌ ▀▀▀▀▀▀▀▀▀█░▌
▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌               ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌    ▐░▌▐░▌          ▐░▌
▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄      ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░▌     ▐░▐░▌ ▄▄▄▄▄▄▄▄▄█░▌
▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌     ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌      ▐░░▌▐░░░░░░░░░░░▌
 ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀       ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀        ▀▀  ▀▀▀▀▀▀▀▀▀▀▀

a new modular gun system
every /obj/item/gun/modular/ (a receiver) has some basic stats and handles shooting behavior.
by default all children of /obj/item/gun/modular/ should populate their own barrel/stock/magazine/accessory as appropriate
with some ordinary basic parts. barrel and grip or stock are pretty necessary, the other two whatever.
additional custom parts can be created with stat bonuses, and other effects in their add_part_to_gun() proc

TODO: make desc dynamic on build unless overridden by an existing desc (i.e. spawned from vending machine or on person)

"average" base spread is 5 without a barrel, other guns may be less accurate, few are more accurate - those that are have limiting factors.
having no barrel is +20 spread, having neither a stock nor grip is +10
in order to balance this, barrels should be balanced around -5 spread, and stocks around -5 (so -3 is a rough barrel, -7 is a great one, etc.)
giving an "average" spread for stock guns around 5-10
*/
//modular guns - guns systen - gunse systen - gun's systen - tags for Search Optimisation™

//remember: no "real" guns, and that doesn't just mean real guns with different goofy names!!!!

//receivers are at the center of everything, basically, so that's the part that makes a gun's a gun's
//If you want to spin off a new reciever, make sure it has: A different sprite, AND a different function- Not just numerical differences
//Generally, a manufacturer should have a similar action for all their receivers, in terms of how a player interacts with it

// add or subtract these when building the complete gun
#define STOCK_OFFSET_SHORT -3
#define STOCK_OFFSET_LONG -6
#define STOCK_OFFSET_BULLPUP -2
#define BARREL_OFFSET_SHORT 0
#define BARREL_OFFSET_LONG 4
#define GRIP_OFFSET_SHORT 0
#define GRIP_OFFSET_LONG -1
#define GRIP_OFFSET_BULLPUP 4
#define JAM_FIRE 1
#define JAM_CYCLE 2
#define JAM_LOAD 3
#define JAM_CATASTROPHIC 4
#define CALIBER_TINY  0 // 00 - tiny
#define CALIBER_WIDE  1 // 01 - wide
#define CALIBER_LONG  2 // 10 - long
#define CALIBER_LONG_WIDE CALIBER_LONG | CALIBER_WIDE // 11 - huge
//bitflags for finding your bits
#define GUN_PART_UNDEF  0
#define GUN_PART_BARREL 1
#define GUN_PART_STOCK  2
#define GUN_PART_GRIP   4
#define GUN_PART_MAG    8
#define GUN_PART_ACCSY  16

#define STANDARD_BARREL_LEN 20 // the formula that determines ALL GUN BARREL LENGTH DAMAGE SCALING. be careful with this one.
#define BARREL_SCALING(length) (1 + clamp(((length - STANDARD_BARREL_LEN) / (length + STANDARD_BARREL_LEN)) * 0.420, -0.25, 0.25))

ABSTRACT_TYPE(/obj/item/gun/modular)
/obj/item/gun/modular/ // PARENT TYPE TO ALL MODULER GUN'S
	var/no_build = FALSE //should this receiver be built from attached parts on spawn? (useful for only-receivers)
	//var/no_save = 0 // when 1, this should prevent the player from carrying it cross-round?
	icon = 'icons/obj/items/modular_guns/receivers.dmi'
	icon_state = "shittygun"
	wear_image_icon = 'icons/mob/back.dmi'
	wear_state = "shittygun"
	contraband = 0 //is this a crime gun made by and for crimers
	inventory_counter_enabled = 1
	appearance_flags = LONG_GLIDE | PIXEL_SCALE | KEEP_TOGETHER

	two_handed = FALSE
	can_dual_wield = TRUE

	// VARIABLES YOU CAN SET ON EACH RECIEVER
	var/gun_DRM = 0 // identify the gun model / type
	var/bulkiness = 1 //receivers have bulk too. total is reset to this on build.
	var/jam_frequency = 1 //base % chance to jam on reload. Just cycle again to clear.
	var/load_time = 1 SECOND // added to the load_time of the ammo
	var/reload_cooldown = 0.3 SECONDS // how often you can try to reload/clear jams
	var/max_ammo_capacity = 1 // How much ammo can this gun hold? Don't make this null (Convair880).
	var/sound_type = null //bespoke set of loading and cycling noises
	var/flashbulb_only = 0 // FOSS guns only

	//offsets and parts
	///how many pixels from the center (16,16) does the barrel attach. most barrels have 2 pixels above the center and 2 or 3 below.
	var/barrel_overlay_x = 0
	var/barrel_overlay_y = 0
	///how many pixels from the center (16,16) does the grip attach
	var/grip_overlay_x = 0
	var/grip_overlay_y = 0
	///how many pixels from the center (16,16) does the stock attach
	var/stock_overlay_x = 0
	var/stock_overlay_y = 0
	///how many pixels from the center (16,16) does the magazine attach
	var/magazine_overlay_x = 0
	var/magazine_overlay_y = 0


	// INTERNAL VARS - DO NOT MODIFY DIRECTLY
	current_projectile = null // chambered round
	var/list/casing_list = list() // a list of types that will clatter out, usually on reload
	var/list/ammo_list = list() // a list of datum/projectile types
	var/jammed = FALSE //got something stuck and unable to fire? good news these have defines now

	var/obj/item/gun_parts/barrel/barrel = null
	var/obj/item/gun_parts/grip/grip = null //need either a grip or a stock to sensibly use
	var/obj/item/gun_parts/stock/stock = null //optional
	var/obj/item/gun_parts/grip/foregrip = null // optional
	var/obj/item/gun_parts/magazine/magazine = null // sort of optional (juicer guns require mag)
	var/obj/item/gun_parts/accessory/accessory = null
	var/list/obj/item/gun_parts/parts = list()
	var/built = 0
	var/lensing = 0 // Variable used for optical gun barrels. laser intensity scales around 1.0 (or will!)
	var/caliber = 0 //see CALIBER defines, this is what sizes a gun can contain
	var/bulk = 1 //bulkiness should also impact recoil (todo)
	var/call_on_cycle = 0 //bitflag
	var/call_alter_projectile = 0 //bitflag
	var/chamber_checked = FALSE // this lets us fast-track alt-fire modes and stuff instead of re-checking the breech every time (reset this on pickup)
	var/accessory_alt = FALSE //does the accessory offer an alternative firing mode?

	// MYLIE TO DO - MOVE TO FOSS PARTS v
	var/flash_auto = 0 // FOSS auto-fire setting
	var/flashbulb_health = 0 // FOSS guns only
	var/unsafety = 0 // FOSS guns only (turn this on and exceed safe design specs)
	var/max_crank_level = 0 // FOSS guns only
	var/safe_crank_level = 0 // FOSS guns only
	var/crank_level = 0 // FOSS guns only
	var/currently_cranking_off = 0 // see above
	var/crank_channel = null //what channel is the flywheel loop playing on (for auto)
	var/processing_ammo = 0 //cycling ammo (separate from cranking off)
	// MYLIE TO DO - MOVE TO FOSS PARTS ^

	New()
		..()
		if (no_build)
			reset_gun()
		else
			make_parts()
			build_gun()

/obj/item/gun/modular/proc/make_parts()
	return

/obj/item/gun/modular/proc/check_DRM(var/obj/item/gun_parts/part)
	if(!istype(part))
		return 0
	if(!part.part_DRM || !src.gun_DRM)
		playsound(src.loc, "sound/machines/buzz-sigh.ogg", 50, 1)
		return 1
	else
		return (src.gun_DRM & part.part_DRM)

/obj/item/gun/modular/buildTooltipContent()
	. = ..()

	if(gun_DRM)
		. += "<div><span>DRM LICENSE: </span>"
		if(gun_DRM & GUN_NANO)
			. += "<img src='[resource("images/tooltips/temp_nano.png")]' alt='' class='icon' />"
		if(gun_DRM & GUN_FOSS)
			. += "<img src='[resource("images/tooltips/temp_foss.png")]' alt='' class='icon' />"
		if(gun_DRM & GUN_JUICE)
			. += "<img src='[resource("images/tooltips/temp_juice.png")]' alt='' class='icon' />"
		if(gun_DRM & GUN_SOVIET)
			. += "<img src='[resource("images/tooltips/temp_soviet.png")]' alt='' class='icon' />"
		if(gun_DRM & GUN_ITALIAN)
			. += "<img src='[resource("images/tooltips/temp_italian.png")]' alt='' class='icon' />"
		. += "</div>"

	if(barrel && barrel.length)
		. += "<div><span>Barrel length: [src.barrel.length] cm = [round(100 * BARREL_SCALING(src.barrel.length), 0.5)]% power </span></div>"

	. += "<div><span>Caliber: [src.caliber ? (src.caliber & CALIBER_LONG ? (src.caliber & CALIBER_WIDE ? "<b>Anythin'</b>" : "Long (Rifle)") : "Wide (Shotgun)") : "Small (Pistol)"]</span></div>"

	. += "<div><img src='[resource("images/tooltips/temp_spread.png")]' alt='' class='icon' /><span>Spread: [src.spread_angle]° </span></div>"

	if(lensing)
		. += "<div><img src='[resource("images/tooltips/lensing.png")]' alt='' class='icon' /><span>Lenses: [src.lensing] </span></div>"

	if(stock && crank_level)
		. += "<div><span>Spring tension: [src.crank_level] </span></div>"

	. += "<div><img src='[resource("images/tooltips/jamjarrd.png")]' alt='' class='icon' /><span>Jammin: [src.jam_frequency]% </span></div>"

	. += "<div><span>Bulk: [src.bulk][pick("kg","lb","0%"," finger")] </span></div>"

	. += "<div> <span>Maxcap: [src.max_ammo_capacity + 1] </span></div>"

	. += "<div> <span>Loaded: [src.ammo_reserve() + (src.current_projectile?1:0)] </span></div>"

	lastTooltipContent = .

/obj/item/gun/modular/displayed_power()
	if(src.current_projectile)
		return "[floor(current_projectile.power * BARREL_SCALING(src.barrel?.length))] dmg - [floor(current_projectile.ks_ratio * 100)]% lethal"
	return "[round(100 * BARREL_SCALING(src.barrel?.length), 0.5)]% power"

/obj/item/gun/modular/attackby(var/obj/item/I as obj, mob/user as mob)
	if (istype(I, /obj/item/stackable_ammo))
		actions.start(new/datum/action/bar/private/load_ammo(src, I), user)
		//var/obj/item/stackable_ammo/SA = I
		//SA.reload(src, user)
		return

	if (istype(I, /obj/item/screwdriver) && src.flashbulb_only)
		src.unsafety = !src.unsafety //toggle safety
		boutput(user,"<span class='notice'><b>You apply a little 'sudo unsafety [src.unsafety ? "TRUE" : "FALSE"]' to the FOSS cannon.</b></span>")
		if (unsafety)
			playsound(src.loc, "sound/machines/reprog.ogg", 55, 0)
		else
			playsound(src.loc, "sound/machines/reprog.ogg", 55, 0, pitch = 0.9)
		return

	if(istype(I,/obj/item/instrument/bikehorn))
		boutput(user,"<span class='notice'><b>You first radicalize [I] by telling it all about The Man.</b></span>")
		playsound(src, pick('sound/musical_instruments/Bikehorn_bonk1.ogg', 'sound/musical_instruments/Bikehorn_bonk2.ogg', 'sound/musical_instruments/Bikehorn_bonk3.ogg'), 50, 1, -1)
		user.u_equip(I)
		I = new /obj/item/gun_parts/accessory/horn()
		user.put_in_hand_or_drop(I)
		return

	if(istype(I,/obj/item/device/light/flashlight))
		boutput(user,"<span class='notice'><b>You first radicalize [I] telling it all about The Man.</b></span>")
		user.u_equip(I)
		I = new /obj/item/gun_parts/accessory/flashlight()
		user.put_in_hand_or_drop(I)
		return

	if(istype(I,/obj/item/gun_parts/))
		if(built)
			boutput(user,"<span class='notice'><b>You cannot place parts onto an assembled gun.</b></span>")
			return
		var/obj/item/gun_parts/part = I
		if(src.check_DRM(part))
			boutput(user,"<span class='notice'><b>You loosely place [I] onto [src].</b></span>")
			if (istype(I, /obj/item/gun_parts/barrel/))
				if(barrel) //occupado
					boutput(user,"<span class='notice'>...and knock [barrel] out of the way.</span>")
					barrel.set_loc(get_turf(src))
				barrel = I
			if (istype(I, /obj/item/gun_parts/stock/))
				if(stock) //occupado
					boutput(user,"<span class='notice'>...and knock [stock] out of the way.</span>")
					stock.set_loc(get_turf(src))
					stock = I
				else
					stock = I
			if (istype(I, /obj/item/gun_parts/grip/))
				if(grip) //occupado
					boutput(user,"<span class='notice'>...and knock [grip] out of the way.</span>")
					grip.set_loc(get_turf(src))
					grip = I
				else
					grip = I
			if (istype(I, /obj/item/gun_parts/magazine/))
				if(magazine) //occupado
					boutput(user,"<span class='notice'>...and knock [magazine] out of the way.</span>")
					magazine.set_loc(get_turf(src))
				magazine = I
			if (istype(I, /obj/item/gun_parts/accessory/))
				if(accessory) //occupado
					boutput(user,"<span class='notice'>...and knock [accessory] out of the way.</span>")
					accessory.set_loc(get_turf(src))
				accessory = I
			user.u_equip(I)
			I.dropped(user)
			I.set_loc(src)
			part.add_overlay_to_gun(src,0)
			//set the built receiver iconstate because this is sort of a WIP so, easier to figure out what the hell's going on
			//icon_state = "[initial(icon_state)]-built"
		else
			boutput(user,"<span class='notice'><b>The [src]'s DRM prevents you from attaching [I].</b></span>")
			playsound(src.loc, "sound/machines/twobeep.ogg", 55, 1)
	else
		..()


/// modular gunse recoil. generates 'implicit_recoil_strength' from gun bulet
/obj/item/gun/modular/handle_recoil(mob/user, turf/start, turf/target, POX, POY, first_shot = TRUE, force_projectile = FALSE)
	if (!recoil_enabled)
		return
	var/start_recoil = FALSE
	if (recoil == 0)
		start_recoil = TRUE // if recoil is 0, make sure do_recoil starts

	// Add recoil
	var/stacked_recoil = 0
	if (recoil_stacking_enabled)
		recoil_stacks += 1
		stacked_recoil = clamp(round(recoil_stacks) - recoil_stacking_safe_stacks,0,recoil_stacking_max_stacks) * recoil_stacking_amount
	var/datum/projectile/projectile = (force_projectile ? force_projectile : src.current_projectile)
	var/implicit_recoil_strength = 5*log(projectile.power * projectile.shot_number)
	recoil += (implicit_recoil_strength + stacked_recoil)
	recoil = clamp(recoil, 0, recoil_max)
	recoil_last_shot = TIME
	if (camera_recoil_enabled)
		do_camera_recoil(user, start,target,POX,POY)

	if (first_shot && projectile.shot_number > 1 && projectile.shot_delay > 0)
		for (var/i=1 to projectile.shot_number-1)
			var/force_proj = src.current_projectile
			SPAWN_DBG(i*projectile.shot_delay)
				handle_recoil(user,start,target,POX,POY, FALSE, force_proj) // hacky. pass current_projectile
	if (start_recoil && icon_recoil_enabled)
		SPAWN_DBG(0)
			do_icon_recoil()

// how much ammo is left outside the chamber, overriden by children
/obj/item/gun/modular/proc/ammo_reserve()
	return src.ammo_list ? length(src.ammo_list) : 0

/obj/item/gun/modular/proc/eject_casings()
	if (length(src.casing_list) > 0)
		var/turf/T = get_turf(src)
		if(T)
			SPAWN_DBG(0)
				var/i = 1
				var/batch = 3
				for(var/casing in src.casing_list)
					if(i == batch)
						sleep(1 DECI SECOND)
						i = 0
						batch++
					var/obj/new_casing = new casing(T) // make your casings pianos for all the shits i give - mylie
					new_casing.forensic_ID = src.forensic_ID
					i++
				src.casing_list.Cut()
	return

// load a piece of ammo, overriden by children
/obj/item/gun/modular/proc/load_ammo(var/mob/user, var/obj/item/stackable_ammo/donor_ammo)
	if(length(src.casing_list))
		boutput(user, "<span class='notice'>First, you clear the casings from [src].</span>")
		src.eject_casings()

	//single shot and chamber handling
	if(!src.current_projectile)
		boutput(user, "<span class='notice'>You stuff a cartridge down the barrel of [src].</span>")
		src.set_current_projectile(new donor_ammo.projectile_type())
		if (src.sound_type)
			playsound(src.loc, "sound/weapons/modular/[src.sound_type]-slowcycle.ogg", 60, 1)
		else
			playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)

	//load the magazine after the chamber
	else if (src.ammo_reserve() < src.max_ammo_capacity)
		if (src.sound_type)
			playsound(src.loc, "sound/weapons/modular/[src.sound_type]-load[rand(1,2)].ogg", 10, 1)
	else
		playsound(src.loc, "sound/weapons/gunload_light.ogg", 10, 1, 0, 0.8)
	src.ammo_list += donor_ammo.projectile_type

	buildTooltipContent()

	//Since we load the chamber first anyway there's no process_ammo call anymore. This can stay though
	if (prob(src.jam_frequency)) //jammed just because this thing sucks to load or you're clumsy
		src.jammed = JAM_LOAD
		boutput(user, "<span class='notice'>Ah, damn, that doesn't go in that way....</span>")
		return FALSE
	return TRUE

//Replaces /obj/item/stackable_ammo/proc/reload. Now also does distance interrupts and doesn't rely on sleeps
/datum/action/bar/private/load_ammo
	duration = 1 SECOND
	//Notably, can reload while moving
	interrupt_flags = INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	var/obj/item/stackable_ammo/donor_ammo
	var/obj/item/gun/modular/target_gun
	id = "load_ammo"

	proc/caliber_check(obj/item/gun/modular/gun, obj/item/stackable_ammo/ammo)
		if(ammo.caliber == CALIBER_TINY || gun.caliber == CALIBER_LONG_WIDE || gun.caliber == ammo.caliber)
			return 1
		return 0

	New(obj/item/gun/modular/gun, obj/item/stackable_ammo/ammo)
		if (!istype(gun) || !istype(ammo))
			interrupt(INTERRUPT_ALWAYS)
		//fucken flash bulbs
		/*if (!ammo.projectile_type)
			interrupt(INTERRUPT_ALWAYS)*/
		target_gun = gun
		donor_ammo = ammo
		duration = max(0.1 SECONDS, target_gun.load_time + donor_ammo.load_time) //baseline (NT) load_time is 1 second
		..()

	onStart()
		if (!ismob(owner)) //plenty of assuming this is true will follow (but mostly not needing typecasting)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (target_gun.jammed)
			boutput(src.owner, "<span class='alert'>This gun is jammed! (Press C to cycle)</span>")
			interrupt(INTERRUPT_ALWAYS)
			return

		//some hardcoded ammo incompatabilities
		//if (istype(donor_ammo, /obj/item/stackable_ammo/scatter) && !target_gun.scatter)
		//	boutput(owner, "<span class='notice'>That shell won't fit the breech.</span>")
		//	interrupt(INTERRUPT_ALWAYS)
		//	return
		if (!caliber_check(target_gun, donor_ammo))
			boutput(owner, "<span class='notice'>That cartridge won't fit the breech.</span>")
			interrupt(INTERRUPT_ALWAYS)
			return
		else if (istype(donor_ammo, /obj/item/stackable_ammo/flashbulb) && !target_gun.flashbulb_only)
			//Note that you can load regular ammo into flashbulb guns.
			//ATM this just makes the gun complain to the player and clear the round, but I believe there was the intent for firing like that to blow out the lenses
			boutput(owner, "<span class='notice'>This gun can't use flashtubes.</span>")
			interrupt(INTERRUPT_ALWAYS)
			return

		if(!target_gun.ammo_list)
			target_gun.ammo_list = list()

		target_gun.chamber_checked = FALSE
		loopStart()

		if (src.state == ACTIONSTATE_DELETE)
			return

		//Maybe if it's behind all the error checking we won't see the bar come up at all on failure?
		..()

		boutput(owner, "<span class='notice'>You start loading [istype(donor_ammo, /obj/item/stackable_ammo/flashbulb) ? "a flashtube" : "rounds"] into [target_gun].</span>")

		if (target_gun.flashbulb_only) //Apparently our joke on FOSS standards goes so deep even the real code for them has to be fucking bespoke
			playsound(target_gun.loc, "sound/weapons/casings/casing-0[rand(1,9)].ogg", 10, 0.1, 0, 0.8)
		else
			if (target_gun.sound_type)
				playsound(target_gun.loc, "sound/weapons/modular/[target_gun.sound_type]-startload.ogg", 60, 1)
			else
				playsound(target_gun.loc, "sound/weapons/gunload_click.ogg", 60, 1)

	loopStart()
		if (!donor_ammo || donor_ammo.disposed || !target_gun || target_gun.disposed) //gun or ammo missing
			interrupt(INTERRUPT_ALWAYS)
		if (GET_DIST(owner, target_gun) > 1 || GET_DIST(owner, donor_ammo) > 1) //gun or ammo out of range
			interrupt(INTERRUPT_ALWAYS)

		if(target_gun.current_projectile) //gun might be full
			if (!target_gun.max_ammo_capacity) //single shot
				boutput(owner, "<span class='notice'>There's already a cartridge in [target_gun]!</span>")
				interrupt(INTERRUPT_ALWAYS)
			else if (target_gun.ammo_reserve() >= target_gun.max_ammo_capacity) //multi shot
				boutput(owner, "<span class='notice'>You can't load [target_gun] any further!</span>")
				interrupt(INTERRUPT_ALWAYS)

	onEnd()
		//one more distance check
		if (GET_DIST(owner, target_gun) > 1 || GET_DIST(owner, donor_ammo) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return ..()

		//special handling for flash bulbs, which don't have projectile_type I guess. onStart should have validated the gun and ammo with each other.
		if (!donor_ammo.projectile_type)
			if(target_gun.ammo_reserve() < target_gun.max_ammo_capacity)
				target_gun.ammo_list += donor_ammo
				var/mob/M = owner
				M.u_equip(donor_ammo)
				donor_ammo.dropped(owner)
				donor_ammo.set_loc(target_gun)
				playsound(target_gun.loc, "sound/items/Screwdriver.ogg", 30, 0.1, 0, 0.8)
				if(!target_gun.flashbulb_health)
					target_gun.flash_process_ammo(owner)
				boutput(owner, "<span class='notice'>You finish loading a flashtube into [target_gun].</span>")

		else //All normal guns
			if(!target_gun.load_ammo(owner, donor_ammo))
				interrupt(INTERRUPT_ALWAYS)

			donor_ammo.change_stack_amount(-1)
		eat_twitch(target_gun) //om nom nom

		var/stored_ammo_left = target_gun.ammo_reserve()
		//update ammo counter
		if(!target_gun.flashbulb_only) //FOSS guns already do it in flash_process_ammo()
			target_gun.inventory_counter.update_number(stored_ammo_left + !!target_gun.current_projectile)

		if(!donor_ammo.amount) //probably more useful to tell a single-shot user they ran out of ammo than that they have a full gun.
			boutput(owner, "<span class='notice'>All the ammo has been loaded.</span>")
			..()
		else if (stored_ammo_left == target_gun.max_ammo_capacity)
			boutput(owner, "<span class='notice'>The hold is now fully loaded.</span>")
			if (target_gun.sound_type)
				playsound(target_gun.loc, "sound/weapons/modular/[target_gun.sound_type]-stopload.ogg", 30, 1)
			else
				playsound(target_gun.loc, "sound/weapons/gunload_heavy.ogg", 30, 0.1, 0, 0.8)
			..()
		else if (src.state == ACTIONSTATE_DELETE) //we jammed mid reload
			..()
		else
			onRestart()
		return

/obj/item/gun/modular/alter_projectile(var/obj/projectile/P, var/mob/user)
	if(call_alter_projectile)
		if(call_alter_projectile & GUN_PART_BARREL)
			barrel.alter_projectile(src, P, user)
		if(call_alter_projectile & GUN_PART_STOCK)
			stock.alter_projectile(src, P, user)
		if(call_alter_projectile & GUN_PART_GRIP)
			grip.alter_projectile(src, P, user)
		if(call_alter_projectile & GUN_PART_MAG)
			magazine.alter_projectile(src, P, user)
		if(call_alter_projectile & GUN_PART_ACCSY)
			accessory.alter_projectile(src, P, user)

	if(P.proj_data.window_pass)
		if(lensing)
			P.power *= lensing + 0.2
			return
		P.power *= PROJ_PENALTY_BARREL
		return

	else
		if(!barrel)
			P.power *= PROJ_PENALTY_BARREL
			if(usr && (prob(10)))
				boutput(usr, "<span class='alert'><b>You're stunned by the uncontained muzzle flash!</b></span>")
				usr.apply_flash(2,1,1,0,1,1)
			return

		if(barrel && lensing)
			src.jammed = JAM_FIRE
			barrel.lensing = 0
			barrel.spread_angle += 5
			barrel.desc += " The internal lenses have been destroyed."
			src.lensing = 0
			src.spread_angle += 5 // this will reset to stock when the gun is rebuilt
			src.jam_frequency += 10 // this will reset to stock when the gun is rebuilt
			//src.jam_frequency += 5 // this will reset to stock when the gun is rebuilt
			P.power *= PROJ_PENALTY_BARREL
			if(usr)
				boutput(usr, "<span class='alert'><b>[src.barrel] is shattered by the projectile!</b></span>")
			playsound(get_turf(src), "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
			barrel.buildTooltipContent()
			buildTooltipContent()
			return

		P.power *= BARREL_SCALING(src.barrel?.length)
		return

//handle flashtube and cranking for foss lasers. returns 1 if good to go
//order: fix jam, check bulb and crank,
/obj/item/gun/modular/proc/flash_process_ammo(mob/user)
	if(processing_ammo)
		return 0

	//check if the dynamo got sproinged or whatever and fix it
	switch(jammed)
		if (JAM_FIRE) //problem on firing
			boutput(user,"<span class='notice'><b>You tighten the loose wires.</b></span>")
			jammed = FALSE
			playsound(src.loc, "sound/items/Ratchet.ogg", 40, 1)
			return 0
		if (JAM_CYCLE) //problem on cycle
			boutput(user,"<span class='notice'><b>You free up the stuck dynamo.</b></span>")
			jammed = FALSE
			playsound(src.loc, "sound/items/Ratchet.ogg", 40, 1)
			return 0
		if (JAM_LOAD) //problem on load
			boutput(user,"<span class='notice'><b>You clear out the bent flashtube.</b></span>")
			jammed = FALSE
			playsound(src.loc, "sound/items/Screwdriver2.ogg", 40, 1)
			return 0
		if (JAM_CATASTROPHIC)//catastrophic failure
			boutput(user,"<span class='notice'><b>You clear the exploded flashtube's contacts out.</b></span>")
			jammed = FALSE
			playsound(src.loc, "sound/items/Screwdriver2.ogg", 40, 1)
			return 0

	//check if a valid working bulb is loaded and active
	if(flashbulb_health)
		processing_ammo = TRUE
		//confirm crank installed
		if(max_crank_level)
			crank(user)
			src.inventory_counter.update_number(crank_level)
			processing_ammo = FALSE
			return 1
		else
			boutput(user,"<span class='alert'><b>Error! Dynamo missing!</b></span>")
			processing_ammo = FALSE
			return 0

	if(!src.ammo_reserve()) //no bulbs in reserve? (behavior that will probably/possibly change)
		playsound(src.loc, "sound/weapons/Gunclick.ogg", 40, 1)
		return (current_projectile?1:0) //thinking this shouldn't be able to fire without a flashbulb, but for now...

	if(src.ammo_reserve() > max_ammo_capacity)
		var/waste = src.ammo_reserve() - max_ammo_capacity
		ammo_list.Cut(1,(1 + waste))
		boutput(user,"<span class='alert'><b>Error! Storage space low! Deleting [waste] ammunition...</b></span>")
		playsound(src.loc, "sound/items/mining_drill.ogg", 20, 1,0,0.8)

	if(src.ammo_reserve()) //check happens again because of process
		playsound(src.loc, "sound/weapons/Gunclick.ogg", 40, 1)
		return (current_projectile?1:0)

	else
		processing_ammo = TRUE
		var/obj/item/stackable_ammo/flashbulb/FB = ammo_list[src.ammo_reserve()]
		//check for right kind of ammo
		if(!istype(FB))
			boutput(user,"<span class='notice'><b>Error! This device is configured only for FOSS Cathodic Flash Bulbs.</b></span>")
			playsound(src.loc, "sound/machines/twobeep.ogg", 55, 1)
		else
			//check chance to cause a jam while loading
			if(prob(jam_frequency)) //very unlikely unless you're clumsy i guess
				jammed = JAM_LOAD
				boutput(user,"<span class='alert'><b>Shit! You accidentally bent the flashtube's contacts while installing it.</b></span>")
				playsound(src.loc, "sound/weapons/trayhit.ogg", 60, 1)
				ammo_list.Remove(FB) //see ya
				qdel(FB)
				processing_ammo = FALSE
				return 0

			//load it from the pile
			flashbulb_health = rand(FB.min_health, FB.max_health)
			boutput(user,"<span class='notice'><b>FOSS Cathodic Flash Bulb loaded.</b></span>")
			playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)

			ammo_list.Remove(FB) //and remove it from the list
			qdel(FB) //please don't qdel typepaths

		processing_ammo = FALSE
		return (current_projectile?1:0)

/obj/item/gun/modular/process_ammo(mob/user)
	if(call_on_cycle)
		if(call_on_cycle & GUN_PART_BARREL)
			barrel.on_cycle(src, current_projectile, user)
		if(call_on_cycle & GUN_PART_STOCK)
			stock.on_cycle(src, current_projectile, user)
		if(call_on_cycle & GUN_PART_GRIP)
			grip.on_cycle(src, current_projectile, user)
		if(call_on_cycle & GUN_PART_MAG)
			magazine.on_cycle(src, current_projectile, user)
		if(call_on_cycle & GUN_PART_ACCSY)
			accessory.on_cycle(src, current_projectile, user)

	if(flashbulb_only) // additional branch for suicide
		return flash_process_ammo(user)

	switch(jammed)
		if(JAM_FIRE) //problem on fire, either dud round or light strike
			if(prob(current_projectile.dud_freq)) //unlucky, dump the round
				src.jammed = FALSE
				src.set_current_projectile(null)
				//come up with a good sound for this
				boutput(user, "You pry the dud round out of [src]") //drop a dud
				return 0
			else //just hit it again it'll work for sure
				src.jammed = FALSE
				if (sound_type)
					playsound(src.loc, "sound/weapons/modular/[sound_type]-slowcycle.ogg", 40, 1)
				else
					playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 40, 1)
				boutput(user, "You re-cock the hammer on [src], ready to fire again.") //good 2 go
				return 1
		if(JAM_CYCLE) //failure to eject, that sorta thing
			src.jammed = FALSE
			boutput(user, "You pry the stuck casing out of [src].") //drop a shell or a damaged cartridge
			return 0
		if(JAM_LOAD)
			src.jammed = FALSE
			//come up with a good sound for this
			boutput(user, "You reseat the stuck round in [src].") //drop a shell or a damaged cartridge
			return 1
		//if(4) //squib, catastrophic failure, etc. real bad time. explode if shot, or requires repair?
		//if(5) //hangfire, figure out how to handle

	var/ammo_left = src.ammo_reserve()

	if(accessory && accessory_alt && (src.current_projectile || !ammo_left)) // accessory alt fire
		accessory.alt_fire()
		return 1

	if(ammo_left > src.max_ammo_capacity)
		var/waste = ammo_left - max_ammo_capacity
		src.ammo_list.Cut(1,(1 + waste))
		boutput(user,"<span class='alert'><b>Error! Storage space low! Deleting [waste] ammunition...</b></span>")
		playsound(src.loc, "sound/items/mining_drill.ogg", 20, 1,0,0.8)

	if(src.chamber_round(user)) //finally, attempt to load and cycle
		if (sound_type)
			playsound(src.loc, "sound/weapons/modular/[sound_type]-quickcycle[rand(1,2)].ogg", 40, 1)
		return TRUE
	return FALSE

/obj/item/gun/modular/proc/chamber_round(var/mob/user)
	var/ammo_left = src.ammo_reserve()
	if(current_projectile || !ammo_left)
		return FALSE
	if(prob(src.jam_frequency))
		src.jammed = JAM_LOAD
		boutput(user,"<span class='alert'><b>A cartridge gets wedged in wrong!</b></span>")
		playsound(src.loc, "sound/weapons/trayhit.ogg", 30, 1)
		return FALSE
	var/ammotype = ammo_list[ammo_left]
	src.set_current_projectile(new ammotype()) // this one goes in
	ammo_list.Remove(ammotype) //and remove it from the list
	return TRUE

//cycle weapon + update counter
/obj/item/gun/modular/attack_self(mob/user)
	if(flashbulb_only)
		flash_process_ammo(user)
		src.inventory_counter.update_number(crank_level)
	else
		if(!src.processing_ammo && (!src.reload_cooldown || !ON_COOLDOWN(user, "mess_with_gunse", src.reload_cooldown)))
			process_ammo(user)
		// this is how many shots are left in reserve- plus the one in the chamber. it was a little too confusing to not include it
		src.inventory_counter.update_number(src.ammo_reserve() + !!current_projectile)
	buildTooltipContent()
	SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user)

/obj/item/gun/modular/canshoot()
	if(jammed)
		return 0
	if(!built)
		return 0
	if(flashbulb_only && !flashbulb_health)
		return 0
	if(currently_cranking_off || processing_ammo)
		return 0
	if(flash_auto && !crank_level)
		return 0
	if(current_projectile)
		return 1
	return 0

/obj/item/gun/modular/shoot(var/target,var/start,var/mob/user,var/POX,var/POY,var/is_dual_wield)
	if (isghostdrone(user))
		user.show_text("<span class='combat bold'>Your internal law subroutines kick in and prevent you from using [src]!</span>")
		return FALSE
	if (!canshoot())
		if (ismob(user))
			user.show_text("*click* *click*", "red") // No more attack messages for empty guns (Convair880).
			if (!silenced)
				playsound(user, "sound/weapons/Gunclick.ogg", 60, 1)
		return FALSE
	if (!isturf(target) || !isturf(start))
		return FALSE
	if (!istype(src.current_projectile,/datum/projectile/))
		return FALSE

	//prevents reloading while shooting, among other things
	actions.interrupt(user, INTERRUPT_ACT)

	if (src.muzzle_flash)
		if (isturf(user.loc))
			var/turf/origin = user.loc
			muzzle_flash_attack_particle(user, origin, target, src.muzzle_flash)

	if (ismob(user))
		var/mob/M = user
		if (M.mob_flags & AT_GUNPOINT)
			for(var/obj/item/grab/gunpoint/G in M.grabbed_by)
				G.shoot()
		if(slowdown)
			SPAWN_DBG(-1)
				M.movement_delay_modifier += slowdown
				sleep(slowdown_time)
				M.movement_delay_modifier -= slowdown

	//jam regular gun's
	if(!flashbulb_only)
		if(prob(jam_frequency))
			jammed = JAM_FIRE
			user.show_text("The cartridge fails to go off!", "red")
			playsound(user, "sound/impact_sounds/Generic_Click_1.ogg", 60, 1)
			//check chance to have a worse misfire
			chamber_checked = FALSE
			return

	//jam flashbulb gun's
	else
		if(prob(jam_frequency))
			//if you're playing it unsafe
			if (unsafety)
				if (prob(max(0,(2 ^ (crank_level - safe_crank_level) + 5)))) //sudden and possibly explosive breakage versus expected burnout, with increasingly bad odds
					var/T = get_turf(src)
					explosion_new(src, T, crank_level, 1)
					jammed = JAM_CATASTROPHIC
					crank_level = 0
					flashbulb_health = 0
					user.show_text("The flashtube shatters suddenly and violently!", "red")
					playsound(user, "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 60, 1)
					//hurts and trouble all around
			//otherwise...
			flashbulb_health = max(0, flashbulb_health - (crank_level))
			if (flash_auto) //slow this down a bit
				crank_level = max(0, crank_level - rand(1,4))
				if (!crank_level)
					var/stopsound = sound(null, wait = 0, channel = crank_channel, repeat = 0)
					for (var/client/C in clients)
						C << stopsound
					crank_channel = 0
				else
					//Electronic, Computer, Hard Drive - 1990s Compaq Hard Drive, Spooling Up, Turning Off.wav by jaegrover -- https://freesound.org/s/262870/ -- License: Creative Commons 0
					if (crank_channel)
						playsound(src.loc, 'sound/weapons/modular/flywheel.ogg', (35 + (crank_level * 2)), 0, 3, pitch = (0.65 + (crank_level * 0.02)), forcechannel = crank_channel)
					else
						crank_channel = playsound(src.loc, 'sound/weapons/modular/flywheel.ogg', (35 + (crank_level *2)), 0, 3, pitch = (0.65 + (crank_level * 0.02)), returnchannel = TRUE)
			else
				//need a good *sproing* noise
				crank_level = 0
			if (flashbulb_health) //flash still there?
				jammed = JAM_FIRE
				user.show_text("A wire comes loose as [src] misfires and drops its charge!", "red")
			else
				user.show_text("The flashtube shorts out and dies!", "red")
			chamber_checked = FALSE
			return //stop
			//maybe a chance to force a shot if this is done while cranking rather than attempting to fire

	var/spread = is_dual_wield*10
	if (user.reagents)
		var/how_drunk = 0
		var/amt = user.reagents.get_reagent_amount("ethanol")
		switch(amt)
			if (110 to INFINITY)
				how_drunk = 2
			if (1 to 110)
				how_drunk = 1
		how_drunk = max(0, how_drunk - (isalcoholresistant(user) ? 1 : 0))
		spread += 5 * how_drunk
	spread = max(spread, spread_angle)

	spread += (recoil/recoil_max) * recoil_inaccuracy_max

	var/obj/projectile/P = shoot_projectile_ST_pixel_spread(user, current_projectile, target, POX, POY, spread, alter_proj = new/datum/callback(src, PROC_REF(alter_projectile)))
	if (P)
		P.forensic_ID = src.forensic_ID
		if(current_projectile.casing)
			casing_list.Add(current_projectile.casing)

	chamber_checked = FALSE

	if(user && !suppress_fire_msg)
		if(!src.silenced)
			for(var/mob/O in AIviewers(user, null))
				O.show_message("<span class='alert'><B>[user] fires [src] at [target]!</B></span>", 1, "<span class='alert'>You hear a gunshot!</span>", 2)
		else
			if (ismob(user)) // Fix for: undefined proc or verb /obj/item/mechanics/gunholder/show text().
				user.show_text("<span class='alert'>You silently fire the [src] at [target]!</span>") // Some user feedback for silenced guns would be nice (Convair880).

		var/turf/T = target
		src.log_shoot(user, T, P)

	SEND_SIGNAL(user, COMSIG_CLOAKING_DEVICE_DEACTIVATE)
	handle_recoil(user, start, target, POX, POY)
#ifdef DATALOGGER
	if (game_stats && istype(game_stats))
		game_stats.Increment("gunfire")
#endif

	if (ismob(user))
		var/mob/M = user
		if (ishuman(M) && src.add_residue) // Additional forensic evidence for kinetic firearms (Convair880).
			var/mob/living/carbon/human/H = user
			H.gunshot_residue = 1

	//might move this to the fossgun shoot()
	if(flashbulb_health)// this should be nonzero if we have a flashbulb loaded.
		if(flash_auto && crank_level) // auto-fire special handling
			flashbulb_health--
			crank_level--
			if (!crank_level) //are we stopped?
				var/stopsound = sound(null, wait = 0, channel = crank_channel, repeat = 0)
				for (var/client/C in clients)
					C << stopsound
				crank_channel = 0
			else //no, still going, but at a new and slower speed
				//Electronic, Computer, Hard Drive - 1990s Compaq Hard Drive, Spooling Up, Turning Off.wav by jaegrover -- https://freesound.org/s/262870/ -- License: Creative Commons 0
				if (crank_channel)
					playsound(src.loc, 'sound/weapons/modular/flywheel.ogg', (35 + (crank_level * 2)), 0, 3, pitch = (0.65 + (crank_level * 0.02)), forcechannel = crank_channel)
				else
					crank_channel = playsound(src.loc, 'sound/weapons/modular/flywheel.ogg', (35 + (crank_level *2)), 0, 3, pitch = (0.65 + (crank_level * 0.02)), returnchannel = TRUE)
		else
			flashbulb_health = max(0,(flashbulb_health - crank_level - (0.5 * (max(0,max_crank_level - crank_level))))) //subtract cranks from life, cranks over max crank level are cranks and a half for bulb lifetime purposes
			crank_level = 0 // reset

		if(!flashbulb_health) // that was the end of it after applying extra damage!
			if((!unsafety && crank_level && !flash_auto))
				user.show_text("<span class='alert'>Your gun's flash bulb burns out and auto-releases your wind-up doohickey!</span>")
				crank_level = 0
			else
				user.show_text("<span class='alert'>Your gun's flash bulb burns out!</span>")
	//give player a scaling zap if they try to shoot their crank_level with no bulb and safety protocols off
	else if (unsafety)
		user.show_text("<span class='alert'>Your gun gives you a nasty discharge of current without a loaded flashtube to conduct it! ROLEPLAY IT</span>")
		//apply shock/burn/possible stun depending on crank level (auto)
		//force drop of gun if not stunned but shock was bad enough
		//force scream
		crank_level = 0
		return

	if(!flash_auto)
		src.set_current_projectile(null) // empty chamber

	src.update_icon()

	//updating count again after shooting
	if(flashbulb_only) //we just want to do this regardless of whatever happens with bulbs possibly burning out
		src.inventory_counter.update_number(crank_level)
	else
		src.inventory_counter.update_number(src.ammo_reserve() + !!current_projectile)

	if(prob(jam_frequency))
		jammed = JAM_CYCLE
		if (flashbulb_only)
			boutput(user,"<span class='alert'><b>The dynamo gets stuck!</b></span>") //slammed forward too fast or whatever
		else
			boutput(user,"<span class='alert'><b>The casing gets stuck!</b></span>") //failed to eject
		playsound(src.loc, "sound/weapons/trayhit.ogg", 30, 1)

	return TRUE

/obj/item/gun/modular/shoot_point_blank(var/mob/M as mob, var/mob/user as mob, var/second_shot = 0)
	..()
	if (flashbulb_only)
		if (flash_auto)
			crank_level--
		else
			crank_level = 0
	src.set_current_projectile(null) // empty chamber
	src.update_icon()

/obj/item/gun/modular/proc/build_gun()
	name = real_name
	icon_state = initial(icon_state)//if i don't do this it's -built-built-built

	bulk = src.bulkiness

	parts = list()
	if(barrel)
		parts += barrel
	else
		spread_angle += BARREL_PENALTY
	if(magazine)
		parts += magazine
	if(grip)
		parts += grip
	if(stock)
		parts += stock
	if(!grip && !stock)
		spread_angle += GRIP_PENALTY
	if(accessory)
		parts += accessory
	for(var/obj/item/gun_parts/part as anything in parts)
		part.add_part_to_gun(src)

	if((src.bulk + !!stock) > 7 || src.flashbulb_only) //flashfoss always two hands, how else will you crank off
		src.two_handed = TRUE

	src.force = floor(4 + src.bulk / 2)
	src.throwforce = floor(6 + src.bulk / 3)
	src.w_class = ceil(src.bulk / 3)

	src.spread_angle = max(0, src.spread_angle) // hee hoo

	if(src.two_handed)
		flags &= ~ONBELT
		flags |= ONBACK
		src.can_dual_wield = FALSE
	else
		flags &= ~ONBACK
		flags |= ONBELT
		src.can_dual_wield = TRUE
	buildTooltipContent()
	built = 1

	src.inventory_counter.update_number(0)

	//update the icon to match!!!!!

/obj/item/gun/modular/proc/reset_gun()
	icon_state = initial(icon_state)
	parts = list()
	barrel = null
	grip = null
	stock = null
	magazine = null
	accessory = null
	//foregrip = null

	name = "[real_name] receiver"

	max_crank_level = 0
	safe_crank_level = 0
	flashbulb_only = 0

	lensing = initial(lensing)
	muzzle_flash = 0
	silenced = 0
	accessory_alt = 0
	flash_auto = 0
	bulk = bulkiness
	caliber = 0

	call_on_cycle = 0
	call_alter_projectile = 0

	max_ammo_capacity = initial(max_ammo_capacity)
	jam_frequency = initial(jam_frequency)
	can_dual_wield = initial(can_dual_wield)
	two_handed = initial(two_handed)
	spread_angle = initial(spread_angle)
	w_class = initial(w_class)

// derringer-esque behavior for tiny gunse
/obj/item/gun/modular/afterattack(obj/O as obj, mob/user as mob)
	if (src.built && !src.stock && src.bulk <= 3 && O.loc == user && O != src && istype(O, /obj/item/clothing))
		playsound(user.loc, "rustle", 50, 1)
		boutput(user, SPAN_HINT("You hide the [src] inside \the [O]. (Use the wink emote while wearing the clothing item to retrieve it.)</span>"))
		for(var/mob/M in orange(3, user))
			boutput(M,SPAN_ALERT("[user] stuffs a gun inside \the [O]!"))
		user.u_equip(src)
		src.set_loc(O)
	else
		..()
	return

/obj/item/gun/modular/proc/crank(mob/user)
	if (currently_cranking_off)
		return

	SPAWN_DBG(0)
		//do no-crank cases first
		if(!unsafety)
			if(crank_level >= safe_crank_level) //training wheels still on, no crank
				boutput(user,"<span class='notice'><b>You're unable to crank further with the safety limits in place!</b></span>")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				currently_cranking_off = FALSE
				return
		else
			if(crank_level >= max_crank_level) //no safety but maxed out, no crank
				boutput(user,"<span class='notice'><b>You're unable to crank further! You're maxed out!</b></span>")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				currently_cranking_off = FALSE
				return

		//we're cranking, so do sound once
		currently_cranking_off = TRUE
		if (flash_auto)
			//need a better turning sound for the flywheel
			playsound(src.loc, "sound/machines/driveclick.ogg", 40, 0.2, pitch = (0.8 + (crank_level * 0.01)))
		else
			playsound(src.loc, "sound/machines/driveclick.ogg", 50, 0.2, pitch = (0.8 + (crank_level * 0.05)))

		//player messages
		if(crank_level < safe_crank_level) //basic crank
			boutput(user,"<span><b>You crank the handle.</b></span>")
		else if(unsafety)
			if(crank_level == safe_crank_level) //starting to get dongerous
				boutput(user,"<span class='notice'><b>You crank the handle past design specifications!</b></span>")
			else if(crank_level > safe_crank_level) //over the limit
				if (max_crank_level > crank_level + 1)
					boutput(user,"<span class='notice'><b>You keep cranking!</b></span>")
				else //maxed out on this crank
					boutput(user,"<span class='notice'><b>You crank the handle to the absolute limit!</b></span>")

		//do the thing and finish up: loaders are faster
		if (flash_auto)
			sleep(0.20 SECONDS)
		else
			sleep(0.80 SECOND)
		crank_level++


		if(flash_auto) // keep the projectile at level 1 after incrementing the crank level for autoloader
			if(!current_projectile)
				src.set_current_projectile(new /datum/projectile/laser/flashbulb())
			src.inventory_counter.update_number(crank_level)
			//07_Flywheel Toy Car.wav by 14GPanskaVitek_Martin -- https://freesound.org/s/420215/ -- License: Attribution 3.0
			playsound(src.loc, "sound/weapons/modular/crank-flywheel.ogg", 60, 0, pitch = (0.65 + (crank_level * 0.03)))
			sleep (0.30 SECONDS)
			if (!((crank_level) % 5)) //beep every 5
				playsound(src.loc, "sound/machines/twobeep.ogg", 55, 0, pitch = (0.65 + (crank_level * 0.02)))
			//Electronic, Computer, Hard Drive - 1990s Compaq Hard Drive, Spooling Up, Turning Off.wav by jaegrover -- https://freesound.org/s/262870/ -- License: Creative Commons 0
			if (crank_channel)
				playsound(src.loc, 'sound/weapons/modular/flywheel.ogg', (35 + (crank_level * 2)), 0, 3, pitch = (0.65 + (crank_level * 0.02)), forcechannel = crank_channel)
			else
				crank_channel = playsound(src.loc, 'sound/weapons/modular/flywheel.ogg', (35 + (crank_level *2)), 0, 3, pitch = (0.65 + (crank_level * 0.02)), returnchannel = TRUE)
			currently_cranking_off = FALSE

			return

		playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1) //sound that plays when you stop crankin

		sleep(0.20 SECONDS)
		if(current_projectile)
			qdel(current_projectile)
		switch(crank_level)
			if (0)
				src.set_current_projectile(null) // this shouldnt happen but just in case!
			if (1)
				src.set_current_projectile(new /datum/projectile/laser/flashbulb())
			if (2)
				src.set_current_projectile(new /datum/projectile/laser/flashbulb/two())
			if (3)
				src.set_current_projectile(new /datum/projectile/laser/flashbulb/three())
			if (4)
				src.set_current_projectile(new /datum/projectile/laser/flashbulb/four())
			if (5)
				src.set_current_projectile(new /datum/projectile/laser/flashbulb/five())
		playsound(src.loc, "sound/machines/twobeep.ogg", 55, 0, pitch = (0.5 + (crank_level * 0.15))) //eventually make this buzzes and alarms and etc.
		src.inventory_counter.update_number(crank_level)
		currently_cranking_off = FALSE

/obj/item/gun/modular/proc/handle_egun_shit(mob/user)
	return

//a receiver that represents the basic standard mounting positions and changes between them when used in hand
//clickdrag onto itself to assemble/disassemble
//will revisit this later
/*
/obj/item/gun/modular/debug
	var/debugnum = 0 //start basic
	var/debugmax = 6 //six debug
	icon = 'icons/obj/items/modular_guns/receivers.dmi'
	icon_state = "debug-0"

	shoot() //a dud
		return

	attack_self(mob/user) //click in hand
		if (src.debugnum < src.debugmax)
			src.debugnum++
		else
			src.debugnum = 0
		icon_state = "debug-[src.debugnum]"

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob) //built in anvil
		if (O == src)
			var/obj/item/gun/modular/debug/gun = O
			var/obj/item/gun_parts/part = null
			if(!gun.built)
				gun.ClearAllOverlays(1)
				boutput(user, "<span class='notice'>You debug the pieces of the gun into place!</span>")
				playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1)
				user.u_equip(gun)
				gun.dropped(user)
				gun.set_loc(user.loc)
				gun.build_gun()
				return
			else
				boutput(user, "<span class='notice'>You debug the pieces of the gun apart!</span>")
				playsound(src.loc, "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
				if(gun.barrel)
					part = gun.barrel.remove_part_from_gun()
					part.set_loc(user.loc)
				if(gun.grip)
					part = gun.grip.remove_part_from_gun()
					part.set_loc(user.loc)
				if(gun.stock)
					part = gun.stock.remove_part_from_gun()
					part.set_loc(user.loc)
				if(gun.foregrip)
					part = gun.foregrip.remove_part_from_gun()
					part.set_loc(user.loc)
				if(gun.magazine)
					part = gun.magazine.remove_part_from_gun()
					part.set_loc(user.loc)
				if(gun.accessory)
					part = gun.accessory.remove_part_from_gun()
					part.set_loc(user.loc)
				user.u_equip(gun)
				gun.dropped(user)
				gun.set_loc(user.loc)
				gun.reset_gun() // back to inits
				gun.buildTooltipContent()
				gun.built = 0
				gun.ClearAllOverlays(1) // clear the part overlays but keep cache? idk if thats better or worse.
			//else if (O == user)
			//pop up offset editor?
		else
			return
*/
