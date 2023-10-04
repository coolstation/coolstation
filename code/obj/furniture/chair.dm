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

/* ================================================= */
/* -------------------- Couches -------------------- */
/* ================================================= */

/obj/stool/chair/couch
	name = "comfy brown couch"
	desc = "You've probably lost some space credits in these things before."
	icon_state = "chair_couch-brown"
	rotatable = 0
	foldable = 0
	var/damaged = 0
	comfort_value = 5
	deconstructable = 0
	securable = 0
	var/max_uses = 0 // The maximum amount of time one can try to look under the cushions for items.
	var/spawn_chance = 0 // How likely is this couch to spawn something?
	var/last_use = 0 // To prevent spam.
	var/time_between_uses = 400 // The default time between uses.
	var/list/items = list (/obj/item/device/light/zippo,
	/obj/item/wrench,
	/obj/item/device/multitool,
	/obj/item/toy/plush/small/buddy,
	/obj/item/toy/plush/small/stress_ball,
	/obj/item/paper/lunchbox_note,
	/obj/item/plant/herb/cannabis/spawnable,
	/obj/item/reagent_containers/food/snacks/candy/candyheart,
	/obj/item/bananapeel,
	/obj/item/reagent_containers/food/snacks/lollipop/random_medical,
	/obj/item/spacecash/random/small,
	/obj/item/spacecash/random/tourist,
	/obj/item/spacecash/buttcoin)

	New()
		..()
		max_uses = rand(0, 2) // Losing things in a couch is hard.
		spawn_chance = rand(1, 20)

		if (prob(10)) //time to flail
			items.Add(/obj/critter/meatslinky)

		if (prob(1))
			desc = "A vague feeling of loss emanates from this couch, as if it is missing a part of itself. A global list of couches, perhaps."

	disposing()
		..()

	proc/damage(severity)
		if(severity > 1 && damaged < 2)
			damaged += 2
			overlays += image('icons/obj/objects.dmi', "couch-tear")
		else if(damaged < 1)
			damaged += 1
			overlays += image('icons/obj/objects.dmi', "couch-rip")

	attack_hand(mob/user as mob)
		if (!user) return
		if (damaged || stool_user) return ..()

		user.lastattacked = src

		playsound(src.loc, "rustle", 66, 1, -5) // todo: find a better sound.

		if (max_uses > 0 && ((last_use + time_between_uses) < world.time) && prob(spawn_chance))

			var/something = pick(items)

			if (ispath(something))
				var/thing = new something(src.loc)
				user.put_in_hand_or_drop(thing)
				if (istype(thing, /obj/critter/meatslinky)) //slink slink
					user.emote("scream")
					random_brute_damage(user, 10)
					user.visible_message("<span class='notice'><b>[user.name]</b> rummages through the seams and behind the cushions of [src] and pulls [his_or_her(user)] hand out in pain! \An [thing] slithers out of \the [src]!</span>",\
					"<span class='notice'>You rummage through the seams and behind the cushions of [src] and your hand gets bit by \an [thing]!</span>")
				else
					user.visible_message("<span class='notice'><b>[user.name]</b> rummages through the seams and behind the cushions of [src] and pulls \an [thing] out of it!</span>",\
					"<span class='notice'>You rummage through the seams and behind the cushions of [src] and you find \an [thing]!</span>")
				last_use = world.time
				max_uses--

		else if (max_uses <= 0)
			user.visible_message("<span class='notice'><b>[user.name]</b> rummages through the seams and behind the cushions of [src] and pulls out absolutely nothing!</span>",\
			"<span class='notice'>You rummage through the seams and behind the cushions of [src] and pull out absolutely nothing!</span>")
		else
			user.visible_message("<span class='notice'><b>[user.name]</b> rummages through the seams and behind the cushions of [src]!</span>",\
			"<span class='notice'>You rummage through the seams and behind the cushions of [src]!</span>")

	blue
		name = "comfy blue couch"
		icon_state = "chair_couch-blue"

	red
		name = "comfy red couch"
		icon_state = "chair_couch-red"

	green
		name = "comfy green couch"
		icon_state = "chair_couch-green"

	yellow
		name = "comfy yellow couch"
		icon_state = "chair_couch-yellow"

	purple
		name = "comfy purple couch"
		icon_state = "chair_couch-purple"

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



/* ========================================================= */
/* -------------------- Electric Chairs -------------------- */
/* ========================================================= */

