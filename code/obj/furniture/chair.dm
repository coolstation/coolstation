/* ================================================ */
/* -------------------- Chairs -------------------- */
/* ================================================ */

/obj/stool/chair
	name = "chair"
	desc = "A four-legged metal chair, rigid and slightly uncomfortable. Helpful when you don't want to use your legs at the moment."
	icon_state = "chair"
	var/comfort_value = 3
	var/buckledIn = 0
	var/status = 0
	var/rotatable = 1
	var/foldable = 1
	var/climbable = 1
	var/buckle_move_delay = 6 // this should have been a var somepotato WHY WASN'T IT A VAR
	var/obj/item/clothing/head/butt/has_butt = null // time for mature humour
	var/image/butt_img
	var/lying = FALSE
	var/list/scoot_sounds_original
	event_handler_flags = STAIR_ANIM | USE_FLUID_ENTER
	securable = 1
	anchored = 1
	scoot_sounds = list( 'sound/misc/chair/normal/scoot1.ogg', 'sound/misc/chair/normal/scoot2.ogg', 'sound/misc/chair/normal/scoot3.ogg', 'sound/misc/chair/normal/scoot4.ogg', 'sound/misc/chair/normal/scoot5.ogg' )
	parts_type = null

	moveable
		anchored = 0

	New()
		if (src.dir == NORTH)
			src.layer = FLY_LAYER+1
		butt_img = image('icons/obj/furniture/chairs.dmi')
		butt_img.layer = OBJ_LAYER + 0.5 //In between OBJ_LAYER and MOB_LAYER
		src.scoot_sounds_original = src.scoot_sounds
		..()
		return


	proc/fall_over(var/turf/T)
		if (src.lying)
			return
		if (src.stool_user)
			var/mob/living/M = src.stool_user
			src.unbuckle()
			if (M && !src.stool_user)
				M.visible_message("<span class='alert'>[M] is tossed out of [src] as it tips [T ? "while rolling over [T]" : "over"]!</span>",\
				"<span class='alert'>You're tossed out of [src] as it tips [T ? "while rolling over [T]" : "over"]!</span>")
				var/turf/target = get_edge_target_turf(src, src.dir)
				M.throw_at(target, 5, 1)
				M.changeStatus("stunned", 8 SECONDS)
				M.changeStatus("weakened", 5 SECONDS)
				M.force_laydown_standup()
			else
				src.visible_message("<span class='alert'>[src] tips [T ? "as it rolls over [T]" : "over"]!</span>")
		else
			src.visible_message("<span class='alert'>[src] tips [T ? "as it rolls over [T]" : "over"]!</span>")
		src.lying = 1
		animate_rest(src, !src.lying)
		src.p_class = initial(src.p_class) + src.lying // 2 while standing, 3 while lying
		src.scoot_sounds = list("sound/misc/chair/normal/scoot1.ogg", "sound/misc/chair/normal/scoot2.ogg", "sound/misc/chair/normal/scoot3.ogg", "sound/misc/chair/normal/scoot4.ogg", "sound/misc/chair/normal/scoot5.ogg")

	Move()
		. = ..()
		if (.)
			if (src.dir == NORTH)
				src.layer = FLY_LAYER+1
			else
				src.layer = OBJ_LAYER

			if (src.stool_user)
				var/mob/living/carbon/C = src.stool_user
				C.buckled = null
				C.Move(src.loc)
				C.buckled = src

	toggle_secure(mob/user as mob)
		if (istype(get_turf(src), /turf/space))
			if (user)
				user.show_text("What exactly are you gunna secure [src] to?", "red")
			return
		if (user)
			user.visible_message("<b>[user]</b> [src.anchored ? "unscrews [src] from" : "secures [src] to"] the floor.")
		playsound(src, "sound/items/Screwdriver.ogg", 100, 1)
		src.anchored = !(src.anchored)
		src.p_class = src.anchored ? initial(src.p_class) : 2
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (ispryingtool(W) && has_butt)
			user.put_in_hand_or_drop(has_butt)
			boutput(user, "<span class='notice'>You pry [has_butt.name] from [name].</span>")
			has_butt = null
			UpdateOverlays(null, "chairbutt")
			return
		if (istype(W, /obj/item/clothing/head/butt) && !has_butt)
			has_butt = W
			user.u_equip(has_butt)
			has_butt.set_loc(src)
			boutput(user, "<span class='notice'>You place [has_butt.name] on [name].</span>")
			butt_img.icon_state = "chair_[has_butt.icon_state]"
			UpdateOverlays(butt_img, "chairbutt")
			return
		if (istype(W, /obj/item/assembly/shock_kit))
			var/obj/stool/chair/e_chair/E = new /obj/stool/chair/e_chair(src.loc)
			if (src.material)
				E.setMaterial(src.material)
			playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
			E.set_dir(src.dir)
			E.part1 = W
			W.set_loc(E)
			W.master = E
			user.u_equip(W)
			W.layer = initial(W.layer)
			qdel(src)
			return
		else
			return ..()

	attack_hand(mob/user as mob)
		if (src.lying)
			user.visible_message("[user] sets [src] back on its wheels.",\
			"You set [src] back on its wheels.")
			src.lying = 0
			animate_rest(src, !src.lying)
			src.p_class = initial(src.p_class) + src.lying // 2 while standing, 3 while lying
			src.scoot_sounds = src.scoot_sounds_original
			return
		if (!ishuman(user)) return
		var/mob/living/carbon/human/H = user
		var/mob/living/carbon/human/chump = null
		for (var/mob/M in src.loc)

			if (ishuman(M))
				chump = M
			if (!chump || !chump.on_chair)// == 1)
				chump = null
			if (H.on_chair)// == 1)
				if (M == user)
					user.visible_message("<span class='notice'><b>[M]</b> steps off [H.on_chair].</span>", "<span class='notice'>You step off [src].</span>")
					src.add_fingerprint(user)
					unbuckle()
					return

			if ((M.buckled) && (!H.on_chair))
				if (locked)
					if(user.restrained())
						return
					if (M != user)
						user.visible_message("<span class='notice'><b>[M]</b> is unbuckled by [user].</span>", "<span class='notice'>You unbuckle [M].</span>")
					else
						user.visible_message("<span class='notice'><b>[M]</b> unbuckles.</span>", "<span class='notice'>You unbuckle.</span>")
					src.add_fingerprint(user)
					unbuckle()
					return
				else
					user.show_text("Seems like the buckle is firmly locked into place.", "red")
					return

		if (!src.buckledIn)
			if (src.foldable)
				user.visible_message("<b>[user.name] folds [src].</b>")
				if ((chump) && (chump != user))
					chump.visible_message("<span class='alert'><b>[chump.name] falls off of [src]!</b></span>")
					chump.on_chair = 0
					chump.pixel_y = 0
					chump.ceilingreach = 0
					chump.lookingup = 0
					chump.changeStatus("weakened", 1 SECOND)
					chump.changeStatus("stunned", 2 SECONDS)
					random_brute_damage(chump, 15)
					playsound(chump.loc, "swing_hit", 50, 1)

				var/obj/item/chair/folded/C = new/obj/item/chair/folded(src.loc)
				if (src.material)
					C.setMaterial(src.material)
				if (src.icon_state)
					C.c_color = src.icon_state
					C.icon_state = "folded_[src.icon_state]"
					C.item_state = C.icon_state

				qdel(src)
			else
				src.rotate()
		return

	MouseDrop_T(mob/M as mob, mob/user as mob)
		..()
		if (M == user)
			buckle_in(M,user,user.a_intent == INTENT_GRAB)
		else
			buckle_in(M,user)
			if (isdead(M) && M != user && emergency_shuttle?.location == SHUTTLE_LOC_STATION) // 1 should be SHUTTLE_LOC_STATION
				var/area/shuttle/escape/station/A = get_area(M)
				if (istype(A))
					user.unlock_medal("Leave no man behind!", 1)
		return

	MouseDrop(atom/over_object as mob|obj)
		if(get_dist(src,usr) <= 1)
			src.rotate(get_dir(get_turf(src),get_turf(over_object)))
		..()

	can_buckle(var/mob/M, var/mob/user)
		if (!ticker)
			boutput(user, "You can't buckle anyone in before the game starts.")
			return 0
		if (M.buckled)
			boutput(user, "They're already buckled into something!", "red")
			return 0
		if (get_dist(src, user) > 1 || M.loc != src.loc || user.restrained() || !isalive(user))
			return 0
		if(src.stool_user && src.stool_user.buckled == src && src.stool_user != M)
			user.show_text("There's already someone buckled in [src]!", "red")
			return 0
		return 1

	buckle_in(mob/living/to_buckle, mob/living/user, var/stand = 0)
		if (src.lying)
			user.visible_message("[user] sets [src] back on its wheels.",\
			"You set [src] back on its wheels.")
			src.lying = 0
			animate_rest(src, !src.lying)
			src.p_class = initial(src.p_class) + src.lying // 2 while standing, 3 while lying
			src.scoot_sounds = src.scoot_sounds_original
			return
		if(!istype(to_buckle))
			return
		if(user.hasStatus("weakened"))
			return
		if(src.stool_user && src.stool_user.buckled == src && to_buckle != src.stool_user) return

		if (!can_buckle(to_buckle,user))
			return

		if(stand)
			if(ishuman(to_buckle))
				if(ON_COOLDOWN(to_buckle, "chair_stand", 1 SECOND))
					return
				if(!src.climbable)
					boutput(user, "<span class='alert'>[src] isn't climbable.</span>")
					return
				user.visible_message("<span class='notice'><b>[to_buckle]</b> climbs up on [src]!</span>", "<span class='notice'>You climb up on [src].</span>")

				var/mob/living/carbon/human/H = to_buckle
				to_buckle.set_loc(src.loc)
				to_buckle.pixel_y = 10
				H.ceilingreach = 1
				H.lookingup = 1
				if (src.anchored)
					to_buckle.anchored = 1
				H.on_chair = src
				to_buckle.buckled = src
				src.stool_user = to_buckle
				src.buckledIn = 1
				to_buckle.setStatus("buckled", duration = INFINITE_STATUS)
				H.start_chair_flip_targeting()
		else
			if (to_buckle == user)
				user.visible_message("<span class='notice'><b>[to_buckle]</b> buckles in!</span>", "<span class='notice'>You buckle yourself in.</span>")
			else
				user.visible_message("<span class='notice'><b>[to_buckle]</b> is buckled in by [user].</span>", "<span class='notice'>You buckle in [to_buckle].</span>")

			if (src.anchored)
				to_buckle.anchored = 1
			to_buckle.buckled = src
			src.stool_user = to_buckle
			to_buckle.set_loc(src.loc)
			src.buckledIn = 1
			to_buckle.setStatus("buckled", duration = INFINITE_STATUS)
		if (has_butt)
			playsound(src, (has_butt.sound_fart ? has_butt.sound_fart : 'sound/voice/farts/fart1.ogg'), 50, 1)
		else
			playsound(src, "sound/misc/belt_click.ogg", 50, 1)
		RegisterSignal(to_buckle, COMSIG_MOVABLE_SET_LOC, PROC_REF(maybe_unbuckle))

	proc/maybe_unbuckle(source, turf/oldloc)
		// unbuckle if the guy is not on a turf, or if their chair is out of range and it's not a shuttle situation
		if(!isturf(stool_user.loc) || (!IN_RANGE(src, oldloc, 1) && (!istype(get_area(src), /area/shuttle || !istype(get_area(oldloc), /area/shuttle)))))
			UnregisterSignal(stool_user, COMSIG_MOVABLE_SET_LOC)
			unbuckle()

	unbuckle()
		..()
		if(!src.stool_user) return
		UnregisterSignal(stool_user, COMSIG_MOVABLE_SET_LOC)

		var/mob/living/M = src.stool_user
		var/mob/living/carbon/human/H = src.stool_user

		M.end_chair_flip_targeting()

		if (istype(H) && H.on_chair)// == 1)
			M.pixel_y = 0
			H.ceilingreach = 0
			H.lookingup = 0
			reset_anchored(M)
			M.buckled = null
			stool_user.force_laydown_standup()
			src.stool_user = null
			SPAWN_DBG(0.5 SECONDS)
				H.on_chair = 0
				src.buckledIn = 0
		else if ((M.buckled))
			reset_anchored(M)
			M.buckled = null
			stool_user.force_laydown_standup()
			src.stool_user = null
			SPAWN_DBG(0.5 SECONDS)
				src.buckledIn = 0

		playsound(src, "sound/misc/belt_click.ogg", 50, 1)

	ex_act(severity)
		for (var/mob/M in src.loc)
			if (M.buckled == src)
				M.buckled = null
				src.stool_user = null
		switch (severity)
			if (OLD_EX_SEVERITY_1)
				qdel(src)
				return
			if (OLD_EX_SEVERITY_2)
				if (prob(50))
					qdel(src)
					return
			if (OLD_EX_SEVERITY_3)
				if (prob(5))
					qdel(src)
					return
		return

	blob_act(var/power)
		if (prob(power * 2.5))
			for (var/mob/M in src.loc)
				if (M.buckled == src)
					M.buckled = null
					src.stool_user = null
			qdel(src)

	disposing()
		for (var/mob/M in src.loc)
			if (M.buckled == src)
				M.buckled = null
				src.stool_user = null
		if (has_butt)
			has_butt.set_loc(loc)
		has_butt = null
		..()
		return

	Move(atom/target)
		if(src.stool_user?.loc != src.loc)
			src.unbuckle()
		. = ..()
		if(src.stool_user?.loc != src.loc)
			src.unbuckle()

	Click(location,control,params)
		var/lpm = params2list(params)
		if(istype(usr, /mob/dead/observer) && !lpm["ctrl"] && !lpm["shift"] && !lpm["alt"])
			rotate()

