/* ----------- THE TRAIN SPOTTER, FOR CONTROLLING TRAINS ----------- */

var/datum/train_controller/train_spotter

/datum/train_controller
	var/list/datum/train_conductor/conductors = list()

/datum/train_controller/proc/config()
	var/dat = "<html><body><title>Train Spotter</title>"
	dat += "<b><u>Train Controls</u></b><HR><small>"

	dat += "<a href='byond://?src=\ref[src];create=1'>Create New Train</a><br>"

	for (var/datum/train_conductor/conductor in src.conductors)
		dat += "<br>"
		dat += "<a href='byond://?src=\ref[src];inspect=\ref[conductor]'>Variables for Train #\ref[conductor]</a><br>"
		if(!conductor.active)
			dat += "<a href='byond://?src=\ref[src];start=\ref[conductor]'>Start Train #\ref[conductor]</a><br>"
		else
			dat += "<a href='byond://?src=\ref[src];stop=\ref[conductor]'>Stop Train #\ref[conductor]</a><br>"

	dat += "</small></body></html>"

	usr.Browse(dat,"window=trains;size=400x600")

/datum/train_controller/Topic(href, href_list[])
	usr_admin_only
	if (href_list["create"])
		new /datum/train_conductor()
		src.config()
	if (href_list["inspect"])
		var/datum/train_conductor/conductor = locate(href_list["inspect"]) in src.conductors
		src.config()
		usr.client:debug_variables(conductor)
	if (href_list["start"])
		var/datum/train_conductor/conductor = locate(href_list["start"]) in src.conductors
		conductor.active = TRUE
		conductor.train_loop()
	if (href_list["stop"])
		var/datum/train_conductor/conductor = locate(href_list["stop"]) in src.conductors
		conductor.active = FALSE

/* ----------- THE TRAIN CARS, THE GOOD LOOKIN' BITS ----------- */

// THE BASE
/atom/movable/traincar
	name = "traincar"
	desc = "That thing what runs you over."
	icon = 'icons/obj/large/trains_256x128.dmi'
	icon_state = "engine_flatbody"
	bound_width = 256
	bound_height = 64
	layer = EFFECTS_LAYER_4
	density = TRUE
	anchored = ANCHORED
	throw_spin = FALSE
	event_handler_flags = Z_ANCHORED
	animate_movement = SYNC_STEPS
	var/traincar_length = 8
	var/loaded = FALSE // used to allow cars to sit in the trainyard safely
	var/any_color_1 = "#FFFFFF"
	var/any_color_2 = "#FFFFFF"
	var/bright_color_1 = "#FFFFFF"
	var/colorful = TRUE

/atom/movable/traincar/New()
	..()
	src.build_colors()
	src.build_overlays()

/atom/movable/traincar/proc/build_colors()
	src.any_color_1 = random_color()
	src.any_color_2 = random_color()
	src.bright_color_1 = random_saturated_hex_color()

/atom/movable/traincar/proc/build_overlays()
	return

// THE ENGINE
/atom/movable/traincar/NT_engine
	name = "engine"
	icon_state = "engine_flatbody"

/atom/movable/traincar/NT_engine/build_overlays()
	var/image/main = image('icons/obj/large/trains_256x128.dmi',"engine_main")
	main.color = src.any_color_1
	src.UpdateOverlays(main, "engine_main")
	var/image/casing = image('icons/obj/large/trains_256x128.dmi',"engine_casing")
	casing.color = src.any_color_2
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

/* ----------- THE TRAIN CONDUCTOR, WHOM DRIVES THE TRAIN ----------- */

