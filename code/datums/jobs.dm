//here's where all the shit that jobs start with are defined
//starting gear, access, special handling, etc.

//added two defines for this
//NO_START_JOBGEAR_MAP: handles gear: if you don't want everyone already loaded up with all their job gear ready to go
//NO_DEPARTMENT_START_MAP: handles spawn location and uniform: if you don't want everyone spawning directly in departments dressed like they're already at work
//these can be combined

/datum/job/
	var/name = null
	var/list/alias_names = null
	var/initial_name = null
	var/linkcolor = "#0FF"
	var/department = null //are they part of another department? i.e. chief engineer is a head job but is responsible for engineering dept
	var/wages = 0
	var/limit = -1
	var/add_to_manifest = 1
	var/no_late_join = 0
	var/no_jobban_from_this_job = 0
	var/allow_traitors = 1
	var/allow_spy_theft = 1
	var/cant_spawn_as_rev = 0 // For the revoltion game mode. See jobprocs.dm for notes etc (Convair880).
	var/cant_spawn_as_con = 0 // Prevents this job spawning as a conspirator in the conspiracy gamemode.
	var/requires_whitelist = 0
	var/requires_supervisor_job = null // Enter job name, this job will only be present if the entered job has joined already
	var/needs_college = 0
	var/assigned = 0
	var/high_priority_job = 0
	var/low_priority_job = 0
	var/cant_allocate_unwanted = 0
	var/recieves_miranda = 0
	var/recieves_implant = null //Will be a path.
	var/receives_disk = 0
	var/receives_security_disk = 0
	var/receives_badge = 0
	var/announce_on_join = 0 // that's the head of staff announcement thing
	var/radio_announcement = 1 // that's the latejoin announcement thing
	var/list/alt_names = list()
	var/slot_card = /obj/item/card/id
	var/spawn_id = 1 // will override slot_card if 1
	// Following slots support single item list or weighted list - Do not use regular lists or it will error!
	var/list/slot_head = list()
	var/list/slot_mask = list()
	var/list/slot_ears = list(/obj/item/device/radio/headset) // cogwerks experiment - removing default headsets
	var/list/slot_eyes = list()
	var/list/slot_suit = list()
	var/list/slot_jump = list()
	var/list/slot_glov = list()
	var/list/slot_foot = list()
	var/list/slot_back = list(/obj/item/storage/backpack)
	var/list/slot_belt = list(/obj/item/device/pda2)
	var/list/slot_poc1 = list() // Pay attention to size. Not everything is small enough to fit in jumpsckets.
	var/list/slot_poc2 = list()
	var/list/slot_lhan = list()
	var/list/slot_rhan = list()
	var/list/items_in_backpack = list() // stop giving everyone a free airtank gosh
	var/list/items_in_belt = list() // works the same as above but is for jobs that spawn with a belt that can hold things
	var/list/access = list(access_fuck_all) // Please define in global get_access() proc (access.dm), so it can also be used by bots etc.
	var/mob/living/mob_type = /mob/living/carbon/human
	var/datum/mutantrace/starting_mutantrace = null
	var/change_name_on_spawn = 0
	var/special_spawn_location = 0
	var/spawn_x = 0
	var/spawn_y = 0
	var/spawn_z = 0
	var/bio_effects = null
	var/objective = null
	var/spawn_miscreant = 0
	var/rounds_needed_to_play = 0 //0 by default, set to the amount of rounds they should have in order to play this. HOS whitelist overrides cause this is only for sec roles atm
	var/map_can_autooverride = 1 // if set to 0 map can't change limit on this job automatically (it can still set it manually)
	//var/do_not_save_gun = 0		// if set to 1, this job will not pull from the gun's persistence cloud nor will it register one at end of round.

	New()
		..()
		initial_name = name

	proc/special_setup(var/mob/M, no_special_spawn)
		if (!M)
			return
		if (recieves_miranda)
			M.verbs += /mob/proc/recite_miranda
			M.verbs += /mob/proc/add_miranda
			if (!isnull(M.mind))
				M.mind.miranda = "You have the right to remain silent. Anything you say can and will be used against you in a NanoTrasen court of Space Law. You have the right to a rent-an-attorney. If you cannot afford one, a monkey in a suit and funny hat will be appointed to you."

		SPAWN_DBG(0)
			if (recieves_implant && ispath(recieves_implant))
				var/mob/living/carbon/human/H = M
				var/obj/item/implant/I = new recieves_implant(M)
				I.implanted = 1
				if(ishuman(M)) H.implant.Add(I)
				I.implanted(M)
				if (src.receives_disk && ishuman(M))
					if (istype(H.back, /obj/item/storage))
						var/obj/item/disk/data/floppy/D = locate(/obj/item/disk/data/floppy) in H.back
						if (D)
							var/datum/computer/file/clone/R = locate(/datum/computer/file/clone/) in D.root.contents
							if (R)
								R.fields["imp"] = "\ref[I]"

			var/give_access_implant = ismobcritter(M)
			if(!spawn_id && (access.len > 0 || access.len == 1 && access[1] != access_fuck_all))
				give_access_implant = 1
			if (give_access_implant)
				var/obj/item/implant/access/I = new /obj/item/implant/access(M)
				I.access.access = src.access.Copy()
				I.owner = M
				I.uses = -1
				I.set_loc(M)
				I.implanted = 1
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					H.implant.Add(I)
				I.implanted(M)

			if (src.special_spawn_location && !no_special_spawn)
				M.set_loc(locate(spawn_x,spawn_y,spawn_z))

			if (ishuman(M) && src.bio_effects)
				var/list/picklist = params2list(src.bio_effects)
				if (length(picklist))
					for(var/pick in picklist)
						M.bioHolder.AddEffect(pick)

			if (ishuman(M) && src.starting_mutantrace)
				var/mob/living/carbon/human/H = M
				H.set_mutantrace(src.starting_mutantrace)

			if (src.objective)
				var/datum/objective/newObjective = spawn_miscreant ? new /datum/objective/miscreant : new /datum/objective/crew
				newObjective.explanation_text = src.objective
				newObjective.owner = M.mind
				M.mind.objectives += newObjective
				if (spawn_miscreant)
					boutput(M, "<B>You are a miscreant!</B>")
					boutput(M, "You should try to complete your objectives, but don't commit any traitorous acts.")
					boutput(M, "Your objective is as follows:")
					boutput(M, "[newObjective.explanation_text]")
					miscreants += M.mind
				else
					boutput(M, "<B>Your OPTIONAL Crew Objectives are as follows:</b>")
					boutput(M, "<B>Objective #1</B>: [newObjective.explanation_text]")

			if (src.change_name_on_spawn && !jobban_isbanned(M, "Custom Names"))
				//if (ishuman(M)) //yyeah this doesn't work with critters fix later
				var/default = M.real_name + " the " + src.name
				var/orig_real = M.real_name
				M.choose_name(3, src.name, default)
				if(M.real_name != default && M.real_name != orig_real)
					phrase_log.log_phrase("name-[ckey(src.name)]", M.real_name, no_duplicates=TRUE)

			if (M.traitHolder && !M.traitHolder.hasTrait("loyalist"))
				cant_spawn_as_rev = 1 //Why would an NT Loyalist be a revolutionary?
/*
			if (src.do_not_save_gun && !isnull(M.mind))
				M.mind.do_not_save_gun = 1
*/
// Command Jobs

ABSTRACT_TYPE(/datum/job/command)
/datum/job/command
	linkcolor = "#128352"
	slot_card = /obj/item/card/id/command
	map_can_autooverride = 0
	//do_not_save_gun = 1

/datum/job/command/captain
	name = "Captain"
	limit = 1
	wages = PAY_EXECUTIVE
	high_priority_job = 1
	recieves_miranda = 1
#ifdef RP_MODE
	allow_traitors = 0
#endif
	cant_spawn_as_rev = 1
	announce_on_join = 1
	allow_spy_theft = 0

	slot_card = /obj/item/card/id/gold
	slot_belt = list(/obj/item/device/pda2/captain)
	slot_back = list(/obj/item/storage/backpack/captain/blue)
#ifdef NO_START_JOBGEAR_MAP
	//no armor, get it from your locker
	slot_jump = list(/obj/item/clothing/under/shirt_pants_w/captain)
#elif defined(NO_DEPARTMENT_START_MAP)
	//start cap in bed
	slot_jump = list(/obj/item/clothing/under/gimmick/pajamas)
#else
	slot_jump = list(/obj/item/clothing/under/shirt_pants_w/captain)
	slot_suit = list(/obj/item/clothing/suit/cap_coat)
#endif
	slot_head = list(/obj/item/clothing/head/caphat)
	slot_foot = list(/obj/item/clothing/shoes/swat)
	slot_ears = list(/obj/item/device/radio/headset/command/captain)
	slot_poc1 = list(/obj/item/disk/data/floppy/read_only/authentication)
	items_in_backpack = list(/obj/item/device/flash)
#ifdef RP_MODE
	rounds_needed_to_play = 20
#endif

	New()
		..()
		src.access = get_all_accesses()

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.show_text("<b>You're the Captain! You're nominally in charge here. Generally, make sure the station is not blowing up and keep up morale. Set a good example! Without you, the whole station would be lost and directionless!</b>", "blue")
		return

	derelict
		//name = "NT-SO Commander"
		name = null
		limit = 0
		slot_suit = list(/obj/item/clothing/suit/armor/centcomm)
		slot_jump = list(/obj/item/clothing/under/misc/turds)
		slot_head = list(/obj/item/clothing/head/centhat)
		slot_belt = list(/obj/item/tank/emergency_oxygen)
		slot_glov = list(/obj/item/clothing/gloves/fingerless)
		slot_back = list(/obj/item/storage/backpack/NT)
		slot_mask = list(/obj/item/clothing/mask/gas)
		slot_eyes = list(/obj/item/clothing/glasses/thermal)
		items_in_backpack = list(/obj/item/crowbar,/obj/item/device/light/flashlight,/obj/item/camera/*,/obj/item/gun/energy/egun*/)

		special_setup(var/mob/living/carbon/human/M)
			..()
			if (!M)
				return
			M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/command/head_of_personnel
	name = "Head of Personnel"
	limit = 1
	wages = PAY_IMPORTANT
	//department = "civilian" //i'm really torn on this
	// not necessary imo. HoP may have been "intended" for civvie head, but history has shown they are the vice president to the captain. - warc

	allow_spy_theft = 0
	recieves_miranda = 1
	cant_spawn_as_rev = 1
	announce_on_join = 1

	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/device/pda2/heads)
	slot_jump = list(/obj/item/clothing/under/suit/hop)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/command/hop)
	items_in_backpack = list(/obj/item/device/flash,/obj/item/storage/box/accessimp_kit)
//starting ready to go
#ifdef NO_START_JOBGEAR_MAP
	items_in_backpack = list(/obj/item/device/flash)
#else
	items_in_backpack = list(/obj/item/device/flash,/obj/item/storage/box/accessimp_kit)
#endif

	New()
		..()
		src.access = get_access("Head of Personnel")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.show_text("<b>You're the Head of Personnel! You're the Captain's number two. Mediate disputes between departments, assist with hiring, firing, basic non-departmental gear, and access changes. Without you, cross-departmental personnel matters would decrease the efficiency of station operations! (That's bad) </b>", "blue")
		return

