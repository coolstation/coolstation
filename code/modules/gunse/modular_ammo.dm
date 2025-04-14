/*This is where my header text would go IF I HAD ANY!!!*/

//shorten up this file a bit by making all the 3/5/10 subtypes this way
#define THE_USUAL_FLAVOURS(_path, _name)\
/obj/item/stackable_ammo/_path/three;\
/obj/item/stackable_ammo/_path/three/name = _name+" (x3)";\
/obj/item/stackable_ammo/_path/three/min_amount = 3;\
/obj/item/stackable_ammo/_path/three/max_amount = 3;\
/obj/item/stackable_ammo/_path/five;\
/obj/item/stackable_ammo/_path/five/name = _name+" (x5)";\
/obj/item/stackable_ammo/_path/five/min_amount = 5;\
/obj/item/stackable_ammo/_path/five/max_amount = 5;\
/obj/item/stackable_ammo/_path/ten;\
/obj/item/stackable_ammo/_path/ten/name = _name+" (x10)";\
/obj/item/stackable_ammo/_path/ten/min_amount = 10;\
/obj/item/stackable_ammo/_path/ten/max_amount = 10

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
	var/caliber = 0 // 0,1,2,3 : standard, wide, long, both.
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
	var/fiddlyness = 0


	New(var/atom/loc, var/amt = 1 as num)
		var/default_amount = (min_amount==max_amount) ? min_amount : rand(min_amount,max_amount)
		src.amount = max(amt,default_amount) //take higher
		..(loc)
		src.update_stack_appearance()

	//All the ammo has 3/5/10 variants that need to stack onto the parent type
	//But then also you get subtypes that shouldn't, so the istype checks the normal version of this pro does don't work (for example, NT mini shot shouldn't stack onto regular NT shot)
	//luckily, since all ammo (at time of writing anyway) has stack_type set we can just compare those directly
	check_valid_stack(obj/item/I)
		if (src.stack_type)
			if(src.stack_type == I.stack_type)
				return TRUE
		return FALSE

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
		src.inventory_counter?.update_number(src.amount)
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
				actions.start(new/datum/action/bar/private/load_ammo(I, src), user)
				//src.reload(I, user)
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

	//just realized this needs some checks to handle things like: moved away from ammo, no longer holding gun, etc.
	//whoops that's current you's and later me's problem
	/*proc/reload(var/obj/item/gun/modular/M, mob/user as mob)
		if(reloading)
			return
		if(!istype(M))
			return
		if(!projectile_type)
			return
		if(!M.ammo_list)
			M.ammo_list = list()
		if(M.jammed)
			return //clear that shit first!
		M.chamber_checked = 0

		//single shot and chamber handling
		if((M.ammo_list.len >= M.max_ammo_capacity) || !M.max_ammo_capacity)
			if(M.current_projectile)
				if (!M.max_ammo_capacity)
					boutput(user, "<span class='notice'>There's already a cartridge in [M]!</span>")
				else
					boutput(user, "<span class='notice'>You can't load [M] any further!</span>")
				return
			else
				reloading = TRUE
				boutput(user, "<span class='notice'>You stuff a cartridge down the barrel of [M]</span>")
				sleep(10)
				M.current_projectile = new projectile_type()
				amount --
				update_stack_appearance()
				if(amount < 1)
					user.u_equip(src)
					src.dropped(user)
					qdel(src)
				//play the sound here because single shot bypasses cycle_ammo
				if (M.sound_type)
					playsound(M.loc, "sound/weapons/modular/[M.sound_type]-slowcycle.ogg", 60, 1)
				else
					playsound(M.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)
				M.hammer_cocked = TRUE
				//set up counter
				if(M.max_ammo_capacity)
					M.inventory_counter.update_number(M.ammo_list.len + !!M.current_projectile)
				else
					M.inventory_counter.update_number(!!M.current_projectile) // 1 if its loaded, 0 if not.
				reloading = FALSE
			return
		//standard handling
		reloading = TRUE
		if(amount < 1)
			user.u_equip(src)
			src.dropped(user)
			qdel(src)
		SPAWN_DBG(0)
			boutput(user, "<span class='notice'>You start loading rounds into [M].</span>")
			if (M.sound_type)
				playsound(M.loc, "sound/weapons/modular/[M.sound_type]-startload.ogg", 60, 1)
			else
				playsound(M.loc, "sound/weapons/gunload_click.ogg", 60, 1)
				//playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1) //oldsound
			sleep(0)
			while(M.ammo_list.len < M.max_ammo_capacity)
				if(amount < 1)
					user.u_equip(src)
					src.dropped(user)
					qdel(src)
					break
				if (M.sound_type)
					playsound(M.loc, "sound/weapons/modular/[M.sound_type]-load[rand(1,2)].ogg", 10, 1)
				else
					playsound(M.loc, "sound/weapons/gunload_light.ogg", 10, 1, 0, 0.8)
					//playsound(src.loc, "sound/weapons/casings/casing-0[rand(1,9)].ogg", 10, 0.1, 0, 0.8) //oldsound
				amount--
				M.ammo_list += projectile_type
				update_stack_appearance()
				M.inventory_counter.update_number(M.ammo_list.len + !!M.current_projectile)
				//moving this here so you load the first round every time instead of having to load twice to be full up
				if(!M.current_projectile)
					sleep(10)
					M.process_ammo()
				if (M.jammed) //jammed after process_ammo
					boutput(user, "<span class='notice'>Fuck, shit, you fumbled something.</span>")
					break
				else if (prob(M.jam_frequency)) //jammed just because this thing sucks to load or you're clumsy
					M.jammed = 2
					boutput(user, "<span class='notice'>Ah, damn, that doesn't go in that way....</span>")
					break
				sleep(10)
			if (M.sound_type)
				playsound(M.loc, "sound/weapons/modular/[M.sound_type]-stopload.ogg", 30, 1)
			else
				playsound(M.loc, "sound/weapons/gunload_heavy.ogg", 30, 0.1, 0, 0.8)
			if (M.ammo_list.len == M.max_ammo_capacity)
				boutput(user, "<span class='notice'>The hold is now fully loaded.</span>")
			else
				boutput(user, "<span class='notice'>You stop loading.</span>")

			M.inventory_counter.update_number(M.ammo_list.len + !!M.current_projectile)

			reloading = FALSE*/

