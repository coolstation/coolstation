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
	var/target_type = "mob"
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
		M = tgui_input_list(user, "Pick something to [emote_string]!", "EmotiConsole v1.1.3", target_list, (20 SECONDS))
		if (!no_out_of_range && M && !IN_RANGE(get_turf(user), get_turf(M), range))
			boutput(user, "<span class='emote'><B>[M]</B> is [inaction_phrase]!</span>")
			return

	if (M)
		return list("<B>[user]</B> [emote_string] [M].", "<I>[emote_string] [M]</I>", MESSAGE_VISIBLE)
	return list("<B>[user]</B> [emote_onself].", "<I>[emote_onself]</I>", MESSAGE_VISIBLE)



///Restrainable emotes that target a mob, kind of a bastard in terms of inheritance
/datum/emote/visible_restrain/targeted
	var/range = 5
	var/no_out_of_range = FALSE // You can totally actively passively aggressively flip people off after they leave the room

	//N.B. these emotes have a bit of a complicated relation to emote_string_leading and emote_string_trailing
	//

	//used when the target moves out of range: boutput(user, "[target] is [inaction_phrase]!")
	var/inaction_phrase	//Can be a weighted list
	var/action_phrase //idem, don't ask me why the unimportant strings sometimes have weights but the actual emote output doesn't (and I'm not coding that)
	var/emote_onself = null
	var/emote_onself_trailing = null //fuck you fingerguns
	pronoun_proc = /proc/himself_or_herself

	emote_fail = "struggles to move"

	saluteto
		action_phrase = "salute"
		inaction_phrase = "saluting"
		emote_string = "salutes"
	waveto
		action_phrase = "wave"
		inaction_phrase = "waving"
		emote_string = "waves to"
	bow
		action_phrase = list("bow" = 99, "prostrate" = 1)
		inaction_phrase = list("bowing" = 99, "prostration" = 1)
		emote_string = "bows to"
	blowkiss
		action_phrase = list("to whom you'll blow a kiss" = 99, "to whom you'll blow a smooch" = 1)
		inaction_phrase = list("kissing" = 99, "smooching" = 1)
		emote_string = "blows a kiss to"
		emote_onself = "blows a kiss to..."
		emote_onself_trailing = "?"
	hug
		range = 1
		action_phrase = "hug"
		inaction_phrase = "hugging"
		emote_string = "hugs"
		emote_onself = "hugs"
	sidehug
		range = 1
		action_phrase = "sidehug"
		inaction_phrase = "sidehugging"
		emote_string = "awkwardly side-hugs"
		emote_onself = "sidehugs" //HOW
	fingerguns
		action_phrase = "point finger guns at"
		inaction_phrase = "finger warfare" //fun fact fingerguns didn't have this
		emote_string = "points finger guns at"
		emote_string_trailing = "!"
		emote_onself = "points finger guns at..."
		emote_onself_trailing = "?"
	fingerflip // The three middle finger emotes only differ in one inconsequental string :<
		no_out_of_range = TRUE
		emote_string = "flips off"
		emote_string_trailing = "!" //previously only the maptext had the exclamation mark
		emote_onself = "raises"
		emote_onself_trailing = "middle finger"
		emote_fail_leading = "scowls and tries to move"
		emote_fail_trailing = "arm"
		pronoun_proc = /proc/his_or_her

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
		emote_string = "gives daps to"
		emote_fail = "wriggles around a bit"
		emote_onself = "shamefully gives daps to"
		//Outputs used to differ massively, but I don't give  a shit:
		//message = "<B>[user]</B> sadly can't find anybody to give daps to, and daps [himself_or_herself(user)]. Shameful."
		//maptext_out = "<I>shamefully gives daps to [himself_or_herself(user)]</I>"
	shakefist
		action_phrase = "shake your fist at"
		no_out_of_range = TRUE
		emote_string_leading = "angrily shakes"
		emote_string = "fist at"
		emote_onself = "angrily shakes"
		emote_onself_trailing = "fist!"
		emote_fail = null
		emote_fail_leading = "tries to move"
		emote_fail_trailing = "arm angrily"

		pronoun_proc = /proc/his_or_her

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
		var/list/target_list = user.get_targets(range, "mob")
		if(length(target_list))
			M = tgui_input_list(user, "Pick something to [islist(action_phrase) ? weighted_pick(action_phrase) : action_phrase]!", "EmotiConsole v1.1.3", target_list, (20 SECONDS)) //why 20 seconds?
			if (!no_out_of_range && M && (range > 1 && !IN_RANGE(get_turf(user), get_turf(M), range)) || (range == 1 && !in_interact_range(user, M)) )
				boutput(user, "<span class='emote'><B>[M]</B> is not in [islist(inaction_phrase) ? weighted_pick(inaction_phrase) : inaction_phrase] distance!</span>")
				return
	if (!M) //emote on self
		if (isnull(emote_onself))
			return
		//The hubris of liking descriptive variable names
		/*
			Since these returns have taken on regex levels of unreadable fuckassery
			first argument
				<B>[user]</B> [emote_onself] [call(pronoun_proc)(user)]																							// emoting mob emotes at self
				[!isnull(emote_onself_trailing) ? emote_onself_trailing : ""] 																					// add trailing bit (see middle finger emotes) if it exists
				[(emote_onself_trailing[length(emote_onself_trailing)] != "!" || emote_onself_trailing[length(emote_onself_trailing)] != "?") ? "." : ""]	// if the trailing bit does not end in an exclamation or question mark, add a period
			second argument
				[emote_onself] [call(pronoun_proc)(user)]									// emoting mob emotes at self (but leaving out mob's name)
				[!isnull(emote_onself_trailing) ? emote_onself_trailing : ""] 				// add trailing bit (see middle finger emotes) if it exists

			For what it's worth I'm cackling while writing this - Bat
		*/
		return list("<B>[user]</B> [emote_onself] [call(pronoun_proc)(user)] [!isnull(emote_onself_trailing) ? emote_onself_trailing : ""][(emote_onself_trailing[length(emote_onself_trailing)] != "!" || emote_onself_trailing[length(emote_onself_trailing)] != "?") ? "." : ""]", "<I>[emote_onself] [call(pronoun_proc)(user)] [!isnull(emote_onself_trailing) ? emote_onself_trailing : ""]</I>", MESSAGE_VISIBLE)
	//The construction here is similar, except we emote at [M] and everything is in terms of emote_string rather than emote_onself
	//BUT ALSO NOW: if emote_string_leading is not null then [emote_string_leading + pronoun proc] gets interjected SPECIFICALLY to support shakefist.
	//I am so, so tired of all these doing slightly different things. daps can still fuck off
	return list("<B>[user]</B> [!isnull(emote_string_leading) ? "[emote_string_leading] [call(pronoun_proc)(user)] " : ""][emote_string] [M] [!isnull(emote_string_trailing) ? emote_string_trailing : ""][(emote_string_trailing[length(emote_string_trailing)] != "!" || emote_string_trailing[length(emote_string_trailing)] != "?") ? "." : ""]", "<I>[!isnull(emote_string_leading) ? "[emote_string_leading] [call(pronoun_proc)(user)] " : ""][emote_string] [M] [!isnull(emote_string_trailing) ? emote_string_trailing : ""]</I>", MESSAGE_VISIBLE)


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
			var/list/target_list = user.get_targets(1, "mob") // Bobby Boblord shakes hands with grody spacemouse!
			if(length(target_list))
				M = tgui_input_list(user, "Pick someone with whom to shake hands!", "EmotiConsole v1.1.3", target_list, (20 SECONDS))
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
			var/list/target_list = user.get_targets(1, "mob") // Funche Arnchlnm slaps shambling abomination across the face!
			if(length(target_list))
				M = tgui_input_list(user, "Pick someone to smack!", "EmotiConsole v1.1.3", target_list, (20 SECONDS))
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
			var/list/target_list = user.get_targets(1, "mob") // Chrunb Erbrbt and Scales To Lizard highfive!
			if(length(target_list))
				M = tgui_input_list(user, "Pick someone to high-five!", "EmotiConsole v1.1.3", target_list, (20 SECONDS))
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
