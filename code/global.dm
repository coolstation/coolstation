#ifdef DELETE_QUEUE_DEBUG
var/global/list/detailed_delete_count = list()
var/global/list/detailed_delete_gc_count = list()
#endif

#ifdef MACHINE_PROCESSING_DEBUG
var/global/list/detailed_machine_timings = list()
var/global/list/detailed_machine_power = list()
var/global/list/detailed_machine_power_prev = list()
#endif

#ifdef QUEUE_STAT_DEBUG
var/global/list/queue_stat_list = list()
#endif

// dumb, bad
var/list/extra_resources = list('code/pressstart2p.ttf', 'ibmvga9.ttf', 'xfont.ttf')
// Press Start 2P - 6px
// PxPlus IBM VGA9 - 12px


// -------------------- GLOBAL VARS --------------------

var/global

	serverKey = 0

	lagcheck_enabled = 0

	vpn_blacklist_enabled = TRUE

	datum/datacore/data_core = null

	atom/movable/screen/renderSourceHolder
	obj/overlay/zamujasa/round_start_countdown/game_start_countdown	// Countdown clock for round start
	list/globalImages = list() //List of images that are always shown to all players. Management procs at the bottom of the file.
	list/image/globalRenderSources = list() //List of images that are always attached invisibly to all player screens. This makes sure they can be used as rendersources.
	list/aiImages = list() //List of images that are shown to all AIs. Management procs at the bottom of the file.
	list/aiImagesLowPriority = list() //Same as above but these can wait a bit when sending to clients
	list/clients = list()
	list/mobs = list()
	list/ai_mobs = list()
	list/processing_items = list()
	list/processing_mechanics = list()
	list/health_update_queue = list()
	list/processing_fluid_groups = list()
	list/processing_fluid_spreads = list()
	list/processing_fluid_drains = list()
	list/processing_fluid_turfs = list()
	list/warping_mobs = list()
	datum/hotspot_controller/hotspot_controller = new
		//items that ask to be called every cycle

	list/muted_keys = list()

	server_start_time = 0
	round_time_check = 0			// set to world.timeofday when round starts, then used to calculate round time
	defer_powernet_rebuild = 0		// true if net rebuild will be called manually after an event
	machines_may_use_wired_power = 0
	regex/url_regex = null
	force_random_names = 0			// for the pre-roundstart thing
	force_random_looks = 0			// same as above

	// disables the "you can't respawn with the same character or slot" checks for admins
	// verbs like respawn-as-self will bypass this entirely.
	admins_can_reuse_characters = 1

	list/default_mob_static_icons = list() // new mobs grab copies of these for themselves, or if their chosen type doesn't exist in the list, they generate their own and add it
	list/mob_static_icons = list() // these are the images that are actually seen by ghostdrones instead of whatever mob
	list/orbicons = list()

	list/browse_item_icons = list()
	list/browse_item_clients = list()
	browse_item_initial_done = 0

	//INTENT: part of approach to show icons next to qm supply categories
	//stub from when i worked on this like in 2023 or whenever, will revisit i promise
	//list/browse_supply_pack_icons = list()
	//list/browse_supply_pack_clients = list()
	//browse_supply_pack_initial_done = 0

	list/rewardDB = list() //Contains instances of the reward datums
	list/materialRecipes = list() //Contains instances of the material recipe datums
	list/materialProps = list() //Contains instances of the material property datums

	list/factions = list()

	list/traitList = list() //List of trait objects

	list/spawned_in_keys = list() //Player keys that have played this round, to prevent that "jerk gets deleted by a bug, gets to respawn" thing.

	list/random_pod_codes = list() // if /obj/random_pod_spawner exists on the map, this will be filled with refs to the pods they make, and people joining up will have a chance to start with the unlock code in their memory

	list/spacePushList = list()
	/// Every location with a unique name for the jump verb
	list/unique_areas_with_turfs = list()
	/// All the accessible areas on the station in one convenient place
	list/station_areas = list()
	/// The station_areas list is up to date. If something changes an area, make sure to set this to 0
	area_list_is_up_to_date = 0

	already_a_dominic = 0 // no just shut up right now, I don't care

	footstep_extrarange = 0 // lol same (modified hackily in mobs.dm to avoid lag from sound at high player coutns)

	list/cursors_selection = list("Default" = 'icons/cursors/target/default.dmi',
	"Red" = 'icons/cursors/target/red.dmi',
	"Green" = 'icons/cursors/target/green.dmi',
	"Blue" = 'icons/cursors/target/blue.dmi',
	"Yellow" = 'icons/cursors/target/yellow.dmi',
	"Cyan" = 'icons/cursors/target/cyan.dmi',
	"White" = 'icons/cursors/target/white.dmi',
	"Rainbow" = 'icons/cursors/target/rainbow.dmi',
	"Animated Rainbow" = 'icons/cursors/target/rainbowanimated.dmi',
	"Flashing" = 'icons/cursors/target/flashing.dmi',
	"Minimalistic" = 'icons/cursors/target/minimalistic.dmi',
	"Flat" = 'icons/cursors/target/flat.dmi',
	"Small" = 'icons/cursors/target/small.dmi')

	list/hud_style_selection = list("New" = 'icons/ui/hud_human_new.dmi',
	"Old" = 'icons/ui/hud_human.dmi',
	"Classic" = 'icons/ui/hud_human_classic.dmi',
	"Mithril" = 'icons/ui/hud_human_quilty.dmi',
	"Vaporized" = 'icons/ui/hud_human_vapor.dmi')

	list/underwear_styles = list("No Underwear" = "none",
	"Briefs" = "briefs",
	"Boxers" = "boxers",
	"Bra and Panties" = "brapan",
	"Tanktop and Panties" = "tankpan",
	"Bra and Boyshorts" = "braboy",
	"Tanktop and Boyshorts" = "tankboy",
	"Panties" = "panties",
	"Boyshorts" = "boyshort",
	"Fig Leaf" = "figleaf")

	list/standard_skintones = list("Albino" = "#FAD7D0",
	"White" = "#FFCC99",
	"Pink" = "#EDB8A8",
	"Olive" = "#CEAB69",
	"Tan" = "#BD8A57",
	"Sunburned" = "#EDAFAB",
	"Black" = "#935D37",
	"Dark" = "#483728")

	list/handwriting_styles = list("Aguafina Script",
	"Alex Brush",
	"Allan",
	"Allura",
	"Annie Use Your Telescope",
	"Architects Daughter",
	"Arizonia",
	"Bad Script",
	"Bilbo Swash Caps",
	"Bilbo",
	"Calligraffitti",
	"Cedarville Cursive",
	"Clicker Script",
	"Coming Soon",
	"Condiment",
	"Cookie",
	"Courgette",
	"Covered By Your Grace",
	"Crafty Girls",
	"Damion",
	"Dancing Script",
	"Dawning of a New Day",
	"Delius Swash Caps",
	"Delius Unicase",
	"Delius",
	"Devonshire",
	"Engagement",
	"Euphoria Script",
	"Fondamento",
	"Give You Glory",
	"Gloria Hallelujah",
	"Gochi Hand",
	"Grand Hotel",
	"Great Vibes",
	"Handlee",
	"Herr Von Muellerhoff",
	"Homemade Apple",
	"Indie Flower",
	"Italianno",
	"Julee",
	"Just Another Hand",
	"Just Me Again Down Here",
	"Kalam",
	"Kaushan Script",
	"Kristi",
	"La Belle Aurore",
	"Leckerli One",
	"Lobster Two",
	"Lobster",
	"Loved by the King",
	"Lovers Quarrel",
	"Marck Script",
	"Meddon",
	"Merienda One",
	"Merienda",
	"Molle",
	"Montez",
	"Mr Dafoe",
	"Mr De Haviland",
	"Mrs Saint Delafield",
	"Neucha",
	"Niconne",
	"Norican",
	"Nothing You Could Do",
	"Over the Rainbow",
	"Pacifico",
	"Parisienne",
	"Patrick Hand SC",
	"Patrick Hand",
	"Petit Formal Script",
	"Pinyon Script",
	"Playball",
	"Quintessential",
	"Qwigley",
	"Rancho",
	"Redressed",
	"Reenie Beanie",
	"Rochester",
	"Rock Salt",
	"Rouge Script",
	"Sacramento",
	"Satisfy",
	"Schoolbell",
	"Shadows Into Light Two",
	"Shadows Into Light",
	"Short Stack",
	"Sofia",
	"Stalemate",
	"Sue Ellen Francisco",
	"Sunshiney",
	"Swanky and Moo Moo",
	"Tangerine",
	"The Girl Next Door",
	"Unkempt",
	"Vibur",
	"Waiting for the Sunrise",
	"Walter Turncoat",
	"Yellowtail",
	"Yesteryear",
	"Zeyada")

	list/selectable_ringtones = list()

	//april fools
	manualbreathing = 0
	manualblinking = 0
	speechpopups = 1

	monkeysspeakhuman = 0
	late_traitors = 1
	no_automatic_ending = 0

	sound_waiting = 1
	soundpref_override = 0

	diary = null
	diary_name = null
	hublog = null
	game_version = "Coolstation 13 (r" + vcs_revision + ")"

	master_mode = "traitor"

	host = null
	game_start_delayed = 0
	game_end_delayed = 0
	game_end_delayer = null
	ooc_allowed = 1
	looc_allowed = 1
	dooc_allowed = 1
	player_capa = 0
	player_cap = 55
	player_cap_grace = list()
	traitor_scaling = 1
	deadchat_allowed = 1
	debug_mixed_forced_wraith = 0
	debug_mixed_forced_blob = 0
	farting_allowed = 1
	resonance_fertscade = 0
	random_emotesounds = 1
	blood_system = 1
	bone_system = 0
	pull_slowing = 0
	suicide_allowed = 1
	dna_ident = 1
	abandon_allowed = 1
	enable_fastpath = 1 // space fastpath default value
	enter_allowed = 1
	johnbus_location = 1
	johnbus_destination = 0
	johnbus_active = 0
	brigshuttle_location = 0
	miningshuttle_location = 0
	researchshuttle_location = 0
	shoppingshuttle_location = 0
	researchshuttle_lockdown = 0
	shipyardship_location = 0
	shipyardship_pre_densitymap = list()
	shipyardship_post_densitymap = list()
	shipyard_scrapwall_prob = 40
	toggles_enabled = 1
	announce_banlogin = 1
	announce_jobbans = 0
	channel_open = 0 // is the channel collapsed or is it open?


	outpost_destroyed = 0
	signal_loss = 0
	fart_attack = 0
	blowout = 0
	sandstorm = 0
	farty_party = 0
	deep_farting = 0

