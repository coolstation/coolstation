var/list/obj/overlay/magindara_fog/magindara_global_fog
var/global/magindara_surface_loop = 'sound/ambience/loop/magindarawind.ogg' //Z1
var/global/magindara_surface_loop_volume = 80

/turf/space/magindara
	name = "ocean below"
	desc = "The deep ocean of Magindara far below, whipped with waves and frothed with an oily sheen."
	icon = 'icons/turf/water.dmi'
	icon_state = "magindara_ocean"
	opacity = 0
	pathable = 0
	mat_changename = 0
	mat_changedesc = 0
	fullbright = 0
	luminosity = 1
	throw_unlimited = 0
	color = "#ffffff"
	special_volume_override = -1
	turf_flags = MINE_MAP_PRESENTS_EMPTY
#ifdef MAGINDARA_MAP
	oxygen = MOLES_O2MAGINDARA
	nitrogen = MOLES_N2MAGINDARA
	carbon_dioxide = MOLES_CO2MAGINDARA
	temperature = MAGINDARA_TEMP
#else
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C
#endif

	var/datum/light/point/light = null
	var/light_atten_con = -0.08
	var/light_r = 0.55
	var/light_g = 0.4
	var/light_b = 0.6
	var/light_brightness = 0.9
	var/light_height = 3
	var/generateLight = 1

	New()
		..()
		if (src.generateLight)
			src.make_light()
		if (current_state > GAME_STATE_PREGAME)
			src.initialise_component()
		if(!magindara_global_fog)
			update_magindaran_weather()
		vis_contents += magindara_global_fog[1 + (src.x % 2) + (src.y % 2) * 2]
		var/obj/overlay/magindara_skylight/skylight = locate() in src
		if(skylight)
			qdel(skylight)

	/// Adds the pitfall, handled in a portion of map setup if game isnt setup yet, to prevent freezes
	proc/initialise_component()
		src.AddComponent(/datum/component/pitfall/target_coordinates/nonstation,\
			BruteDamageMax = 6,\
			AnchoredAllowed = TRUE,\
			HangTime = 0.2 SECONDS,\
			FallTime = 1.2 SECONDS,\
			DepthScale = 0.4,\
			TargetZ = 3)

	make_light()
		if (!light)
			light = new
			light.attach(src)
		light.set_atten_con(light_atten_con)
		light.set_brightness(light_brightness)
		light.set_color(light_r, light_g, light_b)
		light.set_height(light_height)
		SPAWN_DBG(1 DECI SECOND)
			light?.enable()

	ReplaceWith(what, keep_old_material, handle_air, handle_dir, force)
		. = ..()
		if(!istype(., /turf/space))
			new/obj/overlay/magindara_skylight/weather(src)

	Del()
		if(light)
			light.disable()
			qdel(light)
		. = ..()

/turf/space/fluid/magindara
	name = "polluted ocean"
	desc = "The sand is heavily interspersed with grains of plastic and scraps of metal."
	light_r = 0.55
	light_g = 0.4
	light_b = 0.6
	light_brightness = 0.7
	hint = null
#ifdef MAGINDARA_MAP
	oxygen = MOLES_O2MAGINDARA * 0.5
	nitrogen = MOLES_N2MAGINDARA * 0.5
	carbon_dioxide = MOLES_CO2MAGINDARA * 2
	temperature = MAGINDARA_OCEAN_TEMP
#else
	oxygen = MOLES_O2STANDARD * 0.5
	nitrogen = MOLES_N2STANDARD * 0.5
	temperature = OCEAN_TEMP
#endif

	New()
		. = ..()
		if (worldgen_hold)
			worldgen_candidates[worldgen_generation] += src
		else generate_worldgen()

	make_light()
		if(prob(40)) // only a 40% chance, for lag and also a dappled effect
			. = ..()

	generate_worldgen()
		. = ..()
		if(prob(4))
			new /obj/random_item_spawner/junk/one(src)
		if(prob(1) && prob(1)) // about 7-9 of them in the sea aside from the herd
			new /mob/living/critter/magindaran_horse/ai_controlled(src)

