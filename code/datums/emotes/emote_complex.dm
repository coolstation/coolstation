//TBH this is just anything that does significantly weird stuff, some of it's fairly simple

//april fools start

/datum/emote/inhale
/datum/emote/inhale/enact(mob/living/user, voluntary = 0, param)
	if (!istype(user))
		return
	if (!manualbreathing)
		user.show_text("You are already breathing!")
		return

	var/datum/lifeprocess/breath/B = user.lifeprocesses?[/datum/lifeprocess/breath]
	if (B)
		if (B.breathstate)
			user.show_text("You just breathed in, try breathing out next dummy!")
			return
		B.breathtimer = 0
		B.breathstate = 1

	user.show_text("You breathe in.")

/datum/emote/exhale
/datum/emote/exhale/enact(mob/living/user, voluntary = 0, param)
	if (!istype(user))
		return
	if (!manualbreathing)
		user.show_text("You are already breathing!")
		return

	var/datum/lifeprocess/breath/B = user.lifeprocesses?[/datum/lifeprocess/breath]
	if (B)
		if (!B.breathstate)
			user.show_text("You just breathed out, try breathing in next silly!")
			return
		B.breathstate = 0

	user.show_text("You breathe out.")

/datum/emote/closeeyes
/datum/emote/closeeyes/enact(mob/living/user, voluntary = 0, param)
	if (!istype(user))
		return
	if (!manualblinking)
		user.show_text("Why would you want to do that?")
		return

	var/datum/lifeprocess/statusupdate/S = user.lifeprocesses?[/datum/lifeprocess/statusupdate]
	if (S)
		if (S.blinkstate)
			user.show_text("You just closed your eyes, try opening them now dumbo!")
			return
		S.blinkstate = 1
		S.blinktimer = 0

	user.show_text("You close your eyes.")

/datum/emote/openeyes
/datum/emote/openeyes/enact(mob/living/user, voluntary = 0, param)
	if (!istype(user))
		return
	if (!manualblinking)
		user.show_text("Your eyes are already open!")
		return

	var/datum/lifeprocess/statusupdate/S = user.lifeprocesses?[/datum/lifeprocess/statusupdate]
	if (S)
		if (!S.blinkstate)
			user.show_text("Your eyes are already open, try closing them next moron!")
			return
		S.blinkstate = 0

	user.show_text("You open your eyes.")

	//april fools end