/* ------------------------------- Pistol Ammo ------------------------------ */
ABSTRACT_TYPE(/obj/item/stackable_ammo/pistol/)
/obj/item/stackable_ammo/pistol/
	name = "abstract pistol round"
	real_name = "abstract pistol round"
	desc = "abstract bullet do not instantiate" //Do you think abstract bullets would be good for killing mimes?
	projectile_type = /datum/projectile/bullet/pistol_weak
	stack_type = /obj/item/stackable_ammo/pistol
	ammo_DRM = GUN_NANO | GUN_ITALIAN | GUN_JUICE
	caliber = 0
	icon_state = "nt_brass"
	icon_full  = "nt_brass"
	icon_empty = "nt_empty"
	icon_one   = "bullet_brass"
	icon_shell = "brass_case"

/obj/item/stackable_ammo/pistol/NT
	name = "\improper NT pistol round"
	real_name = "\improper NT pistol round"
	desc = "NT's standard 8mm Short firearms cartridge. The same caliber everyone else copies."
	projectile_type = /datum/projectile/bullet/pistol_weak
	stack_type = /obj/item/stackable_ammo/pistol/NT
	ammo_DRM = GUN_NANO | GUN_ITALIAN | GUN_JUICE
	icon_state = "nt_brass"
	icon_full  = "nt_brass"
	icon_empty = "nt_empty"
	icon_one   = "bullet_brass"
	icon_shell = "brass_case"
