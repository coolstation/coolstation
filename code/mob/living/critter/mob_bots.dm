/**
 * Playable bots
 */
ABSTRACT_TYPE(/mob/living/critter/robotic/bot)
/mob/living/critter/robotic/bot
	name = "base bot mob (you should never see me)"
	icon = 'icons/obj/bots/aibots.dmi'
	blood_id = "oil"
	speechverb_say = "beeps"
	speechverb_gasp = "warbles"
	speechverb_stammer = "bleeps"
	speechverb_exclaim = "boops"
	speechverb_ask = "bloops"
	stepsound = "step_plating"
	robot_talk_understand = TRUE
	hand_count = 1
	density = FALSE
	custom_gib_handler = /proc/robogibs
	stepsound = null
	pass_unstable = PRESERVE_CACHE
	flags = FPRINT | FLUID_SUBMERGE
	event_handler_flags = USE_FLUID_ENTER | USE_CANPASS | IS_FARTABLE | STAIR_ANIM
	grounded_for_projectiles = TRUE
	/// defined in new, this is the base of the icon_state with the suffix removed, i.e. "cleanbot" without the "1"
	var/icon_state_base = null
	var/emagged = FALSE
	health_brute = 25
	health_burn = 25
	takes_tox = FALSE
	takes_brain = FALSE

	New()
		. = ..()
		remove_lifeprocess(/datum/lifeprocess/blindness)
		remove_lifeprocess(/datum/lifeprocess/viruses)
		remove_lifeprocess(/datum/lifeprocess/blood)

		var/obj/item/implant/access/infinite/assistant/O = new /obj/item/implant/access/infinite/assistant(src)
		O.owner = src
		O.implanted = 1

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/ui/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "grabber"
		HH.limb.name = "grabber"
		HH.can_hold_items = 1
		HH.can_attack = 1
		HH.can_range_attack = 0
		if(src.emagged == TRUE)
			var/datum/limb/small_critter/L = HH.limb
			L.max_wclass = W_CLASS_SMALL

	get_melee_protection(zone, damage_type)
		return 3

	get_ranged_protection()
		return 2

	death(var/gibbed)
		..(gibbed, 0)
		if (!gibbed)
			gib()
		else
			playsound(src.loc, "sound/impact_sounds/Machinery_Break_1.ogg", 50, 1)
			make_cleanable(/obj/decal/cleanable/oil,src.loc)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/screams/robot_scream.ogg" , 10, 0, pitch = -1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> screams!"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	cleanbot
		name = "cleanbot"
		real_name = "cleanbot"
		desc = "A little cleaning robot, it looks so excited!"
		icon_state = "cleanbot1"
		icon_state_base = "cleanbot"

		New()
			. = ..()
			if(prob(50))
				icon_state = "cleanbot-red1"
				icon_state_base = "cleanbot-red"

			color = pick(list(
				null,\
				list(0,1,0,0,0,1,1,0,0),\
				list(0,0,1,1,0,0,0,1,0),\
				list(0.5,0.5,0,0,0.5,0.5,0.5,0,0.5),\
				list(0.5,0,0.5,0.5,0.5,0,0,0.5,0.5),
			))

			src.create_reagents(60)
			src.reagents.add_reagent("cleaner", 10)
			src.abilityHolder.addAbility(/datum/targetable/critter/bot/mop_floor)
			src.abilityHolder.addAbility(/datum/targetable/critter/bot/reagent_scan_self)
			src.abilityHolder.addAbility(/datum/targetable/critter/bot/dump_reagents)

		emag_act(mob/user, obj/item/card/emag/E)
			. = ..()
			if(!src.emagged)
				playsound(src, "sound/effects/sparks4.ogg", 50)
				src.audible_message("<span class='alert'><B>[src] buzzes oddly!</B></span>")
				src.abilityHolder.addAbility(/datum/targetable/critter/bot/fill_with_chem/lube)
				src.abilityHolder.addAbility(/datum/targetable/critter/bot/fill_with_chem/phlogiston_dust)
				src.emagged = TRUE

		is_open_container()
			return TRUE

		emagged
			emagged = TRUE
			New()
				. = ..()
				src.abilityHolder.addAbility(/datum/targetable/critter/bot/fill_with_chem/lube)
				src.abilityHolder.addAbility(/datum/targetable/critter/bot/fill_with_chem/phlogiston_dust)

ABSTRACT_TYPE(/datum/targetable/critter/bot)
/datum/targetable/critter/bot/mop_floor
	name = "Mop Floor"
	desc = "Clean the floor of dirt and other grime."
	icon_state = "cleanbot_mop"
	targeted = TRUE
	target_anything = TRUE
	cooldown = 3 SECONDS
	max_range = 1
	ai_range = 1

	cast(atom/target)
		if(!holder?.owner)
			return TRUE
		actions.start(new/datum/action/bar/icon/mob_cleanbot_clean(holder.owner, target), holder.owner)

