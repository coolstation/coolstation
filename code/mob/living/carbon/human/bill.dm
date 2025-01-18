/*A FILE FOR BILLS AND BILL RELATED ANYTHINGS
doing this to declutter some of my files.
arguably making it worse, but thats friggin way she goes.

starting with SHITTY BILL
*/


//biker // cogwerks - bringing back the bikers for the diner, now less offensive

/// BILL SPEECH STUFF

#define BILL_PICK(WHAT) pick_string("shittybill.txt", WHAT)

/mob/living/carbon/human/biker
	real_name = "Shitty Bill"
	gender = MALE
	var/talk_prob = 5
	var/greeted_murray = 0

#ifdef TWITCH_BOT_ALLOWED
	max_health = 250

	/*
	proc/n()
		keys_changed(KEY_FORWARD, KEY_FORWARD)
		SPAWN_DBG(1 DECI SECOND)
			keys_changed(0,0xFFFF)
	proc/s()
		src.process_move(SOUTH)
	proc/e()
		src.process_move(KEY_FORWARD)
	proc/w()
		src.process_move(WEST)
	proc/nw()
		src.process_move(NORTHWEST)
	proc/sw()
		src.process_move(SOUTHWEST)
	proc/ne()
		keys_changed(KEY_FORWARD|KEY_RIGHT, KEY_FORWARD|KEY_RIGHT)
		SPAWN_DBG(1 DECI SECOND)
			keys_changed(0,KEY_FORWARD|KEY_BACKWARD|KEY_RIGHT|KEY_LEFT)
	proc/se()
		src.process_move(SOUTHEAST)
	*/
#endif


	New()
		..()
		START_TRACKING_CAT(TR_CAT_SHITTYBILLS)
		src.equip_new_if_possible(/obj/item/clothing/shoes/brown, slot_shoes)
		src.equip_new_if_possible(/obj/item/clothing/under/misc/head_of_security, slot_w_uniform)
		src.equip_new_if_possible(/obj/item/paper/postcard/owlery, slot_l_hand)
		//src.equip_new_if_possible(/obj/item/device/radio/headset/civilian, slot_ears)
		//src.equip_new_if_possible(/obj/item/clothing/suit, slot_wear_suit)
		//src.equip_new_if_possible(/obj/item/clothing/head/biker_cap, slot_head)

		var/obj/item/implant/access/infinite/shittybill/implant = new /obj/item/implant/access/infinite/shittybill(src)
		implant.implanted(src, src)
/*
		var/obj/item/power_stones/G = new /obj/item/power_stones/Gall
		G.set_loc(src)
		src.chest_item = G
		src.chest_item_sewn = 1
*/
	initializeBioholder()
		. = ..()
		bioHolder.mobAppearance.customization_second = new /datum/customization_style/beard/tramp
		bioHolder.mobAppearance.customization_third = new /datum/customization_style/beard/longbeard
		bioHolder.age = 62
		bioHolder.bloodType = "A-"
		bioHolder.mobAppearance.gender = "male"
		bioHolder.mobAppearance.underwear = "briefs"

	disposing()
		STOP_TRACKING_CAT(TR_CAT_SHITTYBILLS)
		..()

	// Shitty Bill always goes to the afterlife bar unless he has a client
	death(gibbed)
		..(gibbed)

		STOP_TRACKING_CAT(TR_CAT_SHITTYBILLS)

		if (!src.client && src.z != 2)
			var/turf/target_turf = pick(get_area_turfs(/area/afterlife/bar/barspawn))

			var/mob/living/carbon/human/biker/newbody = new()
			newbody.set_loc(target_turf)
			newbody.overlays += image('icons/misc/32x64.dmi',"halo")
			if(inafterlifebar(src))
				qdel(src)
			return
		else
			boutput(src, "<span class='bold notice'>Shitty Bill will try to respawn in roughly 3 minutes.</span>")
			src.become_ghost()
