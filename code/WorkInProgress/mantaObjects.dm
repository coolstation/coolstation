//----------------TABLE OF CONTENTS--------------------//

// mylie was here, removing most this shit

//MANTA RELATED LISTS AND GLOBAL VARIABLES//
//MANTA RELATED OBJECTS//
//MANTA RELATED TURFS//
//MANTA RELATED DATUMS (Mainly related to fixing propellers.)//
//MANTA RELATED AREAS//
//MANTA SECRET STUFF//

//-------------------------------------------- MANTA COMPATIBLE OBJECTS HERE --------------------------------------------

/obj/decal/mantaBubbles
	density = 0
	anchored = 2
	layer =  EFFECTS_LAYER_4
	event_handler_flags = USE_FLUID_ENTER
	name = ""
	mouse_opacity = 0

	New()
		START_TRACKING
		..()

	disposing()
		STOP_TRACKING
		return ..()

	small
		icon = 'icons/effects/bubbles32x64.dmi'
		icon_state = "bubbles"
		pixel_y = 8

	large
		icon = 'icons/effects/bubbles64x64.dmi'
		icon_state = "bubbles2"
		pixel_y = 16

	verylarge
		icon = 'icons/effects/bubbles64x256.dmi'
		icon_state = "bubbles"
		pixel_y = 16

	smallfast
		icon = 'icons/effects/bubbles_1.dmi'
		icon_state = "bubbles"
		dir = NORTH
		//pixel_y = 32

/obj/machinery/junctionbox
	name = "junction box"
	desc = "An electrical junction box is an enclosure housing electrical connections, to protect the connections and provide a safety barrier."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "junctionbox"
	anchored = 2
	var/open = 0
	var/iconopen = "junctionbox_open"
	var/iconclosed = "junctionbox"
	var/broken = 0
	var/repairstate = 0
	var/obj/cable/attached
	var/drain_rate = 50000		// amount of power to drain per tick
	var/power_drained = 0 		// has drained this much power
	var/max_power = 2e8		// maximum power that can be drained before exploding

	New()
		START_TRACKING
		. = ..()
		update_icon()

	disposing()
		STOP_TRACKING
		return ..()

	attack_hand(mob/user as mob)
		if (isAI(user))
			boutput(user, "<span class='alert'>You'd touch the door, if only you had hands.</span>")
			return
		if (broken == 1)
			user.shock(src, rand(5000, 15000), "chest", 1)
		if (!src.open)
			src.open = 1
			update_icon()
			user.show_text("<span class='notice'><b>You open junction box's outer door.</b></span>")
		else
			src.open = 0
			update_icon()
			user.show_text("<span class='notice'><b>You close junction box's outer door.</b></span>")
	proc/Breakdown()
		src.broken = 1
		src.repairstate = 1
		src.desc = "You should start by removing the outer screws from the casing. Be sure to wear some insulated gloves!"

	proc/Repair()
		src.broken = 0
		src.repairstate = 0

	proc/update_icon()
		if (src.open == 1)
			src.icon_state = src.iconopen

		else
			src.open = 0
			src.icon_state = src.iconclosed

	process()
		if(broken == 1)
			var/obj/sparks = new /obj/effects/sparks/end()
			sparks.set_loc(src.loc)
			playsound(src.loc, "sparks", 100, 1)
			var/area/TT = get_area(src)
			if(isarea(TT))
				attached = locate() in TT
			if(attached)
				var/datum/powernet/PN = attached.get_powernet()
				if(PN)
					var/drained = min ( drain_rate, PN.avail )
					PN.newload += drained
					power_drained += drained

					if(drained < drain_rate)
						for(var/obj/machinery/power/terminal/T in PN.nodes)
							if(istype(T.master, /obj/machinery/power/apc))
								var/obj/machinery/power/apc/A = T.master
								if(A.operating && A.cell)
									A.cell.charge = max(0, A.cell.charge - 50)
									power_drained += 50

				if(power_drained > max_power * 0.95)
					playsound(src, "sound/effects/screech.ogg", 50, 1, 1)
				if(power_drained >= max_power)
					processing_items.Remove(src)
					explosion(src, src.loc, 3,6,9,12)
					qdel(src)

/obj/machinery/junctionbox/varianta
	icon_state = "junctionbox3"
	iconopen = "junctionbox3_open"
	iconclosed = "junctionbox3"

/obj/machinery/junctionbox/variantb
	icon_state = "junctionbox2"
	iconopen = "junctionbox2_open"
	iconclosed = "junctionbox2"

/obj/machinery/communicationstower
	icon = 'icons/obj/large/32x64.dmi'
	name = "Communications Tower"
	icon_state = "commstower"
	density = 0
	anchored = 2
	var/health = 100
	var/maxhealth = 100
	var/broken = 0
	bound_width = 32
	bound_height = 32

	ex_act(severity)
		switch(severity)
			if(OLD_EX_SEVERITY_1)
				change_health(-maxhealth)
				return
			if(OLD_EX_SEVERITY_2)
				change_health(-50)
				return
			if(OLD_EX_SEVERITY_3)
				change_health(-35)
				return

	attackby(var/obj/item/I as obj, var/mob/user as mob)
		user.lastattacked = src
		..()
		if (broken == 0)
			change_health(-I.force)
			return
		else
			return

	proc/change_health(var/change = 0)
		health = max(min(maxhealth, health+change), 0)
		if (broken == 1)
			return
		if(health == 0)
			icon_state = "commstower_broken"
			broken = 1
			random_events.force_event("Communications Malfunction")

