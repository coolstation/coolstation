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
