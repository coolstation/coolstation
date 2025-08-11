/*
CONTAINS:
TOILET
*/

/obj/item/storage/toilet
	name = "toilet"
	w_class = W_CLASS_BULKY
	anchored = 1.0
	density = 0.0
	mats = 5
	flags = OPENCONTAINER | FPRINT | TABLEPASS | NOSPLASH
	deconstruct_flags = DECON_WRENCH | DECON_WELDER
	var/obj/disposalpipe/trunk/trunk = null
	anchored = 1.0
	icon = 'icons/obj/objects.dmi'
	icon_state = "toilet"
	rand_pos = 0
	burn_point = 15000
	burn_output = 1000
	var/clogged = 0 // clogs at 10 guaranteed or earlier at random, items inside effectively add 1
	var/needs_plunged = 0
	var/last_flush = 0
	var/tank_refill_time = 8 SECONDS
	var/plumbed = 0
	var/cursed = 0

/obj/item/storage/toilet/New()
	..()
	START_TRACKING
	src.create_reagents(300)
	src.reagents.add_reagent("water", 120)
	SPAWN_DBG(0.5 SECONDS)
		if (src)
			trunk = locate() in src.loc
			if(trunk)
				trunk.linked = src	// link the pipe trunk to self
				plumbed = 1


/obj/item/storage/toilet/disposing()
	STOP_TRACKING
	..()

/obj/item/storage/toilet/attackby(obj/item/W as obj, mob/user as mob, obj/item/storage/T)
	if (src.contents.len >= 7)
		return
	if ((istype(W, /obj/item/reagent_containers/glass)) || (istype(W, /obj/item/reagent_containers/food/drinks)))
		/*if(src.reagents && (src.reagents.total_volume >= src.reagents.maximum_volume))
			boutput(user, "That would just spill-over. You should flush first.")
			return*/
		var/obj/item/reagent_containers/R = W
		if(R.reagents && R.reagents.total_volume)
			R.reagents.trans_to(src, R.reagents.total_volume)
			playsound(src, "sound/misc/pourdrink.ogg", 50, 1)
			boutput(user, "You pour out [R] into [src].")
			return

	else if (istype(W, /obj/item/grab))
		playsound(src, "sound/effects/toilet_flush.ogg", 50, 1)
		user.visible_message("<span class='notice'>[user] gives [W:affecting] a swirlie!</span>", "<span class='notice'>You give [W:affecting] a swirlie. It's like Middle School all over again!</span>")
		return

	else if (istype(W, /obj/item/clothing/head/plunger))
		if(!src.needs_plunged) return
		user.visible_message("<span class='notice'>[user] plunges \the [src]!</span>", "<span class='notice'>You plunge \the [src]!</span>")
		playsound(src.loc, "sound/items/plunger_pop.ogg", 50, 1)
		if(prob(15))
			src.needs_plunged = FALSE
			playsound(src, "sound/effects/toilet_flush.ogg", 50, 1)

#ifdef UNDERWATER_MAP
			var/turf/source = get_turf(src)
			if (source && source.z == Z_LEVEL_STATION && !(src.plumbed && src.trunk))
				var/turf/target = locate(source.x,source.y,5)
				for (var/thing in contents)
					var/atom/movable/A = thing
					A.set_loc(target)
#endif
			src.clogged = 0
			if(plumbed && trunk)
				var/obj/disposalholder/D = new()
				src.flush_into(D)
				D.start(src) // not a disposaloutlet but lets see if that matters:)

			else
				for (var/item in src.contents)
					qdel(item)
					src.hud?.remove_item(item)
				src.reagents.clear_reagents()
		return

	return ..()

/obj/item/storage/toilet/MouseDrop(atom/over_object, src_location, over_location)
	if (usr && over_object == usr && in_interact_range(src, usr) && iscarbon(usr) && !usr.stat)
		usr.visible_message("<span class='alert'>[usr] [pick("shoves", "sticks", "stuffs")] [his_or_her(usr)] hand into [src]!</span>")
		playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 25, 1)
	..()

