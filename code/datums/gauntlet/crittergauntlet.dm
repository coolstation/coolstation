#define GAUNTLET_STANDBY 0
#define GAUNTLET_IN_STAGING 1
#define GAUNTLET_WAVE_FINISHED 2
#define GAUNTLET_WAVE_STARTED 3

// CRITTERGAUNTLETTODO - The big issue with the critter gauntlet right now is that nearly all object critters are trivial to kill
// so the gauntlet is largely just boringly easy, but also takes a long time to progress through (50 waves? really?)
// Assuming that a move to mobcritters is out of our team's scope, we should probably at least buff many of the current ones
// And frankly I think less waves (with steeper difficulty scaling) would be good too. I think it might take over half and hour to run the gauntlet
// Also, overlapping waves if the current one is going on too long? Keep clearing enemies or get overrun, chump.


/area/gauntlet
	name = "The Gauntlet"
	icon_state = "dk_yellow"
	virtual = 1

	Entered(var/atom/A)
		..()
		if (!ismob(A))
			return
		if (gauntlet_controller.state == GAUNTLET_IN_STAGING)
			for (var/mob/living/L in gauntlet_controller.staging)
				return
			//No other mobs in the staging room, we can start
			gauntlet_controller.finishStaging()

/area/gauntlet/staging
	name = "Gauntlet Staging Area"
	icon_state = "purple"
	virtual = 1
	ambient_light = "#bfbfbf"

	Entered(var/atom/movable/A)
		..()
		// CRITTERGAUNTLETTODO - teleport out instead thanks
		if (isliving(A))
			if (gauntlet_controller.state >= 2)
				A:gib()

/area/gauntlet/viewing
	name = "Gauntlet Spectator's Area"
	icon_state = "green"
	virtual = 1
	ambient_light = "#bfbfbf"

/mob/proc/is_near_gauntlet()
	var/area/A = get_area(src)
	if (istype(A, /area/gauntlet))
		return 1
	if (ismob(eye))
		var/mob/M = eye
		if (M.is_near_gauntlet())
			return 1
	else if (istype(eye, /obj/observable/gauntlet))
		return 1
	return 0

/mob/proc/is_in_gauntlet()
	var/area/A = get_area(src)
	//for clarity, the base gauntlet area is used for the arena grounds. the staging and viewing areas are subtypes.
	if (A?.type == /area/gauntlet)
		return 1
	return 0

/obj/stagebutton
	name = "Gauntlet Staging Button"
	desc = "By pressing this button, you begin the staging process. No more new attendees will be accepted."
	anchored = 1
	density = 0
	opacity = 0
	icon = 'icons/effects/VR.dmi'
	icon_state = "doorctrl0"

	attack_hand(var/mob/M)
		if (gauntlet_controller.state != GAUNTLET_STANDBY)
			return
		//uncomment if we ever have a problem with this again I just wanna test
		/*if (ticker.round_elapsed_ticks < 3000)
			boutput(usr, "<span class='alert'>You may not initiate the Gauntlet before 5 minutes into the round.</span>")
			return*/
		if (alert("Start the Gauntlet? No more players will be given admittance to the staging area!",, "Yes", "No") == "Yes")
			//presumably a check to prevent multiple players to
			if (gauntlet_controller.state != GAUNTLET_STANDBY)
				return
			gauntlet_controller.beginStaging()

/obj/adventurepuzzle/triggerable/light/gauntlet
	on_brig = 7
	on_cred = 1
	on_cgreen = 1
	on_cblue = 1

	New()
		..()
		on()

