//Apologies in advance for scrungling this so bad but the flow is terrible
ABSTRACT_TYPE(/datum/projectile/bullet)
/datum/projectile/bullet
//How much of a punch this has, tends to be seconds/damage before any resist
	power = 45
//How much ammo this costs
	cost = 1
//How fast the power goes away
	dissipation_rate = 5
//How many tiles till it starts to lose power
	dissipation_delay = 5
//Kill/Stun ratio
	ks_ratio = 1.0
//name of the projectile setting, used when you change a guns setting
	sname = "single shot"
//file location for the sound you want it to play
	shot_sound = 'sound/weapons/Gunshot.ogg'
//How many projectiles should be fired, each will cost the full cost
	shot_number = 1
//Amount of fouling to do per shot (50 shots of NT ammo until it starts to get rough and need cleaning, 100 shots before it really has problems. Other shots are much dirtier)
	//var/dirtiness = 1

	// caliber list: update as needed
	// CALIBER_TINY - standard pistol, 8mm and short
	// CALIBER_LONG - standard rifle, 8mm but long (requires a stock)
	// CALIBER_WIDE - standard shotgun, 16mm and short (requires a heavy barrel)
	// CALIBER_LONG_WIDE - extra large, 16mm and long (requires a heavy barrel and stock)

	// pistol rounds fit in rifles and shotguns, same with rifle/shotgun rounds and huge guns

	// 0.41 - derringer (update later)
	// 1.57 - grenade shell, 40mm (update later)
	// 1.58 - RPG-7 (Tube is 40mm too, though warheads are usually larger in diameter.) (update later)

//What is our damage type
/*
kinetic - raw power
piercing - punches though things
slashing - cuts things
energy - energy
burning - hot
radioactive - rips apart cells or some shit
toxic - poisons
*/
	damage_type = D_KINETIC
// blood system damage type - DAMAGE_STAB, DAMAGE_CUT, DAMAGE_BLUNT
	hit_type = DAMAGE_CUT
	//With what % do we hit mobs laying down
	hit_ground_chance = 33
	//Can we pass windows
	window_pass = 0
	implanted = /obj/item/implant/projectile
	// we create this overlay on walls when we hit them
	icon_turf_hit = "bhole"

	hit_mob_sound = 'sound/impact_sounds/Flesh_Stab_2.ogg'

//Any special things when it hits shit?
	on_hit(atom/hit, direction, obj/projectile/P)
		if (ishuman(hit) && src.hit_type)
			if (hit_type != DAMAGE_BLUNT)
				take_bleeding_damage(hit, null, round(src.power / 3), src.hit_type) // oh god no why was the first var set to src what was I thinking
			hit.changeStatus("staggered", clamp(P.power/8, 5, 1) SECONDS)
		..()//uh, what the fuck, call your parent
		//return // BULLETS CANNOT BLEED, HAINE

//hi i eventually want to make it pistol/weak rather than pistol_weak but i'm not doing that yet (requires lotta changes)

/* ------------------------------ Onto The Bits ----------------------------- */

//custom manufactured bullets. probably for some other time.
/datum/projectile/bullet/custom
	name = "bullet"
	power = 1
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_pistol_nt
	casing = /obj/item/casing/small
	caliber = 0.31
	icon_turf_hit = "bhole-small"
	dud_freq = 10

/* ------------------------------- Pistol Shit ------------------------------ */

//so 8mm is the standard size here just because. all other measurements for "different" calibers are just the same in different measurements systems
/datum/projectile/bullet/pistol
	name = "bullet"
	power = 20
	shot_sound = 'sound/weapons/9x19NATO.ogg' //changing from small caliber because all the bullets are kinda the same size
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	caliber = CALIBER_TINY
	icon_turf_hit = "bhole-small"
	casing = /obj/item/casing/small

//NT plastic rounds (.380/9mm equivalent), low powder
/datum/projectile/bullet/pistol/NT
	power = 25
	implanted = /obj/item/implant/projectile/bullet_pistol_nt
	caliber = CALIBER_TINY
	icon_turf_hit = null //plastic, doesn't leave holes, sure why not
	dud_freq = 2

/datum/projectile/bullet/pistol/NT/HP
	power = 32
	implanted = /obj/item/implant/projectile/bullet_pistol_nt_hp
	dud_freq = 1

/datum/projectile/bullet/pistol/NT/stunners
//basically baton rounds in bullet form, does not penetrate or shock, but does knock the wind out of you if hit in chest (hmm, losebreath?) and sometimes disorient, possibly disarm if hit in limb, possibly knockout if hit in head (aim for head, actually hit mob, roll to hit head)
	name = "stun bullet"
	power = 20
	ks_ratio = 0.0
	dissipation_delay = 6 //One more tick before falloff begins
	damage_type = D_ENERGY
	hit_type = null
	//jam_mult = 0.9
	icon_turf_hit = null // stun bullets don't make holes
	dud_freq = 0

//buttery smooth italian light rounds, slightly more range and slightly less damage
/datum/projectile/bullet/pistol/italian
	name = "bullet"
	power = 22
	ks_ratio = 1.0
	//jam_mult = 0.8
	implanted = /obj/item/implant/projectile/bullet_pistol_italian
	dissipation_delay = 6
	dissipation_rate = 4
	icon_turf_hit = "bhole-small"
	dud_freq = 2

// really need to get better framework for AP rounds in place
/datum/projectile/bullet/pistol/italian/AP //traitor det revolver
	//jam_mult = 0.85
	implanted = /obj/item/implant/projectile/bullet_pistol_italian_ap
	damage_type = D_PIERCING
	hit_type = DAMAGE_STAB

// slightly silly
/datum/projectile/bullet/pistol/italian/flare
	name = "flare"
	power = 12
	//jam_mult = 1.2
	implanted = null
	brightness = 1
	color_red = 1
	color_green = 0.2
	color_blue = 0

	tick(var/obj/projectile/P)
		var/turf/T = get_turf(P)
		if (isturf(T) && !(locate(/obj/blob/reflective) in T))
			T.hotspot_expose(max(power*50,T20C), 5)
		return ..()

	on_hit(atom/hit, direction, obj/projectile/P)
		. = ..()
		if(isliving(hit))
			var/mob/living/L = hit
			L.changeStatus("burning", floor(4 + src.power DECI SECONDS))

