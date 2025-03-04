// from loaf with love
// (C) 2022 Stonepillars <https://github.com/stonepillars>


ABSTRACT_TYPE(/datum/transit_stop)
ABSTRACT_TYPE(/datum/transit_stop/elevator)
/// Stops for a shuttle or elevator.
/datum/transit_stop
	/// Registry key for this stop.
	var/stop_id
	/// Display name of the location, used on the terminal
	var/name = "Call 1-800-CODER"
	/// Area to use when moving the vehicle.
	var/area/target_area
	/// The vehicle_id currently parked here.
	/// if the platform of the elevator or the shuttle starts here, copy it's ID here.
	var/current_occupant
	// any additional procs to call on landing at this stop? sure!
	proc/on_arrival()
		return
	/// Is something preventing this stop from being navigated to?
	proc/can_receive_vehicle()
		return TRUE

	/// Is something preventing the vehicle from leaving this stop?
	proc/vehicle_can_depart()
		return TRUE

ABSTRACT_TYPE(/datum/transit_vehicle)
/datum/transit_vehicle
	/// Registry key for this route.
	var/vehicle_id
	/// Stop IDs that this vehicle can stop at.
	var/list/stop_ids = list()
	/// List of transit stops this vehicle can visit.
	var/list/datum/transit_stop/stops = list()
	/// The transit_stop datum this vehicle is parked at.
	var/datum/transit_stop/current_location
	/// Whether the vehicle is currently moving
	var/in_transit = FALSE

	/// Called by transit_controls prior to area move.
	proc/departing(datum/transit_stop/destination)
		return TRUE

	/// Called after the area move
	proc/arriving(datum/transit_stop/destination)
		return TRUE


var/global/datum/transit_controller/transit_controls = new

/// Controller which manages transit routes
/datum/transit_controller
	/// Registry of vehicles by their id
	var/list/vehicles = list()
	/// Registry of stops by their id
	var/list/stops = list()

	New()
		..()
		var/used_stops = list()
		var/used_targets = list()
		var/datum/transit_stop/stop
		for(var/type in concrete_typesof(/datum/transit_stop))
			stop = get_singleton(type)
			if(!stop.stop_id)
				stack_trace("[type] has no stop_id")
				continue
			if(stop.stop_id in src.stops)
				stack_trace("[type] has duplicate id with [src.stops[stop.stop_id]]")
				continue
			if(!stop.target_area)
				stack_trace("[type] has no target_area")
				continue
			if(stop.target_area in used_targets)
				stack_trace("[type] dupes target area of [used_targets[stop.target_area]]")
				continue
			used_targets[stop.target_area] = type
			src.stops[stop.stop_id] = stop
		var/datum/transit_vehicle/vehicle
		for(var/type in concrete_typesof(/datum/transit_vehicle))
			vehicle = get_singleton(type)
			if(!vehicle.vehicle_id)
				stack_trace("[type] has no vehicle_id")
				continue
			if(vehicle.vehicle_id in src.vehicles)
				stack_trace("[type] has duplicate id with [src.vehicles[vehicle.vehicle_id]]")
				continue
			if(!length(vehicle.stop_ids))
				stack_trace("[type] has no stops")
				continue
			for(var/stop_id in vehicle.stop_ids)
				if(stop_id in used_stops) // TODO: Multiple vehicles, same route. Needs locking & Area magic.
					stack_trace("[type] shares a stop with [used_stops[stop_id]]")
					continue
				stop = src.stops[stop_id]
				if(!stop)
					stack_trace("[type] has invalid stop: [stop_id]")
					continue
				if(stop.current_occupant == vehicle.vehicle_id)
					vehicle.current_location = stop
				vehicle.stops += stop
				used_stops[stop_id] = type
			if(!vehicle.current_location)
				stack_trace("[type] has no starting location") // You need to set it's default stop.
				continue
			src.vehicles[vehicle.vehicle_id] = vehicle

	proc/move_vehicle(vehicle_id, stop_id, mob/user)
		var/datum/transit_stop/stop = src.stops[stop_id]
		if(!stop)
			return FALSE
		if(stop.current_occupant)
			return FALSE
		if(!stop.can_receive_vehicle())
			return FALSE
		var/datum/transit_vehicle/vehicle = src.vehicles[vehicle_id]
		if(vehicle.in_transit)
			return FALSE
		if(!length(vehicle.stops))
			return FALSE
		if(!(stop in vehicle.stops) && !(stop_id in vehicle.stop_ids))
			return FALSE
		var/datum/transit_stop/current = vehicle.current_location
		if(!current)
			return FALSE
		if(stop_id == current.stop_id || stop == current)
			return FALSE
		if(!current.vehicle_can_depart())
			return FALSE
		vehicle.in_transit = TRUE
		logTheThing("station", user, null, "began departure for vehicle [vehicle_id] to [stop_id] at [log_loc(usr)]")
		SPAWN_DBG(0)
			vehicle.departing(stop)
			var/area/start_location = locate(current.target_area)
			var/area/end_location = locate(stop.target_area)
			var/filler_turf_start = text2path(start_location.filler_turf)
			var/filler_turf_end = text2path(end_location.filler_turf)
			if (!filler_turf_start)
				filler_turf_start = "space"
			//need to figure out how to not hardcode the elevators into this
			start_location.move_contents_to(end_location, filler_turf_start, ignore_fluid = FALSE, consider_filler_as_empty = (istype(start_location, /area/transit_vehicle/elevator)))
			//I think this might be kinda superfluous now
			for (var/turf/P in end_location)
				if (istype(P, filler_turf_start))
					P.ReplaceWith(filler_turf_end, keep_old_material = 0, force=1)
			SEND_SIGNAL(src, COMSIG_TRANSIT_VEHICLE_MOVED, vehicle)
			vehicle.arriving(stop) //This may sleep, intentionally holding up this code
			vehicle.current_location = stop
			current.current_occupant = null
			stop.current_occupant = vehicle.vehicle_id
			vehicle.in_transit = FALSE
			SEND_SIGNAL(src, COMSIG_TRANSIT_VEHICLE_READY, vehicle)


		return TRUE


