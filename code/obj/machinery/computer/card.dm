//magic number defines for mode
#define IDCOMP_LOGOUT 0
#define IDCOMP_JOB 1
#define IDCOMP_ACCESS 2
#define IDCOMP_MANIFEST 3

/obj/machinery/computer/card
	name = "identification computer"
	icon_state = "id"
	circuit_type = /obj/item/circuitboard/card
	var/obj/item/card/id/scan = null
	var/obj/item/card/id/modify = null
	var/obj/item/eject = null //Overrides modify slot set_loc. sometimes we want to eject something that's not a card. like an implant!
	var/authenticated = FALSE //Clicked Log In, either as AI (innate) or with a suitable ID card installed in the auth slot (or scan variable)
	var/mode = IDCOMP_LOGOUT //Currently displayed screen, changed by HTML
	var/termcolor = "ANSI" //if this is set to ANSI, the totally awesome new version in incredible 8 color is installed!!!! do i mean 8-bit color? no.
	var/printing = null
	var/list/scan_access = null
	var/list/custom_names = list("Custom 1", "Custom 2", "Custom 3")
	var/custom_access_list = list(list(),list(),list())
	//manually edit these lists if you add new and exciting kinds of accesses
	var/list/civilian_access_list = list(access_bar, access_kitchen, access_hydro, access_janitor, access_chapel_office, access_morgue, access_crematorium)
	var/list/utility_access_list = list(access_maint_tunnels, access_engineering_power, access_external_airlocks, access_tech_storage, access_construction, access_emergency_storage)
	var/list/engineering_access_list = list(access_engineering, access_engineering_engine, access_engineering_control, access_engineering_storage, access_engineering_mechanic, access_engineering_atmos, access_engineering_gas)
	var/list/supply_access_list = list(access_hangar, access_cargo, access_supply_console, access_mining, access_mining_shuttle, access_mining_outpost, access_mining_foundry, access_scrapping)
	var/list/medical_access_list = list(access_medical, access_medlab, access_medical_lockers, access_robotics, access_pathology)
	var/list/research_access_list = list(access_research, access_chemistry, access_tox, access_tox_storage)
	var/list/security_access_list = list(access_security, access_brig, access_forensics_lockers, access_maxsec, access_securitylockers, access_carrypermit, access_contrabandpermit)
	var/list/command_access_list = list(access_heads, access_ai_upload, access_change_ids, access_dwaine_superuser, access_teleporter, access_eva, access_ghostdrone)
	var/list/head_access_list = list(access_captain, access_head_of_personnel, access_engineering_chief, access_quartermaster, access_medical_director, access_research_director)
	//associating command office accesses with respective lockers through in-line add/replace
	var/list/head_locker_access_list
	var/list/allowed_access_list
	req_access = list(access_change_ids)
	desc = "A computer that allows an authorized user to change the access and information of other ID cards."

	deconstruct_flags = DECON_MULTITOOL
	light_r =0.7
	light_g = 1
	light_b = 0.1

/obj/machinery/computer/card/New()
	..()
	src.allowed_access_list = civilian_access_list + utility_access_list + engineering_access_list + supply_access_list + medical_access_list + research_access_list + command_access_list + security_access_list + head_access_list - access_maxsec
	src.head_locker_access_list = list("[access_research_director]" = access_research_director_locker, "[access_engineering_chief]" = access_chief_engineer_locker, "[access_medical_director]" = access_medical_director_locker, "[access_head_of_personnel]" = access_head_of_personnel_locker, "[access_quartermaster]" = access_quartermaster_locker)

/obj/machinery/computer/card/console_upper
	icon = 'icons/obj/machines/computerpanel.dmi'
	icon_state = "id1"

/obj/machinery/computer/card/console_lower
	icon = 'icons/obj/machines/computerpanel.dmi'
	icon_state = "id2"

