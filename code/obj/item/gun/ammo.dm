///////////////// this type of ammo is being removed /////////////////

/obj/item/ammo
	name = "ammo"
	var/sname = "Generic Ammo"
	icon = 'icons/obj/items/ammo.dmi'
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "syringe_kit"
	m_amt = 40000
	g_amt = 0
	throwforce = 2
	w_class = W_CLASS_TINY
	throw_speed = 4
	throw_range = 20
	var/datum/projectile/ammo_type
	var/caliber = null
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 5
	inventory_counter_enabled = 1

	proc
		update_icon()
			return

		swap(var/obj/item/ammo/A)
			return

		use(var/amt = 0)
			return 0

/////////////////////////////// Bullets for kinetic firearms /////////////////////////////////

	// caliber list: update as needed
	// 0.223 - assault rifle
	// 0.308 - rifles
	// 0.355 - pistol (9mm)
	// 0.357 - revolver
	// 0.38 - detective
	// 0.41 - derringer
	// 0.72 - shotgun shell, 12ga
	//haha just kidding everything is 0.31 for light (bullet) or 0.62 for heavy (shot)
	// 0.787 - 20mm cannon round
	// 1.57 - 40mm grenade shell
	// 1.58 - RPG-7 (Tube is 40mm too, though warheads are usually larger in diameter.)


