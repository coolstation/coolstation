mob/new_player
	anchored = 1

	var/ready = 0
	var/spawning = 0
	var/keyd
	var/adminspawned = 0

#ifdef TWITCH_BOT_ALLOWED
	var/twitch_bill_spawn = 0
#endif

	density = 0
	stat = 2
	canmove = 0

	anchored = 1	//  don't get pushed around

	//var/chui/window/spend_spacebux/bank_menu

	New()
		. = ..()
		APPLY_MOB_PROPERTY(src, PROP_INVISIBILITY, src, INVIS_ALWAYS)

	// How could this even happen? Regardless, no log entries for unaffected mobs (Convair880).
	ex_act(severity)
		return

	disposing()
		mobs.Remove(src)
		if (mind)
			if (mind.current == src)
				mind.current = null

			mind = null
		key = null
		..()

	Login()
		..()

		if(!mind)
			mind = new(src)
			keyd = mind.key

		if (src.client?.player) //playtime logging stuff
			var/datum/player/P = src.client.player
			if (!isnull(P.round_join_time) && isnull(P.round_leave_time)) //they likely died but didnt d/c b4 respawn
				P.log_leave_time()

		new_player_panel()
		src.set_loc(pick_landmark(LANDMARK_NEW_PLAYER, locate(1,1,1)))
		src.sight |= SEE_TURFS


		// byond members get a special join message :]
		if (src.client?.IsByondMember())
			var/list/msgs_which_are_gifs = list(8, 9, 10) //not all of these are normal jpgs
			var/num = rand(1,16)
			var/resource = resource("images/member_msgs/byond_member_msg_[num].[(msgs_which_are_gifs.Find(num)) ? "gif" : "jpg"]")
			boutput(src, "<img src='[resource]' style='margin: auto; display: block; max-width: 100%;'>")


		if (src.ckey && !adminspawned)
			if ("[src.ckey]" in spawned_in_keys)
				if (!(client && client.holder) && !abandon_allowed)
					 //They have already been alive this round!!
					var/mob/dead/observer/observer = new()

					src.spawning = 1

					close_spawn_windows()
					boutput(src, "<span class='notice'>Now teleporting.</span>")
					var/ASLoc = pick_landmark(LANDMARK_OBSERVER)
					if (ASLoc)
						observer.set_loc(ASLoc)
					else
						observer.set_loc(locate(1, 1, 1))
					observer.key = key

					if (client?.preferences)
						if (client.preferences.be_random_name)
							client.preferences.randomize_name()

						observer.name = client.preferences.real_name

					observer.real_name = observer.name
					qdel(src)

			else
				spawned_in_keys += "[src.ckey]"

#ifdef TWITCH_BOT_ALLOWED
		if (current_state == GAME_STATE_PLAYING)
			src.try_force_into_bill()
		else
			if (src.client && src.client.ckey == TWITCH_BOT_CKEY)
				twitch_bill_spawn = 1
				boutput(src, "<span class='bold notice'>Please wait. When the game starts, Shitty Bill will be activated.</span>")