//Juicer Jr. rounds shoot two of these
/datum/projectile/bullet/pistol/juicer
	name = "bullet"
	power = 20
	//jam_mult = 2
	dissipation_delay = 4
	dissipation_rate = 6
	implanted = /obj/item/implant/projectile/bullet_pistol_juicer
	icon_turf_hit = "bhole-small"
	casing = null
	//casing = /obj/item/casing/medium
	dud_freq = 10
	fouling = 6

/datum/projectile/bullet/pistol/juicer/AP
	damage_type = D_PIERCING
	hit_type = DAMAGE_STAB
	//jam_mult = 2.2
	implanted = /obj/item/implant/projectile/bullet_pistol_juicer_ap
	dud_freq = 7
	fouling = 8

/datum/projectile/bullet/pistol/italian/derringer
	name = "bullet"
	shot_sound = 'sound/weapons/derringer.ogg'
	power = 120
	dissipation_delay = 1
	dissipation_rate = 50
	damage_type = D_PIERCING
	hit_type = DAMAGE_STAB
	hit_ground_chance = 100
	implanted = /obj/item/implant/projectile/bullet_pistol_italian_ap
	ks_ratio = 0.66
	caliber = CALIBER_TINY
	icon_turf_hit = "bhole"
	casing = /obj/item/casing/derringer
	dud_freq = 0

	on_hit(atom/hit)
		if(ismob(hit))
			var/mob/M = hit
			M.changeStatus("weakened", 2 SECONDS)
			M.force_laydown_standup()
		..()

/* ------------------------------- Rifle Shit ------------------------------- */

//Long rounds, still in 8mm
/datum/projectile/bullet/rifle
	name = "bullet"
	power = 30
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	caliber = CALIBER_LONG
	icon_turf_hit = "bhole"
	casing = /obj/item/casing/rifle

//NT long
/datum/projectile/bullet/rifle/NT
	power = 30
	implanted = /obj/item/implant/projectile/bullet_rifle_nt
	icon_turf_hit = null //also plastic, doesn't leave holes
	dud_freq = 1

/datum/projectile/bullet/rifle/NT/AP
	damage_type = D_PIERCING
	hit_type = DAMAGE_STAB
	icon_turf_hit = "bhole-small" // this one has enough oomph for a small hole
	implanted = /obj/item/implant/projectile/bullet_rifle_nt_ap
	dud_freq = 0

//Soviet long
/datum/projectile/bullet/rifle/soviet
	name = "bullet"
	//SemiAutoRifleShot.wav by SuperPhat -- https://freesound.org/s/421710/ -- License: Creative Commons 0
	shot_sound = 'sound/weapons/modular/soviet-sk58shot.ogg'
	power = 40
	implanted = /obj/item/implant/projectile/bullet_rifle_soviet
	dud_freq = 3
	fouling = 8

//slow rifle round, initially for AMS turret
/datum/projectile/bullet/rifle/soviet/slow
	projectile_speed = 20
	dissipation_delay = 1
	dissipation_rate = 4

/datum/projectile/bullet/rifle/soviet/AP
	damage_type = D_PIERCING
	hit_type = DAMAGE_STAB
	implanted = /obj/item/implant/projectile/bullet_rifle_soviet_ap
	dud_freq = 2

//Juicer BIG, this one is long AND wide
/datum/projectile/bullet/rifle/juicer
	name = "bullet"
	power = 60
	icon_state = "sniper_bullet"
	implanted = /obj/item/implant/projectile/bullet_rifle_juicer
	shot_sound = 'sound/weapons/railgun.ogg'
	dissipation_delay = 0
	dissipation_rate = 1
	projectile_speed = 72
	casing = /obj/item/casing/rifle_loud
	caliber = CALIBER_LONG_WIDE
	icon_turf_hit = "bhole-large"
	dud_freq = 10
	fouling = 8

	on_launch(obj/projectile/O)
		O.AddComponent(/datum/component/sniper_wallpierce, 2) //pierces 2 walls/lockers/doors/etc. Does not function on restriced Z, rwalls and blast doors use both pierces

	on_hit(atom/hit, dirflag, obj/projectile/P)
		if(isliving(hit))
			var/mob/living/L = hit
			if(power > 35)
#ifdef USE_STAMINA_DISORIENT
				L.do_disorient(75, weakened = 40, stunned = 40, disorient = 60, remove_stamina_below_zero = 0)
#else
				L.changeStatus("stunned", floor(power))
				L.changeStatus("weakened", floor(power * 0.75))
#endif
			if(power > 45)
				var/turf/target = get_edge_target_turf(L, dirflag)
				L.throw_at(target, 2, 3, throw_type = THROW_GUNIMPACT)
		..()

/datum/projectile/bullet/rifle/juicer/AP
	damage_type = D_PIERCING
	hit_type = DAMAGE_STAB
	implanted = /obj/item/implant/projectile/bullet_rifle_juicer_ap
	dud_freq = 15


/* ------------------------------ Shotgun Shit ------------------------------ */
//First up: Shot (Tiny projectiles fired from one cartridge, these are not the projectile fired from the gun, that ones a spreader)
/datum/projectile/bullet/shot
	name = "shot"
	sname = "shot"
	damage_type = D_KINETIC
	icon_turf_hit = "bhole-small"

//NT Shot
//small shot pellets generates by shotguns, meant to be fired as a group
//hard but biodegradable plastic
/datum/projectile/bullet/shot/NT
	icon_state = "trace"
	power = 4 //fired in a group of 10 (up to 40) with small spread
	dissipation_rate = 3
	dissipation_delay = 3
	hit_ground_chance = 50
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	icon_turf_hit = null
	implanted = null

/datum/projectile/bullet/shot/NT/mini //for maintenance pest control, fired in a group of 8 (up to 24)
	name = "ratshot"
	sname = "ratshot"
	power = 3
	dissipation_rate = 2.5
	hit_ground_chance = 75

