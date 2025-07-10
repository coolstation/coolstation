
/mob/proc/key_down(var/key)
/mob/proc/key_up(var/key)

/mob/proc/click(atom/target, params)
	//moved the 'actions.interrupt(src, INTERRUPT_ACT)' here to on mob/living
	var/used_ability = src.targeting_ability
	if (!used_ability) used_ability = get_ability_hotkey(src, params)

	if (istype(used_ability, /datum/targetable))
		var/datum/targetable/S = used_ability
		if (S.targeted)
			src.targeting_ability = null
			update_cursor()

			if (!S.target_anything && !ismob(target))
				src.show_text("You have to target a person.", "red")
				if(S.sticky)
					src.targeting_ability = S
					update_cursor()
				return 100
			if (!S.target_in_inventory && !isturf(target.loc) && !isturf(target))
				if(S.sticky)
					src.targeting_ability = S
					update_cursor()
				return 100
			if (S.target_in_inventory && (!IN_RANGE(src, target, 1) && !isturf(target) && !isturf(target.loc)))
				if(S.sticky)
					src.targeting_ability = S
					update_cursor()
				return 100
			if (S.check_range && !IN_RANGE(src, target, S.max_range))
				src.show_text("You are too far away from the target.", "red") // At least tell them why it failed.
				if(S.sticky)
					src.targeting_ability = S
					update_cursor()
				return 100
			if (!S.can_target_ghosts && ismob(target) && (!isliving(target) || iswraith(target) || isintangible(target)))
				src.show_text("It would have no effect on this target.", "red")
				if(S.sticky)
					src.targeting_ability = S
					update_cursor()
				return 100
			if (!S.castcheck(src))
				if(S.sticky)
					src.targeting_ability = S
					update_cursor()
				return 100
			actions.interrupt(src, INTERRUPT_ACTION)
			SPAWN_DBG(0)
				S.handleCast(target)
				if(S)
					if((S.ignore_sticky_cooldown && !S.cooldowncheck()) || (S.sticky && S.cooldowncheck()))
						if(src)
							src.targeting_ability = S
							src.update_cursor()
			return 100

	else if (istype(src.targeting_ability, /obj/ability_button))
		var/obj/ability_button/B = src.targeting_ability

		if (!B.target_anything && !ismob(target) && !istype(target, B))
			src.show_text("You have to target a person.", "red")
			src.targeting_ability = null
			src.update_cursor()
			return 100
		if (!isturf(target.loc) && !isturf(target) && !istype(target, B))
			src.targeting_ability = null
			src.update_cursor()
			return 100
		if (!B.ability_allowed())
			src.targeting_ability = null
			src.update_cursor()
			return 100
		if (istype(target, B))
			return 100
		actions.interrupt(src, INTERRUPT_ACTION)
		SPAWN_DBG(0)
			B.execute_ability(target)
			src.targeting_ability = null
			src.update_cursor()
		return 100

	if (abilityHolder)
		if (abilityHolder.topBarRendered)
			if (abilityHolder.click(target, params))
				return 100
	//Pull cancel 'hotkey'
	if (src.pulling && get_dist(src,target) > 1)
		if (!islist(params))
			params = params2list(params)
		if(params["ctrl"])
			if (src.pulling)
				unpull_particle(src,pulling)
			src.pulling = null

	//circumvented by some rude hack in client.dm; uncomment if hack ceases to exist
	//if (istype(target, /atom/movable/screen/ability))
	//	target:clicked(params)
	if (get_dist(src, target) > 0)
		if(!src.dir_locked)
			set_dir(get_dir(src, target))
			if(dir & (dir-1))
				if (dir & EAST)
					set_dir(EAST)
				else if (dir & WEST)
					set_dir(WEST)

/mob/proc/hotkey(name) //if this gets laggy, look into adding a small spam cooldown like with resting / eating?
	if (name in mouseless_dirnames)
		src.mouseless_interact(mouseless_dirnames[name])
		return
	switch (name)
		if ("look_n")
			if(!dir_locked)
				src.set_dir(NORTH)
		if ("look_s")
			if(!dir_locked)
				src.set_dir(SOUTH)
		if ("look_e")
			if(!dir_locked)
				src.set_dir(EAST)
		if ("look_w")
			if(!dir_locked)
				src.set_dir(WEST)
		if ("admin_interact")
			src.admin_interact_verb()
		if ("stop_pull")
			if (src.pulling)
				unpull_particle(src,pulling)
			src.pulling = null

/**
	* Return the ability bound to the pressed ability hotkey combination
  */
