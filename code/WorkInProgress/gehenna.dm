#define GEHENNA_TIME (((BUILD_TIME_DAY * 24)+(BUILD_TIME_HOUR))*2)
//the above expression results in about 4 days per month.
// 10 just beautiful. oh. wow. lovely.
// 30 is a beautiful, goldenrod gehenna sunrise.
// 45
// 60 is bright yellow, safe air.
// 90 is bright, reddish, safe and warm.
// 120 is bright, magenta bloom, too hot to breathe.
// 150 is a sakura-pink deathtrap, so inviting but so hot and toxic. probably peak deadliness.
// 170 is like sunset ish, its nice but toxic levels of CO2.
// 200 is dark out, cool, and still toxic levels of CO2.
// 230 is night time, and *just* under the CO2 toxicity threshold.
// 260 much the same, less CO2
// 290 same as above.
// 320 same.
// 350 twilight.s
// 370 just beautiful. oh. wow. lovely. Oh it's 10 again.
#define WASTELAND_MIN_TEMP 250
#define WASTELAND_MAX_TEMP 375
#define GEHENNA_CO2 5*(sin(GEHENNA_TIME - 90)+ 1)
#define GEHENNA_O2 MOLES_O2STANDARD * (sin(GEHENNA_TIME - 60)+2)
#define GEHENNA_N2 MOLES_O2STANDARD *0.5*(sin(GEHENNA_TIME + 90)+2)
#define GEHENNA_TEMP WASTELAND_MIN_TEMP + ((0.5*sin(GEHENNA_TIME-45)+0.5)*(WASTELAND_MAX_TEMP - WASTELAND_MIN_TEMP))



var/global/gehenna_time = GEHENNA_TIME

//audio
//you want some audio to play overall in "space" but reduced when you're in a non-space area? check it out
var/global/gehenna_surface_loop = 'sound/ambience/loop/Gehenna_Surface.ogg' //Z1
var/global/gehenna_underground_loop = 'sound/ambience/loop/Gehenna_Surface.ogg' //Z3
// volume curve so wind stuff is loudest in the cold, cold night
var/global/gehenna_surface_loop_vol = (30 + ((0.5*sin(GEHENNA_TIME-135)+0.5)*(60))) //volume meant for outside, min 30 max 90
var/global/gehenna_underground_loop_vol = (gehenna_surface_loop_vol / 6) //just have it the same but quiet i guess (with a proper cave soundscape, increase to like 100 or something)

// Gehenna shit tho
/turf/space/gehenna
	name = "planet gehenna"
	desc = "errrr"
	opacity = 0
	pathable = 0
	mat_changename = 0
	mat_changedesc = 0
	fullbright = 0
	luminosity = 1
	intact = 0 //allow wire laying
	throw_unlimited = 0
	color = "#ffffff"
	special_volume_override = -1

	Entered(atom/movable/O)
		..()
		if(istype(src.loc,/area/gehenna))
			var/area/A = src.loc
			if(A.sandstorm)
				if(prob(A.sandstormIntensity) && !istype(O.dir, A.blowOrigin)) //yeah this is a bad fix, sue me
					step(O,A.blowOrigin)
		//if(istype(O, /mob/living))
			//RegisterSignal(O, COMSIG_MOVABLE_MOVED, PROC_REF(footprints))
	/*
	Exited(atom/movable/O)
		if(istype(O,/mob/living))
			UnregisterSignal(O, COMSIG_MOVABLE_MOVED)

	proc/footprints(mob/living/M, oldLoc, direct)
		var/obj/decal/cleanable/imprint/I
		I = locate(/obj/decal/cleanable/imprint) in src
		if(!I)
			I = make_cleanable(/obj/decal/cleanable/imprint, src)
		var/list/states = M.get_step_image_states()
		if (states[1] || states[2])
			if(states[1])
				I.create_overlay(states[1], "#564c38", direct, 'icons/obj/decals/blood.dmi') //gimme gimme
			if(states[2])
				I.create_overlay(states[2], "#564c38", direct, 'icons/obj/decals/blood.dmi') //awawa
		else
			I.create_overlay("smear2", "#564c38", direct, 'icons/obj/decals/blood.dmi')
	*/