#ifdef HALLOWEEN
			if (istype(usr.abilityHolder, /datum/abilityHolder/ghost_observer))
				var/datum/abilityHolder/ghost_observer/GH = usr.abilityHolder
				GH.change_points(3)
#endif
		else return ..()

	proc/rotate(var/face_dir = 0)
		if (rotatable)
			if (!face_dir)
				src.set_dir(turn(src.dir, 90))
			else
				src.set_dir(face_dir)

			update_icon()
			if (stool_user)
				var/mob/living/carbon/C = src.stool_user
				C.set_dir(dir)
		return

	proc/update_icon()
		if (src.dir == NORTH)
			src.layer = FLY_LAYER+1
		else
			src.layer = OBJ_LAYER

	blue
		icon_state = "chair-b"

	yellow
		icon_state = "chair-y"

	red
		icon_state = "chair-r"

	green
		icon_state = "chair-g"

	purple
		icon_state = "chair-p"

	orange
		icon_state = "chair-o"

	dblue
		icon_state = "chair-n"

/* ========================================================== */
/* -------------------- Syndicate Chairs -------------------- */
/* ========================================================== */

/obj/stool/chair/syndicate
	desc = "That chair is giving off some bad vibes."
	comfort_value = -5
	event_handler_flags = USE_PROXIMITY | USE_FLUID_ENTER

	HasProximity(atom/movable/AM as mob|obj)
		if (ishuman(AM) && prob(40))
			src.visible_message("<span class='alert'>[src] trips [AM]!</span>", "<span class='alert'>You hear someone fall.</span>")
			AM:changeStatus("weakened", 2 SECONDS)
		return

