//Datum for pcui templates
//See chui.dm defines
/datum/pcui_template

	//Keep your HTML here
	var/HTML = ""

	var/tags = list()
	var/name = ""
	var/template = ""
	var/header = null
	var/window = ""
	var/size = ""

/datum/pcui_template/proc/setup(var/mob/user as mob)
	name = "example pcui template"
	window = "pcui-example"
	size = "800x600"
	//Injected into the existing head element
	header = {"
	<style>
	body {
		background-color: linen;
	}

	h1 {
 		color: maroon;
		margin-left: 40px;
	}
	</style>
	"}

	template = {"
	<title>[PC_TAG("title")]</title>
	<h1>[PC_TAG("heading")]</h1>

	<p>[PC_TAG("paragraph")]</p>
	"}
