

//Italian Revolver
//Extremely Stylish
//Heavy Ammo
//Cylinder "Magazine"
ABSTRACT_TYPE(/obj/item/gun/modular/italian)
/obj/item/gun/modular/italian
	name = "abstract Italian gun"
	real_name = "abstract Italian gun"
	desc = "abstract type do not instantiate"
	icon = 'icons/obj/items/modular_guns/receivers.dmi'
	icon_state = "italian_short" //only
	//basic revolving mechanism
	action = "double"
	//this will be a "magazine" but like tubes we'll have a slightly different firing method
	gun_DRM = GUN_ITALIAN
	spread_angle = 10
	//color = "#FFFF99"
	barrel_overlay_x = 5
	grip_overlay_x = -4
	grip_overlay_y = -4
	stock_overlay_x = -5
	stock_overlay_y = -2
	jam_frequency = 5
	jam_frequency = 0
	var/currently_firing = FALSE //this double action pull is slow
	fiddlyness = 25

	//ideally we have two lists
	//one for projectiles
	//one for projectile status
	//index goes 1, advances one until max, then resets to 1
	//shot is ready to fire if 1, fired sets shot to 0, jammed (misfire) set to 2
	//load and fire in that order, every time
	//spin cylinder by clickdragging onto itself if not cocked
	//decock on load?

	shoot(var/target,var/start,var/mob/user,var/POX,var/POY,var/is_dual_wield)
		//If we're doing a double action thing here where it automatically resets and is ready to fire the next shot?
		//Maybe a short sleep, that's the tradeoff for not having to click it every time... I'm not putting it in until I sort out more
		//ALSO: handle unloading all rounds (shot or unshot) at same time, don't load until unloaded?
		//much too consider
		if (src.current_projectile)
			if (hammer_cocked) //single action // not sure if && !currently_firing would feel good
				..() //fire
			else if (!currently_firing)
				currently_firing = TRUE
				sleep(10) //heavy double action
				hammer_cocked = TRUE
				playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)
				..()
				currently_firing = FALSE
		else
			sleep(10) //heavy double action
			//check if still held by same person
			process_ammo()
			..()

	//fuuuuck
	//HOWEVER this will be integral to fanning the hammer, as long as you attackself within like, a few secs of firing, you'll chain fire approximately where you were
	attack_self(mob/user)
		if(!src.processing_ammo && !src.currently_firing)
			process_ammo(user)
		if(src.max_ammo_capacity)
			// this is how many shots are left in the feeder- plus the one in the chamber. it was a little too confusing to not include it
			src.inventory_counter.update_number(ammo_list.len + !!current_projectile)
		else
			src.inventory_counter.update_number(!!current_projectile) // 1 if its loaded, 0 if not.
		if(!hammer_cocked && !src.currently_firing) //for italian revolver purposes, doesn't process_ammo like normal
			playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)
			boutput(user,"<span><b>You cock the hammer.</b></span>")
			hammer_cocked = 1
		buildTooltipContent()

/obj/item/gun/modular/italian/basic
	name = "basic Italian revolver"
	real_name = "\improper Italianetto"
	desc = "Una pistola realizzata in acciaio mediocre."
	max_ammo_capacity = 1 //2 shots

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/italian/small(src)
		grip = new /obj/item/gun_parts/grip/italian(src)

//Standard factory issue
/obj/item/gun/modular/italian/italiano
	name = "improved Italian revolver"
	real_name = "\improper Italiano"
	desc = "Una pistola realizzata in acciaio di qualità e pelle.."
	max_ammo_capacity = 2

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
/obj/item/gun/modular/italian/big_italiano
	name = "masterwork Italian revolver"
	real_name = "\improper Italianone"
	desc = "Una pistola realizzata con acciaio, cuoio e olio d'oliva della più alta qualità possibile."
	max_ammo_capacity = 3

	make_parts()

		if (prob(75))
			stock = new /obj/item/gun_parts/stock/italian(src)
			barrel = new /obj/item/gun_parts/barrel/italian/buntline(src)
		else
			grip = new /obj/item/gun_parts/grip/italian/bigger(src)
			barrel = new /obj/item/gun_parts/barrel/italian/accurate(src)

//da jokah babiyyyy
/obj/item/gun/modular/italian/silly
	name = "jokerfied Italian revolver"
	real_name = "\improper Grande Italiano"
	max_ammo_capacity = 3
	desc = "Io sono il pagliaccio, bambino!"

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/italian/joker(src)
		grip = new /obj/item/gun_parts/grip/italian/cowboy/bandit(src)
