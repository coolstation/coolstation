
// Drinks

/obj/item/reagent_containers/food/drinks/bottle/soda/red
	name = "Robust-Eez"
	desc = "A carbonated robustness tonic. It has quite a kick."
	label = "robust"
	heal_amt = 1
	labeled = 1
	initial_volume = 65
	initial_reagents = list("methamphetamine"=10,"VHFCS"=10,"cola"=40)

/obj/item/reagent_containers/food/drinks/bottle/soda/blue
	name = "Grife-O"
	desc = "The carbonated beverage of a space generation. Contains actual space dust!"
	label = "grife"
	labeled = 1
	initial_volume = 65
	initial_reagents = list("radium"=8,"ephedrine"=12,"VHFCS"=10,"cola"=30)

/obj/item/reagent_containers/food/drinks/bottle/soda/pink
	name = "Dr. Pubber"
	desc = "The beverage of an original crowd. Tastes like an industrial tranquilizer."
	label = "pubber"
	labeled = 1
	initial_volume = 65
	initial_reagents = list("haloperidol"=10,"morphine"=10,"VHFCS"=10,"cola"=30)

/obj/item/reagent_containers/food/drinks/bottle/soda/pee
	name = "Mr. Piss"
	desc = "Originally a knockoff of Dr. Pubber. Still unpopular despite the reformulation and rebrand."
	label = "piss"
	labeled = 1
	initial_volume = 65
	initial_reagents = list("urine"=12,"haloperidol"=4,"morphine"=4,"VHFCS"=10,"cola"=30)

/obj/item/reagent_containers/food/drinks/bottle/soda/poo //now will cause food poisoning but only if you drink two of them real quick like
	name = "Mountain Poo"
	desc = "Fuck, wasn't this stuff banned over a decade ago? Looks like someone took over the copyright and made up a new recipe."
	label = "poo"
	labeled = 1
	initial_volume = 65
	initial_reagents = list("poo"=2,"cocktail_citrus"=10,"ecoli"=8,"VHFCS"=10,"cola"=30) //legal minimum of poo without running afoul of false advert laws

/obj/item/reagent_containers/food/drinks/bottle/soda/italian //beverly + beef
	name = "Cappy Cola"
	desc = "Nuovo! Soda al gusto di prosciutto!"
	label = "italian"
	labeled = 1
	initial_volume = 65
	initial_reagents = list("beff"=6,"bacon"=6,"pepperoni"=6,"bitters"=2,"VHFCS"=5,"cola"=25) //it's even worse now

/obj/item/reagent_containers/food/drinks/bottle/soda/lime
	name = "Lime-Aid"
	desc = "Antihol mixed with lime juice. A well-known cure for hangovers."
	label = "limeaid"
	labeled = 1
	initial_volume = 65
	initial_reagents = list("antihol"=30,"juice_lime"=30)

/obj/item/reagent_containers/food/drinks/bottle/soda/spooky //might be worth making seasonal sodas just because it'd be funny
	name = "Spooky Dan's Runoff Cola"
	desc = "A spoooky cola for Halloween!  Rumors that Runoff Cola contains actual industrial runoff are unsubstantiated."
	label = "spooky"
	labeled = 1
	initial_volume = 65
	initial_reagents = list("chlorine"=5,"phosphorus"=5,"mercury"=5,"VHFCS"=10,"cola"=35)

/obj/item/reagent_containers/food/drinks/bottle/soda/spooky2
	name = "Spooky Dan's Horrortastic Cola"
	desc = "A terrifying Halloween soda.  It's especially frightening if you're diabetic."
	label = "spooky"
	labeled = 1
	initial_volume = 65
	initial_reagents = list("ectoplasm"=20,"sulfur"=5,"VHFCS"=5,"cola"=30)

/obj/item/reagent_containers/food/drinks/bottle/soda/xmas
	name = "Happy Elf Hot Chocolate"
	desc = "Surprising to see this here, in a world of corporate plutocrat lunatics."
	label = "choco"
	labeled = 1
	initial_volume = 35
	initial_reagents = list("chocolate"=30)

	New()
		if (prob(10))
			src.initial_reagents["grognardium"] = 5
		..()

/obj/item/reagent_containers/food/drinks/bottle/soda/bottledwater
	name = "Decirprevo Bottled Water"
	desc = "Bottled from our cool natural springs on Europa."
	label = "water"
	labeled = 1
	initial_volume = 100 //a whole liter.....
	initial_reagents = list("iodine"=15,"water"=85)
	value = 5
	alt_value = 50

