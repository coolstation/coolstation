/* ----------- THE TRAIN EVENT, MAKES TRAINS COME BY ----------- */

/datum/random_event/minor/train
	name = "Train"
	var/min_delay = 10 SECONDS
	var/max_delay = 30 SECONDS
#ifndef RAILWAY_Y
	disabled = TRUE
#endif

	event_effect(source)
		..()
		// yeah the time in this alert is kinda just a fuckin' lie
		command_alert(text = "In [round(rand(min_delay, max_delay), 5 SECONDS) / (1 SECOND)] seconds, a cargo train will make a scheduled pass on local railway. Complete all in-progress crossings swiftly.", title = "Scheduled Train", override_big_title = "Gehenna Rail Traffic Control")

		var/delay_time = rand(min_delay, max_delay)

		var/datum/train_conductor/conductor = new
#ifdef RAILWAY_Y
		conductor.train_front_y = RAILWAY_Y
#else
		// listen, im assuming you WANT to destroy things if you activate this on a map with no tracks
		conductor.train_front_y = rand(80, world.maxy - 80)
#endif

		conductor.movement_delay = (12 + rand(-5,5)) / 10
		if(prob(5))
			conductor.movement_delay *= 3
		else if(prob(5))
			conductor.movement_delay /= 3

		conductor.cars += /obj/traincar/NT_engine

		var/car_length = rand(20,40)
		for(var/i in 1 to car_length)
			conductor.cars += /obj/traincar/NT_shipping

		SPAWN_DBG(delay_time)
			if(QDELETED(conductor))
				return
			conductor.train_z = Z_LEVEL_STATION
			conductor.active = TRUE
			conductor.train_loop()


// Landmark to place everywhere you want the train to automatically sound its horn
/obj/landmark/whistle_board
	deleted_on_start = FALSE
	add_to_landmarks = FALSE

/obj/landmark/whistle_board/Crossed(atom/movable/O)
	var/obj/traincar/NT_engine/loco = O
	if(istype(loco))
		loco.sound_horn()

/* ----------- THE TRAIN SPOTTER, FOR CONTROLLING TRAINS ----------- */

var/datum/train_controller/train_spotter

/datum/train_controller
	var/list/datum/train_conductor/conductors = list()
	var/next_id = 1
	var/list/datum/train_preset/presets = list()
	var/list/cooldowns

/datum/train_controller/New()
	. = ..()
	var/list/preset_types = concrete_typesof(/datum/train_preset)
	for(var/preset_type in preset_types)
		presets.Add(new preset_type)

