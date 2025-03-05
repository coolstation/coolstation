ABSTRACT_TYPE(/datum/customization_style)
ABSTRACT_TYPE(/datum/customization_style/hair)
ABSTRACT_TYPE(/datum/customization_style/hair/short)
ABSTRACT_TYPE(/datum/customization_style/hair/long)
ABSTRACT_TYPE(/datum/customization_style/hair/hairup)
ABSTRACT_TYPE(/datum/customization_style/hair/gimmick)
ABSTRACT_TYPE(/datum/customization_style/moustache)
ABSTRACT_TYPE(/datum/customization_style/beard)
ABSTRACT_TYPE(/datum/customization_style/sideburns)
ABSTRACT_TYPE(/datum/customization_style/eyebrows)
ABSTRACT_TYPE(/datum/customization_style/makeup)
ABSTRACT_TYPE(/datum/customization_style/biological)


#define FEMININE 1
#define MASCULINE 2

/datum/customization_style
	var/name = null
	var/id = null
	//var/gender = 0
	/// Which mob icon layer this should go on (under or over glasses)
	var/default_layer = MOB_HAIR_LAYER1 //Under by default, more direct subtypes where that makes sense
	var/good_for_randomization = TRUE

	none
		name = "None"
		id = "none"
		//gender = MASCULINE
	hair
		default_layer = MOB_HAIR_LAYER2

		short
			afro
				name = "Afro"
				id = "afro"
			afroHR
				name = "Afro: Right Half"
				id = "afroHR"
				good_for_randomization = FALSE
			afroHL
				name = "Afro: Left Half"
				id = "afroHL"
				good_for_randomization = FALSE
			afroST
				name = "Afro: Top"
				id = "afroST"
				good_for_randomization = FALSE
			afroSM
				name = "Afro: Middle Band"
				id = "afroSM"
				good_for_randomization = FALSE
			afroSB
				name = "Afro: Bottom"
				id = "afroSB"
				good_for_randomization = FALSE
			afroSL
				name = "Afro: Left Side"
				id = "afroSL"
				good_for_randomization = FALSE
			afroSR
				name = "Afro: Right Side"
				id = "afroSR"
				good_for_randomization = FALSE
			afroSC
				name = "Afro: Center Streak"
				id = "afroSC"
				good_for_randomization = FALSE
			afroCNE
				name = "Afro: NE Corner"
				id = "afroCNE"
				good_for_randomization = FALSE
			afroCNW
				name = "Afro: NW Corner"
				id = "afroCNW"
				good_for_randomization = FALSE
			afroCSE
				name = "Afro: SE Corner"
				id = "afroCSE"
				good_for_randomization = FALSE
			afroCSW
				name = "Afro: SW Corner"
				id = "afroCSW"
				good_for_randomization = FALSE
			afroSV
				name = "Afro: Tall Stripes"
				id = "afroSV"
				good_for_randomization = FALSE
			afroSH
				name = "Afro: Long Stripes"
				id = "afroSH"
				good_for_randomization = FALSE
			balding
				name = "Balding"
				id = "balding"
			bangs
				name = "Bangs"
				id = "bangs"
			bieb
				name = "Bieber"
				id = "bieb"
			//bloom
			//	name = "Bloom"
			//	id = "bloom"
			//	gender = MASCULINE | FEMININE
			bobcut
				name = "Bobcut"
				id = "bobcut"
			baum_s
				name = "Bobcut Alt"
				id = "baum_s"
			bowl
				name = "Bowl Cut"
				id = "bowl"
			cut
				name = "Buzzcut"
				id = "cut"
			clown
				name = "Clown"
				id = "clown"
			clownT
				name = "Clown: Top"
				id = "clownT"
				good_for_randomization = FALSE
			clownM
				name = "Clown: Middle Band"
				id = "clownM"
				good_for_randomization = FALSE
			clownB
				name = "Clown: Bottom"
				id = "clownB"
				good_for_randomization = FALSE
			combed_s
				name = "Combed"
				id = "combed_s"
			combedbob_s
				name = "Combed Bob"
				id = "combedbob_s"
			chop_short
				name = "Choppy Short"
				id = "chop_short"
			einstein
				name = "Einstein"
				id = "einstein"
			einalt
				name = "Einstein: Alternating"
				id = "einalt"
			emo
				name = "Emo"
				id = "emo"
			emoH
				name = "Emo: Highlight"
				id = "emoH"
				good_for_randomization = FALSE
			flattop
				name = "Flat Top"
				id = "flattop"
			//floof
			//	name = "Floof"
			//	id = "floof"
			//	gender = FEMININE
			streak
				name = "Hair Streak"
				id = "streak"
			mohawk
				name = "Mohawk"
				id= "mohawk"
			mohawkFT
				name = "Mohawk: Fade from End"
				id = "mohawkFT"
				good_for_randomization = FALSE
			mohawkFB
				name = "Mohawk: Fade from Root"
				id = "mohawkFB"
				good_for_randomization = FALSE
			mohawkS
				name = "Mohawk: Stripes"
				id = "mohawkS"
				good_for_randomization = FALSE
			long
				name = "Mullet"
				id = "long"
			part
				name = "Parted Hair"
				id = "part"
			pomp
				name = "Pompadour"
				id = "pomp"
			pompS
				name = "Pompadour: Greaser Shine"
				id = "pompS"
				good_for_randomization = FALSE
			shortflip
				name = "Punky Flip"
				id = "shortflip"
			//spiky
			//	name = "Spiky"
			//	id = "spiky"
			//	gender = MASCULINE
			//subtlespiky
			//	name = "Subtle Spiky"
			//	id = "subtlespiky"
			//	gender = MASCULINE
			temsik
				name = "Temsik"
				id = "temsik"
			tonsure
				name = "Tonsure"
				id = "tonsure"
			short
				name = "Trimmed"
				id = "short"
			//tulip
			//	name = "Tulip"
			//	id = "tulip"
			//	gender = MASCULINE | FEMININE
			//visual
			//	name = "Visual"
			//	id = "visual"
			//	gender = MASCULINE
			shaved
				name = "Shaved"
				id = "shaved"
			croft_bangs
				name = "Bangs: Croft"
				id = "croft-bangs"
				good_for_randomization = FALSE
			doublepart_bangs
				name = "Bangs: Double-Part"
				id = "doublepart-bangs"
				good_for_randomization = FALSE
			long_bangs
				name = "Bangs: Long"
				id = "long-bangs"
				good_for_randomization = FALSE
			midb_bangs
				name = "Bangs: Mid-back"
				id = "midb-bangs"
				good_for_randomization = FALSE
			wavy_bangs
				name = "Bangs: Wavy"
				id = "wavy_tail-bangs"
				good_for_randomization = FALSE
			short_bangs
				name = "Bangs: Short"
				id = "short-bangs"
				good_for_randomization = FALSE
		long
			chub2_s
				name = "Bang: Left"
				id = "chub2_s"
				good_for_randomization = FALSE
			chub_s
				name = "Bang: Right"
				id = "chub_s"
				good_for_randomization = FALSE
			//twobangs_long
			//	name = "Two Bangs: Long"
			//	id = "2bangs_long"
			//twobangs_short
			//	name = "Two Bangs: Short"
			//	id = "2bangs_short"
			bedhead
				name = "Bedhead"
				id = "bedhead"
			disheveled
				name = "Disheveled"
				id = "disheveled"
			doublepart
				name = "Double-Part"
				id = "doublepart"
			shoulders
				name = "Draped"
				id = "shoulders"
			dreads
				name = "Dreadlocks"
				id = "dreads"
			dreadsA
				name = "Dreadlocks: Alternating"
				id = "dreadsA"
			fabio
				name = "Fabio"
				id = "fabio"
			glammetal
				name = "Glammetal"
				id = "glammetal"
			glammetalO
				name = "Glammetal: Faded"
				id = "glammetalO"
				good_for_randomization = FALSE
			eighties
				name = "Hairmetal"
				id = "80s"
			eightiesfade
				name = "Hairmetal: Faded"
				id = "80sfade"
				good_for_randomization = FALSE
			halfshavedR
				name = "Half-Shaved: Left"
				id = "halfshavedR"
			halfshaved_s
				name = "Half-Shaved: Long"
				id = "halfshaved_s"
			halfshavedL
				name = "Half-Shaved: Right"
				id = "halfshavedL"
			kingofrockandroll
				name = "Kingmetal"
				id = "king-of-rock-and-roll"
			froofy_long
				name = "Long and Froofy"
				id = "froofy_long"
			longbraid
				name = "Long Braid"
				id = "longbraid"
			longsidepart_s
				name = "Long Flip"
				id = "longsidepart_s"
			pulledb
				name = "Pulled Back"
				id = "pulledb"
			sage
				name = "Sage"
				id = "sage"
			scraggly
				name = "Scraggly"
				id = "scraggly"
			pulledf
				name = "Shoulder Drape"
				id = "pulledf"
			shoulderl
				name = "Shoulder-Length"
				id = "shoulderl"
			slightlymess_s
				name = "Shoulder-Length Mess"
				id = "slightlymessy_s"
			//smoothwave
			//	name = "Smooth Waves"
			//	id = "smoothwave"
			//	gender = FEMININE
			//smoothwave_fade
			//	name = "Smooth Waves: Faded"
			//	id = "smoothwave_fade"
			mermaid
				name = "Mermaid"
				id = "mermaid"
			//mermaidfade
			//	name = "Mermaid: Faded"
			//	id = "mermaidfade"
			midb
				name = "Mid-Back Length"
				id = "midb"
			bluntbangs_s
				name = "Mid-Length Curl"
				id = "bluntbangs_s"
			vlong
				name = "Very Long"
				id = "vlong"

			untidy
				name = "Untidy"
				id = "untidy"
		hairup
			afos //if you don't recognise this one, look up A Flock Of Seagulls
				name = "New Wave"
				id = "AFOS" //know that I could have picked Sigue Sigue Sputnik
			bun
				name = "Bun"
				id = "bun"
			sakura
				name = "Captor"
				id = "sakura"
			croft
				name = "Croft"
				id = "croft"
			indian
				name = "Double Braids"
				id = "indian"
			doublebun
				name = "Double Buns"
				id = "doublebun"
			drill
				name = "Drill"
				id = "drill"
			fun_bun
				name = "Fun Bun"
				id = "fun_bun"
			charioteers
				name = "High Flat Top"
				id = "charioteers"
			spud
				name = "High Ponytail"
				id = "spud"
			//longtailed
			//	name = "Long Mini Tail"
			//	id = "longtailed"
			//	gender = FEMININE
			lowpig
				name = "Low Pigtails"
				id = "lowpig"
			band
				name = "Low Ponytail"
				id = "band"
			minipig
				name = "Mini Pigtails"
				id = "minipig"
			pig
				name = "Pigtails"
				id = "pig"
			ponytail
				name = "Ponytail"
				id = "ponytail"
			geisha_s
				name = "Shimada"
				id = "geisha_s"
			twotail
				name = "Split-Tails"
				id = "twotail"
			wavy_tail
				name = "Wavy Ponytail"
				id = "wavy_tail"
			croft_pull // is there a better term than pulled? probably.
				name = "Pulled: Croft"
				id = "croft-pull"
			doublepart_pull
				name = "Pulled: Double-Part"
				id = "doublepart-pull"
			long_pull
				name = "Pulled: Long"
				id = "long-pull"
			midb_pull
				name = "Pulled: Mid-back"
				id = "midb-pull"
			wavy_pull
				name = "Pulled: Wavy"
				id = "wavy_tail-pull"

		gimmick
			good_for_randomization = FALSE

			afroHA
				name = "Afro: Alternating Halves"
				id = "afroHA"
			afroRB
				name = "Afro: Rainbow"
				id = "afroRB"
			bart
				name = "Bart"
				id = "bart"
			ewave_s
				name = "Elegant Wave"
				id = "ewave_s"
			flames
				name = "Flame Hair"
				id = "flames"
			goku
				name = "Goku"
				id = "goku"
			homer
				name = "Homer"
				id = "homer"
			jetson
				name = "Jetson"
				id = "jetson"
			sailor_moon
				name = "Sailor Moon"
				id = "sailor_moon"
			sakura
				name = "Sakura"
				id = "sakura"
			wiz
				name = "Wizard"
				id = "wiz"
			xcom
				name = "X-COM Rookie"
				id = "xcom"
			zapped
				name = "Zapped"
				id = "zapped"
	moustache
		fu
			name = "Biker"
			id = "fu"
		chaplin
			name = "Chaplin"
			id = "chaplin"
		dali
			name = "Dali"
			id = "dali"
		hogan
			name = "Hogan"
			id = "hogan"
		devil
			name = "Old Nick"
			id = "devil"
		robo
			name = "Robotnik"
			id = "robo"
		selleck
			name = "Selleck"
			id = "selleck"
		villain
			name = "Twirly"
			id = "villain"
		vandyke
			name = "Van Dyke"
			id = "vandyke"
		watson
			name = "Watson"
			id = "watson"
	beard
		abe
			name = "Abe"
			id = "abe"
		bstreak
			name = "Beard Streaks"
			id = "bstreak"
		braided
			name = "Braided Beard"
			id = "braided"
		chin
			name = "Chinstrap"
			id = "chin"
		fullbeard
			name = "Full Beard"
			id = "fullbeard"
		gt
			name = "Goatee"
			id = "gt"
		hip
			name = "Hipster"
			id = "hip"
		longbeard
			name = "Long Beard"
			id = "longbeard"
		//longbeardfade
		//	name = "Long Beard: Faded"
		//	id = "longbeardfade"
		motley
			name = "Motley"
			id = "motley"
		neckbeard
			name = "Neckbeard"
			id = "neckbeard"
		puffbeard
			name = "Puffy Beard"
			id = "puffbeard"
		tramp
			name = "Tramp"
			id = "tramp"
		trampstains
			name = "Tramp: Beard Stains"
			id = "trampstains"
			good_for_randomization = FALSE
	sideburns
		elvis
			name = "Elvis"
			id = "elvis"
	eyebrows
		eyebrows
			name = "Eyebrows"
			id = "eyebrows"
		thufir
			name = "Huge Eyebrows"
			id  = "thufir"
	makeup
		eyeshadow
			name = "Eyeshadow"
			id = "eyeshadow"
		lipstick
			name = "Lipstick"
			id = "lipstick"
	biological
		hetcroL
			name = "Heterochromia: Left"
			id = "hetcroL"
		hetcroR
			name = "Heterochromia: Right"
			id = "hetcroR"
		h1
			name = "Horns Style 1"
			id = "h1"
		h2
			name = "Horns Style 2"
			id = "h2"
		h3
			name = "Horns Style 3"
			id = "h3"
		h4
			name = "Horns Style 4"
			id = "h4"
		feather1
			name = "Feathers Style 1"
			id = "feather1"

proc/select_custom_style(list/datum/customization_style/customization_types, mob/living/carbon/human/user as mob)
	var/list/datum/customization_style/options = list()
	for (var/datum/customization_style/styletype as anything in customization_types)
		var/datum/customization_style/CS = new styletype
		options[CS.name] = CS
	var/new_style = input(user, "Please select style", "Style")  as null|anything in options
	return options[new_style]

proc/find_style_by_name(var/target_name)
	for (var/datum/customization_style/styletype as anything in concrete_typesof(/datum/customization_style))
		var/datum/customization_style/CS = new styletype
		if(CS.name == target_name)
			return CS
	return new /datum/customization_style/none

proc/find_style_by_id(var/target_id)
	for (var/datum/customization_style/styletype as anything in concrete_typesof(/datum/customization_style))
		var/datum/customization_style/CS = new styletype
		if(CS.id == target_id)
			return CS
	return new /datum/customization_style/none
