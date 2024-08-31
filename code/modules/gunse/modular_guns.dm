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
	var/no_save = 0 // when 1, this should prevent the player from carrying it cross-round?
	icon_state = "shittygun"
	contraband = 0 //is this a crime gun made by and for crimers
	inventory_counter_enabled = 1
	var/bulk = 1 //bulkiness should also impact recoil (not as a real modeled thing but a time between shots/comedic whoopsies)
	var/bulkiness = 1 //receivers have bulk too.

	//offsets and parts
	var/barrel_overlay_x = 0 //barrel attachment offset relative to standard (16,19 to 16,16) part attachment
	var/barrel_overlay_y = 0
	var/bullpup_stock = 0 // this one's fucky but solvable (to be continued....)
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

	var/flashbulb_only = 0 // FOSS guns only
	var/flash_auto = 0 // FOSS auto-fire setting
	var/flashbulb_health = 0 // FOSS guns only
	var/unsafe_crank_level = 0 // FOSS guns only
	var/safety = 0 // FOSS guns only
	var/max_crank_level = 0 // FOSS guns only
	var/crank_level = 0 // FOSS guns only

	var/auto_eject = 0 // Do we eject casings on firing, or on reload?
	var/casings_to_eject = 0 // kee ptrack
	var/max_ammo_capacity = 1 // How much ammo can this gun hold? Don't make this null (Convair880).
	var/list/ammo_list = list() // a list of datum/projectile types
	current_projectile = null // chambered round
	var/chamber_checked = 0 // this lets us fast-track alt-fire modes and stuff instead of re-checking the breech every time

	var/accessory_alt = 0 //does the accessory offer an alternative firing mode?
	var/accessory_on_fire = 0 // does the accessory need to know when you fire?
	var/accessory_on_cycle = 0 // does the accessory need to know you pressed C?

	var/jam_frequency_reload = 1 //base % chance to jam on reload. Just reload again to clear.
	var/jam_frequency_fire = 1 //base % chance to jam on fire. Reload to clear.
	var/jammed = 0 //got something stuck and unable to fire?
	var/processing_ammo = 0 //cycling ammo/cranking off



	two_handed = 0
	can_dual_wield = 1

	New()
		..()
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
		var/obj/item/stackable_ammo/SA = I
		SA.reload(src, user)
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







/obj/item/gun/modular/proc/flash_process_ammo(mob/user)
	if(processing_ammo)
		return 0

	if(jammed)
		boutput(user,"<span class='notice'><b>You clear the ammunition jam.</b></span>")
		jammed = 0
		playsound(src.loc, "sound/weapons/gunload_heavy.ogg", 40, 1)
		return 0

	if(flashbulb_health) // bulb still loaded
		processing_ammo = 1
		if(max_crank_level)
			crank(user)
		else
			handle_egun_shit(user)
		processing_ammo = 0
		return 1

	if(!ammo_list.len) // empty!
		playsound(src.loc, "sound/weapons/Gunclick.ogg", 40, 1)
		return (current_projectile?1:0)

	if(ammo_list.len > max_ammo_capacity)
		var/waste = ammo_list.len - max_ammo_capacity
		ammo_list.Cut(1,(1 + waste))
		boutput(user,"<span class='alert'><b>Error! Storage space low! Deleting [waste] ammunition...</b></span>")
		playsound(src.loc, 'sound/items/mining_drill.ogg', 20, 1,0,0.8)

	if(!ammo_list.len) // empty! again!! just in case max ammo capacity was 0!!!
		playsound(src.loc, "sound/weapons/Gunclick.ogg", 40, 1)
		return (current_projectile?1:0)

	if(prob(jam_frequency_reload))
		jammed = 1
		boutput(user,"<span class='alert'><b>Error! Jam detected!</b></span>")
		playsound(src.loc, "sound/weapons/trayhit.ogg", 60, 1)
		return 0
	else
		processing_ammo = 1
		var/obj/item/stackable_ammo/flashbulb/FB = ammo_list[ammo_list.len]
		if(!istype(FB))
			boutput(user,"<span class='notice'><b>Error! This device is configured only for FOSS Cathodic Flash Bulbs.</b></span>")
			playsound(src.loc, "sound/machines/twobeep.ogg", 55, 1)
		else
			flashbulb_health = rand(FB.min_health, FB.max_health)
			boutput(user,"<span class='notice'><b>FOSS Cathodic Flash Bulb loaded.</b></span>")
			playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)

		qdel(ammo_list[ammo_list.len])
		ammo_list.Remove(ammo_list[ammo_list.len]) //and remove it from the list

		processing_ammo = 0
		return (current_projectile?1:0)

