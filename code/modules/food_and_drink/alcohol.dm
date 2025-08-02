
//the bottle parent to all this is an open container so just do src.flags |= OPENCONTAINER on New() if you want it to start closed (see champagne)
//35 units = 350ml =~ 12oz = regular single serve bottle (let's call this a pint)
//75 units = 750ml = fifth
//100 units = 1 litre
//175 units = 1.75 litre = handle
//left 5 units leeway for poisoning purposes

// all the stuff in fancy full-fledged bottles
/obj/item/reagent_containers/food/drinks/bottle/beer
	name = "space beer"
	desc = "Beer. in space."
	icon_state = "bottle-brown"
	item_state = "beer"
	cap_type = "cap"
	heal_amt = 1
	g_amt = 40
	bottle_style = "brown"
	label = "alcohol1"
	initial_volume = 40
	initial_reagents = list("beer"=35)

/obj/item/reagent_containers/food/drinks/bottle/beer/borg
	cap_type = null
	cap = "none"
	flags = FPRINT | TABLEPASS | OPENCONTAINER | SUPPRESSATTACK
	unbreakable = 1

/obj/item/reagent_containers/food/drinks/bottle/fancy_beer
	name = "fancy beer"
	desc = "Some kind of fancy-pants IPA or lager or ale. Some sort of beer-type thing."
	cap_type = "cap"
	icon_state = "bottle-green"
	initial_volume = 40
	initial_reagents = list("beer"=30,"ethanol"=5)

	New()
		..()
		src.real_name = "[pick_string("chemistry_tools.txt", "BOOZE_prefixes")] [pick_string("chemistry_tools.txt", "BEER_suffixes")]"
		src.UpdateName()
		bottle_style = pick("clear", "black", "barf", "brown", "red", "orange", "yellow", "green", "cyan", "blue", "purple")
		label = pick("alcohol1","alcohol2","alcohol3","alcohol4","alcohol5","alcohol6","alcohol7")
		cap = pick("alcohol1","alcohol2","alcohol3","alcohol4","alcohol5","alcohol6","alcohol7")

		var/flavors = 1
		var/adulterants = 1

		while (flavors > 0)
			flavors--
			reagents.add_reagent(pick_string("chemistry_tools.txt", "BOOZE_flavors"), rand(1,3))

		while (adulterants > 0)
			adulterants--
			reagents.add_reagent(pick_string("chemistry_tools.txt", "CYBERPUNK_drug_adulterants"), rand(1,3))

		update_icon()

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

/obj/item/reagent_containers/food/drinks/bottle/wine
	name = "wine"
	desc = "Not to be confused with pubbie tears."
	icon_state = "bottle-wine"
	cap_type = "cork"
	heal_amt = 1
	g_amt = 40
	bottle_style = "wine"
	label = "wine"
	fluid_style = "none"
	initial_volume = 80
	initial_reagents = list("wine"=75)

/obj/item/reagent_containers/food/drinks/bottle/hobo_wine
	name = "fortified wine"
	desc = "Some sort of bottom-shelf booze. Wasn't this brand banned awhile ago?"
	icon_state = "bottle-vermouth"
	cap_type = "screw"
	heal_amt = 1
	g_amt = 40
	bottle_style = "vermouth"
	fluid_style = "vermouth"
	label = "vermouth"
	alt_filled_state = 1
	var/safe = 0
	initial_volume = 80
	initial_reagents = list("wine"=60,"ethanol"=15)

	New()
		..()
		src.real_name = "[pick_string("chemistry_tools.txt", "BOOZE_prefixes")] [pick_string("chemistry_tools.txt", "WINE_suffixes")]"
		src.UpdateName()
		bottle_style = "vermouth[pick("C", "R", "O", "Y", "", "A", "B", "P")]" // clear, red, orange, green, aqua, blue, purple

		var/adulterant_safety = safe ? "CYBERPUNK_drug_adulterants_safe" : "CYBERPUNK_drug_adulterants"
		var/flavors = rand(1,3)
		var/adulterants = rand(2,4)

		if (safe)
			name = "Watered Down [name]"
			reagents.add_reagent("water", 1) // how is this safe? - this isn't the safe part, the safe part is up there ^ and down there v where it changes what chem list it uses  :v

		while (flavors > 0)
			flavors--
			reagents.add_reagent(pick_string("chemistry_tools.txt", "BOOZE_flavors"), rand(2,5))

		while (adulterants > 0)
			adulterants--
			reagents.add_reagent(pick(adulterant_safety), rand(1,3))

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

