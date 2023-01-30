// This file contains individual elevator definitions.
// also areas and stuff for each instance.

/*
_________ _______  _______  _        _______ __________________   _______ _________ _______  _______  _______
\__   __/(  ____ )(  ___  )( (    /|(  ____ \\__   __/\__   __/  (  ____ \\__   __/(  ___  )(  ____ )(  ____ \
   ) (   | (    )|| (   ) ||  \  ( || (    \/   ) (      ) (     | (    \/   ) (   | (   ) || (    )|| (    \/
   | |   | (____)|| (___) ||   \ | || (_____    | |      | |     | (_____    | |   | |   | || (____)|| (_____
   | |   |     __)|  ___  || (\ \) |(_____  )   | |      | |     (_____  )   | |   | |   | ||  _____)(_____  )
   | |   | (\ (   | (   ) || | \   |      ) |   | |      | |           ) |   | |   | |   | || (            ) |
   | |   | ) \ \__| )   ( || )  \  |/\____) |___) (___   | |     /\____) |   | |   | (___) || )      /\____) |
   )_(   |/   \__/|/     \||/    )_)\_______)\_______/   )_(     \_______)   )_(   (_______)|/       \_______) */


/datum/transit_stop/elevator/qm_top
	stop_id 	= "qm_top"
	name		= "Quartermaster's Upper Level"
	target_area = /area/transit_vehicle/elevator/qm_top
	current_occupant = "qm_elevator"

/datum/transit_stop/elevator/qm_bot
	stop_id 	= "qm_bot"
	name		= "Quartermaster's Lower Level"
	target_area = /area/transit_vehicle/elevator/qm_bot

/datum/transit_stop/elevator/med_top
	stop_id 	= "med_top"
	name		= "Hospital Upper Level"
	target_area = /area/transit_vehicle/elevator/med_top
	current_occupant = "med_elevator"

/datum/transit_stop/elevator/med_bot
	stop_id 	= "med_bot"
	name		= "Hospital Lower Level"
	target_area = /area/transit_vehicle/elevator/med_bot

/datum/transit_stop/elevator/eng_top
	stop_id 	= "eng_top"
	name		= "Engineering Upper Level"
	target_area = /area/transit_vehicle/elevator/eng_top
	current_occupant = "eng_elevator"

/datum/transit_stop/elevator/eng_bot
	stop_id 	= "eng_bot"
	name		= "Engineering Lower Level"
	target_area = /area/transit_vehicle/elevator/eng_bot

/datum/transit_stop/elevator/com_top
	stop_id 	= "com_top"
	name		= "Command Upper Level"
	target_area = /area/transit_vehicle/elevator/com_top
	current_occupant = "com_elevator"

/datum/transit_stop/elevator/com_bot
	stop_id 	= "com_bot"
	name		= "Command Lower Level"
	target_area = /area/transit_vehicle/elevator/com_bot

/datum/transit_stop/elevator/sec_top
	stop_id 	= "sec_top"
	name		= "Security Upper Level"
	target_area = /area/transit_vehicle/elevator/sec_top
	current_occupant = "sec_elevator"

/datum/transit_stop/elevator/sec_bot
	stop_id 	= "sec_bot"
	name		= "Security Lower Level"
	target_area = /area/transit_vehicle/elevator/sec_bot

/datum/transit_stop/elevator/dum_top
	stop_id 	= "dum_top"
	name		= "Dumbwaiter Upper Level"
	target_area = /area/transit_vehicle/elevator/dum_top
	current_occupant = "dum_elevator"

/datum/transit_stop/elevator/dum_bot
	stop_id 	= "dum_bot"
	name		= "Dumbwaiter Lower Level"
	target_area = /area/transit_vehicle/elevator/dum_bot
/*
/datum/transit_stop/elevator/
	stop_id 	= ""
	name		= "Upper Level"
	target_area = /area/transit_vehicle/elevator/

/datum/transit_stop/elevator/
	stop_id 	= ""
	name		= "Lower Level"
	target_area = /area/transit_vehicle/elevator/
*/

/*          _______          _________ _______  _        _______  _______
|\     /|(  ____ \|\     /|\__   __/(  ____ \( \      (  ____ \(  ____ \
| )   ( || (    \/| )   ( |   ) (   | (    \/| (      | (    \/| (    \/
| |   | || (__    | (___) |   | |   | |      | |      | (__    | (_____
( (   ) )|  __)   |  ___  |   | |   | |      | |      |  __)   (_____  )
 \ \_/ / | (      | (   ) |   | |   | |      | |      | (            ) |
  \   /  | (____/\| )   ( |___) (___| (____/\| (____/\| (____/\/\____) |
   \_/   (_______/|/     \|\_______/(_______/(_______/(_______/\_______)
                                                                        */

/datum/transit_vehicle/elevator/qm
	vehicle_id = "qm_elevator"
	stop_ids = list("qm_top","qm_bot")


/datum/transit_vehicle/elevator/med
	vehicle_id = "med_elevator"
	stop_ids = list("med_top","med_bot")


/datum/transit_vehicle/elevator/eng
	vehicle_id = "eng_elevator"
	stop_ids = list("eng_top","eng_bot")


/datum/transit_vehicle/elevator/com
	vehicle_id = "com_elevator"
	stop_ids = list("com_top","com_bot")


/datum/transit_vehicle/elevator/sec
	vehicle_id = "sec_elevator"
	stop_ids = list("sec_top","sec_bot")

/datum/transit_vehicle/elevator/dum
	vehicle_id = "dum_elevator"
	stop_ids = list("dum_top","dum_bot")