/obj/item/gun/modular/process_ammo(mob/user)
	if(accessory && accessory_on_cycle)
		accessory.on_cycle()

	if(flashbulb_only) // additional branch for suicide
		return flash_process_ammo(user)

	if(src.max_ammo_capacity == 0) //single shot? no cycle, no count, it shows up as 0 if we don't skip it
		if(src.jammed) //whoops gotta handle this too. call it a misfire
			if(prob(10)) //unlucky, dump the round
				src.jammed = 0
				src.current_projectile = null
				boutput(user, "<span class='notice'>You pull the bad round out of [src]</span>") //drop a dud
				return 0
			else //just hit it again it'll work for sure
				src.jammed = 0
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

	if(jammed)
		boutput(user,"<span class='notice'><b>You clear the ammunition jam.</b></span>")
		jammed = 0
		playsound(src.loc, "sound/weapons/gunload_heavy.ogg", 40, 1)
		return 0
	if(!ammo_list.len) // empty!
		playsound(src.loc, "sound/weapons/Gunclick.ogg", 40, 1)
		if(accessory && accessory_alt)
			accessory.alt_fire() // so you can turn your flashlight on without having ammo....
		return (current_projectile?1:0)
	if(ammo_list.len > max_ammo_capacity)
		var/waste = ammo_list.len - max_ammo_capacity
		ammo_list.Cut(1,(1 + waste))
		boutput(user,"<span class='alert'><b>Error! Storage space low! Deleting [waste] ammunition...</b></span>")
		playsound(src.loc, 'sound/items/mining_drill.ogg', 20, 1,0,0.8)

	if(!ammo_list.len) // empty! again!! just in case max ammo capacity was 0!!!
		playsound(src.loc, "sound/weapons/Gunclick.ogg", 40, 1)
		return 0

	if(current_projectile) // chamber is loaded
		if(accessory && accessory_alt)
			accessory.alt_fire()
		return 1

	if(prob(jam_frequency_reload))
		jammed = 1
		boutput(user,"<span class='alert'><b>Error! Jam detected!</b></span>")
		playsound(src.loc, "sound/weapons/trayhit.ogg", 60, 1)
		return 0
	else
		var/ammotype = ammo_list[ammo_list.len]
		current_projectile = new ammotype() // last one goes in
		ammo_list.Remove(ammo_list[ammo_list.len]) //and remove it from the list
		playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)
		return 1


/obj/item/gun/modular/attack_self(mob/user)
	if(flashbulb_only)
		flash_process_ammo(user)
		src.inventory_counter.update_number(crank_level)
	else
		process_ammo(user)
		if(src.max_ammo_capacity)
			src.inventory_counter.update_number(ammo_list.len)
		// this is how many shots are left in the feeder- and does not include the one in the chamber. Should make for funny times
		else
			src.inventory_counter.update_number(!!current_projectile) // 1 if its loaded, 0 if not.

	buildTooltipContent()



