
// LOOT TIER DEFINES -
// NOTE: you need at least 1 'small' (1x1) object' for every loot pool, to fall back on.
#define ILLICIT_LOOT_GUN 5 // gunse and weapons!!!
#define ILLICIT_LOOT_AMMO 4 // ammo - uses the "Ammo_Allowed" tag, falls back to ILLICIT_LOOT_GEAR if there is no gun
#define ILLICIT_LOOT_AMMO_LIMITED 3 // ammo, but keeps magazines per gun to 1~2 so you dont get 2 knives and 1 gun with 3+ mags
#define ILLICIT_LOOT_GEAR 2 // healing, cool stuff that stops you dying or helps you
#define GIMMICK 1 // fun stuff, can be helpful


/// Large storage object with lots of loot.
ABSTRACT_TYPE(/obj/storage/crate/illicit_crate)
/obj/storage/crate/illicit_crate
	name = "illicit crate"
	desc = "A surprisingly advanced crate, with an improvised cash register. Smells terrible..."
	is_short = TRUE
	locked = FALSE
	icon_state = "lootcrimegang"
	icon_closed = "lootcrimegang"
	icon_opened = "lootcrimeopengang"
	can_flip_bust = FALSE
	anchored = UNANCHORED
	autosorting = FALSE
	var/datum/loot_generator/lootMaster

	proc/initialize_loot_master(x,y)
		src.vis_controller = new(src)
		lootMaster = new /datum/loot_generator(x,y)

	// Default gang crate
	guns_and_gear
		New()
			initialize_loot_master(4,4)
			// 3 guns, ammo, 3 bits of gear
			lootMaster.add_random_loot(src, ILLICIT_LOOT_GUN, 3)
			lootMaster.add_random_loot(src, ILLICIT_LOOT_AMMO, 3)
			lootMaster.add_random_loot(src, ILLICIT_LOOT_GEAR, 3)
			// fill the rest with whatever
			lootMaster.fill_remaining(src, GIMMICK)
			..()
	guns_and_gear_visualized
		New()
			..()
			initialize_loot_master(4,4)
			src.open()
			// 3 guns, ammo, 3 bits of gear
			SPAWN_DBG(0)
				for (var/i=1 to 3)
					lootMaster.add_random_loot(src, ILLICIT_LOOT_GUN, 1)
					vis_controller.hide()
					vis_controller.show()
					sleep(1 SECOND)
				for (var/i=1 to 3)
					lootMaster.add_random_loot(src, ILLICIT_LOOT_AMMO, 1)
					vis_controller.hide()
					vis_controller.show()
					sleep(1 SECOND)
				for (var/i=1 to 3)
					lootMaster.add_random_loot(src, ILLICIT_LOOT_GEAR, 1)
					vis_controller.hide()
					vis_controller.show()
					sleep(1 SECOND)
				// fill the rest with whatever
				lootMaster.fill_remaining(src, GIMMICK)
				vis_controller.hide()
				vis_controller.show()
				sleep(1 SECOND)
	only_gimmicks
		New()
			initialize_loot_master(4,3)
			lootMaster.fill_remaining(src.loc, GIMMICK)
			..()
	only_guns
		New()
			initialize_loot_master(4,3)
			lootMaster.fill_remaining(src, ILLICIT_LOOT_GUN)
			..()
	only_gear
		New()
			initialize_loot_master(4,3)
			lootMaster.fill_remaining(src, ILLICIT_LOOT_GEAR)
			..()
	gear_and_gimmicks
		New()
			initialize_loot_master(4,3)
			lootMaster.add_random_loot(src, ILLICIT_LOOT_GEAR, 2)
			lootMaster.fill_remaining(src, GIMMICK)
			..()


/// Smaller, handheld loot bags.
ABSTRACT_TYPE(/obj/item/illicit_duffle)
/obj/item/illicit_duffle
	icon = 'icons/obj/items/storage.dmi'
	name = "duffle bag"
	desc = "A greasy, black duffle bag, reeking of pot."
	icon_state = "gang_dufflebag"
	item_state = "bowling"
	var/open = FALSE
	level = UNDERFLOOR

	///Items that haven't been removed from the bag. These will travel with it.
	var/datum/vis_storage_controller/vis_controller
	var/datum/loot_generator/lootMaster

	proc/initialize_loot_master(x,y)
		src.vis_controller = new(src)
		lootMaster = new /datum/loot_generator(x,y)

	only_gimmicks
		New()
			initialize_loot_master(3,2)
			lootMaster.fill_remaining(src, GIMMICK)
			..()

	gear_and_gimmicks
		New()
			initialize_loot_master(3,2)
			lootMaster.add_random_loot(src, ILLICIT_LOOT_GEAR, 2)
			lootMaster.fill_remaining(src, GIMMICK)
			..()

	guns_and_gear
		New()
			initialize_loot_master(3,2)
			lootMaster.add_random_loot(src, ILLICIT_LOOT_GUN, 1)
			lootMaster.add_random_loot(src, ILLICIT_LOOT_AMMO, 1)
			lootMaster.add_random_loot(src, ILLICIT_LOOT_GEAR, 2)
			lootMaster.fill_remaining(src, GIMMICK)
			..()

	/// Uses the boolean 'intact' value of the floor it's beneath to hide, if applicable
	hide(var/floor_intact)
		invisibility = floor_intact ? INVIS_ALWAYS : INVIS_NONE	// hide if floor is intact

	attack_self(mob/user)
		if (!open)
			src.open(user)
			playsound(src.loc, 'sound/misc/zipper.ogg', 100, TRUE)
			boutput(user, "You unzip the duffel bag!")
			user.drop_item(src)
			open = TRUE
			icon_state = "gang_dufflebag_open"
		else
			return ..()

	attack_hand(mob/user)
		if(src.open)
			src.close()
		. = ..()


	proc/open(mob/user)
		open = TRUE
		user.drop_item(src)
		vis_controller.show()

	proc/close()
		open = FALSE
		icon_state = "gang_dufflebag"
		vis_controller.hide()