//probably a lawgiver thing but we can adopt this into real separate shell
//fired as a single projectile
/datum/projectile/bullet/clownshot
	name = "clownshot"
	sname = "clownshot"
	power = 1
	cost = 15				//This should either cost a lot or a little I don't know. On one hand if it costs nothing you can truly tormet clowns with it, but on the other hand if it costs your full charge, then the clown will know how much you hate it because of how much you sacraficed to harm it. I settled for a med amount...
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	implanted = null
	shot_sound = 'sound/impact_sounds/Generic_Snap_1.ogg'
	icon_turf_hit = "bhole-staple"
	casing = null
	hit_ground_chance = 50
	icon_state = "random_thing"	//actually exists, looks funny enough to use as the projectile image for this
	dud_freq = 0
	fouling = 2

	on_hit(atom/hit, dirflag)
		if (ishuman(hit))
			var/mob/living/carbon/human/H = hit
			var/clown_tally = 0
			if(istype(H.w_uniform, /obj/item/clothing/under/misc/clown))
				clown_tally += 1
			if(istype(H.shoes, /obj/item/clothing/shoes/clown_shoes))
				clown_tally += 1
			if(istype(H.wear_mask, /obj/item/clothing/mask/clown_hat))
				clown_tally += 1
			if(clown_tally > 0)
				playsound(H, "sound/musical_instruments/Bikehorn_1.ogg", 50, 1)

			if (H.job == "Clown" || clown_tally >= 2)
				H.drop_from_slot(H.shoes)
				H.throw_at(get_offset_target_turf(H, rand(5)-rand(5), rand(5)-rand(5)), rand(2,4), 2, throw_type = THROW_GUNIMPACT)
				H.emote("twitch_v")
				JOB_XP(H, "Clown", 1)
		return
//FOSS Shot? EMP type stuff/utility shotgun? cryo slugs? etc.
//come back to this later

//Juicer Shot
/datum/projectile/bullet/shot/juicer
	name = "juicy buckshot"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	power = 9 //fired in group of 8 shots (max 72) with big spread
	ks_ratio = 1.0
	dissipation_delay = 2
	dissipation_rate = 8
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	icon_turf_hit = "bhole-small"
	hit_ground_chance = 60
	implanted = /obj/item/implant/projectile/shot_buck

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if (ishuman(hit))
			var/mob/living/carbon/human/H = hit
			if (H.organHolder)
				var/targetorgan = pick("left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix", "tail")
				H.organHolder.damage_organ(proj.power/H.get_ranged_protection(), 0, 0, prob(5) ? "heart" : targetorgan) //5% chance to hit the heart
			..()

/datum/projectile/bullet/shot/juicer/weak
	dud_freq = 3
	fouling = 3
	power = 6
	dissipation_rate = 5
	hit_ground_chance = 50

/datum/projectile/bullet/shot/juicer/denim
	power = 11 //fired in group of 8 shots (max 88) with some spread
	hit_ground_chance = 80 //dirty

		//on_hit override message to player: "J'ow!" "That really jurt!" etc.

/datum/projectile/bullet/shot/juicer/nail
	name = "nail"
	sname = "nail"
	icon_state = "trace"
	power = 4
	dissipation_rate = 3
	dissipation_delay = 6
	damage_type = D_SLASHING

/datum/projectile/bullet/shot/juicer/scrap
	name = "juicy scrap"
	icon_state = "buckshotscrap"
	power = 6 //fired in group of 6 shots (max 36) with some spread
	dissipation_delay = 4
	dissipation_rate = 4
	hit_ground_chance = 40

//bartender's round
//let's make this accurate, since mostly it's gonna be fired from snub barrel
/datum/projectile/bullet/shot/salt
	name = "rock salt"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	icon_state = "trace"
	power = 6 //in a narrow burst of 4 (max 24)
	ks_ratio = 1
	dissipation_rate = 1
	dissipation_delay = 2
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT

	on_hit(atom/hit, direction, obj/projectile/P)
		. = ..()
		if(isliving(hit))
			var/mob/living/L = hit
			if(!ON_COOLDOWN(L, "saltshot_scream", 1 SECOND))
				L.emote("scream")
			L.reagents.add_reagent("salt", P.power) //watch your sodium intake
			L.take_eye_damage(P.power / 2)
			L.change_eye_blurry(P.power, 40)
			L.setStatus("salted", 15 SECONDS, P.power * 2)

//Now slugs: imagine a shotgun shell but instead of a bunch of small balls it's one big bullet (just like irl)

/datum/projectile/bullet/slug
	name = "slug"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	power = 30
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	caliber = CALIBER_WIDE
	icon_turf_hit = "bhole"
	casing = /obj/item/casing/shotgun/red

//NT Slug cop round
/datum/projectile/bullet/slug/rubber
	name = "rubber slug"
	power = 30
	ks_ratio = 0.2
	dissipation_rate = 4
	dissipation_delay = 3
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	icon_turf_hit = "bhole"
	casing = /obj/item/casing/shotgun/blue
	dud_freq = 2

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		. = ..()
		if (isliving(hit))
			var/mob/living/L = hit
			if(proj.power >= 16)
				var/throw_range = (proj.power > 20) ? 5 : 3

				var/turf/target = get_edge_target_turf(L, dirflag)
				if(!L.stat) L.emote("scream")
				L.throw_at(target, throw_range, 1, throw_type = THROW_GUNIMPACT)
				L.update_canmove()
			L.changeStatus("staggered", clamp(proj.power/8, 5, 1) SECONDS)

/datum/projectile/bullet/slug/flare
	name = "flare"
	sname = "flare"
	shot_sound = 'sound/weapons/flaregun.ogg'
	power = 15
	damage_type = D_BURNING
	hit_type = null
	brightness = 1
	color_red = 1
	color_green = 0.4
	color_blue = 0.1
	icon_state = "flare"
	implanted = null
	icon_turf_hit = "bhole"
	casing = /obj/item/casing/shotgun/orange

	tick(var/obj/projectile/P)
		var/turf/T = get_turf(P)
		if (isturf(T) && !(locate(/obj/blob/reflective) in T))
			T.hotspot_expose(max(power*50,T20C), 5)
		return ..()

	on_hit(atom/hit, direction, obj/projectile/P)
		. = ..()
		if (isliving(hit))
			fireflash(get_turf(hit), 0)
			hit.changeStatus("staggered", clamp(P.power/8, 5, 1) SECONDS)
		else if (isturf(hit))
			fireflash(hit, 0)
		else
			fireflash(get_turf(hit), 0)

