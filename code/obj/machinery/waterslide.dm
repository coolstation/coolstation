// legally distinct water slides! deploy a line of slippery tiles that apply touch chems! wowie!

/obj/machinery/waterslide_pump
	name = "water slide pump"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "waterslidepump"
	desc = "A pump and hose attached to a big roll of plastic."
	density = 0 // Being able to step through this makes the 'sliding' part more intuitive

	var/active = FALSE
	var/deployed = FALSE

	var/steps = 7
	var/max_steps = 15
	var/min_steps = 1
	var/current_step = 1

	var/list/deployed_path = null

	var/obj/item/reagent_containers/fluidtank = null

	New()
		..()

		fluidtank = new/obj/item/reagent_containers/food/drinks/fueltank/chlorine/mostly_water(src)
		update_icon()

	proc/update_icon()
		var/image/under = image(src.icon, "waterslidepump-under", dir=src.dir) // very hacky way to show dir on the icon
		var/image/endpiece = image(src.icon, "waterslide-end", dir=turn(src.dir, 180))
		src.ClearAllOverlays()
		if(deployed)
			src.underlays += under
			src.underlays += endpiece
			src.ClearSpecificOverlays("pump")
			src.ClearSpecificOverlays("roll")
			if(active)
				icon_state = "waterslidepump-active"
			else
				icon_state = "waterslidepump"
		else
			src.underlays = null
			src.UpdateOverlays(image(src.icon, "waterslidepump"), "pump")
			src.UpdateOverlays(image(src.icon, "waterslidepump-roll"), "roll")
			icon_state = "waterslidepump-under"


	disposing()
		active = FALSE
		deployed = FALSE
		fluidtank.dispose()
		for(var/obj/item/reagent_containers/waterslide/slide_tile in deployed_path)
			slide_tile.dispose()

		deployed_path = null
		fluidtank = null

		..()

	process()
		if(active && deployed)
			if(current_step > deployed_path.len)
				current_step = 1
			if(!fluidtank || fluidtank.reagents.total_volume <= 0)
				current_step = 1
				src.visible_message("<span class='alert'>\The [src] makes a grumpy noise and shuts down!</span>")
				playsound(src, "sound/machines/buzz-sigh.ogg", 50)
				active = FALSE
				update_icon()
				return

			var/obj/item/reagent_containers/waterslide/section = deployed_path[current_step]
			if(section.reagents.total_volume <= 0)

				fluidtank.reagents.trans_to(section,5)
			if(src.fluidtank.reagents.total_volume <= 0)
				current_step = 1
				src.visible_message("<span class='alert'>\The [src] makes a grumpy noise and shuts down!</span>")
				playsound(src, "sound/machines/buzz-sigh.ogg", 50)
				update_icon()
				active = FALSE
				return

			current_step += 1

	proc/establish_slide()
		deployed_path = new/list()
		var/turf/T = get_step(src,src.dir)
		var/range_slide = 1
		while((get_dist(src,T) < steps) && (range_slide < max_steps)) // copied from fireburp code
			T = get_step(T,src.dir)
			range_slide ++
		var/list/affected_turfs = getline(src, T)

		var/turf/currentturf
		var/turf/previousturf

		if(affected_turfs.len <= 0)
			return

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
			if(deployed_path.len == steps)
				var/obj/item/reagent_containers/waterslide/last = deployed_path[deployed_path.len]
				last.icon_state = "waterslide-end"

		if(deployed_path.len)
			current_step = 1
			deployed = TRUE
			anchored = 1
			update_icon()
			SPAWN_DBG(0) process()
			src.updateUsrDialog()

	proc/remove_slide()
		deployed = FALSE
		anchored = 0
		update_icon()
		for(var/obj/item/reagent_containers/waterslide/slide_tile in deployed_path)
			slide_tile.dispose()

		deployed_path = null
		src.updateUsrDialog()

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/glass/) || istype(W, /obj/item/reagent_containers/food/drinks/))
			if(src.fluidtank)
				boutput(user, "There is already a fluid tank loaded.")
				return
			else
				user.drop_item()
				W.set_loc(src)
				src.fluidtank = W
				boutput(user, "<span class='alert'>You load [W] into [src].</span>")
			src.updateUsrDialog()

