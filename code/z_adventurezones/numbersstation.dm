var/global/shut_up_about_the_fucking_numbers_station = 1

/client/proc/toggle_numbers_station_messages()
	set name = "Toggle Numbers Station Alerts"
	set desc = "I DON'T CARE WHEN SPACE NUMBERS STATION LINCOLNSHIRE IS BROADCASTING SO SHUT UP ABOUT IT"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	ADMIN_ONLY

	shut_up_about_the_fucking_numbers_station = !(shut_up_about_the_fucking_numbers_station)
	logTheThing("admin", usr, null, "toggled numbers station alerts [shut_up_about_the_fucking_numbers_station ? "off" : "on"].")
	logTheThing("diary", usr, null, "toggled numbers station alerts [shut_up_about_the_fucking_numbers_station ? "off" : "on"].", "admin")
	message_admins("[key_name(usr)] toggled numbers station alerts [shut_up_about_the_fucking_numbers_station ? "off" : "on"]")

/area/spyshack
	name = "Space Shack"
	icon_state = "yellow"

/obj/item/paper/mission_outline
	name = "gibberish note"
	info = {"YWTMBYVWZSVRWFWDZVHZRULFBDYCGEZOOPOLMKPFKHTMBHDAOICVXWQPMCLPWEIXKSQWJNCE<br>
ICWRAIWSWFTCAAIMFJOPRXIUPKKTPENMLHNVQCXLQXUYHAXQIUVVDXJNDQVJMWCOJITURUBN<br>
WUMGOFCDVYHPSZGJENGUXOYGEPEDQAOSUOUOKOSCSXNAMQXICOSCSHGIZBDFASSIDFSGNFAW<br>
UQFNBSOJJGKISGYIOGYOWUXRTROLAIEEOTNJCWSWTKXLNEHHUTLOBUZXVHMBPJECPUQECKNQ<br>
ITAYIULHQNCMUOKYBJVRGCPGZBMVIYCQVSOSGLUWVJFUPSEJRIJXQICSGIBCUQCRSBORGQWB<br>
MBNEEDWMKCEZRNYLTREWBFQKNRYJMYLCOFSDSXITAPZB<br><br>

<i><b>On the back of the note is a scribbling:</b> When Blaise says the name of the target, the key of the other unlocks the knowledge.</i>"}

/obj/item/paper/otp
	name = "gibberish note"
	info = {"<i>There are multiple pages of gibberish in this notepad. The first page says:</i>
SXSUZEUKQMUPBHFLFXKOVYKUMWTRPIPSZKHNFWXKBLKEJMTMSHMBCGXOOAOSEYVMTWYAYUPL<br>
HQDFGMEYYIUBTDETHNAMKMVDZMOAXIVQUBAMGMJCHSLTUOAYWFLBJAWWAIKNHZSVZCLGDTBU<br>
MTRYNJKJXBFAQXWESKASBIPKZSLXDTTFWJAYTBKHRQBBJJENYKLNLYYJUEHYIQAWXNJPGTDT<br>
NXRSOCZWETSNAGNIQYMBRMYUOFQFIUIDDAAEWVAKXOPNDDEINMUTLHVNGZZBVYZHXCJBKVGZ<br>
HJEBZAMNJBVKDMHNDRCMSQTLFCHABZQOUTGTWUGNINGYWWBNVZMDIRJAERFLGUJMECGPVBPI<br>
OJSSDONANBRYRWKZIITDCIZULMFCKZZGHLUHNQHPYEKU<br>
"}

/obj/item/paper/intelligence_report
	name = "intelligence report"
	info = {"<b>Clandestine Positronics intelligence report on possible threats regarding the facility</b><br><br>

<i>This information is for the eyes of the facility administrator. If you are not authorized to read this report, please report to your facility administrator for bloodline termination.</i><br><br>

Nanotrasen awareness regarding the facility is currently low. High command is mobilizing infiltrator teams, but military action is not expected for a while.<br>
Thanks to our agents inside the organization, we were able to identify two infiltrators working undercover as scientists. Their designation follows: <br>
- #94413, medium field training, medium value in research. Suggesting immediate elimination in field mission.<br>
- #84153, low field training, extremely high value researcher. Suggesting assignment as primary researcher until further notice."}

/obj/item/paper/numbers_note
	name = "bloody piece of paper"
	desc = "It seems to have some interesting scribblings."
	icon_state = "paper_caution_bloody"

	sizex = 400
	sizey = 600
	rand_pos = 8

	New()
		..()
		info = "<html><body style='margin:0px'><img src='[resource("images/bloody_numbers_note.png")]'></body></html>"

	examine()
		return ..()

	attackby()
		return



/obj/item/paper/requisitionF49A
	name = "requisition form f49-a"
	desc = "Not to be confused with f49-b or f49-c, of course."
	info = {"<html><head></head><body><b>REQUISITION FORM NT-F49-A </b><br>

Site: <b>NT COLONY X03-B 'New Tharros'</b><br>
Quartermaster: <i>J.B. Fiske</i>
<ul>
<br>
REQUEST 1 of 3: Botany Outpost - APPROVED
<li>14 Barrels, GroBoost Nutrients</li>
<li>15 Barrels, TopCrop Nutrients</li>
<li>8 Barrels, Weedkiller</li><br>
<i>Reason: resupply</i><br><br>
REQUEST 2 of 3: Mining Outpost - APPROVED
<li>1 Automated Drill Rover</li>
<li>1 Crate, Mining Helmets(5/pk)</li>
<li>1 Vending Machine Repair Kit</li><br>
<i>Reason: repairs, resupply</i><br><br>
REQUEST 3 of 3: Atmos Facility - APPROVED
<li>2 MULEXL Wheel Assemblies</li>
<li>1 MULEXL Rear Axle Replacement Kit</li>
<li>2 Medical Crates, Standard</li>
<li>6 High Volume Air Canisters</li>
<li>1 Crate, Bodybags(5/pk)</li><br>
<i>Reason: repairs, resupply</i><br><br>

Allocation has been | <u>AUTHORIZED</u> | NOT AUTHORIZED <br> <br>
Fulfillment Method: Merchant | Teleporter | Shuttle | Pod | <br>
Mass Driver | <u>Sub-Orbital Drop</u> | Freighter | Rocket | Other <br><br>

-T.Nakamoto<br>
Regional Supply Director<br>
Logistics and Requisitions<br>
Nanotrasen, Inc.<br>

"}


/obj/item/paper/requisitionF49B
	name = "requisition form f49-b"
	desc = "Not to be confused with f49-a or f49-c, of course. It's stamped 'DELIVERED'"
	info = {"<html><head></head><body><b>REQUISITION FORM NT-F49-B </b><br>

Site: <b>NT X05 Research Complex</b><br>
Head of Personnel: <i>Otis Oates</i>
<ul>
<br>
REQUEST 1 of 2: Outpost Sigma - APPROVED
<li>1 Engineer</li>
<li>2 Assistants</li>
<li>1 Janitor</li>
<br>
<i>Reason: monthly support staff rotation</i><br><br>
REQUEST 2 of 2: Outpost Gamma - APPROVED
<li>2 Security Guards</li>
<li>3 Assistants</li>
<li>1 Medical Doctor</li>
<li>1 Shovel</li>
<li>1 Entertainment Contractor, 1-Day Contract "Rent-a-Wrestler"</li>
<i>Reason: incident, welcome party for new hires</i><br><br>


Allocation has been | <u>AUTHORIZED</u> | NOT AUTHORIZED <br> <br>
Fulfillment Method: Merchant | Teleporter | <u>Shuttle</u> | Pod | <br>
Mass Driver | Sub-Orbital Drop | Freighter | Rocket | Other <br><br>

-Thad Davies<br>
Regional Assistant Director<br>
Human Resources<br>
Nanotrasen, Inc.<br>

"}



/obj/item/paper/requisitionF49A/theta
	name = "requisition form f49-a"
	desc = "Not to be confused with f49-b or f49-c, of course. It's stamped 'DELIVERED'"
	info = {"<html><head></head><body><b>REQUISITION FORM NT-F49-A </b><br>

Site: <b>NT X15 Outpost Theta</b><br>
Research Director: <i>Bob "Bob" Fredrickksen</i>
<ul>
<br>
REQUEST 1 of 1: Research Pod, Surface - APPROVED
<li>1 reindeer sweater</li>
<li>1 snowflake sweater</li>
<li>1 diamond sweater</li>
<br>
<i>Reason: staff appreciation day</i><br><br>


Allocation has been | <u>AUTHORIZED</u> | NOT AUTHORIZED <br> <br>
Fulfillment Method: <u>Merchant</u> | Teleporter | Shuttle | Pod | <br>
Mass Driver | Sub-Orbital Drop | Freighter | Rocket | Other <br><br>

-T.Nakamoto<br>
Regional Supply Director<br>
Logistics and Requisitions<br>
Nanotrasen, Inc.<br>

"}





/obj/item/paper/empty_bloody
	name = "bloody piece of paper"
	desc = "It's blank. Well, other than the blood, anyway."
	icon_state = "paper_caution_bloody"
	info = "<i>The paper is full of eraser marks and scratches but there is nothing legible on here.</i>"
	rand_pos = 8

/obj/item/paper/diner_invoice
	name = "bloody piece of paper"
	desc = "It seems to have some interesting scribblings."
	info = {"<html><head></head><body><b>Delivery invoice</b><br><br>

<b>Articles:</b><br>
<ul><li>4 key lime pies</li>
<li>4 lemon meringue pies</li>
<li>3 jumbo size human meat substitute burgers</li><br><br>

<b>Total:</b> 4134 space credits<br>
<b>Thank</b>... <i>the rest of the invoice is covered in blood and illegible</i>"}
	icon_state = "paper_caution_bloody"
	rand_pos = 8

/obj/item/onyxphoto
	name = "photo of onyx key"
	icon = 'icons/misc/terra8.dmi'
	icon_state = "onyx_photo"
	desc = "You can see a dark key carved of onyx. It's been set on a lab bench with measurement scales alongside it. You feel uneasy looking at this for some reason."
	var/used = 0

/obj/item/storage/secure/ssafe/pilot_cargo1
	name = "pilot's lockbox"

/obj/item/storage/secure/ssafe/pilot_cargo2
	name = "pilot's lockbox"
	configure_mode = 0
	random_code = 1
	spawn_contents = list(/obj/item/paper/requisitionF49B,
	/obj/item/spacecash/thousand, /obj/item/spacecash/thousand, /obj/item/reagent_containers/food/drinks/bottle/fancy_beer)

/obj/item/storage/secure/ssafe/pilot_cargo3
	name = "pilot's lockbox"
	configure_mode = 0
	random_code = 1
	spawn_contents = list(/obj/item/paper/requisitionF49A/theta,
	/obj/item/reagent_containers/emergency_injector/random,/obj/item/reagent_containers/emergency_injector/random,
	/obj/item/reagent_containers/food/drinks/bottle/hobo_wine)



/datum/numbers_station // This is not a physical entity!
	var/name = "Space Lincolnshire"
	var/frequency = FREQ_NUMBERS
	var/sound_channel = 174
	var/login_signal = 'sound/misc/lincolnshire.ogg'
	var/list/numbers = list(0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0)
	var/list/listeners = list()
	var/play_interval = 9000 // 15 minutes
	var/next_warning = 0
	var/next_play = 0

	New()
		..()
		processing_items |= src
		if (ticker)
			while (next_play <= ticker.round_elapsed_ticks)
				next_play += play_interval
		else
			next_play = play_interval
		next_warning = next_play - 300
		SPAWN_DBG(20 SECONDS)
			apiHandler.queryAPI("numbers/get")

	proc/gather_listeners()
		listeners = list()
		for (var/mob/living/carbon/human/H in mobs)
			LAGCHECK(LAG_LOW)
			for (var/obj/item/device/radio/Hs in H)
				if (Hs.frequency == frequency)
					listeners += H
					boutput(H, "<span class='notice'>A peculiar noise intrudes upon the radio frequency of your [Hs].</span>")
				break
		for (var/mob/living/silicon/robot/R in mobs)
			LAGCHECK(LAG_LOW)
			if (istype(R.radio, /obj/item/device/radio))
				var/obj/item/device/radio/Hs = R.radio
				if (Hs.frequency == frequency)
					listeners += R
					boutput(R, "<span class='notice'>A peculiar noise intrudes upon your radio frequency.</span>")

	proc/play_all_numbers()
		var/batch = 0
		var/period = get_vox_by_string(".")
		for (var/number in numbers)
			play_number(number)
			broadcast_sound(period)
			batch++
			if (batch >= 3)
				sleep(0.1 SECONDS)

	proc/process()
		if (ticker.round_elapsed_ticks >= next_warning)
			next_warning += play_interval
			if (!shut_up_about_the_fucking_numbers_station) // SHUT UP
				message_coders("Numbers station [name] broadcasting in about 30 seconds.")
			return
		if (ticker.round_elapsed_ticks >= next_play)
			next_play += play_interval
			if (!shut_up_about_the_fucking_numbers_station)
				message_coders("Numbers station [name] broadcasting now.")
			logTheThing("debug", null, null, "<b>Numbers station</b>: [name] is broadcasting on frequency [frequency / 10].")
			gather_listeners()
			if (!listeners.len)
				logTheThing("debug", null, null, "<b>Numbers station:</b> [name] broadcast aborted: no listeners.")
				return
			SPAWN_DBG(1 SECOND)
				broadcast_sound(login_signal)
				play_all_numbers()
				var/doop = get_vox_by_string("doop")
				var/deeoo = get_vox_by_string("deeoo")
				broadcast_sound(doop)
				broadcast_sound(deeoo)
				broadcast_sound(doop)
				play_all_numbers()

	proc/broadcast_sound(var/soundfile)
		for (var/mob/M in listeners)
			if (M.client)
				M << sound(soundfile, volume = 100, channel = sound_channel, wait = 1)

	proc/get_tens(var/n)
		if (n >= 20)
			var/tens = floor(n / 10)
			switch (tens)
				if (2)
					return "twenty"
				if (3)
					return "thirty"
				if (4)
					return "fourty"
				if (5)
					return "fifty"
				if (6)
					return "sixty"
				if (7)
					return "seventy"
				if (8)
					return "eighty"
				if (9)
					return "ninety"
		return null

	proc/get_ones(var/n)
		if (n == 0)
			return "zero"
		if (n >= 10 && n < 20)
			switch (n)
				if (10)
					return "ten"
				if (11)
					return "eleven"
				if (12)
					return "twelve"
				if (13)
					return "thirteen"
				if (14)
					return "fourteen"
				if (15)
					return "fifteen"
				if (16)
					return "sixteen"
				if (17)
					return "seventeen"
				if (18)
					return "eighteen"
				if (19)
					return "nineteen"
		else
			var/ones = n % 10
			switch (ones)
				if (1)
					return "one"
				if (2)
					return "two"
				if (3)
					return "three"
				if (4)
					return "four"
				if (5)
					return "five"
				if (6)
					return "six"
				if (7)
					return "seven"
				if (8)
					return "eight"
				if (9)
					return "nine"
		return null

	proc/get_vox_by_string(var/vt)
		if (!vt)
			return null
		var/datum/VOXsound/vs = voxsounds[vt]
		if (!vs)
			return null
		return vs.ogg

	proc/play_number(var/n)
		var/stens = get_tens(n)
		var/ogg = get_vox_by_string(stens)
		if (ogg)
			broadcast_sound(ogg)
		var/sones = get_ones(n)
		ogg = get_vox_by_string(sones)
		if (ogg)
			broadcast_sound(ogg)

var/global/datum/numbers_station/lincolnshire = new

/proc/debug_lincolnshire()
	lincolnshire.next_warning = 0
	lincolnshire.process()
	lincolnshire.next_play = 0
	lincolnshire.process()

/proc/lincolnshire_numbers(data)
	if (islist(data))
		logTheThing("debug", null, null, "<b>Numbers station</b>: numbers: [data["numbers"]]")
		var/TP = data["numbers"]
		if (TP == null)
			return 1
		var/list/nums = splittext(TP, " ")
		if (nums.len < 21)
			logTheThing("debug", null, null, "<b>Numbers station</b> got too few numbers.")
			return 2
		for (var/i = 1, i <= 21, i++)
			lincolnshire.numbers[i] = text2num(nums[i])
		logTheThing("debug", null, null, "<b>Numbers station</b> woo success")
		return 0
	return 3


// This particular edition of the handbook is used as the cipher for the numbers station.
/obj/item/paper/book/from_file/numbers_station_hydroguide
	name = "The Helpful Hydroponics Handbook"
	icon_state = "book3"
	file_path = "strings/books/numbers_station_hydroguide.txt"
