// emote



/mob/living/carbon/human/emote(var/act, var/voluntary = 0, var/emoteTarget = null) //mbc : if voluntary is 2, it's a hotkeyed emote and that means that we can skip the findtext check. I am sorry, cleanup later
	var/param = null

	if (!bioHolder) bioHolder = new/datum/bioHolder( src )

	if(voluntary && !src.emote_allowed)
		return

	if (src.bioHolder.HasEffect("revenant"))
		src.visible_message("<span class='alert'>[src] makes [pick("a rude", "an eldritch", "a", "an eerie", "an otherworldly", "a netherly", "a spooky")] gesture!</span>", group = "revenant_emote")
		return

	if (emoteTarget)
		param = emoteTarget
	else if (voluntary == 1)
		if (findtext(act, " ", 1, null))
			var/t1 = findtext(act, " ", 1, null)
			param = copytext(act, t1 + 1, length(act) + 1)
			act = copytext(act, 1, t1)

	for (var/uid in src.pathogens)
		var/datum/pathogen/P = src.pathogens[uid]
		if (P.onemote(act, voluntary, param))
			return

	for (var/obj/item/implant/I in src.implant)
		if (I.implanted)
			I.trigger(act, src)

	var/m_type = MESSAGE_VISIBLE
	var/custom = 0 //Sorry, gotta make this for chat groupings.

	var/maptext_out = 0
	var/message = null
	if (src.mutantrace)
		var/list/mutantrace_emote_stuff = src.mutantrace.emote(act, voluntary)
		if(!islist(mutantrace_emote_stuff))
			message = mutantrace_emote_stuff
		else
			if(length(mutantrace_emote_stuff) >= 1)
				message = mutantrace_emote_stuff[1]
			if(length(mutantrace_emote_stuff) >= 2)
				maptext_out = mutantrace_emote_stuff[2]
	if (!message)
		//Much of this ideally gets turned into a
		var/what_to_do = human_emotes.Find(lowertext(act))
		var/list/what_have_we_done = null
		if (what_to_do)
			var/datum/emote/how_to_do_it = emote_controls.get_emote(human_emotes[lowertext(act)])
			if (istype(how_to_do_it))
				if (!emote_check(voluntary, how_to_do_it.return_cooldown(src, voluntary), 1, !(how_to_do_it.possible_while_dead)))
					return
				what_have_we_done= how_to_do_it.enact(src, voluntary, param)
		if (islist(what_have_we_done))
			message = what_have_we_done[1]
			maptext_out = what_have_we_done[2]
			m_type = what_have_we_done[3]
		else
			src.show_text("Unusable emote '[act]'. 'Me help' for a list.", "blue")
			return
		// These still need datumising/looking at but to my count I datumised 129 emotes already (not counting doubles or the bullshit that the middle finger ones are up to)
		// you can sort these out probably
		/*
			if ("custom")
				if (src.client)
					if (IS_TWITCH_CONTROLLED(src)) return
					var/input = sanitize(html_encode(input("Choose an emote to display.")))
					var/input2 = input("Is this a visible or audible emote?") in list("Visible","Audible")
					if (input2 == "Visible") m_type = 1
					else if (input2 == "Audible") m_type = 2
					else
						alert("Unable to use this emote, must be either audible or visible.")
						return
					phrase_log.log_phrase("emote", input)
					message = "<B>[src]</B> [input]"
					maptext_out = "<I>[input]</I>"
					custom = copytext(input, 1, 10)

			if ("customv")
				if (IS_TWITCH_CONTROLLED(src)) return
				if (!param)
					param = input("Choose an emote to display.")
					if(!param) return

				param = sanitize(html_encode(param))
				phrase_log.log_phrase("emote", param)
				message = "<b>[src]</b> [param]"
				maptext_out = "<I>[param]</I>"
				m_type = 1
				custom = copytext(param, 1, 10)

			if ("customh")
				if (IS_TWITCH_CONTROLLED(src)) return
				if (!param)
					param = input("Choose an emote to display.")
					if(!param) return
				param = sanitize(html_encode(param))
				phrase_log.log_phrase("emote", param)
				message = "<b>[src]</b> [param]"
				maptext_out = "<I>[param]</I>"
				m_type = 2
				custom = copytext(param, 1, 10)

			if ("me")
				if (IS_TWITCH_CONTROLLED(src)) return
				if (!param)
					return
				param = sanitize(html_encode(param))
				phrase_log.log_phrase("emote", param)
				message = "<b>[src]</b> [param]"
				maptext_out = "<I>[param]</I>"
				m_type = 1 // default to visible
				custom = copytext(param, 1, 10)

			if ("help")
				src.show_text("To use emotes, simply enter 'me (emote)' in the input bar. Certain emotes can be targeted at other characters - to do this, enter 'me (emote) (name of character)' without the brackets.")
				src.show_text("For a list of all emotes, use 'me list'. For a list of basic emotes, use 'me listbasic'. For a list of emotes that can be targeted, use 'me listtarget'.")

			if ("listbasic")
				src.show_text("smile, grin, smirk, frown, scowl, grimace, sulk, pout, nod, blink, drool, shrug, tremble, quiver, shiver, shudder, shake, \
				think, ponder, clap, wave, salute, flap, aflap, laugh, chuckle, giggle, chortle, guffaw, cough, hiccup, sigh, mumble, grumble, groan, moan, sneeze, \
				sniff, snore, whimper, yawn, choke, gasp, weep, sob, wail, whine, gurgle, gargle, blush, flinch, blink_r, eyebrow, shakehead, shakebutt, \
				pale, flipout, rage, shame, raisehand, crackknuckles, stretch, rude, cry, retch, raspberry, tantrum, gesticulate, wgesticulate, smug, \
				nosepick, flex, facepalm, panic, snap, airquote, twitch, twitch_v, faint, deathgasp, signal, wink, collapse, trip, dance, scream, \
				burp, fart, monologue, contemplate, custom")

			if ("listtarget")
				src.show_text("salute, bow, hug, wave, glare, stare, look, leer, nod, flipoff, doubleflip, shakefist, handshake, daps, slap, boggle, highfive, fingerguns")

			if ("suicide")
				src.show_text("Suicide is a command, not an emote.  Please type 'suicide' in the input bar at the bottom of the game window to kill yourself.", "red")
	*/
	//copy paste lol

	if (maptext_out && !ON_COOLDOWN(src, "emote maptext", 0.5 SECONDS))
		var/image/chat_maptext/chat_text = null
		SPAWN_DBG(0) //blind stab at a life() hang - REMOVE LATER
			if (speechpopups && src.chat_text)
				chat_text = make_chat_maptext(src, maptext_out, "color: #C2BEBE;" + src.speechpopupstyle, alpha = 140)
				if(chat_text)
					chat_text.measure(src.client)
					for(var/image/chat_maptext/I in src.chat_text.lines)
						if(I != chat_text)
							I.bump_up(chat_text.measured_height)

			if (message)
				logTheThing("say", src, null, "EMOTE: [message]")
				act = lowertext(act)
				if (m_type & 1)
					for (var/mob/O in viewers(src, null))
						O.show_message("<span class='emote'>[message]</span>", m_type, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)
				else if (m_type & 2)
					for (var/mob/O in hearers(src, null))
						O.show_message("<span class='emote'>[message]</span>", m_type, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)
				else if (!isturf(src.loc))
					var/atom/A = src.loc
					for (var/mob/O in A.contents)
						O.show_message("<span class='emote'>[message]</span>", m_type, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)


	else

		if (message)
			logTheThing("say", src, null, "EMOTE: [message]")
			act = lowertext(act)
			if (m_type & 1)
				for (var/mob/O in viewers(src, null))
					O.show_message("<span class='emote'>[message]</span>", m_type, group = "[src]_[act]_[custom]")
			else if (m_type & 2)
				for (var/mob/O in hearers(src, null))
					O.show_message("<span class='emote'>[message]</span>", m_type, group = "[src]_[act]_[custom]")
			else if (!isturf(src.loc))
				var/atom/A = src.loc
				for (var/mob/O in A.contents)
					O.show_message("<span class='emote'>[message]</span>", m_type, group = "[src]_[act]_[custom]")

