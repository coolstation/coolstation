/* -------------------------------------------------------------------------- */
/*                                 Stepladders                                */
/* -------------------------------------------------------------------------- */

//originally in code/obj/stools.dm
//includes turnbuckles since they too are for rasslin'

/obj/stool/chair/stepladder //this can be cleaned up from some lingering buckle stuffs and other checks. also forces looking up
	name = "stepladder"
	desc = "A small freestanding ladder that lets you peek your head up at the ceiling. Mostly for changing lightbulbs. Maybe for wrestling."
	icon = 'icons/obj/fluid.dmi'
	icon_state = "ladder"
	casters = 1
	anchored = 0
	securable = 0
	density = 0 //let people scoot by
	folds_type = /obj/item/chair/folded/stepladder/wrestling
	parts_type = /obj/item/furniture_parts/stepladder

	//TODO: change p_class when someone's on it (modest impact)

	//all we want to do when clicking is unstand or toggle casters
	attack_hand(mob/user as mob)
		var/mob/M = null

		if (isstand(src) && can_unstand(M,user))
			var/aggressive = 0
			if (M != user)
				if (user.a_intent == INTENT_DISARM)
					aggressive = 1
			//if disarm, push 'em (make this an "attempt to knock over chair")
				if (prob(60))
					unstand(M, user, aggressive)
				else
					fall_over(M, user, aggressive)
				return
			unstand(M,user)

		if (src.casters)
			src.toggle_casters(usr)
			return

		if (user.a_intent == INTENT_DISARM)
			//tip it over
			if(prob(25))
				fall_over(src)

	wrestling //this can be cleaned up from some lingering buckle stuffs and other checks. also forces looking up
		name = "wrestling stepladder"
		desc = "A small freestanding ladder that lets you lay the smack down on your enemies. Mostly for wrestling. Not for changing lightbulbs."
		icon = 'icons/obj/fluid.dmi'
		icon_state = "ladder"
		casters = 0 //no wheels but can be tipped over
		density = 1 //can be pushed around, which may make the user fall
		parts_type = /obj/item/furniture_parts/stepladder/wrestling

		//TODO: change p_class when someone's on it (heavy impact)

//wrestlebonus: same general idea, after all
//this type and placement could certainly be improved though
/obj/stool/chair/boxingrope_corner
	name = "Boxing Ropes"
	desc = "Do not exit the ring."
	density = 1
	anchored = 1
	icon = 'icons/obj/decoration.dmi'
	icon_state = "ringrope"
	layer = OBJ_LAYER
	event_handler_flags = USE_FLUID_ENTER | USE_CHECKEXIT | USE_CANPASS

	rotatable = 0
	foldable = 0
	buckle_move_delay = 6 // this should have been a var somepotato WHY WASN'T IT A VAR
	securable = 0

	MouseDrop_T(mob/M as mob, mob/user as mob)
		if (src.can_stand(M,user))
			M.set_loc(src.loc)
			user.visible_message("<span class='notice'><b>[M]</b> climbs up on [src], ready to lay down the pain!</span>", "<span class='notice'>You climb up on [src] and prepare to rain destruction!</span>")
			stand_on(M, 1)

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0) // stolen from window.dm
		if (mover && mover.throwing & THROW_CHAIRFLIP)
			return 1
		if (src.dir == SOUTHWEST || src.dir == SOUTHEAST || src.dir == NORTHWEST || src.dir == NORTHEAST || src.dir == SOUTH || src.dir == NORTH)
			return 0
		if(get_dir(loc, target) == dir)

			return !density
		else
			return 1

	CheckExit(atom/movable/O as mob|obj, target as turf)
		if (!src.density)
			return 1
		if (get_dir(O.loc, target) == src.dir)
			return 0
		return 1

/* ======================================================= */
/* ------------------ Folded Stepladders ----------------- */
/* ======================================================= */

//see folded chairs in chair.dm

/obj/item/chair/folded/stepladder
	name = "stepladder"
	desc = "A folded stepladder. Definitely beats dragging it."
	icon = 'icons/obj/fluid.dmi'
	icon_state = "ladder"
	item_state = "folded_chair"
	unfolds_type = /obj/stool/chair/stepladder

	wrestling
		name = "stepladder"
		desc = "A folded stepladder. Definitely beats people."
		unfolds_type = /obj/stool/chair/stepladder/wrestling
