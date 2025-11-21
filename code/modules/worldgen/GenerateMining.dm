#define ISDISTEDGE(A, D) (((A.x > (world.maxx - D) || A.x <= D)||(A.y > (world.maxy - D) || A.y <= D))?1:0) //1 if A is within D tiles range from edge of the map.
#define NO_BORDER 0
#define YES_BORDER 1
#define BORDER_PREBAKED 2

#define GEHENNA_MINING_CELL_CHANCE "27" // chance of a turf being considered alive at the start of cavegen automata
#define GEHENNA_MINING_CELL_SMOOTHING "4" // cavegen automata life generations
#define GEHENNA_MINING_CELL_BIRTH_ABOVE "3" // cavegen automata rule of life
#define GEHENNA_MINING_CELL_DEATH_BELOW "3" // cavegen automata rule of death
#define GEHENNA_MINING_HOLE_KEY "1" // "1" means living cells become holes, "0" for dead ones
#define GEHENNA_MINING_Y_SHEAR_CHANCE 60 // probability of shearing the y on each x
#define GEHENNA_MINING_X_STRETCHES 30 // how many x stretches are done across the entire y height

var/list/miningModifiers = list()
var/list/miningModifiersUsed = list()//Assoc list, type:times used

//Notes:
//Anything not encased in an area inside a prefab may be replaced with asteroids during generation. In other words, everything not inside that area is considered "transparent"
//Make sure all your actual structures are inside that area.

/turf/variableTurf
	icon = 'icons/turf/internal.dmi'
	name = ""

	New()
		..()
		place()

	proc/place()
		if (map_currently_underwater)
			src.ReplaceWith(/turf/space/fluid/ocean/trench, FALSE, TRUE, FALSE, TRUE)
		else if (map_currently_very_dusty && ((src.z == 3)||(src.z == 1)))
			src.ReplaceWith(/turf/wall/asteroid/gehenna/z3, FALSE, TRUE, FALSE, TRUE)
		else
			src.ReplaceWith(/turf/space, FALSE, TRUE, FALSE, TRUE)

	floor //Replaced with map appropriate floor tile for mining level (asteroid floor on all maps currently)
		name = "variable floor"
		icon_state = "floor"
		place()
			if (map_currently_underwater)
				src.ReplaceWith(/turf/space/fluid/ocean/trench, FALSE, TRUE, FALSE, TRUE)
			else if (map_currently_very_dusty && ((src.z == 3)||(src.z == 1)))
				src.ReplaceWith(/turf/floor/plating/gehenna, FALSE, TRUE, FALSE, TRUE)
			else
				src.ReplaceWith(/turf/floor/plating/airless/asteroid, FALSE, TRUE, FALSE, TRUE)

	wall //Replaced with map appropriate wall tile for mining level (asteroid wall on all maps currently)
		name = "variable wall"
		icon_state = "wall"
		place()
			if (map_currently_very_dusty && (src.z == 3))
				src.ReplaceWith(/turf/wall/asteroid/gehenna/tough/z3, FALSE, TRUE, FALSE, TRUE)
			else if (map_currently_very_dusty && (src.z == 1))
				src.ReplaceWith(/turf/wall/asteroid/gehenna/tough, FALSE, TRUE, FALSE, TRUE)
			else
				src.ReplaceWith(/turf/wall/asteroid, FALSE, TRUE, FALSE, TRUE)

	random_ship_wall //Randomly a wall or scrap wall, so the dingy looking ships can be slightly more varied
		name = "variable ship hull"
		icon_state = "wall_ship"
		place()
			if (prob(shipyard_scrapwall_prob))
				src.ReplaceWith(/turf/wall/s_wall, FALSE, FALSE, FALSE, TRUE)
			else
				src.ReplaceWith(/turf/wall, FALSE, FALSE, FALSE, TRUE)

	clear //Replaced with map appropriate clear tile for mining level (asteroid floor on oshan, space on other maps)
		name = "variable clear"
		icon_state = "clear"
		place()
			if (map_currently_underwater)
				src.ReplaceWith(/turf/space/fluid/ocean/trench, FALSE, TRUE, FALSE, TRUE)
			else if (map_currently_very_dusty && ((src.z == 3)||(src.z == 1)))
				src.ReplaceWith(/turf/floor/plating/gehenna, FALSE, TRUE, FALSE, TRUE)
			else
				src.ReplaceWith(/turf/space, FALSE, TRUE, FALSE, TRUE)

/area/noGenerate
	name = ""
	icon_state = "blockgen"
	is_construction_allowed = TRUE //would break mining magnet with IM_REALLY_IN_A_FUCKING_HURRY_HERE

/area/allowGenerate //Areas of this type do not block asteroid/cavern generation.
	name = ""
	icon_state = "allowgen"
	is_construction_allowed = TRUE //probably not necessary but

	trench
		name = "Trench"
		sound_group = "trench"
		force_fullbright = 0
		requires_power = 0
		luminosity = 0
		sound_environment = EAX_UNDERWATER
		ambient_light = TRENCH_LIGHT

	caves
		name = "Caves"
		sound_group = "caves"
		force_fullbright = 0
		requires_power = 0
		luminosity = 0
		sound_environment = EAX_CAVE
		//ambient_light = TRENCH_LIGHT