THE_USUAL_FLAVOURS(pistol/NT, "\improper NT pistol round")

/obj/item/stackable_ammo/pistol/HP
	name = "\improper NT HP pistol round"
	real_name = "\improper NT HP pistol round"
	desc = "NT's 8mm Short firearms cartridge, with a hollow point for hunting and pest control. Not permitted for use on crew members."
	projectile_type = /datum/projectile/bullet/pistol_weak
	stack_type = /obj/item/stackable_ammo/pistol/HP
	ammo_DRM = GUN_NANO | GUN_ITALIAN | GUN_JUICE
	icon_state = "nt_brass"
	icon_full  = "nt_brass"
	icon_empty = "nt_empty"
	icon_one   = "bullet_brass"
	icon_shell = "brass_case"
	fiddlyness = 5
THE_USUAL_FLAVOURS(pistol/HP, "\improper NT HP pistol round")

/obj/item/stackable_ammo/pistol/ratshot
	name = "\improper NT ratshot pistol round"
	real_name = "\improper NT ratshot pistol round"
	desc = "NT's 8mm Short firearms cartridge, filled with a tiny amount of shot for pest control. Not permitted for use on crew members."
	projectile_type = /datum/projectile/special/spreader/buckshot_burst/nt/short
	stack_type = /obj/item/stackable_ammo/pistol/ratshot
	ammo_DRM = GUN_NANO | GUN_ITALIAN | GUN_JUICE
	icon_state = "nt_brass"
	icon_full  = "nt_brass"
	icon_empty = "nt_empty"
	icon_one   = "bullet_brass"
	icon_shell = "brass_case"
	fiddlyness = 10
THE_USUAL_FLAVOURS(pistol/ratshot, "\improper NT ratshot pistol round")

//making these paper for now (paper will be used for custom rounds)
/obj/item/stackable_ammo/pistol/italian
	name = "\improper Italian pistol round"
	real_name = "\improper Italian pistol round"
	desc = "Italia's standard .31 pistol firearms cartridge, in paper. The same caliber everyone else copies. These rounds are kept fresh with a light coating of olive oil."
	projectile_type = /datum/projectile/bullet/pistol_medium/AP
	stack_type = /obj/item/stackable_ammo/pistol/italian
	ammo_DRM = GUN_NANO | GUN_ITALIAN | GUN_JUICE
	icon_state = "italian"
	icon_full  = "italian"
	icon_empty = "italian-empty"
	icon_one   = "it_what"
	icon_shell = "red_case" //except it's supposed to be caseless
	fiddlyness = 25
THE_USUAL_FLAVOURS(pistol/italian, "\improper Italian pistol round")

//rename to pistol/italian/ap
/obj/item/stackable_ammo/pistol/italian/AP
	name = "\improper Italian AP pistol round"
	real_name = "\improper Italian AP pistol round"
	desc = "Italia's standard .31 pistol firearms cartridge, with an AP core. The same caliber everyone else copies. Still in paper..."
	projectile_type = /datum/projectile/bullet/pistol_medium/AP
	stack_type = /obj/item/stackable_ammo/pistol/italian/AP
	ammo_DRM = GUN_NANO | GUN_ITALIAN | GUN_JUICE
	icon_state = "italian"
	icon_full  = "italian"
	icon_empty = "italian-empty"
	icon_one   = "it_what"
	icon_shell = "red_case" //except it's supposed to be caseless
	fiddlyness = 30
THE_USUAL_FLAVOURS(pistol/italian/AP, "\improper Italian AP pistol round")