ABSTRACT_TYPE(/datum/targetable/critter/bot/fill_with_chem)
/datum/targetable/critter/bot/fill_with_chem
	name = "Synthesize Reagent"
	targeted = FALSE
	cooldown = 30 SECONDS
	var/reagent_id = null

	cast(atom/target)
		if(!holder?.owner?.reagents)
			return TRUE
		holder.owner.reagents.add_reagent(reagent_id, 30)
		playsound(holder.owner.loc, "sound/effects/zzzt.ogg", 50, 1, -6)
	lube
		name = "Synthesize Space Lube"
		desc = "Fill yourself will space lube. Creates a slipping hazard, but it makes those floors shine so well that you can see yourself in them!"
		reagent_id = "lube"
		icon_state = "clean_lube"

	phlogiston_dust
		name = "Synthesize Phlogiston Dust"
		desc = "Fill yourself will phlogiston dust. For those stuck on messes!"
		reagent_id = "firedust"
		icon_state = "clean_phlog"

/datum/targetable/critter/bot/reagent_scan_self
	name = "Reagent Scan Self"
	desc = "Scan yourself for reagents."
	targeted = FALSE
	cooldown = 5 SECONDS
	icon_state = "cleanbot_scan"
	var/reagent_id = null

	cast(atom/target)
		if(!holder?.owner?.reagents)
			return TRUE
		boutput(holder.owner, "[scan_reagents(holder.owner, show_temp = 1, visible = 1, show_volume = 1)]")

/datum/targetable/critter/bot/dump_reagents
	name = "Dump Reagents"
	desc = "Dump all your reagents on the floor."
	targeted = FALSE
	cooldown = 10 SECONDS
	icon_state = "cleanbot_spill"

	cast()
		if (!holder?.owner?.reagents)
			return TRUE
		holder.owner.setStatus("resting", INFINITE_STATUS) // flop over to spill the reagents
		holder.owner.force_laydown_standup()
		holder.owner.reagents.reaction(get_turf(holder.owner), TOUCH)
		holder.owner.reagents.clear_reagents()

/datum/action/bar/icon/mob_cleanbot_clean
	duration = 1 SECOND
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	id = "mob_cleanbot_clean"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	var/mob/master
	var/turf/T
	var/const/cleaning_reagent = "cleaner"

	New(mob/user, atom/target)
		..()
		src.master = user
		src.T = get_turf(target)

	onStart()
		..()
		if (!master || is_incapacitated(master) || !T)
			interrupt(INTERRUPT_ALWAYS)
			return

		playsound(get_turf(master), "sound/impact_sounds/Liquid_Slosh_2.ogg", 25, 1)
		master.anchored = ANCHORED
		if(istype(master, /mob/living/critter/robotic/bot))
			var/mob/living/critter/robotic/bot/bot = master
			master.icon_state = "[bot.icon_state_base]-c"
		master.visible_message("<span class='alert'>[master] begins to clean the [T.name].</span>")

	onUpdate()
		..()
		if (!master || is_incapacitated(master) || !T)
			interrupt(INTERRUPT_ALWAYS)
			return

	onInterrupt(flag)
		. = ..()
		if(istype(master, /mob/living/critter/robotic/bot))
			var/mob/living/critter/robotic/bot/bot = master
			master.icon_state = "[bot.icon_state_base]1"

	onEnd()
		if (master)
			if (master.reagents)
				master.reagents.remove_any(10)
				var/cleaner_amt = master.reagents.get_reagent_amount(cleaning_reagent)
				if (cleaner_amt <= 10)
					master.reagents.add_reagent(cleaning_reagent, 10 - cleaner_amt)
				master.reagents.reaction(T, TOUCH, 10)

			if (T.active_liquid)
				if (T.active_liquid.group)
					T.active_liquid.group.drain(T.active_liquid,1,master)

			if(istype(master, /mob/living/critter/robotic/bot))
				var/mob/living/critter/robotic/bot/bot = master
				master.icon_state = "[bot.icon_state_base]1"
		..()

/mob/living/critter/robotic/bot/firebot
	name = "firebot"
	real_name = "firebot"
	desc = "A little fire-fighting robot! It looks so darn chipper."
	icon_state = "firebot1"
	icon_state_base = "firebot"

	New()
		. = ..()
		color = pick(list(
			null,\
			list(0.780465,0.129599,0.76233,0,0.0941811,0.94407,0.867769,0,0.858187,0.639099,0.46042,0,0,0,0,1,0,0,0,0),\
			list(0.309832,0.486208,0.704786,0,0.57733,0.407169,0.343657,0,0.440741,0.307279,0.0361456,0,0,0,0,1,0,0,0,0),\
			list(0.923407,0.489071,0.0133575,0,0.416634,0.00596684,0.0659536,0,0.151125,0.954365,0.946033,0,0,0,0,1,0,0,0,0),\
			list(0.34802,0.586676,0.382593,0,0.265555,0.208964,0.409951,0,0.395675,0.227339,0.498367,0,0,0,0,1,0,0,0,0),
		))

		src.abilityHolder.addAbility(/datum/targetable/critter/bot/spray_foam)


	emag_act(mob/user, obj/item/card/emag/E)
		. = ..()
		if(!src.emagged)
			playsound(src, "sound/effects/sparks4.ogg", 50)
			src.audible_message("<span class='alert'><B>[src] buzzes oddly!</B></span>")
			src.abilityHolder.addAbility(/datum/targetable/critter/bot/spray_foam/fuel)
			src.abilityHolder.addAbility(/datum/targetable/critter/bot/spray_foam/throw_humans)
			src.emagged = TRUE

	emagged
		emagged = TRUE
		New()
			. = ..()
			src.abilityHolder.addAbility(/datum/targetable/critter/bot/spray_foam/fuel)
			src.abilityHolder.addAbility(/datum/targetable/critter/bot/spray_foam/throw_humans)


