/obj/npc/trader/pricemaster
	name = "The PriceMaster"
	desc = "Make him an offer."
	picture = "pm_start.png"
	density = 1
	anchored = 1
	icon = 'icons/mob/trader.dmi'
	icon_state = "pricemaster"
	hiketolerance = 0
	dialogue = null
	trader_area = "/area/pricemaster"

	New()
		..()
		dialogue = new/datum/dialogueMaster/priceMaster(src)
		if(prob(50))
			src.goods_sell += new /datum/commodity/pricemaster/robot_fist_l(src)
		else
			src.goods_sell += new /datum/commodity/pricemaster/robot_fist_r(src)
		if(prob(75))
			src.goods_sell += new /datum/commodity/pricemaster/chainsaw(src)
		else
			src.goods_sell += new /datum/commodity/pricemaster/lasergun(src)
		src.goods_sell += new /datum/commodity/pricemaster/communicator(src)
		src.goods_sell += new /datum/commodity/pricemaster/nunchucks(src)
		src.goods_sell += new /datum/commodity/pricemaster/tv(src)

		src.set_dir(pick(NORTH,EAST,SOUTH,WEST))

	Click(location,control,params)
		dialogue.showDialogue(usr)
		return

	errormsgs = list("EVERYTHING IS FOR SALE!",
					"EVERYTHING IS FOR SALE!",
					"MAKE ME AN OFFER!",
					"I AM PRICEMASTER. MAKE ME AN OFFER!",
					"THE PRICEMASTER HAS SPOKEN.",
					"THANK YOU FOR SHOPPING.")

	successful_purchase_dialogue = list("THANK YOU FOR SHOPPING")
	successful_purchase_sound = list('sound/voice/PRICEMASTER/EXCLAMATIONS/THANK_YOU_FOR_SHOPPING.ogg',\
					'sound/voice/PRICEMASTER/EXCLAMATIONS/THANK_YOU_FOR_SHOPPING2.ogg',\
					'sound/voice/PRICEMASTER/EXCLAMATIONS/THANK_YOU_FOR_SHOPPING3.ogg',\
					'sound/voice/PRICEMASTER/EXCLAMATIONS/YES.ogg')


	////////////////////////////////////////////////////
	/////////Proc for haggling with pricemaster////////
	//////////////////////////////////////////////////
	spawncrate(var/list/custom)
		usr?.unlock_medal("EVERYTHING IS FOR SALE")
		..(custom)

	haggle(var/askingprice, var/buying, var/datum/commodity/H)
		src.temp = null
		var/master_price = 0
		var/list/sentence = list()
		src.set_dir(pick(NORTH,EAST,SOUTH,WEST))
		// if something's gone wrong and there's no input, reject the haggle
		// also reject if there's no change in the price at all
		if (!askingprice) return
		if (askingprice == H.price) return
		// if the player is being dumb and haggling in the wrong direction, tell them (unless the trader is an asshole)
		if (buying == 1)
			// we're buying, so we want to pay less per unit
			if(askingprice > H.price)
				if (src.bullshit >= 5)
					master_price = askingprice
					src.temp = "<B>Cost:</B> [H.price] Credits<BR>"
					src.temp += src.errormsgs[1]
					H.haggleattempts++
					src.bullshit++
					//return
				else
					master_price = H.price
					src.temp = "<B>Cost:</B> [H.price] Credits<BR>"
					src.temp += src.errormsgs[2]
					src.bullshit++
					//return
		else
			// we're selling, so we want to be paid MORE per unit
			if(askingprice < H.price)
				if (src.bullshit >= 5)
					master_price = askingprice
					H.haggleattempts++
					src.bullshit++
					src.temp = "<B>Cost:</B> [H.price] Credits<BR>"
					src.temp += src.errormsgs[3]
					//return
				else
					master_price = H.price
					src.temp = "<B>Cost:</B> [H.price] Credits<BR>"
					src.temp += src.errormsgs[4]
					src.bullshit++
					//return



		//pricemaster does not haggle... much
		var/firstnum = askingprice
		var/list/temp2 = list()

		if(!src.temp) // skip over the price generation if we just haggled badly
			while(firstnum > 11)
				firstnum /= 10
			firstnum = floor(firstnum)

			H.haggleattempts++
			src.bullshit++

			if(prob(10))
				var/datum/priceVOXsound/V = pick(pmvoxcomplete)
				sentence += V
				master_price = V.value
				src.temp = V.string
				src.bullshit++

			else
				while((H.haggleattempts && (master_price <= H.price) && src.bullshit))
					src.bullshit--
					sentence = list()//we need to reset this every loop just in case


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
						else if(V.value == 150000) // special case
							master_price = master_price*100000 + 50000
						else
							master_price *= V.value

			if((master_price <= 999) && prob(50)) // one last price hike
				var/thousands = rand(1,5) // these are the safest ones i think
				var/list/temp3 = list()
				temp3 += pmvoxnums[thousands]
				temp3 += pmvoxmisc[1]
				temp3 += sentence
				sentence = temp3
				src.temp = pmvoxnums[thousands]:string + " THOUSAND " + src.temp
				master_price += thousands * 1000
		else
			sentence += pick(pmvoxthings)

		//ok so we either got a higher price or gave up
		if (patience <= H.haggleattempts)
			src.temp += " ... THE PRICEMASTER HAS SPOKEN."
			sentence += pick(pmvoxend)

		for(var/datum/priceVOXsound/V in sentence)
			V.load()

		src.temp = "<B>[src.temp]</B><BR>"
		H.price = master_price
		//and say his new price

		var/floating_text_style = ((src.dialogue && src.dialogue.floating_text_style) ? src.dialogue.floating_text_style : "")
		for(var/mob/M in oviewers(src))
			if(!M.client)
				continue
			var/chat_text = make_chat_maptext(src, src.temp, floating_text_style)
			M.show_message("<span class='name'>[src.name]</span> booms: <span class='message'>\"[src.temp]\"</span>",2, assoc_maptext = chat_text)
			var/client/listener = M.client
			SPAWN_DBG(0)
				for(var/datum/priceVOXsound/V in sentence)
					V.play(listener)
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
			H.price =floor(middleground + rand(0,negotiate))
		else
			if(middleground-H.price <= 0.5)
				H.price = floor(middleground + 1)
			else
				H.price = floor(middleground - rand(0,negotiate))

		src.temp = "<B>New Cost:</B> [H.price] Credits<BR><HR>"
		H.haggleattempts++
		// warn the player if the trader isn't going to take any more haggling
		if (patience == H.haggleattempts)
			src.temp += src.hagglemsgs[src.hagglemsgs.len]
		else
			src.temp += pick(src.hagglemsgs)