/proc/decideSolid(var/turf/current, var/turf/center, var/sizemod = 0)
	if(!current || !center || (current.loc.type != /area/space && !istype(current.loc , /area/allowGenerate)) || !istype(current, /turf/space))
		return 0
	if(ISDISTEDGE(current, AST_MAPBORDER))
		return 0
	var/probability = 100 - (((abs(center.x - current.x) + abs(center.y - current.y)) - (AST_MINSIZE+sizemod)) * AST_REDUCTION) + rand(-AST_TILERNG,AST_TILERNG)
	if((abs(center.x - current.x) + abs(center.y - current.y)) <= (AST_MINSIZE+sizemod) || prob(probability))
		return 1
	return 0

/datum/mapGenerator
	var/list/seeds = list()
	var/list/generated = list()

	proc/generate(var/list/levelTurfs)
		return levelTurfs

//Why are we defining 5 vars every CAGetSolid call like this when they could be defines, mining aint got time for this
#define CAGGETSOLID_DEFAULT 1 //1 = wall, 0 = empty
#define CAGGETSOLID_MIN_SOLID 5 //Min amount of solid tiles in a given window to produce another solid tile, less = more dense map
#define CAGGETSOLID_END_FILL -1 //Reduce minSolid by this much in the last few passes (produces tighter corridors)

//#define CAGGETSOLID_FILL_LARGE //If defined, put rocks in the middle of very large open caverns so they don't look so empty. Can create very tight maps.
#define CAGGETSOLID_PASS_TWO_RANGE 2 //Range Threshold for second pass (fill pass, see fillLarge). The higher the number, the larger the cavern needs to be before it is filled in.

/proc/CAGetSolid(var/L, var/currentX, var/currentY, var/generation)
	var/count = 0
	for(var/xx=-1, xx<=1, xx++)
		for(var/yy=-1, yy<=1, yy++)
			if(currentX+xx <= world.maxx && currentX+xx >= 1 && currentY+yy <= world.maxy && currentY+yy >= 1)
				count += L[currentX+xx][currentY+yy]
			else //OOB, count as wall.
				count += CAGGETSOLID_DEFAULT

#ifndef CAGGETSOLID_FILL_LARGE
	return (count >= CAGGETSOLID_MIN_SOLID + ((generation==4||generation==3) ? CAGGETSOLID_END_FILL : 0 ))
#else
	//So the logic of the original return statement (simplified) is "5+ walls in a 3*3 OR less than 2 walls in a 5*5"
	//Meaning, if the first loop cleared its threshold that would evaluate true regardless. Might as well skip the back half right.
	var/result = (count >= CAGGETSOLID_MIN_SOLID + ((generation==4||generation==3) ? CAGGETSOLID_END_FILL : 0 ))
	if (result) return TRUE

	var/count2 = 0
	if(fillLarge)
		for(var/xx=-CAGGETSOLID_PASS_TWO_RANGE, xx<=CAGGETSOLID_PASS_TWO_RANGE, xx++)
			for(var/yy=-CAGGETSOLID_PASS_TWO_RANGE, yy<=CAGGETSOLID_PASS_TWO_RANGE, yy++)
				if(abs(xx)==CAGGETSOLID_PASS_TWO_RANGE && abs(yy)==CAGGETSOLID_PASS_TWO_RANGE) continue //Skip diagonals for this one. Better results
				if(currentX+xx <= world.maxx && currentX+xx >= 1 && currentY+yy <= world.maxy && currentY+yy >= 1)
					count2 += L[currentX+xx][currentY+yy]
				else //OOB, count as wall.
					count2 += CAGGETSOLID_DEFAULT

	return (count2<=(generation==4?1:2) && fillLarge && (generation==3 || generation==4))

	//Look I appreciate being able to get your return on one line like this, but this proc is called like 400000+ times to make the trench & desert levels
	//We gotta go fast so why have the back half of that OR in there when it's not used in practice?
	//return (count >= CAGGETSOLID_MIN_SOLID + ((generation==4||generation==3) ? CAGGETSOLID_END_FILL : 0 ) || (count2<=(generation==4?1:2) && fillLarge && (generation==3 || generation==4)) ) //Remove ((generation==4||generation==3)?-1:0) for larger corridors
#endif



/datum/mapGenerator/desertCaverns
	//I don't know why these generators bother with the miningZ var btw, the desert/trench generators didn't do anything with them before starstone generation was added
	//now this one doesnt use it at all, so bah!
	generate(var/list/miningZ = null, var/z_level = GEH_ZLEVEL, var/generate_borders = YES_BORDER)
		//Set up stat logging
		var/datum/mining_level_stats/our_stats = new
		our_stats.z_level = z_level
		our_stats.generator = src.type
		mining_controls.mining_level_stats += our_stats

		//Generate start/end coords further in if borders are used, at the current default of 3 wide borders that saves ~3,5k turfs getting iterated over.
		var/startx = (generate_borders ? AST_MAPBORDER+1 : 1)
		var/starty = (generate_borders ? AST_MAPBORDER+1 : 1)
		var/endx = (generate_borders ? world.maxx-(AST_MAPBORDER) : world.maxx)
		var/endy = (generate_borders ? world.maxy-(AST_MAPBORDER) : world.maxy)