/obj/item/stackable_ammo/pistol/juicer
	name = "\improper Juicer Jr. round"
	real_name = "\improper Juicer Jr. round"
	desc = "Precision-manufactured Juicer pistol rounds in exactly 4x20 millimeter. Except two of them are taped together to fit in a standard barrel."
	projectile_type = /datum/projectile/special/spreader/uniform_burst/juicer_jr //use a special two-bullet/half-damage projectile here, see if this works
	stack_type = /obj/item/stackable_ammo/pistol/juicer
	ammo_DRM = GUN_NANO | GUN_ITALIAN | GUN_JUICE
	icon_state = "juicer_jr"
	icon_full  = "juicer_jr"
	icon_empty = "juicer_jr-empty"
	icon_one   = "bullet_juicer_jr"
	icon_shell = "juicer_jr_case"
	fiddlyness = 50
THE_USUAL_FLAVOURS(pistol/juicer, "\improper Juicer Jr. round")

/obj/item/stackable_ammo/pistol/tranq
	name = "\improper NT Tranq-Will-8-or"
	real_name = "\improper NT Tranq-Will-8-or"
	desc = "Tranquilizer darts inside bullet cases? What the fuck are these even?"
	projectile_type = /datum/projectile/bullet/tranq_dart
	stack_type = /obj/item/stackable_ammo/pistol/tranq
	ammo_DRM = GUN_NANO
	icon_state = "nt_white"
	icon_full  = "nt_white"
	icon_empty = "nt_empty"
	icon_one   = "it_what"
	icon_shell = "white_case"
	fiddlyness = 20
THE_USUAL_FLAVOURS(pistol/tranq, "\improper NT Tranq-Will-8-or")

/obj/item/stackable_ammo/pistol/anti_mutant
	name = "\improper NT Jean-Nerre-De Boulier dart"
	real_name = "\improper NT Jean-Nerre-De Boulier dart"
	desc = "Darts with anti-mutagenic solution, named after the slightly too prominent geneticists who necessitated their invention."
	projectile_type = /datum/projectile/bullet/tranq_dart/anti_mutant
	stack_type = /obj/item/stackable_ammo/pistol/anti_mutant
	ammo_DRM = GUN_NANO
	icon_state = "nt_white"
	icon_full  = "nt_white"
	icon_empty = "nt_empty"
	icon_one   = "it_what"
	icon_shell = "white_case"
	fiddlyness = 15
THE_USUAL_FLAVOURS(pistol/anti_mutant, "\improper NT Jean-Nerre-De Boulier dart")


/*	These also existed as tranq rifle rounds but I don't have a good name for em
	syndicate
		name = "\improper  Tranq-Will-8-or"
		real_name = "\improper NT Tranq-Will-8-or"
		amount_left = 5
		max_amount = 5
		ammo_type = new/datum/projectile/bullet/tranq_dart/syndicate
		ammo_DRM = GUN_SOVIET //since FOSSies don't use bullets, this was the next best thing I could think of

		pistol
			sname = ".31.0a Tranqilizer"
			name = ".31.0a tranquilizer pistol darts"
			amount_left = 15
			max_amount = 15
			caliber = 0.31
			ammo_type = new/datum/projectile/bullet/tranq_dart/syndicate/pistol
*/


/obj/item/stackable_ammo/pistol/capacitive/
	name = "\improper NT In-Capacit-8-or"
	real_name = "\improper NT In-Capacit-8-or"
	desc = "A less-than-lethal solution to declining asset values, in 8mm Short."
	projectile_type = /datum/projectile/energy_bolt
	stack_type = /obj/item/stackable_ammo/pistol/capacitive/
	ammo_DRM = GUN_NANO | GUN_ITALIAN | GUN_JUICE
	icon_state = "nt_stun"
	icon_full  = "nt_stun"
	icon_empty = "nt_stun_empty"
	icon_one   = "bullet_nerf"
	icon_shell = "nerf_case"
THE_USUAL_FLAVOURS(pistol/capacitive, "\improper NT In-Capacit-8-or")

