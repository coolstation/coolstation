#define LANDMARK_CUSTOMTITLESCREEN "CUSTOM_TITLE_SCREEN_ORIGIN"
#ifndef GOTTA_GO_FAST_BUT_ZLEVELS_TOO_SLOW // doesnt work without somewhere to put it
/// the ckey currently loading a title screen
/// if this is set, noone else can load a title screen (because we dont overwrite the area)
var/title_screen_loader_key = null

/client/verb/load_custom_title_screen()
	set name = "Load Title Screen"
	set desc = "Load a custom title screen. (ONE PER ROUND, 21 BY 15)"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set popup_menu = 0
	ADMIN_ONLY

	if(!landmarks[LANDMARK_CUSTOMTITLESCREEN])
		boutput(src, "Uh, I have no idea where to put a custom title screen. Ensure there is exactly one landmark for it.")
		return

	if(length(landmarks[LANDMARK_CUSTOMTITLESCREEN]) > 1)
		boutput(src, "There's more than one landmark for the custom title screen, and I refuse to guess.")
		return

	if(title_screen_loader_key)
		boutput(src, "Sorry, but [title_screen_loader_key] beat you to the punch!")
		return

	title_screen_loader_key = src.ckey

	message_admins("[title_screen_loader_key] started setting up a custom title screen.")

	var/target = input("Select the map to load (PLEASE use a map that is 21x15).", "Saved map upload", null) as null|file
	if(!target)
		message_admins("[title_screen_loader_key] canceled setting up a custom title screen.")
		title_screen_loader_key = null
		return
	var/text = file2text(target)
	if(!text)
		message_admins("[title_screen_loader_key] canceled setting up a custom title screen.")
		title_screen_loader_key = null
		return

	var/dmm_suite/dmm_suite = new
	var/turf/T = landmarks[LANDMARK_CUSTOMTITLESCREEN][1]
	dmm_suite.read_map(text, T.x, T.y, T.z)

	LAGCHECK(LAG_REALTIME)

	var/turf/new_player_turf = locate(T.x + 10, T.y + 7, T.z)
	var/turf/lobby_timer_turf = locate(T.x + 17, T.y, T.z)
	if(!new_player_turf)
		boutput(src, "Hey, the new_player turf was out of bounds!")
		message_admins("Custom title screen fucked up during attempted load by [title_screen_loader_key].")
	else if(!lobby_timer_turf)
		boutput(src, "Hey, the lobby_timer turf was out of bounds!")
		message_admins("Custom title screen fucked up during attempted load by [title_screen_loader_key].")
	else
		landmarks[LANDMARK_NEW_PLAYER] = list(new_player_turf)
		for(var/mob/new_player/new_player in mobs)
			new_player.set_loc(new_player_turf)
		if(current_state <= GAME_STATE_PREGAME)
			game_start_countdown.set_loc(lobby_timer_turf)
			title_countdown.set_loc(locate(lobby_timer_turf.x, lobby_timer_turf.y + 1, lobby_timer_turf.z))
		boutput(src, "Donezo!")
		message_admins("Custom title screen loaded successfully by [title_screen_loader_key].")


/proc/load_custom_title_screen_baked_in(var/target as null|file)
	if(title_screen_loader_key)
		return

	title_screen_loader_key = "AUTOMATIC"

	if(!target)
		message_admins("[title_screen_loader_key] canceled setting up a custom title screen.")
		title_screen_loader_key = null
		return

	var/text = file2text(target)
	if(!text)
		message_admins("[title_screen_loader_key] canceled setting up a custom title screen.")
		title_screen_loader_key = null
		return

	var/dmm_suite/dmm_suite = new
	var/turf/T = landmarks[LANDMARK_CUSTOMTITLESCREEN][1]
	dmm_suite.read_map(text, T.x, T.y, T.z)

	LAGCHECK(LAG_REALTIME)

	var/turf/new_player_turf = locate(T.x + 10, T.y + 7, T.z)
	var/turf/lobby_timer_turf = locate(T.x + 17, T.y, T.z)
	if(!new_player_turf)
		//boutput(src, "Hey, the new_player turf was out of bounds!")
		message_admins("Custom title screen fucked up during attempted load by [title_screen_loader_key].")
	else if(!lobby_timer_turf)
		//boutput(src, "Hey, the lobby_timer turf was out of bounds!")
		message_admins("Custom title screen fucked up during attempted load by [title_screen_loader_key].")
	else
		landmarks[LANDMARK_NEW_PLAYER] = list(new_player_turf)
		for(var/mob/new_player/new_player in mobs)
			new_player.set_loc(new_player_turf)
		if(current_state <= GAME_STATE_PREGAME)
			game_start_countdown.set_loc(lobby_timer_turf)
			title_countdown.set_loc(locate(lobby_timer_turf.x, lobby_timer_turf.y + 1, lobby_timer_turf.z))
		//boutput(src, "Donezo!")
		message_admins("Custom title screen loaded successfully by [title_screen_loader_key].")



#endif

#undef LANDMARK_CUSTOMTITLESCREEN

/obj/decal/fakeobjects/csbanner
	icon = 'icons/effects/320x320.dmi'
	icon_state = "cs"
	plane = PLANE_HUD