#ifdef TWITCH_BOT_ALLOWED
			src = null


			//FUCK I AM GOOG GOOD GOOD CODER
			SPAWN_DBG(50 SECONDS)
				if (!twitch_mob || !twitch_mob.client)
					for (var/client/C in clients)
						if (C.ckey == TWITCH_BOT_CKEY)
							twitch_mob = C.mob

				if (twitch_mob)
					boutput(twitch_mob, "<span class='bold notice'>Roughly 2 minutes left for respawn.</span>")



			SPAWN_DBG(100 SECONDS)
				if (!twitch_mob || !twitch_mob.client)
					for (var/client/C in clients)
						if (C.ckey == TWITCH_BOT_CKEY)
							twitch_mob = C.mob

				if (twitch_mob)
					boutput(twitch_mob, "<span class='bold notice'>Roughly 1 minute left for respawn.</span>")


			SPAWN_DBG(1500)
				if (!twitch_mob || !twitch_mob.client)
					for (var/client/C in clients)
						if (C.ckey == TWITCH_BOT_CKEY)
							twitch_mob = C.mob

				if (twitch_mob && isdead(twitch_mob))
					var/mob/living/carbon/human/biker/newbody =  = new(pick_landmark(LANDMARK_TWITCHY_BILL_RESPAWN, get_turf(twitch_mob)))

					if (newbody)
						twitch_mob.mind.transfer_to(newbody)
						if (locate(/obj/item/storage/toilet) in newbody.loc)
							newbody.visible_message("<b>[newbody]</b> crawls out of the toilet!")
						else if (locate(/obj/submachine/chef_oven) in newbody.loc)
							newbody.visible_message("<b>[newbody]</b> pops out of the oven!")
#endif

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

#ifdef TWITCH_BOT_ALLOWED
		if (IS_TWITCH_CONTROLLED(src))
			var/list/wins = list()
			wins = splittext(winget(src.client, null, "windows"), ";")
			for(var/x in wins)
				if (!TWITCH_BOT_AUTOCLOSE_BLOCK(x))
					src.Browse(null,"window=[x]")
					//src.Browse(null, "window=[x]")
#endif

		if(!src.stat && !src.client)
			if(target)
				if(isdead(target))
					target = null
				if(get_dist(src, target) > 1)
					step_to(src, target, 1)
				if(get_dist(src, target) <= 1 && !LinkBlocked(src.loc, target.loc))
					var/obj/item/W = src.equipped()
					if (!src.restrained())
						if(W)
							W.attack(target, src, ran_zone("chest"))
						else
							target.Attackhand(src)
			else if(ai_aggressive)
				a_intent = INTENT_HARM
				for(var/mob/M in oview(5, src))
					if(M == src)
						continue
					if(M.type == src.type)
						continue
					if(M.stat)
						continue
					// stop on first human mob
					if(ishuman(M))
						target = M
						break
					target = M
			if(src.canmove && prob(20) && isturf(src.loc))
				step(src, pick(NORTH, SOUTH, EAST, WEST))
			if(prob(2))
				SPAWN_DBG(0) emote(BILL_PICK("emotes"))

			if(prob(talk_prob))
				src.speak()

	proc/speak()
		SPAWN_DBG(0)

			var/obj/machinery/bot/guardbot/old/tourguide/murray = pick(by_type[/obj/machinery/bot/guardbot/old/tourguide])
			if (murray && get_dist(src,murray) > 7)
				murray = null
			if (istype(murray))
				if (!findtext(murray.name, "murray"))
					murray = null

			var/area/A = get_area(src)
			var/list/alive_mobs = list()
			var/list/dead_mobs = list()
			if (A.population && length(A.population))
				for(var/mob/living/M in oview(5,src))
					if(!isdead(M))
						alive_mobs += M
					else
						dead_mobs += M

			if(length(dead_mobs) && prob(60)) //SpyGuy for undefined var/len (what the heck)
				var/mob/M = pick(dead_mobs)
				say("[BILL_PICK("deadguy")] [M.name]...")
			else if (alive_mobs.len > 0)
				if (murray && !greeted_murray)
					greeted_murray = 1
					say("[BILL_PICK("greetings")] Murray! How's it [BILL_PICK("verbs")]?")
					SPAWN_DBG(rand(20,40))
						if (murray?.on && !murray.idle)
							murray.speak("Hi, Bill! It's [BILL_PICK("murraycompliment")] to see you again!")

				else
					var/mob/M = pick(alive_mobs)
					var/speech_type = rand(1,11)

					switch(speech_type)
						if(1)
							say("[BILL_PICK("greetings")] [M.name].")
							M.add_karma(2)

						if(2)
							say("[BILL_PICK("question")] you lookin' at, [BILL_PICK("insults")]?")

						if(3)
							say("You a [BILL_PICK("people")]?")

						if(4)
							say("[BILL_PICK("rude")], gimme yer [BILL_PICK("item")].")

						if(5)
							say("Got a light, [BILL_PICK("insults")]?")

						if(6)
							say("Nice [BILL_PICK("verbs")], [BILL_PICK("insults")].")

						if(7)
							say("Got any [BILL_PICK("drugs")]?")

						if(8)
							say("I ever tell you 'bout [BILL_PICK("stories")]?")

						if(9)
							say("You [BILL_PICK("verbs")]?")

						if(10)
							if (prob(50))
								say("Man, I sure miss [BILL_PICK("domiss")].")
							else
								say("Man, I sure don't miss [BILL_PICK("dontmiss")].")

						if(11)
							say("I think my [BILL_PICK("friends")] [BILL_PICK("friendsactions")].")
