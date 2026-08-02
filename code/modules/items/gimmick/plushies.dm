/obj/submachine/claw_machine
	name = "claw machine"
	desc = "Sure we got our health insurance benefits cut, and yeah we don't get any overtime on holidays, but hey - free to play claw machines!"
	icon = 'icons/obj/items/plushies.dmi'
	icon_state = "claw"
	anchored = ANCHORED
	density = 1
	mats = list("MET-1"=5, "CON-1"=5, "CRY-1"=5, "FAB-1"=5)
	deconstruct_flags = DECON_MULTITOOL | DECON_WRENCH | DECON_CROWBAR
	var/busy = 0
	var/list/prizes = list(/obj/item/toy/plush/small/bee,\
	/obj/item/toy/plush/small/buddy,\
	/obj/item/toy/plush/small/kitten,\
	/obj/item/toy/plush/small/monkey,\
	/obj/item/toy/plush/small/possum,\
	/obj/item/toy/plush/small/brullbar,\
	/obj/item/toy/plush/small/bunny,\
	/obj/item/toy/plush/small/penguin,\
	/obj/item/toy/plush/small/moth)
	var/list/prizes_rare = list(/obj/item/toy/plush/small/bee/cute,\
	/obj/item/toy/plush/small/buddy/future,\
	/obj/item/toy/plush/small/kitten/wizard,\
	/obj/item/toy/plush/small/monkey/assistant,\
	/obj/item/toy/plush/small/bunny/mask,\
	/obj/item/toy/plush/small/penguin/cool)
	var/list/prizes_ultra_rare = list(/obj/item/toy/plush/small/orca,\
	/obj/item/toy/plush/small/tuba,\
	/obj/item/toy/plush/small/chris,\
	/obj/item/toy/plush/small/fancyflippers,\
	/obj/item/toy/plush/small/billy,\
	/obj/item/toy/plush/small/arthur,\
	/obj/item/toy/plush/small/deneb,\
	/obj/item/toy/plush/small/singuloose)

/obj/submachine/claw_machine/attack_hand(var/mob/user as mob)
	src.add_dialog(user)
	if(src.busy)
		boutput(user, "<span class='alert'>Someone else is currently playing [src]. Be patient!</span>")
	else
		actions.start(new/datum/action/bar/icon/claw_machine(user,src), user)
		return

/datum/action/bar/icon/claw_machine
	duration = 100
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT | INTERRUPT_ACTION
	id = "claw_machine"
	icon = 'icons/obj/items/plushies.dmi'
	icon_state = "claw_action"
	var/mob/M
	var/obj/submachine/claw_machine/CM

/datum/action/bar/icon/claw_machine/New(mob, machine)
	M = mob
	CM = machine
	..()

/datum/action/bar/icon/claw_machine/onUpdate()
	..()
	if(get_dist(M, CM) > 1 || M == null || CM == null)
		interrupt(INTERRUPT_ALWAYS)
		return
	if(prob(10) && !M.traitHolder?.hasTrait("claw"))
		playsound(CM, 'sound/machines/claw_machine_fail.ogg', 80, 1)
		M.visible_message("<span class='alert'>[M] flubs up and the claw drops [his_or_her(M)] prize!</spawn>")
		interrupt(INTERRUPT_ALWAYS)
		return

/datum/action/bar/icon/claw_machine/onResume()
	..()
	state = ACTIONSTATE_DELETE

/datum/action/bar/icon/claw_machine/onInterrupt()
	..()
	CM.busy = 0
	CM.icon_state = "claw"

/datum/action/bar/icon/claw_machine/onStart()
	..()
	if(get_dist(M, CM) > 1 || M == null || CM == null)
		interrupt(INTERRUPT_ALWAYS)
		return
	playsound(CM, 'sound/machines/capsulebuy.ogg', 80, 1)
	CM.busy = 1
	CM.icon_state = "claw_playing"

