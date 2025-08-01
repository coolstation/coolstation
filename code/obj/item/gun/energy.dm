/obj/item/gun/energy
	name = "energy weapon"
	icon = 'icons/obj/items/gun.dmi'
	item_state = "gun"
	m_amt = 2000
	g_amt = 1000
	mats = 32
	add_residue = 0 // Does this gun add gunshot residue when fired? Energy guns shouldn't.
	var/rechargeable = 1 // Can we put this gun in a recharger? False should be a very rare exception.
	var/robocharge = 800
	var/cell_type = /obj/item/ammo/power_cell // Type of cell to spawn by default.
	var/custom_cell_max_capacity = null // Is there a limit as to what power cell (in PU) we can use?
	var/wait_cycle = 0 // Using a self-charging cell should auto-update the gun's sprite.
	var/can_swap_cell = 1
	muzzle_flash = null
	inventory_counter_enabled = 1

	New()
		var/cell = null
		if(cell_type)
			cell = new cell_type
		AddComponent(/datum/component/cell_holder, cell, rechargeable, custom_cell_max_capacity, can_swap_cell)
		RegisterSignal(src, COMSIG_UPDATE_ICON, PROC_REF(update_icon))
		..()
		update_icon()

	disposing()
		processing_items -= src
		..()


	examine()
		. = ..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			. += "[src.projectiles ? "It is set to [src.current_projectile.sname]. " : ""]There are [ret["charge"]]/[ret["max_charge"]] PUs left!"
		else
			. += "There is no cell loaded!"
		if(current_projectile)
			. += "Each shot will currently use [src.current_projectile.cost] PUs!"
		else
			. += "<span class='alert'>*ERROR* No output selected!</span>"

	update_icon()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			inventory_counter.update_percent(ret["charge"], ret["max_charge"])
		else
			inventory_counter.update_text("-")
		return 0

	emp_act()
		SEND_SIGNAL(src, COMSIG_CELL_USE, INFINITY)
		src.update_icon()
		return

/*
	process()
		src.wait_cycle = !src.wait_cycle // Self-charging cells recharge every other tick (Convair880).
		if (src.wait_cycle)
			return

		if (!(src in processing_items))
			logTheThing("debug", null, null, "<b>Convair880</b>: Process() was called for an egun ([src]) that wasn't in the item loop. Last touched by: [src.fingerprintslast]")
			processing_items.Add(src)
			return
		if (!src.cell)
			processing_items.Remove(src)
			return
		if (!istype(src.cell, /obj/item/ammo/power_cell/self_charging)) // Plain cell? No need for dynamic updates then (Convair880).
			processing_items.Remove(src)
			return
		if (src.cell.charge == src.cell.max_charge) // Keep them in the loop, as we might fire the gun later (Convair880).
			return

		src.update_icon()
		return
*/

	canshoot()
		if(src.current_projectile)
			if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, current_projectile.cost) & CELL_SUFFICIENT_CHARGE)
				return 1
		return 0

	process_ammo(var/mob/user)
		if(isrobot(user))
			var/mob/living/silicon/robot/R = user
			if(R.cell)
				if(R.cell.charge >= src.robocharge)
					R.cell.charge -= src.robocharge
					return 1
			return 0
		else
			if(canshoot())
				SEND_SIGNAL(src, COMSIG_CELL_USE, src.current_projectile.cost)
				return 1
			boutput(user, "<span class='alert'>*click* *click*</span>")
			if (!src.silenced)
				playsound(user, "sound/weapons/Gunclick.ogg", 60, 1)
			return 0