/* commenting out the bartender stuff because he aint around much. replacing with john bill retorts.
					if (prob(10))
						SPAWN_DBG(4 SECONDS)
							for (var/mob/living/carbon/human/npc/diner_bartender/BT in all_hearers(7, src))
								switch (speech_type)
									if (4)
										BT.say("Look in the machine, you bum.")
									if (7)
										BT.say("You ask that weirdo in the bathroom?")
									if (8)
										if (prob(2))
											BT.say("One of these days, you better. You always talkin' like you're gunna tell some grand story about that, and then you never do[pick("", ", you ass")].")
										else if (prob(6))
											BT.say("Nah, [src].")
										else
											BT.say("Yeah, [src], I remember that one.")
									if (9)
										if (prob(50))
											BT.say("Yeah, sometimes.")
										else
											BT.say("Nah.")
*/

					if (length(by_cat[TR_CAT_JOHNBILLS]) && prob(25))
						SPAWN_DBG(4 SECONDS)
							var/mob/living/carbon/human/john/MJ = pick(by_cat[TR_CAT_JOHNBILLS])
							switch (speech_type)
								if (4)
									MJ.say("You're a big boy now brud, find one yourself.")
								if (7)
									MJ.say("You still on that?")
								if (8)
									if (prob(2))
										MJ.say("Nuh uh, no way no how. You were still in diapers when that happenned- and I'd remember that! [pick("... I think?",".",", Probably...")]")
									else if (prob(6))
										MJ.say("Don't think ya did, [src].")
									else if (prob(50))
										MJ.say("Oh yeah, sure [src], I remember. I do.")
									else
										MJ.say("Sounds a lot like [pick_string("johnbill.txt", "stories")], doesn't it?")
								if (9)
									if (prob(30))
										MJ.say("Only once, in college, and I didn't inhale.")
									else
										MJ.say("Nah, I'd rather [pick_string("johnbill.txt", "verbs")].")
								else
									MJ.speak()


	attackby(obj/item/W, mob/M)
		if (istype(W, /obj/item/paper/tug/invoice))
			if(ON_COOLDOWN(src, "attackby_chatter", 3 SECONDS)) return
			boutput(M, "<span class='notice'><b>You show [W] to [src]</b> </span>")
			SPAWN_DBG(1 SECOND)
				say("Hard to believe, but I think my [BILL_PICK("friends")] would be proud to see it.")
			return
		if (istype(W, /obj/item/paper/postcard/owlery))
			if(ON_COOLDOWN(src, "attackby_chatter", 3 SECONDS)) return
			boutput(M, "<span class='notice'><b>You show [W] to [src]</b> </span>")
			SPAWN_DBG(1 SECOND)
				say("Yep, can't wait to go on that trip! That [pick_string("johnbill.txt", "insults")] oughta be here soon!")
			return

		..()



	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		. = ..()
		if (special) //vamp or ling
			src.target = M
			src.ai_state = AI_ATTACKING
			src.ai_threatened = world.timeofday
			src.ai_target = M
			src.a_intent = INTENT_HARM
			src.ai_set_active(1)

		for (var/mob/JB in by_cat[TR_CAT_JOHNBILLS])
			var/mob/living/carbon/human/john/J = JB
			if (get_dist(J,src) <= 7)
				if((!J.ai_active) || prob(25))
					J.say("That's my brother, you [pick_string("johnbill.txt", "insults")]!")
					M.add_karma(-1)
				J.target = M
				J.ai_set_active(1)
				J.a_intent = INTENT_HARM

