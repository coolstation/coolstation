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
every /obj/item/gun/modular/ has some basic stats and some basic shooting behavior. Nothing super complex.
by default all children of /obj/item/gun/modular/ should populate their own barrel/stock/magazine/accessory as appropriate
with some ordinary basic parts. barrel and mag are necessary, the other two whatever.
additional custom parts can be created with stat bonuses, and other effects in their add_part_to_gun() proc

TODO: make desc dynamic on build unless overridden by an existing desc (i.e. spawned from vending machine or on person)

"average" base spread is 25 without a barrel, other guns may be less accurate, perhaps up to 30. few should ever be more accurate.
in order to balance this, barrels should be balanced around ~ -15 spread, and stocks around -5 (so -13 is a rough barrel, -17 is a good one, etc.)
giving an "average" spread for stock guns around 5-10
*/
//modular guns - guns systen - gun's systen - tags for Search Optimisation™

//remember: no "real" guns, and that doesn't just mean real guns with different goofy names!!!!

//receivers are at the center of everything, basically, so that's the part that makes a gun's a gun's

// add or subtract these when building the complete gun
#define STOCK_OFFSET_SHORT -3
#define STOCK_OFFSET_LONG -6
#define STOCK_OFFSET_BULLPUP -2
#define BARREL_OFFSET_SHORT 0
#define BARREL_OFFSET_LONG 4
#define GRIP_OFFSET_SHORT 0
#define GRIP_OFFSET_LONG -1
#define GRIP_OFFSET_BULLPUP 4

ABSTRACT_TYPE(/obj/item/gun/modular)
/obj/item/gun/modular/ // PARENT TYPE TO ALL MODULER GUN'S
	var/gun_DRM = 0 // identify the gun model / type
	var/obj/item/gun_parts/barrel/barrel = null
	var/obj/item/gun_parts/grip/grip = null //need either a grip or a stock to sensibly use
	var/obj/item/gun_parts/stock/stock = null //optional
	var/obj/item/gun_parts/grip/foregrip = null // optional
	var/obj/item/gun_parts/magazine/magazine = null // sort of optional (juicer guns require mag)
	var/obj/item/gun_parts/accessory/accessory = null
	var/list/obj/item/gun_parts/parts = list()
	var/built = 0
	var/no_build = FALSE //should this receiver be built from attached parts on spawn? (useful for only-receivers)
	var/no_save = 0 // when 1, this should prevent the player from carrying it cross-round?
	icon = 'icons/obj/items/modular_guns/receivers.dmi'
	icon_state = "shittygun"
	contraband = 0 //is this a crime gun made by and for crimers
	inventory_counter_enabled = 1
	var/bulk = 1 //bulkiness should also impact recoil (not as a real modeled thing but a time between shots/comedic whoopsies)
	var/bulkiness = 1 //receivers have bulk too.

	//offsets and parts
	var/barrel_overlay_x = 0 //barrel attachment offset relative to standard (16,19 to 16,16) part attachment
	var/barrel_overlay_y = 0
	var/bullpup_stock = 0 // place stock directly behind grip and redraw receiver greebles over top to cover it again
	var/grip_overlay_x = 0 //grip attachment offset relative to standard (12,16) attachment point on small receiver
	var/grip_overlay_y = 0 //easiest to use templates to make it consistent: less math/offsetting
	var/stock_overlay_x = 0 //stock attachment offset relative to standard (16,19 to 16,16) part attachment
	var/stock_overlay_y = 0
	var/foregrip_offset_x = 8 //where to place the foregrip relative to the grip (default: 8 inches)
	var/foregrip_offset_y = 0
	var/magazine_overlay_x = 0
	var/magazine_overlay_y = 0
	//TODO: changeable offsets to handle 1 vs 2 handedness, barrel length, stock size, etc.

	var/lensing = 0 // Variable used for optical gun barrels. laser intensity scales around 1.0 (or will!)
	var/scatter = 0 // variable for using hella shotgun shells or something
	var/caliber = 0.31 //standard light barrel
	var/cartridge_length = 20 //standard small receiver

	var/flashbulb_only = 0 // FOSS guns only
	var/flash_auto = 0 // FOSS auto-fire setting
	var/flashbulb_health = 0 // FOSS guns only
	var/unsafety = 0 // FOSS guns only (turn this on and exceed safe design specs)
	var/max_crank_level = 0 // FOSS guns only
	var/safe_crank_level = 0 // FOSS guns only
	var/crank_level = 0 // FOSS guns only
	var/currently_cranking_off = 0 // see above
	var/crank_channel = null //what channel is the flywheel loop playing on (for auto)

	var/auto_eject = 0 // Do we eject casings on firing, or on reload?
	var/casings_to_eject = 0 // kee ptrack
	var/max_ammo_capacity = 1 // How much ammo can this gun hold? Don't make this null (Convair880).
	var/list/ammo_list = list() // a list of datum/projectile types
	current_projectile = null // chambered round
	var/chamber_checked = 0 // this lets us fast-track alt-fire modes and stuff instead of re-checking the breech every time (reset this on pickup)
	var/hammer_cocked = FALSE //not everything is a hammer but this basically means ready to fire (single action will not fire if not cocked)
	var/action = null //what kinda gun is this
	//var/fire_delay = 0 //ticks between pulling trigger and actually shooting

	var/accessory_alt = 0 //does the accessory offer an alternative firing mode?
	var/accessory_on_fire = 0 // does the accessory need to know when you fire?
	var/accessory_on_cycle = 0 // does the accessory need to know you pressed C?

	var/jam_frequency_reload = 1 //base % chance to jam on reload. Just cycle again to clear.
	var/jam_frequency_fire = 1 //base % chance to jam on fire. Cycle to clear.
	//var/misfire_frequency = 1 //base % chance to fire wrong in some way
	//var/hangfire_frequency = 1 //base % chance to fail to fire immediately (but will after a delay, whether held or not)
	//var/catastrophic_frequency = 1 //base % chance to fire a bullet just enough to be really dangerous to the user. probably not fun to have to find a screwdriver or rod and poke it out so forget that
	var/jammed = 0 //got something stuck and unable to fire? for now: 1 for didn't go off, 2 for stuck, 3 for whatever TODO: MAKE DEFINES SO THESE AREN'T MAGIC NUMBERS I CAN'T KEEP TRACK OF BECAUSE I'M A REAL BIG IDIOT
	var/processing_ammo = 0 //cycling ammo (separate from cranking off)

	var/sound_type = null //bespoke set of loading and cycling noises

	two_handed = 0
	can_dual_wield = 1

	New()
		..()
		make_parts()
		if (no_build) //need to revisit
			reset_gun()
		else
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
	if(scatter)
		. += "<div><img src='[resource("images/tooltips/temp_scatter.png")]' alt='' class='icon' /></div>"

	. += "<div><img src='[resource("images/tooltips/temp_spread.png")]' alt='' class='icon' /><span>Spread: [src.spread_angle] </span></div>"

	if(lensing)
		. += "<div><img src='[resource("images/tooltips/lensing.png")]' alt='' class='icon' /><span>Lenses: [src.lensing] </span></div>"

	if(barrel && barrel.length)
		. += "<div><span>Barrel length: [src.barrel.length] </span></div>"

	if(stock && crank_level)
		. += "<div><span>Spring tension: [src.crank_level] </span></div>"

	if(jam_frequency_fire || jam_frequency_reload)
		. += "<div><img src='[resource("images/tooltips/jamjarrd.png")]' alt='' class='icon' /><span>Jammin: [src.jam_frequency_reload + src.jam_frequency_fire] </span></div>"

	. += "<div><span>Bulk: [src.bulk][pick("kg","lb","0%"," finger")] </span></div>"
	. += "<div> <span>Maxcap: [src.max_ammo_capacity] </span></div>"
	. += "<div> <span>Loaded: [src.ammo_list.len + (src.current_projectile?1:0)] </span></div>"

	lastTooltipContent = .

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
					//temporarily disabling all foregrip
					/*
					if(foregrip) //also occupado???? hmmm, time to chooce
						switch(alert("There's already both a grip and foregrip installed.", "Get A Grip, Buddy!!!", "Replace Grip", "Replace Foregrip", "Remove Both", "Cancel"))
							if("Replace Grip")
								boutput(user,"<span class='notice'>...and knock [grip] out of the way.</span>")
								grip.set_loc(get_turf(src))
								grip = I
							if("Replace Foregrip")
								boutput(user,"<span class='notice'>...and knock [foregrip] out of the way.</span>")
								foregrip.set_loc(get_turf(src))
								foregrip = I
							if("Remove Both")
								boutput(user,"<span class='notice'>...but change your mind and remove both [grip] and [foregrip].</span>")
								grip.set_loc(get_turf(src))
								grip = null
								foregrip.set_loc(get_turf(src))
								foregrip = null
					else //TODO: frontload check if it's even possible to install a foregrip here (gun/barrel limitation)
						switch(alert("There's already a grip installed.", "Get A Grip, Buddy!!!", "Replace Grip", "Install As Foregrip", "Cancel"))
							if("Replace Grip")
								boutput(user,"<span class='notice'>...and knock [grip] out of the way.</span>")
								grip.set_loc(get_turf(src))
								grip = I
							if("Install As Foregrip")
								boutput(user,"<span class='notice'>...in the forward position.</span>")
								foregrip.set_loc(get_turf(src))
								foregrip = I
						//a little awkward: i'd like to have an attackself interface on an unbuilt gun that lets you pop off items
						//at least to hold off until workbench is created
					*/
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
			icon_state = "[initial(icon_state)]-built"
		else
			boutput(user,"<span class='notice'><b>The [src]'s DRM prevents you from attaching [I].</b></span>")
			playsound(src.loc, "sound/machines/twobeep.ogg", 55, 1)
	else
		..()