/datum/train_controller/proc/config()
	var/dat = "<html><head><title>Train Spotter</title></head><body style='background: #dad8b6;'>"
	dat += "<style> .traintitle { display: inline-block; color:#FFFFFF; background: #3B3632; padding: 2px; text-align: center; border-radius: 5px; width: 100%; left: -2px;} .buttan { display:inline-block; border-radius: 5px; margin: 3px; padding: 3px; width: 2.5cm; height: 2.5em; text-align:center; font-weight: bold;} </style>"
	dat += "<h2 style='display:inline-block; text-align:center; background:#FFB347; color: black; width:98%;'>Train Controls</h2><HR>"

	dat += "<a class='buttan' style='background: #20B142; color:#FFFFFF; position: absolute; left: 2%; font-weight: bold;' href='byond://?src=\ref[src];create=1'>Create New Train</a> "
	dat += "<a class='buttan' style='background: #DB2828; color: #FBD608; position: absolute; left: 34%; font-weight: bold;' href='byond://?src=\ref[src];fucku=1'>Fuck This Y<br>In Particular</a> "
	dat += "<a class='buttan' style='background: #7E5AC9; color: #FFFFFF; position: absolute; right: 2%; font-weight:bold;'  href='byond://?src=\ref[src];RandomTrainEvent=1'>Random Train<br>(TODO)</a><small><div style='position: absolute; top: 4cm; width: 95%; margin:auto;'>"

	for (var/datum/train_conductor/conductor in src.conductors)
		dat += "<div style='height: 3cm; background: #676457; border: 2px; border-radius: 5px; padding: 3px; position: relative; width: 90%;'>"
		dat += "<b class='traintitle'>Train #[conductor.train_id]<span style='display: inline-block; margin: auto; width: 25%;'>-</span>[length(conductor.cars)] cars</b><br>"
		dat += "<b><a href='byond://?src=\ref[src];inspect=\ref[conductor]'>Variables for Train #[conductor.train_id]</a></b><br><b>Train Speed</b>: "
		dat += "<a href='byond://?src=\ref[src];setspeed=\ref[conductor];newspeed=3'>Super Slow</a> - "
		dat += "<a href='byond://?src=\ref[src];setspeed=\ref[conductor];newspeed=0.5'>Normal</a> - "
		dat += "<a href='byond://?src=\ref[src];setspeed=\ref[conductor];newspeed=0.125'>Stupid Fast</a><br>"

		if(!conductor.active)
			dat += "<a href='byond://?src=\ref[src];loadpreset=\ref[conductor]'>Load Preset</a>"

		if(conductor.train_z && conductor.train_front_x && conductor.train_front_y && length(conductor.cars))
			if(!conductor.active)
				dat += "<a class='buttan' style='background: #20B142; color: #FFFFFF; position:absolute; left: 5%; bottom: 5%;' href='byond://?src=\ref[src];start=\ref[conductor]'><b>Start</b><br>(at [conductor.train_front_x], [conductor.train_front_y], [conductor.train_z].)</a>"
			else
				dat += "<a class='buttan' style='background: #DB4B4B; color: #FFFFFF; position:absolute; left: 5%; bottom: 5%;' href='byond://?src=\ref[src];stop=\ref[conductor]'><b>Stop</b> train</a>"
			dat += "<a class='buttan' style='background: #FBB608; color: #000000; position:absolute; right: 34%; bottom: 5%;' href='byond://?src=\ref[src];honk=\ref[conductor]'><b>Horn</b></a>"

		dat += "<a class='buttan' style='background: #DB2828; color:#FFFFFF; position:absolute; right: 5%; bottom: 5%;' href='byond://?src=\ref[src];delete=\ref[conductor]'>Delete Train</a>"
		dat += "</div><br>"

	dat += "</div></small></body></html>"

	usr.Browse(dat,"window=train_spotter;size=400x600")

