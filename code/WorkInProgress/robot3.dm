/// ----- ABSTRACT ROBOT3 -----
/// This should contain any function that every single robot3 needs as a mob
ABSTRACT_TYPE(/mob/living/critter/robotic/robot3)
/mob/living/critter/robotic/robot3
	name = "robot"
	desc = "A concept of what a robot should be."
	mob_flags = USR_DIALOG_UPDATES_RANGE
	var/datum/ai_laws/laws
	var/list/datum/robot3_mechanism/parts = list()

/mob/living/critter/robotic/robot3/attackby(obj/item/I, mob/M)
	if(istype(I, /obj/item/robot3_part))
		var/obj/item/robot3_part/part = I
		if(src.add_mechanism(part.mechanism))
			M.u_equip(part)
			part.dropped(M)
			return
	. = ..()

/mob/living/critter/robotic/robot3/proc/add_mechanism(datum/robot3_mechanism/mechanism)
	return mechanism.on_attached(src)

/mob/living/critter/robotic/robot3/proc/disable_mechanism(datum/robot3_mechanism/mechanism)
	return mechanism.on_disabled(src)

/mob/living/critter/robotic/robot3/proc/remove_mechanism(datum/robot3_mechanism/mechanism)
	return mechanism.on_removed(src)

/// ----- ABSTRACT ROBOT3 MECHANISM -----
/// This datum handles adding, breaking, and removing a part. This is where we handle damage, power draw, and everything else.
ABSTRACT_TYPE(/datum/robot3_mechanism)
/datum/robot3_mechanism
	var/name = "abstract robot mechanism"
	var/description = "An abstracted idea of what a robot mechanism could be."
	var/max_health = 0
	var/health = 0
	var/weight = 0
	var/enabled = FALSE
	var/mob/living/critter/robotic/robot3/owner
	var/obj/item/robot3_part/physical_obj

/datum/robot3_mechanism/New(obj/item/robot3_part/originator_physical_obj)
	. = ..()
	if(originator_physical_obj)
		src.physical_obj = originator_physical_obj

/datum/robot3_mechanism/disposing()
	src.on_disabled()
	if(!QDELETED(src.physical_obj))
		qdel(src.physical_obj)
		src.physical_obj = null
	if(src.owner)
		src.owner.parts -= src
		src.owner = null
	. = ..()

/datum/robot3_mechanism/proc/on_attached(mob/living/critter/robotic/robot3/attached_to)
	SHOULD_CALL_PARENT(TRUE)
	src.owner = attached_to
	if(src.physical_obj)
		src.physical_obj.set_loc(src.owner)
	src.owner.parts |= src
	src.on_enabled()
	return TRUE

/datum/robot3_mechanism/proc/on_removed()
	SHOULD_CALL_PARENT(TRUE)
	if(src.enabled)
		src.on_disabled()
	if(src.physical_obj)
		src.physical_obj.set_loc(src.owner.loc)
	src.owner.parts -= src
	src.owner = null
	return TRUE

/datum/robot3_mechanism/proc/on_disabled()
	SHOULD_CALL_PARENT(TRUE)
	if(!src.enabled)
		return FALSE
	src.enabled = FALSE
	return TRUE

/datum/robot3_mechanism/proc/on_enabled()
	SHOULD_CALL_PARENT(TRUE)
	if(src.enabled || !src.health)
		return FALSE
	src.enabled = TRUE
	return TRUE

/datum/robot3_mechanism/proc/take_damage(var/damage)
	SHOULD_CALL_PARENT(TRUE)
	if(!src.enabled)
		return FALSE
	src.health = max(0, src.health - damage)
	if(!src.health)
		src.on_disabled()
	return TRUE

/// ----- ABSTRACT ROBOT3 PART -----
/// This is the item that houses the mechanism datum. If either is destroyed, the other is.
ABSTRACT_TYPE(/obj/item/robot3_part)
/obj/item/robot3_part
	name = "abstract robot part"
	desc = "The metaphysical concept of what a robot part would be."
	var/mechanism_type
	var/datum/robot3_mechanism/mechanism

/obj/item/robot3_part/New()
	. = ..()
	src.mechanism = new src.mechanism_type(src)

/obj/item/robot3_part/disposing()
	if(!QDELETED(src.mechanism))
		qdel(src.mechanism)
	src.mechanism = null
	. = ..()

/// ----- BASE CONCRETE ROBOT3 -----
/mob/living/critter/robotic/robot3/basic
	name = "basic robot"
	desc = "A very basic robot."

/// ----- HAND MECHANISM -----
/// This adds a limb, technically, not a hand. However, all limbs are things you use to interact with the world
/// in the same way as a hand, so this naming scheme hopefully makes sense.
ABSTRACT_TYPE(/datum/robot3_mechanism/hand)
/datum/robot3_mechanism/hand
	var/limb_type = /datum/limb
	var/datum/handHolder/hand

/datum/robot3_mechanism/hand/on_enabled()
	. = ..()
	if(.)
		var/datum/handHolder/HH = new
		src.hand = HH
		HH.holder = src.owner
		src.owner.hand_count++
		src.owner.hands += HH
		HH.limb = new src.limb_type(src.owner)
		src.owner.hud.add_additional_hand()

/datum/robot3_mechanism/hand/on_disabled()
	. = ..()
	if(.)
		if(src.hand.item)
			src.hand.item.set_loc(src.owner.loc)
			src.owner.u_equip(src.hand.item)
			src.hand.item.dropped()
		src.owner.hand_count--
		qdel(src.hand)
		src.hand = null

ABSTRACT_TYPE(/obj/item/robot3_part/hand)

/// ----- CONCRETE HANDS -----
/datum/robot3_mechanism/hand/manipulator
	name = "manipulator"
	description = "A small robotic limb with a precise but weak hand."
	health = 15
	max_health = 15
	limb_type = /datum/limb/small_critter

/obj/item/robot3_part/hand/manipulator
	name = "manipulator component"
	desc = "A small robotic limb with a precise but weak hand."
	mechanism_type = /datum/robot3_mechanism/hand/manipulator
