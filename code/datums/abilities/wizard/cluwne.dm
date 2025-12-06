/datum/targetable/spell/cluwne
	name = "Clown's Revenge"
	desc = "Turns the target into a cursed clown."
	icon_state = "clownrevenge"
	targeted = 1
	max_range = 1
	ai_range = 1
	cooldown = 1350
	requires_robes = 1
	offensive = 1
	sticky = 1
	voice_grim = "sound/voice/wizard/CluwneGrim.ogg"
	voice_fem = "sound/voice/wizard/CluwneFem.ogg"
	voice_other = "sound/voice/wizard/CluwneLoud.ogg"

	cast(mob/target)
		if(!holder)
			return
		var/mob/living/carbon/human/H = target
		if (!istype(H))
			boutput(holder.owner, "Your target must be human!")
			return 1
		holder.owner.visible_message("<span class='alert'><b>[holder.owner] begins to cast a spell on [target]!</b></span>")

		if (do_mob(holder.owner, target, 15))
			if(!istype(get_area(holder.owner), /area/sim/gunsim))
				holder.owner.say("NWOLC EGNEVER")
			..()

			var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
			smoke.set_up(5, 0, H.loc)
			smoke.attach(H)
			smoke.start()

			if (H.traitHolder.hasTrait("training_chaplain"))
				boutput(holder.owner, "<span class='alert'>[H] has divine protection from magic.</span>")
				H.visible_message("<span class='alert'>The spell has no effect on [H]!</span>")
				JOB_XP(H, "Chaplain", 2)
				return

			if (iswizard(H))
				H.visible_message("<span class='alert'>The spell has no effect on [H]!</span>")
				return

			if(check_target_immunity( H ))
				H.visible_message("<span class='alert'>[H] seems to be warded from the effects!</span>")
				return 1

			if(H.job == "Clown")
				H.visible_message("<span class='alert'>The spell has no effect on [H]!</span>")
				return

			if (H.job != "Cluwne")
				H.cluwnify()

			else
				boutput(H, "<span class='alert'><b>You don't feel very funny.</b></span>")
				H.take_brain_damage(-120)
				H.stuttering = 0
				if (H.mind)
					H.mind.assigned_role = "Lawyer"
				H.change_misstep_chance(-INFINITY)

				animate_clownspell(H)
				for(var/datum/ailment_data/A in H.ailments)
					if(istype(A.master,/datum/ailment/disability/clumsy))
						H.cure_disease(A)
				var/obj/old_uniform = H.w_uniform
				var/obj/item/the_id = H.wear_id

				if(H.w_uniform && findtext("[H.w_uniform.type]","clown"))
					H.w_uniform = new /obj/item/clothing/under/suit(H)
					qdel(old_uniform)

				if(H.shoes && findtext("[H.shoes.type]","clown"))
					qdel(H.shoes)
					H.shoes = new /obj/item/clothing/shoes/black(H)

				if(the_id && the_id:registered == H.real_name)
					if (istype(the_id, /obj/item/card/id))
						the_id:assignment = "Lawyer"
						the_id:name = "[H.real_name]'s ID Card (Lawyer)"
					else if (istype(the_id, /obj/item/device/pda2))
						the_id:assignment = "Lawyer"
						the_id:ID_card:assignment = "Lawyer"
						the_id:ID_card:name = "[H.real_name]'s ID Card (Lawyer)"
					H.wear_id = the_id

				for(var/obj/item/W in H)
					if (findtext("[W.type]","clown"))
						H.u_equip(W)
						if (W)
							W.set_loc(target.loc)
							W.dropped(H)
							W.layer = initial(W.layer)
		else
			return 1
