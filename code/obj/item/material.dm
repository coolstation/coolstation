/obj/item/raw_material/
	name = "construction materials"
	desc = "placeholder item!"
	icon = 'icons/obj/items/materials.dmi'
	force = 4
	throwforce = 6
	value = 70 //base commodity price
	burn_type = 1

	var/material_name = "Ore" //text to display for this ore in manufacturers
	var/initial_material_name = null // used to store what the ore is
	var/metal = 0  // what grade of metal is it?
	var/conductor = 0
	var/dense = 0
	var/crystal = 0
	var/powersource = 0
	var/scoopable = 1
	var/wiggle = 6 // how much we want the sprite to be deviated fron center

	max_stack = INFINITY
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER

	New()
		..()
		src.pixel_x = rand(0 - wiggle, wiggle)
		src.pixel_y = rand(0 - wiggle, wiggle)
		setup_material()
		if(src.material?.name)
			initial_material_name = src.material.name

	unpooled()
		..()
		src.pixel_x = rand(0 - wiggle, wiggle)
		src.pixel_y = rand(0 - wiggle, wiggle)
		setup_material()
/*
	pooled()
		..()
		name = initial(name)
*/
	proc/setup_material()
		.= 0

	update_stack_appearance()
		if(material)
			name = "[amount] [initial(src.name)][amount > 1 ? "s":""]"
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if(W.type == src.type)
			stack_item(W)
			if(!user.is_in_hands(src))
				user.put_in_hand(src)
			boutput(user, "<span class='notice'>You add the ores to the stack. It now has [src.amount] ores.</span>")
			return
		if (istype(W, /obj/item/satchel/mining/))
			var/obj/item/satchel/mining/satchel = W
			satchel.add_thing(src, user)
		else ..()

	attack_hand(mob/user as mob)
		if(user.is_in_hands(src) && src.amount > 1)
			var/splitnum = round(input("How many ores do you want to take from the stack?","Stack of [src.amount]",1) as num)
			if (splitnum >= amount || splitnum < 1)
				boutput(user, "<span class='alert'>Invalid entry, try again.</span>")
				return
			var/obj/item/raw_material/new_stack = split_stack(splitnum)
			user.put_in_hand_or_drop(new_stack)
			new_stack.add_fingerprint(user)
		else
			..(user)

	HasEntered(AM as mob|obj)
		if (isobserver(AM))
			return
		else if (isliving(AM))
			var/mob/living/H = AM
			var/obj/item/ore_scoop/S = H.get_equipped_ore_scoop()
			if (S?.satchel && src.scoopable)
				S.satchel.add_thing(src)
		else if (istype(AM,/obj/machinery/vehicle/))
			var/obj/machinery/vehicle/V = AM
			if (istype(V.sec_system,/obj/item/shipcomponent/secondary_system/orescoop))
				var/obj/item/shipcomponent/secondary_system/orescoop/SCOOP = V.sec_system
				if (SCOOP.contents.len >= SCOOP.capacity || !src.scoopable)
					return
				src.set_loc(SCOOP)
				if (SCOOP.contents.len >= SCOOP.capacity)
					boutput(V.pilot, "<span class='alert'>Your pod's ore scoop hold is full!</span>")
					playsound(V.loc, "sound/machines/chime.ogg", 20, 1)
			return
		else
			return

	MouseDrop(over_object, src_location, over_location) //src dragged onto over_object
		if (isobserver(usr))
			boutput(usr, "<span class='alert'>Quit that! You're dead!</span>")
			return

		if(!istype(over_object, /atom/movable/screen/hud))
			if (get_dist(usr,src) > 1)
				boutput(usr, "<span class='alert'>You're too far away from it to do that.</span>")
				return
			if (get_dist(usr,over_object) > 1)
				boutput(usr, "<span class='alert'>You're too far away from it to do that.</span>")
				return

		if(istype(over_object, /obj/machinery/power/furnace))
			return ..()

		if(istype(over_object, /obj/afterlife_donations))
			return ..()

		if (istype(over_object,/obj/item/raw_material)) //piece to piece, doesnt matter if in hand or not.
			var/obj/item/targetObject = over_object
			if(targetObject.stack_item(src))
				usr.visible_message("<span class='notice'>[usr.name] stacks \the [src]!</span>")
		else if(isturf(over_object)) //piece to turf. piece loc doesnt matter.
			if(src.amount > 1) //split stack.
				usr.visible_message("<span class='notice'>[usr.name] splits the stack of [src]!</span>")
				var/toSplit = round(amount / 2)
				var/atom/movable/splitStack = split_stack(toSplit)
				if(splitStack)
					splitStack.set_loc(over_object)
			else
				if(isturf(src.loc))
					src.set_loc(over_object)
				for(var/obj/item/I in view(1,usr))
					if (!I || I == src)
						continue
					if (!src.check_valid_stack(I))
						continue
					src.stack_item(I)
				usr.visible_message("<span class='notice'>[usr.name] stacks \the [src]!</span>")
		else if(istype(over_object, /atom/movable/screen/hud))
			var/atom/movable/screen/hud/H = over_object
			var/mob/living/carbon/human/dude = usr
			switch(H.id)
				if("lhand")
					if(dude.l_hand)
						if(dude.l_hand == src) return
						else if (istype(dude.l_hand, /obj/item/raw_material))
							var/obj/item/raw_material/DP = dude.l_hand
							DP.stack_item(src)
							usr.visible_message("<span class='notice'>[usr.name] stacks \the [DP]!</span>")
					else if(amount > 1)
						var/toSplit = round(amount / 2)
						var/atom/movable/splitStack = split_stack(toSplit)
						if(splitStack)
							usr.visible_message("<span class='notice'>[usr.name] splits the stack of [src]!</span>")
							splitStack.set_loc(dude)
							dude.put_in_hand(splitStack, 1)
				if("rhand")
					if(dude.r_hand)
						if(dude.r_hand == src) return
						else if (istype(dude.r_hand, /obj/item/raw_material))
							var/obj/item/raw_material/DP = dude.r_hand
							DP.stack_item(src)
							usr.visible_message("<span class='notice'>[usr.name] stacks \the [DP]!</span>")
					else if(amount > 1)
						var/toSplit = round(amount / 2)
						var/atom/movable/splitStack = split_stack(toSplit)
						if(splitStack)
							usr.visible_message("<span class='notice'>[usr.name] splits the stack of [src]!</span>")
							splitStack.set_loc(dude)
							dude.put_in_hand(splitStack, 0)
		else
			..()

