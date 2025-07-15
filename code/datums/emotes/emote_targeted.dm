//Jesus fucking christ targeted emote code was trash
//please go look at the old stuff for ["salute","saluteto","bow","hug","wave","waveto","blowkiss","sidehug","fingerguns","nod","nodat","glare","glareat","stare","stareat","look"] it's absurd
//I'll be honest, this code is pretty fucked because it's preserving a lot of different string contructions but it's still better than the previous shit
//also it's kinda the minimum to get the previous strings across accurately


///These can be done restrained
/datum/emote/targeted
	var/inaction_phrase //when the target is out of range
	var/action_phrase
	var/range = 5
	var/emote_onself
	var/no_out_of_range = FALSE
	var/target_type = "chumps"
	nodat
		emote_string = "nods at"
		action_phrase = "nod at"
		inaction_phrase = "not in acknowledgement distance"
	glareat
		emote_string = "glares at"
		action_phrase = "glare at"
		inaction_phrase = list("out of sight" = 1, "not in sight" = 99)
	stareat
		emote_string = "stares at"
		action_phrase = "stare at"
		inaction_phrase = list("out of sight" = 1, "not in sight" = 99)
	look
		emote_string = "looks at"
		action_phrase = "look at"
		inaction_phrase = list("out of sight" = 1, "not in sight" = 99)
	leer
		emote_string = "leers at"
		action_phrase = "leer at"
		inaction_phrase = list("out of sight" = 1, "not in sight" = 99)
	boggle
		no_out_of_range = TRUE
		target_type = "both"
		action_phrase = "boggle at"
		emote_string = "boggles at the stupidity of" //slight rewording so I don't have to add a var after the mob here too
		emote_onself = "boggles at the stupidity of it all"

/datum/emote/targeted/enact(mob/living/user, voluntary = 0, param)
	if (!istype(user)) //get_targets is on mob/living
		return
	var/M = null
	if (param)
		for (var/mob/A in view(null, null))
			if (ckey(param) == ckey(A.name))
				M = A
				break
	var/list/target_list = user.get_targets(range, target_type)
	if(length(target_list))
		M = input(user, "Pick something to [emote_string]!", "EmotiConsole v1.1.3", "CANCEL") in (target_list + "CANCEL")
		if (M == "CANCEL")
			M = null // lame but im de-TGUIing on a budget. Warc
		if (!no_out_of_range && M && !IN_RANGE(get_turf(user), get_turf(M), range))
			boutput(user, "<span class='emote'><B>[M]</B> is [inaction_phrase]!</span>")
			return

	if (M)
		return list("<B>[user]</B> [emote_string] [M].", "<I>[emote_string] [M]</I>", MESSAGE_VISIBLE)
	return list("<B>[user]</B> [emote_onself].", "<I>[emote_onself]</I>", MESSAGE_VISIBLE)



