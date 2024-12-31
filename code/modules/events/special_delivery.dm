//An event in which a bunch of Shit gets shipped to cargo and it's the station's problem now.
//Intended reactions: "oh god where do we leave all this trash?" and "oh god everyone's coming to steal this"

/datum/random_event/major/special_delivery
	name = "Special Delivery"
	centcom_headline = "Special Delivery"
	centcom_message = {"NTFC thinks y'all are bitchin' and is sending you some cool stuff."}
	customization_available = TRUE
	var/list/categories
	var/waiting_on_the_cargo_shuttle = FALSE
	///
	var/payload = "random"


	New()
		..()
		//Belt cargo struggles at bulk receiving
		SPAWN_DBG(1) //apparently map_settings doesn't exist yet
			if (map_settings.qm_supply_type != "shuttle")
				src.disabled = TRUE
			categories = list("garbage" = 100, "fuel" = 100, "atmospherics" = 75, /*"contraband" = 25, "mechanics" = 75, */"ore" = 100, "artifacts" = 100, "pizza" = 25)
			RegisterSignal(transit_controls, COMSIG_TRANSIT_VEHICLE_READY, PROC_REF(shuttle_ready))

	admin_call(source)
		if (..())
			return
		var/target_amount = input(usr, "What category of delivery?", "Special Delivery", "garbage") as null|anything in categories
		if (target_amount)
			event_effect(source, target_amount)


	event_effect(source, cargo_type = "random")
		//var/index = transit_controls.vehicles.Find("cargo_shuttle")
		var/datum/transit_vehicle/cargo_shuttle/cargo_shuttle = transit_controls.vehicles["cargo_shuttle"]
		if (cargo_shuttle.current_location.stop_id != "cargo_hub" || cargo_shuttle.in_transit)
			waiting_on_the_cargo_shuttle = TRUE


		//index = transit_controls.stops.Find("cargo_hub")
		var/datum/transit_stop/cargo_hub/cargo_hub = transit_controls.stops["cargo_hub"]
		cargo_hub.departure_free = FALSE



		var/message = "To " + pick("make room in our shipping hub", "make a regrettable purchase go away", "fulfill a contract to the letter", "help some numbers match") + ", your station will shortly recieve a shipment of "


		if (cargo_type == "random")
			cargo_type = weighted_pick(categories)
		switch (cargo_type)
			if ("garbage") //
				message += "assorted knick-knacks"
			if ("fuel") //welding fuel and plasma and maybe some other stuff
				message += "fuel"
			if ("atmospherics") //an amount of canisters
				message += "pressurised atmospheric canisters"
			if ("contraband") //traitor gear
				message += "confiscated goods and contraband"
			if ("mechanics") //prefabbed mechanics frames
				message += "prefabricated machinery frames"
			if ("ore")
				message += "ores and scrap metal"
			if ("artifacts")
				message += pick("alien artifacts", "watchamacallits", "weird crap")
			if ("pizza") //pizza is kinda rare cause it might end up a bit boring otherwise.
				message += pick("pizza", "authentic Italian cuisine", "last night's leftovers")

		message += ". Process the shipment as you see fit[cargo_type == "artifacts" ? "." : ", but do not return anything to us."] Please direct any questions or complaints to NanoTrasen Central Logistics Office, Earth."
		centcom_message = message
		payload = cargo_type

		..() //send out centcomm message

		if (!src.waiting_on_the_cargo_shuttle) //ready to go immediately
			spawn_payload()
			cargo_hub.departure_free = TRUE
			transit_controls.move_vehicle("cargo_shuttle", "cargo_dock", "(Special Delivery Event)")