//Replaces /obj/item/stackable_ammo/proc/reload. Now also does distance interrupts and doesn't rely on sleeps
/datum/action/bar/private/load_ammo
	duration = 1 SECOND
	//Notably, can reload while moving
	interrupt_flags = INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	var/obj/item/stackable_ammo/donor_ammo
	var/obj/item/gun/modular/target_gun
	id = "load_ammo"

	New(obj/item/gun/modular/gun, obj/item/stackable_ammo/ammo)
		if (!istype(gun) || !istype(ammo))
			interrupt(INTERRUPT_ALWAYS)
		//fucken flash bulbs
		/*if (!ammo.projectile_type)
			interrupt(INTERRUPT_ALWAYS)*/
		target_gun = gun
		donor_ammo = ammo
		..()

	onStart()
		if (!ismob(owner)) //plenty of assuming this is true will follow (but mostly not needing typecasting)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (target_gun.jammed)
			boutput(src.owner, "<span class='alert'>This gun is jammed!</span>")
			interrupt(INTERRUPT_ALWAYS)
			return

		//some hardcoded ammo incompatabilities
		if (istype(donor_ammo, /obj/item/stackable_ammo/scatter) && !target_gun.scatter)
			boutput(owner, "<span class='notice'>That shell won't fit the breech.</span>")
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
			else if (length(target_gun.ammo_list) >= target_gun.max_ammo_capacity) //multi shot
				boutput(owner, "<span class='notice'>You can't load [target_gun] any further!</span>")
				interrupt(INTERRUPT_ALWAYS)

	onEnd()
		//one more distance check
		if (GET_DIST(owner, target_gun) > 1 || GET_DIST(owner, donor_ammo) > 1)
			interrupt(INTERRUPT_ALWAYS)

		//special handling for flash bulbs, which don't have projectile_type I guess. onStart should have validated the gun and ammo with each other.
		if (!donor_ammo.projectile_type)
			if(target_gun.ammo_list.len < target_gun.max_ammo_capacity)
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
			//single shot and chamber handling
			if(!target_gun.current_projectile)
				boutput(owner, "<span class='notice'>You stuff a cartridge down the barrel of [target_gun]</span>")
				target_gun.current_projectile = new donor_ammo.projectile_type ()
				//play the sound here because single shot bypasses cycle_ammo
				if (target_gun.sound_type)
					playsound(target_gun.loc, "sound/weapons/modular/[target_gun.sound_type]-slowcycle.ogg", 60, 1)
				else
					playsound(target_gun.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)
				target_gun.hammer_cocked = TRUE

			//load the magazine after the chamber
			else if (length(target_gun.ammo_list) < target_gun.max_ammo_capacity)
				if (target_gun.sound_type)
					playsound(target_gun.loc, "sound/weapons/modular/[target_gun.sound_type]-load[rand(1,2)].ogg", 10, 1)
				else
					playsound(target_gun.loc, "sound/weapons/gunload_light.ogg", 10, 1, 0, 0.8)
				target_gun.ammo_list += donor_ammo.projectile_type

				//Since we load the chamber first anyway there's no process_ammo call anymore. This can stay though
				if (prob(target_gun.jam_frequency_reload)) //jammed just because this thing sucks to load or you're clumsy
					target_gun.jammed = 2
					boutput(owner, "<span class='notice'>Ah, damn, that doesn't go in that way....</span>")
					interrupt(INTERRUPT_ALWAYS)

			donor_ammo.change_stack_amount(-1)
		eat_twitch(target_gun) //om nom nom

		//update ammo counter
		if(!target_gun.flashbulb_only) //FOSS guns already do it in flash_process_ammo()
			if(target_gun.max_ammo_capacity)
				target_gun.inventory_counter.update_number(length(target_gun.ammo_list) + !!target_gun.current_projectile)
			else
				target_gun.inventory_counter.update_number(!!target_gun.current_projectile)


		if(!donor_ammo.amount) //probably more useful to tell a single-shot user they ran out of ammo than that they have a full gun.
			boutput(owner, "<span class='notice'>All the ammo has been loaded.</span>")
			..()
		else if (length(target_gun.ammo_list) == target_gun.max_ammo_capacity)
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

