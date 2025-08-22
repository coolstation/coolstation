/mob/living/robot3
	name = "robot"
	desc = "A concept of what a robot should be."
	mob_flags = USR_DIALOG_UPDATES_RANGE
	dna_to_absorb = 0
	var/datum/ai_laws/laws
	var/list/datum/robot_mechanism/parts = list()

ABSTRACT_TYPE(/datum/robot_mechanism)
/datum/robot_mechanism
	var/name = "abstract mechanism"
	var/description = "An abstracted idea of what a robot mechanism could be."
	var/obj/physical_obj

/datum/robot_mechanism/proc/on_attach(var/mob/living/robot3/attached_to)
	return TRUE

/datum/robot_mechanism/manipulator
	name = "manipulator"
	description = "A small robotic limb with a precise hand."

/mob/living/robot3/proc/add_mechanism(var/datum/robot_mechanism/mechanism_attached)
	src.parts.Add(mechanism_attached)
	mechanism_attached.on_attach(src)
	if(mechanism_attached.physical_obj)
		mechanism_attached.physical_obj.set_loc(src)

/mob/living/robot3/proc/add_mechanism_type(var/mechanism_type)
	src.add_mechanism(new mechanism_type(src))