*/
proc/init_pmvox() // first bare numbers
	pmvoxnums = list(new/datum/priceVOXsound("1", "sound/voice/PRICEMASTER/1.ogg", 1, "ONE"),
	new/datum/priceVOXsound("2", "sound/voice/PRICEMASTER/2.ogg", 2, "TWO"),
	new/datum/priceVOXsound("3", "sound/voice/PRICEMASTER/3.ogg", 3, "THREE"),
	new/datum/priceVOXsound("4", "sound/voice/PRICEMASTER/4.ogg", 4, "FOUR"),
	new/datum/priceVOXsound("5", "sound/voice/PRICEMASTER/5.ogg", 5, "FIVE"),
	new/datum/priceVOXsound("5a", "sound/voice/PRICEMASTER/5a.ogg", 5, "FIVE"),
	new/datum/priceVOXsound("7", "sound/voice/PRICEMASTER/7.ogg", 7, "SEVEN"),
	new/datum/priceVOXsound("9", "sound/voice/PRICEMASTER/9.ogg", 9, "NINE"),
	new/datum/priceVOXsound("10", "sound/voice/PRICEMASTER/10.ogg", 10, "TEN"),
	new/datum/priceVOXsound("10a", "sound/voice/PRICEMASTER/10a.ogg", 10, "TEN"),
	new/datum/priceVOXsound("17", "sound/voice/PRICEMASTER/17.ogg", 17, "SEVENTEEN"),
	new/datum/priceVOXsound("40", "sound/voice/PRICEMASTER/40.ogg", 40, "FORTY"),
	new/datum/priceVOXsound("60", "sound/voice/PRICEMASTER/60.ogg", 60 ,"SIXTY"),
	new/datum/priceVOXsound("67", "sound/voice/PRICEMASTER/67.ogg", 67, "SIXTY-SEVEN"),
	new/datum/priceVOXsound("70", "sound/voice/PRICEMASTER/70.ogg", 70, "SEVENTY"),
	new/datum/priceVOXsound("78", "sound/voice/PRICEMASTER/78.ogg", 78, "SEVENTY-EIGHT"))

	pmvoxmisc = list(new/datum/priceVOXsound("thousand", "sound/voice/PRICEMASTER/THOUSAND.ogg", 1000),
	new/datum/priceVOXsound("pointseven", "sound/voice/PRICEMASTER/POINT_SEVEN.ogg", 0.7),
	new/datum/priceVOXsound("hundred", "sound/voice/PRICEMASTER/HUNDRED.ogg", 100),
	new/datum/priceVOXsound("hundred_t", "sound/voice/PRICEMASTER/HUNDRED_THOUSAND.ogg", 100000),
	new/datum/priceVOXsound("500", "sound/voice/PRICEMASTER/500.ogg", 500))

	pmvoxdollars = list(new/datum/priceVOXsound("billion", "sound/voice/PRICEMASTER/DOLLARS/BILLION_DOLLARS.ogg", 100000000, " BILLION DOLLARS"),
	new/datum/priceVOXsound("hundred", "sound/voice/PRICEMASTER/DOLLARS/HUNDRED_AND_FIFTY_THOUSAND_DOLLARS.ogg", 150000, " HUNDRED AND FIFTY THOUSAND DOLLARS"),
	new/datum/priceVOXsound("hundred", "sound/voice/PRICEMASTER/DOLLARS/HUNDRED_AND_THIRTY_SIX_DOLLARS.ogg", 136, " HUNDRED AND THIRTY SIX DOLLARS"),
	//new/datum/priceVOXsound("hundred", "sound/voice/PRICEMASTER/DOLLARS/HUNDRED_BILLION_DOLLARS.ogg", 10000000000, " HUNDRED BILLION DOLLARS"), // not sure why this one is so problematic
	new/datum/priceVOXsound("hundred", "sound/voice/PRICEMASTER/DOLLARS/HUNDRED_DOLLARS.ogg", 100, " HUNDRED DOLLARS"),
	new/datum/priceVOXsound("hundred", "sound/voice/PRICEMASTER/DOLLARS/HUNDRED_DOLLARS2.ogg", 100, " HUNDRED DOLLARS"),
	new/datum/priceVOXsound("hundred", "sound/voice/PRICEMASTER/DOLLARS/HUNDRED_FORTY_SIX_DOLLARS.ogg", 146, " HUNDRED FORTY SIX DOLLARS"),
	new/datum/priceVOXsound("thousand", "sound/voice/PRICEMASTER/DOLLARS/THOUSAND_DOLLARS.ogg", 1000, " THOUSAND DOLLARS"),
	new/datum/priceVOXsound("thousand", "sound/voice/PRICEMASTER/DOLLARS/THOUSAND_DOLLARS2.ogg", 1000, " THOUSAND DOLLARS"),
	new/datum/priceVOXsound("thousand", "sound/voice/PRICEMASTER/DOLLARS/THOUSAND_DOLLARS3.ogg", 1000, " THOUSAND DOLLARS"),
	new/datum/priceVOXsound("thousand", "sound/voice/PRICEMASTER/DOLLARS/THOUSAND_DOLLARS4.ogg", 1000, " THOUSAND DOLLARS"))

	pmvoxthings = list(new/datum/priceVOXsound("communicator", "sound/voice/PRICEMASTER/THINGS/THE_COMMUNICATOR.ogg", 0),
	new/datum/priceVOXsound("enemabox", "sound/voice/PRICEMASTER/THINGS/THE_ENEMA_BOX.ogg", 0),
	new/datum/priceVOXsound("lasergun", "sound/voice/PRICEMASTER/THINGS/THE_LASER_GUN.ogg", 0),
	new/datum/priceVOXsound("robotfist", "sound/voice/PRICEMASTER/THINGS/THE_ROBOT_FIST.ogg", 0),
	 new/datum/priceVOXsound("communication", "sound/voice/PRICEMASTER/THINGS/COMMUNICAITON.ogg", 0))

	pmvoxcomplete = list(new/datum/priceVOXsound("500", "sound/voice/PRICEMASTER/COMPLETES/5_HUNDRED_DOLLARS.ogg", 500, "FIVE HUNDRED DOLLARS"),
	new/datum/priceVOXsound("500a", "sound/voice/PRICEMASTER/COMPLETES/5_HUNDRED_DOLLARS2.ogg", 500, "FIVE HUNDRED DOLLARS"),
	new/datum/priceVOXsound("9000", "sound/voice/PRICEMASTER/COMPLETES/9_THOUSAND_DOLLARS.ogg", 9000, "NINE THOUSAND DOLLARS"),
	new/datum/priceVOXsound("10000", "sound/voice/PRICEMASTER/COMPLETES/10_THOUSAND_DOLLARS.ogg", 10000, "TEN THOUSAND DOLLARS"),
	new/datum/priceVOXsound("78000", "sound/voice/PRICEMASTER/COMPLETES/78_THOUSAND_DOLLARS.ogg", 78000, "SEVENTY-EIGHT THOUSAND DOLLARS"),
	new/datum/priceVOXsound("17.42", "sound/voice/PRICEMASTER/COMPLETES/17_DOLLARS_AND_42_CENTS.ogg", 17.42, "SEVENTEEN DOLLARS AND FORTY-TWO CENTS"),
	new/datum/priceVOXsound("136", "sound/voice/PRICEMASTER/COMPLETES/ONE_HUNDRED_AND_THIRTY_SIX_DOLLARS.ogg", 136,"ONE HUNDRED AND THIRTY SIX DOLLARS"))

	pmvoxend = list(new/datum/priceVOXsound("spoken", "sound/voice/PRICEMASTER/EXCLAMATIONS/THE_PRICEMASTER_HAS_SPOKEN.ogg", 0, "THE PRICEMASTER HAS SPOKEN"),
	new/datum/priceVOXsound("spoken2", "sound/voice/PRICEMASTER/EXCLAMATIONS/THE_PRICEMASTER_HAS_SPOKEN2.ogg", 0, "THE PRICEMASTER HAS SPOKEN"),
	new/datum/priceVOXsound("spoken3", "sound/voice/PRICEMASTER/EXCLAMATIONS/THE_PRICEMASTER_HAS_SPOKEN3.ogg", 0, "THE PRICEMASTER HAS SPOKEN"),
	new/datum/priceVOXsound("spoken4", "sound/voice/PRICEMASTER/EXCLAMATIONS/THE_PRICEMASTER_HAS_SPOKEN4.ogg", 0, "THE PRICEMASTER HAS SPOKEN"),
	new/datum/priceVOXsound("spoken5", "sound/voice/PRICEMASTER/EXCLAMATIONS/THE_PRICEMASTER_HAS_SPOKEN5.ogg", 0, "THE PRICEMASTER HAS SPOKEN"))

	SPAWN_DBG(0.1 SECONDS)
		var/listolists = list(pmvoxnums, pmvoxmisc, pmvoxdollars, pmvoxthings, pmvoxcomplete, pmvoxend)
		for(var/list/listo in listolists)
			for(var/thing in listo)
				var/datum/priceVOXsound/vox = thing
				vox.ogg = file(vox.ogg)




