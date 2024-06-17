/*This is where my header text would go IF I HAD ANY!!!*/

#define default_max_amount 1
#define default_min_amount 1

ABSTRACT_TYPE(/obj/item/stackable_ammo/)
/obj/item/stackable_ammo/
	name = "1 round"
	real_name = "round"
	desc = "You gotta have bullets."
	icon = 'icons/obj/items/modular_guns/ammo.dmi'
	icon_state = "white"
	var/icon_empty = "empty"
	var/icon_one   = "bullet_white"
	var/icon_full  = "white"
	var/icon_shell = "white_case"
	//uses_multiple_icon_states = 1
	opacity = 0
	density = 0
	anchored = 0.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 1
	throw_range = 8
	w_class = W_CLASS_TINY
	burn_point = 700
	burn_possible = TRUE
	burn_output = 750
	health = 10
	amount = 1
	max_stack = 1000
	stack_type = null
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1
	inventory_counter_enabled = 1
	var/min_amount = default_min_amount
	var/max_amount = default_max_amount
	var/datum/projectile/projectile_type = null
	var/ammo_DRM = null
	var/reloading = 0


	New(var/atom/loc, var/amt = 1 as num)
		var/default_amount = (min_amount==max_amount) ? min_amount : rand(min_amount,max_amount)
		src.amount = max(amt,default_amount) //take higher
		..(loc)
		src.update_stack_appearance()
	/*
	proc/setup(var/atom/L, var/amt = 1 as num)
	set_loc(L)
		set_amt(amt)

	proc/set_amt(var/amt = 1 as num)
		var/default_amount = default_min_amount == default_max_amount ? default_min_amount : rand(default_min_amount, default_max_amount)
		src.amount = max(amt,default_amount)
		src.update_stack_appearance()*/
/*
	unpooled()
		..()
		var/default_amount = default_min_amount == default_max_amount ? default_min_amount : rand(default_min_amount, default_max_amount)
		src.amount = max(1, default_amount) //take higher
		src.update_stack_appearance()*/

	disposing()
		if (usr)
			usr.u_equip(src) //wonder if that will work?
		amount = 1
		..()

	update_stack_appearance()
		src.UpdateName()
		src.inventory_counter.update_number(src.amount)
		switch (src.amount)
			if (-INFINITY to 0)
				qdel(src) // ???
			if(1)
				src.icon_state = icon_one
			if ((default_max_amount-1) to 2)
				src.icon_state = icon_empty
			else
				src.icon_state = icon_full


	UpdateName()
		src.name = "[src.amount] [name_prefix(null, 1)][src.real_name][s_es(src.amount)][name_suffix(null, 1)]"

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span class='notice'>[user] is stacking rounds!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='notice'>You finish stacking rounds.</span>")

	failed_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='alert'>You need another stack!</span>")

	attackby(var/obj/item/I as obj, mob/user as mob)
		/*if (istype(I, /obj/item/stackable_ammo) && (src.amount < src.max_stack) && (src.type == I.type))

			user.visible_message("<span class='notice'>[user] stacks some rounds.</span>")
			stack_item(I)*/
		if(!stack_item(I))
			if(istype(I, /obj/item/gun/modular/))
				src.reload(I, user)
			else
				..(I, user)

	attack_hand(mob/user as mob)
		if ((user.l_hand == src || user.r_hand == src) && user.equipped() != src)
			var/obj/item/stackable_ammo/A = split_stack(round(input("How many rounds do you want to take from the stack?") as null|num))
			if (istype(A))
				user.put_in_hand_or_drop(A)
			else
				boutput(user, "<span class='alert'>You wish!</span>")
			/*
			var/amt = round(input("How many rounds do you want to take from the stack?") as null|num)
			if (amt && src.loc == user && !user.equipped())
				if (amt > src.amount || amt < 1)
					boutput(user, "<span class='alert'>You wish!</span>")
					return
				change_stack_amount( 0 - amt )
				var/obj/item/stackable_ammo/young_money = new src.type()
				young_money.setup(user.loc, amt)
				young_money.Attackhand(user)*/
		else
			..(user)

	proc/reload(var/obj/item/gun/modular/M, mob/user as mob)
		if(reloading)
			return
		if(!istype(M))
			return
		if(!projectile_type)
			return
		if(!M.ammo_list)
			M.ammo_list = list()
		M.chamber_checked = 0
		if((M.ammo_list.len >= M.max_ammo_capacity) || !M.max_ammo_capacity)
			if(M.current_projectile)
				boutput(user, "<span class='notice'>There's already a cartridge in [M]!</span>")
				return
			if(!M.current_projectile)
				boutput(user, "<span class='notice'>You stuff a cartridge down the barrel of [M]</span>")
				M.current_projectile = new projectile_type()
				amount --
				update_stack_appearance()
				if(amount < 1)
					user.u_equip(src)
					src.dropped(user)
					qdel(src)
				M.inventory_counter.update_number(!!M.current_projectile)
				playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1) //play the sound here because single shot bypasses cycle_ammo
			return
		reloading = 1
		if(amount < 1)
			user.u_equip(src)
			src.dropped(user)
			qdel(src)
		SPAWN_DBG(0)
			boutput(user, "<span class='notice'>You start loading rounds into [M]</span>")
			while(M.ammo_list.len < M.max_ammo_capacity)
				if(amount < 1)
					user.u_equip(src)
					src.dropped(user)
					qdel(src)
					break
				playsound(src.loc, "sound/weapons/casings/casing-0[rand(1,9)].ogg", 10, 0.1, 0, 0.8)
				amount--
				M.ammo_list += projectile_type
				update_stack_appearance()
				sleep(5)
			playsound(src.loc, "sound/weapons/gunload_heavy.ogg", 30, 0.1, 0, 0.8)
			boutput(user, "<span class='notice'>The hold is full</span>")
			if(!M.current_projectile)
				M.process_ammo()
			M.inventory_counter.update_number(M.ammo_list.len)
			reloading = 0

