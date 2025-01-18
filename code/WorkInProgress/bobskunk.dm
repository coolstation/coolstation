//hiimbobskunk
//stinks in here

//dumb little items i wanna add

//gimmick sodas

//etc.

//mostly so i have a file up? and can put stuff in it? holy moly

/mob/living/carbon/human/clubfert
	is_npc = 1
	uses_mobai = 1
	name = "Club Fert"
	real_name = "Club Fert"
	gender = NEUTER
	max_health = 100
#ifdef IN_MAP_EDITOR
	icon = 'icons/mob/critter.dmi'
	icon_state = "ferret"
#endif IN_MAP_EDITOR

	New()
		..()
		src.ai = new /datum/aiHolder/human/clubfert(src)
		src.equip_new_if_possible(/obj/item/clothing/shoes/heels/dancin, slot_shoes)
		src.equip_new_if_possible(/obj/item/clothing/under/gimmick/eightiesmens, slot_w_uniform) //temporary until i can get a good list together, this supports pick() doesn't it?
		src.equip_new_if_possible(/obj/item/card/id/juicer/fert, slot_wear_id)
		src.set_mutantrace(/datum/mutantrace/fert)
		SPAWN_DBG(0)
			randomize_look(src, 1, 1, 1, 0, 1, 0, src)
			src.update_colorful_parts()

		src.name = pick("Toobs","Slink","Weasel","Dook","Flip","Chomps","Dooker","Wiggle")
		src.real_name = name

		SPAWN_DBG(1 SECOND)
			set_clothing_icon_dirty()

	//gonna get fucked up by a pack of toobs now
	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		. = ..()

		M.add_karma(-10)

		src.target = M
		src.ai_state = AI_ATTACKING
		src.ai_threatened = world.timeofday
		src.ai_target = M
		src.a_intent = INTENT_HARM
		src.say(pick("Hey that's really not fuckin' cool?","Wow, rude???","What'd I do to you?"))
		src.ai_set_active(1)

		/*
		for (var/mob/living/carbon/human/clubfert/fert in view(5,src))
			if (get_dist(fert,src) <= 7)
				if((!fert.ai_active) || prob(25))
					fert.say(pick("You think you can bring that shit into the club??","What the fuck is in your head, pal?","You fucked up!","That's my buddy, you [pick_string("johnbill.txt", "insults")]!"))
				fert.target = M
				fert.ai_set_active(1)
				fert.a_intent = INTENT_HARM
		*/
	//of course they don't attack because they're fixated on dancing (that's what I get for borrowing Juicer Gene's Geneticist Routine)