/datum/arena/gauntletController
	var/area/gauntlet/staging/staging
	var/area/gauntlet/viewing/viewing
	var/area/gauntlet/gauntlet
	var/list/spawnturfs = list()

	var/list/possible_waves = list()
	var/list/possible_events = list()
	var/list/possible_drops = list()
	var/list/moblist = list()

	var/list/current_waves = list()
	var/datum/gauntletEvent/current_event = null
	var/datum/gauntletWave/fallback/fallback

	var/list/critters_left = list()

	var/current_match_id = 0
	var/difficulty = 0
	var/state = GAUNTLET_STANDBY
	var/players = 0
	var/current_level = 0
	var/next_level_at = 0
	var/waiting = 0

	var/score = 0
	var/moblist_names = ""

	proc/announceAll(var/message, var/title = "Gauntlet update")
		var/rendered = "<span style='font-size: 1.5em; font-weight:bold'>[title]</span><br><br><span style='font-weight:bold;color:blue'>[message]<br>"
		for (var/mob/M in staging)
			boutput(M, rendered)
		for (var/mob/M in viewing)
			boutput(M, rendered)
		for (var/mob/M in gauntlet)
			boutput(M, rendered)
		for (var/mob/M in mobs)
			LAGCHECK(LAG_LOW)
			if (ismob(M.eye) && M.eye != M)
				var/mob/N = M.eye
				if (N.is_near_gauntlet())
					boutput(M, rendered)
			else if (istype(M.eye, /obj/observable/gauntlet))
				boutput(M, rendered)

	proc/beginStaging()
		if (state != 0)
			return
		state = GAUNTLET_IN_STAGING
		moblist.len = 0
		moblist_names = ""
		//Lock players into the staging room
		for (var/obj/machinery/door/poddoor/buff/staging/S in staging)
			SPAWN_DBG(0)
				S.close()
		var/mobcount = 0
		for (var/mob/living/M in staging)
			mobcount++
			moblist += M
			//Why are we collecting names at this point? finishStaging redoes this.
			if (moblist_names != "")
				moblist_names += ", "
			var/thename = M.real_name
			if (istype(M, /mob/living/carbon/human/virtual))
				var/mob/living/L = M:body
				if (L)
					thename = L.real_name
				else
					thename = copytext(M.real_name, 9)
			moblist_names += thename
			if (M.client)
				moblist_names += " ([M.client.key])"
			// CRITTERGAUNTLETTODO - straight up deleting shit from mobs will break references, redo this bit
			// Delete anything players may be taking into the arena that gives them an advantage.
			// (fun fact: your butt gets clobbered here, cause it's a hat)
			for (var/obj/item/I in M)
				if (!istype(I, /obj/item/clothing/under) && !istype(I, /obj/item/clothing/shoes) && !istype(I, /obj/item/parts) && !istype(I, /obj/item/organ) && !istype(I, /obj/item/skull))
					qdel(I)
		var/default_table = null
		var/list/tables = list()
		for (var/obj/table/T in staging)
			tables += T
		if (tables.len)
			default_table = pick(tables)
		else
			default_table = locate(/turf/floor) in staging
		for (var/i = 1, i <= mobcount, i++)
			var/target = default_table
			if (tables.len)
				target = pick(tables)
			if (i > moblist.len)
				spawnGear(get_turf(target), null)
			else
				spawnGear(get_turf(target), moblist[i])
			tables -= target
		for (var/i = 1, i <= mobcount, i++)
			var/target = default_table
			if (tables.len)
				target = pick(tables)
			spawnMeds(get_turf(target))
			tables -= target
		announceAll("The Critter Gauntlet Arena has now entered staging phase. No more players may enter the game area. The game will start once all players enter the gauntlet chamber.")
		players = mobcount
		current_level = 1
		for (var/datum/gauntletDrop/D in possible_drops)
			D.used = 0
		current_match_id++
		var/spawned_match_id = current_match_id
		//open doors from staging room to the arena (which are in the staging area atm, but I guess may have been in the gauntlet area previously?)
		SPAWN_DBG(0)
			for (var/obj/machinery/door/poddoor/buff/gauntlet/S in gauntlet)
				SPAWN_DBG(0)
					S.open()
			for (var/obj/machinery/door/poddoor/buff/gauntlet/S in staging)
				SPAWN_DBG(0)
					S.open()
		allow_processing = 1
		SPAWN_DBG(2 MINUTES)
			if (state == GAUNTLET_IN_STAGING && current_match_id == spawned_match_id)
				announceAll("Game did not start after 2 minutes. Resetting arena.")
				resetArena()

	proc/finishStaging()
		if (state == GAUNTLET_WAVE_FINISHED)
			return
		state = GAUNTLET_WAVE_FINISHED
		SPAWN_DBG(0)
			//close doors from staging room to the arena
			for (var/obj/machinery/door/poddoor/buff/gauntlet/S in gauntlet)
				SPAWN_DBG(0)
					S.close()
			for (var/obj/machinery/door/poddoor/buff/gauntlet/S in staging)
				SPAWN_DBG(0)
					S.close()
			//collect the names of all players.
			for (var/mob/living/M in gauntlet)
				if (M in moblist)
					continue
				moblist += M
				if (moblist_names != "")
					moblist_names += ", "
				var/thename = M.real_name
				if (istype(M, /mob/living/carbon/human/virtual))
					var/mob/living/L = M:body
					if (L)
						thename = L.real_name
					else //I'm not convinced at present that this ever gets used, you either have a meat or ghost body and your meatbod getting gibbed while in VR isn't handled gracefully.
						thename = copytext(M.real_name, 9) //crops the "virtual " from your mob's name.
				moblist_names += thename
				if (M.client)
					moblist_names += " ([M.client.key])"
			logTheThing("debug", null, null, "<b>Marquesas/Critter Gauntlet</b>: Starting arena game with players: [moblist_names]")
		announceAll("The Critter Gauntlet Arena game is now in progress. The first level will begin soon.")
		next_level_at = ticker.round_elapsed_ticks + 300

	process()
		if (state == GAUNTLET_WAVE_FINISHED)
			if (ticker.round_elapsed_ticks > next_level_at)
				startWave()
		else if (state == GAUNTLET_WAVE_STARTED)
			if (current_event)
				current_event.process()
			if (current_waves.len)
				if (waiting <= 0)
					var/datum/gauntletWave/wave = current_waves[1]
					if (wave.spawnIn(current_event))
						current_waves.Cut(1,2)
						if (current_waves.len)
							wave = current_waves[1]
							applyDifficulty(wave)
							waiting = 8
				else
					waiting--
			else
				if (waiting <= 0)
					var/live = 0 //# of enemies
					var/pc = 0 //# of combatants
					for (var/obj/critter/C in gauntlet)
						if (!C.alive)
							showswirl(get_turf(C))
							qdel(C)
						else
							live++
					if (!live)
						finishWave()
					for (var/mob/living/M in gauntlet)
						if (!isdead(M) && M.client)
							pc++
					for (var/obj/O in gauntlet)
						for (var/mob/living/M in O)
							if (!isdead(M) && M.client)
								pc++
					if (!pc)
						state = GAUNTLET_STANDBY
					waiting = 8
				else
					waiting--

		if (state == GAUNTLET_STANDBY)
			resetArena()

	var/resetting = 0
	proc/resetArena()
		if (resetting)
			return
		resetting = 1
		allow_processing = 0
		announceAll("The Critter Gauntlet match concluded at level [current_level].")
		if (current_level > 50)
			var/command_report = "A Critter Gauntlet match has concluded at level [current_level]. Congratulations to: [moblist_names]."
			for_by_tcl(C, /obj/machinery/communications_dish)
				C.add_centcom_report("[command_name()] Update", command_report)

			command_alert(command_report, "Critter Gauntlet match finished")
		statlog_gauntlet(moblist_names, score, current_level)

		// CRITTERGAUNTLETTODO - pools of blood aren't removed
		// Clear the arena and staging room of everything
		SPAWN_DBG(0)
			for (var/obj/item/I in staging)
				qdel(I)
			for (var/obj/item/I in gauntlet)
				qdel(I)
			for (var/obj/artifact/A in gauntlet)
				qdel(A)
			for (var/obj/critter/C in gauntlet)
				qdel(C)
			for (var/obj/machinery/bot/B in gauntlet)
				qdel(B)
			for (var/mob/living/M in gauntlet)
				M.gib() //CRITTERGAUNTLETTODO - maybe teleport players out (and give them a full heal) instead of kicking folks out of VR entirely
			for (var/mob/living/M in staging)
				M.gib()
			for (var/obj/decal/D in gauntlet)
				if (!istype(D, /obj/decal/teleport_swirl))
					qdel(D)

			for (var/obj/machinery/door/poddoor/buff/staging/S in staging)
				SPAWN_DBG(0)
					S.open()
			for (var/obj/machinery/door/poddoor/buff/gauntlet/S in gauntlet)
				SPAWN_DBG(0)
					S.close()
			for (var/obj/machinery/door/poddoor/buff/gauntlet/S in staging)
				SPAWN_DBG(0)
					S.close()

		if (current_event)
			current_event.tearDown()
			current_event = null
		current_waves.len = 0
		current_level = 0
		moblist.len = 0
		moblist_names = ""
		score = 0
		state = GAUNTLET_STANDBY
		players = 0
		resetting = 0

	proc/spawnGear(var/turf/target, var/mob/forwhom)
		new /obj/item/storage/backpack/NT(target)
		var/suittype = pick(childrentypesof(/obj/item/clothing/suit/armor/tdome))
		new suittype(target)
		var/list/masks = list(/obj/item/clothing/mask/batman, /obj/item/clothing/mask/clown_hat, /obj/item/clothing/mask/horse_mask, /obj/item/clothing/mask/moustache, /obj/item/clothing/mask/gas/swat, /obj/item/clothing/mask/owl_mask, /obj/item/clothing/mask/hunter, /obj/item/clothing/mask/skull, /obj/item/clothing/mask/spiderman)
		var/masktype = pick(masks)
		new masktype(target)
		new /obj/item/gun/energy/laser_gun/virtual(target)
		new /obj/item/extinguisher/virtual(target)
		new /obj/item/card/id/gauntlet(target, forwhom)
		// CRITTERGAUNTLETTODO - 2/3rds chance that the key only works with one type of artifact and with how rare artifact spawns are that makes them worthless.
		// Also, eldritch ones activate faults which might suck?
		var/obj/item/artifact/activator_key/A = new /obj/item/artifact/activator_key(target)
		SPAWN_DBG(2.5 SECONDS)
			A.name = "Artifact Activator Key"
			//make this thing potentially useful
			var/datum/artifact/activator_key/AD = A.associated_datum
			AD.corrupting = FALSE
			AD.universal = TRUE

	proc/spawnMeds(var/turf/target)
		for (var/medtype in list(/obj/item/storage/firstaid/vr/regular, /obj/item/storage/firstaid/vr/fire, /obj/item/storage/firstaid/vr/brute, /obj/item/storage/firstaid/vr/toxin, /obj/item/reagent_containers/pill/vr/mannitol, /obj/item/storage/box/donkpocket_w_kit/vr))
			new medtype(target)

	proc/increaseCritters(var/obj/critter/C)
		var/name = initial(C.name)
		if (!(name in critters_left))
			critters_left += name
			critters_left[name] = 0
		critters_left[name] += 1

	proc/decreaseCritters(var/obj/critter/C)
		var/name = initial(C.name)
		if (!(name in critters_left))
			return
		critters_left[name] -= 1
		if (critters_left[name] <= 0)
			critters_left -= name

	New()
		..()
		SPAWN_DBG(0.5 SECONDS)
			viewing = locate() in world
			staging = locate() in world
			for (var/area/G in world)
				LAGCHECK(LAG_LOW)
				if (G.type == /area/gauntlet)
					gauntlet = G
					break
			if (!gauntlet) return //unit teeeests
			for (var/turf/T in gauntlet.turfs)
				if (!T.density)
					spawnturfs += T

			for (var/tp in childrentypesof(/datum/gauntletEvent))
				possible_events += new tp()

			for (var/tp in childrentypesof(/datum/gauntletDrop))
				possible_drops += new tp()

			for (var/tp in childrentypesof(/datum/gauntletWave) - /datum/gauntletWave/fallback)
				possible_waves += new tp()

			fallback = new()

	proc/dropIsPossible(var/datum/gauntletDrop/drop, var/points)
		if (drop.used)
			return 0
		if (current_level < drop.minimum_level)
			return 0
		if (current_level > drop.maximum_level)
			return 0
		// CRITTERGAUNTLETTODO - Drop costs are zero or negative, so this doesn't do anything
		if (points < drop.point_cost)
			return 0
		if (!prob(drop.probability))
			return 0
		return 1

	proc/startWave()
		if (state == GAUNTLET_WAVE_STARTED)
			return
		state = GAUNTLET_WAVE_STARTED

		calculateDifficulty()

		//This is kind of a weird formula. Having put it in a graphing program it produces a very slow (imperceptible level-to-level) increase with a jump every 10 levels
		var/points = 2.5 + (floor(current_level * 0.1) * 1.5) + ((current_level % 10) / 20)
		logTheThing("debug", null, null, "<b>Marquesas/Critter Gauntlet:</b> On level [current_level]. Spending [points] points, composed of 1 base, [floor(current_level * 0.1) * 1.5] major and [(current_level % 10) / 20] minor.")

		var/datum/gauntletEvent/candidate = pick(possible_events)
		if (current_level >= candidate.minimum_level && points > candidate.point_cost && prob(candidate.probability))
			current_event = candidate
			points -= candidate.point_cost
		else
			current_event = null

		var/datum/gauntletDrop/drop = pick(possible_drops)
		var/retries = 0
		while (!dropIsPossible(drop, points) && retries < 25)
			drop = pick(possible_drops)
			retries++
		if (retries < 25)
			drop.doDrop()
			//drops can have negative point cost making this net positive, so getting drops often means there's more points for picking critters (harder)
			points -= drop.point_cost
		else
			drop = null

		current_waves.len = 0
		var/waves_this_level = max(1, current_level + rand(-1, 1))
		for (var/i = 1, i <= waves_this_level, i++)
			var/list/choices = possible_waves.Copy()
			while (choices.len)
				var/datum/gauntletWave/wave = pick(choices)
				//this prevents getting duplicates of the same wave type in one level.
				choices -= wave
				if (wave.point_cost < points)
					points -= wave.point_cost
					current_waves += wave
					break

		if (!current_waves.len)
			current_waves += fallback

		if (current_event)
			current_event.setUp()

		applyDifficulty(current_waves[1])

		var/announcement = "Starting level [current_level] now!"
		if (current_event)
			announcement += "<br>Special event this level: [current_event]."
		if (drop)
			announcement += "<br>Supplies this level: [drop]."
		announceAll(announcement)
		waiting = 0

	proc/finishWave()
		if (state == GAUNTLET_WAVE_FINISHED)
			return
		state = GAUNTLET_WAVE_FINISHED

		if (current_event)
			current_event.tearDown()
		//I think this is cleaning up critter drops that aren't prevented by the critter's code
		for (var/obj/decal/D in gauntlet)
			if (!istype(D, /obj/decal/teleport_swirl))
				qdel(D)
		for (var/obj/item/parts/human_parts/P in gauntlet)
			if (isturf(P.loc))
				qdel(P)
		for (var/obj/item/electronics/E in gauntlet)
			qdel(E)

		current_level++
		current_waves.len = 0
		critters_left.len = 0
		current_event = null
		next_level_at = ticker.round_elapsed_ticks + 150
		announceAll("Level [current_level - 1] is finished. Next level starting in 15 seconds!")

	//each level effectively add 0.05 to the difficulty, so at level 12 difficulty is double that of level 1 (1.1 vs 0.55)
	//difficulty scales linearly once
	//For 1-3 player difficulty ranges it's 0.55 at level 1, to 3 at level 50

	proc/calculateDifficulty()
		difficulty = 0.5 + (current_level / 20) * max(1, players / 3)

	proc/applyDifficulty(var/datum/gauntletWave/wave)
		wave.count = initial(wave.count)

		// CRITTERGAUNTLETTODO - see about rebalancing this? It seems like most of the gauntlet plays out spawning less critters
		// than are listed in the wave datums, which is unintuitive for coders. (wave 20 for 1-3 players)
		// OTOH health should then scale slower, cause mashing a 15x critter to death isn't fun.
		// Something with logarhitmic growth maybe

		//Anyway, the [rand(-10, 10) * 0.1] basically amounts to "plus/minus one critter randomly", except given the flooring after this it's probably biased downwards
		wave.count *= difficulty / 1.5 + rand(-10, 10) * 0.1
		//spawn at least 1 thing (note this actually floors the count)
		wave.count = floor(max(1, wave.count))
		//The same maths, except the lower limit is 1/10th health.
		wave.health_multiplier = max(difficulty / 1.5 + rand(-10, 10) * 0.1, 0.1)

	//Text that goes in the status window
	proc/Stat()
		stat(null, "")
		stat(null, "--- GAUNTLET ---")
		switch (state)
			if (GAUNTLET_STANDBY)
				stat(null, "No match is currently in progress.")
			if (GAUNTLET_IN_STAGING)
				stat(null, "Match is currently in setup stage.")
				stat(null, "Registered players: [players]")
			if (GAUNTLET_WAVE_FINISHED)
				stat(null, "Next level starts in [dstohms(next_level_at - ticker.round_elapsed_ticks)].")
				stat(null, "Next level: [current_level]")
			if (GAUNTLET_WAVE_STARTED)
				stat(null, "Current difficulty: [difficulty]")
				stat(null, "Current level: [current_level]")
				if (current_event)
					stat(null, "Special event: [current_event]")
				stat(null, "")
				if (current_waves.len)
					stat(null, "Remaining waves this level: ")
					if (current_level < 50)
						for (var/i = 1, i <= current_waves.len, i++)
							var/datum/gauntletWave/W = current_waves[i]
							stat(null, "- [W.name]")
					else if (current_level < 100)
						for (var/i = 1, i <= current_waves.len, i++)
							stat(null, "- ???")
					else
						stat(null, "No information")
				else
					stat(null, "Critters in gauntlet: ")
					if (current_level < 50)
						for (var/name in critters_left)
							if (critters_left[name])
								stat(null, "- [critters_left[name]] [name][critters_left[name] > 1 ? "s" : null]")
					else if (current_level < 100)
						var/sum = 0
						for (var/name in critters_left)
							sum += critters_left[name]
						stat(null, "- [sum] critter[sum > 1 ? "" : null]")
					else
						stat(null, "No information")
		stat(null, "--- GAUNTLET ---")
		stat(null, "")