/obj/item/gun/modular/alter_projectile(var/obj/projectile/P)
	if(P.proj_data.window_pass)
		if(lensing)
			P.power *= lensing
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
			src.jammed = 1
			barrel.lensing = 0
			barrel.spread_angle += 5
			barrel.desc += " The internal lenses have been destroyed."
			src.lensing = 0
			src.spread_angle += 5 // this will reset to stock when the gun is rebuilt
			src.jam_frequency_fire += 5 // this will reset to stock when the gun is rebuilt
			src.jam_frequency_reload += 5 // this will reset to stock when the gun is rebuilt
			P.power *= PROJ_PENALTY_BARREL
			if(usr)
				boutput(usr, "<span class='alert'><b>[src.barrel] is shattered by the projectile!</b></span>")
			playsound(get_turf(src), "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
			barrel.buildTooltipContent()
			buildTooltipContent()
			return

		var/barrel_adjustment = max((barrel.length-STANDARD_BARREL_LEN)/((barrel.length+STANDARD_BARREL_LEN)/2)/1.5,-0.75)
		P.power *= min((1 + barrel_adjustment),2)
		return

//handle flashtube and cranking for foss lasers. returns 1 if good to go
//order: fix jam, check bulb and crank,
/obj/item/gun/modular/proc/flash_process_ammo(mob/user)
	if(processing_ammo)
		return 0

	//check if the dynamo got sproinged or whatever and fix it
	switch(jammed)
		if (1) //problem on firing
			boutput(user,"<span class='notice'><b>You tighten the loose wires.</b></span>")
			jammed = 0
			playsound(src.loc, "sound/items/Ratchet.ogg", 40, 1)
			return 0
		if (2) //problem on cycle
			boutput(user,"<span class='notice'><b>You free up the stuck dynamo.</b></span>")
			jammed = 0
			playsound(src.loc, "sound/items/Ratchet.ogg", 40, 1)
			return 0
		if (3) //problem on load
			boutput(user,"<span class='notice'><b>You clear out the bent flashtube.</b></span>")
			jammed = 0
			playsound(src.loc, "sound/items/Screwdriver2.ogg", 40, 1)
			return 0
		if (4)//catastrophic failure
			boutput(user,"<span class='notice'><b>You clear the exploded flashtube's contacts out.</b></span>")
			jammed = 0
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

	if(!ammo_list.len) //no bulbs in reserve? (behavior that will probably/possibly change)
		playsound(src.loc, "sound/weapons/Gunclick.ogg", 40, 1)
		return (current_projectile?1:0) //thinking this shouldn't be able to fire without a flashbulb, but for now...

	if(ammo_list.len > max_ammo_capacity)
		var/waste = ammo_list.len - max_ammo_capacity
		ammo_list.Cut(1,(1 + waste))
		boutput(user,"<span class='alert'><b>Error! Storage space low! Deleting [waste] ammunition...</b></span>")
		playsound(src.loc, 'sound/items/mining_drill.ogg', 20, 1,0,0.8)

	if(!ammo_list.len) //check happens again because of process
		playsound(src.loc, "sound/weapons/Gunclick.ogg", 40, 1)
		return (current_projectile?1:0)

	else
		processing_ammo = TRUE
		var/obj/item/stackable_ammo/flashbulb/FB = ammo_list[ammo_list.len]
		//check for right kind of ammo
		if(!istype(FB))
			boutput(user,"<span class='notice'><b>Error! This device is configured only for FOSS Cathodic Flash Bulbs.</b></span>")
			playsound(src.loc, "sound/machines/twobeep.ogg", 55, 1)
		else
			//check chance to cause a jam while loading
			if(prob(jam_frequency_reload)) //very unlikely unless you're clumsy i guess
				jammed = 3
				boutput(user,"<span class='alert'><b>Shit! You accidentally bent the flashtube's contacts while installing it.</b></span>")
				playsound(src.loc, "sound/weapons/trayhit.ogg", 60, 1)
				qdel(ammo_list[ammo_list.len])
				ammo_list.Remove(ammo_list[ammo_list.len]) //see ya
				processing_ammo = FALSE
				return 0

			//load it from the pile
			flashbulb_health = rand(FB.min_health, FB.max_health)
			boutput(user,"<span class='notice'><b>FOSS Cathodic Flash Bulb loaded.</b></span>")
			playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)

			qdel(ammo_list[ammo_list.len]) //please don't qdel typepaths
		ammo_list.Remove(ammo_list[ammo_list.len]) //and remove it from the list

		processing_ammo = FALSE
		return (current_projectile?1:0)

