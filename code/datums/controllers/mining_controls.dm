var/datum/mining_controller/mining_controls

var/list/asteroid_blocked_turfs = list()

/datum/mining_controller
	var/mining_z = 4
	var/mining_z_asteroids_max = 0
	//Every child of datum/ore except for the event parent
	var/list/ore_types_all = list()
	//Regular
	var/list/ore_types_common = list()
	var/list/ore_types_uncommon = list()
	var/list/ore_types_rare = list()
	//Things not randomly generated in the magnet, but permissible in Z-level generation
	var/list/ore_types_common_spicy = list() //empty atm
	var/list/ore_types_uncommon_spicy = list() //empty atm
	var/list/ore_types_rare_spicy = list() //erebite, miraclium
	//Every child of datum/ore/event
	var/list/events = list()
	// magnet vars
	var/turf/magnetic_center = null
	var/area/mining/magnet/magnet_area = null
	var/list/magnet_shields = list()
	var/max_magnet_spawn_size = 7
	var/min_magnet_spawn_size = 4
	var/list/mining_encounters_all = list()
	var/list/mining_encounters_common = list()
	var/list/mining_encounters_uncommon = list()
	var/list/mining_encounters_rare = list()
	var/list/small_encounters = list()
	var/list/mining_encounters_selectable = list()

	//Z level generation stats
	var/list/datum/mining_level_stats = list()

	New()
		..()
		for (var/X in childrentypesof(/datum/ore) - /datum/ore/event)
			ore_types_all += new X

		for (var/X in childrentypesof(/datum/mining_encounter))
			var/datum/mining_encounter/MC = new X
			mining_encounters_common += MC
			mining_encounters_all += MC

		for (var/datum/ore/O in src.ore_types_all)
			O.set_up() //movin' up here above so none are skipped, though I don't think any ores so far have a use for the call here, at the moment
			if (O.no_pick == 2)
				continue

			if (istype(O, /datum/ore/event/))
				events += O
				continue
			switch(O.rarity_tier)
				if (1) //common
					if (O.no_pick)
						ore_types_common_spicy += O
					else
						ore_types_common += O
				if (2) //uncommon
					if (O.no_pick)
						ore_types_uncommon_spicy += O
					else
						ore_types_uncommon += O
				if (3) //rare
					if (O.no_pick)
						ore_types_rare_spicy += O
					else
						ore_types_rare += O


		for (var/datum/mining_encounter/MC in mining_encounters_common)
			if (MC.no_pick)
				mining_encounters_common -= MC
				continue

			if (MC.rarity_tier == 3)
				mining_encounters_rare += MC
				mining_encounters_common -= MC
			else if (MC.rarity_tier == 2)
				mining_encounters_uncommon += MC
				mining_encounters_common -= MC
			else if (MC.rarity_tier == -1)
				small_encounters += MC
				mining_encounters_common -= MC
			else if (MC.rarity_tier != 1)
				mining_encounters_common -= MC
				qdel(MC)

		//pair automagnet landmarks
		var/list/sorted_tags = list()
		SPAWN_DBG(1 SECOND) //UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUGH
			for(var/turf/T in landmarks["automagnet"])
				var/tag = landmarks["automagnet"][T]
				if (tag in sorted_tags)
					continue
				for(var/turf/OT in landmarks["automagnet"])
					if ((T != OT) && (landmarks["automagnet"][OT] == tag))
						//from here on out is copied from the magnetizer
						var/corner_turf
						var/obj/machinery/mining_magnet/construction/a_magnet = locate() in T
						if (!a_magnet)
							corner_turf = T
							a_magnet = locate() in OT
							if (!a_magnet)
								CRASH("automagnet landmark pair is missing mineral magnet.")
						else
							corner_turf = OT

						var/obj/magnet_target_marker/M = new a_magnet.marker_type(corner_turf)
						if (!M.construct())
							qdel(M)
						else
							a_magnet.target = M
				sorted_tags += tag


	proc/setup_mining_landmarks()
		for(var/turf/T in landmarks[LANDMARK_MAGNET_CENTER])
			magnetic_center = T
			magnet_area = get_area(T)
			break

		for(var/turf/T in landmarks[LANDMARK_MAGNET_SHIELD])
			var/obj/forcefield/mining/S = new /obj/forcefield/mining(T)
			magnet_shields += S

	proc/spawn_mining_z_asteroids(var/amt, var/zlev)
		SPAWN_DBG(0)
			var/the_mining_z = zlev ? zlev : src.mining_z
			var/turf/T
			var/spawn_amount = amt ? amt : src.mining_z_asteroids_max
			for (var/i=spawn_amount, i>0, i--)
				LAGCHECK(LAG_LOW)
				T = locate(rand(8,(world.maxy - 8)),rand(8,(world.maxy - 8)),the_mining_z)
				if (istype(T))
					T.GenerateAsteroid(rand(4,15))
			message_admins("Asteroid generation on z[the_mining_z] complete: ")

	proc/get_ore_from_string(var/string)
		if (!istext(string))
			return
		for (var/datum/ore/O in ore_types_all)
			if (O.name == string)
				return O
		return null

	proc/get_ore_from_path(var/path)
		if (!ispath(path))
			return
		for (var/datum/ore/O in ore_types_all)
			if (O.type == path)
				return O
		return null

	proc/get_encounter_by_name(var/enc_name = null)
		if(enc_name)
			for(var/datum/mining_encounter/A in mining_encounters_all)
				if(A.name == enc_name)
					return A
		return null

	proc/add_selectable_encounter(var/datum/mining_encounter/A)
		if(A)
			var/number = "[(mining_encounters_selectable.len + 1)]"
			mining_encounters_selectable += number
			mining_encounters_selectable[number] = A
		return

	proc/remove_selectable_encounter(var/number_id)
		if(mining_encounters_selectable.Find(number_id))
			//var/datum/mining_encounter/A = mining_encounters_selectable[number_id]
			mining_encounters_selectable.Remove(number_id)

			var/list/rebuiltList = list()
			var/count = 1

			for(var/X in mining_encounters_selectable)
				rebuiltList.Add("[count]")
				rebuiltList["[count]"] = mining_encounters_selectable[X]
				count++

			mining_encounters_selectable = rebuiltList

		return

	proc/select_encounter(var/rarity_mod)
		if (!isnum(rarity_mod))
			rarity_mod = 0
		var/chosen = RarityClassRoll(100,rarity_mod,list(95,70))

		var/list/category = mining_controls.mining_encounters_common
		switch(chosen)
			if (2)
				category = mining_controls.mining_encounters_uncommon
			if (3)
				category = mining_controls.mining_encounters_rare

		if (category.len < 1)
			category = mining_controls.mining_encounters_common

		return pick(category)

	proc/select_small_encounter(var/rarity_mod)
		return pick(small_encounters)