/datum/targetable/critter/bot/spray_foam
	name = "Spray Foam"
	desc = "Unleash your spray foam cannon to kill the fire."
	targeted = TRUE
	target_anything = TRUE
	cooldown = 5 SECONDS
	max_range = 30
	ai_range = 4
	icon = 'icons/ui/critter_ui.dmi'
	icon_state = "firebot_foam"
	var/const/num_water_effects = 5
	/// list of reagents to spray and their quantities
	var/list/spray_reagents = list("water"=2, "ff-foam"=8)
	/// reagent container size, passed to the spray proc
	var/max_spray = 15
	/// temp of the sprayed reagents
	var/spray_temperature=T20C

	cast(atom/target)
		if(!holder?.owner)
			return TRUE
		flick("firebot-c", holder.owner)
		playsound(get_turf(holder.owner), "sound/effects/spray.ogg", 50, 1, -3)

		var/direction = get_dir(holder.owner,target)

		var/turf/T = get_turf(target)
		var/turf/T1 = get_step(T,turn(direction, 90))
		var/turf/T2 = get_step(T,turn(direction, -90))

		var/list/the_targets = list(T,T1,T2)

		for(var/i in 0 to num_water_effects)
			var/obj/effects/water/W = new /obj/effects/water
			if(!W) return
			W.set_loc(get_turf(holder.owner))
			var/turf/my_target = pick(the_targets)
			var/datum/reagents/R = new/datum/reagents(max_spray)
			for(var/reagent_key in spray_reagents)
				R.add_reagent(reagent_key, spray_reagents[reagent_key], temp_new = spray_temperature)
			W.spray_at(my_target, R, 1)

	fuel
		name = "Spray Burning Fuel"
		desc = "Spray burning fuel all over the place. Highly flammable but near useless in flooded areas."
		icon_state = "firebot_fire"
		spray_reagents = list("fuel"=5)
		spray_temperature = T0C + 300
		attack_mobs = TRUE
		max_range = 30
		ai_range = 4
		cooldown = 15 SECONDS

	throw_humans
		name = "High Pressure Foam"
		desc = "Unleash your spray foam cannon to send mobs flying."
		attack_mobs = TRUE
		max_range = 30
		ai_range = 3
		cooldown = 15 SECONDS

		cast(atom/target)
			if(..())
				return TRUE
			for(var/mob/living/L in view(1, target))
				if(L == src.holder.owner)
					continue
				var/atom/targetTurf = get_edge_target_turf(L, get_dir(holder.owner, get_step_away(L, holder.owner)))
				boutput(L, "<span class='alert'><b>[holder.owner] knocks you back!</b></span>")
				L.changeStatus("weakened", 2 SECONDS)
				L.throw_at(targetTurf, 25, 4)

/mob/living/critter/robotic/bot/securitron
	name = "securitron"
	real_name = "securitron"
#ifdef HALLOWEEN
	desc = "A little security robot, apparently carved out of a pumpkin.  It looks...spooky?"
	icon = 'icons/misc/halloween.dmi'
#else
	desc = "A little security robot.  It looks less than thrilled."
	icon = 'icons/obj/bots/aibots.dmi'
#endif
	icon_state = "secbot1"
	icon_state_base = "secbot"
	blood_id = "oil"
	hand_count = 1
	base_move_delay = 3.25
	base_walk_delay = 4.25
	metabolizes = FALSE
	stepsound = null
	ai_type = /datum/aiHolder/patroller/packet_based/securitron
	reagent_capacity = 20
	var/random_name = TRUE
	var/control_freq = FREQ_BOT_CONTROL
	var/chase_speed_bonus = 0.3
	var/obj/machinery/camera/camera = null
	var/no_camera = FALSE
	var/initial_limb = /obj/item/baton/mobsecbot
	var/drop_limb_item = FALSE
	var/net_id
	var/power = TRUE
	var/emote_cooldown = 7 SECONDS
	var/arrest_cooldown = 10 SECONDS
	var/siren_active = FALSE
	var/list/req_access = list(access_security)
	var/weapon_access = access_carrypermit
	var/contraband_access = access_contrabandpermit
	var/check_contraband = TRUE
	var/check_records = TRUE
	var/is_detaining = FALSE
	var/report_arrests = TRUE
	var/patrolling = FALSE
	var/lockdown = FALSE
	var/guard_area_name = null
	var/list/datum/contextAction/contexts = list()
	var/datum/contextLayout/configContextLayout = new /datum/contextLayout/experimentalcircle

/mob/living/critter/robotic/bot/securitron/New()
	. = ..()

	if(src.name == "securitron")
		src.real_name = "Securitron-" + "[rand(1,9)]" + "[rand(0,9)]" + "[rand(0,9)]"
		src.name = src.real_name
		src.UpdateName()
	if(src.initial_limb)
		var/datum/handHolder/HH = hands[1]
		src.hud.add_object(src.equipped(), HUD_LAYER+2, HH.screenObj.screen_loc)

	src.net_id = generate_net_id(src)

	remove_lifeprocess(/datum/lifeprocess/blindness)
	remove_lifeprocess(/datum/lifeprocess/blood)

	var/obj/item/implant/access/infinite/secoff/O = new /obj/item/implant/access/infinite/secoff(src)
	O.owner = src
	O.implanted = 1

	src.abilityHolder.addAbility(/datum/targetable/critter/bot/handcuff)

	APPLY_MOVEMENT_MODIFIER(src, /datum/movement_modifier/robot_base, "robot_health_slow_immunity")

	get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).add_mob(src)

	add_simple_light("secbot", list(255, 255, 255, 0.4 * 255))

	MAKE_SENDER_RADIO_PACKET_COMPONENT("pda", FREQ_PDA)

	if(!src.no_camera)
		src.camera = new /obj/machinery/camera(src)
		src.camera.c_tag = src.real_name
		src.camera.network = "Robots"

	for(var/actionType in childrentypesof(/datum/contextAction/securitron)) //see context_actions.dm
		src.contexts += new actionType()

	START_TRACKING

