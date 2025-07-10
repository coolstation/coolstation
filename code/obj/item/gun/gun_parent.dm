var/list/forensic_IDs = new/list() //Global list of all guns, based on bioholder uID stuff

/obj/item/gun
	name = "gun"
	icon = 'icons/obj/items/gun.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	flags =  FPRINT | TABLEPASS | CONDUCT | ONBELT | USEDELAY | EXTRADELAY
	event_handler_flags = USE_GRAB_CHOKE | USE_FLUID_ENTER
	special_grab = /obj/item/grab/gunpoint

	item_state = "gun"
	m_amt = 2000
	force = 10.0
	throwforce = 5
	w_class = W_CLASS_NORMAL
	throw_speed = 4
	throw_range = 6
	contraband = 4
	hide_attack = 2 //Point blanking... gross
	pickup_sfx = "sound/items/pickup_gun.ogg"
	inventory_counter_enabled = 1

	var/suppress_fire_msg = 0

	var/spread_angle = 0
	var/datum/projectile/current_projectile = null
	var/list/projectiles = null
	var/current_projectile_num = 1
	var/silenced = 0
	var/can_dual_wield = 1

	var/slowdown = 0 //Movement delay attack after attack
	var/slowdown_time = 10 //For this long

	var/add_residue = 0 // Does this gun add gunshot residue when fired (Convair880)?

	var/shoot_delay = 4

	var/muzzle_flash = null //set to a different icon state name if you want a different muzzle flash when fired, flash anims located in icons/mob/mob.dmi

	var/fire_animation = FALSE //Used for guns that have animations when firing

	var/recoil = 0 //! current cumulative recoil value, for inaccuracy. leave at 0
	var/recoil_last_shot //! last time this was fired, for recoil purposes
	var/current_anim_recoil = 0 //! current icon rotation, used to make sure the icon resets properly
	var/recoil_stacks = 0 //! current number of shots fired before recoil_reset elapsed.

	// RECOIL SETUP
	var/recoil_enabled = TRUE

	// RECOIL STRENGTH
	// Basic recoil strength, this is how hard the weapon kicks by default
	// recoil_strength is added to recoil every shot, and kicks the camera similarly.
	var/recoil_strength = 9 //! How strong this gun's base recoil impulse is.
	var/recoil_max = 50		//! What's the max cumulative recoil this gun can hit?
	var/recoil_inaccuracy_max = 0 //! at recoil_max, the weapon has this much additional spread

	// Recoil-induced icon tilting. Good for smaller guns. 64x32 icons might look a bit silly with high values.
	// If your gun uses recoil, it's *strongly* recommended to keep this enabled.
	var/icon_recoil_enabled = TRUE //! Should this gun's icon tilt?
	var/icon_recoil_cap = 10 //! At maximum recoil, what angle should the icon state be at?

	// Recoil strength stacking, increases recoil strength as you shoot more
	// Good for making spray & pray kick harder, so just use it on automatic weapons.
	var/recoil_stacking_enabled = FALSE			//! Should this gun gain more recoil strength as it shoots?
	var/recoil_stacking_safe_stacks = 3 //! Ignore this many shots before stacking up (if you want 3-shot bursts not to be penalsied)
	var/recoil_stacking_amount = 1		//! How much should recoil_strength go up by, every shot
	var/recoil_stacking_max_stacks = 3	//! How many times can recoil-stacking_amount apply?

	// RECOIL RESET
	// The following values should be pretty sane for most cases
	// If you really must have 'gun that takes a long time to reset', kick recoil_reset_mult closer to 1
	var/recoil_reset = 6 DECI SECONDS //! how long it takes for recoil to start resetting (6 deci seconds feels nice)
	var/recoil_reset_mult = 0.75 //! multiplier to apply to recoil every .1 seconds (affects high recoil recovery)
	var/recoil_reset_add = 0.2 //! additive reduction to accumulated recoil (affects low recoil recovery better than mult)

	// CAMERA KNOCKING
	// Whenever the gun shoots, it will punt the users' camera back at (recoil_strength + recoil_stacks*recoil_stacking_amount)* pixels per decisecond.
	var/camera_recoil_enabled = TRUE //! Should this gun kickback the camera when fired?
	var/camera_recoil_multiplier = 1 //! Multiply the recoil value by this for camera movement
	var/camera_recoil_sway = TRUE //! If enabled, camera recoil rattles perpendicular to the aim direction too (recommended)
	var/camera_recoil_sway_multiplier = 2 // Multiply the recoil value by this for camera variance (probably fine at 2)
	var/camera_recoil_sway_min = 0 //! Minimum recoil variance
	var/camera_recoil_sway_max = 20 //! Maximum recoil variance


	buildTooltipContent()
		. = ..()
		. += "<br><img style=\"display:inline;margin:0\" src=\"[resource("images/tooltips/ranged.png")]\" width=\"10\" height=\"10\" /> Final Bullet: [src.displayed_power()]"
		lastTooltipContent = .

	New()
		SPAWN_DBG(2 SECONDS)
			src.forensic_ID = src.CreateID()
			forensic_IDs.Add(src.forensic_ID)
		return ..()