/* ===================================================== */
/* -------------------- Wheelchairs -------------------- */
/* ===================================================== */

/obj/stool/chair/comfy/wheelchair
	name = "wheelchair"
	desc = "It's a chair that has wheels attached to it. Do I really have to explain this to you? Can you not figure this out on your own? Wheelchair. Wheel, chair. Chair that has wheels."
	icon_state = "wheelchair"
	arm_icon_state = "arm-wheelchair"
	anchored = 0
	comfort_value = 3
	buckle_move_delay = 1
	p_class = 2
	scoot_sounds = list("sound/misc/chair/office/scoot1.ogg", "sound/misc/chair/office/scoot2.ogg", "sound/misc/chair/office/scoot3.ogg", "sound/misc/chair/office/scoot4.ogg", "sound/misc/chair/office/scoot5.ogg")
	parts_type = /obj/item/furniture_parts/wheelchair
	mat_appearances_to_ignore = list("steel")
	mats = 15
	New()
		..()
		if (src.lying)
			animate_rest(src, !src.lying)
			src.p_class = initial(src.p_class) + src.lying // 2 while standing, 3 while lying

	update_icon()
		ENSURE_IMAGE(src.arm_image, src.icon, src.arm_icon_state)
		src.arm_image.layer = FLY_LAYER+1
		src.UpdateOverlays(src.arm_image, "arm")


	buckle_in(mob/living/to_buckle, mob/living/user, var/stand = 0)
		..()
		if (src.stool_user == to_buckle)
			APPLY_MOVEMENT_MODIFIER(to_buckle, /datum/movement_modifier/wheelchair, src.type)

	unbuckle()
		if(src.stool_user)
			REMOVE_MOVEMENT_MODIFIER(src.stool_user, /datum/movement_modifier/wheelchair, src.type)
		return ..()

	/*set_loc(newloc)
		. = ..()
		unbuckle()
	*/
