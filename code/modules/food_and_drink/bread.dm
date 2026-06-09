
/obj/item/reagent_containers/food/snacks/breadloaf
	name = "loaf of bread"
	desc = "I'm loafin' it!"
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "breadloaf"
	amount = 6
	heal_amt = 1
	food_color = "#FFFFCC"
	real_name = "bread"
	flags = ONBELT | FPRINT | TABLEPASS | SUPPRESSATTACK
	var/slicetype = /obj/item/reagent_containers/food/snacks/breadslice
	initial_volume = 30
	initial_reagents = "bread"
	food_effects = list("food_hp_up")

	attack(mob/M as mob, mob/user as mob, def_zone)
		if (user == M)
			if(user.traitHolder.hasTrait("greedy_beast"))
				boutput(user, "You take a bite out of the side of the bread, the way you were always meant to.")
				user.visible_message("<b>[user]</b> just takes a big gross bite out of [src]!")
				..()
			else
				boutput(user, "<span class='alert'>You can't just cram that in your mouth, you greedy beast!</span>")
				user.visible_message("<b>[user]</b> stares at [src] in a confused manner.")
				return
		else
			user.visible_message("<span class='alert'><b>[user]</b> futilely attempts to shove [src] into [M]'s mouth!</span>")
			return

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/axe) || istype(W, /obj/item/circular_saw) || istype(W, /obj/item/kitchen/utensil/knife) || istype(W, /obj/item/scalpel) || istype(W, /obj/item/sword) || istype(W,/obj/item/knife/butcher))
			if(user.bioHolder.HasEffect("clumsy") && prob(50))
				user.visible_message("<span class='alert'><b>[user]</b> fumbles and jabs [himself_or_herself(user)] in the eye with [W].</span>")
				user.change_eye_blurry(5)
				user.changeStatus("weakened", 3 SECONDS)
				JOB_XP(user, "Clown", 2)
				return

			var/turf/T = get_turf(src)
			user.visible_message("[user] cuts [src] into slices.", "You cut [src] into slices.")
			var/makeslices = 6
			while (makeslices > 0)
				new slicetype (T)
				makeslices -= 1
			qdel (src)
		if(istool(W,TOOL_SPOONING))
			boutput(user, "You scoop the crumb out of [src], making an attractive pair of loafers.")
			var/turf/T = get_turf(src)
			new /obj/item/clothing/shoes/bread(T)
			user.u_equip(src)
			qdel(src)
		else ..()

/obj/item/reagent_containers/food/snacks/breadloaf/honeywheat
	name = "loaf of honey-wheat bread"
	desc = "A bread made with honey. Right there in the name, first thing, top billing."
	icon_state = "honeyloaf"
	amount = 1
	heal_amt = 1
	real_name = "honey-wheat bread"
	slicetype = /obj/item/reagent_containers/food/snacks/breadslice/honeywheat

/obj/item/reagent_containers/food/snacks/breadloaf/banana
	name = "loaf of banana bread"
	desc = "A bread commonly found near clowns."
	icon_state = "bananabread"
	amount = 1
	heal_amt = 1
	real_name = "banana bread"
	slicetype = /obj/item/reagent_containers/food/snacks/breadslice/banana

/obj/item/reagent_containers/food/snacks/breadloaf/brain
	name = "loaf of brain bread"
	desc = "A pretty smart way to eat."
	icon_state = "brainbread"
	amount = 1
	heal_amt = 1
	real_name = "brain bread"
	slicetype = /obj/item/reagent_containers/food/snacks/breadslice/brain

/obj/item/reagent_containers/food/snacks/breadloaf/pumpkin
	name = "loaf of pumpkin bread"
	desc = "A very seasonal quickbread!  It tastes like Fall."
	icon_state = "pumpkinbread"
	amount = 1
	heal_amt = 1
	real_name = "pumpkin bread"
	slicetype = /obj/item/reagent_containers/food/snacks/breadslice/pumpkin