var/global/datum/arena/gauntletController/gauntlet_controller = new()

/obj/observable
	invisibility = 101
	name = "Observable"
	desc = "observable"
	anchored = 1
	density = 0
	opacity = 0
	icon = 'icons/ui/buildmode.dmi'
	icon_state = "build" // don't judge me
	var/obj/machinery/camera/cam
	var/has_camera = 0
	var/cam_network = null

	New()
		..()
		if (has_camera)
			src.cam = new /obj/machinery/camera(src)
			src.cam.c_tag = src.name
			src.cam.network = cam_network
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	gauntlet
		name = "The Gauntlet Arena"
		has_camera = 1
		cam_network = "Zeta"

	colosseum
		name = "The Colosseum Arena"
		has_camera = 1
		cam_network = "Zeta"

/datum/gauntletDrop
	var/name = "Drop"
	var/point_cost = 0
	var/minimum_level = 0
	var/maximum_level = 250
	var/probability = 45
	var/list/supplies = list()
	var/min_percent = 0.2
	var/max_percent = 0.7
	var/max_amount = -1
	var/only_once = 0
	var/used = 0

	proc/doDrop()
		var/amount = max(1, rand(floor(gauntlet_controller.players * min_percent), floor(gauntlet_controller.players * max_percent)))
		if (max_amount > 0)
			amount = min(amount, max_amount)
		for (var/i = 1, i <= amount, i++)
			var/ST = pick(supplies)
			var/turf/T = pick(gauntlet_controller.spawnturfs)
			new ST(T)
			showswirl(T)

		if (only_once)
			used = 1

	artifact
		name = "A Handheld Artifact"
		minimum_level = 35
		supplies = list(/obj/item/gun/energy/artifact)
		doDrop()
			var/ST = supplies[1]
			var/T = pick(gauntlet_controller.spawnturfs)
			var/obj/O = new ST(T)
			showswirl(T)
			SPAWN_DBG(0.5 SECONDS)
				O.ArtifactActivated()

		forcewall
			minimum_level = 25
			supplies = list(/obj/item/artifact/forcewall_wand)

		melee
			minimum_level = 15
			supplies = list(/obj/item/artifact/melee_weapon)

	inactive_artifact
		name = "An Artifact"
		minimum_level = 20
		supplies = list(/obj/machinery/artifact/bomb, /obj/artifact/darkness_field, /obj/artifact/healer_bio, /obj/artifact/forcefield_generator, /obj/artifact/power_giver)
		max_amount = 1

	hamburgers
		name = "Hamburgers"
		minimum_level = 0
		maximum_level = 5
		min_percent = 0.5
		max_percent = 1
		supplies = list(/obj/item/reagent_containers/food/snacks/burger/vr)

	tinfoil
		name = "A Tinfoil Hat"
		minimum_level = 5
		max_amount = 1
		supplies = list(/obj/item/clothing/head/tinfoil_hat)

	incendiary
		name = "A High Range Incendiary Grenade"
		minimum_level = 5
		max_amount = 1
		supplies = list(/obj/item/chem_grenade/very_incendiary/vr)

	weapon_cache
		name = "Pile o' Weapons"
		min_percent = 0.6
		max_percent = 1.5
		point_cost = -3
		minimum_level = 20
		probability =  20
		supplies = list(/obj/item/chem_grenade/very_incendiary/vr, /* /obj/item/gun/kinetic/spes */, /obj/item/gun/energy/laser_gun/virtual)

	welding
		name = "Welders"
		point_cost = -1
		minimum_level = 5
		min_percent = 0.25
		max_percent = 0.75
		supplies = list(/obj/item/weldingtool/vr)

