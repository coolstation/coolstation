ABSTRACT_TYPE(/datum/cookingrecipe)
ABSTRACT_TYPE(/datum/cookingrecipe/oven)
ABSTRACT_TYPE(/datum/cookingrecipe/mixer)
ABSTRACT_TYPE(/datum/cookingrecipe/fryer)
/datum/cookingrecipe
	var/item1 = null
	var/item2 = null
	var/item3 = null
	var/item4 = null
	var/amt1 = 1
	var/amt2 = 1
	var/amt3 = 1
	var/amt4 = 1
	/// how much cooking it needs to get a healing bonus
	var/cookbonus = null
	/// what you get from this recipe
	var/output = null
	/// used for naming of human meat dishes after their victims
	var/useshumanmeat = 0
	/// category for sorting, use null to hide
	var/category = "Unsorted" //TODO - assign these later

	proc/specialOutput(var/obj/submachine/ourCooker)
		return null //If returning an object, that is used as the output

/datum/cookingrecipe/oven/humanburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/humanburger
	useshumanmeat = 1
	category = "Burgers"

/datum/cookingrecipe/oven/fishburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/burger/fishburger
	category = "Burgers"

/datum/cookingrecipe/oven/synthburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/synthburger
	category = "Burgers"

/datum/cookingrecipe/oven/spicychickensandwich_2
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/spicy
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/chicken/spicy
	category = "Burgers"

/datum/cookingrecipe/oven/spicychickensandwich
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget
	item3 = /obj/item/reagent_containers/food/snacks/plant/chili
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/chicken/spicy
	category = "Burgers"

/datum/cookingrecipe/oven/chickensandwich
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/chicken
	category = "Burgers"

/datum/cookingrecipe/oven/mysteryburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/mysteryburger
	category = "Burgers"

/datum/cookingrecipe/oven/camembert
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	amt3 = 6
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/burger/camembert
	category = "Burgers"

/datum/cookingrecipe/oven/cheeseburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/burger/cheeseburger
	category = "Burgers"

/datum/cookingrecipe/oven/cheeseburger_m
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/burger/cheeseburger_m
	category = "Burgers"

/datum/cookingrecipe/oven/luauburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/
	item3 = /obj/item/reagent_containers/food/snacks/plant/pineappleslice
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/luauburger
	category = "Burgers"

/datum/cookingrecipe/oven/coconutburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/plant/coconutmeat/
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/coconutburger
	category = "Burgers"

/datum/cookingrecipe/oven/tikiburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/
	item3 = /obj/item/reagent_containers/food/snacks/plant/pineappleslice
	item4 = /obj/item/reagent_containers/food/snacks/plant/coconutmeat/
	cookbonus = 18
	output = /obj/item/reagent_containers/food/snacks/burger/tikiburger
	category = "Burgers"

/datum/cookingrecipe/oven/monkeyburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/monkeyburger
	category = "Burgers"

/datum/cookingrecipe/oven/buttburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/clothing/head/butt
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/buttburger
	category = "Burgers"

/datum/cookingrecipe/oven/heartburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/organ/heart
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/heartburger
	category = "Burgers"

/datum/cookingrecipe/oven/flockburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/organ/brain/flockdrone
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/flockburger
	category = "Burgers"

/datum/cookingrecipe/oven/brainburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/organ/brain
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/brainburger
	category = "Burgers"

/datum/cookingrecipe/oven/roburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/parts/robot_parts/head
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/roburger
	category = "Burgers"

/datum/cookingrecipe/oven/cheeseborger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/parts/robot_parts/head
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/cheeseborger
	category = "Burgers"

/datum/cookingrecipe/oven/baconburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/baconburger
	category = "Burgers"

/datum/cookingrecipe/oven/baconator
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat
	amt2 = 2
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/burger/bigburger
	category = "Burgers"

/datum/cookingrecipe/oven/butterburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/butter
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/butterburger
	category = "Burgers"

/datum/cookingrecipe/oven/monster
	item1 = /obj/item/reagent_containers/food/snacks/burger/bigburger
	amt1 = 4
	cookbonus = 20
	output = /obj/item/reagent_containers/food/snacks/burger/monsterburger
	category = "Burgers"

#ifdef SECRETS_ENABLED
/datum/cookingrecipe/oven/hamburgris
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/material_piece/hamburgris
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/hamburgris
	category = null
#endif

/datum/cookingrecipe/oven/swede_mball
	item1 = /obj/item/reagent_containers/food/snacks/meatball
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/flour
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/swedishmeatball

/datum/cookingrecipe/oven/donkpocket
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/meatball
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/donkpocket/warm

/datum/cookingrecipe/oven/honkpocket
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/meatball
	item3 = /obj/item/instrument/bikehorn
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/donkpocket/honk/warm

/datum/cookingrecipe/oven/donkpocket2
	item1 = /obj/item/reagent_containers/food/snacks/donkpocket
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/donkpocket/warm

/datum/cookingrecipe/oven/donut
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_circle
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/sugar
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/donut

/datum/cookingrecipe/oven/bagel
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_circle
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/bagel

/datum/cookingrecipe/oven/crumpet //another good idea for this is to cook a trumpet
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/holey_dough
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/crumpet

/datum/cookingrecipe/oven/ice_cream_cone
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/sugar
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/ice_cream_cone

/datum/cookingrecipe/oven/nougat
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/honey
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/sugar
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/candy/nougat

/datum/cookingrecipe/oven/candy_cane
	item1 = /obj/item/plant/herb/mint
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/sugar
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/candy/candy_cane

/datum/cookingrecipe/oven/waffles
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/waffles

/datum/cookingrecipe/oven/spaghetti_p
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/spaghetti
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/spaghetti
	category = "Pasta"

/datum/cookingrecipe/oven/spaghetti_t
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/spaghetti
	item2 = /obj/item/reagent_containers/food/snacks/condiment/tomato_sauce
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/spaghetti/sauce
	category = "Pasta"

/datum/cookingrecipe/oven/spaghetti_s
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/spaghetti
	item2 = /obj/item/reagent_containers/food/snacks/condiment/hotsauce
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/spaghetti/spicy
	category = "Pasta"