/obj/item/stackable_ammo/pistol/
	name = "standardised pistol round"
	real_name = "standardised pistol round"
	desc = "The ubiquitous pistol round, finally standardized."
	projectile_type = /datum/projectile/bullet/bullet_22
	stack_type = /obj/item/stackable_ammo/pistol
	ammo_DRM = GUN_NANO | GUN_ITALIAN | GUN_JUICE
	icon_state = "nt_brass"
	icon_full  = "nt_brass"
	icon_empty = "nt_empty"
	icon_one   = "bullet_brass"
	icon_shell = "brass_case"

	three
		min_amount = 3
		max_amount = 3

	five
		min_amount = 5
		max_amount = 5

	ten
		min_amount = 10
		max_amount = 10

/obj/item/stackable_ammo/pistol_38AP
	name = "armor-piercing pistol round"
	real_name = "armor-piercing pistol round"
	desc = "The weak and useless pistol round, finally buffed."
	projectile_type = /datum/projectile/bullet/revolver_38/AP
	stack_type = /obj/item/stackable_ammo/pistol_38AP
	ammo_DRM = GUN_NANO | GUN_ITALIAN | GUN_JUICE
	icon_state = "nt_red"
	icon_full  = "nt_red"
	icon_empty = "nt_empty"
	icon_one   = "bullet_red"
	icon_shell = "red_case"

	three
		min_amount = 3
		max_amount = 3

	five
		min_amount = 5
		max_amount = 5

	ten
		min_amount = 10
		max_amount = 10

/obj/item/stackable_ammo/tranq
	name = "\improper NT Tranq-Will-8-or"
	real_name = "\improper NT Tranq-Will-8-or"
	desc = "What the fuck are these even?"
	projectile_type = /datum/projectile/bullet/tranq_dart
	stack_type = /obj/item/stackable_ammo/tranq
	ammo_DRM = GUN_NANO
	icon_state = "nt_white"
	icon_full  = "nt_white"
	icon_empty = "nt_empty"
	icon_one   = "it_what"
	icon_shell = "white_case"

	three
		min_amount = 3
		max_amount = 3

	five
		min_amount = 5
		max_amount = 5

	ten
		min_amount = 10
		max_amount = 10

/obj/item/stackable_ammo/capacitive/
	name = "\improper NT In-Capacit-8-or"
	real_name = "\improper NT In-Capacit-8-or"
	desc = "A less-than-lethal solution to declining asset values."
	projectile_type = /datum/projectile/energy_bolt
	stack_type = /obj/item/stackable_ammo/capacitive
	ammo_DRM = GUN_NANO | GUN_ITALIAN | GUN_JUICE
	icon_state = "nt_stun"
	icon_full  = "nt_stun"
	icon_empty = "nt_stun_empty"
	icon_one   = "bullet_nerf"
	icon_shell = "nerf_case"

	three
		min_amount = 3
		max_amount = 3

	five
		min_amount = 5
		max_amount = 5

	ten
		min_amount = 10
		max_amount = 10