///Restrainable emotes that target a mob, kind of a bastard
/datum/emote/visible_restrain/targeted
	var/range = 5
	var/no_out_of_range = FALSE // You can totally actively passively aggressively flip people off after they leave the room

	///used when the target moves out of range
	var/inaction_phrase = "emote upon"	//Can be a weighted list
	///used in the popup where you pick your target
	var/action_phrase = "emote upon" //idem, don't ask me why the unimportant strings sometimes have weights but the actual emote output doesn't (and I'm not coding that)
	///This emote can target yourself (if nobody's around)
	var/emote_onself = FALSE

	var/emote_onself_trailing = null //fuck you fingerguns

	emote_fail = "struggles to move"

	//So previously I coded up this group of emotes into using an abomination of a return statement, because everything's output differed very slightly in 5 ways. It was horrible
	//But here's a few custom procs instead
	proc/on_other(mob/user, target)
		return "OH FUCK THIS EMOTE ISN'T CODED PROPERLY"

	proc/on_self(mob/user)
		return "OH FUCK THIS EMOTE ISN'T CODED PROPERLY"

	proc/maptext_on_other(mob/user, target)
		return "OH FUCK THIS EMOTE ISN'T CODED PROPERLY"

	proc/maptext_on_self(mob/user)
		return "OH FUCK THIS EMOTE ISN'T CODED PROPERLY"

	saluteto
		action_phrase = "salute"
		inaction_phrase = "saluting"

		on_other(mob/user, target)
			return "<B>[user]</B> salutes [target]."

		maptext_on_other(mob/user, target)
			return "<I>salutes [target]</I>"

	waveto
		action_phrase = "wave"
		inaction_phrase = "waving"

		on_other(mob/user, target)
			if(istype(target,/obj/machinery/bot/guardbot))
				var/obj/machinery/bot/guardbot/GB = target
				if(user != GB.arrest_target && prob(66))
					SPAWN_DBG(1 SECOND)
						GB.visible_message("<b>[GB]</b> waves back at [user.name].")
						GB.set_emotion("happy")
			return "<B>[user]</B> waves to [target]."

		maptext_on_other(mob/user, target)
			return "<I>waves to [target]</I>"

	bow
		action_phrase = "bow before"
		inaction_phrase = list("bowing" = 99, "prostration" = 1) //IDK why the error message of all things is weighted on this one

		on_other(mob/user, target)
			return "<B>[user]</B> bows to [target]."

		maptext_on_other(mob/user, target)
			return "<I>bows to [target]</I>"

	blowkiss
		action_phrase = list("to whom you'll blow a kiss" = 99, "to whom you'll blow a smooch" = 1)
		inaction_phrase = list("kissing" = 99, "smooching" = 1)
		emote_onself = TRUE

		on_other(mob/user, target)
			if(istype(target,/obj/machinery/bot/guardbot))
				var/obj/machinery/bot/guardbot/GB = target
				if(user != GB.arrest_target)
					GB.set_emotion("love")
			return "<B>[user]</B> blows a kiss to [target]."

		maptext_on_other(mob/user, target)
			return "<I>blows a kiss to [target]</I>"

		on_self(mob/user)
			return "<B>[user]</B> blows a kiss to... [himself_or_herself(user)]?"

		maptext_on_self(mob/user)
			return "<I>blows a kiss to... [himself_or_herself(user)]</I>"

	hug
		range = 1
		action_phrase = "hug"
		inaction_phrase = "hugging"
		emote_onself = TRUE

		on_other(mob/user, target)
			if(istype(target,/obj/machinery/bot/guardbot))
				var/obj/machinery/bot/guardbot/GB = target
				if(user != GB.arrest_target)
					GB.set_emotion("love")
			return "<B>[user]</B> hugs [target]."

		maptext_on_other(mob/user, target)
			return "<I>hugs [target]</I>"

		on_self(mob/user)
			return "<B>[user]</B> hugs [himself_or_herself(user)]."

		maptext_on_self(mob/user)
			return "<I>hugs [himself_or_herself(user)]</I>"

	sidehug
		range = 1
		action_phrase = "sidehug"
		inaction_phrase = "sidehugging"
		emote_onself = TRUE //HOW

		on_other(mob/user, target)
			return "<B>[user]</B> awkwardly side-hugs [target]."

		maptext_on_other(mob/user, target)
			return "<I>awkwardly side-hugs [target]</I>"

		on_self(mob/user)
			return "<B>[user]</B> sidehugs [himself_or_herself(user)]." //inconsistent hyphenation is how the original did it and IDC :3

		maptext_on_self(mob/user)
			return "<I>sidehugs [himself_or_herself(user)]</I>"

	fingerguns
		action_phrase = "point finger guns at"
		inaction_phrase = "finger warfare" //fingerguns didn't have this but I had to
		emote_onself = TRUE

		on_other(mob/user, target)
			if(istype(target,/obj/machinery/bot/guardbot))
				var/obj/machinery/bot/guardbot/GB = target
				if(user != GB.arrest_target)
					SPAWN_DBG(1 SECOND)
						if(prob(50))
							GB.speak(pick("Ayyyyy...","Back at you! Well, I mean, if I could.","Heyyyy buddy!"))
						GB.set_emotion("cool")
			return "<B>[user]</B> points finger guns at [target]!"

		maptext_on_other(mob/user, target)
			return "<I>points finger guns at [target]!</I>"

		on_self(mob/user)
			return "<B>[user]</B> points finger guns at... [himself_or_herself(user)]?"

		maptext_on_self(mob/user)
			return "<I>points finger guns at... [himself_or_herself(user)]?</I>"

	fingerflip // The three middle finger emotes only differ in one inconsequental string :<
		no_out_of_range = TRUE
		emote_onself = TRUE
		emote_fail = null
		emote_fail_leading = "scowls and tries to move"
		emote_fail_trailing = "arm"
		pronoun_proc = /proc/his_or_her

		on_other(mob/user, target)
			if (istype(target,/obj/machinery/bot/secbot))
				var/obj/machinery/bot/secbot/SB = target
				SB.EngageTarget(user,0,0,1) //pig can't help itself
				user.add_karma(5)
			if(istype(target,/obj/machinery/bot/guardbot))
				var/obj/machinery/bot/guardbot/GB = target
				if(user != GB.arrest_target)
					if(user.has_medal("Stone Cold Cop Disliker") && GB.task)
						GB.task.attack_response(user)
						return "<B>[user]</B> flips off [target]!"
					SPAWN_DBG(1 SECOND)
						if(prob(50))
							GB.speak(pick("Hey... Come on...","Aw, what? Why?","What was that for?"))
						GB.set_emotion("sad")
						user.add_karma(-5)
						if(GB.last_hugged == user)
							user.unlock_medal("Stone Cold Cop Disliker",1) // todo:  atonement
							user.add_karma(-50)
							GB.speak(pick("Well that's a new low...","After all that? This is how it ends?","You? I thought we were friends..."))
							GB.last_hugged = null
				else
					GB.set_emotion("angry")
					user.add_karma(1)
			return "<B>[user]</B> flips off [target]!"

		maptext_on_other(mob/user, target)
			return "<I>flips off [target]!</I>"

		on_self(mob/user)
			user.add_karma(rand(-1,1))
			return "<B>[user]</B> raises [his_or_her(user)] middle finger."


		maptext_on_self(mob/user)
			return "<I>raises [his_or_her(user)]middle finger</I>"

		flipoff
			action_phrase = "flip off"
		flipbird
			action_phrase = "give the bird"
		middlefinger
			action_phrase = "raise your middle finger at"

	fingerflip2 // same deal, 2 fingers
		no_out_of_range = TRUE
		emote_string = "gives"
		emote_string_trailing = "the double deuce!"
		emote_onself = "raises both of"
		emote_onself_trailing = "middle fingers"
		emote_fail_leading = "scowls and tries to move"
		emote_fail_trailing = "arms"
		pronoun_proc = /proc/his_or_her

		on_other(mob/user, target)
			if (istype(target,/obj/machinery/bot/secbot))
				var/obj/machinery/bot/secbot/SB = target
				SB.EngageTarget(user,0,0,1) //pig can't help itself
			if(istype(target,/obj/machinery/bot/guardbot))
				//buddies won't arrest you for this but they will make you feel bad
				var/obj/machinery/bot/guardbot/GB = target
				if(user != GB.arrest_target)
					SPAWN_DBG(1 SECOND)
						if(prob(50))
							GB.speak(pick("Now that's just extra mean...","How could you?","Oh, to be so hated..."))
						GB.set_emotion("sad")
				else
					GB.set_emotion("angry")
			return "<B>[user]</B> gives [target] the double deuce!"

		maptext_on_other(mob/user, target)
			return "<I>gives [target] the double deuce!</I>"

		on_self(mob/user)
			return "<B>[user]</B> raises both of [his_or_her(user)] middle fingers."

		maptext_on_self(mob/user)
			return "<I>raises both of [himself_or_herself(user)]middle fingers</I>"

		doubleflip
			action_phrase = "blast the double-finger"
		doubledeuce
			action_phrase = "give the double deuce"
		doublebird
			action_phrase = "give both birds"
		flip2
			action_phrase = "flip off twice"

	dap // also daps
		range = 1
		action_phrase = "dap"
		inaction_phrase = "dapping"
		emote_fail = "wriggles around a bit"
		emote_onself = TRUE

		on_other(mob/user, target)
			if(istype(target,/obj/machinery/bot/guardbot))
				var/obj/machinery/bot/guardbot/GB = target
				if(user != GB.arrest_target)
					GB.set_emotion("cool")
			return "<B>[user]</B> gives daps [target]."

		maptext_on_other(mob/user, target)
			return "<I>gives daps to [target]</I>"

		on_self(mob/user)
			return "<B>[user]</B> sadly can't find anybody to give daps to, and daps [himself_or_herself(user)]. Shameful."

		maptext_on_self(mob/user)
			return "<I>shamefully gives daps to [himself_or_herself(user)]</I>"

	shakefist
		action_phrase = "shake your fist at"
		no_out_of_range = TRUE
		emote_string_leading = "angrily shakes"
		emote_string = "fist at"
		emote_onself = "angrily shakes"
		emote_onself_trailing = "fist!"
		emote_fail = null
		emote_fail_leading = "tries to move"
		emote_fail_trailing = "arm angrily!"

		pronoun_proc = /proc/his_or_her

		on_other(mob/user, target)
			if(istype(target,/obj/machinery/bot/guardbot))
				var/obj/machinery/bot/guardbot/GB = target
				if(user == GB.arrest_target)
					GB.set_emotion("smug")
				else
					GB.set_emotion("look")
			return "<B>[user]</B> angrily shakes [his_or_her(user)] fist at [target]!"

		maptext_on_other(mob/user, target)
			return "<I>angrily shakes [his_or_her(user)] fist at [target]!</I>"

		on_self(mob/user)
			return "<B><B>[user]</B> angrily shakes [his_or_her(user)] fist!"

		maptext_on_self(mob/user)
			return "<I>angrily shakes [his_or_her(user)] fist!</I>"