/obj/item/reagent_containers/food/snacks/breadloaf/elvis
	name = "loaf of elvis bread"
	desc = "Fattening and delicious, despite the hair.  It tastes like the soul of rock and roll."
	icon_state = "elvisbread"
	amount = 1
	heal_amt = 1
	real_name ="elvis bread"
	slicetype = /obj/item/reagent_containers/food/snacks/breadslice/elvis

/obj/item/reagent_containers/food/snacks/breadloaf/spooky
	name = "loaf of dread"
	desc = "The bread of the damned."
	icon_state = "dreadloaf"
	amount = 1
	heal_amt = 1
	real_name = "dread"
	slicetype = /obj/item/reagent_containers/food/snacks/breadslice/spooky

/obj/item/reagent_containers/food/snacks/breadloaf/corn
	name = "southern-style cornbread"
	desc = "A maize-based quickbread.  This variety, popular in the Southern United States, is not particularly sweet."
	icon_state= "cornbread"
	amount = 1
	heal_amt = 1
	real_name = "cornbread"
	slicetype = /obj/item/reagent_containers/food/snacks/breadslice/corn

	sweet
		name = "northern-style cornbread"
		desc = "A chunk of sweet maize-based quickbread."
		slicetype = /obj/item/reagent_containers/food/snacks/breadslice/corn/sweet

		honey
			name = "honey cornbread"
			desc = "A chunk of honey-sweetened maize-based quickbread."
			slicetype = /obj/item/reagent_containers/food/snacks/breadslice/corn/sweet/honey

