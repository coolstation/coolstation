
/obj/item/reagent_containers/food/snacks/sandwich/
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	amount = 4
	heal_amt = 2
	var/hname = null
	var/job = null
	food_color = "#FFFFCC"
	custom_food = 0
	initial_volume = 30
	food_effects = list("food_refreshed")

	meat_h
		name = "manwich"
		desc = "Human meat between two slices of bread."
		icon_state = "sandwich_m"
		food_effects = list("food_refreshed", "food_energized_big")

		New()
			..()
			if (prob(6)) //warc's idea
				name = pick("womanwich","nonbinarywich")

	meat_m
		name = "monkey sandwich"
		desc = "Meat between two slices of bread."
		icon_state = "sandwich_m"
		food_effects = list("food_refreshed", "food_energized")

	grubmeat
		name = "grubwich"
		desc = "Fried grub between two slices of bread."
		icon_state = "sandwich_grub"
		food_effects = list("food_refreshed", "food_energized", "food_brute")

	pb
		name = "peanut butter sandwich"
		desc = "Peanut butter between two slices of bread."
		icon_state = "sandwich_p"
		food_effects = list("food_refreshed", "food_energized")

	pbh
		name = "peanut butter and honey sandwich"
		desc = "Peanut butter and honey between two slices of bread."
		icon_state = "sandwich_p"
		initial_reagents = list("honey"=10)
		food_effects = list("food_energized_big")
	meat_s
		name = "synthmeat sandwich"
		desc = "Synthetic meat between two slices of bread."
		icon_state = "sandwich_m"

	cheese
		name = "cheese sandwich"
		desc = "Cheese between two slices of bread."
		icon_state = "sandwich_c"

	elvis_meat_h
		name = "elvismanwich"
		desc = "Human meat between two slices of elvis bread."
		icon_state = "elviswich_m"
		initial_reagents = list("essenceofelvis"=25)
		food_effects = list("food_refreshed", "food_energized_big")

		New()
			..()
			if (prob(6)) //warc's idea
				name = pick("elviswomanwich","elvisnonbinarywich")

	elvis_meat_m
		name = "monkey elviswich"
		desc = "Meat between two slices of elvis bread."
		icon_state = "elviswich_m"
		initial_reagents = list("essenceofelvis"=25)
		food_effects = list("food_refreshed", "food_energized")

	elvis_pb
		name = "peanut butter elviswich"
		desc = "Peanut butter between two slices of elvis bread."
		icon_state = "elviswich_p"
		initial_reagents = list("essenceofelvis"=25)
		food_effects = list("food_refreshed", "food_energized")

	elvis_pbh
		name = "peanut butter and honey elviswich"
		desc = "Peanut butter and honey between two slices of elvis bread."
		icon_state = "elviswich_p"
		initial_reagents = list("essenceofelvis"=15,"honey"=10)
		food_effects = list("food_refreshed", "food_energized_big")

	elvis_meat_s
		name = "synthmeat elviswich"
		desc = "Synthetic meat between two slices of elvis bread."
		icon_state = "elviswich_m"
		initial_reagents = list("essenceofelvis"=25)

	elvis_cheese
		name = "cheese elviswich"
		desc = "Cheese between two slices of elvis bread."
		icon_state = "elviswich_c"
		initial_reagents = list("essenceofelvis"=20,"cheese"=5)

	spooky_cheese
		name = "killed cheese sandwich"
		desc = "Cheese that has been murdered and buried in a hasty grave of dread."
		icon_state = "scarewich_c"
		initial_reagents = list("ectoplasm"=15,"cheese"=10)
		food_effects = list("food_energized","food_hp_up")

	spooky_pb
		name = "peanut butter and jelly meet breadula"
		desc = "It's probably rather frightening if you have a nut allergy."
		icon_state = "scarewich_pb"
		initial_reagents = list("ectoplasm"=15,"eyeofnewt"=10)
		food_effects = list("food_energized","food_hp_up")

	spooky_pbh
		name = "killer beenut butter sandwich"
		desc = "A peanut butter sandwich with a terrifying twist: Honey!"
		icon_state = "scarewich_pb"
		initial_reagents = list("ectoplasm"=10,"tongueofdog"=5,"honey"=10)
		food_effects = list("food_energized","food_hp_up")

	spooky_meat_h
		name = "murderwich"
		desc = "Dawn of the bread."
		icon_state = "scarewich_m"
		initial_reagents = list("ectoplasm"=15,"blood"=10)
		food_effects = list("food_hp_up_big","food_energized_big")

	spooky_meat_m
		name = "scare wich project"
		desc = "What's a ghost's favorite sandwich meat? BOO-loney!"
		icon_state = "scarewich_m"
		initial_reagents = list("ectoplasm"=15,"blood"=10)
		food_effects = list("food_hp_up_big")

	spooky_meat_s
		name = "synthmeat steinwich"
		desc = "A dreadful sandwich of flesh borne not of man or beast, but of twisted science."
		icon_state = "scarewich_m"
		initial_reagents = list("ectoplasm"=15,"synthflesh"=10)
		food_effects = list("food_hp_up_big")

	meatball
		name = "meatball sub"
		desc = "A submarine sandwich consisting of meatballs, cheese, and marinara sauce."
		icon_state = "meatball_sub"
		amount = 6
		heal_amt = 4
		food_effects = list("food_hp_up_big", "food_energized_big")

	eggsalad
		name = "egg-salad sandwich"
		desc = "The magnum opus of egg based sandwiches."
		icon_state = "sandwich_egg"
		food_effects = list("food_cateyes", "food_hp_up_big")

	banhmi
		name = "banh mi"
		desc = "Sometimes known as a Vietnamese sub. These are hard to make!"
		icon_state = "banh_mi"
		food_effects = list("food_energized_big", "food_hp_up_big")

		New()
			..()
			reagents.add_reagent("honey", 10)