/datum/emote/visible_restrain/targeted/enact(mob/living/user, voluntary = 0, param)
	if (!istype(user)) //get_targets is on mob/living
		return
	if (user.restrained())
		return ..()
	var/M //What we'll be targeting
	if (param)
		for (var/atom/movable/A in view(range, user))
			if (ckey(param) == ckey(A.name))
				M = A
				break
	else //set up a cruddy list to pick from
		var/list/target_list = user.get_targets(range, "chumps")
		if(length(target_list))
			M = input(user, "Pick something to [islist(action_phrase) ? weighted_pick(action_phrase) : action_phrase]!", "EmotiConsole v1.1.3", "CANCEL") in (target_list + "CANCEL")
			if (M == "CANCEL")
				M = null // lame but im de-TGUIing on a budget. Warc
			if (!no_out_of_range && M && (range > 1 && !IN_RANGE(get_turf(user), get_turf(M), range)) || (range == 1 && !in_interact_range(user, M)) )
				boutput(user, "<span class='emote'><B>[M]</B> is not in [islist(inaction_phrase) ? weighted_pick(inaction_phrase) : inaction_phrase] distance!</span>")
				return
	if (!M) //emote on self
		if (!emote_onself)
			return

		return list(on_self(user), maptext_on_self(user), MESSAGE_VISIBLE)
		//I deleted the explanation for it but look at this mess
		//return list("<B>[user]</B> [emote_onself] [call(pronoun_proc)(user)] [!isnull(emote_onself_trailing) ? emote_onself_trailing : ""][(emote_onself_trailing[length(emote_onself_trailing)] != "!" || emote_onself_trailing[length(emote_onself_trailing)] != "?") ? "." : ""]", "<I>[emote_onself] [call(pronoun_proc)(user)] [!isnull(emote_onself_trailing) ? emote_onself_trailing : ""]</I>", MESSAGE_VISIBLE)
	return list(on_other(user,M), maptext_on_other(user,M), MESSAGE_VISIBLE)
	//lol, lmao
	//return list("<B>[user]</B> [!isnull(emote_string_leading) ? "[emote_string_leading] [call(pronoun_proc)(user)] " : ""][emote_string] [M] [!isnull(emote_string_trailing) ? emote_string_trailing : ""][(emote_string_trailing[length(emote_string_trailing)] != "!" || emote_string_trailing[length(emote_string_trailing)] != "?") ? "." : ""]", "<I>[!isnull(emote_string_leading) ? "[emote_string_leading] [call(pronoun_proc)(user)] " : ""][emote_string] [M] [!isnull(emote_string_trailing) ? emote_string_trailing : ""]</I>", MESSAGE_VISIBLE)


