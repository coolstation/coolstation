//Hey I heard we're doing files like these

//flap flap gonna put cursed stuff here

/*TODO:
blob AI debug overlay doesn't realistically support more than one AI (but maybe that's fine?)
multi actionbar is scuffed, requires removing action/act interrupts when ideally we'd check to allow copies of the same id (also ditch /datum/action/bar/wall_decon_crud for generic)
figure out a report thingy for cargo shuttle to replace getting 6 PDA messages at once
*/

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
