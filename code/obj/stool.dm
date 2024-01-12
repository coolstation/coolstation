// CONTENTS:
// - Stools
// - Benches
// - Beds
// - Chairs
// - Syndicate Chairs (will trip you up)
// - Folded Chairs
// - Comfy Chairs
// - Shuttle Chairs
// - Wheelchairs
// - Wooden Chairs
// - Pews
// - Office Chairs
// - Electric Chairs

/* ================================================ */
/* -------------------- Stools -------------------- */
/* ================================================ */
//to become /obj/furniture/stool in code/furniture/stool.dm
/obj/stool
	name = "stool"
	desc = "A four-legged padded stool for crewmembers to relax on."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "stool"
	flags = FPRINT | FLUID_SUBMERGE
	throwforce = 10
	pressure_resistance = 3*ONE_ATMOSPHERE
	//will this prevent someone from unbuckling for some reason? temporary + mindswap related
	var/locked = 1
	var/mob/living/stool_user = null
	var/deconstructable = 1
	var/securable = 0
	var/list/scoot_sounds = null
	var/parts_type = /obj/item/furniture_parts/stool

	New()
		if (!src.anchored && src.securable) // we're able to toggle between being secured to the floor or not, and we started unsecured
			src.p_class = 2 // so make us easy to move
		..()

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

	attackby(obj/item/W as obj, mob/user as mob)
		if (iswrenchingtool(W) && src.deconstructable)
			actions.start(new /datum/action/bar/icon/furniture_deconstruct(src, W, 30), user)
			return
		else if (isscrewingtool(W) && src.securable)
			src.toggle_secure(user)
			return
		else
			return ..()

	proc/can_sit(var/mob/M, var/mob/user) //less stringent checks that can apply to every stool, including if the stool is a chair or bed
		if (!M)
			return 0
		if (get_dist(src, user) > 1)
			return 0
		if (( !isalive(user) || is_incapacitated(user) ))
			return 0
		if(src.stool_user && src.stool_user.buckled == src)
			user.show_text("There's already someone in [src]!", "red")
			return 0
		if (M.buckled)
			boutput(user, "[M] is already buckled into something!", "red")
			return 0
		return 1

	//but sometimes you want to definitively sit on things that don't have buckles???
	proc/sit_down(mob/living/to_sit, mob/living/user, var/stand = 0) //Handles the actual sitting down
		if (!can_sit(to_sit,user)) return

		if (to_sit == user)
			user.visible_message("<span class='notice'><b>[to_sit]</b> sits down!</span>", "<span class='notice'>You sit down.</span>")
		else
			user.visible_message("<span class='notice'><b>[to_sit]</b> is sat down by [user].</span>", "<span class='notice'>You sit [to_sit] down.</span>")

		//to_sit.setStatus("sitting", duration = INFINITE_STATUS) //just move to get up
		return

	proc/can_buckle(var/mob/M, var/mob/user)
		.= 0

	proc/buckle_in(mob/living/to_buckle, mob/living/user, var/stand = 0) //Handles the actual buckling in
		if (!can_buckle(to_buckle,user)) return

		if (to_buckle == user)
			user.visible_message("<span class='notice'><b>[to_buckle]</b> buckles in!</span>", "<span class='notice'>You buckle yourself in.</span>")
		else
			user.visible_message("<span class='notice'><b>[to_buckle]</b> is buckled in by [user].</span>", "<span class='notice'>You buckle in [to_buckle].</span>")

		to_buckle.setStatus("buckled", duration = INFINITE_STATUS)
		return

	proc/unbuckle() //Ditto but for unbuckling
		if (src.stool_user)
			src.stool_user.end_chair_flip_targeting()

	proc/can_stand(var/mob/M, var/mob/user)
		.= 0

	proc/unstand() //Ditto but for unstanding
		if (src.stool_user)
			src.stool_user.end_chair_flip_targeting()

	proc/toggle_secure(mob/user as mob)
		if (user)
			user.visible_message("<b>[user]</b> [src.anchored ? "loosens" : "tightens"] the casters of [src].[istype(src.loc, /turf/space) ? " It doesn't do much, though, since [src] is in space and all." : null]")
		playsound(src, "sound/items/Screwdriver.ogg", 100, 1)
		src.anchored = !(src.anchored)
		src.p_class = src.anchored ? initial(src.p_class) : 2
		return

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

	Move(atom/target)
		. = ..()
		if (. && islist(scoot_sounds) && scoot_sounds.len && prob(75))
			playsound( get_turf(src), pick( scoot_sounds ), 50, 1 )

/obj/stool/bee_bed
	//to become /obj/furniture/bee_bed
	// idk. Not a bed proper since humans can't lay in it. Weirdos.
	// would also be cool to make these work with bees.
	// it's hip to tuck bees!
	name = "bee bed"
	icon = 'icons/misc/critter.dmi'
	icon_state = "beebed"
	desc = "A soft little bed the general size and shape of a space bee."
	parts_type = /obj/item/furniture_parts/stool/bee_bed

/obj/stool/bar
	//to become /obj/furniture/stool/bar
	name = "bar stool"
	icon_state = "bar-stool"
	desc = "Like a stool, but in a bar."
	parts_type = /obj/item/furniture_parts/stool/bar
	anchored = 1
	var/loose = 0 //hee hee
	var/lying = 0

	attackby(obj/item/W as obj, mob/user as mob)
		if (isscrewingtool(W))
			src.toggle_loose(user)
			return
		if (isweldingtool(W))
			src.toggle_secure(user)
			return
		else
			return ..()

	attack_hand(mob/user as mob)
		if (src.lying)
			user.visible_message("[user] sets [src] back upright. It still doesn't look secure...",\
			"You set [src] upright again. It still doesn't look secure...")
			src.lying = 0
			animate_rest(src, !src.lying)
			return
		else
			return ..()

	//setting up for a later prank when i unfuckle the rest
	//should really adjust the desc but i'm lazy at the moment
	proc/toggle_loose(mob/user as mob)
		if (user)
			user.visible_message("<b>[user]</b> [src.loose ? "tightens" : "loosens"] the floor supports to the rest of [src]. [src.anchored ? null : "The connection to the floor still looks pretty loose..."]")
		playsound(src, "sound/items/Screwdriver.ogg", 100, 1)
		src.loose = !(src.loose)
		return

	//setting up for a later prank when i unfuckle the rest
	toggle_secure(mob/user as mob)
		if (istype(get_turf(src), /turf/space))
			if (user)
				user.show_text("What exactly are you gunna secure [src] to?", "red")
			return
		if (user)
			user.visible_message("<b>[user]</b> [src.anchored ? "unwelds" : "welds"] the floor supports of [src] securely in place. [src.loose ? "The rest of it still looks pretty loose..." : null]")
		src.anchored ? playsound(src, "sound/items/Welder2.ogg", 100, 1) : playsound(src, "sound/items/Welder.ogg", 100, 1)
		src.anchored = !(src.anchored)
		return

	/* //like this: just plum fuckled. everything else works though
	HasEntered(atom/movable/AM as mob|obj)
		if (!src.loose && src.anchored)
			return //it's stable, do nothing
		if (src.lying)
			return //it's already fallen down
		if (ishuman(AM))
			var/mob/living/carbon/human/H = AM
			H.visible_message("<span class='alert'>[H] tries to sit on [src], but it tips right over!</span>",\
			"<span class='alert'>You're knocked on your ass as [src] tips over! Looks like it wasn't screwed down right.</span>",\
			"<span class='alert'>You hear someone's been knocked right down on they are ass.</span>")
			H.changeStatus("stunned", 5 SECONDS)
			H.changeStatus("weakened", 3 SECONDS)
		src.fall_over()
	*/

	proc/fall_over()
		if (src.lying)
			return
		src.lying = 1
		animate_rest(src, !src.lying)

/obj/stool/wooden
	name = "wooden stool"
	icon_state = "wstool"
	desc = "Like a stool, but just made out of wood."
	parts_type = /obj/item/furniture_parts/woodenstool
/* ================================================= */
/* -------------------- Benches -------------------- */
/* ================================================= */

/obj/stool/bench
	//to become /obj/furniture/bench
	name = "bench"
	desc = "It's a bench! You can sit on it!"
	icon = 'icons/obj/furniture/bench.dmi'
	icon_state = "0"
	anchored = 1
	var/auto = 0
	var/auto_path = null
	parts_type = /obj/item/furniture_parts/bench

	New()
		..()
		SPAWN_DBG(0)
			if (src.auto && ispath(src.auto_path))
				src.set_up(1)

	proc/set_up(var/setup_others = 0)
		if (!src.auto || !ispath(src.auto_path))
			return
		var/dirs = 0
		for (var/dir in cardinal)
			var/turf/T = get_step(src, dir)
			if (locate(src.auto_path) in T)
				dirs |= dir
		icon_state = num2text(dirs)
		if (setup_others)
			for (var/obj/stool/bench/B in orange(1,src))
				if (istype(B, src.auto_path))
					B.set_up()

	//todo: add buckle/stand climb up proc without any of the buckling

	deconstruct()
		if (!src.deconstructable)
			return
		var/oldloc = src.loc
		..()
		for (var/obj/stool/bench/B in orange(1,oldloc))
			if (B.auto)
				B.set_up()
		return

/obj/stool/bench/auto
	auto = 1
	auto_path = /obj/stool/bench/auto

/* ---------- Red ---------- */

/obj/stool/bench/red
	icon = 'icons/obj/furniture/bench_red.dmi'
	parts_type = /obj/item/furniture_parts/bench/red

/obj/stool/bench/red/auto
	auto = 1
	auto_path = /obj/stool/bench/red/auto

/* ---------- Blue ---------- */

/obj/stool/bench/blue
	icon = 'icons/obj/furniture/bench_blue.dmi'
	parts_type = /obj/item/furniture_parts/bench/blue

/obj/stool/bench/blue/auto
	auto = 1
	auto_path = /obj/stool/bench/blue/auto

/* ---------- Green ---------- */

/obj/stool/bench/green
	icon = 'icons/obj/furniture/bench_green.dmi'
	parts_type = /obj/item/furniture_parts/bench/green

/obj/stool/bench/green/auto
	auto = 1
	auto_path = /obj/stool/bench/green/auto

/* ---------- Yellow ---------- */

/obj/stool/bench/yellow
	icon = 'icons/obj/furniture/bench_yellow.dmi'
	parts_type = /obj/item/furniture_parts/bench/yellow

/obj/stool/bench/yellow/auto
	auto = 1
	auto_path = /obj/stool/bench/yellow/auto

/* ---------- Wooden ---------- */

/obj/stool/bench/wooden
	icon = 'icons/obj/furniture/bench_wood.dmi'
	parts_type = /obj/item/furniture_parts/bench/wooden

/obj/stool/bench/wooden/auto
	auto = 1
	auto_path = /obj/stool/bench/wooden/auto

/* ---------- Sauna ---------- */

/obj/stool/bench/sauna
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "saunabench"

/* ============================================== */
/* -------------------- Pews -------------------- */
/* ============================================== */

//this is really more of a backed bench than a long chair tbh
/obj/stool/chair/pew // pew pew
//to become /obj/furniture/bench/pew
	name = "pew"
	desc = "It's like a bench, but more holy. No, not <i>holey</i>, <b>holy</b>. Like, godly, divine. That kinda thing.<br>Okay, it's actually kind of holey, too, now that you look at it closer."
	icon_state = "pew"
	anchored = 1
	rotatable = 0
	foldable = 0
	comfort_value = 2
	deconstructable = TRUE
	securable = 0
	parts_type = /obj/item/furniture_parts/bench/pew
	var/image/arm_image = null
	var/arm_icon_state = null

	New()
		..()
		if (arm_icon_state)
			src.update_icon()

	update_icon()
		if (src.dir == NORTH)
			src.layer = FLY_LAYER+1
		else
			src.layer = OBJ_LAYER
			if ((src.dir == WEST || src.dir == EAST) && !src.arm_image)
				src.arm_image = image(src.icon, src.arm_icon_state)
				src.arm_image.layer = FLY_LAYER+1
				src.UpdateOverlays(src.arm_image, "arm")

	left
		icon_state = "pewL"
	center
		icon_state = "pewC"
	right
		icon_state = "pewR"

/obj/stool/chair/pew/fancy
	icon_state = "fpew"
	arm_icon_state = "arm-fpew"

	left
		icon_state = "fpewL"
		arm_icon_state = "arm-fpewL"
	center
		icon_state = "fpewC"
		arm_icon_state = null
	right
		icon_state = "fpewR"
		arm_icon_state = "arm-fpewR"

/* stepladder */
//to become /obj/furniture/stepladder (this will be a re-write and removal from here)
/obj/stool/chair/stepladder //this can be cleaned up from some lingering buckle stuffs and other checks. also forces looking up
	name = "stepladder"
	desc = "A small freestanding ladder that lets you peek your head up at the ceiling. Mostly for changing lightbulbs. Maybe for wrestling."
	icon = 'icons/obj/fluid.dmi'
	icon_state = "ladder"
	anchored = 0
	density = 0
	var/wrestling = 0
	parts_type = /obj/item/furniture_parts/stepladder

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

	can_stand(var/mob/user)
		if (!( iscarbon(user) ) || get_dist(src, user) > 2 || user.restrained() || !isalive(user))
			return 0 //wrong type, too far, or dead maybe
		if(src.stool_user && src.stool_user.buckled == src && src.stool_user != user)
			user.show_text("There's already someone up on the [src]!", "red")
			return 0
		return 1

	can_buckle(var/mob/M, var/mob/user)
		.= 0 //just in case

	//should be stand_on but let's just supersede it for now since stepladders don't have buckles
	//this will eventually go to stool/chair and possibly just stool
	proc/stand_on(mob/living/user)
		if(!istype(user)) return
		if(user.hasStatus("weakened")) return
		if(src.stool_user && src.stool_user.buckled == src && user != src.stool_user) return
		if(!can_stand(user)) return

		if(ishuman(user))
			if(ON_COOLDOWN(user, "chair_stand", 1 SECOND))
				return
			var/mob/living/carbon/human/H = user
			user.visible_message("<span class='notice'><b>[user]</b> climbs up on [src][wrestling ? ", ready to bring the pain!" : "."]</span>","<span class='notice'>You climb up on [src][wrestling ? " and get ready to fly!" : "."]</span>")
			//set statuses and refs
			H.on_chair = src
			src.stool_user = user
			src.buckledIn = 1
			user.buckled = src
			user.setStatus("buckled", duration = INFINITE_STATUS)
			RegisterSignal(user, COMSIG_MOVABLE_SET_LOC, .proc/maybe_unstand)
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
		if(!istype(src.stool_user)) return
		if(!src.stool_user && src.stool_user.buckled != src) return

		user = src.stool_user
		if(ishuman(user))
			if(ON_COOLDOWN(user, "chair_stand", 1 SECOND))
				return
			var/mob/living/carbon/human/H = user
			user.visible_message("<span class='notice'><b>[user]</b> steps off of [src].","<span class='notice'>You step off of [src].</span>")
			//set statuses and refs
			H.on_chair = null
			src.stool_user = null
			src.buckledIn = 0
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
		if(!isturf(stool_user.loc) || (!IN_RANGE(src, oldloc, 1)))
			UnregisterSignal(stool_user, COMSIG_MOVABLE_SET_LOC)
			step_off()

/obj/stool/chair/stepladder/wrestling //this can be cleaned up from some lingering buckle stuffs and other checks. also forces looking up
	name = "wrestling stepladder"
	desc = "A small freestanding ladder that lets you lay the smack down on your enemies. Mostly for wrestling. Not for changing lightbulbs."
	icon = 'icons/obj/fluid.dmi'
	icon_state = "ladder"
	anchored = 0 //no wheels, can be tipped over
	density = 1 //can be pushed around, which may make the user fall
	wrestling = 1
	parts_type = /obj/item/furniture_parts/stepladder/wrestling

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
			var/obj/stool/chair/stepladder/C = new/obj/stool/chair/stepladder(user.loc)
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
			var/obj/stool/chair/stepladder/wrestling/C = new/obj/stool/chair/stepladder/wrestling(user.loc)
			C.set_dir(user.dir)
			boutput(user, "You unfold [C].")
			user.drop_item()
			qdel(src)
		return