/obj/item/gun/proc/displayed_power()
	if(current_projectile)
		return "[floor(current_projectile.power)] dmg - [floor(current_projectile.ks_ratio * 100)]% lethal"
	return "100% power"

///CHECK_LOCK
///Call to run a weaponlock check vs the users implant
///Return 0 for fail
/obj/item/gun/proc/check_lock(var/user as mob)
	return 1

///CHECK_VALID_SHOT
///Call to check and make sure the shot is ok
///Not called much atm might remove, is now inside shoot
/obj/item/gun/proc/check_valid_shot(atom/target as mob|obj|turf|area, mob/user as mob)
	var/turf/T = get_turf(user)
	var/turf/U = get_turf(target)
	if(!istype(T) || !istype(U))
		return 0
	if (U == T)
		//user.bullet_act(current_projectile)
		return 0
	return 1
/*
/obj/item/gun/proc/emag(obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/card/emag))
		boutput(user, "<span class='alert'>No lock to break!</span>")
		return 1
	return 0
*/
/obj/item/gun/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (user)
		boutput(user, "<span class='alert'>No lock to break!</span>")
	return 0

/obj/item/gun/attack_self(mob/user as mob)
	..()
	if(src.projectiles && src.projectiles.len > 1)
		src.current_projectile_num = ((src.current_projectile_num) % src.projectiles.len) + 1
		src.set_current_projectile(src.projectiles[src.current_projectile_num])
		boutput(user, "<span class='notice'>You set the output to [src.current_projectile.sname].</span>")
	return

/obj/item/gun/pixelaction(atom/target, params, mob/user, reach, continuousFire = 0)
	if (reach)
		return 0
	if (!isturf(user.loc))
		return 0

	var/pox = text2num(params["icon-x"]) - 16
	var/poy = text2num(params["icon-y"]) - 16
	var/turf/user_turf = get_turf(user)
	var/turf/target_turf = get_turf(target)

	//if they're holding a gun in each hand... why not shoot both!
	var/is_dual_wield = 0
	if (can_dual_wield)
		if(ishuman(user))
			var/obj/item/gun/G
			if(user.hand && istype(user.r_hand, /obj/item/gun))
				G = user.r_hand
			else if(!user.hand && istype(user.l_hand, /obj/item/gun))
				G = user.l_hand

			if (G && G.can_dual_wield && G.canshoot(user))
				is_dual_wield = 1
				if(!ON_COOLDOWN(G, "shoot_delay", G.shoot_delay))
					SPAWN_DBG(0.2 SECONDS)
						if(!(G in user.equipped_list())) return
						G.Shoot(target_turf,user_turf,user, pox+rand(-2,2), poy+rand(-2,2), is_dual_wield, target)

		else if(ismobcritter(user))
			var/mob/living/critter/M = user
			var/list/obj/item/gun/guns = list()
			for(var/datum/handHolder/H in M.hands)
				if(H.item && H.item != src && istype(H.item, /obj/item/gun) && H.item:can_dual_wield)
					is_dual_wield = 1
					if (H.item:canshoot())
						guns += H.item
						user.next_click = max(user.next_click, world.time + H.item:shoot_delay)
			SPAWN_DBG(0)
				for(var/obj/item/gun/gun in guns)
					if(!ON_COOLDOWN(gun, "shoot_delay", gun.shoot_delay))
						sleep(0.2 SECONDS)
						if(!(gun in user.equipped_list())) return
						gun.Shoot(target_turf,user_turf,user, pox+rand(-2,2), poy+rand(-2,2), is_dual_wield, target)

	if(!ON_COOLDOWN(src, "shoot_delay", src.shoot_delay))
		Shoot(target_turf, user_turf, user, pox, poy, is_dual_wield, target)


	return 1