/obj/item/raw_material/rock
	name = "rock"
	desc = "It's plain old space rock. Pretty worthless!"
	icon_state = "rock1"
	force = 8
	throwforce = 10
	scoopable = 0
	value = -1 //less than worthless, counts as trash (except for an override for Gragg)
	alt_value = 1 //but if you want to buy rocks I'm sure someone might sell that for a dollar

	setup_material()
		..()
		src.icon_state = pick("rock1","rock2","rock3")
		src.setMaterial(getMaterial("rock"), appearance = FALSE, setname = FALSE)

/obj/item/raw_material/rock/gehenna //what if we weren't mining gray all day down there
	name = "desert rock"
	desc = "It's plain old desert rock. Pretty worthless!"

	setup_material()
		..()
		src.icon_state = pick("geh-rock1","geh-rock2","geh-rock3")
		src.setMaterial(getMaterial("rock_gehenna"), appearance = FALSE, setname = FALSE)

/obj/item/raw_material/mauxite
	name = "mauxite ore"
	desc = "A chunk of Mauxite, a sturdy common metal."
	icon_state = "mauxite"
	material_name = "Mauxite"
	metal = 2
	value = 70 //base commodity price

	setup_material()
		src.setMaterial(getMaterial("mauxite"), appearance = FALSE, setname = FALSE)
		return ..()

/obj/item/raw_material/molitz
	name = "molitz crystal"
	desc = "A crystal of Molitz, a common crystalline substance."
	icon_state = "molitz"
	material_name = "Molitz"
	crystal = 1
	value = 70 //base commodity price

	setup_material()
		src.setMaterial(getMaterial("molitz"), appearance = FALSE, setname = FALSE)
		return ..()

/obj/item/raw_material/molitz_beta
	name = "molitz crystal"
	desc = "An unusual crystal of Molitz."
	icon_state = "molitz"
	material_name = "Molitz Beta"
	crystal = 1
	value = 300 //listen if it's rare then fuck it, crank it

	setup_material()
		src.setMaterial(getMaterial("molitz_b"), appearance = TRUE, setname = FALSE)
		return ..()

/obj/item/raw_material/pharosium
	name = "pharosium ore"
	desc = "A chunk of Pharosium, a conductive metal."
	icon_state = "pharosium"
	material_name = "Pharosium"
	metal = 1
	conductor = 1
	value = 70 //base commodity price

	setup_material()
		src.setMaterial(getMaterial("pharosium"), appearance = FALSE, setname = FALSE)
		return ..()

/obj/item/raw_material/cobryl // relate this to precursors
	name = "cobryl ore"
	desc = "A chunk of Cobryl, a somewhat valuable metal."
	icon_state = "cobryl"
	material_name = "Cobryl"
	metal = 1
	value = 200 //base commodity price

	setup_material()
		src.setMaterial(getMaterial("cobryl"), appearance = FALSE, setname = FALSE)
		return ..()

/obj/item/raw_material/char
	name = "char ore"
	desc = "A heap of Char, a fossil energy source similar to coal."
	icon_state = "char"
	material_name = "Char"
	//cogwerks - burn vars
	burn_point = 450
	burn_output = 1600
	burn_possible = TRUE
	health = 20
	value = 35 //base commodity price

	setup_material()
		src.setMaterial(getMaterial("char"), appearance = FALSE, setname = FALSE)
		return ..()