/datum/emote/birdwell/bio //the stinky version humans have
/datum/emote/birdwell/bio/enact(mob/user, voluntary = 0, param)
	if ((user.client && user.client.holder))
		playsound(user.loc, 'sound/hlvox/birdwell.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
		return list("<B>[user]</B> birdwells.", "<I>birdwells</I>", MESSAGE_AUDIBLE)
	else
		return

/datum/emote/uguu
/datum/emote/uguu/enact(mob/user, voluntary = 0, param)
	if (istype(user.wear_mask, /obj/item/clothing/mask/anime) && !user.stat)
		if (narrator_mode)
			playsound(user, 'sound/vox/uguu.ogg', 80, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
		else
			playsound(user, 'sound/voice/uguu.ogg', 80, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
		SPAWN_DBG(1 SECOND)
			user.wear_mask.set_loc(user.loc)
			user.wear_mask = null
			logTheThing("combat", user, null, "was gibbed by emoting uguu at [log_loc(user)].")
			user.gib()
		return list("<B>[user]</B> uguus!", "<I>uguus</I>", MESSAGE_AUDIBLE)
	else
		user.show_text("You just don't feel kawaii enough to uguu right now!", "red")
		return

/datum/emote/juggle
	cooldown = 2.5 SECONDS
/datum/emote/juggle/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user)) //juggling is a list on humans
		return
	if (user.restrained())
		return list("<B>[user]</B> wiggles [his_or_her(user)] fingers a bit.[prob(10) ? " Weird." : null]", "<I>wiggles [his_or_her(user)] fingers a bit.</I>", MESSAGE_VISIBLE)
	if ((user.mind && user.mind.assigned_role == "Clown") || user.can_juggle)
		var/obj/item/thing = user.equipped()
		if (!thing)
			if (user.l_hand)
				thing = user.l_hand
			else if (user.r_hand)
				thing = user.r_hand
		if (thing)
			if (user.juggling())
				if (prob(user.juggling.len * 5)) // might drop stuff while already juggling things
					user.drop_juggle()
				else
					user.add_juggle(thing)

/datum/emote/twirl //also spin
	cooldown = 2.5 SECONDS
/datum/emote/twirl/enact(mob/user, voluntary = 0, param)
	if (user.restrained())
		return list("<B>[user]</B> struggles to move.", "<I>struggles to move</I>", MESSAGE_VISIBLE)
	var/obj/item/thing = user.equipped()
	if (!thing)
		if (user.l_hand)
			thing = user.l_hand
		else if (user.r_hand)
			thing = user.r_hand
	if (thing)
		animate_spin(thing, prob(50) ? "L" : "R", 1, 0)
		/*
		var/trans = thing.transform
		animate(thing, transform = turn(trans, 120), time = 0.7, loop = 3, flags = ANIMATION_PARALLEL)
		animate(transform = turn(trans, 240), time = 0.7, flags = ANIMATION_PARALLEL)
		animate(transform = trans, time = 0.7, flags = ANIMATION_PARALLEL)*/
		SEND_SIGNAL(thing, COMSIG_ITEM_TWIRLED, src, thing)
		return list(thing.on_spin_emote(user), "<I>twirls [thing]</I>", MESSAGE_VISIBLE)
	else
		return list("<B>[user]</B> wiggles [his_or_her(user)] fingers a bit.[prob(10) ? " Weird." : null]", "<I>wiggles [his_or_her(user)] fingers a bit</I>", MESSAGE_VISIBLE)

/datum/emote/raisehand
	cooldown = 2.5 SECONDS
/datum/emote/raisehand/enact(mob/user, voluntary = 0, param)
	if(user.restrained())
		return list("<B>[user]</B> struggles to move.", "<I>struggles to move</I>", MESSAGE_VISIBLE)
	var/obj/item/object = user.equipped()
	if (object)
		return list(object.on_raise_emote(user), "<I>raises [object]</I>", MESSAGE_VISIBLE)
	else
		return list("<B>[user]</B> raises [his_or_her(user)] hand.", "<I>raises [his_or_her(user)] hand</I>", MESSAGE_VISIBLE)

/datum/emote/nudge
/datum/emote/nudge/enact(mob/user, voluntary = 0, param)
	if(!user.restrained())
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.glasses && istype(H.glasses, /obj/item/clothing/glasses/regular))
				var/obj/item/clothing/glasses/G = H.glasses
				if(G.isNudged != TRUE)
					G.attack_self(user)
					if(user.mind && !user.mind.alreadyNudged)
						elecflash(user)
						user.mind.alreadyNudged = TRUE
					user.update_clothing()
					return list("<B>[user]</B> nudges [his_or_her(user)] glasses up [his_or_her(user)] nose", MESSAGE_VISIBLE)
				else
					G.attack_self(user)
					user.update_clothing()
					return list("<B>[user]</B> pushes [his_or_her(user)] glasses back down [his_or_her(user)] nose", MESSAGE_VISIBLE)

/datum/emote/tip
/datum/emote/tip/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (user.restrained() || user.stat || !istype(user))
		return
	if (istype(user.head, /obj/item/clothing/head/mj_hat || /obj/item/clothing/head/det_hat/))
		user.say (pick("M'lady", "M'lord", "M'liege")) //male, female and non-binary variants with alliteration
	if (istype(user.head, /obj/item/clothing/head/fedora))
		user.visible_message("[user] tips [his_or_her(user)] fedora and smirks.")
		user.say ("M'lady")
		SPAWN_DBG(1 SECOND)
			user.add_karma(-10)
			logTheThing("combat", user, null, "was gibbed by emoting fedora tipping at [log_loc(user)].")
			user.gib()

