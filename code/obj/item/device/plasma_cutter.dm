/obj/item/plasma_cutter
	name = "plasma cutter"
	desc = "An extremely bulky and dangerous device, this tool uses electricity from an attatched power store to superheat plasma and cut through nearly any material."
	hint = "click a power bank with the cutter inhand to connect it; in order to start cutting, the bank needs to be charged and the cutter needs to be turned on with the key C or by pressing inhand."
	icon = 'icons/obj/items/cutter.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "cutter-inactive"
	item_state = "cutter-off"
	opacity = 0
	density = 0
	two_handed = TRUE

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
	var/accident_prob = 25 //higher chance of hurting yourself when fucking up with the plasma cutter- higher probabilities also increase the chance of severing limbs.
	var/cable_length = 4
	var/turf/last_loc

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
		var/mob/M
		if(ismob(location))
			M = location
			if (M.l_hand == src || M.r_hand == src)
				location = M.loc
		if(istype(location,/turf))
			location.hotspot_expose(2000,5) //could go horribly wrong- a bit higher than the melting point of steel. Don't leave it on!
		if(prob(10))
			use_power(10)
			if(!get_power())
				runout(M)
		if (get_power() <= 0)
			runout(M)


	attack_self(mob/user)
		tooltip_rebuild = 1
		if (powerbank)
			if(get_power() > 0)
				toggle_active(user)
			else
				boutput(user,"<span class='alert'>Power too low!</span>")
				runout(user)
		else
			boutput(user,"<span class='alert'>No connected power source!</span>")
			runout(user)


	afterattack(atom/target, mob/user, reach, params)
		if (istype(target, /obj/reagent_dispensers/powerbank))
			if (powerbank == target)
				//disconnect
				disconnect()
				boutput(user, "<span class='notice'>You disconnect [src] from [powerbank].</span>")
				user.visible_message("<span class='notice'>[user] disconnects [src] from [powerbank].</span>")
				runout(user)
			else if (powerbank)
				boutput(user, "<span class='notice'>The cutter is already connected to a power source!</span>")
			else
				//connect
				boutput(user, "<span class='notice'>You connect [src] to [powerbank].</span>")
				user.visible_message("<span class='notice'>[user] connects [src] to [powerbank].</span>")
				connect(target)
				deactivate(user)
		else if (src.active)
			var/power = rand(10,20)
			if (src.get_power() <= 0)
				boutput(user, "<span class='notice'>You need to charge the cutter!</span>")
				src.toggle_active()
			var/turf/location = user.loc
			if (istype(location,/turf))
				location.hotspot_expose(2000,50,1)

			if (istype(target, /turf) || istype(target, /obj/machinery/door))
				var/time = 6 SECONDS
				if (istype(target,/obj/machinery/door))
					time = 10 SECONDS
				eyecheck(user)
				actions.start(new/datum/action/bar/icon/cutter_cut(target,src,power),user,time)

			if (target && !ismob(target) && target.reagents)
				boutput(user, "<span class='notice'>You heat \the [target.name]</span>")
				src.use_power(power)
				target.reagents.temperature_reagents(4000,50,100,100,1)
				return
		return

	proc/log_construction(mob/user as mob, var/what)
		logTheThing("station", user, null, "[what] using \the [src] at [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")

	proc/connect(var/obj/reagent_dispensers/powerbank/pb)
		powerbank = pb
		pb.connected(src)

		SPAWN_DBG(0 SECONDS)
			while (powerbank)
				var/pbank_dist = GET_DIST(src,powerbank)
				if (pbank_dist > cable_length)
					if (istype(src.loc,/mob/))
						var/mob/holder = src.loc
						boutput(holder, "<span class='alert'>The cable reaches its length and the cutter is pulled out of your hands!</span>")
						holder.drop_item(src)
						walk_to(src, last_loc, 0, 0.3 SECONDS,0)
				else
					last_loc = get_turf(src)
				sleep(0.2)

	proc/disconnect()
		powerbank.disconnected()
		powerbank = null
		//update powerbank

	proc/activate(mob/user)
		icon_state = "cutter-active"
		item_state = "cutter-on"
		active = 1
		hit_type = DAMAGE_BURN
		if(user)
			user.update_inhands()

	proc/deactivate(mob/user)
		icon_state = "cutter-inactive"
		item_state = "cutter-off"
		if(user)
			user.update_inhands()
		hit_type = DAMAGE_BLUNT
		active = 0

	proc/runout(mob/user)
		icon_state = "cutter-dead"
		item_state = "cutter-off"
		if(user)
			user.update_inhands()
		hit_type = DAMAGE_BLUNT
		active = 0

	proc/toggle_active(mob/user)
		if(!active && get_power())
			activate(user)
			boutput(user, "<span class='notice'>You activate [src]!</span>")
			return 1
		else
			deactivate(user)
			boutput(user, "<span class='notice'>You deactivate [src]!</span>")
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
			boutput(user, "<span class='alert'>You slice through the reinforcing of the wall.</span>")
			log_construction(user, "deconstructs a reinforced wall into a normal wall ([T])")
			if (prob(60))
				var/obj/item/scrap/I = new /obj/item/scrap
				I.set_loc(target)
				I.setMaterial(getMaterial(target.material))
				I.set_components(0.5,0,0.1)
			return

		if (istype(target,/turf/wall))
			var/turf/floor/T = target:ReplaceWithFloor()
			boutput(user, "<span class='alert'>You cut through the wall.</span>")
			log_construction(user, "deconstructs a wall ([T])")
			if (prob(90))
				var/obj/item/scrap/I = new /obj/item/scrap
				I.set_loc(target)
				I.setMaterial(getMaterial(target.material))
				I.set_components(0.5,0,0.1)
			return

		if (istype(target, /turf/floor))
			log_construction(user, "removes flooring ([target])")
			target:ReplaceWithSpace()
			boutput(user, "<span class='alert'>You slice through the floor.</span>")
			var/obj/item/scrap/I = new /obj/item/scrap
			I.set_loc(target)
			I.setMaterial(getMaterial(target.material))
			I.set_components(0.5,0,0.1)
			return

		if (istype(target, /obj/machinery/door))
			log_construction(user, "removes door ([target])")
			var/obj/machinery/door/door = target
			door.break_me_complitely()//6 year old typo lmoa
			boutput(user, "<span class='alert'>You slice through the door!</span>")
			return