/obj/item/ammo/bullets
	name = "Ammo box"
	sname = "Bullets"
	desc = "A box of ammo"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 40000
	g_amt = 0
	caliber = 0.31 //doing it here because most of it's going to be here
	//var/cartridge_length = 20
	var/amount_left = 0.0
	var/max_amount = 1000
	var/unusualCell
	ammo_type = new/datum/projectile/bullet

	var/icon_dynamic = 0 // For dynamic desc and/or icon updates (Convair880).
	var/icon_short = null // If dynamic = 1, the short icon_state has to be specified as well.
	var/icon_empty = null

	// This is needed to avoid duplicating empty magazines (Convair880).
	var/delete_on_reload = 0
	var/force_new_current_projectile = 0 //for custom grenade shells

	var/sound_load = 'sound/weapons/gunload_light.ogg'

	New()
		..()
		SPAWN_DBG(2 SECONDS)
			if (!src.disposed)
				src.update_icon() // So we get dynamic updates right off the bat. Screw static descs.
		return

	use(var/amt = 0)
		if(amount_left >= amt)
			amount_left -= amt
			update_icon()
			return 1
		else
			src.update_icon()
			return 0

	attackby(obj/b as obj, mob/user as mob)
		if(istype(b, /obj/item/gun/kinetic) && b:allowReverseReload)
			b.Attackby(src, user)
		else if(b.type == src.type)
			var/obj/item/ammo/bullets/A = b
			if(A.amount_left<1)
				user.show_text("There's no ammo left in [A.name].", "red")
				return
			if(src.amount_left>=src.max_amount)
				user.show_text("[src] is full!", "red")
				return

			while ((A.amount_left > 0) && (src.amount_left < src.max_amount))
				A.amount_left--
				src.amount_left++
			if ((A.amount_left < 1) && (src.amount_left < src.max_amount))
				A.update_icon()
				src.update_icon()
				if (A.delete_on_reload)
					qdel(A) // No duplicating empty magazines, please (Convair880).
				user.visible_message("<span class='alert'>[user] refills [src].</span>", "<span class='alert'>There wasn't enough ammo left in [A.name] to fully refill [src]. It only has [src.amount_left] rounds remaining.</span>")
				return // Couldn't fully reload the gun.
			if ((A.amount_left >= 0) && (src.amount_left == src.max_amount))
				A.update_icon()
				src.update_icon()
				if (A.amount_left == 0)
					if (A.delete_on_reload)
						qdel(A) // No duplicating empty magazines, please (Convair880).
				user.visible_message("<span class='alert'>[user] refills [src].</span>", "<span class='alert'>You fully refill [src] with ammo from [A.name]. There are [A.amount_left] rounds left in [A.name].</span>")
				return // Full reload or ammo left over.
		else return ..()

	swap(var/obj/item/ammo/bullets/A, var/obj/item/gun/kinetic/K)
		// I tweaked this for improved user feedback and to support zip guns (Convair880).
		var/check = 0
		if (!A || !K)
			check = 0
		if (K.sanitycheck() == 0)
			check = 0
		if (A.caliber == K.caliber)
			check = 1
		else if (A.caliber in K.caliber) // Some guns can have multiple calibers.
			check = 1
		else if (K.caliber == null) // Special treatment for zip guns, huh.
			if (A.caliber == 1.58 || A.caliber == 6969)  // Prevent MRPT rocket & dueling rounds (have some honour)
				check = 0
			else
				check = 1
		if (!check)
			return 0
			//DEBUG_MESSAGE("Couldn't swap [K]'s ammo ([K.ammo.type]) with [A.type].")

		// The gun may have been fired; eject casings if so.
		K.ejectcasings()

		// We can't delete A here, because there's going to be ammo left over.
		if (K.max_ammo_capacity < A.amount_left)
			// Some ammo boxes have dynamic icon/desc updates we can't get otherwise.
			var/obj/item/ammo/bullets/ammoDrop = new K.ammo.type
			ammoDrop.amount_left = K.ammo.amount_left
			ammoDrop.name = K.ammo.name
			ammoDrop.icon = K.ammo.icon
			ammoDrop.icon_state = K.ammo.icon_state
			ammoDrop.ammo_type = K.ammo.ammo_type
			ammoDrop.delete_on_reload = 1 // No duplicating empty magazines, please.
			ammoDrop.update_icon()
			usr.put_in_hand_or_drop(ammoDrop)
			ammoDrop.after_unload(usr)
			K.ammo.amount_left = 0 // Make room for the new ammo.
			K.ammo.loadammo(A, K) // Let the other proc do the work for us.
			//DEBUG_MESSAGE("Swapped [K]'s ammo with [A.type]. There are [A.amount_left] round left over.")
			return 2

		else

			usr.u_equip(A) // We need a free hand for ammoHand first.

			// Some ammo boxes have dynamic icon/desc updates we can't get otherwise.
			var/obj/item/ammo/bullets/ammoHand = new K.ammo.type
			ammoHand.amount_left = K.ammo.amount_left
			ammoHand.name = K.ammo.name
			ammoHand.icon = K.ammo.icon
			ammoHand.icon_state = K.ammo.icon_state
			ammoHand.ammo_type = K.ammo.ammo_type
			ammoHand.delete_on_reload = 1 // No duplicating empty magazines, please.
			ammoHand.update_icon()
			usr.put_in_hand_or_drop(ammoHand)
			ammoHand.after_unload(usr)

			var/obj/item/ammo/bullets/ammoGun = new A.type // Ditto.
			ammoGun.amount_left = A.amount_left
			ammoGun.name = A.name
			ammoGun.icon = A.icon
			ammoGun.icon_state = A.icon_state
			ammoGun.ammo_type = A.ammo_type
			//DEBUG_MESSAGE("Swapped [K]'s ammo with [A.type].")
			qdel(K.ammo) // Make room for the new ammo.
			qdel(A) // We don't need you anymore.
			ammoGun.set_loc(K)
			K.ammo = ammoGun
			K.set_current_projectile(ammoGun.ammo_type)
			if(K.silenced)
				K.current_projectile.shot_sound = 'sound/machines/click.ogg'
			K.update_icon()

			return 1

	proc/loadammo(var/obj/item/ammo/bullets/A, var/obj/item/gun/kinetic/K)
		// Also see attackby() in kinetic.dm.
		if (!A || !K)
			return 0 // Error message.
		if (K.sanitycheck() == 0)
			return 0
		var/check = 0
		if (A.caliber == K.caliber)
			check = 1
		else if (A.caliber in K.caliber)
			check = 1
		else if (K.caliber == null)
			if (A.caliber > 1) // Prevent MRPT rocket
				check = 0
			else
				check = 1 // For zip guns.
		if (!check)
			return 1

		K.add_fingerprint(usr)
		A.add_fingerprint(usr)
		playsound(K, sound_load, 50, 1)

		if (K.ammo.amount_left < 0)
			K.ammo.amount_left = 0
		if (A.amount_left < 1)
			return 2 // Magazine's empty.
		if (K.ammo.amount_left >= K.max_ammo_capacity)
			if (K.ammo.ammo_type.type != A.ammo_type.type)
				return 6 // Call swap().
			return 3 // Gun's full.
		if (K.ammo.amount_left > 0 && K.ammo.ammo_type.type != A.ammo_type.type)
			return 6 // Call swap().

		else

			// The gun may have been fired; eject casings if so (Convair880).
			K.ejectcasings()

			// Required for swap() to work properly (Convair880).
			if (K.ammo.type != A.type || A.force_new_current_projectile)
				var/obj/item/ammo/bullets/ammoGun = new A.type
				ammoGun.amount_left = K.ammo.amount_left
				ammoGun.ammo_type = K.ammo.ammo_type
				qdel(K.ammo)
				ammoGun.set_loc(K)
				K.ammo = ammoGun
				K.set_current_projectile(A.ammo_type)
				if(K.silenced)
					K.current_projectile.shot_sound = 'sound/machines/click.ogg'

				//DEBUG_MESSAGE("Equalized [K]'s ammo type to [A.type]")

			var/move_amount = min(A.amount_left, K.max_ammo_capacity - K.ammo.amount_left)
			A.amount_left -= move_amount
			K.ammo.amount_left += move_amount
			K.ammo.ammo_type = A.ammo_type

			if ((A.amount_left < 1) && (K.ammo.amount_left < K.max_ammo_capacity))
				A.update_icon()
				K.update_icon()
				K.ammo.update_icon()
				if (A.delete_on_reload)
					//DEBUG_MESSAGE("[K]: [A.type] (now empty) was deleted on partial reload.")
					qdel(A) // No duplicating empty magazines, please (Convair880).
				return 4 // Couldn't fully reload the gun.
			if ((A.amount_left >= 0) && (K.ammo.amount_left == K.max_ammo_capacity))
				A.update_icon()
				K.update_icon()
				K.ammo.update_icon()
				if (A.amount_left == 0)
					if (A.delete_on_reload)
						//DEBUG_MESSAGE("[K]: [A.type] (now empty) was deleted on full reload.")
						qdel(A) // No duplicating empty magazines, please (Convair880).
				return 5 // Full reload or ammo left over.

	update_icon()
		if (src.amount_left < 0)
			src.amount_left = 0
		inventory_counter.update_number(src.amount_left)
		src.tooltip_rebuild = 1
		if (src.amount_left > 0)
			if (src.icon_dynamic && src.icon_short)
				src.icon_state = text("[src.icon_short]-[src.amount_left]")
			else if(src.icon_empty)
				src.icon_state = initial(src.icon_state)
		else
			if (src.icon_empty)
				src.icon_state = src.icon_empty
		return

	proc/after_unload(mob/user)
		return

	get_desc()
		return . += "There [src.amount_left == 1 ? "is" : "are"] [src.amount_left][ammo_type.material && istype(ammo_type.material, /datum/material/metal/silver) ? " silver " : " "]bullet\s left!"

