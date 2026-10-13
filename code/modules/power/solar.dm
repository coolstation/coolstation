/* Contains;
- Solar tracker
- Solar panel
- Solar control computer
*/
// Previous SOLARGENRATE was 1500 WATTS processed every 3.2 SECONDS (PROCESSING_EIGHTH). This provided 454.54 WATTS every second
// Adjust accordingly based on machine proc rate
// Boosting a bit because of changes to tracking speed and efficiency, should a little under 200
// Average spawned solar cleanliness will cut this back down to about the same as the original
// If someone wants to go out and wipe down every single panel with a paper towel and space windex they're welcome to the extra power generation, imo
#define SOLARGENRATE (600 * MACHINE_PROCS_PER_SEC) //multiply the unmodified number by 3.2 and you'll get your full power capacity (in this case, 1920 WATTS)

/////////////////////////////////// Solar tracker //////////////////////////////////////////////////////

//Little round blue doodad that tracks the sun and reports it's direction to the solar controllers, one per array
//As long as this is working, solar panels on same powernet will track automatically
//Currently undamageable/unbuildable in no small part due to the ID system

/obj/machinery/power/tracker
	name = "solar tracker"
	desc = "A solar directional tracker."
	icon = 'icons/obj/machines/power.dmi'
	icon_state = "tracker"
	anchored = ANCHORED
	density = 1
	directwired = 1
	var/id = 1
	var/sun_angle = 0		// sun angle as set by sun datum
	var/obj/machinery/power/solar_control/control = null	//the thingy you send your sun angle info to

	north
		id = "north"
	south
		id = "south"
	alt
		id = "alt"
	east
		id = "east"
	west
		id = "west"
	small_backup1
		id = "small_backup1"
	small_backup2
		id = "small_backup2"
	small_backup3
		id = "small_backup3"
	small_backup4
		id = "small_backup4"
	diner
		id = "diner"

//link up to a single solar controller to send your angle tracking to it, intended to be initiated by controller
//if there are multiple "east" controllers or something on the same powernet somehow then shame on you
//controller doesn't link, it just accepts any connection, so that's fine
/obj/machinery/power/tracker/proc/link_control(var/obj/machinery/power/solar_control/SC)
	//attempt to accept direct link
	if(SC && SC.id == id)
		control = SC
		return
	//not matching ID, you fucked up, cancelling here to prevent weird behaviors
	//but we are getting closer to removing IDs from this part entirely, aren't we?
	else
		return

//removing control is just done through iterated list during link/unlink

// called by datum/sun/calc_position() as sun's angle changes
/obj/machinery/power/tracker/proc/set_angle(var/angle)
	sun_angle = angle

	//set icon dir to show sun illumination
	set_dir(turn(NORTH, -angle - 22.5))	// 22.5 deg bias ensures, e.g. 67.5-112.5 is EAST
	// ***TODO: even better communication system using network
	if(control)
		control.tracker_update(angle)

	// override power change to do nothing since we don't care about area power
	// (and it would be pointless anyway given that solar panels and the associated tracker are usually on a separate powernet)
	power_change()
	return

	//no disposal handling either, nobody cares if this little guy is gone


/////////////////////////////////////////////// Solar panel /////////////////////////////////////////////////////