/datum/action/bar/icon/claw_machine/onEnd()
	..()
	if(get_dist(M, CM) > 1 || M == null || CM == null)
		interrupt(INTERRUPT_ALWAYS)
		return
	CM.busy = 0
	CM.icon_state = "claw"
	playsound(CM, 'sound/machines/claw_machine_success.ogg', 80, 1)
	M.visible_message("<span class='notice'>[M] successfully secures their precious goodie, and it drops into the prize chute with a satisfying <i>plop</i>.</span>")
	var/obj/item/P = pick(prob(20) ? (prob(33) ? CM.prizes_ultra_rare : CM.prizes_rare) : CM.prizes)
	P = new P(get_turf(src.M))
	P.desc = "Your new best friend, rescued from a cold and lonely claw machine."
	P.throw_at(M, 16, 3)

/obj/item/toy/plush
	name = "plush toy"
	icon = 'icons/obj/items/plushies.dmi'
	icon_state = "bear"
	desc = "A cute and cuddly plush toy!"
	throwforce = 3
	w_class = W_CLASS_BULKY
	throw_speed = 2
	throw_range = 3
	rand_pos = 8

/obj/item/toy/plush/proc/say_something(mob/user as mob)
	var/message = input("What should [src] say?")
	message = trim(copytext(sanitize(html_encode(message)), 1, MAX_MESSAGE_LEN))
	if (!message || get_dist(src, user) > 1)
		return
	logTheThing("say", user, null, "makes [src] say, \"[message]\"")
	user.audible_message("<span class='emote'>[src] says, \"[message]\"</span>")
	var/mob/living/carbon/human/H = user
	if (H.sims)
		H.sims.affectMotive("fun", 1)

/obj/item/toy/plush/attack_self(mob/user as mob)
	src.say_something(user)

/obj/item/toy/plush/attack(mob/M as mob, mob/user as mob)
	if (user.a_intent == INTENT_HELP)
		M.visible_message("<span class='emote'>[src] gives [M] a hug!</span>", "<span class='emote'>[src] gives you a hug!</span>")
	else
		. = ..()

/obj/item/toy/plush/small
	name = "small plush toy"
	desc = "You found a new friend!"
	w_class = W_CLASS_NORMAL
	throw_speed = 3
	throw_range = 5

/obj/item/toy/plush/small/bee
	name = "bee plush toy"
	icon_state = "bee"

/obj/item/toy/plush/small/bee/cute
	name = "super cute bee plush toy"
	icon_state = "bee_cute"

/obj/item/toy/plush/small/buddy
	name = "buddy plush toy"
	icon_state = "buddy"

/obj/item/toy/plush/small/buddy/future
	name = "future buddy plush toy"
	icon_state = "buddy_future"

/obj/item/toy/plush/small/kitten
	name = "kitten plush toy"
	icon_state = "kitten"

/obj/item/toy/plush/small/kitten/wizard
	name = "wizard kitten plush toy"
	icon_state = "kitten_wizard"

/obj/item/toy/plush/small/monkey
	name = "monkey plush toy"
	icon_state = "monkey"

/obj/item/toy/plush/small/monkey/assistant
	name = "assistant monkey plush toy"
	icon_state = "monkey_assistant"

/obj/item/toy/plush/small/monkey/george
	name = "curious george monkey plush toy"
	icon_state = "monkey_george"

/obj/item/toy/plush/small/possum
	name = "possum plush toy"
	icon_state = "possum"

/obj/item/toy/plush/small/skounk
	name = "skounk plush toy"
	icon_state = "skounk"

/obj/item/toy/plush/small/bignum
	name = "unsigned 64 bit integer"
	icon = 'icons/obj/decals/writing.dmi'
	icon_state = "writing1"
	color = "#FF00FF"

/obj/item/toy/plush/small/brullbar
	name = "brullbar plush toy"
	icon_state = "brullbar"

/obj/item/toy/plush/small/moth
	name = "moth plushie"
	desc = "A plushie depicting an adorable mothperson. It's a huggable bug!"
	icon_state = "moffplush"

/obj/item/toy/plush/small/moth/attack_self(mob/user as mob)
	playsound(user, "sound/voice/moth/scream_moth.ogg", 50, 1)
	src.audible_message("<span class='emote'>[src] screams!</span>")

