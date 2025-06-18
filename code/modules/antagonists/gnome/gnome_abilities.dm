// nasty shapeshifting gnomes

/datum/abilityHolder/gnome
	regenRate = 0
	points = 0
	pointName = "Viscera"
	onAbilityStat()
		..()
		.= list()
		.["Viscera consumed:"] = points
	New()
		..()
		src.addAbility(/datum/targetable/gnome/disguise)
		src.addAbility(/datum/targetable/gnome/gnaw)

/datum/targetable/gnome
	icon = 'icons/ui/blob_ui.dmi'
	icon_state = "blob-reclaimer"
	cooldown = 0
	last_cast = 0
	targeted = 1
	target_anything = 1
	preferred_holder_type = /datum/abilityHolder/gnome
	var/datum/abilityHolder/blob/gnome_holder

	onAttach(datum/abilityHolder/H)
		. = ..()
		src.gnome_holder = H

/obj/item/gnome_disguise
	name = "gnome disguise (you shouldnt see this)"
	desc = "mylie coded bad (you shouldnt see this)"
	real_name = "squishy mass"
	real_desc = "It faintly wriggles. This thing is alive."
	burn_point = T0C + 400
	cannot_be_stored = TRUE
	p_class = 2
	pickup_sfx = "sound/impact_sounds/Slimy_Cut_1.ogg"
	_max_health = 50
	soundproofing = -1
	cant_drop = TRUE
	force = 3
	// world time when last transforming, attacked, etc
	var/last_interacted = 1
	var/datum/targetable/gnome/disguise/ability_master
	var/datum/movement_controller/obj_control/gnome/movement_controller

	New(atom/loc, var/datum/targetable/gnome/disguise/_ability_master)
		..()
		src.ability_master = _ability_master
		src.movement_controller = new(src)

	proc/disguise_as(var/obj/item/target)
		src.appearance = target.appearance
		src.alpha = 255
		src.inhand_image = target.inhand_image
		src.inhand_image_icon = target.inhand_image_icon
		src.inhand_color = target.inhand_color
		src.item_state = target.item_state
		src.w_class = clamp(target.w_class, W_CLASS_SMALL, W_CLASS_NORMAL)

		src.last_interacted = world.time
		playsound(src.loc, "sound/impact_sounds/Slimy_Cut_1.ogg", 45, 1)
		animate_shake(src, amount = 1 SECOND, x_severity = 6, y_severity = 5, return_x = rand(-12, 12), return_y = rand(-12, 12))
		return

	Move(NewLoc, direct)
		. = ..()
		animate_shake(src, 1, 2, 1, src.pixel_x * 0.95, src.pixel_y * 0.95)

	get_movement_controller(mob/user)
		. = ..()
		return movement_controller

	mob_flip_inside(mob/user)
		if(ismob(src.loc))
			if(!ON_COOLDOWN(src, "gnome_venom_cooldown", 4.5 SECONDS))
				var/mob/M = src.loc
				boutput(user, "You thrash and inject venom.")
				boutput(M, SPAN_COMBAT("[src] thrashes and you feel the burn of venom!"))
				playsound(M, "sound/impact_sounds/Slimy_Hit_4.ogg", 50, 1)
				M.reagents.add_reagent("histamine", 2)
		else
			boutput(user, "You rustle around to better hide.")
			playsound(src.loc, "sound/impact_sounds/Slimy_Cut_1.ogg", 35, 1)
		animate_shake(src, amount = 0.3 SECONDS, x_severity = 5, y_severity = 4, return_x = (src.pixel_x + rand(-5, 5)) * 0.9, return_y = (src.pixel_y + rand(-5, 5)) * 0.9)
		return TRUE

	attack_hand(mob/user)
		if((TIME >= (src.l_move_time + 6 SECONDS)) && (world.time >= (src.last_interacted + 12 SECONDS)))
			if (..())
				for (var/mob/M in src.contents)
					boutput(M, SPAN_ALERT("[user] foolishly picks you up!"))
					src.last_interacted = world.time
		else
			for (var/mob/M in src.contents)
				boutput(M, SPAN_COMBAT("[user] punches at you!"))
			if(src.loc == user)
				playsound(user.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
				user.visible_message(SPAN_COMBAT("[src] deforms and crumples wetly when hit!"))
				src.changeHealth(-3)
			else
				playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
				src.visible_message(SPAN_COMBAT("[src] deforms and crumples wetly when hit!"))
				src.changeHealthy(-15)
			src.last_interacted = world.time
			user.next_click = world.time + user.combat_click_delay
			attack_twitch(user)
			hit_twitch(src)

	pickup(mob/user)
		boutput(user, SPAN_ALERT("[src] bites you [src.cant_drop ? "ferociously" : "loosely"]! Holy fuck, beat it to death!"))
		take_bleeding_damage(user, src.ability_master.holder.owner, 6, DAMAGE_CUT)
		user.TakeDamage(user.hand ? "l_arm" : "r_arm", rand(10,35), 0, 0, DAMAGE_STAB)

	attackby(obj/item/W, mob/user, params)
		user.lastattacked = src
		if(!(W?.force))
			return ..()
		for (var/mob/M in src.contents)
			boutput(M, SPAN_COMBAT("[user] attacks you with \the [W]!"))
		if(src.loc == user)
			playsound(user.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
			user.visible_message(SPAN_COMBAT("[src] deforms and crumples wetly when hit!"))
			src.changeHealth(-W.force / 3)
		else
			playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
			src.visible_message(SPAN_COMBAT("[src] deforms and crumples wetly when hit!"))
			src.changeHealth(-W.force * 2)
			take_bleeding_damage(src.ability_master.holder.owner, user, 4)
		src.last_interacted = world.time
		. = ..()

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		. = ..()
		if(isturf(hit_atom) && !hit_atom.density)
			return
		if(prob(90) || thr.get_throw_travelled() < 3)
			playsound(src.loc, "sound/impact_sounds/Wet_Gnome_Thud.ogg", 50, 1)
			src.visible_message(SPAN_COMBAT("[src] slams against [hit_atom] and makes a loud thud!"))
		else
			playsound(src.loc, "sound/impact_sounds/Wet_Gnome_Scream.ogg", 50, 0)
			src.visible_message(SPAN_COMBAT("[src] slams against [hit_atom] and screams in agony!"))
			src.changeHealth(-50)

	updateHealth(var/prevHealth)
		if(_health <= 10)
			if(src.cant_drop && ismob(src.loc))
				var/mob/M = src.loc
				boutput(M, SPAN_ALERT("\The [src] loosens it's grip!"))
			src.cant_drop = FALSE
		else
			src.cant_drop = TRUE
		..()

	onDestroy()
		var/turf/T = get_turf(src)
		for (var/atom/movable/AM in src)
			AM.set_loc(T)
		src.ability_master.holder.owner.visible_message(SPAN_ALERT("[src] unfurls into a hideous little gnome!"))
		return ..()

	disposing()
		var/turf/T = get_turf(src)
		for (var/atom/movable/AM in src)
			AM.set_loc(T)
		if(src.ability_master)
			src.ability_master.doCooldown()
			src.ability_master.holder.removeAbility(/datum/targetable/gnome/shed_disguise)
			src.ability_master.holder.updateButtons()
			src.ability_master.disguise_dummy = null
			src.ability_master = null
		. = ..()

	assume_air(datum/air_group/giver)
		if (loc)
			var/turf/T = get_turf(loc)
			return T.assume_air(giver)
		else
			return null

	remove_air(amount)
		if (loc)
			var/turf/T = get_turf(loc)
			return T.remove_air(amount)
		else
			return null

	return_air()
		if (loc)
			var/turf/T = get_turf(loc)
			return T.return_air()
		else
			return null

/datum/targetable/gnome/disguise
	name = "Disguise"
	desc = "Hide yourself as an imitation of a nearby item. Solidifying like this will prevent squeezing under airlocks."
	pointCost = 0
	cooldown = 30 SECONDS
	max_range = 3
	var/obj/item/gnome_disguise/disguise_dummy

	cast(var/obj/item/target)
		if (..())
			return 1

		if (GET_DIST(src.holder.owner, target) > src.max_range)
			boutput(src.holder.owner, __red("That target is too far away to imitate."))
			return 1

		if (!target)
			target = get_turf(src.holder.owner)
		else if (!isitem(target) || !(target.w_class <= W_CLASS_NORMAL && !target.anchored && target.icon && target.icon_state))
			target = get_turf(target)

		if (isturf(target))
			var/turf/T = target
			for (var/obj/item/possible_target in T.contents)
				if (possible_target.w_class <= W_CLASS_NORMAL && !possible_target.anchored && possible_target.icon && possible_target.icon_state)
					target = possible_target
					break

		if (!isitem(target))
			boutput(src.holder.owner, __red("You don't see anything to imitate there."))
			return 1

		if(!src.disguise_dummy || QDELETED(src.disguise_dummy))
			src.disguise_dummy = new(src.holder.owner.loc, src)
		else
			src.disguise_dummy.set_loc(src.holder.owner.loc)

		src.disguise_dummy.disguise_as(target)
		src.holder.owner.set_loc(src.disguise_dummy)

		src.holder.addAbility(/datum/targetable/gnome/shed_disguise)

		boutput(src.holder.owner, __blue("You disguise yourself as \the [target]."))

		return 0

	disposing()
		if(src.holder?.owner?.loc == src.disguise_dummy)
			src.holder.owner.set_loc(get_turf(src.disguise_dummy))
		qdel(src.disguise_dummy)
		src.disguise_dummy = null
		. = ..()

/datum/targetable/gnome/shed_disguise
	name = "Shed Disguise"
	desc = "Remove your disguise and return to your natural form."
	pointCost = 0
	cooldown = 0
	targeted = FALSE
	special_screen_loc = "SOUTH,WEST"

	cast()
		if(istype(src.holder.owner.loc, /obj/item/gnome_disguise))
			var/obj/item/gnome_disguise/disguise = src.holder.owner.loc
			var/turf/T = get_turf(disguise)
			for (var/atom/movable/AM in disguise)
				AM.set_loc(T)
			disguise.set_loc(src.holder)
			boutput(src.holder.owner, __blue("You shed your disguise."))
			src.holder.removeAbilityInstance(src)
			return 0
		else
			return 1

/datum/targetable/gnome/gnaw
	name = "Gnaw"
	desc = "Take a bite of someone. If you are disguised and bite from behind, you won't even twitch."
	pointCost = 0
	cooldown = 20 SECONDS
	max_range = 1

	cast(var/mob/living/target)
		if (..())
			return 1

		var/obj/item/gnome_disguise/disguise = null
		if (istype(src.holder.owner.loc, /obj/item/gnome_disguise))
			disguise = src.holder.owner.loc

		if(!disguise && !isturf(src.holder.owner.loc))
			boutput(src.holder.owner, __red("You can't bite from in here!"))
			return 1

		if (GET_DIST(src.holder.owner, target) > src.max_range)
			boutput(src.holder.owner, __red("That target is too far away to bite."))
			return 1

		if (!istype(target))
			var/turf/T = get_turf(target)
			for (var/mob/living/possible_target in T.contents)
				target = possible_target
				break

		if (!istype(target))
			boutput(src.holder.owner, __red("You don't see anything to bite there."))
			return 1

		if(!isnull(disguise))
			if (!(target.dir & get_dir(target, disguise)))
				src.holder.points++
				boutput(target, SPAN_COMBAT("Something just bit you! It burns!"))
				boutput(src.holder.owner, SPAN_COMBAT("You bite [target] stealthily!"))
			else
				target.was_harmed(src.holder.owner)
				violent_standup_twitch(disguise)
				disguise.visible_message(SPAN_COMBAT("\The [disguise] unfurls fangs and viciously bites [target]!"))
				boutput(src.holder.owner, SPAN_COMBAT("You bite [target], giving away your position!"))
		else
			target.was_harmed(src.holder.owner)
			target.emote("scream")
			src.holder.owner.visible_message(SPAN_COMBAT("[src.holder.owner] bites [target] with dozens of needlelike fangs!"), SPAN_COMBAT("You sink your full fangs into [target]!"))

		playsound(target, "sound/impact_sounds/Flesh_Stab_1.ogg", 45, 1, -1)
		target.TakeDamageAccountArmor("All", rand(2, isnull(disguise) ? 20 : 8), 0, 0, DAMAGE_STAB)
		target.changeStatus("disoriented", 2 SECONDS)