/*
	revolver
		name = "Revolvers"
		point_cost = -2
		minimum_level = 15
		min_percent = 0.25
		max_percent = 0.5
		supplies = list(/obj/item/gun/kinetic/revolver/vr)

	spes
		name = "SPES-12s"
		point_cost = -2
		minimum_level = 25
		min_percent = 0.25
		max_percent = 0.5
		supplies = list(/obj/item/gun/kinetic/spes)

	rifle
		name = "Hunting Rifles"
		point_cost = -2
		minimum_level = 25
		min_percent = 0.25
		max_percent = 0.5
		supplies = list(/obj/item/gun/kinetic/hunting_rifle)

	ak47
		name = "An AK47"
		point_cost = -2
		minimum_level = 45
		min_percent = 0.25
		max_percent = 0.5
		max_amount = 1
		supplies = list(/obj/item/gun/kinetic/ak47)
*/

	bfg
		name = "The BFG"
		point_cost = -3
		minimum_level = 45
		min_percent = 0.25
		max_percent = 0.5
		max_amount = 1
		only_once = 1
		supplies = list(/obj/item/gun/energy/bfg/vr)

	laser
		name = "Laser Guns"
		point_cost = -2
		probability = 100
		minimum_level = 15
		min_percent = 0.25
		max_percent = 0.5
		supplies = list(/obj/item/gun/energy/laser_gun/virtual)

	predlaser
		name = "Advanced Laser Guns"
		point_cost = -3
		minimum_level = 25
		min_percent = 0.25
		max_percent = 0.5
		supplies = list(/obj/item/gun/energy/laser_gun/pred/vr)

	axe
		name = "Energy Axes"
		point_cost = -2.5
		minimum_level = 35
		min_percent = 0.25
		max_percent = 0.5
		probability = 10
		supplies = list(/obj/item/axe/vr)

	sword
		name = "Energy Swords"
		point_cost = -2.5
		minimum_level = 25
		min_percent = 0.25
		max_percent = 0.5
		supplies = list(/obj/item/sword/vr)

	saw
		name = "Red Chainsaws"
		point_cost = -2.5
		minimum_level = 25
		min_percent = 0.25
		max_percent = 0.5
		supplies = list(/obj/item/saw/syndie/vr)

	defib
		name = "Defibrillator"
		point_cost = -1
		minimum_level = 10
		max_amount = 1
		supplies = list(/obj/item/robodefibrillator/vr)
		only_once = 1

	surgical
		name = "Surgical Tools"
		minimum_level = 15
		point_cost = -1
		supplies = list(/obj/item/reagent_containers/iv_drip/blood/vr, /obj/item/suture/vr, /obj/item/scalpel/vr, /obj/item/reagent_containers/food/drinks/bottle/vodka/vr)

	medkits
		name = "Medkits"
		point_cost = -2
		minimum_level = 15
		supplies = list(/obj/item/storage/firstaid/vr/regular)

	bb_medkits
		name = "Common Medkits"
		point_cost = -2
		minimum_level = 15
		supplies = list(/obj/item/storage/firstaid/vr/brute, /obj/item/storage/firstaid/vr/fire)

	special_medkits
		name = "Special Medkits"
		point_cost = -2
		minimum_level = 15
		supplies = list(/obj/item/storage/firstaid/vr/toxin, /obj/item/storage/firstaid/vr/oxygen, /obj/item/storage/firstaid/vr/brain, /obj/item/reagent_containers/emergency_injector/vr/calomel)