/datum/train_controller/Topic(href, href_list[])
	usr_admin_only
	if (href_list["create"])
		new /datum/train_conductor()
	if (href_list["inspect"])
		var/datum/train_conductor/conductor = locate(href_list["inspect"]) in src.conductors
		if(istype(conductor))
			usr.client:debug_variables(conductor)
	if (href_list["start"])
		var/datum/train_conductor/conductor = locate(href_list["start"]) in src.conductors
		if(istype(conductor))
			conductor.active = TRUE
			conductor.train_loop()
	if (href_list["stop"])
		var/datum/train_conductor/conductor = locate(href_list["stop"]) in src.conductors
		if(istype(conductor))
			conductor.active = FALSE
	if (href_list["loadpreset"])
		var/datum/train_conductor/conductor = locate(href_list["loadpreset"]) in src.conductors
		if(istype(conductor))
			var/datum/train_preset/preset = input(usr, "Select a preset", "Presets",null) in src.presets
			if(preset)
				if(preset.name)
					conductor.basic_name = preset.name
				if(length(preset.cars))
					for(var/obj/traincar/car in conductor.cars)
						qdel(car)
					conductor.cars.Cut()
					conductor.cars.Add(preset.cars)
				if(preset.movement_delay)
					conductor.movement_delay = preset.movement_delay
				if(preset.x)
					conductor.train_front_x = preset.x
				if(preset.y)
					conductor.train_front_y = preset.y
				if(preset.z)
					conductor.train_z = preset.z
	if (href_list["setspeed"])
		var/datum/train_conductor/conductor = locate(href_list["setspeed"]) in src.conductors
		if(istype(conductor))
			var/new_speed = text2num(href_list["newspeed"])
			if(new_speed == 0)
				new_speed = 0.5

			conductor.movement_delay = new_speed
	if (href_list["honk"])
		var/datum/train_conductor/conductor = locate(href_list["honk"]) in src.conductors
		if(istype(conductor))
			var/obj/traincar/NT_engine/loco = locate(/obj/traincar/NT_engine) in conductor.cars
			if(istype(loco))
				loco.sound_horn()
	if (href_list["delete"])
		// unwind & delete the train
		var/datum/train_conductor/conductor = locate(href_list["delete"]) in src.conductors
		if(istype(conductor))
			conductor.active = FALSE
			qdel(conductor)

	if (href_list["fucku"])
		// fuck this Y coordinate in particular, with a vengeance
		// carves the map up from stem to stern
		logTheThing("admin", usr, null, "Fucked everything on Y: [usr.y] Z: [usr.z] with a train")
		var/datum/train_conductor/the_fckr = new()
		// the_fckr.train_id = 666 //  \m/
		the_fckr.cars = list(/obj/traincar/NT_engine, /obj/traincar/NT_shipping, /obj/traincar/NT_shipping, /obj/traincar/NT_shipping)
		the_fckr.train_z = usr.z
		the_fckr.train_front_y = usr.y
		the_fckr.train_not_yet_loaded_x = world.maxx
		the_fckr.movement_delay = 0.25 // hard n fast
		the_fckr.active=TRUE
		the_fckr.train_loop()

	src.config()

/* ----------- THE TRAIN PRESETS, FOR FUN STUFFS ----------- */

ABSTRACT_TYPE(/datum/train_preset)
/datum/train_preset
	var/name = null
	var/list/cars
	var/movement_delay = 0
	var/x = 0
	var/y = 0
	var/z = 0

/*

## These are kinda confusing to see in the preset list tbh. ##

/datum/train_preset/fast_af
	movement_delay = 0.125

/datum/train_preset/slow
	movement_delay = 3

*/

/datum/train_preset/fast_single_car //yeet
	movement_delay = 0.125
	cars = list(/obj/traincar/NT_shipping)

/datum/train_preset/short_cargo
	movement_delay = 3
	cars = list(/obj/traincar/NT_engine, /obj/traincar/NT_shipping, /obj/traincar/NT_shipping, /obj/traincar/NT_shipping)

/datum/train_preset/shipping_cars
	cars = list(/obj/traincar/NT_engine, /obj/traincar/NT_shipping, /obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping,/obj/traincar/NT_shipping)

/* ----------- THE TRAIN CARS, THE GOOD LOOKIN' BITS ----------- */

// THE BASE
/obj/traincar
	name = "traincar"
	desc = "That thing what runs you over."
	icon = 'icons/obj/large/trains_256x128.dmi'
	icon_state = "boxcar_flatbody"
	bound_width = 256
	bound_height = 64
	layer = EFFECTS_LAYER_4
	density = TRUE
	anchored = ANCHORED
	throw_spin = FALSE
	event_handler_flags = USE_FLUID_ENTER | Z_ANCHORED
	animate_movement = SYNC_STEPS
	dir = WEST
	var/traincar_length = 8
	var/loaded = FALSE // used to allow cars to sit in the trainyard safely
	var/datum/train_conductor/my_conductor
	var/list/horn_sound
	var/last_honk = 0

	var/dull_color_1 = "#FFFFFF"
	var/dull_color_2 = "#FFFFFF"
	var/bright_color_1 = "#FFFFFF"

/obj/traincar/New(var/turf/newLoc, var/datum/train_conductor/conductor)
	..()
	src.my_conductor = conductor
	src.build_colors()
	src.build_overlays()

