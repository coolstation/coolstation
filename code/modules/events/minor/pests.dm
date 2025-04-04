/datum/random_event/minor/pests
	name = "Pests"

	event_effect()
		..()
		var/pestlandmark = pick_landmark(LANDMARK_PESTSTART)
		if(!pestlandmark)
			return
		var/masterspawnamount = rand(4,12)
		var/spawnamount = masterspawnamount
		var/type = rand(1,12)
		switch (type)
			if (1)
				while (spawnamount > 0)
					if(prob(50))
						new /obj/critter/roach(pestlandmark)
					else
						new /obj/critter/roach/classic(pestlandmark)
					spawnamount -= 1
					LAGCHECK(LAG_LOW)
			if (2)
				while (spawnamount > 0)
					new /obj/critter/mouse(pestlandmark)
					spawnamount -= 1
					LAGCHECK(LAG_LOW)
			if (5)
				while (spawnamount > 0)
					new /obj/critter/spacebee(pestlandmark)
					spawnamount -= 1
					LAGCHECK(LAG_LOW)
		//pestlandmark.visible_message("A group of [type] emerges from their hidey-hole")