/datum/projectile/bullet/slug/flare/UFO
	name = "heat beam"
	window_pass = 1
	icon_state = "plasma"
	casing = null

//Juicer Explosive Slug
/datum/projectile/bullet/slug/boom
	name = "explosive slug"
	power = 15 // the damage should be more from the explosion
	ks_ratio = 1.0
	dissipation_delay = 6
	dissipation_rate = 10
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	icon_turf_hit = "bhole"
	casing = /obj/item/casing/shotgun/orange
	implanted = null
	dud_freq = 3
	fouling = 10

	on_hit(atom/hit)
		. = ..()
		explosion_new(null, get_turf(hit), 2)

	on_max_range_die(obj/projectile/O)
		. = ..()
		explosion_new(null, get_turf(O), 2)

//Some wacky icecube slug. let's call this FOSS, eventually
/datum/projectile/bullet/slug/cold
	name = "cryogenic slug"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	power = 10
	ks_ratio = 1
	dissipation_rate = 2
	dissipation_delay = 1
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	icon_turf_hit = null
	casing = /obj/item/casing/shotgun/blue

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		. = ..()
		if(isliving(hit))
			var/mob/living/L = hit
			L.bodytemperature = max(50, L.bodytemperature - proj.power * 5)
			var/obj/icecube/I = new/obj/icecube(get_turf(L), L)
			I.health = proj.power / 2

/* -------------------- Unusual, Makeshift, Utility (UMU) ------------------- */

/datum/projectile/bullet/tranq_dart
	name = "dart"
	power = 10
	icon = 'icons/obj/chemical.dmi'
	icon_state = "syringeproj"
	damage_type = D_TOXIC
	hit_type = DAMAGE_BLUNT
	implanted = null
	shot_sound = 'sound/effects/syringeproj.ogg'
	dissipation_delay = 10
	caliber = CALIBER_LONG
	reagent_payload = "haloperidol"
	casing = /obj/item/casing/rifle
	dud_freq = 2

	on_hit(atom/hit, dirflag)
		return

/datum/projectile/bullet/tranq_dart/syndicate
	reagent_payload = "sodium_thiopental"
	dud_freq = 0

/datum/projectile/bullet/tranq_dart/syndicate/pistol
	caliber = CALIBER_TINY
	casing = /obj/item/casing/small
	projectile_speed = 12
	shot_sound = 'sound/weapons/tranq_pistol.ogg'

/datum/projectile/bullet/tranq_dart/anti_mutant
	reagent_payload = "mutadone" // HAH

// REAL WEIRD NONSENSE

/datum/projectile/bullet/spike
	name = "spike"
	sname = "spike"
	icon_state = "spike"
	power = 7.2
	dissipation_rate = 1
	dissipation_delay = 45
	damage_type = D_KINETIC
	hit_type = DAMAGE_STAB
	shot_sound = null
	projectile_speed = 12
	implanted = null

/datum/projectile/bullet/staple
	name = "staple"
	power = 5
	damage_type = D_KINETIC // don't staple through armor
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/staple // HEH
	shot_sound = 'sound/impact_sounds/Generic_Snap_1.ogg'
	icon_turf_hit = "bhole-staple"
	casing = null

/datum/projectile/bullet/airzooka
	name = "airburst"
	shot_sound = 'sound/weapons/airzooka.ogg'
	power = 0
	ks_ratio = 1.0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "crescent_white"
	dissipation_delay = 15
	dissipation_rate = 2
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	icon_turf_hit = "bhole"
	implanted = null
	casing = null
	caliber = 4.6 // I rolled a dice
	cost = 1
	dud_freq = 0

	on_hit(atom/hit, dirflag)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit
			var/turf/target = get_edge_target_turf(M, dirflag)
			if(!M.stat) M.emote("scream")
			M.do_disorient(15, weakened = 10)
			M.throw_at(target, 6, 3, throw_type = THROW_GUNIMPACT)

/datum/projectile/bullet/airzooka/bad
	name = "plasmaburst"
	shot_sound = 'sound/weapons/airzooka.ogg'
	power = 15
	ks_ratio = 1.0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "40mmgatling"
	dissipation_delay = 15
	dissipation_rate = 4
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	icon_turf_hit = "bhole"
	implanted = null
	casing = null
	cost = 2

	on_hit(atom/hit, dirflag)
		fireflash(get_turf(hit), 1)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit
			var/turf/target = get_edge_target_turf(M, dirflag)
			if(!M.stat) M.emote("scream")
			M.do_disorient(15, weakened = 25)
			M.throw_at(target, 12, 3, throw_type = THROW_GUNIMPACT)

/datum/projectile/bullet/vbullet
	name = "virtual bullet"
	shot_sound = 'sound/weapons/Gunshot.ogg'
	power = 10
	cost = 1
	ks_ratio = 1.0
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = null
	casing = null
	icon_turf_hit = null