// I'm very sorry for this but it's to trick the linter into thinking emote doesn't sleep (since it usually doesn't)
// you see from the important places it's called as emote("scream") etc. which doesn't actually sleep but for the linter to recognize
// that would be difficult, datumize emotes 2day!
#ifdef SPACEMAN_DMM
/mob/living/carbon/human/emote(var/act, var/voluntary = 0, var/emoteTarget = null)
#endif

/mob/living/carbon/human/proc/expel_fart_gas(var/oxyplasmafart)
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/gas = unpool(/datum/gas_mixture)
	gas.vacuum()
	if(oxyplasmafart == 1)
		gas.toxins += 1
	if(oxyplasmafart == 2)
		gas.oxygen += 1
	if(src.reagents && src.reagents.get_reagent_amount("fartonium") > 6.9)
		gas.farts = 6.9
	else if(src.reagents && src.reagents.get_reagent_amount("egg") > 6.9)
		gas.farts = 2.69
	else if(src.reagents && src.reagents.get_reagent_amount("refried_beans") > 6.9)
		gas.farts = 1.69
	else
		gas.farts = 0.69
	gas.temperature = T20C
	gas.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
	if (T)
		T.assume_air(gas)

	src.remove_stamina(STAMINA_DEFAULT_FART_COST)