/turf/wall/asteroid/gehenna
	fullbright = 0
	luminosity = 1 // 0.5*(sin(GEHENNA_TIME)+ 1)

	name = "sulferous rock"
	desc = "looks loosely packed"
	icon = 'icons/turf/floors.dmi'
	icon_state = "gehenna_rock"
	floor_turf = "/turf/space/gehenna/desert"
	hardness = 1
	default_ore = /obj/item/raw_material/rock/gehenna

	New()
		..()
		src.icon_state = initial(src.icon_state)
	space_overlays()
		return

	ex_act(severity)
		switch(severity)
			if(OLD_EX_SEVERITY_1)
				src.damage_asteroid(5)
			if(OLD_EX_SEVERITY_2)
				src.damage_asteroid(4)
			if(OLD_EX_SEVERITY_3)
				src.damage_asteroid(3)
		return

/turf/wall/asteroid/gehenna/z3
	floor_turf = "/turf/floor/plating/gehenna"

/turf/wall/asteroid/gehenna/z3/fun //for an prefab
	New()
		..()
		var/datum/ore/starstone/bait = locate(/datum/ore/starstone) in mining_controls.ore_types_all
		if (bait)
			src.ore = bait
			src.hardness += bait.hardness_mod
			src.amount = rand(bait.amount_per_tile_min,bait.amount_per_tile_max)
			var/image/ore_overlay = image('icons/turf/asteroid.dmi',bait.name)
			ore_overlay.transform = turn(ore_overlay.transform, pick(0,90,180,-90))
			ore_overlay.pixel_x += rand(-6,6)
			ore_overlay.pixel_y += rand(-6,6)
			src.overlays += ore_overlay
			bait.onGenerate(src)
			src.mining_health = bait.mining_health
			src.mining_max_health = bait.mining_health
			src.set_event(locate(/datum/ore/event/cave_in) in mining_controls.events)

/turf/wall/asteroid/gehenna/tough
	name = "crimson bedrock"
	desc = "looks densely packed"
	icon_state = "gehenna_rock2"
	hardness = 2
	turf_flags = IS_TYPE_SIMULATED | MINE_MAP_PRESENTS_TOUGH

	ex_act(severity)
		switch(severity)
			if(OLD_EX_SEVERITY_1)
				src.damage_asteroid(3)
			if(OLD_EX_SEVERITY_2)
				src.damage_asteroid(2)
			if(OLD_EX_SEVERITY_3)
				src.damage_asteroid(1)
		return

/turf/wall/asteroid/gehenna/tough/z3
	floor_turf = "/turf/floor/plating/gehenna"


/turf/wall/gehenna/
	fullbright = 0
	luminosity = 1
	name = "monolithic sulferous rock"
	desc = "looks conveniently impenetrable"
	icon = 'icons/turf/floors.dmi'
	icon_state = "gehenna_rock3"

/turf/floor/plating/gehenna/
	name = "sand"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "sand"
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED
	plate_mat = 0 //Prevents this "steel sand" bullshit but it's not a great solution
	allows_vehicles = 1
	turf_flags = IS_TYPE_SIMULATED | MOB_SLIP | MOB_STEP | MINE_MAP_PRESENTS_EMPTY

	New()
		..()
		src.set_dir(pick(cardinal))

	ex_act(severity) //TODO: cave ins?? people mentioned that repeatedly??
		return //no plating/lattice thanx

/turf/floor/plating/gehenna/plasma
	oxygen = MOLES_O2STANDARD * 1.5
	nitrogen = MOLES_N2STANDARD / 2
	toxins = MOLES_O2STANDARD // hehh hehh hehhhehhhe

/turf/floor/plating/gehenna/farts
	farts = MOLES_N2STANDARD / 2
	nitrogen = MOLES_N2STANDARD / 2

