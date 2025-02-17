/proc/testMat()
	boutput(world, "[materialProps.len]")
	sleep(1 SECOND)
	usr.client.debug_variables(material_cache["cerenkite"])
	sleep(1 SECOND)
	usr.client.debug_variables(new/datum/material/metal/cerenkite())
	return

var/global/list/material_cache = list()
/atom/var/datum/material/material = null

/proc/isExploitableObject(var/atom/A)
	if(istype(A, /obj/item/tile) || istype(A, /obj/item/rods) || istype(A, /obj/item/sheet) || istype(A, /obj/item/cable_coil) || istype(A, /obj/item/raw_material/shard)) return 1
	return 0

/// Returns one of the base materials by id.
/proc/getMaterial(var/mat)
	if(mat in material_cache)
		return material_cache[mat]
	return null

/// Compares two materials to determine if stacking should be allowed.
/proc/isSameMaterial(var/datum/material/M1, var/datum/material/M2)
	if(isnull(M1) != isnull(M2))
		return 0
	if(isnull(M1) && isnull(M2))
		return 1
	return M1.mat_id == M2.mat_id

/// Called AFTER the material of the object was changed.
/atom/proc/onMaterialChanged()
	if(istype(src.material))
		explosion_resistance = material.hasProperty("density") ? round(material.getProperty("density") / 33) : explosion_resistance
		explosion_protection = material.hasProperty("density") ? round(material.getProperty("density") / 33) : explosion_protection
		if( !(flags & CONDUCT) && (src.material.getProperty("electrical") >= 50)) flags |= CONDUCT
	return


/// Simply removes a material from an object.
/atom/proc/removeMaterial()
	if(src.mat_changename)
		src.remove_prefixes(99)
		src.remove_suffixes(99)
		src.UpdateName()

	if(src.mat_changedesc)
		src.desc = initial(src.desc)

	src.alpha = initial(src.alpha)
	src.color = initial(src.color)

	src.UpdateOverlays(null, "material")

	src.material = null
	return

/// if a material is listed in here then we don't take on its color/alpha (maybe, if this works)
/atom/var/list/mat_appearances_to_ignore = null

/// Sets the material of an object. PLEASE USE THIS TO SET MATERIALS UNLESS YOU KNOW WHAT YOU'RE DOING.
/atom/proc/setMaterial(datum/material/mat1, appearance = 1, setname = 1)
	if(!istype(mat1))
		return

	if (src.mat_changename && setname)
		src.name_prefix(mat1.name ? mat1.name : "")
		src.UpdateName()

	if (src.mat_changedesc && setname)
		if (istype(src, /obj))
			var/obj/O2 = src
			O2.desc = "[!isnull(O2.real_desc) ? "[O2.real_desc]" : "[initial(O2.desc)]"] It is made of [mat1.name]."
		else
			src.desc = "[initial(src.desc)] It is made of [mat1.name]."

	var/set_color_alpha = 1
	src.alpha = 255
	src.color = null
	src.UpdateOverlays(null, "material")
	if (src.mat_changeappearance && appearance && mat1.applyColor)
		if (islist(src.mat_appearances_to_ignore) && length(src.mat_appearances_to_ignore))
			if (mat1.mat_id in src.mat_appearances_to_ignore)
				set_color_alpha = 0
		if (set_color_alpha)
			if (mat1.texture)
				src.setTexture(mat1.texture, mat1.texture_blend, "material")
			src.alpha = mat1.alpha
			src.color = mat1.color

	src.material = mat1
	mat1.triggerOnAdd(src)
	src.onMaterialChanged()

/// Returns a string for when a material fail or breaks depending on its material flags.
/proc/getMatFailString(var/flag)
	if(flag & MATERIAL_METAL && flag & MATERIAL_CRYSTAL && flag & MATERIAL_CLOTH)
		return "frays apart into worthless dusty fibers"
	if(flag & MATERIAL_METAL && flag & MATERIAL_CRYSTAL)
		return "cracks and shatters into unworkable dust"
	if(flag & MATERIAL_CLOTH && flag & MATERIAL_CRYSTAL)
		return "shatters into useless brittle fibers"
	if(flag & MATERIAL_ENERGY && flag & MATERIAL_CRYSTAL)
		return "violently disintegrates into vapor"
	if(flag & MATERIAL_ENERGY && flag & MATERIAL_METAL)
		return "shines brightly before self-vaporizing"
	if(flag & MATERIAL_ENERGY && flag & MATERIAL_CLOTH)
		return "bursts into flames and is gone almost instantly"
	if(flag & MATERIAL_ENERGY && flag & MATERIAL_ORGANIC)
		return "catches on fire and rapidly burns to ash"
	if(flag & MATERIAL_ORGANIC)
		return "crumbles into worthless slime"
	if(flag & MATERIAL_CRYSTAL)
		return "shatters to dust and blows away"
	if(flag & MATERIAL_METAL)
		return "disintegrates into useless flakes"
	if(flag & MATERIAL_CLOTH)
		return "frays apart into useless strands"
	if(flag & MATERIAL_ENERGY)
		return "suddenly vanishes into nothingness"
	if(flag & MATERIAL_RUBBER)
		return "melts into an unworkable pile of slop"
	return "comes apart"

/// Checks if a list of material ids matches a recipe and returns the recipe if a match is found. returns null if nothing matches it.
/proc/matchesMaterialRecipe(var/list/mat_ids)
	var/list/sorted_ids = sortList(mat_ids)
	for(var/datum/material_recipe/R in materialRecipes)
		if(R.requirements ~= sorted_ids) return R
	return null

/// Yes hello apparently we need a proc for this because theres a million types of different wires and cables.
/proc/applyCableMaterials(atom/C, datum/material/insulator, datum/material/conductor)
	if(!conductor) return // silly

	if(istype(C, /obj/cable))
		var/obj/cable/cable = C
		cable.insulator = insulator
		cable.conductor = conductor

		if (cable.insulator)
			cable.setMaterial(cable.insulator)
			cable.name = "[cable.insulator.name]-insulated [cable.conductor.name]-cable"
			cable.color = cable.insulator.color
		else
			cable.setMaterial(cable.conductor)
			cable.name = "uninsulated [cable.conductor.name]-cable"
			cable.color = cable.conductor.color

	else if(istype(C, /obj/item/cable_coil))
		var/obj/item/cable_coil/coil = C

		coil.insulator = insulator
		coil.conductor = conductor

		if (coil.insulator)
			coil.setMaterial(coil.insulator)
			coil.color = coil.insulator.color
		else
			coil.setMaterial(coil.conductor)
			coil.color = coil.conductor.color
		coil.updateName()
