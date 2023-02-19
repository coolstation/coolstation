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
var/global/gehenna_time = GEHENNA_TIME

// Gehenna shit tho
/turf/space/gehenna
	name = "planet gehenna"
	desc = "errrr"
	opacity = 0
	pathable = 0
	mat_changename = 0
	mat_changedesc = 0
	fullbright = 0
	luminosity = 1
	intact = 0 //allow wire laying
	throw_unlimited = 0
	color = "#ffffff"
	special_volume_override = -1


/turf/simulated/wall/asteroid/gehenna
	fullbright = 0
	luminosity = 1 // 0.5*(sin(GEHENNA_TIME)+ 1)

	name = "sulferous rock"
	desc = "looks loosely packed"
	icon = 'icons/turf/floors.dmi'
	icon_state = "gehenna_rock"
	floor_turf = "/turf/space/gehenna/desert"
	hardness = 1
	New()
		..()
		src.icon_state = initial(src.icon_state)
	space_overlays()
		return

	ex_act(severity)
		switch(severity)
			if(1.0)
				src.damage_asteroid(5)
			if(2.0)
				src.damage_asteroid(4)
			if(3.0)
				src.damage_asteroid(3)
		return

/turf/simulated/wall/asteroid/gehenna/z3
	floor_turf = "/turf/simulated/floor/plating/gehenna"

/turf/simulated/wall/asteroid/gehenna/tough
	name = "crimson bedrock"
	desc = "looks densely packed"
	icon_state = "gehenna_rock2"
	hardness = 2

	ex_act(severity)
		switch(severity)
			if(1.0)
				src.damage_asteroid(3)
			if(2.0)
				src.damage_asteroid(2)
			if(3.0)
				src.damage_asteroid(1)
		return

/turf/simulated/wall/asteroid/gehenna/tough/z3
	floor_turf = "/turf/simulated/floor/plating/gehenna"


/turf/unsimulated/wall/gehenna/
	fullbright = 0
	luminosity = 1
	name = "monolithic sulferous rock"
	desc = "looks conveniently impenetrable"
	icon = 'icons/turf/floors.dmi'
	icon_state = "gehenna_rock3"

/turf/simulated/floor/plating/gehenna/
	name = "sand"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "sand"
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED
	plate_mat = 0 //Prevents this "steel sand" bullshit but it's not a great solution
	allows_vehicles = 1

	New()
		..()
		src.set_dir(pick(cardinal))

	ex_act(severity) //TODO: cave ins?? people mentioned that repeatedly??
		return //no plating/lattice thanx

/turf/simulated/floor/plating/gehenna/plasma
	oxygen = MOLES_O2STANDARD * 1.5
	nitrogen = MOLES_N2STANDARD / 2
	toxins = MOLES_O2STANDARD // hehh hehh hehhhehhhe

/turf/simulated/floor/plating/gehenna/farts
	farts = MOLES_N2STANDARD / 2
	nitrogen = MOLES_N2STANDARD / 2

/turf/space/gehenna/desert
	name = "barren wasteland"
	desc = "Looks really dry out there."
	icon = 'icons/turf/floors.dmi'
	icon_state = "gehenna"
	carbon_dioxide = 5*(sin(GEHENNA_TIME - 90)+ 1)
	oxygen = MOLES_O2STANDARD * (sin(GEHENNA_TIME - 60)+2)
	nitrogen = MOLES_O2STANDARD *0.5*(sin(GEHENNA_TIME + 90)+2)
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
		SPAWN_DBG(0.1)
			light.enable()



	plating
		name = "sand-covered plating"
		desc = "The desert slowly creeps upon everything we build."
		icon = 'icons/turf/floors.dmi'
		icon_state = "gehenna_tile"

		thermal
			name = "sand-covered solar plating"
			desc = "absorbs the sun's rays, gets real hot."
			temperature = WASTELAND_MIN_TEMP + ((0.5*sin(GEHENNA_TIME-45)+0.5)*(1.5*WASTELAND_MAX_TEMP - WASTELAND_MIN_TEMP))

		podbay
			icon_state = "gehenna_plating"

	path
		name = "beaten earth"
		desc = "this soil has been beaten flat by years of foot traffic."
		icon = 'icons/turf/floors.dmi'
		icon_state = "gehenna_edge"

	corner
		name = "beaten earth"
		desc = "this soil has been beaten flat by years of foot traffic."
		icon = 'icons/turf/floors.dmi'
		icon_state = "gehenna_corner"




/area/gehenna

/area/gehenna/wasteland
	icon_state = "red"
	name = "the barren wastes"
	teleport_blocked = 0

/area/gehenna/wasteland/stormy
	name = "the horrid wastes"
	icon_state = "yellow"

	New()
		..()
		overlays += image(icon = 'icons/turf/areas.dmi', icon_state = "dustverlay", layer = EFFECTS_LAYER_BASE)

	Entered(atom/movable/O)
		..()
		if (ishuman(O))
			var/mob/living/jerk = O
			if (!isdead(jerk))
				if((istype(jerk:wear_suit, /obj/item/clothing/suit/armor))||(istype(jerk:wear_suit, /obj/item/clothing/suit/space)))&&(istype(jerk:head, /obj/item/clothing/head/helmet/space)) return
				random_brute_damage(jerk, 50)
				jerk.changeStatus("weakened", 40 SECONDS)
				step(jerk,EAST)
				if(prob(50))
					playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_2.ogg', 50, 1)
					boutput(jerk, pick("Dust gets caught in your eyes!","The wind blows you off course!","Debris pierces through your skin!"))



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

