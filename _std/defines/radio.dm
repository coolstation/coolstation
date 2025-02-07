// Radio (headset etc) colors.
#define RADIOC_STANDARD "#008000"
#define RADIOC_INTERCOM "#008BA0"
#define RADIOC_COMMAND "#4F78A8"
#define RADIOC_SECURITY "#E00000"
#define RADIOC_BRIG "#FF5000"
#define RADIOC_DETECTIVE "#A00000"
#define RADIOC_ENGINEERING "#A86800"
#define RADIOC_LOGISTICS "#6E3B00"
#define RADIOC_MEDICAL "#3A88AC"
#define RADIOC_RESEARCH "#732DCE"
#define RADIOC_CIVILIAN "#A10082"
#define RADIOC_SYNDICATE "#962121"
#define RADIOC_OTHER "#800080"

// Radio (headset etc) css classes.
#define RADIOCL_STANDARD "rstandard"
#define RADIOCL_INTERCOM "rintercom"
#define RADIOCL_COMMAND "rcommand"
#define RADIOCL_SECURITY "rsecurity"
#define RADIOCL_DETECTIVE "rdetective"
#define RADIOCL_ENGINEERING "rengineering"
#define RADIOCL_LOGISTICS "rlogistics"
#define RADIOCL_MEDICAL "rmedical"
#define RADIOCL_RESEARCH "rresearch"
#define RADIOCL_CIVILIAN "rcivilian"
#define RADIOCL_SYNDICATE "rsyndicate"
#define RADIOCL_OTHER "rother"

// Frequency defines for headsets & intercoms (Originally Convair880)

//alltalk
#define R_FREQ_DEFAULT 1459 //145.9 is eternal
#define R_FREQ_MULTI 1451
/// Minimum "selectable" freq
#define R_FREQ_MINIMUM 1441
/// Maximum "selectable" freq
#define R_FREQ_MAXIMUM 1489

//secure or out of band channels
#define R_FREQ_COMMAND 1350
#define R_FREQ_DETECTIVE 1351
#define R_FREQ_SECURITY 1352
#define R_FREQ_RESEARCH 1353
#define R_FREQ_MEDICAL 1355
#define R_FREQ_ENGINEERING 1357
#define R_FREQ_LOGISTICS 1358
#define R_FREQ_CIVILIAN 1359

//crime channels
#define R_FREQ_SYNDICATE 1252 // Randomized for nuke rounds. Also used by conspiracy.
#define R_FREQ_SYNDICATE_MIN 1252 //might raise this back up among 14XX
#define R_FREQ_SYNDICATE_MAX 1337
#define R_FREQ_GANG 1360 // Placeholder, it's actually randomized in gang rounds.
#define R_FREQ_GANG_MIN 1360
#define R_FREQ_GANG_MAX 1420

//i think this is VR oriented
#define R_FREQ_INTERCOM_COLOSSEUM 1401

//wireless intercoms (subject to interference but many to many)
#define R_FREQ_INTERCOM_BRIDGE 1421
#define R_FREQ_INTERCOM_SECURITY 1422
#define R_FREQ_INTERCOM_RESEARCH 1423
#define R_FREQ_INTERCOM_BRIG 1424
#define R_FREQ_INTERCOM_MEDICAL 1425
#define R_FREQ_INTERCOM_AI 1426
#define R_FREQ_INTERCOM_ENGINEERING 1427
#define R_FREQ_INTERCOM_CARGO 1429 //logistics too ig
#define R_FREQ_INTERCOM_CATERING 1431
#define R_FREQ_INTERCOM_BOTANY 1433
#define R_FREQ_INTERCOM_TELESCIENCE 1535 //special case for away team radios

