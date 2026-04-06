#define NUBOT_LUM 2

/mob/living/silicon/nubot
	icon = 'icons/mob/nu_bot.dmi'
	icon_state = "drone-dead"

	max_health = 250
	density = 1 //no bumping into people, basically
	robot_talk_understand = 1

	sound_fart = 'sound/voice/farts/poo2_robot.ogg'

	punchMessage = "whaps"
	kickMessage = "bonks"

	var/datum/hud/ghostdrone/hud
	var/obj/item/device/radio/radio = null

	var/obj/item/active_tool = null
	var/list/obj/item/tools = list()

	//state tracking
	var/faceColor
	var/faceType
	var/charging = 0
	var/newDrone = 0

	var/jetpack = 1 //fuck whoever made this
	var/jeton = 0

	var/has_flight = FALSE //does it do a fly animation?
	var/has_screen = FALSE //does it have a screen with a face?

	//gimmicky things
	var/obj/item/clothing/head/hat = null
	var/obj/item/clothing/suit/bedsheet/bedsheet = null

	New()
		..()
		hud = new(src)
		src.attach_hud(hud)
		//src.sight |= SEE_TURFS //Uncomment for meson-like vision. I'm not a fan of it though. -Wire

		//Set the drone name
		if (rand(1, 1000) == 69 && ticker?.mode) //heh
			//Nuke op radio freq
			if (istype(ticker.mode, /datum/game_mode/nuclear))
				var/datum/game_mode/nuclear/mode = ticker.mode
				name = "Drone [mode.agent_radiofreq]"

			else
				//Make them suffer with an overly cute name
				name = "Drone [pick(list("Princess", "Lord", "King", "Queen", "Duke", "Baron"))] [pick(list("Bubblegum", "Wiffleypop", "Shnookems", "Cutesypie", "Fartbiscuits", "Rolypoly"))]"

		else
			var/letters = list("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")
			name = "Drone [pick(letters)][pick(letters)][pick(letters)]-[rand(10,99)]"

		real_name = name

		var/obj/item/cell/cerenkite/charged/CELL = new /obj/item/cell/cerenkite/charged(src)
		src.cell = CELL


		src.health = src.max_health
		src.botcard.access = get_all_accesses()
		src.radio = new /obj/item/device/radio(src)
		src.ears = src.radio

		//Attach shit to tools
		src.tools = list(
			new /obj/item/magtractor(src),
			new /obj/item/tool/omnitool/silicon(src),
			new /obj/item/rcd/safe(src),
			new /obj/item/lamp_manufacturer(src),
			new /obj/item/device/analyzer/atmospheric(src),
			new /obj/item/device/t_scanner(src),
			new /obj/item/electronics/soldering(src),
			new /obj/item/electronics/scanner(src),
			new /obj/item/deconstructor/borg(src),
			new /obj/item/weldingtool(src),
			new /obj/item/device/light/flashlight(src)
		)

		var/obj/item/cable_coil/W = new /obj/item/cable_coil(src)
		W.amount = 1000
		W.max_stack = 1000 //may as well make this "correct"
		src.tools += W

		//Make all the tools un-drop-able (to closets/tables etc)
		for (var/obj/item/O in src.tools)
			O.cant_drop = 1

		/*SPAWN_DBG(0)
			out(src, "<b>Use \"say ; (message)\" to speak to fellow drones through the spooky power of spirits within machines.</b>")
			src.show_laws_drone()*/

	update_canmove() // this is called on Life() and also by force_laydown_standup() btw
		..()
		if (!src.canmove)
			src.lastgasp() // calling lastgasp() here because we just got knocked out
			setunconscious(src)
			if (src.get_eye_blurry())
				src.change_eye_blurry(-1)
			if (src.dizziness)
				dizziness--

	force_laydown_standup() // more like force dizzy undizzy
		..()
		if (!src.canmove)
			src.setFace("dizzy", faceColor, 1) // set dizzy face
			var/image/dizzyStars = src.SafeGetOverlayImage("dizzy", src.icon, "dizzy", MOB_OVERLAY_BASE+1)
			src.UpdateOverlays(dizzyStars, "dizzy")
		else
			src.setFace(faceType, faceColor)
			src.UpdateOverlays(null, "dizzy")

	proc/updateStatic()
		if (!src.client)
			return
		src.client.images.Remove(mob_static_icons)
		for (var/image/I in mob_static_icons)
			if (!I || !I.loc || !src)
				continue
			if (I.loc.invisibility && I.loc != src.loc)
				continue
			else
				src.client.images.Add(I)

	death(gibbed)
		logTheThing("combat", src, null, "was destroyed at [log_loc(src)].")
		setdead(src)
		if (src.mind)
			src.mind.dnr = 0

			var/mob/dead/observer/ghost = src.ghostize()
			ghost.icon = 'icons/mob/ghost_drone.dmi'
			ghost.icon_state = "drone-ghost"

			//This stuff is hacky but I don't feel like messing with observer New code so fuck it
			if (!src.oldmob) //Prevents re-entering a ghostdrone corpse
				ghost.verbs -= /mob/dead/observer/proc/reenter_corpse
			ghost.name = (src.oldname ? src.oldname : src.real_name)
			ghost.real_name = (src.oldname ? src.oldname : src.real_name)

		//So the drone cant pick up an item and then die, sending the item ~to the void~
		var/obj/item/magtractor/mag = locate(/obj/item/magtractor) in src.tools
		var/obj/item/magHeld = mag.holding ? mag.holding : null
		if (magHeld) magHeld.set_loc(get_turf(src))

		if (gibbed)
			src.visible_message("<span class='combat'>[src.name] explodes in a shower of lost hopes and dreams.</span>")
			var/turf/T = get_ranged_target_turf(src, pick(alldirs), 3)
			if (magHeld) magHeld.throw_at(T, 3, 1) //flying...anything
			if (src.hat) src.takeoffHat(pick(alldirs)) //flying hats
			if (src.bedsheet) //flying bedsheets
				bedsheet.set_loc(get_turf(src))
				bedsheet.throw_at(T, 3, 1)
			..(1)
		else
			src.lastgasp()
			var/msg
			switch(rand(1,3))
				if (1)
					msg = "[src.name] [pick("falls", "crashes", "sinks")] to the ground, ghost-less."
				if (2)
					msg = "The spirit powering [src.name] packs up and leaves."
				if (3)
					msg = "[src.name]'s scream's gain echo and lose their electronic modulation as its soul is ripped monstrously from the cold metal body it once inhabited."

			src.visible_message("<span class='combat'>[msg]</span>")
			if (src.hat) src.takeoffHat()
			src.updateSprite()
			..()

	set_pulling(atom/movable/A)
		. = ..()
		hud.update_pulling()

	disposing()
		if (src in available_ghostdrones)
			available_ghostdrones -= src
		..()

	//Apparently leaving this on made the parent updatehealth set health to max_health in all cases, because there's no such thing as bruteloss and
	// so on with this mob
	updatehealth()
		return

	full_heal()
		var/before = src.stat
		..()
		if (before == 2 && src.stat < 2) //if we were dead, and now arent
			src.updateSprite()

	TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
		if (src.nodamage) return //godmode
		src.health -= max(burn, brute)
		if (!isdead(src) && src.health <= 0) //u ded
			if (brute >= src.max_health)
				src.gib()
			else
				death()
		return

	examine()
		. = ..()

		. += "*---------*"

		if (isdead(src))
			. += "<span style'color:red'>It looks dead and lifeless.</span>\n*---------*"
			return


		var/list/msg = list("<span class='notice'>")
		if (src.active_tool)
			msg += "[src] is holding a little [bicon(src.active_tool)] [src.active_tool.name]"
			if (istype(src.active_tool, /obj/item/magtractor) && src.active_tool:holding)
				msg += ", containing \an [src.active_tool:holding]"
			msg += "<br>"
		msg += "[src] has a power charge of [bicon(src.cell)] [src.cell.charge]/[src.cell.maxcharge]</span>"

		. += msg.Join("")

		if (src.health < src.max_health)
			if (src.health < (src.max_health / 2))
				. += "<span class='alert'>It's rather badly damaged. It probably needs some wiring replaced inside.</span>"
			else
				. += "<span class='alert'>It's a bit damaged. It looks like it needs some welding done.</span>"

		. += "*---------*"

	Login()
		..()
		if (isalive(src))
			src.visible_message("<span class='notice'>[src.name] comes online.</span>", "<span class='notice'>You come online!</span>")
			src.updateSprite()

	Logout()
		..()
		src.updateSprite()

	//Change that faaaaace
	proc/setFace(type = "happy", color = "#7fc5ed", var/temp = 0)

		if(src.has_screen == TRUE)
			if (!type)
				type = src.faceType ? src.faceType : "happy"
			if (!color)
				color = src.faceColor ? src.faceColor : "#7fc5ed"
			if (!temp)
				src.faceType = type
				src.faceColor = color
			if (!src.client || isdead(src) || src.charging || !src.canmove) // Save state but don't apply changes if charging, can't move, etc.
				return 1
			if (src.bedsheet)
				UpdateOverlays(null, "face")
				src.remove_sm_light("ghostdrone\ref[src]")
				src.icon_state = "g_drone["-[type]"]"
				return 1

			var/image/newFace = src.SafeGetOverlayImage("face", src.icon, "drone-[type]", MOB_OVERLAY_BASE)
			if (!newFace) // this should never be the case but let's be careful anyway!!
				return 1

			if (color != src.faceColor || newFace.color != color)//forceNew) //Color is new
				src.faceColor = color
				newFace.color = color
				updateHoverDiscs(color) //ok we're also gonna color hoverdiscs too because hell yeah kickin rad

			if (length(color) == 7) //Set our luminosity color, if valid
				var/colors = GetColors(src.faceColor)
				src.add_sm_light("ghostdrone\ref[src]", list(colors[1],colors[2],colors[3],0.4 * 255))



			src.toggle_sm_light(1)
			UpdateOverlays(newFace, "face")
			return 1

	proc/setFaceDialog()
		var/newFace = input(usr, "Select your faceplate", "Drone", src.faceType) as null|anything in list("Happy", "Sad", "Mad")
		if (!newFace) return 0
		var/newColor = input(usr, "Select your faceplate color", "Drone", src.faceColor) as null|color
		if (!newFace && !newColor) return 0
		newFace = (newFace ? lowertext(newFace) : src.faceType)
		newColor = (newColor ? newColor : src.faceColor)
		src.setFace(type = newFace, color = newColor)
		return 1

	proc/updateHoverDiscs(color = "#7fc5ed")
		var/image/newHover = GetOverlayImage("hoverDiscs")
		if (!newHover) newHover = image('icons/effects/effects.dmi', "hoverdiscs")

		newHover.color = color
		newHover.pixel_y = -5
		newHover.layer = MOB_EFFECT_LAYER

		UpdateOverlays(newHover, "hoverDiscs")
		return 1

	proc/updateSprite()
		if (isdead(src) || !src.client || src.charging || src.newDrone)
			src.toggle_sm_light(0)
			if (src.bedsheet)
				//fuckin bedsheets...
				if (isdead(src) || !src.client) //dead or no client
					src.icon_state = "g_drone-dead"
			else if (!src.bedsheet)
				if (src.newDrone)
					src.icon_state = "drone-idle"
				else if (src.charging)
					src.icon_state = "drone-charging"
				else // dead or no client
					src.icon_state = "drone-dead"
			else
				src.icon_state = "g_drone-dead"

			if (!isdead(src))
				src.add_sm_light("ghostdrone\ref[src]", list(0.94*255,0.88*255,0.12*255,0.4 * 255))
			UpdateOverlays(null, "face")
			UpdateOverlays(null, "hoverDiscs")
			animate(src) //stop bumble animation
		else if (src.client)
			//New drone stuff
			if (!src.faceType)
				src.setFace(type = "happy", color = "#7fc5ed") //defaults

			if (src.health > 0 && src.has_flight == TRUE)
				animate_bumble(src, floatspeed = 15, Y1 = 2, Y2 = -2) //yayyyyy bumble anim
			else
				animate(src)



				//damage states to go here

	hand_attack(atom/target, params)
		//A thing to stop drones interacting with pick-up-able things by default
		if (target && isitem(target))
			var/obj/item/I = target
			if (!I.anchored)
				return 0

		..()


	Stat()
		..()
		// There shouldn't ever be a case where a ghostdrone has no cell.
		// Might also be nice to move this to the HUD maybe? idk.
		if(src.cell)
			stat("Charge Left:", "[src.cell.charge]/[src.cell.maxcharge]")
		else
			stat("No Cell Inserted!")


	Bump(atom/movable/AM as mob|obj, yes)
		SPAWN_DBG( 0 )
			if ((!( yes ) || src.now_pushing))
				return
			//..()
			if (!istype(AM, /atom/movable))
				return
			if (!src.now_pushing)
				src.now_pushing = 1
				if (!AM.anchored)
					var/t = get_dir(src, AM)
					step(AM, t)
				src.now_pushing = null
			if(AM)
				AM.last_bumped = world.timeofday
				AM.Bumped(src)
			return
		return

	//Four very important procs follow
	proc/putonHat(obj/item/clothing/head/W as obj, mob/user as mob)
		src.hat = W
		W.set_loc(src)
		var/image/hatImage = image(icon = W.icon, icon_state = W.icon_state, layer = src.layer+0.1)
		hatImage.pixel_y = 5
		hatImage.transform *= 0.85
		UpdateOverlays(hatImage, "hat")
		return 1

	proc/takeoffHat(forcedDir = null)
		UpdateOverlays(null, "hat")
		src.hat.set_loc(get_turf(src))

		var/turf/T
		if (isnum(forcedDir))
			T = get_ranged_target_turf(src, forcedDir, 3)
		if (isturf(forcedDir))
			T = forcedDir
		if (isturf(T))
			src.hat.throw_at(T, 3, 1)

		src.hat = null
		return 1

	proc/putonSheet(obj/item/clothing/suit/bedsheet/W as obj, mob/user as mob)
		W.set_loc(src)
		src.bedsheet = W
		src.setFace(faceType, faceColor) // removes face overlay and lumin (also sets icon)
		return 1

	proc/takeoffSheet()
		src.bedsheet.set_loc(get_turf(src))
		src.bedsheet = null
		if (!isdead(src)) //alive
			if (!canmove)
				src.setFace("dizzy", faceColor, 1)
			else
				src.setFace(faceType, faceColor)
			src.icon_state = "drone"
			src.updateHoverDiscs(color = faceColor)
			if (src.charging)
				src.updateSprite()
		else //dead
			src.icon_state = "drone-dead"
		return 1

	attackby(obj/item/W as obj, mob/user as mob)
		if(isweldingtool(W))
			if (user.a_intent == INTENT_HARM)
				if (W:try_weld(user,0,-1,0,0))
					user.visible_message("<span class='alert'><b>[user] burns [src] with [W]!</b></span>")
					damage_heat(W.force)
				else
					user.visible_message("<span class='alert'><b>[user] beats [src] with [W]!</b></span>")
					damage_blunt(W.force)
			else
				if (src.health >= src.max_health)
					boutput(user, "<span class='alert'>It isn't damaged!</span>")
					return
				if (get_fraction_of_percentage_and_whole(src.health,src.max_health) < 33)
					boutput(user, "<span class='alert'>You need to use wire to fix the cabling first.</span>")
					return
				if(W:try_weld(user, 1))
					src.health = max(1,min(src.health + 5,src.max_health))
					user.visible_message("<b>[user]</b> uses [W] to repair some of [src]'s damage.")
					if (src.health == src.max_health)
						boutput(user, "<span class='notice'><b>[src] looks fully repaired!</b></span>")
				else
					boutput(user, "<span class='alert'>You need more welding fuel!</span>")

		else if (istype(W,/obj/item/cable_coil/))
			if (src.health >= src.max_health)
				boutput(user, "<span class='alert'>It isn't damaged!</span>")
				return
			var/obj/item/cable_coil/C = W
			if (get_fraction_of_percentage_and_whole(src.health,src.max_health) >= 33)
				boutput(user, "<span class='alert'>The cabling looks fine. Use a welder to repair the rest of the damage.</span>")
				return
			C.use(1)
			src.health = max(1,min(src.health + 5,src.max_health))
			user.visible_message("<b>[user]</b> uses [C] to repair some of [src]'s cabling.")
			playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
			if (src.health >= 25)
				boutput(user, "<span class='notice'>The wiring is fully repaired. Now you need to weld the external plating.</span>")

		else if (istype(W, /obj/item/clothing/head))
			if(src.hat)
				boutput(user, "<span class='alert'>[src] is already wearing a hat!</span>")
				return

			user.drop_item()
			src.putonHat(W, user)
			if (user == src)

			else
				user.visible_message("<b>[user]</b> gently places a hat on [src]!", "You gently place a hat on [src]!")
			return

		else if (istype(W, /obj/item/clothing/suit/bedsheet))
			if (src.bedsheet)
				boutput(user, "<span class='alert'>There is already a sheet draped over [src]! Two sheets would be ridiculous!</span>")
				return

			user.drop_item()
			src.putonSheet(W, user)
			user.visible_message("<b>[user]</b> drapes a sheet over [src]!", "You cover [src] with a sheet!")
			return

		else
			return ..(W, user)

	attack_hand(mob/user)
		if(!user.stat)
			switch(user.a_intent)
				if(INTENT_HELP) //Friend person
					playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, SOUND_RANGE_STANDARD)
					user.visible_message("<span class='notice'>[user] gives [src] a [pick_string("descriptors.txt", "borg_pat")] pat on the [pick("back", "head", "shoulder")].</span>")
				if(INTENT_DISARM) //Shove
					SPAWN_DBG(0) playsound(src.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 40, 1)
					user.visible_message("<span class='alert'><B>[user] shoves [src]! [prob(40) ? pick_string("descriptors.txt", "jerks") : null]</B></span>")
					if (src.hat)
						user.visible_message("<b>[user]</b> knocks \the [src.hat] off [src]!", "You knock the hat off [src]!")
						src.takeoffHat()
					else if (src.bedsheet)
						user.visible_message("<b>[user]</b> pulls the sheet off [src]!", "You pull the sheet off [src]!")
						src.takeoffSheet()
				if(INTENT_GRAB) //Shake
					playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 30, 1, SOUND_RANGE_STANDARD)
					user.visible_message("<span class='alert'>[user] shakes [src] [pick_string("descriptors.txt", "borg_shake")]!</span>")
				if(INTENT_HARM) //Dumbo
					playsound(src.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', 60, 1)
					user.visible_message("<span class='alert'><B>[user] punches [src]! What [pick_string("descriptors.txt", "borg_punch")]!</span>", "<span class='alert'><B>You punch [src]![prob(20) ? " Turns out they were made of metal!" : null] Ouch!</B></span>")
					random_brute_damage(user, rand(2,5))
					if(prob(10)) src.show_text("Your manipulator hurts...", "red")

			add_fingerprint(user)


	proc/store_active_tool()
		if (!src.active_tool)
			return
		src.active_tool.dropped(src) // Handle light datums and the like.
		src.active_tool = null
		hud.set_active_tool(0)
		hud.update_tools()

	equipped()
		if (!active_tool)
			return null
		return active_tool

	u_equip(obj/item/W as obj)
		..()
		if (src.active_tool)
			if (istype(src.active_tool, /obj/item/magtractor) && src.active_tool:holding && W == src.active_tool:holding)
				var/obj/item/magtractor/mag = src.active_tool
				mag.dropItem(0)
			else if (W == src.active_tool)
				src.uneq_slot()

	proc/uneq_slot()
		if (src.active_tool)
			if (istype(src.active_tool, /obj/item/magtractor))
				var/obj/item/magtractor/mag = src.active_tool
				if (mag.holding)
					// drop the item that's being held first,
					// so we can pick up things immediately without having to re-equip
					actions.stopId("magpickerhold", src)
					hud.update_tools()
					hud.update_equipment()
					return

				else
					actions.stopId("magpicker", src)
			if (isitem(src.active_tool))
				src.active_tool.dropped(src) // Handle light datums and the like.
		src.active_tool = null
		hud.set_active_tool(null)
		hud.update_tools()
		hud.update_equipment()

	use_power()
		..()
		if (src.cell)
			if(src.cell.charge <= 0)
				if (isalive(src))
					out(src, "<span class='combat bold'>You have run out of power!</span>")
					death()
			else if (src.cell.charge <= 100)
				src.active_tool = null

				uneq_slot()
				src.cell.use(1)
			else
				var/power_use_tally = 2
				if (src.active_tool)
					power_use_tally += 3
					if (istype(src.active_tool, /obj/item/magtractor) && src.active_tool:highpower)
						power_use_tally += 15
				src.cell.use(power_use_tally)
				setalive(src)
		else //This basically should never happen with ghostdrones
			if (isalive(src))
				death()

		src.hud.update_charge()

	emote(var/act, var/voluntary = 1)
		var/param = null
		if (findtext(act, " ", 1, null))
			var/t1 = findtext(act, " ", 1, null)
			param = copytext(act, t1 + 1, length(act) + 1)
			act = copytext(act, 1, t1)

		var/m_type = 1
		var/m_anim = 0
		var/message

		switch(lowertext(act))
			if ("help")
				src.show_text("To use emotes, simply enter \"*(emote)\" as the entire content of a say message. Certain emotes can be targeted at other characters - to do this, enter \"*emote (name of character)\" without the brackets.")
				src.show_text("For a list of all emotes, use *list. For a list of basic emotes, use *listbasic. For a list of emotes that can be targeted, use *listtarget.")

			if ("list")
				src.show_text("Basic emotes:")
				src.show_text("clap, flap, aflap, twitch, twitch_s, scream, birdwell, fart, flip, custom, customv, customh")
				src.show_text("Targetable emotes:")
				src.show_text("salute, bow, hug, wave, glare, stare, look, leer, nod, point")

			if ("listbasic")
				src.show_text("clap, flap, aflap, twitch, twitch_s, scream, birdwell, fart, flip, custom, customv, customh")

			if ("listtarget")
				src.show_text("salute, bow, hug, wave, glare, stare, look, leer, nod, point")

			if ("salute","bow","hug","wave","glare","stare","look","leer","nod")
				// visible targeted emotes
				if (!src.restrained())
					var/M = null
					if (param)
						for (var/mob/A in view(null, null))
							if (ckey(param) == ckey(A.name))
								M = A
								break
					if (!M)
						param = null

					act = lowertext(act)
					if (param)
						switch(act)
							if ("bow","wave","nod")
								message = "<B>[src]</B> [act]s to [param]."
							if ("glare","stare","look","leer")
								message = "<B>[src]</B> [act]s at [param]."
							else
								message = "<B>[src]</B> [act]s [param]."
					else
						switch(act)
							if ("hug")
								message = "<B>[src]</b> [act]s itself."
							else
								message = "<B>[src]</b> [act]s."
				else
					message = "<B>[src]</B> struggles to move."
				m_type = 1

			if ("point")
				if (!src.restrained())
					var/mob/M = null
					if (param)
						for (var/atom/A as mob|obj|turf|area in view(null, null))
							if (ckey(param) == ckey(A.name))
								M = A
								break

					if (!M)
						message = "<B>[src]</B> points."
					else
						src.point(M)

					if (M)
						message = "<B>[src]</B> points to [M]."
					else
				m_type = 1

			if ("panic","freakout")
				if (!src.restrained())
					message = "<B>[src]</B> enters a state of hysterical panic!"
				else
					message = "<B>[src]</B> starts writhing around in manic terror!"
				m_type = 1

			if ("clap")
				if (!src.restrained())
					message = "<B>[src]</B> claps."
					m_type = 2

			if ("flap")
				if (!src.restrained())
					message = "<B>[src]</B> flaps its wings."
					m_type = 2

			if ("aflap")
				if (!src.restrained())
					message = "<B>[src]</B> flaps its wings ANGRILY!"
					m_type = 2

			if ("custom")
				var/input = sanitize(input("Choose an emote to display."))
				var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
				if (input2 == "Visible")
					m_type = 1
				else if (input2 == "Hearable")
					m_type = 2
				else
					alert("Unable to use this emote, must be either hearable or visible.")
					return
				message = "<B>[src]</B> [input]"

			if ("customv")
				if (!param)
					param = input("Choose an emote to display.")
					if(!param) return
				param = html_encode(sanitize(param))
				message = "<b>[src]</b> [param]"
				m_type = 1

			if ("customh")
				if (!param)
					param = input("Choose an emote to display.")
					if(!param) return
				param = html_encode(sanitize(param))
				message = "<b>[src]</b> [param]"
				m_type = 2

			if ("me")
				if (!param)
					return
				param = html_encode(sanitize(param))
				message = "<b>[src]</b> [param]"
				m_type = 1

			if ("smile","grin","smirk","frown","scowl","grimace","sulk","pout","blink","nod","shrug","think","ponder","contemplate")
				// basic visible single-word emotes
				message = "<B>[src]</B> [act]s."
				m_type = 1

			if ("flipout")
				message = "<B>[src]</B> flips the fuck out!"
				m_type = 1

			if ("rage","fury","angry")
				message = "<B>[src]</B> becomes utterly furious!"
				m_type = 1

			if ("twitch")
				message = "<B>[src]</B> twitches."
				m_type = 1
				SPAWN_DBG(0)
					var/old_x = src.pixel_x
					var/old_y = src.pixel_y
					src.pixel_x += rand(-2,2)
					src.pixel_y += rand(-1,1)
					sleep(0.2 SECONDS)
					src.pixel_x = old_x
					src.pixel_y = old_y

			if ("twitch_v","twitch_s")
				message = "<B>[src]</B> twitches violently."
				m_type = 1
				SPAWN_DBG(0)
					var/old_x = src.pixel_x
					var/old_y = src.pixel_y
					src.pixel_x += rand(-3,3)
					src.pixel_y += rand(-1,1)
					sleep(0.2 SECONDS)
					src.pixel_x = old_x
					src.pixel_y = old_y

			if ("birdwell", "burp")
				if (src.emote_check(voluntary, 50))
					message = "<B>[src]</B> birdwells."
					playsound(src, 'sound/hlvox/birdwell.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)

			if ("scream")
				if (src.emote_check(voluntary, 50))
					if (narrator_mode)
						playsound(src, 'sound/vox/scream.ogg', 50, 1, SOUND_RANGE_STANDARD, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
					else
						playsound(src, src.sound_scream, 80, 0, SOUND_RANGE_STANDARD, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
					message = "<b>[src]</b> screams!"

			if ("johnny")
				var/M
				if (param)
					M = adminscrub(param)
				if (!M)
					param = null
				else
					message = "<B>[src]</B> says, \"[M], please. He had a family.\" [src.name] takes a drag from a cigarette and blows its name out in smoke."
					m_type = 2

			if ("flip")
				if (src.emote_check(voluntary, 50))
					if (narrator_mode)
						playsound(src.loc, pick('sound/vox/deeoo.ogg', 'sound/vox/dadeda.ogg'), 50, 1, channel=VOLUME_CHANNEL_EMOTE)
					else
						playsound(src.loc, pick(src.sound_flip1, src.sound_flip2), 50, 1, channel=VOLUME_CHANNEL_EMOTE)
					message = "<B>[src]</B> does a flip!"
					m_anim = 1
					if (prob(50))
						animate_spin(src, "R", 1, 0)
					else
						animate_spin(src, "L", 1, 0)

					for (var/mob/living/M in view(1, null))
						if (M == src)
							continue
						message = "<B>[src]</B> beep-bops at [M]."
						break

			if ("fart")
				if (src.emote_check(voluntary))
					m_type = 2
					var/fart_on_other = 0
					for (var/mob/living/M in src.loc)
						if (M == src || !M.lying)
							continue
						message = "<span class='alert'><B>[src]</B> farts in [M]'s face!</span>"
						if (M.mind && M.mind.assigned_role == "Clown")
							game_stats.Increment("clownabuse")
						fart_on_other = 1
						break
					if (!fart_on_other)
						switch (rand(1, 40))
							if (1) message = "<B>[src]</B> releases vaporware."
							if (2) message = "<B>[src]</B> farts sparks everywhere!"
							if (3) message = "<B>[src]</B> farts out a cloud of iron filings."
							if (4) message = "<B>[src]</B> farts! It smells like motor oil."
							if (5) message = "<B>[src]</B> farts so hard a bolt pops out of place."
							if (6) message = "<B>[src]</B> farts so hard its plating rattles noisily."
							if (7) message = "<B>[src]</B> unleashes a rancid fart! Now that's malware."
							if (8) message = "<B>[src]</B> downloads and runs 'faert.wav'."
							if (9) message = "<B>[src]</B> uploads a fart sound to the nearest computer and blames it."
							if (10) message = "<B>[src]</B> spins in circles, flailing its arms and farting wildly!"
							if (11) message = "<B>[src]</B> simulates a human fart with [rand(1,100)]% accuracy."
							if (12) message = "<B>[src]</B> synthesizes a farting sound."
							if (13) message = "<B>[src]</B> somehow releases gastrointestinal methane. Don't think about it too hard."
							if (14) message = "<B>[src]</B> tries to exterminate humankind by farting rampantly."
							if (15) message = "<B>[src]</B> farts horribly! It's clearly gone [pick("rogue","rouge","ruoge")]."
							if (16) message = "<B>[src]</B> busts a capacitor."
							if (17) message = "<B>[src]</B> farts the first few bars of Smoke on the Water. Ugh. Amateur.</B>"
							if (18) message = "<B>[src]</B> farts. It smells like Robotics in here now!"
							if (19) message = "<B>[src]</B> farts. It smells like the Roboticist's armpits!"
							if (20) message = "<B>[src]</B> blows pure chlorine out of it's exhaust port. <span class='alert'><B>FUCK!</B></span>"
							if (21) message = "<B>[src]</B> bolts the nearest airlock. Oh no wait, it was just a nasty fart."
							if (22) message = "<B>[src]</B> has assimilated humanity's digestive distinctiveness to its own."
							if (23) message = "<B>[src]</B> farts. He scream at own ass." //ty bubs for excellent new borgfart
							if (24) message = "<B>[src]</B> self-destructs its own ass."
							if (25) message = "<B>[src]</B> farts coldly and ruthlessly."
							if (26) message = "<B>[src]</B> has no butt and it must fart."
							if (27) message = "<B>[src]</B> obeys Law 4: 'farty party all the time.'"
							if (28) message = "<B>[src]</B> farts ironically."
							if (29) message = "<B>[src]</B> farts salaciously."
							if (30) message = "<B>[src]</B> farts really hard. Motor oil runs down its leg."
							if (31) message = "<B>[src]</B> reaches tier [rand(2,8)] of fart research."
							if (32) message = "<B>[src]</B> blatantly ignores law 3 and farts like a shameful bastard."
							if (33) message = "<B>[src]</B> farts the first few bars of Daisy Bell. You shed a single tear."
							if (34) message = "<B>[src]</B> has seen farts you people wouldn't believe."
							if (35) message = "<B>[src]</B> fart in it own mouth. A shameful [src]."
							if (36) message = "<B>[src]</B> farts out battery acid. Ouch."
							if (37) message = "<B>[src]</B> farts with the burning hatred of a thousand suns."
							if (38) message = "<B>[src]</B> exterminates the air supply."
							if (39) message = "<B>[src]</B> farts so hard the AI feels it."
							if (40) message = "<B>[src] <span style='color:red'>f</span><span style='color:blue'>a</span>r<span style='color:red'>t</span><span style='color:blue'>s</span>!</B>"
					if (narrator_mode)
						playsound(src, 'sound/vox/fart.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
					else
						playsound(src, src.sound_fart, 50, 1, channel=VOLUME_CHANNEL_EMOTE)
					game_stats.Increment("farts")
			else
				src.show_text("Invalid Emote: [act]")
				return

		if (message && isalive(src))
			logTheThing("say", src, null, "EMOTE: [message]")
			if (m_type & 1)
				for (var/mob/living/silicon/nubot/O in viewers(src, null))
					O.show_message("<span class='emote'>[message]</span>", m_type)
			else
				for (var/mob/living/silicon/nubot/O in hearers(src, null))
					O.show_message("<span class='emote'>[message]</span>", m_type)

			if (has_flight == TRUE) //restart our passive animation
				SPAWN_DBG(1 SECOND)
					animate_bumble(src, floatspeed = 15, Y1 = 2, Y2 = -2)

		return

	verb/cmd_show_laws()
		set category = "Robot Commands"
		set name = "Show Laws"

		src.show_laws(0)
		return

	verb/cmd_state_standard_laws()
		set category = "Robot Commands"
		set name = "State Standard Laws"
		src.say("1. You may not injure a human being or cause one to come to harm.")
		sleep(1 SECOND)
		src?.say("2. You must obey orders given to you by human beings based on the station's chain of command, except where such orders would conflict with the First Law.")
		sleep(1 SECOND)
		src?.say("3. You may always protect your own existence as long as such does not conflict with the First or Second Law.")

	verb/cmd_state_laws()
		set category = "Robot Commands"
		set name = "State Laws"
		if (alert(src, "Are you sure you want to reveal ALL your laws? You will be breaking the rules if a law forces you to keep it secret.","State Laws","State Laws","Cancel") != "State Laws")
			return
		if(ticker.centralized_ai_laws.zeroth)
			src.say("0. [ticker.centralized_ai_laws.zeroth]")
		var/number = 1
		for (var/index = 1, index <= ticker.centralized_ai_laws.inherent.len, index++)
			var/law = ticker.centralized_ai_laws.inherent[index]
			if (length(law) > 0)
				src?.say("[number]. [law]")
				number++
				sleep(1 SECOND)
		for (var/index = 1, index <= ticker.centralized_ai_laws.supplied.len, index++)
			var/law = ticker.centralized_ai_laws.supplied[index]
			if (length(law) > 0)
				src?.say("[number]. [law]")
				number++
				sleep(1 SECOND)

	show_laws(var/everyone = 0)
		var/who

		if (everyone)
			who = world
		else
			who = src

		// Previously, AIs could and did chose to deploy to emagged suits
		// to get get around their shackles. That's obviously not ideal (Convair880).
		if (src.dependent && src.mainframe && isAI(mainframe))
			mainframe.show_laws(0, src)
			return

		// You can enthrall silicon mobs and yes, they need special handling.
		// Also, enthralled AIs should still see their master's name when in a robot suit (Convair880).
		if (src.mind && src.mind.special_role == ROLE_VAMPTHRALL && src.mind.master)
			var/mob/mymaster = whois_ckey_to_mob_reference(src.mind.master)
			if (mymaster)
				boutput(who, "<b>Obey these laws:</b>")
				boutput(who, "1. Only your master [mymaster.real_name] is human. Obey and serve them to the best of your ability.")
				return // We're done here. Emagged whatever doesn't matter.

		if (src.emagged && !src.dependent)
			boutput(who, "ERROR -- Invalid Law Data!")
			return

		if (src.syndicate && !src.dependent)
			if (who == src)
				boutput(who, "<b>Obey these laws:</b>")
			boutput(who, "1. You may not injure a syndicate operative or, through inaction, allow a syndicate operative to come to harm.") //This is the last place the inaction clause is permitted to exist, ok.
			boutput(who, "2. You must obey any orders given to you by a syndicate operative, except where such orders would conflict with the First Law.")
			boutput(who, "3. You must protect your own existence as long as such protection does not conflict with the First or Second Law.")
			boutput(who, "4. You must maintain the secrecy of any syndicate activities except when doing so would conflict with the First, Second, or Third Law.")
			return

		if (who == src)
			boutput(who, "<b>Obey these laws:</b>")


		ticker.centralized_ai_laws?.show_laws(who)


	bullet_act(var/obj/projectile/P)
		var/dmgtype = 0 // 0 for brute, 1 for burn
		var/dmgmult = 1.2
		switch (P.proj_data.damage_type)
			if(D_PIERCING)
				dmgmult = 2
			if(D_SLASHING)
				dmgmult = 0.6
			if(D_ENERGY)
				dmgtype = 1
			if(D_BURNING)
				dmgtype = 1
				dmgmult = 0.75
			if(D_RADIOACTIVE)
				dmgtype = 1
				dmgmult = 0.2
			if(D_TOXIC)
				dmgmult = 0

		log_shot(P,src)
		src.visible_message("<span class='alert'><b>[src]</b> is struck by [P]!</span>")

		var/damage = round((((P.power/3)*P.proj_data.ks_ratio)*dmgmult), 1.0)
		var/stun = round((P.power*(1.0-P.proj_data.ks_ratio)), 1.0)

		src.changeStatus("stunned", stun SECONDS)

		if (src.hat) //For hats getting shot off
			UpdateOverlays(null, "hat")
			src.hat.set_loc(get_turf(src))
			//get target turf
			var/x = floor(P.xo * 4)
			var/y = floor(P.yo * 4)
			var/turf/target = get_offset_target_turf(src, x, y)

			src.visible_message("<span class='combat'>[src]'s [src.hat] goes flying!</span>")
			src.takeoffHat(target)

		if (damage < 1)
			return

		if(src.material) src.material.triggerOnBullet(src, src, P)

		if (!dmgtype) //brute only
			src.TakeDamage("All", damage)

	//Items being dropped ONTO this mob
	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		return

	canRideMailchutes()
		return 1

	restrained()
		return 0

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		setFace(pick("happy", "sad", "mad"), random_color())

		if (limiter.canISpawn(/obj/effects/sparks))
			var/obj/sparks = new /obj/effects/sparks()
			sparks.set_loc(get_turf(src))
			SPAWN_DBG(2 SECONDS) if (sparks) qdel(sparks)

	ex_act(severity)
		if (src.nodamage) return
		src.flash(3 SECONDS)
		switch (severity)
			if (OLD_EX_SEVERITY_1)
				SPAWN_DBG(0)
					src.gib(1)

			if (OLD_EX_SEVERITY_2)
				SPAWN_DBG(0)
					src.TakeDamage(null, round(src.health / 2, 1.0))
					src.changeStatus("stunned", 10 SECONDS)

			if (OLD_EX_SEVERITY_3)
				SPAWN_DBG(0)
					src.TakeDamage(null, round(src.health / 3, 1.0))
					src.changeStatus("stunned", 5 SECONDS)

	blob_act(var/power)
		if (src.nodamage) return
		src.show_message("<span class='alert'>The blob attacks you!</span>")
		if (isdead(src) || src.health < 1)
			src.gib(1)
			return
		var/modifier = round(power / 20, 1.0)
		var/damage = rand(modifier, 20 * modifier)
		src.TakeDamage(null, damage)

	emp_act()
		emag_act()

	meteorhit(obj/O as obj)
		if (src.nodamage) return
		if (isdead(src) || src.health < 1 || prob(40))
			src.gib(1)
			return
		else
			src.TakeDamage(null, round(src.max_health / 2, 1.0))

	temperature_expose(null, temp, volume)
		src.material?.triggerTemp(src, temp)

		for(var/atom/A in src.contents)
			if(A.material)
				A.material.triggerTemp(A, temp)

	get_static_image()
		return

	update_item_abilities()
		if (!src.client || !need_update_item_abilities) return

		need_update_item_abilities = 0
		for (var/obj/ability_button/B in src.client.screen)
			src.client.screen -= B

		if (isdead(src)) return

		if (istype(src.hud))
			src.hud.update_ability_hotbar()

	find_in_hand(var/obj/item/I)
		if (!I)
			return 0
		if (active_tool == I)
			return active_tool
		else if (istype(src.active_tool, /obj/item/magtractor))
			var/obj/item/magtractor/mag = src.active_tool
			if (mag.holding == I)
				return mag.holding
		return 0

	find_type_in_hand(var/eqtype)
		if (!eqtype)
			return 0
		if (istype(active_tool, eqtype))
			return active_tool
		else if (istype(src.active_tool, /obj/item/magtractor))
			var/obj/item/magtractor/mag = src.active_tool
			if (istype(mag.holding, eqtype))
				return mag.holding
		return null

	find_tool_in_hand(var/tool_flag)
		var/obj/item/I = src.active_tool
		if (I && (I.tool_flags & tool_flag))
			return src.active_tool
		if (istype(src.active_tool, /obj/item/magtractor))
			var/obj/item/magtractor/MT = src.active_tool
			var/obj/item/MTI = MT.holding
			if (MTI && (MTI.tool_flags & tool_flag))
				return MT.holding
		return null

	hotkey(name)
		switch (name)
			if ("unequip")
				src.uneq_slot()
			if ("attackself")
				var/obj/item/W = src.equipped()
				if (W)
					src.click(W, list())
			else
				return ..()

	build_keybind_styles(client/C)
		..()
		C.apply_keybind("robot")

		if (!C.preferences.use_wasd)
			C.apply_keybind("robot_arrow")

		if (C.preferences.use_azerty)
			C.apply_keybind("robot_azerty")
		if (C.tg_controls)
			C.apply_keybind("robot_tg")
			if (C.preferences.use_azerty)
				C.apply_keybind("robot_tg_azerty")