// and now JOHN BILL and his stuff

// all of john's area specific lines here
/area/var/john_talk = null
/area/owlery/owleryhall/john_talk = list("Oh dang, That's me! Wait... Oh dang guys, I think I'm banned from here.","Hope these guys don't mind I stole their bus.","Oh i've seen a scanner like that before. Lotta radiation.","Hey that thing there? Looks important.")
/area/owlery/owleryhall/gangzone/john_talk = list("I don't likesa the looksa these Italians, brud","That's some tough lookin boids- We cool?","Oughta grill a couple of these types. Grill em well done.")
/area/diner/dining/john_talk = list("This place smells a lot like my bro.","This was a good spot to park the bus.","Y'all got a grill in here?","Could do a lot of crimes back there. Probably will.")
/area/diner/bathroom/john_talk = list("I haven't been here in a foggy second!", "I wonder what the fungus on the walls here tastes like... wanna juice it?", "I always wondered what happened to this toilet.")
/area/diner/motel/john_talk = list("Ain't much to look at, but we got the hull for this section pretty cheap!","Uh, don't bother with room 3- it's a little uh... rough.","Mmmm Mmm still smells like salvage.")
/area/diner/motel/observatory/john_talk = list("What a goddamn view.","Never thought I'd have a place like this.")
/area/diner/motel/pool/john_talk = list("Hey brungo, got any water? Like ten to twenty tonnes, eh?","It's a shame I can't swim, on account of the pirate's code.","I've seen this place in a video.")
/area/diner/motel/chemstorage/john_talk = list("Good a time as any to learn chemistry, I guess.","Think I can sell any of this juice?")
/area/upper_arctic/exterior/surface/john_talk = list("Aw damn, isn't this the place where that... that fuckin', uh, Denmarkish guy ended up?","Chilly eh?","Woah that's cold!")
/area/upper_arctic/fita/lobby/john_talk = list("A concrete bunker? They're really committed to the bit.")
/area/moon/museum/west/john_talk = list("Got lost here once. More than once. Every time.","You got a map, beardo?","Can we go home yet?")
/area/jones/bar/john_talk = list("When the heck am I gonna get some service here, I'm parched!","What do I gotta start purrin' to get a drink here?","What's the holdup, catscratch? Let's get this party started!")
/area/solarium/john_talk = list("You kids will try anything, wontcha?","Nice sun, dorkus.","So it's a star? Big deal.","I betcha my bus coulda got us here faster, dork.","All righty, now let's grill a steak on that thing!","You bring any snacks?")
/area/marsoutpost/john_talk= list("Things weren't this dry last time I was here.","Really let the place go to the rats didn't they.","Great place for a cookout, if you ask me.")
/area/marsoutpost/duststorm/john_talk= list("Aw fuck, I've seen storms like this before. Where the hell was that planet...","Gehenna awaits.")
/area/sim/racing_entry/john_talk = list("Haha I'm a Nintendo","Beep Boop","Lookit Ma'! I'm in the computer!","Ey cheggit out! Pixels!")
/area/crypt/sigma/mainhall/john_talk = list("Looks a heck a spooky in here","Wonder if there's any meat in that swamp?")
/area/iomoon/base/john_talk = list("Yknow, I think it's almost too hot to grill out there.","This place is a lot shittier than Mars, y'know that?","I didn't really wanna come along you know. I did this for you.")
/area/dojo/john_talk = list("Eyyy, just like my cartoons!","What a sight! Gotta admire the Italians, eh?")
/area/dojo/sakura/john_talk = list("Shoshun mazu, Sake ni ume uru, Nioi kana","Haru moya ya, Keshiki totonou, Tsuki to ume","Hana no kumo, Kane ha Ueno ka, Asakusa ka")
/area/meat_derelict/entry/john_talk = list("Oooh baby now we're talkin! Now we're talkin!","Oh heck yeah now that's my kind of adventure, eh?","Oh boy do I have a good feelin' about this one!")
/area/meat_derelict/main/john_talk = list("Aw yeah dog, this place just gets better and better!","Mmm Mmm! That smells fresh and ready for a grillin'!")
/area/meat_derelict/guts/john_talk = list("And just when I thought it couldnt get better.","Pinch me, I'm dreaming!","Smells good in here, like vinegar!")
/area/meat_derelict/boss/john_talk = list("I'm gonna need a bigger grill.","Fuck that's a big steak!","Oooh mama we are cooked now!")
/area/meat_derelict/soviet/john_talk = list("Betcha these rooskies don't even own a grill","Wonder what these reds are doin in my steak palace?","Ah, gotta debone that before ya cook it.")
/area/bee_trader/john_talk = list("That little Bee, always gettin' inta trouble.","Hey remember that weird puzzle with the showerheads?","What a nasty museum that was, eh? Nasty.")
/area/flock_trader/john_talk = list("Woah, what's with these teal chickens? Must be good grillin'.","I feel like this was revealed to me in a fever dream once.","Dang, that's a mighty fine chair.")
/area/timewarp/ship/john_talk = list("I wonder if my ol' compadre Murray is around.","Did ya see those clocks outside? Time just flies by.","I swear I saw a ship just like this years ago, but somewhere else.","Didn't they use to haul some strange stuff on these gals?")
/area/derelict_ai_sat/core/john_talk = list("Hello, Daddy.","You should probably start writing down the shit I say, I certainly can't remember any of it.")