/obj/item/material_piece/cloth/mothroachhide/attackby(obj/item/W as obj, mob/user as mob) //moth plush construction using a heart and mothroach hide
	if (istype(W, /obj/item/organ/heart))
		var/obj/item/organ/heart/C = W
		boutput(user, "<span class='notice'>You begin adding \the [C.name] to \the [src.name].</span>")
		if (!do_after(user, 3 SECONDS))
			boutput(user, "<span class='alert'>You were interrupted!</span>")
			return ..()
		else
			user.drop_item()
			var/obj/item/toy/plush/small/moth/N = new /obj/item/toy/plush/small/moth/(get_turf(src))
			src.change_stack_amount(-1)
			qdel(C)
			boutput(user, "You have successfully created \a [N]!")
	return ..()

/obj/item/toy/plush/small/bunny
	name = "bunny plush toy"
	icon_state = "bunny"

/obj/item/toy/plush/small/bunny/mask
	name = "gas mask bunny plush toy"
	icon_state = "bunny_mask"

/obj/item/toy/plush/small/penguin
	name = "penguin plush toy"
	icon_state = "penguin"

/obj/item/toy/plush/small/penguin/cool
	name = "super cool penguin plush toy"
	icon_state = "penguin_cool"

/obj/item/toy/plush/small/orca
	name = "Lilac the orca"
	icon_state = "orca"

/obj/item/toy/plush/small/tuba
	name = "Tuba the rat"
	icon_state = "tuba"

/obj/item/toy/plush/small/chris
	name = "Chris the goat"
	icon_state = "chris"

/obj/item/toy/plush/small/fancyflippers
	name = "Fancyflippers the gentoo penguin"
	icon_state = "fancyflippers"

/obj/item/toy/plush/small/billy
	name = "Billy the hungry fish"
	icon_state = "billy"

/obj/item/toy/plush/small/arthur
	name = "Arthur the bumblespider"
	icon_state = "arthur"

/obj/item/toy/plush/small/arthur/attack_self(mob/user as mob)
	var/menuchoice = alert("What would you like to do with [src]?",,"Awoo","Say")
	if (menuchoice == "Awoo" && !ON_COOLDOWN(src, "playsound", 2 SECONDS))
		playsound(user, "sound/voice/babynoise.ogg", 50, 1)
		src.audible_message("<span class='emote'>[src] awoos!</span>")
	else if (menuchoice == "Say")
		src.say_something(user)

/obj/item/toy/plush/small/stress_ball
	name = "stress ball"
	desc = "Talk and fidget things out. It'll be okay."
	icon_state = "stress_ball"
	throw_range = 10

/obj/item/toy/plush/small/stress_ball/attack_self(mob/user as mob)
	var/menuchoice = alert("What would you like to do with [src]?",,"Fidget","Say")
	if (menuchoice == "Fidget")
		user.visible_message("<span class='emote'>[user] fidgets with [src].</span>")
		boutput(user, "<span class='notice'>You feel [pick("a bit", "slightly", "a teeny bit", "somewhat", "surprisingly", "")] [pick("better", "more calm", "more composed", "less stressed")].</span>")
	else if (menuchoice == "Say")
		src.say_something(user)

/obj/item/toy/plush/small/deneb
	name = "Deneb the swan"
	icon_state = "deneb"

/obj/item/toy/plush/small/deneb/attack_self(mob/user as mob)
	var/menuchoice = alert("What would you like to do with [src]?",,"Honk","Say")
	if (menuchoice == "Honk" && !ON_COOLDOWN(src, "playsound", 2 SECONDS))
		playsound(user, "sound/items/rubberduck.ogg", 50, 1)
		src.audible_message("<span class='emote'>[src] honks!</span>")
	else if (menuchoice == "Say")
		src.say_something(user)

/obj/item/toy/plush/small/singuloose
	name = "Singuloose the Singulo"
	icon_state = "singuloose"

