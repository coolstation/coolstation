/*
The idea with set events is that they are guarenteed to happen at least once per round
and do not take the place of other events. Set events would include small things that are expected to always happen
such as the crew getting hungry and triggering lunchtime, or the lights dimming for a simulated night cycle.
These should ideally not be disruptive, and are intended to encourage interaction.
*/

/datum/random_event/sets/lunchtime
	name = "Lunch Time" //Mahlzeit!
	centcom_headline = "Lunch Break"
	centcom_message = "NanoTrasen employees are required to take a ten minute break to fufill nutritional needs. The catering department has prepared meals for the crew."
	message_delay = 10 MINUTES //give catering time to cook and stuff
	weight = 100 //bring down once more sets are added

	New()
		if (prob(10))
			centcom_headline = "Mahlzeit!"
		..()

	event_effect(var/source)
		..()
		var/list/hungry = list()
		for (var/mob/living/carbon/human/H in mobs)
			if (H.client) //idc if you already ate it's lunchtime pal
				hungry += H
		if (hungry.len)
			var/wait = rand(2 MINUTES, 9 MINUTES)
			for (var/mob/living/carbon/human/H in hungry)
				SPAWN_DBG(wait)
					H.nutrition = 50
					H.setStatus("hungry")
					boutput(H,"<span class='alert'><b>You are starting to feel really hungry.</b></span>")
		var/datum/signal/pdaSignal = get_free_signal()
		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CATERING-MAILBOT",  "group"=list(MGD_KITCHEN), "sender"="00000000", "message"="Notification: Mandated station lunch break is in 10 minutes. Please prepare at least [round(hungry.len,5)] meals for the crew. Catering staff recieves a break after the general crew lunch time.")
		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(pdaSignal)

