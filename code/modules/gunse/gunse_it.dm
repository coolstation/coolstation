

//Italian Gunse
//Lower damage, higher fire rate
//Cylinder "magazine"
ABSTRACT_TYPE(/obj/item/gun/modular/italian)
/obj/item/gun/modular/italian
	name = "abstract Italian gun"
	real_name = "abstract Italian gun"
	desc = "abstract type do not instantiate"
	icon = 'icons/obj/items/modular_guns/receivers.dmi'
	gun_DRM = GUN_ITALIAN
	jam_frequency = 0
	var/cylinder_index = 1
	var/chambered_index = 1
	var/dirty_ammo = TRUE
	var/stored_ammo_count = 0 // only count our ammo when actually needed, otherwise use tricks to avoid checking the entire cylinder a ton

	shoot(target, start, mob/user, POX, POY, is_dual_wield, mob/point_blank_target)
		. = ..()
		if(.) // we remove the current projectile here, not in set_current_projectile, because we want to be able to cycle back around
			qdel(src.current_projectile)
			src.ammo_list[src.chambered_index] = null
			src.stored_ammo_count--
			src.chambered_index = 0
			src.inventory_counter.update_number(src.ammo_reserve())

	build_gun()
		..()
		if(length(src.ammo_list) < src.max_ammo_capacity)
			src.ammo_list.len = src.max_ammo_capacity
		src.dirty_ammo = TRUE

	reset_gun()
		..()
		src.cylinder_index = 1
		src.dirty_ammo = TRUE

	MouseDrop_T(obj/O as obj, mob/user as mob)
		if(src.built && O == src && GET_DIST(src, user) <= 1)
			playsound(src.loc, "sound/weapons/cylinderspin.ogg", 50)
			user.visible_message("<span class='notice'>[user] spins the cylinder.</span>", "<span class='notice'>You spin the cylinder[length(src.casing_list) ? " and toss the casings": ""].</span>")
			src.eject_casings()
			src.cylinder_index = rand(1, src.max_ammo_capacity)
		else
			return ..()

	chamber_round(mob/user)
		. = FALSE

		playsound(src.loc,"sound/weapons/cylinderclick[rand(1,2)].ogg", vol = 35, vary = TRUE, extrarange = -28)
		var/ammotype = ammo_list[src.cylinder_index]

		if(!isnull(ammotype))
			if(istype(ammotype, /datum/projectile)) // might have already been chambered then cycled away
				src.set_current_projectile(ammotype) // so just rechamber it
			else // or its brand new
				src.set_current_projectile(new ammotype()) // this one gets instantiated
				src.ammo_list[src.cylinder_index] = src.current_projectile // it remains in the cylinder until fired, tho

			src.chambered_index = src.cylinder_index
			. = TRUE
			playsound(src.loc, "sound/weapons/gunload_click.ogg", vol = 25, extrarange = -28)

		src.cylinder_index++
		if(src.cylinder_index > src.max_ammo_capacity)
			src.cylinder_index = 1
		return

	set_current_projectile(datum/projectile/newProj) // we dont want to delete the fired bullet for this one, so it doesnt call parent
		src.current_projectile = newProj
		SEND_SIGNAL(src, COMSIG_GUN_PROJECTILE_CHANGED, newProj)

	ammo_reserve()
		if(src.dirty_ammo)
			src.dirty_ammo = FALSE
			src.stored_ammo_count = 0
			for(var/i in 1 to length(src.ammo_list))
				if(i != src.chambered_index && !isnull(src.ammo_list[i]))
					src.stored_ammo_count++
		return src.stored_ammo_count

	load_ammo(mob/user, obj/item/stackable_ammo/donor_ammo)
		if(length(src.casing_list))
			boutput(user, "<span class='notice'>First, you clear the casings from [src].</span>")
			src.eject_casings()

		if (src.ammo_reserve() < src.max_ammo_capacity)
			if (src.sound_type)
				playsound(src.loc, "sound/weapons/modular/[src.sound_type]-load[rand(1,2)].ogg", 10, 1)
			else
				playsound(src.loc, "sound/weapons/gunload_light.ogg", 10, 1, 0, 0.8)

			//load the previous cylinder and spin to it (much computationally cheaper than going forward if you load a lot of bullets)
			var/potential_slot = src.cylinder_index
			for(var/i in 1 to length(src.ammo_list))
				potential_slot--
				if(!potential_slot)
					potential_slot = length(src.ammo_list)
				if(isnull(src.ammo_list[potential_slot]))
					src.ammo_list[potential_slot] = donor_ammo.projectile_type
					src.stored_ammo_count++
					src.cylinder_index = potential_slot
					break

		src.buildTooltipContent()

		//This can stay for now
		if (prob(src.jam_frequency)) //jammed just because this thing sucks to load or you're clumsy
			src.jammed = JAM_LOAD
			boutput(user, "<span class='notice'>Ah, damn, that doesn't go in that way....</span>")
			return FALSE
		return TRUE