/turf/space/gehenna/desert
	pathable = 1 // HARNER GO ACROSS THE SAND YOU OAF
	name = "barren wasteland"
	desc = "Looks really dry out there."
	icon = 'icons/turf/floors.dmi'
	icon_state = "gehenna"
	carbon_dioxide = GEHENNA_CO2
	oxygen = GEHENNA_O2
	nitrogen = GEHENNA_N2
	temperature = GEHENNA_TEMP
	turf_flags = MINE_MAP_PRESENTS_EMPTY

	luminosity = 1 // 0.5*(sin(GEHENNA_TIME)+ 1)

	var/datum/light/point/light = null
	var/light_r = 0.5*(sin(GEHENNA_TIME)+1)
	var/light_g = 0.3*(sin(GEHENNA_TIME )+1)
	var/light_b = 0.4*(sin(GEHENNA_TIME - 45 )+1)
	var/light_brightness = 0.6*(sin(GEHENNA_TIME)+0.8) + 0.3
	var/light_height = 3
	var/generateLight = 1
	var/stone_color
	var/static/list/image/rocks
	var/rock_mult = 85
	var/x_drift = 1
	var/y_drift = 1
	var/perlin_zoom = 80
	var/icon_suffix = null
	var/doublesize = TRUE
	var/big_rock_chance = 2

	New()
		..()

		if(src.doublesize)
			icon_state += "_[x % 2][y % 2]"
		var/seed = global.server_start_time + src.z * 42069
		var/x_input = (src.x + rand(-src.x_drift,src.x_drift)) / src.perlin_zoom
		var/y_input = (src.y + rand(-src.y_drift,src.y_drift)) / src.perlin_zoom
		var/rock_chance = text2num(rustg_noise_get_at_coordinates("[seed]", "[x_input]", "[y_input]"))
		rock_chance = 3.8*((rock_chance - 0.5)**2) + 0.05
		var/g = floor(rock_chance * 55 + 200)
		var/b = floor(rock_chance * 125 + 130)
		src.color = rgb(255,g,b)
		src.stone_color = src.color
		if(src.rock_mult)
			if(!src.rocks)
				src.create_rocks()
			if(prob(floor(src.rock_mult * rock_chance)))
				UpdateOverlays(pick(src.rocks), "rock_overlay")
			if(prob(big_rock_chance * (1.2 - rock_chance))) // ouuugh i hate mapgen
				SPAWN_DBG(0.5)
					var/create_rock = TRUE
					for(var/obj/decal/cragrock/rock in range(5, src))
						create_rock = FALSE
						break
					if(create_rock)
						var/obj/decal/cragrock/rock = new(src)
						rock.color = src.color

		if (generateLight)
			src.make_light()

	proc/create_rocks()
		rocks = list()
		for(var/i in 1 to 18)
			var/image/rock = image('icons/turf/gehenna_overlays.dmi',"rock[i]", layer = TURF_LAYER)
			rock.plane = PLANE_NOSHADOW_BELOW
			rocks += rock

	make_light()
		if (!light)
			light = new
			light.attach(src)
		light.set_brightness(light_brightness)
		light.set_color(light_r, light_g, light_b)
		light.set_height(light_height)
		SPAWN_DBG(0.1)
			light?.enable()

	tunnel_surface
		name = "bored tunnel floor"
		desc = "Industry must flourish."
		icon = 'icons/turf/floors.dmi'
		icon_state = "concrete"
		rock_mult = 0
		generateLight = 0
		big_rock_chance = 0
		doublesize = FALSE

		railroad
			name = "railroad"
			icon_state = "railroad_concrete"

	railroad_ties
		name = "railroad"
		desc = "Industry must flourish."
		icon = 'icons/turf/floors.dmi'
		icon_state = "railroad"
		rock_mult = 0
		generateLight = 1
		big_rock_chance = 0
		doublesize = FALSE

	plating
		name = "sand-covered plating"
		desc = "The desert slowly creeps upon everything we build."
		icon = 'icons/turf/floors.dmi'
		icon_state = "gehenna_tile"
		rock_mult = 30
		doublesize = FALSE
		big_rock_chance = 0

		thermal
			name = "sand-covered solar plating"
			desc = "Absorbs the sun's rays, gets real hot."
			temperature = WASTELAND_MIN_TEMP + ((0.5*sin(GEHENNA_TIME-45)+0.5)*(1.5*WASTELAND_MAX_TEMP - WASTELAND_MIN_TEMP))
			rock_mult = 0
			big_rock_chance = 0

		podbay
			icon_state = "gehenna_plating"
			rock_mult = 0

	path
		name = "beaten earth"
		desc = "This soil has been beaten flat by years of foot traffic."
		icon = 'icons/turf/floors.dmi'
#ifdef IN_MAP_EDITOR
		icon_state = "gehenna_edge"
#else
		icon_state = "gehenna"
#endif
		rock_mult = 20
		doublesize = TRUE
		big_rock_chance = 0
		var/static/list/image/beaten_sand

		New()
			if(!src.beaten_sand)
				src.create_beaten_sand()
			UpdateOverlays(src.beaten_sand["[dir]"], "beaten_sand_overlay")
			..()

		proc/create_beaten_sand()
			beaten_sand = list()
			for(var/i in alldirs)
				beaten_sand["[i]"] = image('icons/turf/gehenna_overlays.dmi',"beaten_edge", dir = i)

	corner
		name = "beaten earth"
		desc = "This soil has been beaten flat by years of foot traffic."
		icon = 'icons/turf/floors.dmi'
#ifdef IN_MAP_EDITOR
		icon_state = "gehenna_corner"
#else
		icon_state = "gehenna"