/obj/traincar/proc/build_colors()
	src.dull_color_1 = random_greyish_hex_color()
	src.dull_color_2 = random_greyish_hex_color()
	src.bright_color_1 = random_saturated_hex_color()

/obj/traincar/proc/build_overlays()
	return

/obj/traincar/Bumped(var/atom/movable/AM)
	. = ..()
	if(src.loaded && src.my_conductor && src.my_conductor.active && src.my_conductor.movement_delay < 1 SECOND)
		if(isliving(AM))
			var/mob/living/L = AM
			if(L.nodamage || ON_COOLDOWN(AM, "trainvacuumbump", 0.1 SECONDS) || GET_COOLDOWN(AM, "trainsquish"))
				return
			src.my_conductor.potential_crushes.Add(AM)
			var/turf/target = get_turf(AM)
			var/y_variance = get_dir(src, AM) & NORTH ? 1 : -1
			if(ON_COOLDOWN(AM, "trainvacuumsucc", 0.6 SECONDS)) // hit twice within 0.6 seconds, excluding the 0.1 second invuln, to get sucked under
				AM.set_loc(locate(target.x, clamp(target.y + y_variance, 1, world.maxy - 1), target.z))
			y_variance = y_variance * rand(-4, 15)
			if(src.my_conductor.train_direction & EAST)
				target = locate(min(target.x + 40, world.maxx-1), clamp(target.y + y_variance, 1, world.maxy - 1), target.z)
			if(src.my_conductor.train_direction & WEST)
				target = locate(max(target.x - 40, 1), clamp(target.y + y_variance, 1, world.maxy - 1), target.z)
			src.visible_message("[AM] gets clipped by \the [src.my_conductor.basic_name]!")
			AM.throw_at(target, floor(5 / src.my_conductor.movement_delay), 2.5 / src.my_conductor.movement_delay)
			shake_camera(L, 4 / src.my_conductor.movement_delay, 5 / src.my_conductor.movement_delay)
			random_brute_damage(L, rand(10, 15) / src.my_conductor.movement_delay, TRUE)
			L.changeStatus("stunned", 2 SECONDS / src.my_conductor.movement_delay)
			L.changeStatus("weakened", 3 SECONDS / src.my_conductor.movement_delay)
			L.force_laydown_standup()

/obj/traincar/proc/sound_horn()
	if(!src.horn_sound)
		return
	if(src.last_honk > (world.timeofday + 5 SECONDS)) // 5 second cooldown should be enough?
		return
	src.last_honk = world.timeofday
	playsound(src.loc, pick(src.horn_sound), 50, 1, 15)


// THE ENGINE
/obj/traincar/NT_engine
	name = "engine"
	icon_state = "engine_flatbody"
	horn_sound = list('sound/effects/train/horn1.ogg','sound/effects/train/horn2.ogg', 'sound/effects/train/horn3.ogg')

/obj/traincar/NT_engine/build_colors()
	src.dull_color_1 = rand(200, 230)
	src.dull_color_1 = rgb(src.dull_color_1, src.dull_color_1, src.dull_color_1)
	src.dull_color_2 = rgb(rand(60,70), rand(115,125), rand(160, 170))
	src.bright_color_1 = rgb(rand(230,255), rand(200,220), rand(65,80))

