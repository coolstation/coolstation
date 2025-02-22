/*TYPEINFO(/datum/component/hallucination/trippy_colors)
	initialization_args = list(
		ARG_INFO("timeout", "num", "how long this hallucination lasts in seconds. -1 for permanent", 30),
	)*/

TYPEINFO(/datum/component/hallucination/random_sound)
	initialization_args = list(
		ARG_INFO("timeout", "num", "how long this hallucination lasts in seconds. -1 for permanent", 30),
		ARG_INFO("sound_list", "Build New List", "List of sounds that the mob can hallucinate appearing."),
		ARG_INFO("sound_prob", "num", "probability of a sound being played per mob life tick", 10),
		ARG_INFO("min_distance", "num", "minimum distance to the mob the sound will play from", 0),
	)

TYPEINFO(/datum/component/hallucination/random_image)
	initialization_args = list(
		ARG_INFO("timeout", "num", "how long this hallucination lasts in seconds. -1 for permanent", 30),
		ARG_INFO("image_list", "Build New List", "List of images that the mob can hallucinate appearing"),
		ARG_INFO("image_prob", "num", "probability of an image being displayed per mob life tick", 10),
		ARG_INFO("image_time", "num", "seconds the displayed image hangs around", 20),
	)

TYPEINFO(/datum/component/hallucination/fake_attack)
	initialization_args = list(
		ARG_INFO("timeout", "num", "how long this hallucination lasts in seconds. -1 for permanent", 30),
		ARG_INFO("image_list", "Build New List", "List of images that the mob can hallucinate attacking, leave null for default"),
		ARG_INFO("name_list", "Build New List", "List of names that the mob can hallucinate attacking, leave null for default"),
		ARG_INFO("attacker_prob", "num", "probability of an attacker being spawned per mob life tick", 10),
		ARG_INFO("max_attackers", "num", "number of attackers that can be active at one time", 5),
	)

TYPEINFO(/datum/component/hallucination/random_image_override)
	initialization_args = list(
		ARG_INFO("timeout", "num", "how long this hallucination lasts in seconds. -1 for permanent", 30),
		ARG_INFO("image_list", "Build New List", "List of images that the mob can hallucinate attached to things"),
		ARG_INFO("target_list", "Build New List", "List of target types that the mob can hallucinate images attached to in range"),
		ARG_INFO("range", "num", "distance from mob to search for target types", 5),
		ARG_INFO("image_prob", "num", "probability of an image being displayed per mob life tick", 10),
		ARG_INFO("image_time", "num", "seconds the displayed image hangs around", 20),
		ARG_INFO("override", "boolean", "Does this hallucination replace the target's icon?", TRUE),
		ARG_INFO("visible_creation", "boolean", "Should the displayed image appear in line of sight?", TRUE),
	)


//#########################################################
//                HALLUCINATION COMPONENTS
//#########################################################


///Generic hallucination effects - subclass for fancy effects
ABSTRACT_TYPE(/datum/component/hallucination)
/datum/component/hallucination
	dupe_mode = COMPONENT_DUPE_SELECTIVE//you can have lots of hallucinations, from different sources, but maybe not duplicates from the same source (unless you wanna)
	///expiry time, -1 means never
	var/ttl = -1
	///Instead of typecasting every tick, let's just hold a nice ref
	var/mob/parent_mob

