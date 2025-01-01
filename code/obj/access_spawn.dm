/obj/access_spawn
	name = "access spawn"
	desc = "Sets access of machines on the same turf as it to its access, then destroys itself."
	icon = 'icons/map-editing/mapeditor.dmi'
	icon_state = "access_spawn"

	/*
	 * loop through valid objects in the same location and, if they have no access set, set it to this one
	 */

	New()
		..()
		if (current_state > GAME_STATE_WORLD_INIT)
			SPAWN_DBG(5 DECI SECONDS)
				src.setup()
				qdel(src)

	initialize()
		..()
		src.setup()
		qdel(src)

	proc/setup()
		for (var/obj/machinery/M in src.loc)
			if (!M.req_access)
				M.req_access = src.req_access
			else
				M.req_access += src.req_access
			//todo : autoname doors	here too. var editing is illegal!

#define SPECIAL "#ffa135"
#define MEDICAL "#3daff7"
#define SECURITY "#f73d3d"
#define MORGUE_BLACK "#002135"
#define TOXINS "#a3f73d"
#define RESEARCH "#b23df7"
#define ENGINEERING "#f7af3d"
#define CARGO "#f7e43d"
#define MAINTENANCE "#e5ff32"
#define COMMAND "#00783c"

/obj/access_spawn/admin_override //special admin override access spawner
	name = "admin override access spawn"
	color = SPECIAL

	setup()
		for (var/obj/O in src.loc)
			O.admin_access_override = TRUE

/obj/access_spawn/public
	name = "public access spawn"
	color = SPECIAL

	setup()
		for (var/obj/O in src.loc)
			O.req_access = null

/obj/access_spawn/security
	name = "security access spawn"
	req_access = list(access_security)
	color = SECURITY

/obj/access_spawn/forensics
	name = "forensics access spawn"
	req_access = list(access_forensics_lockers)
	color = SECURITY

/obj/access_spawn/brig
	name = "brig access spawn"
	req_access = list(access_brig)
	color = SECURITY

/obj/access_spawn/medical
	name = "medical access spawn"
	req_access = list(access_medical)
	color = MEDICAL

/obj/access_spawn/morgue
	name = "morgue access spawn"
	req_access = list(access_morgue)
	color = MORGUE_BLACK

/obj/access_spawn/tox
	name = "tox access spawn"
	req_access = list(access_tox)
	color = TOXINS

/obj/access_spawn/tox_storage
	name = "tox access spawn"
	req_access = list(access_tox_storage)
	color = TOXINS

/obj/access_spawn/medlab
	name = "medlab access spawn"
	req_access = list(access_medlab)
	color = MEDICAL

/obj/access_spawn/pathology
	name = "pathology spawn"
	#ifdef CREATE_PATHOGENS
	req_access = list(access_pathology)
	#elif defined(MAP_OVERRIDE_DESTINY) // destiny has patho in genetics
	req_access = list(access_medlab)
	#else
	req_access = list(access_medical)
	#endif
	color = MEDICAL

//no need to fight, just use different access, ya drangus
//this was only relevant to oshan/manta anyway AND I JUST CHECKED AND IT'S NOT EVEN ON OSHAN??
/obj/access_spawn/pathology_research
	name = "research pathology spawn"
	#ifdef CREATE_PATHOGENS
	req_access = list(access_pathology_research)
	#else
	req_access = list(access_research)
	#endif
	color = RESEARCH

/obj/access_spawn/research_director
	name = "RD access spawn"
	req_access = list(access_research_director)
	color = RESEARCH

/obj/access_spawn/maint
	name = "maint access spawn"
	req_access = list(access_maint_tunnels)
	color = MAINTENANCE

/obj/access_spawn/emergency_storage
	name = "emergency storage access spawn"
	req_access = list(access_emergency_storage)
	color = MAINTENANCE

/obj/access_spawn/emergency_storage
	name = "emergency storage access spawn"
	req_access = list(access_emergency_storage)
	color = MAINTENANCE

/obj/access_spawn/centcom
	name = "centcom access spawn"
	req_access = list(access_centcom)
	color = COMMAND

/obj/access_spawn/ai_upload
	name = "ai upload access spawn"
	req_access = list(access_ai_upload)
	color = COMMAND

/obj/access_spawn/teleporter
	name = "teleporter access spawn"
	req_access = list(access_teleporter)
	color = COMMAND

/obj/access_spawn/eva
	name = "eva access spawn"
	req_access = list(access_eva)
	color = COMMAND