/obj/item/gun/modular/process_ammo(mob/user)
	if(accessory && accessory_on_cycle)
		accessory.on_cycle()

	if(flashbulb_only) // additional branch for suicide
		return flash_process_ammo(user)

	if(src.max_ammo_capacity == 0) //single shot? no cycle, no count, it shows up as 0 if we don't skip it
		if(src.jammed) //whoops gotta handle this too. call it a misfire
			if(src.jammed == 2) //stuck
				if(prob(60))
					src.jammed = 0
					//come up with a good sound for this
					boutput(user, "<span class='notice'>You pry the stuck round out of [src]</span>") //drop a dud
					return 0
				else //just hit it again it'll work for sure
					boutput(user, "<span class='notice'>You fail to pull the stuck round out of [src]</span>") //good 2 go
					return 0
			else //misfire
				if(prob(10)) //unlucky, dump the round
					src.jammed = 0
					src.current_projectile = null
					//come up with a good sound for this
					boutput(user, "<span class='notice'>You pry the bad round out of [src]</span>") //drop a dud
					return 0
				else //just hit it again it'll work for sure
					src.jammed = 0
					src.hammer_cocked = TRUE
					playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)
					boutput(user, "<span class='notice'>You re-cock the hammer on [src]</span>") //good 2 go
					return 1
		else
			if(chamber_checked && accessory && accessory_alt)
				accessory.alt_fire()
			else
				boutput(user, "<span class='notice'>You check the chamber and [src] appears to be [src.current_projectile == null ? "unloaded[prob(15) ? ". ...Probably!" : "."]" : "loaded[prob(15) ? ". ...Maybe?" : "."]"]</span>")
				if(!chamber_checked)
					playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)
					chamber_checked = 1
			return (current_projectile?1:0)

	switch(jammed)
		if(1) //problem on fire, either dud round or light strike
			if(prob(10)) //unlucky, dump the round
				src.jammed = 0
				src.current_projectile = null
				//come up with a good sound for this
				boutput(user, "<span class='notice'>You pry the dud round out of [src]</span>") //drop a dud
				return 0
			else //just hit it again it'll work for sure
				src.jammed = 0
				src.hammer_cocked = TRUE
				if (sound_type)
					playsound(src.loc, "sound/weapons/modular/[sound_type]-slowcycle.ogg", 40, 1)
				else
					playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg.ogg", 40, 1)
				boutput(user, "<span class='notice'>You re-cock the hammer on [src], ready to fire again.</span>") //good 2 go
				return 1
		if(2) //problem on cycle, failure to eject
			if(prob(60))
				src.jammed = 0
				//come up with a good sound for this
				boutput(user, "<span class='notice'>You pry the stuck casing out of [src].</span>") //drop a shell or a damaged cartridge
				return 0
			else //just hit it again it'll work for sure
				boutput(user, "<span class='notice'>You fail to pull the stuck casing out of [src].</span>") //good 2 go
				return 0
		if(3) //problem on load
			if(prob(80))
				src.jammed = 0
				//come up with a good sound for this
				src.current_projectile = null
				boutput(user, "<span class='notice'>You pry the stuck round out of [src].</span>") //drop a shell or a damaged cartridge
				return 0
			else //just hit it again it'll work for sure
				boutput(user, "<span class='notice'>You fail to pull the stuck round out of [src].</span>") //good 2 go
				return 0
		//if(4) //squib, real bad time
		//if(5) //hangfire, figure out how to handle

	if(!ammo_list.len) // empty!
		if (!hammer_cocked)
			if (sound_type)
				playsound(src.loc, "sound/weapons/modular/[sound_type]-slowcycle.ogg", 40, 1)
			else if (src.action == "pump")
				playsound(src.loc, "sound/weapons/shotgunpump.ogg", 40, 1)
			else
				playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 40, 1)
			hammer_cocked = 1
			boutput(user,"<span class='notice'><b>You cycle [src]'s action, but it's empty!</b></span>")
		else if(accessory && accessory_alt)
			accessory.alt_fire() // so you can turn your flashlight on without having ammo....
			boutput(user,"<span class='notice'><b>You fiddle with [accessory] since you're out of ammo.</b></span>")
		else
			boutput(user,"<span class='notice'><b>You faff around with your unloaded [src].</b></span>")
		return (current_projectile?1:0)

	if(ammo_list.len > max_ammo_capacity)
		var/waste = ammo_list.len - max_ammo_capacity
		ammo_list.Cut(1,(1 + waste))
		boutput(user,"<span class='alert'><b>Error! Storage space low! Deleting [waste] ammunition...</b></span>")
		playsound(src.loc, 'sound/items/mining_drill.ogg', 20, 1,0,0.8)

	if(!ammo_list.len) // empty! again!! just in case max ammo capacity was 0!!!
		if (!hammer_cocked)
			hammer_cocked = 1
			boutput(user,"<span class='notice'><b>You cycle [src]'s action, but it's empty!</b></span>")
			if (sound_type)
				playsound(src.loc, "sound/weapons/modular/[sound_type]-slowcycle.ogg", 40, 1)
			else if (src.action == "pump")
				playsound(src.loc, "sound/weapons/shotgunpump.ogg", 40, 1)
			else
				playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 40, 1)
		else
			boutput(user,"<span class='notice'><b>You faff around with your unloaded [src].</b></span>")
		return 0

	if(current_projectile) // chamber is loaded
		if(accessory && accessory_alt)
			accessory.alt_fire()
		return 1

	if(prob(jam_frequency_reload))
		jammed = 2
		boutput(user,"<span class='alert'><b>A cartridge gets wedged in wrong!</b></span>")
		playsound(src.loc, "sound/weapons/trayhit.ogg", 60, 1)
		return 0
	else
		//finally, everything normal. just load it and cycle
		var/ammotype = ammo_list[ammo_list.len]
		current_projectile = new ammotype() // last one goes in
		ammo_list.Remove(ammo_list[ammo_list.len]) //and remove it from the list
		hammer_cocked = TRUE
		if (sound_type)
			playsound(src.loc, "sound/weapons/modular/[sound_type]-quickcycle[rand(1,2)].ogg", 40, 1)
		else if (src.action == "pump")
			playsound(src.loc, "sound/weapons/shotgunpump.ogg", 40, 1)
		else
			playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)
		return 1