/mob/living/critter/robotic/bot/securitron/disposing()
	STOP_TRACKING
	qdel(src.camera)
	..()

/mob/living/critter/robotic/bot/securitron/setup_hands()
	..()
	var/datum/handHolder/HH = hands[1]
	if (src.initial_limb)
		var/datum/limb/item/itemlimb = new
		HH.limb = itemlimb
		HH.item = new src.initial_limb(src)
		var/obj/item/I = HH.item
		I.temp_flags |= IS_LIMB_ITEM
		I.cant_drop = 1
		I.cant_self_remove = 1
		I.cant_other_remove = 1
		itemlimb.my_item = I
	else
		HH.limb = new /datum/limb/small_critter/med
		HH.limb.name = "long arm"
	HH.suffix = "-R"
	HH.name = "long arm"
	HH.icon_state = "handn"
	HH.icon = 'icons/ui/critter_ui.dmi'
	src.update_inhands()

/mob/living/critter/robotic/bot/securitron/proc/change_hand_item()
	set name = "Change hand item"
	var/type = input(usr, "Item type", "Item type")
	if (!type)
		return
	type = get_one_match(type, /obj/item)
	var/datum/handHolder/HH = hands[1]
	if(!istype(HH.limb, /datum/limb/item))
		HH.limb.dispose()
		HH.limb = new /datum/limb/item
	var/obj/item/old_item = HH.item
	HH.item = new type(src)
	var/obj/item/I = HH.item
	I.temp_flags |= IS_LIMB_ITEM
	I.cant_drop = 1
	I.cant_self_remove = 1
	I.cant_other_remove = 1
	var/datum/limb/item/itemlimb = HH.limb
	itemlimb.my_item = HH.item
	if(istype(I, /obj/item/gun/modular))
		var/obj/item/gun/modular/gunse = I
		if(gunse.accessory && !istype(gunse.accessory, /obj/item/gun_parts/accessory/ammofab))
			qdel(gunse.accessory)
			gunse.accessory.remove_part_from_gun()
		if(!gunse.accessory)
			gunse.accessory = new /obj/item/gun_parts/accessory/ammofab(gunse)
			gunse.accessory.add_part_to_gun(gunse)
	HH.can_range_attack = istype(I, /obj/item/gun)
	src.hud.remove_object(old_item)
	qdel(old_item)
	src.hud.add_object(I, HUD_LAYER+2, HH.screenObj.screen_loc)
	src.update_inhands()

/mob/living/critter/robotic/bot/securitron/setup_healths()
	add_hh_robot(src.health_brute, src.health_brute_vuln)
	add_hh_robot_burn(src.health_burn, src.health_burn_vuln)

/mob/living/critter/robotic/bot/securitron/get_melee_protection(zone, damage_type)
	return 3

/mob/living/critter/robotic/bot/securitron/get_ranged_protection()
	return 2

/mob/living/critter/robotic/bot/securitron/death(var/gibbed)
	for (var/datum/handHolder/HH in hands)
		if(istype(HH.limb, /datum/limb/item))
			var/datum/limb/item/item_limb = HH.limb
			if (item_limb.my_item && src.drop_limb_item)
				var/obj/item/I = item_limb.my_item
				I.temp_flags &= ~IS_LIMB_ITEM
				I.cant_drop = initial(I.cant_drop)
				I.cant_self_remove = initial(I.cant_self_remove)
				I.cant_other_remove = initial(I.cant_other_remove)
	..(gibbed, 0)

/mob/living/critter/robotic/bot/securitron/emp_act()
	if(src.emagged)
		src.death(TRUE)
	else
		..()

/mob/living/critter/robotic/bot/securitron/special_movedelay_mod(delay, space_movement, aquatic_movement)
	var/chase_delay = BASE_SPEED
	if (src.client || (src.is_npc && src.ai && src.ai.target && isliving(src.ai.target)))
		chase_delay -= src.chase_speed_bonus
	. = ..(chase_delay, space_movement, aquatic_movement)


/mob/living/critter/robotic/bot/securitron/attack_ai(mob/user as mob)
	if (src.power && src.emagged)
		boutput(user, "<span class='alert'>[src] refuses your authority!</span>")
		return
	user.showContextActions(src.contexts, src, src.configContextLayout)

/mob/living/critter/robotic/bot/securitron/specific_emotes(var/act, var/param = null, var/voluntary = 0)
	if (act == "scream")
		src.siren()
		return null
	if (ON_COOLDOWN(src, "SECURITRON_EMOTE", src.emote_cooldown))
		return null
	src.trash_talk(act)

