
/obj/decal/poster //don't use this one (or do, i'm not your dad)
	desc = "A piece of paper with an image on it. Clearly dealing with incredible technology here."
	name = "poster"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "poster"
	anchored = 1
	opacity = 0
	density = 0
	var/imgw = 600 //set this to around +10 your image's actual size or whatever size you want the window to be
	var/imgh = 400 //ditto
	var/img = "images/arts/posters/sweaterferrets.jpg" //fallback image
	var/resource = null //use html resource instead of quick and dirty html image? ex. "html/traitorTips/wizardTips.html"
	var/popup_win = 1 //wallsign root is 0 don't worry about it
	var/cat = "poster" //reuse windows, define differently if you want a separate/persistent category
	layer = EFFECTS_LAYER_BASE
	plane = PLANE_NOSHADOW_ABOVE

	examine()
		if (usr.client && src.popup_win)
			src.show_popup_win(usr)
			return ..() //someone smarter than me please tell me why we wouldn't also return the name/desc in chatbox like a usual examine
		else			//idk i think we should so im making it happen, ass hole.
			return ..()

	proc/show_popup_win(var/client/C)
		if (!C || !src.popup_win)
			return
		// wtf why is this using wizardtips... with a custom size... fuck it im leaving this one out of the centralization -singh
		//C.Browse(grabResource("html/traitorTips/wizardTips.html"),"window=antagTips;size=[imgw]x[imgh];title=Antagonist Tips")
		// miss you lots, buddy
		if (src.resource) //do we have a resource defined?
			C.Browse(grabResource("[resource]"),"window=[cat];size=[imgw]x[imgh];title=[name]")
		else //no? then it's obviously an image
			C.Browse("<html><title>[name]</title><body style='margin:2px'><img src='[resource("[img]")]'></body></html>","window=[cat];size=[imgw]x[imgh];title=[name]")
			//C.Browse("<img src=\"[resource("images/pw_map.png")]\">","window=Map;size=[imgw]x[imgh];title=Map") //marginless from pw_map, preserved as curiosity (or if i fucked up and need to put it back)

	wallsign
		desc = "A sign, on a wall. Wow!"
		icon = 'icons/obj/decals/wallsigns.dmi'
		popup_win = 0
		var/pixel_var = 0

		New()
			..()
			if (src.pixel_var)
				src.pixel_y += rand(-4,4)
				src.pixel_x += rand(-4,4)

		stencil // font: "space frigate", free and adapted by cogwerks
			name = "stencil"
			desc = ""
			icon = 'icons/obj/decals/stencils.dmi'
			alpha = 200
			pixel_y = 9
			mouse_opacity = 0
			icon_state = "a"

			// splitting this shit up into children seems easier than assigning them all in the mapmaker with varediting.
			// it'll make it way easier to assemble stencils while maintaining controlled spacing
			// this is not a monospaced font so manual adjustments are necessary after laying out text
			// should be a close-enough estimate for starters though
			// characters may fit as dublets or triplets on one turf
			// i suppose it would have been more sensical to just dump out a bunch of full words from gimp
			// instead of hand-setting a typeface inside a fucking spaceman game
			// but fuck it, this will let other mappers write whatever hull stencils they want from it. have fun?
			// going piece by piece should also make damage look more realistic, no floating words over a breach
			// i'm aligning stencils against corners, so stencils on opposite sides of an airbridge will be either l or r aligned

			left
				pixel_x = -3 //fine-tune from this offset

				a
					name = "a"
					icon_state = "a"
				b
					name = "b"
					icon_state = "b"
				c
					name = "c"
					icon_state = "c"
				d
					name = "d"
					icon_state = "d"
				e
					name = "e"
					icon_state = "e"
				f
					name = "f"
					icon_state = "f"
				g
					name = "g"
					icon_state = "g"
				h
					name = "h"
					icon_state = "h"
				i
					name = "i"
					icon_state = "i"
				j
					name = "j"
					icon_state = "j"
				k
					name = "k"
					icon_state = "k"
				l
					name = "l"
					icon_state = "l"
				m
					name = "m"
					icon_state = "m"
				n
					name = "n"
					icon_state = "n"
				o
					name = "o"
					icon_state = "o"
				p
					name = "p"
					icon_state = "p"
				q
					name = "q"
					icon_state = "q"
				r
					name = "r"
					icon_state = "r"
				s
					name = "s"
					icon_state = "s"
				t
					name = "t"
					icon_state = "t"
				u
					name = "u"
					icon_state = "u"
				v
					name = "v"
					icon_state = "v"
				w
					name = "w"
					icon_state = "w"
				x
					name = "x"
					icon_state = "x"
				y
					name = "y"
					icon_state = "y"
				z
					name = "z"
					icon_state = "z"
				one
					name = "one"
					icon_state = "1"
				two
					name = "two"
					icon_state = "2"
				three
					name = "three"
					icon_state = "3"
				four
					name = "four"
					icon_state = "4"
				five
					name = "five"
					icon_state = "5"
				six
					name = "six"
					icon_state = "6"
				seven
					name = "seven"
					icon_state = "7"
				eight
					name = "eight"
					icon_state = "8"
				nine
					name = "nine"
					icon_state = "9"
				zero
					name = "zero"
					icon_state = "0"

			right
				pixel_x = 11 // fine-tune from this offset

				a
					name = "a"
					icon_state = "a"
				b
					name = "b"
					icon_state = "b"
				c
					name = "c"
					icon_state = "c"
				d
					name = "d"
					icon_state = "d"
				e
					name = "e"
					icon_state = "e"
				f
					name = "f"
					icon_state = "f"
				g
					name = "g"
					icon_state = "g"
				h
					name = "h"
					icon_state = "h"
				i
					name = "i"
					icon_state = "i"
				j
					name = "j"
					icon_state = "j"
				k
					name = "k"
					icon_state = "k"
				l
					name = "l"
					icon_state = "l"
				m
					name = "m"
					icon_state = "m"
				n
					name = "n"
					icon_state = "n"
				o
					name = "o"
					icon_state = "o"
				p
					name = "p"
					icon_state = "p"
				q
					name = "q"
					icon_state = "q"
				r
					name = "r"
					icon_state = "r"
				s
					name = "s"
					icon_state = "s"
				t
					name = "t"
					icon_state = "t"
				u
					name = "u"
					icon_state = "u"
				v
					name = "v"
					icon_state = "v"
				w
					name = "w"
					icon_state = "w"
				x
					name = "x"
					icon_state = "x"
				y
					name = "y"
					icon_state = "y"
				z
					name = "z"
					icon_state = "z"
				one
					name = "one"
					icon_state = "1"
				two
					name = "two"
					icon_state = "2"
				three
					name = "three"
					icon_state = "3"
				four
					name = "four"
					icon_state = "4"
				five
					name = "five"
					icon_state = "5"
				six
					name = "six"
					icon_state = "6"
				seven
					name = "seven"
					icon_state = "7"
				eight
					name = "eight"
					icon_state = "8"
				nine
					name = "nine"
					icon_state = "9"
				zero
					name = "zero"
					icon_state = "0"

		chsl
			name = "CLEAN HANDS SAVE LIVES"
			desc = "A poster that reads 'CLEAN HANDS SAVE LIVES'."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "chsl"

		chsc
			name = "CLEAN HANDS SAVE CASH"
			desc = "A poster that reads 'CLEAN HANDS SAVE CASH: Today's unwashed palm is tomorrow's class action suit!'."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "chsc"

		teamwork
			name = "Team Work Makes The Team Work!"
			desc = "One of the less inspired things the poster committee ever submitted at 16:49 on a friday."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "teamwork"

		danger_highvolt
			name = "Danger: High Voltage"
			icon_state = "shock"

		medbay
			name = "Medical Bay"
			icon_state = "wall_sign_medbay"

		qm
			name = "Quartermaster's"
			icon_state = "QM"

		logistics
			name = "logistics"
			desc = "If you follow this one, you might find it pretty profitable."
			icon_state = "wall_logistics"

		logistics_right
			name = "logistics"
			icon_state = "wall_logistics_arrow_r"

		logistics_left
			name = "logistics"
			icon_state = "wall_logistics_arrow_l"

		bunks
			name = "bunks"
			desc = "If you follow this one, you might find it pretty restful."
			icon_state = "wall_bunks"

		bunks_right
			name = "bunks"
			icon_state = "wall_bunks_arrow_r"

		bunks_left
			name = "bunks"
			icon_state = "wall_bunks_arrow_l"

		cafeteria
			name = "cafeteria"
			desc = "If you follow this one, you might find it pretty delicious."
			icon_state = "wall_cafeteria"

		cafeteria_right
			name = "cafeteria"
			icon_state = "wall_cafeteria_arrow_r"

		cafeteria_left
			name = "cafeteria"
			icon_state = "wall_cafeteria_arrow_l"

		security
			name = "Security"
			icon_state = "wall_sign_security"

		engineering
			name = "Engineering"
			icon_state = "wall_sign_engineering"

		space
			name = "VACUUM AREA"
			desc = "A warning sign which reads 'EXTERNAL AIRLOCK'."
			icon_state = "space"

		construction
			name = "CONSTRUCTION AREA"
			desc = "A warning sign which reads 'CONSTRUCTION AREA'."
			icon_state = "wall_sign_danger"

		WC_blue //I tried making some desc jokes for these but I guess I'm not cut out for toilet humour
			name = "WC"
			icon_state = "WC_blue"

		WC_black
			name = "WC"
			icon_state = "WC_black"

		pool
			name = "Pool"
			icon_state = "pool"

		fire
			name = "FIRE HAZARD"
			desc = "A warning sign which reads 'FIRE HAZARD'."
			icon_state = "wall_sign_fire"

		biohazard
			name = "BIOHAZARD"
			desc = "A warning sign which reads 'BIOHAZARD'."
			icon_state = "bio"

		gym
			name = "Barkley Ballin' Gym"
			icon_state = "gym"

		barber
			name = "The Snip"
			icon = 'icons/obj/items/barber_shop.dmi'
			icon_state = "thesnip"

		bar
			name = "Bar"
			icon = 'icons/obj/stationobjs.dmi'
			icon_state = "barsign"

		coffee
			name ="Coffee Shop"
			desc = "A cute little coffee cup poster."
			icon = 'icons/obj/foodNdrink/espresso.dmi'
			icon_state ="fancycoffeecup"

		magnet
			name = "ACTIVE MAGNET AREA"
			desc = "A warning sign. I guess this area is dangerous."
			icon_state = "wall_sign_mag"

		cdnp
			name = "CRIME DOES NOT PAY"
			desc = "A warning sign which suggests that you reconsider your poor life choices."
			icon_state = "crime"

		dont_panic
			name = "DON'T PANIC"
			desc = "A sign which suggests that you remain calm, as everything is surely just fine."
			icon_state = "centcomfail"
			New()
				..()
				icon_state = pick("centcomfail", "centcomfail2")

		fudad
			name = "Arthur Muggins Memorial Jazz Lounge"
			desc = "In memory of Arthur \"F. U. Dad\" Muggins, the bravest, toughest Vice Cop SS13 has ever known. Loved by all. R.I.P."
			icon_state = "rip"

		escape
			name = "ESCAPE"
			desc = "Follow this to find Escape! Or fire. Or death. One of those."
			icon_state = "wall_escape"

		escape_left
			name = "ESCAPE"
			desc = "Follow this to find Escape! Or fire. Or death. One of those."
			icon_state = "wall_escape_arrow_l"

		escape_right
			name = "ESCAPE"
			desc = "Follow this to find Escape! Or fire. Or death. One of those."
			icon_state = "wall_escape_arrow_r"

		medbay_text
			name = "MEDICAL BAY"
			desc = "Follow this to find Medbay! Or fire. Or death. One of those."
			icon_state = "wall_medbay"

		medbay_left
			name = "MEDICAL BAY"
			desc = "Follow this to find Medbay! Or fire. Or death. One of those."
			icon_state = "wall_medbay_arrow_l"

		medbay_right
			name = "MEDICAL BAY"
			desc = "Follow this to find Medbay! Or fire. Or death. One of those."
			icon_state = "wall_medbay_arrow_r"

		security_wall
			name = "SECURITY"
			desc = "Follow this to find Security! Or fire. Or death. One of those."
			icon_state = "wall_security"

		security_left
			name = "SECURITY"
			desc = "Follow this to find Security! Or fire. Or death. One of those."
			icon_state = "wall_security_arrow_l"

		security_right
			name = "SECURITY"
			desc = "Follow this to find Security! Or fire. Or death. One of those."
			icon_state = "wall_security_arrow_r"

		submarines
			name = "SUBMARINES"
			desc = "Follow this to find Submarines! Or fire. Or death. One of those."
			icon_state = "wall_submarines"

		submarines_left
			name = "SUBMARINES"
			desc = "Follow this to find Submarines! Or fire. Or death. One of those."
			icon_state = "wall_submarines_arrow_l"

		submarines_right
			name = "SUBMARINES"
			desc = "Follow this to find Submarines! Or fire. Or death. One of those."
			icon_state = "wall_submarines_arrow_r"

		hazard_stripe
			name = "hazard stripe"
			desc = ""
			icon_state = "stripe"

		hazard_caution
			name = "CAUTION"
			icon_state = "wall_caution"

		hazard_danger
			name = "DANGER"
			icon_state = "wall_danger"

		hazard_bio
			name = "BIOHAZARD"
			icon_state = "wall_biohazard"

		hazard_rad
			name = "RADIATION"
			icon_state = "wall_radiation"

		hazard_exheat
			name = "EXTREME HEAT"
			icon_state = "wall_extremeheat"

		hazard_electrical
			name = "ELECTRICAL HAZARD"
			icon_state = "wall_electricalhazard"

		hazard_hotloop
			name = "HOT LOOP"
			icon_state = "wall_hotloop"

		hazard_coldloop
			name = "COLD LOOP"
			icon_state = "wall_coldloop"

		aarea
			name = "area information sign"
			desc = "A sign that lets you know that this is, in fact, a area."
			icon_state = "wall_area"
			popup_win = 1
			imgw = 185
			imgh = 235
			img = "images/arts/posters/sign-area.jpg"

		poster_hair
			name = "Fabulous Hair!"
			desc = "There's a bunch of ladies with really fancy hair pictured on this."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_hair"

		poster_idiotbastard
			name = "Strange poster"
			desc = "You have no idea what the hell this is."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "idiotbastard"
			popup_win = 1
			imgw = 645
			imgh = 545
			img = "images/arts/posters/idiot-bastard.jpg"

		poster_delari
			name = "Framed portrait"
			desc = "Thanks for the fun, friend."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "delari"
			popup_win = 1
			imgw = 360
			imgh = 410
			img = "images/arts/posters/delari-by-killfrenzy.png"

		poster_cool
			name = "cool poster"
			desc = "There's a couple people pictured on this poster, looking pretty cool."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_cool3"
			random_icon_states = list("wall_poster_cool", "wall_poster_cool2", "wall_poster_cool3")

		poster_human
			name = "poster"
			desc = "There's a person pictured on this poster. Some sort of celebrity."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_human"
			//todo: implement procedural celebrities

		poster_borg
			name = "poster"
			desc = "There's a cyborg pictured on this poster, but you aren't really sure what the message is. Is it trying to advertise something?"
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_borg"

		poster_sol
			name = "poster"
			desc = "There's a star and the word 'SOL' pictured on this poster."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_sol"

		poster_clown
			name = "poster"
			desc = "There's a clown pictured on this poster."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_clown"

		poster_nt
			name = "\improper NanoTrasen poster"
			desc = "A cheerful-looking version of the NT corporate logo."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_nt"

		poster_ptoe
			name = "periodic table of elements"
			desc = "A chart listing all known chemical elements."
			icon_state = "ptoe"

		poster_y4nt
			name = "\improper NanoTrasen recruitment poster"
			desc = "A huge poster that reads 'I want YOU for NT!'"
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "you_4_nt"
			imgw = 365
			imgh = 450

		poster_y4ntshitty
			name = "\improper NanoTrasen recruitment poster"
			desc = "SOMEONE has a passion for graphic design. Fuck..."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "you_4_nt"
			popup_win = 1
			imgw = 365
			imgh = 450
			img = "images/arts/posters/y4nt-shitty.jpg"

		poster_tiger
			name = "tiger poster"
			desc = "Wow, it's free! Totally worth it!"
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "tiger"
			popup_win = 1
			imgw = 410
			imgh = 275
			img = "images/arts/posters/tiger.png"

		newspaper_gg
			name = "newspaper clipping"
			desc = "Whoever pinned this to the wall went to the trouble to cut off all the margins."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "gg"
			popup_win = 1
			imgw = 1252
			imgh = 1765
			img = "images/arts/posters/gg.png"

		pope_portrait
			name = "portrait of the Pope"
			desc = "An official press photo of His Eminence Nosferatu IV, put out by the Space Holy See."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "pope"
			popup_win = 1
			imgw = 199
			imgh = 262
			img = "images/arts/posters/pope.jpg"

		circulatory
			name = "anatomical poster"
			desc = "Is... that accurate?"
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "circulatory"
			popup_win = 1
			imgw = 275
			imgh = 574
			img = "images/arts/posters/circulatory.jpg"

		poster_beach
			name = "beach poster"
			desc = "Sun, sea, and sand! Just visit VR."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_beach"

		poster_discount
			name = "grimy poster"
			desc = "Buy Discount Dans! Now legally food."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_discount"

		poster_octocluwne
			name = "spooky poster"
			desc = "Coming to theatres this summer: THE OCTOCLUWNE FROM MARS!"
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_octocluwne"

		poster_eyetest
			name = "eye chart"
			desc = "It's hard to make out anything. You're at a loss as to what even the first letter is." //heh
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_eyetest"

		poster_rand
			name = "poster"
			desc = "You aren't really sure what the message is. Is it trying to advertise something?"
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_cool3"
			pixel_var = 1
			random_icon_states = list("wall_poster_cool",
																"wall_poster_cool2",
																"wall_poster_cool3",
																"wall_poster_hair",
																"wall_poster_human",
																"wall_poster_borg",
																"wall_poster_sol",
																"wall_poster_clown",
																"wall_poster_beach",
																"wall_poster_discount",
																"wall_poster_octocluwne",
																"wall_poster_eyetest")

		poster_mining
			name = "mining poster"
			desc = "Seems like the miners union is planning yet another strike.."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_mining"

		portrait_scientist
			name = "portrait"
			desc = "It's a portrait of a rather famous plasma scientist, Sawa Hiromi."
			icon_state = "portrait_scientist"

		warning1
			name = "warning sign"
			desc = "A sign warning you of something."
			icon_state = "wall_warning1"

		warning2
			name = "warning sign"
			desc = "A sign warning you of something."
			icon_state = "wall_warning2"

		warning3
			name = "warning sign"
			desc = "A sign warning you of something."
			icon_state = "wall_warning3"

		warning4
			name = "warning sign"
			desc = "A sign warning you of something."
			icon_state = "wall_warning4"

		statistics1
			name = "statistics poster"
			desc = "A poster with a bar chart depicting the rapid growth of chemistry lab related explosions. Although who the fuck even uses a bar chart when you could be using a line chart.."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_statistics1"

		statistics2
			name = "statistics poster"
			desc = "A poster with a line chart depicting the rapid growth of artifact lab related accidents."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_statistics2"

		newtonscrew
			name = "Newtons Crew Memorial Plaque"
			desc = "In memory of the first to go where none had gone before. Sailor Dave,  Faffotron, Bethany Parks, Jake Marshall, Luis Smith, Monte Lowe, Parker Unk, Ygor Savage, Valterak Balmue, Jenny Antonsson, Edison Lootin,"
			icon_state = "rip"

		testsubject
			name = "Anatomy of a test subject"
			desc = "This poster showcases all of the weak points of a monkey test subject. Sadly it does not have any weak points."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "testsubject"

		mantaposter
			name = "NSS Manta poster"
			desc = "The NSS Manta was a piece of shit and sunk!"
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "mantaposter"

		ritossign
			name = "Rito's sign"
			desc = "A sign for Rito's Italian Ices, that water ice place. Didn't they go out of business years ago?"
			icon = 'icons/obj/decals/wallsigns.dmi'
			icon_state = "ritoslogo"

		teaparty
			name = "Weird poster"
			desc = "Seems to be a poster of some sort."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "teaparty"

			New()
				..()

				var/which = pick(
					// old contest winners
					10;"tea1",
					10;"tea2",
					10;"tea3",
					// the fuck II poster
					50;"fuckII",
					// new contest winners
					//50;"contest1",
					//50;"contest2",
					30;"contest3",
					30;"contest4",
					//50;"contest5",
					// new contest not-winners but cool nonetheless
					//15 ;"contest-other1",
					10 ;"contest-other2",
					15 ;"contest-other3",
					//15 ;"contest-other4",
					15 ;"contest-other5",
					15 ;"contest-other6",
					15 ;"contest-other7"
					)
				switch(which)
					if("tea1")
						src.name = "Tea Hell and Back"
						src.desc = "<i>Starring Camryn Stern, Edgar Palmer, Ryan Yeets, Jebediah Hawkins, and Frederick Cooper.</i>"
					if("tea2")
						src.icon_state = "teaparty2"
						src.name = "It Came from the Void"
						src.desc = "<i>Starring William Carr, Bruce Isaman, and Julio Hayhurst.</i>"
					if("tea3")
						src.icon_state = "teaparty3"
						src.name = "Afterlife Activity"
						src.desc = "<i>Starring Marmalade Addison, Lily White, cockroach, and Darcey Paynter.</i>"
					if("fuckII")
						src.name = "\proper fuck II"
						src.desc = "A poster for \"<em>fuck II: Plumb Fuckled.\"</em>"
						src.icon_state = "fuckII"/*
					if("contest1")
						src.name = "Explore the Trench"
						src.icon_state = "explore_the_trench"
					if("contest2")
						src.name = "🐟"
						src.icon_state = "fish_hook"*/
					if("contest3")
						src.name = "Bird Up!"
						src.icon_state = "bird_up"
					if("contest4")
						src.name = "A New You"
						src.icon_state = "a_new_you"/*
					if("contest5")
						src.name = "Work! Ranch"
						src.icon_state = "work_ranch"*/
					/*if("contest-other1") 	- This one and "Join Us For Boom" disabled cause it's not FOSS syndies but also, why the hell does NT allow nukeop recruitment posters?
						src.name = "Pack Smart"
						src.icon_state = "pack_smart"*/
					if("contest-other2")
						src.name = "Grow 420 Weed"
						src.icon_state = "grow_weed"
					if("contest-other3")
						src.name = "Edit Wiki"
						src.icon_state = "edit_wiki"
					/*if("contest-other4")
						src.name = "Join Us For Boom"
						src.icon_state = "join_us_for_boom"*/
					if("contest-other5")
						src.name = "Grow Food Not Weed"
						src.icon_state = "grow_food_not_weed"
					if("contest-other6")
						src.name = "More Laser Power"
						src.icon_state = "more_laser_power"
					if("contest-other7")
						src.name = "Code"
						src.icon_state = "code"

			attack_hand(mob/user)
				. = ..()
				switch(src.icon_state)
					if("code")
						user << link("https://github.com/coolstation/coolstation")
					if("edit_wiki")
						user << link("https://wiki.coolstation.space/")

		fuck1 //do not add this to the random sign rotation, fuck I is a long-lost relic overshadowed entirely by its successor
			name = "\proper fuck"
			desc = "No... it can't be... the original?! This is a vintage!!"
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "fuckI"

		fuck2
			name = "\proper fuck II"
			desc = "A poster for \"<em>fuck II: Plumb Fuckled.\"</em>"
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "fuckII"

		bookcase
			name = "bookcase"
			desc = "A bookcase filled to the brim with marvelous works of lit-... Hey! This is just bookcase wallpaper!"
			icon = 'icons/turf/adventure.dmi'
			icon_state = "bookcase_full_wall"
			pixel_y = -4
			layer = 3


		landscape
			desc = "A beautiful painting of a landscape that is engulfed by flames."
			name = "painting"
			icon = 'icons/obj/large/64x32.dmi'
			icon_state = "landscape"

		garbagegarbssign
			desc = "Come down over to Garbage Garbs, we've got both garbs -AND- garbage!"
			name = "Garbage Garbs sign"
			icon = 'icons/effects/96x32.dmi' //Maybe not the best place but it was the only ready 96x32 dmi
			icon_state = "garbagegarbs"
			bound_width  = 96

		schweewasign
			desc = "Schweewa. Fresh Smokes Prescribed To Order."
			name = "Schweewa sign"
			icon = 'icons/effects/96x32.dmi' //Maybe not the best place but it was the only ready 96x32 dmi
			icon_state = "schweewa"
			bound_width  = 96

		fuq3
			desc = "Our premier line of clothing is so diverse, you'll be sure to cry 'What le fuq?'"
			name = "Fuq III"
			icon = 'icons/effects/96x32.dmi'
			icon_state = "fuq3"
			bound_width  = 96
			plane = -99

		/* Be gay, do crime */
		pride
			name = "pride poster"
			icon = 'icons/obj/items/prideflags.dmi'
			icon_state = "poster_pride1"
			desc = "Be Gay, Do Crime!"

		pride/random
			icon_state = "random_pride"
			New()
				..()
				icon_state = "poster_pride[rand(1,14)]"

		pride/agender
			name = "Agender Pride"
			icon_state = "poster_pride2"
		//	desc = "Proudly gender-free!"

		pride/aromantic
			name = "Aromantic Pride"
			icon_state = "poster_pride3"
		//	desc = "No romantic attraction? No problem!"

		pride/asexual
			name = "Asexual Pride"
			icon_state = "poster_pride4"
		//	desc = "Folks who don't experience sexual attraction are pretty damn cool, y'know!"

		pride/bisexual
			name = "Bisexual Pride"
			icon_state = "poster_pride5"
		//	desc = "Proudly Bi!"

		pride/genderfluid
			name = "Genderfluid Pride"
			icon_state = "poster_pride6"
		//	desc = "Change your gender more often than your socks? You're pretty cool in my book."

		pride/genderqueer
			name = "Genderqueer Pride"
			icon_state = "poster_pride7"
		//	desc = "Gender is malleable, mould your own today!"

		pride/intersex
			name = "Intersex Pride"
			icon_state = "poster_pride8"
		//	desc = "Born outside the neatly labelled boxes, and refusing to be confined to one."

		pride/lesbian
			name = "Lesbian Pride"
			icon_state = "poster_pride9"
		/*	desc = "\"Jean is a nice person. She happens to like girls instead of guys. \
			Some people like cats instead of dogs! Frankly, I'd rather live with a lesbian \
			than a cat. Unless the lesbian sheds; that, I don't know.\""*/

		pride/nonbinary
			name = "NonBinary Pride"
			icon_state = "poster_pride10"
		//	desc = "Clear of mind; Pure of heart; None of binary"

		pride/pansexual
			name = "Pansexual Pride"
			icon_state = "poster_pride11"
		//	desc = "Proudly attracted to people regardless of sex or gender!"

		pride/polysexual
			name = "Polysexual Pride"
			icon_state = "poster_pride12"
		//	desc = "Attraction to many, or all, genders? Right on!"

		pride/transgender
			name = "Transgender Pride"
			icon_state = "poster_pride13"
		//	desc = "Who you are comes from inside, and you get to say who that is."

		pride/queer_villain
			name = "Queer Villain Pride"
			icon_state = "poster_pride14"
		/*	desc = "Chaos, and rebellion, against an oppressive -- and, quite frankly, \
				incredibly boring -- status quo! Passion, community, queer history, \
				... and EVIL! MWAHAHAHA!"*/
		pride/italian
			name = "Italian Pride"
			icon_state = "poster_pride15"

