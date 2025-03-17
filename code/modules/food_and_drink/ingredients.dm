// Ingredients

/obj/item/reagent_containers/food/snacks/ingredient
	name = "ingredient"
	desc = "you shouldnt be able to see this"
	icon = 'icons/obj/foodNdrink/food_ingredient.dmi'
	amount = 1
	heal_amt = 0
	custom_food = 0

/obj/item/reagent_containers/food/snacks/ingredient/meat
	name = "raw meat"
	desc = "you shouldnt be able to see this either!!"
	icon_state = "meat"
	amount = 1
	heal_amt = 0
	custom_food = 1
	value = 50 //base commodity price
	var/blood = 7 //how much blood cleanables we are allowed to spawn

	heal(var/mob/living/M)
		if (prob(33))
			boutput(M, "<span class='alert'>You briefly think you probably shouldn't be eating raw meat.</span>")
			M.contract_disease(/datum/ailment/disease/food_poisoning, null, null, 1) // path, name, strain, bypass resist

	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A)
		playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 100, 1)
		if (src.blood <= 0) return ..()

		if (istype(T))
			make_cleanable( /obj/decal/cleanable/blood,T)
			blood--
		..()

/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat
	name = "-meat"
	desc = "A slab of meat."
	value = -500 //should fine you for selling to most people
	alt_value = 500 //a certain delicacy...
	var/subjectname = ""
	var/subjectjob = null
	amount = 1

/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat
	name = "monkeymeat"
	desc = "A slab of meat from a monkey."
	amount = 1

/obj/item/reagent_containers/food/snacks/ingredient/meat/grubmeat
	name = "grubsteak"
	desc = "One of the grub's central body lobes, separated and skinned. Juicy."
	icon_state = "meat-grub"
	amount = 2
	heal_amt = 3
	initial_reagents = list("blood"=20)
	//var/blood_color = "#33C370" // Someone smarter than me figure out how to do this
	food_effects = list("food_hp_up", "food_brute")

//even more mysterious meat from space meat chunk that nobody should trust to eat, if only because of how normal looking and tasting it is
//could do with a weird and unnerving effect reagent or disease that seems much worse than it is. maybe makes you hungrier the more you eat?
//mostly doing this because i'm not supposed to use the root of /meat and this is clearly not human, monkey, synth, or otherwise known as a meat available on the frontier
/obj/item/reagent_containers/food/snacks/ingredient/meat/perfectlynormalmeat
	name = "normal meat"
	desc = "An exceptionally regular looking slab of meat from... somewhere? No, really, where did this even come from?"
	amount = 1
	value = 75

/obj/item/reagent_containers/food/snacks/ingredient/meat/fish
	name = "fish fillet"
	desc = "A slab of meat from a fish."
	icon_state = "fillet-pink"
	amount = 1
	food_color = "#F4B4BC"
	real_name = "fish"
	value = 60

	salmon
		name = "salmon fillet"
		icon_state = "fillet-orange"
		food_color = "#F29866"
		real_name = "salmon"
	white
		name = "white fish fillet"
		icon_state = "fillet-white"
		food_color = "#FFECB7"
		real_name = "white fish"
	small
		name = "small fish fillet"
		icon_state = "fillet-small"
		food_color = "#FFECB7"
		real_name = "small fish"

/obj/item/reagent_containers/food/snacks/ingredient/meat/fugu
	name = "fugu"
	desc = "Thin slices of pufferfish fillet, looks kind of plain. Hopefully properly prepared."
	icon_state = "fugu"
	amount = 3
	food_color = "#e3e3e3"
	real_name = "fugu"
	food_effects = list("food_hp_up","food_energized")
	value = 100 // Expensive
	var/properly_made = FALSE

	heal(var/mob/M)
		if (!properly_made)
			M.reagents.add_reagent("tetrodotoxin", 5) // Eating this might be a baad idea
		return

	wellmade
		value = 1200 // Very Expensive TM
		properly_made = TRUE

/obj/item/reagent_containers/food/snacks/ingredient/meat/puffer_liver
	name = "pufferfish liver"
	desc = "The most toxic part of pufferfish."
	icon_state = "pufferfish-liver"
	amount = 1
	initial_volume = 20
	initial_reagents = list("tetrodotoxin"=20)