/datum/job/command/head_of_security
	name = "Head of Security"
	limit = 1
	wages = PAY_IMPORTANT
	department = "security"
	requires_whitelist = 1
	recieves_miranda = 1
	allow_traitors = 0
	allow_spy_theft = 0
	cant_spawn_as_con = 1
	cant_spawn_as_rev = 1
	announce_on_join = 1
	receives_badge = 1
	recieves_implant = /obj/item/implant/health/security/anti_insurgent
	items_in_backpack = list(/obj/item/device/flash)

	//hos can spawn with everything, no big deal
	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/storage/belt/security/HoS)
	slot_poc1 = list(/obj/item/device/pda2/hos)
	slot_poc2 = list(/obj/item/instrument/whistle) //replaces sec starter kit
	slot_jump = list(/obj/item/clothing/under/rank/head_of_securityold)
	slot_suit = list(/obj/item/clothing/suit/armor/vest)
	slot_foot = list(/obj/item/clothing/shoes/swat)
	slot_head = list(/obj/item/clothing/head/hos_hat)
	slot_ears = list(/obj/item/device/radio/headset/command/hos)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses/sechud)

	New()
		..()
		src.access = get_access("Head of Security")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_drinker")
		M.traitHolder.addTrait("training_security")
		JOB_XP(M, "Head of Security", 1)
		M.show_text("<b>You're the Head of Security! Make sure the station is safe from damage and crime! Delegate tasks, coordinate with other departments, and make sure your subordinates have what they need (and aren't being too hard OR too soft!). Without your deparment, this place would descend into chaos!</b>", "blue")
		//I took this stuff from the sec equipment vendor we're axing- Bat
		var/obj/item/storage/belt/A = M.belt
		SPAWN_DBG(2 DECI SECONDS) //ugh belts do this on spawn and we need to wait
			var/list/tracklist = list()
			for(var/atom/C in A.contents)
				if (istype(C,/obj/item/baton))
					tracklist += C

			if (length(tracklist))
				var/obj/item/pinpointer/secweapons/P = new(A)
				P.track(tracklist)

	derelict
		name = null//"NT-SO Special Operative"
		limit = 0
		slot_suit = list(/obj/item/clothing/suit/armor/NT)
		slot_jump = list(/obj/item/clothing/under/misc/turds)
		slot_head = list(/obj/item/clothing/head/NTberet)
		slot_belt = list(/obj/item/tank/emergency_oxygen)
		slot_mask = list(/obj/item/clothing/mask/gas)
		slot_glov = list(/obj/item/clothing/gloves/latex)
		slot_back = list(/obj/item/storage/backpack/NT)
		slot_eyes = list(/obj/item/clothing/glasses/thermal)
		items_in_backpack = list(/obj/item/crowbar,/obj/item/device/light/flashlight,/obj/item/breaching_charge,/obj/item/breaching_charge/*,/obj/item/gun/energy/laser_gun/pred*/)

		special_setup(var/mob/living/carbon/human/M)
			..()
			if (!M)
				return
			M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/command/chief_engineer
	name = "Chief Engineer"
	limit = 1
	wages = PAY_IMPORTANT
	department = "engineering"
	cant_spawn_as_rev = 1
	announce_on_join = 1
	allow_spy_theft = 0

	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/device/pda2/chiefengineer)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/rank/chief_engineer)
	slot_ears = list(/obj/item/device/radio/headset/command/ce)
	slot_poc1 = list(/obj/item/paper/book/from_file/pocketguide/engineering)
	items_in_backpack = list(/obj/item/device/flash, /obj/item/rcd_ammo/medium)
#ifdef BOOTSTRAPPED_MAP
	slot_eyes = list(/obj/item/clothing/glasses/meson)
	slot_glov = list(/obj/item/clothing/gloves/yellow)
	slot_head = list(/obj/item/clothing/head/helmet/hardhat)
#endif

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_engineer")
		M.show_text("<b>You're the Chief Engineer! Make sure the station is powered and in working order! Delegate tasks, coordinate with other departments, and make sure your subordinates have what they need. Without your department, everyone would be suffocating in the dark!</b>", "blue")
		return

	New()
		..()
		src.access = get_access("Chief Engineer")
		return

	derelict
		name = null//"Salvage Chief"
		limit = 0
		slot_suit = list(/obj/item/clothing/suit/space/industrial)
		slot_foot = list(/obj/item/clothing/shoes/magnetic)
		slot_head = list(/obj/item/clothing/head/helmet/space/industrial)
		slot_belt = list(/obj/item/tank/emergency_oxygen)
		slot_mask = list(/obj/item/clothing/mask/gas)
		slot_eyes = list(/obj/item/clothing/glasses/thermal) // mesons look fuckin weird in the dark
		items_in_backpack = list(/obj/item/crowbar,/obj/item/rcd,/obj/item/rcd_ammo,/obj/item/rcd_ammo,/obj/item/device/light/flashlight,/obj/item/cell/cerenkite)

		special_setup(var/mob/living/carbon/human/M)
			..()
			if (!M)
				return
			M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/command/research_director
	name = "Research Director"
	limit = 1
	wages = PAY_IMPORTANT
	department = "research"
	allow_spy_theft = 0
	cant_spawn_as_rev = 1
	announce_on_join = 1

	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/device/pda2/research_director)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/rank/research_director)
	slot_ears = list(/obj/item/device/radio/headset/command/rd)
	items_in_backpack = list(/obj/item/device/flash)
#ifdef BOOTSTRAPPED_MAP
	slot_eyes = list(/obj/item/clothing/glasses/spectro)
	slot_rhan = list(/obj/item/clipboard/with_pen)
	slot_suit = list(/obj/item/clothing/suit/labcoat)
#endif

	New()
		..()
		src.access = get_access("Research Director")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		var/obj/critter/domestic_bee/heisenbee/heisenbee = locate() in range(M, 7)
		if (istype(heisenbee) && !heisenbee.beeMom)
			heisenbee.beeMom = M
			heisenbee.beeMomCkey = M.ckey
		M.show_text("<b>You're the Research Director! Make sure the station is properly doing science, especially for export! Delegate tasks, coordinate with other departments, and make sure your subordinates have what they need. Your department is the whole reason Nanotrasen is even out here!</b>", "blue")

/datum/job/command/medical_director
	name = "Medical Director"
	limit = 1
	wages = PAY_IMPORTANT
	department = "medical"
	allow_spy_theft = 0
	cant_spawn_as_rev = 1
	announce_on_join = 1

	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/device/pda2/medical_director)
	slot_lhan = list(/obj/item/storage/firstaid/regular/mdir)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/rank/medical_director)
	slot_suit = list(/obj/item/clothing/suit/labcoat)
	slot_ears = list(/obj/item/device/radio/headset/command/md)
	slot_eyes = list(/obj/item/clothing/glasses/healthgoggles/upgraded)
	items_in_backpack = list(/obj/item/device/flash, /obj/item/robodefibrillator)

	New()
		..()
		src.access = get_access("Medical Director")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_medical")
		M.show_text("<b>You're the Medical Director! Make sure the station is in good health, or at least not dying! Delegate tasks, coordinate with other departments, and make sure your subordinates have what they need. Without your department, everyone would be a goner! You set the tone!</b>", "blue")

/datum/job/command/quartermaster
	name = "Quartermaster"
	limit = 1
	wages = PAY_IMPORTANT
	department = "logistics"

	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_jump = list(/obj/item/clothing/under/rank/qm)
	slot_belt = list(/obj/item/device/pda2/quartermaster)
	slot_ears = list(/obj/item/device/radio/headset/command/qm)
	//slot_poc1 = list(/obj/item/paper/book/from_file/pocketguide/quartermaster) // probably doesnt need the pocket guide?
	slot_poc2 = list(/obj/item/device/appraisal)

	New()
		..()
		src.access = get_access("Quartermaster") //maybe get a little bonus office
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.show_text("<b>You're the Quartermaster! Make sure the station departments are properly equipped, raw materials and salvage are coming in and going out, and income is up! Delegate tasks, coordinate with other departments, and make sure your subordinates have what they need. Without your department, this station grinds to a halt!</b>", "blue")

/datum/job/command/bureaucrat
	name = " Bureaucrat"
	limit = 1
	wages = PAY_IMPORTANT
	department = "command"

	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/device/pda2/heads)
	slot_jump = list(/obj/item/clothing/under/misc/lawyer)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/command)
	slot_head = list(/obj/item/clothing/head/NTberet)
	slot_eyes = list(/obj/item/clothing/glasses/regular)
	slot_lhan = list(/obj/item/clipboard/with_pen)
	items_in_backpack = list(/obj/item/device/flash)

	New()
		..()
		name = get_bureau_name()
		src.access = get_access("VIP")
		return

// Security Jobs

ABSTRACT_TYPE(/datum/job/security)
/datum/job/security
	linkcolor = "#af4242"
	slot_card = /obj/item/card/id/security
	recieves_miranda = 1
	//do_not_save_gun = 1

/datum/job/security/security_officer
	name = "Security Officer"
	limit = 5
	wages = PAY_TRADESMAN
	allow_traitors = 0
	allow_spy_theft = 0
	cant_spawn_as_con = 1
	cant_spawn_as_rev = 1
	receives_badge = 1
	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/storage/belt/security/enhanced)
	slot_jump = list(/obj/item/clothing/under/rank/security)
	//slot_suit = list(/obj/item/clothing/suit/armor/vest)
	slot_foot = list(/obj/item/clothing/shoes/swat)
	slot_ears = list(/obj/item/device/radio/headset/security)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses/sechud)
	slot_poc1 = list(/obj/item/instrument/whistle) //replaces sec starter kit
	slot_poc2 = list(/obj/item/device/pda2/security)
	rounds_needed_to_play = 30 //higher barrier of entry than before but now with a trainee job to get into the rythym of things to compensate

	New()
		..()
		src.access = get_access("Security Officer")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_security")
		//I took this stuff from the sec equipment vendor we're axing- Bat
		var/obj/item/storage/belt/A = M.belt
		if (istype(A,/obj/item/storage/belt/security/enhanced)) //This kinda stinks but it weeds out assistants who are a secoff subtype fsr????
			SPAWN_DBG(2 DECI SECONDS) //ugh belts do this on spawn and we need to wait
				var/list/tracklist = list()
				for(var/atom/C in A.contents)
					if (istype(C,/obj/item/baton))
						tracklist += C

				if (length(tracklist))
					var/obj/item/pinpointer/secweapons/P = new(A)
					P.track(tracklist)

	assistant
		name = "Security Assistant"
		limit = 3
		cant_spawn_as_con = 1
		wages = PAY_UNTRAINED
		slot_jump = list(/obj/item/clothing/under/rank/security/assistant)
		slot_belt = list()
		slot_suit = list()
		slot_glov = list(/obj/item/clothing/gloves/fingerless)
		slot_head = list(/obj/item/clothing/head/red)
		slot_foot = list(/obj/item/clothing/shoes/brown)
		slot_poc1 = list(/obj/item/storage/security_pouch/assistant)
		slot_poc2 = list(/obj/item/device/pda2/security)
		items_in_backpack = list(/obj/item/paper/book/from_file/space_law)
		rounds_needed_to_play = 5

		New()
			..()
			src.access = get_access("Security Assistant")
			return

	derelict
		//name = "NT-SO Officer"
		name = null
		limit = 0
		slot_suit = list(/obj/item/clothing/suit/armor/NT_alt)
		slot_jump = list(/obj/item/clothing/under/misc/turds)
		slot_head = list(/obj/item/clothing/head/helmet/swat)
		slot_glov = list(/obj/item/clothing/gloves/fingerless)
		slot_back = list(/obj/item/storage/backpack/NT)
		//slot_belt = list(/obj/item/gun/energy/laser_gun)
		slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
		items_in_backpack = list(/obj/item/crowbar,/obj/item/device/light/flashlight,/obj/item/baton,/obj/item/breaching_charge,/obj/item/breaching_charge)

		special_setup(var/mob/living/carbon/human/M)
			..()
			if (!M)
				return
			M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/security/detective
	name = "Detective"
	limit = 1
	wages = PAY_TRADESMAN
	//allow_traitors = 0
	receives_badge = 1
	cant_spawn_as_rev = 1
	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/storage/belt/security/shoulder_holster)
	slot_poc1 = list(/obj/item/device/pda2/forensic)
	slot_poc2 = list(/obj/item/reagent_containers/food/snacks/ingredient/egg/hardboiled)
	slot_jump = list(/obj/item/clothing/under/rank/det)
	slot_foot = list(/obj/item/clothing/shoes/detective)
	slot_head = list(/obj/item/clothing/head/det_hat)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_suit = list(/obj/item/clothing/suit/det_suit)
	slot_ears = list(/obj/item/device/radio/headset/detective)
	items_in_backpack = list(/obj/item/clothing/glasses/vr,/obj/item/storage/box/detectivegun)

	New()
		..()
		src.access = get_access("Detective")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_drinker")

		if (M.traitHolder && !M.traitHolder.hasTrait("smoker"))
			slot_poc1 = list(/obj/item/device/light/zippo) //Smokers start with a trinket version

// Research Jobs

ABSTRACT_TYPE(/datum/job/research)
/datum/job/research
	linkcolor = "#A645D1"
	slot_card = /obj/item/card/id/research

