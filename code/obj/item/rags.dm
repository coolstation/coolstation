/obj/item/material_piece/cloth/rag
	name = "rag"
	desc = "an offwhite rag with a few stains of unknown origin."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "rag-basewhite"
	hint = "this can clean your glasses, hands, cups, counters, shoes, and probably alot of other things."
	w_class = W_CLASS_SMALL
	flags = SUPPRESSATTACK
	event_handler_flags = USE_FLUID_ENTER | USE_GRAB_CHOKE

	New()
		..()
		src.create_reagents(10)
		if(prob(80))
			src.icon_state = "rag-basewhite-redstripe"

	attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
		if (user.a_intent == INTENT_HARM)
			playsound(M,'sound/impact_sounds/Generic_Snap_1.ogg',50)

			user.visible_message("<span class='alert'>[user] slaps [M] with [src]!</span>")
			return
		user.visible_message("<span class='notice'>[user] wipes [M] with [src].</span>")
		src.reagents.reaction(M, TOUCH, 5)
		src.reagents.remove_any(5)
		JOB_XP(user, "Janitor", 3)
		if (M.reagents)
			M.reagents.trans_to(src, 5)
		M.clean_forensic()
		return

	afterattack(atom/target, mob/user)
		if (istype(target,/obj/item/reagent_containers/food/drinks))
			var/obj/item/reagent_containers/food/drinks/d = target
			d.drank_from = null
			d.clean_forensic()
			JOB_XP(user, "Janitor", 1)
			user.visible_message("<span class='notice'>[user] wipes down [d] with [src].</span>")
			return

		if(istype(target,/obj/table))
			user.visible_message("<span class='notice'>[user] wipes down [target] with [src].</span>")
			return

		if (istype(target, /obj/item/clothing/shoes) || istype(target, /obj/item/clothing/glasses))
			user.visible_message("<span class='notice'>[user] cleans [his_or_her(user)] [target] with [src].</span>")
			JOB_XP(user, "Janitor", 1)
			target.clean_forensic()
			return

/obj/item/material_piece/cloth/rag/blue
	name = "blue rag"
	desc = "a blue rag that smells faintly of old blood."
	icon_state = "rag-baseblue"
	New()
		..()
		src.icon_state = "rag-baseblue"