/datum/train_conductor
	var/basic_name = "train"
	var/active = FALSE
	var/train_direction = WEST // east-bound trains MIGHT POSSIBLY EVENTUALLY happen. dont count on it.
	var/train_ram_width_bonus = 0 // additional x width of the front hitbox, set dynamically by speed
	var/train_ram_height_bonus = 1 // additional y height of the front hitbox, usually static
	var/train_front_x = 285 // the lowest x coordinate in the trains front hitbox
	var/train_front_y = 163 // the lowest y coordinate in the trains front hitbox
	var/train_z = 0 // the z level the train is on
	var/train_end_x = 285 // the highest x coordinate in the train
	var/list/cars = list(/atom/movable/traincar/NT_engine, /atom/movable/traincar, /atom/movable/traincar, /atom/movable/traincar, /atom/movable/traincar, /atom/movable/traincar, /atom/movable/traincar, /atom/movable/traincar, /atom/movable/traincar, /atom/movable/traincar, /atom/movable/traincar, /atom/movable/traincar, /atom/movable/traincar, /atom/movable/traincar) // all the cars in this train, instantiated or not
	var/list/mob/living/potential_crushes = list() // any mobs that need to be checked for being under the train
	var/movement_delay = 0.5 // how long to wait between each movement
	var/train_unload_x = 15 // a traincar that reaches this x coordinate will immediately be removed
	var/train_not_yet_loaded_x = 285 // the x coordinate to start loading at
	var/unloading_tiles = 0 // how many tiles are currently "missing" between the unload x and the forwardmost loaded car

/datum/train_conductor/New()
	. = ..()
	train_spotter.conductors.Add(src)

/datum/train_conductor/disposing()
	for(var/atom/movable/traincar/car in src.cars)
		qdel(car)
	src.cars = null
	src.potential_crushes = null
	train_spotter.conductors.Cut(src)
	. = ..()

/datum/train_conductor/proc/setup()
	src.train_front_x = src.train_not_yet_loaded_x

/datum/train_conductor/proc/train_loop()
	if(QDELETED(src)) // ah hell nah
		return

	if(!length(src.cars)) // remove empty trains
		qdel(src)
		return

	if(!src.train_z || !src.active || !src.movement_delay) // refuse to process trains that havent been put on a z level
		return

	// first, time for the crushing
	for(var/mob/living/L in src.potential_crushes)
		var/turf/T = get_turf(L)
		if(T.z == src.train_z && (max(src.train_front_x, src.train_unload_x)) <= T.x && T.x <= src.train_end_x && src.train_front_y <= T.y && T.y <= (src.train_front_y + src.train_ram_height_bonus))
			if(L.nodamage || ON_COOLDOWN(L, "trainsquish", rand(1,3)))
				continue
			random_brute_damage(L, rand(15,25)) // incredibly lethal
			playsound(T, 'sound/impact_sounds/Flesh_Break_1.ogg', 40, 1)
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

				var/turf/T = locate(src.train_front_x + x_ram_bonus, src.train_front_y + y_ram_bonus, src.train_z)

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

				for(var/mob/living/L in T.contents)
					if(isintangible(L) || L.nodamage)
						continue
					potential_crushes.Add(L)
					if(!L.lying)
						shake_camera(L, 20, 20)
						for (var/mob/C in viewers(L))
							shake_camera(C, 1, 2)
							C.show_message("<span class='alert'><B>\The [src.basic_name] rams into [L] and sends them flying!</B></span>", 1)
						random_brute_damage(L, rand(40, 55), TRUE)
						L.changeStatus("stunned", 5 SECONDS)
						L.changeStatus("weakened", 6 SECONDS)
						L.force_laydown_standup()
						var/turf/target = get_edge_target_turf(L, turn(src.train_direction, pick(45,-45)))
						L.throw_at(target, 5, 4)
						playsound(T, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)

				if(istype(T, /turf/wall))
					var/turf/wall/rammed_wall = T
					if (isconstructionturf(T)) // phase through it otherwise???
						playsound(T, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
						for(var/mob/C in viewers(T))
							shake_camera(C, 5, 7)
							C.show_message("<span class='alert'><B>\The [src.basic_name] crashes through \the [T]!</B></span>", 1)
						rammed_wall.dismantle_wall(devastated = TRUE, keep_material = TRUE)

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
		var/atom/movable/traincar/car = car_or_typepath
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
			car = new car_or_typepath(locate(current_x, src.train_front_y, src.train_z))
			car.loaded = TRUE
			current_x += car.traincar_length
			src.cars[i] = car
		i++
	src.train_end_x = current_x

	SPAWN_DBG(src.movement_delay)
		src.train_loop()