/obj/item/raw_material/claretine // relate this to wizardry somehow
	name = "claretine ore"
	desc = "A heap of Claretine, a highly conductive salt."
	icon_state = "claretine"
	material_name = "Claretine"
	conductor = 2
	value = 350 //base commodity price

	setup_material()
		src.setMaterial(getMaterial("claretine"), appearance = FALSE, setname = FALSE)
		return ..()

/obj/item/raw_material/bohrum
	name = "bohrum ore"
	desc = "A chunk of Bohrum, a heavy and highly durable metal."
	icon_state = "bohrum"
	material_name = "Bohrum"
	metal = 3
	dense = 1
	value = 350 //base commodity price

	setup_material()
		src.setMaterial(getMaterial("bohrum"), appearance = FALSE, setname = FALSE)
		return ..()

/obj/item/raw_material/syreline
	name = "syreline ore"
	desc = "A chunk of Syreline, an extremely valuable and coveted metal."
	icon_state = "syreline"
	material_name = "Syreline"
	metal = 1
	value = 800 //base commodity price

	setup_material()
		src.setMaterial(getMaterial("syreline"), appearance = FALSE, setname = FALSE)
		return ..()

/obj/item/raw_material/erebite
	name = "erebite ore"
	desc = "A chunk of Erebite, an extremely volatile high-energy mineral."
	icon_state = "erebite"
	var/exploded = 0
	material_name = "Erebite"
	powersource = 2
	value = 650 //base commodity price

	setup_material()
		src.setMaterial(getMaterial("erebite"), appearance = FALSE, setname = FALSE)
		return ..()

	ex_act(severity)
		if(exploded)
			return
		exploded = 1/*
		for(var/obj/item/raw_material/erebite/E in get_turf(src))
			if(E == src) continue
			qdel(E)

		for(var/obj/item/raw_material/erebite/E in range(4,src))
			if (E == src) continue
			qdel(E)*/

		switch(severity)
			if(OLD_EX_SEVERITY_1)
				explosion(src, src.loc, 1, 2, 3, 4, 1)
			if(OLD_EX_SEVERITY_2)
				explosion(src, src.loc, 0, 1, 2, 3, 1)
			if(OLD_EX_SEVERITY_3)
				explosion(src, src.loc, 0, 0, 1, 2, 1)
			else
				return
		// if not on mining z level
		if (src.z != MINING_Z)
			var/turf/bombturf = get_turf(src)
			if (bombturf)
				var/bombarea = bombturf.loc.name
				logTheThing("combat", null, null, "Erebite detonated by an explosion in [bombarea] ([showCoords(bombturf.x, bombturf.y, bombturf.z)]). Last touched by: [src.fingerprintslast]")
				message_admins("Erebite detonated by an explosion in [bombarea] ([showCoords(bombturf.x, bombturf.y, bombturf.z)]). Last touched by: [key_name(src.fingerprintslast)]")

		qdel(src)

	temperature_expose(null, temp, volume)

		explosion(src, src.loc, 1, 2, 3, 4, 1)

		// if not on mining z level
		if (src.z != MINING_Z)
			var/turf/bombturf = get_turf(src)
			var/bombarea = istype(bombturf) ? bombturf.loc.name : "a blank, featureless void populated only by your own abandoned dreams and wasted potential"

			logTheThing("combat", null, null, "Erebite detonated by heat in [bombarea]. Last touched by: [src.fingerprintslast]")
			message_admins("Erebite detonated by heat in [bombarea]. Last touched by: [key_name(src.fingerprintslast)]")

		qdel(src)

/obj/item/raw_material/cerenkite
	name = "cerenkite ore"
	desc = "A chunk of Cerenkite, a highly radioactive mineral."
	icon_state = "cerenkite"
	material_name = "Cerenkite"
	metal = 1
	powersource = 1
	value = 480 //base commodity price

	setup_material()
		src.setMaterial(getMaterial("cerenkite"), appearance = FALSE, setname = FALSE)
		return ..()

/obj/item/raw_material/plasmastone
	name = "plasmastone"
	desc = "A piece of plasma in its solid state."
	icon_state = "plasmastone"
	material_name = "Plasmastone"
	//cogwerks - burn vars
	burn_point = 1000
	burn_output = 10000
	burn_possible = TRUE
	health = 40
	powersource = 1
	crystal = 1
	value = 550 //base commodity price

	setup_material()
		src.setMaterial(getMaterial("plasmastone"), appearance = FALSE, setname = FALSE)
		return ..()

/obj/item/raw_material/gemstone
	name = "gem"
	desc = "A gemstone. It's definitely pretty valuable!"
	icon_state = "gem"
	material_name = "Gem"
	force = 1
	throwforce = 3
	crystal = 1
	value = 1000

	setup_material()
		..()
		var/picker = rand(1,100)
		var/list/picklist
		switch(picker)
			if(1 to 10)
				picklist = list("diamond","ruby","topaz","emerald","sapphire","amethyst")
				value = 1500
			if(11 to 40)
				picklist = list("jasper","garnet","peridot","malachite","lapislazuli","alexandrite")
			else
				picklist = list("onyx","rosequartz","citrine","jade","aquamarine","iolite")
				value = 500

		var/datum/material/M = getMaterial(pick(picklist))
		src.setMaterial(M, appearance = TRUE, setname = TRUE)// why was this set to not update the name/appearance??

