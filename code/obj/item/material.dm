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
	var/scoopable = 1
	var/default_material = "rock"
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
		src.setMaterial(getMaterial(src.default_material), appearance = FALSE, setname = FALSE)
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
	default_material = "rock"
	force = 8
	throwforce = 10
	scoopable = 0
	value = -1 //less than worthless, counts as trash (except for an override for Gragg)
	alt_value = 1 //but if you want to buy rocks I'm sure someone might sell that for a dollar

	setup_material()
		..()
		src.icon_state = pick("rock1","rock2","rock3")

/obj/item/raw_material/rock/gehenna //what if we weren't mining gray all day down there
	name = "desert rock"
	desc = "It's plain old desert rock. Pretty worthless!"
	default_material = "rock_gehenna"

	setup_material()
		..()
		src.icon_state = pick("geh-rock1","geh-rock2","geh-rock3")

/obj/item/raw_material/mauxite
	name = "mauxite ore"
	desc = "A chunk of Mauxite, a sturdy common metal."
	icon_state = "mauxite"
	default_material = "mauxite"
	material_name = "Mauxite"
	value = 70 //base commodity price

/obj/item/raw_material/molitz
	name = "molitz crystal"
	desc = "A crystal of Molitz, a common crystalline substance."
	icon_state = "molitz"
	default_material = "molitz"
	material_name = "Molitz"
	value = 70 //base commodity price

/obj/item/raw_material/molitz_beta
	name = "molitz crystal"
	desc = "An unusual crystal of Molitz."
	icon_state = "molitz"
	default_material = "molitz_b"
	material_name = "Molitz Beta"
	value = 300 //listen if it's rare then fuck it, crank it

/obj/item/raw_material/pharosium
	name = "pharosium ore"
	desc = "A chunk of Pharosium, a conductive metal."
	icon_state = "pharosium"
	default_material = "pharosium"
	material_name = "Pharosium"
	value = 70 //base commodity price

/obj/item/raw_material/cobryl // relate this to precursors
	name = "cobryl ore"
	desc = "A chunk of Cobryl, a somewhat valuable metal."
	icon_state = "cobryl"
	default_material = "cobryl"
	material_name = "Cobryl"
	value = 200 //base commodity price

/obj/item/raw_material/char
	name = "char ore"
	desc = "A heap of Char, a fossil energy source similar to coal."
	icon_state = "char"
	default_material = "char"
	material_name = "Char"
	//cogwerks - burn vars
	burn_point = 450
	burn_output = 1600
	burn_possible = TRUE
	health = 20
	value = 35 //base commodity price

/obj/item/raw_material/claretine // relate this to wizardry somehow
	name = "claretine ore"
	desc = "A heap of Claretine, a highly conductive salt."
	icon_state = "claretine"
	default_material = "claretine"
	material_name = "Claretine"
	value = 350 //base commodity price

/obj/item/raw_material/bohrum
	name = "bohrum ore"
	desc = "A chunk of Bohrum, a heavy and highly durable metal."
	icon_state = "bohrum"
	default_material = "bohrum"
	material_name = "Bohrum"
	value = 350 //base commodity price

	setup_material()
		src.setMaterial(getMaterial("bohrum"), appearance = FALSE, setname = FALSE)
		return ..()

/obj/item/raw_material/syreline
	name = "syreline ore"
	desc = "A chunk of Syreline, an extremely valuable and coveted metal."
	icon_state = "syreline"
	default_material = "syreline"
	material_name = "Syreline"
	value = 800 //base commodity price

/obj/item/raw_material/erebite
	name = "erebite ore"
	desc = "A chunk of Erebite, an extremely volatile high-energy mineral."
	icon_state = "erebite"
	default_material = "erebite"
	var/exploded = 0
	material_name = "Erebite"
	value = 650 //base commodity price

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
	default_material = "cerenkite"
	material_name = "Cerenkite"
	value = 480 //base commodity price