/obj/item/toy/plush/peltpal
	name = "pelt pal"
	icon_state = "peltpal_base" // horrifying
	rand_pos = 0
	w_class = W_CLASS_NORMAL
	throw_speed = 3
	throw_range = 5


	appearance_flags = KEEP_TOGETHER

	var/list/datum/contextAction/contexts = list()
	contextLayout = new /datum/contextLayout/experimentalcircle

	var/obj/item/cell/cell

	var/static/list/message_types = list("idle", "wake", "sleep", "inedible", "edible", "hungry", "bored", "happy", "evil")

	var/glitch_factor = 0 // 1 to 10, how likely it is to do something weird

	var/obj/item/toy/peltpal_guts/fur/fur = null
	var/obj/item/toy/peltpal_guts/limbs/limbs = null
	var/obj/item/toy/peltpal_guts/eyes/eyes = null
	var/obj/item/toy/peltpal_guts/eyelid/eyelid = null
	var/obj/item/toy/peltpal_guts/mouth/mouth = null

	//brain vars
	var/think_time = 5
	var/awake = FALSE
	var/sleeps = TRUE // false to make it super annoying
	var/ignored = 0 // how long since it's been interacted with (so it goes to sleep)

	var/hunger = 0 // feed me
	var/boredom = 0 // let's play a game
	var/list/eaten_items = list() // now with realistic bathroom action

	New()
		..()

		// batteries included! we should make some new crappy cell types..
		cell = new(src)
		cell.charge = 500
		cell.maxcharge = 500
		cell.name = "Ultra-Lo Power Cell"
		cell.desc = "Now in a slim form factor!"
		cell.color = "#00ffea"

		fur = new/obj/item/toy/peltpal_guts/fur(src)
		limbs = new/obj/item/toy/peltpal_guts/limbs(src)
		eyes = new/obj/item/toy/peltpal_guts/eyes(src)
		eyelid = new/obj/item/toy/peltpal_guts/eyelid(src)
		mouth = new/obj/item/toy/peltpal_guts/mouth(src)
		var/grey = rand(80,255)
		var/col = pick(random_saturated_hex_color(), (rgb(grey, grey, grey)))
		src.eyelid.color = pick(col, random_saturated_hex_color())
		src.mouth.color = col
		src.limbs.color = col
		for(var/gut in list(fur, limbs, eyes, mouth, eyelid))
			src.vis_contents += gut

		processing_items |= src

		for(var/actionType in childrentypesof(/datum/contextAction/peltpal)) //see context_actions.dm
			src.contexts += new actionType()

	proc/add_piece(var/obj/item/toy/peltpal_guts/p as obj)
		var/part_added = FALSE
		if(istype(p, /obj/item/toy/peltpal_guts/fur) && !fur)
			fur = p
			p.set_loc(src)
			src.vis_contents += p
			part_added = TRUE
		if(istype(p, /obj/item/toy/peltpal_guts/limbs) && !limbs)
			limbs = p
			p.set_loc(src)
			src.vis_contents += p
			part_added = TRUE
		if(istype(p, /obj/item/toy/peltpal_guts/eyes) && !eyes)
			eyes = p
			p.set_loc(src)
			src.vis_contents += p

			//Also add eyelids
			var/obj/item/toy/peltpal_guts/eyelid/e
			if(!src.eyelid)
				e = new/obj/item/toy/peltpal_guts/eyelid
				src.eyelid = e
				e.set_loc(src)
			src.vis_contents += eyelid
			part_added = TRUE
		if(istype(p, /obj/item/toy/peltpal_guts/mouth) && !mouth)
			mouth = p
			p.set_loc(src)
			src.vis_contents += p
			part_added = TRUE
		if(part_added)
			p.mouse_opacity = 0
			p.pixel_x = 0
			p.pixel_y = 0

	proc/remove_piece(var/t as text, var/forceful = FALSE)
		var/obj/item/toy/peltpal_guts/o
		var/part_removed = FALSE
		switch(t)
			if("fur")
				o = fur
				src.vis_contents -= fur
				o.set_loc(src.loc)
				fur = null
				part_removed = TRUE
			if("limbs")
				o = limbs
				src.vis_contents -= limbs
				o.set_loc(src.loc)
				limbs = null
				part_removed = TRUE
			if("eyes")
				o = eyes
				src.vis_contents -= eyes
				o.set_loc(src.loc)
				eyes = null
				// Hide the eyelid
				src.vis_contents -= eyelid
				part_removed = TRUE
			if("mouth")
				o = mouth
				src.vis_contents -= mouth
				o.set_loc(src.loc)
				mouth = null
				part_removed = TRUE
		if(part_removed)
			o.mouse_opacity = 1
			if(forceful)
				o.streak_object(alldirs)
				src.visible_message("<span class='alert'>[src]'s [o] suddenly flies off!</span>")

	attackby(obj/item/W as obj, mob/user as mob)
		if(user.a_intent == INTENT_HELP)
			if(istype(W, /obj/item/toy/peltpal_guts))
				user.visible_message("<span class='notice'>[user.name] adds [W] to [src]</span>","<span class='notice'>You add [W] to [src].</span>")
				user.drop_item()
				add_piece(W)
			if(istype(W, /obj/item/cell/))
				if(src.cell)
					boutput(user, "<span class='alert'>[src] already has a cell!</span>")
				else
					user.visible_message("<span class='notice'>[user.name] adds [W] to [src]</span>","<span class='notice'>You add [W] to [src].</span>")
					user.drop_item()
					W.set_loc(src)
					src.cell = W
			else // no edible guts please
				if(awake)
					user.visible_message("<span class='notice'>[user.name] offers [W] to [src]</span>","<span class='notice'>You offer [W] to [src].</span>")
					if(W.edible || prob(5 * glitch_factor))
						if(src.hunger >= 10)
							src.visible_message("<span class='notice'>[src] eats [W]!</span>")
							prepare_message("edible")
							user.drop_item()
							W.set_loc(src)
							eaten_items += W
							hunger = 0
							ignored = 0
					else
						prepare_message("inedible")
		else
			..()

	attack_hand(var/mob/user as mob)
		if(user.a_intent == INTENT_HELP)
			user.showContextActions(contexts, src, contextLayout)
		else
			..()

	process()
		if(!awake)
			if(!ON_COOLDOWN(src, "wake_chance", 10 SECONDS))
				if(prob(1)) // very small chance it wakes up randomly
					wake_up()
		else
			if(!ON_COOLDOWN(src, "think", (src.think_time) SECONDS))
				if(!cell)
					go_to_sleep()
					return
				src.cell.use(rand(1,10))
				if(cell?.charge <= 0)
					go_to_sleep()
					return
				src.think_time = 5 / sqrt(src.cell.charge / src.cell.maxcharge) // operation speed changes exponentially with battery charge
				if(think_time <= 1)
					think_time = 1
				if(eyelid != null && eyes != null) // Handle blinking
					flick("peltpal_blink", eyelid)

				if((prob(50) && (src.cell.charge / src.cell.maxcharge) > 1 || prob(glitch_factor * rand(1, 10)))) // shake around a bit
					animate_shake(src,3,rand(1,3),rand(1,3),src.pixel_x,src.pixel_y)

				if((prob(25) && (src.cell.charge / src.cell.maxcharge) > 1 || prob(glitch_factor * rand(1, 5)))) // sparks
					if (limiter.canISpawn(/obj/effects/sparks))
						var/obj/sparks = new /obj/effects/sparks()
						sparks.set_loc(get_turf(src))
						SPAWN_DBG(2 SECONDS) if (sparks) qdel(sparks)

				if(sleeps && ignored >= 10) // So it stops being annoying. Maybe.
					go_to_sleep()
					ignored = 0
					return

				if(eaten_items.len >= 3) // don't wanna lose the authentication disk in there
					eject_food()
					return

				boredom += rand(0, 2)
				hunger += rand(0, 2)
				if(hunger >= 20)
					prepare_message("hungry")
					if(limbs)
						if(prob(33))
							flick("peltpal_dance", src.limbs)
					hunger = 20
					ignored += 1
				else // hunger is a priority over boredom.. probably
					if(boredom >= 20)
						prepare_message("bored")
						boredom = 20
						ignored += 1
					else
						idle_behavior()

	proc/idle_behavior()
		if(prob(50))
			prepare_message("idle")
		if(src.limbs)
			if(prob(33))
				flick("peltpal_dance", src.limbs)

	proc/pet(mob/user as mob)
		user.visible_message("<span class='notice'>[user.name] pets [src]</span>","<span class='notice'>You pet [src].</span>")
		if(!ON_COOLDOWN(src, "pet", 30 SECONDS))
			if(src.limbs)
				flick("peltpal_dance", src.limbs)
			prepare_message("happy")
			boredom = 0
			ignored = 0

	proc/toggle_awake()
		if(awake)
			go_to_sleep()
		else
			wake_up()
		return awake

	proc/wake_up()
		prepare_message("wake")
		awake = TRUE
		eyelid.icon_state = "peltpal_eyelid"

	proc/go_to_sleep()
		prepare_message("sleep")
		awake = FALSE
		eyelid.icon_state = "peltpal_sleep"
		boredom = 0
		hunger = 0

	proc/eject_food()
		var/obj/item/peltpal_poo/poo = new /obj/item/peltpal_poo(src.loc)
		if(eaten_items != null)
			for(var/obj/o in eaten_items)
				if(o.loc == src)
					o.set_loc(poo)
			eaten_items = list()
		if(prob(10 + (10 * glitch_factor)))
			poo.streak_object(alldirs)
		src.visible_message("<span class='notice'>[src] suddenly ejects a strange green substance...</span>")

	proc/prepare_message(var/message_type)
		var/message = null
		if(!(message_type in message_types))
			return
		if(prob(10 * glitch_factor))
			message_type = pick(message_types)
		switch(message_type)
			if("idle")
				message = pick("*humming*", "Hello?", "Hee-hee-hee!")
			if("wake")
				message = pick("Wakey wake!", "Hello!", "Sleep done!")
			if("sleep")
				message = pick("Night night.", "I go bed now.", "I'm sleepy.")
			if("inedible")
				message = pick("Not food!", "No eat!", "Yuck!")
			if("edible")
				message = pick("Yummy!", "*chewing*", "Yum yum!")
			if("hungry")
				message = pick("I'm hungry!", "Feed me!", "I want food!")
			if("bored")
				message = pick("Let's play!", "Fun time!", "Hmm.. boring!")
			if("happy")
				message = pick("Yippee!", "Woohoo!", "Hooray!")
			if("evil")
				message = pick("Destroy!", "Death...", "Hahahahahahahaha")
		if(message != null)
			if(prob((10 * glitch_factor) / 2)) // divided so the wrong message isn't glitched as often
				message = corruptText(message, 33)
			speak(message)

	proc/speak(var/message)
		if (awake)
			if(mouth != null)
				flick("peltpal_talk", mouth)
		var/floating_text_style = ("")
		if(istype(src.loc,/turf))
			for(var/mob/M in oviewers(src))
				if(!M.client)
					continue
				var/chat_text = null
				if(!ON_COOLDOWN(src, "speak", 2 SECONDS))
					chat_text = make_chat_maptext(src, message, floating_text_style)
				M.show_message("<span class='name'>[src.name]</span> beeps: <span class='message'>\"[message]\"</span>",2, assoc_maptext = chat_text)
		else // it'll bug you even through containers!
			for(var/mob/M in oviewers(src.loc))
				if(!M.client)
					continue
				var/chat_text = null
				if(!ON_COOLDOWN(src, "speak", 2 SECONDS))
					chat_text = make_chat_maptext(get_turf(src), message, floating_text_style)
				M.show_message("<span class='name'>[src.name]</span> beeps: <span class='message'>\"[message]\"</span>",2, assoc_maptext = chat_text)