/obj/item/reagent_containers/food/snacks/breadslice
	name = "slice of bread"
	desc = "That's slice."
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "breadslice"
	amount = 1
	heal_amt = 1
	food_color = "#FFFFCC"
	real_name = "bread"
	initial_volume = 5
	initial_reagents = "bread"
	food_effects = list("food_hp_up")
	griddle_result = /obj/item/reagent_containers/food/snacks/breadslice/toastslice
	var/obj/item/reagent_containers/food/snacks/sandwich/defaultsandwich = null //what kind of sandwich we default to if we don't have a special recipe
	var/list/sandwichitems = list()
	var/max_items = 8 //push the limits

	proc/add_contents(var/obj/item/food,var/mob/user = null,var/params = null)
		sandwichitems += food
		src.place_on(food,user,params)
		food.set_loc(src)
		src.vis_contents += food
		food.appearance_flags |= RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		food.vis_flags |= VIS_INHERIT_PLANE | VIS_INHERIT_LAYER | VIS_INHERIT_ID
		food.event_handler_flags |= NO_MOUSEDROP_QOL
		food.transform = matrix(matrix(0.7, 0.7, MATRIX_SCALE), rand(-10,10), MATRIX_ROTATE)

		src.update_icon()
		if (user)
			user.visible_message("<span class='notice'>[user] puts [food] on [src].</span>")

	proc/construct_name(var/name)
		var/endstring = ""
		if (sandwichitems.len == 1)
			var/obj/item/sanditem = sandwichitems[1]
			endstring = "[sanditem.name]"
		var/i = 1
		for (var/obj/item in sandwichitems)
			if (i == sandwichitems.len - 1)
				endstring += item.name + ", and "
			else if (i == sandwichitems.len)
				endstring += item.name
			else
				endstring += item.name + ", "
			i++
		return "[name] with [endstring]."

	proc/search_for_ingredient(var/list/ingredients)
		for (var/ingredient in ingredients)
			var/required = ingredients[ingredient]

			if(isnull(required))
				required = 1
			var/amt = 0

			for(var/food in sandwichitems)
				if(istype(food,ingredient))
					amt++
			if (amt != required)
				return false
		return true

	proc/finish_sandwich(var/obj/item/topslice,var/mob/user) //wassup homeslice
		var/obj/item/reagent_containers/food/snacks/sandwich/output
		var/uniqueingredients = 0 //if this goes above one, we just resort to a custom sandy to avoid conflicts.

		if (uniqueingredients <= 0)
			if (istype(topslice,/obj/item/reagent_containers/food/snacks/breadslice/elvis))
				//elviswiches here
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/elvis_meat_h
					uniqueingredients += 1
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/elvis_meat_m
					uniqueingredients += 1
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/elvis_meat_s
					uniqueingredients += 1
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/elvis_pb
					uniqueingredients += 1
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter,/obj/item/reagent_containers/food/snacks/ingredient/honey)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/elvis_pbh
					uniqueingredients += 1
			else if (istype(topslice,/obj/item/reagent_containers/food/snacks/breadslice/spooky))
				//scarewitches
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/spooky_meat_h
					uniqueingredients += 1
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/spooky_meat_m
					uniqueingredients += 1
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/spooky_meat_s
					uniqueingredients += 1
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/spooky_pb
					uniqueingredients += 1
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter,/obj/item/reagent_containers/food/snacks/ingredient/honey)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/spooky_pbh
					uniqueingredients += 1
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/ingredient/cheese)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/spooky_cheese
					uniqueingredients += 1
			else
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/meat_h
					uniqueingredients += 1
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/meat_m
					uniqueingredients += 1
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/meat_s
					uniqueingredients += 1
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/ingredient/meat/grubmeat)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/grubmeat
					uniqueingredients += 1
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/ingredient/cheese)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/cheese
					uniqueingredients += 1
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/pb
					uniqueingredients += 1
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter,/obj/item/reagent_containers/food/snacks/ingredient/honey)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/pbh
					uniqueingredients += 1
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/eggsalad)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/eggsalad
					uniqueingredients += 1
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/ingredient/cheese,/obj/item/parts/human_parts/arm)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/
					uniqueingredients += 1

		if (!output)
			output = new defaultsandwich
		if (uniqueingredients < 1)
			output.name = src.construct_name(output.name)
		output.set_loc(src.loc)
		if (istype(topslice,/obj/item/reagent_containers))
			var/obj/item/reagent_containers/rc = topslice
			if(rc.reagents && output.reagents)
				rc.reagents.trans_to(output.reagents,rc.reagents.total_volume)
		src.visible_message("[user] places [topslice] on [src], creating a \the[output]!")
		user.u_equip(src)
		user.put_in_hand_or_drop(output)
		JOB_XP(user,"chef",src.sandwichitems.len)
		qdel(topslice)
		qdel(src)

	baguette
		name = "half of a baguette"
		desc = "a crunchy slice of bread perfect for subs."
		icon_state = "baguette-bottom"
		real_name = "baguette-half"
		food_color = "#C07D1E"
		food_effects = list("food_hp_up","food_energized")
		defaultsandwich = /obj/item/reagent_containers/food/snacks/sandwich/custom_sub

		finish_sandwich(obj/item/topslice, mob/user)
			var/obj/item/reagent_containers/food/snacks/sandwich/output
			var/uniqueingredients = 0 //if this goes above one, we just resort to a custom sandy to avoid conflicts.

			if (uniqueingredients <= 0) //don't tell anybody, but you can put a regular slice of bread on a baguette half to make a sandwich.
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/meatball = 3,/obj/item/reagent_containers/food/snacks/ingredient/cheese,/obj/item/reagent_containers/food/snacks/condiment/tomato_sauce)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/meatball
					uniqueingredients += 1
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon,/obj/item/reagent_containers/food/snacks/plant/carrot,/obj/item/reagent_containers/food/snacks/plant/cucumber)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/banhmi
					uniqueingredients += 1
				if (!output && search_for_ingredient(list(/obj/item/reagent_containers/food/snacks/fries,/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon,/obj/item/reagent_containers/food/snacks/condiment)))
					output = new /obj/item/reagent_containers/food/snacks/sandwich/mitraillette
					uniqueingredients += 1

			if (!output)
				output = new defaultsandwich
			if (uniqueingredients < 1)
				output.name = src.construct_name(output.name)
			output.set_loc(src.loc)
			if (istype(topslice,/obj/item/reagent_containers))
				var/obj/item/reagent_containers/rc = topslice
				if(rc.reagents && output.reagents)
					rc.reagents.trans_to(output.reagents,rc.reagents.total_volume)
			src.visible_message("[user] places [topslice] on [src], creating a \the[output]!")
			user.u_equip(src)
			user.put_in_hand_or_drop(output)
			JOB_XP(user,"chef",src.sandwichitems.len)
			qdel(topslice)
			qdel(src)

	honeywheat
		name = "slice of honey-wheat bread"
		desc = "A slice of bread distinguished by the use of honey in its creation.  Also wheat."
		icon_state = "honeyslice"
		real_name = "honey-wheat bread"
		food_color = "#C07D1E"
		food_effects = list("food_hp_up","food_energized")

	banana
		name = "slice of banana bread"
		desc = "It's a slice.  A slice of banana bread."
		icon_state = "bananabreadslice"
		amount = 1
		heal_amt = 4
		real_name = "banana bread"
		food_color = "#633821"
		food_effects = list("food_hp_up","food_energized")
		griddle_result = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/banana

	brain
		name = "slice of brain bread"
		desc = "A slice of bread that may or may not be plotting world domination."
		icon_state = "brainbreadslice"
		amount = 1
		heal_amt = 3
		real_name = "brain bread"
		food_color = "#DD90A3"
		food_effects = list("food_hp_up_big")
		griddle_result = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/brain

	pumpkin
		name = "slice of pumpkin bread"
		desc = "A slice of a festive seasonal bread, vaguely like eating a loaf of pumpkin pie."
		icon_state = "pumpkinbreadslice"
		amount = 1
		heal_amt = 5
		real_name = "pumpkin bread"
		food_color = "#D99C1B"
		food_effects = list("food_hp_up", "food_all")

	elvis
		name = "slice of elvis bread"
		desc = "A slice of the most incredible bread you have ever seen."
		icon_state = "elvisslice"
		amount = 1
		heal_amt = 6
		real_name = "elvis bread"
		initial_volume = 30
		initial_reagents = list("bread"=5,"essenceofelvis"=25)
		food_effects = list("food_sweaty","food_energized")
		griddle_result = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/elvis

	spooky
		name = "slice of dread"
		desc = "A slice of the scariest bread imaginable, even scarier than the buns on a microwaved vending machine hamburger."
		icon_state = "dreadslice"
		amount = 1
		heal_amt = 2
		real_name = "dread"
		initial_volume = 20
		initial_reagents = list("bread"=5,"ectoplasm"=10)
		food_effects = list("food_all")
		griddle_result = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/spooky

	corn
		name = "piece of southern cornbread"
		desc = "A chunk of maize-based quickbread.  This variety, popular in the Southern United States, is not particularly sweet."
		icon_state = "cornbreadslice"
		heal_amt = 3
		real_name = "cornbread"
		food_color = "#BAAC2C"
		food_effects = list("food_all")


	corn/sweet
		name = "piece of northern cornbread"
		desc = "A chunk of sweet maize-based quickbread."
		initial_volume = 10
		initial_reagents = list("bread"=5,"cornsyrup"=5)
		food_effects = list("food_all", "food_energized")

	corn/sweet/honey
		name = "piece of honey cornbread"
		initial_volume = 20
		initial_reagents = list("bread"=5,"cornsyrup"=5,"honey"=10)

	New()
		..()
		src.pixel_x += rand(-3,3)
		src.pixel_y += rand(-3,3)

	attackby(obj/item/W as obj, mob/user as mob,var/params)
		//WE CAN MAKE FUCKING HOTDOGS --redd
		if (istype(W, /obj/item/reagent_containers/food/snacks/hotdog))
			return W.attackby(src, user)
		if (istype(W,/obj/item/reagent_containers/food/snacks/breadslice))
			if (sandwichitems.len >= 1)
				src.finish_sandwich(W,user)
			else
				boutput(user,"<span class='notice'>This sandwich isn't finished yet!</span>")
			return
		if (istype(W,/obj/item/reagent_containers/food))
			if (sandwichitems.len < max_items)
				src.add_contents(W,user,params)
			else
				boutput(user,"<span class='alert'>There's too much on [src] already!</span>")
			return
		..()