/obj/item/stackable_ammo/pistol/radbow
	name = "\improper Syndicate Radioactive Darts"
	real_name = "Syndicate Radioactive Darts"
	projectile_type = /datum/projectile/rad_bolt
	stack_type = /obj/item/stackable_ammo/pistol/radbow
	desc = "Stealthy projectiles that cause insidious radiation poisoning. Fits in just about anything."
	fiddlyness = 25
THE_USUAL_FLAVOURS(pistol/radbow, "\improper Syndicate Radioactive Darts")

/obj/item/stackable_ammo/pistol/zaubertube/
	name = "\improper Soviet zaubertubes"
	real_name = "\improper Soviet zaubertubes"
	desc = "Thick glass bulb filled with hypergolic incandescent chemicals, in the same 2.8 line caliber stolen by everyone else. Product of Elektrograd."
	projectile_type = /datum/projectile/laser/zauber
	stack_type = /obj/item/stackable_ammo/pistol/zaubertube/
	ammo_DRM = GUN_SOVIET | GUN_FOSS
	icon_state = "soviet-zauber"
	icon_full  = "soviet-zauber"
	icon_empty = "soviet-empty"
	icon_one   = "zauber_tube"
	icon_shell = "zauber_spent"
	fiddlyness = 15
THE_USUAL_FLAVOURS(pistol/zaubertube, "\improper Soviet zaubertubes")

//rifle shit
ABSTRACT_TYPE(/obj/item/stackable_ammo/rifle)
/obj/item/stackable_ammo/rifle
	caliber = CALIBER_L
	//cartridge_length = 40

/obj/item/stackable_ammo/rifle/NT
	name = "\improper NT rifle ammo"
	real_name = "\improper NT rifle ammo"
	desc = "Standard 8mm NT Long rifle cartridges: twice as nice as pistol bullets."
	projectile_type = /datum/projectile/bullet/rifle_weak
	stack_type = /obj/item/stackable_ammo/rifle/NT
	ammo_DRM = GUN_NANO | GUN_SOVIET | GUN_JUICE
	icon_state = "nt_brass"
	icon_full  = "nt_brass"
	icon_empty = "nt_empty"
	icon_one   = "bullet_brass"
	icon_shell = "brass_case"
	fiddlyness = 5

THE_USUAL_FLAVOURS(rifle/NT, "\improper NT rifle ammo")

/obj/item/stackable_ammo/rifle/soviet
	name = "\improper Soviet surplus ammo"
	real_name = "\improper Soviet surplus ammo"
	desc = "Old, obsolete 2.8 line Soviet rifle cartridges. This stuff is covered in 3X years of dust and cosmoline."
	projectile_type = /datum/projectile/bullet/rifle_medium
	stack_type = /obj/item/stackable_ammo/rifle/soviet
	ammo_DRM = GUN_NANO | GUN_SOVIET | GUN_JUICE
	icon_state = "soviet-surplus"
	icon_full  = "soviet-surplus"
	icon_empty = "soviet-empty"
	icon_one   = "bullet_brass"
	icon_shell = "brass_case"
	fiddlyness = 10
THE_USUAL_FLAVOURS(rifle/soviet, "\improper Soviet surplus ammo")

/obj/item/stackable_ammo/rifle/juicer
	name = "\improper Juicer BIG rounds"
	real_name = "\improper Juicer BIG rounds"
	desc = "Juicer-pressed fat fuck rifle rounds, manufactured solely for illegal export."
	projectile_type = /datum/projectile/bullet/rifle_heavy
	stack_type = /obj/item/stackable_ammo/rifle/juicer
	ammo_DRM = GUN_NANO | GUN_SOVIET | GUN_JUICE
	icon_state = "juicer_big"
	icon_full  = "juicer_big"
	icon_empty = "juicer_big-empty"
	icon_one   = "bullet_juicer_big"
	icon_shell = "juicer_big_case"
	fiddlyness = 20
THE_USUAL_FLAVOURS(rifle/juicer, "\improper Juicer BIG rounds")

