//Hey I heard we're doing files like these

//flap flap gonna put cursed stuff here

//urticating hairs

///Discord joke that might not be funny two weeks from now (but if it isn't we can just yeet it)
/obj/item/clothing/under/gimmick/bikinion
	name = "\proper bikinion"
	desc = "The only thing proven in court to ward off evil, because nothing wants to be near it."
	icon_state = "bikinion"
	item_state = "yay" //I can't be arsed right now

///Being the space boss California
/obj/item/clothing/under/gimmick/bossCalifornia
	name = "space boss California"
	desc = "Oh that? That's the space boss California."
	icon_state = "spaceboss"
	///How many times are you going to repeat this joke you nincompoop
	var/shirts = 5
	///get your own damn space boss shirt >:(
	cant_other_remove = TRUE

	New()
		..()
		wear_image.overlays += image('icons/mob/overcoats/worn_suit_gimmick.dmi', "spaceboss_shirt")

	//This is kinda easily defeated but AFAIK equipping code isn't set up to ever handle "failed to unequip"
	//cant_remove_self exists but that get checked on mobs before the item is ever given chance to intervene.
	///Take of your shirt, probably
	unequipped(mob/living/carbon/human/user)
		..()
		if (shirts) //we're not done yet bucko
			SPAWN_DBG(0 SECONDS) //gotta wait for whatever's unequipping to finish their set_loc stuff
				user.drop_item(src)
				user.equip_if_possible(src, user.slot_w_uniform) //IDK which of the many equipping related procs is the right one
				user.put_in_hand_or_drop(new /obj/item/clothing/suit/gimmick/bossCalifornia_shirt)
				user.say("Oh[prob(50)?",":null] me? [pick("Oh well ", "Well ", null)]I'm the space boss California.") //covers just about any variation in the original video
				if ((--shirts) < 1) //did we run out
					wear_image.overlays = null
					user.update_clothing() //set_clothing_icon_dirty is too slow when someone's repeatedly taking shirts off

//The loose space boss shirt, which is a suit so you can layer it over the depleted jumpsuit and get that untucked vibe from the good old days
//(also it doesn't have pockets)
/obj/item/clothing/suit/gimmick/bossCalifornia_shirt
	name = "space boss California shirt"
	desc = "A memorial to the declaration of a space boss. California."
	icon_state = "spaceboss_shirt"

/*
2022-10-14
Warc: but the question is - if anyone is using paper calendara with pictures of hot, naked, lusciously buttered up, lascivious and tempting, dark, mysterious, pants-meltingly desireable, mouth watering clownes on them- who is and why?

Bat: don't tempt my spriting hand :P

Warc: i am nothing if not a temptress (content production)
*/

//Produced content
/obj/decal/poster/wallsign/clown_calendar
	desc = "A calendar with bawdy pinups of attractive clowns." //Presented without further comment
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "calendar_rand"

	get_desc(var/dist, var/mob/user)
		if (user.mind?.assigned_role == "Clown")
			. += " These promote heavily unrealistic expectations for clowns!" //Clown solidarity

/obj/decal/poster/wallsign/clown_calendar/slip
	name = "Banana-Peel Beefcakes" //(deliberately proper names)
	icon_state = "calendar_A"

/obj/decal/poster/wallsign/clown_calendar/bridge
	name = "Bridge Break-in Burlesques"
	icon_state = "calendar_B"

/obj/decal/poster/wallsign/clown_calendar/honk
	name = "Hunks That Honk"
	icon_state = "calendar_C"

/obj/random_item_spawner/clown_calendar
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "calendar_rand"
	amt2spawn = 1
	items2spawn = list(/obj/decal/poster/wallsign/clown_calendar/slip, /obj/decal/poster/wallsign/clown_calendar/bridge, /obj/decal/poster/wallsign/clown_calendar/honk)

//I have a phobia for spiderwebs why the fuck did I do this
/obj/spacevine/web //looking at this spread genuinely triggers fear
	name = "webzu"
	desc = "Jesus Christ there's so many spiders in there fuck shit fuck."
	icon_state = "web-light1"
	base_state = "web"
	vinepath = /obj/spacevine/web/living

/obj/spacevine/web/living
	run_life = 1
//These will make the flower pods like kudzu does, cause kudzu infection is a proc on humans called by their decomposition lifeprocess what the hell am I supposed to do with that


///Hell vending machine that stocks itself with every single valid ingredient it finds in the oven recipe list, so you don't have to procure them.
obj/machinery/vending/kitchen/oven_debug //Good luck finding them though
	name = "cornucopia of ingredience"
	desc = "Everything you could ever need, in abundance."
	req_access_txt = null
	color = "#CCFFCC"

	create_products()
		//Fun fact this proc doesn't need to call parent, which is why I can have it be a subtype of the kitchen vendor
		build_oven_recipes()
		var/list/all_ingredients_ever = list()
		for(var/datum/cookingrecipe/recipe as anything in oven_recipes)
			if (recipe.item1)
				if(IS_ABSTRACT(recipe.item1))
					all_ingredients_ever |= pick(concrete_typesof(recipe.item1, cache = FALSE)) //Get something that'll qualify just in case
				else
					all_ingredients_ever |= recipe.item1
			if (recipe.item2)
				if(IS_ABSTRACT(recipe.item2))
					all_ingredients_ever |= pick(concrete_typesof(recipe.item2, cache = FALSE))
				else
					all_ingredients_ever |= recipe.item2
			if (recipe.item3)
				if(IS_ABSTRACT(recipe.item3))
					all_ingredients_ever |= pick(concrete_typesof(recipe.item3, cache = FALSE))
				else
					all_ingredients_ever |= recipe.item3
			if (recipe.item4)
				if(IS_ABSTRACT(recipe.item4))
					all_ingredients_ever |= pick(concrete_typesof(recipe.item4, cache = FALSE))
				else
					all_ingredients_ever |= recipe.item4
		for(var/type in all_ingredients_ever)
			product_list += new/datum/data/vending_product(type, 50)