/turf/floor/specialroom/elevator_shaft
	name = "elevator shaft"
	desc = "It looks like it goes down a long ways."
	icon_state = "moon_shaft"
	has_material = FALSE //this is a big hole, the big hole is made of steel? yeah right buddy!!!
	var/fall_landmark = LANDMARK_FALL_DEBUG

	New()
		..()
		src.calculate_direction(TRUE)
		src.AddComponent(/datum/component/pitfall/target_landmark,\
			BruteDamageMax = 25,\
			HangTime = 0 SECONDS,\
			TargetLandmark = fall_landmark)

	proc/calculate_direction(var/propagate = FALSE)
		var/area_type = get_area(src)
		var/turf/floor/specialroom/elevator_shaft/n = get_step(src,NORTH)
		var/turf/floor/specialroom/elevator_shaft/e = get_step(src,EAST)
		var/turf/floor/specialroom/elevator_shaft/w = get_step(src,WEST)
		var/turf/floor/specialroom/elevator_shaft/s = get_step(src,SOUTH)

		if (!istype(get_area(n), area_type))
			n = null
		if (!istype(get_area(e), area_type))
			e = null
		if (!istype(get_area(w), area_type))
			w = null
		if (!istype(get_area(s), area_type))
			s = null
		if (!istype(n))
			n = null
		if (!istype(e))
			e = null
		if (!istype(w))
			w = null
		if (!istype(s))
			s = null

		if (n && e && w && s)
			src.icon_state = "shaft_center"
		else if (e && w && s)
			set_dir(NORTH)
		else if (n && e && w)
			set_dir(SOUTH)
		else if (n && w && s)
			set_dir(EAST)
		else if (n && e && s)
			set_dir(WEST)
		else if (n && e)
			set_dir(SOUTHWEST)
		else if (e && s)
			set_dir(NORTHWEST)
		else if (n && w)
			set_dir(SOUTHEAST)
		else if (s && w)
			set_dir(NORTHEAST)
		else
			src.icon_state = "shaft_single"

		if (propagate)
			n?.calculate_direction(FALSE)
			e?.calculate_direction(FALSE)
			w?.calculate_direction(FALSE)
			s?.calculate_direction(FALSE)

	ex_act(severity)
		return

ABSTRACT_TYPE(/datum/transit_vehicle/elevator)
/datum/transit_vehicle/elevator
	/// Time the elevator will wait before departing
	var/departure_delay = 2.5 SECONDS
	/// Time the elevator will wait before opening/closing the doors
	var/door_delay = 2 SECONDS
	/// Time the elevator is gauranteed to wait after arriving at a stop.
	var/disembark_time = 5 SECONDS
	var/door_id_prefix = "elevator-"

	departing(datum/transit_stop/destination)
		var/turf/target
		var/area/A = locate(src.current_location.target_area)
		target = pick(A.turfs)
		if(target)
			playsound(target, "sound/machines/elevator_move.ogg", 100, 0)
		else
			stack_trace("Vehicle [src.vehicle_id] had no turfs at stop [src.current_location.stop_id] ([src.current_location.target_area])")
		sleep(door_delay)
		for (var/obj/machinery/door/poddoor/M in by_type[/obj/machinery/door])
			if (M.id == "[src.door_id_prefix][src.current_location.stop_id]")
				M.close()
		sleep(departure_delay)
		for(var/mob/M in locate(destination.target_area)) // oh dear, stay behind the yellow line kids
			//if (!istype(M.loc, text2path(destination.target_area.filler_turf)) || locate(/obj/grille/catwalk) in M.loc) //once we make catwalks constructable you could play Hole In The Wall 2: Hole In The Ceiling
			SPAWN_DBG(1 DECI SECOND) // i dont think that check above was doing what it was meant to.
				random_brute_damage(M, 30)
				M.changeStatus("weakened", 5 SECONDS)
				M.emote("scream")
				playsound(M.loc, "sound/impact_sounds/Flesh_Break_1.ogg", 90, 1)
				#ifdef DATALOGGER
				game_stats.Increment("workplacesafety")
				#endif

	arriving(datum/transit_stop/destination)
		sleep(door_delay)
		for (var/obj/machinery/door/poddoor/M in by_type[/obj/machinery/door])
			if (M.id == "[src.door_id_prefix][destination.stop_id]")
				M.open()
		sleep(disembark_time) //This intentionally holds up the last part of move_vehicle