/datum/gauntletEvent
	var/name = "Event"
	var/point_cost = 0.5
	var/minimum_level = 0
	var/probability = 60

	proc/setUp()
	proc/process()
	proc/onSpawn(var/obj/critter/C)
	proc/tearDown()

	barricade
		name = "Maze"
		point_cost = 0
		minimum_level = 0

		setUp()
			var/list/q = gauntlet_controller.spawnturfs.Copy()
			shuffle_list(q)
			var/percentage = rand(25, 45) * 0.01
			q.len = floor(q.len * percentage)
			for (var/turf/T in q)
				new /obj/structure/woodwall/virtual(T)

		tearDown()
			for (var/obj/structure/woodwall/virtual/W in gauntlet_controller.gauntlet)
				qdel(W)

	regeneration
		name = "Heal Zone"
		point_cost = -1
		minimum_level = 10
		var/counter = 10

		setUp()
			for (var/turf/T in gauntlet_controller.gauntlet)
				if (!T.density)
					T.icon_state = "gauntfloorHearts"
					T.color = "#FF0000"
			counter = 10

		process()
			if (counter)
				counter--
			else
				for (var/mob/living/M in gauntlet_controller.gauntlet)
					M.HealDamage("All", 5, 5)
					//boutput(M, "<span class='notice'>A soothing wave of energy washes over you!</span>")
				counter = 10

		tearDown()
			for (var/turf/T in gauntlet_controller.gauntlet)
				T.icon_state = initial(T.icon_state)
				T.color = "#FFFFFF"

	chill
		name = "Cold Zone"
		point_cost = 2
		minimum_level = 25

		setUp()
			for (var/turf/T in gauntlet_controller.gauntlet)
				if (!T.density)
					T.icon_state = "gauntfloorSnow"
					T.color = "#00FFFF"

		process()
			for (var/mob/living/M in gauntlet_controller.gauntlet)
				M.bodytemperature = T0C - 100

		tearDown()
			for (var/turf/T in gauntlet_controller.gauntlet)
				T.icon_state = initial(T.icon_state)
				T.color = "#FFFFFF"

			for (var/mob/living/M in gauntlet_controller.gauntlet)
				M.bodytemperature = M.base_body_temp

	hot
		name = "Fire Zone"
		point_cost = 2
		minimum_level = 30

		setUp()
			for (var/turf/T in gauntlet_controller.gauntlet)
				if (!T.density)
					T.icon_state = "gauntfloorHeat"
					T.color = "#FF8800"

		process()
			for (var/mob/living/M in gauntlet_controller.gauntlet)
				M.bodytemperature = T0C + 120
				if (prob(10))
					if (!M.getStatusDuration("burning"))
						boutput(M, "<span class='alert'>You spontaneously combust!</span>")
					M.changeStatus("burning", 7 SECONDS)

		tearDown()
			for (var/turf/T in gauntlet_controller.gauntlet)
				T.icon_state = initial(T.icon_state)
				T.color = "#FFFFFF"

			for (var/mob/living/M in gauntlet_controller.gauntlet)
				M.bodytemperature = M.base_body_temp
				M.set_burning(0)

	void
		name = "Toxic Zone"
		point_cost = 0
		minimum_level = 0

		setUp()
			for (var/turf/T in gauntlet_controller.gauntlet)
				if (!T.density)
					T.icon_state = "gauntfloorSkulls"
					T.color = "#FF00FF"

		process()
			if (prob(20))
				for (var/mob/living/M in gauntlet_controller.gauntlet)
					M.TakeDamage("chest", 1, 0, 0, DAMAGE_CUT)
					//boutput(M, "<span class='alert'>The void tears at you!</span>")
					// making the zone name a bit more obvious and making its spam chatbox less - ISN

		tearDown()
			for (var/turf/T in gauntlet_controller.gauntlet)
				T.icon_state = initial(T.icon_state)
				T.color = "#FFFFFF"

	darkness
		name = "Total Darkness"
		point_cost = 3
		minimum_level = 20

		setUp()
			for (var/obj/adventurepuzzle/triggerable/light/gauntlet/G in gauntlet_controller.gauntlet)
				G.off()

		// CRITTERGAUNTLETTODO - Probably a memory leak
		onSpawn(var/obj/critter/C)
			var/datum/light/light = new /datum/light/point
			light.set_brightness(0.4)
			light.set_height(0.5)
			light.attach(C)
			light.enable()

		tearDown()
			for (var/obj/adventurepuzzle/triggerable/light/gauntlet/G in gauntlet_controller.gauntlet)
				G.on()

	flicker
		name = "Flickering Lights"
		point_cost = 1
		minimum_level = 20

		process()
			for (var/obj/adventurepuzzle/triggerable/light/gauntlet/G in gauntlet_controller.gauntlet)
				if (prob(15))
					G.toggle()

		tearDown()
			for (var/obj/adventurepuzzle/triggerable/light/gauntlet/G in gauntlet_controller.gauntlet)
				G.on()

	// CRITTERGAUNTLETTODO - Need to test if this works now
	redlights
		name = "Red Light District"
		point_cost = 0.5
		minimum_level = 10

		setUp()
			for (var/obj/adventurepuzzle/triggerable/light/gauntlet/G in gauntlet_controller.gauntlet)
				G.off()
				G.on_cblue = 0
				G.on_cgreen = 0
				G.light.set_color(G.on_cred, G.on_cgreen, G.on_cblue)
				G.on()

		tearDown()
			for (var/obj/adventurepuzzle/triggerable/light/gauntlet/G in gauntlet_controller.gauntlet)
				G.off()
				G.on_cblue = 1
				G.on_cgreen = 1
				G.light.set_color(G.on_cred, G.on_cgreen, G.on_cblue)
				G.on()

	lightningstrikes
		name = "Lightning Strikes"
		point_cost = 1
		minimum_level = 15
		var/image/marker = null
		var/obj/zapdummy/D1
		var/obj/zapdummy/D2

		setUp()
			var/turf/T

			for (var/turf/Q in gauntlet_controller.gauntlet)
				if (!T)
					T = Q
				if (Q.x < T.x || Q.y < T.y)
					T = Q

			marker = image('icons/effects/VR.dmi', "lightning_marker")
			if (!T)
				logTheThing("debug", null, null, "Gauntlet event Lightning Strikes failed setup.")
			D1 = new(T)
			D2 = new()

		process()
			if (D1)
				if (prob(floor(20 * gauntlet_controller.difficulty)))
					var/turf/target = pick(gauntlet_controller.spawnturfs)
					target.overlays += marker

					SPAWN_DBG(2 SECONDS)
						if (!D2)
							return
						D2.set_loc(target)
						arcFlash(D1, D2, 5000)
						target.overlays -= marker

		tearDown()
			qdel(D1)
			qdel(D2)
			for (var/turf/T in gauntlet_controller.gauntlet)
				T.overlays.len = 0