//cycle weapon + update counter
/obj/item/gun/modular/attack_self(mob/user)
	if(flashbulb_only)
		flash_process_ammo(user)
		src.inventory_counter.update_number(crank_level)
	else
		if(!src.processing_ammo)
			process_ammo(user)
		if(src.max_ammo_capacity)
			// this is how many shots are left in the feeder- plus the one in the chamber. it was a little too confusing to not include it
			src.inventory_counter.update_number(ammo_list.len + !!current_projectile)
		else
			src.inventory_counter.update_number(!!current_projectile) // 1 if its loaded, 0 if not.
		if(!hammer_cocked) //for italian revolver purposes, doesn't process_ammo like normal
			playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)
			boutput(user,"<span><b>You cock the hammer.</b></span>")
			hammer_cocked = 1
	buildTooltipContent()

/obj/item/gun/modular/canshoot()
	if(jammed)
		return 0
	//do this later, i'm just focusing on sounds and reloads for now
	//if(hammer_cocked && action == "single")
	//	return 0
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
			if (hammer_cocked)
				user.show_text("*click* *click*", "red") // No more attack messages for empty guns (Convair880).
				hammer_cocked = FALSE
				if (!silenced)
					playsound(user, "sound/weapons/Gunclick.ogg", 60, 1)
			else if (!processing_ammo)
				user.show_text("Nothing happens!", "red")
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
		if(prob(jam_frequency_fire))
			jammed = 1
			user.show_text("The cartridge fails to go off!", "red")
			playsound(user, "sound/impact_sounds/Generic_Click_1.ogg", 60, 1)
			//check chance to have a worse misfire
			chamber_checked = FALSE
			hammer_cocked = FALSE
			return

	//jam flashbulb gun's
	else
		if(prob(jam_frequency_fire))
			//if you're playing it unsafe
			if (unsafety)
				if (prob(max(0,(2 ^ (crank_level - safe_crank_level) + 5)))) //sudden and possibly explosive breakage versus expected burnout, with increasingly bad odds
					var/T = get_turf(src)
					explosion_new(src, T, crank_level, 1)
					jammed = 4
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
				jammed = 1
				user.show_text("A wire comes loose as [src] misfires and drops its charge!", "red")
			else
				user.show_text("The flashtube shorts out and dies!", "red")
			chamber_checked = FALSE
			hammer_cocked = FALSE
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
		how_drunk = max(0, how_drunk - isalcoholresistant(user) ? 1 : 0)
		spread += 5 * how_drunk
	spread = max(spread, spread_angle)

	var/obj/projectile/P = shoot_projectile_ST_pixel_spread(user, current_projectile, target, POX, POY, spread, alter_proj = new/datum/callback(src, PROC_REF(alter_projectile)))
	if (P)
		P.forensic_ID = src.forensic_ID

	chamber_checked = FALSE
	hammer_cocked = FALSE

	if(accessory && accessory_on_fire)
		accessory.on_fire()

	if(user && !suppress_fire_msg)
		if(!src.silenced)
			for(var/mob/O in AIviewers(user, null))
				O.show_message("<span class='alert'><B>[user] fires [src] at [target]!</B></span>", 1, "<span class='alert'>You hear a gunshot</span>", 2)
		else
			if (ismob(user)) // Fix for: undefined proc or verb /obj/item/mechanics/gunholder/show text().
				user.show_text("<span class='alert'>You silently fire the [src] at [target]!</span>") // Some user feedback for silenced guns would be nice (Convair880).

		var/turf/T = target
		src.log_shoot(user, T, P)

	SEND_SIGNAL(user, COMSIG_CLOAKING_DEVICE_DEACTIVATE)
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
		current_projectile = null // empty chamber

	if(!max_ammo_capacity)
		src.inventory_counter.update_number(!!current_projectile)

	src.update_icon()

	//updating count again after shooting
	//a lot of this can be more efficient i just want to get basic behaviors done and working right
	if(src.max_ammo_capacity)
		src.inventory_counter.update_number(ammo_list.len + !!current_projectile)
	else
		src.inventory_counter.update_number(!!current_projectile) // 1 if its loaded, 0 if not.
	if(flashbulb_only) //we just want to do this regardless of whatever happens with bulbs possibly burning out
		src.inventory_counter.update_number(crank_level)

	if(prob(jam_frequency_reload))
		jammed = 2
		if (flashbulb_only)
			boutput(user,"<span class='alert'><b>The dynamo gets stuck!</b></span>") //slammed forward too fast or whatever
		else
			boutput(user,"<span class='alert'><b>The casing gets stuck!</b></span>") //failed to eject
		playsound(src.loc, "sound/weapons/trayhit.ogg", 60, 1)

	return TRUE