#endif

	Logout()
		ready = 0
		if (src.ckey) //Null if the client changed to another mob, but not null if they disconnected.
			spawned_in_keys -= "[src.ckey]"
		else if (isclient(src.last_client)) //playtime logging stuff
			src.last_client.player.log_join_time()

		..()
		close_spawn_windows()
		if(!spawning)
			qdel(src)

		// Given below call, not much reason to do this if pregameHTML wasn't set
		// explanation for isnull(src.key) from the reference: In the case of a player switching to another mob, by the time Logout() is called, the original mob's key will be null,
		if (isnull(src.key) && pregameHTML && isclient(src.last_client))
			// Removed dupe "if (src.last_client)" check since it was still runtiming anyway
			SPAWN_DBG(0)
				if(isclient(src.last_client))
					winshow(src.last_client, "pregameBrowser", 0)
					src.last_client << browse("", "window=pregameBrowser")
		return

	verb/show_newnewplayer_screen()
		set hidden = 0
		set name = "Show Warning Splash"
		set category = "Commands"
		usr << browse(newplayerHTML, "window=pregameBrowser")

	verb/new_player_panel()

		set src = usr
		if(client)
			winset(src, "joinmenu.button_charsetup", "is-disabled=false")
		// drsingh i put the extra ifs here. i think its dumb but there's a bad client error here so maybe it's somehow going away in winset because byond is shitty
		if(client)
			winset(src, "joinmenu.button_ready", "is-disabled=false;is-visible=true")
		if(client)
			winset(src, "joinmenu.button_cancel", "is-disabled=true;is-visible=false")
		if(client)
			winshow(src, "joinmenu", 1)
		if(client?.antag_tokens > 0 && (!ticker || current_state <= GAME_STATE_PREGAME))
			winset(src, "joinmenu.button_ready_antag", "is-disabled=false;is-visible=true")
			winset(src, "joinmenu", "size=240x256")
			winset(src, "joinmenu.observe", "pos=18,192")
		else if(client) // this shouldn't be necessary but it is
			winset(src, "joinmenu", "size=240x200")
			winset(src, "joinmenu.observe", "pos=18,136")
			winset(src, "joinmenu.button_ready_antag", "is-disabled=true;is-visible=false")
		if(src.ready)
			if (client) winset(src, "joinmenu.button_charsetup", "is-disabled=true")
			if (client) winset(src, "joinmenu.button_ready", "is-disabled=true;is-visible=false")
			if (client) winset(src, "joinmenu.button_cancel", "is-disabled=false;is-visible=true")
			if (client) winset(src, "joinmenu.button_ready_antag", "is-disabled=true")
		//show new player disclaimer to new players
		if (client?.player.rounds_participated < 10)
			winshow(client, "pregameBrowser", 1)
			client << browse(newplayerHTML, "window=pregameBrowser")
		//show pregameHTML if it's available
		else if(pregameHTML && client)
			winshow(client, "pregameBrowser", 1)
			client << browse(pregameHTML, "window=pregameBrowser")
		//if pregameHTML is not available, show blank screen until pregameHTML is generated (which will send a new command to browse upon completion)
		else if(client)
			winshow(src.last_client, "pregameBrowser", 0)
			src.last_client << browse("", "window=pregameBrowser")

	Stat()
		..()
		if(current_state <= GAME_STATE_PREGAME)
			statpanel("Lobby")
			if(client.statpanel=="Lobby" && ticker)
				for (var/client/C)
					var/mob/new_player/player = C.mob
					if (!istype(player)) continue

					if (player.client.holder && (player.client.stealth || player.client.alt_key)) // are they an admin and in stealth mode/have a fake key?
						if (client.holder) // are we an admin?
							stat("[player.key] (as [player.client.fakekey])", (player.ready)?("(Playing)"):(null)) // give us the full deets
						else // are we not an admin?
							stat("[player.client.fakekey]", (player.ready)?("(Playing)"):(null)) // only show the fake key
					else // are they a normal player or not in stealth mode/using a fake key?
						stat("[player.key]", (player.ready)?("(Playing)"):(null)) // show them normally

	Topic(href, href_list[])

		if(href_list["show_preferences"])
			client.preferences.ShowChoices(src)
			return 1

		if(href_list["ready"])
			if(!ready)
				if(alert(src,"Are you sure you are ready? This will lock-in your preferences.","Player Setup","Yes","No") == "Yes")
					ready = 1

		if(href_list["observe"])
			if(alert(src,"Are you sure you wish to observe? You will not be able to play this round!","Player Setup","Yes","No") == "Yes")
				if(!src.client) return
				var/mob/dead/observer/observer = new()

				src.spawning = 1

				close_spawn_windows()
				boutput(src, "<span class='notice'>Now teleporting.</span>")
				var/ASLoc = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, 1))
				if (ASLoc)
					observer.set_loc(ASLoc)
				else
					observer.set_loc(locate(1, 1, 1))
				observer.apply_looks_of(client)

				if(src.mind)
					//src.mind.dnr = 1
					src.mind.joined_observer = 1
					src.mind.transfer_to(observer)
				else
					src.mind = new /datum/mind()
					//src.mind.dnr = 1
					src.mind.joined_observer = 1
					src.mind.transfer_to(observer)

				if(client.preferences.be_random_name)
					client.preferences.randomize_name()
				observer.name = client.preferences.real_name
				observer.real_name = observer.name
			//	observer.Equip_Bank_Purchase(observer.mind.purchased_bank_item)

				message_ghosts("<b>[observer.name]</b> is observing.")
				src.client.loadResources()


				qdel(src)

		if(href_list["late_join"])
			LateChoices()

		if(href_list["SelectedJob"])
			if (src.spawning)
				return

			if (!enter_allowed)
				boutput(usr, "<span class='notice'>There is an administrative lock on entering the game!</span>")
				return

			if (ticker?.mode)
				var/mob/living/silicon/S = locate(href_list["SelectedJob"]) in mobs
				if (S) //Latejoin cyborgs don't inherit from preferences (at least not that I know), so they're always fine
					if(jobban_isbanned(src.mind, "Cyborg"))
						boutput(usr, "<span class='notice'>Sorry, you are banned from playing silicons.</span>")
						close_spawn_windows()
						new_player_panel()
						return
					var/obj/item/organ/brain/latejoin/latejoin = IsSiliconAvailableForLateJoin(S)
					if(latejoin)
						close_spawn_windows()
						latejoin.activated = 1
						src.mind.transfer_to(S)
						SPAWN_DBG(1 DECI SECOND)
							S.choose_name()
							qdel(src)
					else
						close_spawn_windows()
						boutput(usr, "<span class='notice'>Sorry, that Silicon has already been taken control of.</span>")

				else
					//Doing these checks here instead of before pulling up the latejoin menu itself because of latejoin silicons.
					if ((client.preferences.real_name in client.player.character_names_expended))
						if (!(admins_can_reuse_characters && isadmin(src)))
							boutput(usr, "<b><span class='alert'>You can't spawn in with a character you've already played this round. Make or select another character.</span></b>");
							//Elsewhere we disallow changing the name of an existing used-up character to avoid "same guy, technically different names".
							//Which does run into the issue of when someone runs out of characters they made,
							//the only way to make a new character is complete randomising via the otherwise unlabelled "Reset All" button in the Character Setup
							//So we'll pretend to be TGUI for a moment and pulse the preferences to do that for them. Saves em getting stuck.
							client.preferences.ui_act("reset")
							close_spawn_windows()
							new_player_panel()
							return
					if (istype(ticker.mode, /datum/game_mode/construction))
						var/datum/game_mode/construction/C = ticker.mode
						var/datum/job/JOB = locate(href_list["SelectedJob"]) in C.enabled_jobs
						AttemptLateSpawn(JOB)
					else
						var/list/alljobs = job_controls.staple_jobs | job_controls.special_jobs
						var/datum/job/JOB = locate(href_list["SelectedJob"]) in alljobs
						AttemptLateSpawn(JOB)

		if(href_list["preferences"])
			if (!ready)
				client.preferences.process_link(src, href_list)
		else if(!href_list["late_join"] && !href_list["SelectedJob"])
			new_player_panel()

	proc/IsJobAvailable(var/datum/job/JOB)
		if(!ticker || !ticker.mode)
			return 0
		if (!JOB || !istype(JOB,/datum/job/) || JOB.limit == 0)
			return 0
		if (!JOB.no_jobban_from_this_job && jobban_isbanned(src,JOB.name))
			return 0
		if (JOB.requires_supervisor_job && countJob(JOB.requires_supervisor_job) <= 0)
			return 0
		if (JOB.requires_whitelist)
			if (!(src.ckey in NT))
				return 0
		if (JOB.needs_college && !src.has_medal("Unlike the director, I went to college"))
			return 0
		if (JOB.rounds_needed_to_play && (src.client && src.client.player))
			var/round_num = src.client.player.get_rounds_participated()
			if (!isnull(round_num) && round_num < JOB.rounds_needed_to_play && !(src.ckey in NT)) //they havent played enough rounds! (if you have HOS whitelisted you can sec)
				return 0
		if (JOB.limit < 0 || countJob(JOB.name) < JOB.limit)
			return 1
		return 0

	proc/IsSiliconAvailableForLateJoin(var/mob/living/silicon/S)
		if (isdead(S))
			return 0

		if (istype(S,/mob/living/silicon/ai))
			var/mob/living/silicon/ai/AI = S
			var/obj/item/organ/brain/latejoin/latejoin = AI.brain
			if (istype(latejoin) && !latejoin.activated)
				return latejoin
		if (istype(S,/mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = S
			var/obj/item/organ/brain/latejoin/latejoin = R.brain
			if (istype(latejoin) && !latejoin.activated)
				return latejoin
		return 0


	proc/AttemptLateSpawn(var/datum/job/JOB, force=0, var/loc_override = null)
		if (!JOB)
			return
		if (JOB && (force || IsJobAvailable(JOB)))
			var/mob/character = create_character(JOB, JOB.allow_traitors)
			if (isnull(character))
				return
			if(loc_override)
				character.set_loc(loc_override)
			else if(istype(ticker.mode, /datum/game_mode/football))
				var/datum/game_mode/football/F = ticker.mode
				F.init_player(character, 0, 1)/*
			else if(istype(ticker.mode, /datum/game_mode/pod_wars))
				var/datum/game_mode/pod_wars/mode = ticker.mode
				mode.add_latejoin_to_team(character.mind, JOB)
*/
			else if (character.traitHolder && character.traitHolder.hasTrait("immigrant"))
				boutput(character.mind.current,"<h3 class='notice'>You've arrived in a nondescript container! Good luck!</h3>")
				//So the location setting is handled in EquipRank in jobprocs.dm. I assume cause that is run all the time as opposed to this.
			else if (character.traitHolder && character.traitHolder.hasTrait("pilot"))
				boutput(character.mind.current,"<h3 class='notice'>You've become lost on your way to the station! Good luck!</h3>")
				//As with the Stowaway trait, location setting is handled elsewhere.
			else if (istype(character.mind.purchased_bank_item, /datum/bank_purchaseable/space_diner) || istype(character.mind.purchased_bank_item, /datum/bank_purchaseable/mail_order))
				// Location is set in bank_purchaseable Create()
				boutput(character.mind.current,"<h3 class='notice'>You've arrived through an alternative mode of travel! Good luck!</h3>")
			else if (map_settings?.arrivals_type == MAP_SPAWN_CRYO)
				var/obj/cryotron/starting_loc = null
				if (ishuman(character) && by_type[/obj/cryotron])
					starting_loc = pick(by_type[/obj/cryotron])

				if (istype(starting_loc))
					starting_loc.add_person_to_queue(character, JOB)
				else
					starting_loc = pick_landmark(LANDMARK_LATEJOIN, locate(1, 1, 1))
					character.set_loc(starting_loc)
			else if (map_settings?.arrivals_type == MAP_SPAWN_MISSILE)
				latejoin_missile_spawn(character)
			else if(istype(ticker.mode, /datum/game_mode/battle_royale))
				var/datum/game_mode/battle_royale/battlemode = ticker.mode
				if(ticker.round_elapsed_ticks > 3000) // no new people after 5 minutes
					boutput(character.mind.current,"<h3 class='notice'>You've arrived on a station with a battle royale in progress! Feel free to spectate, but you are not considered one of the contestants!</h3>")
					return AttemptLateSpawn(new /datum/job/special/tourist)
				character.set_loc(pick_landmark(LANDMARK_BATTLE_ROYALE_SPAWN))
				equip_battler(character)
				character.mind.assigned_role = "MODE"
				character.mind.special_role = ROLE_BATTLER
				battlemode.living_battlers.Add(character.mind)
				DEBUG_MESSAGE("Adding a new battler")
				battlemode.battle_shuttle_spawn(character.mind)
			else
				var/starting_loc = null
				starting_loc = pick_landmark(LANDMARK_LATEJOIN, locate(floor(world.maxx / 2), floor(world.maxy / 2), 1))
				character.set_loc(starting_loc)

			if (isliving(character))
				var/mob/living/LC = character
				if(!istype(JOB,/datum/job/battler) && !istype(JOB, /datum/job/football))
					LC.Equip_Rank(JOB.name, joined_late=1)

			var/miscreant = 0
#ifdef MISCREANTS
			if (ticker && character.mind && !character.client.using_antag_token && JOB.allow_traitors != 0 && prob(10))
				ticker.generate_miscreant_objectives(character.mind)
				miscreant = 1
#endif

#ifdef CREW_OBJECTIVES
			if (ticker && character.mind && !miscreant)
				ticker.generate_individual_objectives(character.mind)
#endif

			if (manualbreathing)
				boutput(character, "<B>You must breathe manually using the *inhale and *exhale commands!</B>")
			if (manualblinking)
				boutput(character, "<B>You must blink manually using the *closeeyes and *openeyes commands!</B>")

			if (ticker && character.mind)
				character.mind.join_time = world.time
				//ticker.implant_skull_key() // This also checks if a key has been implanted already or not. If not then it'll implant a random sucker with a key.
				if (!(character.mind in ticker.minds))
					logTheThing("debug", character, null, "<b>Late join:</b> added player to ticker.minds.")
					ticker.minds += character.mind
				logTheThing("debug", character, null, "<b>Late join:</b> assigned job: [JOB.name]")
				//if they have a ckey, joined before a certain threshold and the shuttle wasnt already on its way
				if (character.mind.ckey && (ticker.round_elapsed_ticks <= MAX_PARTICIPATE_TIME) && !emergency_shuttle.online)
					participationRecorder.record(character.mind.ckey)

			character.client.player.character_names_expended |= character.client.preferences.real_name

			SPAWN_DBG(0)
				qdel(src)

		else
			src << alert("[JOB.name] is not available. Please try another.")

		return

	proc/LateJoinLink(var/datum/job/J)
		// This is pretty ugly but: whatever! I don't care.
		// It likely needs some tweaking but everything does.
		if (!J.no_late_join)
			var/limit = J.limit
			if (!IsJobAvailable(J))
				// Show unavailable jobs, but no joining them
				limit = 0

			var/c = countJob(J.name) 	// gross
			if (limit == 0 && c == 0)
				// 0 slots, nobody in it, don't show it
				return

			//If it's Revolution time, lets show all command jobs as filled to (try to) prevent metagaming.
			if(istype(J, /datum/job/command/) && istype(ticker.mode, /datum/game_mode/revolution))
				c = limit

			// probalby could be a define but dont give a shite
			var/maxslots = 5
			var/list/slots = list()
			var/shown = min(max(c, (limit == -1 ? 99 : limit)), maxslots)
			// if there's still an open space, show a final join link
			if (limit == -1 || (limit > maxslots && c < limit))
				slots += "<a href='byond://?src=\ref[src];SelectedJob=\ref[J]' class='latejoin-card' style='border-color: [J.linkcolor];' title='Join the round as [J.name].'>&#x2713;&#xFE0E;</a>"

			// show slots up to the limit
			// extra people beyond the limit will be shown as a [+X] card
			for (var/i = shown, i > 0, i--)
				slots += (i <= c ? "<div class='latejoin-card latejoin-full' style='border-color: [J.linkcolor]; background-color: [J.linkcolor];' title='Slot filled.'>[(i == 1 && c > shown) ? "+[c - maxslots]" : "&times;"]</div>" : "<a href='byond://?src=\ref[src];SelectedJob=\ref[J]' class='latejoin-card' style='border-color: [J.linkcolor];' title='Join the round as [J.name].'>&#x2713;&#xFE0E;</a>")

			return {"
				<tbody class='latejoin-buttons'><tr class=latejoin-buttons><td class='latejoin-link'>
					[(limit == -1 || c < limit) ? "<a href='byond://?src=\ref[src];SelectedJob=\ref[J]' style='color: [J.linkcolor];' title='Join the round as [J.name].'>[J.name]</a>" : "<span style='color: [J.linkcolor];' title='This job is full.'>[J.name]</span>"]
					</td>
					<td class='latejoin-cards'>[jointext(slots, " ")]</td>
				</tr></tbody>
				"}

		return

	proc/LateChoices()
		// shut up
		var/header_thing_chui_toggle = true ? {"
		<title>Select a Job</title>
		<div class='contentFlex'><window>
		<style type='text/css'>
			body { background: #222; color: white; font-family: Tahoma, sans-serif; }
		</style>"} : ""

		var/dat = {"
[header_thing_chui_toggle]
<style type='text/css'>

.latejoin {
    border: 2px solid #6d6617;
    border-style: groove;
	margin-bottom: 15px;
}

.table.latejoin {
	border-spacing: 0 2px;
}
.latejoin-buttons {
	background: rgba(248, 248, 248, 1);
}
.latejoin-cards {
	white-space: nowrap;
	min-width: 12em;
	text-align: left;
	border-bottom: 1px solid rgba(217, 217, 217, 1);
	}
.latejoin td {
	padding: 0.1em;
	}
.latejoin-link {
	max-width: 12em;
	padding: 0.2em 0;
	border-bottom: 1px solid rgba(217, 217, 217, 1);
	}
.latejoin-link > * {
	display: block;
	text-align: right;
	padding-right: 1em;
	}

.latejoin-link span {
	opacity: 0.6;
	}

.latejoin-card {
	display: inline-block;
	padding: 0.0em 0.1em;
	border: 2px solid black;
	background: #fff;
	border-radius: 3px;
	min-width: 1em;
	text-align: center;
	font-size: 90%;
	text-decoration: none;
	font-weight: bold;
	}

.latejoin-full {
	opacity: 0.4;
	color: black;
	}

a.latejoin-card {
	box-shadow: -0.5px -0.5px 3px 1px rgba(255, 255, 255, 0.7);
	color: white;
	}

a.latejoin-card:hover {
	box-shadow: 0 0 6px 2px white;
	}

.latejoin th {
	background: #3b3122;
	padding: 0.3em;
	margin-top: 0.5em;
}
.fuck {
	max-width: calc(50% - 12px);
	display: inline-block;
	vertical-align: top;
	margin: calc(12vw - 70px);
	margin-bottom: 0px;
	line-height: 1.2;
}
</style>
<h2>You are joining a round in progress.</h2>
<h3>Please choose from one of the remaining open positions.</h3>
<div>
"}

		// deal with it
		dat += ""
		if (ticker.mode && !istype(ticker.mode, /datum/game_mode/construction) && !istype(ticker.mode,/datum/game_mode/battle_royale) && !istype(ticker.mode,/datum/game_mode/football) )
			dat += {"<div class='fuck'><table class='latejoin'><tr><th colspan='2'>Command/Security</th></tr>"}
			for(var/datum/job/command/J in job_controls.staple_jobs)
				if (!J.department || J.department == "security")
					dat += LateJoinLink(J)
			for(var/datum/job/security/J in job_controls.staple_jobs)
				dat += LateJoinLink(J)
			dat += "</table>"

			dat += {"<table class='latejoin'></tr><tr><th colspan='2'>Research</th></tr>"}
			for(var/datum/job/command/J in job_controls.staple_jobs)
				if (J.department == "research")
					dat += LateJoinLink(J)
					break //one head per department
			for(var/datum/job/research/J in job_controls.staple_jobs)
				dat += LateJoinLink(J)
			for(var/datum/job/medical/J in job_controls.staple_jobs)
				if (J.department == "research")
					dat += LateJoinLink(J)
			dat += "</table>"

			//dat += {"<td valign="top"><table>"}
			dat += {"<table class='latejoin'><tr></tr><tr><th colspan='2'>Engineering</th></tr>"}
			for(var/datum/job/command/J in job_controls.staple_jobs)
				if (J.department == "engineering")
					dat += LateJoinLink(J)
					break
			for(var/datum/job/engineering/J in job_controls.staple_jobs)
				dat += LateJoinLink(J)
			dat += "</table>"

			dat += {"<table class='latejoin'><tr></tr><tr><th colspan='2'>Logistics</th></tr>"}
			for(var/datum/job/command/J in job_controls.staple_jobs)
				if (J.department == "logistics")
					dat += LateJoinLink(J)
					break
			for(var/datum/job/logistics/J in job_controls.staple_jobs)
				dat += LateJoinLink(J)
			dat += "</table>"
			//start of next column
			dat += {"</div><div class='fuck'><table class='latejoin'><tr><th colspan='2'>Medical</th></tr>"}
			for(var/datum/job/command/J in job_controls.staple_jobs)
				if (J.department == "medical")
					dat += LateJoinLink(J)
					break
			for(var/datum/job/medical/J in job_controls.staple_jobs)
				if (J.department == "research")
					continue// this is so we can stick genetics and pathology under research without changing *anything* else:)
				dat += LateJoinLink(J)
			dat += "</table>"

			dat += {"<table class='latejoin'></tr><tr><th colspan='2'>Civilian</th></tr>"}
			for(var/datum/job/command/J in job_controls.staple_jobs)
				if (J.department == "civilian")
					dat += LateJoinLink(J)
					break
			for(var/datum/job/civilian/J in job_controls.staple_jobs)
				dat += LateJoinLink(J)
			for(var/datum/job/daily/J in job_controls.staple_jobs)
				dat += LateJoinLink(J)
			// not showing if it's an ai or cyborg is the worst fuckin shit so: FIXED
			for(var/mob/living/silicon/S in mobs)
				if (IsSiliconAvailableForLateJoin(S))
					dat += {"<tr class='latejoin-link'><td colspan='2' class='latejoin-link'><a href='byond://?src=\ref[src];SelectedJob=\ref[S]'>[S.name] ([istype(S, /mob/living/silicon/ai) ? "AI" : "Cyborg"])</a></td></tr>"}

			dat += "</table>"
			// is this ever actually off? ?????
			if (job_controls.allow_special_jobs)
				dat += {"<table class='latejoin'><tr></tr><tr><th colspan='2'>Special Jobs</th></tr>"}
				for(var/datum/job/special/J in job_controls.special_jobs)
					if (IsJobAvailable(J) && !J.no_late_join)
						dat += LateJoinLink(J)

				for(var/datum/job/created/J in job_controls.special_jobs)
					if (IsJobAvailable(J) && !J.no_late_join)
						dat += LateJoinLink(J)
				dat += "</table>"

			dat += "</div>"

		else if(istype(ticker.mode,/datum/game_mode/battle_royale))
			//ahahaha you get no choices im going to just shove you in the game now good luck
			AttemptLateSpawn(new /datum/job/battler)
			return
		else if(istype(ticker.mode,/datum/game_mode/football))
			//ahahaha you get no choices im going to just shove you in the game now good luck
			AttemptLateSpawn(new /datum/job/football)
			return/*
		else if(istype(ticker.mode,/datum/game_mode/pod_wars))
			//Go to the team with less members
			var/datum/game_mode/pod_wars/mode = ticker.mode

			if (mode?.team_NT?.members?.len > mode?.team_SY?.members?.len)
				AttemptLateSpawn(new /datum/job/special/pod_wars/syndicate, 1)
			else
				AttemptLateSpawn(new /datum/job/special/pod_wars/nanotrasen, 1)

			return*/
		else
			var/datum/game_mode/construction/C = ticker.mode
			if (!C.enabled_jobs.len)
				var/datum/job/special/station_builder/D = new /datum/job/special/station_builder()
				D.limit = -1
				C.enabled_jobs += D
			for (var/datum/job/J in C.enabled_jobs)
				if (IsJobAvailable(J) && !J.no_late_join)
					dat += "<tr><td>"
					dat += {"<a href='byond://?src=\ref[src];SelectedJob=\ref[J]'><font color=[J.linkcolor]>[J.name]</font></a> ([countJob(J.name)][J.limit == -1 ? "" : "/[J.limit]"])<br>"}
					dat += "</td></tr>"
		dat += "</table></div></window></div>"

		src.Browse(dat, "window=latechoices;title=Joining a round in progress;size=655x755", true)
		//if(!bank_menu)
		//	bank_menu = new
		//bank_menu.Subscribe( usr.client )

	proc/create_character(var/datum/job/J, var/allow_late_antagonist = 0)
		if (!src || !src.mind || !src.client)
			return null
		if (!J)
			J = find_job_in_controller_by_string(src.mind.assigned_role)

		src.spawning = 1

		if(!(LANDMARK_LATEJOIN in landmarks))
			// the middle of the map is GeNeRaLlY part of the actual station. moreso than 1,1,1 at least
			var/midx = floor(world.maxx / 2)
			var/midy = floor(world.maxy / 2)
			boutput(world, "No latejoin landmarks placed, dumping [src] to ([midx], [midy], 1)")
			src.set_loc(locate(midx,midy,1))
		else
			src.set_loc(pick_landmark(LANDMARK_LATEJOIN))

		var/mob/new_character = null
		if (J)
			new_character = new J.mob_type(src.loc, client.preferences.AH)
		else
			new_character = new /mob/living/carbon/human(src.loc, client.preferences.AH) // fallback

		close_spawn_windows()

		client.preferences.copy_to(new_character,src)
		if(ishuman(new_character))
			var/mob/living/carbon/human/H = new_character
			H.update_colorful_parts()
		var/client/C = client
		mind.transfer_to(new_character)

		if (ticker?.mode && istype(ticker.mode, /datum/game_mode/assday))
			var/bad_type = ROLE_TRAITOR
			makebad(new_character, bad_type)
			new_character.mind.late_special_role = 1
			logTheThing("debug", new_character, null, "<b>Late join</b>: assigned antagonist role: [bad_type].")
		else
			if (ishuman(new_character) && allow_late_antagonist && current_state == GAME_STATE_PLAYING && ticker.round_elapsed_ticks >= 6000 && emergency_shuttle.timeleft() >= 300 && !C.hellbanned) // no new evils for the first 10 minutes or last 5 before shuttle
				if (late_traitors && ticker.mode && ticker.mode.latejoin_antag_compatible == 1)
					var/livingtraitor = 0

					for(var/datum/mind/brain in ticker.minds)
						if(brain.current && checktraitor(brain.current)) // if a traitor
							if (issilicon(brain.current) || brain.current.stat & 2 || brain.current.client == null) // if a silicon mob, dead or logged out, skip
								continue

							livingtraitor = 1
							logTheThing("debug", null, null, "<b>Late join</b>: checking [new_character.ckey], found livingtraitor [brain.key].")
							break

					var/bad_type = null
					if (islist(ticker.mode.latejoin_antag_roles) && length(ticker.mode.latejoin_antag_roles))
						bad_type = pick(ticker.mode.latejoin_antag_roles)
					else
						bad_type = ROLE_TRAITOR

					if ((!livingtraitor && prob(40)) || (livingtraitor && ticker.mode.latejoin_only_if_all_antags_dead == 0 && prob(4)))
						makebad(new_character, bad_type)
						new_character.mind.late_special_role = 1
						logTheThing("debug", new_character, null, "<b>Late join</b>: assigned antagonist role: [bad_type].")
						antagWeighter.record(role = bad_type, ckey = new_character.ckey, latejoin = 1)




		if(new_character?.client)
			new_character.client.loadResources()



		new_character.temporary_attack_alert(1200) //Messages admins if this new character attacks someone within 2 minutes of signing up. Might help detect grief, who knows?
		new_character.temporary_suicide_alert(1500) //Messages admins if this new character commits suicide within 2 1/2 minutes. probably a bit much but whatever
		return new_character

	Move()
		return 1 // do not return 0 in here for the love of god, let me tell you the tale of why:
		// the default mob/Login (which got called before we actually set our loc onto the start screen), will attempt to put the mob at (1, 1, 1) if the loc is null
		// however, the documentation actually says "near" (1, 1, 1), and will count Move returning 0 as that it cannot be placed there
		// by "near" it means anywhere on the goddamn map where Move will return 1, this meant that anyone logging in would cause the server to
		// grind itself to a slow death in a caciphony of endless Move calls

	proc/makebad(var/mob/living/carbon/human/traitormob, type)
		if (!traitormob || !ismob(traitormob) || !traitormob.mind)
			return

		var/datum/mind/traitor = traitormob.mind
		ticker.mode.traitors += traitor

		var/objective_set_path = null
		switch (type)

			if (ROLE_TRAITOR)
				traitor.special_role = ROLE_TRAITOR
			#ifdef RP_MODE
				objective_set_path = pick(typesof(/datum/objective_set/traitor/rp_friendly))
			#else
				objective_set_path = pick(typesof(/datum/objective_set/traitor))
			#endif

			if (ROLE_CHANGELING)
				traitor.special_role = ROLE_CHANGELING
				objective_set_path = /datum/objective_set/changeling
				traitormob.make_changeling()

			if (ROLE_VAMPIRE)
				traitor.special_role = ROLE_VAMPIRE
				objective_set_path = /datum/objective_set/vampire
				traitormob.make_vampire()

			if (ROLE_WRESTLER)
				traitor.special_role = ROLE_WRESTLER
				objective_set_path = pick(typesof(/datum/objective_set/traitor/rp_friendly))
				traitormob.make_wrestler(1)

			if (ROLE_GRINCH)
				traitor.special_role = ROLE_GRINCH
				objective_set_path = /datum/objective_set/grinch
				traitormob.make_grinch()

			if (ROLE_HUNTER)
				traitor.special_role = ROLE_HUNTER
				objective_set_path = /datum/objective_set/hunter
				traitormob.make_hunter()

			if (ROLE_WEREWOLF)
				traitor.special_role = ROLE_WEREWOLF
				objective_set_path = /datum/objective_set/werewolf
				traitormob.make_werewolf()

			if (ROLE_WRAITH)
				traitor.special_role = ROLE_WRAITH
				traitormob.make_wraith()
				generate_wraith_objectives(traitor)



			else // Fallback if role is unrecognized.
				traitor.special_role = ROLE_TRAITOR
			#ifdef RP_MODE
				objective_set_path = pick(typesof(/datum/objective_set/traitor/rp_friendly))
			#else
				objective_set_path = pick(typesof(/datum/objective_set/traitor))
			#endif

		if (!isnull(objective_set_path))
			if (ispath(objective_set_path, /datum/objective_set))
				new objective_set_path(traitor)
			else if (ispath(objective_set_path, /datum/objective))
				ticker.mode.bestow_objective(traitor, objective_set_path)

		var/obj_count = 1
		for(var/datum/objective/objective in traitor.objectives)
			#ifdef CREW_OBJECTIVES
			if (istype(objective, /datum/objective/crew) || istype(objective, /datum/objective/miscreant)) continue
			#endif
			boutput(traitor.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++

	proc/close_spawn_windows()
		if(client)
			src.Browse(null, "window=latechoices") //closes late choices window
			src.Browse(null, "window=playersetup") //closes the player setup window
			winshow(src, "joinmenu", 0)
			winshow(src, "playerprefs", 0)

	verb/declare_ready_use_token()
		set hidden = 1
		set name = ".ready_antag"

		if (src.client.has_login_notice_pending(TRUE))
			return

		if(!(!ticker || current_state <= GAME_STATE_PREGAME))
			src.show_text("Round has already started. You can't redeem tokens now. (You have [src.client.antag_tokens].)", "red")
		else if(src.client.antag_tokens > 0)
			if(master_mode in list("secret","traitor","nuclear","blob","wizard","changeling","mixed","mixed_rp","vampire","intrigue"))
				src.client.using_antag_token = 1
			src.show_text("Token redeemed, if mode supports redemption your new total will be [src.client.antag_tokens - 1].", "red")
		else
			src.show_text("You don't even have any tokens. How did you get here?", "red")

		src.declare_ready()

	verb/declare_ready()
		set hidden = 1
		set name = ".ready"

		if (src.client.has_login_notice_pending(TRUE))
			return

		if (ticker)
			if (ticker.mode)
				if (istype(ticker.mode, /datum/game_mode/construction))
					var/datum/game_mode/construction/C = ticker.mode
					if (C.in_setup)
						boutput(usr, "<span class='alert'>The round is currently being set up. Please wait.</span>")
						return

		if(!ticker || current_state <= GAME_STATE_PREGAME)
			if(!ready)
				ready = 1
				if (usr.client) winset(src, "joinmenu.button_charsetup", "is-disabled=true")
				if (usr.client) winset(src, "joinmenu.button_ready", "is-disabled=true;is-visible=false")
				if (usr.client) winset(src, "joinmenu.button_cancel", "is-disabled=false;is-visible=true")
				if (usr.client) winset(src, "joinmenu.button_ready_antag", "is-disabled=true")
				usr.Browse(null, "window=mob_occupation")
/*
				bank_menu = new
				bank_menu.Subscribe( usr.client )*/
				src.client.loadResources()
		else
			LateChoices()

	verb/cancel_ready()
		set hidden = 1
		set name = ".cancel_ready"

		if (src.client.has_login_notice_pending(TRUE))
			return

		if (ticker)
			if(ticker.pregame_timeleft <= 1 SECOND)
				boutput(usr, "<span class='alert'>It is too close to roundstart for you to unready. Please wait until setup finishes.</span>")
				return
			if (ticker.mode)
				if (istype(ticker.mode, /datum/game_mode/construction))
					var/datum/game_mode/construction/C = ticker.mode
					if (C.in_setup)
						boutput(usr, "<span class='alert'>You are already spawning, and cannot unready. Please wait until setup finishes.</span>")
						return

		if(ready)
			ready = 0
			winset(src, "joinmenu.button_charsetup", "is-disabled=false")
			winset(src, "joinmenu.button_ready", "is-disabled=false;is-visible=true")
			winset(src, "joinmenu.button_cancel", "is-disabled=true;is-visible=false")
			winset(src, "joinmenu.button_ready_antag", "is-disabled=false")
			if (src.client.using_antag_token)
				src.client.using_antag_token = 0
				src.show_text("Token cancelled", "red")

	verb/observe_round()
		set hidden = 1
		set name = ".observe_round"

		if (src.client.has_login_notice_pending(TRUE))
			return

		if(alert(src,"Are you sure you wish to observe? You will not be able to play this round!","Player Setup","Yes","No") == "Yes")
			if(!src.client) return
			var/mob/dead/observer/observer = new()
			if (src.client && src.client.using_antag_token) //ZeWaka: Fix for null.using_antag_token
				src.client.using_antag_token = 0
				src.show_text("Token refunded, your new total is [src.client.antag_tokens].", "red")
			src.spawning = 1

			close_spawn_windows()
			boutput(src, "<span class='notice'>Now teleporting.</span>")
			var/ASLoc = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, 1))
			if (ASLoc)
				observer.set_loc(ASLoc)
			observer.apply_looks_of(client)

			observer.observe_round = 1
			if(client.preferences && client.preferences.be_random_name) //Wire: fix for Cannot read null.be_random_name (preferences &&)
				client.preferences.randomize_name()
			observer.name = client.preferences.real_name

			if(!src.mind) src.mind = new(src)

			//src.mind.dnr=1
			src.mind.joined_observer=1
			src.mind.transfer_to(observer)
			observer.real_name = observer.name
			if(observer?.client)
				observer.client.loadResources()

			message_ghosts("<b>[observer]</b> is observing.")
			qdel(src)

	say(message)
		if(dd_hasprefix(message, "*"))
			return
		src.ooc(message)

#ifdef TWITCH_BOT_ALLOWED
	proc/try_force_into_bill() //try to put the twitch mob into shittbill
		if (src.client && src.client.ckey == TWITCH_BOT_CKEY)
			for(var/mob/living/carbon/human/biker/shittybill in mobs)
				if (shittybill.z == 2) continue
				if(!src.mind) src.mind = new(src)
				src.mind.transfer_to(shittybill)
				break
#endif
