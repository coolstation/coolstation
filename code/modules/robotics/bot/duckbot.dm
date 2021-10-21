//Amusing duck rewritten and slimmed down to behave more like the dumb toy, though it is still a menace when emagged.

/obj/machinery/bot/duckbot
	name = "Amusing Duck"
	desc = "Bump'n go action! Ages 3 and up."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "duckbot"
	//TODO LAYER
	layer = 5.0
	density = 0
	anchored = 0
	// ACTION
	on = 1
	health = 5
	bot_move_delay = 10
	no_camera = 1
	/// ha ha NO.
	dynamic_processing = 0
	//did it bump, into something?
	var/bump = 0
	//does it go, presently?
	var/go = 1
	//is it action, right now?
	var/action = 0
	//is it true, there is an egg to lay?
	var/layegg = 0
	/// Minimum time between gaggles and quacks
	var/quack_cooldown = 3 SECONDS
	/// To make sure MAKING NOISE IS TRUE is false
	var/amusement_cooldown = 10 SECONDS
	/// Pick someone, then mill around them making noise. If emagged is true.
	var/mob/annoy_target
	/// Though maybe pick someone else after a while
	var/annoy_timeout = 30 SECONDS
	/// And forget about who you annoyed after a while
	var/forget_annoyed_timeout = 15 SECONDS
	/// Don't spam that pathfinding
	var/annoy_path_cooldown = 2 SECONDS

	//Migration system
	/// Location on the station where all these damn things migrate to for whatever reason
	//var/static/area/duck_migration_target
	/// Someone set our migration path, let's go there instead of picking something
	//var/static/migration_override

/*
//no we are not hooking this up to the wifi
/obj/machinery/bot/duckbot/New()
	. = ..()
	if(radio_controller)
		radio_controller.add_object(src, "[FREQ_PDA]")
*/

/obj/machinery/bot/duckbot/process()
	. = ..()
	if(src.on == 1)
		if (!src.emagged)
			src.glide_size = 4 * world.tick_lag
			//bump
			if (src.bump && src.go && !src.annoy_target)
				src.dir = (prob(50) ? turn(src.dir,45) : turn(src.dir,90)) //chance to turn an additional amount in place
				src.bump = 0
				walk(src,src.dir,8,4 * world.tick_lag) //move forward, only forward
			//go
			else if (src.go && !src.annoy_target)
				//as the duck advancing
				if(prob(50)) //this is almost always turning right but sometimes it turns the other way just because
					walk(src,0)
					src.dir = ((prob(85) ? turn(src.dir,45) : turn(src.dir,-45)))
					walk(src,src.dir,8,4 * world.tick_lag)
				walk(src,src.dir,8,4 * world.tick_lag)
		else
			if (!src.annoy_target)
				if(prob(97))
					walk(src,0)
					src.navigate_to(get_step_rand(src)) //just go all over. fuck it. whatever.
				else
					walk(src,pick(alldirs)) //zoom
		//action
		if(prob (7) && src.layegg >= 1)
			//the duck stop, it swaying tail
			src.go = 0
			//then the duck lay an egg as open it's buttocks
			flick("duckbot-lay",src)
			var/obj/item/a_gift/easter/E = new /obj/item/a_gift/easter(src.loc)
			E.name = "duck egg"
			src.layegg--
			playsound(src.loc, "sound/misc/eggdrop.ogg", 50, 0)
			SPAWN_DBG(6 SECONDS)
				src.go = 1
		//plastic toy egg ovulation process
		if(prob(10)) // why the fuck was this 80?????????????????? -warc
			src.action++
		if(src.action >= 100)
			src.layegg++
			src.action = 0
		//go with the duck's call
		if(!src.emagged)
			if(!ON_COOLDOWN(src, "duckbotquackdelay", src.quack_cooldown) && prob(40))
				var/message = pick("wacka", "quack","quacky","gaggle")
				src.speak(message, 1, 0)
			if(!ON_COOLDOWN(src, "duckbotlovesongdelay", src.amusement_cooldown) && prob(20))
				playsound(src.loc, "sound/misc/amusingduck.ogg", 50, 0) // MUSIC
		//or the duck's call with go with you
		else
			var/message = pick("QUacK", "WHaCKA", "quURK", "bzzACK", "quock", "queck", "WOcka", "wacKY","GOggEL","gugel","goEGL","GeGGal")
			src.speak(message, 1, 1)
			wakka_wakka() // Seek loser is TRUE
			if(prob(50))
				playsound(src.loc, "sound/misc/amusingduck.ogg", 50, 1) // MUSIC

