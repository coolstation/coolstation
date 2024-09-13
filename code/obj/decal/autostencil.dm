//Object to automatically generate text out of stencil decals. Theoretically extendable to other fonts, if you have the patience to do so.
//ATM only intended for mapping purposes, but I'd like to give players the ability to easily stencil stuff later on.

//empty space in icon before start of letter
#define STENCIL_SPACE_WIDTH 7 //total width of a space, as best I can tell the only place where a space occurs manually is in "Big Yank's/Cheap Tug", where the spaces are 11 and 4 apart respectively
#define STENCIL_SPACING 3 //three is what's applied manually on cog1 and cog2

/obj/map/autostencil
	name = "TEXT HERE"
	icon_state = "autostencil"
	//metadata about the stencil graphics (/icons/obj/decals/stencils.dmi), for proper-ish kerning
	//N.B. the icon size for stencils is 23*10. Every letter is 9 px high (top pixel is empty) and centered
	var/static/list/stencil_letter_starts = list("a" = 7, "b" = 7, "c" = 7, "d" = 8, "e" = 7, "f" = 7, "g" = 7, "h" = 7, "i" = 10, "j" = 6, "k" = 7, "l" = 7, "m" = 4,  "n" = 7, "o" = 7, "p" = 8, "q" = 7, "r" = 7, "s" = 7, "t" = 7, "u" = 7, "v" = 7, "w" = 5,  "x" = 7, "y" = 7, "z" = 7, "0" = 7, "1" = 10, "2" = 7, "3" = 7, "4" = 7, "5" = 7, "6" = 7, "7" = 7, "8" = 7, "9" = 7)
	var/static/list/stencil_letter_widths =  list("a" = 9, "b" = 9, "c" = 9, "d" = 9, "e" = 9, "f" = 9, "g" = 9, "h" = 9, "i" = 2,  "j" = 9, "k" = 9, "l" = 9, "m" = 14, "n" = 9, "o" = 9, "p" = 9, "q" = 9, "r" = 9, "s" = 9, "t" = 9, "u" = 9, "v" = 9, "w" = 13, "x" = 9, "y" = 9, "z" = 9, "0" = 9, "1" = 2,  "2" = 9, "3" = 9, "4" = 9, "5" = 9, "6" = 9, "7" = 9, "8" = 9, "9" = 9)

	New()
		..()
		src.name = lowertext(src.name)
		var/datum/text_roamer/TR = new(src.name) //a bit overkill, but code reuse!
		var/obj/decal/poster/wallsign/stencil/current_stencil
		var/turf/current_turf = get_turf(src)
		for(var/i in 1 to length(src.name))
			if (TR.curr_char == " ")
				src.pixel_x += STENCIL_SPACE_WIDTH
			else
				if (!(TR.curr_char in stencil_letter_starts)) //ignore unsupported characters
					TR.next()
					continue
				pixel_x += STENCIL_SPACING
				//Realistically stencil text is only going to be written horizontally left to right by virtue of how English works,
				//so why bother with anything else
				if (pixel_x >= 32)
					var/turf/Tnext = locate(current_turf.x + 1, current_turf.y, current_turf.z)
					if (!Tnext)
						break //Can't make text off the edge of the map thx
					set_loc(Tnext)
					current_turf = Tnext
					pixel_x -= 32

				current_stencil = new(current_turf)
				current_stencil.pixel_y = src.pixel_y
				current_stencil.pixel_x = src.pixel_x - stencil_letter_starts[TR.curr_char]
				current_stencil.icon_state = TR.curr_char
				current_stencil.name = TR.curr_char

				pixel_x += stencil_letter_widths[TR.curr_char]
			TR.next()

		qdel(TR)
		qdel(src)

#undef STENCIL_SPACE_WIDTH
#undef STENCIL_SPACING
