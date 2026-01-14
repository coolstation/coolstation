/// ----- ABSTRACT ROBOT3 -----
/// This should contain any function that every single robot3 needs as a mob
ABSTRACT_TYPE(/mob/living/critter/robotic/robot3)
/mob/living/critter/robotic/robot3
	name = "robot"
	desc = "A concept of what a robot should be."
	mob_flags = USR_DIALOG_UPDATES_RANGE
	canmove = FALSE
	var/datum/ai_laws/laws
	var/list/datum/robot3_mechanism/parts = list()

/// When attacked by a robot3 part, attempts to add it to the robot3
/mob/living/critter/robotic/robot3/attackby(obj/item/I, mob/M)
	if(istype(I, /obj/item/robot3_part))
		var/obj/item/robot3_part/part = I
		if(src.add_mechanism(part.mechanism))
			M.u_equip(part)
			part.dropped(M)
			return
	. = ..()

/// Adds a mechanism and its associated functionality
/mob/living/critter/robotic/robot3/proc/add_mechanism(datum/robot3_mechanism/mechanism)
	return mechanism.on_attached(src)

/// Disables a mechanism, temporarily removing its functionality
/mob/living/critter/robotic/robot3/proc/disable_mechanism(datum/robot3_mechanism/mechanism)
	return mechanism.on_disabled(src)

/// Removes a mechanism, permanently removing its functionality
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
	var/power_draw = 0
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

/// When a mechanism is attached, it puts the physical part inside the robot3's contents and enables itself
/datum/robot3_mechanism/proc/on_attached(mob/living/critter/robotic/robot3/attached_to)
	SHOULD_CALL_PARENT(TRUE)
	src.owner = attached_to
	if(src.physical_obj)
		src.physical_obj.set_loc(src.owner)
	src.owner.parts |= src
	src.on_enabled()
	return TRUE

/// When a mechanism is removed, it drops the part to the loc of the robot3 and disables itself if enabled
/datum/robot3_mechanism/proc/on_removed()
	SHOULD_CALL_PARENT(TRUE)
	if(src.enabled)
		src.on_disabled()
	if(src.physical_obj)
		src.physical_obj.set_loc(src.owner.loc)
	src.owner.parts -= src
	src.owner = null
	return TRUE

/// Temporarily stops working. We keep the part and mechanism around, so that they can be repaired.
/// Any code for removing the mechanism functions goes here.
/datum/robot3_mechanism/proc/on_disabled()
	SHOULD_CALL_PARENT(TRUE)
	if(!src.enabled)
		return FALSE
	src.enabled = FALSE
	return TRUE

/// Turns the mechanism on.
/// Any functionality for adding the mechanism functions goes here.
/datum/robot3_mechanism/proc/on_enabled()
	SHOULD_CALL_PARENT(TRUE)
	if(src.enabled || !src.health)
		return FALSE
	src.enabled = TRUE
	return TRUE

/// Take damage to the mechanism and shut down if at 0
/datum/robot3_mechanism/proc/take_damage(var/damage)
	SHOULD_CALL_PARENT(TRUE)
	src.health = max(0, src.health - damage)
	if(!src.health && src.enabled)
		src.on_disabled()
		return FALSE
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

/// ----- ABSTRACT LIMB MECHANISM -----
/// This adds a limb.
ABSTRACT_TYPE(/datum/robot3_mechanism/limb)
/datum/robot3_mechanism/limb
	var/limb_type = /datum/limb
	var/datum/handHolder/hand

/datum/robot3_mechanism/limb/on_enabled()
	. = ..()
	if(.)
		src.hand = src.owner.add_a_limb(src.limb_type)

/datum/robot3_mechanism/limb/on_disabled()
	. = ..()
	if(.)
		if(src.hand.item)
			src.hand.item.set_loc(src.owner.loc)
			src.owner.u_equip(src.hand.item)
			src.hand.item.dropped()
		src.owner.hand_count--
		src.owner.hands -= src.hand
		qdel(src.hand)
		src.hand = null

/// ----- ABSTRACT LIMB PART -----
ABSTRACT_TYPE(/obj/item/robot3_part/limb)
/obj/item/robot3_part/limb

/// ----- CONCRETE LIMBS -----
/datum/robot3_mechanism/limb/manipulator
	name = "manipulator"
	description = "A small robotic limb with a precise but weak hand."
	health = 15
	max_health = 15
	limb_type = /datum/limb/small_critter

/obj/item/robot3_part/limb/manipulator
	name = "manipulator component"
	desc = "A small robotic limb with a precise but weak hand."
	mechanism_type = /datum/robot3_mechanism/limb/manipulator

/// ----- ABSTRACT STORAGE MECHANISM -----
/// Anything in the permanent_storage list of this item is considered undroppable.
ABSTRACT_TYPE(/datum/robot3_mechanism/storage)
/datum/robot3_mechanism/storage
	var/list/atom/movable/permanent_storage = list()

/datum/robot3_mechanism/storage/proc/add_to_permanent_storage(atom/movable/AM)
	src.permanent_storage |= AM
	src.RegisterSignal(AM, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC), PROC_REF(return_to_permanent_storage))

/datum/robot3_mechanism/storage/proc/return_to_permanent_storage(atom/movable/AM)
	SPAWN_DBG(0)
		if(AM.loc != src.physical_obj && (!src.owner || AM.loc != src.owner))
			AM.set_loc(src.physical_obj)
	return

/datum/robot3_mechanism/storage/disposing()
	for(var/atom/movable/AM as anything in src.permanent_storage)
		src.UnregisterSignal(AM, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC))
		qdel(AM)
	src.permanent_storage = null
	. = ..()

/// ----- ABSTRACT STORAGE PART -----
/// Anything in the contents of this item is considered stored.
ABSTRACT_TYPE(/datum/robot3_part/storage)
/obj/item/robot3_part/storage

