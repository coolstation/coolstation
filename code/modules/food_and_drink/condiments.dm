// Condiments

/obj/item/reagent_containers/food/snacks/condiment
	name = "condiment"
	desc = "you shouldnt be able to see this"
	icon = 'icons/obj/foodNdrink/food_ingredient.dmi'
	amount = 1
	heal_amt = 0

	heal(var/mob/M)
		boutput(M, "<span class='alert'>It's just not good enough on its own...</span>")

	afterattack(atom/target, mob/user, flag)
		if (!src.reagents || src.qdeled || src.pooled) return //how

		if (istype(target, /obj/item/reagent_containers/food/snacks/))
			user.visible_message("<span class='notice'>[user] adds [src] to \the [target].</span>", "<span class='notice'>You add [src] to \the [target].</span>")
			src.reagents.trans_to(target, 100)
			qdel (src)
			return

		if (istype(target, /obj/item/reagent_containers/))
			user.visible_message("<span class='notice'><b>[user]</b> crushes up \the [src] in \the [target].</span>",\
			"<span class='notice'>You crush up \the [src] in \the [target].</span>")
			src.reagents.trans_to(target, 100)
			qdel (src)

		else return

/obj/item/reagent_containers/food/snacks/condiment/ironfilings
	name = "iron filings"
	desc = "You probably shouldn't eat these."
	icon_state = "ironfilings"
	heal_amt = 0
	amount = 1


/obj/item/reagent_containers/food/snacks/condiment/tomato_sauce
	name = "tomato sauce"
	desc = "Pureéd tomatoes as a sauce, straight up."
	icon = 'icons/obj/foodNdrink/food.dmi'
	icon_state = "can-tomato"
	initial_volume = 30
	initial_reagents = list("tomato_sauce"=25)

/obj/item/reagent_containers/food/snacks/condiment/ketchup
	name = "ketchup"
	desc = "Pureéd tomatoes as a sauce, thickened with sugar."
	icon_state = "sachet-ketchup"
	initial_volume = 30
	initial_reagents = list("ketchup"=20)

/obj/item/reagent_containers/food/snacks/condiment/syrup
	name = "maple syrup"
	desc = "Made with real artificial maple syrup!"
	icon_state = "syrup"

/obj/item/reagent_containers/food/snacks/condiment/mayo
	name = "mayonnaise"
	desc = "The subject of many a tiresome innuendo."
	icon_state = "mayonnaise"
	initial_volume = 15
	initial_reagents = list("mayonnaise"=10)

/obj/item/reagent_containers/food/snacks/condiment/hotsauce
	name = "hot sauce"
	desc = "Dangerously spicy!"
	icon_state = "sachet-hot"
	initial_volume = 100
	initial_reagents = "capsaicin"

/obj/item/reagent_containers/food/snacks/condiment/coldsauce
	name = "cold sauce"
	desc = "This isn't very hot at all!"
	icon_state = "sachet-cold"
	initial_volume = 100
	initial_reagents = "cryostylane"

/obj/item/reagent_containers/food/snacks/condiment/hotsauce/ghostchilisauce
	name = "incredibly hot sauce"
	desc = "Extraordinarily spicy!"
	icon_state = "sachet-hot"
	initial_volume = 100
	initial_reagents = list("capsaicin"=50,"ghostchilijuice"=50)

/obj/item/reagent_containers/food/snacks/condiment/syndisauce
	name = "syndicate sauce"
	desc = "Traitorous tang."
	icon_state = "sachet-cold"
	initial_volume = 100
	initial_reagents = list("amanitin"=50)

/obj/item/reagent_containers/food/snacks/condiment/cream
	name = "cream"
	desc = "Not related to any kind of crop."
	icon_state = "cream" //ITS NOT A GODDAMN COOKIE
	food_color = "#F8F8F8"

/obj/item/reagent_containers/food/snacks/condiment/custard
	name = "custard"
	desc = "A perennial favourite of clowns."
	icon_state = "custard"
	needspoon = 1
	amount = 2
	heal_amt = 3

	attackby(obj/item/W, mob/user)
		if (isweldingtool(W))
			if (W:try_weld(user,1))
				boutput(user, "<span=notice>You use the welding tool to make a nice dessert. A bit overkill though, don't you think?</span>")
				qdel(src)
				user.put_in_hand_or_drop(new /obj/item/reagent_containers/food/snacks/creme_brulee)
				return
		..()