//These I couldn't shoehorn into the abomination above

//does arm checks
/datum/emote/targeted/handshake // also shakehand, shakehands
/datum/emote/targeted/handshake/enact(mob/living/user, voluntary = 0, param)
	if (!user.restrained() && !user.r_hand || !istype(user))
		var/mob/M = null
		if (param)
			for (var/mob/A in view(1, null))
				if (ckey(param) == ckey(A.name))
					M = A
					break
		if (M == user)
			M = null
		if(!M)
			var/list/target_list = user.get_targets(1, "chumps") // Bobby Boblord shakes hands with grody spacemouse!
			if(length(target_list))
				M = input(user, "Pick someone with whom to shake hands!", "EmotiConsole v1.1.3", "CANCEL") in (target_list + "CANCEL")
				if (M == "CANCEL")
					M = null // lame but im de-TGUIing on a budget. Warc
				if (M && !in_interact_range(user, M))
					boutput(user, "<span class='emote'><B>[M]</B> is out of reach!</span>")
					return

		if (M)
			if (M.canmove && !M.r_hand && !M.restrained())
				return list("<B>[user]</B> shakes hands with [M].", "<I>shakes hands with [M]</I>", MESSAGE_VISIBLE)
			else
				return list("<B>[user]</B> holds out [his_or_her(user)] hand to [M].", "<I>holds out [his_or_her(user)] hand to [M]</I>", MESSAGE_VISIBLE)


