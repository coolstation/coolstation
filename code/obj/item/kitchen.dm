/*
CONTAINS:

CUTLERY
MISC KITCHENWARE
TRAYS
*/

/obj/item/kitchen
	icon = 'icons/obj/foodNdrink/kitchen.dmi'

/obj/item/kitchen/rollingpin
	name = "rolling pin"
	icon_state = "rolling_pin"
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	force = 8.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 7
	w_class = W_CLASS_NORMAL
	desc = "A wooden tube, used to roll dough flat in order to make various edible objects. It's pretty sturdy."
	stamina_damage = 40
	stamina_cost = 15
	stamina_crit_chance = 2

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		BLOCK_SETUP(BLOCK_ROD)

/obj/item/kitchen/rollingpin/light
	name = "light rolling pin"
	force = 4.0
	throwforce = 5.0
	desc = "A hollowed out tube, to save on weight, used to roll dough flat in order to make various edible objects."
	stamina_damage = 10
	stamina_cost = 10

/obj/item/kitchen/utensil
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	force = 5.0
	w_class = W_CLASS_TINY
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	stamina_damage = 5
	stamina_cost = 10
	stamina_crit_chance = 15
	dir = NORTH
	var/rotatable = 1 //just in case future utensils are added that dont wanna be rotated
	var/snapped

	New()
		..()
		if(prob(60))
			src.pixel_y = rand(0, 4)
		BLOCK_SETUP(BLOCK_KNIFE)
		return

	attack_self(mob/user as mob)
		src.rotate()

	proc/rotate()
		if(rotatable)
			//set src in oview(1)
			src.set_dir(turn(src.dir, -90))
		return

	proc/break_utensil(mob/living/carbon/user as mob, var/spawnatloc = 0)
		var/location = get_turf(src)
		user.visible_message("<span style=\"color:red\">[src] breaks!</span>")
		playsound(user.loc, "sound/impact_sounds/Generic_Snap_1.ogg", 30, 1)
		user.u_equip(src)
		var/replacethis
		switch(src.type)
			if(/obj/item/kitchen/utensil/spoon/plastic)
				replacethis = "spoon_plastic_"
			if(/obj/item/kitchen/utensil/fork/plastic)
				replacethis = "fork_plastic_"
			if(/obj/item/kitchen/utensil/knife/plastic)
				if(src.snapped)
					qdel(src)
					return
				replacethis = "knife_plastic_"
		var/utensil_color = replacetext(src.icon_state,replacethis,"")
		var/obj/item/kitchen/utensil/knife/plastic/k = new /obj/item/kitchen/utensil/knife/plastic
		k.icon_state = "snapped_[utensil_color]"
		k.snapped = 1
		k.name = "snapped [k.name]"
		if(spawnatloc)
			k.set_loc(location)
		else
			user.put_in_hand_or_drop(k)
		qdel(src)
		return

