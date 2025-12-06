//Emotes adapted from all the mutantrace overrides
//Some of these (well, the versions that used to be on /datum/mutantrace/proc/emote) are probably quite old, but a lot are very rudimentary in any case.
//It would be nice if say, the screams were brought more in line with what the parent scream emote is like.


// ------------------------------ up first, all the screams --------------------------------

/datum/emote/scream/grey/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user))
		return
	playsound(user, "sound/voice/screams/Psychic_Scream_1.ogg", 80, 0, 0, max(0.7, min(1.2, 1.0 + (30 - user.bioHolder.age)/60)), channel=VOLUME_CHANNEL_EMOTE)
	return list("<B>[user]</B> screams with [his_or_her(user)] mind! Guh, that's creepy!", null, MESSAGE_AUDIBLE)

//also used by vampiric thralls
/datum/emote/scream/zombie/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user))
		return
	playsound(user, "sound/voice/Zgroan[pick("1","2","3","4")].ogg", 80, 0, 0, max(0.7, min(1.2, 1.0 + (30 - user.bioHolder.age)/60)), channel=VOLUME_CHANNEL_EMOTE)
	return list("<B>[user]</B> moans!", null, MESSAGE_AUDIBLE)

/datum/emote/scream/abomination/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user))
		return
	playsound(user, "sound/voice/creepyshriek.ogg", 60, 1, channel=VOLUME_CHANNEL_EMOTE)
	return list("<span class='alert'><B>[user] screeches!</B></span>", null, MESSAGE_AUDIBLE)

/datum/emote/scream/werewolf/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user))
		return
	playsound(user, "sound/voice/animal/werewolf_howl.ogg", 65, 0, 0, max(0.7, min(1.2, 1.0 + (30 - user.bioHolder.age)/60)), channel=VOLUME_CHANNEL_EMOTE)
	return list("<span class='alert'><B>[user] howls [pick("ominously", "eerily", "hauntingly", "proudly", "loudly")]!</B></span>", null, MESSAGE_AUDIBLE)

/datum/emote/scream/monkey/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user))
		return
	playsound(user, 'sound/voice/screams/monkey_scream.ogg', 80, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
	return list("<B>[user]</B> screams!", null, MESSAGE_AUDIBLE)

/datum/emote/scream/amphibian/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user))
		return
	playsound(user, pick("sound/voice/screams/frogscream1.ogg","sound/voice/screams/frogscream3.ogg","sound/voice/screams/frogscream4.ogg"), 60, 1, channel=VOLUME_CHANNEL_EMOTE)
	return list("<span class='alert'><B>[user] makes an awful noise!</B></span>", null, MESSAGE_AUDIBLE)

/datum/emote/scream/cow/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user))
		return
	playsound(user, "sound/voice/screams/moo.ogg", 50, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
	return list("<B>[user]</B> moos!", null, MESSAGE_AUDIBLE)

/datum/emote/scream/chicken/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user))
		return
	playsound(user, "sound/voice/screams/chicken_bawk.ogg", 50, 0, 0, user.get_age_pitch())
	return list("<B>[user]</B> BWAHCAWCKs!", null, MESSAGE_AUDIBLE)

/datum/emote/scream/fert/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user))
		return
	playsound(user, "sound/voice/screams/weaselscream.ogg", 50, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
	return list("<B>[user]</B> screams!", null, MESSAGE_AUDIBLE)

// ------------------------------ werewolf RP --------------------------------

/datum/emote/werewolf/burp/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user))
		return
	playsound(user, "sound/voice/burp_alien.ogg", 60, 1, channel=VOLUME_CHANNEL_EMOTE)
	return list("<B>[user]</B> belches.", null, MESSAGE_AUDIBLE)

/datum/emote/werewolf/uwu/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user))
		return
	playsound(user, "sound/voice/animal/werewolf_howl.ogg", 65, 0, 0, max(1.2, min(1.4, 1.2 + (30 - user.bioHolder.age)/60)), channel=VOLUME_CHANNEL_EMOTE) //need better sound for this
	return list("<span class='alert'><B>[user] uwus!</B></span>", "<I>[user] uwus!</I>", MESSAGE_AUDIBLE)

/datum/emote/werewolf/owo/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user))
		return
	playsound(user, "sound/voice/animal/werewolf_howl.ogg", 65, 0, 0, max(1.2, min(1.4, 1.2 + (30 - user.bioHolder.age)/60)), channel=VOLUME_CHANNEL_EMOTE) //need better sound for this
	return list("<span class='alert'><B>[user] owos!</B></span>", "<I>[user] owos!</I>", MESSAGE_AUDIBLE)