/obj/item/storage/toilet/MouseDrop_T(mob/living/carbon/human/M as mob, mob/user as mob) // Yeah, uh, only living humans should use the toilet
	if (!ticker)
		boutput(user, "You can't help relieve anyone before the game starts.")
		return
	if (!ishuman(M) || get_dist(src, user) > 1 || user.restrained() || user.stat)
		return
	if (M == user && ishuman(user) && !src.needs_plunged)
		var/mob/living/carbon/human/H = user
		if (istype(H.w_uniform, /obj/item/clothing/under/gimmick/mario) && istype(H.head, /obj/item/clothing/head/mario))
			user.visible_message("<span class='notice'>[user] dives into [src]!</span>", "<span class='notice'>You dive into [src]!</span>")
			//particleMaster.SpawnSystem(new /datum/particleSystem/tpbeam(src.loc))
			playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 25, 1)
			H.unlock_medal("It'sa me, Mario", 1)


			var/obj/disposalholder/crawler/crawl = new()
			crawl.pilot = user
			user.override_movement_controller = crawl.movement_controller
			user.set_loc(crawl)
			src.flush_into(crawl)
			return
			/*var/list/destinations = list()

			for_by_tcl(T, /obj/item/storage/toilet)
				if (T == src || !isturf(T.loc) || T.z != src.z  || isrestrictedz(T.z) || (istype(T.loc.loc,/area) && T.loc.loc:teleport_blocked))
					continue
				destinations.Add(T)

			if (destinations.len)
				var/atom/picked = pick(destinations)
				particleMaster.SpawnSystem(new /datum/particleSystem/tpbeam(picked.loc))
				M.set_loc(picked.loc)
				playsound(picked.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 25, 1)
				user.visible_message("<span class='notice'>[user] emerges from [src]!</span>", "<span class='notice'>You emerge from [src]!</span>")
			return*/
	if(M.loc != src.loc)
		return
	if (M == user)
		user.visible_message("<span class='notice'>[user] sits on [src].</span>", "<span class='notice'>You sit on [src].</span>")
	else
		user.visible_message("<span class='notice'>[M] is seated on [src] by [user]!</span>")
	M.anchored = 1
	M.buckled = src
	M.set_loc(src.loc)
	src.add_fingerprint(user)
	return

/obj/item/storage/toilet/attack_hand(mob/user as mob)

	for(var/mob/M in src.loc)
		if (M.buckled)
			if (M != user)
				user.visible_message("<span class='notice'>[M] is zipped up by [user]. That's... that's honestly pretty creepy.</span>")
			else
				user.visible_message("<span class='notice'>[M] zips up.</span>", "<span class='notice'>You zip up.</span>")
//			boutput(world, "[M] is no longer buckled to [src]")
			reset_anchored(M)
			M.buckled = null
			src.add_fingerprint(user)

	if(world.time < src.last_flush + src.tank_refill_time)
		src.reagents.add_reagent("water", (world.time - src.last_flush) / (src.tank_refill_time) * clamp(ceil(150 - src.reagents.total_volume), 5, 120))

	src.last_flush = world.time

	if(src.needs_plunged && prob(99))
		src.visible_message("<span class='notice'>The toilet is clogged!</span>")
		playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 25, 1)
		SPAWN_DBG(src.tank_refill_time)
			if(!QDELETED(src))
				src.reagents.add_reagent("water", clamp(150 - ceil(src.reagents.total_volume), 10, 120))

	else
		if(src.needs_plunged)
			boutput(user, SPAN_NOTICE("Oh thank fuck."))
		else if(src.clogged + src.contents.len >= 3 && (src.clogged + src.contents.len >= 10 || prob((src.clogged + src.contents.len) * 10)))
			src.needs_plunged = TRUE
			boutput(user, SPAN_ALERT("The toilet clogs!"))
			user.unlock_medal("Where's the poop knife?",1)
			SPAWN_DBG(src.tank_refill_time)
				if(!QDELETED(src))
					src.reagents.add_reagent("water", clamp(150 - ceil(src.reagents.total_volume), 5, 120))
			return

		user.visible_message("<span class='notice'>[user] flushes [src].</span>", "<span class='notice'>You flush [src].</span>")
		playsound(src, "sound/effects/toilet_flush.ogg", 50, 1)

#ifdef UNDERWATER_MAP
		var/turf/source = get_turf(src)
		if (source && source.z == Z_LEVEL_STATION && !(src.plumbed && src.trunk))
			var/turf/target = locate(source.x,source.y,5)
			for (var/thing in contents)
				var/atom/movable/A = thing
				A.set_loc(target)
#endif
		src.clogged = max(0, src.clogged - 5) // not guaranteed to clean it entirely
		if(plumbed && trunk)
			var/obj/disposalholder/D = new()
			src.flush_into(D)
			D.start(src) // not a disposaloutlet but lets see if that matters:)

		else
			for (var/item in src.contents)
				qdel(item)
				src.hud?.remove_item(item)
			src.reagents.clear_reagents()

