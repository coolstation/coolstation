// This file contains individual elevator definitions.
// also areas and stuff for each instance.

//Automatically defines an elevator with the following:
//vehicle datum, upper and lower level stops, upper and lower level areas, filler turf, large and small terminals, elevator button, fall landmark
//The elevator starts on the top level, map accordingly. The landmark is there for convenience (reading macros bad)
//The stops will "_id_top"/"_stopname Upper Level" and "_id_bot"/"_stopname Lower Level", whereas _areaname is used verbatim for both areas
#define MAKE_STANDARD_TWO_STOP_ELEVATOR(__id, _stopname, _areaname, _area_sprite)\
ABSTRACT_TYPE(/datum/transit_stop/elevator/__id);\
ABSTRACT_TYPE(/area/transit_vehicle/elevator/__id);\
/datum/transit_stop/elevator/__id/top;\
/datum/transit_stop/elevator/__id/top/name = _stopname+" Upper Level";\
/datum/transit_stop/elevator/__id/top/stop_id = ""+#__id+"_top";\
/datum/transit_stop/elevator/__id/top/target_area = /area/transit_vehicle/elevator/__id/top;\
/datum/transit_stop/elevator/__id/top/current_occupant = ""+#__id+"_elevator";\
/datum/transit_stop/elevator/__id/bot;\
/datum/transit_stop/elevator/__id/bot/name = _stopname+" Lower Level";\
/datum/transit_stop/elevator/__id/bot/stop_id = ""+#__id+"_bot";\
/datum/transit_stop/elevator/__id/bot/target_area = /area/transit_vehicle/elevator/__id/bot;\
/datum/transit_vehicle/elevator/__id;\
/datum/transit_vehicle/elevator/__id/vehicle_id = ""+#__id+"_elevator";\
/datum/transit_vehicle/elevator/__id/stop_ids = list(""+#__id+"_top", ""+#__id+"_bot");\
/obj/machinery/computer/transit_terminal/__id;\
/obj/machinery/computer/transit_terminal/__id/vehicle_id = ""+#__id+"_elevator";\
/obj/machinery/computer/transit_terminal/thin/__id;\
/obj/machinery/computer/transit_terminal/thin/__id/vehicle_id = ""+#__id+"_elevator";\
/obj/machinery/button/elevator/__id;\
/obj/machinery/button/elevator/__id/vehicle_id = ""+#__id+"_elevator";\
/obj/machinery/button/elevator/__id/stop_top_id = ""+#__id+"_top";\
/obj/machinery/button/elevator/__id/stop_bottom_id = ""+#__id+"_bot";\
/area/transit_vehicle/elevator/__id/top;\
/area/transit_vehicle/elevator/__id/top/name = _areaname;\
/area/transit_vehicle/elevator/__id/top/icon_state = _area_sprite;\
/area/transit_vehicle/elevator/__id/top/filler_turf = "/turf/floor/specialroom/elevator_shaft/straight_down";\
/area/transit_vehicle/elevator/__id/bot;\
/area/transit_vehicle/elevator/__id/bot/name = _areaname;\
/area/transit_vehicle/elevator/__id/bot/icon_state = _area_sprite;\
/area/transit_vehicle/elevator/__id/bot/filler_turf = "/turf/floor/plating";\
//I'm not sure if the double underscore in __id ended up necessary but too much effort to change

//Example usage
MAKE_STANDARD_TWO_STOP_ELEVATOR(macro_test, "Mystery Fun", "Mystery Fun Elevator", "funeralparlor")

/*
_________ _______  _______  _        _______ __________________   _______ _________ _______  _______  _______
\__   __/(  ____ )(  ___  )( (    /|(  ____ \\__   __/\__   __/  (  ____ \\__   __/(  ___  )(  ____ )(  ____ \
   ) (   | (    )|| (   ) ||  \  ( || (    \/   ) (      ) (     | (    \/   ) (   | (   ) || (    )|| (    \/
   | |   | (____)|| (___) ||   \ | || (_____    | |      | |     | (_____    | |   | |   | || (____)|| (_____
   | |   |     __)|  ___  || (\ \) |(_____  )   | |      | |     (_____  )   | |   | |   | ||  _____)(_____  )
   | |   | (\ (   | (   ) || | \   |      ) |   | |      | |           ) |   | |   | |   | || (            ) |
   | |   | ) \ \__| )   ( || )  \  |/\____) |___) (___   | |     /\____) |   | |   | (___) || )      /\____) |
   )_(   |/   \__/|/     \||/    )_)\_______)\_______/   )_(     \_______)   )_(   (_______)|/       \_______) */


/datum/transit_stop/elevator
	can_receive_vehicle() //Any amount of blobs in the destination area prevents movement, cause area contents would get moved indiscriminately
		var/area/transit_vehicle/elevator/our_area = locate(target_area) //And blobs are really not built for that sort of thing
		return !our_area.blob_blockage

	vehicle_can_depart() //Similar deal but this is to prevent blobs getting taken on a ride
		var/area/transit_vehicle/elevator/our_area = locate(target_area) //Which is less of a disaster but still
		return !our_area.blob_blockage

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

/datum/transit_stop/elevator/qmdum_top
	stop_id 	= "qmdum_top"
	name		= "Cargo Dumbwaiter Upper Level"
	target_area = /area/transit_vehicle/elevator/qmdum_top
	current_occupant = "qmdum_elevator"

/datum/transit_stop/elevator/qmdum_bot
	stop_id 	= "qmdum_bot"
	name		= "Cargo Dumbwaiter Lower Level"
	target_area = /area/transit_vehicle/elevator/qmdum_bot

/datum/transit_stop/elevator/ntfc_top
	stop_id 	= "ntfc_top"
	name		= "Major Shuttle Dock Ring"
	target_area = /area/transit_vehicle/elevator/ntfc_top

/datum/transit_stop/elevator/ntfc_mid
	stop_id 	= "ntfc_mid"
	name		= "Minor Shuttle Dock Ring"
	target_area = /area/transit_vehicle/elevator/ntfc_mid

/datum/transit_stop/elevator/ntfc_bot
	stop_id 	= "ntfc_bot"
	name		= "Administration"
	target_area = /area/transit_vehicle/elevator/ntfc_bot
	current_occupant = "ntfc_elevator"

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

/datum/transit_vehicle/elevator/qmdum
	vehicle_id = "qmdum_elevator"
	stop_ids = list("qmdum_top","qmdum_bot")

/datum/transit_vehicle/elevator/ntfc
	vehicle_id = "ntfc_elevator"
	stop_ids = list("ntfc_top","ntfc_mid","ntfc_bot")

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

/obj/machinery/computer/transit_terminal/qmdum
	vehicle_id = "qmdum_elevator"

/obj/machinery/computer/transit_terminal/ntfc
	vehicle_id = "ntfc_elevator"
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

/obj/machinery/computer/transit_terminal/thin/qmdum
	vehicle_id = "qmdum_elevator"

/obj/machinery/computer/transit_terminal/thin/ntfc
	vehicle_id = "ntfc_elevator"
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

/obj/machinery/button/elevator/qmdum
	vehicle_id = "qmdum_elevator"
	stop_top_id = "qmdum_top"
	stop_bottom_id = "qmdum_bot"

      //|\\
     // | \\
    //  |  \\
   // shit! \\
  // oh no ! \\
 // A R E A S \\
//|||||||||||||\\

/area/transit_vehicle/
	requires_power = 0 // lintster

/area/transit_vehicle/elevator
	///Count of blob objects keeping this place occupied (don't care about the instances just if any are blocking at all)
	var/blob_blockage = 0

	Entered(atom/movable/A, atom/oldloc)
		if (istype(A, /obj/blob))
			blob_blockage++
		. = ..()

	Exited(atom/movable/A)
		if (istype(A, /obj/blob))
			blob_blockage--
		. = ..()


/area/transit_vehicle/elevator/qm_top
	name = "Quartermaster's Elevator"
	icon_state = "shuttle"
	filler_turf = "/turf/floor/specialroom/elevator_shaft/straight_down"

/area/transit_vehicle/elevator/qm_bot
	name = "Quartermaster's Elevator"
	icon_state = "shuttle2"
	filler_turf = "/turf/floor/plating"

/area/transit_vehicle/elevator/med_top
	name = "Hospital Elevator"
	icon_state = "shuttle"
	filler_turf = "/turf/floor/specialroom/elevator_shaft/straight_down"

/area/transit_vehicle/elevator/med_bot
	name = "Hospital Elevator"
	icon_state = "shuttle2"
	filler_turf = "/turf/floor/plating"

/area/transit_vehicle/elevator/eng_top
	name = "Engineering Elevator"
	icon_state = "shuttle"
	filler_turf = "/turf/floor/specialroom/elevator_shaft/straight_down"

/area/transit_vehicle/elevator/eng_bot
	name = "Engineering Elevator"
	icon_state = "shuttle2"
	filler_turf = "/turf/floor/plating"

/area/transit_vehicle/elevator/com_top
	name = "Command Elevator"
	icon_state = "shuttle"
	filler_turf = "/turf/floor/specialroom/elevator_shaft/straight_down"

/area/transit_vehicle/elevator/com_bot
	name = "Command Elevator"
	icon_state = "shuttle2"
	filler_turf = "/turf/floor/plating"

/area/transit_vehicle/elevator/sec_top
	name = "Security Elevator"
	icon_state = "shuttle"
	filler_turf = "/turf/floor/specialroom/elevator_shaft/straight_down"

/area/transit_vehicle/elevator/sec_bot
	name = "Security Elevator"
	icon_state = "shuttle2"
	filler_turf = "/turf/floor/plating"

/area/transit_vehicle/elevator/dum_top
	name = "Dumbwaiter"
	icon_state = "shuttle"
	filler_turf = "/turf/floor/specialroom/elevator_shaft/straight_down"

/area/transit_vehicle/elevator/dum_bot
	name = "Dumbwaiter"
	icon_state = "shuttle2"
	filler_turf = "/turf/floor/plating"

/area/transit_vehicle/elevator/qmdum_top
	name = "Cargo Dumbwaiter"
	icon_state = "shuttle"
	filler_turf = "/turf/floor/specialroom/elevator_shaft/straight_down"

/area/transit_vehicle/elevator/qmdum_bot
	name = "Cargo Dumbwaiter"
	icon_state = "shuttle2"
	filler_turf = "/turf/floor/plating"

/area/transit_vehicle/elevator/ntfc_top
	name = "Space Elevator"
	icon_state = "shuttle"
	filler_turf = "/turf/floor/specialroom/elevator_shaft/ntfc"

/area/transit_vehicle/elevator/ntfc_mid
	name = "Space Elevator"
	icon_state = "dither_r"
	filler_turf = "/turf/floor/specialroom/elevator_shaft/ntfcm"

/area/transit_vehicle/elevator/ntfc_bot
	name = "Space Elevator"
	icon_state = "shuttle2"
	filler_turf = "/turf/floor/plating"

/turf/floor/specialroom/elevator_shaft/ntfcm
	fall_landmark = LANDMARK_FALL_NTFC
/turf/floor/specialroom/elevator_shaft/ntfc
	fall_landmark = LANDMARK_FALL_NTFCM

#undef MAKE_STANDARD_TWO_STOP_ELEVATOR