/obj/item/reagent_containers/food/snacks/breadslice/toastslice
	name = "slice of toast"
	desc = "Crispy cooked bread."
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "toast"
	amount = 2
	heal_amt = 1
	food_color = "#CC9966"
	real_name = "toast"
	food_effects = list("food_warm", "food_hp_up")
	var/obj/item/reagent_containers/food/snacks/toastcheese/cheeseresult
	var/obj/item/reagent_containers/food/snacks/toastbacon/baconresult

	attackby(obj/item/W, mob/user)
		if (istype(W,/obj/item/reagent_containers/food/snacks/ingredient/cheese))
			cheeseresult = new()
			src.reagents.trans_to(cheeseresult,src.reagents.total_volume)
			cheeseresult.set_loc(src.loc)
			cheeseresult.pixel_x = src.pixel_x
			cheeseresult.pixel_y = src.pixel_y
			user.u_equip(src)
			user.put_in_hand_or_drop(cheeseresult)
			boutput(user,"<span class='notice'>You put [W] on [src].</span>")
			qdel(src)
		if (istype(W,/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon))
			baconresult = new()
			src.reagents.trans_to(baconresult,src.reagents.total_volume)
			baconresult.set_loc(src.loc)
			baconresult.pixel_x = src.pixel_x
			baconresult.pixel_y = src.pixel_y
			user.u_equip(src)
			user.put_in_hand_or_drop(baconresult)
			boutput(user,"<span class='notice'>You put [W] on [src].</span>")
			qdel(src)
		..()


	banana
		name = "slice of banana toast"
		desc = "A less conventional form of crispy bread."
		icon_state = "bananatoast"
		amount = 2
		heal_amt = 4
		food_effects = list("food_warm", "food_energized")

	brain
		name = "slice of brain toast"
		desc = "Historians believe that brain toast originated due to a garbled request for crispy bread made from wheat bran."
		icon_state = "braintoast"
		amount = 2
		heal_amt = 3
		real_name = "brain toast"
		food_effects = list("food_warm", "food_hp_up_big")

	elvis
		name = "slice of elvis toast"
		desc = "Just when you thought Elvis couldn't get any hotter."
		icon_state = "elvistoast"
		amount = 2
		heal_amt = 5
		real_name = "elvis toast"
		initial_volume = 30
		initial_reagents = list("bread"=5,"essenseofelvis"=25)
		food_effects = list("food_warm", "food_energized")
		cheeseresult = /obj/item/reagent_containers/food/snacks/toastcheese/elvis
		baconresult = /obj/item/reagent_containers/food/snacks/toastbacon/elvis

	spooky
		name = "slice of terror toast"
		desc = "It's scarier than regular toast.  That doesn't really say much unless you are going low-carb though."
		icon_state = "terrortoast"
		amount = 2
		heal_amt = 2
		real_name = "terror toast"
		food_effects = list("food_warm", "food_all")

	New()
		..()
		src.pixel_x += rand(-3,3)
		src.pixel_y += rand(-3,3)

