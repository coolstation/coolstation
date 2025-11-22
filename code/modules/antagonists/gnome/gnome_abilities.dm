// nasty shapeshifting gnomes

/datum/abilityHolder/gnome
	regenRate = 0
	points = 0
	pointName = "Viscera"
	var/disguise_health = 25
	var/max_disguise_health = 50
	var/disguised = FALSE
	var/obj/item/gnome_disguise/disguise

	New()
		..()
		src.addAbility(/datum/targetable/gnome/disguise)
		src.addAbility(/datum/targetable/gnome/gnaw)

	onLife(var/mult = 1)
		src.disguise_health = min(src.disguise_health + (src.disguised ? 0.1 : 1) * mult, src.max_disguise_health)
		if(src.disguise)
			src.disguise._max_health = src.max_disguise_health
			src.disguise.setHealth(src.disguise_health)
		src.updateText()
		. = ..()

	onAbilityStat()
		..()
		.= list()
		.["Viscera:"] = src.points
		.["Disguise:"] = floor(src.disguise_health)
		return

	disposing()
		qdel(src.disguise)
		src.disguise = null
		. = ..()

/datum/targetable/gnome
	icon = 'icons/ui/critter_ui.dmi'
	icon_state = "gnomedisguise"
	cooldown = 0
	last_cast = 0
	targeted = 1
	target_anything = 1
	preferred_holder_type = /datum/abilityHolder/gnome
	turf_check = FALSE
	var/datum/abilityHolder/gnome/gnome_holder

	onAttach(datum/abilityHolder/H)
		. = ..()
		src.gnome_holder = H

	disposing()
		src.gnome_holder = null
		..()