//public address (robust interference protection but one to many)
//also useful for playing stuff from radio programs and loops
#define R_FREQ_LOUDSPEAKERS 1551 //general hallway PA?
#define R_FREQ_PA_SECURITY 1552
#define R_FREQ_PA_RESEARCH 1553 //dr. birdwell report to topside motorpool
#define R_FREQ_PA_MEDICAL 1555 //code brown in room 3
#define R_FREQ_PA_ENGINEERING 1557
#define R_FREQ_PA_LOGISTICS 1558
#define R_FREQ_PA_CARGO 1559 //especially useful if cargo spans two z-levels
#define R_FREQ_PA_BAR 1561 //bar basically

// let's start putting adventure zone factions in here

#define R_FREQ_INTERCOM_WIZARD 1089 //magic number, gimmick used in many magic tricks
#define R_FREQ_INTERCOM_OWLERY 1291
#define R_FREQ_INTERCOM_SYNDCOMMAND 6174 // kaprekar's constant, a unique and weird number
#define R_FREQ_INTERCOM_TERRA8 1156 // 34 squared, octahedral number, centered pentagonal number, centered hendecagonal number
#define R_FREQ_INTERCOM_HEMERA 777 // heh
#define R_FREQ_INTERCOM_CHESS 1337 // The cool S of script kiddies, also chess intercoms are virtual so

// These are for the Syndicate headset randomizer proc.
#define R_FREQ_BLACKLIST list(R_FREQ_DEFAULT, R_FREQ_COMMAND, R_FREQ_SECURITY, R_FREQ_DETECTIVE, R_FREQ_ENGINEERING, R_FREQ_RESEARCH, R_FREQ_MEDICAL, R_FREQ_CIVILIAN, R_FREQ_LOGISTICS, R_FREQ_SYNDICATE, R_FREQ_GANG, R_FREQ_MULTI,\
R_FREQ_INTERCOM_COLOSSEUM, R_FREQ_INTERCOM_MEDICAL, R_FREQ_INTERCOM_SECURITY, R_FREQ_INTERCOM_BRIG, R_FREQ_INTERCOM_RESEARCH, R_FREQ_INTERCOM_ENGINEERING, R_FREQ_INTERCOM_CARGO, R_FREQ_INTERCOM_CATERING, R_FREQ_INTERCOM_AI, R_FREQ_INTERCOM_BRIDGE, R_FREQ_INTERCOM_TELESCIENCE, R_FREQ_INTERCOM_WIZARD)

proc/default_frequency_color(freq)
	switch(freq)
		if(R_FREQ_DEFAULT)
			return RADIOC_STANDARD
		if(R_FREQ_COMMAND)
			return RADIOC_COMMAND
		if(R_FREQ_SECURITY)
			return RADIOC_SECURITY
		if(R_FREQ_DETECTIVE)
			return RADIOC_DETECTIVE
		if(R_FREQ_ENGINEERING)
			return RADIOC_ENGINEERING
		if(R_FREQ_RESEARCH)
			return RADIOC_RESEARCH
		if(R_FREQ_MEDICAL)
			return RADIOC_MEDICAL
		if(R_FREQ_CIVILIAN)
			return RADIOC_CIVILIAN
		if(R_FREQ_SYNDICATE)
			return RADIOC_SYNDICATE
		if(R_FREQ_GANG)
			return RADIOC_SYNDICATE
		if(R_FREQ_INTERCOM_MEDICAL)
			return RADIOC_MEDICAL
		if(R_FREQ_INTERCOM_SECURITY)
			return RADIOC_SECURITY
		if(R_FREQ_INTERCOM_BRIG)
			return RADIOC_BRIG
		if(R_FREQ_INTERCOM_RESEARCH)
			return RADIOC_RESEARCH
		if(R_FREQ_INTERCOM_ENGINEERING)
			return RADIOC_ENGINEERING
		if(R_FREQ_INTERCOM_CARGO)
			return RADIOC_LOGISTICS
		if(R_FREQ_LOGISTICS)
			return RADIOC_LOGISTICS
		if(R_FREQ_INTERCOM_CATERING)
			return RADIOC_CIVILIAN
		if(R_FREQ_INTERCOM_AI)
			return RADIOC_COMMAND
		if(R_FREQ_INTERCOM_BRIDGE)
			return RADIOC_COMMAND