/obj/item/reagent_containers/food/snacks/sandwich/mitraillette
	name = "mitraillette"
	desc = "A sandwich with meat, fries and sauce."
	icon_state = "mitraillette"
	amount = 6
	food_effects = list("food_hp_up_big", "food_explosion_resist")

/obj/item/reagent_containers/food/snacks/sandwich/knuckle
	name = "knuckle sandwich"
	desc = "You want some of this, punk?"
	icon_state = "sandwich_knuckle"
	initial_reagents = list("blood"=20)

	heal(var/mob/M) //Heal seems to be the de facto thing that folks override for food effects, so who am I to argue?
		..()
		playsound(get_turf(M), pick(sounds_punch), 50, 1)
		random_brute_damage(M, rand(2, 9), FALSE)  //stole these defaults from punch code, but I don't think anyone really cares if the values between here and there end up not matching exactly
		boutput(M, "<b class='alert'>The [src.name] punches you in [pick(list("your tongue", "your cheek", "the roof of your mouth", "your uvula", "the teeth"))]!</b>" )

	on_finish(mob/eater)
		boutput(eater, "<b class='alert'>The last of the [src.name] flips you off as it slides down your gullet.</b>" ) //Don't ask me how you'd ever know this

	throw_at(atom/target, range, speed, list/params, turf/thrown_from, throw_type, allow_anchored, bonus_throwforce, end_throw_callback)
		..()
		if (src.throwing)
			src.throwing = THROW_SANDWICH

/obj/item/reagent_containers/food/snacks/burger
	name = "burger"
	desc = "A burger."
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "hburger"
	item_state = "burger"
	amount = 5
	heal_amt = 2
	food_color ="#663300"
	initial_volume = 20
	initial_reagents = list("cholesterol"=5)
	food_effects = list("food_hp_up", "food_warm")

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/food/snacks/condiment/))
			src.amount += 1
		else return ..()

	temptation
		heal(var/mob/M)
			..()
			M.changeStatus("hallucination_fakeobject", 15 SECONDS, /obj/item/reagent_containers/food/snacks/burger)

/obj/item/reagent_containers/food/snacks/burger/buttburger
	name = "buttburger"
	desc = "This burger's all buns."
	icon_state = "assburger"
	initial_reagents = list("fartonium"=10)
	food_effects = list("food_sweaty_big")
	New()
		..()
		if(prob(10))
			name = pick("cleveland steamed ham","very sloppy joe","buttconator","bootyburg","quarter-mooner","ass whooper","hambuttger","big crack")


/obj/item/reagent_containers/food/snacks/burger/heartburger
	name = "heartburger"
	desc = "A hearty meal, made with Love."
	icon_state = "heartburger"
	food_effects = list("food_sweaty_big", "food_hp_up_big")

	New()
		..()
		reagents.add_reagent("love", 15)

/obj/item/reagent_containers/food/snacks/burger/brainburger
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	initial_reagents = list("cholesterol"=5,"prions"=10)
	food_effects = list("food_sweaty_big", "food_hp_up_big")

/obj/item/reagent_containers/food/snacks/burger/humanburger
	name = "burger"
	var/hname = ""
	desc = "A bloody burger."
	icon_state = "hburger"
	food_effects = list("food_energized_big", "food_brute")

