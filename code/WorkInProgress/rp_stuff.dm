
/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-=-DESTINY-=-=-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

/proc/get_random_station_turf()
	var/list/areas = get_areas(/area/station)
	if (!areas.len)
		return
	var/area/A = pick(areas)
	if (!A)
		return
	var/list/turfs = get_area_turfs(A, 1)
	if (!turfs.len)
		return
	var/turf/T = pick(turfs)
	if (!T)
		return
	return T

/obj/dummy_pad
	name = "teleport pad"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pad0"
	anchored = 1
	density = 0

/client/proc/cmd_rp_rules()
	set name = "RP Rules"
	set category = "Commands"

	src.Browse( {"<center><h2>Goonstation RP Server Guidelines and Rules</h2></center><hr>
	Welcome to Space Station 13! The only Space Dating Simulator! One of you is going to be the lucky player who gets to be the Protagonist, One of you is going to be the Tsundre who is being courted, and everyone else will show up once and then vanish!
	To enjoy the magic of the rounds, please keep in mind these simple rules.
	1. Do not interrupt the main protaginst. It's against the rules!
	2. You MUST have a meta friend to date!
	3. Any step out of line will result in being shunned and then banned with no appeal!
	</ul>"}, "window=rprules;title=RP+Rules" )


/*
/obj/airlock_door
	icon = 'icons/obj/doors/animated.dmi'
	icon_state = "gen-left"
	density = 0
	opacity = 0
	var/obj/machinery/door/door = null

	attackby(obj/item/W, mob/M)
		if (src.door)
			src.door.Attackby(W, M)

	attack_hand(mob/M)
		if (src.door)
			src.door.Attackhand(M)

	attack_ai(mob/user)
		if (src.door)
			src.door.attack_ai(user)

/obj/machinery/door/airlock/animated
	icon = 'icons/obj/doors/animated.dmi'
	icon_state = "track"
	var/obj/airlock_door/d_left = null
	var/d_left_state = "gen-left"
	var/obj/airlock_door/d_right = null
	var/d_right_state = "gen-right"

	New()
		..()
		src.d_right = new(src.loc)
		src.d_right.icon_state = src.d_right_state
		src.d_right.door = src
		// make left after right so it's on top
		src.d_left = new(src.loc)
		src.d_left.icon_state = src.d_left_state
		src.d_left.door = src

	update_icon()
		src.icon_state = "track"
		return
/*
		if (density)
			if (locked)
				icon_state = "[icon_base]_locked"
			else
				icon_state = "[icon_base]_closed"
			if (p_open)
				if (!src.panel_image)
					src.panel_image = image(src.icon, src.panel_icon_state)
				src.UpdateOverlays(src.panel_image, "panel")
			else
				src.UpdateOverlays(null, "panel")
			if (welded)
				if (!src.welded_image)
					src.welded_image = image(src.icon, src.welded_icon_state)
				src.UpdateOverlays(src.welded_image, "weld")
			else
				src.UpdateOverlays(null, "weld")
		else
			src.UpdateOverlays(null, "panel")
			src.UpdateOverlays(null, "weld")
			icon_state = "[icon_base]_open"
		return
*/
	play_animation(animation)
		switch (animation)
			if ("opening")
				animate(src.d_left, time = src.operation_time, pixel_x = -18, easing = BACK_EASING)
				animate(src.d_right, time = src.operation_time, pixel_x = 18, easing = BACK_EASING)
			if ("closing")
				animate(src.d_left, time = src.operation_time, pixel_x = 0, easing = ELASTIC_EASING)
				animate(src.d_right, time = src.operation_time, pixel_x = 0, easing = ELASTIC_EASING)
			if ("spark")
				flick("[d_left_state]_spark", d_left)
				flick("[d_right_state]_spark", d_right)
			if ("deny")
				flick("[d_left_state]_deny", d_left)
				flick("[d_right_state]_deny", d_right)
		return
*/
// TODO:
// - mailputt
// - mailputt pickup port

/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-CONTROLLER=-=-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */
/*
/datum/destiny_controller
	var/ship_direction = NORTH // the north of the ship should be on this side of the map, ex: cog2's north is to the east side of the map

/* outside the ship during start of warp:
 - throw them at direction opposite ship_direction
 - if they hit the edge and make it to z3, congrats!!
 - if they hit the ship, R  I  P
 - rad damage
 - wibbly effect for space
*/
	proc/enter_warp()
		for (var/mob/M in mobs)
			if (M.z != 1)
				continue
			var/turf/T = get_turf(M)
			if (!istype(T))
				continue
			var/area/A = T.loc
			if (A.type != /area) // not in empty space
				continue
*/
