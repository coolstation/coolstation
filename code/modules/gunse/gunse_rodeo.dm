//St. Tite Nickelworks "Rodeo" Gunse
//Chunky, break action
ABSTRACT_TYPE(/obj/item/gun/modular/rodeo)
/obj/item/gun/modular/rodeo
	name = "abstract rodeo gun"
	real_name = "abstract rodeo gun"
	desc = "abstract type do not instantiate"
	icon = 'icons/obj/items/modular_guns/receivers.dmi'
	gun_DRM = GUN_RODEO
	jam_frequency = 2
	hint = "Spin the gun, drag it to itself, or use it in hand to open it up for loading bullets and ejecting casings."
	var/broke_open = FALSE
	var/break_action_cooldown = 0.3 SECONDS

	proc/open_break()
		if(ON_COOLDOWN(src, "breakaction", src.break_action_cooldown) || !src.barrel || !src.built || src.broke_open)
			return
		src.broke_open = TRUE
		src.eject_casings()
		var/image/I = src.GetOverlayImage("1")
		if(!I)
			return
		I.transform = matrix(I.transform, 90, MATRIX_ROTATE)
		I.pixel_x = 2 + src.barrel_overlay_x
		I.pixel_y = 2 - src.barrel.overlay_x
		src.UpdateOverlays(I, "1")

	proc/close_break()
		if(ON_COOLDOWN(src, "breakaction", src.break_action_cooldown) || !src.barrel || !src.built || !src.broke_open)
			return
		if(src.jammed)
			return src.unjam()
		src.broke_open = FALSE
		var/image/I = src.GetOverlayImage("1")
		if(!I)
			return
		I.pixel_x = src.barrel.overlay_x
		I.pixel_y = src.barrel.overlay_y
		I.transform = matrix(I.transform, -90, MATRIX_ROTATE)
		src.UpdateOverlays(I, "1")

	shoot(target, start, mob/user, POX, POY, is_dual_wield, mob/point_blank_target)
		. = ..()
		src.process_ammo(user)

	canshoot()
		if(src.broke_open && src.barrel)
			return FALSE
		. = ..()

	reset_gun()
		src.broke_open = FALSE
		..()

	MouseDrop_T(obj/O as obj, mob/user as mob)
		if(src.built && O == src && GET_DIST(src, user) <= 1)
			if(src.broke_open)
				src.close_break()
			else
				src.open_break()
		else
			return ..()

	on_spin_emote(mob/living/carbon/human/user)
		. = ..()
		if(!src.built)
			return
		if(src.broke_open)
			src.close_break()
		else
			src.open_break()

	attack_self(mob/user)
		if(src.built)
			if(src.broke_open)
				src.close_break()
			else
				src.open_break()
		else
			. = ..()
		SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user)

	cannotload()
		if (!src.broke_open)
			return "<span class='notice'>You'll need to open the gun!</span>"
		return ..()

ABSTRACT_TYPE(/obj/item/gun/modular/rodeo/maresleg)
/obj/item/gun/modular/rodeo/maresleg
	name = "abstract St. Tite mare's leg"
	real_name = "abstract St. Tite mare's leg"
	icon_state = "rodeo_short"
	spread_angle = 4
	barrel_overlay_x = 4
	grip_overlay_x = -2
	grip_overlay_y = -2
	stock_overlay_x = -3
	stock_overlay_y = -2
	load_time = 0.2 SECONDS
	max_ammo_capacity = 1
	bulkiness = 2
	w_class = W_CLASS_SMALL

/obj/item/gun/modular/rodeo/maresleg/basic
	name = "basic St. Tite mare's leg"
	real_name = "\improper Wild Mare"
	desc = "A serviceable sidearm for a cowpoke."

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/rodeo(src)
		stock = new /obj/item/gun_parts/stock/rodeo(src)
