/obj/item/lifted_thing
	name = "lifted thing"
	desc = "Call a coder, this isn't correct!"
	icon_state = "lift_dummy"
	inhand_image_icon = 'icons/mob/inhand/hand_large_things.dmi'

	flags = SUPPRESSATTACK | TECHNICAL_ATOM

	two_handed = TRUE
	force = 10 //It's probably heavy. Not that it matters because we've got SUPPRESSATTACK going to avoid messages.

	var/obj/our_thing = null
	var/machine_was_previously_processing = FALSE

	w_class = W_CLASS_BULKY

	New(obj/held_thing, mob/living/holder)
		if (!istype(held_thing) || !istype(holder))
			qdel(src)
			return
		if (holder.r_hand?.cant_drop || holder.l_hand?.cant_drop) //can't free up hands
			qdel(src)
			return
		if (holder.r_hand) //force clear hands
			holder.r_hand.set_loc(holder.loc)
			holder.u_equip(holder.r_hand)
		if (holder.l_hand)
			holder.l_hand.set_loc(holder.loc)
			holder.u_equip(holder.l_hand)
		..()

		if (istype(held_thing, /obj/machinery))
			var/obj/machinery/M = held_thing
			if (M.current_processing_tier)
				machine_was_previously_processing = TRUE
				M.UnsubscribeProcess()
		our_thing = held_thing
		//gross, will probably have to make a goshdarn extra var on /obj once this immediately stops working
		src.item_state = "[our_thing.type]"
		//This happens first because the wrapper is spawned inside the object it's meant to be wrapping. We have to be clear of that before we can set_loc() the object.
		if (holder.put_in_hand(src))
			MAKE_PICKUP_SOUND(src, holder.loc) //put_in_hand_or_drop doesn't return the right success codes uuuugh
		else
			our_thing = null
			qdel(src)
			return
		our_thing.set_loc(src)
		src.name = our_thing.name
		src.desc = our_thing.desc
		src.icon = our_thing.icon
		src.icon_state = our_thing.icon_state //probably fine not copying overlays atm
		src.color = our_thing.color


		APPLY_MOVEMENT_MODIFIER(holder, /datum/movement_modifier/lifting, "lifting")

	//passthroughs for examining and tooltips
	get_desc()
		. = our_thing?.get_desc()

	special_desc(dist, mob/user)
		. = our_thing?.special_desc(dist, user)

	emp_act()
		. = our_thing?.emp_act()

	ex_act(severity, last_touched, epicenter)
		. = our_thing?.ex_act(severity, last_touched, epicenter)
		if (our_thing?.disposed) //thing broke
			our_thing = null
			qdel(src)

	afterattack(atom/target, mob/user, reach, params)
		if ((istype(target, /turf) && !target.density) || istype(target, /obj/table))
			place_the_thing(target, user, params)
		else
			. = ..()

	disposing()
		if (our_thing) //ah fuck
			place_the_thing(get_turf(src), ismob(src.loc) ? src.loc : null)
		. = ..()

	dropped(mob/user)
		..()
		if (our_thing)
			place_the_thing(get_turf(user), user)


/obj/item/lifted_thing/proc/place_the_thing(atom/target, mob/user, var/params)
	if (!target)
		target = get_turf(src)
	our_thing.set_loc(get_turf(target))
	if (islist(params) && params["icon-y"] && params["icon-x"])
		our_thing.pixel_x = text2num(params["icon-x"]) - 16
		our_thing.pixel_y = text2num(params["icon-y"]) - 16
	if (machine_was_previously_processing)
		var/obj/machinery/M = our_thing
		M.SubscribeToProcess()
	our_thing = null
	if (user)
		REMOVE_MOVEMENT_MODIFIER(user, /datum/movement_modifier/lifting, "lifting")
	qdel(src)