/obj/item/reagent_containers/food/drinks/bottle/soda/softsoft_pizza
	name = "Soft Soft Pizza"
	desc = "Pizza so soft you can drink it!"
	label= "pizza"
	labeled = 1
	initial_volume = 65
	initial_reagents = list("pizza" = 50, "salt" = 10)

/obj/item/reagent_containers/food/drinks/bottle/soda/grones
	name = "Grones Soda "
	desc = "They make all kinds of flavors these days, good lord."
	label = "grones"
	heal_amt = 1
	labeled = 1
	initial_volume = 65 //20 ounce
	initial_reagents = list("cola"=40)
	value = 25

	New()
		switch(rand(1,16))
			if (1)
				src.name += "Crunchy Kidney Stone Lemonade flavor"
				src.initial_reagents["urine"] = 20
			if (2)
				src.name += "Radical Roadkill Rampage flavor"
				src.initial_reagents["bloodc"] = 20 // heh
			if (3)
				src.name += "Awesome Asbestos Candy Apple flavor"
				src.initial_reagents["lithium"] = 20
			if (4)
				src.name += "Salt-Free Senile Dementia flavor"
				src.initial_reagents["mercury"] = 20
			if (5)
				src.name += "High Fructose Traumatic Stress Disorder flavor"
				src.initial_reagents["atropine"] = 20
			if (6)
				src.name += "Tangy Dismembered Orphan Tears flavor"
				src.initial_reagents["epinephrine"] = 20
			if (7)
				src.name += "Chunky Infected Laceration Salsa flavor"
				src.initial_reagents["charcoal"] = 20
			if (8)
				src.name += "Manic Depressive Multivitamin Dewberry flavor"
				src.initial_reagents["ephedrine"] = 20
			if (9)
				src.name += "Anti-Bacterial Air Freshener flavor"
				src.initial_reagents["spaceacillin"] = 20
			if (10)
				src.name += "Old Country Hay Fever flavor"
				src.initial_reagents["antihistamine"] = 20
			if (11)
				src.name += "Minty Restraining Order Pepper Spray flavor"
				src.initial_reagents["capsaicin"] = 20
			if (12)
				src.name += "Cool Keratin Rush flavor"
				src.initial_reagents["hairgrownium"] = 20
			if (13)
				src.name += "Rancher's Rage Whole Chicken Dinner flavor" //by Splints/FireMoose
				src.initial_reagents += (list("chickensoup"=5, "juice_cran"=5, "juice_carrot"=5, "mashedpotatoes"=3,
				 "gravy"=2)) //removed ether to fit 60
				src.label = "rancher"
			if (14)
				src.name += "Prismatic Rainbow Punch flavor" //by Genesse
				src.initial_reagents += (list("sparkles"=6.6, "colors"=6.6, "space_drugs"=6.7))
				src.label = "rainbow"
			if (15)
				src.name += "Hearty Hellburn Brew flavor" //by Eagletanker
				src.initial_reagents += (list("oxygen"=12, "plasma"=4, "ghostchilijuice"=1, "carbon"=3))
				src.desc = "9/10 Engineers prefered Grones Hearty Hellburn, find out why yourself!"
				src.label = "engine"
			if (16)
				src.name += "Citrus Circus Catastrophe flavor" //by Coolvape
				src.initial_reagents += (list("juice_lemon"=5, "juice_lime"=5, "honk_fart"=5, "honky_tonic"=5))
				src.label = "clown"

		..()

/obj/item/reagent_containers/food/drinks/bottle/soda/orange
	name = "Orange-Aid"
	desc = "A vitamin tonic that promotes good eyesight and health."
	label = "orangeaid"
	heal_amt = 1
	labeled = 1
	initial_volume = 65
	initial_reagents = list("oculine"=30,"juice_orange"=30)

/obj/item/reagent_containers/food/drinks/bottle/soda/gingerale
	name = "Delightful Dan's Ginger Ale"
	desc = "Ginger ale is known for its soothing, healing, and beautifying properties. So claims this compostable, recycled, and eco-friendly paper label."
	label = "gingerale"
	heal_amt = 1
	labeled = 1
	initial_volume = 50
	initial_reagents = "ginger_ale"