/obj/overlay/magindara_fog
	name = "thick smog"
	desc = "Just barely shy of chokingly thick."
	icon = 'icons/effects/tile_effects.dmi'
	icon_state = "densefog"
	appearance_flags = RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | KEEP_APART
	layer = EFFECTS_LAYER_4
	plane = PLANE_NOSHADOW_ABOVE
	mouse_opacity = FALSE
	color = "#ffffff"
	alpha = 128

	ex_act(severity)
		return

/obj/overlay/heavy_rain
	name = "heavy rain"
	desc = "An absolute downpour."
	icon = 'icons/turf/water.dmi'
	icon_state = "bigrain1"
	appearance_flags = RESET_COLOR | RESET_ALPHA
	layer = EFFECTS_LAYER_3
	plane = PLANE_NOSHADOW_ABOVE
	mouse_opacity = FALSE
	color = "#bea2eb"
	alpha = 60

	ex_act(severity)
		return

/obj/overlay/magindara_skylight
	name = null
	desc = "hidden decal to show the light and/or weather of Magindara on any turf"
	anchored = ANCHORED_TECHNICAL
	var/datum/light/point/light = null
	var/light_atten_con = -0.08
	var/light_r = 0.55
	var/light_g = 0.4
	var/light_b = 0.6
	var/light_brightness = 0.9
	var/light_height = 3

	New()
		..()
		if (!light)
			light = new
			light.attach(src)
		light.set_atten_con(light_atten_con)
		light.set_brightness(light_brightness)
		light.set_color(light_r, light_g, light_b)
		light.set_height(light_height)
		SPAWN_DBG(0.1)
			light?.enable()


	ex_act(severity)
		return

/obj/overlay/magindara_skylight/weather
	New()
		..()
		if(!magindara_global_fog)
			update_magindaran_weather()
		vis_contents += magindara_global_fog[1 + (src.x % 2) + (src.y % 2) * 2]

/area/magindara
	icon_state = "pink"
	name = "\proper Magindaran sea"
	is_construction_allowed = TRUE
	requires_power = TRUE

/area/magindara/seafloor
	icon_state = "pink"
	name = "\proper Magindaran sea floor"
	is_construction_allowed = TRUE
	requires_power = FALSE // i want this to be true later, once i figure out lights on the outside of the hull

/area/station/catwalk/simulated //todo: make this an abstract type later
	icon_state = "yellow"
	name = "Maintenance Catwalk"
	force_fullbright = FALSE
	requires_power = TRUE

proc/update_magindaran_weather(change_time = 5 SECONDS, fog_alpha=0,fog_color="#ffffff",rain_alpha=0,rain_color="#bea2eb")
	if(!magindara_global_fog)
		magindara_global_fog = list()
	if(!length(magindara_global_fog))
		for (var/i in 1 to 4)
			magindara_global_fog += new /obj/overlay/magindara_fog
	for (var/i in 1 to 4)
		var/obj/overlay/heavy_rain/rain = locate() in magindara_global_fog[i].vis_contents
		if(!rain)
			rain = new
			rain.icon_state = "bigrain[i]"
			magindara_global_fog[i].vis_contents += rain
		animate(magindara_global_fog[i], time = change_time, alpha = fog_alpha, color = fog_color)
		animate(rain, time = change_time, alpha = rain_alpha, color = rain_color)

/client/proc/change_magindaran_weather()
	set name = "Change Magindaran Weather"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	admin_only

	var/change_time = input(usr, "Please enter the animation time in deciseconds:","Animation Time", "50") as num
	var/fog_alpha = input(usr, "Please enter the fog alpha:","Fog Alpha", "128") as num
	var/fog_color = input(usr, "Please enter the fog tint:","Fog Tint", "#ffffff") as color
	var/rain_alpha = input(usr, "Please enter the rain alpha:","Rain Alpha", "60") as num
	var/rain_color = input(usr, "Please enter the rain color:","Rain Color", "#bea2eb") as color

	logTheThing("admin", usr, null, "changed Magindara's weather to fog [fog_alpha] [fog_color] and rain [rain_alpha] [rain_color] over [change_time / 10] seconds.")
	logTheThing("diary", usr, null, "changed Magindara's weather to fog [fog_alpha] [fog_color] and rain [rain_alpha] [rain_color] over [change_time / 10] seconds.", "admin")

	update_magindaran_weather(change_time, fog_alpha, fog_color, rain_alpha, rain_color)