// Handles the weighting and generation
/datum/loot_generator
	var/static/loot_x_pixels = 8 // how many pixels each grid square takes up
	var/static/loot_y_pixels = 8
	/// Whether loot weights have been generated yet.
	var/static/populated = FALSE
	/// The spawner associated with the X & Y Size. so spawners[1][2] is 1 wide, 2 tall
	var/static/list/spawners[4][2]
	/// Associative list, spawners to their childrens' total weight, as a number
	var/static/list/totalWeights[0][0]
	/// Associative list, spawners to their childrens individual weight, as a list
	var/static/list/weights[0][0][0]
	/// The loot grid (inventory grid) this generator is using
	var/datum/loot_grid/lootGrid
	/// List for passing information to spawners (for example, ammo spawners would need to know what guns this spawner made)
	var/tags[]   = new/list()
	/// ASsociative list of loot instances this generator created.
	var/list/spawned_instances[0]

	// LOOT GENERATING METHODS
	//
	// tier = the tier of generated loot, like ILLICIT_LOOT_GUN for gang guns.
	// x = horizontal position on lootGrid
	// y = vertical position on lootGrid
	// xSize = number of horizontal lootGrid tiles this uses
	// ySize = number of vertical lootGrid tiles this uses
	// invisible = mark as TRUE to skip marking the loot grid as used

	/// Add multiple random loot objects. bottom left to top right. this looks gross in practise and prioritises just making large high-ticket items
	proc/add_random_loot_sequential(loc,tier, quantity=1, invisible=FALSE)
		for (var/i=1 to quantity)
			var/pos = lootGrid.get_next_empty_space()
			if (!pos) break
			var/maxSize = lootGrid.get_largest_space(pos[1],pos[2])
			var/lootSize = choose_random_loot_size(maxSize[1],maxSize[2],tier)
			var/override = place_random_loot_sized(loc, pos[1],pos[2],lootSize[1],lootSize[2],tier, invisible)
			if (!invisible && !override)
				lootGrid.mark_used(pos[1],pos[2],lootSize[1],lootSize[2])

	/// Add multiple random loot objects, in random positions
	proc/add_random_loot(loc,tier, quantity=1, invisible=FALSE)
		for (var/i=1 to quantity)
			var/pos = lootGrid.get_random_empty_space()
			if (!pos) break
			var/maxSize = lootGrid.get_largest_space(pos[1],pos[2])
			var/lootSize = choose_random_loot_size(maxSize[1],maxSize[2],tier)
			var/override = place_random_loot_sized(loc, pos[1],pos[2],lootSize[1],lootSize[2],tier, invisible)
			if (!invisible && !override)
				lootGrid.mark_used(pos[1],pos[2],lootSize[1],lootSize[2])



	/// Place a random loot instance at a specific position
	proc/place_random_loot(loc,x,y,tier, invisible=FALSE)
		var/maxSize = lootGrid.get_largest_space(x,y)
		var/lootSize = choose_random_loot_size(maxSize[1],maxSize[2],tier)
		place_random_loot_sized(loc, x,y,lootSize[1],lootSize[2],tier, invisible)

	/// Fills all remaining space with instances of random size
	proc/fill_remaining(loc, tier)
		var/done = FALSE
		var/spawnedLootInstances = list()
		var/pos = new/list(2)
		pos[1] = 1
		pos[2] = 1
		while (!done)
			pos = lootGrid.get_next_empty_space(pos[1],pos[2])
			if (!pos) break
			var/maxSize = lootGrid.get_largest_space(pos[1],pos[2])
			var/lootSize = choose_random_loot_size(maxSize[1],maxSize[2],tier)
			place_random_loot_sized(loc, pos[1],pos[2],lootSize[1],lootSize[2],tier)

		return spawnedLootInstances

	/// place a loot object that's been created externally
	proc/place_loot_instance(loc, x,y,obj/loot_spawner/loot, invisible)
		var/override = add_loot_instance(loc,loot,x,y)
		if (!invisible && !override)
			lootGrid.mark_used(x,y,loot.xSize,loot.ySize)


	/// Fills all remaining space with as many instances as possible of a loot object that's been created externally
	/// Ignores override, due to infinite loop.
	proc/fill_remaining_with_instance(loc, obj/loot_spawner/loot)
		var/done = FALSE
		var/pos = new/list(2)
		pos[1] = 1
		pos[2] = 1
		while (!done)
			pos = lootGrid.get_next_empty_space(pos[1],pos[2])
			if (!pos) break
			var/maxSize = lootGrid.get_largest_space(pos[1],pos[2])
			if (maxSize[1] < loot.xSize)
				pos[2]++
			else
				add_loot_instance(loc,loot,pos[1],pos[2])
				lootGrid.mark_used(pos[1],pos[2],loot.xSize,loot.ySize)


	/// Place a random loot instance of a specific size at a specific position
	proc/place_random_loot_sized(loc, xPos,yPos,sizeX,sizeY, tier, invisible = FALSE)
		var/chosenType = pick_weighted_option(sizeX,sizeY,tier)
		var/obj/new_spawner = new chosenType
		var/override = add_loot_instance(loc,new_spawner,xPos,yPos)
		if (!override && !invisible)
			lootGrid.mark_used(xPos,yPos,sizeX,sizeY)
		return override

	// INTERNAL LOOT GENERATION

	New(xSize, ySize)
		if (!populated)
			populate()
		lootGrid = new/datum/loot_grid(xSize, ySize)
		..()

	/// Initialize spawners & weights for all random loot spawners
	proc/populate()
		// setting these manually to map class names to sizes
		// this avoids having to instantiate them just to read their xSize & ySize
		spawners[1][1] = /obj/loot_spawner/random/short
		spawners[2][1] = /obj/loot_spawner/random/medium
		spawners[3][1] = /obj/loot_spawner/random/long
		spawners[4][1] = /obj/loot_spawner/random/xlong
		spawners[1][2] = /obj/loot_spawner/random/short_tall
		spawners[2][2] = /obj/loot_spawner/random/medium_tall
		spawners[3][2] = /obj/loot_spawner/random/long_tall
		spawners[4][2] = /obj/loot_spawner/random/xlong_tall

		// determine the total weight of all our spawners
		for(var/spawnersByLength in spawners)
			for(var/spawner in spawnersByLength)
				totalWeights[spawner] = new/list(0)
				weights[spawner] = new/list(0)
				var/childtypes = concrete_typesof(spawner)

				for(var/childType in childtypes)
					var/obj/loot_spawner/random/item = new childType()
					if (length(totalWeights[spawner]) < item.tier)
						totalWeights[spawner].len = item.tier
						weights[spawner].len = item.tier

					if (!totalWeights[spawner][item.tier])
						totalWeights[spawner][item.tier] = 0
						weights[spawner][item.tier] = new/list(0)

					totalWeights[spawner][item.tier] += item.weight
					weights[spawner][item.tier][childType] = item.weight

		populated = TRUE

	/// use predefined weights pick a spawner of size xSize, ySize, in chosenTIer
	proc/pick_weighted_option(xSize, ySize, var/chosenTier)
		var/spawnerBase = spawners[xSize][ySize]
		var/roll = rand(1, totalWeights[spawnerBase][chosenTier])
		for (var/item in weights[spawnerBase][chosenTier])
			roll = roll - weights[spawnerBase][chosenTier][item]
			if (roll <= 0)
				return item

	/// Chooses the size of loot to spawn, given a max and min.
	proc/choose_random_loot_size(largestX,largestY,tier)
		var/desiredX  = 1
		var/desiredY  = 1
		//scaling prob for each X size of loot
		while (length(spawners) > desiredX && desiredX < largestX && prob(90-(20*desiredX)))
			desiredX++
		// 40% to make it 2 tiles tall
		while (length(spawners[1]) > desiredY && desiredY < largestY && prob(40))
			desiredY++

		// select the largest valid crate (proritizing X size)
		for (var/xTest = 1 to desiredX)
			for (var/yTest = 1 to desiredY)
				var/obj/loot_spawner/random/chosenSpawner = spawners[1+desiredX-xTest][1+desiredY-yTest]
				if (totalWeights[chosenSpawner][tier])
					var/size = list(1+desiredX-xTest,1+desiredY-yTest)
					return size

	/// creates a loot object and offset info
	proc/add_loot_instance(loc,obj/loot_spawner/instance,xPos,yPos)
		src.spawned_instances += instance
		var/datum/loot_spawner_info/info = new /datum/loot_spawner_info()
		info.parent = src
		info.grid_x = loot_x_pixels
		info.grid_y = loot_y_pixels
		info.position_x = xPos
		info.position_y = yPos
		info.layer = 3+(lootGrid.size_y-yPos)
		info.tags = src.tags
		return instance.handle_loot(loc,info)

	/// Adds an entry to a list in this spawner's tags.
	proc/tag_list(name, value)
		if (!(name in tags))
			tags[name] = new/list()
		tags[name] += value

	/// set the value of this spawner's tag.
	proc/tag_single(name, value)
		tags[name] = value

