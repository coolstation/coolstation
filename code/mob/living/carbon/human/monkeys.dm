
#define IS_NPC_HATED_ITEM(x) ( \
		istype(x, /obj/item/clothing/suit/straight_jacket) || \
		istype(x, /obj/item/handcuffs) || \
		istype(x, /obj/item/device/radio/electropack) || \
		x:block_vision \
	)

/mob/living/carbon/human/monkey //Please ignore how silly this path is.
	name = "monkey"
#ifdef IN_MAP_EDITOR
	icon_state = "monkey"
#endif
	static_type_override = /datum/mutantrace/monkey

	New()
		..()
		SPAWN_DBG(0.5 SECONDS)
			if (!src.disposed)
				src.bioHolder.AddEffect("monkey")
				src.get_static_image()
				if (src.name == "monkey" || !src.name)
					src.name = pick_string_autokey("names/monkey.txt")
				src.real_name = src.name

	initializeBioholder()
		randomize_look(src, 1, 1, 1, 0, 1, 0)
		. = ..()

// special monkeys.
/mob/living/carbon/human/npc/monkey/mr_muggles
	name = "Mr. Muggles"
	real_name = "Mr. Muggles"
	gender = "male"
	ai_offhand_pickup_chance = 1 // very civilized
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/under/color/blue, slot_w_uniform)

/mob/living/carbon/human/npc/monkey/mrs_muggles
	name = "Mrs. Muggles"
	real_name = "Mrs. Muggles"
	gender = "female"
	ai_offhand_pickup_chance = 1 // also very civilized
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/under/color/magenta, slot_w_uniform)

/mob/living/carbon/human/npc/monkey/mr_rathen
	name = "Mr. Rathen"
	real_name = "Mr. Rathen"
	gender = "male"
	ai_offhand_pickup_chance = 2 // learned that there's dangerous stuff in engineering!
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/under/rank/engineer, slot_w_uniform)

/mob/living/carbon/human/npc/monkey/albert
	name = "Albert"
	real_name = "Albert"
	gender = "male"
	ai_offhand_pickup_chance = 10 // more curious than most monkeys
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/suit/space, slot_wear_suit)
			src.equip_new_if_possible(/obj/item/clothing/head/helmet/space, slot_head)

/mob/living/carbon/human/npc/monkey/trovalds //change the name a little while later here and in map's
	name = "Trovalds"
	real_name = "Trovalds"
	gender = "male"
	ai_offhand_pickup_chance = 40 // went through training as a spy thief, skilled at snatching stuff
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/suit/space/syndicate, slot_wear_suit)
			//src.equip_new_if_possible(/obj/item/clothing/head/helmet/space, slot_head) //this hides ID and he's not going out, so
	ai_action()
		if(ai_aggressive)
			return ..()

		if (ai_state == 0)
			if (prob(50))
				//attempt to fuck around
				if(src.ai_syndicate_fuck_around())
					//successfully fucked around, nothing else
					return
		//do regular monkey stuff
		..()

/mob/living/carbon/human/npc/monkey/minty //same. like i get it's the nuclear operative thing but
	name = "Nick \'Minty\' Kelvin"
	real_name = "Nick \'Minty\' Kelvin"
	gender = "male"
	ai_offhand_pickup_chance = 40 // went through training as a spy thief, skilled at snatch- wait, I'm getting a feeling of deja vu
	ai_aggressive = TRUE
	ai_calm_down = FALSE
	ai_default_intent = INTENT_HARM
	ai_aggression_timeout = 0
	var/preferred_card_type = /obj/item/card/id/syndicate

	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/under/misc/syndicate, slot_w_uniform)
			src.equip_new_if_possible(/obj/item/clothing/suit/space/syndicate, slot_wear_suit)
			src.equip_new_if_possible(/obj/item/clothing/head/helmet/space, slot_head)

			var/obj/item/card/id/ID = new/obj/item/card/id(src)
			ID.name = "Nick \'Minty\' Kelvin's ID Card"
			ID.assignment = "Syndicate Monkey"
			ID.registered = "Nick \'Minty\' Kelvin"
			ID.icon = 'icons/obj/items/card.dmi'
			ID.icon_state = "id_syndie"
			ID.desc = "Nick \'Minty\' Kelvin's identification card."

			src.equip_if_possible(ID, slot_wear_id)


	ai_is_valid_target(mob/M)
		if(!isliving(M) || !isalive(M))
			return FALSE
		return !istype(M.get_id(), preferred_card_type)

	ai_action()
		if(ai_aggressive)
			return ..()

		if (ai_state == 0)
			if (prob(50))
				//attempt to fuck around
				if(src.ai_syndicate_fuck_around())
					//successfully fucked around, nothing else
					return
		//do regular monkey stuff
		..()