#endif
		rock_mult = 20
		doublesize = TRUE
		big_rock_chance = 0
		var/static/list/image/beaten_sand

		New()
			if(!src.beaten_sand)
				src.create_beaten_sand()
			UpdateOverlays(src.beaten_sand["[dir]"], "beaten_sand_overlay")
			..()

		proc/create_beaten_sand()
			beaten_sand = list()
			for(var/i in alldirs)
				beaten_sand["[i]"] = image('icons/turf/gehenna_overlays.dmi',"beaten_corner", dir = i)

	beaten
		name = "beaten earth"
		desc = "This soil has been beaten flat by years of foot traffic."
		icon = 'icons/turf/floors.dmi'
#ifdef IN_MAP_EDITOR
		icon_state = "gehenna_beat"
#else
		icon_state = "gehenna"
#endif
		rock_mult = 20
		doublesize = TRUE
		big_rock_chance = 0
		var/static/image/beaten_sand

		New()
			if(!src.beaten_sand)
				src.create_beaten_sand()
			UpdateOverlays(src.beaten_sand["[pick(cardinal)]"], "beaten_sand_overlay")
			..()

		proc/create_beaten_sand()
			beaten_sand = list()
			for(var/i in cardinal)
				beaten_sand["[i]"] = image('icons/turf/gehenna_overlays.dmi',"beaten_center", dir = i)

/area/gehenna
	requires_power = 0
	icon_state = "dither_b"
	name = "the gehennan desert"
	is_construction_allowed = TRUE


/area/gehenna/south // just in case i need a separate area for stuff
	requires_power = 0
	icon_state = "dither_g"
	name = "the gehennan desert"

/area/gehenna/wasteland
	icon_state = "dither_r"
	name = "the barren wastes"
	teleport_blocked = 0
	sound_environment = EAX_PLAIN
	permarads = 1
	irradiated = 0.3

	New()
		..()
		for(var/turf/space/gehenna/desert/T in src)
			T.temperature = (T.temperature + WASTELAND_MAX_TEMP)/2 // hotter but not maximum.

/area/gehenna/wasteland/stormy
	name = "the horrid wastes"
	icon_state = "yellow"
	teleport_blocked = 1
	requires_power = 0
	sound_environment = EAX_PLAIN
	sound_loop_1 = 'sound/ambience/loop/SANDSTORM.ogg' //need something wimdy, maybe overlay a storm sound on this
	sound_loop_1_vol = 100 //always loud, fukken storming
	var/list/assholes_to_hurt = list()
	var/buffeting_assoles = FALSE
	irradiated = 0.5

	New()
		..()
		overlays += image(icon = 'icons/turf/areas.dmi', icon_state = "dustverlay", layer = EFFECTS_LAYER_BASE)
		for(var/turf/space/gehenna/desert/T in src)
			T.temperature = WASTELAND_MAX_TEMP


	Entered(atom/movable/O)
		..()
		if (ishuman(O))
			var/mob/living/jerk = O
			if (!isdead(jerk))
				assholes_to_hurt |= jerk
				if((istype(jerk:wear_suit, /obj/item/clothing/suit/armor))||(istype(jerk:wear_suit, /obj/item/clothing/suit/space))&&(istype(jerk:head, /obj/item/clothing/head/helmet/space))) return
				random_brute_damage(jerk, 20)
				if(prob(50))
					playsound(O.loc, 'sound/impact_sounds/Flesh_Stab_2.ogg', 50, 1)
					boutput(jerk, pick("Sand gets caught in your eyes!","The wind blows you off course!","Debris really fucks up your skin!"))
					jerk.changeStatus("weakened", 13 SECONDS)
					jerk.change_eye_blurry(15, 30)
				SPAWN_DBG(10)
					src.process_some_sand()
		else
			if(ismob(O))
				var/mob/living/M = O
				if (!isdead(M))
					assholes_to_hurt |= M //quick and simple, nonhuman mobs are gonna get hurt.
					src.process_some_sand()
					return
			if(istype(O, /obj/vehicle) || istype(O, /obj/machinery/bot) || istype(O, /obj/machinery/vehicle))
				playsound(O.loc, 'sound/effects/creaking_metal2.ogg', 100, 1)
				O.ex_act(OLD_EX_LIGHT)
				assholes_to_hurt |= O
				src.process_some_sand()
				return





	Exited(atom/movable/A)
		..()
		if (ismob(A))
			var/mob/living/jerk = A
			assholes_to_hurt &= ~jerk

	proc/process_some_sand()
		if(buffeting_assoles)
			return
		while(assholes_to_hurt.len)
			buffeting_assoles = TRUE
			for(var/mob/living/jerk in assholes_to_hurt)
				if(!istype(jerk) || isdead(jerk))
					assholes_to_hurt &= ~jerk
					continue
				if((istype(jerk:wear_suit, /obj/item/clothing/suit/armor))||(istype(jerk:wear_suit, /obj/item/clothing/suit/space))&&(istype(jerk:head, /obj/item/clothing/head/helmet/space)))
					//assholes_to_hurt &= ~jerk //warc: gonna not remove them and just pass over, so if they lose their suit later they get hurt.
					continue
				random_brute_damage(jerk, 10)
				if(prob(50))
					playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_2.ogg', 50, 1)
					boutput(jerk, pick("Dust gets caught in your eyes!","The wind disorients you!","Debris pierces through your skin!"))
					jerk.changeStatus("weakened", 7 SECONDS)
					jerk.change_eye_blurry(10, 20)
			for(var/obj/vehicle/V in assholes_to_hurt)
				if(!istype(V))
					assholes_to_hurt &= ~V
					continue
				if((V.rider_visible || !V.sealed_cabin)&&prob(50))
					V.eject_rider()
					V.ex_act(OLD_EX_TOTAL)
				else
					V.ex_act(OLD_EX_LIGHT)
				playsound(V.loc, 'sound/effects/creaking_metal2.ogg', 100, 1)
			for(var/obj/machinery/vehicle/pod in assholes_to_hurt)
				if(!istype(pod) || pod.health <= 0)
					assholes_to_hurt &= ~pod
					continue
				else
					playsound(pod.loc, 'sound/effects/creaking_metal1.ogg', 100, 1)
					pod.ex_act(rand(2,3))
			for(var/obj/machinery/bot/aipod in assholes_to_hurt)
				if(!istype(aipod) || aipod.health <= 0)
					assholes_to_hurt &= ~aipod
					continue
				else
					playsound(aipod.loc, 'sound/effects/creaking_metal1.ogg', 100, 1)
					aipod.ex_act(rand(3))




			sleep(10 SECONDS)
		buffeting_assoles = FALSE