///////////////////////////////////////
// HATSUNE MIKU'S HEAD OF DEPARTMENT ITEMS// + FIREBARRAGE HELPED TOO BUT HE SMELLS
///////////////////////////////////////

		framed_award
			name = "A framed award"
			desc = "Just some generic award"
			var/award_text = null
			var/obj/item/award_type = /obj/item/rddiploma
			var/award_name ="diploma"
			var/usage_state = 0		// 0 = GLASS, AWARD 1 = GLASS OFF, AWARD IN CASE, 2 = GLASS OFF, AWARD GONE,
			var/owner_job = "Research Director"
			var/icon_glass = "rddiploma1"
			var/icon_award = "rddiploma"
			var/icon_empty = "frame"
			icon_state = "rddiploma"
			pixel_y = -6

			New()
				..()
				var/obj/item/M = new award_type(src.loc)
				M.desc = src.desc
				src.contents.Add(M)

			get_desc()
				if(award_text)
					return award_text
				else
					// Do we have a player of the right job?
					for(var/mob/living/carbon/human/player in mobs)
						if(!player.mind)
							continue
						if(player.mind.assigned_role == owner_job)
							award_text = src.get_award_text(player.mind)
							return award_text


			attack_hand(mob/user as mob)
				if (user.stat || isghostdrone(user) || !isliving(user))
					return

				switch (usage_state)
					if (0)
						if (issilicon(user)) return
						src.usage_state = 1
						src.icon_state = icon_glass
						user.visible_message("[user] takes off the glass frame.", "You take off the glass frame.")
						var/obj/item/sheet/glass/G = new /obj/item/sheet/glass()
						G.amount = 1
						src.add_fingerprint(user)
						user.put_in_hand_or_drop(G)

					if (1)
						playsound(src.loc, "sound/machines/click.ogg", 50, 1)
						var/obj/item/award_item = locate(award_type) in src
						if(award_item)
							if(award_text)
								award_item.desc = src.award_text
							else
								award_item.desc = src.desc

							user.put_in_hand_or_drop(award_item)
							user.visible_message("[user] takes the [award_name] from the frame.", "You take the [award_name] out of the frame.")
							src.icon_state = icon_empty
							src.add_fingerprint(user)
							src.usage_state = 2

			attackby(obj/item/W as obj, mob/user as mob)
				if (user.stat)
					return

				if (src.usage_state == 2)
					if (istype(W, award_type))
						playsound(src.loc, "sound/machines/click.ogg", 50, 1)
						user.u_equip(W)
						W.set_loc(src)
						user.visible_message("[user] places the [award_name] back in the frame.", "You place the [award_name] back in the frame.")
						src.usage_state = 1
						src.icon_state = icon_glass

				if (src.usage_state == 1)
					if (istype(W, /obj/item/sheet/glass))
						if (W.amount >= 1)
							playsound(src.loc, "sound/machines/click.ogg", 50, 1)
							user.u_equip(W)
							qdel(W)
							user.visible_message("[user] places glass back in the frame.", "You place the glass back in the frame.")
							src.usage_state = 0
							src.icon_state = icon_award


			proc/get_award_text(var/datum/mind/M)
				. = "Awarded to some chump for achieving something."

		framed_award/hos_medal
			name = "framed medal"
			desc = "A dusty old war medal."
			award_type = /obj/item/clothing/suit/hosmedal/
			award_name = "medal"
			owner_job = "Head of Security"
			icon_glass = "medal1"
			icon_award = "medal"
			icon_empty = "frame"
			icon_state = "medal"

			attackby(obj/item/W as obj, mob/user as mob)
				if (user.stat)
					return

				if (istype(W, /obj/item/diary))
					var/obj/item/paper/book/from_file/space_law/first/newbook = new /obj/item/paper/book/from_file/space_law/first
					user.u_equip(W)
					user.put_in_hand_or_drop(newbook)
					boutput(user, "<span class='alert'>Beepsky's private journal transforms into Space Law 1st Print.</span>")
					qdel(W)

				..()

			get_award_text(var/datum/mind/M)
				var/hosname = "Anonymous"
				if(M?.current?.client?.preferences?.name_last)
					hosname = M.current.client.preferences.name_last
				var/hosage = 50
				if(M?.current?.bioHolder?.age)
					hosage = M.current.bioHolder.age
				. = "Awarded to [pick("Pvt.","Sgt","Cpl.","Maj.","Cpt.","Col.","Gen.")] "
				. += "[hosname] for [pick("Outstanding","Astounding","Incredible")] "
				. += "[pick("Bravery","Courage","Sneakiness","Competence","Participation","Robustness")] in the "
				. += "[pick("Great","Scary","Bloody","")] [pick("War","Battle","Massacre","Riot","Kerfuffle","Undeclared Conflict")] of "
				. += "'[(CURRENT_SPACE_YEAR - rand((hosage - 18),hosage)) % 100]."

		framed_award/firstbill
			name = "framed space currency"
			desc = "A single bill of space currency."
			award_type = /obj/item/firstbill/
			award_name = "first bill"
			owner_job = "Head of Personnel"
			icon_glass = "hopcredit1"
			icon_award = "hopcredit"
			icon_empty = "frame"
			icon_state = "hopcredit"

			get_award_text(var/datum/mind/M)
				var/hopname = "Anonymous"
				if(M?.current?.client?.preferences?.name_last)
					hopname = M.current.client.preferences.name_last
				. = "The first [pick("Space","NT", "Golden","Silver")] "
				. += "[pick("Dollar","Doubloon","Buck","Peso","Credit")] earned by [hopname] "
				. += "for selling a [pick("Amazing","Mediocre","Suspicious","Quality","Decent","Odd")] "
				. += "[pick("Time share","Hamburger", "Clown shoe","Corporate secrets")]"

		framed_award/rddiploma
			name = "research directors diploma"
			desc = "A fancy space diploma."
			award_type = /obj/item/rddiploma/

			get_desc(dist)
				if(award_text)
					return award_text
				if (dist <= 1 & prob(50))
					. += ".. Upon closer inspection this degree seems to be fake! Who could have guessed!"
				else
					// Do we have a rd?
					..()

			get_award_text(var/datum/mind/M)
				var/rdname = "Anonymous"
				if(M?.current?.client?.preferences?.name_last)
					rdname = M.current.client.preferences.name_last
				. += "It says \ [rdname] has been awarded the degree of [pick("Associate", "Bachelor")] of [pick("arts","science")] "
				. += "Master of [pick("arts","science")], "
				. += "in [pick("Superstition","Quantum","Avian","Simian","Relative","Absolute","Computational","Philosophical","Practical","Inadvisably-applied","Impractical","Hyper", "Mega", "Giga", "Probabilistic")] [pick("Physics","Astronomy","Plasmatology", "Astrology","Cosmetology", "Dentistry","Botany","Science","Ologylogy","Wumbology")].\""

		framed_award/mdlicense
			name = "medical directors medical license"
			desc = "There's just no way this is real."
			award_name = "medical license"
			owner_job = "Medical Director"
			icon_glass = "mdlicense1"
			icon_award = "mdlicense"
			icon_empty = "frame"
			icon_state = "mdlicense"

			get_award_text(var/datum/mind/M)
				var/mdname = "Anonymous"
				if(M?.current?.client?.preferences?.name_last)
					mdname = M.current.client.preferences.name_last
				. += "It says \ [mdname] has been granted a license as a Physician and Surgeon entitled to practice the profession of medicine in space."

		framed_award/captaindiploma
			name = "Captain's old clown-college diploma."
			desc = "A faded clown-college diploma, this must be ancient!"
			award_type = /obj/item/toy/diploma
			icon_glass = "capdiploma"
			icon_award = "capdiploma1"
			icon_state = "capdiploma1"
			owner_job  = "Captain"

			get_award_text(var/datum/mind/M)
				var/capname = "someone, the name has been [pick("smeared quite badly", "erased", "scribbled out")],"
				if(M?.current?.client?.preferences?.name_last)
					capname = M.current.client.preferences.name_last
				. += "It says \ [capname] has been awarded a Bachelor of [pick("Farts", "Fards")] Degree for the study of [pick("slipology", "jugglemancy", "pie science", "bicycle horn accoustics", "comic sans calligraphy", "gelotology", "flatology", "nuclear physics", "goonstation coder")]! It appears to be written in faded crayon."

