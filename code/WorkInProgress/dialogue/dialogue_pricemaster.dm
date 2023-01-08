/mob/living/carbon/human/pricemaster
	name = "The PriceMaster"
	desc = "Make him an offer."
	density = 1
	anchored = 1
	icon='icons/mob/human.dmi'
	icon_state = "body_m"

	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/priceMaster(src)
		..()

	Click(location,control,params)
		dialogue.showDialogue(usr)
		return

/datum/dialogueMaster/priceMaster

/datum/dialogueNode
	pm_start
		links= list()
		linkText = "..."
		soundClips = list('sound/voice/PRICEMASTER/EXCLAMATIONS/I_AM_PRICEMASTER.ogg',\
							'sound/voice/PRICEMASTER/EXCLAMATIONS/EL_MAESTRO_DEL_PRICIO.ogg',\
							'sound/voice/PRICEMASTER/EXCLAMATIONS/EVERYTHING_IS_FOR_SALE.ogg',\
							'sound/voice/PRICEMASTER/EXCLAMATIONS/EVERYTHING_IS_FOR_SALE2.ogg')

	pm_who
		links= list()
		linkText = "who are you?"
		soundClips = list('sound/voice/PRICEMASTER/EXCLAMATIONS/I_AM_PRICEMASTER.ogg',\
							'sound/voice/PRICEMASTER/EXCLAMATIONS/I_AM_PRICEMASTER-MAKE_ME_AN_OFFER.ogg')