///Something you can plop down in the map editor as a reference for screen size and what bits will get obscured by the HUD
/obj/mapping_HUD_template
	icon = 'icons/map-editing/mapping_HUD_template.dmi'
	icon_state = "template" //blue is TG HUD, yellow is regular
	plane = PLANE_HUD

	New()
		..()
		qdel(src)

	//centered on the turf you click in the editor :)
	centered
		pixel_x = -320
		pixel_y = -224

//fursuits (they were designed as "dragon costumes" but let's be honest, they're fursuits)
/obj/item/clothing/under/gimmick/dragon
	name = "dragon suit"
	icon_state = "dragon_blue"
	item_state = "dragon_blue"
/obj/item/clothing/under/gimmick/dragon/red
	icon_state = "dragon_red"
	item_state = "dragon_red"
/obj/item/clothing/under/gimmick/dragon/green
	icon_state = "dragon_green"
	item_state = "dragon_green"
/obj/item/clothing/under/gimmick/dragon/white
	icon_state = "dragon_white"
	item_state = "dragon_white"

/obj/item/clothing/suit/gimmick/dragon
	name = "dragon wings"
	icon_state = "dragon_blue"
	item_state = "dragon_blue"
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
/obj/item/clothing/suit/gimmick/dragon/red
	icon_state = "dragon_red"
	item_state = "dragon_red"
/obj/item/clothing/suit/gimmick/dragon/green
	icon_state = "dragon_green"
	item_state = "dragon_green"
/obj/item/clothing/suit/gimmick/dragon/white
	icon_state = "dragon_white"
	item_state = "dragon_white"

//AFAIK we don't have a generic "trash worn on belt" thing
/obj/item/dragon_tail
	name = "dragon tail"
	flags = FPRINT | ONBELT
	icon = 'icons/obj/items/belts.dmi'
	wear_image_icon = 'icons/mob/belt.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	icon_state = "dragon_blue"
	item_state = "dragon_blue"
/obj/item/dragon_tail/red
	icon_state = "dragon_red"
	item_state = "dragon_red"
/obj/item/dragon_tail/green
	icon_state = "dragon_green"
	item_state = "dragon_green"
/obj/item/dragon_tail/white
	icon_state = "dragon_white"
	item_state = "dragon_white"

/obj/item/clothing/shoes/dragon
	name = "dragon shoes"
	icon_state = "dragon_blue"
	item_state = "dragon_blue"
/obj/item/clothing/shoes/dragon/red
	icon_state = "dragon_red"
	item_state = "dragon_red"
/obj/item/clothing/shoes/dragon/green
	icon_state = "dragon_green"
	item_state = "dragon_green"
/obj/item/clothing/shoes/dragon/white
	icon_state = "dragon_white"
	item_state = "dragon_white"

/obj/item/clothing/head/dragon
	name = "dragon hood"
	icon_state = "dragon_blue"
	item_state = "dragon_blue"
/obj/item/clothing/head/dragon/red
	icon_state = "dragon_red"
	item_state = "dragon_red"
/obj/item/clothing/head/dragon/green
	icon_state = "dragon_green"
	item_state = "dragon_green"
/obj/item/clothing/head/dragon/white
	icon_state = "dragon_white"
	item_state = "dragon_white"

//dumb joke
/obj/item/gun_exploder/mythical
	name = "gunsemything anvil"
	desc = "hit it with a gun 'till the gun reveals its deepest secrets rofl"

	attackby(obj/item/gun/modular/W as obj, mob/user as mob, params)
		if(!istype(W) || prob(70) || !W.built)
			playsound(src.loc, "sound/impact_sounds/Wood_Hit_1.ogg", 70, 1)
			return
		var/coolname = "\proper "
		var/segments = rand(1,4)
		var/newbit
		for (var/i = 1, i <= segments, i++)
			//I know these are sword names just shush
			newbit = pick("grar", "drakh" , "farth" , "kroth" , "ire", "mor", "death", "dragon", "wyrm", "flame", "doom", "iano", "thon", "thor", "azal", "celsior", "calibur", "berge", "rok", "holi", "bane", "farte", "winky", "peebim")
			if (i == 1)
				newbit = capitalize(newbit)
			coolname += newbit

		coolname += " the [pick("Legendary", "Mythical", "Lost", "Arcane", "Feared", "Reaver", "Wrathful", "Vanquisher", "Bloody", "Corrupted")]"
		W.name = coolname
		boutput(user, "<span class='notice'>You discover the true identity of your gun!</span>")
		playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1)

//:3
/obj/item/clothing/suit/weakness
	name = "glowing weak point"
	desc = "Hope nobody hits you there."
	icon = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi' //to yourself
	wear_image_icon = 'icons/mob/overcoats/worn_suit_hazard.dmi'
	icon_state = "weakpoint"
	item_state = "weakpoint"
	body_parts_covered = TORSO

	setupProperties()
		..()
		setProperty("meleeprot", -8)
		setProperty("rangedprot", -0.5) //double damage

//what if a crate looted you
/obj/storage/crate/loot_crate/reverse
	name = "loot crate"
	desc = "A small, cuboid object with a hinged top and looted interior."
	spawn_contents = list()
	event_handler_flags = USE_FLUID_ENTER | USE_CANPASS | NO_MOUSEDROP_QOL | USE_PROXIMITY

