
// misc gunse go here
ABSTRACT_TYPE(/obj/item/gun/modular/zip)
/obj/item/gun/modular/zip
	name = "zipgun"
	real_name = "zipgun"
	desc = "A staple gun welded and reconfigured to fire bullets. Barely. Make sure to spin the casings out."
	max_ammo_capacity = 1
	gun_DRM = GUN_ALL
	spread_angle = 4
	icon_state = "zip"
	load_time = 1.3 SECONDS
	barrel_overlay_x = 7
	stock_overlay_x = -11
	grip_overlay_x = -8
	grip_overlay_y = -5
	bulkiness = 2
	w_class = W_CLASS_SMALL
	reload_cooldown = 0.9 SECONDS
	caliber = CALIBER_LONG_WIDE // it would just be disrespectful to this things history to not allow any ammo
	var/gonna_blow = FALSE

	shoot(var/target,var/start ,var/mob/user)
		if(src.gonna_blow)
			return
		var/failure_chance = 0
		if(src.current_projectile?.power)
			failure_chance = clamp(round(src.current_projectile.power * 0.67 - 15), -5, 30) + (length(src.casing_list) + src.ammo_reserve() + !!src.jammed * 5) * 5
		if(failure_chance > 0 && prob(failure_chance))
			if(prob(failure_chance))	// Sometimes the failure is obvious
				playsound(src.loc, "sound/impact_sounds/Metal_Hit_Heavy_1.ogg", 50, 1)
				boutput(user, SPAN_ALERT("The [src]'s shoddily thrown-together [pick("breech", "bullet holder", "firing pin", "striker", "staple-driver mechanism", "bendy metal part", "shooty-bit")][pick("", "...thing")] [pick("cracks", "pops off", "bends nearly in half", "comes loose")]! It's gonna blow!</span>"))
			else						// Other times, less obvious
				playsound(src.loc, "sound/impact_sounds/Generic_Snap_1.ogg", 50, 1)
			src.gonna_blow = TRUE
			SPAWN_DBG(rand(6, 10))
				if(!QDELETED(src))
					var/turf/T = get_turf(src)
					explosion_new(src, T, failure_chance / 7)
					qdel(src)
		return ..()

	load_ammo(var/mob/user, var/obj/item/stackable_ammo/donor_ammo) // doesnt clear casings unless ya spin it
		if(src.ammo_reserve() < src.max_ammo_capacity)
			//single shot and chamber handling
			if(!src.current_projectile)
				boutput(user, "<span class='notice'>You stuff a cartridge down the barrel of [src].</span>")
				src.set_current_projectile(new donor_ammo.projectile_type())

				if (src.sound_type)
					playsound(src.loc, "sound/weapons/modular/[src.sound_type]-slowcycle.ogg", 60, 1)
				else
					playsound(src.loc, "sound/weapons/gunload_heavy.ogg", 60, 1)

			//load the magazine after the chamber
			else
				if (src.sound_type)
					playsound(src.loc, "sound/weapons/modular/[src.sound_type]-load[rand(1,2)].ogg", 10, 1)
				else
					playsound(src.loc, "sound/weapons/gunload_light.ogg", 10, 1, 0, 0.8)
					src.ammo_list += donor_ammo.projectile_type

			buildTooltipContent()

			//Since we load the chamber first anyway there's no process_ammo call anymore. This can stay though
			if (prob(src.jam_frequency)) //jammed just because this thing sucks to load or you're clumsy
				src.jammed = JAM_LOAD
				boutput(user, "<span class='notice'>Ah, damn, that doesn't go in that way....</span>")
				return FALSE
			return TRUE
		return FALSE

	on_spin_emote(mob/living/carbon/human/user)
		. = ..()
		src.eject_casings()

/obj/item/gun/modular/zip/base
	no_build = TRUE

