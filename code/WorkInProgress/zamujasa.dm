/obj/very_important_wire
	name = "very conspicuous cable"
	desc = "Some sort of cabling that runs under the floor. Looks pretty important."
	density = 0
	anchored = 1
	icon = 'icons/obj/machines/power_cond.dmi'
	icon_state = "1-10"
	layer = CABLE_LAYER
	color = "#037ffc"

	attackby(obj/item/W as obj, mob/user as mob)
		if (issnippingtool(W))
			logTheThing("station", user, null, "cut the don't-cut-this wire and got ghosted/disconnected as a result.")
			//boutput(user, "<span class='alert'>You snip the ca</span>")
			user.visible_message("[user] nearly snips the cable with \the [W], but suddenly freezes in place just before it cuts!", "<span class='alert'>You snip the ca</span>")
			var/client/C = user.client
			user.ghostize()
			del(C)
			return

		..()
		return



/obj/item/device/speechtotext
	name = "prototype flying chat device"
	desc = "This is a microphone that was a prototype of the floating chat that pali added. It doesn't work that great, but hey."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "mic"
	item_state = "mic"

	hear_talk(mob/M as mob, msg, real_name, lang_id)
		var/turf/T = get_turf(src)
		if (M in range(1, T))
			src.talk_into(M, msg, null, real_name, lang_id)

	talk_into(mob/M as mob, messages, param, real_name, lang_id)
		new /obj/maptext_junk/speech(M, msg = messages[1])


/obj/maptext_junk
	mouse_opacity = 0
	density = 0
	opacity = 0
	icon = null
	plane = PLANE_HUD - 1
	maptext = ""
	flags = TECHNICAL_ATOM


#ifdef DEBUG_LIGHTING_UPDATES
/obj/maptext_junk/RL_counter
	icon = null
	maptext = ""
	anchored = 2
	var/applies = 0
	var/updates = 0
	var/gen = 0
	var/wait = 0
	icon = 'icons/effects/white.dmi'

	proc/tick(var/apply = 0, var/update = 0, var/generation)
		if (update)
			updates++
		if (apply)
			applies++
		wait++
		src.gen = generation
		src.maptext = "<span class='c vm ps2p ol'><span style='color: #ffff00'>[updates]</span>\n<span style='color: #00ffff'>[applies]</span>\n<span class='pixel'>[src.gen]</span></span>"
		src.color = null;
		animate(src, color = "#ffffff", time = 15, flags = ANIMATION_END_NOW)
		animate(color = "#999999", time = 2)
#endif


/obj/maptext_junk/damage
	name = "damage popup"
	maptext_y = 16
	maptext_x = -32
	maptext_width = 96

	New(var/change = 0)
		..()
		if (abs(change) < 1)
			qdel(src)
			return

		var/hcol = (change > 0) ? "#88ff88" : "#ff6666"
		maptext = "<span class='ps2p c sh' style='color: [hcol];'>[change > 0 ? "+" : ""][round(change, 1)]</span>"

		if (change < 0)
			var/xofs = rand(32, 78) * (prob(50) ? 1 : -1)
			var/yofs = rand(60, 100)
			animate(src, maptext_y = yofs, time = 8, easing = EASE_OUT | QUAD_EASING, flags = ANIMATION_RELATIVE)
			animate(alpha = -255, maptext_y = yofs * -1, time = 8, easing = EASE_IN | QUAD_EASING, flags = ANIMATION_RELATIVE)
			animate(maptext_x = xofs * 1.5, time = 16, flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)
		else
			animate(src, maptext_y = 56, time = 8, easing = EASE_OUT | QUAD_EASING)
			animate(time = 8)
			animate(maptext_y = 52, alpha = 0, time = 4, easing = EASE_OUT | CUBIC_EASING)

		// ptoato said to just call del directly so blame them
		// pali: potato was wrong
		SPAWN_DBG(4 SECONDS)
			qdel(src)


/obj/maptext_junk/speech
	name = "spoken chat"
	maptext_x = -64
	maptext_y = 28
	maptext_width = 160
	maptext_height = 48
	alpha = 0
	var/bumped = 0

	New(mob/M as mob, msg, style = "")
		..()
		for (var/obj/maptext_junk/speech/O in M.vis_contents)
			if (!istype(O))
				continue
			O.bump_up()

		M.vis_contents += src

		maptext = "<span class='pixel c sh' style=\"[style]\">[msg]</span>"
		animate(src, alpha = 255, maptext_y = 34, time = 4)

		SPAWN_DBG(4 SECONDS)
			bump_up()


		SPAWN_DBG(7 SECONDS)
			del(src)

	proc/bump_up()
		if (bumped)
			return
		src.bumped = 1
		animate(src, alpha = 0, maptext_y = maptext_y + 8, time = 4)


/obj/ptl_mirror
#define NW_SE 0
#define SW_NE 1

	anchored = 1
	density = 1
	opacity = 0
	icon = 'icons/obj/unused/glass.dmi'
	icon_state = "sheet"

	var/facing = NW_SE
	var/list/affecting = list()

	attack_hand(mob/user as mob)
		boutput(user, "rotating mirror...")
		facing = 1 - facing
		for (var/obj/machinery/power/pt_laser/PTL in affecting)
			//
			boutput(user, "[PTL] would be notified")


	attackby(obj/item/W as obj, mob/user as mob)
		if (iswrenchingtool(W))
			boutput(user, "this would deconstruct it.")
			return

		..()
		return

#undef NW_SE
#undef SW_NE





/obj/invisible_teleporter
	name = "invisible teleporter side 1"
	desc = "Totally not a portal."
	event_handler_flags = USE_HASENTERED
	icon = 'icons/effects/letter_overlay.dmi'
	icon_state = "A"
	anchored = 1
	density = 0
	var/id = null
	var/which_end = 0
	invisibility = 0
	var/busy = 0

	New()
		..()
		if (!id)
			id = icon_state
		src.tag = "invisportal[id][which_end]"
		desc += " Tag: [tag]"
		/*
		src.maptext = "<span class='pixel sh'>[tag]</span>"
		src.maptext_width = 128
		*/

	HasEntered(AM as mob|obj)
		if (AM == src)
			// jesus christ don't teleport OURSELVES
			return
		Z_LOG_DEBUG("shit", "Checking things: event_handler_flags [event_handler_flags], [AM] entered")
		if (busy || istype(AM, /obj/overlay/tile_effect) || istype(AM, /mob/dead) || istype(AM, /mob/wraith) || istype(AM, /mob/living/intangible))
			Z_LOG_DEBUG("shit", "Decided not to teleport")
			return ..()

		Z_LOG_DEBUG("shit", "Doing teleport")
		do_the_teleport(AM)

	ex_act(severity)
		return

	meteorhit(obj/meteor)
		return

	proc/do_the_teleport(atom/movable/AM as mob|obj)
		Z_LOG_DEBUG("shit", "Teleporting [AM]")
		var/obj/invisible_teleporter/other_side = locate("invisportal[id][which_end ? "0" : "1"]")
		if (!istype(other_side))
			Z_LOG_DEBUG("shit", "Couldn't find another warp point (invisportal[id][which_end ? "0" : "1"]) ??????? ")
			return
		other_side.busy = 1
		Z_LOG_DEBUG("shit", "okie dokie warpy popry")
		AM.set_loc(get_turf(other_side))
		other_side.busy = 0

	destination
		name = "invisible teleporter side 2"
		which_end = 1
		icon_state = "A"


	receive_only
		name = "invisible teleporter (exit only)"
		icon_state = "A"
		which_end = 1
		color = "#FF0000"
		event_handler_flags = 0