/obj/machinery/bot/duckbot/Bump()
	//the duck stop
	src.bump = 1
	walk(src,0)

/obj/machinery/bot/duckbot/attack_hand(mob/user as mob)
	var/dat
	dat += "<TT><B>AMUSING DUCK</B></TT><BR>"
	dat += "<B>toy series with strong sense for playing</B><BR><BR>"
	dat += "LAY EGG IS: <A href='byond://?src=\ref[src];on=1'>[src.on ? "TRUE!!!" : "NOT TRUE!!!"]</A><BR><BR>"
	dat += "AS THE DUCK ADVANCING,FLICKING THE PLUMAGE AND YAWNING THE MOUTH GO WITH MUSIC & LIGHT.<BR>"
	dat += "THE DUCK STOP,IT SWAYING TAIL THEN THE DUCK LAY AN EGG AS OPEN IT'S BUTTOCKS,<BR>GO WITH THE DUCK'S CALL"

	user.Browse("<HEAD><TITLE>Amusing Duck</TITLE></HEAD>[dat]", "window=ducky")
	onclose(user, "ducky")
	return

/obj/machinery/bot/duckbot/Topic(href, href_list)
	if (!(usr in range(1)))
		return
	if (href_list["on"])
		on = !on
	attack_hand(usr)

/obj/machinery/bot/duckbot/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/card/emag))
		emag_act(user, W)
	else
		src.visible_message("<span class='alert'>[user] hits [src] with [W]!</span>")
		src.health -= W.force * 0.5
		if (src.health <= 0)
			src.explode()

/obj/machinery/bot/duckbot/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (!src.emagged)
		if(user)
			boutput(user, "<span class='alert'>You short out the horn on [src].</span>")
		src.audible_message("<span class='alert'><B>[src] quacks loudly!</B></span>", 1)
		playsound(src.loc, "sound/misc/amusingduck.ogg", 50, 1)
		src.glide_size = initial(src.glide_size)
		src.action += rand(3,9)
		src.emagged = 1
		src.processing_tier = src.PT_active
		src.SubscribeToProcess()
		return 1
	return 0

/// Emag chase
/obj/machinery/bot/duckbot/proc/wakka_wakka()
	//continue chase
	if(ismob(src.annoy_target))
		if(!GET_COOLDOWN(src, "duckbotnerdobsessionlength"))
			src.annoy_target = null
		else if(!ON_COOLDOWN(src, "duckbotnospamastar", src.annoy_path_cooldown))
			var/turf/randwander = get_step_rand(get_turf(src.annoy_target))
			src.navigate_to(randwander, src.bot_move_delay, 0, 30)
		if(frustration >= 8)
			//congrats on outwitting the duck
			src.annoy_target = null
	//new nerd
	else
		for_by_tcl(M, /mob)
			if(IN_RANGE(src, M, 7))
				if(!ON_COOLDOWN(src, "["duckbotforgetannoyednerds"]-[M.name]", src.forget_annoyed_timeout))
					src.annoy_target = M
					src.navigate_to(get_turf(M), src.bot_move_delay, 0, 100)
					break

/obj/machinery/bot/duckbot/demag(var/mob/user)
	if (!src.emagged)
		return 0
	if (user)
		user.show_text("You repair [src]'s horn. Thank God.", "blue")
	src.emagged = 0
	src.processing_tier = src.PT_idle
	src.SubscribeToProcess()
	return 1

/obj/machinery/bot/duckbot/gib()
	return src.explode()

/obj/machinery/bot/duckbot/explode()
	if(src.exploding) return
	src.exploding = 1
	src.on = 0
	src.visible_message("<span class='alert'><B>[src] blows apart!</B></span>", 1)
	playsound(src.loc, "sound/impact_sounds/Machinery_Break_1.ogg", 40, 1)
	elecflash(src, radius=1, power=3, exclude_center = 0)
	qdel(src)
	return

/*
//So there's a buncha silly migration/pathing stuff.
//This is not a smart toy. It bumps, it goes, it lays egg.
//Not really appropriate for this thing, but some of the below behaviors could be useful to study or use elsewhere.

/// Sends the duckbot to a random spot on the station
/obj/machinery/bot/duckbot/proc/mystical_journey()
	var/list/stationAreas = get_accessible_station_areas()
	if (!length(stationAreas))
		return FALSE
	var/area/AR = pick(stationAreas)
	var/list/T = get_area_turfs(stationAreas[AR], 1)
	if(length(T) >= 1)
		T = (pick(T))
		src.mystical_access()
		src.navigate_to(T, src.bot_move_delay, 0, 69)
		if(length(src.path) >= 1)
			return TRUE

/// Gives the duckbot all access while on its quest
/obj/machinery/bot/duckbot/proc/mystical_access()
	qdel(src.botcard)
	src.access_lookup = "Captain"
	src.botcard = new /obj/item/card/id(src)
	src.botcard.access = get_access(src.access_lookup)
*/