/*
/obj/item/ammo/bullets/derringer
	sname = ".41 RF"
	name = ".41 ammo box"
	icon_state = "357-2"
	amount_left = 2.0
	max_amount = 2.0
	ammo_type = new/datum/projectile/bullet/derringer
	caliber = 0.41
	icon_dynamic = 1
	icon_short = "357"
	icon_empty = "357-0"

/obj/item/ammo/bullets/custom
	sname = "8mm Short Custom"
	name = "custom 8mm Short ammo box"
	icon_state = "custom-8"
	amount_left = 8.0
	max_amount = 8.0
	ammo_type = new/datum/projectile/bullet/custom
	caliber = 0.31
	icon_dynamic = 1
	icon_short = "custom"
	icon_empty = "custom-0"

	onMaterialChanged()
		ammo_type.material = src.material

		if(src.material)
			ammo_type.power = round(material.getProperty("density") / 2.75)
			ammo_type.dissipation_delay = round(material.getProperty("density") / 4)
			ammo_type.ks_ratio = max(0,round(material.getProperty("hard") / 75))

			if((src.material.material_flags & MATERIAL_CRYSTAL))
				ammo_type.damage_type = D_PIERCING
			if((src.material.material_flags & MATERIAL_METAL))
				ammo_type.damage_type = D_KINETIC
			if((src.material.material_flags & MATERIAL_ORGANIC))
				ammo_type.damage_type = D_TOXIC
			if((src.material.material_flags & MATERIAL_ENERGY))
				ammo_type.damage_type = D_ENERGY
			if((src.material.material_flags & MATERIAL_METAL) && (src.material.material_flags & MATERIAL_CRYSTAL))
				ammo_type.damage_type = D_SLASHING
			if((src.material.material_flags & MATERIAL_ENERGY) && (src.material.material_flags & MATERIAL_ORGANIC))
				ammo_type.damage_type = D_BURNING
			if((src.material.material_flags & MATERIAL_ENERGY) && (src.material.material_flags & MATERIAL_METAL))
				ammo_type.damage_type = D_RADIOACTIVE

		return ..()

/obj/item/ammo/bullets/bullet_22
	sname = "8mm Short"
	name = "8mm Short magazine"
	icon_state = "pistol_magazine"
	amount_left = 10.0
	max_amount = 10.0
	ammo_type = new/datum/projectile/bullet/pistol_weak

/obj/item/ammo/bullets/bullet_22HP
	sname = "8mm Short Hollow Point"
	name = "8mm Short HP magazine"
	icon_state = "pistol_magazine_hp"
	amount_left = 10.0
	max_amount = 10.0
	ammo_type = new/datum/projectile/bullet/pistol_weak/HP

/obj/item/ammo/bullets/a357
	sname = "Juicer Jr. Tandem"
	name = "Juicer Jr. speedloader"
	icon_state = "38-7"
	amount_left = 7.0
	max_amount = 7.0
	ammo_type = new/datum/projectile/bullet/pistol_heavy
	icon_dynamic = 1
	icon_short = "38"
	icon_empty = "speedloader_empty"

/obj/item/ammo/bullets/a357/AP
	sname = "Juicer Jr. Tandem AP"
	name = "Juicer Jr. AP speedloader"
	icon_state = "38A-7"
	ammo_type = new/datum/projectile/bullet/pistol_heavy/AP
	icon_dynamic = 1
	icon_short = "38A"
	icon_empty = "speedloader_empty"

/obj/item/ammo/bullets/a38
	sname = ".31 Italian"
	name = ".31 speedloader"
	icon_state = "38-7"
	amount_left = 7.0
	max_amount = 7.0
	ammo_type = new/datum/projectile/bullet/pistol_italian
	caliber = 0.31
	icon_dynamic = 1
	icon_short = "38"
	icon_empty = "speedloader_empty"

/obj/item/ammo/bullets/a38/AP
	sname = ".31 Italian AP"
	name = ".31 AP speedloader"
	icon_state = "38A-7"
	amount_left = 7.0
	max_amount = 7.0
	ammo_type = new/datum/projectile/bullet/pistol_italian/AP
	icon_dynamic = 1
	icon_short = "38A"
	icon_empty = "speedloader_empty"

/obj/item/ammo/bullets/a38/stun
	sname = "8mm Short Stun"
	name = "8mm Short Stun speedloader"
	icon_state = "38S-7"
	amount_left = 7.0
	max_amount = 7.0
	ammo_type = new/datum/projectile/bullet/pistol_weak/stunners
	icon_dynamic = 1
	icon_short = "38S"
	icon_empty = "speedloader_empty"

/obj/item/ammo/bullets/c_45
	sname = "Coalddt .31"
	name = "Coalddt .31 speedloader"
	icon_state = "38-7"
	amount_left = 7.0
	max_amount = 7.0
	ammo_type = new/datum/projectile/bullet/pistol_heavy
	caliber = 0.31
	icon_dynamic = 1
	icon_short = "38"
	icon_empty = "speedloader_empty"


/obj/item/ammo/bullets/airzooka
	name = "Airzooka Tactical Replacement Trashbag"
	sname = "air"
	desc = "A tactical trashbag for use in a Donk Co Airzooka."
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	icon_state = "trashbag"
	m_amt = 40000
	g_amt = 0
	amount_left = 10
	max_amount = 10
	ammo_type = new/datum/projectile/bullet/airzooka
	caliber = 4.6

/obj/item/ammo/bullets/airzooka/bad
	name = "Airzooka Tactical Replacement Trashbag: Xtreme Edition"
	sname = "air"
	desc = "A tactical trashbag for use in a Donk Co Airzooka, now with plasma lining."
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	icon_state = "biobag"
	m_amt = 40000
	g_amt = 0
	amount_left = 10
	max_amount = 10
	ammo_type = new/datum/projectile/bullet/airzooka/bad
	caliber = 4.6

/obj/item/ammo/bullets/nine_mm_NATO
	sname = "8mm Short"
	name = "8mm Short magazine"
	icon_state = "pistol_clip"	//9mm_clip that exists already. Also, put this in hacked manufacturers cause these bullets are not good.
	amount_left = 18.0
	max_amount = 18.0
	ammo_type = new/datum/projectile/bullet/pistol_weak

/obj/item/ammo/bullets/nine_mm_NATO/boomerang //empty clip for the clock_188/boomerang
	amount_left = 0

//concentrated juicer shot
/obj/item/ammo/bullets/a12
	sname = "Juicer HOT POCKETS Buckshot"
	name = "Juicer HOT POCKETS ammo box"
	ammo_type = new/datum/projectile/special/spreader/buckshot_burst/juicer
	icon_state = "12"
	amount_left = 8.0
	max_amount = 8.0
	caliber = 0.62
	icon_dynamic = 0
	icon_empty = "12-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'

	weak //for nuke ops engineer (probably going away)
		ammo_type = new/datum/projectile/special/spreader/buckshot_burst/juicer

//need to figure out where we're using this, maybe this is a feature of sawn off barrels
/obj/item/ammo/bullets/buckshot_burst // real spread shotgun ammo
	sname = "Buckshot"
	name = "buckshot ammo box"
	ammo_type = new/datum/projectile/special/spreader/buckshot_burst/
	icon_state = "12"
	amount_left = 8.0
	max_amount = 8.0
	caliber = 0.62
	icon_dynamic = 0
	icon_empty = "12-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'

/obj/item/ammo/bullets/nails // oh god oh fuck
	sname = "Nails"
	name = "nailshot ammo box"
	ammo_type = new/datum/projectile/special/spreader/buckshot_burst/nails
	icon_state = "custom-8"
	icon_short = "custom"
	amount_left = 8.0
	max_amount = 8.0
	caliber = 0.62
	icon_dynamic = 1
	icon_empty = "custom-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'

/obj/item/ammo/bullets/aex
	sname = "JUICER BOOMERS"
	name = "approximately 16mm explosive slug ammo box"
	ammo_type = new/datum/projectile/bullet/slug_boom
	icon_state = "AEX"
	amount_left = 8.0
	max_amount = 8.0
	caliber = 0.62
	icon_dynamic = 0
	icon_empty = "AEX-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'

/obj/item/ammo/bullets/abg
	sname = "16mm NT Rubber Slug"
	name = "16mm NT rubber slugs"
	ammo_type = new/datum/projectile/bullet/slug_rubber
	icon_state = "bg"
	amount_left = 8.0
	max_amount = 8.0
	caliber = 0.62
	icon_dynamic = 0
	icon_empty = "bg-0"
	sound_load = 'sound/weapons/gunload_click.ogg'

/obj/item/ammo/bullets/ak47
	sname = "2.8lin. Soviet" //just a little short of a three line rifle
	name = "SK-58 magazine"
	desc = "That's some seriously old ammo in there."
	ammo_type = new/datum/projectile/bullet/rifle_medium
	icon_state = "ak47"
	amount_left = 30.0
	max_amount = 30.0
	caliber = 0.31
	sound_load = 'sound/weapons/gunload_heavy.ogg'

//most of these are going away but might as well have fun with it until then
/obj/item/ammo/bullets/assault_rifle
	sname = ".31x40mm NT"
	name = "STENK magazine" //heh
	ammo_type = new/datum/projectile/bullet/rifle_weak
	icon_state = "stenag_mag"
	amount_left = 30.0
	max_amount = 30.0
	caliber = 0.31
	sound_load = 'sound/weapons/gunload_heavy.ogg'

	armor_piercing
		sname = ".31x40mm NT AP"
		name = "AP STENK magazine"
		ammo_type = new/datum/projectile/bullet/rifle_weak/AP
		icon_state = "stenag_mag-AP"

/obj/item/ammo/bullets/minigun
	sname = "8×40mm Italian"
	name = "Minigun cartridge"
	ammo_type = new/datum/projectile/bullet/minigun
	icon_state = "40mmR"
	icon_empty = "40mmR-0"
	amount_left = 100.0
	max_amount = 100.0
	caliber = 0.31
	sound_load = 'sound/weapons/gunload_heavy.ogg'

/obj/item/ammo/bullets/rifle_3006
	sname = "Juicer BIG AP"
	name = "Juicer BIG rifle magazine"
	ammo_type = new/datum/projectile/bullet/rifle_heavy/AP
	icon_state = "rifle_clip"
	amount_left = 4
	max_amount = 4
	caliber = 0.31

/obj/item/ammo/bullets/rifle_762_NATO
	sname = "Juicer BIG"
	name = "Juicer BIG magazine"
	ammo_type = new/datum/projectile/bullet/rifle_heavy
	icon_state = "rifle_box_mag" //todo
	amount_left = 4
	max_amount = 4
	caliber = 0.31

/obj/item/ammo/bullets/tranq_darts
	sname = "8mm Short Tranquilizer"
	name = "8mm Short tranquilizer darts"
	ammo_type = new/datum/projectile/bullet/tranq_dart
	icon_state = "tranq_clip"
	amount_left = 4
	max_amount = 4
	caliber = 0.31

	syndicate
		sname = ".31.0a Tranquilizer Deluxe"
		name = ".31.0a tranquilizer rifle darts"
		ammo_type = new/datum/projectile/bullet/tranq_dart/syndicate

		pistol
			sname = ".31.0a Tranqilizer"
			name = ".31.0a tranquilizer pistol darts"
			amount_left = 15
			max_amount = 15
			caliber = 0.31
			ammo_type = new/datum/projectile/bullet/tranq_dart/syndicate/pistol

	anti_mutant
		sname = "8mm Short Mutadone"
		name = "8mm Short mutadone darts"
		ammo_type = new/datum/projectile/bullet/tranq_dart/anti_mutant

/obj/item/ammo/bullets/vbullet
	sname = "VR bullets"
	name = "VR magazine"
	ammo_type = new/datum/projectile/bullet/vbullet
	icon_state = "ak47"
	amount_left = 200

/obj/item/ammo/bullets/flare
	sname = "16mm Flare"
	name = "16mm flares"
	amount_left = 8
	max_amount = 8
	icon_state = "flare"
	ammo_type = new/datum/projectile/bullet/flare
	caliber = 0.62
	icon_dynamic = 0
	icon_empty = "flare-0"

	single
		amount_left = 1
		max_amount = 1


/obj/item/ammo/bullets/cannon
	sname = "20mm APHE"
	name = "20mm APHE shells"
	amount_left = 5
	max_amount = 5
	icon_state = "40mmR"
	ammo_type = new/datum/projectile/bullet/cannon
	caliber = 0.787
	w_class = W_CLASS_SMALL
	icon_dynamic = 1
	icon_empty = "40mmR-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'

	single
		amount_left = 1
		max_amount = 1

*/

