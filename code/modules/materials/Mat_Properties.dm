/// Base material property. Stuff like conductivity. See: [/datum/material/var/properties]
/datum/material_property
	/// External name of this property.
	var/name = ""
	/// Internal ID of this property.
	var/id = ""

	proc/onAdded(var/datum/material/M, var/new_value)
		return
	/*
	proc/onRemoved(var/datum/material/M)
		return
	*/
	proc/getAdjective(value)
		return "odd"

/datum/material_property/electrical_conductivity
	name = "Electrical conductivity"
	id = "electrical"

	getAdjective(value)
		switch(value)
			if(1 to 14)
				return "highly insulating"
			if(15 to 30)
				return "insulating"
			if(31 to 45)
				return "slightly insulating"
			if(46 to 65)
				return "slightly conductive"
			if(66 to 76)
				return "conductive"
			if(77 to 85)
				return "highly conductive"
			if(86 to INFINITY)
				return "extremely conductive"


/datum/material_property/thermal_conductivity
	name = "Thermal conductivity"
	id = "thermal"

	getAdjective(value)
		switch(value)
			if(1 to 14)
				return "very temperature-resistant"
			if(15 to 30)
				return "temperature-resistant"
			if(31 to 45)
				return "slightly temperature-resistant"
			if(46 to 65)
				return "slightly thermally-conductive"
			if(66 to 76)
				return "thermally-conductive"
			if(77 to 85)
				return "highly thermally-conductive"
			if(86 to INFINITY)
				return "extremely thermally-conductive"

/datum/material_property/hardness
	name = "Hardness"
	id = "hard"

	getAdjective(value)
		switch(value)
			if(1 to 10)
				return "very soft"
			if(11 to 25)
				return "soft"
			if(26 to 50)
				return "slightly soft"
			if(51 to 59)
				return "slightly hard"
			if(60 to 90)
				return "hard"
			if(90 to INFINITY)
				return "very hard"

/datum/material_property/density
	name = "Density"
	id = "density"

	getAdjective(value)
		switch(value)
			if(1 to 10)
				return "very light"
			if(11 to 25)
				return "light"
			if(26 to 50)
				return "somewhat light"
			if(51 to 59)
				return "somewhat dense"
			if(60 to 90)
				return "dense"
			if(90 to INFINITY)
				return "very dense"

/datum/material_property/reflectivity
	name = "Reflectivity"
	id = "reflective"

	getAdjective(value)
		switch(value)
			if(1 to 10)
				return "very dull"
			if(11 to 25)
				return "dull"
			if(26 to 50)
				return "slightly dull"
			if(51 to 75)
				return "slightly reflective"
			if(76 to 90)
				return "reflective"
			if(90 to INFINITY)
				return "very reflective"

	onAdded(var/datum/material/M, var/new_value)
		if(new_value >= 76)
			M.addTrigger(M.triggersOnBullet, new /datum/materialProc/reflective_onbullet())
		else
			M.removeTrigger(M.triggersOnBullet, /datum/materialProc/reflective_onbullet)
		return

/datum/material_property/flammability
	name = "Flammability"
	id = "flammable"

	getAdjective(value)
		switch(value)
			if(1 to 10)
				return "very fireproof"
			if(11 to 25)
				return "fireproof"
			if(26 to 50)
				return "slightly fireproof"
			if(51 to 75)
				return "slightly flammable"
			if(76 to 90)
				return "flammable"
			if(90 to INFINITY)
				return "very flammable"

/datum/material_property/corrosion
	name = "Corrosion resistance"
	id = "corrosion"

	getAdjective(value)
		switch(value)
			if(1 to 10)
				return "very corroded"
			if(11 to 25)
				return "corroded"
			if(26 to 50)
				return "slightly corroded"
			if(51 to 75)
				return "slightly corrosion-resistant"
			if(76 to 90)
				return "corrosion-resistant"
			if(90 to INFINITY)
				return "highly corrosion-resistant"

/datum/material_property/stability
	name = "Stability"
	id = "stability"

	getAdjective(value)
		switch(value)
			if(1 to 10)
				return "very unstable"
			if(11 to 25)
				return "unstable"
			if(26 to 50)
				return "slightly unstable"
			if(51 to 75)
				return "slightly solid"
			if(76 to 90)
				return "solid"
			if(90 to INFINITY)
				return "very solid"

