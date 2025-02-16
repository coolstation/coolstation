/datum/ailment/disease/space_madness
	name = "Space Madness"
	scantype = "Psychological Condition"
	max_stages = 5
	spread = "Non-Contagious"
	cure = "Anti-Psychotics"
	reagentcure = list("haloperidol")
	associated_reagent = "loose_screws"
	affected_species = list("Human")
	var/static/list/monkey_images = list(
		new /image('icons/mob/monkey.dmi', "monkey"),
		new /image('icons/mob/monkey.dmi', "fire3"),
		new /image('icons/mob/monkey.dmi', "skeleton"),
		new /image('icons/mob/monkey.dmi', "seamonkey"),
	)
	var/static/list/monkey_names = strings("names/monkey.txt")
	var/static/list/halluc_attackers = list(
		new /image('icons/mob/hallucinations.dmi',"pig") = list("pig","DAT FUKKEN PIG"),
		new /image('icons/mob/hallucinations.dmi',"spider") = list("giant black widow","queen bitch spider", "OH FUCK A SPIDER"),
		new /image('icons/mob/hallucinations.dmi',"dragon") = list("dragon","Lord Cinderbottom","SOME FUKKEN LIZARD THAT BREATHES FIRE"),
		new /image('icons/mob/hallucinations.dmi',"slime") = list("red slime","\proper some gooey thing","\improper ANGRY CRIMSON POO"),
		new /image('icons/mob/hallucinations.dmi',"shambler") = list("shambler", "strange creature", "OH GOD WHAT THE FUCK IS THAT THING?")
	)

/datum/ailment/disease/space_madness/stage_act(var/mob/living/affected_mob,var/datum/ailment_data/D)
	if (..())
		return
	if(affected_mob.job == "Clown")
		if(prob(6))
			var/icp = pick("Fuckin' magnets!", "Fuckin' rainbows!", "Magic everywhere in this bitch...", "Pure motherfuckin' miracles!", "Magic all around you and you don't even know it!")
			affected_mob.say("[icp]")
			return
	switch(D.stage)
		if(2)
			if (prob(10))
				boutput(affected_mob, pick("<span class='alert'><i><b><font face =Tempus Sans ITC>Kill them all!!!!!</b></i></FONT></span>", "<span class='alert'><i><b><font face = Tempus Sans ITC>They are out to get you!</b></FONT></i></span>", "<span class='alert'><i><b><font face = Tempus Sans ITC>They know what you did!!!!</b></FONT></i></span>", "<span class='alert'><i><b><font face = Tempus Sans ITC>They are watching you!!!</b></i></FONT></span>"))
		if(3)
			if (prob(8))
				for (var/mob/living/M in view(7,affected_mob))
					if(M!= affected_mob)
						boutput(affected_mob, "<b>[M.name]</b> says, \"[pick("I'm going to kill you!","I'm the the traitor.", "TRAITOR!")]\"")
						break
			if (prob(9))
				boutput(affected_mob, pick("<span class='alert'><i><b><font face =Tempus Sans ITC>Kill them all!!!!!</b></i></FONT></span>", "<span class='alert'><i><b><font face = Tempus Sans ITC>They are out to get you!</b></FONT></i></span>", "<span class='alert'><i><b><font face = Tempus Sans ITC>They know what you did!!!!</b></FONT></i></span>", "<span class='alert'><i><b><font face = Tempus Sans ITC>They are watching you!!!</b></i></FONT></span>"))

		if(4)
			if(prob(5))
				switch(rand(1,2))
					if(1)
						if(prob(50))
							M.AddComponent(/datum/component/hallucination/fake_attack, timeout=10, image_list=null, name_list=null, attacker_prob=20, max_attackers=2)
						else
							M.AddComponent(/datum/component/hallucination/fake_attack, timeout=10, image_list=monkey_images, name_list=monkey_names, attacker_prob=20, max_attackers=2)
					if(2)
						var/image/imagekey = pick(halluc_attackers)
						M.AddComponent(/datum/component/hallucination/fake_attack, timeout=15, image_list=list(imagekey), name_list=halluc_attackers[imagekey], attacker_prob=20, max_attackers=2)

			if(prob(9))
				affected_mob.playsound_local(affected_mob.loc, pick("explosion", "punch", 'sound/vox/poo-vox.ogg', "clownstep", 'sound/weapons/armbomb.ogg', 'sound/weapons/Gunshot.ogg'), 50, 1)

			if (prob(8))
				for (var/mob/living/M in view(7,affected_mob))
					if(M!= affected_mob)
						boutput(affected_mob, "<b>[M.name]</b> says, \"[pick("I'm going to kill you!","I'm the the traitor.", "You are a loser!")]\"")
						break

		if(5)
			if(prob(5))
				switch(rand(1,2))
					if(1)
						if(prob(50))
							M.AddComponent(/datum/component/hallucination/fake_attack, timeout=10, image_list=null, name_list=null, attacker_prob=20, max_attackers=2)
						else
							M.AddComponent(/datum/component/hallucination/fake_attack, timeout=10, image_list=monkey_images, name_list=monkey_names, attacker_prob=20, max_attackers=2)
					if(2)
						var/image/imagekey = pick(halluc_attackers)
						M.AddComponent(/datum/component/hallucination/fake_attack, timeout=15, image_list=list(imagekey), name_list=halluc_attackers[imagekey], attacker_prob=20, max_attackers=2)
			if(prob(9))
				affected_mob.playsound_local(affected_mob.loc, pick("explosion", "punch", 'sound/vox/poo-vox.ogg', "clownstep", 'sound/weapons/armbomb.ogg', 'sound/weapons/Gunshot.ogg'), 50, 1)

			if (prob(8))
				for (var/mob/living/M in view(7,affected_mob))
					if(M!= affected_mob)
						boutput(affected_mob, "<b>[M.name]</b> says, \"[pick("I'm going to kill you!","I'm the the traitor.", "You are a loser!")]\"")
						break

/datum/ailment/disease/space_madness/on_remove(var/mob/living/affected_mob, var/datum/ailment_data/D)
	if (affected_mob?.client)
		affected_mob.client.dir = 1 // Reset their view of the map. Yes, this was missing for many years (Convair880).
	..()
	return