/obj/item/reagent_containers/food/snacks/burger/monkeyburger
	name = "monkeyburger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "hburger"
	food_effects = list("food_energized", "food_brute")

/obj/item/reagent_containers/food/snacks/burger/butterburger
	name = "butter burger"
	desc = "Two heart attacks in one sloppy mess."
	icon_state = "butterburger"
	initial_reagents = list("cholesterol"=5,"butter"=10)
	food_effects = list("food_all", "food_sweaty")

/obj/item/reagent_containers/food/snacks/burger/fishburger
	name = "Fish-Fil-A"
	desc = "A delicious alternative to heart-grinding beef patties."
	icon_state = "fishburger"
	food_effects = list("food_energized", "food_burn")

/obj/item/reagent_containers/food/snacks/burger/moldy
	name = "moldy burger"
	desc = "A rather disgusting looking burger."
	icon_state ="moldyburger"
	amount = 1
	heal_amt = 1
	initial_volume = 15
	initial_reagents = null
	food_effects = list("food_bad_breath")

	New()
		..()
		#ifdef CREATE_PATHOGENS // PATHOLOGY REMOVAL
		wrap_pathogen(reagents, generate_flu_pathogen(), 7)
		wrap_pathogen(reagents, generate_cold_pathogen(), 8)
		#endif

	heal(var/mob/M)
		#ifdef CREATE_PATHOGENS //PATHOLOGY REMOVAL
		..()
		#else
		boutput(M, "<span class='alert'>Oof, how old was that?.</span>")
		if(prob(66))
			M.reagents.add_reagent("salmonella",15)
		..()
		#endif

/obj/item/reagent_containers/food/snacks/burger/plague
	name = "burgle"
	desc = "The plagueburger."
	icon_state = "moldyburger"
	amount = 1
	heal_amt = 1
	initial_volume = 15
	initial_reagents = null
	var/roundstart_pathogens = 1

	New()
		..()
		if(roundstart_pathogens)
			wrap_pathogen(reagents, generate_random_pathogen(), 15)

	fishstick
		roundstart_pathogens = 0
		pickup(mob/user)
			if(isadmin(user) || current_state == GAME_STATE_FINISHED)
				wrap_pathogen(reagents, generate_random_pathogen(), 15)
			else
				boutput(user, "<span class='notice'>You feel that it was too soon for this...</span>")
			. = ..()