/datum/job/research/scientist
	name = "Scientist"
	limit = 5
	wages = PAY_DOCTORATE
	slot_belt = list(/obj/item/device/pda2/toxins)
	slot_jump = list(/obj/item/clothing/under/rank/scientist)
	slot_suit = list(/obj/item/clothing/suit/labcoat)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_mask = list(/obj/item/clothing/mask/gas)
	slot_lhan = list(/obj/item/tank/air)
	slot_ears = list(/obj/item/device/radio/headset/research)
	slot_eyes = list(/obj/item/clothing/glasses/spectro)
	slot_poc1 = list(/obj/item/pen = 50, /obj/item/pen/fancy = 25, /obj/item/pen/red = 5, /obj/item/pen/pencil = 20)

	New()
		..()
		src.access = get_access("Scientist")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		if(prob(20))
			M.traitHolder.addTrait("scienceteam")

/datum/job/research/chemist //welcome back to the team
	name = "Chemist"
	limit = 2
	wages = PAY_DOCTORATE
	slot_belt = list(/obj/item/device/pda2/toxins)
	slot_jump = list(/obj/item/clothing/under/rank/scientist)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_ears = list(/obj/item/device/radio/headset/research)
	slot_eyes = list(/obj/item/clothing/glasses/spectro)
	slot_poc1 = list(/obj/item/reagent_containers/glass/beaker/large = 50, /obj/item/pen/fancy = 25, /obj/item/pen/red = 5, /obj/item/reagent_containers/glass/beaker = 20)

	New()
		..()
		src.access = get_access("Chemist")
		return

	special_setup(var/mob/living/carbon/human/M) //chemists are also on the science team, unfortunately
		..()
		if (!M)
			return
		if(prob(20))
			M.traitHolder.addTrait("scienceteam")

// Medical Jobs

ABSTRACT_TYPE(/datum/job/medical)
/datum/job/medical
	linkcolor = "#3577AD" //still the nerd department (medsci)
	slot_card = /obj/item/card/id/research

/datum/job/medical/medical_doctor
	name = "Medical Doctor"
	limit = 4
	wages = PAY_DOCTORATE
	slot_back = list(/obj/item/storage/backpack/medic)
	slot_belt = list(/obj/item/storage/belt/medical)
	slot_jump = list(/obj/item/clothing/under/rank/medical)
	slot_suit = list(/obj/item/clothing/suit/labcoat)
	slot_foot = list(/obj/item/clothing/shoes/red)
	slot_lhan = list(/obj/item/storage/firstaid/regular/doctor_spawn)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	slot_eyes = list(/obj/item/clothing/glasses/healthgoggles)
	slot_poc1 = list(/obj/item/device/pda2/medical)
	slot_poc2 = list(/obj/item/paper/book/from_file/pocketguide/medical)
	items_in_backpack = list(/obj/item/crowbar) // cogwerks: giving medics a guaranteed air tank, stealing it from roboticists (those fucks)
	// 2018: guaranteed air tanks now spawn in boxes (depending on backpack type) to save room

	New()
		..()
		src.access = get_access("Medical Doctor")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_medical")

	derelict
		//name = "Salvage Medic"
		name = null
		limit = 0
		slot_suit = list(/obj/item/clothing/suit/armor/vest)
		slot_head = list(/obj/item/clothing/head/helmet/swat)
		slot_belt = list(/obj/item/tank/emergency_oxygen)
		slot_mask = list(/obj/item/clothing/mask/breath)
		slot_eyes = list(/obj/item/clothing/glasses/healthgoggles)
		slot_glov = list(/obj/item/clothing/gloves/latex)
		items_in_backpack = list(/obj/item/crowbar,/obj/item/device/light/flashlight,/obj/item/storage/firstaid/regular,/obj/item/storage/firstaid/regular)

		special_setup(var/mob/living/carbon/human/M)
			..()
			if (!M) return
			M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/medical/surgeon //flavor job
	name = "Surgeon"
	limit = 1 //1 or 2
	wages = PAY_DOCTORATE
	slot_head = list(/obj/item/clothing/head/headmirror) //medical doofus hat
	slot_belt = list(/obj/item/device/pda2/medical)
	slot_back = list(/obj/item/storage/backpack/medic)
	slot_jump = list(/obj/item/clothing/under/rank/medical)
	slot_suit = list(/obj/item/clothing/suit/labcoat)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_lhan = list(/obj/item/storage/firstaid/docbag)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	slot_eyes = list(/obj/item/clothing/glasses/healthgoggles)
	slot_poc1 = list(/obj/item/tweezers)
	slot_poc2 = list(/obj/item/paper/book/from_file/pocketguide/medical)
	items_in_backpack = list(/obj/item/clothing/under/scrub/maroon)

	New()
		..()
		src.access = get_access("Medical Doctor")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_medical")

/datum/job/medical/pharmacist //flavor job
	name = "Pharmacist"
	limit = 2
	wages = PAY_TRADESMAN
	slot_card = /obj/item/card/id/research
	slot_back = list(/obj/item/storage/backpack/medic)
	slot_jump = list(/obj/item/clothing/under/shirt_pants)
	slot_suit = list(/obj/item/clothing/suit/labcoat)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	slot_belt = list(/obj/item/device/pda2/medical)
	slot_poc2 = list(/obj/item/paper/book/from_file/pocketguide/medical)
	items_in_backpack = list(/obj/item/storage/box/beakerbox, /obj/item/storage/pill_bottle/cyberpunk) //encourage a little drug dealing, why not

	New()
		..()
		src.access = get_access("Pharmacist")
		return

#ifdef CREATE_PATHOGENS
/datum/job/medical/pathologist
#else
/datum/job/pathologist // pls no autogenerate list
#endif
	name = "Pathologist"
	department = "research"
	#ifdef CREATE_PATHOGENS
	limit = 2
	#else
	limit = 0
	#endif
	wages = PAY_DOCTORATE
	slot_belt = list(/obj/item/device/pda2/genetics)
	slot_jump = list(/obj/item/clothing/under/rank/pathologist)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_suit = list(/obj/item/clothing/suit/labcoat/pathology)
	#ifdef SCIENCE_PATHO_MAP
	slot_ears = list(/obj/item/device/radio/headset/research)
	#else
	slot_ears = list(/obj/item/device/radio/headset/medical)
	#endif

	New()
		..()
		src.access = get_access("Pathologist")
		return

/datum/job/medical/roboticist
	name = "Roboticist"
	limit = 2
	wages = PAY_DOCTORATE
	slot_belt = list(/obj/item/device/pda2/medical/robotics)
	slot_jump = list(/obj/item/clothing/under/rank/roboticist)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_suit = list(/obj/item/clothing/suit/labcoat/robotics)
	slot_glov = list(/obj/item/clothing/gloves/latex)
	slot_lhan = list(/obj/item/storage/toolbox/mechanical)
	slot_eyes = list(/obj/item/clothing/glasses/healthgoggles)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	slot_poc1 = list(/obj/item/reagent_containers/mender/brute)
	items_in_backpack = list(/obj/item/crowbar)

	New()
		..()
		src.access = get_access("Roboticist")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_medical")

/datum/job/medical/geneticist
	name = "Geneticist"
	limit = 2
	department = "research"
	linkcolor = "#A645D1"
	wages = PAY_DOCTORATE
	slot_belt = list(/obj/item/device/pda2/genetics)
	slot_jump = list(/obj/item/clothing/under/rank/geneticist)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_suit = list(/obj/item/clothing/suit/labcoat/genetics)
	slot_ears = list(/obj/item/device/radio/headset/medical)

	New()
		..()
		src.access = get_access("Geneticist")
		return

/datum/job/medical/nurse //flavor job, medical assistant in scrubs
	name = "Nurse"
	limit = 2
	wages = PAY_UNTRAINED
	low_priority_job = 1
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_jump = list(/obj/item/clothing/under/scrub/teal=1,\
	/obj/item/clothing/under/scrub/maroon =1,\
	/obj/item/clothing/under/scrub/blue=1,\
	/obj/item/clothing/under/scrub/purple=1,\
	/obj/item/clothing/under/scrub/orange=1,\
	/obj/item/clothing/under/scrub/pink=1,\
	/obj/item/clothing/under/scrub/flower=1)
	slot_ears = list(/obj/item/device/radio/headset/medical)

	New()
		..()
		src.access = get_access("Nurse")
		return

/datum/job/medical/receptionist //flavor job, medical assistant in scrubs, dispatch pills and basic diagnoses from front desk and try to reduce as many people coming as possible
	name = "Receptionist"
	limit = 1 //or 2 maybe
	wages = PAY_UNTRAINED
	low_priority_job = 1
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_jump = list(/obj/item/clothing/under/color/white)

	New()
		..()
		src.access = get_access("Nurse")
		return

// Engineering Jobs

ABSTRACT_TYPE(/datum/job/engineering)
/datum/job/engineering
	linkcolor = "#ac5f06"
	slot_card = /obj/item/card/id/engineering

/datum/job/engineering/engineer
	name = "Engineer"
	limit = 5
	wages = PAY_TRADESMAN
	slot_back = list(/obj/item/storage/backpack/withO2)
#ifndef NO_START_JOBGEAR_MAP
	//spawn your tools
	slot_lhan = list(/obj/item/storage/toolbox/mechanical/engineer_spawn)
	slot_glov = list(/obj/item/clothing/gloves/yellow)
	slot_belt = list(/obj/item/storage/belt/utility)
#endif
#ifndef NO_DEPARTMENT_START_MAP
	//spawn in dept, go get your shit from your locker, lazybones
	slot_jump = list(/obj/item/clothing/under/rank/engineer)
	slot_foot = list(/obj/item/clothing/shoes/orange)
#else
	//fresh from shuttle/quarters, probably just woke up
	//todo: casual clothes
	slot_jump = list(/obj/item/clothing/under/rank/engineer)
	slot_foot = list(/obj/item/clothing/shoes/orange)
#endif
	slot_poc1 = list(/obj/item/device/pda2/engine)
	slot_ears = list(/obj/item/device/radio/headset/engineer)
	items_in_backpack = list(/obj/item/paper/book/from_file/pocketguide/engineering, /obj/item/old_grenade/oxygen)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_engineer")

	New()
		..()
		src.access = get_access("Engineer")
		return

	derelict
		name = null//"Salvage Engineer"
		limit = 0
		slot_suit = list(/obj/item/clothing/suit/space/engineer)
		slot_head = list(/obj/item/clothing/head/helmet/welding)
		slot_belt = list(/obj/item/tank/emergency_oxygen)
		slot_mask = list(/obj/item/clothing/mask/breath)
		items_in_backpack = list(/obj/item/crowbar,/obj/item/device/light/flashlight,/obj/item/device/light/glowstick,/obj/item/gun/modular/NT/flare_gun,/obj/item/stackable_ammo/shotgun/slug_flare/ten,/obj/item/cell/cerenkite)

		special_setup(var/mob/living/carbon/human/M)
			..()
			if (!M)
				return
			M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/engineering/mechanic //redstone guys should fix doors too and machinery too (yes this includes the microwave)
	name = "Mechanic"
	limit = 2 //split between them and new department, they have the same toys
	wages = PAY_TRADESMAN

	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/storage/belt/utility/prepared)
	slot_jump = list(/obj/item/clothing/under/rank/mechanic)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_lhan = list(/obj/item/storage/toolbox/electrical/mechanic_spawn)
	slot_glov = list(/obj/item/clothing/gloves/yellow = 95, /obj/item/clothing/gloves/yellow/unsulated = 5)
	slot_poc1 = list(/obj/item/device/pda2/mechanic)
	slot_ears = list(/obj/item/device/radio/headset/engineer)

	New()
		..()
		src.access = get_access("Mechanic")
		return

/datum/job/engineering/electrician //wiring and broken APCs are a pain, give engineers a break. also: fixes small handheld items.
	name = "Electrician"
	limit = 2
	wages = PAY_TRADESMAN
	//need to redo loadout. probably dress them in yellow.
	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/storage/belt/utility/prepared)
	slot_jump = list(/obj/item/clothing/under/rank/mechanic)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_lhan = list(/obj/item/storage/toolbox/electrical/mechanic_spawn)
	slot_glov = list(/obj/item/clothing/gloves/yellow)
	slot_poc1 = list(/obj/item/device/pda2/mechanic)
	slot_ears = list(/obj/item/device/radio/headset/engineer)

	New()
		..()
		src.access = get_access("Mechanic")
		return