/obj/item/ammo/bullets/autocannon
	sname = "40mm HE"
	name = "40mm HE shells"
	amount_left = 2
	max_amount = 2
	icon_state = "40mmR"
	ammo_type = new/datum/projectile/bullet/autocannon
	caliber = 1.57
	w_class = W_CLASS_NORMAL
	icon_dynamic = 0
	icon_empty = "40mmR-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'
	value = 100000

	single
		amount_left = 1
		max_amount = 1

	seeker
		sname = "40mm HE Seeker"
		name = "40mm HE pod-seeking shells"
		ammo_type = new/datum/projectile/bullet/autocannon/seeker/pod_seeking

	knocker
		sname = "40mm HE Knocker"
		name = "40mm HE airlock-breaching shells"
		ammo_type = new/datum/projectile/bullet/autocannon/knocker

/obj/item/ammo/bullets/grenade_round
	sname = "40mm HEDP"
	name = "40mm HEDP shells"
	amount_left = 8
	max_amount = 8
	icon_state = "40mmR"
	ammo_type = new/datum/projectile/bullet/grenade_round/
	caliber = 1.57
	w_class = W_CLASS_NORMAL
	icon_dynamic = 0
	icon_empty = "40mmR-0"
	sound_load = 'sound/weapons/gunload_40mm.ogg'

	explosive
		desc = "High Explosive Dual Purpose grenade rounds compatible with grenade launchers. Effective against infantry and armour."
		ammo_type = new/datum/projectile/bullet/grenade_round/explosive

	high_explosive
		desc = "High Explosive grenade rounds compatible with grenade launchers. Devastatingly effective against infantry targets."
		sname = "40mm HE"
		name = "40mm HE shells"
		icon_state = "AEX"
		icon_empty = "AEX-0"
		ammo_type = new/datum/projectile/bullet/grenade_round/high_explosive