/datum/cookingrecipe/oven/spaghetti_m
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/spaghetti
	item2 = /obj/item/reagent_containers/food/snacks/meatball
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/spaghetti/meatball
	category = "Pasta"

/datum/cookingrecipe/oven/lasagna
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/pasta/sheet
	item2 = /obj/item/reagent_containers/food/snacks/condiment/tomato_sauce
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/lasagna
	category = "Pasta"

/datum/cookingrecipe/oven/spaghetti_pg
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/spaghetti
	item2 = /obj/item/reagent_containers/food/snacks/condiment/tomato_sauce
	item3 = /obj/item/reagent_containers/food/snacks/pizza
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/spaghetti/pizzaghetti
	category = "Pasta"

/datum/cookingrecipe/oven/spooky_bread
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item3 = /obj/item/reagent_containers/food/snacks/ectoplasm
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf/spooky
	category = "Bread"

/datum/cookingrecipe/oven/elvis_bread
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/plant/banana
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/peanutbutter
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf/elvis
	category = "Bread"

/datum/cookingrecipe/oven/banana_bread
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/plant/banana
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/sugar
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf/banana
	category = "Bread"

/datum/cookingrecipe/oven/banana_bread_alt
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/plant/banana
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf/banana
	category = "Bread"

/datum/cookingrecipe/oven/cornbread1
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/plant/corn
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/breadloaf/corn
	category = "Bread"

/datum/cookingrecipe/oven/cornbread2
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/plant/corn
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/breadloaf/corn/sweet
	category = "Bread"

/datum/cookingrecipe/oven/cornbread3
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/plant/corn
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/sugar
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/breadloaf/corn/sweet
	category = "Bread"

/datum/cookingrecipe/oven/cornbread4
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/plant/corn
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/honey
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/breadloaf/corn/sweet/honey
	category = "Bread"

/datum/cookingrecipe/oven/pumpkin_bread
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/plant/pumpkin
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf/pumpkin
	category = "Bread"

/datum/cookingrecipe/oven/bread
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf
	category = "Bread"

/datum/cookingrecipe/oven/honeywheat_bread
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/honey
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf/honeywheat
	category = "Bread"

/datum/cookingrecipe/oven/brain_bread
	item1 = /obj/item/reagent_containers/food/snacks/breadloaf
	item2 = /obj/item/organ/brain
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/breadloaf/brain
	category = "Bread"

/datum/cookingrecipe/oven/toast
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/breadslice/toastslice
	category = "Toast"

/datum/cookingrecipe/oven/toast_banana
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/banana
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/banana
	category = "Toast"

/datum/cookingrecipe/oven/toast_brain
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/brain
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/brain
	category = "Toast"

/datum/cookingrecipe/oven/toast_elvis
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/elvis
	category = "Toast"

/datum/cookingrecipe/oven/toast_spooky
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/spooky
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/spooky
	category = "Toast"

/datum/cookingrecipe/oven/sandwich_m_h
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/meat_h
	useshumanmeat = 1
	category = "Sandwiches"

/datum/cookingrecipe/oven/sandwich_m_m
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/meat_m
	category = "Sandwiches"

/datum/cookingrecipe/oven/sandwich_m_s
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/meat_s
	category = "Sandwiches"

/datum/cookingrecipe/oven/sandwich_grub
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/grubmeat
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/grubmeat
	category = "Sandwiches"

/datum/cookingrecipe/oven/sandwich_c
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/cheese
	category = "Sandwiches"

/datum/cookingrecipe/oven/sandwich_p
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/peanutbutter
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/pb
	category = "Sandwiches"

/datum/cookingrecipe/oven/sandwich_p_h
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/peanutbutter
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/honey
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/pbh
	category = "Sandwiches"

/datum/cookingrecipe/oven/elviswich_m_h
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/elvis_meat_h
	useshumanmeat = 1
	category = "Sandwiches"

/datum/cookingrecipe/oven/elviswich_m_m
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/elvis_meat_m
	category = "Sandwiches"

/datum/cookingrecipe/oven/elviswich_m_s
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/elvis_meat_s
	category = "Sandwiches"

/datum/cookingrecipe/oven/elviswich_c
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/elvis_cheese
	category = "Sandwiches"

/datum/cookingrecipe/oven/elviswich_p
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/peanutbutter
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/elvis_pb
	category = "Sandwiches"

/datum/cookingrecipe/oven/elviswich_p_h
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/peanutbutter
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/honey
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/elvis_pbh
	category = "Sandwiches"

/datum/cookingrecipe/oven/scarewich_c
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/spooky
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/spooky_cheese
	category = "Sandwiches"

/datum/cookingrecipe/oven/scarewich_p
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/spooky
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/peanutbutter
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/spooky_pb
	category = "Sandwiches"

/datum/cookingrecipe/oven/scarewich_p_h
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/spooky
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/peanutbutter
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/honey
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/spooky_pbh
	category = "Sandwiches"

/datum/cookingrecipe/oven/scarewich_h
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/spooky
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/spooky_meat_h
	useshumanmeat = 1
	category = "Sandwiches"

/datum/cookingrecipe/oven/scarewich_m
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/spooky
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/spooky_meat_m
	category = "Sandwiches"

/datum/cookingrecipe/oven/scarewich_s
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/spooky
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/spooky_meat_s
	category = "Sandwiches"

/datum/cookingrecipe/oven/sandwich_mb //Original meatball sub recipe
	item1 = /obj/item/reagent_containers/food/snacks/meatball
	item2 = /obj/item/reagent_containers/food/snacks/breadloaf
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	item4 = /obj/item/reagent_containers/food/snacks/condiment/tomato_sauce
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/sandwich/meatball
	category = "Sandwiches"

/datum/cookingrecipe/oven/sandwich_mbalt //Secondary recipe that uses the baguette
	item1 = /obj/item/reagent_containers/food/snacks/meatball
	item2 = /obj/item/baguette
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	item4 = /obj/item/reagent_containers/food/snacks/condiment/tomato_sauce
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/sandwich/meatball
	category = "Sandwiches"