/datum/job/engineering/atmospheric_technician //you make sure air is in places that air should be and stays in there
	name = "Atmospheric Technician"
	limit = 2
	wages = PAY_TRADESMAN
	slot_belt = list(/obj/item/device/pda2/atmos)
	slot_jump = list(/obj/item/clothing/under/misc/atmospheric_technician)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_lhan = list(/obj/item/storage/toolbox/mechanical)
	slot_poc1 = list(/obj/item/device/analyzer/atmospheric)
	slot_ears = list(/obj/item/device/radio/headset/engineer)
	items_in_backpack = list(/obj/item/crowbar, /obj/item/paper/book/from_file/pocketguide/atmos, /obj/item/deconstructor)

	New()
		..()
		src.access = get_access("Atmospheric Technician")
		return

// Logistics Jobs

ABSTRACT_TYPE(/datum/job/logistics)
/datum/job/logistics
	linkcolor = "#7B750F"
	slot_card = /obj/item/card/id/logistics

//QM got promoted, look under /job/command/quartermaster

/datum/job/logistics/cargotechnician
	name = "Cargo Technician"
	limit = 3
	wages = PAY_TRADESMAN
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_jump = list(/obj/item/clothing/under/rank/cargo)
	slot_belt = list(/obj/item/device/pda2/cargo_tech)
	slot_ears = list(/obj/item/device/radio/headset/shipping)
	slot_poc1 = list(/obj/item/paper/book/from_file/pocketguide/quartermaster)
	slot_poc2 = list(/obj/item/device/appraisal)

	New()
		..()
		src.access = get_access("Cargo Technician") //same access as QM
		return


/datum/job/logistics/miner
	name = "Miner"
	limit = 5
	wages = PAY_TRADESMAN
	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/device/pda2/mining)
	slot_jump = list(/obj/item/clothing/under/rank/overalls)
	slot_foot = list(/obj/item/clothing/shoes/orange)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/shipping)
	slot_poc1 = list(/obj/item/paper/book/from_file/pocketguide/mining)
	items_in_backpack = list(/obj/item/crowbar)

	New()
		..()
		src.access = get_access("Miner")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("training_miner")
		if(prob(20))
			M.bioHolder.AddEffect("dwarf", magical=1)

/datum/job/logistics/scrapper
	name = "Scrapper"
	wages = PAY_TRADESMAN
	limit = 0 //overriden by the bayou bend

	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/device/pda2/scrapping)
	slot_jump = list(/obj/item/clothing/under/rank/orangeoveralls/scrapper)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/scrapping)
	New()
		..()
		src.access = get_access("Scrapper")
		return


/datum/job/logistics/mailcarrier
	name = "Mailcarrier"
	wages = PAY_TRADESMAN
	limit = 1
	slot_jump = list(/obj/item/clothing/under/misc/mail/syndicate)
	slot_head = list(/obj/item/clothing/head/mailcap)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_back = list(/obj/item/storage/backpack/satchel)
	slot_ears = list(/obj/item/device/radio/headset/mail)
	items_in_backpack = list(/obj/item/wrapping_paper, /obj/item/paper_bin, /obj/item/scissors, /obj/item/stamp)
	alt_names = list("Head of Deliverying", "Head of Mailcarrying")

	New()
		..()
		src.access = get_access("Mailcarrier")
		return

/datum/job/logistics/janitor
	name = "Janitor"
	limit = 2
	wages = PAY_TRADESMAN
	slot_belt = list(/obj/item/device/pda2/janitor)
	slot_jump = list(/obj/item/clothing/under/rank/janitor)
	slot_foot = list(/obj/item/clothing/shoes/galoshes)
	slot_ears = list(/obj/item/device/radio/headset/shipping)

	New()
		..()
		src.access = get_access("Janitor")
		return

// Civilian Jobs

ABSTRACT_TYPE(/datum/job/civilian)
/datum/job/civilian
	linkcolor = "#0873d2"
	slot_card = /obj/item/card/id/civilian

/datum/job/civilian/chef
	name = "Chef"
	limit = 1
	wages = PAY_UNTRAINED
	slot_belt = list(/obj/item/device/pda2/chef)
	slot_jump = list(/obj/item/clothing/under/rank/chef)
	slot_foot = list(/obj/item/clothing/shoes/chef)
	slot_head = list(/obj/item/clothing/head/chefhat)
	slot_suit = list(/obj/item/clothing/suit/chef)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	items_in_backpack = list(/obj/item/kitchen/rollingpin)

	New()
		..()
		src.access = get_access("Chef")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_chef")

/datum/job/civilian/bartender
	name = "Bartender"
	alias_names = list("Barman")
	//do_not_save_gun = 1
	limit = 1
	wages = PAY_UNTRAINED
	slot_belt = list(/obj/item/device/pda2/bartender)
	slot_jump = list(/obj/item/clothing/under/rank/bartender)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_suit = list(/obj/item/clothing/suit/armor/vest)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_poc1 = list(/obj/item/paper/book/from_file/pocketguide/bartending)
	slot_lhan = list(/obj/item/reagent_containers/food/drinks/cocktailshaker) // bartenders buddy ammo is broken i think
	items_in_backpack = list(/obj/item/gun/modular/NT/bartender, /obj/item/stackable_ammo/shotgun/slug_rubber/three, /obj/item/stackable_ammo/pistol/ratshot/three)

	New()
		..()
		src.access = get_access("Bartender")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_drinker")
		//Gonna give bartenders a black flavour of vest to respect their two-tone colour scheme
		var/obj/item/clothing/suit/armor/vest/A = M.wear_suit
		if (istype(A))
			A.icon_state = "armorvest-light"

/datum/job/civilian/botanist
	name = "Botanist"
	limit = 5
	wages = PAY_TRADESMAN
	slot_belt = list(/obj/item/device/pda2/botanist)
	slot_jump = list(/obj/item/clothing/under/rank/hydroponics)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_poc1 = list(/obj/item/paper/botany_guide)
	slot_ears = list(/obj/item/device/radio/headset/civilian)

	New()
		..()
		src.access = get_access("Botanist")
		return

/datum/job/civilian/rancher
	name = "Rancher"
	limit = 1
	wages = PAY_TRADESMAN
	slot_belt = list(/obj/item/device/pda2/botanist)
	slot_jump = list(/obj/item/clothing/under/rank/rancher)
	slot_head = list(/obj/item/clothing/head/cowboy)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_poc1 = list(/obj/item/paper/ranch_guide)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	items_in_backpack = list(/obj/item/fishing_rod/rancher)

	New()
		..()
		src.access = get_access("Rancher")
		return


/datum/job/civilian/chaplain
	name = "Chaplain"
	limit = 1
	wages = PAY_UNTRAINED
	slot_jump = list(/obj/item/clothing/under/rank/chaplain)
	slot_belt = list(/obj/item/device/pda2/chaplain)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_lhan = list(/obj/item/storage/bible)

	New()
		..()
		src.access = get_access("Chaplain")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_chaplain")
		OTHER_START_TRACKING_CAT(M, TR_CAT_CHAPLAINS)
		if (prob(15))
			M.see_invisible = 15

/datum/job/civilian/staff_assistant
	name = "Staff Assistant"
	wages = PAY_UNTRAINED
	no_jobban_from_this_job = 1
	low_priority_job = 1
	cant_allocate_unwanted = 1
	map_can_autooverride = 0
	slot_jump = list(/obj/item/clothing/under/rank)
	slot_foot = list(/obj/item/clothing/shoes/black)

	New()
		..()
		src.access = get_access("Staff Assistant")
		return

/datum/job/civilian/clown
	name = "Clown"
	limit = 1
	wages = PAY_DUMBCLOWN
	linkcolor = "#FF99FF"
	slot_back = list()
	slot_belt = list(/obj/item/storage/fanny/funny)
	slot_mask = list(/obj/item/clothing/mask/clown_hat)
	slot_jump = list(/obj/item/clothing/under/misc/clown)
	slot_foot = list(/obj/item/clothing/shoes/clown_shoes)
	slot_lhan = list(/obj/item/instrument/bikehorn)
	slot_poc1 = list(/obj/item/device/pda2/clown)
	slot_poc2 = list(/obj/item/reagent_containers/food/snacks/plant/banana)
	slot_card = /obj/item/card/id/clown
	slot_ears = list(/obj/item/device/radio/headset/clown)
	change_name_on_spawn = 1

	New()
		..()
		src.access = get_access("Clown")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		// Yaaaaaay!
		M.AddComponent(/datum/component/death_confetti)

		M.bioHolder.AddEffect("clumsy", magical=1)
		M.bioHolder.AddEffect("accent_comic", magical=1) //the clown should ALWAYS have the silly voice
		if(prob(20))
			M.bioHolder.AddEffect("waddle_walk", magical=1)

// AI and Cyborgs

/datum/job/civilian/AI
	name = "AI"
	linkcolor = "#7B7070"
	limit = 1
	//no_late_join = 1
	high_priority_job = 1
	allow_traitors = 0
	cant_spawn_as_rev = 1
	slot_ears = list()
	slot_card = null
	slot_back = list()
	slot_belt = list()
	items_in_backpack = list()

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		return M.AIize()

/datum/job/civilian/cyborg
	name = "Cyborg"
	linkcolor = "#7B7070"
	limit = 8
	//no_late_join = 1
	allow_traitors = 0
	cant_spawn_as_rev = 1
	slot_ears = list()
	slot_card = null
	slot_back = list()
	slot_belt = list()
	items_in_backpack = list()

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		return M.Robotize_MK2()

// Special Cases

/datum/job/special
	linkcolor = "#46afb9" //For the job screen

/datum/job/special/station_builder
	// Used for Construction game mode, where you build the station
	name = "Station Builder"
	allow_traitors = 0
	cant_spawn_as_rev = 1
	limit = 0
	wages = PAY_TRADESMAN
	slot_belt = list(/obj/item/storage/belt/utility/prepared)
	slot_jump = list(/obj/item/clothing/under/rank/engineer)
	slot_foot = list(/obj/item/clothing/shoes/magnetic)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/engineer)
	slot_rhan = list(/obj/item/tank/jetpack)
	slot_eyes = list(/obj/item/clothing/glasses/construction)
	slot_poc1 = list(/obj/item/spacecash/fivehundred)
	slot_poc2 = list(/obj/item/room_planner)
	slot_suit = list(/obj/item/clothing/suit/space/engineer)
	slot_head = list(/obj/item/clothing/head/helmet/space/engineer)
	slot_mask = list(/obj/item/clothing/mask/breath)

	items_in_backpack = list(/obj/item/rcd/construction, /obj/item/rcd_ammo/big, /obj/item/rcd_ammo/big, /obj/item/material_shaper,/obj/item/room_marker)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_engineer")

	New()
		..()
		src.access = get_access("Construction Worker")
		return


/datum/job/special/head_surgeon
	name = "Head Surgeon"
	linkcolor = "#3577AD"
	limit = 0
	wages = PAY_IMPORTANT
	cant_spawn_as_rev = 1
	slot_card = /obj/item/card/id/command
	slot_belt = list(/obj/item/device/pda2/medical_director)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_jump = list(/obj/item/clothing/under/scrub/maroon)
	slot_suit = list(/obj/item/clothing/suit/labcoat)
	slot_ears = list(/obj/item/device/radio/headset/command/md)
	slot_rhan = list(/obj/item/storage/firstaid/docbag)

	New()
		..()
		src.access = get_access("Head Surgeon")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_medical")

/datum/job/special/lawyer
	name = "Lawyer"
	linkcolor = "#af4242"
	wages = PAY_DOCTORATE
	limit = 0
	slot_jump = list(/obj/item/clothing/under/misc/lawyer)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_rhan = list(/obj/item/paper/book/from_file/space_law)
	slot_ears = list(/obj/item/device/radio/headset/civilian)

	New()
		..()
		src.access = get_access("Lawyer")
		return