/obj/item/raw_material/plasmastone
	name = "plasmastone"
	desc = "A piece of plasma in its solid state."
	icon_state = "plasmastone"
	default_material = "plasmastone"
	material_name = "Plasmastone"
	//cogwerks - burn vars
	burn_point = 1000
	burn_output = 10000
	burn_possible = TRUE
	health = 40
	value = 550 //base commodity price

/obj/item/raw_material/gemstone
	name = "gem"
	desc = "A gemstone. It's definitely pretty valuable!"
	icon_state = "gem"
	default_material = "onyx"
	material_name = "Gem"
	force = 1
	throwforce = 3
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
	default_material = "uqill"
	material_name = "Uqill"
	value = 750 //base commodity price

/obj/item/raw_material/fibrilith
	name = "fibrilith chunk"
	desc = "A compressed chunk of Fibrilith, an odd mineral known for its high tensile strength."
	icon_state = "fibrilith"
	default_material = "fibrilith"
	material_name = "Fibrilith"
	value = 25 //sure why not TODO: figure out relative costs for cotton etc.

/obj/item/raw_material/telecrystal
	name = "telecrystal"
	desc = "A large unprocessed telecrystal, a gemstone with space-warping properties."
	icon_state = "telecrystal"
	default_material = "telecrystal"
	material_name = "Telecrystal"
	value = 1000 //base commodity price

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
	default_material = "miracle"
	material_name = "Miracle Matter"
	value = 400 //still give you a decent offer even if you can make more by changing it, i guess!

/obj/item/raw_material/starstone
	name = "starstone"
	desc = "An extremely rare jewel. Highly prized by collectors and lithovores."
	icon_state = "starstone"
	default_material = "starstone"
	material_name = "Starstone"
	//TODO: value (only gragg really pays a lot for it but it has ~unique properties~ that changed its utility away from purely moneymaking. come back to this later)

/obj/item/raw_material/eldritch
	name = "koshmarite ore"
	desc = "An unusual dense pulsating stone. You feel uneasy just looking at it."
	icon_state = "eldritch"
	default_material = "koshmarite"
	material_name = "Koshmarite"
	value = 750 //base commodity price

/obj/item/raw_material/martian
	name = "viscerite lump"
	desc = "A disgusting flesh-like material. Ugh. What the hell is this?"
	icon_state = "martian"
	default_material = "viscerite"
	material_name = "Viscerite"
	value = 100 //base commodity price

	setup_material()
		src.create_reagents(25)
		src.reagents.add_reagent("synthflesh", 25)
		return ..()

//handwave: actual gold is still rare and has unique properties, cobryl/syreline are similarly precious but actually common and don't do the same stuff, so they just look pretty
/obj/item/raw_material/gold
	name = "gold nugget"
	desc = "A chunk of pure gold. Damn son."
	icon_state = "gold"
	material_name = "Gold"
	value = 3500 //base commodity price

// Misc building material

/obj/item/raw_material/fabric
	name = "fibrilith sheet"
	desc = "Some spun fibrilith. Useful if you want to make clothing."
	icon_state = "fabric"
	default_material = "fibrilith"
	material_name = "Fibrilith"
	scoopable = 0
	value = 15 //seems fair

/obj/item/raw_material/cotton/
	name = "cotton wad"
	desc = "It's a big puffy white thing. Most likely not a cloud though."
	icon_state = "cotton"
	default_material = "cotton"
	value = 10 //seems fair

/obj/item/raw_material/ice
	name = "ice chunk"
	desc = "A chunk of ice. It's pretty cold."
	icon_state = "ice"
	default_material = "ice"
	material_name = "Ice"
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
	default_material = "chitin"
	material_name = "Chitin"
	value = 10 //oh, sending us your bug trash huh

// bars, tied into the new material system

/// Processed material piece
/obj/item/material_piece
	//weird name for an ingot but whatever. let's call this a bundle of 25 units.
	name = "bar"
	desc = "Some sort of processed material bar."
	icon = 'icons/obj/items/materials.dmi'
	icon_state = "bar"
	max_stack = INFINITY
	stack_type = /obj/item/material_piece
	value = 70 //base commodity price
	/// required to get the material right
	var/default_material = null

	New()
		..()
		setup_material()
