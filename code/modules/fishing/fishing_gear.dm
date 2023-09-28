//file for da fishin gear

// rod flags are WIP, nonfunctional yet
#define ROD_WATER (1<<0) //can it fish in water?

/obj/item/fishing_rod
	name = "fishing rod"
	icon = 'icons/obj/items/fishing_gear.dmi'
	icon_state = "fishing_rod-inactive"
	inhand_image_icon = 'icons/mob/inhand/hand_fishing.dmi'
	item_state = "fishing_rod-inactive"
	/// average time to fish up something, in seconds - will vary on the upper and lower bounds by a maximum of 4 seconds, with a minimum time of 0.5 seconds.
	var/fishing_speed = 8 SECONDS
	/// how long to wait between casts in seconds - mainly so sounds dont overlap
	var/fishing_delay = 2 SECONDS
	/// set to TIME when fished, value is checked when deciding if the rod is currently on cooldown
	var/last_fished = 0
	/// true if the rod is currently "fishing", false if it isnt
	var/is_fishing = false

	//todo: attack particle?? some sort of indicator of where we're fishing
	afterattack(atom/target, mob/user)
		if (target && user && (src.last_fished < TIME + src.fishing_delay))
			var/datum/fishing_spot/fishing_spot = global.fishing_spots[target.type]
			if (fishing_spot)
				actions.start(new /datum/action/fishing(user, src, fishing_spot, target), user)

	proc/update_icon()
		//state for fishing
		if (src.is_fishing)
			src.icon_state = "fishing_rod-active"
			src.item_state = "fishing_rod-active"
		//state for not fishing
		else
			src.icon_state = "fishing_rod-inactive"
			src.item_state = "fishing_rod-inactive"

/// (invisible) action for timing out fishing. this is also what lets the fishing spot know that we fished
/datum/action/fishing
	var/mob/user = null
	/// the target of the action
	var/atom/target = null
	/// what fishing rod triggered this action
	var/obj/item/fishing_rod/rod = null
	/// the fishing spot that the rod is fishing from
	var/datum/fishing_spot/fishing_spot = null
	/// how long the fishing action loop will take in seconds, set on onStart(), varies by 4 seconds in either direction.
	duration = 0
	/// id for fishing action
	id = "fishing_for_fishies"

	New(var/user, var/rod, var/fishing_spot, var/target)
		..()
		src.user = user
		src.rod = rod
		src.fishing_spot = fishing_spot
		src.target = target

	onStart()
		..()
		if (!IN_RANGE(src.user, src.rod, 1) || !IN_RANGE(src.user, src.target, 1) || !src.user || !src.target || !src.rod || !src.fishing_spot)
			interrupt(INTERRUPT_ALWAYS)
			return

		src.duration = max(0.5 SECONDS, rod.fishing_speed + (pick(1, -1) * (rand(0,40) / 10) SECONDS)) //translates to rod duration +- (0,4) seconds, minimum of 0.5 seconds
		playsound(src.user, "sound/items/fishing_rod_cast.ogg", 50, 1)
		src.user.visible_message("[src.user] starts fishing.")
		src.rod.is_fishing = true
		src.rod.update_icon()
		src.user.update_inhands()

	onUpdate()
		..()
		if (!IN_RANGE(src.user, src.rod, 1) || !IN_RANGE(src.user, src.target, 1) || !src.user || !src.target || !src.rod || !src.fishing_spot)
			interrupt(INTERRUPT_ALWAYS)
			src.rod.is_fishing = false
			src.rod.update_icon()
			src.user.update_inhands()
			return

	onEnd()
		if (!IN_RANGE(src.user, src.rod, 1) || !IN_RANGE(src.user, src.target, 1) || !src.user || !src.target || !src.rod || !src.fishing_spot)
			..()
			interrupt(INTERRUPT_ALWAYS)
			src.rod.is_fishing = false
			src.rod.update_icon()
			src.user.update_inhands()
			return

		if (src.fishing_spot.try_fish(src.user, src.rod, target)) //if it returns one we successfully fished, otherwise lets restart the loop
			..()
			src.rod.is_fishing = false
			src.rod.update_icon()
			src.user.update_inhands()
			return

		else //lets restart the action
			src.onRestart()

	onInterrupt()
		..()
		src.rod.is_fishing = false
		src.rod.update_icon()
		src.user.update_inhands()
		return