//make a single shot
/obj/item/stackable_ammo/rifle/capacitive/burst
	name = "\improper NT In-Capacit-8-or MAX"
	real_name = "\improper NT In-Capacit-8-or MAX"
	desc = "A lot of problems? A lot of solutions."
	projectile_type = /datum/projectile/energy_bolt/three
	stack_type = /obj/item/stackable_ammo/rifle/capacitive/burst
	ammo_DRM = GUN_NANO
	icon_state = "nt_stun"
	icon_full  = "nt_stun"
	icon_empty = "nt_stun_empty"
	icon_one   = "bullet_nerf"
	icon_shell = "nerf_case"
	fiddlyness = 10
THE_USUAL_FLAVOURS(rifle/capacitive/burst, "\improper NT In-Capacit-8-or MAX")


//smoothbore shit
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
	caliber = CALIBER_W

	/*reload(var/obj/item/gun/modular/M, mob/user as mob)
		if(!M.scatter)
			boutput(user, "<span class='notice'>That shell won't fit the breech.</span>")
			return
		..()*/

//NT's small shotgun shell
/obj/item/stackable_ammo/scatter/NT
	name = "\improper NT Shot"
	real_name = "\improper NT Shot"
	desc = "NT 16mm shotgun shell with medium shot, for heavy barrels."
	projectile_type = /datum/projectile/special/spreader/buckshot_burst
	stack_type = /obj/item/stackable_ammo/scatter/NT
	icon_state = "nt_shells"
	icon_full  = "nt_shells"
	icon_empty = "nt_shells-empty"
	fiddlyness = 10
THE_USUAL_FLAVOURS(scatter/NT, "\improper NT Shot")

//NT's EXTRA skinny shotgun shell, which works in regular light barrels! wow!
/obj/item/stackable_ammo/scatter/NT/mini
	name = "\improper NT Mini Shot"
	real_name = "\improper NT Mini Shot"
	desc = "NT 8mm microshotgun shell, loaded for maintenance vermin. For light barrels."
	projectile_type = /datum/projectile/bullet/shot_weak/mini
	stack_type = /obj/item/stackable_ammo/scatter/NT/mini
	icon_one   = "shell_mini_blue"
	icon_shell = "shell_mini_case"
	fiddlyness = 15
THE_USUAL_FLAVOURS(scatter/NT/mini, "\improper NT Mini Shot")

//thinking FOSS might make some stupid shotgun shells. for later

//juicer BIG shells
/obj/item/stackable_ammo/scatter/juicer
	name = "\improper Juicer Hot Pocketz"
	real_name = "\improper Juicer Hot Pocketz"
	desc = "Ecologically and economically hand-packed by local Juicer children. In, uh, whatever caliber. It'll probably fit heavy barrels, but won't fit in pistol receivers."
	projectile_type = /datum/projectile/special/spreader/buckshot_burst/juicer
	stack_type = /obj/item/stackable_ammo/scatter/juicer
	icon_state = "juicer_shells_red"
	icon_full  = "juicer_shells_red"
	icon_empty = "juicer_shells_red-empty"
	icon_one   = "shell_red"
	icon_shell = "shell_red_case"
	//cartridge_length = 40 //for big receivers only
	fiddlyness = 30
THE_USUAL_FLAVOURS(scatter/juicer, "\improper Juicer Hot Pocketz")

/obj/item/stackable_ammo/scatter/juicer/denim
	name = "\improper Juicer JAMMO"
	real_name = "\improper Juicer JAMMO"
	desc = "Denim-wrapped shotgun cartridges. Increases chamber pressure, somehow, but the fabric is very prone to getting stuck. For jeavy jarrels and long receivers."
	projectile_type = /datum/projectile/special/spreader/buckshot_burst/juicer/denim
	stack_type = /obj/item/stackable_ammo/scatter/juicer/denim
	icon_state = "juicer_shells_blue"
	icon_full  = "juicer_shells_blue"
	icon_empty = "juicer_shells_blue-empty"
	icon_one   = "shell_blue"
	icon_shell = "shell_case"
	fiddlyness = 50
