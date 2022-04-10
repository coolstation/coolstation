/mob/living/critter/small_animal/bubs
	name = "bubs"
	real_name = "bubs"
	desc = "What kind of bee IS THIS?!"
	density = 1
	icon_state = "bubs"
	icon_state_dead = "bubs-dead"
	speechverb_ask = "bombles"
	health_brute = 50
	health_brute_vuln = 0.8
	health_burn = 25
	health_burn_vuln = 0.5
	hand_count = 3
	add_abilities = list(/datum/targetable/critter/bite/bee,
				/datum/targetable/critter/bee_sting)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch(act)
			if("snap", "buzz")
				if(src.emote_check(voluntary, 30))
					return "<b>[src]</b> buzzes!"
			if("smile", "bumble", "bomble")
				if(src.emote_check(voluntary, 50))
					return "<b>[src]</b> [act == "smile" ? pick("bumbles", "bombles") : "[act]s"] happily!"
		return null