/obj/item/fishing_rod/enhanced //for testing/admin shenanigans
	name = "enhanced fibreglass telescope ultralight 47" //droods
	desc = "The latest model"
	fishing_speed = -4 SECONDS
	fishing_delay = 0.1 SECONDS

	New()
		..()
		src.setMaterial(getMaterial("carbonfibre"), appearance = 1, setname = 0)
		return .

/obj/item/fishing_rod/rancher //for the rancher
	name = "bamboo fishing rod"
	desc = "More effective than your average fishing rod"
	fishing_speed = 4 SECONDS
	fishing_delay = 2 SECONDS

	New()
		..()
		src.setMaterial(getMaterial("bamboo"), appearance = 1, setname = 0)
		return .


// portable fishing portal currently found in a prefab in space
/obj/item/fish_portal
	name = "Fishing Portal Generator"
	desc = "A small device that creates a portal you can fish in."
	icon = 'icons/obj/items/fishing_gear.dmi'
	icon_state = "fish_portal"
	mats = 11

	attack_self(mob/user as mob)
		new /obj/machinery/active_fish_portal(get_turf(user))
		playsound(src.loc, 'sound/items/miningtool_on.ogg', 40)
		user.visible_message("[user] flips on the [src].", "You turn on the [src].")
		user.u_equip(src)
		qdel(src)

/obj/machinery/active_fish_portal
	name = "Fishing Portal"
	desc = "A portal you can fish in. It's not big enough to go through."
	anchored = ANCHORED
	icon = 'icons/obj/items/fishing_gear.dmi'
	icon_state = "fish_portal-active"

	attack_hand(mob/user as mob)
		new /obj/item/fish_portal(get_turf(src))
		playsound(src.loc, 'sound/items/miningtool_off.ogg', 40)
		user.visible_message("[user] flips off the [src].", "You turn off the [src].")
		qdel(src)

TYPEINFO(/obj/item/syndie_fishing_rod)
	mats = list("MET-3"=15, "WOOD"=5)