/// data class representing a grid of goodies (like an inventory grid in RE4).
/datum/loot_grid
	var/list/grid[][]
	var/size_x
	var/size_y

	New(xSize, ySize)
		set_size(xSize,ySize)
		..()

	/// Sets the size of this grid, resetting it in the process.
	proc/set_size(xSize,ySize)
		size_x = xSize
		size_y = ySize
		grid = new/list(size_x,size_y)

	/// Return the coordinates of a random empty grid square
	proc/get_random_empty_space()
		// start at a random X, Y position
		var/pos = new/list(2)
		pos[1] = rand(1,size_x)
		pos[2] = rand(1,size_y)

		// now we loop over every possible X and Y pos, but starting at an offset
		for (var/y_iter=1 to size_y)
			pos[2] = (pos[2]+1)
			if (pos[2] > size_y)
				pos[2] = 1
			for (var/x_iter=1 to size_x)
				pos[1] = (pos[1]+1)
				if (pos[1] > size_x)
					pos[1] = 1
				if (!grid[pos[1]][pos[2]])
					return pos
		return null

	/// Return the coordinates of the next empty grid square from pos_x, pos_y. Fills out one row before moving up.
	proc/get_next_empty_space(pos_x = 1, pos_y = 1)
		var/pos = new/list(2)
		for (var/y_iter=pos_y to size_y)
			for (var/x_iter=pos_x to size_x)
				if (!grid[x_iter][y_iter])
					pos[1] = x_iter
					pos[2] = y_iter
					return pos
			pos_x = 1
		return FALSE

	/// Marks an area of size xSize, ySize as used, starting at xPos, yPos
	proc/mark_used(xPos,yPos,xSize,ySize)
		for (var/x=1 to xSize)
			for (var/y=1 to ySize)
				grid[xPos-1+x][yPos+y-1] = 1

	/// Returns if coordinate x, y is empty
	proc/is_empty(x,y)
		return grid[x][y]

	/// Returns the largest empty rectangle possible, prioritising length rather than area.
	proc/get_largest_space(startX,startY)
		var/size = list(1,1)
		while (startX+size[1]-1 < size_x && !grid[startX+size[1]][startY])
			size[1]++

		var/nextYOccupied = FALSE
		while (!nextYOccupied)
			if ((startY+size[2]) <= size_y) // if we aren't at the bottom row of loot already
				for (var/x=1 to size[1]) // check every X position on the next row down
					if (grid[startX+x-1][startY+size[2]])
						nextYOccupied = TRUE
						break
				if (!nextYOccupied)
					size[2]++
			else
				nextYOccupied = TRUE

		return size


/// Contains positional info and tags to pass to loot spawners, so they can spawn items in the right spot.
/datum/loot_spawner_info
	var/grid_x = 8 		//! how wide a grid square is, in pixels
	var/grid_y = 8		//! how tall a grid square is, in pixels
	var/position_x = 0 	//! The horizontal position, in grid squares, that the spawner should use as its' origin
	var/position_y = 0  //! The vertical position, in grid squares, that the spawner should use as its' origin
	var/layer    = 0 //! The layer the spawner should use
	var/datum/loot_generator/parent //! The loot generator that created this spawner. Used to modify tags if necessary.
	var/tags[] //! The tags that the loot generator currently has. Such as what ammunition types spawned guns use



// You can uncomment this tool to help build item layouts for spawning.
// Use in-hand to set the position arguments, hit an item to see what it'd look like
// By default, each x&y coordinate is roughly 8x8 pixels, so a 2x1 item should take up 16x8 pixels (or 32x16 in 64x64 tilesize etc.)

