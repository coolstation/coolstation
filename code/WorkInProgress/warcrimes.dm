// ITS WARC TIME BAYBEE
// f
// Moved these from BBSSS.dm to here because they're global and don't really give that much away (should they be global?)
var/johnbill_shuttle_fartnasium_active = 1
var/fartcount = 0

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



/area/diner/tug
	icon_state = "green"
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

/obj/item/clothing/shoes/thong
	name = "garbage flip-flops"
	desc = "These cheap sandals don't even look legal."
	icon_state = "thong"
	protective_temperature = 0
	permeability_coefficient = 1
	var/possible_names = list("sandals", "flip-flops", "thongs", "rubber slippers", "jandals", "slops", "chanclas")
	var/stapled = FALSE

	examine()
		. = ..()
		if(stapled)
			. += "Two thongs stapled together, to make a MEGA VELOCITY boomarang."
		else
			. += "These cheap [pick(possible_names)] don't even look legal."

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/staple_gun) && !stapled)
			stapled = TRUE
			boutput(user, "You staple the [src] together to create a mighty thongarang.")
			name = "thongarang"
			icon_state = "thongarang"
			throwforce = 5
			throw_range = 10
			throw_return = 1
		else
			..()

	setupProperties()
		..()
		setProperty("coldprot", 0)
		setProperty("heatprot", 0)
		setProperty("conductivity", 1)



/obj/machinery/vending/meat //MEAT VENDING MACHINE
	name = "Meat4cash"
	desc = "An exotic meat vendor."
	icon_state = "steak"
	icon_panel = "standard-panel"
	icon_off = "monkey-off"
	icon_broken = "monkey-broken"
	icon_fallen = "monkey-fallen"
	pay = 1
	acceptcard = 1
	slogan_list = list("It's meat you can buy!",
	"Trade your money for meat!",
	"Buy the meat! It's meat!",
	"Why not buy the meat?",
	"Please, please buy meat.")

	light_r = 0.9
	light_g = 0.1
	light_b = 0.1

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat, 10, cost=PAY_UNTRAINED/4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat, 10, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat, 20, cost=PAY_UNTRAINED/6)

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat, 2, cost=PAY_UNTRAINED, hidden=1)








obj/decal/fakeobjects/thrust
	icon = 'icons/effects/effects.dmi'
	icon_state = "sparkle_ions"
	name = "ionized exhaust"
	desc = "Thankfully harmless, to registered employees anyway."

obj/decal/fakeobjects/thrust/flames
	icon_state = "engineshit"
obj/decal/fakeobjects/thrust/flames2
	icon_state = "engineshit2"

obj/item/paper/tug/invoice
	name = "Big Yank's Space Tugs, Limited."
	desc = "Looks like a bill of sale."
	info = {"<b>Client:</b> Bill, John
			<br><b>Date:</b> TBD
			<br><b>Articles:</b> Structure, Static. Pressurized. Single.
			<br><b>Destination:</b> \"where there's rocks at\"\[sic\]
			<br>
			<br><b>Total Charge:</b> 17,440 paid in full with value-added meat.
			<br>Big Yank's Cheap Tug"}

obj/item/paper/tug/warehouse
	name = "Big Yank's Space Tugs, Limited."
	desc = "Looks like a bill of sale. It is blank"
	info = {"<b>Client:</b>
			<br><b>Date:</b>
			<br><b>Articles:</b>
			<br><b>Duration:</b>
			<br>
			<br><b>Total Charge:</b>
			<br>Big Yank's Stash N Dash"}

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


/*
Urs' Hauntdog critter
*/
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

/mob/living/critter/small_animal/pig/hogg
	name = "hogg vorbis"
	real_name = "hogg vorbis"
	desc = "the hogg vorbis."
	icon_state = "hogg"
	icon_state_dead = "pig-dead"
	density = 1
	speechverb_say = "screams!"
	speechverb_exclaim = "screams!"
	meat_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	name_the_meat = 0

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		if(act == "scream" && src.emote_check(voluntary, 50))
			var/turf/T = get_turf(src)
			var/hogg = pick("sound/voice/hagg_vorbis.ogg","sound/voice/hogg_vorbis.ogg","sound/voice/hogg_vorbis_the.ogg","sound/voice/hogg_vorbis_screams.ogg","sound/voice/hogg_with_scream.ogg","sound/voice/hoooagh2.ogg","sound/voice/hoooagh.ogg",)
			playsound(T, hogg, 60, 1, channel=VOLUME_CHANNEL_EMOTE)
			return "<span class='emote'><b>[src]</b> screeeams!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	on_pet(mob/user)
		if (..())
			return 1
		if (prob(ASS_JAM?50:25))
			var/turf/T = get_turf(src)
			src.visible_message("[src] screams![prob(5) ? " ...uh?" : null]",\
			"You screams!")
			var/hogg = pick("sound/voice/hagg_vorbis.ogg","sound/voice/hogg_vorbis.ogg","sound/voice/hogg_vorbis_the.ogg","sound/voice/hogg_vorbis_screams.ogg","sound/voice/hogg_with_scream.ogg","sound/voice/hoooagh2.ogg","sound/voice/hoooagh.ogg",)
			playsound(T, hogg, 60, 1)
			user.add_karma(1.5)

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


/mob/living/carbon/human/geneticist
	is_npc = 1
	uses_mobai = 1
	real_name = "Juicer Gene"
	gender = NEUTER
	max_health = 50

	New()
		..()
		src.ai = new /datum/aiHolder/human/geneticist(src)
		src.equip_new_if_possible(/obj/item/clothing/shoes/dress_shoes, slot_shoes)
		src.equip_new_if_possible(/obj/item/clothing/under/rank/geneticist, slot_w_uniform)
		src.equip_new_if_possible(/obj/item/clothing/suit/labcoat/pathology, slot_wear_suit)
		if(prob(50))
			src.equip_new_if_possible(/obj/item/clothing/glasses/regular, slot_glasses)
