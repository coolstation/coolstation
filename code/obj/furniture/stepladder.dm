/* -------------------------------------------------------------------------- */
/*                               New Stepladder                               */
/* -------------------------------------------------------------------------- */

//should be a lot simpler without all the overloaded baggage of stool

/obj/furniture/stepladder //this can be cleaned up from some lingering buckle stuffs and other checks. also forces looking up
	name = "stepladder"
	desc = "A small freestanding ladder that lets you peek your head up at the ceiling. Mostly for changing lightbulbs. Maybe for wrestling."
	icon = 'icons/obj/fluid.dmi'
	icon_state = "ladder"
	anchored = 0
	density = 0
	var/wrestling = 0
	parts_type = /obj/item/furniture_parts/stepladder
	var/mob/living/stepladder_user = null
	var/can_stand = 1
	var/stood_on = 0
	foldable = 1

	attack_hand(mob/user as mob)
		if (!ishuman(user)) return
		var/mob/living/carbon/human/H = user
		var/mob/living/carbon/human/chump = null
		for (var/mob/M in src.loc)
			if (ishuman(M)) //right now only humans can be on chairs/stepladder, will investigate later
				chump = M
			if (!chump || !chump.on_chair)
				chump = null
			if (H.on_chair)// == 1)
				if (M == user)
					user.visible_message("<span class='notice'><b>[M]</b> steps off [H.on_chair].</span>", "<span class='notice'>You step off [src].</span>")
					src.add_fingerprint(user)
					step_off()
					return

		if (src.foldable)
			user.visible_message("<b>[user.name] folds [src].</b>")
			if ((chump) && (chump != user))
				chump.visible_message("<span class='alert'><b>[chump.name] falls off of [src]!</b></span>")
				step_off()
				//bonus hurt
				chump.changeStatus("weakened", 1 SECOND)
				chump.changeStatus("stunned", 2 SECONDS)
				random_brute_damage(chump, 15)
				playsound(chump.loc, "swing_hit", 50, 1)
			if (wrestling)
				new /obj/item/chair/folded/stepladder/wrestling(src.loc)
			else
				new /obj/item/chair/folded/stepladder(src.loc)

			qdel(src)

	MouseDrop_T(mob/M as mob, mob/user as mob)
		if (M == user) //don't care intents, only mousedrop
			stand_on(M, user)
			return
		if (M != user) //don't care intents, only mousedrop
			user.show_text("You can't lift someone else up on [src]! ...Yet!", "red")
			return
		else
			return ..()

	proc/can_stand(var/mob/user)
		if (!( iscarbon(user) ) || get_dist(src, user) > 2 || user.restrained() || !isalive(user))
			return 0 //wrong type, too far, or dead maybe
		if(src.stepladder_user && src.stepladder_user.buckled == src && src.stepladder_user != user)
			user.show_text("There's already someone up on the [src]!", "red")
			return 0
		return 1


	//should be stand_on but let's just supersede it for now since stepladders don't have buckles
	//this will eventually go to stool/chair and possibly just stool
	proc/stand_on(mob/living/user)
		if(!istype(user)) return
		if(user.hasStatus("weakened")) return
		if(src.stepladder_user && src.stepladder_user.buckled == src && user != src.stepladder_user) return
		if(!can_stand(user)) return

		if(ishuman(user))
			if(ON_COOLDOWN(user, "chair_stand", 1 SECOND))
				return
			var/mob/living/carbon/human/H = user
			user.visible_message("<span class='notice'><b>[user]</b> climbs up on [src][wrestling ? ", ready to bring the pain!" : "."]</span>","<span class='notice'>You climb up on [src][wrestling ? " and get ready to fly!" : "."]</span>")
			//set statuses and refs
			H.on_chair = src
			src.stepladder_user = user
			src.stood_on = 1
			user.buckled = src
			user.setStatus("buckled", duration = INFINITE_STATUS)
			RegisterSignal(user, COMSIG_MOVABLE_SET_LOC, PROC_REF(maybe_unstand))
			//set special effects
			if (src.wrestling)
				H.start_chair_flip_targeting()
				//user.setStatus("aggressivestand", duration = INFINITE_STATUS) //click to not flying-tackle (if possible)
			else
				H.ceilingreach = 1
				H.lookingup = 1
				get_image_group(CLIENT_IMAGE_GROUP_CEILING_ICONS).add_mob(user)
				//user.setStatus("passivestand", duration = INFINITE_STATUS) //click to flying-tackle (if possible)
			//set positioning
			user.set_loc(src.loc)
			user.pixel_y = 10
			if (src.anchored)
				user.anchored = 1
			return 1

	proc/step_off()
		var/mob/user = null
		if(!istype(src.stepladder_user)) return
		if(!src.stepladder_user && src.stepladder_user.buckled != src) return

		user = src.stepladder_user
		if(ishuman(user))
			if(ON_COOLDOWN(user, "chair_stand", 1 SECOND))
				return
			var/mob/living/carbon/human/H = user
			user.visible_message("<span class='notice'><b>[user]</b> steps off of [src].","<span class='notice'>You step off of [src].</span>")
			//set statuses and refs
			H.on_chair = null
			src.stepladder_user = null
			src.stood_on = 0
			user.buckled = null
			user.delStatus("buckled")
			UnregisterSignal(user, COMSIG_MOVABLE_SET_LOC)
			if (src.wrestling)
				H.end_chair_flip_targeting()
			else
				H.lookingup = 0
				get_image_group(CLIENT_IMAGE_GROUP_CEILING_ICONS).remove_mob(user)
			user.ceilingreach = 0
			user.set_loc(src.loc)
			user.pixel_y = 0
			user.anchored = 0
			return 1

	proc/maybe_unstand(source, turf/oldloc)
		// unstand if the guy is not on a turf, or if their ladder is out of range
		if(!isturf(stepladder_user.loc) || (!IN_RANGE(src, oldloc, 1)))
			UnregisterSignal(stepladder_user, COMSIG_MOVABLE_SET_LOC)
			step_off()

