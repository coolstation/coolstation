//Hey I heard we're doing files like these

//flap flap gonna put cursed stuff here

///Discord joke that might not be funny two weeks from now (but if it isn't we can just yeet it)
/obj/item/clothing/under/gimmick/bikinion
	name = "\proper bikinion"
	desc = "The only thing proven in court to ward off evil, because nothing wants to be near it."
	icon_state = "bikinion"
	item_state = "yay" //I can't be arsed right now

///Being the space boss California
/obj/item/clothing/under/gimmick/bossCalifornia
	name = "space boss California"
	desc = "Oh that? That's the space boss California."
	icon_state = "spaceboss"
	///How many times are you going to repeat this joke you nincompoop
	var/shirts = 5
	///get your own damn space boss shirt >:(
	cant_other_remove = TRUE

	New()
		..()
		wear_image.overlays += image('icons/mob/overcoats/worn_suit_gimmick.dmi', "spaceboss_shirt")

	//This is kinda easily defeated but AFAIK equipping code isn't set up to ever handle "failed to unequip"
	//cant_remove_self exists but that get checked on mobs before the item is ever given chance to intervene.
	///Take of your shirt, probably
	unequipped(mob/living/carbon/human/user)
		..()
		if (shirts) //we're not done yet bucko
			SPAWN_DBG(0 SECONDS) //gotta wait for whatever's unequipping to finish their set_loc stuff
				user.drop_item(src)
				user.equip_if_possible(src, user.slot_w_uniform) //IDK which of the many equipping related procs is the right one
				user.put_in_hand_or_drop(new /obj/item/clothing/suit/gimmick/bossCalifornia_shirt)
				user.say("Oh[prob(50)?",":null] me? [pick("Oh well ", "Well ", null)]I'm the space boss California.") //covers just about any variation in the original video
				if ((--shirts) < 1) //did we run out
					wear_image.overlays = null
					user.update_clothing() //set_clothing_icon_dirty is too slow when someone's repeatedly taking shirts off

//The loose space boss shirt, which is a suit so you can layer it over the depleted jumpsuit and get that untucked vibe from the good old days
//(also it doesn't have pockets)
/obj/item/clothing/suit/gimmick/bossCalifornia_shirt
	name = "space boss California shirt"
	desc = "A memorial to the declaration of a space boss. California."
	icon_state = "spaceboss_shirt"