/obj/item/raw_material/uqill // relate this to ancients
	name = "uqill nugget"
	desc = "A nugget of Uqill, a rare and very dense stone."
	icon_state = "uqill"
	material_name = "Uqill"
	dense = 2
	value = 750 //base commodity price

	setup_material()
		src.setMaterial(getMaterial("uqill"), appearance = FALSE, setname = FALSE)
		return ..()


/obj/item/raw_material/fibrilith
	name = "fibrilith chunk"
	desc = "A compressed chunk of Fibrilith, an odd mineral known for its high tensile strength."
	icon_state = "fibrilith"
	material_name = "Fibrilith"
	value = 25 //sure why not TODO: figure out relative costs for cotton etc.

	setup_material()
		src.setMaterial(getMaterial("fibrilith"), appearance = FALSE, setname = FALSE)
		return ..()

/obj/item/raw_material/telecrystal
	name = "telecrystal"
	desc = "A large unprocessed telecrystal, a gemstone with space-warping properties."
	icon_state = "telecrystal"
	material_name = "Telecrystal"
	crystal = 1
	powersource = 2
	value = 1000 //base commodity price

	setup_material()
		src.setMaterial(getMaterial("telecrystal"), appearance = FALSE, setname = FALSE)
		return ..()

	attack(mob/M as mob, mob/user as mob, def_zone)//spyguy apologizes in advance -- not somepotato i promise
		if(M == user)
			boutput(M, "<b class='alert'>You eat the [html_encode(src)]!</b>")
			boutput(M, "Nothing happens, though.")
			qdel(src)
		else if(istype(M))
			boutput(user, "<b class='alert'>You feed [html_encode(M)] the [html_encode(src)]!</b>")
			boutput(M, "<b class='alert'>[html_encode(user)] feeds you the [html_encode(src)]!</b>")
			boutput(M, "Nothing happens, though.")
			boutput(user, "Nothing happens, though.")
			qdel(src)
		else return ..()
		return
	var/emagged = 0
	emag_act()
		if(emagged) return
		src.visible_message( "<b class='notice'>\the [src] turns blue!</b>" )
		emagged = 1
		src.color = "#00f"
		name = "Blue Telecrystal"
		desc = "[desc] It's all shiny and blue now."


/obj/item/raw_material/miracle
	name = "miracle matter"
	desc = "Miracle Matter is a bizarre substance known to metamorphosise into other minerals when processed."
	icon_state = "miracle"
	material_name = "Miracle Matter"
	value = 400 //still give you a decent offer even if you can make more by changing it, i guess!

	setup_material()
		src.setMaterial(getMaterial("miracle"), appearance = FALSE, setname = FALSE)
		return ..()

/obj/item/raw_material/starstone
	name = "starstone"
	desc = "An extremely rare jewel. Highly prized by collectors and lithovores."
	icon_state = "starstone"
	material_name = "Starstone"
	crystal = 1
	//TODO: value (only gragg really pays a lot for it but it has ~unique properties~ that changed its utility away from purely moneymaking. come back to this later)

	setup_material()
		src.setMaterial(getMaterial("starstone"), appearance = FALSE, setname = FALSE)
		return ..()

/obj/item/raw_material/eldritch
	name = "koshmarite ore"
	desc = "An unusual dense pulsating stone. You feel uneasy just looking at it."
	icon_state = "eldritch"
	material_name = "Koshmarite"
	crystal = 1
	dense = 2
	value = 750 //base commodity price

	setup_material()
		src.setMaterial(getMaterial("koshmarite"), appearance = FALSE, setname = FALSE)
		return ..()

/obj/item/raw_material/martian
	name = "viscerite lump"
	desc = "A disgusting flesh-like material. Ugh. What the hell is this?"
	icon_state = "martian"
	material_name = "Viscerite"
	dense = 2
	value = 100 //base commodity price

	setup_material()
		src.setMaterial(getMaterial("viscerite"), appearance = FALSE, setname = FALSE)
		src.create_reagents(25)
		src.reagents.add_reagent("synthflesh", 25)
		return ..()

//handwave: actual gold is still rare and has unique properties, cobryl/syreline are similarly precious but actually common and don't do the same stuff, so they just look pretty
/obj/item/raw_material/gold
	name = "gold nugget"
	desc = "A chunk of pure gold. Damn son."
	icon_state = "gold"
	material_name = "Gold"
	dense = 2
	value = 3500 //base commodity price

	setup_material()
		src.setMaterial(getMaterial("gold"), appearance = FALSE, setname = FALSE)
		return ..()

