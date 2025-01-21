
/obj/item/toy/sword
	name = "toy sword"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "sword1"
	inhand_image_icon = 'icons/mob/inhand/hand_cswords.dmi'
	desc = "A sword made of cheap plastic. Contains a colored LED. Collect all five!"
	throwforce = 1
	w_class = W_CLASS_TINY
	throw_speed = 4
	throw_range = 5
	contraband = 3
	stamina_damage = 1
	stamina_cost = 7
	stamina_crit_chance = 1
	var/bladecolor = "G"
	var/sound_attackM1 = 'sound/weapons/male_toyattack.ogg'
	var/sound_attackM2 = 'sound/weapons/male_toyattack2.ogg'
	var/sound_attackF1 = 'sound/weapons/female_toyattack.ogg'
	var/sound_attackF2 = 'sound/weapons/female_toyattack2.ogg'

	New()
		..()
		src.bladecolor = pick("R","O","Y","G","C","B","P","Pi","W")
		if (prob(1))
			bladecolor = null
		icon_state = "sword1-[bladecolor]"
		item_state = "sword1-[bladecolor]"
		src.setItemSpecial(/datum/item_special/swipe)
		BLOCK_SETUP(BLOCK_SWORD)

	attack(target as mob, mob/user as mob)
		..()
		if (ishuman(user))
			var/mob/living/carbon/human/U = user
			if (U.gender == MALE)
				playsound(U, pick(src.sound_attackM1, src.sound_attackM2), 100, 0, 0, U.get_age_pitch())
			else
				playsound(U, pick(src.sound_attackF1, src.sound_attackF2), 100, 0, 0, U.get_age_pitch())

/obj/item/toy/judge_gavel
	name = "judge's gavel"
	desc = "A judge's best friend."
	icon = 'icons/obj/items/courtroom.dmi'
	icon_state = "gavel"
	w_class = W_CLASS_SMALL
	force = 5
	throwforce = 7
	stamina_damage = 25
	stamina_cost = 10
	stamina_crit_chance = 5

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		playsound(loc, 'sound/items/gavel.ogg', 75, 1)
		user.visible_message("<span class='alert'><b> Sweet Jesus! [user] is bashing their head in with [name]!</b></span>")
		user.TakeDamage("head", 150, 0)
		SPAWN_DBG(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

/obj/item/toy/judge_block
	name = "block"
	desc = "bang bang bang Bang Bang Bang Bang BANG BANG BANG BANG BANG!!!"
	icon = 'icons/obj/items/courtroom.dmi'
	icon_state = "block"
	flags = SUPPRESSATTACK
	w_class = W_CLASS_TINY
	throwforce = 1
	throw_speed = 4
	throw_range = 7
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1
	var/cooldown = 0

/obj/item/toy/judge_block/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/toy/judge_gavel))
		if(cooldown > world.time)
			return
		else
			playsound(loc, 'sound/items/gavel.ogg', 75, 1)
			user.say("Order, order in the court!")
			cooldown = world.time + 40
			return
	return ..()

/obj/item/toy/judge_block/attack()
	return

/obj/item/toy/diploma
	name = "diploma"
	icon = 'icons/obj/items/writing.dmi'
	icon_state = "diploma"
	w_class = W_CLASS_SMALL
	throwforce = 3
	throw_speed = 3
	throw_range = 5
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1
	var/redeemer = null
	var/receiver = null

/obj/item/toy/diploma/New()
	..()
	src.desc = "This is Clown College diploma, a Bachelor of Farts Degree for the study of [pick("slipology", "jugglemancy", "pie science", "bicycle horn accoustics", "comic sans calligraphy", "gelotology", "flatology", "nuclear physics", "goonstation coder")]. It appears to be written in crayon."

