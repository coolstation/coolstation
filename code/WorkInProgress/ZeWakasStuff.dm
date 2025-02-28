
/*
 * 90 101 87 97 107 97 39 115 83 116 117 102 102
 */

//foo 44: bodacious grandiose bargaloo mambo prime preceed wow github cdn sub jekyll docs rsc ci2 rename profile rat


/* 514 checklist
	?[] experimentation perhaps
	make some lib animate stuff better with spaces? (better rainbow anyone?)
	world.map_cpu hookin (fuck why i delete the old code)
	enable TILE_MOVEMENT_MODE and see if break
	time2text timezone stuff for external? wire?
	particle abuse
*/

// cat

// Greek Adventurezone Thingy

/turf/greek/
	name = "Greek Adventurezone Sprites"
	icon = 'icons/turf/adventure_gannets.dmi'

/turf/wall/greek/
	name = "Greek Adventurezone Sprites"
	icon = 'icons/turf/adventure_gannets.dmi'

/area/greek
	skip_sims = 1
	sims_score = 30

// Beach zone Stuff

/area/greek/beach
	name = "Strange Beach"
	icon_state = "yellow"
	force_fullbright = 1
	sound_environment = EAX_PLAIN

/turf/greek/grass
	name = "grass"
	desc = "Some bright green grass on the ground."
	icon_state = "grass"

/obj/decal/fakeobjects/greekgrass
	name = "grass"
	icon = 'icons/turf/adventure_gannets.dmi'
	icon_state = "grass"
	mouse_opacity = 0

	curve
		icon_state = "grass-curve"
	diag
		icon_state = "grass-diag"

/turf/greek/beach
	name = "beach"
	desc = "A very strange beach, almost artificial somehow."
	icon_state = "sand"

	curve
		icon_state = "beach-curve"
	bodge //yes, i needed this
		icon_state = "island-1"

/turf/greek/water
	name = "water"
	desc = "Splish splash, it's water."
	icon_state = "water"

// Cave Stuff

/area/greek/caves
	name = "Strange Caves"
	icon_state = "green"
	sound_environment = EAX_CAVE

/area/greek/cliffs
	name = "Strange Cliffs"
	icon_state = "blue"
	sound_environment = EAX_CAVE
	force_fullbright = 1

/turf/greek/cave
	name = "rock"
	desc = "A rocky floor, carved from the cave."
	icon_state = "rock-floor"

	floor
		icon_state = "cave-floor"

	rockwall
		icon_state = "rock-wall"

/turf/wall/greek/cave //flat rock wall
	name = "rock"
	desc = "A flat rocky surface."
	icon_state = "rock"

/obj/greek/rockwall //the rocky cliff objects
	name = "rocky cliff"
	desc = "A sharp cliff face formed by rocks"
	icon = 'icons/turf/adventure_gannets.dmi'
	icon_state = "cave-wall"
	anchored = 1
	density = 1
	opacity = 1

	alt
		icon_state = "cave-wall-2"

	meteorhit()
		return

	ex_act()
		return

	blob_act()
		return

	bullet_act()
		return

/obj/decal/fakeobjects/rockpile //small rock pile decor
	name = "rock pile"
	desc = "Some rocks that tumbled off of the cliff walls."
	icon = 'icons/turf/adventure_gannets.dmi'
	icon_state = "smallrock"

	big
		icon_state = "bigrock"

/obj/critter/cyclops
	name = "cyclops"
	real_name = "cyclops"
	desc = "The Eye stares straight into your soul. Creepy."
	density = 1
	icon_state = "greek-cyclops"
	health = 70
	wanderer = 0
	aggressive = 1
	defensive = 1
	atkcarbon = 1
	atksilicon = 1

	seek_target()
		src.anchored = 0
		for (var/mob/living/C in hearers(src.seekrange,src))
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (iscarbon(C) && !src.atkcarbon) continue
			if (issilicon(C) && !src.atksilicon) continue
			if (C.health < 0) continue
			if (C in src.friends) continue
			if (C.name == src.attacker) src.attack = 1
			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (issilicon(C) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message("<span class='combat'><b>[src]</b> charges at [C:name]!</span>")
				playsound(src.loc, 'sound/voice/MEraaargh.ogg', 40, 0)
				src.task = "chasing"
				break
			else
				continue

	ChaseAttack(mob/M)
		src.visible_message("<span class='combat'><B>[src]</B> viciously lunges at [M]!</span>")
		if (prob(20)) M.changeStatus("stunned", 2 SECONDS)
		random_brute_damage(M, rand(5,20),1)

	CritterAttack(mob/M)
		src.attacking = 1
		src.visible_message("<span class='combat'><B>[src]</B> bites [src.target] viciously!</span>")
		random_brute_damage(src.target, rand(5,15),1)
		SPAWN_DBG(1 SECOND)
			src.attacking = 0

// Underworld Stuff

/area/greek/underworld
	name = "Strange Depths"
	icon_state = "purple"
	sound_environment = EAX_DISORDERED

/area/greek/underworld/pit
	icon_state = "white"

/turf/greek/underworld
	name = "brick"
	desc = "Some old and strange weathered bricks, with a bit of dust for good measure."
	icon_state = "under-floor"

	half
		icon_state = "under-halfwall"

/turf/wall/greek/underwall
	name = "brick"
	desc = "A sharp wall composed of old funky bricks."
	icon_state = "under-wall"

/turf/greek/pit
	name = "darkness"
	desc = "You can't see the bottom."
	icon_state = "pit"
	carbon_dioxide = 100
	nitrogen = 0
	oxygen = 0
	temperature = 100
	fullbright = 0
	pathable = 0

	New()
		. = ..()
		src.AddComponent(/datum/component/pitfall/target_landmark,\
			BruteDamageMax = 50,\
			HangTime = 0 SECONDS,\
			TargetLandmark = LANDMARK_FALL_GREEK)

// Misc Stuff

/obj/decal/lightshaft/rainbow
	name = "rainbow"
	desc = "Oh wow, you finally found the end of the rainbow."
	icon_state = "rainbow"


//th3*vqoE