/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat
	name = "synthmeat"
	desc = "Synthetic meat grown in hydroponics."
	icon_state = "meat-plant"
	amount = 1
	initial_volume = 20
	food_color = "#228822"
	initial_reagents = list("synthflesh"=2)

/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat
	name = "mystery meat"
	desc = "What the fuck is this??"
	icon_state = "meat-mystery"
	amount = 1
	value = 40
	var/cybermeat = 0

	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A)
		if (src.cybermeat == 1)
			playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 100, 1)
			if (istype(T))
				make_cleanable(/obj/decal/cleanable/oil,T)
				..()
			else
				return..()

/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	name = "bacon"
	desc = "A strip of salty cured pork. Many disgusting nerds have a bizarre fascination with this meat, going so far as to construct tiny houses out of it."
	icon_state = "bacon"
	amount = 1
	initial_reagents = list("porktonium"=10)

	New()
		..()
		src.pixel_x += rand(-4,4)
		src.pixel_y += rand(-4,4)

	heal(var/mob/M)
		M.nutrition += 20
		return

	raw
		name = "raw bacon"
		desc = "A strip of salty raw cured pork. It really should be cooked first."
		icon_state = "bacon-raw"
		amount = 1
		real_name = "bacon"

/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget
	name = "chicken nugget"
	desc = "A breaded wad of poultry, far too processed to have a more specific label than 'nugget.'"
	icon = 'icons/obj/foodNdrink/food_ingredient.dmi'
	icon_state = "nugget0"
	amount = 2
	initial_volume = 15

	New()
		..()
		src.pixel_x += rand(-4,4)
		src.pixel_y += rand(-4,4)

	heal(var/mob/M)
		if (icon_state == "nugget0")
			icon_state = "nugget1"
		return ..()

/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/spicy
	name = "\improper Windy's spicy chicken nugget"
	desc = "A breaded wad of poultry, far too processed to have a more specific label than 'nugget.' It's spicy. The ones from Windy's are the best."
	color = "#FF6600"
	food_color = "#FF6600"
	heal_amt = 10
	initial_reagents = list("capsaicin"=15)

/obj/item/reagent_containers/food/snacks/ingredient/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"
	food_color = "#FFFFFF"
	initial_volume = 20
	initial_reagents = list("egg"=5)
	doants = 0 // They're protected by a shell

	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A)
		src.visible_message("<span class='alert'>[src] splats onto the floor messily!</span>")
		playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 100, 1)
		make_cleanable(/obj/decal/cleanable/eggsplat,T)
		make_cleanable(/obj/decal/cleanable/eggshell,T)
		qdel (src)

/obj/item/reagent_containers/food/snacks/ingredient/egg/hardboiled
	name = "hard-boiled egg"
	desc = "You're a loose cannon, egg. I'm taking you off the menu."
	icon_state = "egg-hardboiled"
	food_color = "#FFFFFF"
	initial_volume = 20
	food_effects = list("food_brute", "food_cateyes")

	New()
		..()
		reagents.add_reagent("egg", 5)

	throw_impact(atom/A, datum/thrown_thing/thr)
		src.visible_message("<span class='alert'>[src] flops onto the floor!</span>")

	attackby(obj/item/W as obj, mob/user as mob)
		if (istool(W, TOOL_CUTTING | TOOL_SNIPPING))
			boutput(user, "<span class='notice'>You cut [src] in half</span>")
			new /obj/item/reagent_containers/food/snacks/deviledegg(get_turf(src))
			new /obj/item/reagent_containers/food/snacks/deviledegg(get_turf(src))
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			qdel(src)
		else ..()


/obj/item/reagent_containers/food/snacks/ingredient/flour
	name = "flour"
	desc = "Some flour."
	icon_state = "flour"
	amount = 1
	food_color = "#FFFFFF"
	value = 20

/obj/item/reagent_containers/food/snacks/ingredient/flour/semolina
	name = "semolina"
	desc = "Some semolina flour."
	icon_state = "semolina"
	food_color = "#FFFFEE"

