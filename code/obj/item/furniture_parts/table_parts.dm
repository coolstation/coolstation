#define TABLE_WARNING(user) boutput(user, "<span class='alert'>You can't build a table under yourself! You'll have to build it somewhere adjacent instead.</span>")
/obj/item/furniture_parts/table
	name = "table parts"
	desc = "A collection of parts that can be used to make a table."
	check_existing_type = /obj/table

	afterattack(atom/target, mob/user)
		if (isturf(target) && target == get_turf(user))
			TABLE_WARNING(user)
			return
		else
			return ..()

	attack_self(mob/user)
		TABLE_WARNING(user)

#undef TABLE_WARNING

/obj/item/furniture_parts/table/desk
	name = "desk parts"
	desc = "A collection of parts that can be used to make a desk."
	icon = 'icons/obj/furniture/table_desk.dmi'
	furniture_type = /obj/table/auto/desk
	furniture_name = "desk"

/obj/item/furniture_parts/table/wood
	name = "wood table parts"
	desc = "A collection of parts that can be used to make a wooden table."
	icon = 'icons/obj/furniture/table_wood.dmi'
	furniture_type = /obj/table/wood/auto
	furniture_name = "wooden table"

/obj/item/furniture_parts/table/wood/round
	name = "round wood table parts"
	desc = "A collection of parts that can be used to make a round wooden table."
	icon = 'icons/obj/furniture/table_wood_round.dmi'
	furniture_type = /obj/table/wood/round/auto

/obj/item/furniture_parts/table/wood/desk
	name = "wood desk parts"
	desc = "A collection of parts that can be used to make a wooden desk."
	icon = 'icons/obj/furniture/table_wood_desk.dmi'
	furniture_type = /obj/table/wood/auto/desk
	furniture_name = "wooden desk"

/obj/item/furniture_parts/table/round
	name = "round table parts"
	desc = "A collection of parts that can be used to make a round table."
	icon = 'icons/obj/furniture/table_round.dmi'
	furniture_type = /obj/table/round/auto

/obj/item/furniture_parts/table/regal
	name = "regal table parts"
	desc = "A collection of parts that can be used to make a regal table."
	icon = 'icons/obj/furniture/table_regal.dmi'
	furniture_type = /obj/table/regal/auto

/obj/item/furniture_parts/table/clothred
	name = "red event table parts"
	desc = "A collection of parts that can be used to make a red event table."
	icon = 'icons/obj/furniture/table_clothred.dmi'
	furniture_type = /obj/table/clothred/auto

/obj/item/furniture_parts/table/checkercloth
	name = "red event table parts"
	desc = "A collection of parts that can be used to make a red event table."
	icon = 'icons/obj/furniture/table_checkercloth.dmi'
	furniture_type = /obj/table/clothchecker/auto

/obj/item/furniture_parts/table/folding
	name = "folded folding table"
	desc = "A collapsed table that can be deployed quickly."
	icon = 'icons/obj/furniture/table_folding.dmi'
	furniture_type = /obj/table/folding
	furniture_name = "folding table"
	build_duration = 15

/obj/item/furniture_parts/table/bin
	name = "folded bin"
	desc = "A collapsed bin that can be deployed quickly."
	icon = 'icons/obj/scrap.dmi'
	icon_state = "hopperfolded"
	furniture_type = /obj/table/folding/bin
	furniture_name = "bin"
	build_duration = 15

/* ---------- Glass Table Parts ---------- */
/obj/item/furniture_parts/table/glass
	name = "glass table parts"
	desc = "A collection of parts that can be used to make a glass table."
	icon = 'icons/obj/furniture/table_glass.dmi'
	mat_appearances_to_ignore = list("glass")
	furniture_type = /obj/table/glass/auto
	furniture_name = "glass table"
	var/has_glass = 1
	var/default_material = "glass"

	New()
		..()
		if (!src.material && default_material)
			var/datum/material/M
			M = getMaterial(default_material)
			src.setMaterial(M)

	UpdateName()
		if (!src.has_glass)
			src.name = "glass table frame[name_suffix(null, 1)]"
		else
			src.name = name_prefix(null, 1)
			if (length(src.name)) // name_prefix() returned something so we have some kinda material, probably
				src.name = "[src.reinforced ? "reinforced " : null][src.name]table parts[name_suffix(null, 1)]"
			else
				src.name = "[initial(src.name)][name_suffix(null, 1)]"