/obj/item/toy/diploma/attack(mob/M as mob, mob/user as mob)
	if (isliving(user))
		var/mob/living/L = user
		if (L.mind && L.mind.assigned_role == "Clown")
			L.visible_message("<span class='alert'><B>[L] bonks [M] [pick("kindly", "graciously", "helpfully", "sympathetically")].</B></span>")
			playsound(M, "sound/misc/boing/[rand(1,6)].ogg", 20, 1)
			M.say("[pick("Wow", "Gosh dangit", "Aw heck", "Oh gosh", "Damnit")], [L], [pick("why are you so", "it's totally unfair that you're so", "how come you're so", "tell me your secrets to being so")] [pick("cool", "smart", "worldly", "funny", "wise", "drop dead hilarious", "incredibly likeable", "beloved by everyone", "straight up amazing", "devilishly handsome")]!")

//We at cool don't have the historical context that made the gooncode's joke work, so I reworked it a bit.
/obj/item/toy/coolcode
	name = "coolcode hard disk drive"
	desc = "With this beautiful exemplar of open source software, you too can be coder! Just use your PDA and make your dream come true!"
	icon = 'icons/obj/cloning.dmi' // sprite is an altered harddisk
	icon_state = "gooncode" //I don't care
	flags = SUPPRESSATTACK
	throwforce = 3
	w_class = W_CLASS_SMALL
	throw_speed = 2
	throw_range = 3
	rand_pos = 1
	var/prfirst = "very"
	var/prmiddle = "smelly"
	var/prlast = "farts"

/obj/item/toy/coolcode/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/device/pda2))
		if(!ON_COOLDOWN(src, "magnum_opus", 4 SECONDS))
			switch(rand(1,3))
				if(1) //balance patches
					if (prob(50)) //We're saltily hacking into the code of whatever we got killed by last round.
						prfirst = pick("Balanced", "Nerfed", "Adjusted", "Balance pass on", "Fixes")
						//Now for what we've done to it
						prlast = pick("halving all the stats, if not worse", "gating it behind 40 minutes of mining gameplay",\
								"commenting it out", "adding 30-second actionbars", "moving it to the end of an azone", "making it replace one of your arms",\
								"giving it a 2% chance to spawn", "adding several layers of obtuse bullshit", "adding station-wide notifications",\
								"giving sec more guns")

					else //We're giving our favourite blorbo some love. Too much love.
						prfirst = pick("Balanced", "Buffed", "Improves", "Corrects", "Adds to", "Fixes")
						prlast = pick("making head-specific variants", "adding AoE stuns", "giving it to every department", "making it do half the station's jobs",\
								"bridging the one obstacle that balanced it in the first place", "adding it to every vending machine for free")

					prmiddle = pick("Grigoris", "draculas", "changelings", "genetics", "gunse", "fartin'", "toxins", "explosions", "pipebombs", "cloner", "antags", "medbay", "N2O", "pathology", "traitors", "nukies", "HoS", "HoP", "captain", "insuls", "multitools", "crowbars", "AI", "silicons", "RP")
					I.audible_message("<i>New pull request opened on Coolstation: <span class='emote'>\"[prfirst] [prmiddle] by [prlast].\"</i></span>")
				if(2) //ports
					prfirst = pick("Ports", "Re-invents", "Adds", "Brings over", "Implements")
					prmiddle = pick("a multi-department overhaul", "70 fluff chems", "NT-flavoured space marines", "something that didn't even work out where I got it from",\
							"ERP", "a -get this!- cult based antag", "magical clown powers", "an undercooked combat rework")
					prlast = pick("it exists on another codebase already", "it'd make me overpowered", "Goon wouldn't let me", "it makes this place more like other codebases",\
							"trust me bro", "it came to me in a dream", "I can't RP without it")
					I.audible_message("<i>New pull request opened on Coolstation: <span class='emote'>\"[prfirst] [prmiddle] because [prlast].\"</i></span>")
				if(3) //mapping changes
					prfirst = pick("Adds a ranch to", "Adds 14 more internal walls to medbay on", "Deletes cargo from", "Puts a new engine on",\
							"Turns security into an impenetrable fortress on", "Adds a public armory to", "QOL for medbay that basically eats all surrounding maint for",\
							"Remaps literally everything but within the same footprint on", "Replaces the bar with a pool on", "Replaces the pool with a bar on",\
							"Adds giant mining magnet to", "Just completely fucks up")
					prlast = pick("Chunk", "Gehenna", "Bayou", "Bayou Bay", "Cog1", "Cogmap1", "Donut2", "Bobmap", "Crag") //mostly maps that see use, even if sporadic
					I.audible_message("<i>New pull request opened on Coolstation: <span class='emote'>\"[prfirst] [prlast].\"</i></span>")
			playsound(loc, 'sound/machines/ding.ogg', 75, 1)
			user.visible_message("<span class='alert'><B>[user] contributes to Coolstation with their PDA.</B></span>")

			return
	return ..()

/obj/item/toy/coolcode/attack()
	return

/obj/item/toy/cellphone
	name = "flip phone"
	desc = "Wow! You've always wanted one of these charmingly clunky doodads!"
	icon = 'icons/obj/items/cellphone.dmi'
	icon_state = "cellphone-on"
	w_class = W_CLASS_SMALL
	var/datum/game/tetris
	var/datum/mail

	New()
		src.contextLayout = new /datum/contextLayout/instrumental(16)
		src.contextActions = childrentypesof(/datum/contextAction/cellphone)
		//Email was never even coded so ???
		..()
		START_TRACKING
		src.tetris = new /datum/game/tetris(src)

	disposing()
		..()
		STOP_TRACKING

	attack_self(mob/user as mob)
		..()
		user.showContextActions(contextActions, src)

/obj/machinery/computer/arcade/handheld
	desc = "You shouldn't see this, I exist for typechecks"

/obj/item/toy/handheld
	name = "arcade toy"
	desc = "These high tech gadgets compress the full arcade experience into a large, clunky handheld!"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "arcade-generic"
	mats = 2
	var/arcademode = FALSE
	//The arcade machine will typecheck if we're this type
	var/obj/machinery/computer/arcade/handheld/arcadeholder = null
	var/datum/game/gameholder = null
	var/datum/gametype = /datum/game/tetris

	New()
		. = ..()
		if (!arcademode)
			gameholder = new gametype(src)
			return
		//I wanted to make this the first time it's used
		//But then I don't have a name
		arcadeholder = new(src)
		name = arcadeholder.name

	attack_self(mob/user as mob)
		. = ..()
		if (!arcademode)
			src.gameholder.new_game(user)
			return

		arcadeholder.show_ui(user)


/obj/item/toy/handheld/robustris
	icon_state = "arcade-robustris"
	name = "Robustris Pro"

/obj/item/toy/handheld/arcade
	arcademode = TRUE
	icon_state = "arcade-adventure"
/obj/item/item_box/figure_capsule/gaming_capsule
	name = "game capsule"
	New()
		contained_item = pick(30;/obj/item/toy/handheld/arcade, 70;/obj/item/toy/handheld/robustris)
		. = ..()
		if (ispath(contained_item, /obj/item/toy/handheld/robustris))
			itemstate = "robustris-fig"
		else if (ispath(contained_item, /obj/item/toy/handheld/arcade))
			itemstate = "arcade-fig"
		else
			itemstate = "game-fig"
