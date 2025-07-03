// ITS WARC TIME BAYBEE
// f
// Moved these from BBSSS.dm to here because they're global and don't really give that much away (should they be global?)
var/johnbill_shuttle_fartnasium_active = 1
var/fartcount = 0
var/weadegrowne = 0
var/doinkssparked = 0
var/clownabuse = 0

/obj/death_button/immersive
	name = "Button that simulates the Coolstation Experience"
	desc = "A button which, if you press it, will fill you with the sense that you had a pretty good round."
	var/playing = 0
	attack_hand(mob/user)
		if(playing)
			return
		playing = 1
		playsound(src.loc, "sound/misc/TYOOL2053.ogg", 85, 1)
		SPAWN_DBG(17 SECONDS)
			playing = 0
			..()

/obj/build_time_monument
	name = "ancient monument"
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "grill_tablet"
	desc = "This thing's been pretty badly weathered... it's almost illegible."

	New()
		..()
		desc += " The only thing you can make out is the consecration date:<br><span style='color:green;'>Erected on this [BUILD_TIME_DAY]th day of the [BUILD_TIME_MONTH]th orbit, 2047, at pretty much exactly [BUILD_TIME_HOUR]:[BUILD_TIME_MINUTE]:[BUILD_TIME_SECOND].</span><br>That's disturbingly specific."

/area/diner/tug
	icon_state = "yellow"
	name = "Big Yank's Cheap Tug"

/area/diner/jucer_trader
	icon_state = "green"
	name = "Placeholder Paul's $STORE_NAME.shuttle"

/obj/item/clothing/head/paper_hat/john
	name = "John Bill's paper bus captain hat"
	desc = "This is made from someone's tax returns"

/obj/item/clothing/mask/cigarette/john
	name = "John Bill's cigarette"
	on = 1
	put_out(var/mob/user as mob, var/message as text)
		// how about we do literally nothing instead?
		// please stop doing the thing you keep doing.

/obj/decal/fakeobjects/surfer
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "surfer"
	name = "a piece of debris!"
	desc = "i think i've figured out a way!"


/obj/decal/fakeobjects/thrust
	icon = 'icons/effects/effects.dmi'
	icon_state = "sparkle_ions"
	name = "ionized exhaust"
	desc = "no longer harmless."

	Crossed(atom/movable/M)
		M.throw_at(get_step(src,dir),1,1)
		..()

/obj/decal/fakeobjects/thrust/flames
	icon_state = "engineshit"
	Crossed(atom/movable/M)
		if(ismob(M))
			var/mob/F = M
			F.TakeDamage("All",0,50)
		..()
/obj/decal/fakeobjects/thrust/flames2
	icon_state = "engineshit2"
	Crossed(atom/movable/M)
		if(ismob(M))
			var/mob/F = M
			F.TakeDamage("All",0,50)
		..()

