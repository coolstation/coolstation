/* ---------- Rack Parts ---------- */
/obj/item/furniture_parts/rack
	name = "rack parts"
	desc = "A collection of parts that can be used to make a rack."
	icon = 'icons/obj/metal.dmi'
	icon_state = "rack_base_parts"
	stamina_damage = 25
	stamina_cost = 22
	stamina_crit_chance = 15
	furniture_type = /obj/rack
	furniture_name = "rack"

//bookshelf part construction
	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/plank))
			user.visible_message("[user] starts to reinforce \the [src] with wood.", "You start to reinforce \the [src] with wood.")
			if (!do_after(user, 2 SECONDS))
				return
			user.visible_message("[user] reinforces \the [src] with wood.",  "You reinforce \the [src] with wood.")
			playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
			new /obj/item/furniture_parts/bookshelf(get_turf(src))
			qdel(src)
			qdel(W)
		else
			..()

/* ---------- Bed Parts ---------- */
/obj/item/furniture_parts/bed
	name = "bed parts"
	desc = "A collection of parts that can be used to make a bed."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "bed_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool/bed
	furniture_name = "bed"

/obj/item/furniture_parts/bed/roller
	name = "roller bed parts"
	desc = "A collection of parts that can be used to make a roller bed."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "rbed_parts"
	furniture_type = /obj/stool/bed/moveable
	furniture_name = "roller bed"

/* ---------- Decor Parts ---------- */
/obj/item/furniture_parts/decor/regallamp
	name = "regal lamp parts"
	desc = "A collection of parts that can be used to make a regal lamp."
	icon = 'icons/obj/furniture/walp_decor.dmi'
	icon_state = "lamp_regal_parts"
	furniture_type = /obj/decoration/regallamp
	furniture_name = "regal lamp"
