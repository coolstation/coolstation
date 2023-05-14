
#define MAXLINING 40

/// The neon lining object, used for placing neon lining.
/obj/item/neon_lining
	name = "neon lining"
	var/base_name = "neon lining"
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
	//rand_pos = 1 Unnessecary atm, see New()
	event_handler_flags = USE_GRAB_CHOKE | USE_FLUID_ENTER
	special_grab = /obj/item/grab
	inventory_counter_enabled = 1

	var/lining_item_color = "blue"

	New(loc, length = 1, set_color = "blue")
		src.amount = length
		if (set_color in list("blue", "pink", "yellow"))
			lining_item_color = set_color
			updateicon()
		//This can probably be folded into obj/item/rand_pos if we add a var for the offset severity
		pixel_x = rand(-2,2)
		pixel_y = rand(-2,2)
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

	if (!istype(F,/turf/simulated/floor))
		return

	if (get_dist(F,user) > 1)
		boutput(user, "You can't lay neon lining at a place that far away.")
		return

	else
		var/obj/neon_lining/C = new /obj/neon_lining(F, user.dir, src.lining_item_color)
		boutput(user, "You set some neon lining on the floor.")
		C.add_fingerprint(user)
		change_stack_amount(-1)
	return

#undef MAXLINING