/obj/machinery/power/solar

	//TODO: big bulky two hand panels that can be added and removed with a wrench and wires (or wirecutters and a wrench) to handle damage
	name = "solar panel"
	desc = "A solar electrical generator."
	icon = 'icons/obj/machines/power.dmi'
	icon_state = "solar_panel"
	anchored = ANCHORED
	density = 1
	directwired = 1

	//2024-9-14: commented this processing_tier out because solar panels need to proc add_avail() at the same frequency as powernets proc reset()
	//What would happen is solars output would be erratic because different amounts of panels processed over time (in a cycle), so you'd get an input
	//at the SMES like (for example) 8kW -> 9kW -> 56kW -> 2 kW -> 8kW repeating
	//and since SMESes don't charge unless given a decently stable input over a few cycles, they wouldn't charge worth anything.

	//BTW I think "line 175" refers to the [sgen *= PROCESSING_TIER_MULTI(src)] line below, but by the time of open source goon it was already pointing elsewhere

	//processing_tier = PROCESSING_32TH // Uncomment this and line 175 for an experimental optimization
	//now that I've been waist deep in all this I feel like the 32th "optimization" is a bandaid over doing proper lists and adding/removing them in a sensible way

	power_usage = 10 //used by servos to reorient. an emergency battery for the solar leg wiring might be a good idea, otherwise should be self sustaining?
	var/health = 10.0
	var/id = "unset"
	var/obscured = FALSE //evaluated and set by sun controller; if the direction this panel is pointing is in shadow (i.e. unable to reach the edge of the map or 20 tiles without being blocked by a dense turf like the station) then don't even process it
	var/sunfrac = 0 //angle difference between solar panel and sun position, for reduction purposes
	var/adir = SOUTH //actual direction, where the panel is pointed right this moment
	var/ndir = SOUTH //new direction, set by linked controller
	var/cleanliness //between 0 and 100, used as a percent for reducing power generation even at full sun angle
	var/lubrication //between 0 and 100, used as a percent for slowing rotation. replenishes from 0-100 from built in 10U tank
	var/stuck = FALSE //has something happened and it fails to move? adding enough oil will fix it, and if there's enough oil
	var/controldist = 1 //distance from controller, directly. not important: it's for making the rotation animations radiate outward
	var/obj/machinery/power/solar_control/control //console that's currently controlling this panel (and receiving its power output)

	north
		id = "north"
	south
		id = "south"
	alt
		id = "alt"
	east
		id = "east"
	west
		id = "west"
	small_backup1
		id = "small_backup1"
	small_backup2
		id = "small_backup2"
	small_backup3
		id = "small_backup3"
	small_backup4
		id = "small_backup4"
	diner
		id = "diner"


//TODO: other means of cleaning, repair and other maintenance
//oilcan has special interaction in its code to fill the oil tank, so that works, it's just not here (it's in robotics tools)
/obj/machinery/power/solar/New()
	..()
	SPAWN_DBG(1 SECOND)
		updateicon()
		update_solar_exposure()
		//set up initial efficiency/movement (until we add lubrication handling, this amounts to a redo of the randomness in animations)
		if (map_currently_very_dusty)
			//on rough rough average, 50% efficiency, should be comparable to 300W
			cleanliness = rand(40,60)
		else
			//on rough rough average, 75% efficiency, should be comparable to 450W
			cleanliness = rand(65,85)
		lubrication = rand(50,90)

		//empty holder, 10U reserve tank that is used at 0.1U = 1% to bring solar lubrication up to 100
			//honestly might be room for a re-usable, multi-machine-spanning lubrication system for handling arbitrary reagents
			//but i'm just bowtie spinning with all of this anyway
		create_reagents(10)

/obj/machinery/power/solar/attackby(obj/item/W, mob/user)
	if (istype(W,/obj/item/material_piece/cloth))
		//TODO: action bar that is relative to amount of dirt needing to be cleaned up, 1s for every percent
		//TODO: space cleaner cleans from 0% up to 80% in two sprays but no further, gotta rub it down
		//TODO: space paper towels...
		if (cleanliness >= 100)
			boutput(user, "You can't clean \the [src] up any more than it already is.")
			return
		cleanliness += rand(30,40)
		cleanliness = min(100, cleanliness)
		boutput(user, "You clean \the [src] a bit.")
		return
	if (isscrewingtool(W))
		if(reagents && reagents.total_volume)
			//dump oil
			var/turf/T = get_turf(src)
			logTheThing("combat", user, null, "drains oil tank of [src] [log_reagents(src)] onto [T] at [log_loc(user)].") // Added reagents (Convair880).
			reagents.trans_to(T, src.reagents.total_volume)
			boutput(user, "You open up \the [src]'s oil reserve tank drain and spill its contents.")
		else
			boutput(user, "The \the [src]'s oil tank is completely empty and there's nothing to drain.")
		return


	..()
	add_fingerprint(user)
	health -= W.force
	healthcheck()
	return