/mob/living/critter/robotic/bot/securitron/proc/trash_talk(var/emote = null)
	if(!emote)
		emote = pick("laugh","fart","salute","snap","flex")
	switch (emote)
		if ("laugh")
			src.say("YOU CAN'T OUTRUN A RADIO.")
			playsound(src, 'sound/voice/bradio.ogg', 50, FALSE, 0, 1)
		if ("fart")
			src.say("YOUR MOVE, CREEP.")
			playsound(src, 'sound/voice/bcreep.ogg', 50, FALSE, 0, 1)
		if ("salute")
			src.say("HAVE A SECURE DAY.")
			playsound(src, 'sound/voice/bsecureday.ogg', 50, FALSE, 0, 1)
		if ("snap")
			src.say("GOD MADE TOMORROW FOR THE CROOKS WE DON'T CATCH TODAY.")
			playsound(src, 'sound/voice/bgod.ogg', 50, FALSE, 0, 1)
		if ("flex")
			src.say("I AM THE LAW.")
			playsound(src, 'sound/voice/biamthelaw.ogg', 50, FALSE, 0, 1)
	return

/mob/living/critter/robotic/bot/securitron/proc/accuse_perp(atom/target, threat = 4)
	src.point_at(target)
	src.say("LEVEL [threat] INFRACTION ALERT.")
	switch(rand(1,3))
		if(1)
			src.say("CRIMINAL DETECTED.")
			playsound(src, 'sound/voice/bcriminal.ogg', 50, FALSE, 0, 1)
		if(2)
			src.say("PREPARE FOR JUSTICE.")
			playsound(src, 'sound/voice/bjustice.ogg', 50, FALSE, 0, 1)
		if(3)
			src.say("FREEZE. SCUMBAG.")
			playsound(src, 'sound/voice/bfreeze.ogg', 50, FALSE, 0, 1)

/mob/living/critter/robotic/bot/securitron/proc/siren()
	if(siren_active)
		return
	SPAWN_DBG(0)
		siren_active = TRUE
		var/weeoo = 10
		playsound(src, 'sound/machines/siren_police.ogg', 50, TRUE)
		while (weeoo)
			add_simple_light("secbot", list(255 * 0.9, 255 * 0.1, 255 * 0.1, 0.8 * 255))
			sleep(0.2 SECONDS)
			add_simple_light("secbot", list(255 * 0.1, 255 * 0.1, 255 * 0.9, 0.8 * 255))
			sleep(0.2 SECONDS)
			weeoo--

		add_simple_light("secbot", list(255, 255, 255, 0.4 * 255))
		siren_active = FALSE

/mob/living/critter/robotic/bot/securitron/attack_hand(mob/user, params)
	if (user.a_intent == INTENT_HELP && src.allowed(user))
		src.ai.stop_move()
		EXTEND_COOLDOWN(src, "HALT_FOR_INTERACTION", 4 SECONDS)
		user.showContextActions(src.contexts, src, src.configContextLayout)
	else if (user.a_intent == INTENT_HARM && ishuman(user))
		var/damage = 1
		var/mob/living/carbon/human/H = user
		if (H.shoes)
			damage += H.shoes.kick_bonus
		else if (H.limbs.r_leg)
			damage += H.limbs.r_leg.limb_hit_bonus
		else if (H.limbs.l_leg)
			damage += H.limbs.l_leg.limb_hit_bonus
		random_brute_damage(src, damage)
		user.visible_message("<span class='alert'><b>[user]</b> kicks [src] like the football!</span>")
		var/atom/throw_target = get_edge_target_turf(src, get_dir(user, src))
		if(throw_target)
			src.throw_at(throw_target, 6, 2)
		src.was_harmed(user)
	else
		..()

/mob/living/critter/robotic/bot/securitron/proc/set_power(var/on_off)
	if(src.power == on_off)
		return
	src.power = on_off
	src.icon_state = "[src.icon_state_base][src.power]"
	if (src.power)
		src.say("TEN-FORTY ONE. [uppertext(src.name)]: ONLINE.")
		add_simple_light("secbot", list(255, 255, 255, 0.4 * 255))
		ai.enable()
	else
		src.say("TEN-FORTY TWO. [uppertext(src.name)]: OFFLINE.")
		remove_simple_light("secbot")
		ai.disable()

/mob/living/critter/robotic/bot/securitron/proc/configure(var/setting, var/mob/M)
	switch(setting)
		if ("power")
			src.guard_area_name = null
			src.set_power(!src.power)
			return src.power
		if ("check_contraband")
			src.check_contraband = !src.check_contraband
			if(src.power)
				src.say("TEN-FOUR. CONTRABAND CHECKS: [src.check_contraband ? "ENGAGED" : "DISENGAGED"].")
			return src.check_contraband
		if ("check_records")
			src.check_records = !src.check_records
			if(src.power)
				src.say("TEN-FOUR. SECURITY RECORDS: [src.check_records ? "REFERENCED" : "IGNORED"].")
			return src.check_records
		if ("arrest_type")
			src.is_detaining = !src.is_detaining
			if(src.power)
				src.say("TEN-FOUR. ENGAGEMENT MODE: [src.is_detaining ? "DETAIN" : "RESTRAIN"].")
			if (istype(src.ai,/datum/aiHolder/patroller/packet_based/securitron))
				var/datum/aiHolder/patroller/packet_based/securitron/securitron_ai = src.ai
				securitron_ai.is_detaining = src.is_detaining
			return src.is_detaining
		if ("report_arrests")
			src.report_arrests = !src.report_arrests
			if(src.power)
				src.say("TEN-FOUR. [src.report_arrests ? "REPORTING ARRESTS ON: [FREQ_PDA]" : "LONE RANGER PROTOCOL ENGAGED."]")
			return src.report_arrests
		if ("patrolling")
			src.guard_area_name = null
			src.patrolling = !src.patrolling
			if(src.power)
				src.say("TEN-FOUR. PATROL ROUTE: [src.patrolling ? "IN PROGRESS" : "HALTED"].")
			return src.patrolling

