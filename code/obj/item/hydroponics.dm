// Contains:
//
// - Chainsaw
// - Plant analyzer
// - Portable seed fabricator
// - Watering can
// - Compost bag
// - Plant formulas
// - Garden Trowel

//////////////////////////////////////////////// Chainsaw ////////////////////////////////////

/obj/item/saw
	name = "chainsaw"
	desc = "A chainsaw used to chop up harmful plants."
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "c_saw_off"
	item_state = "c_saw"
	var/base_state = "c_saw"
	var/active = 0.0
	hit_type = DAMAGE_CUT
	force = 3.0
	var/active_force = 12.0
	var/off_force = 3.0
	var/how_dangerous_is_this_thing = 1
	var/takes_damage = 1
	health = 10.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_BULKY
	flags = FPRINT | TABLEPASS | CONDUCT
	tool_flags = TOOL_SAWING
	mats = 12
	var/sawnoise = 'sound/machines/chainsaw_green.ogg'
	arm_icon = "chainsaw0"
	over_clothes = 1
	override_attack_hand = 1
	can_hold_items = 0
	stamina_damage = 30
//	stamina_cost = 15
//	stamina_crit_chance = 35

	cyborg
		takes_damage = 0

	active
		active = 1
		force = 12

	New()
		..()
		SPAWN_DBG(0.5 SECONDS)
			if (src)
				src.update_icon()
		BLOCK_SETUP(BLOCK_ROD)
		return

	proc/check_health()
		if (src.health <= 0 && src.takes_damage)
			SPAWN_DBG(0.2 SECONDS)
				if (src)
					usr.u_equip(src)
					usr.update_inhands()
					boutput(usr, "<span class='alert'>[src] falls apart!</span>")
					qdel(src)
		return

	proc/damage_health(var/amt)
		src.health -= amt
		src.check_health()
		return

	update_icon()
		set_icon_state("[src.base_state][src.active ? null : "_off"]")
		return

	// Fixed a couple of bugs and cleaned code up a little bit (Convair880).
	attack(mob/target as mob, mob/user as mob)
		if (!istype(target))
			return

		if (src.active)

			user.lastattacked = target
			target.lastattacker = user
			target.lastattackertime = world.time

			if (ishuman(target))
				if (ishuman(user) && saw_surgery(target,user))
					src.damage_health(2)
					take_bleeding_damage(target, user, 2, DAMAGE_CUT)
					return
				else if (!isdead(target))
					take_bleeding_damage(target, user, 5, DAMAGE_CUT)
					if (prob(80))
						target.emote("scream")

			playsound(target, sawnoise, 60, 1)//need a better sound

			if (src.takes_damage)
				if (issilicon(target))
					src.damage_health(4)
				else
					src.damage_health(1)

			switch (src.how_dangerous_is_this_thing)
				if (2) // Red chainsaw.
					if (iscarbon(target))
						var/mob/living/carbon/C = target
						if (!isdead(C))
							C.changeStatus("stunned", 3 SECONDS)
							C.changeStatus("weakened", 3 SECONDS)
						else
							logTheThing("combat", user, C, "butchers [C]'s corpse with the [src.name] at [log_loc(C)].")
							var/sourcename = C.real_name
							var/sourcejob = "Stowaway"
							if (C.mind && C.mind.assigned_role)
								sourcejob = C.mind.assigned_role
							else if (C.ghost && C.ghost.mind && C.ghost.mind.assigned_role)
								sourcejob = C.ghost.mind.assigned_role
							for (var/i=0, i<3, i++)
								var/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/meat = new /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat(get_turf(C))
								meat.name = sourcename + meat.name
								meat.subjectname = sourcename
								meat.subjectjob = sourcejob
							if (C.mind)
								C.ghostize()
								qdel(C)
								return
							else
								qdel(C)
								return

				if (3) // Elimbinator.
					if (ishuman(target))
						var/mob/living/carbon/human/H = target
						var/list/limbs = list("l_arm","r_arm","l_leg","r_leg")
						var/the_limb = null

						if (user.zone_sel.selecting in limbs)
							the_limb = user.zone_sel.selecting
						else
							the_limb = pick("l_arm","r_arm","l_leg","r_leg")

						if (!the_limb)
							return //who knows

						H.sever_limb(the_limb)
						H.changeStatus("stunned", 3 SECONDS)
						bleed(H, 3, violent = TRUE)
		..()
		return

	attack_self(mob/user as mob)
		if (user.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span class='alert'><b>[user]</b> accidentally grabs the blade of [src].</span>")
			user.TakeDamage(user.hand == 1 ? "l_arm" : "r_arm", 5, 5)
			JOB_XP(user, "Clown", 1)
		src.active = !( src.active )
		if (src.active)
			boutput(user, "<span class='notice'>[src] is now active.</span>")
			src.force = active_force
		else
			boutput(user, "<span class='notice'>[src] is now off.</span>")
			src.force = off_force
		tooltip_rebuild = 1
		src.update_icon()
		user.update_inhands()
		src.add_fingerprint(user)
		return

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] shoves the chainsaw into [his_or_her(user)] chest!</b></span>")
		blood_slash(user, 25)
		playsound(user.loc, 'sound/machines/chainsaw_red.ogg', 50, 1)
		playsound(user.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 50, 1)
		user.u_equip(src)
		src.set_loc(user.loc)
		user.gib()
		return 1

