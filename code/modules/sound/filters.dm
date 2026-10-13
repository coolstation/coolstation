//custom environment filters (for when standard EAX presets aren't enough)
//Environments define and alter how you hear all the sounds going on around you.
//If you are in an echoey cave or a padded bathroom, or more accurately your client is, the same sound played in either is going to be different when it reaches your "ears"
//but you knew that. here this is just a way of trying something new with it
//the filters are inscrutible and awful when all on one line for saving space, but if we break it out in its own file...

//here's a list with the defaults, names and ranges from the DM ref as a jumping off point for making your own
//recommend having the DM ref for echo/environment vars split screened if you're doing it
/*
	7.5, 		//EnvSize (1.0 to 100.0)
	1.0,		//EnvDiffusion (0.0 to 1.0)
	-1000,		//Room (-10000 to 0)
	-100,		//RoomHF (-10000 to 0)
	0,			//RoomLF (-10000 to 0)
	1.49,		//DecayTime (0.1 to 20.0)
	0.83,		//DecayHFRatio (0.1 to 2.0)
	1.0,		//DecayLFRatio (0.1 to 2.0)
	-2602,		//Reflections (-10000 to 1000)
	0.007,		//ReflectionsDelay (0.0 to 0.3)
	200,		//Reverb (-10000 to 2000)
	0.011,		//ReverbDelay (0.0 to 0.1)
	0.25,		//EchoTime (0.075 to 0.250)
	0.0,		//EchoDepth (0.0 to 1.0)
	0.25,		//ModulationTime (0.04 to 4.0)
	0.0,		//ModulationDepth (0.0 to 1.0)
	-5.0,		//AirAbsorptionHF (-100 to 0.0)
	5000.0,		//HFReference (1000.0 to 20000)
	250.0,		//LFReference (20.0 to 1000.0)
	0.0,		//RoomRolloffFactor (0.0 to 10.0)
	100.0,		//Diffusion (0.0 to 100.0)
	100.0,		//Density (0.0 to 100.0)
	0x3f 		//Flags(63)
	*/

//---- Environments ----

var/global/SPACED_ENV = list(
	100.0, 		//EnvSize
	0.52,		//EnvDiffusion
	0,			//Room
	-1600,		//RoomHF
	-1500,		//RoomLF
	0.0,		//DecayTime
	2.0,		//DecayHFRatio
	2.0,		//DecayLFRatio
	-10000,		//Reflections
	0.0,		//ReflectionsDelay
	200,		//Reverb
	0.01,		//ReverbDelay
	0.165,		//EchoTime
	0.0,		//EchoDepth
	0.25,		//ModulationTime
	0.01,		//ModulationDepth
	-5.0,		//AirAbsorptionHF
	1000.0,		//HFReference
	20.0,		//LFReference
	10.0,		//RoomRolloffFactor
	53.0,		//Diffusion
	100.0,		//Density
	0x3f) 		//Flags

var/global/DEAF_ENV = list(
	20.0,			//EnvSize
	0.4,		//EnvDiffusion
	-200,		//Room
	-2000,		//RoomHF
	700,		//RoomLF
	0.15,		//DecayTime
	2.0,		//DecayHFRatio
	1.2,		//DecayLFRatio
	-8000,		//Reflections
	0.02,		//ReflectionsDelay
	400,		//Reverb
	0.08,		//ReverbDelay
	0.165,		//EchoTime
	0.0,		//EchoDepth
	0.25,		//ModulationTime
	0.01,		//ModulationDepth
	-15.0,		//AirAbsorptionHF
	500.0,		//HFReference
	200.0,		//LFReference
	3.0,		//RoomRolloffFactor
	70.0,		//Diffusion
	100.0,		//Density
	0x3f)		//Flags

//Echo Filters
//Similar to above but they apply to the specific sound being played and maintains some of its own characteristics outside of what's imposed by environment
//easier to think of it like sounds happening in different rooms, something distant, something reflected (for example outside a club, or banging on an airlock from the outside)
//But basically they work together

//another list with the defaults
/*
	0, 			//Direct (-10,000 to 1,000)
	0,			//DirectHF (-10,000 to 0)
	0,			//Room (-10,000 to 1,000)
	0,			//RoomHF (-10,000 to 0)
	0,			//Obstruction (-10,000 to 0)
	0.0,		//ObstructionLFRatio (0.0 to 1.0)
	0,			//Occlusion (-10,000 to 0)
	0.25,		//OcclusionLFRatio (0.0 to 1.0)
	1.5,		//OcclusionRoomRatio (0.0 to 10.0)
	1.0,		//OcclusionDirectRatio (0.0 to 10.0)
	0,			//Exclusion (-10,000 to 0)
	1.0,		//ExclusionLFRatio (0.0 to 1.0)
	0,			//OutsideVolumeHF (-10,000 to 0)
	0.0,		//DopplerFactor (0.0 to 10.0)
	0.0,		//RolloffFactor (0.0 to 10.0)
	0.0,		//RoomRolloffFactor (0.0 to 10.0)
	1.0,		//AirAbsorptionFactor (0.0 to 10.0)
	7) 			//Flags
	*/

//---- Echoes ----

var/global/SPACED_ECHO = list(
	-10000,		//Direct
	0,			//DirectHF
	-1450,		//Room
	0,			//RoomHF
	0,			//Obstruction
	1,			//ObstructionLFRatio
	0,			//Occlusion
	1,			//OcclusionLFRatio
	10,			//OcclusionRoomRatio
	10,			//OcclusionDirectRatio
	0,			//Exclusion
	1.0,		//ExclusionLFRatio
	0,			//OutsideVolumeHF
	10,			//DopplerFactor
	10,			//RolloffFactor
	10,			//RoomRolloffFactor
	10,			//AirAbsorptionFactor
	7)			//Flags

var/global/ECHO_AFAR = list(
	0,			//Direct
	0,			//DirectHF
	0,			//Room
	0,			//RoomHF
	0,			//Obstruction
	0.0,		//ObstructionLFRatio
	-10000,		//Occlusion
	1.0,		//OcclusionLFRatio
	1.5,		//OcclusionRoomRatio
	1.0,		//OcclusionDirectRatio
	0,			//Exclusion
	1.0,		//ExclusionLFRatio
	0,			//OutsideVolumeHF
	0.2,		//DopplerFactor
	0.0,		//RolloffFactor
	0.0,		//RoomRolloffFactor
	1.0,		//AirAbsorptionFactor
	7)			//Flags

var/global/ECHO_CLOSE = list(
	0,			//Direct
	0,			//DirectHF
	0,			//Room
	0,			//RoomHF
	0,			//Obstruction
	0.0,		//ObstructionLFRatio
	0,			//Occlusion
	0.25,		//OcclusionLFRatio
	1.5,		//OcclusionRoomRatio
	1.0,		//OcclusionDirectRatio
	0,			//Exclusion
	1.0,		//ExclusionLFRatio
	0,			//OutsideVolumeHF
	0.2,		//DopplerFactor
	0.0,		//RolloffFactor
	0.0,		//RoomRolloffFactor
	1.0,		//AirAbsorptionFactor
	7)			//Flags

