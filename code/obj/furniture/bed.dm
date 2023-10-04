/* ============================================== */
/* -------------------- Beds -------------------- */
/* ============================================== */

//originally in code/obj/stools.dm

/obj/stool/bed
	name = "bed"
	desc = "A solid metal frame with some padding on it, useful for sleeping on."
	icon_state = "bed"
	anchored = 1
	cando_flags = STOOL_SIT | STOOL_BUCKLE | STOOL_STAND //may make a new type for bucklebedding
	var/obj/item/clothing/suit/bedsheet/Sheet = null
	parts_type = /obj/item/furniture_parts/bed

	brig
		name = "brig cell bed"
		desc = "It doesn't look very comfortable. Fortunately there's no way to be buckled to it."
		cando_flags = STOOL_SIT | STOOL_STAND
		parts_type = null

	moveable
		name = "roller bed"
		desc = "A solid metal frame with some padding on it, useful for sleeping on. This one has little wheels on it, neat!"
		anchored = 0
		securable = 1
		icon_state = "rollerbed"
		parts_type = /obj/item/furniture_parts/bed/roller
		scoot_sounds = list( 'sound/misc/chair/office/scoot1.ogg', 'sound/misc/chair/office/scoot2.ogg', 'sound/misc/chair/office/scoot3.ogg', 'sound/misc/chair/office/scoot4.ogg', 'sound/misc/chair/office/scoot5.ogg' )

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
			if (can_unbuckle(M, user))
				src.unbuckle(M, user)
		return

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

	disposing()
		for (var/mob/M in src.loc)
			if (M.stool_used == src)
				M.stool_used = null
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
