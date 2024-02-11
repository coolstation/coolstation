var/list/datum/kart_powerup/karting_powerups = list()

/area/sim/racing_entry
	name = "Clowncar Race track - Entry"
	icon_state = "green"
	luminosity = 1
	force_fullbright = 1
	requires_power = 0

/area/sim/racing_track
	name = "Clowncar Race track"
	icon_state = "yellow"
	luminosity = 1
	force_fullbright = 1
	requires_power = 0

/obj/racing_boosterstrip
	name = "Booster"
	icon = 'icons/misc/racing.dmi'
	icon_state = "boosterstrip"
	anchored = 1
	density = 0
	opacity = 0
	event_handler_flags = USE_HASENTERED
	plane = PLANE_NOSHADOW_BELOW

	HasEntered(atom/A)
		if(istype(A,/obj/vehicle/kart))
			playsound(A, "sound/mksounds/boost.ogg",30, 0)
			step(A,src.dir)

			var/obj/vehicle/kart/R = A
			R.boost(1.5 SECONDS)


/obj/racing_powerup_spawner
	name = "PowerUpSpawner"
	icon = 'icons/Testing/atmos_testing.dmi'
	anchored = 1
	density = 0
	opacity = 0
	invisibility = 101
	var/spawn_time = 0
	var/wait = 0

	New()
		processing_items += src
		spawnit()
		..()

	disposing()
		processing_items -= src
		..()

	proc/process()
		if (world.time > spawn_time + wait)
			spawnit()

	proc/spawnit()
		if(!(locate(/obj/racing_powerupbox) in src.loc))
			new/obj/racing_powerupbox(src.loc)
		wait = 150 + rand(50, 400)
		spawn_time = world.time

/obj/racing_butt/
	name = "butt"
	icon = 'icons/misc/racing.dmi'
	icon_state = "buttshell"
	anchored = 1
	density = 1
	opacity = 0
	var/source_car = null

	New(var/atom/spawnloc, var/spawndir, var/atom/sourcecar)
		..()
		src.set_loc(spawnloc)
		src.set_dir(spawndir)
		source_car = sourcecar
		SPAWN_DBG(7.5 SECONDS)
			playsound(src, "sound/mksounds/itemdestroy.ogg",45, 0)
			qdel(src)
		move_process()

	Bump(var/atom/A)
		if(istype(A,/obj/vehicle/kart) && A != source_car)
			var/obj/vehicle/kart/R = A
			R.spin(20)
			playsound(A, "sound/mksounds/gothit.ogg",45, 0)
			qdel(src)

	proc/move_process()
		if (src.qdeled || src.pooled)
			return
		step(src,dir)
		SPAWN_DBG(1 DECI SECOND) move_process()

/obj/super_racing_butt/
	name = "superbutt"
	icon = 'icons/misc/racing.dmi'
	icon_state = "superbuttshell"
	anchored = 1
	density = 1
	opacity = 0
	var/source_car = null

	New(var/atom/spawnloc, var/spawndir, var/atom/sourcecar)
		..()
		src.set_loc(spawnloc)
		src.set_dir(spawndir)
		source_car = sourcecar
		SPAWN_DBG(7.5 SECONDS)
			playsound(src, "sound/mksounds/itemdestroy.ogg",45, 0)
			qdel(src)
		move_process()

	Bump(var/atom/A)
		if(istype(A,/obj/vehicle/kart) && A != source_car)
			var/obj/vehicle/kart/R = A
			R.spin(15)
			playsound(A, "sound/mksounds/gothit.ogg",45, 0)
			qdel(src)

	proc/move_process()
		if (src.qdeled || src.pooled)
			return

		var/atom/target = null

		for(var/obj/vehicle/kart/C in view(2,src))
			if(C != source_car)
				target = C
				break

		if(target)
			step_towards(src,target)
			SPAWN_DBG(1 DECI SECOND) move_process()
		else
			step(src, src.dir)
			SPAWN_DBG(1 DECI SECOND) move_process()

/obj/racing_trap_banana/
	name = "banana peel"
	icon = 'icons/misc/racing.dmi'
	icon_state = "banana-peel"
	anchored = 1
	density = 0
	opacity = 0
	var/delete = 1
	event_handler_flags = USE_HASENTERED
	var/spawn_time = 0

	New()
		..()
		spawn_time = world.time
		if (delete)
			processing_items += src

	disposing()
		if (delete)
			processing_items -= src
		..()

	proc/process()
		if (world.time > spawn_time + 4500)
			qdel(src)

	HasEntered(atom/A)
		if(istype(A,/obj/vehicle/kart))
			var/obj/vehicle/kart/R = A
			R.spin(20)
			playsound(src, "sound/mksounds/itemdestroy.ogg",45, 0)
			if(delete)	qdel(src)