/obj/storage/crate/loot_crate/reverse/HasProximity(atom/movable/AM)
	if (ishuman(AM) && !GET_COOLDOWN(src, "looting"))
		var/mob/living/carbon/human/H = AM
		var/shit2steal = list()
		var/obj/ourpick
		if (H.r_store)
			shit2steal += H.r_store
		if (H.l_store)
			shit2steal += H.l_store
		if (H.wear_mask)
			shit2steal += H.wear_mask
		if (H.head)
			shit2steal += H.head
		if (H.glasses)
			shit2steal += H.glasses
		if (H.shoes)
			shit2steal += H.shoes

		if (length(shit2steal))
			ourpick = pick(shit2steal)
		else
			if (H.w_uniform) //be mean if they've got nothing left
				ourpick = H.w_uniform
			else
				return
		close()
		H.u_equip(ourpick)
		ourpick.set_loc(src)
		src.visible_message("[src] loots [ourpick].") //deliberately no mention of the victim
		ON_COOLDOWN(src, "looting", (rand(6 SECONDS, 10 SECONDS)))

//stubs for secret stuff
/var/datum/controller/process/crash_zone/valiant_controls
/datum/controller/process/crash_zone/
/datum/controller/process/crash_zone/proc/debug_panel()

//This all goes off of the vaguest recollection of DNA electrophoresis. It's probably not accurate in any way.
//The point really is just to make genetics embedded in physical stuff as much as it is in the computers.
/obj/item/device/gene_separator
	name = "\improper DNA electrophoresis unit"
	desc = "Takes an agarose substrate that has DNA on it, and will then separate that DNA into smaller groups of genes over time."
	icon = 'icons/obj/items/genetics.dmi'
	icon_state = "box"
	var/obj/item/reagent_containers/agarose/our_slab = null
	var/active = FALSE

	New()
		..()
		var/image/img = image(src.icon, icon_state = "box-front", layer = FLOAT_LAYER - 2)
		UpdateOverlays(img, "front-of-box")

	disposing()
		turn_off()
		UpdateOverlays(null, "agarose")
		UpdateOverlays(null, "agarose_goop")
		qdel(our_slab)
		our_slab = null
		..()

	attackby(obj/item/W, mob/user, params)
		if (istype(W, /obj/item/reagent_containers/agarose))
			if (our_slab)
				boutput(user, "<span class='alert'>[src] already has material in it.</span>")
				return
			user.drop_item(W)
			W.set_loc(src)
			our_slab = W
			UpdateOverlays(image(our_slab.icon, icon_state = our_slab.icon_state, layer = FLOAT_LAYER), "agarose")
			UpdateOverlays(our_slab.development_img, "agarose_goop")
			boutput(user, "<span class='notice'>You put [our_slab] in [src].</span>")
		else ..()

	attack_hand(mob/user)
		if (our_slab && !active && user.find_in_hand(src))
			turn_off()
			user.put_in_hand(our_slab)
			our_slab = null
			UpdateOverlays(null, "agarose")
			UpdateOverlays(null, "agarose_goop")

		else ..()

	attack_self(mob/user)
		if (our_slab)
			if (active)
				turn_off()
				boutput(user, "<span class='notice'>You turn off [src].</span>")
				playsound(src,'sound/misc/lightswitch.ogg',40,1)
			else
				if ((our_slab.time_to_finish && our_slab.time_spent > our_slab.time_to_finish)/*our_slab.development >= 100*/ || (length(our_slab.gene_groups) > 1)) //latter shouldn't be possible on a fresh slab
					boutput(user, "<span class='alert'>This slab has already been fully developed and is spent. Transfer its contents onto a fresh slab.</span>")
					return
				active = TRUE
				processing_items |= src

				if (!our_slab.time_to_finish) //uninitialised
					//Let's make some shit up
					//Generally: the less genes we're splitting, the longer it's gonna be (non-linear).
					//This is to try and encourage people splitting down to groups of 2-3 a bit.
					//instead of bluntly splitting everything down to individual genes. Hand out hulk with an accent maybe? better than waiting ages.
					//At the same time, have the stability of the constituent genes play a role in the timer too.
					//And add in a dash of randomness~
					var/list/group = our_slab.gene_groups[1]
					var/total_genes = length(group)
					if (!total_genes) //abort
						//deactivate()
						return
					var/total_stability_change = 0
					for (var/datum/bioEffect/gene in group)
						total_stability_change += abs(gene.stability_loss)

					//~4m for 2 genes, ~2m for 4 genes, a full genome of 11 genes is a bit over 30s
					var/time_penalty_genes = ((8/total_genes) MINUTES) - (total_genes SECONDS)
					//splitting two (+/-)40 stability genes takes longer (or shorter!) than two (+/-) 5 stability ones, but full genome lightly affected by stability factor
					var/stability_factor = (total_stability_change/total_genes)
					var/time_penalty_stability = rand(-stability_factor, stability_factor) SECONDS
					our_slab.time_to_finish = time_penalty_genes + time_penalty_stability + (rand(-10,10) SECONDS) //slight random factor
					if (our_slab.time_to_finish < 0) //If i did it right the above maths can't produce negative results until 16 genes, but to be safe
						our_slab.time_to_finish = 30 SECONDS

				var/how_long_will_it_take = "until the end of time"
				switch(our_slab.time_to_finish - our_slab.time_spent)
					if (0 to 30 SECONDS)
						how_long_will_it_take = "not long at all"
					if (30 to 60 SECONDS)
						how_long_will_it_take = "a brief time"
					if (1 MINUTE to 2 MINUTES)
						how_long_will_it_take = "a short while"
					if (2 MINUTE to INFINITY)
						how_long_will_it_take = "quite a while"
				boutput(user, "<span class='notice'>You turn on [src]. This will take [how_long_will_it_take].</span>")
				playsound(src,'sound/misc/lightswitch.ogg',40,1)

		..()


	process()
		..() //updates last_tick_duration

		if (!active) //burning? maybe?
			return
		if (!our_slab)
			turn_off()
			return
		if (our_slab.time_spent > our_slab.time_to_finish/*our_slab.development >= 100*/ || !our_slab.time_to_finish)
			turn_off()
			return
		//Basically undoing what the parent call did, I'm guessing last_tick_duration is intended as a lag mult
		//But we need the actual time elapsed.
		var/elapsed_time = last_tick_duration * ITEM_PROCESS_SCHEDULE_INTERVAL
		our_slab.time_spent += elapsed_time
		//our_slab.development = (our_slab.time_spent/our_slab.time_to_finish)*100
		our_slab.update_icon()
		UpdateOverlays(our_slab.development_img, "agarose_goop")
		if (our_slab.time_spent > our_slab.time_to_finish)
			our_slab.finish_developing()
			playsound(src, "sound/machines/ding.ogg", 30, 1)
			var/mob/holder = src.loc
			if (istype(holder))
				boutput(holder, "<span class='notice'>[src] finishes developing [our_slab].</span>")
			turn_off()