#ifdef APRIL_FOOLS
	ghost_invisibility = INVIS_NONE
	no_emote_cooldowns = 1
#else
	// Default ghost invisibility. Set when the game is over
	ghost_invisibility = INVIS_GHOST
	no_emote_cooldowns = 0
#endif


	datum/titlecard/lobby_titlecard

	total_souls_sold = 0
	total_souls_value = 0

	///////////////
	//Radio network passwords
	netpass_security = null
	netpass_heads = null
	netpass_medical = null
	netpass_banking = null
	netpass_cargo = null
	netpass_syndicate = null //Detomatix

	///////////////
	//cyberorgan damage thresholds for emagging without emag
	list/cyberorgan_brute_threshold = list("heart" = 0, "cyber_lung_L" = 0, "cyber_lung_R" = 0, "cyber_kidney_L" = 0, "cyber_kidney_R" = 0, "liver" = 0, "stomach" = 0, "intestines" = 0, "spleen" = 0, "pancreas" = 0, "appendix" = 0)
	list/cyberorgan_burn_threshold = list("heart" = 0, "cyber_lung_L" = 0, "cyber_lung_R" = 0, "cyber_kidney_L" = 0, "cyber_kidney_R" = 0, "liver" = 0, "stomach" = 0, "intestines" = 0, "spleen" = 0, "pancreas" = 0, "appendix" = 0)

	///////////////
	list/logs = list ( //Loooooooooogs
		"admin_help" = list (  ),
		"speech" = list (  ),
		"ooc" = list (  ),
		"combat" = list (  ),
		"station" = list (  ),
		"pdamsg" = list (  ),
		"admin" = list (  ),
		"mentor_help" = list (  ),
		"telepathy" = list (  ),
		"bombing" = list (  ),
		"signalers" = list (  ),
		"atmos" = list (  ),
		"debug" = list (  ),
		"pathology" = list (  ),
		"deleted" = list (  ),
		"vehicle" = list (  ),
		"tgui" = list (), //me 2
		"audit" = list()//im a rebel, i refuse to add that gross SPACING
	)
	savefile/compid_file 	//The file holding computer ID information
	do_compid_analysis = 1	//Should we be analysing the comp IDs of new clients?
	list/admins = list(  )
	list/onlineAdmins = list(  )
	list/whitelistCkeys = list(  )
	list/bypassCapCkeys = list(  )
	list/warned_keys = list()	// tracking warnings per round, i guess

	datum/dj_panel/dj_panel = new()
	datum/player_panel/player_panel = new()

	list/prisonwarped = list()	//list of players already warped
	list/wormholeturfs = list()
	bioele_accidents = 0
	bioele_shifts_since_accident = 0

	// Controllers
	datum/wage_system/wagesystem
	datum/shipping_market/shippingmarket

	datum/configuration/config = null
	datum/sun/sun = null

	datum/changelog/changelog = null
	datum/admin_changelog/admin_changelog = null

	list/datum/powernet/powernets = null

	join_motd = null
	rules = null
	forceblob = 0

	halloween_mode = 0