/obj/machinery/power/solar/attack_hand(mob/user)
	if(stuck)
		if((prob(10) && lubrication > 10) || lubrication >= 25)
			boutput(user, "You manage to get \the [src] moving again.")
			stuck = FALSE
			if (lubrication < 15)
				playsound(src, pick('sound/effects/valve_creak.ogg'), 40, 1, pitch=0.5)
		else
			boutput(user, "You can't seem to get \the [src] to budge.")
	add_fingerprint(user)

/obj/machinery/power/solar/proc/healthcheck()
	if (health <= 0)
		if(!HAS_FLAG(status, BROKEN))
			broken()
		else
			var/obj/item/raw_material/shard/glass/G = new()
			G.set_loc(src.loc)
			G = new /obj/item/raw_material/shard/glass()
			G.set_loc(src.loc)
			qdel(src)
			return
	return

//link up to a single solar controller to send your power to it, intended to be initiated by controller
/obj/machinery/power/solar/proc/link_control(var/obj/machinery/power/solar_control/SC)
	//attempt to accept direct link
	if (SC && SC.id == id)
		control = SC
		controldist = get_dist(src,control)
		return
	//not matching ID, you fucked up, cancelling here to prevent weird behaviors
	//but we are getting closer to removing IDs from this part entirely, aren't we?
	else
		return

//remove references on this solar panel to controller (do not directly touch references on controller), intended to be initiated by controller
//useful for resetting
/obj/machinery/power/solar/proc/unlink_control()
	controldist = null
	control = null
	ndir = SOUTH //reset to south, stock direction absent any control input
	return

//rotate according to max direction,
/obj/machinery/power/solar/proc/updateicon()
	if(HAS_FLAG(status, BROKEN))
		icon_state = "solar_panel-b"
	else
		icon_state = "solar_panel"
		set_dir(NORTH)
		//visual confirmation of any slow panels in need of maintenance
		//no oil is 4s, full oil is 1s, no longer random
		var/rotation_time = (1 + ((100-lubrication)/100 * 3)) SECONDS
		//delay in actually beginning to turn, by distance from controller, also no longer random
		//each tile away is a half-second delay
		animate(src, time=(min(controldist*5)))
		//the actual turn, governed by oil levels
		animate(transform=matrix(adir, MATRIX_ROTATE), time=rotation_time)
		//TODO: nice pleasant rotating motor noise

/obj/machinery/power/solar/proc/update_solar_exposure()
	if(obscured)
		sunfrac = 0
		return
	if(isnull(sun))	return
	var/p_angle = abs((360+adir)%360 - (360+sun.angle)%360)
	if(p_angle > 90)			// if facing more than 90deg from sun, zero output
		sunfrac = 0
		return

	sunfrac = cos(p_angle) ** 2