//THE REVOLVER
//Extremely stylish revolver with an almost double action and a fannable hammer to boot.
ABSTRACT_TYPE(/obj/item/gun/modular/italian/revolver)
/obj/item/gun/modular/italian/revolver
	name = "abstract Italian revolver"
	real_name = "abstract Italian revolver"
	icon_state = "italian_revolver"
	spread_angle = 6
	barrel_overlay_x = 5
	grip_overlay_x = -4
	grip_overlay_y = -4
	stock_overlay_x = -5
	stock_overlay_y = -2
	load_time = 1 SECOND
	max_ammo_capacity = 6
	bulkiness = 1

	shoot_delay = 0.1 SECONDS // this is a lie. its actually 0.6ish seconds if youre good
	reload_cooldown = 0.2 SECONDS

	var/hammer_cocked = FALSE
	var/currently_firing = FALSE

	//MAYBE: handle unloading all rounds (shot or unshot) at same time, don't load until unloaded?
	//much too consider

	shoot(var/turf/target,var/turf/start,var/mob/user,var/POX,var/POY,var/is_dual_wield,var/atom/point_blank_target)
		if(!src.currently_firing && !src.jammed)
			src.currently_firing = TRUE
			var/offset_x = target.x - start.x
			var/offset_y = target.y - start.y
			var/point_blank_first = point_blank_target
			SPAWN_DBG(0)
				if(!src.current_projectile)
					src.chamber_round()
					sleep(0.1 SECONDS)
				if(!src.hammer_cocked)
					playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 50, 1)
					sleep(0.2 SECONDS)
					src.hammer_cocked = TRUE
				if (src.current_projectile)
					while(src.hammer_cocked && src.current_projectile && user.equipped() == src && !src.jammed)
						src.hammer_cocked = FALSE
						var/turf/T_start = get_turf(user)
						var/turf/T_target = locate(T_start.x + offset_x, T_start.y + offset_y, T_start.z)
						if(T_start && T_target)
							..(T_target, T_start, user, POX, POY, is_dual_wield, point_blank_first) // the voices told me its okay to do this
							point_blank_first = null
						else
							break // if you aim off a world border this can happen
						sleep(0.4 SECONDS)
						if(src.hammer_cocked)
							src.chamber_round(user)
					if(src.hammer_cocked)
						playsound(src.loc, "sound/weapons/dryfire.ogg", 35, 1)
				else
					playsound(src.loc, "sound/weapons/dryfire.ogg", 35, 1)
				src.hammer_cocked = FALSE
				sleep(0.3 SECONDS)
				src.currently_firing = FALSE
			return TRUE

	attack_self(mob/user)
		if(src.currently_firing && (src.jammed || src.hammer_cocked))
			return
		if(!src.jammed && !src.hammer_cocked) // fan the damn hammer
			playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)
			boutput(user,"<span><b>You [src.currently_firing ? "fan" : "cock"] the hammer.</b></span>", group = "revolvercock_\ref[src]")
			src.hammer_cocked = TRUE
			return
		return ..()

	alter_projectile(obj/projectile/P, mob/user)
		P.power = P.power * (0.7 + 0.2 * src.two_handed)
		..()

	displayed_power()
		if(src.current_projectile)
			return "[floor(BARREL_SCALING(src.barrel?.length) * (src.current_projectile.power * (0.6 + 0.2 * src.two_handed)))] dmg - [current_projectile.ks_ratio * 100]% lethal"
		return "[round(BARREL_SCALING(src.barrel?.length) * 100 * (0.6 + 0.2 * src.two_handed), 0.5)]% power"

	load_ammo(mob/user, obj/item/stackable_ammo/donor_ammo)
		if(src.hammer_cocked)
			playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 20, 1)
			boutput(user,"<span><b>You lower the hammer.</b></span>")
			src.hammer_cocked = FALSE
		return ..()

	on_spin_emote(mob/living/carbon/human/user)
		if(length(src.casing_list))
			src.eject_casings()
		. = ..()

