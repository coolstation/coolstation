//#define NEVICATA_TIME (((BUILD_TIME_DAY * 24)+(BUILD_TIME_HOUR)) * 2)
#define NEVICATA_TIME 30 //set this define to whatever to test different times of day

#define NEVICATA_PRESSURE ONE_ATMOSPHERE * 0.8
#define WASTES_MIN_TEMP 125 //only marginally warmer than the real life Triton
#define WASTES_MAX_TEMP 170 //hell is still well beyond frozen over
#define NEVICATA_CO2 NEVICATA_PRESSURE * 0.07
#define NEVICATA_N2 MOLES_N2STANDARD * 1.7
#define NEVICATA_02 MOLES_O2STANDARD * 2.1
#define NEVICATA_TEMP ((WASTES_MAX_TEMP - WASTES_MIN_TEMP)/2) * sin(NEVICATA_TIME-20) + ((WASTES_MAX_TEMP + WASTES_MIN_TEMP) / 2)

var/global/nevicata_time = NEVICATA_TIME

// 10 - dark and cold
// 30 - little, slightly warmer sunrise
// 70 - About as bright as twilight and as cold as Titan.
// 90 - <b>The midday glow of Amica casts a long shadow</b>, still really cold
// 110 -The warmest it will be, which is still lethal.
// 150 -Amica is beginning to set, and the bone chilling cold is creeping back(more bone chilling, rather.)
//
//todo: make some nevicata audio loops and whatnot

/turf/space/nevicata
	name = "the moon Nevicata"
	desc = "it seems reality has broken down."
	opacity = 0
	pathable = 0
	mat_changename = 0
	mat_changedesc = 0
	fullbright = 0
	luminosity = 1
	intact = 0
	throw_unlimited = 0
	color = "#ffffff"
	special_volume_override = -1

/turf/wall/asteroid/nevicata
	fullbright = 0
	luminosity = 1

	name = "exotic ice"
	desc = "looks pretty tough."
	icon = 'icons/turf/floors.dmi'
	icon_state = "nevicata_ice"
	hardness = 1
	default_ore = /obj/item/raw_material/ice/nevicata

	New()
		..()
		src.icon_state = initial(src.icon_state)
	space_overlays()
		return

	ex_act(severity)
		switch(severity)
			if(OLD_EX_SEVERITY_1)
				src.damage_asteroid(5)
			if(OLD_EX_SEVERITY_2)
				src.damage_asteroid(4)
			if(OLD_EX_SEVERITY_3)
				src.damage_asteroid(3)
		return

/turf/wall/asteroid/nevicata/tough
	name = "exotic ice bedrock"
	desc = "looks very tough"
	icon_state = "nevicata_ice2"
	hardness = 2
	turf_flags = IS_TYPE_SIMULATED | MINE_MAP_PRESENTS_TOUGH

	ex_act(severity)
		switch(severity)
			if(OLD_EX_SEVERITY_1)
				src.damage_asteroid(3)
			if(OLD_EX_SEVERITY_2)
				src.damage_asteroid(2)
			if(OLD_EX_SEVERITY_3)
				src.damage_asteroid(1)
		return

/turf/wall/nevicata/
	fullbright = 0
	luminosity = 1
	name = "gigantic exotic ice"
	desc = "looks impossible to mine through"
	icon = 'icons/turf/floors.dmi'
	icon_state = "nevicata_ice3"

/turf/floor/plating/nevicata/
	name = "snow"
	icon = 'icons/turf/floors.dmi'
	icon_state = "snow_calm"
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED
	plate_mat = 0 //copy pasted from Gehenna, to prevent tiles from having material prefixes
	allows_vehicles = 1
	turf_flags = IS_TYPE_SIMULATED | MOB_SLIP | MOB_STEP | MINE_MAP_PRESENTS_EMPTY

	New()
		..()
		src.set_dir(pick(cardinal))



/turf/space/nevicata/wastes
	pathable = 1
	name = "frozen wastes"
	desc = "Crunchy ice and ash underfoot. Try not to step on the yellow spots."
	icon = 'icons/turf/floors.dmi'
	icon_state = "snow_calm"
	carbon_dioxide = NEVICATA_CO2
	oxygen = NEVICATA_02
	nitrogen = NEVICATA_N2
	temperature = NEVICATA_TEMP

	luminosity = 1

	var/datum/light/point/light = null
	var/light_r = 0.25*(sin(NEVICATA_TIME)+1.1)
	var/light_g = 0.15*(sin(NEVICATA_TIME)+1.1)
	var/light_b = 0.2*(sin(NEVICATA_TIME)) + 0.3
	var/light_brightness = 0.6*(sin(NEVICATA_TIME)) + 0.62
	var/light_height = 3
	var/generateLight = 1
	var/stone_color

	New()
		..()
		if (generateLight)
			src.make_light()
		if(icon_state == "snow_beat" || icon_state == "snow_calm")
			src.dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)


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
		name = "snow-covered plating"
		desc = "Everything ends in ice."
		icon = 'icons/turf/floors.dmi'
		icon_state = "snow2"

	path
		name = "packed ice"
		desc = "this ice has been packed by years of foot traffic"
		icon = 'icons/turf/floors.dmi'
		icon_state = "snow_edge"

	corner
		name = "beaten earth"
		desc = "this ice has been packed by years of foot traffic"
		icon = 'icons/turf/floors.dmi'
		icon_state = "snow_edge_corner"

	beaten
		name = "beaten earth"
		desc = "this ice has been packed by years of foot traffic"
		icon = 'icons/turf/floors.dmi'
		icon_state = "snow_beat"

/area/nevicata
	requires_power = 0
	icon_state = "dither_b"
	name = "the nevicatan tundra"

/area/nevicata/wastes
	requires_power = 0
	icon_state = "dither_g"
	name = "the barren nevicatan wastes"
	teleport_blocked = 0
	sound_environment = EAX_PLAIN

	New()
		..()
		for(var/turf/space/nevicata/wastes/T in src)
			T.temperature = (T.temperature + WASTELAND_MIN_TEMP)