/obj/item/reagent_containers/food/snacks/ingredient/rice_sprig
	name = "rice sprig"
	desc = "A sprig of rice. There's probably a decent amount in it, thankfully."
	icon = 'icons/obj/foodNdrink/food_produce.dmi'
	icon_state = "rice-sprig"
	amount = 1
	food_color = "#FFFFAA"
	brewable = 1
	brew_result = "ricewine"
	value = 10

/obj/item/reagent_containers/food/snacks/ingredient/rice
	name = "rice"
	desc = "Some rice."
	icon_state = "rice"
	amount = 1
	food_color = "#E3E3E3"
	value = 20

/obj/item/reagent_containers/food/snacks/ingredient/sugar
	name = "sugar"
	desc = "How sweet."
	icon_state = "sugar"
	amount = 1
	food_color = "#FFFFFF"
	custom_food = 1
	initial_volume = 50
	initial_reagents = list("sugar"=25)
	brewable = 1
	brew_result = "rum"
	value = 20

/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter
	name = "peanut butter"
	desc = "A jar of GRIF peanut butter."
	icon_state = "peanutbutter"
	amount = 3
	heal_amt = 1
	food_color = "#996600"
	custom_food = 1
	food_effects = list("food_deep_burp")
	value = 25

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/food/snacks/candy) && W.reagents && W.reagents.has_reagent("chocolate"))
			if (istype(W, /obj/item/reagent_containers/food/snacks/candy/pbcup))
				return
			boutput(user, "You get chocolate in the peanut butter!  Or maybe the other way around?")

			var/obj/item/reagent_containers/food/snacks/candy/pbcup/A = new /obj/item/reagent_containers/food/snacks/candy/pbcup
			user.u_equip(W)
			user.put_in_hand_or_drop(A)

			qdel(W)
			if (src.amount-- < 1)
				qdel(src)

		else
			..()
		return

/obj/item/reagent_containers/food/snacks/ingredient/oatmeal
	name = "oatmeal"
	desc = "A breakfast staple."
	icon_state = "oatmeal"
	amount = 1
	food_color = "#CC9966"
	custom_food = 1
	value = 20

/obj/item/reagent_containers/food/snacks/ingredient/honey
	name = "honey"
	desc = "A sweet nectar derivative produced by bees."
	icon_state = "honeyblob"
	amount = 1
	food_color = "#C0C013"
	custom_food = 1
	doants = 0
	initial_volume = 50
	initial_reagents = list("honey"=15)
	brewable = 1
	brew_result = "mead"
	value = 200 //base commodity price

	New()
		..()
		src.setMaterial(getMaterial("honey"), appearance = 0, setname = 0)

/obj/item/reagent_containers/food/snacks/ingredient/royal_jelly
	name = "royal jelly"
	desc = "A blob of nutritive gel for larval bees."
	icon_state = "jellyblob"
	amount = 1
	food_color = "#990066"
	custom_food = 1
	doants = 0
	initial_volume = 50
	initial_reagents = list("royal_jelly"=25)
	value = 200

/obj/item/reagent_containers/food/snacks/ingredient/peeled_banana
	name = "peeled banana"
	icon = 'icons/obj/foodNdrink/food_produce.dmi'
	icon_state = "banana-fruit"
	value = -1 //gross

//an entire cheese but it acts like a slice in cooking
/obj/item/reagent_containers/food/snacks/ingredient/cheese
	name = "cheese"
	desc = "Some kind of curdled milk product."
	icon_state = "cheese"
	amount = 2
	heal_amt = 1
	food_color = "#FFD700"
	initial_volume = 10
	initial_reagents = list("cheese"=10)
	custom_food = 1
	value = 5

/obj/item/reagent_containers/food/snacks/ingredient/gcheese
	name = "weird cheese"
	desc = "Some kind of... gooey, messy, gloopy thing. Similar to cheese, but only in the looser sense of the word."
	icon_state = "cheese-green"
	amount = 2
	heal_amt = 1
	food_color = "#669966"
	custom_food = 1
	initial_volume = 50
	initial_reagents = list("mercury"=5,"LSD"=5,"ethanol"=5,"gcheese"=5)
	food_effects = list("food_sweaty","food_bad_breath")
	value = -5
	alt_value = 20

