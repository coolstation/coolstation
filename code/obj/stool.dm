/*

  ______     ______   ______     ______     __         ______
 /\  ___\   /\__  _\ /\  __ \   /\  __ \   /\ \       /\  ___\
 \ \___  \  \/_/\ \/ \ \ \/\ \  \ \ \/\ \  \ \ \____  \ \___  \
  \/\_____\    \ \_\  \ \_____\  \ \_____\  \ \_____\  \/\_____\
   \/_____/     \/_/   \/_____/   \/_____/   \/_____/   \/_____/


*/

//Big fuckin' interaction system rewrite by Bobskunk
//stools and benches live here

// CONTENTS:
// - Intro
// - HowTo
// - Flag Bullshit
// - Base Object
// - CanDo Checks
// - CantDo Checks
// - Actions
// - Interactions
// - Construction/Deconstruction
// - Special Procs

// THE STOOLS THEMSELVES:

// Moved to /furniture/stool.dm
// - Stools
// - Benches
// - Pews

// Moved to /furniture/bed.dm
// - Chairs
// - Syndicate Chairs (will trip you up)
// - Comfy Chairs
// - Shuttle Chairs
// - Wheelchairs
// - Office Chairs
// - Wooden Chairs
// - Electric Chairs
// - Folded Chairs

// Moved to /furniture/stepladder.dm
// - Stepladders
// - Wrestling Stepladders
// - Folded Stepladders

// Moved to /furniture/bed.dm
// - Beds

/* -------------------------------------------------------------------------- */
/*                                    Intro                                   */
/* -------------------------------------------------------------------------- */

/* ------ Whoa What The Fuck Everything's Different Bob What Did You Do ----- */

//  I got tired of weird terminology and things being all over the place so I
// rewrote the shit out of all this okay. It was hard to extend and do fun
// things with chairs and beds like pushing them over and changing lightbulbs
// on the ceiling. Now you can stand on stools (and eventually, tables).
//
// At least with tables I won't do that until we have a good means of securing
// certain areas- give them a bustable plexi/bpglass window that allows items?
//
// Now there's a distinction between sitting on, standing on, buckled in, and
// secured to (bucklecuffs).
//
//  There's also a means of changing that! For example, it would be easy to
// implement cutting off the seatbelts on the shuttle with scissors.
// Kinda preparing to move beds into its own thing, and hopefully get lots of
// stuff moved under obj/furniture. easier to find, sensible to work with.

/* -------------------------------------------------------------------------- */
/*                                    HowTo                                   */
/* -------------------------------------------------------------------------- */

/* --------------------- Okay so how do you interact now -------------------- */

// Wow it's So Easy!!!!

/*
 * Sit down?
 * ---------
 * Click a seat next to you
 * If it's not in use, you will move to it and sit down!
 * To stop sitting, just move away.
 *
 * If it's a special chair (office chair on wheels, wheelchair), click the chair to get up. Just like old buckling!
 *
 * If it's a bed, you lie in it.
 *
 * Buckle in?
 * ----------
 * Help/Disarm Mousedrop yourself (or someone else) onto the seat! Just like before!
 * You must be on the same turf and the stool must not be used.
 * If it does not have seatbelts, it will not buckle, but will attempt to sit you normally.
 *
 * If you are cuffed, you will not be able to do this.
 * If your target is cuffed, you will either secure them, buckle them, or sit them, depending on what options the stools have.
 * Securing is just a new context but it's the same old buckling: it just lets you do it on a thing that doesn't have buckles but does have a spot for
 * something like handcuffs: chairs, beds, benches, but for example not stools
 *
 * If it's a bed, you tuck in and try to sleep.
 * If they have handcuffs and it is a bed that allows it I guess that's tucklecuffing.
 *
 * TODO: If you drag yourself onto a chair that is already being used (by you or someone else) AND it swivels (office chair, barstool), spin it around 3 times.
 * Chance of tipping over/barfing. Fun!
 *
 * Unbuckle?
 * ---------
 * Click your chair (or yourself?) with any intent to unbuckle and get up!
 *
 * If you are cuffed, you will not be able to do this.
 * If your target is cuffed and secured, you will unsecure, unbuckle, and unsit them.
 *
 * If you remove your cuffs while buckled/secured, the next time you try to unbuckle or move it will automatically check and update.
 * For example, if you're buckled on the shuttle and manage to slip your cuffs right before launch, you will not be thrown about.
 * So that just means click yourself or your chair to get up and throw the captain out the airlock!
 *
 * Stand on?
 * ---------
 * Grab/Harm Mousedrop yourself onto the seat!
 * You must be on the same turf and the stool must not be used by someone else, and you must not be buckled or secured to it.
 *
 * Grab intent is for ceiling access. You will automatically look at the ceiling.
 * Harm intent is for flying piledrivers. You will not automatically look at the ceiling.
 * It is possible to toggle between the two by clicking the status effect icon in the upper right, without having to get off the chair! wow!
 *
 * Pro-Tipping: Some stools are much less stable than others and may collapse or be pushed!
 * Unanchored stools are much more likely to fall over.
 *
 * Unseat?
 * -------
 * Help click on a chair occupied by someone else who isn't buckled to stand them up relatively politely.
 * Disarm click on a someone sitting in a chair to shove them out of it rudely.
 * If they're fastened to the chair in some way, this might topple the chair over!
 * OR: Disarm click on the chair to push it over!
 * If they're buckled or secured to it, it's gonna be even worse for them! Fuckin' ow!
 *
 * Folding chairs?
 * ---------------
 * Drag a foldable chair onto itself to fold it.
 * If someone's sitting on it, they will fall on they ass.
 * If someone's standing on it, they will fall on they ass harder.
 *
 * On wheels?
 * ----------
 * If it doesn't fold, this same move can be used to toggle caster locks.
 * This is a weaker anchoring than screwing or welding seats to the floor.
 * The exception is the standard stepladder, which is wheeled and folds.
 *
 * Stepladders are special!
 * ------------------------
 * You can climb onto them by dragging with any intent.
 * Standard ones will make you look up at the ceiling by default.
 * If it is a wrestling stepladder, you automatically are in targetting intent and do not look up.
 * Those modes are still toggleable.
 *
 * The non-wrestling one has casters that can be toggled with a click, as long as nobody's on it.
 * Being on a stepladder with unlocked casters can be risky! This is because you can't sit on them!
 *
 * Also, you can still fold 'em by dragging it onto itself!
 *
 * okay that's it
*/

//The cool news with this is a lot of this shit will become portable so if it ever comes to it you won't have to think of a bed as a type of stool
//Possibly even everything can become a type of......... gasp, FURNITURE??? along with tables, etc.

/* -------------------------------------------------------------------------- */
/*                                Flag Bullshit                               */
/* -------------------------------------------------------------------------- */

//These live in _std/defines/stool.dm and _std/macro/stool.dm but it's good to know.
/*
 * flags
  STOOL_SIT		(1)  click help or disarm on non-buckle chair //also will be used for beds
  STOOL_BUCKLE	(2)  mousedrop help or disarm on buckle chair
  STOOL_STAND	(4)  mousedrop grab (or click grab+harm for wrestling ladder)
  STOOL_SECURE	(8)  disarm
  BED_TUCK		(16) bedsheets secured, comfort delivered

stools only:
 * capability
  cansit(x)
  canbuckle(x)
  canstand(x)
  cansecure(x)

stools and mobs:
 * status
  issit(x)
  isbuckle(x)
  isstand(x)
  issecure(x)
 * setting
  setsit(x)
  setbuckle(x)
  setstand(x)
  setsecure(x)
  settuck(x)
 * unsetting
  setunsit(x)
  setunbuckle(x)
  setunstand(x)
  setunsecure(x)
  setuntuck(x)
*/

