// emote



/mob/living/carbon/human/emote(var/act, var/voluntary = 0, var/emoteTarget = null, datum/emote/actual_emote, param = null) //mbc : if voluntary is 2, it's a hotkeyed emote and that means that we can skip the findtext check. I am sorry, cleanup later
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

	var/datum/emote/the_datum =null

	if (src.mutantrace?.emote_overrides)
		var/what_to_do = src.mutantrace.emote_overrides.Find(lowertext(act))
		if (what_to_do)
			the_datum = get_singleton(src.mutantrace.emote_overrides[lowertext(act)])

	if (!istype(the_datum)) //no mutantrace override found
		var/what_to_do = human_emotes.Find(lowertext(act))
		if (what_to_do)
			the_datum = get_singleton(human_emotes[lowertext(act)])

	..(act, voluntary, emoteTarget, the_datum, param)

// I'm very sorry for this but it's to trick the linter into thinking emote doesn't sleep (since it usually doesn't)
// you see from the important places it's called as emote("scream") etc. which doesn't actually sleep but for the linter to recognize
// that would be difficult, datumize emotes 2day!
#ifdef SPACEMAN_DMM
/mob/living/carbon/human/emote(var/act, var/voluntary = 0, var/emoteTarget = null)
#endif

/mob/living/carbon/human/proc/expel_fart_gas(var/oxyplasmafart)
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/gas = new()
	//gas.vacuum()
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
			G.affecting.ex_act(OLD_EX_LIGHT) // this is hilariously overpowered, but WHATEVER!!!
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
/// Valid kinds: "mob", "obj", "both", "critter", "bot", "chumps"
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
		if("critter")
			. = list()
			for(var/obj/critter/C in everything_around)
				if(C == src)
					continue
				. |= C
		if("bot")
			. = list()
			for(var/obj/machinery/bot/B in everything_around)
				if(B == src)
					continue
				. |= B
		if("chumps")
			. = list()
			for(var/C as anything in everything_around)
				if(C == src)
					continue
				if(istype(C,/obj/machinery/bot/) || istype(C,/obj/critter/) || istype(C,/mob/))
					. |= C