/obj/zapdummy
	invisibility = 101
	anchored = 1
	density = 0

// CRITTERGAUNTLETTODO - Would it be nice to have some level gating for these?
/datum/gauntletWave
	var/name = "Wave"
	var/point_cost = 1
	var/count = 5 //changes at runtime
	var/health_multiplier = 1 //changes at runtime
	var/list/types = list()

	//Spawns in 1 enemy, but is called every process loop so long as there's more to spawn this wave. (this is how spawns are staggered)
	proc/spawnIn(var/datum/gauntletEvent/ev)
		if (count)
			var/turf/T = pick(gauntlet_controller.spawnturfs)
			var/crit_type = pick(types)
			showswirl(T)
			var/obj/critter/C = new crit_type(T)
			C.health *= health_multiplier
			C.aggressive = 1
			C.defensive = 1
			C.opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
			if (ev)
				ev.onSpawn(C)
			count--
		if (count < 1)
			count = initial(count)
			return 1
		return 0

	mimic
		name = "Mimic"
		point_cost = 1
		count = 6
		types = list(/obj/critter/mimic)

	meaty
		name = "Meat Thing"
		point_cost = 1
		count = 2
		types = list(/obj/critter/blobman/meaty_martha)

	// CRITTERGAUNTLETTODO - these don't do damage on their regular attacks (just the psychic blast counters), but maybe that's reflected in the cost?
	martian
		name = "Martian"
		point_cost = 1
		count = 6
		types = list(/obj/critter/martian)

	soldier
		name = "Martian Soldier"
		point_cost = 3
		count = 4
		types = list(/obj/critter/martian/soldier)

	warrior
		name = "Martian Warrior"
		point_cost = 3
		count = 2
		types = list(/obj/critter/martian/warrior)

	mutant
		name = "Martian Mutant"
		point_cost = 5
		count = 0.05
		types = list(/obj/critter/martian/psychic)

	martian_assorted
		name = "Martian Assortment"
		point_cost = 6
		count = 12
		types = list(/obj/critter/martian/soldier, /obj/critter/martian/soldier, /obj/critter/martian/soldier, /obj/critter/martian/warrior)

	bear
		name = "Bear"
		point_cost = 4
		count = 2
		types = list(/obj/critter/bear)

	tomato
		name = "Killer Tomato"
		point_cost = 2
		count = 8
		types = list(/obj/critter/killertomato)

	// CRITTERGAUNTLETTODO - drones are relatively tanky, may need to be used more sparingly than they are now
	scdrone
		name = "SC Drone"
		point_cost = 4
		count = 4
		types = list(/obj/critter/gunbot/drone)

	crdrone
		name = "CR Drone"
		point_cost = 6
		count = 2
		types = list(/obj/critter/gunbot/drone/buzzdrone)

	hkdrone
		name = "HK Drone"
		point_cost = 8
		count = 1
		types = list(/obj/critter/gunbot/drone/heavydrone)

	xdrone
		name = "X Drone"
		point_cost = 10
		count = 0.05
		types = list(/obj/critter/gunbot/drone/raildrone)

	cannondrone
		name = "AR Drone"
		point_cost = 16
		count = 0.05
		types = list(/obj/critter/gunbot/drone/cannondrone)

	skeleton
		name = "Skeleton"
		point_cost = 3
		count = 5
		types = list(/obj/critter/magiczombie)

	zombie
		name = "Zombie"
		point_cost = 4
		count = 2
		types = list(/obj/critter/zombie)

	micromen
		name = "Micro Man"
		point_cost = 3
		count = 0.1
		types = list(/obj/critter/microman)

	spiderbaby
		name = "Spider Baby"
		point_cost = 5
		count = 3
		types = list(/obj/critter/spider/baby)

	spidericebaby
		name = "Ice Spider Baby"
		point_cost = 5
		count = 3
		types = list(/obj/critter/spider/ice/baby)

	spider
		name = "Spider"
		point_cost = 5
		count = 3
		types = list(/obj/critter/spider)

	spiderice
		name = "Ice Spider"
		point_cost = 5
		count = 3
		types = list(/obj/critter/spider/ice)

	spiderqueen
		name = "Ice Spider Queen"
		point_cost = 8
		count = 0.05
		types = list(/obj/critter/spider/ice/queen)

	spacerachnid
		name = "Space Arachnid"
		point_cost = 3
		count = 2
		types = list(/obj/critter/spider/spacerachnid)

	ohfuckspiders
		name = "OH FUCK SPIDERS"
		point_cost = 8
		count = 7
		types = list(/obj/critter/spider,/obj/critter/spider/baby,/obj/critter/spider/ice,/obj/critter/spider/ice/baby)

	// CRITTERGAUNTLETTODO - Brullbars have a very low point cost, but are disproportionately strong
	// (like, most critters are generally unthreatening but a brullbar will win a 1v1 in melee)
	brullbar
		name = "Brullbar"
		point_cost = 4
		count = 2
		types = list(/obj/critter/brullbar)

	// CRITTERGAUNTLETTODO - Waaay too tanky for the gauntlet. Even with a csaber fighting these is tedious.
	brullbarking
		name = "Brullbar King"
		point_cost = 6
		count = 0.05
		types = list(/obj/critter/brullbar/king)

	badbot
		name = "Security Zapbot"
		point_cost = 2
		count = 2
		types = list(/obj/critter/ancient_repairbot/grumpy)

	fermid
		name = "Fermid"
		point_cost = 3
		count = 3
		types = list(/obj/critter/fermid)

	// CRITTERGAUNTLETTODO - Another balance issue. Lions are fairly strong but shouldn't cost more than brullbars
	lion
		name = "Lion"
		point_cost = 5
		count = 2
		types = list(/obj/critter/lion)

	maneater
		name = "Man Eater"
		point_cost = 5
		count = 2
		types = list(/obj/critter/maneater)

	//this one's hardcoded to get used if event picking fucks up
	fallback
		name = "Floating Eyes"
		point_cost = 0.01
		count = 10
		types = list(/obj/critter/floateye)

/proc/queryGauntletMatches(data)
	if (islist(data) && data["data_hub_callback"])
		logTheThing("<b>Marquesas/Gauntlet Query:</b> Invoked (data is [data])")
		for (var/userkey in data["keys"])
			logTheThing("debug", null, null, "<b>Marquesas/Gauntlet Query:</b> Got key [userkey].")
			var/matches = data[userkey]
			logTheThing("debug", null, null, "<b>Marquesas/Gauntlet Query:</b> Matches for [userkey]: [matches].")
			var/obj/item/card/id/gauntlet/G = locate("gauntlet-id-[userkey]") in world
			if (G && istype(G))
				G.SetMatchCount(text2num(matches))
			else
				logTheThing("debug", null, null, "<b>Marquesas/Gauntlet Query:</b> Could not locate ID 'gauntlet-id-[userkey]'.")
				return 1

	else
		var/list/query = list()
		query["key"] = data
		apiHandler.queryAPI("gauntlet/getPrevious", query)

#undef GAUNTLET_STANDBY
#undef GAUNTLET_IN_STAGING
#undef GAUNTLET_WAVE_FINISHED
#undef GAUNTLET_WAVE_STARTED