/obj/stool/chair/e_chair
	name = "electrified chair"
	desc = "A chair that has been modified to conduct current with over 2000 volts, enough to kill a human nearly instantly."
	icon_state = "e_chair0"
	foldable = 0
	cando_flags = STOOL_SIT | STOOL_BUCKLE | STOOL_SECURE
	var/on = 0
	var/obj/item/assembly/shock_kit/part1 = null
	var/last_time = 1
	var/lethal = 0
	var/image/image_belt = null
	comfort_value = -3
	securable = 0

	New()
		..()
		SPAWN_DBG(2 SECONDS)
			if (src)
				if (!(src.part1 && istype(src.part1)))
					src.part1 = new /obj/item/assembly/shock_kit(src)
					src.part1.master = src
				src.update_icon()
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (iswrenchingtool(W))
			var/obj/stool/chair/C = new /obj/stool/chair(get_turf(src))
			if (src.material)
				C.setMaterial(src.material)
			playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
			C.set_dir(src.dir)
			if (src.part1)
				src.part1.set_loc(get_turf(src))
				src.part1.master = null
				src.part1 = null
			qdel(src)
			return

	verb/controls()
		set src in oview(1)
		set category = "Local"

		src.control_interface(usr)

	// Seems to be the only way to get this stuff to auto-refresh properly, sigh (Convair880).
	proc/control_interface(mob/user as mob)
		if (!user.hasStatus("handcuffed") && isalive(user))
			src.add_dialog(user)

			var/dat = ""

			var/area/A = get_area(src)
			if (!isarea(A) || !A.powered(EQUIP))
				dat += "\n<font color='red'>ERROR:</font> No power source detected!</b>"
			else
				dat += {"<A href='?src=\ref[src];on=1'>[on ? "Switch Off" : "Switch On"]</A><BR>
				<A href='?src=\ref[src];lethal=1'>[lethal ? "<font color='red'>Lethal</font>" : "Nonlethal"]</A><BR><BR>
				<A href='?src=\ref[src];shock=1'>Shock</A><BR>"}

			user.Browse("<TITLE>Electric Chair</TITLE><b>Electric Chair</b><BR>[dat]", "window=e_chair;size=180x180")

			onclose(user, "e_chair")
		return

	Topic(href, href_list)
		if (usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened") || usr.stat || usr.restrained()) return
		if (!in_interact_range(src, usr)) return

		if (href_list["on"])
			toggle_active()
		else if (href_list["lethal"])
			toggle_lethal()
		else if (href_list["shock"])
			if (src.stool_user)
				// The log entry for remote signallers can be found in item/assembly/shock_kit.dm (Convair880).
				logTheThing("combat", usr, src.stool_user, "activated an electric chair (setting: [src.lethal ? "lethal" : "non-lethal"]), shocking [constructTarget(src.stool_user,"combat")] at [log_loc(src)].")
			shock(lethal)

		src.control_interface(usr)
		src.add_fingerprint(usr)
		return

	proc/toggle_active()
		src.on = !(src.on)
		src.update_icon()
		return src.on

	proc/toggle_lethal()
		src.lethal = !(src.lethal)
		src.update_icon()
		return

	update_icon()
		src.icon_state = "e_chair[src.on]"
		if (!src.image_belt)
			src.image_belt = image(src.icon, "e_chairo[src.on][src.lethal]", layer = FLY_LAYER + 1)
			src.UpdateOverlays(src.image_belt, "belts")
			return
		src.image_belt.icon_state = "e_chairo[src.on][src.lethal]"
		src.UpdateOverlays(src.image_belt, "belts")

	// Options:      1) place the chair anywhere in a powered area (fixed shock values),
	// (Convair880)  2) on top of a powered wire (scales with engine output).
	proc/get_connection()
		var/turf/T = get_turf(src)
		if (!istype(T, /turf/floor))
			return 0

		for (var/obj/cable/C in T)
			return C.netnum

		return 0

	proc/get_gridpower()
		var/netnum = src.get_connection()

		if (netnum)
			var/datum/powernet/PN
			if (powernets && powernets.len >= netnum)
				PN = powernets[netnum]
				return PN.avail

		return 0

	proc/shock(lethal)
		if (!src.on)
			return
		if ((src.last_time + 50) > world.time)
			return
		src.last_time = world.time

		// special power handling
		var/area/A = get_area(src)
		if (!isarea(A))
			return
		if (!A.powered(EQUIP))
			return
		A.use_power(EQUIP, 5000)
		A.updateicon()

		for (var/mob/M in AIviewers(src, null))
			M.show_message("<span class='alert'>The electric chair went off!</span>", 3)
			if (lethal)
				playsound(src.loc, "sound/effects/electric_shock.ogg", 50, 0)
			else
				playsound(src.loc, "sound/effects/sparks4.ogg", 50, 0)

		if (src.stool_user && ishuman(src.stool_user))
			var/mob/living/carbon/human/H = src.stool_user

			if (src.lethal)
				var/net = src.get_connection() // Are we wired-powered (Convair880)?
				var/power = src.get_gridpower()
				if (!net || (net && (power < 2000000)))
					H.shock(src, 2000000, "chest", 0.3, 1) // Nope or not enough juice, use fixed values instead (around 80 BURN per shock).
				else
					//DEBUG_MESSAGE("Shocked [H] with [power]")
					src.electrocute(H, 100, net, 1) // We are, great. Let that global proc calculate the damage.
			else
				H.shock(src, 2500, "chest", 1, 1)
				H.changeStatus("stunned", 10 SECONDS)

			if (ticker?.mode && istype(ticker.mode, /datum/game_mode/revolution))
				if ((H.mind in ticker.mode:revolutionaries) && !(H.mind in ticker.mode:head_revolutionaries) && prob(66))
					ticker.mode:remove_revolutionary(H.mind)

		A.updateicon()
		return


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