/obj/machinery/power/solar/process()
	//get dirtier
	if (map_currently_very_dusty && cleanliness && (prob(5)))
		cleanliness -= rand(2,4) //fuck your panels
		cleanliness = max (0, cleanliness) //absolutely can't go under 0 or it gets fucked up and you get negative power
		if (prob(2)) //and a rock or something hit it too
			health -= 1
			playsound(src.loc, "sound/impact_sounds/Glass_Hit_1.ogg", 50, 1, SOUND_RANGE_STANDARD)
			healthcheck()

	//i can't stop drinking oil
	process_lube()

	// -- OKAY SO HEAR ME OUT --
	// terrestrial solar would be terrible in this game because there's a flow to the rotation in space that doesn't happen on land, especially with moment-in-time day/night cycle on gehenna
	// (and that's fine, you just don't get solars when it's night time, HOWEVER during the day it's just that: day. point solars in one direction and you're done)
	// this means instead of star rotation making solars work good or bad or whatever, they get dirty in ways they really don't in space. and they get damaged by storms so you have to replace panels.
	// still work to make them happen, it's not set and forget, and it just seems to make sense. too me..
	// ----
	//future weather considerations
	//gehenna sandstorm? the following calcs assume it lasts about 5 minutes
	//at the end of it, a perfectly clean panel should be close to or at 0% clean
	//on average, they should withstand about 50% damage (-5 health)

	//currently sandstorm && (prob(25))
		//obscured = TRUE
		//cleanliness = max (0, cleanliness - rand(4,8)) //fuck your panels so much more
		//if (prob(3)) (small chance to damage also, but the damage is relatively big if it does happen)
			//src.health -= rand(1,2)
	//currently raining && (cleanliness < 75) && (prob(20))
		//weather/sun controller should also reduce sun output at that point
		//if (cleanliness < 75 && prob(20))
			//cleanliness += rand(1,2)
	// ^^^^ but that's all just my opinion
	//regular degular space map
	if (cleanliness && prob(2))
		cleanliness -= 1
		if (prob(20)) //some space junk hit it
			health -= 1
			playsound(src.loc, "sound/impact_sounds/Glass_Hit_1.ogg", 50, 1, SOUND_RANGE_STANDARD)
			healthcheck()
	if(HAS_FLAG(status, BROKEN))
		return

	//do some necessary checks to actually generate power and feed it into the wire
	if(!obscured)
		//full ideal efficiency, reduced by dirty panel, reduced by offangle, boosted or reduced by solar flare/storm strength modifier
		var/sgen = ((SOLARGENRATE * (cleanliness/100)) * sunfrac) * sunmult
		sgen *= PROCESSING_TIER_MULTI(src)
		add_avail(sgen)
		if(powernet && control && powernet == control.powernet)
			control.gen += sgen

		if(sgen > score_tracker.engine_power_hiscore)
			score_tracker.engine_power_hiscore = sgen
			score_tracker.engine_power_type = "Solar "

	//need to turn to face requested direction
	if(adir != ndir)
		var/old_adir = adir
		//range: 0% lube, 4 degrees per move. 100% lube, 12 degrees per move. Compensated for process loop changes.
		var/max_move = (0.5 + (lubrication/100)) * PROCESSING_TIER_MULTI(src) //was between 8,12 when these were on PROCESSING_32TH.
		//HOWEVER: I think it was still actually on 8th. It feels good again now.
		if(stuck)
			//make a report that you're doing nothing
			control.stuckpanels++
		//if new direction, and you've got enough oil, try to turn to it
		else if (lubrication > 50 || prob(lubrication*2)) //always turns above 50% lube, chance to fail to rotate if it's dry
		//TODO: add to desk or a maint panel: green light if good, yellow between 75-25, red light if below 25, red flashing light at 0
			adir = (360 + adir + clamp((180 - (540 - ndir + adir) % 360), -max_move, max_move)) % 360
			if (src.lubrication <= 33)
				playsound(src, pick('sound/machines/engine_grump1.ogg', 'sound/effects/creaking_metal1.ogg', 'sound/effects/creaking_metal2.ogg'), 30, 1, 4, 0.8)
				if(prob(1))
					stuck = TRUE
			else if (src.lubrication <= 66)
				playsound(src, pick('sound/effects/valve_creak.ogg'), 30, 1, 4, 0.4)
			//neglected long enough, run the risk of bad things
		else if (lubrication <= 10 && prob(10))
			stuck = TRUE
			control.stuckpanels++
		if (abs((180 + abs(adir - ndir))%360 - 180) > 60)
			//make a report that you're late/off-axis
			control.latepanels++
		if(adir != old_adir)
			if (lubrication && prob(5))
				src.lubrication-- //deplete lubricant on move
			use_power(power_usage * (1 + (100-lubrication)/100))
			updateicon()

		update_solar_exposure()

	if((obscured || cleanliness <= 20) && powernet && control && powernet == control.powernet)
		control.obspanels++