/obj/access_spawn/heads
	name = "heads access spawn"
	req_access = list(access_heads)
	color = COMMAND

/obj/access_spawn/captain
	name = "captain access spawn"
	req_access = list(access_captain)
	color = COMMAND

/obj/access_spawn/medical_director
	name = "MD access spawn"
	req_access = list(access_medical_director)
	color = MEDICAL

/obj/access_spawn/head_of_personnel
	name = "HOP access spawn"
	req_access = list(access_head_of_personnel)
	color = COMMAND

/obj/access_spawn/chapel_office
	name = "chapel office access spawn"
	req_access = list(access_chapel_office)
	color = MAINTENANCE

/obj/access_spawn/tech_storage
	name = "tech storage access spawn"
	req_access = list(access_tech_storage)
	color = MAINTENANCE

/obj/access_spawn/research
	name = "research access spawn"
	req_access = list(access_research)
	color = RESEARCH

/obj/access_spawn/bar
	name = "bar access spawn"
	req_access = list(access_bar)
	color = MAINTENANCE

/obj/access_spawn/janitor
	name = "janitor access spawn"
	req_access = list(access_janitor)
	color = MAINTENANCE

/obj/access_spawn/crematorium
	name = "crematorium access spawn"
	req_access = list(access_crematorium)
	color = MAINTENANCE

/obj/access_spawn/kitchen
	name = "kitchen access spawn"
	req_access = list(access_kitchen)
	color = MAINTENANCE

/obj/access_spawn/robotics
	name = "robotics access spawn"
	req_access = list(access_robotics)
	color = MEDICAL

/obj/access_spawn/hangar
	name = "hangar access spawn"
	req_access = list(access_hangar)
	color = CARGO

/obj/access_spawn/cargo
	name = "cargo access spawn"
	req_access = list(access_cargo)
	color = CARGO

/obj/access_spawn/chemistry
	name = "chem access spawn"
	req_access = list(access_chemistry)
	color = RESEARCH

/obj/access_spawn/hydro
	name = "hydro access spawn"
	req_access = list(access_hydro)
	color = MAINTENANCE

/obj/access_spawn/rancher
	name = "ranch access spawn"
	req_access = list(access_ranch)
	color = MAINTENANCE

/obj/access_spawn/hos
	name = "HOS access spawn"
	req_access = list(access_maxsec)
	color = SECURITY

/obj/access_spawn/sec_lockers
	name = "security weapons access spawn"
	req_access = list(access_securitylockers)
	color = SECURITY

/obj/access_spawn/carry_permit
	name = "carry permit access spawn"
	req_access = list(access_carrypermit)
	color = SECURITY

/obj/access_spawn/engineering
	name = "engineering access spawn"
	req_access = list(access_engineering)
	color = ENGINEERING

/obj/access_spawn/engineering_storage
	name = "engineering storage access spawn"
	req_access = list(access_engineering_storage)
	color = ENGINEERING

/obj/access_spawn/engineering_eva
	name = "engineering EVA access spawn"
	req_access = list(access_engineering_eva)
	color = ENGINEERING

/obj/access_spawn/engineering_power
	name = "engineering power access spawn"
	req_access = list(access_engineering_power)
	color = ENGINEERING

/obj/access_spawn/engineering_engine
	name = "engineering engine access spawn"
	req_access = list(access_engineering_engine)
	color = ENGINEERING

/obj/access_spawn/engineering_power
	name = "engineering power access spawn"
	req_access = list(access_engineering_power)
	color = ENGINEERING

/obj/access_spawn/engineering_mechanic
	name = "engineering mechanics access spawn"
	req_access = list(access_engineering_mechanic)
	color = ENGINEERING

/obj/access_spawn/engineering_atmos
	name = "engineering atmos access spawn"
	req_access = list(access_engineering_atmos)
	color = ENGINEERING

/obj/access_spawn/engineering_control
	name = "engineering control access spawn"
	req_access = list(access_engineering_control)
	color = ENGINEERING

/obj/access_spawn/engineering_chief
	name = "CE access spawn"
	req_access = list(access_engineering_chief)
	color = ENGINEERING

/obj/access_spawn/quartermaster
	name = "quartermaster access spawn"
	req_access = list(access_quartermaster)
	color = CARGO

/obj/access_spawn/mining_shuttle
	name = "mining_shuttle access spawn"
	req_access = list(access_mining_shuttle)
	color = CARGO

/obj/access_spawn/mining
	name = "mining EVA access spawn"
	req_access = list(access_mining)
	color = CARGO

