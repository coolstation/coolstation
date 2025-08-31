/mob/living/critter/maulworm
	name = "maulworm"
	real_name = "maulworm"
	desc = "A short and stout desert worm with dangerous pincers."
	speechverb_say = "clicks"
	speechverb_exclaim = "clacks"
	speechverb_ask = "chitters"
	density = 0
	pass_unstable = PRESERVE_CACHE
	can_help = 1
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	lie_on_death = 0
	butcherable = 1
	name_the_meat = 1
	max_skins = 1
	// meat_type = /obj/item/reagent_containers/food/snacks/ingredient/meat
	blood_id = "sewage"
	health_brute = 15
	health_burn = 15
	health_brute_vuln = 0.9
	health_burn_vuln = 0.9
	flags = TABLEPASS | FLUID_SUBMERGE
	fits_under_table = 1
	hand_count = 1

	base_move_delay = 3
	base_walk_delay = 4.5

/mob/living/critter/maulworm/setup_hands()
	..()
	var/datum/handHolder/HH = hands[1]
	HH.limb = new /datum/limb/pincers(src)
	HH.icon = 'icons/ui/critter_ui.dmi'
	HH.icon_state = "mouth"
	HH.name = "mandibles"
	HH.limb.name = "mandibles"

/mob/living/critter/maulworm/ai_rate_target(mob/living/L)
	if(!istype(L))
		return 0
	if(issilicon(L))
		return 1
	if(istype(L, /mob/living/critter/maulworm))
		return 1
	return 2 + L.bleeding