/datum/job/special/vice_officer
	name = "Vice Officer"
	linkcolor = "#af4242"
	limit = 0
	wages = PAY_TRADESMAN
	allow_traitors = 0
	cant_spawn_as_con = 1
	cant_spawn_as_rev = 1
	receives_badge = 1
	recieves_miranda = 1
	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/device/pda2/security)
	slot_jump = list(/obj/item/clothing/under/misc/vice)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_ears = list( /obj/item/device/radio/headset/security)
	slot_poc1 = list(/obj/item/storage/security_pouch) //replaces sec starter kit
	slot_belt = list(/obj/item/storage/belt/security/assistant)

	New()
		..()
		src.access = get_access("Vice Officer")
		return

/datum/job/special/forensic_technician
	name = "Forensic Technician"
	linkcolor = "#af4242"
	limit = 0
	wages = PAY_TRADESMAN
	cant_spawn_as_rev = 1
	slot_belt = list(/obj/item/device/pda2/security)
	slot_jump = list(/obj/item/clothing/under/color/darkred)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_glov = list(/obj/item/clothing/gloves/latex)
	slot_ears = list(/obj/item/device/radio/headset/security)
	slot_poc1 = list(/obj/item/device/detective_scanner)
	slot_poc2 = list(/obj/item/reagent_containers/food/snacks/ingredient/egg/hardboiled)
	items_in_backpack = list(/obj/item/tank/emergency_oxygen)

	New()
		..()
		src.access = get_access("Forensic Technician")
		return

/datum/job/special/toxins_researcher
	name = "Toxins Researcher"
	linkcolor = "#A645D1"
	limit = 0
	wages = PAY_DOCTORATE
	slot_belt = list(/obj/item/device/pda2/toxins)
	slot_jump = list(/obj/item/clothing/under/rank/scientist)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_mask = list(/obj/item/clothing/mask/gas)
	slot_lhan = list(/obj/item/tank/air)
	slot_ears = list(/obj/item/device/radio/headset/research)

	New()
		..()
		src.access = get_access("Toxins Researcher")
		return

/datum/job/special/research_assistant
	name = "Research Assistant"
	linkcolor = "#A645D1"
	limit = 0
	wages = PAY_UNTRAINED
	low_priority_job = 1
	slot_jump = list(/obj/item/clothing/under/color/white)
	slot_foot = list(/obj/item/clothing/shoes/white)

	New()
		..()
		src.access = get_access("Research Assistant")
		return

/datum/job/special/medical_assistant
	name = "Medical Assistant"
	linkcolor = "#A645D1"
	limit = 0
	wages = PAY_UNTRAINED
	low_priority_job = 1
	slot_jump = list(/obj/item/clothing/under/color/white)
	slot_foot = list(/obj/item/clothing/shoes/white)

	New()
		..()
		src.access = get_access("Medical Assistant")
		return

/datum/job/special/tech_assistant
	name = "Technical Assistant"
	linkcolor = "#ac5f06"
	limit = 0
	wages = PAY_UNTRAINED
	low_priority_job = 1
	slot_jump = list(/obj/item/clothing/under/color/yellow)
	slot_foot = list(/obj/item/clothing/shoes/brown)

	New()
		..()
		src.access = get_access("Technical Assistant")
		return

/datum/job/special/boxer
	name = "Boxer"
	wages = PAY_UNTRAINED
	limit = 0
	slot_jump = list(/obj/item/clothing/under/shorts)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_glov = list(/obj/item/clothing/gloves/boxing)
	alt_names = list("Boxer", "Fighter", "Wrestler")
	change_name_on_spawn = 1

	New()
		..()
		src.access = get_access("Boxer")
		return

/datum/job/special/barber
	name = "Barber"
	wages = PAY_UNTRAINED
	limit = 0
	slot_jump = list(/obj/item/clothing/under/misc/barber)
	slot_head = list(/obj/item/clothing/head/boater_hat)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_poc1 = list(/obj/item/scissors)
	slot_poc2 = list(/obj/item/razor_blade)

	New()
		..()
		src.access = get_access("Barber")
		return

/datum/job/special/tourist
	name = "Tourist"
	limit = 0
	linkcolor = "#FF99FF"
	slot_back = list()
	slot_belt = list(/obj/item/storage/fanny)
	slot_jump = list(/obj/item/clothing/under/misc/tourist)
	slot_poc1 = list(/obj/item/camera_film)
	slot_poc2 = list(/obj/item/spacecash/random/tourist) // Exact amount is randomized.
	slot_foot = list(/obj/item/clothing/shoes/tourist)
	slot_lhan = list(/obj/item/camera)
	slot_rhan = list(/obj/item/storage/photo_album)
	change_name_on_spawn = 1

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		if(prob(25))
			var/morph = pick(/datum/mutantrace/lizard,/datum/mutantrace/skeleton,/datum/mutantrace/ithillid,/datum/mutantrace/martian,/datum/mutantrace/amphibian)
			M.set_mutantrace(morph)


/datum/job/special/space_cowboy
	name = "Space Cowboy"
	linkcolor = "#FF99FF"
	limit = 0
	wages = PAY_UNTRAINED
	slot_jump = list(/obj/item/clothing/under/rank/det)
	slot_belt = list(/obj/item/gun/modular/italian/revolver/basic)
	slot_head = list(/obj/item/clothing/head/cowboy)
	slot_mask = list(/obj/item/clothing/mask/cigarette/random)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	slot_foot = list(/obj/item/clothing/shoes/cowboy)
	slot_poc1 = list(/obj/item/cigpacket/random)
	slot_poc2 = list(/obj/item/device/light/zippo/gold)
	slot_lhan = list(/obj/item/whip)
	slot_back = list(/obj/item/storage/backpack/satchel)

	New()
		..()
		src.access = get_access("Space Cowboy")
		return

/datum/job/special/mime
	name = "Mime"
	limit = 1
	wages = PAY_DUMBCLOWN*2 // lol okay whatever
	slot_belt = list(/obj/item/device/pda2)
	slot_head = list(/obj/item/clothing/head/mime_bowler)
	slot_mask = list(/obj/item/clothing/mask/mime)
	slot_jump = list(/obj/item/clothing/under/misc/mime/alt)
	slot_suit = list(/obj/item/clothing/suit/scarf)
	slot_glov = list(/obj/item/clothing/gloves/latex)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_poc1 = list(/obj/item/pen/crayon/white)
	slot_poc2 = list(/obj/item/paper)
	items_in_backpack = list(/obj/item/baguette)
	change_name_on_spawn = 1

	New()
		..()
		src.access = get_access("Mime")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("mute", magical=1)
		M.bioHolder.AddEffect("blankman", magical=1)
		if(prob(20))
			M.bioHolder.AddEffect("noir", magical=1)

// randomizd gimmick jobs

/datum/job/special/random
	limit = 0
	//requires_whitelist = 1
	name = "Hollywood Actor"
	wages = PAY_UNTRAINED
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/suit/purple)
	//change_name_on_spawn = 1

	New()
		..()
		if (prob(15))
			limit = 1
		if (src.alt_names.len)
			name = pick(src.alt_names)


/datum/job/special/random/vip
	name = "VIP"
	wages = PAY_EXECUTIVE
	linkcolor = "#af4242"
	slot_jump = list(/obj/item/clothing/under/suit)
	slot_head = list(/obj/item/clothing/head/that)
	slot_eyes = list(/obj/item/clothing/glasses/monocle)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_lhan = list(/obj/item/storage/secure/sbriefcase)
	items_in_backpack = list(/obj/item/baton/cane)
	alt_names = list("Senator", "President", "CEO", "Board Member", "Mayor", "Vice-President", "Governor")

	New()
		..()
		src.access = get_access("VIP")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		var/obj/item/storage/secure/sbriefcase/B = M.find_type_in_hand(/obj/item/storage/secure/sbriefcase)
		if (B && istype(B))
			var/obj/item/material_piece/gold/G = new()
			G.set_loc(B)
			G = new /obj/item/material_piece/gold()
			G.set_loc(B)

		return


/datum/job/special/random/inspector
	name = "Inspector"
	wages = PAY_IMPORTANT
	recieves_miranda = 1
	cant_spawn_as_rev = 1
	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/device/pda2/heads)
	slot_jump = list(/obj/item/clothing/under/misc/lawyer/black) // so they can slam tables
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/command)
	slot_head = list(/obj/item/clothing/head/NTberet)
	slot_suit = list(/obj/item/clothing/suit/armor/NT)
	slot_eyes = list(/obj/item/clothing/glasses/regular)
	slot_lhan = list(/obj/item/storage/briefcase)
	items_in_backpack = list(/obj/item/device/flash)

	New()
		..()
		src.access = get_access("Inspector")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		var/obj/item/storage/briefcase/B = M.find_type_in_hand(/obj/item/storage/briefcase)
		if (B && istype(B))
			new /obj/item/instrument/whistle(B)
			new /obj/item/clipboard/with_pen(B)

		return

/datum/job/special/random/director
	name = "Regional Director"
	recieves_miranda = 1
	cant_spawn_as_rev = 1
	wages = PAY_EXECUTIVE

	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/device/pda2/heads)
	slot_jump = list(/obj/item/clothing/under/misc/NT)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/command)
	slot_head = list(/obj/item/clothing/head/NTberet)
	slot_suit = list(/obj/item/clothing/suit/wcoat)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	slot_lhan = list(/obj/item/clipboard/with_pen)
	items_in_backpack = list(/obj/item/device/flash)

	New()
		..()
		src.access = get_all_accesses()

/datum/job/special/random/diplomat
	name = "Diplomat"
	wages = PAY_DUMBCLOWN
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_jump = list(/obj/item/clothing/under/misc/lawyer)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	alt_names = list("Diplomat", "Ambassador")
	cant_spawn_as_rev = 1
	change_name_on_spawn = 1

	New()
		..()
		src.access = get_access("Diplomat")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/morph = pick(/datum/mutantrace/lizard,/datum/mutantrace/skeleton,/datum/mutantrace/ithillid,/datum/mutantrace/martian,/datum/mutantrace/amphibian,/datum/mutantrace/blob,/datum/mutantrace/cow)
		M.set_mutantrace(morph)

/datum/job/special/random/testsubject
	name = "Test Subject"
	wages = PAY_DUMBCLOWN
	slot_jump = list(/obj/item/clothing/under/shorts)
	slot_mask = list(/obj/item/clothing/mask/monkey_translator)
	change_name_on_spawn = 1
	starting_mutantrace = /datum/mutantrace/monkey

/datum/job/special/random/musician
	name = "Musician"
	wages = PAY_UNTRAINED
	slot_jump = list(/obj/item/clothing/under/suit/pinstripe)
	slot_head = list(/obj/item/clothing/head/flatcap)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	items_in_backpack = list(/obj/item/instrument/saxophone,/obj/item/instrument/guitar,/obj/item/instrument/bagpipe,/obj/item/instrument/fiddle)

/datum/job/special/random/union
	name = "Union Rep"
	wages = PAY_TRADESMAN
	slot_jump = list(/obj/item/clothing/under/misc/lawyer)
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	alt_names = list("Assistants Union Rep", "Cyborgs Union Rep", "Union Rep", "Security Union Rep", "Doctors Union Rep", "Engineers Union Rep", "Miners Union Rep")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		var/obj/item/storage/briefcase/B = M.find_type_in_hand(/obj/item/storage/briefcase)
		if (B && istype(B))
			new /obj/item/clipboard/with_pen(B)

		return

/datum/job/special/random/salesman
	name = "Salesman"
	wages = PAY_TRADESMAN
	slot_suit = list(/obj/item/clothing/suit/merchant)
	slot_jump = list(/obj/item/clothing/under/gimmick/merchant)
	slot_head = list(/obj/item/clothing/head/merchant_hat)
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	alt_names = list("Salesman", "Merchant")
	change_name_on_spawn = 1

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		if(prob(33))
			var/morph = pick(/datum/mutantrace/lizard,/datum/mutantrace/skeleton,/datum/mutantrace/ithillid,/datum/mutantrace/martian,/datum/mutantrace/amphibian)
			M.set_mutantrace(morph)

		var/obj/item/storage/briefcase/B = M.find_type_in_hand(/obj/item/storage/briefcase)
		if (B && istype(B))
			var/obj/item/material_piece/gold/G = new()
			G.set_loc(B)
			G = new()
			G.set_loc(B)

		return

/datum/job/special/random/coach
	name = "Coach"
	wages = PAY_UNTRAINED
	slot_jump = list(/obj/item/clothing/under/jersey)
	slot_suit = list(/obj/item/clothing/suit/armor/vest/macho)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_poc1 = list(/obj/item/instrument/whistle)
	slot_glov = list(/obj/item/clothing/gloves/boxing)
	items_in_backpack = list(/obj/item/football,/obj/item/football,/obj/item/basketball,/obj/item/basketball)

