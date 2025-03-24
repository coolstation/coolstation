/obj/train
	name = "train engine"
	desc = "That thing what runs you over."
	icon = 'icons/obj/large/trains_256x128.dmi'
	icon_state = "engine_precolor_test"
	bound_width = 256
	bound_height = 64
	layer = EFFECTS_LAYER_UNDER_4
	density = TRUE
	anchored = ANCHORED
	throw_spin = FALSE
	event_handler_flags = Z_ANCHORED
	var/step_delay = 0.5
	var/in_motion = FALSE
	var/in_bump = 0
	var/list/mob/riders = list()

	New()
		..()
		var/image/fullbright = image('icons/obj/large/trains_256x128.dmi',"fullbright")
		fullbright.plane = PLANE_SELFILLUM
		src.UpdateOverlays(fullbright, "fullbright")


	Bump(atom/AM as mob|obj|turf)
		if(src.in_bump || !src.in_motion)
			return
		if(world.timeofday - AM.last_bumped <= 50)
			return
		..()
		in_bump = 1
		if(isturf(AM))
			if (!isconstructionturf(AM))
				in_bump = 0
				src.emergency_brake()
				return
			if(istype(AM, /turf/wall))
				var/turf/wall/T = AM
				T.dismantle_wall(1)
				playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
				for(var/mob/C in viewers(src))
					shake_camera(C, 10, 16)
					C.show_message("<span class='alert'><B>The [src] crashes through the wall!</B></span>", 1)
				in_bump = 0
				return
		if(ismob(AM))
			var/mob/M = AM
			for (var/mob/C in viewers(src))
				shake_camera(C, 8, 12)
				C.show_message("<span class='alert'><B>The [src] crashes into [M]!</B></span>", 1)
			random_brute_damage(M, rand(30,45) / src.step_delay, TRUE)
			M.changeStatus("stunned", 6 SECONDS)
			M.changeStatus("weakened", 6 SECONDS)
			M.force_laydown_standup()
			var/turf/target = get_edge_target_turf(src, pick(NORTHWEST, SOUTHWEST))
			M.throw_at(target, 4, 2)
			playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
			in_bump = 0
			return
		if(isobj(AM))
			var/obj/O = AM
			if(O.density)
				for (var/mob/C in viewers(src))
					shake_camera(C, 8, 12)
					C.show_message("<span class='alert'><B>The [src] crashes into [O]!</B></span>", 1)
				var/turf/target = get_edge_target_turf(src, src.dir)
				playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
				O.throw_at(target, 3, 2)
				if(istype(O, /obj/window) || istype(O, /obj/grille) || istype(O, /obj/machinery/door) || istype(O, /obj/structure/girder) || istype(O, /obj/foamedmetal))
					qdel(O)
				if(istype(O, /obj/critter))
					O:CritterDeath()
				if(!isnull(O))
					O.ex_act(4)
				in_bump = 0
				return
		in_bump = 0
		return

	Move(NewLoc,Dir)
		. = ..()
		if(.)
			for(var/turf/T in src.locs)
				for(var/mob/living/L in T)
					if(!(L in src.riders))
						random_brute_damage(L, rand(30,40)) // hits 8 times, so this is very lethal
						playsound(T, 'sound/impact_sounds/Flesh_Break_1.ogg', 40, 1)
						var/bdna = null // For forensics (Convair880).
						var/btype = null

						if (ishuman(L))
							if (L.bioHolder)
								bdna = L.bioHolder.Uid // Ditto (Convair880).
								btype = L.bioHolder.bloodType
							if (L.organHolder && prob(30))
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
									gibs(L.loc, viral_list, null, bdna, btype, source=L) // For forensics (Convair880).
								else
									gibs(L.loc, viral_list, null, source=L)
							else
								robogibs(L.loc, viral_list)
						else
							call(L.custom_gib_handler)(L.loc, viral_list, null, bdna, btype)

	proc/cross_the_map(var/new_delay)
		if(new_delay)
			src.step_delay = new_delay
		src.glide_size = (32 / src.step_delay) * world.tick_lag
		src.in_motion = TRUE
		walk(src, WEST, src.step_delay)

	proc/emergency_brake()
		src.in_motion = FALSE
		walk(src, 0)