//THE RATTLER
//Massive drum-like cylinder that increases in damage and decreases in accuracy as it is fired,
//but has a solid chance to fail to chamber each round- so keep spinning the cylinder for diminishing returns!
ABSTRACT_TYPE(/obj/item/gun/modular/italian/rattler)
/obj/item/gun/modular/italian/rattler
	name = "abstract Italian rattler"
	real_name = "abstract Italian rattler"
	icon_state = "italian_rattler"
	spread_angle = 4
	barrel_overlay_x = 6
	grip_overlay_x = -7
	grip_overlay_y = -4
	stock_overlay_x = -8
	stock_overlay_y = -2
	load_time = 0.3 SECONDS // reloads exceptionally fast as long as you use ammo with low load_time
	max_ammo_capacity = 15
	bulkiness = 3
	var/successful_chamber_frequency = 27
	var/failed_chamber_fudge = 3 // each failed chamber boosts successful_chamber_frequency by this much until the gun is reloaded or chambers
	var/max_fudged_chance = 90 // maxes at this chance after enough fudges
	var/failures_to_chamber = 0

	shoot_delay = 0.2 SECONDS

	recoil_strength = 4
	recoil_inaccuracy_max = 12
	recoil_stacking_enabled = TRUE
	recoil_stacking_amount = 2
	recoil_stacking_safe_stacks = 1
	recoil_stacking_max_stacks = 10
	recoil_reset_mult = 0.9

	shoot(target, start, mob/user, POX, POY, is_dual_wield, point_blank_target)
		if(src.jammed)
			return // TODO - feedback
		if(src.current_projectile)
			..()
		src.chamber_round(user)
		if(src.current_projectile) // yes, empty cylinders count as failures
			src.failures_to_chamber = 0
		else
			src.failures_to_chamber++

	chamber_round(mob/user)
		if(prob(min(src.max_fudged_chance, src.successful_chamber_frequency + src.failed_chamber_fudge * src.failures_to_chamber)))
			return ..()

		playsound(src.loc,"sound/weapons/cylinderclick[rand(1,2)].ogg", vol = min(50, 20 + src.failed_chamber_fudge * 3), vary = TRUE, extrarange = -28)
		src.cylinder_index++
		if(src.cylinder_index > src.max_ammo_capacity)
			src.cylinder_index = 1
		return FALSE

	build_gun()
		..()
		src.AddComponent(/datum/component/holdertargeting/fullauto, src.shoot_delay, src.shoot_delay, 1)

	reset_gun()
		..()
		var/C = src.GetComponent(/datum/component/holdertargeting/fullauto)
		src.failures_to_chamber = 0
		qdel(C)

	alter_projectile(obj/projectile/P, mob/user)
		P.power = P.power * (0.35 + 0.2 * src.two_handed + 0.25 * src.recoil / src.recoil_max)
		..()

	displayed_power()
		var/lower_scale = BARREL_SCALING(src.barrel?.length) * (0.35 + 0.2 * src.two_handed)
		var/upper_scale = BARREL_SCALING(src.barrel?.length) * (0.35 + 0.2 * src.two_handed + 0.25)
		if(src.current_projectile)
			return "[floor(lower_scale * src.current_projectile.power)] to [floor(upper_scale * src.current_projectile.power)] dmg - [current_projectile.ks_ratio * 100]% lethal"
		return "[round(100 * lower_scale, 0.5)]% to [round(100 * upper_scale, 0.5)]% power"

	load_ammo(mob/user, obj/item/stackable_ammo/donor_ammo)
		src.failures_to_chamber = 0
		. = ..()