/client/proc/strike_lightning_here()
	set name = "Strike Lightning Here"
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	admin_only

	var/power = input(usr, "Please enter the power:","Power", "10") as num
	var/warning_time = input(usr, "Please enter the warning time (deciseconds):","Warning Time", "60") as num
	var/warning_sparks = input(usr, "Please enter the number of warning sparks:","Warning Sparks", "9") as num
	var/is_turf_safe = input(usr, "Is this lightning safe for turfs? BE CAREFUL:","Turf Safe", "1") as num
	var/turf/T = get_turf(src.mob)

	if(power)
		logTheThing("admin", src, null, "created[is_turf_safe ? "" : " turf destroying"] lightning (power [power], warning [warning_time]) at [log_loc(T)].")
		logTheThing("diary", src, null, "created[is_turf_safe ? "" : " turf destroying"] lightning (power [power], warning [warning_time]) at [log_loc(T)].", "admin")

		lightning_strike(T, power, warning_time, warning_sparks, is_turf_safe)

/proc/lightning_strike(var/turf/target, var/power = 10, var/warning_time = 6 SECONDS, var/warning_sparks = 9, var/is_turf_safe = TRUE, var/color = "#ccf5ff")
	if(!target || !power)
		return
	if(!istype(target))
		target = get_turf(target)
	var/rodded = FALSE
	for (var/obj/lightning_rod/rod in by_type[/obj/lightning_rod])
		if(rod.attached && GET_DIST(rod, target) <= 16)
			target = get_turf(rod)
			SPAWN_DBG(warning_time + 0.2 SECONDS)
				if(!QDELETED(rod))
					rod.struck(floor(power * 100 MEGA))
			rodded = TRUE
			break
	logTheThing("bombing", null, null, "Lightning[is_turf_safe ? "" : " (turf destroying)"] with power [power] started striking [log_loc(target)], warning time [warning_time / 10] seconds.")
	logTheThing("diary", null, null, "Lightning[is_turf_safe ? "" : " (turf destroying)"] with power [power] started striking [log_loc(target)], warning time [warning_time / 10] seconds.", "combat")
	SPAWN_DBG(0)
		var/sleep_time = ceil(warning_time / (warning_sparks + 1))
		if(warning_sparks && warning_time)
			var/spark_volume = max(50 - 5 * warning_sparks, 20)
			for(var/i in 1 to warning_sparks)
				if(QDELETED(target))
					return
				var/datum/effects/system/spark_spread/E = new()
				E.set_up(6,0,target)
				E.start()
				sleep(sleep_time)
				playsound(target, pick(sounds_sparks), spark_volume, 1)
				spark_volume = min(spark_volume + 5 * warning_sparks, 65)
		sleep(sleep_time)
		if(QDELETED(target))
			return
		playsound(target, 'sound/effects/thunder.ogg', 80, 1, floor(power))
		new /obj/decal/lightning(target, rodded ? 64 : 0, color)
		if(!rodded)
			explosion_new(target, target, power, turf_safe = is_turf_safe, no_effects = TRUE)
		for(var/mob/living/L in orange(2, target)) // some more mean effects
			L.changeStatus("disorient",min(15 * power,30 SECONDS))
			L.change_misstep_chance(min(power, 30))