/obj/item/gun/modular/zip/classic
	make_parts()
		barrel = new /obj/item/gun_parts/barrel/pipeframe(src)

// the MPRT
ABSTRACT_TYPE(/obj/item/gun/modular/MPRT)
/obj/item/gun/modular/MPRT
	name = "MPRT-7"
	desc = "A rocket-propelled grenade launcher licensed by the Space Irish Republican Army."
	icon_state = "mprt"
	item_state = "rpg7_empty"
	uses_multiple_icon_states = 1
	contraband = 8
	caliber = CALIBER_SPUD
	max_ammo_capacity = 1
	gun_DRM = GUN_FOSS
	barrel_overlay_x = 5
	stock_overlay_x = -6
	grip_overlay_x = -4
	grip_overlay_y = -5
	bulkiness = 4
	w_class = W_CLASS_NORMAL
	jam_frequency = -1

	shoot()
		. = ..()
		if(!src.current_projectile)
			src.UpdateOverlays(null, "warhead")
			src.item_state = "rpg7_empty"
			if (ishuman(src.loc))
				var/mob/living/carbon/human/H = src.loc
				H.update_inhands()

	build_gun()
		. = ..()
		max_ammo_capacity = 1
		buildTooltipContent()

	load_ammo(mob/user, obj/item/stackable_ammo/donor_ammo)
		if(!src.current_projectile)
			boutput(user, "<span class='notice'>You stuff \an [donor_ammo] down the barrel of \the [src].</span>")
			if(donor_ammo.caliber & CALIBER_SPUD)
				var/image/warhead = image(donor_ammo.icon, src, donor_ammo.icon_state, OBJ_LAYER - 0.02, EAST, src.barrel_overlay_x + src.barrel?.overlay_x, -1)
				src.UpdateOverlays(warhead, "warhead")
				src.item_state = "rpg7"
				if (ishuman(src.loc))
					var/mob/living/carbon/human/H = src.loc
					H.update_inhands()
				src.set_current_projectile(new donor_ammo.projectile_type())
				buildTooltipContent()
			else
				boutput(user, "<span class='notice'>It falls right through!</span>")
				if(donor_ammo.stack_type)
					new donor_ammo.stack_type(get_turf(src))
		return FALSE

/obj/item/gun/modular/MPRT/built
	glued = TRUE

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/MPRT(src)
		stock = new /obj/item/gun_parts/stock/MPRT(src)

// the singulo buster
ABSTRACT_TYPE(/obj/item/gun/modular/singularity_buster)
/obj/item/gun/modular/singularity_buster
	name = "Singularity Buster"
	desc = "An experimental rocket launcher designed to deliver various payloads in rocket format."
	icon_state = "antisingularity"
	item_state = "ntlauncher"
	caliber = CALIBER_SPUD
	max_ammo_capacity = 1
	gun_DRM = GUN_NANO
	barrel_overlay_x = 5
	stock_overlay_x = -6
	grip_overlay_x = -4
	grip_overlay_y = -5
	bulkiness = 4
	w_class = W_CLASS_NORMAL

	build_gun()
		. = ..()
		max_ammo_capacity = 1
		buildTooltipContent()

	load_ammo(mob/user, obj/item/stackable_ammo/donor_ammo)
		if(!src.current_projectile)
			boutput(user, "<span class='notice'>You stuff \an [donor_ammo] down the barrel of \the [src].</span>")
			if(donor_ammo.caliber & CALIBER_SPUD)
				src.set_current_projectile(new donor_ammo.projectile_type())
				buildTooltipContent()
			else
				boutput(user, "<span class='notice'>It falls right through!</span>")
				if(donor_ammo.stack_type)
					new donor_ammo.stack_type(get_turf(src))
		return FALSE

/obj/item/gun/modular/singularity_buster/built
	glued = TRUE

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/NT/singularity_buster(src)
		stock = new /obj/item/gun_parts/stock/NT/singularity_buster(src)