/obj/item/reagent_containers/food/snacks/burger/camembert
	name = "\improper Camembert burger"
	desc = "This looks like one of those weird influencer burgers."
	icon_state = "camburger"
	amount = 6
	heal_amt = 1
	initial_volume = 15
	initial_reagents = list("cholesterol"=50,"cheese"=50)
	var/erupted = FALSE

	New()
		..()

	heal(var/mob/M)
		if(!erupted)
			var/turf/T = get_turf(src)
			T.fluid_react_single("cheese", 500)
			logTheThing("admin", src, T, "created fluid at [T] : cheese with volume 500 at [log_loc(T)].")
			message_admins("[key_name(src)] created fluid at [T] : cheese with volume 500 at [log_loc(T)].)")

			boutput(M, "<span class='alert'>oh shit, oh god, what the fuck is this</span>")
			M.visible_message("<span class='alert'>[src] erupts when [M] takes a bite!</span>")
			playsound(M.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
			icon_state = "camburger-erupted"
			erupted = TRUE
		else
			..()

/obj/item/reagent_containers/food/snacks/burger/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	amount = 3
	heal_amt = 1
	food_color = "#C8C8C8"
	brewable = 1
	brew_result = "beepskybeer"
	initial_reagents = list("cholesterol"=5,"nanites"=20)

/obj/item/reagent_containers/food/snacks/burger/cheeseborger
	name = "cheeseborger"
	desc = "The cheese really helps smooth out the metallic flavor."
	icon_state = "cheeseborger"
	amount = 3
	heal_amt = 1
	food_color = "#C8C8C8"
	brewable = 1
	brew_result = "beepskybeer"
	initial_reagents = list("cholesterol"=5,"nanites"=20)

/obj/item/reagent_containers/food/snacks/burger/synthburger
	name = "synthburger"
	desc = "A thoroughly artificial snack."
	icon_state = "hburger"
	amount = 5
	heal_amt = 2

/obj/item/reagent_containers/food/snacks/burger/baconburger
	name = "baconatrix"
	desc = "The official food of the Lunar Football League! Also possibly one of the worst things you could ever eat."
	icon_state = "baconburger"
	amount = 5
	heal_amt = 1
	initial_volume = 50
	initial_reagents = list("cholesterol"=5,"porktonium"=45)
	food_effects = list("food_hp_up_big", "food_sweaty")

	heal(var/mob/M)
		if(prob(25))
			M.nutrition += 100
		..()

/obj/item/reagent_containers/food/snacks/burger/sloppyjoe
	name = "sloppy joe"
	desc = "A rather messy burger."
	icon_state = "sloppyjoe"
	amount = 5
	heal_amt = 2
	food_effects = list("food_hp_up_big", "food_sweaty")

	heal(var/mob/M)
		if(prob(20))
			var/obj/decal/cleanable/tracked_reagents/blood/gibs/gib = make_cleanable(/obj/decal/cleanable/tracked_reagents/blood/gibs, get_turf(src) )
			gib.streak_cleanable(M.dir)
			boutput(M, "<span class='alert'>You drip some meat on the floor</span>")
			M.visible_message("<span class='alert'>[M] drips some meat on the floor!</span>")
			playsound(M.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)

		else
			..()

	temptation
		heal(var/mob/M)
			..()
			M.changeStatus("hallucination_fakeobject", 15 SECONDS, /obj/item/reagent_containers/food/snacks/burger/sloppyjoe)

/obj/item/reagent_containers/food/snacks/burger/mysteryburger
	name = "dubious burger"
	desc = "A burger of indeterminate meat type."
	icon_state = "brainburger"
	amount = 5
	heal_amt = 1
	food_effects = list("food_bad_breath", "food_hp_up_big")

	heal(var/mob/M)
		if(prob(8))
			var/effect = rand(1,4)
			switch(effect)
				if(1)
					boutput(M, "<span class='alert'>Ugh. Tasted all greasy and gristly.</span>")
					M.nutrition += 20
				if(2)
					boutput(M, "<span class='alert'>Good grief, that tasted awful!</span>")
					M.take_toxin_damage(2)
				if(3)
					boutput(M, "<span class='alert'>There was a cyst in that burger. Now your mouth is full of pus OH JESUS THATS DISGUSTING OH FUCK</span>")
					M.visible_message("<span class='alert'>[M] suddenly and violently vomits!</span>")
					M.vomit(20)
				if(4)
					boutput(M, "<span class='alert'>You bite down on a chunk of bone, hurting your teeth.</span>")
					random_brute_damage(M, 2)
		..()

/obj/item/reagent_containers/food/snacks/burger/cheeseburger
	name = "cheeseburger"
	desc = "Tasty, but not paticularly healthy."
	icon_state = "cburger"
	amount = 6
	heal_amt = 2
	food_effects = list("food_brute", "food_burn")

/obj/item/reagent_containers/food/snacks/burger/cheeseburger_m
	name = "monkey cheese burger"
	desc = "How very dadaist."
	icon_state = "cburger"
	amount = 6
	heal_amt = 2

	heal(var/mob/M)
		if(prob(3) && ishuman(M))
			switch (rand(1,4))
				if (1)
					boutput(M, "<span class='alert'>You wackily and randomly turn into a lizard.</span>")
					M.set_mutantrace(/datum/mutantrace/lizard)
					M:update_face()
					M:update_body()

				if (2)
					boutput(M, "<span class='alert'>You wackily and randomly turn into a ferret.</span>")
					M.set_mutantrace(/datum/mutantrace/fert)
					M:update_face()
					M:update_body()

				if (3)
					boutput(M, "<span class='alert'>You wackily and randomly turn into a cat.</span>")
					M.set_mutantrace(/datum/mutantrace/cat)
					M:update_face()
					M:update_body()

				if (4)
					boutput(M, "<span class='alert'>You wackily and randomly turn into a cow.</span>")
					M.set_mutantrace(/datum/mutantrace/cow)
					M:update_face()
					M:update_body()

		else if(prob(3))
			boutput(M, "<span class='alert'>You wackily and randomly turn into a monkey.</span>")
			M:monkeyize()

		..()

/obj/item/reagent_containers/food/snacks/burger/bigburger
	name = "Coronator"
	desc = "The king of burgers. You can feel your digestive system shutting down just LOOKING at it."
	icon_state = "bigburger"
	amount = 10
	heal_amt = 5
	initial_volume = 100
	initial_reagents = list("cholesterol"=50)
	food_effects = list("food_hp_up_big", "food_sweaty_big")

/obj/item/reagent_containers/food/snacks/burger/monsterburger
	name = "THE MONSTER"
	desc = "There are no words to describe the sheer unhealthiness of this abomination."
	icon_state = "giantburger"
	amount = 1
	heal_amt = 50
	throwforce = 10
	initial_volume = 330
	initial_reagents = list("cholesterol"=200)
	unlock_medal_when_eaten = "That's no moon, that's a GOURMAND!"
	food_effects = list("food_hp_up_big", "food_sweaty_big", "food_bad_breath", "food_warm")

/obj/item/reagent_containers/food/snacks/burger/vr
	icon = 'icons/effects/VR.dmi'

/obj/item/reagent_containers/food/snacks/fries //my favourite sandwich
	name = "fries"
	desc = "Lightly salted potato fingers."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "fries"
	amount = 5
	heal_amt = 1
	initial_volume = 5
	initial_reagents = list("cholesterol"=1)
	//TODO: make generic somehow?
	var/disappointing = FALSE

	heal(var/mob/M)
		if (disappointing)
			boutput(M, "These taste disappointing. Like a mild, but clear insult to fries.")
		else ..() //mostly to suppress other "that tasted X" messages, but yeah no benefits from oven fries either


/obj/item/reagent_containers/food/snacks/fat_fries //my other favourite sandwich
	name = "fat fries"
	desc = "Lightly salted potato thumbs."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "fries_thicc"
	amount = 6
	heal_amt = 1
	initial_volume = 10
	initial_reagents = list("cholesterol"=1)
	//TODO: make generic somehow?
	var/disappointing = FALSE

	heal(var/mob/M)
		if (disappointing)
			boutput(M, "These taste disappointing. Like a mild, but clear insult to fries.")
		else ..() //mostly to suppress other "that tasted X" messages, but yeah no benefits from oven fries either

	on_reagent_change(add)
		if(add && src.reagents.get_reagent_amount("gravy") >= 5)
			src.visible_message("[src] gets remarkably saucier.")
			new /obj/item/reagent_containers/food/snacks/frites_sauce(get_turf(src))
			qdel(src)
		..()

/obj/item/reagent_containers/food/snacks/frites_sauce
	name = "frites sauce"
	desc = "Des patates frites avec sauce brune."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "fries_gravy"
	amount = 7
	heal_amt = 2
	initial_volume = 10
	initial_reagents = list("gravy"=5)
	food_effects = list("food_warm")

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/reagent_containers/food/snacks/ingredient/cheese))
			user.visible_message("[user] adds some cheese to [src].", "You add some cheese to [src].")
			user.u_equip(W)
			W.dropped()
			qdel(W)
			new /obj/item/reagent_containers/food/snacks/poutine(get_turf(src))
			qdel(src)
		else
			..()