/obj/afterlife_donations
	name = "afterlife thing"
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "voting_box"
	density = 1
	event_handler_flags = NO_MOUSEDROP_QOL
	flags = FPRINT
	anchored = 1
	desc = "Funds further renovations for the afterlife. You can put the fruits / vegetables / minerals / bombs you grew into this (click this with them or click-drag them onto it)."
	var/total_score = 0
	var/round_score = 0
	var/obj/maptext_junk/tracker = null
	var/working = 0

	New()
		..()
		total_score = world.load_intra_round_value("afterlife_donations")
		tracker = new /obj/maptext_junk()
		tracker.pixel_y = 40
		tracker.pixel_x = -48
		tracker.maptext_width = 128
		tracker.alpha = 120
		src.vis_contents += tracker
		update_totals()

	get_desc()
		return " It's saved a total of [floor(total_score)] points, with [floor(round_score)] points added today."

	proc/update_totals()
		tracker.maptext = "<span class='c vt ps2p sh'>TOTAL [add_lspace(floor(total_score), 7)]\nROUND [add_lspace(floor(round_score), 7)]</span>"


	attackby(obj/item/W as obj, mob/user as mob)
		var/score = get_item_value(W)
		if (score == -1)
			return ..()

		boutput(user, "<span class='notice'>[src] mulches up [W].</span>")
		user.u_equip(W)
		W.dropped()
		mulch_item(W, score)
		var/MT = start_scoring()
		update_score(MT, score)
		finish_scoring(MT)
		//give_points(W, score)
		return



	proc/get_item_value(obj/item/W as obj)
		var/base_score = 0

		if (istype(W, /obj/item/reagent_containers/food/snacks/plant))
			var/obj/item/reagent_containers/food/snacks/plant/I = W
			base_score = 2 + I.quality

		else if (istype(W, /obj/item/plant))
			var/obj/item/plant/I = W
			base_score = 2 + I.quality

		else if (istype(W, /obj/item/reagent_containers/food/snacks/mushroom))
			var/obj/item/reagent_containers/food/snacks/mushroom/I = W
			base_score = 2 + I.quality

		else if (istype(W, /obj/item/reagent_containers))
			var/obj/item/reagent_containers/I = W
			base_score = 2 + I.quality

		else if (istype(W, /obj/item/raw_material))
			// todo : itd be nice to use matsci but thats supposedly getting updated soon agani
			var/obj/item/raw_material/I = W
			base_score = (3 + (I.metal + I.conductor + I.dense + I.crystal + I.powersource) * 2.5) * I.quality
			base_score *= I.amount
		else
			return -1

		return max(0, base_score)


	proc/mulch_item(var/obj/I, score)
		playsound(src.loc, "sound/impact_sounds/Slimy_Hit_4.ogg", 50, 1)
		qdel( I )
		total_score += score
		round_score += score
		update_totals()

	proc/start_scoring()
		var/obj/maptext_junk/M = new /obj/maptext_junk()
		tracker.alpha = 255
		M.pixel_y = 20
		M.pixel_x = -16
		M.maptext_width = 64
		M.transform = matrix(2, 0, -16, 0, 2, 0)
		src.vis_contents += M
		working++
		return M

	proc/update_score(var/obj/maptext_junk/M, var/score)
		M.maptext = "<span class='ps2p c vm sh'>+[floor(score)]</span>"

	proc/finish_scoring(var/obj/maptext_junk/M)
		animate(M, time = 2)
		animate(transform = matrix(1, 0, 0, 0, 1, 0), time = 5)
		animate(pixel_y = 20 + 6, time = 5)
		animate(pixel_y = 20 + 12, alpha = 0, time = 5)
		SPAWN_DBG(4 SECONDS)
			working--
			if (working == 0)
				// if > 1 then the score is still changing so just wait a while...
				world.save_intra_round_value("afterlife_donations", total_score)
				animate(tracker, alpha = 160, time = 10)
			src.vis_contents -= M
			qdel(M)


	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!isliving(user))
			boutput(user, "<span class='alert'>Excuse me you are dead, get your gross dead hands off that!</span>")
			return
		if (get_dist(user,src) > 1)
			boutput(user, "<span class='alert'>You need to move closer to [src] to do that.</span>")
			return
		if (get_dist(O,src) > 1 || get_dist(O,user) > 1)
			boutput(user, "<span class='alert'>[O] is too far away to load into [src]!</span>")
			return

		var/score = 0
		if (get_item_value(O) != -1)
			var/MT = start_scoring()
			user.visible_message("<span class='notice'>[user] begins quickly stuffing things into [src]!</span>")
			var/staystill = user.loc

			for(var/obj/item/P in view(1,user))
				if (user.loc != staystill) break
				var/addscore = get_item_value(P)
				if (addscore == -1)
					continue
				score += addscore
				mulch_item(P, addscore)
				update_score(MT, score)
				sleep(0.1 SECONDS)

			boutput(user, "<span class='notice'>You finish stuffing things into [src]!</span>")
			finish_scoring(MT)
		else ..()

/obj/death_button/clean_gunsim
	name = "button that will clean the murderbox"
	desc = "push this to clean the murderbox and probably not get killed. takes a minute."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "cleanbot1"

	var/area/sim/gunsim/gunsim
	var/active = 0

	New()
		..()
		SPAWN_DBG(0.5 SECONDS)
			gunsim = locate() in world

	attack_hand(mob/user as mob)
		if (active)
			boutput(user, "It just did some cleaning give it a minute!!!")
			return

		active = 1
		alpha = 128
		icon_state = "cleanbot-c"
		user.visible_message("CLEANIN UP THE MURDERBOX STAND CLEAR")

		SPAWN_DBG(0)
			for (var/obj/item/I in gunsim)
				if(istype(I, /obj/item/device/radio/intercom)) //lets not delete the intercoms inside shall we?
					continue
				else
					qdel(I)

			for (var/atom/S in gunsim)
				if(istype(S, /obj/storage) || istype(S, /obj/artifact) || istype(S, /obj/critter) || istype(S, /obj/machinery) || istype(S, /obj/decal) || istype(S, /mob/living/carbon/human/tdummy))
					qdel(S)