/obj/item/gun/modular/canshoot()
	if(jammed)
		return 0
	if(!built)
		return 0
	if(flashbulb_only && !flashbulb_health)
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

	if(prob(jam_frequency_fire))
		jammed = 1
		user.show_text("*clunk* *clack*", "red")
		playsound(user, "sound/impact_sounds/Generic_Click_1.ogg", 60, 1)


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

	chamber_checked = 0

	if (ismob(user))
		var/mob/M = user
		if (ishuman(M) && src.add_residue) // Additional forensic evidence for kinetic firearms (Convair880).
			var/mob/living/carbon/human/H = user
			H.gunshot_residue = 1

	if(flashbulb_health)// this should be nonzero if we have a flashbulb loaded.
		if(flash_auto && crank_level) // auto-fire special handling
			flashbulb_health--
			crank_level--
		else
			flashbulb_health = max(0,(flashbulb_health - crank_level))//subtract cranks from life
			crank_level = 0 // reset

		if(!flashbulb_health) // that was the end of it!
			user.show_text("<span class='alert'>Your gun's flash bulb burns out!</span>")
		src.inventory_counter.update_number(crank_level)

	if(!flash_auto)
		current_projectile = null // empty chamber

	if(!max_ammo_capacity)
		src.inventory_counter.update_number(!!current_projectile)

	src.update_icon()
	return TRUE

/obj/item/gun/modular/shoot_point_blank(var/mob/M as mob, var/mob/user as mob, var/second_shot = 0)
	..()
	current_projectile = null // empty chamber
	src.update_icon()

/obj/item/gun/modular/proc/build_gun()
	icon_state = "[initial(icon_state)]-built" //if i don't do this it's -built-built-built
	parts = list()
	if(foregrip) //tuck this under the barrel
		foregrip.part_type = "foregrip"
		parts += foregrip
		foregrip.overlay_x += foregrip_offset_x
		foregrip.overlay_y += foregrip_offset_y
	if(barrel)
		parts += barrel
	else //bad idea
		spread_angle += BARREL_PENALTY
	if(src.gun_DRM == GUN_JUICE) //pump requires two hands also it's almost always fukken huge
		src.two_handed = 1 //but i may revisit this
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
		src.two_handed = 1

	if(accessory)
		parts += accessory

	for(var/obj/item/gun_parts/part as anything in parts)
		part.add_part_to_gun(src)

	if(bulk >= 6 || flashbulb_only) //flashfoss always two hands, how else will you crank off
		src.two_handed = 1
		if(!foregrip)
			spread_angle += GRIP_PENALTY/3
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
	foregrip = null

	name = real_name

	max_crank_level = 0
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
	SPAWN_DBG(10)
		if(crank_level > max_crank_level)
			boutput(user,"<span class='notice'><b>Error! This device cannot be further overloaded.</b></span>")
			playsound(src.loc, "sound/machines/twobeep.ogg", 55, 1)
			processing_ammo = 0
			return
		if(crank_level == max_crank_level)
			boutput(user,"<span class='notice'><b>Notice! Exceeding design specification.</b></span>")
			playsound(src.loc, "sound/machines/twobeep.ogg", 55, 1)
			sleep(0.5 SECONDS)
			crank_level++
			playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
		if(crank_level < max_crank_level)
			boutput(user,"<span><b>You crank the handle.</b></span>")
			crank_level++
			playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)

		if(flash_auto) // keep the projectile at level 1 after incrementing the crank level.
			if(!current_projectile)
				current_projectile = new /datum/projectile/laser/flashbulb()
			processing_ammo = 0
			return

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
			//if (5)
				//current_projectile = /datum/projectile/laser/flashbulb/five
		processing_ammo = 0

/obj/item/gun/modular/proc/handle_egun_shit(mob/user)
	return

// BASIC GUN'S
//NANOTRASEN COP GUNS
//stupid plastic patented hi tech bullshit, for copse. rifle is bullpup
//probably the most "normal" modern gun in the game
//standard stupid breech load
//Ammo: standard/small and also primarily stun
//magazine: none by default, ammo is stored behind/in the stock (the grip holds the very large battery for the light and the loader)
//eventually: convert long stock to short stock and vice versa via swappable kit (with NT and soviet receivers)