/*
	unpooled()
		..()
		if (istext(default_material))
			var/datum/material/M = getMaterial(default_material)
			src.setMaterial(M)
		setup_material()

	pooled()
		..()
*/
	proc/setup_material()
		src.setMaterial(getMaterial(src.default_material), appearance = TRUE, setname = FALSE)
		.=0

	update_stack_appearance()
		if(material)
			name = "[amount] [initial(src.name)][amount > 1 ? "s":""]"
		return

	split_stack(var/toRemove)
		if(toRemove >= amount || toRemove < 1) return 0
		var/obj/item/material_piece/P = new src.type()
		P.set_loc(src.loc)
		P.setMaterial(src.material, TRUE, FALSE)
		src.change_stack_amount(-toRemove)
		P.change_stack_amount(toRemove - P.amount)
		return P

	attack_hand(mob/user as mob)
		if(user.is_in_hands(src) && src.amount > 1)
			var/splitnum = round(input("How many material pieces do you want to take from the stack?","Stack of [src.amount]",1) as num)
			if (splitnum >= amount || splitnum < 1)
				boutput(user, "<span class='alert'>Invalid entry, try again.</span>")
				return
			var/obj/item/material_piece/new_stack = split_stack(splitnum)
			user.put_in_hand_or_drop(new_stack)
			new_stack.add_fingerprint(user)
		else
			..(user)

	attackby(obj/item/W, mob/user)
		if(W.type == src.type)
			stack_item(W)
			if(!user.is_in_hands(src))
				user.put_in_hand(src)
			boutput(user, "<span class='notice'>You add the material to the stack. It now has [src.amount] pieces.</span>")

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

		if (istype(over_object,/obj/item/material_piece)) //piece to piece, doesnt matter if in hand or not.
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
						else if (istype(dude.l_hand, /obj/item/material_piece))
							var/obj/item/material_piece/DP = dude.l_hand
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
						else if (istype(dude.r_hand, /obj/item/material_piece))
							var/obj/item/material_piece/DP = dude.r_hand
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

	cloth
		// fabric
		icon_state = "fabric"
		name = "fabric"
		desc = "A weave of some kind."
		var/in_use = 0

		attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
			if (user.a_intent == INTENT_GRAB)
				return ..()
			if (src.in_use)
				return ..()
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				var/zone = user.zone_sel.selecting
				var/surgery_status = H.get_surgery_status(zone)
				if (surgery_status && H.organHolder)
					actions.start(new /datum/action/bar/icon/medical_suture_bandage(H, src, 15, zone, surgery_status, rand(1,4), "bandag"), user)
					src.in_use = 1
				else if (H.bleeding)
					actions.start(new /datum/action/bar/icon/medical_suture_bandage(H, src, 20, zone, 0, rand(2,4), "bandag"), user)
					src.in_use = 1
				else
					user.show_text("[H == user ? "You have" : "[H] has"] no wounds or incisions on [H == user ? "your" : his_or_her(H)] [zone_sel2name[zone]] to bandage!", "red")
					src.in_use = 0
					return
			else
				return ..()

		afterattack(turf/A, mob/user)
			if(locate(/obj/decal/poster/banner, A))
				return
			else if(istype(A, /turf/wall/))
				var/obj/decal/poster/banner/B = new(A)
				if (src.material) B.setMaterial(src.material, TRUE, TRUE)
				logTheThing("station", user, null, "Hangs up a banner (<b>Material:</b> [B.material && B.material.mat_id ? "[B.material.mat_id]" : "*UNKNOWN*"]) in [A] at [log_loc(user)].")
				src.change_stack_amount(-1)
				user.visible_message("<span class='notice'>[user] hangs up a [B.name] in [A]!.</span>", "<span class='notice'>You hang up a [B.name] in [A]!</span>")

/obj/item/material_piece/wad // LOAD BEARING WAD!? SERIOUSLY!?
	// organic
	icon_state = "wad"
	name = "clump"
	desc = "A clump of some kind of material."