/obj/item/toy/peltpal_guts
	icon = 'icons/obj/items/plushies.dmi'
	mouse_opacity = 0
	rand_pos = 0

	fur
		icon_state = "fur1"

		New()
			..()
			icon_state = "fur[rand(1,11)]"

	limbs
		icon_state = "peltpal_limbs"

	eyes
		icon_state = "eye1"

		New()
			..()
			icon_state = "eye[rand(1,4)]"
	eyelid
		icon_state = "peltpal_sleep"

	mouth
		icon_state = "peltpal_mouth"

/obj/item/peltpal_poo
	name = "gooey green mass"
	desc = "You don't want to think too much about it."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "molten"
	color = "#09ff00"
	var/splat = 1

	get_desc()
		if(src.contents.len)
			. += " There might be something inside."

	attack_self(mob/user as mob)
		if(src.contents.len)
			src.loc.visible_message("<span class='alert'>[src] bursts like an overripe melon!</span>")
			playsound(get_turf(src), "sound/impact_sounds/Flesh_Break_1.ogg", 50, 1)
			for (var/obj/o in src.contents)
				o.set_loc(get_turf(src))
			qdel(src)


	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A)
		playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 100, 1)
		if (src.splat <= 0) return ..()

		if (istype(T))
			var/obj/decal/cleanable/mess/random_splotch/splotch = new /obj/decal/cleanable/mess/random_splotch(T)
			splotch.color = "#09ff00"
			splat--
		..()