// Misc building material

/obj/item/raw_material/fabric
	name = "fabric sheet"
	desc = "Some spun cloth. Useful if you want to make clothing."
	icon_state = "fabric"
	material_name = "Fabric"
	scoopable = 0
	value = 15 //seems fair

	setup_material()
		src.setMaterial(getMaterial("fibrilith"), appearance = FALSE, setname = FALSE)
		return ..()

/obj/item/raw_material/cotton/
	name = "cotton wad"
	desc = "It's a big puffy white thing. Most likely not a cloud though."
	icon_state = "cotton"
	value = 10 //seems fair

	setup_material()
		src.setMaterial(getMaterial("cotton"), appearance = FALSE, setname = FALSE)
		return ..()

/obj/item/raw_material/ice
	name = "ice chunk"
	desc = "A chunk of ice. It's pretty cold."
	icon_state = "ice"
	material_name = "Ice"
	crystal = 1
	scoopable = 0
	value = 0 //don't get anything for it, don't get anything against for it. (market event: ice shortage for a BIG PARTY might put this on the map)

	setup_material()
		src.setMaterial(getMaterial("ice"), appearance = FALSE, setname = FALSE)
		return ..()

/obj/item/raw_material/scrap_metal
	// this should only be spawned by the game, spawning it otherwise would just be dumb
	name = "scrap"
	desc = "Some twisted and ruined metal. It could probably be smelted down into something more useful."
	icon_state = "scrap"
	burn_possible = FALSE
	value = 10

	New()
		..()
		icon_state += "[rand(1,5)]"

/obj/item/raw_material/shard
	// same deal here
	name = "shard"
	desc = "A jagged piece of broken crystal or glass. It could probably be smelted down into something more useful."
	icon_state = "shard"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "shard-glass"
	flags = TABLEPASS | FPRINT
	tool_flags = TOOL_CUTTING
	w_class = W_CLASS_NORMAL
	hit_type = DAMAGE_CUT
	hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
	force = 5.0
	throwforce = 5.0
	g_amt = 3750
	burn_type = 1
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 35
	burn_possible = FALSE
	value = 5
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER
	var/sound_stepped = 'sound/impact_sounds/Glass_Shards_Hit_1.ogg'

	New()
		..()
		icon_state += "[rand(1,3)]"
		src.setItemSpecial(/datum/item_special/double)