/obj/decal/poster/wallsign/pod_build
	name = "\improper How to Build a Space Pod"
	icon = 'icons/obj/decals/posters_64x32.dmi'
	icon_state = "nt-pod-poster"
	popup_win = 1
	resource = "html/how_to_build_a_pod.html"
	cat = "how_to_build_a_pod"

/obj/decal/poster/wallsign/hypothermia
	name = "repulsive public service poster"
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "frostbite"
	popup_win = 1
	imgw = 690
	imgh = 570
	img = "images/arts/posters/hypothermia.jpg"

/obj/decal/poster/wallsign/recremation
	name = "recremation LCD sign"
	desc = "Recreational cremation promises to be festive, yet solemn."
	icon = 'icons/obj/decals/posters_64x32.dmi'
	icon_state= "recremation"

/obj/decal/poster/wallsign/gunsmithing
	name = "basic firearm maintenance"
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "gunse"
	popup_win = 1
	imgw = 650
	imgh = 200
	img = "images/arts/posters/gunsmithing.jpg"

/obj/decal/poster/wallsign/pod_build/nt
	icon_state = "nt-pod-poster"
/obj/decal/poster/wallsign/pod_build/sy
	icon_state = "sy-pod-poster"

/obj/decal/poster/wallsign/pw_map
	name = "Map"
	desc = "A map affixed to the wall!'."
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "pw_map"
	popup_win = 1
	imgw = 702
	imgh = 702
	img = "images/pw_map.png"
	cat = "map"