/datum/job/special/random/journalist
	name = "Journalist"
	wages = PAY_UNTRAINED
	slot_jump = list(/obj/item/clothing/under/suit/red)
	slot_head = list(/obj/item/clothing/head/fedora)
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_poc1 = list(/obj/item/camera)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	items_in_backpack = list(/obj/item/camera_film/large)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		var/obj/item/storage/briefcase/B = M.find_type_in_hand(/obj/item/storage/briefcase)
		if (B && istype(B))
			new /obj/item/device/camera_viewer(B)
			new /obj/item/clothing/head/helmet/camera(B)
			new /obj/item/device/audio_log(B)
			new /obj/item/clipboard/with_pen(B)

		return

/datum/job/special/random/beekeeper
	name = "Apiculturist"
	wages = PAY_TRADESMAN
	slot_jump = list(/obj/item/clothing/under/rank/beekeeper)
	slot_suit = list(/obj/item/clothing/suit/bio_suit/beekeeper)
	slot_head = list(/obj/item/clothing/head/bio_hood/beekeeper)
	slot_poc1 = list(/obj/item/reagent_containers/food/snacks/beefood)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_belt = list(/obj/item/device/pda2/botanist)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	items_in_backpack = list(/obj/item/bee_egg_carton, /obj/item/bee_egg_carton, /obj/item/bee_egg_carton, /obj/item/reagent_containers/food/snacks/beefood, /obj/item/reagent_containers/food/snacks/beefood)
	alt_names = list("Apiculturist", "Apiarist")

	New()
		..()
		src.access = get_access("Apiculturist")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		if (prob(15))
			var/obj/critter/domestic_bee/bee = new(get_turf(M))
			bee.beeMom = M
			bee.beeMomCkey = M.ckey
			bee.name = pick_string("bee_names.txt", "beename")
			bee.name = replacetext(bee.name, "larva", "bee")

		M.bioHolder.AddEffect("bee", magical=1) //They're one with the bees!

/datum/job/special/random/souschef
	name = "Sous-Chef"
	wages = PAY_UNTRAINED
	slot_belt = list(/obj/item/device/pda2/chef)
	slot_jump = list(/obj/item/clothing/under/misc/souschef)
	slot_foot = list(/obj/item/clothing/shoes/chef)
	slot_head = list(/obj/item/clothing/head/souschefhat)
	slot_suit = list(/obj/item/clothing/suit/apron)
	slot_ears = list(/obj/item/device/radio/headset/civilian)

	New()
		..()
		src.access = get_access("Sous-Chef")
		return

/datum/job/special/random/waiter
	name = "Waiter"
	wages = PAY_UNTRAINED
	slot_jump = list(/obj/item/clothing/under/rank/bartender)
	slot_suit = list(/obj/item/clothing/suit/wcoat)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_lhan = list(/obj/item/plate/tray)
	items_in_backpack = list(/obj/item/storage/box/glassbox,/obj/item/storage/box/cutlery)

	New()
		..()
		src.access = get_access("Waiter")
		return

/datum/job/special/random/radioshowhost
	name = "Radio Show Host"
	wages = PAY_TRADESMAN
#ifdef MAP_OVERRIDE_OSHAN
	limit = 1
	special_spawn_location = 0
#elif defined(MAP_OVERRIDE_CRAG)
	limit = 1
	special_spawn_location = 0
#else
	limit = 1
	special_spawn_location = 1
	spawn_x = 276
	spawn_y = 257
	spawn_z = 3
#endif
	slot_ears = list(/obj/item/device/radio/headset/command/radio_show_host)
	slot_eyes = list(/obj/item/clothing/glasses/regular)
	slot_jump = list(/obj/item/clothing/under/shirt_pants)
	slot_card = /obj/item/card/id/civilian
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_back = list(/obj/item/storage/backpack/satchel)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/reagent_containers/food/drinks/coffee)
	items_in_backpack = list(/obj/item/device/camera_viewer, /obj/item/device/audio_log, /obj/item/storage/box/record/radio/host)
	alt_names = list("Radio Show Host", "Talk Show Host")
	change_name_on_spawn = 1

	New()
		..()
		limit = 0 //Disables radio host regardless of map settings/the 15% random roll (it's not clean but it works)
		src.access = get_access("Radio Show Host")
		return

#ifdef HALLOWEEN
/*
 * Halloween jobs
 */
ABSTRACT_TYPE(/datum/job/special/halloween)
/datum/job/special/halloween
	linkcolor = "#FF7300"

/datum/job/special/halloween/blue_clown
	name = "Blue Clown"
	wages = PAY_DUMBCLOWN
	limit = 1
	change_name_on_spawn = 1
	slot_mask = list(/obj/item/clothing/mask/clown_hat/blue)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/misc/clown/blue)
	slot_card = /obj/item/card/id/clown
	slot_foot = list(/obj/item/clothing/shoes/clown_shoes/blue)
	slot_belt = list(/obj/item/storage/fanny/funny)
	slot_poc1 = list(/obj/item/bananapeel)
	slot_poc2 = list(/obj/item/device/pda2/clown)
	slot_lhan = list(/obj/item/instrument/bikehorn)

	New()
		..()
		src.access = get_access("Clown")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("regenerator", magical=1)

/datum/job/special/halloween/candy_salesman
	name = "Candy Salesman"
	wages = PAY_UNTRAINED
	limit = 1
	slot_head = list(/obj/item/clothing/head/that/purple)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/suit/purple)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/storage/pill_bottle/cyberpunk)
	slot_poc2 = list(/obj/item/storage/pill_bottle/catdrugs)
	items_in_backpack = list(/obj/item/storage/goodybag, /obj/item/kitchen/everyflavor_box, /obj/item/item_box/heartcandy, /obj/item/kitchen/peach_rings)

	New()
		..()
		src.access = get_access("Salesman")
		return

/datum/job/special/halloween/pumpkin_head
	name = "Pumpkin Head"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = 1
	slot_head = list(/obj/item/clothing/head/pumpkin)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/color/orange)
	slot_foot = list(/obj/item/clothing/shoes/orange)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/reagent_containers/food/snacks/candy/candy_corn)
	slot_poc2 = list(/obj/item/item_box/assorted/stickers/stickers_limited)

	New()
		..()
		src.access = get_access("Staff Assistant")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("quiet_voice", magical=1)

/*
/datum/job/special/halloween/wanna_bee
	name = "WannaBEE"
	wages = PAY_UNTRAINED
	limit = 1

	slot_head = /obj/item/clothing/head/headband/bee
	slot_suit = /obj/item/clothing/suit/bee
	slot_ears = /obj/item/device/radio/headset
	slot_jump = /obj/item/clothing/under/rank/beekeeper
	slot_foot = /obj/item/clothing/shoes/black
	slot_belt = /obj/item/device/pda2
	slot_poc1 = /obj/item/reagent_containers/food/snacks/ingredient/egg/bee
	slot_poc2 = /obj/item/reagent_containers/food/snacks/ingredient/egg/bee/buddy
	items_in_backpack = list(/obj/item/reagent_containers/food/snacks/b_cupcake, /obj/item/reagent_containers/food/snacks/ingredient/royal_jelly)

	New()
		..()
		src.access = get_access("Botanist")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("drunk_bee", magical=1)
*/

/datum/job/special/halloween/dracula
	name = "Discount Dracula"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = 1
	slot_head = list(/obj/item/clothing/head/that)
	slot_suit = list(/obj/item/clothing/suit/gimmick/vampire)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/gimmick/vampire)
	slot_foot = list(/obj/item/clothing/shoes/swat)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/reagent_containers/syringe)
	slot_poc2 = list(/obj/item/reagent_containers/glass/beaker/large)
	slot_back = list(/obj/item/storage/backpack/satchel)

	New()
		..()
		src.access = get_access("Staff Assistant")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("aura", magical=1)
		M.bioHolder.AddEffect("cloak_of_darkness", magical=1)

/datum/job/special/halloween/werewolf
	name = "Discount Werewolf"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = 1
	slot_mask = list(/obj/item/clothing/head/werewolf)
	slot_jump = list(/obj/item/clothing/under/shorts)
	slot_suit = list(/obj/item/clothing/suit/gimmick/werewolf)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_belt = list(/obj/item/device/pda2)

	New()
		..()
		src.access = get_access("Staff Assistant")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("jumpy", magical=1)

/datum/job/special/halloween/mummy
	name = "Discount Mummy"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = 1
	slot_mask = list(/obj/item/clothing/mask/mummy)
	slot_jump = list(/obj/item/clothing/under/gimmick/mummy)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_belt = list(/obj/item/device/pda2)

	New()
		..()
		src.access = get_access("Staff Assistant")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("aura", magical=1)
		M.bioHolder.AddEffect("midas", magical=1)

/datum/job/special/halloween/hotdog
	name = "Hot Dog"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = 1
	slot_jump = list(/obj/item/clothing/under/shorts)
	slot_suit = list(/obj/item/clothing/suit/gimmick/hotdog)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_belt = list(/obj/item/device/pda2)
	slot_back = list(/obj/item/storage/backpack/satchel/randoseru)
	slot_poc1 = list(/obj/item/shaker/ketchup)
	slot_poc2 = list(/obj/item/shaker/mustard)

	New()
		..()
		src.access = get_access("Staff Assistant")
		return

/*
/datum/job/special/halloween/godzilla
	name = "Discount Godzilla"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = 1
	slot_head = list(/obj/item/clothing/head/biglizard)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/color/green)
	slot_suit = list(/obj/item/clothing/suit/gimmick/dinosaur)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/toy/figure)
	slot_poc2 = list(/obj/item/toy/figure)

	New()
		..()
		src.access = get_access("Staff Assistant")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("lizard", magical=1)
		M.bioHolder.AddEffect("loud_voice", magical=1)
*/

/datum/job/special/halloween/macho
	name = "Discount Macho Man"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = 1
	slot_head = list(/obj/item/clothing/head/helmet/macho)
	slot_eyes = list(/obj/item/clothing/glasses/macho)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/gimmick/macho)
	slot_foot = list(/obj/item/clothing/shoes/macho)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/reagent_containers/food/snacks/ingredient/sugar)
	slot_poc2 = list(/obj/item/sticker/ribbon/first_place)

	New()
		..()
		src.access = get_access("Staff Assistant")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("accent_brummie", magical=1)

/datum/job/special/halloween/ghost
	name = "Ghost"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = 1
	slot_eyes = list(/obj/item/clothing/glasses/regular/ecto/goggles)
	slot_suit = list(/obj/item/clothing/suit/bedsheet)
	slot_ears = list(/obj/item/device/radio/headset)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("chameleon", magical=1)

/datum/job/special/halloween/ghost_buster
	name = "Ghost Buster"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = 1
	slot_ears = list(/obj/item/device/radio/headset/command/captain)
	slot_eyes = list(/obj/item/clothing/glasses/regular/ecto/goggles)
	slot_jump = list(/obj/item/clothing/under/shirt_pants)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_back = list(/obj/item/storage/backpack/satchel)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/magnifying_glass)
	slot_poc2 = list(/obj/item/shaker/salt)
	items_in_backpack = list(/obj/item/device/camera_viewer, /obj/item/device/audio_log, /obj/item/gun/energy/ghost)
	alt_names = list("Paranormal Activities Investigator", "Spooks Specialist")
	change_name_on_spawn = 1

	New()
		..()
		src.access = get_access("Staff Assistant")
		return

/datum/job/special/halloween/angel
	name = "Angel"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = 1
	slot_head = list(/obj/item/clothing/head/laurels/gold)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/gimmick/birdman)
	slot_foot = list(/obj/item/clothing/shoes/sandal)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/coin)
	slot_poc2 = list(/obj/item/plant/herb/cannabis/white/spawnable)

	New()
		..()
		src.access = get_access("Chaplain")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("shiny", magical=1)
		M.bioHolder.AddEffect("healing_touch", magical=1)