/obj/item/syndie_fishing_rod
	name = "\improper Glaucus fishing rod"
	desc = "A high grade tactical fishing rod, completely impractical for reeling in bass."
	icon = 'icons/obj/items/fishing_gear.dmi'
	icon_state = "syndie_fishing_rod-inactive"
	inhand_image_icon = 'icons/mob/inhand/hand_fishing.dmi'
	item_state = "syndie_fishing_rod-inactive"
	hit_type = DAMAGE_STAB
	flags = FPRINT | TABLEPASS | USEDELAY
	w_class = W_CLASS_NORMAL
	force = 10
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	contraband = 4
	is_syndicate = TRUE
	tooltip_flags = REBUILD_DIST
	var/obj/item/syndie_lure/lure = null
	/// delay between tossing or reeling or etc
	var/usage_cooldown = 0.8 SECONDS
	/// time per step to reel/filet a mob
	var/syndie_fishing_speed = 0.7 SECONDS
	/// cooldown after throwing a hooked target around
	var/yank_cooldown = 6 SECONDS
	/// how far you throw when yanking them
	var/yank_range = 4
	/// how far the line can stretch
	var/line_length = 8
	/// true if the rod is currently ""fishing"", false if it isnt
	var/is_fishing = FALSE
	hint = "The Glaucus starts with 7 damage on a melee reel, but stores up 3 onetime bonus damage on each ranged reel. If this reaches <b>25 damage</b>, or 6 ranged reels before a melee reel, the target will be stunned when damaged."

	New()
		..()
		src.reset_lure()
		RegisterSignal(src, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(max_range_check))

	get_desc(dist)
		..()
		if (dist < 1 && src.lure) // on our tile or our person and a lure exists
			. += "There is \a [src.lure.name] presented as bait."

	attackby(obj/item/I, mob/user)
		src.reset_lure()
		if (src.lure.loc == src)
			boutput(user, "You scan \the [I.name] onto \the [src.name]'s holographic bait projector.")
			src.lure.real_name = I.name
			src.lure.name = I.name
			src.lure.desc = I.desc
			src.lure.appearance = I
			src.lure.set_dir(I.dir)
			src.lure.overlay_refs = I.overlay_refs?.Copy()
			src.lure.plane = initial(src.lure.plane)
			src.lure.layer = initial(src.lure.layer)
			src.lure.tooltip_rebuild = 1
			tooltip_rebuild = 1
		else
			boutput(user, "You can't change the bait while the line is out!")
		return

	attack_self(mob/user)
		. = ..()
		src.reset_lure()
		if (src.lure.loc == src)
			boutput(user, "You clean \the [src.name]'s holographic bait projector.")
			src.lure.clean_forensic()
		else
			if(!src.lure.owner)
				if(BOUNDS_DIST(src.lure,src) == 0)
					src.is_fishing = FALSE
					src.update_icon()
					user.update_inhands()
					src.lure.set_loc(src)
				else
					if (!istype(src.lure.loc, /turf))
						src.lure.set_loc(get_turf(src.lure.loc))
					else
						step_towards(src.lure, src)
			else
				user.visible_message("<span class='alert'><b>[user] yanks the lure out of [src.lure.owner]!</b></span>")
				src.lure.set_loc(get_turf(src.lure.loc))
				src.lure.owner = null

	pixelaction(atom/target, params, mob/user, reach)
		..()
		return null

	afterattack(atom/target, mob/user)
		..()
		if (!isturf(user.loc))
			return
		src.reset_lure()
		if (!ON_COOLDOWN(user, "syndie_fishing_delay", src.usage_cooldown))
			if (src.lure.owner && isliving(src.lure.owner))
				logTheThing(LOG_COMBAT, user, "at [log_loc(src)] reels in a Syndicate Fishing Rod hooked in [src.lure.owner]")
				if (!actions.hasAction(user,"fishing_for_fools"))
					actions.start(new /datum/action/bar/syndie_fishing(user, src.lure.owner, src, src.lure), user)
				if (!ON_COOLDOWN(user, "syndie_fishing_yank", src.yank_cooldown))
					src.lure.owner.throw_at(target, yank_range, yank_range / 4)
					user.visible_message("<span class='alert'><b>[user] thrashes [src.lure.owner] by yanking \the [src.name]!</b></span>")
			else if (src.lure.loc == src)
				if (target == loc)
					return
				logTheThing(LOG_COMBAT, user, "casts a Syndicate Fishing Rod out at [log_loc(src)]")
				playsound(user, 'sound/items/fishing_rod_cast.ogg', 50, 1)
				src.is_fishing = TRUE
				src.update_icon()
				user.update_inhands()
				src.lure.pixel_x = rand(-12, 12)
				src.lure.pixel_y = rand(-12, 12)
				src.lure.set_loc(get_turf(src.loc))
				src.lure.throw_at(target, src.line_length, 2)
			else
				src.pull_in_lure(user)

	update_icon()
		//state for fishing
		if (src.is_fishing)
			src.icon_state = "syndie_fishing_rod-active"
			src.item_state = "syndie_fishing_rod-active"
		//state for not fishing
		else
			src.icon_state = "syndie_fishing_rod-inactive"
			src.item_state = "syndie_fishing_rod-inactive"

	disposing()
		UnregisterSignal(src, XSIG_MOVABLE_TURF_CHANGED)
		UnregisterSignal(src.lure, XSIG_MOVABLE_TURF_CHANGED)
		qdel(src.lure)
		. = ..()

	proc/reset_lure()
		if (!src.lure)
			src.lure = new (src)
			src.lure.rod = src
			tooltip_rebuild = 1
			RegisterSignal(src.lure, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(max_range_check))
		if (src.lure.owner && src.lure.loc != src.lure.owner)
			src.lure.owner = null

	proc/max_range_check()
		if (get_dist(src, src.lure) > src.line_length) // this should not be GET_DIST
			src.pull_in_lure()

	// reels in, returns whether damage was dealt
	proc/reel_in(mob/target, mob/user, damage_on_reel = 7)
		target.setStatusMin("staggered", 4 SECONDS)
		if(BOUNDS_DIST(target, user) == 0)
			if (issilicon(target))
				user.visible_message("<span class='alert'><b>[user] tears some scrap out of [target] with \the [src.name]!</b></span>")
				playsound(target.loc, 'sound/impact_sounds/circsaw.ogg', 40, 1)
				random_burn_damage(target, damage_on_reel)
			else
				user.visible_message("<span class='alert'><b>[user] reels some meat out of [target] with \the [src.name]!</b></span>")
				playsound(target.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 50, 1)
				take_bleeding_damage(target, user, damage_on_reel, DAMAGE_CUT)
			random_brute_damage(target, damage_on_reel)
			if (damage_on_reel >= 25)
				target.changeStatus("weakened", sqrt(damage_on_reel) / 3 SECONDS)
				target.force_laydown_standup()
				if (target.bioHolder && target.bioHolder.Uid && target.bioHolder.bloodType)
					gibs(target.loc, blood_DNA=target.bioHolder.Uid, blood_type=target.bioHolder.bloodType, headbits=FALSE, source=target)
				else
					gibs(target.loc, headbits=FALSE, source=target)
			return TRUE
		else
			step_towards(target, user)
			return FALSE

	proc/pull_in_lure(mob/user)
		if (src.lure.owner)
			src.lure.owner.visible_message("\The [src.lure] rips out of [src.lure.owner]!", "\The [src.lure] rips out of you!")
			take_bleeding_damage(src.lure.owner, null, 5, DAMAGE_STAB)
		src.lure.set_loc(get_turf(src.lure))
		src.lure.owner = null
		src.lure.throw_at(src, 15, 2)
		SPAWN(0.2 SECONDS)
			if (src.lure)
				if (src.lure.owner)
					src.lure.owner.throw_at(src, 2, 2)
				else
					src.lure.set_loc(src)
					src.is_fishing = FALSE
					src.update_icon()
					if(istype(user))
						user.update_inhands()