/area/gehenna/underground
	icon_state = "dither_g"
	name = "the sulfurous caverns"
	teleport_blocked = 0
	sound_group = "caves"
	force_fullbright = 0
	requires_power = 0
	luminosity = 0
	sound_environment = EAX_CAVE
	is_atmos_simulated = TRUE

/area/gehenna/underground/staffies_nest
	name = "the rat's nest"
	teleport_blocked = 1

/*
/obj/machinery/computer/sea_elevator/sec
	upper = /area/shuttle/sea_elevator/upper/sec
	lower = /area/shuttle/sea_elevator/lower/sec

/obj/machinery/computer/sea_elevator/eng
	upper = /area/shuttle/sea_elevator/upper/eng
	lower = /area/shuttle/sea_elevator/lower/eng

/obj/machinery/computer/sea_elevator/med
	upper = /area/shuttle/sea_elevator/upper/med
	lower = /area/shuttle/sea_elevator/lower/med

/obj/machinery/computer/sea_elevator/QM
	upper = /area/shuttle/sea_elevator/upper/QM
	lower = /area/shuttle/sea_elevator/lower/QM

/obj/machinery/computer/sea_elevator/command
	upper = /area/shuttle/sea_elevator/upper/command
	lower = /area/shuttle/sea_elevator/lower/command
*/
/obj/machinery/computer/sea_elevator/NTFC
	upper = /area/shuttle/sea_elevator/upper/NTFC
	lower = /area/shuttle/sea_elevator/lower/NTFC

/obj/decal/gehenna/warning
	name = "warning display"
	desc = "A warning display with an internal Gehennan clock. It's off, which means it has nothing to warn you about."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "warning-unpowered"
	anchored = 1

	New()
		..()
		if(GEHENNA_CO2>=8 && GEHENNA_TEMP >= 335)
			src.icon_state = "warning-combined"
			src.desc = desc = "A warning display with an internal Gehennan clock. It's extremely hazardous outside."
		else
			if(GEHENNA_CO2 >= 8)
				src.icon_state = "warning-internals"
				src.desc = desc = "A warning display with an internal Gehennan clock. The outside currently contains dangerous concentrations of sleepytime gas."
			if(GEHENNA_TEMP >= 335)
				src.icon_state = "warning-hot"
				src.desc = desc = "A warning display with an internal Gehennan clock. It's gonna be a scorcher!"