/*
		//Generate a map full of random 1s and 0s, 1s are dense rock and 0s are loose rock
		var/map[world.maxx][world.maxy]
		var/list/vertical_slice = list()
		var/sine_offset = rand(-60, 60) //degrees
		var/sine_amplitude = rand(4,5)
		var/sine_frequency = rand(17,27)/10 //1.7-2.7, can't go too low or the sine wave gets very obviously segmented thanks to rounding
		var/sine_ramp = rand(-5,5)/10
		for(var/i = 1, i <= 300, i++)
			vertical_slice += pick(90;1,100;0)
		for(var/y=max(starty - 1,1), y<= min(endy + 1, world.maxy), y++)
			for(var/x=max(startx - 1,1), x <= min(endx + 1, world.maxx), x++)
				map[x][y] = vertical_slice[x]/*pick(90;1,100;0)*/ //Initialize randomly.
			/*
				This mess is basically round(a*sin(bY+c)+dY) plus some randomness
				where: a = sine_amplitude, b = sine_frequency, c = sine_offset, d = sine_ramp
				all that modulo 300 because we can't go bigger than the length of vertical_slice (and functionally it'd loop anyway)
			*/
			var/jitter = (round(sine_amplitude*(sin(sine_frequency*y + sine_offset)) + y*sine_ramp, 1) + rand(-2,4)) % 300
			if (jitter > 0)
				var/list/tempu = vertical_slice.Copy(1, jitter)
				vertical_slice.Cut(1, jitter)
				vertical_slice += tempu
			else if (jitter < 0)
				var/list/tempd = vertical_slice.Copy(length(vertical_slice) + jitter, 0)
				vertical_slice.Cut(length(vertical_slice) + jitter,0)
				vertical_slice = tempd + vertical_slice
			//if jitter is 0, do nothing




		//Previous version of the smoothing loop, which I figure might be of interest to someone when the code below looks too shit
		/*for(var/i=0, i<5, i++) //5 Passes to smooth it out.
			var/mapnew[world.maxx][world.maxy]
			for(var/x=startx,x<=endx,x++)
				for(var/y=starty,y<=endy,y++)
					mapnew[x][y] = CAGetSolid(map, x, y, i)
					LAGCHECK(LAG_REALTIME)
			map = mapnew*/

		/*
		So how about we inline CAGetSolid into this smoothing bit?
		The reason for doing this is computer science levels of optimisation bullshit. CAGetSolid checks the 3*3 around a cell and counts 1s in that (OOB are dense)
		It has no context of which order it's being called in but since we'd call it with consecutive cells, 6 of 9 cells being evaluated are the same until we reach the end of a row
		This means that just by doing some manual memory shuffling we save , which should in theory speed up the process considerably.
		While I'm at it, I'm just gonna ignore OOB checking since in practice this is only ever going to operating within the 3 tile buffer.
		*/
		//Feed the map of random noise through a smoothing algorithm a few times, creating a marbled texture by the end

		for(var/i=0, i<5, i++) //5 Passes to smooth it out.
			var/mapnew[world.maxx][world.maxy]
			for(var/x=startx,x<=endx,x++)
				//So this is silly, since we only need to store 3 things. The problem is BYOND kept making a fucking associative list with numeric association indices (which I tihnk isn't supposed ot be possible?)
				//Resulting shit just getting stored randomly in places.
				//And rather than become the kind of masochist who engages in whatever fucking pedantry is going on, I've just decided to instead used indices 4 through 6 since count only goes up to 3
				var/list/rolling_counts = list(0,0,0,0,0,0)
				var/index = 6 //We'll pre-populate the first 2 (indices 4 & 5)
				var/count

				//First, handle the rows behind and
				for(var/yy=-1, yy<1, yy++)
					count = 0
					for(var/xx=-1, xx<=1, xx++)
						count += map[x+xx][starty+yy]
					rolling_counts[yy+5] = count

				//Now all that needs to be checked for each y is the three turfs one ahead of y
				for(var/y=starty,y<=endy,y++)
					count = 0
					for(var/xx=-1, xx<=1, xx++)
						count += map[x + xx][y + 1]
					rolling_counts[index] = count
					index++
					if (index > 6) index = 4 //Again, this is dumb, I agree
					var/sum_of_dense = rolling_counts[4] + rolling_counts[5] + rolling_counts[6] //but it works
					mapnew[x][y] = (sum_of_dense >= CAGGETSOLID_MIN_SOLID + ((i==4||i==3) ? CAGGETSOLID_END_FILL : 0 ))
					LAGCHECK(LAG_REALTIME)
			map = mapnew
*/

/*
		var/list/used = list()
		for(var/s=0, s<20, s++)
			var/turf/TU = pick(generated - used)
			var/list/L = list()
			for(var/turf/wall/asteroid/A in orange(5,TU))
				L.Add(A)
			seeds.Add(TU)
			seeds[TU] = L
			used.Add(L)
			used.Add(TU)

			var/list/holeList = list()
			for(var/k=0, k<AST_RNGWALKINST, k++)
				var/turf/T = pick(L)
				for(var/j=0, j<rand(2*AST_RNGWALKCNT,round(AST_RNGWALKCNT*4.5)), j++)
					holeList.Add(T)
					T = get_step(T, pick(NORTH,EAST,SOUTH,WEST,EAST,SOUTH)) // slight S-E bias
					if(!istype(T, /turf/wall/asteroid)) continue
					var/turf/wall/asteroid/ast = T
					ast.destroy_asteroid(0)
*/