//THE SNIPER
//Slow double action only "revolver" (has to be for copyright reasons, I reckon), holding a minimal number of rounds. Comes with a fancy scope.
//Cuts the dissipation rate of ammo, in exchange for extreme bulk and slow fire rate. Minimal spread, but has high recoil-based spread.
ABSTRACT_TYPE(/obj/item/gun/modular/italian/sniper)
/obj/item/gun/modular/italian/sniper
	name = "abstract Italian sniper"
	real_name = "abstract Italian sniper"
	icon_state = "italian_sniper"
	spread_angle = 1
	jam_frequency = 1
	barrel_overlay_x = 6
	barrel_overlay_y = -1
	grip_overlay_x = -6
	grip_overlay_y = -3
	stock_overlay_x = -7
	stock_overlay_y = -1
	max_ammo_capacity = 2
	bulkiness = 4

	load_time = 1.3 SECONDS

	recoil_strength = 25
	recoil_reset_mult = 0.975
	recoil_inaccuracy_max = 20

	shoot_delay = 1.2 SECONDS

	var/currently_firing = FALSE
	var/scope_speed = 12
	var/scope_range = 640
	var/dissipation_divisor = 1.75

	// ultra heavy Double Action Only revolver
	shoot(var/turf/target,var/turf/start,var/mob/user,var/POX,var/POY,var/is_dual_wield,var/mob/point_blank_target)
		if(!src.currently_firing && !src.jammed)
			src.currently_firing = TRUE
			var/offset_x = target.x - start.x
			var/offset_y = target.y - start.y
			SPAWN_DBG(0)
				if(!src.current_projectile)
					chamber_round()
					sleep(0.3 SECONDS)
				if (src.current_projectile)
					playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)
					sleep(0.2 SECONDS)
					if(src.current_projectile && src.loc == user && !src.jammed)
						var/turf/T_start = get_turf(user)
						var/turf/T_target = locate(T_start.x + offset_x, T_start.y + offset_y, T_start.z)
						if(T_start && T_target)
							..(T_target, T_start, user, POX, POY, is_dual_wield, point_blank_target)
					else
						playsound(src.loc, "sound/weapons/dryfire.ogg", 50, 1)
					sleep(0.2 SECONDS)
				else
					playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)
					sleep(0.2 SECONDS)
					playsound(src.loc, "sound/weapons/dryfire.ogg", 50, 1)
				sleep(0.3 SECONDS)
				src.currently_firing = FALSE

	build_gun()
		..()
		src.AddComponent(/datum/component/holdertargeting/sniper_scope, src.scope_speed, src.scope_range, /datum/overlayComposition/sniper_scope_italian, "sound/weapons/scope.ogg")

	reset_gun()
		..()
		var/C = src.GetComponent(/datum/component/holdertargeting/sniper_scope)
		qdel(C)

	alter_projectile(obj/projectile/P, mob/user)
		P.proj_data.dissipation_rate = P.proj_data.dissipation_rate / (src.dissipation_divisor + !!src.stock)
		// INTENTIONALLY LEFT OUT - this was too strong
		//P.proj_data.dissipation_delay = P.proj_data.dissipation_delay * (src.dissipation_divisor + !!src.stock)
		..()

	displayed_power()
		if(src.current_projectile)
			return "[floor(src.current_projectile.power * BARREL_SCALING(src.barrel?.length))] - [floor(src.current_projectile.ks_ratio * 100)]% lethal - x[2 + !!src.stock] range"
		return "[round(100 * BARREL_SCALING(src.barrel?.length), 0.5)]% power - x[src.dissipation_divisor + !!src.stock] range"

// REVOLVERS