/obj/item/device/item_placer
	name = "Item transformation viewer"
	icon_state = "multitool"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	w_class = W_CLASS_SMALL
	var/off_x = 0
	var/off_y = 0
	var/rot = 0
	var/scale_x = 1
	var/scale_y = 1
	desc = ""
	attack_self(var/mob/user as mob)

		off_x = input(usr, "Offset X", "OffX", off_x) as null|num
		off_y = input(usr, "Offset Y", "OffY", off_y) as null|num
		rot = input(usr, "Rotation", "Rot", rot) as null|num
		scale_x = input(usr, "Scale X", "ScaleX", scale_x) as null|num
		scale_y = input(usr, "Scale Y", "ScaleY", scale_y) as null|num

	afterattack(atom/target,mob/user as mob)
		if(istype(target, /obj))
			var/obj/object = target
			object.transform = matrix()
			object.transform = object.transform.Scale(scale_x,scale_y)
			object.transform = object.transform.Turn(rot)
			object.pixel_x = off_x
			object.pixel_y = off_y
			object.AddComponent(/datum/component/reset_transform_on_pickup)






// LOOT SPAWNERS
//
// The non-random base exists for loot you don't want to put in a random pool.
// In addition, the loot_spawner/specified child allows for definition of an item and size in New(), useful for live use.

ABSTRACT_TYPE(/obj/loot_spawner)
/obj/loot_spawner
	icon = 'icons/obj/items/items.dmi'
	icon_state = "gift2-r"

	var/xSize = 1 //! The width of this spawner
	var/ySize = 1 //! The height of this spawner

	// for testing, or if you want to spawn these into the world for whatever reason
	attack_hand(mob/user as mob)
		var/I = new/datum/loot_spawner_info()
		src.spawn_loot(get_turf(user),I)
		qdel(src)

	// spawn_item(C,I,off_x,off_y,rot,scale_x,scale_y,layer_offset)
	// C = Container
	// I = The spawner info, containing where to spawn this, and tags.
	//
	// Optional positioning arguments:
	// off_x/off_y = Offset of the icon (in pixels)
	// rot = Rotation of the icon
	// scale_x/scale_y = Scale of icon
	// layer_offset = overall offset of layers
	//
	/// spawn a given item with the 'transform on pickup' component. Refer to function definition for better docs.
	proc/spawn_item(loc,datum/loot_spawner_info/I,path,off_x=0,off_y=0, rot=0, scale_x=1,scale_y=1, layer_offset=0)
		var/obj/lootObject
		if (istype(loc, /obj/storage/crate))
			var/obj/storage/container = loc
			lootObject = new path(container)
			container.vis_controller.add_item(lootObject)
		else if (istype(loc, /obj/item/illicit_duffle))
			var/obj/item/illicit_duffle/loot = loc
			lootObject = new path(loot)
			loot.vis_controller.add_item(lootObject)
		else
			lootObject = new path(loc)
		lootObject.transform = lootObject.transform.Scale(scale_x,scale_y)
		lootObject.transform = lootObject.transform.Turn(rot)

		lootObject.pixel_x = I.grid_x * ((I.position_x + xSize/2-1)-I.parent?.lootGrid?.size_x/2) + off_x
		lootObject.pixel_y = I.grid_y * ((I.position_y + ySize/2-1)-I.parent?.lootGrid?.size_y/2) + off_y
		lootObject.layer = I.layer + layer_offset
		lootObject.AddComponent(/datum/component/reset_transform_on_pickup)
		return lootObject

	/// Calls spawn_loot, then handles disappearing & overrides
	proc/handle_loot(loc,datum/loot_spawner_info/I)
		var/override = spawn_loot(loc,I)
		qdel(src)
		return override

	/// Spawn the loot for this instance. Return TRUE if this should not take up grid squares.
	proc/spawn_loot(loc,datum/loot_spawner_info/I)

ABSTRACT_TYPE(/obj/loot_spawner/short)
/obj/loot_spawner/short //1x1
	xSize = 1
	ySize = 1

	two_sarin_grenades
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/chem_grenade/sarin,off_y=2,scale_x=0.825,scale_y=0.65)
			spawn_item(C,I,/obj/item/chem_grenade/sarin,off_y=-2,scale_x=0.825,scale_y=0.65)

// The random loot master checks all definitions of loot_spawner/random when it's first created.
// To define new random loot, simply create a new child of the appropriate size and tier, and it will be automatically picked up.
// Uncomment the above item_placer if you'd like to scale the items spawned by this.

ABSTRACT_TYPE(/obj/loot_spawner/random)
/obj/loot_spawner/random
	var/tier = GIMMICK	//! what tier must be selected to select this spawner.
	var/weight = 3		//! the weight this spawner has to be selected in its' tier, defaults to 3.

	/// generic booze loot pool
	var/static/booze_items = list(
		/obj/item/reagent_containers/food/drinks/bottle/beer,
		/obj/item/reagent_containers/food/drinks/bottle/wine,
		/obj/item/reagent_containers/food/drinks/bottle/mead,
		/obj/item/reagent_containers/food/drinks/bottle/cider,
		/obj/item/reagent_containers/food/drinks/bottle/rum,
		/obj/item/reagent_containers/food/drinks/bottle/vodka,
		/obj/item/reagent_containers/food/drinks/bottle/tequila,
		/obj/item/reagent_containers/food/drinks/bottle/bojackson,
		/obj/item/reagent_containers/food/drinks/curacao
	)
	/// generic drug loot pool
	var/static/drug_items = list(
		/obj/item/storage/pill_bottle/methamphetamine,
		/obj/item/storage/pill_bottle/crank,
		/obj/item/storage/pill_bottle/bathsalts,
		/obj/item/storage/pill_bottle/catdrugs,
		/obj/item/storage/pill_bottle/cyberpunk,
		/obj/item/storage/pill_bottle/epinephrine
	)
	/// uncommon, valuable drugs, for placement in syringes
	var/static/strong_stims = list("enriched_msg", "triplemeth", "glowing_fliptonium", "cocktail_triple", "energydrink", "grog", "bathsalts", "UGHFCS", "madness_toxin", "strychnine")
	var/static/crime_prefixes = list("triple-filtered", "dubious", "illegal", "rank", "suspicious", "shady", "illicit", "street", "back-alley", "hustler", "laced", "evil", "dogmatic", "uncut", "ontological")