/obj/item/device/gene_separator/proc/turn_off()
	active = FALSE
	processing_items -= src
	//So here's a bit of technical debt that may bite us in the ass if we ever add more stuff to rely on last_processing_tick & last_tick_duration
	//It's clearly a little hack to get lag mult going for the robot hypospray, and it's made on the implicit assumption that the item never leaves the item process loop.
	//If something were to exit and then later re-enters the process loop, last_tick_duration will be massive to compensate the intervening time.
	//So this is here to reset that hack. If we didn't you might leave a unit dormant for a few minutes and then it'll slam the next slab from 0 to 100 in one tick.
	last_processing_tick = -1



//The base item is used for the small chunks the slabs get cut into.
/obj/item/reagent_containers/agarose
	name = "agarose chunk"
	desc = "A bunch of previously algae used genetic research."
	icon = 'icons/obj/items/genetics.dmi'
	icon_state = "agarose"
	initial_volume = 60
	w_class = W_CLASS_TINY
	rc_flags = RC_SPECTRO
	var/time_to_finish = 0 //premature
	var/time_spent = 0
	//var/development = 0
	var/list/gene_groups
	var/DNA_color = "#ffffff"
	var/image/development_img
	//not currently used, but I'm not sure how long I can go on without making this bit explicit
	var/is_a_chunk = TRUE

	New()
		..()
		gene_groups = list()
		development_img = image(src.icon, icon_state = "blank")

	disposing()
		qdel(development_img)
		development_img = null
		..()

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/genetics_injector/dna_injector))
			var/obj/item/genetics_injector/dna_injector/injector = I
			if (injector.uses)
				boutput(user, "<span class='alert'>[injector] already has material in it.</span>")
				return
			if (length(src.gene_groups) > 1)
				boutput(user, "<span class='alert'>There's several groups of gene goop in there. Cut this thing into chunks first.</span>")
				return
			injector.BE = src.gene_groups[1]
			injector.uses++
			injector.update_appearance()
			//worthless and empty, LIKE MY SOOOOOUUUULLL
			src.gene_groups = list()
			src.update_icon()
			boutput(user,"<span class='notice'>You take up the genes in the agarose with [injector].</span>")

		else if (istype(I, /obj/item/genetics_injector/dna_transfer))
			var/obj/item/genetics_injector/dna_transfer/donor = I

			if (donor.uses) //taking out of agarose
				if (!length(src.gene_groups))
					boutput(user, "<span class='alert'>[src] is empty.</span>")
					return
				if (length(src.gene_groups) > 1)
					boutput(user, "<span class='alert'>There's several groups of gene goop in there. Cut this thing into chunks first.</span>")
					return
				donor.gene_group = src.gene_groups[1]
				donor.uses--
				donor.DNA_color = src.DNA_color
				src.gene_groups = list()
				src.update_icon()
				boutput(user,"<span class='notice'>You take up the genes in [src] agarose with [donor].</span>")
			else //putting into agarose
				if (!length(donor.gene_group)) //??
					return
				if (length(src.gene_groups))
					boutput(user, "<span class='alert'>[src] already has material in it.</span>")
					return
				src.gene_groups = list(1)
				src.gene_groups[1] = donor.gene_group //deliberately nested list
				donor.gene_group = list()
				donor.uses++
				donor.update_appearance()
				src.DNA_color = donor.DNA_color
				src.update_icon()
				boutput(user,"<span class='notice'>You deposit the material in [donor] into [src].</span>")

		else if (iscuttingtool(I))
			switch(length(gene_groups))
				if (0 to 1) //empty or only one group, which a transfer syringe can handle.
					boutput(user, "<span class='alert'>No point in slicing [src] at the moment.</span>")
				if (2) //halve
					var/image/img
					var/obj/item/reagent_containers/agarose/chunk1 = new/obj/item/reagent_containers/agarose// {initial_volume = 30} ()
					chunk1.reagents.maximum_volume = 30
					src.reagents.trans_to(chunk1,src.reagents.total_volume / 2)
					chunk1.gene_groups = list(gene_groups[1])
					//the numbers aren't important, just that time_spent is larger (counting as fully developed)
					chunk1.time_to_finish = 1
					chunk1.time_spent = 2
					chunk1.pixel_x = src.pixel_x
					chunk1.pixel_y = src.pixel_y
					//chunk1.development = 100
					chunk1.icon_state = "[src.icon_state]-half1"
					img = image(src.icon, icon_state = "develop-half1")
					img.color = src.DNA_color
					chunk1.UpdateOverlays(img, "develop")

					var/obj/item/reagent_containers/agarose/chunk2 = new /obj/item/reagent_containers/agarose//{initial_volume = 30; initial_reagents = list("bacterialmedium"=15)}
					chunk2.reagents.maximum_volume = 30
					src.reagents.trans_to(chunk2,src.reagents.total_volume)
					chunk2.gene_groups = list(gene_groups[2])
					chunk2.time_to_finish = 1
					chunk2.time_spent = 2
					chunk2.pixel_x = src.pixel_x
					chunk2.pixel_y = src.pixel_y
					chunk2.icon_state = "[src.icon_state]-half2"
					img = image(src.icon, "develop-half2")
					img.color = src.DNA_color
					chunk2.UpdateOverlays(img, "develop")

					var/turf/T = get_turf(src)
					chunk1.set_loc(T)
					chunk2.set_loc(T)
				else //thirds
					var/image/img
					var/obj/item/reagent_containers/agarose/chunk1 = new /obj/item/reagent_containers/agarose//{initial_volume = 20; initial_reagents = list("bacterialmedium"=10)}
					chunk1.reagents.maximum_volume = 20
					src.reagents.trans_to(chunk1,src.reagents.total_volume / 3)
					chunk1.gene_groups = list(gene_groups[1])
					chunk1.time_to_finish = 1
					chunk1.time_spent = 2
					chunk1.pixel_x = src.pixel_x
					chunk1.pixel_y = src.pixel_y
					chunk1.icon_state = "[src.icon_state]-third1"
					img = image(src.icon, icon_state = "develop-third1")
					img.color = src.DNA_color
					chunk1.UpdateOverlays(img, "develop")

					var/obj/item/reagent_containers/agarose/chunk3 = new /obj/item/reagent_containers/agarose//{initial_volume = 20; initial_reagents = list("bacterialmedium"=10)}
					chunk3.reagents.maximum_volume = 20
					src.reagents.trans_to(chunk3,src.reagents.total_volume / 2) // (1-(1/3))/2 = (2/3)/2 = 1/3
					chunk3.gene_groups = list(gene_groups[length(gene_groups)])
					chunk3.time_to_finish = 1
					chunk3.time_spent = 2
					chunk3.pixel_x = src.pixel_x
					chunk3.pixel_y = src.pixel_y
					chunk3.icon_state = "[src.icon_state]-third3"
					img = image(src.icon, icon_state = "develop-third3")
					img.color = src.DNA_color
					chunk3.UpdateOverlays(img, "develop")

					//more than 3 groups? shouldn't happen but we may as well attempt to account
					//split into 3, separate one group into the first and one into the third chunk
					//the middle bit (which is physically larger) gets all the rest, probably needs to be re-developed on a fresh slab
					var/list/for_the_middle_chunk = gene_groups[2]
					if (length(gene_groups) > 3)
						for (var/i in 3 to (length(gene_groups) - 1))
							for_the_middle_chunk.Join(gene_groups[i])

					var/obj/item/reagent_containers/agarose/chunk2 = new /obj/item/reagent_containers/agarose//{initial_volume = 20; initial_reagents = list("bacterialmedium"=10)}
					chunk2.reagents.maximum_volume = 20
					src.reagents.trans_to(chunk2,src.reagents.total_volume)
					chunk2.gene_groups = list(for_the_middle_chunk)
					chunk2.time_to_finish = 1
					chunk2.time_spent = 2
					chunk2.pixel_x = src.pixel_x
					chunk2.pixel_y = src.pixel_y
					chunk2.icon_state = "[src.icon_state]-third2"
					img = image(src.icon, icon_state = "develop-third2")
					img.color = src.DNA_color
					chunk2.UpdateOverlays(img, "develop")

					var/turf/T = get_turf(src)
					chunk1.set_loc(T)
					chunk2.set_loc(T)
					chunk3.set_loc(T)
			qdel(src)
		else if (istype(I, /obj/item/device/analyzer/genes))
			var/obj/item/device/analyzer/genes/nerdery = I
			nerdery.do_scan(src, user)
		else
			..()