/mob/living/carbon/human/proc/dabbify()
	if(ON_COOLDOWN(src, "dab", 2 SECONDS))
		return
	src.render_target = "*\ref[src]"
	var/image/left_arm = image(null, src)
	left_arm.render_source = src.render_target
	left_arm.filters += filter(type="alpha", icon=icon('icons/mob/humanmasks.dmi', "r_arm"))
	left_arm.appearance_flags = KEEP_APART
	var/image/right_arm = image(null, src)
	right_arm.render_source = src.render_target
	right_arm.filters += filter(type="alpha", icon=icon('icons/mob/humanmasks.dmi', "l_arm"))
	right_arm.appearance_flags = KEEP_APART
	var/image/torso = image(null, src)
	torso.render_source = src.render_target
	torso.filters += filter(type="alpha", icon=icon('icons/mob/humanmasks.dmi', "torso"))
	torso.appearance_flags = KEEP_APART
	APPLY_MOB_PROPERTY(src, PROP_CANTMOVE, "dabbify")
	src.update_canmove()
	src.set_dir(SOUTH)
	src.dir_locked = TRUE
	sleep(0.1) //so the direction setting actually takes place
	world << torso
	world << right_arm
	world << left_arm
	torso.plane = PLANE_DEFAULT
	right_arm.plane = PLANE_DEFAULT
	left_arm.plane = PLANE_DEFAULT
	/*torso.loc = get_turf(O)
	right_arm.loc = get_turf(O)
	left_arm.loc = get_turf(O)*/
	animate(left_arm, transform = turn(left_arm.transform, -110), pixel_y = 10, pixel_x = -1, 5, 1, CIRCULAR_EASING)
	animate(right_arm, transform = turn(right_arm.transform, -95), pixel_y = 1, pixel_x = 10, 5, 1, CIRCULAR_EASING)
	SPAWN_DBG(1 SECOND)
		animate(left_arm, transform = null, pixel_y = 0, pixel_x = 0, 4, 1, CIRCULAR_EASING)
		animate(right_arm, transform = null, pixel_y = 0, pixel_x = 0, 4, 1, CIRCULAR_EASING)
		sleep(0.5 SECONDS)
		qdel(torso)
		qdel(right_arm)
		qdel(left_arm)
		REMOVE_MOB_PROPERTY(src, PROP_CANTMOVE, "dabbify")
		src.update_canmove()
		src.dir_locked = FALSE
		src.render_target = "\ref[src]"