/obj/item/ammo/bullets/smoke
	sname = "40mm Smoke"
	name = "40mm smoke shells"
	amount_left = 5
	max_amount = 5
	icon_state = "40mmB"
	ammo_type = new/datum/projectile/bullet/smoke
	caliber = 1.57
	w_class = W_CLASS_NORMAL
	icon_dynamic = 0
	icon_empty = "40mmB-0"
	sound_load = 'sound/weapons/gunload_40mm.ogg'

	single
		amount_left = 1
		max_amount = 1

/obj/item/ammo/bullets/marker
	sname = "40mm Paint Marker Rounds"
	name = "40mm paint marker rounds"
	ammo_type = new/datum/projectile/bullet/marker
	amount_left = 5
	max_amount = 5
	icon_state = "40mmR"
	caliber = 1.57
	w_class = W_CLASS_NORMAL
	icon_dynamic = 0
	icon_empty = "40mmR-0"
	sound_load = 'sound/weapons/gunload_40mm.ogg'

/obj/item/ammo/bullets/pbr
	sname = "40mm Plastic Baton Rounds"
	name = "40mm plastic baton rounds"
	ammo_type = new/datum/projectile/bullet/pbr
	amount_left = 5
	max_amount = 5
	icon_state = "40mmB"
	caliber = 1.57
	w_class = W_CLASS_NORMAL
	icon_dynamic = 0
	icon_empty = "40mmB-0"
	sound_load = 'sound/weapons/gunload_40mm.ogg'