/obj/item/storage/toilet/on_reagent_change(add)
	if(add && src.reagents.total_volume > src.reagents.maximum_volume * 0.8)
		var/turf/T = get_turf(src)
		if(issimulatedturf(T))
			playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 25, 1)
			src.reagents.trans_to(T, src.reagents.total_volume - src.reagents.maximum_volume * 0.7, do_fluid_react = TRUE)


/obj/item/storage/toilet/proc/flush_into(var/obj/disposalholder/D)
	if(src.trunk)		//copypasted
		D.set_loc(src.trunk)
	else
		D.set_loc(src)

	if(!D.reagents)
		D.reagents = new(1000)

	if(src.reagents && src.reagents.total_volume)
		var/wastewater = src.reagents.get_reagent_amount("water")
		var/sewage_created = min(src.reagents.total_volume - wastewater, wastewater)
		if(sewage_created)
			src.reagents.remove_any(sewage_created)
			src.reagents.add_reagent("sewage", sewage_created)

		src.reagents.trans_to(D, src.reagents.total_volume)
		SPAWN_DBG(src.tank_refill_time)
			if(!QDELETED(src))
				src.reagents.add_reagent("water", clamp(150 - ceil(src.reagents.total_volume), 5, 120))

	for(var/atom/movable/AM in src)
		AM.set_loc(D)

/obj/item/storage/toilet/custom_suicide = 1
/obj/item/storage/toilet/suicide_in_hand = 0
/obj/item/storage/toilet/suicide(var/mob/living/carbon/human/user as mob)
	if (!ishuman(user) || !user.organHolder)
		return 0

	user.visible_message("<span class='alert'><b>[user] sticks [his_or_her(user)] head into [src] and flushes it, giving [him_or_her(user)]self an atomic swirlie!</b></span>")
	var/obj/head = user.organHolder.drop_organ("head")
	if (src.needs_plunged)
		head.set_loc(src.loc)
		playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 25, 1)
		src.visible_message("<span class='notice'>[head] floats up out of the clogged [src.name]!</span>")
		for (var/mob/living/carbon/human/O in AIviewers(head, null))
			if (prob(33))
				O.visible_message("<span class='alert'>[O] pukes all over [him_or_her(O)]self. Thanks, [user].</span>",\
				"<span class='alert'>You feel ill from watching that. Thanks, [user].</span>")
				O.vomit()
	else
		var/list/emergeplaces = list()
		for_by_tcl(T, /obj/item/storage/toilet)
			if (T == src || !isturf(T.loc) || T.z != src.z  || isrestrictedz(T.z)) continue
			emergeplaces.Add(T)
		if (emergeplaces.len)
			var/atom/picked = pick(emergeplaces)
			head.set_loc(picked.loc)
			playsound(picked.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 25, 1)
			head.visible_message("<span class='notice'>[head] emerges from [picked]!</span>")
		for (var/mob/living/carbon/human/O in AIviewers(head, null))
			if (prob(33))
				O.visible_message("<span class='alert'>[O] pukes all over [him_or_her(O)]self. Thanks, [user].</span>",\
				"<span class='alert'>You feel ill from watching that. Thanks, [user].</span>")
				O.vomit()

	playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 25, 1)
	health_update_queue |= user
	SPAWN_DBG(10 SECONDS)
		if (user)
			user.suiciding = 0
	return 1

/obj/item/storage/toilet/random
	New()
		..()
		if (prob(1))
			var/something = pick(trinket_safelist)
			if (ispath(something))
				new something(src)

/obj/item/storage/toilet/random/gold // important!!
	New()
		..()
		src.setMaterial(getMaterial("gold"))

/obj/item/storage/toilet/random/escapetools
	spawn_contents = list(/obj/item/wirecutters,\
	/obj/item/screwdriver,\
	/obj/item/wrench,\
	/obj/item/crowbar,)

/obj/item/storage/toilet/goldentoilet
	name = "golden toilet"
	icon_state = "goldentoilet"
	desc = "The result of years of stolen Nanotrasen funds."

	New()
		..()
		particleMaster.SpawnSystem(new /datum/particleSystem/sparkles(src))

/obj/item/storage/toilet/proc/curse()
	src.name = "cursed " + src.name
	src.cursed = 1