//consume oil to restore lubrication
//only consumes lubrication. for now fouling is handled by "the tank is full of shit that doesn't get removed and doesn't lubricate"
//requires screwdriver to drain oil. grife-able but nevertheless resolveable.
/obj/machinery/power/solar/proc/process_lube()
	if (stuck && lubrication >= 30)
		lubrication -= 5
		stuck = FALSE

	//check the tank and the works
	if (!src.reagents || !src.reagents.total_volume || lubrication >= 100)
		return

	var/lube_needed = (100 - lubrication)
	for(var/lube in reagents.reagent_list)
		var/datum/reagent/current_lube = reagents.reagent_list[lube]
		var/effectiveness = 1
		switch (current_lube.id)
			if ("superlube")
				effectiveness = 15
			if ("lube")
				effectiveness = 12.5
			if ("oil")
				effectiveness = 10
			else
				continue
		//time to delete reagents in exchange for solars spinning faster
		if(current_lube.volume > lube_needed/effectiveness)
			lubrication += lube_needed //should be at 100 now
			src.reagents.remove_reagent(current_lube, lube_needed/effectiveness)
			lube_needed = 0
			break
		if(current_lube.volume <= lube_needed/effectiveness)
			lubrication += current_lube.volume*effectiveness
			lube_needed -= current_lube.volume*effectiveness
			src.reagents.del_reagent(current_lube)
		if(lube_needed <= 0 || lubrication >= 100)
			lubrication = 100 //clamp it just in case
			return

/obj/machinery/power/solar/proc/broken()
	unlink_control()
	ADD_FLAG(status, BROKEN)
	updateicon()
	UnsubscribeProcess() // Broken solar panels need not process, supposedly there's no way to repair them?
	return

/obj/machinery/power/solar/meteorhit()
	if(!HAS_FLAG(status, BROKEN))
		broken()
	else
		qdel(src)

/obj/machinery/power/solar/ex_act(severity)
	switch(severity)
		if(OLD_EX_SEVERITY_1)
			qdel(src)
			if(prob(15))
				var/obj/item/raw_material/shard/glass/G = new()
				G.set_loc(src.loc)
			return
		if(OLD_EX_SEVERITY_2)
			if (prob(50))
				broken()
		if(OLD_EX_SEVERITY_3)
			if (prob(25))
				broken()
	return

/obj/machinery/power/solar/blob_act(var/power)
	if(prob(power * 2.5))
		broken()
		src.set_density(0)

/obj/machinery/power/solar/disposing()
	if(control)
		control.unlink_panel(src)
	..()

/////////////////////////////////////////////////// Solar control computer /////////////////////////////////////////

