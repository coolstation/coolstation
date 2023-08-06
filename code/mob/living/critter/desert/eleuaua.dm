
/mob/living/critter/desert/eleuaua
	name = "eleuaua"
	desc = "A beastie!"
	icon = 'icons/misc/critter.dmi'
	icon_state = "eleuaua"
	icon_state_alive = "eleuaua"
	icon_state_dead = "eleuaua-dead"
	abilityHolder = null
	add_abilities = null

	hand_count = 1	//One mouth

	base_move_delay = 1.6 //guess
	base_walk_delay = 2.2
	stepsound = null
	///time when mob last awoke from hibernation
	last_hibernation_wake_tick = 0
	is_hibernating = TRUE

	can_burn = 1
	can_throw = 0
	can_choke = 0
	in_throw_mode = 0

	can_help = TRUE
	can_grab = 0
	can_disarm = 0

	reagent_capacity = 137

	//death_text = null // can use %src%
	//pet_text = "pets" // can be a list

	custom_brain_type = null

	last_life_process = 0
	use_stunned_icon = 1

	pull_w_class = W_CLASS_SMALL

	blood_id = "blood"

	New()
		..()
		APPLY_MOB_PROPERTY(src, PROP_CANTSPRINT, src) //Rather, they're always sprinting but same idea

	setup_healths()
		add_hh_flesh(33, 1.3)
		add_hh_flesh_burn(33, 0.75)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/mouth/eleuaua
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "mouth"


/datum/limb/mouth/eleuaua
	sound_attack = "sound/impact_sounds/Flesh_Tear_1.ogg"
	dam_low = 6 //high damage floor cause desert creature's gotta make it count
	dam_high = 9

	help(mob/target, mob/user)
		user.visible_message("<span class='notice'>[user] nuzzes [target].</span>") //critical feature
		user.lastattacked = target