//Pretty bad
/obj/item/gun/modular/italian/revolver/basic
	name = "basic Italian revolver"
	real_name = "\improper Italianetto"
	desc = "Una pistola realizzata in acciaio mediocre."
	max_ammo_capacity = 5

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/italian/short(src)
		grip = new /obj/item/gun_parts/grip/italian(src)

//Standard factory issue
/obj/item/gun/modular/italian/revolver/improved
	name = "improved Italian revolver"
	real_name = "\improper Italiano"
	desc = "Una pistola realizzata in acciaio di qualità e pelle."
	max_ammo_capacity = 6

	make_parts()
		if (prob(50))
			barrel = new /obj/item/gun_parts/barrel/italian(src)
		else
			barrel = new /obj/item/gun_parts/barrel/italian/spicy(src)
		if (prob(50))
			grip = new /obj/item/gun_parts/grip/juicer(src)
		else if (prob(50))
			grip = new /obj/item/gun_parts/grip/juicer/black(src)
		else
			grip = new /obj/item/gun_parts/grip/italian/cowboy(src)

//mama mia
/obj/item/gun/modular/italian/revolver/masterwork
	name = "masterwork Italian revolver"
	real_name = "\improper Italianone"
	desc = "Una pistola realizzata con acciaio, cuoio e olio d'oliva della più alta qualità possibile."
	max_ammo_capacity = 7

	make_parts()

		if (prob(75))
			stock = new /obj/item/gun_parts/stock/italian(src)
			barrel = new /obj/item/gun_parts/barrel/italian/buntline(src)
		else
			grip = new /obj/item/gun_parts/grip/italian/bigger(src)
			barrel = new /obj/item/gun_parts/barrel/italian/accurate(src)

//da jokah babiyyyy
/obj/item/gun/modular/italian/revolver/silly
	name = "jokerfied Italian revolver"
	real_name = "\improper Grande Italiano"
	max_ammo_capacity = 7
	desc = "Io sono il pagliaccio, bambino!"

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/italian/joker(src)
		grip = new /obj/item/gun_parts/grip/italian/cowboy/bandit(src)


// RATTLERS

//basic, occasionally one handed
/obj/item/gun/modular/italian/rattler/basic
	name = "basic Italian rattler"
	real_name = "\improper Bacino"
	desc = "Tecnicamente è un revolver, con un tamburo enorme e un meccanismo di cameratura inaffidabile."
	bulkiness = 3

	load_time = 0.4 SECONDS
	successful_chamber_frequency = 40
	failed_chamber_fudge = 3

	make_parts()
		if(prob(60))
			stock = new /obj/item/gun_parts/stock/italian/wire(src)
		else if(prob(50))
			stock = new /obj/item/gun_parts/stock/italian(src)
		else
			grip = new /obj/item/gun_parts/grip/italian/cowboy/bandit(src)

		if(prob(40))
			barrel = new /obj/item/gun_parts/barrel/italian/tommy(src)
		else
			barrel = new /obj/item/gun_parts/barrel/italian/buntline(src)

//better and approved for rattling
/obj/item/gun/modular/italian/rattler/improved
	name = "improved Italian rattler"
	real_name = "\improper Costola"
	desc = "Un modello recente di revolver con un massiccio tamburo lucidato."

	load_time = 0.3 SECONDS
	successful_chamber_frequency = 30

	make_parts()
		if(prob(70))
			stock = new /obj/item/gun_parts/stock/italian(src)
		else
			stock = new /obj/item/gun_parts/stock/italian/wire(src)

		if (prob(5)) // it happens to a lot of gunse
			barrel = new /obj/item/gun_parts/barrel/italian/snub(src)
		else if(prob(40))
			barrel = new /obj/item/gun_parts/barrel/italian/tommy(src)
		else
			barrel = new /obj/item/gun_parts/barrel/italian/buntline(src)

//oh thats a spooky meatball
/obj/item/gun/modular/italian/rattler/masterwork
	name = "masterwork Italian rattler"
	real_name = "\improper Cranio"
	desc = "Un revolver all'avanguardia con un cilindro massiccio ben unto con olio d'oliva."

	load_time = 0.25 SECONDS
	successful_chamber_frequency = 30
	failed_chamber_fudge = 3.5

	make_parts()
		stock = new /obj/item/gun_parts/stock/italian(src)
		barrel = new /obj/item/gun_parts/barrel/italian/tommy(src)