//So here's the meat and potatoes
//If you click on this thing and it's logged out (not set authorized), you will be prompted to log in
//If you are an AI or you have inserted an ID card in the auth-slot, you can log in, otherwise you cannot
//If you select manifest, you'll see crew manifest regardless of modify-slot being populated
/obj/machinery/computer/card/attack_hand(var/mob/user as mob)
	if(..())
		return

	src.add_dialog(user)
	var/dat
	//start building header shit including general computer and id computer specific css, let's get reasonably compliant here
	//computer.css should have general box/computery look stuff
	//idcomputer.css should have specific classes that are not present in computer.css (or values needing override)
	dat = {"<html>
		<title>ID Computer</title>
		<head>
		<link rel="stylesheet" type="text/css" href="[resource("css/COMPUTAH.css")]" />
		<link rel="stylesheet" type="text/css" href="[resource("css/idcomputer.css")]" />"}
	//color upgrade install (by class: .color or .color.bright, these classes are ignored if not present for graceful monochrome)
	if (src.termcolor == "ANSI")
		dat += {"<link rel="stylesheet" type="text/css" href="[resource("css/color-ansi.css")]" />"}
	//button will be solid if referring to active mode, outlined if it's selectable
	dat += {"</head><body>"}
	//frame with virtual monitor
	//dat += {"<div class="monitorinset>"}
	//start of proper visual plus crt flicker (eventually make this an effect that can be turned off)
	dat += {"<div class="crt"></div>"}
	//header: in-window title
	dat += {"
	<div class="box surround"><h1>Nanotrasen Personnel Records System [src.termcolor == "ANSI" ? "v2.7" : "v2.6"]</h1></div>
	<div class="box inverse surround">
		<div [src.mode == IDCOMP_JOB ? "class = \"box button\"" : "class =\"box button inverse\""]>[src.mode == IDCOMP_JOB ? "ID Modification" : "<a href=\"?src=\ref[src];mode=1\">ID Modification</a>"]</div>
		<div [src.mode == IDCOMP_ACCESS ? "class = \"box button\"" : "class =\"box button inverse\""]>[src.mode == IDCOMP_ACCESS ? "Custom Access" : "<a href=\"?src=\ref[src];mode=2\">Custom Access</a>"]</div>
		<div [src.mode == IDCOMP_MANIFEST ? "class = \"box button\"" : "class =\"box button inverse\""]>[src.mode == IDCOMP_MANIFEST ? "Crew Manifest" : "<a href=\"?src=\ref[src];mode=3\">Crew Manifest</a>"]</div>
	</div>"}
	//category buttons: solid and with no destination if already active mode

	if (!( ticker ))
		return

	//get footer shit out of the way (these are used before the footer appears, and that is always visible regardless of login or out)
	var/target_name
	var/target_owner
	var/target_rank

	if(src.modify)
		target_name = src.modify.name
	else
		target_name = "--------"
	if(src.modify && src.modify.registered)
		target_owner = src.modify.registered
	else
		target_owner = "--------"
	if(src.modify && src.modify.assignment)
		target_rank = src.modify.assignment
	else
		target_rank = "Unassigned"
	if (src.eject)
		target_name = src.eject.name

	var/scan_name
	if(src.scan)
		scan_name = src.scan.name
	else
		scan_name = "--------"

	//bottom of page, eventually will be held outside of 'screen'
	//To Change
	//fuck you any hanging divs fuck you so much
	var/footer = {"<div class = "box inverse"><span class="white bright">ID To Modify:</span> <a href="byond://?src=\ref[src];modify=1">[target_name]</a></div>"}
	//Auth ID
	footer += {"<div class="box inverse"><span class="white bright">Authorizing ID:</span> <a href="byond://?src=\ref[src];scan=1">[scan_name]</a></div><br>"}

	if (src.mode)
		//the core of whatever modes. if you're not logged in it won't work
		var/header = list()
		var/body = list()
		//access/state tree
		//keep track of your divs you dirty animals! if you open it in an inner section you should close it in that inner section (exception: overall container divs, to be handled at the start and at the end)
		if (src.authenticated) //ID with suitable access (or AC usage) detected, valid to eat fingers
			switch (src.mode)
				if (IDCOMP_MANIFEST)
					header = {"<div class="box inverse surround" style="flex-direction: column"><h1>Crew Manifest</h1><div class="disclaimer">Please use security record computer to modify entries.</div>"}
					//start the table header
					var/crew = {"<tr><th>NAME</th><th>RANK</th></tr>"}
					//each crew and job gets recorded as a row
					for(var/datum/db_record/t as anything in data_core.general.records)
						crew += "<tr><td>[t["name"]]</td> <td>[t["rank"]]</td></tr>"
					//splitting this out for readability and easy tag handling
					dat += {"<div class="box inverse surround"><table>[crew]</table><br>"}
					dat += {"<div class="box button inverse"><a href="?src=\ref[src];print=1">Print</a></div></div>"}
					//goto end for footer add
				if (IDCOMP_JOB)
					if (!src.modify)
						body += "No ID card inserted.<br>"
					//Set up job lists, divided into sections
					var/list/civilianjobs = list("Staff Assistant", "Bartender", "Chef", "Botanist", "Chaplain", "Janitor", "Clown")
					var/list/maintainencejobs = list("Engineer", "Mechanic", "Atmospheric Technician", "Miner", "Cargo Technician", "Scrapper")
					var/list/researchjobs = list("Scientist", "Chemist", "Medical Doctor", "Geneticist", "Roboticist", "Pathologist", "Surgeon", "Nurse", "Receptionist")
					var/list/securityjobs = list("Security Officer", "Security Assistant", "Detective")
					var/list/commandjobs = list("Captain", "Head of Personnel",  "Research Director", "Medical Director", "Chief Engineer", "Quartermaster")
					//TODO: "adjust salary?" button
					//start container box and put in headerheader
					header += {"<div class="box inverse"><div class="inHeader white bright">Job-Based Quick Access Selection</div>"}
					//list the jobs
					//highlight job if inserted title matches name
					//also use nonbreaking spaces to make sure there isn't a line break in the middle of a job
					body += {"<div class style="flex-direction:row"><span class="cyan bright">Civilian:</span>"}
					for(var/job in civilianjobs)
						body += {" <a class="job[target_rank == job ? " selected" : ""]" href="byond://?src=\ref[src];assign=[job];idcolor=blue">[replacetext(job, " ", "&nbsp")]</a>"}
					body += {"<br><span class="yellow bright">Technical:</span>"}
					for(var/job in maintainencejobs)
						body += {" <a class="job[target_rank == job ? " selected" : ""]" href="byond://?src=\ref[src];assign=[job];idcolor=yellow">[replacetext(job, " ", "&nbsp")]</a>"}
					body += {"<br><span class="magenta bright">Med-Sci:</span>"}
					for(var/job in researchjobs)
						body += {" <a class="job[target_rank == job ? " selected" : ""]" href="byond://?src=\ref[src];assign=[job];idcolor=purple">[replacetext(job, " ", "&nbsp")]</a>"}
					body += {"<br><span class="red bright">Security:</span>"}
					for(var/job in securityjobs)
						body += {" <a class="job[target_rank == job ? " selected" : ""]" href="byond://?src=\ref[src];assign=[job];idcolor=red">[replacetext(job, " ", "&nbsp")]</a>"}
					body += {"<br><span class="green bright">Command:</span>"}
					for(var/job in commandjobs)
						body += {" <a class="job[target_rank == job ? " selected" : ""]" href="byond://?src=\ref[src];assign=[job];idcolor=green">[replacetext(job, " ", "&nbsp")]</a>"}
					//show the custom saved jobs/access lists as their name (unlike custom)
					body += {"<br><span class="white bright">Custom:</span>"}
					for (var/i = 1, i <= custom_names.len, i++)
						body += {" <a class="job[target_rank == src.custom_names[i] ? " selected" : ""]" href="byond://?src=\ref[src];apply=[i]">[src.custom_names[i]]</a>"}
					//close the div
					body += "</div>"

				if (IDCOMP_ACCESS)
					if (!src.modify)
						body += "No ID card inserted.<br>"
					//Set up access lists, divided into sections. These will be plopped into the HTML blob "body"
					var/civilian_access = list("<div class=\"box inverse accessgroup\">Staff:")
					var/utility_access = list("<div class=\"box inverse accessgroup\">Utility:")
					var/engineering_access = list("<div class=\"box inverse accessgroup\">Engineering:")
					var/supply_access = list("<div class=\"box inverse accessgroup\">Supply:")
					var/research_access = list("<div class=\"box inverse accessgroup\">Science:")
					var/medical_access = list("<div class=\"box inverse accessgroup\">Medical:")
					var/security_access = list("<div class=\"box inverse accessgroup\">Security:")
					var/command_access = list("<div class=\"box inverse accessgroup\">Command:")
					var/head_access = list("<div class=\"box inverse accessgroup\">Head:")

					//Modify Name/Job/PIN at top
					//put this in a wide div with properties tbd
					//removed <div class="box inverse surround"> from start of first header line here
					header += {"<div class="white bright">Individual Access Selection</div>"}
					header += {"<div class="box inverse surround">Individual Access Selection</div>"}
					header = {"<div class="box">ID Registered Name:</div> <a href="byond://?src=\ref[src];reg=1">[target_owner]</a>"}
					header += {"<div class="box">ID Job Assignment:</div> <a href="byond://?src=\ref[src];assign=Custom Assignment">[replacetext(target_rank, " ", "&nbsp")]</a>"}
					header += {"<div class="box">Personal PIN Number:</div> <a href="byond://?src=\ref[src];pin=1">****</a></div></div>"}
					//holder for access below. see if we can move these styles to css
					//body += {"<div class="box inverse" style="justify-content: space-evenly; align-items: center;">"} //probably can reimplement this but holding on just in case

					//build out lists for each section, leading spaces between each. replace spaces in job names with non-breaking spaces to avoid splitting up a multi-word job title between two lines
					for(var/A in access_name_lookup)
						//Go through the list and compare with existing target ID access
						//Add links to Remove Access entries (with appropriate style) to be added to the HTML blob
						if(access_name_lookup[A] in src.modify.access)
							if (access_name_lookup[A] in civilian_access_list)
								civilian_access += {" <a class="selected active" href="byond://?src=\ref[src];access=[access_name_lookup[A]];allowed=0">[replacetext(A, " ", "&nbsp")]</a>"}
							if (access_name_lookup[A] in utility_access_list)
								utility_access += {" <a class="selected active" href="byond://?src=\ref[src];access=[access_name_lookup[A]];allowed=0">[replacetext(A, " ", "&nbsp")]</a>"}
							if (access_name_lookup[A] in engineering_access_list)
								engineering_access += {" <a class="selected active" href="byond://?src=\ref[src];access=[access_name_lookup[A]];allowed=0">[replacetext(A, " ", "&nbsp")]</a>"}
							if (access_name_lookup[A] in supply_access_list)
								supply_access += {" <a class="selected active" href="byond://?src=\ref[src];access=[access_name_lookup[A]];allowed=0">[replacetext(A, " ", "&nbsp")]</a>"}
							if (access_name_lookup[A] in medical_access_list)
								medical_access += {" <a class="selected active" href="byond://?src=\ref[src];access=[access_name_lookup[A]];allowed=0">[replacetext(A, " ", "&nbsp")]</a>"}
							if (access_name_lookup[A] in research_access_list)
								research_access += {" <a class="selected active" href="byond://?src=\ref[src];access=[access_name_lookup[A]];allowed=0">[replacetext(A, " ", "&nbsp")]</a>"}
							if (access_name_lookup[A] in security_access_list)
								security_access += {" <a class="selected active" href="byond://?src=\ref[src];access=[access_name_lookup[A]];allowed=0">[replacetext(A, " ", "&nbsp")]</a>"}
							if (access_name_lookup[A] in command_access_list)
								command_access += {" <a class="selected active" href="byond://?src=\ref[src];access=[access_name_lookup[A]];allowed=0">[replacetext(A, " ", "&nbsp")]</a>"}
							if (access_name_lookup[A] in head_access_list)
								head_access += {" <a class="selected active" href="byond://?src=\ref[src];access=[access_name_lookup[A]];allowed=0">[replacetext(A, " ", "&nbsp")]</a>"}
							//a little funky but it replaces list item with a little locker access dingle (to keep them together)
								if ("[access_name_lookup[A]]" in head_locker_access_list)
									var/access_num_locker = head_locker_access_list["[access_name_lookup[A]]"]
									if (access_num_locker in src.modify.access)
										head_access += {"&nbsp<i>(<a class="selected" href="byond://?src=\ref[src];access=[access_num_locker];allowed=0">Locker</a>)</i>"}
									else
										head_access += {"&nbsp<i>(<a class="inactive red" href="byond://?src=\ref[src];access=[access_num_locker];allowed=1">Locker</a>)</i>"}
						//Add Access entries to be added to the HTML blob
						else
							if (access_name_lookup[A] in civilian_access_list)
								civilian_access += {" <a class="inactive red" href="byond://?src=\ref[src];access=[access_name_lookup[A]];allowed=1">[replacetext(A, " ", "&nbsp")]</a>"}
							if (access_name_lookup[A] in utility_access_list)
								utility_access += {" <a class="inactive red" href="byond://?src=\ref[src];access=[access_name_lookup[A]];allowed=1">[replacetext(A, " ", "&nbsp")]</a>"}
							if (access_name_lookup[A] in engineering_access_list)
								engineering_access += {" <a class="inactive red" href="byond://?src=\ref[src];access=[access_name_lookup[A]];allowed=1">[replacetext(A, " ", "&nbsp")]</a>"}
							if (access_name_lookup[A] in supply_access_list)
								supply_access += {" <a class="inactive red" href="byond://?src=\ref[src];access=[access_name_lookup[A]];allowed=1">[replacetext(A, " ", "&nbsp")]</a>"}
							if (access_name_lookup[A] in medical_access_list)
								medical_access += {" <a class="inactive red" href="byond://?src=\ref[src];access=[access_name_lookup[A]];allowed=1">[replacetext(A, " ", "&nbsp")]</a>"}
							if (access_name_lookup[A] in research_access_list)
								research_access += {" <a class="inactive red" href="byond://?src=\ref[src];access=[access_name_lookup[A]];allowed=1">[replacetext(A, " ", "&nbsp")]</a>"}
							if (access_name_lookup[A] in security_access_list)
								security_access += {" <a class="inactive red" href="byond://?src=\ref[src];access=[access_name_lookup[A]];allowed=1">[replacetext(A, " ", "&nbsp")]</a>"}
							if (access_name_lookup[A] in command_access_list)
								command_access += {" <a class="inactive red" href="byond://?src=\ref[src];access=[access_name_lookup[A]];allowed=1">[replacetext(A, " ", "&nbsp")]</a>"}
							if (access_name_lookup[A] in head_access_list)
								head_access += {" <a class="inactive red" href="byond://?src=\ref[src];access=[access_name_lookup[A]];allowed=1">[replacetext(A, " ", "&nbsp")]</a>"}
								if ("[access_name_lookup[A]]" in head_locker_access_list)
									var/access_num_locker = head_locker_access_list["[access_name_lookup[A]]"]
									if (access_num_locker in src.modify.access)
										head_access += {"&nbsp<a class="selected" href="byond://?src=\ref[src];access=[access_num_locker];allowed=0"><i>(Locker)</i></a>"}
									else
										head_access += {"&nbsp<a class="inactive red" href="byond://?src=\ref[src];access=[access_num_locker];allowed=1"><i>(Locker)</i></a>"}
					//end of lists

					//TODO: quick "salary to untrained/tradesman/doctorate" buttons?

					//Add the above formed lists to the actual blob of HTML to be shown to client
					//This has a two column grid (80/20) wrapper with the 80 column subdivided into two more columns via flexbox with access divs stuffed into them
					//The flexbox is closed in this line but the 80/20 wrapper remains open for the ID colors and custom access
					//Closing div tag after every access list added keeps it nice and clean
					body += {"<div class="box inverse"><div class="accessgrid"><div class=\"accesslist\">[jointext(civilian_access, "")]</div>[jointext(utility_access, "")]</div>[jointext(engineering_access, "")]</div>[jointext(supply_access, "")]</div>[jointext(medical_access, "")]</div>[jointext(research_access, "")]</div>[jointext(security_access, "")]</div>[jointext(command_access, "")]</div>[jointext(head_access, "")]</div></div></div>"}
					//20% right-hand column
					//ID colors
					//if your ID matches a state, highlight the box and make it not clickable
					body += {"<div class = "box inverse" style = "flex-direction:column"><div class = "inHeader"><u>Customise ID</u></div>"}
					body += {"<a class="pln[src.modify.icon_state == "id" ? " selected" : " href=\"byond://?src=\ref[src];idcolor=none"]">Plain</a> "}
					body += {"<a class="civ[src.modify.icon_state == "id_civ" ? " selected" : " href=\"byond://?src=\ref[src];idcolor=blue"]">Civilian</a> "}
					body += {"<a class="eng[src.modify.icon_state == "id_eng" ? " selected" : " href=\"byond://?src=\ref[src];idcolor=yellow"]">Engineering</a> "}
					body += {"<a class="log[src.modify.icon_state == "id_log" ? " selected" : " href=\"byond://?src=\ref[src];idcolor=orange"]">Logistics</a> "}
					body += {"<a class="res[src.modify.icon_state == "id_res" ? " selected" : " href=\"byond://?src=\ref[src];idcolor=purple"]">Med-Sci</a> "}
					body += {"<a class="sec[src.modify.icon_state == "id_sec" ? " selected" : " href=\"byond://?src=\ref[src];idcolor=red"]">Security</a> "}
					body += {"<a class="com[src.modify.icon_state == "id_com" ? " selected" : " href=\"byond://?src=\ref[src];idcolor=green"]">Command</a> "}
					//Custom access/job management
					body += {"<div><span class="white bright">Custom Access/Title:</span><br>"}
					for (var/i = 1, i <= custom_names.len, i++)
						body += {" <span class="white bright">[src.custom_names[i]]</span> <br><a href="byond://?src=\ref[src];save=[i]">save</a> <a href="byond://?src=\ref[src];apply=[i]">apply</a><br>"}
					//now we close this div and the 80/20 grid
					body += "</div></div>"

					user.unlock_medal("Identity Theft", 1)
		else //unauthenticated
			//handle login prompt, do not show access
			header = {"<div class="white bright"><h2>Welcome To You're ID Management Solution</h2></div>"}
			body += {"<div class = "box inverse button"><a href="byond://?src=\ref[src];auth=1">{Log In To System}</a></div>"}
		header = jointext(header, "")
		body = jointext(body, "")

		dat += {"[header][body]"}
	else
		dat += {"<div class = "box inverse button"><a href="byond://?src=\ref[src];auth=1">{Log In To System}</a></div>"}
	//add everpresent footer and close out html
	footer = jointext(footer, "")
	//fuck you there is some dangling div fuck you
	dat += {"</div></div></div><div class="box inverse surround" style="flex-direction:row">[footer]</div></body></html>"}
	user.Browse(dat, "window=id_com;size=1000x700")
	onclose(user, "id_com")
	return

/obj/machinery/computer/card/Topic(href, href_list)
	if(..())
		return
	src.add_dialog(usr)

	if (href_list["modify"])
		if (src.modify)
			src.modify.update_name()
			if (src.eject)
				usr.put_in_hand_or_eject(src.eject)
				src.eject.pixel_y = 6
				src.eject = null
			else
				usr.put_in_hand_or_eject(src.modify)
				src.modify.pixel_y = 6
			src.modify = null
		else
			var/obj/item/I = usr.equipped()
			if (!istype(I,/obj/item/card/id))
				I = get_card_from(I)
			if (istype(I, /obj/item/card/id))
				usr.drop_item()
				if (src.eject)
					src.eject.set_loc(src)
				else
					I.set_loc(src)
				src.modify = I
			else if (istype(I, /obj/item/magtractor))
				var/obj/item/magtractor/mag = I
				if (istype(mag.holding, /obj/item/card/id))
					I = mag.holding
					mag.dropItem(0)
					if (src.eject)
						src.eject.set_loc(src)
					else
						I.set_loc(src)
					src.modify = I
			if (I && !src.modify)
				boutput(usr, "<span class='notice'>[I] won't fit in the modify slot.</span>")

	if (href_list["scan"])
		if (src.scan)
			usr.put_in_hand_or_eject(src.scan)
			src.scan.pixel_y = -6
			src.scan = null
			src.authenticated = 0
			src.scan_access = null
		else
			var/obj/item/I = usr.equipped()
			if (istype(I, /obj/item/card/id))
				usr.drop_item()
				I.set_loc(src)
				src.scan = I
			else if (istype(I, /obj/item/magtractor))
				var/obj/item/magtractor/mag = I
				if (istype(mag.holding, /obj/item/card/id))
					I = mag.holding
					mag.dropItem(0)
					I.set_loc(src)
					src.modify = I
			else
				boutput(usr, "<span class='notice'>[I] won't fit in the authentication slot.</span>")


	if (href_list["auth"])
		if ((!( src.authenticated ) && (src.scan || ((issilicon(usr) || isAI(usr)) && !isghostdrone(usr))) && (src.modify || src.mode)))
			if (src.check_access(src.scan))
				src.authenticated = TRUE
				src.mode = IDCOMP_JOB
				src.scan_access = src.scan.access
		else if ((!( src.authenticated ) && (issilicon(usr) || isAI(usr))) && (!src.modify))
			boutput(usr, "You can't modify an ID without an ID inserted to modify. Once one is in the modify slot on the computer, you can log in.")

	if(href_list["access"] && href_list["allowed"])
		if(src.authenticated)
			var/access_type = text2num(href_list["access"])
			var/access_allowed = text2num(href_list["allowed"])
			if(access_type in (get_all_accesses() + list(access_research_director_locker, access_chief_engineer_locker, access_medical_director_locker, access_head_of_personnel_locker, access_quartermaster_locker)))
				src.modify.access -= access_type
				if(access_allowed == TRUE)
					src.modify.access += access_type

	if (href_list["assign"])
		if (src.authenticated && src.modify)
			var/t1 = href_list["assign"]

			if(t1 == "Head of Security")
				return

			if (t1 == "Custom Assignment")
				t1 = input(usr, "Enter a custom job assignment.", "Assignment")
				t1 = strip_html(t1, 100, 1)
				playsound(src.loc, "keyboard", 50, 1, SOUND_RANGE_SMALL)
			else
				src.modify.access = get_access(t1)

			//Wire: This possibly happens after the input() above, so we re-do the initial checks
			if (src.authenticated && src.modify)
				src.modify.assignment = t1


	if (href_list["reg"])
		if (src.authenticated)
			var/t2 = src.modify

			var/t1 = input(usr, "What name?", "ID computer", null)
			t1 = strip_html(t1, 100, 1)

			if ((src.authenticated && src.modify == t2 && (in_interact_range(src, usr) || (issilicon(usr) || isAI(usr))) && istype(src.loc, /turf)))
				logTheThing("station", usr, null, "changes the registered name on the ID card from [src.modify.registered] to [t1]")
				src.modify.registered = t1

			playsound(src.loc, "keyboard", 50, 1, SOUND_RANGE_SMALL)

	if (href_list["pin"])
		if (src.authenticated)
			var/currentcard = src.modify

			var/newpin = input(usr, "Enter a new PIN.", "ID computer", 0) as null|num

			if ((src.authenticated && src.modify == currentcard && (in_interact_range(src, usr) || (istype(usr, /mob/living/silicon))) && istype(src.loc, /turf)))
				if(newpin < 1000)
					src.modify.pin = 1000
				else if(newpin > 9999)
					src.modify.pin = 9999
				else
					src.modify.pin = round(newpin)
				playsound(src.loc, "keyboard", 50, 1, SOUND_RANGE_SMALL)

	if (href_list["mode"]) //change between ID stuff and crew manifest
		if (src.authenticated)
			src.mode = text2num(href_list["mode"])
		else
			src.mode = IDCOMP_LOGOUT

	if (href_list["logout"]) //change between ID stuff and crew manifest
		src.authenticated = FALSE

	if (href_list["print"])
		if (!( src.printing ))
			src.printing = 1
			sleep(5 SECONDS)
			var/obj/item/paper/P = new()
			P.set_loc(src.loc)

			var/t1 = "<B>Crew Manifest:</B><BR>"
			for(var/datum/db_record/t as anything in data_core.general.records)
				t1 += "<B>[t["name"]]</B> - [t["rank"]]<BR>"
			P.info = t1
			P.name = "paper- 'Crew Manifest'"
			src.printing = null

	//change ID stripe color
	if (href_list["idcolor"])
		if(src.modify.keep_icon == FALSE) // ids that are FALSE will update their icon if the job changes
			var/newidcolor = href_list["idcolor"]
			if (newidcolor == "none")
				src.modify.icon_state = "id"
			if (newidcolor == "blue")
				src.modify.icon_state = "id_civ"
			if (newidcolor == "yellow")
				src.modify.icon_state = "id_eng"
			if (newidcolor == "orange")
				src.modify.icon_state = "id_log"
			if (newidcolor == "purple")
				src.modify.icon_state = "id_res"
			if (newidcolor == "red")
				src.modify.icon_state = "id_sec"
			if (newidcolor == "green")
				src.modify.icon_state = "id_com"

	if (href_list["save"])
		var/slot = text2num(href_list["save"])
		if (!src.modify.assignment)
			src.custom_names[slot] = "Custom [slot]"
		else
			src.custom_names[slot] = src.modify.assignment
		src.custom_access_list[slot] = src.modify.access.Copy()
		src.custom_access_list[slot] &= allowed_access_list //prevent saving non-allowed accesses

	if (href_list["apply"])
		var/slot = text2num(href_list["apply"])
		src.modify.assignment = src.custom_names[slot]
		var/list/selected_access_list = src.custom_access_list[slot]
		src.modify.access = selected_access_list.Copy()

	if (src.modify)
		src.modify.name = "[src.modify.registered]'s [src.modify.generic_name] <br>([src.modify.assignment])"

	if (src.eject)
		if (istype(src.eject,/obj/item/implantcase/access))
			var/obj/item/implantcase/access/A = src.eject
			var/obj/item/implant/access/I = A.imp
			var/iassign = "None"
			if (istype(I) && I.access)
				iassign = I.access.assignment
			A.name = "glass case - 'Electronic Access' ([iassign])"
		else if (istype(src.eject, /obj/item/implant/access))
			var/obj/item/implant/access/A = src.eject
			A.name = "electronic access implant ([A.access ? A.access.assignment : "None"])"
	src.updateUsrDialog()
	return

/obj/machinery/computer/card/attackby(obj/item/I as obj, mob/user as mob)
	//grab the ID card from an access implant if this is one
	var/modify_only = 0
	if (!istype(I,/obj/item/card/id))
		I = get_card_from(I)
		modify_only = 1

	if (modify_only && src.eject && !src.scan && src.modify)
		boutput(user, "<span class='notice'>[src.eject] will not work in the authentication card slot.</span>")
		return
	else if (istype(I, /obj/item/card/id))
		if ((!src.scan && !modify_only) && src.check_access(I)) //QOL do a simultaneous front-loaded auth check: if it won't work for auth, then insert it as a target card if the slot's open. ezpz
			boutput(user, "<span class='notice'>You insert [I] into the authentication card slot.</span>")
			user.drop_item()
			I.set_loc(src)
			src.scan = I
		else if (!src.modify)
			boutput(user, "<span class='notice'>You insert [src.eject ? src.eject : I] into the target card slot.</span>")
			user.drop_item()
			if (src.eject)
				src.eject.set_loc(src)
			else
				I.set_loc(src)
			src.modify = I
		src.updateUsrDialog()
		return
	else
		..()
	return

/obj/machinery/computer/card/proc/get_card_from(obj/item/I as obj)
	if (istype(I, /obj/item/implantcase/access))
		src.eject = I
		var/obj/item/implantcase/access/A = I
		if (A.imp)
			return A.imp:access
	else if (istype(I, /obj/item/implant/access)) //accept access implant - get their ID
		src.eject = I
		return I:access
	return I

//tidy up defines
#undef IDCOMP_LOGOUT
#undef IDCOMP_JOB
#undef IDCOMP_ACCESS
#undef IDCOMP_MANIFEST
