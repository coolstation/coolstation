//Datum for pcui templates
//See chui.dm defines
/datum/pcui_template

	//Keep your HTML here
	var/HTML = ""

	var/tags = list()
	var/name = ""
	var/template = ""
	var/header = NULL
	var/window = ""
	var/size = "800x600"

/datum/pcui_template/proc/setup(var/mob/user as mob)
	return