/obj/item/reagent_containers/food/snacks/ingredient/pancake_batter
	name = "pancake batter"
	desc = "Used for making pancakes."
	icon_state = "pancake"
	amount = 1
	food_color = "#FFFFFF"
	value = 20

/obj/item/reagent_containers/food/snacks/ingredient/meatpaste
	name = "meatpaste"
	desc = "A meaty paste"
	icon_state = "meatpaste"
	amount = 1
	custom_food = 1
	initial_volume = 50
	initial_reagents = list("meat_slurry"=15)
	value = 40

/obj/item/reagent_containers/food/snacks/ingredient/sticky_rice
	name = "sticky rice"
	desc = "A big lump of sticky rice."
	icon_state = "rice-sticky"
	amount = 1
	food_color = "#E3E3E3"
	custom_food = 0
	value = 5

	attack_self(mob/user as mob)
		boutput(user, "You mold the sticky rice into rice balls.")
		for (var/x = 0, x < 3, x++)
			new /obj/item/reagent_containers/food/snacks/rice_ball(user.loc)
		user.u_equip(src)
		qdel(src)


/obj/item/reagent_containers/food/snacks/ingredient/dough
	name = "dough"
	desc = "Used for making bready things."
	icon_state = "dough"
	amount = 1
	food_color = "#FFFFFF"
	custom_food = 0
	value = -1 //standard for used but not completed ingredients

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/sugar))
			boutput(user, "<span class='notice'>You add [W] to [src] to make sweet dough!</span>")
			var/obj/item/reagent_containers/food/snacks/ingredient/dough_s/D = new /obj/item/reagent_containers/food/snacks/ingredient/dough_s(W.loc)
			user.u_equip(W)
			user.put_in_hand_or_drop(D)
			qdel(W)
			qdel(src)
		else if (istype(W, /obj/item/kitchen/rollingpin) || istype(W, /obj/item/rods))
			boutput(user, "<span class='notice'>You flatten out the dough.</span>")
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			if(prob(1))
				playsound(src.loc, "sound/voice/screams/male_scream.ogg", 100, 1, channel=VOLUME_CHANNEL_EMOTE)
				src.visible_message("<span class='alert'><B>The [src] screams!</B></span>")
			if(src.reagents?.has_reagent("bubs"))
				new /obj/item/reagent_containers/food/snacks/ingredient/pizza_base/bubsian(get_turf(src))
			else
				new /obj/item/reagent_containers/food/snacks/ingredient/pizza_base(get_turf(src))
			user.u_equip(src)
			qdel(src)
		else if (istype(W, /obj/item/axe) || istype(W, /obj/item/circular_saw) || istype(W, /obj/item/kitchen/utensil/knife) || istype(W, /obj/item/scalpel) || istype(W, /obj/item/sword) || istype(W,/obj/item/saw) || istype(W,/obj/item/knife/butcher))
			boutput(user, "<span class='notice'>You cut the dough into two strips.</span>")
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			if(prob(1))
				playsound(src.loc, "sound/voice/screams/male_scream.ogg", 100, 1, channel=VOLUME_CHANNEL_EMOTE)
				src.visible_message("<span class='alert'><B>The [src] screams!</B></span>")
			for(var/i = 1, i <= 2, i++)
				new /obj/item/reagent_containers/food/snacks/ingredient/dough_strip(get_turf(src))
			qdel(src)
		else if (istype(W, /obj/item/kitchen/utensil/fork))
			boutput(user, "<span class='notice'>You stab holes in the dough. How vicious.</span>")
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			if(prob(1))
				playsound(src.loc, "sound/voice/screams/male_scream.ogg", 100, 1, channel=VOLUME_CHANNEL_EMOTE)
				src.visible_message("<span class='alert'><B>The [src] screams!</B></span>")
			var/obj/item/reagent_containers/food/snacks/ingredient/holey_dough/H = new /obj/item/reagent_containers/food/snacks/ingredient/holey_dough(W.loc)
			user.u_equip(src)
			user.put_in_hand_or_drop(H)
			qdel(src)
		else if (istype(W, /obj/item/robodefibrillator))
			boutput(user, "<span class='notice'>You defibrilate the dough, yielding a perfect stack of flapjacks.</span>")
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			if(prob(1))
				playsound(src.loc, "sound/voice/screams/male_scream.ogg", 100, 1, channel=VOLUME_CHANNEL_EMOTE)
				src.visible_message("<span class='alert'><B>The [src] screams!</B></span>")
			var/obj/item/reagent_containers/food/snacks/pancake/F = new /obj/item/reagent_containers/food/snacks/pancake(src.loc)
			user.u_equip(src)
			user.put_in_hand_or_drop(F)
			qdel(src)
		else if (istype(W, /obj/item/baton))
			var/obj/item/baton/baton = W
			if (baton.is_active) //baton is on
				if (user.a_intent != "harm")
					if (user.traitHolder.hasTrait("training_security"))
						playsound(src, "sound/impact_sounds/Energy_Hit_3.ogg", 30, 1, -1) //bit quieter than a baton hit
						user.visible_message("<span class='notice'>[user] [pick("expertly", "deftly", "casually", "smoothly")] baton-fries the dough, yielding a tasty donut.</span>", group = "batonfry")
						var/obj/item/reagent_containers/food/snacks/donut/result = new /obj/item/reagent_containers/food/snacks/donut(src.loc)
						user.u_equip(src)
						user.put_in_hand_or_drop(result)
						qdel(src)
					else
						boutput(user, "<span class='alert'>You just aren't experienced enough to baton-fry.</span>")
				else
					user.visible_message("<b class='alert'>[user] tries to baton fry the dough, but fries [his_or_her(user)] hand instead!</b>")
					playsound(src, "sound/impact_sounds/Energy_Hit_3.ogg", 30, 1, -1)
					user.do_disorient(baton.stamina_damage, weakened = baton.stun_normal_weakened * 10, disorient = 80) //cut from batoncode to bypass all the logging stuff
					user.emote("scream")
			else
				boutput(user, "<span class='notice'>You [user.a_intent == "harm" ? "beat" : "prod"] the dough. The dough doesn't react.</span>")
		else ..()