/*
		//For the next bit, you might want to turn on DEBUG_ORE_GENERATION in sea_hotspot_controls.dm so you can see what ore generation looks like at scale

		//This bit seeds random squares of the level with large amounts of ore, densely packed.
		for(var/i=0, i<80, i++)
			var/list/L = list()
			for (var/turf/wall/asteroid/gehenna/A in range(4,pick(generated)))
				if(prob(50))
					L+=A

			Turfspawn_Asteroid_SeedOre(L, rand(2,8), rand(1,70), TRUE, level_stats = our_stats)

		//Sprinkles random ore veins just all over the map
		for(var/i=0, i<80, i++)
			Turfspawn_Asteroid_SeedOre(generated, spicy = TRUE, level_stats = our_stats)

*/

		//Generate a map of holes aka caves via cellular automata
		//a 0 is a solid turf while a 1 is a hole here, useful for ore generation
		var/map[endx - startx + 1][endy - starty + 1]
		//the lower this is (1 is no stretch), the more the caves are stretched
		var/cell_y_stretch = rand() * 0.15 + 0.4 // vertical stretch
		var/cell_x_stretch = rand() * 0.15 + 0.7 // horizontal stretch
		//how many spaces we are skipping forward
		var/cell_bonus = 0
		//these values are all cellular automata rules
		var/cellular_holes = rustg_cnoise_generate(GEHENNA_MINING_CELL_CHANCE, GEHENNA_MINING_CELL_SMOOTHING, GEHENNA_MINING_CELL_BIRTH_ABOVE, GEHENNA_MINING_CELL_DEATH_BELOW, "[endx - startx + 1]", "[endy - starty + 1]")
		var/cellular_holes_length = length(cellular_holes)
		//convert the map we've ended up with into caves
		var/list/x_stretch_locations = list()
		//Generates some stretch locations
		for(var/i in 0 to (GEHENNA_MINING_X_STRETCHES - 1))
			x_stretch_locations += 1 + ceil(rand(0, (endx - startx + 1) / GEHENNA_MINING_X_STRETCHES) + (endy - starty + 1) * i / GEHENNA_MINING_X_STRETCHES)
		var/cell_x_sum
		for(var/x in startx to endx)
			if(prob(GEHENNA_MINING_Y_SHEAR_CHANCE))
				cell_bonus += 1 + prob(GEHENNA_MINING_Y_SHEAR_CHANCE)
			else if(prob(10))
				cell_bonus--

			// start over on the cell index, but include the y shear bonus
			var/cell_index = cell_bonus
			cell_x_sum = (cell_x_stretch) + rand() * 0.05
			if(cell_x_sum >= 1)
				cell_x_sum--
				cell_bonus += endx - startx + 1
			var/x_stretch_index = 1
			for(var/y in starty to endy)
				// indexing
				cell_index += cell_y_stretch

				// find the turf
				var/turf/T = locate(x,y,z_level)

				// get outta the station and already empty parts
				if(!T.density || !istype(T.loc, /area/allowGenerate))
					map[x - startx + 1][y - starty + 1] = !T.density
					continue

				// check if the current location is past (in case we skipped it due to being in the station) the lowest x_stretch location,
				// and if it is, stretch, maybe decrease all positions, and start checking for the next one
				if(y >= x_stretch_locations[x_stretch_index])
					x_stretch_locations[x_stretch_index] += rand(-1,1)
					x_stretch_index = min(x_stretch_index + 1, GEHENNA_MINING_X_STRETCHES)
					cell_index += (endy - starty + 1)

				// create cave holes and weaken tough rocks that linger
				if(cellular_holes[ceil(1 + ((cell_index + cellular_holes_length) % cellular_holes_length))] == GEHENNA_MINING_HOLE_KEY)
					if(!istype(T, /turf/wall/asteroid/gehenna/tough/z3) || prob(60))
						T = T.ReplaceWith(/turf/floor/plating/gehenna, FALSE, TRUE, FALSE, TRUE)
						map[x - startx + 1][y - starty + 1] = 1
						LAGCHECK(LAG_REALTIME)
						continue
					else if(prob(70))
						T = T.ReplaceWith(/turf/wall/asteroid/gehenna/z3, FALSE, TRUE, FALSE, TRUE)

				// add whatever rock we have
				generated.Add(T)
				map[x - startx + 1][y - starty + 1] = 0
				LAGCHECK(LAG_REALTIME)

		//we adjust the map to give higher ore chance when adjacent to a cave
		var/mapnew[endx - startx + 1][endy - starty + 1]
		for(var/i in 1 to 2)
			for(var/x in 2 to (endx - startx - 1))
				for(var/y in 2 to (endy - starty - 1))
					mapnew[x][y] = map[x][y] == 1 ? 1 : ((map[x-1][y] + map[x+1][y] + map[x][y-1] + map[x][y+1]) * 0.175)
					LAGCHECK(LAG_REALTIME)
			map = mapnew

		//manual ore generation without using the proc, for speed and also so i can make minor alterations to this variants patterns
		var/ore_types_nonevent = mining_controls.ore_types_common + mining_controls.ore_types_uncommon + mining_controls.ore_types_rare + mining_controls.ore_types_rare_spicy
		for(var/turf/wall/asteroid/T as anything in generated)
			var/datum/ore/picked_ore
			// common ores near caves
			if(prob(80 * map[T.x - startx + 1][T.y - starty + 1]))
				picked_ore = prob(20) ? (prob(20) ? pick(mining_controls.ore_types_rare) : pick(mining_controls.ore_types_uncommon)) : pick(mining_controls.ore_types_common)
			// rare ones in the walls!
			else if(map[T.x - startx + 1][T.y - starty + 1] < 0.1 && prob(3))
				picked_ore = pick(ore_types_nonevent)
			else
				LAGCHECK(LAG_REALTIME)
				continue

			if (our_stats)
				our_stats.total_ore_ids |= picked_ore.name
				our_stats.veins[picked_ore.name] += 1
			var/turf/wall/asteroid/T2 = T
			var/vein_dir = NORTHWEST
			for(var/ore_spawns in 1 to rand(picked_ore.tiles_per_rock_min,picked_ore.tiles_per_rock_max) * 2) // gehenna ores are long veins
				if(istype(T2) && !T2.ore)
					T2.ore = picked_ore
					T2.hardness += picked_ore.hardness_mod
					T2.amount = rand(picked_ore.amount_per_tile_min,picked_ore.amount_per_tile_max)
					var/image/ore_overlay = image('icons/turf/asteroid.dmi',picked_ore.name)
					ore_overlay.transform = turn(ore_overlay.transform, pick(0,90,180,-90))
					ore_overlay.pixel_x += rand(-6,6)
					ore_overlay.pixel_y += rand(-6,6)
					T2.overlays += ore_overlay // faster than UpdateOverlays
					picked_ore.onGenerate(T2)
					T2.mining_health = picked_ore.mining_health
					T2.mining_max_health = picked_ore.mining_health
					if (our_stats)
						our_stats.ores[picked_ore.name] += 1
						our_stats.total_generated_ores += 1
					if(prob(10))
						vein_dir = turn(vein_dir, pick(50; 45, 100; -45))
				else
					our_stats.misses[picked_ore.name] += 1
					if(prob(20))
						vein_dir = turn(vein_dir, pick(100; 45, 50; -45))
				T2 = get_step(T, vein_dir)
			LAGCHECK(LAG_REALTIME)

		//Seeds gem/artifact/crate/rock modifiers. Note that without specifying an amount of events the proc will randomly do between 1 and 6 each time
		//(meaning if i is still 40 on the line below, that's anywhere from 40-240 events)
		// its 50 now, and with 40+ samples its not gonna roll anything too high or low. expect 175ish attempts.
		for(var/i=0, i<50, i++)
			Turfspawn_Asteroid_SeedEvents(generated, level_stats = our_stats)
			LAGCHECK(LAG_REALTIME)

		if(generate_borders == YES_BORDER) //border needed and isn't prebaked
			var/list/border = list()
			border |= (block(locate(1,1,z_level), locate(AST_MAPBORDER,world.maxy,z_level))) //Left
			border |= (block(locate(1,1,z_level), locate(world.maxx,AST_MAPBORDER,z_level))) //Bottom
			border |= (block(locate(world.maxx-(AST_MAPBORDER-1),1,z_level), locate(world.maxx,world.maxy,z_level))) //Right
			border |= (block(locate(1,world.maxy-(AST_MAPBORDER-1),z_level), locate(world.maxx,world.maxy,z_level))) //Top

			for(var/turf/T as anything in border)
				T.ReplaceWith(/turf/wall/gehenna, FALSE, TRUE, FALSE, TRUE)
				new/area/cordon/dark(T)
				LAGCHECK(LAG_REALTIME)

		//Same deal as on asteroidsDistance, try manually seeding some starstones so they're not magnet exclusive (though there's no magnet available on gehenna, right?)
		var/starstones = 0
		for (var/i in 1 to 3) // 3 tries, because it should only fail due to ore being present
			var/turf/wall/asteroid/TRY = pick(generated)
			if (!istype(TRY))
				logTheThing("debug", null, null, "Starstone gen #[i] at [showCoords(TRY.x, TRY.y, TRY.z)] failed - bad turf.")
				continue
			if (TRY.ore)
				logTheThing("debug", null, null, "Starstone gen #[i] at [showCoords(TRY.x, TRY.y, TRY.z)] failed - ore present.")
				continue
			//asteroid and unoccupied!
			Turfspawn_Asteroid_SeedSpecificOre(list(TRY),"starstone",1, level_stats = our_stats) //This probably makes a coder from 10 years ago cry
			logTheThing("debug", null, null, "Starstone gen #[i] at [showCoords(TRY.x, TRY.y, TRY.z)] success!")
			starstones++
			if(starstones >= 3)
				break

		//We're done, get some totals up
		our_stats.calculate_totals()
		return miningZ

