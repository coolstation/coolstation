/obj/machinery/gibber
	name = "gibber"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/obj/foodNdrink/kitchen.dmi'
	icon_state = "grinder_mapping" //has directional arrows on it
	density = 1
	anchored = ANCHORED
	var/operating = 0 //Is it on?
	var/dirty = 0 // Does it need cleaning?
	var/gibtime = 40 // Time from starting until meat appears
	var/mob/occupant // Mob who has been put inside
	var/output_direction = "W" // Spray gibs and meat in that direction.
	mats = 15
	deconstruct_flags =  DECON_WRENCH | DECON_WELDER

	//2026-1-20 - superfluous now that you map them directionally to set output dir, but not removed from all the maps
	output_north
		dir = NORTH
	output_east
		dir = EAST
	output_west
		dir = WEST
	output_south
		dir = SOUTH

/obj/machinery/gibber/New()
	..()
	output_direction = src.dir
	icon_state = "grinder"
	UnsubscribeProcess()

/obj/machinery/gibber/custom_suicide = 1
/obj/machinery/gibber/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	if (user.client)
		user.visible_message("<span class='alert'><b>[user] climbs into the gibber and switches it on.</b></span>")
		user.set_loc(src)
		src.occupant = user
		src.startgibbing(user)
		return 1

/obj/machinery/gibber/relaymove(mob/user as mob)
	src.go_out()
	return

/obj/machinery/gibber/attack_hand(mob/user as mob)
	if(operating)
		boutput(user, "<span class='alert'>It's locked and running</span>")
		return
	else
		src.startgibbing(user)

/obj/machinery/gibber/attackby(obj/item/grab/G as obj, mob/user as mob)
	if(src.occupant)
		boutput(user, "<span class='alert'>The gibber is full, empty it first!</span>")
		return
	if (!(istype(G, /obj/item/grab)) || !ismob(G.affecting))
		boutput(user, "<span class='alert'>This item is not suitable for the gibber!</span>")
		return
	user.visible_message("<span class='alert'>[user] starts to put [G.affecting] into the gibber!</span>")
	src.add_fingerprint(user)
	sleep(3 SECONDS)
	if(G?.affecting)
		user.visible_message("<span class='alert'>[user] stuffs [G.affecting] into the gibber!</span>")
		logTheThing("combat", user, G.affecting, "forced [constructTarget(G.affecting,"combat")] into a gibber at [log_loc(src)].")
		message_admins("[key_name(user)] forced [key_name(G.affecting, 1)] ([isdead(G.affecting) ? "dead" : "alive"]) into a gibber at [log_loc(src)].")
		var/mob/M = G.affecting
		M.set_loc(src)
		src.occupant = M
		qdel(G)

/obj/machinery/gibber/mouse_drop(over_object, src_location, over_location)
	..()
	if (IN_RANGE(src, over_object, 1))
		src.output_direction = get_dir(src, over_object)
		boutput(usr, "[src] now aims [dir2text(output_direction)].")

/obj/machinery/gibber/verb/eject()
	set src in oview(1)
	set category = "Local"

	if (!isalive(usr)) return
	if (src.operating) return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/gibber/proc/go_out()
	if (!src.occupant)
		return
	for(var/obj/O in src)
		O.set_loc(src.loc)
	src.occupant.set_loc(src.loc)
	src.occupant = null
	return


/obj/machinery/gibber/proc/startgibbing(mob/user as mob)
	if(src.operating)
		return
	if(!src.occupant)
		for(var/mob/M in hearers(src, null))
			M.show_message("<span class='alert'>You hear a loud metallic grinding sound.</span>", 1)
		return
	else
		var/bdna = null // For forensics (Convair880).
		var/btype = null

		for(var/mob/M in hearers(src, null))
			M.show_message("<span class='alert'>You hear a loud squelchy grinding sound.</span>", 1)
		src.operating = 1
		flick("grinder-on", src)

		var/sourcename = src.occupant.real_name
		var/sourcejob
		if (src.occupant.mind && src.occupant.mind.assigned_role)
			sourcejob = src.occupant.mind.assigned_role
		else if (src.occupant.ghost && src.occupant.ghost.mind && src.occupant.ghost.mind.assigned_role)
			sourcejob = src.occupant.ghost.mind.assigned_role
		else
			sourcejob = "Stowaway"

		var/well_done = (src.occupant.get_burn_damage() > WELL_DONE_THRESHOLD)
		var/decomp = 0
		if(ishuman(src.occupant))
			decomp = src.occupant:decomp_stage

			bdna = src.occupant.bioHolder.Uid // Ditto (Convair880).
			btype = src.occupant.bioHolder.bloodType

		if(user != src.occupant) //for suiciding with gibber
			logTheThing("combat", user, src.occupant, "grinds [constructTarget(src.occupant,"combat")] in a gibber at [log_loc(src)].")
			message_admins("[key_name(src.occupant, 1)] is ground up in a gibber by [key_name(user)] at [log_loc(src)].")
		src.occupant.death(1)

		src.occupant.remove()
		src.occupant = null

		var/product_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat
		if (decomp)
			//2026-1-20 - light decomp gives bone instead of more gibs, and I guess you get 3 molten things now
			//but that's just so it can fit into this loop. I don't think anyone really cares about keeping strict equity.
			if (decomp > 2)
				product_type = /obj/decal/cleanable/molten_item
			else
				product_type = /obj/item/material_piece/bone
		else if (well_done)
			product_type = /obj/item/reagent_containers/food/snacks/steak_h
		var/obj/item/product
		var/obj/decal/cleanable/tracked_reagents/blood/gibs/gibbes = null // For forensics (Convair880).
		src.dirty += 1 // at 1 the gibber gets a blood overlay, and I guess we're just gonna keep incrementing to not stack em?
		SPAWN_DBG(src.gibtime)
			playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
			var/blocked = FALSE
			var/cur_T = get_turf(src)
			for(var/i in 1 to 3)
				if (!blocked) //Does it really matter to avoid canpass loops if we're only ever doing 3 total? Probably not, but here we are anyway.
					var/turf/new_T = get_step(cur_T, output_direction)
					if (!new_T.canpass())
						blocked = TRUE
					else
						cur_T = new_T
					//slightly strange spot to put this, but it's to make sure that gibs appear on the last unblocked turf too.
					if (decomp <= 2)
						gibbes = make_cleanable(/obj/decal/cleanable/tracked_reagents/blood/gibs,cur_T)
						if (bdna && btype)
							gibbes.blood_DNA = bdna
							gibbes.blood_type = btype

				if (product_type)
					product = new product_type (cur_T)
					//woop woop names and stuff
					switch(product_type)
						if (/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat)
							var/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/meat = product
							meat.name = sourcename + meat.name
							meat.subjectname = sourcename
							meat.subjectjob = sourcejob
						if (/obj/item/reagent_containers/food/snacks/steak_h)
							var/obj/item/reagent_containers/food/snacks/steak_h/steak = product
							steak.name = sourcename + steak.name
							steak.hname = sourcename
							steak.job = sourcejob
							steak.quality = rand() //hmmmmmmmmmmmm

			operating = FALSE
			if (src.dirty == 1)
				src.overlays += image('icons/obj/foodNdrink/kitchen.dmi', "grbloody")
