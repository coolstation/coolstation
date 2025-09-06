/obj/item/plasma_cutter
	name = "plasma cutter"
	desc = "An extremely bulky and dangerous device, this tool uses electricity from an attatched power store to superheat plasma able cut through nearly any material."
	icon = 'icons/obj/items/plasmacutter.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "base"
	item_state = "cutter"
	opacity = 0
	density = 0

	var/obj/tank/emergency_plasma/tank
	var/obj/reagent_dispensers/powerbank/powerbank

	flags = FPRINT | TABLEPASS | CONDUCT
	force = 20.0
	throwforce = 20.0
	throw_speed = 1
	throw_range = 3
	w_class = W_CLASS_GIGANTIC
	m_amt = 50000 //?

	var/power_cut_wall = 3
	var/time_cut_wall = 3 SECONDS