/obj/item/reagent_containers/food/snacks/poutine
	name = "poutine"
	desc = "Des patates frites avec fromage en grains et sauce brune."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "poutine"
	amount = 8
	heal_amt = 3
	initial_volume = 15
	initial_reagents = list("gravy"=5,"cheese"=5)
	food_effects = list("food_warm", "food_hp_up")

/obj/item/reagent_containers/food/snacks/macguffin
	name = "sausage macguffin"
	desc = "You might want to start over, I'm not exactly lovin' it."
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "macguffin"
	amount = 4
	heal_amt = 1
	initial_reagents = list("cholesterol"=1)

/obj/item/reagent_containers/food/snacks/burger/luauburger
	name = "luau burger"
	desc = "You can already taste the fresh, sweet pineapple."
	icon_state = "luauburger"
	food_effects = list("food_refreshed_big", "food_hp_up")

/obj/item/reagent_containers/food/snacks/burger/tikiburger
	name = "tiki burger"
	desc = "A burger straight out of Hawaii"
	icon_state = "tikiburger"
	food_effects = list("food_refreshed_big", "food_hp_up")

/obj/item/reagent_containers/food/snacks/burger/coconutburger
	name = "coconut burger"
	desc = "Wait a minute... this has no real meat in it."
	icon_state = "coconutburger"
	food_effects = list("food_refreshed_big", "food_hp_up")

/obj/item/reagent_containers/food/snacks/burger/chicken
	name = "chicken sandwich"
	desc = "A delicious chicken sandwich."
	icon_state = "chickenburger"

/obj/item/reagent_containers/food/snacks/burger/chicken/spicy
	name = "spicy chicken sandwich"
	desc = "A delicious chicken sandwich with a bit of a kick."
	icon_state = "chickenburger-spicy"
	initial_reagents = list("capsaicin"=15)
