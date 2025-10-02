/* ============================================== */
/* -------------------- Beds -------------------- */
/* ============================================== */

/obj/stool/bed
	name = "bed"
	desc = "A solid metal frame with some padding on it, useful for sleeping on."
	icon_state = "bed"
	anchored = ANCHORED
	var/security = 0
	var/obj/item/clothing/suit/bedsheet/Sheet = null
	parts_type = /obj/item/furniture_parts/bed

	brig
		name = "brig cell bed"
		desc = "It doesn't look very comfortable. Fortunately there's no way to be buckled to it."
		security = 1
		parts_type = null

	moveable
		name = "roller bed"
		desc = "A solid metal frame with some padding on it, useful for sleeping on. This one has little wheels on it, neat!"
		anchored = UNANCHORED
		securable = 1
		icon_state = "rollerbed"
		parts_type = /obj/item/furniture_parts/bed/roller
		scoot_sounds = list( 'sound/misc/chair/office/scoot1.ogg', 'sound/misc/chair/office/scoot2.ogg', 'sound/misc/chair/office/scoot3.ogg', 'sound/misc/chair/office/scoot4.ogg', 'sound/misc/chair/office/scoot5.ogg' )

	Move()
		if(src.stool_user?.loc != src.loc)
			src.unbuckle()
		. = ..()
		if (. && src.stool_user)
			var/mob/living/carbon/C = src.stool_user
			C.buckled = null
			C.Move(src.loc)
			C.buckled = src

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/clothing/suit/bedsheet))
			src.tuck_sheet(W, user)
			return
		if (iswrenchingtool(W) && !src.deconstructable)
			boutput(user, "<span class='alert'>You briefly ponder how to go about disassembling a featureless slab using a wrench. You quickly give up.</span>")
			return
		else
			return ..()

	attack_hand(mob/user as mob)
		..()
		if (src.Sheet)
			src.untuck_sheet(user)
		for (var/mob/M in src.loc)
			src.unbuckle_mob(M, user)
		return

	can_buckle(var/mob/living/carbon/C, var/mob/user)
		if (!C || (C.loc != src.loc))
			return 0// yeesh

		if (get_dist(src, user) > 1)
			user.show_text("[src] is too far away!", "red")
			return 0

		if(src.stool_user && src.stool_user.buckled == src)
			user.show_text("There's already someone buckled in [src]!", "red")
			return 0

		if (!ticker)
			user.show_text("You can't buckle anyone in before the game starts.", "red")
			return 0
		if (C.buckled)
			boutput(user, "[hes_or_shes(C)] already buckled into something!", "red")
			return 0
		if (src.security)
			user.show_text("There's nothing you can buckle them to!", "red")
			return 0
		if (get_dist(src, user) > 1)
			user.show_text("[src] is too far away!", "red")
			return 0
		if ((!(iscarbon(C)) || C.loc != src.loc || user.restrained() || is_incapacitated(user) ))
			return 0

		return 1

	proc/unbuckle_mob(var/mob/M as mob, var/mob/user as mob)
		if (M.buckled && !user.restrained())
			if (locked)
				if (M != user)
					user.visible_message("<span class='notice'><b>[M]</b> is unbuckled by [user].</span>", "<span class='notice'>You unbuckle [M].</span>")
				else
					user.visible_message("<span class='notice'><b>[M]</b> unbuckles.</span>", "<span class='notice'>You unbuckle.</span>")
				unbuckle()
			else
				user.show_text("Seems like the buckle is firmly locked into place.", "red")

			src.add_fingerprint(user)

	buckle_in(mob/living/to_buckle, mob/living/user)
		if(src.stool_user && src.stool_user.buckled == src)
			return
		if (!can_buckle(to_buckle,user))
			return

		if (to_buckle == user)
			user.visible_message("<span class='notice'><b>[to_buckle]</b> lies down on [src], fastening the buckles!</span>", "<span class='notice'>You lie down and buckle yourself in.</span>")
		else
			user.visible_message("<span class='notice'><b>[to_buckle]</b> is buckled in by [user].</span>", "<span class='notice'>You buckle in [to_buckle].</span>")

		to_buckle.lying = 1
		if (src.anchored)
			to_buckle.anchored = ANCHORED
		to_buckle.buckled = src
		src.stool_user = to_buckle
		to_buckle.set_loc(src.loc)

		to_buckle.set_clothing_icon_dirty()
		playsound(src, "sound/misc/belt_click.ogg", 50, 1)
		to_buckle.setStatus("buckled", duration = INFINITE_STATUS)

	unbuckle()
		..()
		if(src.stool_user && src.stool_user.buckled == src)
			reset_anchored(stool_user)
			stool_user.buckled = null
			stool_user.force_laydown_standup()
			src.stool_user = null
			playsound(src, "sound/misc/belt_click.ogg", 50, 1)

	proc/tuck_sheet(var/obj/item/clothing/suit/bedsheet/newSheet as obj, var/mob/user as mob)
		if (!newSheet || newSheet.cape || (src.Sheet == newSheet && newSheet.loc == src.loc)) // if we weren't provided a new bedsheet, the new bedsheet we got is tied into a cape, or the new bedsheet is actually the one we already have and is still in the same place as us...
			return // nevermind

		if (src.Sheet && src.Sheet.loc != src.loc) // a safety check: do we have a sheet and is it not where we are?
			if (src.Sheet.Bed && src.Sheet.Bed == src) // does our sheet have us listed as its bed?
				src.Sheet.Bed = null // set its bed to null
			src.Sheet = null // then set our sheet to null: it's not where we are!

		if (src.Sheet && src.Sheet != newSheet) // do we have a sheet, and is the new sheet we've been given not our sheet?
			user.show_text("You try to kinda cram [newSheet] into the edges of [src], but there's not enough room with [src.Sheet] tucked in already!", "red")
			return // they're crappy beds, okay?  there's not enough space!

		if (!src.Sheet && (newSheet.loc == src.loc || user.find_in_hand(newSheet))) // finally, do we have room for the new sheet, and is the sheet where we are or in the hand of the user?
			src.Sheet = newSheet // let's get this shit DONE!
			newSheet.Bed = src
			user.u_equip(newSheet)
			newSheet.set_loc(src.loc)
			mutual_attach(src, newSheet)

			var/mob/somebody
			if (src.stool_user)
				somebody = src.stool_user
			else
				somebody = locate(/mob/living/carbon) in get_turf(src)
			if (somebody?.lying)
				user.tri_message("<span class='notice'><b>[user]</b> tucks [somebody == user ? "[him_or_her(user)]self" : "[somebody]"] into bed.</span>",\
				user, "<span class='notice'>You tuck [somebody == user ? "yourself" : "[somebody]"] into bed.</span>",\
				somebody, "<span class='notice'>[somebody == user ? "You tuck yourself" : "<b>[user]</b> tucks you"] into bed.</span>")
				newSheet.layer = EFFECTS_LAYER_BASE-1
				return
			else
				user.visible_message("<span class='notice'><b>[user]</b> tucks [newSheet] into [src].</span>",\
				"<span class='notice'>You tuck [newSheet] into [src].</span>")
				return

	proc/untuck_sheet(var/mob/user as mob)
		if (!src.Sheet) // vOv
			return // there's nothing to do here, everyone go home

		var/obj/item/clothing/suit/bedsheet/oldSheet = src.Sheet

		if (user)
			var/mob/somebody
			if (src.stool_user)
				somebody = src.stool_user
			else
				somebody = locate(/mob/living/carbon) in get_turf(src)
			if (somebody?.lying)
				user.tri_message("<span class='notice'><b>[user]</b> untucks [somebody == user ? "[him_or_her(user)]self" : "[somebody]"] from bed.</span>",\
				user, "<span class='notice'>You untuck [somebody == user ? "yourself" : "[somebody]"] from bed.</span>",\
				somebody, "<span class='notice'>[somebody == user ? "You untuck yourself" : "<b>[user]</b> untucks you"] from bed.</span>")
				oldSheet.layer = initial(oldSheet.layer)
			else
				user.visible_message("<span class='notice'><b>[user]</b> untucks [oldSheet] from [src].</span>",\
				"<span class='notice'>You untuck [oldSheet] from [src].</span>")

		if (oldSheet.Bed == src) // just in case it's somehow not us
			oldSheet.Bed = null
		mutual_detach(src, oldSheet)
		src.Sheet = null
		return

	MouseDrop_T(atom/A as mob|obj, mob/user as mob)
		if (get_dist(src, user) > 1 || A.loc != src.loc || user.restrained() || !isalive(user))
			..()
		else if (istype(A, /obj/item/clothing/suit/bedsheet))
			if ((!src.Sheet || (src.Sheet && src.Sheet.loc != src.loc)) && A.loc == src.loc)
				src.tuck_sheet(A, user)
				return
			if (src.Sheet && A == src.Sheet)
				src.untuck_sheet(user)
				return

		else if (ismob(A))
			src.buckle_in(A, user)
			var/mob/M = A
			if (isdead(M) && M != user && emergency_shuttle?.location == SHUTTLE_LOC_STATION) // 1 should be SHUTTLE_LOC_STATION
				var/area/shuttle/escape/station/area = get_area(M)
				if (istype(area))
					user.unlock_medal("Leave no man behind!", 1)
			src.add_fingerprint(user)
		else
			return ..()

	disposing()
		for (var/mob/M in src.loc)
			if (M.buckled == src)
				M.buckled = null
				src.stool_user = null
				M.lying = 0
				reset_anchored(M)
		if (src.Sheet && src.Sheet.Bed == src)
			src.Sheet.Bed = null
			src.Sheet = null
		..()
		return

	proc/sleep_in(var/mob/M)
		if (!ishuman(M))
			return

		var/mob/living/carbon/user = M

		if (isdead(user))
			boutput(user, "<span class='alert'>Some would say that death is already the big sleep.</span>")
			return

		if ((get_turf(user) != src.loc) || (!user.lying))
			boutput(user, "<span class='alert'>You must be lying down on [src] to sleep on it.</span>")
			return

		user.setStatus("resting", INFINITE_STATUS)
		user.sleeping = 4
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			H.hud.update_resting()
		return
