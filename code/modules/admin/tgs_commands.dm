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

/datum/tgs_chat_command/ooc
	admine_only = TRUE
	name = "ooc"
	help_text = "OOC-blasts a message. Usage: !tgs ooc <message>"

/datum/tgs_chat_command/ooc/Run(datum/tgs_chat_user/sender, params)
	var/msg = trim(copytext(sanitize(params), 1, MAX_MESSAGE_LEN))
	var/nick = sender.friendly_name
	msg = discord_emojify(msg)
	if(!msg)
		return "try harder."

	logTheThing("ooc", nick, null, "OOC: [msg]")
	logTheThing("diary", nick, null, ": [msg]", "ooc")
	var/rendered = "<span class=\"adminooc\"><span class=\"prefix\">OOC:</span> <span class=\"name\">[nick]:</span> <span class=\"message\">[msg]</span></span>"

	for (var/client/C in clients)
		if (C.preferences && !C.preferences.listen_ooc)
			continue
		boutput(C, rendered)
	return "OOC blasted out."

/datum/tgs_chat_command/admin_pm
	admine_only = TRUE
	name = "pm"
	help_text = "Admin-PMs a given ckey. Usage: !tgs pm <key> <message>"

/datum/tgs_chat_command/admin_pm/Run(datum/tgs_chat_user/sender, params)
	var/list/stuff = splittext(params, " ")
	var/mob/M = whois_ckey_to_mob_reference(stuff[1], FALSE)
	var/nick = sender.friendly_name

	if(stuff.len < 2)
		return "uhh say something"

	stuff = stuff.Copy(2,0)
	var/t = jointext(stuff," ")

	if (M?.client)
		boutput(M, {"
			<div style='border: 2px solid red; font-size: 110%;'>
				<div style="color: black; background: #f88; font-weight: bold; border-bottom: 1px solid red; text-align: center; padding: 0.2em 0.5em;">
					Admin PM from <a href=\"byond://?action=priv_msg_irc&nick=[ckey(nick)]\">[nick]</a>
				</div>
				<div style="padding: 0.2em 0.5em;">
					[t]
				</div>
				<div style="font-size: 90%; background: #fcc; font-weight: bold; border-top: 1px solid red; text-align: center; padding: 0.2em 0.5em;">
					<a href=\"byond://?action=priv_msg_irc&nick=[ckey(nick)]" style='color: #833; font-weight: bold;'>&lt; Click to Reply &gt;</a></div>
				</div>
			</div>
			"})
		M << sound('sound/misc/adminhelp.ogg', volume=100, wait=0)
		logTheThing("admin_help", null, M, "Discord: [nick] PM'd [constructTarget(M,"admin_help")]: [t]")
		logTheThing("diary", null, M, "Discord: [nick] PM'd [constructTarget(M,"diary")]: [t]", "ahelp")
		for (var/client/C)
			if (C.holder && C.key != M.key)
				if (C.player_mode && !C.player_mode_ahelp)
					continue
				else
					boutput(C, "<span class='ahelp'><b>PM: <a href=\"byond://?action=priv_msg_irc&nick=[ckey(nick)]\">[nick]</a> (Discord) <i class='icon-arrow-right'></i> [key_name(M)]</b>: [t]</span>")
		return "Yelled At [M.key]"
	else return "Seems they ran off."

/datum/tgs_chat_command/mentor_pm
	name = "mpm"
	help_text = "Mentor-PMs a given ckey. Usage: !tgs mpm <key> <message>"

/datum/tgs_chat_command/mentor_pm/Run(datum/tgs_chat_user/sender, params)
	var/list/stuff = splittext(params, " ")
	var/mob/M = whois_ckey_to_mob_reference(stuff[1], FALSE)

	if(sender.channel.custom_tag != "mentors")
		return "this command is only for mentors. try it in the mentor channel."

	if(stuff.len < 2)
		return "uhh say something"

	stuff = stuff.Copy(2,0)
	var/t = jointext(stuff," ")

	if (M?.client)

		boutput(M, "<span class='mhelp'><b>MENTOR PM: FROM [sender.friendly_name] (Discord) </b>: <span class='message'>[t]</span></span>")
		M.playsound_local(M, "sound/misc/mentorhelp.ogg", 100, flags = SOUND_IGNORE_SPACE, channel = VOLUME_CHANNEL_MENTORPM)

		logTheThing("mentor_help", sender.friendly_name, M, "Mentor PM'd [constructTarget(M,"mentor_help")]: [t]")
		logTheThing("diary", sender.friendly_name, M, "Mentor PM'd [constructTarget(M,"diary")]: [t]", "admin")

		var/mentormsg = "<span class='mhelp'><b>MENTOR PM: [sender.friendly_name] (Discord)  <i class='icon-arrow-right'></i> [key_name(M,0,0,1)]</b>: <span class='message'>[t]</span></span>"
		for (var/client/C)
			if (C.can_see_mentor_pms() && (M && C.key != M.key))
				if (C.holder)
					if (C.player_mode && !C.player_mode_mhelp)
						continue
					else
						boutput(C, "<span class='mhelp'><b>MENTOR PM: [sender.friendly_name] (Discord) <i class='icon-arrow-right'></i> [key_name(M,0,0,1)]/[M.real_name] <A HREF='byond://?src=\ref[C.holder];action=adminplayeropts;targetckey=[M.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: <span class='message'>[t]</span></span>")
				else
					boutput(C, mentormsg)
		return "Mentaur Peem Sent!"
	else return "Must have been the wind..."

/datum/tgs_chat_command/echo
	name = "echo"
	help_text = "echo!"

/datum/tgs_chat_command/echo/Run(datum/tgs_chat_user/sender, params)
	return params