#ifdef RP_MODE
#define SIMS_MODE
#endif

#ifdef APRIL_FOOLS
#define SIMS_MODE
	literal_disarm = 1
#else
	literal_disarm = 0
#endif

#ifdef SIMS_MODE // idk if theres a smarter way to do this
	global_sims_mode = 1 // SET THIS TO 0 TO DISABLE SIMS MODE
#else
	global_sims_mode = 0 // SET THIS TO 0 TO DISABLE SIMS MODE
#endif

	narrator_mode = 0

	disable_next_click = 0

	//airlockWireColorToIndex takes a number representing the wire color, e.g. the orange wire is always 1, the dark red wire is always 2, etc. It returns the index for whatever that wire does.
	//airlockIndexToWireColor does the opposite thing - it takes the index for what the wire does, for example AIRLOCK_WIRE_IDSCAN is 1, AIRLOCK_WIRE_POWER1 is 2, etc. It returns the wire color number.
	//airlockWireColorToFlag takes the wire color number and returns the flag for it (1, 2, 4, 8, 16, etc)
	list/airlockWireColorToFlag = list()// = RandomAirlockWires()
	list/airlockIndexToFlag = list()
	list/airlockIndexToWireColor = list()
	list/airlockWireColorToIndex = list()
	list/APCWireColorToFlag = RandomAPCWires()
	list/APCIndexToFlag
	list/APCIndexToWireColor
	list/APCWireColorToIndex
	list/VendWireColorToFlag = RandomVendWires()
	list/VendIndexToFlag
	list/VendIndexToWireColor
	list/VendWireColorToIndex

	// drsingh global reaction cache to reduce cpu usage in handle_reactions (Chemistry-Holder.dm)
	list/chemical_reactions_cache = list()

	// SpyGuy global reaction structure to further recuce cpu usage in handle_reactions (Chemistry-Structure.dm)
	list/total_chem_reactions = list()
	list/chem_reactions_by_id = list() //This sure beats processing the monster above if I want a particular reaction. =I

	//SpyGuy: The reagents cache is now an associative list
	list/reagents_cache = list()

	// list of miscreants since mode is irrelevant
	list/miscreants = list()

	// New idea (as of 2024-10-25): for applicable objectives (global, trackable success/fail state mid-round), update this list so checking at end of round is easy.
	list/global_objective_status = list()

	// Antag overlays for admin ghosts, Syndieborgs and the like (Convair880).
	antag_generic = image('icons/mob/antag_overlays.dmi', icon_state = "generic")
	antag_syndieborg = image('icons/mob/antag_overlays.dmi', icon_state = "syndieborg")
	antag_traitor = image('icons/mob/antag_overlays.dmi', icon_state = "traitor")
	antag_changeling = image('icons/mob/antag_overlays.dmi', icon_state = "changeling")
	antag_wizard = image('icons/mob/antag_overlays.dmi', icon_state = "wizard")
	antag_vampire = image('icons/mob/antag_overlays.dmi', icon_state = "vampire")
	antag_hunter = image('icons/mob/antag_overlays.dmi', icon_state = "hunter")
	antag_werewolf = image('icons/mob/antag_overlays.dmi', icon_state = "werewolf")
	antag_emagged = image('icons/mob/antag_overlays.dmi', icon_state = "emagged")
	antag_insurgent = image('icons/mob/antag_overlays.dmi', icon_state = "insurgent")
	antag_vampthrall = image('icons/mob/antag_overlays.dmi', icon_state = "vampthrall")
	antag_head = image('icons/mob/antag_overlays.dmi', icon_state = "head")
	antag_rev = image('icons/mob/antag_overlays.dmi', icon_state = "rev")
	antag_revhead = image('icons/mob/antag_overlays.dmi', icon_state = "rev_head")
	antag_syndicate = image('icons/mob/antag_overlays.dmi', icon_state = "syndicate")
	antag_spyleader = image('icons/mob/antag_overlays.dmi', icon_state = "spy")
	antag_spyrecruit = image('icons/mob/antag_overlays.dmi', icon_state = "spyrecruit")
	antag_gang = image('icons/mob/antag_overlays.dmi', icon_state = "gang")
	antag_gang_leader = image('icons/mob/antag_overlays.dmi', icon_state = "gang_head")
	antag_grinch = image('icons/mob/antag_overlays.dmi', icon_state = "grinch")
	antag_wraith = image('icons/mob/antag_overlays.dmi', icon_state = "wraith")
	antag_omnitraitor = image('icons/mob/antag_overlays.dmi', icon_state = "omnitraitor")
	antag_blob = image('icons/mob/antag_overlays.dmi', icon_state = "blob")
	antag_wrestler = image('icons/mob/antag_overlays.dmi', icon_state = "wrestler")
	antag_spy_theft = image('icons/mob/antag_overlays.dmi', icon_state = "spy_thief")

	pod_wars_NT = image('icons/mob/antag_overlays.dmi', icon_state = "nanotrasen")
	pod_wars_NT_CMDR = image('icons/mob/antag_overlays.dmi', icon_state = "nanocomm")
	pod_wars_SY = image('icons/mob/antag_overlays.dmi', icon_state = "syndicate")
	pod_wars_SY_CMDR = image('icons/mob/antag_overlays.dmi', icon_state = "syndcomm")

	//QM Caches: It's Fine Don't Worry About It
	list/datum/supply_packs/qm_supply_cache = list() //the big fucker that i want to replace with the below list of lists
	//QM Vendor-Specific Lists
	list/datum/supply_packs/vendor_supply_caches = list() //this fucko needs to contain all the below fuckos
	//but i don't know how
	list/datum/supply_packs/nanotrasen_supply_cache = list() //nanotrasen direct order
	list/datum/supply_packs/engineering_supply_cache = list() //juicy engineering
	list/datum/supply_packs/construction_supply_cache = list() //construction comrade
	list/datum/supply_packs/electronics_supply_cache = list() //electronics libre
	list/datum/supply_packs/grocery_supply_cache = list() //giuseppe's grocery
	list/datum/supply_packs/heavy_supply_cache = list() //hafgan heavy equipment
	list/datum/supply_packs/vending_supply_cache = list() //vend-tech
	list/datum/supply_packs/party_supply_cache = list() //all celebrations are beautiful
	list/datum/supply_packs/misc_supply_cache = list() //anything that doesn't fit, pawn/junk shop (move to roaming trader imo)
	//need furniture, clothing, stationary, misc, but we're not doing that yet

	//Used for QM Ordering Categories
	list/QM_CategoryList = list()
	list/QM_SupplierList = list()

	//Okay, I guess this was getting constructed every time someone wanted something from it
	list/datum/syndicate_buylist/syndi_buylist_cache = list()

	//AI camera movement dealies
	defer_camnet_rebuild = 0 //What it says on the tin.
	camnet_needs_rebuild = 0 //Also what it says on the tin.
	list/obj/machinery/camera/dirty_cameras = list() //Cameras that should be rebuilt

	list/list/obj/machinery/camera/camnets = list() //Associative list keyed by network name, contains a list of each camera in a network.
	list/datum/particleSystem/mechanic/camera_path_list = list() //List of particlesystems that the connection display proc creates. I dunno where else to put it. :(
	camera_network_reciprocity = 1 //If camera connections reciprocate one another or if the path is calculated separately for each camera
	list/datum/ai_camera_tracker/tracking_list = list()

	centralConn = 1 //Are we able to connect to the central server?
	centralConnTries = 0 //How many times have we tried and failed to connect?

	/* nuclear reactor & parameter set, if it exists */
	obj/machinery/power/nuke/fchamber/nuke_core = null
	obj/machinery/power/nuke/nuke_turbine/nturbine = null
	datum/nuke_knobset/nuke_knobs = null

	//Resource Management
	list/localResources = list()
	list/cachedResources = list()
	cdn = "" //Contains link to CDN as specified in the config (if not locally testing)
	disableResourceCache = 0

	// for translating a zone_sel's id to its name
	list/zone_sel2name = list("head" = "head",
	"chest" = "chest",
	"l_arm" = "left arm",
	"r_arm" = "right arm",
	"l_leg" = "left leg",
	"r_leg" = "right leg")

	transparentColor = "#ff00e4"

	pregameHTML = null
	newplayerHTML = null

	list/cooldowns

	syndicate_currency = "[pick("Flooz","Beenz","Telecrystals","Telecrystals","Telecrystals","Telecrystals","Telecrystals","Telecrystals")]"

	whatcha_see_is_whatcha_get = TRUE