ABSTRACT_TYPE(/obj/loot_spawner/random/short)
/obj/loot_spawner/random/short //1x1
	xSize = 1
	ySize = 1

	ammo
		tier = ILLICIT_LOOT_AMMO
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			if ("Ammo_Allowed" in I.tags)
				// Otherwise, make ammo modifications
				var/ammoSelected = pick(I.tags["Ammo_Allowed"])
				spawn_item(C,I,ammoSelected,scale_x=0.6,scale_y=0.6)
			else
				I.parent.place_random_loot_sized(C, I.position_x, I.position_y, 1, 1, ILLICIT_LOOT_GEAR)
				return TRUE // override this

		limited
			tier = ILLICIT_LOOT_AMMO_LIMITED
			// AMMO_LIMITED limits the amount of ammo spawned to 'the amount of guns, plus a 50% chance for a bonus mag'
			// So, if there's 1 gun, there's a 50% chance for 2 mags, 50% for one mag
			// For 2 guns, there's a 50% chance for 3 mags, 50% for 2 mags.
			// any AMMO_LIMITED that spawns thereafter will instead spawn a 1x1 GEAR item.
			spawn_loot(var/C, datum/loot_spawner_info/I)
				var/ammoSpawned = 0
				if (I.tags["Ammo_Spawned"])
					ammoSpawned = I.tags["Ammo_Spawned"] + 1
					I.parent.tag_single("Ammo_Spawned", I.tags["Ammo_Spawned"] + 1)
				else
					ammoSpawned = 1
					I.parent.tag_single("Ammo_Spawned", 1)

				var/skipAmmo = (ammoSpawned-length(I.tags["Ammo_Allowed"]))*50
				// If we've got more ammo than guns, roll gear instead
				if (prob(skipAmmo))
					I.parent.place_random_loot_sized(C, I.position_x, I.position_y, 1, 1, ILLICIT_LOOT_GEAR)
					return TRUE // override this spawn
				. = ..()

	// ILLICIT_LOOT_GUN:
	tiny_italian_revolver
		tier = ILLICIT_LOOT_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/gun/modular/italian/revolver/basic,scale_x=0.65,scale_y=0.65)
			I.parent?.tag_list("Ammo_Allowed", /obj/item/stackable_ammo/pistol/italian/five)
	small_nades
		weight=2
		tier = ILLICIT_LOOT_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/old_grenade/stinger/frag,off_y=0,scale_x=0.6,scale_y=0.6)
			spawn_item(C,I,/obj/item/old_grenade/stinger/frag,off_y=0,scale_x=0.6,scale_y=0.6)
			spawn_item(C,I,/obj/item/old_grenade/stinger/frag,off_y=0,scale_x=0.6,scale_y=0.6)

	// ILLICIT_LOOT_GEAR
	spraypaint
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/spray_paint,scale_x=0.6,scale_y=0.45,off_x=-2)
			spawn_item(C,I,/obj/item/spray_paint,scale_x=0.6,scale_y=0.45)
			spawn_item(C,I,/obj/item/spray_paint,scale_x=0.6,scale_y=0.45,off_x=2)
	flash
		weight = 1 // it sucks getting more than 1 of these
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/device/flash,off_x=2,off_y=0,rot=0,scale_x=0.6,scale_y=0.6)
			spawn_item(C,I,/obj/item/device/flash,off_x=-2,off_y=0,rot=0,scale_x=0.6,scale_y=0.6)
	flashbang
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_y=2,scale_x=0.825,scale_y=0.65)
			spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_y=-2,scale_x=0.825,scale_y=0.65)
	donk
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donkpocket_w,scale_x=0.75,scale_y=0.75)
	crank
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/storage/pill_bottle/crank,scale_x=0.75,scale_y=0.75)
	meth
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/storage/pill_bottle/methamphetamine,scale_x=0.75,scale_y=0.75)
	//quickhacks
	//	weight = 1
	//	tier = ILLICIT_LOOT_GEAR
	//	spawn_loot(var/C,var/datum/loot_spawner_info/I)
	//		spawn_item(C,I,/obj/item/tool/quickhack,scale_x=0.6, scale_y = 0.6)


	// GIMMICKS
	jaffacakes
		tier = GIMMICK
		weight=5
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			for(var/i=1 to 4)
				var/obj/item/cake = spawn_item(C,I,/obj/item/reagent_containers/food/snacks/cookie/jaffa,off_y=2*(2-i),scale_x=0.7,scale_y=0.85)
				cake.name_prefix(pick(src.crime_prefixes))
				cake.reagents.add_reagent("omnizine", 5)
				cake.reagents.add_reagent("msg", 1) // make em taste different
				cake.UpdateName()
	weed
		weight=5
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,off_y=2,scale_x = 0.6,scale_y = 0.6)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,scale_x = 0.6,scale_y = 0.6)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,off_y=-2,scale_x = 0.6,scale_y = 0.6)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,off_y=-4,scale_x = 0.6,scale_y = 0.6)
	whiteweed
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/white/spawnable,off_y=2,scale_x = 0.6,scale_y = 0.6)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/white/spawnable,scale_x = 0.6,scale_y = 0.6)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/white/spawnable,off_y=-2,scale_x = 0.6,scale_y = 0.6)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/white/spawnable,off_y=-4,scale_x = 0.6,scale_y = 0.6)
	omegaweed
		weight=2
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,off_y=2,scale_x = 0.6,scale_y = 0.6)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/omega/spawnable,scale_x = 0.6,scale_y = 0.6)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,off_y=-2,scale_x = 0.6,scale_y = 0.6)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,off_y=-4,scale_x = 0.6,scale_y = 0.6)

	goldzippo
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/device/light/zippo/gold,scale_x=0.85,scale_y=0.85)
	rillo
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/cigpacket/cigarillo,off_x=-2,scale_y=0.8)
			spawn_item(C,I,/obj/item/cigpacket/cigarillo,off_x=2,scale_y=0.8)
	juicerillo
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/cigpacket/cigarillo/juicer,off_x=-2,scale_y=0.8)
			spawn_item(C,I,/obj/item/cigpacket/cigarillo/juicer,off_x=2,scale_y=0.8)
	drugs
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,pick(drug_items),scale_x=0.75,scale_y=0.75)

