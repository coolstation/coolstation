//Emote parent datum
//Emote datums are a shared pool so don't go putting vars on them that should be mob-specific!
//(You could make a thing to instantiate those emotes where needed I guess, godspeed if you do that.)

/datum/emote
	var/cooldown = 0 SECONDS
	var/emote_string = "acts in a manner that suggests something in the code fucked up!"
	var/possible_while_dead = FALSE //can mobs that are supposed to be alive do this when they're dead?

///Exists for dancin shoes & deathgasp, but variable cooldowns cool maybe?
/datum/emote/proc/return_cooldown(mob/user, voluntary = 0)
	return cooldown

///Returns a list: [emote message, maptext, message_type] - because of this, make sure any fancy effects happen first!
/datum/emote/proc/enact(mob/user, voluntary = 0, param) //param might be another mob, or some more text. See human emote()
	return list("[user] [emote_string]", emote_string, MESSAGE_VISIBLE)
	//Just do your


var/datum/emote_controller/emote_controls


///Holds a list of emote datums and populates it with datums on demand, lazy init and preventing duplication basically
/datum/emote_controller
	var/list/all_the_emotes = list()

///Returns the instance of a type
/datum/emote_controller/proc/get_emote(var/this_one) //Supply with a typepath
	if (!ispath(this_one, /datum/emote))
		return 0 //>:(
	var/datum/emote/here_you_go = locate(this_one) in all_the_emotes
	if (!here_you_go)
		here_you_go = new this_one()
		all_the_emotes += here_you_go
	return here_you_go

//Below here be all the lookup lists for emotes, for the love of sanity please don't put any code below this point.
//The strings are verbatim (but lowertexted) how the emote is called, so [*fart] turns into "fart" etc. Multiple strings can point to the same datum.
//Emotes are (or should) be lowertexted when they get checked, so don't put capitals in these lookup strings.

