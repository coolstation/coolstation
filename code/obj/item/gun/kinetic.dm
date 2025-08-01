ABSTRACT_TYPE(/obj/item/gun/kinetic)
/obj/item/gun/kinetic
	name = "kinetic weapon"
	icon = 'icons/obj/items/gun.dmi'
	item_state = "gun"
	m_amt = 2000
	var/obj/item/ammo/bullets/ammo = null
	var/max_ammo_capacity = 1 // How much ammo can this gun hold? Don't make this null (Convair880).
	var/caliber = null // Can be a list too. The .357 Mag revolver can also chamber .38 Spc rounds, for instance (Convair880).
	var/has_empty_state = 0 //Does this gun have a special icon state for having no ammo lefT?
	var/gildable = 0 //Can this gun be affected by the [Helios] medal reward?
	var/gilded = FALSE //Is this gun currently gilded by the [Helios] medal reward?
	var/auto_eject = 0 // Do we eject casings on firing, or on reload?
	var/casings_to_eject = 0 // If we don't automatically ejected them, we need to keep track (Convair880).


	add_residue = 1 // Does this gun add gunshot residue when fired? Kinetic guns should (Convair880).

	var/allowReverseReload = 1 //Use gun on ammo to reload
	var/allowDropReload = 1    //Drag&Drop ammo onto gun to reload

	muzzle_flash = "muzzle_flash"

	// caliber list: update as needed
	// 0.22 - pistols
	// 0.308 - rifles
	// 0.357 - revolver
	// 0.38 - detective
	// 0.41 - derringer
	// 0.72 - shotgun shell, 12ga
	// 1.57 - 40mm shell
	// 1.58 - RPG-7 (Tube is 40mm too, though warheads are usually larger in diameter.)

	New()
		if(silenced)
			current_projectile.shot_sound = 'sound/machines/click.ogg'
		..()
		src.update_icon()

	examine()
		. = ..()
		if (src.ammo && (src.ammo.amount_left > 0))
			var/datum/projectile/ammo_type = src.ammo.ammo_type
			. += "There are [src.ammo.amount_left][(ammo_type.material && istype(ammo_type.material, /datum/material/metal/silver)) ? " silver " : " "]bullets of [src.ammo.sname] left!"
		else
			. += "There are 0 bullets left!"
		if (current_projectile)
			. += "Each shot will currently use [src.current_projectile.cost] bullets!"
		else
			. += "<span class='alert'>*ERROR* No output selected!</span>"

	update_icon()
		if (src.ammo)
			inventory_counter.update_number(src.ammo.amount_left)
		else
			inventory_counter.update_text("-")

		if(src.has_empty_state)
			if ((!src.ammo || src.ammo.amount_left < 1) && !findtext(src.icon_state, "-empty")) //sanity check
				src.icon_state = "[src.icon_state]-empty"
			else
				src.icon_state = replacetext(src.icon_state, "-empty", "")
		return 0

	canshoot()
		if(src.ammo && src.current_projectile)
			if(src.ammo:amount_left >= src.current_projectile:cost)
				return 1
		return 0

	process_ammo(var/mob/user)
		if(src.ammo && src.current_projectile)
			if(src.ammo.use(current_projectile.cost))
				return 1
		boutput(user, "<span class='alert'>*click* *click*</span>")
		if (!src.silenced)
			playsound(user, "sound/weapons/Gunclick.ogg", 60, 1)
		return 0

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (istype(O, /obj/item/ammo/bullets) && allowDropReload)
			src.Attackby(O, user)
		return ..()

	attackby(obj/item/ammo/bullets/b as obj, mob/user as mob)
		if(istype(b, /obj/item/ammo/bullets))
			switch (src.ammo.loadammo(b,src))
				if(0)
					user.show_text("You can't reload this gun.", "red")
					return
				if(1)
					user.show_text("This ammo won't fit!", "red")
					return
				if(2)
					user.show_text("There's no ammo left in [b.name].", "red")
					return
				if(3)
					user.show_text("[src] is full!", "red")
					return
				if(4)
					user.visible_message("<span class='alert'>[user] reloads [src].</span>", "<span class='alert'>There wasn't enough ammo left in [b.name] to fully reload [src]. It only has [src.ammo.amount_left] rounds remaining.</span>")
					src.tooltip_rebuild = 1
					src.logme_temp(user, src, b) // Might be useful (Convair880).
					return
				if(5)
					user.visible_message("<span class='alert'>[user] reloads [src].</span>", "<span class='alert'>You fully reload [src] with ammo from [b.name]. There are [b.amount_left] rounds left in [b.name].</span>")
					src.tooltip_rebuild = 1
					src.logme_temp(user, src, b)
					return
				if(6)
					switch (src.ammo.swap(b,src))
						if(0)
							user.show_text("This ammo won't fit!", "red")
							return
						if(1)
							user.visible_message("<span class='alert'>[user] reloads [src].</span>", "<span class='alert'>You swap out the magazine. Or whatever this specific gun uses.</span>")
						if(2)
							user.visible_message("<span class='alert'>[user] reloads [src].</span>", "<span class='alert'>You swap [src]'s ammo with [b.name]. There are [b.amount_left] rounds left in [b.name].</span>")
					src.logme_temp(user, src, b)
					return
		else
			..()

	//attack_self(mob/user as mob)
	//	return

	attack_hand(mob/user as mob)
	// Added this to make manual reloads possible (Convair880).

		if ((src.loc == user) && user.find_in_hand(src)) // Make sure it's not on the belt or in a backpack.
			src.add_fingerprint(user)
			if (src.sanitycheck(0, 1) == 0)
				user.show_text("You can't unload this gun.", "red")
				return
			if (src.ammo.amount_left <= 0)
				// The gun may have been fired; eject casings if so.
				if ((src.casings_to_eject > 0) && src.current_projectile.casing)
					if (src.sanitycheck(1, 0) == 0)
						logTheThing("debug", usr, null, "<b>Convair880</b>: [usr]'s gun ([src]) ran into the casings_to_eject cap, aborting.")
						src.casings_to_eject = 0
						return
					else
						user.show_text("You eject [src.casings_to_eject] casings from [src].", "red")
						src.ejectcasings()
						return
				else
					user.show_text("[src] is empty!", "red")
					return

			// Make a copy here to avoid item teleportation issues.
			var/obj/item/ammo/bullets/ammoHand = new src.ammo.type
			ammoHand.amount_left = src.ammo.amount_left
			ammoHand.name = src.ammo.name
			ammoHand.icon = src.ammo.icon
			ammoHand.icon_state = src.ammo.icon_state
			ammoHand.ammo_type = src.ammo.ammo_type
			ammoHand.delete_on_reload = 1 // No duplicating empty magazines, please (Convair880).
			ammoHand.update_icon()
			user.put_in_hand_or_drop(ammoHand)
			ammoHand.after_unload(user)

			// The gun may have been fired; eject casings if so.
			src.ejectcasings()
			src.casings_to_eject = 0

			src.ammo.amount_left = 0
			src.update_icon()
			src.add_fingerprint(user)
			ammoHand.add_fingerprint(user)

			user.visible_message("<span class='alert'>[user] unloads [src].</span>", "<span class='alert'>You unload [src].</span>")
			//DEBUG_MESSAGE("Unloaded [src]'s ammo manually.")
			return

		return ..()

	attack(mob/M as mob, mob/user as mob)
	// Finished Cogwerks' former WIP system (Convair880).
		if (src.canshoot() && user.a_intent != "help" && user.a_intent != "grab")
			if (src.auto_eject)
				var/turf/T = get_turf(src)
				if(T)
					if (src.current_projectile.casing && (src.sanitycheck(1, 0) == 1))
						var/number_of_casings = max(1, src.current_projectile.shot_number)
						//DEBUG_MESSAGE("Ejected [number_of_casings] casings from [src].")
						for (var/i = 1, i <= number_of_casings, i++)
							var/obj/item/casing/C = new src.current_projectile.casing(T)
							C.forensic_ID = src.forensic_ID
							C.set_loc(T)
			else
				if (src.casings_to_eject < 0)
					src.casings_to_eject = 0
				src.casings_to_eject += src.current_projectile.shot_number
		..()

	shoot(var/target,var/start ,var/mob/user)
		if (src.canshoot())
			if (src.auto_eject)
				var/turf/T = get_turf(src)
				if(T)
					if (src.current_projectile.casing && (src.sanitycheck(1, 0) == 1))
						var/number_of_casings = max(1, src.current_projectile.shot_number)
						//DEBUG_MESSAGE("Ejected [number_of_casings] casings from [src].")
						for (var/i = 1, i <= number_of_casings, i++)
							var/obj/item/casing/C = new src.current_projectile.casing(T)
							C.forensic_ID = src.forensic_ID
							C.set_loc(T)
			else
				if (src.casings_to_eject < 0)
					src.casings_to_eject = 0
				src.casings_to_eject += src.current_projectile.shot_number

		if (fire_animation)
			if(src.ammo?.amount_left > 1)
				flick(icon_state, src)

		..()

	proc/ejectcasings()
		if ((src.casings_to_eject > 0) && src.current_projectile.casing && (src.sanitycheck(1, 0) == 1))
			var/turf/T = get_turf(src)
			if(T)
				//DEBUG_MESSAGE("Ejected [src.casings_to_eject] [src.current_projectile.casing] from [src].")
				var/obj/item/casing/C = null
				while (src.casings_to_eject > 0)
					C = new src.current_projectile.casing(T)
					C.forensic_ID = src.forensic_ID
					C.set_loc(T)
					src.casings_to_eject--
		return

	// Don't set this too high. Absurdly large reloads and item spawning can cause a lot of lag. (Convair880).
	proc/sanitycheck(var/casings = 0, var/ammo = 1)
		if (casings && (src.casings_to_eject > 30 || src.current_projectile.shot_number > 30))
			logTheThing("debug", usr, null, "<b>Convair880</b>: [usr]'s gun ([src]) ran into the casings_to_eject cap, aborting.")
			if (src.casings_to_eject > 0)
				src.casings_to_eject = 0
			return 0
		if (ammo && (src.max_ammo_capacity > 200 || src.ammo.amount_left > 200))
			logTheThing("debug", usr, null, "<b>Convair880</b>: [usr]'s gun ([src]) ran into the magazine cap, aborting.")
			return 0
		return 1