/obj/item/syndie_lure
	name = "Captain's spare ID"
	icon = 'icons/obj/items/card.dmi'
	desc = "A standardized NanoTrasen microchipped identification card that contains data that is scanned when attempting to access various doors and computers."
	icon_state = "gold"
	throwforce = 5
	density = 0
	var/obj/item/syndie_fishing_rod/rod = null
	var/mob/owner

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

	attackby(obj/item/W, mob/user)
		if (src.try_embed(user))
			return
		..()

	attack_hand(mob/user)
		if (src.try_embed(user))
			return
		..()

	pickup(mob/user)
		if (src.try_embed(user))
			return
		..()

	pull(mob/user)
		if (src.try_embed(user))
			return
		..()

	Crossed(atom/movable/AM as mob|obj)
		if (ishuman(AM))
			var/mob/living/carbon/human/H = AM
			if(H.lying)
				src.try_embed(H, FALSE)
		..()

	Uncrossed(atom/movable/AM as mob|obj)
		if (ishuman(AM))
			var/mob/living/carbon/human/H = AM
			if(H.lying)
				src.try_embed(H, FALSE)
		..()

	throw_impact(mob/hit_atom, datum/thrown_thing/thr)
		if (istype(hit_atom))
			src.try_embed(hit_atom, FALSE)
			return
		return ..()

	proc/try_embed(mob/M, do_weaken = TRUE)
		if (istype(M) && isliving(M))
			var/area/AR = get_area(M)
			if (AR?.sanctuary || M.nodamage || (src.rod in M.equipped_list(check_for_magtractor = 0)))
				return TRUE
			if (do_weaken)
				M.changeStatus("weakened", 5 SECONDS)
				M.TakeDamage(M.hand == LEFT_HAND ? "l_arm": "r_arm", 15, 0, 0, DAMAGE_STAB)
			M.force_laydown_standup()

			src.owner = M
			src.set_loc(M)
			M.visible_message("<span class='alert'><b>[M] gets snagged by a fishing lure!</b></span>")
			logTheThing(LOG_COMBAT, M, "is caught by a barbed fishing lure at [log_loc(src)]")
			M.emote("scream")
			take_bleeding_damage(M, null, 10, DAMAGE_STAB)
			M.UpdateDamageIcon()
			return TRUE
		else
			return FALSE

	Eat(mob/M, mob/user, by_matter_eater)
		. = ..()
		M.emote("scream")
		M.TakeDamage("chest", 25, 0, 0, DAMAGE_CUT)
		M.visible_message("\The [src] tears a bunch of gore out of [M.name]!")
		if (M.bioHolder && M.bioHolder.Uid && M.bioHolder.bloodType)
			gibs(M.loc, blood_DNA=M.bioHolder.Uid, blood_type=M.bioHolder.bloodType, headbits=FALSE, source=M)
		else
			gibs(M.loc, headbits=FALSE, source=M)
		var/mob/living/carbon/human/H = M
		if (istype(H))
			if (H.organHolder)
				for(var/organ in list("right_kidney", "left_kidney", "liver", "stomach", "intestines", "spleen", "pancreas"))
					var/obj/item/organ/O = H.drop_organ(organ, M.loc)
					if (istype(O))
						O.throw_at(src.rod.loc, rand(3,6), rand(1,2))
		qdel(src)

	disposing()
		src.rod.lure = null
		. = ..()