/datum/mining_controller/proc/show_stats()
	var/dat = {"<html>
<head>
	<title>Mining Generation Statistics</title>
	<style>
		table, td, th {
			border-collapse: collapse;
			border: 1px solid #FF6961;
			font-size: 100%;
		}
		th { background: #FF6961; }
		td { background: #FFFFFF; }
		td, th {
			margin:	0;
			padding: 0.25em 0.5em;
		}
	</style>
</head>
<body style='background-color:#EEEEEE'>

		"}

	if (!length(src.mining_level_stats))
		dat += "<b>No mining level stats found, are you by any chance bypassing the generation with one of the compile speed-up options?</b>"
	else
		for (var/datum/mining_level_stats/some_stats as anything in src.mining_level_stats)
			//ORE TABLE
			dat += "<b>Z-level: [some_stats.z_level] | Generator: [some_stats.generator]<br>"
			dat += "Total Ores: [some_stats.total_generated_ores] | Total Events: [some_stats.total_generated_events] | Total Event Calls: [some_stats.total_event_calls]</b><br>"
			dat += {"<p><table>
				<tr>
					<th>Ore Name</th>
					<th>Veins</th>
					<th>No. Generated</th>
					<th>No. Misses</th>
					<th>% Success</th>
					<th>Avg Per Vein</th>
					<th>% Of Generated</th>
				</tr>"}
			for (var/an_ore in some_stats.total_ore_ids)
				//var/datum/ore/the_ore_datum = src.get_ore_from_string(an_ore) //For vein size
				// <td>[the_ore_datum.tiles_per_rock_min]-[the_ore_datum.tiles_per_rock_max]</td>
				dat +=	{"<tr>
					<td><b>[an_ore]</b></td>
					<td>[some_stats.veins[an_ore]]</td>
					<td>[some_stats.ores[an_ore]]</td>
					<td>[!isnull(some_stats.misses[an_ore]) ? some_stats.misses[an_ore] : "-"]</td>
					<td>[some_stats.ore_success_percentages[an_ore]]%</td>
					<td>[some_stats.ore_averages_per_vein[an_ore]]</td>

					<td>[some_stats.ore_total_percentages[an_ore]]%</td>
				</tr>"}
			dat += "</table></p><br><p>"
			//EVENT TABLE
			dat += {"<table>
				<tr>
					<th>Event Name</th>
					<th>Calls</th>
					<th>No. Generated</th>
					<th>No. Misses</th>
					<th>% Success</th>
					<th>% of calls</th>
					<th>% Of Generated</th>
				</tr>"}
			for (var/an_event in some_stats.total_event_ids)
				//var/datum/ore/the_ore_datum = src.get_ore_from_string(an_ore) //fun fact events are weird ores, we want the  distribution min/max this time
				dat +=	{"<tr>
					<td><b>[an_event]</b></td>
					<td>[some_stats.event_calls[an_event]]</td>
					<td>[some_stats.events[an_event]]</td>
					<td>[!isnull(some_stats.event_misses[an_event]) ? some_stats.event_misses[an_event] : "-"]</td>
					<td>[some_stats.event_success_percentages[an_event]]%</td>
					<td>[some_stats.event_call_percentages[an_event]]%</td>
					<td>[some_stats.event_total_percentages[an_event]]%</td>
				</tr>"}
			dat += "</table></p><br><br>"


	dat += "</small></body></html>"

	usr.Browse(dat,"window=miningstats;size=800x600")




/area/mining/magnet
	name = "Magnet Area"
	icon_state = "purple"
	force_fullbright = 1
	requires_power = 0
	luminosity = 1

	proc/check_for_unacceptable_content()
		for (var/mob/living/L in src.contents)
			return 1
		for (var/obj/machinery/vehicle in src.contents)
			return 1
		return 0

/obj/forcefield/mining
	name = "magnetic forcefield"
	desc = "A powerful field used by the mining magnet to attract minerals."
	icon = 'icons/misc/old_or_unused.dmi'
	icon_state = "noise6"
	color = "#BF12DE"
	alpha = 175
	opacity = 0
	density = 0
	invisibility = 101
	anchored = ANCHORED
	flags = FPRINT | MINERAL_MAGNET_SAFE

/// *** MISC *** ///

/proc/getOreQualityName(var/quality)
	switch(quality)
		if(-INFINITY to -101)
			return "worthless"
		if(-100 to -51)
			return "terrible"
		if(-50 to -41)
			return "awful"
		if(-40 to -31)
			return "bad"
		if(-30 to -21)
			return "low-grade"
		if(-20 to -11)
			return "poor"
		if(-10 to -1)
			return "impure"
		if(0)
			return ""
		if(1 to 10)
			return "decent"
		if(11 to 20)
			return "fine"
		if(21 to 30)
			return "good"
		if(31 to 40)
			return "high-quality"
		if(41 to 50)
			return "excellent"
		if(51 to 60)
			return "fantastic"
		if(61 to 70)
			return "amazing"
		if(71 to 80)
			return "incredible"
		if(81 to 90)
			return "supreme"
		if(91 to 100)
			return "pure"
		if(101 to INFINITY)
			return "perfect"
		else
			return "strange"

/proc/getGemQualityName(var/quality)
	switch(quality)
		if(-INFINITY to -101)
			return "worthless"
		if(-100 to -51)
			return "awful"
		if(-50 to -41)
			return "shattered"
		if(-40 to -31)
			return "broken"
		if(-30 to -21)
			return "cracked"
		if(-20 to -11)
			return "flawed"
		if(-10 to -1)
			return "dull"
		if(0)
			return ""
		if(1 to 10)
			return "pretty"
		if(11 to 20)
			return "shiny"
		if(21 to 30)
			return "gleaming"
		if(31 to 40)
			return "sparkling"
		if(41 to 50)
			return "glittering"
		if(51 to 60)
			return "beautiful"
		if(61 to 70)
			return "lustrous"
		if(71 to 80)
			return "iridescent"
		if(81 to 90)
			return "radiant"
		if(91 to 100)
			return "pristine"
		if(101 to INFINITY)
			return "perfect"
		else
			return "strange"