/datum/emote/hatstomp // also stomphat
/datum/emote/hatstomp/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user))
		return
	if (user.restrained())
		return list("<B>[user]</B> tries to move [his_or_her(user)] arm and grumbles.", null, MESSAGE_VISIBLE)
	var/obj/item/clothing/head/hos_hat/hat = user.find_type_in_hand(/obj/item/clothing/head/hos_hat)
	var/message = null
	var/hat_or_beret = null
	var/already_stomped = null // store the picked phrase in here
	var/on_head = 0

	if (!hat) // if the find_type_in_hand() returned 0 earlier
		if (istype(user.head, /obj/item/clothing/head/hos_hat)) // maybe it's on our head?
			hat = user.head
			on_head = 1
		else // if not then never mind
			return
	if (hat.icon_state == "hosberet" || hat.icon_state == "hosberet-smash") // does it have one of the beret icons?
		hat_or_beret = "beret" // call it a beret
	else // otherwise?
		hat_or_beret = "hat" // call it a hat. this should cover cases where the hat somehow doesn't have either hosberet or hoscap
	if (hat.icon_state == "hosberet-smash" || hat.icon_state == "hoscap-smash") // has it been smashed already?
		already_stomped = pick(" That [hat_or_beret] has seen better days.", " That [hat_or_beret] is looking pretty shabby.", " How much more abuse can that [hat_or_beret] take?", " It looks kinda ripped up now.") // then add some extra flavor text

	// the actual messages are generated here
	if (on_head)
		message = "<B>[user]</B> yanks [his_or_her(user)] [hat_or_beret] off [his_or_her(user)] head, throws it on the floor and stomps on it![already_stomped]\
		<br><B>[user]</B> grumbles, \"<i>rasmn frasmn grmmn[prob(1) ? " dick dastardly" : null]</i>.\""
	else
		message = "<B>[user]</B> throws [his_or_her(user)] [hat_or_beret] on the floor and stomps on it![already_stomped]\
		<br><B>[user]</B> grumbles, \"<i>rasmn frasmn grmmn</i>.\""

	user.drop_from_slot(hat) // we're done here, drop that hat!
	hat.pixel_x = 0
	hat.pixel_y = -16

	SPAWN_DBG(0.5 SECONDS)
		if (hat_or_beret == "beret")
			hat.icon_state="hosberet-smash"
		else
			hat.icon_state="hoscap-smash"
	if(user.mind && user.mind.assigned_role != "Head of Security")
		user.add_karma(5)
	return list(message, "<I>stomps on [his_or_her(user)] hat!</I>", MESSAGE_VISIBLE)

/datum/emote/bubble //currently unused because bubblegum is unused
	cooldown = 2.5 SECONDS
/datum/emote/bubble/enact(mob/user, voluntary = 0, param)
	var/obj/item/clothing/mask/bubblegum/gum = user.wear_mask
	if (!istype(gum))
		return
	if (!ismuzzled(user))
		//todo: sound
		//todo: gum icon animation?
		if (gum.reagents && gum.reagents.total_volume)
			gum.reagents.reaction(get_turf(user), TOUCH, gum.chew_size)
		return list(message = "<B>[user]</B> blows a bubble.", "<I>blows a bubble</I>", MESSAGE_AUDIBLE)
	else //Hey Haine, when exactly does this happen? Is there bubblegum that also acts as a muzzle?
		return list(message = "<B>[user]</B> tries to make a noise.", "<I>tries to make a noise</I>", MESSAGE_AUDIBLE)



/datum/emote/give
	cooldown = 5 SECONDS
/datum/emote/give/enact(mob/living/user, voluntary = 0, param)
	if (user.restrained() || !istype(user)) //give_to
		return
	var/obj/item/thing = user.equipped()
	if (!thing)
		if (user.l_hand)
			thing = user.l_hand
		else if (user.r_hand)
			thing = user.r_hand

	if (thing)
		var/mob/living/carbon/human/H = null
		if (param)
			for (var/mob/living/carbon/human/M in view(1, user))
				if (ckey(param) == ckey(M.name) && can_act(M, TRUE))
					H = M
					break
		else
			var/list/possible_recipients = list()
			for (var/mob/living/carbon/human/M in view(1, user))
				if (M != user && can_act(M, TRUE))
					possible_recipients += M
			if (possible_recipients.len > 1)
				H = input(user, "Who would you like to hand your [thing] to?", "Choice") as null|anything in possible_recipients
			else if (possible_recipients.len == 1)
				H = possible_recipients[1]

		#ifdef TWITCH_BOT_ALLOWED
		if (IS_TWITCH_CONTROLLED(H))
			return
		#endif
		user.give_to(H)
		return list("<I>offers to [H]...</I>", null, MESSAGE_VISIBLE)