//makes sounds and stuff
/datum/emote/targeted/slap // also smack
/datum/emote/targeted/slap/enact(mob/living/user, voluntary = 0, param)
	if (!istype(user)) //get_targets is on mob/living
		return
	if (!user.restrained())
		if (user.bioHolder.HasEffect("chime_snaps"))
			user.sound_snap = 'sound/impact_sounds/Glass_Shards_Hit_1.ogg'
		var/M = null
		if (param)
			for (var/mob/A in view(1, null))
				if (ckey(param) == ckey(A.name))
					M = A
					break
		else
			var/list/target_list = user.get_targets(1, "chumps") // Funche Arnchlnm slaps shambling abomination across the face!
			if(length(target_list))
				M = input(user, "Pick someone to smack!", "EmotiConsole v1.1.3", "CANCEL") in (target_list + "CANCEL")
				if (M == "CANCEL")
					M = null // lame but im de-TGUIing on a budget. Warc
				if (M && !in_interact_range(user, M))
					boutput(user, "<span class='emote'><B>[M]</B> is out of reach!</span>")
					return
		playsound(user.loc, user.sound_snap, 100, 1, channel=VOLUME_CHANNEL_EMOTE)
		if (M)
			return list("<B>[user]</B> slaps [M] across the face! Ouch!", "<I>slaps [M] across the face!</I>", MESSAGE_VISIBLE)
		else
			user.TakeDamage("head", 0, 4, 0, DAMAGE_BURN)
			return list("<B>[user]</B> slaps [himself_or_herself(user)]!", "<I>slaps [himself_or_herself(user)]!</I>", MESSAGE_VISIBLE)
	else
		return list("<B>[user]</B> lurches forward strangely and aggressively!", "<I>lurches forward strangely and aggressively!</I>", MESSAGE_VISIBLE)


/datum/emote/targeted/highfive
/datum/emote/targeted/highfive/enact(mob/living/user, voluntary = 0, param)
	if (!istype(user)) //get_targets is on mob/living
		return
	if (!user.restrained() && user.stat != 1 && !isunconscious(user) && !isdead(user))
		var/mob/M = null
		if (param)
			for (var/mob/A in view(1, null))
				if (ckey(param) == ckey(A.name))
					M = A
					break
			#ifdef TWITCH_BOT_ALLOWED
			if (IS_TWITCH_CONTROLLED(M))
				return
			#endif
		else
			var/list/target_list = user.get_targets(1, "chumps") // Chrunb Erbrbt and Scales To Lizard highfive!
			if(length(target_list))
				M = input(user, "Pick someone to high-five!", "EmotiConsole v1.1.3", "CANCEL") in (target_list + "CANCEL")
				if (M == "CANCEL")
					M = null // lame but im de-TGUIing on a budget. Warc
				if (M && !in_interact_range(user, M))
					boutput(user, "<span class='emote'><B>[M]</B> is out of reach!</span>")
					return

		if (M)
			if (!M.restrained() && M.stat != 1 && !isunconscious(M) && !isdead(M))
				if (alert(M, "[user] offers you a highfive! Do you accept it?", "Choice", "Yes", "No") == "Yes")
					if (M in view(1,null))
						playsound(user.loc, user.sound_snap, 100, 1, channel=VOLUME_CHANNEL_EMOTE)
						return list("<B>[user]</B> and [M] highfive!", "<I>highfives [M]!</I>", MESSAGE_VISIBLE)

				else
					if (M.mind)
						user.add_karma(-5)
					return list("<B>[user]</B> offers [M] a highfive, but [M] leaves [him_or_her(user)] hanging!", "<I>tries to highfive [M] but is left hanging!</I>", MESSAGE_VISIBLE)

			else
				playsound(user.loc, user.sound_snap, 100, 1, channel=VOLUME_CHANNEL_EMOTE)
				return list("<B>[user]</B> highfives [M]!", "<I>highfives [M]!</I>", MESSAGE_VISIBLE)

		else
			return list("<B>[user]</B> randomly raises [his_or_her(user)] hand!", "<I>randomly raises [his_or_her(user)] hand!</I>", MESSAGE_VISIBLE)