/* ----------------------- Automatic Weapons and Etc. ----------------------- */
/*
/datum/projectile/bullet/minigun
	name = "bullet"
	shot_sound = 'sound/weapons/minigunshot.ogg'
	power = 8
	cost = 10
	shot_number = 10
	shot_delay = 0.7
	dissipation_delay = 7
	ks_ratio = 1.0
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	caliber = 0.31
	icon_turf_hit = "bhole-small"
	implanted = /obj/item/implant/projectile/bullet_rifle_medium
	casing = /obj/item/casing/rifle
	dud_freq = 0

/datum/projectile/bullet/minigun/turret
	power = 15
	dissipation_delay = 8

/datum/projectile/bullet/lmg
	name = "bullet"
	sname = "8-shot burst"
	shot_sound = 'sound/weapons/minigunshot.ogg'
	power = 12
	cost = 8
	shot_number = 8
	shot_delay = 0.7
	dissipation_delay = 12
	ks_ratio = 1.0
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	caliber = 0.31
	icon_turf_hit = "bhole-small"
	implanted = /obj/item/implant/projectile/bullet_rifle_medium
	casing = /obj/item/casing/rifle
	var/slow = 1
	dud_freq = 0

	on_hit(atom/hit, direction, obj/projectile/P)
		if(slow && ishuman(hit))
			var/mob/living/carbon/human/M = hit
			M.changeStatus("slowed", 0.5 SECONDS)
			M.changeStatus("staggered", clamp(P.power/8, 5, 1) SECONDS)

	auto
		shot_volume = 66
		cost = 1
		shot_number = 1
		dud_freq = 0

/datum/projectile/bullet/lmg/weak
	power = 1
	cost = 2
	shot_number = 16
	shot_delay = 0.7
	dissipation_delay = 8
	silentshot = 1
	slow = 0
	implanted = null
	dud_freq = 0

/datum/projectile/bullet/rod // for the coilgun
	name = "metal rod"
	power = 50
	damage_type = D_KINETIC
	hit_type = DAMAGE_STAB
	window_pass = 0
	icon_state = "rod_1"
	dissipation_delay = 25
	caliber = 1.0
	shot_sound = 'sound/weapons/ACgun2.ogg'
	casing = null
	icon_turf_hit = "bhole-large"
	dud_freq = 0

	on_hit(atom/hit)
		explosion_new(null, get_turf(hit), 5)
*/
/* --------------- Grenades and Rockets and Explosives I Guess -------------- */

//kinda feel like not everything should be a bullet but what od i know i am just a head

/datum/projectile/bullet/shrapnel // for explosions
	name = "shrapnel"
	power = 10
	damage_type = D_PIERCING
	hit_type = DAMAGE_CUT
	window_pass = 0
	icon = 'icons/obj/scrap.dmi'
	icon_state = "2metal0"
	casing = null
	icon_turf_hit = "bhole-staple"
	dud_freq = 0