ABSTRACT_TYPE(/obj/item/gun/modular/NT)
/obj/item/gun/modular/NT
	name = "\improper NT gun"
	real_name = "\improper NT gun"
	desc = "A simple, reliable cylindrical bored weapon."
	max_ammo_capacity = 0 // single-shot pistols ha- unless you strap an expensive loading mag on it.
	gun_DRM = GUN_NANO
	spread_angle = 7
	icon = 'icons/obj/items/modular_guns/receivers.dmi'
	icon_state = "nt_short" //or nt_long
	barrel_overlay_x = BARREL_OFFSET_SHORT
	grip_overlay_x = GRIP_OFFSET_SHORT
	stock_overlay_x = STOCK_OFFSET_SHORT

//short receiver, by itself
/obj/item/gun/modular/NT/short
	built = FALSE

//long receiver, by itself
/obj/item/gun/modular/NT/long
	name = "\improper NT rifle"
	real_name = "\improper NT rifle"
	desc = "A simple, reliable rifled bored weapon."
	max_ammo_capacity = 2 //built in small loader
	icon_state = "nt_long"
	grip_overlay_x = GRIP_OFFSET_BULLPUP
	barrel_overlay_x = BARREL_OFFSET_LONG
	stock_overlay_x = STOCK_OFFSET_BULLPUP
	bullpup_stock = 1 //for the overlay
	built = FALSE

//a built and usable pistol
/obj/item/gun/modular/NT/short/pistol
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
	name = "grey-market shotgun"
	desc = "Cobbled together from unlicensed parts."
	contraband = 3
	make_parts()
		barrel = new /obj/item/gun_parts/barrel/juicer/chub(src)
		if(prob(50))
			grip = new /obj/item/gun_parts/grip/juicer/black(src)
			if(prob(10))
				foregrip = new /obj/item/gun_parts/grip/NT/stub(src)
		else
			grip = new /obj/item/gun_parts/grip/juicer(src)
			if(prob(10))
				foregrip = new /obj/item/gun_parts/grip/juicer/black(src)
		if(prob(30))
			accessory = new /obj/item/gun_parts/accessory/flashlight(src)

//long rifle
/obj/item/gun/modular/NT/long/rifle

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
	desc = "Cloned from Juicer parts, it seems."
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
		if(prob(30))
			foregrip = new /obj/item/gun_parts/grip/NT/stub(src)

// syndicate laser gun's!
// cranked capacitor which discharges through a flashbulb thing and shoots a big honking lazers
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
	foregrip_offset_x = 12
	foregrip_offset_y = 0

//basic foss laser
/obj/item/gun/modular/foss/standard

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/foss(src)
		stock = new /obj/item/gun_parts/stock/foss(src)


/obj/item/gun/modular/foss/long
	desc = "An open-sourced and freely modifiable FOSS Inductive Flash Arc, Model 2k/20"

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/foss/long(src)
		stock = new /obj/item/gun_parts/stock/foss/long(src)
		grip = new /obj/item/gun_parts/grip/foss(src)

/obj/item/gun/modular/foss/punt
	desc = "An open-sourced and freely modifiable FOSS Inductive Flash Arc, Model 2k/420"

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/foss/long/very(src)
		stock = new /obj/item/gun_parts/stock/foss/longer(src)

/obj/item/gun/modular/foss/loader
	desc = "An open-sourced and freely modifiable FOSS Inductive Flash Arc, Model 2k/19L"
	make_parts()
		barrel = new /obj/item/gun_parts/barrel/foss/long(src)
		stock = new /obj/item/gun_parts/stock/foss/loader(src)
		grip = new /obj/item/gun_parts/grip/foss(src)
		foregrip = new /obj/item/gun_parts/grip/foss(src)


