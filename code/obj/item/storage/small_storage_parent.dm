
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

/obj/item/storage/desk_drawer
	name = "desk drawer"
	desc = "This fits into a desk and you can store stuff in it! Wow, amazing!!"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "desk_drawer"
	flags = FPRINT | TABLEPASS
	w_class = W_CLASS_BULKY
	max_wclass = 2
	slots = 13 // these can't move (in theory) and they can only hold w_class 2 things so we may as well let them hold a bunch
	mechanics_type_override = /obj/item/storage/desk_drawer
	var/locked = 0
	var/id = null

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/device/key/filing_cabinet))
			var/obj/item/device/key/K = W
			if (src.id && K.id == src.id)
				src.locked = !src.locked
				user.visible_message("[user] [!src.locked ? "un" : null]locks [src].")
				playsound(src, "sound/items/Screwdriver2.ogg", 50, 1)
			else
				boutput(user, "<span class='alert'>[K] doesn't seem to fit in [src]'s lock.</span>")
			return
		..()

	mouse_drop(atom/over_object, src_location, over_location)
		if (src.locked)
			if (usr)
				boutput(usr, "<span class='alert'>[src] is locked!</span>")
			return
		..()

/obj/item/storage/desk_drawer/prepared_tool_cart //boy the tool carts are funky in terms of inheritance
	//Got some spares just in case, no welders cause I figure these'll be in podbays which have welding closets
	spawn_contents = list(/obj/item/crowbar,
	/obj/item/crowbar,
	/obj/item/wirecutters,
	/obj/item/wirecutters,
	/obj/item/screwdriver,
	/obj/item/screwdriver,
	/obj/item/wrench,
	/obj/item/wrench,
	/obj/item/reagent_containers/glass/oilcan,
	/obj/item/clothing/gloves/black,
	/obj/item/cable_coil/white, //approximately the neutral/live/earth wiring colours for the US
	/obj/item/cable_coil/black, //don't ask why the cart contents reference that of all things, I thought it'd be a cute thing to do :P
	/obj/item/cable_coil/green) //anyway we got slots to fill, so

/obj/item/storage/desk_drawer/kitchen_tools //thanks for the example batelite
	spawn_contents = list(/obj/item/kitchen/utensil/knife/cleaver,
	/obj/item/kitchen/utensil/knife/pizza_cutter,
	/obj/item/kitchen/utensil/knife/bread,
	/obj/item/kitchen/rollingpin,
	/obj/item/kitchen/sushi_roller,
	/obj/item/soup_pot,
	/obj/item/ladle,
	/obj/item/cigpacket,
	/obj/item/clothing/gloves/latex)

/obj/item/storage/desk_drawer/kitchen_sink
	spawn_contents = list(/obj/item/spraybottle/cleaner,
	/obj/item/reagent_containers/glass/bottle/cleaner,
	/obj/item/reagent_containers/glass/bottle/ammonia/janitors,
	/obj/item/sponge,
	/obj/item/storage/box/mousetraps,
	/obj/item/clothing/gloves/long,
	/obj/item/decoration/ashtray,
	/obj/item/wrench)

/obj/item/storage/desk_drawer/kitchen_plate
	spawn_contents = list(/obj/item/platestack,
	/obj/item/platestack,
	/obj/item/platestack,
	/obj/item/platestack,
	/obj/item/plate/tray,
	/obj/item/plate/tray,
	/obj/item/plate/tray,
	/obj/item/plate/tray)

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