//basically an internal object for converting hand-grenades into shells, but can be spawned independently.
/obj/item/ammo/bullets/grenade_shell
	sname = "40mm Custom Shell"
	name = "40mm hand grenade conversion chamber"
	desc = "A 40mm shell used for converting hand grenades into impact detonation explosive shells"
	amount_left = 1
	max_amount = 1
	icon_state = "paintballr-4"
	ammo_type = new/datum/projectile/bullet/grenade_shell
	caliber = 1.57
	w_class = W_CLASS_NORMAL
	icon_dynamic = 0
	icon_empty = "paintballb-4"
	delete_on_reload = 0 //deleting it before the shell can be fired breaks things
	sound_load = 'sound/weapons/gunload_40mm.ogg'
	force_new_current_projectile = 1

	rigil
		max_amount = 4

	attackby(obj/item/W as obj, mob/living/user as mob)
		var/datum/projectile/bullet/grenade_shell/AMMO = src.ammo_type
		if(!W || !user)
			return
		if (istype(W, /obj/item/chem_grenade) || istype(W, /obj/item/old_grenade))
			if (AMMO.has_grenade == 0)
				AMMO.load_nade(W)
				user.u_equip(W)
				W.layer = initial(W.layer)
				W.set_loc(src)
				src.update_icon()
				boutput(user, "You load [W] into the [src].")
				return
			else if(src.amount_left < src.max_amount && W.type == AMMO.get_nade()?.type)
				src.amount_left++
				boutput(user, "You load [W] into the [src].")
			else
				boutput(user, "<span class='alert'>For <i>some reason</i>, you are unable to place [W] into an already filled chamber.</span>")
				return
		else
			return ..()

	attack_hand(mob/user as mob)
		var/datum/projectile/bullet/grenade_shell/AMMO = src.ammo_type
		if(!user)
			return
		if (src.loc == user && AMMO.has_grenade != 0)
			for(var/i in 1 to amount_left)
				user.put_in_hand_or_drop(SEMI_DEEP_COPY(AMMO.get_nade()))
			AMMO.unload_nade()
			boutput(user, "You pry the grenade[amount_left>1?"s":""] out of [src].")
			src.add_fingerprint(user)
			src.update_icon()
			return
		return ..()

	update_icon()
		inventory_counter.update_number(src.amount_left)
		var/datum/projectile/bullet/grenade_shell/AMMO = src.ammo_type
		if (AMMO.has_grenade != 0)
			src.icon_state = "40mmR"
		else
			src.icon_state = "40mmR-0"

	after_unload(mob/user)
		var/datum/projectile/bullet/grenade_shell/AMMO = src.ammo_type
		if(AMMO.has_grenade && src.delete_on_reload)
			for(var/i in 1 to amount_left)
				user.put_in_hand_or_drop(SEMI_DEEP_COPY(AMMO.get_nade()))
			AMMO.unload_nade()
			qdel(src)

/*
// Ported from old, non-gun RPG-7 object class (Convair880).
/obj/item/ammo/bullets/rpg
	sname = "MPRT rocket"
	name = "MPRT rocket"
	amount_left = 1
	max_amount = 1
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "rpg_rocket"
	ammo_type = new /datum/projectile/bullet/rpg
	caliber = 1.58
	w_class = W_CLASS_NORMAL
	delete_on_reload = 1
	sound_load = 'sound/weapons/gunload_heavy.ogg'

/obj/item/ammo/bullets/rod
	sname = "metal rod"
	name = "metal rod"
	force = 4
	amount_left = 2
	max_amount = 2
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "rod_1"
	ammo_type = new/datum/projectile/bullet/rod
	caliber = 1.0
	sound_load = 'sound/weapons/gunload_heavy.ogg'

/obj/item/ammo/bullets/bullet_9mm
	sname = ".31×20mm NT"
	name = ".31 Short magazine"
	icon_state = "pistol_magazine"
	amount_left = 15.0
	max_amount = 15.0
	ammo_type = new/datum/projectile/bullet/pistol_weak
	caliber = 0.31

	five_shots
		amount_left = 5.0

	smartgun
		name = ".31 Short smartgun magazine"
		amount_left = 24.0
		max_amount = 24.0
		ammo_type = new/datum/projectile/bullet/pistol_weak
		sound_load = 'sound/weapons/gunload_hitek.ogg'

	smg
		name = ".31 Short SMG magazine"
		amount_left = 30.0
		max_amount = 30.0
		ammo_type = new/datum/projectile/bullet/pistol_weak

/obj/item/ammo/bullets/lmg
	sname = "8x40mm Italian"
	name = "LMG belt"
	ammo_type = new/datum/projectile/bullet/lmg
	icon_state = "lmg_ammo"
	icon_empty = "lmg_ammo-0"
	amount_left = 100.0
	max_amount = 100.0
	caliber = 0.31
	sound_load = 'sound/weapons/gunload_heavy.ogg'

	weak
		sname = "8×40mm Italian W"
		name = "discount LMG belt"
		ammo_type = new/datum/projectile/bullet/lmg/weak
		amount_left = 25.0
		max_amount = 25.0
*/