/obj/item/reagent_containers/agarose/proc/update_icon()
	if (!length(gene_groups))
		development_img.icon_state = "blank"
	else if (!time_to_finish || !time_spent)
		development_img.icon_state = "develop-0"
	else
		var/quarter = ceil((time_spent/time_to_finish)*4)//ceil(development/25)
		development_img.icon_state = "develop-[quarter]"
	development_img.color = DNA_color
	UpdateOverlays(development_img, "development")

/obj/item/reagent_containers/agarose/proc/finish_developing()

/obj/item/reagent_containers/agarose/separator
	name = "separator agarose slab"
	desc = "A bunch of previously algae used in splitting groups of genes."
	initial_reagents = list("bacterialmedium"=30) //Agarose derives from agar which is a common petri dish substrate so
	is_a_chunk = FALSE

	finish_developing()
		var/list/geneses = gene_groups[1]
		var/amount_of_genes = length(geneses)
		var/list/new_groups
		//try to split into groups of 4
		switch(amount_of_genes)
			if (11) //full genome
				new_groups = new/list(3)
				new_groups[1] = geneses.Copy(1,5)
				new_groups[2] = geneses.Copy(5,9)
				new_groups[3] = geneses.Copy(9,0)
			if (3)
				new_groups = new/list(3)
				new_groups[1] = list(geneses[1])
				new_groups[2] = list(geneses[2])
				new_groups[3] = list(geneses[3])
			else//whatever just halve the thing, this should take case of like everything else.
				var/halfway = round((amount_of_genes/2)+1)
				new_groups = new/list(2)
				new_groups[1] = geneses.Copy(1,halfway)
				new_groups[2] = geneses.Copy(halfway,0)
		gene_groups = new_groups