/mob/living/critter/robotic/bot/securitron/ai_is_valid_target(mob/M)
	if (ishuman(M))
		if (M.hasStatus("handcuffed"))
			return FALSE // already cuffed
	else if (is_incapacitated(M))
		return FALSE // already stunned
	if (GET_COOLDOWN(M, "ARRESTED_BY_SECURITRON_\ref[src]"))
		return FALSE // we JUST arrested this jerk
	. = ..()
	if (!.)
		return FALSE
	var/threat_level = assess_perp(M)
	if (!GET_COOLDOWN(M, "MARKED_FOR_SECURITRON_ARREST") || (istype(M, /mob/living/critter/robotic/bot/securitron) && !src.emagged)) // set in assess_perp
		return FALSE // not a threat
	if (threat_level >= 4 && !ON_COOLDOWN(src, "SECURITRON_EMOTE", src.emote_cooldown))
		src.accuse_perp(M, threat_level)
		src.siren()
	return TRUE

//If the security records say to arrest them, arrest them
//Or if they have weapons and aren't security, arrest them.
/mob/living/critter/robotic/bot/securitron/proc/assess_perp(mob/living/perp)
	var/threatcount = 0

	if(src.emagged > 1)
		threatcount = rand(7,15)
		EXTEND_COOLDOWN(perp, "MARKED_FOR_SECURITRON_ARREST", threatcount * 1.5 SECONDS)
		return threatcount //Everything that moves is a target!

	if((src.check_contraband) || (ishuman(perp) && src.lockdown)) // bot is set to actively search for contraband or we need id due to lockdown
		var/obj/item/card/id/perp_id = perp.equipped()
		if (!istype(perp_id))
			perp_id = perp.get_id()

		if(src.lockdown)
			var/area/perp_area = get_area(perp)
			if(perp_area.name == src.guard_area_name)
				if(!perp_id || !((access_security in perp_id) || (access_heads in perp_id.access)))
					threatcount = 10
					EXTEND_COOLDOWN(perp, "MARKED_FOR_SECURITRON_ARREST", 10 SECONDS)
					return threatcount

		//Agent cards lower threat level
		if(istype(perp_id, /obj/item/card/id/syndicate))
			threatcount -= 2

		if(!perp_id || !(contraband_access in perp_id.access))
			threatcount += GET_ATOM_PROPERTY(perp, PROP_MOVABLE_VISIBLE_CONTRABAND)
		if(!perp_id || !(weapon_access in perp_id.access))
			threatcount += GET_ATOM_PROPERTY(perp, PROP_MOVABLE_VISIBLE_GUNS)

	var/perpname = perp.name
	if(ishuman(perp))
		if(src.emagged)
			threatcount = rand(7,15)
			EXTEND_COOLDOWN(perp, "MARKED_FOR_SECURITRON_ARREST", threatcount * 1.5 SECONDS)
			return threatcount //this cannons loose as fuck!
		var/mob/living/carbon/human/H_perp = perp
		if(istype(H_perp.mutantrace, /datum/mutantrace/abomination))
			threatcount += 5

		if (((H_perp.wear_mask && H_perp.wear_mask.see_face) || !H_perp.wear_mask) && ((H_perp.head && H_perp.head.see_face) || !H_perp.head))
			perpname = H_perp.real_name
		if(perp.traitHolder?.hasTrait("stowaway") && perp.traitHolder?.hasTrait("jailbird"))
			if(isnull(data_core.security.find_record("name", perpname)))
				threatcount += 5

	// we have grounds to make an arrest, don't bother with further analysis
	if(threatcount >= 4)
		EXTEND_COOLDOWN(perp, "MARKED_FOR_SECURITRON_ARREST", threatcount * 3 SECONDS)
		return threatcount

	// note - this does allow flagging 'fire elemental' and such for arrest. probably fine
	if (src.check_records) // bot is set to actively compare security records
		for (var/datum/db_record/R as anything in data_core.security.find_records("name", perpname))
			if(R["criminal"] == "*Arrest*")
				EXTEND_COOLDOWN(perp, "MARKED_FOR_SECURITRON_ARREST", 5 SECONDS) // clearing a record stops securitrons quickly
				threatcount = 7
				break

	return threatcount

/mob/living/critter/robotic/bot/securitron/proc/allowed(mob/M)
	if(isghostdrone(M))
		return 0
	if(issilicon(M) || isAIeye(M))
	//check if it doesn't require any access at all
		return 1
	if(src.check_access(null))
		return 1
	if(src.check_access(M.equipped()))
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(src.check_access(H.wear_id))
			return 1
	return 0

