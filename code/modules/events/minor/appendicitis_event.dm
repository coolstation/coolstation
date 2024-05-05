/datum/random_event/minor/appendicitis
	name = "Appendicitis Contraction"
	centcom_headline = "Medical Data Inbound"
	centcom_message = "The NanoTrasen Personnel Records Department has informed us that some crew members have the genetic indicators that they will very likely contract Appendicitis, they should report to medbay before their condition worsens."
	weight = 10
	customization_available = TRUE

	//haha what if
	admin_call(var/source)
		if (..())
			return
		var/list/potential_victims = list()
		var/new_target
		var/list/selected_targets = list()
		for (var/mob/living/carbon/human/H in mobs)
			if (H.client)
				potential_victims += H

		if (!length(potential_victims))
			return

		do
			new_target = input("Anyone in particular you want to screw over?", "Observe", null, null) as null|anything in potential_victims
			if (new_target)
				potential_victims -= new_target
		while (new_target != null && length(potential_victims))

		event_effect(source, length(selected_targets) ? selected_targets : null)


	event_effect(var/source, var/list/mob/living/carbon/human/shmucks)
		..()
		var/list/potential_victims = list()
		for (var/mob/living/carbon/human/H in mobs)
			if (H.stat == 2)
				continue
			potential_victims += H
		if (potential_victims.len)
			var/num = rand(2, 4)
			//admin wrath
			if (islist(shmucks))
				num -= length(shmucks)
				for (var/i = 1, i <= length(shmucks), i++)
					var/mob/living/carbon/human/patient = shmucks[i]
					if (!(isnpcmonkey(patient)) && patient.organHolder && patient.organHolder.appendix && !patient.organHolder.appendix.robotic)
						patient.contract_disease(/datum/ailment/disease/appendicitis,null,null,1)
			//regular bad luck
			for (var/i = 0, i < num, i++)
				var/mob/living/carbon/human/patient = pick(potential_victims)
				if (!(isnpcmonkey(patient)) && patient.organHolder && patient.organHolder.appendix && !patient.organHolder.appendix.robotic)
					patient.contract_disease(/datum/ailment/disease/appendicitis,null,null,1)