/obj/item/gun/attack(mob/M as mob, mob/user as mob)
	if (!M || !ismob(M)) //Wire note: Fix for Cannot modify null.lastattacker
		return ..()

	user.lastattacked = M
	M.lastattacker = user
	M.lastattackertime = world.time

	if(user.a_intent != INTENT_HELP && isliving(M))
		if (user.a_intent == INTENT_GRAB)
			attack_particle(user,M)
			return ..()
		src.Shoot(get_turf(M), get_turf(user), user, point_blank_target = M)
	else
		..()
		attack_particle(user,M)

#ifdef DATALOGGER
		game_stats.Increment("violence")
		if(M.mind && M.mind.assigned_role == "Clown")
			game_stats.Increment("clownabuse")
#endif
		return

/obj/item/gun/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	src.add_fingerprint(user)
	if (flag)
		return

/obj/item/gun/proc/alter_projectile(var/obj/projectile/P, var/mob/user)
	return

/obj/item/gun/proc/Shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/point_blank_target = null)
	if(!SEND_SIGNAL(src, COMSIG_GUN_TRY_SHOOT, target, start, user, POX, POY, is_dual_wield, point_blank_target))
		src.shoot(target, start, user, POX, POY, is_dual_wield, point_blank_target)

/obj/item/gun/proc/shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/point_blank_target = null)
	if (isghostdrone(user))
		user.show_text("<span class='combat bold'>Your internal law subroutines kick in and prevent you from using [src]!</span>")
		return FALSE
	if (!canshoot())
		if (ismob(user))
			user.show_text("*click* *click*", "red") // No more attack messages for empty guns (Convair880).
			if (!silenced)
				playsound(user, "sound/weapons/Gunclick.ogg", 60, 1)
		return FALSE
	if (!process_ammo(user))
		return FALSE
	if (!isturf(start))
		return FALSE
	if (!istype(src.current_projectile,/datum/projectile/))
		return FALSE

	if(!isturf(target))
		target = get_turf(target)

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

	src.update_icon()
	return TRUE

/obj/item/gun/proc/canshoot()
	return 0

/obj/item/gun/proc/log_shoot(mob/user, turf/T, obj/projectile/P)
	logTheThing("combat", user, null, "fires \a [src] from [log_loc(user)], vector: ([T.x - user.x], [T.y - user.y]), dir: <I>[dir2text(get_dir(user, T))]</I>, projectile: <I>[P.name]</I>[P.proj_data && P.proj_data.type ? ", [P.proj_data.type]" : null]")

/obj/item/gun/examine()
	if (src.artifact)
		return list("You have no idea what the hell this thing is!")
	return ..()

/obj/item/gun/proc/update_icon()
	return 0


/obj/item/gun/proc/do_camera_recoil(mob/user, turf/start, turf/target, POX, POY)
	// calculate the mob's position relative to the target location
	// this is backwards so that the output angle is the angle we knock the camera back
	var/x_diff = (start.x - target.x) * world.icon_size - POX
	var/y_diff = (start.y - target.y) * world.icon_size - POY

	var/dir = arctan(x_diff, y_diff)
	var/total_strength = src.recoil_strength
	if (recoil_stacking_enabled)
		total_strength += clamp(round(recoil_stacks) - recoil_stacking_safe_stacks,0,recoil_stacking_max_stacks) * recoil_stacking_amount
	var/variance = clamp(total_strength * camera_recoil_sway_multiplier, camera_recoil_sway_min, camera_recoil_sway_max)

	recoil_camera(user, dir, total_strength * camera_recoil_multiplier, variance)


/obj/item/gun/proc/do_icon_recoil()
	if (!icon_recoil_enabled)
		return
	while(src.recoil > 0)
		var/timediff = TIME - recoil_last_shot
		if (timediff >= recoil_reset)
			recoil *= recoil_reset_mult
			recoil -= recoil_reset_add // small linear part to aid with low values
			recoil = clamp(recoil,0, recoil_max)
			recoil_stacks = clamp(round(recoil_stacks) - 0.25, 0, recoil_stacking_max_stacks)

		var/base_icon_recoil = round((recoil/recoil_max)*icon_recoil_cap)
		var/matrix/M = src.transform
		var/jitter = base_icon_recoil/5
		var/jittervalue = rand(-jitter, jitter)
		if (src.recoil < current_anim_recoil || timediff > 0.2 DECI SECONDS) // stop the gun jerking up after you stop shooting
			jittervalue = 0
		var/target_recoil = base_icon_recoil + jittervalue

		var/recoil_diff = (current_anim_recoil - target_recoil)
		current_anim_recoil = target_recoil
		animate(src, transform = matrix(M, recoil_diff, MATRIX_ROTATE | MATRIX_MODIFY), 0.1)
		sleep(0.1 SECONDS)
	recoil_stacks = 0

