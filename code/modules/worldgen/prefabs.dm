
ABSTRACT_TYPE(/datum/generatorPrefab)
/datum/generatorPrefab
	var/probability = 0
	var/maxNum = 0
	var/prefabPath = ""
	var/prefabSizeX = 5
	var/prefabSizeY = 5
	var/underwater = 0 //prefab will only be used if this matches map_currently_underwater. I.e. if this is 1 and map_currently_underwater is 1 then the prefab may be used.
	var/dusty = 0 		// prefab will only be used if this matched map_currently_very_dusty, see above if your so dumb.
	var/required = 0   //If 1 we will try to always place thing thing no matter what. Required prefabs will only ever be placed once.

	proc/applyTo(var/turf/target)
		var/adjustX = target.x
		var/adjustY = target.y

		 //Move prefabs backwards if they would end up outside the map.
		if((adjustX + prefabSizeX) > (world.maxx - AST_MAPBORDER))
			adjustX -= ((adjustX + prefabSizeX) - (world.maxx - AST_MAPBORDER))

		if((adjustY + prefabSizeY) > (world.maxy - AST_MAPBORDER))
			adjustY -= ((adjustY + prefabSizeY) - (world.maxy - AST_MAPBORDER))

		var/turf/T = locate(adjustX, adjustY, target.z)

		for(var/x=0, x<prefabSizeX; x++)
			for(var/y=0, y<prefabSizeY; y++)
				var/turf/L = locate(T.x+x, T.y+y, T.z)
				if(L?.loc && ((L.loc.type != /area/space) && !istype(L.loc , /area/allowGenerate) && !istype(L.loc, /area/gehenna/underground))) // istype(L.loc, /area/noGenerate)
					return 0

		var/loaded = file2text(prefabPath)

		if(T && loaded)
			var/dmm_suite/D = new/dmm_suite()
			var/datum/loadedProperties/props = D.read_map(loaded,T.x,T.y,T.z,prefabPath)
			if(prefabSizeX != props.maxX - props.sourceX + 1 || prefabSizeY != props.maxY - props.sourceY + 1)
				CRASH("size of prefab [prefabPath] is incorrect ([prefabSizeX]x[prefabSizeY] != [props.maxX - props.sourceX + 1]x[props.maxY - props.sourceY + 1])")
			return 1
		else return 0

	clown
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_clown.dmm"
		prefabSizeX = 5
		prefabSizeY = 5

	vault
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_vault.dmm"
		prefabSizeX = 7
		prefabSizeY = 7

	shuttle
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_shuttle.dmm"
		prefabSizeX = 19
		prefabSizeY = 13

	cannibal
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_cannibal.dmm"
		prefabSizeX = 10
		prefabSizeY = 10

	sleepership
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_sleepership.dmm"
		prefabSizeX = 15
		prefabSizeY = 19

	rockworms
		maxNum = 4 // It was at 10 ... and there was a good chance that most of the prefabs on Z5 were this ugly mess. We need less of that. Way less. So here ya'go.
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_rockworms.dmm"
		prefabSizeX = 5
		prefabSizeY = 5

	beacon // warp beacon for easy z5 teleporting.
		required = 1
		maxNum = 1
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_beacon.dmm"
		prefabSizeX = 5
		prefabSizeY = 5

	outpost // rest stop/outpost for miners to eat/rest/heal at.
		required = 1
		maxNum = 1
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_outpost.dmm"
		prefabSizeX = 20
		prefabSizeY = 20

	ksol // The wreck of the old radio buoy, rip
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_ksol.dmm"
		prefabSizeX = 35
		prefabSizeY = 27

	habitat // kube's habitat thing
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_habitat.dmm"
		prefabSizeX = 25
		prefabSizeY = 20

	smuggler // kube's smuggler thing
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_smuggler.dmm"
		prefabSizeX = 19
		prefabSizeY = 18

	tomb // small little tomb
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_tomb.dmm"
		prefabSizeX = 13
		prefabSizeY = 10

	janitor // adhara's janitorial hideout
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_janitor.dmm"
		prefabSizeX = 16
		prefabSizeY = 15

	pie_ship // Urs's ship originally built for the pie eating contest event
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_pie_ship.dmm"
		prefabSizeX = 16
		prefabSizeY = 21

	bee_sanctuary_space // Sov's Bee Sanctuary (Space Variant)
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_beesanctuary.dmm"
		prefabSizeX = 41
		prefabSizeY = 24

	sequestered_cloner // MarkNstein's Sequestered Cloner
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_sequestered_cloner.dmm"
		prefabSizeX = 20
		prefabSizeY = 15

	clown_nest // Gores abandoned Clown-Federation Outpost
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_clown_nest.dmm"
		prefabSizeX = 30
		prefabSizeY = 30

	dans_asteroid // Discount Dans Delivery Asteroid featuring advanced cooling technology
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_dans_asteroid.dmm"
		prefabSizeX = 37
		prefabSizeY = 48

	drug_den // A highly cozy hideout in space; take out the stress - eat some mice sandwiches.
		maxNum = 1
		probability = 40
		prefabPath = "assets/maps/prefabs/prefab_drug_den.dmm"
		prefabSizeX = 32
		prefabSizeY = 27

	von_ricken // One way or another - an expensive space vavaction for a physical toll.
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_von_ricken.dmm"
		prefabSizeX = 42
		prefabSizeY = 40

	candy_shop // Ryn's store from out of time and out of place
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_candy_shop.dmm"
		prefabSizeX = 20
		prefabSizeY = 20

	space_casino // Lythine's casino with some dubious gambling machines
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_space_casino.dmm"
		prefabSizeX = 31
		prefabSizeY = 23

	ranch // A tiny little ranch in space
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_ranch.dmm"
		prefabSizeX = 12
		prefabSizeY = 12

	shooting_range // Nef's shooting range with an experimental ray gun
		maxNum = 1
		probability = 15
		prefabPath = "assets/maps/prefabs/prefab_gunrange.dmm"
		prefabSizeX = 19
		prefabSizeY = 22

	//UNDERWATER AREAS FOR OSHAN

	pit
		required = 1
		underwater = 1
		maxNum = 3
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_water_oshanpit.dmm"
		prefabSizeX = 8
		prefabSizeY = 8

