// ITS WARC TIME BAYBEE
// f
// Moved these from BBSSS.dm to here because they're global and don't really give that much away (should they be global?)
var/johnbill_shuttle_fartnasium_active = 1
var/fartcount = 0
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

/obj/machinery/vending/sause // todo: make it slather sauce on stuff instead of selling loose sauce but this is funny anyway.
	name = "sause"
	desc = "looks normal."
	icon_state = "sauce"
	icon_panel = "standard-panel"
	icon_off = "monkey-off"
	icon_broken = "monkey-broken"
	icon_fallen = "monkey-fallen"
	pay = 1
	acceptcard = 0
	slogan_list = list("<span style=\"font-family:'Comic Sans MS', sans-serif; \">for they <span style=\"color:#0F0;\">HIGH ROLLERS</span> out there...... </span>",
	"<span style=\"font-family:'Comic Sans MS', sans-serif; \">get it on their. </span>",
	"<span style=\"font-family:'Comic Sans MS', sans-serif; color: yellow; \">exclusive, premiume <span style=\"color:brown;\">GOURMéT BARBEBEQUE SAUCE.</span></span>",
	"<span style=\"font-family:'Comic Sans MS', sans-serif; color:gold; \">CHRIST</span>",
	"<span style=\"font-family:'Comic Sans MS', sans-serif; \">INGREGIENTS: it`s is, 100% <span style=\"color:gold;\">SAUSCE!!</span></span>",
	"<span style=\"font-family:'Comic Sans MS', sans-serif; \">Cash Only.</span>")

	light_r = 0.9
	light_g = 0.6
	light_b = 0.1

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/ketchup, 5, cost=PAY_UNTRAINED/9)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/mayo, 5, cost=PAY_UNTRAINED/9)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/hotsauce, 5, cost=PAY_UNTRAINED/6)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/coldsauce, 5, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/cream, 5, cost=PAY_UNTRAINED/7)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/custard, 5, cost=PAY_UNTRAINED/7)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/butters, 5, cost=PAY_UNTRAINED/4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/syrup, 5, cost=PAY_UNTRAINED/4)
		product_list += new/datum/data/vending_product(/obj/item/shaker/mustard, 5, cost=PAY_UNTRAINED/3)
		product_list += new/datum/data/vending_product(/obj/item/shaker/ketchup, 5, cost=PAY_UNTRAINED/3)

/obj/machinery/vending/meat //MEAT VENDING MACHINE
	name = "Meat4cash"
	desc = "An exotic meat vendor."
	icon_state = "steak"
	icon_panel = "standard-panel"
	icon_off = "monkey-off"
	icon_broken = "monkey-broken"
	icon_fallen = "monkey-fallen"
	pay = 1
	acceptcard = 0
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
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/meatball, 5, cost=PAY_UNTRAINED/6)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meatpaste, 5, cost=PAY_UNTRAINED/7)

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat, 2, cost=PAY_UNTRAINED, hidden=1)




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
    desc = "Looks like a bill of sale."
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
		src.equip_new_if_possible(/obj/item/card/id/juicer/gene, slot_wear_id)
		if(prob(50))
			src.equip_new_if_possible(/obj/item/clothing/glasses/regular, slot_glasses)