/obj/item/casing
	name = "bullet casing"
	desc = "A spent casing from a bullet of some sort."
	icon = 'icons/obj/items/casings.dmi'
	icon_state = "medium"
	w_class = W_CLASS_TINY
	plane = PLANE_NOSHADOW_BELOW //2023-9-1 - if this breaks layering remove, but IMO bullet casings shouldn't really be casting shadows

	small
		icon_state = "small"
		desc = "Seems to be a small pistol cartridge."
		New()
			..()
			SPAWN_DBG(rand(1, 3))
				playsound(src.loc, "sound/weapons/casings/casing-small-0[rand(1,6)].ogg", 20, 0.1)

	medium
		icon_state = "medium"
		desc = "Seems to be a common revolver cartridge."
		New()
			..()
			SPAWN_DBG(rand(1, 3))
				playsound(src.loc, "sound/weapons/casings/casing-0[rand(1,9)].ogg", 20, 0.1)

	rifle
		icon_state = "rifle"
		desc = "Seems to be a rifle cartridge."
		New()
			..()
			SPAWN_DBG(rand(1, 3))
				playsound(src.loc, "sound/weapons/casings/casing-0[rand(1,9)].ogg", 20, 0.1, 0, 0.8)


	rifle_loud
		icon_state = "rifle"
		desc = "Seems to be a rifle cartridge."
		New()
			..()
			SPAWN_DBG(rand(1, 3))
				playsound(src.loc, "sound/weapons/casings/casing-large-0[rand(1,4)].ogg", 25, 0.1)

	derringer
		icon_state = "medium"
		desc = "A fat and stumpy bullet casing. Looks pretty old."
		New()
			..()
			SPAWN_DBG(rand(1, 3))
				playsound(src.loc, "sound/weapons/casings/casing-0[rand(1,9)].ogg", 20, 0.1)

	deagle
		icon_state = "medium"
		desc = "An uncomfortably large pistol cartridge."
		New()
			..()
			SPAWN_DBG(rand(1, 3))
				playsound(src.loc, "sound/weapons/casings/casing-0[rand(1,9)].ogg", 20, 0.1, 0, 0.9)
	shotgun
		red
			icon_state = "shotgun_red"
			desc = "A red shotgun shell."

		blue
			icon_state = "shotgun_blue"
			desc = "A blue shotgun shell."

		orange
			icon_state = "shotgun_orange"
			desc = "An orange shotgun shell."

		gray
			icon_state = "shotgun_gray"
			desc = "An gray shotgun shell."
		New()
			..()
			SPAWN_DBG(rand(4, 7))
				playsound(src.loc, "sound/weapons/casings/casing-shell-0[rand(1,7)].ogg", 20, 0.1)

	cannon
		icon_state = "rifle"
		desc = "A cannon shell."
		w_class = W_CLASS_SMALL
		New()
			..()
			SPAWN_DBG(rand(2, 4))
				playsound(src.loc, "sound/weapons/casings/casing-large-0[rand(1,4)].ogg", 35, 0.1, 0, 0.8)

	grenade
		w_class = W_CLASS_SMALL
		icon_state = "40mm"
		desc = "A 40mm grenade round casing. Huh."
		New()
			..()
			SPAWN_DBG(rand(3, 6))
				playsound(src.loc, "sound/weapons/casings/casing-xl-0[rand(1,6)].ogg", 15, 0.1)



	New()
		..()
		src.pixel_y += rand(-12,12)
		src.pixel_x += rand(-12,12)
		src.set_dir(pick(alldirs))
		return

