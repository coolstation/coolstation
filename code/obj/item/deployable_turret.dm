/////////////////////////////
//      Deployer Code      //
/////////////////////////////

ABSTRACT_TYPE(/obj/item/turret_deployer)
/obj/item/turret_deployer
	name = "fucked up turret deployer that you shouldn't see"
	desc = "this isn't going to spawn anything and will also probably yell errors at you"
	icon = 'icons/obj/deployableturret.dmi'
	force = 3
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_NORMAL
	var/damage_words = "mostly undamaged!"
	var/icon_tag = null
	var/quick_deploy_fuel = 0
	var/associated_turret = null //what kind of turret should this spawn?

	New(newLoc, forensics_id)
		..()
		icon_state = "[src.icon_tag]_deployer"
		if (!src.forensic_ID)
			if (forensics_id)
				src.forensic_ID = forensics_id
			else
				src.forensic_ID = src.CreateID()
				forensic_IDs.Add(src.forensic_ID)

	get_desc()
		. = "<br><span class='notice'>It looks [damage_words]</span>"


	attack_self(mob/user as mob)
		user.show_message("You assemble the turret parts.")
		src.set_loc(get_turf(user))
		src.spawn_turret(user.dir)
		user.u_equip(src)
		src.set_loc(get_turf(user))
		logTheThing("diary", user, null, "deploys the [src] turret at [log_loc(user)].")
		qdel(src)

	proc/spawn_turret(var/direct)
		var/obj/deployable_turret/turret = new src.associated_turret(src.loc, direct)
		turret.health = src.health // NO FREE REPAIRS
		turret.damage_words = src.damage_words
		turret.quick_deploy_fuel = src.quick_deploy_fuel
		return turret

	throw_end(list/params, turf/thrown_from)
		if(src.quick_deploy_fuel > 0)
			var/turf/thrown_to = get_turf(src)
			var/spawn_direction = get_dir(thrown_to,thrown_from)
			var/obj/deployable_turret/turret = src.spawn_turret(spawn_direction)
			turret.set_angle(get_angle(thrown_from,thrown_to))
			turret.quick_deploy()
			qdel(src)

	throw_impact(atom/hit_atom, datum/thrown_thing/thr=null)

		..()

/obj/item/turret_deployer/syndicate
	name = "NAS-T Deployer"
	desc = "A Nuclear Agent Sentry Turret Deployer. Use it in your hand to deploy."
	health = 250
	icon_tag = "st"
	quick_deploy_fuel = 2
	associated_turret = /obj/deployable_turret/syndicate

/obj/item/turret_deployer/riot
	name = "N.A.R.C.S. Deployer"
	desc = "A Nanotrasen Automatic Riot Control System Deployer. Use it in your hand to deploy."
	icon_state = "nt_deployer"
	w_class = W_CLASS_BULKY
	health = 125
	icon_tag = "nt"
	mats = list("INS-1"=10, "CON-1"=10, "CRY-1"=3, "MET-2"=2)
	is_syndicate = 1
	associated_turret = /obj/deployable_turret/riot

/obj/item/turret_deployer/outpost
	name = "Perimeter Turret Deployer"
	desc = "A standard issue perimeter security turret deployer used on the frontier. Use it in your hand to deploy."
	health = 125
	icon_state = "op_deployer"
	w_class = W_CLASS_BULKY
	icon_tag = "op"
	associated_turret = /obj/deployable_turret/outpost

/obj/item/turret_deployer/juicer
	name = "HOT DAWG DPLOYERE"
	desc = "This dude FUCKS. Let the dawg out by using it in your hand!"
	health = 150
	icon_state = "op_deployer"
	w_class = W_CLASS_BULKY
	icon_tag = "op"
	associated_turret = /obj/deployable_turret/juicer

/obj/item/turret_deployer/ams
	name = "AMS Antipersonnel Turret Deployer"
	desc = "A deadly rifle-chambered turret produced by a warware mercantile conglomerate. Use in hand or throw to deploy."
	health = 120
	quick_deploy_fuel = 1
	icon_state = "st_deployer"
	w_class = W_CLASS_BULKY
	icon_tag = "st"
	associated_turret = /obj/deployable_turret/ams