/mob/living/critter/robotic/bot/securitron/hand_attack(mob/target)
	EXTEND_COOLDOWN(target, "MARKED_FOR_SECURITRON_ARREST", 10 SECONDS)
	var/obj/item/I = src.equipped()
	if(!I)
		return FALSE
	if (istype(I,/obj/item/gun))
		src.a_intent = INTENT_HARM
		if(istype(I,/obj/item/gun/modular))
			var/obj/item/gun/modular/gunse = I
			if(gunse.jammed)
				gunse.attack_self(src)
	else
		src.a_intent = INTENT_DISARM
		if(istype(I,/obj/item/baton))
			var/obj/item/baton/batong = I
			if(!batong.is_active)
				batong.attack_self(src)
	src.hud.update_intent()
	..(target)
	var/bonus_hits = src.emagged - 1
	SPAWN_DBG(0)
		while(bonus_hits >= 1)
			sleep(2)
			src.next_click = 0
			..(target)
			bonus_hits--
	return TRUE

/mob/living/critter/robotic/bot/securitron/proc/check_access(obj/item/I)
	if(!istype(src.req_access, /list)) //something's very wrong
		return 1
	var/list/L = src.req_access
	if(!L.len) //no requirements
		return 1
	if (istype(I, /obj/item/device/pda2) && I:ID_card)
		I = I:ID_card
	if (!istype(I, /obj/item/card/id))
		return 0
	if(!I:access) //not ID or no access
		return 0
	for(var/req in src.req_access)
		if(!(req in I:access)) //doesn't have this access
			return 0
	return 1

/mob/living/critter/robotic/bot/securitron/was_harmed(mob/attacker, obj/attacked_with, special, intent)
	if(!src.ai?.enabled || istype(attacker, /mob/living/critter/robotic/bot/securitron))
		return
	if(attacker.hasStatus("handcuffed") && !src.is_detaining)
		return
	var/aggression_hp = 1
	if(ishuman(attacker))
		var/mob/living/carbon/human/H = attacker
		if(istype(H.wear_suit,/obj/item/clothing/suit/security_badge))
			aggression_hp -= 0.2 // 10 damage allowed because beepsky thinks youre a cop
	if(src.allowed(attacker))
		aggression_hp -= 0.1 // 5 damage allowed
	if(src.get_health_percentage() > aggression_hp) // if health is still high enough, assume it was friendly fire or a 0 damage hit
		return
	EXTEND_COOLDOWN(attacker, "MARKED_FOR_SECURITRON_ARREST", 15 SECONDS)
	if(!ON_COOLDOWN(src, "SECURITRON_EMOTE", src.emote_cooldown))
		src.accuse_perp(attacker, rand(5,8))
		src.siren()
	..()

/mob/living/critter/robotic/bot/securitron/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if(ON_COOLDOWN(src,"EMAG_COOLDOWN",12 SECONDS)) // no rapid double emags
		if (user)
			boutput(user, SPAN_ALERT("\The [src] is still sparking from the last time!"))
		return 0

	if (user)
		if(!src.emagged)
			boutput(user, SPAN_ALERT("You short out [src]'s contraband assessment circuits!"))
			OVERRIDE_COOLDOWN(user, "ARRESTED_BY_SECURITRON_\ref[src]", 3 SECONDS) // just enough time to book it
		else if(src.emagged == 1)
			boutput(user, SPAN_ALERT("You scramble [src]'s target verification circuits!"))
			OVERRIDE_COOLDOWN(user, "ARRESTED_BY_SECURITRON_\ref[src]", 0.3 SECONDS) // run fast
			src.AddComponent(/datum/component/waddling)
		else
			boutput(user, SPAN_ALERT("You mess with \the [src] a bit more, just for kicks."))
	playsound(src, 'sound/effects/sparks4.ogg', 50, FALSE, 0, 1)
	src.audible_message(SPAN_ALERT("<B>[src] buzzes oddly!</B>"))

	src.emagged++
	src.set_power(TRUE)

	if (src.emagged > 5)
		playsound(src, 'sound/effects/glitchy1.ogg', 50, FALSE, 0, 1)
		src.say("I WAS THE LAW.")
		SPAWN_DBG(5 DECI SECONDS)
			src.blowthefuckup(3)

	logTheThing("station", user, "emagged securitron ([src]) at [log_loc(src)].")
	return 1


/datum/targetable/critter/bot/handcuff
	name = "Detain"
	desc = "Attempts to handcuff a target."
	targeted = TRUE
	target_anything = TRUE
	attack_mobs = TRUE
	max_range = 1
	ai_range = 1
	cooldown = 4 SECONDS
	icon = 'icons/ui/critter_ui.dmi'
	icon_state = "secbot_detain"

/datum/targetable/critter/bot/handcuff/cast(atom/target)
	if (..())
		return TRUE
	var/mob/living/carbon/human/H = target
	if (!ishuman(target))
		target = get_turf(target)
	if (isturf(target))
		H = locate(/mob/living/carbon/human) in target
		if (!H)
			boutput(holder.owner, "<span class='alert'>Nothing to detain there.</span>")
			return TRUE
	if (H == holder.owner)
		return TRUE
	if (!H.lying)
		boutput(holder.owner, "<span class='alert'>The target must be lying down.</span>")
		return TRUE
	if (BOUNDS_DIST(holder.owner, H) > 0)
		boutput(holder.owner, "<span class='alert'>That is too far away to detain.</span>")
		return TRUE
	var/mob/M = holder.owner
	if (!isturf(M.loc))
		boutput(holder.owner, "<span class='alert'>You'll need to get out of \the [M.loc] before trying to detain someone.")
		return TRUE
	if (target.hasStatus("handcuffed"))
		boutput(holder.owner, "<span class='alert'>That target is already cuffed.</span>")
		return TRUE
	actions.start(new/datum/action/bar/icon/mob_secbot_cuff(M, H), M)
	return 0

