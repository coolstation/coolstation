
/* ==================================================== */
/* -------------------- Fuel Tanks -------------------- */
/* ==================================================== */

// Why is this a drinking bottle now? Well, I want the same set of functionality (drag & drop, transference)
// without the C&P code a separate obj class would require. You can't use drinking bottles in beaker
// assemblies and the like in case you're worried about the availability of 400 units beakers (Convair880).
/obj/item/reagent_containers/food/drinks/fueltank
	name = "fuel tank"
	desc = "A specialized anti-static tank for holding flammable compounds"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "bottlefuel"
	w_class = W_CLASS_NORMAL
	amount_per_transfer_from_this = 25
	incompatible_with_chem_dispensers = 1
	inventory_counter_enabled = TRUE
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	rc_flags = RC_SCALE | RC_SPECTRO | RC_INV_COUNT_AMT
	initial_volume = 400
	can_recycle = FALSE
	can_chug = 0
	initial_reagents = "fuel"

/obj/item/reagent_containers/food/drinks/fueltank/empty
	initial_reagents = null

/obj/item/reagent_containers/food/drinks/fueltank/napalm
	initial_reagents = "napalm_goo"

/obj/item/reagent_containers/food/drinks/fueltank/chlorine // high capacity pool chlorine container! will probably do something later ~Warc
	initial_reagents = "chlorine"
	icon_state = "bottlecl"
	name = "Pool Chlorine"

/obj/item/reagent_containers/food/drinks/chemicalcan
	name = "chemical cannister"
	desc = "For storing medical chemicals and less savory things."
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	icon = 'icons/obj/objects.dmi'
	icon_state = "chemtank"
	item_state = "chemtank"
	initial_volume = 1000
	flags = OPENCONTAINER
	w_class = W_CLASS_HUGE
	incompatible_with_chem_dispensers = 1
	throw_speed = 1
	throw_range = 3
	throwforce = 15
	can_chug = FALSE
	two_handed = TRUE
	p_class = 2
	cannot_be_stored = TRUE
	c_flags = EQUIPPED_WHILE_HELD


	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		..()
		playsound(hit_atom.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, 1)
		if(ismob(hit_atom))
			var/mob/living/L = hit_atom
			L.changeStatus("weakened", 2 SECONDS)
			L.force_laydown_standup()

	throw_at(atom/target, range, speed, list/params, turf/thrown_from, throw_type = 1,
			allow_anchored = 0, bonus_throwforce = 0, end_throw_callback = null)
		..()
		if(ismob(usr))
			var/mob/living/L = usr
			L.changeStatus("stunned", 2 SECONDS)
