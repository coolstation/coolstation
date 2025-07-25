// crates/closets/etc.  this shoulda been combined a while ago, but here we are.

// NOTE:
// Unlike old closets/etc, these things make their contents in the make_my_stuff() proc.
// DO NOT OVERRIDE New() ON THESE OKAY
// PLEASE JUST MAKE A MESS OF make_my_stuff() INSTEAD
// CALL YOUR PARENTS

#define RELAYMOVE_DELAY 50

/obj/storage
	name = "storage"
	desc = "this is a parent item you shouldn't see!!"
	flags = FPRINT | NOSPLASH | FLUID_SUBMERGE
	event_handler_flags = USE_FLUID_ENTER | USE_CANPASS | NO_MOUSEDROP_QOL
	icon = 'icons/obj/large_storage.dmi'
	icon_state = "closed"
	density = 1
	throwforce = 10
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	p_class = 2.5
	var/intact_frame = 1 //Variable to create crates and fridges which cannot be closed anymore.
	var/secure = 0
	var/personal = 0
	var/registered = null
	var/icon_closed = "closed"
	var/icon_opened = "open"
	var/icon_welded = "welded-closet"
	var/open_sound = "sound/machines/click.ogg"
	var/close_sound = "sound/machines/click.ogg"
	var/max_capacity = 100 //Won't close past this many items.
	var/open = 0
	var/welded = 0
	var/image/weld_image
	//Offsets for the weld icon, rather than make icons for every slightly off crate or closet
	var/weld_image_offset_X = 0 //Positive is right, negative is left
	var/weld_image_offset_Y = 0 //Positive is up, negative is down
	var/locked = 0
	var/emagged = 0
	var/jiggled = 0
	var/legholes = 0
	var/health = 3
	var/can_flip_bust = 0 // Can the trapped mob damage this container by flipping?
	var/obj/item/card/id/scan = null
	var/datum/data/record/account = null
	var/last_relaymove_time
	var/is_short = 0 // can you not stand in it?  ie, crates?
	var/open_fail_prob = 50
	var/crunches_contents = 0 // for the syndicate trashcart & hotdog stand
	var/crunches_deliciously = 0 // :I
	//var/mob/living/carbon/to_crunch = null
	var/owner_ckey = null // owner of the crunchy cart, so they don't get crunched
	var/opening_anim = null
	var/closing_anim = null
	///If true, this storage will sort the first 8 items on open for access QOL
	var/autosorting = TRUE

	var/list/spawn_contents = list() // maybe better than just a bunch of stuff in New()?
	var/made_stuff

	var/grab_stuff_on_spawn = TRUE

	///Controls items that are 'inside' the crate, even when it's open. These will be dragged around with the crate until removed.
	var/datum/vis_storage_controller/vis_controller

	New()
		..()
		START_TRACKING
		weld_image = image(src.icon, src.icon_welded)
		weld_image.pixel_x = weld_image_offset_X
		weld_image.pixel_y = weld_image_offset_Y
		SPAWN_DBG(1 DECI SECOND)
			src.update_icon()

			if (!src.open && grab_stuff_on_spawn)		// if closed, any item at src's loc is put in the contents
				for (var/atom/movable/A in src.loc)
					if (src.is_acceptable_content(A))
						A.set_loc(src)

	disposing()
		if(src.vis_controller)
			qdel(src.vis_controller)
			src.vis_controller = null
		STOP_TRACKING
		..()

	proc/make_my_stuff() // use this rather than overriding the container's New()
		. = 1
		if (!islist(src.spawn_contents))
			return 0

		for (var/thing in src.spawn_contents)
			var/amt = 1
			if (!ispath(thing))
				continue
			if (isnum(spawn_contents[thing])) //Instead of duplicate entries in the list, let's make them associative
				amt = abs(spawn_contents[thing])
			do new thing(src)	//Two lines! I TOLD YOU I COULD DO IT!!!
			while (--amt > 0)

	proc/update_icon()
		if (src.open)
			flick(src.opening_anim,src)
			src.icon_state = src.icon_opened
		else if (!src.open)
			flick(src.closing_anim,src)
			src.icon_state = src.icon_closed

		if (src.welded)
			src.UpdateOverlays(weld_image, "welded")
		else
			src.UpdateOverlays(null, "welded")

	emp_act()
		if (!src.open && length(src.contents))
			for (var/atom/A in src.contents)
				if (ismob(A))
					var/mob/M = A
					M.emp_act()
				if (isitem(A))
					var/obj/item/I = A
					I.emp_act()

	alter_health()
		. = get_turf(src)

	relaymove(mob/user as mob)
		if (is_incapacitated(user))
			return
		if (world.time < (src.last_relaymove_time + RELAYMOVE_DELAY))
			return
		src.last_relaymove_time = world.time

		if (!src.open())
			if (!src.is_short && src.legholes)
				step(src, pick(alldirs))
			if (!src.jiggled)
				src.jiggled = 1
				user.show_text("You kick at [src], but it doesn't budge!", "red")
				//user.unlock_medal("IT'S A TRAP", 1)
				for (var/mob/M in hearers(src, null))
					M.show_text("<font size=[max(0, 5 - get_dist(src, M))]>THUD, thud!</font>")
				playsound(src, "sound/impact_sounds/Wood_Hit_1.ogg", 15, 1, -3)
				var/shakes = 5
				while (shakes > 0)
					shakes--
					src.pixel_x = rand(-5,5)
					src.pixel_y = rand(-5,5)
					sleep(0.1 SECONDS)
				src.pixel_x = 0
				src.pixel_y = 0
				SPAWN_DBG(0.5 SECONDS)
					src.jiggled = 0

			if (prob(10) && src.can_flip_bust)
				user.show_text("<span class='alert'>[src] [pick("cracks","bends","shakes","groans")].</span>")
				src.bust_out()

			return

		else if (prob(src.open_fail_prob))
			if (src.legholes)
				step(src,user.dir)
			user.show_text("You kick at [src], but it doesn't budge!", "red")
			return

		// if all else fails:
		src.open()
		src.visible_message("<span class='alert'><b>[user]</b> kicks [src] open!</span>")

	attack_hand(mob/user as mob)
		if (!in_interact_range(src, user))
			return

		interact_particle(user,src)
		add_fingerprint(user)
		if (src.welded)
			user.show_text("It won't open!", "red")
			return
		else if (!src.toggle(user))
			return src.Attackby(null, user)

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/cargotele))
			var/obj/item/cargotele/CT = W
			CT.cargoteleport(src, user)
			return

		else if (istype(W, /obj/item/satchel/))
			var/amt = length(W.contents)
			if (amt)
				user.visible_message("<span class='notice'>[user] dumps out [W]'s contents into [src]!</span>")
				var/amtload = 0
				for (var/obj/item/I in W.contents)
					if (open)
						I.set_loc(src.loc)
					else
						I.set_loc(src)
					amtload++
					W:curitems -= I.amount
				W:satchel_updateicon()
				if (amtload)
					user.show_text("[amtload] [W:itemstring] dumped into [src]!", "blue")
				else
					user.show_text("No [W:itemstring] dumped!", "red")
				return

		if (src.open)
			if (!src.is_short && isweldingtool(W))
				if (!src.legholes)
					if(!W:try_weld(user, 1))
						return
					src.legholes = 1
					src.visible_message("<span class='alert'>[user] adds some holes to the bottom of [src] with [W].</span>")
					return
				else if(!issilicon(user))
					if(user.drop_item())
						if (W)
							W:set_loc(src.loc)
					return

			else if (iswrenchingtool(W))
				actions.start(new /datum/action/bar/icon/storage_disassemble(src, W), user)
				return
			else if (!issilicon(user))
				if (istype(W, /obj/item/grab))
					return src.MouseDrop_T(W:affecting, user)	//act like they were dragged onto the closet
				if(user.drop_item())
					if(W) W.set_loc(src.loc)
				return

		else if (!src.open && isweldingtool(W))
			if(!W:try_weld(user, 1, burn_eyes = 1))
				return
			if (!src.welded)
				src.weld(1, W, user)
				src.visible_message("<span class='alert'>[user] welds [src] closed with [W].</span>")
			else
				src.weld(0, W, user)
				src.visible_message("<span class='alert'>[user] unwelds [src] with [W].</span>")
			return

		if (src.secure)
			if (src.emagged)
				user.show_text("It appears to be broken.", "red")
				return
			else if (src.personal && istype(W, /obj/item/card/id))
				var/obj/item/card/id/I = W
				if ((src.req_access && src.allowed(user)) || !src.registered || (istype(W, /obj/item/card/id) && src.registered == I.registered))
					//they can open all lockers, or nobody owns this, or they own this locker
					src.locked = !( src.locked )
					user.visible_message("<span class='notice'>The locker has been [src.locked ? null : "un"]locked by [user].</span>")
					src.update_icon()
					if (!src.registered)
						src.registered = I.registered
						src.name = "[I.registered]'s [src.name]"
						src.desc = "Owned by [I.registered]."
					for (var/mob/M in src.contents)
						src.log_me(user, M, src.locked ? "locks" : "unlocks")
					return
			else if (!src.personal && src.allowed(user))
				if (!src.open)
					src.locked = !src.locked
					user.visible_message("<span class='notice'>[src] has been [src.locked ? null : "un"]locked by [user].</span>")
					src.update_icon()
					for (var/mob/M in src.contents)
						src.log_me(user, M, src.locked ? "locks" : "unlocks")
					return
				else
					src.close()
					return

			if (secure != 2)
				user.show_text("Access Denied", "red")
			user.unlock_medal("Rookie Thief", 1)
			return

		else
			return ..()

	proc/check_if_enterable(var/mob/living/L, var/skip_penalty=0)
		//return 1 if a mob can enter, 0 if not
		if(istype(L) && L.buckled)
			return 0
		var/turf/T = get_turf(src)
		var/no_go = 0
		if (T.density)
			no_go = T
		else
			for (var/obj/thingy in T)
				if (thingy == src)
					continue
				if (istype(thingy, /obj/storage) && thingy:is_short)
					continue
				if (thingy.density)
					no_go = thingy
					break

		if (no_go) // no more scooting around walls and doors okay
			if(!skip_penalty && istype(L))
				L.visible_message("<span class='alert'><b>[L]</b> scoots around [src], right into [no_go]!</span>",\
				"<span class='alert'>You scoot around [src], right into [no_go]!</span>")
				if (!L.hasStatus("weakened"))
					L.changeStatus("weakened", 4 SECONDS)
				if (prob(25))
					L.show_text("You hit your head on [no_go]!", "red")
					L.TakeDamage("head", 10, 0, 0, DAMAGE_BLUNT)

			. = 0
		else
			. = 1

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		var/turf/T = get_turf(src)
		if (!in_interact_range(user, src) || !in_interact_range(user, O) || user.restrained() || user.getStatusDuration("paralysis") || user.sleeping || user.stat || user.lying || isAI(user))
			return

		if (!src.is_acceptable_content(O))
			return

		if (isitem(O) && (O:cant_drop || (issilicon(user) && O.loc == user))) //For borg held items
			boutput(user, "<span class='alert'>You can't put that in [src] when it's attached to you!</span>")
			return

		src.add_fingerprint(user)

		if (src.is_short && O == user)
			if(!check_if_enterable(user))
				return

			if (iscarbon(O))
				var/mob/living/carbon/M = user
				if (M.bioHolder && M.bioHolder.HasEffect("clumsy") && prob(40))
					user.visible_message("<span class='alert'><b>[user]</b> trips over [src]!</span>",\
					"<span class='alert'>You trip over [src]!</span>")
					playsound(user.loc, 'sound/impact_sounds/Generic_Hit_2.ogg', 15, 1, -3)
					user.set_loc(src.loc)
					if (!user.hasStatus("weakened"))
						user.changeStatus("weakened", 10 SECONDS)
					JOB_XP(user, "Clown", 3)
					return
				else
					user.show_text("You scoot around [src].")
					user.set_loc(src.loc)
					return
			if (issilicon(O))
				user.show_text("You scoot around [src].")
				user.set_loc(src.loc)
				return

		if (src.locked)
			user.show_text("You'll have to unlock [src] first.", "red")
			return

		if (src.welded)
			user.show_text("[src] is welded shut!", "red")
			return

		if (!src.open)
			src.open()

		if (T.contents.len >= src.max_capacity)
			user.show_text("[src] is too full!", "red")
			return

		if (O.loc == user)
			var/obj/item/I = O
			if(istype(I) && I.cant_drop)
				return
			if(istype(I) && I.equipped_in_slot && I.cant_self_remove)
				return
			user.u_equip(O)
			O.set_loc(get_turf(user))

		else if(istype(O.loc, /obj/item/storage))
			var/obj/item/storage/storage = O.loc
			O.set_loc(get_turf(O))
			storage.hud.remove_item(O)

		SPAWN_DBG(0.5 SECONDS)
			var/stuffed = FALSE
			var/list/draggable_types = list(
				/obj/item/plant = "produce",
				/obj/item/reagent_containers/food/snacks = "food",
				/obj/item/casing = "ammo casings",
				/obj/item/raw_material = "materials",
				/obj/item/material_piece = "processed materials",
				/obj/item/paper = "paper",
				/obj/item/tile = "floor tiles")
			for(var/drag_type in draggable_types)
				if(!istype(O, drag_type))
					continue
				stuffed = TRUE
				var/type_name = draggable_types[drag_type]
				user.visible_message("<span class='notice'>[user] begins quickly stuffing [type_name] into [src]!</span>",\
				"<span class='notice'>You begin quickly stuffing [type_name] into [src]!</span>")
				var/staystill = user.loc
				for (var/obj/thing in view(1,user))
					if(!istype(thing, drag_type))
						continue
					if (thing.material && thing.material.getProperty("radioactive") > 0)
						user.changeStatus("radiation", (round(min(thing.material.getProperty("radioactive") / 2, 20))) SECONDS, 2)
					if (thing in user)
						continue
					if (thing.loc == src || thing.loc == src.loc) // we're already there!
						continue
					thing.set_loc(src.loc)
					sleep(0.5)
					if (!src.open)
						break
					if (user.loc != staystill)
						break
					if (T.contents.len >= src.max_capacity)
						break
				user.show_text("You finish stuffing [type_name] into [src]!", "blue")
				SPAWN_DBG(0.5 SECONDS)
					if (src.open)
						src.close()
			if(!stuffed)
				if(check_if_enterable(O))
					O.set_loc(src.loc)
					if (user != O)
						user.visible_message("<span class='alert'>[user] stuffs [O] into [src]!</span>",\
						"<span class='alert'>You stuff [O] into [src]!</span>")
					SPAWN_DBG(0.5 SECONDS)
						if (src.open)
							src.close()
		return ..()

	attack_ai(mob/user)
		if (can_reach(user, src) <= 1 && (isrobot(user) || isshell(user)))
			. = src.Attackhand(user)

	alter_health()
		. = get_turf(src)

	CanPass(atom/movable/mover, turf/target)
		. = open
		if (src.is_short)
			return 0

	ex_act(severity)
		switch (severity)
			if (OLD_EX_SEVERITY_1)
				dump_contents(null, FALSE, TRUE) //dump as in delete
				qdel(src)
			if (OLD_EX_SEVERITY_2)
				if (prob(50))
					dump_contents(null, FALSE) //Don't lazy init contents (but if the locker's been opened already it'll get dumped anyway)
					qdel(src)
			if (OLD_EX_SEVERITY_3)
				if (prob(5))
					dump_contents()
					qdel(src)

	blob_act(var/power)
		if (prob(power * 2.5))
			dump_contents()
			qdel(src)

	meteorhit(obj/O as obj)
		if(istype(O,/obj/newmeteor/))
			if(O.icon_state == "flaming")
				src.dump_contents()
				qdel(src)
		else
			src.dump_contents()
			qdel(src)
		return

	proc/is_acceptable_content(var/atom/A)
		. = TRUE
		if (!A || !(isobj(A) || ismob(A)))
			return 0
		if (istype(A, /obj/decal/skeleton)) // uuuuuuugh
			return 1
		if (isobj(A) && ((A.density && !istype(A, /obj/critter)) || A:anchored || A:cannot_be_stored || A == src || istype(A, /obj/decal) || istype(A, /atom/movable/screen) || istype(A, /obj/storage)))
			return 0

	var/obj/storage/entangled
	proc/open(var/entangleLogic, var/mob/user)
		if (src.open)
			return 0
		if (!src.can_open())
			return 0
		else
			flick(src.opening_anim,src)

		if(entangled && !entangleLogic && !entangled.can_close())
			visible_message("<span class='alert'>It won't budge!</span>")
			return 0

		if(entangled && !entangleLogic)
			entangled.entangled = src
			entangled.close(1)
			for(var/atom/movable/AM in entangled)
				AM.set_loc(src.open ? src.loc : src)

		src.dump_contents(user)
		src.open = 1
		src.update_icon()
		p_class = initial(p_class)
		playsound(src.loc, src.open_sound, 15, 1, -3)
		return 1

	proc/close(var/entangleLogic)
		flick(src.closing_anim,src)
		if (!src.open)
			return 0
		if (!src.can_close())
			visible_message("<span class='alert'>[src] can't close; looks like it's too full!</span>")
			return 0
		if (!src.intact_frame())
			visible_message("<span class='alter'>[src] can't close; the door is completely bend out of shape!</span>")
			return 0

		if(entangled && !entangleLogic && !entangled.can_open())
			visible_message("<span class='alert'>It won't budge!</span>")
			return 0

		src.open = 0

		for (var/obj/O in get_turf(src))
			if (src.is_acceptable_content(O))
				O.set_loc(src)
		vis_controller?.hide()
		for (var/mob/M in get_turf(src))
			if (M.anchored || M.buckled)
				continue
			if (src.is_short && !M.lying && ( M != src.loc ) ) // ignore movement when container is inside the mob (possessed)
				step_away(M, src, 1)
				continue
