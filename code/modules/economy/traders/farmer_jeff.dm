// Space Farmer who is terrible at farming but occasionally sells explosives and weird seeds
// Somewhere on Gehenna...

/datum/trader/farmer_jeff
	name = "Farmer Jeff"
	picture = "farmerjeff.png"
	crate_tag = "FARMERJEFF"
	hiketolerance = 20
	base_patience = list(6,10)
	chance_leave = 25
	chance_arrive = 25
	asshole = 1

	max_goods_sell = 5
	max_goods_buy = 2

	base_goods_sell = list(/datum/commodity/trader/jeff/apple,
	/datum/commodity/trader/jeff/banana,
	/datum/commodity/trader/jeff/broccoliss,
	/datum/commodity/trader/jeff/grapes,
	/datum/commodity/trader/jeff/peach,
	/datum/commodity/trader/jeff/seeds,
	/datum/commodity/trader/jeff/bomb,)

	base_goods_buy = list(/datum/commodity/trader/jeff/plantanalyzer,
	/datum/commodity/trader/jeff/mud, //oh god
	/datum/commodity/trader/jeff/rake,
	/datum/commodity/trader/jeff/uvlighttube,
	/datum/commodity/trader/jeff/rake) //fast traitor cash

	dialogue_greet = list("Hey I can get you some better deals than that other big box grocery fucker",
	"You want some real food? Some real good food? I got you covered.",
	"I grow this shit myself! I grow it all! I MADE IT, PUT IT IN YOU.",
	"You got any sunscreen? I could really use some sunscreen.",
	"Hey, whatever they tell you about how or why I was banned from the supply store, it's lies.",
	"So I says, \"I don't even know how to build a bomb, seriously.\" Oh- oh hey, you buyin'?")
	dialogue_leave = list("brb gotta take a piss",
	"Aw goddammit a space crow is attacking my space beans or whatever see ya",
	"Hey man hold up a sec some juicers are joyriding on my space tractor and I gotta go deal with it.")
	dialogue_purchase = list("Just be careful you don't bang that crate around too much. Fruit bruises easily.",
	"Do with that whatever you want but if the cops get involved I have no idea who you are or what you're talking about.",
	"Alright, loading it in the thingy right now.")
	dialogue_haggle_accept = list("Kinda weird to get all tight-walleted about a broccoliss but hey, whatever bud.",
	"Fuck it, why not.",
	"I think I can do that, yeah")
	dialogue_haggle_reject = list("Oh you think my apples and bananas are too pricey for you, huh?",
	"I gotta make a living here, you know.",
	"Hey according to my calculations the labor value of this transaction is I worked hard for an hour only to get pissed on!! No",
	"You have no respect for what goes into making everything you put in your mouth, huh.",
	"Yeah? And just how am I gonna buy food selling my produce for that little?")
	dialogue_wrong_haggle_accept = list("Yeah, uh, sure?")
	dialogue_wrong_haggle_reject = list("I'll do you a favor and pretend I didn't hear that one.")
	dialogue_cant_afford_that = list("You need some more of those NT bucks for that.",
	"Aren't you a big corporate station? Pride of the Frontier? Get real and come back when you can pay, 'Traser.",
	"Either pay up or grow it yourself, bud.")
	dialogue_out_of_stock = list("Well, guess I'm gonna have to grow more of that.",
	"You cleared out the last of it, I'll have more in the future.")

// Jeff is selling these things