/* ======================================================= */
/* -------------------- Wooden Chairs -------------------- */
/* ======================================================= */

/obj/stool/chair/wooden
	name = "wooden chair"
	icon_state = "chair_wooden" // this sprite is bad I will fix it at some point
	comfort_value = 3
	foldable = 0
	anchored = 0
	//deconstructable = 0
	parts_type = /obj/item/furniture_parts/wood_chair

	regal
		name = "regal chair"
		desc = "Much more comfortable than the average dining chair, and much more expensive."
		icon_state = "regalchair"
		comfort_value = 7
		parts_type = /obj/item/furniture_parts/wood_chair/regal

/* ======================================================= */
/* -------------------- Office Chairs -------------------- */
/* ======================================================= */

/obj/stool/chair/office
	name = "office chair"
	desc = "Hey, you remember spinning around on one of these things as a kid!"
	icon_state = "office_chair"
	comfort_value = 4
	foldable = 0
	anchored = 0
	buckle_move_delay = 3
	//deconstructable = 0
	parts_type = /obj/item/furniture_parts/office_chair
	scoot_sounds = list( 'sound/misc/chair/office/scoot1.ogg', 'sound/misc/chair/office/scoot2.ogg', 'sound/misc/chair/office/scoot3.ogg', 'sound/misc/chair/office/scoot4.ogg', 'sound/misc/chair/office/scoot5.ogg' )

	red
		icon_state = "office_chair_red"
		parts_type = /obj/item/furniture_parts/office_chair/red

	green
		icon_state = "office_chair_green"
		parts_type = /obj/item/furniture_parts/office_chair/green

	blue
		icon_state = "office_chair_blue"
		parts_type = /obj/item/furniture_parts/office_chair/blue

	yellow
		icon_state = "office_chair_yellow"
		parts_type = /obj/item/furniture_parts/office_chair/yellow

	purple
		icon_state = "office_chair_purple"
		parts_type = /obj/item/furniture_parts/office_chair/purple

	orange
		icon_state = "office_chair_orange"
		parts_type = /obj/item/furniture_parts/office_chair/orange

	lblue
		icon_state = "office_chair_lblue"
		parts_type = /obj/item/furniture_parts/office_chair/lblue

	syndie
		icon_state = "syndiechair"
		parts_type = null

	toggle_secure(mob/user as mob)
		if (user)
			user.visible_message("<b>[user]</b> [src.anchored ? "loosens" : "tightens"] the casters of [src].[istype(src.loc, /turf/space) ? " It doesn't do much, though, since [src] is in space and all." : null]")
		playsound(src, "sound/items/Screwdriver.ogg", 100, 1)
		src.anchored = !(src.anchored)
		return

/* ====================================================== */
/* -------------------- Comfy Chairs -------------------- */
/* ====================================================== */

/obj/stool/chair/comfy
	name = "comfy brown chair"
	desc = "This advanced seat commands authority and respect. Everyone is super envious of whoever sits in this chair."
	icon_state = "chair_comfy"
	comfort_value = 7
	foldable = 0
	deconstructable = 1
//	var/atom/movable/overlay/overl = null
	var/image/arm_image = null
	var/arm_icon_state = "arm"
	parts_type = /obj/item/furniture_parts/comfy_chair

	New()
		..()
		update_icon()
/* what in the unholy mother of god was this about
		src.overl = new /atom/movable/overlay( src.loc )
		src.overl.icon = 'icons/obj/objects.dmi'
		src.overl.icon_state = "arm"
		src.overl.layer = 6// TODO Layer wtf
		src.overl.name = "chair arm"
		src.overl.master = src
		src.overl.set_dir(src.dir)
*/

	update_icon()
		if (src.dir == NORTH)
			src.layer = FLY_LAYER+1
		else
			src.layer = OBJ_LAYER
			if ((src.dir == WEST || src.dir == EAST) && !src.arm_image)
				src.arm_image = image(src.icon, src.arm_icon_state)
				src.arm_image.layer = FLY_LAYER+1
				src.UpdateOverlays(src.arm_image, "arm")

	blue
		name = "comfy blue chair"
		icon_state = "chair_comfy-blue"
		arm_icon_state = "arm-blue"
		parts_type = /obj/item/furniture_parts/comfy_chair/blue

	red
		name = "comfy red chair"
		icon_state = "chair_comfy-red"
		arm_icon_state = "arm-red"
		parts_type = /obj/item/furniture_parts/comfy_chair/red

	green
		name = "comfy green chair"
		icon_state = "chair_comfy-green"
		arm_icon_state = "arm-green"
		parts_type = /obj/item/furniture_parts/comfy_chair/green

	yellow
		name = "comfy yellow chair"
		icon_state = "chair_comfy-yellow"
		arm_icon_state = "arm-yellow"
		parts_type = /obj/item/furniture_parts/comfy_chair/yellow

	orange
		name = "comfy orange chair"
		icon_state = "chair_comfy-orange"
		arm_icon_state = "arm-orange"
		parts_type = /obj/item/furniture_parts/comfy_chair/orange

	lblue
		name = "comfy light blue chair"
		icon_state = "chair_comfy-lblue"
		arm_icon_state = "arm-lblue"
		parts_type = /obj/item/furniture_parts/comfy_chair/lblue

	purple
		name = "comfy purple chair"
		icon_state = "chair_comfy-purple"
		arm_icon_state = "arm-purple"
		parts_type = /obj/item/furniture_parts/comfy_chair/purple

/obj/stool/chair/comfy/throne_gold
	name = "golden throne"
	desc = "This throne commands authority and respect. Everyone is super envious of whoever sits in this chair."
	icon_state = "thronegold"
	arm_icon_state = "thronegold-arm"
	comfort_value = 7
	anchored = 0
	deconstructable = 1
	parts_type = /obj/item/furniture_parts/throne_gold

/* ======================================================== */
/* -------------------- Shuttle Chairs -------------------- */
/* ======================================================== */

//Buckle up
//For safety
//Buckle up

/obj/stool/chair/comfy/shuttle
	name = "shuttle seat"
	desc = "Equipped with a safety buckle and a tray on the back for the person behind you to use!"
	icon_state = "shuttle_chair"
	arm_icon_state = "shuttle_chair-arm"
	comfort_value = 5
	deconstructable = 0
	parts_type = null

	red
		icon_state = "shuttle_chair-red"
	brown
		icon_state = "shuttle_chair-brown"
	green
		icon_state = "shuttle_chair-green"

	//these seatbelts are getting pretty old huh
	proc/seatbelt_snap(var/probobo)
		if (!probobo)
			probobo = 1
		if(prob(probobo) && src.stool_user) //isstoolbuckled(src)
			src.unbuckle()
			src.stool_user.visible_message("[src.stool_user]'s seatbelt snaps off on launch! Holy shit!","Your seatbelt snaps on launch! Uh oh!")

/obj/stool/chair/comfy/shuttle/pilot
	name = "pilot's seat"
	desc = "Only the most important crew member gets to sit here. Everyone is super envious of whoever sits in this chair."
	icon_state = "shuttle_chair-pilot"
	arm_icon_state = "shuttle_chair-pilot-arm"
	comfort_value = 7

/* ======================================================= */
/* -------------------- Folded Chairs -------------------- */
/* ======================================================= */

/obj/item/chair/folded
	name = "chair"
	desc = "A folded chair. Good for smashing noggin-shaped things."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "folded_chair"
	item_state = "folded_chair"
	w_class = W_CLASS_BULKY
	throwforce = 10
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 5
	stamina_damage = 45
	stamina_cost = 21
	stamina_crit_chance = 10
	var/c_color = null

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		BLOCK_SETUP(BLOCK_LARGE)

/obj/item/chair/folded/attack_self(mob/user as mob)
	if(cant_drop == 1)
		boutput(user, "You can't unfold the [src] when its attached to your arm!")
		return
	else
		var/obj/stool/chair/C = new/obj/stool/chair(user.loc)
		if (src.material)
			C.setMaterial(src.material)
		if (src.c_color)
			C.icon_state = src.c_color
		C.set_dir(user.dir)
		boutput(user, "You unfold [C].")
		user.drop_item()
		qdel(src)
		return

/obj/item/chair/folded/attack(atom/target, mob/user as mob)
	var/oldcrit = src.stamina_crit_chance
	if(iswrestler(user))
		src.stamina_crit_chance = 100
	if (ishuman(target))
		playsound(src.loc, pick(sounds_punch), 100, 1)
	..()
	src.stamina_crit_chance = oldcrit
