// EARS

/obj/item/clothing/ears
	name = "ears"
	icon = 'icons/obj/clothing/item_ears.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_headgear.dmi'
	wear_image_icon = 'icons/mob/ears.dmi'
	w_class = W_CLASS_TINY
	wear_layer = MOB_EARS_LAYER
	throwforce = 2

/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Keeps you warm, makes it hard to hear."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	protective_temperature = 500

	equipped(mob/user, slot)
		. = ..()
		if(slot == SLOT_EARS)
			user.ear_protected++

	unequipped(mob/user)
		if(src.equipped_in_slot == SLOT_EARS)
			user.ear_protected--
		. = ..()

	disposing()
		if(src.equipped_in_slot == SLOT_EARS && ismob(src.loc))
			var/mob/M = src.loc
			M.ear_protected--
		. = ..()

	setupProperties()
		..()
		setProperty("coldprot", 20)
		setProperty("disorient_resist_ear", 100)

/obj/item/clothing/ears/earmuffs/earplugs
	name = "ear plugs"
	desc = "Protects you from sonic attacks."
	icon_state = "earplugs"
	item_state = "nothing"
	protective_temperature = 0

	setupProperties()
		..()
		setProperty("coldprot", 0)
		setProperty("disorient_resist_ear", 100)

/obj/item/clothing/ears/yeti_warmers
	name = "yeti-fur earwarmers"
	desc = "Keeps you warm without making it hard to hear."
	icon_state = "yetiearmuffs"
	item_state = "yetiearmuffs"
	protective_temperature = 500

	setupProperties()
		..()
		setProperty("coldprot", 80)
		setProperty("disorient_resist_ear", 80)
