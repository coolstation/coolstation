/obj/item/plasma_cutter
	name = "plasma cutter"
	desc = "An extremely bulky and dangerous device, this tool uses electricity from an attatched power store to superheat plasma and cut through nearly any material."
	hint = "click a power bank with the cutter inhand to connect it; in order to start cutting, the bank needs to be charged and the cutter needs to be turned on with the key C or by pressing inhand."
	//icon = 'icons/obj/items/plasmacutter.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "base"
	item_state = "cutter"
	opacity = 0
	density = 0

	var/obj/reagent_dispensers/powerbank/powerbank
	var/list/working_on

	flags = FPRINT | TABLEPASS | CONDUCT
	force = 20.0
	throwforce = 20.0
	throw_speed = 1
	throw_range = 3
	w_class = W_CLASS_GIGANTIC
	//m_amt = 50000 //?

	var/power_cut_wall = 3
	var/time_cut_wall = 3 SECONDS
	var/active = 0

	examine()
		. = ..()
		if (powerbank)
			. += "<br>The dial says there are [powerbank.value] PU left in the battery."
		else
			. += "<br>The [src] is not connected to a power bank."

	process()
		if(!active)
			processing_items.Remove(src)
			return
		var/turf/location = src.loc
		if(ismob(location))
			var/mob/M = location
			if (M.l_hand == src || M.r_hand == src)
				location = M.loc
		if(istype(location,/turf))
			location.hotspot_expose(2000,5) //could go horribly wrong- a bit higher than the melting point of steel. Don't leave it on!
		if(prob(10))
			use_power(10)
			if(!get_power())
				active = 0

	attack_self(mob/user)
		tooltip_rebuild = 1
		if (powerbank)
			if(get_power() > 0)
				toggle_active(user)
			else
				boutput(user,"<span class='alert'>Power too low!</span>")
		else
			boutput(user,"<span class='alert'>No connected power source!</span>")

	afterattack(atom/target, mob/user, reach, params)
		if (istype(target, /obj/reagent_dispensers/powerbank))
			if (powerbank == target)
				//disconnect
				disconnect()
				boutput(user, "<span class='notice'>You disconnect [src] from [powerbank].</span>")
				user.visible_message("<span class='notice'>[user] disconnects [src] from [powerbank].</span>")
			else if (powerbank)
				boutput(user, "<span class='notice'>The cutter is already connected to a power source!</span>")
			else
				//connect
				boutput(user, "<span class='notice'>You connect [src] to [powerbank].</span>")
				user.visible_message("<span class='notice'>[user] connects [src] to [powerbank].</span>")
				connect(target)
		else if (src.active)
			var/power = rand(10,20)
			if (src.get_power() <= 0)
				boutput(user, "<span class='notice'>You need to charge the cutter!</span>")
				src.toggle_active()
			var/turf/location = user.loc
			if (istype(location,/turf))
				location.hotspot_expose(2000,50,1)

			if (istype(target, /turf))
				actions.start(new/datum/action/bar/icon/cutter_cut(target,src,power),user)

			if (target && !ismob(target) && target.reagents)
				boutput(user, "<span class='notice'>You heat \the [target.name]</span>")
				src.use_power(power)
				target.reagents.temperature_reagents(4000,50,100,100,1)
		return

	proc/log_construction(mob/user as mob, var/what)
		logTheThing("station", user, null, "[what] using \the [src] at [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")

	proc/connect(var/obj/reagent_dispensers/powerbank/pb)
		powerbank = pb
		//update powerbank

	proc/disconnect()
		powerbank = null
		//update powerbank

	proc/toggle_active(mob/user)
		if(!active && get_power())
			icon_state = "active"
			active = 1
			hit_type = DAMAGE_BURN
//			user.update_inhands()
			boutput(user, "<span class='notice'>You activate [src]!</span>")
			//boowap
			return 1
		else
			icon_state = "base"
			active = 0
			hit_type = DAMAGE_BLUNT
