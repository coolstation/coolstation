//You made a define for the default neon lining stack size of 1 but not the indices of the damn shapes??
#define LINING_CIRCLE 1
#define LINING_STRAIGHT 2
#define LINING_STRAIGHT_SMALL 3
#define LINING_U 4
#define LINING_CORNER 5
#define LINING_CORNER_SMALL 6

/obj/neon_lining
	anchored = ANCHORED
	icon = 'icons/obj/decals/neon_lining.dmi'
	icon_state = "base2"
	name = "neon lining"
	real_name = "neon lining"
	///Shapes: 1 = circle, 2 = _ that's a tile long, 3 = _ that's half a tile long, 4 = |_| shape, 5 = _| shape, 6 = _| shape but twice as wide & tall.
	var/lining_shape = LINING_STRAIGHT
	///Most shapes use patterns in such a way: 0 = no glow on the ends, 1 = glow on both ends, 2 = glow on one end, 3 = glow on the other end; Shape 3 has 4 additional patterns that are used for alternative positioning; Shape 1 only has a single pattern, 0; Shape 0 was removed during development as it was literally 3 pixels and was basically invisible & unclickable.
	var/lining_pattern = 0
	///The on/off variable: 0 = off, 1 = on. Yes, it's a pun.
	var/lining_neOn = 1
	///Colors: blue, pink, yellow.
	var/lining_color = "blue"
	///Rotation: 0 = south, 1 = west, 2 = north, 3 = east.
	var/lining_rotation = 0
	///This is used for choosing the proper icon state for reasons stated in the lining_pattern comment.
	var/lining_icon_state = 1
	///The light. Obviously.
	var/datum/light/light
	///The overlay image which hosts the glowing parts.
	var/image/glow

	New(loc, set_rotation = null, set_color = null, set_shape = null)
		. = ..()
		if (set_rotation)
			lining_rotation = set_rotation
		else //Here's to not fucking up the diner club neon (it'll probably break other, more complicated stuff though)
			lining_rotation = src.dir
		if (set_shape)
			lining_shape = set_shape
		//set_dir(lining_rotation)
		if (set_color in list("blue", "pink", "yellow"))
			lining_color = set_color

		glow = image('icons/obj/decals/neon_lining.dmi', "blue2_1")
		glow.plane = PLANE_SELFILLUM
		lining_update_icon()
		light = new /datum/light/point
		light.set_brightness(0.1)
		if (lining_color == "pink")
			light.set_color(108, 7, 67)
		else if (lining_color == "yellow")
			light.set_color(126, 114, 54)
		else
			light.set_color(17, 74, 124)
		light.attach(src)
		light.enable()

	proc/lining_update_icon()
		//Placed lining colour isn't dynamic this is pointless
		//But also if we do ever need this, break it out into its own proc
		//(A light this tiny is going to affect maybe 9 turfs so who really cares, it's more the principle of the thing dangit)
		/*
		if (lining_color == "pink")
			light.set_color(108, 7, 67)
		else if (lining_color == "yellow")
			light.set_color(126, 114, 54)
		else
			light.set_color(17, 74, 124)
		*/
		if (lining_pattern in list(0, 1, 4, 5))
			lining_icon_state = 1 //No end transition colour or both ends do
		else
			lining_icon_state = 2 //One end transitions

		if (lining_pattern % 2)												//1,3,5,7
			set_dir(lining_rotation)
		else																//0,2,4,6
			//This is some cursed shit but it stems from the order in which alternative patterns are stored in the diagonals of the icon states,
			//so I can't get rid of it without reordering 40+ icon states
			switch(lining_rotation)
				if (SOUTH)
					set_dir(SOUTHEAST)
				if (WEST)
					set_dir(NORTHWEST)
				if (NORTH)
					set_dir(SOUTHWEST)
				else
					set_dir(NORTHEAST)

		if (lining_shape < 1 || lining_shape > 6) //OOB check I guess
			lining_shape = 1
		else if (lining_shape == LINING_STRAIGHT_SMALL)
			//I don't know what's going on here exactly but it relates to the fact that the short straight pieces can be either half of a turf's side
			if (lining_pattern < 2)
				set_icon_state("base3_1")
				glow.icon_state = "[lining_color]3_1"

			else if (lining_pattern > 1 && lining_pattern < 4)
				set_icon_state("base3_1")
				glow.icon_state = "[lining_color]3_2"

			else if (lining_pattern > 3 && lining_pattern < 6)
				set_icon_state("base3_2")
				glow.icon_state = "[lining_color]3_3"

			else if (lining_pattern > 5 && lining_pattern < 8)
				set_icon_state("base3_2")
				glow.icon_state = "[lining_color]3_4"

		else //Every other shape
			set_icon_state("base[lining_shape]")
			if (lining_shape == LINING_CIRCLE)
				glow.icon_state = "[lining_color]1" //Only one possible configuration
			else
				glow.icon_state = "[lining_color][lining_shape]_[lining_icon_state]"

		//This is kinda terrible after setting up glow up above, but only so much I can do
		if (!lining_neOn)
			glow.icon_state = "off" //blank icon
		src.UpdateOverlays(glow, "glow")
		return

	attackby(obj/item/W, mob/user)
		if (ispryingtool(W))
			user.put_in_hand_or_drop(new /obj/item/neon_lining(get_turf(user), 1, lining_color))
			qdel(src)
			return
		if (iswrenchingtool(W)) //Cycle shapes
			if (lining_shape > 0 && lining_shape < 6)
				lining_shape++
			else
				lining_shape = 1
			lining_update_icon()
			return
		if (isscrewingtool(W)) //Turn current shape
			lining_rotation = (turn(lining_rotation, 90))
			lining_update_icon()
			return
		if (issnippingtool(W)) //Toggle on or off
			if (lining_neOn)
				light.disable()
			else
				light.enable()
			lining_neOn = !lining_neOn
			lining_update_icon()
			return
		if (ispulsingtool(W))
			if (lining_pattern > -1 && lining_pattern < 7)
				lining_pattern++
			else
				lining_pattern = 0
			lining_update_icon()
			return
		return

#undef LINING_CIRCLE
#undef LINING_STRAIGHT
#undef LINING_STRAIGHT_SMALL
#undef LINING_U
#undef LINING_CORNER
#undef LINING_CORNER_SMALL
