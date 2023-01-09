/obj/npc/trader/pricemaster
	name = "The PriceMaster"
	desc = "Make him an offer."
	density = 1
	anchored = 1
	icon='icons/mob/human.dmi'
	icon_state = "body_m"
	hiketolerance = 0

	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/priceMaster(src)
		..()

	Click(location,control,params)
		dialogue.showDialogue(usr)
		return

	errormsgs = list("EVERYTHING IS FOR SALE!",
					"EVERYTHING IS FOR SALE!",
					"MAKE ME AN OFFER!",
					"I AM PRICEMASTER. MAKE ME AN OFFER!",
					"THE PRICEMASTER HAS SPOKEN.",
					"THANK YOU FOR SHOPPING.")

	hagglemsgs = list("Alright, how's this sound?",
					"You drive a hard bargain. How's this price?",
					"You're busting my balls here. How's this?",
					"I'm being more than generous here, I think you'll agree.",
					"This is my final offer. Can't do better than this.")


	////////////////////////////////////////////////////
	/////////Proc for haggling with pricemaster////////
	//////////////////////////////////////////////////
	haggle(var/askingprice, var/buying, var/datum/commodity/H)
		// if something's gone wrong and there's no input, reject the haggle
		// also reject if there's no change in the price at all
		if (!askingprice) return
		if (askingprice == H.price) return
		// if the player is being dumb and haggling in the wrong direction, tell them (unless the trader is an asshole)
		if (buying == 1)
			// we're buying, so we want to pay less per unit
			if(askingprice > H.price)
				if (src.bullshit >= 5)
					src.temp = src.errormsgs[1]
					H.price = askingprice
					H.haggleattempts++
					return
				else
					src.temp = src.errormsgs[2]
					src.bullshit++
					return
		else
			// we're selling, so we want to be paid MORE per unit
			if(askingprice < H.price)
				if (src.bullshit >= 5)
					H.price = askingprice
					H.haggleattempts++
					src.temp = "<B>Cost:</B> [H.price] Credits<BR>"
					src.temp += src.errormsgs[3]
					return
				else
					src.temp = "<B>Cost:</B> [H.price] Credits<BR>"
					src.temp += src.errormsgs[4]
					src.bullshit++
					return


		//pricemaster does not haggle... much
		var/firstnum = askingprice
		var/master_price = 500
		var/sentence = list()
		var/temp2 = list()

		while(firstnum > 11)
			firstnum /= 10
		firstnum = floor(firstnum)

		H.haggleattempts++
		src.bullshit++

		if(prob(5))
			var/datum/priceVOXsound/V = pick(pmvoxcomplete)
			sentence += V
			master_price = V.value
			src.temp = V.string
			src.bullshit++

		else
			while((H.haggleattempts && (master_price < H.price) && src.bullshit))
				src.bullshit--

				for(var/datum/priceVOXsound/V in pmvoxnums) // find if we can spit their offer back at them
					if(V.value == firstnum)
						temp2 += V
				if(temp2.len && prob(75)) // but not every time
					var/datum/priceVOXsound/V = pick(temp2)
					sentence += V
					master_price = V.value
					src.temp = V.string
				else
					var/datum/priceVOXsound/V = pick(pmvoxnums)
					sentence += V
					master_price = V.value
					src.temp = V.string

				temp2 = list()
				if(!(master_price % 10)) //this ends in 0 so let's not add a Hundred mod to it.
					for(var/datum/priceVOXsound/V in pmvoxdollars)
						if(V.id == "hundred")
							continue
						temp2 += V
					if(temp2.len)
						var/datum/priceVOXsound/V = pick(temp2)
						sentence += V
						master_price *= V.value
						src.temp += V.string
				else
					var/datum/priceVOXsound/V = pick(pmvoxdollars)
					sentence += V
					src.temp += V.string
						if(V.value % 100)//has some trailing digits there
							master_price = master_price * 100 + (V.value % 100)
						else
							master_price *= V.value
		//ok so we either got a higher price or gave up
		if (patience == H.haggleattempts)
			src.temp += "<BR>THE PRICEMASTER HAS SPOKEN."
			sentence += pick(pmvoxend)

		for(var/datum/priceVOXsound/V in sentence)
			V.load()

		src.temp = "<B>[src.temp]</B><BR>"
		H.price = master_price
		//and say his new price

		SPAWN_DBG(0)
			for(var/datum/priceVOXsound/V in sentence)
				V.play(src)
				sleep(0.1 SECONDS)







		/*
		// check if the price increase % of the haggle is more than this trader will tolerate
		var/hikeperc = askingprice - H.price
		hikeperc = (hikeperc / H.price) * 100
		var/negatol = 0 - src.hiketolerance
		if (buying == 1) // we're buying, so price must be checked for negative
			if (hikeperc <= negatol)
				src.temp = "<B>Cost:</B> [H.price] Credits<BR>"
				src.temp += src.errormsgs[5]
				H.haggleattempts++
				return
		else
			if (hikeperc >= src.hiketolerance) // we're selling, so check hike for positive
				src.temp = src.errormsgs[5]
				H.haggleattempts++
				return
		// now, the actual haggling part! find the middle ground between the two prices
		var/middleground = (H.price + askingprice) / 2
		var/negotiate = abs(H.price-middleground)-1
		if (buying == 1)
			H.price =round(middleground + rand(0,negotiate))
		else
			if(middleground-H.price <= 0.5)
				H.price = round(middleground + 1)
			else
				H.price = round(middleground - rand(0,negotiate))

		src.temp = "<B>New Cost:</B> [H.price] Credits<BR><HR>"
		H.haggleattempts++
		// warn the player if the trader isn't going to take any more haggling
		if (patience == H.haggleattempts)
			src.temp += src.hagglemsgs[src.hagglemsgs.len]
		else
			src.temp += pick(src.hagglemsgs)
*/
proc/init_pmvox() // first bare numbers
	pmvoxnums = list("1" = new/datum/priceVOXsound("1", "sound/voice/PRICEMASTER/1.ogg", 1, "ONE"),
	"2" = new/datum/priceVOXsound("2", "sound/voice/PRICEMASTER/2.ogg", 2, "TWO"),
	"3" = new/datum/priceVOXsound("3", "sound/voice/PRICEMASTER/3.ogg", 3, "THREE"),
	"4" = new/datum/priceVOXsound("4", "sound/voice/PRICEMASTER/4.ogg", 4, "FOUR"),
	"5" = new/datum/priceVOXsound("5", "sound/voice/PRICEMASTER/5.ogg", 5, "FIVE"),
	"5a" = new/datum/priceVOXsound("5a", "sound/voice/PRICEMASTER/5a.ogg", 5, "FIVE"),
	"7" = new/datum/priceVOXsound("7", "sound/voice/PRICEMASTER/7.ogg", 7, "SEVEN"),
	"9" = new/datum/priceVOXsound("9", "sound/voice/PRICEMASTER/9.ogg", 9, "NINE"),
	"10" = new/datum/priceVOXsound("10", "sound/voice/PRICEMASTER/10.ogg", 10, "TEN"),
	"10a" = new/datum/priceVOXsound("10a", "sound/voice/PRICEMASTER/10a.ogg", 10, "TEN"),
	"17" = new/datum/priceVOXsound("17", "sound/voice/PRICEMASTER/17.ogg", 17, "SEVENTEEN"),
	"40" = new/datum/priceVOXsound("40", "sound/voice/PRICEMASTER/40.ogg", 40, "FORTY"),
	"60" = new/datum/priceVOXsound("60", "sound/voice/PRICEMASTER/60.ogg", 60 ,"SIXTY"),
	"67" = new/datum/priceVOXsound("67", "sound/voice/PRICEMASTER/67.ogg", 67, "SIXTY-SEVEN"),
	"70" = new/datum/priceVOXsound("70", "sound/voice/PRICEMASTER/70.ogg", 70, "SEVENTY"),
	"78" = new/datum/priceVOXsound("78", "sound/voice/PRICEMASTER/78.ogg", 78, "SEVENTY-EIGHT"))

	pmvoxmisc = list("pointseven" = new/datum/priceVOXsound("pointseven", "sound/voice/PRICEMASTER/POINT_SEVEN.ogg", 0.7),
	"hundred" = new/datum/priceVOXsound("hundred", "sound/voice/PRICEMASTER/HUNDRED.ogg", 100),
	"hundred_t" = new/datum/priceVOXsound("hundred_t", "sound/voice/PRICEMASTER/HUNDRED_THOUSAND.ogg", 100000),
	"thousand" = new/datum/priceVOXsound("thousand", "sound/voice/PRICEMASTER/THOUSAND.ogg", 1000),
	"500" = new/datum/priceVOXsound("500", "sound/voice/PRICEMASTER/500.ogg", 500))

	pmvoxdollars = list("billion" = new/datum/priceVOXsound("billion", "sound/voice/PRICEMASTER/DOLLARS/BILLION_DOLLARS.ogg", 100000000 " BILLION DOLLARS"),
	"hundred_50_t" = new/datum/priceVOXsound("hundred", "sound/voice/PRICEMASTER/DOLLARS/HUNDRED_AND_FIFTY_THOUSAND_DOLLARS.ogg", 150000, " HUNDRED AND FIFTY THOUSAND DOLLARS DOLLARS"),
	"hundred_36" = new/datum/priceVOXsound("hundred", "sound/voice/PRICEMASTER/DOLLARS/HUNDRED_AND_THIRTY_SIX_DOLLARS.ogg", 136, " HUNDRED AND THIRTY SIX DOLLARS"),
	"hundred_b" = new/datum/priceVOXsound("hundred", "sound/voice/PRICEMASTER/DOLLARS/HUNDRED_BILLION_DOLLARS.ogg", 10000000000, " HUNDRED BILLION DOLLARS"),
	"hundred" = new/datum/priceVOXsound("hundred", "sound/voice/PRICEMASTER/DOLLARS/HUNDRED_DOLLARS.ogg", 100, " HUNDRED DOLLARS"),
	"hundred2" = new/datum/priceVOXsound("hundred", "sound/voice/PRICEMASTER/DOLLARS/HUNDRED_DOLLARS2.ogg", 100, " HUNDRED DOLLARS"),
	"hundred_46" = new/datum/priceVOXsound("hundred", "sound/voice/PRICEMASTER/DOLLARS/HUNDRED_FORTY_SIX_DOLLARS.ogg", 146, " HUNDRED FORTY SIX DOLLARS"),
	"thousand" = new/datum/priceVOXsound("thousand", "sound/voice/PRICEMASTER/DOLLARS/THOUSAND_DOLLARS.ogg", 1000, " THOUSAND DOLLARS"),
	"thousand2" = new/datum/priceVOXsound("thousand", "sound/voice/PRICEMASTER/DOLLARS/THOUSAND_DOLLARS2.ogg", 1000 " THOUSAND DOLLARS"),
	"thousand3" = new/datum/priceVOXsound("thousand", "sound/voice/PRICEMASTER/DOLLARS/THOUSAND_DOLLARS3.ogg", 1000 " THOUSAND DOLLARS"),
	"thousand4" = new/datum/priceVOXsound("thousand", "sound/voice/PRICEMASTER/DOLLARS/THOUSAND_DOLLARS4.ogg", 1000 " THOUSAND DOLLARS"))

	pmvoxthings = list("communicator" = new/datum/priceVOXsound("communicator", "sound/voice/PRICEMASTER/THINGS/THE_COMMUNICATOR.ogg", 0),
	"enemabox" = new/datum/priceVOXsound("enemabox", "sound/voice/PRICEMASTER/THINGS/THE_ENEMA_BOX.ogg", 0),
	"lasergun" = new/datum/priceVOXsound("lasergun", "sound/voice/PRICEMASTER/THINGS/THE_LASER_GUN.ogg", 0),
	"robotfist" = new/datum/priceVOXsound("robotfist", "sound/voice/PRICEMASTER/THINGS/THE_ROBOT_FIST.ogg", 0),
	"communication" = new/datum/priceVOXsound("communication", "sound/voice/PRICEMASTER/THINGS/COMMUNICAITON.ogg", 0))

	pmvoxcomplete = list("500" = new/datum/priceVOXsound("500", "sound/voice/PRICEMASTER/COMPLETES/5_HUNDRED_DOLLARS.ogg", 500, "FIVE HUNDRED DOLLARS"),
	"500a" = new/datum/priceVOXsound("500a", "sound/voice/PRICEMASTER/COMPLETES/5_HUNDRED_DOLLARS2.ogg", 500, "FIVE HUNDRED DOLLARS"),
	"9000" = new/datum/priceVOXsound("9000", "sound/voice/PRICEMASTER/COMPLETES/9_THOUSAND_DOLLARS.ogg", 9000, "NINE THOUSAND DOLLARS"),
	"10000" = new/datum/priceVOXsound("10000", "sound/voice/PRICEMASTER/COMPLETES/10_THOUSAND_DOLLARS.ogg", 10000, "TEN THOUSAND DOLLARS"),
	"78000" = new/datum/priceVOXsound("78000", "sound/voice/PRICEMASTER/COMPLETES/78_THOUSAND_DOLLARS.ogg", 78000, "SEVENTY-EIGHT THOUSAND DOLLARS"),
	"17.42" = new/datum/priceVOXsound("17.42", "sound/voice/PRICEMASTER/COMPLETES/17_DOLLARS_AND_42_CENTS.ogg", 17.42, "SEVENTEEN DOLLARS AND FORTY-TWO CENTS"),
	"136" = new/datum/priceVOXsound("136", "sound/voice/PRICEMASTER/COMPLETES/ONE_HUNDRED_AND_THIRTY_SIX_DOLLARS.ogg", 136,"ONE HUNDRED AND THIRTY SIX DOLLARS"))

	pmvoxend = list("spoken" = new/datum/priceVOXsound("spoken", "sound/voice/PRICEMASTER/EXCLAMATIONS/THE_PRICEMASTER_HAS_SPOKEN.ogg", 0, "THE PRICEMASTER HAS SPOKEN"),
	"spoken2" = new/datum/priceVOXsound("spoken2", "sound/voice/PRICEMASTER/EXCLAMATIONS/THE_PRICEMASTER_HAS_SPOKEN.ogg2", 0, "THE PRICEMASTER HAS SPOKEN"),
	"spoken3" = new/datum/priceVOXsound("spoken3", "sound/voice/PRICEMASTER/EXCLAMATIONS/THE_PRICEMASTER_HAS_SPOKEN.ogg3", 0, "THE PRICEMASTER HAS SPOKEN"),
	"spoken4" = new/datum/priceVOXsound("spoken4", "sound/voice/PRICEMASTER/EXCLAMATIONS/THE_PRICEMASTER_HAS_SPOKEN.ogg4", 0, "THE PRICEMASTER HAS SPOKEN"),
	"spoken5" = new/datum/priceVOXsound("spoken5", "sound/voice/PRICEMASTER/EXCLAMATIONS/THE_PRICEMASTER_HAS_SPOKEN.ogg5", 0, "THE PRICEMASTER HAS SPOKEN"))

	SPAWN_DBG(0.1 SECONDS)
		var/listolists = list(pmvoxnums, pmvoxmisc, pmvoxdollars, pmvoxthings, pmvoxcomplete, pmvoxend)
		for(var/list/listo in listolists)
			for(var/id in listo)
				var/datum/priceVOXsound/vox = listo[id]
				vox.ogg = file(vox.ogg)




