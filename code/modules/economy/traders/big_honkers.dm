/datum/trader/big_honkers
	// Geoff's Estranged Brother - Enthusiastic and double-fisting bike horns
	// Sells awful party supplies and also animals for some reason
	// yes the store's meant to be apostrophe s but also his name is BIG HONKERS fuckin' who knows with clowns
	name = "Big Honke'rs Party Supply"
	picture = "nio.png" //placeholder
	crate_tag = "BIGHONKERS"
	hiketolerance = 33
	base_patience = list(12,20)
	chance_leave = 25
	chance_arrive = 25

	max_goods_buy = 2
	max_goods_sell = 5

	base_goods_buy = list(/datum/commodity/trader/big_honkers/peel) //gotta have 'em
	base_goods_sell = list(/datum/commodity/trader/big_honkers/helium)

	dialogue_greet = list("WHOAOAAAA A NEW CUSTOMER HAHAHAHAHA")
	dialogue_leave = list("AHHH YOU CAUGHT ME SLIPPING, SEE YOU LATER ALLIGATOR")
	dialogue_purchase = list("YOU'RE HAVING A PARTY???? CAN I COME")
	dialogue_haggle_accept = list("HAHAHAHA! SURE")
	dialogue_haggle_reject = list("HAHAHAHA! No.")
	dialogue_wrong_haggle_reject = list("OOPSIE DAISY SOMEBODY MADE A MISTAKE OOHHHHH MAMMA")
	dialogue_cant_afford_that = list("This is unacceptable. I am astonished and disgusted.")
	dialogue_out_of_stock = list("ALLLLLLLLLLLLLLLLLLL SOLD OUT! HAHAHAHA.")

// Big Honker is selling these things

/datum/commodity/trader/big_honkers/helium
	comname = "Helium Tank"
	comtype = /obj/reagent_dispensers/heliumtank
	amount = 10
	price_boundary = list(75,120)
	possible_names = list("HEY WHAT'S A PARTY WITHOUT SOME BALLOONS RIGHT????")

// Big Honker wants these things

/datum/commodity/trader/big_honkers/peels
	comname = "Banana Peels"
	comtype =
	price_boundary = list(20,30)
	possible_names = list("HEY YOU GOT ANY OF THOSE BANANA PEELS HOLY SHIT I AM JONESIN'")
