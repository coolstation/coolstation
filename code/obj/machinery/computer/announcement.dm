/////////////////////////////////////// General Announcement Computer

/obj/machinery/computer/announcement
	name = "Announcement Computer"
	icon_state = "comm"
	machine_registry_idx = MACHINES_ANNOUNCEMENTS
	var/last_announcement = 0
	var/announcement_delay = 1200
	var/obj/item/card/id/ID = null
	var/unlocked = 0
	var/announce_status = "<div class = 'box warning'>Insert Card</div>"
	var/message = ""
	var/inhibit_updates = 0
	var/announces_arrivals = 0
	var/arrival_announcements_enabled = 1
	var/say_language = "english"
	var/arrivalalert = "$NAME has signed up as $JOB."
	var/departurealert = "$NAME the $JOB has entered cryogenic storage."
	var/obj/item/device/radio/intercom/announcement_radio = null
	var/voice_message = "broadcasts"
	var/voice_name = "Announcement Computer"
	var/sound_to_play = "sound/misc/announcement_1.ogg"
	req_access = list(access_heads)
	object_flags = CAN_REPROGRAM_ACCESS

	light_r =0.6
	light_g = 1
	light_b = 0.1

	New()
		..()
		if (src.announces_arrivals)
			src.announcement_radio = new(src)

	process()
		if (!inhibit_updates) src.updateUsrDialog()

	attack_hand(mob/user)
		if(..()) return
		src.add_dialog(user)
		var/dat = {"


	<style type="text/css">

		html{
			titlebar=0;
			can_resize=0;
			border=0;
		}

		body
		{
			background: #030602;
			font-family: "Not Jam Mono Clean 16";
			font-size: 16pt;
			letter-spacing: 2px;
			color: #52ff00;

		hr{
			border: 1px solid #52ff00;
		}

		@font-face {
				font-family: "Not Jam Mono Clean 16";
				font-style: normal;
				src: 'browserassets/css/fonts/Not Jam Mono Clean 16.ttf'
			}
			html { background: #030602;
					font-family: "Not Jam Mono Clean 16";
					font-size: 16pt;
					line-height: 1;
					animation-duration: 0.01s;
					animation-name: textflicker;
					animation-iteration-count: infinite;
					animation-direction: alternate;
			}
			h1 {
				font-size: 32px;
				text-align: left;
				background-color: #0A3609;
				color: #08FF03;
                width:auto;
				font-weight: normal;
			}
			.container {
			display: flex;
			flex-direction: row;
			}
            .box{
            border: 2px solid #08FF03;
			background-color: #11F20C;
			color: #011201;
            padding: 3px;
			font-size: 16pt;
            animation-duration: 0.01s;
              animation-name: boxflicker;
              animation-iteration-count: infinite;
              animation-direction: alternate;
              width: fit-content;
              display: inline;
              line-height: 200%;
              text-align: center;
              font-weight: normal;

            }
            .box.button{
            background-color: #020600;
			color: #52ff00;
            border: 2px solid #52ff00;
            }
			.holder{
			color: #171716;
			}
            .box.error{
               border: 5px groove red;
               padding: 3px;
               color: red;
               background-color: black ;
            }
			.box.warning{
				border: 2px groove #c6ff00;
				background-color: #0c1500;
				color: #c6ff00;
			}
			a{
				color:#52ff00;
			}
			.crt::before {
				content: " ";
				display: block;
				position: absolute;
				top: 0;
				left: 0;
				bottom: 0;
				right: 0;
				background: linear-gradient(rgba(18, 16, 16, 0) 50%, rgba(0, 0, 0, 0.25) 50%), linear-gradient(90deg, rgba(255, 0, 0, 0.06), rgba(0, 255, 0, 0.02), rgba(0, 0, 255, 0.06));
				z-index: 2;
				background-size: 100% 2px, 3px 100%;
				pointer-events: none;
			}
			@keyframes flicker {
				0% {
				opacity: 0.27861;
				}
				5% {
				opacity: 0.34769;
				}
				10% {
				opacity: 0.23604;
				}
				15% {
				opacity: 0.90626;
				}
				20% {
				opacity: 0.18128;
				}
				25% {
				opacity: 0.83891;
				}
				30% {
				opacity: 0.65583;
				}
				35% {
				opacity: 0.67807;
				}
				40% {
				opacity: 0.26559;
				}
				45% {
				opacity: 0.84693;
				}
				50% {
				opacity: 0.96019;
				}
				55% {
				opacity: 0.08594;
				}
				60% {
				opacity: 0.20313;
				}
				65% {
				opacity: 0.71988;
				}
				70% {
				opacity: 0.53455;
				}
				75% {
				opacity: 0.37288;
				}
				80% {
				opacity: 0.71428;
				}
				85% {
				opacity: 0.70419;
				}
				90% {
				opacity: 0.7003;
				}
				95% {
				opacity: 0.36108;
				}
				100% {
				opacity: 0.24387;
				}
				}

				.crt::after {
				content: " ";
				display: block;
				position: absolute;
				top: 0;
				left: 0;
				bottom: 0;
				right: 0;
				background: rgba(18, 16, 16, 0.1);
				opacity: 0;
				z-index: 2;
				pointer-events: none;
				animation: flicker 0.15s infinite;
				}




		</style>
		<body scroll=no class = "crt">


				<h1>Announcement Computer <button type="button" onclick="window.open('', '_self', ''); window.close();">Discard</button></h1>
				<hr>
			<div class = "container>
				<img src='[resource("images/consoles/transmit.gif")]'/>
				<div>
					<div class = "box">STATUS</div> [announce_status]<BR>
					<div class = "box">CARD</div> <a href='byond://?src=\ref[src];card=1' class = 'filler'>[src.ID ? src.ID.name : "--------"]</a><br>

					<div class = "box">BROADCAST DELAY</div> [nice_timer()]<br>
					<div class = "box">MESSAGE</div> "<a href='byond://?src=\ref[src];edit_message=1'>[src.message ? src.message : "___________"]</a>" <a class = "box error" href='byond://?src=\ref[src];clear_message=1'>CLEAR</a><br>
					<div class = "box button"><b><a href='byond://?src=\ref[src];send_message=1'>TRANSMIT</a></b></div>
				</div>
			</div>
			"}
		if (src.announces_arrivals)
			dat += "<hr>[src.arrival_announcements_enabled ? "Arrival Announcement Message: \"[src.arrivalalert]\"<br><br><b><a href='byond://?src=\ref[src];set_arrival_message=1'>Change</a></b><br><b><a href='byond://?src=\ref[src];toggle_arrival_message=1'>Disable</a></b>" : "Arrival Announcements Disabled<br><br><b><a href='byond://?src=\ref[src];toggle_arrival_message=1'>Enable</a></b>"]"
		dat += "</body>"
		user.Browse(dat, "window=announcementcomputer")
		onclose(user, "announcementcomputer")

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/card/id))
			if (src.ID)
				src.ID.set_loc(src.loc)
				boutput(user, "<span class='notice'>[src.ID] is ejected from the ID scanner.</span>")
			user.drop_item()
			W.set_loc(src)
			src.ID = W
			src.unlocked = check_access(ID, 1)
			boutput(user, "<span class='notice'>You insert [W].</span>")
			return
		..()

	Topic(href, href_list[])
		if(..()) return

		if(href_list["card"])
			if(src.ID)
				src.ID.set_loc(src.loc)
				usr.put_in_hand_or_eject(src.ID) // try to eject it into the users hand, if we can
				src.ID = null
				src.unlocked = 0
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/card/id))
					usr.drop_item()
					I.set_loc(src)
					src.ID = I
					src.unlocked = check_access(ID, 1)
				else if (istype(I, /obj/item/magtractor))
					var/obj/item/magtractor/mag = I
					if (istype(mag.holding, /obj/item/card/id))
						I = mag.holding
						mag.dropItem(0)
						I.set_loc(src)
						src.ID = I
						src.unlocked = check_access(ID, 1)

		else if(href_list["edit_message"])
			inhibit_updates = 1
			message = copytext( html_decode(trim(strip_html(html_decode(input("Select what you wish to announce.", "Announcement."))))), 1, 280 )
			if(url_regex?.Find(message)) message = ""
			inhibit_updates = 0
			playsound(src.loc, "keyboard", 50, 1, -15)

		else if (href_list["clear_message"])
			message = ""

		else if (href_list["send_message"])
			send_message(usr)

		else if (href_list["set_arrival_message"])
			inhibit_updates = 1
			src.set_arrival_alert(usr)
			inhibit_updates = 0

		else if (href_list["toggle_arrival_message"])
			src.arrival_announcements_enabled = !(src.arrival_announcements_enabled)
			boutput(usr, "Arrival announcements [src.arrival_announcements_enabled ? "en" : "dis"]abled.")

		update_status()
		src.updateUsrDialog()

	proc/update_status()
		if(!src.ID)
			announce_status = "<div class = 'box warning'>Insert Card</div>"
		else if(!src.unlocked)
			announce_status = "<div class = 'box error'>INSUFFICIENT ACCESS</div>"
		else if(!message)
			announce_status = "Input message."
		else if(get_time() > 0)
			announce_status = "Broadcast delay in effect."
		else
			announce_status = "Ready to transmit!"

	proc/send_message(var/mob/user)
		if(!message || !unlocked || get_time() > 0) return
		var/area/A = get_area(src)

		if(user.bioHolder.HasEffect("mute"))
			boutput(user, "You try to speak into \the [src] but you can't since you are mute.")
			return

		logTheThing("say", user, null, "created a command report: [message]")
		logTheThing("diary", user, null, "created a command report: [message]", "say")

		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			message = process_accents(H, message) //Slurred announcements? YES!

		command_announcement(message, "[A.name] Announcement by [ID.registered] ([ID.assignment])", sound_to_play)
		last_announcement = world.timeofday
		message = ""

	proc/nice_timer()
		if (world.timeofday < last_announcement)
			last_announcement = 0
		var/time = get_time()
		if(time < 0)
			return "--:--"
		else
			var/seconds = text2num(time) % 60 //ZeWaka: Should fix type mismatches.
			var/flick_seperator = (seconds % 2 == 0) // why was this being calculated after converting BACK into a string?!!! - cirr
			// VARIABLES SHOULDN'T CHANGE TYPE FROM STRING TO NUMBER TO STRING LIKE THIS IN LIKE SIX LINES AAGGHHHHH FUCK YOU DYNAMIC TYPING
			var/minutes = round(text2num((time - seconds) / 60))
			minutes = minutes < 10 ? "0[minutes]" : "[minutes]"
			seconds = seconds < 10 ? "0[seconds]" : "[seconds]"

			return "[minutes][flick_seperator ? ":" : " "][seconds]"

	proc/get_time()
		return max(((last_announcement + announcement_delay) - world.timeofday ) / 10, 0)

	proc/set_arrival_alert(var/mob/user)
		if (!user)
			return
		var/newalert = input(user,"Please enter a new arrival alert message. Valid tokens: $NAME, $JOB, $STATION, $THEY, $THEM, $THEIR", "Custom Arrival Alert", src.arrivalalert) as null|text
		if (!newalert)
			return
		if (!findtext(newalert, "$NAME"))
			user.show_text("The alert needs at least one $NAME token.", "red")
			return
		if (!findtext(newalert, "$JOB"))
			user.show_text("The alert needs at least one $JOB token.", "red")
			return
		src.arrivalalert = sanitize(adminscrub(newalert, 200))
		logTheThing("station", user, src, "sets the arrival announcement on [constructTarget(src,"station")] to \"[src.arrivalalert]\"")
		user.show_text("Arrival alert set to '[newalert]'", "blue")
		playsound(src.loc, "keyboard", 50, 1, -15)
		return

	proc/say_quote(var/text)
		return "[src.voice_message], \"[text]\""

	proc/process_language(var/message)
		var/datum/language/L = languages.language_cache[src.say_language]
		if (!L)
			L = languages.language_cache["english"]
		return L.get_messages(message)

	proc/announce_arrival(var/mob/living/person)
		if (!src.announces_arrivals)
			return 1
		if (!src.announcement_radio)
			src.announcement_radio = new(src)

		var/message = replacetext(replacetext(replacetext(src.arrivalalert, "$STATION", "[station_name()]"), "$JOB", person.mind.assigned_role), "$NAME", person.real_name)
		message = replacetext(replacetext(replacetext(message, "$THEY", "[he_or_she(person)]"), "$THEM", "[him_or_her(person)]"), "$THEIR", "[his_or_her(person)]")

		var/list/messages = process_language(message)
		src.announcement_radio.talk_into(src, messages, 0, src.name, src.say_language)
		world << csound("sounds/misc/announcement_chime.ogg")
		logTheThing("station", src, null, "ANNOUNCES: [message]")
		return 1

	proc/announce_departure(var/mob/living/person)
		if (!src.announcement_radio)
			src.announcement_radio = new(src)

		var/message = replacetext(replacetext(replacetext(src.departurealert, "$STATION", "[station_name()]"), "$JOB", person.mind.assigned_role), "$NAME", person.real_name)
		message = replacetext(replacetext(replacetext(message, "$THEY", "[he_or_she(person)]"), "$THEM", "[him_or_her(person)]"), "$THEIR", "[his_or_her(person)]")

		var/list/messages = process_language(message)
		src.announcement_radio.talk_into(src, messages, 0, src.name, src.say_language)
		logTheThing("station", src, null, "ANNOUNCES: [message]")
		return 1

/obj/machinery/computer/announcement/console_upper
	icon = 'icons/obj/machines/computerpanel.dmi'
	icon_state = "announcement1"
/obj/machinery/computer/announcement/console_lower
	icon = 'icons/obj/machines/computerpanel.dmi'
	icon_state = "announcement2"

/obj/machinery/computer/announcement/syndie
		icon_state = "syndiepc14"
		icon = 'icons/obj/decoration.dmi'
		req_access = null
		name = "Syndicate Announcement computer"
		voice_name = "Syndicate Announcement Computer"
