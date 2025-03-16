/mob/living/intangible/blob_overmind
	name = "Blob Overmind"
	real_name = "Blob Overmind"
	desc = "The disembodied consciousness of a big pile of goop."
	icon = 'icons/mob/mob.dmi'
	icon_state = "blob"
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	density = 0
	canmove = 1
	blinded = 0
	anchored = 1
	use_stamina = 0
	mob_flags = SPEECH_BLOB

	//give blobs who get rekt soon after starting another chance
	var/current_try = 1
	var/extra_tries_max = 2
	var/extra_try_period = 3000 //3000 = 5 minutes
	var/extra_try_timestamp = 0

	var/datum/abilityHolder/blob/blob_holder

	New()
		..()
		APPLY_MOB_PROPERTY(src, PROP_INVISIBILITY, src, INVIS_GHOST)
		src.sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
		src.see_invisible = 15
		src.see_in_dark = SEE_DARK_FULL

		//set start grace-period timestamp
		var/extraGrace = rand(600, 1800) //add between 1 min and 3 mins extra
		src.extra_try_timestamp = world.timeofday + extra_try_period + extraGrace

		src.blob_holder = src.add_ability_holder(/datum/abilityHolder/blob)

	Move(NewLoc)
		if (src.blob_holder.tutorial)
			if (!src.blob_holder.tutorial.PerformAction("move", NewLoc))
				return 0
		if (isturf(NewLoc))
			var/turf/T = NewLoc
			if (istype(T, /turf/wall) && !issimulatedturf(T)) //IDK why this gives a shit about not letting blobs go on unsimmed walls
				return 0
		..()

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (src.blob_holder.started && (!length(src.blob_holder.nuclei) || !length(src.blob_holder.blobs)))
			death()
			return

	death()
		//death was called but the player isnt playing this blob anymore
		//OR they're in the process of transforming (e.g. gibbing)
		if ((src.client && src.client.mob != src) || src.transforming)
			return

		//if within grace period, respawn
		if (src.current_try < src.extra_tries_max && world.timeofday <= src.extra_try_timestamp)
			src.extra_try_timestamp = 0
			src.current_try++
			src.blob_holder.reset()
			boutput(src, "<span class='notice'><b>In a desperate act of self preservation you avoid your untimely death by concentrating what energy you had left! You feel ready for round [src.current_try]!</b></span>")

		//no grace, go die scrub
		else
			src.remove_ability_holder(src.blob_holder)
			boutput(src, "<span class='alert'><b>With no nuclei to bind it to your biomass, your consciousness slips away into nothingness...</b></span>")
			src.ghostize()
			SPAWN_DBG(0)
				qdel(src)

	Login()
		..()
		client.show_popup_menus = 0
		var/atom/plane = client.get_plane(PLANE_LIGHTING)
		plane.alpha = 200

	Logout()
		..()
		if (src.last_client)
			if (src.last_client.buildmode)
				if (src.last_client.buildmode.is_active)
					return
			src.last_client.show_popup_menus = 1

			var/atom/plane = last_client.get_plane(PLANE_LIGHTING)
			if (plane)
				plane.alpha = 255

	MouseDrop()
		return

	MouseDrop_T()
		return

	meteorhit()
		return

	is_spacefaring()
		return 1

	movement_delay()
		if (src.client && src.client.check_key(KEY_RUN))
			return 0.4 + movement_delay_modifier
		else
			return 0.75 + movement_delay_modifier

	click(atom/target, params)
		if(!src.targeting_ability && !(params && (params["shift"] || params["ctrl"] || params["alt"])) && isturf(target))
			var/turf/T = target
			if (T && (!isghostrestrictedz(T.z) || (isghostrestrictedz(T.z) && restricted_z_allowed(src, T)) || src.blob_holder.tutorial || (src.client && src.client.holder)))
				if (src.blob_holder.tutorial)
					if (!src.blob_holder.tutorial.PerformAction("clickmove", T))
						return
				src.set_loc(T)
				return

			if (T && isghostrestrictedz(T.z) && !restricted_z_allowed(src, T) && !(src.client && src.client.holder))
				var/OS = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, 1))
				if (OS)
					src.set_loc(OS)
				else
					src.z = 1
		else
			..()

	say_understands() return 1
	can_use_hands()	return 0

	say(var/message)
		return ..(message)

	say_quote(var/text)
		var/speechverb = pick("wobbles", "wibbles", "jiggles", "wiggles", "undulates", "fidgets", "joggles", "twitches", "waggles", "trembles", "quivers")
		return "[speechverb], \"[text]\""

	proc/onBlobHit(var/obj/blob/B, var/mob/M)
		return

	proc/onBlobDeath(var/obj/blob/B, var/mob/M)
		return

	projCanHit(datum/projectile/P)
		return 0

/mob/living/intangible/blob_overmind/checkContextActions(atom/target)
	// a bit oh a hack, no multicontext for blobs now because it keeps overriding attacking pods :/
	return list()

/mob/proc/make_blob()
	if (!src.client && !src.mind)
		return null
	var/mob/living/intangible/blob_overmind/W = new/mob/living/intangible/blob_overmind(src)

	var/turf/T = get_turf(src)
	if (!(T && isturf(T)) || (isghostrestrictedz(T.z) && !(src.client && src.client.holder)))
		var/ASLoc = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, 1))
		if (ASLoc)
			W.set_loc(ASLoc)
		else
			W.z = 1
	else
		W.set_loc(pick_landmark(LANDMARK_LATEJOIN))

	if (src.mind)
		src.mind.transfer_to(W)
	else
		var/key = src.client.key
		if (src.client)
			src.client.mob = W
		W.mind = new /datum/mind()
		W.mind.ckey = ckey
		W.mind.key = key
		W.mind.current = W
		ticker.minds += W.mind

	var/this = src
	src = null
	qdel(this)

	boutput(W, "<b>You are a blob! Grow in size and devour the station.</b>")
	boutput(W, "Your hivemind will cease to exist if your body is entirely destroyed.")
	boutput(W, "Use the question mark button in the lower right corner to get help on your abilities.")

	return W