/obj/item/reagent_containers/food/snacks/condiment/chocchips
	name = "chocolate chips"
	desc = "Mmm! Little bits of chocolate! Or rabbit droppings. Either or."
	icon_state = "chocchips"
	amount = 5
	heal_amt = 1
	initial_volume = 10
	initial_reagents = "chocolate"

	afterattack(atom/target, mob/user, flag)
		if (istype(target, /obj/item/reagent_containers/food/snacks/) && src.reagents) //Wire: fix for Cannot execute null.trans to()
			user.visible_message("<span class='notice'>[user] sprinkles [src] onto [target].</span>", "<span class='notice'>You sprinkle [src] onto [target].</span>")
			src.reagents.trans_to(target, 20)
			qdel (src)
		else return

/obj/item/reagent_containers/food/snacks/condiment/butters
	name = "butt-er"
	desc = "Fluffy and fragrant."
	icon_state = "butters"
	amount = 1
	heal_amt = 3
	initial_volume = 20

	New()
		..()
		reagents.add_reagent("cholesterol", 20)

/obj/item/shaker // todo: rewrite shakers to not be horrible hacky nonsense - haine
	name = "shaker"
	desc = "A little bottle for shaking things onto other things."
	icon = 'icons/obj/foodNdrink/food.dmi'
	icon_state = "shaker"
	flags = FPRINT | TABLEPASS | ONBELT
	w_class = W_CLASS_SMALL
	g_amt = 10
	var/stuff = null
	var/shakes = 0
	var/myVerb = "shake"

	afterattack(atom/A, mob/user as mob)
		if (src.shakes >= 15)
			user.show_text("[src] is empty!", "red")
			return
		if (istype(A, /obj/item/reagent_containers/food))
			A.reagents.add_reagent("[src.stuff]", 2)
			src.shakes ++
			user.show_text("You put some [src.stuff] onto [A].")
		else if (istype(A, /obj/item/reagent_containers/glass/beaker))
			A.reagents.add_reagent("[src.stuff]", 5)
			src.shakes += 5
			user.show_text("You [src.myVerb] some [src.stuff] into [A]")
		else
			return ..()

	attack(mob/M as mob, mob/user as mob)
		if (src.shakes >= 15)
			user.show_text("[src] is empty!", "red")
			return
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if ((H.head && H.head.c_flags & COVERSEYES) || (H.wear_mask && H.wear_mask.c_flags & COVERSEYES) || (H.glasses && H.glasses.c_flags & COVERSEYES))
				H.tri_message("<span class='alert'><b>[user]</b> uselessly [myVerb]s some [src.stuff] onto [H]'s headgear!</span>",\
				H, "<span class='alert'>[H == user ? "You uselessly [myVerb]" : "[user] uselessly [myVerb]s"] some [src.stuff] onto your headgear! Okay then.</span>",\
				user, "<span class='alert'>You uselessly [myVerb] some [src.stuff] onto [user == H ? "your" : "[H]'s"] headgear![user == H ? " Okay then." : null]</span>")
				src.shakes ++
				return
			else
				switch (src.stuff)
					if ("salt")
						H.tri_message("<span class='alert'><b>[user]</b> [myVerb]s something into [H]'s eyes!</span>",\
						H, "<span class='alert'>[H == user ? "You [myVerb]" : "[user] [myVerb]s"] some salt into your eyes! <B>FUCK!</B></span>",\
						user, "<span class='alert'>You [myVerb] some salt into [user == H ? "your" : "[H]'s"] eyes![user == H ? " <B>FUCK!</B>" : null]</span>")
						H.emote("scream")
						random_brute_damage(user, 2) //small buff, need to decide if we're going to use the organ eye-damage/blindness proc. we want old combat but maybe not screwdriver-targeting eyes combat
						H.change_eye_blurry(15, 30) //good barfight initiator
						src.shakes ++
						return
					if ("pepper")
						H.tri_message("<span class='alert'><b>[user]</b> [myVerb]s something onto [H]'s nose!</span>",\
						H, "<span class='alert'>[H == user ? "You [myVerb]" : "[user] [myVerb]s"] some pepper onto your nose! <B>Why?!</B></span>",\
						user, "<span class='alert'>You [myVerb] some pepper onto [user == H ? "your" : "[H]'s"] nose![user == H ? " <B>Why?!</B>" : null]</span>")
						H.emote("sneeze")
						src.shakes ++
						for (var/i = 1, i <= 30, i++)
							SPAWN_DBG(50*i)
								if (H && prob(20)) //Wire: Fix for Cannot execute null.emote().
									H.emote("sneeze")
						return
					if ("redpepper") //a little more dastardly and handles the missing space
						H.tri_message("<span class='alert'><b>[user]</b> [myVerb]s red pepper flakes into [H]'s eyes!</span>",\
						H, "<span class='alert'>[H == user ? "You [myVerb]" : "[user] [myVerb]s"] some red pepper flakes into your eyes! <B>ARGH!</B></span>",\
						user, "<span class='alert'>You [myVerb] some red pepper flakes into [user == H ? "your" : "[H]'s"] eyes![user == H ? " <B>Why?!</B>" : null]</span>")
						H.emote("scream")
						random_brute_damage(user, 2)
						H.change_eye_blurry(10, 20) //less effective for blurriness, doesn't fly like salt
						src.shakes ++
						return
					if ("capsaicin")
						H.tri_message("<span class='alert'><b>[user]</b> [myVerb]s hot sauce into [H]'s eyes!</span>",\
						H, "<span class='alert'>[H == user ? "You [myVerb]" : "[user] [myVerb]s"] some hot sauce into your eyes! <B>ARGH!</B></span>",\
						user, "<span class='alert'>You [myVerb] some hot sauce into [user == H ? "your" : "[H]'s"] eyes![user == H ? " <B>Why?!</B>" : null]</span>")
						H.emote("scream")
						random_brute_damage(user, 5)
						H.change_eye_blurry(15, 30) //fuck
						src.shakes ++
						return
					if ("garlic")
						if (isvampire(H))
							H.tri_message("<span class='alert'><b>[user]</b> [myVerb]s garlic powder into [H]'s face!</span>",\
							H, "<span class='alert'>[H == user ? "You [myVerb]" : "[user] [myVerb]s"] some garlic into your face! <B>FUCK, it BURNS your whole dracula business!</B></span>",\
							user, "<span class='alert'>You [myVerb] some garlic into [user == H ? "your" : "[H]'s"] face![user == H ? " <B>FUCK! Why would you DO THIS? That's GARLIC! You're a DRACULA!</B>" : null]</span>")
							H.emote("scream")
							for(var/mob/O in AIviewers(M, null))
								O.show_message(text("<span class='alert'><b>[] begins to crisp and burn!</b></span>", H), 1)
							H.TakeDamage("head", 0, 6.25, 0, DAMAGE_BURN)
							H.change_vampire_blood(-5)
							H.change_eye_blurry(15, 30)
						else
							H.tri_message("<span class='alert'><b>[user]</b> [myVerb]s garlic powder into [H]'s face!</span>",\
							H, "<span class='alert'>[H == user ? "You [myVerb]" : "[user] [myVerb]s"] some garlic into your face! Kind of annoying.</span>",\
							user, "<span class='alert'>You [myVerb] some garlic into [user == H ? "your" : "[H]'s"] face![user == H ? " <B>Great job.</B>" : null]</span>")
							H.change_eye_blurry(2, 5)
						src.shakes ++
						return
					else
						H.tri_message("<span class='alert'><b>[user]</b> [myVerb]s some [src.stuff] at [H]'s head!</span>",\
						H, "<span class='alert'>[H == user ? "You [myVerb]" : "[user] [myVerb]s"] some [src.stuff] at your head! Fuck!</span>",\
						user, "<span class='alert'>You [myVerb] some [src.stuff] at [user == H ? "your" : "[H]'s"] head![user == H ? " Fuck!" : null]</span>")
						src.shakes ++
						return
		else if (istype(M, /mob/living/critter/small_animal/slug) && src.stuff == "salt")
			M.visible_message("<span class='alert'><b>[user]</b> [myVerb]s some salt onto [M] and it shrivels up!</span>",\
			"<span class='alert'><b>OH GOD THE SALT [pick("IT BURNS","HOLY SHIT THAT HURTS","JESUS FUCK YOU'RE DYING")]![pick("","!","!!")]</b></span>")
			M.TakeDamage(null, 15, 15)
			src.shakes ++
			return

		else
			return ..()

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/))
			if (W.reagents.has_reagent("[src.stuff]") && W.reagents.get_reagent_amount("[src.stuff]") >= 15)
				user.show_text("You refill [src].", "blue")
				W.reagents.remove_reagent("[src.stuff]", 15)
				src.shakes = 0
				return
			else
				user.show_text("There isn't enough [src.stuff] in here to refill [src]!", "red")
				return
		else
			return ..()

	salt
		name = "salt shaker"
		desc = "A little bottle for shaking things onto other things. It has some salt in it."
		icon_state = "shaker-salt"
		stuff = "salt"

	pepper
		name = "pepper shaker"
		desc = "A little bottle for shaking things onto other things. It has some pepper in it."
		icon_state = "shaker-pepper"
		stuff = "pepper"

	parmesan
		name = "parmesan shaker"
		desc = "A little round glass shaker you see at certain restaurants. It has some parmesan cheese in it."
		icon_state = "shaker-parmesan"
		stuff = "parmesan"

	garlic
		name = "garlic powder shaker"
		desc = "A little bottle for shaking things onto other things. It has some garlic powder in it."
		icon_state = "shaker-garlic"
		stuff = "garlic"

	//oregano is sprited but pointless mechanically, unlike garlic

	redpepper
		name = "red pepper shaker"
		desc = "A little round glass shaker you see at certain restaurants. It has some red pepper flakes in it."
		icon_state = "shaker-redpepper"
		stuff = "redpepper" //hacky nonsense is right, sheesh

		afterattack(atom/A, mob/user as mob) //this is just to cut out the "puts some redpepper onto the spagheto" message
			if (src.shakes >= 15)
				user.show_text("[src] is empty!", "red") //todo: add the empty sprites for parmesan and red pepper flakes (and also salt and pepper)
				return
			if (istype(A, /obj/item/reagent_containers/food))
				A.reagents.add_reagent("[src.stuff]", 2)
				src.shakes ++
				user.show_text("You shake some red pepper flakes onto [A].")
			else if (istype(A, /obj/item/reagent_containers/glass/beaker))
				A.reagents.add_reagent("[src.stuff]", 5)
				src.shakes += 5
				user.show_text("You [src.myVerb] some red pepper flakes into [A]")
			else
				return ..()

	ketchup
		name = "ketchup bottle"
		desc = "A little bottle for putting condiments on stuff. It has some ketchup in it."
		icon_state = "bottle-ketchup"
		stuff = "ketchup"
		myVerb = "squirt"

	mustard
		name = "mustard bottle"
		desc = "A little bottle of John Johnsson's finest mustard. It has a picture of a fire-fighting boat on it for some reason."
		icon_state = "bottle-mustard"
		stuff = "mustard"
		myVerb = "squirt"

	mayo
		name = "mayonnaise bottle"
		desc = "A little bottle of mayonnaise. It's... completely unbranded? But it's definitely mayonnaise in there."
		icon_state = "bottle-mayo"
		stuff = "mayonnaise"
		myVerb = "squirt"

	hot
		name = "hot sauce bottle"
		desc = "A little bottle of Juicy-Hot medium-batch hot sauce. No compromises in this one: just pure, self-grown hot peppers, mashed and fermented in someone's bathtub."
		icon_state = "bottle-hot"
		stuff = "capsaicin"
		myVerb = "splash"

		afterattack(atom/A, mob/user as mob) //at this point the ketchup and mustard and etc. needs a refactor into regular bottles, refillable, reagent based transfer, and so on. but at least the items are there and open for more fun. especially if we find a mix between reagent and item based cooking
			if (src.shakes >= 15)
				user.show_text("[src] is empty!", "red") //todo: add the empty sprites for parmesan and red pepper flakes (and also salt and pepper)
				return
			if (istype(A, /obj/item/reagent_containers/food))
				A.reagents.add_reagent("[src.stuff]", 2)
				src.shakes ++
				user.show_text("You [src.myVerb] some hot sauce onto [A].")
			else if (istype(A, /obj/item/reagent_containers/glass/beaker))
				A.reagents.add_reagent("[src.stuff]", 5)
				src.shakes += 5
				user.show_text("You [src.myVerb] some hot sauce into [A]")
			else
				return ..()

	//todo: add ranch, bbq

	//also todo: revamp self-mob interactions so you can fuckin' slurp down mayo and ranch straight from the bottle

/// the present implementation of condiment bottles isnt my favorite, i might reinvent the wheel about it later - mylie
/obj/item/reagent_containers/glass/food_dye
	name = "food coloring bottle"
	desc = "A bottle of potent food coloring."
	item_state = "beaker"
	initial_volume = 10
	splash_all_contents = 0
	amount_per_transfer_from_this = 0.5
	can_mousedrop = FALSE
	can_recycle = FALSE
	w_class = W_CLASS_TINY
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO

/obj/item/reagent_containers/glass/food_dye/red
	name = "red coloring bottle"
	icon_state = "food_coloring_red"
	initial_reagents = "dye_red"

/obj/item/reagent_containers/glass/food_dye/green
	name = "green coloring bottle"
	icon_state = "food_coloring_green"
	initial_reagents = "dye_green"

/obj/item/reagent_containers/glass/food_dye/blue
	name = "blue coloring bottle"
	icon_state = "food_coloring_blue"
	initial_reagents = "dye_blue"