/mob/proc/get_ability_hotkey(mob/user, parameters)
	if(!parameters["left"]) return
	if(!user?.abilityHolder) return
	if(parameters["ctrl"] && user.abilityHolder.ctrlPower)
		return user.abilityHolder.ctrlPower
	if(parameters["alt"] && user.abilityHolder.altPower)
		return user.abilityHolder.altPower
	if(parameters["shift"] && user.abilityHolder.shiftPower)
		return user.abilityHolder.shiftPower

/**
	* Additiviely applies keybind styles onto the client's keymap.
	*
	* To be extended upon in children types that want to have special keybind handling.
	*
	* Call this proc first, and then do your specific application of keybind styles.
	*/
/mob/proc/build_keybind_styles(client/C)
	SHOULD_CALL_PARENT(TRUE)

	if (!C.keymap)
		C.keymap = new

	C.apply_keybind("base")

	if (C.preferences?.use_azerty) // runtime : preferences is null? idk why, bandaid for now
		C.apply_keybind("base_azerty")
	if (C.tg_controls)
		C.apply_keybind("base_tg")
	if (C.experimental_mouseless)
		C.apply_keybind("mouseless")

/**
	* Applies the client's custom keybind changelist, fetched from the cloud.
	*
	* Called by build_keybind_styles if not resetting the custom keybinds of a u
	*/
/mob/proc/apply_custom_keybinds(client/C)
	PROTECTED_PROC(TRUE)

	if(!C || !C.cloud_available())
		//logTheThing("debug", null, null, "<B>ZeWaka/Keybinds:</B> Attempted to fetch custom keybinds for [C.ckey] but failed.")
		return

	var/fetched_keylist = C.cloud_get("custom_keybind_data")
	if (!isnull(fetched_keylist)) //The client has a list of custom keybinds.
		var/datum/keymap/new_map = new /datum/keymap(json_decode(fetched_keylist))
		C.keymap.overwrite_by_action(new_map)
		C.keymap.on_update(C)

/**
	* Builds the mob's keybind styles, checks for valid movement controllers, and finally sets the keymap.
	*
	* Called on: Login, Vehicle change, WASD/TG/AZERTY toggle, Keybind menu Reset
	*/
/mob/proc/reset_keymap()
	if (src.client)
		src.client.applied_keybind_styles = list() //Reset currently applied styles
		build_keybind_styles(src.client)
		apply_custom_keybinds(src.client)
		var/datum/movement_controller/controller = src.override_movement_controller
		if (controller)
			controller.modify_keymap(src.client)

//I couldn't think of a better way to do this than give it it's own proc,
//but probably just as well since AFAIK there's no way to specify what you're targeting on a turf like a rat can.

//
/mob/proc/mouseless_interact(direction)
	if (isnull(direction))
		return
	if (!src.client)
		return
	//Determine the turf we're getting at
	var/turf/target_turf
	if (direction == "CENTER")
		target_turf = get_turf(src)
	else
		target_turf = get_step(src, direction)

	var/atom/click_target = null


	//Look for modifier keys.

	//The priority stuff here is my best guess and probably better suited by adding a ratless priority var on /atom/movable
	if (src.client.keys_modifier & MODIFIER_CTRL) //target the turf itself
		click_target = target_turf


	//else if (src.client.keys_modifier & MODIFIER_SHIFT) //target mobs

				//if (isdead(click_target) && isalive(possible_mob)) //prioritise living folks
				//	click_target = possible_mob

	else if (src.client.keys_modifier & MODIFIER_ALT) //non-item objects, like closets and shit
		for(var/obj/possible_object in target_turf)
			if (istype(possible_object, /obj/overlay))
				continue

			//if (istype(possible_object, /obj/window) && istype(click_target, ))
			//Machinery is probably the most important crap for folks
			if (istype(possible_object, /obj/machinery) && !istype(click_target, /obj/machinery))
				click_target = possible_object

			if (!click_target)
				click_target = possible_object
				continue

	else //target items by default
		//var/list/items = list()
		if (!isghostdrone(src)) //Only bap ghost friends
			for(var/mob/possible_mob in target_turf)
				if (isobserver(possible_mob)) //no targeting ghosts...yet?
					continue
				if (iswraith(possible_mob))
					click_target = possible_mob
					break //Wraiths probably the highest priority weird mob, so
				if (!click_target)
					click_target = possible_mob
					continue

		if (!click_target)
			for(var/obj/item/possible_item in target_turf)
				if (!possible_item.anchored) //Filter out weird things like pianos and wall cabinets
					click_target = possible_item
					break

	if (click_target)
		src.client.Click(click_target, target_turf, params = list("icon-x" = "16", "icon-y" = "16", "left" = "1", "button" = "left"))