THE_USUAL_FLAVOURS(scatter/juicer/denim, "\improper Juicer JAMMO")

/obj/item/stackable_ammo/scatter/bartender
	name = "\improper Bartender's Buddy"
	real_name = "\improper Bartender's Buddy"
	desc = "Unlicensed and handmade short 16mm shotgun shell, full of rock salt. And probably some kind of acid. Fuck Bart."
	projectile_type = /datum/projectile/bullet/shot_salt
	stack_type = /obj/item/stackable_ammo/scatter/bartender
	icon_state = "shells"
	icon_full  = "shells"
	icon_empty = "empty"
	icon_one   = "shell_blue"
	icon_shell = "shell_case"
	fiddlyness = 10
THE_USUAL_FLAVOURS(scatter/bartender, "\improper Bartender's Buddy")

/obj/item/stackable_ammo/scatter/slug_rubber // scatter doesnt mean scatter, just means thick:)
	name = "\improper NT rubber slug"
	real_name = "\improper NT rubber slug"
	desc = "An allegedly less-than-lethal riot deterrent slug, at least in low doses."
	projectile_type = /datum/projectile/bullet/slug_rubber
	stack_type = /obj/item/stackable_ammo/scatter/slug_rubber
	fiddlyness = 10
THE_USUAL_FLAVOURS(scatter/slug_rubber, "\improper NT rubber slug")

//silly idea, I figure would be crafted ammo and not bought (though for the moment they are bought I haven't decided on a crafting method)
/obj/item/stackable_ammo/coil
	name = "coil slug round"
	real_name = "coil slug round"
	desc = "A metal coil packed into a bullet cartridge. This seems both stupid and cruel."
	projectile_type = /datum/projectile/bullet/coil
	stack_type = /obj/item/stackable_ammo/coil
	fiddlyness = 5
THE_USUAL_FLAVOURS(coil, "coil slug round")

/obj/item/stackable_ammo/flashbulb/
	name = "\improper FOSSYN. Cathodic Flash Tube 1.4"
	real_name = "\improper FOSSYN. Cathodic Flash Tube 1.4"
	desc = "A modest glass tube filled with ionic gas, and two opposing electrodes."
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


	/*
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
		reloading = TRUE
		SPAWN_DBG(0)
			boutput(user, "<span class='notice'>You start loading a flashtube into [M].</span>")
			if(M.ammo_list.len < M.max_ammo_capacity)
				sleep(10)
				playsound(src.loc, "sound/weapons/casings/casing-0[rand(1,9)].ogg", 10, 0.1, 0, 0.8)
				M.ammo_list += src
				user.u_equip(src)
				src.dropped(user)
				src.set_loc(M)
				sleep(10)
				playsound(src.loc, "sound/items/Screwdriver.ogg", 30, 0.1, 0, 0.8)
				if(!M.flashbulb_health)
					M.flash_process_ammo(user)
				boutput(user, "<span class='notice'>You finish loading a flashtube into [M].</span>")
				reloading = FALSE
				*/

/obj/item/stackable_ammo/flashbulb/better
	name = "\improper FOSSYN. Cathodic Flash Tube 2.0b"
	real_name = "\improper FOSSYN. Cathodic Flash Tube 2.0b"
	desc = "A hefty glass tube filled with ionic gas, and two opposing electrodes."
	max_health = 25
	min_health = 20
	icon_state = "bulb_good"
	fiddlyness = 15