/obj/machinery/power/solar_control
	name = "solar panel control"
	desc = "A controller for solar panel arrays."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "solar"
	anchored = ANCHORED
	density = 1
	directwired = 1
	//var/obj/overlay/solcon
	var/id = 1
	var/cdir = 0			// Controller angle sent to panels, updated either by solar tracker (when tracking is auto), by a fixed rate/direction process, or solely by manual input
	var/sdir = 0			// Tracker-reported sun angle
	var/maxgen = 0			// Maximum ideal capacity of all solar panels (not counting solar flares)
	var/gen = 0				// Tally of collected power during current process cycle
	var/lastgen = 0			// Previous process cycle's production of power
	var/track = 2			// 0= off  1=timed  2=auto (tracker)
	var/trackrate = 600		// Timed Tracking: 300-900 seconds
	var/trackdir = 1		// Timed Tracking: 0 =CCW, 1=CW
	var/nexttime = 0		// Next Process time
	var/list/currentpanels = list()	// List of our currently linked panels
	var/obspanels = 0		// How many panels produced no power because they're blocked from the sun
	var/latepanels = 0		// Panels more than 60 degrees off
	var/stuckpanels = 0		// Panels with less than 10% lubrication
	var/lastobs = 0			// Previous process cycle's blocked panels
	var/lastlate = 0		// Previous process cycle's late panels
	var/laststuck = 0		// Previous process cycle's stuck panels

	north
		id = "north"
	south
		id = "south"
	alt
		id = "alt"
	east
		id = "east"
	west
		id = "west"
	small_backup1
		id = "small_backup1"
	small_backup2
		id = "small_backup2"
	small_backup3
		id = "small_backup3"
	small_backup4
		id = "small_backup4"
	diner
		id = "diner"

/obj/machinery/power/solar_control/get_desc(dist)
	. = ..()
	if(HAS_FLAG(status, (NOPOWER|BROKEN)))
		return
	else
		. += "<br> Generated power : [round(lastgen)] W"


/obj/machinery/power/solar_control/New()
	..()
	SPAWN_DBG(3 SECONDS)
		link_panels()

/obj/machinery/power/solar_control/proc/updateicon()
	if(HAS_FLAG(status, BROKEN) && icon_state != "solarb")
		icon_state = "solarb"
		return

	if(HAS_FLAG(status, NOPOWER) && icon_state != "solar0")
		icon_state = "solar0"
		return

	if(icon_state != "solar")
		icon_state = "solar"

/obj/machinery/power/solar_control/attack_ai(mob/user)
	add_fingerprint(user)

	if(HAS_FLAG(status, (NOPOWER|BROKEN))) return

	interacted(user)

/obj/machinery/power/solar_control/attack_hand(mob/user)
	add_fingerprint(user)

	if(HAS_FLAG(status, (NOPOWER|BROKEN))) return

	interacted(user)

/obj/machinery/power/solar_control/process()
	lastgen = gen
	lastobs = obspanels
	lastlate = latepanels
	laststuck = stuckpanels
	gen = 0
	obspanels = 0
	latepanels = 0
	stuckpanels = 0


	if(HAS_FLAG(status, (NOPOWER|BROKEN)))
		return

	use_power(250)

	//manual tracking process
	if(track==1 && nexttime < world.timeofday && trackrate)
		nexttime = world.timeofday + 3600/abs(trackrate)
		cdir = (cdir+trackrate/abs(trackrate)+360)%360

		set_panels(cdir)
		updateicon()

	src.updateDialog()

//steps toward making more fuckwithable and networked solar panels

//set self as controller for id-shared panels (and tracker), initiated by controller
//intended for repair/replacement of panels or controller
//remove references on solar controller to panel (do not touch references on panel)
/obj/machinery/power/solar_control/proc/link_panels()
	//start internal tallies from scratch
	currentpanels = list()
	clear_stats()
	if(!powernet) return
	for(var/obj/machinery/power/solar/S in powernet.nodes)
		if(S.id != id) continue //only match our hard-coded id
		S.unlink_control(src) //resetting it for good measure
		cdir = S.adir //we'll just set our console to the direction of the last one i guess (99% of the time next process will pull the sun dir from tracker)
		updateicon()
		S.link_control(src)
		currentpanels += S
	for(var/obj/machinery/power/tracker/T in powernet.nodes)
		if(T.id != id) continue //only match our hard-coded id
		T.link_control(src)
	capcalc()