/obj/traincar/NT_engine/build_overlays()
	var/image/main = image('icons/obj/large/trains_256x128.dmi',"engine_main")
	main.color = src.dull_color_1
	src.UpdateOverlays(main, "engine_main")
	var/image/casing = image('icons/obj/large/trains_256x128.dmi',"engine_casing")
	casing.color = src.dull_color_2
	src.UpdateOverlays(casing, "engine_casing")
	var/image/hazpaint = image('icons/obj/large/trains_256x128.dmi',"engine_hazpaint")
	hazpaint.color = src.bright_color_1
	src.UpdateOverlays(hazpaint, "engine_hazpaint")
	var/image/greeble_overlay = image('icons/obj/large/trains_256x128.dmi',"engine_greebles_12")
	src.UpdateOverlays(greeble_overlay, "engine_greeble_overlay")
	var/image/animated_overlay = image('icons/obj/large/trains_256x128.dmi',"engine_animated_temp")
	src.UpdateOverlays(animated_overlay, "engine_animated_overlay")
	var/image/grime_overlay = image('icons/obj/large/trains_256x128.dmi',"engine_grime_overlay1")
	src.UpdateOverlays(grime_overlay, "engine_grime_overlay")
	var/image/grime_multiply = image('icons/obj/large/trains_256x128.dmi',"engine_grime_multiply1")
	grime_multiply.blend_mode = BLEND_MULTIPLY
	src.UpdateOverlays(grime_multiply, "engine_grime_multiply")
	var/image/fullbright = image('icons/obj/large/trains_256x128.dmi',"engine_fullbright")
	fullbright.plane = PLANE_SELFILLUM
	src.UpdateOverlays(fullbright, "engine_fullbright")

// ONE OR TWO SHIPPING CONTAINERS
/obj/traincar/NT_shipping
	name = "shipping car"

/obj/traincar/NT_shipping/build_colors()
	src.dull_color_1 = random_greyish_hex_color(50,90)
	src.dull_color_2 = random_greyish_hex_color(50,90)
	//src.bright_color_1 = random_saturated_hex_color()

/obj/traincar/NT_shipping/build_overlays()
	var/did_one = prob(90)
	var/offset = rand(3,7)

	if(did_one)
		var/image/container_1 = image('icons/obj/large/trains_128x96.dmi',"shipping_container")
		container_1.color = src.dull_color_1
		container_1.pixel_x = offset
		container_1.pixel_y = rand(28, 31)
		src.UpdateOverlays(container_1, "container_one")
		if(prob(5))
			var/image/paint_1 = image('icons/obj/large/trains_128x96.dmi',"shipping_container_paint1")
			paint_1.pixel_x = container_1.pixel_x
			paint_1.pixel_y = container_1.pixel_y
			src.UpdateOverlays(paint_1, "paint_one")
		var/image/grime_1 = image('icons/obj/large/trains_128x96.dmi',"shipping_container_grime_multiply1")
		grime_1.blend_mode = BLEND_MULTIPLY
		grime_1.pixel_x = container_1.pixel_x
		grime_1.pixel_y = container_1.pixel_y
		src.UpdateOverlays(grime_1, "grime_one")

	if(!did_one || prob(90))
		var/image/container_2 = image('icons/obj/large/trains_128x96.dmi',"shipping_container")
		container_2.color = src.dull_color_2
		container_2.pixel_x = offset + rand(118,120)
		container_2.pixel_y = rand(28, 31)
		src.UpdateOverlays(container_2, "container_two")
		if(prob(5))
			var/image/paint_2 = image('icons/obj/large/trains_128x96.dmi',"shipping_container_paint1")
			paint_2.pixel_x = container_2.pixel_x
			paint_2.pixel_y = container_2.pixel_y
			src.UpdateOverlays(paint_2, "paint_two")
		var/image/grime_2 = image('icons/obj/large/trains_128x96.dmi',"shipping_container_grime_multiply1")
		grime_2.blend_mode = BLEND_MULTIPLY
		grime_2.pixel_x = container_2.pixel_x
		grime_2.pixel_y = container_2.pixel_y
		src.UpdateOverlays(grime_2, "grime_two")

/* ----------- THE TRAIN CONDUCTOR, WHOM DRIVES THE TRAIN ----------- */

/datum/train_conductor
	var/basic_name = "train"
	var/active = FALSE
	var/train_direction = WEST // east-bound trains MIGHT POSSIBLY EVENTUALLY happen. dont count on it.
	var/train_id = 0 // the id of this train
	var/train_ram_width_bonus = 0 // additional x width of the front hitbox
	var/train_ram_height_bonus = 1 // additional y height of the front hitbox, usually static