#ifdef HALLOWEEN
			if (halloween_mode && prob(5)) //remove the prob() if you want, it's just a little broken if dudes are constantly teleporting
				var/list/obj/storage/myPals = list()
				for_by_tcl(O, /obj/storage)
					if (O.z != src.z || O.open || !O.can_open())
						continue
					myPals.Add(O)

				var/obj/storage/warp_dest = pick(myPals)
				M.set_loc(warp_dest)
				M.show_text("You are suddenly thrown elsewhere!", "red")
				M.playsound_local(M.loc, "warp", 50, 1)
				continue
#endif
			if (isobserver(M) || iswraith(M) || isintangible(M) || istype(M, /mob/living/object))
				continue
			if (src.crunches_contents)
				src.crunch(M)
			M.set_loc(src)

		recalcPClass()

		if(entangled && !entangleLogic)
			entangled.entangled = src
			for(var/atom/movable/AM in src)
				AM.set_loc(entangled.open ? entangled.loc : entangled)
			entangled.open(1)

		src.update_icon()
		playsound(src.loc, src.close_sound, 15, 1, -3)
		return 1

	proc/recalcPClass()
		var/maxPClass = 0
		for (var/atom/movable/O in contents)
			if (ishuman(O)) // can't use p_class for human mobs as we need to use the heavier one regardless of whether they're standing/lying down
				maxPClass = max(maxPClass, 3) //horay magic number
			else
				maxPClass = max(maxPClass, O.p_class)
		p_class = initial(p_class) + maxPClass

	proc/can_open()
		. = TRUE
		if (src.welded || src.locked)
			return 0

	proc/can_close()
		. = TRUE
		var/turf/T = get_turf(src)
		if (!T) return 0
		if (T.contents.len > src.max_capacity)
			return 0
		for (var/obj/storage/S in T)
			if (S != src)
				return 0

	proc/intact_frame()
		. = TRUE
		if (!src.intact_frame)
			return 0

	//Normally contents are dumped on the floor
	//The do_lazy_init skips spawning default contents if the locker hasn't been opened yet, I'm kinda tired of seeing neat stacks of storage contents in the wake of giant explosions
	//delete_and_damage deletes objects and hurts mobs, for when a storage blows up so badly that whatever's inside probably shouldn't survive either
	proc/dump_contents(var/mob/user, do_lazy_init = TRUE, delete_and_damage = FALSE)
		if (do_lazy_init)
			if(src.spawn_contents && make_my_stuff()) //Make the stuff when the locker is first opened.
				spawn_contents = null

		//2023-5-30: Let's trial some auto-sorting QOL on these
		if (src.autosorting && !delete_and_damage)
			var/start_py = 10
			var/start_px = -11
			var/items = 1
			for (var/obj/item/I in contents) //Wanna skip mobs, wanna skip non-items
				if ((I in vis_controller?.vis_items))
					continue
				if (items > 8)
					I.pixel_y = min(0,pixel_y) //try to keep the bottom of the cart sprite free, clicking stuffed crates is a goddamn pain
				else
					I.pixel_x = start_px //If you did custom pixel offsets in make_my_stuff or in the map
					I.pixel_y = start_py //Sorry but they're getting nuked
					start_px += 7
					if (items == 4) //shit's hardcoded, sue me
						start_px = -11
						start_py = 0
				items++

		var/newloc = get_turf(src)
		vis_controller?.show()
		for (var/obj/O in src)
			if (delete_and_damage)
				qdel(O)
				continue
			if (!(O in vis_controller?.vis_items))
				O.set_loc(newloc)
			if(istype(O,/obj/item/mousetrap))
				var/obj/item/mousetrap/our_trap = O
				if(our_trap.armed && user)
					INVOKE_ASYNC(our_trap, TYPE_PROC_REF(/obj/item/mousetrap, triggered),user)

		for (var/mob/M in src)
			M.set_loc(newloc)
			if (delete_and_damage) //Mobs just get hurt cause no deleting players
				random_burn_damage(M, 15)
				random_brute_damage(M, 15) //Mix of burn/brute feels appropriate for explosion, but the numbers are arbitrary picks

	proc/toggle(var/mob/user)
		if (src.open)
			return src.close()
		if (user)
			return src.open(null,user)
		return src.open()

	proc/unlock()
		if (src.locked)
			src.locked = !src.locked

	proc/bust_out()
		if (src.health)
			src.visible_message("<span class='alert'>[src] [pick("cracks","bends","shakes","groans")].</span>")
			src.health--
		if (src.health <= 0)
			src.visible_message("<span class='alert'>[src] breaks apart!</span>")
			src.dump_contents()
			SPAWN_DBG(1 DECI SECOND)
				var/newloc = get_turf(src)
				make_cleanable( /obj/decal/cleanable/machine_debris,newloc)
				qdel(src)

	proc/weld(var/shut = 0, var/obj/item/weldingtool/W as obj, var/mob/weldman as mob)
		if (shut)
			weldman.visible_message("<span class='alert'>[weldman] welds [src] shut.</span>")
			src.welded = 1
		else
			weldman.visible_message("<span class='alert'>[weldman] unwelds [src].</span>") // walt-fuck_you.ogg
			src.welded = 0
		src.update_icon()
		for (var/mob/M in src.contents)
			src.log_me(weldman, M, src.welded ? "welds" : "unwelds")
		return

	proc/crunch(var/mob/M as mob)
		if (!M || istype(M, /mob/living/carbon/wall))
			return

		if (M.ckey && (M.ckey == owner_ckey))
			return
		else
			M.show_text("Is it getting... smaller in here?", "red")
			SPAWN_DBG(5 SECONDS)

				var/found = 0
				for (var/mob/contained_mob in src.contents)
					if (M == contained_mob)
						found = 1

				if (found)
					playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 75, 1)
					M.show_text("<b>OH JESUS CHRIST</b>", "red")
					bleed(M, 500, violent = TRUE)
					src.log_me(usr && ismob(usr) ? usr : null, M, "uses trash compactor")
					var/mob/living/carbon/cube/meat/W = M.make_cube(/mob/living/carbon/cube/meat, rand(10,15), get_turf(src))
					if (src.crunches_deliciously)
						W.name = "hotdog"
						var/obj/item/reagent_containers/food/snacks/hotdog/syndicate/snoopdog = new /obj/item/reagent_containers/food/snacks/hotdog/syndicate(src)
						snoopdog.victim = W

					for (var/obj/item/I in M)
						if (istype(I, /obj/item/implant))
							I.set_loc(W)
							continue

						I.set_loc(src)

					src.locked = 0
					src.open()

	// Added (Convair880).
	proc/log_me(var/mob/user, var/mob/occupant, var/action = "")
		if (!src || !occupant || !ismob(occupant) || !action)
			return

		logTheThing("station", user, occupant, "[action] [src] with [constructTarget(occupant,"station")] inside at [log_loc(src)].")
		return

	verb/toggle_verb()
		set src in oview(1)
		set name = "Open / Close"
		set desc = "Open or close the closet/crate/whatever. Woah!"
		set category = "Local"

		if (usr.stat || !usr.can_use_hands() || isAI(usr))
			return

		return toggle()

	verb/move_inside()
		set src in oview(1)
		set name = "Move Inside"
		set desc = "Enter the closet/crate/whatever. Wow!"
		set category = "Local"

		if (usr.stat || !usr.can_use_hands() || usr.loc == src || isAI(usr))
			return

		if (src.locked)
			return

		if (src.open)
			step_towards(usr, src)
			sleep(1 SECOND)
			if (usr.loc == src.loc)
				if (src.is_short)
					usr.lying = 1
				src.close()
		else if (src.open())
			step_towards(usr, src)
			sleep(1 SECOND)
			if (usr.loc == src.loc)
				if (src.is_short)
					usr.lying = 1
				src.close()
		return

	mob_flip_inside(var/mob/user)
		..(user)
		if (prob(33) && src.can_flip_bust)
			user.show_text("<span class='alert'>[src] [pick("cracks","bends","shakes","groans")].</span>")
			src.bust_out()