/datum/component/hallucination/Initialize(timeout=30)
	. = ..()
	if (!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	parent_mob = parent
	ttl = timeout
	if(ttl != -1)
		ttl = world.time + timeout SECONDS
	RegisterSignal(parent, COMSIG_LIVING_LIFE_TICK, PROC_REF(do_mob_tick))

/datum/component/hallucination/proc/do_mob_tick(mob, mult)
	if(ttl != -1 && world.time > ttl)
		UnregisterFromParent()
		qdel(src)

/datum/component/hallucination/CheckDupeComponent(timeout)
	if(timeout == -1)
		src.ttl = timeout
	else if(src.ttl != -1)
		src.ttl = world.time + timeout SECONDS //reset timeout

	return FALSE //false means create a new component, true means this is a dupe so don't create it
//#########################################################
//                    TRIPPY COLORS
//#########################################################


///MYLIE TO DO - requires color update to 20 channel for complete porting

/// Trippy colors - apply an RGB swap to client's vision
/*/datum/component/hallucination/trippy_colors
	var/current_color_pattern = 0
	var/pattern1 = list(0,0,1,0, 1,0,0,0, 0,1,0,0, 0,0,0,1, 0,0,0,0)
	var/pattern2 = list(0,1,0,0, 0,0,1,0, 1,0,0,0, 0,0,0,1, 0,0,0,0)

	do_mob_tick(mob, mult)
		if(parent_mob.client && (current_color_pattern == 0 || probmult(20))) //trippy colours
			if(src.current_color_pattern == 1)
				parent_mob.client.animate_color(pattern2, time=40, easing=SINE_EASING)
				src.current_color_pattern = 2
			else
				parent_mob.client.animate_color(pattern1, time=40, easing=SINE_EASING)
				src.current_color_pattern = 1
		..()

	UnregisterFromParent()
		. = ..()
		UnregisterSignal(parent, COMSIG_LIVING_LIFE_TICK)
		if(parent_mob?.client)
			animate(parent_mob.client, color = null, time = 2 SECONDS, easing = SINE_EASING)
*/


//#########################################################
//                    RANDOM SOUNDS
//#########################################################

/// Random sound - play a sound from a list with a prob per life tick
/datum/component/hallucination/random_sound
	var/list/sound_list
	var/sound_prob = 10
	var/min_distance = 0

	Initialize(timeout=30, sound_list=null, sound_prob=10, min_distance=0)
		.=..()
		if(. == COMPONENT_INCOMPATIBLE || length(sound_list) == 0)
			return .
		src.sound_list = sound_list
		src.sound_prob = sound_prob
		src.min_distance = min_distance


	do_mob_tick(mob, mult)
		if(probmult(src.sound_prob))
			var/atom/origin = parent_mob.loc
			var/turf/mob_turf = get_turf(parent_mob)
			if (mob_turf)
				origin = locate(mob_turf.x + pick(rand(-10,-src.min_distance),rand(src.min_distance,10)), mob_turf.y + pick(rand(-10,-src.min_distance),rand(src.min_distance,10)), mob_turf.z)
			//wacky loosely typed code ahead
			var/datum/hallucinated_sound/chosen = pick(src.sound_list)
			if (istype(chosen)) //it's a datum
				chosen.play(parent_mob, origin)
			else //it's just a path directly
				parent_mob.playsound_local(origin, chosen, 100, 1)
		. = ..()

	CheckDupeComponent(timeout, sound_list, sound_prob)
		if(sound_list ~= src.sound_list) //this is the same hallucination, just update timeout and prob
			if(timeout == -1)
				src.ttl = timeout
			else if(src.ttl != -1)
				src.ttl = world.time + timeout SECONDS //reset timeout
			src.sound_prob = sound_prob
			return TRUE //no duplicate
		else
			return FALSE //create a new hallucination

//#########################################################
//                    RANDOM IMAGE
//#########################################################

/// Random image - hallucinate an image on a visible tile with prob per life tick
/datum/component/hallucination/random_image
	var/list/image_list
	var/image_prob = 10
	var/image_time = 20

	Initialize(timeout=30, image_list=null, image_prob=10, image_time=20 SECONDS)
		. = ..()
		if(. == COMPONENT_INCOMPATIBLE || length(image_list) == 0)
			return .
		src.image_list = image_list
		src.image_prob = image_prob
		src.image_time = image_time

	do_mob_tick(mob, mult)
		if(probmult(image_prob))
			//pick a non dense turf in view
			var/list/turf/potentials = list()
			for(var/turf/T in view(parent_mob))
				if(!T.density)
					potentials += T
			var/turf/halluc_loc = pick(potentials)
			var/image/halluc = new /image()
			var/image/copyfrom = pick(src.image_list)
			halluc.appearance = copyfrom.appearance
			halluc.loc = halluc_loc
			parent_mob.client?.images += halluc
			SPAWN_DBG(src.image_time SECONDS)
				qdel(halluc)
		. = ..()

	CheckDupeComponent(timeout, image_list, image_prob, image_time)
		if(image_list ~= src.image_list) //this is the same hallucination, just update timeout and prob, time
			if(timeout == -1)
				src.ttl = timeout
			else if(src.ttl != -1)
				src.ttl = world.time + timeout SECONDS //reset timeout
			src.image_prob = image_prob
			src.image_time = image_time
			return TRUE //no duplicate
		else
			return FALSE //create a new hallucination

//#########################################################
//                    FAKE ATTACK
//#########################################################

/// Fake attack - hallucinate being attacked by something
/datum/component/hallucination/fake_attack
	var/list/image_list
	var/list/name_list
	var/attacker_prob = 10
	var/max_attackers = 5
	var/attacker_list = list()

	Initialize(timeout=30, image_list=null, name_list=null, attacker_prob=10, max_attackers=5)
		.=..()
		if(. == COMPONENT_INCOMPATIBLE)
			return .
		src.image_list = image_list
		src.name_list = name_list
		src.attacker_prob = attacker_prob
		src.max_attackers = max_attackers

	do_mob_tick(mob, mult)
		//I know it's kinda gross, but whatever
		for(var/obj/fake_attacker/fakey in src.attacker_list)
			if(fakey.disposed)
				src.attacker_list -= fakey
		if(length(attacker_list) > src.max_attackers)
			return
		if(probmult(attacker_prob))
			var/obj/fake_attacker/F
			var/image/halluc
			var/mob/attack_target = parent_mob
			if(isnull(image_list)) //if not specified, let's do a 50/50 of critters or humans
				var/list/possible_clones = new/list()
				var/list/possible_targets = new/list()
				for(var/mob/living/carbon/human/H in mobs)
					if (GET_DIST(H,parent_mob) < 10)
						possible_targets += H
					if (H.stat || H.lying || H.dir == NORTH) continue
					possible_clones += H
				possible_targets = possible_targets - parent_mob
				if(prob(60) && length(possible_targets))
					attack_target = pick(possible_targets)
				if(prob(50) && length(possible_clones)) //try for a human fake attacker
					var/mob/living/carbon/human/clone = null
					var/clone_weapon = null
					clone = pick(possible_clones)

					if (clone.l_hand)
						clone_weapon = clone.l_hand.name
					else if (clone.r_hand)
						clone_weapon = clone.r_hand.name

					F = new /obj/fake_attacker(attack_target.loc, attack_target, parent_mob)

					F.name = clone.name
					F.weapon_name = clone_weapon
					halluc = image(clone,F)
					parent_mob.client?.images += halluc
				else //try for a predefined critter fake attacker
					var/faketype = pick(concrete_typesof(/obj/fake_attacker) - /obj/fake_attacker) //all but the base type
					F = new faketype(attack_target.loc, attack_target, parent_mob)

			else //image list isn't null, so create a fake attacker with that image
				if(prob(60))
					var/list/possible_targets = new/list()
					for(var/mob/living/carbon/human/H in orange(8,parent_mob))
						possible_targets += H
					if(length(possible_targets))
						attack_target = pick(possible_targets)
				F = new /obj/fake_attacker(attack_target.loc, attack_target, parent_mob)
				F.name = "attacker"
				halluc = image(pick(image_list), F)
				parent_mob.client?.images += halluc

			if(!isnull(name_list))
				F.name = pick(name_list)
			src.attacker_list += F
		..()

	CheckDupeComponent(timeout, image_list, name_list, attacker_prob, max_attackers)
		if(image_list ~= src.image_list && name_list ~= src.name_list) //this is the same hallucination, just update timeout and prob
			if(timeout == -1)
				src.ttl = timeout
			else if(src.ttl != -1)
				src.ttl = world.time + timeout SECONDS //reset timeout
			src.attacker_prob = attacker_prob
			src.max_attackers = max_attackers
			return TRUE //no duplicate
		else
			return FALSE //create a new hallucination

//#########################################################
//                 RANDOM IMAGE OVERRIDE
//#########################################################

/// Random image override - hallucinate an image on a filtered atom in view with prob per life tick, with an option to add as overlay or replace the icon
/datum/component/hallucination/random_image_override
	var/list/image_list
	var/image_prob = 10
	var/image_time = 20
	var/list/target_list
	var/range = 5
	var/override = TRUE
	var/visible_creation = TRUE

	Initialize(timeout=30, image_list=null, target_list=null, range=5, image_prob=10, image_time=20 SECONDS, override=TRUE, visible_creation=TRUE)
		. = ..()
		if(. == COMPONENT_INCOMPATIBLE || length(image_list) == 0 || length(target_list) == 0)
			return .
		src.image_list = image_list
		src.image_prob = image_prob
		src.image_time = image_time
		src.range = range
		src.target_list = target_list
		src.override = override
		src.visible_creation = visible_creation


	do_mob_tick(mob,mult)
		if(probmult(image_prob))
			//pick a non dense turf in view
			var/list/atom/potentials = list()
			if(src.visible_creation)
				for(var/atom/A in oview(parent_mob, src.range))
					for(var/type in src.target_list)
						if(istype(A, type))
							potentials += A
			else
				for(var/atom/A in (orange(parent_mob, src.range) - oview(parent_mob, src.range)))
					for(var/type in src.target_list)
						if(istype(A, type))
							potentials += A
			if(!length(potentials)) return
			var/atom/halluc_loc = pick(potentials)
			var/image/halluc = new /image()
			var/image/copyfrom = pick(src.image_list)
			halluc.appearance = copyfrom.appearance
			halluc.loc = halluc_loc
			halluc.override = src.override
			parent_mob.client?.images += halluc
			SPAWN_DBG(src.image_time SECONDS)
				qdel(halluc)
		. = ..()

	CheckDupeComponent(timeout, image_list, target_list, range, image_prob, image_time, override)
		if(image_list ~= src.image_list && src.target_list ~= target_list) //this is the same hallucination, just update timeout and prob, time
			if(timeout == -1)
				src.ttl = timeout
			else if(src.ttl != -1)
				src.ttl = world.time + timeout SECONDS //reset timeout
			src.range = range
			src.image_prob = image_prob
			src.image_time = image_time
			src.override = override
			return TRUE //no duplicate
		else
			return FALSE //create a new hallucination

//#########################################################
//                    SUPPORTING CAST
//#########################################################


/datum/hallucinated_sound
	///The sound file to play
	var/path
	///Max number of times to play it
	var/max_count
	///Min number of times to play it
	var/min_count
	///Delay between each play
	var/delay
	///Pitch to play it at
	var/pitch
	///Volume to play it at
	var/volume

	New(path, min_count = 1, max_count = 1, delay = 0, pitch = 1, volume = 100)
		..()
		src.path = path
		src.min_count = min_count
		src.max_count = max_count
		src.delay = delay
		src.pitch = pitch
		src.volume = volume

	///Play the sound to a mob from a location
	proc/play(var/mob/mob, var/atom/location)
		SPAWN_DBG(0)
			for (var/i = 1 to rand(src.min_count, src.max_count))
				mob.playsound_local(location, src.path, src.volume, 1, pitch = src.pitch)
				sleep(src.delay)

/obj/fake_attacker
	icon = null
	icon_state = null
	var/fake_icon = 'icons/mob/critter.dmi'
	var/fake_icon_state = ""
	name = ""
	desc = ""
	density = 0
	anchored = ANCHORED
	opacity = 0
	flags = USEDELAY
	var/mob/my_target = null
	var/mob/my_hallucinator = null
	var/weapon_name = null
	///Does this hallucination constantly whack you
	var/should_attack = TRUE
	event_handler_flags = USE_FLUID_ENTER

	proc/get_name()
		return src.fake_icon_state

	pig
		fake_icon = 'icons/mob/hallucinations.dmi'
		fake_icon_state = "pig"
		get_name()
			return pick("pig", "DAT FUKKEN PIG")
	/*spider
		fake_icon_state = "big_spide"
		get_name()
			return pick("giant black widow", "aw look a spider", "OH FUCK A SPIDER")*/
	slime
		fake_icon = 'icons/mob/hallucinations.dmi'
		fake_icon_state = "slime"
		get_name()
			return pick("red slime", "some gooey thing", "ANGRY CRIMSON POO")
	shambler
		fake_icon = 'icons/mob/hallucinations.dmi'
		fake_icon_state = "shambler"
		get_name()
			return pick("shambler", "strange creature", "OH GOD WHAT THE FUCK IS THAT THING?")
	legworm
		fake_icon_state = "legworm"
	handspider
		fake_icon_state = "handspider"

	eyespider
		fake_icon_state = "eyespider"
	buttcrab
		fake_icon_state = "buttcrab"
		should_attack = FALSE
	bat
		fake_icon_state = "bat"
		get_name()
			return pick("bat", "batty", "the roundest possible bat", "the giant bat that makes all of the rules")
	snake
		fake_icon_state = "snake_green"
		get_name()
			return pick("snek", "WHY DID IT HAVE TO BE SNAKES?!", "rattlesnake", "OH SHIT A SNAKE")
	/*scorpion
		fake_icon_state = "spacescorpion"
		get_name()
			return "space scorpion"*/
	aberration
		fake_icon_state = "aberration"
		should_attack = FALSE
		get_name()
			return "transposed particle field"
	frog
		fake_icon_state = "frog"
		should_attack = FALSE

	disposing()
		my_target = null
		my_hallucinator = null
		. = ..()

/obj/fake_attacker/attack_hand(mob/M, params)
	src.Attackby(null, M, params)

/obj/fake_attacker/attackby(obj/item/W, mob/M, params, is_special)
	if(M != src.my_hallucinator)
		return
	M.a_intent = INTENT_HARM // not gonna be nice to the hallucinations... or the people beneath
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.check_for_intent_trigger()
		H.hud.update_intent()
	for(var/mob/living/crossfire in get_turf(src))
		if(W)
			crossfire.Attackby(W, M, params, is_special)
		else
			crossfire.Attackhand(M, params)
		M.lastattacked = src
		return
	M.lastattacked = src
	for(var/mob/witness in oviewers(world.view,my_hallucinator))
		boutput(witness, SPAN_ALERT("<B>[my_hallucinator] flails around wildly[W ? " with [W]" : ""].</B>"))
	if(W)
		if (!W.hide_attack)
			attack_particle(M,src,TRUE)
			attack_twitch(M)
		boutput(M,"<span class='combat'><B>[M] hits [src] with [W]!</B></span>")
		if (narrator_mode)
			my_hallucinator.playsound_local(my_target.loc, 'sound/vox/weapon.ogg', 40, 1)
		else
			M.playsound_local(M.loc, W.hitsound, 50, 1)
		if((W.hit_type == DAMAGE_CUT || W.hit_type == DAMAGE_STAB) && prob(50))
			if (!locate(/obj/overlay/fake) in src.loc)
				fake_blood(M,src.loc)
	else
		attack_particle(M,src,TRUE)
		attack_twitch(M)
		if (narrator_mode)
			M.playsound_local(M.loc, 'sound/vox/hit.ogg', 50, 1, -1)
		else
			M.playsound_local(M.loc, pick(sounds_punch), 50, 1, -1)
		boutput(M,"<span class='alert'><B>[M] [M.punchMessage] [src]!</B></span>")


/obj/fake_attacker/Crossed(atom/movable/M)
	..()
	if (M == my_hallucinator)
		step_away(src,my_hallucinator,2)
		if (prob(30))
			for(var/mob/witness in oviewers(world.view, my_hallucinator))
				boutput(witness, "<span class='alert'><B>[my_hallucinator] stumbles around.</B></span>")


/obj/fake_attacker/New(location, target, hallucinator)
	..()
	SPAWN_DBG(30 SECONDS)
		qdel(src)
	src.name = src.get_name()
	src.my_target = target
	src.my_hallucinator = hallucinator ? hallucinator : src.my_target
	if (src.fake_icon && src.fake_icon_state)
		var/image/image = image(icon = src.fake_icon, loc = src, icon_state = src.fake_icon_state)
		image.override = TRUE
		src.my_hallucinator << image
	step_away(src,my_target,2)
	SPAWN_DBG(0.3 SECONDS)
		process()

/obj/fake_attacker/proc/process()
	if (!my_target || !my_hallucinator)
		qdel(src)
		return
	if (BOUNDS_DIST(src, my_target) > 0)
		if(prob(85)) // outrun your nightmares
			step_towards(src,my_target)
	else
		if (src.should_attack && prob(70) && isturf(my_target.loc) && !ON_COOLDOWN(src, "fake_attack_cooldown", rand(1 SECOND, 2 SECONDS)))
			if (weapon_name)
				if (narrator_mode)
					my_hallucinator.playsound_local(my_target.loc, 'sound/vox/weapon.ogg', 40, 0)
				else
					my_hallucinator.playsound_local(my_target.loc, "sound/impact_sounds/Generic_Hit_[rand(1, 3)].ogg", 40, 1)
				my_hallucinator.show_message("<span class='alert'><B>[my_target] has been attacked with [weapon_name] by [src.name] </B></span>", 1)
				if (prob(10))
					if (!locate(/obj/overlay/fake) in my_target.loc)
						fake_blood(my_hallucinator,my_target.loc)
			else
				if (narrator_mode)
					my_hallucinator.playsound_local(my_target.loc, 'sound/vox/hit.ogg', 40, 0)
				else
					my_hallucinator.playsound_local(my_target.loc, pick(sounds_punch), 40, 1)
				my_hallucinator.show_message("<span class='alert'><B>[src.name] has punched [my_target]!</B></span>", 1)
			attack_twitch(src)

	if (src.should_attack && prob(5)) step_away(src,my_target,2)
	SPAWN_DBG(0.3 SECONDS)
		src.process()

/proc/fake_blood(var/mob/target,var/location,var/fake_blood_color)
	var/obj/overlay/fake/O = new/obj/overlay/fake(location ? location : target.loc)
	O.plane = PLANE_NOSHADOW_BELOW
	O.name = "blood"
	if (!fake_blood_color)
		fake_blood_color = DEFAULT_BLOOD_COLOR
		var/mob/living/L = target
		if (istype(L))
			fake_blood_color = L.blood_color
	var/image/I = image('icons/obj/decals/blood.dmi',O,"floor[rand(1,7)]",O.dir,1)
	I.color = fake_blood_color
	target << I
	SPAWN_DBG(30 SECONDS)
		qdel(O)

/proc/fake_attack(var/mob/target,var/mob/hallucinator)
	var/list/possible_clones = new/list()
	var/mob/living/carbon/human/clone = null
	var/clone_weapon = null

	for(var/mob/living/carbon/human/H in mobs)
		if (H.stat || H.lying || H.dir == NORTH) continue
		possible_clones += H

	if (!possible_clones.len) return
	clone = pick(possible_clones)

	if (clone.l_hand)
		clone_weapon = clone.l_hand.name
	else if (clone.r_hand)
		clone_weapon = clone.r_hand.name

	var/obj/fake_attacker/F = new/obj/fake_attacker(target.loc, target, hallucinator)

	F.name = clone.name
	F.weapon_name = clone_weapon

	var/image/O = image(clone,F)
	hallucinator << O

