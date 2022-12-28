#define GEHENNA_TIME (((BUILD_TIME_DAY * 24)+(BUILD_TIME_HOUR))*2)
//the above expression results in about 4 days per month.
// 10 just beautiful. oh. wow. lovely.
// 30 is a beautiful, goldenrod gehenna sunrise.
// 45
// 60 is bright yellow, safe air.
// 90 is bright, reddish, safe and warm.
// 120 is bright, magenta bloom, too hot to breathe.
// 150 is a sakura-pink deathtrap, so inviting but so hot and toxic. probably peak deadliness.
// 170 is like sunset ish, its nice but toxic levels of CO2.
// 200 is dark out, cool, and still toxic levels of CO2.
// 230 is night time, and *just* under the CO2 toxicity threshold.
// 260 much the same, less CO2
// 290 same as above.
// 320 same.
// 350 twilight.s
// 370 just beautiful. oh. wow. lovely. Oh it's 10 again.
#define WASTELAND_MIN_TEMP 250
#define WASTELAND_MAX_TEMP 350


// Gehenna shit tho
/turf/unsimulated/floor/gehenna
	name = "planet gehenna"
	desc = "errrr"
	opacity = 0

/turf/simulated/wall/asteroid/gehenna
	fullbright = 0
	luminosity = 1 // 0.5*(sin(GEHENNA_TIME)+ 1)

	name = "sulferous rock"
	desc = "looks loosely packed"
	icon = 'icons/turf/floors.dmi'
	icon_state = "gehenna_rock"
	floor_turf = "/turf/unsimulated/floor/gehenna/desert"
	hardness = 1
	New()
		..()
		src.icon_state = initial(src.icon_state)
	space_overlays()
		return

/turf/simulated/wall/asteroid/gehenna/z3
	floor_turf = "/turf/simulated/floor/sand"
	hardness = 1

/turf/simulated/wall/asteroid/gehenna/tough
	name = "dense sulferous rock"
	desc = "looks densely packed"
	icon_state = "gehenna_rock2"
	hardness = 2

/turf/simulated/wall/asteroid/gehenna/z3/tough
	name = "dense sulferous rock"
	desc = "looks densely packed"
	icon_state = "gehenna_rock2"
	hardness = 2

/turf/unsimulated/wall/gehenna/
	fullbright = 0
	luminosity = 1
	name = "monolithic sulferous rock"
	desc = "looks conveniently impenetrable"
	icon = 'icons/turf/floors.dmi'
	icon_state = "gehenna_rock3"

/turf/unsimulated/floor/gehenna/desert
	name = "barren wasteland"
	desc = "Looks really dry out there."
	icon = 'icons/turf/floors.dmi'
	icon_state = "gehenna"
	carbon_dioxide = 5*(sin(GEHENNA_TIME - 90)+ 1)
	oxygen = MOLES_O2STANDARD
	nitrogen = 0
	temperature = WASTELAND_MIN_TEMP + ((0.5*sin(GEHENNA_TIME-45)+0.5)*(WASTELAND_MAX_TEMP - WASTELAND_MIN_TEMP))

	luminosity = 1 // 0.5*(sin(GEHENNA_TIME)+ 1)

	var/datum/light/point/light = null
	var/light_r = 0.5*(sin(GEHENNA_TIME)+1)
	var/light_g = 0.3*(sin(GEHENNA_TIME )+1)
	var/light_b = 0.4*(sin(GEHENNA_TIME - 45 )+1)
	var/light_brightness = 0.6*(sin(GEHENNA_TIME)+0.8) + 0.3
	var/light_height = 3
	var/generateLight = 1
	var/stone_color

	New()
		..()
		if (generateLight)
			src.make_light() /*
			generateLight = 0
			if (z != 3) //nono z3
				for (var/dir in alldirs)
					var/turf/T = get_step(src,dir)
					if (istype(T, /turf/simulated))
						generateLight = 1
						src.make_light()
						break */


	make_light()
		if (!light)
			light = new
			light.attach(src)
		light.set_brightness(light_brightness)
		light.set_color(light_r, light_g, light_b)
		light.set_height(light_height)
		light.enable()



	plating
		name = "sand-covered plating"
		desc = "The desert slowly creeps upon everything we build."
		icon = 'icons/turf/floors.dmi'
		icon_state = "gehenna_tile"

		podbay
			icon_state = "gehenna_plating"

	path
		name = "beaten earth"
		desc = "for seven years we toiled, to tame wild Gehenna"
		icon = 'icons/turf/floors.dmi'
		icon_state = "gehenna_edge"

	corner
		name = "beaten earth"
		desc = "for seven years we toiled, to tame wild Gehenna"
		icon = 'icons/turf/floors.dmi'
		icon_state = "gehenna_corner"




/area/gehenna

/area/gehenna/wasteland
	icon_state = "red"
	name = "the barren wastes"
	teleport_blocked = 0

/*
/obj/machinery/computer/sea_elevator/sec
	upper = /area/shuttle/sea_elevator/upper/sec
	lower = /area/shuttle/sea_elevator/lower/sec

/obj/machinery/computer/sea_elevator/eng
	upper = /area/shuttle/sea_elevator/upper/eng
	lower = /area/shuttle/sea_elevator/lower/eng

/obj/machinery/computer/sea_elevator/med
	upper = /area/shuttle/sea_elevator/upper/med
	lower = /area/shuttle/sea_elevator/lower/med

/obj/machinery/computer/sea_elevator/QM
	upper = /area/shuttle/sea_elevator/upper/QM
	lower = /area/shuttle/sea_elevator/lower/QM

/obj/machinery/computer/sea_elevator/command
	upper = /area/shuttle/sea_elevator/upper/command
	lower = /area/shuttle/sea_elevator/lower/command
*/
/obj/machinery/computer/sea_elevator/NTFC
	upper = /area/shuttle/sea_elevator/upper/NTFC
	lower = /area/shuttle/sea_elevator/lower/NTFC