/obj/item/material_piece/frozenfart
	icon_state = "fart"
	name = "frozen fart"
	desc = "Remarkable! The cold temperatures in the freezer have frozen the fart in mid-air."
	default_material = "frozenfart"
	amount = 5
	value = -10
	alt_value = 50

/obj/item/material_piece/rock
	name = "rock brick"
	desc = "A processed brick of rock, a common material."
	default_material = "rock"
	value = -1

/obj/item/material_piece/rock/gehenna
	name = "gehennan rock brick"
	desc = "A processed brick of sulfurous rock, a common material."
	default_material = "rock_gehenna"
	value = -1

/obj/item/material_piece/steel
	name = "steel bar"
	desc = "A processed bar of steel, a common alloy."
	default_material = "steel"
	value = 100 //legacy iron carbon earth material

/obj/item/material_piece/electrum
	name = "electrum bar"
	desc = "A processed bar of electrum, a rare alloy."
	default_material = "electrum"
	value = 2000 //this stuffs useful

/obj/item/material_piece/hamburgris
	name = "hamburgris clump"
	desc = "A big clump of petrified mince, with a horriffic smell."
	default_material = "hamburgris"
	icon_state = "slag"
	value = -500 //horrifying
	alt_value = 5000

/obj/item/material_piece/glass
	name = "glass block"
	desc = "A cut block of glass, a common crystalline substance."
	default_material = "glass"
	icon_state = "block"
	value = 100 //legacy silica earth material

/obj/item/material_piece/silver
	name = "silver bar"
	desc = "A processed bar of silver, a lustrous metal."
	default_material = "silver"
	value = 500 //legacy earth material

/obj/item/material_piece/copper
	name = "copper bar"
	desc = "A processed bar of copper, a conductive metal."
	default_material = "copper"
	value = 100 //legacy earth material

/obj/item/material_piece/iridiumalloy
	icon_state = "iridium"
	name = "iridium alloy plate"
	desc = "A chunk of some sort of iridium alloy plating."
	default_material = "iridiumalloy"
	amount = 5
	value = 1000 //seems cool

/obj/item/material_piece/spacelag
	icon_state = "spacelag"
	name = "spacelag bar"
	desc = "Yep. There it is. You've done it. I hope you're happy now."
	default_material = "spacelag"
	amount = 1
	value = -500 //cause a stutter when selling if possible, just because it's funny

/obj/item/material_piece/slag
	icon_state = "slag"
	name = "slag"
	desc = "By-product of smelting"
	default_material = "slag"
	value = -10 //heavy trash

/obj/item/material_piece/rubber/latex
	name = "latex sheet"
	desc = "A sheet of latex."
	icon_state = "latex"
	default_material = "latex"
	value = 20 //maybe

	setup_material()
		src.create_reagents(10)
		reagents.add_reagent("rubber", 10)
		return ..()

/obj/item/material_piece/organic/wood
	name = "wooden log"
	desc = "Years of genetic engineering mean timber always comes in mostly perfectly shaped cylindrical logs."
	icon_state = "log"
	default_material = "wood"
	value = 100 //somewhat rare in space

	attackby(obj/item/W as obj, mob/user as mob)
		if ((istool(W, TOOL_CUTTING | TOOL_SAWING)))
			user.visible_message("[user] cuts a plank from the [src].", "You cut a plank from the [src].")
			var/obj/item/plankobj = new /obj/item/plank(user.loc)
			plankobj.setMaterial(getMaterial("wood"), appearance = 0, setname = 0)
			if (src.amount > 1)
				change_stack_amount(-1)
			else
				qdel (src)
		else
			..()

/obj/item/material_piece/organic/bamboo
	name = "bamboo stalk"
	desc = "Keep away from Space Pandas."
	icon_state = "bamboo"
	default_material = "bamboo"
	value = 20 //cheap material

	attackby(obj/item/W as obj, mob/user as mob)
		if ((istool(W, TOOL_CUTTING | TOOL_SAWING)))
			user.visible_message("[user] carefully extracts a shoot from [src].", "You carefully cut a shoot from [src].")
			new /obj/item/reagent_containers/food/snacks/plant/bamboo/(user.loc)
			if (src.amount > 1)
				change_stack_amount(-1)
			else
				qdel (src)
		else
			..()