/datum/cookingrecipe/oven/sandwich_egg
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/eggsalad
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/eggsalad
	category = "Sandwiches"

/datum/cookingrecipe/oven/sandwich_bm //Original banh mi recipe
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon/raw
	item2 = /obj/item/reagent_containers/food/snacks/breadloaf/honeywheat
	item3 = /obj/item/reagent_containers/food/snacks/plant/carrot
	item4 = /obj/item/reagent_containers/food/snacks/plant/cucumber
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/sandwich/banhmi
	category = "Sandwiches"

/datum/cookingrecipe/oven/sandwich_bmalt //Secondary recipe that uses the baguette
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon/raw
	item2 = /obj/item/baguette
	item3 = /obj/item/reagent_containers/food/snacks/plant/carrot
	item4 = /obj/item/reagent_containers/food/snacks/plant/cucumber
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/sandwich/banhmi
	category = "Sandwiches"

/datum/cookingrecipe/oven/sandwich_mitraillette //Hey lads what the fuck is with all the sandwich recipes and single letters, writing out words isn't going to hurt you.
	item1 = /obj/item/baguette
	item2 = /obj/item/reagent_containers/food/snacks/fries
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/meat
	item4 = /obj/item/reagent_containers/food/snacks/condiment
	cookbonus = 9 //IDK what this is exactly
	output = /obj/item/reagent_containers/food/snacks/sandwich/mitraillette
	category = "Sandwiches"

/datum/cookingrecipe/oven/sandwich_knuckle
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	amt1 = 2
	item2 = /obj/item/parts/human_parts/arm
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/cheese //This recipe is a cheesy joke
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/knuckle
	category = "Sandwiches"