/obj/item/reagent_containers/food/drinks/bottle/hobo_wine/safe
	safe = 1

/obj/item/reagent_containers/food/drinks/bottle/champagne
	name = "Space Champagne"
	desc = "Fizzy wine used in celebrations. It's not technically space champagne if it's not made using grapes from the Champagne region of Space France."
	icon_state = "bottle-champagneG"
	bottle_style = "champagneG"
	fluid_style = "champagne"
	label = "champagne"
	cap_type = "champagne"
	alt_filled_state = 1
	heal_amt = 1
	alphatest_closecontainer = 1
	g_amt = 60
	initial_volume = 80
	initial_reagents = list("champagne"=75)
	var/makes_shards_on_break = 1

	New()
		src.close_container()
		..()

	attack(mob/M as mob, mob/user as mob, def_zone)
		if (!src.is_open_container())
			return
		..()

	//unique champagne behaviors

	//uncorking
	attack_self(mob/user as mob)
		if (src.broken)
			..()
			return
		if (!src.is_open_container())
			src.unseal(user)
			return
		..()

	//recorking
	attackby(obj/item/W as obj, mob/user as mob) //open it with an empty hand
		if (src.broken)
			..()
			return
		if (!src.is_open_container())
			if (istype(W, /obj/item/bottleopener/corkscrew))
				boutput(user, "<span class='notice'>It's too dangerous to open a bottle of a champagne with a corkscrew. Even worse, it's tacky!</span>")
				return
			if (W) //something in hand?
				boutput(user, "<span class='notice'>You gotta use your hands to pop that cork, bud!</span>")
				return
		else
			if (istype(W, /obj/item/cap/champcork))
				user.visible_message("<span class='notice'>[user] pops a cork back in \the [src].</span>", "<span class='notice'>You pop the cork back in \the [src].</span>")
				playsound(user, "sound/impact_sounds/Wood_Hit_Small_1.ogg", 50, 1)
				src.close_container()
				qdel (W)
				src.update_icon()
				return
			else if (istype(W, /obj/item/cap/cork))
				user.visible_message("<span class='notice'>This is the wrong kind of cork. Ugh!</span>")
				return
		..()

	afterattack(obj/target, mob/user, flag)
		if (!src.is_open_container())
			//if (src.unseal() != 2) //as a courtesy, sometimes things might not be open when they should be
			boutput(user, "<span class='notice'>\The [src] needs to be opened first!</span>")
			return //otherwise, done
		..()

	//the elaborate process of opening a champagne bottle
	proc/unseal(var/mob/user as mob)
		if (src.popped) //already done it, no pressure, easy
			var/obj/item/cap/champcork/C = new/obj/item/cap/champcork
			C.set_loc(src)
			user.put_in_hand_or_drop(C)
			src.open_container()
			playsound(user, "sound/impact_sounds/Wood_Hit_Small_1.ogg", 50, 1)
			user.visible_message("[user] pulls the cork out of \the [src].",\
			"<span class='notice'>You pull the cork out of \the [src]. It's not as fun as doing it the first time...]</span>")
			src.update_icon()
			return
		var/bartender_bonus = 0
		if (user.mind.assigned_role == "Bartender")
			bartender_bonus = 3 //you make this look easy and fire the cork off further for theatrics
		if (!src.shakes)
			user.visible_message("[user] shakes up \the [src] a bit!",\
			"<span class='notice'>You shake up \the [src] a bit to get it ready!</span>")
			playsound(src, "sound/items/CocktailShake.ogg", 25, 1, 2)
			src.shakes++
			return
		if (src.shakes >= rand(1,5) || bartender_bonus) //succeed at shake on prob or bartender's magic touch
			src.open_container() //open it
			src.popped = 1
			src.update_icon()
			playsound(src, "sound/items/CocktailShake.ogg", 25, 1, 3)
			user.visible_message("[user] shakes up \the [src] some more, then pops the cork! [src.shakes >= 4 ? "Finally..." : "Party time!"]",\
			"<span class='notice'>You shake up \the [src] some more and pop the cork! [src.shakes >= 4 ? "At least that's over with..." : "Alright!"]</span>")
			sleep(2)
			playsound(user, "sound/impact_sounds/Wood_Hit_Small_1.ogg", 50, 1)
			//src.splashreagents(src.loc,splashamt=(src.shakes * 2)) //leave a puddle, for when i fix and implement bottle spilling/smashing
			src.shakes = 0
			//create cork and launch it further depending on the shakes
			var/obj/item/cap/champcork/C = new/obj/item/cap/champcork
			C.set_loc(user.loc)
			C.throw_at(get_edge_target_turf(user, user.dir), (src.shakes + 2 + bartender_bonus), (3 + src.shakes))
		else
			src.shakes++
			user.visible_message("[user] tries and fails to pop the cork, then shakes up \the [src] a bit more! [src.shakes >= 4 ? "This is starting to get a little embarrassing." : null]",\
			"<span class='notice'>You can't pop the cork, so you shake up \the [src] a bit more! [src.shakes >= 4 ? "This is starting to get a little embarrassing." : null]</span>")
			return

	//renaming vehicles
	afterattack(obj/O as obj, mob/user as mob)
		if (istype(O, /obj/machinery/vehicle) || istype(O, /obj/vehicle) && user.a_intent == "harm")
			var/turf/U = user.loc
			if (src.broken)
				boutput(user, "You can't christen something with a bottle in that state! Are you some kind of unsophisticated ANIMAL?!")
				return
			if (prob(50))
				user.visible_message("<span class='alert'><b>[user]</b> hits [O] with [src], shattering it open!</span>")
				playsound(U, pick('sound/impact_sounds/Glass_Shatter_1.ogg','sound/impact_sounds/Glass_Shatter_2.ogg','sound/impact_sounds/Glass_Shatter_3.ogg'), 100, 1)
				if (makes_shards_on_break)
					var/obj/item/raw_material/shard/glass/G = new()
					G.set_loc(U)
				src.broken = 1
				src.reagents.reaction(U)
				src.create_reagents(0)
				src.update_icon()
			var/new_name = input(user, "Enter new name for [O]", "Rename [O]", O.name) as null|text
			if (isnull(new_name) || !length(new_name) || new_name == " ")
				return
			phrase_log.log_phrase("vehicle", new_name, no_duplicates=TRUE)
			logTheThing("station", user, null, "renamed [O] to [new_name] in [get_area(user)] ([showCoords(user.x, user.y, user.z)])")
			new_name = copytext(strip_html(new_name), 1, 32)
			O.name = new_name
			return
		else return ..()

	cristal_champagne
		name = "Cristal Champagne"
		desc = "Fizzy wine used in most prestigeous celebrations. It is also very famous in space hip-hip culture."
		icon_state = "bottle-champagne"
		bottle_style = "champagne"
		fluid_style = "champagne"
		label = "champagne"
		alt_filled_state = 1
		heal_amt = 1
		g_amt = 60
		initial_volume = 80
		initial_reagents = list("champagne"=75)

	breakaway_glass
		makes_shards_on_break = 0

/obj/item/reagent_containers/food/drinks/bottle/cider
	name = "cider"
	desc = "Made from apples."
	cap_type = "cap"
	icon_state = "bottle-green"
	heal_amt = 1
	g_amt = 40
	bottle_style = "green"
	label = "alcohol1"
	initial_volume = 40
	initial_reagents = list("cider"=35)

/obj/item/reagent_containers/food/drinks/bottle/rum
	name = "rum"
	desc = "Yo ho ho and all that."
	cap_type = "screw"
	bottle_style = "spicedrum"
	fluid_style = "spicedrum"
	label = "spicedrum"
	alt_filled_state = 1
	heal_amt = 1
	initial_volume = 80
	initial_reagents = list("rum"=75)

/obj/item/reagent_containers/food/drinks/bottle/mead
	name = "mead"
	desc = "A pillager's tipple."
	cap_type = "cap"
	icon_state = "bottle-barf"
	heal_amt = 1
	g_amt = 40
	bottle_style = "barf"
	label = "alcohol5"
	initial_volume = 40
	initial_reagents = list("mead"=35)

/obj/item/reagent_containers/food/drinks/bottle/vintage
	name = "2010 Vintage"
	desc = "A bottle marked '2010 Vintage'. ...wait, this isn't wine..."
	cap_type = "cork"
	icon_state = "bottle-barf"
	heal_amt = 1
	g_amt = 40
	bottle_style = "barf"
	label = "alcohol5"
	initial_volume = 80
	initial_reagents = list("urine"=75) //fuck it it's a fifth of piss

/obj/item/reagent_containers/food/drinks/bottle/vodka
	name = "vodka"
	desc = "Russian stuff. Pretty good quality."
	cap_type = "screw"
	icon_state = "bottle-vodka"
	bottle_style = "vodka"
	fluid_style = "vodka"
	label = "none"
	heal_amt = 1
	g_amt = 60
	initial_volume = 105
	initial_reagents = list("vodka"=100) //well

/obj/item/reagent_containers/food/drinks/bottle/vodka/vr
	icon_state = "vr_vodka"
	bottle_style = "vr_vodka"
	cap_type = "none"

/obj/item/reagent_containers/food/drinks/bottle/tequila
	name = "tequila"
	desc = "Guadalajara is a crazy place, man, lemme tell you."
	cap_type = "screw"
	icon_state = "bottle-tequila"
	bottle_style = "tequila"
	fluid_style = "tequila"
	label = "tequila"
	alt_filled_state = 1
	heal_amt = 1
	g_amt = 60
	initial_volume = 80
	initial_reagents = list("tequila"=75)

/obj/item/reagent_containers/food/drinks/bottle/gin
	name = "gin"
	desc = "Gin is technically just a kind of alcohol that tastes strongly of juniper berries. Would juniper-flavored vodka count as a gin?"
	cap_type = "screw"
	icon_state = "bottle-gin"
	bottle_style = "gin"
	fluid_style = "gin"
	label = "gin"
	alt_filled_state = 1
	heal_amt = 1
	g_amt = 60
	initial_volume = 80
	initial_reagents = list("gin"=75)

/obj/item/reagent_containers/food/drinks/bottle/ntbrew
	name = "NanoTrasen Brew"
	desc = "Jesus, how long has this even been here?"
	cap_type = "screw"
	icon_state = "bottle-vermouth"
	bottle_style = "vermouth"
	fluid_style = "vermouth"
	label = "vermouth"
	alt_filled_state = 1
	heal_amt = 1
	g_amt = 60
	initial_volume = 80
	initial_reagents = list("wine"=50,"charcoal"=25)

/obj/item/reagent_containers/food/drinks/bottle/thegoodstuff
	name = "Stinkeye's Special Reserve"
	desc = "An old bottle labelled 'The Good Stuff'. This probably has enough kick to knock an elephant on its ass."
	cap_type = "screw"
	icon_state = "bottle-whiskey"
	bottle_style = "whiskey"
	fluid_style = "whiskey"
	label = "whiskey"
	alt_filled_state = 1
	heal_amt = 1
	g_amt = 60
	initial_volume = 125
	initial_reagents = list("champagne"=20,"wine"=20,"cider"=20,"vodka"=20,"eyeofnewt"=40)

/obj/item/reagent_containers/food/drinks/bottle/bojackson
	name = "Bo Jack Daniel's"
	desc = "Bo knows how to get you drunk, by diddley!"
	cap_type = "screw"
	icon_state = "bottle-whiskey"
	bottle_style = "whiskey"
	fluid_style = "whiskey"
	label = "whiskey"
	alt_filled_state = 1
	heal_amt = 1
	g_amt = 40
	initial_volume = 100
	initial_reagents = "bojack"

// knickknacks for making fancy drinks

/obj/item/cocktail_stuff
	name = "cocktail doodad"
	desc = "Some kinda li'l thing to put in a cocktail. How are you seeing this?"
	icon = 'icons/obj/foodNdrink/drinks.dmi'
	flags = FPRINT | TABLEPASS
	w_class = W_CLASS_TINY
	rand_pos = 8

	drink_umbrella
		name = "drink umbrella"
		desc = "A tiny little umbrella, to put into drinks. I guess it makes you feel like you're on the beach, even when you're actually in a vomit-, piss- and blood-covered bar in the middle of some shitty dump of a space station. Maybe."
		icon_state = "umbrella1"

		New()
			..()
			src.icon_state = "umbrella[rand(1,6)]"

	maraschino_cherry
		name = "maraschino cherry"
		desc = "A sweet, vibrantly red little cherry, which has been preserved in maraschino liquer, which is made from maraschino cherries. Huh."
		icon_state = "cherry"
		edible = 1

	cocktail_olive
		name = "cocktail olive"
		desc = "An olive on a toothpick, to put in a drink. I dunno what this accomplishes for the taste of the drink, but hey, you get an olive to eat."
		icon_state = "olive"
		edible = 1

	celery
		name = "celery stick"
		desc = "A stick of celery. Does not feature ants. Unless you leave it on the floor, but those would probably not be very tasty. I dunno, though, I've never eaten an ant. They might be delicious."
		icon_state = "celery"
		edible = 1

// empty bottles

/obj/item/reagent_containers/food/drinks/bottle/empty/long
	name = "long bottle"
	desc = "A bottle shaped like the ones used to hold beer or vermouth."
	icon_state = "bottle-vermouthC"
	item_state = "vermouth"
	alt_filled_state = 1
	heal_amt = 1
	g_amt = 40
	bottle_style = "vermouthC"
	label = "label-none"
	initial_volume = 80

/obj/item/reagent_containers/food/drinks/bottle/empty/tall
	name = "tall bottle"
	desc = "A bottle shaped like the ones used to hold vodka."
	icon_state = "bottle-tvodka"
	bottle_style = "tvodka"
	fluid_style = "tvodka"
	label = "label-none"
	alt_filled_state = 1
	heal_amt = 1
	g_amt = 60
	initial_volume = 80

/obj/item/reagent_containers/food/drinks/bottle/empty/rectangular
	name = "rectangular bottle"
	desc = "A bottle shaped like the ones used to hold gin."
	icon_state = "bottle-gin"
	bottle_style = "gin"
	fluid_style = "gin"
	label = "label-none"
	alt_filled_state = 1
	heal_amt = 1
	g_amt = 60
	initial_volume = 80

/obj/item/reagent_containers/food/drinks/bottle/empty/square
	name = "square bottle"
	desc = "A bottle shaped like the ones used to hold rum."
	icon_state = "bottle-spicedrum"
	bottle_style = "spicedrum"
	fluid_style = "spicedrum"
	label = "label-none"
	alt_filled_state = 1
	heal_amt = 1
	g_amt = 60
	initial_volume = 80

/obj/item/reagent_containers/food/drinks/bottle/empty/masculine
	name = "wide bottle"
	desc = "A bottle shaped like the ones used to hold tequila."
	icon_state = "bottle-tequila"
	bottle_style = "tequila"
	fluid_style = "tequila"
	label = "label-none"
	alt_filled_state = 1
	heal_amt = 1
	g_amt = 60
	initial_volume = 80

// the non-bottle/legacy boozes
/obj/item/reagent_containers/food/drinks/rum_spaced
	name = "spaced rum"
	desc = "Rum which has been exposed to cosmic radiation. Don't worry, radiation does everything!"
	icon_state = "rum"
	heal_amt = 1
	initial_volume = 105
	initial_reagents = list("rum"=50,"yobihodazine"=50)

/obj/item/reagent_containers/food/drinks/grog
	name = "Ye Olde Grogge"
	desc = "The dusty glass bottle has caustic fumes wafting out of it. You're not sure drinking it is a good idea."
	icon_state = "moonshine"
	heal_amt = 0
	initial_volume = 105
	initial_reagents = list("grog"=100)

/obj/item/reagent_containers/food/drinks/grodyjug
	name = "grody jug"
	desc = "A dusty glass bottle containing barely-liquid of unknown age and provenance, probably unearthed in some long-forgotten crawlspace. Maybe you could offer a buddy ten credits to take a sip?"
	icon_state = "grodyjug"
	heal_amt = 0
	initial_volume = 120 //big jug
	initial_reagents = list("grime"=30,"acetone"=30,"formaldehyde"=30,"jenkem"=10)

/obj/item/reagent_containers/food/drinks/moonshine
	name = "jug of moonshine"
	desc = "A jug of an illegally brewed alchoholic beverage, which is quite potent."
	icon_state = "moonshine"
	heal_amt = 1
	rc_flags = RC_FULLNESS
	initial_volume = 250
	initial_reagents = "moonshine"

/obj/item/reagent_containers/food/drinks/curacao
	name = "curaçao liqueur"
	desc = "A bottle of curaçao liqueur, made from the dried peels of the bitter orange Lahara."
	icon_state = "curacao"
	heal_amt = 1
	rc_flags = RC_FULLNESS
	initial_volume = 80
	initial_reagents = list("curacao"=75)

/obj/item/reagent_containers/food/drinks/dehab
	name = "Dehab"
	desc = "Shake vigorously and serve with Pope Crunch."
	icon_state = "eldritch"
	gulp_size = 100
	initial_volume = 7320
	initial_reagents = list("beer"=20,"cider"=20,"mead"=20,"white_wine"=20,"wine"=20,"champagne"=20,"rum"=20,"vodka"=20,"bourbon"=20,
	"tequila"=20,"ricewine"=20,"boorbon"=20,"beepskybeer"=20,"moonshine"=20,"bojack"=20,"screwdriver"=20,"bloody_mary"=20,"bloody_scary"=20,
	"suicider"=20,"port"=20,"gin"=20,"vermouth"=20,"bitters"=20,"whiskey_sour"=20,"daiquiri"=20,"martini"=20,"v_martini"=20,
	"murdini"=20,"mutini"=20,"manhattan"=20,"libre"=20,"ginfizz"=20,"gimlet"=20,"v_gimlet"=20,"w_russian"=20,"b_russian"=20,"irishcoffee"=20,
	"cosmo"=20,"beach"=20,"gtonic"=20,"vtonic"=20,"sonic"=20,"gpink"=20,"eraser"=20,"dbreath"=20,"squeeze"=20,"madmen"=20,
	"planter"=20,"maitai"=20,"harlow"=20,"gchronic"=20,"margarita"=20,"tequini"=20,"pfire"=20,"bull"=20,"longisland"=20,"longbeach"=20,
	"pinacolada"=20,"mimosa"=20,"french75"=20,"sangria"=20,"tomcollins"=20,"peachschnapps"=20,"moscowmule"=20,"tequilasunrise"=20,"paloma"=20,
	"mintjulep"=20,"mojito"=20,"cremedementhe"=20,"freeze"=20,"negroni"=20,"necroni"=20,"bathsalts"=20,"jenkem"=360,"crank"=360,"LSD"=360, "lsd_bee"=360,"space_drugs"=360,
	"THC"=360,"nicotine"=360,"psilocybin"=360,"krokodil"=360,"catdrugs"=360,"triplemeth"=360,"methamphetamine"=360,"aranesp"=100,"capulettium"=100,
	"spiders"=100,"glitter"=100,"triplepiss"=100,"acid"=100,"clacid"=100,"cyanide"=100,"formaldehyde"=100,"itching"=100,"pacid"=100,
	"sodium_thiopental"=100,"ketamine"=100,"neurotoxin"=100,"mutagen"=100,"omega_mutagen"=100,"histamine"=100,"haloperidol"=100,"morphine"=100)