/obj/furniture/stepladder/wrestling //this can be cleaned up from some lingering buckle stuffs and other checks. also forces looking up
	name = "wrestling stepladder"
	desc = "A small freestanding ladder that lets you lay the smack down on your enemies. Mostly for wrestling. Not for changing lightbulbs."
	icon = 'icons/obj/fluid.dmi'
	icon_state = "ladder"
	anchored = 0 //no wheels, can be tipped over
	density = 1 //can be pushed around, which may make the user fall
	wrestling = 1
	parts_type = /obj/item/furniture_parts/stepladder/wrestling

//duplicate for now, it's still in stool.dm
/*
/obj/item/chair/folded/stepladder
	name = "stepladder"
	desc = "A folded stepladder. Definitely beats dragging it."
	icon = 'icons/obj/fluid.dmi'
	icon_state = "ladder"
	item_state = "folded_chair"

	attack_self(mob/user as mob)
		if(cant_drop == 1)
			boutput(user, "You can't unfold the [src] when its attached to your arm!")
			return
		else
			var/obj/furniture/stepladder/C = new/obj/furniture/stepladder(user.loc)
			C.set_dir(user.dir)
			boutput(user, "You unfold [C].")
			user.drop_item()
			qdel(src)
		return

/obj/item/chair/folded/stepladder/wrestling
	name = "stepladder"
	desc = "A folded stepladder. Definitely beats people."

	attack_self(mob/user as mob)
		if(cant_drop == 1)
			boutput(user, "You can't unfold the [src] when its attached to your arm!")
			return
		else
			var/obj/furniture/stepladder/wrestling/C = new/obj/furniture/stepladder/wrestling(user.loc)
			C.set_dir(user.dir)
			boutput(user, "You unfold [C].")
			user.drop_item()
			qdel(src)
		return
*/