/obj/item/furniture_parts/table/glass/frame
	name = "glass table frame"
	desc = "A collection of parts that can be used to make a frame for a glass table. It has no glass, though."
	icon_state = "e_table_parts"
	furniture_type = /obj/table/glass/frame/auto
	furniture_name = "glass table frame"
	has_glass = 0

/obj/item/furniture_parts/table/glass/reinforced
	name = "reinforced glass table parts"
	desc = "A collection of parts that can be used to make a reinforced glass table."
	icon_state = "r_table_parts"
	furniture_type = /obj/table/glass/reinforced/auto
	furniture_name = "reinforced glass table"

/* ---------- Reinforced Table Parts ---------- */
/obj/item/furniture_parts/table/reinforced
	name = "reinforced table parts"
	desc = "A collection of parts that can be used to make a reinforced table."
	icon = 'icons/obj/furniture/table_reinforced.dmi'
	reinforced = 1
	stamina_damage = 40
	stamina_cost = 22
	stamina_crit_chance = 15
	furniture_type = /obj/table/reinforced/auto
	furniture_name = "reinforced table"

/obj/item/furniture_parts/table/reinforced/industrial
	name = "industrial table parts"
	desc = "A collection of parts that can be used to make an industrial looking table."
	icon = 'icons/obj/furniture/table_industrial.dmi'
	furniture_type = /obj/table/reinforced/industrial/auto

/obj/item/furniture_parts/table/reinforced/bar
	name = "bar table parts"
	desc = "A collection of parts that can be used to make a bar table."
	icon = 'icons/obj/furniture/table_bar.dmi'
	furniture_type = /obj/table/reinforced/bar/auto
	furniture_name = "bar table"

/obj/item/furniture_parts/table/reinforced/roulette
	name = "roulette table parts"
	desc = "A collection of parts that can be used to make a roulette table."
	icon = 'icons/obj/furniture/table_bar.dmi'
	furniture_type = /obj/table/reinforced/roulette
	furniture_name = "roulette table"

/obj/item/furniture_parts/table/reinforced/chemistry
	name = "chemistry countertop parts"
	desc = "A collection of parts that can be used to make a chemistry table."
	icon = 'icons/obj/furniture/table_chemistry.dmi'
	furniture_type = /obj/table/reinforced/chemistry/auto
	furniture_name = "chemistry countertop"

/obj/item/furniture_parts/table/reinforced/medical
	name = "medical cabinet parts"
	desc = "A collection of parts that can be used to make a medical cabinet."
	icon = 'icons/obj/furniture/table_medical.dmi'
	furniture_type = /obj/table/reinforced/medical/auto
	furniture_name = "medical cabinet"

	solid
		name = "medical table parts"
		desc = "A collection of parts that can be used to make a medical table."
		icon = 'icons/obj/furniture/table_medical_solid.dmi'
		furniture_type = /obj/table/reinforced/medical/solid/auto
		furniture_name = "medical table"

/obj/item/furniture_parts/table/reinforced/kitchen
	name = "kitchen cabinet parts"
	desc = "A collection of parts that can be used to make a kitchen cabinet."
	icon = 'icons/obj/furniture/table_kitchen.dmi'
	furniture_type = /obj/table/reinforced/kitchen/auto
	furniture_name = "kitchen cabinet"

	solid
		name = "kitchen counter parts"
		desc = "A collection of parts that can be used to make a kitchen counter."
		icon = 'icons/obj/furniture/table_kitchen_solid.dmi'
		furniture_type = /obj/table/reinforced/kitchen/solid/auto
		furniture_name = "kitchen counter"