/obj/item/reagent_containers/agarose/replicator
	name = "replicator agarose slab"
	desc = "A bunch of previously algae impregnated with enzymes and nucleotides, ready to assemble into copies of genes put in."
	icon_state = "agarose-blu"
	initial_reagents = list("bacterialmedium"=30) //Agarose derives from agar which is a common petri dish substrate so
	is_a_chunk = FALSE

	finish_developing()
		var/list/geneses = gene_groups[1]
		var/amount_of_genes = length(geneses)
		var/list/new_groups = new/list((amount_of_genes <= 2 ? 3 : 2))
		var/list/temp = list()


		new_groups[1] = geneses
		for (var/datum/bioEffect/effect as anything in geneses)
			temp.Add(effect.GetCopy())
		new_groups[2] = temp

		if (amount_of_genes <= 2) //you get 3 copies of the group if it's smol :3
			temp = list()
			for (var/datum/bioEffect/once_again as anything in geneses)
				temp.Add(once_again.GetCopy())
			new_groups[3] = temp
		gene_groups = new_groups

//needle reuse party lets goooo
/obj/item/genetics_injector/dna_transfer
	name = "\improper DNA transfer syringe"
	desc = "Slurps the DNA straight out of someone's cells and into wherever, which is probably fine. Well, except for those cells. Sucks to be them."
	icon_state = "transfer_empty"
	var/list/gene_group
	var/DNA_color
	var/image/fluid_img

	inject_verb_self = "takes a gene sample from"
	inject_verb_other = "take a gene sample from"

	//In order for this thing to make use of generic injector code, the uses var is backwards from how other injectors use it:
	//if uses = 1, this thing is empty (but can used on people)
	//if uses = 0, this thing is filled (and needs to be emptied into agarose)

	New()
		..()
		gene_group = list()
		fluid_img = image(src.icon, icon_state = "transfer_fluid_empty")

	disposing()
		for (var/gene in gene_group)
			qdel(gene)
		gene_group = null
		qdel(fluid_img)
		fluid_img = null
		..()

	attackby(obj/item/W, mob/user, params)
		if (istype(W, /obj/item/device/analyzer/genes))
			var/obj/item/device/analyzer/genes/nerdery = W
			nerdery.do_scan(src, user)
		else ..()


	injected(var/mob/living/carbon/user,var/mob/living/carbon/target)
		if (..())
			return

		for(var/id as anything in target.bioHolder.effectPool)
			var/datum/bioEffect/their_gene = target.bioHolder.effectPool[id]
			//I'm fairly certain that this isn't correct, GetCopy is only intended for use on the global reference list
			//However that looks to be because of references to the block pair lists (don't want to corrupt the same list twice), which agarose doesn't use
			//We could deep copy their dnaBlocks datums but with no intended way of getting the genes into the computers again that shoooould be a waste of time.
			//Plus I'd like to kill off the block matching thing altogether it's just such a weirdly pointless part of genetics?
			gene_group.Add(their_gene.GetCopy())
		//target.bioHolder.AddEffectInstance(BE,1)
		src.DNA_color = target.bioHolder.DNA_color
		src.uses--
		src.update_appearance()

	update_appearance()
		fluid_img.color = DNA_color
		if(src.uses < 1) //was full, now empty
			flick("transfer_in", src)
			src.icon_state = "transfer_full"
			fluid_img.icon_state = "transfer_fluid_out"
			UpdateOverlays(fluid_img, "fluid")
		else //was empty, now full
			flick("transfer_out", src)
			src.icon_state = "transfer_empty"
			fluid_img.icon_state = "transfer_fluid_in"
			UpdateOverlays(fluid_img, "fluid")

		SPAWN_DBG(1 SECOND) //fluid animations stop indefinitely, this isn't timing critical
			if (!src.uses)
				fluid_img.icon_state = "transfer_fluid_full"
				UpdateOverlays(fluid_img, "fluid")
			else
				fluid_img.icon_state = "transfer_fluid_empty"
				UpdateOverlays(fluid_img, "fluid")



//"#1D257E"

/obj/item/storage/box/genetic_syringes
	name = "gene research syringe box"
	icon_state = "genetics_syringes"
	desc = "A box filled with many syringes specialised for genetics research, empty and sterilized."
	spawn_contents = list(/obj/item/genetics_injector/dna_transfer = 2, /obj/item/genetics_injector/dna_injector = 5)

/obj/item/storage/box/agarose_separator
	name = "separator agarose box"
	icon_state = "genetics_green"
	desc = "A box filled with green blocks of agarose for genetics research."
	spawn_contents = list(/obj/item/reagent_containers/agarose/separator = 7)

/obj/item/storage/box/agarose_replicator
	name = "replicator agarose box"
	icon_state = "genetics_blue"
	desc = "A box filled with blue blocks of agarose for genetics research."
	spawn_contents = list(/obj/item/reagent_containers/agarose/replicator = 7)

/obj/storage/crate/gene_separators
	name = "electrophoresis unit crate"
	desc = "A box filled with other boxes, but these boxes are electronic! Genetics research!"
	spawn_contents = list(/obj/item/device/gene_separator = 8)

