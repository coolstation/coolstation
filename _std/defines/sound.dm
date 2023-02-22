//Reserved Area Ambience sound channels
#define SOUNDCHANNEL_BIGALARM 122 //uh oh
#define SOUNDCHANNEL_LOOPING_Z 123 //gehenna outdoors wind (for now)
#define SOUNDCHANNEL_LOOPING_1 124
#define SOUNDCHANNEL_LOOPING_2 125
#define SOUNDCHANNEL_FX_1 126
#define SOUNDCHANNEL_FX_2 127

//sound mute
#define SOUND_NONE 0
#define SOUND_SPEECH 1
#define SOUND_BLAH 2
#define SOUND_ALL 4
#define SOUND_VOX 8

//volume channel defines
#define VOLUME_CHANNEL_MASTER 0
#define VOLUME_CHANNEL_GAME 1
#define VOLUME_CHANNEL_AMBIENT 2
#define VOLUME_CHANNEL_RADIO 3
#define VOLUME_CHANNEL_ADMIN 4
#define VOLUME_CHANNEL_EMOTE 5
#define VOLUME_CHANNEL_MENTORPM 6

var/global/list/audio_channel_name_to_id = list(
	"master" = VOLUME_CHANNEL_MASTER,
	"game" = VOLUME_CHANNEL_GAME,
	"ambient" = VOLUME_CHANNEL_AMBIENT,
	"radio" = VOLUME_CHANNEL_RADIO,
	"admin" = VOLUME_CHANNEL_ADMIN,
	"emote" = VOLUME_CHANNEL_EMOTE,
	"mentorpm" = VOLUME_CHANNEL_MENTORPM
)

//Area Ambience Switch
#define AMBIENCE_LOOPING_1 1
#define AMBIENCE_LOOPING_2 2
#define AMBIENCE_FX_1 3
#define AMBIENCE_FX_2 4

//playsound flags
#define SOUND_IGNORE_SPACE (1<<0)

//standard environments
#define EAX_GENERIC 0
#define EAX_PADDED_CELL 1
#define EAX_ROOM 2
#define EAX_BATHROOM 3
#define EAX_LIVINGROOM 4
#define EAX_STONEROOM 5
#define EAX_AUDITORIUM 6
#define EAX_CONCERT_HALL 7
#define EAX_CAVE 8
#define EAX_ARENA 9
#define EAX_HANGAR 10
#define EAX_CARPETED_HALLWAY 11
#define EAX_HALLWAY 12
#define EAX_STONE_CORRIDOR 13
#define EAX_ALLEY 14
#define EAX_FOREST 15
#define EAX_CITY 16
#define EAX_MOUNTAINS 17
#define EAX_QUARRY 18
#define EAX_PLAIN 19
#define EAX_PARKING_LOT 20
#define EAX_SEWER_PIPE 21
#define EAX_UNDERWATER 22
#define EAX_DRUGGED 23
#define EAX_DIZZY 24
#define EAX_DISORDERED 25
