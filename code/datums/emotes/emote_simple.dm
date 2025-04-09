///Emotes that do little more than show some text or whatever, maybe make a noise too?
//Basically if there's a bunch of emotes doing the same thing (or it's *clap) it goes here
//N.B. There's a lot of bespoke types for minor differences because I figured making the common emote parents confusing messes was the worse option.
//Chalking that one up to the many peculiarities of language, deal with it.

// ---------------------------
//    Visible
// ---------------------------

///Return prebaked string, visible. Not limiting to single
/datum/emote/simple_visible
	//I normally don't like relative pathing, but for shit like this?
	smile //also :)
		emote_string = "smiles" //Don't add punctuation that'd look weird with maptext
	grin //also :D, >:)
		emote_string = "grins"
	smirk //also :J
		emote_string = "smirks"
	frown //also :(
		emote_string = "frowns"
	scowl //also >:(
		emote_string = "scowls"
	grimace //also D:, DX
		emote_string = "grimaces"
	sulk
		emote_string = "sulks"
	pout //also :C
		emote_string = "pouts"
	stare //also :|
		emote_string = "stares"
	glare
		emote_string = "glares"
	nod
		emote_string = "nod"
	nods
		emote_string = "nods"
	blink
		emote_string = "blinks"
	drool
		emote_string = "drools"
	shrug
		emote_string = "shrugs"
	tremble
		emote_string = "trembles"
	quiver
		emote_string = "quivers"
	shiver
		emote_string = "shivers"
	shudder
		emote_string = "shudders"
	shake
		emote_string = "shakes"
	think
		emote_string = "thinks"
	ponder
		emote_string = "ponders"
	contemplate
		emote_string = "contemplates"
	grump //also :I
		emote_string = "grumps"
	despair //Look on my code, ye Mighty, and
		emote_string = "despairs" //(I added this one for the joke while making emote datums a thing, but tell me it's not a good one)
	//slightly different wording ones below
	blush
		emote_string = "blushes"
	squint
		emote_string = "squints"
	flinch
		emote_string = "flinches"
		enact(mob/living/carbon/human/user, voluntary = 0, param)
			if (istype(user) && user.traitHolder && user.traitHolder.hasTrait("scienceteam") && !ismuzzled(user))
				playsound(user.loc, pick(user.sound_list_laugh), 80, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
			. = ..()
	blink_r
		emote_string = "blinks rapidly"
	eyebrow //also raiseeyebrow
		emote_string = "raises an eyebrow"
	flipout
		emote_string = "flips the fuck out!"
	rage //also fury, angry
		emote_string = "becomes utterly furious!"

/datum/emote/simple_visible/enact(mob/user, voluntary = 0, param) //"simple"
	return list("<B>[user]</B> [emote_string][emote_string[length(emote_string)] != "!" ? "." : ""]", "<I>[emote_string]</I>", MESSAGE_VISIBLE)


//Okay this one got a little messy, but there's a bunch of emotes that fail when restrained
//and some of them use pronouns in the success strings or the fail strings in all possible combinations

///Visible emote that fails when restrained, might use pronouns
/datum/emote/visible_restrain
	/*How 2 Use:
	If emote_string is not null, that's output on success as usual.
	Otherwise it'll [(user) (output emote_string_leading) (pronouns) (emote_string_trailing).]
	Same basic deal for emote_fail(_leading/_trailing) when the user is restrained.
	You're free to mix and match types of success/fail messages otherwise.
	Exclude spaces from the end and start of the leading/trailing strings.
	pronoun_proc is proc/his_or_her or proc/himself_or_herself, I wasn't gonna make 2 subtypes just for that


	*/
	emote_string = null
	var/emote_string_leading = null
	var/emote_string_trailing = null
	var/emote_fail = null
	var/emote_fail_leading = null
	var/emote_fail_trailing = null
	var/pronoun_proc = null //I want you to make the one you use explicit >:(

	clap
		emote_string = "claps"
		emote_fail = "struggles to move"
	salute
		emote_string = "salutes"
		emote_fail = "struggles to move"
	wave //Didn't bother to port handkerchief stuff
		emote_string = "waves"
		emote_fail = "struggles to move"
		enact(mob/user, voluntary = 0, param)
			if (!user.restrained()) user.add_karma(2)
			. = ..()

	crackknuckles //also knuckles
		emote_string_leading = "crack"
		emote_string_trailing = "knuckles"
		emote_fail = "irritably shuffles around"
		pronoun_proc = /proc/his_or_her
	stretch
		emote_string = "stretches"
		emote_fail = "writhes around slowly"
	rude
		emote_string = "makes a rude gesture"
		emote_fail_leading = "tries to move"
		emote_fail_trailing = "arm"
		pronoun_proc = /proc/his_or_her
	tantrum
		emote_string = "throws a tantrum!"
		emote_fail = "starts wriggling around furiously!"

	nosepick // also picknose
		emote_string_leading = "picks"
		emote_string_trailing = "nose"
		emote_fail_leading = "sniffs and scrunches"
		emote_fail_trailing = "face up irritably"
		pronoun_proc = /proc/his_or_her

		enact(mob/user, voluntary = 0, param) //fuck you nosepick
			if (user.mind)
				user.add_karma(-1)
			. = ..()
	flap
		emote_string_leading = "flaps"
		emote_string_trailing = "arms!"
		emote_fail = "writhes!"
		var/angry = 0
		pronoun_proc = /proc/his_or_her

		enact(mob/living/carbon/human/user, voluntary = 0, param) //Tommy Wiseau exclusive bullshit
			if (!istype(user)) return //sound_list_flap
			if (!user.restrained() && user.sound_list_flap && length(user.sound_list_flap))
				playsound(user.loc, pick(user.sound_list_flap), 80, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
			if (istype(user.w_uniform, /obj/item/clothing/under/gimmick/owl)) //owlsuit has wings, just my imo (but oh this feels like a bad way for me to shoehorn this in)
				if (angry)
					emote_string_trailing = "wings ANGRILY!"
				else
					emote_string_trailing = "wings!"
			. = ..()
		//Guess what it's nested relative pathing baybee
		aflap
			emote_string_trailing = "arms ANGRILY!"
			emote_fail = "writhes ANGRILY!"
			angry = 1

	gesticulate
		emote_string = "gesticulates"
		emote_fail = "wriggles around a lot"
	wgesticulate
		emote_string = "gesticulates wildly"
		emote_fail = "enthusiastically wriggles around a lot!"
	panic //also freakout
		emote_string = "enters a state of hysterical panic!"
		emote_fail = "starts writhing around in manic terror!"
		enact(mob/living/carbon/human/user, voluntary = 0, param)
			if (istype(user) && user.traitHolder && user.traitHolder.hasTrait("scienceteam") && ismuzzled(user))
				playsound(user.loc, pick(user.sound_list_laugh), 80, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
			. = ..()
	smug
		enact(mob/user, voluntary = 0, param) //fuck you for having non-matching strings you piece of shit
			if (user.mind)
				user.add_karma(-2)
			if (!user.restrained())
				return list("<B>[user]</B> folds [his_or_her(user)] arms and smirks broadly, making a self-satisfied \"heh\".", "<I>folds [his_or_her(user)] arms and smirks broadly</I>", MESSAGE_VISIBLE)
			else
				return list("<B>[user]</B> shuffles a bit and smirks broadly, emitting a rather self-satisfied noise.", "<I>shuffles a bit and smirks broadly</I>", MESSAGE_VISIBLE)

/datum/emote/visible_restrain/enact(mob/user, voluntary = 0, param)
	if (!user.restrained())
		if (!isnull(emote_string))
			return list("<B>[user]</B> [emote_string][emote_string[length(emote_string)] != "!" ? "." : ""]", "<I>[emote_string]</I>", MESSAGE_VISIBLE)
		else //jesus
			return list("<B>[user]</B> [emote_string_leading] [call(pronoun_proc)(user)] [emote_string_trailing][emote_string_trailing[length(emote_string_trailing)] != "!" ? "." : ""]", "<I>[emote_string_leading] [call(pronoun_proc)(user)] [emote_string_trailing]</I>", MESSAGE_VISIBLE)
	if (!isnull(emote_fail))
		return list("<B>[user]</B> [emote_fail][emote_fail[length(emote_fail)] != "!" ? "." : ""]", "<I>[emote_fail]</I>", MESSAGE_VISIBLE)
	else
		return list("<B>[user]</B> [emote_fail_leading] [call(pronoun_proc)(user)] [emote_fail_trailing][emote_fail_trailing[length(emote_fail_trailing)] != "!" ? "." : ""]", "<I>[emote_fail_leading] [call(pronoun_proc)(user)] [emote_fail_trailing]</I>", MESSAGE_VISIBLE)

// ---------------------------
//    Audible
// ---------------------------

///Return prebaked string, audible
/datum/emote/simple_audible
	//tag yourself
	cough
		emote_string = "coughs"
	hiccup
		emote_string = "hiccups"
	mumble
		emote_string = "mumbles"
	grumble
		emote_string = "grumbles"
	groan
		emote_string = "groans"
	moan
		emote_string = "moans"
	sneeze
		emote_string = "sneezes"
	wheeze
		emote_string = "wheezes"
	sniff
		emote_string = "sniffs"
	snore
		emote_string = "snores"
	whimper
		emote_string = "whimpers"
	yawn
		emote_string = "yawns"
	choke
		emote_string = "chokes"
	weep
		emote_string = "weeps"
	sob
		emote_string = "sobs"
	wail
		emote_string = "wails"
	whine //it's me
		emote_string = "whines"
	gurgle
		emote_string = "gurgles"
	gargle
		emote_string = "gargles"
	sputter
		emote_string = "sputters"

/datum/emote/simple_audible/enact(mob/user, voluntary = 0, param)
	if (!ismuzzled(user))
		return list("[user] [emote_string].", emote_string, MESSAGE_AUDIBLE)
	//The old system had the outcome audible either way but you can't hear someone failing to make a noise, right?
	return	list("<B>[user]</B> tries to make a noise.", "<I>tries to make a noise</I>", MESSAGE_VISIBLE)


///Same as simple_audible, but possibly plays a laugh too.
/datum/emote/play_laugh
	laugh //also XD
		emote_string = "laughs"
	chuckle
		emote_string = "chuckles"
	giggle
		emote_string = "giggles"
	chortle
		emote_string = "chortles"
	guffaw
		emote_string = "guffaws"
	cackle
		emote_string = "cackles"

/datum/emote/play_laugh/enact(mob/living/carbon/human/user, voluntary = 0, param)
	if (!istype(user)) //sound_list_laugh
		return
	if (!ismuzzled(user))
		if (user.sound_list_laugh && length(user.sound_list_laugh))
			playsound(user.loc, pick(user.sound_list_laugh), 80, 0, 0, user.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
		if (user.traitHolder && user.traitHolder.hasTrait("scienceteam"))
			return list("[user] [emote_string] nervously.", "<I>[emote_string] worriedly</I>", MESSAGE_AUDIBLE)
		return list("[user] [emote_string].", emote_string, MESSAGE_AUDIBLE)
	return	list("<B>[user]</B> tries to make a noise.", "<I>tries to make a noise</I>", MESSAGE_VISIBLE)

//Same as visible_restrain but cares about muzzling instead
/datum/emote/audible_restrain
	/*How 2 Use:
	If emote_string is not null, that's output on success as usual.
	Otherwise it'll [(user) (output emote_string_leading) (pronouns) (emote_string_trailing).]
	Same basic deal for emote_fail(_leading/_trailing) when the user is restrained.
	You're free to mix and match types of success/fail messages otherwise.
	Exclude spaces from the end and start of the leading/trailing strings.
	pronoun_proc is proc/his_or_her or proc/himself_or_herself, I wasn't gonna make 2 subtypes just for that


	*/
	emote_string = null
	var/emote_string_leading = null
	var/emote_string_trailing = null
	var/emote_fail = null
	var/emote_fail_leading = null
	var/emote_fail_trailing = null
	var/pronoun_proc = null //I want you to make the one you use explicit >:(

	retch // also gag
		emote_string = "retches in disgust!"
		emote_fail = "makes a strange choking sound."
	raspberry
		emote_string = "blows a raspberry"
		emote_fail_leading = "slobbers all over"
		emote_fail_trailing = ""
		pronoun_proc = /proc/himself_or_herself
	cry
		enact(mob/user, voluntary = 0, param) //fuck you for having non-matching strings you piece of shit
			if (!ismuzzled(user))
				var/corner = FALSE
				for (var/direction as anything in cardinal)
					var/turf/T1 = get_step(user, direction)
					if (!(T1.CanPass(user, T1)))
						var/turf/T2 = get_step(user, turn(direction,90))
						if (!(T2.CanPass(user, T2)))
							corner = TRUE
							break
				if (corner)
					return list("<B>[user]</B> cries in the corner.", "<I>cries in the corner</I>", MESSAGE_AUDIBLE)
				return list("<B>[user]</B> cries.", "<I>cries</I>", MESSAGE_AUDIBLE)
			else
				return list("<B>[user]</B> makes an odd noise. A tear runs down [his_or_her(user)] face.", "<I>makes an odd noise</I>", MESSAGE_AUDIBLE)



/datum/emote/audible_restrain/enact(mob/user, voluntary = 0, param)
	if (!ismuzzled(user))
		if (!isnull(emote_string))
			return list("<B>[user]</B> [emote_string][emote_string[length(emote_string)] != "!" ? "." : ""]", "<I>[emote_string]</I>", MESSAGE_AUDIBLE)
		else //jesus
			return list("<B>[user]</B> [emote_string_leading] [call(pronoun_proc)(user)] [emote_string_trailing][emote_string_trailing[length(emote_string_trailing)] != "!" ? "." : ""]", "<I>[emote_string_leading] [call(pronoun_proc)(user)] [emote_string_trailing]</I>", MESSAGE_AUDIBLE)
	if (!isnull(emote_fail))
		return list("<B>[user]</B> [emote_fail][emote_fail[length(emote_fail)] != "!" ? "." : ""]", "<I>[emote_fail]</I>", MESSAGE_AUDIBLE)
	else
		return list("<B>[user]</B> [emote_fail_leading] [call(pronoun_proc)(user)] [emote_fail_trailing][emote_fail_trailing[length(emote_fail_trailing)] != "!" ? "." : ""]", "<I>[emote_fail_leading] [call(pronoun_proc)(user)] [emote_fail_trailing]</I>", MESSAGE_AUDIBLE)

// ---------------------------
//    One-offs or odd cases (that aren't that complex anyway)
// ---------------------------

//has a silly easter egg
/datum/emote/simple_audible/sigh
	emote_string = "sighs"

/datum/emote/simple_audible/sigh/enact(mob/user, voluntary = 0, param)
	if (prob(1))
		emote_string = "singhs" //I know I'm doing something dirty here but I'm pretty sure this can't erroneously affect other people's sighs
	. = ..() //...and if it does, who gives a fuck if two people singh at the same time?
	emote_string = "sighs"

//Plays sounds
/datum/emote/simple_audible/gasp
	emote_string = "gasps"

/datum/emote/simple_audible/gasp/enact(mob/living/user, voluntary = 0, param)
	if (!istype(user)) //sound_gasp only exists on living
		return
	if (!ismuzzled(user))
		if (user.health <= 0)
			var/dying_gasp_sfx = "sound/voice/gasps/[pick("male","female")]_gasp_[pick(1,5)].ogg" // this is funnier than adding 5 new gasp sounds for neuters, just pick. for everyone. why not?
			playsound(user, dying_gasp_sfx, 100, 0, 0, user.get_age_pitch())
		else
			playsound(user, user.sound_gasp, 15, 0, 0, user.get_age_pitch())
	. = ..()

//I'm shoving a bunch of these under oneoff purely for the navigability of the object tree
//ends in exclamation mark
/*
/datum/emote/flipout
/datum/emote/flipout/enact(mob/user, voluntary = 0, param)
	return list("<B>[user]</B> flips the fuck out!", "<I>flips the fuck out!</I>", MESSAGE_VISIBLE)

//ends in exclamation mark
/datum/emote/rage //also fury, angry
/datum/emote/rage/enact(mob/user, voluntary = 0, param)
	return list("<B>[user]</B> becomes utterly furious!", "<I>becomes utterly furious!</I>", MESSAGE_VISIBLE)
*/
//maptext differs
/datum/emote/pale
/datum/emote/pale/enact(mob/user, voluntary = 0, param)
	return list("<B>[user]</B> goes pale for a second.", "<I>goes pale...</I>", MESSAGE_VISIBLE)

//one of 2 pronoun-using emotes that can't fail
/datum/emote/shame// also hanghead
/datum/emote/shame/enact(mob/user, voluntary = 0, param)
	return list("<B>[user]</B> hangs [his_or_her(user)] head in shame.", "<I>hangs [his_or_her(user)] head in shame</I>", MESSAGE_VISIBLE)

//one of 2 pronoun-using emotes that can't fail
/datum/emote/shakehead// also smh
/datum/emote/shakehead/enact(mob/user, voluntary = 0, param)
	return list("<B>[user]</B> shakes [his_or_her(user)] head.", "<I>shakes [his_or_her(user)] head</I>", MESSAGE_VISIBLE)

//even the sin that is the visible_restrain code can't deal with this
/datum/emote/facepalm
/datum/emote/facepalm/enact(mob/user, voluntary = 0, param)
	if (!user.restrained())
		return list("<B>[user]</B> places [his_or_her(user)] hand on [his_or_her(user)] face in exasperation.", "<I>places [his_or_her(user)] hand on [his_or_her(user)] face in exasperation</I>", MESSAGE_VISIBLE)
	else
		return list("<B>[user]</B> looks rather exasperated.", "<I>looks rather exasperated</I>", MESSAGE_VISIBLE) //mood

//This one was in the middle of the complex emote section, look how dang long it is!
/datum/emote/handpuppet
/datum/emote/handpuppet/enact(mob/user, voluntary = 0, param)
	return list("<b>[user]</b> throws [his_or_her(user)] voice, badly, while flapping [his_or_her(user)] thumb and index finger like some sort of lips.[prob(10) ? " Admittedly, it is a pretty good impression of the [pick("captain", "head of personnel", "clown", "research director", "chief engineer", "head of security", "medical director", "AI", "chaplain", "detective")]." : null]", null, MESSAGE_VISIBLE)

/datum/emote/help
/datum/emote/help/enact(mob/user, voluntary = 0, param)
	user.show_text("To use emotes, simply enter 'me (emote)' in the input bar. Certain emotes can be targeted at other characters - to do this, enter 'me (emote) (name of character)' without the brackets.")
	user.show_text("For a list of all emotes, use 'me list'. For a list of basic emotes, use 'me listbasic'. For a list of emotes that can be targeted, use 'me listtarget'.")

//Emotes differ per mob type, so
/datum/emote/listtarget/human
/datum/emote/listtarget/human/enact(mob/user, voluntary = 0, param)
	user.show_text("salute, bow, hug, wave, glare, stare, look, leer, nod, flipoff, doubleflip, shakefist, handshake, daps, slap, boggle, highfive, fingerguns")

/datum/emote/listbasic/human
/datum/emote/listbasic/human/enact(mob/user, voluntary = 0, param)
	user.show_text("smile, grin, smirk, frown, scowl, grimace, sulk, pout, nod, nods, blink, drool, shrug, tremble, despair, quiver, shiver, shudder, shake, \
	think, ponder, clap, wave, salute, flap, aflap, laugh, chuckle, giggle, chortle, guffaw, cough, hiccup, sigh, mumble, grumble, groan, moan, sneeze, \
	sniff, snore, whimper, yawn, choke, gasp, weep, sob, wail, whine, gurgle, gargle, blush, flinch, blink_r, eyebrow, shakehead, shakebutt, \
	pale, flipout, rage, shame, crackknuckles, stretch, rude, cry, retch, raspberry, tantrum, gesticulate, wgesticulate, smug, \
	nosepick, flex, facepalm, panic, snap, airquote, twitch, twitch_v, faint, deathgasp, signal, wink, collapse, trip, dance, scream, \
	burp, fart, monologue, contemplate, custom")