//JUICER GUN'ZES
//Loud and obnoxious and comical and deudly but also extremely unreliable
//Ammo: probably whatever but primarily shot
//Pump Action Slam
//Integrated Non-Removable TOP-FED Box Magazine (It's BIG but you still have to load one at a time and it's probably the most unreliable part)
//Ideally a two handed thing: maybe if you don't have a stock you can use wire to make a strap so it has a much smaller chance of flying out of your hands
//High damage potential but high fuckup potential as well
ABSTRACT_TYPE(/obj/item/gun/modular/juicer)
/obj/item/gun/modular/juicer
	name = "\improper BLASTA"
	real_name = "\improper Blaster"
	desc = "A juicer-built, juicer-'designed', and most importantly juicer-marketed gun."
	icon = 'icons/obj/items/modular_guns/receivers.dmi'
	icon_state = "juicer" //only large
	max_ammo_capacity = 0 //fukt up mags only
	gun_DRM = GUN_JUICE
	spread_angle = 10
	//color = "#99FF99"
	contraband = 1
	barrel_overlay_x = BARREL_OFFSET_LONG
	grip_overlay_x = GRIP_OFFSET_LONG
	stock_overlay_x = STOCK_OFFSET_LONG
	foregrip_offset_x = 15 //put it on the pump

/obj/item/gun/modular/juicer/basic
	name = "\improper BLASTA"
	real_name = "\improper BLASTA"

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
	name = "blunder BLASTA"
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
	name = "Sniper BLASTA"
	make_parts()
		barrel = new /obj/item/gun_parts/barrel/juicer/longer(src)
		if(prob(70))
			grip = new /obj/item/gun_parts/grip/italian(src)
		else
			grip = new /obj/item/gun_parts/grip/italian/bigger(src)
		if(prob(50))
			foregrip = new /obj/item/gun_parts/grip/juicer(src)
			magazine = new /obj/item/gun_parts/magazine/juicer/four(src)
		else
			magazine = new /obj/item/gun_parts/magazine/juicer(src)

/obj/item/gun/modular/juicer/ribbed
	name = "greeble BLASTA"
	make_parts()
		barrel = new /obj/item/gun_parts/barrel/juicer/ribbed(src)
		if(prob(70))
			grip = new /obj/item/gun_parts/grip/juicer(src)
		else
			grip = new /obj/item/gun_parts/grip/juicer/black(src)
		if(prob(50))
			foregrip = new /obj/item/gun_parts/grip/juicer/black(src)
			magazine = new /obj/item/gun_parts/magazine/juicer/four(src)
		else
			magazine = new /obj/item/gun_parts/magazine/juicer(src)

//Soviet Laser
//Functional, chunky
//Ammo is a series of chemical zaubertubes
//Not really for physical ammo
//might be funny to be lever action/underbarrel tube-fed (which means load directly to chamber, then: last in, first out)

ABSTRACT_TYPE(/obj/item/gun/modular/soviet)
/obj/item/gun/modular/soviet

	name = "\improper Soviet лазерная"
	real_name = "\improper Soviet лазерная"
	desc = "Энергетическая пушка советской разработки с пиротехническими лампами-вспышками."
	icon = 'icons/obj/items/modular_guns/receivers.dmi'
	gun_DRM = GUN_SOVIET


//short receiver only
/obj/item/gun/modular/soviet/short
	icon_state = "soviet_short"
	max_ammo_capacity = 2
	contraband = 2
	barrel_overlay_x = BARREL_OFFSET_SHORT
	grip_overlay_x = GRIP_OFFSET_SHORT
	stock_overlay_x = STOCK_OFFSET_SHORT

//long receiver only
/obj/item/gun/modular/soviet/long
	icon_state = "soviet_long"
	max_ammo_capacity = 4
	spread_angle = 9
	contraband = 4
	barrel_overlay_x = BARREL_OFFSET_LONG
	grip_overlay_x = GRIP_OFFSET_LONG
	stock_overlay_x = STOCK_OFFSET_LONG
	two_handed = TRUE