/obj/item/paper/tug/invoice
	name = "Big Yank's Space Tugs, Limited."
	desc = "Looks like a bill of sale."
	info = {"<b>Client:</b> Bill, John
			<br><b>Date:</b> TBD
			<br><b>Articles:</b> Structure, Static. Pressurized. Single.
			<br><b>Destination:</b> \"where there's rocks at\"\[sic\]
			<br>
			<br><b>Total Charge:</b> 17,440 paid in full with value-added meat.
			<br>Big Yank's Cheap Tug"}

/obj/item/paper/tug/warehouse
	name = "Big Yank's Space Tugs, Limited."
	desc = "Looks like a bill of sale. It is blank"
	info = {"<b>Client:</b>
			<br><b>Date:</b>
			<br><b>Articles:</b>
			<br><b>Duration:</b>
			<br>
			<br><b>Total Charge:</b>
			<br>Big Yank's Stash N Dash"}

/obj/item/paper/tug/diner_arcade_invoice
    name = "Big Yank's Space Tugs, Limited."
    desc = "Looks like a bill of sale, slightly yellowed."
    info = {"<b>Client:</b> Bill, John
            <br><b>Date:</b> TBD
            <br><b>Articles:</b> Structure, Static. Pressurized. Duplex.
            <br><b>Destination:</b> \"jes' hook it up anywhere it fits\"\[sic\]
            <br>
            <br><b>Total Charge:</b> 9,233 paid in full with bootleg cigarillos.
            <br>Big Yank's Cheap Tug"}

/obj/item/paper/horizon/HTSL
	name = "crumpled note"
	interesting = "The carbon dating of the cellulose within the paper is not consistent."
	info = {"NSS Horizon Technical Service Log
			<br>Commission date 22 June 2047
			<br>Printing Shakedown Notes:
			<br>
			<br>With regards to the Horizon-class Hypercarrier, the following concerns were identified and addressed:
			<br>
			<br>Concern: Due to budgetary concerns, \[REDACTED] and mitigation efforts resulting unusual thermal flux, drastically increasing the odds of a runaway thermal \[REDACTED]
			<br>
			<br>Remedy: The NSS Horizon will not house critical Nanotrasen staff.
			<br>
			<br>Concern: Thermal cladding is both grossly insufficient and visibly in very poor repair, further exacerbating \[REDACTED] into a runaway thermal event, of possible \[REDACTED] and further collateral damage.
			<br>
			<br>Remedy: Cladding repainted; damaged cladding is no longer visible and will not affect employee morale
			<br>
			<br>Concern: Artificial Intelligence Core grossly insufficient for intra-\[REDACTED] navigation, sublight control necessary for all course changes.
			<br>
			<br>Remedy: A.I.C. relegated to door control and entertainment services.
			<br
			><br>Concern: Hull integrity tests inconclusive, all data lost when hull-mounted sensors were lost in testing breach. See personnel logs for subsequent staff rotation.
			<br>
			<br>No remedy suggested.
			<br>
			<br><span style='font-family: Dancing Script, cursive;'>You'd think they would have made this file easier to access, at least to the assholes refitting it. Stranded for six years, moored by failing engines, we've made do, but there's not much more we can do here. I've converted most of the Horizon Project bolt-ons to more civil amenities, got the port engine running well enough to keep life support on, but nearly everyone left here is either a grifter or a prisonner.
			<br>Never would have signed up for that mission if I knew what they were actually trying to do. Assholes.
			<br>
			<br>Got a call this morning that NT wants to recomission this heap of shit, as a research outpost. I spend six fucking years sending distress calls, and by 1800 hours, there's going to be a shuttle full of bright-faced convicts ready to make the Kuiper Belt teem with greed again. I'm sorry, but its a step too far. I won't be here to greet them.
			<br>
			<br>February 3rd, 2053</span>"}

/obj/item/paper/horizon/eggs
	name = "eggs"
	desc = "eggs"
	info = "legs"

/turf/wall/r_wall/afterbar
	name = "wall"
	desc = null
	attackby(obj/item/W as obj, mob/user as mob, params)
		return


/obj/critter/hauntdog
	name = "hauntdog"
	desc = "A very, <i>very</i> haunted hotdog. Hopping around. Hopdog."
	icon = 'icons/misc/hauntdog.dmi'
	icon_state = "hauntdog"
	death_text = null
	health = 30
	density = 0

	patrol_step()
		if (!mobile)
			return
		var/turf/moveto = locate(src.x + rand(-1,1),src.y + rand(-1, 1),src.z)

		if(isturf(moveto) && !moveto.density)
			flick("hauntdog-hop",src)
			step_towards(src, moveto)
		if(src.aggressive) seek_target()
		steps += 1
		if (steps == rand(5,20)) src.task = "thinking"

	ai_think()
		if(prob(5))
			flip()
		..()

	proc/flip()
		src.visible_message("<b>[src]</b> does a flip!",2)
		flick("hauntdog-flip",src)
		sleep(1.3 SECONDS)

	CritterDeath()
		if (!src.alive) return
		..()
		src.visible_message("<b>[src]</b> stops moving.",2)
		var/obj/item/reagent_containers/food/snacks/hotdog/H = new /obj/item/reagent_containers/food/snacks/hotdog(get_turf(src))

		H.bun = 5
		H.desc = "A very haunted hotdog. A hauntdog, perhaps."
		H.heal_amt += 1
		H.name = "ordinary hauntdog"
		H.food_effects = list("food_all","food_brute")
		if (H.reagents)
			H.reagents.add_reagent("ectoplasm", 10)
		H.update_icon()

		qdel(src)


// ########################
// # Horizon  audio  logs #
// ########################

/obj/item/device/audio_log/horizon_minorcollision
	continuous = 0
	audiolog_messages = list("Course stady, bearing One One Zero Mark Two,",
							"Firing thrusters.",
							"Steady hot stuff. Keep your eyes on the grav- wait a second.",
							"Uh, Captain- I- I don't-",
							"Shuttlecraft One to NSS Horizon abort maneuver! ABORT MANEUVER WE ARE NOT CLEA-",
							"*Thunderous scraping, metallic sound*",
							"Negative, Captain. Engines offline, there's some kind of well between *click*",
							"What. the fuck is that. *Creaking, static*")
	audiolog_speakers = list("Female voice",
							"Juvenile voice",
							"Female voice",
							"Juvenile voice",
							"Female voice",
							"???",
							"NSS Horizon",
							"???")