/obj/item/reagent_containers/food/snacks/ingredient/dough/semolina
	name = "semolina dough"
	desc = "Used for making pasta-y things."
	icon_state = "dough-semolina"
	value = -1 //standard for used but not completed ingredients

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/kitchen/rollingpin))
			boutput(user, "<span class='notice'>You flatten out the dough into a sheet.</span>")
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			if(prob(1))
				playsound(src.loc, "sound/voice/screams/male_scream.ogg", 100, 1, channel=VOLUME_CHANNEL_EMOTE)
				src.visible_message("<span class='alert'><B>The [src] screams!</B></span>")
			var/obj/item/reagent_containers/food/snacks/ingredient/pasta/sheet/P = new /obj/item/reagent_containers/food/snacks/ingredient/pasta/sheet(src.loc)
			user.u_equip(src)
			user.put_in_hand_or_drop(P)
			qdel(src)
		else ..()

/obj/item/reagent_containers/food/snacks/ingredient/dough_strip
	name = "dough strip"
	desc = "A strand of cut up dough. It looks like you can re-attach two of them back together."
	icon_state = "dough-strip"
	amount = 1
	food_color = "#FFFFF"
	custom_food = 0
	value = -1 //standard for used but not completed ingredients

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/dough_strip))
			boutput(user, "<span class='notice'>You attach the [src]s back together to make a piece of dough.</span>")
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			var/obj/item/reagent_containers/food/snacks/ingredient/dough/D = new /obj/item/reagent_containers/food/snacks/ingredient/dough(W.loc)
			user.u_equip(W)
			user.put_in_hand_or_drop(D)
			qdel(W)
			qdel(src)
		else ..()

	attack_self(var/mob/user as mob)
		boutput(user, "<span class='notice'>You twist the [src] into a circle.</span>")
		if (prob(25))
			JOB_XP(user, "Chef", 1)
		if(prob(1))
			playsound(src.loc, "sound/voice/screams/male_scream.ogg", 100, 1, channel=VOLUME_CHANNEL_EMOTE)
			src.visible_message("<span class='alert'><B>The [src] screams!</B></span>")
		new /obj/item/reagent_containers/food/snacks/ingredient/dough_circle(get_turf(src))
		qdel (src)