/datum/commodity/trader/jeff/
	apple
		comname = "Apple"
		comtype = /obj/item/reagent_containers/food/snacks/plant/apple
		price_boundary = list(20,50)
		possible_alt_types = list(/obj/item/reagent_containers/food/snacks/plant/apple/stick)
		alt_type_chance = 10
		possible_names = list("Hey, you all eat the middle part too, right? Hell yeah, waste not want not.",
		"No bullshit apples here, I promise you. That variety is banned for a reason.")

	banana
		comname = "Banana"
		comtype = /obj/item/reagent_containers/food/snacks/plant/banana
		amount = 20
		price_boundary = list(20,50)
		possible_alt_types = list(/obj/item/bananapeel)
		alt_type_chance = 50
		possible_names = list("As much as I miss the cronch, unzipping them really is a lot tastier.",
		"You ever have a guy argue with you and he's just so wrong but he just keeps shouting \"everyone <i>knows</i> that's a <i>squash</i>\" and... Ah, never mind.",
		"Oh I eat a lot of these yellow fuckers right on the loading dock. Even got a few crates laying around the dock for the peels.")

	broccoliss
		comname = "Decorative \"Broccoliss\" Tree"
		comtype = /obj/shrub/captainshrub/broccoliss
		amount = 1
		price_boundary = list(300,500)
		//possible_alt_types = list(/obj/shrub/captainshrub/broccoliss) //this should be the rare one and otherwise you just get broccoli but there is no brocc atm
		//alt_type_chance = 5
		possible_names = list("You ever see these little tree things, man? I grow just a few, they're real fun.",
		"Yeah, I've gotten into broccoliss tending lately. It helps center my nerves.")

	grapes
		comname = "Grapes"
		comtype = /obj/item/reagent_containers/food/snacks/plant/grape/
		amount = 20
		price_boundary = list(40,70)
		possible_alt_types = list(/obj/item/reagent_containers/food/snacks/plant/grape/green)
		alt_type_chance = 50
		possible_names = list("Selling these little guys all together as a package, it's bulk deal for you.",
		"These guys all kinda stick together, which is pretty handy.")

	peach
		comname = "Peaches"
		comtype = /obj/item/reagent_containers/food/snacks/plant/peach
		amount = 10
		price_boundary = list(40,70)
		possible_alt_types = list(/obj/item/kitchen/peach_rings) //OOPS!
		alt_type_chance = 10
		possible_names = list("You can huck the thing in the middle at someone real good and ruin their day.",
		"Hey aren't you the station with all the butts and farts? Yeah I'm sure you weirdos will get a kick out of these.")

	seeds
		comname = "Unusual Plant Seeds"
		comtype = /obj/item/seed/alien
		price_boundary = list(200,350)
		//possible_alt_types = list(literally just normal vegetable seeds in a weird wrapper)
		//alt_type_chance = 75
		possible_names = list("I'm tellin' you, I know how to grow all sorts of things, honest. But this alien shit? I have no idea what to do with them.",
		"Unlike the other guy, my weird alien seeds I want to get rid of are perfectly safe.")

	bomb
		comname = "Thing What Blows Up"
		comtype = /obj/item/pipebomb/bomb
		amount = 1
		price_boundary = list(10000,20000)
		possible_alt_types = list(/obj/item/implant/microbomb,/obj/item/pipebomb/bomb/syndicate)
		alt_type_chance = 5
		possible_names = list("Okay so sometimes some other dudes who are complete strangers to me come around and hide stuff in my space barn completely without my knowledge and sometimes I sell one or two and if you're interested just buy it and don't say anything to anybody alright?",
		"I had nothing to do with either the manufacture or import or design or use of these in any sort of retail establishment but they might be persuaded to accidentally fall into your next shipment with some credits.")

// Jeff wants these things

	plantanalyzer
		comname = "Plant Analyzer"
		comtype = /obj/item/plantanalyzer
		amount = 1
		price_boundary = list(800,1600)
		possible_names = list("Hey listen, my plant scanning thing broke and the only place I know to get them is that damn wholesale store, and I'm banned for life, so, do me a solid? Just one, though, not paying for any extra.",
		"My plant thingy broke again and you're gonna have to be my fence. Or whatever the opposite of that is. I'd buy it myself, but whatever. Only need one!")

	mud
		comname = "\"Fertilizer\""
		comtype = /obj/item/reagent_containers/food/snacks/ingredient/mud
		amount = 10
		price_boundary = list(200,300)
		possible_names = list("Hey you're that one station, aren't you? I could use some fertilizer. Please don't get fuckin' weird about it.",
		"Listen, just, label and seal the crate up really, really, <i>really</i> tight, please.")

	satchel
		comname = "Produce Satchel"
		comtype = /obj/item/satchel/hydro
		price_boundary = list(200,500)
		possible_names = list("Hey, this is embarrassing, but instead of dumping my loose produce in the giant boxes and launching them into space, I threw the last of my produce satchels in. Got a few to spare?",
		"I'm out of produce satchels again, got any you can send my way? I'd buy them myself, but, you know. Banned.")

	uvlighttube
		comname = "UV Growlight Tube"
		comtype = /obj/item/light/tube/blacklight
		price_boundary = list(200,300)
		possible_names = list("I got an exclusive contract to sell growlights to you-know-who, but I need some new stock.",
		"Yeah I'm kind of a light tube middleman too. I got a lotta fingers in a lot of pies. Hustle hustle.")

	rake
		comname = "Rake"
		comtype = /obj/rake
		amount = 1
		price_boundary = list(2000,5000)
		possible_names = list("Weird question but do you happen to have a good quality rake? One with a real solid handle? Just one, though.",
		"Damn if you can't get a fuckin' good rake that doesn't fall apart any more. I'm only paying for one, though.")