/*
/obj/item/gun/energy/heavyion
	name = "heavy ion blaster"
	icon_state = "heavyion"
	item_state = "rifle"
	force = 1.0
	desc = "..."
	//charge_up = 15
	can_dual_wield = 0
	two_handed = 1
	slowdown = 5
	slowdown_time = 5
	cell_type = /obj/item/ammo/power_cell/self_charging/disruptor
	w_class = W_CLASS_BULKY
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY

	New()
		set_current_projectile(new/datum/projectile/heavyion)
		projectiles = list(current_projectile)
		..()

	pixelaction(atom/target, params, mob/user, reach)
		if(..(target, params, user, reach))
			playsound(user, "sound/weapons/heavyioncharge.ogg", 90)

////////////////////////////////////TASERGUN
/obj/item/gun/energy/taser_gun
	name = "taser gun"
	icon_state = "taser"
	item_state = "taser"
	uses_multiple_icon_states = 1
	force = 1.0
	cell_type = /obj/item/ammo/power_cell/med_power
	desc = "A weapon that produces an cohesive electrical charge that stuns its target."
	muzzle_flash = "muzzle_flash_elec"

	New()
		set_current_projectile(new/datum/projectile/energy_bolt)
		projectiles = list(current_projectile,new/datum/projectile/energy_bolt/burst)
		..()

	update_icon()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			if (current_projectile.type == /datum/projectile/energy_bolt/burst)
				src.icon_state = "taserburst[ratio]"
			else if(current_projectile.type == /datum/projectile/energy_bolt)
				src.icon_state = "taser[ratio]"
		..()

	attack_self()
		..()
		update_icon()

	borg
		cell_type = /obj/item/ammo/power_cell/self_charging/disruptor

/obj/item/gun/energy/taser_gun/bouncy
	name = "richochet taser gun"
	desc = "A weapon that produces an cohesive electrical charge that stuns its target. This one appears to be capable of firing ricochet charges."

	New()
		..()
		set_current_projectile(new/datum/projectile/energy_bolt/bouncy)
		projectiles = list(current_projectile)

	update_icon()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			if(current_projectile.type == /datum/projectile/energy_bolt/bouncy)
				src.icon_state = "taser[ratio]"
		..()

/////////////////////////////////////LASERGUN
/obj/item/gun/energy/laser_gun
	name = "laser gun"
	icon_state = "laser"
	item_state = "laser"
	uses_multiple_icon_states = 1
	cell_type = /obj/item/ammo/power_cell/med_plus_power
	force = 7.0
	desc = "A gun that produces a harmful laser, causing substantial damage."
	muzzle_flash = "muzzle_flash_laser"

	New()
		set_current_projectile(new/datum/projectile/laser)
		projectiles = list(current_projectile)
		..()

	virtual
		icon = 'icons/effects/VR.dmi'
		New()
			..()
			set_current_projectile(new /datum/projectile/laser/virtual)
			projectiles.len = 0
			projectiles += current_projectile

	update_icon()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "laser[ratio]"
			return
		..()

////////////////////////////////////// Antique laser gun
// Part of a mini-quest thing (see displaycase.dm). Typically, the gun's properties (cell, projectile)
// won't be the default ones specified here, it's here to make it admin-spawnable (Convair880).
/obj/item/gun/energy/laser_gun/antique
	name = "antique laser gun"
	icon_state = "caplaser"
	uses_multiple_icon_states = 1
	desc = "Wait, that's not a plastic toy..."
	muzzle_flash = "muzzle_flash_laser"
	cell_type = /obj/item/ammo/power_cell/med_power

	New()
		if (!src.current_projectile)
			src.set_current_projectile(new /datum/projectile/laser)
		if (isnull(src.projectiles))
			src.projectiles = list(src.current_projectile)
		src.update_icon()
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "caplaser[ratio]"
			return

//////////////////////////////////////// Phaser
/obj/item/gun/energy/phaser_gun
	name = "phaser gun"
	icon_state = "phaser-new"
	uses_multiple_icon_states = 1
	item_state = "phaser"
	force = 7.0
	desc = "A gun that produces a harmful phaser bolt, causing substantial damage."
	muzzle_flash = "muzzle_flash_phaser"
	cell_type = /obj/item/ammo/power_cell/med_power

	New()
		set_current_projectile(new/datum/projectile/laser/light)
		projectiles = list(current_projectile)
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "phaser-new[ratio]"
			return

///////////////////////////////////////Rad Crossbow
/obj/item/gun/energy/crossbow
	name = "mini rad-poison-crossbow"
	desc = "A weapon favored by many of the syndicate's stealth specialists, which does damage over time using a slow-acting radioactive poison. Utilizes a self-recharging atomic power cell."
	icon_state = "crossbow"
	uses_multiple_icon_states = 1
	w_class = W_CLASS_SMALL
	item_state = "crossbow"
	force = 4.0
	throw_speed = 3
	throw_range = 10
	rechargeable = 0 // Cannot be recharged manually.
	cell_type = /obj/item/ammo/power_cell/self_charging/slowcharge
	projectiles = null
	is_syndicate = 1
	silenced = 1 // No conspicuous text messages, please (Convair880).
	hide_attack = 1
	custom_cell_max_capacity = 100 // Those self-charging ten-shot radbows were a bit overpowered (Convair880)
	muzzle_flash = null

	New()
		set_current_projectile(new/datum/projectile/rad_bolt)
		projectiles = list(current_projectile)
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			if(ret["charge"] >= 37) //this makes it only enter its "final" sprite when it's actually able to fire, if you change the amount of charge regen or max charge the bow has, make this number one charge increment before full charge
				set_icon_state("crossbow")
				return
			else
				var/ratio = min(1, ret["charge"] / ret["max_charge"])
				ratio = round(ratio, 0.25) * 100
				set_icon_state("crossbow[ratio]")
				return

////////////////////////////////////////EGun
/obj/item/gun/energy/egun
	name = "energy gun"
	icon_state = "energy"
	uses_multiple_icon_states = 1
	cell_type = /obj/item/ammo/power_cell/med_plus_power
	desc = "Its a gun that has two modes, stun and kill"
	item_state = "egun"
	force = 5.0
	mats = list("MET-1"=15, "CON-1"=5, "POW-1"=5)
	var/nojobreward = 0 //used to stop people from scanning it and then getting both a lawbringer/sabre AND an egun.
	muzzle_flash = "muzzle_flash_elec"

	New()
		set_current_projectile(new/datum/projectile/energy_bolt)
		projectiles = list(current_projectile,new/datum/projectile/laser)
		..()
	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			if(current_projectile.type == /datum/projectile/energy_bolt)
				src.item_state = "egun"
				src.icon_state = "energystun[ratio]"
				muzzle_flash = "muzzle_flash_elec"
			else if (current_projectile.type == /datum/projectile/laser)
				src.item_state = "egun-kill"
				src.icon_state = "energykill[ratio]"
				muzzle_flash = "muzzle_flash_laser"
			else
				src.item_state = "egun"
				src.icon_state = "energy[ratio]"
				muzzle_flash = "muzzle_flash_elec"
	attack_self(var/mob/M)
		..()
		update_icon()
		M.update_inhands()

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/electronics/scanner))
			nojobreward = 1
		..()

//////////////////////// nanotrasen gun
//Azungar's Nanotrasen inspired Laser Assault Rifle for RP gimmicks
/obj/item/gun/energy/ntgun
	name = "Laser Assault Rifle"
	icon_state = "ntneutral100"
	desc = "Rather futuristic assault rifle with two firing modes."
	item_state = "ntgun"
	force = 10.0
	contraband = 8
	two_handed = 1
	spread_angle = 6
	cell_type = /obj/item/ammo/power_cell/med_power

	New()
		set_current_projectile(new/datum/projectile/energy_bolt/ntburst)
		projectiles = list(current_projectile,new/datum/projectile/laser/ntburst)
		..()
	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			if(current_projectile.type == /datum/projectile/energy_bolt/ntburst)
				src.icon_state = "ntstun[ratio]"
			else if (current_projectile.type == /datum/projectile/laser/ntburst)
				src.icon_state = "ntlethal[ratio]"
			else
				src.icon_state = "ntneutral[ratio]"
	attack_self()
		..()
		update_icon()


////////////////////////////////////VUVUV
/obj/item/gun/energy/vuvuzela_gun
	name = "amplified vuvuzela"
	icon_state = "vuvuzela"
	uses_multiple_icon_states = 1
	item_state = "bike_horn"
	desc = "BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZT, *fart*"
	cell_type = /obj/item/ammo/power_cell/med_power
	is_syndicate = 1

	New()
		set_current_projectile(new/datum/projectile/energy_bolt_v)
		projectiles = list(current_projectile)
		..()
	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "vuvuzela[ratio]"

//////////////////////////////////////Crabgun
/obj/item/gun/energy/crabgun
	name = "a strange crab"
	desc = "Years of extreme genetic tinkering have finally led to the feared combination of crab and gun."
	icon = 'icons/obj/crabgun.dmi'
	icon_state = "crabgun"
	item_state = "crabgun-world"
	inhand_image_icon = 'icons/obj/crabgun.dmi'
	w_class = W_CLASS_BULKY
	force = 12.0
	throw_speed = 8
	throw_range = 12
	rechargeable = 0
	cell_type = /obj/item/ammo/power_cell/self_charging/slowcharge
	projectiles = null
	is_syndicate = 1
	custom_cell_max_capacity = 100 //endless crab

	New()
		set_current_projectile(new/datum/projectile/claw)
		projectiles = list(current_projectile)
		..()

	attackby(obj/item/b, mob/user)
		if(istype(b, /obj/item/ammo/power_cell))
			boutput(user, "<span class='alert'>You attempt to swap the cell but \the [src] bites you instead.</span>")
			playsound(src.loc, "sound/impact_sounds/Flesh_Stab_1.ogg", 50, 1, -6)
			user.TakeDamage(user.zone_sel.selecting, 3, 0)
			take_bleeding_damage(user, user, 3, DAMAGE_CUT)
			return
		. = ..()




//////////////////////////////////////Disruptor
/obj/item/gun/energy/disruptor
	name = "Disruptor"
	icon_state = "disruptor"
	uses_multiple_icon_states = 1
	desc = "Disruptor Blaster - Comes equipped with self-charging powercell."
	m_amt = 4000
	force = 6.0
	cell_type = /obj/item/ammo/power_cell/self_charging/disruptor

	New()
		set_current_projectile(new/datum/projectile/disruptor)
		projectiles = list(current_projectile,new/datum/projectile/disruptor/burst,new/datum/projectile/disruptor/high)
		src.update_icon()
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.20) * 100
			src.icon_state = "disruptor[ratio]"
		return

////////////////////////////////////Wave Gun
/obj/item/gun/energy/wavegun
	name = "Wave Gun"
	icon = 'icons/obj/items/gun.dmi'
	icon_state = "wavegun100"
	item_state = "wave"
	cell_type = /obj/item/ammo/power_cell/med_power
	uses_multiple_icon_states = 1
	m_amt = 4000
	force = 6.0
	muzzle_flash = "muzzle_flash_wavep"

	New()
		set_current_projectile(new/datum/projectile/wavegun)
		projectiles = list(current_projectile,new/datum/projectile/wavegun/transverse,new/datum/projectile/wavegun/bouncy)
		..()

	// Old phasers aren't around anymore, so the wave gun might as well use their better sprite (Convair880).
	// Flaborized has made a lovely new wavegun sprite! - Gannets
	// Flaborized has made even more wavegun sprites!
	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			if(current_projectile.type == /datum/projectile/wavegun)
				src.icon_state = "wavegun[ratio]"
				item_state = "wave"
				muzzle_flash = "muzzle_flash_wavep"
			else if (current_projectile.type == /datum/projectile/wavegun/transverse)
				src.icon_state = "wavegun_green[ratio]"
				item_state = "wave-g"
				muzzle_flash = "muzzle_flash_waveg"
			else
				src.icon_state = "wavegun_emp[ratio]"
				item_state = "wave-emp"
				muzzle_flash = "muzzle_flash_waveb"

	attack_self(mob/user as mob)
		..()
		update_icon()
		user.update_inhands()
*/
////////////////////////////////////BFG
/obj/item/gun/energy/bfg
	name = "BFG 9000"
	icon = 'icons/obj/items/gun.dmi'
	icon_state = "bfg"
	m_amt = 4000
	force = 6.0
	desc = "I think it stands for Banned For Griefing?"
	cell_type = /obj/item/ammo/power_cell/high_power

	New()
		set_current_projectile(new/datum/projectile/bfg)
		projectiles = list(new/datum/projectile/bfg)
		..()

	update_icon()
		..()
		return

	shoot(var/target,var/start,var/mob/user)
		if (canshoot()) // No more attack messages for empty guns (Convair880).
			playsound(user, "sound/weapons/DSBFG.ogg", 75)
			sleep(0.9 SECONDS)
		return ..(target, start, user)