/datum/random_event/major/special_delivery/proc/spawn_payload()
	var/list/obj/shit_in_crates = list()
	//Large objects, but will also contain the crates containing small objects later.
	var/list/obj/shit_in_the_open = list()

	switch (payload)
		if ("garbage") //
			var/obj/trash
			var/path
			for(var/i in 1 to rand(20,60))
				switch (rand(1,100))
					if (1 to 85)
						path = pick(generic_gift_paths)
					if (86 to 97) //small chance of christmas tat
						path = pick(xmas_gift_paths)
					if (98 to 100) //smaller chance of spicy tat :3
						path = pick(questionable_generic_gift_paths) //I think overall the odds are mildly spicier than christmas stockings though?
				trash = new path
				if (istype(trash, /obj/item))
					shit_in_crates += trash
				else
					shit_in_the_open += trash

		if ("fuel") //welding fuel and plasma and maybe some other stuff
			for(var/i in 1 to rand(7,13))
				switch(rand(1,100))
					if (1 to 30)
						shit_in_the_open += new /obj/machinery/portable_atmospherics/canister/toxins
					if (31 to 60)
						shit_in_the_open += new /obj/reagent_dispensers/fueltank
					if (61 to 100)
						shit_in_crates += new /obj/item/reagent_containers/food/drinks/fueltank

		if ("atmospherics") //an amount of canisters
			for(var/i in 1 to rand(5,11))
				switch(rand(1,100))
					if (1 to 21)
						shit_in_the_open += new /obj/machinery/portable_atmospherics/canister/air
					if (22 to 33)
						shit_in_the_open += new /obj/machinery/portable_atmospherics/canister/air/large
					if (34 to 42)
						shit_in_the_open += new /obj/machinery/portable_atmospherics/canister/carbon_dioxide
					if (43 to 58)
						shit_in_the_open += new /obj/machinery/portable_atmospherics/canister/nitrogen
					if (59 to 69)
						shit_in_the_open += new /obj/machinery/portable_atmospherics/canister/toxins
					if (70 to 80)
						shit_in_the_open += new /obj/machinery/portable_atmospherics/canister/empty
					if (81 to 91)
						shit_in_the_open += new /obj/machinery/portable_atmospherics/canister/oxygen
					if (92 to 94)
						shit_in_the_open += new /obj/machinery/portable_atmospherics/canister/sleeping_agent
					if (95 to 97)
						shit_in_the_open += new /obj/machinery/portable_atmospherics/canister/farts
					if (98 to 100)
						shit_in_the_open += new /obj/machinery/portable_atmospherics/canister/oxygen_agent_b
		if ("contraband") //traitor gear, cause
		if ("mechanics") //prefabbed mechanics frames
			//Okay so it turns out that there's only 4 predefined mechanics frames. All the department in a crate kits from cargo make the frames dynamically
			//So if I wanted to do this, I'd have to figure out myself what shit should show up in these and that's just too much mental load atm
		if ("ore")
			//this one kinda sucks and I want to make a better one someday
			var/list/valid_ores = childrentypesof(/obj/item/raw_material) - list(/obj/item/raw_material/chitin, /obj/item/raw_material/ice, /obj/item/raw_material/scrap_metal, /obj/item/raw_material/shard)
			for(var/i in 1 to rand(20,60))
				var/path = pick(valid_ores)
				shit_in_crates += new path
		if ("artifacts")
			//Artifact_Spawn only spawns when given an object or turf, so let's cheat that
			var/obj/dummy/D = new
			for(var/i in 1 to rand(5,13))
				Artifact_Spawn(D)
			for(var/obj/artifact as anything in D.contents)
				if (istype(artifact, /obj/item))
					shit_in_crates += artifact
				else
					shit_in_the_open += artifact
				artifact.set_loc(null) //when we delete D it'd delete all its contents with it
			qdel(D)
		if ("pizza")
			var/list/pizzae = concrete_typesof(/obj/item/reagent_containers/food/snacks/pizza)
			for(var/i in 1 to rand(8,24)) //1 to 3 crates worth
				var/path = pick(pizzae)
				if (path == /obj/item/reagent_containers/food/snacks/pizza/xmas) //making spacemas pizza rare by needing to roll it twice in a row (1/5th*1/5th)
					path = pick(pizzae)
				shit_in_crates += new path

	for (var/obj/big_obj as anything in shit_in_the_open) //mark em now before the crates get added, because we don't want those to get marked.
		big_obj.object_flags |= SPECIAL_PENALTY_ON_SALE //Doesn't do anything ATM though, shuttle cargo isn't set up to take loose items besides arts (who I didn't penalise)

	var/crate_path = pick(list(/obj/storage/crate, /obj/storage/crate/wooden))
	var/obj/storage/crate/current_crate = new crate_path
	var/space_this_crate = 8
	for (var/obj/small_obj as anything in shit_in_crates)
		small_obj.object_flags |= SPECIAL_PENALTY_ON_SALE
		small_obj.set_loc(current_crate)
		space_this_crate--
		if (!space_this_crate)
			shit_in_the_open += current_crate
			crate_path = pick(list(/obj/storage/crate, /obj/storage/crate/wooden))
			current_crate = new crate_path
			space_this_crate = 8

	if (length(current_crate.contents)) //last crate likely needs to be added to the shipping list still
		shit_in_the_open += current_crate
	else //amount of crap spawned perfectly divisible by 8, so we have an empty crate at the end we didn't need
		qdel(current_crate)

	for (var/i in 1 to length(shit_in_the_open))
		var/obj/to_receive = pick(shit_in_the_open)
		shit_in_the_open -= to_receive
		shippingmarket.receive_crate(to_receive, FALSE) // don't spam em with like a dozen messages


/datum/random_event/major/special_delivery/proc/shuttle_ready(source, datum/transit_vehicle/vehicle)
	if (vehicle.vehicle_id != "cargo_shuttle")
		return
	if (!src.waiting_on_the_cargo_shuttle)
		return
	if (vehicle.current_location.stop_id == "cargo_hub")
		spawn_payload()

		var/datum/transit_stop/cargo_hub/cargo_hub = vehicle.current_location
		SPAWN_DBG(rand(30 SECONDS, 60 SECONDS)) //pad the time a bit to make it look like it takes a bit to load everything on
			cargo_hub.departure_free = TRUE
			transit_controls.move_vehicle("cargo_shuttle", "cargo_dock", "(Special Delivery Event)")
			src.waiting_on_the_cargo_shuttle = FALSE
	else
		transit_controls.move_vehicle("cargo_shuttle", "cargo_hub", "(Special Delivery Event)") //immediate yoink, rude