#if defined(MAP_OVERRIDE_CRAG)
	var/train_front_y = 163 // the lowest y coordinate in the trains front hitbox
	var/train_z = 1 // the z level the train is on
#else
	var/train_front_y = 0 // the lowest y coordinate in the trains front hitbox
	var/train_z = 0 // the z level the train is on
#endif
	var/train_front_x = 285 // the lowest x coordinate in the trains front hitbox
	var/train_end_x = 285 // the highest x coordinate in the train
	var/list/cars = list()
	var/list/mob/living/potential_crushes = list() // any mobs that need to be checked for being under the train
	var/movement_delay = 0.5 // how long to wait between each movement
	var/train_unload_x = 15 // a traincar that reaches this x coordinate will immediately be removed
	var/train_not_yet_loaded_x = 285 // the x coordinate to start loading at
	var/unloading_tiles = 0 // how many tiles are currently "missing" between the unload x and the forwardmost loaded car

/datum/train_conductor/New()
	. = ..()
	train_spotter.conductors.Add(src)
	src.train_id = train_spotter.next_id
	train_spotter.next_id++

/datum/train_conductor/disposing()
	for(var/obj/traincar/car in src.cars)
		qdel(car)
	src.cars = null
	src.potential_crushes = null
	train_spotter.conductors -= src
	. = ..()

/datum/train_conductor/proc/setup()
	src.train_front_x = src.train_not_yet_loaded_x