/datum/cookingrecipe/oven/sandwich_custom
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	amt1 = 2
	cookbonus = 12
	output = null
	category = "Sandwiches"

	specialOutput(obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		var/obj/item/reagent_containers/food/snacks/sandwich/customSandwich = new /obj/item/reagent_containers/food/snacks/sandwich (ourCooker)
		customSandwich.heal_amt = 1 // no filling yet, so less than regular sandwich
		customSandwich.reagents = new /datum/reagents(100)
		customSandwich.reagents.my_atom = customSandwich


		var/obj/item/reagent_containers/food/snacks/breadslice/slice1
		var/obj/item/reagent_containers/food/snacks/breadslice/slice2
		var/list/fillings = list()
		var/list/fillingColors = list()
		var/onBreadText = ""
		var/extraSlices = 0
		var/isToast = FALSE

		var/i = 1
		for (var/obj/item/reagent_containers/food/snacks/snack in ourCooker)
			if (snack == customSandwich)
				continue

			else if (istype(snack, /obj/item/reagent_containers/food/snacks/breadslice))
				if (slice1 && slice2)
					// fix up ordering of toast sandwich components
					var/toast1 = istype(slice1, /obj/item/reagent_containers/food/snacks/breadslice/toastslice)
					var/toast2 = istype(slice2, /obj/item/reagent_containers/food/snacks/breadslice/toastslice)
					var/toast3 = istype(snack, /obj/item/reagent_containers/food/snacks/breadslice/toastslice)
					if (extraSlices == 0 && toast1 + toast2 + toast3 == 1)
						var/obj/item/reagent_containers/food/snacks/breadslice/temp = snack
						if (toast1)
							snack = slice1
							slice1 = temp
						else if (toast2)
							snack = slice2
							slice2 = temp
						isToast = TRUE
						onBreadText = "on [slice1.real_name == "bread" ? "plain bread" : slice1.real_name]"
						if (slice1.real_name != slice2.real_name)
							onBreadText += " and [slice2.real_name == "bread" ? "plain" : slice2.real_name]"
					else
						isToast = FALSE

					extraSlices++

					if (snack.reagents)
						snack.reagents.trans_to(customSandwich, 25)
					customSandwich.food_effects += snack.food_effects

					//fillings += snack.name
					if (snack.food_color)
						if (fillingColors.len % 2 || fillingColors.len < (i*2))
							fillingColors += "B[snack.food_color]"
						else
							fillingColors.Insert((i++*2), "B[snack.food_color]")
					qdel(snack)

				else if (slice1)
					slice2 = snack
					if (slice1.real_name != snack.real_name)
						onBreadText += " and [snack.real_name == "bread" ? "plain" : snack.real_name]"
				else
					slice1 = snack
					onBreadText = "on [snack.real_name == "bread" ? "plain bread" : snack.real_name]"
			else
				if (snack.reagents)
					snack.reagents.trans_to(customSandwich, 25)
				customSandwich.food_effects += snack.food_effects

				fillings += snack.name
				if (snack.food_color && !istype(snack, /obj/item/reagent_containers/food/snacks/ingredient) && prob(50))
					fillingColors += snack.food_color
				else
					var/obj/transformedFilling = image(snack.icon, snack.icon_state)
					transformedFilling.transform = matrix(0.75, MATRIX_SCALE)
					fillingColors += transformedFilling

				// spread the total healing left for the added food among the sandwich bites
				customSandwich.heal_amt += snack.heal_amt * snack.amount / customSandwich.amount

				qdel(snack)

		if (!fillings.len && isToast)
			customSandwich.name = "toast"
			customSandwich.desc = "A slice of toast between two slices of bread. Apparently this counts as a sandwich?"
			extraSlices--
			customSandwich.reagents.add_reagent("worcestershire_sauce", 25)
		else if (!fillings.len)
			customSandwich.name = "wish"
			customSandwich.desc = "So named because you 'wish' you had something to put between the slices of bread. Ha.  ha.  Ha..."
		else
			var/fillingText = copytext(html_encode(english_list(fillings)), 1, 512)
			customSandwich.name = fillingText
			customSandwich.desc = "A sandwich filled with [fillingText]."

		switch (extraSlices)
			if (0)
				customSandwich.name += " sandwich"

			if (1)
				customSandwich.name += " club"

			if (2)
				customSandwich.name += " double-decker sandwich"

			if (3)
				customSandwich.name += " dagwood"

		customSandwich.name += " [onBreadText]"

		var/obj/sandwichIcon
		customSandwich.icon = 'icons/obj/foodNdrink/food_meals.dmi'
		customSandwich.icon_state = "blank"
		if (slice1)
			sandwichIcon = image('icons/obj/foodNdrink/food_meals.dmi', "sandwich-bread")//, 1, 1)
			//sandwichIcon.Blend(slice1.food_color, ICON_ADD)
			sandwichIcon.color = slice1.food_color

			customSandwich.overlays += sandwichIcon
			//qdel(slice1)

		var/fillingOffset = 2
		var/obj/newFilling
		while (fillingColors.len)
			if (istype(fillingColors[fillingColors.len], /image))
				newFilling = fillingColors[fillingColors.len]

			else if (copytext(fillingColors[fillingColors.len],1,2) == "B")
				newFilling = image('icons/obj/foodNdrink/food_meals.dmi', "sandwich-bread")
				fillingColors[fillingColors.len] = copytext(fillingColors[fillingColors.len], 2)

			else
				newFilling = image('icons/obj/foodNdrink/food_meals.dmi', "sandwich-filling[rand(1,4)]")//, 1, 1)
			//newFilling.Blend(fillingColors[fillingColors.len], ICON_ADD)
			newFilling.pixel_y = fillingOffset
			newFilling.color = fillingColors[fillingColors.len]
			fillingColors.len--
			fillingOffset += 2

			customSandwich.overlays += newFilling


		if (slice2)
			newFilling = image('icons/obj/foodNdrink/food_meals.dmi', "sandwich-bread")//, 1, 1)
			//newFilling.Blend( slice2.food_color, ICON_ADD)
			newFilling.color = slice2.food_color
			newFilling.pixel_y = fillingOffset

			//qdel(slice2)

			customSandwich.overlays += newFilling

		return customSandwich

/datum/cookingrecipe/oven/pizza_custom
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/pizza_base
	cookbonus = 18
	output = null
	category = "Pizzas"

	specialOutput(obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		for (var/obj/item/reagent_containers/food/snacks/ingredient/pizza_base/P in ourCooker)
			return P.bake_pizza()

/datum/cookingrecipe/oven/cheesetoast
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/toastcheese
	category = "Toast (Meal)"

/datum/cookingrecipe/oven/bacontoast
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/toastbacon
	category = "Toast (Meal)"

/datum/cookingrecipe/oven/eggtoast
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/toastegg
	category = "Toast (Meal)"

/datum/cookingrecipe/oven/elvischeesetoast
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/toastcheese/elvis
	category = "Toast (Meal)"

/datum/cookingrecipe/oven/elvisbacontoast
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/toastbacon/elvis
	category = "Toast (Meal)"

/datum/cookingrecipe/oven/elviseggtoast
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	amt2 = 2
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/toastegg/elvis
	category = "Toast (Meal)"

/datum/cookingrecipe/oven/breakfast
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	amt2 = 2
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/breakfast
	category = "Toast (Meal)"

/datum/cookingrecipe/oven/breakfast_green
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/grubmeat
	amt1 = 1
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	amt2 = 2
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/breakfast_green
	category = "Toast (Meal)"

/datum/cookingrecipe/mixer/wonton_wrapper
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/flour
	cookbonus = 1
	output = /obj/item/reagent_containers/food/snacks/wonton_spawner

/datum/cookingrecipe/oven/taco_shell
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/tortilla
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/taco

/datum/cookingrecipe/oven/eggnog
	item1 = /obj/item/reagent_containers/food/drinks/milk
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	amt2 = 3
	cookbonus = 3
	output = /obj/item/reagent_containers/food/drinks/eggnog

// Pastries and bread-likes

/datum/cookingrecipe/oven/baguette
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_strip
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/flour
	cookbonus = 8
	output = /obj/item/baguette
	category = "Pastries and bread-likes" // not sorry

/datum/cookingrecipe/oven/garlicbread
	item1 = /obj/item/baguette
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/butter
	item3 = /obj/item/reagent_containers/food/snacks/plant/garlic
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/garlicbread
	category = "Pastries and bread-likes"

/datum/cookingrecipe/oven/garlicbread_ch
	item1 = /obj/item/baguette
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	item3 = /obj/item/reagent_containers/food/snacks/plant/garlic
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/butter
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/garlicbread_ch
	category = "Pastries and bread-likes"

/datum/cookingrecipe/oven/painauchocolat
	item1 = /obj/item/reagent_containers/food/snacks/candy/chocolate
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/butter
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/painauchocolat
	category = "Pastries and bread-likes"

/datum/cookingrecipe/oven/croissant
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/butter
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/croissant
	category = "Pastries and bread-likes"

/datum/cookingrecipe/oven/danish_apple
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/butter
	item3 = /obj/item/reagent_containers/food/snacks/plant/apple
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/danish_apple
	category = "Pastries and bread-likes"

/datum/cookingrecipe/oven/danish_cherry
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/butter
	item3 = /obj/item/reagent_containers/food/snacks/plant/cherry
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/danish_cherry
	category = "Pastries and bread-likes"

/datum/cookingrecipe/oven/danish_blueb
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/butter
	item3 = /obj/item/reagent_containers/food/snacks/plant/blueberry
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/danish_blueb
	category = "Pastries and bread-likes"

/datum/cookingrecipe/oven/danish_weed
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/butter
	item3 = /obj/item/plant/herb/cannabis
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/danish_weed
	category = "Pastries and bread-likes"

/datum/cookingrecipe/oven/fairybread
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/sugar
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/butter
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/fairybread
	category = "Pastries and bread-likes"

//Cookies
/datum/cookingrecipe/oven/stroopwalfel
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/condiment/syrup
	item3 = /obj/item/reagent_containers/food/snacks/candy/caramel
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/stroopwafel/walf
	category = "Cookies"

/datum/cookingrecipe/oven/stroopwafel
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/condiment/syrup
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/stroopwafel
	category = "Cookies"

/datum/cookingrecipe/oven/cookie
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie
	category = "Cookies"

/datum/cookingrecipe/oven/cookie_iron
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	item2 = /obj/item/reagent_containers/food/snacks/condiment/ironfilings
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/metal
	category = "Cookies"

/datum/cookingrecipe/oven/cookie_chocolate_chip
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	item2 = /obj/item/reagent_containers/food/snacks/condiment/chocchips
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/chocolate_chip
	category = "Cookies"

/datum/cookingrecipe/oven/cookie_oatmeal
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/oatmeal
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/oatmeal
	category = "Cookies"

/datum/cookingrecipe/oven/cookie_bacon
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/bacon
	category = "Cookies"

/datum/cookingrecipe/oven/cookie_jaffa
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	item2 = /obj/item/reagent_containers/food/snacks/plant/orange
	item3 = /obj/item/reagent_containers/food/snacks/candy/regular
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/jaffa
	category = "Cookies"

/datum/cookingrecipe/oven/cookie_spooky
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	item2 = /obj/item/reagent_containers/food/snacks/ectoplasm
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/spooky
	category = "Cookies"

/datum/cookingrecipe/oven/cookie_butter
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/butter
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/butter
	category = "Cookies"

/datum/cookingrecipe/oven/cookie_peanut
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/peanutbutter
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/peanut
	category = "Cookies"

//Moon pies!
/datum/cookingrecipe/oven/moon_pie
	item1 = /obj/item/reagent_containers/food/snacks/cookie
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/condiment/cream
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie
	category = "Moon Pies"

/datum/cookingrecipe/oven/moon_pie_iron
	item1 = /obj/item/reagent_containers/food/snacks/cookie/metal
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/condiment/cream
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie/metal
	category = "Moon Pies"

/datum/cookingrecipe/oven/moon_pie_chips
	item1 = /obj/item/reagent_containers/food/snacks/cookie/chocolate_chip
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/condiment/cream
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie/chocolate_chip
	category = "Moon Pies"

/datum/cookingrecipe/oven/moon_pie_oatmeal
	item1 = /obj/item/reagent_containers/food/snacks/cookie/oatmeal
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/condiment/cream
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie/oatmeal
	category = "Moon Pies"

/datum/cookingrecipe/oven/moon_pie_bacon
	item1 = /obj/item/reagent_containers/food/snacks/cookie/bacon
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/condiment/cream
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie/bacon
	category = "Moon Pies"

/datum/cookingrecipe/oven/moon_pie_jaffa
	item1 = /obj/item/reagent_containers/food/snacks/cookie/jaffa
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/condiment/cream
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie/jaffa
	category = "Moon Pies"

/datum/cookingrecipe/oven/moon_pie_spooky
	item1 = /obj/item/reagent_containers/food/snacks/cookie/spooky
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/condiment/cream
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie/spooky
	category = "Moon Pies"

/datum/cookingrecipe/oven/moon_pie_chocolate
	item1 = /obj/item/reagent_containers/food/snacks/cookie/chocolate_chip
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/condiment/cream
	item3 = /obj/item/reagent_containers/food/snacks/candy/regular
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/moon_pie/chocolate
	category = "Moon Pies"

/datum/cookingrecipe/oven/onionchips
	item1 = /obj/item/reagent_containers/food/snacks/onion_slice
	item2 = /obj/item/reagent_containers/food/snacks/onion_slice
	item3 = /obj/item/reagent_containers/food/snacks/plant/garlic
	item4 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/onionchips

/datum/cookingrecipe/oven/fries
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/chips
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/fries //unused cause of specialOutput

	//There's no after-cooking output alter proc, so
	specialOutput(obj/submachine/ourCooker)
		return new /obj/item/reagent_containers/food/snacks/fries {disappointing = TRUE;} ()

/datum/cookingrecipe/oven/fat_fries
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/chips_thicc
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/fat_fries //unused cause of specialOutput

	//There's no after-cooking output alter proc, so
	specialOutput(obj/submachine/ourCooker)
		return new /obj/item/reagent_containers/food/snacks/fat_fries {disappointing = TRUE;} ()


/datum/cookingrecipe/oven/bakedpotato
	item1 = /obj/item/reagent_containers/food/snacks/plant/potato
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/bakedpotato

/datum/cookingrecipe/oven/hotdog
	item1 = /obj/item/reagent_containers/food/snacks/meatball
	amt1 = 2
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/hotdog

/datum/cookingrecipe/oven/steak_h
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/steak_h
	useshumanmeat = 1

/datum/cookingrecipe/oven/steak_m
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/steak_m

/datum/cookingrecipe/oven/steak_s
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/steak_s

/datum/cookingrecipe/oven/steak_s
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/steak_s

/datum/cookingrecipe/oven/steak_grub
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/grubmeat
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/steak_grub

/datum/cookingrecipe/oven/fish_fingers
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/fish_fingers

/datum/cookingrecipe/oven/bacon
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon/raw
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon

/datum/cookingrecipe/oven/pie_apple
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/plant/apple
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/apple
	category = "Pies"

/datum/cookingrecipe/oven/pie_lime
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/plant/lime
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/lime
	category = "Pies"

/datum/cookingrecipe/oven/pie_lemon
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/plant/lemon
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/lemon
	category = "Pies"

/datum/cookingrecipe/oven/pie_slurry
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/plant/slurryfruit
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/slurry
	category = "Pies"

/datum/cookingrecipe/oven/pie_pumpkin
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/plant/pumpkin
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/pumpkin
	category = "Pies"

/datum/cookingrecipe/oven/pie_strawberry
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/plant/strawberry
	amt2 = 2
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/strawberry
	category = "Pies"

/datum/cookingrecipe/oven/pie_cream
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/condiment/cream
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/pie/cream
	category = "Pies"

	specialOutput(var/obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		var/obj/item/reagent_containers/food/snacks/custom_pie_food
		for (var/obj/item/reagent_containers/food/snacks/S in ourCooker.contents)
			if (S.type == item1 || S.type == item2)
				continue

			custom_pie_food = S
			break

		if (!custom_pie_food)
			return null

		var/obj/item/reagent_containers/food/snacks/pie/cream/custom_pie = new
		custom_pie_food.reagents.trans_to(custom_pie, 50)
		if(custom_pie.real_name)
			custom_pie.name = "[custom_pie_food.real_name] cream pie"

		else
			custom_pie.name = "[custom_pie_food.name] cream pie"

		var/icon/I = new /icon('icons/obj/foodNdrink/food_dessert.dmi',"creampie")
		I.Blend(custom_pie_food.food_color, ICON_ADD)
		custom_pie.icon = I

		return custom_pie

/datum/cookingrecipe/oven/pie_anything
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/pie/anything
	category = "Pies"

	specialOutput(var/obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		var/obj/item/reagent_containers/food/snacks/anItem
		var/obj/item/reagent_containers/food/snacks/pie/anything/custom_pie = new
		var/pieDesc
		var/pieName
		var/contentAmount = ourCooker.contents.len - 2
		var/count = 1
		var/found1 = 0
		var/found2 = 0
		for (var/obj/item/T in ourCooker.contents)

			if (T.type == item1 && !found1)
				found1 = true
				continue

			if (T.type == item2 && !found2)
				found2 = true
				continue

			anItem = T
			anItem.set_loc(custom_pie)
			if (count == contentAmount && contentAmount > 1)
				pieDesc += "and a "
			else
				pieDesc += "a "

			if (custom_pie.real_name)
				pieDesc += lowertext(anItem.real_name)
				pieName += lowertext(anItem.real_name)
			else
				pieDesc += lowertext(anItem.name)
				pieName += lowertext(anItem.name)

			if (count < contentAmount)
				if (count == (contentAmount - 1))
					pieDesc += " "
				else
					pieDesc += ", "
				pieName += " "

			custom_pie.w_class = max(custom_pie.w_class, T.w_class) //Well, that huge thing you put into it isn't going to shrink, you know

			count++

//		if (!anItem)
//			return null

		custom_pie.name = pieName + " pie"
		custom_pie.desc = "A pie containing [pieDesc]. Well alright then."

		var/icon/I = new /icon('icons/obj/foodNdrink/food_dessert.dmi',"pie")
		var/random_color = rgb(rand(1,255), rand(1,255), rand(1,255))
		I.Blend(random_color, ICON_ADD)
		custom_pie.icon = I

		return custom_pie

/datum/cookingrecipe/oven/pie_custard
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/condiment/custard
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/pie/custard
	category = "Pies"

/datum/cookingrecipe/oven/pie_bacon
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/pie/bacon
	category = "Pies"

/datum/cookingrecipe/oven/pie_ass
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/clothing/head/butt
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/pie/ass
	category = "Pies"

/datum/cookingrecipe/oven/pie_chocolate
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/candy/regular
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/butter
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/pie/chocolate
	category = "Pies"

/datum/cookingrecipe/oven/pot_pie
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget
	item3 = /obj/item/reagent_containers/food/snacks/plant/carrot
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/pot
	category = "Pies"

/datum/cookingrecipe/oven/pie_weed
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget
	item3 = /obj/item/plant/herb/cannabis
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/weed
	category = "Pies"

/datum/cookingrecipe/oven/pie_fish
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish
	item3 = /obj/item/reagent_containers/food/snacks/plant/potato
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/pie/fish
	category = "Pies"

/datum/cookingrecipe/mixer/custard
	item1 = /obj/item/reagent_containers/food/drinks/milk
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/condiment/custard

/datum/cookingrecipe/mixer/gruel
	item1 = /obj/item/reagent_containers/food/snacks/yuck
	amt1 = 3
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/soup/gruel

/datum/cookingrecipe/oven/porridge
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/rice
	amt1 = 2
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/soup/porridge

/datum/cookingrecipe/oven/oatmeal
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/oatmeal
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/soup/oatmeal

/datum/cookingrecipe/oven/tomsoup
	item1 = /obj/item/reagent_containers/food/snacks/plant/tomato
	amt1 = 2
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/soup/tomato

/datum/cookingrecipe/oven/mint_chutney
	item1 = /obj/item/plant/herb/mint
	item2 = /obj/item/reagent_containers/food/snacks/plant/chili
	item3 = /obj/item/reagent_containers/food/snacks/plant/garlic
	item4 = /obj/item/reagent_containers/food/snacks/plant/onion
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/soup/mint_chutney

/datum/cookingrecipe/oven/refried_beans
	item1 = /obj/item/reagent_containers/food/snacks/plant/bean
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/soup/refried_beans

/datum/cookingrecipe/oven/chili
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/
	item2 = /obj/item/reagent_containers/food/snacks/plant/chili
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/soup/chili

/datum/cookingrecipe/oven/queso
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	item2 = /obj/item/reagent_containers/food/snacks/plant/chili
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/soup/queso

/datum/cookingrecipe/oven/superchili
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/
	item2 = /obj/item/reagent_containers/food/snacks/plant/chili
	item3 = /obj/item/reagent_containers/food/snacks/condiment/hotsauce
	amt3 = 2
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/soup/superchili

/datum/cookingrecipe/oven/ultrachili
	item1 = /obj/item/reagent_containers/food/snacks/soup/chili
	item2 = /obj/item/reagent_containers/food/snacks/soup/superchili
	item3 = /obj/item/reagent_containers/food/snacks/plant/chili
	item4 = /obj/item/reagent_containers/food/snacks/condiment/hotsauce
	cookbonus = 20
	output = /obj/item/reagent_containers/food/snacks/soup/ultrachili

/datum/cookingrecipe/oven/salad
	item1 = /obj/item/reagent_containers/food/snacks/plant/lettuce
	amt1 = 2
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/salad

//Delightful Halloween Recipes
/datum/cookingrecipe/oven/candy_apple
	item1 = /obj/item/reagent_containers/food/snacks/plant/apple/stick
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/sugar
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/candy/candy_apple

/datum/cookingrecipe/oven/candy_apple_sour
	item1 = /obj/item/reagent_containers/food/snacks/plant/apple/stick/sour
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/sugar
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/candy/candy_apple/sour

/datum/cookingrecipe/oven/candy_apple_poison
	item1 = /obj/item/reagent_containers/food/snacks/plant/apple/stick/poison
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/sugar
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/candy/candy_apple/poison

//Cakes!
/datum/cookingrecipe/mixer/cake_batter
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	amt2 = 2
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/cake_batter
	category = "Cakes"

/datum/cookingrecipe/oven/cake_cream
	item1 = /obj/item/reagent_containers/food/snacks/cake_batter
	item2 = /obj/item/reagent_containers/food/snacks/condiment/cream
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/cake/cream
	category = "Cakes"

/datum/cookingrecipe/oven/cake_chocolate
	item1 = /obj/item/reagent_containers/food/snacks/cake_batter
	item2 = /obj/item/reagent_containers/food/snacks/candy/regular
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/cake/chocolate
	category = "Cakes"

/datum/cookingrecipe/oven/cake_meat
	item1 = /obj/item/reagent_containers/food/snacks/cake_batter
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/cake/meat
	category = "Cakes"

/datum/cookingrecipe/oven/cake_bacon
	item1 = /obj/item/reagent_containers/food/snacks/cake_batter
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	amt2 = 3
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/cake/bacon
	category = "Cakes"

/datum/cookingrecipe/oven/cake_true_bacon
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	amt1 = 7
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/cake/true_bacon
	category = "Cakes"

#ifdef XMAS

/datum/cookingrecipe/oven/cake_fruit
	item1 = /obj/item/reagent_containers/food/snacks/yuckburn
	item2 = /obj/item/reagent_containers/food/snacks/yuck
	cookbonus = 14
	output = null
	category = "Cakes"

	specialOutput(var/obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		var/fruitcake = new /obj/item/reagent_containers/food/snacks/fruit_cake
		playsound(ourCooker.loc, "sound/effects/splat.ogg", 50, 1)

		return fruitcake

#endif

/datum/cookingrecipe/oven/cake_custom
	item1 = /obj/item/reagent_containers/food/snacks/cake_batter
	cookbonus = 14
	output = null
	category = "Cakes"

	specialOutput(var/obj/submachine/ourCooker)
		if(!ourCooker)
			return null

		var/obj/item/reagent_containers/food/snacks/cake_batter/docakeitem = locate() in ourCooker.contents

		var/obj/item/reagent_containers/food/snacks/S
		if(docakeitem.custom_item)
			S = docakeitem.custom_item
		var/obj/item/reagent_containers/food/snacks/cake/B = new /obj/item/reagent_containers/food/snacks/cake(ourCooker)
		var/image/overlay = new /image('icons/obj/foodNdrink/food_dessert.dmi',"cake1-base_custom")
		B.food_color = S ? S.food_color : "#CC8555"
		overlay.color = B.food_color
		overlay.alpha = 255
		B.UpdateOverlays(overlay,"first")
		B.cake_bases = list("base_custom")
		if(S)
			S.reagents.trans_to(B, 50)
			B.food_effects += S.food_effects
			if(S.real_name)
				B.name = "[S.real_name] cake"
				for(var/food_effect in S.food_effects)
					if(food_effect in B.food_effects)
						continue
					B.food_effects += food_effect
			else
				B.name = "[S.name] cake"
		else
			B.name = "plain cake"

		B.desc = "Mmm! A delicious-looking [B.name]!"
		return B


/datum/cookingrecipe/oven/cake_custom_item
	item1 = /obj/item/reagent_containers/food/snacks/cake/cream
	cookbonus = 14
	output = null
	category = "Cakes"

	specialOutput(var/obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		var/obj/item/cake_item/B = new /obj/item/cake_item(ourCooker)
		for (var/obj/item/I in ourCooker.contents)
			if (istype(I,/obj/item/cake_item))
				continue
			I.set_loc(B)
			break

		return B

/datum/cookingrecipe/mixer/mix_cake_custom
	item1 = /obj/item/reagent_containers/food/snacks/cake_batter
	amt1 = 1
	output = null

	specialOutput(var/obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		for (var/obj/item/I in ourCooker.contents)
			if (istype(I, item1))
				continue
			else if (istype(I,/obj/item/reagent_containers/food/snacks/))
				var/obj/item/reagent_containers/food/snacks/cake_batter/batter = new

				batter.custom_item = I
				I.set_loc(batter)
				batter.name = "[I:real_name ? I:real_name : I.name] cake batter"
				for (var/obj/M in ourCooker.contents)
					qdel(M)

				return batter

		return null


/datum/cookingrecipe/oven/omelette
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/omelette

/datum/cookingrecipe/oven/omelette_bee
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/egg/bee
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/omelette/bee

/datum/cookingrecipe/mixer/pancake_batter
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/drinks/milk
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	amt3 = 2
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/ingredient/pancake_batter

/datum/cookingrecipe/oven/pancake
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/pancake_batter
	cookbonus = 11
	output = /obj/item/reagent_containers/food/snacks/pancake

/datum/cookingrecipe/mixer/mashedpotatoes
	item1 = /obj/item/reagent_containers/food/snacks/plant/potato
	amt1 = 3
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/mashedpotatoes

/datum/cookingrecipe/mixer/mashedbrains
	item1 = /obj/item/organ/brain
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/mashedbrains

/datum/cookingrecipe/mixer/creamofmushroom
	item1 = /obj/item/reagent_containers/food/snacks/mushroom
	item2 = /obj/item/reagent_containers/food/drinks/milk
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/soup/creamofmushroom

/datum/cookingrecipe/mixer/creamofmushroom/amanita
	item1 = /obj/item/reagent_containers/food/snacks/mushroom/amanita
	output = /obj/item/reagent_containers/food/snacks/soup/creamofmushroom/amanita

/datum/cookingrecipe/mixer/creamofmushroom/psilocybin
	item1 = /obj/item/reagent_containers/food/snacks/mushroom/psilocybin
	output = /obj/item/reagent_containers/food/snacks/soup/creamofmushroom/psilocybin

/datum/cookingrecipe/mixer/meatpaste
	item1 =  /obj/item/reagent_containers/food/snacks/ingredient/meat/
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/ingredient/meatpaste/

/datum/cookingrecipe/oven/sloppyjoe
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meatpaste
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/sloppyjoe

/datum/cookingrecipe/oven/meatloaf
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meatpaste
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/meatloaf

/datum/cookingrecipe/oven/cereal_honey
	item1 = /obj/item/reagent_containers/food/snacks/cereal_box
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/honey
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cereal_box/honey

/datum/cookingrecipe/oven/granola_bar
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/honey
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/oatmeal
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/granola_bar

/datum/cookingrecipe/oven/hardboiled
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/ingredient/egg/hardboiled

/datum/cookingrecipe/oven/eggsalad
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/egg/hardboiled
	item2 = /obj/item/reagent_containers/food/snacks/salad
	item3 = /obj/item/reagent_containers/food/snacks/condiment/mayo
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/eggsalad

/datum/cookingrecipe/oven/biscuit
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/flour
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/biscuit

/datum/cookingrecipe/oven/hardtack
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/condiment/ironfilings
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/hardtack

/datum/cookingrecipe/oven/macguffin
	item1 = /obj/item/reagent_containers/food/snacks/emuffin
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	item4 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	amt1 = 2
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/macguffin

/datum/cookingrecipe/oven/haggis
	item1 = /obj/item/organ/
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/oatmeal
	item3 = /obj/item/reagent_containers/food/snacks/plant/onion
	cookbonus = 18
	output = /obj/item/reagent_containers/food/snacks/haggis

/datum/cookingrecipe/oven/haggass
	item1 = /obj/item/clothing/head/butt
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/oatmeal
	item3 = /obj/item/reagent_containers/food/snacks/plant/onion
	cookbonus = 18
	output = /obj/item/reagent_containers/food/snacks/haggis/ass

/datum/cookingrecipe/oven/scotch_egg
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/scotch_egg

/datum/cookingrecipe/oven/rice_ball
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/rice
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/rice_ball

/datum/cookingrecipe/oven/nigiri_roll
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish
	item2 = /obj/item/reagent_containers/food/snacks/rice_ball
	cookbonus = 2
	output = /obj/item/reagent_containers/food/snacks/nigiri_roll

/datum/cookingrecipe/oven/sushi_roll
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish
	item2 = /obj/item/reagent_containers/food/snacks/rice_ball
	item3 = /obj/item/reagent_containers/food/snacks/rice_ball
	item4 = /obj/item/reagent_containers/food/snacks/ingredient/seaweed
	cookbonus = 2
	output = /obj/item/reagent_containers/food/snacks/sushi_roll

/datum/cookingrecipe/oven/riceandbeans
	item1 = /obj/item/reagent_containers/food/snacks/plant/bean
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/rice
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/riceandbeans

/datum/cookingrecipe/oven/friedrice
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/rice
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	item3 = /obj/item/reagent_containers/food/snacks/plant/onion
	item4 = /obj/item/reagent_containers/food/snacks/plant/garlic
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/friedrice

/datum/cookingrecipe/oven/omurice
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/rice
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	item3 = /obj/item/reagent_containers/food/snacks/condiment/ketchup
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/omurice

/datum/cookingrecipe/oven/risotto
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/rice
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/butter
	item3 = /obj/item/reagent_containers/food/snacks/plant/onion
	item4 = /obj/item/reagent_containers/food/snacks/plant/garlic
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/risotto

/datum/cookingrecipe/oven/cheesewheel
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	amt1 = 4
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/cheesewheel

// Recipe for zongzi is a WIP; we're gonna need rice balls or something

/datum/cookingrecipe/oven/beefood
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/honey
	item2 = /obj/item/plant/wheat
	item3 = /obj/item/reagent_containers/food/snacks/yuck
	cookbonus = 22
	output = /obj/item/reagent_containers/food/snacks/beefood

/datum/cookingrecipe/oven/b_cupcake
	item1 = /obj/item/reagent_containers/food/snacks/beefood
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/sugar
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/royal_jelly
	item4 = /obj/item/device/light/candle/small
	cookbonus = 22
	output = /obj/item/reagent_containers/food/snacks/b_cupcake

	specialOutput(var/obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		var/obj/item/reagent_containers/food/snacks/b_cupcake = new /obj/item/reagent_containers/food/snacks/b_cupcake

		b_cupcake.desc = "A little birthday cupcake for a bee. May not taste good to non-bees."
		var/icon/I = new /icon('icons/obj/foodNdrink/food_dessert.dmi',"b_cupcake")
		var/random_color = rgb(rand(1,255), rand(1,255), rand(1,255))
		I.Blend(random_color, ICON_ADD)
		b_cupcake.icon = I

		return b_cupcake

/datum/cookingrecipe/mixer/butters
	item1 = /obj/item/clothing/head/butt
	item2 = /obj/item/reagent_containers/food/drinks/milk
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/condiment/butters

/datum/cookingrecipe/oven/lipstick
	item1 = /obj/item/pen/crayon
	item2 = /obj/item/item_box/figure_capsule
	cookbonus = 10
	output = /obj/item/pen/crayon/lipstick

	specialOutput(obj/submachine/ourCooker)
		if (!ourCooker)
			return null
		var/obj/item/pen/crayon/lipstick/lipstick = new /obj/item/pen/crayon/lipstick
		for (var/obj/item/pen/crayon/C in ourCooker.contents)
			lipstick.font_color = C.font_color
			lipstick.color_name = hex2color_name(lipstick.font_color)
			lipstick.name = "[lipstick.color_name] lipstick"
			lipstick.update_icon()
		return lipstick

/datum/cookingrecipe/fryer
	//I noticed you can pour reagents into the fryer, so why not make a little stub :3
	//not actually functional in fryer code atm
	var/required_reagents = null

	//ATM only one item can go into the fryer, so only item1 ever gets checked.

//glorious potatoes
/datum/cookingrecipe/fryer/fries
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/chips
	output = /obj/item/reagent_containers/food/snacks/fries
	cookbonus = 15

/datum/cookingrecipe/fryer/fat_fries
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/chips_thicc
	output = /obj/item/reagent_containers/food/snacks/fat_fries
	cookbonus = 15
