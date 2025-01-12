/**
 * Wanna make a room for a S P A C E S H I P ???? Cool!!!!!! All you have to do is make your prefab, name it
 * whatever, (has to be either 3x3 or 5x3 for now), and throw it in assets/maps/random_ships/(cargo or room)/size
 * NOTE: ALL PREFABS HAVE TO HAVE THE CLEAR_AREA AREA, AND ALL CARGO PREFABS MUST HAVE BOTH CLEAR_TURF AND CLEAR_AREA <3
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
	var/shipworth = 0
	var/payoutMod = 0

	var/destroyedMalus = -300
	var/repairedBonus = 100

	var/step = 1
	for (var/S in postWork)
		if(S != preWork[step] && S == 0) //deducts half points for replacing a wall with a floor
			payoutMod += destroyedMalus / 2
		else if(S != preWork[step] && S == 2) //deducts full points for replacing anything with a space tile(destroying)
			payoutMod += destroyedMalus
		else if(S == preWork[step]) //rewards points for matching the original design
			payoutMod += repairedBonus
		step += 1
	if(payoutMod != 0)
		shipworth += payoutMod
	else
		shipworth = 0

	for(var/datum/data/record/record in data_core.bank)
		if(record.fields["job"] == "Scrapper")
			record.fields["current_money"] += shipworth

	var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("[FREQ_PDA]")
	var/datum/signal/pdaSignal = get_free_signal()
	pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="SHIPYARD-MAILBOT",  "group"=list(MGD_CARGO, MGA_SHIPPING, MGO_MINING), "sender"="00000000", "message"="Notification: Payment of: [shipworth] recieved from client ship.")
	pdaSignal.transmission_method = TRANSMISSION_RADIO
	if(transmit_connection != null)
		transmit_connection.post_signal(null, pdaSignal)

proc/buildRandomShips() //This is byond a terrible fix which likely doesn't function anyway. A better way to do this would be to create two landmarks, one for the ships and another for the rooms.
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
		icon_state = "cargo"
	#endif

	room5x3
		size = "5x3"
		roomclass = "room"
	#ifdef IN_MAP_EDITOR
		icon = 'icons/map-editing/random-rooms/5x3.dmi'
		icon_state = "cargo"
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



	size30x25
		size = "30x25"
	#ifdef IN_MAP_EDITOR
		icon = 'icons/map-editing/random-rooms/30x25.dmi'
	#endif