/*
	unpooled()
		. = ..()
		src.setItemSpecial(/datum/item_special/double)
*/
	attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
		if(!scalpel_surgery(M,user)) return ..()
		else return

	HasEntered(AM as mob|obj)
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			if(H.getStatusDuration("stunned") || H.getStatusDuration("weakened")) // nerf for dragging a person and a shard to damage them absurdly fast - drsingh
				return
			playsound(src.loc, src.sound_stepped, 50, 1)
			if(isabomination(H))
				return
			if(H.throwing || HAS_MOB_PROPERTY(H, PROP_ATOM_FLOATING))
				return
			if(H.lying)
				boutput(H, "<span class='alert'><B>You crawl on [src]! Ouch!</B></span>")
				step_on(H)
			else
				//Can't step on stuff if you have no legs, and it can't hurt if they're robolegs.
				if (!istype(H.limbs.l_leg, /obj/item/parts/human_parts) && !istype(H.limbs.r_leg, /obj/item/parts/human_parts))
					return
				if((!H.shoes || (src.material && src.material.hasProperty("hard") && src.material.getProperty("hard") >= 70)) && !iscow(H))
					boutput(H, "<span class='alert'><B>You step on [src]! Ouch!</B></span>")
					step_on(H)
		..()

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] slashes [his_or_her(user)] own throat with [src]!</b></span>")
		blood_slash(user, 25)
		user.TakeDamage("head", 150, 0)
		SPAWN_DBG(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	glass
		setup_material()
			..()
			src.setMaterial(getMaterial("glass"), appearance = TRUE, setname = TRUE) // why were these set to 0 and 0, why would you use a glass shard to make some other kind of materialed thing when you could just use the base /obj/item/raw_material/shard

	plasmacrystal
		setup_material()
			..()
			src.setMaterial(getMaterial("plasmaglass"), appearance = TRUE, setname = TRUE)

/obj/item/raw_material/shard/proc/step_on(mob/living/carbon/human/H as mob)
	#ifdef DATALOGGER
	game_stats.Increment("workplacesafety")
	#endif
	H.changeStatus("weakened", 3 SECONDS)
	H.force_laydown_standup()
	var/obj/item/affecting = H.organs[pick("l_leg", "r_leg")]
	affecting.take_damage(force, 0)
	H.UpdateDamageIcon()


/obj/item/raw_material/chitin
	name = "chitin chunk"
	desc = "A chunk of chitin."
	icon_state = "chitin"
	material_name = "Chitin"
	metal = 3
	dense = 1
	value = 10 //oh, sending us your bug trash huh

	setup_material()
		src.setMaterial(getMaterial("chitin"), appearance = FALSE, setname = FALSE)
		return ..()

// bars, tied into the new material system

/obj/item/material_piece/mauxite
	desc = "A processed bar of Mauxite, a sturdy common metal."
	default_material = "mauxite"
	icon_state = "mauxite-bar"
	value = 100 //more than raw

/obj/item/material_piece/molitz
	desc = "A cut block of Molitz, a common crystalline substance."
	default_material = "molitz"
	icon_state = "molitz-bar"
	value = 100 //more than raw

/obj/item/material_piece/pharosium
	desc = "A processed bar of Pharosium, a conductive metal."
	default_material = "pharosium"
	icon_state = "pharosium-bar"
	value = 100 //more than raw

/obj/item/material_piece/cobryl
	desc = "A processed bar of Cobryl, a somewhat valuable metal."
	default_material = "cobryl"
	icon_state = "cobryl-bar"
	value = 300 //more than raw, it's just fancy blue space silver

/obj/item/material_piece/claretine
	desc = "A compressed Claretine, a highly conductive salt."
	default_material = "claretine"
	icon_state = "claretine-bar"
	value = 100 //more than raw

/obj/item/material_piece/bohrum
	desc = "A processed bar of Bohrum, a heavy and highly durable metal."
	default_material = "bohrum"
	icon_state = "bohrum-bar"
	value = 250 //processed and ready for use

/obj/item/material_piece/syreline
	desc = "A processed bar of Syreline, an extremely valuable and coveted metal."
	default_material = "syreline"
	icon_state = "syreline-bar"
	value = 1000 //more than raw, it's just fancy yellow space platinum

/obj/item/material_piece/plasmastone
	desc = "A cut block of Plasmastone."
	default_material = "plasmastone"
	icon_state = "plasmastone-bar"
	value = 750 //shaped and purified? yeah makes sense to me for a boost


/obj/item/material_piece/uqill
	desc = "A cut block of Uqill. It is quite heavy."
	default_material = "uqill"
	icon_state = "uqill-bar"
	value = 1000 //slightly better price

/obj/item/material_piece/koshmarite
	desc = "A cut block of an unusual dense stone. It seems similar to obsidian."
	default_material = "koshmarite"
	icon_state = "eldritch-bar"
	value = 120 //slightly better price

/obj/item/material_piece/viscerite
	desc = "A cut block of a disgusting flesh-like material. Grody."
	default_material = "viscerite"
	icon_state = "martian-bar"
	value = 100 //same amount, different shape, it's just goop

/obj/item/material_piece/char
	desc = "A cut block of Char."
	default_material = "char"
	icon_state = "wad"
	color = "#221122"
	value = 50 //processed for better incineration? maybe make this a bonus for furnaces

/obj/item/material_piece/telecrystal
	desc = "A cut block of Telecrystal."
	default_material = "telecrystal"
	icon_state = "martian-bar" //excuse me
	value = 1000 //for now, i feel like it'd take a lot of telecrystal to make a whole bar, maybe. and that it's not particularly worth anything until inscribed or whatever.

/obj/item/material_piece/fibrilith
	desc = "A cut block of Fibrilith."
	default_material = "fibrilith"
	icon_state = "martian-bar"
	value = 40 //more than raw

/obj/item/material_piece/cerenkite
	desc = "A cut block of Cerenkite."
	default_material = "cerenkite"
	icon_state = "martian-bar"
	value = 650 //more than raw

/obj/item/material_piece/erebite
	desc = "A cut block of Erebite."
	default_material = "erebite"
	icon_state = "martian-bar"
	value = 850 //more than raw

/obj/item/material_piece/gold
	name = "stamped bullion"
	desc = "Oh wow! This stuff's got to be worth a lot of money!"
	default_material = "gold"
	value = 35000 //base commodity price

/obj/item/material_piece/ice
	desc = "Uh. What's the point in this? Is someone planning to make an igloo?"
	default_material = "ice"
	value = 0
	alt_value = 50

// Material-related Machinery

/obj/machinery/portable_reclaimer
	name = "portable reclaimer"
	desc = "A sophisticated piece of machinery that quickly processes minerals into bars."
	icon = 'icons/obj/scrap.dmi'
	icon_state = "reclaimer"
	anchored = 0
	density = 1
	event_handler_flags = NO_MOUSEDROP_QOL
	var/active = 0
	var/reject = 0
	var/insufficient = 0
	var/smelt_interval = 5
	var/sound/sound_load = sound('sound/items/Deconstruct.ogg')
	var/sound/sound_process = sound('sound/effects/pop.ogg')
	var/sound/sound_grump = sound('sound/machines/buzz-two.ogg')
	var/atom/output_location = null

	attack_hand(var/mob/user as mob)
		if (active)
			boutput(user, "<span class='alert'>It's already working! Give it a moment!</span>")
			return
		if (src.contents.len < 1)
			boutput(user, "<span class='alert'>There's nothing inside to reclaim.</span>")
			return
		user.visible_message("<b>[user.name]</b> switches on [src].")
		active = 1
		anchored = 1
		icon_state = "reclaimer-on"

		for (var/obj/item/M in src.contents)
			if (istype(M, /obj/item/wizard_crystal))
				var/obj/item/wizard_crystal/wc = M
				wc.setMaterial(getMaterial(wc.assoc_material),0,0,1,0)

			if (!istype(M.material))
				M.set_loc(src.loc)
				src.reject = 1
				continue

			else if (istype(M, /obj/item/raw_material/shard))
				if (output_bar_from_item(M, 10))
					qdel(M)

			else if (istype(M, /obj/item/raw_material))
				output_bar_from_item(M)
				qdel(M)

			else if (istype(M, /obj/item/sheet))
				if (output_bar_from_item(M, 10))
					qdel(M)

			else if (istype(M, /obj/item/rods))
				if (output_bar_from_item(M, 20))
					qdel(M)

			else if (istype(M, /obj/item/tile))
				if (output_bar_from_item(M, 40))
					qdel(M)

			else if (istype(M, /obj/item/cable_coil))
				var/obj/item/cable_coil/C = M
				if (output_bar_from_item(M, 30, C.conductor.mat_id))
					qdel(C)

			else if (istype(M, /obj/item/scrap))
				output_bar_from_item(M, 10)
				qdel(M)

			else if (istype(M, /obj/item/wizard_crystal))
				if (output_bar_from_item(M))
					qdel(M)

			sleep(smelt_interval)

		if (reject)
			src.reject = 0
			src.visible_message("<b>[src]</b> emits an angry buzz and rejects some unsuitable materials!")
			playsound(src.loc, sound_grump, 40, 1)

		if (insufficient)
			src.insufficient = 0
			src.visible_message("<b>[src]</b> emits a grumpy buzz and ejects some leftovers.")
			playsound(src.loc, sound_grump, 40, 1)

		active = 0
		anchored = 0
		icon_state = "reclaimer"
		src.visible_message("<b>[src]</b> finishes working and shuts down.")

	proc/output_bar_from_item(obj/item/O, var/amount_modifier = 1, var/extra_mat)
		if (!O || !O.material)
			return

		var/stack_amount = O.amount
		if (amount_modifier)
			var/divide = O.amount / amount_modifier
			stack_amount = round(divide)
			if (stack_amount != divide)
				src.insufficient = 1
				O.change_stack_amount(-stack_amount * amount_modifier)
				O.set_loc(src.loc)
				if (!stack_amount)
					return
			else
				. = 1

		output_bar(O.material, stack_amount, O.quality)
		if (extra_mat)
			output_bar(extra_mat, stack_amount, O.quality)

	proc/output_bar(material, amount, quality)

		var/datum/material/MAT = material
		if (!istype(MAT))
			MAT = getMaterial(material)
			if (!MAT)
				return

		var/output_location = src.get_output_location()

		var/bar_type = getProcessedMaterialForm(MAT)
		var/obj/item/material_piece/BAR = new bar_type()
		BAR.quality = quality
		BAR.name += getQualityName(quality)
		BAR.setMaterial(MAT)
		BAR.change_stack_amount(amount - 1)

		if (istype(output_location, /obj/machinery/manufacturer))
			var/obj/machinery/manufacturer/M = output_location
			M.load_item(BAR)
		else
			BAR.set_loc(output_location)

		playsound(src.loc, sound_process, 40, 1)

	proc/load_reclaim(obj/item/W as obj, mob/user as mob)
		. = FALSE
		if (istype(W,/obj/item/raw_material/) || istype(W,/obj/item/sheet/) || istype(W,/obj/item/rods/) || istype(W,/obj/item/tile/) || istype(W,/obj/item/cable_coil) || istype(W,/obj/item/wizard_crystal))
			W.set_loc(src)
			if (user) user.u_equip(W)
			W.dropped()
			. = TRUE

	attackby(obj/item/W as obj, mob/user as mob)
		if (W.cant_drop) //For borg held items
			boutput(user, "<span class='alert'>You can't put that in [src] when it's attached to you!</span>")
			return ..()
		if (istype(W,/obj/item/storage/) || istype(W,/obj/item/satchel/))
			var/obj/item/storage/S = W
			var/obj/item/satchel/B = W
			var/items = W
			if(istype(S))
				items = S.get_contents()
			for(var/obj/item/O in items)
				if (load_reclaim(O))
					. = TRUE
					if (istype(S))
						S.hud.remove_object(O)
					else
						B.curitems -= O.amount
			if (istype(B) && .)
				B.satchel_updateicon()
			//Users loading individual items would make an annoying amount of messages
			//But loading a container is more noticable and there should be less
			if (.)
				user.visible_message("<b>[user.name]</b> loads [W] into [src].")
				playsound(src, sound_load, 40, 1)

		else if (load_reclaim(W, user))
			boutput(user, "You load [W] into [src].")
			playsound(src, sound_load, 40, 1)

		else
			. = ..()

	MouseDrop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, "<span class='alert'>Get your filthy dead fingers off that!</span>")
			return

		if(over_object == src)
			output_location = null
			boutput(usr, "<span class='notice'>You reset the reclaimer's output target.</span>")
			return

		if(get_dist(over_object,src) > 1)
			boutput(usr, "<span class='alert'>The reclaimer is too far away from the target!</span>")
			return

		if(get_dist(over_object,usr) > 1)
			boutput(usr, "<span class='alert'>You are too far away from the target!</span>")
			return

		if (istype(over_object,/obj/storage/crate/))
			var/obj/storage/crate/C = over_object
			if (C.locked || C.welded)
				boutput(usr, "<span class='alert'>You can't use a currently unopenable crate as an output target.</span>")
			else
				src.output_location = over_object
				boutput(usr, "<span class='notice'>You set the reclaimer to output to [over_object]!</span>")

		else if (istype(over_object,/obj/storage/cart/))
			var/obj/storage/cart/C = over_object
			if (C.locked || C.welded)
				boutput(usr, "<span class='alert'>You can't use a currently unopenable cart as an output target.</span>")
			else
				src.output_location = over_object
				boutput(usr, "<span class='notice'>You set the reclaimer to output to [over_object]!</span>")

		else if (istype(over_object,/obj/machinery/manufacturer/))
			var/obj/machinery/manufacturer/M = over_object
			if (M.status & BROKEN || M.status & NOPOWER || M.dismantle_stage > 0)
				boutput(usr, "<span class='alert'>You can't use a non-functioning manufacturer as an output target.</span>")
			else
				src.output_location = M
				boutput(usr, "<span class='notice'>You set the reclaimer to output to [over_object]!</span>")

		else if (istype(over_object,/obj/table/) && istype(over_object,/obj/rack/))
			var/obj/O = over_object
			src.output_location = O.loc
			boutput(usr, "<span class='notice'>You set the reclaimer to output on top of [O]!</span>")

		else if (istype(over_object,/turf/floor/))
			src.output_location = over_object
			boutput(usr, "<span class='notice'>You set the reclaimer to output to [over_object]!</span>")

		else
			boutput(usr, "<span class='alert'>You can't use that as an output target.</span>")
		return

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!O || !user)
			return

		if(!isliving(user))
			boutput(user, "<span class='alert'>Only living mobs are able to use the reclaimer's quick-load feature.</span>")
			return

		if (!isobj(O))
			boutput(user, "<span class='alert'>You can't quick-load that.</span>")
			return

		if(!IN_RANGE(O, user, 1))
			boutput(user, "<span class='alert'>You are too far away!</span>")
			return

		if (istype(O, /obj/storage/crate/) || istype(O, /obj/storage/cart/))
			user.visible_message("<span class='notice'>[user] uses [src]'s automatic loader on [O]!</span>", "<span class='notice'>You use [src]'s automatic loader on [O].</span>")
			var/amtload = 0
			for (var/obj/item/raw_material/M in O.contents)
				M.set_loc(src)
				amtload++
			if (amtload) boutput(user, "<span class='notice'>[amtload] materials loaded from [O]!</span>")
			else boutput(user, "<span class='alert'>No material loaded!</span>")

		else if (istype(O, /obj/item/raw_material/) || istype(O, /obj/item/sheet/) || istype(O, /obj/item/rods/) || istype(O, /obj/item/tile/) || istype(O, /obj/item/cable_coil))
			quickload(user,O)
		else
			..()

	proc/quickload(var/mob/living/user,var/obj/item/O)
		if (!user || !O)
			return
		user.visible_message("<span class='notice'>[user] begins quickly stuffing [O] into [src]!</span>")
		var/staystill = user.loc
		for(var/obj/item/M in view(1,user))
			if (!M || M.loc == user)
				continue
			if (M.name != O.name)
				continue
			if(!istype(M, /obj/item/cable_coil))
				if (!istype(M.material))
					continue
				if (!(M.material.material_flags & MATERIAL_CRYSTAL) && !(M.material.material_flags & MATERIAL_METAL))
					continue

			M.set_loc(src)
			playsound(src, sound_load, 40, 1)
			sleep(0.5)
			if (user.loc != staystill) break
		boutput(user, "<span class='notice'>You finish stuffing [O] into [src]!</span>")
		return

	proc/get_output_location()
		if (!output_location)
			return src.loc

		if (!IN_RANGE(src.output_location, src, 1))
			output_location = null
			return src.loc

		if (istype(output_location,/obj/machinery/manufacturer))
			var/obj/machinery/manufacturer/M = output_location
			if (M.status & NOPOWER || M.status & BROKEN | M.dismantle_stage > 0)
				return M.loc
			return M

		if (istype(output_location,/obj/storage))
			var/obj/storage/S = output_location
			if (S.locked || S.welded || S.open)
				return S.loc
			return S

		return output_location
