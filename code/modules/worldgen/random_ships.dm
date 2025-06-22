/**
 * Wanna make a room for a S P A C E S H I P ???? Cool!!!!!! All you have to do is make your prefab, name it
 * whatever, (has to be either 3x3 or 5x3 for now), and throw it in assets/maps/random_ships/(cargo or room)/size
 * NOTE: ALL PREFABS HAVE TO HAVE THE CLEAR_AREA AREA, AND ALL CARGO PREFABS MUST HAVE BOTH CLEAR_TURF AND CLEAR_AREA <3
 * oh ya you can make a spaceship too, just throw it in the 25x15 folder same as the rest :3
 * IMPORTANT: Please do not make your ship prefabs already destroyed. Just make how it would look if it were intact. There's code for that sweetie.
 */


TYPEINFO(/datum/mapPrefab/random_ship)
	folder = "random_ships"


/datum/mapPrefab/random_ship
	maxNum = 1 // Might be useful to add a way to override if someone ever wants that

	post_init()
		var/regex/size_regex = regex(@"^(\d+)x(\d+)$")
		for(var/tag in src.tags)
			if(size_regex.Find(tag))
				src.prefabSizeX = text2num(size_regex.group[1])
				src.prefabSizeY = text2num(size_regex.group[2])

		var/filename = filename_from_path(src.prefabPath)
		var/regex/probability_regex = regex(@"^.*_(\d+)\.dmm$")
		if(probability_regex.Find(filename))
			src.probability = text2num(probability_regex.group[1])

/datum/mapPrefab/random_ship
	maxNum = null

	post_init()
		var/regex/size_regex = regex(@"^(\d+)x(\d+)$")
		for(var/tag in src.tags)
			if(size_regex.Find(tag))
				src.prefabSizeX = text2num(size_regex.group[1])
				src.prefabSizeY = text2num(size_regex.group[2])

		var/filename = filename_from_path(src.prefabPath)
		var/regex/probability_regex = regex(@"^.*_(\d+)\.dmm$")
		if(probability_regex.Find(filename))
			src.probability = text2num(probability_regex.group[1])

proc/scrapperPayout(var/list/preWork,var/list/postWork) //TODO: ignore space tiles, take ONLY NEW empty tiles into account for better schtuff
	var/payout = 0
	var/scrappedBonus = 10

	var/step = 1
	for (var/S in postWork)
		if(S != preWork[step] && S == 0) //rewards points for destroying a wall
			payout += scrappedBonus
		step += 1

	for(var/datum/data/record/record in data_core.bank)
		if(record.fields["job"] == "Scrapper")
			record.fields["current_money"] += payout

	var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("[FREQ_PDA]")
	var/datum/signal/pdaSignal = get_free_signal()
	pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="SHIPYARD-MAILBOT",  "group"=list(MGD_CARGO, MGA_SHIPPING, MGO_MINING), "sender"="00000000", "message"="Notification: Payment of: [payout] recieved from client ship.")
	pdaSignal.transmission_method = TRANSMISSION_RADIO
	if(transmit_connection != null)
		transmit_connection.post_signal(null, pdaSignal)
	shipyardship_pre_densitymap = list()
	shipyardship_post_densitymap = list()

proc/prepShips(var/area/stagearea,var/area/start_location,var/area/end_location) //not efficient
	if(prob(60))
		explode_area(stagearea,rand(60,190),rand(1,3))
	SPAWN_DBG(7 SECONDS)
		shipyardship_pre_densitymap = calculate_density_map(stagearea)
		start_location.move_contents_to(end_location)
		shipyardship_location = 1

proc/processShips(var/area/shipyard)
	command_announcement("Shipyard decontamination process underway, please vacate the shipyard immediately.", "Shipyard Control Alert","sound/machines/engine_alert2.ogg")
	shipyardship_post_densitymap = calculate_density_map(shipyard)
	SPAWN_DBG(10 SECONDS)
		playsound_global(world, "sound/effects/radio_sweep5.ogg", 50)
		//gib_area(shipyard)
		scrapperPayout(shipyardship_pre_densitymap,shipyardship_post_densitymap)

proc/buildRandomShips()
	shuffle_list(by_type[/obj/landmark/random_ship])
	for_by_tcl(landmark, /obj/landmark/random_ship)
		landmark.apply()
	shuffle_list(by_type[/obj/landmark/random_ship_room]) //this happens twice, as the first landmark would be the 30x25 which then introduces many other ship landmarks that must be generated
	for_by_tcl(landmark, /obj/landmark/random_ship_room)
		landmark.apply()

/obj/landmark/random_ship_room
	var/size = null
	var/roomclass = null
	deleted_on_start = FALSE
	add_to_landmarks = FALSE

	New()
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	proc/apply()
		var/datum/mapPrefab/random_ship/ship_prefab = pick_map_prefab(/datum/mapPrefab/random_ship, list(roomclass,size))
		if(isnull(ship_prefab))
			CRASH("No random ship prefab found for size: " + size + ", and of type: " + roomclass)
		ship_prefab.applyTo(src.loc)
		logTheThing("debug", null, null, "Applied random ship prefab: [ship_prefab] to [log_loc(src)]")
		qdel(src)

	room3x3
		size = "3x3"
		roomclass = "room"
	#ifdef IN_MAP_EDITOR
		icon = 'icons/map-editing/random-rooms/3x3.dmi'
		icon_state = "room" //3x3 cargo icon also available, but no rooms yet
	#endif

	room5x3
		size = "5x3"
		roomclass = "room"
	#ifdef IN_MAP_EDITOR
		icon = 'icons/map-editing/random-rooms/5x3.dmi'
		icon_state = "room"
	#endif

	cargo5x3
		size = "5x3"
		roomclass = "cargo"
	#ifdef IN_MAP_EDITOR
		icon = 'icons/map-editing/random-rooms/5x3.dmi'
		icon_state = "cargo"
	#endif



/obj/landmark/random_ship
	var/size = null
	deleted_on_start = FALSE
	add_to_landmarks = FALSE

	New()
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	proc/apply()
		var/datum/mapPrefab/random_ship/ship_prefab = pick_map_prefab(/datum/mapPrefab/random_ship, list(size))
		if(isnull(ship_prefab))
			CRASH("No random ship prefab found for size: " + size)
		ship_prefab.applyTo(src.loc)
		logTheThing("debug", null, null, "Applied random ship prefab: [ship_prefab] to [log_loc(src)]")



	size25x15
		size = "25x15"
	#ifdef IN_MAP_EDITOR
		icon = 'icons/map-editing/random-rooms/30x25.dmi' //update this
	#endif