/*
			for (var/obj/storage/S in gunsim)
				qdel(S)
			for (var/obj/artifact/A in gunsim)
				qdel(A)
			for (var/obj/critter/C in gunsim)
				qdel(C)
			for (var/obj/machinery/bot/B in gunsim)
				qdel(B)
			for (var/obj/decal/D in gunsim)
				qdel(D)
*/
		SPAWN_DBG(60 SECONDS)
			active = 0
			alpha = 255
			icon_state = "cleanbot1"


/obj/death_button/create_dummy
	name = "Button that creates a test dummy"
	desc = "click this to create a test dummy"
	icon = 'icons/mob/human.dmi'
	icon_state = "ghost"
	var/active = 0
	alpha = 255

	attack_hand(mob/user as mob)
		if (active)
			boutput(user, "did you already kill the dummy? either way wait a bit!")
			return

		active = 1
		alpha = 128
		boutput(user, "Spawning target dummy, stand by") //no need to be rude

		new /mob/living/carbon/human/tdummy(locate(src.x+1, src.y, src.z))
		//T.x = src.x + 1 // move it to the right


		SPAWN_DBG(10 SECONDS)
			active = 0
			alpha = 255

	ex_act(severity)
		return


/proc/fancy_pressure_bar(var/pressure, var/max_pressure, var/width = 300)

	var/pct = max_pressure && pressure / max_pressure
	var/bar_bg_color = "#000000"
	var/bar_color = "#00cc00"
	var/bar_width = clamp(pct, 0, 1)
	if (pct > 1.01)
		bar_width = clamp((pressure / (max_pressure * 10)), 0, 1)
		bar_bg_color = "#b00000"
		bar_color = "#ffff00"

	. = {"
		<div style="width: [width + 2]px; border: 1px solid #000000; height: 1.25em; background: black;">
			<div style="width: [width + 2]px; border: 1px solid #bbbbbb; height: 100%; background: [bar_bg_color]; position: relative;">
				<div style="position: absolute; top: 2px; bottom: 2px; left: 1px; right: [floor(100 - bar_width * 100)]%; background-color: [bar_color];"></div>
				<div style="position: absolute; top: -3px; margin-left: -2px; left: 0%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: -3px; margin-left: -2px; left: 10%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: -3px; margin-left: -2px; left: 20%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: -3px; margin-left: -2px; left: 30%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: -3px; margin-left: -2px; left: 40%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: -3px; margin-left: -2px; left: 50%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: -3px; margin-left: -2px; left: 60%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: -3px; margin-left: -2px; left: 70%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: -3px; margin-left: -2px; left: 80%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: -3px; margin-left: -2px; left: 90%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: -3px; margin-left: -3px; left: 100%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: 0.12em; left: 100%; width: 7em; text-align: right; margin-left: 1em; font-weight: bold;">[pressure] kPa</div>
			</div>
		</div>
	"}




// if haine can have sailor moon, then i'm doing this and you cant stop me
/obj/item/clow_key
	name = "\improper Clow key"
	desc = "RELEEEAAAAAAAAAASSSSEEEEEEEEEEEEEEEEEEEE!"
	icon = 'icons/obj/junk.dmi'
	icon_state = "clowkey"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "nothing"
	uses_multiple_icon_states = 1
	flags = FPRINT | TABLEPASS | ONBELT
	force = 0
	w_class = W_CLASS_TINY
	throwforce = 1
	throw_speed = 3
	throw_range = 8
	stamina_damage = 1
	stamina_cost = 1
	stamina_crit_chance = 0
	var/active = 0

	attack_self(mob/user as mob)
		src.active = !( src.active )
		if (src.active)
			src.name = "\improper Clow wand"
			src.desc = "Hoeeeh!? This is only useful if you're decked out."
			src.icon_state = "clowwand"
			src.item_state = "clowwand"
			src.w_class = W_CLASS_BULKY
		else
			src.name = initial(src.name)
			src.desc = initial(src.desc)
			src.icon_state = initial(src.icon_state)
			src.item_state = initial(src.item_state)
			src.w_class = initial(src.w_class)

		user.update_inhands()
		src.add_fingerprint(user)
		..()




/obj/decal/big_number
	name = "big number"
	mouse_opacity = 0
	density = 0
	anchored = 1
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "num0"
	layer = TURF_LAYER + 0.1 // it should basically be part of a turf
	plane = PLANE_FLOOR // hence, they should be on the same plane!

	ex_act(severity)
		return


/area/football
	name = "Space American Football Stadium"
	force_fullbright = 1
	icon_state = "purple"

/area/football/field
	name = "Space American Football Field"
	icon_state = "green"

	endzone
		icon_state = "yellow"
		var/team = null

		red
			name = "Red Team Endzone"
			icon_state = "red"
			team = "blue"
		blue
			name = "Blue Team Endzone"
			icon_state = "blue"
			team = "red"

		Entered(atom/movable/O)
			..()
			if (isobserver(O) || !istype(ticker?.mode, /datum/game_mode/football))
				return
			var/datum/game_mode/football/F = ticker.mode
			if (ismob(O))
				var/mob/jerk = O
				if (F.the_football in jerk.contents)
					F.score_a_goal(src.team)

			else if (O == F.the_football)
				F.score_a_goal(src.team, 1)

			return



/area/football/staging
	name = "Football Locker Rooms"
	sanctuary = 1
	icon_state = "death"



/obj/landmark/football
	name = "join"
	icon = 'icons/map-editing/mapeditor.dmi'
	icon_state = "landmark"
	deleted_on_start = TRUE
	add_to_landmarks = FALSE

	New()
		football_spawns[src.name] += src.loc
		..()

	blue
		name = "blue"
		color = "#8888ff"
		field
			name = "bluefield"
			color = "#0000ff"
	red
		name = "red"
		color = "#ff8888"
		field
			name = "redfield"
			color = "#ff0000"

	football
		name = "football"
		color = "#00ff00"


/*
	Entered(atom/movable/O)
		var/dest = null
		..()
		if (isobserver(O))
			return
		if (ismob(O))
			var/mob/jerk = O
			dest = pick(get_area_turfs(current_battle_spawn,1))
			if(!dest)
				dest= pick(get_area_turfs(/area/station/maintenance/,1))
				boutput(jerk, "You somehow land in maintenance! Weird!")
			jerk.set_loc(dest)
			jerk.nodamage = 0
			jerk.removeOverlayComposition(/datum/overlayComposition/shuttle_warp)
			jerk.removeOverlayComposition(/datum/overlayComposition/shuttle_warp/ew)
		else if (isobj(O) && !istype(O, /obj/overlay/tile_effect))
			qdel(O)
		return
*/



/obj/machinery/fix_this_shit
	name = "\proper imcoder"
	desc = "They're not bugs, okay? They're <em>features</em>."
	icon = 'icons/mob/inhand/hand_general.dmi'
	icon_state = "DONGS"
	plane = PLANE_HUD
	anchored = 1
	density = 1

	var/last_count = -1


	New()
		..()
		src.process()

	disposing()
		UnsubscribeProcess()
		..()

	process()
		if (src.last_count != runtime_count)
			src.last_count = runtime_count
			animate_storage_rustle(src)
			playsound(src, "sound/mksounds/gotitem.ogg",33, 0)
			src.maptext = "<span class='ps2p sh vb c'><span style='font-size: 12px;'>[runtime_count]</span>\nruntimes</span>"
			src.maptext_x = -100
			src.maptext_width = 232
			src.maptext_y = 34

	ex_act()
		return


/obj/machinery/fix_this_shit/delete_this_shit
	name = "\proper qdel()"
	desc = "please stop looking at my dangling references"
	icon = 'icons/effects/effects.dmi'
	icon_state = "onfire"

	process()
		if (src.last_count != harddel_count)
			src.last_count = harddel_count
			animate_storage_rustle(src)
			playsound(src, "sound/mksounds/gotitem.ogg",33, 0)
			src.maptext = "<span class='ps2p sh vb c'><span style='font-size: 12px;'>[harddel_count]</span>\nharddels</span>"
			src.maptext_x = -100
			src.maptext_width = 232
			src.maptext_y = 34


/obj/machinery/maptext_monitor
	name = "maptext monitor doodad"
	desc = "This thing reports the value something else has, automatically! Wow!"
	icon = null
	anchored = 2
	density = 0
	plane = PLANE_HUD - 1

	var/datum/monitored = null
	var/monitored_var = null
	var/monitored_list = null
	var/monitored_ref = null
	var/last_value = null
	var/display_mode = null
	var/maptext_prefix = "<span class='c pixel sh'>Value:\n<span class='vga'>"
	var/maptext_suffix = "</span></span>"
	var/ding_on_change = 0
	var/ding_sound = "sound/machines/ping.ogg"
	var/update_delay = 0
	var/require_var_or_list = 1

	New()
		..()
		src.maptext_x = -100
		src.maptext_width = 232
		src.maptext_height = 64
		src.process()

	disposing()
		UnsubscribeProcess()
		..()

	process()
		src.update_monitor()
		if (src.update_delay)
			UnsubscribeProcess()
			SPAWN_DBG(0)
				while (src.update_delay)
					src.update_monitor()
					sleep(update_delay)

				SubscribeToProcess()

	/**
	* Checks if a monitored thing still exists
	*
	* Returns 0 if monitoring should stop,
	* 1 if monitoring is okay
	*/
	proc/validate_monitored()
		if (src.monitored_ref)
			var/datum/thing = locate(src.monitored_ref)
			if (thing)
				src.monitored = thing
			else
				// Try again with [] enclosing it. who knows. maybe it will work
				thing = locate("\[[src.monitored_ref]]")
				if (thing)
					src.monitored = thing

			src.monitored_ref = null

		if (monitored)
			if (monitored.pooled || monitored.qdeled)
				// The thing we were watching was deleted/removed! Welp.
				monitored = null
				return 0

			if (src.require_var_or_list && !src.monitored_list && !src.monitored_var)
				return 0
			return 1

		return 0

	/**
	* Updates the maptext monitor
	*/
	proc/update_monitor()
		if (!src.validate_monitored())
			return

		try
			var/current_value = src.get_value()

			if (current_value != last_value)
				src.maptext = "[maptext_prefix][format_value(current_value)][maptext_suffix]"
				src.last_value = current_value
				if (src.ding_on_change)
					playsound(src, src.ding_sound, 33, 0)
		catch(var/exception/e)
			src.maptext = "<span class='c pixel sh'>[src.monitored]\n(Err: [e])</span>"


	proc/get_value()
		if (src.monitored_list && !src.monitored_var)
			var/list/monlist = monitored.vars[src.monitored_list]
			. = length(monlist)
		else if (src.monitored_list)
			. = monitored.vars[src.monitored_list][src.monitored_var]
		else
			. = monitored.vars[monitored_var]


	proc/format_value(var/val)
		switch (src.display_mode)
			if ("power")
				return engineering_notation(val)
			if ("percent")
				return (val * 100)
			if ("temperature")
				return "[val - T0C]&deg;C"
			if ("round")
				return floor(val)

			if ("time")
				val /= 10
				var/sign = ""
				if (val < 0)
					val *= -1
					sign = "-"
				// @TODO: formatting times like this surely has to be a proc somewhere already, right
				switch (val)
					if (3600 to INFINITY)
						return "[sign][floor(val / 3600)]:[add_zero(val / 60 % 60, 2)]:[add_zero(val % 60, 2)]"
					if (0 to 3600)
						return "[sign][floor(val / 60 % 60)]:[add_zero(val % 60, 2)]"
			if ("fulltime")
				val /= 10
				var/sign = ""
				if (val < 0)
					val *= -1
					sign = "-"
				return "[sign][floor(val / 3600)]:[add_zero(val / 60 % 60, 2)]:[add_zero(val % 60, 2)]"

			if ("time2")
				// some things use centiseconds. some things dont. fart!
				var/sign = ""
				if (val < 0)
					val *= -1
					sign = "-"
				// @TODO: formatting times like this surely has to be a proc somewhere already, right
				switch (val)
					if (3600 to INFINITY)
						return "[sign][floor(val / 3600)]:[add_zero(val / 60 % 60, 2)]:[add_zero(val % 60, 2)]"
					if (0 to 3600)
						return "[sign][floor(val / 60 % 60)]:[add_zero(val % 60, 2)]"
			if ("fulltime2")
				var/sign = ""
				if (val < 0)
					val *= -1
					sign = "-"
				return "[sign][floor(val / 3600)]:[add_zero(val / 60 % 60, 2)]:[add_zero(val % 60, 2)]"

			if ("timer")
				val /= 10
				return "[floor(val)].[val * 10 % 10]"

			if ("timer2")
				return "[floor(val / 10)].[val % 10]"

		return val


	ex_act()
		return

	proc_monitor
		require_var_or_list = 0
		var/monitored_proc = null
		var/datum/effective_callee = null
		var/list/monitored_args = list()

		validate_monitored()
			// Do we have a working ref, at least?
			if (!..())
				// If not, get out
				return 0
			if (!src.monitored_proc)
				// no proc to check.
				return 0
			if (src.monitored_var && !istype(src.monitored[monitored_var], /datum))
				// If we're calling a proc on a var it better be something we can call a proc on
				return 0

			// So what ARE we calling this proc on then?
			src.effective_callee = (src.monitored_var ? src.monitored[src.monitored_var] : src.monitored)

			if (!hascall(src.effective_callee, monitored_proc))
				// does it have this proc?
				return 0

			// If we've gotten here then we can probably rest assured that
			// we can at least call whatever it is. Baby steps.
			return 1

		get_value()
			// validate_monitored should handle most of the checks for us
			// so we can probably just call it
			if (!src.effective_callee)
				// no! how did you even get here. jesus
				return

			return call(src.effective_callee, src.monitored_proc)(src.monitored_args)


		emergency_shuttle
			// remember those radio-controlled displays? i miss those.
			// we should bring those back.
			maptext_prefix = "<span class='c pixel sh'>Emergency Shuttle\n<span class='vga'>"
			display_mode = "time2"
			update_delay = 1 SECOND

			New()
				src.monitored = emergency_shuttle
				src.monitored_proc = "timeleft"
				..()

			format_value(var/val)
				// lord have mercy for this one.
				// get_value will return the seconds, which is passed here.
				// but we want to see the direction, not just the timer.
				// so we override this and call the parent to format the time properly
				switch (emergency_shuttle.location)
					if (SHUTTLE_LOC_CENTCOM, SHUTTLE_LOC_RETURNED, SHUTTLE_LOC_TRANSIT)
						if (!emergency_shuttle.online)
							return "Idle"
						return "ETA [..(val)]"

					if (SHUTTLE_LOC_STATION)
						return "Departing in [..(val)]"



	location
		require_var_or_list = 0
		maptext_prefix = "<span class='c pixel sh'><span class='xfont'>"
		maptext_suffix = "</span>"

		get_value()
			var/turf/where = get_turf(monitored)
			if (!where)
				. = "Unknown</span>\n(?, ?, ?)"
			else
				. = "[where.loc]</span>\n([where.x], [where.y], [where.z])"


		gps
			// Automated GPS! Wow!
			appearance_flags = TILE_BOUND | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART | PIXEL_SCALE
			update_delay = 1

			New()
				..()
				src.pixel_y += 34

				var/atom/movable/home = src.loc
				// Put it inside something to make it constantly show its location.
				if (istype(home))
					home.vis_contents += src
				else
					// if we are not home then we are gone, bye
					qdel(src)
					return
				src.monitored = src.loc
				set_loc(null)


	stats
		monitored_list = "stats"
		ding_on_change = 1

		New()
			src.monitored = game_stats
			..()

		farts
			monitored_var = "farts"
			maptext_prefix = "<span class='c pixel sh'>Farts:\n<span class='vga'>"
			update_delay = 1 SECOND

		deaths
			monitored_var = "deaths"
			maptext_prefix = "<span class='c pixel sh'>Deaths:\n<span class='vga'>"
			ding_sound = "sound/misc/lose.ogg"

			players
				monitored_var = "playerdeaths"
				maptext_prefix = "<span class='c pixel sh'>Deaths:\n<span class='vga'>"
				ding_sound = "sound/misc/lose.ogg"

		safety
			monitored_var = "workplacesafety"
			maptext_prefix = "<span class='c pixel sh'>Health and Safety Violations:\n<span class='vga'>"

		adminhelps
			monitored_var = "adminhelps"
			maptext_prefix = "<span class='c pixel sh'>Adminhelps:\n<span class='vga'>"
			ding_sound = "sound/voice/screams/mascream6.ogg"

		mentorhelps
			monitored_var = "mentorhelps"
			maptext_prefix = "<span class='c pixel sh'>Mentorhelps:\n<span class='vga'>"
			ding_sound = "sound/voice/animal/mouse_squeak.ogg"

		prayers
			monitored_var = "prayers"
			maptext_prefix = "<span class='c pixel sh'>Prayers:\n<span class='vga'>"
			ding_sound = "sound/voice/heavenly.ogg"

		violence
			monitored_var = "violence"
			maptext_prefix = "<span class='c pixel sh'>Acts of violence:\n<span class='vga'>"
			update_delay = 1 SECOND

		clones
			monitored_var = "clones"
			maptext_prefix = "<span class='c pixel sh'>Clones:\n<span class='vga'>"

	budget
		New()
			src.monitored = wagesystem
			..()

		display_mode = "round"
		monitored_var = "station_budget"
		maptext_prefix = "<span class='c pixel sh'>Station Budget:\n<span class='vga'>$"
		ding_sound = "sound/misc/cashregister.ogg"

		station
			// the default, but explicit...
		shipping
			monitored_var = "shipping_budget"
			maptext_prefix = "<span class='c pixel sh'>Shipping Budget:\n<span class='vga'>$"
		research
			monitored_var = "research_budget"
			maptext_prefix = "<span class='c pixel sh'>Research Budget:\n<span class='vga'>$"


	clients
		maptext_prefix = "<span class='c pixel sh'>Players:\n<span class='vga'>"
		validate_monitored()
			return 1
		get_value()
			. = total_clients()

	players
		maptext_prefix = "<span class='c pixel sh'>Players:\n<span class='vga'>"
		var/what_group = "total"
		validate_monitored()
			return 1
		get_value()
			. = get_crew_stats()[what_group]

		alive
			maptext_prefix = "<span class='c pixel sh'>Living players:\n<span class='vga'>"
			what_group = "alive"
		dead
			maptext_prefix = "<span class='c pixel sh'>Dead players:\n<span class='vga'>"
			what_group = "dead"
		observers
			maptext_prefix = "<span class='c pixel sh'>Observers:\n<span class='vga'>"
			what_group = "observer"



		// shamefully stolen from get_dead_crew_percentage()
		proc/get_crew_stats()
			var/list/results = list()
			results["total"] = 0
			results["alive"] = 0
			results["dead"] = 0
			results["observer"] = 0

			for(var/client/C)
				var/mob/M = C.mob
				if(!M || isnewplayer(M)) continue
				if (isdead(M) && !isliving(M))
					if (M.mind?.joined_observer)
						results["observer"]++
					else
						results["dead"]++
				else
					results["alive"]++
				results["total"]++

			return results


	load
		maptext_prefix = "<span class='c pixel sh'>Server Load:\n<span class='vga'>"
		update_delay = 1 SECOND

		validate_monitored()
			return 1
		get_value()
			var/lagc = "#ffffff"
			switch (world.tick_lag)
				if (0 to 0.4)
					lagc = "#00ff00"
				if (0.4 to 0.6)
					lagc = "#ffff00"
				if (0.6 to 0.8)
					lagc = "#ff8800"
				if (0.8 to INFINITY)
					lagc = "#ff0000; -dm-text-outline: 1px #000000 solid"

			. = "<span style='color: [lagc];'>[floor(world.cpu)]% @ [world.tick_lag / 10]s</span>"


/obj/overlay/zamujasa/football_wave_timer
	name = "football wave countdown"

	New()
		..()
		src.maptext_x = -100
		src.maptext_height = 64
		src.maptext_width = 232
		src.plane = 100
		src.anchored = 2
		src.mouse_opacity = 1

	proc/update_timer(var/num)
		if (num == -1)
			src.maptext = ""
		else
			src.maptext = {"<span class='c pixel sh'>Next spawn wave in\n<span class='vga'>[floor(num)]</span> seconds</span>"}



/obj/overlay/zamujasa/help_text
	name = "new player tutorial maptext"

	New()
		..()
		src.maptext_x = -100
		src.maptext_height = 64
		src.maptext_width = 232
		src.plane = 100
		src.anchored = 2
		src.mouse_opacity = 1
		src.maptext = {"<div class='c pixel sh' style="background: #00000080;"><strong>-- Welcome to Coolstation! --</strong>
New? <a href="https://mini.xkeeper.net/ss13/tutorial/" style="color: #8888ff; font-weight: bold;" clss="ol">Click here for a tutorial!</a>
Ask mentors for help with <strong>F3</strong>
Contact admins with <strong>F1</strong>
Read the rules, don't grief, and have fun!</div>"}


/obj/overlay/zamujasa/round_start_countdown
	var/maptext_area = "status"

	New()
		..()
		if (length(landmarks[LANDMARK_LOBBY_STATUS]))
			src.set_loc(landmarks[LANDMARK_LOBBY_STATUS][1])
		src.layer = HUD_LAYER

		src.maptext_width = 320
		src.maptext_x = -(320 / 2) + 16
		src.maptext_height = 48
		src.plane = 100
		src.set_text("")

	disposing()
		lobby_titlecard.set_maptext(maptext_area, "")
		..()

	proc/set_text(text)
		src.maptext = text
		lobby_titlecard.set_maptext(maptext_area, text)

	proc/update_status(message)
		if (message)
			src.set_text("<span class='c ol vga vt'>Setting up game...\n<span style='color: #aaaaaa;'>[message]</span></span>")
		else
			src.set_text("")

	timer
		maptext_area = "timer"

		New()
			..()
			if (length(landmarks[LANDMARK_LOBBY_TIMER]))
				src.set_loc(landmarks[LANDMARK_LOBBY_TIMER][1])

			src.maptext_height = 96

		proc/update_time(var/time)
			if (time >= 0)
				var/timeLeftColor
				switch (time)
					if (90 to INFINITY)
						timeLeftColor = "#33dd33"
					if (60 to 68)
						timeLeftColor = "#ffff00"
					if(69)
						timeLeftColor = "#ff55ff"
					if (70 to 90)
						timeLeftColor = "#ffff00"
					if (30 to 60)
						timeLeftColor = "#ffb400"
					if (0 to 30)
						timeLeftColor = "#ff6666"
				src.set_text("<span class='c ol vga vt'>Round begins in<br><span style='color: [timeLeftColor]; font-size: 3em;'>[time]</span></span>")
			else
				src.set_text("<span class='c ol vga vt'>Round begins<br><span style='color: #aaaaaa; font-size: 3em;'>soon</span></span>")

	encourage
		maptext_area = "leftside"

		New()
			..()
			if (length(landmarks[LANDMARK_LOBBY_LEFTSIDE]))
				src.set_loc(landmarks[LANDMARK_LOBBY_LEFTSIDE][1])

			// This is gross. I'm sorry.
			var/list/servers = list()
			servers["main1"] = "1 Classic: Heisenbee"
			servers["main2"] = "2 Classic: Bombini"
			servers["main3"] = "3 Roleplay: Morty"
			servers["main4"] = "4 Roleplay: Sylvester"

			var/serverList = ""
			for (var/serverId in servers)
				if (serverId == config.server_id)
					continue
				serverList += {"\n<a style='color: #88f;' href='byond://winset?command=Change-Server "[serverId]'>Goonstation [servers[serverId]]</a>"}

			src.maptext_x = 0
			src.maptext_width = 600
			src.maptext_height = 400
			src.set_text({"<span class='ol vga'>
Welcome to <a style='color: #88f;' href="https://wiki.coolstation.space/">Coolstation</a>!
New? <a style='color: #88f;' href="https://mini.xkeeper.net/ss13/tutorial/">Check the tutorial</a>!
Have questions? Ask mentors with \[F3]!
Need an admin? Message us with \[F1].

Other Coolstation servers: Not Yet!!!</span>"})




/obj/overlay/inventory_counter
	name = "inventory amount counter"
	invisibility = 101
	plane = PLANE_HUD
	layer = HUD_LAYER_3
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | PIXEL_SCALE | KEEP_APART
	var/static/matrix/infinity_matrix = matrix().Turn(90).Translate(18, 1)

	New()
		..()
		maptext_width = 64
		maptext_x = -34
		maptext_y = 1
		mouse_opacity = 0
		maptext = ""

	proc/update_text(var/text)
		maptext = {"<span class="vb r pixel sh">[text]</span>"}
		if(src.transform) src.transform = null

	proc/update_number(var/number)
		if(number == -1)
			maptext = {"<span class="vb r pixel sh" style="font-size:1.5em;">8</span>"} // pixel font has more symmetric 8, ok?
			src.transform = infinity_matrix
			return
		maptext = {"<span class="vb r xfont sh"[number == 0 ? " style='color: #ff6666;'" : number == -1 ? " style='-ms-transform: rotate(-90deg);'" : ""]>[number == -1 ? "8" : number >= 100000 ? "[floor(number / 1000)]K" : floor(number)]</span>"}
		if(src.transform) src.transform = null

	proc/update_percent(var/current, var/maximum)
		if (!maximum)
			// no dividing by zero
			src.update_number(current)
			return
		maptext = {"<span class="vb r xfont sh"[current == 0 ? " style='color: #ff6666;'" : ""]>[floor(current / maximum * 100)]%</span>"}
		if(src.transform) src.transform = null

	proc/hide_count()
		invisibility = 101

	proc/show_count()
		invisibility = 0
/*
	pooled()
		src.maptext = ""
		src.invisibility = 101
		..()
*/



/obj/item/rcd/construction/safe/admin_crimes
	// do not put this anywhere anyone can get it. it is for crime.
	name = "ultra hyper super rapid construction device 2 turbo: championship edition hd remix now with NEW funky mode"
	desc = "Also known as the ultimate in grief technology, this is capable of rapidly (de)constructing walls, flooring, windows, and doors. This admin crime edition features no cooldowns and extremely reduced matter costs. Does not, in fact, have a funky mode."

	matter = 999999
	max_matter = 999999

	// lol
	matter_create_floor = 1
	time_create_floor = 0

	matter_create_wall = 1
	time_create_wall = 0

	matter_reinforce_wall = 1
	time_reinforce_wall = 0

	matter_create_wall_girder = 1
	time_create_wall_girder = 0

	matter_create_door = 1
	time_create_door = 0

	matter_create_window = 1
	time_create_window = 0

	matter_create_light_fixture = 1
	time_create_light_fixture = 0

	matter_remove_door = 1
	time_remove_door = 0

	matter_remove_floor = 1
	time_remove_floor = 0

	matter_remove_lattice = 1
	time_remove_lattice = 0

	matter_remove_wall = 1
	time_remove_wall = 0

	matter_unreinforce_wall = 1
	time_unreinforce_wall = 0

	matter_remove_girder = 1
	time_remove_girder = 0

	matter_remove_window = 1
	time_remove_window = 0

	matter_remove_light_fixture = 1
	time_remove_light_fixture = 0





/mob/living/critter/small_animal/bee/zombee/zambee
	name = "zambee"
	real_name = "zambee"
	desc = "Genetically engineered for passiveness and bred for badminning, the greater domestic zambee is increasingly unpopular among grayshirts and griefers."
	limb_path = /datum/limb/small_critter/bee/strong
	add_abilities = list(/datum/targetable/critter/bite/bee,
						 /datum/targetable/critter/bee_sting/zambee,
						 /datum/targetable/critter/bee_swallow,
						 /datum/targetable/critter/bee_teleport)

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears(src)
		equipment += new /datum/equipmentHolder/head/bee(src)


/datum/targetable/critter/bee_sting/zambee
	venom1 = "saline"
	amt1 = 15
	venom2 = "omnizine"
	amt2 = 5




// i am not sorry for this
/obj/machinery/shower/cowbrush
	name = "\improper PLEASEDMOO cattle cleaner"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "cowbrush"
	desc = "A huge rotary brush attached to a wall. Supposedly, cows love it."

	attack_hand(mob/user as mob)
		..()
		src.icon_state = "cowbrush[src.on ? "_on" : ""]"



// modified from admin_spacebux_store by mylie
/obj/configurable_credit_store
	name = "configurable credit store setup object"
	desc = "An admin can click on this to set stuff up."
	density = 0
	anchored = 1
	icon = 'icons/mob/inhand/hand_general.dmi'
	icon_state = "DONGS"
	layer = EFFECTS_LAYER_4
	var/tmp/set_up = FALSE
	var/tmp/copy_mode = FALSE
	var/tmp/thing_name = null
	var/tmp/atom/thing_to_copy = null
	var/tmp/number_purchased = 0
	var/tmp/obj/maptext_junk/price_text = null
	var/tmp/obj/maptext_junk/quantity_text = null
	var/tmp/list/purchaser_ckeys = list()
	var/type_to_spawn = null
	var/delete_at_zero = TRUE
	var/float_pixels = 0
	var/price = 0
	var/limit_per_player = 0
	var/limit_total = 0

	get_desc()
		if (set_up)
			. += "<br>Looks like it costs $[src.price][src.limit_per_player ? ", a person can buy up to [src.limit_per_player]," : null] and there are [src.limit_total - src.number_purchased] left."

	attack_hand(mob/user)
		if (!set_up)
			src.try_setup(user)
		else
			// it has been set up so we can do stuff here
			src.try_purchase(user)

		return

	attackby(obj/item/I, mob/user)
		if (!set_up)
			src.try_setup(user)
		else if(istype(I, /obj/item/spacecash))
			src.try_purchase(user)
		return

	proc/try_setup(mob/user)
		if (!isadmin(user))
			boutput(user, SPAN_ALERT("You're no admin! Please wait for one to configure this!"))
			return

		var/copyOrType = alert(user, "Sell copies of a target, or new instances of a type?", "Whatcha sellin'?", "Copies", "Type", "Cancel")
		if (copyOrType == "Copies")
			// copy
			alert(user, "Click on the thing you want to sell copies of.")
			var/atom/thing = pick_ref(user)
			if(!(isobj(thing) || ismob(thing)))
				boutput(user, SPAN_ALERT("It has to be an obj or mob, sorry!"))
				return

			copy_mode = TRUE
			src.thing_to_copy = thing
			src.appearance = thing.appearance
			src.thing_name = thing.name

		else if (copyOrType == "Type")

			alert(user, "Click on something for the store to copy the appearance of (the actual item you're selling comes after this; you might have to varedit the store later)")
			var/atom/thing = pick_ref(user)
			if(!(isobj(thing) || ismob(thing)))
				boutput(user, SPAN_ALERT("It has to be an obj or mob, sorry!"))
				return

			// copy the appearance
			src.appearance = thing.appearance
			src.thing_name = thing.name

			var/objpath = get_one_match(input(user, "Type in (part of) a path to spawn:", "Type path", "[thing.type]"), /atom)
			copy_mode = FALSE
			src.type_to_spawn = objpath

		else
			// cancel
			return

		src.price = max(0, input(user, "How much does one cost?", "Credit Price", 500) as num)
		src.limit_total = max(0, input(user, "How many can be taken? (0=infinite)", "Quantity", 0) as num)
		src.limit_per_player = max(0, input(user, "How many can one player take? (0=infinite)", "Quantity", 0) as num)

		src.name = "[price > 0 ? "credit shop" : "dispenser"] - [src.thing_name]"
		src.desc = "A little shop where you can grab \a [src.thing_name]. Wow!"

		src.price_text = new()
		src.price_text.set_loc(src)
		src.price_text.maptext_width = 132
		src.price_text.maptext_x = -50
		src.price_text.maptext_y = -8
		src.price_text.maptext = "<span class='c vb sh xfont'><font color=green>[price > 0 ? "$[price]" : "FREE"]</font></span>"
		src.vis_contents += src.price_text
		src.price_text.appearance_flags = TILE_BOUND | RESET_COLOR | RESET_ALPHA | KEEP_APART | PIXEL_SCALE

		if (src.limit_total && src.limit_total != 1)
			src.quantity_text = new()
			src.quantity_text.set_loc(src)
			src.vis_contents += src.quantity_text
			src.quantity_text.appearance_flags = TILE_BOUND | RESET_COLOR | RESET_ALPHA | KEEP_APART | PIXEL_SCALE
			src.update_quantity()

		src.set_up = TRUE

		animate(src, pixel_y = 0 + src.float_pixels,  time = 2 SECONDS, loop = -1, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
		animate(pixel_y = 0, time = 2 SECONDS, loop = -1, easing = SINE_EASING)

	proc/try_purchase(mob/user)

		// Check if this can actually be bought
		// This also outputs the message to (user) as to why they can't
		if (!src.can_this_person_buy_it(user))
			return FALSE

		// Are we actually buying this?
		if (src.price)

			// Do we really wanna buy it?
			if (alert(user, "Purchase \a [src.thing_name] for [src.price] credits?", "Buy it?", "Yes", "No") != "Yes")
				// If no, abort
				return

			// Check if this can actually be bought, again
			// This is here because of a race condition when none are left:
			// Player 1   click -> prompt -------------------------> buy (x-1)
			// Player 2               click -> prompt ---> buy (x0)
			if (!src.can_this_person_buy_it(user))
				return FALSE

		if(src.price)
			var/list/obj/item/spacecash/credits = list()
			for(var/obj/item/spacecash/credit in user.contents) // intentionally does not grab cash from backpacks, belts, etc. DOES grab cash from your guts. its funny.
				credits += credit
			var/left_to_pay = src.price
			while(left_to_pay && length(credits))
				var/obj/item/spacecash/credit = credits[1]
				if(credit.amount >= left_to_pay)
					credit.amount -= left_to_pay
					credit.update_stack_appearance()
					left_to_pay = 0
				else
					left_to_pay -= credit.amount
					credit.amount = 0
				if(!credit.amount)
					qdel(credit)
					credits -= credit
			if(left_to_pay) // idk if it CAN happen but im afraid it COULD happen due to really fast races - mylie
				boutput(user, SPAN_ALERT("Something goes fucky with the purchase, so you get your money back."))
				var/obj/item/spacecash/cashback = new()
				cashback.setup(get_turf(user), left_to_pay)
				user.put_in_hand_or_drop(cashback)
				return FALSE

		if (!src.purchaser_ckeys[user.client.ckey])
			src.purchaser_ckeys[user.client.ckey] = 0

		src.number_purchased++
		src.purchaser_ckeys[user.client.ckey]++
		src.update_quantity()
		playsound(src, 'sound/misc/cashregister.ogg', 33, FALSE)

		var/atom/new_instance = null
		var/turf/T = get_turf(src)
		if (src.copy_mode && src.thing_to_copy)
			new_instance = semi_deep_copy(src.thing_to_copy, T)
		else
			new_instance = new src.type_to_spawn(T)

		// Try to put it in their hand if it's an item
		if (istype(new_instance, /obj/item))
			user.put_in_hand_or_drop(new_instance)

		if(src.delete_at_zero && (src.number_purchased >= src.limit_total))
			qdel(src)
			return

	// TRUE: yes you can buy it  FALSE: no
	proc/can_this_person_buy_it(mob/user)
		// Do we have any left to sell?
		if (limit_total && number_purchased >= limit_total)
			boutput(user, SPAN_ALERT("There's no more left to buy..."))
			return FALSE

		// Are we limiting how many people can buy?
		if (limit_per_player && (src.purchaser_ckeys[user.client.ckey] && src.purchaser_ckeys[user.client.ckey] >= limit_per_player))
			boutput(user, SPAN_ALERT("You've reached the limit that you can buy."))
			return FALSE

		if(src.price)
			var/total_credits = 0
			for(var/obj/item/spacecash/credit in user.contents) // intentionally does not grab cash from backpacks, belts, etc. DOES grab cash from your guts. its funny.
				total_credits += credit.amount
			if(total_credits < src.price)
				boutput(user, SPAN_ALERT("You're gonna need some more credits for that."))
				return FALSE
		return TRUE

	proc/update_quantity()
		if (!src.quantity_text) return
		src.quantity_text.maptext = "<span class='r sh pixel' style='font-size: 5px;[(limit_total - number_purchased) == 0 ? " color: red;" : ""]'>x[limit_total - number_purchased]</span>"
		return

/obj/configurable_credit_store/premade
	limit_total = 1

	New()
		. = ..()
		if(istext(type_to_spawn))
			type_to_spawn = text2path(type_to_spawn)
		if (!type_to_spawn)	return
		setup_premade_shop()

	proc/setup_premade_shop()
		var/atom/movable/AM = new type_to_spawn

		src.appearance = AM.appearance
		src.name = AM.name
		src.thing_name = AM.name
		src.set_density(AM.density)

		src.price_text = new()
		src.price_text.set_loc(src)
		src.price_text.maptext_width = 132
		src.price_text.maptext_x = -50
		src.price_text.maptext_y = -8
		src.price_text.maptext = "<span class='c vb sh xfont'><font color=green>[price > 0 ? "$[price]" : "FREE"]</font></span>"
		src.vis_contents += src.price_text
		src.price_text.appearance_flags = TILE_BOUND | RESET_COLOR | RESET_ALPHA | KEEP_APART | PIXEL_SCALE

		if (src.limit_total && src.limit_total != 1)
			src.quantity_text = new()
			src.quantity_text.set_loc(src)
			src.vis_contents += src.quantity_text
			src.quantity_text.appearance_flags = TILE_BOUND | RESET_COLOR | RESET_ALPHA | KEEP_APART | PIXEL_SCALE
			src.update_quantity()

		qdel(AM)
		animate(src, pixel_y = 0 + src.float_pixels,  time = 2 SECONDS, loop = -1, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
		animate(pixel_y = 0, time = 2 SECONDS, loop = -1, easing = SINE_EASING)
		set_up = TRUE

/obj/configurable_credit_store/premade/popcorn
	limit_total = 0
	price = 0
	type_to_spawn = /obj/item/reagent_containers/food/snacks/popcorn

	New()
		. = ..()
		pixel_x = 0
		pixel_y = 0