/obj/item/device/analyzer/genes
	name = "gene analyzer"
	desc = "Also analyzes jeans."
	icon = 'icons/obj/items/genetics.dmi'
	icon_state = "shitty_temp_scanner"
	w_class = W_CLASS_SMALL

/obj/item/device/analyzer/genes/proc/do_scan(obj/item/I, mob/user)
	if (!I || !user)
		return
	var/list/them_genes
	if (istype(I, /obj/item/genetics_injector/dna_transfer))
		var/obj/item/genetics_injector/dna_transfer/T = I
		them_genes = T.gene_group

	else if (istype(I, /obj/item/genetics_injector/dna_injector))
		var/obj/item/genetics_injector/dna_injector/inj = I
		them_genes = inj.BE
	else if (istype(I, /obj/item/reagent_containers/agarose))
		var/obj/item/reagent_containers/agarose/A = I
		them_genes = A.gene_groups
		if (length(A.gene_groups) == 1)
			them_genes = A.gene_groups[1] //supposed to prevent "agarose contains 1 groups of genes.", IDK why it doesn't work

	if (!length(them_genes))
		boutput(user,"<span class='notice'><b>[I] does not contain any genes.</b></span>")
		return
	var/out = ""
	if (islist(them_genes[1])) //there's multiple groups wheee
		out += "<span class='notice'>[I] contains [length(them_genes)] groups of genes.<br></span>"
		for (var/i in 1 to length(them_genes))
			var/list/a_group = them_genes[i]
			out += "<span class='notice'><b>group [i]:<br></b></span>"
			out += do_scan_internal(a_group)
			out += "<span class='notice'>...</span>"

	else
		out += "<span class='notice'>[I] contains the following genes:<br></span>"
		out += do_scan_internal(them_genes)
	boutput(user, out)


/obj/item/device/analyzer/genes/proc/do_scan_internal(var/list/datum/bioEffect/shit)
	if (!islist(shit))
		return null
	var/out = ""
	for (var/datum/bioEffect/gene in shit)
		out += "[gene.name] ([gene.stability_loss])<br>"
	return out

/obj/item/clothing/under/gimmick/chaps/prophetic
	desc = "These are more literal than most."

	equipped(mob/user, slot)
		..()
		if (isliving(user))
			var/mob/living/L = user
			var/obj/item/clothing/head/butt/myButt = L.organHolder?.drop_organ("butt")
			if (myButt)
				qdel(myButt)
				L.playsound_local(src, 'sound/impact_sounds/Flesh_Tear_1.ogg', 50, TRUE)
				boutput(L, "<span class='alert'><b>WOE, THINE BUTTE IS LOST!!</b></span>")