/obj/item/stackable_ammo/capacitive_burst
	name = "\improper NT In-Capacit-8-or MAX"
	real_name = "\improper NT In-Capacit-8-or MAX"
	desc = "A lot of problems? A lot of solutions."
	projectile_type = /datum/projectile/energy_bolt/three
	stack_type = /obj/item/stackable_ammo/capacitive_burst
	ammo_DRM = GUN_NANO
	icon_state = "nt_stun"
	icon_full  = "nt_stun"
	icon_empty = "nt_stun_empty"
	icon_one   = "bullet_nerf"
	icon_shell = "nerf_case"

	three
		min_amount = 3
		max_amount = 3

	five
		min_amount = 5
		max_amount = 5

	ten
		min_amount = 10
		max_amount = 10

/obj/item/stackable_ammo/radbow
	name = "\improper Syndicate Radioactive Darts"
	real_name = "Syndicate Radioactive Darts"
	projectile_type = /datum/projectile/rad_bolt
	stack_type = /obj/item/stackable_ammo/radbow
	desc = "Stealthy projectiles that cause insidious radiation poisoning."

	three
		min_amount = 3
		max_amount = 3

	five
		min_amount = 5
		max_amount = 5

	ten
		min_amount = 10
		max_amount = 10

/obj/item/stackable_ammo/zaubertube/
	name = "\improper Elektrograd лазерный Zaubertube"
	real_name = "Elektrograd лазерный Zaubertube"
	desc = "A small glass bulb filled with hypergolic incandescent chemicals."
	projectile_type = /datum/projectile/laser
	stack_type = /obj/item/stackable_ammo/zaubertube
	ammo_DRM = GUN_SOVIET | GUN_FOSS
	icon_state = "zaubertubes"
	icon_full  = "zaubertubes"
	icon_empty = "zaubertubes_empty"
	icon_one   = "zauber_tube"
	icon_shell = "zauber_spent"

	three
		min_amount = 3
		max_amount = 3

	five
		min_amount = 5
		max_amount = 5

	ten
		min_amount = 10
		max_amount = 10

ABSTRACT_TYPE(/obj/item/stackable_ammo/scatter/)
/obj/item/stackable_ammo/scatter/ // ABSOLUTELY USE THIS TYPE FOR ALL SCATTER AMMO, EVEN OPTICAL
	name = "generic scatter ammo"
	real_name = "generic scatter ammo"
	desc = "debug"
	icon_state = "shells"
	icon_full  = "shells"
	icon_empty = "empty"
	icon_one   = "shell_blue"
	icon_shell = "shell_case"

	reload(var/obj/item/gun/modular/M, mob/user as mob)
		if(!M.scatter)
			boutput(user, "<span class='notice'>That shell won't fit the breech.</span>")
			return
		..()


/obj/item/stackable_ammo/scatter/buckshot
	name = "\improper Hot Pocketz"
	real_name = "\improper Hot Pocketz"
	desc = "Ecologically and economically hand-packed by local Juicer children."
	projectile_type = /datum/projectile/bullet/a12
	stack_type = /obj/item/stackable_ammo/scatter/buckshot

	three
		min_amount = 3
		max_amount = 3

	five
		min_amount = 5
		max_amount = 5

	ten
		min_amount = 10
		max_amount = 10

/obj/item/stackable_ammo/scatter/slug_rubber // scatter doesnt mean scatter, just means thick:)
	name = "standard rubber slug"
	real_name = "standard rubber slug"
	desc = "An allegedly less-than-lethal riot deterrent slug, at least in low doses."
	projectile_type = /datum/projectile/bullet/abg
	stack_type = /obj/item/stackable_ammo/scatter/slug_rubber

	three
		min_amount = 3
		max_amount = 3

	five
		min_amount = 5
		max_amount = 5

	ten
		min_amount = 10
		max_amount = 10