//action (with bar) for reeling in a mob with the Glaucus
/datum/action/bar/syndie_fishing
	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_ACTION
	var/mob/user = null
	var/mob/target = null
	/// what fishing rod caught the mob
	var/obj/item/syndie_fishing_rod/rod = null
	/// what lure is snagged in the mob
	var/obj/item/syndie_lure/lure = null
	/// stores current damage per point blank reel and increases by 3 each cycle that target isnt point blank
	/// resets when damage is dealt
	var/damage_on_reel = 7
	/// how long a step of reeling takes, set onStart
	duration = 0
	/// id for fishing action
	id = "fishing_for_fools"

	New(var/user, var/target, var/rod, var/lure)
		..()
		src.user = user
		src.target = target
		src.rod = rod
		src.lure = lure

	onStart()
		..()

		src.duration = max(0.1 SECONDS, rod.syndie_fishing_speed)
		playsound(src.user, 'sound/items/fishing_rod_cast.ogg', 50, 1)
		APPLY_ATOM_PROPERTY(src.target, PROP_MOB_CANTSPRINT, src)
		APPLY_MOVEMENT_MODIFIER(src.target, /datum/movement_modifier/syndie_fishing, src)
		src.user.visible_message("[src.user] sets the hook!")
		src.rod.is_fishing = TRUE
		src.rod.update_icon()
		src.user.update_inhands()

	onEnd()
		..()
		if (!src.user || !src.target || !src.rod || !src.lure || (src.target == src.user) || !(src.lure.loc == src.target) || !(src.user.equipped() == src.rod) || !isturf(src.user.loc))
			interrupt(INTERRUPT_ALWAYS)
			return

		if (src.rod.reel_in(src.target, src.user, src.damage_on_reel))
			src.damage_on_reel = initial(src.damage_on_reel)
		else
			src.damage_on_reel += 3
		src.onRestart()

	onDelete()
		..()
		src.rod.is_fishing = FALSE
		src.rod.update_icon()
		src.user.update_inhands()
		if (src.lure.owner)
			src.lure.set_loc(get_turf(src.lure.loc))
			src.lure.owner = null
		REMOVE_ATOM_PROPERTY(src.target, PROP_MOB_CANTSPRINT, src)
		REMOVE_MOVEMENT_MODIFIER(src.target, /datum/movement_modifier/syndie_fishing, src)