/datum/mapGenerator/seaCaverns //Cellular automata based generator. Produces cavern-like maps. Empty space is filled with asteroid floor.
	generate(var/list/miningZ, var/z_level = AST_ZLEVEL, var/generate_borders = YES_BORDER)
		//Set up stat logging
		var/datum/mining_level_stats/our_stats = new
		our_stats.z_level = z_level
		our_stats.generator = src.type
		mining_controls.mining_level_stats += our_stats

		var/map[world.maxx][world.maxy]
		for(var/x=1,x<=world.maxx,x++)
			for(var/y=1,y<=world.maxy,y++)
				map[x][y] = pick(90;1,100;0) //Initialize randomly.

		for(var/i=0, i<5, i++) //5 Passes to smooth it out.
			var/mapnew[world.maxx][world.maxy]
			for(var/x=1,x<=world.maxx,x++)
				for(var/y=1,y<=world.maxy,y++)
					mapnew[x][y] = CAGetSolid(map, x, y, i)
					LAGCHECK(LAG_REALTIME)
			map = mapnew

		for(var/x=1,x<=world.maxx,x++)
			for(var/y=1,y<=world.maxy,y++)
				var/turf/T = locate(x,y,z_level)
				if(map[x][y] && !ISDISTEDGE(T, 3) && T.loc && ((T.loc.type == /area/space) || istype(T.loc , /area/allowGenerate)) )
					var/turf/wall/asteroid/N = T.ReplaceWith(/turf/wall/asteroid/dark, FALSE, TRUE, FALSE, TRUE)
					generated.Add(N)
				if(T.loc.type == /area/space || istype(T.loc, /area/allowGenerate))
					new/area/allowGenerate/trench(T)
				LAGCHECK(LAG_REALTIME)

		var/list/used = list()
		for(var/s=0, s<20, s++)
			var/turf/TU = pick(generated - used)
			var/list/L = list()
			for(var/turf/wall/asteroid/A in orange(5,TU))
				L.Add(A)
			seeds.Add(TU)
			seeds[TU] = L
			used.Add(L)
			used.Add(TU)

			var/list/holeList = list()
			for(var/k=0, k<AST_RNGWALKINST, k++)
				var/turf/T = pick(L)
				for(var/j=0, j<rand(AST_RNGWALKCNT,round(AST_RNGWALKCNT*1.5)), j++)
					holeList.Add(T)
					T = get_step(T, pick(NORTH,EAST,SOUTH,WEST))
					if(!istype(T, /turf/wall/asteroid)) continue
					var/turf/wall/asteroid/ast = T
					ast.destroy_asteroid(0)


		for(var/i=0, i<80, i++)
			var/list/L = list()
			for (var/turf/wall/asteroid/dark/A in range(4,pick(generated)))
				L+=A

			Turfspawn_Asteroid_SeedOre(L, rand(2,8), rand(1,70), level_stats = our_stats)

		for(var/i=0, i<80, i++)
			Turfspawn_Asteroid_SeedOre(generated, level_stats = our_stats)


		//for(var/i=0, i<100, i++)
		//	if(prob(20))
		//		Turfspawn_Asteroid_SeedOre(generated, rand(2,6), rand(0,70))
		//	else
		//		Turfspawn_Asteroid_SeedOre(generated)

		for(var/i=0, i<40, i++)
			Turfspawn_Asteroid_SeedEvents(generated, level_stats = our_stats)

		if(generate_borders)
			var/list/border = list()
			border |= (block(locate(1,1,z_level), locate(AST_MAPBORDER,world.maxy,z_level))) //Left
			border |= (block(locate(1,1,z_level), locate(world.maxx,AST_MAPBORDER,z_level))) //Bottom
			border |= (block(locate(world.maxx-(AST_MAPBORDER-1),1,z_level), locate(world.maxx,world.maxy,z_level))) //Right
			border |= (block(locate(1,world.maxy-(AST_MAPBORDER-1),z_level), locate(world.maxx,world.maxy,z_level))) //Top

			for(var/turf/T in border)
				T.ReplaceWith(/turf/wall/trench, FALSE, TRUE, FALSE, TRUE)
				new/area/cordon/dark(T)
				LAGCHECK(LAG_REALTIME)

		for (var/i=0, i<55, i++)
			var/turf/T = locate(rand(1,world.maxx),rand(1,world.maxy),z_level)
			for (var/turf/space/fluid/ocean/TT in range(rand(2,4),T))
				TT.spawningFlags |= SPAWN_TRILOBITE

		//I copied this from the desert caves without testing, how often are we gonna run Oshan anyway
		for (var/i = 1, i <= 3 ,i++)
			var/turf/wall/asteroid/TRY = pick(miningZ)
			if (!istype(TRY))
				logTheThing("debug", null, null, "Starstone gen #[i] at [showCoords(TRY.x, TRY.y, TRY.z)] failed - no wall.")
				continue
			if (TRY.ore)
				logTheThing("debug", null, null, "Starstone gen #[i] at [showCoords(TRY.x, TRY.y, TRY.z)] failed - ore present.")
				continue
			//asteroid and unoccupied!
			Turfspawn_Asteroid_SeedSpecificOre(list(TRY),"starstone",1, level_stats = our_stats)
			logTheThing("debug", null, null, "Starstone gen #[i] at [showCoords(TRY.x, TRY.y, TRY.z)] success!")

		//We're done, get some totals up
		our_stats.calculate_totals()
		return miningZ