/obj/item/reagent_containers/food/snacks/ingredient/dough_circle
	name = "dough circle"
	desc = "Used for making torus-shaped things." //I used to eat out with friends, but bagels just torus apart.
	icon_state = "dough-circle"
	amount = 1
	food_color = "#FFFFF"
	custom_food = 0
	value = -1 //standard for used but not completed ingredients

/obj/item/reagent_containers/food/snacks/ingredient/holey_dough
	name = "holey dough" //+1 to chaplain magic skills
	desc = "Some dough with a bunch of holes poked in it. How exotic."
	icon_state = "dough-holey"
	amount = 1
	food_color = "#FFFFF"
	custom_food = 0
	value = -1 //standard for used but not completed ingredients

/obj/item/reagent_containers/food/snacks/ingredient/dough_s
	name = "sweet dough"
	desc = "Used for making cakey things."
	icon_state = "dough-sweet"
	amount = 1
	value = -1 //standard for used but not completed ingredients

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/axe) || istype(W, /obj/item/circular_saw) || istype(W, /obj/item/kitchen/utensil/knife) || istype(W, /obj/item/scalpel) || istype(W, /obj/item/sword) || istype(W,/obj/item/saw) || istype(W,/obj/item/knife/butcher))
			boutput(user, "<span class='notice'>You cut [src] into smaller pieces...</span>")
			for(var/i = 1, i <= 4, i++)
				new /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie(get_turf(src))
			qdel(src)
		if (prob(25))
			JOB_XP(user, "Chef", 1)
		else ..()

/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	name = "cookie dough"
	desc = "Probably shouldn't be eaten raw, not that THAT'S ever stopped anyone."
	icon_state = "dough-cookie"
	amount = 1
	custom_food = 1
	rand_pos = 6
	value = -1 //standard for used but not completed ingredients

	heal(var/mob/M)
		if(prob(15))
			#ifdef CREATE_PATHOGENS //PATHOLOGY REMOVAL
			wrap_pathogen(M.reagents, generate_indigestion_pathogen(), 15)
			#else
			M.reagents.add_reagent("salmonella",15)
			#endif
			boutput(M, "<span class='alert'>That tasted a little bit...off.</span>")
		..()

/obj/item/reagent_containers/food/snacks/ingredient/tortilla
	name = "uncooked tortilla"
	desc = "An uncooked flour tortilla."
	amount = 1
	icon_state = "tortillabase"
	food_color = "#FFFFFF"
	rand_pos = 8
	value = 3 //need to calculate all the stuff you get from doughs


/obj/item/reagent_containers/food/snacks/ingredient/pasta
	// generic uncooked pasta parent
	name = "pasta sheet"
	desc = "Uncooked pasta."
	heal_amt = 0
	amount = 1
	value = 5 //standard for used but not completed ingredients

	heal(var/mob/M)
		boutput(M, "<span class='alert'>... You must be really hungry.</span>")
		..()

/obj/item/reagent_containers/food/snacks/ingredient/pasta/sheet
	name = "pasta sheet"
	desc = "An uncooked sheet of pasta."
	icon_state = "pasta-sheet"


/obj/item/reagent_containers/food/snacks/ingredient/chips_thicc
	name = "uncooked chips"
	desc = "Cook them up into some nice fat fries, or cut them again into shoestrings."
	icon_state = "pchips_thicc"
	amount = 6
	heal_amt = 0
	food_color = "#FFFF99"
	value = -1 //standard for used but not completed ingredients

	heal(var/mob/M)
		boutput(M, "<span class='alert'>Raw potato tastes pretty nasty...</span>") // does it?

	attackby(obj/item/W as obj, mob/user as mob)
		if (iscuttingtool(W))
			user.visible_message("[user] chops up [src].", "You chop up [src].")
			new /obj/item/reagent_containers/food/snacks/ingredient/chips(get_turf(src))
			new /obj/item/reagent_containers/food/snacks/ingredient/chips(get_turf(src))
			qdel(src)