/proc/updateAreaLists()
	//Admin jump list
	for (var/area/A in get_areas_with_turfs(/area))
		if(!A.name)
			continue
		if(!length(A.name))
			continue
		unique_areas_with_turfs[A.name] += list(A)
	unique_areas_with_turfs = sortList(unique_areas_with_turfs)

	//Battle royale list
	var/list/L = list()
	var/list/areas = concrete_typesof(/area/station)
	for(var/A in areas)
		var/area/station/instance = locate(A)
		for(var/turf/T in instance)
			if(!isfloor(T) && is_blocked_turf(T) && istype(T,/area/sim/test_area) && T.z == 1)
				continue
			L[instance.name] = instance
	station_areas = L

	area_list_is_up_to_date = 1

//returns a list of all areas on a station
proc/get_accessible_station_areas()
	if(station_areas && area_list_is_up_to_date) // In case someone makes a new area
		return station_areas

	updateAreaLists()
	return station_areas

//returns all useable areas for admin jump as an associative list of lists
/proc/getUniqueAreas()
	if(length(unique_areas_with_turfs) && area_list_is_up_to_date)
		return unique_areas_with_turfs

	updateAreaLists()
	return unique_areas_with_turfs

/proc/addGlobalRenderSource(var/image/I, var/key)
	if(I && length(key) && !globalRenderSources[key])
		addGlobalImage(I, "[key]-renderSourceImage")
		I.render_target = key
		I.appearance_flags = KEEP_APART
		I.loc = renderSourceHolder
		globalRenderSources[key] = I
		return I
	return