/mob/living/carbon/human/gunsemanne
	is_npc = 1
	//uses_mobai = 1
	real_name = "Pingin' \"Grand\" Thum"
	gender = NEUTER
	max_health = 150
	var/obj/item/part_in_inventory = null
	var/price_expected = 0

	proc/appraise(obj/item/W, mob/M)
		M.u_equip(W)
		W.unequipped(M)
		W.dropped(M)
		W.set_loc(src)
		part_in_inventory = W

		if(istype(W, /obj/item/gun/modular))
			price_expected = 0
			var/obj/item/gun/modular/gun = W

			if(!gun.gun_DRM)
				src.say("This is already cracked, juicer. [pick("Gimme something else.","You easily startled?","You know the drill.","C'mon.","You alright?")]")
				part_in_inventory.set_loc(src.loc)
				W.throw_at(M.loc, 10, 2)
				part_in_inventory = null
				return
			else if(gun.gun_DRM & GUN_NANO)
				price_expected = rand(9,11)
				src.say("Nano tech's kind of tricky. [price_expected] Hundo. Non-negotiable.")
				price_expected *= 100

			else if(gun.gun_DRM & GUN_JUICE)
				price_expected = rand(200,300)
				src.say("Childs play. [price_expected] bucks.")

			else if(gun.gun_DRM & GUN_SOVIET)
				price_expected = rand(800,900)
				src.say("Oooh hoo, vintage communist gear. Not easy. [price_expected]?")

			else if(gun.gun_DRM & GUN_ITALIAN)
				price_expected = 100
				src.say("Christ these things basically crack themselves. One crisp double-zero.")

			else if(gun.gun_DRM & GUN_FOSS)
				price_expected = 1000
				src.say("Uhhhh... I mean, a thousand bucks will get you somewhere but I don't think you're getting that past security.")


		else if(istype(W, /obj/item/gun_parts))
			price_expected = 0
			var/obj/item/gun_parts/part = W

			if(!part.part_DRM)
				src.say("This is already cracked, juicer. [pick("Gimme something else.","You easily startled?","You know the drill.","C'mon.","You alright?")]")
				part_in_inventory.set_loc(src.loc)
				W.throw_at(M.loc, 10, 2)
				part_in_inventory = null
				return

			else if(part.part_DRM & GUN_FOSS)
				price_expected = 500
				src.say("At this point i'm not even gonna ask. Five hundred, no less.")

			else if(part.part_DRM & GUN_NANO)
				price_expected = 350
				src.say("Nanotrasen parts... ugh. Whatever, 350?")

			else if(part.part_DRM & GUN_SOVIET)
				price_expected = 250
				src.say("These things are getting scarce. Two-Fifty.")

			else if(part.part_DRM & GUN_JUICE)
				price_expected = 100
				src.say("These used to come unregistered, yknow. Hundred bucks.")


			else if(part.part_DRM & GUN_ITALIAN)
				price_expected = 100
				src.say("Not sure why you'd want that... but alright. Cool hundo.")



		else
			src.say("Uhhhh... I guess I can't read this. Call a coder. That's fucked.")
			return


	proc/crack_the_drm(mob/M)
		price_expected = 0
		if(!part_in_inventory)
			src.say("Uhhhh... I guess I lost it. Call a coder. That's fucked.")
			return
		else
			if(istype(part_in_inventory, /obj/item/gun/modular))
				var/obj/item/gun/modular/gun = part_in_inventory
				gun.gun_DRM = null

			if(istype(part_in_inventory, /obj/item/gun_parts))
				var/obj/item/gun_parts/part = part_in_inventory
				part.part_DRM = null

			src.say("aaaaaall right, there we go.")
			sleep(1 SECOND)
			part_in_inventory.set_loc(src.loc)
			part_in_inventory.throw_at(M.loc, 10, 2)
			part_in_inventory = null



	attack_hand(mob/M)
		if((M.a_intent == INTENT_HELP || M.a_intent == INTENT_DISARM) && part_in_inventory)
			src.say("Sure, it's yours after all.")
			part_in_inventory.set_loc(src.loc)
			part_in_inventory.throw_at(M.loc, 10, 2)
			part_in_inventory = null
			price_expected = 0
		else
			..()



	attackby(obj/item/W, mob/M)
		if(istype(W, /obj/item/gun/modular) || istype(W, /obj/item/gun_parts))
			if(price_expected && part_in_inventory)
				src.say("You gonna pay me first? You owe me [price_expected] bucks, or you can have [part_in_inventory] back.")
				return
			else
				appraise(W,M)
				return
		else if(istype(W, /obj/item/spacecash))
			var/obj/item/spacecash/dosh = W
			if(!price_expected)
				src.say("You making a donation? I didn't ask you for shit.")
				return
			else if(part_in_inventory && (dosh.amount >= price_expected))
				src.say("Right. [price_expected] septims, numbers filed.")
				dosh.change_stack_amount(0 - price_expected)
				SPAWN_DBG(2 SECONDS)
					crack_the_drm(M)
				return
		else
			..()

	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		. = ..()
		if(isdead(src))
			return

		src.ai.target = M
		src.ai.enabled = 1

	New()
		gender = pick(NEUTER,MALE,FEMALE,PLURAL)
		..()
		src.ai = new /datum/aiHolder/human/yank(src) // todo: replace this (its fine for now)
		src.equip_new_if_possible(/obj/item/clothing/shoes/swat/knight, slot_shoes)
		src.equip_new_if_possible(/obj/item/clothing/under/rank/det, slot_w_uniform)
		src.equip_new_if_possible(/obj/item/clothing/suit/armor/gunsemanne, slot_wear_suit)
		src.equip_new_if_possible(/obj/item/card/id/juicer/security, slot_wear_id)
		if(prob(50))
			src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses, slot_glasses)
		else
			src.equip_new_if_possible(/obj/item/clothing/glasses/nightvision, slot_glasses)

	initializeBioholder()
		. = ..()
		bioHolder.mobAppearance.customization_first = new /datum/customization_style/moustache/devil
		bioHolder.mobAppearance.customization_first_color = "#281400"
		bioHolder.mobAppearance.customization_second = new /datum/customization_style/hair/hairup/ponytail
		bioHolder.mobAppearance.customization_second_color = "#311800"
		bioHolder.mobAppearance.customization_third = new /datum/customization_style/beard/trampstains
		bioHolder.mobAppearance.customization_third_color = "#663300"
		bioHolder.age = 43
		bioHolder.bloodType = "M1"
		bioHolder.mobAppearance.gender = NEUTER
		bioHolder.mobAppearance.underwear = "briefs"
		bioHolder.mobAppearance.u_color = "#7aa668"