/obj/access_spawn/scrapping

	name = "scrapping access spwan"
	req_access = list(access_scrapping)
	color = CARGO

/obj/access_spawn/mining_outpost
	name = "mining_outpost access spawn"
	req_access = list(access_mining_outpost)
	color = CARGO

/obj/access_spawn/syndie_shuttle
	name = "syndie_shuttle access spawn"
	req_access = list(access_syndicate_shuttle)
	color = SECURITY

//////////////////////owlzone access///////
/obj/access_spawn/owlmaint
	name = "owlery maint access spawn"
	req_access = list(access_owlerymaint)
	color = ENGINEERING

/obj/access_spawn/owlcommand
	name = "owlery command access spawn"
	req_access = list(access_owlerysec)
	color = COMMAND

/obj/access_spawn/owlsecurity
	name = "owlery sec access spawn"
	req_access = list(access_owlerycommand)
	color = SECURITY

/obj/access_spawn/polariscargo
	name = "polaris cargo access spawn"
	req_access = list(access_polariscargo)
	color = CARGO

/obj/access_spawn/polarisimportant
	name = "polaris important access spawn"
	req_access = list(access_polarisimportant)
	color = CARGO


/obj/access_spawn/juicer
	name = "juicer access spawn"
	req_access = list(access_juicer)
	color = TOXINS

/obj/access_spawn/juicer/engineering
	name = "juicer engineering access spawn"
	req_access = list(access_juicer_engineer)
	color = ENGINEERING

/obj/access_spawn/juicer/service
	name = "service industry juicer access spawn"
	req_access = list(access_juicer_service)
	color = MEDICAL

/obj/access_spawn/juicer/bballer
	name = "basket-baller juicer access spawn"
	req_access = list(access_juicer_bballer)
	color = COMMAND

/obj/access_spawn/juicer/crypto
	name = "crypto-scammer juicer access spawn"
	req_access = list(access_juicer_crypto)
	color = CARGO

/obj/access_spawn/juicer/muscle
	name = "muscle juicer access spawn"
	req_access = list(access_juicer_muscle)
	color = SECURITY

/obj/access_spawn/juicer/prepper
	name = "doomsday prepper juicer access spawn"
	req_access = list(access_juicer_prepper)
	color = SECURITY

/obj/access_spawn/juicer/deejay
	name = "disco juicer access spawn"
	req_access = list(access_juicer_deejay)
	color = MEDICAL

/obj/access_spawn/juicer/fraud
	name = "tax fraud juicer access spawn"
	req_access = list(access_juicer_fraud)
	color = RESEARCH

/obj/access_spawn/juicer/grease
	name = "greasy juicer access spawn"
	req_access = list(access_juicer_grease)
	color = TOXINS

/obj/access_spawn/soviet
	name = "soviet public access spawn"
	req_access = list(access_soviet_public)
	color = SECURITY

/obj/access_spawn/soviet/private
	name = "soviet private access spawn"
	req_access = list(access_soviet_private)
	color = SECURITY

/obj/access_spawn/soviet/private/mining
	name = "soviet mining access spawn"
	req_access = list(access_soviet_mining)
	color = ENGINEERING

/obj/access_spawn/soviet/private/engineering
	name = "soviet engineering access spawn"
	req_access = list(access_soviet_engineering)
	color = ENGINEERING

/obj/access_spawn/soviet/private/cargo
	name = "soviet cargo access spawn"
	req_access = list(access_soviet_cargo)
	color = CARGO

/obj/access_spawn/soviet/private/medical
	name = "soviet medical access spawn"
	req_access = list(access_soviet_medical)
	color = MEDICAL

/obj/access_spawn/soviet/private/research
	name = "soviet research access spawn"
	req_access = list(access_soviet_research)
	color = RESEARCH

/obj/access_spawn/soviet/private/security
	name = "soviet security access spawn"
	req_access = list(access_soviet_security)
	color = SECURITY

/obj/access_spawn/soviet/private/command
	name = "soviet command access spawn"
	req_access = list(access_soviet_command)
	color = SECURITY

/obj/access_spawn/ghostdrone
	name = "ghostdrone access spawn"
	req_access = list(access_ghostdrone)
	color = MAINTENANCE

#undef MEDICAL
#undef SECURITY
#undef MORGUE_BLACK
#undef TOXINS
#undef RESEARCH
#undef ENGINEERING
#undef CARGO
#undef MAINTENANCE
#undef COMMAND