/*
/// Sends all the duckbots to a random spot on the station
/obj/machinery/bot/duckbot/proc/migrate()
	var/list/stationAreas = get_accessible_station_areas()
	if(!isarea(src.duck_migration_target))
		var/A = pick(stationAreas)
		src.duck_migration_target = stationAreas[A]
	var/list/T = get_area_turfs(src.duck_migration_target, 1)
	if(length(T) >= 1)
		. = TRUE
		SPAWN_DBG(rand(0,10 SECONDS)) // give em some time to spread out a bit
			T = (pick(T))
			//src.mystical_access() AB SO FUC KING LUTE LEY NOT THANK YOU VERRY MOUCHE - warc
			src.navigate_to(T, src.bot_move_delay, 0, 300)
			if(length(src.path) < 1)
				src.KillPathAndGiveUp(1)

/// Tells all the other bots that it's time to migrate... somewhere
/obj/machinery/bot/duckbot/proc/declare_migration()
	if(!src.migration_override || !isarea(src.duck_migration_target))
		var/list/stationAreas = get_accessible_station_areas()
		var/A = pick(stationAreas)
		src.duck_migration_target = stationAreas[A]

	var/datum/radio_frequency/frequency = radio_controller.return_frequency("[FREQ_PDA]")
	if(!frequency) return FALSE

	var/datum/signal/signal = get_free_signal()
	signal.source = src
	signal.data["sender"] = src.botnet_id
	signal.data["sender_name"] = src
	signal.data["message"] = "BUMP N GO TO [src.duck_migration_target]."
	signal.data["target"] = src.duck_migration_target
	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)
	return TRUE
*/
/*
/obj/machinery/bot/duckbot/receive_signal(datum/signal/signal)
	if(!on)
		return

	var/list/stationAreas = get_accessible_station_areas()
	// in case someone wants to trick a flock of plastic birds to break you into security or something
	if(signal.data["command"] == "set_migration_target")
		var/message_to_send = "quack"
		if(signal.data["message"] in stationAreas)
			src.duck_migration_target = stationAreas[signal.data["message"]]
			message_to_send = "wacka"
			src.migration_override = TRUE
		if(signal.data["sender"])
			src.send_confirm_signal(message_to_send, signal.data["sender"])

	// migrate is true! Also to prevent people from asking just one duck to run off somewhere
	if(isarea(signal.data["target"]))
		src.migrate()
		return

	// Someone asked this bot to go on an adventure! Must be migration season, let everyone know
	 ~ Never activate this thanks,
	if(signal.data["command"] == "migrate")
		var/message_to_send = "wacka"
		if(ON_COOLDOWN(global, "duckbot_forced_migration", 3 MINUTES))
			message_to_send = "quack"
		else
			src.declare_migration()
			message_admins("[signal.data["sender"]] has triggered a mass migration of duckbots. Maybe see if this is a promble.")
			ON_COOLDOWN(global, "duckbot_declare_migration", 15 MINUTES)
		if(signal.data["sender"])
			src.send_confirm_signal(message_to_send, signal.data["sender"])
			*/
/*
/obj/machinery/bot/duckbot/proc/send_confirm_signal(var/msg, var/target)
	if(!ON_COOLDOWN(global, "duckbot_antispam_[target]", 1 SECOND))
		var/datum/radio_frequency/frequency = radio_controller.return_frequency("[FREQ_PDA]")
		if(!frequency) return FALSE
		var/datum/signal/sigsend = get_free_signal()
		sigsend.source = src
		sigsend.data["sender"] = src.botnet_id
		sigsend.data["command"] = "message"
		sigsend.data["sender_name"] = src
		sigsend.data["message"] = "[msg]"
		sigsend.data["address_1"] = target
		sigsend.transmission_method = TRANSMISSION_RADIO
		frequency.post_signal(src, sigsend)*/

/*
/obj/machinery/bot/duckbot/KillPathAndGiveUp(give_up)
	. = ..()
	if(give_up)
		src.annoy_target = null
		/*
		src.migration_override = FALSE
		if(src.access_lookup != initial(src.access_lookup))
			src.access_lookup = initial(src.access_lookup)
			src.botcard.access = get_access(src.access_lookup)
		*/
*/