/datum/projectile/bullet/cannon // autocannon should probably be renamed next
	name = "cannon round"
	brightness = 0.7
	window_pass = 0
	icon_state = "20mmAPHE"
	damage_type = D_PIERCING
	hit_type = DAMAGE_CUT
	power = 150
	dissipation_delay = 1
	dissipation_rate = 5
	cost = 1
	shot_sound = 'sound/weapons/20mm.ogg'
	shot_volume = 130
	implanted = null
	dud_freq = 0

	ks_ratio = 1.0
	caliber = 0.787 //20mm
	icon_turf_hit = "bhole-large"
	casing = /obj/item/casing/cannon
	pierces = 4
	shot_sound_extrarange = 1

	on_launch(obj/projectile/proj)
		proj.AddComponent(/datum/component/sniper_wallpierce, 4) //pierces 4 walls/lockers/doors/etc. Does not function on restricted Z, rwalls and blast doors use 2 pierces
		for(var/mob/M in range(proj.loc, 5))
			shake_camera(M, 3, 8)

	on_hit(atom/hit, dirflag, obj/projectile/proj)

		..()

		SPAWN_DBG(0)
			//hit.setTexture()

			var/turf/T = get_turf(hit)
			new /obj/effects/rendersparks (T)
			var/impact = clamp(1,3, proj.pierces_left % 4)
			if(proj.pierces_left <= 1 )
				new /obj/effects/explosion/dangerous(T)
				new /obj/effects/explosion/dangerous(get_step(T, dirflag))
				new /obj/effects/explosion/dangerous(get_step(get_step(T, dirflag), dirflag))
				proj.die()
				return

			if(hit && ismob(hit))
				var/mob/living/M = hit
				var/throw_range = 10
				var/turf/target = get_edge_target_turf(M, dirflag)
				if(!M.stat)
					M.emote("scream")
				M.throw_at(target, throw_range, 2, throw_type = THROW_GUNIMPACT)

				if (ishuman(M) && M.organHolder)
					var/mob/living/carbon/human/H = M
					var/targetorgan
					for (var/i in 1 to 3)
						targetorgan = pick("left_lung", "heart", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix", "tail")
						H.organHolder.damage_organ(proj.power/H.get_ranged_protection(), 0, 0,  targetorgan)
				M.ex_act(impact)

			if(hit && isobj(hit))
				var/obj/O = hit
				O.throw_shrapnel(T, 1, 1)

				if(istype(hit, /obj/machinery/door))
					var/obj/machinery/door/D = hit
					if(!D.cant_emag)
						D.take_damage(D.health) //fuck up doors without needing ex_act(OLD_EX_TOTAL)

				else if(istype(hit, /obj/window))
					var/obj/window/W = hit
					W.smash()

				else
					O.ex_act(impact)

			if(hit && isturf(hit))
				T.throw_shrapnel(T, 1, 1)
				T.ex_act(OLD_EX_HEAVY)

/datum/projectile/bullet/autocannon
	name = "HE grenade"
	window_pass = 0
	icon_state = "40mmR"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	power = 25
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	ks_ratio = 1.0
	caliber = 1.57 // 40mm grenade shell
	icon_turf_hit = "bhole-large"
	casing = /obj/item/casing/grenade
	dud_freq = 0

	on_hit(atom/hit)
		explosion_new(null, get_turf(hit), 12)

	knocker
		name = "breaching round"
		power = 10
		on_hit(atom/hit)
			if(istype(hit , /obj/machinery/door))
				var/obj/machinery/door/D = hit
				if(!D.cant_emag)
					D.take_damage(D.health/2) //fuck up doors without needing ex_act(OLD_EX_TOTAL)
			explosion_new(null, get_turf(hit), 4, 1.75)

	plasma_orb
		name = "fusion orb"
		damage_type = D_BURNING
		hit_type = null
		icon_state = "fusionorb"
		implanted = null
		brightness = 0.8
		color_red = 1
		color_green = 0.6
		color_blue = 0.2
		power = 50
		shot_sound = 'sound/machines/engine_alert3.ogg'
		icon_turf_hit = null
		casing = null

	huge
		icon_state = "400mm"
		power = 100
		caliber = 15.7
		icon_turf_hit = "bhole-large"

		on_hit(atom/hit)
			explosion_new(null, get_turf(hit), 80)

	seeker
		name = "drone-seeking grenade"
		power = 50 //even if they don't explode, you FEEL this one
		var/max_turn_rate = 20
		var/type_to_seek = /obj/critter/gunbot/drone //what are we going to seek
		precalculated = 0
		disruption = INFINITY //distrupt every system at once
		on_hit(atom/hit, angle, var/obj/projectile/P)
			if (P.data)
				..()
			else
				new /obj/effects/rendersparks(hit.loc)
				if(ishuman(hit))//copypasted shamelessly from singbuster rockets
					var/mob/living/carbon/human/M = hit
					boutput(M, "<span class='alert'>You are struck by an autocannon round! Thankfully it was not armed.</span>")
					M.do_disorient(stunned = 40)
					if (!M.stat)
						M.emote("scream")


		on_launch(var/obj/projectile/P)
			var/D = locate(type_to_seek) in range(15, P)
			if (D)
				P.data = D

		tick(var/obj/projectile/P)
			if (!P)
				return
			if (!P.loc)
				return
			if (!P.data)
				return
			var/obj/D = P.data
			if (!istype(D))
				return
			var/turf/T = get_turf(D)
			var/turf/S = get_turf(P)

			if (!T || !S)
				return

			var/STx = T.x - S.x
			var/STy = T.y - S.y
			var/STlen = STx * STx + STy * STy
			if (!STlen)
				return
			STlen = sqrt(STlen)
			STx /= STlen
			STy /= STlen
			var/dot = STx * P.xo + STy * P.yo
			var/det = STx * P.yo - STy * P.xo
			var/sign = -1
			if (det <= 0)
				sign = 1

			var/relang = arccos(dot)
			P.rotateDirection(max(-max_turn_rate, min(max_turn_rate, sign * relang)))

		pod_seeking
			name = "pod-seeking grenade"
			type_to_seek = /obj/machinery/vehicle
			on_hit(atom/hit)
				. = ..()
				if(istype(hit, /obj/machinery/vehicle))
					var/obj/machinery/vehicle/V = hit
					V.health -= V.maxhealth / 4 //a little extra punch in the face

		ghost
			name = "pod-seeking grenade"
			type_to_seek = /mob/dead/observer

/datum/projectile/bullet/grenade_round
	name = "40mm round"
	window_pass = 0
	icon_state = "40mmR"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	power = 5
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/launcher.ogg'
	ks_ratio = 1.0
	caliber = 1.57
	icon_turf_hit = "bhole-large"
	casing = /obj/item/casing/grenade

	explosive
		name = "40mm HEDP round"

		on_hit(atom/hit)
			explosion_new(null, get_turf(hit), 2.5, 1.75)

	high_explosive //more powerful than HEDP
		name = "40mm HE round"
		power = 10

		on_hit(atom/hit)
			explosion_new(null,get_turf(hit), 8, 0.75)

// Ported from old, non-gun RPG-7 object class (Convair880).
/datum/projectile/bullet/rpg
	name = "MPRT rocket"
	window_pass = 0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "rpg_rocket"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	power = 40
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	ks_ratio = 1.0
	caliber = CALIBER_LONG_WIDE | CALIBER_SPUD
	icon_turf_hit = "bhole-large"
	dud_freq = 0

	on_end(var/obj/projectile/O)
		var/turf/T = get_turf(O)
		if (T)
			for (var/mob/living/carbon/human/M in view(4, T))
				M.TakeDamage("chest", 15/M.get_ranged_protection(), 0)
				if (M.get_ranged_protection()>=1.5)
					boutput(M, "<span class='alert'>Your armor blocks the shrapnel!</span>")
				else
					var/obj/item/implant/projectile/shrapnel/implanted = new /obj/item/implant/projectile/shrapnel(M)
					implanted.owner = M
					M.implant += implanted
					implanted.implanted(M, null, 2)
					boutput(M, "<span class='alert'>You are struck by shrapnel!</span>")
					if (!M.stat)
						M.emote("scream")

			T.hotspot_expose(700,125)
			explosion_new(null, T, 36, 0.45)
		return

/datum/projectile/bullet/smoke
	name = "smoke grenade"
	sname = "smokeshot"
	window_pass = 0
	icon_state = "40mmB"
	damage_type = D_KINETIC
	power = 25
	dissipation_delay = 10
	cost = 1
	shot_sound = 'sound/weapons/launcher.ogg'
	ks_ratio = 1.0
	caliber = 1.57 // 40mm grenade shell
	icon_turf_hit = "bhole-large"
	casing = /obj/item/casing/grenade
	implanted = null

	var/list/smokeLocs = list()
	var/smokeLength = 100

	proc/startSmoke(atom/hit, dirflag, atom/projectile)
		/*var/turf/trgloc = get_turf(projectile)
		var/list/affected = block(locate(trgloc.x - 3,trgloc.y - 3,trgloc.z), locate(trgloc.x + 3,trgloc.y + 3,trgloc.z))
		if(!affected.len) return
		var/list/centerview = view(world.view, trgloc)
		for(var/atom/A in affected)
			if(!(A in centerview)) continue
			var/obj/smokeDummy/D = new(A)
			smokeLocs.Add(D)
			SPAWN_DBG(smokeLength) qdel(D)
		particleMaster.SpawnSystem(new/datum/particleSystem/areaSmoke("#ffffff", smokeLength, trgloc))
		return*/

		// I'm so tired of overlays freezing my client, sorry. Get rid of the old smoke call here once
		// the performance and issues of full-screen overlays have been resolved, I guess (Convair880).
		var/turf/T = get_turf(projectile)
		if (T && isturf(T))
			var/datum/effects/system/bad_smoke_spread/S = new /datum/effects/system/bad_smoke_spread/(T)
			if (S)
				S.set_up(20, 0, T)
				S.start()
		return

	on_hit(atom/hit, dirflag, atom/projectile)
		startSmoke(hit, dirflag, projectile)
		return

/datum/projectile/bullet/marker
	name = "marker grenade"
	sname = "paint"
	window_pass = 0
	icon_state = "40mmR"
	damage_type = D_KINETIC
	power = 15
	dissipation_delay = 10
	cost = 1
	shot_sound = 'sound/weapons/launcher.ogg'
	ks_ratio = 1.0
	caliber = 1.57 // 40mm grenade shell
	icon_turf_hit = "bhole-large"
	casing = /obj/item/casing/grenade
	hit_type = DAMAGE_BLUNT
	hit_mob_sound = "sound/misc/splash_1.ogg"
	hit_object_sound = "sound/misc/splash_1.ogg"
	implanted = null

	on_hit(atom/hit, dirflag, atom/projectile)
		..()
		hit.setStatus("marker_painted", 30 SECONDS)

/datum/projectile/bullet/pbr //direct less-lethal 40mm option
	name = "plastic baton round"
	shot_sound = 'sound/weapons/launcher.ogg'
	power = 50
	ks_ratio = 0.5
	dissipation_rate = 5
	dissipation_delay = 4
	max_range = 9
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	caliber = 1.57
	icon_turf_hit = "bhole-large"
	casing = /obj/item/casing/grenade
	implanted = null

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if(proj.power >= 20)
				var/throw_range = (proj.power > 30) ? 5 : 3

				var/turf/target = get_edge_target_turf(M, dirflag)
				if(!M.stat) M.emote("scream")
				M.changeStatus("stunned", 1 SECONDS)
				M.changeStatus("weakened", 2 SECONDS)
				M.throw_at(target, throw_range, 1, throw_type = THROW_GUNIMPACT)
				M.update_canmove()
			hit.changeStatus("staggered", clamp(proj.power/8, 5, 1) SECONDS)
		if(!ismob(hit))
			shot_volume = 0
			var/obj/projectile/P = shoot_reflected_bounce(proj, hit, 1, PROJ_NO_HEADON_BOUNCE)
			shot_volume = 100
			if(P)
				P.travelled = max(proj.travelled, (max_range-2) * 32)

/datum/projectile/bullet/grenade_shell
	name = "40mm grenade conversion shell"
	window_pass = 0
	icon_state = "40mmR"
	damage_type = D_KINETIC
	power = 25
	dissipation_delay = 20
	cost = 1
	shot_sound = 'sound/weapons/launcher.ogg'
	ks_ratio = 1.0
	caliber = CALIBER_SPUD | CALIBER_WIDE // 40mm grenade shell
	icon_turf_hit = "bhole-large"
	casing = /obj/item/casing/grenade
	implanted = null

	var/has_grenade = 0
	var/obj/item/chem_grenade/CHEM = null
	var/obj/item/old_grenade/OLD = null
	var/has_det = 0 //have we detonated a grenade yet?

	proc/get_nade()
		RETURN_TYPE(/obj/item)
		if (src.has_grenade != 0)
			if (src.CHEM != null)
				return src.CHEM
			else if (src.OLD != null)
				return src.OLD
			else
				return null
		else
			return null

	proc/load_nade(var/obj/item/W)
		if (W)
			if (src.has_grenade == 0)
				if (istype(W,/obj/item/chem_grenade))
					src.CHEM = W
					src.has_grenade = 1
					return 1
				else if (istype(W, /obj/item/old_grenade))
					src.OLD = W
					src.has_grenade = 1
					return 1
				else
					return 0
			else
				return 0
		else
			return 0

	proc/unload_nade(var/turf/T)
		if (src.has_grenade !=0)
			if (src.CHEM != null)
				if (T)
					src.CHEM.set_loc(T)
				src.CHEM = null
				src.has_grenade = 0
				return 1
			else if (src.OLD != null)
				if (T)
					src.OLD.set_loc(T)
				src.OLD = null
				src.has_grenade = 0
				return 1
			else //how did this happen?
				return 0
		else
			return 0

	proc/det(var/turf/T)
		if (T && src.has_det == 0 && src.has_grenade != 0)
			if (src.CHEM != null)
				CHEM.set_loc(T)
				src.has_det = 1
				SPAWN_DBG(1 DECI SECOND)
					CHEM.explode()
				return
			else if (src.OLD != null)
				OLD.set_loc(T)
				src.has_det = 1
				SPAWN_DBG(1 DECI SECOND)
					OLD.prime()
				return
			else //what the hell happened
				return
		else
			return

	on_hit(atom/hit, angle, obj/projectile/O)
		var/turf/T = get_turf(hit)
		if (T)
			src.det(T)
		else if (O)
			var/turf/pT = get_turf(O)
			if (pT)
				src.det(pT)
		return ..()

	on_end(obj/projectile/O)
		if (O && src.has_det == 0)
			var/turf/T = get_turf(O)
			if (T)
				src.det(T)
		else if (O)
			src.has_det = 0

/datum/projectile/bullet/flak_chunk
	name = "flak chunk"
	sname = "flak chunk"
	icon_state = "trace"
	shot_sound = null
	power = 12
	dissipation_rate = 5
	dissipation_delay = 8
	damage_type = D_KINETIC
	dud_freq = 0

/datum/projectile/bullet/antisingularity
	name = "Singularity buster rocket"
	window_pass = 0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "antisingularity"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	power = 5
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	ks_ratio = 1.0
	caliber = CALIBER_SPUD | CALIBER_LONG_WIDE
	icon_turf_hit = "bhole-large"
	implanted = null
	dud_freq = 0

	on_hit(atom/hit)
		var/obj/machinery/the_singularity/S = hit
		if(istype(S))
			new /obj/bhole(S.loc,rand(100,300))
			qdel(S)
		else
			new /obj/effects/rendersparks(hit.loc)
			if(ishuman(hit))
				var/mob/living/carbon/human/M = hit
				M.TakeDamage("chest", 15/M.get_ranged_protection(), 0)
				boutput(M, "<span class='alert'>You are struck by a big rocket! Thankfully it was not the exploding kind.</span>")
				M.do_disorient(stunned = 40)
				if (!M.stat)
					M.emote("scream")

/datum/projectile/bullet/mininuke //Assday only.
	name = "miniature nuclear warhead"
	window_pass = 0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "mininuke"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	power = 120
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	ks_ratio = 1.0
	caliber = CALIBER_SPUD | CALIBER_LONG_WIDE
	icon_turf_hit = "bhole-large"
	implanted = null
	dud_freq = 0

	on_hit(atom/hit)
		var/turf/T = get_turf(hit)
		if (T)
			T.hotspot_expose(700,125)
			explosion_new(null, T, 300, 1)
		return

/* ----------------------- Specialized Or Really Olde ----------------------- */

/datum/projectile/bullet/flintlock
	name = "bullet"
	power = 100
	damage_type = D_PIERCING
	hit_type = DAMAGE_STAB
	implanted = /obj/item/implant/projectile/flintlock
	shot_sound = 'sound/weapons/flintlock.ogg'
	dissipation_delay = 10
	casing = null
	caliber = 0.58
	icon_turf_hit = "bhole-small"

	on_hit(atom/hit, dirflag)
		if(ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if(power > 40)
#ifdef USE_STAMINA_DISORIENT
				M.do_disorient(75, weakened = 40, stunned = 40, disorient = 60, remove_stamina_below_zero = 0)
#else
				M.changeStatus("stunned", 4 SECONDS)
				M.changeStatus("weakened", 3 SECONDS)
#endif
			if(power > 80)
				var/turf/target = get_edge_target_turf(M, dirflag)
				M.throw_at(target, 2, 2, throw_type = THROW_GUNIMPACT)
		..()


/datum/projectile/bullet/dueling //Where the magic of dueling happens
	name = "dueling round"
	sname = "dueling round"

	dissipation_delay = 20 //Basically you can shoot at one another anywhere on screen I guess
	power = 450 //die
	ks_ratio = 1 //die
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT //Don't want non-duelists to bleed profusely
	dud_freq = 0

	//Do 5 damage to non-duelists and full damage to duelists
	get_power(obj/projectile/P, atom/A)
		if (ismob(A))
			var/mob/victim = A
			if (victim.find_type_in_hand(/obj/item/gun/kinetic/dueling_pistol) || GET_COOLDOWN(victim, "duel_anticheat"))
				return ..()
		return 5

	///Dueling victims also get to bleed out dramatically
	on_hit(atom/hit, direction, obj/projectile/P)
		if (ismob(hit))
			var/mob/victim = hit
			if (victim.find_type_in_hand(/obj/item/gun/kinetic/dueling_pistol) || GET_COOLDOWN(victim, "duel_anticheat"))
				take_bleeding_damage(hit, null, 200, DAMAGE_STAB) // oh god no why was the first var set to src what was I thinking
		..()


/* ------------------------------- Silly Stuff ------------------------------ */

/datum/projectile/bullet/pistol/foamdart
	name = "foam dart"
	sname = "foam dart"
	icon_state = "foamdart"
	shot_sound = 'sound/effects/syringeproj.ogg'
	icon_turf_hit = null
	projectile_speed = 26
	implanted = null
	power = 0
	ks_ratio = 0
	damage_type = D_SPECIAL
	hit_type = DAMAGE_BLUNT
	max_range = 15
	dissipation_rate = 0
	ie_type = null
	dud_freq = 0

/datum/projectile/bullet/glitch
	name = "bullet"
	window_pass = 1
	icon_state = "glitchproj"
	damage_type = D_KINETIC
	hit_type = null
	power = 30
	dissipation_delay = 12
	cost = 1
	shot_sound = 'sound/effects/glitchshot.ogg'
	ks_ratio = 1.0
	casing = null
	icon_turf_hit = null
	dud_freq = 0

	New()
		..()
		src.name = pick("weird", "puzzling", "odd", "strange", "baffling", "creepy", "unusual", "confusing", "discombobulating") + " bullet"
		src.name = corruptText(src.name, 66)

	on_hit(atom/hit)
		hit.icon_state = pick(icon_states(hit.icon))

		for(var/atom/a in hit)
			a.icon_state = pick(icon_states(a.icon))

		playsound(hit, "sound/machines/glitch3.ogg", 50, 1)

/datum/projectile/bullet/glitch/gun
	power = 1

/datum/projectile/bullet/frog/ //sorry for making this, players -ZeWaka
	name = "green splat" //thanks aibm for wording this beautifully
	window_pass = 0
	icon_state = "acidspit"
	hit_type = null
	damage_type = 0
	power = 0
	dissipation_delay = 12
	sname = "Get In"
	shot_sound = 'sound/weapons/ribbit.ogg' //heh
	casing = null
	icon_turf_hit = null

	New()
		..()

	on_hit(atom/hit)
		hit.UpdateOverlays(image('icons/misc/frogs.dmi', "icon_state" = "getin"), "getin") //why did i code this

/datum/projectile/bullet/frog/getout
	sname = "Get Out"

	on_hit(atom/hit)
		hit.UpdateOverlays(image('icons/misc/frogs.dmi', "icon_state" = "getout"), "getout") //its like im trying to intentionally torture players

//we can have coilguns in TYOOL 2053, just not like that :)
/datum/projectile/bullet/coil
	name = "coil"
	icon_state = "coil"
	power = 25 //lowish damage, but easy to spray & pray
	shot_sound = 'sound/misc/boing/1.ogg' //comedy
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	//jam_mult = 1
	implanted = /obj/item/implant/projectile/coil
	casing = null
	icon_turf_hit = null
	dud_freq = 4
	max_range = 100
	dissipation_rate = 0.2 //slow to lose energy even with ricochets :3

	on_hit(atom/hit, direction, obj/projectile/P)
		if(!ismob(hit))
			if (!shoot_reflected_bounce(P, hit, 8, PROJ_RAPID_HEADON_BOUNCE))
				on_max_range_die(P)
		..()

	on_max_range_die(obj/projectile/O)
		new /obj/item/coil/small/(get_turf(O))