//remove self as linked controller for id-shared panels, initiated by controller
//intended for resets and troubleshooting
//add references on solar controller to panel (and tracker) (do not touch references on panel)
/obj/machinery/power/solar_control/proc/unlink_panels()
	//wipe internal tallies
	currentpanels = list()
	clear_stats()
	sdir = 0
	//attempt to clear out linked information
	for(var/obj/machinery/power/solar/S in currentpanels)
		S.control = null
		S.controldist = 1
		S.ndir = SOUTH //reset to south, stock direction
		S.unlink_control()
	for(var/obj/machinery/power/tracker/T in powernet.nodes)
		if(T.id != id) continue //only match our hard-coded id
		T.control = null

//remove single panel from list, initiated by panel
//intended for deletions and damage
/obj/machinery/power/solar_control/proc/unlink_panel(var/obj/machinery/power/solar/SP)
	SP.unlink_control()
	if (SP in currentpanels)
		currentpanels -= SP
	capcalc()

//just redo this thingy right here
/obj/machinery/power/solar_control/proc/capcalc()
	src.maxgen = (SOLARGENRATE / MACHINE_PROCS_PER_SEC) * 3.2 * currentpanels.len

/obj/machinery/power/solar_control/proc/clear_stats()
	lastobs = 0
	lastlate = 0
	laststuck = 0
	obspanels = 0
	latepanels = 0
	stuckpanels = 0

// called by solar tracker when sun position changes
/obj/machinery/power/solar_control/proc/tracker_update(var/angle)
	if(HAS_FLAG(status, (NOPOWER|BROKEN)))
		return
	sdir = angle
	if(track == 2)
		cdir = angle
		set_panels(cdir)
		updateicon()

	src.updateDialog()

/obj/machinery/power/solar_control/proc/interacted(mob/user)
	if(HAS_FLAG(status, (NOPOWER|BROKEN))) return
	if ( (get_dist(src, user) > 1 ))
		if (!issilicon(user))
			src.remove_dialog(user)
			user.Browse(null, "window=solcon")
			return

	add_fingerprint(user)
	src.add_dialog(user)

	var/t = "<TT><B>Solar Generator Control</B><HR><PRE>"
	t += "Generated power : [round(lastgen)] W<br>Maximum Array Capacity : [round(maxgen)] W<BR><BR>"
	t += "<B>Orientation</B>: [rate_control(src,"cdir","[cdir]&deg",1,15)] ([angle2text(cdir)])<BR><BR>"
	t += "<B>Total Panels</B>: [currentpanels.len] | <B>Occluded Panels</B>: [lastobs]<BR>"
	t += "<B>Off-Axis Panels</B>: [lastlate] | <B>Stuck Panels</B>: [laststuck]<BR><BR><BR>"

	t += "<BR><HR><BR><BR>"

	t += "Tracking: "
	switch(track)
		if(0)
			t += "<B>Off</B> <A href='byond://?src=\ref[src];track=1'>Timed</A> <A href='byond://?src=\ref[src];track=2'>Auto</A><BR>"
		if(1)
			t += "<A href='byond://?src=\ref[src];track=0'>Off</A> <B>Timed</B> <A href='byond://?src=\ref[src];track=2'>Auto</A><BR>"
		if(2)
			t += "<A href='byond://?src=\ref[src];track=0'>Off</A> <A href='byond://?src=\ref[src];track=1'>Timed</A> <B>Auto</B><BR>"


	t += "Tracker Reported Sun Angle: [sdir ? "[sdir] ([angle2text(sdir)])" : "404 (error)"]<BR><BR>"
	t += "Tracking Rate: [rate_control(src,"tdir","[trackrate] deg/h ([trackrate<0 ? "CCW" : "CW"])",5,30,180)]<BR><BR>"
	t += "Panel Array: <A href='byond://?src=\ref[src];relink=1'>Relink</A> <A href='byond://?src=\ref[src];unlink=1'>Unlink</A><br><br>"
	t += "<A href='byond://?src=\ref[src];close=1'>Close</A></TT>"
	user.Browse(t, "window=solcon")
	onclose(user, "solcon")
	return