/proc/removeGlobalRenderSource(var/key)
	set background = 1
	if(length(key) && globalRenderSources[key])
		globalRenderSources[key].loc = null
		removeGlobalImage("[key]-renderSourceImage")
		globalRenderSources[key] = null
		globalRenderSources.Remove(key)
	return

/proc/getGlobalRenderSource(var/key)
	if(length(key) && globalRenderSources[key]) return globalRenderSources[key]
	else return null

/proc/addGlobalImage(var/image/I, var/key)
	if(I && length(key))
		globalImages[key] = I
		world << I //Not sure what's faster.
		//for(var/client/C in clients)
		//	C.images += I
		return I
	return

/proc/getGlobalImage(var/key)
	if(length(key) && globalImages[key]) return globalImages[key]
	else return null

/proc/removeGlobalImage(var/key)
	if(length(key) && globalImages[key])
		for(var/client/C in clients)
			C.images -= globalImages[key]
		globalImages[key] = null
		globalImages.Remove(key)
	return

/// Generates item icons for manufacturers and other things, used in UI dialogs. Sends to client if needed.
// Note that a client that clears its cache won't get new icons. Deal with it. BYOND's browse_rsc is shite.
/proc/getItemIcon(var/atom/path, var/state, var/dir, var/key = null, var/client/C)
	if (!key)
		if (!state)
			state = initial(path.icon_state)
		if (!dir)
			dir = initial(path.dir)

		key = replacetext("[path]-[state]-[dir].png", "/", "~")
		if (!browse_item_icons[key])
			browse_item_icons[key] = new/icon(initial(path.icon), state, dir)

	if (C && !(C in browse_item_clients[key]))
		if (!browse_item_clients[key])
			browse_item_clients[key] = list()
		C << browse_rsc(browse_item_icons[key], key)
		browse_item_clients[key] += C

	return key

/// Sends all of the item icons to a client. Kinda gross, but whatever.
// The worst part of this is that client latency impacts this, so someone who is running slow
// is probably gonna break everything.
/proc/sendItemIcons(var/client/C)
	for (var/key in browse_item_icons)
		getItemIcon(key = key, C = C)

/// Sends all item icons to all clients. Used at world startup to preload things.
/proc/sendItemIconsToAll()
	browse_item_initial_done = 1
	for (var/client/C in clients)
		sendItemIcons(C)
