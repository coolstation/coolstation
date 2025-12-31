/datum/tgs_chat_command/ping
	name = "ping"
	help_text = "Server responds with pong."

/datum/tgs_chat_command/ping/Run(datum/tgs_chat_user/sender, params)
	return "Pong, [sender.friendly_name]!"

/datum/tgs_chat_command/respawn_dude
	name = "respawn"
	help_text = "Respawns a given ckey."

/datum/tgs_chat_command/respawn_dude/Run(datum/tgs_chat_user/sender, params)
	var/mob/target = whois_ckey_to_mob_reference(params, FALSE)
	if(!target)
		return "Target not found."
	logTheThing("admin", "[sender.friendly_name] (Discord)", target, "respawned [constructTarget(target,"admin")]")
	logTheThing("diary", "[sender.friendly_name] (Discord)", target, "respawned [constructTarget(target,"diary")].", "admin")
	message_admins("[sender.friendly_name] (Discord) respawned [key_name(target)].")

	var/mob/new_player/newM = new()
	newM.adminspawned = 1

	newM.key = target.key
	if (target.mind)
		target.mind.damned = 0
		target.mind.transfer_to(newM)
	newM.Login()
	newM.sight = SEE_TURFS //otherwise the HUD remains in the login screen
	qdel(target)

	boutput(newM, "<b>You have been respawned.</b>")
	return "Player respawned."

/datum/tgs_chat_command/mentor_pm
	name = "mpm"
	help_text = "Mentor-PMs a given ckey. Usage: !tgs mpm <key> <message>"

/datum/tgs_chat_command/mentor_pm/Run(datum/tgs_chat_user/sender, params)
	var/list/stuff = params2list(params)
	var/mob/M = whois_ckey_to_mob_reference(stuff[1], FALSE)
	if(!M)
		return "Target not found."
	var/t = stuff - stuff[1]
	if(!t)
		return "uhh say something"

	boutput(M, "<span class='mhelp'><b>MENTOR PM: FROM [sender.friendly_name] (Discord) </b>: <span class='message'>[t]</span></span>")
	M.playsound_local(M, "sound/misc/mentorhelp.ogg", 100, flags = SOUND_IGNORE_SPACE, channel = VOLUME_CHANNEL_MENTORPM)

	logTheThing("mentor_help", sender.friendly_name, M, "Mentor PM'd [constructTarget(M,"mentor_help")]: [t]")
	logTheThing("diary", sender.friendly_name, M, "Mentor PM'd [constructTarget(M,"diary")]: [t]", "admin")

	var/mentormsg = "<span class='mhelp'><b>MENTOR PM: [sender.friendly_name] (Discord)  <i class='icon-arrow-right'></i> [key_name(M,0,0,1)]</b>: <span class='message'>[t]</span></span>"
	for (var/client/C)
		if (C.can_see_mentor_pms() && C.key != usr.key && (M && C.key != M.key))
			if (C.holder)
				if (C.player_mode && !C.player_mode_mhelp)
					continue
				else
					boutput(C, "<span class='mhelp'><b>MENTOR PM: [sender.friendly_name] (Discord) <i class='icon-arrow-right'></i> [key_name(M,0,0,1)]/[M.real_name] <A HREF='byond://?src=\ref[C.holder];action=adminplayeropts;targetckey=[M.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: <span class='message'>[t]</span></span>")
			else
				boutput(C, mentormsg)
	return "Mentaur Peem Sent!"