/datum/job/special/halloween/vendor
	name = "Costume Vendor"
	wages = PAY_TRADESMAN
	limit = 1
	change_name_on_spawn = 1
	slot_jump = list(/obj/item/clothing/under/trash_bag)
	slot_foot = list(/obj/item/clothing/shoes/sandal)
	slot_belt = list(/obj/item/device/pda2)
	slot_back = list(/obj/item/storage/backpack/satchel/anello)
	items_in_backpack = list(/obj/item/storage/box/costume/abomination,
	/obj/item/storage/box/costume/werewolf/odd,
	/obj/item/storage/box/costume/monkey,
	/obj/item/storage/box/costume/eighties,
	/obj/item/clothing/head/zombie)

/datum/job/special/halloween/devil
	name = "Devil"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = 1
	slot_head = list(/obj/item/clothing/head/devil)
	slot_mask = list(/obj/item/clothing/mask/moustache/safe)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/misc/lawyer/red/demonic)
	slot_foot = list(/obj/item/clothing/shoes/sandal)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/pen/fancy/satan)
	slot_poc2 = list(/obj/item/contract/juggle)

	New()
		..()
		src.access = get_access("Chaplain")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("hell_fire", magical=1)

/datum/job/special/halloween/superhero
	name = "Discount Superhero"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = 1
	allow_traitors = 0
	allow_spy_theft = 0
	cant_spawn_as_rev = 1
	recieves_miranda = 1
	slot_ears = list(/obj/item/device/radio/headset/security)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses/sechud/superhero)
	slot_glov = list(/obj/item/clothing/gloves/latex/blue)
	slot_jump = list(/obj/item/clothing/under/gimmick/superhero)
	slot_foot = list(/obj/item/clothing/shoes/tourist)
	slot_belt = list(/obj/item/storage/belt/utility/superhero)
	slot_back = list()
	slot_poc2 = list(/obj/item/device/pda2)

	New()
		..()
		src.access = get_access("Security Officer")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_security")
		if(prob(60))
			var/aggressive = pick("eyebeams","cryokinesis")
			var/defensive = pick("fire_resist","cold_resist","food_rad_resist","breathless") // no thermal resist, gotta have some sort of comic book weakness
			var/datum/bioEffect/power/be = M.bioHolder.AddEffect(aggressive, do_stability=0)
			if(aggressive == "eyebeams")
				var/datum/bioEffect/power/eyebeams/eb = be
				eb.stun_mode = 1
				eb.altered = 1
			else
				be.power = 1
				be.altered = 1
			be = M.bioHolder.AddEffect(defensive, do_stability=0)
		else
			var/datum/bioEffect/power/shoot_limb/sl = M.bioHolder.AddEffect("shoot_limb", do_stability=0)
			sl.safety = 1
			sl.altered = 1
			sl.cooldown = 300
			sl.stun_mode = 1
			var/datum/bioEffect/regenerator/r = M.bioHolder.AddEffect("regenerator", do_stability=0)
			r.regrow_prob = 10
		var/datum/bioEffect/power/be = M.bioHolder.AddEffect("adrenaline", do_stability=0)
		be.safety = 1
		be.altered = 1


/datum/job/special/halloween/remy
	name = "Remy"
	wages = PAY_DUMBCLOWN
	requires_whitelist = 1
	limit = 1
	allow_traitors = 0
	slot_ears = list()
	slot_card = null
	slot_back = list()

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.critterize(/mob/living/critter/small_animal/mouse/remy)

/datum/job/special/halloween/bumblespider
	name = "Bumblespider"
	wages = PAY_DUMBCLOWN
	requires_whitelist = 1
	limit = 1
	allow_traitors = 0
	slot_ears = list()
	slot_card = null
	slot_back = list()

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.critterize(/mob/living/critter/spider/nice)

/datum/job/special/halloween/crow
	name = "Crow"
	wages = PAY_DUMBCLOWN
	requires_whitelist = 1
	limit = 1
	allow_traitors = 0
	slot_ears = list()
	slot_card = null
	slot_back = list()

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.critterize(/mob/living/critter/small_animal/bird/crow)

// end halloween jobs
#endif

/*
/datum/job/special/turkey
	name = "Turkey"
	linkcolor = "#FF7300"
	wages = PAY_DUMBCLOWN
	requires_whitelist = 1
	limit = 1
	allow_traitors = 0
	slot_ears = list()
	slot_card = null
	slot_back = list()

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/type = pick(/mob/living/critter/small_animal/bird/turkey/gobbler, /mob/living/critter/small_animal/bird/turkey/hen)
		M.critterize(type)
*/

/datum/job/special/syndicate_operative
	name = "Syndicate"
	wages = 0
	limit = 0
	linkcolor = "#880000"
	slot_ears = list() // So they don't get a default headset and stuff first.
	slot_card = null
	slot_glov = list()
	slot_foot = list()
	slot_back = list()
	slot_belt = list()
	spawn_id = 0

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		if (ticker?.mode && istype(ticker.mode, /datum/game_mode/nuclear))
			M.real_name = "[syndicate_name_foss()] Operative #[ticker.mode:agent_number]"
			ticker.mode:agent_number++
		else
			M.real_name = "Syndicate Agent"

		antagify(M, "Syndicate Agent", 0)

		equip_syndicate(M)
		return

/datum/job/special/syndicate_weak
	linkcolor = "#880000"
	name = "Junior Syndicate Operative"
	limit = 0
	wages = 0
	slot_back = list(/obj/item/storage/backpack/satchel)
	slot_belt = list()
	slot_jump = list(/obj/item/clothing/under/misc/syndicate)
	slot_suit = list(/obj/item/clothing/suit/armor/vest)
	slot_head = list(/obj/item/clothing/head/helmet/swat)
	slot_foot = list(/obj/item/clothing/shoes/swat)
	slot_ears = list()
	slot_mask = list(/obj/item/clothing/mask/breath)
	slot_card = null		///obj/item/card/id/
	slot_poc1 = list(/obj/item/reagent_containers/pill/tox)
	slot_poc2 = list(/obj/item/stackable_ammo/pistol/zaubertube/ten)
	slot_lhan = list()
	slot_rhan = list(/obj/item/gun/modular/soviet/long/advanced)

	special_setup(var/mob/living/carbon/human/M)
		..()
		antagify(M, "Syndicate Agent", 0)

/datum/job/special/syndicate_weak/no_ammo
	name = "Poorly Equipped Junior Syndicate Operative"
	slot_poc2 = list()
	slot_poc1 = list()
// hidden jobs for nt-so vs syndicate spec-ops

/datum/job/special/juicer/
	linkcolor = "#0066ff"
	name = "Juicer"
	limit = 0
	wages = 0
	slot_card = null		///obj/item/card/id/

/datum/job/special/juicer/specialist
	linkcolor = "#cc8899"
	name = "Juicer Security"
	allow_traitors = 0
	allow_spy_theft = 0
	cant_spawn_as_rev = 1

	//slot_back = list(/obj/item/gun/energy/blaster_cannon)
	slot_belt = list(/obj/item/storage/fanny)
	//more
/datum/job/special/juicer/clubfert
	linkcolor = "#0066ff"
	name = "Juicer Clubgoer"
	slot_jump = list(/obj/item/clothing/under/gimmick/eightiesmens) //temporary until i can get a good list together, this supports pick() doesn't it?
	slot_foot = list(/obj/item/clothing/shoes/heels/dancin)
	special_spawn_location = 1 //club, duh
	spawn_x = 194 //hopefully this won't futz with npc spawns
	spawn_y = 131
	spawn_z = 5

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.set_mutantrace(/datum/mutantrace/fert) //they're all dooks, huh?

/datum/job/special/syndicate_specialist
	linkcolor = "#C70039"
	name = "Syndicate Special Operative"
	limit = 0
	wages = 0
	allow_traitors = 0
	allow_spy_theft = 0
	cant_spawn_as_rev = 1
	recieves_implant = /obj/item/implant/microbomb
	slot_back = list(/obj/item/storage/backpack/satchel)
	slot_belt = list(/obj/item/gun/modular/italian/revolver/improved)
	slot_jump = list(/obj/item/clothing/under/misc/syndicate)
	slot_suit = list(/obj/item/clothing/suit/space/syndicate/specialist)
	slot_head = list(/obj/item/clothing/head/helmet/space/syndicate/specialist)
	slot_foot = list(/obj/item/clothing/shoes/swat)
	slot_ears = list( /obj/item/device/radio/headset/syndicate) //needs their own secret channel
	slot_mask = list(/obj/item/clothing/mask/breath)
	slot_card = /obj/item/card/id/
	//slot_poc1 = list(/obj/item/storage/pouch/assault_rifle)
	//slot_poc2 = list(/obj/item/storage/pouch/bullet_9mm)
	slot_lhan = list(/obj/item/remote/syndicate_teleporter)
	slot_rhan = list(/obj/item/tank/jetpack)
	items_in_backpack = list(///obj/item/gun/kinetic/assault_rifle,
							/obj/item/device/pda2,
							/obj/item/old_grenade/stinger/frag,
							/obj/item/breaching_charge)

	New()
		..()
		src.access = syndicate_spec_ops_access()

#ifdef MAP_OVERRIDE_OSHAN
	special_spawn_location = 0
#else
	special_spawn_location = 1
	spawn_x = 96
	spawn_y = 272
	spawn_z = 2
#endif

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		antagify(M, "Syndicate Agent", 0)
		M.show_text("<b>The assault has begun! Head over to the station and kill any and all Nanotrasen personnel you encounter!</b>", "red")

/datum/job/special/ntso_specialist
	linkcolor = "#3348ff"
	name = "Nanotrasen Special Operative"
	limit = 0
	wages = PAY_IMPORTANT
	allow_traitors = 0
	allow_spy_theft = 0
	cant_spawn_as_rev = 1
	recieves_implant = /obj/item/implant/health
	slot_back = list(/obj/item/storage/backpack/NT)
	slot_belt = list(/obj/item/storage/belt/security)
	slot_jump = list(/obj/item/clothing/under/misc/turds)
	slot_suit = list(/obj/item/clothing/suit/space/ntso)
	slot_head = list(/obj/item/clothing/head/helmet/space/ntso)
	slot_foot = list(/obj/item/clothing/shoes/swat)
	slot_ears = list(/obj/item/device/radio/headset/command/nt) //needs their own secret channel
	slot_mask = list(/obj/item/clothing/mask/breath)
	slot_card = /obj/item/card/id/command
	slot_poc1 = list(/obj/item/spacecash/fivehundred)
	slot_poc2 = list(/obj/item/rubberduck)
	items_in_backpack = list(/obj/item/gun/modular/NT/pistol_sec,
							/obj/item/device/pda2/heads,
							/obj/item/old_grenade/stinger/frag,
							/obj/item/storage/firstaid/regular,
							/obj/item/stackable_ammo/pistol/NT/HP/ten,
							/obj/item/gun/modular/italian/revolver/basic)

	New()
		..()
		src.access = get_all_accesses()
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_security")
		M.show_text("<b>Hostile assault force incoming! Defend the crew from the attacking Syndicate Special Operatives!</b>", "blue")


// Use this one for late respawns to dael with existing antags. they are weaker cause they dont get a laser rifle or frags
/datum/job/special/ntso_specialist_weak
	linkcolor = "#3348ff"
	name = "Nanotrasen Security Operative"
	limit = 1 // backup during HELL WEEK. players will probably like it
	wages = PAY_TRADESMAN
	requires_whitelist = 1
	requires_supervisor_job = "Head of Security"
	allow_traitors = 0
	allow_spy_theft = 0
	cant_spawn_as_rev = 1
	receives_badge = 1
	recieves_miranda = 1
	recieves_implant = /obj/item/implant/health
	slot_back = list(/obj/item/storage/backpack/NT)
	slot_belt = list(/obj/item/storage/belt/security) //special secbelt subtype that spawns with the NTSO gear inside
	slot_jump = list(/obj/item/clothing/under/misc/turds)
	slot_head = list(/obj/item/clothing/head/NTberet)
	slot_foot = list(/obj/item/clothing/shoes/swat)
	slot_glov = list(/obj/item/clothing/gloves/swat/NT)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses/sechud)
	slot_ears = list(/obj/item/device/radio/headset/command/nt) //needs their own secret channel
	slot_card = /obj/item/card/id/command
	slot_poc1 = list(/obj/item/device/pda2/ntso)
	slot_poc2 = list(/obj/item/spacecash/fivehundred)
	items_in_backpack = list(/obj/item/storage/firstaid/regular,
							/obj/item/clothing/head/helmet/space/ntso,
							/obj/item/clothing/suit/space/ntso)

	New()
		..()
		src.access = get_access("Security Officer") + list(access_heads)
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_security")
		M.show_text("<b>Defend the crew from all current threats!</b>", "blue")