/datum/train_conductor/proc/train_loop()
	if(QDELETED(src)) // ah hell nah
		return

	if(!length(src.cars)) // remove empty trains
		qdel(src)
		return

	if(!src.train_z || !src.active || src.movement_delay < 0.01) // refuse to process trains that havent been put on a z level
		return

	// first, time for the crushing
	for(var/mob/living/L in src.potential_crushes)
		var/turf/T = get_turf(L)
		if(!T)
			src.potential_crushes.Cut(L)
		if(T.z == src.train_z && (max(src.train_front_x, src.train_unload_x)) <= T.x && T.x <= src.train_end_x && src.train_front_y <= T.y && T.y <= (src.train_front_y + src.train_ram_height_bonus))
			if(L.nodamage || ON_COOLDOWN(L, "trainsquish", rand(1,3)))
				continue
			random_brute_damage(L, rand(15,25)) // incredibly lethal
			playsound(T, 'sound/impact_sounds/Flesh_Break_1.ogg', 40, 1)

			if(L.get_brute_damage() > 500) // thats enough maiming
				continue

			var/bdna = null
			var/btype = null
			if (ishuman(L))
				if (L.bioHolder)
					bdna = L.bioHolder.Uid
					btype = L.bioHolder.bloodType
				if (L.organHolder && prob(5))
					var/list/choosable_organs = list("left_lung", "right_lung", "butt", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix", "tail")
					var/obj/item/organ/organ = null
					var/count = 0
					//Do this search 3 times or until you find an organ.
					while (!organ && count <= 3)
						count++
						var/organ_name = pick(choosable_organs)
						organ = L.organHolder.get_organ(organ_name)

					L.organHolder.drop_and_throw_organ(organ, L.loc, get_offset_target_turf(get_turf(L), rand(-5,5), rand(-5,5)), rand(1,4), 1, 0)
				else if (prob(5))
					var/mob/living/carbon/human/H = L
					H.sever_limb(pick("l_arm","r_arm","l_leg","r_leg"))

			// spray gibs
			if(!ON_COOLDOWN(L, "trainsquishgibs", rand(15,20)))
				var/list/viral_list = list()
				for (var/datum/ailment_data/AD in L.ailments)
					viral_list += AD

				if (!L.custom_gib_handler)
					if (iscarbon(L))
						if (bdna && btype)
							gibs(L.loc, viral_list, null, bdna, btype, source=L)
						else
							gibs(L.loc, viral_list, null, source=L)
					else
						robogibs(L.loc, viral_list)
				else
					call(L.custom_gib_handler)(L.loc, viral_list, null, bdna, btype)
		else // if they aint under the train, stop checking
			src.potential_crushes.Cut(L)

	// thats enough crushing, now we do the ramming
	if(src.train_front_x > src.train_unload_x)
		for(var/x_ram_bonus in 0 to src.train_ram_width_bonus)
			for(var/y_ram_bonus in 0 to src.train_ram_height_bonus)

				var/turf/T = locate(src.train_front_x + x_ram_bonus - 1, src.train_front_y + y_ram_bonus, src.train_z)
				for(var/mob/living/L in T.contents)
					if(isintangible(L) || L.nodamage)
						continue
					potential_crushes.Add(L)
					if(!L.lying)
						ON_COOLDOWN(L, "trainsquish", 1 SECOND)
						shake_camera(L, 5 / src.movement_delay, 10 / src.movement_delay)
						for (var/mob/C in viewers(L))
							shake_camera(C, 1, 2)
							C.show_message("<span class='alert'><B>\The [src.basic_name] rams into [L] and sends [him_or_her(L)] flying!</B></span>", 1)
						random_brute_damage(L, rand(40, 50) / src.movement_delay, TRUE)
						L.changeStatus("stunned", 2 SECONDS / src.movement_delay)
						L.changeStatus("weakened", 3 SECONDS / src.movement_delay)
						L.force_laydown_standup()
						var/turf/target = get_edge_target_turf(L, turn(src.train_direction, pick(45,-45)))
						L.throw_at(target, floor(5 / src.movement_delay), 1.5 / src.movement_delay)
						playsound(T, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)

				if(istype(T, /turf/wall))
					var/turf/wall/rammed_wall = T
					if (isconstructionturf(T)) // phase through it otherwise???
						playsound(T, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
						for(var/mob/C in viewers(T))
							shake_camera(C, 5, 7)
							C.show_message("<span class='alert'><B>\The [src.basic_name] crashes through \the [T]!</B></span>", 1)
						rammed_wall.dismantle_wall(devastated = TRUE, keep_material = TRUE)

				var/hit_obj = FALSE
				for(var/obj/O in T.contents)
					if(O.density)
						var/turf/target = get_edge_target_turf(O, src.train_direction)
						O.throw_at(target, 3, 3)
						if(!hit_obj)
							playsound(T, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 35, 1)
						if(!QDELETED(O))
							O.ex_act(7)
						hit_obj = TRUE

	// thats enough ramming, time for the movement
	src.train_front_x--
	if(src.unloading_tiles > 0)
		src.unloading_tiles--
	var/glide_size = (32 / src.movement_delay) * world.tick_lag
	var/current_x = max(src.train_front_x, src.train_unload_x + src.unloading_tiles)
	var/i = 1
	for(var/car_or_typepath in src.cars)
		if(current_x > src.train_not_yet_loaded_x)
			break
		var/obj/traincar/car = car_or_typepath
		if(istype(car))
			if(current_x > src.train_unload_x)
				car.loaded = TRUE
				car.glide_size = glide_size
				car.set_loc(locate(current_x, src.train_front_y, src.train_z))
				car.glide_size = glide_size
				current_x += car.traincar_length
			else if(car.loaded)
				src.unloading_tiles = current_x - src.train_unload_x + car.traincar_length
				current_x += car.traincar_length
				qdel(car)
				src.cars.Cut(1,2)
		else
			if(i == 1)
				src.train_front_x--
			car = new car_or_typepath(locate(current_x, src.train_front_y, src.train_z), src)
			car.loaded = TRUE
			current_x += car.traincar_length
			src.cars[i] = car
		i++
	src.train_end_x = current_x

	SPAWN_DBG(src.movement_delay)
		src.train_loop()

/area/centcom/train_depot
	name = "NTFC Train Depot"
	icon_state = "yellow"