/obj/item/gun/energy/bfg/vr
	icon = 'icons/effects/VR.dmi'

///////////////////////////////////////Telegun
/obj/item/gun/energy/teleport
	name = "teleport gun"
	desc = "A hacked together combination of a taser and a handheld teleportation unit."
	icon_state = "teleport"
	uses_multiple_icon_states = 1
	w_class = W_CLASS_NORMAL
	item_state = "gun"
	force = 10.0
	throw_speed = 2
	throw_range = 10
	mats = 0
	cell_type = /obj/item/ammo/power_cell/med_power
	var/obj/item/our_target = null
	var/obj/machinery/computer/teleporter/our_teleporter = null // For checks before firing (Convair880).

	New()
		set_current_projectile(new /datum/projectile/tele_bolt)
		projectiles = list(current_projectile)
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "teleport[ratio]"
		else
			icon_state = "teleport"
	// I overhauled everything down there. Old implementation made the telegun unreliable and crap, to be frank (Convair880).
	attack_self(mob/user as mob)
		src.add_fingerprint(user)

		var/list/L = list()
		L += "None (Cancel)" // So we'll always get a list, even if there's only one teleporter in total.

		for(var/obj/machinery/teleport/portal_generator/PG as anything in machine_registry[MACHINES_PORTALGENERATORS])
			if (!PG.linked_computer || !PG.linked_rings)
				continue
			var/turf/PG_loc = get_turf(PG)
			if (PG && isrestrictedz(PG_loc.z)) // Don't show teleporters in "somewhere", okay.
				continue

			var/obj/machinery/computer/teleporter/Control = PG.linked_computer
			if (Control)
				switch (Control.check_teleporter())
					if (0) // It's busted, Jim.
						continue
					if (1)
						L["Tele at [get_area(Control)]: Locked in ([ismob(Control.locked.loc) ? "[Control.locked.loc.name]" : "[get_area(Control.locked)]"])"] += Control
					if (2)
						L["Tele at [get_area(Control)]: *NOPOWER*"] += Control
					if (3)
						L["Tele at [get_area(Control)]: Inactive"] += Control
			else
				continue

		if (L.len < 2)
			user.show_text("Error: no working teleporters detected.", "red")
			return

		var/t1 = input(user, "Please select a teleporter to lock in on.", "Target Selection") in L
		if ((user.equipped() != src) || user.stat || user.restrained())
			return
		if (t1 == "None (Cancel)")
			return

		var/obj/machinery/computer/teleporter/Control2 = L[t1]
		if (Control2)
			src.our_teleporter = null
			src.our_target = null
			switch (Control2.check_teleporter())
				if (0)
					user.show_text("Error: selected teleporter is out of order.", "red")
					return
				if (1)
					src.our_target = Control2.locked
					if (!our_target)
						user.show_text("Error: selected teleporter is locked in to invalid coordinates.", "red")
						return
					else
						user.show_text("Teleporter selected. Locked in on [ismob(Control2.locked.loc) ? "[Control2.locked.loc.name]" : "beacon"] in [get_area(Control2.locked)].", "blue")
						src.our_teleporter = Control2
						return
				if (2)
					user.show_text("Error: selected teleporter is unpowered.", "red")
					return
				if (3)
					user.show_text("Error: selected teleporter is not locked in.", "red")
					return
		else
			user.show_text("Error: couldn't establish connection to selected teleporter.", "red")
			return

	attack(mob/M as mob, mob/user as mob)
		if (!src.our_target)
			user.show_text("Error: no target set. Please select a teleporter first.", "red")
			return
		if (!src.our_teleporter || (src.our_teleporter.check_teleporter() != 1))
			user.show_text("Error: linked teleporter is out of order.", "red")
			return

		var/datum/projectile/tele_bolt/TB = current_projectile
		TB.target = our_target
		return ..(M, user)

	shoot(var/target, var/start, var/mob/user)
		if (!src.our_target)
			user.show_text("Error: no target set. Please select a teleporter first.", "red")
			return
		if (!src.our_teleporter || (src.our_teleporter.check_teleporter() != 1))
			user.show_text("Error: linked teleporter is out of order.", "red")
			return

		var/datum/projectile/tele_bolt/TB = current_projectile
		TB.target = our_target
		return ..(target, start, user)