/*
/mob/living/carbon/human/npc/monkey/minty/pod_wars
	preferred_card_type = /obj/item/card/id/pod_wars/syndicate

	New()
		START_TRACKING_CAT(TR_CAT_PW_PETS)
		..()
	disposing()
		STOP_TRACKING_CAT(TR_CAT_PW_PETS)
		..()

	ai_is_valid_target(mob/M)
		var/team_num = get_pod_wars_team_num(M)
		switch(team_num)
			if (TEAM_NANOTRASEN)	//1
				return TRUE
			if (TEAM_SYNDICATE)		//2
				return FALSE
			else
				return ..()
*/
/mob/living/carbon/human/npc/monkey/horse
	name = "????"
	real_name = "????"
	gender = "male"
	New()
		..()
		ai_offhand_pickup_chance = rand(100) // an absolute wildcard
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/mask/horse_mask/cursed/monkey, slot_wear_mask)

/mob/living/carbon/human/npc/monkey/tanhony
	name = "Tanhony"
	real_name = "Tanhony"
	gender = "female"
	ai_offhand_pickup_chance = 5 // your base monkey
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/head/paper_hat, slot_head)

/mob/living/carbon/human/npc/monkey/krimpus
	name = "Krimpus"
	real_name = "Krimpus"
	gender = "female"
	ai_offhand_pickup_chance = 2.5 // some of the botany fruit is very dangerous, Krimpus learned not to eat
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/under/rank/hydroponics, slot_w_uniform)
			src.equip_new_if_possible(/obj/item/clothing/suit/apron/botanist, slot_wear_suit)

/mob/living/carbon/human/npc/monkey/stirstir
	name = "Monsieur Stirstir"
	real_name = "Monsieur Stirstir"
	gender = "male"
	ai_offhand_pickup_chance = 4 // a filthy thief but he's trying to play nice for now
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/under/misc, slot_w_uniform)
			src.equip_new_if_possible(/obj/item/clothing/head/beret/prisoner, slot_head)
			if(prob(80)) // couldnt figure out how to hide it in the debris field, so i just chucked it in a monkey
				var/obj/item/disk/data/cartridge/ringtone_numbers/idk = new
				idk.set_loc(src)
				src.chest_item = idk
				src.chest_item_sewn = 1

/mob/living/carbon/human/npc/monkey // :getin:
	name = "monkey"
#ifdef IN_MAP_EDITOR
	icon_state = "monkey"