/obj/item/stackable_ammo/flashbulb/
	name = "\improper FOSSYN. CATHODIC FLASH BULBS"
	real_name = "FOSSYN. CATHODIC FLASH BULB"
	desc = "A hefty glass tube filled with ionic gas, and two opposing electrodes."
	icon = 'icons/obj/items/modular_guns/fossgun.dmi'
	icon_state = "bulb"
	icon_shell = "bulb_burnt"
	projectile_type = null
	max_stack = 1 // not stackable! scandalous!
	ammo_DRM = GUN_FOSS
	var/max_health = 20
	var/min_health = 15

	update_stack_appearance()
		src.UpdateName()
		src.inventory_counter.update_number(src.amount)


	reload(var/obj/item/gun/modular/M, mob/user as mob)
		if(reloading)
			return
		if(!istype(M))
			return
		if(!M.flashbulb_only)
			return
		if(!M.ammo_list)
			M.ammo_list = list()
		if(M.ammo_list.len >= M.max_ammo_capacity)
			return
		reloading = 1
		SPAWN_DBG(0)
			boutput(user, "<span class='notice'>You start loading a bulb into [M].</span>")
			if(M.ammo_list.len < M.max_ammo_capacity)
				playsound(src.loc, "sound/weapons/casings/casing-0[rand(1,9)].ogg", 10, 0.1, 0, 0.8)
				M.ammo_list += src
				user.u_equip(src)
				src.dropped(user)
				src.set_loc(M)
				sleep(5)
				if(M.ammo_list.len == M.max_ammo_capacity)
					playsound(src.loc, "sound/weapons/gunload_heavy.ogg", 30, 0.1, 0, 0.8)
				reloading = 0

/obj/item/stackable_ammo/flashbulb/better
	max_health = 25
	min_health = 20
	icon_state = "bulb_good"

/obj/item/storage/box/foss_flashbulbs
	name = "box of FOSSYN flashbulbs"
	icon_state = "foss_bulb"
	spawn_contents = list(/obj/item/stackable_ammo/flashbulb, /obj/item/stackable_ammo/flashbulb, /obj/item/stackable_ammo/flashbulb, /obj/item/stackable_ammo/flashbulb, /obj/item/stackable_ammo/flashbulb, /obj/item/stackable_ammo/flashbulb)

/obj/item/storage/box/foss_flashbulbs/better
	name = "box of premium FOSSYN flashbulbs"
	spawn_contents = list(/obj/item/stackable_ammo/flashbulb/better, /obj/item/stackable_ammo/flashbulb/better, /obj/item/stackable_ammo/flashbulb/better, /obj/item/stackable_ammo/flashbulb, /obj/item/stackable_ammo/flashbulb, /obj/item/stackable_ammo/flashbulb)
	make_my_stuff()
		..()
		if (prob(70))
			new /obj/item/gun_parts/magazine/juicer(src)
		else
			new /obj/item/gun_parts/accessory/horn(src)

/obj/item/storage/box/foss_gun_kit
	name = "Syndicate Gun Kit"
	icon_state = "foss_gun"
	spawn_contents = list(/obj/item/gun/modular/foss, /obj/item/stackable_ammo/flashbulb/better, /obj/item/stackable_ammo/flashbulb/better, /obj/item/stackable_ammo/flashbulb, /obj/item/stackable_ammo/flashbulb)
	make_my_stuff()
		..()
		if (prob(50))
			new /obj/item/gun_parts/stock/foss/loader(src)
		else
			new /obj/item/gun_parts/barrel/foss/long(src)

// NEW PROJECTILE TYPES TEMPORARY STORAGE


/datum/projectile/energy_bolt/three
	power = 10
	shot_number = 3

/datum/projectile/energy_bolt/five
	power = 8
	shot_number = 5

/datum/projectile/laser/three
	power = 15
	shot_number = 3


/datum/projectile/laser/flashbulb
	name = "open-source laser"
	icon_state = "u_laser"
	power = 15
	cost = 50
	dissipation_delay = 5
	brightness = 0
	sname = "open-source laser"
	shot_sound = 'sound/weapons/Laser.ogg'
	color_red = 0
	color_green = 1
	color_blue = 0
	projectile_speed = 75


/datum/projectile/laser/flashbulb/two
	power = 25
	color_red = 1
	color_green = 1
	cost = 75
	projectile_speed = 70

/datum/projectile/laser/flashbulb/three
	power = 35
	color_red = 1
	color_green = 0
	cost = 100
	projectile_speed = 65

	on_hit(atom/hit)
		if (isliving(hit))
			var/mob/living/L = hit
			L.changeStatus("slowed", 1 SECOND)
			L.change_misstep_chance(1)
			L.emote("twitch_v")
		if(prob(5))
			hit.ex_act(OLD_EX_LIGHT)
		return

/datum/projectile/laser/flashbulb/four
	power = 45
	color_red = 1
	color_green = 0
	cost = 200
	projectile_speed = 60

	on_hit(atom/hit)
		fireflash(get_turf(hit), 0)
		if (isliving(hit))
			var/mob/living/L = hit
			L.changeStatus("slowed", 1 SECOND)
			L.change_misstep_chance(1)
			L.emote("twitch_v")
		if(prob(20))
			hit.ex_act(OLD_EX_LIGHT)
		return

#undef default_max_amount
#undef default_min_amount