// computers

/obj/machinery/computer/transit_terminal/qm
	vehicle_id = "qm_elevator"

/obj/machinery/computer/transit_terminal/med
	vehicle_id = "med_elevator"

/obj/machinery/computer/transit_terminal/eng
	vehicle_id = "eng_elevator"

/obj/machinery/computer/transit_terminal/com
	vehicle_id = "com_elevator"

/obj/machinery/computer/transit_terminal/sec
	vehicle_id = "sec_elevator"

/obj/machinery/computer/transit_terminal/dum
	vehicle_id = "dum_elevator"

// thins

/obj/machinery/computer/transit_terminal/thin/qm
	vehicle_id = "qm_elevator"

/obj/machinery/computer/transit_terminal/thin/med
	vehicle_id = "med_elevator"

/obj/machinery/computer/transit_terminal/thin/eng
	vehicle_id = "eng_elevator"

/obj/machinery/computer/transit_terminal/thin/com
	vehicle_id = "com_elevator"

/obj/machinery/computer/transit_terminal/thin/sec
	vehicle_id = "sec_elevator"

/obj/machinery/computer/transit_terminal/thin/dum
	vehicle_id = "dum_elevator"

// buttons

/obj/machinery/button/elevator/med
	vehicle_id = "med_elevator"
	stop_top_id = "med_top"
	stop_bottom_id = "med_bot"

/obj/machinery/button/elevator/qm
	vehicle_id = "qm_elevator"
	stop_top_id = "qm_top"
	stop_bottom_id = "qm_bot"

/obj/machinery/button/elevator/eng
	vehicle_id = "eng_elevator"
	stop_top_id = "eng_top"
	stop_bottom_id = "eng_bot"

/obj/machinery/button/elevator/com
	vehicle_id = "com_elevator"
	stop_top_id = "com_top"
	stop_bottom_id = "com_bot"

/obj/machinery/button/elevator/sec
	vehicle_id = "sec_elevator"
	stop_top_id = "sec_top"
	stop_bottom_id = "sec_bot"

/obj/machinery/button/elevator/dum
	vehicle_id = "dum_elevator"
	stop_top_id = "dum_top"
	stop_bottom_id = "dum_bot"

      //|\\
     // | \\
    //  |  \\
   // shit! \\
  // oh no ! \\
 // A R E A S \\
//|||||||||||||\\

/area/transit_vehicle/
	requires_power = 0 // lintster

/area/transit_vehicle/elevator/qm_top
	name = "Quartermaster's Elevator"
	icon_state = "shuttle"
	filler_turf = "/turf/simulated/floor/specialroom/elevator_shaft/qm"

/area/transit_vehicle/elevator/qm_bot
	name = "Quartermaster's Elevator"
	icon_state = "shuttle2"
	filler_turf = "/turf/simulated/floor/plating"

/area/transit_vehicle/elevator/med_top
	name = "Hospital Elevator"
	icon_state = "shuttle"
	filler_turf = "/turf/simulated/floor/specialroom/elevator_shaft/med"

/area/transit_vehicle/elevator/med_bot
	name = "Hospital Elevator"
	icon_state = "shuttle2"
	filler_turf = "/turf/simulated/floor/plating"

/area/transit_vehicle/elevator/eng_top
	name = "Engineering Elevator"
	icon_state = "shuttle"
	filler_turf = "/turf/simulated/floor/specialroom/elevator_shaft/eng"

/area/transit_vehicle/elevator/eng_bot
	name = "Engineering Elevator"
	icon_state = "shuttle2"
	filler_turf = "/turf/simulated/floor/plating"

/area/transit_vehicle/elevator/com_top
	name = "Command Elevator"
	icon_state = "shuttle"
	filler_turf = "/turf/simulated/floor/specialroom/elevator_shaft/com"

/area/transit_vehicle/elevator/com_bot
	name = "Command Elevator"
	icon_state = "shuttle2"
	filler_turf = "/turf/simulated/floor/plating"

/area/transit_vehicle/elevator/sec_top
	name = "Security Elevator"
	icon_state = "shuttle"
	filler_turf = "/turf/simulated/floor/specialroom/elevator_shaft/sec"

/area/transit_vehicle/elevator/sec_bot
	name = "Security Elevator"
	icon_state = "shuttle2"
	filler_turf = "/turf/simulated/floor/plating"

/area/transit_vehicle/elevator/dum_top
	name = "Dumbwaiter"
	icon_state = "shuttle"
	filler_turf = "/turf/simulated/floor/specialroom/elevator_shaft/dum"

/area/transit_vehicle/elevator/dum_bot
	name = "Dumbwaiter"
	icon_state = "shuttle2"
	filler_turf = "/turf/simulated/floor/plating"

/turf/simulated/floor/specialroom/elevator_shaft/qm
	fall_landmark = LANDMARK_FALL_QM
/turf/simulated/floor/specialroom/elevator_shaft/med
	fall_landmark = LANDMARK_FALL_MED
/turf/simulated/floor/specialroom/elevator_shaft/eng
	fall_landmark = LANDMARK_FALL_ENG
/turf/simulated/floor/specialroom/elevator_shaft/com
	fall_landmark = LANDMARK_FALL_COM
/turf/simulated/floor/specialroom/elevator_shaft/sec
	fall_landmark = LANDMARK_FALL_SEC
/turf/simulated/floor/specialroom/elevator_shaft/dum
	fall_landmark = LANDMARK_FALL_DUM
