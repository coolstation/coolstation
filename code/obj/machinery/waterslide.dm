// legally distinct water slides! deploy a line of slippery tiles that apply touch chems! wowie!

/obj/machinery/waterslide_pump
	name = "water slide pump"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "waterslide-pump"
	desc = "A pump and hose attached to a big roll of plastic."
	density = 0 // Being able to step through this makes the 'sliding' part more intuitive
	anchored = 1

	var/active = FALSE

	var/steps = 7
	var/max_steps = 15
	var/min_steps = 1
	var/current_step = 1

	var/list/deployed_path = new/list()

	var/obj/item/fluidtank = null

	New()
		..()

		fluidtank = new/obj/item/reagent_containers/food/drinks/fueltank/chlorine/mostly_water(src)

	disposing()
		for(var/obj/item/reagent_containers/waterslide/slide_tile in deployed_path)
			slide_tile.dispose()

		..()

	process()
		if(active)
			if(current_step > deployed_path.len)
				current_step = 1
			if(!fluidtank || fluidtank.reagents.total_volume <= 0)
				active = FALSE
				return
			var/obj/item/reagent_containers/waterslide/section = deployed_path[current_step]

			if(section.reagents.total_volume <= 0)
				fluidtank.reagents.trans_to(section,5)
			if(src.fluidtank.reagents.total_volume <= 0)
				active = FALSE
				current_step = 1
				return

			current_step += 1

			SPAWN_DBG(2 SECONDS) src.process()
		return

	proc/establish_slide()
		var/turf/T = get_step(src,src.dir)
		var/range_slide = 1
		while((get_dist(src,T) < steps) && (range_slide < max_steps)) // copied from fireburp code
			T = get_step(T,src.dir)
			range_slide ++
		var/list/affected_turfs = getline(src, T)

		var/turf/currentturf
		var/turf/previousturf

		for(var/turf/F in affected_turfs)
			previousturf = currentturf
			currentturf = F
			if(currentturf.density || istype(currentturf, /turf/space) || locate(/obj/item/reagent_containers/waterslide) in currentturf)
				if(deployed_path.len) // make the last piece an end piece
					var/obj/item/reagent_containers/waterslide/last = deployed_path[deployed_path.len]
					last.icon_state = "waterslide-end"
				break
			if(previousturf && LinkBlocked(previousturf, currentturf))
				if(deployed_path.len) // make the last piece an end piece
					var/obj/item/reagent_containers/waterslide/last = deployed_path[deployed_path.len]
					last.icon_state = "waterslide-end"
				break
			if (F == get_turf(src))
				continue
			if (get_dist(src,F) > steps)
				continue
			var/obj/item/reagent_containers/waterslide/slide_section = new/obj/item/reagent_containers/waterslide(F)
			slide_section.dir = src.dir
			deployed_path += slide_section

		if(deployed_path.len)
			current_step = 1
			active = TRUE
			var/image/end = image(src.icon, "waterslide-end")
			end.dir = turn(src.dir, 180)
			src.underlays += end
			SPAWN_DBG(0) process()

	proc/remove_slide()
		active = FALSE
		for(var/obj/item/reagent_containers/waterslide/slide_tile in deployed_path)
			slide_tile.dispose()

/obj/item/reagent_containers/waterslide
	name = "water slide"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "waterslide"
	desc = "A slippery plastic surface spread across the floor."
	anchored = 1
	layer = 2
	initial_volume = 5
	var/image/fluid_image = null

	event_handler_flags = USE_HASENTERED

	New()
		..()
		fluid_image = image(src.icon, "waterslide-fluid")

	get_desc(dist, mob/user)
		if(src.reagents && dist <= 2)
			. = "<br><span class='notice'>[reagents.get_description(user,rc_flags)]</span>"
			/obj/item/reagent_containers

	on_reagent_change()
		if (reagents.total_volume)
			var/datum/color/average = reagents.get_average_color()
			fluid_image.color = average.to_rgba()
			src.UpdateOverlays(src.fluid_image, "fluid")
		else
			src.UpdateOverlays(null, "fluid")

	HasEntered(AM as mob|obj)
		if (iscarbon(AM))
			var/mob/M =	AM
			if (src.reagents)
				src.reagents.reaction(M, TOUCH)
				if(prob(25)) // the liquid splashes out as a puddle
					playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 25, 1)
					var/turf/T = get_turf(src)
					src.reagents.reaction(T, TOUCH)
					src.reagents.trans_to(T, 5)
				src.reagents.clear_reagents()

				var/atom/target = get_edge_target_turf(M, M.dir) // copied from space lube
				var/distance = 8
				// if(M.dir != src.dir || M.dir != turn(src.dir, 180))
				// 	distance = 1
				if(!M.hasStatus("weakened")) // prevents spam and makes em 'slow down' kinda more realistically
					M.pulling = null
					M.changeStatus("weakened", 3 SECONDS)
					boutput(M, "<span class='notice'>You slipped on [src]!</span>")
					playsound(src.loc, "sound/misc/slip.ogg", 50, 1, -3)
					M.throw_at(target, distance, 2, throw_type = THROW_SLIP)
				else
					M.throw_at(target, 1, 1, throw_type = THROW_SLIP)