// vanilla gun recoil. not gunse
/obj/item/gun/proc/handle_recoil(mob/user, turf/start, turf/target, POX, POY, first_shot = TRUE, force_projectile = FALSE)
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

	recoil += (recoil_strength + stacked_recoil)
	recoil = clamp(recoil, 0, recoil_max)
	recoil_last_shot = TIME
	if (camera_recoil_enabled)
		do_camera_recoil(user, start,target,POX,POY)

	if (first_shot && src.current_projectile.shot_number > 1 && src.current_projectile.shot_delay > 0)
		for (var/i=1 to src.current_projectile.shot_number-1)
			spawn(i*src.current_projectile.shot_delay)
				handle_recoil(user,start,target,POX,POY, FALSE)
	if (start_recoil && icon_recoil_enabled)
		spawn(0)
			do_icon_recoil()

/obj/item/gun/proc/process_ammo(var/mob/user)
	boutput(user, "<span class='alert'>*click* *click*</span>")
	if (!src.silenced)
		playsound(user, "sound/weapons/Gunclick.ogg", 60, 1)
	return 0

// Could be useful in certain situations (Convair880).
/obj/item/gun/proc/logme_temp(mob/user as mob, obj/item/gun/G as obj, obj/item/ammo/A as obj)
	if (!user || !G || !A)
		return

	else if (istype(G, /obj/item/gun/kinetic) && istype(A, /obj/item/ammo/bullets))
		logTheThing("combat", user, null, "reloads [G] (<b>Ammo type:</b> <i>[G.current_projectile.type]</i>) at [log_loc(user)].")
		return

	else if (istype(G, /obj/item/gun/energy) && istype(A, /obj/item/ammo/power_cell))
		logTheThing("combat", user, null, "reloads [G] (<b>Cell type:</b> <i>[A.type]</i>) at [log_loc(user)].")
		return

	else return

/obj/item/gun/custom_suicide = 1
/obj/item/gun/suicide(var/mob/living/carbon/human/user as mob)
	if (!src.user_can_suicide(user))
		return 0

	user.visible_message("<span class='alert'><b>[user] places [src] against [his_or_her(user)] head!</b></span>")
	var/dmg = user.get_brute_damage() + user.get_burn_damage()
	var/turf/T = get_turf(user)
	APPLY_MOB_PROPERTY(user, PROP_RANGEDPROT, "gun_suicide", 0.1 - user.get_ranged_protection()) // take 10x damage from projectiles for 1 second
	src.Shoot(T, T, user, point_blank_target = user)
	SPAWN_DBG(1 SECOND)
		if(!QDELETED(user)) // i sincerely hope someone makes this check matter
			REMOVE_MOB_PROPERTY(user, PROP_RANGEDPROT, "gun_suicide")
			var/new_dmg = user.get_brute_damage() + user.get_burn_damage()
			if (new_dmg < (dmg + 30)) // BOOOO!
				user.visible_message("<span class='alert'>[user] hangs [his_or_her(user)] head in shame.</span>")
	return 1

/obj/item/gun/on_spin_emote(var/mob/living/carbon/human/user as mob)
	. = ..(user)
	if ((user.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(50)) || (user.reagents && prob(user.reagents.get_reagent_amount("ethanol") / 2)) || prob(5))
		user.visible_message("<span class='alert'><b>[user] accidentally shoots [him_or_her(user)]self with [src]!</b></span>")
		var/turf/T = get_turf(user)
		src.Shoot(T, T, user, point_blank_target = user)
		JOB_XP(user, "Clown", 3)


///setter for current_projectile so we can have a signal attached. do not set current_projectile on guns without this proc
/obj/item/gun/proc/set_current_projectile(datum/projectile/newProj)
	src.current_projectile = newProj
	SEND_SIGNAL(src, COMSIG_GUN_PROJECTILE_CHANGED, newProj)