ABSTRACT_TYPE(/obj/loot_spawner/random/medium)
/obj/loot_spawner/random/medium //2x1
	xSize = 2
	ySize = 1

	// ILLICIT_LOOT_GUN:
	italian_revolver
		weight = 5
		tier = ILLICIT_LOOT_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			if(prob(65))
				spawn_item(C,I,/obj/item/gun/modular/italian/revolver/italiano,scale_x=0.65,scale_y=0.65)
			else
				spawn_item(C,I,/obj/item/gun/modular/italian/revolver/big_italiano,scale_x=0.65,scale_y=0.65)
			I.parent?.tag_list("Ammo_Allowed", /obj/item/stackable_ammo/pistol/italian/ten)

	throwingknife
		tier = ILLICIT_LOOT_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/dagger/throwing_knife,rot=45,scale_x=0.55,scale_y=0.55)

	switchblade
		tier = ILLICIT_LOOT_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/switchblade,rot=45,scale_x=0.75,scale_y=0.75)

	// ILLICIT_LOOT_GEAR
	pouch
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/storage/pouch,scale_x=0.65,scale_y=0.65)
	amphetamines
		weight = 3
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			for(var/i=1 to 3)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,rot=45,off_y=3-(2*i),scale_x=0.75,scale_y=0.75)
	robust_donuts
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donut/custom/robust,scale_x=0.6,scale_y=0.6,rot=90,off_x=-6)
			spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donut/custom/robust,scale_x=0.6,scale_y=0.6,rot=90,off_x=-2)
			spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donut/custom/robusted,scale_x=0.6,scale_y=0.6,rot=90,off_x=2)
			spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donut/custom/robusted,scale_x=0.6,scale_y=0.6,rot=90,off_x=6)
	moneythousand
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/spacecash/thousand,off_y=2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/thousand,off_y=0,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/thousand,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
	stims_syringe
		tier = ILLICIT_LOOT_GEAR
		weight=1
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			for(var/i=1 to 3)
				var/obj/item/syringe = spawn_item(C,I,/obj/item/reagent_containers/syringe,off_y=6-3*i,rot=(i*180%360)+45,scale_x=0.7,scale_y=0.7)
				var/stim = pick(strong_stims)
				syringe.name_prefix(pick(src.crime_prefixes))
				syringe.reagents.add_reagent(stim, 10)
				syringe.reagents.add_reagent("bonerjuice", rand(0,4))
				syringe.reagents.add_reagent("grime", 5) // fill remaining space
				syringe.name_suffix("([syringe.reagents.get_master_reagent_name()])")
				syringe.UpdateName()

	// GIMMICKS
	utility_belt
		weight = 1
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/storage/belt/utility/prepared,off_y=1)
			spawn_item(C,I,/obj/item/storage/belt/utility/prepared,off_y=-1)
	money
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_y=2,scale_x=0.825,scale_y=0.825, layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_y=0,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
	moneythousand
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/spacecash/thousand,off_y=2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/thousand,off_y=0,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/thousand,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)

	drugs_syringe
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/reagent_containers/syringe/krokodil,off_y=3,rot=45,scale_x=0.7,scale_y=0.7)
			spawn_item(C,I,/obj/item/reagent_containers/syringe/krokodil,rot=45,scale_x=0.7,scale_y=0.7)
			spawn_item(C,I,/obj/item/reagent_containers/syringe/krokodil,off_y=-3,rot=45,scale_x=0.7,scale_y=0.7)
	syndieomnitool
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/tool/omnitool/syndicate,scale_y=0.75,rot=90)

	cigar
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			for(var/i=1 to 3)
				var/obj/item/cig = spawn_item(C,I,/obj/item/clothing/mask/cigarette/cigar,off_y=3*(2-i))
				cig.name_prefix(pick(src.crime_prefixes))
				cig.reagents.add_reagent("salicylic_acid", 5)
				cig.reagents.add_reagent("CBD", 5)
				cig.UpdateName()

	goldcigar
		weight = 2
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			for(var/i=1 to 3)
				var/obj/item/cig = spawn_item(C,I,/obj/item/clothing/mask/cigarette/cigar/gold,off_y=3*(2-i))
				cig.name_prefix(pick(src.crime_prefixes))
				cig.reagents.add_reagent("salicylic_acid", 5)
				cig.reagents.add_reagent("THC", 5)
				cig.UpdateName()

	drug_injectors
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/random,off_y=4,rot=45,scale_x=0.75,scale_y=0.75)
			spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/random,off_y=0,rot=45,scale_x=0.75,scale_y=0.75)
			spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/random,off_y=-4,rot=45,scale_x=0.75,scale_y=0.75)


ABSTRACT_TYPE(/obj/loot_spawner/random/long)
/obj/loot_spawner/random/long //3x1
	xSize = 3
	ySize = 1

	// ILLICIT_LOOT_GUN
	italian_rattler
		weight = 15
		tier = ILLICIT_LOOT_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			if(prob(50))
				spawn_item(C,I,/obj/item/gun/modular/italian/rattler/basic,off_x=-8,off_y=1,scale_x=0.6,scale_y=0.8)
			else if(prob(60))
				spawn_item(C,I,/obj/item/gun/modular/italian/rattler/improved,off_x=-8,off_y=1,scale_x=0.6,scale_y=0.8)
			else
				spawn_item(C,I,/obj/item/gun/modular/italian/rattler/saucy,off_x=-8,off_y=1,scale_x=0.6,scale_y=0.8)
			I.parent?.tag_list("Ammo_Allowed", /obj/item/stackable_ammo/pistol/italian/ten)

	switchblades
		tier = ILLICIT_LOOT_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/switchblade,rot=45,off_x=-5,scale_x=0.75,scale_y=0.75)
			spawn_item(C,I,/obj/item/switchblade,rot=225,off_x=5,scale_x=0.75,scale_y=0.75)

	// ILLICIT_LOOT_GEAR
	weldinghelmets
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/clothing/head/helmet/welding,off_x=-8,off_y=-1,rot=90,scale_x=0.75,scale_y=0.825)
			spawn_item(C,I,/obj/item/clothing/head/helmet/welding,off_x=8,off_y=2,rot=270,scale_x=0.75,scale_y=0.825)




	// GIMMICKS
	money_big
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/spacecash/thousand,off_x=4,off_y=2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/thousand,off_x=4,off_y=0,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/thousand,off_x=4,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/spacecash/thousand,off_x=-4,off_y=2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/thousand,off_x=-4,off_y=0,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/thousand,off_x=-4,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
	money
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=2,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=0,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=0,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)