/obj/machinery/power/solar_control/Topic(href, href_list)
	if(..())
		usr.Browse(null, "window=solcon")
		src.remove_dialog(usr)
		return
	if(href_list["close"] )
		usr.Browse(null, "window=solcon")
		src.remove_dialog(usr)
		return

	if(href_list["dir"])
		cdir = text2num(href_list["dir"])
		SPAWN_DBG(1 DECI SECOND)
			set_panels(cdir)
			updateicon()

	if(href_list["rate control"])
		if(href_list["cdir"])
			src.cdir = clamp((360+src.cdir+text2num(href_list["cdir"]))%360, 0, 359)
			SPAWN_DBG(1 DECI SECOND)
				set_panels(cdir)
				updateicon()
		if(href_list["tdir"])
			src.trackrate = clamp(src.trackrate+text2num(href_list["tdir"]), -7200,7200)
			if(src.trackrate) nexttime = world.timeofday + 3600/abs(trackrate)

	if(href_list["track"])
		if(src.trackrate) nexttime = world.timeofday + 3600/abs(trackrate)
		track = text2num(href_list["track"])
		if(track == 2)
			var/obj/machinery/power/tracker/T = locate() in machine_registry[MACHINES_POWER]
			if(T)
				cdir = T.sun_angle

	if(href_list["relink"])
		link_panels()

	if(href_list["unlink"])
		unlink_panels()

	src.updateUsrDialog()
	return

//set panels to a specific direction, called by tracker/timed updates, or by the player using the browser
/obj/machinery/power/solar_control/proc/set_panels(var/cdir)
	if(!powernet) return
	for(var/obj/machinery/power/solar/S in src.currentpanels)
		S.ndir = cdir

/obj/machinery/power/solar_control/power_change()
	if(powered())
		REMOVE_FLAG(status, NOPOWER)
		updateicon()
	else
		SPAWN_DBG(rand(0, 15))
			unlink_panels()
			ADD_FLAG(status, NOPOWER)
			updateicon()

/obj/machinery/power/solar_control/proc/broken()
	//detach
	unlink_panels()
	ADD_FLAG(status, BROKEN)
	updateicon()

/obj/machinery/power/solar_control/meteorhit()
	broken()
	return

/obj/machinery/power/solar_control/ex_act(severity)
	switch(severity)
		if(OLD_EX_SEVERITY_1)
			qdel(src)
			return
		if(OLD_EX_SEVERITY_2)
			if (prob(50))
				broken()
		if(OLD_EX_SEVERITY_3)
			if (prob(25))
				broken()
	return

/obj/machinery/power/solar_control/blob_act(var/power)
	if (prob(power * 2.5))
		broken()
		src.set_density(0)

/obj/machinery/power/solar_control/disposing()
	unlink_panels()
	..()

// solar panels which ignore occlusion
/obj/machinery/power/solar/owl_cheat
	id = "owl"
	lubrication = 30 //old, abandoned
	cleanliness = 75 //approximately same power as before

	update_solar_exposure()
		if(isnull(sun))	return
		var/p_angle = abs((360+adir)%360 - (360+sun.angle)%360)
		if(p_angle > 90)			// if facing more than 90deg from sun, zero output
			sunfrac = 0
			return
		sunfrac = cos(p_angle) ** 2

	process()
		if(HAS_FLAG(status, BROKEN))
			return

		var/sgen = SOLARGENRATE * sunfrac
		add_avail(sgen)
		if(powernet && control)
			if(control in powernet.nodes) //this line right here...
				control.gen += sgen

		if(adir != ndir)
			SPAWN_DBG(10+rand(0,15))
				var/old_adir = adir
				var/max_move = rand(0.25, 0.375) * PROCESSING_TIER_MULTI(src)
				adir = (360 + adir + clamp((180 - (540 - ndir + adir) % 360), -max_move, max_move)) % 360
				if(adir != old_adir)
					updateicon()
				update_solar_exposure()

#undef SOLARGENRATE