//action bars

/datum/action/bar/icon/cutter_cut
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACTION
	var/turf/target
	var/obj/item/plasma_cutter/cutter
	var/power
	var/a_prob

	New(var/atom/ta,var/obj/item/plasma_cutter/cu,var/po,var/time)
		if(time)
			duration = time
		target = ta
		cutter = cu
		power = po
		a_prob = cu.accident_prob
		..()

	onUpdate()
		..()
		if (get_dist(owner, target) > 1 || target == null || cutter == null || power <= 0)
			a_prob = 0
			interrupt(INTERRUPT_ALWAYS)
		var/mob/source = owner
		if (cutter != source.equipped())
			//bro dropped it
			interrupt(INTERRUPT_ALWAYS)
		if (!cutter.active)
			a_prob = 0 //this is how you safely stop a cut!
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		if (!cutter.power_check(power))
			boutput(owner, "Not enough power to cut this!")
			interrupt(INTERRUPT_ALWAYS)
		//sounds
		boutput(owner, "<span class='notice'>You start to slice through [target].</span>")

	onInterrupt(var/flag)
		..()
		var/mob/source = owner
		var/list/choppableBits = list("r_arm","l_arm","r_leg","l_leg","tail")
		if(prob(a_prob)) //ported this straight from my grigori branch (remind me to finish it!)
			var/mob/living/carbon/human/H
			if(istype(owner, /mob/living/carbon/human) && prob(a_prob))
				H = owner
				if(!H.organHolder?.tail)
					choppableBits.Remove("tail")
				if(!H.limbs.r_arm)
					choppableBits.Remove("r_arm")
				if(!H.limbs.l_arm)
					choppableBits.Remove("l_arm")
				if(!H.limbs.r_leg)
					choppableBits.Remove("r_leg")
				if(!H.limbs.l_leg)
					choppableBits.Remove("l_leg")
				var/targetedLimb = pick(choppableBits)

				var/wendung
				switch (targetedLimb)
					if("r_arm" , "l_arm")
						wendung = "arm"
					else
						wendung = "leg"

				if(targetedLimb == "tail")
					H.drop_and_throw_organ("tail",dist=3,speed=1)
					boutput(source, "<span class='alert'>YOU CUT YOUR FUCKING TAIL OFF! <B>FUCK!!!!</B></span>")
				else
					H.sever_limb(targetedLimb)
					boutput(source, "<span class='alert'>YOU CUT YOUR FUCKING [uppertext(wendung)] OFF! <B>FUCK!!!!</B></span>")
				source.TakeDamage("chest",30,0,0,DAMAGE_CUT,0)
				boutput(source, "<span class='alert'>You fuck up and cut yourself with the cutter!</span>")
			else
				source.TakeDamage("All",50,0,0,DAMAGE_CUT,0)
				boutput(source, "<span class='alert'>You fuck up and cut yourself with the cutter!</span>")

	onEnd()
		..()
		cutter.use_power(power)
		elecflash(cutter)
		cutter.cutter_cut(target,owner)