/datum/emote/scream //Might not be ready for borgs, but I'd like that to happen (mostly for annoying Morty)
	cooldown = 5 SECONDS
/datum/emote/scream/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user))
		return
	if (user.traitHolder && user.traitHolder.hasTrait("scaredshitless"))
		user.emote("fart") //We can still fart if we're muzzled.
	if(user.bioHolder?.HasEffect("mute")) //I appreciate this flavour but did these options have to be so long?
		var/pre_message = "[pick("vibrates for a moment, then stops", "opens [his_or_her(user)] mouth, but no sound comes out",
		"tries to scream, but can't", "emits an audible silence", "huffs and puffs with all [his_or_her(user)] might, but can't seem to make a sound",
		"opens [his_or_her(user)] mouth to produce a resounding lack of noise","flails desperately","")]..."
		return list("<B>[user]</B> [pre_message]", "<i>[pre_message]</i>", MESSAGE_VISIBLE)
	else if (!ismuzzled(user))
		if (narrator_mode)
			playsound(user.loc, 'sound/vox/scream.ogg', 80, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
		else if (user.traitHolder && user.traitHolder.hasTrait("scienceteam"))
			playsound(user.loc, pick(user.sound_list_scream), 80, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
		else if (user.sound_list_scream && length(user.sound_list_scream))
			playsound(user.loc, pick(user.sound_list_scream), 80, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
		else
			playsound(user, user.sound_scream, 80, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
		#ifdef HALLOWEEN
		spooktober_GH.change_points(user.ckey, 30)
		#endif
		var/possumMax = 15
		for_by_tcl(responsePossum, /obj/critter/opossum)
			if (!responsePossum.alive)
				continue
			if(!IN_RANGE(responsePossum, user, 4))
				continue
			if (possumMax-- < 0)
				break
			responsePossum.CritterDeath() // startled into playing dead!
		for_by_tcl(P, /mob/living/critter/small_animal/opossum) // is this more or less intensive than a range(4)?
			if (P.playing_dead) // already out
				continue
			if(!IN_RANGE(P, user, 4))
				continue
			P.play_dead(rand(20,40)) // shorter than the regular "death" stun
		return list("<B>[user]</B> [istype(user.w_uniform, /obj/item/clothing/under/gimmick/frog) ? "croaks" : "screams"]!", null, MESSAGE_AUDIBLE)
	else
		return list("<B>[user]</B> makes a very loud noise.", null, MESSAGE_AUDIBLE)



/datum/emote/twerk // also shakebutt, shakebooty, shakeass
/datum/emote/twerk/enact(mob/user, voluntary = 0, param)
	//For a fun mental image, consider that this emote doesn't actually require you to have a butt organ in place
	user.add_karma(-3)
	SPAWN_DBG(0.5 SECONDS)
		var/beeMax = 15
		for (var/obj/critter/domestic_bee/responseBee in range(5, user))
			if (!responseBee.alive)
				continue

			if (beeMax-- < 0)
				break

			if (prob(75))
				responseBee.visible_message("<b>[responseBee]</b> buzzes [pick("in a confused manner", "perplexedly", "in a perplexed manner")].", group = "responseBee")
			else
				responseBee.visible_message("<b>[responseBee]</b> can't understand [user]'s accent!")
	return list("<B>[user]</B> shakes [his_or_her(user)] ass!", "<I>shakes [his_or_her(user)] ass!</I>", MESSAGE_VISIBLE)


/datum/emote/flex // also flexmuscles
/datum/emote/flex/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user)) return //slot_r_hand
	for (var/obj/item/C as anything in user.get_equipped_items())
		if ((locate(/obj/item/tool/omnitool/syndicate) in C) != null)
			var/obj/item/tool/omnitool/syndicate/O = (locate(/obj/item/tool/omnitool/syndicate) in C)
			var/drophand = (user.hand == 0 ? user.slot_r_hand : user.slot_l_hand)
			user.drop_item()
			O.set_loc(user)
			user.equip_if_possible(O, drophand)
			user.visible_message("<span class='alert'><B>[user] pulls a set of tools out of \the [C]!</B></span>")
			playsound(user.loc, "rustle", 60, 1)
			break
	if (!user.restrained())
		var/roboarms = FALSE
		if (ishuman(user))
			var/mob/living/carbon/human/M = user
			roboarms = M.limbs && istype(M.limbs.r_arm, /obj/item/parts/robot_parts) && istype(M.limbs.l_arm, /obj/item/parts/robot_parts)
		if (roboarms)
			return list("<B>[user]</B> flexes [his_or_her(user)] powerful robotic muscles.", "<I>flexes [his_or_her(user)] powerful robotic muscles</I>", MESSAGE_VISIBLE)
		else
			return list("<B>[user]</B> flexes [his_or_her(user)] muscles.", "<I>flexes [his_or_her(user)] muscles</I>", MESSAGE_VISIBLE)
	else
		return list("<B>[user]</B> tries to stretch [his_or_her(user)] arms.", "<I>tries to stretch [his_or_her(user)] arms</I>", MESSAGE_VISIBLE)


/datum/emote/snapfingers // also snap, fingersnap, click, clickfingers - not to be confused with snap on borgs
/datum/emote/snapfingers/enact(mob/living/user, voluntary = 0, param) //the first human emote I found that goes on mob/living specifically
	if (user.restrained() || !istype(user))
		return
	if (user.bioHolder.HasEffect("chime_snaps"))
		user.sound_fingersnap = 'sound/musical_instruments/WeirdChime_5.ogg'
		user.sound_snap = 'sound/impact_sounds/Glass_Shards_Hit_1.ogg'
	var/hasSwitch = FALSE
	for (var/obj/item/container as anything in user.get_equipped_items())
		if (!(locate(/obj/item/switchblade) in container))
			continue
		var/obj/item/switchblade/blade = (locate(/obj/item/switchblade) in container)
		blade.set_loc(get_turf(user))
		user.put_in_hand_or_drop(blade)
		user.visible_message("<span class='alert'><B>[user] pulls a [blade] out of \the [container]!</B></span>")
		playsound(user.loc, "rustle", 60, TRUE)
		hasSwitch = TRUE
		break
	if (!hasSwitch && prob(5))
		random_brute_damage(user, 20)
		if (narrator_mode)
			playsound(user.loc, 'sound/vox/break.ogg', 100, 1, channel=VOLUME_CHANNEL_EMOTE)
		else
			playsound(user.loc, user.sound_snap, 100, 1, channel=VOLUME_CHANNEL_EMOTE)
		return list("<font color=red><B>[user]</B> snaps [his_or_her(user)] fingers RIGHT OFF!</font>", null, MESSAGE_AUDIBLE)
	else
		if (narrator_mode)
			playsound(user.loc, 'sound/vox/deeoo.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
		else
			playsound(user.loc, user.sound_fingersnap, 50, 1, channel=VOLUME_CHANNEL_EMOTE)
		return list("<B>[user]</B> snaps [his_or_her(user)] fingers.", null, MESSAGE_AUDIBLE)



/datum/emote/airquote // also airquotes
/datum/emote/airquote/enact(mob/user, voluntary = 0, param)
	if (param)
		param = strip_html(param, 200)
		return list("<B>[user]</B> sneers, \"Ah yes, \"[param]\". We have dismissed that claim.\"", null, MESSAGE_AUDIBLE)
	else
		return list("<B>[user]</B> makes air quotes with [his_or_her(user)] fingers.", "<I>makes air quotes with [his_or_her(user)] fingers</I>", MESSAGE_VISIBLE)


/datum/emote/twitch
	var/amplitude_x = 2
	var/amplitude_y = 1
	emote_string = "twitches"

	twitch_v //also twitch_s
		amplitude_x = 3
		emote_string = "twitches violently"
/datum/emote/twitch/enact(mob/user, voluntary = 0, param)
	. = list("<B>[user]</B> [emote_string].", null, MESSAGE_VISIBLE) //no return because of the sleep()
	//The below used to be on a SPAWN but that's probably no longer needed
	var/old_x = user.pixel_x
	var/old_y = user.pixel_y
	user.pixel_x += rand(-amplitude_x,amplitude_x)
	user.pixel_y += rand(-amplitude_y,amplitude_y)
	sleep(0.2 SECONDS)
	user.pixel_x = old_x
	user.pixel_y = old_y


/datum/emote/faint
/datum/emote/faint/enact(mob/user, voluntary = 0, param)
	user.sleeping = 1
	return list("<B>[user]</B> faints.", null, MESSAGE_VISIBLE)


/datum/emote/deathgasp
	possible_while_dead = TRUE
/datum/emote/deathgasp/return_cooldown(mob/user, voluntary = 0)
	return (voluntary ? 5 SECONDS : 0 SECONDS) //I *think* this replicates [if (!voluntary || user.emote_check(voluntary,50))]
/datum/emote/deathgasp/enact(mob/user, voluntary = 0, param)
	if (prob(15) && !ischangeling(user) && !isdead(user))
		return list("<span class='regular'><B>[user]</B> seizes up and falls limp, peeking out of one eye sneakily.</span>", null, MESSAGE_VISIBLE)
	else
		if (!isdead(user))
			#ifdef COMSIG_MOB_FAKE_DEATH
			SEND_SIGNAL(user, COMSIG_MOB_FAKE_DEATH)
			#endif

		// Active if XMAS or manually toggled.
		if (deathConfettiActive)
			user.deathConfetti()

		if (user.traitHolder && user.traitHolder.hasTrait("scienceteam"))
			playsound(user, "sound/voice/scientist/sci_die[pick(1,2,3)].ogg", 80, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
		else
			playsound(user, "sound/voice/death_[pick(1,2)].ogg", 40, 0, 0, user.get_age_pitch())
		return list("<span class='regular'><B>[user]</B> seizes up and falls limp, [his_or_her(user)] eyes dead and lifeless...</span>", null, MESSAGE_VISIBLE)


/datum/emote/johnny
	cooldown = 6 SECONDS
/datum/emote/johnny/enact(mob/user, voluntary = 0, param)
	var/M
	if (param) M = adminscrub(param)
	if (!M)
		var/list/nearby = list()
		for (var/mob/living/N in oview(4, M))
			if(N != M)
				nearby.Add(N)
		if(nearby.len)
			M = pick(nearby)
	if(M)
		particleMaster.SpawnSystem(new /datum/particleSystem/blow_cig_smoke(user.loc, user.dir))
		return list("<B>[user]</B> says, \"[M], please. He had a family.\" [user.name] takes a drag from a cigarette and blows [his_or_her(user)] name out in smoke.", null, MESSAGE_AUDIBLE)


/datum/emote/point
/datum/emote/point/enact(mob/user, voluntary = 0, param)
	if (user.restrained())
		return
	var/mob/M = null
	if (param)
		for (var/atom/A as mob|obj|turf|area in view(null, null))
			if (ckey(param) == ckey(A.name))
				M = A
				break
	if (!M)
		return list("<B>[user]</B> points.", "<I>points</I>", MESSAGE_VISIBLE)
	else
		user.point(M)
		return list("<B>[user]</B> points to [M].", "<I>points to [M]</I>", MESSAGE_VISIBLE)


/datum/emote/signal
/datum/emote/signal/enact(mob/user, voluntary = 0, param)
	if (user.restrained())
		return
	var/t1 = min( max(floor(text2num(param)), 1), 10)
	if (isnum(t1))
		if (t1 <= 5 && (!user.r_hand || !user.l_hand))
			return list("<B>[user]</B> raises [t1] finger\s.", "<I>raises [t1] finger\s</I>", MESSAGE_VISIBLE)
		else if (t1 <= 10 && (!user.r_hand && !user.l_hand))
			return list("<B>[user]</B> raises [t1] finger\s.", "<I>raises [t1] finger\s</I>", MESSAGE_VISIBLE)


/datum/emote/wink
/datum/emote/wink/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user)) return
	for (var/obj/item/C as anything in user.get_equipped_items())
		if ((locate(/obj/item/gun/kinetic/derringer) in C) != null)
			var/obj/item/gun/kinetic/derringer/D = (locate(/obj/item/gun/kinetic/derringer) in C)
			var/drophand = (user.hand == 0 ? user.slot_r_hand : user.slot_l_hand)
			user.drop_item()
			D.set_loc(user)
			user.equip_if_possible(D, drophand)
			user.visible_message("<span class='alert'><B>[user] pulls a derringer out of \the [C]!</B></span>")
			playsound(user.loc, "rustle", 60, 1)
			break

	return list("<B>[user]</B> winks.", "<I>winks</I>", MESSAGE_VISIBLE)


/datum/emote/collapse
	emote_string = "collapse"
	trip //relative type
		emote_string = "trip"
/datum/emote/collapse/enact(mob/user, voluntary = 0, param)
	if (!user.getStatusDuration("paralysis"))
		user.changeStatus("paralysis", 3 SECONDS)
	return list("<B>[user]</B> [emote_string]s!", null, MESSAGE_AUDIBLE) //was audible in the old code but IDK why


/datum/emote/burp
/datum/emote/burp/enact(mob/living/user, voluntary = 0, param)
	if (!istype(user)) //burp sound
		return
	if ((user.charges >= 1) && (!ismuzzled(user)))
		for (var/mob/O in viewers(user, null))
			O.show_message("<B>[user]</B> burps.")
		for (var/mob/M in oview(1))
			elecflash(user,power = 2)
			boutput(M, "<span class='notice'>BZZZZZZZZZZZT!</span>")
			M.TakeDamage("chest", 0, 20, 0, DAMAGE_BURN)
			user.charges -= 1
			if (narrator_mode)
				playsound(user.loc, 'sound/vox/bloop.ogg', 70, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
			else
				playsound(user, user.sound_burp, 70, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
			return
	else if ((user.charges >= 1) && (ismuzzled(user)))
		for (var/mob/O in viewers(user, null))
			O.show_message("<B>[user]</B> vomits in [his_or_her(user)] own mouth a bit.")
		user.TakeDamage("head", 0, 50, 0, DAMAGE_BURN)
		user.charges -=1
		return
	else if ((user.charges < 1) && (!ismuzzled(user)))
		if (narrator_mode)
			playsound(user.loc, 'sound/vox/bloop.ogg', 70, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
		else
			if (user.getStatusDuration("food_deep_burp"))
				playsound(user, user.sound_burp, 70, 0, 0, user.get_age_pitch() * 0.5, channel=VOLUME_CHANNEL_EMOTE)
			else
				playsound(user, user.sound_burp, 70, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)

		var/datum/statusEffect/fire_burp/FB = user.hasStatus("food_fireburp")
		if (!FB)
			FB = user.hasStatus("food_fireburp_big")
		if (FB)
			SPAWN_DBG(0)
				FB.cast()
		return list("<B>[user]</B> burps.", null, MESSAGE_AUDIBLE)
	else
		return list("<B>[user]</B> vomits in [his_or_her(user)] own mouth a bit.", null, MESSAGE_AUDIBLE)


/datum/emote/poo //also poop, shit, crap
/datum/emote/poo/enact(mob/living/carbon/user, voluntary = 0, param)
	if (!istype(user))
		return
	var/message = "<B>[user]</B> grunts for a moment."
	var/obj/item/storage/toilet/toilet = locate() in user.loc

	if (toilet && (user.buckled != null))
		if (user.poops >= 1)
			for (var/obj/item/storage/toilet/T in user.loc)
				message = pick("<B>[user]</B> unzips [his_or_her(user)] pants and [pick("shits","turds","craps","poops","pooes")] in the toilet.", "<B>[user]</B> empties [his_or_her(user)] bladder.", "<span class='notice'>Ahhh, sweet relief.</span>")
				var/load = (rand(1,user.poops))/5 //if you got five or more poops (ten bites) stored up, you might clog the pipes!
				user.poops = 0 //empty out the shitbutt!
				if(load >= 1)
					message = "<B>[user]</B> grunts for a moment- Then really fills the bowl!"
					var/turf/terf = get_turf(user)
					terf.fluid_react_single("miasma", 5, airborne = 1)
					T.poops++
					var/obj/item/reagent_containers/food/snacks/ingredient/mud/shit = new()
					shit.amount = user.poop_amount
					T.add_contents(shit)
				T.clogged += load
				T.poops++
				var/obj/item/reagent_containers/food/snacks/ingredient/mud/shit = new()
				shit.amount = user.poop_amount
				T.add_contents(shit)
				playsound(user, user.sound_fart, 50, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
				break
			user.wiped = 0
			user.cleanhands = 0
		else
			message = "<B>[user]</B> unzips [his_or_her(user)] pants but, try as [he_or_she(user)] might, [he_or_she(user)] can't shit!"
	else if (user.poops < 1)
		message = "<B>[user]</B> grunts for a moment. [prob(1)?"something":"nothing"] happens."
	else

		user.poop()
	return list(message, "<I>grunts</I>", MESSAGE_AUDIBLE)


/datum/emote/miranda
	cooldown = 5 SECONDS
/datum/emote/miranda/enact(mob/user, voluntary = 0, param)
	if (user.mind && (user.mind.assigned_role in list("Captain", "Head of Personnel", "Head of Security", "Security Officer", "Security Assistant", "Detective", "Vice Officer", "Regional Director", "Inspector")))
		user.recite_miranda()

/datum/emote/suicide
/datum/emote/suicide/enact(mob/user, voluntary = 0, param)
	user.do_suicide()

/datum/emote/custom
/datum/emote/custom/enact(mob/user, voluntary = 0, param)
	if (IS_TWITCH_CONTROLLED(user)) return
	var/m_type
	var/input = sanitize(html_encode(input("Choose an emote to display.")))
	var/input2 = input("Is this a visible or audible emote?") in list("Visible","Audible")
	if (input2 == "Visible") m_type = MESSAGE_VISIBLE
	else if (input2 == "Audible") m_type = MESSAGE_AUDIBLE
	else
		alert("Unable to use this emote, must be either audible or visible.")
		return
	phrase_log.log_phrase("emote", input)
	return list("<B>[user]</B> [input]", "<I>[input]</I>", m_type, copytext(input, 1, 10))

/datum/emote/customv //custom visible
/datum/emote/customv/enact(mob/user, voluntary = 0, param)
	if (IS_TWITCH_CONTROLLED(user)) return
	if (!param)
		param = input("Choose an emote to display.")
		if(!param) return

	param = sanitize(html_encode(param))
	phrase_log.log_phrase("emote", param)
	return list("<b>[user]</b> [param]","<I>[param]</I>",MESSAGE_VISIBLE,copytext(param, 1, 10))

/datum/emote/customh //custom heard
/datum/emote/customh/enact(mob/user, voluntary = 0, param)
	if (IS_TWITCH_CONTROLLED(user)) return
	if (!param)
		param = input("Choose an emote to display.")
		if(!param) return

	param = sanitize(html_encode(param))
	phrase_log.log_phrase("emote", param)
	return list("<b>[user]</b> [param]","<I>[param]</I>",MESSAGE_AUDIBLE,copytext(param, 1, 10))

/datum/emote/me //AFAIK this exists for me_verb
/datum/emote/me/enact(mob/user, voluntary = 0, param)
	if (IS_TWITCH_CONTROLLED(user)) return
	if (!param)
		return
	param = sanitize(html_encode(param))
	phrase_log.log_phrase("emote", param)
	return list("<b>[user]</b> [param]","<I>[param]</I>",MESSAGE_VISIBLE,copytext(param, 1, 10))