/obj/item/gun/modular/shoot_point_blank(var/mob/M as mob, var/mob/user as mob, var/second_shot = 0)
	..()
	if (flashbulb_only)
		if (flash_auto)
			crank_level--
		else
			crank_level = 0
	current_projectile = null // empty chamber
	hammer_cocked = FALSE
	src.update_icon()

/obj/item/gun/modular/proc/build_gun()
	icon_state = "[initial(icon_state)]-built" //if i don't do this it's -built-built-built
	parts = list()
	if(barrel)
		parts += barrel
	/*
	if(foregrip) //tuck this under the barrel
		foregrip.part_type = "foregrip"
		parts += foregrip
		foregrip.overlay_x += foregrip_offset_x
		foregrip.overlay_y += foregrip_offset_y
	*/
	else //bad idea
		spread_angle += BARREL_PENALTY
	if(src.gun_DRM == GUN_JUICE) //pump requires two hands also it's almost always fukken huge
		src.two_handed = FALSE //but i may revisit this
		src.can_dual_wield = FALSE
	if(magazine)
		parts += magazine
	if(grip)
		parts += grip
	if(stock)
		parts += stock
		two_handed = 1 //for later: if (stock.foldable != 2) (unfolded) then 2-handed
	if(!grip && !stock) //uh oh
		spread_angle += GRIP_PENALTY
	if(bullpup_stock) //quick + dirty handling of overlay shit since the stock must be behind the receiver
		var/image/I = image(icon, icon_state) //so so dirty
		src.UpdateOverlays(I, "greebling") //later this will be its own thing and every receiver can greeble. bullpupping will simply be a more forward grip/foregrip offset + overlay on stock
		src.two_handed = TRUE
		src.can_dual_wield = FALSE

	if(accessory)
		parts += accessory

	for(var/obj/item/gun_parts/part as anything in parts)
		part.add_part_to_gun(src)

	if(bulk >= 6 || flashbulb_only) //flashfoss always two hands, how else will you crank off
		src.two_handed = TRUE
		src.can_dual_wield = FALSE
		//if(!foregrip)
		//	spread_angle += GRIP_PENALTY/3
	src.force = 2 + bulk
	src.throwforce = bulk

	buildTooltipContent()
	built = 1

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
	scatter = 0
	lensing = 0
	muzzle_flash = 0
	silenced = 0
	accessory_alt = 0
	accessory_on_fire = 0
	accessory_on_cycle = 0
	flash_auto = 0
	bulk = 0

	spread_angle = initial(spread_angle)
	max_ammo_capacity = initial(max_ammo_capacity)
	jam_frequency_reload = initial(jam_frequency_reload)
	jam_frequency_fire = initial(jam_frequency_fire)
	can_dual_wield = initial(can_dual_wield)
	two_handed = initial(two_handed)
	spread_angle = initial(spread_angle)

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
				current_projectile = new /datum/projectile/laser/flashbulb()
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
				current_projectile = null // this shouldnt happen but just in case!
			if (1)
				current_projectile = new /datum/projectile/laser/flashbulb()
			if (2)
				current_projectile = new /datum/projectile/laser/flashbulb/two()
			if (3)
				current_projectile = new /datum/projectile/laser/flashbulb/three()
			if (4)
				current_projectile = new /datum/projectile/laser/flashbulb/four()
			if (5)
				current_projectile = new /datum/projectile/laser/flashbulb/five()
		playsound(src.loc, "sound/machines/twobeep.ogg", 55, 0, pitch = (0.5 + (crank_level * 0.15))) //eventually make this buzzes and alarms and etc.
		src.inventory_counter.update_number(crank_level)
		currently_cranking_off = FALSE

/obj/item/gun/modular/proc/handle_egun_shit(mob/user)
	return

// BASIC GUN'S
//NANOTRASEN COP GUNS
//stupid plastic patented hi tech bullshit, for copse. rifle is bullpup
//probably the most "normal" modern gun in the game
//standard stupid breech load
//Ammo: standard/small and also primarily stun
//magazine: none by default, ammo is stored behind/in the stock (the grip holds the very large battery for the light and the loader)
//eventually: convert long receiver to short receiver and vice versa via swappable kit (with NT and soviet receivers)

ABSTRACT_TYPE(/obj/item/gun/modular/NT)
/obj/item/gun/modular/NT
	name = "abstract NT gun"
	real_name = "abstract NT gun"
	desc = "You're not supposed to see this, call a coder or whatever."
	max_ammo_capacity = 0 // single-shot pistols ha- unless you strap an expensive loading mag on it.
	action = "single"
	gun_DRM = GUN_NANO
	spread_angle = 7
	icon = 'icons/obj/items/modular_guns/receivers.dmi'
	icon_state = "nt_short" //or nt_long
	var/electrics_intact = TRUE //the grody autoloading ID locked snitchy smart gun parts that are just begging to be microwaved, emagged, or simply pried and cut out