#if defined(MAP_OVERRIDE_OSHAN)
	elevator
		required = 1
		underwater = 1
		maxNum = 1
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_water_oshanelevator.dmm"
		prefabSizeX = 11
		prefabSizeY = 11
#endif
	robotfactory
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_robotfactory.dmm"
		prefabSizeX = 20
		prefabSizeY = 28

	racetrack
		underwater = 1
		maxNum = 1
		probability = 10
		prefabPath = "assets/maps/prefabs/prefab_water_racetrack.dmm"
		prefabSizeX = 24
		prefabSizeY = 25

	zoo
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_zoo.dmm"
		prefabSizeX = 20
		prefabSizeY = 17

	outpost
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_outpost.dmm"
		prefabSizeX = 21
		prefabSizeY = 21

	sandyruins
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_sandyruins.dmm"
		prefabSizeX = 11
		prefabSizeY = 13

	greenhouse
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_greenhouse.dmm"
		prefabSizeX = 21
		prefabSizeY = 15

	genelab
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_genelab.dmm"
		prefabSizeX = 12
		prefabSizeY = 11

	beetrader
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_beetrader.dmm"
		prefabSizeX = 13
		prefabSizeY = 18

	stripmall
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_stripmall.dmm"
		prefabSizeX = 20
		prefabSizeY = 22

	blindpig
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_blindpig.dmm"
		prefabSizeX = 23
		prefabSizeY = 20

	strangeprison
		underwater = 1
		maxNum = 1
		probability = 10
		prefabPath = "assets/maps/prefabs/prefab_water_strangeprison.dmm"
		prefabSizeX = 35
		prefabSizeY = 21

	seamonkey
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_seamonkey.dmm"
		prefabSizeX = 33
		prefabSizeY = 25

	ghost_house
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_ghosthouse.dmm"
		prefabSizeX = 23
		prefabSizeY = 34

	drone_battle
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_drone_battle.dmm"
		prefabSizeX = 24
		prefabSizeY = 21

	ydrone
		underwater = 1
		maxNum = 1
		probability = 10
		prefabPath = "assets/maps/prefabs/prefab_water_ydrone.dmm"
		prefabSizeX = 15
		prefabSizeY = 15

	honk
		underwater = 1
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_water_honk.dmm"
		prefabSizeX = 24
		prefabSizeY = 22

	disposal
		underwater = 1
		maxNum = 1
		probability = 35
		prefabPath = "assets/maps/prefabs/prefab_water_disposal.dmm"
		prefabSizeX = 16
		prefabSizeY = 13

	sketchy
		underwater = 1
		maxNum = 1
		probability = 35
		prefabPath = "assets/maps/prefabs/prefab_water_sketchy.dmm"
		prefabSizeX = 21
		prefabSizeY = 15

	water_treatment // Sov's water treatment facility
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_watertreatment.dmm"
		prefabSizeX = 33
		prefabSizeY = 14

	bee_sanctuary //Sov's Bee Sanctuary
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_beesanctuary.dmm"
		prefabSizeX = 34
		prefabSizeY = 19

	danktrench //the marijuana trench
		underwater = 1
		maxNum = 1
		probability = 35
		prefabPath = "assets/maps/prefabs/prefab_water_danktrench.dmm"
		prefabSizeX = 16
		prefabSizeY = 9

	grill //test post do not bonk
		maxNum = 1
		required = 1
		prefabPath = "assets/maps/prefabs/prefab_grill.dmm"
		probability = 100
		prefabSizeX = 10
		prefabSizeY = 10

	torpedo_deposit // Torpedo deposit
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_torpedo_deposit.dmm"
		prefabSizeX = 21
		prefabSizeY = 21


