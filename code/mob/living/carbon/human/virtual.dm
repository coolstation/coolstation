/mob/living/carbon/human/virtual
	real_name = "Virtual Human"
	var/mob/body = null
	var/isghost = 0 //Should contain a string of the original ghosts real_name
	var/escape_vr = 0


	New()
		..()
		sound_burp = 'sound/voice/virtual_gassy.ogg'
		//sound_malescream = 'sound/voice/virtual_scream.ogg'
		sound_scream = 'sound/voice/virtual_scream.ogg'
		sound_fart = 'sound/voice/virtual_gassy.ogg'
		sound_snap = 'sound/voice/virtual_snap.ogg'
		sound_fingersnap = 'sound/voice/virtual_snap.ogg'
		SPAWN_DBG(0)
			src.set_mutantrace(/datum/mutantrace/virtual)

	Life(datum/controller/process/mobs/parent)
		if (!loc)
			return
		if (..(parent))
			return 1
		var/turf/T = get_turf(src)

		if (!escape_vr)
			var/area/A = get_area(src)
			if ((T && !(T.z == 2)) || (A && !A.virtual))
				boutput(src, "<span class='alert'>Is this virtual?  Is this real?? <b>YOUR MIND CANNOT TAKE THIS METAPHYSICAL CALAMITY</b></span>")
				src.gib()
				return

			if(!isghost && src.body)
				if(!istype(src.body, /mob/dead/aieye) && isdead(src.body) || !src.body:network_device)
					src.gib()
					return
		return

	death(gibbed)

		ghostize(src)

		Station_VNet.Leave_Vspace(src)

		qdel(src)

		src.z = 1 //stops gibs generating in nullspace

		return

	disposing()
		if (isghost && src.client)
			var/mob/dead/observer/O = src.ghostize()
			var/arrival_loc = pick_landmark(LANDMARK_LATEJOIN)
			O.real_name = src.isghost
			O.name = O.real_name
			O.set_loc(arrival_loc)
		..()

	ex_act(severity)
		src.flash(3 SECONDS)
		if(severity >= 6) //old severity 1
			src.death()
		return

	say(var/message, var/ignore_stamina_winded = FALSE, var/unique_maptext_style, var/maptext_animation_colors)
		if(!isghost)
			return ..()

		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
		if (!message)
			return

		if (dd_hasprefix(message, "*"))
			return src.emote(copytext(message, 2),1)

		if (src.client && src.client.ismuted())
			boutput(src, "You are currently muted and may not speak.")
			return

		. = src.say_dead(message, 1)

	emote(var/act, var/voluntary = 0, var/emoteTarget = null)
		if(isghost)
			if (findtext(act, " ", 1, null))
				var/t1 = findtext(act, " ", 1, null)
				act = copytext(act, 1, t1)
			var/txt = lowertext(act)
			if (txt == "custom" || txt == "customh" || txt == "customv" || txt == "me" || txt == "airquote" || txt == "airquotes")
				boutput(usr, "You may not use that emote as a Virtual Spectre.")
				return
		..()

	whisper(message as text, forced=FALSE)
		if (isghost)
			boutput(usr, "You may not use that emote as a Virtual Spectre.")
			return
		..()



/datum/abilityHolder/virtual
	usesPoints = 0
	regenRate = 0
	tabName = "Virtual"

/////////////////////////////////////////////// Wrestler spell parent ////////////////////////////

/datum/targetable/virtual
	pointCost = 0
	targeted = 0
	preferred_holder_type = /datum/abilityHolder/virtual
	icon = 'icons/misc/kudzu_plus.dmi'
	icon_state = "kudzu-template"

/datum/targetable/virtual/logout
	icon_state = "guide"
	name = "Log out"
	desc = "Exit virtual reality."
	cooldown = 0
	targeted = 0
	target_anything = 0
	interrupt_action_bars = 0
	dont_lock_holder = 1

	//castcheck()
		//if (!holder)
		//	return 0

	cast()
		// Won't delete the VR character otherwise, which can be confusing (detective's goggles sending you to the existing body in the bomb VR etc).
		setdead(holder.owner)
		holder.owner.death(0)

		Station_VNet.Leave_Vspace(holder.owner)



/atom/movable/screen/ability/topBar/virtual
	clicked(params)
		var/datum/targetable/virtual/spell = owner
		//var/datum/abilityHolder/holder = owner.holder

		spell.handleCast()
		/*

		if (!istype(spell))
			return
		if (!spell.holder)
			return

		if (spell.targeted && usr.targeting_ability == owner)
			usr.targeting_ability = null
			usr.update_cursor()
			return
		if (spell.targeted)
			if (world.time < spell.last_cast)
				return
			owner.holder.owner.targeting_ability = owner
			owner.holder.owner.update_cursor()
		else
			SPAWN_DBG(0)
				spell.handleCast()
		return
		*/