/obj/miningteleporter
	name = "Experimental long-range mining teleporter"
	desc = "Well this looks somewhat unsafe."
	icon = 'icons/misc/32x64.dmi'
	icon_state = "englrt0"
	density = 0
	anchored = 1
	var/recharging =0
	var/id = "shuttle" //The main location of the teleporter
	var/recharge = 20 //A short recharge time between teleports
	var/busy = 0
	layer = 2
	bound_height = 32
	bound_width = 32

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING


	attack_ai(mob/user as mob)
		return attack_hand(user)

	attack_hand(mob/user as mob)
		if(busy) return
		if(get_dist(user, src) > 1 || user.z != src.z) return
		src.add_dialog(user)
		add_fingerprint(user)
		busy = 1
		flick("englrt1", src)
		playsound(src, 'sound/machines/lrteleport.ogg', 60, 1)
		animate_teleport(user)
		SPAWN_DBG(1 SECOND)
		teleport(user)
		busy = 0

	proc/teleport(mob/user)
		for_by_tcl(S, /obj/miningteleporter)
			if(S.id == src.id && S != src)
				if(recharging == 1)
					return 1
				else
					S.recharging = 1
					src.recharging = 1
					user.set_loc(S.loc)
					showswirl(user.loc)
					SPAWN_DBG(recharge)
						S.recharging = 0
						src.recharging = 0
				return
/obj/item/rddiploma
	name = "RD's diploma"
	icon = 'icons/obj/items/items.dmi'
	desc = ".. Upon closer inspection this degree seems to be fake! Who could have guessed!"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	icon_state = "rddiploma"
	item_state = "rddiploma"

/obj/item/mdlicense
	name = "MD's medical license"
	icon = 'icons/obj/items/items.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	icon_state = "mdlicense"
	item_state = "mdlicense"

/obj/item/firstbill
	name = "HoP's first bill"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "hopbill"

//CONSTRUCTION WORKER STUFF//

/obj/item/constructioncone
	desc = "Caution!"
	name = "construction cone"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "cone"
	force = 1.0
	throwforce = 3.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	flags = FPRINT | TABLEPASS
	stamina_damage = 15
	stamina_cost = 8
	stamina_crit_chance = 10

/obj/effect/boommarker
	name = ""
	icon = 'icons/effects/64x64.dmi'
	icon_state = "impact_marker"
	density = 0
	anchored = 1
	mouse_opacity = 0
	desc = "Uh oh.."
	pixel_x = -16
	pixel_y = -16

/obj/item/blackbox
	name = "flight recorder of NSS Polaris"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	icon = 'icons/obj/items/items.dmi'
	icon_state = "blackbox"
	desc = "A flight recorder is an electronic recording device placed in an spacecraft for the purpose of facilitating the investigation of accidents and incidents. Someone from Nanotrasen would surely want to see this."
	item_state = "electropack"
	force = 5.0

/turf/floor/polarispit
	name = "deep abyss"
	desc = "You can't see the bottom."
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "pit"
	fullbright = 0
	pathable = 0
	var/falltarget = LANDMARK_FALL_POLARIS

	New()
		src.AddComponent(/datum/component/pitfall/target_landmark,\
			BruteDamageMax = 50,\
			HangTime = 0 SECONDS,\
			TargetLandmark = src.falltarget)
		..()

	polarispitwall
		icon_state = "pit_wall"

	marj
		name = "dank abyss"
		desc = "The smell rising from it somehow permeates the surrounding water."
		falltarget = LANDMARK_FALL_MARJ

		pitwall
			icon_state = "pit_wall"

//-------------------------------------------- NSS MANTA SECRET VAULT --------------------------------------------

/obj/vaultdoor
	name = "vault door"
	icon = 'icons/obj/large/96x32.dmi'
	icon_state = "vaultdoor_closed"
	density = 1
	anchored = 2
	opacity = 1
	bound_width = 96
	appearance_flags = TILE_BOUND

/turf/floor/special/fogofcheating
	name = "fog of cheating prevention"
	desc = "Yeah, nice try."
	icon_state = "void_gray"

/area/mantavault
	name = "NSS Manta Secret Vault"
	icon_state = "red"
	teleport_blocked = 1
	sound_loop_1 = "sound/ambience/loop/manta_vault.ogg"
	sound_group = "vault"

/obj/trigger/mantasecrettrigger
	name = "Confession of a jester."

	var/running = 0
	var/triggered = 0

	on_trigger(var/atom/movable/triggerer)
		//Sanity check
		if(isobserver(triggerer) || running) return
		if (triggered == 0)
			var/mob/M = triggerer
			if(!istype(M))
				return
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if (H.wear_mask && H.head && H.shoes && H.w_uniform)
					if (istype(H.head, /obj/item/clothing/head/jester) && istype(H.wear_mask, /obj/item/clothing/mask/jester) && istype(H.shoes, /obj/item/clothing/shoes/jester) && istype(H.w_uniform, /obj/item/clothing/under/gimmick/jester))
						triggerer.visible_message("<span class='alert'>A hidden compartment opens up, revealing a hatch and a ladder.</span>")
						playsound(src.loc, "sound/effects/polaris_crateopening.ogg", 90, 1,1)
						new /obj/ladder/vaultladder(get_turf(src))
						triggered = 1
						return

/obj/ladder/vaultladder
	id = "vault"