#if defined(MAP_OVERRIDE_OSHAN)
	sea_miner
		underwater = 1
		maxNum = 1
		probability = 35
		prefabPath = "assets/maps/prefabs/prefab_water_miner.dmm"
		prefabSizeX = 21
		prefabSizeY = 15
#endif

	cache_small_loot
		underwater = 1
		maxNum = -1
		probability = 1
		prefabPath = "assets/maps/prefabs/prefab_water_cache_smallloot.dmm"
		prefabSizeX = 4
		prefabSizeY = 4

	cache_small_oxygen
		underwater = 1
		maxNum = -1
		probability = 1
		prefabPath = "assets/maps/prefabs/prefab_water_cache_smalloxygen.dmm"
		prefabSizeX = 4
		prefabSizeY = 4

	cache_small_skull
		underwater = 1
		maxNum = -1
		probability = 1
		prefabPath = "assets/maps/prefabs/prefab_water_cache_smallskull.dmm"
		prefabSizeX = 3
		prefabSizeY = 3

	sea_crashed
		underwater = 1
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_water_crashed.dmm"
		prefabSizeX = 24
		prefabSizeY = 32

// gehenna's prefabs go here ok.

	cave_spider
		dusty = 1
		maxNum = 3
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_cave_spider.dmm"
		prefabSizeX = 10
		prefabSizeY = 10

	cave_bread
		dusty = 1
		maxNum = 1
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_cave_bread.dmm"
		prefabSizeX = 10
		prefabSizeY = 10

	cave_meat
		dusty = 1
		maxNum = 2
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_cave_meat.dmm"
		prefabSizeX = 10
		prefabSizeY = 10

	cave_long
		dusty = 1
		maxNum = 3
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_cave_long.dmm"
		prefabSizeX = 10
		prefabSizeY = 25

	cave_wide
		dusty = 1
		maxNum = 3
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_cave_wide.dmm"
		prefabSizeX = 25
		prefabSizeY = 10

	cave_rockworms
		dusty = 1
		maxNum = 3
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_rockworms.dmm"
		prefabSizeX = 5
		prefabSizeY = 5

	cave_cannibal
		dusty = 1
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_cannibal.dmm"
		prefabSizeX = 10
		prefabSizeY = 10

	cave_stash
		dusty = 1
		maxNum = 1
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_cave_stash.dmm"
		prefabSizeX = 30
		prefabSizeY = 20

	cave_plasma
		dusty = 1
		maxNum = 2
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_cave_plasma.dmm"
		prefabSizeX = 10
		prefabSizeY = 10

	cave_farts
		dusty = 1
		maxNum = 2
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_cave_farts.dmm"
		prefabSizeX = 10
		prefabSizeY = 10

	cave_parts
		dusty = 1
		maxNum = 1
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_cave_parts.dmm"
		prefabSizeX = 25
		prefabSizeY = 25

	cave_parts2
		dusty = 1
		maxNum = 1
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_cave_parts2.dmm"
		prefabSizeX = 35
		prefabSizeY = 15

	cave_parts3
		dusty = 1
		maxNum = 1
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_cave_parts3.dmm"
		prefabSizeX = 15
		prefabSizeY = 35

	cave_landmines
		dusty = 1
		maxNum = 2
		probability = 75
		prefabPath = "assets/maps/prefabs/prefab_cave_landmines.dmm"
		prefabSizeX = 5
		prefabSizeY = 5

	cave_landmines2
		dusty = 1
		maxNum = 2
		probability = 75
		prefabPath = "assets/maps/prefabs/prefab_cave_landmines2.dmm"
		prefabSizeX = 7
		prefabSizeY = 7

	cave_jeweler
		dusty = 1
		maxNum = 0 //not lore friendly it turns out, RIP
		probability = 68
		prefabPath = "assets/maps/prefabs/prefab_cave_jeweler.dmm"
		prefabSizeX = 20
		prefabSizeY = 15

	cave_waffle //This one isn't great but the idea amused me, delete whenever you get tired of it :P
		dusty = 1
		maxNum = 1
		probability = 63
		prefabPath = "assets/maps/prefabs/prefab_cave_waffle.dmm"
		prefabSizeX = 11
		prefabSizeY = 9

	cave_closet
		dusty = 1
		maxNum = 2
		probability = 80
		prefabPath = "assets/maps/prefabs/prefab_cave_closet.dmm"
		prefabSizeX = 4
		prefabSizeY = 4

	cave_robotics
		dusty = 1
		maxNum = 1
		probability = 60
		prefabPath = "assets/maps/prefabs/prefab_cave_robotics.dmm"
		prefabSizeX = 20
		prefabSizeY = 12

	cave_star
		dusty = 1
		maxNum = 1
		probability = 60
		prefabPath = "assets/maps/prefabs/prefab_cave_star.dmm"
		prefabSizeX = 14
		prefabSizeY = 14
		required = TRUE