/////////////////////////////
//       Turret Code       //
/////////////////////////////
ABSTRACT_TYPE(/obj/deployable_turret)
/obj/deployable_turret
	name = "fucked up abstract turret that should never exist"
	desc = "why did you do this"
	icon = 'icons/obj/deployableturret.dmi'
	icon_state = "maphelper" //this gets set properly in new
	anchored = UNANCHORED
	density = 1
	var/health = 250
	var/max_health = 250
	var/list/mob/living/target_list = list()
	var/mob/living/target = null
	var/wait_time = 20 //wait if it can't find a target
	var/range = 7 // tiles
	var/internal_angle = 0 // used for the matrix transforms
	var/external_angle = 180 // used for determining target validity
	var/projectile_type = null
	var/datum/projectile/current_projectile
	var/burst_size = 3 // number of shots to fire. Keep in mind the bullet's shot_count
	var/fire_rate = 3 // rate of fire in shots per second
	var/angle_arc_size = 45
	var/active = 0 // are we gonna shoot some peeps?
	var/damage_words = "mostly undamaged!"
	var/icon_tag = null //tag for icons to get correct states on activating/deactivating. 'st' for syndicate, 'nt' for NT
	var/quick_deploy_fuel = 2 // number of quick deploys the turret has left
	var/spread = 0
	var/associated_deployer = null //what kind of turret deployer should this deconstruct to?
	var/deconstructable = TRUE
	var/can_toggle_activation = TRUE // whether you can enable or disable the turret with a screwdriver, used for map setpiece turrets
	var/sweep_angle = 0 // if nonzero, the turret will sweep side to side between +sweep_angle and -sweep_angle
	var/sweep_speed = 0 // how many degrees the turret rotates per processing tick
	var/sweep_current = 0 // tracks current angle of sweep
	var/emagged = FALSE
	var/firing = FALSE // so guns dont stack shooting
	var/nonstop = FALSE // try to reacquire the same target when done shooting

	New(loc, direction, forensics_id)
		..()
		src.set_dir(direction || src.dir) // don't set the dir if we weren't passed one
		src.set_initial_angle()

		if (!src.forensic_ID)
			if (forensics_id)
				src.forensic_ID = forensics_id
			else
				src.forensic_ID = src.CreateID()
				forensic_IDs.Add(src.forensic_ID)

		src.icon_state = "[src.icon_tag]_base"
		src.appearance_flags |= RESET_TRANSFORM
		src.underlays += src
		src.appearance_flags &= ~RESET_TRANSFORM
		src.icon_state = "[src.icon_tag]_off"
		src.appearance_flags |= PIXEL_SCALE

		var/matrix/M = matrix()
		src.transform = M.Turn(src.external_angle)
		processing_items |= src
		if(active)
			set_projectile()

		#ifdef LOW_SECURITY
		START_TRACKING_CAT(TR_CAT_DELETE_ME)
		#endif

	emag_act(mob/user, obj/item/card/emag/E)
		if (src.emagged)
			return
		src.emagged = TRUE
		boutput(user, SPAN_ALERT("You short out [src]'s targeting systems."))
		src.visible_message(SPAN_ALERT(SPAN_BOLD("[src] buzzes oddly!")))
		playsound(src, "sound/effects/sparks[rand(1, 6)].ogg", 40, 1, extrarange = -10)

	disposing()
		processing_items.Remove(src)
		..()


	get_desc(dist)
		. = "<br><span class='notice'>It looks [src.damage_words]. It is [src.anchored ? "secured to" : "unsecured from"] the floor and powered [src.active ? "on" : "off"].</span>"

	proc/set_initial_angle()
		switch(src.dir)
			if(NORTH)
				src.external_angle = (0)
			if(NORTHEAST)
				src.external_angle = (45)
			if(EAST)
				src.external_angle = (90)
			if(SOUTHEAST)
				src.external_angle = (135)
			if(SOUTH)
				src.external_angle = (180)
			if(SOUTHWEST)
				src.external_angle = (225)
			if(WEST)
				src.external_angle = (270)
			if(NORTHWEST)
				src.external_angle = (315)
			else
				src.external_angle = (180) // how did you get here?

	proc/set_projectile()
		current_projectile = new projectile_type
		current_projectile.shot_number = burst_size
		current_projectile.shot_delay = 10/fire_rate

	proc/shoot(target, angle_of_rest)
		SPAWN_DBG(0)
			src.firing = TRUE
			angle_of_rest = angle_of_rest ? angle_of_rest : src.external_angle
			var/list/casing_turfs
			var/turf/picked_turf
			if (src.current_projectile.casing)
				casing_turfs = list()
				for (var/direction in alldirs)
					var/turf/T = get_step(src, direction)
					if (T && !T.density)
						casing_turfs += T
			for(var/i in 1 to src.current_projectile.shot_number) //loop animation until finished
				set_angle(get_angle(src,target))
				src.on_shoot()
				flick("[src.icon_tag]_fire",src)
				muzzle_flash_any(src, 0, "muzzle_flash")
				if (src.current_projectile.casing)
					picked_turf = pick(casing_turfs)
					var/obj/item/casing/turret_casing = new src.current_projectile.casing(picked_turf, src.forensic_ID)
					// prevent infinite casing stacks
					if (length(picked_turf.contents) > 6)
						SPAWN_DBG(30 SECONDS)
							if (!QDELETED(turret_casing) && get_turf(turret_casing) == picked_turf)
								qdel(turret_casing)
				sleep(src.current_projectile.shot_delay)
			if(src.nonstop && target_valid(target, FALSE))
				shoot(target, angle_of_rest)
			else
				set_angle(angle_of_rest)
				src.firing = FALSE
		shoot_projectile_ST_pixel_spread(src, current_projectile, target, 0, 0 , spread)

	proc/on_shoot()
		return

	proc/process()
		if(src.active && !src.firing)
			if(!src.target && !src.seek_target()) //attempt to set the target if no target
				src.sweep()
				return
			if(!src.target_valid(src.target)) //check valid target
				src.icon_state = "[src.icon_tag]_idle"
				src.target = null
				src.sweep()
				return
			else //GUN THEM DOWN
				if(src.target)
					src.shoot(target)

	proc/sweep()
		if(!src.sweep_angle)
			return
		src.sweep_current = clamp(src.sweep_current + src.sweep_speed,-src.sweep_angle,src.sweep_angle)
		if(abs(src.sweep_current) == src.sweep_angle)
			src.sweep_speed *= -1
		src.set_angle(src.external_angle + src.sweep_speed)

	attackby(obj/item/W, mob/user)
		user.lastattacked = src
		if (isweldingtool(W) && !(src.active))
			if(!W:try_weld(user, 1))
				return

			user.show_message(src.anchored ? "You start to unweld the turret from the floor." : "You start to weld the turret to the floor.")
			SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, .proc/toggle_anchored, null, W.icon, W.icon_state, \
			  src.anchored ? "[user] unwelds the turret from the floor." : "[user] welds the turret to the floor.", \
			  INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)
			logTheThing("diary", user, "[src.anchored ? "unwelds" : "welds"] the [src] turret [src.anchored ? "from" : "to"] the floor at [log_loc(src)]")

		else if (isweldingtool(W) && (src.active))
			if (src.health >= max_health)
				user.show_message("<span class='notice'>The turret is already fully repaired!.</span>")
				return

			if(!W:try_weld(user, 1))
				return

			user.show_message("You start to repair the turret.")
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, .proc/repair, null, W.icon, W.icon_state, \
			  "[user] repairs some of the turret's damage.", \
			  INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)
			logTheThing("diary", user, "repairs the [src] turret with a welding tool at [log_loc(user)]")

		else if  (iswrenchingtool(W))

			if(src.active || src.anchored)

				user.show_message("<span class='notice'>Click where you want to aim the turret!</span>")
				var/datum/targetable/deployable_turret_aim/A = new()
				user.targeting_ability = A
				user.update_cursor()
				A.my_turret = src
				A.user_turf = get_turf(user)
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				logTheThing("diary", user, "reorients the [src] turret (at [log_loc(src)]) to face a new direction.")

			else
				user.show_message("You begin to disassemble the turret.")
				playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
				SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, .proc/spawn_deployer, null, W.icon, W.icon_state, \
				  "[user] disassembles the turret.", \
				  INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)
				logTheThing("diary", user, "undeploys the [src] turret at [log_loc(user)].")

		else if (isscrewingtool(W))

			if(src.can_toggle_activation == TRUE || !src.is_friend(user))

				if(!src.anchored && !src.active)
					user.show_message("<span class='notice'>The turret is too unstable to fire! Secure it to the ground with a welding tool first!</span>")
					return

				if (!src.deconstructable)
					user.show_message("<span class='alert'>You can't power the turret off! The controls are too secure!</span>")
					return

				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)

				SETUP_GENERIC_ACTIONBAR(user, src, 1 SECOND, PROC_REF(toggle_activated), null, W.icon, W.icon_state, \
			 	 "[user] powers the turret [src.active ? "off" : "on"].", \
			 	 INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)
				logTheThing("diary", user, "powers the [src] turret [src.active ? "off" : "on"] at [log_loc(src)].")

			else
				user.show_message("<span class='alert'>The activation switch is protected! You can't toggle the power!</span>")
				return

		else if (istype(W, /obj/item/card/emag)) //emags should be sneaky
			..()
		else
			src.health = src.health - W.force
			playsound(get_turf(src), "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 25, 1)
			attack_particle(user,src)
			src.check_health()
			..()

	//actionbar procs
	///Anchor if unanchored, unanchor if anchored
	proc/toggle_anchored()
		src.anchored = !src.anchored

	///Repair the turret by 10 health (only repaired by welding currently, so no custom values)
	proc/repair()
		src.health = min(src.max_health, (src.health + 10))
		src.check_health()

	///Toggle the turret on or off.
	proc/toggle_activated()
		if (src.active)
			src.icon_state = "[src.icon_tag]_off"
			src.active = FALSE
			src.firing = FALSE
			src.target = null
		else
			src.set_projectile()
			src.active = 1
			src.icon_state = "[src.icon_tag]_idle"

	proc/quick_deploy()
		if(!(src.quick_deploy_fuel > 0))
			return
		src.quick_deploy_fuel--
		src.visible_message("<span class='alert'>[src]'s quick deploy system engages, automatically securing it!</span>")
		playsound(src.loc, "sound/items/Welder2.ogg", 30, 1)
		set_projectile()
		src.anchored = 1
		src.active = 1
		src.icon_state = "[src.icon_tag]_idle"

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round((P.power*P.proj_data.ks_ratio), 1.0)
		if (damage < 1)
			return
		src.health = src.health - max(P.power/2,0) // staples have a power of 5, .22 bullets have a power of 35
		src.check_health()

	proc/check_health()
		if(src.health <= 0)
			src.active = FALSE
			src.firing = FALSE
			src.target = null
			src.die()

		var/percent_damage = src.health/src.max_health * 100
		switch(percent_damage)
			if(90 to 100)
				damage_words = "mostly undamaged!"
			if(75 to 89)
				damage_words = "a little bit damaged."
			if(30 to 74)
				damage_words = "pretty beaten up."
			if(0 to 29)
				damage_words = "to be on the verge of falling apart!"

	proc/die()
		playsound(src.loc, "sound/impact_sounds/Machinery_Break_1.ogg", 50, 1)
		new /obj/decal/cleanable/robot_debris(src.loc)
		qdel(src)

	proc/spawn_deployer()
		var/obj/item/turret_deployer/deployer = new src.associated_deployer(src.loc, src.forensic_ID)
		deployer.health = src.health // NO FREE REPAIRS
		deployer.damage_words = src.damage_words
		deployer.quick_deploy_fuel = src.quick_deploy_fuel
		deployer.tooltip_rebuild = 1
		qdel(src)
		return deployer

	proc/seek_target()
		src.target_list = list()
		for (var/mob/living/C in mobs)
			if(!src)
				break

			if (!isnull(C) && src.target_valid(C))
				src.target_list += C
				var/distance = GET_DIST(C.loc,src.loc)
				src.target_list[C] = distance

			else
				continue

		if (src.target_list.len>0)
			var/min_dist = 99999

			for (var/mob/living/T in src.target_list)
				if (src.target_list[T] < min_dist)
					src.target = T
					min_dist = src.target_list[T]

			src.icon_state = "[src.icon_tag]_active"

			playsound(src.loc, "sound/vox/woofsound.ogg", 40, 1)

		return src.target

	proc/target_valid(var/mob/living/C, var/check_angle = TRUE)
		var/distance = GET_DIST(get_turf(C),get_turf(src))

		if(distance > src.range)
			return 0
		if (!C)
			return 0
		if(!isliving(C) || isintangible(C))
			return 0
		if (C.health < 0)
			return 0
		if (C.stat == 2)
			return 0
		if (istype(C,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = C
			if (H.hasStatus(list("weakened", "stunned", "paralysis"))) // stops it from uselessly firing at people who are already suppressed. It's meant to be a suppression weapon!
				return FALSE
		if (is_friend(C) && !src.emagged)
			return FALSE

		var/angle = get_angle(get_turf(src),get_turf(C))


		var/anglemod = (-(angle < 180 ? angle : angle - 360) + 90) //Blatant Code Theft from showLine(), checks to see if there's something in the way of us and the target
		var/crossed_turfs = list()
		crossed_turfs = castRay(src,anglemod,distance)
		for (var/turf/T in crossed_turfs)
			if (T.opacity == 1)
				return 0
			if (T.density == 1)
				return 0

		if(!check_angle)
			return 1

		angle = angle < 0 ? angle+360 : angle // make angles positive
		angle = angle - src.external_angle

		if (angle > 180) // rotate angle and convert into absolute terms from 0, where 0 is the seek-arc midpoint
			angle = abs(360-angle)
		else if (angle < -180)
			angle = abs(360+angle)
		else
			angle = abs(angle)

		if (angle <= (angle_arc_size/2)) //are we in the seeking arc?
			return 1
		return 0


	proc/is_friend(var/mob/living/C) //tried to keep this generic in case you want to make a turret that only shoots monkeys or something
		return null

	proc/set_angle(var/angle)
		angle = angle > 0 ? angle%360 : -((-angle)%360)+360 //limit user input to a sane range!
		var/angle_diff = angle - src.external_angle
		var/new_internal_angle = src.internal_angle + angle_diff

		new_internal_angle = new_internal_angle > 0 ? new_internal_angle%360 : -((-new_internal_angle)%360)+360 //limit user input to a sane range!

		src.animate_turret_turn(src.internal_angle,new_internal_angle)

		src.internal_angle = new_internal_angle
		src.external_angle = angle


	proc/animate_turret_turn(var/curr_ang,var/new_ang)
		var/ang = (new_ang - curr_ang)
		if (abs(ang) > 180) // stops funky turret moving where it flips the long way around
			ang = ang > 0 ? ang - 360 : ang + 360

		var/time = max(ang / 54,1) // 54 is a magic number so that a 180 degree turn takes 1 second, and all others are faster
		var/matrix/transform_original = src.transform
		animate(src, transform = matrix(transform_original, ang/3, MATRIX_ROTATE | MATRIX_MODIFY), time = time, loop = 0) //blatant code theft from throw_at proc
		animate(transform = matrix(transform_original, ang/3, MATRIX_ROTATE | MATRIX_MODIFY), time = time, loop = 0) // needs to do in multiple steps because byond takes shortcuts
		animate(transform = matrix(transform_original, ang/3, MATRIX_ROTATE | MATRIX_MODIFY), time = time, loop = 0) // :argh:

/obj/deployable_turret/syndicate
	name = "NAS-T"
	desc = "A Nuclear Agent Sentry Turret."
	projectile_type = /datum/projectile/bullet/rifle/soviet
	icon_tag = "st"
	associated_deployer = /obj/item/turret_deployer/syndicate

	is_friend(var/mob/living/C)
		return istype(C.get_id(), /obj/item/card/id/syndicate) || istype(C, /mob/living/critter/gunbot/) //dumb lazy

/obj/deployable_turret/syndicate/active
	anchored = 1

	New(loc)
		..(src.loc, src.dir)
		src.toggle_activated()

/obj/deployable_turret/riot
	name = "N.A.R.C.S."
	desc = "A Nanotrasen Automatic Riot Control System."
	health = 125
	max_health = 125
	range = 5
	projectile_type = /datum/projectile/bullet/slug/rubber
	burst_size = 1
	fire_rate = 1
	angle_arc_size = 60
	icon_tag = "nt"
	quick_deploy_fuel = 0
	associated_deployer = /obj/item/turret_deployer/riot
	sweep_angle = 25
	sweep_speed = 5

	is_friend(var/mob/living/C)
		var/obj/item/card/id/I = C.get_id()
		if(!istype(I))
			return FALSE
		. = (access_security in I.access) || (access_heads in I.access)

/obj/deployable_turret/riot/active
	anchored = 1

	New(loc)
		..(src.loc, src.dir)
		src.toggle_activated()

/obj/deployable_turret/outpost // for a planetary outpost, it gon' shootcha!
	name = "Perimeter Turret"
	desc = "The red light seems to be pointed right at you. Uh oh..."
	health = 125
	max_health = 125
	range = 7
	projectile_type = /datum/projectile/bullet/rifle/soviet
	burst_size = 2
	fire_rate = 1
	angle_arc_size = 90
	icon_tag = "op"
	quick_deploy_fuel = 0
	associated_deployer = /obj/item/turret_deployer/outpost

/obj/deployable_turret/outpost/active
	can_toggle_activation = FALSE // for map placement so people don't cheese them by rushing them with a screwdriver
	anchored = ANCHORED

	New(loc)
		..(src.loc, src.dir)
		src.toggle_activated()

	north
		dir=NORTH
	south
		dir=SOUTH
	east
		dir=EAST
	west
		dir=WEST

/obj/deployable_turret/juicer
	name = "HOT DAWG Turret"
	desc = "Oh shit, someone welded a shotgun to an office chair and wired it up!"
	health = 150
	max_health = 150
	range = 5
	projectile_type = /datum/projectile/special/spreader/buckshot_burst/juicer/scrap
	burst_size = 2
	fire_rate = 1.5
	angle_arc_size = 75
	icon_tag = "op"
	quick_deploy_fuel = 0
	associated_deployer = /obj/item/turret_deployer/juicer
	sweep_angle = 75
	sweep_speed = 25
	nonstop = TRUE

	is_friend(var/mob/living/C)
		var/obj/item/card/id/I = C.get_id()
		if(!istype(I))
			return FALSE
		. = (access_juicer in I.access)

	/// this thing is somehow the most dangerous part of the turret
	on_shoot()
		var/slide_angle = src.external_angle + rand(-20,20)
		var/scalar = rand(4,16) - 8 * src.anchored
		var/slide_x = src.pixel_x - sin(slide_angle) * scalar
		var/slide_y = src.pixel_y - cos(slide_angle) * scalar
		if(slide_x > 16)
			if(!step(src, EAST))
				for(var/mob/living/L in get_step(src, EAST))
					L.throw_at(get_edge_cheap(src, EAST), 2, 1)
				slide_x -= rand(10,20)
			else
				slide_x = pixel_x % 32 - 16
		else if(slide_x < -16)
			if(!step(src, WEST))
				for(var/mob/living/L in get_step(src, WEST))
					L.throw_at(get_edge_cheap(src, WEST), 2, 1)
				slide_x += rand(10,20)
			else
				slide_x = pixel_x % 32 + 16
		if(slide_y > 16)
			if(!step(src, NORTH))
				for(var/mob/living/L in get_step(src, NORTH))
					L.throw_at(get_edge_cheap(src, NORTH), 2, 1)
				slide_y -= rand(10,20)
			else
				slide_y = pixel_y % 32 - 16
		else if(slide_y < -16)
			if(!step(src, SOUTH))
				for(var/mob/living/L in get_step(src, SOUTH))
					L.throw_at(get_edge_cheap(src, SOUTH), 2, 1)
				slide_y += rand(10,20)
			else
				slide_y = pixel_y % 32 + 16
		animate(src, pixel_x = slide_x, pixel_y = slide_y, time = 0.2 SECONDS, flags = ANIMATION_PARALLEL)
		if(src.anchored == ANCHORED && prob(15))
			src.visible_message("<span class='combat bold'>\The [src] snaps a brake!</span>")
			src.toggle_anchored()
		..()

/obj/deployable_turret/juicer/active
	anchored = ANCHORED

	New(loc)
		..(src.loc, src.dir)
		src.toggle_activated()

	north
		dir=NORTH
	south
		dir=SOUTH
	east
		dir=EAST
	west
		dir=WEST

/obj/deployable_turret/juicer/active/fullrotation
	sweep_angle = 360
	sweep_speed = 120
	angle_arc_size = 180

/obj/deployable_turret/ams
	name = "AMS Antipersonnel Turret"
	desc = "A vicious turret with multiple sensor arrays and massive range. The side is emblazoned with a crossed sword and pickaxe."
	health = 120
	max_health = 120
	range = 12
	projectile_type = /datum/projectile/bullet/rifle/soviet/slow
	spread = 3
	burst_size = 1
	fire_rate = 2
	angle_arc_size = 270
	icon_tag = "st"
	quick_deploy_fuel = 0
	associated_deployer = /obj/item/turret_deployer/ams
	sweep_angle = 90
	sweep_speed = 10
	nonstop = TRUE

	on_shoot()
		var/datum/lineResult/lasersight = drawLine(src, src.target, "red_laser", getCrossed = 0)
		lasersight.lineImage.appearance_flags |= RESET_TRANSFORM
		lasersight.lineImage.alpha = 196
		lasersight.lineImage.plane = PLANE_SELFILLUM
		lasersight.lineImage.blend_mode = BLEND_ADD
		addGlobalImage(lasersight.lineImage, "ams_turret_[src.forensic_ID]")
		animate(lasersight.lineImage, alpha = 0, time = 0.2 SECONDS)
		..()

/obj/deployable_turret/ams/active
	anchored = ANCHORED

	New(loc)
		..(src.loc, src.dir)
		src.toggle_activated()

	north
		dir=NORTH
	south
		dir=SOUTH
	east
		dir=EAST
	west
		dir=WEST

/////////////////////////////
//   Turret Ability Stuff  //
/////////////////////////////

/datum/targetable/deployable_turret_aim
	name = "Turret Aim"
	desc = "You are aiming a turret"
	cooldown = 0
	targeted = 1
	target_anything = 1
	max_range = 3000
	var/obj/deployable_turret/my_turret = null
	var/turf/user_turf = null

	castcheck(var/mob/M)
		if (M.client && M.client.holder) //???
			return TRUE
		else
			return ..()

	handleCast(var/atom/target)

		var/mob/M = usr

		if (istype(M))
			if(!my_turret.is_friend(M) && !my_turret.emagged)
				boutput(M, "<span class='alert'>You can't modify the aim of this turret without being authorized!</span>")
				return

			if(!iswrenchingtool(M.equipped()))
				boutput(M, "<span class='alert'>You need to be holding a wrench or similar to modify the turret's aim.</span>")
				return

			if (!my_turret.deconstructable)
				boutput(M, "<span class='alert'>You can't modify this turret's aim- it's bolted in place!</span>")
				return

			if(!(get_turf(usr) == src.user_turf))
				return

			if(target == my_turret)
				return

			if (!istype(target,/turf))
				target = get_turf(target)

			if(target == get_turf(my_turret))
				return

			SPAWN_DBG(0)
				src.my_turret.set_angle(get_angle(my_turret,target))
				src.my_turret.sweep_current = 0

			return 0

/////////////////////////////
//       User Manuals      //
/////////////////////////////

/obj/item/paper/nast_manual
	name = "paper- 'Nuclear Agent Sentry Turret Manual'"
	info = {"<h4>Nuclear Agent Sentry Turret Manual</h4>
	Congratulations, on your purchase of a Nuclear Agent Sentry Turret!<br>
	This a turret that fires at non-syndicate threats in a 45 degree arc.<br>
	Press its deploy button while it is your hand to deploy it.<br>
	The turret will start out facing the direction you are facing.<br>
	If the turret is unsecured, wrenching it will disassemble it.<br>
	Weld it to the floor to secure it.<br>
	While secured, using a screwdriver on the turret will turn it on, and using a wrench on it will set the angle.<br>
	Setting the angle will bring up a prompt to choose a target. Direct the turret to a sightline by pointing at it.<br>
	Welding the turret while it is active will allow you to perform repairs.<br>
	This turret is equipped with two quick-deploy charges installed.<br>
	When thrown, one quick-deploy charge will be used, automatically securing and activating the turret.<br>
	The quick-deployed turret will point in the direction it was thrown."}

/obj/item/paper/narcs_manual
	name = "paper- 'Nanotrasen Automatic Riot Control System'"
	info = {"<h4>Nanotrasen Automatic Riot Control System</h4>
	Congratulations, on your purchase of a Nanotrasen Automatic Riot Control System!<br>
	This a turret that fires at non-security and non-command threats in a 60 degree arc.<br>
	Press its deploy button while it is your hand to deploy it.<br>
	The turret will start out facing the direction you are facing.<br>
	If the turret is unsecured, wrenching it will disassemble it.<br>
	Weld it to the floor to secure it.<br>
	While secured, using a screwdriver on the turret will turn it on, and using a wrench on it will set the angle.<br>
	Setting the angle will bring up a prompt to choose a target. Direct the turret to a sightline by pointing at it.<br>
	Welding the turret while it is active will allow you to perform repairs.<br>"}