/obj/item/reagent_containers/food/drinks/bottle/soda/drowsy
	name = "Drowsy Dan's Terrific Tonic"
	desc = "You'll be fast asleep in no time!"
	label = "drowsy"
	heal_amt = 1
	labeled = 1
	initial_volume = 50
	initial_reagents = list("lemonade"=25,"ether"=25)

/obj/item/reagent_containers/food/drinks/water
	name = "water bottle"
	desc = "I wonder if this is still fresh?"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "bottlewater"
	item_state = "contliquid"
	initial_volume = 50 //good old 16.9oz
	initial_reagents = "water"

/obj/item/reagent_containers/food/drinks/tea
	name = "tea"
	desc = "A fine cup of tea.  Possibly Earl Grey.  Temperature undetermined."
	icon_state = "tea0"
	item_state = "coffee"
	initial_volume = 30
	initial_reagents = "tea"

	New()
		..()
		reagents.set_reagent_temp(T0C + 65) //little hotter than coffee

/obj/item/reagent_containers/food/drinks/tea/mugwort
	name = "mugwort tea"
	desc = "Rumored to have mystical powers of protection.<br>It has a message written on it: 'To the world's greatest wizard - love, Dad'"
	icon_state = "tea1"
	initial_volume = 50
	initial_reagents = list("tea"=30,"mugwort"=20)

/obj/item/reagent_containers/food/drinks/coffee
	name = "Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
	heal_amt = 1
	initial_volume = 25
	initial_reagents = list("coffee"=24)

	New()
		..()
		reagents.set_reagent_temp(T0C + 60) //top end of comfortable sipping

/obj/item/reagent_containers/food/drinks/eggnog
	name = "Egg Nog"
	desc = "A festive beverage made with eggs. Please eat the eggs. Eat the eggs up."
	icon_state = "nog"
	heal_amt = 1
	festivity = 1
	rc_flags = RC_FULLNESS
	initial_volume = 50
	initial_reagents = list("eggnog"=40)

/obj/item/reagent_containers/food/drinks/chickensoup
	name = "Chicken Soup"
	desc = "Got something to do with souls. Maybe. Do chickens even have souls?"
	icon_state = "soup"
	heal_amt = 1
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	initial_volume = 30
	can_recycle = FALSE
	initial_reagents = list("chickensoup"=30)

	New()
		..()
		reagents.set_reagent_temp(T0C + 55)

/obj/item/reagent_containers/food/drinks/weightloss_shake
	name = "Weight-Loss Shake"
	desc = "A shake designed to cause weight loss.  The package proudly proclaims that it is 'tapeworm free.'"
	icon_state = "shake"
	heal_amt = 1
	rc_flags = RC_FULLNESS
	initial_volume = 35
	initial_reagents = list("lipolicide"=30,"chocolate"=5)