ABSTRACT_TYPE(/obj/item/gun/modular/NT/short)
/obj/item/gun/modular/NT/short
	name = "\improper NT pistol receiver"
	real_name = "\improper NT pistol"
	desc = "A basic, Nanotrasen-licensed single-shot weapon."
	icon_state = "nt_short" //or nt_long
	barrel_overlay_x = BARREL_OFFSET_SHORT
	grip_overlay_x = GRIP_OFFSET_SHORT
	stock_overlay_x = STOCK_OFFSET_SHORT

	//short receiver, by itself and unbuilt
	receiver
		no_build = TRUE

//long receiver, by itself
//eventually be able to convert between long and short?
ABSTRACT_TYPE(/obj/item/gun/modular/NT/long)

/obj/item/gun/modular/NT/long
	name = "\improper NT rifle receiver"
	real_name = "\improper NT rifle"
	desc = "A mostly reliable, autoloading Nanotrasen-licensed and corporate security-issued weapon."
	cartridge_length = 40
	max_ammo_capacity = 2 //built in small loader
	action = "autoloader"
	icon_state = "nt_long"
	grip_overlay_x = GRIP_OFFSET_BULLPUP
	barrel_overlay_x = BARREL_OFFSET_LONG
	stock_overlay_x = STOCK_OFFSET_BULLPUP
	bullpup_stock = 1 //for the overlay

	//long receiver, by itself and unbuilt
	receiver
		no_build = TRUE

	//this operates like a shitty electric motor loading glock or something
	//"but but don't we need a power cell or something" it's got integrated batteries that'll last a month in the receiver don't worry about it
	//point and click, but if that's too slow, then toss it in a microwave or something. built in a way that if electronics fail, manual control is unlocked
	shoot(var/target,var/start,var/mob/user,var/POX,var/POY,var/is_dual_wield)
		if(electrics_intact) //handholding nonsense if electronics are intact
			if (!src.processing_ammo)
				if (jammed)
					src.processing_ammo = TRUE
					boutput(user, "<span class='notice'>The NT smartloader beeps, 'Jam Detected in [src]!'</span>")
					sleep(30) //just long enough to be a pain
					if(src.jammed == 2) //stuck
						src.jammed = 0
						src.hammer_cocked = TRUE
						boutput(user, "The NT smartloader forces the stuck casing out of [src]")
					else //misfire
						if(prob(10)) //unlucky, dump the round
							src.current_projectile = null
							src.jammed = 0
							boutput(user, "The NT smartloader forces the dud round out of [src]") //drop a dud
						else
							src.jammed = 0
							src.hammer_cocked = TRUE
							boutput(user, "The NT smartloader re-cocks the hammer on [src]")
					playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)
					src.processing_ammo = FALSE
					return
				if (!current_projectile)
					return //kill spam click on unloaded chamber (this causes beepboops all over)
		else //fall back to manual single action striker
			if (!src.hammer_cocked)
				src.hammer_cocked = TRUE
				playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)
				return
		..()
		if(electrics_intact)
			if (jammed == 2 && !src.processing_ammo) //and again, because sometimes it jams a casing on eject
				src.processing_ammo = TRUE
				boutput(user, "<span class='notice'>The NT smartloader beeps, 'Jam Detected in [src]!'</span>")
				sleep(30) //just long enough to be a pain
				src.jammed = 0
				boutput(user, "The NT smartloader ejects the stuck casing from [src]")
				src.processing_ammo = FALSE
			if(!current_projectile)
				sleep(20)
				if(ammo_list.len)
					playsound(src.loc, "sound/machines/ping.ogg", 40, 1)
					process_ammo() //attempt autoload beep boop
				else
					playsound(src.loc, "sound/machines/buzz-sigh.ogg", 40, 1)
			if (jammed && !src.processing_ammo)
				src.processing_ammo = TRUE
				sleep(30)
				src.jammed = 0
				boutput(user, "The NT smartloader automatically reseats the round in [src]") //possibly the only advantage of smart loader easymode 4 babies
				src.processing_ammo = FALSE
			src.hammer_cocked = TRUE
			playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)

	//cycle weapon + update counter
	attack_self(mob/user)
		if(electrics_intact) //can't do anything unless the gun does it, unless you microwave it or emag it (or eventually do some parts surgery on it)
			boutput(user, "The intact NT smartloader prevents you from interacting with [src]'s action beyond reloading and shooting.")
			if(src.max_ammo_capacity)
				src.inventory_counter.update_number(ammo_list.len + !!current_projectile)
			else
				src.inventory_counter.update_number(!!current_projectile) // 1 if its loaded, 0 if not.
			buildTooltipContent()
			return
		else //operate it like any other firearm
			if(src.processing_ammo)
				return //hold your dang horses
			process_ammo(user)
			if(src.max_ammo_capacity)
				// this is how many shots are left in the feeder- plus the one in the chamber. it was a little too confusing to not include it
				src.inventory_counter.update_number(ammo_list.len + !!current_projectile)
			else
				src.inventory_counter.update_number(!!current_projectile) // 1 if its loaded, 0 if not.
		buildTooltipContent()

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!electrics_intact)
			return 0
		if (user)
			user.show_text("[src]'s 'smart' autoloading capabilities have been disabled.", "red")
		src.electrics_intact = FALSE
		//do a thing here to turn off the lights
		return 1

//a built and usable pistol
/obj/item/gun/modular/NT/short/pistol
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
			grip = new /obj/item/gun_parts/grip/NT/guardless(src)