/obj/item/gnome_disguise
	name = "squishy mass"
	desc = "mylie coded bad (you shouldnt see this)"
	real_name = "squishy mass"
	real_desc = "It faintly wriggles. This thing is alive."
	burn_point = T0C + 350
	cannot_be_stored = TRUE
	p_class = 2
	pickup_sfx = "sound/impact_sounds/Slimy_Cut_1.ogg"
	_max_health = 25
	_health = 25
	soundproofing = -1
	cant_drop = TRUE
	force = 3
	// world time when last transforming, attacked, etc
	var/last_interacted = 1
	var/disguise_scaling = 8
	var/datum/abilityHolder/gnome/ability_holder_master
	var/datum/movement_controller/obj_control/gnome/movement_controller

	New(atom/loc, var/datum/abilityHolder/gnome/_ability_holder_master)
		..()
		src.ability_holder_master = _ability_holder_master
		src.movement_controller = new(src)
		src._max_health = src.ability_holder_master.max_disguise_health
		src.setHealth(src.ability_holder_master.disguise_health)

	proc/disguise_as(var/obj/item/target)
		src.appearance = target.appearance
		src.alpha = 255
		src.inhand_image = target.inhand_image
		src.inhand_image_icon = target.inhand_image_icon
		src.inhand_color = target.inhand_color
		src.item_state = target.item_state
		src.w_class = target.w_class

		src.last_interacted = world.time
		playsound(src.loc, "sound/impact_sounds/Slimy_Cut_1.ogg", 45, 1)
		animate_shake(src, amount = 1 SECOND, x_severity = 6, y_severity = 5, return_x = rand(-12, 12), return_y = rand(-12, 12))
		return

	Move(NewLoc, direct)
		. = ..()
		animate_shake(src, 1, 2, 1, src.pixel_x * 0.95, src.pixel_y * 0.95)

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
		if(src.loc != user && (user.intent != INTENT_HARM || (TIME >= (src.l_move_time + 2 SECONDS)) && (world.time >= (src.last_interacted + 2 SECONDS))))
			if (..())
				for (var/mob/M in src.contents)
					boutput(M, SPAN_ALERT("[user] foolishly gets in range of your teeth!"))
					src.last_interacted = world.time
		else
			if(src.loc == user)
				if(ON_COOLDOWN(user, "gnome_prying", 5 SECONDS))
					return
				playsound(user.loc, "sound/impact_sounds/Slimy_Cut_1.ogg", 40, 1)
				user.visible_message(SPAN_ALERT("[src] can't be pried off without a weapon!"))
			else
				playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
				src.visible_message(SPAN_COMBAT("[src] deforms and crumples wetly when hit!"))
				src.changeHealth(-5)
			for (var/mob/M in src.contents)
				boutput(M, SPAN_COMBAT("[user] punches at you!"))
			src.last_interacted = world.time
			user.next_click = world.time + user.combat_click_delay
			attack_twitch(user)
			hit_twitch(src)

	pickup(mob/user)
		user.emote("scream")
		hit_twitch(user)
		shake_camera(user, 1, 2)
		boutput(user, SPAN_ALERT("[src] bites you [src.cant_drop ? "ferociously" : "loosely"]! Holy fuck, beat it to death!"))
		take_bleeding_damage(user, src.ability_holder_master.owner, 6, DAMAGE_CUT)
		user.TakeDamage(user.hand ? "l_arm" : "r_arm", rand(10,35), 0, 0, DAMAGE_STAB)
		if(isvalidantagmeal(user))
			src.ability_holder_master.points += 3

	attackby(obj/item/W, mob/user, params)
		if(!(W?.force))
			return ..()

		if(src.loc == user)
			if(world.time < user.next_click)
				return
			playsound(user.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
			user.visible_message(SPAN_COMBAT("[src] deforms and wriggles wetly when hit!"))
			src.changeHealth(-W.force / 2)
		else
			playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
			src.visible_message(SPAN_COMBAT("[src] crumples like fleshy tissue paper when hit!"))
			src.changeHealth(-W.force)
		for (var/mob/M in src.contents)
			boutput(M, SPAN_COMBAT("[user] attacks you with \the [W]!"))

		src.last_interacted = world.time
		user.next_click = world.time + W.combat_click_delay
		attack_twitch(user)
		hit_twitch(src)
		. = ..()

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		. = ..()
		if(isturf(hit_atom) && !hit_atom.density)
			return
		if(prob(75) || thr.get_throw_travelled() < 3)
			playsound(src.loc, "sound/impact_sounds/Wet_Gnome_Thud.ogg", 60, 1)
			src.visible_message(SPAN_COMBAT("[src] slams against [hit_atom] and makes a loud thud!"))
			src.changeHealth(-5)
		else
			playsound(src.loc, "sound/impact_sounds/Wet_Gnome_Scream.ogg", 60, 0)
			src.visible_message(SPAN_COMBAT("[src] slams against [hit_atom] and screams in agony!"))
			src.changeHealth(-30)

	updateHealth(var/prevHealth)
		..()
		if(src.ability_holder_master)
			src.ability_holder_master.disguise_health = _health
		if(_health <= _max_health * 0.5)
			if(src.cant_drop && ismob(src.loc))
				var/mob/M = src.loc
				boutput(M, SPAN_ALERT("\The [src] loosens it's grip!"))
			src.cant_drop = FALSE
		else
			src.cant_drop = TRUE

	onDestroy()
		var/turf/T = get_turf(src)
		for (var/atom/movable/AM in src)
			AM.set_loc(T)
		src.ability_holder_master.owner.visible_message(SPAN_ALERT("[src] unfurls into a hideous little gnome!"))
		return ..()

	disposing()
		var/turf/T = get_turf(src)
		for (var/atom/movable/AM in src)
			AM.set_loc(T)
		if(src.ability_holder_master)
			src.ability_holder_master.removeAbility(/datum/targetable/gnome/shed_disguise)
			src.ability_holder_master.disguised = FALSE
			src.ability_holder_master.updateButtons()
			src.ability_holder_master.disguise = null
			src.ability_holder_master = null
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
	icon_state = "gnomedisguise"
	name = "Disguise"
	desc = "Hide yourself as an imitation of a nearby item."
	pointCost = 0
	cooldown = 10 SECONDS
	max_range = 3
	var/minimum_visible_pixels = 35

	cast(var/obj/item/target)
		if (..())
			return 1

		if(src.gnome_holder.disguise_health <= 5)
			boutput(src.holder.owner, __red("Your disguise is too weak to maintain!"))
			return 1

		if (GET_DIST(src.holder.owner, target) > src.max_range)
			boutput(src.holder.owner, __red("That target is too far away to imitate."))
			return 1

		if (!target)
			target = get_turf(src.holder.owner)
		else if (!isitem(target) || !(target.w_class <= W_CLASS_BULKY && !target.anchored && target.icon && target.icon_state))
			target = get_turf(target)

		if (isturf(target))
			var/turf/T = target
			for (var/obj/item/possible_target in T.contents)
				if (possible_target.w_class <= W_CLASS_BULKY && !possible_target.anchored && possible_target.icon && possible_target.icon_state)
					target = possible_target
					break

		if (!isitem(target))
			boutput(src.holder.owner, __red("You don't see anything to imitate there."))
			return 1

		var/icon/target_icon = getFlatIcon(target)

		if(!target_icon)
			boutput(src.holder.owner, __red("You don't think you can make yourself into that shape."))
			return 1

		if(target_icon.Width() > 48 || target_icon.Height() > 48)
			boutput(src.holder.owner, __red("You don't think you can stretch yourself into that shape that large."))
			return 1

		var/pixel_count = 0
		for(var/x=1, x<=target_icon.Width(), x++)
			for(var/y=1, y<=target_icon.Height(), y++)
				if(!isnull(target_icon.GetPixel(x, y)))
					pixel_count++
		if(src.minimum_visible_pixels > pixel_count)
			boutput(src.holder.owner, __red("You don't think you can cram yourself into that small of a shape."))
			return 1

		if(!src.gnome_holder.disguise || QDELETED(src.gnome_holder.disguise))
			src.gnome_holder.disguise = new(src.holder.owner.loc, src.gnome_holder)
		else if(ismob(src.gnome_holder.disguise.loc))
			src.gnome_holder.disguise.set_loc(get_turf(src.gnome_holder.disguise))
		else
			src.gnome_holder.disguise.set_loc(src.holder.owner.loc)

		src.gnome_holder.disguise.disguise_as(target)
		src.gnome_holder.disguise.disguise_scaling = floor(sqrt(pixel_count))
		src.holder.owner.set_loc(src.gnome_holder.disguise)
		src.holder.owner.override_movement_controller = src.gnome_holder.disguise.movement_controller

		src.holder.addAbility(/datum/targetable/gnome/shed_disguise)
		src.gnome_holder.disguised = TRUE

		boutput(src.holder.owner, __blue("You disguise yourself as \the [target]."))

		return 0

	disposing()
		if(src.holder?.owner?.loc == src.gnome_holder.disguise)
			src.holder.owner.set_loc(get_turf(src.gnome_holder.disguise))
		qdel(src.gnome_holder.disguise)
		src.gnome_holder.disguise = null
		. = ..()

/datum/targetable/gnome/shed_disguise
	icon_state = "gnomeshed"
	name = "Shed Disguise"
	desc = "Remove your disguise and return to your natural form."
	pointCost = 0
	cooldown = 0
	targeted = FALSE
	special_screen_loc = "SOUTH,WEST"

	cast()
		if(src.gnome_holder.disguised)
			var/turf/T = get_turf(src.gnome_holder.disguise)
			for (var/atom/movable/AM in src.gnome_holder.disguise)
				AM.set_loc(T)
			src.gnome_holder.disguise.set_loc(src.holder.owner)
			src.gnome_holder.owner.override_movement_controller = null
			src.gnome_holder.disguised = FALSE
			boutput(src.holder.owner, __blue("You shed your disguise."))
			src.holder.removeAbilityInstance(src)
			return 0
		else
			return 1

/datum/targetable/gnome/gnaw
	icon_state = "gnomegnaw"
	name = "Gnaw"
	desc = "Take a bite of someone. If you are disguised and bite from behind, you won't even twitch."
	pointCost = 0
	cooldown = 20 SECONDS
	max_range = 1
	ai_range = 1
	attack_mobs = TRUE
	turf_check = FALSE

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

		if (!istype(target) || target == src.holder.owner)
			var/turf/T = get_turf(target)
			for (var/mob/living/possible_target in T.contents)
				if(possible_target != src.holder.owner)
					target = possible_target
					break

		if (!istype(target))
			boutput(src.holder.owner, __red("You don't see anything to bite there."))
			return 1

		if(!isnull(disguise))
			if (!(target.dir & get_dir(target, disguise)))
				if(isvalidantagmeal(target))
					src.holder.points++
				boutput(target, SPAN_COMBAT("Something just bit you! It burns!"))
				boutput(src.holder.owner, SPAN_COMBAT("You bite [target] stealthily!"))
			else
				target.was_harmed(src.holder.owner)
				violent_standup_twitch(disguise)
				disguise.visible_message(SPAN_COMBAT("\The [disguise] unfurls fangs and bites [target]!"))
				boutput(src.holder.owner, SPAN_COMBAT("You bite [target], giving away your position!"))
		else
			attack_twitch(src.holder.owner)
			target.was_harmed(src.holder.owner)
			target.emote("scream")
			src.holder.owner.visible_message(SPAN_COMBAT("[src.holder.owner] bites [target] with dozens of needlelike fangs!"), SPAN_COMBAT("You sink your full fangs into [target]!"))

		playsound(target, "sound/impact_sounds/Flesh_Stab_1.ogg", 45, 1, -1)
		target.TakeDamageAccountArmor("All", isnull(disguise) ? rand(5, 15) : rand(disguise.disguise_scaling / 2, disguise.disguise_scaling), 0, 0, DAMAGE_STAB)
		target.changeStatus("disorient", 3 SECONDS)

