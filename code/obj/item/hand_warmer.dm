/obj/item/hand_warmer
	name = "pocket hand warmer"
	icon_state = "hand_warmer"
	item_state = "hand_warmer"
	desc = "A cute little chemical handwarmer to warm you up when you're cold. Just shake them a few times, and they're good to go!"
	w_class = W_CLASS_TINY

	var/max_heating
	var/heattime = 0
	var/heatingfactor = 1 //change this to edit how effective these are

	New()
		..()
		max_heating = rand(90,300) // change this to edit how long these things will work for

	attack_self(mob/user)
		..()
		if(!istype(user,/mob/living/carbon/human))
			boutput(user,"<span class='alert'>You can't seem to figure out how to make this work...</span>")
			return 0
		playsound(user,"sound/items/pills_4.ogg",40,TRUE)
		boutput(user,"<span class='alert'>You shake the hand warmer.</span>")

		for(var/i = 6, i>0, i--)
			animate(src, pixel_x = 0, pixel_y = 1, time = 0.1, easing = EASE_IN)
			sleep(0.1 SECONDS)
			animate(src, pixel_x = 0, pixel_y = -1, time = 0.1, easing = EASE_OUT)

		animate(src, pixel_x = x, pixel_y = x, time = 0.2, easing = EASE_OUT)
		heattime += rand(20 SECONDS, 60 SECONDS)
		boutput(user,"<b>DEBUG: [heattime] seconds left</b>")

	proc/heating(mob/user)
		if(heattime > 0 && user.bodytemperature < user.base_body_temp && !max_heating <= 0)
			icon_state = "hand_warmer_warm"
			item_state = "hand_warmer_warm"
			user.base_body_temp = min(user.bodytemperature + (user.base_body_temp + rand(1,3) * heatingfactor), user.base_body_temp)//this can use tweaking
			heattime--
			max_heating--
		else if(max_heating)
			expire(src)

	proc/expire(mob/user as mob)
		var/obj/item/hand_warmer/dead/d
		boutput(user,"<span class='alert'>The hand warmer goes cold and shrivels up.</span>")

		user.u_equip(src)
		user.put_in_hand_or_drop(d)
		qdel(src)


/obj/item/hand_warmer/dead
	name = "dead hand warmer"
	icon_state = "hand_warmer_used"
	item_state = "hand_warmer_used"
	desc = "A cold hand warmer. It served its purpose, and is now trash."

	attack_self(mob/user)
		if(!istype(user,/mob/living/carbon/human))
			boutput(user,"<span class='alert'>You can't seem to figure out how to make this work...</span>")
			return 0
		playsound("sound/items/matchstick_hit.ogg",40,4)
		boutput(user,"<span class='alert'>You shake the hand warmer, but it's not getting any warmer.</span>")