ABSTRACT_TYPE(/obj/loot_spawner/random/xlong)
/obj/loot_spawner/random/xlong //4x1:// these are rare finds
	xSize = 4
	ySize = 1
	// ILLICIT_LOOT_GUN
	italian_rattler
		weight = 15
		tier = ILLICIT_LOOT_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			if(prob(50))
				spawn_item(C,I,/obj/item/gun/modular/italian/rattler/basic,off_x=-8,off_y=1,scale_x=0.6,scale_y=0.8)
			else if(prob(60))
				spawn_item(C,I,/obj/item/gun/modular/italian/rattler/improved,off_x=-8,off_y=1,scale_x=0.6,scale_y=0.8)
			else
				spawn_item(C,I,/obj/item/gun/modular/italian/rattler/saucy,off_x=-8,off_y=1,scale_x=0.6,scale_y=0.8)
			I.parent?.tag_list("Ammo_Allowed", /obj/item/stackable_ammo/pistol/italian/ten)

	// GIMMICKS
	money_big
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/spacecash/thousand,off_x=4,off_y=2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/thousand,off_x=4,off_y=0,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/thousand,off_x=4,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/spacecash/thousand,off_x=-4,off_y=2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/thousand,off_x=-4,off_y=0,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/thousand,off_x=-4,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)

ABSTRACT_TYPE(/obj/loot_spawner/random/short_tall)
/obj/loot_spawner/random/short_tall //1x2
	xSize = 1
	ySize = 2
	// good for tall items, like booze

	// ILLICIT_LOOT_GUN
	frags
		tier = ILLICIT_LOOT_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,	/obj/item/old_grenade/stinger/frag,off_y=5,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,	/obj/item/old_grenade/stinger/frag,off_y=5,scale_x=0.8,scale_y=0.8)

	// ILLICIT_LOOT_GEAR
	robusttecs
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/implantcase/robust,off_x=-2,off_y= 2,rot=0,scale_x=0.6,scale_y=0.8)
			spawn_item(C,I,/obj/item/implantcase/robust,off_x=-2,off_y=-2,rot=0,scale_x=0.6,scale_y=0.8)
			spawn_item(C,I,/obj/item/implanter,off_x=3,off_y=0,rot=45,scale_x=0.6,scale_y=0.6)
	syndieomnitool
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/tool/omnitool/syndicate,scale_y=0.75)
	autos
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,off_x=-2,rot=135,scale_x=0.75,scale_y=0.75)
			spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,off_x=0,rot=135,scale_x=0.75,scale_y=0.75)
			spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,off_x=2,rot=135,scale_x=0.75,scale_y=0.75)
	edrink
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/reagent_containers/food/drinks/energyshake,off_x=1,scale_y=0.8)
			spawn_item(C,I,/obj/item/reagent_containers/food/drinks/energyshake,off_x=-1,scale_y=0.8)
	patches
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/item_box/medical_patches/mini_synthflesh,scale_x=0.6,scale_y=0.8)


	// GIMMICKS
	bong
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,/obj/item/reagent_containers/glass/water_pipe,scale_x=0.8,scale_y=0.8)
	booze
		weight=6
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,pick(booze_items),off_x=-2,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,pick(booze_items),scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,pick(booze_items),off_x=2,scale_x=0.825,scale_y=0.825)
	airhorn
		weight=1
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/instrument/bikehorn/airhorn,scale_x=0.825,scale_y=0.825)

ABSTRACT_TYPE(/obj/loot_spawner/random/medium_tall)
/obj/loot_spawner/random/medium_tall //2x2
	xSize = 2
	ySize = 2

	// ILLICIT_LOOT_GUN
	italian_revolver
		tier = ILLICIT_LOOT_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			if(prob(60))
				spawn_item(C,I,/obj/item/gun/modular/italian/revolver/italiano,off_x=-8,off_y=1,scale_x=0.825,scale_y=0.825)
			else
				spawn_item(C,I,/obj/item/gun/modular/italian/revolver/big_italiano,off_x=-8,off_y=1,scale_x=0.825,scale_y=0.825)
			I.parent?.tag_list("Ammo_Allowed", /obj/item/stackable_ammo/pistol/italian/ten)
	beartraps
		tier = ILLICIT_LOOT_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,	/obj/item/beartrap,off_x=-4,off_y=-5,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,	/obj/item/beartrap,off_x=-3,off_y=3,scale_x=0.8,scale_y=0.8)

	// ILLICIT_LOOT_GEAR
	gold
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/material_piece/gold,off_x=-4)
			spawn_item(C,I,/obj/item/material_piece/gold)
			spawn_item(C,I,/obj/item/material_piece/gold,off_x=4)
	mixed_sec
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=-4,off_y=4)
			spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=4,off_y=4)
			spawn_item(C,I,/obj/item/chem_grenade/cryo,off_x=-4,off_y=-4,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,/obj/item/chem_grenade/shock,off_x=4,off_y=-4,scale_x=0.8,scale_y=0.8)
	helmet
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			var/helmet = pick(filtered_concrete_typesof(/obj/item/clothing/head/helmet, /proc/filter_trait_hats))
			spawn_item(C,I,helmet,off_y=-2,scale_x=0.7,scale_y=0.7)
			spawn_item(C,I,helmet,off_y=0,scale_x=0.7,scale_y=0.7)
			spawn_item(C,I,helmet,off_y=2,scale_x=0.7,scale_y=0.7)

	galoshes
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/clothing/shoes/galoshes,off_y=2)
			spawn_item(C,I,/obj/item/clothing/shoes/galoshes,off_y=-2)

	// LOW VALUE: Gimmicks

	booze
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,pick(booze_items),off_x=-2)
			spawn_item(C,I,pick(booze_items))
			spawn_item(C,I,pick(booze_items),off_x=2)

	hat
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head, /proc/filter_trait_hats)),off_y=-2,scale_x=0.7,scale_y=0.7)
			spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head, /proc/filter_trait_hats)),off_y=0,scale_x=0.7,scale_y=0.7)
			spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head, /proc/filter_trait_hats)),off_y=2,scale_x=0.7,scale_y=0.7)
	medkits
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/storage/firstaid/crit,off_y=2)
			spawn_item(C,I,/obj/item/storage/firstaid/regular,off_y=0)
			spawn_item(C,I,/obj/item/storage/firstaid/toxin,off_y=-2)
	gasmasks
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/clothing/mask/gas,off_y=2)
			spawn_item(C,I,/obj/item/clothing/mask/gas,off_y=0)
			spawn_item(C,I,/obj/item/clothing/mask/gas,off_y=-2)

	money
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=4,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=2,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=0,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=4,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=2,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=0,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=-4,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=-6,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=-4,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=-6,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)

