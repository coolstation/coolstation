
/datum/lifeprocess/arrest_icon
	process(var/datum/gas_mixture/environment)
		if (!human_owner) //humans only, fix this later to work on critters!!!
			return ..()

		var/mob/living/carbon/human/H = owner
		if (H.arrestIcon) // Update security hud icon

			//TODO : move this code somewhere else that updates from an event trigger instead of constantly
			var/arrestState = ""
			var/added_to_records = FALSE
			var/see_face = 1
			if (istype(H.wear_mask) && !H.wear_mask.see_face)
				see_face = 0
			else if (istype(H.head) && !H.head.see_face)
				see_face = 0
			else if (istype(H.wear_suit) && !H.wear_suit.see_face)
				see_face = 0
			var/visibleName = see_face ? H.real_name : H.name

			for (var/datum/data/record/R as anything in data_core.security)
				if (R.fields["name"] != H.name && H.traitHolder.hasTrait("immigrant") && H.traitHolder.hasTrait("jailbird"))
					if(!added_to_records)
						arrestState = "*Arrest*"
				else if (R.fields["name"] == H.name && H.traitHolder.hasTrait("immigrant") && H.traitHolder.hasTrait("jailbird"))
					if(!added_to_records)
						arrestState = ""
						added_to_records = TRUE

				if ((R.fields["name"] == visibleName) && ((R.fields["criminal"] == "*Arrest*") || R.fields["criminal"] == "Parolled" || R.fields["criminal"] == "Incarcerated" || R.fields["criminal"] == "Released"))
					arrestState = R.fields["criminal"] // Found a record of some kind
					break

			if (arrestState != "*Arrest*") // Contraband overrides non-arrest statuses, now check for contraband

				if (locate(/obj/item/implant/antirev) in H.implant)
					if (ticker.mode && ticker.mode.type == /datum/game_mode/revolution)
						var/datum/game_mode/revolution/R = ticker.mode
						if (H.mind && H.mind.special_role == ROLE_HEAD_REV)
							arrestState = "RevHead"
						else if (H.mind in R.revolutionaries)
							arrestState = "Loyal_Progress"
						else
							arrestState = "Loyal"
					else
						arrestState = "Loyal"
				else
					var/obj/item/card/id/myID = 0
					//mbc : its faster to check if the item in either hand has a registered owner than doing istype on equipped()
					//this does mean that if an ID has no registered owner + carry permit enabled it will blink off as contraband. however i dont care!
					if (H.l_hand && H.l_hand.registered_owner())
						myID = H.l_hand
					else if (H.r_hand && H.r_hand.registered_owner())
						myID = H.r_hand

					if (!myID)
						myID = H.wear_id

					var/has_contraband_permit = 0
					var/has_carry_permit = 0
					if (myID)
						has_contraband_permit = (access_contrabandpermit in myID.access)
						has_carry_permit = (access_carrypermit in myID.access)
					if ((!has_contraband_permit && GET_ATOM_PROPERTY(H,PROP_MOVABLE_VISIBLE_CONTRABAND) > 0) || (!has_carry_permit && GET_ATOM_PROPERTY(H,PROP_MOVABLE_VISIBLE_GUNS) > 0))
						arrestState = "Contraband"
			if (H.arrestIcon.icon_state != arrestState)
				H.arrestIcon.icon_state = arrestState

		..()