// bus driver
/mob/living/carbon/human/john
	real_name = "John Bill"
	interesting = "Found in a coffee can at age fifteen. Went to jail for fraud. Recently returned to the can."
	gender = MALE
	var/talk_prob = 7
	var/greeted_murray = 0
	var/list/snacks = null
	var/gotsmokes = 0
	var/nude = 0

	nude
		nude = 1

	New()
		..()
		START_TRACKING_CAT(TR_CAT_JOHNBILLS)
		if(nude)
			return
		src.equip_new_if_possible(/obj/item/clothing/shoes/thong, slot_shoes)
		src.equip_new_if_possible(/obj/item/clothing/under/color/orange, slot_w_uniform)
		src.equip_new_if_possible(/obj/item/clothing/mask/cigarette/john, slot_wear_mask)
		src.equip_new_if_possible(/obj/item/clothing/suit/labcoat, slot_wear_suit)
		src.equip_new_if_possible(/obj/item/clothing/head/paper_hat/john, slot_head)
		src.equip_new_if_possible(/obj/item/card/id/juicer/john, slot_wear_id)

		var/obj/item/implant/access/infinite/shittybill/implant = new /obj/item/implant/access/infinite/shittybill(src)
		implant.implanted(src, src)
		traitHolder.addTrait("italian")

	disposing()
		STOP_TRACKING_CAT(TR_CAT_JOHNBILLS)
		..()

	initializeBioholder()
		bioHolder.mobAppearance.customization_first = new /datum/customization_style/beard/tramp
		bioHolder.mobAppearance.customization_first_color = "#281400"
		bioHolder.mobAppearance.customization_second = new /datum/customization_style/hair/short/pomp
		bioHolder.mobAppearance.customization_second_color = "#241200"
		bioHolder.mobAppearance.customization_third = new /datum/customization_style/beard/trampstains
		bioHolder.mobAppearance.customization_third_color = "#663300"
		bioHolder.age = 63
		bioHolder.bloodType = "A+"
		bioHolder.mobAppearance.gender = "male"
		bioHolder.mobAppearance.underwear = "briefs"
		bioHolder.mobAppearance.u_color = "#996633"
		. = ..()

	// John Bill always goes to the afterlife bar.
	death(gibbed)
		..(gibbed)

		STOP_TRACKING_CAT(TR_CAT_JOHNBILLS)

		if (!src.client)
			var/turf/target_turf = pick(get_area_turfs(/area/afterlife/bar/barspawn))

			var/mob/living/carbon/human/john/newbody = new()
			newbody.set_loc(target_turf)
			newbody.overlays += image('icons/misc/32x64.dmi',"halo")
			if(inafterlifebar(src))
				qdel(src)
			return
		else
			boutput(src, "<span class='bold notice'>Haha you died loser.</span>")
			src.become_ghost()

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		if(!src.stat && !src.client)
			if(target)
				if(isdead(target))
					target = null
				if(get_dist(src, target) > 1)
					step_to(src, target, 1)
				if(get_dist(src, target) <= 1 && !LinkBlocked(src.loc, target.loc))
					var/obj/item/W = src.equipped()
					if (!src.restrained())
						if(W)
							W.attack(target, src, ran_zone("chest"))
						else
							target.Attackhand(src)
			else if(ai_aggressive)
				a_intent = INTENT_HARM
				for(var/mob/M in oview(5, src))
					if(M == src)
						continue
					if(M.type == src.type)
						continue
					if(M.stat)
						continue
					// stop on first human mob
					if(ishuman(M))
						target = M
						break
					target = M
			if(prob(20) && src.canmove && isturf(src.loc))
				step(src, pick(NORTH, SOUTH, EAST, WEST))
			if(prob(2))
				SPAWN_DBG(0) emote(JOHN_PICK("emotes"))
			if(prob(15))
				snacktime()
			var/area/A = get_area(src)
			if(prob(talk_prob) || A?.john_talk)
				src.speak()

	proc/snacktime()
		snacks = list()
		for(var/obj/item/reagent_containers/food/snacks/S in src)
			snacks += S
		if(snacks.len > 0)
			var/obj/item/reagent_containers/food/snacks/snacc = pick(snacks)
			if(istype(snacc, /obj/item/reagent_containers/food/snacks/bite))
				if(prob(75))
					return
				else
					src.visible_message("<span class='alert'>[src] horks up a lump from his stomach... </span>")
			snacc.Eat(src,src,1)

	proc/pacify()
		src.a_intent = INTENT_HELP
		src.target = null
		src.ai_state = 0
		src.ai_target = null

	proc/speak()
		if(nude)
			return // nude john is for looking at, not listening to.
		SPAWN_DBG(0)
			var/list/grills = list()

			var/obj/machinery/bot/guardbot/old/tourguide/murray = pick(by_type[/obj/machinery/bot/guardbot/old/tourguide])
			if (murray && get_dist(src,murray) > 7)
				murray = null
			if (istype(murray))
				if (!findtext(murray.name, "murraycompliment"))
					murray = null

			var/area/A = get_area(src)
			var/list/alive_mobs = list()
			var/list/dead_mobs = list()
			if (A && A.population && length(A.population))
				for(var/mob/living/M in oview(5,src))
					if(!isdead(M))
						alive_mobs += M
					else
						dead_mobs += M

			if (prob(20))
				for(var/obj/machinery/shitty_grill/G in orange(5, src))
					grills.Add(G)

			if (A.john_talk && prob(90))
				SPAWN_DBG(5 SECONDS)
					var/area/john_area = get_area(src)
					say(pick(john_area.john_talk))
					john_area.john_talk = null

			else if (grills.len > 0)
				var/obj/machinery/shitty_grill/G = pick(grills)
				if (G.grillitem)
					switch(G.cooktime)
						if (0 to 15)
							say("Yep, \the [G.grillitem] needs a little more time.")
						if (16 to 49)
							say("[JOHN_PICK("rude")], [JOHN_PICK("grilladvice")] [G.grillitem].")
						if (50 to 59)
							say("Whoa! \The [G.grillitem] is cooked to perfection! Lemme get that for ya!")
							G.eject_food()
						else
							say("Good fuckin' job [JOHN_PICK("insults")], you burnt it.")
				else
					if (G.grilltemp >= 200 + T0C)
						if(prob(70))
							say("That there ol' [G] looks about ready for a [JOHN_PICK("drugs")]-seasoned steak!")
						else
							say("That [G] is hot! Who's grillin' ?")
					else
						say("Anyone gonna fire up \the [G]?")

			else if(prob(40) && length(dead_mobs))
				var/mob/M = pick(dead_mobs)
				if(M.traitHolder.hasTrait("italian"))
					say("Ciao bella, paisan... bella ciao.")
				else
					say("[JOHN_PICK("deadguy")] [M.name]...")
			else if (alive_mobs.len > 0)
				if (murray && !greeted_murray)
					greeted_murray = 1
					say("[JOHN_PICK("greetings")] Murray! How's it [JOHN_PICK("verbs")]?")
					SPAWN_DBG(rand(20,40))
						if (murray?.on && !murray.idle)
							murray.speak("Hi, John! It's [JOHN_PICK("murraycompliment")] to see you here, of all places.")

				else
					var/mob/M = pick(alive_mobs)
					var/speech_type = rand(1,11)

					switch(speech_type)
						if(1)
							say("[JOHN_PICK("greetings")] [M.name].")
							M.add_karma(2)

						if(2)
							say("[JOHN_PICK("question")] you lookin' at, [JOHN_PICK("insults")]?")

						if(3)
							say("You a [JOHN_PICK("people")]?")

						if(4)
							say("[JOHN_PICK("rude")], gimme yer [JOHN_PICK("item")].")

						if(5)
							say("Got a light, [JOHN_PICK("insults")]?")

						if(6)
							say("Nice [JOHN_PICK("nouns")], [JOHN_PICK("insults")].")

						if(7)
							say("Got any [JOHN_PICK("drugs")]?")

						if(8)
							say("I ever tell you 'bout [JOHN_PICK("stories")]?")

						if(9)
							say("You [JOHN_PICK("verbs")]?")

						if(10)
							if (prob(50))
								say("Man, I sure miss [JOHN_PICK("domiss")].")
							else
								say("Man, I sure don't miss [JOHN_PICK("dontmiss")].")

						if(11)
							say("I think my [JOHN_PICK("friends")] [JOHN_PICK("friendsactions")].")

					if (prob(25) && length(by_cat[TR_CAT_SHITTYBILLS]))
						SPAWN_DBG(3.5 SECONDS)
							var/mob/living/carbon/human/biker/MB = pick(by_cat[TR_CAT_SHITTYBILLS])
							switch (speech_type)
								if (4)
									MB.say("You borrowed mine fifty years ago, and I never got it back.")
								if (7)
									MB.say("If I had any, I wouldn't share it with ya [pick_string("shittybill.txt", "insults")].")
								if (8)
									if (prob(2))
										MB.say("One of these days, you oughta. I don't believe it for a second but let's hear it, [pick_string("shittybill.txt", "people")].")
									else if (prob(6))
										MB.say("No way, [src].")
									else
										MB.say("Yeah, [src], you told me that one before.")
								if (9)
									if (prob(50))
										MB.say("Yeah, sometimes.")
									else
										MB.say("No way.")
								else
									MB.speak()



	attackby(obj/item/W, mob/M)
		if (istype(W, /obj/item/paper/tug/invoice))
			if(ON_COOLDOWN(src, "attackby_chatter", 3 SECONDS)) return
			boutput(M, "<span class='notice'><b>You show [W] to [src]</b> </span>")
			SPAWN_DBG(1 SECOND)
				say("One of them [JOHN_PICK("people")] folks from the station helped us raise the cash. Lil bro been dreamin bout it fer years.")
			return
		#ifdef SECRETS_ENABLED
		if (istype(W, /obj/item/paper/grillnasium/fartnasium_recruitment))
			if(ON_COOLDOWN(src, "attackby_chatter", 3 SECONDS)) return
			boutput(M, "<span class='notice'><b>You show [W] to [src]</b> </span>")
			SPAWN_DBG(1 SECOND)
				say("Well hot dog! [JOHN_PICK("insults")], you wouldn't believe it but I use to work there!")
				johnbill_shuttle_fartnasium_active = 1
				sleep(2 SECONDS)
				say("Yer dag right we can go Juicin around in there! Pack yer shit we're doin a B&E ! ! ! ")
				emote("dance")
			return
		#endif
		if (istype(W, /obj/item/reagent_containers/food/snacks) || (istype(W, /obj/item/clothing/mask/cigarette/cigarillo) && !gotsmokes))
			if(ON_COOLDOWN(src, "attackby_chatter", 3 SECONDS)) return
			boutput(M, "<span class='notice'><b>You offer [W] to [src]</b> </span>")
			M.u_equip(W)
			W.set_loc(src)
			W.dropped()
			src.drop_item()
			src.put_in_hand_or_drop(W)

			SPAWN_DBG(1 DECI SECOND)
				say("Oh? [W] eh?")
				say(pick("No kiddin' fer me?","I guess I could go fer a quick one yeah!","Oh dang dang dang! Haven't had one of these babies in a while!","Well I never get tired of those!","You're offering this to me? Don't mind if i do, [JOHN_PICK("people")]"))
				pacify()

				if (istype(W, /obj/item/clothing/mask/cigarette/cigarillo/juicer))
					gotsmokes = 1
					sleep(3 SECONDS)
					say(pick("Listen bud, I don't know who sold you these, but they ain't your pal.","Y'know these ain't legal in any NT facilities, right?","Maybe you ain't so dumb as ya look, brud."))
					var/obj/item/clothing/mask/cigarette/cigarillo/juicer/J = W
					src.u_equip(wear_mask)
					src.equip_if_possible(J, slot_wear_mask)
					J.cant_other_remove = 0
					sleep(3 SECONDS)
					J.light(src, "<span class='alert'><b>[src]</b> casually lights [J] and takes a long draw.</span>")
					sleep(5 SECONDS)