///////////////////////////////////////Ghost Gun
/obj/item/gun/energy/ghost
	name = "ectoplasmic destabilizer"
	desc = "If this had streams, it would be inadvisable to cross them. But no, it fires bolts instead.  Don't throw it into a stream, I guess?"
	icon_state = "ghost"
	w_class = W_CLASS_NORMAL
	item_state = "gun"
	force = 10.0
	throw_speed = 2
	throw_range = 10
	mats = 0
	cell_type = /obj/item/ammo/power_cell/med_power
	muzzle_flash = "muzzle_flash_waveg"

	New()
		set_current_projectile(new /datum/projectile/energy_bolt_antighost)
		projectiles = list(current_projectile)
		..()

///////////////////////////////////////Not Modular Blasters
/*
/obj/item/gun/energy/blaster_pistol
	name = "blaster pistol"
	desc = "A dangerous-looking blaster pistol. It's self-charging by a radioactive power cell."
	icon = 'icons/obj/items/gun_mod.dmi'
	icon_state = "pistol"
	w_class = W_CLASS_NORMAL
	force = 5.0
	mats = 0
	cell_type = /obj/item/ammo/power_cell/self_charging/medium
*/

	/*
	var/obj/item/gun_parts/emitter/emitter = null
	var/obj/item/gun_parts/back/back = null
	var/obj/item/gun_parts/top_rail/top_rail = null
	var/obj/item/gun_parts/bottom_rail/bottom_rail = null
	var/heat = 0 // for overheating stuff

	New()
		if (!emitter)
			emitter = new /obj/item/gun_parts/emitter
		if(!current_projectile)
			set_current_projectile(src.emitter.projectile)
		projectiles = list(current_projectile)
		..() */



	//handle gun mods at a workbench
/*

	New()
		set_current_projectile(new /datum/projectile/laser/blaster)
		projectiles = list(current_projectile)
		..()


	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "pistol[ratio]"
			return
*/



	/*examine()
		set src in view()
		boutput(usr, "<span class='notice'>Installed components:</span><br>")
		if(emitter)
			boutput(usr, "<span class='notice'>[src.emitter.name]</span>")
		if(cell)
			boutput(usr, "<span class='notice'>[src.cell.name]</span>")
		if(back)
			boutput(usr, "<span class='notice'>[src.back.name]</span>")
		if(top_rail)
			boutput(usr, "<span class='notice'>[src.top_rail.name]</span>")
		if(bottom_rail)
			boutput(usr, "<span class='notice'>[src.bottom_rail.name]</span>")
		..()*/

	/*proc/generate_overlays()
		src.overlays = null
		if(extension_mod)
			src.overlays += icon('icons/obj/items/gun_mod.dmi',extension_mod.overlay_name)
		if(converter_mod)
			src.overlays += icon('icons/obj/items/gun_mod.dmi',converter_mod.overlay_name)*/
/*
/obj/item/gun/energy/blaster_smg
	name = "burst blaster"
	desc = "A special issue blaster weapon, configured for burst fire. It's self-charging by a radioactive power cell."
	icon = 'icons/obj/items/gun_mod.dmi'
	icon_state = "smg"
	can_dual_wield = 0
	w_class = W_CLASS_NORMAL
	force = 7.0
	mats = 0
	cell_type = /obj/item/ammo/power_cell/self_charging/medium


	New()
		set_current_projectile(new /datum/projectile/laser/blaster/burst)
		projectiles = list(current_projectile)
		..()


	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "smg[ratio]"
			return

/obj/item/gun/energy/blaster_cannon
	name = "blaster cannon"
	desc = "A heavily overcharged blaster weapon, modified for extreme firepower. It's self-charging by a larger radioactive power cell."
	icon = 'icons/obj/items/gun_mod.dmi'
	icon_state = "cannon"
	item_state = "rifle"
	can_dual_wield = 0
	two_handed = 1
	w_class = W_CLASS_BULKY
	force = 15
	cell_type = /obj/item/ammo/power_cell/self_charging/big


	New()
		set_current_projectile(new /datum/projectile/special/spreader/uniform_burst/blaster)
		projectiles = list(current_projectile)
		flags |= ONBACK
		..()


	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "cannon[ratio]"
			return
*/

///////////modular components - putting them here so it's easier to work on for now////////
/*
/obj/item/gun_parts
	name = "gun parts"
	desc = "Components for building custom sidearms."
	item_state = "table_parts"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon = 'icons/obj/items/gun_mod.dmi'
	icon_state = "frame" // todo: make more item icons
	mats = 0

/obj/item/gun_parts/emitter
	name = "optical pulse emitter"
	desc = "Generates a pulsed burst of energy."
	icon_state = "emitter"
	var/datum/projectile/laser/light/projectile = new/datum/projectile/laser/light
	var/obj/item/device/flash/flash = new/obj/item/device/flash
	//use flash as the core of the device

	// inherit material vars from the flash

/obj/item/gun_parts/back
	name = "phaser stock"
	desc = "A gun stock for a modular phaser. Does this even do anything? Probably not."
	icon_state = "mod-stock"

/obj/item/gun_parts/top_rail
	name = "phaser pulse modifier"
	desc = "Modifies the beam path of modular phaser."
	icon_state = "mod-range"

	range
		name = "beam collimator"
		icon_state = "mod-range"

	width
		name = "beam spreader"
		icon_state = "mod-aoe"

/obj/item/gun_parts/bottom_rail
	name = "Phaser accessory"

	sight
		name = "phaser dot accessory"
		icon_state = "mod-sight"
		// idk what the hell this would even do

	flashlight
		name = "phaser flashlight accessory"
		icon_state = "mod-flashlight"

	heatsink
		name = "phaser heatsink"
		icon_state = "mod-heatsink"

	grip // tacticool
		name = "fore grip"
		icon_state = "mod-grip"
*/
///////////////////////////////////////Owl Gun
/*
/obj/item/gun/energy/owl
	name = "Owl gun"
	desc = "Its a gun that has two modes, Owl and Owler"
	item_state = "gun"
	force = 5.0
	icon_state = "ghost"
	uses_multiple_icon_states = 1
	cell_type = /obj/item/ammo/power_cell/med_power

	New()
		set_current_projectile(new/datum/projectile/owl)
		projectiles = list(current_projectile,new/datum/projectile/owl/owlate)
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "ghost[ratio]"

/obj/item/gun/energy/owl_safe
	name = "Owl gun"
	desc = "Hoot!"
	item_state = "gun"
	force = 5.0
	icon_state = "ghost"
	uses_multiple_icon_states = 1
	cell_type = /obj/item/ammo/power_cell/med_power

	New()
		set_current_projectile(new/datum/projectile/owl)
		projectiles = list(current_projectile)
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "ghost[ratio]"

/////////////////////////////////////Frog Gun (Shoots :getin: and :getout:)
/obj/item/gun/energy/frog
	name = "Frog Gun"
	item_state = "gun"
	m_amt = 1000
	force = 0.0
	icon_state = "frog"
	cell_type = /obj/item/ammo/power_cell/self_charging/big //gotta have power for the frog
	desc = "It appears to be shivering and croaking in your hand. How creepy." //it must be unhoppy :^)

	New()
		set_current_projectile(new/datum/projectile/bullet/frog)
		projectiles = list(current_projectile,new/datum/projectile/bullet/frog/getout)
		..()
*/

