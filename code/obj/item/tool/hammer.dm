//Please Hammer Don't Hurt 'Em (1990)
/obj/item/hammer
	name = "hammer"
	desc = "Used by carpenters and moral philosophers alike."
	//a better place than one of the worn exosuit dmis it used to be in, but I don't want to do more of every tool getting a dmi for 4 sprites
	//Like I should merge all these tiny files into one.
	icon = 'icons/obj/items/tools/omnitool.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "hammer"

	//Idea: move a good deal of those carpenter/engineering trait checks into checks for holding a hammer.
	tool_flags = TOOL_HAMMERING
	force = 10 //It's a hammer
	throwforce = 10

	afterattack(atom/target, mob/user, reach, params)
		if (ismob(target))
			user.add_karma(0.1)
		..()