/datum/action/bar/icon/mob_secbot_cuff
	duration = 4 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/items/items.dmi'
	icon_state = "buddycuff"
	var/mob/master
	var/mob/living/carbon/human/target
	var/arrest_cooldown = 10 SECONDS

/datum/action/bar/icon/mob_secbot_cuff/New(var/mob/living/M, var/mob/living/carbon/human/H)
	src.master = M
	src.target = H
	..()

/datum/action/bar/icon/mob_secbot_cuff/onStart()
	if ((BOUNDS_DIST(master, target) > 0) || master == null || target == null || target.hasStatus("handcuffed"))
		interrupt(INTERRUPT_ALWAYS)
		return
	..()
	playsound(master, 'sound/weapons/handcuffs.ogg', 30, TRUE, -2)
	master.visible_message("<span class='alert'><B>[master] is trying to put handcuffs on [target]!</B></span>")

/datum/action/bar/icon/mob_secbot_cuff/onEnd()
	..()
	if(ishuman(target))
		OVERRIDE_COOLDOWN(target,"ARRESTED_BY_SECURITRON_\ref[master]",src.arrest_cooldown)
		OVERRIDE_COOLDOWN(target,"MARKED_FOR_SECURITRON_ARREST",0)
		target.handcuffs = new /obj/item/handcuffs/guardbot(target)
		target.setStatus("handcuffed", duration = INFINITE_STATUS)
		logTheThing("combat", master, "handcuffs [constructTarget(target,"combat")] at [log_loc(master)].")

		if(istype(master,/mob/living/critter/robotic/bot/securitron))
			var/mob/living/critter/robotic/bot/securitron/secbot = master
			if(secbot.ai?.enabled)
				secbot.trash_talk()

		//////PDA NOTIFY/////
		if(istype(master, /mob/living/critter/robotic/bot/securitron))
			var/mob/living/critter/robotic/bot/securitron/secbot = master
			if(!secbot.report_arrests)
				return

		var/area/user_location = get_area(master)
		var/turf/target_loc = get_turf(target)
		if(!target_loc)
			target_loc = get_turf(master)

		var/message2send ="Notification: [target] detained by [master] in [user_location] at coordinates [target_loc.x], [target_loc.y]."

		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.data["sender"] = "00000000"
		signal.data["command"] = "text_message"
		signal.data["sender_name"] = "SECURITY-MAILBOT"
		signal.data["group"] = list(MGD_SECURITY, MGA_ARREST)
		signal.data["address_1"] = "00000000"
		signal.data["message"] = message2send
		SEND_SIGNAL(src.master, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, "pda")

/mob/living/critter/robotic/bot/securitron/autopatrol
	patrolling = TRUE

/mob/living/critter/robotic/bot/securitron/bowling
	name = "bowlatron"
	real_name = "bowlatron"
	throw_speed = 0.75

/mob/living/critter/robotic/bot/securitron/bowling/throw_at(atom/target, range, speed, list/params, turf/thrown_from, mob/thrown_by, throw_type = 1,
			allow_anchored = UNANCHORED, bonus_throwforce = 0, end_throw_callback = null)
	throw_unlimited = TRUE
	..()

/mob/living/critter/robotic/bot/securitron/bowling/throw_impact(atom/hit_atom, datum/thrown_thing/thr)
	. = ..()
	if	(isturf(hit_atom) && !hit_atom.density)
		return
	src.visible_message("<span class='alert'>[src] unleashes a flash of electricity on impact!</span>")
	elecflash(get_turf(hit_atom), 1, 2, 1)
	if (ismob(hit_atom))
		var/mob/M = hit_atom
		M.do_disorient(150, weakened = 120, disorient = 60)

/mob/living/critter/robotic/bot/securitron/beepsky
	name = "Officer Beepsky"
	desc = "It's Officer Beepsky! He's a loose cannon but he gets the job done."
	initial_limb = /obj/item/baton/mobsecbot/beepsky
	gender = MALE
	patrolling = TRUE
	drop_limb_item = TRUE
	chase_speed_bonus = 0.5

/mob/living/critter/robotic/bot/securitron/formal
	name = "Lord Beepingshire"
	desc = "The most distinguished of security robots."
	// icon_state = 'like a formal sprite or somethin'

/mob/living/critter/robotic/bot/securitron/haunted
	name = "Beep-o-Lantern"
	desc = "A little security robot, apparently carved out of a pumpkin.  He looks...spooky?"
	icon = 'icons/misc/halloween.dmi'

/mob/living/critter/robotic/bot/securitron/emagged
	desc = "A tattered and rusted security bot, held together only by hate."
	health_brute = 5
	health_burn = 5
	emagged = 1
	no_camera = 1
	var/blow_up = 1

	New()
		..()
		src.name = pick("Commissar Oinkovich","The Oppressor","Assigned Cop At Birth","Donut Destroyer","Bastard")
		if (src.blow_up == 1)
			SPAWN_DBG(1 MINUTE)
				if(!QDELETED(src))
					src.blowthefuckup(0)
		return

/mob/living/critter/robotic/bot/securitron/emagged/no_selfdestruct
	blow_up = 0