/datum/material_property/permeability
	name = "Permeability"
	id = "permeable"

	getAdjective(value)
		switch(value)
			if(1 to 10)
				return "very impermeable"
			if(11 to 25)
				return "impermeable"
			if(26 to 50)
				return "slightly impermeable"
			if(51 to 75)
				return "slightly permeable"
			if(76 to 90)
				return "permeable"
			if(90 to INFINITY)
				return "very permeable"

/datum/material_property/radioactivity
	name = "Radioactivity"
	id = "radioactive"

	getAdjective(value)
		switch(value)
			if(1 to 10)
				return "slightly radioactive"
			if(11 to 25)
				return "somewhat radioactive"
			if(26 to 50)
				return "radioactive"
			if(51 to 75)
				return "very radioactive"
			if(76 to 90)
				return "extremely radioactive"
			if(90 to INFINITY)
				return "impossibly radioactive"

	onAdded(var/datum/material/M, var/new_value)
		M.addTrigger(M.triggersPickup, new /datum/materialProc/radioactive_pickup())
		M.addTrigger(M.triggersOnLife, new /datum/materialProc/radioactive_life())
		M.addTrigger(M.triggersOnAdd, new /datum/materialProc/radioactive_add())
		M.addTrigger(M.triggersOnEntered, new /datum/materialProc/radioactive_on_enter())
		return
/*
	onRemoved(var/datum/material/M)
		M.removeTrigger(M.triggersPickup, /datum/materialProc/radioactive_pickup)
		M.removeTrigger(M.triggersOnLife, /datum/materialProc/radioactive_life)
		M.removeTrigger(M.triggersOnAdd, /datum/materialProc/radioactive_add)
		M.removeTrigger(M.triggersOnEntered, /datum/materialProc/radioactive_on_enter)
		return
*/
/datum/material_property/neutron_radioactivity
	name = "Neutron Radioactivity"
	id = "n_radioactive"

	getAdjective(value)
		switch(value)
			if(1 to 10)
				return "glowing slightly blue"
			if(11 to 25)
				return "glowing somewhat blue"
			if(26 to 50)
				return "glowing blue"
			if(51 to 75)
				return "brightly glowing blue"
			if(76 to 90)
				return "brilliantly glowing blue"
			if(90 to INFINITY)
				return "blindingly glowing blue"

	onAdded(var/datum/material/M, var/new_value)
		M.addTrigger(M.triggersPickup, new /datum/materialProc/n_radioactive_pickup())
		M.addTrigger(M.triggersOnLife, new /datum/materialProc/n_radioactive_life())
		M.addTrigger(M.triggersOnAdd, new /datum/materialProc/n_radioactive_add())
		M.addTrigger(M.triggersOnEntered, new /datum/materialProc/n_radioactive_on_enter())
		return
/*
	onRemoved(var/datum/material/M)
		M.removeTrigger(M.triggersPickup, /datum/materialProc/n_radioactive_pickup)
		M.removeTrigger(M.triggersOnLife, /datum/materialProc/n_radioactive_life)
		M.removeTrigger(M.triggersOnAdd, /datum/materialProc/n_radioactive_add)
		M.removeTrigger(M.triggersOnEntered, /datum/materialProc/n_radioactive_on_enter)
		return
*/
/datum/material_property/fissile
	name = "Fissibility"
	id = "fissile"

	getAdjective(value)
		switch(value)
			if(1 to 10)
				return "barely fissile"
			if(11 to 25)
				return "somewhat fissile"
			if(26 to 50)
				return "fissile"
			if(51 to 75)
				return "very fissile"
			if(76 to 90)
				return "dangerously fissile"
			if(90 to INFINITY)
				return "supercritically fissile"

/datum/material_property/resonance // Just for molitz, not used for anything else and doubt it will be. Could tie instance boosts to resonance and give other mats resonance for purposes of being good to alloy with molitz.
	name = "Resonance"
	id = "resonance"

	getAdjective(value)
		switch(value)
			if(1 to 10)
				return "barely harmonic"
			if(11 to 25)
				return "somewhat harmonic"
			if(26 to 50)
				return "harmonic"
			if(51 to 75)
				return "very harmonic"
			if(76 to 90)
				return "dangerously harmonic"
			if(90 to INFINITY)
				return "supercritically harmonic"