/datum/priceVOXsound
	var/id
	var/ogg
	var/sound/soundFile
	var/flags
	var/value
	var/string = ""

	New(var/id, var/file, var/value, var/string = "")
		..()
		src.id = id
		src.ogg = file
		src.value = value
		src.string = string

	disposing()
		ogg = null
		soundFile = null
		//voxsounds -= src //todo
		..()

	proc/load(var/freq = 1)
		if (src.ogg)
			src.soundFile = sound(src.ogg, wait = 1, channel = 5)
			src.soundFile.frequency = freq
			src.soundFile.volume = 100 //fuck vox man you are SO LOUD!!!!!!

	proc/play(var/client/listener)
		if (src.soundFile)
			listener << src.soundFile



/datum/dialogueMaster/priceMaster
	dialogueName = "THE PRICEMASTER"
	start = /datum/dialogueNode/pm_start
	visibleDialogue = 1
	floatingText = 1
	floating_text_style = "font-size:large;"
	//maxDist    ance = 3

/datum/dialogueNode
	pm_start
		nodeImage = "pm_start.png"
		links= list(/datum/dialogueNode/pm_who, /datum/dialogueNode/pm_StartTrade)
		linkText = "..."
		nodeText = "EVERYTHING IS FOR SALE"
		voiceClips = list('sound/voice/PRICEMASTER/EXCLAMATIONS/I_AM_PRICEMASTER.ogg',\
							'sound/voice/PRICEMASTER/EXCLAMATIONS/EL_MAESTRO_DEL_PRICIO.ogg',\
							'sound/voice/PRICEMASTER/EXCLAMATIONS/EVERYTHING_IS_FOR_SALE.ogg',\
							'sound/voice/PRICEMASTER/EXCLAMATIONS/EVERYTHING_IS_FOR_SALE2.ogg')
		onActivate(var/client/C)
			..()
			var/atom/A = master.master
			A.set_dir(pick(NORTH,EAST,SOUTH,WEST))

	pm_who
		links= list(/datum/dialogueNode/pm_StartTrade)
		linkText = "who are you?"
		nodeText = "I AM PRICEMASTER"
		nodeImage = "pm_who.png"
		voiceClips = list('sound/voice/PRICEMASTER/EXCLAMATIONS/I_AM_PRICEMASTER.ogg',\
							'sound/voice/PRICEMASTER/EXCLAMATIONS/I_AM_PRICEMASTER-MAKE_ME_AN_OFFER.ogg')

	pm_StartTrade
		linkText = "are you selling anything?"
		nodeText = "MAKE ME AN OFFER"
		voiceClips = list('sound/voice/PRICEMASTER/EXCLAMATIONS/MAKE_ME_AN_OFFER.ogg',\
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
					return T.angrynope
				else
					return nodeText
			else
				return nodeText

		onActivate(var/client/C)
			var/atom/A = master.master
			A.set_dir(pick(NORTH,EAST,SOUTH,WEST))
			if(istype(A, /obj/npc/trader) && C.mob != null)
				var/obj/npc/trader/T = A
				if(T.angry)
					if(nopevoice.len)
						playsound(master.master, pick(nopevoice), 80, 0)
						cooldowning = TRUE
						SPAWN_DBG(1 SECOND)
							cooldowning = FALSE
				else
					T.openTrade(C.mob, windowName = "trader", windowSize = "400x700")
			..()
			return DIALOGUE_CLOSE
