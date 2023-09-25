/datum/trader/paisano_placeholder
	// EYYYY IS THAT...???
	// Real friendly! Loves fancy dress
	name = "Paisano Somebody"
	picture = "lizardman.png"
	crate_tag = "PAISANO"
	hiketolerance = 33
	base_patience = list(12,20)
	chance_leave = 25
	chance_arrive = 25

	max_goods_buy = 2
	max_goods_sell = 5

	base_goods_buy = list(/datum/commodity/trader/paisano_placeholder/itsmmask,
						/datum/commodity/trader/paisano_placeholder/itsmcostume)
	base_goods_sell = list(/datum/commodity/trader/paisano_placeholder/metal)

	dialogue_greet = list("Hey :DDDD",
	"Hello There :DDDD",
	"Greetings :DDDD")
	dialogue_leave = list("Gotta Go :DDDD")
	dialogue_purchase = list("Clothes!!!! :DDDD",
	"Shoes!!!! :DDDD",
	"Hats!!!! :DDDD")
	dialogue_haggle_accept = list("Okay!!!! :DDDD")
	dialogue_haggle_reject = list("No!!!! :DDDD")
	dialogue_wrong_haggle_reject = list("What :DDDD")
	dialogue_cant_afford_that = list("Cash Please :DDDD")
	dialogue_out_of_stock = list("All Out!!!! :DDDD")

// Paisano is selling these things

/datum/commodity/trader/paisano_placeholder/guybrush
	comname = "Swashbuckler Outfit"
	comtype = /obj/item/clothing/under/gimmick/
	price_boundary = list(150,200)
	possible_names = list("I'm Selling These Fine Leather Jackets :DDDD")

/datum/commodity/trader/paisano_placeholder/spaceboss
	comname = "Boss of Space California Uniform"
	comtype = /obj/item/clothing/under/gimmick/
	price_boundary = list(250,300)
	possible_names = list("Oh, you???? Could be!!!! :DDDD")

// Paisano wants these things

/datum/commodity/trader/paisano_placeholder/itsmmask
	comname = "Italian Arachnid Mask and Moustache"
	comtype = /obj/item/plant/herb/
	price_boundary = list(300,900)
	possible_names = list("Hey :DDDD")


/datum/commodity/trader/paisano_placeholder/itsmcostume
	comname = "Italian Arachnid Sweater"
	comtype = /obj/item/plant/herb/
	price_boundary = list(900,1600)
	possible_names = list("Hey :DDDD")