/obj/item/reagent_containers/food/drinks/cola
	name = "space cola"
	desc = "Cola. in space."
	icon = 'icons/obj/foodNdrink/can.dmi'
	icon_state = "cola-1"
	item_state = "cola-1"
	heal_amt = 1
	rc_flags = RC_FULLNESS
	initial_volume = 35
	can_chug = 0
	initial_reagents = list("cola"=20,"VHFCS"=10)
	var/is_sealed = 1 //can you drink out of it?
	var/standard_override //is this a random cola or a standard cola (for crushed icons)

	New()
		..()
		if (prob(50))
			src.icon_state = "cola-2"

	attack(mob/M as mob, mob/user as mob)
		if (is_sealed)
			boutput(user, "<span class='alert'>You can't drink out of a sealed can!</span>") //idiot
			return
		..()

	attack_self(mob/user as mob)
		var/drop_this_shit = 0 //i promise this is useful
		if (src.is_sealed)
			user.visible_message("[user] pops the tab on \the [src]!", "You pop \the [src] open!")
			is_sealed = 0
			can_chug = 1
			playsound(src.loc, "sound/items/can_open.ogg", 50, 1)
			return
		if (!src.reagents || !src.reagents.total_volume)
			var/zone = user.zone_sel.selecting
			if (zone == "head")
				user.visible_message("<span class='alert'><b>[user] crushes \the [src] against their forehead!! [pick("Bro!", "Epic!", "Damn!", "Gnarly!", "Sick!",\
				"Crazy!", "Nice!", "Hot!", "What a monster!", "How sick is that?", "That's slick as shit, bro!")]", "You crush the can against your forehead! You feel super cool.")
				drop_this_shit = 1
			else
				user.visible_message("[user] crushes \the [src][pick(" one-handed!", ".", ".", ".")] [pick("Lame.", "Eh.", "Meh.", "Whatevs.", "Weirdo.")]", "You crush the can!")
			var/obj/item/crushed_can/C = new(get_turf(user))
			playsound(src.loc, "sound/items/can_crush-[rand(1,3)].ogg", 50, 1)
			C.crush_can(src.name, src.icon_state)
			user.u_equip(src)
			user.drop_item(src)
			if (!drop_this_shit) //see?
				user.put_in_hand_or_drop(C)
			qdel(src)

/obj/item/crushed_can
	name = "crushed can"
	desc = "This can's been totally crushed!"
	icon = 'icons/obj/foodNdrink/can.dmi'

	proc/crush_can(var/name, var/icon_state)
		src.name = "crushed [name]"
		switch(icon_state)
			if ("cola-1")
				src.icon_state = "crushed-1"
				return
			if ("cola-2")
				src.icon_state = "crushed-2"
				return
		var/list/iconsplit = splittext("[icon_state]", "-")
		src.icon_state = "crushed-[iconsplit[2]]"

/obj/item/reagent_containers/food/drinks/cola/random
	name = "space cola"
	desc = "You don't recognise this cola brand at all."
	icon = 'icons/obj/foodNdrink/can.dmi'
	heal_amt = 1
	rc_flags = RC_FULLNESS
	initial_volume = 35

	New()
		..()
		name = "[pick_string("chemistry_tools.txt", "COLA_prefixes")] [pick_string("chemistry_tools.txt", "COLA_suffixes")]"
		var/n = rand(1,26)
		icon_state = "cola-[n]"
		reagents.add_reagent("cola, 20")
		reagents.add_reagent("VHFCS, 10")
		reagents.add_reagent(pick_string("chemistry_tools.txt", "COLA_flavors"), 5, 3)

/obj/item/reagent_containers/food/drinks/peach
	name = "Delightful Dan's Peachy Punch"
	desc = "A vibrantly colored can of 100% all natural peach juice."
	icon = 'icons/obj/foodNdrink/can.dmi'
	icon_state = "peach"
	rc_flags = RC_FULLNESS
	initial_volume = 50
	initial_reagents = "juice_peach"

/obj/item/reagent_containers/food/drinks/milk
	name = "Creaca's Space Milk"
	desc = "A half-gallon bottle of fresh space milk from happy, free-roaming space cows."
	icon_state = "milk"
	item_state = "milk"
	var/icon_style = "milk"
	var/glass_style = "milk"
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	heal_amt = 1
	initial_volume = 190 //fuck it, half gallon
	initial_reagents = "milk"
	var/canberandom = 1

	var/image/fluid_image

	on_reagent_change()
		src.update_icon()

	proc/update_icon()
		src.underlays = null
		if (reagents.total_volume)
			var/fluid_state = round(clamp((src.reagents.total_volume / src.reagents.maximum_volume * 3 + 1), 1, 3))
			if (!src.fluid_image)
				src.fluid_image = image(src.icon, "fluid-milk[fluid_state]", -1)
			else
				src.fluid_image.icon_state = "fluid-milk[fluid_state]"
			src.icon_state = "milk[fluid_state]"
			var/datum/color/average = reagents.get_average_color()
			src.fluid_image.color = average.to_rgba()
			src.underlays += fluid_image
		else
			src.icon_state = "milk"

	New()
		if(canberandom == 1)
			if(prob(10))
				name = "Mootimer's Calcium Drink"
				desc = "Blue-ribbon winning secret family recipe. This one's a whole gallon!"
				icon_state = "milk_calcium"
				initial_volume = 380 //fuck it, full gallon
			else if(prob(1))
				name = "Nelvana's Bagged Milk" //but not literally
				desc = "In Space Quebec, milk comes in bags. Trois sacs font quatre litres!"
				icon_state = "milk_bag" //100% guaranteed not to look like a jizzing penis
				initial_volume = 133
				//later on, make pitchers to use this with and then turn up the player pranks on everyone who doesn't know how to use bagged milk
		..()

/obj/item/reagent_containers/food/drinks/milk/rancid
	name = "Rancid Space Milk"
	desc = "A half-gallon bottle of rancid space milk, left open and half-finished. Better not drink this stuff..."
	icon_state = "milk"
	heal_amt = 1
	initial_volume = 190
	initial_reagents = list("milk"=40,"toxin"=50, "gcheese"=10) //made it worse

/obj/item/reagent_containers/food/drinks/milk/clownspider
	name = "Honkey Gibbersons - Clownspider Milk"
	desc = "A half-gallon bottle of really - really colorful milk? The smell is sweet and looking at this envokes the same thrill as wanting to drink paint! Didn't even bother filling it up..."
	icon_state = "milk"
	heal_amt = 1
	initial_volume = 190
	initial_reagents = list("rainbow fluid" = 10, "milk" = 60)
	canberandom = 0

/obj/item/reagent_containers/food/drinks/milk/cluwnespider
	name = "Honkey Gibbersons - Cluwnespider Milk"
	desc = "A bottle of ... oh no! Do not look at it! Better never drink this colorful milk?!"
	icon_state = "milk"
	heal_amt = 1
	initial_volume = 190
	initial_reagents = list("painbow fluid" = 20, "milk" = 60)
	canberandom = 0

/obj/item/reagent_containers/food/drinks/milk/soy
	name = "Creaca's Space Soy Milk"
	desc = "A bottle of fresh space soy milk from happy, free-roaming space soybean plants. The plant pots just float around untethered."
	//it's just regular milk!!!

//originally by LuigiThirty but man I can't countenance a covfefe joke at all in this day and age
obj/item/reagent_containers/food/drinks/pseudocoffee
	name = "Wired Dan's Kafe Kick!"
	desc = "Some kind of ersatz drink that can't legally be called coffee. Actually, it's mostly water and whatever they could get cheap that day. Wait, wasn't this banned by the FDA?"
	icon_state = "coffee"
	heal_amt = 1
	initial_volume = 50

	New()
		..()
		if(prob(1)) // hi im cirr i fuck with peoples' patches hurr
			name = "Wired Dan's Chilled Cofefefe"
			reagents.add_reagent("cryostylane", 5)
		reagents.add_reagent("water", 25)
		reagents.add_reagent("UGHFCS", 5)
		reagents.add_reagent(pick("methamphetamine", "crank", "space_drugs", "cat_drugs", "coffee"), 5)
		for(var/i=0; i<3; i++)
			reagents.add_reagent(pick("beff","ketchup","eggnog","yuck","chocolate","vanilla","cleaner","capsaicin","toxic_slurry","luminol","urine","nicotine","weedkiller","venom","jenkem","ectoplasm"), 5)

/obj/item/reagent_containers/food/drinks/bottle/soda/contest
	name = "Grones Soda Call 1-800-IMCODER flavour"
	desc = "They make all kinds of flavors these days, good lord."
	label = "grones"
	heal_amt = 1
	labeled = 1
	initial_volume = 65

	lizard_tonic
		name = "Grones Soda Lucky Lizard Tonic flavor" //by Rlocks
		label = "lizard"
		initial_reagents = (list("cola"=30, "yee"=5, "chalk"=5, "sangria"=10, "capsaicin"=10))


	babel_blast
		name = "Grones Soda Mountain Grones Babel Blast flavor" //by warcrimes
		label = "babel"
		initial_reagents = (list("cola"=35, "suomium"=5, "quebon"=5, "swedium"=5, "caledonium"=5, "worcestershire_sauce"=5))

	jungle_juice
		name = "Grones Soda Jammin' Jambalaya Jungle Juice flavor" //by Camryn Buttes
		label = "jungle"
		initial_reagents = (list("cola"=30, "strawberry_milk"=1, "ricewine"=1, "boorbon"=1, "diesel"=1, "irishcoffee"=1,
		"vanilla"=1, "harlow"=1, "espressomartini"=1, "ectocooler"=1, "bread"=1, "sarsaparilla"=1, "eggnog"=1,
		"chocolate"=1, "guacamole"=1, "salt"=1, "gravy"=1, "mashedpotatoes"=1, "msg"=1, "mugwort"=1, "juice_cran"=1,
		"juice_blueberry"=1, "juice_grapefruit"=1, "juice_pickle"=1, "worcestershire_sauce"=1, "fakecheese"=1,
		"capsaicin"=1, "urine"=1, "paper"=1, "chalk"=1)) //pain; a little of everything