/obj/item/material_piece/cloth/spidersilk
	name = "space spider silk"
	desc = "space silk produced by space dwelling space spiders. space."
	icon_state = "spidersilk"
	default_material = "spidersilk"
	value = 200 //luxury

/obj/item/material_piece/cloth/leather
	name = "leather"
	desc = "leather made from the skin of some sort of space critter."
	icon_state = "leather"
	default_material = "leather"
	value = 150 //cool

/obj/item/material_piece/cloth/synthleather
	name = "synthleather"
	desc = "A type of artificial leather."
	icon_state = "synthleather"
	default_material = "synthleather"
	value = 100 //less cool

/obj/item/material_piece/cloth/cottonfabric
	name = "cotton fabric"
	desc = "A type of natural fabric."
	icon_state = "fabric"
	default_material = "cotton"
	value = 20 //processed

/obj/item/material_piece/cloth/cottonfabric/randomcolor
	New()
		. = ..()
		src.color = random_hex(6)

/obj/item/material_piece/cloth/brullbarhide
	name = "brullbar hide"
	desc = "The hide of a brüllbär"
	icon_state = "brullbarhide"
	default_material = "brullbarhide"
	value = 500 //way cool

/obj/item/material_piece/cloth/kingbrullbarhide
	name = "king brüllbär hide"
	desc = "The hide of a king brüllbär"
	icon_state = "brullbarhide"
	default_material = "kingbrullbarhide"
	value = 5000 //holy shit man

/obj/item/material_piece/cloth/carbon
	name = "carbon nano fibre fabric"
	desc = "carbon based hi-tech material."
	icon_state = "carbonfibre"
	default_material = "carbonfibre"
	value = 200

/obj/item/material_piece/cloth/dyneema
	name = "dyneema fabric"
	desc = "carbon nanofibres and space spider silk!"
	icon_state = "dyneema"
	default_material = "dyneema"
	value = 500 //whatever

/obj/item/material_piece/cloth/hauntium
	name = "hauntium fabric"
	desc = "This cloth seems almost alive."
	default_material = "hauntium"
	value = 300
	icon_state = "dyneema"

/obj/item/material_piece/cloth/beewool
	name = "bee wool"
	desc = "Some bee wool."
	icon_state = "beewool"
	default_material = "beewool"
	value = 75

/obj/item/material_piece/soulsteel
	name = "soulsteel bar"
	desc = "A bar of soulsteel. Metal made from souls."
	icon_state = "soulsteel"
	default_material = "soulsteel"
	value = 500 //curse you

/obj/item/material_piece/bone
	name = "bits of bone"
	desc = "some bits and pieces of bones."
	icon_state = "scrap3"
	default_material = "bone"
	value = -10 //trash at best, crime at worst

/obj/item/material_piece/gnesis
	name = "gnesis wafer"
	desc = "A warm, pulsing block of weird alien computer crystal stuff."
	icon_state = "gnesis"
	default_material = "gnesis"
	value = 100 //weird but commonish

/obj/item/material_piece/gnesisglass
	name = "gnesisglass wafer"
	desc = "A shimmering, transclucent block of weird alien computer crystal stuff."
	icon_state = "gnesisglass"
	default_material = "gnesisglass"
	value = 100 //sure

/obj/item/material_piece/coral
	name = "coral"
	desc = "A piece of coral. Nice!"
	icon_state = "coral"
	default_material = "coral"
	value = 150 //space tourists love that shit

/obj/item/material_piece/neutronium
	name = "neutronium bar"
	desc = "Neutrons condensed into a solid form."
	default_material = "neutronium"
	value = 5000 //i guess? i don't know how often this comes up

/obj/item/material_piece/negativematter
	name = "negative matter bar"
	desc = "Negative matter condensed into a solid form."
	default_material = "negativematter"
	value = 5000 //i guess? i don't know how often this comes up

/obj/item/material_piece/mauxite
	name = "mauxite bar"
	desc = "A processed bar of mauxite, a sturdy common metal."
	default_material = "mauxite"
	value = 100 //more than raw

