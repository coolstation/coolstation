/area/centcom
	name = "Centcom"
	icon_state = "purple"
	requires_power = 0
	sound_environment = EAX_LIVINGROOM
	teleport_blocked = 1
	skip_sims = 1
	sims_score = 25
	sound_group = "centcom"
	filler_turf = "/turf/nicegrass/random"
	is_centcom = 1
	is_construction_allowed = FALSE
	is_atmos_simulated = 1 // why dont we try this out btw

//current team
/area/centcom/offices
	name = "NT Offices"
	icon_state = "red"
	var/ckey = ""

	atomicthumbs
		ckey = ""
		name = "Office of Atomicthumbs"
	batelite
		ckey = "roselace"
		name = "Here Be Bats"
	bubs
		ckey = "insanoblan"
		name = "Office of bubs"
	cogwerks
		ckey = "drcogwerks"
		name = "Office of Cogwerks"
	crimes
		ckey = "warc"
		name = "Office of Warcrimes"
	dions
		ckey = "dionsu"
		name = "Office of Dions"
	delari
		ckey = "magicmountain"
		name = "Office of Delari"
	emarl
		ckey = ""
		name = "Office of Emarl"
	klushy
		ckey = "klushy225"
		name = "Office of Klushy"
	pope
		ckey = "popecrunch"
		name = "Office of Popecrunch"
	reginaldhj
		ckey = "reginaldhj"
		name = "Office of ReginaldHJ"
	donglord
		ckey = "inquisitorlisica"
		name = "The Bathroom"
	maid
		ckey = "housekeep"
		name = "Office of Maid"
	mbc
		ckey = "mybluecorners"
		name = "Office of Dotty Spud"
	nevada
		ckey = "spacingnevada"
		name = "Claire's Office of Claire"
		is_atmos_simulated = 1 //gotta light that POO
	sheezius
		ckey = "sheezius"
		name = "Claire's Orifice of Claire"
	schwick
		ckey = "schwickyschwag"
		name = "Schwick's Normal Bear Closet"
	stardust
		ckey = "stardustskunk"
		name = "Office of Stardust"
	tamber
		ckey = "tamber"
		name = "Office of Tamber"
	lupi
		ckey = "awildlupi"
		name = "the fart side"
	wackalope
		ckey = "wackalope"
		name = "ITS A LIGHTNING ROD OK"