//Diner's back in the debris field, so,
/obj/item/paper/tug/diner_arcade_invoice_the_sequel
    name = "Big Yank's Space Tugs, Limited."
    desc = "Looks like a bill of sale."
    info = {"<b>Client:</b> Bill, John
            <br><b>Date:</b> TBD
            <br><b>Articles:</b> Structure, Static. Pressurized. Duplex.
            <br><b>Destination:</b> \"Put it back please, I'm sick of the view.\"\[sic\]
            <br>
            <br><b>Total Charge:</b> 9,233 paid in full with novelty jumbo hotdog-esques.
            <br>Big Yank's Cheap Tug"}

/*
/obj/spawn_all_the_dragon_shit
	New()
		..()
		var/turf/T = get_turf(src)
		for(var/derg_type in concrete_typesof(/obj/item/clothing/under/gimmick/dragon))
			new derg_type(T)
		for(var/derg_type in concrete_typesof(/obj/item/clothing/suit/gimmick/dragon))
			new derg_type(T)
		for(var/derg_type in concrete_typesof(/obj/item/dragon_tail))
			new derg_type(T)
		for(var/derg_type in concrete_typesof(/obj/item/clothing/shoes/dragon))
			new derg_type(T)
		for(var/derg_type in concrete_typesof(/obj/item/clothing/head/dragon))
			new derg_type(T)
		qdel(src)
*/
/*
/area/proc/Force_Ambience(mob/M)
		if (M?.client)
			src.pickAmbience()
			M.client.playAmbience(src, AMBIENCE_FX_1, 18)

/client/proc/admin_force_ambience()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Debug Force Area Ambience"
	if(!src.holder)
		alert("You are not an admin")
		return
	if (src.mob)
		var/area/A = get_area(src.mob)
		A.Force_Ambience(src.mob)
*/
//When uncommented, these two together should produce an undecidability crash in insert_recipe
/*
/datum/cookingrecipe/undecidable_A
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/egg/bee
	item2 = /obj/item/reagent_containers/food/snacks/breadslice/

/datum/cookingrecipe/undecidable_B
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	item2 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
*/

/*
		//MINING GENERATION BITS
		//Generates a kinda vertical stratified thing (heavily biased to light rock), kinda like ant nests or sand dunes
		//having randflip pick between 10 and 17 instead creates funky wavy terrain

		var/map[world.maxx][world.maxy]
		var/randflip = rand(3,7)
		var/doing_dense = rand(0,1)
		for(var/y=max(starty - 1,1), y<= min(endy + 1, world.maxy), y++)
			for(var/x=max(startx - 1,1), x <= min(endx + 1, world.maxx), x++)
				if (randflip == 0)
					randflip = rand(3,7)
					doing_dense = !doing_dense
				map[x][y] = doing_dense/*pick(90;1,100;0)*/ //Initialize randomly.
				randflip--

		//Generates a simple marbled look
		for(var/x=max(startx - 1,1), x <= min(endx + 1, world.maxx), x++)
			for(var/y=max(starty - 1,1), y<= min(endy + 1, world.maxy), y++)
				map[x][y] = pick(90;1,100;0) //Initialize randomly.

*/



//asteroidsDistance plunking a bunch of suspiciously diamond-shaped asteroids on the map is functionally fine and all
//But it's not really aesthetically pleasing
/*
/datum/mapGenerator/asteroid_belts
	//You can adjust these before generating if you want
	var/number_of_belts = 3 //

	generate(var/list/miningZ)
		var/numAsteroidSeed = AST_SEEDS + rand(1, 5)
		for(var/i=0, i<numAsteroidSeed, i++)
			var/turf/X = pick(miningZ)
			//var/quality = rand(-101,101)

			while(!istype(X, /turf/space) || ISDISTEDGE(X, AST_MAPSEEDBORDER) || (X.loc.type != /area/space && !istype(X.loc , /area/allowGenerate)))
				X = pick(miningZ)
				LAGCHECK(LAG_REALTIME)

			var/list/solidTiles = list()
			var/list/edgeTiles = list(X)
			var/list/visited = list()

			var/sizeMod = rand(-AST_SIZERANGE,AST_SIZERANGE)

			while(edgeTiles.len)
				var/turf/curr = edgeTiles[1]
				edgeTiles.Remove(curr)

				if(curr in visited) continue
				else visited.Add(curr)

				var/turf/north = get_step(curr, NORTH)
				var/turf/east = get_step(curr, EAST)
				var/turf/south = get_step(curr, SOUTH)
				var/turf/west = get_step(curr, WEST)
				if(decideSolid(north, X, sizeMod))
					solidTiles.Add(north)
					edgeTiles.Add(north)
				if(decideSolid(east, X, sizeMod))
					solidTiles.Add(east)
					edgeTiles.Add(east)
				if(decideSolid(south, X, sizeMod))
					solidTiles.Add(south)
					edgeTiles.Add(south)
				if(decideSolid(west, X, sizeMod))
					solidTiles.Add(west)
					edgeTiles.Add(west)
				LAGCHECK(LAG_REALTIME)

			var/list/placed = list()
			for(var/turf/T in solidTiles)
				if((T?.loc?.type == /area/space) || istype(T?.loc , /area/allowGenerate))
					var/turf/wall/asteroid/AST = T.ReplaceWith(/turf/wall/asteroid)
					placed.Add(AST)
					//AST.quality = quality
				LAGCHECK(LAG_REALTIME)

			if(prob(15))
				Turfspawn_Asteroid_SeedOre(placed, rand(2,6), rand(0,40), TRUE)
			else
				Turfspawn_Asteroid_SeedOre(placed, spicy = TRUE)

			Turfspawn_Asteroid_SeedEvents(placed)

			if(placed.len)
				generated.Add(placed)
				if(placed.len > 9)
					seeds.Add(X)
					seeds[X] = placed
					var/list/holeList = list()
					for(var/k=0, k<AST_RNGWALKINST, k++)
						var/turf/T = pick(placed)
						for(var/j=0, j<rand(AST_RNGWALKCNT,round(AST_RNGWALKCNT*1.5)), j++)
							holeList.Add(T)
							T = get_step(T, pick(NORTH,EAST,SOUTH,WEST))
							if(!istype(T, /turf/wall/asteroid)) continue
							var/turf/wall/asteroid/ast = T
							ast.destroy_asteroid(0)

		//So I think it's kinda BS that the funkiest ores are magnet exclusive
		//but starstone is supposed to be very rare, so how about this:
		//We try n times picking turfs at random from the entire Z level, and if we happen to hit an unoccupied asteroid turf we plant a starstone
		//This relies on better-than-chance odds of dud turf picks. By my estimate the asteroid field is generally like 20-30% actual asteroid.
		for (var/i = 1, i <= 10 ,i++) //10 tries atm, which I think should give a decent chance no starstones spawn.
			var/turf/wall/asteroid/TRY = pick(miningZ)
			if (!istype(TRY))
				logTheThing("debug", null, null, "Starstone gen #[i] at [showCoords(TRY.x, TRY.y, TRY.z)] failed - no asteroid.")
				continue
			if (TRY.ore)
				logTheThing("debug", null, null, "Starstone gen #[i] at [showCoords(TRY.x, TRY.y, TRY.z)] failed - ore present.")
				continue
			//asteroid and unoccupied!
			Turfspawn_Asteroid_SeedSpecificOre(list(TRY),"starstone",1) //This probably makes a coder from 10 years ago cry
			logTheThing("debug", null, null, "Starstone gen #[i] at [showCoords(TRY.x, TRY.y, TRY.z)] success!")
		return miningZ
*/


/*
	Supposed to go in datum/admins/Topic under secretsadmin. FSR didn't find the spy market, despite copy pasting that line from else within that same Topic
					if("cycle_spy_thief")
						var/datum/game_mode/spy_theft/game = istype(ticker.mode, /datum/game_mode/spy_theft) ? ticker.mode : ticker.mode.spy_market
						game.spy_market.build_bounty_list()
						game.spy_market.update_bounty_readouts()
						logTheThing("admin", usr, null, "Forced a refresh of the spy-thief bounty list.")
						logTheThing("diary", usr, null, "Forced a refresh of the spy-thief bounty list.", "admin")
						message_admins("[key_name(usr)] forced a refresh of the spy-thief bounty list.")
						//hack to refresh the window
						Topic(null, list("action" = "secretsadmin", "type" = "check_antagonist"))
*/