//gluttonous beast
/obj/item/gun/modular/italian/rattler/saucy
	name = "saucy Italian rattler"
	real_name = "\improper Sterno"
	desc = "Questa pistola, un prototipo di revolver che divora munizioni, puzza di pomodoro."

	shoot_delay = 0.15 SECONDS

	max_ammo_capacity = 26
	load_time = 0.2 SECONDS
	successful_chamber_frequency = 15
	max_fudged_chance = 75

	make_parts()
		if(prob(60))
			grip = new /obj/item/gun_parts/grip/italian/bigger(src)
		else if(prob(80))
			grip = new /obj/item/gun_parts/grip/italian(src)
		else
			grip = new /obj/item/gun_parts/grip/italian/meatball(src)

		if(prob(50))
			barrel = new /obj/item/gun_parts/barrel/italian/tommy(src)
		else
			barrel = new /obj/item/gun_parts/barrel/italian/spicy(src)

// SNIPERS
// basic but always has a stock by default
/obj/item/gun/modular/italian/sniper/basic
	name = "basic Italian sniper"
	real_name = "\improper Zuffa"
	desc = "Un fucile a doppia azione a lungo raggio, dotato di un buon mirino ottico."

	scope_range = 480
	scope_speed = 10

	make_parts()
		stock = new /obj/item/gun_parts/stock/italian/wire(src)
		if(prob(30))
			if(prob(50))
				grip = new /obj/item/gun_parts/grip/italian(src)
			else if(prob(70))
				grip = new /obj/item/gun_parts/grip/italian/cowboy/bandit(src)
			else
				grip = new /obj/item/gun_parts/grip/italian/bigger(src)
		if(prob(60))
			barrel = new /obj/item/gun_parts/barrel/italian/spicy(src)
		else
			barrel = new /obj/item/gun_parts/barrel/italian/buntline(src)

// better and less likely to be rockin out w/ the wire stock out
/obj/item/gun/modular/italian/sniper/improved
	name = "improved Italian sniper"
	real_name = "\improper Rissa"
	desc = "Un fucile a doppia azione a lungo raggio, dotato di un buon mirino ottico e unto con vino rosso."

	scope_range = 640
	scope_speed = 12
	dissipation_divisor = 2

	make_parts()
		if(prob(30))
			stock = new /obj/item/gun_parts/stock/italian/wire(src)
		else
			stock = new /obj/item/gun_parts/stock/italian(src)
		if(prob(50))
			if(prob(50))
				grip = new /obj/item/gun_parts/grip/italian(src)
			else if(prob(70))
				grip = new /obj/item/gun_parts/grip/italian/cowboy/bandit(src)
			else
				grip = new /obj/item/gun_parts/grip/italian/bigger(src)
		if(prob(40))
			barrel = new /obj/item/gun_parts/barrel/italian/silenced(src)
		else if(prob(60))
			barrel = new /obj/item/gun_parts/barrel/italian/tommy(src)
		else
			barrel = new /obj/item/gun_parts/barrel/italian/spicy(src)

//named after Letizia Battaglia, and then the lesser snipers were named for near-synonyms of her surname
/obj/item/gun/modular/italian/sniper/masterwork
	name = "masterwork Italian sniper"
	real_name = "\improper Battaglia"
	desc = "Un sofisticato fucile a doppia azione a lungo raggio, dotato di un cannocchiale adatto a sparare alla mafia."

	scope_range = 800
	scope_speed = 16
	dissipation_divisor = 2.25

	make_parts()
		stock = new /obj/item/gun_parts/stock/italian(src)
		if(prob(50))
			grip = new /obj/item/gun_parts/grip/italian(src)
		else if (prob(40))
			grip = new /obj/item/gun_parts/grip/italian/cowboy/pearl(src)
		barrel = new /obj/item/gun_parts/barrel/italian/silenced(src)
