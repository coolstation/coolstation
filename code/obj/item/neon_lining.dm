///Max stack size for lining
#define MAXLINING 40

///Neon lining autoplacement vars
#define AUTOPLACE_STRUCTURAL 1 //Walls, doors and windows

/// The neon lining object, used for placing neon lining.
/obj/item/neon_lining
	name = "neon lining"
	var/base_name = "neon lining" //<- probably superfluous? how much naming is going on with neon lining coils, the item that lets you place neon lining?
	desc = "A coil of neon lining."
	amount = 1
	max_stack = MAXLINING
	stack_type = /obj/item/neon_lining
	icon = 'icons/obj/decals/neon_lining.dmi'
	icon_state = "item_blue"
	item_state = "electronic"
	throwforce = 2	//I'm pretty sure half the vars from here on down are practically irrelevant and I don't know why they're set like this. comments, people!
	w_class = W_CLASS_TINY
	throw_speed = 2
	throw_range = 5
	flags = TABLEPASS|EXTRADELAY|FPRINT|CONDUCT|ONBELT
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 10
	rand_pos = 2
	event_handler_flags = USE_GRAB_CHOKE | USE_FLUID_ENTER
	special_grab = /obj/item/grab
	inventory_counter_enabled = 1


	abilities = list(/obj/ability_button/lining_auto_walls)

	///Flags for the various autopositioning settings
	var/auto_flags = 0

	var/lining_item_color = "blue"

	New(loc, length = 1, set_color = "blue")
		src.amount = length
		if (set_color in list("blue", "pink", "yellow"))
			lining_item_color = set_color
			updateicon()
		..(loc)
		BLOCK_SETUP(BLOCK_ROPE)

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span class='notice'>[user] begins coiling neon lining!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='notice'>You finish coiling neon lining.</span>")

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] wraps neon lining around [his_or_her(user)] neck and tightens it.</b></span>")
		user.take_oxygen_deprivation(160)
		SPAWN_DBG(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	proc/updateicon()
		set_icon_state("item_[lining_item_color]")
		inventory_counter?.update_number(amount)
		return

/obj/item/neon_lining/cut
	New(loc, length)
		if (length)
			..(loc, length)
		else
			..(loc, rand(1,2))

/obj/item/neon_lining/cut/small
	New(loc, length)
		..(loc, rand(1,5))

///Default length in the Qm crates
/obj/item/neon_lining/shipped
	New(loc, length)
		..(loc, 20)

/obj/item/neon_lining/attack_self(mob/user as mob)
	if (lining_item_color == "blue")
		lining_item_color = "pink"
	else if (lining_item_color == "pink")
		lining_item_color = "yellow"
	else
		lining_item_color = "blue"
	tooltip_rebuild = 1
	boutput(user, "You change the [base_name]'s color to [lining_item_color].")
	updateicon()
	return

/obj/item/neon_lining/get_desc()
	return " There's [amount] length[s_es(amount)] left. It is [lining_item_color]."

/obj/item/neon_lining/attackby(obj/item/W, mob/user)
	if (issnippingtool(W) && src.amount > 1)
		var/obj/item/neon_lining/A = split_stack(round(input("How long of a wire do you wish to cut?","Length of [src.amount]",1) as num))
		if (istype(A))
			A.lining_item_color = src.lining_item_color
			A.updateicon()
			user.put_in_hand_or_drop(A)
			boutput(user, "You cut a piece off the [base_name].")
		//Not sure if these two are still necessary
		//tooltip_rebuild = 1
		//src.updateicon()
		return

	if (check_valid_stack(W))
		stack_item(W)
		if(!user.is_in_hands(src))
			user.put_in_hand(src)
		boutput(user, "You join the lining coils together.")

/obj/item/neon_lining/MouseDrop_T(atom/movable/O as obj, mob/user as mob)
	..(O, user)
	for (var/obj/item/neon_lining/C in view(1, user))
		C.updateicon()

/obj/item/neon_lining/afterattack(turf/F, mob/user)
	if (!isturf(user.loc))
		return

	if (!istype(F,/turf/floor))
		return

	if (get_dist(F,user) > 1)
		boutput(user, "You can't lay neon lining at a place that far away.")
		return

	else //Placing neon
		var/obj/neon_lining/C
		var/to_line_along = 0 //Direction bitflags we want to go along cause there's walls there or whatever
		if (!auto_flags) //No autoplacement: just follow user dir
			to_line_along = get_dir(user, F)
		else //Funky stuff
			if (auto_flags & AUTOPLACE_STRUCTURAL)
				for(var/d in cardinal)
					var/turf/T = get_turf(get_step(F, d))
					if (!T || T.density) //Is a wall, or we're at the edge of the map which I feel might as well be neon-lined
						to_line_along |= d
						continue
					if (locate(/obj/window) in T) //Can't be arsed to check thindows
						to_line_along |= d
						continue
					if (locate(/obj/machinery/door/airlock) in T)
						to_line_along |= d
						continue

		//Now to interpret what walls we're lining along
		if (!to_line_along) //No nearby walls, default to straight & user dir
			C = new /obj/neon_lining(F, user.dir, src.lining_item_color)

		else if (to_line_along in cardinal) //one wall
			C = new /obj/neon_lining(F, to_line_along, src.lining_item_color)

		else if (to_line_along == (NORTH | SOUTH)) //Opposite walls, we need to use & spawn 2 pieces for this
			if (src.amount > 1)
				C = new /obj/neon_lining(F, NORTH, src.lining_item_color)
				C.add_fingerprint(user)
				change_stack_amount(-1)
			C = new /obj/neon_lining(F, SOUTH, src.lining_item_color)

		else if (to_line_along == (EAST | WEST))  //idem but other walls
			if (src.amount > 1)
				C = new /obj/neon_lining(F, EAST, src.lining_item_color)
				C.add_fingerprint(user)
				change_stack_amount(-1)
			C = new /obj/neon_lining(F, WEST, src.lining_item_color)

		else if (to_line_along == (NORTH | SOUTH | EAST | WEST)) //All walls? hope you like your 1x1 neon cell
			C = new /obj/neon_lining(F, SOUTH, src.lining_item_color, 1) //shape 1 is circle

		else
			var/non_lining = to_line_along ^ (NORTH | SOUTH | EAST | WEST) //xor to maybe get a single dir out
			if (non_lining in cardinal) //cause if that's the case we've got 3 walls
				C = new /obj/neon_lining(F, turn(non_lining, 180), src.lining_item_color, 4) //4 is a u piece
			else //By process of elimination, a corner
				C = new /obj/neon_lining(F, turn(to_line_along, -45), src.lining_item_color, 5) //5 i a corner


		boutput(user, "You set some neon lining on the floor.")
		C.add_fingerprint(user)
		change_stack_amount(-1)
	return

#undef MAXLINING


//Neon lining auto-placement
//cause jeez it's tedious

/obj/ability_button/lining_auto_walls
	name = "Toggle wall/window autoorient"
	icon_state = "rocketshoes"

	execute_ability()
		var/obj/item/neon_lining/N = the_item
		if (N.auto_flags & AUTOPLACE_STRUCTURAL)
			N.auto_flags &= ~AUTOPLACE_STRUCTURAL
			boutput(the_mob, "<span class='notice'>No longer orienting lining along structural elements.</span>")
		else
			N.auto_flags |= AUTOPLACE_STRUCTURAL
			boutput(the_mob, "<span class='notice'>Now orienting lining along structural elements.</span>")
		..()

#undef AUTOPLACE_STRUCTURAL