/obj/racing_powerupbox/
	name = "POWERUP!"
	icon = 'icons/misc/racing.dmi'
	icon_state = "powerup"
	anchored = 1
	density = 0
	opacity = 0
	event_handler_flags = USE_HASENTERED

	HasEntered(atom/A)
		if(istype(A,/obj/vehicle/kart))
			var/obj/vehicle/kart/R = A
			R.random_powerup()
			qdel(src)

//project "holy fuck the kart track is neglected to shit"
/obj/vehicle/kart //like, /obj/vehicle is an *upgrade* for karts
	name = "\improper Go-Kart"
	desc = "A Go-Kart, whatever the kids spell it these days."
	icon = 'icons/misc/racing.dmi'
	icon_state = "kart_blue_u"
	layer = OBJ_LAYER
	var/returnpoint = null
	var/returndir = null
	var/turf/returnloc = null
	var/colour = "blue"

	//var/obj/powerup/powerup = null
	ability_buttons_to_initialize = list(/obj/ability_button/kart_powerup)

	var/dir_original = 1

	var/cant_control = 0 //Used during spins, etc
	delay = 2
	var/base_delay = 2 //Base speed.
	var/turbo = 1 //Boost speed is base_speed - turbo.
	var/super = 0 //Invincibility

	//One of the more important bits of kart racers like this is chaining boosts together
	//so this is just a "only have the spawn for the most recent boost resets speed" tally var
	//It does mean that if you use a long boost item into a short boost that it would normally outlast, most of the long one is wasted
	//But I think mario kart does it that way too and that's what this whole thing is modeled after anyway
	var/boost_generation = 0 //karts ain't got a process loop, nor would a coarse timing associatiated with those work for boosts.
	//var/driving = 0


	red
		icon_state = "kart_red_u"
		colour = "red"

	New()
		..()
		returndir = dir
		if(returnpoint)
			returnloc = pick_landmark(returnpoint)

/obj/vehicle/kart/relaymove(mob/user as mob, dir)
	if (!cant_control)
		..()

//hot kart on kart action
/obj/vehicle/kart/Bump(var/atom/A)
	if(super && istype(A,/obj/vehicle/kart))
		var/obj/vehicle/kart/R = A
		if(!R.super)
			R.set_dir(pick(turn(src.dir,90),turn(src.dir,-90)))
			step(R,R.dir)
			R.spin(6)
	return

/obj/vehicle/kart/remove_air(amount as num)
	var/datum/gas_mixture/Air = new()
	Air.oxygen = amount
	Air.temperature = 310
	return Air

//god why isn't this shared vehicle code
/obj/vehicle/kart/MouseDrop_T(atom/movable/A as obj|mob, mob/user as mob)
	if (user.stat)
		return

	if(ishuman(A) && get_dist(user, src) <= 1  && get_dist(A, user) <= 1 && !rider)
		if (A == user)
			boutput(user, "You get into [src].")
		else
			boutput(user, "<span class='notice'>You help [A] onto [src]!</span>")
		A.set_loc(src)
		src.rider = A
		UpdateOverlays(src.rider, "rider")
		src.name = "[A.name]'s Go-Kart"
		if (rider.client)
			handle_button_addition()
		return

/obj/vehicle/kart/Click()
	//Click the forkli-kart when inside it to get out
	if(src.rider != usr)
		..()
		return

	if (usr.stat)
		return

	stop()
	eject_rider()
	return

/obj/vehicle/kart/eject_rider(crashed, selfdismount, ejectall)
	src.name = initial(src.name)
	var/obj/ability_button/kart_powerup/ability = locate() in src.ability_buttons
	ability?.current_powerup = null //clear powerup for fairness, or something.
	..()

/obj/vehicle/kart/proc/reset()
	stop()
	returntoline()
	eject_rider()
	update()

/obj/vehicle/kart/proc/returntoline()
	if(returnloc)
		set_loc(returnloc)
		set_dir(returndir)

/obj/vehicle/kart/proc/update()
	if(!rider)
		icon_state = "kart_[colour]_u"
	else
		icon_state = "kart_[colour]"

