/*
CONTAINS:
TABLE PARTS(+wood,round,roundwood)
REINFORCED TABLE PARTS(+bar,chemistry)
RACK PARTS
*/

/* -------------------- Furniture Parts-------------------- */
ABSTRACT_TYPE(/obj/item/furniture_parts)
/obj/item/furniture_parts
	name = "furniture parts"
	desc = "A collection of parts that can be used to make some kind of furniture."
	icon = 'icons/obj/furniture/table.dmi'
	icon_state = "table_parts"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	flags = FPRINT | TABLEPASS | CONDUCT
	stamina_damage = 35
	stamina_cost = 22
	stamina_crit_chance = 10
	var/furniture_type = /obj/table/auto
	var/furniture_name = "table"
	var/reinforced = 0
	var/build_duration = 50
	var/obj/contained_storage = null // used for desks' drawers atm, if src is deconstructed it'll dump its contents on the ground and be deleted

	New(loc, obj/storage_thing)
		..()
		if (storage_thing)
			src.contained_storage = storage_thing
			src.contained_storage.set_loc(src)
		BLOCK_SETUP(BLOCK_LARGE)

	proc/construct(mob/user as mob, turf/T as turf)
		var/obj/newThing = null

		if (!T)
			T = user ? get_turf(user) : get_turf(src)
			if (!T) // buh??
				return
		if (ispath(src.furniture_type))
			newThing = new src.furniture_type(T, src.contained_storage ? src.contained_storage : null)
		else
			logTheThing("diary", user, null, "tries to build a piece of furniture from [src] ([src.type]) but its furniture_type is null and it is being deleted.", "station")
			user.u_equip(src)
			qdel(src)
			return

		if (newThing)
			if (src.material)
				newThing.setMaterial(src.material)
			if (src.color)
				newThing.color = src.color
			if (user)
				newThing.add_fingerprint(user)
				logTheThing("station", user, null, "builds \a [newThing] (<b>Material:</b> [newThing.material && newThing.material.mat_id ? "[newThing.material.mat_id]" : "*UNKNOWN*"]) at [log_loc(T)].")
				user.u_equip(src)
		qdel(src)
		return newThing

	proc/deconstruct(var/reinforcement = 0)
		if (src.contained_storage && length(src.contained_storage.contents))
			var/turf/T = get_turf(src)
			for (var/atom/movable/A in src.contained_storage)
				A.set_loc(T)
			var/obj/O = src.contained_storage
			src.contained_storage = null
			qdel(O)

		var/obj/item/sheet/A = new /obj/item/sheet(get_turf(src))
		if (src.material)
			A.setMaterial(src.material)
			if (reinforcement == 1)
				A.set_reinforcement(src.material)
				// will have to come back to this later
		else
			var/datum/material/M = getMaterial("steel")
			A.setMaterial(M)
			if (reinforcement == 1)
				A.set_reinforcement(M)

	attackby(obj/item/W as obj, mob/user as mob)
		if (iswrenchingtool(W))
			src.deconstruct(src.reinforced ? 1 : null)
			qdel(src)
		else
			return ..()

	attack_self(mob/user as mob)
		actions.start(new /datum/action/bar/icon/furniture_build(src, src.furniture_name, src.build_duration, get_turf(user)), user)


	afterattack(atom/target, mob/user)
		if (!isturf(target) || target.density)
			return ..()
		actions.start(new /datum/action/bar/icon/furniture_build(src, src.furniture_name, src.build_duration, target), user)

	disposing()
		if (src.contained_storage && length(src.contained_storage.contents))
			var/turf/T = get_turf(src)
			for (var/atom/movable/A in src.contained_storage)
				A.set_loc(T)
			var/obj/O = src.contained_storage
			src.contained_storage = null
			qdel(O)
		..()

	MouseDrop(atom/target, src_location, over_location, over_control, params)
		. = ..()
		if (HAS_ATOM_PROPERTY(usr, PROP_MOB_CAN_CONSTRUCT_WITHOUT_HOLDING) && isturf(target))
			actions.start(new /datum/action/bar/icon/furniture_build(src, src.furniture_name, src.build_duration, target), usr)


/* -------------------- Furniture Actions -------------------- */
/datum/action/bar/icon/furniture_build
	id = "furniture_build"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 5 SECONDS
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/item/furniture_parts/parts //! The parts we're building from
	var/furniture_name = "piece of furniture" //! Displayed name for the thing we're building (for chat)
	var/target_turf = null //! The turf we're trying to build on

	New(var/obj/item/furniture_parts/parts, var/name, var/duration, var/target_turf)
		..()
		src.parts = parts
		src.furniture_name = name
		src.target_turf = target_turf
		if (duration)
			src.duration = duration
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (parts == null || owner == null || BOUNDS_DIST(owner, parts) > 0 || BOUNDS_DIST(owner, target_turf) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		// cirrfix: ghost drones should be able to build furniture now
		if(istype(source))
			if(istype(source.equipped(), /obj/item/magtractor))
				// check to see it's holding the right thing
				var/obj/item/magtractor/M = source.equipped()
				if(parts != M.holding)
					interrupt(INTERRUPT_ALWAYS)
			else if (parts != source.equipped())
				interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		var/mob/living/blocker
		for (var/mob/living/L in target_turf)
			if (!(L.flags & TABLEPASS))
				blocker = L
				break

		if (blocker)
			boutput(owner, "<span class='alert'>You try to build \a [furniture_name], but [blocker] is in the way!</span>")
			interrupt(INTERRUPT_ALWAYS)
		else
			owner.visible_message("<span class='notice'>[owner] begins constructing \a [furniture_name]!</span>")

	onResume(datum/action/bar/icon/furniture_build/attempted) //guaranteed since we only resume with the same type
		..()
		if (attempted.target_turf != src.target_turf)
			interrupt(INTERRUPT_ALWAYS)

	onEnd()
		..()
		owner.visible_message("<span class='notice'>[owner] constructs \a [furniture_name]!</span>")
		parts.construct(owner, target_turf)

/datum/action/bar/icon/furniture_deconstruct
	id = "furniture_deconstruct"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
	duration = 50
	icon_state = "working"

	var/obj/the_furniture
	var/obj/item/the_tool

	New(var/obj/O, var/obj/item/tool, var/duration_i)
		..()
		if (O)
			the_furniture = O
			place_to_put_bar = O
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (the_furniture == null || the_tool == null || owner == null || get_dist(owner, the_furniture) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		playsound(the_furniture, "sound/items/Ratchet.ogg", 50, 1)
		owner.visible_message("<span class='notice'>[owner] begins disassembling [the_furniture].</span>")

	onEnd()
		..()
		playsound(the_furniture, "sound/items/Deconstruct.ogg", 50, 1)
		the_furniture:deconstruct() // yes a colon, bite me
		owner.visible_message("<span class='notice'>[owner] disassembles [the_furniture].</span>")