/obj/item/storage/box/foss_flashbulbs
	name = "box of FOSSYN flashtubes"
	icon_state = "foss_bulb"
	spawn_contents = list(/obj/item/stackable_ammo/flashbulb, /obj/item/stackable_ammo/flashbulb, /obj/item/stackable_ammo/flashbulb, /obj/item/stackable_ammo/flashbulb, /obj/item/stackable_ammo/flashbulb, /obj/item/stackable_ammo/flashbulb)

/obj/item/storage/box/foss_flashbulbs/better
	name = "box of premium FOSSYN flashtubes"
	spawn_contents = list(/obj/item/stackable_ammo/flashbulb/better, /obj/item/stackable_ammo/flashbulb/better, /obj/item/stackable_ammo/flashbulb/better, /obj/item/stackable_ammo/flashbulb, /obj/item/stackable_ammo/flashbulb, /obj/item/stackable_ammo/flashbulb)
	make_my_stuff()
		..()
		if (prob(70))
			new /obj/item/gun_parts/accessory/horn(src)

/obj/item/storage/box/foss_gun_kit
	name = "Syndicate Gun Kit"
	icon_state = "foss_gun"
	spawn_contents = list(/obj/item/gun/modular/foss/standard, /obj/item/stackable_ammo/flashbulb/better, /obj/item/stackable_ammo/flashbulb/better, /obj/item/stackable_ammo/flashbulb, /obj/item/stackable_ammo/flashbulb)
	make_my_stuff()
		..()
		if (prob(50))
			new /obj/item/gun_parts/stock/foss/loader(src)
		else
			new /obj/item/gun_parts/barrel/foss/long(src)

// NEW PROJECTILE TYPES TEMPORARY STORAGE


/datum/projectile/energy_bolt/three
	power = 20
	shot_number = 3

/datum/projectile/energy_bolt/five
	power = 15
	shot_number = 5

/datum/projectile/laser/three
	power = 15
	shot_number = 3


/datum/projectile/laser/flashbulb
	name = "open-source laser"
	icon_state = "laser1"
	power = 25
	cost = 50
	dissipation_delay = 5
	brightness = 0
	sname = "open-source laser"
	shot_sound = 'sound/weapons/Laser.ogg'
	//red
	color_red = 1
	color_green = 0.20
	color_blue = 0
	projectile_speed = 75


/datum/projectile/laser/flashbulb/two
	icon_state = "laser2"
	power = 40
	shot_pitch = 0.95
	//orange
	color_red = 0.9
	color_green = 0.69
	color_blue = 0
	cost = 75
	projectile_speed = 70

/datum/projectile/laser/flashbulb/three
	icon_state = "laser3"
	power = 50
	shot_pitch = 0.90
	//yellow
	color_red = 0.9
	color_green = 0.9
	color_blue = 0
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
	icon_state = "laser4"
	power = 60
	shot_pitch = 0.85
	//cyan
	color_red = 0
	color_green = 0.8
	color_blue = 0.95
	cost = 200
	projectile_speed = 60

	on_hit(atom/hit)
		fireflash(get_turf(hit), 0)
		if (isliving(hit))
			var/mob/living/L = hit
			L.changeStatus("slowed", 1 SECOND)
			L.change_misstep_chance(1)
			L.emote("twitch_v")
		if(prob(15))
			hit.ex_act(OLD_EX_LIGHT)
		return

/datum/projectile/laser/flashbulb/five //bringing it back
	icon_state = "laser5"
	power = 75
	shot_pitch = 0.75
	//near-ultraviolet
	color_red = 0.25
	color_blue = 1
	color_green = 0
	cost = 400
	projectile_speed = 50

	on_hit(atom/hit)
		fireflash(get_turf(hit), 0)
		if (isliving(hit))
			var/mob/living/L = hit
			L.changeStatus("slowed", 3 SECOND)
			L.change_misstep_chance(3)
			L.emote("twitch_v")
		if(prob(30))
			hit.ex_act(OLD_EX_LIGHT)
		return

#undef default_max_amount
#undef default_min_amount
#undef THE_USUAL_FLAVOURS