///Things all mob/living/carbon/human can access
var/static/list/human_emotes = list(
	"scream" = /datum/emote/scream,					//These two are at the front like they were in the old system (maybe optimization? IDK)
	"fart" = /datum/emote/fart/bio,
	"smile" = /datum/emote/simple_visible/smile,	//start of simple_visible
	":)" = /datum/emote/simple_visible/smile,		//Same order as the simple datums except I grouped the emoticon alts up front
	"grin" = /datum/emote/simple_visible/grin,
	":d" = /datum/emote/simple_visible/grin,		//:D
	">:)" = /datum/emote/simple_visible/grin,
	"smirk" = /datum/emote/simple_visible/smirk,
	":j" = /datum/emote/simple_visible/smirk, 		//:J
	"frown" = /datum/emote/simple_visible/frown,
	":(" = /datum/emote/simple_visible/frown,
	"scowl" = /datum/emote/simple_visible/scowl,
	">:(" = /datum/emote/simple_visible/scowl,
	"grimace" = /datum/emote/simple_visible/grimace,
	"d:" = /datum/emote/simple_visible/grimace,	//D:
	"dx" = /datum/emote/simple_visible/grimace,	//DX
	"pout" = /datum/emote/simple_visible/pout,
	":c" = /datum/emote/simple_visible/pout,		//:C
	"stare" = /datum/emote/simple_visible/stare,
	":|" = /datum/emote/simple_visible/stare,
	"grump" = /datum/emote/simple_visible/grump,
	":i" = /datum/emote/simple_visible/grump, 		//:I
	"sulk" = /datum/emote/simple_visible/sulk,
	"glare" = /datum/emote/simple_visible/glare,
	"nod" = /datum/emote/simple_visible/nod,
	"blink" = /datum/emote/simple_visible/blink,
	"drool" = /datum/emote/simple_visible/drool,
	"shrug" = /datum/emote/simple_visible/shrug,
	"tremble" = /datum/emote/simple_visible/tremble,
	"quiver" = /datum/emote/simple_visible/quiver,
	"shiver" = /datum/emote/simple_visible/shiver,
	"shudder" = /datum/emote/simple_visible/shudder,
	"shake" = /datum/emote/simple_visible/shake,
	"think" = /datum/emote/simple_visible/think,
	"ponder" = /datum/emote/simple_visible/ponder,
	"contemplate" = /datum/emote/simple_visible/contemplate,
	"despair" = /datum/emote/simple_visible/despair,
	"blush" = /datum/emote/simple_visible/blush,
	"flinch" = /datum/emote/simple_visible/flinch,
	"blink_r" = /datum/emote/simple_visible/blink_r,
	"eyebrow" = /datum/emote/simple_visible/eyebrow,
	"raiseeyebrow" = /datum/emote/simple_visible/eyebrow,
	"flipout" = /datum/emote/simple_visible/flipout,
	"rage" = /datum/emote/simple_visible/rage,
	"fury" = /datum/emote/simple_visible/rage,
	"angry" = /datum/emote/simple_visible/rage,	//end of simple_visible
	"clap" = /datum/emote/visible_restrain/clap,	//start of visible_restrain
	"salute" = /datum/emote/visible_restrain/salute,
	"wave" = /datum/emote/visible_restrain/wave,
	"raisehand" = /datum/emote/visible_restrain/raisehand,
	"crackknuckles" = /datum/emote/visible_restrain/crackknuckles,
	"knuckles" = /datum/emote/visible_restrain/crackknuckles,
	"stretch" = /datum/emote/visible_restrain/stretch,
	"rude" = /datum/emote/visible_restrain/rude,
	"tantrum" = /datum/emote/visible_restrain/tantrum,
	"nosepick" = /datum/emote/visible_restrain/nosepick,
	"picknose" = /datum/emote/visible_restrain/nosepick,
	"flap" = /datum/emote/visible_restrain/flap,
	"aflap" = /datum/emote/visible_restrain/flap/aflap,
	"gesticulate" = /datum/emote/visible_restrain/gesticulate,
	"wgesticulate" = /datum/emote/visible_restrain/wgesticulate,
	"panic" = /datum/emote/visible_restrain/panic,
	"freakout" = /datum/emote/visible_restrain/panic,
	"smug" = /datum/emote/visible_restrain/smug,	//end of visible_restrain
	"cough" = /datum/emote/simple_audible/cough,	//start of simple_audible
	"hiccup" = /datum/emote/simple_audible/hiccup,
	"mumble" = /datum/emote/simple_audible/mumble,
	"grumble" = /datum/emote/simple_audible/grumble,
	"groan" = /datum/emote/simple_audible/groan,
	"moan" = /datum/emote/simple_audible/moan,
	"sneeze" = /datum/emote/simple_audible/sneeze,
	"wheeze" = /datum/emote/simple_audible/wheeze,
	"sniff" = /datum/emote/simple_audible/sniff,
	"snore" = /datum/emote/simple_audible/snore,
	"whimper" = /datum/emote/simple_audible/whimper,
	"yawn" = /datum/emote/simple_audible/yawn,
	"choke" = /datum/emote/simple_audible/choke,
	"weep" = /datum/emote/simple_audible/weep,
	"sob" = /datum/emote/simple_audible/sob,
	"wail" = /datum/emote/simple_audible/wail,
	"whine" = /datum/emote/simple_audible/whine,
	"gurgle" = /datum/emote/simple_audible/gurgle,
	"gargle" = /datum/emote/simple_audible/gargle,
	"sputter" = /datum/emote/simple_audible/sputter,
	"sigh" = /datum/emote/simple_audible/sigh,
	"gasp" = /datum/emote/simple_audible/gasp,			//end of simple_audible
	"laugh" = /datum/emote/play_laugh/laugh,			//start of a couple small audible categories
	"chuckle" = /datum/emote/play_laugh/chuckle,
	"giggle" = /datum/emote/play_laugh/giggle,
	"chortle" = /datum/emote/play_laugh/chortle,
	"guffaw" = /datum/emote/play_laugh/guffaw,
	"cackle" = /datum/emote/play_laugh/cackle,
	"retch" = /datum/emote/audible_restrain/retch,
	"gag" = /datum/emote/audible_restrain/retch,
	"raspberry" = /datum/emote/audible_restrain/raspberry,
	"cry" = /datum/emote/audible_restrain/cry,			//misc audible end
	"pale" = /datum/emote/oneoff/pale,					//miscellania
	"shame" = /datum/emote/oneoff/shame,
	"hanghead" = /datum/emote/oneoff/shame,
	"shakehead" = /datum/emote/oneoff/shakehead,
	"smh" = /datum/emote/oneoff/shakehead,
	"facepalm" = /datum/emote/oneoff/facepalm,
	"handpuppet" = /datum/emote/oneoff/handpuppet,
	"help" = /datum/emote/help,
	"listbasic" = /datum/emote/listbasic/human,
	"listtarget" = /datum/emote/listtarget/human,		//end of emote_simple.dm
	"nodat" = /datum/emote/targeted/nodat,				//start of emote_targeted.dm
	"glareat" = /datum/emote/targeted/glareat,
	"stareat" = /datum/emote/targeted/stareat,
	"look" = /datum/emote/targeted/look,
	"boggle" = /datum/emote/targeted/boggle,
	"saluteto" = /datum/emote/visible_restrain/targeted/saluteto,
	"waveto" = /datum/emote/visible_restrain/targeted/waveto,
	"bow" = /datum/emote/visible_restrain/targeted/bow,
	"blowkiss" = /datum/emote/visible_restrain/targeted/blowkiss,
	"hug" = /datum/emote/visible_restrain/targeted/hug,
	"sidehug" = /datum/emote/visible_restrain/targeted/sidehug,
	"fingerguns" = /datum/emote/visible_restrain/targeted/fingerguns,
	"flipoff" = /datum/emote/visible_restrain/targeted/fingerflip/flipoff,
	"flipbird" = /datum/emote/visible_restrain/targeted/fingerflip/flipbird,
	"middlefinger" = /datum/emote/visible_restrain/targeted/fingerflip/middlefinger,
	"doubleflip" = /datum/emote/visible_restrain/targeted/fingerflip2/doubleflip,
	"doubledeuce" = /datum/emote/visible_restrain/targeted/fingerflip2/doubledeuce,
	"doublebird" = /datum/emote/visible_restrain/targeted/fingerflip2/doublebird,
	"flip2" = /datum/emote/visible_restrain/targeted/fingerflip2/flip2,
	"dap" = /datum/emote/visible_restrain/targeted/dap,
	"daps" = /datum/emote/visible_restrain/targeted/dap,
	"shakefist" = /datum/emote/visible_restrain/targeted/shakefist,
	"handshake" = /datum/emote/targeted/handshake,
	"shakehand" = /datum/emote/targeted/handshake,
	"shakehands" = /datum/emote/targeted/handshake,
	"slap" = /datum/emote/targeted/slap,
	"smack" = /datum/emote/targeted/slap,
	"highfive" = /datum/emote/targeted/highfive,		//end of emote_targeted.dm
	"dance" = /datum/emote/dance,						//emote_huge.dm (except *fart)
	"boogie" = /datum/emote/dance,
	"flip" = /datum/emote/flip,
	"urinate" = /datum/emote/urinate,
	"pee" = /datum/emote/urinate,
	"piss" = /datum/emote/urinate,		//end of emote_huge.dm
	"inhale" = /datum/emote/inhale,		//start of emote_complex (minus *scream)
	"exhale" = /datum/emote/exhale,
	"closeeyes" = /datum/emote/closeeyes,
	"openeyes" = /datum/emote/openeyes,
	"birdwell" = /datum/emote/birdwell/bio,
	"uguu" = /datum/emote/uguu,
	"juggle" = /datum/emote/juggle,
	"twirl" = /datum/emote/twirl,
	"spin" = /datum/emote/twirl,
	"tip" = /datum/emote/tip,
	"stomphat" = /datum/emote/hatstomp,
	"hatstomp" = /datum/emote/hatstomp,
	"bubble" = /datum/emote/bubble,
	"give" = /datum/emote/give,
	"twerk" = /datum/emote/twerk,
	"shakebutt" = /datum/emote/twerk,
	"shakebooty" = /datum/emote/twerk,
	"shakeass" = /datum/emote/twerk,
	"flex" = /datum/emote/flex,
	"flexmuscles" = /datum/emote/flex,
	"snapfingers" = /datum/emote/snapfingers,
	"snap" = /datum/emote/snapfingers,
	"fingersnap" = /datum/emote/snapfingers,
	"click" = /datum/emote/snapfingers,
	"clickfingers" = /datum/emote/snapfingers,
	"airquote" = /datum/emote/airquote,
	"airquotes" = /datum/emote/airquote,
	"twitch" = /datum/emote/twitch,
	"twitch_v" = /datum/emote/twitch/twitch_v,
	"twitch_s" = /datum/emote/twitch/twitch_v,
	"faint" = /datum/emote/faint,
	"deathgasp" = /datum/emote/deathgasp,
	"johnny" = /datum/emote/johnny,
	"point" = /datum/emote/point,
	"signal" = /datum/emote/signal,
	"wink" = /datum/emote/wink,
	"collapse" = /datum/emote/collapse,
	"trip" = /datum/emote/collapse/trip,
	"burp" = /datum/emote/burp,
	"poo" = /datum/emote/poo,
	"poop" = /datum/emote/poo,
	"shit" = /datum/emote/poo,
	"crap" = /datum/emote/poo,
	"miranda" = /datum/emote/miranda,
	"suicide" = /datum/emote/suicide,
	"custom" = /datum/emote/custom,
	"customv" = /datum/emote/customv,
	"customh" = /datum/emote/customh,
	"suicide" = /datum/emote/suicide,
	"me" = /datum/emote/me, 			//end of emote_complex.dm
	"monologue" = /datum/emote/monologue
	)