/obj/item/reagent_containers/food/snacks/toastcheese
	name = "cheese on toast"
	desc = "A quick cheesy snack."
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "cheesetoast"
	amount = 2
	heal_amt = 2
	food_color = "#CC9966"
	real_name = "toast cheese"
	initial_volume = 10
	initial_reagents = list("bread"=5,"cheese"=5)
	food_effects = list("food_warm", "food_burn", "food_hp_up")

	elvis
		name = "cheese on elvis toast"
		desc = "The king of cheesy toast."
		icon_state = "cheesyelvis"
		amount = 3
		heal_amt = 6
		real_name = "elvis cheese toast"
		initial_volume = 35
		initial_reagents = list("bread"=5,"cheese"=5,"essenseofelvis"=25)

	New()
		..()
		src.pixel_x += rand(-3,3)
		src.pixel_y += rand(-3,3)

/obj/item/reagent_containers/food/snacks/toastbacon
	name = "bacon on toast"
	desc = "Is this a real snack anywhere? Honestly?"
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "bacontoast"
	amount = 2
	heal_amt = 3
	food_color = "#CC9966"
	real_name = "bacon toast"
	initial_volume = 10
	initial_reagents = list("bread"=5,"porktonium"=5)
	food_effects = list("food_warm", "food_burn", "food_hp_up")

	elvis
		name = "bacon on elvis toast"
		desc = "Oh, come on. That just does not look healthy."
		icon_state = "baconelvis"
		amount = 3
		heal_amt = 4
		real_name ="bacon elvis toast"
		initial_volume = 35
		initial_reagents = list("bread"=5,"porktonium"=5,"essenseofelvis"=25)

	New()
		..()
		src.pixel_x += rand(-3,3)
		src.pixel_y += rand(-3,3)

