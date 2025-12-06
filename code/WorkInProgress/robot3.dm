/mob/living/critter/robotic/robot3
	name = "robot"
	desc = "A concept of what a robot should be."
	mob_flags = USR_DIALOG_UPDATES_RANGE
	var/datum/ai_laws/laws
	var/list/datum/robot_mechanism/parts = list()

/mob/living/critter/robotic/robot3/proc/add_mechanism(datum/robot_mechanism/mechanism_attached)
	src.parts.Add(mechanism_attached)
	mechanism_attached.on_attach(src)
	if(mechanism_attached.physical_obj)
		mechanism_attached.physical_obj.set_loc(src)

/mob/living/critter/robotic/robot3/proc/add_mechanism_type(mechanism_type)
	src.add_mechanism(new mechanism_type(src))

ABSTRACT_TYPE(/datum/robot_mechanism)
/datum/robot_mechanism
	var/name = "abstract mechanism"
	var/description = "An abstracted idea of what a robot mechanism could be."
	var/max_health = 20
	var/health = 20
	var/weight = 1
	var/physical_obj_type
	var/obj/physical_obj

/datum/robot_mechanism/proc/on_attach(mob/living/critter/robotic/robot3/attached_to)
	return TRUE

ABSTRACT_TYPE(/datum/robot_mechanism/hand)
/datum/robot_mechanism/hand
	var/limb_type = /datum/limb

/datum/robot_mechanism/hand/manipulator
	name = "manipulator"
	description = "A small robotic limb with a precise but weak hand."
	limb_type = /datum/limb/small_critter

/datum/robot_mechanism/manipulator/on_attach(mob/living/critter/robotic/robot3/attached_to)
	var/datum/handHolder/HH = new
	HH.holder = src
	attached_to.hands += HH
	HH.limb = new src.limb_type(attached_to)
	attached_to.active_hand = length(attached_to.hands)
	attached_to.hand = attached_to.active_hand