/obj/item/material_piece/molitz
	name = "molitz block"
	desc = "A cut block of molitz, a common crystalline substance."
	default_material = "molitz"
	icon_state = "block"
	value = 100 //more than raw

/obj/item/material_piece/molitz_beta
	name = "molitz block"
	desc = "An unusually colored block of molitz, a common crystalline substance."
	default_material = "molitz_beta"
	icon_state = "block"
	value = 300 //same as raw

/obj/item/material_piece/pharosium
	name = "pharosium bar"
	desc = "A processed bar of pharosium, a conductive metal."
	default_material = "pharosium"
	value = 100 //more than raw

/obj/item/material_piece/cobryl
	name = "cobryl bar"
	desc = "A processed bar of cobryl, a somewhat valuable metal."
	default_material = "cobryl"
	value = 300 //more than raw, it's just fancy blue space silver

/obj/item/material_piece/claretine
	name = "claretine block"
	desc = "A compressed block of claretine, a highly conductive salt."
	default_material = "claretine"
	icon_state = "block"
	value = 100 //more than raw

/obj/item/material_piece/bohrum
	name = "bohrum bar"
	desc = "A processed bar of bohrum, a heavy and highly durable metal."
	default_material = "bohrum"
	value = 250 //processed and ready for use

/obj/item/material_piece/syreline
	name = "syreline bar"
	desc = "A processed bar of syreline, an extremely valuable and coveted metal."
	default_material = "syreline"
	value = 1000 //more than raw, it's just fancy yellow space platinum

/obj/item/material_piece/plasmastone
	name = "plasmastone block"
	desc = "A cut block of plasmastone."
	default_material = "plasmastone"
	icon_state = "block"
	value = 750 //shaped and purified? yeah makes sense to me for a boost

/obj/item/material_piece/plasmasteel
	name = "plasmasteel bar"
	desc = "A processed bar of plasmasteel, a space age alloy."
	default_material = "plasmasteel"
	value = 800 //nice useful stuff

/obj/item/material_piece/plasmaglass
	name = "plasmaglass block"
	desc = "A processed block of plasmaglass, a space age transparent alloy."
	default_material = "plasmaglass"
	value = 800 //nice useful stuff

/obj/item/material_piece/gemstone
	name = "cracked gemstone"
	desc = "The processor fucked this gemstone up pretty bad."
	default_material = "gemstone"
	icon_state = "block"
	value = 10 //ngl i just dont wanna implement 20 gemstone types

/obj/item/material_piece/uqill
	name = "uqill block"
	desc = "A cut block of uqill. It is quite heavy."
	default_material = "uqill"
	icon_state = "block"
	value = 1000 //slightly better price

/obj/item/material_piece/koshmarite
	name = "koshmarite block"
	desc = "A cut block of an unusual dense stone. It seems similar to obsidian."
	default_material = "koshmarite"
	icon_state = "block"
	value = 120 //slightly better price

/obj/item/material_piece/viscerite
	name = "viscerite block"
	desc = "A cut block of a disgusting flesh-like material. Grody."
	default_material = "viscerite"
	icon_state = "block"
	value = 100 //same amount, different shape, it's just goop

/obj/item/material_piece/char
	name = "char"
	desc = "Compressed and processed char."
	default_material = "char"
	icon_state = "wad"
	value = 50 //processed for better incineration? maybe make this a bonus for furnaces

/obj/item/material_piece/telecrystal
	name = "telecrystal block"
	desc = "A cut block of telecrystal."
	default_material = "telecrystal"
	icon_state = "block"
	value = 1000 //for now, i feel like it'd take a lot of telecrystal to make a whole bar, maybe. and that it's not particularly worth anything until inscribed or whatever.

/obj/item/material_piece/fibrilith
	desc = "A cut block of fibrilith."
	default_material = "fibrilith"
	icon_state = "block"
	value = 40 //more than raw