ABSTRACT_TYPE(/obj/loot_spawner/random/long_tall)
/obj/loot_spawner/random/long_tall //3x2
	xSize = 3
	ySize = 2

	// ILLICIT_LOOT_GUN
	italian_rattler
		tier = ILLICIT_LOOT_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			if(prob(80))
				spawn_item(C,I,/obj/item/gun/modular/italian/rattler/improved,off_x=-8,off_y=1,scale_x=0.825,scale_y=0.825)
			else
				spawn_item(C,I,/obj/item/gun/modular/italian/rattler/masterwork,off_x=-8,off_y=1,scale_x=0.825,scale_y=0.825)
			I.parent?.tag_list("Ammo_Allowed", /obj/item/stackable_ammo/pistol/italian/ten)
	// ILLICIT_LOOT_GEAR
	grenades
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/old_grenade/smoke,off_x=-6,off_y=-4)
			spawn_item(C,I,/obj/item/old_grenade/smoke,off_x=-6,off_y=4)
			spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=6,off_y=4)
			spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=6,off_y=-4)
			spawn_item(C,I,/obj/item/old_grenade/stinger,off_y=-4)
			spawn_item(C,I,/obj/item/old_grenade/stinger,off_y=4)
	// GIMMICKS
	money
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/spacecash/fivehundred, -6,-6,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/fivehundred, -6,-4,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/fivehundred, -6,-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/spacecash/fivehundred, -6,0,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/fivehundred, -6,2,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/fivehundred, -6,4,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/spacecash/fivehundred, 6,-6,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/fivehundred, 6,-4,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/fivehundred, 6,-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/spacecash/fivehundred, 6,0,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/fivehundred, 6,2,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/fivehundred, 6,4,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
	hotbox
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,-6,-6,scale_x = 0.8,scale_y = 0.8)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,-6,-3,scale_x = 0.8,scale_y = 0.8)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,-6,0,scale_x = 0.8,scale_y = 0.8)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,-3,3,scale_x = 0.8,scale_y = 0.8)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,-3,6,scale_x = 0.8,scale_y = 0.8)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,-3,scale_x = 0.8,scale_y = 0.8)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,0,-6,scale_x = 0.8,scale_y = 0.8)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,0,-3,scale_x = 0.8,scale_y = 0.8)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,0,0,scale_x = 0.8,scale_y = 0.8)
			spawn_item(C,I,/obj/item/device/light/zippo/gold,6,0,scale_x=0.85,scale_y=0.85)


ABSTRACT_TYPE(/obj/loot_spawner/random/xlong_tall)
/obj/loot_spawner/random/xlong_tall //4x2, these are INCREDIBLY rare and will take up the majority of a crate. can probably be a lil crazy
	xSize = 4
	ySize = 2

	// ILLICIT_LOOT_GUN
	italian_gunse_jackpot
		weight = 15
		tier = ILLICIT_LOOT_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			if(prob(60))
				spawn_item(C,I,/obj/item/gun/modular/italian/rattler/improved,off_x=-4,off_y=4,scale_x=0.825,scale_y=0.825,layer_offset=-0.75)
			else
				spawn_item(C,I,/obj/item/gun/modular/italian/rattler/masterwork,off_x=-4,off_y=4,scale_x=0.825,scale_y=0.825,layer_offset=-0.75)
			spawn_item(C,I,/obj/item/gun/modular/italian/revolver/italiano,off_x=-6,off_y=-4,scale_x=0.825,scale_y=0.825,layer_offset=-0.25)
			spawn_item(C,I,/obj/item/gun/modular/italian/revolver/italiano,off_x=6,off_y=-8,rot=180,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			I.parent?.tag_list("Ammo_Allowed", /obj/item/stackable_ammo/pistol/italian/ten)

	// ILLICIT_LOOT_GEAR

	explosives_jackpot
		tier = ILLICIT_LOOT_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,	/obj/item/mine/stun,off_x=-10, off_y=-2,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,	/obj/item/mine/stun,off_x=-10, off_y=2,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,	/obj/item/mine/stun,off_x=-2, off_y=-2,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,	/obj/item/mine/stun,off_x=-2, off_y=2,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=2,off_y=2,scale_y=0.8)
			spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=2,off_y=2,scale_y=0.8)
			spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=2,off_y=2,scale_y=0.8)
			spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=2,off_y=2,scale_y=0.8)

	// GIMMICKS
	money_jackpot
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/spacecash/thousand, off_x=-8,off_y=-6,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/thousand, off_x=-8,off_y=-4,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/thousand, off_x=-8,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/spacecash/thousand, off_x=-8,off_y=0,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/thousand, off_x=-8,off_y=2,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/thousand, off_x=-8,off_y=4,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/spacecash/thousand, off_x=8,off_y=-6,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/thousand, off_x=8,off_y=-4,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/thousand, off_x=8,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/spacecash/thousand, off_x=8,off_y=0,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/spacecash/thousand, off_x=8,off_y=2,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/spacecash/thousand, off_x=8,off_y=4,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