/obj/machinery/waterslide_pump/attack_hand(mob/user as mob)
	var/dat

	dat += "<TT><B>Bringing Hours of Wet N' Wild Fun To Your Station!</B></TT><BR>"

	dat += "<U><h4>Fluid tank:</h4></U>"
	if(!fluidtank)
		dat += "Please insert fluid tank.<BR>"
	else if (!fluidtank.reagents.total_volume)
		dat += "Fluid tank is empty. "
		dat += "<A href='byond://?src=\ref[src];eject=1'>Eject fluid tank</A><BR>"
	else
		dat += "<A href='byond://?src=\ref[src];eject=1'>Eject fluid tank</A><BR>"
	dat += "<U><h4>Pump active:</h4></U>"
	dat += "<A href='byond://?src=\ref[src];active_toggle=1'>[src.active ? "True" : "False"]</A><BR>"
	dat += "<U><h4>Slide deployed:</h4></U>"
	dat += "<A href='byond://?src=\ref[src];deploy_toggle=1'>[src.deployed ? "True" : "False"]</A><BR>"
	dat += "<U><h4>Slide length:</h4></U>"
	dat += "<A href='byond://?src=\ref[src];op=set_range'>[steps] tiles</A><BR>"

	user.Browse("<HEAD><TITLE>Waterslide Pump</TITLE></HEAD>[dat]", "window=waterslide")
	onclose(user, "waterslide")
	return

/obj/machinery/waterslide_pump/Topic(href, href_list)
	if(!IN_RANGE(usr, src, 1))
		boutput(usr, "You're too far away from [src], get closer.")
		return

	if (href_list["eject"])
		fluidtank.set_loc(src.loc)
		usr.put_in_hand_or_eject(fluidtank)
		fluidtank = null

	if(href_list["active_toggle"])
		if(deployed)
			active = !active
			update_icon()
		else
			boutput(usr, "You need to deploy the slide first.")


	if(href_list["deploy_toggle"])
		if(active)
			boutput(usr, "You need to turn off [src] first.")
			return
		switch(deployed)
			if(TRUE)
				remove_slide()
			if(FALSE)
				establish_slide()
				usr.pulling = null
		update_icon()

	if(href_list["set_range"])
		var/value = input(usr,"Value:","") as num
		//var/value = input(usr, "Slide Range (1 - [max_steps]): ", "Enter Target Range", src.steps) as num
		if (!isnum(value)) return
		steps = clamp(value, min_steps, max_steps)

	attack_hand(usr)

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
			if (src.reagents.total_volume)
				src.reagents.reaction(M, TOUCH)
				if(prob(25)) // the liquid splashes out as a puddle
					playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 25, 1)
					var/turf/T = get_turf(src)
					src.reagents.reaction(T, TOUCH)
					src.reagents.trans_to(T, 5)
				src.reagents.clear_reagents()

				if(M.dir == src.dir || M.dir == turn(src.dir, 180))
					if(!M.hasStatus("weakened"))
						//Find distance from mob to the furthest water slide tile. Too complicated for something so silly? Maybe...
						var/distance = 1
						var/direction = src.dir ? M.dir == src.dir : turn(src.dir, 180)
						var/turf/T = get_step(src,direction)
						var/search = 1
						while((get_dist(src,T) < 15) && (search < 15)) // 15 may be too absurd?
							T = get_step(T,src.dir)
							search ++
						var/list/affected_turfs = getline(src, T)

						var/turf/currentturf
						var/turf/previousturf

						for(var/turf/F in affected_turfs)
							if(previousturf && LinkBlocked(previousturf, currentturf))
								break
							if(locate(/obj/item/reagent_containers/waterslide) in F)
								distance ++

						// Actually slip the mob, copied from space lube
						var/atom/target = get_edge_target_turf(M, M.dir)
						M.pulling = null
						M.changeStatus("weakened", 3 SECONDS)
						boutput(M, "<span class='notice'>You slipped on [src]!</span>")
						playsound(src.loc, "sound/misc/slip.ogg", 50, 1, -3)
						M.throw_at(target, distance, 2, throw_type = THROW_SLIP)
				else
					if (M.slip(ignore_actual_delay = 1))
						return