/obj/item/reagent_containers/food/snacks/toastegg
	name = "eggs on toast"
	desc = "Crunchy, eggy goodness."
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "eggtoast"
	amount = 2
	heal_amt = 3
	food_color = "#CC9966"
	real_name = "eggs on toast"
	initial_volume = 30
	food_effects = list("food_hp_up","food_deep_burp")

	elvis
		name = "eggs on elvis toast"
		desc = "More than enough calories to make you leave the metaphorical building."
		icon_state = "eggelvis"
		amount = 3
		heal_amt = 6
		real_name ="eggs on elvis toast"

		New()
			..()
			reagents.add_reagent("essenceofelvis",25)

	New()
		..()
		src.pixel_x += rand(-3,3)
		src.pixel_y += rand(-3,3)

/obj/item/baguette
	name = "baguette"
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "baguette"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	throwforce = 1
	w_class = W_CLASS_NORMAL
	throw_speed = 4
	throw_range = 5
	desc = "Hon hon hon, oui oui! Needs to be cut into slices before eating."
	stamina_damage = 5
//	stamina_cost = 1
	var/slicetype = /obj/item/reagent_containers/food/snacks/breadslice/baguette

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		BLOCK_SETUP(BLOCK_ROD)

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/axe) || istype(W, /obj/item/circular_saw) || istype(W, /obj/item/kitchen/utensil/knife) || istype(W, /obj/item/scalpel) || istype(W, /obj/item/sword) || istype(W,/obj/item/knife/butcher))
			if(user.bioHolder.HasEffect("clumsy") && prob(50))
				user.visible_message("<span class='alert'><b>[user]</b> fumbles and jabs [himself_or_herself(user)] in the eye with [W].</span>")
				user.change_eye_blurry(5)
				user.changeStatus("weakened", 3 SECONDS)
				JOB_XP(user, "Clown", 2)
				return

			user.visible_message("[user] cuts [src] into slices. Magnifique!", "You cut [src] into slices. Magnifique!")
			for (var/i=0, i <= 1, i++)
				var/obj/item/reagent_containers/food/snacks/breadslice/baguette/B
				B = new()
				if(i == 0)
					B.icon_state = "baguette-top"
				B.set_loc(src.loc)
			qdel (src)
		else ..()

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] attempts to beat [him_or_her(user)]self to death with the baguette, oui oui, but fails! Hon hon hon!</b></span>")
		user.suiciding = 0
		return 1

/obj/item/reagent_containers/food/snacks/garlicbread
	name = "garlic bread"
	desc = "Garlic, butter and bread. Usually seen alongside pasta and pizza."
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "garlicbread"
	amount = 2
	heal_amt = 4
	food_color = "#ffe87a"
	initial_volume = 20
	initial_reagents = list("garlic"=20)
	food_effects = list("food_tox","food_hp_up_big","food_bad_breath")

/obj/item/reagent_containers/food/snacks/garlicbread_ch
	name = "cheesy garlic bread"
	desc = "Garlic, butter, bread AND cheese. Usually seen alongside pasta and pizza."
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "garlicbread_ch"
	amount = 2
	heal_amt = 4
	food_color = "#ffe87a"
	initial_volume = 20
	initial_reagents = list("garlic"=10,"cheese"=10)
	food_effects = list("food_tox","food_hp_up_big","food_bad_breath","food_energized")

/obj/item/reagent_containers/food/snacks/fairybread
	name = "fairy bread"
	desc = "A traditional delicacy of Australian origin."
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "fairybread"
	amount = 2
	heal_amt = 2
	food_color = "#ffcdfb"
	initial_volume = 10
	initial_reagents = list("bread"=5,"sugar"=5)
	food_effects = list("food_refreshed_big")