/datum/mapGenerator/asteroidsDistance //Generates a bunch of asteroids based on distance to seed/center. Super simple.
	generate(var/list/miningZ, z_level = AST_ZLEVEL)
		//Set up stat logging
		var/datum/mining_level_stats/our_stats = new
		our_stats.z_level = z_level
		our_stats.generator = src.type
		mining_controls.mining_level_stats += our_stats

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
				Turfspawn_Asteroid_SeedOre(placed, rand(2,6), rand(0,40), TRUE, level_stats = our_stats)
			else
				Turfspawn_Asteroid_SeedOre(placed, spicy = TRUE, level_stats = our_stats)

			Turfspawn_Asteroid_SeedEvents(placed, level_stats = our_stats)

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
			Turfspawn_Asteroid_SeedSpecificOre(list(TRY),"starstone",1, level_stats = our_stats) //This probably makes a coder from 10 years ago cry
			logTheThing("debug", null, null, "Starstone gen #[i] at [showCoords(TRY.x, TRY.y, TRY.z)] success!")

		//We're done, get some totals up
		our_stats.calculate_totals()
		return miningZ

/proc/makeMiningLevelGehenna()
	//var/list/miningZ = block(locate(1, 1, GEH_ZLEVEL), locate(world.maxx, world.maxy, GEH_ZLEVEL))
	var/startTime = world.timeofday
	boutput(world, "<span class='alert'>Generating the OTHER Mining Level ...</span>")

	var/num_to_place = AST_NUMPREFABS + rand(0,AST_NUMPREFABSEXTRA) + 2
	for (var/n = 1, n <= num_to_place, n++)
		game_start_countdown?.update_status("Setting up mining level...\n(Prefab [n]/[num_to_place])")
		var/datum/generatorPrefab/M = pickPrefab(1)
		if (M)
			var/maxX = (world.maxx - M.prefabSizeX - AST_MAPBORDER)
			var/maxY = (world.maxy - M.prefabSizeY - AST_MAPBORDER)
			var/stop = 0
			var/count= 0
			var/maxTries = (M.required ? 200:33)
			while (!stop && count < maxTries) //Kinda brute forcing it. Dumb but whatever.
				var/turf/target = locate(rand(1+AST_MAPBORDER, maxX), rand(1+AST_MAPBORDER,maxY), GEH_ZLEVEL)
				var/ret = M.applyTo(target)
				if (ret == 0)
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type] failed due to blocked area. [target] @ [showCoords(target.x, target.y, target.z)]")
				else
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type][M.required?" (REQUIRED)":""] succeeded. [target] @ [showCoords(target.x, target.y, target.z)]")
					stop = 1
				count++
				if (count >= maxTries)
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type] failed due to maximum tries [maxTries][M.required?" WARNING: REQUIRED FAILED":""]. [target] @ [showCoords(target.x, target.y, target.z)]")
		else break

	var/datum/mapGenerator/desertCaverns/D = new/datum/mapGenerator/desertCaverns()

	game_start_countdown?.update_status("Setting up mining level...\nGenerating terrain... again...")
	D.generate(miningZ = null, generate_borders = BORDER_PREBAKED)
	var/area/desertarea = get_area_by_type(/area/gehenna/underground)
	if(!desertarea)
		desertarea = new /area/gehenna/underground(locate(1,1,GEH_ZLEVEL))

	// remove temporary areas
	for (var/turf/T in get_area_turfs(/area/noGenerate))
		if(T.z==3)
			desertarea.add_turf(T)
		else
			new /area/space(T)

	for (var/turf/T in get_area_turfs(/area/allowGenerate))
		if(T.z==3)
			desertarea.add_turf(T)
		else
			new /area/space(T)

	boutput(world, "<span class='alert'>Generated (the other) Mining Level in [((world.timeofday - startTime)/10)] seconds!")