///////////////////////////////////////Shrink Ray
/obj/item/gun/energy/shrinkray
	name = "Shrink ray"
	item_state = "gun"
	force = 5.0
	icon_state = "ghost"
	cell_type = /obj/item/ammo/power_cell/med_power
	uses_multiple_icon_states = 1

	New()
		set_current_projectile(new/datum/projectile/shrink_beam)
		projectiles = list(current_projectile)
		..()
	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "ghost[ratio]"

/obj/item/gun/energy/shrinkray/growray
	name = "Grow ray"
	New()
		..()
		set_current_projectile(new/datum/projectile/shrink_beam/grow)
		projectiles = list(current_projectile)


///////////////////////////////////////Glitch Gun
/obj/item/gun/energy/glitch_gun
	name = "Glitch Gun"
	icon = 'icons/obj/items/gun.dmi'
	icon_state = "airzooka"
	m_amt = 4000
	force = 0.0
	cell_type = /obj/item/ammo/power_cell/high_power
	desc = "It's humming with some sort of disturbing energy. Do you really wanna hold this?"

	New()
		set_current_projectile(new/datum/projectile/bullet/glitch/gun)
		projectiles = list(new/datum/projectile/bullet/glitch/gun)
		..()

	shoot(var/target,var/start,var/mob/user,var/POX,var/POY)
		if (canshoot()) // No more attack messages for empty guns (Convair880).
			playsound(user, "sound/weapons/DSBFG.ogg", 75)
			sleep(0.1 SECONDS)
		return ..(target, start, user)

///////////////////////////////////////Hunter
/*
/obj/item/gun/energy/laser_gun/pred // Made use of a spare sprite here (Convair880).
	name = "laser rifle"
	desc = "This advanced bullpup rifle contains a self-recharging power cell."
	icon_state = "bullpup"
	item_state = "bullpup"
	uses_multiple_icon_states = 1
	force = 5.0
	cell_type = /obj/item/ammo/power_cell/self_charging/big
	muzzle_flash = "muzzle_flash_plaser"
	mats = list("MET-3"=7, "CRY-1"=13, "POW-2"=10)

	New()
		..()
		set_current_projectile(new/datum/projectile/laser/pred)
		projectiles = list(new/datum/projectile/laser/pred)

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "bullpup[ratio]"
			return

/obj/item/gun/energy/laser_gun/pred/vr
	name = "advanced laser gun"
	icon = 'icons/effects/VR.dmi'
	icon_state = "wavegun"

	update_icon() // Necessary. Parent's got a different sprite now (Convair880).
		return
*/
/////////////////////////////////////// Pickpocket Grapple, Grayshift's grif gun
/obj/item/gun/energy/pickpocket
	name = "pickpocket grapple gun" // absurdly shitty name
	desc = "A complicated, camoflaged claw device on a tether capable of complex and stealthy interactions. It steals shit."
	icon_state = "pickpocket"
	w_class = W_CLASS_SMALL
	item_state = "pickpocket"
	force = 4.0
	throw_speed = 3
	throw_range = 10
	rechargeable = 0 // Cannot be recharged manually.
	cell_type = /obj/item/ammo/power_cell/self_charging/slowcharge
	projectiles = null
	is_syndicate = 1
	silenced = 1
	hide_attack = 1
	mats = 100 //yeah no, you can do it if you REALLY want to
	custom_cell_max_capacity = 100
	var/obj/item/heldItem = null
	tooltip_flags = REBUILD_DIST

	New()
		set_current_projectile(new/datum/projectile/pickpocket/steal)
		projectiles = list(current_projectile, new/datum/projectile/pickpocket/plant, new/datum/projectile/pickpocket/harass)
		..()

	get_desc(dist)
		..()
		if (dist < 1) // on our tile or our person
			if (.) // we're returning something
				. += " " // add a space
			if (src.heldItem)
				. += "It's currently holding \a [src.heldItem]."
			else
				. += "It's not holding anything."

	attack_hand(mob/user as mob)
		if (src.loc == user && (src == user.l_hand || src == user.r_hand))
			if (heldItem)
				boutput(user, "You remove \the [heldItem.name] from the gun.")
				user.put_in_hand_or_drop(heldItem)
				heldItem = null
				tooltip_rebuild = 1
			else
				boutput(user, "The gun does not contain anything.")
		else
			return ..()

	attackby(obj/item/I as obj, mob/user as mob)
		if (I.cant_drop) return
		if (heldItem)
			boutput(user, "The gun is already holding [heldItem.name].")
		else
			heldItem = I
			user.u_equip(I)
			I.dropped(user)
			boutput(user, "You insert \the [heldItem.name] into the gun's gripper.")
			tooltip_rebuild = 1
		return ..()

	attack(mob/M as mob, mob/user as mob)
		if (istype(current_projectile, /datum/projectile/pickpocket/steal) && heldItem)
			boutput(user, "Cannot steal while gun is holding something!")
			return
		if (istype(current_projectile, /datum/projectile/pickpocket/plant) && !heldItem)
			boutput(user, "Cannot plant item if gun is not holding anything!")
			return

		var/datum/projectile/pickpocket/shot = current_projectile
		shot.linkedGun = src
		shot.firer = user.key
		shot.targetZone = user.zone_sel.selecting
		var/turf/us = get_turf(src)
		var/turf/tgt = get_turf(M)
		if(isrestrictedz(us.z) || isrestrictedz(tgt.z))
			boutput(user, "\The [src.name] jams!")
			return
		return ..(M, user)

	shoot(var/target, var/start, var/mob/user)
		if (istype(current_projectile, /datum/projectile/pickpocket/steal) && heldItem)
			boutput(user, "Cannot steal items while gun is holding something!")
			return
		if (istype(current_projectile, /datum/projectile/pickpocket/plant) && !heldItem)
			boutput(user, "Cannot plant item if gun is not holding anything!")
			return

		var/turf/us = get_turf(src)
		var/turf/tgt = get_turf(target)
		if(isrestrictedz(us.z) || isrestrictedz(tgt.z))
			boutput(user, "\The [src.name] jams!")
			message_admins("[key_name(user)] is a nerd and tried to fire a pickpocket gun in a restricted z-level at [showCoords(us.x, us.y, us.z)].")
			return


		var/datum/projectile/pickpocket/shot = current_projectile
		shot.linkedGun = src
		shot.targetZone = user.zone_sel.selecting
		shot.firer = user.key
		return ..(target, start, user)