//			user.update_inhands()
			boutput(user, "<span class='notice'>You deactivate [src]!</span>")
			//boowump
			return 0

	proc/power_check(var/amount)
		if(src.get_power() && src.get_power() - amount >= 0)
			return 1
		else
			return 0

	proc/get_power()
		if(powerbank)
			return powerbank.charge

	proc/use_power(var/amount)
		amount = min(get_power(), amount)
		if(get_power() > 0)
			powerbank.lose_charge(amount)


	proc/eyecheck(mob/user as mob) //this is literally copy pasted welder code with tweaked values
		if(user.isBlindImmune())
			return
		//check eye protection
		var/safety = 0
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			// we want to check for the thermals first so having a polarized eye doesn't protect you if you also have a thermal eye
			if (istype(H.glasses, /obj/item/clothing/glasses/thermal) || H.eye_istype(/obj/item/organ/eye/cyber/thermal) || istype(H.glasses, /obj/item/clothing/glasses/nightvision) || H.eye_istype(/obj/item/organ/eye/cyber/nightvision))
				safety = -1
			else if (istype(H.head, /obj/item/clothing/head/helmet/welding))
				var/obj/item/clothing/head/helmet/welding/WH = H.head
				if(!WH.up)
					safety = 2
				else
					safety = 0
			else if (istype(H.head, /obj/item/clothing/head/helmet/space))
				safety = 2
			else if (istype(H.glasses, /obj/item/clothing/glasses/sunglasses) || H.eye_istype(/obj/item/organ/eye/cyber/sunglass))
				safety = 1
		switch (safety)
			if (1)
				boutput(user, "<span class='alert'>Your eyes burn badly.</span>")
				user.take_eye_damage(rand(2, 10))
			if (0)
				boutput(user, "<span class='alert'>Your eyes are being severely burned.</span>")
				user.take_eye_damage(rand(5, 11))
			if (-1)
				boutput(user, "<span class='alert'><b>Your goggles intensify the cutter's glow. Your eyes are melting out of your skull.</b></span>")
				user.change_eye_blurry(rand(20, 35))
				user.take_eye_damage(rand(20, 29))

	proc/cutter_cut(atom/target,mob/user)
		if (istype(target,/turf/wall/r_wall) || istype(target,/turf/wall/auto/reinforced))
			var/turf/wall/T = target:ReplaceWithUpdateWalls(map_setting ? map_settings.walls : /turf/wall)
			T.setMaterial(getMaterial("steel"))
			boutput(user, "<span class='notice'>You slice through the reinforcing of the wall.</span>")
			log_construction(user, "deconstructs a reinforced wall into a normal wall ([T])")
			return

		if (istype(target,/turf/wall))
			var/turf/floor/T = target:ReplaceWithFloor()
			boutput(user, "<span class='notice'>You cut through the wall.</span>")
			log_construction(user, "deconstructs a wall ([T])")
			return

		if (istype(target, /turf/floor))
			log_construction(user, "removes flooring ([target])")
			target:ReplaceWithSpace()
			boutput(user, "<span class='notice'>You slice through the floor.</span>")
			return

//action bars

/datum/action/bar/icon/cutter_cut
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_ATTACKED
	var/turf/target
	var/obj/item/plasma_cutter/cutter
	var/power

	New(var/turf/ta,var/obj/item/plasma_cutter/cu,var/po)
		..()
		target = ta
		cutter = cu
		power = po

	onUpdate()
		..()
		if (get_dist(owner, target) > 1 || target == null || cutter == null || power <= 0)
			interrupt(INTERRUPT_ALWAYS)
		var/mob/source = owner
		if (cutter != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		if (!cutter.power_check(power))
			boutput(owner, "Not enough power to cut this!")
			interrupt(INTERRUPT_ALWAYS)
		//sounds
		boutput(owner, "<span class='notice'>You start to cut [target].</span>")

	onEnd()
		..()
		cutter.use_power(power)
		elecflash(cutter)
		cutter.cutter_cut(target,owner)
