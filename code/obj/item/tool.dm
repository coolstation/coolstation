/obj/item/tool
	name = "tool"
	desc = "Some sort of tool."
	icon = 'icons/obj/items/tools/tools.dmi'
	inhand_image_icon = 'icons/obj/items/tools/tools.dmi'

	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	w_class = W_CLASS_SMALL

	// sensible defaults
	force = 5.0
	throwforce = 5.0
	stamina_damage = STAMINA_ITEM_DMG * 5/4
	stamina_cost = STAMINA_ITEM_COST * 10/9
	stamina_crit_chance = STAMINA_CRIT_CHANCE * 2/5

	rand_pos = 8

	proc/on_use()
		return 1