//////////////////////////////////// Power cells for eguns //////////////////////////

/obj/item/ammo/power_cell
	name = "Power Cell"
	desc = "A power cell that holds a max of 100PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 10000
	g_amt = 20000
	var/charge = 100.0
	var/max_charge = 100.0
	var/recharge_rate = 0
	var/sound_load = 'sound/weapons/gunload_click.ogg'
	var/unusualCell = 0

	New()
		..()
		AddComponent(/datum/component/power_cell, max_charge, charge, recharge_rate)
		RegisterSignal(src, COMSIG_UPDATE_ICON, PROC_REF(update_icon))
		desc = "A power cell that holds a max of [src.max_charge]PU. Can be inserted into any energy gun, even tasers!"
		update_icon()

	disposing()
		processing_items -= src
		..()

	emp_act()
		SEND_SIGNAL(src, COMSIG_CELL_USE, INFINITY)
		return

	update_icon()
		if (src.artifact || src.unusualCell) return
		overlays = null
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.20) * 100
			inventory_counter.update_percent(ret["charge"], ret["max_charge"])
			switch(ratio)
				if(20)
					overlays += "cell_1/5"
				if(40)
					overlays += "cell_2/5"
				if(60)
					overlays += "cell_3/5"
				if(80)
					overlays += "cell_4/5"
				if(100)
					overlays += "cell_5/5"
			return

	examine()
		if (src.artifact)
			return list("You have no idea what this thing is!")
		. = ..()
		if (src.unusualCell)
			return
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			. += "There are [ret["charge"]]/[ret["max_charge"]] PU left!"


/obj/item/ammo/power_cell/med_power
	name = "Power Cell - 200"
	desc = "A power cell that holds a max of 200PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 15000
	g_amt = 30000
	charge = 200.0
	max_charge = 200.0

/obj/item/ammo/power_cell/med_plus_power
	name = "Power Cell - 250"
	desc = "A power cell that holds a max of 250PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 17500
	g_amt = 35000
	charge = 250.0
	max_charge = 250.0

/obj/item/ammo/power_cell/high_power
	name = "Power Cell - 300"
	desc = "A power cell that holds a max of 300PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 20000
	g_amt = 40000
	charge = 300.0
	max_charge = 300.0

/obj/item/ammo/power_cell/self_charging
	name = "Power Cell - Atomic"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 40PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	m_amt = 18000
	g_amt = 38000
	charge = 40.0
	max_charge = 40.0
	recharge_rate = 5.0

	process()
		if(src.material)
			if(src.material.hasProperty("stability"))
				if(src.material.getProperty("stability") <= 50)
					if(prob(max(11 - src.material.getProperty("stability"), 0)))
						var/turf/T = get_turf(src)
						explosion_new(src, T, 1)
						src.visible_message("<span class='alert'>\the [src] detonates.</span>")


/obj/item/ammo/power_cell/self_charging/custom
	name = "Power Cell"
	desc = "A custom-made power cell."

	onMaterialChanged()
		..()
		if(istype(src.material))
			if(src.material.hasProperty("electrical"))
				max_charge = round(material.getProperty("electrical") ** 1.33)
			else
				max_charge =  40

			recharge_rate = 0
			if(src.material.hasProperty("radioactive"))
				recharge_rate += ((src.material.getProperty("radioactive") / 10) / 2.5) //55(cerenkite) should give around 2.2, slightly less than a slow charge cell.
			if(src.material.hasProperty("n_radioactive"))
				recharge_rate += ((src.material.getProperty("n_radioactive") / 10) / 2)

		charge = max_charge
		AddComponent(/datum/component/power_cell, max_charge, charge, recharge_rate)
		return

/obj/item/ammo/power_cell/self_charging/slowcharge
	name = "Power Cell - Atomic Slowcharge"
	desc = "A self-contained radioisotope power cell that very slowly recharges an internal capacitor. Holds 40PU."
	recharge_rate = 2.5 // cogwerks: raised from 1.0 because radbows were terrible!!!!!

/obj/item/ammo/power_cell/self_charging/disruptor
	name = "Power Cell - Disruptor Charger"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 100PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	m_amt = 18000
	g_amt = 38000
	charge = 100.0
	max_charge = 100.0
	recharge_rate = 7.5

/obj/item/ammo/power_cell/self_charging/ntso_baton
	name = "Power Cell - NTSO Stun Baton"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 100PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	charge = 150.0
	max_charge = 150.0
	recharge_rate = 7.5

/obj/item/ammo/power_cell/self_charging/ntso_signifer
	name = "Power Cell - NTSO D49"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 100PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	charge = 250.0
	max_charge = 250.0
	recharge_rate = 6