/obj/item/gun/energy/pickpocket/testing // has a beefier cell in it
	cell_type = /obj/item/ammo/power_cell/self_charging/big

/*
/obj/item/gun/energy/alastor
	name = "Alastor pattern laser rifle"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "alastor100"
	item_state = "alastor"
	icon = 'icons/obj/large/38x38.dmi'
	uses_multiple_icon_states = 1
	force = 7.0
	can_dual_wield = 0
	two_handed = 1
	cell_type = /obj/item/ammo/power_cell/med_power
	desc = "A gun that produces a harmful laser, causing substantial damage."
	muzzle_flash = "muzzle_flash_laser"

	New()
		set_current_projectile(new/datum/projectile/laser/alastor)
		projectiles = list(current_projectile)
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "alastor[ratio]"
			return
*/
///////////////////////////////////////////////////

//turn these into switchable foam dart/water/noisemaker gun toys just in my imo
//space cop playset comes with unassailable plastic badge and ignorable consent decree

/*
/obj/item/gun/energy/lawbringer/old
	name = "Antique Lawbringer"
	icon = 'icons/obj/items/gun.dmi'
	icon_state = "old-lawbringer0"
	old = 1

/obj/item/gun/energy/lawbringer
	name = "Lawbringer"
	icon = 'icons/obj/items/gun.dmi'
	item_state = "lawg-detain"
	icon_state = "lawbringer0"
	desc = "A gun with a microphone. Fascinating."
	var/old = 0
	m_amt = 5000
	g_amt = 2000
	cell_type = null ///obj/item/ammo/power_cell/self_charging/lawbringer
	mats = list("MET-1"=15, "CON-2"=5, "POW-2"=5)
	var/owner_prints = null
	var/image/indicator_display = null
	rechargeable = 0
	can_swap_cell = 0
	muzzle_flash = "muzzle_flash_elec"

	New(var/mob/M)
		set_current_projectile(new/datum/projectile/energy_bolt/aoe)
		projectiles = list("detain" = current_projectile, "execute" = new/datum/projectile/bullet/pistol_weak, "smokeshot" = new/datum/projectile/bullet/smoke, "knockout" = new/datum/projectile/bullet/tranq_dart, "hotshot" = new/datum/projectile/bullet/flare, "bigshot" = new/datum/projectile/bullet/shot_weak, "clownshot" = new/datum/projectile/bullet/clownshot, "pulse" = new/datum/projectile/energy_bolt/pulse)
		// projectiles = list(current_projectile,new/datum/projectile/bullet/pistol_italian,new/datum/projectile/bullet/smoke,new/datum/projectile/bullet/tranq_dart/law_giver,new/datum/projectile/bullet/flare,new/datum/projectile/bullet/slug_boom,new/datum/projectile/bullet/clownshot)

		src.indicator_display = image('icons/obj/items/gun.dmi', "")
		asign_name(M)

		..()

	disposing()
		indicator_display = null
		..()

	attack_hand(mob/user as mob)
		if (!owner_prints)
			boutput(user, "<span class='alert'>[src] has accepted your fingerprint ID. You are its owner!</span>")
			asign_name(user)
		..()


	//if it has no owner prints scanned, the next person to attack_self it is the owner.
	//you have to use voice activation to change modes. haha!
	attack_self(mob/user as mob)
		src.add_fingerprint(user)
		if (!owner_prints)
			boutput(user, "<span class='alert'>[src] has accepted your fingerprint ID. You are its owner!</span>")
			asign_name(user)
		else
			boutput(user, "<span class='notice'>There don't seem to be any buttons on [src] to press.</span>")

	proc/asign_name(var/mob/M)
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (H.bioHolder)
				owner_prints = H.bioHolder.uid_hash
				src.name = "HoS [H.real_name]'s Lawbringer"
				tooltip_rebuild = 1

	//stolen the heartalk of microphone. the microphone can hear you from one tile away. unless you wanna
	hear_talk(mob/M as mob, msg, real_name, lang_id)
		var/turf/T = get_turf(src)
		if (M in range(1, T))
			src.talk_into(M, msg, null, real_name, lang_id)

	//can only handle one name at a time, if it's more it doesn't do anything
	talk_into(mob/M as mob, msg, real_name, lang_id)
		//Do I need to check for this? I can't imagine why anyone would pass the wrong var here...
		if (!islist(msg))
			return

		//only work if the voice is the same as the voice of your owner fingerprints.
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (owner_prints && (H.bioHolder.uid_hash != owner_prints))
				are_you_the_law(M, msg[1])
				return
		else
			are_you_the_law(M, msg[1])
			return //AFAIK only humans have fingerprints/"palmprints(in judge dredd)" so just ignore any talk from non-humans arlight? it's not a big deal.

		if(!src.projectiles && !src.projectiles.len > 1)
			boutput(M, "<span class='notice'>Gun broke. Call 1-800-CODER.</span>")
			set_current_projectile(new/datum/projectile/energy_bolt/aoe)
			item_state = "lawg-detain"
			M.update_inhands()
			update_icon()

		var/text = msg[1]
		text = sanitize_talk(text)
		if (fingerprints_can_shoot(M))
			switch(text)
				if ("detain")
					set_current_projectile(projectiles["detain"])
					item_state = "lawg-detain"
					playsound(M, "sound/vox/detain.ogg", 50)
				if ("execute", "exterminate")
					set_current_projectile(projectiles["execute"])
					current_projectile.cost = 30
					item_state = "lawg-execute"
					playsound(M, "sound/vox/exterminate.ogg", 50)
				if ("smokeshot","fog")
					set_current_projectile(projectiles["smokeshot"])
					current_projectile.cost = 50
					item_state = "lawg-smokeshot"
					playsound(M, "sound/vox/smoke.ogg", 50)
				if ("knockout", "sleepshot")
					set_current_projectile(projectiles["knockout"])
					current_projectile.cost = 60
					item_state = "lawg-knockout"
					playsound(M, "sound/vox/sleep.ogg", 50)
				if ("hotshot","incendiary")
					set_current_projectile(projectiles["hotshot"])
					current_projectile.cost = 60
					item_state = "lawg-hotshot"
					playsound(M, "sound/vox/hot.ogg", 50)
				if ("bigshot","highexplosive","he")
					set_current_projectile(projectiles["bigshot"])
					current_projectile.cost = 170
					item_state = "lawg-bigshot"
					playsound(M, "sound/vox/high.ogg", 50)
					SPAWN_DBG(0.4 SECONDS)
						playsound(M, "sound/vox/explosive.ogg", 50)
				if ("clownshot","clown")
					set_current_projectile(projectiles["clownshot"])
					item_state = "lawg-clownshot"
					playsound(M, "sound/vox/clown.ogg", 30)
				if ("pulse", "push", "throw")
					set_current_projectile(projectiles["pulse"])
					item_state = "lawg-pulse"
					playsound(M, "sound/vox/push.ogg", 50)

					/datum/projectile/energy_bolt/pulse
		else		//if you're not the owner and try to change it, then fuck you
			switch(text)
				if ("detain","execute","knockout","hotshot","incendiary","bigshot","highexplosive","he","clownshot","clown", "pulse", "punch")
					random_burn_damage(M, 50)
					M.changeStatus("weakened", 4 SECONDS)
					elecflash(src,power=2)
					M.visible_message("<span class='alert'>[M] tries to fire [src]! The gun initiates its failsafe mode.</span>")
					return

		M.update_inhands()
		update_icon()

	//Are you really the law? takes the mob as speaker, and the text spoken, sanitizes it. If you say "i am the law" and you in fact are NOT the law, it's gonna blow. Moved out of the switch statement because it that switch is only gonna run if the owner speaks
	proc/are_you_the_law(mob/M as mob, text)
		text = sanitize_talk(text)
		if (findtext(text, "iamthelaw"))
			//you must be holding/wearing the weapon
			//this check makes it so that someone can't stun you, stand on top of you and say "I am the law" to kill you
			if (src in M.contents)
				if (M.job != "Head of Security")
					src.cant_self_remove = 1
					playsound(src.loc, "sound/weapons/armbomb.ogg", 75, 1, -3)
					logTheThing("combat", src, null, "Is not the law. Caused explosion with Lawbringer.")

					SPAWN_DBG(2 SECONDS)
						src.blowthefuckup(15)
					return 0
				else
					return 1

	//all gun modes use the same base sprite icon "lawbringer0" depending on the current projectile/current mode, we apply a coloured overlay to it.
	update_icon()
		..()
		src.icon_state = "[old ? "old-" : ""]lawbringer0"
		src.overlays = null

		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			//if we're showing zero charge, don't do any overlay, since the main image shows an empty gun anyway
			if (ratio == 0)
				return
			indicator_display.icon_state = "[old ? "old-" : ""]lawbringer-d[ratio]"

			if(current_projectile.type == /datum/projectile/energy_bolt/aoe)			//detain - yellow
				indicator_display.color = "#FFFF00"
				muzzle_flash = "muzzle_flash_elec"
			else if (current_projectile.type == /datum/projectile/bullet/pistol_weak)			//execute - cyan
				indicator_display.color = "#00FFFF"
				muzzle_flash = "muzzle_flash"
			else if (current_projectile.type == /datum/projectile/bullet/smoke)			//smokeshot - dark-blue
				indicator_display.color = "#0000FF"
				muzzle_flash = "muzzle_flash"
			else if (current_projectile.type == /datum/projectile/bullet/tranq_dart/law_giver)	//knockout - green
				indicator_display.color = "#008000"
				muzzle_flash = null
			else if (current_projectile.type == /datum/projectile/bullet/flare)			//hotshot - red
				indicator_display.color = "#FF0000"
				muzzle_flash = null
			else if (current_projectile.type == /datum/projectile/bullet/shot_weak)	//bigshot - purple
				indicator_display.color = "#551A8B"
				muzzle_flash = null
			else if (current_projectile.type == /datum/projectile/bullet/clownshot)		//clownshot - pink
				indicator_display.color = "#FFC0CB"
				muzzle_flash = null
			else if (current_projectile.type == /datum/projectile/energy_bolt/pulse)		//clownshot - pink
				indicator_display.color = "#EEEEFF"
				muzzle_flash = "muzzle_flash_bluezap"
			else
				indicator_display.color = "#000000"				//default, should never reach. make it black
			src.overlays += indicator_display

	//just remove all capitalization and non-letter characters
	proc/sanitize_talk(var/msg)
		//find all characters that are not letters and remove em
		var/regex/r = regex("\[^a-z\]+", "g")
		msg = lowertext(msg)
		msg = r.Replace(msg, "")
		return msg

	// Checks if the gun can shoot based on the fingerprints of the shooter.
	//returns true if the prints match or there are no prints stored on the gun(emagged). false if it fails
	proc/fingerprints_can_shoot(var/mob/user)
		if (!owner_prints || (user.bioHolder.uid_hash == owner_prints))
			return 1
		return 0

	shoot(var/target,var/start,var/mob/user)
		if (canshoot())
			//removing this for now so anyone can shoot it. I PROBABLY will want it back, doing this for some light appeasement to see how it goes.
			//shock the guy who tries to use this if they aren't the proper owner. (or if the gun is not emagged)
			// if (!fingerprints_can_shoot(user))
			// 	// shock(user, 70)
			// 	random_burn_damage(user, 50)
			// 	user.changeStatus("weakened", 4 SECONDS)
			// 	var/datum/effects/system/spark_spread/s = new()
			// 	s.set_up(2, 1, (get_turf(src)))
			// 	s.start()
			// 	user.visible_message("<span class='alert'>[user] tries to fire [src]! The gun initiates its failsafe mode.</span>")
			// 	return

			if (current_projectile.type == /datum/projectile/bullet/flare)
				shoot_fire_hotspots(target, start, user)
		return ..(target, start, user)

/obj/item/gun/energy/lawbringer/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (user)
		boutput(user, "<span class='alert'>Anyone can use this gun now. Be careful! (use it in-hand to register your fingerprints)</span>")
		owner_prints = null
	return 0

//stolen from firebreath in powers.dm
/obj/item/gun/energy/lawbringer/proc/shoot_fire_hotspots(var/target,var/start,var/mob/user)
	var/list/affected_turfs = getline(get_turf(start), get_turf(target))
	var/range = 6
	playsound(user.loc, "sound/effects/mag_fireballlaunch.ogg", 50, 0)
	var/turf/currentturf
	var/turf/previousturf
	for(var/turf/F in affected_turfs)
		previousturf = currentturf
		currentturf = F
		if(currentturf.density || istype(currentturf, /turf/space))
			break
		if(previousturf && LinkBlocked(previousturf, currentturf))
			break
		if (F == get_turf(user))
			continue
		if (get_dist(user,F) > range)
			continue
		tfireflash(F,0.5,2400)
*/