/datum/action/bar/icon/storage_disassemble
	id = "storage_disassemble"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 20
	icon = 'icons/obj/items/tools/tools.dmi'
	icon_state = "wrench"

	var/obj/storage/the_storage
	var/obj/item/wrench/the_wrench

	New(var/obj/storage/S, var/obj/item/wrench/W, var/duration_i)
		..()
		if (S)
			the_storage = S
		if (W)
			the_wrench = W
			icon = the_wrench.icon
			icon_state = the_wrench.icon_state
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (!the_storage || !the_wrench || !owner || get_dist(owner, the_storage) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_wrench != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		playsound(the_storage, "sound/items/Ratchet.ogg", 50, 1)
		owner.visible_message("<span class='notice'>[owner] begins taking apart [the_storage].</span>")

	onEnd()
		..()
		playsound(the_storage, "sound/items/Deconstruct.ogg", 50, 1)
		owner.visible_message("<span class='notice'>[owner] takes apart [the_storage].</span>")
		var/obj/item/I = new /obj/item/sheet(get_turf(the_storage))
		if (the_storage.material)
			I.setMaterial(the_storage.material)
		else
			var/datum/material/M = getMaterial("steel")
			I.setMaterial(M)
		qdel(the_storage)


/obj/storage/secure
	name = "secure storage"
	icon_state = "secure"
	health = 6
	secure = 1
	locked = 1
	icon_closed = "secure"
	icon_opened = "secure-open"
	var/icon_greenlight = "greenlight"
	var/icon_redlight = "redlight"
	var/icon_sparks = "sparks"
	var/always_display_locks = 0
	var/datum/radio_frequency/radio_control = 1431
	var/net_id

	New()
		..()
		SPAWN_DBG(1 SECOND)
			if (isnum(src.radio_control) && radio_controller)
				radio_control = max(1000, min(round(radio_control), 1500))
				src.net_id = generate_net_id(src)
				radio_controller.add_object(src, "[src.radio_control]")
				src.radio_control = radio_controller.return_frequency("[src.radio_control]")

	update_icon()
		..()
		if (!src.open)
			src.icon_state = src.icon_closed

		if(!src.open || always_display_locks)
			if (src.emagged)
				var/image/sparks = image(src.icon, src.icon_sparks)
				sparks.plane = PLANE_SELFILLUM
				src.UpdateOverlays(sparks, "sparks")
				src.UpdateOverlays(null, "light")
			else if (src.locked)
				var/image/redlight = image(src.icon, src.icon_redlight)
				redlight.plane = PLANE_SELFILLUM
				src.UpdateOverlays(redlight, "light")
			else
				var/image/greenlight = image(src.icon, src.icon_greenlight)
				greenlight.plane = PLANE_SELFILLUM
				src.UpdateOverlays(greenlight, "light")
		else
			src.UpdateOverlays(null, "sparks")
			src.UpdateOverlays(null, "light")

	receive_signal(datum/signal/signal)
		if (!src.radio_control)
			return

		var/sender = signal.data["sender"]
		if (!signal || signal.encryption || !sender)
			return

		if (signal.data["address_1"] == src.net_id)
			var/datum/signal/reply = get_free_signal()
			reply.source = src
			reply.transmission_method = TRANSMISSION_RADIO
			reply.data["sender"] = src.net_id
			reply.data["address_1"] = sender
			switch (lowertext(signal.data["command"]))
				if ("help")
					if (!signal.data["topic"])
						reply.data["description"] = "Secure Storage"
						reply.data["topics"] = "status,lock,unlock"
					else
						reply.data["topic"] = signal.data["topic"]
						switch (lowertext(signal.data["topic"]))
							if ("status")
								reply.data["description"] = "Returns the status of the secure storage. No arguments"
							if ("lock")
								reply.data["description"] = "Locks the secure storage. Requires NETPASS_SECURITY"
								reply.data["args"] = "pass"
							if ("unlock")
								reply.data["description"] = "Unlocks the secure storage. Requires NETPASS_SECURITY"
								reply.data["args"] = "pass"
							else
								reply.data["description"] = "ERROR: UNKNOWN TOPIC"
				if ("status")
					reply.data["command"] = "lock=[locked]&open=[open]"
				if ("lock")
					. = 0
					if (signal.data["pass"] == netpass_security)
						. = 1
						src.locked = !src.locked
						src.visible_message("[src] clicks[src.open ? "" : " locked"].")
						src.update_icon()
					if (.)
						reply.data["command"] = "ack"
					else
						reply.data["command"] = "nack"
						reply.data["data"] = "badpass"
				if ("unlock")
					. = 0
					if (signal.data["pass"] == netpass_security)
						. = 1
						src.locked = !src.locked
						src.visible_message("[src] clicks[src.open ? "" : " unlocked"].")
						src.update_icon()
					if (.)
						reply.data["command"] = "ack"
					else
						reply.data["command"] = "nack"
						reply.data["data"] = "badpass"
				else
					return //COMMAND NOT RECOGNIZED
			SPAWN_DBG(0.5 SECONDS)
				src.radio_control.post_signal(src, reply, 2)

		else if (signal.data["address_1"] == "ping")
			var/datum/signal/reply = get_free_signal()
			reply.source = src
			reply.transmission_method = TRANSMISSION_RADIO
			reply.data["address_1"] = sender
			reply.data["command"] = "ping_reply"
			reply.data["device"] = "WNET_SECLOCKER"
			reply.data["netid"] = src.net_id
			SPAWN_DBG(0.5 SECONDS)
				src.radio_control.post_signal(src, reply, 2)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.emagged) // secure crates checked for being locked/welded but so long as you aren't telling the thing to open I don't see why that was needed
			src.emagged = 1
			src.locked = 0
			src.update_icon()
			playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
			if (user)
				user.show_text("You short out the lock on [src].", "blue")
			return 1
		return 0

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		else if (src.emagged)
			src.emagged = 0
			src.update_icon()
			if (user)
				user.show_text("You repair the lock on [src].", "blue")
			return 1

#undef RELAYMOVE_DELAY