/obj/item/saw/abilities = list(/obj/ability_button/saw_toggle)

/obj/item/saw/syndie
	name = "red chainsaw"
	icon_state = "c_saw_s_off"
	item_state = "c_saw_s"
	base_state = "c_saw_s"
	tool_flags = TOOL_SAWING | TOOL_CHOPPING //fucks up doors. fuck doors
	active = 0.0
	force = 6.0
	active_force = 20.0
	off_force = 6.0
	health = 10
	takes_damage = 0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_BULKY
	is_syndicate = 1
	how_dangerous_is_this_thing = 1 //it gibs differently
	mats = 14
	desc = "This one is the real deal. Time for a space chainsaw massacre."
	contraband = 10 //scary
	sawnoise = 'sound/machines/chainsaw_red.ogg'
	arm_icon = "chainsaw1"
	stamina_damage = 100
//	stamina_cost = 30
//	stamina_crit_chance = 40
	c_flags = EQUIPPED_WHILE_HELD




	setupProperties()
		. = ..()
		setProperty("deflection", 75)

/obj/item/saw/syndie/attack(mob/living/carbon/human/target as mob, mob/user as mob)
	var/mob/living/carbon/human/H = target

	if(!active)
		src.visible_message("<span class='notify'>[user] gently taps [target] with the turned off [src].</span>")

	if(active && prob(35))
		gibs(target.loc, blood_DNA=H.bioHolder.Uid, blood_type=H.bioHolder.bloodType, headbits=FALSE, source=H)

	if (H.organHolder && active)
		if (H.organHolder.appendix)
			H.organHolder.drop_organ("appendix")
			playsound(target.loc,'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
			target.visible_message(
				"<span class='alert'><b>[target]'s appendix is ripped out [pick("violently", "brutally", "ferociously", "fiercely")]!</span>"
				)
			make_cleanable(/obj/decal/cleanable/tracked_reagents/blood/gibs,target.loc)
			return ..()

		if (H.organHolder.left_kidney)
			H.organHolder.drop_organ("left_kidney")
			playsound(target.loc,'sound/impact_sounds/Flesh_Tear_2.ogg', 50, 1)
			target.visible_message(
				"<span class='alert'><b>[target]'s kidney is torn out [pick("cruelly", "viciously", "atrociously", "fiercely")]!</span>"
				)
			make_cleanable(/obj/decal/cleanable/tracked_reagents/blood/gibs,target.loc)
			return ..()

		if (H.organHolder.left_lung)
			H.organHolder.drop_organ("left_lung")
			playsound(target.loc,'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
			target.visible_message(
				"<span class='alert'><b>[target]'s lung is gashed out [pick("tempestuously", "impetuously", "sorta meanly", "unpleasantly")]!</span>"
				)
			make_cleanable(/obj/decal/cleanable/tracked_reagents/blood/gibs,target.loc)
			return ..()

		if (H.organHolder.right_kidney)
			H.organHolder.drop_organ("right_kidney")
			playsound(target.loc,'sound/impact_sounds/Flesh_Tear_2.ogg', 50, 1)
			target.visible_message(
				"<span class='alert'><b>[target]'s kidney is torn out [pick("cruelly", "viciously", "atrociously", "fiercely")]!</span>"
				)
			make_cleanable(/obj/decal/cleanable/tracked_reagents/blood/gibs,target.loc)
			return ..()

		if (H.organHolder.right_lung)
			H.organHolder.drop_organ("right_lung")
			playsound(target.loc,'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
			target.visible_message(
				"<span class='alert'><b>[target]'s lung is gashed out [pick("tempestuously", "impetuously", "sorta meanly", "unpleasantly")]!</span>"
				)
			make_cleanable(/obj/decal/cleanable/tracked_reagents/blood/gibs,target.loc)
			return ..()

		if (H.organHolder.liver)
			H.organHolder.drop_organ("liver")
			playsound(target.loc,'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
			target.visible_message(
				"<span class='alert'><b>[target]'s liver is gashed out [pick("unnecessarily", "stylishly", "viciously", "unethically")]!</span>"
				)
			make_cleanable(/obj/decal/cleanable/tracked_reagents/blood/gibs,target.loc)

			return ..()

		if (H.organHolder.heart) //move this up or down to make it kill faster or later
			H.organHolder.drop_organ("heart")
			playsound(target.loc,'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
			target.visible_message(
				"<span class='alert'><b>[target]'s heart is ripped clean out! [pick("HOLY MOLY", "FUCK", "JESUS CHRIST", "THAT'S GONNA LEAVE A MARK", "OH GOD", "OUCH", "DANG", "WOW", "woah")]!!</span>"
				)
			make_cleanable(/obj/decal/cleanable/tracked_reagents/blood/gibs,target.loc)
			return ..()


		if (H.organHolder.spleen)
			H.organHolder.drop_organ("spleen")
			playsound(target.loc,'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
			target.visible_message(
				"<span class='alert'><b>[target]'s spleen is removed with [pick("conviction", "malice", "disregard for safety regulations", "contempt")]!</span>"
				)
			make_cleanable(/obj/decal/cleanable/tracked_reagents/blood/gibs,target.loc)
			return ..()

		if (H.organHolder.pancreas)
			H.organHolder.drop_organ("pancreas")
			playsound(target.loc,'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
			target.visible_message(
				"<span class='alert'><b>[target]'s pancreas is evicted with [pick("anger", "ill intent", "disdain")]!</span>"
				)
			make_cleanable(/obj/decal/cleanable/tracked_reagents/blood/gibs,target.loc)
			return ..()

		if (H.health < -500) //gib if it can't take any more organs and target is very damaged
			target.gib()
			return

		else
			return ..()

/obj/item/saw/syndie/vr
	icon = 'icons/effects/VR.dmi'

/obj/item/saw/elimbinator
	name = "The Elimbinator"
	desc = "Lops off limbs left and right!"
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "c_saw_s"
	item_state = "c_saw_s"
	base_state = "c_saw_s"
	hit_type = DAMAGE_CUT
	active = 1.0
	force = 5
	active_force = 10.0
	off_force = 5.0
	health = 10
	how_dangerous_is_this_thing = 3
	takes_damage = 0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_BULKY
	mats = 12
	sawnoise = 'sound/machines/chainsaw_red.ogg'
	arm_icon = "chainsaw1"
	stamina_damage = 40
//	stamina_cost = 40
//	stamina_crit_chance = 50

////////////////////////////////////// Plant analyzer //////////////////////////////////////

/obj/item/plantanalyzer/
	name = "plant analyzer"
	desc = "A device which examines the genes of plant seeds."
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "plantanalyzer"
	w_class = W_CLASS_TINY
	flags = ONBELT
	mats = 4

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
		if (get_dist(A, user) > 1)
			return

		boutput(user, scan_plant(A, user, visible = 1)) // Replaced with global proc (Convair880).
		src.add_fingerprint(user)
		return

/////////////////////////////////////////// Seed fabricator ///////////////////////////////

/obj/item/seedplanter
	name = "portable seed fabricator"
	desc = "A tool for cyborgs used to create plant seeds."
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "portable_seed_fab"
	var/datum/plant/selected = null


	attack_self(var/mob/user as mob)
		playsound(src.loc, "sound/machines/click.ogg", 100, 1)
		var/list/usable = list()
		for(var/datum/plant/A in hydro_controls.plant_species)
			if (!A.vending)
				continue
			usable += A

		var/holder = src.loc
		var/datum/plant/pick = input(usr, "Which seed do you want?", "Portable Seed Fabricator", null) in usable
		if (src.loc != holder)
			return
		src.selected = pick

	afterattack(atom/target as obj|mob|turf, mob/user as mob, flag)
		if (isturf(target) && selected)
			var/obj/item/seed/S
			// if (selected.unique_seed)
			// 	S = new selected.unique_seed(src.loc)
			// else
			// 	S = new /obj/item/seed(src.loc,0)
			// S.generic_seed_setup(selected)
			if (selected.unique_seed)
				S = new selected.unique_seed(src.loc)
				S.set_loc(src.loc)
			else
				S = new(src.loc)
				S.set_loc(src.loc)
				S.removecolor()
			S.generic_seed_setup(selected)



/obj/item/seedplanter/hidden
	desc = "This is supposed to be a cyborg part. You're not quite sure what it's doing here."


///////////////////////////////////// Garden Trowel ///////////////////////////////////////////////

/obj/item/gardentrowel
	name = "garden trowel"
	desc = "A tool to uproot plants and transfer them to decorative pots"
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "trowel"

	flags = FPRINT | TABLEPASS | ONBELT
	w_class = W_CLASS_TINY

	force = 5.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	stamina_damage = 10
//	stamina_cost = 10
//	stamina_crit_chance = 30
	hit_type = DAMAGE_STAB
	hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'

	rand_pos = 8
	var/image/plantyboi

	New()
		..()
		BLOCK_SETUP(BLOCK_KNIFE)

	afterattack(obj/target as obj, mob/user as mob)
		if(istype(target, /obj/machinery/plantpot))
			var/obj/machinery/plantpot/pot = target
			if(pot.current)
				var/datum/plant/p = pot.current
				if(pot.GetOverlayImage("plant"))
					plantyboi = pot.GetOverlayImage("plant")
					plantyboi.pixel_x = 2
					src.icon_state = "trowel_full"
				else
					return
				if(p.growthmode == "weed")
					user.visible_message("<b>[user]</b> tries to uproot the [p.name], but it's roots hold firmly to the [pot]!","<span class='alert'>The [p.name] is too strong for you traveller...</span>")
					return
				pot.HYPdestroyplant()

		//check if target is a plant pot to paste in the cosmetic plant overlay
///////////////////////////////////// Watering can ///////////////////////////////////////////////

/obj/item/reagent_containers/glass/wateringcan
	name = "watering can"
	desc = "Used to water things. Obviously."
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "wateringcan"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "wateringcan"
	amount_per_transfer_from_this = 60
	w_class = W_CLASS_NORMAL
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	initial_volume = 120
	can_recycle = FALSE

	New()
		..()
		reagents.add_reagent("water", 120)

/obj/item/reagent_containers/glass/wateringcan/old
	name = "antique watering can"
	desc = "Used to water things. Obviously. But in a sort of rustic way..."
	icon_state = "watercan_old"
	item_state = ""				//it didn't have an in-hand icon ever...

/obj/item/reagent_containers/glass/wateringcan/gold
	name = "golden watering can"
	desc = "Used to water things. Obviously. But it's golden..."
	icon_state = "wateringcan_gold"
	item_state = "wateringcan_gold"

/obj/item/reagent_containers/glass/wateringcan/weed
	name = "weed watering can"
	desc = "Used to water things. Obviously."
	icon_state = "wateringcan_weed"
	item_state = "wateringcan_weed"

/obj/item/reagent_containers/glass/wateringcan/rainbow
	name = "rainbow watering can"
	desc = "Used to water things. Obviously. It's rainbow..."
	icon_state = "wateringcan_rainbow"
	item_state = "wateringcan_rainbow"

/////////////////////////////////////////// Compost bag ////////////////////////////////////////////////

/obj/item/reagent_containers/glass/compostbag/
	name = "compost bag"
	desc = "A big bag of shit."
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "compost"
	amount_per_transfer_from_this = 10
	w_class = W_CLASS_NORMAL
	rc_flags = 0
	initial_volume = 60

	New()
		..()
		reagents.add_reagent("poo", 60)

/////////////////////////////////////////// Plant formulas /////////////////////////////////////

/obj/item/reagent_containers/glass/bottle/weedkiller
	name = "weedkiller"
	desc = "A small bottle filled with Atrazine, an effective weedkiller."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"
	amount_per_transfer_from_this = 10
	initial_volume = 40

	New()
		..()
		reagents.add_reagent("weedkiller", 40)

/obj/item/reagent_containers/glass/bottle/mutriant
	name = "Mutagenic Plant Formula"
	desc = "An unstable radioactive mixture that stimulates genetic diversity."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 10
	initial_volume = 40

	New()
		..()
		reagents.add_reagent("mutagen", 40)

/obj/item/reagent_containers/glass/bottle/groboost
	name = "Ammonia Plant Formula"
	desc = "A nutrient-rich plant formula that encourages quick plant growth."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 10
	initial_volume = 40

	New()
		..()
		reagents.add_reagent("ammonia", 40)

/obj/item/reagent_containers/glass/bottle/topcrop
	name = "Potash Plant Formula"
	desc = "A nutrient-rich plant formula that encourages large crop yields."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 10
	initial_volume = 40

	New()
		..()
		reagents.add_reagent("potash", 40)

/obj/item/reagent_containers/glass/bottle/powerplant
	name = "Saltpetre Plant Formula"
	desc = "A nutrient-rich plant formula that encourages more potent crops."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 10
	initial_volume = 40

	New()
		..()
		reagents.add_reagent("saltpetre", 40)

/obj/item/reagent_containers/glass/bottle/fruitful
	name = "Mutadone Plant Formula"
	desc = "A nutrient-rich formula that attempts to rectify genetic problems."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 10
	initial_volume = 40

	New()
		..()
		reagents.add_reagent("mutadone", 40)

/obj/item/reagent_containers/glass/happyplant
	name = "Happy Plant Mixture"
	desc = "250 units of things that make plants grow happy!"
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "happyplant"
	amount_per_transfer_from_this = 50
	w_class = W_CLASS_NORMAL
	incompatible_with_chem_dispensers = 1
	inventory_counter_enabled = TRUE
	rc_flags = RC_SCALE | RC_INV_COUNT_AMT
	initial_volume = 250
	initial_reagents = list("saltpetre"=50, "ammonia"=50, "potash"=50, "poo"=50, "space_fungus"=50)

/obj/item/reagent_containers/bowlpiece
	name = "bong bowlpiece"
	desc = "Don't tell security."
	icon = 'icons/obj/chemical.dmi' //placeholder mini vial icon until bowlpieces can be sprited
	icon_state = "minivial"
	contraband = 1
	flags = FPRINT | TABLEPASS
	object_flags = 0
	incompatible_with_chem_dispensers = 1
	value = 20
	//var/max_hit_count = 6 //number of hits until cleared // mylie thinks max hits should be kinda based on reagent count, like cigs?
	var/base_reagent_per_rip = 5 // amount transferred from this, for anything with less than 50 units in it
	var/scaling_past_fifty = 0.05 // additional units transferred per unit past 50 in the herb
	var/reagent_per_rip = 0
	var/loaded_with = "empty" //what herb is loaded in the bowl
	var/list/allowed_types_list = list(/obj/item/plant/herb)

	//Basic bowl piece for water pipes, loading it behaves sort of like rolling a joint code wise
	New()
		..()


	proc/pack_a_bowl(obj/item/W as obj, mob/user as mob)
		if(src.reagents.total_volume >= CHEM_EPSILON)
			boutput(user, "<span class='alert'>This bowl is already packed, finish smoking it!.</span>")
			return FALSE
		else
			if(istype(W, /obj/item/plant/herb/cannabis/black))
				loaded_with = "weed-black"
			else if(istype(W, /obj/item/plant/herb/cannabis/white))
				loaded_with = "weed-white"
			else if(istype(W, /obj/item/plant/herb/cannabis/mega))
				loaded_with = "weed-mega"
			else if(istype(W, /obj/item/plant/herb/cannabis/omega))
				loaded_with = "weed-omega"
			else
				loaded_with = "weed"   //weed and everything else can share loaded bowl a sprite for now

			src.reagents.maximum_volume = src.reagents.total_volume + W.reagents?.total_volume
			if(W.reagents)
				W.reagents.trans_to(src, W.reagents.total_volume)
			//reagent_per_rip = round(src.reagents.total_volume / max_hit_count)
			src.reagent_per_rip = src.base_reagent_per_rip
			if(src.reagents.total_volume > 50)
				src.reagent_per_rip += src.scaling_past_fifty * (src.reagents.total_volume - 50)
			boutput(user, "<span class='notice'>You pack the bowl piece with [W.name].</span>")
			W.force_drop(user)
			qdel(W)

		return TRUE

/obj/item/reagent_containers/bowlpiece/cigarette
	name = "ashtray bowlpiece"
	desc = "There's a ton of stubbed out cigarettes in it. Why?"
	allowed_types_list = list(/obj/item/plant/herb, /obj/item/clothing/mask/cigarette)

/obj/item/reagent_containers/bowlpiece/meat
	name = "\proper bowl that hungers"
	desc = "It needs to eat or it will die."
	contraband = 5
	allowed_types_list = list(/obj/item/reagent_containers/food/snacks/ingredient/meat, /obj/item/organ)

	pack_a_bowl(obj/item/W, mob/user)
		. = ..()
		if(.)
			src.reagents.maximum_volume += 10
			src.reagents.add_reagent(pick("bloodc", "beff", "MRSA", "salmonella", "enriched_msg", "porktonium"), 10)

/obj/item/reagent_containers/food/drinks/water_pipe
	name = "water pipe"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bong"
	incompatible_with_chem_dispensers = 1
	value = 420
	//need something to sort of behave like a bong bowl piece
	var/obj/item/reagent_containers/bowlpiece/bowl
	var/image/fluid_image
	var/image/bowl_image

	//handle filling the water pipe with reagents i.e. water
	New()
		..()
		fluid_image = image(src.icon, "fluid-[src.icon_state]")
		bowl_image = "null"
		src.bowl = new(src)

	disposing()
		if(src.bowl)
			qdel(src.bowl)
			src.bowl = null
		. = ..()

	on_reagent_change()
		..()
		src.update_icon()

	update_icon()
		src.underlays = null

		if (reagents.total_volume)
			var/fluid_state = round(clamp((src.reagents.total_volume / src.reagents.maximum_volume * 5 + 1), 1, 5))
			src.icon_state = "bong[fluid_state]"
			var/datum/color/average = reagents.get_average_color()
			src.fluid_image.color = average.to_rgba()
			src.fluid_image.icon_state = "fluid-bong[fluid_state]"
			src.underlays += src.fluid_image


		else
			src.icon_state = initial(src.icon_state)

		if (bowl && src.bowl.reagents.total_volume >= CHEM_EPSILON)
			bowl_image = image(src.icon, "bong-[bowl.loaded_with]")
			src.underlays += bowl_image

	//handle loading bong with smokable herb reagents i.e. cannabis, tobacco, etc.
    //handle smoking from the water pipe. hiting it, clearing it, adding ash to water, etc.
	attackby(obj/item/W as obj, mob/user as mob)
		if(src.bowl)
			// ive decided to take "for now" to mean "you can smoke glass shards when someone adds that", and have done so - mylie
			if (src.bowl.reagents.total_volume < CHEM_EPSILON && !W.cant_drop && length(src.bowl.allowed_types_list)) //just weade and tobacco for now - hexphire
				for(var/allowed_type in src.bowl.allowed_types_list)
					if(istype(W, allowed_type) && src.bowl.pack_a_bowl(W, user))
						//load bowl with the good good
						src.update_icon()
						return

			if (iswrenchingtool(W))
				playsound(src.loc, "sound/items/Ratchet.ogg", 40, 1, SOUND_RANGE_SMALL)
				user.put_in_hand_or_drop(src.bowl)
				src.bowl = null
			if (isweldingtool(W) && W:try_weld(user,0,-1,0,0))
				hit_da_bong(user)
				return
			else if (istype(W, /obj/item/sword) && W:active)
				hit_da_bong(user)
				return
			else if (istype(W, /obj/item/clothing/head/cakehat) && W:on)
				hit_da_bong(user)
				return
			else if (istype(W, /obj/item/device/igniter))
				hit_da_bong(user)
				return
			else if (istype(W, /obj/item/device/light/zippo) && W:on)
				hit_da_bong(user)
				return
			else if ((istype(W, /obj/item/match) || istype(W, /obj/item/clothing/mask/cigarette) || istype(W, /obj/item/device/light/candle)) && W:on)
				hit_da_bong(user)
				return
			else if (W.burning)
				hit_da_bong(user)
				return
			else if (W.firesource)
				hit_da_bong(user)
				W.firesource_interact()
				return
		else if (istype(W, /obj/item/reagent_containers/bowlpiece) && !W.cant_drop)
			src.bowl = W
			user.u_equip(W)
			W.set_loc(src)
		return ..()

	proc/hit_da_bong(mob/user as mob)
		if(src.reagents.total_volume < (src.reagents.maximum_volume / 2))
			boutput(user, "<span class='alert'>Aw hell, it's dry! Pour some water in first.</span>")
			return

		if(!src.bowl)
			boutput(user, "<span class='alert'>Shit, where's the bowlpiece?</span>")
			return

		if(src.bowl.reagents.total_volume < CHEM_EPSILON)
			boutput(user, "<span class='alert'>The bowl is empty! Load it with something to smoke first.</span>")
			return

		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if (prob(1))
				H.contract_disease(/datum/ailment/malady/heartdisease,null,null,1)

		if(user.bodytemperature < user.base_body_temp)
			user.bodytemperature += 1

		if((user.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(42)) || prob(10)) // ypou DWEEB you done slurped up bongwater oh my gawd you biffed it
			playsound(user.loc, "sound/items/drink.ogg", 45, 1, SOUND_RANGE_LARGE) // we are alerting the neighborhood for this one
			src.reagents.reaction(user, INGEST, (src.reagents.total_volume/8))
			src.reagents.trans_to(user, (src.reagents.total_volume/8))
			user.emote("burp")

		src.bowl.reagents.trans_to(src, (src.bowl.reagent_per_rip * 0.25)) //water gets some sauce
		src.bowl.reagents.reaction(user, INGEST, (src.bowl.reagent_per_rip * 0.75))
		src.bowl.reagents.trans_to(user, (src.bowl.reagent_per_rip * 0.75))

		if(src.bowl.reagents.total_volume >= CHEM_EPSILON)
			user.visible_message("[user] takes a hit from the [src] and exhales smoke.", "<span class='notice'>You take a hit from the [src]. You feel the effects of the whatever's in the bowl starting to kick in.</span>", "You hear the distinct burbling of a water pipe.")
		else
			user.visible_message("[user] takes the last hit from the [src], then clears the bowl.", "<span class='notice'>You take the last hit from the [src], clearing the bowl.</span>", "You hear the distinct burbling of a water pipe, then some tapping on glass.")
			src.reagents.add_reagent("ash", 5)
			src.bowl.reagents.clear_reagents()
			src.bowl.loaded_with = "null"
			src.update_icon()

		//play the bong hit noise
		//old bong hit sound effect must have also been in the .secret, need to add a new one eventually use bubbles_short for not
		playsound(user.loc, 'sound/effects/bubbles_short.ogg', 50, 1, SOUND_RANGE_MODERATE)
		particleMaster.SpawnSystem(new /datum/particleSystem/blow_cig_smoke(user.loc, user.dir))
