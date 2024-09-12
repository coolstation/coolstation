/* ================================================ */
/* -------------------- Chairs -------------------- */
/* ================================================ */

//originally in code/obj/stool.dm

/obj/stool/chair
	name = "chair"
	desc = "A four-legged metal chair, rigid and slightly uncomfortable. Helpful when you don't want to use your legs at the moment."
	icon_state = "chair"
	var/comfort_value = 3
	var/status = 0
	rotatable = 1
	cando_flags = STOOL_SIT | STOOL_BUCKLE | STOOL_STAND | STOOL_SECURE //was tempted to not have them buckle but what kind of ss13 would this be without buckling to chairs and scooting
	securable = 1
	anchored = 1
	foldable = 1
	scoot_sounds = list( 'sound/misc/chair/normal/scoot1.ogg', 'sound/misc/chair/normal/scoot2.ogg', 'sound/misc/chair/normal/scoot3.ogg', 'sound/misc/chair/normal/scoot4.ogg', 'sound/misc/chair/normal/scoot5.ogg' )
	folds_type = /obj/item/chair/folded
	parts_type = null

	moveable
		anchored = 0

	New()
		if (src.dir == NORTH)
			src.layer = FLY_LAYER+1
		butt_img = image('icons/obj/furniture/chairs.dmi')
		butt_img.layer = OBJ_LAYER + 0.5 //In between OBJ_LAYER and MOB_LAYER
		..()
		return

	Move()
		. = ..()
		if (.)
			if (src.dir == NORTH)
				src.layer = FLY_LAYER+1
			else
				src.layer = OBJ_LAYER

	rotate(var/face_dir = 0)
		..()
		update_icon()
		return

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
	cando_flags = STOOL_SIT
//	var/atom/movable/overlay/overl = null
	var/image/arm_image = null
	var/arm_icon_state = "arm"
	parts_type = /obj/item/furniture_parts/comfy_chair

	New()
		..()
		update_icon()

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

/obj/stool/chair/comfy/shuttle
	name = "shuttle seat"
	desc = "Equipped with a safety buckle and a tray on the back for the person behind you to use!"
	icon_state = "shuttle_chair"
	arm_icon_state = "shuttle_chair-arm"
	cando_flags = STOOL_SIT | STOOL_BUCKLE | STOOL_STAND | STOOL_SECURE
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
		if(prob(probobo) && isbuckle(src)) //isbuckle(src)
			src.unbuckle()
			src.stool_user.visible_message("[src.stool_user]'s seatbelt snaps off on launch! Holy shit!","Your seatbelt snaps on launch! Uh oh!")
			src.cando_flags &= ~(STOOL_BUCKLE)

/obj/stool/chair/comfy/shuttle/pilot
	name = "pilot's seat"
	desc = "Only the most important crew member gets to sit here. Everyone is super envious of whoever sits in this chair."
	icon_state = "shuttle_chair-pilot"
	arm_icon_state = "shuttle_chair-pilot-arm"
	comfort_value = 7

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
	swivels = 1
	unstable = 1
	casters = 1
	sticky = 1
	cando_flags = STOOL_SIT | STOOL_STAND //standing is a real bad idea
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

	syndie
		icon_state = "syndiechair"
		parts_type = null

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
	cando_flags = STOOL_SIT | STOOL_BUCKLE | STOOL_STAND | STOOL_SECURE
	scoot_sounds = list("sound/misc/chair/office/scoot1.ogg", "sound/misc/chair/office/scoot2.ogg", "sound/misc/chair/office/scoot3.ogg", "sound/misc/chair/office/scoot4.ogg", "sound/misc/chair/office/scoot5.ogg")
	parts_type = /obj/item/furniture_parts/wheelchair
	mat_appearances_to_ignore = list("steel")
	mats = 15

	update_icon()
		ENSURE_IMAGE(src.arm_image, src.icon, src.arm_icon_state)
		src.arm_image.layer = FLY_LAYER+1
		src.UpdateOverlays(src.arm_image, "arm")

	fall_over(var/turf/T)
		if (issit(src))
			var/mob/living/M = src.stool_user
			src.unsit()
			if (M && !src.stool_user)
				M.visible_message("<span class='alert'>[M] is tossed out of [src] as it tips [T ? "while rolling over [T]" : "over"]!</span>",\
				"<span class='alert'>You're tossed out of [src] as it tips [T ? "while rolling over [T]" : "over"]!</span>")
				var/turf/target = get_edge_target_turf(src, src.dir)
				M.throw_at(target, 5, 1)
				M.changeStatus("stunned", 8 SECONDS)
				M.changeStatus("weakened", 5 SECONDS)
		else
			src.visible_message("<span class='alert'>[src] tips [T ? "as it rolls over [T]" : "over"]!</span>")
		src.scoot_sounds = list("sound/misc/chair/normal/scoot1.ogg", "sound/misc/chair/normal/scoot2.ogg", "sound/misc/chair/normal/scoot3.ogg", "sound/misc/chair/normal/scoot4.ogg", "sound/misc/chair/normal/scoot5.ogg")

	pick_up(mob/user as mob)
		if (user)
			user.visible_message("[user] sets [src] back on its wheels.",\
			"You set [src] back on its wheels.")
		src.lying = 0
		animate_rest(src, !src.lying)
		src.p_class = initial(src.p_class) + src.lying // 2 while standing, 3 while lying

	buckle_in(mob/living/to_buckle, mob/living/user)
		..()
		if (src.stool_user == to_buckle)
			APPLY_MOVEMENT_MODIFIER(to_buckle, /datum/movement_modifier/wheelchair, src.type)

	unbuckle()
		if(src.stool_user)
			REMOVE_MOVEMENT_MODIFIER(src.stool_user, /datum/movement_modifier/wheelchair, src.type)
		return ..()

	set_loc(newloc)
		. = ..()
		unbuckle()

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
	var/unfolds_type = /obj/stool/chair

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		BLOCK_SETUP(BLOCK_LARGE)

	attack_self(mob/user as mob)
		if(cant_drop == 1)
			boutput(user, "You can't unfold the [src] when its attached to your arm!")
			return
		else
			var/obj/stool/chair/C = new src.unfolds_type(user.loc)
			if (src.material)
				C.setMaterial(src.material)
			if (src.c_color)
				C.icon_state = src.c_color
			C.set_dir(user.dir)
			boutput(user, "You unfold [C].")
			user.drop_item()
			qdel(src)
			return

	attack(atom/target, mob/user as mob)
		var/oldcrit = src.stamina_crit_chance
		if(iswrestler(user))
			src.stamina_crit_chance = 100
		if (ishuman(target))
			playsound(src.loc, pick(sounds_punch), 100, 1)
		..()
		src.stamina_crit_chance = oldcrit