/datum/emote/werewolf/rawr/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user))
		return
	var/adjective = pick("proudly", "loudly")
	playsound(user, "sound/voice/animal/werewolf_howl.ogg", 65, 0, 0, max(1.2, min(1.4, 1.2 + (30 - user.bioHolder.age)/60)), channel=VOLUME_CHANNEL_EMOTE) //also need better sound
	return list("<span class='alert'><B>[user] rawrs [adjective]! xD</B></span>", "<I>[user] rawrs [adjective]!</I>", MESSAGE_AUDIBLE)

// ------------------------------ Monkeys --------------------------------

/datum/emote/visible_restrain
	scratch
		emote_string = "scratches"
		emote_fail = "shifts irately"

	stretch //was originally prevented by muzzling, but that doesn't make sense so it's here now.
		emote_string = "stretches"
		emote_fail = "strains"

	paw
		emote_string_leading = "flails"
		emote_string_trailing = "paw"
		emote_fail = "writhes!"
		pronoun_proc = /proc/his_or_her

	//The original tail emote can't fail, but simple emotes don't support pronoun procs
	//I hate many of the things I did when I datumised human emotes.
	tail
		emote_string_leading = "waves"
		emote_string_trailing = "tail"
		emote_fail_leading = "waves"
		emote_fail_trailing = "tail"
		pronoun_proc = /proc/his_or_her

	roll
		emote_string = "rolls"
		emote_fail = "wiggles"

/datum/emote/audible_restrain
	gnarl
		emote_string_leading = "gnarls and shows"
		emote_string_trailing = "teeth"
		emote_fail = "glares furiously"
		pronoun_proc = /proc/his_or_her

	roar
		emote_string = "roars"
		emote_fail = "makes a muffled noise"

/datum/emote/simple_visible
	jump
		emote_string = "jumps!"
	sulk2 //why though
		emote_string = "sulks down sadly"

/datum/emote/fart/bio/monkey/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if(!istype(user))
		return
	if(farting_allowed && (!user.reagents || !user.reagents.has_reagent("anti_fart")))
		var/fart_on_other = 0
		for(var/mob/living/M in user.loc)
			if(M == src || !M.lying)
				continue
			. = "<span class='alert'><B>[user]</B> farts in [M]'s face!</span>"
			if (M.mind && M.mind.assigned_role == "Clown")
				game_stats.Increment("clownabuse")
			fart_on_other = 1
			break
		if(!fart_on_other)
			switch(rand(1, 27))
				if(1) . = "<B>[user]</B> farts. It smells like... bananas. Huh."
				if(2) . = "<B>[user]</B> goes apeshit! Or at least smells like it."
				if(3) . = "<B>[user]</B> releases an unbelievably foul fart."
				if(4) . = "<B>[user]</B> chimpers out of its ass."
				if(5) . = "<B>[user]</B> farts and looks incredibly amused about it."
				if(6) . = "<B>[user]</B> unleashes the king kong of farts!"
				if(7) . = "<B>[user]</B> farts and does a silly little dance."
				if(8) . = "<B>[user]</B> farts gloriously."
				if(9) . = "<B>[user]</B> plays the song of its people. With farts."
				if(10) . = "<B>[user]</B> screeches loudly and wildly flails its arms in a poor attempt to conceal a fart."
				if(11) . = "<B>[user]</B> clenches and bares its teeth, but only manages a sad squeaky little fart."
				if(12) . = "<B>[user]</B> unleashes a chain of farts by beating its chest."
				if(13) . = "<B>[user]</B> farts so hard a bunch of fur flies off its ass."
				if(14) . = "<B>[user]</B> does an impression of a baboon by farting until its ass turns red."
				if(15) . = "<B>[user]</B> farts out a choking, hideous stench!"
				if(16) . = "<B>[user]</B> reflects on its captive life aboard a space station, before farting and bursting into hysterial laughter."
				if(17) . = "<B>[user]</B> farts megalomaniacally."
				if(18) . = "<B>[user]</B> rips a floor-rattling fart. Damn."
				if(19) . = "<B>[user]</B> farts. What a damn dirty ape!"
				if(20) . = "<B>[user]</B> farts. It smells like a nuclear engine. Not that you know what that smells like."
				if(21) . = "<B>[user]</B> performs a complex monkey divining ritual. By farting."
				if(22) . = "<B>[user]</B> farts out the smell of the jungle. The jungle smells gross as hell apparently."
				if(23) . = "<B>[user]</B> farts up a methane monsoon!"
				if(24) . = "<B>[user]</B> unleashes an utterly rancid stink from its ass."
				if(25) . = "<B>[user]</B> makes a big goofy grin and farts loudly."
				if(26) . = "<B>[user]</B> hovers off the ground for a moment using a powerful fart."
				if(27) . = "<B>[user]</B> plays drums on its ass while farting."
		playsound(user.loc, "sound/voice/farts/poo2.ogg", 80, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)

		user.remove_stamina(STAMINA_DEFAULT_FART_COST)
		user.stamina_stun()
		game_stats.Increment("farts")
		user.expel_fart_gas(0)
		user.add_karma(0.5)
		return list(., null, MESSAGE_AUDIBLE)