/*
/obj/item/gun/kinetic/riot40mm
	desc = "A 40mm riot control launcher."
	name = "Riot launcher"
	icon_state = "40mm"
	item_state = "40mm"
	force = MELEE_DMG_LARGE
	w_class = W_CLASS_BULKY
	contraband = 7
	caliber = 1.57
	max_ammo_capacity = 1
	muzzle_flash = "muzzle_flash_launch"

	New()
		ammo = new/obj/item/ammo/bullets/smoke/single
		set_current_projectile(new/datum/projectile/bullet/smoke)
		..()

	attackby(obj/item/b as obj, mob/user as mob)
		if (istype(b, /obj/item/chem_grenade) || istype(b, /obj/item/old_grenade))
			if(src.ammo.amount_left > 0)
				boutput(user, "<span class='alert'>The [src] already has something in it! You can't use the conversion chamber right now! You'll have to manually unload the [src]!</span>")
				return
			else
				SETUP_GENERIC_ACTIONBAR(user, src, 1 SECOND, PROC_REF(convert_grenade), list(b, user), b.icon, b.icon_state,"", null)
				return
		else
			..()

	proc/convert_grenade(obj/item/nade, mob/user)
		var/obj/item/ammo/bullets/grenade_shell/TO_LOAD = new /obj/item/ammo/bullets/grenade_shell
		TO_LOAD.Attackby(nade, user)
		src.Attackby(TO_LOAD, user)

/obj/item/gun/kinetic/foamdartgun
	name = "Foam Dart Gun"
	icon_state = "foamdartgun"
	desc = "A toy gun that fires foam darts. Keep out of reach of clowns, staff assistants and scientists."
	w_class = W_CLASS_SMALL
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "toygun"
	contraband = 1
	force = 1
	caliber = 0.393
	max_ammo_capacity = 10

	New()
		ammo = new/obj/item/ammo/bullets/foamdarts/ten
		set_current_projectile(new/datum/projectile/bullet/foamdart)
		..()

/obj/item/gun/kinetic/derringer
	name = "derringer"
	desc = "A small and easy-to-hide gun that comes with 2 shots. (Can be hidden in worn clothes and retrieved by using the wink emote)"
	icon_state = "derringer"
	force = MELEE_DMG_PISTOL
	caliber = 0.41
	max_ammo_capacity = 2
	w_class = W_CLASS_SMALL
	muzzle_flash = null

	afterattack(obj/O as obj, mob/user as mob)
		if (O.loc == user && O != src && istype(O, /obj/item/clothing))
			boutput(user, "<span class='hint'>You hide the derringer inside \the [O]. (Use the wink emote while wearing the clothing item to retrieve it.)</span>")
			user.u_equip(src)
			src.set_loc(O)
			src.dropped(user)
		else
			..()
		return

	New()
		ammo = new/obj/item/ammo/bullets/derringer
		set_current_projectile(new/datum/projectile/bullet/derringer)
		..()

/obj/item/gun/kinetic/derringer/empty
	New()
		..()
		ammo.amount_left = 0
		update_icon()
*/
/obj/item/gun/kinetic/dueling_pistol
	name = "dueling pistol"
	desc = "Let's settle this."
	w_class = W_CLASS_NORMAL
	icon_state = "dueling_pistol"
	//color = "#ABBBFF"
	caliber = 6969 //
	contraband = 0 //Beepsky DO NOT INTERFERE

	max_ammo_capacity = 1

	New()
		ammo = new/obj/item/ammo/bullets/dueling
		ammo.amount_left = 0 //Start empty
		set_current_projectile(new/datum/projectile/bullet/dueling)
		..()

	dropped(mob/user) //I can guarantee someone's gonna try and cheat this by dropping the gun before the opponent's bullet can hit them
		ON_COOLDOWN(user, "duel_anticheat", 1.5 SECONDS) //Jokes on you chump
		..()

/obj/item/storage/box/dueling
	name = "dueling pistol case"
	desc = "A very fancy case for those arguments that words cannot resolve."
	icon_state = "dueling_case_thats_a_shitty_edit_of_the_hard_case" //I couldn't be bothered at this point
	slots = 3

	spawn_contents = list(/obj/item/gun/kinetic/dueling_pistol = 2,\
	/obj/item/ammo/bullets/dueling)