/datum/priceVOXsound
	var/id
	var/ogg
	var/sound/soundFile
	var/flags
	var/value
	var/string = ""

	New(var/id, var/file, var/value var/string = "")
		..()
		src.id = id
		src.ogg = file
		src.value = value
		src.string = string

	disposing()
		ogg = null
		soundFile = null
		voxsounds -= src
		for(var/token in voxtokens)
			var/list/sounds = voxsounds_flag_sorted[token]
			sounds -= src
		..()

	proc/matches_id(var/t)
		. = id == lowertext(t)

	proc/matches_flag(var/f)
		. = 0
		if (istext(f))
			f = text2num(f)
		if (isnum(f))
			. = (f & flags)

	proc/load(var/freq = 1)
		if (src.ogg)
			src.soundFile = sound(src.ogg, wait = 1, channel = 5)
			src.soundFile.frequency = freq
			src.soundFile.volume = 50 //fuck vox man you are SO LOUD!!!!!!

	proc/play(var/atom/A)
		if (src.soundFile)
			listener << src.soundFile


/datum/dialogueMaster/priceMaster

/datum/dialogueNode
	pm_start
		links= list(/datum/dialogueNode/pm_who, /datum/dialogueNode/pm_StartTrade)
		linkText = "..."
		soundClips = list('sound/voice/PRICEMASTER/EXCLAMATIONS/I_AM_PRICEMASTER.ogg',\
							'sound/voice/PRICEMASTER/EXCLAMATIONS/EL_MAESTRO_DEL_PRICIO.ogg',\
							'sound/voice/PRICEMASTER/EXCLAMATIONS/EVERYTHING_IS_FOR_SALE.ogg',\
							'sound/voice/PRICEMASTER/EXCLAMATIONS/EVERYTHING_IS_FOR_SALE2.ogg')

	pm_who
		links= list(/datum/dialogueNode/pm_start, /datum/dialogueNode/pm_StartTrade)
		linkText = "who are you?"
		soundClips = list('sound/voice/PRICEMASTER/EXCLAMATIONS/I_AM_PRICEMASTER.ogg',\
							'sound/voice/PRICEMASTER/EXCLAMATIONS/I_AM_PRICEMASTER-MAKE_ME_AN_OFFER.ogg')

	pm_StartTrade
		nodeImage = "generic.png"
		linkText = "I want to trade."
		soundClips = list('sound/voice/PRICEMASTER/EXCLAMATIONS/MAKE_ME_AN_OFFER.ogg',\
							'sound/voice/PRICEMASTER/EXCLAMATIONS/MAKE_ME_AN_OFFER2.ogg',\
							'sound/voice/PRICEMASTER/EXCLAMATIONS/MAKE_ME_AN_OFFER3.ogg')

		var/list/nopevoice = list('sound/voice/PRICEMASTER/EXCLAMATIONS/THE_PRICEMASTER_HAS_SPOKEN.ogg',\
					'sound/voice/PRICEMASTER/EXCLAMATIONS/THE_PRICEMASTER_HAS_SPOKEN2.ogg',\
					'sound/voice/PRICEMASTER/EXCLAMATIONS/THE_PRICEMASTER_HAS_SPOKEN3.ogg',\
					'sound/voice/PRICEMASTER/EXCLAMATIONS/THE_PRICEMASTER_HAS_SPOKEN4.ogg',\
					'sound/voice/PRICEMASTER/EXCLAMATIONS/THE_PRICEMASTER_HAS_SPOKEN5.ogg')

		getNodeImage(var/client/C)
			var/atom/A = master.master
			if(istype(A, /obj/npc/trader))
				var/obj/npc/trader/T = A
				return resource("images/traders/[((T.picture != null && T.picture != "") ? T.picture : "generic.png")]")
			else
				return resource("images/traders/[nodeImage]")

		getNodeText(var/client/C)
			var/atom/A = master.master
			if(istype(A, /obj/npc/trader))
				var/obj/npc/trader/T = A
				if(T.angry)
					if(nopevoice.len)
						playsound(T, pick(nopevoice), 50, 0)
					return T.angrynope
				else
					return nodeText
			else
				return nodeText

		onActivate(var/client/C)
			..()
			var/atom/A = master.master
			if(istype(A, /obj/npc/trader) && C.mob != null)
				var/obj/npc/trader/T = A
				if(!T.angry)
					T.openTrade(C.mob, windowName = "trader", windowSize = "400x700")
			return DIALOGUE_CLOSE