// Pulse Rifle //
// An energy gun that uses the lawbringer's Pulse setting, to beef up the current armory.
/*
/obj/item/gun/energy/pulse_rifle
	name = "pulse rifle"
	desc = "A sleek energy rifle with two different pulse settings: Kinetic and Electromagnetic."
	icon_state = "pulse_rifle"
	uses_multiple_icon_states = 1
	item_state = "pulse_rifle"
	force = 5
	two_handed = 1
	can_dual_wield = 0
	muzzle_flash = "muzzle_flash_bluezap"
	cell_type = /obj/item/ammo/power_cell/high_power //300 PU

	New()
		..()
		set_current_projectile(new/datum/projectile/energy_bolt/pulse)//uses 35PU per shot, so 8 shots
		projectiles = list(new/datum/projectile/energy_bolt/pulse, new/datum/projectile/energy_bolt/electromagnetic_pulse)

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "pulse_rifle[ratio]"
			return

*/
///////////////////////////////////////Wasp Gun
/obj/item/gun/energy/wasp
	name = "mini wasp-egg-crossbow"
	desc = "A weapon favored by many of the syndicate's stealth apiarists, which does damage over time using swarms of angry wasps. Utilizes a self-recharging atomic power cell to synthesize more wasp eggs. Somehow."
	icon_state = "crossbow" //placeholder, would prefer a custom wasp themed icon
	w_class = W_CLASS_SMALL
	item_state = "crossbow" //ditto
	force = 4.0
	throw_speed = 3
	throw_range = 10
	rechargeable = 0 // Cannot be recharged manually.
	cell_type = /obj/item/ammo/power_cell/self_charging/slowcharge
	projectiles = null
	is_syndicate = 1
	silenced = 1
	custom_cell_max_capacity = 100

	New()
		set_current_projectile(new/datum/projectile/special/spreader/quadwasp)
		projectiles = list(current_projectile)
		..()