/obj/item/kitchen/utensil/spoon
	name = "spoon"
	desc = "A metal object that has a handle and ends in a small concave oval. Used to carry liquid objects from the container to the mouth."
	icon_state = "spoon"
	dir = NORTH
	tool_flags =  TOOL_SPOONING

	attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
		if (user?.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span style='color:red'><b>[user]</b> fumbles [src] and jabs [himself_or_herself(user)].</span>")
			random_brute_damage(user, 5)
		if (!spoon_surgery(M,user))
			return ..()

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		var/hisher = his_or_her(user)
		user.visible_message("<span style='color:red'><b>[user] jabs [src] straight through [hisher] eye and into [hisher] brain!</b></span>")
		blood_slash(user, 25)
		playsound(user.loc, src.hitsound, 50, 1)
		user.TakeDamage("head", 150, 0)
		user.updatehealth()
		return 1

	fancy
		icon_state = "spoon-new"

/obj/item/kitchen/utensil/fork
	name = "fork"
	icon_state = "fork"
	tool_flags = TOOL_SAWING
	hit_type = DAMAGE_STAB
	hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
	desc = "A multi-pronged metal object, used to pick up objects by piercing them. Helps with eating some foods."
	dir = NORTH
	throwforce = 7

	New()
		..()
		//setItemSpecial(/datum/item_special/jab)

	attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
		if(user?.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span class='alert'><b>[user]</b> fumbles [src] and stabs [himself_or_herself(user)].</span>")
			random_brute_damage(user, 10)
			JOB_XP(user, "Clown", 1)
		if(!saw_surgery(M,user)) // it doesn't make sense, no. but hey, it's something.
			return ..()

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if(!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] stabs [src] right into [his_or_her(user)] heart!</b></span>")
		blood_slash(user, 25)
		playsound(user.loc, src.hitsound, 50, 1)
		user.TakeDamage("chest", 150, 0)
		return 1
	fancy
		icon_state = "fork-new"

/obj/item/kitchen/utensil/knife
	name = "knife"
	icon_state = "knife"
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	tool_flags = TOOL_CUTTING
	event_handler_flags = USE_GRAB_CHOKE | USE_FLUID_ENTER
	special_grab = /obj/item/grab
	hit_type = DAMAGE_CUT
	hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'
	force = 7.0
	throwforce = 10
	desc = "A long bit of metal that is sharpened on one side, used for cutting foods. Also useful for butchering dead animals. And live ones."
	dir = NORTH

	New()
		..()
		src.AddComponent(/datum/component/bloodflick)
		src.setItemSpecial(/datum/item_special/double)

	attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
		if(user?.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span class='alert'><b>[user]</b> fumbles [src] and cuts [himself_or_herself(user)].</span>")
			random_brute_damage(user, 20)
			JOB_XP(user, "Clown", 1)
		if(!scalpel_surgery(M,user))
			return ..()

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if(!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] slashes [his_or_her(user)] own throat with [src]!</b></span>")
		blood_slash(user, 25)
		user.TakeDamage("head", 150, 0)
		return 1


	fancy
		icon_state = "knife-new"

	steak
		name = "steak knife"
		icon_state = "knife-steak"
		desc = "The proper way to cut up a hot fresh monkey steak."

/obj/item/kitchen/utensil/spoon/plastic
	name = "plastic spoon"
	icon_state = "spoon_plastic"
	desc = "A cheap plastic spoon, prone to breaking. Used to carry liquid objects from the container to the mouth."
	force = 1.0
	throwforce = 1.0

	New()
		..()
		src.icon_state = pick("spoon_plastic_pink","spoon_plastic_yellow","spoon_plastic_green","spoon_plastic_blue")

	attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
		if (user?.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span style=\"color:red\"><b>[user]</b> fumbles [src] and jabs [himself_or_herself(user)].</span>")
			random_brute_damage(user, 5)
		if (prob(20))
			src.break_utensil(user)
			return
		if (!spoon_surgery(M,user))
			return ..()

	suicide(var/mob/user as mob)
		user.visible_message("<span style=\"color:red\"><b>[user] tries to jab [src] straight through [his_or_her(user)] eye and into [his_or_her(user)] brain!</b></span>")
		src.break_utensil(user)
		spawn(100)
			if (user)
				user.suiciding = 0
		return 1

/obj/item/kitchen/utensil/fork/plastic
	name = "plastic fork"
	icon_state = "fork_plastic_pink"
	desc = "A cheap plastic fork, prone to breaking. Helps with eating some foods."
	force = 1.0
	throwforce = 1.0
	dir = NORTH

	New()
		..()
		src.icon_state = pick("fork_plastic_pink","fork_plastic_yellow","fork_plastic_green","fork_plastic_blue")

	attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
		if (user?.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span style=\"color:red\"><b>[user]</b> fumbles [src] and stabs [himself_or_herself(user)].</span>")
			random_brute_damage(user, 5)
		if (prob(20))
			src.break_utensil(user)
			return
		if (!saw_surgery(M,user))
			return ..()

	suicide(var/mob/user as mob)
		user.visible_message("<span style=\"color:red\"><b>[user] tries to stab [src] right into [his_or_her(user)] heart!</b></span>")
		src.break_utensil(user)
		spawn(100)
			if (user)
				user.suiciding = 0
		return 1

/obj/item/kitchen/utensil/knife/plastic
	name = "plastic knife"
	icon_state = "knife_plastic"
	force = 1.0
	throwforce = 1.0
	desc = "A long bit plastic that is serated on one side, prone to breaking. It is used for cutting foods. Also useful for butchering dead animals, somehow."

	New()
		..()
		src.icon_state = pick("knife_plastic_pink","knife_plastic_yellow","knife_plastic_green","knife_plastic_blue")

	attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
		if(user?.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span class='alert'><b>[user]</b> fumbles [src] and cuts [himself_or_herself(user)].</span>")
			random_brute_damage(user, 5)
			JOB_XP(user, "Clown", 1)
		if(prob(20))
			src.break_utensil(user)
			return
		if(!scalpel_surgery(M,user))
			return ..()

	suicide(var/mob/user as mob)
		user.visible_message("<span class='alert'><b>[user] tries to slash  [his_or_her(user)] own throat with [src]!</b></span>")
		src.break_utensil(user)
		SPAWN_DBG(10 SECONDS)
			if(user)
				user.suiciding = 0
		return 1

/obj/item/kitchen/plasticpackage
	name = "package of plastic silverware"
	desc = "These don't look very clean..."
	icon_state = "plasticpackage"
	w_class = W_CLASS_TINY
	var/list/messages = list("The packaging decides to not open at this time. How rude.", "The plastic is just too strong for your fumbly fingers!", "Almost open! Wait...Nevermind.", "Almost there.....")

	attack_self(mob/user as mob)
		if(prob(40))
			var/obj/item/kitchen/utensil/fork/plastic/f = new /obj/item/kitchen/utensil/fork/plastic
			var/obj/item/kitchen/utensil/knife/plastic/k = new /obj/item/kitchen/utensil/knife/plastic
			var/obj/item/kitchen/utensil/spoon/plastic/s = new /obj/item/kitchen/utensil/spoon/plastic
			f.icon_state = "fork_plastic_white"
			k.icon_state = "knife_plastic_white"
			s.icon_state = "spoon_plastic_white"
			f.set_loc(get_turf(user))
			k.set_loc(get_turf(user))
			s.set_loc(get_turf(user))
			user.u_equip(src)
			src.set_loc(user)
			if(prob(30))
				user.show_text("<b>The plastic silverware go EVERYWHERE!</b>","red")
				var/list/throw_targets = list()
				for (var/i=1, i<=3, i++)
					throw_targets += get_offset_target_turf(src.loc, rand(5)-rand(5), rand(5)-rand(5))
				f.throw_at(pick(throw_targets), 5, 1)
				if(prob(20))
					f.break_utensil(user, 1)
				k.throw_at(pick(throw_targets), 5, 1)
				if(prob(20))
					k.break_utensil(user, 1)
				s.throw_at(pick(throw_targets), 5, 1)
				if(prob(20))
					s.break_utensil(user, 1)
			qdel(src)
		else
			user.visible_message("<b>[user]</b> comically struggles to open the [src]","<b>[pick(messages)]</b>")

//chopsticks
/obj/item/kitchen/chopsticks_package
	name = "chopsticks"
	desc = "cheap disposable chopsticks!"
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	icon_state = "chop_closed"
	item_state = "chop"
	w_class = W_CLASS_TINY

	attack_self(mob/user as mob)
		if(src.icon_state == "chop_closed")
			user.visible_message("<b>[user.name]</b> unwraps the chopsticks!")
			src.icon_state = "chop_stowed"
			src.name = "stowed chopsticks"
		else if(src.icon_state == "chop_stowed")
			user.u_equip(src)
			user.put_in_hand_or_drop(new /obj/item/kitchen/utensil/fork/chopsticks)
			qdel(src)

	attackby(obj/item/weapon as obj,mob/user as mob)
		if(istype(weapon,/obj/item/paper))
			if(src.icon_state == "chop_stowed")
				user.u_equip(weapon)
				qdel(weapon)
				src.icon_state = "chop_closed"
				src.name = "chopsticks"
			else
				boutput(user,"<span style=\"color:red\"><b>The chopstics already have a wrapper!</b></span>")

/obj/item/kitchen/utensil/fork/chopsticks
	name = "chopsticks"
	desc = "cheap disposable chopsticks!"
	icon_state = "chop_open"
	item_state = "chop"
	rotatable = 0
	tool_flags = 0

	attack_self(mob/user as mob)
		var/obj/item/kitchen/chopsticks_package/chop = new /obj/item/kitchen/chopsticks_package
		chop.icon_state = "chop_stowed"
		chop.name = "stowed chopsticks"
		user.u_equip(src)
		user.put_in_hand_or_drop(chop)
		qdel(src)

/obj/item/kitchen/utensil/knife/cleaver
	name = "meatcleaver"
	icon_state = "cleaver"
	item_state = "cleaver"
	desc = "An extremely sharp cleaver in a rectangular shape. Only for the professionals."
	force = 12.0
	throwforce = 3.0
	hit_type = DAMAGE_CUT
	hitsound = 'sound/impact_sounds/Blade_Small_Bloody.ogg'

	throw_impact(atom/A, datum/thrown_thing/thr)
		if(iscarbon(A))
			var/mob/living/carbon/C = A
			if(ismob(usr))
				A:lastattacker = usr
				A:lastattackertime = world.time
			random_brute_damage(C, 15, 1)
			take_bleeding_damage(C, null, 10, DAMAGE_CUT)
			playsound(src, 'sound/impact_sounds/Flesh_Stab_3.ogg', 40, 1)

/obj/item/kitchen/utensil/knife/bread
	name = "bread knife"
	icon_state = "knife-bread"
	item_state = "knife"
	desc = "A rather blunt knife; it still cuts things, but not very effectively."
	force = 3.0
	throwforce = 3.0

	suicide(var/mob/user as mob)
		user.visible_message("<span class='alert'><b>[user] drags [src] over [his_or_her(user)] own throat!</b></span>")
		blood_slash(user, 25)
		user.TakeDamage("head", 150, 0)
		return 1

/obj/item/kitchen/utensil/knife/pizza_cutter
	name = "pizza cutter"
	icon_state = "pizzacutter"
	force = 3.0 // it's a bladed instrument, sure, but you're not going to do much damage with it
	throwforce = 3.0
	desc = "A cutting tool with a rotary circular blade, designed to cut pizza. You can probably use it as a knife with enough patience."
	tool_flags = TOOL_SAWING

	attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
		if(user?.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span class='alert'><b>[user]</b> fumbles [src] and pinches [his_or_her(user)] fingers against the blade guard.</span>")
			random_brute_damage(user, 5)
			JOB_XP(user, "Clown", 1)
		if(!saw_surgery(M,user))
			return ..()

	suicide(var/mob/user as mob)
		user.visible_message("<span class='alert'><b>[user] rolls [src] repeatedly over [his_or_her(user)] own throat and slices it wide open!</b></span>")
		blood_slash(user, 25)
		user.TakeDamage("head", 150, 0)
		return 1

/obj/item/kitchen/utensil/knife/pizza_cutter/traitor
	var/sharpener_mode = FALSE

	attack_self(mob/user as mob)
		sharpener_mode = !sharpener_mode
		boutput(user, "You flip a hidden switch in the pizza cutter to the [sharpener_mode ? "ON" : "OFF"] position.")

//420 lol
/obj/item/kitchen/wineholder //mama mia
	name = "\improper novelty wine holder"
	desc = "LOOKS NORMAL!!!"
	icon = 'icons/obj/foodNdrink/kitchen.dmi'
	icon_state = "homph"
	anchored = 1
	flags = NOSPLASH
	var/emagged = FALSE //hoo hoo
	var/wine = null
	var/launching = 0

	get_desc(dist, mob/user)
		if (dist <= 3)
			. += " There's [(src.wine) ? "a" : "no" ] wine bottle inserted in \the [src][(src.wine) ? "." : ". get it in their...." ]"

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W,/obj/item/reagent_containers/food/drinks/bottle/wine)) //need to add hobowine and make bottles breakable when thrown
			if(src.wine)
				boutput(user, "There's already a wine bottle in \the [src].")
				return
			if (src.launching)
				boutput(user, "You probably shouldn't put anything else in \the [src] right now...")
				return
			user.remove_item(W)
			W.set_loc(src)
			src.wine = W
			src.icon_state = "homph-wine"
			if (src.emagged)
				boutput(user, "You place \the [W] into \the [src]. Take cover!") //you were warned
				src.visible_message("<span class='alert'><b> The [src] starts looking around for a target!</b></span>")
				playsound(src, "sound/misc/tarantella-emag.ogg", 50, 1)
				src.launch_wine() //launch sequence engaged
			else
				boutput(user, "You place \the [W] into \the [src].")
				playsound(src, "sound/misc/tarantella-short.ogg", 50, 1)
		else
			..()
		return

	proc/launch_wine() //some temporary target discrimination
		if (src.launching)
			return //already busy
		if (src.wine && src.emagged) //loaded and ready?
			src.launching = 1
			//warm up
			animate_storage_thump(src)
			src.dir = turn(src.dir,-180)
			sleep(2 SECONDS)
			animate_storage_thump(src)
			src.dir = turn(src.dir,-180)
			sleep(3 SECONDS)
			animate_storage_thump(src)
			src.dir = turn(src.dir,-180)
			src.visible_message("<span class='alert'><b>\The [src] lets out [pick("a strange","a weird","an awful","a <b>sexy<b>","a")] [pick("moan","groan","sigh")]!</b></span>")
			playsound(src, "sound/voice/hoooagh2.ogg", 100, 1)
			sleep((rand(3,6)) SECONDS)
			animate_storage_thump(src)
			src.dir = turn(src.dir,-180)
			sleep((rand(3,6)) SECONDS)
			//target selection
			var/mob/living/target = locate() in view(7,src)
			//"the search for another target" functionality was broken and laggy as shit
			//i'll come back later, since it'd be nice to have a projectile landwine
			//firing
			if (!src.emagged || !target) //are we still even emagged, or did we even find a target?
				src.visible_message("<span class='alert'><b>\The [src] stops searching for a target.</b></span>")
				src.launching = 0
				return
			if (src.launching)
				if (src.wine)
					var/obj/item/W = src.wine
					W.set_loc(get_turf(src)) //bring it out
					src.wine = null //clear it from the holder
					W.throw_at(target, 16, 5, 49)
					animate_storage_thump(src)
					playsound(src, "sound/misc/tarantella-emag.ogg", 50, 1)
					src.icon_state = "homph-emag"
					src.visible_message("<span class='alert'><b>\The [src] launches \the [W] at [target]!</b></span>")
				else
					src.visible_message("<span class='alert'><b>\The [src] looks incredibly disappointed.</b></span>")
				src.launching = 0
				return

	emag_act(var/mob/user, var/obj/item/card/emag/E) //emaggable behavior
		if (!src.emagged)
			src.emagged = 1
			if (!src.wine)
				src.icon_state = "homph-emag"
				if(user)
					boutput(user, "you make this meatball a little spicier!!! homph omph")
				src.visible_message("<span class='alert'><b> \The [src] buzzes oddly and gets a wild look in its eyes!</b></span>")
			else
				if(user)
					boutput(user, "you make this meatball a little spicier!!! ...You should probably take cover!")
				src.visible_message("<span class='alert'><b> \The [src] buzzes oddly and starts looking around for a target!</b></span>")
				SPAWN_DBG(1 SECOND)
					src.launch_wine() //otherwise it waits for the whole process to end to return 1
			playsound(src, "sound/misc/tarantella-emag.ogg", 50, 1)
			SPAWN_DBG(5 MINUTES) //start the process to un-emag
				src.visible_message("<b>\The [src] takes a nap!</b>") //chill
				if(src.wine)
					src.icon_state = "homph-wine"
				else
					src.icon_state = "homph"
				src.emagged = 0
				src.launching = 0 //otherwise you can't get the wine back out.
			return 1

		if (src.emagged && (!src.wine) && user) //double emag, must be empty
			if (src.launching)
				src.visible_message("<b>\The [src]</b> looks a little busy at the moment!")
				return 0
			if (get_dist(src, user) >= 2)
				return 0
			src.launching = 1
			playsound(src, "sound/items/eatfood.ogg", 100, 1)
			user.visible_message("<b>[src]</b> eats [user]'s [E]! What the fuck?","Your [E] gets eaten by \the [src]. What the fuck!?")
			src.icon_state = "homph"
			qdel(E)
			SPAWN_DBG(2 SECONDS)
				playsound(src, "sound/voice/burp.ogg", 100, 1)
				src.visible_message("<b>[src]</b> burps.")
				sleep(3 SECOND)

				src.visible_message("<b>[src]</b> gesticulates wildly!")
				src.icon_state = "homph-emag"
				sleep(3 SECONDS)
				src.icon_state = "homph"
				sleep(3 SECONDS)

				if (get_dist(src, user) <= 7)
					src.visible_message("<b>\The [src]</b> winks jovially at [user]. Everything about this feels [prob(90)?" wrong.":" right!"]")
				sleep(3 SECONDS)
				//yes this is a ripoff of the golden emag
				var/obj/item/card/emag/EI = new /obj/item/card/emag(src.loc)
				EI.name = "Carta Elettromagnetica"
				EI.desc = "È una scheda con una striscia magnetica attaccata a dei circuiti. Comunemente indicato come 'EMAG'. Profuma di vino..."
				playsound(src, "sound/misc/meat_plop.ogg", 50, 1)
				if (get_dist(src, user) <= 7)
					EI.throw_at(user, 16, 5)
					src.visible_message("<b>\The [src]</b> spits out a [EI] at [user]!")
				else
					src.visible_message("<b>\The [src]</b> spits out a [EI]!")
				src.icon_state = "homph-emag"
				src.launching = 0
			return 0
		else
			return 0

	attack_hand(mob/user as mob) //take a wine bottle out
		src.add_fingerprint(user)
		if (!src.wine)
			user.show_text("\The [src] doesn't have anything in it.", "red")
		else if (src.launching)
			user.show_text("No way! You're not touching that thing right now.", "red")
		else
			boutput(user, "You take \the [src.wine] out of \the [src].")
			playsound(src, "sound/misc/tarantella-short.ogg", 50, 1)
			user.put_in_hand_or_drop(src.wine)
			src.wine = null
			src.icon_state= "homph"

	unchained
		anchored = 0

/obj/item/kitchen/food_box // I came in here just to make donut/egg boxes put the things in your hand when you take one out and I end up doing this instead, kill me. -haine
	name = "food box"
	desc = "A box that can hold food! Well, not this one, I mean. You shouldn't be able to see this one."
	icon = 'icons/obj/foodNdrink/food_related.dmi'
	icon_state = "donutbox"
	uses_multiple_icon_states = 1
	amount = 6
	var/max_amount = 6
	var/box_type = "donutbox"
	var/has_closed_state = 1
	var/contained_food = /obj/item/reagent_containers/food/snacks/donut/custom/random
	var/allowed_food = /obj/item/reagent_containers/food/snacks/donut
	var/contained_food_name = "donut"
	tooltip_flags = REBUILD_DIST

	donut_box
		name = "donut box"
		desc = "A box for containing and transporting \"dough-nuts\", a popular ethnic food."

	egg_box
		name = "egg carton"
		desc = "A carton that holds a bunch of eggs. What kind of eggs? What grade are they? Are the eggs from space? Space chicken eggs?"
		icon_state = "eggbox"
		amount = 12
		max_amount = 12
		box_type = "eggbox"
		contained_food = /obj/item/reagent_containers/food/snacks/ingredient/egg
		allowed_food = /obj/item/reagent_containers/food/snacks/ingredient/egg
		contained_food_name = "egg"

	lollipop
		name = "lollipop bowl"
		desc = "A little bowl of sugar-free lollipops, totally healthy in every way! They're medicinal, after all!"
		icon_state = "lpop8"
		amount = 8
		max_amount = 8
		box_type = "lpop"
		has_closed_state = 0
		contained_food = /obj/item/reagent_containers/food/snacks/lollipop/random_medical
		allowed_food = /obj/item/reagent_containers/food/snacks/lollipop
		contained_food_name = "lollipop"
		w_class = W_CLASS_SMALL

	New()
		..()
		SPAWN_DBG(1 SECOND)
			if(!ispath(src.contained_food))
				logTheThing("debug", src, null, "has a non-path contained_food, \"[src.contained_food]\", and is being disposed of to prevent errors")
				qdel(src)
				return

	get_desc(dist)
		if(dist <= 1)
			. += "There's [(src.amount > 0) ? src.amount : "no" ] [src.contained_food_name][s_es(src.amount)] in [src]."

	attackby(obj/item/W as obj, mob/user as mob)
		if(src.amount >= src.max_amount)
			boutput(user, "You can't fit anything else in [src]!")
			return
		else
			if(istype(W, src.allowed_food))
				user.drop_item()
				W.set_loc(src)
				src.amount ++
				tooltip_rebuild = 1
				boutput(user, "You place [W] into [src].")
				src.update()
			else return ..()

	MouseDrop(mob/user as mob) // no I ain't even touchin this mess it can keep doin whatever it's doin
		// I finally came back and touched that mess because it was broke - Haine
		if(user == usr && !user.restrained() && !user.stat && (user.contents.Find(src) || in_interact_range(src, user)))
			if(!user.put_in_hand(src))
				return ..()

	attack_hand(mob/user as mob)
		if((!istype(src.loc, /turf) && !user.is_in_hands(src)) || src.amount == 0)
			..()
			return
		src.add_fingerprint(user)
		var/list/obj/item/reagent_containers/food/snacks/myFoodList = src.contents
		if(myFoodList.len >= 1)
			var/obj/item/reagent_containers/food/snacks/myFood = myFoodList[myFoodList.len]
			if(src.amount >= 1)
				src.amount--
				tooltip_rebuild = 1
			user.put_in_hand_or_drop(myFood)
			boutput(user, "You take [myFood] out of [src].")
		else
			if(src.amount >= 1)
				src.amount--
				tooltip_rebuild = 1
				var/obj/item/reagent_containers/food/snacks/newFood = new src.contained_food(src.loc)
				user.put_in_hand_or_drop(newFood)
				boutput(user, "You take [newFood] out of [src].")
		src.update()

	attack_self(mob/user as mob)
		if(!src.has_closed_state) return
		if(src.icon_state == "[src.box_type]")
			src.icon_state = "[src.box_type][src.amount]"
			boutput(user, "You open [src].")
		else
			src.icon_state = "[src.box_type]"
			boutput(user, "You close [src].")

	proc/update()
		src.icon_state = "[src.box_type][src.amount]"
		return

//=-=-=-=-=-=-=-=-=-=-=-=-
//TRAYS AND PLATES OH MY||
//=-=-=-=-=-=-=-=-=-=-=-=-

/obj/item/plate
	name = "plate"
	desc = "It's like a frisbee, but more dangerous!"
	icon = 'icons/obj/foodNdrink/food_related.dmi'
	icon_state = "plate"
	item_state = "zippo"
	throwforce = 3.0
	throw_speed = 3
	throw_range = 8
	force = 2
	rand_pos = 0
	pickup_sfx = "sound/items/pickup_plate.ogg"
	var/list/ordered_contents = list()
	var/food_desc = null
	var/max_food = 2
	var/list/throw_targets = list()
	var/throw_dist = 3
	var/stackable = TRUE
	var/is_plate = TRUE
	var/obj/item/plate/plate_stacked
	tooltip_flags = REBUILD_DIST
	var/hit_sound = "sound/items/plate_tap.ogg"

	New()
		..()
		BLOCK_SETUP(BLOCK_BOOK)

	proc/update_icon()
		return

	/// Attempts to add an item to the plate, if there's space. Returns TRUE if food is successfully added.
	proc/add_contents(obj/item/food, mob/user, click_params)
		. = FALSE
		if (istype(food, /obj/item/plate))
			if (food == src)
				boutput(user, "<span class='alert'>You can't stack a [src] on itself!</span>")
				return
			if (src.plate_stacked)
				boutput(user, "<span class='alert'>You can't stack anything on [src], it already has a plate stacked on it!</span>")
				return
			var/obj/item/plate/not_really_food = food
			. = src.stackable && not_really_food.stackable // . is TRUE if we can stack the other plate on this plate, FALSE otherwise

		if (length(src.ordered_contents) == max_food && src.is_plate)
			boutput(user, "<span class='alert'>There's no more space on \the [src]!</span>")
			return
			                                    // anything that isn't a plate may as well hold anything that fits the "plate"
		if (!food.edible && !. && src.is_plate) // plates aren't edible, so we check if we're adding a valid plate as well (. is TRUE if so)
			boutput(user, "<span class='alert'>That's not food, it doesn't belong on \the [src]!</span>")
			return
		if (food.w_class > W_CLASS_NORMAL && !.) // same logic as above, but to check if we can stack it
			boutput(user, "You try to think of a way to put [food] [src.is_plate ? "on" : "in"] \the [src] but it's not possible! It's too large!")
			return
		if (food in src.vis_contents)
			boutput(user, "That's already on the [src]!")
			return

		. = TRUE // If we got this far it's a valid plate content

		if (istype(food, /obj/item/plate/))
			src.plate_stacked = TRUE
		else
			src.ordered_contents += food

		src.place_on(food, user, click_params) // this handles pixel positioning
		food.set_loc(src)
		src.vis_contents += food
		food.appearance_flags |= RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		food.vis_flags |= VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
		food.event_handler_flags |= NO_MOUSEDROP_QOL
		//RegisterSignal(food, COMSIG_ATOM_MOUSEDROP, .proc/indirect_pickup)
		RegisterSignal(food, COMSIG_MOVABLE_SET_LOC, .proc/remove_contents)
		RegisterSignal(food, COMSIG_ATTACKHAND, .proc/remove_contents)
		src.update_icon()
		boutput(user, "You put [food] [src.is_plate ? "on" : "in"] \the [src].")

	/// Removes a piece of food from the plate.
	proc/remove_contents(obj/item/food)
		MOVE_OUT_TO_TURF_SAFE(food, src)
		src.vis_contents -= food
		food.appearance_flags = initial(food.appearance_flags)
		food.vis_flags = initial(food.vis_flags)
		food.event_handler_flags = initial(food.event_handler_flags)
		//UnregisterSignal(food, COMSIG_ATOM_MOUSEDROP)
		UnregisterSignal(food, COMSIG_MOVABLE_SET_LOC)
		UnregisterSignal(food, COMSIG_ATTACKHAND)
		if (istype(food, /obj/item/plate/))
			src.plate_stacked = FALSE
		else
			src.ordered_contents -= food
		src.update_icon()

	/// Used to pick the plate up by click dragging some food to you, in case the plate is covered by big foods
	proc/indirect_pickup(var/food, mob/user, atom/over_object)
		if (user == over_object && in_interact_range(src, user) && can_act(user))
			src.Attackhand(user)

	/// Called when you throw or smash the plate, throwing the contents everywhere
	proc/shit_goes_everywhere(depth = 1)
		if (length(src.contents))
			src.visible_message("<span class='alert'>Everything [src.is_plate ? "on" : "in"] \the [src] goes flying!</span>")
		for (var/atom/movable/food in src)
			food.set_loc(get_turf(src))
			if (istype(food, /obj/item/plate))
				var/obj/item/plate/not_food = food
				SPAWN_DBG(0.1 SECONDS) // This is rude but I want a small delay in smashing nested plates. More satisfying
					not_food?.shit_goes_everywhere(depth)
			else
				food.throw_at(get_offset_target_turf(src.loc, rand(throw_dist)-rand(throw_dist), rand(throw_dist)-rand(throw_dist)), 5, 1)

	/// Used to smash the plate over someone's head
	proc/unique_attack_garbage_fuck(mob/M, mob/user)
		attack_particle(user,M)
		M.TakeDamageAccountArmor("head", force, 0, 0, DAMAGE_BLUNT)
		playsound(src, "sound/impact_sounds/plate_break.ogg", 50, 1)

		var/turf/shardturf = get_turf(M)

		if(src.cant_drop == 1)
			var/mob/living/carbon/human/H = user
			H.sever_limb(H.hand == 1 ? "l_arm" : "r_arm")
		else
			user.drop_item()
			src.set_loc(shardturf)

		for (var/i in 1 to 2)
			var/obj/O = new /obj/item/raw_material/shard/glass()
			O.set_loc(shardturf)
			if(src.material)
				O.setMaterial(src.material)
			O.throw_at(get_offset_target_turf(shardturf, rand(-4,4), rand(-4,4)), 7, 1)

		qdel(src)

	throw_impact(atom/A, datum/thrown_thing/thr)
		..()
		if(ordered_contents.len == 0)
			return
		src.shit_goes_everywhere()

	get_desc(dist)
		if(dist > 5)
			return
		if(ordered_contents.len == 0)
			food_desc = "\The [src] has no food on it!"
		else
			food_desc = "\The [src] has "
			for (var/i = 1, i <= ordered_contents.len, i++)
				var/obj/item/F = ordered_contents[i]
				if(i == ordered_contents.len && i == 1)
					food_desc += "\an [F] on it."
					return "[food_desc]"
				if(i == ordered_contents.len)
					food_desc += "and \an [F] on it."
				else
					food_desc += "\an [F], "
		if(length("[food_desc]") > MAX_MESSAGE_LEN)
			return "<span style=\"color:orange\">There's a positively <i>indescribable</i> amount of food on \the [src]!</span>"
		return "[food_desc]"

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/plate) && !istype(W, /obj/item/plate/tray) && W.type == src.type)
			if(length(src.contents) || length(W.contents))
				user.visible_message("<b>[user]</b> tries to stack plates but there's food on them.","You try to stack plates but there's food on them.")
				return
			qdel(W)
			src.set_loc(user)
			user.put_in_hand_or_drop(new /obj/item/platestack)
			user.visible_message("<b>[user]</b> adds a plate to the stack.","You add a plate to the stack.")
			qdel(src)
			return
		else if(istype(W, /obj/item/platestack))
			var/obj/item/platestack/stack = W
			if(stack.platenum >= stack.platemax)
				boutput(user,"<span class='alert'><b>The plates are piled too high!</b></span>")
				return
			src.set_loc(user)
			stack.platenum++
			stack.update_icon(user)
			user.visible_message("<b>[user]</b> adds a plate to the stack.","You add a plate to the stack.")
			qdel(src)
			return
		if(!W.edible)
			if(istype(W, /obj/item/kitchen/utensil/fork) || istype(W, /obj/item/kitchen/utensil/spoon))
				var/obj/item/reagent_containers/food/sel_food = input(user, "Which food do you want to eat?", "[src] Contents") as null|anything in ordered_contents
				if(!sel_food)
					return
				sel_food.Eat(user,user)
				user.visible_message("[user] takes a bite from \the [sel_food].")
				if(sel_food in src.contents)
					return
				src.remove_contents(sel_food)
				src.update_icon()
				return
			boutput(user, "[W] isn't food, That doesn't belong on \the [src]!")
			return
		if(ordered_contents.len == max_food)
			boutput(user, "That won't fit, \the [src] is too full!")
			return
		if(W.w_class > W_CLASS_NORMAL)
			boutput(user, "You try to think of a way to put [W] on \the [src] but it's not possible! It's too large!")
			return
		user.drop_item()
		W.set_loc(src)
		src.add_contents(W)
		src.ClearAllOverlays()
		src.update_icon()
		boutput(user, "You put [W] on \the [src]")

	MouseDrop(atom/over_object, src_location, over_location)
		if(over_object == usr && get_dist(src, usr) <=1 && isliving(usr) && !usr.stat && !usr.restrained())
			var/mob/M = over_object
			if(ordered_contents.len == 0)
				boutput(M, "There's no food to take off of \the [src]!")
				return
			var/food_sel = input(M, "Which food do you want to take off of \the [src]?", "[src]'s contents") as null|anything in ordered_contents
			if(!food_sel)
				return

			M.put_in_hand_or_drop(food_sel)
			src.remove_contents(food_sel)
			src.update_icon()
			boutput(M, "You take \the [food_sel] off of \the [src].")
		else
			..()

	attack_self(mob/user as mob)
		if(ordered_contents.len == 0)
			boutput(user, "There's no food to take off of \the [src]!")
			return
		var/food_sel = input(user, "Which food do you want to take off of \the [src]?", "[src]'s contents") as null|anything in ordered_contents
		if(!food_sel)
			return
		user.put_in_hand_or_drop(food_sel)
		src.remove_contents(food_sel)
		src.update_icon()
		boutput(user, "You take \the [food_sel] off of \the [src].")

	attack(mob/M as mob, mob/user as mob)
		if(user.a_intent == INTENT_HARM)
			if(M == user)
				boutput(user, "<span class='alert'><B>You smash [src] over your own head!</b></span>")
			else
				M.visible_message("<span class='alert'><B>[user] smashes [src] over [M]'s head!</B></span>")
				logTheThing("combat", user, M, "smashes [src] over [constructTarget(M,"combat")]'s head! ")
			if(length(ordered_contents))
				src.shit_goes_everywhere()

			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(istype(H.head, /obj/item/clothing/head/helmet))
					M.do_disorient(stamina_damage = 150, weakened = 0.1 SECONDS, disorient = 3 SECOND)
				else
					M.changeStatus("weakened", 2 SECONDS)
					M.force_laydown_standup()
			else if(ismobcritter(M))
				var/mob/living/critter/L = M
				var/has_helmet = FALSE
				for(var/datum/equipmentHolder/head/head in L.equipment)
					if(istype(head.item, /obj/item/clothing/head/helmet))
						has_helmet = TRUE
						break
				if(has_helmet)
					M.do_disorient(stamina_damage = 150, weakened = 0.1 SECONDS, disorient = 3 SECOND)
				else
					M.changeStatus("weakened", 2 SECONDS)
					M.force_laydown_standup()
			else //borgs, ghosts, whatever
				M.do_disorient(stamina_damage = 150, weakened = 0.1 SECONDS, disorient = 1 SECOND)

			unique_attack_garbage_fuck(M, user)
		else
			M.visible_message("<span class='alert'>[user] taps [M] over the head with [src].</span>")
			playsound(src, src.hit_sound, 30, 1)
			logTheThing("combat", user, M, "taps [constructTarget(M,"combat")] over the head with [src].")

	attack_hand(mob/user as mob)
		..()
		src.ClearAllOverlays()
		src.update_icon()

	dropped(mob/user as mob) //shit_goes_everwhere doesnt work
		..()
		if(user.lying)
			user.visible_message("<span class='alert'>[user] drops \the [src]!</span>")
			if(ordered_contents.len == 0)
				return
			src.shit_goes_everywhere()
		if(user?.bioHolder.HasEffect("clumsy") && prob(25))
			user.visible_message("<span class='alert'>[user] clumsily drops \the [src]!</span>")
			if(ordered_contents.len == 0)
				return
			src.shit_goes_everywhere()

	MouseDrop_T(atom/movable/a as mob|obj, mob/user as mob)
		if(istype(a, /obj/item/plate) && (!istype(a, /obj/item/plate/tray)))
			var/obj/item/platestack/p = new /obj/item/platestack
			var/gate = 0
			for (var/obj/item/plate/P in range(1, user))
				if(P == src)
					continue
				if(P in user.contents)
					continue
				gate = 1
			if(gate == 0)
				return
			var/plateloc = get_turf(src)
			p.set_loc(plateloc)
			if(src in user.contents)
				user.u_equip(src)
			src.set_loc(p)
			p.MouseDropRelay(src,user)
		else
			return ..()

/obj/item/plate/tray //this is the big boy!
	name = "serving tray"
	desc = "It's a big flat tray for serving food upon."
	icon = 'icons/obj/foodNdrink/food_related.dmi'
	icon_state = "tray"
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	item_state = "tray"
	throwforce = 3.0
	throw_speed = 3
	throw_range = 4
	force = 10
	w_class = W_CLASS_BULKY //no trays of loaves in a backpack for you
	max_food = 30
	throw_dist = 5
	two_handed = 1 //decomment this line when porting over please
	is_plate = FALSE
	stackable = FALSE
	var/health_desc = null
	var/y_counter = 0
	var/y_mod = 0
	var/tray_health = 5 //number of times u can smash with a tray + 1, get_desc values are hardcoded so please adjust them (i know im a bad coder)
	hit_sound = "step_lattice"

	New()
		..()
		BLOCK_SETUP(BLOCK_ALL)

	proc/update_inhand_icon()
		var/weighted_num = round(ordered_contents.len / 5) //6 inhand sprites, 30 possible foods on the tray
		if(ordered_contents.len == 0)
			src.item_state = "tray"
			return

		switch (weighted_num)
			if(1)
				src.item_state = "tray_2"
			if(2)
				src.item_state = "tray_3"
			if(3)
				src.item_state = "tray_4"
			if(4)
				src.item_state = "tray_5"
			if(5)
				src.item_state = "tray_6"
			else  //overflow from 25 to 30, underflow from 0 to 5
				if(ordered_contents.len < 5)
					src.item_state = "tray_1"
					return
				src.item_state = "tray_6"

	update_icon() //this is what builds the overlays, it looks at the ordered list of food in the tray and does magic
		for (var/i = 1, i <= ordered_contents.len, i++)
			var/obj/item/F = ordered_contents[i]
			var/image/I = SafeGetOverlayImage("food_[i]", F.icon, F.icon_state)
			I.transform *= 0.75
			if(i % 2) //i feel clever for this haha
				I.pixel_x = -8
			else
				I.pixel_x = 8
			y_counter++
			if(y_counter == 3)
				y_mod++
				y_counter = 1
			I.pixel_y = y_mod * 3 //food layers are 3px above eachother
			I.layer = src.layer + 0.1
			src.UpdateOverlays(I, "food_[i]", 0, 1)
		for (var/i = ordered_contents.len + 1, i <= src.overlays.len, i++) //this is to clear up any funky ghost overlays
			src.ClearSpecificOverlays("food_[i]")
		y_counter = 0
		y_mod = 0
		src.update_inhand_icon() //update inhand sprite to match
		return

	get_desc(dist)
		if(dist > 5)
			return
		if((5 >= tray_health) && (tray_health > 3)) //im using hardcoded values im so garbage
			health_desc = "\The [src] seems nice and sturdy!"
		else if((3 >= tray_health) && (tray_health > 1)) //im a trash human
			health_desc = "\The [src] is getting pretty warped and flimsy."
		else if((1 >= tray_health) && (tray_health >=0))  //im a bad coder
			health_desc = "\The [src] is about to break, be careful!"
		if(ordered_contents.len == 0)
			food_desc = "\The [src] has no food on it!"
		else
			food_desc = "\The [src] has "
			for (var/i = 1, i <= ordered_contents.len, i++)
				var/obj/item/F = ordered_contents[i]
				if(i == ordered_contents.len && i == 1)
					food_desc += "\an [F] on it."
					return "[health_desc] [food_desc]"
				if(i == ordered_contents.len)
					food_desc += "and \an [F] on it."
				else //just a normal food then ok
					food_desc += "\an [F], "
		if(length("[health_desc] [food_desc]") > MAX_MESSAGE_LEN)
			return "<span style=\"color:orange\">There's a positively <i>indescribable</i> amount of food on \the [src]!</span>"
		return "[health_desc] [food_desc]" //heres yr desc you *bastard*

	unique_attack_garbage_fuck(mob/M as mob, mob/user as mob)
		M.TakeDamageAccountArmor("head", src.force, 0, 0, DAMAGE_BLUNT)
		playsound(src, "sound/weapons/trayhit.ogg", 50, 1)
		src.visible_message("\The [src] falls out of [user]'s hands due to the impact!")
		user.drop_item(src)

		if(tray_health == 0) //breakable trays because you flew too close to the sun, you tried to have unlimited damage AND stuns you fool, your hubris is too fat, too wide
			src.visible_message("<b>\The [src] shatters!</b>")
			playsound(src, "sound/impact_sounds/Metal_Hit_Light_1.ogg", 70, 1)
			new /obj/item/scrap(src.loc)
			qdel(src)
			return
		tray_health--
		tooltip_rebuild = 1

		src.visible_message("\The [src] looks less sturdy now.")

//sushiiiiiii
/obj/item/kitchen/sushi_roller
	name = "rolling mat"
	desc = "a bamboo mat for rolling sushi"
	icon_state = "roller-0"
	w_class = W_CLASS_SMALL

	var/seaweed //0 or 1, storage variable for checking if there's a seaweed overlay without using resources pulling image files
	var/rice //same :)
	var/toppings = 0 //amount of toppings on the sushi roller (up to 3)
	var/rolling = 0 //the progress of the rolling (used for the rolling interactivity)
	var/rolled //the status of the sushi being fully rolled
	var/fish //override for unique fish overlay handling
	var/swedish //override for unique swedish fish oberlay handling

	var/fishflag
	var/skip

	var/list/toppingdata = list() //(food_color)
	var/obj/item/reagent_containers/food/snacks/sushi_roll/custom/roll//= new /obj/item/reagent_containers/food/snacks/sushi_roll/custom

	New()
		..()
		BLOCK_SETUP(BLOCK_BOOK)

	attackby(obj/item/W as obj, mob/user as mob)

		if(!(locate(/obj/item/reagent_containers/food/snacks/sushi_roll/custom) in src))
			var/obj/item/reagent_containers/food/snacks/sushi_roll/custom/roll_internal = new /obj/item/reagent_containers/food/snacks/sushi_roll/custom(src)
			roll = roll_internal

		if(istype(W,/obj/item/reagent_containers/food/snacks) && !src.rolling && !(src.toppings>=3))
			var/obj/item/reagent_containers/food/snacks/FOOD = W
			if(istype(FOOD,/obj/item/reagent_containers/food/snacks/ingredient/seaweed)) //seaweed overlay handling
				if(!src.seaweed)
					var/image/seaweed = new /image('icons/obj/foodNdrink/kitchen.dmi',"seaweed-0")
					seaweed.layer = (src.layer+1) //i had to use explicit layering to get the dynamic rolling to render properly
					src.UpdateOverlays(seaweed,"seaweed")
					src.seaweed = 1
				user.u_equip(FOOD)
				qdel(FOOD)
			else if(istype(FOOD,/obj/item/reagent_containers/food/snacks/ingredient/sticky_rice) && src.seaweed) //rice overlay (requires seaweed)
				if(!src.rice)
					var/image/rice = new /image('icons/obj/foodNdrink/kitchen.dmi',"rice-0")
					rice.layer = (src.layer+2)
					src.UpdateOverlays(rice,"rice")
					src.rice = 1
				user.u_equip(FOOD)
				qdel(FOOD)
			else if(src.seaweed && src.rice) //if its not a seaweed sheet or sticky rice, and theres seaweed and rice on the sheet
				src.toppings++
				if(istype(FOOD,/obj/item/reagent_containers/food/snacks/swedish_fish)) //setting overrides
					src.swedish = 1
					skip = "ALL"
				var/ingredienttype
				if(istype(FOOD,/obj/item/reagent_containers/food/snacks/ingredient/meat)) //setting ingredient type for the roller overlays
					if(istype(FOOD,/obj/item/reagent_containers/food/snacks/ingredient/meat/fish))
						if(!fishflag)
							if(istype(FOOD,/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/small))
								fishflag = "fillet-white"
							else
								fishflag = FOOD.icon_state
							skip = src.toppings
					ingredienttype="meat"
				else
					ingredienttype="nonmeat"
				var/image/foodoverlay = new /image('icons/obj/foodNdrink/kitchen.dmi',"[ingredienttype]-[src.toppings]") //setting up an overlay image
				foodoverlay.color = FOOD.food_color
				foodoverlay.layer = (src.layer+3)
				toppingdata.Add(FOOD.food_color)
				FOOD.reagents?.trans_to(roll,FOOD.reagents.total_volume)
				for(var/food_effect in FOOD.food_effects)
					if(food_effect in roll.food_effects)
						continue
					roll.food_effects += food_effect
					roll.quality += FOOD.quality
				src.UpdateOverlays(foodoverlay,"topping-[src.toppings]")
				user.u_equip(FOOD)
				qdel(FOOD)
			else if(!src.seaweed)
				boutput(user,"<span class='alert'>You need a seaweed sheet on the roller first, silly.</span>")
			else
				boutput(user,"<span class='alert'>You need sticky rice!</span>")
		else
			..()

	attack_hand(mob/user as mob)
		if(src.seaweed && src.rice)
			if(!src.toppings) //dependent on having toppings (empty sushi caused a lot of problems)
				..()
				return
			if(!src.rolled) //handling the rolling interactivity, basically switching overlays until eventually the item's overlays are wiped...
				src.rolling++
				if(src.toppings && (src.rolling<3))
					var/image/seaweed = new /image('icons/obj/foodNdrink/kitchen.dmi',"seaweed-[src.rolling]")
					var/image/rice = new /image('icons/obj/foodNdrink/kitchen.dmi',"rice-[src.rolling]")
					seaweed.layer = (src.layer+1)
					rice.layer = (src.layer+2)
					src.UpdateOverlays(seaweed,"seaweed")
					src.UpdateOverlays(rice,"rice")
					src.icon_state = "roller-[src.rolling]"
					for(var/i=1,i<=src.toppings,i++)
						if(src.GetOverlayImage("topping-[i]"))
							src.ClearSpecificOverlays("topping-[i]")
							break
					return
				if(src.rolling == 3)
					src.ClearAllOverlays()
					src.icon_state = "roller-[src.rolling]"
					return
				if(src.rolling > 3)
					src.rolling -= 2
					src.rolled = 1
					src.icon_state = "roller-[src.rolling]"
					src.UpdateOverlays(new /image('icons/obj/foodNdrink/kitchen.dmi',"roller_roll"),"roll")
					for(var/i=1,i<=src.toppings,i++)
						var/image/rolltopping = new /image('icons/obj/foodNdrink/kitchen.dmi',"roll_topping-[i]")
						rolltopping.color = toppingdata[i]
						src.UpdateOverlays(rolltopping,"roll_topping-[i]")
					src.rolling = 0
			else if(src.rolling == 0) //and out pops a sushi roll!
				src.icon_state = "roller-[src.rolling]"
				src.seaweed = 0
				src.rice = 0
				src.rolled = 0
				src.ClearAllOverlays()
				if(src.swedish) //setting actual overrides for sushi roll
					roll.UpdateOverlays(new /image('icons/obj/foodNdrink/food_sushi.dmi',"fisk"),"fisk")
				else if(src.fishflag) //fish overlays (there's two states, one for if the fish is the only ingredient, and one if there's other ingredients)
					roll.UpdateOverlays(new /image('icons/obj/foodNdrink/food_sushi.dmi',"[fishflag]-[src.toppings == 1 ? "s" : "m"]"),"[fishflag]")
				if(skip != "ALL") //in case of swedish fisk, that is the only overlay rendered, so everything else is skipped
					var/toppingoverlay = 0
					for(var/t,t<=toppingdata.len,t++)
						if(toppingdata[t] && (skip != t)) //its not the best way to do this, but im not sure if theres a decent way of dynamically referencing variables without a bunch of weird string conversions
							toppingoverlay++
							var/image/overlay = new /image('icons/obj/foodNdrink/food_sushi.dmi',"topping-[toppingoverlay]")
							overlay.color = toppingdata[t]
							roll.UpdateOverlays(overlay,"topping-[toppingoverlay]")
				if(src.toppings)
					roll.quality = (roll.quality/src.toppings)+1
				else
					roll.quality = 1
				user.put_in_hand_or_drop(roll)
				src.toppings = 0
				src.swedish = 0
				src.fish = 0
				src.toppingdata = list()
				src.fishflag = null
				src.skip = null
				src.roll = null
		else
			..()

/obj/item/fish/random // used by the Wholetuna Cordata plant
	New()
		..()
		SPAWN_DBG(0)
			var/fish = pick(/obj/item/fish/salmon,/obj/item/fish/carp,/obj/item/fish/bass)
			new fish(get_turf(src))
			qdel(src)


/obj/item/platestack
	name = "Stack of Plates"
	desc = "It's a stack of plates"
	icon = 'icons/obj/foodNdrink/platestack.dmi'
	inhand_image_icon = 'icons/obj/foodNdrink/platestackinhand.dmi'
	icon_state = "platestack1"
	item_state = "platestack1"
	w_class = W_CLASS_BULKY // why the fuck would you put a stack of plates in your backpack, also prevents shenanigans
	var/platenum = 1 // used for targeting icon_states

	var/platemax = 8


	proc/update_icon(mob/user as mob)
		src.icon_state = "platestack[src.platenum]"
		src.item_state = "platestack[src.platenum]"
		user.update_inhands()

	attackby(obj/item/weapon as obj,mob/user as mob)
		if(istype(weapon,/obj/item/plate) && !(istype(weapon,/obj/item/plate/tray)))
			var/obj/item/plate/p = weapon
			if(!p.ordered_contents.len)
				if(!(platenum >= platemax))
					src.platenum++
					src.update_icon(user)
					user.u_equip(p)
					qdel(p)
				else
					boutput(user,"<span class='alert'><b>The plates are piled too high!</b></span>")
					return
			else
				boutput(user,"<span class='alert'><b>You can't stack a plate with food on it, silly!</b></span>")
		else if(istype(weapon,/obj/item/platestack))
			var/obj/item/platestack/p = weapon
			var/keeptrigger = 0
			if(((src.platenum + (p.platenum+1)) > platemax) && (src.platenum != platemax))
				keeptrigger = 1
				p.platenum = (p.platenum - (platemax - src.platenum))
				p.update_icon(user)
				src.platenum = platemax
				src.update_icon(user)
			else if(src.platenum == platemax)
				boutput(user,"<span class='alert'><b>The plates are piled too high!</b></span>")
				return
			else
				src.platenum += (p.platenum+1)
				src.update_icon(user)
			if(keeptrigger != 1)
				user.u_equip(p)
				qdel(p)

	attack_hand(mob/user as mob)
		if(src in user.contents)
			platenum--
			src.update_icon(user)
			user.put_in_hand_or_drop(new /obj/item/plate)
			if(platenum <= 0)
				user.u_equip(src)
				user.put_in_hand_or_drop(new /obj/item/plate)
				qdel(src)
		else
			..()

	throw_impact(atom/A, datum/thrown_thing/thr)
		..()
		var/list/throw_targets = list()
		if(platenum == 0)
			return
		for(var/i=1,i<=platenum,i++)
			throw_targets += get_offset_target_turf(src.loc, rand(3)-rand(3), rand(3)-rand(3))
		platenum++
		while(platenum > 0)
			platenum--
			var/obj/item/plate/p = new /obj/item/plate
			p.set_loc(get_turf(src))
			p.throw_at(pick(throw_targets), 5, 1)
			p.pixel_y = rand(-8,8)
			p.pixel_x = rand(-8,8)
		qdel(src)

	attack_self(mob/user as mob)
		if(src.platenum > 1)
			src.platenum--
			src.update_icon(user)
			user.put_in_hand_or_drop(new /obj/item/plate)
		else if(src.platenum <= 1)
			user.u_equip(src)
			user.put_in_hand_or_drop(new /obj/item/plate)
			user.put_in_hand_or_drop(new /obj/item/plate)
			qdel(src)

	MouseDrop_T(atom/movable/a as mob|obj, mob/user as mob)
		if(istype(a, /obj/item/plate))
			if(src.platenum >= platemax)
				boutput(user,"<span class='alert'><b>The plates are piled too high!</b></span>")
				return
			SPAWN_DBG(0.2 SECONDS)
				var/message = 1
				for (var/obj/item/plate/p in range(1, user))
					if(p == src)
						continue
					if(istype(p,/obj/item/plate/tray))
						continue
					if(p in user.contents)
						continue
					if(message == 1)
						user.visible_message("<b>[user]</b> stacks some plates.",\
						"You stack some plates.")
						message = 0
					qdel(p)
					src.platenum++
					src.update_icon(user)
					if(src.platenum == platemax)
						break
					else
						sleep(0.2 SECONDS)
				return
		else
			return ..()

	proc/MouseDropRelay(var/obj/item/a,mob/user as mob)
		if(src.platenum >= platemax)
			boutput(user,"<span class='alert'><b>The plates are piled too high!</b></span>")
			return
		SPAWN_DBG(0.2 SECONDS)
			var/message = 1
			var/first = 1
			for (var/obj/item/plate/p in range(1, user))
				if(p == src)
					continue
				if(istype(p,/obj/item/plate/tray))
					continue
				if(p in user.contents)
					continue
				if(p.ordered_contents.len)
					continue
				if(message == 1)
					user.visible_message("<b>[user]</b> stacks some plates.",\
					"You stack some plates.")
					message = 0
				qdel(p)
				if(src.contents.len)
					src.contents -= a
				if(first)
					first = 0
					continue
				src.platenum++
				src.update_icon()
				if(src.platenum == platemax)
					break
				else
					sleep(0.2 SECONDS)
			return