// ------------------------------ Amphibian frogges --------------------------------

/datum/emote/fart/amphibian
	cooldown = 1 SECOND
/datum/emote/fart/amphibian/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user))
		return
	playsound(user, pick("sound/voice/screams/frogscream1.ogg","sound/voice/screams/frogscream3.ogg","sound/voice/screams/frogscream4.ogg"), 60, 1, channel=VOLUME_CHANNEL_EMOTE)
	return list("<span class='alert'><B>[user] croaks.</B></span>", null, MESSAGE_AUDIBLE)

// ------------------------------ Cows --------------------------------

/datum/emote/cow/milk/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user))
		return
	var/datum/mutantrace/cow/M = user.mutantrace
	if (!istype(M))
		return
	M.release_milk()
	return list(null, null, null)

// ------------------------------ Ferrets --------------------------------

/datum/emote/fert/laugh/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user))
		return
	playsound(user, 'sound/misc/talk/fert.ogg', 40, 1, 0.3, channel=VOLUME_CHANNEL_EMOTE)
	return list("<span class='alert'><B>[user] dooks excitedly</B></span>", "<I>dooks excitedly</I>", MESSAGE_AUDIBLE)


/datum/emote/fert/dance/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user))
		return
	if (!voluntary)
		user.show_message("<span class='alert'>You CAN'T CONTROL YOURSELF AT ALL!!! YOU GOTTA [pick("WOBBLE","WIGGLE","WIG OUT","FREAK OUT","BOUNCE AROUND","GET WOOZED UP")]!!!</span>") //message to only yourself

	//do the actual dance:
	if (prob(20)) //starts off with a flip
		animate_spin(user, prob(50) ? "L" : "R", 1, 0)
	SPAWN_DBG(0) //commence the wiggling
		var/x = rand(5,10)
		while (x-- > 0)
			if (user)
				user.pixel_x = rand(-6,6)
				user.pixel_y = rand(-6,6)
				user.dir = pick(1,2,4,8)
				sleep(0.2 SECONDS)
				if (x == 0) //it's fine for the critters to be sloppy but not the player, get back to normal position at the end
					if (user) //sometimes explosions happen during a freakout and we don't want to animate a dead body
						user.pixel_x = 0
						user.pixel_y = 0
						if (prob((voluntary * 3) + 2)) //when done, also a chance to flop (5% if you did it, 2% if you were compelled)
							user.changeStatus("weakened", 3 SECONDS)
							user.visible_message("<span class='alert'><B>[user] gets exhausted from prancing about and falls over!</B></span>")
						else if (prob(20)) //but... maybe just one more flip, for the road
							animate_spin(user, prob(50) ? "L" : "R", 1, 0)

	//chance to excite (big and small) ferts who can see you:
	if(resonance_fertscade || voluntary) //unless A Really Bad Idea is enabled, the chain is one
		if (!user.client)
			return list("<B>[user]</B> [pick("wigs out","frolics","rolls about","freaks out","goes wild","wiggles","wobbles","weasel-wardances")]!", null, MESSAGE_VISIBLE) //npcs don't cause other freakouts
		sleep(0.2 SECONDS) //so they don't start fuckin' dancing before you do
		for (var/mob/M in viewers(user))
			if (M != user && isfert(M) && M.client) //get other big (player) ferrets to join in
				if (prob(25) && M.emote_allowed) //test this with the slower and more reliable cooldown
					for (var/mob/V in viewers(M)) //secondary viewers watching this trainwreck unfold
						if (V == M || !V.client) //affected players and npcs don't need to see this message
							continue
						V.show_message("<span class='notice'>[M] joins [user] in these [pick("fuckin'","absolutely","totally","")] [pick("weaselly","toobular","dooked-up","slinky","stinky")] [pick("shenanigans","hijinks","carryings-on","behaviors","wiggles","wobbles")].</span>", 1)
						M.emote("dance", 0) //involuntary
			if (istype(M, /mob/living/critter/small_animal/meatslinky)) //small ferrets (mobs only)
				var/mob/living/critter/small_animal/meatslinky/frrt = M
				frrt.contagiousfreakout(1) //the ferret's freakout proc handles the ferret's emotional state and probability
		for (var/obj/O in viewers(user))
			if (istype(O, /obj/critter/meatslinky)) //small ferrets (critter...)
				var/obj/critter/meatslinky/toob = O
				toob.contagiousfreakout(1) //just a response, cannot force further freakouts
	return list("<B>[user]</B> [pick("wigs out","frolics","rolls about","freaks out","goes wild","wiggles","wobbles","weasel-wardances")]!", null, MESSAGE_VISIBLE)