//single shot, no stock, intended for shotgun shell
/obj/item/gun/modular/NT/short/bartender
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
/obj/item/gun/modular/NT/long/rifle
	name = "\improper NT rifle"

	make_parts()
		if(prob(90))
			barrel = new /obj/item/gun_parts/barrel/NT/long(src)
		else
			barrel = new /obj/item/gun_parts/barrel/NT/long/padded(src)
		stock = new /obj/item/gun_parts/stock/NT(src)
		if(prob(40))
			grip = new /obj/item/gun_parts/grip/NT
		else if(prob(40))
			grip = new /obj/item/gun_parts/grip/NT/guardless
		if(prob(10))
			accessory = new /obj/item/gun_parts/accessory/flashlight(src)

//stocked shotgun for sec
/obj/item/gun/modular/NT/long/shotty
	name = "\improper NT riot suppressor"
	desc = "'Innovated' almost entirely from Juicer parts, it seems."
	icon_state = "nt_long"
	grip_overlay_x = GRIP_OFFSET_BULLPUP
	barrel_overlay_x = BARREL_OFFSET_LONG
	stock_overlay_x = STOCK_OFFSET_BULLPUP
	bullpup_stock = 1
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
	//set these manually because nothing really uh
	//nothing else is like the foss guns
	barrel_overlay_x = 6
	stock_overlay_x = -10 //combined with the inherent -6 on the stock itself, this is 16 to the left (fiddly fucking thing)
	grip_overlay_x = -4
	grip_overlay_y = -2
	jam_frequency_fire = 0.1 //really only if overcharged
	jam_frequency_reload = 0 //only if the user is clumsy
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
	//color = "#99FF99"
	contraband = 1
	barrel_overlay_x = BARREL_OFFSET_LONG
	grip_overlay_x = GRIP_OFFSET_LONG
	stock_overlay_x = STOCK_OFFSET_LONG
	//foregrip_offset_x = 15 //put it on the pump

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
		magazine = new /obj/item/gun_parts/magazine/juicer(src)

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
	max_ammo_capacity = 4
	spread_angle = 9
	contraband = 4
	barrel_overlay_x = BARREL_OFFSET_LONG
	grip_overlay_x = GRIP_OFFSET_LONG
	stock_overlay_x = STOCK_OFFSET_LONG
	two_handed = TRUE
	can_dual_wield = FALSE

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

//Italian Revolver
//Extremely Stylish
//Heavy Ammo
//Cylinder "Magazine"
ABSTRACT_TYPE(/obj/item/gun/modular/italian)
/obj/item/gun/modular/italian
	name = "abstract Italian gun"
	real_name = "abstract Italian gun"
	desc = "abstract type do not instantiate"
	icon = 'icons/obj/items/modular_guns/receivers.dmi'
	icon_state = "italian" //only
	//basic revolving mechanism
	action = "double"
	//this will be a "magazine" but like tubes we'll have a slightly different firing method
	gun_DRM = GUN_ITALIAN
	spread_angle = 10
	//color = "#FFFF99"
	grip_overlay_x = GRIP_OFFSET_SHORT
	stock_overlay_x = STOCK_OFFSET_SHORT
	barrel_overlay_x = BARREL_OFFSET_SHORT
	jam_frequency_fire = 3
	jam_frequency_reload = 3

	shoot(var/target,var/start,var/mob/user,var/POX,var/POY,var/is_dual_wield)
		//If we're doing a double action thing here where it automatically resets and is ready to fire the next shot?
		//Maybe a short sleep, that's the tradeoff for not having to click it every time... I'm not putting it in until I sort out more
		//ALSO: handle unloading all rounds (shot or unshot) at same time, don't load until unloaded?
		//much too consider
		//if (!src.hammer_cocked) then delay and set hammer_cocked
		if (src.hammer_cocked)
			..()
		else
			sleep(10) //heavy double action
			//check if still held by same person
			process_ammo()
			..()

/obj/item/gun/modular/italian/basic
	name = "basic Italian revolver"
	real_name = "\improper Italianetto"
	desc = "Una pistola realizzata in acciaio mediocre."
	max_ammo_capacity = 1 //2 shots

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/italian/small(src)
		grip = new /obj/item/gun_parts/grip/italian(src)

//Standard factory issue
/obj/item/gun/modular/italian/italiano
	name = "improved Italian revolver"
	real_name = "\improper Italiano"
	desc = "Una pistola realizzata in acciaio di qualità e pelle.."
	max_ammo_capacity = 2

	make_parts()
		if (prob(50))
			barrel = new /obj/item/gun_parts/barrel/italian(src)
		else
			barrel = new /obj/item/gun_parts/barrel/italian/spicy(src)
		if (prob(50))
			grip = new /obj/item/gun_parts/grip/juicer(src)
		else if (prob(50))
			grip = new /obj/item/gun_parts/grip/juicer/black(src)
		else
			grip = new /obj/item/gun_parts/grip/italian/cowboy(src)

//mama mia
/obj/item/gun/modular/italian/big_italiano
	name = "masterwork Italian revolver"
	real_name = "\improper Italianone"
	desc = "Una pistola realizzata con acciaio, cuoio e olio d'oliva della più alta qualità possibile."
	max_ammo_capacity = 3

	make_parts()

		if (prob(75))
			stock = new /obj/item/gun_parts/stock/italian(src)
			barrel = new /obj/item/gun_parts/barrel/italian/buntline(src)
		else
			grip = new /obj/item/gun_parts/grip/italian/bigger(src)
			barrel = new /obj/item/gun_parts/barrel/italian/accurate(src)

//da jokah babiyyyy
/obj/item/gun/modular/italian/silly
	name = "jokerfied Italian revolver"
	real_name = "\improper Grande Italiano"
	max_ammo_capacity = 3
	desc = "Io sono il pagliaccio, bambino!"

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/italian/joker(src)
		grip = new /obj/item/gun_parts/grip/italian/cowboy/bandit(src)

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