/*
// HOWIZTER GUN
// dumb meme admin item. not remotely fair, will probably kill person firing it.
/obj/item/gun/energy/howitzer
	name = "man-portable plasma howitzer"
	desc = "How can you even lift this?"
	icon_state = "bfg"
	uses_multiple_icon_states = 0
	force = 25
	two_handed = 1
	can_dual_wield = 0
	cell_type = /obj/item/ammo/power_cell/self_charging/howitzer

	New()
		..()
		set_current_projectile(new/datum/projectile/special/howitzer)
		projectiles = list(new/datum/projectile/special/howitzer )

/obj/item/gun/energy/signifer2
	name = "Signifer II"
	desc = "It's a handgun? Or an smg? You can't tell."
	icon_state = "signifer2"
	w_class = W_CLASS_NORMAL		//for clarity
	force = 8
	two_handed = 0
	cell_type = /obj/item/ammo/power_cell/self_charging/ntso_signifer
	can_swap_cell = 0
	var/shotcount = 0

	New()
		set_current_projectile(new/datum/projectile/energy_bolt/signifer_tase)
		projectiles = list(current_projectile,new/datum/projectile/laser/signifer_lethal)
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			if(!src.two_handed)// && current_projectile.type == /datum/projectile/energy_bolt)
				src.icon_state = "signifer_2"
				src.item_state = "signifer_2"
				muzzle_flash = "muzzle_flash_elec"
				shoot_delay = 2
				spread_angle = 0
				force = 9
				w_class = W_CLASS_NORMAL
			else //if (current_projectile.type == /datum/projectile/laser)
				src.item_state = "signifer_2-smg"
				src.icon_state = "signifer_2-smg"
				muzzle_flash = "muzzle_flash_bluezap"
				spread_angle = 3
				shoot_delay = 5
				force = 12
				w_class = W_CLASS_BULKY

	attack_self(var/mob/M)
		if (!src.two_handed)

			if(M.l_hand == src)
				if(M.r_hand != null)
					boutput(M, "<span class='alert'>You need a free hand to switch modes!</span>")
					src.two_handed = 0
					return 0
			else if(M.r_hand == src)
				if(M.l_hand != null)
					boutput(M, "<span class='alert'>You need a free hand to switch modes!</span>")
					src.two_handed = 0
					return 0
		..()

		setTwoHanded(!src.two_handed)
		src.can_dual_wield = !src.two_handed
		update_icon()

		M.update_inhands()

	alter_projectile(obj/projectile/P)
		. = ..()
		if(++shotcount == 2 && istype(P.proj_data, /datum/projectile/laser/signifer_lethal/))
			P.proj_data = new/datum/projectile/laser/signifer_lethal/brute

	shoot()
		shotcount = 0
		. = ..()

/obj/item/gun/energy/tasersmg
	name = "Taser SMG"
	icon_state = "tsmg_burst100"
	desc = "A weapon that produces an cohesive electrical charge that stuns its target, capable of firing in two shot burst or full auto configurations."
	item_state = "tsmg"
	force = 5.0
	two_handed = 1
	can_dual_wield = 0
	cell_type = /obj/item/ammo/power_cell/med_power
	muzzle_flash = "muzzle_flash_elec"

	New()
		set_current_projectile(new/datum/projectile/energy_bolt/smgburst)

		projectiles = list(current_projectile,new/datum/projectile/energy_bolt/smgauto)
		AddComponent(/datum/component/holdertargeting/fullauto, 1.2, 1.2, 1)
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			if(current_projectile.type == /datum/projectile/energy_bolt/smgauto)
				src.icon_state = "tsmg_auto[ratio]"
			else if (current_projectile.type == /datum/projectile/energy_bolt/smgburst)
				src.icon_state = "tsmg_burst[ratio]"


	attack_self(mob/user as mob)
		..()
		if (istype(current_projectile, /datum/projectile/energy_bolt/smgauto))
			spread_angle = 8
		else
			spread_angle = 2
		update_icon()

///////////////////////////////////////Ray Gun
/obj/item/gun/energy/raygun
	name = "Experimental Ray Gun"
	icon_state = "raygun"
	desc = "A weapon that looks vaguely like a cheap toy and is definitely unsafe."
	item_state = "raygun"
	force = 5.0
	can_dual_wield = 0
	muzzle_flash = "muzzle_flash_laser"

	New()
		set_current_projectile(new/datum/projectile/energy_bolt/raybeam)
		projectiles = list(new/datum/projectile/energy_bolt/raybeam)
		..()

	update_icon()
		..()
		return

	shoot(var/target,var/start,var/mob/user) //it's experimental for a reason; use at your own risk!
		if (canshoot())
			if (GET_COOLDOWN(src, "raygun_cooldown"))
				return
			if (prob(30))
				user.TakeDamage("chest", 0, rand(5, 15), 0, DAMAGE_BURN, 1)
				boutput(user, "<span class='alert'>This piece of junk Ray Gun backfired! Ouch!</span>")
				user.do_disorient(stamina_damage = 20, disorient = 3 SECONDS)
				ON_COOLDOWN(src, "raygun_cooldown", 2 SECONDS)
		return ..(target, start, user)
*/
