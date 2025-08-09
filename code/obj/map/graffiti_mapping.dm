//freshly spawnable spray paint graffiti

/obj/decal/cleanable/gang_graffiti/greenface
	name = "graffiti"
	desc = "What a funky dude. He'll never attain political power."
	icon_state = "graffiti-single-1"

/obj/decal/cleanable/gang_graffiti/cool_s
	icon_state = "graffiti-single-2"

/obj/decal/cleanable/gang_graffiti/securitron
	icon_state = "graffiti-single-3"

/obj/decal/cleanable/gang_graffiti/skull
	icon_state = "graffiti-single-4"

/obj/decal/cleanable/gang_graffiti/bigchallenges
	name = "Big Challenges"
	desc = "They're really big challenges. They're really consequential challenges."
	icon_state = "graffiti-single-5"

/obj/decal/cleanable/gang_graffiti/gas_mask
	icon_state = "graffiti-single-6"

/obj/decal/cleanable/gang_graffiti/double
	icon_state = "don't use this one directly fucko"
	icon = 'icons/map-editing/graffiti.dmi'

	New()
		..()
		if (worldgen_hold)
			worldgen_candidates[worldgen_generation] += src
		else src.generate_worldgen()

	generate_worldgen()
		//var/olddir = src.dir
		src.icon = 'icons/obj/decals/graffiti.dmi'
		var/obj/decal/cleanable/gang_graffiti/other_piece = new()
		//Only after rebuilding and importing all the graffitis did I realise their ordering is kinda wack
		//SOUTH and NORTH are graffitis that extend eastwards, EAST AND WEST extend north.
		switch(src.dir)
			if (NORTH)
				other_piece.set_loc(get_step(src, EAST))
				other_piece.icon_state = src.icon_state + "-1"
				//other_piece.set_dir(NORTH)
				src.icon_state = src.icon_state + "-2"
			if (SOUTH)
				other_piece.set_loc(get_step(src, EAST))
				other_piece.icon_state = src.icon_state + "-2"
				//other_piece.set_dir(SOUTH)
				src.icon_state = src.icon_state + "-1"
			if (WEST)
				other_piece.set_loc(get_step(src, NORTH))
				other_piece.icon_state = src.icon_state + "-1"

				src.icon_state = src.icon_state + "-2"
			if (EAST)
				other_piece.set_loc(get_step(src, NORTH))
				other_piece.icon_state = src.icon_state + "-2"
				//other_piece.set_dir(SOUTH)
				src.icon_state = src.icon_state + "-1"
		other_piece.set_dir(src.dir)

/obj/decal/cleanable/gang_graffiti/double/romani_ite_domum //"Romans go home" I think?
	icon_state = "graffiti-dbl-1"

/obj/decal/cleanable/gang_graffiti/double/slop
	icon_state = "graffiti-dbl-2"

/obj/decal/cleanable/gang_graffiti/double/acab
	icon_state = "graffiti-dbl-3"

/obj/decal/cleanable/gang_graffiti/double/accident
	icon_state = "graffiti-dbl-4"

/obj/decal/cleanable/gang_graffiti/double/pride
	icon_state = "graffiti-dbl-5"

/obj/decal/cleanable/gang_graffiti/double/hog
	icon_state = "graffiti-dbl-6"

/obj/decal/cleanable/gang_graffiti/triple
	icon_state = "don't use this one directly fucko"
	icon = 'icons/map-editing/graffiti.dmi'

	New()
		..()
		if (worldgen_hold)
			worldgen_candidates[worldgen_generation] += src
		else src.generate_worldgen()

	generate_worldgen() //Same general idea as the doubles, except with a middle part
		src.icon = 'icons/obj/decals/graffiti.dmi'
		var/obj/decal/cleanable/gang_graffiti/middle_piece = new()
		middle_piece.icon_state = src.icon_state + "-2"
		var/obj/decal/cleanable/gang_graffiti/other_end_piece = new()
		switch(src.dir)
			if (NORTH)
				middle_piece.set_loc(get_step(src, EAST))
				other_end_piece.set_loc(get_step(middle_piece, EAST))
				other_end_piece.icon_state = src.icon_state + "-1"
				src.icon_state = src.icon_state + "-3"
			if (SOUTH)
				middle_piece.set_loc(get_step(src, EAST))
				other_end_piece.set_loc(get_step(middle_piece, EAST))
				other_end_piece.icon_state = src.icon_state + "-3"
				src.icon_state = src.icon_state + "-1"
			if (WEST)
				middle_piece.set_loc(get_step(src, NORTH))
				other_end_piece.set_loc(get_step(middle_piece, NORTH))
				other_end_piece.icon_state = src.icon_state + "-1"
				src.icon_state = src.icon_state + "-3"
			if (EAST)
				middle_piece.set_loc(get_step(src, NORTH))
				other_end_piece.set_loc(get_step(middle_piece, NORTH))
				other_end_piece.icon_state = src.icon_state + "-3"
				src.icon_state = src.icon_state + "-1"
		middle_piece.set_dir(src.dir)
		other_end_piece.set_dir(src.dir)

/obj/decal/cleanable/gang_graffiti/triple/captain
	icon_state = "graffiti-trpl-1"

/obj/decal/cleanable/gang_graffiti/triple/scream
	icon_state = "graffiti-trpl-2"

/obj/decal/cleanable/gang_graffiti/triple/hooliganz
	icon_state = "graffiti-trpl-3"