#endif
	static_type_override = /datum/mutantrace/monkey
	ai_aggressive = 0
	ai_calm_down = 1
	ai_default_intent = INTENT_HELP
	var/list/shitlist = list()
	var/ai_aggression_timeout = 600

	New()
		..()
		START_TRACKING
		if (!src.disposed)
			src.bioHolder.mobAppearance.customization_first = new /datum/customization_style/none
			src.bioHolder.AddEffect("monkey")
			if (src.name == "monkey" || !src.name)
				src.name = pick_string_autokey("names/monkey.txt")
			src.real_name = src.name

	disposing()
		STOP_TRACKING
		..()

	initializeBioholder()
		if (src.name == "monkey" || !src.name)
			randomize_look(src, 1, 1, 1, 0, 1, 0)
			src.gender = src.bioHolder?.mobAppearance.gender
		switch(src.gender)
			if("male")
				src.bioHolder?.mobAppearance?.pronouns = get_singleton(/datum/pronouns/heHim)
			if("female")
				src.bioHolder?.mobAppearance?.pronouns = get_singleton(/datum/pronouns/sheHer)
		. = ..()

	ai_action()
		if(ai_aggressive)
			return ..()

		if (src.ai_state == AI_ATTACKING && src.done_with_you(src.ai_target))
			return
		..()
		if (src.ai_state == 0)
			if (prob(50))
				src.ai_pickpocket(priority_only=prob(80))
			else if (prob(50))
				src.ai_knock_from_hand(priority_only=prob(80))
			if(!ai_target && prob(20))
				for(var/obj/fitness/speedbag/bag in view(1, src))
					if(!ON_COOLDOWN(src, "ai monkey punching bag", 1 MINUTE))
						src.ai_target = bag
						src.target = bag
						src.ai_state = AI_ATTACKING
						break
			if(prob(1))
				src.emote(pick("dance", "flip", "laugh"))
			if(prob(0.5))
				var/list/priority_targets = list()
				var/list/targets = list()
				for(var/atom/movable/AM in view(5, src))
					if(ismob(AM) && AM != src)
						priority_targets += AM
					else if(isobj(AM) && isturf(AM.loc) && !istype(AM, /obj/overlay))
						targets += AM
				if(length(priority_targets) && prob(55))
					src.point_at(pick(priority_targets))
					if(prob(20))
						src.emote("laugh")
				else if(length(targets))
					src.point_at(pick(targets))

	ai_findtarget_new()
		if (ai_aggressive || ai_aggression_timeout == 0 || (world.timeofday - ai_threatened) < ai_aggression_timeout)
			..()

	was_harmed(var/atom/T as mob|obj, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		// Dead monkeys can't hold a grude and stops emote
		if(isdead(src) || T == src)
			return ..()
		if(ismonkey(T) && T:ai_active && prob(90))
			return ..()
		//src.ai_aggressive = 1
		var/aggroed = src.ai_state != AI_ATTACKING
		src.target = T
		src.ai_state = AI_ATTACKING
		src.ai_threatened = world.timeofday
		src.ai_target = T
		src.shitlist[T] ++
		if (prob(40))
			src.emote("scream")
		var/pals = 0
		for_by_tcl(pal, /mob/living/carbon/human/npc/monkey)
			if (get_dist(src, pal) > 7)
				continue
			if (pals >= 5)
				return
			if (prob(10))
				continue
			//pal.ai_aggressive = 1
			pal.target = T
			pal.ai_state = AI_ATTACKING
			pal.ai_threatened = world.timeofday
			pal.ai_target = T
			pal.shitlist[T] ++
			pals ++
			if (prob(40))
				src.emote("scream")
		if(aggroed && !isunconscious(src))
			walk_towards(src, ai_target, ai_movedelay)

	ai_is_valid_target(mob/M)
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (istype(H.wear_suit, /obj/item/clothing/suit/monkey))
				return FALSE
		return ..()

	proc/shot_by(var/atom/A as mob|obj)
		if (src.ai_state == AI_ATTACKING)
			return
		if (ishuman(A))
			src.was_harmed(A)
		else
			walk_away(src, A, 10, 1)
			SPAWN_DBG(1 SECOND)
				walk(src, 0)

	proc/done_with_you(var/atom/T as mob|obj)
		if (!T)
			return 0
		if (src.health <= 0 || (get_dist(src, T) >= 11))
			if(src.health <= 0)
				src.ai_state = AI_FLEEING
			else
				src.ai_state = 0
				src.target = null
				src.ai_target = null
			src.ai_frustration = 0
			walk_towards(src,null)
			return 1
		if (src.shitlist[T] && src.shitlist[T] > 10)
			return 0
		if (ismob(T))
			var/mob/M = T
			if (M.health <= 0)
				src.target = null
				src.ai_state = 0
				src.ai_target = null
				src.ai_frustration = 0
				walk_towards(src,null)
				return 1
		else
			return 0

	proc/ai_pickpocket(priority_only=FALSE)
		if (src.getStatusDuration("weakened") || src.getStatusDuration("stunned") || src.getStatusDuration("paralysis") || src.stat || src.ai_picking_pocket)
			return
		var/list/possible_targets = list()
		var/list/priority_targets = list()
		for (var/mob/living/carbon/human/H in view(1, src))
			if(H == src)
				continue
			if (istype(H, /mob/living/carbon/human/npc/monkey))
				if(H.handcuffs)
					priority_targets += H
					continue
				for(var/obj/item/thing in H)
					if(IS_NPC_HATED_ITEM(thing) && thing.equipped_in_slot)
						priority_targets += H
						break
				continue
			if (!H.l_store && !H.r_store && isalive(H))
				continue
			possible_targets += H
		if(length(possible_targets) == 0 && length(priority_targets) == 0)
			return
		var/mob/living/carbon/human/theft_target
		if(length(priority_targets))
			theft_target = pick(priority_targets)
		else if(!priority_only)
			theft_target = pick(possible_targets)
		var/obj/item/thingy
		var/slot = 15
		if(!theft_target)
			return
		if(ismonkey(theft_target))
			if(theft_target.handcuffs)
				actions.start(new/datum/action/bar/icon/handcuffRemovalOther(theft_target), src)
				return
			for(var/obj/item/thing in theft_target)
				if(IS_NPC_HATED_ITEM(thing) && thing.equipped_in_slot)
					thingy = thing
					slot = thing.equipped_in_slot
					break
		if(!thingy)
			if(!isalive(theft_target))
				var/list/choices = theft_target.get_equipped_items()
				if(!length(choices))
					return
				thingy = pick(choices)
				slot = thingy.equipped_in_slot
			else if (theft_target.l_store && theft_target.r_store)
				thingy = pick(theft_target.l_store, theft_target.r_store)
				if (thingy == theft_target.r_store)
					slot = 16
			else if (theft_target.l_store)
				thingy = theft_target.l_store
			else if (theft_target.r_store)
				thingy = theft_target.r_store
				slot = 16
			else // ???
				return
		walk_towards(src, null)
		if(ismonkey(theft_target))
			src.say("I help!")
		else if(isalive(theft_target))
			src.say("[pick("Gimme", "Want", "Need")] [thingy.name].") // Monkeys don't know grammar!
		actions.start(new/datum/action/bar/icon/filthyPickpocket(src, theft_target, slot), src)

	ai_move()
		if(src.ai_picking_pocket)
			return
		. = ..()

	proc/ai_knock_from_hand(priority_only=FALSE)
		if (src.getStatusDuration("weakened") || src.getStatusDuration("stunned") || src.getStatusDuration("paralysis") || src.stat || src.ai_picking_pocket || src.r_hand)
			return
		var/list/possible_targets = list()
		var/list/priority_targets = list()
		for (var/mob/living/carbon/human/H in view(1, src))
			if (istype(H, /mob/living/carbon/human/npc/monkey))
				continue
			if (!H.l_hand && !H.r_hand)
				continue
			possible_targets += H
			if(H.equipped() && IS_NPC_HATED_ITEM(H.equipped()) || istype(H.equipped(), /obj/item/gun) && prob(60))
				priority_targets += H
		if(length(possible_targets) == 0 && length(priority_targets) == 0)
			return
		var/mob/living/carbon/human/theft_target
		if(length(priority_targets))
			theft_target = pick(priority_targets)
		else if(!priority_only)
			theft_target = pick(possible_targets)
		if(!theft_target)
			return
		walk_towards(src, null)
		src.a_intent = INTENT_DISARM
		theft_target.Attackhand(src)
		src.a_intent = src.ai_default_intent

	proc/ai_syndicate_fuck_around()
		if (src.getStatusDuration("weakened") || src.getStatusDuration("stunned") || src.getStatusDuration("paralysis") || src.stat || src.ai_picking_pocket)
			return
		var/list/possible_targets = list()
		//proof of concept, redo this to have a saved list of things to fuck with and move to so we're not a) constantly scanning b) limited to line of sight
		for (var/obj/decoration/syndiepc/M in orange(10, src))
			possible_targets += M
		for (var/obj/machinery/nuclearbomb/M in orange(10, src))
			possible_targets += M
		for (var/obj/cairngorm_stats/foss/M in orange(10, src))
			possible_targets += M
		if(length(possible_targets) == 0)
			return
		var/obj/fuckaround_target = pick(possible_targets)
		if(!fuckaround_target)
			return
		src.a_intent = INTENT_HELP
		src.ai_state = AI_IDLE

		//should really check if we're still in range but whatever it's fine
		if (istype(fuckaround_target, /obj/decoration/syndiepc))
			if(prob(50))
				walk_towards(src, fuckaround_target, ai_movedelay)
				sleep(5 SECONDS)
				src.visible_message(pick("<B>[name]</B> types something into [fuckaround_target]. You're not sure what it is, but it did something.", \
				"<B>[name]</B> acknowledges some sort of message on [fuckaround_target].", \
				"<B>[name]</B> looks at [fuckaround_target] with [pick("vague","mild","intense","")] [pick("concern","annoyance","interest")] and types something in."), 1)
				playsound(fuckaround_target, "sound/machines/keyboard[rand(1,3)].ogg", 50, 1, -5)
				sleep(15)
				if(prob(5))
					playsound(fuckaround_target, 'sound/machines/buzz-two.ogg', 50, 1, -5)
					if(prob(75))
						src.emote(pick("sigh","scream","grump"))
				else
					playsound(fuckaround_target, 'sound/machines/twobeep.ogg', 50, 1, -5)

		else if (istype(fuckaround_target, /obj/machinery/nuclearbomb))
			if(prob(5))
				src.visible_message(pick("<B>[name]</B> glances at [fuckaround_target] with a mix of fear and respect.", \
				"<B>[name]</B> seems to want [fuckaround_target] off this ship as soon as possible.", \
				"<B>[name]</B> makes a little explosion noise and gesture at [fuckaround_target]."), 1)
				if(prob(20))
					src.emote("scream")
		else if (istype(fuckaround_target, /obj/cairngorm_stats/foss))
			if(prob(5))
				walk_towards(src, fuckaround_target, ai_movedelay)
				sleep(5 SECONDS)
				src.visible_message(pick("<B>[name]</B> performs a little salute at [fuckaround_target]. [pick("Aw, how cute.","That's kinda weird, actually!")]", \
				"<B>[name]</B> picks [his_or_her(src)] nose and wipes it on [fuckaround_target].", \
				"<B>[name]</B> closely reads the names on [fuckaround_target] and [pick("sheds a tear","laughs","hoots","makes a fart noise","flips one of them off")]."), 1)
				if(prob(10))
					sleep(2 SECONDS)
					src.emote("fart")
		else
			src.visible_message(pick("<B>[name]</B> [pick("pokes","prods","fusses with")] [fuckaround_target].", \
			"<B>[name]</B> [pick("hoots","chimpers","grunts")] at [fuckaround_target]."), 1)
		sleep(3 SECONDS)
		src.a_intent = src.ai_default_intent
		walk_towards(src, null)
		src.ai_state = 0
		return

	hear_talk(mob/M as mob, messages, heardname, lang_id)
		if (isalive(src) && messages)
			if (M.singing)
				if (M.singing & (BAD_SINGING | LOUD_SINGING))
					if (prob(20))
						// monkey is angered by singing
						spawn(0.5 SECONDS)
							was_harmed(M)
							var/singing_modifier = (M.singing & BAD_SINGING) ? "bad" : "loud"
							src.visible_message("<B>[name]</B> becomes furious at [M] for [his_or_her(M)] [singing_modifier] singing!", 1)
							src.say(pick("Must take revenge for insult to music!", "I now attack you like your singing attacked my ears!"))
					else
						spawn(0.5 SECONDS)
							src.visible_message(pick("<B>[name]</B> doesn't seem to like [M]'s singing", \
							"<B>[name]</B> puts their hands over [his_or_her(src)] ears", \
							), 1)
						// monkey merely doesn't like the singing
							src.say(pick("You human sing worse than a baboon!", \
							"Me know gorillas with better vocal pitch than you!", \
							"Monkeys ears too sensitive for this cacophony!", \
							"You sound like you singing in two keys at same time!", \
							"Monkey no like atonal music!")) // monkeys don't know grammar but naturally know concepts like "atonal" and "cacophony"
							if (prob(40))
								src.emote("scream")
		..()

	proc/pursuited_by(atom/movable/AM)
		src.ai_state = AI_FLEEING
		src.ai_target = AM
		src.target = AM

/datum/action/bar/icon/filthyPickpocket
	id = "pickpocket"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/ui/screen1.dmi'
	icon_state = "grabbed"

	var/mob/living/carbon/human/npc/source  //The npc doing the action
	var/mob/living/carbon/human/target  	//The target of the action
	var/slot						    	//The slot number

	New(var/Source, var/Target, var/Slot)
		source = Source
		target = Target
		slot = Slot

		var/obj/item/I = target.get_slot(slot)
		if(I)
			if(I.duration_remove > 0)
				duration = I.duration_remove
			else
				duration = 25
		..()

	onStart()
		..()

		target.add_fingerprint(source) // Added for forensics (Convair880).
		var/obj/item/I = target.get_slot(slot)

		if(!I)
			source.show_text("There's nothing in that slot.", "red")
			interrupt(INTERRUPT_ALWAYS)
			return

		if(!I.handle_other_remove(source, target))
			source.show_text("[I] can not be removed.", "red")
			interrupt(INTERRUPT_ALWAYS)
			return

		logTheThing("combat", source, target, "tries to pickpocket \an [I] from [constructTarget(target,"combat")]")

		if(slot == SLOT_L_STORE || slot == SLOT_R_STORE)
			source.visible_message("<B>[source]</B> rifles through [target]'s pockets!", "You rifle through [target]'s pockets!")
		else
			source.visible_message("<B>[source]</B> rifles through [target]!", "You rifle through [target]!")

		source.ai_picking_pocket = 1

	onEnd()
		..()

		if(get_dist(source, target) > 1 || target == null || source == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/obj/item/I = target.get_slot(slot)
		if(!I)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(I.handle_other_remove(source, target))
			logTheThing("combat", source, target, "successfully pickpockets \an [I] from [constructTarget(target,"combat")]!")
			if(slot == SLOT_L_STORE || slot == SLOT_R_STORE)
				source.visible_message("<B>[source]</B> grabs [I] from [target]'s pockets!", "You grab [I] from [target]'s pockets!")
			else
				source.visible_message("<B>[source]</B> grabs [I] from [target]!", "You grab [I] from [target]!")
			target.u_equip(I)
			I.dropped(target)
			I.layer = initial(I.layer)
			I.add_fingerprint(source)
			source.put_in_hand_or_drop(I)
		else
			source.show_text("You fail to remove [I] from [target].", "red")

		source.ai_picking_pocket = 0

	onUpdate()
		..()
		if(get_dist(source, target) > 1 || target == null || source == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(!target.get_slot(slot=slot))
			interrupt(INTERRUPT_ALWAYS)

	onInterrupt()
		..()
		source.ai_picking_pocket = 0

/mob/living/carbon/human/npc/monkey/angry
	ai_aggressive = 1
	ai_calm_down = 0
	ai_default_intent = INTENT_HARM
	ai_aggression_timeout = null
	max_health = 150

	New()
		..()
		SPAWN_DBG(1 SECOND)
			var/head = pick(/obj/item/clothing/head/bandana/red, /obj/item/clothing/head/bandana/random_color)
			src.equip_new_if_possible(/obj/item/clothing/shoes/tourist, slot_shoes)
			src.equip_new_if_possible(head, slot_head)
			var/weap = pick(/obj/item/saw/active, /obj/item/extinguisher, /obj/item/ratstick, /obj/item/razor_blade, /obj/item/bat, /obj/item/kitchen/utensil/knife/cleaver, /obj/item/nunchucks, /obj/item/tinyhammer, /obj/item/storage/toolbox/mechanical/empty, /obj/item/kitchen/rollingpin)
			src.put_in_hand_or_drop(new weap)
		APPLY_MOB_PROPERTY(src, PROP_STAMINA_REGEN_BONUS, "angry_monkey", 5)
		src.add_stam_mod_max("angry_monkey", 100)

	get_disorient_protection()
		. = ..()
		return clamp(.+25, 80, .)

	ai_is_valid_target(mob/M)
		return ..() && !(istype(M, /mob/living/carbon/human/npc/monkey/angry))

// sea monkeys
/mob/living/carbon/human/npc/monkey/sea
	name = "sea monkey"
	max_health = 150
	static_type_override = /datum/mutantrace/monkey/seamonkey
	ai_useitems = FALSE // or they eat all the floor pills and die before anyone visits

	New()
		..()
		SPAWN_DBG(0.5 SECONDS)
			if (!src.disposed)
				src.bioHolder.AddEffect("seamonkey")
				src.get_static_image()
				if (src.name == "sea monkey" || !src.name)
					src.name = pick_string_autokey("names/monkey.txt")
				src.real_name = src.name


/mob/living/carbon/human/npc/monkey/sea/gang
	//name = "sea monkey"
	//real_name = "sea monkey"
	gender = "male"
	ai_aggressive = 1
	ai_calm_down = 0
	ai_aggression_timeout = null
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses, slot_glasses)
			src.equip_new_if_possible(/obj/item/clothing/under, slot_w_uniform)

/mob/living/carbon/human/npc/monkey/sea/gang_gun
	//name = "sea monkey"
	//real_name = "sea monkey"
	gender = "female"
	ai_aggressive = 1
	ai_calm_down = 0
	ai_aggression_timeout = null
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses, slot_glasses)
			src.equip_new_if_possible(/obj/item/gun/modular/italian/revolver/basic, slot_l_hand)
			src.equip_new_if_possible(/obj/item/clothing/under, slot_w_uniform)

/mob/living/carbon/human/npc/monkey/sea/rich
	//name = "sea monkey"
	//real_name = "sea monkey"
	gender = "female"
	ai_aggressive = 1
	ai_calm_down = 0
	ai_aggression_timeout = null
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/head/crown, slot_head)

/mob/living/carbon/human/npc/monkey/sea/lab
	name = "Kimmy"
	real_name = "Kimmy"
	gender = "female"
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/glasses/regular, slot_glasses)
			src.equip_new_if_possible(/obj/item/clothing/under/rank/scientist, slot_w_uniform)

// non-AI monkeys
/mob/living/carbon/human/monkey/mr_wigglesby
	name = "Mr. Wigglesby"
	real_name = "Mr. Wigglesby"
	gender = "male"
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/under/suit, src.slot_w_uniform)
			src.equip_new_if_possible(/obj/item/clothing/shoes/black, src.slot_shoes)

#undef IS_NPC_HATED_ITEM