/obj/item/device/weather_remote
	name = "weather control remote"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "bomb_remote"
	item_state = "electronic"
	desc = "A haphazard assembly of wires, antennas, and 3D printed PCBs which <i>allegedly</i> links up to a weather control satellite in orbit around Magindara. Allegedly."

	var/charges = 3 //how many times can we change the weather with this remote?
	var/italian = FALSE //admin only

	get_desc()
		. = ..()
		if(charges >= 1)
			. += " There's a nixie tube sticking out of the side, glowing dimly with the number <b>[charges]</b>."
		else
			. += " The nixie tube is extinguished."

/obj/item/device/weather_remote/italian
	name = "italian weather control remote"
	desc = "...this is just a colander on a stick, what the hell?"

	charges = INFINITY
	italian = TRUE

/obj/item/device/weather_remote/attack_self(mob/user as mob)
	..()

	//src.add_dialog(user) //how the fuck do you make a ui - we're adding this later, we can just use popup inputs for now
	if(charges >= 1)
		if(!magindara_global_fog)
			update_magindaran_weather()

		var/obj/overlay/heavy_rain/rain = locate() in magindara_global_fog[1].vis_contents
		var/fog_alpha = input(usr, "Please enter the fog alpha. Max 220:","Fog Alpha", "128") as num
		var/rain_alpha = input(usr, "Please enter the rain alpha. Max 220:","Rain Alpha", "60") as num
		var/fog_color = magindara_global_fog[1].color
		var/rain_color = rain.color

		fog_alpha = clamp(fog_alpha, 0, 220)
		rain_alpha = clamp(rain_alpha, 0, 220) // i don't want some wiseguy giving us -1 fog

		if(italian)
			fog_color = input(usr, "Please enter the fog tint:","Fog Tint", fog_color) as color
			rain_color = input(usr, "Please enter the rain color:","Rain Color", rain_color) as color

		if(alert(user, "Confirm?", "Magindaran Weather Control", "Yes", "No") == "Yes")
			update_magindaran_weather(30 SECONDS, fog_alpha, fog_color, rain_alpha, rain_color)
			if(!italian)
				boutput(user, "<span class='notice'>The [src] beeps, and something flashes in the clouds far above.</span>")
			else
				boutput(user, "<span class='notice'>The [src] sort of... wiggles.</span>")

			src.charges -= 1
			src.tooltip_rebuild = TRUE

	else
		boutput(user, "<span class='notice'>The [src] beeps, but nothing seems to happen.</span>")

/obj/landmark/herd_animal
	name = LANDMARK_HERD_ANIMAL_SPAWN

/mob/living/critter/magindaran_horse
	name = "horse"
	desc = "A common horse, frequently harvested for neck meat on Magindara."
	icon = 'icons/obj/large/32x96.dmi'
	icon_state = "magindarahorse"
	icon_state_dead = "magindarahorse"
	health_brute = 45
	health_burn = 45
	pull_w_class = W_CLASS_BULKY
	takes_brain = FALSE
	custom_gib_handler = /proc/gibs
	pet_text = list("slaps", "smacks", "whaps", "pets")
	ideal_blood_volume = 200
	blood_id = "oil"
	caneat = FALSE
	candrink = FALSE
	can_lie = FALSE
	use_stunned_icon = FALSE // for now
	layer = MOB_LAYER + 0.12
	base_walk_delay = 8
	base_move_delay = 7
	var/out_of_water_movedelay = 8
	var/obj/magindaran_horsehead/myhead = null

	New()
		. = ..()
		src.myhead = new /obj/magindaran_horsehead(src, src)
		src.synchead()

	proc/synchead()
		if(!src.myhead)
			src.myhead = new /obj/magindaran_horsehead(src, src)
		if(isturf(src.loc))
			var/turf/T = get_turf(src)
			var/datum/component/updraft/updraft = T.GetComponent(/datum/component/updraft)
			if(updraft && updraft.TargetTurf)
				src.myhead.set_loc(updraft.TargetTurf)
		src.myhead.dir = src.dir
		src.myhead.color = src.color

	Move(turf/NewLoc, direct)
		. = ..()
		src.myhead.dir = src.dir
		if(isturf(src.loc))
			var/turf/T = get_turf(src)
			var/datum/component/updraft/updraft = T.GetComponent(/datum/component/updraft)
			if(updraft && updraft.TargetTurf)
				src.myhead.set_loc(updraft.TargetTurf)
				return
		src.myhead.set_loc(src)

	set_loc(newloc)
		. = ..()
		src.myhead.dir = src.dir
		if(isturf(src.loc))
			var/turf/T = get_turf(src)
			var/datum/component/updraft/updraft = T.GetComponent(/datum/component/updraft)
			if(updraft && updraft.TargetTurf)
				src.myhead.set_loc(updraft.TargetTurf)
				return
		src.myhead.set_loc(src)

	special_movedelay_mod(delay,space_movement,aquatic_movement)
		. = ..()
		var/turf/T = get_turf(src)
		if (T && !(T.turf_flags & FLUID_MOVE))
			. += src.out_of_water_movedelay

	disposing()
		qdel(src.myhead)
		src.myhead = null
		. = ..()

	ai_controlled
		is_npc = 1
		ai_type = /datum/aiHolder/horse_herd

		New()
			..()
			//todo later : move this lifeprocess stuff to a component
			remove_lifeprocess(/datum/lifeprocess/blindness)
			remove_lifeprocess(/datum/lifeprocess/viruses)

		death(var/gibbed)
			qdel(src.ai)
			src.ai = null
			reduce_lifeprocess_on_death()
			..()

