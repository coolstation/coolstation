///The laptop that lets you hack doors easily
/obj/item/device/hacking_laptop
	name = "portable computer" //This thing mimics the normal briefcase laptop
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "briefcase"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "briefcase"
	desc = "A much smaller computer workstation, designed to be hoisted around by 80s pro gamers."
	w_class = W_CLASS_NORMAL //Kinda weird to fit a whole briefcase in your backpack, but you have to cut newbies some slack (+ it creates a tell anyway)
	var/overlay_image_url = "images/syndex.gif"
	var/overlay_image_url2 = "images/noise1.png"
	///net IDs of the doors this laptop has hacked
	var/list/hacked_doors

	///Autohacker is currently deployed and conspicuous
	var/open = 0


	New()
		..()
		hacked_doors = list()

	attack_self(mob/user)
		toggle(!open, user)

	//I don't know if there's a way to suppress slamming the door with the laptop, but it'd be nice if there was.
	afterattack(obj/machinery/door/airlock/target, mob/user, reach, params)
		if (!ishuman(user))
			return
		if (isrestrictedz(user.z)) //IDK what azone airlocks are like but I presume this would be a shitshow
			return
		if (!istype(target)) //airlocks only plox
			return
		if (target.net_id in hacked_doors) //hacked before
			toggle(TRUE,user)
			open_hack_UI(target, user)
		else if (!target.cant_emag) //start hacking if it's not a funky special fancy door
			actions.start(new/datum/action/bar/private/autohacker(target, src), user)
			//N.B. You can hack a door with the laptop closed, that's intentional.

/obj/item/device/hacking_laptop/proc/open_hack_UI(obj/machinery/door/airlock/target, mob/user)
	var/html = ""
	if (!istype(user) || !user.find_in_hand(src))
		return

	html += {"<title>D00R PHR34K The Airlock Liberatorrrr!!!</title>
<body style="background-color:#C14417;background-image:url([resource(src.overlay_image_url)]);">
<b>D00R PHR34K</b><br>
Hello hacker fucker<br><br>
<div style = "background-image:url([resource(src.overlay_image_url2)]);font-size:large;font-family:courier;">
<br><span style="background-color:yellow;"><b>This airlock is:</b><br>"}
	// open/close status
	if (!target.density) //IDK if there's a better var for this but fucking hell airlocks are complicated
		html += "<b>OPENED</b> | <a href=byond://?src=\ref[src];command=close;the_door=\ref[target]>(Close!)</a><br>"
	else
		html += "<b>CLOSED</b> | <a href=byond://?src=\ref[src];command=open;the_door=\ref[target]>(Open!)</a><br>"
	// bolts
	if (target.locked)
		html += "<b>BOLTS DROPPED</b> | <a href=byond://?src=\ref[src];command=togglebolts;the_door=\ref[target]>(Raise!)</a><br>"
	else
		html += "<b>BOLTS RAISED</b> | <a href=byond://?src=\ref[src];command=togglebolts;the_door=\ref[target]>(Drop!)</a><br>"
	// electrification
	if (target.secondsElectrified != 0)
		html += "<b>LIVE AT [uppertext(station_or_ship())] VOLTAGE</b> | <a href=byond://?src=\ref[src];command=makesafe;the_door=\ref[target]>(Fuck that!)</a><br>"
	else
		html += "<b>SAFE TO THE TOUCH</b> | <a href=byond://?src=\ref[src];command=electrify;the_door=\ref[target]>(Zappp it!)</a><br>"
	html += "</span><br></div></body>"
	user.Browse(html, "window=autohacker;size=450x350")


/obj/item/device/hacking_laptop/proc/toggle(opening = FALSE, mob/user)
	if (opening)
		icon_state = "briefcase_autohacker" //*FURIOUS TYPING*
		item_state = "briefcase_autohacker"
	else
		icon_state = "briefcase"
		item_state = "briefcase"
		usr.Browse(null, "window=autohacker") //Closes the window
	open = opening
	user.update_inhands()


/obj/item/device/hacking_laptop/Topic(href, href_list)
	//if not in hand, or no user, or the door isn't in range anymore, heck off
	var/obj/machinery/door/airlock/target = locate(href_list["the_door"])
	if (!target || !IN_RANGE(usr, target, 1))
		usr.Browse(null, "window=autohacker")
		return
	if (!href_list["command"])
		usr.Browse(null, "window=autohacker")
		return
	var/mob/user = usr
	if (!user || !user.find_in_hand(src))
		usr.Browse(null, "window=autohacker")
		return

	var/wait = 0
	switch(href_list["command"])
		if ("open")
			target.open()
			wait = 0.6 SECONDS //Door parent why must you have a spawn and a sleep in open() and close() I need your density updates weh
		if ("close")
			target.close()
			wait = 0.6 SECONDS
		if ("togglebolts")
			target.toggle_bolt(usr)
		if ("electrify")
			target.shock_perm(usr)
		if ("makesafe")
			target.shock_restore(usr)
	SPAWN_DBG(wait)
		open_hack_UI(target, usr) //Update status :3

//--------------------------------------------
//--------------------------------------------
///Unlocking a door for the autohacker to manipulate
/datum/action/bar/private/autohacker
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACTION
	var/obj/machinery/door/airlock/target_door
	var/obj/item/device/hacking_laptop/beepboop
	var/mob/living/carbon/human/user //IDK if typecasting every onUpdate (= every tick) has any performance impact but it sounds like a gross thing to do
	id = "autohack"

	New(var/obj/machinery/door/airlock/target, var/obj/item/device/hacking_laptop/loptap)
		src.target_door = target
		src.beepboop = loptap
		..()

	onStart()//So onStart won't be called with any arguments, but owner isn't set until right before onStart is called :) :) :)
		src.user = owner
		..()

	onEnd()
		..()
		beepboop.hacked_doors += target_door.net_id

		//I can't decide if it'd be better for the thing to stay stealthy if you hack a door with the briefcase closed or not, so I coded both

		beepboop.toggle(TRUE, user) //Open er up
		beepboop.open_hack_UI(target_door, user)

		/*
		if (beepboop.open) //Remain sneaky
			beepboop.open_hack_UI(target_door, user)
		*/

	onUpdate() //I didn't see anything about dropping an item calling INTERRUPT_ACT, otherwise this override is unnecessary
		..()
		if (!user.find_in_hand(beepboop)) //You have to hold the fucking laptop the whole time
			interrupt(INTERRUPT_ALWAYS)