/obj/machinery/computer/transit_terminal
	name = "Vehicle Control"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "mmagnet"
	circuit_type = /obj/item/circuitboard/transit_terminal
	/// Transit ID of the Vehicle this terminal controls
	var/vehicle_id
	/// The transit vehicle datum we control
	var/datum/transit_vehicle/vehicle

	thin
		icon = 'icons/misc/mechanicsExpansion.dmi'
		icon_state = "comp_buttpanel"
		circuit_type = null
		density = FALSE
		glow_in_dark_screen = FALSE

	New()
		..()
		SPAWN_DBG(5 SECONDS)
			src.vehicle = transit_controls.vehicles[src.vehicle_id]
			if(!src.vehicle)
				stack_trace("vehicle [src.vehicle_id] invalid, deleting terminal")
				qdel(src)
				return

	ui_status(mob/user, datum/ui_state/state)
		. = min(
			..(),
			src.vehicle?.in_transit ? UI_UPDATE : UI_INTERACTIVE,
			src.allowed(user) ? UI_INTERACTIVE : UI_CLOSE
		)


	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "TransitTerminal", src.name)
			ui.open()

	ui_data(mob/user)
		if(!src.vehicle)
			. = list("panic"=TRUE)
		var/stops = list()
		for(var/datum/transit_stop/stop in src.vehicle.stops)
			stops += list(
				list(
					"id" = stop.stop_id,
					"disabled" = !!stop.current_occupant,
					"label" = stop.name
				)
			)
		. = list(
			"in_transit" = src.vehicle.in_transit,
			"stops" = stops
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if(.)
			return
		switch(action)
			if("move")
				var/stopname = params["stopname"]
				if(!transit_controls.move_vehicle(src.vehicle_id, stopname, ui.user))
					boutput("<span class='alert'>Something went wrong, the vehicle wont move!</span>")
					return FALSE
				playsound(src.loc, 'sound/machines/chime.ogg', 40, 0.5)
				return TRUE

//Bat here adding a button because (TG)UI is a bother
//We should bring all of the random buttons we got under a single banner sometime but this one gets a head start
/obj/machinery/button/elevator
	name = "elevator call button"
	desc = "Send an elevator back and forth for your amusement"
	icon = 'icons/obj/machines/buttons.dmi'
	icon_state = "elev_idle"
	anchored = 1
	//Which vehicle this button shuttles
	var/vehicle_id
	//Idem
	var/datum/transit_vehicle/our_vehicle
	//This button exists to save navigating the UI for elevators that just shuttle between two locations, if you want more than that you're better off using transit_terminal instead.
	var/stop_top_id
	var/stop_bottom_id

	New()
		..()
		SPAWN_DBG(1 SECOND)
			our_vehicle = transit_controls.vehicles[src.vehicle_id]
			if (!our_vehicle) //RIP
				status |= BROKEN //Safety permabrick ourselves
			else
				RegisterSignal(transit_controls, COMSIG_TRANSIT_VEHICLE_MOVED, PROC_REF(update_icon))
				RegisterSignal(transit_controls, COMSIG_TRANSIT_VEHICLE_READY, PROC_REF(update_icon))
			update_icon()

	attack_hand(mob/user)
		if (..()) // Range/sanity/power checks
			return
		if (our_vehicle.in_transit)
			return
		if (our_vehicle.current_location == transit_controls.stops[stop_bottom_id])
			transit_controls.move_vehicle(src.vehicle_id, stop_top_id, user)
			update_icon(,, "up")
		else
			transit_controls.move_vehicle(src.vehicle_id, stop_bottom_id, user)
			update_icon(,, "down")
		playsound(src.loc, 'sound/misc/handle_click.ogg', 40, 0.5)

	attackby(obj/item/I, mob/user) //smack in the button with yer loot, food, or thing to shoot
		attack_hand(user)

	proc/update_icon(dummy = null, datum/transit_vehicle/vehicle = null ,direction = null) //The first argument ends up being the transit controller and IDK signals well enough to know what to do about it
		if (status & (NOPOWER|BROKEN))
			icon_state = "elev_offline"
			return
		switch(direction)
			if ("up")
				icon_state = "elev_transit_up"
			if ("down")
				icon_state = "elev_transit_down"
			else//This handles signal-based calls
				if (vehicle == our_vehicle)
					icon_state = (our_vehicle.in_transit ? "elev_cooldown" : "elev_idle")

	disposing()
		UnregisterSignal(transit_controls, COMSIG_TRANSIT_VEHICLE_MOVED)
		UnregisterSignal(transit_controls, COMSIG_TRANSIT_VEHICLE_READY)
		our_vehicle = null
		..()