/*
/obj/item/gun/kinetic/meowitzer
	name = "\improper Meowitzer"
	desc = "It purrs gently in your hands."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "blaster"

	color = "#ff7b00"
	force = MELEE_DMG_LARGE
	caliber = 20
	max_ammo_capacity = 1
	auto_eject = 0
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	spread_angle = 0
	can_dual_wield = 0
	slowdown = 0
	slowdown_time = 0
	two_handed = 1
	w_class = W_CLASS_BULKY

	New()
		ammo = new/obj/item/ammo/bullets/meowitzer
		set_current_projectile(new/datum/projectile/special/meowitzer)
		..()

	afterattack(atom/A, mob/user as mob)
		if(src.ammo.amount_left < max_ammo_capacity && istype(A, /obj/critter/cat))
			src.ammo.amount_left += 1
			user.visible_message("<span class='alert'>[user] loads \the [A] into \the [src].</span>", "<span class='alert'>You load \the [A] into \the [src].</span>")
			src.current_projectile.icon_state = A.icon_state //match the cat sprite that we load
			qdel(A)
			return
		else
			..()

/obj/item/gun/kinetic/meowitzer/inert
	New()
		..()
		ammo = new/obj/item/ammo/bullets/meowitzer/inert
		set_current_projectile(new/datum/projectile/special/meowitzer/inert)

// Ported from old, non-gun RPG-7 object class (Convair880).
/obj/item/gun/kinetic/rpg7
	desc = "A rocket-propelled grenade launcher licensed by the Space Irish Republican Army."
	name = "MPRT-7"
	icon = 'icons/obj/large/64x32.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "rpg7"
	uses_multiple_icon_states = 1
	item_state = "rpg7"
	wear_image_icon = 'icons/mob/back.dmi'
	flags = ONBACK | FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	w_class = W_CLASS_BULKY
	throw_speed = 2
	throw_range = 4
	force = MELEE_DMG_LARGE
	contraband = 8
	caliber = 1.58
	max_ammo_capacity = 1
	can_dual_wield = 0
	two_handed = 1
	muzzle_flash = "muzzle_flash_launch"
	has_empty_state = 1

	New()
		ammo = new /obj/item/ammo/bullets/rpg
		ammo.amount_left = 0 // Spawn empty.
		set_current_projectile(new /datum/projectile/bullet/rpg)
		..()
		return

	update_icon()
		..()
		if (src.ammo.amount_left < 1)
			src.item_state = "rpg7_empty"
		else
			src.item_state = "rpg7"
		if (ishuman(src.loc))
			var/mob/living/carbon/human/H = src.loc
			H.update_inhands()

	loaded
		New()
			..()
			ammo.amount_left = 1
			src.update_icon()
			return

/obj/item/gun/kinetic/antisingularity
	desc = "An experimental rocket launcher designed to deliver various payloads in rocket format."
	name = "Singularity Buster rocket launcher"
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "ntlauncher"
	item_state = "ntlauncher"
	w_class = W_CLASS_BULKY
	throw_speed = 2
	throw_range = 4
	force = MELEE_DMG_LARGE
	caliber = 1.12 //Based on APILAS
	max_ammo_capacity = 1
	can_dual_wield = 0
	two_handed = 1
	muzzle_flash = "muzzle_flash_launch"

	New()
		ammo = new /obj/item/ammo/bullets/antisingularity
		ammo.amount_left = 0 // Spawn empty.
		set_current_projectile(new /datum/projectile/bullet/antisingularity)
		..()
		return

	setupProperties()
		..()
		setProperty("movespeed", 0.8)

/obj/item/gun/kinetic/minigun
	name = "Minigun"
	desc = "The M134 Minigun is a 7.62×51mm NATO, six-barrel rotary machine gun with a high rate of fire."
	icon_state = "minigun"
	item_state = "heavy"
	force = MELEE_DMG_LARGE
	caliber = 0.31
	max_ammo_capacity = 100
	auto_eject = 1

	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY

	spread_angle = 25
	can_dual_wield = 0

	slowdown = 5
	slowdown_time = 15

	two_handed = 1
	w_class = W_CLASS_BULKY

	New()
		ammo = new/obj/item/ammo/bullets/minigun
		set_current_projectile(new/datum/projectile/bullet/minigun)
		..()

	setupProperties()
		..()
		setProperty("movespeed", 0.4)

/obj/item/gun/kinetic/revolver
	name = "Predator revolver"
	desc = "A hefty combat revolver developed by Cormorant Precision Arms. Uses .357 caliber rounds."
	icon_state = "revolver"
	item_state = "revolver"
	force = MELEE_DMG_REVOLVER
	caliber = list(0.38, 0.357) // Just like in RL (Convair880).
	max_ammo_capacity = 7

	New()
		ammo = new/obj/item/ammo/bullets/a357
		set_current_projectile(new/datum/projectile/bullet/pistol_heavy)
		..()

/obj/item/gun/kinetic/revolver/vr
	icon = 'icons/effects/VR.dmi'

//no, chappie doesn't just get a fancy bespoke non-modular gun's
/obj/item/gun/kinetic/faith
	name = "Faith"
	desc = "'Cause ya gotta have Faith."
	icon_state = "faith"
	force = MELEE_DMG_PISTOL
	caliber = 0.31
	max_ammo_capacity = 4
	auto_eject = 1
	w_class = W_CLASS_SMALL
	muzzle_flash = null
	has_empty_state = 1

	New()
		ammo = new/obj/item/ammo/bullets/bullet_22/faith
		set_current_projectile(new/datum/projectile/bullet/pistol_weak)
		..()

/obj/item/gun/kinetic/detectiverevolver
	name = "Detective Special revolver"
	desc = "A pre-modular revolver which accepts standard NT .31 short rounds."
	icon_state = "detective"
	item_state = "detective"
	w_class = W_CLASS_SMALL
	force = MELEE_DMG_REVOLVER
	caliber = 0.31
	max_ammo_capacity = 7
	gildable = 1

	New()
		ammo = new/obj/item/ammo/bullets/a38/stun
		set_current_projectile(new/datum/projectile/bullet/pistol_weak/stunners)
		..()

/obj/item/gun/kinetic/colt_saa
	name = "fake nerd revolver"
	desc = "A speculative replica of a revolver that could have been built two centuries ago. Hard to believe something so high-tech and illegal could ever have existed."
	icon_state = "colt_saa"
	item_state = "colt_saa"
	w_class = W_CLASS_NORMAL
	force = MELEE_DMG_REVOLVER
	caliber = 0.31
	spread_angle = 1
	max_ammo_capacity = 7
	var/hammer_cocked = 0

	New()
		ammo = null //formerly new/obj/item/ammo/bullets/c_45
		set_current_projectile(new/datum/projectile/bullet/pistol_weak)
		..()

	canshoot()
		if (hammer_cocked)
			return ..()
		else
			return 0
	shoot(var/target,var/start ,var/mob/user)
		..()
		hammer_cocked = 0
		icon_state = "colt_saa"

	attack_self(mob/user as mob)
		..()	//burst shot has a slight spread.
		if (hammer_cocked)
			hammer_cocked = 0
			icon_state = "colt_saa"
			boutput(user, "<span class='notice'>You gently lower the weapon's hammer!</span>")
		else
			hammer_cocked = 1
			icon_state = "colt_saa-c"
			boutput(user, "<span class='alert'>You cock the hammer!</span>")
			playsound(user.loc, "sound/weapons/gun_cocked_colt45.ogg", 70, 1)

/obj/item/gun/kinetic/clock_188
	desc = "What the hell is this thing?"
	name = "weird plastic gun"
	icon_state = "glock"
	item_state = "glock"
	shoot_delay = 2
	w_class = W_CLASS_SMALL
	force = MELEE_DMG_PISTOL
	caliber = 0.31
	max_ammo_capacity = 18
	auto_eject = 1
	has_empty_state = 1
	gildable = 1
	fire_animation = TRUE

	New()
		if (prob(70))
			icon_state = "glocktan"
			item_state = "glocktan"

		if(throw_return)
			ammo = new/obj/item/ammo/bullets/nine_mm_NATO/boomerang
		else
			ammo = null //new/obj/item/ammo/bullets/nine_mm_NATO

		set_current_projectile(new/datum/projectile/bullet/pistol_weak)

		if(throw_return)
			projectiles = list(current_projectile)
		else
			projectiles = list(current_projectile, new/datum/projectile/bullet/pistol_weak)
			AddComponent(/datum/component/holdertargeting/fullauto, 1.2, 1.2, 1)
		..()

	attack_self(mob/user as mob)
		..()	//burst shot has a slight spread.
		if (istype(current_projectile, /datum/projectile/bullet/pistol_weak))
			spread_angle = 10
			shoot_delay = 4
		else
			spread_angle = 0
			shoot_delay = 2

/obj/item/gun/kinetic/clock_188/boomerang
	desc = "No, seriously, what the fuck kind of gun even is this?"
	name = "weirder plastic gun"
	force = MELEE_DMG_PISTOL
	throw_range = 10
	throwforce = 1
	throw_speed = 1
	throw_return = 1
	fire_animation = TRUE
	var/prob_clonk = 0

	throw_begin(atom/target)
		playsound(src.loc, "rustle", 50, 1)
		return ..(target)

	throw_impact(atom/hit_atom)
		if(hit_atom == usr)
			if(prob(prob_clonk))
				var/mob/living/carbon/human/user = usr
				var/turf/T = get_turf(user)
				user.visible_message("<span class='alert'><B>[user] fumbles the catch and accidentally discharges [src]!</B></span>")
				src.Shoot(T, T, user, point_blank_target = user)
				user.force_laydown_standup()
			else
				src.Attackhand(usr)
			return
		else
			var/mob/M = hit_atom
			if(istype(M))
				var/mob/living/carbon/human/user = usr
				if(istype(user.wear_suit, /obj/item/clothing/suit/security_badge))
					src.silenced = 1
					src.Shoot(get_turf(M), get_turf(src), user, point_blank_target = M)
					M.visible_message("<span class='alert'><B>[src] fires, hitting [M] point blank!</B></span>")
					src.silenced = initial(src.silenced)

			prob_clonk = min(prob_clonk + 5, 100)
			SPAWN_DBG(1 SECONDS)
				prob_clonk = max(prob_clonk - 5, 0)

		return ..(hit_atom)


/obj/item/gun/kinetic/spes
	name = "SPES-12"
	desc = "Another speculative replica."
	icon_state = "spas"
	item_state = "spas"
	force = MELEE_DMG_RIFLE
	contraband = 7
	caliber = 0.62
	max_ammo_capacity = 8
	auto_eject = 1
	can_dual_wield = 0

	New()
		if(prob(10))
			name = pick("SPEZZ-12", "SPESS-12", "SPETZ-12", "SPOCK-12", "SCHPATZL-12", "SABRINA-12", "SAURUS-12", "SABER-12", "SOSIG-12", "DINOHUNTER-12", "PISS-12", "ASS-12", "SPES-12", "SHIT-12", "SHOOT-12", "SHOTGUN-12", "FAMILYGUY-12", "SPAGOOTER-12")
		ammo = null //new/obj/item/ammo/bullets/a12
		set_current_projectile(new/datum/projectile/bullet/shot_heavy)
		..()

	custom_suicide = 1
	suicide(var/mob/living/carbon/human/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (!istype(user) || !src.canshoot())//!hasvar(user,"organHolder")) STOP IT STOP IT HOLY SHIT STOP WHY DO YOU USE HASVAR FOR THIS, ONLY HUMANS HAVE ORGANHOLDERS
			return 0

		src.process_ammo(user)
		var/hisher = his_or_her(user)
		user.visible_message("<span class='alert'><b>[user] places [src]'s barrel in [hisher] mouth and pulls the trigger with [hisher] foot!</b></span>")
		var/obj/head = user.organHolder.drop_organ("head")
		qdel(head)
		playsound(src, "sound/weapons/shotgunshot.ogg", 100, 1)
		var/obj/decal/cleanable/tracked_reagents/blood/gibs/gib = make_cleanable( /obj/decal/cleanable/tracked_reagents/blood/gibs,get_turf(user))
		gib.streak_cleanable(turn(user.dir,180))
		health_update_queue |= user
		return 1


/obj/item/gun/kinetic/riotgun
	name = "Riot Shotgun"
	desc = "A real old police-issue shotgun meant for suppressing riots."
	icon = 'icons/obj/large/48x32.dmi'
	icon_state = "shotty-empty"
	item_state = "shotty"
	force = MELEE_DMG_RIFLE
	contraband = 5
	caliber = 0.62
	max_ammo_capacity = 8
	auto_eject = 0
	can_dual_wield = 0
	two_handed = 1
	has_empty_state = 1
	gildable = 1
	var/racked_slide = FALSE



	New()
		ammo = new/obj/item/ammo/bullets/abg
		set_current_projectile(new/datum/projectile/bullet/slug_rubber)
		..()

	update_icon()
		. = ..()
		src.icon_state = "shotty" + (gilded ? "-golden" : "") + (racked_slide ? "" : "-empty" )

	canshoot()
		return(..() && src.racked_slide)

	shoot(var/target,var/start ,var/mob/user)
		if(ammo.amount_left > 0 && !racked_slide)
			boutput(user, "<span class='notice'>You need to rack the slide before you can fire!</span>")
		..()
		src.racked_slide = FALSE
		src.casings_to_eject = 1
		if (src.ammo.amount_left == 0) // change icon_state to empty if 0 shells left
			src.update_icon()
			src.casings_to_eject = 0

	attack_self(mob/user as mob)
		..()
		src.rack(user)

	proc/rack(var/atom/movable/user)
		var/mob/mob_user = null
		if(ismob(user))
			mob_user = user
		if (!src.racked_slide) //Are we racked?
			if (src.ammo.amount_left == 0)
				boutput(mob_user, "<span class ='notice'>You are out of shells!</span>")
				update_icon()
			else
				src.racked_slide = TRUE
				if (src.icon_state == "shotty[src.gilded ? "-golden" : ""]") //"animated" racking
					src.icon_state = "shotty[src.gilded ? "-golden-empty" : "-empty"]" // having update_icon() here breaks
					animate(src, time = 0.2 SECONDS)
					animate(icon_state = "shotty[gilded ? "-golden" : ""]")
				else
					update_icon() // Slide already open? Just close the slide
				boutput(mob_user, "<span class='notice'>You rack the slide of the shotgun!</span>")
				playsound(user.loc, "sound/weapons/shotgunpump.ogg", 50, 1)
				src.casings_to_eject = 0
				if (src.ammo.amount_left < 8) // Do not eject shells if you're racking a full "clip"
					var/turf/T = get_turf(src)
					if (T) // Eject shells on rack instead of on shoot()
						var/obj/item/casing/C = new src.current_projectile.casing(T)
						C.forensic_ID = src.forensic_ID
						C.set_loc(T)


/obj/item/gun/kinetic/ak47
	name = "Soviet AK-58 Rifle"
	desc = "A rare Frontier-side example of Soviet prototype guns from a century ago, before the invention of zaubertubes."
	icon = 'icons/obj/large/48x32.dmi' // big guns get big icons
	icon_state = "ak47"
	item_state = "ak47"
	force = MELEE_DMG_RIFLE
	contraband = 8
	caliber = 0.31
	max_ammo_capacity = 30 // It's magazine-fed (Convair880).
	auto_eject = 1
	can_dual_wield = 0
	two_handed = 1
	gildable = 1

	New()
		ammo = new/obj/item/ammo/bullets/ak47
		set_current_projectile(new/datum/projectile/bullet/rifle_medium)
		..()

/obj/item/gun/kinetic/hunting_rifle
	name = "Old Hunting Rifle"
	desc = "A powerful antique hunting rifle."
	icon = 'icons/obj/large/48x32.dmi'
	icon_state = "ohr"
	item_state = "ohr"
	force = MELEE_DMG_RIFLE
	contraband = 8
	caliber = 0.31
	max_ammo_capacity = 4 // It's magazine-fed (Convair880).
	auto_eject = 1
	can_dual_wield = 0
	two_handed = 1
	has_empty_state = 1
	gildable = 1

	New()
		ammo = new/obj/item/ammo/bullets/rifle_3006
		set_current_projectile(new/datum/projectile/bullet/rifle_heavy)
		..()

/obj/item/gun/kinetic/dart_rifle
	name = "Tranquilizer Rifle"
	desc = "A veterinary tranquilizer rifle chambered in .308 caliber."
	icon = 'icons/obj/large/48x32.dmi'
	icon_state = "tranq"
	item_state = "tranq"
	force = MELEE_DMG_RIFLE
	//contraband = 8
	caliber = 0.31
	max_ammo_capacity = 4 // It's magazine-fed (Convair880).
	auto_eject = 1
	can_dual_wield = 0
	two_handed = 1
	gildable = 1

	New()
		ammo = new/obj/item/ammo/bullets/tranq_darts
		set_current_projectile(new/datum/projectile/bullet/tranq_dart)
		..()

/obj/item/gun/kinetic/zipgun
	name = "Zip Gun"
	desc = "An improvised and unreliable gun."
	icon_state = "zipgun"
	force = MELEE_DMG_PISTOL
	contraband = 6
	caliber = null // use any ammo at all BA HA HA HA HA
	max_ammo_capacity = 2
	var/failure_chance = 6
	var/failured = 0

	New()

		ammo = new/obj/item/ammo/bullets/bullet_22
		ammo.amount_left = 0 // start empty
		set_current_projectile(new/datum/projectile/bullet/pistol_weak)
		..()


	shoot(var/target,var/start ,var/mob/user)
		if(failured)
			var/turf/T = get_turf(src)
			explosion(src, T,-1,-1,1,2)
			qdel(src)
			return
		if(ammo?.amount_left && current_projectile?.caliber && current_projectile.power)
			failure_chance = max(0,min(33,round(current_projectile.power/2 - 9)))
		if(canshoot() && prob(failure_chance)) // Empty zip guns had a chance of blowing up. Stupid (Convair880).
			failured = 1
			if(prob(failure_chance))	// Sometimes the failure is obvious
				playsound(src.loc, "sound/impact_sounds/Metal_Hit_Heavy_1.ogg", 50, 1)
				boutput(user, "<span class='alert'>The [src]'s shodilly thrown-together [pick("breech", "barrel", "bullet holder", "firing pin", "striker", "staple-driver mechanism", "bendy metal part", "shooty-bit")][pick("", "...thing")] [pick("cracks", "pops off", "bends nearly in half", "comes loose")]!</span>")
			else						// Other times, less obvious
				playsound(src.loc, "sound/impact_sounds/Generic_Snap_1.ogg", 50, 1)
		..()
		return

/obj/item/gun/kinetic/silenced_22
	name = "Orion silenced pistol"
	desc = "A small pistol with an integrated flash and noise suppressor, developed by Specter Tactical Laboratory. Uses .22 rounds."
	icon_state = "silenced"
	w_class = W_CLASS_SMALL
	silenced = 1
	force = MELEE_DMG_PISTOL
	contraband = 4
	caliber = 0.31
	max_ammo_capacity = 10
	auto_eject = 1
	hide_attack = 1
	muzzle_flash = null
	has_empty_state = 1
	fire_animation = TRUE

	New()
		ammo = new/obj/item/ammo/bullets/bullet_22HP
		set_current_projectile(new/datum/projectile/bullet/pistol_weak/HP)
		..()

/obj/item/gun/kinetic/vgun
	name = "Virtual Pistol"
	desc = "This thing would be better if it wasn't such a piece of shit."
	icon_state = "railgun"
	force = MELEE_DMG_PISTOL
	contraband = 0
	max_ammo_capacity = 200

	New()
		ammo = new/obj/item/ammo/bullets/vbullet
		set_current_projectile(new/datum/projectile/bullet/vbullet)
		..()

	shoot(var/target,var/start ,var/mob/user)
		var/turf/T = get_turf(src)

		if (!istype(T.loc, /area/sim))
			boutput(user, "<span class='alert'>You can't use the guns outside of the combat simulation, fuckhead!</span>")
			return
		else
			..()

/obj/item/gun/kinetic/flaregun
	desc = "A 12-gauge flaregun."
	name = "Flare Gun"
	icon_state = "flare"
	item_state = "flaregun"
	force = MELEE_DMG_PISTOL
	contraband = 2
	caliber = 0.62
	max_ammo_capacity = 1
	has_empty_state = 1

	New()
		ammo = new/obj/item/ammo/bullets/flare/single
		set_current_projectile(new/datum/projectile/bullet/flare)
		..()


/obj/item/gun/kinetic/coilgun_TEST
	name = "coil gun"
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "coilgun_2"
	item_state = "flaregun"
	force = MELEE_DMG_RIFLE
	contraband = 6
	caliber = 1.0
	max_ammo_capacity = 2

	New()
		ammo = new/obj/item/ammo/bullets/rod
		set_current_projectile(new/datum/projectile/bullet/rod)
		..()

/obj/item/gun/kinetic/airzooka //This is technically kinetic? I guess?
	name = "Airzooka"
	desc = "The new double action air projection device from Donk Co!"
	icon_state = "airzooka"
	force = MELEE_DMG_PISTOL
	max_ammo_capacity = 10
	caliber = 4.6 // I rolled a dice
	muzzle_flash = "muzzle_flash_launch"

	New()
		ammo = new/obj/item/ammo/bullets/airzooka
		set_current_projectile(new/datum/projectile/bullet/airzooka)
		..()

/obj/item/gun/kinetic/smg_old //testing keelin's continuous fire POC
	name = "submachine gun"
	desc = "An automatic submachine gun"
	icon_state = "walthery1"
	w_class = W_CLASS_SMALL
	force = MELEE_DMG_SMG
	contraband = 4
	caliber = 0.31
	max_ammo_capacity = 30
	auto_eject = 1

	continuous = 1
	c_interval = 1.1

	New()
		ammo = new/obj/item/ammo/bullets/bullet_9mm/smg
		set_current_projectile(new/datum/projectile/bullet/pistol_weak)
		..()

//  <([['v') - Gannets Nuke Ops Class Guns - ('u']])>  //

// agent
/obj/item/gun/kinetic/pistol
	name = "Branwen pistol"
	desc = "A semi-automatic, 9mm caliber service pistol, developed by Mabinogi Firearms Company."
	icon_state = "9mm_pistol"
	w_class = W_CLASS_NORMAL
	force = MELEE_DMG_PISTOL
	contraband = 4
	caliber = 0.31
	max_ammo_capacity = 15
	auto_eject = 1
	has_empty_state = 1
	fire_animation = TRUE

	New()
		ammo = new/obj/item/ammo/bullets/bullet_9mm
		set_current_projectile(new/datum/projectile/bullet/pistol_weak)
		..()

/obj/item/gun/kinetic/pistol/empty

	New()
		..()
		ammo.amount_left = 0
		update_icon()

/obj/item/gun/kinetic/pistol/smart/mkII
	name = "\improper Hydra smart pistol"
	desc = "A pistol capable of locking onto multiple targets and firing on them in rapid sequence. \"Anderson Para-Munitions\" is engraved on the slide."
	icon_state = "smartgun"
	max_ammo_capacity = 24

	New()
		..()
		ammo = new/obj/item/ammo/bullets/bullet_9mm/smartgun
		set_current_projectile(new/datum/projectile/bullet/pistol_weak)
		AddComponent(/datum/component/holdertargeting/smartgun/nukeop, 3)


/datum/component/holdertargeting/smartgun/nukeop/is_valid_target(mob/user, mob/M)
	return ..() && !istype(M.get_id(), /obj/item/card/id/syndicate)

/obj/item/gun/kinetic/smg
	name = "Bellatrix submachine gun"
	desc = "A semi-automatic, 9mm submachine gun, developed by Almagest Weapons Fabrication."
	icon = 'icons/obj/large/48x32.dmi'
	icon_state = "mp52"
	w_class = W_CLASS_SMALL
	force = MELEE_DMG_SMG
	contraband = 4
	caliber = 0.31
	max_ammo_capacity = 30
	auto_eject = 1
	spread_angle = 12.5
	has_empty_state = 1

	New()
		ammo = new/obj/item/ammo/bullets/bullet_9mm/smg
		set_current_projectile(new/datum/projectile/bullet/pistol_weak)
		..()

/obj/item/gun/kinetic/smg/empty

	New()
		..()
		ammo.amount_left = 0
		update_icon()

/obj/item/gun/kinetic/tranq_pistol
	name = "Gwydion tranquilizer pistol"
	desc = "A silenced 9mm tranquilizer pistol, developed by Mabinogi Firearms Company."
	icon_state = "tranq_pistol"
	item_state = "tranq_pistol"
	w_class = W_CLASS_SMALL
	force = MELEE_DMG_PISTOL
	contraband = 4
	caliber = 0.31
	max_ammo_capacity = 15
	auto_eject = 1
	hide_attack = 1
	muzzle_flash = null

	New()
		ammo = new/obj/item/ammo/bullets/tranq_darts/syndicate/pistol
		set_current_projectile(new/datum/projectile/bullet/tranq_dart/syndicate/pistol)
		..()

// scout
/obj/item/gun/kinetic/tactical_shotgun //just a reskin, unused currently
	name = "tactical shotgun"
	desc = "Multi-purpose high-grade military shotgun, painted a menacing black colour."
	icon_state = "tactical_shotgun"
	item_state = "shotgun"
	force = MELEE_DMG_RIFLE
	contraband = 7
	caliber = 0.62
	max_ammo_capacity = 8
	auto_eject = 1
	two_handed = 1
	can_dual_wield = 0

	New()
		ammo = new/obj/item/ammo/bullets/buckshot_burst
		set_current_projectile(new/datum/projectile/special/spreader/buckshot_burst/)
		..()

// assault
/obj/item/gun/kinetic/assault_rifle
	name = "Sirius assault rifle"
	desc = "A bullpup assault rifle capable of semi-automatic and burst fire modes, developed by Almagest Weapons Fabrication."
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "assault_rifle"
	item_state = "assault_rifle"
	force = MELEE_DMG_RIFLE
	contraband = 8
	caliber = 0.31
	max_ammo_capacity = 30
	auto_eject = 1
	object_flags = NO_ARM_ATTACH

	two_handed = 1
	can_dual_wield = 0
	spread_angle = 0

	New()
		ammo = new/obj/item/ammo/bullets/assault_rifle
		set_current_projectile(new/datum/projectile/bullet/rifle_weak)
		projectiles = list(current_projectile,new/datum/projectile/bullet/rifle_weak)
		..()

	attackby(obj/item/ammo/bullets/b, mob/user)  // has to account for whether regular or armor-piercing ammo is loaded AND which firing mode it's using
		var/obj/previous_ammo = ammo
		var/mode_was_burst = (istype(current_projectile, /datum/projectile/bullet/rifle_weak/))  // was previous mode burst fire?
		..()
		if(previous_ammo.type != ammo.type)  // we switched ammo types
			if(istype(ammo, /obj/item/ammo/bullets/assault_rifle/armor_piercing)) // we switched from normal to armor_piercing
				if(mode_was_burst) // we were in burst shot mode
					set_current_projectile(new/datum/projectile/bullet/rifle_medium/AP)
					projectiles = list(new/datum/projectile/bullet/rifle_medium/AP, current_projectile)
				else // we were in single shot mode
					set_current_projectile(new/datum/projectile/bullet/rifle_medium/AP)
					projectiles = list(current_projectile, new/datum/projectile/bullet/rifle_medium/AP)
			else // we switched from armor penetrating ammo to normal
				if(mode_was_burst) // we were in burst shot mode
					set_current_projectile(new/datum/projectile/bullet/rifle_medium)
					projectiles = list(new/datum/projectile/bullet/rifle_medium, current_projectile)
				else // we were in single shot mode
					set_current_projectile(new/datum/projectile/bullet/rifle_medium)
					projectiles = list(current_projectile, new/datum/projectile/bullet/rifle_medium)

	attack_self(mob/user as mob)
		..()	//burst shot has a slight spread.
		if (istype(current_projectile, /datum/projectile/bullet/rifle_medium/))
			spread_angle = 12.5
			shoot_delay = 4 DECI SECONDS
		else
			spread_angle = 0
			shoot_delay = 3 DECI SECONDS



// heavy
/obj/item/gun/kinetic/light_machine_gun
	name = "Antares light machine gun"
	desc = "A 100 round light machine gun, developed by Almagest Weapons Fabrication."
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "lmg"
	item_state = "lmg"
	wear_image_icon = 'icons/mob/back.dmi'
	force = MELEE_DMG_RIFLE
	caliber = 0.31
	max_ammo_capacity = 100
	auto_eject = 0

	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY | ONBACK
	object_flags = NO_ARM_ATTACH
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD

	spread_angle = 8
	can_dual_wield = 0

	two_handed = 1
	w_class = W_CLASS_BULKY

	New()
		ammo = new/obj/item/ammo/bullets/lmg
		set_current_projectile(new/datum/projectile/bullet/lmg)
		projectiles = list(current_projectile, new/datum/projectile/bullet/lmg/auto)
		AddComponent(/datum/component/holdertargeting/fullauto, 1.5 DECI SECONDS, 1.5 DECI SECONDS, 1)
		..()

	setupProperties()
		..()
		setProperty("movespeed", 1)


/obj/item/gun/kinetic/cannon
	name = "M20-CV tactical cannon"
	desc = "A shortened conversion of a 20mm military cannon. Slow but enormously powerful."
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "cannon"
	item_state = "cannon"
	wear_image_icon = 'icons/mob/back.dmi'
	force = MELEE_DMG_LARGE
	caliber = 0.787
	max_ammo_capacity = 1
	auto_eject = 1

	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY | ONBACK
	object_flags = NO_ARM_ATTACH
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD

	can_dual_wield = 0

	slowdown = 10
	slowdown_time = 15

	two_handed = 1
	w_class = W_CLASS_BULKY
	muzzle_flash = "muzzle_flash_launch"


	New()
		ammo = new/obj/item/ammo/bullets/cannon/single
		set_current_projectile(new/datum/projectile/bullet/cannon)
		..()

	setupProperties()
		..()
		setProperty("movespeed", 0.3)



// demo
/obj/item/gun/kinetic/grenade_launcher
	name = "Rigil grenade launcher"
	desc = "A 40mm hand-held grenade launcher, developed by Almagest Weapons Fabrication."
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "grenade_launcher"
	item_state = "grenade_launcher"
	force = MELEE_DMG_RIFLE
	contraband = 7
	caliber = 1.57
	max_ammo_capacity = 4 // to fuss with if i want 6 packs of ammo
	two_handed = 1
	can_dual_wield = 0
	object_flags = NO_ARM_ATTACH
	auto_eject = 1

	New()
		ammo = new/obj/item/ammo/bullets/grenade_round/explosive
		ammo.amount_left = max_ammo_capacity
		set_current_projectile(new/datum/projectile/bullet/grenade_round/explosive)
		..()
	attackby(obj/item/b as obj, mob/user as mob)
		if (istype(b, /obj/item/chem_grenade) || istype(b, /obj/item/old_grenade))
			if((src.ammo.amount_left > 0 && !istype(current_projectile, /datum/projectile/bullet/grenade_shell)) || src.ammo.amount_left >= src.max_ammo_capacity)
				boutput(user, "<span class='alert'>The [src] already has something in it! You can't use the conversion chamber right now! You'll have to manually unload the [src]!</span>")
				return
			else
				var/datum/projectile/bullet/grenade_shell/custom_shell = src.current_projectile
				if(src.ammo.amount_left > 0 && istype(custom_shell) && custom_shell.get_nade().type != b.type)
					boutput(user, "<span class='alert'>The [src] has a different kind of grenade in the conversion chamber, and refuses to mix and match!</span>")
					return
				else
					SETUP_GENERIC_ACTIONBAR(user, src, 0.3 SECONDS, PROC_REF(convert_grenade), list(b, user), b.icon, b.icon_state,"", null)
					return
		else
			..()

	proc/convert_grenade(obj/item/nade, mob/user)
		var/obj/item/ammo/bullets/grenade_shell/TO_LOAD = new /obj/item/ammo/bullets/grenade_shell/rigil
		TO_LOAD.Attackby(nade, user)
		src.Attackby(TO_LOAD, user)

// slamgun
/obj/item/gun/kinetic/slamgun
	// perhaps refactor later to allow for easy creation of 'manual extract weapons'?
	// would allow easy implementation of other weps such as weldrods
	name = "slamgun"
	desc = "A 12 gauge shotgun. Apparently. It's just two pipes stacked together."
	icon = 'icons/obj/unused/slamgun.dmi'
	icon_state = "slamgun-ready"
	inhand_image_icon = 'icons/obj/unused/slamgun.dmi'
	item_state = "slamgun-ready-world"
	force = MELEE_DMG_RIFLE
	caliber = 0.62
	max_ammo_capacity = 1
	auto_eject = 0
	spread_angle = 10 // sorry, no sniping with slamguns

	can_dual_wield = 0
	two_handed = 1
	w_class = W_CLASS_BULKY
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY

	New()
		set_current_projectile(new/datum/projectile/bullet/nails)
		ammo = new /obj/item/ammo/bullets/a12
		ammo.amount_left = 0 // Spawn empty.
		..()

	attack_self(mob/user as mob)
		if (src.icon_state == "slamgun-ready")
			w_class = W_CLASS_NORMAL
			if (src.ammo.amount_left > 0 || src.casings_to_eject > 0)
				src.icon_state = "slamgun-open-loaded"
			else
				src.icon_state = "slamgun-open"
			update_icon()
			two_handed = 0
			user.updateTwoHanded(src, 0)
			user.update_inhands()
		else
			w_class = W_CLASS_BULKY
			src.icon_state = "slamgun-ready"
			update_icon()
			two_handed = 1
			user.updateTwoHanded(src, 1)
			user.update_inhands()
		..()

	canshoot()
		if (src.icon_state == "slamgun-ready")
			return ..()
		else
			return 0

	attack_hand(mob/user as mob)
		if ((src.loc == user) && user.find_in_hand(src))
			return // Not unloading like that.
		..()

	update_icon()
		if(src.icon_state == "slamgun-ready")
			src.item_state = "slamgun-ready-world"
		else
			src.item_state = "slamgun-open-world"
			if (src.ammo.amount_left > 0 || src.casings_to_eject > 0)
				src.icon_state = "slamgun-open-loaded"
			else
				src.icon_state = "slamgun-open"

		..()

	MouseDrop(atom/over_object, src_location, over_location, params)
		if (usr.stat || usr.restrained() || !can_reach(usr, src) || usr.getStatusDuration("paralysis") || usr.sleeping || usr.lying || isAIeye(usr) || isAI(usr) || isghostcritter(usr))
			return ..()
		if (over_object == usr && src.icon_state == "slamgun-open-loaded") // sorry for doing it like this, but i have no idea how to do it cleaner.
			src.add_fingerprint(usr)
			if (src.sanitycheck(0, 1) == 0)
				usr.show_text("You can't unload this gun.", "red")
				return
			if (src.ammo.amount_left <= 0)
				if ((src.casings_to_eject > 0))
					if (src.sanitycheck(1, 0) == 0)
						src.casings_to_eject = 0
						return
					else
						usr.show_text("You eject [src.casings_to_eject] casings from [src].", "red")
						src.ejectcasings()
						src.casings_to_eject = 0 // needed for bullets that don't have casings (???)
						src.update_icon()
						return
				else
					usr.show_text("[src] is empty!", "red")
					return

			// Make a copy here to avoid item teleportation issues.
			var/obj/item/ammo/bullets/ammoHand = new src.ammo.type
			ammoHand.amount_left = src.ammo.amount_left
			ammoHand.name = src.ammo.name
			ammoHand.icon = src.ammo.icon
			ammoHand.icon_state = src.ammo.icon_state
			ammoHand.ammo_type = src.ammo.ammo_type
			ammoHand.delete_on_reload = 1 // No duplicating empty magazines, please (Convair880).
			ammoHand.update_icon()
			usr.put_in_hand_or_drop(ammoHand)

			// The gun may have been fired; eject casings if so.
			src.ejectcasings()
			src.casings_to_eject = 0

			src.ammo.amount_left = 0
			src.update_icon()

			src.add_fingerprint(usr)
			ammoHand.add_fingerprint(usr)

			usr.visible_message("<span class='alert'>[usr] unloads [src].</span>", "<span class='alert'>You unload [src].</span>")
			return
		..()

	attackby(obj/item/b as obj, mob/user as mob)
		if (istype(b, /obj/item/ammo/bullets) && src.icon_state == "slamgun-ready")
			boutput(user, "<span class='alert'>You can't shove shells down the barrel! You'll have to open the [src]!</span>")
			return
		if (istype(b, /obj/item/ammo/bullets) && (src.ammo.amount_left > 0 || src.casings_to_eject > 0))
			boutput(user, "<span class='alert'>The [src] already has a shell inside! You'll have to unload the [src]!</span>")
			return
		..()

// sniper
/obj/item/gun/kinetic/sniper
	name = "Betelgeuse sniper rifle"
	desc = "A semi-automatic bullpup sniper rifle, developed by Almagest Weapons Fabrication."
	icon = 'icons/obj/large/64x32.dmi' // big guns get big icons
	icon_state = "sniper"
	item_state = "sniper"
	wear_image_icon = 'icons/mob/back.dmi'
	force = MELEE_DMG_RIFLE
	caliber = 0.31
	max_ammo_capacity = 4
	auto_eject = 1
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY | ONBACK
	object_flags = NO_ARM_ATTACH
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD
	slowdown = 7
	slowdown_time = 5

	can_dual_wield = 0
	two_handed = 1
	w_class = W_CLASS_BULKY

	shoot_delay = 1 SECOND

	New()
		set_current_projectile(new/datum/projectile/bullet/rifle_heavy)
		AddComponent(/datum/component/holdertargeting/sniper_scope, 12, 3200, /datum/overlayComposition/sniper_scope_old, 'sound/weapons/scope.ogg')
		..()

	setupProperties()
		..()
		setProperty("movespeed", 0.8)

// WIP //////////////////////////////////
/obj/item/gun/kinetic/sniper/antimateriel
	name = "M20-S antimateriel cannon"
	desc = "A ruthlessly powerful rifle chambered for a 20mm cannon round. Built to destroy vehicles and infrastructure at range."
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "antimateriel"
	item_state = "cannon"
	wear_image_icon = 'icons/mob/back.dmi'
	force = 10
	caliber = 0.787
	max_ammo_capacity = 5
	auto_eject = 1

	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY | ONBACK
	object_flags = NO_ARM_ATTACH
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD

	can_dual_wield = 0

	slowdown = 5
	slowdown_time = 10

	two_handed = 1
	w_class = W_CLASS_BULKY
	muzzle_flash = "muzzle_flash_launch"


	New()
		ammo = new/obj/item/ammo/bullets/cannon
		set_current_projectile(new/datum/projectile/bullet/cannon)
		AddComponent(/datum/component/holdertargeting/sniper_scope, 12, 0, /datum/overlayComposition/sniper_scope, 'sound/weapons/scope.ogg')
		..()


	setupProperties()
		..()
		setProperty("movespeed", 0.3)

/obj/item/gun/kinetic/flintlockpistol
	name = "flintlock pistol"
	desc = "A powerful antique flintlock pistol."
	icon_state = "flintlock"
	item_state = "flintlock"
	force = MELEE_DMG_PISTOL
	contraband = 0 //It's so old that futuristic security scanners don't even recognize it.
	caliber = 0.58
	max_ammo_capacity = 1 // It's magazine-fed (Convair880).
	auto_eject = null
	var/failure_chance = 1

	New()
		ammo = new/obj/item/ammo/bullets/flintlock
		set_current_projectile(new/datum/projectile/bullet/flintlock)
		..()

	shoot()
		if(ammo?.amount_left && current_projectile?.caliber && current_projectile.power)
			failure_chance = max(10,min(33,round(current_projectile.caliber * (current_projectile.power/2))))
		if(canshoot() && prob(failure_chance))
			var/turf/T = get_turf(src)
			boutput(T, "<span class='alert'>[src] blows up!</span>")
			explosion(src, T,0,1,1,2)
			qdel(src)
		else
			..()
			return


/obj/item/gun/kinetic/gungun //meesa jarjar binks
	name = "Gun"
	desc = "A gun that shoots... something. It looks like a modified grenade launcher."
	icon_state = "gungun"
	item_state = "gungun"
	w_class = W_CLASS_NORMAL
	caliber = 3//fuck if i know lol, derringers are about 3 inches in size so ill just set this to 3
	max_ammo_capacity = 6 //6 guns
	force = MELEE_DMG_SMG
	New()
		ammo = new /obj/item/ammo/bullets/gun
		ammo.amount_left = 6 //spawn full please
		set_current_projectile(new /datum/projectile/special/spawner/gun)
		..()

/obj/item/gun/kinetic/SMG_briefcase
	name = "secure briefcase"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "secure"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "sec-case"
	desc = "A large briefcase with a digital locking system. This one has a small hole in the side of it. Odd."
	force = MELEE_DMG_SMG
	caliber = 0.31
	max_ammo_capacity = 30
	auto_eject = 0

	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	object_flags = NO_ARM_ATTACH
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD

	spread_angle = 2
	can_dual_wield = 0
	var/cases_to_eject = 0
	var/open = FALSE


	New()
		ammo = new/obj/item/ammo/bullets/nine_mm_NATO
		set_current_projectile(new/datum/projectile/bullet/pistol_weak)
		..()

	attack_hand(mob/user as mob)
		if(!user.find_in_hand(src))
			..() //this works, dont touch it
		else if(open)
			.=..()
		else
			boutput(user, "<span class='alert'>You can't unload the [src] while it is closed.</span>")

	attackby(obj/item/ammo/bullets/b as obj, mob/user)
		if(open)
			.=..()
		else
			boutput(user, "<span class='alert'>You can't access the gun inside the [src] while it's closed! You'll have to open the [src]!</span>")

	attack_self(mob/user)
		if(open)
			open = FALSE
			update_icon()
			boutput(user, "<span class='alert'>You close the [src]!</span>")
		else
			boutput(user, "<span class='alert'>You open the [src].</span>")
			open = TRUE
			update_icon()
			if (src.loc == user && user.find_in_hand(src)) // Make sure it's not on the belt or in a backpack.
				src.add_fingerprint(user)
				if (!src.sanitycheck(0, 1))
					user.show_text("You can't unload this gun.", "red")
					return
				if (src.casings_to_eject > 0 && src.current_projectile.casing)
					if (!src.sanitycheck(1, 0))
						logTheThing("debug", user, null, "<b>Convair880</b>: [user]'s gun ([src]) ran into the casings_to_eject cap, aborting.")
						src.casings_to_eject = 0
						return
					else
						user.show_text("You eject [src.casings_to_eject] casings from [src].", "red")
						src.ejectcasings()
						return
				else
					user.show_text("[src] is empty!", "red")
					return

	canshoot()
		if(open)
			return 0
		else
			. = ..()

	update_icon()
		if(open)
			icon_state="guncase"
		else
			icon_state="secure"
*/