#if BUILD_TIME_DAY >= 28 // this block controls whether or not it is the right time to smoke a fat doink with Big J
					say("You know a little more than you let on, don't you?")
					sleep(7 SECONDS)
					say("See but I been away long enough that I don't know much about you.")
					emote("cough")
					sleep(15 SECONDS)
					particleMaster.SpawnSystem(new /datum/particleSystem/blow_cig_smoke(src.loc, src.dir))
					say("Other than you 'trasies really did me and my bro a solid, back when there was that whole business with the bee n' all that. A real solid. But by now you're wonderin' why we were involved with her anyhow.")
					sleep(7 SECONDS)
					say("All in due time.")
					emote("cough")
					sleep(9 SECONDS)
					J.put_out(src, "<b>[src]</b> distractedly drops and treads on the lit [J.name], putting it out instantly.")
					src.u_equip(J)
					J.set_loc(src.loc)
					sleep(2 SECONDS)
					say("These just don't taste the same without him...")
#else // it is not time
					say(pick("This ain't the time, but we should have a talk. A long talk.","Under better circumstances, I'd like to smoke a few of these and reminesce with ya.","We'll have to do this again some time. When the time is right."))
#endif
					gotsmokes = 0

				else if(istype(W, /obj/item/clothing/mask/cigarette))
					say(pick("Well this ain't my usual brand, but...", "Oh actually, got any... uh nah you've probably never even seen one of those.","Wait a second, this ain't a real 'Rillo."))
					var/obj/item/clothing/mask/cigarette/cig = W
					src.u_equip(wear_mask)
					src.equip_if_possible(cig, slot_wear_mask)
					sleep(3 SECONDS)
					cig.light(src, "<span class='alert'><b>[src]</b> cautiously lights [cig] and takes a short draw.</span>")
					sleep(5 SECONDS)
					say(pick("Yeah that's ol' Dan's stuff...","But hey, thanks for the smokes, bruddo.","Smooth. Too smooth."))
			return
		..()

	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		. = ..()
		if (special) //vamp or ling
			src.target = M
			src.ai_state = AI_ATTACKING
			src.ai_threatened = world.timeofday
			src.ai_target = M
			src.a_intent = INTENT_HARM
			src.ai_set_active(1)

		for (var/mob/SB in by_cat[TR_CAT_SHITTYBILLS])
			var/mob/living/carbon/human/biker/S = SB
			if (get_dist(S,src) <= 7)
				if(!(S.ai_active) || (prob(25)))
					S.say("That's my brother, you [JOHN_PICK("insults")]!")
					M.add_karma(-1)
				S.target = M
				S.ai_set_active(1)
				S.a_intent = INTENT_HARM