/obj/vehicle/kart/proc/spin(var/magnitude)
	if(super) return
	cant_control = 1
	set_density(0)
	dir_original = src.dir
	var/image/out_of_control = image('icons/misc/racing.dmi',"broken")
	UpdateOverlays(out_of_control, "out_of_control")

	playsound(src, "sound/mksounds/cpuspin.ogg",33, 0)

	SPAWN_DBG(magnitude+1)
		cant_control = 0
		dir_original = 0
		set_density(1)
		UpdateOverlays(null, "out_of_control")

	SPAWN_DBG(0)
		for(var/i=0, i<magnitude, i++)
			src.set_dir(turn(src.dir, 90))
			sleep(0.1 SECONDS)
	return

/obj/vehicle/kart/proc/boost(time = 5 SECONDS, reset_super = FALSE)
	delay = base_delay - turbo
	walk(src, dir, delay)

	UpdateOverlays(image('icons/misc/racing.dmi', "up-speed"), "boost")
	boost_generation++
	var/cur_boost = boost_generation
	SPAWN_DBG(time)
		if (reset_super) //So I introduced another race condition with chaining super boosts but I'll look at that later
			src.super = FALSE //previously super *never* cleared, good job
		//another boost got chained from this one and now we don't do shit
		if (boost_generation != cur_boost)
			return
		delay = base_delay
		if (rider)//good enough 4 now
			walk(src, dir, delay)
		else
			stop()
		UpdateOverlays(null, "boost")

/obj/vehicle/kart/proc/random_powerup()
	if (!length(karting_powerups))
		for(var/thing in concrete_typesof(/datum/kart_powerup/))
			karting_powerups += new thing
	playsound(src, "sound/mksounds/gotitem.ogg",33, 0)

	var/datum/kart_powerup/picked = pick(karting_powerups)
	var/obj/ability_button/kart_powerup/ability = locate() in src.ability_buttons
	if (ability && picked)
		ability.current_powerup = picked
		ability.name = "Power-Up ([picked.name])"
		ability.desc = "Click to use."
		ability.icon_state = picked.UI_icon


ABSTRACT_TYPE(/datum/kart_powerup)
/datum/kart_powerup
	var/UI_icon = "blank"
	var/name = "powerup"
/datum/kart_powerup/proc/use(obj/vehicle/kart/user)

/datum/kart_powerup/bananapeel
	name = "Bananapeel"
	UI_icon = "banana"

	use(obj/vehicle/kart/user)
		var/turf/T = get_turf(user)
		new/obj/racing_trap_banana/(T)
		playsound(T, "sound/mksounds/itemdrop.ogg",45, 0)

/datum/kart_powerup/butt
	name = "Butt"
	UI_icon = "butt"

	use(obj/vehicle/kart/user)
		var/turf/T = get_turf(user)
		var/turf/T2 = get_step(T,user.dir)
		var/turf/trg = null

		if(!T2.density) trg = T2
		else trg = T
		new/obj/racing_butt(trg, user.dir, user)
		playsound(user, "sound/mksounds/throw.ogg",33, 0)

/datum/kart_powerup/superbutt
	name = "Superbutt"
	UI_icon = "superbutt"

	use(obj/vehicle/kart/user)
		var/turf/T = get_turf(user)
		var/turf/T2 = get_step(T,user.dir)
		var/turf/trg = null

		if(!T2.density) trg = T2
		else trg = T
		new/obj/super_racing_butt(trg, user.dir, user)
		playsound(user, "sound/mksounds/throw.ogg",33, 0)

/datum/kart_powerup/mushroom
	name = "Mushroom"
	UI_icon = "mushroom"

	use(obj/vehicle/kart/user)
		playsound(user, "sound/mksounds/boost.ogg",33, 0)
		user.boost(5 SECONDS)

/datum/kart_powerup/superboost
	name = "Super Boost"
	UI_icon = "superboost"

	use(obj/vehicle/kart/user)
		playsound(user, "sound/mksounds/invin10sec.ogg",33, 0,0) // 33

		user.super = TRUE
		user.boost(5 SECONDS, TRUE) //if the music lasts 10 seconds, maybe this should?


/obj/ability_button/kart_powerup
	name = "Power-Up (Empty)"
	desc = "Click to use (once you grab an item)"
	icon = 'icons/misc/racing.dmi'
	icon_state = "blank"
	var/datum/kart_powerup/current_powerup = null

	Click()
		if(!the_mob) return
		if(!current_powerup) return

		if (istype(the_mob.loc, /obj/vehicle/kart))
			current_powerup.use(the_mob.loc)
			current_powerup = null
			src.name = "Power-Up (Empty)"
			src.desc = "Click to use (once you grab an item)"
			src.icon_state = "blank"

	disposing()
		current_powerup = null
		..()

