/datum/ailment/disease/infection
	name = "MRSA"
	max_stages = 3
	spread = "Non-Contagious"
	cure = "Antibiotics"
	reagentcure = list("spaceacillin")
	recureprob = 5
	affected_species = list("Human")
	stage_prob = 6
	carrier_possible = FALSE

/datum/ailment/disease/infection/stage_act(var/mob/living/affected_mob,var/datum/ailment_data/D)
	if (..())
		return

	switch(D.stage)
		if(1)
			if(prob(20))
				boutput(affected_mob, "<span class='alert'>You feel cold.</span>")
				affected_mob.emote("shiver")
		if(2)
			if(prob(60))
				affected_mob.bodytemperature = min(affected_mob.bodytemperature + rand(5,10), T0C + 103)
				affected_mob.take_toxin_damage(rand(0,1))
			else if(prob(30))
				boutput(affected_mob, "<span class='alert'>You feel feverish!</span>")
				affected_mob.bodytemperature = min(affected_mob.bodytemperature + rand(10,15), T0C + 103)
				affected_mob.take_toxin_damage(rand(1,3))
			else if(prob(30))
				boutput(affected_mob, "<span class='alert'>You feel sickly.</span>")
				affected_mob.emote("shiver")
		if(3)
			if(prob(30))
				boutput(affected_mob, "<span class='alert'>You feel like you're burning up!</span>")
				affected_mob.bodytemperature = min(affected_mob.bodytemperature + rand(20,30), T0C + 103)
				random_burn_damage(affected_mob,3)
				if(prob(60))
					affected_mob.emote(pick("tremble", "groan", "shake"))
					affected_mob.take_toxin_damage(rand(1,4))
			else if(prob(30))
				boutput(affected_mob, "<span class='alert'>You feel sick!</span>")
				affected_mob.change_misstep_chance(5)
				affected_mob.take_toxin_damage(rand(3,5))
				if(prob(40))
					affected_mob.take_toxin_damage(rand(2,3))
			else if(prob(25))
				boutput(affected_mob, "<span class='alert'>You feel like death warmed over.</span>")
				affected_mob.emote(pick("faint","groan","shiver"))
				if(prob(20))
					affected_mob.vomit()
