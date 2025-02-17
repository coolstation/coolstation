/// material recipie definition
/datum/material_recipe
	var/name = ""
	/// ID of the result material. used as fallback or when you do not want to use a result item.
	var/result_id = null
	/// Path of the resulting material item.
	var/result_item = null
	/// Required materials
	var/list/datum/material/requirements

	/// called with the resultant item from the recipe as argument. Use this if you want to say, print a message when a recipe is made.
	proc/apply_to_obj(var/obj/O)
		return

/datum/material_recipe/spacelag
	name = "spacelag"
	result_id = "spacelag"
	requirements = list("slag", "neutronium")

/datum/material_recipe/dyneema
	name = "dyneema"
	result_id = "dyneema"
	requirements = list("carbonfibre", "spidersilk")

/datum/material_recipe/hauntium
	name = "hauntium"
	result_id = "hauntium"
	requirements = list("koshmarite", "soulsteel")

/datum/material_recipe/soulsteel
	name = "soul steel"
	result_id = "soulsteel"
	requirements = list("ectoplasm", "steel")

/datum/material_recipe/steel
	name = "steel"
	result_id = "steel"
	requirements = list("char", "mauxite")

/datum/material_recipe/electrum
	name = "electrum"
	result_id = "electrum"
	requirements = list("cobryl", "gold")

/datum/material_recipe/plasmasteel
	name = "plasmasteel"
	result_id = "plasmasteel"
	requirements = list("plasmastone", "steel")

/datum/material_recipe/plasmaglass
	name = "plasmaglass"
	result_id = "plasmaglass"
	requirements = list("plasmastone", "glass")

/datum/material_recipe/plasmaglass_molitz
	name = "plasmaglass"
	result_id = "plasmaglass"
	requirements = list("plasmastone", "molitz")

/datum/material_recipe/synthleather
	name = "synthleather"
	result_id = "synthleather"
	requirements = list("cotton", "latex")

/datum/material_recipe/synthblubber
	name = "synthblubber"
	result_id = "synthblubber"
	requirements = list("coral", "latex")