/proc/makeMiningLevel()
	var/list/miningZ = block(locate(1, 1, AST_ZLEVEL), locate(world.maxx, world.maxy, AST_ZLEVEL))
	var/startTime = world.timeofday
	if(world.maxz < AST_ZLEVEL)
		boutput(world, "<span class='alert'>Skipping Mining Generation!</span>")
		return
	else
		boutput(world, "<span class='alert'>Generating Mining Level ...</span>")

	var/num_to_place = AST_NUMPREFABS + rand(0,AST_NUMPREFABSEXTRA)
	for (var/n = 1, n <= num_to_place, n++)
		game_start_countdown?.update_status("Setting up mining level...\n(Prefab [n]/[num_to_place])")
		var/datum/generatorPrefab/M = pickPrefab()
		if (M)
			var/maxX = (world.maxx - M.prefabSizeX - AST_MAPBORDER)
			var/maxY = (world.maxy - M.prefabSizeY - AST_MAPBORDER)
			var/stop = 0
			var/count= 0
			var/maxTries = (M.required ? 200:33)
			while (!stop && count < maxTries) //Kinda brute forcing it. Dumb but whatever.
				var/turf/target = locate(rand(1+AST_MAPBORDER, maxX), rand(1+AST_MAPBORDER,maxY), AST_ZLEVEL)
				var/ret = M.applyTo(target)
				if (ret == 0)
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type] failed due to blocked area. [target] @ [showCoords(target.x, target.y, target.z)]")
				else
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type][M.required?" (REQUIRED)":""] succeeded. [target] @ [showCoords(target.x, target.y, target.z)]")
					stop = 1
				count++
				if (count >= 33)
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type] failed due to maximum tries [maxTries][M.required?" WARNING: REQUIRED FAILED":""]. [target] @ [showCoords(target.x, target.y, target.z)]")
		else break

	var/datum/mapGenerator/D

	if(map_currently_underwater)
		D = new/datum/mapGenerator/seaCaverns()
	else
		D = new/datum/mapGenerator/asteroidsDistance()

	game_start_countdown?.update_status("Setting up mining level...\nGenerating terrain...")
	miningZ = D.generate(miningZ, AST_ZLEVEL)

	// remove temporary areas
	if(!map_currently_very_dusty)
		for (var/turf/T in get_area_turfs(/area/noGenerate))
			if (map_currently_underwater)
				new /area/allowGenerate/trench(T)
			else
				new /area/space(T)
		if (!map_currently_underwater)
			for (var/turf/T in get_area_turfs(/area/allowGenerate))
				new /area/space(T)

	boutput(world, "<span class='alert'>Generated Mining Level in [((world.timeofday - startTime)/10)] seconds!")

	if(map_currently_very_dusty)
		makeMiningLevelGehenna()
		hotspot_controller.generate_map(GEH_ZLEVEL, "desert")

	hotspot_controller.generate_map(AST_ZLEVEL, map_currently_underwater ? "trench" : "space")

/proc/pickPrefab(var/dusty = 0)
	var/list/eligible = list()
	var/list/required = list()

	for(var/datum/generatorPrefab/M in miningModifiers)
		if(M.underwater != map_currently_underwater) continue
		if(M.dusty != dusty) continue
		if(M.type in miningModifiersUsed)
			if(M.required) continue
			if(M.maxNum != -1)
				if(miningModifiersUsed[M.type] >= M.maxNum)
					continue
				else
					eligible.Add(M)
					eligible[M] = M.probability
			else
				eligible.Add(M)
				eligible[M] = M.probability
		else
			eligible.Add(M)
			eligible[M] = M.probability
			if(M.required) required.Add(M)

	if(required.len)
		var/datum/generatorPrefab/P = required[1]
		miningModifiersUsed.Add(P.type)
		miningModifiersUsed[P.type] = 1
		return P
	else
		if(eligible.len)
			var/datum/generatorPrefab/P = weighted_pick(eligible)
			if(P.type in miningModifiersUsed)
				miningModifiersUsed[P.type] = (miningModifiersUsed[P.type] + 1)
			else
				miningModifiersUsed.Add(P.type)
				miningModifiersUsed[P.type] = 1
			return P
		else return null

