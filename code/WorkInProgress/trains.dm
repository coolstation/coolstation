/obj/train
	name = "train engine"
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
	var/main_color
	var/casing_color
	var/hazpaint_color
	var/step_delay = 0.5
	var/in_bump = 0
	var/hitslow = 1.02
	var/list/mob/riders = list()

	New()
		..()
		src.build_colors()

	Bump(atom/AM as mob|obj|turf)
		if(src.in_bump || !src.step_delay)
			return
		if(world.timeofday - AM.last_bumped <= 5)
			return
		..()
		var/clamped_delay = clamp(src.step_delay, 0.34, 6)
		in_bump = 1
		if(isturf(AM))
			if (!isconstructionturf(AM))
				in_bump = 0
				src.emergency_brake()
				return
			if(istype(AM, /turf/wall))
				var/turf/wall/T = AM
				T.dismantle_wall()
				playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
				for(var/mob/C in viewers(src))
					shake_camera(C, ceil(6 / clamped_delay), ceil(8 / clamped_delay))
					C.show_message("<span class='alert'><B>[src] crashes through the wall!</B></span>", 1)
				src.slow_from_impact(3)
				in_bump = 0
				return
		if(ismob(AM))
			var/mob/M = AM
			for (var/mob/C in viewers(src))
				shake_camera(C, ceil(4 / clamped_delay), ceil(6 / clamped_delay))
				C.show_message("<span class='alert'><B>[src] crashes into [M]!</B></span>", 1)
			random_brute_damage(M, rand(30,45) / clamped_delay, TRUE)
			M.changeStatus("stunned", ceil(6 SECONDS / clamped_delay))
			M.changeStatus("weakened", ceil(6 SECONDS / clamped_delay))
			M.force_laydown_standup()
			var/turf/target = get_edge_target_turf(M, turn(src.dir, pick(45,-45)))
			M.throw_at(target, ceil(2 / clamped_delay), ceil(1 / clamped_delay))
			playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
			src.slow_from_impact(1)
			in_bump = 0
			return
		if(isobj(AM))
			var/obj/O = AM
			if(O.density)
				for (var/mob/C in viewers(src))
					shake_camera(C, ceil(4 / clamped_delay), ceil(6 / clamped_delay))
					C.show_message("<span class='alert'><B>[src] crashes into [O]!</B></span>", 1)
				var/turf/target = get_edge_target_turf(src, src.dir)
				O.throw_at(target, 3, 2)
				playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
				if(!isnull(O))
					O.ex_act(10 / clamped_delay)
					src.slow_from_impact(2)
				in_bump = 0
				return
		in_bump = 0
		return

	Move(NewLoc,Dir)
		. = ..()
		if(.)
			for(var/turf/T in src.locs)
				for(var/mob/living/L in T)
					if(!(L in src.riders) && !L.nodamage)
						random_brute_damage(L, rand(25,35)) // hits 8 times per car, so this is very lethal
						playsound(T, 'sound/impact_sounds/Flesh_Break_1.ogg', 40, 1)
						var/bdna = null
						var/btype = null

						if (ishuman(L))
							if (L.bioHolder)
								bdna = L.bioHolder.Uid
								btype = L.bioHolder.bloodType
							if (L.organHolder && prob(15))
								var/list/choosable_organs = list("left_lung", "right_lung", "butt", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix", "tail")
								var/obj/item/organ/organ = null
								var/count = 0
								//Do this search 5 times or until you find an organ.
								while (!organ && count <= 5)
									count++
									var/organ_name = pick(choosable_organs)
									organ = L.organHolder.get_organ(organ_name)

								L.organHolder.drop_and_throw_organ(organ, src.loc, get_offset_target_turf(src.loc, rand(-5,5), rand(-5,5)), rand(1,4), 1, 0)
							else if (prob(30))
								var/mob/living/carbon/human/H = L
								H.sever_limb(pick("l_arm","r_arm","l_leg","r_leg"))

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

	throw_at(atom/target, range, speed, list/params, turf/thrown_from, throw_type, allow_anchored, bonus_throwforce, end_throw_callback)
		src.step_delay = 1 / speed
		src.glide_size = (32 / src.step_delay) * world.tick_lag
		walk(src, 0)
		. = ..()

	throw_end(list/params, turf/thrown_from)
		. = ..()

	proc/build_colors(var/main_color, var/casing_color, var/hazpaint_color)
		if(!main_color)
			src.main_color = random_color()
		else
			src.main_color = main_color
		var/image/main = image('icons/obj/large/trains_256x128.dmi',"engine_main")
		main.color = src.main_color
		src.UpdateOverlays(main, "engine_main")
		if(!casing_color)
			src.casing_color = random_color()
		else
			src.casing_color = casing_color
		var/image/casing = image('icons/obj/large/trains_256x128.dmi',"engine_casing")
		casing.color = src.casing_color
		src.UpdateOverlays(casing, "engine_casing")
		if(!hazpaint_color)
			src.hazpaint_color = random_saturated_hex_color()
		else
			src.hazpaint_color = hazpaint_color
		var/image/hazpaint = image('icons/obj/large/trains_256x128.dmi',"engine_hazpaint")
		hazpaint.color = src.hazpaint_color
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

	proc/cross_the_map(var/new_delay)
		if(new_delay)
			src.step_delay = new_delay
		src.glide_size = (32 / src.step_delay) * world.tick_lag
		walk(src, WEST, src.step_delay)

	proc/emergency_brake()
		src.step_delay = 0
		walk(src, 0)

	proc/slow_from_impact(var/slow_multiplier = 1)
		src.step_delay = src.step_delay * (src.hitslow ** slow_multiplier)
		if(src.step_delay >= 7)
			walk(src, 0)
		else
			src.glide_size = (32 / src.step_delay) * world.tick_lag
			walk(src, src.dir, src.step_delay)

/*
	proc/process()
		if(src.slowed <= 0)
			processing_items.Remove(src)
			return
		else
			src.step_delay -= clamp(src.slowed, 1, 3) * 0.1
			src.slowed = max(src.slowed - 3, 0)
			src.glide_size = (32 / src.step_delay) * world.
			walk(src, src.dir, src.step_delay)
*/