/obj/item/material_piece/cerenkite
	name = "cerenkite block"
	desc = "A cut block of highly radioactive cerenkite."
	icon_state = "block"
	default_material = "cerenkite"
	value = 650 //more than raw

/obj/item/material_piece/erebite
	name = "erebite block"
	desc = "A cut block of highly radioactive and dangerously volatile erebite."
	icon_state = "block"
	default_material = "erebite"
	value = 850 //more than raw

/obj/item/material_piece/gold
	name = "stamped bullion"
	desc = "Oh wow! This stuff's got to be worth a lot of money!"
	default_material = "gold"
	value = 35000 //base commodity price

/obj/item/material_piece/ice
	name = "ice cube"
	desc = "Uh. What's the point in this? Is someone planning to make an igloo?"
	default_material = "ice"
	icon_state = "block"
	value = 0
	alt_value = 50

/obj/item/material_piece/butt
	name = "butt cube"
	desc = "You feel a compulsion to throw this into the nearest trash compactor."
	default_material = "butt"
	icon_state = "block"
	value = -50

/obj/item/material_piece/flesh
	name = "flesh"
	desc = "Processed flesh. Absolutely horrible."
	default_material = "flesh"
	icon_state = "wad"
	value = 0 // i... i dunno


/obj/item/material_piece/flesh/grody
	name = "disgusting pulp"
	desc = "You would throw this in the crusher, but it looks like it already went through."
	default_material = "grodyflesh"
	value = -500 // definitely a crime

/obj/item/material_piece/miracle
	name = "miracle matter block"
	desc = "A cut block of miracle matter. Probably less magical now."
	default_material = "miracle"
	icon_state = "block"
	value = 300 // the scientists maybe want it untouched

/obj/item/material_piece/starstone
	name = "starstone cube"
	desc = "A compacted crystalline block of starstone. Definitely not magical, but more marketable."
	default_material = "starstone"
	icon_state = "block"
	value = 5000 // surely this is fine

/obj/item/material_piece/blob
	name = "blob of blob"
	desc = "The living flesh of the terrifying giant space amoeba."
	default_material = "blob"
	icon_state = "wad"
	value = -150 // they have to pay biohazard cleanup now!

/obj/item/material_piece/cardboard
	name = "cardboard slab"
	desc = "A slab of uncorrugated cardboard."
	default_material = "cardboard"
	value = 0

/obj/item/material_piece/chitin
	name = "chitin chunk"
	desc = "A chunk of grody squished up chitin."
	default_material = "chitin"
	icon_state = "wad"
	value = 10

/obj/item/material_piece/beeswax
	name = "beeswax bar"
	desc = "A bar of solid beeswax. It isn't scented yet."
	default_material = "beeswax"
	value = 100 //candles!

/obj/item/material_piece/honey
	name = "industrial honey"
	desc = "Industrial grade honey. It's spherical."
	default_material = "honey"
	icon_state = "sphere"
	value = 100

/obj/item/material_piece/pizza
	name = "cubed pizza"
	desc = "Pizza compressed into a cube shape. Oh god."
	default_material = "pizza"
	icon_state = "block"
	value = 100

/obj/item/material_piece/cloth/ectofibre
	name = "ectofibre cloth"
	desc = "What even is this... oh, it's ectofibre."
	default_material = "ectofibre"
	value = 50 // scary!

/obj/item/material_piece/block/rubber
	name = "synthrubber block"
	desc = "A block of red rubber."
	default_material = "synthrubber"
	icon_state = "block"
	value = 20

	setup_material()
		src.create_reagents(5)
		reagents.add_reagent("rubber", 5)
		return ..()


/obj/item/material_piece/block/rubber/synthblubber
	name = "synthblubber block"
	desc = "A block of synthblubber. Probably."
	default_material = "synthblubber"
	icon_state = "block"
	value = 50

/obj/item/material_piece/ectoplasm
	name = "ectoplasm ball"
	desc = "A ball of purified ectoplasm."
	default_material = "honey"
	icon_state = "sphere"
	value = 25

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

		var/obj/item/material_piece/BAR = new MAT.bar_type()
		BAR.setMaterial(MAT, TRUE, FALSE)
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