/obj/magindaran_horsehead
	icon = 'icons/mob/critter.dmi'
	icon_state = "magindarahorsehead"
	name = "horse"
	desc = "A common horse, frequently harvested for neck meat on Magindara."
	anchored = ANCHORED_TECHNICAL
	density = FALSE
	event_handler_flags = Z_ANCHORED | USE_FLUID_ENTER
	plane = PLANE_SPACE
	var/mob/living/critter/magindaran_horse/myhorse = null
	var/bullet_hit_rate = 30

	New(turf/newLoc, var/mob/living/critter/magindaran_horse/horse = null)
		. = ..()
		src.myhorse = horse

	attackby(obj/item/I, mob/user)
		. = src.myhorse.attackby(I, user)
		user.lastattacked = src.myhorse
		user.next_click = world.time + max(I.click_delay,I.combat_click_delay)

	attack_hand(mob/user, params, location, control)
		. = src.myhorse.attack_hand(user, params, location, control)
		if(user.lastattacked == src.myhorse)
			user.next_click = world.time + max(user.click_delay,user.combat_click_delay)
		else
			user.next_click = world.time + user.click_delay

	ex_act(severity, last_touched, epicenter, turf_safe)
		var/turf/epicenter_down = epicenter
		var/turf/myhorse_turf = get_turf(src.myhorse)
		epicenter_down = locate(epicenter_down.x, epicenter_down.y, myhorse_turf.z)
		return src.myhorse.ex_act(severity, last_touched, epicenter_down, turf_safe)

	CanPass(atom/movable/mover)
		if(istype(mover, /obj/projectile))
			return prob(src.bullet_hit_rate)
		. = ..()


	bullet_act(obj/projectile/P)
		. = ..()
		return src.myhorse

// todo: they need to wander as a herd, approximately
// they should congregate nearish the station, and if someone feeds one,
// the tile they were fed at should be considered a high priority tile
/datum/aiHolder/horse_herd
	New()
		. = ..()
		var/datum/aiTask/timed/wander_sometimes/W =  get_instance(/datum/aiTask/timed/wander_sometimes, list(src))
		W.transition_task = W
		default_task = W

/datum/aiTask/timed/wander_sometimes
	name = "occasionally wandering"
	minimum_task_ticks = 15
	maximum_task_ticks = 20
	var/wander_chance = 15

/datum/aiTask/timed/wander_sometimes/evaluate()
	. = 1

/datum/aiTask/timed/wander_sometimes/on_tick()
	. = ..()
	if(prob(src.wander_chance))
		holder.owner.move_dir = pick(alldirs)
		holder.owner.process_move()
	holder.stop_move()