/datum/job/special/headminer
	name = "Head of Mining"
	limit = 0
	wages = PAY_IMPORTANT
	linkcolor = "#7B750F"
	cant_spawn_as_rev = 1
	slot_card = /obj/item/card/id/command
	slot_belt = list(/obj/item/device/pda2/mining)
	slot_jump = list(/obj/item/clothing/under/rank/overalls)
	slot_foot = list(/obj/item/clothing/shoes/orange)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/command/ce)
	items_in_backpack = list(/obj/item/tank/emergency_oxygen,/obj/item/crowbar)

	New()
		..()
		src.access = get_access("Head of Mining")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("training_miner")

/datum/job/special/machoman
	name = "Macho Man"
	linkcolor = "#9E0E4D"
	limit = 0
	slot_ears = list()
	slot_card = null
	slot_back = list()
	items_in_backpack = list()

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.machoize()

/datum/job/special/meatcube
	name = "Meatcube"
	linkcolor = "#990000"
	limit = 0
	allow_traitors = 0
	slot_ears = list()
	slot_card = null
	slot_back = list()
	items_in_backpack = list()

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.cubeize(INFINITY)

/datum/job/special/AI
	name = "AI"
	linkcolor = "#999999"
	limit = 0
	wages = 0
	allow_traitors = 0
	cant_spawn_as_rev = 1
	slot_ears = list()
	slot_card = null
	slot_back = list()
	slot_belt = list()
	items_in_backpack = list()

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		return M.AIize()

/datum/job/special/cyborg
	name = "Cyborg"
	linkcolor = "#999999"
	limit = 0
	wages = 0
	allow_traitors = 0
	cant_spawn_as_rev = 1
	slot_ears = list()
	slot_card = null
	slot_back = list()
	slot_belt = list()
	items_in_backpack = list()

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		return M.Robotize_MK2()

/datum/job/special/ghostdrone
	name = "Drone"
	linkcolor = "#999999"
	limit = 0
	wages = 0
	allow_traitors = 0
	slot_ears = list()
	slot_card = null
	slot_back = list()
	items_in_backpack = list()

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		droneize(M, 0)

/datum/job/daily //Special daily jobs
	linkcolor = "#3bc48b"

/datum/job/daily/sunday
	name = "Boxer"
	wages = PAY_UNTRAINED
	limit = 4
	slot_jump = list(/obj/item/clothing/under/shorts)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_glov = list(/obj/item/clothing/gloves/boxing)
	change_name_on_spawn = 1

	New()
		..()
		src.access = get_access("Boxer")
		return

/datum/job/daily/monday
	name = "Mime"
	limit = 1
	wages = PAY_DUMBCLOWN*2
	slot_belt = list(/obj/item/device/pda2)
	slot_head = list(/obj/item/clothing/head/mime_bowler)
	slot_mask = list(/obj/item/clothing/mask/mime)
	slot_jump = list(/obj/item/clothing/under/misc/mime/alt)
	slot_suit = list(/obj/item/clothing/suit/scarf)
	slot_glov = list(/obj/item/clothing/gloves/latex)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_poc1 = list(/obj/item/pen/crayon/white)
	slot_poc2 = list(/obj/item/paper)
	items_in_backpack = list(/obj/item/baguette)
	change_name_on_spawn = 1

	New()
		..()
		src.access = get_access("Mime")
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("mute", magical=1)

/datum/job/daily/tuesday
	name = "Barber"
	wages = PAY_UNTRAINED
	limit = 1
	slot_jump = list(/obj/item/clothing/under/misc/barber)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_poc1 = list(/obj/item/scissors)
	slot_poc2 = list(/obj/item/razor_blade)

	New()
		..()
		src.access = get_access("Barber")
		return

/datum/job/daily/wednesday
	name = "Mail Thief"
	wages = PAY_TRADESMAN
	limit = 2
	slot_jump = list(/obj/item/clothing/under/misc/mail/syndicate)
	slot_head = list(/obj/item/clothing/head/mailcap)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_back = list(/obj/item/storage/backpack/satchel)
	slot_ears = list(/obj/item/device/radio/headset/mail)
	items_in_backpack = list(/obj/item/wrapping_paper, /obj/item/paper_bin, /obj/item/scissors, /obj/item/stamp)
	alt_names = list("Head of Undeliverying", "Head of Mailtheft")

	New()
		..()
		src.access = get_access("Mailcarrier")
		return

/datum/job/daily/thursday
	name = "Lawyer"
	linkcolor = "#af4242"
	wages = PAY_DOCTORATE
	limit = 4
	slot_jump = list(/obj/item/clothing/under/misc/lawyer)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_ears = list(/obj/item/device/radio/headset/civilian)

	New()
		..()
		src.access = get_access("Lawyer")
		return


/datum/job/daily/friday
	name = "Tourist"
	limit = 100
	wages = 0
	linkcolor = "#FF99FF"
	slot_back = null
	slot_belt = list(/obj/item/storage/fanny)
	slot_jump = list(/obj/item/clothing/under/misc/tourist)
	slot_poc1 = list(/obj/item/camera_film)
	slot_poc2 = list(/obj/item/spacecash/random/tourist) // Exact amount is randomized.
	slot_foot = list(/obj/item/clothing/shoes/tourist)
	slot_lhan = list(/obj/item/camera)
	slot_rhan = list(/obj/item/storage/photo_album)
	change_name_on_spawn = 1

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		if(prob(33))
			var/morph = pick(/datum/mutantrace/lizard,/datum/mutantrace/skeleton,/datum/mutantrace/ithillid,/datum/mutantrace/martian,/datum/mutantrace/amphibian)
			M.set_mutantrace(morph)

/datum/job/daily/saturday
	name = "Part-time Vice Officer"
	linkcolor = "#af4242"
	limit = 2
	wages = PAY_TRADESMAN
	allow_traitors = 0
	cant_spawn_as_con = 1
	cant_spawn_as_rev = 1
	receives_badge = 1
	recieves_miranda = 1
	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/device/pda2/security)
	slot_jump = list(/obj/item/clothing/under/misc/vice)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/security)
	slot_poc1 = list(/obj/item/storage/security_pouch) //replaces sec starter kit
	slot_belt = list(/obj/item/storage/belt/security/assistant)

	New()
		..()
		src.access = get_access("Vice Officer")
		return

/datum/job/battler
	name = "Battler"
	limit = -1
/*
ABSTRACT_TYPE(/datum/job/special/pod_wars)
/datum/job/special/pod_wars
	name = "Pod_Wars"
#ifdef MAP_OVERRIDE_POD_WARS
	limit = -1
#else
	limit = 0
#endif
	allow_traitors = 0
	cant_spawn_as_rev = 1
	var/team = 0 //1 = NT, 2 = SY

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		if (!M.abilityHolder)
			M.abilityHolder = new /datum/abilityHolder/pod_pilot(src)
			M.abilityHolder.owner = src
		else if (istype(M.abilityHolder, /datum/abilityHolder/composite))
			var/datum/abilityHolder/composite/AH = M.abilityHolder
			AH.addHolder(/datum/abilityHolder/pod_pilot)

		//stuff for headsets
		if (istype(ticker.mode, /datum/game_mode/pod_wars))
			var/datum/game_mode/pod_wars/mode = ticker.mode
			if (team == 1)
				M.mind.special_role = mode.team_NT?.name
				setup_headset(M.ears, mode.team_NT?.comms_frequency)
			else if (team == 2)
				M.mind.special_role = mode.team_SY?.name
				setup_headset(M.ears, mode.team_SY?.comms_frequency)

	proc/setup_headset(var/obj/item/device/radio/headset/headset, var/freq)
		if (istype(headset))
			headset.set_secure_frequency("g",freq)
			headset.secure_classes["g"] = RADIOCL_SYNDICATE
			headset.cant_self_remove = 0
			headset.cant_other_remove = 0

	nanotrasen
		name = "NanoTrasen Pod Pilot"
		linkcolor = "#3348ff"
		no_jobban_from_this_job = 1
		low_priority_job = 1
		cant_allocate_unwanted = 1
		access = list(access_heads, access_medical, access_medical_lockers)
		team = 1

		slot_back = list(/obj/item/storage/backpack/NT)
		slot_belt = list(/obj/item/gun/energy/blaster_pod_wars/nanotrasen)
		slot_jump = list(/obj/item/clothing/under/misc/turds)
		slot_head = list(/obj/item/clothing/head/helmet/space/nanotrasen/pilot)
		slot_suit = list(/obj/item/clothing/suit/space/nanotrasen/pilot)
		slot_foot = list(/obj/item/clothing/shoes/swat)
		slot_card = /obj/item/card/id/pod_wars/nanotrasen
		slot_ears = list(/obj/item/device/radio/headset/pod_wars/nanotrasen)
		slot_mask = list(/obj/item/clothing/mask/breath)
		slot_glov = list(/obj/item/clothing/gloves/swat/NT)
		slot_poc1 = list(/obj/item/tank/emergency_oxygen)
		slot_poc2 = list(/obj/item/device/pda2/pod_wars/nanotrasen)
		items_in_backpack = list(/obj/item/survival_machete, /obj/item/spacecash/hundred)

		commander
			name = "NanoTrasen Commander"
#ifdef MAP_OVERRIDE_POD_WARS
			limit = 1
#else
			limit = 0
#endif
			no_jobban_from_this_job = 0
			high_priority_job = 1
			cant_allocate_unwanted = 1
			access = list(access_heads, access_captain, access_medical, access_medical_lockers, access_engineering_power)

			slot_head = list(/obj/item/clothing/head/NTberet/commander)
			slot_suit = list(/obj/item/clothing/suit/space/nanotrasen/pilot/commander)
			slot_card = /obj/item/card/id/pod_wars/nanotrasen/commander
			slot_ears = list(/obj/item/device/radio/headset/pod_wars/nanotrasen/commander)

	syndicate
		name = "Syndicate Pod Pilot"
		linkcolor = "#FF0000"
		no_jobban_from_this_job = 1
		low_priority_job = 1
		cant_allocate_unwanted = 1
		access = list(access_syndicate_shuttle, access_medical, access_medical_lockers)
		team = 2

		slot_back = list(/obj/item/storage/backpack/syndie)
		slot_belt = list(/obj/item/gun/energy/blaster_pod_wars/syndicate)
		slot_jump = list(/obj/item/clothing/under/misc/syndicate)
		slot_head = list(/obj/item/clothing/head/helmet/space/syndicate/specialist)
		slot_suit = list(/obj/item/clothing/suit/space/syndicate)
		slot_foot = list(/obj/item/clothing/shoes/swat)
		slot_card = /obj/item/card/id/pod_wars/syndicate
		slot_ears = list(/obj/item/device/radio/headset/pod_wars/syndicate)
		slot_mask = list(/obj/item/clothing/mask/breath)
		slot_glov = list(/obj/item/clothing/gloves/swat)
		slot_poc1 = list(/obj/item/tank/emergency_oxygen)
		slot_poc2 = list(/obj/item/device/pda2/pod_wars/syndicate)
		items_in_backpack = list(/obj/item/survival_machete/syndicate, /obj/item/spacecash/hundred)

		commander
			name = "Syndicate Commander"
#ifdef MAP_OVERRIDE_POD_WARS
			limit = 1
#else
			limit = 0
#endif
			no_jobban_from_this_job = 0
			high_priority_job = 1
			cant_allocate_unwanted = 1
			access = list(access_syndicate_shuttle, access_syndicate_commander, access_medical, access_medical_lockers, access_engineering_power)

			slot_head = list(/obj/item/clothing/head/helmet/space/syndicate/commissar_cap)
			slot_suit = list(/obj/item/clothing/suit/space/syndicate/commissar_greatcoat)
			slot_card = /obj/item/card/id/pod_wars/syndicate/commander
			slot_ears = list(/obj/item/device/radio/headset/pod_wars/syndicate/commander)
*/
/datum/job/football
	name = "Football Player"
	limit = -1

/*---------------------------------------------------------------*/

/datum/job/created
	name = "Special Job"