/obj/decal/poster/wallsign/dont_drugs
	name = "Anti-drug poster"
	desc = "A poster warning against the dangers of drug use."
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "ddd"

/obj/decal/poster/wallsign/dont_drugs/do_drugs
	name = "Anti-Anti-drug poster"
	desc = "A poster that once warned against the dangers of drug use."
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "dd"

/obj/decal/poster/wallsign/wktv
	name = "WKTV logo"
	desc = "the WKTV logo printed on a shitty carpet"
	icon = 'icons/obj/decals/posters_64x32.dmi'
	icon_state = "wktv"
	plane = PLANE_NOSHADOW_BELOW
	layer = TURF_LAYER


/obj/decal/poster/banner
	name = "banner"
	desc = "An unfinished banner, try adding some color to it by using a crayon!"
	icon = 'icons/obj/decals/banners.dmi'
	icon_state = "banner_base"
	popup_win = 0
	var/colored = FALSE
	var/chosen_overlay
	var/static/list/choosable_overlays = list("Horizontal Stripes","Vertical Stripes","Diagonal Stripes","Cross","Diagonal Cross","Full","Full Gradient",
	"Left Line","Middle Line","Right Line","Northwest Line","Northeast Line","Southwest Line","Southeast Line","Big Ball","Medium Ball","Small Ball",
	"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9","+","-","=")

	proc/clear_banner()
		if (src.material)
			src.color = src.material.color
		else
			src.color = "#ffffff" // In case the material is null
		src.overlays = null
		src.colored = FALSE
		usr.visible_message("<span class='alert'>[usr] clears the [src.name].</span>", "<span class='alert'>You clear the [src.name].</span>")

	New()
		. = ..()
		var/image/banner_holder = image(src.icon, "banner_holder")
		banner_holder.appearance_flags = RESET_COLOR
		src.underlays.Add(banner_holder)

	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/pen/crayon))
			if(src.colored)
				chosen_overlay = tgui_input_list(user, "What do you want to draw?", "Drawings Options", choosable_overlays)
				if (!chosen_overlay) return
				var/mutable_appearance/new_overlay = mutable_appearance(src.icon, chosen_overlay)
				new_overlay.appearance_flags = RESET_COLOR
				new_overlay.color = W.color
				src.overlays.Add(new_overlay)
				logTheThing("station", user, null, "Drew a [chosen_overlay] in the [src] with [W] at [log_loc(user)].")
				desc = "A banner, colored and decorated"
				if(istype(W,/obj/item/pen/crayon/rainbow))
					var/obj/item/pen/crayon/rainbow/R = W
					R.font_color = random_saturated_hex_color(1)
					R.color_name = hex2color_name(R.font_color)
					R.color = R.font_color

			else
				src.color = W.color
				src.colored = TRUE
				desc = "A colored banner, try adding some drawings to it with a crayon!"

		if(istool(W,TOOL_SNIPPING | TOOL_CUTTING | TOOL_SAWING))
			user.visible_message("<span class='alert'>[user] cuts off the [src.name] with [W].</span>", "<span class='alert'>You cut off the [src.name] with [W].</span>")
			var/obj/item/material_piece/cloth/C = new(user.loc)
			if (src.material) C.setMaterial(src.material)
			else C.setMaterial(getMaterial("cotton")) // In case the material is null
			qdel(src)

	MouseDrop(atom/over_object, src_location, over_location)
		..()
		if (usr.stat || usr.restrained() || !can_reach(usr, src))
			return

		else
			if(alert(usr, "Are you sure you want to clear the banner?", "Confirmation", "Yes", "No") == "Yes")
				clear_banner()
			else
				return