/mob/living/proc/do_suplex(obj/item/grab/G)
	if (!(G.state >= 1 && isturf(src.loc) && isturf(G.affecting.loc)))
		return null
	if(!IN_RANGE(src, G.affecting, 1))
		return null

	var/obj/table/tabl = locate() in src.loc.contents
	var/turf/newloc = src.loc
	G.affecting.set_loc(newloc)
	if (!G.affecting.reagents.has_reagent("fliptonium"))
		animate_spin(src, prob(50) ? "L" : "R", 1, 0)

	if (!iswrestler(src) && src.traitHolder && !src.traitHolder.hasTrait("glasscannon"))
		src.remove_stamina(STAMINA_FLIP_COST)
		src.stamina_stun()

	G.affecting.was_harmed(src)

	src.emote("scream")
	. = "<span class='alert'><B>[src] suplexes [G.affecting][tabl ? " into [tabl]" : null]!</B></span>"
	logTheThing("combat", src, G.affecting, "suplexes [constructTarget(G.affecting,"combat")][tabl ? " into \an [tabl]" : null] [log_loc(src)]")
	G.affecting.lastattacker = src
	G.affecting.lastattackertime = world.time
	if (iswrestler(src))
		if (prob(50))
			G.affecting.ex_act(3) // this is hilariously overpowered, but WHATEVER!!!
		else
			G.affecting.changeStatus("weakened", 5 SECONDS)
			G.affecting.force_laydown_standup()
			G.affecting.TakeDamage("head", 10, 0, 0, DAMAGE_BLUNT)
		playsound(src.loc, "sound/impact_sounds/Flesh_Break_1.ogg", 75, 1)
	else
		src.changeStatus("weakened", 3.9 SECONDS)

		if (client?.hellbanned)
			src.changeStatus("weakened", 4 SECONDS)
		if (G.affecting && !G.affecting.hasStatus("weakened"))
			G.affecting.changeStatus("weakened", 4.5 SECONDS)


		G.affecting.force_laydown_standup()
		SPAWN_DBG(1 SECOND) //let us do that combo shit people like with throwing
			src.force_laydown_standup()

		G.affecting.TakeDamage("head", 9, 0, 0, DAMAGE_BLUNT)
		playsound(src.loc, "sound/impact_sounds/Flesh_Break_1.ogg", 75, 1)
	if (istype(tabl, /obj/table/glass))
		var/obj/table/glass/g_tabl = tabl
		if (!g_tabl.glass_broken)
			if ((prob(g_tabl.reinforced ? 60 : 80)) || (src.bioHolder.HasEffect("clumsy") && (!g_tabl.reinforced || prob(90))))
				SPAWN_DBG(0)
					g_tabl.smash()
					src.changeStatus("weakened", 7 SECONDS)
					random_brute_damage(src, rand(20,40))
					take_bleeding_damage(src, src, rand(20,40))
					G.affecting.changeStatus("weakened", 4 SECONDS)
					random_brute_damage(G.affecting, rand(20,40))
					take_bleeding_damage(G.affecting, src, rand(20,40))
					G.affecting.force_laydown_standup()
					sleep(1 SECOND) //let us do that combo shit people like with throwing
					src.force_laydown_standup()

/// Looks for the kind_of_target movables within range, and throws the user an input
/// Valid kinds: "mob", "obj", "both"
/mob/living/proc/get_targets(range = 1, kind_of_target = "mob")
	if(!isturf(get_turf(src))) return

	var/list/atom/movable/everything_around = list()

	for(var/atom/movable/AM in view(range, get_turf(src)))
		if(AM == src)
			continue
		everything_around |= AM

	switch(kind_of_target)
		if("both")
			return everything_around
		if("mob")
			. = list()
			for(var/mob/M in everything_around)
				if(M == src)
					continue
				. |= M
		if("obj")
			. = list()
			for(var/obj/O in everything_around)
				if(O == src)
					continue
				. |= O