/obj/item/gun/modular/soviet/short/basic
	spread_angle = 9
	contraband = 4
	stock_overlay_x = -10

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/soviet(src)
		grip = new /obj/item/gun_parts/grip/italian/cowboy(src)

/obj/item/gun/modular/soviet/short/covert
	name = "\improper Soviet лазерная"
	real_name = "\improper Soviet лазерная"
	desc = "Энергетическая пушка советской разработки с пиротехническими лампами-вспышками."
	icon = 'icons/obj/items/modular_guns/receivers.dmi'
	icon_state = "soviet_short"
	max_ammo_capacity = 1
	gun_DRM = GUN_SOVIET
	spread_angle = 9
	//color = "#FF9999"
	//icon_state = "laser"
	contraband = 2

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/soviet/covert(src)
		grip = new /obj/item/gun_parts/grip/italian(src)

/obj/item/gun/modular/soviet/long/advanced
	name = "\improper Soviet лазерная"
	real_name = "\improper Soviet лазерная"
	desc = "Энергетическая пушка советской разработки с пиротехническими лампами-вспышками."
	icon_state = "soviet_long"
	max_ammo_capacity = 4
	gun_DRM = GUN_SOVIET
	spread_angle = 9
	contraband = 5
	barrel_overlay_x = BARREL_OFFSET_LONG
	grip_overlay_x = GRIP_OFFSET_LONG
	stock_overlay_x = STOCK_OFFSET_LONG
	two_handed = TRUE

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
	name = "\improper Soviet лазерная"
	real_name = "\improper Soviet лазерная"
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
	name = "\improper Italiano"
	real_name = "\improper Italiano"
	//may need a vending machine name because the names are the same prior to prefix/suffix generation
	desc = "Una pistola realizzata con acciaio, cuoio e olio d'oliva della più alta qualità possibile."
	icon = 'icons/obj/items/modular_guns/receivers.dmi'
	icon_state = "italian" //only
	max_ammo_capacity = 2 // basic revolving mechanism
	//this will be a "magazine" but like tubes we'll have a slightly different firing method
	gun_DRM = GUN_ITALIAN
	spread_angle = 10
	//color = "#FFFF99"
	grip_overlay_x = GRIP_OFFSET_SHORT
	stock_overlay_x = STOCK_OFFSET_SHORT
	barrel_overlay_x = BARREL_OFFSET_SHORT
	jam_frequency_fire = 3
	jam_frequency_reload = 3

	shoot()
		//If we're doing a double action thing here where it automatically resets and is ready to fire the next shot?
		//Maybe a short sleep, that's the tradeoff for not having to click it every time... I'm not putting it in until I sort out more
		//ALSO: handle unloading all rounds (shot or unshot) at same time, don't load until unloaded?
		//much too consider
		..()
		process_ammo()

/obj/item/gun/modular/italian/basic

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/italian/small(src)
		grip = new /obj/item/gun_parts/grip/italian(src)

//Standard factory issue
/obj/item/gun/modular/italian/italiano
	max_ammo_capacity = 3

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
	max_ammo_capacity = 4

	make_parts()

		if (prob(75))
			stock = new /obj/item/gun_parts/stock/italian(src)
			barrel = new /obj/item/gun_parts/barrel/italian/buntline(src)
		else
			grip = new /obj/item/gun_parts/grip/italian/bigger(src)
			barrel = new /obj/item/gun_parts/barrel/italian/accurate(src)

//da jokah babiyyyy
/obj/item/gun/modular/italian/silly
	max_ammo_capacity = 4

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/italian/joker(src)
		grip = new /obj/item/gun_parts/grip/italian/cowboy/bandit(src)

//a receiver that represents the basic standard mounting positions and changes between them when used in hand
//clickdrag onto itself to assemble/disassemble
//will revisit this later
/*
/obj/item/gun/modular/debug
	var/debugnum = 0 //start basic
	var/debugmax = 6 //six debug gunse
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