#undef ISDISTEDGE
#undef NO_BORDER
#undef YES_BORDER
#undef BORDER_PREBAKED

#undef CAGGETSOLID_DEFAULT
#undef CAGGETSOLID_MIN_SOLID
#undef CAGGETSOLID_END_FILL
#undef CAGGETSOLID_PASS_TWO_RANGE

///// ------------------------------------------------------------------ /////
//Let's get some stats on the mining Z level generation

///Modular mining Z level generation stats holder, to be used by the global mining controller
/datum/mining_level_stats
	///Which Z level?
	var/z_level
	///type of the generator that generated this level (the data is actually entered mostly by the lower level seeding procs and not the generator itself)
	var/generator

	///Every ore that has been attemped to be generated, so we always have a full list of IDs even if one of them failed every single time somehow
	var/list/total_ore_ids = list()
	///Every event that has been attempted to be generated
	var/list/total_event_ids = list()
	///Counts of ores, by ore name (which are practically also their ID)
	var/list/ores = list()
	///Counts of ore "veins" by ore name, since some ores generate larger veins by
	var/list/veins = list()
	///Counts of ores that failed to generate, by name
	var/list/misses = list()
	///Counts of mining events, by name
	var/list/events = list()
	///Amount of set_event calls by name, analogous to ore veins since some events will spawn a bunch of copies around neighbouring turfs
	var/list/event_calls = list() //And I feel like there's some interest to be had in relative distribution that isn't skewed by a few factors of 12
	///Counts of events that couldn't be placed, by name
	var/list/event_misses = list()

	///Asteroid generation specific
	//var/amount_of_seeds = 0
	//var/failed_seeds = 0

	var/total_generated_ores = 0
	var/total_generated_events = 0
	var/total_event_calls = 0

	///percentage of every ore versus total generated ore, by name
	var/list/ore_total_percentages = list()
	///percentage of succeeded vs total generations per ore type, by name
	var/list/ore_success_percentages = list()
	///ores / veins, by ore name
	var/list/ore_averages_per_vein = list()

	//var/list/ore_percentage_in_rarity_bracket = list()
	///percentage of event vs total
	var/list/event_total_percentages = list()
	///percentage of event calls vs total
	var/list/event_call_percentages = list()
	///percentage of succeeded vs total generations per event type, by name
	var/list/event_success_percentages = list()


//Calculate percentages and stuff, once level generation has populated all the ores.
/datum/mining_level_stats/proc/calculate_totals()
	//First, get 2 sortin'
	//sortList(total_ore_ids)
	//sortList(total_event_ids)

	//I don't care that much for decimals, so 0,1% is good enough
	for (var/an_ore in total_ore_ids)
		if (isnull(ores[an_ore])) //short if we didn't manage to generate anything
			ore_total_percentages[an_ore] = 0
			ore_success_percentages[an_ore] = 0
			ore_averages_per_vein[an_ore] = 0
			continue

		if (total_generated_ores) //no div by 0 pls
			ore_total_percentages[an_ore] = round((ores[an_ore]/total_generated_ores)*100, 0.1)
		else
			ore_total_percentages[an_ore] = 0

		if (!isnull(misses[an_ore]))
			ore_success_percentages[an_ore] = round((ores[an_ore]/(ores[an_ore] + misses[an_ore]))*100 ,0.1)
		else //No fails!
			ore_success_percentages[an_ore] = 100

		if (!isnull(veins[an_ore])) //shouldn't be possible but
			ore_averages_per_vein[an_ore] = round(ores[an_ore]/veins[an_ore], 0.1)
		else
			ore_averages_per_vein[an_ore] = 0

	for (var/an_event in total_event_ids)
		if (isnull(events[an_event])) //No events generated, which should be impossible
			event_total_percentages[an_event] = 0
			event_success_percentages[an_event] = 0
			event_call_percentages[an_event] = 0 //<- Not necessarily accurate but IDC
			continue

		if (total_generated_events)
			event_total_percentages[an_event] = round((events[an_event]/total_generated_events)*100, 0.1)
		else
			event_total_percentages[an_event] = 0

		//if (isnull(event_calls[an_event]))
		//	event_

		if (total_event_calls && !isnull(event_calls[an_event]))
			event_call_percentages[an_event] = round((event_calls[an_event]/total_event_calls)*100, 0.1)
		else
			event_call_percentages[an_event] = 0

		if (!isnull(event_misses[an_event]))
			event_success_percentages[an_event] = round((events[an_event]/(events[an_event] + event_misses[an_event]))*100, 0.1)
		else
			event_success_percentages[an_event] = 100


#undef GEHENNA_MINING_CELL_CHANCE
#undef GEHENNA_MINING_CELL_SMOOTHING
#undef GEHENNA_MINING_CELL_BIRTH_ABOVE
#undef GEHENNA_MINING_CELL_DEATH_BELOW
#undef GEHENNA_MINING_HOLE_KEY
#undef GEHENNA_MINING_Y_SHEAR_CHANCE
#undef GEHENNA_MINING_X_STRETCHES