/obj/item/reagent_containers/food/snacks/ingredient/chips
	name = "uncooked fries"
	desc = "Cook them up into some nice golden fries."
	icon_state = "pchips"
	amount = 6
	heal_amt = 0
	food_color = "#FFFF99"
	value = -1 //standard for used but not completed ingredients

	heal(var/mob/M)
		boutput(M, "<span class='alert'>Raw potato tastes pretty nasty...</span>") // does it?


/obj/item/reagent_containers/food/snacks/proc/random_spaghetti_name()
	.= pick(list("spagtetti","splaghetti","spaghetty","spagtti","spagheti","spaghettie","spahetti","spetty","pisketti","spagoody","spaget","spagherti","spaceghetti"))

/obj/item/reagent_containers/food/snacks/ingredient/spaghetti
	name = "spaghetti noodles"
	desc = "Original italian noodles."
	icon_state = "spaghetti"
	heal_amt = 0
	amount = 1

	New()
		..()
		name = "[random_spaghetti_name()] noodles"

	get_desc()
		..()
		.= "Original italian [name]."


	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/reagent_containers/food/snacks/condiment/ketchup))
			boutput(user, "<span class='notice'>You create [random_spaghetti_name()] with tomato sauce...</span>")
			var/obj/item/reagent_containers/food/snacks/spaghetti/sauce/D
			if (user.mob_flags & IS_BONER)
				D = new/obj/item/reagent_containers/food/snacks/spaghetti/sauce/skeletal(W.loc)
				boutput(user, "<span class='alert'>... whoa, that felt good. Like really good.</span>")
				user.reagents.add_reagent("satisghetti",20)
			else
				D = new/obj/item/reagent_containers/food/snacks/spaghetti/sauce(W.loc)
			user.u_equip(W)
			user.put_in_hand_or_drop(D)
			qdel(W)
			qdel(src)

	heal(var/mob/M)
		boutput(M, "<span class='alert'>The noodles taste terrible uncooked...</span>")
		..()

/obj/item/reagent_containers/food/snacks/ingredient/butter //its actually margarine
	name = "butter"
	desc = "Everything's better with it."
	icon_state = "butter"
	amount = 1
	heal_amt = 0
	food_color = "#FFFF00"
	initial_volume = 25
	initial_reagents = "butter"
	value = 10

	heal(var/mob/M)
		if(!M.traitHolder.hasTrait("greedy_beast"))
			boutput(M, "<span class='alert'>You feel ashamed of yourself...</span>")
		..()

/obj/item/reagent_containers/food/snacks/ingredient/pepperoni
	name = "pepperoni"
	desc = "A slice of what you believe could possibly be meat."
	icon_state = "pepperoni"
	amount = 1
	food_color = "#C90E0E"
	custom_food = 1
	doants = 1
	initial_volume = 5
	initial_reagents = "pepperoni"
	value = 40

obj/item/reagent_containers/food/snacks/ingredient/pepperoni_log
	name = "pepperoni log"
	desc = "It's like a forest of pepperoni was felled just for you."
	icon_state = "pepperoni-log"
	custom_food = 1
	amount = 1
	food_color = "#C90E0E"
	doants = 0
	initial_volume = 40
	initial_reagents = "pepperoni"
	value = 40

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/axe) || istype(W, /obj/item/circular_saw) || istype(W, /obj/item/kitchen/utensil/knife) || istype(W, /obj/item/scalpel) || istype(W, /obj/item/sword) || istype(W,/obj/item/saw) || istype(W,/obj/item/knife/butcher))
			var/turf/T = get_turf(src)
			user.visible_message("[user] cuts [src] into slices.", "You cut [src] into slices.")
			for (var/i in 1 to 8)
				new /obj/item/reagent_containers/food/snacks/ingredient/pepperoni(T)
			qdel (src)

/obj/item/reagent_containers/food/snacks/ingredient/seaweed
	name = "seaweed sheets"
	desc = "Dried and salted sheets of seaweed."
	icon_state = "seaweed"
	amount = 1
	heal_amt = 1
	food_color = "#4C453E"
	value = 10