/obj/item/ammo/power_cell/self_charging/medium
	name = "Power Cell - Hicap RTG"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 100PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	charge = 200
	max_charge = 200
	recharge_rate = 7.5

/obj/item/ammo/power_cell/self_charging/big
	name = "Power Cell - Fusion"
	desc = "A self-contained cold fusion power cell that quickly recharges an internal capacitor. Holds 400PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	m_amt = 18000
	g_amt = 38000
	charge = 400.0
	max_charge = 400.0
	recharge_rate = 40.0
/*
/obj/item/ammo/power_cell/self_charging/lawbringer
	name = "Power Cell - Lawbringer Charger"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 300PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	m_amt = 18000
	g_amt = 38000
	charge = 300.0
	max_charge = 300.0
	recharge_rate = 10.0
*/

/obj/item/ammo/power_cell/self_charging/howitzer
	name = "Miniaturized SMES"
	desc = "This thing is huge! How did you even lift it put it into the gun?"
	charge = 2500.0
	max_charge = 2500.0

/*
/obj/item/ammo/bullets/flintlock //Flintlock cant be reloaded so this is only for the initial bullet.
	sname = ".58 Flintlock"
	name = ".58 Flintlock"
	ammo_type = new/datum/projectile/bullet/flintlock
	icon_state = null
	amount_left = 1
	max_amount = 1
	caliber = 0.58

/obj/item/ammo/bullets/antisingularity
	sname = "Singularity buster rocket"
	name = "Singularity buster rocket"
	amount_left = 1
	max_amount = 1
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "regularrocket"
	ammo_type = new /datum/projectile/bullet/antisingularity
	caliber = 1.12
	w_class = W_CLASS_NORMAL
	delete_on_reload = 1
	sound_load = 'sound/weapons/gunload_heavy.ogg'

/obj/item/ammo/bullets/mininuke
	sname = "Miniature nuclear warhead"
	name = "Miniature nuclear warhead"
	amount_left = 1
	max_amount = 1
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "mininuke"
	ammo_type = new /datum/projectile/bullet/mininuke
	caliber = 1.12
	w_class = W_CLASS_NORMAL
	delete_on_reload = 1
	sound_load = 'sound/weapons/gunload_heavy.ogg'

/obj/item/ammo/bullets/gun
	name = "Briefcase of guns"
	desc = "A briefcase full of guns. It's locked tight..."
	sname = "Guns"
	amount_left = 6
	max_amount = 6
	icon_state = "gungun"
	throwforce = 2
	w_class = W_CLASS_TINY
	throw_speed = 4
	throw_range = 20
	ammo_type = new /datum/projectile/special/spawner/gun
	caliber = 3 //idk what caliber to actually make it but apparently its diameter of the tube so i figure it should be 3 inches????
	delete_on_reload = 1

/obj/item/ammo/bullets/meowitzer
	sname = "meowitzer"
	name = "meowitzer"
	desc = "A box containg a single meowitzer. It's shaking violently and feels warm to the touch. You probably don't want to be anywhere near this when it goes off. Wait is that a cat?"
	icon_state = "lmg_ammo"
	icon_empty = "lmg_ammo-0"
	amount_left = 1
	max_amount = 1
	ammo_type = new/datum/projectile/special/meowitzer
	caliber = 20
	w_class = W_CLASS_NORMAL


/obj/item/ammo/bullets/meowitzer/inert
	sname = "inert meowitzer"
	name = "inert meowitzer"
	desc = "A box containg a single inert meowitzer. It appears to be softly purring. Wait is that a cat?"
	ammo_type = new/datum/projectile/special/meowitzer/inert

/obj/item/ammo/bullets/foamdarts
	sname = "foam darts"
	name = "foam dart box"
	icon_state = "foamdarts"
	icon_empty = "foamdarts-0"
	amount_left = 20
	max_amount = 20
	caliber = 0.393
	ammo_type = new/datum/projectile/bullet/foamdart

/obj/item/ammo/bullets/foamdarts/ten
	amount_left = 10
	max_amount = 10

*/

/obj/item/ammo/bullets/dueling
	sname = "dueling rounds"
	name = "dueling round case"
	icon_state = "dueling_rounds"
	ammo_type = new/datum/projectile/bullet/dueling

	amount_left = 4 //Each side gets 2 tries
	max_amount = 4
	caliber = 6969 //better not let folks use these in other guns

/datum/action/bar/icon/powercellswap
	duration = 1 SECOND
	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	id = "powercellswap"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	var/mob/living/user
	var/obj/item/ammo/power_cell/cell
	var/obj/item/gun/energy/gun

	New(User, Cell, Gun)
		user = User
		cell = Cell
		gun = Gun
		..()

	onUpdate()
		..()
		if(get_dist(user, gun) > 1 || user == null || cell == null || gun == null || get_turf(gun) != get_turf(cell) )
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(user, gun) > 1 || user == null || cell == null || gun == null || get_turf(gun) != get_turf(cell) )
			interrupt(INTERRUPT_ALWAYS)
			return
		return

	onEnd()
		..()
		if(get_dist(user, gun) > 1 || user == null || cell == null || gun == null || get_turf(gun) != get_turf(cell) )
			..()
			interrupt(INTERRUPT_ALWAYS)
			return
		cell.swap(gun,user)