/* -------------------------------------------------------------------------- */
/*                                 Base Object                                */
/* -------------------------------------------------------------------------- */

/obj/stool
	name = "stool"
	desc = "A four-legged padded stool for crewmembers to relax on."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "stool"
	flags = FPRINT | FLUID_SUBMERGE
	throwforce = 10
	pressure_resistance = 3*ONE_ATMOSPHERE
	p_class = 2.5
	//because whoopie cushions are for amateurs
	var/obj/item/clothing/head/butt/has_butt = null // time for mature humour
	var/image/butt_img
	//are you temporarily locked in place? (mindswap)
	var/locked = 0
	//what can this seat do or not do, innately
	var/cando_flags = STOOL_SIT | STOOL_STAND
	//what is this seat doing presently (name shared with mob var and its sitting statuses)
	var/stool_flags = 0
	//who's using this thing anyway
	var/mob/living/stool_user = null
	//can it be disassembled into portable parts
	var/deconstructable = 1
	//can anchoring be toggled
	var/securable = 0
	//is it a bit more firmly installed in place
	var/detachable = 0
	//can you fold it up and take it with you
	var/foldable = 0
	//is this thing on wheels
	var/casters = 0
	//do you have to click to stop sitting instead of just moving?
	var/sticky = 0
	//does it rotate easily even while attached and secured?
	var/swivels = 0
	//can you rotate it at all? chairs are directional for example but a stool can swivel too
	var/rotatable = 0 //the base state will be yes maybe but it will be 0 for beds and such
	//is it stable for standing on
	var/unstable = 0
	//is it okay to just stand on this thing while it's moving? no safety probs?
	var/standsafe = 0
	//has it been detached from the floor without being fully unsecured
	var/loose = 0
	//has it been knocked over somehow
	var/lying = 0
	//when you drag it does it make noise
	var/list/scoot_sounds = null
	//if you're strapped in, delay your movement
	var/buckle_move_delay = 6 // this should have been a var somepotato WHY WASN'T IT A VAR
	//what does a foldable stool fold into (should be in /obj/item/chair/folded/)
	var/folds_type = null
	//what does it break into when you deconstruct it (should be in /obj/item/furniture_parts/)
	var/parts_type = /obj/item/furniture_parts/stool

	/*

	____
	|  _ \ _ __ ___   ___ ___
	| |_) | '__/ _ \ / __/ __|
	|  __/| | | (_) | (__\__ \
	|_|   |_|  \___/ \___|___/


	*/

	/* -------------------------------------------------------------------------- */
	/*                                CanDo Checks                                */
	/* -------------------------------------------------------------------------- */

	// - Checks if there's any reason why you could NOT do an action
	// - Broken up into specific checks
	// - Handles messaging if user is provided (a specific, intended act)
	// - Returns 1 if you can, 0 if you can't, 2+ for special cases

	/* ------------------------------ Basic Checks ------------------------------ */

	proc/stool_checks(mob/M, mob/user)
		if (!M || !ismob(M)) return //can't buckle nothing or a not-mob
		if (get_dist(src, user) > 1) return //user must be next to chair
		if (M != user) //stooling someone else?
			if (get_dist(M, user) > 1 || get_dist(M, src) > 1) return //target not in reach of user or chair
		if ((!isalive(user) || is_incapacitated(user))) return //too unconscious
		if (!ticker) //game not started
			user.show_text("You can't mess with stools before the game starts!", "red")
			return
		if (src.lying) return //this is flopped over on its side. no
		if (src.locked)
			if (user)
				boutput(user, "[src] is occupied and the straps are locked tight!")
			return
		//little debug action for now
		if (src.stool_flags || M.stool_flags)
			if (!src.stool_user)
				src.visible_message("fart")
			if (!M.stool_used)
				M.visible_message("piss")
		if (src.stool_user || M.stool_used)
			if (!src.stool_flags)
				src.visible_message("ass")
			if (!M.stool_flags)
				M.visible_message("shit")

		//cleared
		return 1

	/* ------------------------------- Sit Checks ------------------------------- */

	proc/can_sit(mob/M, mob/user)
		//standard checks
		if (!src.stool_checks(M,user)) return

		//check if in use (i.e. any flags set at all) since standing is mutually exclusive and buckling/securing includes sitting
		if (src.stool_flags || src.stool_user || M.stool_flags || M.stool_used)
			return //silently, because clicking to sit is also clicking to unsit and that can get weird

		//check if this is not a sittable stool
		if (!cansit(src))
			if (M == user)
				boutput(user, "You can't see a way to sit on [src].")
			else
				boutput(user, "You can't see a way to sit [him_or_her(M)] on [src].")
			return

		return 1

	/* ------------------------------ Buckle Checks ----------------------------- */

	//returns 2 if you can't buckle but can sit

	proc/can_buckle(mob/M, mob/user)
		//standard checks
		if (!src.stool_checks(M,user)) return
		//special case: if has no seatbelt but can sit, allow a silent case for handling sitting instead (will require can_sit check)
		if (!canbuckle(src) && cansit(src)) return 2
		//target must be on the chair
		if (M.loc != src.loc) return
		//is target already on a different stool??? get outta here
		if (M.stool_used && (M.stool_used != src)) return

		//if someone (or you) is already standing on it
		if (isstand(src) || isstand(M))
			if (M == user)
				if (M == src.stool_user)
					boutput(user, "You can't buckle into [src] while standing on it!", "red")
				else
					boutput(user, "You can't buckle into [src] while someone else is standing on it!", "red")
			else if (user)
				if (M == src.stool_user)
					boutput(user, "You can't buckle [M] into [src] while [hes_or_shes(M)] standing on it!", "red")
				else
					boutput(user, "You can't buckle [M] into [src] while someone else is standing on it!", "red")
			return

		//if someone (or you) is already buckled/secured to it
		if (isbuckle(src) || isbuckle(M))
			if (M == user)
				if (M == src.stool_user)
					boutput(user, "You're already buckled into [src]!", "red")
				else
					boutput(user, "You can't buckle into [src] because someone else is already buckled!", "red")
			else
				if (M == src.stool_user)
					boutput(user, "[hes_or_shes(M)] already buckled into [src]!", "red")
				else
					boutput(user, "You can't buckle [M] into [src] because someone else is already buckled!", "red")
			return
		//if someone is already standing on it
		//it's okay to buckle if you're sitting on it tho
		if (issit(src) || issit(M))
			if (M != src.stool_user)
				if (M == user)
					boutput(user, "You can't buckle into [src] because someone else is already sitting on it!", "red")
				else
					boutput(user, "You can't buckle [M] into [src] because someone else is already sitting on it!", "red")
			return

		//does this have a seatbelt?
		if (!canbuckle(src))
			if (M == user)
				boutput(user, "You can't buckle into [src] because it doesn't have a seatbelt!")
			else
				boutput(user, "You can't buckle [M] into [src] because it doesn't have a seatbelt!")
			return

		if (canbuckle(src))
			if (M == user && M.hasStatus("handcuffed"))
				boutput(user, "You can't buckle into [src] while handcuffed!")
				return

		return 1

	/* ------------------------------ Stand Checks ------------------------------ */

	//returns 2 if user can potentially hop from one chair to another

	proc/can_stand(mob/M, mob/user)
		//standard checks
		if (!src.stool_checks(M,user)) return

		//check if stool is available
		if (src.stool_user && (src.stool_user != M))
			boutput(user, "Someone else is already on [src]!")
			return

		//check if target is available or already doing something
		if (isstand(M))
			if (M.stool_used)
				//standing on this stool?
				if (M.stool_used == src)
					if (M == user)
						boutput(user, "You're already standing on [M.stool_used]!", "red")
					else
						boutput(user, "[hes_or_shes(M)] already standing on [M.stool_used]!", "red")
					return
				//standing on another stool in range?
				else if (M.stool_flags == STOOL_STAND)
					if (M == user)
						//handle a case to hop across chairs and you can present it here (the floor is lava)
						//but for now it's 0
						//return 2
					else
						boutput(user, "[hes_or_shes(M)] already standing on something else!", "red")
					return

		//if (isstand(M) || isstand(src))

		return 1

	//checks if the mob can be secured to the stool, handles distance, status, handcuffs-having humanity, etc.
	//returns 1 if can secure restraints, 2 if it can't but can buckle, 3 if it can neither secure nor buckle, and 0 if it can't
	//gives feedback if user is provided
	proc/can_secure(mob/M, mob/user)
		//standard checks
		if (!src.stool_checks(M,user)) return
		if (M.loc != src.loc) return

		if (src.stool_user && src.stool_user != M)
			boutput(user, "Someone else is already on [src]!")
			return

		if (issecure(src) == M || issecure(src))
			if (M == user)
				boutput(user, "You're already secured to [M.stool_used]! Also you shouldn't see this this is genuinely an error please notify a coder.")
				return
			if (M.stool_used == src)
				boutput(user, "They're already secured to [M.stool_used]!")
				return
			boutput(user, "Someone else is already secured to [src]!", "red")
			return

		if (!cansecure(src))
			//scootching in special case handling for securing:
			//can't secure but it does have a buckle
			if (canbuckle(src))
				return 2
			else if (cansit(src))
				return 2
			if (M == user)
				boutput(user, "[src] doesn't have any place to attach your restraints, and doesn't have seatbelts either! Also you shouldn't see this this is genuinely an error please notify a coder.")
			else
				boutput(user, "[src] doesn't have a seatbelt or a place to attach [M]'s restraints!")
			return

		//fourth stage check for any weird exceptions or edge cases
		if (cansecure(src))
			//gotta be right on the chair
			if (M.loc != src.loc) return
			//gotta have cuffs + not be you + sitting
			if (M.hasStatus("handcuffed"))
				if (M == user)
					boutput(user, "You can't secure your own restraints to [src], you bonehead![isstand(M) ? " That goes double if you're standing on it!" : ""]")
					return
				if (isstand(src))
					boutput(user, "You can't secure someone into [src] while they're standing on it!")
					return
			else
				boutput(user, "You can only secure handcuffs to [src] if there are handcuffs to secure! How did you even get here.")
				return

		return 1

	/* -------------------------------------------------------------------------- */
	/*                                CantDo Checks                               */
	/* -------------------------------------------------------------------------- */

	// - Same as before but undone. should be smaller

	proc/unstool_checks(mob/M, mob/user)
		if (!M) return //can't unbuckle what's not there
		if (get_dist(src, user) > 1) return //user must be next to chair at most
		if (get_dist(src, M) > 1) return //target must be ON chair
		if ((!isalive(user) || is_incapacitated(user))) return //too unconscious
		if (M.stool_used != src) return //who the hell are you sitting on
		if (!ticker) //game not started
			if (user)
				boutput(user, "You can't mess with stools before the game starts!")
			return
		if (src.locked)
			if (user)
				boutput(user, "[src]'s straps are locked tight and escape is impossible!")
			return
		//cleared
		return 1

	proc/can_unsit(mob/M, mob/user)
		//standard checks
		if (!src.unstool_checks(M, user)) return 0

		//is the mob/stool even sitting?
		if (!issit(M) || !issit(src)) return 0

		//doing anything other than sitting?
		if (cansit(src))
			if (src.stool_flags != STOOL_SIT || M.stool_flags != STOOL_SIT) return 0

		return 1

	proc/can_unbuckle(mob/M, mob/user)
		//standard checks
		if (!src.unstool_checks(M, user)) return 0

		//preempting something potentially fucked up with restraints not existing
		if (!M.hasStatus("handcuffed") && issecure(M))
			//delete any securing relationship to whatever stool they are unsecured to because something's fucked
			M.stool_used.unsecure(M)

		//check if anyone is buckled
		if (!isbuckle(M) || !isbuckle(src)) return 0

		//check if this thing has buckles (maybe they got deleted while you were on?)
		if (!canbuckle(src))
			//there's probably nothing actually stopping you from just getting up
			if (src.can_unsit())
				//fuck it
				src.sit_on(M)
				return 2
			//...but just in case you're buckled to something you can't and aren't sitting on
			return

		if (canbuckle(src))
			if (M.hasStatus("handcuffed"))
				boutput(user, "You can't unbuckle from [src] while restrained, you're gonna have to slip 'em.")
				return

		return 1

	proc/can_unstand(mob/M, mob/user)
		//standard checks
		if (!src.unstool_checks(M, user)) return 0
		//check if anyone is standing on it
		if (!isstand(M) || !isstand(src)) return 0
		//real easy
		return 1

	//checks if the mob can be unsecured, with user context, edge case handling, and correcting bad states
	//returns 0 if can't, returns 1 if can, returns 2 if can't but you can unbuckle, returns -1 if there was some issue
	proc/can_unsecure(mob/M, mob/user)
		//standard checks
		if (!src.unstool_checks(M, user)) return 0

		//preempting something potentially fucked up with restraints not existing
		if (!M.hasStatus("handcuffed") && issecure(M))
			//delete any securing relationship to whatever stool they are unsecured to because something's fucked
			M.stool_used.unsecure(M)

		//check if anyone is secured
		if (!issecure(M) || !issecure(src)) return 0

		//seat doesn't have a place for restraints but is secured and you're trying to call unsecure? try unbuckles-unsit
		if (!cansecure(src))
			if (canbuckle(src))
				if(M == user && user.hasStatus("handcuffed"))
					boutput(user, "You can't unbuckle from [src] while restrained, you're gonna have to slip 'em.")
					return
				//just unbuckle
				return 2
			else if (cansit(src))
				//just unsit
				return 3

			else
				boutput(M, "Congrats! You did something really weird. Let a coder know what you or someone else did with the [src] in order to get yourself tangled up like this.")
				reset_stool(M, TRUE)
				return -1

		if (cansecure(src))
			if (M.loc != src.loc) return
			if(M == user && user.hasStatus("handcuffed"))
				boutput(user, "You can't unbuckle from [src] while restrained, you're gonna have to slip 'em.")
				return

		return 1

	/* -------------------------------------------------------------------------- */
	/*                                 Basic Procs                                */
	/* -------------------------------------------------------------------------- */

	New()
		if (!src.anchored && src.securable) // we're able to toggle between being secured to the floor or not, and we started unsecured
			src.p_class = 2 // so make us easy to move
		..()
		if (src.lying)
			animate_rest(src, !src.lying)
			src.p_class = initial(src.p_class) + src.lying // 2.5 while standing, 3.5 while lying

	/* ------------------------------ Basic Clicks ------------------------------ */
	// - Basic sit, unsecure-unstand-unbuckle, righting a fallen stool
	attack_hand(mob/user as mob)
		//TODO: if stool upright, disarm to push stool over, harm to kick it
		var/mob/M = null

		//Stool Occupied Tasks
		if (src.stool_user)
			M = src.stool_user

			//you or someone else on there, in handcuffs?
			if (issecure(src))
				var/try_unsecure = can_unsecure(M,user)
				if (!try_unsecure || (user == M)) return
				switch (user.a_intent)
					if (INTENT_HELP)
						//help them out on help intent
						switch (try_unsecure)
							if (1)
								unsecure(user)
							if (2)
								unbuckle(user)
							if (3)
								unsit(user)
						return
					if (INTENT_DISARM)
						//shove chump, possibly over
						if(!src.lying)
							M.visible_message("<span class='alert'><b>[user]</b> gives [src] a good shove!</span>","<span class='alert'>Your [src] gets shoved recklessly by [user]!</span>")
							if(prob(75))
								fall_over(M,user,TRUE)
						//pick them up and dust them off (just to shove them over again of course)
						else
							pick_up(user)
						return
					if (INTENT_GRAB)
						//handle roughly
						if (src.lying && (user != M))
							pick_up(user)
						else if (try_unsecure == 3)
							user.Attackhand(M)
							unsit(M)
						else
							M.visible_message("<span class='alert'><b>[user]</b> vigorously shakes the [src] with [M] on it!","<span class='alert'>You're banged around a bit from [user] shaking the [src]!</span>")
							animate_storage_thump(M)
							animate_storage_thump(src)
						return
					if (INTENT_HARM)
						//just do a hit (until we all come up with something more interesting)
						user.Attackhand(M)
						return

			//you or someone else on there, buckled in but not cuffed?
			else if (isbuckle(src))
				var/try_unbuckle = can_unbuckle(M,user)
				if (!try_unbuckle) return
				if (user.a_intent == INTENT_HELP)
					//no seatbelt?
					if (try_unbuckle == 2)
						unsit(M, user)
					else
						unbuckle(M, user)
					return
				if (src.lying)
					if (user.a_intent == INTENT_HARM)
						user.Attackhand(M)
					else
						pick_up(user)
					return
				else
					if (user.a_intent == INTENT_DISARM)
						switch(try_unbuckle)
							if(2)
								if (M == user)
									unsit(M, user)
								else
									unsit(M, user, TRUE)
							if(1)
								if (M == user)
									unbuckle(M, user)
								else
									M.visible_message("<span class='alert'><b>[user]</b> shoves the [src]!","<span class='alert'>You're smashed right into [src], but there's already somebody on it!</span>")
									if (prob(75))
										src.fall_over(M,user,TRUE,FALSE)
						return
					if (user.a_intent == INTENT_GRAB)
						switch (try_unbuckle)
							if (2)
								unsit(M, user, TRUE)
								//probably see if you can make you grab the person
								//user.attackhand(M)?
						if (try_unbuckle == 1)
							M.visible_message("<span class='alert'><b>[user]</b> vigorously shakes the [src] with [M] on it!","<span class='alert'>You're banged around a bit from [user] shaking the [src]!</span>")
							animate_storage_thump(M)
							animate_storage_thump(src)
						return
					if (user.a_intent == INTENT_HARM)
						user.Attackhand(M)
						return

			//Standing?
			if (isstand(src) && can_unstand(M,user))
				var/aggressive = 0
				if (M != user)
					if (user.a_intent == INTENT_DISARM)
						aggressive = 1
				//if disarm, push 'em (make this an "attempt to knock over chair")
				unstand(M, user, aggressive)
				return

		//Unoccupied Chair

		//If the chair is still down
		if (src.lying)
			pick_up(user)
			return

		//Sit (only on help intent: we don't want to sit down in the middle of a fight, right?)
		if (user.a_intent == INTENT_HELP)
			if (can_sit(user,user))
				sit_on(user,user)
				return
			if (can_unsit(user,user))
				unsit(user,user)
				return
			//and finally, rotating seats if there's nothing else you can do
			src.rotate()

		return ..()

	/* ------------------ MouseDrops (Complicated Interactions) ----------------- */
	// - Handles buckling, securing, standing, as a destination
	MouseDrop_T(mob/M as mob, mob/user as mob)
		if (!ismob(M)) return //fuck u
		var/buckle = src.can_buckle(M, user)
		//secure (M is handcuffed, all intents but help)
		if (M.hasStatus("handcuffed") && user.a_intent != INTENT_HELP)
			switch(src.can_secure(M, user))
				//normal state
				if (1)
					src.secure_to(M,user)
				//can't secure but can buckle
				if (2)
					src.buckle_in(M,user)
				//can't secure or buckle but can sit
				if (3)
					//handle "you're sitting while handcuffed" in this proc
					src.sit_on(M,user)
			return
		//buckle in: help or disarm
		else if (user.a_intent == INTENT_HELP)
			if(buckle == 1)
				src.buckle_in(M, user)
			//can't buckle but can sit
			else if(buckle == 2)
				//handle "you're sitting without being buckled" in this proc
				src.sit_on(M,user)
			return

		else if (user.a_intent == INTENT_DISARM)
			if(buckle == 1)
				src.buckle_in(M, user)
			//can't buckle but can sit
			else if(buckle == 2)
				//handle "you're sitting without being buckled" in this proc
				src.sit_on(M,user)
			return

		//stand on: grab
		else if (user.a_intent == INTENT_GRAB)
			switch(can_stand(M, user))
				if (1)
					//free chairflips for wrestlers
					if(iswrestler(user))
						stand_on(M, user, TRUE)
					//get it on their
					else
						stand_on(M, user)
				if (2)
					stand_on(M, user, TRUE) //the floor is lava
			return

		//stand on: harm (aggressive, wrestling)
		else if (user.a_intent == INTENT_HARM && can_stand(M, user)) //harm intent, or are some kinda wrestler
			//aggressive stand on (i.e. starts on chairflip)
			stand_on(M, user, TRUE)
			return

		else
			return ..()

	//If you drop it onto itself, fold or toggle casters
	MouseDrop(obj/C as obj)
		if (C == src)
			if (src.foldable)
				src.fold_up(usr)
			else if (src.casters)
				src.toggle_casters(usr)

	/* ---------------------------- Item Interactions --------------------------- */

	attackby(obj/item/W as obj, mob/user as mob)
	//construction
		if (iswrenchingtool(W) && src.deconstructable)
			actions.start(new /datum/action/bar/icon/furniture_deconstruct(src, W, 30), user)
			return
		else if (isscrewingtool(W) && src.securable)
			src.toggle_secured(user)
			return
		else if (isweldingtool(W) && src.detachable)
			src.toggle_attached(user)
			return

	//pranks
		//put a bangin' *fart* on it
		if (istype(W, /obj/item/clothing/head/butt) && !has_butt && src.butt_img)
			has_butt = W
			user.u_equip(has_butt)
			has_butt.set_loc(src)
			boutput(user, "<span class='notice'>You place [has_butt.name] on [name].</span>")
			butt_img.icon_state = "chair_[has_butt.icon_state]"
			UpdateOverlays(butt_img, "chairbutt")
			return

		//take the butt off
		if (ispryingtool(W) && has_butt)
			user.put_in_hand_or_drop(has_butt)
			boutput(user, "<span class='notice'>You pry [has_butt.name] from [name].</span>")
			has_butt = null
			UpdateOverlays(null, "chairbutt")
			return

	//shoving someone into a chair
		if (istype(W, /obj/item/grab))
			var/obj/item/grab/grab = W
			var/mob/target = grab.affecting
			if (can_sit(target))
				if(prob(85))
					//shove them in, intimidatingly
					src.sit_on(target,user,TRUE)
				else
					//overdid it a bit
					src.fall_over(target,user,TRUE)
			else
				//someone's already on it and you just smashed them into it so make them fall too
				logTheThing("combat", user, target, "shoved [constructTarget(target,"combat")] into a chair at [log_loc(src)].")
				target.visible_message("<span class='alert'><b>[user]</b> slams [target] right into [src], with somebody on it!</span>","<span class='alert'>You're smashed right into [src], but there's already somebody on it!</span>")
				src.fall_over(null,user,TRUE)

	//that's all
		return ..()

	Move(atom/target)
		//if someone moves this stool while someone's standing on it
		if (src.stool_user)
			var/mob/M = stool_user
			if (M.loc != src.loc)
				if (isstand(src) && (!src.sticky))
					if(can_unstand(M)) //silent
						if(!src.standsafe)
							src.fall_off(M,M)
						else
							src.unstand(M,M)

		//do movement
		. = ..()

		//handle special post-movement cases for someone using this seat
		if (. && src.stool_user)

			//really it's only if someone's standing on the thing
			if (isstand(src) && !src.standsafe)
				//eventually add push force to this (like imagine standing on a chair and a really big shoe slams into you)
				var/risk = 1
				risk += src.unstable
				risk += src.swivels
				risk += src.casters
				if (prob((100 * risk) / 5))
					if (risk > 3)
						//hard fall
						fall_over(stool_user,TRUE)
						return
					if (risk > 1)
						//less hard fall
						fall_over(stool_user)
					else
						//graceful dismount
						src.unstand(stool_user)
						return

			//temporary set no stool use to avoid tripping up the on-move automatic loc-mismatch check above
			src.stool_user.stool_used = null
			src.stool_user.Move(src.loc)
			src.stool_user.stool_used = src

		//and then the scoot sounds
		if (. && islist(scoot_sounds) && scoot_sounds.len && prob(75))
			playsound( get_turf(src), pick( scoot_sounds ), 50, 1 )

	//find what the fuck proc acts when something tries to throw the chair

	/*
	aw shit see if we can get out of sitting or standing if we move
	Move()
			//see if someone should get down
		if (src.stool_user == target)
			//standing?
			if (isstand(src) && src.anchored)
				//would love it if sprinting in a direction just flung you in that direction while standing on a chair
				src.unstand(target) //just step off
			//not buckled or secured?
			if (!isbuckle(src) && !issecure(src) && !src.sticky)
				src.unsit(target) //just stand up

	*/

	// --- Damage ------------------------
	ex_act(severity)
		switch(severity)
			if (OLD_EX_SEVERITY_1)
				qdel(src)
				return
			if (OLD_EX_SEVERITY_2)
				if (prob(50))
					if (src.deconstructable)
						src.deconstruct()
					else
						qdel(src)
					return
			if (OLD_EX_SEVERITY_3)
				if (src.detachable)
					if (prob(50))
						src.loose = 1
						if (prob(20))
							src.anchored = 0
				else if (src.securable)
					if (prob(40))
						src.anchored = 0
				if (prob(5))
					if (src.deconstructable)
						src.deconstruct()
					else
						qdel(src)
					return
			else
		return

	blob_act(var/power)
		if (prob(power * 2.5))
			var/obj/item/I = new /obj/item/raw_material/scrap_metal()
			I.set_loc(get_turf(src))

			if (src.material)
				I.setMaterial(src.material)
			else
				var/datum/material/M = getMaterial("steel")
				I.setMaterial(M)
			qdel(src)

	disposing()
		for (var/mob/M in src.loc)
			if (M.stool_used == src)
				M.stool_used = null
				M.buckled = null
				M.stool_flags = 0
				M.ceilingreach = initial(M.ceilingreach)
				M.pixel_y = initial(M.pixel_y)
		src.stool_user = null
		if (has_butt)
			has_butt.set_loc(loc)
		has_butt = null
		..()
		return

	/* -------------------------------- Use Procs ------------------------------- */
	//Sitting: Implies an unused chair.
	//sometimes you want to definitively sit on things that don't have buckles- this could be useful for some contexts
	//can pass an aggressive intent to the flavor text or handling
	proc/sit_on(mob/living/M, mob/living/user, var/aggressive)
		if (!ismob(M)) return //type protection (what the fuck)
		//spam protection
		if(ON_COOLDOWN(user, "chair_sit", 1 SECOND)) return
		//if we're here that means we can sit and we should be the only sitter (so let's clear the flags)
		src.stool_flags = 0
		M.stool_flags = 0

		//pranked
		if (src.loose)
			if (prob(66))
				src.fall_over(M, user)

		//visible action (with handcuff handling)
		if (user)
			if (M == user)
				M.visible_message("<span class='notice'><b>[M]</b> sits down on [src].</span>", "<span class='notice'>You sit down on [src].</span>")
			else if (M.hasStatus("handcuffed"))
				M.visible_message("<span class='alert'><b>[user]</b> sits [M] firmly down on [src], but has nothing to secure [him_or_her(M)] to!","<span class='alert'>You're pushed down into [src] by [user], but your restraints aren't secured to anything!</span>")
			else
				M.visible_message("<span class='notice'><b>[user]</b> [aggressive ? "shoves" : "sits"] [M] down [aggressive ? "onto" : "on"] [src]!</span>", "<span class='notice'>You [aggressive ? "shove" : "sit"] [M] down [aggressive ? "onto" : "on"] [src].</span>")

		//move target onto stool and sit them
		M.set_loc(src.loc)
		setsit(src)
		setsit(M)
		src.stool_user = src
		M.stool_used = src
		if (src.sticky)
			M.anchored = 1
			M.buckled = src
		//set statuses
		M.setStatus("sitting", duration = INFINITE_STATUS) //just move to get up from this
		RegisterSignal(M, COMSIG_MOVABLE_SET_LOC, .proc/maybe_unseat)
		return

	//Buckling: Implies either an unused or already seated chair.
	//classic buckling in space, where everything has seatbelts: even the beds

	proc/buckle_in(mob/living/M, mob/living/user) //Handles the actual buckling in (and for chairs, standing)
		if (!ismob(M)) return //i do not want to buckle ceiling tiles to a shuttle seat, or another shuttle seat to a shuttle seat, or a shuttle seat to itself
		if(ON_COOLDOWN(user, "chair_buckle", 1 SECOND)) return
		if (user)
			if (M == user)
				M.visible_message("<span class='notice'><b>[M]</b> buckles in!</span>", "<span class='notice'>You buckle yourself in.</span>")
			else
				M.visible_message("<span class='notice'><b>[M]</b> is buckled in by [user].</span>", "<span class='notice'>You are buckled in by [user].</span>")

		//link flags
		setbuckle(src)
		setbuckle(M)
		//link refs
		src.stool_user = M
		M.stool_used = src
		M.buckled = src
		//and for good measure, if this is a sittable bucklething
		if (cansit(src))
			setsit(src)
			setsit(M)
			M.setStatus("sitting", duration = INFINITE_STATUS)

		//additional handling
		if (src.anchored)
			M.anchored = 1
		M.setStatus("buckled", duration = INFINITE_STATUS)
		RegisterSignal(M, COMSIG_MOVABLE_SET_LOC, .proc/maybe_unseat)
		M.set_clothing_icon_dirty()
		playsound(src, "sound/misc/belt_click.ogg", 50, 1)
		return

	//secures a mob to a stool via restraints
	//only call if you're sure you can do this
	proc/stand_on(mob/living/M, mob/living/user, var/aggressive, var/hop)
		if(ON_COOLDOWN(user, "chair_stand", 1 SECOND)) return
		if (user)
			if (hop)
				user.visible_message("<span class='notice'><b>[M]</b> hops from [M.stool_used] to [src]!", "<span class='notice'>You successfully hop from M.stool_used] to [src]!</span>")
			else if (M == user)
				user.visible_message("<span class='notice'><b>[M]</b> stands up on [src][aggressive ? "! They look pretty serious!" : "."]</span>", "<span class='notice'>You climb up on [src][aggressive ? " and get ready to fly!" : "."]</span>")
			else
				user.visible_message("<span class='notice'><b>[M]</b> is helped onto [src] by [user][aggressive ? "! What are they going to do??" : "."]</span>", "<span class='notice'>You help [M] up onto [src][aggressive ? "! Let's go!" : "."]</span>")

		//if we're here that means we can stand and that's the only state
		//clear_stool_states(M,TRUE) //so, start with clean slate (including any previous stool, just in case we're hopping)

		//set positioning and movement
		M.set_loc(src.loc)
		M.pixel_y = 10
		if (src.anchored)
			M.anchored = 1

		//link flags
		setstand(src)
		setstand(M)
		//link refs
		src.stool_user = M
		M.stool_used = src
		M.buckled = src

		//set statuses
		if (aggressive)
			M.start_chair_flip_targeting()
			M.ceilingreach = 1
			M.setStatus("standing-aggro", duration = INFINITE_STATUS)
		else
			M.ceiling_shown = 1
			get_image_group(CLIENT_IMAGE_GROUP_CEILING_ICONS).add_mob(M)
			M.ceilingreach = 1
			M.setStatus("standing", duration = INFINITE_STATUS)
		RegisterSignal(M, COMSIG_MOVABLE_SET_LOC, .proc/maybe_unseat)
		playsound(src, "sound/misc/belt_click.ogg", 50, 1) //classic noise
		return

	//secures a mob to a stool via restraints
	//also sets buckling because 'securing' is just abstracted buckles
	proc/secure_to(mob/living/M, mob/living/user)
		if (user)
			if (M == user)
				user.visible_message("<span class='notice'><b>[user]</b> secures [his_or_her(M)] restraints to [src]! <b>This is a bug!</b></span>")
			else
				user.visible_message("<span class='notice'><b>[user]</b> secures [M]'s restraints to [src].</span>","<span class='notice'>You have your restraints secured to [src] by [user]!</span>")

		//secure stool
		setsecure(src)
		setbuckle(src)
		src.stool_user = M

		//secure mob
		setsecure(M)
		setbuckle(M)
		M.stool_used = src
		M.buckled = src //lots of stuff still check this but it can be updated later

		//misc handling
		if (cansit(src))
			setsit(src)
			setsit(M)
			M.setStatus("sitting", duration = INFINITE_STATUS)
		if (src.anchored)
			M.anchored = 1

		//set status
		M.setStatus("bucklecuffed", duration = INFINITE_STATUS)
		RegisterSignal(M, COMSIG_MOVABLE_SET_LOC, .proc/maybe_unseat)

		return

	/* ------------------------------- UnUse Procs ------------------------------ */
	// Does not check if it can or should, so check that before calling
	// Does nothing but the bare minimum- if you want someone to fall over, do that before or after you call these too
	// If no user is provided, it does not provide visible messages (or deeper contextual checks)

	// stand up by clicking the seat, or simply moving: yeah that's right if it seats, hit the breats
	/* ---------------------------------- Unsit --------------------------------- */
	proc/unsit(mob/living/user as mob, var/aggressive, var/indirect)
		var/mob/living/M = null
		if (src.stool_user)
			M = src.stool_user
		else
			return

		if (user)
			if (M == user)
				M.visible_message("<span class='notice'><b>[M]</b> gets up from [src].</span>", "<span class='notice'>You get up from [src].</span>")
			else if (indirect)
				M.visible_message("<span class='notice'><b>[M]</b> is knocked off of [src]!</span>", "<span class='notice'>You are knocked off of [src]!</span>")
			else
				M.visible_message("<span class='notice'><b>[user]</b> [aggressive ? "drags" : "helps"] [M] [aggressive ? "off of" : "up from"] [src]!</span>", "<span class='notice'>You [aggressive ? "drag" :"help"] [M] off of [src]!</span>")

		//clear all stool and mob relationships
		src.stool_flags = 0
		src.stool_user = null
		M.stool_flags = 0
		M.stool_used = null
		M.buckled = null
		M.delStatus("sitting")
		return

	/* -------------------------------- Unbuckle -------------------------------- */
	//unbuckle and get off
	proc/unbuckle(mob/living/user as mob)
		var/mob/living/M = null
		if (src.stool_user)
			M = src.stool_user
		else
			return

		//notify witnesses
		if (user)
			if (M == user)
				M.visible_message("<span class='notice'><b>[M]</b> unbuckles from [src]!</span>", "<span class='notice'>You unbuckle from [src].</span>")
			else
				M.visible_message("<span class='notice'><b>[M]</b> is unbuckled  from [src] by [user]!</span>", "<span class='notice'>You are unbuckled from [src] by [user].</span>")

		//clear all stool and mob relationships
		src.stool_flags = 0
		src.stool_user = null
		M.stool_flags = 0
		M.stool_used = null
		M.buckled = null
		//clear related statuses
		M.delStatus("buckled")
		M.delStatus("sitting")
		M.delStatus("stooled")
		playsound(src, "sound/misc/belt_click.ogg", 50, 1)
		return

	/* --------------------------------- Unstand -------------------------------- */
	//Can also include an aggressive context

	proc/unstand(mob/living/user as mob, var/aggressive)
		var/mob/living/M = null
		if (src.stool_user)
			M = src.stool_user
		else
			return

		if (user)
			if (M == user)
				M.visible_message("<span class='notice'><b>[M]</b> steps down from [src][aggressive ? ". What a relief!" :"!"]</span>", "<span class='notice'>You step down from [src].</span>")
			else
				M.visible_message("<span class='notice'><b>[M]</b> is [aggressive ? "knocked" : "helped"] down from [src] by [user]!</span>", "<span class='notice'>You are [aggressive ? "knocked" :"helped"] down from [src] by [user]!</span>")

		//undo all mob shifting/reaching/looking/flipping stuff
		M.pixel_y = 0
		M.ceilingreach = 0
		if (M.hasStatus("standing"))
			M.delStatus("standing")
			M.ceiling_shown = 0
			get_image_group(CLIENT_IMAGE_GROUP_CEILING_ICONS).remove_mob(M)
		else
			M.delStatus("standing-aggro")
			M.end_chair_flip_targeting()

		//clear all stool and mob relationships
		src.stool_flags = 0
		src.stool_user = null
		M.stool_flags = 0
		M.stool_used = null
		M.buckled = null
		return

	/* -------------------------------- Unsecure -------------------------------- */

	proc/unsecure(mob/living/user as mob)
		var/mob/living/M = null
		if (src.stool_user)
			M = src.stool_user
		else
			return

		if (user)
			if (M == user)
				M.visible_message("<span class='notice'><b>[M]</b> unsecures [his_or_her(M)] restraints from [src] which is 100% a bug, please tell a coder.</span>")
			else if (isbuckle(M))
			else
				M.visible_message("<span class='notice'><b>[M]'s</b> restraints are detached from [src] by [user]!</span>", "<span class='notice'>Your restraints are detached from [src] by [user]!</span>")

		//were we secured to a buckle-less stool?
		if(!canbuckle(src))
			setunbuckle(src)
			setunbuckle(M)
			M.delStatus("stooled")

		//otherwise, stay buckled
		setunsecure(src)
		setunsecure(M)
		M.delStatus("bucklecuffed")
		M.changeStatus("buckled")
		//you're still possibly buckled and possibly sat in the stool, though!
		return

/* -------------------------------------------------------------------------- */
/*                       Movement, Construction, Pranks                       */
/* -------------------------------------------------------------------------- */

	//restrict movement
	proc/toggle_casters(mob/user as mob)
		//mousedrop onto self for stuff that doesn't fold but has wheels
		//doesn't move when you push on it
		//still pushed around by explosions and fluids
		if (user)
			user.visible_message("<b>[user]</b> [src.anchored ? "loosens" : "tightens"] the casters of [src].[istype(src.loc, /turf/space) ? " It doesn't do much, though, since [src] is in space and all." : null]")
		playsound(src, "sound/items/Screwdriver.ogg", 100, 1)
		src.anchored = !(src.anchored)
		src.p_class = src.anchored ? initial(src.p_class) : 2
		src.buckle_move_delay = src.anchored ? initial(src.buckle_move_delay) * 2 : initial(src.buckle_move_delay)
		return

	//fix it in place with screws or caster locks, sets anchored
	proc/toggle_secured(mob/user as mob)
		//screwed to the ground
		//doesn't move when you push on it
		//resistant to explosions and fluids unless it's really powerful
		if (istype(get_turf(src), /turf/space))
			if (user)
				user.show_text("What exactly are you gunna secure [src] to?", "red")
			return
		if (detachable && !src.anchored)
			if (user)
				boutput(user, "[src]'s floor supports aren't attached to anything.")
				return
		if (user)
			if (detachable)
				user.visible_message("<b>[user]</b> [src.loose ? "tightens" : "loosens"] the floor supports to the rest of [src]. [src.anchored ? null : "The connection to the floor still looks pretty loose..."]")
				src.loose = !(src.loose)
			else
				user.visible_message("<b>[user]</b> [src.anchored ? "unscrews [src] from" : "secures [src] to"] the floor.")
				src.anchored = !(src.anchored)
				src.p_class = src.anchored ? initial(src.p_class) : 2
			playsound(src, "sound/items/Screwdriver.ogg", 100, 1)
		return

	//weld this thing to the ground for beefier securing
	proc/toggle_attached(mob/user as mob)
		//welded to the ground
		//doesn't move when you push on it
		//not getting pushed by explosions or fluids or anything
		if (!src.loose)
			if (user)
				boutput(user, "[src] is still screwed into the floor support.")
			return
		if (user)
			user.visible_message("<b>[user]</b> [src.anchored ? "unwelds" : "welds"] the floor supports of [src] securely in place. [src.loose ? "The rest of it still looks pretty loose..." : null]")
			src.anchored ? playsound(src, "sound/items/Welder2.ogg", 100, 1) : playsound(src, "sound/items/Welder.ogg", 100, 1)
			src.fall_over()
		src.anchored = !(src.anchored)
		return

	//make it a hand-portable item
	proc/fold_up(mob/user as mob)
		if (!src.foldable)
			return
		if (!ispath(src.folds_type))
			return
		//self handling
		if (user)
			if (src == user.stool_used)
				src.visible_message("<span class='alert'><b>[src.stool_user] gets down from [src] and folds it.</b></span>")
			else
				user.visible_message("<b>[user.name] folds [src].</b>")
		//chump detected
		if ((src.stool_user) && (src.stool_user != user))
			//should be a fall_off proc
			unstand(src.stool_user)
			//bonus hurt
			if (prob(75))
				src.stool_user.changeStatus("weakened", 1 SECOND)
				src.stool_user.changeStatus("stunned", 2 SECONDS)
				random_brute_damage(src.stool_user, 15)
				playsound(src.stool_user.loc, "swing_hit", 50, 1)
				src.stool_user.visible_message("<span class='alert'><b>[src.stool_user] falls off of [src]!</b></span>")
				//TODO: prob(30) to throw chump 1 tile in any direction
			else
				src.stool_user.visible_message("<span class='alert'><b>[src.stool_user] deftly hops off of [src] as it's folded up!</b></span>")
		//fold it up
		var/obj/item/chair/folded/F = new src.folds_type(src.loc)
		if (F && src.material)
			F.setMaterial(src.material)
		if (F && src.color)
			F.color = src.color
		qdel(src)

	//rotato
	proc/rotate(var/face_dir = 0)
		if (rotatable)
			if (!face_dir)
				src.set_dir(turn(src.dir, 90))
			else
				src.set_dir(face_dir)
			if (stool_user)
				var/mob/living/carbon/C = src.stool_user
				C.set_dir(dir)
		return

	//speeeeen
	proc/swivelspin()
		if(ON_COOLDOWN(src, "chair_swivelspin", 10 SECONDS)) return //not too much
		if (swivels)
			var/spins = 0
			var/barfed = 0
			var/standing = (isstand(src))
			if (standing)
				standing = 5
			while(spins < 10)
				src.dir = turn(src.dir,90)
				if (prob(3 + standing))
					src.fall_over(TRUE)
				spins++
			while(spins < 17)
				src.dir = turn(src.dir,90)
				if (prob(1) && !barfed)
					src.stool_user.vomit()
					barfed = 1
				if (prob(3 + standing))
					src.fall_over(TRUE)
				sleep(1)
				spins++
			while(spins < 22)
				src.dir = turn(src.dir,90)
				if (prob(1) && !barfed)
					src.stool_user.vomit()
					barfed = 1
				if (prob(3 + standing))
					src.fall_over(TRUE)
				sleep(2)
				spins++
			while(spins < 25)
				src.dir = turn(src.dir,90)
				sleep(4)
				if (prob(3) && !barfed)
					src.stool_user.vomit()
					barfed = 1
				spins++
			while(spins < 27)
				src.dir = turn(src.dir,90)
				sleep(6)
				if (prob(1) && !barfed)
					src.stool_user.vomit()
					barfed = 1
				spins++
			sleep (10)
			src.dir = turn(src.dir,90)
		return

	//disassemble to parts
	proc/deconstruct()
		if (!src.deconstructable)
			return
		if (ispath(src.parts_type))
			var/obj/item/furniture_parts/P = new src.parts_type(src.loc)
			if (P && src.material)
				P.setMaterial(src.material)
			if (P && src.color)
				P.color = src.color
		else
			playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
			var/obj/item/sheet/S = new (src.loc)
			if (src.material)
				S.setMaterial(src.material)
			else
				var/datum/material/M = getMaterial("steel")
				S.setMaterial(M)
		qdel(src)
		return

	//handles a chair tipping over while someone is sitting in it or empty. can be called on its own (say, an explosion)
	//basically figures out what to do with the person and how hard to hurt them or, say, to throw them
	proc/fall_over(var/mob/living/user as mob, var/aggressive)
		//if we already fell over, don't do anything
		if (src.lying)
			return

		//pick a side to fall, for animation and damage purposes
		var/side = pick(2,3) //(2L 3R)
		//TODO: handling of throwforce and direction imparted on this thing

		//tip the icon over and make it harder to move until it's pick_up()'d
		animate_rest(src, 0, side)
		src.p_class = initial(src.p_class) + 1
		src.lying = side

		//deal damage to victim
		if (src.stool_user)
			var/mob/living/chump = src.stool_user
			//could handle this better but this is a fun way to see it without getting it fully figured out
			var/throw_em
			if (aggressive)
				throw_em = TRUE
			//if they're standing on the thing, deal with them separately
			if (isstand(chump))
				src.fall_off(chump,user,aggressive)
			//otherwise, they're sitting or attempting to sit
			else
				chump.lying = side
				//high chance to damage
				if (prob(90))
					chump.TakeDamage("head", rand(1,3), 0, 0, DAMAGE_BLUNT)
					chump.TakeDamage("chest", rand(1,3), 0, 0, DAMAGE_BLUNT)
					chump.TakeDamage("All", rand(0,1), 0, 0, DAMAGE_BLUNT)
					chump.changeStatus("stunned", 3 SECONDS)
					chump.changeStatus("weakened", 2 SECONDS)
				//set side back to string for limb damage now that anims are over
				if (side == 2 )
					side = "l"
				else
					side = "r"
				//if you're strapped in, you go down with it and probably hit your head
				if (isbuckle(chump) || issecure(chump))
					//and are stuck there until you unbuckle or unsecure
					chump.changeStatus("stooled", INFINITE_STATUS)
					//was this knocked over hard?
					if (aggressive)
						//greater bonus damage
						chump.TakeDamage("head", rand(1,3), 0, 0, DAMAGE_BLUNT)
						chump.TakeDamage("chest", rand(0,2), 0, 0, DAMAGE_BLUNT)
						chump.TakeDamage("[side]_arm", rand(0,3), 0, 0, DAMAGE_BLUNT)
						chump.TakeDamage("[side]_leg", rand(0,3), 0, 0, DAMAGE_BLUNT)
						chump.changeStatus("stunned", 5 SECONDS)
						chump.changeStatus("weakened", 3 SECONDS)
					//or just regular style
					else
						//lesser bonus damage damage
						chump.TakeDamage("head", rand(1,2), 0, 0, DAMAGE_BLUNT)
						chump.TakeDamage("chest", rand(1,2), 0, 0, DAMAGE_BLUNT)
						chump.TakeDamage("[side]_arm", rand(0,2), 0, 0, DAMAGE_BLUNT)
						chump.TakeDamage("[side]_leg", rand(0,2), 0, 0, DAMAGE_BLUNT)
						chump.changeStatus("stunned", 2 SECONDS)
						chump.changeStatus("weakened", 1 SECONDS)
				//gotta toss a chump?
				if (throw_em)
					//how hard? which direction? etc.? these are mysterys, too me
					var/throwdir = null
					if (user)
						throwdir = get_dir(user,chump)
					else
						if (side == "l")
							throwdir = turn(src.dir, -90)
						else
							throwdir = turn(src.dir, 90)
					var/turf/target = get_edge_target_turf(src, throwdir)
					chump.throw_at(target, 1, 1)

		//but after all that? if nobody's on it, the chair just falls over
		else
			src.visible_message("<span class='alert'>[src] tips over!</span>")

	//handles people falling off folded ladders and chairs
	proc/fall_off(var/mob/living/chump as mob, var/mob/living/user as mob, var/aggressive)
		var/throw_em = 0
		if (aggressive && !isbuckle(chump))
			throw_em = TRUE
		src.unstand(chump)

		//pick a side to fall, for animation and damage purposes
		var/side = pick(2,3) //(2L 3R)
		chump.lying = side
		//set it back for limbs
		if (side == 2 )
			side = "l"
		else
			side = "r"
		//TODO: handling of throwforce and direction imparted on this thing

		//deal some damage
		if (prob(25))
			chump.TakeDamage("head", rand(2,5), 0, 0, DAMAGE_BLUNT)
			chump.TakeDamage("chest", rand(2,5), 0, 0, DAMAGE_BLUNT)
			chump.TakeDamage("[side]_arm", rand(2,4), 0, 0, DAMAGE_BLUNT)
			chump.TakeDamage("[side]_leg", rand(2,4), 0, 0, DAMAGE_BLUNT)
			chump.changeStatus("stunned", 5 SECONDS)
			chump.changeStatus("weakened", 3 SECONDS)

		else //bigger hit
			chump.TakeDamage("head", rand(1,2), 0, 0, DAMAGE_BLUNT)
			chump.TakeDamage("chest", rand(1,3), 0, 0, DAMAGE_BLUNT)
			chump.TakeDamage("All", rand(0,1), 0, 0, DAMAGE_BLUNT)
			chump.changeStatus("stunned", 3 SECONDS)
			chump.changeStatus("weakened", 2 SECONDS)


		if (throw_em)
			//how hard? which direction? etc.? these are mysterys, too me
			var/throwdir = null
			if (user)
				throwdir = get_dir(user,chump)
			else
				if (side == "l")
					throwdir = turn(src.dir, -90)
				else
					throwdir = turn(src.dir, 90)
			var/turf/target = get_edge_target_turf(src, throwdir)
			//bigger throw than just falling over while seated
			chump.throw_at(target, 2, 1)
		return

	//for uprighting a stool that has fallen over
	proc/pick_up(var/mob/user)
		//if we're already up, don't do this
		if (!src.lying)
			return
		if (user)
			user.visible_message("[user] sets [src] back upright.","You set [src] back upright.")
		src.lying = 0
		animate_rest(src, 1)
		//is some poor bastard still on here? lift them up too
		if (src.stool_user)
			src.stool_user.lying = 0
		src.p_class = initial(src.p_class)
		src.scoot_sounds = initial(src.scoot_sounds)

/* ------------------------------ A Little Help ----------------------------- */
	//nuclear option to reset stool (and standing/ceiling) shit entirely
	//clears flags and refs and statuses for both stool and optional provided mob
	//now they are free of each other entirely (and if there's another stool involved, clean that up too)
	//this is debug shit mostly and will go away when all edge cases are accounted for (he says, writing ss13 code)

	proc/reset_stool(mob/M, extra)
		src.clear_flags(M)
		src.clear_refs(M)
		//if you pass TRUE along with a mob, see if there's some other stool they're possibly still fucking attached to, for deep cleaning
		if (M)
			//remove any benefits that come from standing on a stool
			clear_standing(M)
			//clear any stool-related statuses
			clear_status(M)
			//clear any lingering unintended anchoring
			reset_anchored(M)
			//clear the "this fucker moved, what now" signal
			UnregisterSignal(M, COMSIG_MOVABLE_SET_LOC)
			//clear the other stool
			if (!isnull(M.stool_used) && M.stool_used != src && extra)
				M.stool_used.reset_stool()

	proc/clear_flags(mob/M)
		src.stool_flags = 0
		if(M)
			M.stool_flags = 0

	proc/clear_refs(mob/M)
		src.stool_user = null
		if(M)
			M.stool_used = null
			M.buckled = null

	proc/clear_standing(mob/M)
		if (M)
			get_image_group(CLIENT_IMAGE_GROUP_CEILING_ICONS).remove_mob(M)
			M.ceilingreach = initial(M.ceilingreach) //just in case there's a really tall mob that somehow stood or sat
			M.ceiling_shown = 0
			M.pixel_y =  0
			M.end_chair_flip_targeting()

	proc/clear_status(mob/M)
		if (M)
			M.delStatus("sitting")
			M.delStatus("buckled")
			M.delStatus("bucklecuffed")
			M.delStatus("standing")
			M.delStatus("standing-aggro")
			M.delStatus("stooled")

	//this will continue to exist though

	//proc for handling wrongly movements while using
	proc/maybe_unseat(source, turf/oldloc)
		// unseat if they're not on a turf, or if their chair is out of range and it's not a shuttle situation
		if(!isturf(stool_user.loc) || (!IN_RANGE(src, oldloc, 1) && (!istype(get_area(src), /area/shuttle || !istype(get_area(oldloc), /area/shuttle)))))

			reset_stool(src.stool_user) //clean them both up
			UnregisterSignal(stool_user, COMSIG_MOVABLE_SET_LOC)