/datum/contextAction/peltpal
	icon = 'icons/ui/context16x16.dmi'
	close_clicked = TRUE
	desc = ""

	execute(var/obj/item/toy/plush/peltpal/peltpal, var/mob/user)
		if (!istype(peltpal))
			return

	checkRequirements(var/obj/item/toy/plush/peltpal/peltpal, var/mob/user)
		if (!issilicon(user) && !isAIeye(user) && GET_DIST(peltpal, user) > 1)
			return FALSE
		else
			return TRUE

	power
		name = "Main Power"
		desc = "Toggle main power"
		icon_state = "secbot_power_off"

		execute(var/obj/item/toy/plush/peltpal/peltpal, var/mob/user)
			..()
			if(!peltpal.cell)
				boutput(user, "<span class='notice'>[peltpal] doesn't have a power cell.</span>")
				return
			var/toggled_result = peltpal.toggle_awake()
			src.icon_state = toggled_result ? "secbot_power_off" : "secbot_power_on"

	pet
		name = "Pet"
		desc = "Pet the creature"
		icon_state = "happy_face"

		execute(var/obj/item/toy/plush/peltpal/peltpal, var/mob/user)
			..()
			peltpal.add_fingerprint(user)
			if(!peltpal.awake)
				return
			peltpal.pet(user)

	remove_part
		name = "Remove Part"
		desc = "Take off a component"
		icon_state = "return"

		execute(var/obj/item/toy/plush/peltpal/peltpal, var/mob/user)
			..()
			peltpal.add_fingerprint(user)
			var/list/actions = list("Do nothing")
			if (peltpal.fur)
				actions.Add("Remove Fur")
			if (peltpal.limbs)
				actions.Add("Remove Limbs")
			if (peltpal.eyes)
				actions.Add("Remove Eyes")
			if (peltpal.mouth)
				actions.Add("Remove Mouth")
			if(peltpal.cell)
				actions.Add("Remove Battery")

			if (!actions.len)
				boutput(user, "<span class='alert'>There's nothing on [peltpal] that can be removed.</span>")
				return

			var/action = input("What do you want to do?", "Remove Part") in actions
			if (!action) return
			if (action == "Do nothing") return
			if (!issilicon(user) && !isAIeye(user) && GET_DIST(peltpal, user) > 1)
				boutput(user, "<span class='alert'>You need to move closer!</span>")
				return

			playsound(get_turf(peltpal), "sound/items/Ratchet.ogg", 40, 1)
			switch(action)
				if("Remove Fur")
					peltpal.remove_piece("fur")
				if("Remove Limbs")
					peltpal.remove_piece("limbs")
				if("Remove Eyes")
					peltpal.remove_piece("eyes")
				if("Remove Mouth")
					peltpal.remove_piece("mouth")
				if("Remove Battery")
					user.put_in_hand_or_drop(peltpal.cell)
					peltpal.cell = null
