
// haine wuz here and tore this file to bits!!!  f u we can have things in their own files and we SHOULD
// rather than EVERYTHING BEING IN HALLOWEEN.DM AND KEELINSSTUFF.DM OKAY THINGS CAN BE IN OTHER FILES

/obj/item/storage
	name = "storage"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "box_blank"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "box"
	// variables here are copied from /datum/storage
	var/list/can_hold = null
	var/list/can_hold_exact = null
	var/list/prevent_holding = null
	var/check_wclass = 0
	var/datum/hud/storage/hud
	var/sneaky = 0
	var/opens_if_worn = FALSE
	var/max_wclass = W_CLASS_SMALL
	var/slots = 7
	var/list/spawn_contents = list()
	move_triggered = 1
	flags = FPRINT | TABLEPASS | NOSPLASH
	w_class = W_CLASS_NORMAL

		//cogwerks - burn vars
	burn_point = 2500
	burn_output = 2500
	burn_possible = TRUE
	health = 10

	New()
		src.create_storage(/datum/storage, spawn_contents, can_hold, can_hold_exact, prevent_holding, check_wclass, max_wclass, slots, sneaky, opens_if_worn)
		src.make_my_stuff()
		..()

	// override this with specific additions to add to the storage
	proc/make_my_stuff()
		return

/obj/item/storage/box
	name = "box"
	icon_state = "box"
	desc = "A box that can hold a number of small items."
	max_wclass = 2

/obj/item/storage/box/starter // the one you get in your backpack
	spawn_contents = list(/obj/item/clothing/mask/breath)

/obj/item/storage/box/starter/withO2
	spawn_contents = list(/obj/item/clothing/mask/breath,/obj/item/tank/emergency_oxygen)

/obj/item/storage/pill_bottle
	name = "pill bottle"
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	item_state = "contsolid"
	can_hold = list(/obj/item/reagent_containers/pill)
	w_class = W_CLASS_SMALL
	max_wclass = 1
	desc = "A small bottle designed to carry pills. Does not come with a child-proof lock, as that was determined to be too difficult for the crew to open."
	hint = "you can create your own pill bottles with a Chemmaster."

	mouse_drop(atom/over_object, src_location, over_location)
		if(!(usr == over_object)) return ..()
		if(!istype(usr, /mob/living/carbon)) return ..()
		var/mob/living/carbon/C = usr
		if(C.r_hand == src || C.l_hand == src) // inhand? chugg
			actions.start(new /datum/action/bar/icon/chug_pills(C, src), C)
		else
			return ..()


/obj/item/storage/briefcase
	name = "briefcase"
	icon_state = "briefcase"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "briefcase"
	flags = FPRINT | TABLEPASS| CONDUCT | NOSPLASH
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = W_CLASS_BULKY
	max_wclass = 3
	desc = "A fancy synthetic leather-bound briefcase, capable of holding a number of small objects, with style."
	stamina_damage = 40
//	stamina_cost = 17
//	stamina_crit_chance = 10
	spawn_contents = list(/obj/item/paper = 2,/obj/item/pen)
	// Don't use up more slots, certain job datums put items in the briefcase the player spawns with.
	// And nobody needs six sheets of paper right away, realistically speaking.

	New()
		..()
		BLOCK_SETUP(BLOCK_BOOK)

/obj/item/storage/briefcase/toxins
	name = "toxins research briefcase"
	icon_state = "briefcase_rd"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "rd-case"
	desc = "A large briefcase for experimental toxins research."
	spawn_contents = list(/obj/item/paper/iou)
//	spawn_contents = list(/obj/item/raw_material/molitz_beta = 2, /obj/item/paper/hellburn)

/obj/item/storage/rockit
	name = "\improper Rock-It Launcher"
	desc = "Huh..."
	icon = 'icons/obj/items/gun.dmi'
	icon_state = "rockit"
	item_state = "gun"
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	w_class = W_CLASS_BULKY
	max_wclass = W_CLASS_NORMAL

	New()
		..()
		src.setItemSpecial(null)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (target == loc)
			return
		if (!length(src.storage.get_contents()))
			return
		var/obj/item/I = pick(src.storage.get_contents())
		if (!I)
			return

		src.storage.transfer_stored_item(I, get_turf(src.loc))
		I.dropped(user)
		I.layer = initial(I.layer)
		I.throw_at(target, 8, 2, bonus_throwforce=8)

		playsound(src, 'sound/effects/singsuck.ogg', 40, 1)
