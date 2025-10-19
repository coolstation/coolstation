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

	attack_self(mob/user as mob)
		..()
		if(!istype(user,/mob/living/carbon/human))
			boutput(user,"<span class='alert'>You can't seem to figure out how to make this work...</span>")
			return 0
		playsound(user,"sound/items/pills_4.ogg",40,TRUE)
		boutput(user,"<span class='alert'>You shake the hand warmer.</span>")
		if(prob(30))
			expire(user)
		user.setStatus("hand_warmer",20 SECONDS)


	proc/expire(mob/user as mob)
		var/obj/item/hand_warmer/dead/d
		boutput(user,"<span class='alert'>The hand warmer goes cold and shrivels up.</span>")
		user.delStatus("warm")

		user.u_equip(src)
		d = new /obj/item/hand_warmer/dead(user.loc)
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
		playsound(user,"sound/items/matchstick_hit.ogg",40,4)
		boutput(user,"<span class='alert'>You shake the hand warmer, but it's not getting any warmer.</span>")


